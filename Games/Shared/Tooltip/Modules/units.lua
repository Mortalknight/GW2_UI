---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

local AFK_TAG = " |cffff9900<" .. AFK .. ">|r"
local DND_TAG = " |cffff3333<" .. DND .. ">|r"
local GUILD_COLOR = "|cff00ff10"
local CLASSIFICATIONS = {
    worldboss = format(" |cffaf5050%s|r", BOSS),
    rareelite = format("|cffaf5050+ %s|r", ITEM_QUALITY3_DESC),
    rare = format(" |cffaf5050%s|r", ITEM_QUALITY3_DESC),
    elite = "|cffaf5050+|r",
}
local GENDERS = {UNKNOWN, MALE, FEMALE}
-- races both factions play, the tooltip adds the faction to them
local NEUTRAL_RACES = {Pandaren = true, Dracthyr = true, EarthenDwarf = true, Harronir = true}
-- the classic clients name the class in the level line, the modern ones in the line below;
-- era, tbc and wrath have the guild in the name line, the others in a line of its own
local CLASS_IN_LEVEL_LINE = not GW.isModern
local HAS_GUILD_LINE = not (GW.Classic or GW.TBC or GW.Wrath)

-- the words of blizzards level line without the numbers, "Level %s" -> "level", "%s-го уровня" -> "го уровня"
local function GetLevelWords(template)
    return template and strlower(strtrim((gsub(gsub(template, "%%%d?%$?s", ""), "%-", ""))))
end
local LEVEL_WORDS = {GetLevelWords(TOOLTIP_UNIT_LEVEL), GetLevelWords(TOOLTIP_UNIT_LEVEL_RACE or TOOLTIP_UNIT_LEVEL_CLASS)}

local function IsLevelLine(text)
    local lower = strlower(text)
    for _, words in ipairs(LEVEL_WORDS) do
        if words ~= "" and strfind(lower, words, 1, true) then
            return true
        end
    end
end

-- the font string of the level line and the one after it, searched after the given line
local function FindLevelLine(tooltip, after)
    local info = tooltip:GetTooltipData()
    for i = after + 1, info and #info.lines or 0 do
        local text = info.lines[i].leftText
        if GW.IsSecretValue(text) or not text or text == "" then
            return
        elseif IsLevelLine(text) then
            return _G["GameTooltipTextLeft" .. i], _G["GameTooltipTextLeft" .. i + 1]
        end
    end
end

-- the pvp and faction lines tell nothing the rest of the tooltip does not
local function HideFactionLines(tooltip)
    local info = tooltip:GetTooltipData()
    for i = 4, info and #info.lines or 0 do
        local text = info.lines[i].leftText
        if GW.NotSecretValue(text) then
            if not text or text == "" then
                break
            elseif text == PVP or text == FACTION_ALLIANCE or text == FACTION_HORDE then
                _G["GameTooltipTextLeft" .. i]:SetText("")
                _G["GameTooltipTextLeft" .. i]:Hide()
            end
        end
    end
end

local function GetLevelText(level, realLevel)
    local color = GetCreatureDifficultyColor(level)
    local text = GW.RGBToHex(color.r, color.g, color.b) .. (level > 0 and level or "??") .. "|r"
    if realLevel and level < realLevel then
        text = text .. " |cffffffff(" .. realLevel .. ")|r"
    end
    return text
end

-- title and realm as the settings want, shift shows the realm too
local function GetPlayerName(unit)
    local settings = GW.settings.tooltip.unit
    local name, realm = UnitName(unit)
    local title = settings.playerTitles and UnitPVPName(unit)
    if title and title ~= "" then
        name = title
        realm = GW.Forever and nil or realm
    end
    if GW.Forever then
        -- the realm of forever characters is their surname
        return realm and name .. " " .. realm or name
    elseif realm and realm ~= "" then
        if IsShiftKeyDown() or settings.realmAlways then
            return name .. "-" .. realm
        end
        local relationship = UnitRealmRelationship(unit)
        if relationship == LE_REALM_RELATION_COALESCED then
            return name .. FOREIGN_SERVER_LABEL
        elseif relationship == LE_REALM_RELATION_VIRTUAL then
            return name .. INTERACTIVE_SERVER_LABEL
        end
    end
    return name
end

local function SetGuildLine(tooltip, unit, levelLine)
    local guildName, rankName, _, guildRealm = GetGuildInfo(unit)
    if GW.IsSecretValue(guildName) or not guildName then
        return
    end
    if guildRealm and IsShiftKeyDown() then
        guildName = guildName .. "-" .. guildRealm
    end
    local text = GUILD_COLOR .. "<" .. guildName .. ">|r"
    if GW.settings.tooltip.unit.guildRanks and rankName then
        text = text .. " [" .. GUILD_COLOR .. rankName .. "|r]"
    end
    -- the classic clients have no guild line of their own
    if levelLine == GameTooltipTextLeft2 then
        tooltip:AddLine(text, 1, 1, 1)
    else
        GameTooltipTextLeft2:SetText(text)
    end
