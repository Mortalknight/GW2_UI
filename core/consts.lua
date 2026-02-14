local _, GW = ...

GW.WINDOW_FADE_DURATION = 0.2

GW.TextSizeType = {
    BIG_HEADER = 1,
    HEADER = 2,
    NORMAL = 3,
    SMALL = 4,
}

GW.TextColors = {
    LIGHT_HEADER = { r = 1, g = 0.9450, b = 0.8196 }
}

GW.ClassIndex = {
    WARRIOR = 1,
    PALADIN = 2,
    HUNTER = 3,
    ROGUE = 4,
    PRIEST = 5,
    DEATHKNIGHT = 6,
    SHAMAN = 7,
    MAGE = 8,
    WARLOCK = 9,
    MONK = 10,
    DRUID = 11,
    DEMONHUNTER = 12,
    EVOKER = 13,
}

GW.DispelType = {
	-- https://wago.tools/db2/SpellDispelType
	None = 0,
	Magic = 1,
	Curse = 2,
	Disease = 3,
	Poison = 4,
	Enrage = 9,
	Bleed = 11,
}

GW.DebuffColors = {
    [GW.DispelType.None] = CreateColor(220 / 255, 0, 0),
    [GW.DispelType.Curse] = CreateColor(97 / 255, 72 / 255, 177 / 255),
    [GW.DispelType.Disease] = CreateColor(177 / 255, 114 / 255, 72 / 255),
    [GW.DispelType.Magic] = CreateColor(72 / 255, 94 / 255, 177 / 255),
    [GW.DispelType.Poison] = CreateColor(94 / 255, 177 / 255, 72 / 255),
    [GW.DispelType.Bleed] = CreateColor(1, 0.2, 0.6),
    [GW.DispelType.Enrage] = CreateColor(243/255, 95/255, 245/255),
}

GW.FallbackColor = CreateColor(0, 0, 0, 0)

GW.PowerBarColorCustom = {
    MANA = { r = 37 / 255, g = 133 / 255, b = 240 / 255 },
    RAGE = { r = 240 / 255, g = 66 / 255, b = 37 / 255 },
    ENERGY = { r = 240 / 255, g = 200 / 255, b = 37 / 255 },
    LUNAR_POWER = { r = 130 / 255, g = 172 / 255, b = 230 / 255 },
    RUNIC_POWER = { r = 37 / 255, g = 214 / 255, b = 240 / 255 },
    FOCUS = { r = 240 / 255, g = 121 / 255, b = 37 / 255 },
    FURY = { r = 166 / 255, g = 37 / 255, b = 240 / 255 },
    PAIN = { r = 255 / 255, g = 156 / 255, b = 0 },
    MAELSTROM = { r = 0.00, g = 0.50, b = 1.00 },
    INSANITY = { r = 0.40, g = 0, b = 0.80 },
    CHI = { r = 0.71, g = 1.0, b = 0.92 },

    -- vehicle colors
    AMMOSLOT = { r = 0.80, g = 0.60, b = 0.00 },
    FUEL = { r = 0.0, g = 0.55, b = 0.5 },
    STAGGER = { r = 0.52, g = 1.0, b = 0.52 },
}

GW.BAG_TYP_COLORS = {
    [0x0001] = {r = 1, g = 1, b = 1},            --Quivers       1
    [0x0002] = {r = 1, g = 1, b = 1},            --Quivers       2
    [0x0004] = {r = 0.251, g = 0.878, b = 0.816},--Soul          3
    [0x0020] = {r = 0.451, g = 1, b = 0},        --Herbs         6
    [0x0040] = {r = 1, g = 0, b = 1}             --Enchanting    7
}

GW.nameRoleIcon = {
    TANK = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank.png:0:0:0:0:64:64:4:60:4:60|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer.png:0:0:0:0:64:64:4:60:4:60|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps.png:0:0:0:0:64:64:4:60:4:60|t ",
    NONE = ""
}

GW.nameRoleIconPure = {
    TANK = "Interface/AddOns/GW2_UI/textures/party/roleicon-tank.png",
    HEALER = "Interface/AddOns/GW2_UI/textures/party/roleicon-healer.png",
    DAMAGER = "Interface/AddOns/GW2_UI/textures/party/roleicon-dps.png",
    NONE = ""
}

GW.professionBagColor = {
    [8] = { r = .88, g = .73, b = .29 },  --leatherworking
    [16] = { r = .29, g = .30, b = .88 }, --inscription
    [32] = { r = .07, g = .71, b = .13 }, --herbs
    [64] = { r = .76, g = .02, b = .8 },  --enchanting
    [128] = { r = .91, g = .46, b = .18 }, --engineering
    [512] = { r = .03, g = .71, b = .81 }, --gems
    [1024] = { r = .54, g = .40, b = .04 }, --Mining Bag
    [32768] = { r = .42, g = .59, b = 1 }, --fishing
    [65536] = { r = .87, g = .05, b = .25 } --cooking
}

GW.trackingTypes = {
    [136025] = {l = 0.125, r = 0.250, t = 0, b = 0.5}, --mining
    [133939] = {l = 0, r = 0.125, t = 0, b = 0.5}, --herbalism
    [135974] = {l = 0.750, r = 0.875, t = 0, b = 0.5}, --undead
    [136142] = {l = 0.750, r = 0.875, t = 0, b = 0.5}, --undead
    ["1323283"] = {l = 0.875, r = 1, t = 0, b = 0.5}, --beast for hunter
    ["13232811"] = {l = 0, r = 0.125, t = 0.5, b = 1}, --human for druid
    [135942] = {l = 0, r = 0.125, t = 0.5, b = 1}, --human
    [136172] = {l = 0.250, r = 0.375, t = 0.5, b = 1}, --demon
    [136217] = {l = 0.250, r = 0.375, t = 0.5, b = 1}, --demon
    [135725] = {l = 0.375, r = 0.5, t = 0.5, b = 1}, --treasure
    [133888] = {l = 0.125, r = 0.250, t = 0.5, b = 1}, --fish
    [134153] = {l = 0.5, r = 0.625, t = 0, b = 0.5}, --Dragonkin
    [135861] = {l = 0.250, r = 0.375, t = 0, b = 0.5}, --Elementals
    [132275] = {l = 0.375, r = 0.5, t = 0, b = 0.5}, --Giants
    [132320] = {l = 0.625, r = 0.750, t = 0, b = 0.5}, --Hidden
}

GW.TRACKER_TYPE_COLOR = {
    QUEST = { r = 221 / 255, g = 198 / 255, b = 68 / 255 },
    CAMPAIGN = { r = 121 / 255, g = 222 / 255, b = 47 / 255 },
    EVENT = { r = 240 / 255, g = 121 / 255, b = 37 / 255 },
    SCENARIO = { r = 171 / 255, g = 37 / 255, b = 240 / 255 },
    BOSS = { r = 240 / 255, g = 37 / 255, b = 37 / 255 },
    ARENA = { r = 240 / 255, g = 37 / 255, b = 37 / 255 },
    ACHIEVEMENT = { r = 37 / 255, g = 240 / 255, b = 172 / 255 },
    DAILY = { r = 68 / 255, g = 192 / 255, b = 250 / 255 },
    TORGHAST = { r = 109 / 255, g = 161 / 255, b = 207 / 255 },
    RECIPE = { r = 228 / 255, g = 157 / 255, b = 0 / 255 },
    MONTHLYACTIVITY = { r = 228 / 255, g = 157 / 255, b = 0 / 255 },
    HOUSINGINITIATIVE = {r = 0.85, g = 0.7, b = 0.43},
    DELVE = { r = 171 / 255, g = 37 / 255, b = 240 / 255 }
}

GW.TRACKER_TYPE = {
    QUEST = "QUEST",
    CAMPAIGN = "CAMPAIGN",
    EVENT = "EVENT",
    SCENARIO = "SCENARIO",
    BOSS = "BOSS",
    ARENA = "ARENA",
    ACHIEVEMENT = "ACHIEVEMENT",
    DAILY = "DAILY",
    TORGHAST = "TORGHAST",
    RECIPE = "RECIPE",
    MONTHLYACTIVITY = "MONTHLYACTIVITY",
    HOUSINGINITIATIVE = "HOUSINGINITIATIVE",
    DELVE = "DELVE",
    DEAD = "DEAD"
}

