local _, GW = ...

local function HandleMirrorTimer(timer)
	local i = 1
	local frame = MirrorTimer1
	while frame do
		if not frame.atlasHolder then
			frame.atlasHolder = CreateFrame("Frame", nil, frame)
			frame.atlasHolder:SetClipsChildren(true)
			frame.atlasHolder:SetInside()

			frame.StatusBar:SetParent(frame.atlasHolder)
			frame.StatusBar:ClearAllPoints()
			frame.StatusBar:SetSize(204, 22)
			frame.StatusBar:SetPoint('TOP', 0, 2)
			--frame.StatusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/units/castingbarsDF")
			--frame.StatusBar:GetStatusBarTexture():SetTexCoord(GW.CASTINGBAR_TEXTURES[timer].NORMAL.L, GW.CASTINGBAR_TEXTURES[timer].NORMAL.R, GW.CASTINGBAR_TEXTURES[timer].NORMAL.T, GW.CASTINGBAR_TEXTURES[timer].NORMAL.B)
			frame:SetSize(200, 18)

			frame.Text:ClearAllPoints()
			frame.Text:SetParent(frame.StatusBar)
			frame.Text:SetPoint("CENTER", frame.StatusBar, 0, 1)
		end

		frame:StripTextures()
		frame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

		i = i + 1
		frame = _G['MirrorTimer' ..i]
	end
end

local function LoadMirrorTimers()
	local i = 1
	local frame = MirrorTimer1
	while frame do
		GW.RegisterMovableFrame(frame,  GW.L["MirrorTimer"] .. i, frame:GetName(), "VerticalActionBarDummy", nil, {"default"})
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", frame.gwMover)

		-- temp beta thing need to be removed with 6.0.0 TODO
		local profiles = GW.GetSettingsProfiles()
		for k, _ in pairs(profiles) do
			if profiles[k] then
				if profiles[k]["MirrorTimer" ..i] then
					GW2UI_SETTINGS_PROFILES[k]["MirrorTimer" ..i] = nil
				end
			end
		end
		GW.SetSetting("MirrorTimer" .. i, nil)
		--

		i = i + 1
		frame = _G["MirrorTimer" .. i]
	end

	hooksecurefunc("MirrorTimer_Show", HandleMirrorTimer)
end
GW.LoadMirrorTimers = LoadMirrorTimers