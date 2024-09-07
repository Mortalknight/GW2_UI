local _, GW = ...

local function LoadMiscBlizzardFrameSkins()
    if not GW.settings.MISC_SKIN_ENABLED then return end

    GW.LoadTimerTrackerSkin()
    GW.LoadGhostFrameSkin()

    OpacityFrame:GwStripTextures()
	OpacityFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    OpacityFrameSlider:GwSkinSliderFrame()
end
GW.LoadMiscBlizzardFrameSkins = LoadMiscBlizzardFrameSkins