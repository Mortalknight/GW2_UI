---@class GW2
local GW = select(2, ...)
local LRI = GW.Libs.LRI
local REALM_FLAGS = GW.REALM_FLAGS

local stringtoboolean = {["true"] = true, ["false"] = false}

local ICONS = {
    leader = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader.png:0:0:0:-2:64:64:4:60:4:60|t",
    assist = "|TInterface/AddOns/GW2_UI/textures/party/icon-assist.png:0:0:0:-2:64:64:4:60:4:60|t",
    mainTank = "|TInterface/AddOns/GW2_UI/textures/party/icon-maintank.png:15:15:0:-2|t",
    mainAssist = "|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist.png:15:15:0:-1|t",
}
GW.GridTagIcons = ICONS

local function AddTag(tagName, events, func)
    GW.oUF.Tags.Events[tagName] = events
    GW.oUF.Tags.Methods[tagName] = func
end

local function Create_Tags()
    AddTag("GW2_Grid:name", "UNIT_NAME_UPDATE", function(unit, realunit)
        return GW.GetUnitDisplayName(realunit or unit, UnitName)
    end)

    AddTag("GW2_Grid:leaderIcon", "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE", function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        local isLeader = UnitIsGroupLeader(realUnit or unit)
        if( GW.NotSecretValue(isLeader) and isLeader) then
            return ICONS.leader
        end
    end)

    AddTag("GW2_Grid:assistIcon", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE GROUP_ROSTER_UPDATE", function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        local isAssistant = UnitIsGroupAssistant(realUnit or unit)
        if( GW.NotSecretValue(isAssistant) and isAssistant) then
            return ICONS.assist
        end
    end)

    AddTag("GW2_Grid:roleIcon", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE" ,function(unit, realUnit, ...)
        local setting = stringtoboolean[...]
        if not setting then return "" end
        local role = UnitGroupRolesAssigned(realUnit or unit)

        if GW.NotSecretValue(role) and GW.nameRoleIcon[role] then
            return GW.nameRoleIcon[role]
        end
    end)

    AddTag("GW2_Grid:realmFlag", "PARTY_LEADER_CHANGED UNIT_NAME_UPDATE", function(unit, realUnit, ...)
        local realmLocal = select(5, LRI:GetRealmInfoByUnit(realUnit or unit))
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

        -- asks for the unit directly, the roster scan ran over the whole raid for every name
        local isTank, isAssist = GetPartyAssignment("MAINTANK", realUnit or unit), GetPartyAssignment("MAINASSIST", realUnit or unit)
        if GW.IsSecretValue(isTank) or GW.IsSecretValue(isAssist) then return "" end
        if isTank then
            return ICONS.mainTank
        elseif isAssist then
            return ICONS.mainAssist
        end
    end)

    AddTag("GW2_Grid:healtValue", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit, realUnit, ...)
        local healthDisplaySetting, shortendHealthValue = ...
        -- like the name: config mode hands its made up member in as realUnit
        unit = realUnit or unit
        local formatFunc

        shortendHealthValue = stringtoboolean[shortendHealthValue]

        if GW.isModern then
            formatFunc = shortendHealthValue and GW.ShortValue or BreakUpLargeNumbers
        else
            formatFunc = shortendHealthValue and GW.ShortValue or GW.GetLocalizedNumber
        end

        if healthDisplaySetting == "NONE" then
            return ""
        end
        if healthDisplaySetting == "PREC" then
            if GW.isModern then
                return string.format("%.0f%%", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))
            else
                local healthMax = UnitHealthMax(unit)
                local healthPrecentage = (healthMax > 0) and (UnitHealth(unit) / healthMax) or 0
                return GW.RoundDec(healthPrecentage * 100, 0) .. "%"
            end
        elseif healthDisplaySetting == "HEALTH" then
            return formatFunc(UnitHealth(unit))
        elseif healthDisplaySetting == "MAX" then
            return formatFunc(UnitHealthMax(unit))
        elseif healthDisplaySetting == "LOSTHEALTH" then
            if GW.isModern then
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

    AddTag("GW2_Grid:power", "UNIT_POWER_UPDATE UNIT_MAXPOWER UNIT_DISPLAYPOWER", function(unit, realUnit, mode, short, mana)
        unit = realUnit or unit
        local powerType = stringtoboolean[mana] and Enum.PowerType.Mana or nil
        if mode == "PREC" then
            if GW.isModern then
                return string.format("%.0f%%", UnitPowerPercent(unit, powerType, true, CurveConstants.ScaleTo100))
            end
            local powerMax = UnitPowerMax(unit, powerType)
            return GW.RoundDec(powerMax > 0 and UnitPower(unit, powerType) / powerMax * 100 or 0, 0) .. "%"
        end

        local formatFunc = stringtoboolean[short] and GW.ShortValue or GW.isModern and BreakUpLargeNumbers or GW.GetLocalizedNumber
        if mode == "MAX" then
            return formatFunc(UnitPowerMax(unit, powerType))
        elseif mode == "MISSING" then
            if GW.isModern then
                return formatFunc(UnitPowerMissing(unit, powerType))
            end
            return formatFunc(UnitPowerMax(unit, powerType) - UnitPower(unit, powerType))
        end
        return formatFunc(UnitPower(unit, powerType))
    end)

    AddTag("GW2:classPower", "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_AURA RUNE_POWER_UPDATE"
        .. " PLAYER_SPECIALIZATION_CHANGED", function()
        local spec = C_SpecializationInfo.GetSpecialization()
        local class = GW.myclass
        local powerType
        if class == "MONK" and spec == 1 and GW.Retail then
            local stagger = UnitStagger("player") or 0
            if not issecretvalue(stagger) and stagger == 0 then return "" end
            return GW.ShortValue(stagger)
        elseif class == "SHAMAN" and spec == 2 and GW.Retail then
            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(344179) -- maelstrom weapon, not secret
            return auraData and auraData.applications > 0 and auraData.applications or ""
        elseif class == "DEATHKNIGHT" then
            local ready = 0
            for index = 1, 6 do
                if select(3, GetRuneCooldown(index)) then
                    ready = ready + 1
                end
            end
            return C_StringUtil.TruncateWhenZero(ready)
        elseif class == "PALADIN" then
            powerType = Enum.PowerType.HolyPower
        elseif class == "MONK" then
            powerType = Enum.PowerType.Chi
        elseif class == "MAGE" and spec == 1 and GW.Retail then
            powerType = Enum.PowerType.ArcaneCharges
        elseif class == "EVOKER" then
            powerType = Enum.PowerType.Essence
        elseif class == "PRIEST" and spec == 3 and GW.Mists then
            powerType = Enum.PowerType.ShadowOrbs
        elseif class == "WARLOCK" then
            powerType = GW.Mists and spec == 2 and Enum.PowerType.DemonicFury
                or GW.Mists and spec == 3 and Enum.PowerType.BurningEmbers
                or Enum.PowerType.SoulShards
        elseif class == "ROGUE" or class == "DRUID" then
            powerType = Enum.PowerType.ComboPoints
        end
        if powerType then
            return C_StringUtil.TruncateWhenZero(UnitPower("player", powerType))
        end
    end)
end
GW.Create_Tags = Create_Tags
