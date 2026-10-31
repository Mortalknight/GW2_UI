---@class GW2
local GW = select(2, ...)

--[[
    The quest log of the classic clients, one file for all of them. Two kinds of quest log exist:
    era and tbc list their quests in fixed rows (QuestLogTitle1..n) inside one frame, wrath and mists
    scroll a hybrid list and open the details in a frame of their own (QuestLogDetailFrame).
    The npc quest dialog (QuestFrame) is skinned by questFrame.lua.
]]

local HEADER_COLOR = GW.Colors.TextColors.LightHeader
local TEXT_COLOR = GW.Colors.FallbackWhite
local MONEY_MISSING_COLOR = GW.Colors.SkinColors.Disabled
local MONEY_OK_COLOR = GW.Colors.SkinColors.QuestGold
local OBJECTIVE_DONE_COLOR = GW.Colors.SkinColors.QuestGold
local OBJECTIVE_OPEN_COLOR = GW.Colors.SkinColors.ObjectiveOpen
local ARROW_RIGHT = "Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right.png"
local ARROW_DOWN = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local CHECKBOX = "Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png"
local CHECKBOX_CHECKED = "Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png"
-- era and tbc: the list as wide as the details under it
local LIST_WIDTH = (GW.Classic or GW.TBC) and 335 or 303

local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetItemQualityColor = C_Item and C_Item.GetItemQualityColor or GetItemQualityColor

local function SetColor(text, color)
    if text then
        text:SetTextColor(color:GetRGB())
    end
end

-- not every client has every text, the missing ones are nil in the middle of the list
local function SetColors(color, ...)
    for i = 1, select("#", ...) do
        SetColor(select(i, ...), color)
    end
end

---------- reward and requirement items ----------

