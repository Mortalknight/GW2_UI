local _, GW = ...

GW.PowerBarColorCustom = {
    MANA = {r = 37 / 255, g = 133 / 255, b = 240 / 255},
    RAGE = {r = 240 / 255, g = 66 / 255, b = 37 / 255},
    ENERGY = {r = 240 / 255, g = 200 / 255, b = 37 / 255},
    LUNAR_POWER = {r = 130 / 255, g = 172 / 255, b = 230 / 255},
    RUNIC_POWER = {r = 37 / 255, g = 214 / 255, b = 240 / 255},
    FOCUS = {r = 240 / 255, g = 121 / 255, b = 37 / 255},
    FURY = {r = 166 / 255, g = 37 / 255, b = 240 / 255},
    PAIN = {r = 255/255, g = 156/255, b = 0},
    MAELSTROM = {r = 0.00, g = 0.50, b = 1.00},
    INSANITY = {r = 0.40, g = 0, b = 0.80},
    CHI = {r = 0.71, g = 1.0, b = 0.92},

    -- vehicle colors
    AMMOSLOT = {r = 0.80, g = 0.60, b = 0.00},
    FUEL = {r = 0.0, g = 0.55, b = 0.5},
    STAGGER = {r = 0.52, g = 1.0, b = 0.52},
}

GW.nameRoleIcon = {
    TANK = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank:0:0:0:0:64:64:4:60:4:60|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer:0:0:0:0:64:64:4:60:4:60|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps:0:0:0:0:64:64:4:60:4:60|t ",
    NONE = ""
}

GW.professionBagColor = {
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

GW.DEBUFF_COLOR = {
    none = {r = 220 / 255, g = 0, b = 0},
    Curse = {r = 97 / 255, g = 72 / 255, b = 177 / 255},
    Disease = {r = 177 / 255, g = 114 / 255, b = 72 / 255},
    Magic = {r = 72 / 255, g = 94 / 255, b = 177 / 255},
    Poison = {r = 94 / 255, g = 177 / 255, b = 72 / 255},
}
GW.DEBUFF_COLOR[""] = GW.DEBUFF_COLOR.none

GW.TRACKER_TYPE_COLOR = {
    QUEST = {r = 221 / 255, g = 198 / 255, b = 68 / 255},
    CAMPAIGN = {r = 121 / 255, g = 222 / 255, b = 47 / 255},
    EVENT = {r = 240 / 255, g = 121 / 255, b = 37 / 255},
    SCENARIO = {r = 171 / 255, g = 37 / 255, b = 240 / 255},
    BOSS = {r = 240 / 255, g = 37 / 255, b = 37 / 255},
    ARENA = {r = 240 / 255, g = 37 / 255, b = 37 / 255},
    ACHIEVEMENT = {r = 37 / 255, g = 240 / 255, b = 172 / 255},
    DAILY = {r = 68 / 255, g = 192 / 255, b = 250 / 255},
    TORGHAST = {r = 109 / 255, g = 161 / 255, b = 207 / 255},
    RECIPE = {r = 228 / 255, g = 157 / 255, b = 0 / 255},
}

GW.FACTION_BAR_COLORS = {
    [1] = {r = 0.8, g = 0.3, b = 0.22},
    [2] = {r = 0.8, g = 0.3, b = 0.22},
    [3] = {r = 0.75, g = 0.27, b = 0},
    [4] = {r = 0.9, g = 0.7, b = 0},
    [5] = {r = 0, g = 0.6, b = 0.1},
    [6] = {r = 0, g = 0.6, b = 0.1},
    [7] = {r = 0, g = 0.6, b = 0.1},
    [8] = {r = 0, g = 0.6, b = 0.1},
    [9] = {r = 0.22, g = 0.37, b = 0.98},   --Paragon
    [10] = {r = 0.09, g = 0.29, b = 0.79},   --Azerite
    [11] = {r = 0, g = 0.74, b = 0.95},    --(Renown)
}

GW.COLOR_FRIENDLY = {
    [1] = {r = 88 / 255, g = 170 / 255, b = 68 / 255},
    [2] = {r = 159 / 255, g = 36 / 255, b = 20 / 255},
    [3] = {r = 159 / 255, g = 159 / 255, b = 159 / 255}
}
GW.BLOOD_SPARK = {
    [0] = {left = 0, right = 0.125, top = 0, bottom = 0.5},
    [1] = {left = 0, right = 0.125, top = 0, bottom = 0.5},
    [2] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5},
    [3] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5},
    [4] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5},
    [5] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5},
    [6] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5},
    [7] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5},
    [8] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5},

    [9] = {left = 0, right = 0.125, top = 0.5, bottom = 1},
    [10] = {left = 0.125, right = 0.125 * 2, top = 0.5, bottom = 1},
    [11] = {left = 0.125 * 2, right = 0.125 * 3, top = 0.5, bottom = 1},
    [12] = {left = 0.125 * 3, right = 0.125 * 4, top = 0.5, bottom = 1},
    [13] = {left = 0.125 * 4, right = 0.125 * 5, top = 0.5, bottom = 1},
    [14] = {left = 0.125 * 5, right = 0.125 * 6, top = 0.5, bottom = 1},
    [15] = {left = 0.125 * 6, right = 0.125 * 7, top = 0.5, bottom = 1},
    [16] = {left = 0.125 * 7, right = 0.125 * 8, top = 0.5, bottom = 1},

    [17] = {left = 0, right = 0.125, top = 0, bottom = 0.5},
    [18] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5},
    [19] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5},
    [20] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5},
    [21] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5},
    [22] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5},
    [23] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5},
    [24] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}
}

