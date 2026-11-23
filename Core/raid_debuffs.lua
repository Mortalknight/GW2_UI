---@class GW2
local GW = select(2, ...)
GW.ImportantRaidDebuff = GW.ImportantRaidDebuff or {}

local function SetDefaults(list)
    local dst = GW.globalDefault.profile.groupFrames.raidDebuffs
    local mark = GW.ImportantRaidDebuff
    for i = 1, #list do
        local id = list[i]
        if type(id) == "number" then
            mark[id] = true
            dst[id] = true
        end
    end
end

local function RemoveOldRaidDebuffsFormProfiles()
    local profiles = GW.globalSettings.profiles or {}
    local defaults = GW.globalDefault.profile.groupFrames.raidDebuffs

    for _, profile in pairs(profiles) do
        local list = profile and profile.groupFrames and profile.groupFrames.raidDebuffs
        if type(list) == "table" then
            for id in pairs(list) do
                if defaults[id] == nil then
                    list[id] = nil
                end
            end
        end
    end
end
GW.RemoveOldRaidDebuffsFormProfiles = RemoveOldRaidDebuffsFormProfiles

-- =========================
-- ======== DEFAULTS =======
-- =========================
-- modern clients take blizzards boss aura flag instead of a list
if GW.Mists then
    -------------------------------------------------
    -- Dungeons (Platzhalter – keine IDs gelistet)
    -------------------------------------------------
    -- (leer)

    -------------------------------------------------
    -- Raids — Mogu'shan Vaults
    -------------------------------------------------
    SetDefaults({
        -- The Stone Guard
        125206, -- Rend Flesh
        130395, -- Jasper Chains
        116281, -- Cobalt Mine Blast
        -- Feng the Accursed
        131788, -- Lightning Lash
        116942, -- Flaming Spear
        131790, -- Arcane Shock
        131792, -- Shadowburn
        116374, -- Lightning Charge
        116784, -- Wildfire Spark
        116417, -- Arcane Resonance
        -- Gara'jal the Spiritbinder
        122151, -- Voodoo Doll
        117723, -- Frail Soul
        -- The Spirit Kings
        117708, -- Maddening Shout
        118303, -- Fixate
        118048, -- Pillaged
        118135, -- Pinned Down
        118163, -- Robbed Blind
        -- Elegon
        117878, -- Overcharged
        117949, -- Closed Circuit
        132222, -- Destabilizing Energies
        -- Will of the Emperor
        116835, -- Devastating Arc
        116778, -- Focused Defense
        116525, -- Focused Assault
    })

    -------------------------------------------------
    -- Heart of Fear
    -------------------------------------------------
    SetDefaults({
        -- Imperial Vizier Zor'lok
        122761, -- Exhale
        122760, -- Exhale
        122740, -- Convert
        123812, -- Pheromones of Zeal
        -- Blade Lord Ta'yak
        123180, -- Wind Step
        123474, -- Overwhelming Assault
        -- Garalon
        122835, -- Pheromones
        123081, -- Pungency
        -- Wind Lord Mel'jarak
        129078, -- Amber Prison
        122055, -- Residue
        122064, -- Corrosive Resin
        123963, -- Kor'thik Strike
        -- Amber-Shaper Un'sok
        121949, -- Parasitic Growth
        122370, -- Reshape Life
    })

    -------------------------------------------------
    -- Terrace of Endless Spring
    -------------------------------------------------
    SetDefaults({
        -- Protectors of the Endless
        117436, -- Lightning Prison
        118091, -- Defiled Ground
        117519, -- Touch of Sha
        -- Tsulong
        122752, -- Shadow Breath
        123011, -- Terrorize
        116161, -- Crossed Over
        122777, -- Nightmares
        123036, -- Fright
        -- Lei Shi
        123121, -- Spray
        123705, -- Scary Fog
        -- Sha of Fear
        119985, -- Dread Spray
        119086, -- Penetrating Bolt
        119775, -- Reaching Attack
        120669, -- Naked and Afraid
        120629, -- Huddle in Terror
    })

    -------------------------------------------------
    -- Throne of Thunder
    -------------------------------------------------
    SetDefaults({
        -- Trash
        138349, -- Static Wound
        137371, -- Thundering Throw
        -- Jin'rokh the Breaker
        137162, -- Static Burst
        138732, -- Ionization
        137422, -- Focused Lightning
        -- Horridon
        136767, -- Triple Puncture
        136708, -- Stone Gaze
        136654, -- Rending Charge
        136719, -- Blazing Sunlight
        136587, -- Venom Bolt Volley
        136710, -- Deadly Plague
        136512, -- Hex of Confusion
        -- Council of Elders
        137641, -- Soul Fragment
        137359, -- Shadowed Loa Spirit Fixate
        137972, -- Twisted Fate
        136903, -- Frigid Assault
        136922, -- Frostbite
        136992, -- Biting Cold
        136857, -- Entrapped
        -- Tortos
        136753, -- Slashing Talons
        137633, -- Crystal Shell
        140701, -- Crystal Shell: Full Capacity! (Heroic)
        -- Megaera
        137731, -- Ignite Flesh
        139843, -- Arctic Freeze
        139840, -- Rot Armor
        134391, -- Cinder
        139857, -- Torrent of Ice
        140179, -- Suppression (Heroic)
        -- Ji-Kun
        134366, -- Talon Rake
        140092, -- Infected Talons
        134256, -- Slimed
        -- Durumu the Forgotten
        133767, -- Serious Wound
        133768, -- Arterial Cut
        133798, -- Life Drain
        133597, -- Dark Parasite (Heroic)
        -- Primordius
        136050, -- Malformed Blood
        136228, -- Volatile Pathogen
        -- Dark Animus
        138569, -- Explosive Slam
        138609, -- Matter Swap
        138659, -- Touch of the Animus
        -- Iron Qon
        134691, -- Impale
        136192, -- Lightning Storm
        136193, -- Arcing Lightning
        -- Twin Consorts
        137440, -- Icy Shadows
        137408, -- Fan of Flames
        137360, -- Corrupted Healing
        136722, -- Slumber Spores
        137341, -- Beast of Nightmares
        -- Lei Shen
        135000, -- Decapitate
        136478, -- Fusion Slash
        136914, -- Electrical Shock
        135695, -- Static Shock
        136295, -- Overcharged
        139011, -- Helm of Command (Heroic)
        -- Ra-den
        138297, -- Unstable Vita
        138329, -- Unleashed Anima
        138372, -- Vita Sensitivity
    })

    -------------------------------------------------
    -- Siege of Orgrimmar
    -------------------------------------------------
    SetDefaults({
        -- Immerseus
        143436, -- Corrosive Blast
        143579, -- Sha Corruption(Heroic)
        -- Fallen Protectors
        143434, -- Shadow Word: Bane
        143198, -- Garrote
        143840, -- Mark of Anguish
        147383, -- Debilitation
        -- Norushen
        146124, -- Self Doubt
        144851, -- Test of Confidence
        144514, -- Lingering Corruption
        -- Sha of Pride
        144358, -- Wounded Pride
        144774, -- Reaching Attacks
        147207, -- Weakened Resolve(Heroic)
        144351, -- Mark of Arrogance
        146594, -- Gift of the Titans
        -- Galakras
        147029, -- Flames of Galakrond
        146902, -- Poison-Tipped Blades
        -- Iron Juggernaut
        144467, -- Ignite Armor
        144459, -- Laser Burn
        -- Kor'kron Dark Shaman
        144215, -- Froststorm Strike
        143990, -- Foul Geyser
        144330, -- Iron Prison(Heroic)
        144089, -- Toxic Mist
        -- General Nazgrim
        143494, -- Sundering Blow
        143638, -- Bonecracker
        143431, -- Magistrike
        143480, -- Assassin's Mark
        -- Malkorok
        142990, -- Fatal Strike
        143919, -- Languish(Heroic)
        142864, -- Ancient Barrier
        142865, -- Strong Ancient Barrier
        142913, -- Displaced Energy
        -- Spoils of Pandaria
        145218, -- Harden Flesh
        146235, -- Breath of Fire
        -- Thok the Bloodthirsty
        143766, -- Panic
        143773, -- Freezing Breath
        146589, -- Skeleton Key
        143777, -- Frozen Solid
        143780, -- Acid Breath
        143800, -- Icy Blood
        143767, -- Scorching Breath
        143791, -- Corrosive Blood
        -- Siegecrafter Blackfuse
        143385, -- Electrostatic Charge
        144236, -- Pattern Recognition
        -- Paragons of the Klaxxi
        143974, -- Shield Bash
        142315, -- Caustic Blood
        143701, -- Whirling
        142948, -- Aim
        -- Garrosh Hellscream
        145183, -- Gripping Despair
        145195, -- Empowered Gripping Despair
        145065, -- Touch of Y'Shaarj
        145171, -- Empowered Touch of Y'Shaarj
    })

