local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local SkinButton = GW.skins.SkinButton

local function SkinReadyCheckListenerFrame()
    _G.ReadyCheckListenerFrame:SetBackdrop(nil)

    SkinButton(_G.ReadyCheckFrameYesButton, false, true)
    SkinButton(_G.ReadyCheckFrameNoButton, false, true)

    local r = {_G.ReadyCheckListenerFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    _G.ReadyCheckListenerFrame:SetBackdrop(constBackdropFrame)
    _G.ReadyCheckPortrait:Show()
    _G.ReadyCheckPortrait:SetDrawLayer("OVERLAY", 2)
end
GW.SkinReadyCheckListenerFrame = SkinReadyCheckListenerFrame