GW.FACTION_BAR_COLORS = {
    [1] = { r = 0.8, g = 0.3, b = 0.22 },
    [2] = { r = 0.8, g = 0.3, b = 0.22 },
    [3] = { r = 0.75, g = 0.27, b = 0 },
    [4] = { r = 0.9, g = 0.7, b = 0 },
    [5] = { r = 0, g = 0.6, b = 0.1 },
    [6] = { r = 0, g = 0.6, b = 0.1 },
    [7] = { r = 0, g = 0.6, b = 0.1 },
    [8] = { r = 0, g = 0.6, b = 0.1 },
    [9] = { r = 0.22, g = 0.37, b = 0.98 }, --Paragon
    [10] = { r = 0.09, g = 0.29, b = 0.79 }, --Azerite
    [11] = { r = 0, g = 0.74, b = 0.95 },  --(Renown)
}

GW.COLOR_FRIENDLY = {
    [1] = { r = 88 / 255, g = 170 / 255, b = 68 / 255 }, --friendly #58aa44
    [2] = { r = 159 / 255, g = 36 / 255, b = 20 / 255 }, --enemy    #9f2414
    [3] = { r = 159 / 255, g = 159 / 255, b = 159 / 255 } --tapped   #9f9f9f
}
GW.BLOOD_SPARK = {
    [0] = { left = 0, right = 0.125, top = 0, bottom = 0.5 },
    [1] = { left = 0, right = 0.125, top = 0, bottom = 0.5 },
    [2] = { left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5 },
    [3] = { left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5 },
    [4] = { left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5 },
    [5] = { left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5 },
    [6] = { left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5 },
    [7] = { left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5 },
    [8] = { left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5 },

    [9] = { left = 0, right = 0.125, top = 0.5, bottom = 1 },
    [10] = { left = 0.125, right = 0.125 * 2, top = 0.5, bottom = 1 },
    [11] = { left = 0.125 * 2, right = 0.125 * 3, top = 0.5, bottom = 1 },
    [12] = { left = 0.125 * 3, right = 0.125 * 4, top = 0.5, bottom = 1 },
    [13] = { left = 0.125 * 4, right = 0.125 * 5, top = 0.5, bottom = 1 },
    [14] = { left = 0.125 * 5, right = 0.125 * 6, top = 0.5, bottom = 1 },
    [15] = { left = 0.125 * 6, right = 0.125 * 7, top = 0.5, bottom = 1 },
    [16] = { left = 0.125 * 7, right = 0.125 * 8, top = 0.5, bottom = 1 },

    [17] = { left = 0, right = 0.125, top = 0, bottom = 0.5 },
    [18] = { left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5 },
    [19] = { left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5 },
    [20] = { left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5 },
    [21] = { left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5 },
    [22] = { left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5 },
    [23] = { left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5 },
    [24] = { left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5 }
}

GW.CLASS_ICONS = {
    [0] = { l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1 },

    [1] = { l = 0.0625 * 11, r = 0.0625 * 12, t = 0, b = 1 },
    [2] = { l = 0.0625 * 10, r = 0.0625 * 11, t = 0, b = 1 },
    [3] = { l = 0.0625 * 9, r = 0.0625 * 10, t = 0, b = 1 },
    [4] = { l = 0.0625 * 8, r = 0.0625 * 9, t = 0, b = 1 },
    [5] = { l = 0.0625 * 7, r = 0.0625 * 8, t = 0, b = 1 },
    [6] = { l = 0.0625 * 6, r = 0.0625 * 7, t = 0, b = 1 },
    [7] = { l = 0.0625 * 5, r = 0.0625 * 6, t = 0, b = 1 },
    [8] = { l = 0.0625 * 4, r = 0.0625 * 5, t = 0, b = 1 },
    [9] = { l = 0.0625 * 3, r = 0.0625 * 4, t = 0, b = 1 },
    [10] = { l = 0.0625 * 2, r = 0.0625 * 3, t = 0, b = 1 },
    [11] = { l = 0.0625 * 1, r = 0.0625 * 2, t = 0, b = 1 },
    [12] = { l = 0, r = 0.0625 * 1, t = 0, b = 1 },
    [13] = { l = 0.0625 * 13, r = 0.0625 * 14, t = 0, b = 1 },
    dead = { l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1 }
}
GW.CLASS_ICONS.WARRIOR = GW.CLASS_ICONS[1]
GW.CLASS_ICONS.PALADIN = GW.CLASS_ICONS[2]
GW.CLASS_ICONS.HUNTER = GW.CLASS_ICONS[3]
GW.CLASS_ICONS.ROGUE = GW.CLASS_ICONS[4]
GW.CLASS_ICONS.PRIEST = GW.CLASS_ICONS[5]
GW.CLASS_ICONS.DEATHKNIGHT = GW.CLASS_ICONS[6]
GW.CLASS_ICONS.SHAMAN = GW.CLASS_ICONS[7]
GW.CLASS_ICONS.MAGE = GW.CLASS_ICONS[8]
GW.CLASS_ICONS.WARLOCK = GW.CLASS_ICONS[9]
GW.CLASS_ICONS.MONK = GW.CLASS_ICONS[10]
GW.CLASS_ICONS.DRUID = GW.CLASS_ICONS[11]
GW.CLASS_ICONS.DEMONHUNTER = GW.CLASS_ICONS[12]
GW.CLASS_ICONS.EVOKER = GW.CLASS_ICONS[13]

GW.GW_CLASS_COLORS = {
    WARRIOR = { r = 90 / 255, g = 54 / 255, b = 38 / 255, a = 1 },
    PALADIN = { r = 177 / 255, g = 72 / 255, b = 117 / 255, a = 1 },
    HUNTER = { r = 99 / 255, g = 125 / 255, b = 53 / 255, a = 1 },
    ROGUE = { r = 190 / 255, g = 183 / 255, b = 79 / 255, a = 1 },
    PRIEST = { r = 205 / 255, g = 205 / 255, b = 205 / 255, a = 1 },
    DEATHKNIGHT = { r = 148 / 255, g = 62 / 255, b = 62 / 255, a = 1 },
    SHAMAN = { r = 30 / 255, g = 44 / 255, b = 149 / 255, a = 1 },
    --MAGE = {r = 62 / 255, g = 121 / 255, b = 149 / 255, a = 1},
    MAGE = { r = 101 / 255, g = 157 / 255, b = 184 / 255, a = 1 },
    WARLOCK = { r = 125 / 255, g = 88 / 255, b = 154 / 255, a = 1 },
    MONK = { r = 66 / 255, g = 151 / 255, b = 112 / 255, a = 1 },
    DRUID = { r = 158 / 255, g = 103 / 255, b = 37 / 255, a = 1 },
    DEMONHUNTER = { r = 72 / 255, g = 38 / 255, b = 148 / 255, a = 1 },
    EVOKER = { r = 56 / 255, g = 99 / 255, b = 113 / 255, a = 1 }
}

GW.FACTION_COLOR = {
    [1] = { r = 163 / 255, g = 46 / 255, b = 54 / 255 }, --Horde
    [2] = { r = 57 / 255, g = 115 / 255, b = 186 / 255 } --Alliance
}

GW.TARGET_FRAME_ART = {
    minus = "Interface/AddOns/GW2_UI/textures/units/targetshadow.png",
    normal = "Interface/AddOns/GW2_UI/textures/units/targetshadow.png",
    elite = "Interface/AddOns/GW2_UI/textures/units/targetshadowelit.png",
    rare = "Interface/AddOns/GW2_UI/textures/units/targetshadowrare.png",
    rareelite = "Interface/AddOns/GW2_UI/textures/units/targetshadowrare.png",
    worldboss = "Interface/AddOns/GW2_UI/textures/units/targetshadow_boss.png",
    boss = "Interface/AddOns/GW2_UI/textures/units/targetshadow_boss.png",
    prestige1 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p1.png",
    prestige2 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p2.png",
    prestige3 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p3.png",
    prestige4 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p4.png",
    realboss = "Interface/AddOns/GW2_UI/textures/units/targetshadow-raidboss.png"
}

GW.REALM_FLAGS = {
    enUS = "|TInterface/AddOns/GW2_UI/textures/flags/us.png:10:12:0:0|t",
    ptBR = "|TInterface/AddOns/GW2_UI/textures/flags/br.png:10:12:0:0|t",
    ptPT = "|TInterface/AddOns/GW2_UI/textures/flags/pt.png:10:12:0:0|t",
    esMX = "|TInterface/AddOns/GW2_UI/textures/flags/mx.png:10:12:0:0|t",
    deDE = "|TInterface/AddOns/GW2_UI/textures/flags/de.png:10:12:0:0|t",
    enGB = "|TInterface/AddOns/GW2_UI/textures/flags/gb.png:10:12:0:0|t",
    koKR = "|TInterface/AddOns/GW2_UI/textures/flags/kr.png:10:12:0:0|t",
    frFR = "|TInterface/AddOns/GW2_UI/textures/flags/fr.png:10:12:0:0|t",
    esES = "|TInterface/AddOns/GW2_UI/textures/flags/es.png:10:12:0:0|t",
    itIT = "|TInterface/AddOns/GW2_UI/textures/flags/it.png:10:12:0:0|t",
    ruRU = "|TInterface/AddOns/GW2_UI/textures/flags/ru.png:10:12:0:0|t",
    zhTW = "|TInterface/AddOns/GW2_UI/textures/flags/tw.png:10:12:0:0|t",
    zhCN = "|TInterface/AddOns/GW2_UI/textures/flags/cn.png:10:12:0:0|t"
}