GW.CLASS_ICONS = {
    [0] = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1},

    [1] = {l = 0.0625 * 11, r = 0.0625 * 12, t = 0, b = 1},
    [2] = {l = 0.0625 * 10, r = 0.0625 * 11, t = 0, b = 1},
    [3] = {l = 0.0625 * 9, r = 0.0625 * 10, t = 0, b = 1},
    [4] = {l = 0.0625 * 8, r = 0.0625 * 9, t = 0, b = 1},
    [5] = {l = 0.0625 * 7, r = 0.0625 * 8, t = 0, b = 1},
    [6] = {l = 0.0625 * 6, r = 0.0625 * 7, t = 0, b = 1},
    [7] = {l = 0.0625 * 5, r = 0.0625 * 6, t = 0, b = 1},
    [8] = {l = 0.0625 * 4, r = 0.0625 * 5, t = 0, b = 1},
    [9] = {l = 0.0625 * 3, r = 0.0625 * 4, t = 0, b = 1},
    [10] = {l = 0.0625 * 2, r = 0.0625 * 3, t = 0, b = 1},
    [11] = {l = 0.0625 * 1, r = 0.0625 * 2, t = 0, b = 1},
    [12] = {l = 0, r = 0.0625 * 1, t = 0, b = 1},
    [13] = {l = 0.0625 * 13, r = 0.0625 * 14, t = 0, b = 1},
    dead = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1}
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
    WARRIOR = {r = 90 / 255, g = 54 / 255, b = 38 / 255, a = 1},
    PALADIN = {r = 177 / 255, g = 72 / 255, b = 117 / 255, a = 1},
    HUNTER = {r = 99 / 255, g = 125 / 255, b = 53 / 255, a = 1},
    ROGUE = {r = 190 / 255, g = 183 / 255, b = 79 / 255, a = 1},
    PRIEST = {r = 205 / 255, g = 205 / 255, b = 205 / 255, a = 1},
    DEATHKNIGHT = {r = 148 / 255, g = 62 / 255, b = 62 / 255, a = 1},
    SHAMAN = {r = 30 / 255, g = 44 / 255, b = 149 / 255, a = 1},
    --MAGE = {r = 62 / 255, g = 121 / 255, b = 149 / 255, a = 1},
    MAGE = {r = 101 / 255, g = 157 / 255, b = 184 / 255, a = 1},
    WARLOCK = {r = 125 / 255, g = 88 / 255, b = 154 / 255, a = 1},
    MONK = {r = 66 / 255, g = 151 / 255, b = 112 / 255, a = 1},
    DRUID = {r = 158 / 255, g = 103 / 255, b = 37 / 255, a = 1},
    DEMONHUNTER = {r = 72 / 255, g = 38 / 255, b = 148 / 255, a = 1},
    --EVOKER = {r = 51 / 255, g = 147 / 255, b = 127 / 255, a = 1},
    EVOKER = {r = 56 / 255, g = 99 / 255, b = 113 / 255, a = 1}
}

