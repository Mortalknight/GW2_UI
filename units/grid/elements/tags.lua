local _, GW = ...
local LRI = GW.Libs.LRI
local REALM_FLAGS = GW.REALM_FLAGS

local stringtoboolean = {["true"] = true, ["false"] = false}

local function Create_Tags()
    GW.oUF.Tags.Methods['GW2_Grid:name'] = function(unit)
        local name = UnitName(unit)
        if name then
            return name
        end
    end
    GW.oUF.Tags.Events['GW2_Grid:name'] = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT'

    GW.oUF.Tags.Methods['GW2_Grid:leaderIcon'] = function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        if( UnitIsGroupLeader(unit)) then
            return "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:0:0:0:-2:64:64:4:60:4:60|t "
        end
    end
    GW.oUF.Tags.Events['GW2_Grid:leaderIcon'] = 'PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE'

    GW.oUF.Tags.Methods['GW2_Grid:assistIcon'] = function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        if( UnitIsGroupAssistant(unit)) then
            return"|TInterface/AddOns/GW2_UI/textures/party/icon-assist:0:0:0:-2:64:64:4:60:4:60|t "
        end
    end
    GW.oUF.Tags.Events['GW2_Grid:assistIcon'] = 'PARTY_LEADER_CHANGED UNIT_NAME_UPDATE GROUP_ROSTER_UPDATE'

    GW.oUF.Tags.Methods['GW2_Grid:roleIcon'] = function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end

        local role = UnitGroupRolesAssigned(unit)
        if GW.nameRoleIcon[role] then
            return GW.nameRoleIcon[role]
        end
    end
    GW.oUF.Tags.Events['GW2_Grid:roleIcon'] = 'PARTY_LEADER_CHANGED UNIT_NAME_UPDATE PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE'

    GW.oUF.Tags.Methods['GW2_Grid:realmFlag'] = function(unit, realUnit, ...)
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(unit))
        local realmflag = ""
        local setting = ...
        if realmLocal and setting then
            realmflag = setting == "DIFFERENT" and GW.mylocal ~= realmLocal and REALM_FLAGS[realmLocal] or setting == "ALL" and REALM_FLAGS[realmLocal] or ""
        end

        return realmflag
    end
    GW.oUF.Tags.Events['GW2_Grid:realmFlag'] = 'PARTY_LEADER_CHANGED UNIT_NAME_UPDATE'

    GW.oUF.Tags.Methods['GW2_Grid:mainTank'] = function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end

        local name, server = UnitName(unit)
        if server and server ~= "" then
            name = string.format('%s-%s', name, server)
        end

        for i = 1, GetNumGroupMembers() do
            local raidName, _, _, _, _, _, _, _, _, role2 = GetRaidRosterInfo(i)
            if( raidName == name ) then
                if role2 == "MAINTANK" then
                    return "|TInterface/AddOns/GW2_UI/textures/party/icon-maintank:15:15:0:-2|t "
                elseif role2 == "MAINASSIST" then
                    return "|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist:15:15:0:-1|t "
                end
            end
        end
    end
    GW.oUF.Tags.Events['GW2_Grid:mainTank'] = 'PARTY_LEADER_CHANGED UNIT_NAME_UPDATE'

    GW.oUF.Tags.Methods['GW2_Grid:healtValue'] = function(unit, realUnit, ...)
        local healthstring = ""
        local setting = ...
        local health = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        local healthPrec = 0
        if healthMax > 0 then
            healthPrec = health / healthMax
        end

        if setting == "NONE" then
            return ""
        end
        if setting == "PREC" then
            return GW.RoundDec(healthPrec * 100, 0) .. "%"
        elseif setting == "HEALTH" then
            return GW.CommaValue(health)
        elseif setting == "LOSTHEALTH" then
            if healthMax - health > 0 then healthstring = GW.CommaValue(healthMax - health) end
            return healthstring
        end
    end
    GW.oUF.Tags.Events['GW2_Grid:healtValue'] = 'UNIT_HEALTH UNIT_MAXHEALTH'

end
GW.Create_Tags = Create_Tags