---@class GW2
local GW = select(2, ...)

-- the building blocks of the frame texts: a frame stores each text line as a list of blocks, {k = key} plus the
-- options of that block, and gets its oUF tag string built from it; the designer edits these lists
local function EscapeText(text)
    -- brackets would start a tag, a lone pipe an escape sequence
    return ((text or ""):gsub("[%[%]]", ""):gsub("|", "||"))
end

local L = GW.L

-- the made up member of the preview, a shaman healer who leads the group; test modes hand in their own values
local PREVIEW_UNIT = {name = "Thrall", role = "HEALER", spec = "Restoration", health = 58204, maxHealth = 80840,
    power = 42000, maxPower = 50000, inBattleground = true}
local PREVIEW_UNIT_META = {__index = PREVIEW_UNIT}

local function PreviewValue(block, mode, current, max)
    if mode == "PREC" then
        return string.format("%.0f%%", current / max * 100)
    end
    local value = mode == "MAX" and max or (mode == "LOSTHEALTH" or mode == "MISSING") and max - current or current
    return block.short and GW.ShortValue(value) or BreakUpLargeNumbers(value)
end

-- a block with modes keeps the chosen one in block.mode, the first mode is the default; checks are the
-- checkboxes of a block, hideInMode hides one in the mode it does nothing in; a hidden mode or checkbox does not
-- exist on this client; playerOnly blocks show the
-- player's own values and are only offered by designer targets for the player; hidden blocks do not exist
-- on this client
local SHORT_CHECK = {key = "short", label = L["Shorten values"], hideInMode = "PREC"}

-- for blocks whose modes are the oUF tags themselves
local function ModeTag(_, mode)
    return mode
end

local COLOR_PREVIEWS = {
    raidcolor = function() return RAID_CLASS_COLORS.SHAMAN:GenerateHexColorMarkup() end,
    powercolor = function() return GW.oUF.colors.power.MANA:GenerateHexColorMarkup() end,
    threatcolor = function() return GW.oUF.colors.threat[3]:GenerateHexColorMarkup() end,
    difficulty = function() return RED_FONT_COLOR:GenerateHexColorMarkup() end,
}
local CLASSIFICATION_PREVIEWS = {classification = "Elite", shortclassification = "+", rare = "Rare", plus = "+",
    affix = "Affix"}