end

local function SetPlayerLines(tooltip, unit, color)
    local awayTag = GW.UnitIsAFK(unit) and AFK_TAG or GW.UnitIsDND(unit) and DND_TAG or ""
    GameTooltipTextLeft1:SetText(color:WrapTextInColorCode(GetPlayerName(unit) or UNKNOWN) .. awayTag)

    local hasGuild = GW.NotSecretValue(GetGuildInfo(unit)) and GetGuildInfo(unit)
    local levelLine, specLine = FindLevelLine(tooltip, hasGuild and HAS_GUILD_LINE and 2 or 1)
    if hasGuild then
        SetGuildLine(tooltip, unit, levelLine)
    end
    if not levelLine then
        return
    end

    local race, englishRace = UnitRace(unit)
    if GW.IsSecretValue(race) or not race then
        race, englishRace = "", nil
    end
    local _, localizedFaction = GW.GetUnitBattlefieldFaction(unit)
    if localizedFaction and NEUTRAL_RACES[englishRace] then
        race = localizedFaction .. " " .. race
    end
    local gender = GW.settings.tooltip.unit.gender and GENDERS[UnitSex(unit)]

    local text = GetLevelText(UnitEffectiveLevel(unit), UnitLevel(unit)) .. " " .. (gender and gender .. " " or "") .. race
    if CLASS_IN_LEVEL_LINE then
        text = text .. " " .. color:WrapTextInColorCode(UnitClass(unit))
    elseif specLine then
        local specText = specLine:GetText()
        if GW.NotSecretValue(specText) and specText then
            specLine:SetText(color:WrapTextInColorCode(specText))
        end
    end
    levelLine:SetText(text)
end

local function SetCreatureLines(tooltip, unit, color)
    local isCompanion = UnitIsBattlePetCompanion and UnitIsBattlePetCompanion(unit)
    local isBattlePet = isCompanion or (UnitIsWildBattlePet and UnitIsWildBattlePet(unit))
    local levelLine, typeLine = FindLevelLine(tooltip, 1)
    if levelLine then
        local creatureType = UnitCreatureType(unit)
        local levelText
        if isBattlePet then
            local level = UnitBattlePetLevel(unit)
            local petType = _G["BATTLE_PET_NAME_" .. UnitBattlePetType(unit)]
            creatureType = creatureType and creatureType .. " " .. petType or petType
            local teamLevel = C_PetJournal.GetPetTeamAverageLevel()
            local levelColor = teamLevel and GetRelativeDifficultyColor(teamLevel, level) or GetCreatureDifficultyColor(level)
            levelText = GW.RGBToHex(levelColor.r, levelColor.g, levelColor.b) .. level .. "|r"
        else
            levelText = GetLevelText(UnitEffectiveLevel(unit))
        end

        local isPvP = UnitIsPVP(unit)
        local pvpTag = GW.NotSecretValue(isPvP) and isPvP and " (" .. PVP .. ")" or ""
        levelLine:SetText(levelText .. (CLASSIFICATIONS[UnitClassification(unit)] or "") .. " " .. (creatureType or "") .. pvpTag)

        -- the creature type now sits in the level line
        local typeText = typeLine and typeLine:GetText()
        if GW.NotSecretValue(typeText) and typeText and typeText == creatureType then
            typeLine:SetText("")
            typeLine:Hide()
        end
    end

    if not isCompanion then
        GameTooltipTextLeft1:SetText(color:WrapTextInColorCode(UnitName(unit) or UNKNOWN))
    end
end

local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or tooltip:IsForbidden() then
        return
    end
    -- secret units hand out secret levels and names, those cannot be compared
    local unit = Tooltip.GetUnit(tooltip, data)
    if not unit or GW.IsSecretUnit(unit) then
        return
    end

    HideFactionLines(tooltip)
    local color = Tooltip.GetUnitColor(unit)
    if UnitIsPlayer(unit) then
        SetPlayerLines(tooltip, unit, color)
    else
        SetCreatureLines(tooltip, unit, color)
    end
end

-- shift, ctrl and alt change what the unit lines show; the mouseover tooltip is built again
local function RefreshMouseoverTooltip()
    if GameTooltip:IsForbidden() or not GameTooltip:IsShown() or not GW.UnitExists("mouseover") then
        return
    end
    local owner = GameTooltip:GetOwner()
    if owner ~= UIParent and not (GW2_PlayerFrame and owner == GW2_PlayerFrame) and not (GwPlayerUnitFrame and owner == GwPlayerUnitFrame) then
        return
    end
    if GW.isModern then
        if GW.NotSecretValue(select(2, GameTooltip:GetUnit())) then
            GameTooltip:RefreshData()
        end
    else
        GameTooltip:SetUnit("mouseover")
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        Tooltip.OnTooltipData("Unit", OnUnitTooltip)
        local watcher = CreateFrame("Frame")
        watcher:RegisterEvent("MODIFIER_STATE_CHANGED")
        watcher:SetScript("OnEvent", RefreshMouseoverTooltip)
    end,
})
