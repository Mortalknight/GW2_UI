local _, GW = ...

GW.Enum.ChangelogType = {
	feature = 1,
	change = 2,
	bug = 3
}

GW.Enum.ObjectivesBlockType = {
	Notification = 1,
	BossFrames = 2,
	ArenaFrames = 3,
    Scenario = 4,
    Achievement = 5,
    Campaign = 6,
    Quests = 7,
    Bonus = 8,
    Recipe = 9,
    MonthlyActivity = 10,
    Collection = 11,
    HousingInitiative = 12,
    WQT = 13,
    PetTracker = 14,
    Todoloo = 15,
}

GW.Enum.ObjectivesNotificationType = {
    Quest = 1,
    Campaign = 2,
    Event = 3,
    Scenario = 4,
    Boss = 5,
    Arena = 6,
    Achievement = 7,
    DailyQuest = 8,
    Torghast = 9,
    Recipe = 10,
    MonthlyActivity = 11,
    HousingInitiative = 12,
    Delve = 13,
    Dead = 14,
}

GW.Enum.DispelType = {
	-- https://wago.tools/db2/SpellDispelType
	None = 0,
	Magic = 1,
	Curse = 2,
	Disease = 3,
	Poison = 4,
	Enrage = 9,
	Bleed = 11,
}

GW.Enum.TextSizeType = {
    BigHeader = 1,
    Header = 2,
    Normal = 3,
    Small = 4,
}

GW.Enum.ClassIndex = {
    Warrior = 1,
    Paladin = 2,
    Hunter = 3,
    Rogue = 4,
    Priest = 5,
    Deathknight = 6,
    Shaman = 7,
    Mage = 8,
    Warlock = 9,
    Monk = 10,
    Druid = 11,
    Demonhunter = 12,
    Evoker = 13,
}
