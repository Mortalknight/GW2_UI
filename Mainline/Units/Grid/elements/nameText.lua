local _, GW = ...

local function Construct_NameText(frame)
    local name = GW.CreateRaisedText(frame.RaisedElementParent)

    name:SetShadowOffset(-1, -1)
    name:SetShadowColor(0, 0, 0, 1)
    name:SetJustifyH("LEFT")
    name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)


    return name
end
GW.Construct_NameText = Construct_NameText

local function UpdateNameSettings(frame)
    local name = frame.Name


    name:ClearAllPoints()
    name:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    name:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)

    frame:Tag(name, ("[GW2_Grid:mainTank(%s)][GW2_Grid:leaderIcon(%s)][GW2_Grid:assistIcon(%s)][GW2_Grid:roleIcon(%s)][GW2_Grid:name] [GW2_Grid:realmFlag(%s)]"):format(tostring(frame.showTankIcon), tostring(frame.showLeaderAssistIcon), tostring(frame.showLeaderAssistIcon), tostring(frame.showRoleIcon), frame.showRealmFlags))
    --frame:Tag(name, "[GW2_Grid:name]")
end
GW.UpdateNameSettings = UpdateNameSettings