GW.ShortPrefixStyles = {
    TCHINESE = {{1e8, "億"}, {1e4, "萬"}},
    CHINESE = {{1e8, "亿"}, {1e4, "万"}},
    ENGLISH = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}},
    GERMAN = {{1e12, "Bio"}, {1e9, "Mrd"}, {1e6, "Mio"}, {1e3, "Tsd"}},
    KOREAN = {{1e8, "억"}, {1e4, "만"}, {1e3, "천"}},
    METRIC = {{1e12, "T"}, {1e9, "G"}, {1e6, "M"}, {1e3, "k"}}
}

GW.GemTypeInfo = {
	Yellow			= { r = 0.97, g = 0.82, b = 0.29 },
	Red				= { r = 1.00, g = 0.47, b = 0.47 },
	Blue			= { r = 0.47, g = 0.67, b = 1.00 },
	Hydraulic		= { r = 1.00, g = 1.00, b = 1.00 },
	Cogwheel		= { r = 1.00, g = 1.00, b = 1.00 },
	Meta			= { r = 1.00, g = 1.00, b = 1.00 },
	Prismatic		= { r = 1.00, g = 1.00, b = 1.00 },
	PunchcardRed	= { r = 1.00, g = 0.47, b = 0.47 },
	PunchcardYellow	= { r = 0.97, g = 0.82, b = 0.29 },
	PunchcardBlue	= { r = 0.47, g = 0.67, b = 1.00 },
}