GW.FACTION_COLOR = {
    [1] = {r = 163 / 255, g = 46 / 255, b = 54 / 255}, --Horde
    [2] = {r = 57 / 255, g = 115 / 255, b = 186 / 255} --Alliance
}

GW.TARGET_FRAME_ART = {
    minus = "Interface/AddOns/GW2_UI/textures/units/targetshadow",
    normal = "Interface/AddOns/GW2_UI/textures/units/targetshadow",
    elite = "Interface/AddOns/GW2_UI/textures/units/targetShadowElit",
    rare = "Interface/AddOns/GW2_UI/textures/units/targetShadowRare",
    rareelite = "Interface/AddOns/GW2_UI/textures/units/targetShadowRare",
    worldboss = "Interface/AddOns/GW2_UI/textures/units/targetshadow_boss",
    boss = "Interface/AddOns/GW2_UI/textures/units/targetshadow_boss",
    prestige1 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p1",
    prestige2 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p2",
    prestige3 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p3",
    prestige4 = "Interface/AddOns/GW2_UI/textures/units/targetshadow_p4",
    realboss = "Interface/AddOns/GW2_UI/textures/units/targetshadow-raidboss"
}

GW.REALM_FLAGS = {
    enUS = "|TInterface/AddOns/GW2_UI/textures/flags/us:10:12:0:0|t",
    ptBR = "|TInterface/AddOns/GW2_UI/textures/flags/br:10:12:0:0|t",
    ptPT = "|TInterface/AddOns/GW2_UI/textures/flags/pt:10:12:0:0|t",
    esMX = "|TInterface/AddOns/GW2_UI/textures/flags/mx:10:12:0:0|t",
    deDE = "|TInterface/AddOns/GW2_UI/textures/flags/de:10:12:0:0|t",
    enGB = "|TInterface/AddOns/GW2_UI/textures/flags/gb:10:12:0:0|t",
    koKR = "|TInterface/AddOns/GW2_UI/textures/flags/kr:10:12:0:0|t",
    frFR = "|TInterface/AddOns/GW2_UI/textures/flags/fr:10:12:0:0|t",
    esES = "|TInterface/AddOns/GW2_UI/textures/flags/es:10:12:0:0|t",
    itIT = "|TInterface/AddOns/GW2_UI/textures/flags/it:10:12:0:0|t",
    ruRU = "|TInterface/AddOns/GW2_UI/textures/flags/ru:10:12:0:0|t",
    zhTW = "|TInterface/AddOns/GW2_UI/textures/flags/tw:10:12:0:0|t",
    zhCN = "|TInterface/AddOns/GW2_UI/textures/flags/cn:10:12:0:0|t"
}

