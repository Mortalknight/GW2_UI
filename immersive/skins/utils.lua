local _, GW = ...
GW.skins = {}

local function addHoverToButton(self)
    if not self.hover then
        local hover = self:CreateTexture("hover", "ARTWORK")
        hover:SetPoint("LEFT", self, "LEFT")
        hover:SetPoint("TOP", self, "TOP")
        hover:SetPoint("BOTTOM", self, "BOTTOM")
        hover:SetPoint("RIGHT", self, "RIGHT")
        hover:SetTexture("Interface/AddOns/GW2_UI/textures/button_hover")
        self.hover = hover
        self.hover:SetAlpha(0)

        self:SetScript("OnEnter", GwStandardButton_OnEnter)
        self:SetScript("OnLeave", GwStandardButton_OnLeave)
    end
end
GW.skins.addHoverToButton = addHoverToButton

local constBackdropFrame = {
	bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
	edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
	tile = false,
	tileSize = 64,
	edgeSize = 32,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrame = constBackdropFrame

local constBackdropFrameBorder = {
	bgFile = "",
	edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
	tile = false,
	tileSize = 64,
	edgeSize = 32,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrameBorder = constBackdropFrameBorder

local function SkinButton(button, isXButton, setTextColor, onlyHover)
    if not button or button.isSkinned then return end

    if not onlyHover then
        if isXButton then
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
            if button.SetHighlightTexture then button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover") end
            if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover") end
            if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
        else
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button") end
            if button.SetHighlightTexture then 
                button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
                button:GetHighlightTexture():SetVertexColor(0, 0, 0)
            end
            if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button") end
            if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/button_disable") end
        end

        if setTextColor then
            --button:SetTextColor(0, 0, 0, 1)
            --button:SetShadowOffset(0, 0)
            if button.Text then
                button.Text:SetTextColor(0, 0, 0, 1)
                button.Text:SetShadowOffset(0, 0)
            end

            local r = {button:GetRegions()}
            for _,c in pairs(r) do
                if c:GetObjectType() == "FontString" then
                    c:SetTextColor(0, 0, 0, 1)
                    c:SetShadowOffset(0, 0)
                end
            end
        end
    end

    if not isXButton or onlyHover then
        addHoverToButton(button)
    end

	button.isSkinned = true
end
GW.skins.SkinButton = SkinButton

local function SkinCheckButton(button)
    if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetCheckedTexture then button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/checkboxchecked") end
    if button.SetDisabledCheckedTexture then button:SetDisabledCheckedTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
end
GW.skins.SkinCheckButton = SkinCheckButton

local function SkinDropDownMenu(self)
    if self.Left then self.Left:Hide() end
    if self.Middle then self.Middle:Hide() end
    if self.Right then self.Right:Hide() end

    if self.Button then
        self.Button.NormalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        self.Button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        self.Button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        self.Button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    end

    if self.Left and self.Right then
        local tex = self:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", self, "TOP", 0, 0)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar")
        tex:SetPoint("TOPLEFT", self.Left, "BOTTOMRIGHT", 0, 23)
        tex:SetPoint("BOTTOMRIGHT", self.Right, "TOPLEFT", 10, -20)
        tex:SetVertexColor(0, 0, 0)
        self.tex = tex
    end
end
GW.skins.SkinDropDownMenu = SkinDropDownMenu

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_Initialize", SkinDropDownMenu)
end
GW.SkinUIDropDownMenu = SkinUIDropDownMenu

local function SkinDropDownList_OnShow(self)
    _G[self:GetName() .. "Backdrop"]:Hide()
    _G[self:GetName() .. "MenuBackdrop"]:Hide()
    self:SetBackdrop(constBackdropFrame)
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        if _G[self:GetName() .. "Button" .. i .. "ExpandArrow"] then
            _G[self:GetName() .. "Button" .. i .. "ExpandArrow"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
        end
    end
    --Check if Raider.IO Entry is added
    if IsAddOnLoaded("RaiderIO") and RaiderIO_CustomDropDownList then
        _G["RaiderIO_CustomDropDownListMenuBackdrop"]:Hide()
        _G["RaiderIO_CustomDropDownList"]:SetBackdrop(constBackdropFrame)
    end
end

local function SkinDropDownList()
    hooksecurefunc("UIDropDownMenu_OnShow", SkinDropDownList_OnShow)
end
GW.SkinDropDownList = SkinDropDownList