elseif GW.Classic then
    -------------------------------------------------
    -- Classic
    -------------------------------------------------
    -- Onyxia's Lair
    SetDefaults({
        18431, -- Bellowing Roar
    })

    -- Molten Core
    SetDefaults({
        19703, -- Lucifron's Curse
        19408, -- Panic
        19716, -- Gehennas' Curse
        20277, -- Fist of Ragnaros
        20475, -- Living Bomb
        19695, -- Inferno
        19659, -- Ignite Mana
        19714, -- Deaden Magic
        19713, -- Shazzrah's Curse
    })

    -- Blackwing's Lair
    SetDefaults({
        23023, -- Conflagration
        18173, -- Burning Adrenaline
        24573, -- Mortal Strike
        23340, -- Shadow of Ebonroc
        23170, -- Brood Affliction: Bronze
        22687, -- Veil of Shadow
    })

    -- Zul'Gurub
    SetDefaults({
        23860, -- Holy Fire
        22884, -- Psychic Scream
        23918, -- Sonic Burst
        24111, -- Corrosive Poison
        21060, -- Blind
        24328, -- Corrupted Blood
        16856, -- Mortal Strike
        24664, -- Sleep
        17172, -- Hex
        24306, -- Delusions of Jin'do
        24099, -- Poison Bolt Volley
    })

    -- Ahn'Qiraj Ruins
    SetDefaults({
        25646, -- Mortal Wound
        25471, -- Attack Order
        96,    -- Dismember
        25725, -- Paralyze
        25189, -- Enveloping Winds
    })

    -- Ahn'Qiraj Temple
    SetDefaults({
        785,   -- True Fulfillment
        26580, -- Fear
        26050, -- Acid Spit
        26180, -- Wyvern Sting
        26053, -- Noxious Poison
        26613, -- Unbalancing Strike
        26029, -- Dark Glare
    })

    -- Naxxramas
    SetDefaults({
        28732, -- Widow's Embrace
        28622, -- Web Wrap
        28169, -- Mutating Injection
        29213, -- Curse of the Plaguebringer
        28835, -- Mark of Zeliek
        27808, -- Frost Blast
        28410, -- Chains of Kel'Thuzad
        27819, -- Detonate Mana
    })

    -- Multiple Dungeons
    SetDefaults({
        744,   -- Poison
        18267, -- Curse of Weakness
        20800, -- Immolate
        246,   -- Slow
        6533,  -- Net
        8399,  -- Sleep
    })

    -- Blackrock Depths
    SetDefaults({
        13704, -- Psychic Scream
    })

    -- Deadmines
    SetDefaults({
        6304,  -- Rhahk'Zor Slam
        12097, -- Pierce Armor
        7399,  -- Terrify
        6713,  -- Disarm
        5213,  -- Molten Metal
        5208,  -- Poisoned Harpoon
    })

    -- Maraudon
    SetDefaults({
        7964,  -- Smoke Bomb
        21869, -- Repulsive Gaze
    })

    -- Razorfen Downs
    SetDefaults({
        12255, -- Curse of Tuten'kash
        12252, -- Web Spray
        7645,  -- Dominate Mind
        12946, -- Putrid Stench
    })

    -- Razorfen Kraul
    SetDefaults({
        14515, -- Dominate Mind
    })

    -- Scarlet Monastery
    SetDefaults({
        9034,  -- Immolate
        8814,  -- Flame Spike
        8988,  -- Silence
        9256,  -- Deep Sleep
        8282,  -- Curse of Blood
    })

    -- Shadowfang Keep
    SetDefaults({
        7068,  -- Veil of Shadow
        7125,  -- Toxic Saliva
        7621,  -- Arugal's Curse
    })

    -- Stratholme
    SetDefaults({
        16798, -- Enchanting Lullaby
        12734, -- Ground Smash
        17293, -- Burning Winds
        17405, -- Domination
        16867, -- Banshee Curse
        6016,  -- Pierce Armor
        16869, -- Ice Tomb
        17307, -- Knockout
    })

    -- Sunken Temple
    SetDefaults({
        12889, -- Curse of Tongues
        12888, -- Cause Insanity
        12479, -- Hex of Jammal'an
        12493, -- Curse of Weakness
        12890, -- Deep Slumber
        24375, -- War Stomp
    })

    -- Uldaman
    SetDefaults({
        3356, -- Flame Lash
        6524, -- Ground Tremor
    })

    -- Wailing Caverns
    SetDefaults({
        8040, -- Druid's Slumber
        8142, -- Grasping Vines
        7967, -- Naralex's Nightmare
        8150, -- Thundercrack
    })

    -- Zul'Farrak
    SetDefaults({
        11836, -- Freeze Solid
    })

    -- World Bosses
    SetDefaults({
        21056, -- Mark of Kazzak
        24814, -- Seeping Fog
    })

