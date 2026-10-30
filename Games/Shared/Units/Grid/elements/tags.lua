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
    Alliance = "|TInterface/AddOns/GW2_UI/textures/battleground/alliance.png:16:16:0:0|t ",
    Horde = "|TInterface/AddOns/GW2_UI/textures/battleground/horde.png:16:16:0:0|t ",
}
GW.GridTagIcons = ICONS


-- the spec of an arena enemy and its role; 12.1.5 hands the spec out as a secret, then only its name is known
local function GetArenaSpec(unit)
    local id = tonumber(unit:match("^arena(%d)$"))
    if not id or not GetArenaOpponentSpec then return end
    local specID = GetArenaOpponentSpec(id)
    if issecretvalue(specID) then
        return UnitFrameUtil.GetArenaOpponentSpecDisplayInfo(id).specName
    elseif specID and specID > 0 then
        local _, specName, _, _, role = GetSpecializationInfoByID(specID, UnitSex(unit))
        return specName, role
    end
end

local function AddTag(tagName, events, func)
    GW.oUF.Tags.Events[tagName] = events
    GW.oUF.Tags.Methods[tagName] = func
end

local function Create_Tags()
    -- the name, cut to a number of letters, other words than the last as initials, with the realm of other realms
    AddTag("GW2_Grid:name", "UNIT_NAME_UPDATE", function(unit, realunit, maxLength, abbrev, withRealm)
        unit = realunit or unit
        local name = GW.GetUnitDisplayName(unit, UnitName)
        if not maxLength or GW.IsSecretValue(name) or not name then
            return name
        end
        if stringtoboolean[abbrev] then
            name = name:gsub("(%S+) ", function(word) return string.utf8sub(word, 1, 1) .. ". " end)
        end
        if stringtoboolean[withRealm] then
            local _, realm = UnitName(unit)
            if GW.NotSecretValue(realm) and realm and realm ~= "" then
                name = name .. "-" .. realm
            end
        end
        maxLength = tonumber(maxLength)
        if maxLength > 0 and strlenutf8(name) > maxLength then
            name = string.utf8sub(name, 1, maxLength)
        end
        return name
    end)

    -- the name of what the unit has targeted
    AddTag("GW2:target", "UNIT_TARGET UNIT_NAME_UPDATE", function(unit, realUnit)
        local target = (realUnit or unit) .. "target"
        local exists = UnitExists(target)
        if GW.NotSecretValue(exists) and exists then
            return GW.GetUnitDisplayName(target)
        end
    end)

    AddTag("GW2:guild", "UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE", function(unit, realUnit, brackets, withRank)
        local guild, rank = GetGuildInfo(realUnit or unit)
        if GW.IsSecretValue(guild) or not guild then return end
        if stringtoboolean[withRank] and GW.NotSecretValue(rank) and rank then
            guild = guild .. " - " .. rank
        end
        return stringtoboolean[brackets] and "<" .. guild .. ">" or guild
    end)

    AddTag("GW2:classIcon", "UNIT_NAME_UPDATE", function(unit, realUnit)
        unit = realUnit or unit
        local isPlayer = UnitIsPlayer(unit)
        local _, class = UnitClass(unit)
        local coords = GW.NotSecretValue(isPlayer) and isPlayer and GW.NotSecretValue(class) and CLASS_ICON_TCOORDS[class]
        if coords then
            return format("|TInterface/WorldStateFrame/Icons-Classes:0:0:0:0:256:256:%d:%d:%d:%d|t",
                coords[1] * 256, coords[2] * 256, coords[3] * 256, coords[4] * 256)
        end
    end)

    -- dead, ghost or offline like oUF, then away or busy
    AddTag("GW2:status", "UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE PLAYER_FLAGS_CHANGED",
        function(unit, realUnit, mode)
        unit = realUnit or unit
        local text = GW.oUF.Tags.Methods[mode](unit)
        if text then return text end
        local afk, dnd = UnitIsAFK(unit), UnitIsDND(unit)
        if GW.IsSecretValue(afk) or GW.IsSecretValue(dnd) then return end
        return afk and AFK or dnd and DND or nil
    end)

    -- your threat on the unit
    AddTag("GW2:threatPercent", "UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE", function(unit, realUnit)
        local _, _, percent = UnitDetailedThreatSituation("player", realUnit or unit)
        if GW.NotSecretValue(percent) and percent and percent > 0 then
            return format("%.0f%%", percent)
        end
    end)

    AddTag("GW2:reactionColor", "UNIT_FACTION UNIT_NAME_UPDATE", function(unit, realUnit)
        local reaction = UnitReaction(realUnit or unit, "player")
        local color = GW.NotSecretValue(reaction) and reaction and GW.Colors.FactionBarColors[reaction]
        return color and color:GenerateHexColorMarkup()
    end)

    -- red over yellow to green by the health; retail hands the health out as a secret, it has no such color
    AddTag("GW2:healthColor", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit, realUnit)
        unit = realUnit or unit
        local healthMax = UnitHealthMax(unit)
        local percent = healthMax > 0 and UnitHealth(unit) / healthMax or 0
        local from, to = RED_FONT_COLOR, YELLOW_FONT_COLOR
        if percent > 0.5 then
            from, to, percent = YELLOW_FONT_COLOR, GREEN_FONT_COLOR, percent - 0.5
        end
        percent = percent * 2
        return CreateColor(Lerp(from.r, to.r, percent), Lerp(from.g, to.g, percent), Lerp(from.b, to.b, percent)):GenerateHexColorMarkup()
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
        -- arena enemies have no group role, their spec tells it
        if GW.NotSecretValue(role) and role == "NONE" then
            role = select(2, GetArenaSpec(realUnit or unit)) or role
        end

        if GW.NotSecretValue(role) and GW.nameRoleIcon[role] then
            return GW.nameRoleIcon[role]
        end
    end)

    AddTag("GW2:arenaSpec", "ARENA_PREP_OPPONENT_SPECIALIZATIONS ARENA_OPPONENT_UPDATE", function(unit, realUnit, dash)
        local specName = GetArenaSpec(realUnit or unit)
        if specName and stringtoboolean[dash] then
            return " - " .. specName
        end
        return specName
    end)

    -- the faction of the unit, the arena frames showed it only in battlegrounds
    AddTag("GW2:factionIcon", "UNIT_FACTION PLAYER_ENTERING_WORLD", function(unit, realUnit, onlyBattleground)
        if stringtoboolean[onlyBattleground] and not UnitInBattleground("player") then return end
        local faction = UnitFactionGroup(realUnit or unit)
        return GW.NotSecretValue(faction) and ICONS[faction]
    end)
    GW.oUF.Tags.SharedEvents.PLAYER_ENTERING_WORLD = true

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

    AddTag("GW2_Grid:healtValue", "UNIT_HEALTH UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED", function(unit, realUnit, mode, short, withShield)
        -- like the name: config mode hands its made up member in as realUnit
        unit = realUnit or unit
        local formatFunc = stringtoboolean[short] and GW.ShortValue or GW.isModern and BreakUpLargeNumbers or GW.GetLocalizedNumber

        -- retail hands the health out as a secret: blizzards functions format it, no math on it
        if GW.isModern then
            local percent = string.format("%.0f%%", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))
            if mode == "PREC" then
                return percent
            elseif mode == "HEALTH" then
                return formatFunc(UnitHealth(unit))
            elseif mode == "MAX" then
                return formatFunc(UnitHealthMax(unit))
            elseif mode == "LOSTHEALTH" then
                return formatFunc(UnitHealthMissing(unit))
            elseif mode == "CURMAX" then
                return formatFunc(UnitHealth(unit)) .. " / " .. formatFunc(UnitHealthMax(unit))
            elseif mode == "CURPREC" then
                return formatFunc(UnitHealth(unit)) .. " - " .. percent
            end
            return ""
        end

        local health, healthMax = UnitHealth(unit), UnitHealthMax(unit)
        if mode == "LOSTHEALTH" then
            return healthMax - health > 0 and formatFunc(healthMax - health) or ""
        end
        if stringtoboolean[withShield] and UnitGetTotalAbsorbs then
            health = health + (UnitGetTotalAbsorbs(unit) or 0)
        end
        local percent = GW.RoundDec(healthMax > 0 and health / healthMax * 100 or 0, 0) .. "%"
        if mode == "PREC" then
            return percent
        elseif mode == "HEALTH" then
            return formatFunc(health)
        elseif mode == "MAX" then
            return formatFunc(healthMax)
        elseif mode == "CURMAX" then
            return formatFunc(health) .. " / " .. formatFunc(healthMax)
        elseif mode == "CURPREC" then
            return formatFunc(health) .. " - " .. percent
        end
        return ""
    end)

    AddTag("GW2_Grid:power", "UNIT_POWER_UPDATE UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER PLAYER_ROLES_ASSIGNED", function(unit, realUnit, mode, short, mana, onlyHealer)
        unit = realUnit or unit
        if stringtoboolean[onlyHealer] then
            local role = UnitGroupRolesAssigned(unit)
            if GW.IsSecretValue(role) or role ~= "HEALER" then return end
        end
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
        elseif mode == "CURMAX" then
            return formatFunc(UnitPower(unit, powerType)) .. " / " .. formatFunc(UnitPowerMax(unit, powerType))
        elseif mode == "MISSING" then
            if GW.isModern then
                return formatFunc(UnitPowerMissing(unit, powerType))
            end
            return formatFunc(UnitPowerMax(unit, powerType) - UnitPower(unit, powerType))
        end
        return formatFunc(UnitPower(unit, powerType))
    end)

    -- the level like the unit frames showed it before the text designer, colored by difficulty the same way
    AddTag("GW2:level", "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_FACTION UNIT_CLASSIFICATION_CHANGED",
        function(unit, realUnit, smart, colored)
        unit = realUnit or unit
        local text
        if stringtoboolean[smart] then
            text = GW.oUF.Tags.Methods.smartlevel(unit)
        else
            local level = UnitLevel(unit)
            text = level == -1 and "??" or level
        end
        if not stringtoboolean[colored] then
            return text
        end
        -- white like our other texts, blizzards color only where it says more than the yellow of an even level
        local color = GW.GetUnitLevelColor(unit)
        color = color == QuestDifficultyColors.difficult and GW.Colors.FallbackWhite or color
        return format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, text)
    end)

    -- the damage shield; retail hands it out as a secret, there it stays a plain number without zero
    AddTag("GW2:absorb", "UNIT_ABSORB_AMOUNT_CHANGED UNIT_MAXHEALTH", function(unit, realUnit, mode, short)
        unit = realUnit or unit
        local absorb = UnitGetTotalAbsorbs and UnitGetTotalAbsorbs(unit) or 0
        if GW.isModern then
            return C_StringUtil.TruncateWhenZero(absorb)
        elseif absorb == 0 then
            return ""
        elseif mode == "PREC" then
            local healthMax = UnitHealthMax(unit)
            return GW.GetLocalizedNumber(healthMax > 0 and absorb / healthMax * 100 or 0, 0) .. "%"
        end
        return stringtoboolean[short] and GW.ShortValue(absorb) or GW.GetLocalizedNumber(absorb)
    end)

    -- the text of the class bar: the stagger of a brewmaster in percent of the health, colored by its height, or the
    -- void metamorphosis counter of a devourer demon hunter
    AddTag("GW2:classBarValue", "UNIT_AURA UNIT_HEALTH UNIT_MAXHEALTH PLAYER_SPECIALIZATION_CHANGED", function()
        local spec = C_SpecializationInfo.GetSpecialization()
        if GW.myclass == "MONK" and spec == 1 then
            local healthMax = UnitHealthMax("player")
            local stagger = math.max(0, math.min((UnitStagger("player") or 0) / healthMax, 1))
            local colors = GW.Colors.StaggerTextColors
            local color = stagger >= 0.75 and colors[3] or stagger >= 0.5 and colors[2] or colors[1]
            return color:WrapTextInColorCode(GW.GetLocalizedNumber(format("%.2f%%", stagger * 100)))
        elseif GW.myclass == "DEMONHUNTER" and spec == 3 then
            return select(2, GW.ClassPowers.GetVoidMetamorphosisPoints())
        end
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
-- at load, the target frame tags its texts before the grids are built
Create_Tags()
