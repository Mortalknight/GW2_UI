local _, GW = ...

local PowerBarColorCustom = {}
GW.PowerBarColorCustom = PowerBarColorCustom

PowerBarColorCustom["MANA"] = {r = 37 / 255, g = 133 / 255, b = 240 / 255}
PowerBarColorCustom["RAGE"] = {r = 240 / 255, g = 66 / 255, b = 37 / 255}
PowerBarColorCustom["ENERGY"] = {r = 240 / 255, g = 200 / 255, b = 37 / 255}
PowerBarColorCustom["POWER_TYPE_ENERGY"] = PowerBarColorCustom["ENERGY"]
PowerBarColorCustom["LUNAR_POWER"] = {r = 130 / 255, g = 172 / 255, b = 230 / 255}
PowerBarColorCustom["RUNIC_POWER"] = {r = 37 / 255, g = 214 / 255, b = 240 / 255}
PowerBarColorCustom["FOCUS"] = {r = 240 / 255, g = 121 / 255, b = 37 / 255}
PowerBarColorCustom["FURY"] = {r = 166 / 255, g = 37 / 255, b = 240 / 255}
PowerBarColorCustom["PAIN"] = {r = 255/255, g = 156/255, b = 0}
PowerBarColorCustom["MAELSTROM"] = {r = 0.00, g = 0.50, b = 1.00}
PowerBarColorCustom["INSANITY"] = {r = 0.40, g = 0, b = 0.80}
PowerBarColorCustom["CHI"] = {r = 0.71, g = 1.0, b = 0.92}

-- vehicle colors
PowerBarColorCustom["AMMOSLOT"] = {r = 0.80, g = 0.60, b = 0.00}
PowerBarColorCustom["FUEL"] = {r = 0.0, g = 0.55, b = 0.5}
PowerBarColorCustom["STAGGER"] = {r = 0.52, g = 1.0, b = 0.52}

local DEBUFF_COLOR = {}
GW.DEBUFF_COLOR = DEBUFF_COLOR
DEBUFF_COLOR["none"] = {r = 220 / 255, g = 0, b = 0}
DEBUFF_COLOR["Curse"] = {r = 97 / 255, g = 72 / 255, b = 177 / 255}
DEBUFF_COLOR["Disease"] = {r = 177 / 255, g = 114 / 255, b = 72 / 255}
DEBUFF_COLOR["Magic"] = {r = 72 / 255, g = 94 / 255, b = 177 / 255}
DEBUFF_COLOR["Poison"] = {r = 94 / 255, g = 177 / 255, b = 72 / 255}
DEBUFF_COLOR[""] = DEBUFF_COLOR["none"]

local FACTION_BAR_COLORS = {
    [1] = {r = 0.8, g = 0.3, b = 0.22},
    [2] = {r = 0.8, g = 0.3, b = 0.22},
    [3] = {r = 0.75, g = 0.27, b = 0},
    [4] = {r = 0.9, g = 0.7, b = 0},
    [5] = {r = 0, g = 0.6, b = 0.1},
    [6] = {r = 0, g = 0.6, b = 0.1},
    [7] = {r = 0, g = 0.6, b = 0.1},
    [8] = {r = 0, g = 0.6, b = 0.1},
}
GW.FACTION_BAR_COLORS = FACTION_BAR_COLORS

local COLOR_FRIENDLY = {
    [1] = {r = 88 / 255, g = 170 / 255, b = 68 / 255},
    [2] = {r = 159 / 255, g = 36 / 255, b = 20 / 255},
    [3] = {r = 159 / 255, g = 159 / 255, b = 159 / 255}
}
GW.COLOR_FRIENDLY = COLOR_FRIENDLY

local bloodSpark = {}
GW.BLOOD_SPARK = bloodSpark

bloodSpark[0] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[1] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[2] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5}
bloodSpark[3] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5}
bloodSpark[4] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5}
bloodSpark[5] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5}
bloodSpark[6] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5}
bloodSpark[7] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5}
bloodSpark[8] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}

bloodSpark[9] = {left = 0, right = 0.125, top = 0.5, bottom = 1}
bloodSpark[10] = {left = 0.125, right = 0.125 * 2, top = 0.5, bottom = 1}
bloodSpark[11] = {left = 0.125 * 2, right = 0.125 * 3, top = 0.5, bottom = 1}
bloodSpark[12] = {left = 0.125 * 3, right = 0.125 * 4, top = 0.5, bottom = 1}
bloodSpark[13] = {left = 0.125 * 4, right = 0.125 * 5, top = 0.5, bottom = 1}
bloodSpark[14] = {left = 0.125 * 5, right = 0.125 * 6, top = 0.5, bottom = 1}
bloodSpark[15] = {left = 0.125 * 6, right = 0.125 * 7, top = 0.5, bottom = 1}
bloodSpark[16] = {left = 0.125 * 7, right = 0.125 * 8, top = 0.5, bottom = 1}

bloodSpark[17] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[18] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5}
bloodSpark[19] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5}
bloodSpark[20] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5}
bloodSpark[21] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5}
bloodSpark[22] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5}
bloodSpark[23] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5}
bloodSpark[24] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}