GW.INDICATORS = {"BAR", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT"}
GW.indicatorsText = {"Bar", "Top Left", "Top", "Top Right", "Left", "Center", "Right"}

GW.bossFrameExtraEnergyBar = {
    [2469] = { -- Andui Wrynn
        enable = true,
        npcIds = {
            [181954] = true,
        },
    },
    [2467] = { -- Rygelon
        enable = true,
        npcIds = {
            [182777] = true,
        },
    },
    [2470] = { -- Artificer Xy’mox
        enable = true,
        npcIds = {
            [184140] = true,
        },
    },
    [2459] = { -- Dausegne, the Fallen Oracle
        enable = true,
        npcIds = {
            [181224] = true,
        },
    },
    [2461] = { -- Lihuvim, Principal Architect
        enable = true,
        npcIds = {
            [182169] = true,
        },
    },
    [2457] = { -- Lords of Dread
        enable = true,
        npcIds = {
            [181398] = true,
        },
    },
--    [465] = { -- Lord Overheat for testing
--        enable = true,
--        npcIds = {
--            [46264] = true,
--        },
--    }
}

-- Taken from ElvUI: https://git.tukui.org/elvui/elvui/blob/master/ElvUI/Settings/Filters/UnitFrame.lua
-- Format: {class = {id = {r, g, b[, <spell-id-same-slot>]} ...}, ...}
GW.AURAS_INDICATORS = {
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
        [10060]   =  {1, 0.81, 0.11},  -- Power Infusion
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
        [203554] =  {1, 1, 0.4},        -- Focused Growth (PvP)
        [391891] =  {0.01, 0.75, 0.6},  -- Adaptive Swarm
        [157982] =  {0.75, 0.75, 0.75}, -- Tranquility
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
        [157047] =  {0.15, 0.58, 0.84}, -- Saved by the Light (T25 Talent)
        [204018] =  {0.2, 0.2, 1},      -- Blessing of Spellwarding
        [148039] =  {0.98, 0.5, 0.11},  -- Barrier of Faith (accumulation)
        [395180] =  {0.93, 0.8, 0.36},  -- Barrier of Faith (absorbtion)
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
        [116841] =  {0.12, 1.00, 0.53}, -- Tiger's Lust (Freedom)
        [325209] =  {0.3, 0.8, 0.6},    -- Enveloping Breath
    },
    ROGUE = {
        [57934] =   {0.89, 0.09, 0.05}  -- Tricks of the Trade
    },
    WARRIOR = {
        [114030] =  {0.2, 0.2, 1},      -- Vigilance
        [3411] =    {0.89, 0.09, 0.05}  -- Intervene
    },
    HUNTER = {
        [90361]  = {0.34, 0.47, 0.31},  -- Spirit Mend (HoT)
    },
    DEMONHUNTER = {},
    WARLOCK = {},
    MAGE = {},
    DEATHKNIGHT = {},
    EVOKER = {
        [355941] =  {0.33, 0.33, 0.77},     -- Dream Breath
        [363502] =  {0.33, 0.33, 0.7},      -- Dream Flight
        [366155] =  {0.14, 1.00, 0.88},     -- Reversion
        [364343] =  {0.13, 0.87, 0.50},     -- Echo
        [357170] =  {0.11, 0.57, 0.7},      -- Time Dilation
        [376788] =  {0.25, 0.25, 0.58},     -- Dreaon Breath (echo)
        [367364] =  {0.09, 0.69, 0.61},     -- Reversion (echo)
        [373267] =  {0.82, 0.29, 0.24},     -- Life Bind (Verdant Embrace)
    },
    PET = {
        [193396] =  {0.6, 0.2, 0.8},    -- Demonic Empowerment
        [19615] =   {0.89, 0.09, 0.05}, -- Frenzy
        [136] =     {0.2, 0.8, 0.2}     -- Mend Pet
    }
}

-- Never show theses auras
GW.AURAS_IGNORED = {
    57723, -- Sated
    57724, -- Exhaustion
    80354, -- Temporal Displacement
    264689 -- Fatigued
}

-- Show these auras only when they are missing
GW.AURAS_MISSING = {
    21562,  -- Power Word: Fortitude
    6673,   -- Battle Shout
    1459    -- Arcane Intellect
}

GW.MagePortals = {
    -- Alliance
    [10059] = true,		-- Stormwind
    [11416] = true,		-- Ironforge
    [11419] = true,		-- Darnassus
    [32266] = true,		-- Exodar
    [49360] = true,		-- Theramore
    [33691] = true,		-- Shattrath
    [88345] = true,		-- Tol Barad
    [132620] = true,	-- Vale of Eternal Blossoms
    [176246] = true,	-- Stormshield
    [281400] = true,	-- Boralus
    -- Horde
    [11417] = true,		-- Orgrimmar
    [11420] = true,		-- Thunder Bluff
    [11418] = true,		-- Undercity
    [32267] = true,		-- Silvermoon
    [49361] = true,		-- Stonard
    [35717] = true,		-- Shattrath
    [88346] = true,		-- Tol Barad
    [132626] = true,	-- Vale of Eternal Blossoms
    [176244] = true,	-- Warspear
    [281402] = true,	-- Dazar'alor
    -- Alliance/Horde
    [53142] = true,		-- Dalaran
    [120146] = true,	-- Ancient Dalaran
    [224871] = true,	-- Dalaran, Broken Isles
    [344597] = true,	-- Oribos
    [395289] = true,	-- DF
}
