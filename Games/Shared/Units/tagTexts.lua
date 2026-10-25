---@class GW2
local GW = select(2, ...)

-- the building blocks of the frame texts: a frame stores each text line as a list of blocks, {k = key} plus the
-- options of that block, and gets its oUF tag string built from it; the designer edits these lists
local function EscapeText(text)
    -- brackets would start a tag, a lone pipe an escape sequence
    return ((text or ""):gsub("[%[%]]", ""):gsub("|", "||"))
end

local L = GW.L

-- the made up member of the preview, a shaman healer who leads the group
local PREVIEW_HEALTH, PREVIEW_MAX_HEALTH = 58204, 80840
local PREVIEW_POWER, PREVIEW_MAX_POWER = 42000, 50000

local function PreviewValue(block, mode, current, max)
    if mode == "PREC" then
        return string.format("%.0f%%", current / max * 100)
    end
    local value = mode == "MAX" and max or (mode == "LOSTHEALTH" or mode == "MISSING") and max - current or current
    return block.short and GW.ShortValue(value) or BreakUpLargeNumbers(value)
end

-- a block with modes keeps the chosen one in block.mode, the first mode is the default; checks are the
-- checkboxes of a block, hideInMode hides one in the mode it does nothing in; playerOnly blocks show the
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
    name = {category = "name", label = NAME, desc = L["The name of the unit."], tag = "GW2_Grid:name", preview = "Thrall"},
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
        tag = "arenaspec", preview = "Restoration", hidden = GW.Classic or GW.TBC or GW.Wrath},

    healthValue = {category = "health", label = HEALTH, desc = L["The health of the unit."],
        modes = {{"PREC", STATUS_TEXT_PERCENT}, {"HEALTH", REFORGE_CURRENT}, {"MAX", MAXIMUM}, {"LOSTHEALTH", L["Missing"]}},
        checks = {SHORT_CHECK}, tag = "GW2_Grid:healtValue",
        args = function(block, mode) return mode .. "," .. tostring(block.short == true) end,
        preview = function(block, mode) return PreviewValue(block, mode, PREVIEW_HEALTH, PREVIEW_MAX_HEALTH) end},
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
        preview = function(block, mode) return PreviewValue(block, mode, PREVIEW_POWER, PREVIEW_MAX_POWER) end},
    classPower = {category = "power", label = L["Class Resource"], playerOnly = true,
        desc = L["Your class resource, picked by class and specialization like the class power bar."],
        tag = "GW2:classPower", preview = "3"},

    roleIcon = {category = "icon", label = L["Role Icon"], desc = L["Tank, healer or damage dealer."],
        tag = "GW2_Grid:roleIcon", args = "true", preview = function() return GW.nameRoleIcon.HEALER end},
    leaderIcon = {category = "icon", label = L["Leader Icon"], desc = L["Shown on the group leader."],
        tag = "GW2_Grid:leaderIcon", args = "true", preview = function() return GW.GridTagIcons.leader end},
    assistIcon = {category = "icon", label = L["Assist Icon"], desc = L["Shown on raid assistants."],
        tag = "GW2_Grid:assistIcon", args = "true", preview = function() return GW.GridTagIcons.assist end},
    mainTankIcon = {category = "icon", label = L["Tank Icon"], desc = L["Shown on main tanks and main assists."],
        tag = "GW2_Grid:mainTank", args = "true", preview = function() return GW.GridTagIcons.mainTank end},
    realmFlag = {category = "icon", label = L["Country Flag"], desc = L["The language of the realm."],
        modes = {{"DIFFERENT", L["Different Than Own"]}, {"ALL", ALL}}, tag = "GW2_Grid:realmFlag", args = ModeTag,
        preview = function() return GW.REALM_FLAGS.enUS or "" end},

    level = {category = "status", label = LEVEL, desc = L["The level, or ?? when it is unknown."],
        checks = {{key = "smart", label = L["+ on Elites, Boss on Bosses"]}},
        tag = function(block) return block.smart and "smartlevel" or "level" end, preview = "90"},
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
    separator = {category = "text", label = L["Separator"], desc = L["A vertical line between two texts."], text = " || "},
    text = {category = "text", label = L["Custom Text"], desc = L["Any text of up to 10 characters."], textInput = true,
        text = function(block) return EscapeText(block.text) end},
}
-- the order of the block list in the designer
GW.TagTextBlockOrder = {
    "name", "class", "race", "sex", "creature", "faction", "arenaspec",
    "healthValue", "status",
    "power", "classPower",
    "roleIcon", "leaderIcon", "assistIcon", "mainTankIcon", "realmFlag",
    "level", "group", "leader", "classification", "pvp", "resting", "threat", "happiness",
    "colorStart", "colorEnd",
    "space", "separator", "text",
}
GW.TagTextBlocks = BLOCKS

-- the chosen mode of a block, a block without one has the default
function GW.GetTagTextBlockMode(def, block)
    return def.modes and (block.mode or def.modes[1][1])
end

-- a field of a block definition is a value or a function of the block and its mode
local function Field(def, field, block)
    local value = def[field]
    if type(value) == "function" then
        return value(block, GW.GetTagTextBlockMode(def, block))
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

-- the same line with made up values instead of the tags
function GW.BuildTagPreview(blocks)
    local parts = {}
    for _, block in ipairs(blocks) do
        local def = BLOCKS[block.k]
        if def then
            tinsert(parts, Field(def, def.tag and "preview" or "text", block))
        end
    end
    return table.concat(parts)
end
