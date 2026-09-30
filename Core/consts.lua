---@class GW2
local GW = select(2, ...)

GW.WINDOW_FADE_DURATION = 0.2

GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE = "GW2_UI_2_DEFAULT"

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
    dead = { l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1 },
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

GW.INDICATORS = { "BAR", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT" }
GW.indicatorsText = { "Bar", "Top Left", "Top", "Top Right", "Left", "Center", "Right" }

GW.cooldownNumberFormatter = nil
if C_StringUtil and C_StringUtil.CreateNumericRuleFormatter then
    GW.cooldownNumberFormatter = C_StringUtil.CreateNumericRuleFormatter()
    GW.cooldownNumberFormatter:SetBreakpoints({
        {
            threshold = 0, -- seconds
            format = "%ds",
            step = 1,
            rounding = Enum.NumericRuleFormatRounding.Floor,
        },
        {
            threshold = 60, -- minute
            format = "%.0fm",
            components = {
                {
                    div = 60,
                    step = 1,
                    rounding = Enum.NumericRuleFormatRounding.Nearest,
                },
            }
        },
        {
            threshold = 3600, -- 1 hour
            format = "%.0fh",
            components = {
                {
                    div = 3600,
                    step = 1,
                    rounding = Enum.NumericRuleFormatRounding.Nearest,
                },
            }
        },
        {
            threshold = 86400, -- 1 day
            format = "%.0fd",
            components = {
                {
                    div = 86400,
                    step = 1,
                    rounding = Enum.NumericRuleFormatRounding.Nearest,
                },
            }
        },
    });
end

-- Buffs the group frame indicators can watch, per class. Each entry is a palette color and the
-- spell ids it covers (on classic clients every rank is its own id); sameSlot lists more ids
-- the same indicator also shows.
local IC = GW.Colors.IndicatorColors

local function Indicator(color, sameSlot)
    return { color = color, sameSlot = sameSlot }
end

local function Indicators(entries)
    local list = {}
    for _, entry in ipairs(entries) do
        for i = 2, #entry do
            list[entry[i]] = Indicator(entry[1], entry.sameSlot)
        end
    end
    return list
end

if GW.Retail then
    GW.AURAS_INDICATORS = {
        EVOKER = Indicators({
            -- All
            { IC.Cyan, 381748, sameSlot = { 381732, 381741, 381746, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758, 432652, 432658 } }, -- Blessing of the Bronze
            -- Preservation
            { IC.Purple, 355941 }, -- Dream Breath
            { IC.Purple, 376788 }, -- Dream Breath (echo)
            { IC.Purple, 363502 }, -- Dream Flight
            { IC.Cyan, 366155 }, -- Reversion
            { IC.Teal, 367364 }, -- Reversion (echo)
            { IC.Red, 373267 }, -- Life Bind (Verdant Embrace)
            { IC.Mint, 364343 }, -- Echo
            -- Augmentation
            { IC.Purple, 360827 }, -- Blistering Scales
            { IC.Mint, 410089 }, -- Prescience
            { IC.Orange, 395152 }, -- Ebon Might
            { IC.Mint, 410263 }, -- Inferno's Blessing
            { IC.Cyan, 410686 }, -- Symbiotic Bloom
            { IC.Cyan, 413984 }, -- Shifting Sands
            { IC.Grey, 369459 }, -- Source of Magic
        }),
        PRIEST = Indicators({
            -- All
            { IC.Cyan, 21562 }, -- Power Word: Fortitude
            -- Discipline
            { IC.Yellow, 194384 }, -- Atonement
            { IC.Grey, 17 }, -- Power Word: Shield
            { IC.Red, 1253593 }, -- Void Shield
            -- Holy
            { IC.Green, 41635 }, -- Prayer of Mending
            { IC.Green, 139 }, -- Renew
            { IC.Lime, 77489 }, -- Echo of Light
        }),
        DRUID = Indicators({
            -- All
            { IC.Cyan, 1126 }, -- Mark of the Wild
            { IC.Grey, 474754 }, -- Symbiotic Relationship
            -- Restoration
            { IC.Pink, 774 }, -- Rejuvenation
            { IC.Green, 33763 }, -- Lifebloom
            { IC.Orange, 48438 }, -- Wild Growth
            { IC.Green, 8936 }, -- Regrowth
            { IC.Pink, 155777 }, -- Germination
        }),
        PALADIN = Indicators({
            -- Holy
            { IC.Pink, 53563 }, -- Beacon of Light
            { IC.Pink, 156910 }, -- Beacon of Faith
            { IC.Pink, 200025 }, -- Beacon of Virtue
            { IC.Green, 156322 }, -- Eternal Flame
            { IC.Green, 1244893 }, -- Beacon of the Savior
        }),
        SHAMAN = Indicators({
            -- All
            { IC.Cyan, 462854 }, -- Skyfury
            -- Restoration
            { IC.Pink, 61295 }, -- Riptide
            { IC.Yellow, 974 }, -- Earth Shield
            { IC.Yellow, 383648 }, -- Earth Shield (Elemental Orbit)
            { IC.Purple, 207400 }, -- Ancestral Vigor
            { IC.Yellow, 382024 }, -- Earthliving Weapon
            { IC.Yellow, 444490 }, -- Hydrobubble
        }),
        MONK = Indicators({
            -- Mistweaver
            { IC.Teal, 115175 }, -- Soothing Mist
            { IC.Teal, 119611 }, -- Renewing Mist
            { IC.Teal, 450769 }, -- Aspect of Harmony (Modified version of Renewing Mist)
            { IC.Lime, 124682 }, -- Enveloping Mist
        }),
        MAGE = Indicators({
            { IC.Cyan, 1459 }, -- Arcane Intellect
        }),
        WARRIOR = Indicators({
            { IC.Cyan, 6673 }, -- Battle Shout
        }),
        -- Not used for now
        WARLOCK = {},
        ROGUE = {},
        HUNTER = {},
        DEMONHUNTER = {},
        DEATHKNIGHT = {},
    }
elseif GW.Classic then
    GW.AURAS_INDICATORS = {
        PRIEST = Indicators({
            { IC.Yellow, 10937 }, -- Power Word: Fortitude Rank 5
            { IC.Yellow, 10938 }, -- Power Word: Fortitude Rank 6
            { IC.Yellow, 21564 }, -- Prayer of Fortitude Rank 2
            { IC.Green, 14819 }, -- Divine Spirit Rank 3
            { IC.Green, 27841 }, -- Divine Spirit Rank 4
            { IC.Green, 27581 }, -- Prayer of Spirit Rank 1
            { IC.Grey, 10957 }, -- Shadow Protection Rank 2
            { IC.Grey, 10958 }, -- Shadow Protection Rank 3
            { IC.Grey, 27683 }, -- Prayer of Shadow Protection Rank 1
            { IC.Blue, 10898 }, -- Power Word: Shield Rank 7
            { IC.Blue, 10899 }, -- Power Word: Shield Rank 8
            { IC.Blue, 10900 }, -- Power Word: Shield Rank 9
            { IC.Blue, 10901 }, -- Power Word: Shield Rank 10
            { IC.Teal, 10927 }, -- Renew Rank 7
            { IC.Teal, 10928 }, -- Renew Rank 8
            { IC.Teal, 10929 }, -- Renew Rank 9
            { IC.Teal, 25315 }, -- Renew Rank 10
        }),
        DRUID = Indicators({
            { IC.Teal, 8907 }, -- Mark of the Wild Rank 5
            { IC.Teal, 9884 }, -- Mark of the Wild Rank 6
            { IC.Teal, 16878 }, -- Mark of the Wild Rank 7
            { IC.Grey, 21849 }, -- Gift of the Wild Rank 1
            { IC.Teal, 21850 }, -- Gift of the Wild Rank 2
            { IC.Purple, 8914 }, -- Thorns Rank 4
            { IC.Purple, 9756 }, -- Thorns Rank 5
            { IC.Purple, 9910 }, -- Thorns Rank 6
            { IC.Lime, 9839 }, -- Rejuvenation Rank 8
            { IC.Lime, 9840 }, -- Rejuvenation Rank 9
            { IC.Lime, 9841 }, -- Rejuvenation Rank 10
            { IC.Lime, 25299 }, -- Rejuvenation Rank 11
            { IC.Teal, 9856 }, -- Regrowth  Rank 7
            { IC.Teal, 9857 }, -- Regrowth  Rank 8
            { IC.Teal, 9858 }, -- Regrowth  Rank 9
            { IC.Grey, 29166 }, -- Innervate
        }),
        PALADIN = Indicators({
            { IC.Orange, 1044 }, -- Blessing of Freedom
            { IC.Pink, 6940, 20729 }, -- Blessing Sacrifice Rank 1
            { IC.Green, 19837 }, -- Blessing of Might Rank 5
            { IC.Green, 19838 }, -- Blessing of Might Rank 6
            { IC.Green, 25291 }, -- Blessing of Might Rank 7
            { IC.Green, 19854 }, -- Blessing of Wisdom Rank 5
            { IC.Green, 25290 }, -- Blessing of Wisdom Rank 6
            { IC.Green, 25916 }, -- Greater Blessing of Might Rank 2
            { IC.Green, 25918 }, -- Greater Blessing of Wisdom Rank 2
            { IC.Lime, 10293 }, -- Devotion Aura Rank 7
            { IC.Mint, 19978 }, -- Blessing of Light Rank 2
            { IC.Mint, 19979 }, -- Blessing of Light Rank 3
            { IC.Mint, 5599 }, -- Blessing of Protection Rank 2
            { IC.Mint, 10278 }, -- Blessing of Protection Rank 3
            { IC.Lime, 19746 }, -- Concentration Aura
        }),
        SHAMAN = Indicators({
            { IC.Pink, 29203 }, -- Healing Way
            { IC.Blue, 16237 }, -- Ancestral Fortitude
            { IC.Navy, 25909 }, -- Tranquil Air
            { IC.Mint, 10534 }, -- Fire Resistance Totem Rank 2
            { IC.Mint, 10535 }, -- Fire Resistance Totem Rank 3
            { IC.Grey, 10476 }, -- Frost Resistance Totem Rank 2
            { IC.Grey, 10477 }, -- Frost Resistance Totem Rank 3
            { IC.Green, 10598 }, -- Nature Resistance Totem Rank 2
            { IC.Green, 10599 }, -- Nature Resistance Totem Rank 3
            { IC.Lime, 10460 }, -- Healing Stream Totem Rank 4
            { IC.Lime, 10461 }, -- Healing Stream Totem Rank 5
            { IC.Yellow, 17355 }, -- Mana Tide Totem Rank 2
            { IC.Yellow, 17360 }, -- Mana Tide Totem Rank 3
            { IC.Yellow, 10493 }, -- Mana Spring Totem Rank 3
            { IC.Yellow, 10494 }, -- Mana Spring Totem Rank 4
            { IC.Navy, 10403 }, -- Stoneskin Totem Rank 4
            { IC.Navy, 10404 }, -- Stoneskin Totem Rank 5
            { IC.Navy, 10405 }, -- Stoneskin Totem Rank 6
        }),
        ROGUE = {}, --No buffs
        WARRIOR = Indicators({
            { IC.Blue, 11551 }, -- Battle Shout Rank 6
            { IC.Blue, 25289 }, -- Battle Shout Rank 7
        }),
        HUNTER = Indicators({
            { IC.Red, 19506 }, -- Trueshot Aura Rank 1
            { IC.Red, 20905 }, -- Trueshot Aura Rank 2
            { IC.Red, 20906 }, -- Trueshot Aura Rank 3
        }),
        WARLOCK = Indicators({
            { IC.Red, 5597 }, -- Unending Breath
            { IC.Green, 6512 }, -- Detect Lesser Invisibility
            { IC.Green, 2970, 11743 }, -- Detect Invisibility
        }),
        MAGE = Indicators({
            { IC.Red, 10157 }, -- Arcane Intellect Rank 5
            { IC.Red, 27127 }, -- Arcane Brilliance Rank 2
            { IC.Green, 10174 }, -- Dampen Magic Rank 5
            { IC.Green, 10170 }, -- Amplify Magic Rank 4
            { IC.Navy, 12438 }, -- Slow Fall
        })
    }

    if GW.ClassicSOD then
        GW.AURAS_INDICATORS.DRUID[408120] = Indicator(IC.Navy) -- Wild Growth
        GW.AURAS_INDICATORS.MAGE[400735] = Indicator(IC.Navy) -- Temporal Beacon
        GW.AURAS_INDICATORS.PRIEST[401877] = Indicator(IC.Blue) -- Prayer of Mending
        GW.AURAS_INDICATORS.PRIEST[402004] = Indicator(IC.Blue) -- Pain Suppression
    end
elseif GW.Mists then
    GW.AURAS_INDICATORS = {
        PRIEST = Indicators({
            { IC.Blue, 17 }, -- Power Word: Shield
            { IC.Teal, 139 }, -- Renew
            { IC.Red, 6788 }, -- Weakened Soul
            { IC.Green, 41635 }, -- Prayer of Mending
            { IC.Mint, 10060 }, -- Power Infusion
            { IC.Mint, 47788 }, -- Guardian Spirit
            { IC.Mint, 33206 }, -- Pain Suppression
        }),
        DRUID = Indicators({
            { IC.Purple, 467 }, -- Thorns
            { IC.Lime, 774 }, -- Rejuvenation
            { IC.Teal, 8936 }, -- Regrowth
            { IC.Grey, 29166 }, -- Innervate
            { IC.Grey, 33763 }, -- Lifebloom
            { IC.Orange, 48438 }, -- Wild Growth
        }),
        PALADIN = Indicators({
            { IC.Orange, 1044 }, -- Hand of Freedom
            { IC.Mint, 1038 }, -- Hand of Salvation
            { IC.Red, 6940 }, -- Hand of Sacrifice
            { IC.Mint, 1022 }, -- Hand of Protection
            { IC.Pink, 53563 }, -- Beacon of Light
        }),
        SHAMAN = Indicators({
            { IC.Blue, 16177, sameSlot = { 16236, 16237 } }, -- Ancestral Fortitude
            { IC.Navy, 974 }, -- Earth Shield
            { IC.Pink, 61295 }, -- Riptide
            { IC.Pink, 51945 }, -- Earthliving
        }),
        ROGUE = Indicators({
            { IC.Mint, 57933 }, -- Tricks of the Trade
        }),
        WARRIOR = Indicators({
            { IC.Blue, 3411 }, -- Intervene
            { IC.Purple, 50720 }, -- Vigilance
        }),
        HUNTER = Indicators({
            { IC.Mint, 34477 }, -- Misdirection
        }),
        WARLOCK = Indicators({
            { IC.Red, 5697 }, -- Unending Breath
            { IC.Blue, 20707 }, -- Soulstone
        }),
        MAGE = Indicators({
            { IC.Navy, 130 }, -- Slow Fall
            { IC.Mint, 54646 }, -- Focus Magic
        }),
        DEATHKNIGHT = Indicators({
            { IC.Mint, 49016 }, -- Unholy Frenzy
        }),
        MONK = Indicators({
            { IC.Pink, 119611 }, -- Renewing Mist
            { IC.Green, 116849 }, -- Life Cocoon
            { IC.Orange, 124081 }, -- Zen Sphere
            { IC.Green, 132120 }, -- Enveloping Mist
        }),
    }
elseif GW.TBC then
    GW.AURAS_INDICATORS = {
        PRIEST = Indicators({
            { IC.Yellow, 1243, 1244, 1245, 2791, 10937, 10938, 25389 }, -- Power Word: Fortitude
            { IC.Yellow, 21562, 21564, 25392 }, -- Prayer of Fortitude
            { IC.Green, 14752, 14818, 14819, 27841, 25312 }, -- Divine Spirit
            { IC.Green, 27681, 32999 }, -- Prayer of Spirit
            { IC.Grey, 976, 10957, 10958, 25433 }, -- Shadow Protection
            { IC.Grey, 27683, 39374 }, -- Prayer of Shadow Protection
            { IC.Blue, 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218 }, -- Power Word: Shield
            { IC.Teal, 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, 25221, 25222 }, -- Renew
        }),
        DRUID = Indicators({
            { IC.Teal, 1126, 5232, 6756, 5234, 8907, 9884, 9885, 26990 }, -- Mark of the Wild
            { IC.Teal, 21849, 21850, 26991 }, -- Gift of the Wild
            { IC.Purple, 467, 782, 1075, 8914, 9756, 9910, 26992 }, -- Thorns
            { IC.Lime, 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299, 26981, 26982 }, -- Rejuvenation
            { IC.Teal, 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 26980 }, -- Regrowth
            { IC.Grey, 29166 }, -- Innervate
            { IC.Grey, 33763 }, -- Lifebloom
        }),
        PALADIN = Indicators({
            { IC.Orange, 1044 }, -- Blessing of Freedom
            { IC.Mint, 1038 }, -- Blessing of Salvation
            { IC.Red, 6940, 20729, 27147, 27148 }, -- Blessing Sacrifice
            { IC.Green, 19740, 19834, 19835, 19836, 19837, 19838, 25291, 27140 }, -- Blessing of Might
            { IC.Green, 19742, 19850, 19852, 19853, 19854, 25290, 27142 }, -- Blessing of Wisdom
            { IC.Green, 25782, 25916, 27141 }, -- Greater Blessing of Might
            { IC.Green, 25894, 25918, 27143 }, -- Greater Blessing of Wisdom
            { IC.Lime, 465, 10290, 643, 10291, 1032, 10292, 10293, 27149 }, -- Devotion Aura
            { IC.Mint, 19977, 19978, 19979, 27144 }, -- Blessing of Light
            { IC.Mint, 1022, 5599, 10278 }, -- Blessing of Protection
            { IC.Lime, 19746 }, -- Concentration Aura
            { IC.Lime, 32223 }, -- Crusader Aura
        }),
        SHAMAN = Indicators({
            { IC.Pink, 29203 }, -- Healing Way
            { IC.Blue, 16237 }, -- Ancestral Fortitude
            { IC.Mint, 8185, 10534, 10535, 25563 }, -- Fire Resistance Totem
            { IC.Grey, 8182, 10476, 10477, 25560 }, -- Frost Resistance Totem
            { IC.Green, 10596, 10598, 10599, 25574 }, -- Nature Resistance Totem
            { IC.Lime, 5672, 6371, 6372, 10460, 10461, 25567 }, -- Healing Stream Totem
            { IC.Yellow, 16191, 17355, 17360 }, -- Mana Tide Totem
            { IC.Yellow, 5677, 10491, 10493, 10494, 25570 }, -- Mana Spring Totem
            { IC.Navy, 8072, 8156, 8157, 10403, 10404, 10405, 25508, 25509 }, -- Stoneskin Totem
            { IC.Navy, 974, 32593, 32594 }, -- Earth Shield
        }),
        ROGUE = {}, --No buffs
        WARRIOR = Indicators({
            { IC.Blue, 6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048 }, -- Battle Shout
            { IC.Purple, 469 }, -- Commanding Shout
        }),
        HUNTER = Indicators({
            { IC.Red, 19506, 20905, 20906, 27066 }, -- Trueshot Aura
            { IC.Blue, 13159 }, -- Aspect of the Pack
            { IC.Cyan, 20043, 20190, 27045 }, -- Aspect of the Wild
        }),
        WARLOCK = Indicators({
            { IC.Red, 5597 }, -- Unending Breath
            { IC.Green, 6512 }, -- Detect Lesser Invisibility
            { IC.Green, 2970 }, -- Detect Invisibility
            { IC.Green, 11743 }, -- Detect Greater Invisibility
        }),
        MAGE = Indicators({
            { IC.Red, 1459, 1460, 1461, 10156, 10157, 27126 }, -- Arcane Intellect
            { IC.Red, 23028, 27127 }, -- Arcane Brilliance
            { IC.Green, 604, 8450, 8451, 10173, 10174, 33944 }, -- Dampen Magic
            { IC.Green, 1008, 8455, 10169, 10170, 27130, 33946 }, -- Amplify Magic
            { IC.Navy, 130 }, -- Slow Fall
        })
    }
elseif GW.Wrath then
    GW.AURAS_INDICATORS = {
        PRIEST = Indicators({
            { IC.Yellow, 1243, sameSlot = { 1244, 1245, 2791, 10937, 10938, 25389, 48161 } }, -- Power Word: Fortitude
            { IC.Yellow, 21562, sameSlot = { 21564, 25392, 48162 } }, -- Prayer of Fortitude
            { IC.Green, 14752, sameSlot = { 14818, 14819, 27841, 25312, 48073 } }, -- Divine Spirit
            { IC.Green, 27681, sameSlot = { 32999, 48074 } }, -- Prayer of Spirit
            { IC.Grey, 976, sameSlot = { 10957, 10958, 25433, 48169 } }, -- Shadow Protection
            { IC.Grey, 27683, sameSlot = { 39374, 48170 } }, -- Prayer of Shadow Protection
            { IC.Blue, 17, sameSlot = { 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218, 48065, 48066 } }, -- Power Word: Shield
            { IC.Teal, 139, sameSlot = { 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, 25221, 25222, 48067, 48068 } }, -- Renew
            { IC.Red, 6788 }, -- Weakened Soul
        }),
        DRUID = Indicators({
            { IC.Teal, 1126, sameSlot = { 5232, 6756, 5234, 8907, 9884, 9885, 26990, 48469, 21849, 21850, 26991, 48470 } }, -- Mark of the Wild
            { IC.Purple, 467, sameSlot = { 782, 1075, 8914, 9756, 9910, 26992, 53307 } }, -- Thorns
            { IC.Lime, 774, sameSlot = { 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299, 26981, 26982, 48440, 48441 } }, -- Rejuvenation
            { IC.Teal, 8936, sameSlot = { 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 26980, 48442, 48443 } }, -- Regrowth
            { IC.Grey, 29166 }, -- Innervate
            { IC.Grey, 33763, sameSlot = { 48450, 48451 } }, -- Lifebloom
            { IC.Orange, 48438, sameSlot = { 53248, 53249, 53251 } }, -- Wild Growth
        }),
        PALADIN = Indicators({
            { IC.Orange, 1044 }, -- Blessing of Freedom
            { IC.Mint, 1038 }, -- Blessing of Salvation
            { IC.Red, 6940 }, -- Blessing Sacrifice(Rank 1)
            { IC.Mint, 1022, sameSlot = { 5599, 10278 } }, -- Hand of Protection
            { IC.Green, 19740, sameSlot = { 19834, 19835, 19836, 19837, 19838, 25291, 27140, 48931, 48932, 25782, 25916, 27141, 48933, 48934 } }, -- Blessing of Might
            { IC.Green, 19742, sameSlot = { 19850, 19852, 19853, 19854, 25290, 27142, 48935, 48936, 25894, 25918, 27143, 48937, 48938 } }, -- Blessing of Wisdom
            { IC.Lime, 465, sameSlot = { 10290, 643, 10291, 1032, 10292, 10293, 27149, 48941, 48942 } }, -- Devotion Aura
            { IC.Lime, 19746 }, -- Concentration Aura
            { IC.Lime, 32223 }, -- Crusader Aura
            { IC.Pink, 53563 }, -- Beacon of Light
            { IC.Green, 53601 }, -- Sacred Shield
        }),
        SHAMAN = Indicators({
            { IC.Blue, 16177, sameSlot = { 16236, 16237 } }, -- Ancestral Fortitude
            { IC.Mint, 8185, sameSlot = { 10534, 10535, 25563, 58737, 58739 } }, -- Fire Resistance Totem
            { IC.Grey, 8182, sameSlot = { 10476, 10477, 25560, 58741, 58745 } }, -- Frost Resistance Totem
            { IC.Green, 10596, sameSlot = { 10598, 10599, 25574, 58746, 58749 } }, -- Nature Resistance Totem
            { IC.Lime, 5672, sameSlot = { 6371, 6372, 10460, 10461, 25567, 58755, 58756, 58757 } }, -- Healing Stream Totem
            { IC.Yellow, 16191 }, -- Mana Tide Totem
            { IC.Yellow, 5677, sameSlot = { 10491, 10493, 10494, 25569, 58775, 58776, 58777 } }, -- Mana Spring Totem
            { IC.Navy, 8072, sameSlot = { 8156, 8157, 10403, 10404, 10405, 25506, 25507, 58752, 58754 } }, -- Stoneskin Totem
            { IC.Navy, 974, sameSlot = { 32593, 32594, 49283, 49284 } }, -- Earth Shield
            { IC.Navy, 49284 }, -- Earth Shield(Rank 5)
        }),
        ROGUE = {}, --No buffs
        WARRIOR = Indicators({
            { IC.Blue, 6673, sameSlot = { 5242, 6192, 11549, 11550, 11551, 25289, 2048, 47436 } }, -- Battle Shout
            { IC.Green, 469, sameSlot = { 47439, 47440 } }, -- Commanding Shout
        }),
        HUNTER = Indicators({
            { IC.Red, 19506 }, -- Trueshot Aura
            { IC.Blue, 13159 }, -- Aspect of the Pack
            { IC.Cyan, 20043, sameSlot = { 20190, 27045, 49071 } }, -- Aspect of the Wild
        }),
        WARLOCK = Indicators({
            { IC.Red, 5697 }, -- Unending Breath
            { IC.Green, 6512 }, -- Detect Lesser Invisibility
        }),
        MAGE = Indicators({
            { IC.Red, 1459, sameSlot = { 1460, 1461, 10156, 10157, 27126, 42995, 61024, 61316, 23028, 27127, 43002 } }, -- Arcane Intellect
            { IC.Green, 604, sameSlot = { 8450, 8451, 10173, 10174, 33944, 43015 } }, -- Dampen Magic
            { IC.Green, 1008, sameSlot = { 8455, 10169, 10170, 27130, 33946, 43017 } }, -- Amplify Magic
            { IC.Navy, 130 }, -- Slow Fall
        }),
        DEATHKNIGHT = Indicators({
            -- TODO: Hysteria / Unholy Frenzy
        })
    }
elseif GW.Forever then
    GW.AURAS_INDICATORS = {}
end

-- Never show theses auras
if GW.Mists then
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
GW.AURAS_MISSING = {}

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
elseif GW.Wrath then
    GW.ChannelTicks = {
        -- Death Knight
        [42650]	= 8, -- Army of the Dead
        --Druid
        [740]	= 4, -- Tranquility
        [8918]	= 4, -- Tranquility (Rank 2)
        [9862]	= 4, -- Tranquility (Rank 3)
        [9863]	= 4, -- Tranquility (Rank 4)
        [26983]	= 4, -- Tranquility (Rank 5)
        [48446]	= 4, -- Tranquility (Rank 6)
        [48447]	= 4, -- Tranquility (Rank 7)
        [16914]	= 10, -- Hurricane (Rank 1)
        [17401]	= 10, -- Hurricane (Rank 2)
        [17402]	= 10, -- Hurricane (Rank 3)
        [27012]	= 10, -- Hurricane (Rank 4)
        [48467]	= 10, -- Hurricane (Rank 5)
        --Hunter
        [1510]	= 6, -- Volley (Rank 1)
        [14294]	= 6, -- Volley (Rank 2)
        [14295]	= 6, -- Volley (Rank 3)
        [27022]	= 6, -- Volley (Rank 4)
        [58431]	= 6, -- Volley (Rank 5)
        [58434]	= 6, -- Volley (Rank 6)
        -- Mage
        [10]	= 8, -- Blizzard (Rank 1)
        [6141]	= 8, -- Blizzard (Rank 2)
        [8427]	= 8, -- Blizzard (Rank 3)
        [10185]	= 8, -- Blizzard (Rank 4)
        [10186]	= 8, -- Blizzard (Rank 5)
        [10187]	= 8, -- Blizzard (Rank 6)
        [27085]	= 8, -- Blizzard (Rank 7)
        [42939]	= 8, -- Blizzard (Rank 8)
        [42940]	= 8, -- Blizzard (Rank 9)
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
        [38704]	= 5, -- Arcane Missiles (Rank 11)
        [42843]	= 5, -- Arcane Missiles (Rank 12)
        [42846]	= 5, -- Arcane Missiles (Rank 13)
        [12051]	= 4, -- Evocation
        -- Priest
        [15407]	= 3, -- Mind Flay (Rank 1)
        [17311]	= 3, -- Mind Flay (Rank 2)
        [17312]	= 3, -- Mind Flay (Rank 3)
        [17313]	= 3, -- Mind Flay (Rank 4)
        [17314]	= 3, -- Mind Flay (Rank 5)
        [18807]	= 3, -- Mind Flay (Rank 6)
        [25387]	= 3, -- Mind Flay (Rank 7)
        [48155]	= 3, -- Mind Flay (Rank 8)
        [48156]	= 3, -- Mind Flay (Rank 9)
        [64843]	= 4, -- Divine Hymn
        [64901]	= 4, -- Hymn of Hope -- TODO: Accurate without glyph - with glyph it is 5 ticks
        [48045]	= 5, -- Mind Sear (Rank 1)
        [53023]	= 5, -- Mind Sear (Rank 2)
        [47540]	= 2, -- Penance (Rank 1) (Dummy)
        [47750]	= 2, -- Penance (Rank 1) (Heal A)
        [47757]	= 2, -- Penance (Rank 1) (Heal B)
        [47666]	= 2, -- Penance (Rank 1) (DPS A)
        [47758]	= 2, -- Penance (Rank 1) (DPS B)
        [53005]	= 2, -- Penance (Rank 2) (Dummy)
        [52983]	= 2, -- Penance (Rank 2) (Heal A)
        [52986]	= 2, -- Penance (Rank 2) (Heal B)
        [52998]	= 2, -- Penance (Rank 2) (DPS A)
        [53001]	= 2, -- Penance (Rank 2) (DPS B)
        [53006]	= 2, -- Penance (Rank 3) (Dummy)
        [52984]	= 2, -- Penance (Rank 3) (Heal A)
        [52987]	= 2, -- Penance (Rank 3) (Heal B)
        [52999]	= 2, -- Penance (Rank 3) (DPS A)
        [53002]	= 2, -- Penance (Rank 3) (DPS B)
        [53007]	= 2, -- Penance (Rank 4) (Dummy)
        [52985]	= 2, -- Penance (Rank 4) (Heal A)
        [52988]	= 2, -- Penance (Rank 4) (Heal B)
        [53000]	= 2, -- Penance (Rank 4) (DPS A)
        [53003]	= 2, -- Penance (Rank 4) (DPS B)
        -- Warlock
        [1120]	= 5, -- Drain Soul (Rank 1)
        [8288]	= 5, -- Drain Soul (Rank 2)
        [8289]	= 5, -- Drain Soul (Rank 3)
        [11675]	= 5, -- Drain Soul (Rank 4)
        [27217]	= 5, -- Drain Soul (Rank 5)
        [47855]	= 5, -- Drain Soul (Rank 6)
        [755]	= 10, -- Health Funnel (Rank 1)
        [3698]	= 10, -- Health Funnel (Rank 2)
        [3699]	= 10, -- Health Funnel (Rank 3)
        [3700]	= 10, -- Health Funnel (Rank 4)
        [11693]	= 10, -- Health Funnel (Rank 5)
        [11694]	= 10, -- Health Funnel (Rank 6)
        [11695]	= 10, -- Health Funnel (Rank 7)
        [27259]	= 10, -- Health Funnel (Rank 8)
        [47856]	= 10, -- Health Funnel (Rank 9)
        [689]	= 5, -- Drain Life (Rank 1)
        [699]	= 5, -- Drain Life (Rank 2)
        [709]	= 5, -- Drain Life (Rank 3)
        [7651]	= 5, -- Drain Life (Rank 4)
        [11699]	= 5, -- Drain Life (Rank 5)
        [11700]	= 5, -- Drain Life (Rank 6)
        [27219]	= 5, -- Drain Life (Rank 7)
        [27220]	= 5, -- Drain Life (Rank 8)
        [47857]	= 5, -- Drain Life (Rank 9)
        [5740]	= 4, -- Rain of Fire (Rank 1)
        [6219]	= 4, -- Rain of Fire (Rank 2)
        [11677]	= 4, -- Rain of Fire (Rank 3)
        [11678]	= 4, -- Rain of Fire (Rank 4)
        [27212]	= 4, -- Rain of Fire (Rank 5)
        [47819]	= 4, -- Rain of Fire (Rank 6)
        [47820]	= 4, -- Rain of Fire (Rank 7)
        [1949]	= 15, -- Hellfire (Rank 1)
        [11683]	= 15, -- Hellfire (Rank 2)
        [11684]	= 15, -- Hellfire (Rank 3)
        [27213]	= 15, -- Hellfire (Rank 4)
        [47823]	= 15, -- Hellfire (Rank 5)
        [5138]	= 5, -- Drain Mana
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
        [746]	= 6, -- Linen Bandage
    }
elseif GW.Forever then
    GW.ChannelTicks = {

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