GW.INDICATORS = { "BAR", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT" }
GW.indicatorsText = { "Bar", "Top Left", "Top", "Top Right", "Left", "Center", "Right" }

-- Taken from ElvUI: https://git.tukui.org/elvui/elvui/blob/master/ElvUI/Settings/Filters/UnitFrame.lua
-- Format: {class = {id = {r, g, b[, <spell-id-same-slot>]} ...}, ...}
if GW.Retail then
    GW.AURAS_INDICATORS = {
        PRIEST = {
            [194384] = { 1, 1, 0.66 },      -- Atonement
            [214206] = { 1, 1, 0.66 },      -- Atonement (PvP)
            [41635]  = { 1, 1, 0.66 },      -- Prayer of Mending
            [193065] = { 0.54, 0.21, 0.78 }, -- Masochism
            [139]    = { 0.4, 0.7, 0.2 },   -- Renew
            [17]     = { 0.7, 0.7, 0.7 },   -- Power Word: Shield
            [47788]  = { 0.86, 0.45, 0 },   -- Guardian Spirit
            [33206]  = { 0.47, 0.35, 0.74 }, -- Pain Suppression
            [6788]   = { 0.89, 0.1, 0.1 },  -- Weakened Soul
            [10060]  = { 1, 0.81, 0.11 },   -- Power Infusion
            [77489]  = { 0.75, 1, 0.3 },    -- Echo of Light
        },
        DRUID = {
            [774] = { 0.8, 0.4, 0.8 },      -- Rejuvenation
            [155777] = { 0.8, 0.4, 0.8 },   -- Germination
            [8936] = { 0.2, 0.8, 0.2 },     -- Regrowth
            [33763] = { 0.4, 0.8, 0.2 },    -- Lifebloom
            [188550] = { 0.4, 0.8, 0.2 },   -- Lifebloom Legendary version
            [48438] = { 0.8, 0.4, 0 },      -- Wild Growth
            [207386] = { 0.4, 0.2, 0.8 },   -- Spring Blossoms
            [102351] = { 0.2, 0.8, 0.8 },   -- Cenarion Ward (Initial Buff)
            [102352] = { 0.2, 0.8, 0.8 },   -- Cenarion Ward (HoT)
            [200389] = { 1, 1, 0.4 },       -- Cultivation
            [203554] = { 1, 1, 0.4 },       -- Focused Growth (PvP)
            [391891] = { 0.01, 0.75, 0.6 }, -- Adaptive Swarm
            [157982] = { 0.75, 0.75, 0.75 }, -- Tranquility
        },
        PALADIN = {
            [53563] = { 1, 0.3, 0 },         -- Beacon of Light
            [156910] = { 0, 0.7, 1, 53563 }, -- Beacon of Faith
            [200025] = { 1, 0.85, 0, 53563 }, -- Beacon of Virtue
            [1022] = { 0.2, 0.2, 1 },        -- Hand of Protection
            [1044] = { 0.89, 0.45, 0 },      -- Hand of Freedom
            [6940] = { 0.89, 0.1, 0.1 },     -- Hand of Sacrifice
            [223306] = { 0.7, 0.7, 0.3 },    -- Bestow Faith
            [287280] = { 1, 0.5, 0 },        -- Glimmer of Light
            [157047] = { 0.15, 0.58, 0.84 }, -- Saved by the Light (T25 Talent)
            [204018] = { 0.2, 0.2, 1 },      -- Blessing of Spellwarding
            [148039] = { 0.98, 0.5, 0.11 },  -- Barrier of Faith (accumulation)
            [395180] = { 0.93, 0.8, 0.36 },  -- Barrier of Faith (absorbtion)
        },
        SHAMAN = {
            [61295] = { 0.7, 0.3, 0.7 },      -- Riptide
            [974] = { 0.91, 0.8, 0.44 },      -- Earth Shield
            [383648] = { 0.91, 0.8, 0.44 },   -- Earth Shield (Elemental Orbit)
        },
        MONK = {
            [115175] = { 0.6, 0.9, 0.9 },   -- Soothing Mist
            [119611] = { 0.3, 0.8, 0.6 },   -- Renewing Mist
            [116849] = { 0.2, 0.8, 0.2 },   -- Life Cocoon
            [124682] = { 0.8, 0.8, 0.25 },  -- Enveloping Mist
            [191840] = { 0.27, 0.62, 0.7 }, -- Essence Font
            [116841] = { 0.12, 1.00, 0.53 }, -- Tiger's Lust (Freedom)
            [325209] = { 0.3, 0.8, 0.6 },   -- Enveloping Breath
        },
        ROGUE = {
            [57934] = { 0.89, 0.09, 0.05 } -- Tricks of the Trade
        },
        WARRIOR = {
            [3411] = { 0.89, 0.09, 0.05 }  -- Intervene
        },
        HUNTER = {
            [90361] = { 0.34, 0.47, 0.31 }, -- Spirit Mend (HoT)
        },
        DEMONHUNTER = {},
        WARLOCK = {},
        MAGE = {},
        DEATHKNIGHT = {},
        EVOKER = {
            [355941] = { 0.33, 0.33, 0.77 }, -- Dream Breath
            [363502] = { 0.33, 0.33, 0.7 }, -- Dream Flight
            [366155] = { 0.14, 1.00, 0.88 }, -- Reversion
            [364343] = { 0.13, 0.87, 0.50 }, -- Echo
            [357170] = { 0.11, 0.57, 0.7 }, -- Time Dilation
            [376788] = { 0.25, 0.25, 0.58 }, -- Dreaon Breath (echo)
            [367364] = { 0.09, 0.69, 0.61 }, -- Reversion (echo)
            [373267] = { 0.82, 0.29, 0.24 }, -- Life Bind (Verdant Embrace)
            [360827] = { 0.33, 0.33, 0.77 }, -- Blistering Scales
            [410089] = { 0.13, 0.87, 0.50 }, -- Prescience
            [395296] = { 0.98, 0.44, 0.00 }, -- Ebon Might < self
            [395152] = { 0.98, 0.44, 0.00 }, -- Ebon Might < others
            [361022] = { 0.98, 0.44, 0.00 }, -- Sense Power
            [406732] = { 0.82, 0.29, 0.24 }, -- Spatial Paradox
            [406789] = { 0.82, 0.29, 0.24 }, -- Spatial Paradox
        },
        PET = {
            [193396] = { 0.6, 0.2, 0.8 },   -- Demonic Empowerment
            [19615] = { 0.89, 0.09, 0.05 }, -- Frenzy
            [136] = { 0.2, 0.8, 0.2 }       -- Mend Pet
        }
    }
elseif GW.Classic then
    GW.AURAS_INDICATORS = {
        PRIEST = {
            --[1243] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 1
            --[1244] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 2
            --[1245] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 3
            --[2791] =    {1, 1, 0.66},       -- Power Word: Fortitude Rank 4
            [10937] =   {1, 1, 0.66},       -- Power Word: Fortitude Rank 5
            [10938] =   {1, 1, 0.66},       -- Power Word: Fortitude Rank 6
            --[21562] =   {1, 1, 0.66},       -- Prayer of Fortitude Rank 1
            [21564] =   {1, 1, 0.66},       -- Prayer of Fortitude Rank 2
            --[14752] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 1
            --[14818] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 2
            [14819] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 3
            [27841] =   {0.2, 0.7, 0.2},    -- Divine Spirit Rank 4
            [27581] =   {0.2, 0.7, 0.2},    -- Prayer of Spirit Rank 1
            --[976] =     {0.7, 0.7, 0.7},    -- Shadow Protection Rank 1
            [10957] =   {0.7, 0.7, 0.7},    -- Shadow Protection Rank 2
            [10958] =   {0.7, 0.7, 0.7},    -- Shadow Protection Rank 3
            [27683] =   {0.7, 0.7, 0.7},    -- Prayer of Shadow Protection Rank 1
            --[17] =      {0, 0, 1},          -- Power Word: Shield Rank 1
            --[592] =     {0, 0, 1},          -- Power Word: Shield Rank 2
            --[600] =     {0, 0, 1},          -- Power Word: Shield Rank 3
            --[3747] =    {0, 0, 1},          -- Power Word: Shield Rank 4
            --[6065] =    {0, 0, 1},          -- Power Word: Shield Rank 5
            --[6066] =    {0, 0, 1},          -- Power Word: Shield Rank 6
            [10898] =   {0, 0, 1},          -- Power Word: Shield Rank 7
            [10899] =   {0, 0, 1},          -- Power Word: Shield Rank 8
            [10900] =   {0, 0, 1},          -- Power Word: Shield Rank 9
            [10901] =   {0, 0, 1},          -- Power Word: Shield Rank 10
            --[139] =     {0.33, 0.73, 0.75}, -- Renew Rank 1
            --[6074] =    {0.33, 0.73, 0.75}, -- Renew Rank 2
            --[6075] =    {0.33, 0.73, 0.75}, -- Renew Rank 3
            --[6076] =    {0.33, 0.73, 0.75}, -- Renew Rank 4
            --[6077] =    {0.33, 0.73, 0.75}, -- Renew Rank 5
            --[6078] =    {0.33, 0.73, 0.75}, -- Renew Rank 6
            [10927] =   {0.33, 0.73, 0.75}, -- Renew Rank 7
            [10928] =   {0.33, 0.73, 0.75}, -- Renew Rank 8
            [10929] =   {0.33, 0.73, 0.75}, -- Renew Rank 9
            [25315] =   {0.33, 0.73, 0.75}, -- Renew Rank 10
        },
        DRUID = {
            --[1126] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 1
            --[5232] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 2
            --[6756] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 3
            --[5234] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 4
            [8907] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 5
            [9884] =    {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 6
            [16878] =   {0.2, 0.8, 0.8},    -- Mark of the Wild Rank 7
            [21849] =   {0.8, 0.8, 0.8},    -- Gift of the Wild Rank 1
            [21850] =   {0.2, 0.8, 0.8},    -- Gift of the Wild Rank 2
            --[467] =     {0.4, 0.2, 0.8},    -- Thorns Rank 1
            --[782] =     {0.4, 0.2, 0.8},    -- Thorns Rank 2
            --[1075] =    {0.4, 0.2, 0.8},    -- Thorns Rank 3
            [8914] =    {0.4, 0.2, 0.8},    -- Thorns Rank 4
            [9756] =    {0.4, 0.2, 0.8},    -- Thorns Rank 5
            [9910] =    {0.4, 0.2, 0.8},    -- Thorns Rank 6
            --[774] =     {0.83, 1, 0.25},    -- Rejuvenation Rank 1
            --[1058] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 2
            --[1430] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 3
            --[2090] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 4
            --[2091] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 5
            --[3627] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 6
            --[8910] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 7
            [9839] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 8
            [9840] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 9
            [9841] =    {0.83, 1, 0.25},    -- Rejuvenation Rank 10
            [25299] =   {0.83, 1, 0.25},    -- Rejuvenation Rank 11
            --[8936] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 1
            --[8938] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 2
            --[8939] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 3
            --[8940] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 4
            --[8941] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 5
            --[9750] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 6
            [9856] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 7
            [9857] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 8
            [9858] =    {0.33, 0.73, 0.75}, -- Regrowth  Rank 9
            [29166] =   {0.49, 0.6, 0.55},  -- Innervate
        },
        PALADIN = {
            [1044] =    {0.89, 0.45, 0},    -- Blessing of Freedom
            [6940] =    {0.89, 0.1, 1},     -- Blessing Sacrifice Rank 1
            [20729] =   {0.89, 0.1, 1},     -- Blessing Sacrifice Rank 1
            --[19740] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 1
            --[19834] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 2
            --[19835] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 3
            --[19836] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 4
            [19837] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 5
            [19838] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 6
            [25291] =   {0.2, 0.8, 0.2},    -- Blessing of Might Rank 7
            --[19742] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 1
            --[19850] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 2
            --[19852] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 3
            --[19853] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 4
            [19854] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 5
            [25290] =   {0.2, 0.8, 0.2},    -- Blessing of Wisdom Rank 6
            --[25782] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Might Rank 1
            [25916] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Might Rank 2
            --[25894] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Wisdom Rank 1
            [25918] =   {0.2, 0.8, 0.2},    -- Greater Blessing of Wisdom Rank 2
            --[465] =     {0.58, 1, 0.5},     -- Devotion Aura Rank 1
            --[10290] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 2
            --[643] =     {0.58, 1, 0.5},     -- Devotion Aura Rank 3
            --[10291] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 4
            --[1032] =    {0.58, 1, 0.5},     -- Devotion Aura Rank 5
            --[10292] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 6
            [10293] =   {0.58, 1, 0.5},     -- Devotion Aura Rank 7
            --[19977] =   {0.17, 1, 0.75},    -- Blessing of Light Rank 1
            [19978] =   {0.17, 1, 0.75},    -- Blessing of Light Rank 2
            [19979] =   {0.17, 1, 0.75},    -- Blessing of Light Rank 3
            --[1022] =    {0.17, 1, 0.75},    -- Blessing of Protection Rank 1
            [5599] =    {0.17, 1, 0.75},    -- Blessing of Protection Rank 2
            [10278] =   {0.17, 1, 0.75},    -- Blessing of Protection Rank 3
            [19746] =   {0.83, 1, 0.07},    -- Concentration Aura
        },
        SHAMAN = {
            [29203] =   {0.7, 0.3, 0.7},    -- Healing Way
            [16237] =   {0.2, 0.2, 1},      -- Ancestral Fortitude
            [25909] =   {0, 0, 0.5},        -- Tranquil Air
            --[8185] =    {0.05, 1, 0.5},     -- Fire Resistance Totem Rank 1
            [10534] =   {0.05, 1, 0.5},     -- Fire Resistance Totem Rank 2
            [10535] =   {0.05, 1, 0.5},     -- Fire Resistance Totem Rank 3
            --[8182] =    {0.54, 0.53, 0.79}, -- Frost Resistance Totem Rank 1
            [10476] =   {0.54, 0.53, 0.79}, -- Frost Resistance Totem Rank 2
            [10477] =   {0.54, 0.53, 0.79}, -- Frost Resistance Totem Rank 3
            --[10596] =   {0.33, 1, 0.2},     -- Nature Resistance Totem Rank 1
            [10598] =   {0.33, 1, 0.2},     -- Nature Resistance Totem Rank 2
            [10599] =   {0.33, 1, 0.2},     -- Nature Resistance Totem Rank 3
            --[5672] =    {0.67, 1, 0.5},     -- Healing Stream Totem Rank 1
            --[6371] =    {0.67, 1, 0.5},     -- Healing Stream Totem Rank 2
            --[6372] =    {0.67, 1, 0.5},     -- Healing Stream Totem Rank 3
            [10460] =   {0.67, 1, 0.5},     -- Healing Stream Totem Rank 4
            [10461] =   {0.67, 1, 0.5},     -- Healing Stream Totem Rank 5
            --[16191] =   {0.67, 1, 0.8},     -- Mana Tide Totem Rank 1
            [17355] =   {0.67, 1, 0.8},     -- Mana Tide Totem Rank 2
            [17360] =   {0.67, 1, 0.8},     -- Mana Tide Totem Rank 3
            --[5677] =    {0.67, 1, 0.8},     -- Mana Spring Totem Rank 1
            --[10491] =   {0.67, 1, 0.8},     -- Mana Spring Totem Rank 2
            [10493] =   {0.67, 1, 0.8},     -- Mana Spring Totem Rank 3
            [10494] =   {0.67, 1, 0.8},     -- Mana Spring Totem Rank 4
            --[8072] =    {0, 0, 0.26},       -- Stoneskin Totem Rank 1
            --[8156] =    {0, 0, 0.26},       -- Stoneskin Totem Rank 2
            --[8157] =    {0, 0, 0.26},       -- Stoneskin Totem Rank 3
            [10403] =   {0, 0, 0.26},       -- Stoneskin Totem Rank 4
            [10404] =   {0, 0, 0.26},       -- Stoneskin Totem Rank 5
            [10405] =   {0, 0, 0.26},       -- Stoneskin Totem Rank 6
        },
        ROGUE = {}, --No buffs
        WARRIOR = {
            --[6673] =    {0.2, 0.2, 1},      -- Battle Shout Rank 1
            --[5242] =    {0.2, 0.2, 1},      -- Battle Shout Rank 2
            --[6192] =    {0.2, 0.2, 1},      -- Battle Shout Rank 3
            --[11549] =   {0.2, 0.2, 1},      -- Battle Shout Rank 4
            --[11550] =   {0.2, 0.2, 1},      -- Battle Shout Rank 5
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
            --[1459] =    {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 1
            --[1460] =    {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 2
            --[1461] =    {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 3
            --[10156] =   {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 4
            [10157] =   {0.89, 0.09, 0.05}, -- Arcane Intellect Rank 5
            --[23028] =   {0.89, 0.09, 0.05}, -- Arcane Brilliance Rank 1
            [27127] =   {0.89, 0.09, 0.05}, -- Arcane Brilliance Rank 2
            --[604] =     {0.2, 0.8, 0.2},    -- Dampen Magic Rank 1
            --[8450] =    {0.2, 0.8, 0.2},    -- Dampen Magic Rank 2
            --[8451] =    {0.2, 0.8, 0.2},    -- Dampen Magic Rank 3
            --[10173] =   {0.2, 0.8, 0.2},    -- Dampen Magic Rank 4
            [10174] =   {0.2, 0.8, 0.2},    -- Dampen Magic Rank 5
            --[1008] =    {0.2, 0.8, 0.2},    -- Amplify Magic Rank 1
            --[8455] =    {0.2, 0.8, 0.2},    -- Amplify Magic Rank 2
            --[10169] =   {0.2, 0.8, 0.2},    -- Amplify Magic Rank 3
            [10170] =   {0.2, 0.8, 0.2},    -- Amplify Magic Rank 4
            [12438] =   {0, 0, 0.5},        -- Slow Fall
        }
    }

    if GW.ClassicSOD then
        GW.AURAS_INDICATORS.DRUID[408120] = {0.38, 0.19, 0.43} -- Wild Growth
        GW.AURAS_INDICATORS.MAGE[400735] = {0.38, 0.19, 0.43} -- Temporal Beacon
        GW.AURAS_INDICATORS.PRIEST[401877] = {0.00, 0.00, 0.90} -- Prayer of Mending
        GW.AURAS_INDICATORS.PRIEST[402004] =  {0.00, 0.00, 0.83} -- Pain Suppression
    end
elseif GW.Mists then --TODO
    GW.AURAS_INDICATORS = {
        PRIEST = {
            [17]	= {0.00, 0.00, 1.00}, -- Power Word: Shield
            [139]	= {0.33, 0.73, 0.75}, -- Renew
            [6788]	= {0.89, 0.1, 0.1}, -- Weakened Soul
            [41635]	= {0.2, 0.7, 0.2}, -- Prayer of Mending
            [10060] = {0.17, 1.00, 0.45}, -- Power Infusion
            [47788] = {0.17, 1.00, 0.45}, -- Guardian Spirit
            [33206] = {0.17, 1.00, 0.45}, -- Pain Suppression
        },
        DRUID = {
            [467]	= {0.4, 0.2, 0.8}, -- Thorns
            [774]	= {0.83, 1.00, 0.25}, -- Rejuvenation
            [8936]	= {0.33, 0.73, 0.75}, -- Regrowth
            [29166]	= {0.49, 0.60, 0.55}, -- Innervate
            [33763]	= {0.33, 0.37, 0.47}, -- Lifebloom
            [48438]	= {0.8, 0.4, 0}, -- Wild Growth
        },
        PALADIN = {
            [1044]	= {0.89, 0.45, 0}, -- Hand of Freedom
            [1038]	= {0.11, 1.00, 0.45}, -- Hand of Salvation
            [6940]	= {0.89, 0.1, 0.1}, -- Hand of Sacrifice
            [1022]	= {0.17, 1.00, 0.75}, -- Hand of Protection
            [53563]	= {0.7, 0.3, 0.7}, -- Beacon of Light
        },
        SHAMAN = {
            [16177]	= {0.2, 0.2, {116236,16237}}, -- Ancestral Fortitude
            [974]	= {0.08, 0.21, 0.43}, -- Earth Shield
            [61295] = {0.7, 0.3, 0.7}, -- Riptide
            [51945] = {0.7, 0.3, 0.7}, -- Earthliving
        },
        ROGUE = {
            [57933] = {0.17, 1.00, 0.45}, -- Tricks of the Trade
        },
        WARRIOR = {
            [3411]	= {0.2, 0.2, 1}, -- Intervene
            [50720]	= {0.4, 0.2, 0.8}, -- Vigilance
        },
        HUNTER = {
            [34477] = {0.17, 1.00, 0.45},-- Misdirection
        },
        WARLOCK = {
            [5697]	= {0.89, 0.09, 0.05}, -- Unending Breath
            [20707]	= {0.00, 0.00, 0.85}, -- Soulstone
        },
        MAGE = {
            [130]	= {0.00, 0.00, 0.50}, -- Slow Fall
            [54646] = {0.17, 1.00, 0.45}, -- Focus Magic
        },
        DEATHKNIGHT = {
            [49016] = {0.17, 1.00, 0.45}, -- Unholy Frenzy
        },
        MONK = {
            [119611] = { 0.8, 0.4, 0.8 },   -- Renewing Mist
            [116849] = { 0.2, 0.8, 0.2 },   -- Life Cocoon
            [124081] = { 0.7, 0.4, 0 },  -- Zen Sphere
            [132120] = { 0.4, 0.8, 0.2 }, -- Enveloping Mist
        },
    }
elseif GW.TBC then
    GW.AURAS_INDICATORS = {
        PRIEST = {
            [1243]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 1)
            [1244]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 2)
            [1245]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 3)
            [2791]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 4)
            [10937]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 5)
            [10938]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 6)
            [25389]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 7)
            [21562]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 1)
            [21564]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 2)
            [25392]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 3)
            [14752]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 1)
            [14818]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 2)
            [14819]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 3)
            [27841]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 4)
            [25312]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 5)
            [27681]   = {0.2, 0.7, 0.2}, -- Prayer of Spirit(Rank 1)
            [32999]   = {0.2, 0.7, 0.2}, -- Prayer of Spirit(Rank 2)
            [976]     = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 1)
            [10957]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 2)
            [10958]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 3)
            [25433]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 4)
            [27683]   = {0.7, 0.7, 0.7}, -- Prayer of Shadow Protection(Rank 1)
            [39374]   = {0.7, 0.7, 0.7}, -- Prayer of Shadow Protection(Rank 2)
            [17]      = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 1)
            [592]     = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 2)
            [600]     = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 3)
            [3747]    = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 4)
            [6065]    = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 5)
            [6066]    = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 6)
            [10898]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 7)
            [10899]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 8)
            [10900]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 9)
            [10901]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 10)
            [25217]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 11)
            [25218]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 12)
            [139]     = {0.33, 0.73, 0.75}, -- Renew(Rank 1)
            [6074]    = {0.33, 0.73, 0.75}, -- Renew(Rank 2)
            [6075]    = {0.33, 0.73, 0.75}, -- Renew(Rank 3)
            [6076]    = {0.33, 0.73, 0.75}, -- Renew(Rank 4)
            [6077]    = {0.33, 0.73, 0.75}, -- Renew(Rank 5)
            [6078]    = {0.33, 0.73, 0.75}, -- Renew(Rank 6)
            [10927]   = {0.33, 0.73, 0.75}, -- Renew(Rank 7)
            [10928]   = {0.33, 0.73, 0.75}, -- Renew(Rank 8)
            [10929]   = {0.33, 0.73, 0.75}, -- Renew(Rank 9)
            [25315]   = {0.33, 0.73, 0.75}, -- Renew(Rank 10)
            [25221]   = {0.33, 0.73, 0.75}, -- Renew(Rank 11)
            [25222]   = {0.33, 0.73, 0.75}, -- Renew(Rank 12)
        },
        DRUID = {
            [1126]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 1)
            [5232]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 2)
            [6756]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 3)
            [5234]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 4)
            [8907]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 5)
            [9884]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 6)
            [9885]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 7)
            [26990]   = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 8)
            [21849]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 1)
            [21850]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 2)
            [26991]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 3)
            [467]     = {0.4, 0.2, 0.8}, -- Thorns(Rank 1)
            [782]     = {0.4, 0.2, 0.8}, -- Thorns(Rank 2)
            [1075]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 3)
            [8914]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 4)
            [9756]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 5)
            [9910]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 6)
            [26992]   = {0.4, 0.2, 0.8}, -- Thorns(Rank 7)
            [774]     = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 1)
            [1058]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 2)
            [1430]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 3)
            [2090]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 4)
            [2091]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 5)
            [3627]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 6)
            [8910]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 7)
            [9839]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 8)
            [9840]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 9)
            [9841]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 10)
            [25299]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 11)
            [26981]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 12)
            [26982]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 13)
            [8936]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 1)
            [8938]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 2)
            [8939]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 3)
            [8940]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 4)
            [8941]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 5)
            [9750]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 6)
            [9856]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 7)
            [9857]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 8)
            [9858]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 9)
            [26980]   = {0.33, 0.73, 0.75}, -- Regrowth(Rank 10)
            [29166]   = {0.49, 0.60, 0.55}, -- Innervate
            [33763]   = {0.33, 0.37, 0.47}, -- Lifebloom
        },
        PALADIN = {
            [1044]    = {0.89, 0.45, 0}, -- Blessing of Freedom
            [1038]    = {0.11, 1.00, 0.45}, --Blessing of Salvation
            [6940]    = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 1)
            [20729]   = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 2)
            [27147]   = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 3)
            [27148]   = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 4)
            [19740]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 1)
            [19834]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 2)
            [19835]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 3)
            [19836]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 4)
            [19837]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 5)
            [19838]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 6)
            [25291]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 7)
            [27140]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 8)
            [19742]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 1)
            [19850]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 2)
            [19852]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 3)
            [19853]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 4)
            [19854]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 5)
            [25290]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 6)
            [27142]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 7)
            [25782]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 1)
            [25916]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 2)
            [27141]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 3)
            [25894]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 1)
            [25918]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 2)
            [27143]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 3)
            [465]     = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 1)
            [10290]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 2)
            [643]     = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 3)
            [10291]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 4)
            [1032]    = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 5)
            [10292]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 6)
            [10293]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 7)
            [27149]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 8)
            [19977]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 1)
            [19978]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 2)
            [19979]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 3)
            [27144]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 4)
            [1022]    = {0.17, 1.00, 0.75}, -- Blessing of Protection(Rank 1)
            [5599]    = {0.17, 1.00, 0.75}, -- Blessing of Protection(Rank 2)
            [10278]   = {0.17, 1.00, 0.75}, -- Blessing of Protection(Rank 3)
            [19746]   = {0.83, 1.00, 0.07}, -- Concentration Aura
            [32223]   = {0.83, 1.00, 0.07}, -- Crusader Aura
        },
        SHAMAN = {
            [29203]   = {0.7, 0.3, 0.7}, -- Healing Way
            [16237]   = {0.2, 0.2, 1}, -- Ancestral Fortitude
            [8185]    = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 1)
            [10534]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 2)
            [10535]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 3)
            [25563]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 4)
            [8182]    = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 1)
            [10476]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 2)
            [10477]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 3)
            [25560]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 4)
            [10596]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 1)
            [10598]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 2)
            [10599]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 3)
            [25574]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 4)
            [5672]    = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 1)
            [6371]    = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 2)
            [6372]    = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 3)
            [10460]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 4)
            [10461]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 5)
            [25567]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 6)
            [16191]   = {0.67, 1.00, 0.80}, -- Mana Tide Totem(Rank 1)
            [17355]   = {0.67, 1.00, 0.80}, -- Mana Tide Totem(Rank 2)
            [17360]   = {0.67, 1.00, 0.80}, -- Mana Tide Totem(Rank 3)
            [5677]    = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 1)
            [10491]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 2)
            [10493]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 3)
            [10494]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 4)
            [25570]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 5)
            [8072]    = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 1)
            [8156]    = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 2)
            [8157]    = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 3)
            [10403]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 4)
            [10404]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 5)
            [10405]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 6)
            [25508]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 7)
            [25509]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 8)
            [974]     = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 1)
            [32593]   = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 2)
            [32594]   = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 3)
        },
        ROGUE = {}, --No buffs
        WARRIOR = {
            [6673]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 1)
            [5242]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 2)
            [6192]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 3)
            [11549]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 4)
            [11550]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 5)
            [11551]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 6)
            [25289]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 7)
            [2048]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 8)
            [469]     = {0.4, 0.2, 0.8}, -- Commanding Shout
        },
        HUNTER = {
            [19506]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 1)
            [20905]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 2)
            [20906]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 3)
            [27066]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 4)
            [13159]   = {0.00, 0.00, 0.85}, -- Aspect of the Pack
            [20043]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 1)
            [20190]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 2)
            [27045]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 3)
        },
        WARLOCK = {
            [5597]    = {0.89, 0.09, 0.05}, -- Unending Breath
            [6512]    = {0.2, 0.8, 0.2}, -- Detect Lesser Invisibility
            [2970]    = {0.2, 0.8, 0.2}, -- Detect Invisibility
            [11743]   = {0.2, 0.8, 0.2}, -- Detect Greater Invisibility
        },
        MAGE = {
            [1459]    = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 1)
            [1460]    = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 2)
            [1461]    = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 3)
            [10156]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 4)
            [10157]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 5)
            [27126]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 6)
            [23028]   = {0.89, 0.09, 0.05}, -- Arcane Brilliance(Rank 1)
            [27127]   = {0.89, 0.09, 0.05}, -- Arcane Brilliance(Rank 2)
            [604]     = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 1)
            [8450]    = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 2)
            [8451]    = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 3)
            [10173]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 4)
            [10174]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 5)
            [33944]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 6)
            [1008]    = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 1)
            [8455]    = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 2)
            [10169]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 3)
            [10170]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 4)
            [27130]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 5)
            [33946]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 6)
            [130]     = {0.00, 0.00, 0.50}, -- Slow Fall
        }
    }