-- an item row like on retail: the quality frame only around the icon, the name on our name plate
local function SkinItemButton(item)
    if not item or item.gwSkinned then return end
    item.gwSkinned = true
    item:SetSize(143, 40)

    if item.Icon then
        item.Icon:SetSize(35, 35)
        item.Icon:SetDrawLayer("ARTWORK")
        item.Icon:SetPoint("TOPLEFT", 2, -2)
        GW.HandleIcon(item.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
        item.Icon.backdrop:SetFrameLevel(item:GetFrameLevel() + 1)
    end
    if item.IconBorder then
        GW.HandleIconBorder(item.IconBorder, item.Icon and item.Icon.backdrop)
    end
    local nameFrame = item.NameFrame or item:GetName() and _G[item:GetName() .. "NameFrame"]
    if nameFrame then
        nameFrame:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/nameframe.png")
        nameFrame:SetAlpha(0.75)
    end
    if item.Count then
        item.Count:SetDrawLayer("OVERLAY")
        item.Count:ClearAllPoints()
        item.Count:SetPoint("BOTTOMRIGHT", item.Icon, "BOTTOMRIGHT", 0, 0)
    end
    if item.Name then
        item.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    end
    for _, key in ipairs({"IconOverlay", "CircleBackground", "CircleBackgroundGlow"}) do
        if item[key] then
            item[key]:SetAlpha(0)
        end
    end
    -- spell rewards bring a piece of the old spellbook art
    for _, region in ipairs({item:GetRegions()}) do
        if region:IsObjectType("Texture") and region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
            region:SetTexture("")
        end
    end
end

-- the icon frame in the quality color of the item, white for common and below; the name stays white like on retail
local function ColorItemByQuality(item, name, link)
    -- reward buttons blizzard has not created yet
    if not item or not name then return end
    SkinItemButton(item)
    local quality = link and select(3, GetItemInfo(link))
    local r, g, b = 1, 1, 1
    if quality and quality > 1 then
        r, g, b = GetItemQualityColor(quality)
    end
    name:SetTextColor(TEXT_COLOR:GetRGB())
    if item.Icon and item.Icon.backdrop then
        item.Icon.backdrop:SetBackdropBorderColor(r, g, b)
    end
end

local function GetRewardLink(item)
    local fromLog = QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink
    return item.type and fromLog(item.type, item:GetID())
end

local function ColorRewardItems()
    for i = 1, #QuestInfoRewardsFrame.RewardButtons do
        local item = _G["QuestInfoRewardsFrameQuestInfoItem" .. i]
        ColorItemByQuality(item, _G["QuestInfoRewardsFrameQuestInfoItem" .. i .. "Name"], GetRewardLink(item))
    end
end

-- the picked reward in gold, the others keep their quality
local function MarkChosenReward(chosen)
    if chosen.type ~= "choice" then return end
    ColorRewardItems()
    if chosen.Icon and chosen.Icon.backdrop then
        chosen.Icon.backdrop:SetBackdropBorderColor(MONEY_OK_COLOR:GetRGB())
    end
    _G[chosen:GetName() .. "Name"]:SetTextColor(MONEY_OK_COLOR:GetRGB())
end

-- grey while the player lacks the money a quest asks for
local function ColorRequiredMoney(text, amount)
    if amount > 0 then
        SetColor(text, amount > GetMoney() and MONEY_MISSING_COLOR or MONEY_OK_COLOR)
    end
end

local function ColorQuestLogMoney()
    ColorRequiredMoney(QuestInfoRequiredMoneyText, GetQuestLogRequiredMoney())
end

---------- the quest texts ----------

-- the detail texts of era and tbc, which do not use QuestInfo yet
local function ColorQuestLogTexts()
    for _, name in ipairs({"QuestLogDescriptionTitle", "QuestLogRewardTitleText", "QuestLogQuestTitle"}) do
        SetColor(_G[name], HEADER_COLOR)
    end
    for _, name in ipairs({"QuestLogItemChooseText", "QuestLogItemReceiveText", "QuestLogObjectivesText", "QuestLogQuestDescription",
        "QuestLogSpellLearnText", "QuestInfoQuestType"}) do
        SetColor(_G[name], TEXT_COLOR)
    end
    ColorQuestLogMoney()
    if QuestLogItem1 and QuestLogItemChooseText then
        QuestLogItem1:SetPoint("TOPLEFT", QuestLogItemChooseText, "BOTTOMLEFT", 1, -3)
    end

    -- spell objectives have no line of their own
    local line = 0
    for i = 1, GetNumQuestLeaderBoards() do
        local _, objectiveType, finished = GetQuestLogLeaderBoard(i)
        if objectiveType ~= "spell" then
            line = line + 1
            SetColor(_G["QuestLogObjective" .. line], finished and OBJECTIVE_DONE_COLOR or OBJECTIVE_OPEN_COLOR)
        end
    end

    for i = 1, MAX_NUM_ITEMS do
        local item = _G["QuestLogItem" .. i]
        if item then
            ColorItemByQuality(item, _G["QuestLogItem" .. i .. "Name"], item.type and (GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID()))
        end
    end
end

-- the texts of the QuestInfo frame the log and the npc dialog share
local function ColorQuestInfoTexts()
    local rewards = QuestInfoRewardsFrame
    SetColors(HEADER_COLOR, QuestInfoTitleHeader, QuestInfoDescriptionHeader, QuestInfoObjectivesHeader, rewards.Header)
    SetColors(TEXT_COLOR, QuestInfoDescriptionText, QuestInfoObjectivesText, QuestInfoGroupSize, QuestInfoRewardText, QuestInfoQuestType,
        rewards.ItemChooseText, rewards.ItemReceiveText, rewards.XPFrame and rewards.XPFrame.ReceiveText, rewards.PlayerTitleText,
        QuestInfoRewardsFrameHonorReceiveText, QuestInfoRewardsFrameReceiveText)
    for i = 1, GetNumQuestLeaderBoards() do
        local objective = _G["QuestInfoObjective" .. i]
        if not objective then break end
        SetColor(objective, TEXT_COLOR)
    end

    -- the spell reward headers take their color from the pool
    local spellHeaders = rewards.spellHeaderPool
    spellHeaders.textR, spellHeaders.textG, spellHeaders.textB = TEXT_COLOR:GetRGB()
    for header in spellHeaders:EnumerateActive() do
        header:SetVertexColor(GW.Colors.FallbackWhite:GetRGB())
    end
    GW.SkinPoolFrames(rewards.spellRewardPool, SkinItemButton)

    ColorQuestLogMoney()
    ColorRewardItems()
end

-- the items a quest still asks for, in their quality; immersive questing shows them itself
local function ColorProgressItems()
    if GW.settings.immersiveQuesting.enabled then return end
    for i = 1, MAX_REQUIRED_ITEMS do
        local item = _G["QuestProgressItem" .. i]
        ColorItemByQuality(item, _G["QuestProgressItem" .. i .. "Name"], item.type and GetQuestItemLink(item.type, item:GetID()))
    end
    ColorRequiredMoney(QuestProgressRequiredMoneyText, GetQuestMoneyToGet())
end

---------- the quest list ----------

-- headers show our arrows instead of blizzards plus and minus buttons
local function UpdateCollapseTexture(button, texture, skip)
    if skip or not texture then return end
    if texture == 130838 or type(texture) == "string" and (strfind(texture, "Plus") or strfind(texture, "Closed")) then
        button:SetNormalTexture(ARROW_RIGHT, true)
    elseif texture == 130821 or type(texture) == "string" and (strfind(texture, "Minus") or strfind(texture, "Open")) then
        button:SetNormalTexture(ARROW_DOWN, true)
    end
end

local function HookCollapseTexture(button)
    hooksecurefunc(button, "SetNormalTexture", UpdateCollapseTexture)
    local normal = button:GetNormalTexture()
    if normal then
        UpdateCollapseTexture(button, normal:GetTexture())
        normal:SetSize(16, 16)
    end
end
GW.HookClassicCollapseTexture = HookCollapseTexture

-- the rows look like the objectives tracker: zones as its headers, titles in its quest type colors and the level,
-- which blizzard only tells by the color, in front in the difficulty color
local TYPES = GW.Enum.ObjectivesNotificationType
-- a font per color: blizzard switches the row to its highlight font on hover and back to the normal one,
-- a text color set on the row would be gone after the first hover
local rowFonts = {}
local function GetRowFont(key, color, header)
    if not rowFonts[key] then
        local font = CreateFont("GW2QuestLogRowFont" .. key)
        font:CopyFontObject(GameFontNormal)
        if header then
            font:SetFont(DAMAGE_TEXT_FONT, select(2, GameFontNormal:GetFont()), "")
        end
        font:SetTextColor(color:GetRGB())
        rowFonts[key] = font
    end
    return rowFonts[key]
end

-- the type of a quest like the tracker tells it, and its level in the difficulty color
local function GetQuestTypeAndLevel(questIndex)
    local _, level, _, _, _, _, frequency, questID = GetQuestLogTitle(questIndex)
    local tagID = GW.GetQuestTagID(questID)
    local questType = GW.IsClassQuestLogIndex(questIndex) and TYPES.Campaign
        or tagID == Enum.QuestTag.PvP and TYPES.PvPQuest
        or GW.IsRepeatableQuestFrequency(frequency) and TYPES.DailyQuest or TYPES.Quest
    local color = GetQuestDifficultyColor(level)
    -- the level with the group and dungeon icon of the tracker
    return questType, CreateColor(color.r, color.g, color.b):WrapTextInColorCode(strtrim(GW.GetQuestLevelPrefix(level, tagID)))
end

-- the quest icon of the tracker for the type
local function GetTypeIcon(questType, size)
    local icon = GW.GetObjectivesTypeIcon and GW.GetObjectivesTypeIcon(questType)
    if not icon then return "" end
    local color = icon.tint and GW.Colors.ObjectivesTypeColors[questType] or GW.Colors.FallbackWhite
    return format("|TInterface/AddOns/GW2_UI/textures/icons/%s.png:%d:%d:0:0:256:512:%d:%d:%d:%d:%d:%d:%d|t ", icon.tex, size, size,
        icon.l * 256, icon.r * 256, icon.t * 512, icon.b * 512, color.r * 255, color.g * 255, color.b * 255)
end

-- once per row: the line under zones and the green tick of the tracker for watched quests
local function SkinRow(title)
    if title.gwSeparator then return end
    title.gwSeparator = title:CreateTexture(nil, "BACKGROUND")
    title.gwSeparator:SetColorTexture(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
    title.gwSeparator:SetHeight(1)
    title.gwSeparator:SetPoint("BOTTOMLEFT", 0, 0)
    title.gwSeparator:SetPoint("BOTTOMRIGHT", 0, 0)
    local check = _G[title:GetName() .. "Check"]
    check:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck.png")
    check:SetTexCoord(0, 1, 0.5, 0.75)
    check:SetVertexColor(GW.Colors.SkinColors.Positive:GetRGB())
    check:SetSize(12, 12)
    title:SetWidth(LIST_WIDTH)
    -- the hover of our lists
    GW.AddListItemChildHoverTexture(title)

    title.gwCompass = title:CreateTexture(nil, "BACKGROUND", nil, 2)
    title.gwCompass:SetTexture("Interface/AddOns/GW2_UI/textures/notification/compass-rad-bg.png")
    title.gwCompass:SetSize(22, 22)
    title.gwCompassArrow = title:CreateTexture(nil, "BACKGROUND", nil, 3)
    title.gwCompassArrow:SetTexture("Interface/AddOns/GW2_UI/textures/notification/compass-arrow.png")
    title.gwCompassArrow:SetTexCoord(1, 0, 0, 1)
    title.gwCompassArrow:SetAllPoints(title.gwCompass)

    -- blizzard turns the tag white on hover; the objectives in the tooltip, below the party info blizzard may show
    local tag = _G[title:GetName() .. "Tag"]
    title:HookScript("OnEnter", function(self)
        tag:SetTextColor(self.r, self.g, self.b)

        local questIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
        local questTitle, _, _, isHeader = GetQuestLogTitle(questIndex)
        local numObjectives = not isHeader and GetNumQuestLeaderBoards(questIndex) or 0
        if numObjectives == 0 then return end
        if GameTooltip:IsOwned(self) then
            GameTooltip:AddLine(" ")
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(questTitle, self.gwTypeColor:GetRGB())
        end
        for i = 1, numObjectives do
            local text, _, finished = GetQuestLogLeaderBoard(i, questIndex)
            if text then
                GameTooltip:AddLine(text, (finished and OBJECTIVE_DONE_COLOR or OBJECTIVE_OPEN_COLOR):GetRGB())
            end
        end
        GameTooltip:Show()
    end)
end


-- the number of quests of a zone; a collapsed zone lists none, it keeps the number from when it was open
local zoneQuestCounts = {}
local function GetZoneQuestCount(questIndex)
    local zone, _, _, _, isCollapsed = GetQuestLogTitle(questIndex)
    if not isCollapsed then
        local count, numEntries = 0, GetNumQuestLogEntries()
        while questIndex + count < numEntries and not select(4, GetQuestLogTitle(questIndex + count + 1)) do
            count = count + 1
        end
        zoneQuestCounts[zone] = count
    end
    return zoneQuestCounts[zone]
end

-- the quest the compass points to gets the compass look around its icon: the round background and the arrow,
-- pointing left like the compass in the tracker; a new compass quest updates the open log
local compassHooked
local function HookCompass()
    if compassHooked or not GwObjectivesNotification then return end
    compassHooked = true
    local lastQuestID
    hooksecurefunc(GwObjectivesNotification, "SetObjectiveNotification", function(self)
        if self.compassQuestID ~= lastQuestID then
            lastQuestID = self.compassQuestID
            if QuestLogFrame:IsShown() then
                QuestLog_Update()
            end
        end
    end)
end

local QUEST_TEXT_OFFSET = 4

local function StyleQuestRow(title, questIndex)
    SkinRow(title)
    local isHeader = select(4, GetQuestLogTitle(questIndex))
    title.gwSeparator:SetShown(isHeader)
    local tag = _G[title:GetName() .. "Tag"]
    -- zones keep their name behind the collapse arrow, quests start with their icon in that arrow column
    title:GetFontString():SetPoint("LEFT", title, "LEFT", isHeader and 20 or QUEST_TEXT_OFFSET, 0)
    if isHeader then
        title:SetNormalFontObject(GetRowFont("Header", HEADER_COLOR, true))
        title:SetHighlightFontObject(GetRowFont("Header", HEADER_COLOR, true))
        title.gwHoverTexture:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
        -- the count right aligned in the tag blizzard leaves empty on zones; leaving the row restores title.r/g/b to it
        title.r, title.g, title.b = GW.Colors.SkinColors.SubText:GetRGB()
        tag:SetText(GetZoneQuestCount(questIndex) or "")
        tag:SetTextColor(title.r, title.g, title.b)
        tag:SetPoint("RIGHT", title, "RIGHT", -4, 0)
        return
    end
    local questType, levelText = GetQuestTypeAndLevel(questIndex)
    local typeColor = GW.Colors.ObjectivesTypeColors[questType]
    title.gwTypeColor = typeColor
    -- hovered and selected rows keep their colors, the hover shows in the type color like in the tracker
    title:SetNormalFontObject(GetRowFont(questType, typeColor))
    title:SetHighlightFontObject(GetRowFont(questType, typeColor))
    title.gwHoverTexture:SetVertexColor(typeColor.r, typeColor.g, typeColor.b, GW.Colors.SkinColors.ListHover.a)

    -- (Complete) green, (Failed) red; dungeon, group and elite show in the level like in the tracker
    local isComplete = select(6, GetQuestLogTitle(questIndex))
    if isComplete then
        title.r, title.g, title.b = (isComplete > 0 and GW.Colors.SkinColors.Positive or GW.Colors.SkinColors.Negative):GetRGB()
    else
        tag:SetText("")
    end
    tag:SetTextColor(title.r, title.g, title.b)

    -- the title and its xp like the tracker shows it; questie may have written the level already, it is taken off
    local label = strtrim(title:GetText() or "")
    label = label:gsub("^%[[^%]]*%]%s*", "")
    local questID = select(8, GetQuestLogTitle(questIndex))
    local xp = GW.GetQuestRewardXP(questID)
    if xp then
        label = label .. " " .. GW.Colors.SkinColors.Disabled:WrapTextInColorCode("(" .. GW.CommaValue(xp) .. XP .. ")")
    end
    -- icon, level, title like the details
    local onCompass = GwObjectivesNotification and GwObjectivesNotification.compassQuestID == questID
    title:SetText(GetTypeIcon(questType, 14) .. levelText .. " " .. label)

    title.gwCompass:SetShown(onCompass)
    title.gwCompassArrow:SetShown(onCompass)
    if onCompass then
        title.gwCompass:ClearAllPoints()
        title.gwCompass:SetPoint("CENTER", title:GetFontString(), "LEFT", 7, 0)
    end

    -- the watched tick at the right end, a tag like (Complete) moves in front of it
    local check = _G[title:GetName() .. "Check"]
    check:ClearAllPoints()
    check:SetPoint("RIGHT", title, "RIGHT", -4, 0)
    tag:SetPoint("RIGHT", title, "RIGHT", check:IsShown() and -20 or -2, 0)

    -- blizzard caps the title near its old row width, it may use the row up to tag and tick
    local tagText = tag:GetText()
    local rightSpace = (check:IsShown() and 20 or 4) + (tagText and tagText ~= "" and tag:GetStringWidth() + 6 or 0)
    title:GetFontString():SetWidth(title:GetWidth() - QUEST_TEXT_OFFSET - rightSpace)
end

-- era and tbc have fixed rows, wrath and mists the buttons of their hybrid list
local skinnedTitles = {}
local function SkinTitleButtons()
    local buttons = QuestLogListScrollFrame.buttons
    if not buttons then
        -- the selected quest in our list color instead of blizzards difficulty colored glow
        QuestLogSkillHighlight:SetVertexColor(GW.Colors.SkinColors.ListSelected:GetRGBA())
        HookCompass()
        buttons = {}
        local offset = FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
        for i = 1, QUESTS_DISPLAYED do
            buttons[i] = _G["QuestLogTitle" .. i]
            if buttons[i]:IsShown() then
                StyleQuestRow(buttons[i], i + offset)
            end
        end
    end
    for _, title in ipairs(buttons) do
        if not skinnedTitles[title] then
            skinnedTitles[title] = true
            HookCollapseTexture(title)
            -- the fixed rows mark the hovered quest through QuestLogHighlightFrame, their own glow goes
            local highlight = not QuestLogListScrollFrame.buttons and title:GetName() and _G[title:GetName() .. "Highlight"]
            if highlight then
                highlight:SetAlpha(0)
            end
        end
    end
end

-- the details of era and tbc like the tracker: the title in the type color with the level in front, the objectives
-- with the progress bar of the tracker under counted ones
local BAR_HEIGHT = 10
local objectiveBars = {}
-- the bar of the tracker's objective row, background and border included; only the bar is used
local function GetObjectiveBar(index)
    if not objectiveBars[index] then
        local row = CreateFrame("Frame", nil, QuestLogObjective1:GetParent(), "GwQuesttrackerObjectiveTemplate")
        row.ObjectiveText:Hide()
        -- the tracker's width, its spark is placed for it
        row.StatusBar:SetSize(280, BAR_HEIGHT)
        -- the tracker's dark track vanishes on this background
        row.StatusBar.statusbarBg:SetColorTexture(GW.Colors.SkinColors.StatusBarTrack:GetRGBA())
        row.StatusBar.statusbarBg:Show()
        objectiveBars[index] = {StatusBar = row.StatusBar}
    end
    return objectiveBars[index]
end

-- the fonts of the tracker instead of blizzards big quest fonts
local function SetDetailFonts()
    QuestLogQuestTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    for _, name in ipairs({"QuestLogDescriptionTitle", "QuestLogRewardTitleText"}) do
        _G[name]:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    end
    for _, name in ipairs({"QuestLogObjectivesText", "QuestLogQuestDescription", "QuestLogItemChooseText", "QuestLogItemReceiveText",
        "QuestLogSpellLearnText", "QuestLogTimerText", "QuestLogRequiredMoneyText", "QuestLogSuggestedGroupNum"}) do
        if _G[name] then
            _G[name]:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
    end
    local i = 1
    while _G["QuestLogObjective" .. i] do
        _G["QuestLogObjective" .. i]:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        i = i + 1
    end
end

local function StyleQuestDetails()
    local questIndex = GetQuestLogSelection()
    if not questIndex or questIndex == 0 then return end
    local questType, levelText = GetQuestTypeAndLevel(questIndex)
    local typeColor = GW.Colors.ObjectivesTypeColors[questType]
    QuestLogQuestTitle:SetText(GetTypeIcon(questType, 16) .. levelText .. " " .. (QuestLogQuestTitle:GetText() or ""))
    QuestLogQuestTitle:SetTextColor(typeColor:GetRGB())

    -- the lines stay under each other at the left, a bar only adds its height to the gap
    local numObjectives = GetNumQuestLeaderBoards()
    local previous, previousBar
    for i = 1, numObjectives do
        local line = _G["QuestLogObjective" .. i]
        local text, _, finished = GetQuestLogLeaderBoard(i)
        line:SetTextColor((finished and GW.Colors.SkinColors.Disabled or TEXT_COLOR):GetRGB())
        -- finished ones are struck through like in the tracker
        if not line.gwStrike then
            line.gwStrike = line:GetParent():CreateTexture(nil, "OVERLAY")
            line.gwStrike:SetHeight(1)
            line.gwStrike:SetPoint("LEFT", line, "LEFT", 0, 0)
            local r, g, b = GW.Colors.SkinColors.Disabled:GetRGB()
            line.gwStrike:SetColorTexture(r, g, b, 0.7)
        end
        line.gwStrike:SetWidth(line:GetStringWidth())
        line.gwStrike:SetShown(finished)
        if previous then
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, previousBar and -(BAR_HEIGHT + 6) or -2)
        end
        local holder = GetObjectiveBar(i)
        local bar = holder.StatusBar
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 2, -4)
        bar:SetStatusBarColor(typeColor:GetRGB())
        -- the tracker's parser shows the bar when the progress bars setting is on
        if finished or not GW.ParseObjectiveString(holder, text or "") then
            bar:Hide()
        end
        previous, previousBar = line, bar:IsShown()
    end
    for i = numObjectives + 1, #objectiveBars do
        objectiveBars[i].StatusBar:Hide()
    end
    local i = numObjectives + 1
    while _G["QuestLogObjective" .. i] do
        if _G["QuestLogObjective" .. i].gwStrike then
            _G["QuestLogObjective" .. i].gwStrike:Hide()
        end
        i = i + 1
    end

    -- what blizzard hung under the last objective makes room for its bar, the description keeps some more distance
    for _, region in ipairs({QuestLogRequiredMoneyText, QuestLogSuggestedGroupNum, QuestLogDescriptionTitle}) do
        local point, relativeTo, relativePoint, x, y = region:GetPoint(1)
        local extra = (previousBar and relativeTo == previous and BAR_HEIGHT + 4 or 0) + (region == QuestLogDescriptionTitle and 6 or 0)
        if extra > 0 then
            region:SetPoint(point, relativeTo, relativePoint, x, y - extra)
        end
    end
