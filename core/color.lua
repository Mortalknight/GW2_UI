local _, GW = ...

GW.Colors.TextColors = {
    LightHeader = CreateColor(1, 0.9450, 0.8196)
}

GW.Colors.DebuffColors = {
    [GW.Enum.DispelType.None] = CreateColor(220 / 255, 0, 0),
    [GW.Enum.DispelType.Curse] = CreateColor(97 / 255, 72 / 255, 177 / 255),
    [GW.Enum.DispelType.Disease] = CreateColor(177 / 255, 114 / 255, 72 / 255),
    [GW.Enum.DispelType.Magic] = CreateColor(72 / 255, 94 / 255, 177 / 255),
    [GW.Enum.DispelType.Poison] = CreateColor(94 / 255, 177 / 255, 72 / 255),
    [GW.Enum.DispelType.Bleed] = CreateColor(1, 0.2, 0.6),
    [GW.Enum.DispelType.Enrage] = CreateColor(243 / 255, 95 / 255, 245 / 255),
}
GW.Colors.DebuffColors.None = GW.Colors.DebuffColors[GW.Enum.DispelType.None]
GW.Colors.DebuffColors.Curse = GW.Colors.DebuffColors[GW.Enum.DispelType.Curse]
GW.Colors.DebuffColors.Disease = GW.Colors.DebuffColors[GW.Enum.DispelType.Disease]
GW.Colors.DebuffColors.Magic = GW.Colors.DebuffColors[GW.Enum.DispelType.Magic]
GW.Colors.DebuffColors.Poison = GW.Colors.DebuffColors[GW.Enum.DispelType.Poison]
GW.Colors.DebuffColors.Bleed = GW.Colors.DebuffColors[GW.Enum.DispelType.Bleed]
GW.Colors.DebuffColors.Enrage = GW.Colors.DebuffColors[GW.Enum.DispelType.Enrage]
GW.Colors.DebuffColors.BadDispel = CreateColor(0.05, 0.85, 0.94)
GW.Colors.DebuffColors.Stealable = CreateColor(0.93, 0.91, 0.55)

GW.Colors.Fallback = CreateColor(0, 0, 0, 1)

GW.Colors.TabDenied = CreateColor(159 / 255, 159 / 255, 159 / 255)

GW.Colors.PowerBarCustomColors = {
    MANA = CreateColor(37 / 255, 133 / 255, 240 / 255),
    RAGE = CreateColor(240 / 255, 66 / 255, 37 / 255),
    ENERGY = CreateColor(240 / 255, 200 / 255, 37 / 255),
    LUNAR_POWER = CreateColor(130 / 255, 172 / 255, 230 / 255),
    RUNIC_POWER = CreateColor(37 / 255, 214 / 255, 240 / 255),
    FOCUS = CreateColor(240 / 255, 121 / 255, 37 / 255),
    FURY = CreateColor(166 / 255, 37 / 255, 240 / 255),
    PAIN = CreateColor(255 / 255, 156 / 255, 0),
    MAELSTROM = CreateColor(0.00, 0.50, 1.00),
    INSANITY = CreateColor(0.40, 0, 0.80),
    CHI = CreateColor(0.71, 1.0, 0.92),

    -- vehicle colors
    AMMOSLOT = CreateColor(0.80, 0.60, 0.00),
    FUEL = CreateColor(0.0, 0.55, 0.5),
    STAGGER = CreateColor(0.52, 1.0, 0.52),
}

GW.Colors.BagTypeColors = {
    [0x0001] = CreateColor(1, 1, 1),            --Quivers       1
    [0x0002] = CreateColor(1, 1, 1),            --Quivers       2
    [0x0004] = CreateColor(0.251, 0.878, 0.816),--Soul          3
    [0x0020] = CreateColor(0.451, 1, 0),        --Herbs         6
    [0x0040] = CreateColor(1, 0, 1)             --Enchanting    7
}

GW.Colors.ProfessionBagColors = {
    [8] = CreateColor(.88, .73, .29),  --leatherworking
    [16] = CreateColor(.29, .30, .88), --inscription
    [32] = CreateColor(.07, .71, .13), --herbs
    [64] = CreateColor(.76, .02, .8),  --enchanting
    [128] = CreateColor(.91, .46, .18), --engineering
    [512] = CreateColor(.03, .71, .81), --gems
    [1024] = CreateColor(.54, .40, .04), --Mining Bag
    [32768] = CreateColor(.42, .59, 1), --fishing
    [65536] = CreateColor(.87, .05, .25) --cooking
}

