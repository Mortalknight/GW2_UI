local _, GW = ...

local function Construct_NameText(frame)
    local name = GW.CreateRaisedText(frame.RaisedElementParent)

    name:SetShadowOffset(-1, -1)
    name:SetShadowColor(0, 0, 0, 1)
    name:SetJustifyH("LEFT")
    name:SetFont(UNIT_NAME_FONT, 12)

	name:SetPoint('TOPLEFT', frame.Health, "TOPLEFT", 2, -2)
    name:SetPoint('TOPRIGHT', frame.Health, "TOPRIGHT", -2, -2)

	return name
end
GW.Construct_NameText = Construct_NameText

local function UpdateNameSettings(frame)
    local name = frame.Name
    frame:Tag(name, ("[GW2_Grid:mainTank][GW2_Grid:leaderIcon][GW2_Grid:assistIcon][GW2_Grid:roleIcon][name][GW2_Grid:realmFlag(%s)]"):format(frame.showRealmFlags))
end
GW.UpdateNameSettings = UpdateNameSettings