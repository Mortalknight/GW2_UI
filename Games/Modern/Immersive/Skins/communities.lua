---@class GW2
local GW = select(2, ...)

-- Guild/communities window: our chrome, blizzards right hand tabs move onto our side panel,
-- the community list, the roster and the chat get our backgrounds and scroll bars.

local TAB_SETUP = {
    {key = "ChatTab", icon = "social/tabicon_chat"},
    {key = "RosterTab", icon = "social/tabicon_friends"},
    {key = "GuildBenefitsTab", icon = "character/tabicon_legacy_rewards"},
    {key = "GuildInfoTab", icon = "uistuff/tabicon_guild"},
    {key = "GuildPreferredPlaySettingsTab", icon = "uistuff/tabicon_settings"}
}

local TAB_ICON_PATH = "Interface/AddOns/GW2_UI/textures/%s.png"
local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png"
-- blizzards list starts 9 into our header, the first entry sits just below it
local LIST_TOP_PADDING = 11
local LIST_BOTTOM_OFFSET = 6
local BLIZZARD_LIST_PADDING = 40
local MEMBER_DROPDOWN_WIDTH = 150
local MEMBER_DROPDOWN_HEIGHT = 18
local MEMBER_DROPDOWN_TOP = 35
local CALENDAR_BUTTON_TOP = 36
local NEWS_FILTERS_WIDTH = 320
local MEMBER_DETAIL_TOP = 76
local MEMBER_DETAIL_BUTTON_GAP = 2
local TICKET_MANAGER_AVATAR_TOP = 42

local function UpdateTabIcon(tab)
    if tab:GetChecked() then
        tab.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        tab.icon:SetTexCoord(0.51, 1, 0, 0.625)
    end
end

local function LayoutTabs()
    local shown = 0

    for _, info in ipairs(TAB_SETUP) do
        -- GuildPreferredPlaySettingsTab is forever only
        local tab = CommunitiesFrame[info.key]
        if tab then
            if not tab.gwSkinned then
                GW.SkinSideTabButton(tab, TAB_ICON_PATH:format(info.icon), tab.tooltip)
                tab.Icon:Hide()
                hooksecurefunc(tab, "SetChecked", UpdateTabIcon)
            end

            -- anchored only, their click calls self:GetParent():SetDisplayMode()
            UpdateTabIcon(tab)
            tab:SetSize(64, 40)
            tab:ClearAllPoints()
            tab:SetPoint("TOPRIGHT", CommunitiesFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * shown))

            if tab:IsShown() then
                shown = shown + 1
            end
        end
    end
end

local function SkinInset(inset)
    inset:GwStripTextures()
    if inset.Bg then inset.Bg:Hide() end
    if inset.NineSlice then inset.NineSlice:Hide() end
end

local function SkinScroll(frame)
    GW.HandleTrimScrollBar(frame.ScrollBar)
    GW.HandleScrollControls(frame)
    frame.ScrollBar:SetHideIfUnscrollable(true)
end

-- blizzard re-textures the entries in every initialization
local function SkinListEntry(entry)
    -- blizzards plates are 80 high on a 68 high row (their art had transparent padding), ours would overlap
    entry.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    entry.Background:SetTexCoord(0, 1, 0, 1)
    entry.Background:SetAllPoints(entry)
    entry.Selection:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    entry.Selection:SetTexCoord(0, 1, 0, 1)
    entry.Selection:SetAllPoints(entry)
    entry.Selection:SetVertexColor(0.8, 0.8, 0.8, 1)
    entry.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    -- only real communities carry the ringed avatar; invitations and the join / finder entries keep blizzards look
    local isCommunity = entry.IconRing:IsShown()
    if isCommunity then
        entry.Name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        entry.IconRing:Hide()
        entry.CircleMask:Hide()
        if not entry.Icon.backdrop then
            -- a border only, lifted above the row: the row background would cover a backdrop behind it
            GW.HandleIcon(entry.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
            entry.Icon.backdrop:SetFrameLevel(entry:GetFrameLevel() + 2)
            entry.Icon.backdrop:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
        end
        entry.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    if entry.Icon.backdrop then
        entry.Icon.backdrop:SetShown(isCommunity)
    end

    -- the hover plate is an unnamed HighlightTexture on the button, drawn additive over blizzards blue art
    local highlight = entry:GetHighlightTexture()
    highlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    highlight:SetTexCoord(0, 1, 0, 1)
    highlight:SetBlendMode("BLEND")
    highlight:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    highlight:ClearAllPoints()
    highlight:SetAllPoints(entry.Background)

    entry.NewCommunityFlash:SetAlpha(0)
end

local function SkinCommunitiesList(list)
    list:GwStripTextures()
    list.FilligreeOverlay:Hide()

    GW.AddDetailsBackground(list)
    SkinScroll(list)

    -- only the bottom moves (blizzard keeps 29 free there), half the window hangs off the list top
    list:SetPoint("BOTTOMRIGHT", CommunitiesFrame, "BOTTOMLEFT", 170, LIST_BOTTOM_OFFSET)

    -- writing the views 40 padding taints the list (SetAvatarTexture is protected), so the box moves up inside the
    -- clipping list instead; clipping on the parents level draws nothing, and the scroll bar must not be clipped
    list:SetUsingParentLevel(false)
    list:SetFrameLevel(CommunitiesFrame:GetFrameLevel() + 1)
    list:SetClipsChildren(true)
    list.ScrollBox:ClearAllPoints()
    list.ScrollBox:SetPoint("TOPLEFT", list, "TOPLEFT", 0, BLIZZARD_LIST_PADDING - LIST_TOP_PADDING)
    list.ScrollBox:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT")
    list.ScrollBar:SetParent(CommunitiesFrame)
    list.ScrollBar:SetFrameLevel(list:GetFrameLevel() + 1)
    list.ScrollBar:ClearAllPoints()
    list.ScrollBar:SetPoint("TOPLEFT", list, "TOPRIGHT", 6, -LIST_TOP_PADDING)
    list.ScrollBar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 6, 2)

    -- the registry hands the owner in first, the existing frames come without it
    ScrollUtil.AddInitializedFrameCallback(list.ScrollBox, function(_, entry)
        SkinListEntry(entry)
    end, list)
    list.ScrollBox:ForEachFrame(SkinListEntry)
end

-- the window hosts a dozen sub panels, most of them wrapped in blizzards inset art: take that art off
-- everywhere instead of listing frames that only exist in some states (no guild, club finder, dialogs)
local function StripInsetsRecursive(frame, depth)
    for _, child in ipairs({frame:GetChildren()}) do
        if child.InsetFrame then
            SkinInset(child.InsetFrame)
        end
        if child.Inset then
            SkinInset(child.Inset)
        end
        if child.NineSlice then
            child.NineSlice:Hide()
        end

        if depth > 1 then
            StripInsetsRecursive(child, depth - 1)
        end
    end
