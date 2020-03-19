local _, GW = ...

local function SkinUIDropDownMenu_Initialize(self)
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

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_Initialize", SkinUIDropDownMenu_Initialize)
end
GW.SkinUIDropDownMenu = SkinUIDropDownMenu