-- label, desc and preview are for the designer; blocks that show nothing on the preview member preview an example
local BLOCKS = {
    name = {category = "name", label = NAME, desc = L["The name of the unit."], tag = "GW2_Grid:name",
        preview = function(_, _, unit) return unit.name end},
    class = {category = "name", label = CLASS, desc = L["The class of a player."],
        checks = {{key = "creature", label = L["Creature Type on Everything Else"]}},
        tag = function(block) return block.creature and "smartclass" or "class" end,
        preview = function() return LOCALIZED_CLASS_NAMES_MALE.SHAMAN end},
    race = {category = "name", label = RACE, desc = L["The race of a player."], tag = "race", preview = "Orc"},
    sex = {category = "name", label = L["Gender"], desc = L["Male or female."], tag = "sex", preview = "Male"},
    creature = {category = "name", label = L["Creature Type"], desc = L["The family or type of a creature, like Beast."],
        tag = "creature", preview = "Beast"},
    faction = {category = "name", label = FACTION, desc = L["Horde or Alliance."], tag = "faction", preview = "Horde"},
    arenaspec = {category = "name", label = SPECIALIZATION, desc = L["The specialization of an arena enemy."],
        checks = {{key = "dash", label = L["With Dash in Front"]}}, tag = "GW2:arenaSpec",
        args = function(block) return tostring(block.dash == true) end,
        preview = function(block, _, unit) return (block.dash and " - " or "") .. unit.spec end,
        hidden = GW.Classic or GW.TBC or GW.Wrath},

    healthValue = {category = "health", label = HEALTH, desc = L["The health of the unit."],
        modes = {{"PREC", STATUS_TEXT_PERCENT}, {"HEALTH", REFORGE_CURRENT}, {"MAX", MAXIMUM}, {"LOSTHEALTH", L["Missing"]}},
        checks = {SHORT_CHECK}, tag = "GW2_Grid:healtValue",
        args = function(block, mode) return mode .. "," .. tostring(block.short == true) end,
        preview = function(block, mode, unit) return PreviewValue(block, mode, unit.health, unit.maxHealth) end},
    -- retail hands out the shield as a secret, only blizzards formatting can show it, so no percent and no shortening
    absorb = {category = "health", label = L["Shield"], desc = L["The damage shield of the unit."],
        modes = {{"CUR", REFORGE_CURRENT}, {"PREC", STATUS_TEXT_PERCENT, hidden = GW.isModern}},
        checks = {{key = "short", label = L["Shorten values"], hideInMode = "PREC", hidden = GW.isModern}},
        tag = "GW2:absorb",
        args = function(block, mode) return mode .. "," .. tostring(block.short == true) end,
        preview = function(block, mode)
            return mode == "PREC" and "15%" or block.short and GW.ShortValue(12000) or BreakUpLargeNumbers(12000)
        end},
    status = {category = "health", label = DEAD .. " / " .. PLAYER_OFFLINE,
        desc = L["Dead, Ghost or Offline, zzz on yourself while resting."],
        modes = {{"status", L["Dead, Ghost or Offline"]}, {"dead", L["Dead or Ghost"]}, {"offline", PLAYER_OFFLINE}},
        tag = ModeTag, preview = function(_, mode) return mode == "offline" and "Offline" or "Dead" end},

    power = {category = "power", label = L["Power"], desc = L["The power of the unit, like mana or rage."],
        modes = {{"PREC", STATUS_TEXT_PERCENT}, {"CUR", REFORGE_CURRENT}, {"MAX", MAXIMUM}, {"MISSING", L["Missing"]}},
        checks = {SHORT_CHECK, {key = "mana", label = L["Always Mana"]}}, tag = "GW2_Grid:power",
        args = function(block, mode)
            return mode .. "," .. tostring(block.short == true) .. "," .. tostring(block.mana == true)
        end,
        preview = function(block, mode, unit) return PreviewValue(block, mode, unit.power, unit.maxPower) end},
    classPower = {category = "power", label = L["Class Resource"], playerOnly = true,
        desc = L["Your class resource, picked by class and specialization like the class power bar."],
        tag = "GW2:classPower", preview = "3"},
    classBarValue = {category = "power", label = L["Class Bar Value"], playerOnly = true, hidden = not GW.Retail,
        desc = L["The stagger of a brewmaster in percent of the health, the counter of a devourer demon hunter."],
        tag = "GW2:classBarValue",
        preview = function() return GW.Colors.StaggerTextColors[1]:WrapTextInColorCode(GW.GetLocalizedNumber("12.50%")) end},

    roleIcon = {category = "icon", label = L["Role Icon"], desc = L["Tank, healer or damage dealer."],
        tag = "GW2_Grid:roleIcon", args = "true", preview = function(_, _, unit) return GW.nameRoleIcon[unit.role] end},
    leaderIcon = {category = "icon", label = L["Leader Icon"], desc = L["Shown on the group leader."],
        tag = "GW2_Grid:leaderIcon", args = "true", preview = function() return GW.GridTagIcons.leader end},
    assistIcon = {category = "icon", label = L["Assist Icon"], desc = L["Shown on raid assistants."],
        tag = "GW2_Grid:assistIcon", args = "true", preview = function() return GW.GridTagIcons.assist end},
    mainTankIcon = {category = "icon", label = L["Tank Icon"], desc = L["Shown on main tanks and main assists."],
        tag = "GW2_Grid:mainTank", args = "true", preview = function() return GW.GridTagIcons.mainTank end},
    factionIcon = {category = "icon", label = L["Faction Icon"], desc = L["Horde or Alliance as an icon."],
        checks = {{key = "onlyBattleground", label = L["Only in Battlegrounds"]}}, tag = "GW2:factionIcon",
        args = function(block) return tostring(block.onlyBattleground == true) end,
        preview = function(block, _, unit)
            return (unit.inBattleground or not block.onlyBattleground) and GW.GridTagIcons.Horde or ""
        end},
    realmFlag = {category = "icon", label = L["Country Flag"], desc = L["The language of the realm."],
        modes = {{"DIFFERENT", L["Different Than Own"]}, {"ALL", ALL}}, tag = "GW2_Grid:realmFlag", args = ModeTag,
        preview = function() return GW.REALM_FLAGS.enUS or "" end},

    level = {category = "status", label = LEVEL, desc = L["The level, or ?? when it is unknown."],
        checks = {{key = "smart", label = L["+ on Elites, Boss on Bosses"]}, {key = "colored", label = L["Difficulty Color"]}},
        tag = "GW2:level",
        args = function(block) return tostring(block.smart == true) .. "," .. tostring(block.colored == true) end,
        -- your own level
        preview = function(block)
            return GW.oUF.Tags.Methods["GW2:level"]("player", nil, "false", tostring(block.colored == true))
        end},
    group = {category = "status", label = GROUP, desc = L["The number of the raid group."], tag = "group", preview = "2"},
    leader = {category = "status", label = LEADER, desc = L["Shown on the group leader."],
        modes = {{"leader", "L"}, {"leaderlong", "Leader"}}, tag = ModeTag,
        preview = function(_, mode) return mode == "leader" and "L" or "Leader" end},
    classification = {category = "status", label = L["Classification"],
        desc = L["Rare, Rare Elite, Elite, Boss or Affix; short: R, R+, +, B or -."],
        modes = {{"classification", TIME_LEFT_LONG}, {"shortclassification", SHORT}, {"rare", ITEM_QUALITY3_DESC}, {"plus", ELITE}, {"affix", L["Affix"]}},
        tag = ModeTag, preview = function(_, mode) return CLASSIFICATION_PREVIEWS[mode] end},
    pvp = {category = "status", label = PVP, desc = L["PvP while the unit is flagged for PvP."], tag = "pvp",
        preview = "PvP"},
    resting = {category = "status", label = TUTORIAL_TITLE30, desc = L["zzz on yourself while resting."],
        tag = "resting", preview = "zzz"},
    threat = {category = "status", label = L["Threat"], desc = L["++, -- or Aggro, depending on the threat of the unit."],
        tag = "threat", preview = "Aggro"},
    happiness = {category = "status", label = HAPPINESS, desc = L["The happiness of a hunter pet."], tag = "happiness",
        preview = ":D", hidden = GW.Retail or GW.Mists},

    colorStart = {category = "color", label = L["Color Start"], desc = L["Colors the text up to the next Color End."],
        modes = {{"raidcolor", CLASS}, {"powercolor", L["Power"]}, {"threatcolor", L["Threat"]}, {"difficulty", L["Difficulty"]}},
        tag = ModeTag, preview = function(_, mode) return COLOR_PREVIEWS[mode]() end},
    colorEnd = {category = "color", label = L["Color End"], desc = L["Ends the color, the text after it is no longer colored."],
        text = "|r"},

    space = {category = "text", label = L["Space"], desc = L["An empty space."], text = " "},
    newLine = {category = "text", label = L["Line Break"],
        desc = L["Starts a new row, for texts with room for it like the health globe."], text = "\n"},
    separator = {category = "text", label = L["Separator"], desc = L["A vertical line between two texts."], text = " || "},
    text = {category = "text", label = L["Custom Text"], desc = L["Any text of up to 10 characters."], textInput = true,
        text = function(block) return EscapeText(block.text) end},
}
-- the order of the block list in the designer
GW.TagTextBlockOrder = {
    "name", "class", "race", "sex", "creature", "faction", "arenaspec",
    "healthValue", "absorb", "status",
    "power", "classPower", "classBarValue",
    "roleIcon", "leaderIcon", "assistIcon", "mainTankIcon", "factionIcon", "realmFlag",
    "level", "group", "leader", "classification", "pvp", "resting", "threat", "happiness",
    "colorStart", "colorEnd",
    "space", "separator", "newLine", "text",
}
GW.TagTextBlocks = BLOCKS