end

local DETAILS_OFFSET = 6

local function SkinCheckbox(checkbox)
    checkbox:GwSkinCheckButton(false, 15)
    checkbox.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    checkbox.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    checkbox.Text:ClearAllPoints()
    checkbox.Text:SetPoint("LEFT", checkbox, "RIGHT", 6, 0)
end

-- blizzards class sheet becomes our flat class icons, in the member list and the applicant list
local function SetFlatClassIcon(texture, classID)
    local classInfo = classID and C_CreatureInfo.GetClassInfo(classID)
    if classInfo then
        texture:SetTexture("Interface/AddOns/GW2_UI/Textures/classicons/" .. strlower(classInfo.classFile) .. "_flat.png")
        texture:SetTexCoord(0, 1, 0, 1)
    end
end

local function SetMemberClassIcon(entry)
    SetFlatClassIcon(entry.Class, entry.memberInfo and entry.memberInfo.classID)
end

local function SkinMemberEntry(entry)
    if entry.gwSkinned then return end
    entry.gwSkinned = true
    GW.AddListItemChildHoverTexture(entry)

    -- blizzard only ever sets the tex coords of its class sheet, and does that in here
    hooksecurefunc(entry, "RefreshExpandedColumns", SetMemberClassIcon)
    SetMemberClassIcon(entry)
end

local function SkinColumnHeaders(columnDisplay)
    for header in columnDisplay.columnHeaders:EnumerateActive() do
        GW.HandleScrollFrameHeaderButton(header)

        local text = header:GetFontString()
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        header:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.08)
    end
end

-- the header buttons come from a pool that LayoutColumns refills
local function SkinColumnDisplay(columnDisplay)
    columnDisplay:GwStripTextures()
    hooksecurefunc(columnDisplay, "LayoutColumns", SkinColumnHeaders)
    SkinColumnHeaders(columnDisplay)
end

local function SkinMemberList(memberList)
    SkinInset(memberList.InsetFrame)
    GW.AddDetailsBackground(memberList.ScrollBox, -DETAILS_OFFSET, DETAILS_OFFSET)
    SkinScroll(memberList)

    memberList.MemberCount:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    memberList.MemberCount:SetTextColor(1, 1, 1)
    -- blizzard puts the member list 6 above the chat, the stream dropdown row sits on the chat top
    memberList.MemberCount:ClearAllPoints()
    memberList.MemberCount:SetPoint("LEFT", memberList, "TOPLEFT", 4, 14)

    SkinCheckbox(memberList.ShowOfflineButton)
    -- the row above the column headers is tight, the normal checkbox touches them
    memberList.ShowOfflineButton:SetSize(13, 13)
    memberList.ShowOfflineButton:SetPoint("BOTTOMLEFT", memberList, "TOPLEFT", 0, 31)
    memberList.ShowOfflineButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

    SkinColumnDisplay(memberList.ColumnDisplay)

    ScrollUtil.AddInitializedFrameCallback(memberList.ScrollBox, function(_, entry)
        SkinMemberEntry(entry)
    end, memberList)
    memberList.ScrollBox:ForEachFrame(SkinMemberEntry)
end

local function SkinChat(chat)
    SkinInset(chat.InsetFrame)
    GW.AddDetailsBackground(chat, -DETAILS_OFFSET, DETAILS_OFFSET)
    SkinScroll(chat)

    CommunitiesFrame.StreamDropdown:ClearAllPoints()
    CommunitiesFrame.StreamDropdown:SetPoint("BOTTOMLEFT", chat, "TOPLEFT", -DETAILS_OFFSET - 3, DETAILS_OFFSET + 2)

    local addToChat = CommunitiesFrame.AddToChatButton
    GW.SkinArrowDropdown(addToChat)
    addToChat.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    addToChat.Label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    CommunitiesFrame.ChatEditBox:GwStripTextures()
    CommunitiesFrame.ChatEditBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
end

local SECTION_HEADER = "Interface/AddOns/GW2_UI/textures/bag/bag-sep.png"
local ROW_BACKGROUND = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local ROW_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"

local function SetLightHeader(fontString)
    fontString:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

local function SkinPanelTitle(title)
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    SetLightHeader(title)
end

local function SetSectionHeader(texture)
    texture:SetTexture(SECTION_HEADER)
    texture:SetTexCoord(0, 1, 0, 1)
end

-- a border only, lifted above the row: the row background would cover a backdrop behind it
local function SkinRowIcon(icon)
    GW.HandleIcon(icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
    icon.backdrop:SetFrameLevel(icon:GetParent():GetFrameLevel() + 2)
    icon.backdrop:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
end

-- perks draw their plate from four unnamed guild frame textures, the icon is the only region worth keeping
local function SkinPerkButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    for _, region in ipairs({button:GetRegions()}) do
        if region:IsObjectType("Texture") and region ~= button.Icon then
            region:SetTexture(nil)
        end
    end
    button.NormalBorder:GwStripTextures()
    button.DisabledBorder:GwStripTextures()

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", button.Icon, "TOPRIGHT", 0, 0)
    background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 2)
    background:SetTexture(ROW_BACKGROUND)
    SkinRowIcon(button.Icon)
end

-- locked rewards keep blizzards grey name
local function ApplyRewardQuality(button, quality)
    local color = GW.GetQualityColor(quality)
    button.Icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
    button.Name:SetTextColor(color.r, color.g, color.b)
end

-- blizzard sets the name font object in every initialization, and uncached rewards have no quality yet
local function SkinRewardButton(button)
    if not button.gwSkinned then
        button.gwSkinned = true
        button:SetNormalTexture(ROW_BACKGROUND)
        button:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        button:SetHighlightTexture(ROW_HOVER)
        button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        button:GetHighlightTexture():SetBlendMode("BLEND")
        SkinRowIcon(button.Icon)
    end

    local itemID = button.itemID
    local quality = C_Item.GetItemQualityByID(itemID)
    if quality then
        ApplyRewardQuality(button, quality)
    else
        Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
            local loadedQuality = C_Item.GetItemQualityByID(itemID)
            if button.itemID == itemID and loadedQuality then
                ApplyRewardQuality(button, loadedQuality)
            end
        end)
    end
end

