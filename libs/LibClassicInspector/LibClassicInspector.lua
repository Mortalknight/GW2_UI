--[[

    LibClassicInspector by kebabstorm
    for Classic/TBC/WOTLK

    Requires: LibStub, CallbackHandler-1.0, LibDetours-1.0
    Version: 14 (2023-02-26)

--]]

local LCI_VERSION = 14

local clientVersionString = GetBuildInfo()
local clientBuildMajor = string.byte(clientVersionString, 1)
-- load only on classic/tbc/wotlk
if (clientBuildMajor < 49 or clientBuildMajor > 51 or string.byte(clientVersionString, 2) ~= 46) then
    return
end

assert(LibStub, "LibClassicInspector requires LibStub")
assert(LibStub:GetLibrary("CallbackHandler-1.0", true), "LibClassicInspector requires CallbackHandler-1.0")
assert(LibStub:GetLibrary("LibDetours-1.0", true), "LibClassicInspector requires LibDetours-1.0")

local lib, oldminor = LibStub:NewLibrary("LibClassicInspector", LCI_VERSION)

-- already loaded
if (not lib) then
    return
end
oldminor = oldminor or 0

local Detours = LibStub("LibDetours-1.0")

--------------------------------------------------------------------------
--
--  INTERNAL FUNCTIONS
--
--------------------------------------------------------------------------

INSPECTOR_MAX_CACHE = 150
INSPECTOR_INSPECT_DELAY = 2
INSPECTOR_MAX_QUEUE = 20
INSPECTOR_REFRESH_DELAY = 10
INSPECTOR_QUEUE_INTERVAL = 1
INSPECTOR_INFO_MIN_INTERVAL = 5
INSPECTOR_INFO_MAX_INTERVAL = 60

local MAX_TALENTS_PER_TAB = 31
local skip_error = false
local nextInspectTime = 0
local user_cache_this = {["guid"] = "0"}
local infoChanged = false
local infoTicks = 0
local C_PREFIX = "LCIV1"

local GUIDIsPlayer = C_PlayerInfo.GUIDIsPlayer
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local NewTicker = C_Timer.NewTicker

local isWotlk = clientBuildMajor == 51
local isTBC = clientBuildMajor == 50
local isClassic = clientBuildMajor == 49

local playerClass = select(2, UnitClass("player"))

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.frame = lib.frame or CreateFrame("Frame")
lib.cache = lib.cache or {["len"] = 0}
lib.queue = lib.queue or {}
lib.guildies = lib.guildies or {}

lib.spec_table = lib.spec_table or {
    ["WARRIOR"] = {"Arms", "Fury", "Protection"},
    ["PALADIN"] = {"Holy", "Protection", "Retribution"},
    ["HUNTER"] = {"Beast Mastery", "Marksmanship", "Survival"},
    ["ROGUE"] = {"Assassination", "Combat", "Subtlety"},
    ["PRIEST"] = {"Discipline", "Holy", "Shadow"},
    ["DEATHKNIGHT"] = {"Blood", "Frost", "Unholy"},
    ["SHAMAN"] = {"Elemental", "Enhancement", "Restoration"},
    ["MAGE"] = {"Arcane", "Fire", "Frost"},
    ["WARLOCK"] = {"Affliction", "Demonology", "Destruction"},
    ["DRUID"] = {"Balance", "Feral Combat", "Restoration"}
}

-- TODO: localization
if (GetLocale() == "deDE") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Waffen", "Furor", "Schutz"},
    ["PALADIN"] = {"Heilig", "Schutz", "Vergeltung"},
    ["HUNTER"] = {"Tierherrschaft", "Treffsicherheit", "\195\156berleben"},
    ["ROGUE"] = {"Meucheln", "Kampf", "T\195\164uschung"},
    ["PRIEST"] = {"Disziplin", "Heilig", "Schatten"},
    ["DEATHKNIGHT"] = {"Blut", "Frost", "Unheilig"},
    ["SHAMAN"] = {"Elementar", "Verst\195\164rkung", "Wiederherstellung"},
    ["MAGE"] = {"Arkan", "Feuer", "Frost"},
    ["WARLOCK"] = {"Gebrechen", "D\195\164monologie", "Zerst\195\182rung"},
    ["DRUID"] = {"Gleichgewicht", "Wildheit", "Wiederherstellung"}
}
elseif (GetLocale() == "esES") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Armas", "Furia", "Protecci\195\179n"},
    ["PALADIN"] = {"Sagrado", "Protecci\195\179n", "Reprensi\195\179n"},
    ["HUNTER"] = {"Bestias", "Punter\195\173a", "Supervivencia"},
    ["ROGUE"] = {"Asesinato", "Combate", "Sutileza"},
    ["PRIEST"] = {"Disciplina", "Sagrado", "Sombra"},
    ["DEATHKNIGHT"] = {"Sangre", "Escarcha", "Profano"},
    ["SHAMAN"] = {"Elemental", "Mejora", "Restauraci\195\179n"},
    ["MAGE"] = {"Arcano", "Fuego", "Escarcha"},
    ["WARLOCK"] = {"Aflicci\195\179n", "Demonolog\195\173a", "Destrucci\195\179n"},
    ["DRUID"] = {"Equilibrio", "Combate feral", "Restauraci\195\179n"}
}
elseif (GetLocale() == "esMX") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Arms", "Fury", "Protection"},
    ["PALADIN"] = {"Holy", "Protection", "Retribution"},
    ["HUNTER"] = {"Beast Mastery", "Marksmanship", "Survival"},
    ["ROGUE"] = {"Assassination", "Combat", "Subtlety"},
    ["PRIEST"] = {"Discipline", "Holy", "Shadow"},
    ["DEATHKNIGHT"] = {"Blood", "Frost", "Unholy"},
    ["SHAMAN"] = {"Elemental", "Enhancement", "Restoration"},
    ["MAGE"] = {"Arcane", "Fire", "Frost"},
    ["WARLOCK"] = {"Affliction", "Demonology", "Destruction"},
    ["DRUID"] = {"Balance", "Feral Combat", "Restoration"}
}
elseif (GetLocale() == "frFR") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Arms", "Fury", "Protection"},
    ["PALADIN"] = {"Holy", "Protection", "Retribution"},
    ["HUNTER"] = {"Beast Mastery", "Marksmanship", "Survival"},
    ["ROGUE"] = {"Assassination", "Combat", "Subtlety"},
    ["PRIEST"] = {"Discipline", "Holy", "Shadow"},
    ["DEATHKNIGHT"] = {"Blood", "Frost", "Unholy"},
    ["SHAMAN"] = {"Elemental", "Enhancement", "Restoration"},
    ["MAGE"] = {"Arcane", "Fire", "Frost"},
    ["WARLOCK"] = {"Affliction", "Demonology", "Destruction"},
    ["DRUID"] = {"Balance", "Feral Combat", "Restoration"}
}
elseif (GetLocale() == "itIT") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Arms", "Fury", "Protection"},
    ["PALADIN"] = {"Holy", "Protection", "Retribution"},
    ["HUNTER"] = {"Beast Mastery", "Marksmanship", "Survival"},
    ["ROGUE"] = {"Assassination", "Combat", "Subtlety"},
    ["PRIEST"] = {"Discipline", "Holy", "Shadow"},
    ["DEATHKNIGHT"] = {"Blood", "Frost", "Unholy"},
    ["SHAMAN"] = {"Elemental", "Enhancement", "Restoration"},
    ["MAGE"] = {"Arcane", "Fire", "Frost"},
    ["WARLOCK"] = {"Affliction", "Demonology", "Destruction"},
    ["DRUID"] = {"Balance", "Feral Combat", "Restoration"}
}
elseif (GetLocale() == "koKR") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"\235\172\180\234\184\176", "\235\182\132\235\133\184", "\235\176\169\236\150\180"},
    ["PALADIN"] = {"\236\139\160\236\132\177", "\235\179\180\237\152\184", "\236\167\149\235\178\140"},
    ["HUNTER"] = {"\236\149\188\236\136\152", "\236\130\172\234\178\169", "\236\131\157\236\161\180"},
    ["ROGUE"] = {"\236\149\148\236\130\180", "\236\160\132\237\136\172", "\236\158\160\237\150\137"},
    ["PRIEST"] = {"\236\136\152\236\150\145", "\236\139\160\236\132\177", "\236\149\148\237\157\145"},
    ["DEATHKNIGHT"] = {"\237\152\136\234\184\176", "\235\131\137\234\184\176", "\235\182\128\236\160\149"},
    ["SHAMAN"] = {"\236\160\149\234\184\176", "\234\179\160\236\150\145", "\237\154\140\235\179\181"},
    ["MAGE"] = {"\235\185\132\236\160\132", "\237\153\148\236\151\188", "\235\131\137\234\184\176"},
    ["WARLOCK"] = {"\234\179\160\237\134\181", "\236\149\133\235\167\136", "\237\140\140\234\180\180"},
    ["DRUID"] = {"\236\161\176\237\153\148", "\236\149\188\236\132\177", "\237\154\140\235\179\181"}
}
elseif (GetLocale() == "ruRU") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"\208\158\209\128\209\131\208\182\208\184\208\181", "\208\157\208\181\208\184\209\129\209\130\208\190\208\178\209\129\209\130\208\178\208\190", "\208\151\208\176\209\137\208\184\209\130\208\176"},
    ["PALADIN"] = {"\208\161\208\178\208\181\209\130", "\208\151\208\176\209\137\208\184\209\130\208\176", "\208\146\208\190\208\183\208\180\208\176\209\143\208\189\208\184\208\181"},
    ["HUNTER"] = {"\208\159\208\190\208\178\208\181\208\187\208\184\209\130\208\181\208\187\209\140 \208\183\208\178\208\181\209\128\208\181\208\185", "\208\161\209\130\209\128\208\181\208\187\209\140\208\177\208\176", "\208\146\209\139\208\182\208\184\208\178\208\176\208\189\208\184\208\181"},
    ["ROGUE"] = {"\208\155\208\184\208\186\208\178\208\184\208\180\208\176\209\134\208\184\209\143", "\208\145\208\190\208\185", "\208\161\208\186\209\128\209\139\209\130\208\189\208\190\209\129\209\130\209\140"},
    ["PRIEST"] = {"\208\159\208\190\209\129\208\187\209\131\209\136\208\176\208\189\208\184\208\181", "\208\161\208\178\208\181\209\130", "\208\162\209\140\208\188\208\176"},
    ["DEATHKNIGHT"] = {"\208\154\209\128\208\190\208\178\209\140", "\208\155\208\181\208\180", "\208\157\208\181\209\135\208\181\209\129\209\130\208\184\208\178\208\190\209\129\209\130\209\140"},
    ["SHAMAN"] = {"\208\161\209\130\208\184\209\133\208\184\208\184", "\208\161\208\190\208\178\208\181\209\128\209\136\208\181\208\189\209\129\209\130\208\178\208\190\208\178\208\176\208\189\208\184\208\181", "\208\146\208\190\209\129\209\129\209\130\208\176\208\189\208\190\208\178\208\187\208\181\208\189\208\184\208\181"},
    ["MAGE"] = {"\208\162\208\176\208\185\208\189\208\176\209\143 \208\188\208\176\208\179\208\184\209\143", "\208\158\208\179\208\190\208\189\209\140", "\208\155\208\181\208\180"},
    ["WARLOCK"] = {"\208\154\208\190\208\187\208\180\208\190\208\178\209\129\209\130\208\178\208\190", "\208\148\208\181\208\188\208\190\208\189\208\190\208\187\208\190\208\179\208\184\209\143", "\208\160\208\176\208\183\209\128\209\131\209\136\208\181\208\189\208\184\208\181"},
    ["DRUID"] = {"\208\145\208\176\208\187\208\176\208\189\209\129", "\208\161\208\184\208\187\208\176 \208\183\208\178\208\181\209\128\209\143", "\208\146\208\190\209\129\209\129\209\130\208\176\208\189\208\190\208\178\208\187\208\181\208\189\208\184\208\181"}
}
elseif (GetLocale() == "ptBR") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Arms", "Fury", "Protection"},
    ["PALADIN"] = {"Holy", "Protection", "Retribution"},
    ["HUNTER"] = {"Beast Mastery", "Marksmanship", "Survival"},
    ["ROGUE"] = {"Assassination", "Combat", "Subtlety"},
    ["PRIEST"] = {"Discipline", "Holy", "Shadow"},
    ["DEATHKNIGHT"] = {"Blood", "Frost", "Unholy"},
    ["SHAMAN"] = {"Elemental", "Enhancement", "Restoration"},
    ["MAGE"] = {"Arcane", "Fire", "Frost"},
    ["WARLOCK"] = {"Affliction", "Demonology", "Destruction"},
    ["DRUID"] = {"Balance", "Feral Combat", "Restoration"}
}
elseif (GetLocale() == "zhCN") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"\230\173\166\229\153\168", "\231\139\130\230\128\146", "\233\152\178\230\138\164"},
    ["PALADIN"] = {"\231\165\158\229\156\163", "\233\152\178\230\138\164", "\230\131\169\230\136\146"},
    ["HUNTER"] = {"\233\135\142\229\133\189\230\142\167\229\136\182", "\229\176\132\229\135\187", "\231\148\159\229\173\152"},
    ["ROGUE"] = {"\229\165\135\232\162\173", "\230\136\152\230\150\151", "\230\149\143\233\148\144"},
    ["PRIEST"] = {"\230\136\146\229\190\139", "\231\165\158\229\156\163", "\230\154\151\229\189\177"},
    ["DEATHKNIGHT"] = {"\233\178\156\232\161\128", "\229\134\176\233\156\156", "\233\130\170\230\129\182"},
    ["SHAMAN"] = {"\229\133\131\231\180\160", "\229\162\158\229\188\186", "\230\129\162\229\164\141"},
    ["MAGE"] = {"\229\165\165\230\156\175", "\231\129\171\231\132\176", "\229\134\176\233\156\156"},
    ["WARLOCK"] = {"\231\151\155\232\139\166", "\230\129\182\233\173\148\229\173\166\232\175\134", "\230\175\129\231\129\173"},
    ["DRUID"] = {"\229\185\179\232\161\161", "\233\135\142\230\128\167\230\136\152\230\150\151", "\230\129\162\229\164\141"}
}
elseif (GetLocale() == "zhTW") then
lib.spec_table_localized = lib.spec_table_localized or {
    ["WARRIOR"] = {"Arms", "Fury", "Protection"},
    ["PALADIN"] = {"Holy", "Protection", "Retribution"},
    ["HUNTER"] = {"Beast Mastery", "Marksmanship", "Survival"},
    ["ROGUE"] = {"Assassination", "Combat", "Subtlety"},
    ["PRIEST"] = {"Discipline", "Holy", "Shadow"},
    ["DEATHKNIGHT"] = {"Blood", "Frost", "Unholy"},
    ["SHAMAN"] = {"Elemental", "Enhancement", "Restoration"},
    ["MAGE"] = {"Arcane", "Fire", "Frost"},
    ["WARLOCK"] = {"Affliction", "Demonology", "Destruction"},
    ["DRUID"] = {"Balance", "Feral Combat", "Restoration"}
}
else -- enUS / enGB
lib.spec_table_localized = lib.spec_table
end

-- TODO: talent IDs
-- TODO: localization
if (isWotlk) then
if (oldminor < 13) then
  lib.glyphs_table = nil
  lib.glyph_r_tbl = nil
