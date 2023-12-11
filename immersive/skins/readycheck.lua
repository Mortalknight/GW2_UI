local _, GW = ...
local constBackdropFrame = GW.BackdropTemplates.Default

local function LoadReadyCheckSkin()
    if not GW.settings.READYCHECK_SKIN_ENABLED then return end

    _G.ReadyCheckFrameYesButton:GwSkinButton(false, true)
    _G.ReadyCheckFrameNoButton:GwSkinButton(false, true)

    ReadyCheckListenerFrame:GwStripTextures()

    _G.ReadyCheckListenerFrame:GwCreateBackdrop(constBackdropFrame)
    _G.ReadyCheckPortrait:Show()
    _G.ReadyCheckPortrait:SetDrawLayer("OVERLAY", 2)
end
GW.LoadReadyCheckSkin = LoadReadyCheckSkin