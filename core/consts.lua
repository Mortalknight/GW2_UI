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
TRACKER_TYPE_COLOR["BONUS"] = {r = 240 / 255, g = 121 / 255, b = 37 / 255}
TRACKER_TYPE_COLOR["SCENARIO"] = {r = 171 / 255, g = 37 / 255, b = 240 / 255}
TRACKER_TYPE_COLOR["BOSS"] = {r = 240 / 255, g = 37 / 255, b = 37 / 255}
TRACKER_TYPE_COLOR["ARENA"] = {r = 240 / 255, g = 37 / 255, b = 37 / 255}
TRACKER_TYPE_COLOR["ACHIEVEMENT"] = {r = 37 / 255, g = 240 / 255, b = 172 / 255}
TRACKER_TYPE_COLOR["DAILY"] = {r = 68 / 255, g = 192 / 255, b = 250 / 255}

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
        [33206] =   {0.47, 0.35, 0.74}  -- Pain Suppression
    },
    DRUID = {
        [774] =     {0.8, 0.4, 0.8},    -- Rejuvenation
        [155777] =  {0.8, 0.4, 0.8},    -- Germination
        [8936] =    {0.2, 0.8, 0.2},    -- Regrowth
        [33763] =   {0.4, 0.8, 0.2},    -- Lifebloom
        [188550] =   {0.4, 0.8, 0.2},    -- Lifebloom Legendary version
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

local ImportendRaidDebuff = {
-- Mythic+ Dungeons
    [209858] = true, -- Necrotic
    [226512] = true, -- Sanguine
    [240559] = true, -- Grievous
    [240443] = true, -- Bursting
    -- 8.3 Affix
    [314531] = true, -- Tear Flesh
    [314308] = true, -- Spirit Breaker
    [314478] = true, -- Cascading Terror
    [314483] = true, -- Cascading Terror
    [314592] = true, -- Mind Flay
    [314406] = true, -- Crippling Pestilence
    [314411] = true, -- Lingering Doubt
    [314565] = true, -- Defiled Ground
    [314392] = true, -- Vile Corruption
    -- Shadowlands
    [342494] = true, -- Belligerent Boast (Prideful)

-- Shadowlands Dungeons
    -- Halls of Atonement
    [335338] = true,  -- Ritual of Woe
    [326891] = true,  -- Anguish
    [329321] = true,  -- Jagged Swipe
    [319603] = true,  -- Curse of Stone
    [319611] = true,  -- Turned to Stone
    [325876] = true,  -- Curse of Obliteration
    [326632] = true,  -- Stony Veins
    [323650] = true,  -- Haunting Fixation
    [326874] = true,  -- Ankle Bites
    -- Mists of Tirna Scithe
    [325027] = true,  -- Bramble Burst
    [323043] = true,  -- Bloodletting
    [322557] = true,  -- Soul Split
    [331172] = true,  -- Mind Link
    [322563] = true,  -- Marked Prey
    -- Plaguefall
    [336258] = true,  -- Solitary Prey
    [331818] = true,  -- Shadow Ambush
    [329110] = true,  -- Slime Injection
    [325552] = true,  -- Cytotoxic Slash
    [336301] = true,  -- Web Wrap
    -- The Necrotic Wake
    [321821] = true,  -- Disgusting Guts
    [323365] = true,  -- Clinging Darkness
    [338353] = true,  -- Goresplatter
    [333485] = true,  -- Disease Cloud
    [338357] = true,  -- Tenderize
    [328181] = true,  -- Frigid Cold
    [320170] = true,  -- Necrotic Bolt
    [323464] = true,  -- Dark Ichor
    [323198] = true,  -- Dark Exile
    -- Theater of Pain
    [333299] = true,  -- Curse of Desolation
    [319539] = true,  -- Soulless
    [326892] = true,  -- Fixate
    [321768] = true,  -- On the Hook
    [323825] = true,  -- Grasping Rift
    -- Sanguine Depths
    [326827] = true,  -- Dread Bindings
    [326836] = true,  -- Curse of Suppression
    [322554] = true,  -- Castigate
    [321038] = true,  -- Burden Soul
    -- Spires of Ascension
    [338729] = true,  -- Charged Stomp
    [338747] = true,  -- Purifying Blast
    [327481] = true,  -- Dark Lance
    [322818] = true,  -- Lost Confidence
    [322817] = true,  -- Lingering Doubt
    -- De Other Side
    [320786] = true,  -- Power Overwhelming
    [334913] = true,  -- Master of Death
    [325725] = true,  -- Cosmic Artifice
    [328987] = true,  -- Zealous
    [334496] = true, -- Soporific Shimmerdust
    [339978] = true, -- Pacifying Mists
    [323692] = true, -- Arcane Vulnerability
    [333250] = true, -- Reaver


-- BFA Dungeons
    -- Freehold
    [258323] = true, -- Infected Wound
    [257775] = true, -- Plague Step
    [257908] = true, -- Oiled Blade
    [257436] = true, -- Poisoning Strike
    [274389] = true, -- Rat Traps
    [274555] = true, -- Scabrous Bites
    [258875] = true, -- Blackout Barrel
    [256363] = true, -- Ripper Punch
    -- Shrine of the Storm
    [264560] = true, -- Choking Brine
    [268233] = true, -- Electrifying Shock
    [268322] = true, -- Touch of the Drowned
    [268896] = true, -- Mind Rend
    [268104] = true, -- Explosive Void
    [267034] = true, -- Whispers of Power
    [276268] = true, -- Heaving Blow
    [264166] = true, -- Undertow
    [264526] = true, -- Grasp of the Depths
    [274633] = true, -- Sundering Blow
    [268214] = true, -- Carving Flesh
    [267818] = true, -- Slicing Blast
    [268309] = true, -- Unending Darkness
    [268317] = true, -- Rip Mind
    [268391] = true, -- Mental Assault
    [274720] = true, -- Abyssal Strike
    -- Siege of Boralus
    [257168] = true, -- Cursed Slash
    [272588] = true, -- Rotting Wounds
    [272571] = true, -- Choking Waters
    [274991] = true, -- Putrid Waters
    [275835] = true, -- Stinging Venom Coating
    [273930] = true, -- Hindering Cut
    [257292] = true, -- Heavy Slash
    [261428] = true, -- Hangman's Noose
    [256897] = true, -- Clamping Jaws
    [272874] = true, -- Trample
    [273470] = true, -- Gut Shot
    [272834] = true, -- Viscous Slobber
    [257169] = true, -- Terrifying Roar
    [272713] = true, -- Crushing Slam
    -- Tol Dagor
    [258128] = true, -- Debilitating Shout
    [265889] = true, -- Torch Strike
    [257791] = true, -- Howling Fear
    [258864] = true, -- Suppression Fire
    [257028] = true, -- Fuselighter
    [258917] = true, -- Righteous Flames
    [257777] = true, -- Crippling Shiv
    [258079] = true, -- Massive Chomp
    [258058] = true, -- Squeeze
    [260016] = true, -- Itchy Bite
    [257119] = true, -- Sand Trap
    [260067] = true, -- Vicious Mauling
    [258313] = true, -- Handcuff
    [259711] = true, -- Lockdown
    [256198] = true, -- Azerite Rounds: Incendiary
    [256101] = true, -- Explosive Burst (mythic)
    [256105] = true, -- Explosive Burst (mythic+)
    [256044] = true, -- Deadeye
    [256474] = true, -- Heartstopper Venom
    -- Waycrest Manor
    [260703] = true, -- Unstable Runic Mark
    [263905] = true, -- Marking Cleave
    [265880] = true, -- Dread Mark
    [265882] = true, -- Lingering Dread
    [264105] = true, -- Runic Mark
    [264050] = true, -- Infected Thorn
    [261440] = true, -- Virulent Pathogen
    [263891] = true, -- Grasping Thorns
    [264378] = true, -- Fragment Soul
    [266035] = true, -- Bone Splinter
    [266036] = true, -- Drain Essence
    [260907] = true, -- Soul Manipulation
    [260741] = true, -- Jagged Nettles
    [264556] = true, -- Tearing Strike
    [265760] = true, -- Thorned Barrage
    [260551] = true, -- Soul Thorns
    [263943] = true, -- Etch
    [265881] = true, -- Decaying Touch
    [261438] = true, -- Wasting Strike
    [268202] = true, -- Death Lens
    [278456] = true, -- Infest
    [264153] = true, -- Spit
    -- AtalDazar
    [252781] = true, -- Unstable Hex
    [250096] = true, -- Wracking Pain
    [250371] = true, -- Lingering Nausea
    [253562] = true, -- Wildfire
    [255582] = true, -- Molten Gold
    [255041] = true, -- Terrifying Screech
    [255371] = true, -- Terrifying Visage
    [252687] = true, -- Venomfang Strike
    [254959] = true, -- Soulburn
    [255814] = true, -- Rending Maul
    [255421] = true, -- Devour
    [255434] = true, -- Serrated Teeth
    [256577] = true, -- Soulfeast
    -- Kings Rest
    [270492] = true, -- Hex
    [267763] = true, -- Wretched Discharge
    [276031] = true, -- Pit of Despair
    [265773] = true, -- Spit Gold
    [270920] = true, -- Seduction
    [270865] = true, -- Hidden Blade
    [271564] = true, -- Embalming Fluid
    [270507] = true, -- Poison Barrage
    [267273] = true, -- Poison Nova
    [270003] = true, -- Suppression Slam
    [270084] = true, -- Axe Barrage
    [267618] = true, -- Drain Fluids
    [267626] = true, -- Dessication
    [270487] = true, -- Severing Blade
    [266238] = true, -- Shattered Defenses
    [266231] = true, -- Severing Axe
    [266191] = true, -- Whirling Axes
    [272388] = true, -- Shadow Barrage
    [271640] = true, -- Dark Revelation
    [268796] = true, -- Impaling Spear
    [268419] = true, -- Gale Slash
    [269932] = true, -- Gust Slash
    -- Motherlode
    [263074] = true, -- Festering Bite
    [280605] = true, -- Brain Freeze
    [257337] = true, -- Shocking Claw
    [270882] = true, -- Blazing Azerite
    [268797] = true, -- Transmute: Enemy to Goo
    [259856] = true, -- Chemical Burn
    [269302] = true, -- Toxic Blades
    [280604] = true, -- Iced Spritzer
    [257371] = true, -- Tear Gas
    [257544] = true, -- Jagged Cut
    [268846] = true, -- Echo Blade
    [262794] = true, -- Energy Lash
    [262513] = true, -- Azerite Heartseeker
    [260829] = true, -- Homing Missle (travelling)
    [260838] = true, -- Homing Missle (exploded)
    [263637] = true, -- Clothesline
    -- Temple of Sethraliss
    [269686] = true, -- Plague
    [268013] = true, -- Flame Shock
    [268008] = true, -- Snake Charm
    [273563] = true, -- Neurotoxin
    [272657] = true, -- Noxious Breath
    [267027] = true, -- Cytotoxin
    [272699] = true, -- Venomous Spit
    [263371] = true, -- Conduction
    [272655] = true, -- Scouring Sand
    [263914] = true, -- Blinding Sand
    [263958] = true, -- A Knot of Snakes
    [266923] = true, -- Galvanize
    [268007] = true, -- Heart Attack
    -- Underrot
    [265468] = true, -- Withering Curse
    [278961] = true, -- Decaying Mind
    [259714] = true, -- Decaying Spores
    [272180] = true, -- Death Bolt
    [272609] = true, -- Maddening Gaze
    [269301] = true, -- Putrid Blood
    [265533] = true, -- Blood Maw
    [265019] = true, -- Savage Cleave
    [265377] = true, -- Hooked Snare
    [265625] = true, -- Dark Omen
    [260685] = true, -- Taint of G'huun
    [266107] = true, -- Thirst for Blood
    [260455] = true, -- Serrated Fangs
    -- Operation Mechagon
    [291928] = true, -- Giga-Zap
    [292267] = true, -- Giga-Zap
    [302274] = true, -- Fulminating Zap
    [298669] = true, -- Taze
    [295445] = true, -- Wreck
    [294929] = true, -- Blazing Chomp
    [297257] = true, -- Electrical Charge
    [294855] = true, -- Blossom Blast
    [291972] = true, -- Explosive Leap
    [285443] = true, -- "Hidden" Flame Cannon
    [291974] = true, -- Obnoxious Monologue
    [296150] = true, -- Vent Blast
    [298602] = true, -- Smoke Cloud
    [296560] = true, -- Clinging Static
    [297283] = true, -- Cave In
    [291914] = true, -- Cutting Beam
    [302384] = true, -- Static Discharge
    [294195] = true, -- Arcing Zap
    [299572] = true, -- Shrink
    [300659] = true, -- Consuming Slime
    [300650] = true, -- Suffocating Smog
    [301712] = true, -- Pounce
    [299475] = true, -- B.O.R.K
    [293670] = true, -- Chain Blade

-- Castle Nathria
    -- Shriekwing
    [328897] = true,  -- Exsanguinated
    [330713] = true,  -- Reverberating Pain
    [329370] = true,  -- Deadly Descent
    [336494] = true,  -- Echo Screech
    -- Huntsman Altimor
    [335304] = true,  -- Sinseeker
    [334971] = true,  -- Jagged Claws
    [335113] = true,  -- Huntsman's Mark 1
    [335112] = true,  -- Huntsman's Mark 2
    [335111] = true,  -- Huntsman's Mark 3
    [334945] = true,  -- Bloody Thrash
    -- Hungering Destroyer
    [334228] = true,  -- Volatile Ejection
    [329298] = true,  -- Gluttonous Miasma
    -- Lady Inerva Darkvein
    [325936] = true,  -- Shared Cognition
    [335396] = true,  -- Hidden Desire
    [324983] = true,  -- Shared Suffering
    [324982] = true,  -- Shared Suffering Partner
    [332664] = true,  -- Concentrate Anima
    [325382] = true,  -- Warped Desires
    -- Sun King's Salvation
    [333002] = true,  -- Vulgar Brand
    [326078] = true,  -- Infuser's Boon
    [325251] = true,  -- Sin of Pride
    -- Artificer Xy'mox
    [327902] = true,  -- Fixate
    [326302] = true,  -- Stasis Trap
    [325236] = true,  -- Glyph of Destruction
    [327414] = true,  -- Possession
    -- The Council of Blood
    [327773] = true,  -- Drain Essence 1
    [327052] = true,  -- Drain Essence 2
    [328334] = true,  -- Tactical Advance
    [330848] = true,  -- Wrong Moves
    [331706] = true,  -- Scarlet Letter
    [331636] = true,  -- Dark Recital 1
    [331637] = true,  -- Dark Recital 2
    -- Sludgefist
    [335470] = true,  -- Chain Slam
    [339181] = true,  -- Chain Slam (Root)
    [331209] = true,  -- Hateful Gaze
    [335293] = true,  -- Chain Link
    [335270] = true,  -- Chain This One!
    [335295] = true,  -- Shattering Chain
    -- Stone Legion Generals
    [334498] = true,  -- Seismic Upheaval
    [337643] = true,  -- Unstable Footing
    [334765] = true,  -- Stone Shatterer
    [333377] = true,  -- Wicked Mark
    [334616] = true,  -- Petrified
    [334541] = true,  -- Curse of Petrification
    -- Sire Denathrius
    [326851] = true,  -- Blood Price
    [327798] = true,  -- Night Hunter
    [327992] = true,  -- Desolation
    [328276] = true,  -- March of the Penitent
    [326699] = true,  -- Burden of Sin

-- Uldir
    -- MOTHER
    [268277] = true, -- Purifying Flame
    [268253] = true, -- Surgical Beam
    [268095] = true, -- Cleansing Purge
    [267787] = true, -- Sundering Scalpel
    [268198] = true, -- Clinging Corruption
    [267821] = true, -- Defense Grid
    -- Vectis
    [265127] = true, -- Lingering Infection
    [265178] = true, -- Mutagenic Pathogen
    [265206] = true, -- Immunosuppression
    [265212] = true, -- Gestate
    [265129] = true, -- Omega Vector
    [267160] = true, -- Omega Vector
    [267161] = true, -- Omega Vector
    [267162] = true, -- Omega Vector
    [267163] = true, -- Omega Vector
    [267164] = true, -- Omega Vector
    -- Mythrax
    [272536] = true, -- Imminent Ruin
    [274693] = true, -- Essence Shear
    [272407] = true, -- Oblivion Sphere
    -- Fetid Devourer
    [262313] = true, -- Malodorous Miasma
    [262292] = true, -- Rotting Regurgitation
    [262314] = true, -- Deadly Disease
    -- Taloc
    [270290] = true, -- Blood Storm
    [275270] = true, -- Fixate
    [271224] = true, -- Plasma Discharge
    [271225] = true, -- Plasma Discharge
    -- Zul
    [273365] = true, -- Dark Revelation
    [273434] = true, -- Pit of Despair
    [272018] = true, -- Absorbed in Darkness
    [274358] = true, -- Rupturing Blood
    -- Zekvoz
    [265237] = true, -- Shatter
    [265264] = true, -- Void Lash
    [265360] = true, -- Roiling Deceit
    [265662] = true, -- Corruptor's Pact
    [265646] = true, -- Will of the Corruptor
    -- Ghuun
    [263436] = true, -- Imperfect Physiology
    [263227] = true, -- Putrid Blood
    [263372] = true, -- Power Matrix
    [272506] = true, -- Explosive Corruption
    [267409] = true, -- Dark Bargain
    [267430] = true, -- Torment
    [263235] = true, -- Blood Feast
    [270287] = true, -- Blighted Ground

-- Siege of Zuldazar
    -- Rawani Kanae / Frida Ironbellows
    [283573] = true, -- Sacred Blade
    [283617] = true, -- Wave of Light
    [283651] = true, -- Blinding Faith
    [284595] = true, -- Penance
    [283582] = true, -- Consecration
    -- Grong
    [285998] = true, -- Ferocious Roar
    [283069] = true, -- Megatomic Fire
    [285671] = true, -- Crushed
    [285875] = true, -- Rending Bite
    -- Jaina
    [285253] = true, -- Ice Shard
    [287993] = true, -- Chilling Touch
    [287365] = true, -- Searing Pitch
    [288038] = true, -- Marked Target
    [285254] = true, -- Avalanche
    [287626] = true, -- Grasp of Frost
    [287490] = true, -- Frozen Solid
    [287199] = true, -- Ring of Ice
    [288392] = true, -- Vengeful Seas
    -- Stormwall Blockade
    [284369] = true, -- Sea Storm
    [284410] = true, -- Tempting Song
    [284405] = true, -- Tempting Song
    [284121] = true, -- Thunderous Boom
    [286680] = true, -- Roiling Tides
    -- Opulence
    [286501] = true, -- Creeping Blaze
    [283610] = true, -- Crush
    [289383] = true, -- Chaotic Displacement
    [285479] = true, -- Flame Jet
    [283063] = true, -- Flames of Punishment
    [283507] = true, -- Volatile Charge
    -- King Rastakhan
    [284995] = true, -- Zombie Dust
    [285349] = true, -- Plague of Fire
    [285044] = true, -- Toad Toxin
    [284831] = true, -- Scorching Detonation
    [289858] = true, -- Crushed
    [284662] = true, -- Seal of Purification
    [284676] = true, -- Seal of Purification
    [285178] = true, -- Serpent's Breath
    [285010] = true, -- Poison Toad Slime
    -- Jadefire Masters
    [282037] = true, -- Rising Flames
    [284374] = true, -- Magma Trap
    [285632] = true, -- Stalking
    [288151] = true, -- Tested
    [284089] = true, -- Successful Defense
    [286988] = true, -- Searing Embers
    -- Mekkatorque
    [288806] = true, -- Gigavolt Blast
    [289023] = true, -- Enormous
    [286646] = true, -- Gigavolt Charge
    [288939] = true, -- Gigavolt Radiation
    [284168] = true, -- Shrunk
    [286516] = true, -- Anti-Tampering Shock
    [286480] = true, -- Anti-Tampering Shock
    [284214] = true, -- Trample
    -- Conclave of the Chosen
    [284663] = true, -- Bwonsamdi's Wrath
    [282444] = true, -- Lacerating Claws
    [282592] = true, -- Bleeding Wounds
    [282209] = true, -- Mark of Prey
    [285879] = true, -- Mind Wipe
    [282135] = true, -- Crawling Hex
    [286060] = true, -- Cry of the Fallen
    [282447] = true, -- Kimbul's Wrath
    [282834] = true, -- Kimbul's Wrath
    [286811] = true, -- Akunda's Wrath
    [286838] = true, -- Static Orb

-- Crucible of Storms
    -- The Restless Cabal
    [282386] = true, -- Aphotic Blast
    [282384] = true, -- Shear Mind
    [282566] = true, -- Promises of Power
    [282561] = true, -- Dark Herald
    [282432] = true, -- Crushing Doubt
    [282589] = true, -- Mind Scramble
    [292826] = true, -- Mind Scramble
    -- Fathuul the Feared
    [284851] = true, -- Touch of the End
    [286459] = true, -- Feedback: Void
    [286457] = true, -- Feedback: Ocean
    [286458] = true, -- Feedback: Storm
    [285367] = true, -- Piercing Gaze of N'Zoth
    [284733] = true, -- Embrace of the Void
    [284722] = true, -- Umbral Shell
    [285345] = true, -- Maddening Eyes of N'Zoth
    [285477] = true, -- Obscurity
    [285652] = true, -- Insatiable Torment

-- Eternal Palace
    -- Lady Ashvane
    [296693] = true, -- Waterlogged
    [296725] = true, -- Barnacle Bash
    [296942] = true, -- Arcing Azerite
    [296938] = true, -- Arcing Azerite
    [296941] = true, -- Arcing Azerite
    [296939] = true, -- Arcing Azerite
    [296943] = true, -- Arcing Azerite
    [296940] = true, -- Arcing Azerite
    [296752] = true, -- Cutting Coral
    [297333] = true, -- Briny Bubble
    [297397] = true, -- Briny Bubble
    -- Abyssal Commander Sivara
    [300701] = true, -- Rimefrost
    [300705] = true, -- Septic Taint
    [294847] = true, -- Unstable Mixture
    [295850] = true, -- Delirious
    [295421] = true, -- Overflowing Venom
    [295348] = true, -- Overflowing Chill
    [295807] = true, -- Frozen
    [300883] = true, -- Inversion Sickness
    [295705] = true, -- Toxic Bolt
    [295704] = true, -- Frost Bolt
    [294711] = true, -- Frost Mark
    [294715] = true, -- Toxic Brand
    -- The Queens Court
    [301830] = true, -- Pashmar's Touch
    [296851] = true, -- Fanatical Verdict
    [297836] = true, -- Potent Spark
    [297586] = true, -- Suffering
    [304410] = true, -- Repeat Performance
    [299914] = true, -- Frenetic Charge
    [303306] = true, -- Sphere of Influence
    [300545] = true, -- Mighty Rupture
    -- Radiance of Azshara
    [296566] = true, -- Tide Fist
    [296737] = true, -- Arcane Bomb
    [296746] = true, -- Arcane Bomb
    [295920] = true, -- Ancient Tempest
    [296462] = true, -- Squall Trap
    -- Orgozoa
    [298156] = true, -- Desensitizing Sting
    [298306] = true, -- Incubation Fluid
    -- Blackwater Behemoth
    [292127] = true, -- Darkest Depths
    [292138] = true, -- Radiant Biomass
    [292167] = true, -- Toxic Spine
    [301494] = true, -- Piercing Barb
    -- Zaqul
    [295495] = true, -- Mind Tether
    [295480] = true, -- Mind Tether
    [295249] = true, -- Delirium Realm
    [303819] = true, -- Nightmare Pool
    [293509] = true, -- Manifest Nightmares
    [295327] = true, -- Shattered Psyche
    [294545] = true, -- Portal of Madness
    [298192] = true, -- Dark Beyond
    [292963] = true, -- Dread
    [300133] = true, -- Snapped
    -- Queen Azshara
    [298781] = true, -- Arcane Orb
    [297907] = true, -- Cursed Heart
    [302999] = true, -- Arcane Vulnerability
    [302141] = true, -- Beckon
    [299276] = true, -- Sanction
    [303657] = true, -- Arcane Burst
    [298756] = true, -- Serrated Edge
    [301078] = true, -- Charged Spear
    [298014] = true, -- Cold Blast
    [298018] = true, -- Frozen

-- Nyalotha
    -- Wrathion
    [313255] = true, -- Creeping Madness (Slow Effect)
    [306163] = true, -- Incineration
    [306015] = true, -- Searing Armor [tank]
    -- Maut
    [307805] = true, -- Devour Magic
    [314337] = true, -- Ancient Curse
    [306301] = true, -- Forbidden Mana
    [314992] = true, -- Darin Essence
    [307399] = true, -- Shadow Claws [tank]
    -- Prophet Skitra
    [306387] = true, -- Shadow Shock
    [313276] = true, -- Shred Psyche
    -- Dark Inquisitor
    [306311] = true, -- Soul Flay
    [312406] = true, -- Void Woken
    [311551] = true, -- Abyssal Strike [tank]
    -- Hivemind
    [313461] = true, -- Corrosion
    [313672] = true, -- Acid Pool
    [313460] = true, -- Nullification
    -- Shadhar
    [307471] = true, -- Crush [tank]
    [307472] = true, -- Dissolve [tank]
    [307358] = true, -- Debilitating Spit
    [306928] = true, -- Umbral Breath
    [312530] = true, -- Entropic Breath
    [306929] = true, -- Bubbling Breath
    -- Drest
    [310406] = true, -- Void Glare
    [310277] = true, -- Volatile Seed [tank]
    [310309] = true, -- Volatile Vulnerability
    [310358] = true, -- Mutterings of Insanity
    [310552] = true, -- Mind Flay
    [310478] = true, -- Void Miasma
    -- Ilgy
    [309961] = true, -- Eye of Nzoth [tank]
    [310322] = true, -- Morass of Corruption
    [311401] = true, -- Touch of the Corruptor
    [314396] = true, -- Cursed Blood
    [275269] = true, -- Fixate
    [312486] = true, -- Recurring Nightmare
    -- Vexiona
    [307317] = true, -- Encroaching Shadows
    [307359] = true, -- Despair
    [315932] = true, -- Brutal Smash
    [307218] = true, -- Twilight Decimator
    [307284] = true, -- Terrifying Presence
    [307421] = true, -- Annihilation
    [307019] = true, -- Void Corruption [tank]
    -- Raden
    [306819] = true, -- Nullifying Strike [tank]
    [306279] = true, -- Insanity Exposure
    [315258] = true, -- Dread Inferno
    [306257] = true, -- Unstable Vita
    [313227] = true, -- Decaying Wound
    [310019] = true, -- Charged Bonds
    [316065] = true, -- Corrupted Existence
    -- Carapace
    [315954] = true, -- Black Scar [tank]
    [306973] = true, -- Madness
    [316848] = true, -- Adaptive Membrane
    [307044] = true, -- Nightmare Antibody
    [313364] = true, -- Mental Decay
    [317627] = true, -- Infinite Void
    -- Nzoth
    [318442] = true, -- Paranoia
    [313400] = true, -- Corrupted Mind
    [313793] = true, -- Flames of Insanity
    [316771] = true, -- Mindwrack
    [314889] = true, -- Probe Mind
    [317112] = true, -- Evoke Anguish
    [318976] = true, -- Stupefying Glare
}
GW.ImportendRaidDebuff = ImportendRaidDebuff