end

-- Never show theses auras
if GW.Retail then
    GW.AURAS_IGNORED = {
        57723, -- Sated
        57724, -- Exhaustion
        80354, -- Temporal Displacement
        264689 -- Fatigued
    }
elseif GW.Mists then
    GW.AURAS_IGNORED = {
        186403,	-- Sign of Battle
        377749,	-- Joyous Journeys
        24755, 	-- Tricked or Treated
        6788,	-- Weakended Soul
        8326,	-- Ghost
        8733,	-- Blessing of Blackfathom
        15007,	-- Resurrection Sickness
        23445,	-- Evil Twin
        24755,	-- Trick or Treat
        25163,	-- Oozeling Disgusting Aura
        25771,	-- Forbearance
        26013,	-- Deserter
        36032,	-- Arcane Blast
        41425,	-- Hypothermia
        46221,	-- Animal Blood
        55711,	-- Weakened Heart
        57723,	-- Exhaustion
        57724,	-- Sated
        58539,	-- Watchers Corpse
        69438,	-- Sample Satisfaction
        71041,	-- Dungeon Deserter
        80354,	-- Timewarp
        95809,	-- Insanity
        95223	-- Group Res
    }
else
    GW.AURAS_IGNORED = {}
end


-- Show these auras only when they are missing
if GW.Retail then
    GW.AURAS_MISSING = {
        21562, -- Power Word: Fortitude
        6673,  -- Battle Shout
        1459   -- Arcane Intellect
    }
