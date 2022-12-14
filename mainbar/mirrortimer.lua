local _, GW = ...

local function HandleMirrorTimer()
	local i = 1
	local frame = MirrorTimer1
	while frame do
		if not frame.atlasHolder then
			frame.atlasHolder = CreateFrame("Frame", nil, frame)
			frame.atlasHolder:SetClipsChildren(true)
			frame.atlasHolder:SetInside()

			frame.StatusBar:SetParent(frame.atlasHolder)
			frame.StatusBar:ClearAllPoints()
			frame.StatusBar:SetSize(200, 18)
			frame.StatusBar:SetPoint("TOP", 0, 2)
			frame:SetSize(200, 18)

			frame.Text:ClearAllPoints()
			frame.Text:SetParent(frame.StatusBar)
			frame.Text:SetPoint("CENTER", frame.StatusBar, 0, 1)
		end

		frame:StripTextures()
		frame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

		i = i + 1
		frame = _G["MirrorTimer" .. i]
	end
end

local function LoadMirrorTimers()
	for i = 1, 3 do
		local frame = _G["MirrorTimer" .. i]
		GW.RegisterMovableFrame(frame, GW.L["MirrorTimer"] .. i, "MirrorTimer" .. i, "VerticalActionBarDummy", {200, 18}, {"default"})
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", frame.gwMover)

		-- remove wrong anchor point for DB in Profiles and Layout frames
		local profiles = GW.GetSettingsProfiles()
		for k, _ in pairs(profiles) do
			if profiles[k] then
				if profiles[k]["MirrorTimer" ..i] and profiles[k]["MirrorTimer" ..i].anchor then
					GW2UI_SETTINGS_PROFILES[k]["MirrorTimer" ..i].anchor = nil
				end
			end
		end
		--private layouts
		if GW2UI_SETTINGS_DB_03["MirrorTimer" ..i] and GW2UI_SETTINGS_DB_03["MirrorTimer" ..i].anchor then
			GW2UI_SETTINGS_DB_03["MirrorTimer" ..i].anchor = nil
		end
		local layouts = GW.GetAllLayouts()
		for k, _ in pairs(layouts) do
			if layouts[k] then
				for key, _ in pairs(layouts[k].frames) do
					if layouts[k].frames[key] and layouts[k].frames[key].settingName == "MirrorTimer" .. i and layouts[k].frames[key].point and layouts[k].frames[key].point.anchor then
						GW2UI_LAYOUTS[k].frames[key].point.anchor = nil
					end
				end
			end
		end
		--
	end

	hooksecurefunc("MirrorTimer_Show", HandleMirrorTimer)
end
GW.LoadMirrorTimers = LoadMirrorTimers