-- blizzard colours the date rows gold in every initialization
local function SkinNewsButton(button)
    if not button.gwSkinned then
        button.gwSkinned = true
        SetSectionHeader(button.header)
        button:SetHighlightTexture(ROW_HOVER)
        button:GetHighlightTexture():SetBlendMode("BLEND")
    end
    if button.header:IsShown() then
        SetLightHeader(button.text)
    end
end

local function SkinScrollBoxButtons(frame, skinFunc)
    ScrollUtil.AddInitializedFrameCallback(frame.ScrollBox, function(_, button)
        skinFunc(button)
    end, frame)
    frame.ScrollBox:ForEachFrame(skinFunc)
end

-- the frame is 20 high around the 14 high bar (filled from 1 in to 2 short of the right edge), the holder stays behind it
local function SkinFactionBar(bar)
    for _, key in ipairs({"Left", "Right", "Middle", "Shadow", "BG"}) do
        bar[key]:SetAlpha(0)
    end
    bar.Progress:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

    local holder = CreateFrame("Frame", nil, bar)
    holder:SetPoint("TOPLEFT", bar.Progress, "TOPLEFT")
    holder:SetPoint("BOTTOMRIGHT", bar.BG, "BOTTOMRIGHT", -2, 0)
    holder:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
    GW.AddStatusBarFrame(holder)
end

-- same look as the achievement status of our collection skin
local function SkinAchievementPointDisplay(display)
    display.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/achievementmicrobutton-up.png")
    display.Icon:SetTexCoord(0, 1, 0, 1)
    display.Icon:SetSize(18, 18)
    display.SumText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    display.SumText:SetTextColor(1, 1, 1)
    display.Highlight:SetAlpha(0)
end

local function SkinGuildInfo(info)
    info:GwStripTextures()
    GW.AddDetailsBackground(info)

    -- the section headers keep their place, only their art changes; the third one is known by its name alone
    SetSectionHeader(info.Header1)
    SetSectionHeader(info.Header2)
    SetSectionHeader(_G[info:GetName() .. "Header3"])
    for _, region in ipairs({info:GetRegions()}) do
        if region:IsObjectType("FontString") then
            SetLightHeader(region)
        end
    end

    SkinPanelTitle(info.TitleText)

    for index, challenge in ipairs(info.Challenges) do
        challenge.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        challenge.count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        challenge.count:SetTextColor(1, 1, 1)
        if index % 2 == 1 then
            local zebra = challenge:CreateTexture(nil, "BACKGROUND")
            zebra:SetAllPoints(challenge)
            zebra:SetTexture(ROW_BACKGROUND)
        end
    end

    SkinScroll(info.MOTDScrollFrame)
    SkinScroll(info.DetailsFrame)
end

-- the art only fades out, the name and the text frame below the model are anchored to it
local function SkinBossModel(model)
    model:GwStripTextures(nil, true)
    model.TextFrame:GwStripTextures(nil, true)
    model:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    model.backdrop:ClearAllPoints()
    model.backdrop:SetPoint("TOPLEFT", model, "TOPLEFT", -2, 2)
    model.backdrop:SetPoint("BOTTOMRIGHT", model.TextFrame, "BOTTOMRIGHT", 2, -2)

    model.BossName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    SetLightHeader(model.BossName)
    model.TextFrame.BossLocationText:SetTextColor(1, 1, 1)
end

local function SkinGuildNews(news)
    news:GwStripTextures()
    GW.AddDetailsBackground(news)
    SetSectionHeader(news.Header)
    for _, region in ipairs({news:GetRegions()}) do
        if region:IsObjectType("FontString") and region ~= news.NoNews then
            SetLightHeader(region)
        end
    end
    SkinPanelTitle(news.TitleText)
    SkinScroll(news)
    SkinScrollBoxButtons(news, SkinNewsButton)
    SkinBossModel(news.BossModel)
end

local function SkinGuildPanels()
    local details = CommunitiesFrame.GuildDetailsFrame
    details:GwStripTextures()
    SkinGuildInfo(details.Info)
    SkinGuildNews(details.News)

    local benefits = CommunitiesFrame.GuildBenefitsFrame
    benefits:GwStripTextures()
    for _, list in ipairs({benefits.Perks, benefits.Rewards}) do
        list:GwStripTextures()
        GW.AddDetailsBackground(list)
        SkinPanelTitle(list.TitleText)
        SkinScroll(list)
    end
    SkinScrollBoxButtons(benefits.Perks, SkinPerkButton)
    SkinScrollBoxButtons(benefits.Rewards, SkinRewardButton)

    SetLightHeader(benefits.FactionFrame.Label)
    SkinFactionBar(benefits.FactionFrame.Bar)
    SkinAchievementPointDisplay(benefits.GuildAchievementPointDisplay)
    GW.SkinHelpIconButton(benefits.GuildRewardsTutorialButton, 20)
end

local function SkinButtons()
    local buttons = {
        CommunitiesFrame.InviteButton,
        CommunitiesFrame.GuildLogButton,
        CommunitiesFrame.CommunitiesControlFrame.GuildControlButton,
        CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton,
        CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton,
    }

    for _, button in ipairs(buttons) do
        button:GwSkinButton(false, true)
    end

    -- blizzard puts it 20 right of the list, where our list scroll bar now sits
    CommunitiesFrame.GuildLogButton:SetPoint("BOTTOMLEFT", CommunitiesFrame, "BOTTOMLEFT", 204, 5)

    -- our windows do not minimize, and blizzards button sits right next to the close button as a second X
    CommunitiesFrame.MaximizeMinimizeFrame:Hide()

    for _, key in ipairs({"StreamDropdown", "GuildMemberListDropdown", "CommunityMemberListDropdown", "CommunitiesListDropdown"}) do
        local dropdown = CommunitiesFrame[key]
        dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
    end

    -- the roster column dropdowns sit 27 below the frame top, which is inside our header
    for _, dropdown in ipairs({CommunitiesFrame.GuildMemberListDropdown, CommunitiesFrame.CommunityMemberListDropdown}) do
        dropdown:SetSize(MEMBER_DROPDOWN_WIDTH, MEMBER_DROPDOWN_HEIGHT)
        dropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        dropdown:ClearAllPoints()
        dropdown:SetPoint("TOPRIGHT", CommunitiesFrame, "TOPRIGHT", -10, -MEMBER_DROPDOWN_TOP)
    end

    -- blizzard parks it 26 below the frame top, inside our header; ours lines up with the online count
    local calendarButton = CommunitiesFrame.CommunitiesCalendarButton
    calendarButton:SetSize(26, 26)
    calendarButton:ClearAllPoints()
    calendarButton:SetPoint("TOPRIGHT", CommunitiesFrame, "TOPRIGHT", -8, -CALENDAR_BUTTON_TOP)
    calendarButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/calendar.png")
    calendarButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/calendar.png")
    calendarButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/calendar.png")
    for _, texture in ipairs({calendarButton:GetNormalTexture(), calendarButton:GetPushedTexture(), calendarButton:GetHighlightTexture()}) do
        texture:SetTexCoord(0, 1, 0, 1)
    end
    calendarButton:GetHighlightTexture():SetBlendMode("ADD")
    calendarButton:GetHighlightTexture():SetAlpha(0.3)
