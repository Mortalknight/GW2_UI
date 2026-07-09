---@class GW2
local GW = select(2, ...)

local READY_CHECK_TEXTURE = "Interface/AddOns/GW2_UI/textures/party/readycheck.png"
local READY_CHECK_BUTTON = "Interface/AddOns/GW2_UI/textures/party/readycheck-button.png"
local STATUS_BAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png"
local LEVEL_REWARD_SEPARATOR = "Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png"

-- color schemes matching the ready check skin buttons
local BUTTON_SCHEMES = {
    confirm = {
        normal = {0.78, 1, 0.78},
        pushed = {0.58, 0.86, 0.58},
        hover = {0.35, 1, 0.35},
        text = {0.84, 1, 0.78},
        hoverText = {0.95, 1, 0.95},
        iconTexCoord = {0, 1, 0.5, 0.75},
    },
    cancel = {
        normal = {1, 0.82, 0.82},
        pushed = {1, 0.68, 0.68},
        hover = {1, 0.2, 0.2},
        text = {1, 0.82, 0.78},
        hoverText = {1, 0.95, 0.95},
        iconTexCoord = {0, 1, 0.25, 0.5},
    },
    neutral = {
        normal = {1, 1, 1},
        pushed = {0.8, 0.8, 0.8},
        hover = {1, 1, 1},
        text = {0.9, 0.92, 0.94},
        hoverText = {1, 1, 1},
    },
}

-- map button labels (from global strings) to a color scheme, so negative buttons
-- like Cancel/No are red and affirmative ones like Yes/Okay are green everywhere
local BUTTON_TEXT_SCHEMES = {}
do
    local function register(scheme, ...)
        for i = 1, select("#", ...) do
            local str = select(i, ...)
            if type(str) == "string" and str ~= "" then
                BUTTON_TEXT_SCHEMES[strlower(strtrim(str))] = scheme
            end
        end
    end
    register("cancel", CANCEL, NO, DECLINE)
    register("confirm", YES, OKAY, ACCEPT, ACCEPT_ALT)
end

local function SetButtonFontStringColor(button, r, g, b, a)
    if button:GetFontString() then
        button:GetFontString():SetTextColor(r, g, b, a or 1)
    end

    if button.Text then
        button.Text:SetTextColor(r, g, b, a or 1)
    end
end

function GW.SetPopupButtonScheme(button, schemeName)
    local scheme = BUTTON_SCHEMES[schemeName]
    button.gwPopupScheme = scheme

    button:GetNormalTexture():SetVertexColor(scheme.normal[1], scheme.normal[2], scheme.normal[3], 1)
    button:GetPushedTexture():SetVertexColor(scheme.pushed[1], scheme.pushed[2], scheme.pushed[3], 1)
    if button.hover then
        button.hover.r, button.hover.g, button.hover.b = scheme.hover[1], scheme.hover[2], scheme.hover[3]
    end
    SetButtonFontStringColor(button, scheme.text[1], scheme.text[2], scheme.text[3])

    -- only show the check/cross icon when the button is wide enough for text + icon
    local fontString = button:GetFontString()
    local icon = button.gwPopupIcon
    local showIcon = scheme.iconTexCoord and fontString and (button:GetWidth() - fontString:GetStringWidth()) >= 44
    if showIcon then
        icon:SetTexCoord(scheme.iconTexCoord[1], scheme.iconTexCoord[2], scheme.iconTexCoord[3], scheme.iconTexCoord[4])
        icon:Show()
        fontString:ClearAllPoints()
        fontString:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        fontString:SetPoint("RIGHT", button, "RIGHT", -10, 0)
        fontString:SetJustifyH("CENTER")
    else
        icon:Hide()
        if fontString then
            fontString:ClearAllPoints()
            fontString:SetPoint("CENTER", button, "CENTER", 0, 0)
        end
    end
end

