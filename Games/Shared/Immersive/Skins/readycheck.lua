---@class GW2
local GW = select(2, ...)

local READY_CHECK_TEXTURE = "Interface/AddOns/GW2_UI/textures/party/readycheck.png"
local READY_CHECK_BUTTON = "Interface/AddOns/GW2_UI/textures/party/readycheck-button.png"
local MANAGE_GROUP_BG = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png"
local LEVEL_REWARD_SEPARATOR = "Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png"
local STATUS_BAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png"

local function SetButtonFontStringColor(button, r, g, b, a)
    if button:GetFontString() then
        button:GetFontString():SetTextColor(r, g, b, a or 1)
    end

    if button.Text then
        button.Text:SetTextColor(r, g, b, a or 1)
    end

    if button.ButtonText then
        button.ButtonText:SetTextColor(r, g, b, a or 1)
    end
end

local function StyleReadyCheckButton(button, isReadyButton)
    button:SetSize(136, 26)
    button:GwSkinButton(false, true)
    button:SetNormalTexture(READY_CHECK_BUTTON)
    button:SetPushedTexture(READY_CHECK_BUTTON)

    local highlightTexture = button:GetHighlightTexture()
    highlightTexture:SetTexture()

    local normalTexture = button:GetNormalTexture()
    normalTexture:SetVertexColor(isReadyButton and 0.78 or 1, isReadyButton and 1 or 0.82, isReadyButton and 0.78 or 0.82, 1)

    local pushedTexture = button:GetPushedTexture()
    pushedTexture:SetVertexColor(isReadyButton and 0.58 or 1, isReadyButton and 0.86 or 0.68, isReadyButton and 0.58 or 0.68, 1)

    button.hover.r = isReadyButton and 0.35 or 1
    button.hover.g = isReadyButton and 1 or 0.2
    button.hover.b = isReadyButton and 0.35 or 0.2

    local normalTextColor = isReadyButton and {0.84, 1, 0.78} or {1, 0.82, 0.78}
    local hoverTextColor = isReadyButton and {0.95, 1, 0.95} or {1, 0.95, 0.95}

    SetButtonFontStringColor(button, normalTextColor[1], normalTextColor[2], normalTextColor[3])

    if not button.gwReadyCheckButtonHooks then
        button:HookScript("OnEnter", function(self)
            if self.IsEnabled and not self:IsEnabled() then return end
            SetButtonFontStringColor(self, hoverTextColor[1], hoverTextColor[2], hoverTextColor[3])
        end)
        button:HookScript("OnLeave", function(self)
            SetButtonFontStringColor(self, normalTextColor[1], normalTextColor[2], normalTextColor[3])
        end)
        button.gwReadyCheckButtonHooks = true
    end

    button.gwReadyCheckIcon = button:CreateTexture(nil, "OVERLAY")
    button.gwReadyCheckIcon:SetSize(16, 16)
    button.gwReadyCheckIcon:SetPoint("LEFT", button, "LEFT", 8, 0)
    button.gwReadyCheckIcon:SetTexture(READY_CHECK_TEXTURE)
    button.gwReadyCheckIcon:SetTexCoord(0, 1, isReadyButton and 0.5 or 0.25, isReadyButton and 0.75 or 0.5)

    local fontString = button:GetFontString()
    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", button.gwReadyCheckIcon, "RIGHT", 4, 0)
    fontString:SetPoint("RIGHT", button, "RIGHT", -10, 0)
    fontString:SetJustifyH("CENTER")
    fontString:SetShadowColor(0, 0, 0, 0.9)
    fontString:SetShadowOffset(1, -1)
end

local function CreatePanelTexture(frame, key, layer, subLevel, texture)
    frame[key] = frame:CreateTexture(nil, layer, nil, subLevel)
    frame[key]:ClearAllPoints()
    frame[key]:SetTexture(texture)
    return frame[key]
end

local function GetReadyCheckTitle(listener)
    if GW.Retail then return listener.TitleContainer.TitleText end

    if not listener.gwReadyCheckTitle then
        listener.gwReadyCheckTitle = listener:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    end

    listener.gwReadyCheckTitle:SetText(_G.READY_CHECK or "READY CHECK")
    return listener.gwReadyCheckTitle
end

