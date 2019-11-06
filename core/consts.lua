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
    [8] = {r = 0, g = 0.6, b = 0.1}
}
GW.FACTION_BAR_COLORS = FACTION_BAR_COLORS

local BAG_TYP_COLORS = {
    [1] = {r = 1, g = 1, b = 1},            --Quivers       1
    [2] = {r = 1, g = 1, b = 1},            --Quivers       2
    [3] = {r = 0.251, g = 0.878, b = 0.816},--Soul          3
    [6] = {r = 0.451, g = 1, b = 0},        --Herbs         6
    [7] = {r = 1, g = 0, b = 1}             --Enchanting    7

}
GW.BAG_TYP_COLORS = BAG_TYP_COLORS

local COLOR_FRIENDLY = {
    [1] = {r = 88 / 255, g = 170 / 255, b = 68 / 255},
    [2] = {r = 159 / 255, g = 36 / 255, b = 20 / 255},
    [3] = {r = 159 / 255, g = 159 / 255, b = 159 / 255}
}
GW.COLOR_FRIENDLY = COLOR_FRIENDLY

local trackingTypes = {}
GW.trackingTypes = trackingTypes

trackingTypes[136025] = {l = 0.125, r = 0.250, t = 0, b = 0.5} --mining
trackingTypes[133939] = {l = 0, r = 0.125, t = 0, b = 0.5} --herbalism
trackingTypes[135974] = {l = 0.750, r = 0.875, t = 0, b = 0.5} --undead
trackingTypes[136142] = {l = 0.750, r = 0.875, t = 0, b = 0.5} --undead
trackingTypes["1323283"] = {l = 0.875, r = 1, t = 0, b = 0.5} --beast for hunter
trackingTypes["13232811"] = {l = 0, r = 0.125, t = 0.5, b = 1} --human for druid
trackingTypes[135942] = {l = 0, r = 0.125, t = 0.5, b = 1} --human
trackingTypes[136172] = {l = 0.250, r = 0.375, t = 0.5, b = 1} --demon
trackingTypes[136217] = {l = 0.250, r = 0.375, t = 0.5, b = 1} --demon
trackingTypes[135725] = {l = 0.375, r = 0.5, t = 0.5, b = 1} --treasure
trackingTypes[133888] = {l = 0.125, r = 0.250, t = 0.5, b = 1} --fish
trackingTypes[134153] = {l = 0.5, r = 0.625, t = 0, b = 0.5} --Dragonkin
trackingTypes[135861] = {l = 0.250, r = 0.375, t = 0, b = 0.5} --Elementals
trackingTypes[132275] = {l = 0.375, r = 0.5, t = 0, b = 0.5} --Giants
trackingTypes[132320] = {l = 0.625, r = 0.750, t = 0, b = 0.5} --Hidden

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
    ["worldboss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["boss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_boss",
    ["realboss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow-raidboss"
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
        [1243] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 1
        [1244] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 2
        [1245] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 3
        [2791] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 4
        [10937] =   {1, 1, 0.66},       -- Power Word: Fortitude Rank 5
        [10938] =   {1, 1, 0.66},       -- Power Word: Fortitude Rank 6
        [21562] =   {1, 1, 0.66},       -- Prayer of Fortitude Rank 1
        [21564] =   {1, 1, 0.66},       -- Prayer of Fortitude Rank 2
        [14752] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 1
        [14818] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 2
        [14819] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 3
        [27841] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 4
        [27581] =   {0.2, 0.7, 0.2},    -- Prayer of Spirit Rank 1
        [976] =     {0.7, 0.7, 0.7},    -- Shadow Protection Rank 1
        [10957] =   {0.7, 0.7, 0.7},    -- Shadow Protection Rank 2
        [10958] =   {0.7, 0.7, 0.7},    -- Shadow Protection Rank 3
        [27683] =   {0.7, 0.7, 0.7},    -- Prayer of Shadow Protection Rank 1
        [17] =      {0, 0, 1},          -- Power Word: Shield Rank 1
        [592] =     {0, 0, 1},          -- Power Word: Shield Rank 2
        [600] =     {0, 0, 1},          -- Power Word: Shield Rank 3
        [3747] =    {0, 0, 1},          -- Power Word: Shield Rank 4
        [6065] =    {0, 0, 1},          -- Power Word: Shield Rank 5
        [6066] =    {0, 0, 1},          -- Power Word: Shield Rank 6
        [10898] =   {0, 0, 1},          -- Power Word: Shield Rank 7
        [10899] =   {0, 0, 1},          -- Power Word: Shield Rank 8
        [10900] =   {0, 0, 1},          -- Power Word: Shield Rank 9
        [10901] =   {0, 0, 1},          -- Power Word: Shield Rank 10
        [139] =     {0.33, 0.73, 0.75}, -- Renew Rank 1
        [6074] =    {0.33, 0.73, 0.75}, -- Renew Rank 2
        [6075] =    {0.33, 0.73, 0.75}, -- Renew Rank 3
        [6076] =    {0.33, 0.73, 0.75}, -- Renew Rank 4
        [6077] =    {0.33, 0.73, 0.75}, -- Renew Rank 5
        [6078] =    {0.33, 0.73, 0.75}, -- Renew Rank 6
        [10927] =   {0.33, 0.73, 0.75}, -- Renew Rank 7
        [10928] =   {0.33, 0.73, 0.75}, -- Renew Rank 8
        [10929] =   {0.33, 0.73, 0.75}, -- Renew Rank 9
        [25315] =   {0.33, 0.73, 0.75}, -- Renew Rank 10
    },
    DRUID = {
        [1126] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 1
        [5232] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 2
        [6756] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 3
        [5234] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 4
        [8907] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 5
        [9884] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 6
        [16878] =   {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 7
        [21849] =   {0.8, 0.8, 0.8},    -- Gift of the Wild Rank 1
        [21850] =   {0.2, 0.8, 0.8},    -- Gift of the Wild Rank 2
        [467] =     {0.4, 0.2, 0.8},    -- Thorns Rank 1
        [782] =     {0.4, 0.2, 0.8},    -- Thorns Rank 2
        [1075] =    {0.4, 0.2, 0.8},    -- Thorns Rank 3
        [8914] =    {0.4, 0.2, 0.8},    -- Thorns Rank 4
        [9756] =    {0.4, 0.2, 0.8},    -- Thorns Rank 5
        [9910] =    {0.4, 0.2, 0.8},    -- Thorns Rank 6
        [774] =     {0.83, 1, 0.25},    -- Rejuvenation Rank 1
        [1058] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 2
        [1430] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 3
        [2090] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 4
        [2091] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 5
        [3627] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 6
        [8910] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 7
        [9839] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 8
        [9840] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 9
        [9841] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 10
        [25299] =   {0.83, 1, 0.25},    -- Rejuvenation Rank 11
        [8936] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 1
        [8938] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 2
        [8939] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 3
        [8940] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 4
        [8941] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 5
        [9750] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 6
        [9856] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 7
        [9857] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 8
        [9858] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 9
        [29166] =   {0.49, 0.6, 0.55},  -- Innervate
    },
    PALADIN = {
        [1044] =    {0.89, 0.45, 0},    -- Blessing of Freedom
        [6940] =    {0.89, 0.1, 1},     -- Blessing Sacrifice Rank 1
        [20729] =   {0.89, 0.1, 1},     -- Blessing Sacrifice Rank 1
        [19740] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 1
        [19834] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 2
        [19835] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 3
        [19836] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 4
        [19837] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 5
        [19838] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 6
        [25291] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 7
        [19742] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 1
        [19850] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 2
        [19852] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 3
        [19853] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 4
        [19854] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 5
        [25290] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 6
        [25782] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Might Rank 1
        [25916] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Might Rank 2
        [25894] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Wisdom Rank 1
        [25918] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Wisdom Rank 2
        [465] =     {0.58, 1, 0.5},     -- Devotion Aura Rank 1
        [10290] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 2
        [643] =     {0.58, 1, 0.5},     -- Devotion Aura Rank 3
        [10291] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 4
        [1032] =    {0.58, 1, 0.5},     -- Devotion Aura Rank 5
        [10292] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 6
        [10293] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 7
        [19977] =   {0.17, 1, 0.75},    -- Blessing of Light Rank 1
        [19978] =   {0.17, 1, 0.75},    -- Blessing of Light Rank 2
        [19979] =   {0.17, 1, 0.75},    -- Blessing of Light Rank 3
        [1022] =    {0.17, 1, 0.75},    -- Blessing of Protection Rank 1
        [5599] =    {0.17, 1, 0.75},    -- Blessing of Protection Rank 2
        [10278] =   {0.17, 1, 0.75},    -- Blessing of Protection Rank 3
        [19746] =   {0.83, 1, 0.07},    -- Concentration Aura
    },
    SHAMAN = {
        [29203] =   {0.7, 0.3, 0.7},    -- Healing Way
        [16237] =   {0.2, 0.2, 1},      -- Ancestral Fortitude
        [25909] =   {0, 0, 0.5},        -- Tranquil Air
        [8185] =    {0.05, 1, 0.5},     -- Fire Resistance Totem Rank 1
        [10534] =   {0.05, 1, 0.5},     -- Fire Resistance Totem Rank 2
        [10535] =   {0.05, 1, 0.5},     -- Fire Resistance Totem Rank 3
        [8182] =    {0.54, 0.53, 0.79}, -- Frost Resistance Totem Rank 1
        [10476] =   {0.54, 0.53, 0.79}, -- Frost Resistance Totem Rank 2
        [10477] =   {0.54, 0.53, 0.79}, -- Frost Resistance Totem Rank 3
        [10596] =   {0.33, 1, 0.2},     -- Nature Resistance Totem Rank 1
        [10598] =   {0.33, 1, 0.2},     -- Nature Resistance Totem Rank 2
        [10599] =   {0.33, 1, 0.2},     -- Nature Resistance Totem Rank 3
        [5672] =    {0.67, 1, 0.5},     -- Healing Stream Totem Rank 1
        [6371] =    {0.67, 1, 0.5},     -- Healing Stream Totem Rank 2
        [6372] =    {0.67, 1, 0.5},     -- Healing Stream Totem Rank 3
        [10460] =   {0.67, 1, 0.5},     -- Healing Stream Totem Rank 4
        [10461] =   {0.67, 1, 0.5},     -- Healing Stream Totem Rank 5
        [16191] =   {0.67, 1, 0.8},     -- Mana Tide Totem Rank 1
        [17355] =   {0.67, 1, 0.8},     -- Mana Tide Totem Rank 2
        [17360] =   {0.67, 1, 0.8},     -- Mana Tide Totem Rank 3
        [5677] =    {0.67, 1, 0.8},     -- Mana Spring Totem Rank 1
        [10491] =   {0.67, 1, 0.8},     -- Mana Spring Totem Rank 2
        [10493] =   {0.67, 1, 0.8},     -- Mana Spring Totem Rank 3
        [10494] =   {0.67, 1, 0.8},     -- Mana Spring Totem Rank 4
        [8072] =    {0, 0, 0.26},       -- Stoneskin Totem Rank 1
        [8156] =    {0, 0, 0.26},       -- Stoneskin Totem Rank 2
        [8157] =    {0, 0, 0.26},       -- Stoneskin Totem Rank 3
        [10403] =   {0, 0, 0.26},       -- Stoneskin Totem Rank 4
        [10404] =   {0, 0, 0.26},       -- Stoneskin Totem Rank 5
        [10405] =   {0, 0, 0.26},       -- Stoneskin Totem Rank 6
    },
    ROGUE = {}, --No buffs
    WARRIOR = {
        [6673] =    {0.2, 0.2, 1},      -- Battle Shout Rank 1
        [5242] =    {0.2, 0.2, 1},      -- Battle Shout Rank 2
        [6192] =    {0.2, 0.2, 1},      -- Battle Shout Rank 3
        [11549] =   {0.2, 0.2, 1},      -- Battle Shout Rank 4
        [11550] =   {0.2, 0.2, 1},      -- Battle Shout Rank 5
        [11551] =   {0.2, 0.2, 1},      -- Battle Shout Rank 6
        [25289] =   {0.2, 0.2, 1},      -- Battle Shout Rank 7
    },
    HUNTER = {
        [19506] =   {0.89, 0.09, 0.05}, -- Trueshot Aura Rank 1
        [20905] =   {0.89, 0.09, 0.05}, -- Trueshot Aura Rank 2
        [20906] =   {0.89, 0.09, 0.05}, -- Trueshot Aura Rank 3
    },
    WARLOCK = {
        [5597] =    {0.89, 0.09, 0.05}, -- Unending Breath
        [6512] =    {0.2, 0.8, 0.2},    -- Detect Lesser Invisibility
        [2970] =    {0.2, 0.8, 0.2},    -- Detect Invisibility
        [11743] =   {0.2, 0.8, 0.2},    -- Detect Invisibility
    },
    MAGE = {
        [1459] =    {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 1
        [1460] =    {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 2
        [1461] =    {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 3
        [10156] =   {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 4
        [10157] =   {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 5
        [23028] =   {0.89, 0.09, 0.05}, -- Arcane Brilliance Rank 1
        [27127] =   {0.89, 0.09, 0.05}, -- Arcane Brilliance Rank 2
        [604] =     {0.2, 0.8, 0.2},    -- Dampen Magic Rank 1
        [8450] =    {0.2, 0.8, 0.2},    -- Dampen Magic Rank 2
        [8451] =    {0.2, 0.8, 0.2},    -- Dampen Magic Rank 3
        [10173] =   {0.2, 0.8, 0.2},    -- Dampen Magic Rank 4
        [10174] =   {0.2, 0.8, 0.2},    -- Dampen Magic Rank 5
        [1008] =    {0.2, 0.8, 0.2},    -- Amplify Magic Rank 1
        [8455] =    {0.2, 0.8, 0.2},    -- Amplify Magic Rank 2
        [10169] =   {0.2, 0.8, 0.2},    -- Amplify Magic Rank 3
        [10170] =   {0.2, 0.8, 0.2},    -- Amplify Magic Rank 4
        [12438] =   {0, 0, 0.5},        -- Slow Fall
    },
    PET = {
        --Warlock Imp
        [6307] =    {0.89, 0.09, 0.05}, -- Blood Pact Rank 1
        [7804] =    {0.89, 0.09, 0.05}, -- Blood Pact Rank 2
        [7805] =    {0.89, 0.09, 0.05}, -- Blood Pact Rank 3
        [11766] =   {0.89, 0.09, 0.05}, -- Blood Pact Rank 4
        [11767] =   {0.89, 0.09, 0.05}, -- Blood Pact Rank 5
        --Warlock Felhunter
        [19480] =   {0.2, 0.8, 0.2},    -- Paranoia
        --Hunter Pets
        [24604] =   {0.08, 0.59, 0.41}, -- Furious Howl Rank 1
        [24605] =   {0.08, 0.59, 0.41}, -- Furious Howl Rank 2
        [24603] =   {0.08, 0.59, 0.41}, -- Furious Howl Rank 3
        [24597] =   {0.08, 0.59, 0.41}, -- Furious Howl Rank 4
    }
}
GW.AURAS_INDICATORS = AURAS_INDICATORS

-- Never show theses auras
local AURAS_IGNORED = {
    --57723, -- Sated
    --57724, -- Exhaustion
    --80354, -- Temporal Displacement
    --264689 -- Fatigued
}
GW.AURAS_IGNORED = AURAS_IGNORED

-- Show these auras only when they are missing
local AURAS_MISSING = {
    --21562,  -- Power Word: Fortitude
    --6673,   -- Battle Shout
    --1459    -- Arcane Intellect
}
GW.AURAS_MISSING = AURAS_MISSING