-- core ready check button styling; assumes the button already has GW hover handling
-- (GwStandardButton template or a prior GwSkinButton call)
function GW.StylePopupButton(button)
    if not button or button.gwPopupStyled then return end

    button:SetNormalTexture(READY_CHECK_BUTTON)
    button:SetPushedTexture(READY_CHECK_BUTTON)

    local highlightTexture = button:GetHighlightTexture()
    if highlightTexture then
        highlightTexture:SetTexture()
    end

    button.gwPopupIcon = button:CreateTexture(nil, "OVERLAY")
    button.gwPopupIcon:SetSize(16, 16)
    button.gwPopupIcon:SetPoint("LEFT", button, "LEFT", 8, 0)
    button.gwPopupIcon:SetTexture(READY_CHECK_TEXTURE)
    button.gwPopupIcon:Hide()

    local fontString = button:GetFontString()
    if fontString then
        fontString:SetShadowColor(0, 0, 0, 0.9)
        fontString:SetShadowOffset(1, -1)
    end

    button:HookScript("OnEnter", function(self)
        if self.IsEnabled and not self:IsEnabled() then return end
        local scheme = self.gwPopupScheme
        if scheme then
            SetButtonFontStringColor(self, scheme.hoverText[1], scheme.hoverText[2], scheme.hoverText[3])
        end
    end)
    button:HookScript("OnLeave", function(self)
        local scheme = self.gwPopupScheme
        if scheme then
            SetButtonFontStringColor(self, scheme.text[1], scheme.text[2], scheme.text[3])
        end
    end)

    GW.SetPopupButtonScheme(button, "neutral")
    button.gwPopupStyled = true
end

local function StyleStaticPopupButton(button)
    if not button or button.gwPopupStyled then return end

    button:GwSkinButton(false, true)
    GW.StylePopupButton(button)
end

local function ClassifyPopupButton(button)
    local fontString = button:GetFontString()
    local text = fontString and fontString:GetText()
    if not text or text == "" then return "neutral" end
    return BUTTON_TEXT_SCHEMES[strlower(strtrim(text))] or "neutral"
end

local function UpdatePopupButtonSchemes(popup)
    local buttons = popup.gwPopupButtons
    if not buttons then return end

    -- color each button from its label: negative (Cancel/No) red, affirmative (Yes/Okay) green
    for _, button in ipairs(buttons) do
        GW.SetPopupButtonScheme(button, ClassifyPopupButton(button))
    end
end

local FOOTER_SHADE_ALPHA = 0.35
local FOOTER_SHADE_EDGE = 28

local FOOTER_PADDING = 8 -- gap between the button row and the footer/divider edges

function GW.CreatePopupPanelDecoration(popup, anchorButton)
    -- footer shade as a band around the button row, anchored to the buttons so it
    -- stays a neat band regardless of popup size or which content sits above it.
    -- solid middle with short gradients so the left and right edges fade out softly
    local function anchorBand(tex)
        tex:SetTexture(STATUS_BAR_TEXTURE)
        tex:SetPoint("TOP", anchorButton, "TOP", 0, FOOTER_PADDING)
        tex:SetPoint("BOTTOM", anchorButton, "BOTTOM", 0, -FOOTER_PADDING)
    end

    local middleShade = popup:CreateTexture(nil, "BACKGROUND", nil, 1)
    anchorBand(middleShade)
    middleShade:SetPoint("LEFT", popup, "LEFT", 5 + FOOTER_SHADE_EDGE, 0)
    middleShade:SetPoint("RIGHT", popup, "RIGHT", -(5 + FOOTER_SHADE_EDGE), 0)
    middleShade:SetVertexColor(0, 0, 0, FOOTER_SHADE_ALPHA)

    local leftShade = popup:CreateTexture(nil, "BACKGROUND", nil, 1)
    anchorBand(leftShade)
    leftShade:SetWidth(FOOTER_SHADE_EDGE)
    leftShade:SetPoint("LEFT", popup, "LEFT", 5, 0)
    leftShade:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, FOOTER_SHADE_ALPHA))

    local rightShade = popup:CreateTexture(nil, "BACKGROUND", nil, 1)
    anchorBand(rightShade)
    rightShade:SetWidth(FOOTER_SHADE_EDGE)
    rightShade:SetPoint("RIGHT", popup, "RIGHT", -5, 0)
    rightShade:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, FOOTER_SHADE_ALPHA), CreateColor(0, 0, 0, 0))

    popup.gwFooterShadeMiddle = middleShade
    popup.gwFooterShadeLeft = leftShade
    popup.gwFooterShadeRight = rightShade

    -- divider on the band's top edge, like the ready check frame
    local divider = popup:CreateTexture(nil, "ARTWORK", nil, 2)
    divider:SetTexture(LEVEL_REWARD_SEPARATOR)
    divider:SetHeight(2)
    divider:SetPoint("TOPLEFT", middleShade, "TOPLEFT", 0, 0)
    divider:SetPoint("TOPRIGHT", middleShade, "TOPRIGHT", 0, 0)
    popup.gwDivider = divider