end
lib.tracked_achievements = lib.tracked_achievements or {}
lib.glyphs_table = lib.glyphs_table or {
  ["WARRIOR"] = {
    [1] = {
      [1] = 58353,  -- Glyph of Taunt
      [2] = 58355,  -- Glyph of Rapid Charge
      [3] = 58356,  -- Glyph of Resonating Power
      [4] = 58357,  -- Glyph of Heroic Strike
      [5] = 58364,  -- Glyph of Revenge
      [6] = 58365,  -- Glyph of Barbaric Insults
      [7] = 58366,  -- Glyph of Cleaving
      [8] = 58367,  -- Glyph of Execution
      [9] = 58368,  -- Glyph of Mortal Strike
      [10] = 58369, -- Glyph of Bloodthirst
      [11] = 58370, -- Glyph of Whirlwind
      [12] = 58372, -- Glyph of Hamstring
      [13] = 58375, -- Glyph of Blocking
      [14] = 58376, -- Glyph of Last Stand
      [15] = 58377, -- Glyph of Intervene
      [16] = 58382, -- Glyph of Victory Rush
      [17] = 58384, -- Glyph of Sweeping Strikes
      [18] = 58385, -- Glyph of Rending
      [19] = 58386, -- Glyph of Overpower
      [20] = 58387, -- Glyph of Sunder Armor
      [21] = 58388, -- Glyph of Devastate
      [22] = 63324, -- Glyph of Bladestorm
      [23] = 63325, -- Glyph of Shockwave
      [24] = 63326, -- Glyph of Vigilance
      [25] = 63327, -- Glyph of Enraged Regeneration
      [26] = 63328, -- Glyph of Spell Reflection
      [27] = 63329  -- Glyph of Shield Wall
    },
    [2] = {
      [1] = 58095,  -- Glyph of Battle
      [2] = 58096,  -- Glyph of Bloodrage
      [3] = 58097,  -- Glyph of Charge
      [4] = 58098,  -- Glyph of Thunder Clap
      [5] = 58099,  -- Glyph of Mocking Blow
      [6] = 58104,  -- Glyph of Enduring Victory
      [7] = 68164   -- Glyph of Command
    },
  },
  ["PALADIN"] = {
    [1] = {
      [1] = 54922,  -- Glyph of Judgement
      [2] = 54923,  -- Glyph of Hammer of Justice
      [3] = 54924,  -- Glyph of Spiritual Attunement
      [4] = 54925,  -- Glyph of Seal of Command
      [5] = 54926,  -- Glyph of Hammer of Wrath
      [6] = 54927,  -- Glyph of Crusader Strike
      [7] = 54928,  -- Glyph of Consecration
      [8] = 54929,  -- Glyph of Righteous Defense
      [9] = 54930,  -- Glyph of Avenger's Shield
      [10] = 54931, -- Glyph of Turn Evil
      [11] = 54934, -- Glyph of Exorcism
      [12] = 54935, -- Glyph of Cleansing
      [13] = 54936, -- Glyph of Flash of Light
      [14] = 54937, -- Glyph of Holy Light
      [15] = 54938, -- Glyph of Avenging Wrath
      [16] = 54939, -- Glyph of Divinity
      [17] = 54940, -- Glyph of Seal of Wisdom
      [18] = 54943, -- Glyph of Seal of Light
      [19] = 56414, -- Glyph of Seal of Righteousness
      [20] = 56416, -- Glyph of Seal of Vengeance
      [21] = 56420, -- Glyph of Holy Wrath
      [22] = 63218, -- Glyph of Beacon of Light
      [23] = 63219, -- Glyph of Hammer of the Righteous
      [24] = 63220, -- Glyph of Divine Storm
      [25] = 63222, -- Glyph of Shield of Righteousness
      [26] = 63223, -- Glyph of Divine Plea
      [27] = 63224, -- Glyph of Holy Shock
      [28] = 63225, -- Glyph of Salvation
      [29] = 405004 -- Glyph of Reckoning
    },
    [2] = {
      [1] = 57937,  -- Glyph of Blessing of Kings
      [2] = 57947,  -- Glyph of Sense Undead
      [3] = 57954,  -- Glyph of the Wise
      [4] = 57955,  -- Glyph of Lay on Hands
      [5] = 57958,  -- Glyph of Blessing of Might
      [6] = 57979   -- Glyph of Blessing of Wisdom
    },
  },
  ["HUNTER"] = {
    [1] = {
      [1] = 56824,  -- Glyph of Aimed Shot
      [2] = 56826,  -- Glyph of Steady Shot
      [3] = 56828,  -- Glyph of Rapid Fire
      [4] = 56829,  -- Glyph of Hunter's Mark
      [5] = 56830,  -- Glyph of Bestial Wrath
      [6] = 56832,  -- Glyph of Serpent Sting
      [7] = 56833,  -- Glyph of Mending
      [8] = 56836,  -- Glyph of Multi-Shot
      [9] = 56838,  -- Glyph of Volley
      [10] = 56841, -- Glyph of Arcane Shot
      [11] = 56842, -- Glyph of Trueshot Aura
      [12] = 56844, -- Glyph of Disengage
      [13] = 56845, -- Glyph of Freezing Trap
      [14] = 56846, -- Glyph of Immolation Trap
      [15] = 56847, -- Glyph of Frost Trap
      [16] = 56848, -- Glyph of Wyvern Sting
      [17] = 56849, -- Glyph of Snake Trap
      [18] = 56850, -- Glyph of Deterrence
      [19] = 56851, -- Glyph of Aspect of the Viper
      [20] = 56856, -- Glyph of the Hawk
      [21] = 56857, -- Glyph of the Beast
      [22] = 63065, -- Glyph of Chimera Shot
      [23] = 63066, -- Glyph of Explosive Shot
      [24] = 63067, -- Glyph of Kill Shot
      [25] = 63068, -- Glyph of Explosive Trap
      [26] = 63069, -- Glyph of Scatter Shot
      [27] = 63086  -- Glyph of Raptor Strike
    },
    [2] = {
      [1] = 57866,  -- Glyph of Revive Pet
      [2] = 57870,  -- Glyph of Mend Pet
      [3] = 57900,  -- Glyph of Possessed Strength
      [4] = 57902,  -- Glyph of Scare Beast
      [5] = 57903,  -- Glyph of Feign Death
      [6] = 57904   -- Glyph of the Pack
    },
  },
  ["ROGUE"] = {
    [1] = {
      [1] = 56798,  -- Glyph of Sap
      [2] = 56799,  -- Glyph of Evasion
      [3] = 56800,  -- Glyph of Backstab
      [4] = 56801,  -- Glyph of Rupture
      [5] = 56802,  -- Glyph of Eviscerate
      [6] = 56803,  -- Glyph of Expose Armor
      [7] = 56804,  -- Glyph of Feint
      [8] = 56805,  -- Glyph of Vigor
      [9] = 56806,  -- Glyph of Deadly Throw
      [10] = 56807, -- Glyph of Hemorrhage
      [11] = 56808, -- Glyph of Adrenaline Rush
      [12] = 56809, -- Glyph of Gouge
      [13] = 56810, -- Glyph of Slice and Dice
      [14] = 56811, -- Glyph of Sprint
      [15] = 56812, -- Glyph of Garrote
      [16] = 56813, -- Glyph of Ambush
      [17] = 56814, -- Glyph of Ghostly Strike
      [18] = 56818, -- Glyph of Blade Flurry
      [19] = 56819, -- Glyph of Preparation
      [20] = 56820, -- Glyph of Crippling Poison
      [21] = 56821, -- Glyph of Sinister Strike
      [22] = 63269, -- Glyph of Cloak of Shadows
      [23] = 63249, -- Glyph of Hunger of Blood
      [24] = 63252, -- Glyph of Killing Spree
      [25] = 63253, -- Glyph of Shadow Dance
      [26] = 63254, -- Glyph of Fan of Knives
      [27] = 63256, -- Glyph of Tricks of the Trade
      [28] = 63268, -- Glyph of Mutilate
      [29] = 64199  -- Glyph of Envenom
    },
    [2] = {
      [1] = 58017,  -- Glyph of Pick Pocket
      [2] = 58027,  -- Glyph of Pick Lock
      [3] = 58032,  -- Glyph of Distract
      [4] = 58033,  -- Glyph of Safe Fall
      [5] = 58038,  -- Glyph of Vanish
      [6] = 58039   -- Glyph of Blurred Speed
    },
  },
  ["PRIEST"] = {
    [1] = {
      [1] = 55672,  -- Glyph of Power Word: Shield
      [2] = 55673,  -- Glyph of Lightwell
      [3] = 55674,  -- Glyph of Renew
      [4] = 55675,  -- Glyph of Circle of Healing
      [5] = 55676,  -- Glyph of Psychic Scream
      [6] = 55677,  -- Glyph of Dispel Magic
      [7] = 55678,  -- Glyph of Fear Ward
      [8] = 55679,  -- Glyph of Flash Heal
      [9] = 55680,  -- Glyph of Prayer of Healing
      [10] = 55681, -- Glyph of Shadow Word: Pain
      [11] = 55682, -- Glyph of Shadow Word: Death
      [12] = 55683, -- Glyph of Holy Nova
      [13] = 55684, -- Glyph of Fade
      [14] = 55685, -- Glyph of Spirit of Redemption
      [15] = 55686, -- Glyph of Inner Fire
      [16] = 55687, -- Glyph of Mind Flay
      [17] = 55688, -- Glyph of Mind Control
      [18] = 55689, -- Glyph of Shadow
      [19] = 55690, -- Glyph of Scourge Imprisonment
      [20] = 55691, -- Glyph of Mass Dispel
      [21] = 55692, -- Glyph of Smite
      [22] = 63229, -- Glyph of Dispersion
      [23] = 63231, -- Glyph of Guardian Spirit
      [24] = 63235, -- Glyph of Penance
      [25] = 63237, -- Glyph of Mind Sear
      [26] = 63246, -- Glyph of Hymn of Hope
      [27] = 63248  -- Glyph of Pain Suppression
    },
    [2] = {
      [1] = 57985,  -- Glyph of Fading
      [2] = 57986,  -- Glyph of Shackle Undead
      [3] = 57987,  -- Glyph of Levitate
      [4] = 58009,  -- Glyph of Fortitude
      [5] = 58015,  -- Glyph of Shadow Protection
      [6] = 58228   -- Glyph of Shadowfiend
    },
  },
  ["DEATHKNIGHT"] = {
    [1] = {
      [1] = 58613,  -- Glyph of Dark Command
      [2] = 58616,  -- Glyph of Heart Strike
      [3] = 58618,  -- Glyph of Strangulate
      [4] = 58620,  -- Glyph of Chains of Ice
      [5] = 58623,  -- Glyph of Anti-Magic Shell
      [6] = 58625,  -- Glyph of Icebound Fortitude
      [7] = 58629,  -- Glyph of Death and Decay
      [8] = 58631,  -- Glyph of Icy Touch
      [9] = 58635,  -- Glyph of Unbreakable Armor
      [10] = 58642, -- Glyph of Scourge Strike
      [11] = 58647, -- Glyph of Frost Strike
      [12] = 58657, -- Glyph of Plague Strike
      [13] = 58669, -- Glyph of Rune Strike
      [14] = 58671, -- Glyph of Obliterate
      [15] = 58673, -- Glyph of Bone Shield
      [16] = 58676, -- Glyph of Vampiric Blood
      [17] = 58686, -- Glyph of the Ghoul
      [18] = 59327, -- Glyph of Rune Tap
      [19] = 59332, -- Glyph of Blood Strike
      [20] = 59336, -- Glyph of Death Strike
      [21] = 62259, -- Glyph of Death Grip
      [22] = 63330, -- Glyph of Dancing Rune Weapon
      [23] = 63331, -- Glyph of Hungering Cold
      [24] = 63332, -- Glyph of Unholy Blight
      [25] = 63333, -- Glyph of Dark Death
      [26] = 63334, -- Glyph of Disease
      [27] = 63335  -- Glyph of Howling Blast
    },
    [2] = {
      [1] = 58640,  -- Glyph of Blood Tap
      [2] = 58677,  -- Glyph of Death's Embrace
      [3] = 58680,  -- Glyph of Horn of Winter
      [4] = 59307,  -- Glyph of Corpse Explosion
      [5] = 59309,  -- Glyph of Pestilence
      [6] = 60200   -- Glyph of Raise Dead
    },
  },
  ["SHAMAN"] = {
    [1] = {
      [1] = 55436,  -- Glyph of Water Mastery
      [2] = 55437,  -- Glyph of Chain Heal
      [3] = 55438,  -- Glyph of Lesser Healing Wave
      [4] = 55439,  -- Glyph of Earthliving Weapon
      [5] = 55440,  -- Glyph of Healing Wave
      [6] = 55441,  -- Glyph of Mana Tide
      [7] = 55442,  -- Glyph of Shocking
      [8] = 55443,  -- Glyph of Frost Shock
      [9] = 55444,  -- Glyph of Lava Lash
      [10] = 55445, -- Glyph of Windfury Weapon
      [11] = 55446, -- Glyph of Stormstrike
      [12] = 55447, -- Glyph of Flame Shock
      [13] = 55448, -- Glyph of Lightning Shield
      [14] = 55449, -- Glyph of Chain Lightning
      [15] = 55450, -- Glyph of Fire Nova
      [16] = 55451, -- Glyph of Flametongue Weapon
      [17] = 55452, -- Glyph of Elemental Mastery
      [18] = 55453, -- Glyph of Lightning Bolt
      [19] = 55454, -- Glyph of Lava
      [20] = 55455, -- Glyph of Fire Elemental Totem
      [21] = 55456, -- Glyph of Healing Stream Totem
      [22] = 63270, -- Glyph of Thunder
      [23] = 63271, -- Glyph of Feral Spirit
      [24] = 63273, -- Glyph of Riptide
      [25] = 63279, -- Glyph of Earth Shield
      [26] = 63280, -- Glyph of Totem of Wrath
      [27] = 63291, -- Glyph of Hex
      [28] = 63298  -- Glyph of Stoneclaw Totem
    },
    [2] = {
      [1] = 58055,  -- Glyph of Water Breathing
      [2] = 58057,  -- Glyph of Water Walking
      [3] = 58058,  -- Glyph of Astral Recall
      [4] = 58059,  -- Glyph of Renewed Life
      [5] = 58063,  -- Glyph of Water Shield
      [6] = 59289,  -- Glyph of Ghost Wolf
      [7] = 62132   -- Glyph of Thunderstorm
    },
  },
  ["MAGE"] = {
    [1] = {
      [1] = 56360,  -- Glyph of Arcane Explosion
      [2] = 56363,  -- Glyph of Arcane Missiles
      [3] = 56364,  -- Glyph of Remove Curse
      [4] = 56365,  -- Glyph of Blink
      [5] = 56366,  -- Glyph of Invisibility
      [6] = 56367,  -- Glyph of Mana Gem
      [7] = 56368,  -- Glyph of Fireball
      [8] = 56369,  -- Glyph of Fire Blast
      [9] = 56370,  -- Glyph of Frostbolt
      [10] = 56371, -- Glyph of Scorch
      [11] = 56372, -- Glyph of Ice Block
      [12] = 56373, -- Glyph of Water Elemental
      [13] = 56374, -- Glyph of Icy Veins
      [14] = 56375, -- Glyph of Polymorph
      [15] = 56376, -- Glyph of Frost Nova
      [16] = 56377, -- Glyph of Ice Lance
      [17] = 56380, -- Glyph of Evocation
      [18] = 56381, -- Glyph of Arcane Power
      [19] = 56382, -- Glyph of Molten Armor
      [20] = 56383, -- Glyph of Mage Armor
      [21] = 56384, -- Glyph of Ice Armor
      [22] = 61205, -- Glyph of Frostfire
      [23] = 62210, -- Glyph of Arcane Blast
      [24] = 63090, -- Glyph of Deep Freeze
      [25] = 63091, -- Glyph of Living Bomb
      [26] = 63092, -- Glyph of Arcane Barrage
      [27] = 63093, -- Glyph of Mirror Image
      [28] = 63095, -- Glyph of Ice Barrier
      [29] = 70937  -- Glyph of Eternal Water
    },
    [2] = {
      [1] = 52648,  -- Glyph of the Penguin
      [2] = 57924,  -- Glyph of Arcane Intellect
      [3] = 57925,  -- Glyph of Slow Fall
      [4] = 57926,  -- Glyph of Fire Ward
      [5] = 57927,  -- Glyph of Frost Ward
      [6] = 57928,  -- Glyph of Frost Armor
      [7] = 62126   -- Glyph of Blast Wave
    },
  },
  ["WARLOCK"] = {
    [1] = {
      [1] = 56216,  -- Glyph of Siphon Life
      [2] = 56217,  -- Glyph of Howl of Terror
      [3] = 56218,  -- Glyph of Corruption
      [4] = 56224,  -- Glyph of Healthstone
      [5] = 56226,  -- Glyph of Searing Pain
      [6] = 56228,  -- Glyph of Immolate
      [7] = 56229,  -- Glyph of Shadowburn
      [8] = 56231,  -- Glyph of Soulstone
      [9] = 56232,  -- Glyph of Death Coil
      [10] = 56233, -- Glyph of Unstable Affliction
      [11] = 56235, -- Glyph of Conflagrate
      [12] = 56238, -- Glyph of Health Funnel
      [13] = 56240, -- Glyph of Shadow Bolt
      [14] = 56241, -- Glyph of Curse of Agony
      [15] = 56242, -- Glyph of Incinerate
      [16] = 56244, -- Glyph of Fear
      [17] = 56246, -- Glyph of Felguard
      [18] = 56247, -- Glyph of Voidwalker
      [19] = 56248, -- Glyph of Imp
      [20] = 56249, -- Glyph of Felhunter
      [21] = 56250, -- Glyph of Succubus
      [22] = 63302, -- Glyph of Haunt
      [23] = 63303, -- Glyph of Metamorphosis
      [24] = 63304, -- Glyph of Chaos Bolt
      [25] = 63309, -- Glyph of Demonic Circle
      [26] = 63310, -- Glyph of Shadowflame
      [27] = 63312, -- Glyph of Soul Link
      [28] = 63320, -- Glyph of Life Tap
      [29] = 70947  -- Glyph of Quick Decay
    },
    [2] = {
      [1] = 58070,  -- Glyph of Drain Soul
      [2] = 58079,  -- Glyph of Unending Breath
      [3] = 58080,  -- Glyph of Curse of Exhausion
      [4] = 58081,  -- Glyph of Kilrogg
      [5] = 58094,  -- Glyph of Souls
      [6] = 58107   -- Glyph of Subjugate Demon
    },
  },
  ["DRUID"] = {
    [1] = {
      [1] = 54733,  -- Glyph of Rebirth
      [2] = 54743,  -- Glyph of Regrowth
      [3] = 54754,  -- Glyph of Rejuvenation
      [4] = 54756,  -- Glyph of Wrath
      [5] = 54760,  -- Glyph of Entangling Roots
      [6] = 54810,  -- Glyph of Frenzied Regeneration
      [7] = 54811,  -- Glyph of Maul
      [8] = 54812,  -- Glyph of Growling
      [9] = 54813,  -- Glyph of Mangle
      [10] = 54815, -- Glyph of Shred
      [11] = 54818, -- Glyph of Rip
      [12] = 54821, -- Glyph of Rake
      [13] = 54824, -- Glyph of Swiftmend
      [14] = 54825, -- Glyph of Healing Touch
      [15] = 54826, -- Glyph of Lifebloom
      [16] = 54828, -- Glyph of Starfall
      [17] = 54829, -- Glyph of Moonfire
      [18] = 54830, -- Glyph of Insect Swarm
      [19] = 54831, -- Glyph of Hurricane
      [20] = 54832, -- Glyph of Innervate
      [21] = 54845, -- Glyph of Starfire
      [22] = 62080, -- Glyph of Focus
      [23] = 62969, -- Glyph of Berserk
      [24] = 62970, -- Glyph of Wild Growth
      [25] = 62971, -- Glyph of Nourish
      [26] = 63055, -- Glyph of Savage Roar
      [27] = 63056, -- Glyph of Monsoon
      [28] = 63057, -- Glyph of Barkskin
      [29] = 65243, -- Glyph of Survival Instincts
      [30] = 67598, -- Glyph of Claw
      [31] = 71013  -- Glyph of Rapid Rejuvenation
    },
    [2] = {
      [1] = 57855,  -- Glyph of the Wild
      [2] = 57856,  -- Glyph of Aquatic Form
      [3] = 57857,  -- Glyph of Unburdened Rebirth
      [4] = 57858,  -- Glyph of Challenging Roar
      [5] = 57862,  -- Glyph of Thorns
      [6] = 59219,  -- Glyph of Dash
      [7] = 62135   -- Glyph of Typhoon
    },
  }
}
if (not lib.glyph_r_tbl) then
    lib.glyph_r_tbl = {}
    for k,v in pairs (lib.glyphs_table[playerClass][1]) do
        lib.glyph_r_tbl[v] = k
    end
    for k,v in pairs (lib.glyphs_table[playerClass][2]) do
        lib.glyph_r_tbl[v] = k
    end
