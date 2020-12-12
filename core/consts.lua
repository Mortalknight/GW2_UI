local _, GW = ...

GW.DispelClasses = {
    PRIEST = { Magic = true, Disease = true },
    SHAMAN = { Magic = false, Curse = true },
    PALADIN = { Poison = true, Magic = false, Disease = true },
    DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
    MONK = { Magic = false, Disease = true, Poison = true },
    MAGE = { Curse = true }
}

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

local nameRoleIcon = {}
GW.nameRoleIcon = nameRoleIcon
nameRoleIcon["TANK"] = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank:12:12:0:0|t "
nameRoleIcon["HEALER"] = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer:12:12:0:0|t "
nameRoleIcon["DAMAGER"] = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps:12:12:0:0|t "
nameRoleIcon["NONE"] = ""

local professionBagColor = {
    [8] = {r = .88, g = .73, b = .29}, --leatherworking
    [16] = {r = .29, g = .30, b = .88}, --inscription
    [32] = {r = .07, g = .71, b = .13}, --herbs
    [64] = {r = .76, g = .02, b = .8}, --enchanting
    [128] = {r = .91, g = .46, b = .18}, --engineering
    [512] = {r = .03, g = .71, b = .81}, --gems
    [1024] = {r = .54, g = .40, b = .04}, --Mining Bag
    [32768] = {r = .42, g = .59, b = 1}, --fishing
    [65536] = {r = .87, g = .05, b = .25} --cooking
}
GW.professionBagColor = professionBagColor

local DEBUFF_COLOR = {}
GW.DEBUFF_COLOR = DEBUFF_COLOR
DEBUFF_COLOR["none"] = {r = 220 / 255, g = 0, b = 0}
DEBUFF_COLOR["Curse"] = {r = 97 / 255, g = 72 / 255, b = 177 / 255}
DEBUFF_COLOR["Disease"] = {r = 177 / 255, g = 114 / 255, b = 72 / 255}
DEBUFF_COLOR["Magic"] = {r = 72 / 255, g = 94 / 255, b = 177 / 255}
DEBUFF_COLOR["Poison"] = {r = 94 / 255, g = 177 / 255, b = 72 / 255}
DEBUFF_COLOR[""] = DEBUFF_COLOR["none"]

local TRACKER_TYPE_COLOR = {}
GW.TRACKER_TYPE_COLOR = TRACKER_TYPE_COLOR
TRACKER_TYPE_COLOR["QUEST"] = {r = 221 / 255, g = 198 / 255, b = 68 / 255}
TRACKER_TYPE_COLOR["CAMPAIGN"] = {r = 121 / 255, g = 222 / 255, b = 47 / 255}
TRACKER_TYPE_COLOR["EVENT"] = {r = 240 / 255, g = 121 / 255, b = 37 / 255}
TRACKER_TYPE_COLOR["SCENARIO"] = {r = 171 / 255, g = 37 / 255, b = 240 / 255}
TRACKER_TYPE_COLOR["BOSS"] = {r = 240 / 255, g = 37 / 255, b = 37 / 255}
TRACKER_TYPE_COLOR["ARENA"] = {r = 240 / 255, g = 37 / 255, b = 37 / 255}
TRACKER_TYPE_COLOR["ACHIEVEMENT"] = {r = 37 / 255, g = 240 / 255, b = 172 / 255}
TRACKER_TYPE_COLOR["DAILY"] = {r = 68 / 255, g = 192 / 255, b = 250 / 255}
TRACKER_TYPE_COLOR["TORGHAST"] = {r = 109 / 255, g = 161 / 255, b = 207 / 255}