GW.Colors.ObjectivesTypeColors = {
    [GW.Enum.ObjectivesNotificationType.Quest] = CreateColor(221 / 255, 198 / 255, 68 / 255),
    [GW.Enum.ObjectivesNotificationType.Campaign] = CreateColor(121 / 255, 222 / 255, 47 / 255),
    [GW.Enum.ObjectivesNotificationType.Event] = CreateColor(240 / 255, 121 / 255, 37 / 255),
    [GW.Enum.ObjectivesNotificationType.Scenario] = CreateColor(171 / 255, 37 / 255, 240 / 255),
    [GW.Enum.ObjectivesNotificationType.Boss] = CreateColor(240 / 255, 37 / 255, 37 / 255),
    [GW.Enum.ObjectivesNotificationType.Achievement] = CreateColor(37 / 255, 240 / 255, 172 / 255),
    [GW.Enum.ObjectivesNotificationType.Arena] = CreateColor(240 / 255, 37 / 255, 37 / 255),
    [GW.Enum.ObjectivesNotificationType.DailyQuest] = CreateColor(68 / 255, 192 / 255, 250 / 255),
    [GW.Enum.ObjectivesNotificationType.Torghast] = CreateColor(109 / 255, 161 / 255, 207 / 255),
    [GW.Enum.ObjectivesNotificationType.HousingInitiative] = CreateColor(0.85, 0.7, 0.43),
    [GW.Enum.ObjectivesNotificationType.Delve] = CreateColor(171 / 255, 37 / 255, 240 / 255),
    [GW.Enum.ObjectivesNotificationType.Recipe] = CreateColor(228 / 255, 157 / 255, 0 / 255),
    [GW.Enum.ObjectivesNotificationType.MonthlyActivity] = CreateColor(228 / 255, 157 / 255, 0 / 255),
    [GW.Enum.ObjectivesNotificationType.Dead] = CreateColor(255 / 255, 255 / 255, 255 / 255),
}

GW.Colors.FactionBarColors = {
    [1] = CreateColor(0.8, 0.3, 0.22),
    [2] = CreateColor(0.8, 0.3, 0.22),
    [3] = CreateColor(0.75, 0.27, 0),
    [4] = CreateColor(0.9, 0.7, 0),
    [5] = CreateColor(0, 0.6, 0.1),
    [6] = CreateColor(0, 0.6, 0.1),
    [7] = CreateColor(0, 0.6, 0.1),
    [8] = CreateColor(0, 0.6, 0.1),
    [9] = CreateColor(0.22, 0.37, 0.98), --Paragon
    [10] = CreateColor(0.09, 0.29, 0.79), --Azerite
    [11] = CreateColor(0, 0.74, 0.95),  --(Renown)
}

GW.Colors.FriendlyColors = {
    [1] = CreateColor(88 / 255, 170 / 255, 68 / 255), --friendly #58aa44
    [2] = CreateColor(159 / 255, 36 / 255, 20 / 255), --enemy    #9f2414
    [3] = CreateColor(159 / 255, 159 / 255, 159 / 255) --tapped   #9f9f9f
}

GW.Colors.ClassColors = {
    WARRIOR = CreateColor(90 / 255, 54 / 255, 38 / 255, 1),
    PALADIN = CreateColor(177 / 255, 72 / 255, 117 / 255, 1),
    HUNTER = CreateColor(99 / 255, 125 / 255, 53 / 255, 1),
    ROGUE = CreateColor(190 / 255, 183 / 255, 79 / 255, 1),
    PRIEST = CreateColor(205 / 255, 205 / 255, 205 / 255, 1),
    DEATHKNIGHT = CreateColor(148 / 255, 62 / 255, 62 / 255, 1),
    SHAMAN = CreateColor(30 / 255, 44 / 255, 149 / 255, 1),
    --MAGE = CreateColor(62 / 255, 121 / 255, 149 / 255, 1},
    MAGE = CreateColor(101 / 255, 157 / 255, 184 / 255, 1),
    WARLOCK = CreateColor(125 / 255, 88 / 255, 154 / 255, 1),
    MONK = CreateColor(66 / 255, 151 / 255, 112 / 255, 1),
    DRUID = CreateColor(158 / 255, 103 / 255, 37 / 255, 1),
    DEMONHUNTER = CreateColor(72 / 255, 38 / 255, 148 / 255, 1),
    EVOKER = CreateColor(56 / 255, 99 / 255, 113 / 255, 1)
}

GW.Colors.FactionColors = {
    Horde = CreateColor(163 / 255, 46 / 255, 54 / 255), --Horde
    Alliance = CreateColor(57 / 255, 115 / 255, 186 / 255) --Alliance
}

GW.Colors.GemTypeInfoColors = {
	Yellow			= CreateColor(0.97, 0.82, 0.29),
	Red				= CreateColor(1.00, 0.47, 0.47),
	Blue			= CreateColor(0.47, 0.67, 1.00),
	Hydraulic		= CreateColor(1.00, 1.00, 1.00),
	Cogwheel		= CreateColor(1.00, 1.00, 1.00),
	Meta			= CreateColor(1.00, 1.00, 1.00),
	Prismatic		= CreateColor(1.00, 1.00, 1.00),
	PunchcardRed	= CreateColor(1.00, 0.47, 0.47),
	PunchcardYellow	= CreateColor(0.97, 0.82, 0.29),
	PunchcardBlue	= CreateColor(0.47, 0.67, 1.00),
}