else
    GW.AURAS_MISSING = {}
end

GW.BotList = {
    [22700] = true,
    [44389] = true,
    [54711] = true,
    [67826] = true,
    [126459] = true,
    [157066] = true,
    [161414] = true,
    [199109] = true,
    [200061] = true,
    [200204] = true,
    [200205] = true,
    [200210] = true,
    [200211] = true,
    [200212] = true,
    [200214] = true,
    [200215] = true,
    [200216] = true,
    [200217] = true,
    [200218] = true,
    [200219] = true,
    [200220] = true,
    [200221] = true,
    [200222] = true,
    [200223] = true,
    [200225] = true,
    [226241] = true,
    [256230] = true,
    [298926] = true,
    [324029] = true,
    [453942] = true,
}

GW.FeastList = {
    [104958] = true,
    [126492] = true,
    [126494] = true,
    [126495] = true,
    [126496] = true,
    [126497] = true,
    [126498] = true,
    [126499] = true,
    [126500] = true,
    [126501] = true,
    [126502] = true,
    [126503] = true,
    [126504] = true,
    [145166] = true,
    [145169] = true,
    [145196] = true,
    [188036] = true,
    [201351] = true,
    [201352] = true,
    [259409] = true,
    [259410] = true,
    [276972] = true,
    [286050] = true,
    [297048] = true,
    [298861] = true,
    [307157] = true,
    [308458] = true,
    [308462] = true,
    [359336] = true,
    [382423] = true,
    [382427] = true,
    [383063] = true,
    [432877] = true,
    [433292] = true,
    [455960] = true,
    [457285] = true,
    [457302] = true,
    [462212] = true,
    [462213] = true,
}

