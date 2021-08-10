local _, GW = ...
GW.DEFAULTS = GW.DEFAULTS or {}
GW.DEFAULTS.RAIDDEBUFFS = {}
GW.ImportendRaidDebuff = {}

local function SetDefaultOnTheFly(id)
    GW.DEFAULTS.RAIDDEBUFFS[id] = true
    GW.ImportendRaidDebuff[id] = true
end

-------------------------------------------------
-------------------- Phase 1 --------------------
-------------------------------------------------
-- Karazhan
    -- Attument the Huntsman
    SetDefaultOnTheFly(29833) -- Intangible Presence
    SetDefaultOnTheFly(29711) -- Knockdown
    -- Moroes
    SetDefaultOnTheFly(29425) -- Gouge
    SetDefaultOnTheFly(34694) -- Blind
    SetDefaultOnTheFly(37066) -- Garrote
    -- Opera Hall Event
    SetDefaultOnTheFly(30822) -- Poisoned Thrust
    SetDefaultOnTheFly(30889) -- Powerful Attraction
    SetDefaultOnTheFly(30890) -- Blinding Passion
    -- Maiden of Virtue
    SetDefaultOnTheFly(29511) -- Repentance
    SetDefaultOnTheFly(29522) -- Holy Fire
    SetDefaultOnTheFly(29512) -- Holy Ground
    -- The Curator
    -- Terestian Illhoof
    SetDefaultOnTheFly(30053) -- Amplify Flames
    SetDefaultOnTheFly(30115) -- Sacrifice
    -- Shade of Aran
    SetDefaultOnTheFly(29946) -- Flame Wreath
    SetDefaultOnTheFly(29947) -- Flame Wreath
    SetDefaultOnTheFly(29990) -- Slow
    SetDefaultOnTheFly(29991) -- Chains of Ice
    SetDefaultOnTheFly(29954) -- Frostbolt
    SetDefaultOnTheFly(29951) -- Blizzard
    -- Netherspite
    SetDefaultOnTheFly(38637) -- Nether Exhaustion (Red)
    SetDefaultOnTheFly(38638) -- Nether Exhaustion (Green)
    SetDefaultOnTheFly(38639) -- Nether Exhaustion (Blue)
    SetDefaultOnTheFly(30400) -- Nether Beam - Perseverence
    SetDefaultOnTheFly(30401) -- Nether Beam - Serenity
    SetDefaultOnTheFly(30402) -- Nether Beam - Dominance
    SetDefaultOnTheFly(30421) -- Nether Portal - Perseverence
    SetDefaultOnTheFly(30422) -- Nether Portal - Serenity
    SetDefaultOnTheFly(30423) -- Nether Portal - Dominance
    SetDefaultOnTheFly(30466) -- Nether Portal - Perseverence
    -- Chess Event
    SetDefaultOnTheFly(30529) -- Recently In Game
    -- Prince Malchezaar
    SetDefaultOnTheFly(39095) -- Amplify Damage
    SetDefaultOnTheFly(30898) -- Shadow Word: Pain 1
    SetDefaultOnTheFly(30854) -- Shadow Word: Pain 2
    -- Nightbane
    SetDefaultOnTheFly(37091) -- Rain of Bones
    SetDefaultOnTheFly(30210) -- Smoldering Breath
    SetDefaultOnTheFly(30129) -- Charred Earth
    SetDefaultOnTheFly(30127) -- Searing Cinders
    SetDefaultOnTheFly(36922) -- Bellowing Roar
-- Gruul's Lair
    -- High King Maulgar
    SetDefaultOnTheFly(36032) -- Arcane Blast
    SetDefaultOnTheFly(11726) -- Enslave Demon
    SetDefaultOnTheFly(33129) -- Dark Decay
    SetDefaultOnTheFly(33175) -- Arcane Shock
    SetDefaultOnTheFly(33061) -- Blast Wave
    SetDefaultOnTheFly(33130) -- Death Coil
    SetDefaultOnTheFly(16508) -- Intimidating Roar
    -- Gruul the Dragonkiller
    SetDefaultOnTheFly(38927) -- Fel Ache
    SetDefaultOnTheFly(36240) -- Cave In
    SetDefaultOnTheFly(33652) -- Stoned
    SetDefaultOnTheFly(33525) -- Ground Slam
-- Magtheridon's Lair
    -- Magtheridon
    SetDefaultOnTheFly(44032) -- Mind Exhaustion
    SetDefaultOnTheFly(30530) -- Fear
    SetDefaultOnTheFly(38927) -- Fel Ache
-------------------------------------------------
-------------------- Phase 2 --------------------
-------------------------------------------------
-- Serpentshrine Cavern
    -- Hydross the Unstable
    -- The Lurker Below
    -- Leotheras the Blind
    -- Fathom-Lord Karathress
    -- Morogrim Tidewalker
    -- Lady Vashj
-- The Eye
    -- Al'ar
    -- Void Reaver
    -- High Astromancer Solarian
    -- Kael'thas Sunstrider
-------------------------------------------------
-------------------- Phase 3 --------------------
-------------------------------------------------
-- The Battle for Mount Hyjal
    -- Rage Winterchill
    -- Anetheron
    -- Kaz'rogal
    -- Azgalor
    -- Archimonde
-- Black Temple
    -- High Warlord Naj'entus
    -- Supremus
    -- Shade of Akama
    -- Teron Gorefiend
    -- Gurtogg Bloodboil
    -- Reliquary of Souls
    -- Mother Shahraz
    -- Illidari Council
    -- Illidan Stormrage
-------------------------------------------------
-------------------- Phase 4 --------------------
-------------------------------------------------
-- Zul'Aman
    -- Nalorakk
    -- Jan'alai
    -- Akil'zon
    -- Halazzi
    -- Hexxlord Jin'Zakk
    -- Zul'jin
-------------------------------------------------
-------------------- Phase 5 --------------------
-------------------------------------------------
-- Sunwell Plateau
    -- Kalecgos
    -- Sathrovarr
    -- Brutallus
    -- Felmyst
    -- Alythess
    -- Sacrolash
    -- M'uru
    -- Kil'Jaeden