end

local function AvatarSelected_OnShown(selected, shown)
    local border = selected:GetParent().Icon.backdrop
    if shown then
        border:SetBackdropBorderColor(1, 0.82, 0.1, 1)
    else
        border:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
    end
end

local function SkinAvatarButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
    button.Selected:SetAlpha(0)
    hooksecurefunc(button.Selected, "SetShown", AvatarSelected_OnShown)
    AvatarSelected_OnShown(button.Selected, button.Selected:IsShown())

    local highlight = button:GetHighlightTexture()
    highlight:SetColorTexture(1, 1, 1, 0.15)
    highlight:SetAllPoints(button.Icon)
end

-- CommunitiesAddDialog and CommunitiesCreateDialog live in blizzards secure environment and are out of our reach
local function SkinAvatarPicker()
    local picker = CommunitiesAvatarPickerDialog
    if picker.gwSkinned then return end
    picker.gwSkinned = true

    picker:GwStripTextures()
    picker.Selector:GwStripTextures()

    local title
    for _, region in ipairs({picker:GetRegions()}) do
        if region:GetObjectType() == "FontString" then
            title = region
            break
        end
    end

    GW.SkinSmallWindow(picker, title, WINDOW_ICON)
    GW.AddDetailsBackground(picker.ScrollBox)

    picker.Selector.OkayButton:GwSkinButton(false, true)
    picker.Selector.CancelButton:GwSkinButton(false, true)

    GW.HandleTrimScrollBar(picker.ScrollBar)
    GW.HandleScrollControls(picker)

    ScrollUtil.AddInitializedFrameCallback(picker.ScrollBox, function(_, button)
        SkinAvatarButton(button)
    end, picker)
    picker.ScrollBox:ForEachFrame(SkinAvatarButton)
end

local function SkinNotificationStreamEntry(entry)
    if entry.gwSkinned then return end
    entry.gwSkinned = true

    entry.StreamName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    entry.StreamName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    entry.Separator:SetColorTexture(1, 1, 1, 0.1)
    entry.HideNotificationsButton:GwSkinCheckButton(true, 15)
    entry.ShowNotificationsButton:GwSkinCheckButton(true, 15)
end

local function SkinNotificationStreamEntries(dialog)
    for entry in dialog.buttonPool:EnumerateActive() do
        SkinNotificationStreamEntry(entry)
    end
end

local function SkinNotificationSettingsDialog(dialog)
    dialog.BG:Hide()
    dialog.Selector:GwStripTextures()

    GW.SkinSmallWindow(dialog, dialog.TitleLabel, WINDOW_ICON)

    dialog.Selector.OkayButton:GwSkinButton(false, true)
    dialog.Selector.CancelButton:GwSkinButton(false, true)
    local scrollFrame = dialog.ScrollFrame
    local dropdown = dialog.CommunitiesListDropdown
    dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
    dropdown:ClearAllPoints()
    dropdown:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 2, DETAILS_OFFSET + 4)

    GW.AddDetailsBackground(scrollFrame, -DETAILS_OFFSET, DETAILS_OFFSET)
    SkinScroll(scrollFrame)

    local child = scrollFrame.Child
    child.SettingsLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    child.Separator:SetColorTexture(1, 1, 1, 0.1)
    SkinCheckbox(child.QuickJoinButton)
    child.AllButton:GwSkinButton(false, true)
    child.NoneButton:GwSkinButton(false, true)

    hooksecurefunc(dialog, "Refresh", SkinNotificationStreamEntries)
end

local INPUT_SCROLL_CORNERS = {"TopLeftTex", "TopRightTex", "BottomLeftTex", "BottomRightTex"}
local TEXTBOX_PADDING = 6

-- blizzards box art hangs 5 out to the left of the text, ours starts at the text, so the text needs the room
local function SkinInputBox(editBox)
    GW.SkinTextBox(editBox.Middle, editBox.Left, editBox.Right)
    editBox:SetTextInsets(TEXTBOX_PADDING, TEXTBOX_PADDING, 0, 0)
end

local function SkinInputScrollText(scroll)
    SkinScroll(scroll)
    local editBox = scroll.EditBox
    editBox:SetTextInsets(TEXTBOX_PADDING, TEXTBOX_PADDING, 4, 4)
    editBox.Instructions:ClearAllPoints()
    editBox.Instructions:SetPoint("TOPLEFT", editBox, "TOPLEFT", TEXTBOX_PADDING, -4)
end

local function SkinInputScroll(scroll)
    for _, key in ipairs(INPUT_SCROLL_CORNERS) do
        scroll[key]:Hide()
    end
    GW.SkinTextBox(scroll.MiddleTex, scroll.LeftTex, scroll.RightTex, scroll.TopTex, scroll.BottomTex)
    SkinInputScrollText(scroll)
end

-- the club finder message boxes: a bordered frame around an input scroll frame that keeps its own border art too
local MESSAGE_FRAME_CORNERS = {"TopLeft", "TopRight", "BottomLeft", "BottomRight"}
local INPUT_SCROLL_ART = {"TopLeftTex", "TopRightTex", "TopTex", "BottomLeftTex", "BottomRightTex", "BottomTex", "LeftTex", "RightTex", "MiddleTex"}
local function SkinMessageFrame(frame, scroll)
    for _, key in ipairs(MESSAGE_FRAME_CORNERS) do
        frame[key]:Hide()
    end
    GW.SkinTextBox(frame.Middle, frame.Left, frame.Right, frame.Top, frame.Bottom)

    for _, key in ipairs(INPUT_SCROLL_ART) do
        scroll[key]:Hide()
    end
    SkinInputScrollText(scroll)
end

local function SkinDialogLabels(labels)
    for _, label in ipairs(labels) do
        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
end