GW.MagePortals = {
    -- Alliance
    [10059] = true,  -- Stormwind
    [11416] = true,  -- Ironforge
    [11419] = true,  -- Darnassus
    [32266] = true,  -- Exodar
    [49360] = true,  -- Theramore
    [33691] = true,  -- Shattrath
    [88345] = true,  -- Tol Barad
    [132620] = true, -- Vale of Eternal Blossoms
    [176246] = true, -- Stormshield
    [281400] = true, -- Boralus
    -- Horde
    [11417] = true,  -- Orgrimmar
    [11420] = true,  -- Thunder Bluff
    [11418] = true,  -- Undercity
    [32267] = true,  -- Silvermoon
    [49361] = true,  -- Stonard
    [35717] = true,  -- Shattrath
    [88346] = true,  -- Tol Barad
    [132626] = true, -- Vale of Eternal Blossoms
    [176244] = true, -- Warspear
    [281402] = true, -- Dazar'alor
    -- Alliance/Horde
    [53142] = true,  -- Dalaran
    [120146] = true, -- Ancient Dalaran
    [224871] = true, -- Dalaran, Broken Isles
    [344597] = true, -- Oribos
    [395289] = true, -- DF
    [446534] = true,
}

-- List of spells to display ticks
if GW.Retail then
    GW.ChannelTicks = {
        -- Racials
        [291944]	= 6, -- Regeneratin (Zandalari)
        -- Evoker
        [356995]	= 3, -- Disintegrate
        -- Warlock
        [198590]	= 4, -- Drain Soul
        [755]		= 5, -- Health Funnel
        [234153]	= 5, -- Drain Life
        -- Priest
        [64843]		= 4, -- Divine Hymn
        [15407]		= 6, -- Mind Flay
        [48045]		= 6, -- Mind Sear
        [47757]		= 3, -- Penance (heal)
        [47758]		= 3, -- Penance (dps)
        [373129]	= 3, -- Penance (Dark Reprimand, dps)
        [400171]	= 3, -- Penance (Dark Reprimand, heal)
        [64902]		= 5, -- Symbol of Hope (Mana Hymn)
        -- Mage
        [5143]		= 4, -- Arcane Missiles
        [12051]		= 6, -- Evocation
        [205021]	= 5, -- Ray of Frost
        -- Druid
        [740]		= 4, -- Tranquility
        -- DK
        [206931]	= 3, -- Blooddrinker
        -- DH
        [198013]	= 10, -- Eye Beam
        [212084]	= 10, -- Fel Devastation
        -- Hunter
        [120360]	= 15, -- Barrage
        [257044]	= 7, -- Rapid Fire
        -- Monk
        [113656]	= 4, -- Fists of Fury
    }
elseif GW.Classic then
    GW.ChannelTicks = {
        -- Druid
        [740]	= 5, -- Tranquility (Rank 1)
        [8918]	= 5, -- Tranquility (Rank 2)
        [9862]	= 5, -- Tranquility (Rank 3)
        [9863]	= 5, -- Tranquility (Rank 4)
        [16914]	= 10, -- Hurricane (Rank 1)
        [17401]	= 10, -- Hurricane (Rank 2)
        [17402]	= 10, -- Hurricane (Rank 3)
        -- Hunter
        [1510]	= 6, -- Volley (Rank 1)
        [14294]	= 6, -- Volley (Rank 2)
        [14295]	= 6, -- Volley (Rank 3)
        [136]	= 5, -- Mend Pet (Rank 1)
        [3111]	= 5, -- Mend Pet (Rank 2)
        [3661]	= 5, -- Mend Pet (Rank 3)
        [3662]	= 5, -- Mend Pet (Rank 4)
        [13542]	= 5, -- Mend Pet (Rank 5)
        [13543]	= 5, -- Mend Pet (Rank 6)
        [13544]	= 5, -- Mend Pet (Rank 7)
        -- Mage
        [10]	= 8, -- Blizzard (Rank 1)
        [6141]	= 8, -- Blizzard (Rank 2)
        [8427]	= 8, -- Blizzard (Rank 3)
        [10185]	= 8, -- Blizzard (Rank 4)
        [10186]	= 8, -- Blizzard (Rank 5)
        [10187]	= 8, -- Blizzard (Rank 6)
        [5143]	= 3, -- Arcane Missiles (Rank 1)
        [5144]	= 4, -- Arcane Missiles (Rank 2)
        [5145]	= 5, -- Arcane Missiles (Rank 3)
        [8416]	= 5, -- Arcane Missiles (Rank 4)
        [8417]	= 5, -- Arcane Missiles (Rank 5)
        [10211]	= 5, -- Arcane Missiles (Rank 6)
        [10212]	= 5, -- Arcane Missiles (Rank 7)
        [12051]	= 4, -- Evocation
        -- Priest
        [15407]	= 3, -- Mind Flay (Rank 1)
        [17311]	= 3, -- Mind Flay (Rank 2)
        [17312]	= 3, -- Mind Flay (Rank 3)
        [17313]	= 3, -- Mind Flay (Rank 4)
        [17314]	= 3, -- Mind Flay (Rank 5)
        [18807]	= 3, -- Mind Flay (Rank 6)
        -- Warlock
        [1120]	= 5, -- Drain Soul (Rank 1)
        [8288]	= 5, -- Drain Soul (Rank 2)
        [8289]	= 5, -- Drain Soul (Rank 3)
        [11675]	= 5, -- Drain Soul (Rank 4)
        [755]	= 10, -- Health Funnel (Rank 1)
        [3698]	= 10, -- Health Funnel (Rank 2)
        [3699]	= 10, -- Health Funnel (Rank 3)
        [3700]	= 10, -- Health Funnel (Rank 4)
        [11693]	= 10, -- Health Funnel (Rank 5)
        [11694]	= 10, -- Health Funnel (Rank 6)
        [11695]	= 10, -- Health Funnel (Rank 7)
        [689]	= 5, -- Drain Life (Rank 1)
        [699]	= 5, -- Drain Life (Rank 2)
        [709]	= 5, -- Drain Life (Rank 3)
        [7651]	= 5, -- Drain Life (Rank 4)
        [11699]	= 5, -- Drain Life (Rank 5)
        [11700]	= 5, -- Drain Life (Rank 6)
        [5740]	= 4, -- Rain of Fire (Rank 1)
        [6219]	= 4, -- Rain of Fire (Rank 2)
        [11677]	= 4, -- Rain of Fire (Rank 3)
        [11678]	= 4, -- Rain of Fire (Rank 4)
        [1949]	= 15, -- Hellfire (Rank 1)
        [11683]	= 15, -- Hellfire (Rank 2)
        [11684]	= 15, -- Hellfire (Rank 3)
        [5138]	= 5, -- Drain Mana (Rank 1)
        [6226]	= 5, -- Drain Mana (Rank 2)
        [11703]	= 5, -- Drain Mana (Rank 3)
        [11704]	= 5, -- Drain Mana (Rank 4)
        -- First Aid
        [23567]	= 8, -- Warsong Gulch Runecloth Bandage
        [23696]	= 8, -- Alterac Heavy Runecloth Bandage
        [24414]	= 8, -- Arathi Basin Runecloth Bandage
        [18610]	= 8, -- Heavy Runecloth Bandage
        [18608]	= 8, -- Runecloth Bandage
        [10839]	= 8, -- Heavy Mageweave Bandage
        [10838]	= 8, -- Mageweave Bandage
        [7927]	= 8, -- Heavy Silk Bandage
        [7926]	= 8, -- Silk Bandage
        [3268]	= 7, -- Heavy Wool Bandage
        [3267]	= 7, -- Wool Bandage
        [1159]	= 6, -- Heavy Linen Bandage
        [746]	= 6, -- Linen Bandage
    }
    if GW.ClassicSOD then
        GW.ChannelTicks[401417] = 3 -- Regeneration
        GW.ChannelTicks[412510] = 3 -- Mass Regeneration
        -- Priest
        GW.ChannelTicks[402261] = 3 -- Penance (DPS)
        GW.ChannelTicks[402277] = 3 -- Penance (Healing)
        GW.ChannelTicks[413259] = 5 -- Mind Sear (Rune)
    end