end

-- blizzard sizes the highlight to its own list width, ours is narrower
local function KeepHighlightWidth(highlight, width)
    if width ~= LIST_WIDTH then
        highlight:SetWidth(LIST_WIDTH)
    end
end

---------- the frame ----------

local function SkinButtons()
    for _, name in ipairs({"QuestLogFrameAbandonButton", "QuestFramePushQuestButton", "QuestFrameExitButton", "QuestLogFrameTrackButton",
        "QuestLogFrameCancelButton"}) do
        local button = _G[name]
        if button then
            button:GwStripTextures()
            button:GwSkinButton(false, true)
        end
    end
    QuestLogFrameAbandonButton:GwSkinNegativeButton()

    for _, close in ipairs({QuestLogFrameCloseButton, QuestLogDetailFrameCloseButton or false}) do
        if close then
            close:GwSkinButton(true)
            close:SetSize(20, 20)
        end
    end
    QuestLogFrameCloseButton:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -5, -3)
end

-- the quest count: in our small frame above the list where the log has a frame for it,
-- else only moved there
local function SkinQuestCount(listBackground)
    if not QuestLogDetailFrame then
        -- era and tbc: plain grey text at the right end of the line above the list, under it the ticks of the rows;
        -- tbc has a frame around the count, era only the text
        local count = QuestLogCount or QuestLogQuestCount
        if QuestLogCount then
            QuestLogCount:GwStripTextures()
        end
        for _, text in ipairs({QuestLogQuestCount, QuestLogDailyQuestCount or false}) do
            if text then
                text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
                text:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
            end
        end
        hooksecurefunc("QuestLog_Update", function()
            count:ClearAllPoints()
            count:SetPoint("RIGHT", QuestLogFrame, "TOPLEFT", 19 + LIST_WIDTH + 4, -52)
        end)
    elseif QuestLogCount then
        QuestLogCount:GwStripTextures()
        QuestLogCount:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        QuestLogCount.backdrop:SetFrameLevel(QuestLogFrame:GetFrameLevel() + 1)
        QuestLogQuestCount:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.Enum.TextSizeType.Small)
        QuestLogQuestCount:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        if QuestLogDetailFrame then
            hooksecurefunc("QuestLogUpdateQuestCount", function()
                QuestLogCount:ClearAllPoints()
                QuestLogCount:SetPoint("BOTTOMLEFT", listBackground, "TOPLEFT", 0, 5)
            end)
        end
    else
        hooksecurefunc("QuestLog_Update", function()
            QuestLogQuestCount:ClearAllPoints()
            QuestLogQuestCount:SetPoint("BOTTOMLEFT", listBackground, "TOPLEFT", 0, 5)
        end)
    end