end
lib.talents_table = lib.talents_table or {
    ["HUNTER"] = {
        [1] = {
            [26] = {["name"] = "Kindred Spirits", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236202},
            [25] = {["name"] = "Longevity", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236186},
            [24] = {["isExceptional"] = 1, ["name"] = "Beast Mastery", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236175},
            [23] = {["name"] = "Aspect Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236172},
            [22] = {["name"] = "Cobra Strikes", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236177},
            [21] = {["name"] = "Invigoration", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236184},
            [20] = {["name"] = "The Beast Within", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132166},
            [19] = {["name"] = "Serpent's Swiftness", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132209},
            [18] = {["name"] = "Catlike Reflexes", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132167},
            [9] = {["name"] = "Bestial Discipline", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136006},
            [1] = {["name"] = "Improved Aspect of the Monkey", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132159},
            [15] = {["name"] = "Improved Revive Pet", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132163},
            [3] = {["name"] = "Pathfinding", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132242},
            [2] = {["name"] = "Improved Aspect of the Hawk", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136076},
            [5] = {["isExceptional"] = 1, ["name"] = "Bestial Wrath", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132127},
            [4] = {["name"] = "Improved Mend Pet", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132179},
            [7] = {["name"] = "Spirit Bond", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132121},
            [6] = {["isExceptional"] = 1, ["name"] = "Intimidation", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132111},
            [14] = {["name"] = "Focused Fire", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132210},
            [8] = {["name"] = "Endurance Training", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136080},
            [16] = {["name"] = "Animal Handler", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132158},
            [17] = {["name"] = "Ferocious Inspiration", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132173},
            [13] = {["name"] = "Frenzy", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134296},
            [12] = {["name"] = "Unleashed Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132091},
            [11] = {["name"] = "Thick Hide", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134355},
            [10] = {["name"] = "Ferocity", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134297},
        },
        [2] = {
            [27] = {["name"] = "Focused Aim", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236179},
            [26] = {["isExceptional"] = 1, ["name"] = "Chimera Shot", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236176},
            [25] = {["name"] = "Marked for Death", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236173},
            [24] = {["name"] = "Improved Steady Shot", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236182},
            [23] = {["name"] = "Wild Quiver", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236204},
            [22] = {["name"] = "Rapid Recuperation", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236201},
            [21] = {["name"] = "Piercing Shots", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236198},
            [20] = {["name"] = "Improved Barrage", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132330},
            [19] = {["name"] = "Rapid Killing", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132205},
            [18] = {["name"] = "Go for the Throat", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132174},
            [9] = {["name"] = "Mortal Shots", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132271},
            [1] = {["name"] = "Improved Concussive Shot", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135860},
            [15] = {["name"] = "Careful Aim", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132217},
            [3] = {["name"] = "Improved Hunter's Mark", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132212},
            [2] = {["name"] = "Efficiency", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135865},
            [5] = {["isExceptional"] = 1, ["name"] = "Aimed Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135130},
            [4] = {["name"] = "Lethal Shots", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132312},
            [7] = {["name"] = "Barrage", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132330},
            [6] = {["name"] = "Improved Arcane Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132218},
            [14] = {["name"] = "Combat Experience", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132168},
            [8] = {["name"] = "Improved Stings", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132204},
            [16] = {["name"] = "Master Marksman", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132177},
            [17] = {["isExceptional"] = 1, ["name"] = "Silencing Shot", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132323},
            [13] = {["name"] = "Ranged Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135615},
            [12] = {["isExceptional"] = 1, ["name"] = "Trueshot Aura", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132329},
            [11] = {["isExceptional"] = 1, ["name"] = "Readiness", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132206},
            [10] = {["name"] = "Concussive Barrage", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135753},
        },
        [3] = {
            [22] = {["name"] = "Noxious Stings", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236200},
            [27] = {["name"] = "Hunter vs. Wild", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236180},
            [26] = {["isExceptional"] = 1, ["name"] = "Explosive Shot", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236178},
            [25] = {["name"] = "Hunting Party", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236181},
            [24] = {["name"] = "Sniper Training", ["tier"] = 9, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 236187},
            [23] = {["name"] = "Point of No Escape", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236199},
            [28] = {["name"] = "T.N.T.", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 133713},
            [21] = {["name"] = "Hawk Eye", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132327},
            [20] = {["isExceptional"] = 1, ["name"] = "Scatter Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132153},
            [19] = {["name"] = "Master Tactician", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132178},
            [18] = {["name"] = "Expose Weakness", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132295},
            [9] = {["name"] = "Killer Instinct", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135881},
            [1] = {["name"] = "Lightning Reflexes", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136047},
            [15] = {["name"] = "Resourcefulness", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132207},
            [3] = {["name"] = "Trap Mastery", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132149},
            [2] = {["name"] = "Entrapment", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136100},
            [5] = {["name"] = "Survival Tactics", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132293},
            [4] = {["name"] = "Lock and Load", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 236185},
            [7] = {["name"] = "Deflection", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132269},
            [6] = {["name"] = "Surefooted", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132219},
            [14] = {["name"] = "Improved Tracking", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 236183},
            [8] = {["isExceptional"] = 1, ["name"] = "Counterattack", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132336},
            [16] = {["name"] = "Survival Instincts", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132214},
            [17] = {["name"] = "Thrill of the Hunt", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132216},
            [13] = {["name"] = "Survivalist", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136223},
            [12] = {["name"] = "Savage Strikes", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132277},
            [11] = {["isExceptional"] = 1, ["name"] = "Wyvern Sting", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135125},
            [10] = {["isExceptional"] = 1, ["name"] = "Black Arrow", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136181},
        },
    },
    ["WARRIOR"] = {
        [1] = {
            [31] = {["name"] = "Juggernaut", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 132335},
            [30] = {["name"] = "Improved Slam", ["tier"] = 7, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132340},
            [21] = {["name"] = "Second Wind", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132175},
            [22] = {["name"] = "Blood Frenzy", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132334},
            [27] = {["isExceptional"] = 1, ["name"] = "Bladestorm", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236303},
            [26] = {["name"] = "Strength of Arms", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132349},
            [25] = {["name"] = "Unrelenting Assault", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236317},
            [24] = {["name"] = "Trauma", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 236305},
            [23] = {["name"] = "Improved Mortal Strike", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132355},
            [28] = {["name"] = "Wrecking Crew", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132364},
            [29] = {["name"] = "Taste for Blood", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236276},
            [20] = {["name"] = "Sudden Death", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132346},
            [19] = {["isExceptional"] = 1, ["name"] = "Endless Rage", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132344},
            [18] = {["name"] = "Impale", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132312},
            [9] = {["name"] = "Deflection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [1] = {["name"] = "Deep Wounds", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132090},
            [15] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132400},
            [3] = {["name"] = "Improved Heroic Strike", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132282},
            [2] = {["name"] = "Sword Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135328},
            [5] = {["name"] = "Improved Charge", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132337},
            [4] = {["name"] = "Mace Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 133476},
            [7] = {["name"] = "Tactical Mastery", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136031},
            [6] = {["name"] = "Improved Rend", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132155},
            [14] = {["isExceptional"] = 1, ["name"] = "Mortal Strike", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132355},
            [8] = {["name"] = "Improved Hamstring", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132316},
            [16] = {["isExceptional"] = 1, ["name"] = "Anger Management", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135881},
            [17] = {["name"] = "Iron Will", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135995},
            [13] = {["name"] = "Weapon Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132367},
            [12] = {["isExceptional"] = 1, ["name"] = "Sweeping Strikes", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132306},
            [11] = {["name"] = "Poleaxe Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132397},
            [10] = {["name"] = "Improved Overpower", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135275},
        },
        [2] = {
            [27] = {["name"] = "Armored to the Teeth", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135053},
            [26] = {["name"] = "Unending Fury", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236310},
            [25] = {["isExceptional"] = 1, ["name"] = "Heroic Fury", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 236171},
            [24] = {["name"] = "Titan's Grip", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236316},
            [23] = {["name"] = "Bloodsurge", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236306},
            [22] = {["name"] = "Furious Attacks", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236308},
            [21] = {["name"] = "Intensify Rage", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132344},
            [20] = {["isExceptional"] = 1, ["name"] = "Rampage", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132352},
            [19] = {["name"] = "Improved Berserker Stance", ["tier"] = 8, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132275},
            [18] = {["name"] = "Precision", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132222},
            [9] = {["isExceptional"] = 1, ["name"] = "Death Wish", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136146},
            [1] = {["name"] = "Commanding Presence", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136035},
            [15] = {["name"] = "Improved Intercept", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132307},
            [3] = {["name"] = "Flurry", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132152},
            [2] = {["name"] = "Enrage", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136224},
            [5] = {["name"] = "Booming Voice", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136075},
            [4] = {["name"] = "Cruelty", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132292},
            [7] = {["isExceptional"] = 1, ["name"] = "Piercing Howl", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136147},
            [6] = {["name"] = "Unbridled Wrath", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136097},
            [14] = {["name"] = "Improved Execute", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135358},
            [8] = {["name"] = "Improved Demoralizing Shout", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132366},
            [16] = {["name"] = "Dual Wield Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132147},
            [17] = {["name"] = "Improved Whirlwind", ["tier"] = 7, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132369},
            [13] = {["name"] = "Improved Berserker Rage", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136009},
            [12] = {["name"] = "Blood Craze", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136218},
            [11] = {["isExceptional"] = 1, ["name"] = "Bloodthirst", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136012},
            [10] = {["name"] = "Improved Cleave", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132338},
        },
        [3] = {
            [27] = {["name"] = "Improved Spell Reflection", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132361},
            [26] = {["name"] = "Damage Shield", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 134976},
            [25] = {["name"] = "Warbringer", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 236319},
            [24] = {["name"] = "Critical Block", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236307},
            [23] = {["isExceptional"] = 1, ["name"] = "Shockwave", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236312},
            [22] = {["name"] = "Sword and Board", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236315},
            [21] = {["name"] = "Safeguard", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236311},
            [20] = {["isExceptional"] = 1, ["name"] = "Devastate", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135291},
            [19] = {["name"] = "Focused Rage", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132345},
            [18] = {["name"] = "Shield Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132360},
            [9] = {["name"] = "Gag Order", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132357},
            [1] = {["name"] = "Anticipation", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136056},
            [15] = {["name"] = "Shield Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 134952},
            [3] = {["name"] = "Improved Thunder Clap", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132326},
            [2] = {["name"] = "Toughness", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135892},
            [5] = {["name"] = "Incite", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236309},
            [4] = {["name"] = "Improved Bloodrage", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132277},
            [7] = {["name"] = "Improved Revenge", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132353},
            [6] = {["name"] = "Puncture", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132363},
            [14] = {["name"] = "One-Handed Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135321},
            [8] = {["isExceptional"] = 1, ["name"] = "Vigilance", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236318},
            [16] = {["name"] = "Improved Defensive Stance", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132341},
            [17] = {["name"] = "Vitality", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 133123},
            [13] = {["isExceptional"] = 1, ["name"] = "Last Stand", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135871},
            [12] = {["isExceptional"] = 1, ["name"] = "Concussion Blow", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132325},
            [11] = {["name"] = "Improved Disarm", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132343},
            [10] = {["name"] = "Improved Disciplines", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132362},
        },
    },
    ["PALADIN"] = {
        [1] = {
            [26] = {["name"] = "Judgements of the Pure", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 236256},
            [25] = {["name"] = "Blessed Hands", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 236248},
            [24] = {["name"] = "Infusion of Light", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 236254},
            [23] = {["isExceptional"] = 1, ["name"] = "Beacon of Light", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236247},
            [22] = {["name"] = "Enlightened Judgements", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236251},
            [21] = {["name"] = "Sacred Cleansing", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236261},
            [20] = {["isExceptional"] = 1, ["name"] = "Divine Illumination", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135895},
            [19] = {["name"] = "Holy Guidance", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135921},
            [18] = {["name"] = "Light's Grace", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135931},
            [9] = {["name"] = "Illumination", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135913},
            [1] = {["name"] = "Spiritual Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135736},
            [15] = {["name"] = "Pure of Heart", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135948},
            [3] = {["isExceptional"] = 1, ["name"] = "Aura Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135872},
            [2] = {["isExceptional"] = 1, ["name"] = "Divine Favor", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135915},
            [5] = {["name"] = "Healing Light", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135920},
            [4] = {["name"] = "Improved Lay on Hands", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135928},
            [7] = {["name"] = "Divine Intellect", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136090},
            [6] = {["name"] = "Improved Blessing of Wisdom", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135970},
            [14] = {["name"] = "Unyielding Faith", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135984},
            [8] = {["name"] = "Improved Concentration Aura", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135933},
            [16] = {["name"] = "Purifying Power", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135950},
            [17] = {["name"] = "Blessed Life", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135876},
            [13] = {["name"] = "Holy Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135938},
            [12] = {["isExceptional"] = 1, ["name"] = "Holy Shock", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135972},
            [11] = {["name"] = "Sanctified Light", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135917},
            [10] = {["name"] = "Seals of the Pure", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132325},
        },
        [2] = {
            [26] = {["name"] = "Spiritual Attunement", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135958},
            [25] = {["name"] = "Divine Guardian", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 253400},
            [24] = {["isExceptional"] = 1, ["name"] = "Divine Sacrifice", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 253400},
            [23] = {["name"] = "Shield of the Templar", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236264},
            [22] = {["name"] = "Judgements of the Just", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236259},
            [21] = {["isExceptional"] = 1, ["name"] = "Hammer of the Righteous", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236253},
            [20] = {["name"] = "Touched by the Light", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236267},
            [19] = {["name"] = "Guarded by the Light", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236252},
            [18] = {["name"] = "Divine Strength", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132154},
            [9] = {["name"] = "Divinity", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135883},
            [1] = {["name"] = "Redoubt", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132110},
            [15] = {["name"] = "Ardent Defender", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135870},
            [3] = {["name"] = "Toughness", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
            [2] = {["name"] = "Improved Devotion Aura", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135893},
            [5] = {["name"] = "Reckoning", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135882},
            [4] = {["name"] = "Guardian's Favor", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135964},
            [7] = {["isExceptional"] = 1, ["name"] = "Holy Shield", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135880},
            [6] = {["name"] = "One-Handed Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135321},
            [14] = {["name"] = "Sacred Duty", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135896},
            [8] = {["isExceptional"] = 1, ["name"] = "Blessing of Sanctuary", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136051},
            [16] = {["name"] = "Combat Expertise", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135986},
            [17] = {["isExceptional"] = 1, ["name"] = "Avenger's Shield", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135874},
            [13] = {["name"] = "Stoicism", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135978},
            [12] = {["name"] = "Anticipation", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135994},
            [11] = {["name"] = "Improved Hammer of Justice", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135963},
            [10] = {["name"] = "Improved Righteous Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135962},
        },
        [3] = {
            [26] = {["name"] = "Sheath of Light", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236263},
            [25] = {["name"] = "The Art of War", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236246},
            [24] = {["isExceptional"] = 1, ["name"] = "Divine Storm", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236250},
            [23] = {["name"] = "Righteous Vengeance", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236260},
            [22] = {["name"] = "Swift Retribution", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236266},
            [21] = {["name"] = "Sanctified Wrath", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236262},
            [20] = {["isExceptional"] = 1, ["name"] = "Crusader Strike", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135891},
            [19] = {["name"] = "Sanctity of Battle", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135924},
            [18] = {["name"] = "Fanaticism", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135905},
            [9] = {["isExceptional"] = 1, ["name"] = "Seal of Command", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132347},
            [1] = {["name"] = "Improved Blessing of Might", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135906},
            [15] = {["name"] = "Sanctified Retribution", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135934},
            [3] = {["name"] = "Deflection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [2] = {["name"] = "Vengeance", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132275},
            [5] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 133041},
            [4] = {["name"] = "Benediction", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135863},
            [7] = {["isExceptional"] = 1, ["name"] = "Repentance", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135942},
            [6] = {["name"] = "Conviction", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135957},
            [14] = {["name"] = "Crusade", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135889},
            [8] = {["name"] = "Heart of the Crusader", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135924},
            [16] = {["name"] = "Divine Purpose", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135897},
            [17] = {["name"] = "Judgements of the Wise", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236257},
            [13] = {["name"] = "Pursuit of Justice", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135937},
            [12] = {["name"] = "Vindication", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135985},
            [11] = {["name"] = "Eye for an Eye", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135904},
            [10] = {["name"] = "Improved Judgements", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135959},
        },
    },
    ["MAGE"] = {
        [1] = {
            [10] = {["isExceptional"] = 1, ["name"] = "Presence of Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136031},
            [11] = {["isExceptional"] = 1, ["name"] = "Arcane Power", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136048},
            [12] = {["name"] = "Improved Counterspell", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135856},
            [13] = {["name"] = "Arcane Instability", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136222},
            [17] = {["name"] = "Arcane Potency", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135732},
            [16] = {["name"] = "Improved Blink", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135736},
            [8] = {["name"] = "Arcane Shielding", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136153},
            [14] = {["name"] = "Arcane Meditation", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136208},
            [28] = {["name"] = "Missile Barrage", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 236221},
            [29] = {["isExceptional"] = 1, ["name"] = "Focus Magic", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 135754},
            [21] = {["isExceptional"] = 1, ["name"] = "Slow", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136091},
            [9] = {["name"] = "Arcane Fortitude", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135733},
            [4] = {["name"] = "Arcane Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136129},
            [5] = {["name"] = "Arcane Stability", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136096},
            [1] = {["name"] = "Arcane Subtlety", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135894},
            [15] = {["name"] = "Magic Absorption", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136011},
            [3] = {["name"] = "Arcane Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135892},
            [2] = {["name"] = "Arcane Concentration", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136170},
            [19] = {["name"] = "Arcane Empowerment", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136096},
            [18] = {["name"] = "Prismatic Cloak", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135752},
            [7] = {["name"] = "Magic Attunement", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136006},
            [6] = {["name"] = "Spell Impact", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136116},
            [25] = {["name"] = "Student of the Mind", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236225},
            [24] = {["name"] = "Incanter's Absorption", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236219},
            [27] = {["isExceptional"] = 1, ["name"] = "Arcane Barrage", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236205},
            [26] = {["name"] = "Netherwind Presence", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236222},
            [20] = {["name"] = "Mind Mastery", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135740},
            [30] = {["name"] = "Torment the Weak", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 236226},
            [22] = {["name"] = "Spell Power", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135734},
            [23] = {["name"] = "Arcane Flows", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 236223},
        },
        [2] = {
            [10] = {["isExceptional"] = 1, ["name"] = "Blast Wave", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135903},
            [11] = {["name"] = "Critical Mass", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136115},
            [12] = {["name"] = "Ignite", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135818},
            [13] = {["name"] = "Fire Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135817},
            [17] = {["name"] = "Playing with Fire", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135823},
            [16] = {["name"] = "Master of Elements", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135820},
            [28] = {["name"] = "Burning Determination", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135829},
            [8] = {["name"] = "Impact", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135821},
            [14] = {["isExceptional"] = 1, ["name"] = "Combustion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135824},
            [9] = {["name"] = "World in Flames", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236228},
            [15] = {["name"] = "Incineration", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135813},
            [4] = {["name"] = "Improved Fireball", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135812},
            [1] = {["name"] = "Burning Soul", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135805},
            [5] = {["name"] = "Improved Fire Blast", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135807},
            [3] = {["name"] = "Improved Scorch", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135827},
            [2] = {["name"] = "Molten Shields", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135806},
            [19] = {["name"] = "Molten Fury", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135822},
            [18] = {["name"] = "Blazing Speed", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135788},
            [7] = {["isExceptional"] = 1, ["name"] = "Pyroblast", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135808},
            [6] = {["name"] = "Flame Throwing", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135815},
            [25] = {["name"] = "Hot Streak", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236218},
            [24] = {["name"] = "Firestarter", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236216},
            [27] = {["isExceptional"] = 1, ["name"] = "Living Bomb", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236220},
            [26] = {["name"] = "Burnout", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236207},
            [20] = {["name"] = "Pyromaniac", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135789},
            [21] = {["name"] = "Empowered Fire", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135812},
            [22] = {["isExceptional"] = 1, ["name"] = "Dragon's Breath", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134153},
            [23] = {["name"] = "Fiery Payback", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236215},
        },
        [3] = {
            [10] = {["name"] = "Winter's Chill", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135836},
            [11] = {["isExceptional"] = 1, ["name"] = "Icy Veins", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135838},
            [12] = {["name"] = "Frost Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135850},
            [13] = {["isExceptional"] = 1, ["name"] = "Ice Barrier", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135988},
            [17] = {["name"] = "Precision", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135989},
            [16] = {["name"] = "Arctic Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136141},
            [28] = {["name"] = "Shattered Barrier", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236224},
            [8] = {["name"] = "Frost Channeling", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135860},
            [14] = {["isExceptional"] = 1, ["name"] = "Cold Snap", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135865},
            [9] = {["name"] = "Shatter", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135849},
            [15] = {["name"] = "Ice Shards", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135855},
            [4] = {["name"] = "Ice Floes", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135854},
            [1] = {["name"] = "Improved Frostbolt", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135846},
            [5] = {["name"] = "Improved Blizzard", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135857},
            [3] = {["name"] = "Piercing Ice", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135845},
            [2] = {["name"] = "Frostbite", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135842},
            [19] = {["name"] = "Cold as Ice", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236209},
            [18] = {["name"] = "Frozen Core", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135851},
            [7] = {["name"] = "Permafrost", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135864},
            [6] = {["name"] = "Improved Cone of Cold", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135852},
            [25] = {["name"] = "Enduring Winter", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135862},
            [24] = {["name"] = "Brain Freeze", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236206},
            [27] = {["isExceptional"] = 1, ["name"] = "Deep Freeze", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236214},
            [26] = {["name"] = "Chilled to the Bone", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236208},
            [20] = {["name"] = "Arctic Winds", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135833},
            [21] = {["name"] = "Empowered Frostbolt", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135846},
            [22] = {["isExceptional"] = 1, ["name"] = "Summon Water Elemental", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135862},
            [23] = {["name"] = "Fingers of Frost", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236227},
        },
    },
    ["PRIEST"] = {
        [1] = {
            [22] = {["name"] = "Divine Aegis", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237539},
            [27] = {["name"] = "Renewed Hope", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135923},
            [26] = {["name"] = "Grace", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 237543},
            [25] = {["name"] = "Twin Disciplines", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135969},
            [24] = {["isExceptional"] = 1, ["name"] = "Penance", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237545},
            [23] = {["name"] = "Rapture", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 237548},
            [28] = {["name"] = "Reflective Shield", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135940},
            [21] = {["name"] = "Aspiration", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 237537},
            [20] = {["name"] = "Focused Will", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135737},
            [19] = {["isExceptional"] = 1, ["name"] = "Pain Suppression", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135936},
            [18] = {["name"] = "Improved Flash Heal", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135886},
            [9] = {["isExceptional"] = 1, ["name"] = "Inner Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135863},
            [1] = {["name"] = "Martyrdom", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136107},
            [15] = {["name"] = "Absolution", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135868},
            [3] = {["name"] = "Mental Agility", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132156},
            [2] = {["isExceptional"] = 1, ["name"] = "Power Infusion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135939},
            [5] = {["name"] = "Improved Power Word: Shield", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135940},
            [4] = {["name"] = "Unbreakable Will", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135995},
            [7] = {["name"] = "Improved Inner Fire", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135926},
            [6] = {["name"] = "Improved Power Word: Fortitude", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135987},
            [14] = {["name"] = "Borrowed Time", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 237538},
            [8] = {["name"] = "Meditation", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136090},
            [16] = {["name"] = "Focused Power", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136158},
            [17] = {["name"] = "Enlightenment", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135740},
            [13] = {["name"] = "Mental Strength", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136031},
            [12] = {["name"] = "Silent Resolve", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136053},
            [11] = {["isExceptional"] = 1, ["name"] = "Soul Warding", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135948},
            [10] = {["name"] = "Improved Mana Burn", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136170},
        },
        [2] = {
            [27] = {["name"] = "Body and Soul", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135982},
            [26] = {["isExceptional"] = 1, ["name"] = "Guardian Spirit", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237542},
            [25] = {["name"] = "Divine Providence", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 237541},
            [24] = {["name"] = "Serendipity", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237549},
            [23] = {["name"] = "Test of Faith", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237550},
            [22] = {["name"] = "Empowered Renew", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236254},
            [21] = {["isExceptional"] = 1, ["name"] = "Circle of Healing", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135887},
            [20] = {["name"] = "Holy Concentration", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135905},
            [19] = {["name"] = "Empowered Healing", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135913},
            [18] = {["name"] = "Surge of Light", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135981},
            [9] = {["name"] = "Spell Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135976},
            [1] = {["name"] = "Inspiration", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135928},
            [15] = {["name"] = "Blessed Recovery", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135877},
            [3] = {["name"] = "Spiritual Guidance", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135977},
            [2] = {["name"] = "Holy Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135967},
            [5] = {["name"] = "Spiritual Healing", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136057},
            [4] = {["name"] = "Searing Light", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135973},
            [7] = {["name"] = "Improved Healing", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135916},
            [6] = {["name"] = "Improved Renew", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135953},
            [14] = {["name"] = "Holy Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135949},
            [8] = {["name"] = "Healing Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135918},
            [16] = {["isExceptional"] = 1, ["name"] = "Lightwell", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135980},
            [17] = {["name"] = "Blessed Resilience", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135878},
            [13] = {["isExceptional"] = 1, ["name"] = "Spirit of Redemption", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132864},
            [12] = {["name"] = "Divine Fury", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135971},
            [11] = {["isExceptional"] = 1, ["name"] = "Desperate Prayer", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135954},
            [10] = {["name"] = "Healing Prayers", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135943},
        },
        [3] = {
            [27] = {["name"] = "Improved Devouring Plague", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 252996},
            [26] = {["name"] = "Improved Spirit Tap", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136188},
            [25] = {["isExceptional"] = 1, ["name"] = "Dispersion", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237563},
            [24] = {["name"] = "Pain and Suffering", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237567},
            [23] = {["isExceptional"] = 1, ["name"] = "Psychic Horror", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 237568},
            [22] = {["name"] = "Twisted Faith", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 237566},
            [21] = {["name"] = "Improved Shadowform", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136221},
            [20] = {["name"] = "Misery", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136176},
            [19] = {["name"] = "Mind Melt", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 237569},
            [18] = {["isExceptional"] = 1, ["name"] = "Vampiric Touch", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135978},
            [9] = {["isExceptional"] = 1, ["name"] = "Vampiric Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136230},
            [1] = {["name"] = "Shadow Weaving", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136123},
            [15] = {["name"] = "Improved Vampiric Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136165},
            [3] = {["name"] = "Shadow Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136126},
            [2] = {["name"] = "Darkness", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136223},
            [5] = {["name"] = "Shadow Affinity", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136205},
            [4] = {["name"] = "Spirit Tap", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136188},
            [7] = {["name"] = "Improved Shadow Word: Pain", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136207},
            [6] = {["name"] = "Improved Mind Blast", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136224},
            [14] = {["name"] = "Shadow Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136130},
            [8] = {["name"] = "Veiled Shadows", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135994},
            [16] = {["name"] = "Focused Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136035},
            [17] = {["name"] = "Shadow Power", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136204},
            [13] = {["name"] = "Improved Psychic Scream", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136184},
            [12] = {["isExceptional"] = 1, ["name"] = "Silence", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136164},
            [11] = {["isExceptional"] = 1, ["name"] = "Shadowform", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136200},
            [10] = {["isExceptional"] = 1, ["name"] = "Mind Flay", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136208},
        },
    },
    ["WARLOCK"] = {
        [1] = {
            [22] = {["name"] = "Improved Felhunter", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136217},
            [27] = {["name"] = "Improved Fear", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136183},
            [26] = {["isExceptional"] = 1, ["name"] = "Haunt", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236298},
            [25] = {["name"] = "Eradication", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236295},
            [24] = {["name"] = "Everlasting Affliction", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236296},
            [23] = {["name"] = "Death's Embrace", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237557},
            [28] = {["name"] = "Pandemic", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136227},
            [21] = {["name"] = "Empowered Corruption", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136118},
            [20] = {["name"] = "Shadow Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136198},
            [19] = {["isExceptional"] = 1, ["name"] = "Unstable Affliction", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136228},
            [18] = {["name"] = "Contagion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136180},
            [9] = {["isExceptional"] = 1, ["name"] = "Dark Pact", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136141},
            [1] = {["name"] = "Fel Concentration", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136157},
            [15] = {["name"] = "Improved Curse of Agony", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136139},
            [3] = {["name"] = "Improved Corruption", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136118},
            [2] = {["name"] = "Nightfall", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136223},
            [5] = {["name"] = "Suppression", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136230},
            [4] = {["name"] = "Soul Siphon", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136169},
            [7] = {["name"] = "Improved Life Tap", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136126},
            [6] = {["name"] = "Improved Curse of Weakness", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136138},
            [14] = {["name"] = "Improved Drain Soul", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136163},
            [8] = {["name"] = "Grim Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136127},
            [16] = {["name"] = "Malediction", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136137},
            [17] = {["name"] = "Improved Howl of Terror", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136147},
            [13] = {["isExceptional"] = 1, ["name"] = "Curse of Exhaustion", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136162},
            [12] = {["isExceptional"] = 1, ["name"] = "Amplify Curse", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136132},
            [11] = {["name"] = "Shadow Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136195},
            [10] = {["isExceptional"] = 1, ["name"] = "Siphon Life", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136188},
        },
        [2] = {
            [27] = {["name"] = "Decimation", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135808},
            [26] = {["isExceptional"] = 1, ["name"] = "Metamorphosis", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237558},
            [25] = {["name"] = "Demonic Pact", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 237562},
            [24] = {["name"] = "Nemesis", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237561},
            [23] = {["name"] = "Fel Synergy", ["tier"] = 1, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 237564},
            [22] = {["name"] = "Improved Demonic Tactics", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236299},
            [21] = {["isExceptional"] = 1, ["name"] = "Demonic Empowerment", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236292},
            [20] = {["name"] = "Demonic Resilience", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136149},
            [19] = {["name"] = "Demonic Tactics", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136150},
            [18] = {["isExceptional"] = 1, ["name"] = "Summon Felguard", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136216},
            [9] = {["name"] = "Improved Sayaad", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136220},
            [1] = {["name"] = "Improved Healthstone", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135230},
            [15] = {["isExceptional"] = 1, ["name"] = "Soul Link", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136160},
            [3] = {["name"] = "Demonic Embrace", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136172},
            [2] = {["name"] = "Improved Imp", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136218},
            [5] = {["name"] = "Demonic Brutality", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136221},
            [4] = {["name"] = "Improved Health Funnel", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136168},
            [7] = {["name"] = "Master Summoner", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136164},
            [6] = {["isExceptional"] = 1, ["name"] = "Fel Domination", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136082},
            [14] = {["isExceptional"] = 1, ["name"] = "Mana Feed", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136171},
            [8] = {["name"] = "Fel Vitality", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135932},
            [16] = {["name"] = "Molten Core", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236301},
            [17] = {["name"] = "Demonic Aegis", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136185},
            [13] = {["name"] = "Demonic Knowledge", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136165},
            [12] = {["name"] = "Unholy Power", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136206},
            [11] = {["name"] = "Master Conjuror", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132386},
            [10] = {["name"] = "Master Demonologist", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136203},
        },
        [3] = {
            [26] = {["name"] = "Empowered Imp", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236294},
            [25] = {["isExceptional"] = 1, ["name"] = "Chaos Bolt", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236291},
            [24] = {["name"] = "Fire and Brimstone", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236297},
            [23] = {["name"] = "Improved Soul Leech", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236300},
            [22] = {["name"] = "Backdraft", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236290},
            [21] = {["name"] = "Molten Skin", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132221},
            [20] = {["name"] = "Backlash", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135823},
            [19] = {["name"] = "Nether Protection", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136178},
            [18] = {["name"] = "Soul Leech", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136214},
            [9] = {["name"] = "Ruin", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136207},
            [1] = {["name"] = "Cataclysm", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135831},
            [15] = {["name"] = "Pyroclasm", ["tier"] = 7, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135830},
            [3] = {["name"] = "Improved Shadow Bolt", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136197},
            [2] = {["name"] = "Bane", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136146},
            [5] = {["isExceptional"] = 1, ["name"] = "Shadowburn", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136191},
            [4] = {["name"] = "Improved Immolate", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135817},
            [7] = {["name"] = "Improved Searing Pain", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135827},
            [6] = {["name"] = "Destructive Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136133},
            [14] = {["name"] = "Intensity", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135819},
            [8] = {["name"] = "Emberstorm", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135826},
            [16] = {["isExceptional"] = 1, ["name"] = "Shadowfury", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136201},
            [17] = {["name"] = "Shadow and Flame", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136196},
            [13] = {["name"] = "Demonic Power", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135809},
            [12] = {["name"] = "Aftermath", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135805},
            [11] = {["name"] = "Devastation", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135813},
            [10] = {["isExceptional"] = 1, ["name"] = "Conflagrate", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135807},
        },
    },
    ["ROGUE"] = {
        [1] = {
            [27] = {["isExceptional"] = 1, ["name"] = "Hunger For Blood", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236276},
            [26] = {["name"] = "Cut to the Chase", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236269},
            [25] = {["name"] = "Focused Attacks", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236274},
            [24] = {["name"] = "Blood Spatter", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 236268},
            [23] = {["name"] = "Turn the Tables", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236284},
            [22] = {["name"] = "Deadly Brew", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236270},
            [21] = {["name"] = "Quick Recovery", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132301},
            [20] = {["name"] = "Deadened Nerves", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132286},
            [19] = {["name"] = "Fleet Footed", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132296},
            [18] = {["isExceptional"] = 1, ["name"] = "Mutilate", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132304},
            [9] = {["name"] = "Improved Expose Armor", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132354},
            [1] = {["name"] = "Improved Poisons", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132273},
            [15] = {["name"] = "Vile Poisons", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132293},
            [3] = {["name"] = "Malice", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132277},
            [2] = {["name"] = "Lethality", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132109},
            [5] = {["name"] = "Ruthlessness", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132122},
            [4] = {["name"] = "Remorseless Attacks", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132151},
            [7] = {["name"] = "Improved Eviscerate", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132292},
            [6] = {["name"] = "Murder", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136147},
            [14] = {["name"] = "Vigor", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136023},
            [8] = {["name"] = "Puncturing Wounds", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132090},
            [16] = {["name"] = "Master Poisoner", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132108},
            [17] = {["name"] = "Find Weakness", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132295},
            [13] = {["name"] = "Seal Fate", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136130},
            [12] = {["isExceptional"] = 1, ["name"] = "Overkill", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132205},
            [11] = {["isExceptional"] = 1, ["name"] = "Cold Blood", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135988},
            [10] = {["name"] = "Improved Kidney Shot", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132298},
        },
        [2] = {
            [22] = {["name"] = "Combat Potency", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135673},
            [27] = {["name"] = "Prey on the Weak", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236278},
            [26] = {["name"] = "Savage Combat", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132100},
            [25] = {["name"] = "Unfair Advantage", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236285},
            [24] = {["name"] = "Throwing Specialization", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 236282},
            [23] = {["name"] = "Improved Slice and Dice", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132306},
            [28] = {["isExceptional"] = 1, ["name"] = "Killing Spree", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236277},
            [21] = {["isExceptional"] = 1, ["name"] = "Surprise Attacks", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132308},
            [20] = {["name"] = "Nerves of Steel", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132300},
            [19] = {["name"] = "Blade Twisting", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132283},
            [18] = {["name"] = "Vitality", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132353},
            [9] = {["isExceptional"] = 1, ["name"] = "Adrenaline Rush", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136206},
            [1] = {["name"] = "Precision", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132222},
            [15] = {["isExceptional"] = 1, ["name"] = "Riposte", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132336},
            [3] = {["name"] = "Mace Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 133476},
            [2] = {["name"] = "Close Quarters Combat", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135641},
            [5] = {["name"] = "Deflection", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132269},
            [4] = {["name"] = "Lightning Reflexes", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136047},
            [7] = {["name"] = "Improved Gouge", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132155},
            [6] = {["name"] = "Improved Sinister Strike", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136189},
            [14] = {["name"] = "Hack and Slash", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135328},
            [8] = {["name"] = "Endurance", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136205},
            [16] = {["name"] = "Aggression", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132275},
            [17] = {["name"] = "Weapon Expertise", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135882},
            [13] = {["isExceptional"] = 1, ["name"] = "Blade Flurry", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132350},
            [12] = {["name"] = "Improved Sprint", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132307},
            [11] = {["name"] = "Dual Wield Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132147},
            [10] = {["name"] = "Improved Kick", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132219},
        },
        [3] = {
            [22] = {["name"] = "Cheat Death", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132285},
            [27] = {["isExceptional"] = 1, ["name"] = "Shadow Dance", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236279},
            [26] = {["name"] = "Slaughter from the Shadows", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236280},
            [25] = {["name"] = "Filthy Tricks", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236287},
            [24] = {["name"] = "Honor Among Thieves", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236275},
            [23] = {["name"] = "Waylay", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236286},
            [28] = {["name"] = "Relentless Strikes", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132340},
            [21] = {["isExceptional"] = 1, ["name"] = "Shadowstep", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132303},
            [20] = {["name"] = "Master of Subtlety", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132299},
            [19] = {["name"] = "Sinister Calling", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132305},
            [18] = {["name"] = "Enveloping Shadows", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132291},
            [9] = {["name"] = "Dirty Deeds", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136220},
            [1] = {["name"] = "Master of Deception", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136129},
            [15] = {["name"] = "Sleight of Hand", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132294},
            [3] = {["name"] = "Initiative", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136159},
            [2] = {["name"] = "Camouflage", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132320},
            [5] = {["name"] = "Elusiveness", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135994},
            [4] = {["name"] = "Setup", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136056},
            [7] = {["name"] = "Dirty Tricks", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132310},
            [6] = {["name"] = "Opportunity", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132366},
            [14] = {["name"] = "Serrated Blades", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135315},
            [8] = {["name"] = "Improved Ambush", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132282},
            [16] = {["name"] = "Heightened Senses", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132089},
            [17] = {["name"] = "Deadliness", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135540},
            [13] = {["isExceptional"] = 1, ["name"] = "Hemorrhage", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136168},
            [12] = {["isExceptional"] = 1, ["name"] = "Premeditation", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136183},
            [11] = {["isExceptional"] = 1, ["name"] = "Ghostly Strike", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136136},
            [10] = {["isExceptional"] = 1, ["name"] = "Preparation", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136121},
        },
    },
    ["DRUID"] = {
        [1] = {
            [22] = {["name"] = "Eclipse", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236151},
            [27] = {["name"] = "Improved Insect Swarm", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136045},
            [26] = {["name"] = "Genesis", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135730},
            [25] = {["name"] = "Earth and Moon", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 236150},
            [24] = {["isExceptional"] = 1, ["name"] = "Starfall", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236168},
            [23] = {["name"] = "Gale Winds", ["tier"] = 9, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 236154},
            [28] = {["name"] = "Nature's Splendor", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136060},
            [21] = {["isExceptional"] = 1, ["name"] = "Typhoon", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236170},
            [20] = {["name"] = "Owlkin Frenzy", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236163},
            [19] = {["name"] = "Improved Moonkin Form", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236156},
            [18] = {["name"] = "Nature's Majesty", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135138},
            [9] = {["name"] = "Moonfury", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136057},
            [1] = {["name"] = "Starlight Wrath", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136006},
            [15] = {["name"] = "Improved Faerie Fire", ["tier"] = 7, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136033},
            [3] = {["name"] = "Nature's Reach", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136065},
            [2] = {["name"] = "Improved Moonfire", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136096},
            [5] = {["name"] = "Moonglow", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136087},
            [4] = {["name"] = "Brambles", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136104},
            [7] = {["isExceptional"] = 1, ["name"] = "Insect Swarm", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136045},
            [6] = {["name"] = "Celestial Focus", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135753},
            [14] = {["name"] = "Dreamstate", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132123},
            [8] = {["name"] = "Nature's Grace", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136062},
            [16] = {["name"] = "Wrath of Cenarius", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132146},
            [17] = {["isExceptional"] = 1, ["name"] = "Force of Nature", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132129},
            [13] = {["name"] = "Balance of Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132113},
            [12] = {["name"] = "Lunar Guidance", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132132},
            [11] = {["isExceptional"] = 1, ["name"] = "Moonkin Form", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136036},
            [10] = {["name"] = "Vengeance", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136075},
        },
        [2] = {
            [30] = {["name"] = "Primal Gore", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132140},
            [21] = {["name"] = "Improved Leader of the Pack", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136112},
            [22] = {["name"] = "Primal Precision", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 236165},
            [27] = {["isExceptional"] = 1, ["name"] = "Berserk", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236149},
            [26] = {["name"] = "King of the Jungle", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236159},
            [25] = {["name"] = "Improved Mangle", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132135},
            [24] = {["name"] = "Infected Wounds", ["tier"] = 8, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 236158},
            [23] = {["name"] = "Rend and Tear", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 236164},
            [28] = {["name"] = "Protector of the Pack", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132117},
            [29] = {["name"] = "Natural Reaction", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132091},
            [20] = {["name"] = "Mangle", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132135},
            [19] = {["name"] = "Predatory Instincts", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132138},
            [18] = {["name"] = "Survival of the Fittest", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132126},
            [9] = {["name"] = "Predatory Strikes", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132185},
            [1] = {["name"] = "Thick Hide", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134355},
            [15] = {["isExceptional"] = 1, ["name"] = "Survival Instincts", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236169},
            [3] = {["name"] = "Ferocity", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132190},
            [2] = {["name"] = "Feral Aggression", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132121},
            [5] = {["name"] = "Sharpened Claws", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134297},
            [4] = {["name"] = "Brutal Impact", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132114},
            [7] = {["name"] = "Primal Fury", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132278},
            [6] = {["name"] = "Feral Instinct", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132089},
            [14] = {["isExceptional"] = 1, ["name"] = "Leader of the Pack", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136112},
            [8] = {["name"] = "Shredding Attacks", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136231},
            [16] = {["name"] = "Nurturing Instinct", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132130},
            [17] = {["name"] = "Primal Tenacity", ["tier"] = 7, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132139},
            [13] = {["name"] = "Heart of the Wild", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135879},
            [12] = {["name"] = "Feral Swiftness", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136095},
            [11] = {["name"] = "Savage Fury", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132141},
            [10] = {["name"] = "Feral Charge", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132183},
        },
        [3] = {
            [27] = {["name"] = "Improved Barkskin", ["tier"] = 10, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136097},
            [26] = {["name"] = "Improved Tree of Life", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236157},
            [25] = {["name"] = "Revitalize", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 236166},
            [24] = {["name"] = "Living Seed", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 236155},
            [23] = {["isExceptional"] = 1, ["name"] = "Wild Growth", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236153},
            [22] = {["name"] = "Gift of the Earthmother", ["tier"] = 10, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 236160},
            [21] = {["name"] = "Master Shapeshifter", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236161},
            [20] = {["name"] = "Living Spirit", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136037},
            [19] = {["isExceptional"] = 1, ["name"] = "Tree of Life", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132145},
            [18] = {["name"] = "Natural Perfection", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132137},
            [9] = {["name"] = "Intensity", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135863},
            [1] = {["name"] = "Improved Mark of the Wild", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136078},
            [15] = {["isExceptional"] = 1, ["name"] = "Swiftmend", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134914},
            [3] = {["name"] = "Nature's Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136042},
            [2] = {["name"] = "Furor", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135881},
            [5] = {["name"] = "Nature's Bounty", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136085},
            [4] = {["name"] = "Naturalist", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136041},
            [7] = {["name"] = "Omen of Clarity", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136017},
            [6] = {["name"] = "Natural Shapeshifter", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136116},
            [14] = {["name"] = "Tranquil Spirit", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135900},
            [8] = {["name"] = "Gift of Nature", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136074},
            [16] = {["name"] = "Empowered Touch", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132125},
            [17] = {["name"] = "Empowered Rejuvenation", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132124},
            [13] = {["name"] = "Improved Tranquility", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136107},
            [12] = {["name"] = "Subtlety", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132150},
            [11] = {["isExceptional"] = 1, ["name"] = "Nature's Swiftness", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136076},
            [10] = {["name"] = "Improved Rejuvenation", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136081},
        },
    },
    ["DEATHKNIGHT"] = {
        [1] = {
            [22] = {["name"] = "Spell Deflection", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237531},
            [27] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135378},
            [26] = {["name"] = "Abomination's Might", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 236310},
            [25] = {["name"] = "Death Rune Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135372},
            [24] = {["name"] = "Blood Gorged", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136080},
            [23] = {["isExceptional"] = 1, ["name"] = "Vampiric Blood", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136168},
            [28] = {["name"] = "Improved Death Strike", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 237517},
            [21] = {["name"] = "Blade Barrier", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132330},
            [20] = {["name"] = "Bloody Strikes", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135772},
            [19] = {["isExceptional"] = 1, ["name"] = "Dancing Rune Weapon", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135277},
            [18] = {["name"] = "Bloodworms", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136211},
            [9] = {["name"] = "Scent of Blood", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132284},
            [1] = {["name"] = "Improved Blood Presence", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135770},
            [15] = {["isExceptional"] = 1, ["name"] = "Heart Strike", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135675},
            [3] = {["name"] = "Butchery", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132455},
            [2] = {["name"] = "Bladed Armor", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135067},
            [5] = {["name"] = "Improved Rune Tap", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237529},
            [4] = {["isExceptional"] = 1, ["name"] = "Rune Tap", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 237529},
            [7] = {["name"] = "Bloody Vengeance", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132090},
            [6] = {["name"] = "Dark Conviction", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 237518},
            [14] = {["name"] = "Sudden Doom", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136181},
            [8] = {["name"] = "Subversion", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 237533},
            [16] = {["name"] = "Might of Mograine", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135771},
            [17] = {["name"] = "Will of the Necropolis", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132094},
            [13] = {["isExceptional"] = 1, ["name"] = "Unholy Frenzy", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237512},
            [12] = {["name"] = "Vendetta", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 237536},
            [11] = {["name"] = "Veteran of the Third War", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136005},
            [10] = {["isExceptional"] = 1, ["name"] = "Mark of Blood", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 132205},
        },
        [2] = {
            [21] = {["name"] = "Guile of Gorefiend", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132373},
            [22] = {["name"] = "Icy Talons", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 252994},
            [27] = {["name"] = "Improved Icy Talons", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 252994},
            [26] = {["isExceptional"] = 1, ["name"] = "Lichborne", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136187},
            [25] = {["name"] = "Blood of the North", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135714},
            [24] = {["name"] = "Annihilation", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135609},
            [23] = {["name"] = "Killing Machine", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135305},
            [28] = {["name"] = "Chilblains", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135864},
            [29] = {["name"] = "Threat of Thassarian", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132148},
            [20] = {["name"] = "Icy Reach", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135859},
            [19] = {["name"] = "Improved Icy Touch", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237526},
            [18] = {["name"] = "Glacier Rot", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136083},
            [9] = {["name"] = "Frigid Dreadplate", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132734},
            [1] = {["name"] = "Toughness", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
            [15] = {["name"] = "Runic Power Mastery", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135728},
            [3] = {["name"] = "Black Ice", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136141},
            [2] = {["name"] = "Endless Winter", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136223},
            [5] = {["isExceptional"] = 1, ["name"] = "Unbreakable Armor", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132388},
            [4] = {["isExceptional"] = 1, ["name"] = "Frost Strike", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237520},
            [7] = {["name"] = "Chill of the Grave", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135849},
            [6] = {["isExceptional"] = 1, ["name"] = "Deathchill", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136213},
            [14] = {["isExceptional"] = 1, ["name"] = "Hungering Cold", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135152},
            [8] = {["isExceptional"] = 1, ["name"] = "Howling Blast", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135833},
            [16] = {["name"] = "Nerves of Cold Steel", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132147},
            [17] = {["name"] = "Improved Frost Presence", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135773},
            [13] = {["name"] = "Tundra Stalker", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136107},
            [12] = {["name"] = "Acclimation", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135791},
            [11] = {["name"] = "Merciless Combat", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135294},
            [10] = {["name"] = "Rime", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135840},
        },
        [3] = {
            [31] = {["name"] = "Desolation", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136224},
            [30] = {["name"] = "Desecration", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136199},
            [21] = {["name"] = "On a Pale Horse", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 237534},
            [22] = {["name"] = "Ebon Plaguebringer", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132095},
            [27] = {["name"] = "Anticipation", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136056},
            [26] = {["isExceptional"] = 1, ["name"] = "Scourge Strike", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 237530},
            [25] = {["isExceptional"] = 1, ["name"] = "Ghoul Frenzy", ["tier"] = 7, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 132152},
            [24] = {["name"] = "Vicious Strikes", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135774},
            [23] = {["name"] = "Necrosis", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135695},
            [28] = {["isExceptional"] = 1, ["name"] = "Anti-Magic Zone", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237510},
            [29] = {["name"] = "Night of the Dead", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 237511},
            [20] = {["name"] = "Rage of Rivendare", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135564},
            [19] = {["name"] = "Unholy Command", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 237532},
            [18] = {["name"] = "Improved Unholy Presence", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135775},
            [9] = {["isExceptional"] = 1, ["name"] = "Summon Gargoyle", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132182},
            [1] = {["name"] = "Virulence", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136126},
            [15] = {["name"] = "Outbreak", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136182},
            [3] = {["name"] = "Ravenous Dead", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 237524},
            [2] = {["name"] = "Morbidity", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136144},
            [5] = {["name"] = "Epidemic", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136207},
            [4] = {["name"] = "Crypt Fever", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136066},
            [7] = {["isExceptional"] = 1, ["name"] = "Corpse Explosion", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132099},
            [6] = {["name"] = "Master of Ghouls", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136119},
            [14] = {["isExceptional"] = 1, ["name"] = "Bone Shield", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132728},
            [8] = {["isExceptional"] = 1, ["name"] = "Unholy Blight", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136132},
            [16] = {["name"] = "Magic Suppression", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136120},
            [17] = {["name"] = "Dirge", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136194},
            [13] = {["name"] = "Impurity", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136196},
            [12] = {["name"] = "Blood-Caked Blade", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132109},
            [11] = {["name"] = "Wandering Plague", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136127},
            [10] = {["name"] = "Reaping", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136195},
        },
    },
    ["SHAMAN"] = {
        [1] = {
            [25] = {["name"] = "Booming Echoes", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135782},
            [24] = {["name"] = "Shamanism", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136234},
            [23] = {["isExceptional"] = 1, ["name"] = "Thunderstorm", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237589},
            [22] = {["name"] = "Storm, Earth and Fire", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237588},
            [21] = {["name"] = "Lava Flows", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 237583},
            [20] = {["name"] = "Astral Shift", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237572},
            [19] = {["name"] = "Elemental Oath", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 237576},
            [18] = {["isExceptional"] = 1, ["name"] = "Totem of Wrath", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135829},
            [9] = {["name"] = "Reverberation", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135850},
            [1] = {["name"] = "Call of Flame", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135817},
            [15] = {["name"] = "Unrelenting Storm", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136111},
            [3] = {["name"] = "Concussion", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135807},
            [2] = {["name"] = "Call of Thunder", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136014},
            [5] = {["name"] = "Elemental Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135830},
            [4] = {["name"] = "Convection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136116},
            [7] = {["isExceptional"] = 1, ["name"] = "Elemental Mastery", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136115},
            [6] = {["name"] = "Improved Fire Nova", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135824},
            [14] = {["name"] = "Elemental Devastation", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135791},
            [8] = {["isExceptional"] = 1, ["name"] = "Elemental Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136170},
            [16] = {["name"] = "Elemental Precision", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136028},
            [17] = {["name"] = "Lightning Overload", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136050},
            [13] = {["name"] = "Eye of the Storm", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136213},
            [12] = {["name"] = "Elemental Reach", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136099},
            [11] = {["name"] = "Elemental Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136094},
            [10] = {["name"] = "Lightning Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135990},
        },
        [2] = {
            [21] = {["name"] = "Improved Stormstrike", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 237581},
            [22] = {["name"] = "Static Shock", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237587},
            [27] = {["name"] = "Earth's Grasp", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136097},
            [26] = {["name"] = "Mental Dexterity", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136012},
            [25] = {["isExceptional"] = 1, ["name"] = "Feral Spirit", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 237577},
            [24] = {["name"] = "Maelstrom Weapon", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 237584},
            [23] = {["name"] = "Earthen Power", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136024},
            [28] = {["isExceptional"] = 1, ["name"] = "Lava Lash", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 236289},
            [29] = {["name"] = "Frozen Power", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135776},
            [20] = {["isExceptional"] = 1, ["name"] = "Shamanistic Rage", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136088},
            [19] = {["name"] = "Dual Wield Specialization", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132148},
            [18] = {["name"] = "Mental Quickness", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136055},
            [9] = {["name"] = "Ancestral Knowledge", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136162},
            [1] = {["name"] = "Anticipation", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136056},
            [15] = {["name"] = "Improved Windfury Totem", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136114},
            [3] = {["name"] = "Improved Ghost Wolf", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136095},
            [2] = {["name"] = "Flurry", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132152},
            [5] = {["name"] = "Guardian Totems", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136098},
            [4] = {["name"] = "Improved Shields", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136051},
            [7] = {["name"] = "Elemental Weapons", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135814},
            [6] = {["name"] = "Enhancing Totems", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136023},
            [14] = {["name"] = "Weapon Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132215},
            [8] = {["name"] = "Thundering Strikes", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132325},
            [16] = {["name"] = "Unleashed Rage", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136110},
            [17] = {["name"] = "Dual Wield", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132147},
            [13] = {["isExceptional"] = 1, ["name"] = "Stormstrike", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132314},
            [12] = {["isExceptional"] = 1, ["name"] = "Shamanistic Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136027},
            [11] = {["name"] = "Spirit Weapons", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132269},
            [10] = {["name"] = "Toughness", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
        },
        [3] = {
            [26] = {["isExceptional"] = 1, ["name"] = "Cleanse Spirit", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 236288},
            [25] = {["isExceptional"] = 1, ["name"] = "Riptide", ["tier"] = 11, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 252995},
            [24] = {["name"] = "Tidal Waves", ["tier"] = 10, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 237590},
            [23] = {["name"] = "Ancestral Awakening", ["tier"] = 9, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 237571},
            [22] = {["name"] = "Blessing of the Eternals", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 237573},
            [21] = {["name"] = "Improved Earth Shield", ["tier"] = 9, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136089},
            [20] = {["name"] = "Nature's Guardian", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136060},
            [19] = {["isExceptional"] = 1, ["name"] = "Earth Shield", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136089},
            [18] = {["name"] = "Improved Chain Heal", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136042},
            [9] = {["isExceptional"] = 1, ["name"] = "Nature's Swiftness", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136076},
            [1] = {["name"] = "Ancestral Healing", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136109},
            [15] = {["name"] = "Healing Way", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136044},
            [3] = {["name"] = "Improved Water Shield", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132315},
            [2] = {["isExceptional"] = 1, ["name"] = "Tidal Force", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135845},
            [5] = {["name"] = "Healing Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136043},
            [4] = {["name"] = "Improved Healing Wave", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136052},
            [7] = {["name"] = "Improved Reincarnation", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136080},
            [6] = {["name"] = "Restorative Totems", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136053},
            [14] = {["name"] = "Healing Grace", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136041},
            [8] = {["isExceptional"] = 1, ["name"] = "Mana Tide Totem", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135861},
            [16] = {["name"] = "Focused Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136035},
            [17] = {["name"] = "Nature's Blessing", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136059},
            [13] = {["name"] = "Totemic Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136057},
            [12] = {["name"] = "Tidal Mastery", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136107},
            [11] = {["name"] = "Tidal Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135859},
            [10] = {["name"] = "Purification", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135865},
        },
    },
}
elseif (isTBC) then
lib.talents_table = lib.talents_table or {
    ["HUNTER"] = {
        [1] = {
            [21] = {["name"] = "The Beast Within", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132166},
            [20] = {["name"] = "Serpent's Swiftness", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132209},
            [19] = {["name"] = "Catlike Reflexes", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132167},
            [18] = {["isExceptional"] = 1, ["name"] = "Bestial Wrath", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132127},
            [9] = {["name"] = "Unleashed Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132091},
            [1] = {["name"] = "Improved Aspect of the Hawk", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136076},
            [15] = {["name"] = "Animal Handler", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132158},
            [3] = {["name"] = "Focused Fire", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132210},
            [2] = {["name"] = "Endurance Training", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136080},
            [5] = {["name"] = "Thick Hide", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134355},
            [4] = {["name"] = "Improved Aspect of the Monkey", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132159},
            [7] = {["name"] = "Pathfinding", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132242},
            [6] = {["name"] = "Improved Revive Pet", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132163},
            [14] = {["name"] = "Bestial Discipline", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136006},
            [8] = {["name"] = "Bestial Swiftness", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132120},
            [16] = {["name"] = "Frenzy", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134296},
            [17] = {["name"] = "Ferocious Inspiration", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132173},
            [13] = {["isExceptional"] = 1, ["name"] = "Intimidation", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132111},
            [12] = {["name"] = "Spirit Bond", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132121},
            [11] = {["name"] = "Ferocity", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134297},
            [10] = {["name"] = "Improved Mend Pet", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132179},
        },
        [2] = {
            [20] = {["isExceptional"] = 1, ["name"] = "Silencing Shot", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132323},
            [19] = {["name"] = "Master Marksman", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132177},
            [18] = {["name"] = "Improved Barrage", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132330},
            [9] = {["name"] = "Improved Stings", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132204},
            [1] = {["name"] = "Improved Concussive Shot", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135860},
            [15] = {["name"] = "Ranged Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135615},
            [3] = {["name"] = "Improved Hunter's Mark", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132212},
            [2] = {["name"] = "Lethal Shots", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132312},
            [5] = {["name"] = "Go for the Throat", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132174},
            [4] = {["name"] = "Efficiency", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135865},
            [7] = {["isExceptional"] = 1, ["name"] = "Aimed Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135130},
            [6] = {["name"] = "Improved Arcane Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132218},
            [14] = {["name"] = "Combat Experience", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132168},
            [8] = {["name"] = "Rapid Killing", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132205},
            [16] = {["name"] = "Careful Aim", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132217},
            [17] = {["isExceptional"] = 1, ["name"] = "Trueshot Aura", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132329},
            [13] = {["name"] = "Barrage", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132330},
            [12] = {["isExceptional"] = 1, ["name"] = "Scatter Shot", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132153},
            [11] = {["name"] = "Concussive Barrage", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135753},
            [10] = {["name"] = "Mortal Shots", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132271},
        },
        [3] = {
            [23] = {["isExceptional"] = 1, ["name"] = "Readiness", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132206},
            [22] = {["name"] = "Master Tactician", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132178},
            [21] = {["name"] = "Expose Weakness", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132295},
            [20] = {["isExceptional"] = 1, ["name"] = "Wyvern Sting", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135125},
            [19] = {["name"] = "Thrill of the Hunt", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132216},
            [18] = {["name"] = "Lightning Reflexes", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136047},
            [9] = {["name"] = "Survivalist", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136223},
            [1] = {["name"] = "Monster Slaying", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 134154},
            [15] = {["name"] = "Killer Instinct", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135881},
            [3] = {["name"] = "Hawk Eye", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132327},
            [2] = {["name"] = "Humanoid Slaying", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135942},
            [5] = {["name"] = "Entrapment", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136100},
            [4] = {["name"] = "Savage Strikes", ["tier"] = 1, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132277},
            [7] = {["name"] = "Improved Wing Clip", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132309},
            [6] = {["name"] = "Deflection", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [14] = {["name"] = "Survival Instincts", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132214},
            [8] = {["name"] = "Clever Traps", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136106},
            [16] = {["isExceptional"] = 1, ["name"] = "Counterattack", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132336},
            [17] = {["name"] = "Resourcefulness", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132207},
            [13] = {["name"] = "Improved Feign Death", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132293},
            [12] = {["name"] = "Surefooted", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132219},
            [11] = {["name"] = "Trap Mastery", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132149},
            [10] = {["isExceptional"] = 1, ["name"] = "Deterrence", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132369},
        },
    },
    ["WARRIOR"] = {
        [1] = {
            [23] = {["isExceptional"] = 1, ["name"] = "Endless Rage", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132344},
            [22] = {["name"] = "Improved Mortal Strike", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132355},
            [21] = {["name"] = "Second Wind", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132175},
            [20] = {["isExceptional"] = 1, ["name"] = "Mortal Strike", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132355},
            [19] = {["name"] = "Blood Frenzy", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132334},
            [18] = {["name"] = "Improved Disciplines", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132346},
            [9] = {["name"] = "Deep Wounds", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132090},
            [1] = {["name"] = "Improved Heroic Strike", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132282},
            [15] = {["name"] = "Sword Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135328},
            [3] = {["name"] = "Improved Rend", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132155},
            [2] = {["name"] = "Deflection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [5] = {["name"] = "Iron Will", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135995},
            [4] = {["name"] = "Improved Charge", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132337},
            [7] = {["name"] = "Improved Overpower", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135275},
            [6] = {["name"] = "Improved Thunder Clap", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132326},
            [14] = {["name"] = "Mace Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 133476},
            [8] = {["isExceptional"] = 1, ["name"] = "Anger Management", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135881},
            [16] = {["name"] = "Improved Intercept", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132307},
            [17] = {["name"] = "Improved Hamstring", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132316},
            [13] = {["isExceptional"] = 1, ["name"] = "Death Wish", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136146},
            [12] = {["name"] = "Poleaxe Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132397},
            [11] = {["name"] = "Impale", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132312},
            [10] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132400},
        },
        [2] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Rampage", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132352},
            [20] = {["name"] = "Improved Berserker Stance", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132275},
            [19] = {["name"] = "Improved Whirlwind", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132369},
            [18] = {["isExceptional"] = 1, ["name"] = "Bloodthirst", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136012},
            [9] = {["name"] = "Dual Wield Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132147},
            [1] = {["name"] = "Booming Voice", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136075},
            [15] = {["name"] = "Improved Berserker Rage", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136009},
            [3] = {["name"] = "Improved Demoralizing Shout", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132366},
            [2] = {["name"] = "Cruelty", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132292},
            [5] = {["name"] = "Improved Cleave", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132338},
            [4] = {["name"] = "Unbridled Wrath", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136097},
            [7] = {["name"] = "Blood Craze", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136218},
            [6] = {["isExceptional"] = 1, ["name"] = "Piercing Howl", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136147},
            [14] = {["name"] = "Weapon Mastery", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132367},
            [8] = {["name"] = "Commanding Presence", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136035},
            [16] = {["name"] = "Flurry", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132152},
            [17] = {["name"] = "Precision", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132222},
            [13] = {["isExceptional"] = 1, ["name"] = "Sweeping Strikes", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132306},
            [12] = {["name"] = "Improved Slam", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132340},
            [11] = {["name"] = "Enrage", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136224},
            [10] = {["name"] = "Improved Execute", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135358},
        },
        [3] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Devastate", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135291},
            [21] = {["name"] = "Vitality", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 133123},
            [20] = {["name"] = "Focused Rage", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132345},
            [19] = {["isExceptional"] = 1, ["name"] = "Shield Slam", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134951},
            [18] = {["name"] = "Improved Defensive Stance", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132341},
            [9] = {["name"] = "Defiance", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132347},
            [1] = {["name"] = "Improved Bloodrage", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132277},
            [15] = {["name"] = "Improved Shield Bash", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132357},
            [3] = {["name"] = "Anticipation", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136056},
            [2] = {["name"] = "Tactical Mastery", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136031},
            [5] = {["name"] = "Toughness", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
            [4] = {["name"] = "Shield Specialization", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 134952},
            [7] = {["name"] = "Improved Shield Block", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132110},
            [6] = {["isExceptional"] = 1, ["name"] = "Last Stand", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135871},
            [14] = {["isExceptional"] = 1, ["name"] = "Concussion Blow", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132325},
            [8] = {["name"] = "Improved Revenge", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132353},
            [16] = {["name"] = "Shield Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132360},
            [17] = {["name"] = "One-Handed Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135321},
            [13] = {["name"] = "Improved Shield Wall", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132362},
            [12] = {["name"] = "Improved Taunt", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136080},
            [11] = {["name"] = "Improved Disarm", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132343},
            [10] = {["name"] = "Improved Sunder Armor", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132363},
        },
    },
    ["PALADIN"] = {
        [1] = {
            [20] = {["isExceptional"] = 1, ["name"] = "Divine Illumination", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135895},
            [19] = {["name"] = "Holy Guidance", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135921},
            [18] = {["name"] = "Blessed Life", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135876},
            [9] = {["name"] = "Illumination", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135913},
            [1] = {["name"] = "Divine Strength", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132154},
            [15] = {["name"] = "Holy Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135938},
            [3] = {["name"] = "Spiritual Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135736},
            [2] = {["name"] = "Divine Intellect", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136090},
            [5] = {["name"] = "Healing Light", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135920},
            [4] = {["name"] = "Improved Seal of Righteousness", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132325},
            [7] = {["name"] = "Improved Lay on Hands", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135928},
            [6] = {["isExceptional"] = 1, ["name"] = "Aura Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135872},
            [14] = {["name"] = "Purifying Power", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135950},
            [8] = {["name"] = "Unyielding Faith", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135984},
            [16] = {["name"] = "Light's Grace", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135931},
            [17] = {["isExceptional"] = 1, ["name"] = "Holy Shock", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135972},
            [13] = {["name"] = "Sanctified Light", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135917},
            [12] = {["isExceptional"] = 1, ["name"] = "Divine Favor", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135915},
            [11] = {["name"] = "Pure of Heart", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135948},
            [10] = {["name"] = "Improved Blessing of Wisdom", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135970},
        },
        [2] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Avenger's Shield", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135874},
            [21] = {["name"] = "Combat Expertise", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135986},
            [20] = {["name"] = "Ardent Defender", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135870},
            [19] = {["isExceptional"] = 1, ["name"] = "Holy Shield", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135880},
            [18] = {["name"] = "Improved Holy Shield", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135880},
            [9] = {["name"] = "Anticipation", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135994},
            [1] = {["name"] = "Improved Devotion Aura", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135893},
            [15] = {["name"] = "Reckoning", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135882},
            [3] = {["name"] = "Precision", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132282},
            [2] = {["name"] = "Redoubt", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132110},
            [5] = {["name"] = "Toughness", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135892},
            [4] = {["name"] = "Guardian's Favor", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135964},
            [7] = {["name"] = "Improved Righteous Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135962},
            [6] = {["isExceptional"] = 1, ["name"] = "Blessing of Kings", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135995},
            [14] = {["isExceptional"] = 1, ["name"] = "Blessing of Sanctuary", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136051},
            [8] = {["name"] = "Shield Specialization", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134952},
            [16] = {["name"] = "Sacred Duty", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135896},
            [17] = {["name"] = "One-Handed Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135321},
            [13] = {["name"] = "Spell Warding", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135925},
            [12] = {["name"] = "Improved Concentration Aura", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135933},
            [11] = {["name"] = "Improved Hammer of Justice", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135963},
            [10] = {["name"] = "Stoicism", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135978},
        },
        [3] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Crusader Strike", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135891},
            [21] = {["name"] = "Fanaticism", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135905},
            [20] = {["name"] = "Divine Purpose", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135897},
            [19] = {["isExceptional"] = 1, ["name"] = "Repentance", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135942},
            [18] = {["name"] = "Sanctified Seals", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135924},
            [9] = {["name"] = "Pursuit of Justice", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135937},
            [1] = {["name"] = "Improved Blessing of Might", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135906},
            [15] = {["name"] = "Improved Sanctity Aura", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135934},
            [3] = {["name"] = "Improved Judgement", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135959},
            [2] = {["name"] = "Benediction", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135863},
            [5] = {["name"] = "Deflection", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132269},
            [4] = {["name"] = "Improved Seal of the Crusader", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135924},
            [7] = {["name"] = "Conviction", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135957},
            [6] = {["name"] = "Vindication", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135985},
            [14] = {["isExceptional"] = 1, ["name"] = "Sanctity Aura", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135934},
            [8] = {["isExceptional"] = 1, ["name"] = "Seal of Command", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132347},
            [16] = {["name"] = "Vengeance", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132275},
            [17] = {["name"] = "Sanctified Judgement", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135959},
            [13] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 133041},
            [12] = {["name"] = "Crusade", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135889},
            [11] = {["name"] = "Improved Retribution Aura", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135873},
            [10] = {["name"] = "Eye for an Eye", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135904},
        },
    },
    ["MAGE"] = {
        [1] = {
            [23] = {["isExceptional"] = 1, ["name"] = "Slow", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136091},
            [22] = {["name"] = "Mind Mastery", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135740},
            [21] = {["name"] = "Spell Power", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135734},
            [20] = {["isExceptional"] = 1, ["name"] = "Arcane Power", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136048},
            [19] = {["name"] = "Empowered Arcane Missiles", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136096},
            [18] = {["name"] = "Arcane Potency", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135732},
            [9] = {["isExceptional"] = 1, ["name"] = "Arcane Fortitude", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 135733},
            [1] = {["name"] = "Arcane Subtlety", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135894},
            [15] = {["name"] = "Arcane Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136129},
            [3] = {["name"] = "Improved Arcane Missiles", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136096},
            [2] = {["name"] = "Arcane Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135892},
            [5] = {["name"] = "Magic Absorption", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136011},
            [4] = {["name"] = "Wand Specialization", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135463},
            [7] = {["name"] = "Magic Attunement", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136006},
            [6] = {["name"] = "Arcane Concentration", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136170},
            [14] = {["isExceptional"] = 1, ["name"] = "Presence of Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136031},
            [8] = {["name"] = "Arcane Impact", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136116},
            [16] = {["name"] = "Prismatic Cloak", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135752},
            [17] = {["name"] = "Arcane Instability", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136222},
            [13] = {["name"] = "Improved Blink", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135736},
            [12] = {["name"] = "Arcane Meditation", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136208},
            [11] = {["name"] = "Improved Counterspell", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135856},
            [10] = {["name"] = "Improved Mana Shield", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136153},
        },
        [2] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Dragon's Breath", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134153},
            [21] = {["name"] = "Empowered Fireball", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135812},
            [20] = {["name"] = "Molten Fury", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135822},
            [19] = {["isExceptional"] = 1, ["name"] = "Combustion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135824},
            [18] = {["name"] = "Pyromaniac", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135789},
            [9] = {["name"] = "Burning Soul", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135805},
            [1] = {["name"] = "Improved Fireball", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135812},
            [15] = {["isExceptional"] = 1, ["name"] = "Blast Wave", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135903},
            [3] = {["name"] = "Ignite", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135818},
            [2] = {["name"] = "Impact", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135821},
            [5] = {["name"] = "Improved Fire Blast", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135807},
            [4] = {["name"] = "Flame Throwing", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135815},
            [7] = {["name"] = "Improved Flamestrike", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135826},
            [6] = {["name"] = "Incineration", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135813},
            [14] = {["name"] = "Critical Mass", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136115},
            [8] = {["isExceptional"] = 1, ["name"] = "Pyroblast", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135808},
            [16] = {["name"] = "Blazing Speed", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135788},
            [17] = {["name"] = "Fire Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135817},
            [13] = {["name"] = "Playing with Fire", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135823},
            [12] = {["name"] = "Master of Elements", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135820},
            [11] = {["name"] = "Molten Shields", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135806},
            [10] = {["name"] = "Improved Scorch", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135827},
        },
        [3] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Summon Water Elemental", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135862},
            [21] = {["name"] = "Empowered Frostbolt", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135846},
            [20] = {["name"] = "Arctic Winds", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135833},
            [19] = {["isExceptional"] = 1, ["name"] = "Ice Barrier", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135988},
            [18] = {["name"] = "Winter's Chill", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135836},
            [9] = {["isExceptional"] = 1, ["name"] = "Icy Veins", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135838},
            [1] = {["name"] = "Frost Warding", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135850},
            [15] = {["isExceptional"] = 1, ["name"] = "Cold Snap", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135865},
            [3] = {["name"] = "Elemental Precision", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135989},
            [2] = {["name"] = "Improved Frostbolt", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135846},
            [5] = {["name"] = "Frostbite", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135842},
            [4] = {["name"] = "Ice Shards", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135855},
            [7] = {["name"] = "Permafrost", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135864},
            [6] = {["name"] = "Improved Frost Nova", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135840},
            [14] = {["name"] = "Frozen Core", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135851},
            [8] = {["name"] = "Piercing Ice", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135845},
            [16] = {["name"] = "Improved Cone of Cold", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135852},
            [17] = {["name"] = "Ice Floes", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135854},
            [13] = {["name"] = "Shatter", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135849},
            [12] = {["name"] = "Frost Channeling", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135860},
            [11] = {["name"] = "Arctic Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136141},
            [10] = {["name"] = "Improved Blizzard", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135857},
        },
    },
    ["PRIEST"] = {
        [1] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Pain Suppression", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135936},
            [21] = {["name"] = "Enlightenment", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135740},
            [20] = {["name"] = "Reflective Shield", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135940},
            [19] = {["isExceptional"] = 1, ["name"] = "Power Infusion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135939},
            [18] = {["name"] = "Focused Will", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135737},
            [9] = {["name"] = "Meditation", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136090},
            [1] = {["name"] = "Unbreakable Will", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135995},
            [15] = {["name"] = "Improved Divine Spirit", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135898},
            [3] = {["name"] = "Silent Resolve", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136053},
            [2] = {["name"] = "Wand Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135463},
            [5] = {["name"] = "Improved Power Word: Shield", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135940},
            [4] = {["name"] = "Improved Power Word: Fortitude", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135987},
            [7] = {["name"] = "Absolution", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135868},
            [6] = {["name"] = "Martyrdom", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136107},
            [14] = {["isExceptional"] = 1, ["name"] = "Divine Spirit", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135898},
            [8] = {["isExceptional"] = 1, ["name"] = "Inner Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135863},
            [16] = {["name"] = "Focused Power", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136158},
            [17] = {["name"] = "Force of Will", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136092},
            [13] = {["name"] = "Mental Strength", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136031},
            [12] = {["name"] = "Improved Mana Burn", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136170},
            [11] = {["name"] = "Mental Agility", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132156},
            [10] = {["name"] = "Improved Inner Fire", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135926},
        },
        [2] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Circle of Healing", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135887},
            [20] = {["name"] = "Empowered Healing", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135913},
            [19] = {["name"] = "Blessed Resilience", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135878},
            [18] = {["isExceptional"] = 1, ["name"] = "Lightwell", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135980},
            [9] = {["name"] = "Holy Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135949},
            [1] = {["name"] = "Healing Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135918},
            [15] = {["name"] = "Surge of Light", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135981},
            [3] = {["name"] = "Holy Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135967},
            [2] = {["name"] = "Improved Renew", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135953},
            [5] = {["name"] = "Divine Fury", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135971},
            [4] = {["name"] = "Spell Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135976},
            [7] = {["name"] = "Blessed Recovery", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135877},
            [6] = {["isExceptional"] = 1, ["name"] = "Holy Nova", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135922},
            [14] = {["name"] = "Spiritual Guidance", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135977},
            [8] = {["name"] = "Inspiration", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135928},
            [16] = {["name"] = "Spiritual Healing", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136057},
            [17] = {["name"] = "Holy Concentration", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135905},
            [13] = {["isExceptional"] = 1, ["name"] = "Spirit of Redemption", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132864},
            [12] = {["name"] = "Healing Prayers", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135943},
            [11] = {["name"] = "Searing Light", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135973},
            [10] = {["name"] = "Improved Healing", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135916},
        },
        [3] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Vampiric Touch", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135978},
            [20] = {["name"] = "Misery", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136176},
            [19] = {["name"] = "Shadow Power", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136204},
            [18] = {["isExceptional"] = 1, ["name"] = "Shadowform", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136200},
            [9] = {["name"] = "Improved Fade", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135994},
            [1] = {["name"] = "Spirit Tap", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136188},
            [15] = {["name"] = "Focused Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136035},
            [3] = {["name"] = "Shadow Affinity", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136205},
            [2] = {["name"] = "Blackout", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136160},
            [5] = {["name"] = "Shadow Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136126},
            [4] = {["name"] = "Improved Shadow Word: Pain", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136207},
            [7] = {["name"] = "Improved Mind Blast", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136224},
            [6] = {["name"] = "Improved Psychic Scream", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136184},
            [14] = {["name"] = "Improved Vampiric Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136165},
            [8] = {["isExceptional"] = 1, ["name"] = "Mind Flay", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136208},
            [16] = {["name"] = "Shadow Resilience", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136162},
            [17] = {["name"] = "Darkness", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136223},
            [13] = {["isExceptional"] = 1, ["name"] = "Vampiric Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136230},
            [12] = {["isExceptional"] = 1, ["name"] = "Silence", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136164},
            [11] = {["name"] = "Shadow Weaving", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136123},
            [10] = {["name"] = "Shadow Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136130},
        },
    },
    ["WARLOCK"] = {
        [1] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Unstable Affliction", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136228},
            [20] = {["name"] = "Malediction", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136137},
            [19] = {["name"] = "Improved Howl of Terror", ["tier"] = 8, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136147},
            [18] = {["isExceptional"] = 1, ["name"] = "Dark Pact", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136141},
            [9] = {["isExceptional"] = 1, ["name"] = "Amplify Curse", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136132},
            [1] = {["name"] = "Suppression", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136230},
            [15] = {["isExceptional"] = 1, ["name"] = "Curse of Exhaustion", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136162},
            [3] = {["name"] = "Improved Curse of Weakness", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136138},
            [2] = {["name"] = "Improved Corruption", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136118},
            [5] = {["name"] = "Improved Life Tap", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136126},
            [4] = {["name"] = "Improved Drain Soul", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136163},
            [7] = {["name"] = "Improved Curse of Agony", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136139},
            [6] = {["name"] = "Soul Siphon", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136169},
            [14] = {["isExceptional"] = 1, ["name"] = "Siphon Life", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136188},
            [8] = {["name"] = "Fel Concentration", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136157},
            [16] = {["name"] = "Shadow Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136195},
            [17] = {["name"] = "Contagion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136180},
            [13] = {["name"] = "Shadow Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136198},
            [12] = {["name"] = "Empowered Corruption", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136118},
            [11] = {["name"] = "Nightfall", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136223},
            [10] = {["name"] = "Grim Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136127},
        },
        [2] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Summon Felguard", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136216},
            [21] = {["name"] = "Demonic Tactics", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136150},
            [20] = {["name"] = "Demonic Knowledge", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136165},
            [19] = {["isExceptional"] = 1, ["name"] = "Soul Link", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136160},
            [18] = {["name"] = "Demonic Resilience", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136149},
            [9] = {["name"] = "Fel Stamina", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136121},
            [1] = {["name"] = "Improved Healthstone", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135230},
            [15] = {["name"] = "Master Conjuror", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132386},
            [3] = {["name"] = "Demonic Embrace", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136172},
            [2] = {["name"] = "Improved Imp", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136218},
            [5] = {["name"] = "Improved Voidwalker", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136221},
            [4] = {["name"] = "Improved Health Funnel", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136168},
            [7] = {["name"] = "Improved Sayaad", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 4352493},
            [6] = {["name"] = "Fel Intellect", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135932},
            [14] = {["isExceptional"] = 1, ["name"] = "Demonic Sacrifice", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136184},
            [8] = {["isExceptional"] = 1, ["name"] = "Fel Domination", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136082},
            [16] = {["name"] = "Mana Feed", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136171},
            [17] = {["name"] = "Master Demonologist", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136203},
            [13] = {["name"] = "Improved Enslave Demon", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136154},
            [12] = {["name"] = "Unholy Power", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136206},
            [11] = {["name"] = "Master Summoner", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136164},
            [10] = {["name"] = "Demonic Aegis", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136185},
        },
        [3] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Shadowfury", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136201},
            [20] = {["name"] = "Shadow and Flame", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136196},
            [19] = {["name"] = "Soul Leech", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136214},
            [18] = {["isExceptional"] = 1, ["name"] = "Conflagrate", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135807},
            [9] = {["name"] = "Intensity", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135819},
            [1] = {["name"] = "Improved Shadow Bolt", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136197},
            [15] = {["name"] = "Nether Protection", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136178},
            [3] = {["name"] = "Bane", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136146},
            [2] = {["name"] = "Cataclysm", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135831},
            [5] = {["name"] = "Improved Firebolt", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135809},
            [4] = {["name"] = "Aftermath", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135805},
            [7] = {["name"] = "Devastation", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135813},
            [6] = {["name"] = "Improved Lash of Pain", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136136},
            [14] = {["name"] = "Ruin", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136207},
            [8] = {["isExceptional"] = 1, ["name"] = "Shadowburn", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136191},
            [16] = {["name"] = "Emberstorm", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135826},
            [17] = {["name"] = "Backlash", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135823},
            [13] = {["name"] = "Improved Immolate", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135817},
            [12] = {["name"] = "Pyroclasm", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135830},
            [11] = {["name"] = "Improved Searing Pain", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135827},
            [10] = {["name"] = "Destructive Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136133},
        },
    },
    ["SHAMAN"] = {
        [1] = {
            [20] = {["isExceptional"] = 1, ["name"] = "Totem of Wrath", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135829},
            [19] = {["name"] = "Lightning Overload", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136050},
            [18] = {["name"] = "Elemental Shields", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136030},
            [9] = {["name"] = "Improved Fire Totems", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135824},
            [1] = {["name"] = "Convection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136116},
            [15] = {["name"] = "Elemental Precision", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136028},
            [3] = {["name"] = "Earth's Grasp", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136097},
            [2] = {["name"] = "Concussion", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135807},
            [5] = {["name"] = "Call of Flame", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135817},
            [4] = {["name"] = "Elemental Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136094},
            [7] = {["name"] = "Reverberation", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135850},
            [6] = {["isExceptional"] = 1, ["name"] = "Elemental Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136170},
            [14] = {["name"] = "Unrelenting Storm", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136111},
            [8] = {["name"] = "Call of Thunder", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136014},
            [16] = {["name"] = "Lightning Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135990},
            [17] = {["isExceptional"] = 1, ["name"] = "Elemental Mastery", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136115},
            [13] = {["name"] = "Elemental Fury", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135830},
            [12] = {["name"] = "Storm Reach", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136099},
            [11] = {["name"] = "Elemental Devastation", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135791},
            [10] = {["name"] = "Eye of the Storm", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136213},
        },
        [2] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Shamanistic Rage", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136088},
            [20] = {["name"] = "Unleashed Rage", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136110},
            [19] = {["isExceptional"] = 1, ["name"] = "Stormstrike", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132314},
            [18] = {["name"] = "Dual Wield", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132147},
            [9] = {["name"] = "Anticipation", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136056},
            [1] = {["name"] = "Ancestral Knowledge", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136162},
            [15] = {["name"] = "Mental Quickness", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136055},
            [3] = {["name"] = "Guardian Totems", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136098},
            [2] = {["name"] = "Shield Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134952},
            [5] = {["name"] = "Improved Ghost Wolf", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136095},
            [4] = {["name"] = "Thundering Strikes", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132325},
            [7] = {["name"] = "Enhancing Totems", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136023},
            [6] = {["name"] = "Improved Lightning Shield", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136051},
            [14] = {["name"] = "Elemental Weapons", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135814},
            [8] = {["name"] = "Shamanistic Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136027},
            [16] = {["name"] = "Weapon Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132215},
            [17] = {["name"] = "Dual Wield Specialization", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132148},
            [13] = {["name"] = "Spirit Weapons", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132269},
            [12] = {["name"] = "Improved Weapon Totems", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135792},
            [11] = {["name"] = "Toughness", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
            [10] = {["name"] = "Flurry", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132152},
        },
        [3] = {
            [20] = {["isExceptional"] = 1, ["name"] = "Earth Shield", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136089},
            [19] = {["name"] = "Improved Chain Heal", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136042},
            [18] = {["name"] = "Nature's Blessing", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136059},
            [9] = {["name"] = "Healing Grace", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136041},
            [1] = {["name"] = "Improved Healing Wave", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136052},
            [15] = {["name"] = "Purification", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135865},
            [3] = {["name"] = "Improved Reincarnation", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136080},
            [2] = {["name"] = "Tidal Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135859},
            [5] = {["name"] = "Totemic Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136057},
            [4] = {["name"] = "Ancestral Healing", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136109},
            [7] = {["name"] = "Healing Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136043},
            [6] = {["name"] = "Nature's Guidance", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135860},
            [14] = {["name"] = "Focused Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136035},
            [8] = {["name"] = "Totemic Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136069},
            [16] = {["isExceptional"] = 1, ["name"] = "Mana Tide Totem", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135861},
            [17] = {["name"] = "Nature's Guardian", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136060},
            [13] = {["isExceptional"] = 1, ["name"] = "Nature's Swiftness", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136076},
            [12] = {["name"] = "Healing Way", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136044},
            [11] = {["name"] = "Tidal Mastery", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136107},
            [10] = {["name"] = "Restorative Totems", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136053},
        },
    },
    ["DRUID"] = {
        [1] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Force of Nature", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132129},
            [20] = {["name"] = "Wrath of Cenarius", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132146},
            [19] = {["name"] = "Improved Faerie Fire", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136033},
            [18] = {["isExceptional"] = 1, ["name"] = "Moonkin Form", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136036},
            [9] = {["name"] = "Nature's Reach", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136065},
            [1] = {["name"] = "Starlight Wrath", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136006},
            [15] = {["name"] = "Moonfury", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136057},
            [3] = {["name"] = "Improved Nature's Grasp", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 4, ["texture"] = 136063},
            [2] = {["isExceptional"] = 1, ["name"] = "Nature's Grasp", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136063},
            [5] = {["name"] = "Focused Starlight", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135138},
            [4] = {["name"] = "Control of Nature", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136100},
            [7] = {["name"] = "Brambles", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136104},
            [6] = {["name"] = "Improved Moonfire", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136096},
            [14] = {["name"] = "Moonglow", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136087},
            [8] = {["isExceptional"] = 1, ["name"] = "Insect Swarm", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136045},
            [16] = {["name"] = "Balance of Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132113},
            [17] = {["name"] = "Dreamstate", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132123},
            [13] = {["name"] = "Nature's Grace", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136062},
            [12] = {["name"] = "Lunar Guidance", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132132},
            [11] = {["name"] = "Celestial Focus", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135753},
            [10] = {["name"] = "Vengeance", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136075},
        },
        [2] = {
            [21] = {["name"] = "Mangle", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132135},
            [20] = {["name"] = "Predatory Instincts", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132138},
            [19] = {["name"] = "Improved Leader of the Pack", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136112},
            [18] = {["isExceptional"] = 1, ["name"] = "Leader of the Pack", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136112},
            [9] = {["name"] = "Shredding Attacks", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136231},
            [1] = {["name"] = "Ferocity", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132190},
            [15] = {["name"] = "Heart of the Wild", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135879},
            [3] = {["name"] = "Feral Instinct", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132089},
            [2] = {["name"] = "Feral Aggression", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132121},
            [5] = {["name"] = "Thick Hide", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134355},
            [4] = {["name"] = "Brutal Impact", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132114},
            [7] = {["isExceptional"] = 1, ["name"] = "Feral Charge", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132183},
            [6] = {["name"] = "Feral Swiftness", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136095},
            [14] = {["name"] = "Nurturing Instinct", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132130},
            [8] = {["name"] = "Sharpened Claws", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134297},
            [16] = {["name"] = "Survival of the Fittest", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132126},
            [17] = {["name"] = "Primal Tenacity", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132139},
            [13] = {["isExceptional"] = 1, ["name"] = "Faerie Fire (Feral)", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136033},
            [12] = {["name"] = "Savage Fury", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132141},
            [11] = {["name"] = "Primal Fury", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132278},
            [10] = {["name"] = "Predatory Strikes", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132185},
        },
        [3] = {
            [20] = {["isExceptional"] = 1, ["name"] = "Tree of Life", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132145},
            [19] = {["name"] = "Empowered Rejuvenation", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132124},
            [18] = {["name"] = "Natural Perfection", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132137},
            [9] = {["name"] = "Tranquil Spirit", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135900},
            [1] = {["name"] = "Improved Mark of the Wild", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136078},
            [15] = {["name"] = "Improved Regrowth", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136085},
            [3] = {["name"] = "Naturalist", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136041},
            [2] = {["name"] = "Furor", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135881},
            [5] = {["name"] = "Natural Shapeshifter", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136116},
            [4] = {["name"] = "Nature's Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136042},
            [7] = {["name"] = "Subtlety", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132150},
            [6] = {["name"] = "Intensity", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135863},
            [14] = {["name"] = "Empowered Touch", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132125},
            [8] = {["isExceptional"] = 1, ["name"] = "Omen of Clarity", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136017},
            [16] = {["name"] = "Living Spirit", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136037},
            [17] = {["isExceptional"] = 1, ["name"] = "Swiftmend", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134914},
            [13] = {["name"] = "Improved Tranquility", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136107},
            [12] = {["name"] = "Gift of Nature", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136074},
            [11] = {["isExceptional"] = 1, ["name"] = "Nature's Swiftness", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136076},
            [10] = {["name"] = "Improved Rejuvenation", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136081},
        },
    },
    ["ROGUE"] = {
        [1] = {
            [21] = {["isExceptional"] = 1, ["name"] = "Mutilate", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132304},
            [20] = {["name"] = "Find Weakness", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132295},
            [19] = {["name"] = "Deadened Nerves", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132286},
            [18] = {["name"] = "Vigor", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136023},
            [9] = {["name"] = "Lethality", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132109},
            [1] = {["name"] = "Improved Eviscerate", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132292},
            [15] = {["name"] = "Quick Recovery", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132301},
            [3] = {["name"] = "Malice", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132277},
            [2] = {["name"] = "Remorseless Attacks", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132151},
            [5] = {["name"] = "Murder", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136147},
            [4] = {["name"] = "Ruthlessness", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132122},
            [7] = {["isExceptional"] = 1, ["name"] = "Relentless Strikes", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 132340},
            [6] = {["name"] = "Puncturing Wounds", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132090},
            [14] = {["name"] = "Improved Kidney Shot", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132298},
            [8] = {["name"] = "Improved Expose Armor", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132354},
            [16] = {["name"] = "Seal Fate", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136130},
            [17] = {["name"] = "Master Poisoner", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132108},
            [13] = {["isExceptional"] = 1, ["name"] = "Cold Blood", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135988},
            [12] = {["name"] = "Fleet Footed", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132296},
            [11] = {["name"] = "Improved Poisons", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132273},
            [10] = {["name"] = "Vile Poisons", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132293},
        },
        [2] = {
            [24] = {["isExceptional"] = 1, ["name"] = "Surprise Attacks", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132308},
            [23] = {["name"] = "Combat Potency", ["tier"] = 8, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135673},
            [22] = {["name"] = "Nerves of Steel", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132300},
            [21] = {["isExceptional"] = 1, ["name"] = "Adrenaline Rush", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136206},
            [20] = {["name"] = "Vitality", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132353},
            [19] = {["name"] = "Aggression", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132275},
            [18] = {["name"] = "Weapon Expertise", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135882},
            [9] = {["name"] = "Improved Sprint", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132307},
            [1] = {["name"] = "Improved Gouge", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132155},
            [15] = {["name"] = "Sword Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135328},
            [3] = {["name"] = "Lightning Reflexes", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136047},
            [2] = {["name"] = "Improved Sinister Strike", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136189},
            [5] = {["name"] = "Deflection", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [4] = {["name"] = "Improved Slice and Dice", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132306},
            [7] = {["name"] = "Endurance", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136205},
            [6] = {["name"] = "Precision", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132222},
            [14] = {["isExceptional"] = 1, ["name"] = "Blade Flurry", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132350},
            [8] = {["isExceptional"] = 1, ["name"] = "Riposte", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132336},
            [16] = {["name"] = "Fist Weapon Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132938},
            [17] = {["name"] = "Blade Twisting", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132283},
            [13] = {["name"] = "Mace Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 133476},
            [12] = {["name"] = "Dual Wield Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132147},
            [11] = {["name"] = "Dagger Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135641},
            [10] = {["name"] = "Improved Kick", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132219},
        },
        [3] = {
            [22] = {["isExceptional"] = 1, ["name"] = "Shadowstep", ["tier"] = 9, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132303},
            [21] = {["name"] = "Sinister Calling", ["tier"] = 8, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132305},
            [20] = {["name"] = "Cheat Death", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132285},
            [19] = {["isExceptional"] = 1, ["name"] = "Premeditation", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136183},
            [18] = {["name"] = "Enveloping Shadows", ["tier"] = 7, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132291},
            [9] = {["name"] = "Setup", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136056},
            [1] = {["name"] = "Master of Deception", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136129},
            [15] = {["isExceptional"] = 1, ["name"] = "Hemorrhage", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136168},
            [3] = {["name"] = "Sleight of Hand", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132294},
            [2] = {["name"] = "Opportunity", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132366},
            [5] = {["name"] = "Camouflage", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132320},
            [4] = {["name"] = "Dirty Tricks", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132310},
            [7] = {["isExceptional"] = 1, ["name"] = "Ghostly Strike", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136136},
            [6] = {["name"] = "Initiative", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136159},
            [14] = {["name"] = "Dirty Deeds", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136220},
            [8] = {["name"] = "Improved Ambush", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132282},
            [16] = {["name"] = "Master of Subtlety", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132299},
            [17] = {["name"] = "Deadliness", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135540},
            [13] = {["isExceptional"] = 1, ["name"] = "Preparation", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136121},
            [12] = {["name"] = "Heightened Senses", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132089},
            [11] = {["name"] = "Serrated Blades", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135315},
            [10] = {["name"] = "Elusiveness", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135994},
        },
    },
    ["DEATHKNIGHT"] = {
        [1] = {},
        [2] = {},
        [3] = {},
    },
}
elseif (isClassic) then
lib.talents_table = lib.talents_table or {
    ["HUNTER"] = {
        [1] = {
            [1] = {["name"] = "Improved Aspect of the Hawk", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136076},
            [15] = {["name"] = "Frenzy", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134296},
            [3] = {["name"] = "Improved Eyes of the Beast", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132150},
            [2] = {["name"] = "Endurance Training", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136080},
            [5] = {["name"] = "Thick Hide", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134355},
            [4] = {["name"] = "Improved Aspect of the Monkey", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132159},
            [7] = {["name"] = "Pathfinding", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132242},
            [6] = {["name"] = "Improved Revive Pet", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132163},
            [9] = {["name"] = "Unleashed Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132091},
            [8] = {["name"] = "Bestial Swiftness", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132120},
            [16] = {["isExceptional"] = 1, ["name"] = "Bestial Wrath", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132127},
            [14] = {["name"] = "Bestial Discipline", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136006},
            [13] = {["isExceptional"] = 1, ["name"] = "Intimidation", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132111},
            [12] = {["name"] = "Spirit Bond", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132121},
            [11] = {["name"] = "Ferocity", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134297},
            [10] = {["name"] = "Improved Mend Pet", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132179},
        },
        [2] = {
            [1] = {["name"] = "Improved Concussive Shot", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135860},
            [3] = {["name"] = "Improved Hunter's Mark", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132212},
            [2] = {["name"] = "Efficiency", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135865},
            [5] = {["isExceptional"] = 1, ["name"] = "Aimed Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135130},
            [4] = {["name"] = "Lethal Shots", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132312},
            [7] = {["name"] = "Hawk Eye", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132327},
            [6] = {["name"] = "Improved Arcane Shot", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132218},
            [9] = {["name"] = "Mortal Shots", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132271},
            [8] = {["name"] = "Improved Serpent Sting", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132204},
            [14] = {["isExceptional"] = 1, ["name"] = "Trueshot Aura", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132329},
            [13] = {["name"] = "Ranged Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135615},
            [12] = {["name"] = "Improved Scorpid Sting", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132169},
            [11] = {["name"] = "Barrage", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132330},
            [10] = {["isExceptional"] = 1, ["name"] = "Scatter Shot", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 132153},
        },
        [3] = {
            [1] = {["name"] = "Monster Slaying", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 134154},
            [15] = {["name"] = "Lightning Reflexes", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136047},
            [3] = {["name"] = "Deflection", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132269},
            [2] = {["name"] = "Humanoid Slaying", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135942},
            [5] = {["name"] = "Savage Strikes", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132277},
            [4] = {["name"] = "Entrapment", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136100},
            [7] = {["name"] = "Clever Traps", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136106},
            [6] = {["name"] = "Improved Wing Clip", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132309},
            [9] = {["isExceptional"] = 1, ["name"] = "Deterrence", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132369},
            [8] = {["name"] = "Survivalist", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136223},
            [16] = {["isExceptional"] = 1, ["name"] = "Wyvern Sting", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135125},
            [14] = {["isExceptional"] = 1, ["name"] = "Counterattack", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132336},
            [13] = {["name"] = "Killer Instinct", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135881},
            [12] = {["name"] = "Improved Feign Death", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132293},
            [11] = {["name"] = "Surefooted", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132219},
            [10] = {["name"] = "Trap Mastery", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132149},
        },
    },
    ["WARRIOR"] = {
        [1] = {
            [4] = {["name"] = "Improved Charge", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132337},
            [14] = {["name"] = "Mace Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 133476},
            [1] = {["name"] = "Improved Heroic Strike", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132282},
            [8] = {["isExceptional"] = 1, ["name"] = "Anger Management", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135881},
            [3] = {["name"] = "Improved Rend", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132155},
            [2] = {["name"] = "Deflection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [5] = {["name"] = "Tactical Mastery", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136031},
            [18] = {["isExceptional"] = 1, ["name"] = "Mortal Strike", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132355},
            [7] = {["name"] = "Improved Overpower", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135275},
            [6] = {["name"] = "Improved Thunder Clap", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132326},
            [9] = {["name"] = "Deep Wounds", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132090},
            [15] = {["name"] = "Sword Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135328},
            [16] = {["name"] = "Polearm Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135562},
            [17] = {["name"] = "Improved Hamstring", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132316},
            [13] = {["isExceptional"] = 1, ["name"] = "Sweeping Strikes", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132306},
            [12] = {["name"] = "Axe Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132397},
            [11] = {["name"] = "Impale", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132312},
            [10] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132400},
        },
        [2] = {
            [14] = {["name"] = "Improved Intercept", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132307},
            [1] = {["name"] = "Booming Voice", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136075},
            [8] = {["name"] = "Improved Battle Shout", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132333},
            [3] = {["name"] = "Improved Demoralizing Shout", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132366},
            [2] = {["name"] = "Cruelty", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132292},
            [5] = {["name"] = "Improved Cleave", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132338},
            [4] = {["name"] = "Unbridled Wrath", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136097},
            [7] = {["name"] = "Blood Craze", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136218},
            [6] = {["isExceptional"] = 1, ["name"] = "Piercing Howl", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136147},
            [9] = {["name"] = "Dual Wield Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132147},
            [15] = {["name"] = "Improved Berserker Rage", ["tier"] = 6, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136009},
            [16] = {["name"] = "Flurry", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132152},
            [17] = {["isExceptional"] = 1, ["name"] = "Bloodthirst", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136012},
            [13] = {["isExceptional"] = 1, ["name"] = "Death Wish", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136146},
            [12] = {["name"] = "Improved Slam", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132340},
            [11] = {["name"] = "Enrage", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136224},
            [10] = {["name"] = "Improved Execute", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135358},
        },
        [3] = {
            [14] = {["isExceptional"] = 1, ["name"] = "Concussion Blow", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132325},
            [1] = {["name"] = "Shield Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 134952},
            [8] = {["name"] = "Improved Revenge", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132353},
            [3] = {["name"] = "Improved Bloodrage", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132277},
            [2] = {["name"] = "Anticipation", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136056},
            [5] = {["name"] = "Iron Will", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135995},
            [4] = {["name"] = "Toughness", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
            [7] = {["name"] = "Improved Shield Block", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132110},
            [6] = {["isExceptional"] = 1, ["name"] = "Last Stand", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135871},
            [9] = {["name"] = "Defiance", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132347},
            [15] = {["name"] = "Improved Shield Bash", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132357},
            [16] = {["name"] = "One-Handed Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135321},
            [17] = {["isExceptional"] = 1, ["name"] = "Shield Slam", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134951},
            [13] = {["name"] = "Improved Shield Wall", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132362},
            [12] = {["name"] = "Improved Taunt", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136080},
            [11] = {["name"] = "Improved Disarm", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132343},
            [10] = {["name"] = "Improved Sunder Armor", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132363},
        },
    },
    ["PALADIN"] = {
        [1] = {
            [1] = {["name"] = "Divine Strength", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132154},
            [3] = {["name"] = "Spiritual Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135736},
            [2] = {["name"] = "Divine Intellect", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136090},
            [5] = {["name"] = "Healing Light", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135920},
            [4] = {["name"] = "Improved Seal of Righteousness", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132325},
            [7] = {["name"] = "Improved Lay on Hands", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135928},
            [6] = {["isExceptional"] = 1, ["name"] = "Consecration", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135926},
            [9] = {["name"] = "Illumination", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135913},
            [8] = {["name"] = "Unyielding Faith", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135984},
            [14] = {["isExceptional"] = 1, ["name"] = "Holy Shock", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135972},
            [13] = {["name"] = "Holy Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135938},
            [12] = {["name"] = "Lasting Judgement", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135917},
            [11] = {["isExceptional"] = 1, ["name"] = "Divine Favor", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135915},
            [10] = {["name"] = "Improved Blessing of Wisdom", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135970},
        },
        [2] = {
            [1] = {["name"] = "Improved Devotion Aura", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135893},
            [3] = {["name"] = "Precision", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132282},
            [2] = {["name"] = "Redoubt", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132110},
            [5] = {["name"] = "Toughness", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135892},
            [4] = {["name"] = "Guardian's Favor", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135964},
            [7] = {["name"] = "Improved Righteous Fury", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135962},
            [6] = {["isExceptional"] = 1, ["name"] = "Blessing of Kings", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135995},
            [9] = {["name"] = "Anticipation", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135994},
            [8] = {["name"] = "Shield Specialization", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134952},
            [15] = {["isExceptional"] = 1, ["name"] = "Holy Shield", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135880},
            [14] = {["name"] = "One-Handed Weapon Specialization", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135321},
            [13] = {["name"] = "Reckoning", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135882},
            [12] = {["isExceptional"] = 1, ["name"] = "Blessing of Sanctuary", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136051},
            [11] = {["name"] = "Improved Concentration Aura", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135933},
            [10] = {["name"] = "Improved Hammer of Justice", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135963},
        },
        [3] = {
            [1] = {["name"] = "Improved Blessing of Might", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135906},
            [3] = {["name"] = "Improved Judgement", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135959},
            [2] = {["name"] = "Benediction", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135863},
            [5] = {["name"] = "Deflection", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132269},
            [4] = {["name"] = "Improved Seal of the Crusader", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135924},
            [7] = {["name"] = "Conviction", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135957},
            [6] = {["name"] = "Vindication", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135985},
            [9] = {["name"] = "Pursuit of Justice", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135937},
            [8] = {["isExceptional"] = 1, ["name"] = "Seal of Command", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132347},
            [15] = {["isExceptional"] = 1, ["name"] = "Repentance", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135942},
            [14] = {["name"] = "Vengeance", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132275},
            [13] = {["isExceptional"] = 1, ["name"] = "Sanctity Aura", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135934},
            [12] = {["name"] = "Two-Handed Weapon Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 133041},
            [11] = {["name"] = "Improved Retribution Aura", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135873},
            [10] = {["name"] = "Eye for an Eye", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135904},
        },
    },
    ["MAGE"] = {
        [1] = {
            [1] = {["name"] = "Arcane Subtlety", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135894},
            [15] = {["name"] = "Arcane Instability", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136222},
            [3] = {["name"] = "Improved Arcane Missiles", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136096},
            [2] = {["name"] = "Arcane Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135892},
            [5] = {["name"] = "Magic Absorption", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136011},
            [4] = {["name"] = "Wand Specialization", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135463},
            [7] = {["name"] = "Magic Attunement", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136006},
            [6] = {["name"] = "Arcane Concentration", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136170},
            [9] = {["isExceptional"] = 1, ["name"] = "Arcane Resilience", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135733},
            [8] = {["name"] = "Improved Arcane Explosion", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136116},
            [16] = {["isExceptional"] = 1, ["name"] = "Arcane Power", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136048},
            [14] = {["name"] = "Arcane Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136129},
            [13] = {["isExceptional"] = 1, ["name"] = "Presence of Mind", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136031},
            [12] = {["name"] = "Arcane Meditation", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136208},
            [11] = {["name"] = "Improved Counterspell", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135856},
            [10] = {["name"] = "Improved Mana Shield", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136153},
        },
        [2] = {
            [1] = {["name"] = "Improved Fireball", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135812},
            [15] = {["name"] = "Fire Power", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135817},
            [3] = {["name"] = "Ignite", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135818},
            [2] = {["name"] = "Impact", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135821},
            [5] = {["name"] = "Improved Fire Blast", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135807},
            [4] = {["name"] = "Flame Throwing", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135815},
            [7] = {["name"] = "Improved Flamestrike", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135826},
            [6] = {["name"] = "Incinerate", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135813},
            [9] = {["name"] = "Burning Soul", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 135805},
            [8] = {["isExceptional"] = 1, ["name"] = "Pyroblast", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135808},
            [16] = {["isExceptional"] = 1, ["name"] = "Combustion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135824},
            [14] = {["isExceptional"] = 1, ["name"] = "Blast Wave", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135903},
            [13] = {["name"] = "Critical Mass", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136115},
            [12] = {["name"] = "Master of Elements", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135820},
            [11] = {["name"] = "Improved Fire Ward", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135806},
            [10] = {["name"] = "Improved Scorch", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135827},
        },
        [3] = {
            [9] = {["isExceptional"] = 1, ["name"] = "Cold Snap", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135865},
            [1] = {["name"] = "Frost Warding", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135850},
            [15] = {["name"] = "Improved Cone of Cold", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135852},
            [3] = {["name"] = "Elemental Precision", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135989},
            [2] = {["name"] = "Improved Frostbolt", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135846},
            [5] = {["name"] = "Frostbite", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135842},
            [4] = {["name"] = "Ice Shards", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 135855},
            [7] = {["name"] = "Permafrost", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135864},
            [6] = {["name"] = "Improved Frost Nova", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135840},
            [14] = {["isExceptional"] = 1, ["name"] = "Ice Block", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135841},
            [8] = {["name"] = "Piercing Ice", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135845},
            [16] = {["name"] = "Winter's Chill", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135836},
            [17] = {["isExceptional"] = 1, ["name"] = "Ice Barrier", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135988},
            [13] = {["name"] = "Shatter", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135849},
            [12] = {["name"] = "Frost Channeling", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135860},
            [11] = {["name"] = "Arctic Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136141},
            [10] = {["name"] = "Improved Blizzard", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135857},
        },
    },
    ["PRIEST"] = {
        [1] = {
            [1] = {["name"] = "Unbreakable Will", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135995},
            [3] = {["name"] = "Silent Resolve", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136053},
            [2] = {["name"] = "Wand Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135463},
            [5] = {["name"] = "Improved Power Word: Shield", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135940},
            [4] = {["name"] = "Improved Power Word: Fortitude", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135987},
            [7] = {["isExceptional"] = 1, ["name"] = "Inner Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135863},
            [6] = {["name"] = "Martyrdom", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136107},
            [9] = {["name"] = "Improved Inner Fire", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135926},
            [8] = {["name"] = "Meditation", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136090},
            [15] = {["isExceptional"] = 1, ["name"] = "Power Infusion", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135939},
            [14] = {["name"] = "Force of Will", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136092},
            [13] = {["isExceptional"] = 1, ["name"] = "Divine Spirit", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 135898},
            [12] = {["name"] = "Mental Strength", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136031},
            [11] = {["name"] = "Improved Mana Burn", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136170},
            [10] = {["name"] = "Mental Agility", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132156},
        },
        [2] = {
            [1] = {["name"] = "Healing Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135918},
            [15] = {["name"] = "Spiritual Healing", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136057},
            [3] = {["name"] = "Holy Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135967},
            [2] = {["name"] = "Improved Renew", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135953},
            [5] = {["name"] = "Divine Fury", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135971},
            [4] = {["name"] = "Spell Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135976},
            [7] = {["name"] = "Blessed Recovery", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135877},
            [6] = {["isExceptional"] = 1, ["name"] = "Holy Nova", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 135922},
            [9] = {["name"] = "Holy Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135949},
            [8] = {["name"] = "Inspiration", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135928},
            [16] = {["isExceptional"] = 1, ["name"] = "Lightwell", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135980},
            [14] = {["name"] = "Spiritual Guidance", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135977},
            [13] = {["isExceptional"] = 1, ["name"] = "Spirit of Redemption", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132864},
            [12] = {["name"] = "Improved Prayer of Healing", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135943},
            [11] = {["name"] = "Searing Light", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 135973},
            [10] = {["name"] = "Improved Healing", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135916},
        },
        [3] = {
            [1] = {["name"] = "Spirit Tap", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136188},
            [15] = {["name"] = "Darkness", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136223},
            [3] = {["name"] = "Shadow Affinity", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136205},
            [2] = {["name"] = "Blackout", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136160},
            [5] = {["name"] = "Shadow Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136126},
            [4] = {["name"] = "Improved Shadow Word: Pain", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136207},
            [7] = {["name"] = "Improved Mind Blast", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136224},
            [6] = {["name"] = "Improved Psychic Scream", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136184},
            [9] = {["name"] = "Improved Fade", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135994},
            [8] = {["isExceptional"] = 1, ["name"] = "Mind Flay", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136208},
            [16] = {["isExceptional"] = 1, ["name"] = "Shadowform", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136200},
            [14] = {["name"] = "Improved Vampiric Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136165},
            [13] = {["isExceptional"] = 1, ["name"] = "Vampiric Embrace", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136230},
            [12] = {["isExceptional"] = 1, ["name"] = "Silence", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136164},
            [11] = {["name"] = "Shadow Weaving", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136123},
            [10] = {["name"] = "Shadow Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136130},
        },
    },
    ["WARLOCK"] = {
        [1] = {
            [14] = {["isExceptional"] = 1, ["name"] = "Curse of Exhaustion", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136162},
            [1] = {["name"] = "Suppression", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136230},
            [8] = {["name"] = "Fel Concentration", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136157},
            [3] = {["name"] = "Improved Curse of Weakness", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136138},
            [2] = {["name"] = "Improved Corruption", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136118},
            [5] = {["name"] = "Improved Life Tap", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136126},
            [4] = {["name"] = "Improved Drain Soul", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136163},
            [7] = {["name"] = "Improved Curse of Agony", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136139},
            [6] = {["name"] = "Improved Drain Life", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136169},
            [9] = {["isExceptional"] = 1, ["name"] = "Amplify Curse", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136132},
            [15] = {["name"] = "Improved Curse of Exhaustion", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 4, ["texture"] = 136162},
            [16] = {["name"] = "Shadow Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136195},
            [17] = {["isExceptional"] = 1, ["name"] = "Dark Pact", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136141},
            [13] = {["isExceptional"] = 1, ["name"] = "Siphon Life", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136188},
            [12] = {["name"] = "Improved Drain Mana", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136208},
            [11] = {["name"] = "Nightfall", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136223},
            [10] = {["name"] = "Grim Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136127},
        },
        [2] = {
            [14] = {["name"] = "Improved Firestone", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132386},
            [1] = {["name"] = "Improved Healthstone", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135230},
            [8] = {["isExceptional"] = 1, ["name"] = "Fel Domination", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136082},
            [3] = {["name"] = "Demonic Embrace", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136172},
            [2] = {["name"] = "Improved Imp", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136218},
            [5] = {["name"] = "Improved Voidwalker", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136221},
            [4] = {["name"] = "Improved Health Funnel", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136168},
            [7] = {["name"] = "Improved Sayaad", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 4352493},
            [6] = {["name"] = "Fel Intellect", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135932},
            [9] = {["name"] = "Fel Stamina", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136121},
            [15] = {["name"] = "Master Demonologist", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136203},
            [16] = {["isExceptional"] = 1, ["name"] = "Soul Link", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136160},
            [17] = {["name"] = "Improved Spellstone", ["tier"] = 7, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 134131},
            [13] = {["isExceptional"] = 1, ["name"] = "Demonic Sacrifice", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136184},
            [12] = {["name"] = "Improved Enslave Demon", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136154},
            [11] = {["name"] = "Unholy Power", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136206},
            [10] = {["name"] = "Master Summoner", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136164},
        },
        [3] = {
            [1] = {["name"] = "Improved Shadow Bolt", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136197},
            [8] = {["isExceptional"] = 1, ["name"] = "Shadowburn", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136191},
            [3] = {["name"] = "Bane", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136146},
            [2] = {["name"] = "Cataclysm", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135831},
            [5] = {["name"] = "Improved Firebolt", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135809},
            [4] = {["name"] = "Aftermath", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135805},
            [7] = {["name"] = "Devastation", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135813},
            [6] = {["name"] = "Improved Lash of Pain", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136136},
            [9] = {["name"] = "Intensity", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135819},
            [15] = {["name"] = "Emberstorm", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135826},
            [16] = {["isExceptional"] = 1, ["name"] = "Conflagrate", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135807},
            [14] = {["name"] = "Ruin", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136207},
            [13] = {["name"] = "Improved Immolate", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135817},
            [12] = {["name"] = "Pyroclasm", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135830},
            [11] = {["name"] = "Improved Searing Pain", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 135827},
            [10] = {["name"] = "Destructive Reach", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136133},
        },
    },
    ["ROGUE"] = {
        [1] = {
            [1] = {["name"] = "Improved Eviscerate", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132292},
            [3] = {["name"] = "Malice", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132277},
            [2] = {["name"] = "Remorseless Attacks", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132151},
            [5] = {["name"] = "Murder", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136147},
            [4] = {["name"] = "Ruthlessness", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132122},
            [7] = {["isExceptional"] = 1, ["name"] = "Relentless Strikes", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 132340},
            [6] = {["name"] = "Improved Slice and Dice", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 132306},
            [9] = {["name"] = "Lethality", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132109},
            [8] = {["name"] = "Improved Expose Armor", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132354},
            [15] = {["name"] = "Vigor", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136023},
            [14] = {["name"] = "Seal Fate", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136130},
            [13] = {["name"] = "Improved Kidney Shot", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132298},
            [12] = {["isExceptional"] = 1, ["name"] = "Cold Blood", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135988},
            [11] = {["name"] = "Improved Poisons", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132273},
            [10] = {["name"] = "Vile Poisons", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132293},
        },
        [2] = {
            [19] = {["isExceptional"] = 1, ["name"] = "Adrenaline Rush", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136206},
            [18] = {["name"] = "Aggression", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132275},
            [9] = {["name"] = "Improved Sprint", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132307},
            [1] = {["name"] = "Improved Gouge", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132155},
            [15] = {["name"] = "Sword Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135328},
            [3] = {["name"] = "Lightning Reflexes", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136047},
            [2] = {["name"] = "Improved Sinister Strike", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 136189},
            [5] = {["name"] = "Deflection", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132269},
            [4] = {["name"] = "Improved Backstab", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 132090},
            [7] = {["name"] = "Endurance", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136205},
            [6] = {["name"] = "Precision", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132222},
            [14] = {["isExceptional"] = 1, ["name"] = "Blade Flurry", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132350},
            [8] = {["isExceptional"] = 1, ["name"] = "Riposte", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132336},
            [16] = {["name"] = "Fist Weapon Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132938},
            [17] = {["name"] = "Weapon Expertise", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135882},
            [13] = {["name"] = "Mace Specialization", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 133476},
            [12] = {["name"] = "Dual Wield Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132147},
            [11] = {["name"] = "Dagger Specialization", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135641},
            [10] = {["name"] = "Improved Kick", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132219},
        },
        [3] = {
            [9] = {["name"] = "Setup", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136056},
            [1] = {["name"] = "Master of Deception", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136129},
            [15] = {["isExceptional"] = 1, ["name"] = "Hemorrhage", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 1, ["texture"] = 136168},
            [3] = {["name"] = "Sleight of Hand", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132294},
            [2] = {["name"] = "Opportunity", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132366},
            [5] = {["name"] = "Camouflage", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132320},
            [4] = {["name"] = "Elusiveness", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 135994},
            [7] = {["isExceptional"] = 1, ["name"] = "Ghostly Strike", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136136},
            [6] = {["name"] = "Initiative", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136159},
            [14] = {["name"] = "Dirty Deeds", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136220},
            [8] = {["name"] = "Improved Ambush", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 132282},
            [16] = {["name"] = "Deadliness", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135540},
            [17] = {["isExceptional"] = 1, ["name"] = "Premeditation", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136183},
            [13] = {["isExceptional"] = 1, ["name"] = "Preparation", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136121},
            [12] = {["name"] = "Heightened Senses", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132089},
            [11] = {["name"] = "Serrated Blades", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135315},
            [10] = {["name"] = "Improved Sap", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132310},
        },
    },
    ["DRUID"] = {
        [1] = {
            [1] = {["name"] = "Improved Wrath", ["tier"] = 1, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136006},
            [15] = {["name"] = "Moonfury", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136057},
            [3] = {["name"] = "Improved Nature's Grasp", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 4, ["texture"] = 136063},
            [2] = {["isExceptional"] = 1, ["name"] = "Nature's Grasp", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136063},
            [5] = {["name"] = "Improved Moonfire", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136096},
            [4] = {["name"] = "Improved Entangling Roots", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136100},
            [7] = {["name"] = "Natural Shapeshifter", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136116},
            [6] = {["name"] = "Natural Weapons", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135138},
            [9] = {["isExceptional"] = 1, ["name"] = "Omen of Clarity", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136017},
            [8] = {["name"] = "Improved Thorns", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136104},
            [16] = {["isExceptional"] = 1, ["name"] = "Moonkin Form", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136036},
            [14] = {["name"] = "Moonglow", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 136087},
            [13] = {["name"] = "Nature's Grace", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136062},
            [12] = {["name"] = "Improved Starfire", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135753},
            [11] = {["name"] = "Vengeance", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136075},
            [10] = {["name"] = "Nature's Reach", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136065},
        },
        [2] = {
            [1] = {["name"] = "Ferocity", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132190},
            [15] = {["name"] = "Heart of the Wild", ["tier"] = 6, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135879},
            [3] = {["name"] = "Feral Instinct", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 132089},
            [2] = {["name"] = "Feral Aggression", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132121},
            [5] = {["name"] = "Thick Hide", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134355},
            [4] = {["name"] = "Brutal Impact", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 2, ["texture"] = 132114},
            [7] = {["isExceptional"] = 1, ["name"] = "Feral Charge", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 132183},
            [6] = {["name"] = "Feline Swiftness", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136095},
            [9] = {["name"] = "Improved Shred", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136231},
            [8] = {["name"] = "Sharpened Claws", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 134297},
            [16] = {["isExceptional"] = 1, ["name"] = "Leader of the Pack", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136112},
            [14] = {["isExceptional"] = 1, ["name"] = "Faerie Fire (Feral)", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136033},
            [13] = {["name"] = "Savage Fury", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 132141},
            [12] = {["name"] = "Primal Fury", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 132278},
            [11] = {["name"] = "Blood Frenzy", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132152},
            [10] = {["name"] = "Predatory Strikes", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 132185},
        },
        [3] = {
            [1] = {["name"] = "Improved Mark of the Wild", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136078},
            [3] = {["name"] = "Improved Healing Touch", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 5, ["texture"] = 136041},
            [2] = {["name"] = "Furor", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135881},
            [5] = {["name"] = "Improved Enrage", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 132126},
            [4] = {["name"] = "Nature's Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136042},
            [7] = {["isExceptional"] = 1, ["name"] = "Insect Swarm", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136045},
            [6] = {["name"] = "Reflection", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135863},
            [9] = {["name"] = "Tranquil Spirit", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135900},
            [8] = {["name"] = "Subtlety", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 132150},
            [15] = {["isExceptional"] = 1, ["name"] = "Swiftmend", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 134914},
            [14] = {["name"] = "Improved Regrowth", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136085},
            [13] = {["name"] = "Improved Tranquility", ["tier"] = 5, ["id"] = 0, ["column"] = 4, ["maxRank"] = 2, ["texture"] = 136107},
            [12] = {["name"] = "Gift of Nature", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136074},
            [11] = {["isExceptional"] = 1, ["name"] = "Nature's Swiftness", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136076},
            [10] = {["name"] = "Improved Rejuvenation", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136081},
        },
    },
    ["SHAMAN"] = {
        [1] = {
            [1] = {["name"] = "Convection", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136116},
            [3] = {["name"] = "Earth's Grasp", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136097},
            [2] = {["name"] = "Concussion", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135807},
            [5] = {["name"] = "Call of Flame", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 3, ["texture"] = 135817},
            [4] = {["name"] = "Elemental Warding", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136094},
            [7] = {["name"] = "Reverberation", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 135850},
            [6] = {["isExceptional"] = 1, ["name"] = "Elemental Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 1, ["texture"] = 136170},
            [9] = {["name"] = "Improved Fire Totems", ["tier"] = 4, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135824},
            [8] = {["name"] = "Call of Thunder", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136014},
            [15] = {["isExceptional"] = 1, ["name"] = "Elemental Mastery", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 136115},
            [14] = {["name"] = "Lightning Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135990},
            [13] = {["name"] = "Elemental Fury", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135830},
            [12] = {["name"] = "Storm Reach", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136099},
            [11] = {["name"] = "Elemental Devastation", ["tier"] = 4, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 135791},
            [10] = {["name"] = "Eye of the Storm", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136032},
        },
        [2] = {
            [1] = {["name"] = "Ancestral Knowledge", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136162},
            [8] = {["name"] = "Two-Handed Axes and Maces", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132401},
            [3] = {["name"] = "Guardian Totems", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136098},
            [2] = {["name"] = "Shield Specialization", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 134952},
            [5] = {["name"] = "Improved Ghost Wolf", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 2, ["texture"] = 136095},
            [4] = {["name"] = "Thundering Strikes", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132325},
            [7] = {["name"] = "Enhancing Totems", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136023},
            [6] = {["name"] = "Improved Lightning Shield", ["tier"] = 2, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136051},
            [9] = {["name"] = "Anticipation", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 5, ["texture"] = 136056},
            [15] = {["name"] = "Weapon Mastery", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 132215},
            [16] = {["isExceptional"] = 1, ["name"] = "Stormstrike", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135963},
            [14] = {["name"] = "Parry", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 132269},
            [13] = {["name"] = "Elemental Weapons", ["tier"] = 5, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 135814},
            [12] = {["name"] = "Improved Weapon Totems", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 135792},
            [11] = {["name"] = "Toughness", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135892},
            [10] = {["name"] = "Flurry", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 132152},
        },
        [3] = {
            [1] = {["name"] = "Improved Healing Wave", ["tier"] = 1, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136052},
            [3] = {["name"] = "Improved Reincarnation", ["tier"] = 2, ["id"] = 0, ["column"] = 1, ["maxRank"] = 2, ["texture"] = 136080},
            [2] = {["name"] = "Tidal Focus", ["tier"] = 1, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135859},
            [5] = {["name"] = "Totemic Focus", ["tier"] = 2, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136057},
            [4] = {["name"] = "Ancestral Healing", ["tier"] = 2, ["id"] = 0, ["column"] = 2, ["maxRank"] = 3, ["texture"] = 136109},
            [7] = {["name"] = "Healing Focus", ["tier"] = 3, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136043},
            [6] = {["name"] = "Nature's Guidance", ["tier"] = 3, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 135860},
            [9] = {["name"] = "Healing Grace", ["tier"] = 3, ["id"] = 0, ["column"] = 4, ["maxRank"] = 3, ["texture"] = 136041},
            [8] = {["name"] = "Totemic Mastery", ["tier"] = 3, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136069},
            [15] = {["isExceptional"] = 1, ["name"] = "Mana Tide Totem", ["tier"] = 7, ["id"] = 0, ["column"] = 2, ["maxRank"] = 1, ["texture"] = 135861},
            [14] = {["name"] = "Purification", ["tier"] = 6, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 135865},
            [13] = {["isExceptional"] = 1, ["name"] = "Nature's Swiftness", ["tier"] = 5, ["id"] = 0, ["column"] = 3, ["maxRank"] = 1, ["texture"] = 136076},
            [12] = {["name"] = "Healing Way", ["tier"] = 5, ["id"] = 0, ["column"] = 1, ["maxRank"] = 3, ["texture"] = 136044},
            [11] = {["name"] = "Tidal Mastery", ["tier"] = 4, ["id"] = 0, ["column"] = 3, ["maxRank"] = 5, ["texture"] = 136107},
            [10] = {["name"] = "Restorative Totems", ["tier"] = 4, ["id"] = 0, ["column"] = 2, ["maxRank"] = 5, ["texture"] = 136053},
        },
    },
    ["DEATHKNIGHT"] = {
        [1] = {},
        [2] = {},
        [3] = {},
    },
}
end

-- locals
local f = lib.frame
local cache = lib.cache
local queue = lib.queue
local spec_table = lib.spec_table
local spec_table_localized = lib.spec_table_localized
local talents_table = lib.talents_table
local guildies = lib.guildies
local tracked_achievements = lib.tracked_achievements
local glyphs_table = lib.glyphs_table
local glyph_r_tbl = lib.glyph_r_tbl

local function getPlayerGUID(arg)
    if (arg) then
        if (GUIDIsPlayer(arg)) then
            return arg
        elseif (UnitIsPlayer(arg)) then
            return UnitGUID(arg)
        end
    end
    return nil
end

local function getCacheUser(guid)
    if (guid == user_cache_this.guid) then
        return user_cache_this
    elseif (cache.first) then
        local node = cache.first
        repeat
            if (guid == node.guid) then
                user_cache_this = node
                return node
            end
            node = node.next
        until (node == nil)
    end
    return nil
end

local function getCacheUser2(guid)
    if (not guid) then return end
    local user = getCacheUser(guid)
    if (user) then
        local t = time()-INSPECTOR_REFRESH_DELAY
        if ((not isClassic and user.talents.time < t) or user.inventory.time < t or (isWotlk and user.achievements.time < t)) then
            lib:DoInspect(guid)
        end
    else
        lib:DoInspect(guid)
    end
    return user
end

local function addCacheUser(guid, inventory, talents, achievements, glyphs)
    local user = {["guid"] = guid}
    if(inventory) then
        user.inventory = inventory
    else
        user.inventory = {["time"] = 0}
    end
    if(talents) then
        user.talents = talents
    else
        user.talents = {[1] = {[1] = {}, [2] = {}, [3] = {}}, [2] = {[1] = {}, [2] = {}, [3] = {}}, ["time"] = 0, ["active"] = 0}
    end
    if(achievements) then
        user.achievements = achievements
    else
        user.achievements = {["time"] = 0}
    end
    if(glyphs) then
        user.glyphs = glyphs
    else
        user.glyphs = {["time"] = 0}
    end
    if (not cache.first) then
        cache.first = user
        cache.last = user
        cache.len = 1
    else
        cache.last.next = user
        cache.last = user
        if (cache.len >= INSPECTOR_MAX_CACHE) then
            if (IsInGroup() and IsGUIDInGroup(cache.first.guid)) then
                local node = cache.first
                while (IsGUIDInGroup(node.next.guid)) do
                    node = node.next
                end
                local next = node.next
                node.next = next.next
                next = nil
            else
                local next = cache.first.next
                cache.first = nil
                cache.first = next 
            end
        else
            cache.len = cache.len + 1
        end
    end
end

local function cacheUserInventory(unit)
    local guid = UnitGUID(unit)
    if (not guid) then
        return
    end
    local inventory = {["time"] = time(), ["inspect"] = true}
    for i=1,19 do
        inventory[i] = GetInventoryItemID(unit, i)
        --C_Item.RequestLoadItemDataByID(itemID)
    end
    local user = getCacheUser(guid)
    if(user) then
        user.inventory = inventory
    else
        addCacheUser(guid, inventory, nil, nil, nil)
    end
    -- Fire INVENTORY_READY(guid, isInspect[, unit]) callback
    lib.callbacks:Fire("INVENTORY_READY", guid, true, unit)
end

local function cacheUserTalents(unit)
    local guid = UnitGUID(unit)
    if (not guid) then
        return
    end
    local talents = {[1] = {[1] = {}, [2] = {}, [3] = {}}, [2] = {[1] = {}, [2] = {}, [3] = {}}, ["time"] = time(), ["active"] = isWotlk and GetActiveTalentGroup(true, false) or 1, ["inspect"] = true}
    for x = 1, (isWotlk and 2 or 1) do
        for i = 1, 3 do  -- GetNumTalentTabs
            for j = 1, GetNumTalents(i, true, false) do
                talents[x][i][j] = select(5, GetTalentInfo(i, j, true, false, x))
            end
        end
    end
    local user = getCacheUser(guid)
    if(user) then
        user.talents = talents
    else
        addCacheUser(guid, nil, talents, nil, nil)
    end
    -- Fire TALENTS_READY(guid, isInspect[, unit]) callback
    lib.callbacks:Fire("TALENTS_READY", guid, true, unit)
end

local function cacheUserAchievements(guid)
    local achievements = {["time"] = time(), ["t_pts"] = GetComparisonAchievementPoints()}
    for k,v in pairs(tracked_achievements) do
        if (v == 1) then
            achievements[k] = GetComparisonStatistic(k)
        else
            achievements[k] = {GetAchievementComparisonInfo(k)}
        end
    end
    local user = getCacheUser(guid)
    if(user) then
        user.achievements = achievements
    else
        addCacheUser(guid, nil, nil, achievements, nil)
    end
end

local function tryCompare(unit)
    if (AchievementFrameComparison) then
        AchievementFrameComparison:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
    end
    if (not AchievementFrame or not AchievementFrame.isComparison) then
        ClearAchievementComparisonUnit()
        SetAchievementComparisonUnit(unit)
        return true
    end
    return false
end

local function tryInspect(unit, refresh)
    if (lib:CanInspect(unit)) then
        local guid = UnitGUID(unit)
        local user = getCacheUser(guid)
        local ret = false
        if (user) then
            if (refresh) then
                local t = time()-INSPECTOR_REFRESH_DELAY
                if ((not isClassic and user.talents.time < t) or user.inventory.time < t) then
                    NotifyInspect(unit)
                    ret = true
                end
                if (isWotlk and user.achievements.time < t) then
                    if (tryCompare(unit)) then
                        ret = true
                    end
                end
            else
                if ((not isClassic and user.talents.time == 0) or user.inventory.time == 0) then
                    NotifyInspect(unit)
                    ret = true
                end
                if (isWotlk and user.achievements.time == 0) then
                    if (tryCompare(unit)) then
                        ret = true
                    end
                end
            end
        else
            NotifyInspect(unit)
            if (isWotlk) then
                tryCompare(unit)
            end
            return true
        end
    end
    return ret
end

function f:INSPECT_READY(event, guid)
    if (not guid) then 
        return
    end
    local unit = lib:PlayerGUIDToUnitToken(guid)
    if(not unit or UnitIsUnit(unit, "player")) then
        return
    end
    if (not isClassic) then
        cacheUserTalents(unit)
    end
    cacheUserInventory(unit)
end
function f:UNIT_INVENTORY_CHANGED(event, unit)
    if (unit and UnitIsPlayer(unit) and (not UnitIsUnit(unit, "player"))) then
        cacheUserInventory(unit)
    end
end
function f:CHAT_MSG_ADDON(event, prefix, text, channelType, senderFullName, sender)
    if (prefix ~= C_PREFIX) then return end
    if (string.byte(text, 1) ~= 48 or string.byte(text, 3) ~= 45) then return end
    local v = string.byte(text, 2)
    if (v == 48 or v == 49 or v == 50) then
        local guid = UnitGUID(sender)
        if (not guid or not GUIDIsPlayer(guid)) then
            if (not IsInGuild()) then return end
            guid = guildies[senderFullName]
            if (not guid or not GUIDIsPlayer(guid)) then return end
        end
        if (guid == UnitGUID("player")) then return end
        local _, class = GetPlayerInfoByGUID(guid)
        if (not class) then return end
        local a = tonumber(string.byte(text,4))
        a = a and (a-48) or 0
        if (a < 1 or a > 2) then return end
        local talents = {[1] = {[1] = {}, [2] = {}, [3] = {}}, [2] = {[1] = {}, [2] = {}, [3] = {}}, ["time"] = time(), ["active"] = a, ["inspect"] = false}
        local s = strsub(text, 5)
        local y = 0
        for x = 1, (isWotlk and 2 or 1) do
            for i = 1, 3 do  -- GetNumTalentTabs
                for j = 1, lib:GetNumTalentsByClass(class, i) do
                    y = y + 1
                    local z = tonumber(string.byte(s,y))
                    z = z and (z-48) or -1
                    if (z < 0 or z > select(6, lib:GetTalentInfoByClass(class, i, j))) then return end
                    talents[x][i][j] = z
                end
            end
        end
        local glyphs
        if (isWotlk and v == 50) then
            glyphs = {["time"] = time()}
            for x = 1, 12 do
                y = y + 1
                local z = tonumber(string.byte(s,y))
                z = z and (z-48) or -1
                if (x == 1 or x == 4 or x == 6 or x == 7 or x == 10 or x == 12) then
                    if (z < 0 or z > #glyphs_table[class][1]) then return end
                else
                    if (z < 0 or z > #glyphs_table[class][2]) then return end
                end
                glyphs[x] = z
            end
        end
        local user = getCacheUser(guid)
        if(user) then
            user.talents = talents
            if (glyphs) then
                user.glyphs = glyphs
            end
        else
            addCacheUser(guid, nil, talents, nil, glyphs)
        end
        -- Fire TALENTS_READY(guid, isInspect[, unit]) callback
        lib.callbacks:Fire("TALENTS_READY", guid, false, nil)
        if (glyphs) then
            -- Fire GLYPHS_READY(guid, isInspect[, unit]) callback
            lib.callbacks:Fire("GLYPHS_READY", guid, false, nil)
        end
    end
end
function f:GUILD_ROSTER_UPDATE()
    if (IsInGuild()) then
        for i=1, GetNumGuildMembers() do
            local fullName, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
            if (fullName and guid) then
                guildies[fullName] = guid
            end
        end
    end
    infoChanged = true
end
function f:PLAYER_ALIVE()
    infoChanged = true
end
function f:PLAYER_UNGHOST()
    infoChanged = true
end
function f:GROUP_ROSTER_UPDATE()
    infoChanged = true
end
function f:PLAYER_ENTERING_WORLD()
    infoChanged = true
end
function f:CHARACTER_POINTS_CHANGED()
    infoChanged = true
end
function f:PLAYER_TALENT_UPDATE()
    infoChanged = true
end
function f:ACTIVE_TALENT_GROUP_CHANGED()
    infoChanged = true
end
if (isWotlk) then
function f:INSPECT_ACHIEVEMENT_READY(event, guid, ...)
    if (guid and GUIDIsPlayer(guid)) then
        cacheUserAchievements(guid)
        -- Fire ACHIEVEMENTS_READY(guid, isInspect) callback
        lib.callbacks:Fire("ACHIEVEMENTS_READY", guid, true, nil)
    end
    if (AchievementFrame and AchievementFrame.isComparison and AchievementFrameComparison) then
        AchievementFrameComparison_OnEvent(AchievementFrameComparison, event, guid, ...)
    end
end
end

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)
f:RegisterEvent("INSPECT_READY")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ALIVE")
f:RegisterEvent("PLAYER_UNGHOST")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")
if (isWotlk) then
    f:RegisterEvent("PLAYER_TALENT_UPDATE")
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    f:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
end
C_ChatInfo.RegisterAddonMessagePrefix(C_PREFIX)

local function sendInfo()
    if (IsInGroup() or IsInGuild()) then
        local s = "02-"
        s = s .. (isWotlk and GetActiveTalentGroup(false, false) or 1)
        for x = 1, (isWotlk and 2 or 1) do
            for i = 1, 3 do  -- GetNumTalentTabs
                for j = 1, GetNumTalents(i, false, false) do
                    s = s .. select(5, GetTalentInfo(i, j, false, false, x))
                end
            end
        end
        if (isWotlk) then
            for x = 1, 2 do
                for i = 1, 6 do
                    local z = select(3, GetGlyphSocketInfo(i, x))
                    if (z) then
                        if (z == 55115) then z = 54929 end
                        s = s..string.char(glyph_r_tbl[z]+48)
                    else
                        s = s.."0"
                    end
                end
            end
        end
        if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
            SendAddonMessage(C_PREFIX, s, "RAID")
        end
        if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
            SendAddonMessage(C_PREFIX, s, "INSTANCE_CHAT")
        end
        if (IsInGuild()) then
            SendAddonMessage(C_PREFIX, s, "GUILD")
        end
    end
end

local function inspectQueueTick()
    if (InCombatLockdown() or not UnitExists("player") or not UnitIsConnected("player") or UnitIsDeadOrGhost("player")) then return end
    if (GetTime() >= nextInspectTime) then
        if (UnitExists("target") and tryInspect("target", true)) then
            return
        elseif (#queue > 0) then
            for i=#queue,1,-1 do
                local unit = lib:PlayerGUIDToUnitToken(queue[i])
                table.remove(queue, i)
                if (unit and tryInspect(unit, true)) then
                    return
                end
            end
        elseif (IsInGroup()) then
            if (IsInRaid()) then
                for i=1,40 do
                    if (UnitExists("raid"..i) and tryInspect("raid"..i, false)) then
                        return
                    end
                end
            else
                for i=1,4 do
                    if (UnitExists("party"..i) and tryInspect("party"..i, false)) then
                        return
                    end
                end
            end
        end
    end
end 
if lib.queueTicker then
    lib.queueTicker:Cancel()
end
lib.queueTicker = NewTicker(INSPECTOR_QUEUE_INTERVAL, inspectQueueTick)

local function infoTick()
    if (infoChanged or infoTicks >= INSPECTOR_INFO_MAX_INTERVAL) then
        infoChanged = false
        infoTicks = 0
        sendInfo()
    else
        infoTicks = infoTicks + INSPECTOR_INFO_MIN_INTERVAL
    end
end
if lib.infoTicker then
    lib.infoTicker:Cancel()
end
lib.infoTicker = NewTicker(INSPECTOR_INFO_MIN_INTERVAL, infoTick)

Detours:SecureHook(lib, "NotifyInspect", function()
    nextInspectTime = GetTime()+INSPECTOR_INSPECT_DELAY
end)

-- fix blizzard CanInspect
local oCanInspect
oCanInspect = Detours:DetourHook(lib, "CanInspect", function(unit, showError, ...)
    skip_error = not showError
    local ret = oCanInspect(unit, showError, ...)
    skip_error = false
    return ret
end)

local oAddMessage
oAddMessage = Detours:DetourHook(lib, UIErrorsFrame, "AddMessage", function(self, ...)
    if (skip_error) then
        skip_error = false
        local msg = ...
        if (msg == ERR_UNIT_NOT_FOUND or msg == ERR_INVALID_INSPECT_TARGET or msg == ERR_OUT_OF_RANGE) then
            if (GetCVar("Sound_EnableErrorSpeech") == "1") then
                skip_error = true
            end
            return nil
        end
    end
    return oAddMessage(self, ...)
end)

local oPlayVocalErrorSoundID
oPlayVocalErrorSoundID = Detours:DetourHook(lib, "PlayVocalErrorSoundID", function(vocalErrorSoundID, ...)
    if (vocalErrorSoundID == 10 and skip_error == true) then
        skip_error = false
        return nil
    end
    return oPlayVocalErrorSoundID(vocalErrorSoundID, ...)
end)


--------------------------------------------------------------------------
--
--  LIBRARY FUNCTIONS
--
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- ClassicInspector:IsClassic()
--
--  Returns
--     @boolean isClassic          - client version is Classic "Vanilla": Means Classic Era and its seasons like SoM (1.x.x)
--
function lib:IsClassic()
    return isClassic
end


--------------------------------------------------------------------------
-- ClassicInspector:IsTBC()
--
--  Returns
--     @boolean isTBC              - client version is Classic TBC (2.x.x)
--
function lib:IsTBC()
    return isTBC
end


--------------------------------------------------------------------------
-- ClassicInspector:IsWotlk()
--
--  Returns
--     @boolean isWotlk            - client version is Classic Wotlk (3.x.x)
--
function lib:IsWotlk()
    return isWotlk
end


--------------------------------------------------------------------------
-- ClassicInspector:CanInspect(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid of target to check
--
--  Returns
--     @boolean canInspect         - can target unit be inspected
--
function lib:CanInspect(unitorguid)
    if ((not unitorguid) or InCombatLockdown()) then return false end
    local unit
    if (GUIDIsPlayer(unitorguid)) then
        unit = lib:PlayerGUIDToUnitToken(unitorguid)
    elseif (UnitIsPlayer(unitorguid)) then
        unit = unitorguid
    end
    return unit and UnitExists(unit) and UnitIsConnected(unit) and (not UnitIsDeadOrGhost(unit)) and (not UnitIsUnit(unit, "player")) and CheckInteractDistance(unit, 1) and (not InspectFrame or not InspectFrame:IsShown()) and CanInspect(unit, false)
end


--------------------------------------------------------------------------
-- ClassicInspector:DoInspect(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid of inspection target
--
--  Returns
--     @number status              - inspection status
--                                   == 0 : target cannot be inspected
--                                   == 1 : instant inspection 
--                                   == 2 : queued inspection
--
function lib:DoInspect(unitorguid)
    if (not unitorguid) then return nil end
    local unit, guid
    if (GUIDIsPlayer(unitorguid)) then
        unit = lib:PlayerGUIDToUnitToken(unitorguid)
        guid = unitorguid
    elseif (UnitIsPlayer(unitorguid)) then
        unit = unitorguid
        guid = UnitGUID(unit)
    end
    if (lib:CanInspect(unit)) then
        if (GetTime() >= nextInspectTime) then
            NotifyInspect(unit)
            if (isWotlk) then
                tryCompare(unit)
            end
            return 1
        else
            local c = #queue
            if (c > 0) then
                for i=1,c do
                    if (queue[i] == guid) then
                        return 2
                    end
                end
                if (c >= INSPECTOR_MAX_QUEUE) then
                    table.remove(queue, 1)
                end
            end
            table.insert(queue, guid)
            return 2
        end
    end
    return 0
end


--------------------------------------------------------------------------
-- ClassicInspector:GetLastCacheTime(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--
--  Returns
--     @number talentsTime         - time when talents were last cached or 0 if not found
--     @number inventoryTime       - time when inventory was last cached or 0 if not found
--     @number achievementsTime    - time when achievements were last cached or 0 if not found
--     @number glyphsTime          - time when glyphs were last cached or 0 if not found
--
function lib:GetLastCacheTime(unitorguid)
    local user = getCacheUser2(getPlayerGUID(unitorguid))
    if (user) then
        return user.talents.time, user.inventory.time, user.achievements.time, user.glyphs.time
    end
    return 0, 0, 0, 0
end


--------------------------------------------------------------------------
-- ClassicInspector:GetSpecializationName(class, tabIndex, localized)
--
--  Parameters
--     @string class               - english class name in uppercase e.g. "WARRIOR"
--     @number tabIndex            - talent tab index (1-3)
--     @boolean localized          - return localized name instead of english name
--
--  Returns
--     @string specName            - specialization name e.g. "Retribution"
--
function lib:GetSpecializationName(class, tabIndex, localized)
    assert(class == "WARRIOR" or class == "PALADIN" or class == "HUNTER" or class == "ROGUE" or class == "PRIEST" or class == "SHAMAN" or 
           class == "MAGE" or class == "WARLOCK" or class == "DRUID" or (isWotlk and class == "DEATHKNIGHT"), "invalid class")
    local n = tonumber(tabIndex) or 0
    assert(n > 0 and n < 4, "tabIndex is not a valid number (1-3)")
    return localized and spec_table_localized[class][tabIndex] or spec_table[class][tabIndex]
end


--------------------------------------------------------------------------
-- ClassicInspector:GetNumTalentsByClass(class, tabIndex)
--
--  Parameters
--     @string class               - english class name in uppercase e.g. "WARRIOR"
--     @number tabIndex            - talent tab index (1-3)
--
--  Returns
--     @number numTalents          - number of talents in tab
--
function lib:GetNumTalentsByClass(class, tabIndex)
    assert(class == "WARRIOR" or class == "PALADIN" or class == "HUNTER" or class == "ROGUE" or class == "PRIEST" or class == "SHAMAN" or 
           class == "MAGE" or class == "WARLOCK" or class == "DRUID" or (isWotlk and class == "DEATHKNIGHT"), "invalid class")
    local n = tonumber(tabIndex) or 0
    assert(n > 0 and n < 4, "tabIndex is not a valid number (1-3)")
    return #talents_table[class][tabIndex]
end


--------------------------------------------------------------------------
-- ClassicInspector:GetSpecialization(unitorguid[, group])
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number [group]             - talent group or the current active talent group if nil
--
--  Returns
--     @number specIndex           - main specialization index (1-3)
--     @number pointsSpent         - talent points spent to the main spec
--
function lib:GetSpecialization(unitorguid, _group)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil, 0
    end
    if (not _group) then
        _group = lib:GetActiveTalentGroup(guid)
        if (not _group) then
            return nil, 0
        end
    end
    local group = tonumber(_group) or 0
    assert(group == 1 or group == 2, "group is not a valid number (1-2)")
    if (not isWotlk and group == 2) then
        return nil, 0
    end
    local mostPoints = 0
    local specIndex = nil
    if (guid == UnitGUID("player")) then
        for i = 1, 3 do  -- GetNumTalentTabs
            local points = 0
            for j = 1, GetNumTalents(i, false, false) do
                points = points + select(5, GetTalentInfo(i, j, false, false, group))
            end
            if (points > mostPoints) then
                mostPoints = points
                specIndex = i
            end
        end
    else
        local user = getCacheUser2(guid)
        if (user and user.talents.time ~= 0) then
            for i = 1, 3 do  -- GetNumTalentTabs
                local points = 0
                for _, v in ipairs(user.talents[group][i]) do
                    points = points + v
                end
                if (points > mostPoints) then
                    mostPoints = points
                    specIndex = i
                end
            end
        end
    end
    return specIndex, mostPoints
end


--------------------------------------------------------------------------
-- ClassicInspector:GetTalentPoints(unitorguid[, group])
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number [group]             - talent group or the current active talent group if nil
--
--  Returns
--     @number pointsSpent1        - talent points spent to tab 1
--     @number pointsSpent2        - talent points spent to tab 2
--     @number pointsSpent3        - talent points spent to tab 3
--
function lib:GetTalentPoints(unitorguid, _group)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (not _group) then
        _group = lib:GetActiveTalentGroup(guid)
        if (not _group) then
            return nil
        end
    end
    local group = tonumber(_group) or 0
    assert(group == 1 or group == 2, "group is not a valid number (1-2)")
    if (not isWotlk and group == 2) then
        return nil
    end
    local talents = {0, 0, 0}
    if (guid == UnitGUID("player")) then
        for i = 1, 3 do  -- GetNumTalentTabs
            for j = 1, GetNumTalents(i, false, false) do
                talents[i] = talents[i] + select(5, GetTalentInfo(i, j, false, false, group))
            end
        end
        return unpack(talents)
    else
        local user = getCacheUser2(guid)
        if (user and user.talents.time ~= 0) then
            for i = 1, 3 do  -- GetNumTalentTabs
                for _, v in ipairs(user.talents[group][i]) do
                    talents[i] = talents[i] + v
                end
            end
            return unpack(talents)
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetActiveTalentGroup(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--
--  Returns
--     @number group               - active talent group (1-2)
--
function lib:GetActiveTalentGroup(unitorguid)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (guid == UnitGUID("player")) then
        return isWotlk and GetActiveTalentGroup(false, false) or 1
    else
        local user = getCacheUser2(guid)
        if (user and user.talents["active"] > 0) then
            return user.talents["active"]
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetTalentInfo(unitorguid, tabIndex, talentIndex[, group])
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number tabIndex            - talent tab index (1-3)
--     @number talentIndex         - ranging from 1 to GetNumTalents(tabIndex). counted from left to right, top to bottom.
--     @number [group]             - talent group or the current active talent group if nil
--
--  Returns
--     @string name                - name of the talent
--     @number iconTexture         - fileID of icon texture
--     @number tier                - the row/tier that the talent sits on
--     @number column              - the column that the talent sits on
--     @number rank                - the current amount of talent points for a talent
--     @number maxRank             - the maximum amount of talent points for a talent
--     @number isExceptional       - 1 if the talent is the ultimate talent, e.g. Lightwell, otherwise returns nil
--     @number available           - always 1
--     @number talentID            - talent ID
--
function lib:GetTalentInfo(unitorguid, tabIndex, talentIndex, _group)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    tabIndex = tonumber(tabIndex) or 0
    assert(tabIndex > 0 and tabIndex < 4, "tabIndex is not a valid number (1-3)")
    talentIndex = tonumber(talentIndex) or 0
    assert(talentIndex > 0 and talentIndex <= MAX_TALENTS_PER_TAB, "talentIndex is not a valid number")
    if (not _group) then
        _group = lib:GetActiveTalentGroup(guid)
        if (not _group) then
            return nil
        end
    end
    local group = tonumber(_group) or 0
    assert(group == 1 or group == 2, "group is not a valid number (1-2)")
    local _, class = GetPlayerInfoByGUID(guid)
    if (not class or (not isWotlk and group == 2)) then
        return nil
    end
    if (guid == UnitGUID("player")) then
        local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex, false, false, group)
        return name, iconTexture, tier, column, rank, maxRank, isExceptional, available, talents_table[class][tabIndex][talentIndex].id
    else
        local user = getCacheUser2(guid)
        if (user and user.talents.time ~= 0) then
            local talent = talents_table[class][tabIndex][talentIndex]
            return talent.name, talent.texture, talent.tier, talent.column, user.talents[group][tabIndex][talentIndex] or 0, talent.maxRank, talent.isExceptional, talent.available, talent.id
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetTalentInfoByClass(class, tabIndex, talentIndex)
--
--  Parameters
--     @string class               - english class name in uppercase e.g. "WARRIOR"
--     @number tabIndex            - talent tab index (1-3)
--     @number talentIndex         - ranging from 1 to GetNumTalents(tabIndex). counted from left to right, top to bottom.
--
--  Returns
--     @string name                - name of the talent
--     @number iconTexture         - fileID of icon texture
--     @number tier                - the row/tier that the talent sits on
--     @number column              - the column that the talent sits on
--     @number rank                - always 0
--     @number maxRank             - the maximum amount of talent points for a talent
--     @number isExceptional       - 1 if the talent is the ultimate talent, e.g. Lightwell, otherwise returns nil
--     @number available           - always 1
--     @number talentID            - talent ID
--
function lib:GetTalentInfoByClass(class, tabIndex, talentIndex)
    assert(class == "WARRIOR" or class == "PALADIN" or class == "HUNTER" or class == "ROGUE" or class == "PRIEST" or class == "SHAMAN" or 
           class == "MAGE" or class == "WARLOCK" or class == "DRUID" or (isWotlk and class == "DEATHKNIGHT"), "invalid class")
    tabIndex = tonumber(tabIndex) or 0
    assert(tabIndex > 0 and tabIndex < 4, "tabIndex is not a valid number (1-3)")
    talentIndex = tonumber(talentIndex) or 0
    assert(talentIndex > 0 and talentIndex <= MAX_TALENTS_PER_TAB, "talentIndex is not a valid number")
    local talent = talents_table[class][tabIndex][talentIndex]
    return talent.name, talent.texture, talent.tier, talent.column, 0, talent.maxRank, talent.isExceptional, talent.available, talent.id
end


--------------------------------------------------------------------------
-- ClassicInspector:GetInventoryItemID(unitorguid, slot)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number inventorySlot       - inventory slot (1-19)
--
--  Returns
--     @number itemID              - inventory item id
--
function lib:GetInventoryItemID(unitorguid, slot)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    local n = tonumber(slot) or 0
    assert(n > 0 and n < 20, "inventorySlot is not a valid number (1-19)")
    if (guid == UnitGUID("player")) then
        local itemID = GetInventoryItemID("player", n)
        return itemID
    else
        local user = getCacheUser2(guid)
        if (user and user.inventory.time ~= 0) then
            return user.inventory[n]
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetInventoryItemLink(unitorguid, slot)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number inventorySlot       - inventory slot (1-19)
--
--  Returns
--     @string itemLink            - inventory item link (can return nil if item is not cached yet)
--
function lib:GetInventoryItemLink(unitorguid, slot)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    local n = tonumber(slot) or 0
    assert(n > 0 and n < 20, "inventorySlot is not a valid number (1-19)")
    if (guid == UnitGUID("player")) then
        return GetInventoryItemLink("player", n)
    else
        local user = getCacheUser2(guid)
        if (user and user.inventory.time ~= 0) then
            local itemID = user.inventory[n]
            return itemID and select(2, GetItemInfo(itemID))
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetInventoryItemMixin(unitorguid, slot)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number inventorySlot       - inventory slot (1-19)
--
--  Returns
--     @ItemMixin item             - inventory item ItemMixin
--
function lib:GetInventoryItemMixin(unitorguid, slot)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    local n = tonumber(slot) or 0
    assert(n > 0 and n < 20, "inventorySlot is not a valid number (1-19)")
    if (guid == UnitGUID("player")) then
        if (GetInventoryItemID("player", n)) then
            return Item:CreateFromEquipmentSlot(n)
        end
    else
        local user = getCacheUser2(guid)
        if (user and user.inventory.time ~= 0) then
            local itemID = user.inventory[n]
            return itemID and Item:CreateFromItemID(itemID) or nil
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetInventoryItemIDTable(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--
--  Returns
--     @table  inventoryTable      - inventory item id table (1-19)
--
function lib:GetInventoryItemIDTable(unitorguid)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (guid == UnitGUID("player")) then
        local inventory = {}
        for i=1,19 do
            inventory[i] = GetInventoryItemID("player", i)
        end
        return inventory
    else
        local user = getCacheUser2(guid)
        if (user and user.inventory.time ~= 0) then
            local inventory = {}
            for i=1,19 do
                inventory[i] = user.inventory[i]
            end
            return inventory
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetTalentRanksTable(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--
--  Returns
--     @table  talentsTable        - talent ranks table
--
function lib:GetTalentRanksTable(unitorguid)
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (guid == UnitGUID("player")) then
        local talents = {[1] = {[1] = {}, [2] = {}, [3] = {}}, [2] = {[1] = {}, [2] = {}, [3] = {}}}
        for x = 1, (isWotlk and 2 or 1) do
            for i = 1, 3 do  -- GetNumTalentTabs
                for j = 1, GetNumTalents(i, true, false) do
                    talents[x][i][j] = select(5, GetTalentInfo(i, j, true, false, x))
                end
            end
        end
        return talents
    else
        local user = getCacheUser2(guid)
        if (user and user.talents.time ~= 0) then
            local talents = {[1] = {[1] = {}, [2] = {}, [3] = {}}, [2] = {[1] = {}, [2] = {}, [3] = {}}}
            for x = 1, (isWotlk and 2 or 1) do
                for i = 1, 3 do  -- GetNumTalentTabs
                    for k,v in ipairs(user.talents[x][i]) do
                        talents[x][i][k] = v
                    end
                end
            end
            return talents
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:PlayerGUIDToUnitToken(unit)
--
--  Parameters
--     @string guid                - player guid
--
--  Returns
--     @string unit                - player unit token
--
function lib:PlayerGUIDToUnitToken(guid)
    --assert(GUIDIsPlayer(guid), "guid is not a player")
    if (not guid or not GUIDIsPlayer(guid)) then
        return nil
    end
    if (UnitGUID("player") == guid) then
        return "player"
    end
    if (IsInGroup() and IsGUIDInGroup(guid)) then
        if (IsInRaid()) then
            for i=1,40 do
                if (UnitGUID("raid"..i) == guid) then
                    return "raid"..i
                end
            end
        else
            for i=1,4 do
                if (UnitGUID("party"..i) == guid) then
                    return "party"..i
                end
            end
        end
    end
    if (UnitGUID("target") == guid) then
        return "target"
    end
    if (UnitGUID("focus") == guid) then
        return "focus"
    end
    if (UnitGUID("mouseover") == guid) then
        return "mouseover"
    end
    if (GetCVar("nameplateShowFriends") == "1" or GetCVar("nameplateShowEnemies") == "1") then
        local nameplatesArray = C_NamePlate.GetNamePlates()
        for i, nameplate in ipairs(nameplatesArray) do
            if (UnitGUID(nameplate.namePlateUnitToken) == guid) then
                return nameplate.namePlateUnitToken
            end
        end
    end
    if (UnitGUID("targettarget") == guid) then
        return "targettarget"
    end
    if (UnitGUID("focustarget") == guid) then
        return "focustarget"
    end
    if (UnitGUID("mouseovertarget") == guid) then
        return "mouseovertarget"
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetTotalAchievementPoints(unitorguid)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--
--  Returns
--     @number total_points        - total achievement points
--
function lib:GetTotalAchievementPoints(unitorguid)
    if (not isWotlk) then
        return nil
    end
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (guid == UnitGUID("player")) then
        return GetTotalAchievementPoints()
    else
        local user = getCacheUser2(guid)
        if (user and user.achievements.time > 0) then
            return user.achievements["t_pts"]
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetAchievementInfo(unitorguid, achievementID)
--
--  Parameters
--     @string  unitorguid         - unit token or guid
--     @number  achievementID      - achievement ID (type=achievement)
--
--  Returns
--     @boolean completed          - is achievement completed
--     @number  month              - month of completion
--     @number  day                - day of completion
--     @number  year               - year of completion
--
function lib:GetAchievementInfo(unitorguid, achievementID)
    if (not isWotlk) then
        return nil
    end
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    local id = tonumber(achievementID) or 0
    assert(id > 0, "achievementID is not a valid number")
    if (not tracked_achievements[id]) then
        assert(select(15,GetAchievementInfo(id))==false, "achievementID is not a valid achievement ID")
        tracked_achievements[id] = 0
    end
    assert(tracked_achievements[id]==0, "achievementID is not a valid achievement ID")
    if (guid == UnitGUID("player")) then
        local _, _, _, completed, month, day, year = GetAchievementInfo(id)
        return completed, month, day, year
    else
        local user = getCacheUser2(guid)
        if (user and user.achievements.time > 0 and user.achievements[id]) then
            return unpack(user.achievements[id])
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetStatistic(unitorguid, achievementID)
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number achievementID       - achievement ID (type=statistic)
--
--  Returns
--     @string value               - value of the statistic as displayed in-game
--
function lib:GetStatistic(unitorguid, achievementID)
    if (not isWotlk) then
        return nil
    end
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    local id = tonumber(achievementID) or 0
    assert(id > 0, "achievementID is not a valid number")
    if (not tracked_achievements[id]) then
        assert(select(15,GetAchievementInfo(id)), "achievementID is not a valid statistic ID")
        tracked_achievements[id] = 1
    end
    assert(tracked_achievements[id]==1, "achievementID is not a valid statistic ID")
    if (guid == UnitGUID("player")) then
        local s = GetStatistic(id)
        return s
    else
        local user = getCacheUser2(guid)
        if (user and user.achievements.time > 0) then
            return user.achievements[id]
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:AddTrackedAchievement(achievementID)
--
--  Parameters
--     @number  achievementID      - achievement ID (type=achievement/statistic)
--
--  Returns
--     @boolean success            - achievementID is valid and added to tracking list
--     @boolean isStatistic        - is achievement type a statistic
--
function lib:AddTrackedAchievement(achievementID)
    if (not isWotlk) then
        return nil
    end
    local id = tonumber(achievementID) or 0
    assert(id > 0, "achievementID is not a valid number")
    if (not tracked_achievements[id]) then
        local type = select(15,GetAchievementInfo(id))
        assert(type ~= nil, "achievementID is not a valid achievement ID")
        tracked_achievements[id] = type and 1 or 0
    end
    return true, tracked_achievements[id]==1
end


--------------------------------------------------------------------------
-- ClassicInspector:GetGlyphSocketInfo(unitorguid, socketID[, group])
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number socketID            - socket index to query, ranging from 1 to 6 (NUM_GLYPH_SLOTS)
--     @number [group]             - talent group or the current active talent group if nil
--
--  Returns
--     @boolean enabled            - true if the socket has a glyph inserted
--     @number glyphType           - type of glyph accepted by this socket (GLYPHTYPE_MAJOR=1 or GLYPHTYPE_MINOR=2)
--     @number glyphSpellID        - spell ID of the socketed glyph
--     @number iconFile            - file ID of the sigil icon associated with the socketed glyph
--
function lib:GetGlyphSocketInfo(unitorguid, socketID, _group)
    if (not isWotlk) then
        return nil
    end
    local n = tonumber(socketID) or 0
    assert(n >= 1 and n <= 6, "socketID is not a valid number")    
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (not _group) then
        _group = lib:GetActiveTalentGroup(guid)
        if (not _group) then
            return nil
        end
    end
    local group = tonumber(_group) or 0
    assert(group == 1 or group == 2, "group is not a valid number (1-2)")
    local _, class = GetPlayerInfoByGUID(guid)
    if (not class) then
        return nil
    end    
    if (guid == UnitGUID("player")) then
        return GetGlyphSocketInfo(n, group)
    else
        local user = getCacheUser2(guid)
        if (user and user.glyphs.time > 0) then
            local enabled = false
            local glyphType, glyphSpellID
            if (n == 1 or n == 4 or n == 6) then
                glyphType = 1 -- GLYPHTYPE_MAJOR
            else
                glyphType = 2 -- GLYPHTYPE_MINOR
            end
            local x = user.glyphs[(group==1) and n or (n+6)]
            if (x > 0) then
                glyphSpellID = glyphs_table[class][glyphType][x]
                enabled = true
            end
            return enabled, glyphType, glyphSpellID, 0
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:HasGlyph(unitorguid, glyphSpellID[, group])
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number glyphSpellID        - spell ID of the socketed glyph
--     @number [group]             - talent group or the current active talent group if nil
--
--  Returns
--     @boolean enabled            - true if the player has socketed glyph with matching ID
--
function lib:HasGlyph(unitorguid, glyphSpellID, _group)
    if (not isWotlk) then
        return nil
    end
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (not _group) then
        _group = lib:GetActiveTalentGroup(guid)
        if (not _group) then
            return nil
        end
    end
    local group = tonumber(_group) or 0
    assert(group == 1 or group == 2, "group is not a valid number (1-2)")
    local _, class = GetPlayerInfoByGUID(guid)
    if (not class) then
        return nil
    end    
    if (guid == UnitGUID("player")) then
        for i=1,6 do
            local enabled, _, id = GetGlyphSocketInfo(i, group)
            if (enabled and id) then
                if (id == 55115) then id = 54929 end
                if (id == glyphSpellID) then
                    return true
                end
            end
        end
        return false
    else
        local user = getCacheUser2(guid)
        if (user and user.glyphs.time > 0) then
            for i=1,6 do
                local x = user.glyphs[(group==1) and i or (i+6)]
                if (x > 0) then
                    if (i == 1 or i == 4 or i == 6) then
                        if (glyphs_table[class][1][x] == glyphSpellID) then
                            return true
                        end
                    else
                        if (glyphs_table[class][2][x] == glyphSpellID) then
                            return true
                        end
                    end
                end
            end
            return false
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:GetGlyphs(unitorguid[, group])
--
--  Parameters
--     @string unitorguid          - unit token or guid
--     @number [group]             - talent group or the current active talent group if nil
--
--  Returns
--     @number glyphSpellID1       - spell ID of glyph in socket 1 (MAJOR)
--     @number glyphSpellID2       - spell ID of glyph in socket 2 (MINOR)
--     @number glyphSpellID3       - spell ID of glyph in socket 3 (MINOR)
--     @number glyphSpellID4       - spell ID of glyph in socket 4 (MAJOR)
--     @number glyphSpellID5       - spell ID of glyph in socket 5 (MINOR)
--     @number glyphSpellID6       - spell ID of glyph in socket 6 (MAJOR)
--
function lib:GetGlyphs(unitorguid, _group)
    if (not isWotlk) then
        return nil
    end
    local guid = getPlayerGUID(unitorguid)
    if (not guid) then
        return nil
    end
    if (not _group) then
        _group = lib:GetActiveTalentGroup(guid)
        if (not _group) then
            return nil
        end
    end
    local group = tonumber(_group) or 0
    assert(group == 1 or group == 2, "group is not a valid number (1-2)")
    local _, class = GetPlayerInfoByGUID(guid)
    if (not class) then
        return nil
    end
    local glyphs = {}
    if (guid == UnitGUID("player")) then
        for i=1,6 do
            local enabled, _, id = GetGlyphSocketInfo(i, group)
            if (enabled and id) then
                if (id == 55115) then id = 54929 end
                glyphs[i] = id
            else
                glyphs[i] = 0
            end
        end
        return unpack(glyphs)
    else
        local user = getCacheUser2(guid)
        if (user and user.glyphs.time > 0) then
            for i=1,6 do
                local x = user.glyphs[(group==1) and i or (i+6)]
                if (x == 0) then
                    glyphs[i] = 0
                else
                    if (i == 1 or i == 4 or i == 6) then
                        if (glyphs_table[class][1][x]) then
                            glyphs[i] = glyphs_table[class][1][x]
                        end
                    else
                        if (glyphs_table[class][2][x]) then
                            glyphs[i] = glyphs_table[class][2][x]
                        end
                    end
                end
            end
            return unpack(glyphs)
        end
    end
    return nil
end


--------------------------------------------------------------------------
-- ClassicInspector:Version()
--
--  Returns
--     @number version             - library version
--
function lib:Version()
    return LCI_VERSION
end