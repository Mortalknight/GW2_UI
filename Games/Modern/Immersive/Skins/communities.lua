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
local LIST_TOP_PADDING = 40

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
    if not inset then return end

    inset:GwStripTextures()
    if inset.Bg then inset.Bg:Hide() end
    if inset.NineSlice then inset.NineSlice:Hide() end
end

local function SkinScroll(frame)
    if not frame or not frame.ScrollBar then return end

    GW.HandleTrimScrollBar(frame.ScrollBar)
    GW.HandleScrollControls(frame)
    frame.ScrollBar:SetHideIfUnscrollable(true)
end

-- blizzard re-textures the entries in their initializer (SetClubInfo, SetAddCommunity, ...),
-- so this runs after every initialization instead of once
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
    if highlight then
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        highlight:SetTexCoord(0, 1, 0, 1)
        highlight:SetBlendMode("BLEND")
        highlight:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        highlight:ClearAllPoints()
        highlight:SetAllPoints(entry.Background)
    end

    if entry.NewCommunityFlash then
        entry.NewCommunityFlash:SetAlpha(0)
    end
end

local function SkinCommunitiesList(list)
    list:GwStripTextures()
    for _, key in ipairs({"Bg", "TopFiligree", "BottomFiligree", "FilligreeOverlay"}) do
        if list[key] then
            list[key]:Hide()
        end
    end

    GW.AddDetailsBackground(list)
    SkinScroll(list)

    -- the scroll box keeps blizzards 40 padding: changing it taints every list update (SetAvatarTexture is protected)
    -- and the entries look their list up through their parents, so the box can not be moved into a clipping frame
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

local function SetMemberClassIcon(entry)
    local classInfo = entry.memberInfo and entry.memberInfo.classID and C_CreatureInfo.GetClassInfo(entry.memberInfo.classID)
    if classInfo then
        entry.Class:SetTexture("Interface/AddOns/GW2_UI/Textures/classicons/" .. strlower(classInfo.classFile) .. "_flat.png")
        entry.Class:SetTexCoord(0, 1, 0, 1)
    end
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

local function SkinGuildPanels()
    local details = CommunitiesFrame.GuildDetailsFrame
    details:GwStripTextures()
    GW.AddDetailsBackground(details.Info)
    GW.AddDetailsBackground(details.News)
    SkinScroll(details.News)

    local benefits = CommunitiesFrame.GuildBenefitsFrame
    benefits:GwStripTextures()
    GW.AddDetailsBackground(benefits.Perks)
    GW.AddDetailsBackground(benefits.Rewards)
    SkinScroll(benefits.Perks)
    SkinScroll(benefits.Rewards)
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
        if button then
            button:GwSkinButton(false, true)
        end
    end

    -- our windows do not minimize, and blizzards button sits right next to the close button as a second X
    CommunitiesFrame.MaximizeMinimizeFrame:Hide()

    for _, key in ipairs({"StreamDropdown", "GuildMemberListDropdown", "CommunityMemberListDropdown", "CommunitiesListDropdown"}) do
        local dropdown = CommunitiesFrame[key]
        if dropdown then
            dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
        end
    end
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

    GW.CreateFrameHeaderWithBody(picker, title, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png")
    picker.gwHeader.windowIcon:ClearAllPoints()
    picker.gwHeader.windowIcon:SetPoint("CENTER", picker.gwHeader, "BOTTOMLEFT", 24, 30)
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

    GW.CreateFrameHeaderWithBody(dialog, dialog.TitleLabel, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png")
    dialog.gwHeader.windowIcon:ClearAllPoints()
    dialog.gwHeader.windowIcon:SetPoint("CENTER", dialog.gwHeader, "BOTTOMLEFT", 24, 30)

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

local function SkinEditStreamDialog(dialog)
    dialog.BG:Hide()

    GW.CreateFrameHeaderWithBody(dialog, dialog.TitleLabel, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png")
    dialog.gwHeader.windowIcon:ClearAllPoints()
    dialog.gwHeader.windowIcon:SetPoint("CENTER", dialog.gwHeader, "BOTTOMLEFT", 24, 30)

    for _, label in ipairs({dialog.NameLabel, dialog.DescriptionLabel, dialog.TypeLabel}) do
        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    -- blizzards box art hangs 5 out to the left of the text, ours starts at the text, so the text needs the room
    local nameEdit = dialog.NameEdit
    GW.SkinTextBox(nameEdit.Middle, nameEdit.Left, nameEdit.Right)
    nameEdit:SetTextInsets(TEXTBOX_PADDING, TEXTBOX_PADDING, 0, 0)

    local description = dialog.Description
    for _, key in ipairs(INPUT_SCROLL_CORNERS) do
        description[key]:Hide()
    end
    GW.SkinTextBox(description.MiddleTex, description.LeftTex, description.RightTex, description.TopTex, description.BottomTex)
    SkinScroll(description)

    local descriptionEdit = description.EditBox
    descriptionEdit:SetTextInsets(TEXTBOX_PADDING, TEXTBOX_PADDING, 4, 4)
    descriptionEdit.Instructions:ClearAllPoints()
    descriptionEdit.Instructions:SetPoint("TOPLEFT", descriptionEdit, "TOPLEFT", TEXTBOX_PADDING, -4)

    dialog.TypeCheckbox:GwSkinCheckButton(false, 15)
    dialog.TypeCheckbox:ClearAllPoints()
    dialog.TypeCheckbox:SetPoint("RIGHT", dialog.TypeLabel, "LEFT", -6, 0)

    dialog.Accept:GwSkinButton(false, true)
    dialog.Delete:GwSkinButton(false, true)
    dialog.Cancel:GwSkinButton(false, true)
end

local function SkinCommunitiesFrame()
    if CommunitiesFrame.gwSkinned then return end
    CommunitiesFrame.gwSkinned = true

    GW.HandlePortraitFrame(CommunitiesFrame)
    GW.HandlePortraitFrameArt(CommunitiesFrame)
    CommunitiesFrame.PortraitOverlay:Hide()

    GW.CreateFrameHeaderWithBody(CommunitiesFrame, CommunitiesFrame.TitleContainer.TitleText, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png", nil, nil, true, true)
    CommunitiesFrame.gwHeader.windowIcon:ClearAllPoints()
    CommunitiesFrame.gwHeader.windowIcon:SetPoint("CENTER", CommunitiesFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    CommunitiesFrame:GetTitleText():ClearAllPoints()
    CommunitiesFrame:GetTitleText():SetPoint("BOTTOMLEFT", CommunitiesFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    CommunitiesFrame:GetTitleText():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    CommunitiesFrame:SetClampedToScreen(true)
    CommunitiesFrame:SetClampRectInsets(-60, 0, CommunitiesFrame.gwHeader:GetHeight() - 30, 0)

    CommunitiesFrame.CloseButton:ClearAllPoints()
    CommunitiesFrame.CloseButton:SetPoint("TOPRIGHT", CommunitiesFrame, "TOPRIGHT", -5, -2)

    SkinInset(CommunitiesFrame.Inset)
    SkinCommunitiesList(CommunitiesFrame.CommunitiesList)
    SkinMemberList(CommunitiesFrame.MemberList)
    SkinChat(CommunitiesFrame.Chat)
    SkinGuildPanels()
    SkinButtons()

    SkinNotificationSettingsDialog(CommunitiesFrame.NotificationSettingsDialog)
    SkinEditStreamDialog(CommunitiesFrame.EditStreamDialog)
    StripInsetsRecursive(CommunitiesFrame, 3)

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