end

-- the layout of each kind of quest log; tbc has the wider detail pane
local function LayoutSplitLog()
    QuestFramePushQuestButton:ClearAllPoints()
    QuestFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", 1, 0)
    QuestFramePushQuestButton:SetPoint("RIGHT", QuestLogFrameTrackButton, "LEFT", -1, 0)
    QuestLogFrameCancelButton:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -25, 12)
    QuestLogDetailScrollFrame:SetWidth(LIST_WIDTH)
    QuestLogFrameAbandonButton:SetWidth(129)
    if QuestLogFrameShowMapButtonText then
        QuestLogFrameShowMapButtonText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    end

    -- the detail frame of its own in our window background
    local detail = QuestLogDetailFrame
    detail:GwStripTextures()
    if detail.NineSlice then
        detail.tex = detail:CreateTexture(nil, "BACKGROUND", nil, 0)
        detail.tex:SetPoint("TOPLEFT", detail.NineSlice, "TOPLEFT", -10, 20)
        detail.tex:SetPoint("BOTTOMRIGHT", detail.NineSlice, "BOTTOMRIGHT", 20, -20)
        detail.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    end
end

-- "track quest" of the row log: a radio art blizzard tints green while quests are watched,
-- our check box instead
local function SkinTrackToggle()
    if not QuestLogTrack or not QuestLogTrackTracking then return end

    for _, region in ipairs({QuestLogTrack:GetRegions()}) do
        if region:IsObjectType("Texture") then
            region:SetAlpha(0)
        end
    end
    local box = QuestLogTrack:CreateTexture(nil, "ARTWORK")
    box:SetSize(16, 16)
    box:SetPoint("LEFT", 2, 0)
    QuestLogTrackTitle:ClearAllPoints()
    QuestLogTrackTitle:SetPoint("LEFT", box, "RIGHT", 4, 0)
    QuestLogTrackTitle:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    QuestLogTrackTitle:SetTextColor(TEXT_COLOR:GetRGB())
    QuestLogTrack.gwBox = box

    local function UpdateBox(_, r, g)
        -- green while quests are watched, red otherwise
        box:SetTexture(g > 0.5 and r < 0.5 and CHECKBOX_CHECKED or CHECKBOX)
    end
    hooksecurefunc(QuestLogTrackTracking, "SetVertexColor", UpdateBox)
    UpdateBox(nil, QuestLogTrackTracking:GetVertexColor())