local function SkinEditStreamDialog(dialog)
    dialog.BG:Hide()

    GW.SkinSmallWindow(dialog, dialog.TitleLabel, WINDOW_ICON)

    SkinDialogLabels({dialog.NameLabel, dialog.DescriptionLabel, dialog.TypeLabel})
    SkinInputBox(dialog.NameEdit)
    SkinInputScroll(dialog.Description)

    dialog.TypeCheckbox:GwSkinCheckButton(false, 15)
    dialog.TypeCheckbox:ClearAllPoints()
    dialog.TypeCheckbox:SetPoint("RIGHT", dialog.TypeLabel, "LEFT", -6, 0)

    dialog.Accept:GwSkinButton(false, true)
    dialog.Delete:GwSkinButton(false, true)
    dialog.Cancel:GwSkinButton(false, true)
end

-- the log and the text edit window name their X and their close button both $parentCloseButton, the global keeps the X
local function GetCloseButtons(frame)
    local titleBarButton, closeButton
    local name = frame:GetName() .. "CloseButton"
    for _, child in ipairs({frame:GetChildren()}) do
        if child:GetName() == name then
            if (child:GetText() or "") == "" then
                titleBarButton = child
            else
                closeButton = child
            end
        end
    end
    return titleBarButton, closeButton
end

-- the small guild windows (log, news filters, text edit) share blizzards translucent frame
local function SkinGuildDialog(frame, title, closeButton, buttons)
    frame:GwStripTextures()
    GW.SkinSmallWindow(frame, title, WINDOW_ICON, closeButton)

    for _, button in ipairs(buttons or {}) do
        button:GwSkinButton(false, true)
    end

    local container = frame.Container
    if container then
        container.NineSlice:Hide()
        GW.AddDetailsBackground(container)
        SkinScroll(container.ScrollFrame)
    end
end

-- only the art shrinks, the rows are chained to each other and would collapse with a smaller button
local function SkinNewsFilterCheckbox(checkbox)
    checkbox:GwSkinCheckButton(false, 15, true)
    checkbox.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    checkbox.Text:SetTextColor(1, 1, 1)
end

local function SkinGuildDialogs()
    local logTitleBarButton, logCloseButton = GetCloseButtons(CommunitiesGuildLogFrame)
    SkinGuildDialog(CommunitiesGuildLogFrame, CommunitiesGuildLogFrameTitle, logTitleBarButton, {logCloseButton})

    local editTitleBarButton, editCloseButton = GetCloseButtons(CommunitiesGuildTextEditFrame)
    SkinGuildDialog(CommunitiesGuildTextEditFrame, CommunitiesGuildTextEditFrame.Title, editTitleBarButton,
        {CommunitiesGuildTextEditFrameAcceptButton, editCloseButton})

    -- blizzards 264 are too narrow for the title in our header font
    local filters = CommunitiesGuildNewsFiltersFrame
    filters:SetWidth(NEWS_FILTERS_WIDTH)
    SkinGuildDialog(filters, filters.Title, filters.CloseButton)
    for _, checkbox in ipairs(filters.GuildNewsFilterButtons) do
        SkinNewsFilterCheckbox(checkbox)
    end
end

-- blizzards class colors like the names in the member list, ours are bar colors and too dark for text
local function ColorMemberDetailName(detail, _, memberInfo)
    local classInfo = memberInfo and memberInfo.classID and C_CreatureInfo.GetClassInfo(memberInfo.classID)
    if classInfo then
        detail.Name:SetTextColor(GW.GWGetClassColor(classInfo.classFile, true, true):GetRGB())
    else
        SetLightHeader(detail.Name)
    end
end

-- 212 wide and sized from the name on every display, too small for our header
local function SkinGuildMemberDetail(detail)
    detail.Border:Hide()
    detail:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    detail:ClearAllPoints()
    detail:SetPoint("TOPLEFT", CommunitiesFrame, "TOPRIGHT", 4, -MEMBER_DETAIL_TOP)

    detail.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    hooksecurefunc(detail, "DisplayMember", ColorMemberDetailName)
    for _, label in ipairs({detail.ZoneLabel, detail.RankLabel, detail.OnlineLabel, detail.NoteLabel, detail.OfficerNoteLabel}) do
        SetLightHeader(label)
    end

    for _, background in ipairs({detail.NoteBackground, detail.OfficerNoteBackground}) do
        background.NineSlice:Hide()
        GW.SkinTextBox(nil, nil, nil, nil, nil, 0, 0, false, background)
    end

    detail.CloseButton:GwSkinButton(true)
    detail.CloseButton:SetSize(20, 20)
    detail.CloseButton:ClearAllPoints()
    detail.CloseButton:SetPoint("TOPRIGHT", detail, "TOPRIGHT", -4, -4)
    detail.RemoveButton:GwSkinButton(false, true)
    detail.GroupInviteButton:GwSkinButton(false, true)

    -- blizzards two 96 wide buttons stick out past the note boxes, they split the note width instead
    local buttonWidth = (detail.NoteBackground:GetWidth() - MEMBER_DETAIL_BUTTON_GAP) / 2
    detail.RemoveButton:SetWidth(buttonWidth)
    detail.RemoveButton:ClearAllPoints()
    detail.RemoveButton:SetPoint("BOTTOMLEFT", detail, "BOTTOMLEFT", 15, 12)
    detail.GroupInviteButton:SetWidth(buttonWidth)
    detail.GroupInviteButton:ClearAllPoints()
    detail.GroupInviteButton:SetPoint("LEFT", detail.RemoveButton, "RIGHT", MEMBER_DETAIL_BUTTON_GAP, 0)

    local rankDropdown = detail.RankDropdown
    rankDropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, rankDropdown:GetWidth())
end

-- blizzards checkboxes are 32 wide with their label 30 to 35 right of the box, ours are 15
local function SkinSettingsCheckbox(checkbox, label)
    checkbox:GwSkinCheckButton(false, 15)
    label:ClearAllPoints()
    label:SetPoint("LEFT", checkbox, "RIGHT", 6, 0)
end

-- focus, looking for and language of a club posting, in the settings and the guild recruitment dialog
local function SkinClubFinderPostingDropdowns(dialog)
    for _, key in ipairs({"ClubFocusDropdown", "LookingForDropdown", "LanguageDropdown"}) do
        local dropdown = dialog[key]
        dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
        if dropdown.Label then
            SetLightHeader(dropdown.Label)
        end
    end
end

-- SetAvatarTexture resets the tex coords whenever the avatar changes
local function UpdateSettingsAvatar(dialog)
    dialog.IconPreview:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