elseif GW.Mists then
    GW.ChannelTicks = {
        -- Warlock
        [1120]	= 5, -- Drain Soul
        [689]	= 5, -- Drain Life
        [5740]	= 4, -- Rain of Fire
        [755]	= 10, -- Health Funnel
        [79268]	= 3, -- Soul Harvest
        [1949]	= 15, -- Hellfire
        -- Druid
        [44203]	= 4, -- Tranquility
        [16914]	= 10, -- Hurricane
        -- Priest
        [15407]	= 3, -- Mind Flay
        [129197] = 3, -- Mind Flay (Insanity)
        [48045]	= 5, -- Mind Sear
        [47666]	= 3, -- Penance
        [64901]	= 4, -- Hymn of Hope
        [64843]	= 4, -- Divine Hymn
        -- Mage
        [5143]	= 5, -- Arcane Missiles
        [10]	= 8, -- Blizzard
        [12051]	= 4, -- Evocation
        -- Death Knight
        [42650]	= 8, -- Army of the Dead
        -- Monk
        [113656]	= 4, -- Fists of Fury
        -- First Aid
        [45544]	= 8, -- Heavy Frostweave Bandage
        [45543]	= 8, -- Frostweave Bandage
        [27031]	= 8, -- Heavy Netherweave Bandage
        [27030]	= 8, -- Netherweave Bandage
        [23567]	= 8, -- Warsong Gulch Runecloth Bandage
        [23696]	= 8, -- Alterac Heavy Runecloth Bandage
        [24414]	= 8, -- Arathi Basin Runecloth Bandage
        [18610]	= 8, -- Heavy Runecloth Bandage
        [18608]	= 8, -- Runecloth Bandage
        [10839]	= 8, -- Heavy Mageweave Bandage
        [10838]	= 8, -- Mageweave Bandage
        [7927]	= 8, -- Heavy Silk Bandage
        [7926]	= 8, -- Silk Bandage
        [3268]	= 7, -- Heavy Wool Bandage
        [3267]	= 7, -- Wool Bandage
        [1159]	= 6, -- Heavy Linen Bandage
        [746]	= 6 -- Linen Bandage
    }
elseif GW.TBC then
    GW.ChannelTicks = {
        -- First Aid
        [27031]	= 8, -- Heavy Netherweave Bandage
        [27030]	= 8, -- Netherweave Bandage
        [23567]	= 8, -- Warsong Gulch Runecloth Bandage
        [23696]	= 8, -- Alterac Heavy Runecloth Bandage
        [24414]	= 8, -- Arathi Basin Runecloth Bandage
        [18610]	= 8, -- Heavy Runecloth Bandage
        [18608]	= 8, -- Runecloth Bandage
        [10839]	= 8, -- Heavy Mageweave Bandage
        [10838]	= 8, -- Mageweave Bandage
        [7927]	= 8, -- Heavy Silk Bandage
        [7926]	= 8, -- Silk Bandage
        [3268]	= 7, -- Heavy Wool Bandage
        [3267]	= 7, -- Wool Bandage
        [1159]	= 6, -- Heavy Linen Bandage
        [746]	= 6, -- Linen Bandage
        -- Warlock
        [1120]	= 5, -- Drain Soul (Rank 1)
        [8288]	= 5, -- Drain Soul (Rank 2)
        [8289]	= 5, -- Drain Soul (Rank 3)
        [11675]	= 5, -- Drain Soul (Rank 4)
        [27217]	= 5, -- Drain Soul (Rank 5)
        [755]	= 10, -- Health Funnel (Rank 1)
        [3698]	= 10, -- Health Funnel (Rank 2)
        [3699]	= 10, -- Health Funnel (Rank 3)
        [3700]	= 10, -- Health Funnel (Rank 4)
        [11693]	= 10, -- Health Funnel (Rank 5)
        [11694]	= 10, -- Health Funnel (Rank 6)
        [11695]	= 10, -- Health Funnel (Rank 7)
        [27259]	= 10, -- Health Funnel (Rank 8)
        [689]	= 5, -- Drain Life (Rank 1)
        [699]	= 5, -- Drain Life (Rank 2)
        [709]	= 5, -- Drain Life (Rank 3)
        [7651]	= 5, -- Drain Life (Rank 4)
        [11699]	= 5, -- Drain Life (Rank 5)
        [11700]	= 5, -- Drain Life (Rank 6)
        [27219]	= 5, -- Drain Life (Rank 7)
        [27220]	= 5, -- Drain Life (Rank 8)
        [5740]	= 4, -- Rain of Fire (Rank 1)
        [6219]	= 4, -- Rain of Fire (Rank 2)
        [11677]	= 4, -- Rain of Fire (Rank 3)
        [11678]	= 4, -- Rain of Fire (Rank 4)
        [27212]	= 4, -- Rain of Fire (Rank 5)
        [1949]	= 15, -- Hellfire (Rank 1)
        [11683]	= 15, -- Hellfire (Rank 2)
        [11684]	= 15, -- Hellfire (Rank 3)
        [27213]	= 15, -- Hellfire (Rank 4)
        [5138]	= 5, -- Drain Mana (Rank 1)
        [6226]	= 5, -- Drain Mana (Rank 2)
        [11703]	= 5, -- Drain Mana (Rank 3)
        [11704]	= 5, -- Drain Mana (Rank 4)
        [27221]	= 5, -- Drain Mana (Rank 5)
        [30908]	= 5, -- Drain Mana (Rank 6)
        -- Priest
        [15407]	= 3, -- Mind Flay (Rank 1)
        [17311]	= 3, -- Mind Flay (Rank 2)
        [17312]	= 3, -- Mind Flay (Rank 3)
        [17313]	= 3, -- Mind Flay (Rank 4)
        [17314]	= 3, -- Mind Flay (Rank 5)
        [18807]	= 3, -- Mind Flay (Rank 6)
        [25387]	= 3, -- Mind Flay (Rank 7)
        -- Mage
        [10]	= 8, -- Blizzard (Rank 1)
        [6141]	= 8, -- Blizzard (Rank 2)
        [8427]	= 8, -- Blizzard (Rank 3)
        [10185]	= 8, -- Blizzard (Rank 4)
        [10186]	= 8, -- Blizzard (Rank 5)
        [10187]	= 8, -- Blizzard (Rank 6)
        [27085]	= 8, -- Blizzard (Rank 7)
        [5143]	= 3, -- Arcane Missiles (Rank 1)
        [5144]	= 4, -- Arcane Missiles (Rank 2)
        [5145]	= 5, -- Arcane Missiles (Rank 3)
        [8416]	= 5, -- Arcane Missiles (Rank 4)
        [8417]	= 5, -- Arcane Missiles (Rank 5)
        [10211]	= 5, -- Arcane Missiles (Rank 6)
        [10212]	= 5, -- Arcane Missiles (Rank 7)
        [25345]	= 5, -- Arcane Missiles (Rank 8)
        [27075]	= 5, -- Arcane Missiles (Rank 9)
        [38699]	= 5, -- Arcane Missiles (Rank 10)
        [12051]	= 4, -- Evocation
        --Druid
        [740]	= 5, -- Tranquility (Rank 1)
        [8918]	= 5, -- Tranquility (Rank 2)
        [9862]	= 5, -- Tranquility (Rank 3)
        [9863]	= 5, -- Tranquility (Rank 4)
        [26983]	= 5, -- Tranquility (Rank 5)
        [16914]	= 10, -- Hurricane (Rank 1)
        [17401]	= 10, -- Hurricane (Rank 2)
        [17402]	= 10, -- Hurricane (Rank 3)
        [27012]	= 10, -- Hurricane (Rank 4)
        --Hunter
        [1510]	= 6, -- Volley (Rank 1)
        [14294]	= 6, -- Volley (Rank 2)
        [14295]	= 6, -- Volley (Rank 3)
        [27022]	= 6, -- Volley (Rank 4)
    }
end

-- Spells that chain, ticks to add
GW.ChainChannelTicks = {
    -- Evoker
    [356995]	= 1, -- Disintegrate
}

-- Window to chain time (in seconds); usually the channel duration
GW.ChainChannelTime = {
    -- Evoker
    [356995]	= 3, -- Disintegrate
}

-- Spells Effected By Talents (unused; talents changed)
GW.TalentChannelTicks = {
    [356995]	= {[1219723] = 4}
}

-- Increase ticks from auras
GW.AuraChannelTicks = {
    -- Priest
    [47757]		= { filter = "HELPFUL", spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (heal)
    [47758]		= { filter = "HELPFUL", spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (dps)
}

-- Spells Effected By Haste, value is Base Tick Size
GW.HastedChannelTicks = {
}
