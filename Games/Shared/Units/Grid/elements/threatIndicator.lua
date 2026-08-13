---@class GW2
local GW = select(2, ...)

local function unitExists(unit)
	return unit and (UnitExists(unit) or UnitIsVisible(unit))
end

local function Update(self, event, unit)
    if(unit ~= self.__unit) then return end

	local element = self.ThreatIndicator

    local feedbackUnit = element.feedbackUnit
	unit = unit or self.__unit

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

local function Construct_ThreatIndicator(frame)
    local threatIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "BORDER")
    threatIndicator:SetPoint("TOPLEFT", frame, 0, 0)
    threatIndicator:SetPoint("BOTTOMRIGHT", frame, 0, 0)
    threatIndicator:SetTexture("Interface/AddOns/GW2_UI/textures/party/aggroborder.png")

    threatIndicator.Override = Update


	return threatIndicator
end
GW.Construct_ThreatIndicator = Construct_ThreatIndicator

local function UpdateThreatIndicatorSettings(frame)
    -- nothing atm
end
GW.UpdateThreatIndicatorSettings = UpdateThreatIndicatorSettings