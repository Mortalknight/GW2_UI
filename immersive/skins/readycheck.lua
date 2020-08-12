local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinReadyCheck()
    _G.ReadyCheckListenerFrame:CreateBackdrop(nil)

    _G.ReadyCheckFrameYesButton:SkinButton(false, true)
    _G.ReadyCheckFrameNoButton:SkinButton(false, true)

    local r = {_G.ReadyCheckListenerFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    _G.ReadyCheckListenerFrame:CreateBackdrop(constBackdropFrame)
    _G.ReadyCheckPortrait:Show()
    _G.ReadyCheckPortrait:SetDrawLayer("OVERLAY", 2)
end
GW.SkinReadyCheck = SkinReadyCheck