local function SkinCommunitiesSettings(dialog)
    dialog.BG:Hide()
    dialog.DialogLabel:SetJustifyH("LEFT")
    GW.SkinSmallWindow(dialog, dialog.DialogLabel, WINDOW_ICON)

    SkinDialogLabels({dialog.NameLabel, dialog.ShortNameLabel, dialog.DescriptionLabel, dialog.MessageOfTheDayLabel})
    SkinInputBox(dialog.NameEdit)
    SkinInputBox(dialog.ShortNameEdit)
    SkinInputBox(dialog.MinIlvlOnly.EditBox)
    SkinInputScroll(dialog.Description)
    SkinInputScroll(dialog.MessageOfTheDay)

    dialog.IconPreviewRing:SetAlpha(0)
    dialog.CircleMask:Hide()
    SkinRowIcon(dialog.IconPreview)
    UpdateSettingsAvatar(dialog)
    hooksecurefunc(dialog, "SetAvatarId", UpdateSettingsAvatar)

    SkinSettingsCheckbox(dialog.CrossFactionToggle.CheckButton, dialog.CrossFactionToggle.Label)
    for _, key in ipairs({"ShouldListClub", "AutoAcceptApplications", "MaxLevelOnly", "MinIlvlOnly"}) do
        SkinSettingsCheckbox(dialog[key].Button, dialog[key].Label)
    end

    SkinClubFinderPostingDropdowns(dialog)

    for _, button in ipairs({dialog.ChangeAvatarButton, dialog.Accept, dialog.Delete, dialog.Cancel}) do
        button:GwSkinButton(false, true)
    end
end

local function SkinRecruitmentDialog(dialog)
    dialog.BG:Hide()
    dialog.DialogLabel:SetJustifyH("LEFT")
    GW.SkinSmallWindow(dialog, dialog.DialogLabel, WINDOW_ICON)

    for _, key in ipairs({"ShouldListClub", "MaxLevelOnly", "MinIlvlOnly"}) do
        SkinSettingsCheckbox(dialog[key].Button, dialog[key].Label)
    end
    SkinInputBox(dialog.MinIlvlOnly.EditBox)
    SkinClubFinderPostingDropdowns(dialog)

    local messageFrame = dialog.RecruitmentMessageFrame
    SkinMessageFrame(messageFrame, messageFrame.RecruitmentMessageInput)
    SkinDialogLabels({messageFrame.Label})

    dialog.Accept:GwSkinButton(false, true)
    dialog.Cancel:GwSkinButton(false, true)
end

-- blizzard draws the same stripe on every link row, ours alternate
local function SkinTicketEntry(scrollBox, entry, ticketInfo)
    if not entry.gwSkinned then
        entry.gwSkinned = true
        entry.Stripe:SetTexture(ROW_BACKGROUND)
        entry.Stripe:SetTexCoord(0, 1, 0, 1)
        entry:SetHighlightTexture(ROW_HOVER)
        entry:GetHighlightTexture():SetBlendMode("BLEND")
        entry.CopyLinkButton:GwSkinButton(false, true)
    end
    local index = scrollBox:FindElementDataIndex(ticketInfo)
    entry.Stripe:SetShown(index ~= nil and index % 2 == 1)
end

-- the club avatar comes from SetAvatarTexture on every show
local function UpdateTicketManagerAvatar(dialog)
    dialog.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

-- the border is eight atlas pieces, half of them unnamed; the avatar, its ring and the separator are the keepers
local function SkinTicketManager(dialog)
    local keep = {[dialog.Icon] = true, [dialog.IconRing] = true, [dialog.Separator] = true}
    for _, region in ipairs({dialog:GetRegions()}) do
        if region:IsObjectType("Texture") and not keep[region] then
            region:SetAlpha(0)
        end
    end
    dialog.DialogLabel:SetJustifyH("LEFT")
    GW.SkinSmallWindow(dialog, dialog.DialogLabel, WINDOW_ICON)

    -- the avatar hangs off the title, which moved into our header
    dialog.IconRing:SetAlpha(0)
    dialog.IconRing:ClearAllPoints()
    dialog.IconRing:SetPoint("TOP", dialog, "TOP", 0, -TICKET_MANAGER_AVATAR_TOP)
    dialog.CircleMask:Hide()
    SkinRowIcon(dialog.Icon)
    dialog:HookScript("OnShow", UpdateTicketManagerAvatar)
    dialog.Separator:SetColorTexture(1, 1, 1, 0.1)

    dialog.LinkInstructions:SetTextColor(1, 1, 1)
    for _, label in ipairs({dialog.ExpandLabel, dialog.ExpiresDropdownLabel, dialog.UsesDropdownLabel}) do
        SetLightHeader(label)
    end

    for _, button in ipairs({dialog.LinkToChat, dialog.Copy, dialog.GenerateLinkButton, dialog.Close}) do
        button:GwSkinButton(false, true)
    end
    GW.HandleNextPrevButton(dialog.MaximizeButton, "down")
    for _, dropdown in ipairs({dialog.ExpiresDropdown, dialog.UsesDropdown}) do
        dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
    end

    local manager = dialog.InviteManager
    manager.ArtOverlay:Hide()
    manager.ScrollBox.Background:Hide()
    GW.AddDetailsBackground(manager.ScrollBox)
    SkinScroll(manager)
    SkinColumnDisplay(manager.ColumnDisplay)
    ScrollUtil.AddInitializedFrameCallback(manager.ScrollBox, function(_, entry, ticketInfo)
        SkinTicketEntry(manager.ScrollBox, entry, ticketInfo)
    end, manager)
end

-- SetAvatarTexture resets the tex coords on every display, and guild invitations hide the icon for their banner
local function UpdateInvitationIcon(frame)
    frame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.Icon.backdrop:SetShown(frame.Icon:IsShown())
end

-- the unnamed wide background is found by its atlas; it was opaque over the chat, so ours needs the window background
local function SkinInvitationFrame(frame, displayMethod)
    for _, region in ipairs({frame:GetRegions()}) do
        if region:IsObjectType("Texture") and region:GetAtlas() == "communities-widebackground" then
            region:SetAlpha(0)
        end
    end
    local background = frame.InsetFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    background:SetAllPoints(frame.InsetFrame)
    background:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background.png")
    GW.AddDetailsBackground(frame.InsetFrame)

    frame.CircleMask:Hide()
    frame.IconRing:SetAlpha(0)
    SkinRowIcon(frame.Icon)
    hooksecurefunc(frame, displayMethod, UpdateInvitationIcon)

    SetLightHeader(frame.InvitationText)
    frame.Name:SetTextColor(1, 1, 1)
    for _, text in ipairs({frame.Type, frame.MemberCount, frame.Leader, frame.Description}) do
        text:SetTextColor(1, 1, 1)
    end

    frame.AcceptButton:GwSkinButton(false, true)
    frame.DeclineButton:GwSkinButton(false, true)
end