-- the chosen mode of a block, a block without one has the default
function GW.GetTagTextBlockMode(def, block)
    return def.modes and (block.mode or def.modes[1][1])
end

-- a field of a block definition is a value or a function of the block, its mode and the preview unit
local function Field(def, field, block, unit)
    local value = def[field]
    if type(value) == "function" then
        return value(block, GW.GetTagTextBlockMode(def, block), unit)
    end
    return value
end

function GW.BuildTagString(blocks)
    local parts = {}
    for _, block in ipairs(blocks) do
        local def = BLOCKS[block.k]
        if def and def.tag then
            local args = Field(def, "args", block)
            tinsert(parts, "[" .. Field(def, "tag", block) .. (args and "(" .. args .. ")" or "") .. "]")
        elseif def then
            tinsert(parts, Field(def, "text", block))
        end
    end
    return table.concat(parts)
end

-- the same line with made up values instead of the tags; unit overrides fields of the made up member
function GW.BuildTagPreview(blocks, unit)
    unit = setmetatable(unit or {}, PREVIEW_UNIT_META)
    local parts = {}
    for _, block in ipairs(blocks) do
        local def = BLOCKS[block.k]
        if def then
            tinsert(parts, Field(def, def.tag and "preview" or "text", block, unit) or "")
        end
    end
    return table.concat(parts)
end

-- GW frames that are no oUF objects use the oUF tag engine too, it reads the unit from __unit
local function IsEventless()
    return false
end

function GW.SetFontStringTag(frame, fontString, tagString)
    frame.__unit = frame.gwUnit
    frame.IsEventless = IsEventless
    frame.Untag = GW.oUF.Tags.Untag
    GW.oUF.Tags.Tag(frame, fontString, tagString)
end