end

local function gwSetStaticPopupSize()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]
        StaticPopup.AlertIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/warning-icon.png")
        if _G["StaticPopup" .. i .. "ItemFrameNameFrame"] then
            _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:SetTexture(nil)
            _G["StaticPopup" .. i .. "ItemFrame"].IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
            _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            _G["StaticPopup" .. i .. "ItemFrameNormalTexture"]:SetTexture(nil)
        else
            StaticPopup.ItemFrame.NameFrame:SetTexture(nil)
            StaticPopup.ItemFrame.Item.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
            StaticPopup.ItemFrame.Item.icon:SetTexCoord(0.9, 0.1, 0.9, 0.1)
            StaticPopup.ItemFrame.Item.icon:GwSetInside()
        end
        StaticPopup.CloseButton:GwSkinButton(true)
        StaticPopup.CloseButton:SetSize(20, 20)
        StaticPopup.CloseButton:ClearAllPoints()
        StaticPopup.CloseButton:SetPoint("TOPRIGHT", -20, -5)
    end
end

local function ClearSetTexture(texture, tex)
    if tex ~= nil then
        texture:SetTexture()
    end
end

local function LoadStaticPopupSkin()
    if not GW.settings.STATICPOPUP_SKIN_ENABLED then return end

    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:GwCreateBackdrop()
        if not GW.Retail then
            StaticPopup:GwStripTextures()
        end
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()
        if StaticPopup.Border then
            StaticPopup.Border:Hide()
        end

        if StaticPopup.BG then
            StaticPopup.BG:Hide()
        end

        local tex = StaticPopup:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("TOPLEFT", StaticPopup, "TOPLEFT", 0, 0)
        tex:SetPoint("BOTTOMRIGHT", StaticPopup, "BOTTOMRIGHT", 0, 0)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
        StaticPopup.tex = tex

        -- message text in the ready check look
        local text = StaticPopup.text or _G["StaticPopup" .. i .. "Text"]
        if text then
            text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            text:SetTextColor(0.92, 0.88, 0.78, 1)
            text:SetShadowOffset(1, -1)
        end

        --Style Buttons (ready check style; confirm/cancel coloring is applied on show)
        local button1, button2, button3, button4, extraButton
        if StaticPopup.ButtonContainer then
            button1 = StaticPopup.ButtonContainer.Button1
            button2 = StaticPopup.ButtonContainer.Button2
            button3 = StaticPopup.ButtonContainer.Button3
            button4 = StaticPopup.ButtonContainer.Button4
            extraButton = StaticPopup.ExtraButton
        else
            button1 = StaticPopup.button1
            button2 = StaticPopup.button2
            button3 = StaticPopup.button3
            button4 = StaticPopup.button4
            extraButton = StaticPopup.extraButton
        end

        StaticPopup.gwPopupButtons = {button1, button2, button3, button4}
        for _, button in ipairs(StaticPopup.gwPopupButtons) do
            StyleStaticPopupButton(button)
        end
        StyleStaticPopupButton(extraButton)

        -- ready check style divider and footer shade behind the button row
        GW.CreatePopupPanelDecoration(StaticPopup, button1)

        StaticPopup:HookScript("OnShow", UpdatePopupButtonSchemes)

        StaticPopup.Dropdown:GwHandleDropDownBox()

        GW.SkinTextBox(_G["StaticPopup" .. i .. "MoneyInputFrameGoldMiddle"], _G["StaticPopup" .. i .. "MoneyInputFrameGoldLeft"], _G["StaticPopup" .. i .. "MoneyInputFrameGoldRight"], nil, nil, 5)
        GW.SkinTextBox(_G["StaticPopup" .. i .. "MoneyInputFrameSilverMiddle"], _G["StaticPopup" .. i .. "MoneyInputFrameSilverLeft"], _G["StaticPopup" .. i .. "MoneyInputFrameSilverRight"], nil, nil, 5, -10)
        GW.SkinTextBox(_G["StaticPopup" .. i .. "MoneyInputFrameCopperMiddle"], _G["StaticPopup" .. i .. "MoneyInputFrameCopperLeft"], _G["StaticPopup" .. i .. "MoneyInputFrameCopperRight"], nil, nil, 5, -10)

        local editbox = StaticPopup.editBox or StaticPopup.EditBox
        if editbox.NineSlice then
            editbox.NineSlice:GwStripTextures()
        end
        editbox:SetFrameLevel(editbox:GetFrameLevel() + 1)
        editbox:SetPoint("TOPLEFT", -2, -4)
        editbox:SetPoint("BOTTOMRIGHT", 2, 4)
        GW.SkinTextBox(_G["StaticPopup" .. i .. "EditBoxMid"], _G["StaticPopup" .. i .. "EditBoxLeft"], _G["StaticPopup" .. i .. "EditBoxRight"], nil, nil, 5, nil, nil, editbox)

        if _G["StaticPopup" .. i .. "ItemFrameNameFrame"] then
            _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:GwKill()
            _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:SetTexCoord(0.9, 0.1, 0.9, 0.1)
            _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:GwSetInside()
        else
            StaticPopup.ItemFrame.NameFrame:GwKill()
            StaticPopup.ItemFrame.Item.icon:SetTexCoord(0.9, 0.1, 0.9, 0.1)
            StaticPopup.ItemFrame.Item.icon:GwSetInside()
        end

        local itemFrame = StaticPopup.ItemFrame
        itemFrame:GwStyleButton()
        if itemFrame.Item then
            GW.HandleIcon(itemFrame.Item.icon, true, GW.BackdropTemplates.ColorableBorderOnly)
            GW.HandleIconBorder(itemFrame.Item.IconBorder, itemFrame.Item.icon.backdrop)
        else
            GW.HandleIcon(itemFrame.icon, true, GW.BackdropTemplates.ColorableBorderOnly)
            GW.HandleIconBorder(itemFrame.IconBorder, itemFrame.icon.backdrop)
        end

        local normTex = itemFrame.GetNormalTexture and itemFrame:GetNormalTexture()
        if normTex then
            normTex:SetTexture()
            hooksecurefunc(normTex, "SetTexture", ClearSetTexture)
        end
    end

    hooksecurefunc("StaticPopup_OnUpdate", gwSetStaticPopupSize)

    --Movie skip Frame
    hooksecurefunc("CinematicFrame_UpdateLettboxForAspectRatio", function(self)
        if self and self.closeDialog and not self.closeDialog.tex then
            self.closeDialog.Border:Hide()

            local tex = self.closeDialog:CreateTexture(nil, "BACKGROUND")
            tex:SetPoint("TOPLEFT", self.closeDialog, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", self.closeDialog, "BOTTOMRIGHT", 0, 0)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
            self.closeDialog.tex = tex

            local dialogName = self.closeDialog.GetName and self.closeDialog:GetName()
            local closeButton = self.closeDialog.ConfirmButton or (dialogName and _G[dialogName .. "ConfirmButton"])
            local resumeButton = self.closeDialog.ResumeButton or (dialogName and _G[dialogName .. "ResumeButton"])
            if closeButton then
                closeButton:GwSkinButton(false, true)
            end
            if resumeButton then
                resumeButton:GwSkinButton(false, true)
            end
        end
    end)

    hooksecurefunc("MovieFrame_PlayMovie", function(self)
        if self and self.CloseDialog and not self.CloseDialog.tex then
            self.CloseDialog.Border:Hide()

            local tex = self.CloseDialog:CreateTexture(nil, "BACKGROUND")
            tex:SetPoint("TOPLEFT", self.closeDialog, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", self.closeDialog, "BOTTOMRIGHT", 0, 0)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
            self.CloseDialog.tex = tex

            self.CloseDialog.ConfirmButton:GwSkinButton(false, true)
            self.CloseDialog.ResumeButton:GwSkinButton(false, true)
        end
    end)
end
GW.LoadStaticPopupSkin = LoadStaticPopupSkin