elseif GW.TBC then
    -------------------------------------------------
-------------------- Phase 1 --------------------
-------------------------------------------------
-- Karazhan
    -- Attument the Huntsman
    SetDefaults({
        29833, -- Intangible Presence
        29711, -- Knockdown
    })
    -- Moroes
    SetDefaults({
        29425, -- Gouge
        34694, -- Blind
        37066, -- Garrote
    })
    -- Opera Hall Event
    SetDefaults({
        30822, -- Poisoned Thrust
        30889, -- Powerful Attraction
        30890, -- Blinding Passion
    })
    -- Maiden of Virtue
    SetDefaults({
        29511, -- Repentance
        29522, -- Holy Fire
        29512, -- Holy Ground
    })
    -- The Curator
    -- Terestian Illhoof
    SetDefaults({
        30053, -- Amplify Flames
        30115, -- Sacrifice
    })
    -- Shade of Aran
    SetDefaults({
        29946, -- Flame Wreath
        29947, -- Flame Wreath
        29990, -- Slow
        29991, -- Chains of Ice
        29954, -- Frostbolt
        29951, -- Blizzard
    })
    -- Netherspite
    SetDefaults({
        38637, -- Nether Exhaustion (Red)
        38638, -- Nether Exhaustion (Green)
        38639, -- Nether Exhaustion (Blue)
        30400, -- Nether Beam - Perseverence
        30401, -- Nether Beam - Serenity
        30402, -- Nether Beam - Dominance
        30421, -- Nether Portal - Perseverence
        30422, -- Nether Portal - Serenity
        30423, -- Nether Portal - Dominance
        30466, -- Nether Portal - Perseverence
    })
    -- Chess Event
    SetDefaults({
        30529, -- Recently In Game
    })
    -- Prince Malchezaar
    SetDefaults({
        39095, -- Amplify Damage
        30898, -- Shadow Word: Pain 1
        30854, -- Shadow Word: Pain 2
    })
    -- Nightbane
    SetDefaults({
        37091, -- Rain of Bones
        30210, -- Smoldering Breath
        30129, -- Charred Earth
        30127, -- Searing Cinders
        36922, -- Bellowing Roar
    })
-- Gruul's Lair
    -- High King Maulgar
    SetDefaults({
        36032, -- Arcane Blast
        11726, -- Enslave Demon
        33129, -- Dark Decay
        33175, -- Arcane Shock
        33061, -- Blast Wave
        33130, -- Death Coil
        16508, -- Intimidating Roar
    })
    -- Gruul the Dragonkiller
    SetDefaults({
        38927, -- Fel Ache
        36240, -- Cave In
        33652, -- Stoned
        33525, -- Ground Slam
    })
-- Magtheridon's Lair
    -- Magtheridon
    SetDefaults({
        44032, -- Mind Exhaustion
        30530, -- Fear
        38927, -- Fel Ache
    })
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

end