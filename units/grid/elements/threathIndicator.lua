local _, GW = ...

local function unitExists(unit)
	return unit and (UnitExists(unit) or ShowBossFrameWhenUninteractable(unit))
end

local function Update(self, event, unit)
    if(unit ~= self.unit) then return end

	local element = self.ThreatIndicator

    local feedbackUnit = element.feedbackUnit
	unit = unit or self.unit

	local status
	-- BUG: Non-existent '*target' or '*pet' units cause UnitThreatSituation() errors
	if(unitExists(unit)) then
		if(feedbackUnit and feedbackUnit ~= unit and unitExists(feedbackUnit)) then
			status = UnitThreatSituation(feedbackUnit, unit)
		else
			status = UnitThreatSituation(unit)
		end
	end

    if status and status > 2 then
        element:Show()
    else
        element:Hide()
    end
end

local function Construct_ThreathIndicator(frame)
    local threatIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "BORDER")
    threatIndicator:SetPoint("TOPLEFT", frame, 0, 0)
    threatIndicator:SetPoint("BOTTOMRIGHT", frame, 0, 0)
    threatIndicator:SetTexture("Interface/AddOns/GW2_UI/textures/party/aggroborder")

    threatIndicator.Override = Update


	return threatIndicator
end
GW.Construct_ThreathIndicator = Construct_ThreathIndicator

local function UpdateThreathIndicatorSettings(frame)
    -- nothing atm
end
GW.UpdateThreathIndicatorSettings = UpdateThreathIndicatorSettings