local _, GW = ...

GW.DispelClasses = {
    DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
    MAGE = { Curse = true },
    PALADIN = { Magic = true, Poison = true, Disease = true },
    PRIEST = { Magic = true, Disease = true },
    SHAMAN = { Magic = false, Poison = true, Disease = true, Curse = IsSpellKnown(51886) },
    WARLOCK = { Magic = true }
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

GW.nameRoleIcon = {
    TANK = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank:0:0:0:0:64:64:4:60:4:60|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer:0:0:0:0:64:64:4:60:4:60|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps:0:0:0:0:64:64:4:60:4:60|t ",
    NONE = ""
}

local DEBUFF_COLOR = {}
GW.DEBUFF_COLOR = DEBUFF_COLOR
DEBUFF_COLOR["none"] = {r = 220 / 255, g = 0, b = 0}
DEBUFF_COLOR["Curse"] = {r = 97 / 255, g = 72 / 255, b = 177 / 255}
DEBUFF_COLOR["Disease"] = {r = 177 / 255, g = 114 / 255, b = 72 / 255}
DEBUFF_COLOR["Magic"] = {r = 72 / 255, g = 94 / 255, b = 177 / 255}
DEBUFF_COLOR["Poison"] = {r = 94 / 255, g = 177 / 255, b = 72 / 255}
DEBUFF_COLOR[""] = DEBUFF_COLOR["none"]

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
}

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
    [0x0001] = {r = 1, g = 1, b = 1},            --Quivers       1
    [0x0002] = {r = 1, g = 1, b = 1},            --Quivers       2
    [0x0004] = {r = 0.251, g = 0.878, b = 0.816},--Soul          3
    [0x0020] = {r = 0.451, g = 1, b = 0},        --Herbs         6
    [0x0040] = {r = 1, g = 0, b = 1}             --Enchanting    7

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

GW.GW_CLASS_COLORS = {
    WARRIOR = {r = 90 / 255, g = 54 / 255, b = 38 / 255, a = 1},
    PALADIN = {r = 177 / 255, g = 72 / 255, b = 117 / 255, a = 1},
    HUNTER = {r = 99 / 255, g = 125 / 255, b = 53 / 255, a = 1},
    ROGUE = {r = 190 / 255, g = 183 / 255, b = 79 / 255, a = 1},
    PRIEST = {r = 205 / 255, g = 205 / 255, b = 205 / 255, a = 1},
    DEATHKNIGHT = {r = 148 / 255, g = 62 / 255, b = 62 / 255, a = 1},
    SHAMAN = {r = 30 / 255, g = 44 / 255, b = 149 / 255, a = 1},
    MAGE = {r = 62 / 255, g = 121 / 255, b = 149 / 255, a = 1},
    WARLOCK = {r = 125 / 255, g = 88 / 255, b = 154 / 255, a = 1},
    MONK = {r = 66 / 255, g = 151 / 255, b = 112 / 255, a = 1},
    DRUID = {r = 158 / 255, g = 103 / 255, b = 37 / 255, a = 1},
    DEMONHUNTER = {r = 72 / 255, g = 38 / 255, b = 148 / 255, a = 1}
}

GW.FACTION_COLOR = {
    [1] = {r = 163 / 255, g = 46 / 255, b = 54 / 255}, --Horde
    [2] = {r = 57 / 255, g = 115 / 255, b = 186 / 255} --Alliance
}

local TARGET_FRAME_ART = {
    ["minus"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetshadow",
    ["normal"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetshadow",
    ["elite"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetShadowElit",
    ["rare"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetShadowRare",
    ["rareelite"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetShadowRare",
    ["worldboss"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetshadow",
    ["boss"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetshadow_boss",
    ["realboss"] = "Interface\\AddOns\\GW2_UI\\textures\\units\\targetshadow-raidboss"
}
GW.TARGET_FRAME_ART = TARGET_FRAME_ART

local INDICATORS = {"BAR", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT"}
local indicatorsText = {"Bar", "Top Left", "Top", "Top Right", "Left", "Center", "Right"}
GW.INDICATORS = INDICATORS
GW.indicatorsText = indicatorsText

GW.bossFrameExtraEnergyBar = {}

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

-- Taken from ElvUI: https://git.tukui.org/elvui/elvui/blob/master/ElvUI/Settings/Filters/UnitFrame.lua
-- Format: {class = {id = {r, g, b[, {<spell-id-same-slot>, ...}]} ...}, ...}
local AURAS_INDICATORS = {
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

GW.WINDOW_FADE_DURATION = 0.2