local CLASS_ICONS = {}
GW.CLASS_ICONS = CLASS_ICONS

CLASS_ICONS[0] = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1}

CLASS_ICONS[1] = {l = 0.0625 * 11, r = 0.0625 * 12, t = 0, b = 1}
CLASS_ICONS[2] = {l = 0.0625 * 10, r = 0.0625 * 11, t = 0, b = 1}
CLASS_ICONS[3] = {l = 0.0625 * 9, r = 0.0625 * 10, t = 0, b = 1}
CLASS_ICONS[4] = {l = 0.0625 * 8, r = 0.0625 * 9, t = 0, b = 1}
CLASS_ICONS[5] = {l = 0.0625 * 7, r = 0.0625 * 8, t = 0, b = 1}
CLASS_ICONS[6] = {l = 0.0625 * 6, r = 0.0625 * 7, t = 0, b = 1}
CLASS_ICONS[7] = {l = 0.0625 * 5, r = 0.0625 * 6, t = 0, b = 1}
CLASS_ICONS[8] = {l = 0.0625 * 4, r = 0.0625 * 5, t = 0, b = 1}
CLASS_ICONS[9] = {l = 0.0625 * 3, r = 0.0625 * 4, t = 0, b = 1}
CLASS_ICONS[10] = {l = 0.0625 * 2, r = 0.0625 * 3, t = 0, b = 1}
CLASS_ICONS[11] = {l = 0.0625 * 1, r = 0.0625 * 2, t = 0, b = 1}
CLASS_ICONS[12] = {l = 0, r = 0.0625 * 1, t = 0, b = 1}
CLASS_ICONS["WARRIOR"] = CLASS_ICONS[1]
CLASS_ICONS["PALADIN"] = CLASS_ICONS[2]
CLASS_ICONS["HUNTER"] = CLASS_ICONS[3]
CLASS_ICONS["ROGUE"] = CLASS_ICONS[4]
CLASS_ICONS["PRIEST"] = CLASS_ICONS[5]
CLASS_ICONS["DEATHKNIGHT"] = CLASS_ICONS[6]
CLASS_ICONS["SHAMAN"] = CLASS_ICONS[7]
CLASS_ICONS["MAGE"] = CLASS_ICONS[8]
CLASS_ICONS["WARLOCK"] = CLASS_ICONS[9]
CLASS_ICONS["MONK"] = CLASS_ICONS[10]
CLASS_ICONS["DRUID"] = CLASS_ICONS[11]
CLASS_ICONS["DEMONHUNTER"] = CLASS_ICONS[12]
CLASS_ICONS["dead"] = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1}

local CLASS_COLORS_RAIDFRAME = {}
GW.CLASS_COLORS_RAIDFRAME = CLASS_COLORS_RAIDFRAME

CLASS_COLORS_RAIDFRAME[1] = {r = 90 / 255, g = 54 / 255, b = 38 / 255} --Warrior
CLASS_COLORS_RAIDFRAME[2] = {r = 177 / 255, g = 72 / 255, b = 117 / 255} --Paladin
CLASS_COLORS_RAIDFRAME[3] = {r = 99 / 255, g = 125 / 255, b = 53 / 255} --Hunter
CLASS_COLORS_RAIDFRAME[4] = {r = 190 / 255, g = 183 / 255, b = 79 / 255} --Rogue
CLASS_COLORS_RAIDFRAME[5] = {r = 205 / 255, g = 205 / 255, b = 205 / 255} --Priest
CLASS_COLORS_RAIDFRAME[6] = {r = 148 / 255, g = 62 / 255, b = 62 / 255} --Death Knight
CLASS_COLORS_RAIDFRAME[7] = {r = 30 / 255, g = 44 / 255, b = 149 / 255} -- Shaman
CLASS_COLORS_RAIDFRAME[8] = {r = 62 / 255, g = 121 / 255, b = 149 / 255} -- Mage
CLASS_COLORS_RAIDFRAME[9] = {r = 125 / 255, g = 88 / 255, b = 154 / 255} -- Warlock
CLASS_COLORS_RAIDFRAME[10] = {r = 66 / 255, g = 151 / 255, b = 112 / 255} -- Monk
CLASS_COLORS_RAIDFRAME[11] = {r = 158 / 255, g = 103 / 255, b = 37 / 255} -- Druid
CLASS_COLORS_RAIDFRAME[12] = {r = 72 / 255, g = 38 / 255, b = 148 / 255} -- Demon Hunter

local FACTION_COLOR = {}
GW.FACTION_COLOR = FACTION_COLOR
FACTION_COLOR[1] = {r = 163 / 255, g = 46 / 255, b = 54 / 255}
FACTION_COLOR[2] = {r = 57 / 255, g = 115 / 255, b = 186 / 255}

