local _, GW = ...

local function SkinTimerTrackerFrame_OnShow(self)
    local Frame = _G[self:GetName() .. "StatusBar"]
    if Frame then
        Frame:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
        _G[Frame:GetName() .. "Border"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
        _G[Frame:GetName() .. "Border"]:SetSize(199, 14)
        _G[Frame:GetName() .. "Border"]:ClearAllPoints()
        _G[Frame:GetName() .. "Border"]:SetPoint(Frame:GetPoint())
    end
end

local function LoadTimerTrackerSkin()
    hooksecurefunc("StartTimer_SetGoTexture", SkinTimerTrackerFrame_OnShow)
end
GW.LoadTimerTrackerSkin = LoadTimerTrackerSkin