end

-- the thin track our classic scroll bars have between their arrows; stripping the frame took blizzards away
local function AddScrollTrack(scrollBar)
    local name = scrollBar:GetName()
    local track = scrollBar:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")
    track:SetWidth(3)
    track:SetPoint("TOP", _G[name .. "ScrollUpButton"], "BOTTOM", 0, -2)
    track:SetPoint("BOTTOM", _G[name .. "ScrollDownButton"], "TOP", 0, 2)
end

-- era and tbc: list and details are told apart by their backgrounds like the tracker, without frames
local function LayoutRowLog()
    local details = GW.CreateDetailsBackgroundTexture(QuestLogFrame, 6)
    details:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", 19, -75)
    details:SetPoint("BOTTOMRIGHT", QuestLogTitle6, "BOTTOMRIGHT", 2, -5)
    QuestLogDetailScrollFrame:SetSize(LIST_WIDTH, 300)
    QuestLogFrameAbandonButton:SetWidth(123)

    -- abandon, share and close in one row at the bottom
    local previous
    for _, button in ipairs({QuestLogFrameAbandonButton, QuestFramePushQuestButton, QuestFrameExitButton}) do
        button:ClearAllPoints()
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
        else
            button:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 20, 8)
        end
        previous = button
    end

    -- one line above the list: "all" over the collapse arrows of the zones, at the right end "watch quest" and the count
    if QuestLogCollapseAllButton then
        HookCollapseTexture(QuestLogCollapseAllButton)
        QuestLogCollapseAllButton:GwStripTextures()
        QuestLogCollapseAllButton:ClearAllPoints()
        QuestLogCollapseAllButton:SetPoint("LEFT", QuestLogFrame, "TOPLEFT", 19, -52)
        QuestLogCollapseAllButton:ClearHighlightTexture()
        local text = QuestLogCollapseAllButton:GetFontString()
        text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        text:GwLockTextColor(HEADER_COLOR:GetRGB())
    end
    SkinTrackToggle()
    local box = QuestLogTrack.gwBox
    box:SetSize(14, 14)
    QuestLogTrackTitle:ClearAllPoints()
    QuestLogTrackTitle:SetPoint("RIGHT", QuestLogCount or QuestLogQuestCount, "LEFT", -12, 0)
    box:ClearAllPoints()
    box:SetPoint("RIGHT", QuestLogTrackTitle, "LEFT", -4, 0)
    QuestLogTrack:ClearAllPoints()
    QuestLogTrack:SetPoint("CENTER", box, "CENTER", 0, 0)
    QuestLogTrack:SetSize(14, 14)
    -- the text is part of the click area of the box
    QuestLogTrack:SetHitRectInsets(0, -(QuestLogTrackTitle:GetStringWidth() + 4), 0, 0)

    AddScrollTrack(QuestLogDetailScrollFrameScrollBar)

    -- the details only show their scroll bar when the text is longer than the pane
    GW.HideScrollBarWhenUnneeded(QuestLogDetailScrollFrame)