local TARGET_FRAME_ART = {
    ["minus"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["normal"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["elite"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit",
    ["rare"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",
    ["rareelite"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",
    ["worldboss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_boss",
    ["boss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_boss"
}
GW.TARGET_FRAME_ART = TARGET_FRAME_ART

local DODGEBAR_SPELLS = {}
GW.DODGEBAR_SPELLS = DODGEBAR_SPELLS
DODGEBAR_SPELLS[1] = {100, 198304}
DODGEBAR_SPELLS[2] = {190784}
DODGEBAR_SPELLS[3] = {781, 190925}
DODGEBAR_SPELLS[4] = {195457}
DODGEBAR_SPELLS[5] = {121536}
DODGEBAR_SPELLS[6] = {212552}
DODGEBAR_SPELLS[7] = {196884}
DODGEBAR_SPELLS[8] = {212653, 1953}
DODGEBAR_SPELLS[9] = {48018}
DODGEBAR_SPELLS[10] = {109132, 115008}
DODGEBAR_SPELLS[11] = {102280, 102401}
DODGEBAR_SPELLS[12] = {189110, 195072}

local INDICATORS = {"BAR", "TOPLEFT","TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT"}
GW.INDICATORS = INDICATORS

-- Taken from ElvUI: https://git.tukui.org/elvui/elvui/blob/master/ElvUI/Settings/Filters/UnitFrame.lua
-- Format: {class = {id = {r, g, b[, <spell-id-same-slot>]} ...}, ...}
local AURAS_INDICATORS = {
    PRIEST = {
        [194384] =  {1, 1, 0.66},       -- Atonement
        [41635] =   {1, 1, 0.66},       -- Prayer of Mending
        [193065] =  {0.54, 0.21, 0.78}, -- Masochism
        [139] =     {0.4, 0.7, 0.2},    -- Renew
        [17] =      {0.7, 0.7, 0.7},    -- Power Word: Shield
        [47788] =   {0.86, 0.45, 0},    -- Guardian Spirit
        [33206] =   {0.47, 0.35, 0.74}  -- Pain Suppression
    },
    DRUID = {
        [774] =     {0.8, 0.4, 0.8},    -- Rejuvenation
        [155777] =  {0.8, 0.4, 0.8},    -- Germination
        [8936] =    {0.2, 0.8, 0.2},    -- Regrowth
        [33763] =   {0.4, 0.8, 0.2},    -- Lifebloom
        [48438] =   {0.8, 0.4, 0},      -- Wild Growth
        [207386] =  {0.4, 0.2, 0.8},    -- Spring Blossoms
        [102351] =  {0.2, 0.8, 0.8},    -- Cenarion Ward (Initial Buff)
        [102352] =  {0.2, 0.8, 0.8},    -- Cenarion Ward (HoT)
        [200389] =  {1, 1, 0.4},        -- Cultivation
    },
    PALADIN = {
        [53563] =   {1, 0.3, 0},        -- Beacon of Light
        [156910] =  {0, 0.7, 1, 53563}, -- Beacon of Faith
        [200025] =  {1, 0.85, 0, 53563},-- Beacon of Virtue
        [1022] =    {0.2, 0.2, 1},      -- Hand of Protection
        [1044] =    {0.89, 0.45, 0},    -- Hand of Freedom
        [6940] =    {0.89, 0.1, 0.1},   -- Hand of Sacrifice
        [223306] =  {0.7, 0.7, 0.3},    -- Bestow Faith
        [287280] =  {1, 0.5, 0},        -- Glimmer of Light
        [19834] =  {1, 0.5, 0},        -- Segen der Macht (TEST - NEEDS MAX RANK)
    },
    SHAMAN = {
        [61295] =   {0, 0.4, 0.53},     -- Riptide
        [974] =     {0.42, 0.74, 0},    -- Earth Shield
    },
    MONK = {
        [119611] =  {0.3, 0.8, 0.6},    -- Renewing Mist
        [116849] =  {0.2, 0.8, 0.2},    -- Life Cocoon
        [124682] =  {0.8, 0.8, 0.25},   -- Enveloping Mist
        [191840] =  {0.27, 0.62, 0.7},  -- Essence Font
    },
    ROGUE = {
        [57934] =   {0.89, 0.09, 0.05}  -- Tricks of the Trade
    },
    WARRIOR = {
        [114030] =  {0.2, 0.2, 1},      -- Vigilance
        [3411] =    {0.89, 0.09, 0.05}  -- Intervene
    },
    HUNTER = {},
    DEMONHUNTER = {},
    WARLOCK = {},
    MAGE = {},
    DEATHKNIGHT = {},
    PET = {
        [193396] =  {0.6, 0.2, 0.8},    -- Demonic Empowerment
        [19615] =   {0.89, 0.09, 0.05}, -- Frenzy
        [136] =     {0.2, 0.8, 0.2}     -- Mend Pet
    }
}
GW.AURAS_INDICATORS = AURAS_INDICATORS

-- Never show theses auras
local AURAS_IGNORED = {
    57723, -- Sated
    57724, -- Exhaustion
    80354, -- Temporal Displacement
    264689 -- Fatigued
}
GW.AURAS_IGNORED = AURAS_IGNORED

-- Show these auras only when they are missing
local AURAS_MISSING = {
    21562,  -- Power Word: Fortitude
    6673,   -- Battle Shout
    1459    -- Arcane Intellect
}
GW.AURAS_MISSING = AURAS_MISSING