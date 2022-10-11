local _, GW = ...
GW.DEFAULTS = GW.DEFAULTS or {}
GW.DEFAULTS.RAIDDEBUFFS = {}
GW.ImportendRaidDebuff = {}

local function SetDefaultOnTheFly(id)
    GW.DEFAULTS.RAIDDEBUFFS[id] = true
    GW.ImportendRaidDebuff[id] = true
end

-------------------------------------------------
-------------------- Dungeons -------------------
-------------------------------------------------
	-- Ahn'kahet: The Old Kingdom
	-- Azjol-Nerub
	-- Drak'Tharon Keep
	-- Gundrak
	-- Halls of Lightning
	-- Halls of Reflection
	-- Halls of Stone
	-- Pit of Saron
	-- The Culling of Stratholme
	-- The Forge of Souls
	-- The Nexus
	-- The Oculus
	-- The Violet Hold
	-- Trial of the Champion
	-- Utgarde Keep
	-- Utgarde Pinnacle
-------------------------------------------------
-------------------- Phase 1 --------------------
-------------------------------------------------
-- Naxxramas
    -- Anub'Rekhan
    SetDefaultOnTheFly(54022) -- Locust Swarm
    SetDefaultOnTheFly(56098) -- Acid Spit
    -- Grand Widow Faerlina
    SetDefaultOnTheFly(54099) -- Rain of Fire
    SetDefaultOnTheFly(54098) -- Poison Bolt Volley
    -- Maexxna
    SetDefaultOnTheFly(54121) -- Necrotic Poison 1
    SetDefaultOnTheFly(28776) -- Necrotic Poison 2
    SetDefaultOnTheFly(28622) -- Web Wrap
    SetDefaultOnTheFly(54125) -- Web Spray
    -- Noth the Plaguebringer
    SetDefaultOnTheFly(54835) -- Curse of the Plaguebringer
    SetDefaultOnTheFly(54814) -- Cripple 1
    SetDefaultOnTheFly(29212) -- Cripple 2
    -- Heigan the Unclean
    SetDefaultOnTheFly(55011) -- Decrepit Fever
    -- Loatheb
    SetDefaultOnTheFly(55052) -- Inevitable Doom
    SetDefaultOnTheFly(55053) -- Deathbloom
    -- Instructor Razuvious
    SetDefaultOnTheFly(55550) -- Jagged Knife
    SetDefaultOnTheFly(55470) -- Unbalancing Strike
    -- Gothik the Harvester
    SetDefaultOnTheFly(55646) -- Drain Life
    SetDefaultOnTheFly(55645) -- Death Plague
    SetDefaultOnTheFly(28679) -- Harvest Soul
    -- The Four Horsemen
    SetDefaultOnTheFly(57369) -- Unholy Shadow
    SetDefaultOnTheFly(28832) -- Mark of Korth'azz
    SetDefaultOnTheFly(28835) -- Mark of Zeliek
    SetDefaultOnTheFly(28833) -- Mark of Blaumeux
    SetDefaultOnTheFly(28834) -- Mark of Rivendare
    -- Patchwerk
    SetDefaultOnTheFly(28801) -- Slime / Not really Encounter related
    -- Grobbulus
    SetDefaultOnTheFly(28169) -- Mutating Injection
    -- Gluth
    SetDefaultOnTheFly(54378) -- Mortal Wound
    SetDefaultOnTheFly(29306) -- Infected Wound
    -- Thaddius
    SetDefaultOnTheFly(28084) -- Negative Charge (-)
    SetDefaultOnTheFly(28059) -- Positive Charge (+)
    -- Sapphiron
    SetDefaultOnTheFly(28522) -- Icebolt
    SetDefaultOnTheFly(55665) -- Life Drain
    SetDefaultOnTheFly(28547) -- Chill 1
    SetDefaultOnTheFly(55699) -- Chill 2
    -- Kel'Thuzad
    SetDefaultOnTheFly(55807) -- Frostbolt 1
    SetDefaultOnTheFly(55802) -- Frostbolt 2
    SetDefaultOnTheFly(27808) -- Frost Blast
    SetDefaultOnTheFly(28410) -- Chains of Kel'Thuzad
-- The Eye of Eternity
    -- Malygos
    SetDefaultOnTheFly(56272) -- Arcane Breath
    SetDefaultOnTheFly(55853) -- Vortex 1
    SetDefaultOnTheFly(56263) -- Vortex 2
    SetDefaultOnTheFly(57407) -- Surge of Power
    SetDefaultOnTheFly(57429) -- Static Field
-- The Obsidian Sanctum
    -- Sartharion
    SetDefaultOnTheFly(60708) -- Fade Armor
    SetDefaultOnTheFly(58105) -- Power of Shadron
    SetDefaultOnTheFly(61248) -- Power of Tenebron
    SetDefaultOnTheFly(56910) -- Tail Lash
    SetDefaultOnTheFly(57874) -- Twilight Shift
    SetDefaultOnTheFly(57632) -- Magma
-------------------------------------------------
-------------------- Phase 2 --------------------
-------------------------------------------------
-- Ulduar
    -- Flame Leviathan
    -- Ignis the Furnace Master
    -- Razorscale
    -- XT-002 Deconstructor
    -- The Assembly of Iron
    -- Kologarn
    -- Auriaya
    -- Hodir
    -- Thorim
    -- Freya
    -- Mimiron
    -- General Vezax
    -- Yogg-Saron
    -- Algalon the Observer
-------------------------------------------------
-------------------- Phase 3 --------------------
-------------------------------------------------
-- Trial of the Crusader
    -- The Northrend Beasts
    -- Lord Jaraxxus
    -- Champions of the Horde
    -- Champions of the Alliance
    -- Twin Val'kyr
    -- Anub'arak
-- Onyxia’s Lair
    -- Onyxia
-------------------------------------------------
-------------------- Phase 4 --------------------
-------------------------------------------------
-- Icecrown Citadel
    -- Lord Marrowgar
    -- Lady Deathwhisper
    -- Gunship Battle Alliance
    -- Gunship Battle Horde
    -- Deathbringer Saurfang
    -- Festergut
    -- Rotface
    -- Professor Putricide
    -- Blood Prince Council
    -- Blood-Queen Lana'thel
    -- Valithria Dreamwalker
    -- Sindragosa
    -- The Lich King
-------------------------------------------------
-------------------- Phase 5 --------------------
-------------------------------------------------
-- The Ruby Sanctum
    -- Halion
