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
    SetDefaultOnTheFly(62376) -- Battering Ram
    SetDefaultOnTheFly(62374) -- Pursued
    -- Ignis the Furnace Master
    SetDefaultOnTheFly(62717) -- Slag Pot
    -- Razorscale
    SetDefaultOnTheFly(64016) -- Flame Buffet
    SetDefaultOnTheFly(64771) -- Fuse Armor
    SetDefaultOnTheFly(64757) -- Stormstrike
    -- XT-002 Deconstructor
    SetDefaultOnTheFly(63018) -- Searing Light
    SetDefaultOnTheFly(63024) -- Gravity Bomb
    -- Assembly of Iron
    SetDefaultOnTheFly(61886) -- Lightning Tendrils
    SetDefaultOnTheFly(61878) -- Overload
    SetDefaultOnTheFly(62269) -- Rune of Death
    SetDefaultOnTheFly(61903) -- Fusion Punch
    SetDefaultOnTheFly(61888) -- Overwhelming Power
    SetDefaultOnTheFly(44008) -- Static Disruption
    -- Kologarn
    SetDefaultOnTheFly(63355) -- Crunch Armor
    SetDefaultOnTheFly(64290) -- Stone Grip
    SetDefaultOnTheFly(63978) -- Stone Nova
    -- Auriaya
    SetDefaultOnTheFly(64669) -- Feral Pounce
    SetDefaultOnTheFly(64496) -- Feral Rush
    SetDefaultOnTheFly(64396) -- Guardian Swarm
    SetDefaultOnTheFly(64667) -- Rip Flesh
    SetDefaultOnTheFly(64666) -- Savage Pounce
    SetDefaultOnTheFly(64389) -- Sentinel Blast
    -- Freya
    SetDefaultOnTheFly(62243) -- Unstable Sun Beam
    SetDefaultOnTheFly(62310) -- Impale
    SetDefaultOnTheFly(62438) -- Iron Roots
    SetDefaultOnTheFly(62354) -- Broken Bones
    SetDefaultOnTheFly(62283) -- Iron Roots
    SetDefaultOnTheFly(63571) -- Nature's Fury
    -- Hodir
    SetDefaultOnTheFly(62039) -- Biting Cold
    SetDefaultOnTheFly(61969) -- Flash Freeze
    SetDefaultOnTheFly(62469) -- Freeze
    -- Mimiron
    SetDefaultOnTheFly(63666) -- Napalm Shell
    SetDefaultOnTheFly(64533) -- Heat Wave
    SetDefaultOnTheFly(64616) -- Deafening Siren
    SetDefaultOnTheFly(64668) -- Magnetic Field
    -- Thorim
    SetDefaultOnTheFly(62415) -- Acid Breath
    SetDefaultOnTheFly(62318) -- Barbed Shot
    SetDefaultOnTheFly(62576) -- Blizzard
    SetDefaultOnTheFly(32323) -- Charge
    SetDefaultOnTheFly(64971) -- Electro Shock
    SetDefaultOnTheFly(62605) -- Frost Nova
    SetDefaultOnTheFly(64970) -- Fuse Lightning
    SetDefaultOnTheFly(62418) -- Impale
    SetDefaultOnTheFly(35054) -- Mortal Strike
    SetDefaultOnTheFly(62420) -- Shield Smash
    SetDefaultOnTheFly(62042) -- Stormhammer
    SetDefaultOnTheFly(57807) -- Sunder Armor
    SetDefaultOnTheFly(62417) -- Sweep
    SetDefaultOnTheFly(62130) -- Unbalancing Strike
    SetDefaultOnTheFly(64151) -- Whirling Trip
    SetDefaultOnTheFly(40652) -- Wing Clip
    -- General Vezax
    SetDefaultOnTheFly(63276) -- Mark of the Faceless
    SetDefaultOnTheFly(63420) -- Profound Darkness
    -- Yogg-Saron
    SetDefaultOnTheFly(63802) -- Brain Link
    SetDefaultOnTheFly(64157) -- Curse of Doom
    SetDefaultOnTheFly(63830) -- Malady of the Mind
    SetDefaultOnTheFly(63138) -- Sara's Fervor
    SetDefaultOnTheFly(63134) -- Sara's Blessing
    SetDefaultOnTheFly(64125) -- Squeeze
    SetDefaultOnTheFly(64412) -- Phase Punch
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
