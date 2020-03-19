local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function UIDropDownMenu_OnUpdate(self)
    _G[self:GetName() .. "Backdrop"]:Hide()
    _G[self:GetName() .. "MenuBackdrop"]:Hide()
    self:SetBackdrop(constBackdropFrame)
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        if _G[self:GetName() .. "Button" .. i .. "ExpandArrow"] then
            _G[self:GetName() .. "Button" .. i .. "ExpandArrow"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
        end
    end
end

local function SkinDropDownList()
    hooksecurefunc("UIDropDownMenu_OnUpdate", UIDropDownMenu_OnUpdate)
end
GW.SkinDropDownList = SkinDropDownList