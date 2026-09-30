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
local LIST_WIDTH = 303

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

-- an item row: the icon in our frame, the name plate art gone
local function SkinItemButton(item)
    if not item or item.backdrop then return end
    item:GwCreateBackdrop("Transparent", true, -1, -1)
    item:SetSize(143, 40)
    item:SetFrameLevel(item:GetFrameLevel() + 2)

    if item.Icon then
        item.Icon:SetSize(35, 35)
        item.Icon:SetDrawLayer("ARTWORK")
        item.Icon:SetPoint("TOPLEFT", 2, -2)
        GW.HandleIcon(item.Icon)
    end
    if item.IconBorder then
        GW.HandleIconBorder(item.IconBorder)
    end
    if item.Count then
        item.Count:SetDrawLayer("OVERLAY")
        item.Count:ClearAllPoints()
        item.Count:SetPoint("BOTTOMRIGHT", item.Icon, "BOTTOMRIGHT", 0, 0)
    end
    if item.Name then
        item.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    end
    for _, key in ipairs({"NameFrame", "IconOverlay", "CircleBackground", "CircleBackgroundGlow"}) do
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

-- name and frame in the quality color of the item, white for common and below
local function ColorItemByQuality(item, name, link)
    -- reward buttons blizzard has not created yet
    if not item or not name then return end
    SkinItemButton(item)
    local quality = link and select(3, GetItemInfo(link))
    local r, g, b = 1, 1, 1
    if quality and quality > 1 then
        r, g, b = GetItemQualityColor(quality)
    end
    name:SetTextColor(r, g, b)
    item.backdrop:SetBackdropBorderColor(r, g, b)
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
    chosen.backdrop:SetBackdropBorderColor(MONEY_OK_COLOR:GetRGB())
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

-- era and tbc have fixed rows, wrath and mists the buttons of their hybrid list
local skinnedTitles = {}
local function SkinTitleButtons()
    local buttons = QuestLogListScrollFrame.buttons
    if not buttons then
        buttons = {}
        for i = 1, QUESTS_DISPLAYED do
            buttons[i] = _G["QuestLogTitle" .. i]
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
    if QuestLogCount then
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

local function LayoutRowLog()
    QuestLogListScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.OnlyBorder, true, 2, 2)
    QuestLogDetailScrollFrame:GwCreateBackdrop(GW.BackdropTemplates.OnlyBorder, true, 2, 4)
    if GW.TBC then
        local details = GW.CreateDetailsBackgroundTexture(QuestLogFrame, 6)
        details:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", 19, -75)
        details:SetPoint("BOTTOMRIGHT", QuestLogTitle6, "BOTTOMRIGHT", 19, -5)
        QuestLogDetailScrollFrame:SetSize(335, 300)
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
    else
        QuestLogDetailScrollFrame:SetWidth(LIST_WIDTH)
        QuestLogFrameAbandonButton:SetWidth(129)
    end

    if QuestLogCollapseAllButton then
        HookCollapseTexture(QuestLogCollapseAllButton)
        QuestLogCollapseAllButton:GwStripTextures()
        QuestLogCollapseAllButton:SetPoint("TOPLEFT", -45, 7)
        QuestLogCollapseAllButton:ClearHighlightTexture()
    end
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
    -- the split log keeps its list on our details background, the row log in a frame
    SkinQuestCount(splitLog and QuestLogListScrollFrame.tex or QuestLogListScrollFrame.backdrop)
    SkinQuestModel()
    MakeMovable(QuestLogFrame)

    QuestLogHighlightFrame:SetWidth(LIST_WIDTH)
    hooksecurefunc(QuestLogHighlightFrame, "SetWidth", KeepHighlightWidth)
    QuestLogSkillHighlight:SetAlpha(0.35)

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
end
GW.LoadQuestLogFrameSkin = LoadQuestLogFrameSkin
