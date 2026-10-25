---@class GW2
local GW = select(2, ...)

local function Construct_HealthValueText(frame)
    local healthValue = GW.CreateRaisedText(frame.RaisedElementParent)

    healthValue:SetShadowOffset(-1, -1)
    healthValue:SetShadowColor(0, 0, 0, 1)
    healthValue:SetJustifyH("LEFT")
    healthValue:SetFont(UNIT_NAME_FONT, 11)

	healthValue:SetPoint('TOPLEFT', frame.Name, "BOTTOMLEFT", 2, 0)

	return healthValue
end
GW.Construct_HealthValueText = Construct_HealthValueText

local function UpdateHealthValueTextSettings(frame)
    local name = frame.HealthValueText
    frame:Tag(name, frame.healthTagString)
end
GW.UpdateHealthValueTextSettings = UpdateHealthValueTextSettings