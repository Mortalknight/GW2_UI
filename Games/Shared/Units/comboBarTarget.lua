---@class GW2
local GW = select(2, ...)

local comboBar
local FADE_IN_TIME = 0.3

local function ComboFrame_Update(self)
    -- druids only have a max in cat form, it changes without an event of its own
    local maxComboPoints = UnitPowerMax(self.unit, Enum.PowerType.ComboPoints)
    local comboPoints = GetComboPoints(self.unit, "target")
    if maxComboPoints ~= self.maxComboPoints then
        self.maxComboPoints = maxComboPoints
        for i = 1, 9 do
            self["runeTex" .. i]:SetShown(i <= maxComboPoints)
            self["combo" .. i]:Hide()
        end
    end

    if comboPoints > 0 and UnitExists("target") then
        if not self:IsShown() then
			self:Show()
			UIFrameFadeIn(self, FADE_IN_TIME, 0, 1)
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

local function ToggleComboEvents(self, enable)
    if enable then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", "vehicle")
        self:RegisterUnitEvent("UNIT_MAXPOWER", "player", "vehicle")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
    else
        self:UnregisterEvent("PLAYER_TARGET_CHANGED")
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end

local function comboBarOnEvent(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
		ComboFrame_Update(self)
	elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
		if ... == self.unit then
			ComboFrame_Update(self)
		end
	elseif event == "UNIT_ENTERED_VEHICLE" then
        if not GW.settings.unitframes.target.hookComboPoints then
            ToggleComboEvents(self, true)
        end

		self.unit = "vehicle"
		ComboFrame_Update(self)
    elseif event == "UNIT_EXITED_VEHICLE" then
        if not GW.settings.unitframes.target.hookComboPoints then
            ToggleComboEvents(self, false)
        end

		self.unit = "player"
		ComboFrame_Update(self)
	end
end

local function UpdateSettings(targetFrame)
    local castBar = targetFrame.castingbar or targetFrame.castingbarNormal
    comboBar:ClearAllPoints()
    if targetFrame.frameInvert then
        comboBar:SetPoint("TOPRIGHT", castBar, "TOPRIGHT", 0, -13)
    else
        comboBar:SetPoint("TOPLEFT", castBar, "TOPLEFT", 0, -13)
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

    if GW.settings.unitframes.target.hookComboPoints then
        ToggleComboEvents(comboBar, true)

        ComboFrame_Update(comboBar)
    else
        -- only check vehicle stuff
        comboBar:Hide()
        ToggleComboEvents(comboBar, false)
    end
end
GW.UpdateComboBarOnTargetFrame = UpdateSettings

-- the target frame calls this on every settings change, the bar is only created once
local function LoadComboBarOnTargetFrame(targetFrame)
    if not comboBar then
        comboBar = CreateFrame("Frame", nil, UIParent, "GWTargetClassPower")
        comboBar.unit = "player"
        comboBar.gwPower = 0
        comboBar:SetScript("OnEvent", comboBarOnEvent)
        comboBar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
        comboBar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    end

    UpdateSettings(targetFrame)
end
GW.LoadComboBarOnTargetFrame = LoadComboBarOnTargetFrame