end

-- the npc model beside the log in our frames, the name above it and the text in a slim scroll frame
local function SkinQuestModel()
    -- clients without the model scene only get our background behind the text
    if not QuestModelScene then
        local width, height = QuestNPCModelTextFrame:GetSize()
        QuestNPCModelTextFrame:GwStripTextures()
        QuestNPCModelTextFrame.tex = QuestNPCModelTextFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
        QuestNPCModelTextFrame.tex:SetPoint("TOP", QuestNPCModelTextFrame, "TOP", 0, 20)
        QuestNPCModelTextFrame.tex:SetSize(width + 30, height + 60)
        QuestNPCModelTextFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
        return
    end
    QuestModelScene:SetHeight(253)
    QuestModelScene:GwStripTextures()
    QuestModelScene:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    QuestNPCModelTextFrame:GwStripTextures()
    QuestNPCModelTextFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    QuestNPCModelTextFrame:SetPoint("BOTTOM", QuestModelScene, 0, -66)

    QuestNPCModelNameText:ClearAllPoints()
    QuestNPCModelNameText:SetPoint("TOP", QuestModelScene, 0, -10)
    QuestNPCModelNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "OUTLINE")
    QuestNPCModelNameText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    QuestNPCModelText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    QuestNPCModelText:SetJustifyH("CENTER")

    QuestNPCModelTextScrollFrame:ClearAllPoints()
    QuestNPCModelTextScrollFrame:SetPoint("TOPLEFT", QuestNPCModelTextFrame, 2, -2)
    QuestNPCModelTextScrollFrame:SetPoint("BOTTOMRIGHT", QuestNPCModelTextFrame, -10, 6)
    QuestNPCModelTextScrollChildFrame:GwSetInside(QuestNPCModelTextScrollFrame)
    GW.SkinSlimScrollFrame(QuestNPCModelTextScrollFrame)