local function ApplyReadyCheckLayout()
    local frame = _G.ReadyCheckFrame
    local listener = _G.ReadyCheckListenerFrame
    if not frame or not listener then return end

    frame:SetSize(360, 138)
    frame:SetClampedToScreen(true)

    listener:ClearAllPoints()
    listener:SetAllPoints(frame)

    local background = CreatePanelTexture(listener, "gwReadyCheckBackground", "BACKGROUND", 0, MANAGE_GROUP_BG)
    background:SetAllPoints(listener)

    local headerShade = CreatePanelTexture(listener, "gwReadyCheckHeaderShade", "BACKGROUND", 1, STATUS_BAR_TEXTURE)
    headerShade:SetPoint("TOPLEFT", listener, "TOPLEFT", 5, -5)
    headerShade:SetPoint("TOPRIGHT", listener, "TOPRIGHT", -5, -5)
    headerShade:SetHeight(38)
    headerShade:SetVertexColor(0, 0, 0, 0.55)

    local footerShade = CreatePanelTexture(listener, "gwReadyCheckFooterShade", "BACKGROUND", 1, STATUS_BAR_TEXTURE)
    footerShade:SetPoint("BOTTOMLEFT", listener, "BOTTOMLEFT", 5, 5)
    footerShade:SetPoint("BOTTOMRIGHT", listener, "BOTTOMRIGHT", -5, 5)
    footerShade:SetHeight(42)
    footerShade:SetVertexColor(0, 0, 0, 0.28)

    local divider = CreatePanelTexture(listener, "gwReadyCheckDivider", "ARTWORK", 2, LEVEL_REWARD_SEPARATOR)
    divider:SetPoint("TOPLEFT", listener, "TOPLEFT", 18, -43)
    divider:SetPoint("TOPRIGHT", listener, "TOPRIGHT", -18, -43)
    divider:SetHeight(2)

    if GW.Retail then
        listener.NineSlice:Hide()
        listener.Bg:Hide()
    end

    local title = GetReadyCheckTitle(listener)
    title:SetParent(listener)
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", listener, "TOPLEFT", 58, -12)
    title:SetPoint("TOPRIGHT", listener, "TOPRIGHT", -18, -12)
    title:SetJustifyH("LEFT")
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 1)
    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    title:SetShadowOffset(1, -1)

    if GW.Retail then
        listener.TitleContainer:Hide()
    end

    local portrait = _G.ReadyCheckPortrait
    portrait:SetParent(listener)
    portrait:ClearAllPoints()
    portrait:SetPoint("TOPLEFT", listener, "TOPLEFT", 18, -9)
    portrait:SetSize(34, 34)
    portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    portrait:SetDrawLayer("OVERLAY", 2)
    portrait:Show()

    portrait:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true, 3, 3)
    portrait.backdrop:SetBackdropColor(0, 0, 0, 0.72)
    portrait.backdrop:SetBackdropBorderColor(0.75, 0.62, 0.35, 0.9)

    portrait.gwReadyCheckInnerBorder = frame:CreateTexture(nil, "OVERLAY", nil, 3)
    portrait.gwReadyCheckInnerBorder:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
    portrait.gwReadyCheckInnerBorder:SetPoint("BOTTOMLEFT", portrait, "BOTTOMLEFT", 0, -2)
    portrait.gwReadyCheckInnerBorder:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 0, -2)
    portrait.gwReadyCheckInnerBorder:SetHeight(2)
    portrait.gwReadyCheckInnerBorder:SetVertexColor(1, 0.86, 0.46, 0.85)

    if GW.Retail then
        listener.PortraitContainer:Hide()
    end

    local text = _G.ReadyCheckFrameText
    text:SetParent(listener)
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", listener, "TOPLEFT", 22, -52)
    text:SetPoint("TOPRIGHT", listener, "TOPRIGHT", -22, -52)
    text:SetHeight(34)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("MIDDLE")
    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    text:SetTextColor(0.92, 0.88, 0.78, 1)
    text:SetShadowOffset(1, -1)

    local noButton = _G.ReadyCheckFrameNoButton
    local yesButton = _G.ReadyCheckFrameYesButton
    StyleReadyCheckButton(noButton, false)
    StyleReadyCheckButton(yesButton, true)

    noButton:ClearAllPoints()
    noButton:SetPoint("BOTTOMLEFT", listener, "BOTTOMLEFT", 35, 14)

    yesButton:ClearAllPoints()
    yesButton:SetPoint("BOTTOMRIGHT", listener, "BOTTOMRIGHT", -35, 14)
end

function GW.LoadReadyCheckSkin()
    if not GW.settings.READYCHECK_SKIN_ENABLED then return end

    local listener = _G.ReadyCheckListenerFrame
    if not listener then return end

    listener:GwStripTextures()
    listener:GwCreateBackdrop(GW.BackdropTemplates.Default)

    ApplyReadyCheckLayout()
end
