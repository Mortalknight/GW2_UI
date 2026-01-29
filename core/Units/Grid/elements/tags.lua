local _, GW = ...
local LRI = GW.Libs.LRI
local REALM_FLAGS = GW.REALM_FLAGS

local stringtoboolean = {["true"] = true, ["false"] = false}

local function AddTag(tagName, events, func)
    GW.oUF.Tags.Events[tagName] = events
    GW.oUF.Tags.Methods[tagName] = func
end

local function Create_Tags()
    AddTag("GW2_Grid:name", "UNIT_NAME_UPDATE", function(unit, realunit)
        return UnitName(realunit or unit)
    end)

    AddTag("GW2_Grid:leaderIcon", "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE", function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        if( UnitIsGroupLeader(unit)) then
            return "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader.png:0:0:0:-2:64:64:4:60:4:60|t "
        end
    end)

    AddTag("GW2_Grid:assistIcon", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE GROUP_ROSTER_UPDATE", function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        if( UnitIsGroupAssistant(unit)) then
            return"|TInterface/AddOns/GW2_UI/textures/party/icon-assist.png:0:0:0:-2:64:64:4:60:4:60|t "
        end
    end)

    AddTag("GW2_Grid:roleIcon", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE" ,function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end

        local role = UnitGroupRolesAssigned(unit)
        if GW.nameRoleIcon[role] then
            return GW.nameRoleIcon[role]
        end
    end)

    AddTag("GW2_Grid:realmFlag", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE", function(unit, realUnit, ...)
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(unit))
        local realmflag = ""
        local setting = ...
        if realmLocal and setting then
            realmflag = setting == "DIFFERENT" and GW.mylocal ~= realmLocal and REALM_FLAGS[realmLocal] or setting == "ALL" and REALM_FLAGS[realmLocal] or ""
        end

        return realmflag
    end)

    AddTag("GW2_Grid:mainTank", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE", function(unit, realUnit, ...)
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
                    return "|TInterface/AddOns/GW2_UI/textures/party/icon-maintank.png:15:15:0:-2|t "
                elseif role2 == "MAINASSIST" then
                    return "|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist.png:15:15:0:-1|t "
                end
            end
        end
    end)

    AddTag("GW2_Grid:healtValue", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit, realUnit, ...)
        local healthDisplaySetting, shortendHealthValue = ...
        local formatFunc

        shortendHealthValue = stringtoboolean[shortendHealthValue]

        if GW.Retail then
            formatFunc = shortendHealthValue and AbbreviateNumbers or BreakUpLargeNumbers
        else
            formatFunc = shortendHealthValue and GW.ShortValue or GW.GetLocalizedNumber
        end

        if healthDisplaySetting == "NONE" then
            return ""
        end
        if healthDisplaySetting == "PREC" then
            if GW.Retail then
                return string.format("%.0f%%", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))
            else
                local healthMax = UnitHealthMax(unit)
                local healthPrecentage = (healthMax > 0) and (UnitHealth(unit) / healthMax) or 0
                return GW.RoundDec(healthPrecentage * 100, 0) .. "%"
            end
        elseif healthDisplaySetting == "HEALTH" then
            return formatFunc(UnitHealth(unit))
        elseif healthDisplaySetting == "LOSTHEALTH" then
            if GW.Retail then
                return formatFunc(UnitHealthMissing(unit))
            else
                local healthMax = UnitHealthMax(unit)
                local health = UnitHealth(unit)
                if (healthMax - health) > 0 then
                    return formatFunc(healthMax - health)
                end
                return ""
            end
        end

        return ""
    end)
end
GW.Create_Tags = Create_Tags