---@class GW2
local GW = select(2, ...)

-- chat channels window: mainline and forever list with scroll boxes, the classic clients with hybrid and panel scroll frames
local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png"
local HEADER_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bag-sep.png"
local LIST_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local ARROW = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local SELECTED_ATLAS = "voicechat-channellist-row-selected"

local function SkinScroll(scrollFrame, scrollBar)
    if scrollBar.SetHideIfUnscrollable then
        GW.HandleTrimScrollBar(scrollBar)
        GW.HandleScrollControls(scrollFrame)
    else
        scrollBar:GwSkinScrollBar()
        scrollFrame:GwSkinScrollFrame()
    end
end

local function SkinInset(inset)
    inset:GwStripTextures()
    if inset.NineSlice then
        inset.NineSlice:Hide()
    end
    GW.AddDetailsBackground(inset)
end

-- blizzard sets its highlight atlas again on every selection change
local function UpdateHighlight(button)
    local highlight = button:GetHighlightTexture()
    local atlas = highlight:GetAtlas()
    if not atlas then return end
    highlight:SetTexture(LIST_HOVER)
    highlight:SetBlendMode("BLEND")
    highlight:SetVertexColor((atlas == SELECTED_ATLAS and GW.Colors.SkinColors.ListSelected or GW.Colors.SkinColors.ListHover):GetRGBA())
end

local function SkinRowButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true
    button.NormalTexture:SetAlpha(0)
    UpdateHighlight(button)
    if button.SetIsSelectedChannel then
        hooksecurefunc(button, "SetIsSelectedChannel", UpdateHighlight)
    end
end

-- blizzard writes the header text with its color code and sets the plus/minus atlas on every update
local function UpdateHeader(header)
    header.Text:SetText(GW.Colors.TextColors.LightHeader:WrapTextInColorCode(header:GetChannelName() or ""))
    header.Collapsed:SetTexture(ARROW)
    header.Collapsed:SetRotation(header:IsCollapsed() and math.pi / 2 or 0)
end

local function SkinHeaderButton(header)
    if header.gwSkinned then return end
    header.gwSkinned = true
    header.NormalTexture:SetTexture(HEADER_TEXTURE)
    header.HighlightTexture:SetTexture(LIST_HOVER)
    header.HighlightTexture:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
    header.Collapsed:SetSize(16, 16)
    hooksecurefunc(header, "Update", UpdateHeader)
    UpdateHeader(header)
end

local function UpdateChannelList(list)
    for header in list.headerButtonPool:EnumerateActive() do
        SkinHeaderButton(header)
    end
    for _, pool in ipairs({list.textChannelButtonPool, list.voiceChannelButtonPool, list.communityChannelButtonPool}) do
        for button in pool:EnumerateActive() do
            SkinRowButton(button)
        end
    end
end

local function SkinRoster(roster)
    roster.ChannelName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    roster.ChannelCount:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    if roster.ScrollBox then
        SkinScroll(roster, roster.ScrollBar)
        ScrollUtil.AddInitializedFrameCallback(roster.ScrollBox, function(_, button) SkinRowButton(button) end, roster)
        roster.ScrollBox:ForEachFrame(SkinRowButton)
    else
        SkinScroll(roster.ScrollFrame, roster.ScrollFrame.scrollBar)
        for _, button in ipairs(roster.ScrollFrame.buttons or {}) do
            SkinRowButton(button)
        end
    end
end

local function SkinCreateChannelPopup()
    local popup = CreateChannelPopup
    popup:GwStripTextures()
    if popup.BG then
        popup.BG:Hide()
    end
    if popup.Header then
        popup.Header:GwStripTextures()
    end
    if popup.SetBackdrop then
        popup:SetBackdrop(nil)
    end
    popup:GwCreateBackdrop(GW.BackdropTemplates.Default)
    local title = popup.Header and popup.Header.Text or popup.Title
    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    -- in line with the close button, blizzards header sits on top of the dialog edge
    title:ClearAllPoints()
    title:SetPoint("TOP", popup, "TOP", 0, -10)

    -- our box starts at the text, blizzards art hangs out to the left, so the text needs the room
    for _, editBox in ipairs({popup.Name, popup.Password}) do
        GW.SkinTextBox(editBox.Middle, editBox.Left, editBox.Right)
        editBox:SetTextInsets(6, 6, 0, 0)
        editBox.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    end
    popup.OKButton:GwSkinButton(false, true)
    popup.CancelButton:GwSkinButton(false, true)
    popup.CloseButton:GwSkinButton(true)
    popup.CloseButton:SetSize(20, 20)
    popup.CloseButton:ClearAllPoints()
    popup.CloseButton:SetPoint("TOPRIGHT", -5, -5)
end

local function ApplyChannelsSkin()
    local frame = ChannelFrame
    frame:GwStripTextures()
    GW.HandlePortraitFrameArt(frame)
    if frame.Inset then
        frame.Inset:Hide()
    end

    local title = frame.TitleContainer and frame.TitleContainer.TitleText or frame.TitleText
    GW.SkinSmallWindow(frame, title, WINDOW_ICON, frame.CloseButton or ChannelFrameCloseButton)

    SkinInset(frame.LeftInset)
    SkinInset(frame.RightInset)
    frame.NewButton:GwSkinButton(false, true)
    frame.SettingsButton:GwSkinButton(false, true)

    SkinScroll(frame.ChannelList, frame.ChannelList.ScrollBar)
    hooksecurefunc(frame.ChannelList, "Update", UpdateChannelList)
    UpdateChannelList(frame.ChannelList)
    SkinRoster(frame.ChannelRoster)

    SkinCreateChannelPopup()
end

local function LoadChannelsSkin()
    if not GW.settings.chat.enabled then return end
    GW.RegisterLoadHook(ApplyChannelsSkin, "Blizzard_Channels", ChannelFrame)
end
GW.LoadChannelsSkin = LoadChannelsSkin
