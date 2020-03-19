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