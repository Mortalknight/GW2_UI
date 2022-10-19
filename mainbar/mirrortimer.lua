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

        GW.RegisterMovableFrame(bar,  GW.L["MirrorTimer"] .. i, "MirrorTimer" .. i , "VerticalActionBarDummy", nil, {"default"})
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", bar.gwMover)
	end
end
GW.LoadMirrorTimers = LoadMirrorTimers