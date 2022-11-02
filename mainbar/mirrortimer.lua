local _, GW = ...



local function LoadMirrorTimers()
    for i = 1, MIRRORTIMER_NUMTIMERS do
		local bar = _G['MirrorTimer'..i]
		local statusbar = bar.StatusBar or _G[bar:GetName() .. "StatusBar"]

		--bar:SetTemplate()
		bar:SetSize(200, 15)

		bar.Text:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
		bar.Border:Hide()

		statusbar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white")
		statusbar:SetAllPoints()

		-- temp to clean up setitngs
		local profiles = GW.GetSettingsProfiles()
		for k, _ in pairs(profiles) do
			if profiles[k] then
				if profiles[k]["MirrorTimer" ..i] then
					GW2UI_SETTINGS_PROFILES[k]["MirrorTimer" ..i] = nil
				end
			end
		end
		GW.SetSetting("MirrorTimer" .. i, nil)
        GW.RegisterMovableFrame(bar,  GW.L["MirrorTimer"] .. i, "MirrorTimer" .. i , "VerticalActionBarDummy", nil, {"default"})
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", bar.gwMover)
	end
end
GW.LoadMirrorTimers = LoadMirrorTimers