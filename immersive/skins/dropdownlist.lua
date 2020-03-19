local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

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