local function SkinClubFinderInvitation(frame)
    SkinInvitationFrame(frame, "DisplayInvitation")
    frame.ApplyButton:GwSkinButton(false, true)

    local warning = frame.WarningDialog
    warning.BG:Hide()
    warning:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    warning.Accept:GwSkinButton(false, true)
    warning.Cancel:GwSkinButton(false, true)
end

-- the initializer sets the class sheet coords and blizzard draws the same stripe on every row, ours alternate
local function SkinApplicantEntry(scrollBox, entry, applicantInfo)
    if not entry.gwSkinned then
        entry.gwSkinned = true
        entry:SetNormalTexture(ROW_BACKGROUND)
        entry:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        entry:SetHighlightTexture(ROW_HOVER)
        entry:GetHighlightTexture():SetBlendMode("BLEND")
        entry.InviteButton:GwSkinButton(false, true)
    end
    local index = scrollBox:FindElementDataIndex(applicantInfo)
    entry:GetNormalTexture():SetAlpha((index and index % 2 == 1) and 1 or 0)
    SetFlatClassIcon(entry.Class, applicantInfo and applicantInfo.classID)
end

local function SkinApplicantList(list)
    GW.AddDetailsBackground(list.InsetFrame)
    SkinScroll(list)
    SkinColumnDisplay(list.ColumnDisplay)
    ScrollUtil.AddInitializedFrameCallback(list.ScrollBox, function(_, entry, applicantInfo)
        SkinApplicantEntry(list.ScrollBox, entry, applicantInfo)
    end, list)
end

---------- club finder (community finder and guild browser) ----------

local FINDER_TABS = {
    {key = "ClubFinderSearchTab", icon = "social/tabicon_who"},
    {key = "ClubFinderPendingTab", icon = "social/tabicon_friendrequests"},
}
local FINDER_ROLES = {
    {key = "TankRoleFrame", role = "TANK"},
    {key = "HealerRoleFrame", role = "HEALER"},
    {key = "DpsRoleFrame", role = "DAMAGER"},
}
local ROLE_ICON_SIZE = 30
-- our dropdowns are taller than blizzards, they drop to the role checkboxes while the roles keep their place
local FINDER_DROPDOWN_DROP = 12
local SEARCH_BOX_HEIGHT = 22
local SEARCH_BOX_OFFSET = 4
local SEARCH_BUTTON_GAP = 4
local REQUEST_TO_JOIN_NAME_TOP = 40
local FINDER_DETAILS_LEFT = 2
local FINDER_DETAILS_TOP = 8

-- blizzard anchors the roles to the size / sort dropdown and the search box to the dps role on every setup
local function PlaceFinderRolesAndSearch(options, dropdown)
    options.TankRoleFrame:SetPoint("RIGHT", dropdown, "RIGHT", 50, 6 + FINDER_DROPDOWN_DROP)
    options.SearchBox:SetPoint("RIGHT", options.DpsRoleFrame, "RIGHT", 160, SEARCH_BOX_OFFSET)
end

local function SkinFinderGuildCard(card)
    card.CardBackground:SetAlpha(0)
    local background = GW.CreateDetailsBackgroundTexture(card, 0)
    background:SetAllPoints(card)
    card:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    card.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
    card.RequestJoin:GwSkinButton(false, true)
end

-- the logo comes from SetAvatarTexture in every initialization, which resets the tex coords
local function SkinFinderCommunityCard(card)
    if not card.gwSkinned then
        card.gwSkinned = true
        card.Background:SetTexture(ROW_BACKGROUND)
        card.Background:SetTexCoord(0, 1, 0, 1)
        card.Background:SetAllPoints(card)
        card.HighlightBackground:SetTexture(ROW_HOVER)
        card.HighlightBackground:SetTexCoord(0, 1, 0, 1)
        card.HighlightBackground:SetBlendMode("BLEND")
        card.HighlightBackground:ClearAllPoints()
        card.HighlightBackground:SetAllPoints(card)
        card.LogoBorder:SetAlpha(0)
        card.CircleMask:Hide()
        SkinRowIcon(card.CommunityLogo)
    end
    card.CommunityLogo:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

local function SkinFinderOptions(options)
    for _, key in ipairs({"ClubFilterDropdown", "ClubSizeDropdown", "SortByDropdown"}) do
        local dropdown = options[key]
        dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
        SetLightHeader(dropdown.Label)
    end

    for _, info in ipairs(FINDER_ROLES) do
        local roleFrame = options[info.key]
        roleFrame.Icon:SetTexture(GW.nameRoleIconPure[info.role])
        roleFrame.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
        roleFrame.Icon:SetSize(ROLE_ICON_SIZE, ROLE_ICON_SIZE)
        roleFrame.Checkbox:GwSkinCheckButton(false, 15)
    end

    options.ClubFilterDropdown:SetPoint("TOPLEFT", options, "TOPLEFT", 0, 16 - FINDER_DROPDOWN_DROP)
    hooksecurefunc(options, "SetupGuildFinderOptions", function(self)
        PlaceFinderRolesAndSearch(self, self.ClubSizeDropdown)
    end)
    hooksecurefunc(options, "SetupCommunityFinderOptions", function(self)
        PlaceFinderRolesAndSearch(self, self.SortByDropdown)
    end)

    -- blizzards box is 35 high for its art, ours would reach into the header
    local searchBox = options.SearchBox
    searchBox:SetHeight(SEARCH_BOX_HEIGHT)
    GW.SkinTextBox(searchBox.Middle, searchBox.Left, searchBox.Right)
    searchBox.Instructions:SetTextColor(1, 1, 1)
    -- blizzard hangs the button 15 into its tall box, under ours it gets a gap and the box width
    options.Search:ClearAllPoints()
    options.Search:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -SEARCH_BUTTON_GAP)
    options.Search:SetPoint("TOPRIGHT", searchBox, "BOTTOMRIGHT", 0, -SEARCH_BUTTON_GAP)
    options.Search:GwSkinButton(false, true)
    SetLightHeader(options.PendingTextFrame.Text)
end

local function SkinFinderGuildCards(cards)
    for _, card in ipairs(cards.Cards) do
        SkinFinderGuildCard(card)
    end
    GW.HandleNextPrevButton(cards.PreviousPage, "left")
    GW.HandleNextPrevButton(cards.NextPage, "right")
end

local function SkinFinderCommunityCards(cards)
    SkinScroll(cards)
    SkinScrollBoxButtons(cards, SkinFinderCommunityCard)
end