--GW_FACTION_BAR_COLORS = FACTION_BAR_COLORS
--GW_FACTION_BAR_COLORS = {
local FACTION_BAR_COLORS = {
    [1] = {r = 0.8, g = 0.3, b = 0.22},
    [2] = {r = 0.8, g = 0.3, b = 0.22},
    [3] = {r = 0.75, g = 0.27, b = 0},
    [4] = {r = 0.9, g = 0.7, b = 0},
    [5] = {r = 0, g = 0.6, b = 0.1},
    [6] = {r = 0, g = 0.6, b = 0.1},
    [7] = {r = 0, g = 0.6, b = 0.1},
    [8] = {r = 0, g = 0.6, b = 0.1},
    [9] = {r = 0.22, g = 0.37, b = 0.98}, --Paragon
    [10] = {r = 0.09, g = 0.29, b = 0.79} --Azerite
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

CLASS_COLORS_RAIDFRAME["WARRIOR"] = {r = 90 / 255, g = 54 / 255, b = 38 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["PALADIN"] = {r = 177 / 255, g = 72 / 255, b = 117 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["HUNTER"] = {r = 99 / 255, g = 125 / 255, b = 53 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["ROGUE"] = {r = 190 / 255, g = 183 / 255, b = 79 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["PRIEST"] = {r = 205 / 255, g = 205 / 255, b = 205 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["DEATHKNIGHT"] = {r = 148 / 255, g = 62 / 255, b = 62 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["SHAMAN"] = {r = 30 / 255, g = 44 / 255, b = 149 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["MAGE"] = {r = 62 / 255, g = 121 / 255, b = 149 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["WARLOCK"] = {r = 125 / 255, g = 88 / 255, b = 154 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["MONK"] = {r = 66 / 255, g = 151 / 255, b = 112 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["DRUID"] = {r = 158 / 255, g = 103 / 255, b = 37 / 255, a = 1}
CLASS_COLORS_RAIDFRAME["DEMONHUNTER"] = {r = 72 / 255, g = 38 / 255, b = 148 / 255, a = 1}

local FACTION_COLOR = {}
GW.FACTION_COLOR = FACTION_COLOR
FACTION_COLOR[1] = {r = 163 / 255, g = 46 / 255, b = 54 / 255}
FACTION_COLOR[2] = {r = 57 / 255, g = 115 / 255, b = 186 / 255}

local TARGET_FRAME_ART = {
    ["minus"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow",
    ["normal"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow",
    ["elite"] = "Interface/AddOns/GW2_UI/textures/units/targetShadowElit",
    ["rare"] = "Interface/AddOns/GW2_UI/textures/units/targetShadowRare",
    ["rareelite"] = "Interface/AddOns/GW2_UI/textures/units/targetShadowRare",
    ["worldboss"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow_boss",
    ["boss"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow_boss",
    ["prestige1"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p1",
    ["prestige2"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p2",
    ["prestige3"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p3",
    ["prestige4"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p4",
    ["realboss"] = "Interface/AddOns/GW2_UI/textures/units/targetshadow-raidboss"
}
GW.TARGET_FRAME_ART = TARGET_FRAME_ART

local REALM_FLAGS = {
    ["enUS"] = "|TInterface/AddOns/GW2_UI/textures/flags/us:10:12:0:0|t",
    ["ptBR"] = "|TInterface/AddOns/GW2_UI/textures/flags/br:10:12:0:0|t",
    ["ptPT"] = "|TInterface/AddOns/GW2_UI/textures/flags/pt:10:12:0:0|t",
    ["esMX"] = "|TInterface/AddOns/GW2_UI/textures/flags/mx:10:12:0:0|t",
    ["deDE"] = "|TInterface/AddOns/GW2_UI/textures/flags/de:10:12:0:0|t",
    ["enGB"] = "|TInterface/AddOns/GW2_UI/textures/flags/gb:10:12:0:0|t",
    ["koKR"] = "|TInterface/AddOns/GW2_UI/textures/flags/kr:10:12:0:0|t",
    ["frFR"] = "|TInterface/AddOns/GW2_UI/textures/flags/fr:10:12:0:0|t",
    ["esES"] = "|TInterface/AddOns/GW2_UI/textures/flags/es:10:12:0:0|t",
    ["itIT"] = "|TInterface/AddOns/GW2_UI/textures/flags/it:10:12:0:0|t",
    ["ruRU"] = "|TInterface/AddOns/GW2_UI/textures/flags/ru:10:12:0:0|t",
    ["zhTW"] = "|TInterface/AddOns/GW2_UI/textures/flags/tw:10:12:0:0|t",
    ["zhCN"] = "|TInterface/AddOns/GW2_UI/textures/flags/cn:10:12:0:0|t"
}
GW.REALM_FLAGS = REALM_FLAGS

local INDICATORS = {"BAR", "TOPLEFT","TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT"}
GW.INDICATORS = INDICATORS

-- Taken from ElvUI: https://git.tukui.org/elvui/elvui/blob/master/ElvUI/Settings/Filters/UnitFrame.lua
-- Format: {class = {id = {r, g, b[, <spell-id-same-slot>]} ...}, ...}
local AURAS_INDICATORS = {
    PRIEST = {
        [194384] =  {1, 1, 0.66},       -- Atonement
        [214206] =  {1, 1, 0.66},       -- Atonement (PvP)
        [41635] =   {1, 1, 0.66},       -- Prayer of Mending
        [193065] =  {0.54, 0.21, 0.78}, -- Masochism
        [139] =     {0.4, 0.7, 0.2},    -- Renew
        [17] =      {0.7, 0.7, 0.7},    -- Power Word: Shield
        [47788] =   {0.86, 0.45, 0},    -- Guardian Spirit
        [33206] =   {0.47, 0.35, 0.74}, -- Pain Suppression
        [6788]   =  {0.89, 0.1, 0.1},   -- Weakened Soul
    },
    DRUID = {
        [774] =     {0.8, 0.4, 0.8},    -- Rejuvenation
        [155777] =  {0.8, 0.4, 0.8},    -- Germination
        [8936] =    {0.2, 0.8, 0.2},    -- Regrowth
        [33763] =   {0.4, 0.8, 0.2},    -- Lifebloom
        [188550] =  {0.4, 0.8, 0.2},    -- Lifebloom Legendary version
        [48438] =   {0.8, 0.4, 0},      -- Wild Growth
        [207386] =  {0.4, 0.2, 0.8},    -- Spring Blossoms
        [102351] =  {0.2, 0.8, 0.8},    -- Cenarion Ward (Initial Buff)
        [102352] =  {0.2, 0.8, 0.8},    -- Cenarion Ward (HoT)
        [200389] =  {1, 1, 0.4},        -- Cultivation
        [203554] =  {1, 1, 0.4}),		-- Focused Growth (PvP)
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
        [157047] =  {0.15, 0.58, 0.84},	-- Saved by the Light (T25 Talent)
        [204018] =  {0.2, 0.2, 1},      -- Blessing of Spellwarding
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
        [116841] =  {0.12, 1.00, 0.53},	-- Tiger's Lust (Freedom)
        [325209] =  {0.3, 0.8, 0.6},	-- Enveloping Breath
    },
    ROGUE = {
        [57934] =   {0.89, 0.09, 0.05}  -- Tricks of the Trade
    },
    WARRIOR = {
        [114030] =  {0.2, 0.2, 1},      -- Vigilance
        [3411] =    {0.89, 0.09, 0.05}  -- Intervene
    },
    HUNTER = {
        [90361]  = {0.34, 0.47, 0.31},	-- Spirit Mend (HoT)
    },
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

local ImportendRaidDebuff = {
    -- Mythic+ Dungeons
        -- General Affix
        [209858] = true, -- Necrotic
        [226512] = true, -- Sanguine
        [240559] = true, -- Grievous
        [240443] = true, -- Bursting
        -- Shadowlands Affix
        [342494] = true, -- Belligerent Boast (Prideful)

    -- Shadowlands Dungeons
        -- Halls of Atonement
        [335338] = true, -- Ritual of Woe
        [326891] = true, -- Anguish
        [329321] = true, -- Jagged Swipe 1
        [344993] = true, -- Jagged Swipe 2
        [319603] = true, -- Curse of Stone
        [319611] = true, -- Turned to Stone
        [325876] = true, -- Curse of Obliteration
        [326632] = true, -- Stony Veins
        [323650] = true, -- Haunting Fixation
        [326874] = true, -- Ankle Bites
        [340446] = true, -- Mark of Envy
        -- Mists of Tirna Scithe
        [325027] = true, -- Bramble Burst
        [323043] = true, -- Bloodletting
        [322557] = true, -- Soul Split
        [331172] = true, -- Mind Link
        [322563] = true, -- Marked Prey
        [322487] = true, -- Overgrowth 1
        [322486] = true, -- Overgrowth 2
        [328756] = true, -- Repulsive Visage
        [325021] = true, -- Mistveil Tear
        [321891] = true, -- Freeze Tag Fixation
        [325224] = true, -- Anima Injection
        [326092] = true, -- Debilitating Poison
        [325418] = true, -- Volatile Acid
        -- Plaguefall
        [336258] = true, -- Solitary Prey
        [331818] = true, -- Shadow Ambush
        [329110] = true, -- Slime Injection
        [325552] = true, -- Cytotoxic Slash
        [336301] = true, -- Web Wrap
        [322358] = true, -- Burning Strain
        [322410] = true, -- Withering Filth
        [328180] = true, -- Gripping Infection
        [320542] = true, -- Wasting Blight
        [340355] = true, -- Rapid Infection
        [328395] = true, -- Venompiercer
        [320512] = true, -- Corroded Claws
        [333406] = true, -- Assassinate
        [332397] = true, -- Shroudweb
        [330069] = true, -- Concentrated Plague
        -- The Necrotic Wake
        [321821] = true, -- Disgusting Guts
        [323365] = true, -- Clinging Darkness
        [338353] = true, -- Goresplatter
        [333485] = true, -- Disease Cloud
        [338357] = true, -- Tenderize
        [328181] = true, -- Frigid Cold
        [320170] = true, -- Necrotic Bolt
        [323464] = true, -- Dark Ichor
        [323198] = true, -- Dark Exile
        [343504] = true, -- Dark Grasp
        [343556] = true, -- Morbid Fixation 1
        [338606] = true, -- Morbid Fixation 2
        [324381] = true, -- Chill Scythe
        [320573] = true, -- Shadow Well
        [333492] = true, -- Necrotic Ichor
        [334748] = true, -- Drain FLuids
        [333489] = true, -- Necrotic Breath
        [320717] = true, -- Blood Hunger
        -- Theater of Pain
        [333299] = true, -- Curse of Desolation 1
        [333301] = true, -- Curse of Desolation 2
        [319539] = true, -- Soulless
        [326892] = true, -- Fixate
        [321768] = true, -- On the Hook
        [323825] = true, -- Grasping Rift
        [342675] = true, -- Bone Spear
        [323831] = true, -- Death Grasp
        [330608] = true, -- Vile Eruption
        [330868] = true, -- Necrotic Bolt Volley
        [323750] = true, -- Vile Gas
        [323406] = true, -- Jagged Gash
        [330700] = true, -- Decaying Blight
        [319626] = true, -- Phantasmal Parasite
        [324449] = true, -- Manifest Death
        [341949] = true, -- Withering Blight
        -- Sanguine Depths
        [326827] = true, -- Dread Bindings
        [326836] = true, -- Curse of Suppression
        [322554] = true, -- Castigate
        [321038] = true, -- Burden Soul
        [328593] = true, -- Agonize
        [325254] = true, -- Iron Spikes
        [335306] = true, -- Barbed Shackles
        [322429] = true, -- Severing Slice
        [334653] = true, -- Engorge
        -- Spires of Ascension
        [338729] = true, -- Charged Stomp
        [338747] = true, -- Purifying Blast
        [327481] = true, -- Dark Lance
        [322818] = true, -- Lost Confidence
        [322817] = true, -- Lingering Doubt
        [324205] = true, -- Blinding Flash
        [331251] = true, -- Deep Connection
        [328331] = true, -- Forced Confession
        [341215] = true, -- Volatile Anima
        [323792] = true, -- Anima Field
        [317661] = true, -- Insidious Venom
        [330683] = true, -- Raw Anima
        [328434] = true, -- Intimidated
        -- De Other Side
        [320786] = true, -- Power Overwhelming
        [334913] = true, -- Master of Death
        [325725] = true, -- Cosmic Artifice
        [328987] = true, -- Zealous
        [334496] = true, -- Soporific Shimmerdust
        [339978] = true, -- Pacifying Mists
        [323692] = true, -- Arcane Vulnerability
        [333250] = true, -- Reaver
        [330434] = true, -- Buzz-Saw 1
        [320144] = true, -- Buzz-Saw 2
        [331847] = true, -- W-00F
        [327649] = true, -- Crushed Soul
        [331379] = true, -- Lubricate
        [332678] = true, -- Gushing Wound
        [322746] = true, -- Corrupted Blood
        [323687] = true, -- Arcane Lightning
        [323877] = true, -- Echo Finger Laser X-treme
        [334535] = true, -- Beak Slice

    -- Castle Nathria
        -- Shriekwing
        [328897] = true, -- Exsanguinated
        [330713] = true, -- Reverberating Pain
        [329370] = true, -- Deadly Descent
        [336494] = true, -- Echo Screech
        -- Huntsman Altimor
        [335304] = true, -- Sinseeker
        [334971] = true, -- Jagged Claws
        [335111] = true, -- Huntsman's Mark 3
        [335112] = true, -- Huntsman's Mark 2
        [335113] = true, -- Huntsman's Mark 1
        [334945] = true, -- Vicious Lunge
        [334852] = true, -- Petrifying Howl
        -- Hungering Destroyer
        [334228] = true, -- Volatile Ejection
        [329298] = true, -- Gluttonous Miasma
        -- Lady Inerva Darkvein
        [325936] = true, -- Shared Cognition
        [335396] = true, -- Hidden Desire
        [324983] = true, -- Shared Suffering
        [324982] = true, -- Shared Suffering (Partner)
        [332664] = true, -- Concentrate Anima
        [325382] = true, -- Warped Desires
        -- Sun King's Salvation
        [333002] = true, -- Vulgar Brand
        [326078] = true, -- Infuser's Boon
        [325251] = true, -- Sin of Pride
        [341475] = true, -- Crimson Flurry
        [341473] = true, -- Crimson Flurry Teleport
        [328479] = true, -- Eyes on Target
        [328889] = true, -- Greater Castigation
        -- Artificer Xy'mox
        [327902] = true, -- Fixate
        [326302] = true, -- Stasis Trap
        [325236] = true, -- Glyph of Destruction
        [327414] = true, -- Possession
        [328468] = true, -- Dimensional Tear 1
        [328448] = true, -- Dimensional Tear 2
        -- The Council of Blood
        [327052] = true, -- Drain Essence 1
        [327773] = true, -- Drain Essence 2
        [346651] = true, -- Drain Essence Mythic
        [328334] = true, -- Tactical Advance
        [330848] = true, -- Wrong Moves
        [331706] = true, -- Scarlet Letter
        [331636] = true, -- Dark Recital 1
        [331637] = true, -- Dark Recital 2
        -- Sludgefist
        [335470] = true, -- Chain Slam
        [339181] = true, -- Chain Slam (Root)
        [331209] = true, -- Hateful Gaze
        [335293] = true, -- Chain Link
        [335270] = true, -- Chain This One!
        [342419] = true, -- Chain Them! 1
        [342420] = true, -- Chain Them! 2
        [335295] = true, -- Shattering Chain
        [332572] = true, -- Falling Rubble
        -- Stone Legion Generals
        [334498] = true, -- Seismic Upheaval
        [337643] = true, -- Unstable Footing
        [334765] = true, -- Heart Rend
        [333377] = true, -- Wicked Mark
        [334616] = true, -- Petrified
        [334541] = true, -- Curse of Petrification
        [339690] = true, -- Crystalize
        [342655] = true, -- Volatile Anima Infusion
        [342698] = true, -- Volatile Anima Infection
        [343881] = true, -- Serrated Tear
        -- Sire Denathrius
        [326851] = true, -- Blood Price
        [327796] = true, -- Night Hunter
        [327992] = true, -- Desolation
        [328276] = true, -- March of the Penitent
        [326699] = true, -- Burden of Sin
        [329181] = true, -- Wracking Pain
        [335873] = true, -- Rancor
        [329951] = true, -- Impale
        [327039] = true, -- Feeding Time
        [332794] = true, -- Fatal Finesse
}
GW.ImportendRaidDebuff = ImportendRaidDebuff
