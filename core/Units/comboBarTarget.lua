local _, GW = ...

local comboBar

local function ComboFrame_Update(self)
    if not self.maxComboPoints then
		-- This can happen if we are showing combo points on the player frame (which doesn't use ComboFrame) and we exit a vehicle.
		return
	end

    local comboPoints = GetComboPoints(self.unit, "target")

    if comboPoints > 0 and UnitExists("target") then
        if not self:IsShown() then
			self:Show()
			UIFrameFadeIn(self, COMBOFRAME_FADE_IN, 0, 1)
		end

        local chargedPowerPoints = GetUnitChargedPowerPoints and GetUnitChargedPowerPoints("player") or {}
        local showPoint = false
        local old_power = self.gwPower
        self.gwPower = comboPoints

        if self.maxComboPoints == 6 or self.maxComboPoints == 9 then
            self.showExtraPoint = 7
        else
            self.showExtraPoint = self.maxComboPoints
        end


        for i = 1, self.showExtraPoint do
            local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i)
            if isCharged then
                self["combo" .. i]:SetTexCoord(0, 0.5, 0.5, 1)
            else
                self["combo" .. i]:SetTexCoord(0.5, 1, 0.5, 0)
            end

            if i >= self.showExtraPoint and comboPoints >= self.showExtraPoint then -- only show the extra point if we have it
                showPoint = true
            elseif i >= self.showExtraPoint and comboPoints < self.showExtraPoint then
                showPoint = false
            elseif i < self.showExtraPoint and comboPoints >= i then
                showPoint = true
            else
                showPoint = false
            end

            self["runeTex" .. i]:SetShown((i < self.showExtraPoint or i <= self.maxComboPoints or showPoint))
            self["combo" .. i]:SetShown(showPoint)
            self.comboFlare:ClearAllPoints()
            self.comboFlare:SetPoint("CENTER", self["combo" .. i], "CENTER", 0, 0)
            if comboPoints > old_power then
                self.comboFlare:SetShown(showPoint)
                if showPoint then
                    GW.AddToAnimation(
                        "COMBOPOINTS_FLARE",
                        0,
                        5,
                        GetTime(),
                        0.5,
                        function(p)
                            p = math.min(1, math.max(0, p))
                            self.comboFlare:SetAlpha(p)
                        end,
                        nil,
                        function()
                            self.comboFlare:Hide()
                        end
                    )
                end
            end
        end
    else
        self:Hide()
    end
end

local function ComboFrame_UpdateMax(self)
	self.maxComboPoints = UnitPowerMax(self.unit, Enum.PowerType.ComboPoints)

	-- First hide all combo points
	for i = 1, 9 do
        self["runeTex" .. i]:SetShown(i <= self.maxComboPoints)
        self["combo" .. i]:Hide()
    end

	ComboFrame_Update(self)
end

local function comboBarOnEvent(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
		ComboFrame_Update(self);
	elseif event == "UNIT_POWER_FREQUENT" then
		local unit = ...
		if unit == self.unit then
			ComboFrame_Update(self)
		end
	elseif event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" then
		ComboFrame_UpdateMax(self)
	elseif event == "UNIT_ENTERED_VEHICLE" then
        if not GW.settings.target_HOOK_COMBOPOINTS then
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("UNIT_POWER_FREQUENT")
            self:RegisterEvent("UNIT_MAXPOWER")
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
        end

		self.unit = "vehicle"
		ComboFrame_UpdateMax(self)
    elseif event == "UNIT_EXITED_VEHICLE" then
        if not GW.settings.target_HOOK_COMBOPOINTS then
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("UNIT_POWER_FREQUENT")
            self:UnregisterEvent("UNIT_MAXPOWER")
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end

		self.unit = "player"
		ComboFrame_UpdateMax(self)
	end
end

local function UpdateSettings(targetFrame)
    comboBar:ClearAllPoints()
    if targetFrame.frameInvert then
        comboBar:SetPoint("TOPRIGHT", targetFrame.castingbar, "TOPRIGHT", 0, -13)
    else
        comboBar:SetPoint("TOPLEFT", targetFrame.castingbar, "TOPLEFT", 0, -13)
    end

    local point = 0
    local anchorPoint = targetFrame.frameInvert and "RIGHT" or "LEFT"
    for i = 1, 9 do
        comboBar["runeTex" .. i]:ClearAllPoints()
        comboBar["combo" .. i]:ClearAllPoints()
        comboBar["runeTex" .. i]:SetPoint(anchorPoint, comboBar, anchorPoint, point, 0)
        comboBar["combo" .. i]:SetPoint(anchorPoint, comboBar, anchorPoint, point, 0)

        if targetFrame.frameInvert then
            point = point - 32
        else
            point = point + 32
        end
    end

    if GW.settings.target_HOOK_COMBOPOINTS then
        comboBar:RegisterEvent("PLAYER_TARGET_CHANGED")
        comboBar:RegisterEvent("UNIT_POWER_FREQUENT")
        comboBar:RegisterEvent("UNIT_MAXPOWER")
        comboBar:RegisterEvent("PLAYER_ENTERING_WORLD")

        ComboFrame_UpdateMax(comboBar)
    else
        -- only check vehicle stuff
        comboBar:Hide()
        comboBar:UnregisterEvent("PLAYER_TARGET_CHANGED")
        comboBar:UnregisterEvent("UNIT_POWER_FREQUENT")
        comboBar:UnregisterEvent("UNIT_MAXPOWER")
        comboBar:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end
GW.UpdateComboBarOnTargetFrame = UpdateSettings

local function LoadComboBarOnTargetFrame(targetFrame)
    comboBar = CreateFrame("Frame", nil, UIParent, "GWTargetClassPower")

    comboBar.unit = "player"
    comboBar.gwPower = 0

    UpdateSettings(targetFrame)

    comboBar:SetScript("OnEvent", comboBarOnEvent)

	comboBar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
	comboBar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
end
GW.LoadComboBarOnTargetFrame = LoadComboBarOnTargetFrame