-- the finder shows instead of the window tabs, so its tabs take the same slots on our side panel
local function SkinFinderTabs(finder)
    for index, info in ipairs(FINDER_TABS) do
        local tab = finder[info.key]
        GW.SkinSideTabButton(tab, TAB_ICON_PATH:format(info.icon))
        tab.Icon:Hide()
        hooksecurefunc(tab, "SetChecked", UpdateTabIcon)
        -- blizzard greys the pending tab out while there is nothing pending
        hooksecurefunc(tab.Icon, "SetDesaturated", function(_, desaturated)
            tab.icon:SetDesaturated(desaturated)
        end)
        UpdateTabIcon(tab)
        tab:ClearAllPoints()
        tab:SetPoint("TOPRIGHT", CommunitiesFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * (index - 1)))
    end
end

-- the spec checkboxes come from a new pool on every initialization, blizzard puts their names 35 right of the box
local function SkinRequestToJoinSpecs(dialog)
    for specButton in dialog.SpecsPool:EnumerateActive() do
        local checkbox = specButton.Checkbox
        if not checkbox.gwSkinned then
            checkbox:GwSkinCheckButton(false, 15)
            specButton.SpecName:ClearAllPoints()
            specButton.SpecName:SetPoint("LEFT", checkbox, "RIGHT", 6, 0)
        end
    end
end

-- the dialog sizes itself on every initialization; its club name hangs off the title, which moves into our header
local function SkinRequestToJoin(dialog)
    dialog.BG:Hide()
    dialog.DialogLabel:SetJustifyH("LEFT")
    GW.SkinSmallWindow(dialog, dialog.DialogLabel, WINDOW_ICON)
    dialog.ClubName:ClearAllPoints()
    dialog.ClubName:SetPoint("TOP", dialog, "TOP", 0, -REQUEST_TO_JOIN_NAME_TOP)

    -- ClubDescription2 is retail only
    for _, key in ipairs({"ClubDescription", "ClubDescription2", "ErrorDescription", "RecruitingSpecDescriptions"}) do
        if dialog[key] then
            dialog[key]:SetTextColor(1, 1, 1)
        end
    end

    SkinMessageFrame(dialog.MessageFrame, dialog.MessageFrame.MessageScroll)

    dialog.Apply:GwSkinButton(false, true)
    dialog.Cancel:GwSkinButton(false, true)

    hooksecurefunc(dialog, "Initialize", SkinRequestToJoinSpecs)
end

local function SkinClubFinder(finder)
    SkinFinderOptions(finder.OptionsList)
    SkinFinderGuildCards(finder.GuildCards)
    SkinFinderGuildCards(finder.PendingGuildCards)
    SkinFinderCommunityCards(finder.CommunityCards)
    SkinFinderCommunityCards(finder.PendingCommunityCards)
    -- blizzards inset starts under the lowered dropdowns and right at the list scroll bar
    GW.AddDetailsBackground(finder.InsetFrame, FINDER_DETAILS_LEFT, -FINDER_DETAILS_TOP)
    finder.InsetFrame.GuildDescription:SetTextColor(1, 1, 1)
    finder.InsetFrame.ErrorDescription:SetTextColor(1, 1, 1)
    SkinFinderTabs(finder)
    SkinRequestToJoin(finder.RequestToJoinFrame)
end

local function SkinCommunitiesFrame()
    if CommunitiesFrame.gwSkinned then return end
    CommunitiesFrame.gwSkinned = true

    GW.HandlePortraitFrame(CommunitiesFrame)
    GW.HandlePortraitFrameArt(CommunitiesFrame)
    CommunitiesFrame.PortraitOverlay:Hide()

    GW.CreateFrameHeaderWithBody(CommunitiesFrame, CommunitiesFrame.TitleContainer.TitleText, WINDOW_ICON, nil, nil, true, true)
    CommunitiesFrame.gwHeader.windowIcon:ClearAllPoints()
    CommunitiesFrame.gwHeader.windowIcon:SetPoint("CENTER", CommunitiesFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    CommunitiesFrame:GetTitleText():ClearAllPoints()
    CommunitiesFrame:GetTitleText():SetPoint("BOTTOMLEFT", CommunitiesFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    CommunitiesFrame:GetTitleText():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    CommunitiesFrame:SetClampedToScreen(true)
    CommunitiesFrame:SetClampRectInsets(-60, 0, CommunitiesFrame.gwHeader:GetHeight() - 30, 0)

    CommunitiesFrame.CloseButton:ClearAllPoints()
    CommunitiesFrame.CloseButton:SetPoint("TOPRIGHT", CommunitiesFrame, "TOPRIGHT", -5, -2)

    -- blizzards inset art comes off first, several of our backgrounds sit on those insets
    SkinInset(CommunitiesFrame.Inset)
    StripInsetsRecursive(CommunitiesFrame, 3)
    SkinCommunitiesList(CommunitiesFrame.CommunitiesList)
    SkinMemberList(CommunitiesFrame.MemberList)
    SkinChat(CommunitiesFrame.Chat)
    SkinGuildPanels()
    SkinGuildDialogs()
    SkinGuildMemberDetail(CommunitiesFrame.GuildMemberDetailFrame)
    SkinCommunitiesSettings(CommunitiesSettingsDialog)
    SkinRecruitmentDialog(CommunitiesFrame.RecruitmentDialog)
    SkinTicketManager(CommunitiesTicketManagerDialog)
    SkinInvitationFrame(CommunitiesFrame.InvitationFrame, "DisplayInvitation")
    SkinInvitationFrame(CommunitiesFrame.TicketFrame, "DisplayTicket")
    SkinClubFinderInvitation(CommunitiesFrame.ClubFinderInvitationFrame)
    SkinApplicantList(CommunitiesFrame.ApplicantList)
    SkinClubFinder(CommunitiesFrame.GuildFinderFrame)
    SkinClubFinder(CommunitiesFrame.CommunityFinderFrame)
    SkinButtons()

    SkinNotificationSettingsDialog(CommunitiesFrame.NotificationSettingsDialog)
    SkinEditStreamDialog(CommunitiesFrame.EditStreamDialog)

    LayoutTabs()
    hooksecurefunc(CommunitiesFrame, "UpdateCommunitiesTabs", LayoutTabs)
    CommunitiesFrame:HookScript("OnShow", LayoutTabs)
end

local function LoadCommunitiesSkin()
    if not GW.settings.skins.communities.enabled then return end

    GW.RegisterLoadHook(SkinCommunitiesFrame, "Blizzard_Communities", CommunitiesFrame)
    -- the picker opens from the create dialog, independent of the guild window
    GW.RegisterLoadHook(function()
        hooksecurefunc("CommunitiesAvatarPicker_OpenDialog", SkinAvatarPicker)
    end, "Blizzard_Communities", CommunitiesAvatarPickerDialog)
end
GW.LoadCommunitiesSkin = LoadCommunitiesSkin
