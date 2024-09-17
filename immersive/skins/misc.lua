local _, GW = ...

local function LoadMiscBlizzardFrameSkins()
    if not GW.settings.MISC_SKIN_ENABLED then return end

    GW.LoadTimerTrackerSkin()
    GW.LoadGhostFrameSkin()

    OpacityFrame:GwStripTextures()
    OpacityFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    OpacityFrameSlider:GwSkinSliderFrame()

    -- Basic Message Dialog
    if BasicMessageDialog then
        BasicMessageDialog:GwStripTextures()
        BasicMessageDialog:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
        BasicMessageDialogButton:GwSkinButton(false, true)
    end

    -- SplashFrame (Whats New)
    SplashFrame.TopCloseButton:GwSkinButton(true)
    SplashFrame.BottomCloseButton:GwSkinButton(false, true)
end
GW.LoadMiscBlizzardFrameSkins = LoadMiscBlizzardFrameSkins