end

local function MakeMovable(frame)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

local function LoadQuestLogFrameSkin()
    if not GW.settings.skins.questLog.enabled then return end
    local splitLog = QuestLogDetailFrame ~= nil

    for _, frame in ipairs({QuestLogFrame, EmptyQuestLogFrame or false, QuestLogListScrollFrame, QuestLogDetailScrollFrame, QuestLogQuestCount,
        QuestInfoItemHighlight or false, QuestDetailScrollChildFrame or false, QuestRewardScrollChildFrame or false}) do
        if frame then
            frame:GwStripTextures(true)
        end
    end
    for _, scrollFrame in ipairs({QuestLogListScrollFrame, QuestLogDetailScrollFrame}) do
        _G[scrollFrame:GetName() .. "ScrollBar"]:GwSkinScrollBar()
        scrollFrame:GwSkinScrollFrame()
    end

    GW.CreateFrameHeaderWithBody(QuestLogFrame, QuestLogTitleText:GetText(), "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png",
        {QuestLogListScrollFrame, QuestLogDetailScrollFrame}, splitLog and 2 or nil, nil, true)
    QuestLogTitleText:Hide()
    SkinButtons()

    if splitLog then
        LayoutSplitLog()
    else
        LayoutRowLog()
    end
    QuestLogListScrollFrame:SetWidth(LIST_WIDTH)
    -- the split log hangs its count above the details background of its list
    SkinQuestCount(QuestLogListScrollFrame.tex)
    SkinQuestModel()
    MakeMovable(QuestLogFrame)

    QuestLogHighlightFrame:SetWidth(LIST_WIDTH)
    hooksecurefunc(QuestLogHighlightFrame, "SetWidth", KeepHighlightWidth)
    if QuestLogListScrollFrame.buttons then
        QuestLogSkillHighlight:SetAlpha(0.35)
    else
        -- the fixed rows mark the selected quest with the selection of our lists, SkinTitleButtons colors it
        QuestLogSkillHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    end

    -- items: the fixed reward and requirement rows, the reward buttons blizzard creates later
    for prefix, count in pairs({QuestLogItem = MAX_NUM_ITEMS, QuestProgressItem = MAX_REQUIRED_ITEMS}) do
        for i = 1, count do
            SkinItemButton(_G[prefix .. i])
        end
    end
    hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
        SkinItemButton(rewardsFrame.RewardButtons[index])
    end)
    hooksecurefunc("QuestInfoItem_OnClick", MarkChosenReward)
    hooksecurefunc("QuestInfo_ShowRewards", ColorRewardItems)
    hooksecurefunc("QuestInfo_Display", ColorQuestInfoTexts)
    hooksecurefunc("QuestFrameProgressItems_Update", ColorProgressItems)
    hooksecurefunc("QuestLog_UpdateQuestDetails", ColorQuestLogMoney)
    if QuestFrameItems_Update then
        hooksecurefunc("QuestFrameItems_Update", ColorQuestLogTexts)
    end

    SkinTitleButtons()
    hooksecurefunc("QuestLog_Update", SkinTitleButtons)
    if not splitLog and QuestLogObjective1 then
        SetDetailFonts()
        hooksecurefunc("QuestLog_UpdateQuestDetails", StyleQuestDetails)
    end
end
GW.LoadQuestLogFrameSkin = LoadQuestLogFrameSkin
