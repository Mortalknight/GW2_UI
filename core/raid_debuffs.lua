local _, GW = ...
GW.ImportantRaidDebuff = GW.ImportantRaidDebuff or {}

local function SetDefaults(list)
    local dst = GW.globalDefault.profile.RAIDDEBUFFS
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
    local defaults = GW.globalDefault.profile.RAIDDEBUFFS

    for _, profile in pairs(profiles) do
        local list = profile and profile.RAIDDEBUFFS
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
if GW.Retail then
    ----------------------------------------------------------
    -- General / Misc
    ----------------------------------------------------------
    SetDefaults({
        160029, -- Resurrecting (Pending CR)
        225080, -- Reincarnation (Ankh ready)
        255234, -- Totemic Revival
    })

    ----------------------------------------------------------
    -- Mythic+ Specific – General Affix
    ----------------------------------------------------------
    SetDefaults({
        440313, -- Void Rift
    })

    ----------------------------------------------------------
    -- The War Within Dungeons — The Stonevault (Season 1)
    ----------------------------------------------------------
    SetDefaults({
        427329, -- Void Corruption
        435813, -- Void Empowerment
        423572, -- Void Empowerment
        424889, -- Seismic Reverberation
        424795, -- Refracting Beam
        457465, -- Entropy
        425974, -- Ground Pound
        445207, -- Piercing Wail
        428887, -- Smashed
        427382, -- Concussive Smash
        449154, -- Molten Mortar
        427361, -- Fracture
        443494, -- Crystalline Eruption
        424913, -- Volatile Explosion
        443954, -- Exhaust Vents
        426308, -- Void Infection
        429999, -- Flaming Scrap
        429545, -- Censoring Gear
        428819, -- Exhaust Vents
    })

    ----------------------------------------------------------
    -- City of Threads (Season 1)
    ----------------------------------------------------------
    SetDefaults({
        434722, -- Subjugate
        439341, -- Splice
        440437, -- Shadow Shunpo
        448561, -- Shadows of Doubt
        440107, -- Knife Throw
        439324, -- Umbral Weave
        442285, -- Corrupted Coating
        440238, -- Ice Sickles
        461842, -- Oozing Smash
        434926, -- Lingering Influence
        440310, -- Chains of Oppression
        439646, -- Process of Elimination
        448562, -- Doubt
        441391, -- Dark Paranoia
        461989, -- Oozing Smash
        441298, -- Freezing Blood
        441286, -- Dark Paranoia
        452151, -- Rigorous Jab
        451239, -- Brutal Jab
        443509, -- Ravenous Swarm
        443437, -- Shadows of Doubt
        451295, -- Void Rush
        443427, -- Web Bolt
        461630, -- Venomous Spray
        445435, -- Black Blood
        443401, -- Venom Strike
        443430, -- Silk Binding
        443438, -- Doubt
        443435, -- Twist Thoughts
        443432, -- Silk Binding
        448047, -- Web Wrap
        451426, -- Gossamer Barrage
        446718, -- Umbral Weave
        450055, -- Gutburst
        450783, -- Perfume Toss
    })

    ----------------------------------------------------------
    -- The Dawnbreaker (Season 1)
    ----------------------------------------------------------
    SetDefaults({
        463428, -- Lingering Erosion
        426736, -- Shadow Shroud
        434096, -- Sticky Webs
        453173, -- Collapsing Night
        426865, -- Dark Orb
        434090, -- Spinneret's Strands
        434579, -- Corrosion
        426735, -- Burning Shadows
        434576, -- Acidic Stupor
        452127, -- Animate Shadows
        438957, -- Acid Pools
        434441, -- Rolling Acid
        451119, -- Abyssal Blast
        453345, -- Abyssal Rot
        449332, -- Encroaching Shadows
        431333, -- Tormenting Beam
        431309, -- Ensnaring Shadows
        451107, -- Bursting Cocoon
        434406, -- Rolling Acid
        431491, -- Tainted Slash
        434113, -- Spinneret's Strands
        431350, -- Tormenting Eruption
        431365, -- Tormenting Ray
        434668, -- Sparking Arathi Bomb
        460135, -- Dark Scars
        451098, -- Tacky Nova
        450855, -- Dark Orb
        431494, -- Black Edge
        451115, -- Terrifying Slam
        432448, -- Stygian Seed
    })

    ----------------------------------------------------------
    -- Ara-Kara, City of Echoes (Season 1)
    ----------------------------------------------------------
    SetDefaults({
        461487, -- Cultivated Poisons
        432227, -- Venom Volley
        432119, -- Faded
        433740, -- Infestation
        439200, -- Voracious Bite
        433781, -- Ceaseless Swarm
        432132, -- Erupting Webs
        434252, -- Massive Slam
        432031, -- Grasping Blood
        438599, -- Bleeding Jab
        438618, -- Venomous Spit
        436401, -- AUGH!
        434830, -- Vile Webbing
        436322, -- Poison Bolt
        434083, -- Ambush
        433843, -- Erupting Webs
    })

    ----------------------------------------------------------
    -- The Rookery (Season 2)
    ----------------------------------------------------------
    SetDefaults({
        429493, -- Unstable Corruption
        424739, -- Chaotic Corruption
        433067, -- Seeping Corruption
        426160, -- Dark Gravity
        1214324, -- Crashing Thunder
        424966, -- Lingering Void
        467907, -- Festering Void
        458082, -- Stormrider's Charge
        472764, -- Void Extraction
        427616, -- Energized Barrage
        430814, -- Attracting Shadows
        430179, -- Seeping Corruption
        1214523, -- Feasting Void
    })

    ----------------------------------------------------------
    -- Priory of the Sacred Flame (Season 2)
    ----------------------------------------------------------
    SetDefaults({
        424414, -- Pierce Armor
        423015, -- Castigator's Shield
        447439, -- Savage Mauling
        425556, -- Sanctified Ground
        428170, -- Blinding Light
        448492, -- Thunderclap
        427621, -- Impale
        446403, -- Sacrificial Flame
        451764, -- Radiant Flame
        424426, -- Lunging Strike
        448787, -- Purification
        435165, -- Blazing Strike
        448515, -- Divine Judgment
        427635, -- Grievous Rip
        427897, -- Heat Wave
        424430, -- Consecration
        453461, -- Caltrops
        427900, -- Molten Pool
    })

    ----------------------------------------------------------
    -- Cinderbrew Meadery (Season 2)
    ----------------------------------------------------------
    SetDefaults({
        441397, -- Bee Venom
        431897, -- Rowdy Yell
        442995, -- Swarming Surprise
        437956, -- Erupting Inferno
        441413, -- Shredding Sting
        434773, -- Mean Mug
        438975, -- Shredding Sting
        463220, -- Volatile Keg
        449090, -- Reckless Delivery
        437721, -- Boiling Flames
        441179, -- Oozing Honey
        440087, -- Oozing Honey
        434707, -- Cinderbrew Toss
        445180, -- Crawling Brawl
        442589, -- Beeswax
        435789, -- Cindering Wounds
        440134, -- Honey Marinade
        432182, -- Throw Cinderbrew
        436644, -- Burning Ricochet
        436624, -- Cash Cannon
        436640, -- Burning Ricochet
        439325, -- Burning Fermentation
        432196, -- Hot Honey
        439586, -- Fluttering Wing
        440141, -- Honey Marinade
    })

    ----------------------------------------------------------
    -- Darkflame Cleft (Season 2)
    ----------------------------------------------------------
    SetDefaults({
        426943, -- Rising Gloom
        427015, -- Shadowblast
        420696, -- Throw Darkflame
        422648, -- Darkflame Pickaxe
        1218308, -- Enkindling Inferno
        422245, -- Rock Buster
        423693, -- Luring Candleflame
        421638, -- Wicklighter Barrage
        421817, -- Wicklighter Barrage
        424223, -- Incite Flames
        421146, -- Throw Darkflame
        427180, -- Fear of the Gloom
        424322, -- Explosive Flame
        422807, -- Candlelight
        420307, -- Candlelight
        422806, -- Smothering Shadows
        469620, -- Creeping Shadow
        443694, -- Crude Weapons
        425555, -- Crude Weapons
        428019, -- Flashpoint
        423501, -- Wild Wallop
        426277, -- One-Hand Headlock
        423654, -- Ouch!
        421653, -- Cursed Wax
        421067, -- Molten Wax
        426883, -- Bonk!
        440653, -- Surging Flamethrower
    })

    ----------------------------------------------------------
    -- Operation: Floodgate (Season 2)
    ----------------------------------------------------------
    SetDefaults({
        462737, -- Black Blood Wound
        1213803, -- Nailed
        468672, -- Pinch
        468616, -- Leaping Spark
        469799, -- Overcharge
        469811, -- Backwash
        468680, -- Crabsplosion
        473051, -- Rushing Tide
        474351, -- Shreddation Sawblade
        465830, -- Warp Blood
        468723, -- Shock Water
        474388, -- Flamethrower
        472338, -- Surveyed Ground
        462771, -- Surveying Beam
        472819, -- Razorchoke Vines
        473836, -- Electrocrush
        468815, -- Gigazap
        470022, -- Barreling Charge
        470038, -- Razorchoke Vines
        473713, -- Kinetic Explosive Gel
        468811, -- Gigazap
        466188, -- Thunder Punch
        460965, -- Barreling Charge
        472878, -- Sludge Claws
        473224, -- Sonic Boom
    })

    ----------------------------------------------------------
    -- The War Within (Season 2) — The MOTHERLODE
    ----------------------------------------------------------
    SetDefaults({
        263074, -- Festering Bite
        280605, -- Brain Freeze
        257337, -- Shocking Claw
        270882, -- Blazing Azerite
        268797, -- Transmute: Enemy to Goo
        259856, -- Chemical Burn
        269302, -- Toxic Blades
        280604, -- Iced Spritzer
        257371, -- Tear Gas
        257544, -- Jagged Cut
        268846, -- Echo Blade
        262794, -- Energy Lash
        262513, -- Azerite Heartseeker
        260829, -- Homing Missle (travelling)
        260838, -- Homing Missle (exploded)
        263637, -- Clothesline
    })

    ----------------------------------------------------------
    -- Theater of Pain
    ----------------------------------------------------------
    SetDefaults({
        333299, -- Curse of Desolation 1
        333301, -- Curse of Desolation 2
        319539, -- Soulless
        326892, -- Fixate
        321768, -- On the Hook
        323825, -- Grasping Rift
        342675, -- Bone Spear
        323831, -- Death Grasp
        330608, -- Vile Eruption
        330868, -- Necrotic Bolt Volley
        323750, -- Vile Gas
        323406, -- Jagged Gash
        330700, -- Decaying Blight
        319626, -- Phantasmal Parasite
        324449, -- Manifest Death
        341949, -- Withering Blight
    })

    ----------------------------------------------------------
    -- Operation Mechagon: Workshop
    ----------------------------------------------------------
    SetDefaults({
        291928, -- Giga-Zap
        292267, -- Giga-Zap
        302274, -- Fulminating Zap
        298669, -- Taze
        295445, -- Wreck
        294929, -- Blazing Chomp
        297257, -- Electrical Charge
        294855, -- Blossom Blast
        291972, -- Explosive Leap
        285443, -- 'Hidden' Flame Cannon
        291974, -- Obnoxious Monologue
        296150, -- Vent Blast
        298602, -- Smoke Cloud
        296560, -- Clinging Static
        297283, -- Cave In
        291914, -- Cutting Beam
        302384, -- Static Discharge
        294195, -- Arcing Zap
        299572, -- Shrink
        300659, -- Consuming Slime
        300650, -- Suffocating Smog
        301712, -- Pounce
        299475, -- B.O.R.K
        293670, -- Chain Blade
    })

    ----------------------------------------------------------
    -- The War Within (Season 3)
    ----------------------------------------------------------

    -- Eco-Dome Al'dani
    SetDefaults({
        1217439, -- Toxic Regurgitation
        1227152, -- Warp Strike
        1219535, -- Rift Claws
        1220390, -- Warp Strike
        1236126, -- Binding Javelin
        1225221, -- Dread of the Unknown
        1217446, -- Digestive Spittle
        1220671, -- Binding Javelin
        1231494, -- Overgorged Burst
        1224865, -- Fatebound
        1231224, -- Arcane Slash
        1221190, -- Gluttonous Miasma
        1221483, -- Arcing Energy
        1222202, -- Arcane Burn
    })

    -- Halls of Atonement
    SetDefaults({
        335338, -- Ritual of Woe
        326891, -- Anguish
        329321, -- Jagged Swipe 1
        344993, -- Jagged Swipe 2
        319603, -- Curse of Stone
        319611, -- Turned to Stone
        325876, -- Curse of Obliteration
        326632, -- Stony Veins
        323650, -- Haunting Fixation
        326874, -- Ankle Bites
        340446, -- Mark of Envy
    })

    -- Tazavesh, the Veiled Market
    SetDefaults({
        350804, -- Collapsing Energy
        350885, -- Hyperlight Jolt
        351101, -- Energy Fragmentation
        346828, -- Sanitizing Field
        355641, -- Scintillate
        355451, -- Undertow
        355581, -- Crackle
        349999, -- Anima Detonation
        346961, -- Purging Field
        351956, -- High-Value Target
        346297, -- Unstable Explosion
        347728, -- Flock!
        356408, -- Ground Stomp
        347744, -- Quickblade
        347481, -- Shuri
        355915, -- Glyph of Restraint
        350134, -- Infinite Breath
        350013, -- Gluttonous Feast
        355465, -- Boulder Throw
        346116, -- Shearing Swings
        356011, -- Beam Splicer
    })

    ---------------------------------------------------------
    -- Manaforge Omega
    ---------------------------------------------------------

    -- Plexus Sentinel
    SetDefaults({
        1219459, -- Manifest Matrices
        1219607, -- Eradicating Salvo
        1218625, -- Displacement Matrix
    })

    -- Loom'ithar
    SetDefaults({
        1226311, -- Infusion Tether
        1237212, -- Piercing Strand
        1226721, -- Silken Snare
    })
    SetDefaults({
        1226311, -- Infusion Tether
        1237212, -- Piercing Strand
        1226721, -- Silken Snare
    })

    -- Soulbinder Naazindhri
    SetDefaults({
        1227276, -- Soulfray Annihilation
        1223859, -- Arcane Expulsion
    })

    -- Forgeweaver Araz
    -- (keine Debuffs gelistet)
    -- The Soul Hunters
    -- (keine Debuffs gelistet)
    -- Fractillus
    -- (keine Debuffs gelistet)
    -- Nexus-King Salhadaar
    -- (keine Debuffs gelistet)
    -- Dimensius, the All-Devouring
    -- (keine Debuffs gelistet)

    ----------------------------------------------------------
    -- Liberation of Undermine
    ----------------------------------------------------------
    -- Vexie and the Geargrinders
    SetDefaults({
        465865, -- Tank Buster
        459669, -- Spew Oil
    })
    -- Cauldron of Carnage
    SetDefaults({
        1213690, -- Molten Phlegm
        1214009, -- Voltaic Image
    })
    -- Rik Reverb
    SetDefaults({
        1217122, -- Lingering Voltage
        468119,  -- Resonant Echoes
        467044,  -- Faulty Zap
    })
    -- Stix Bunkjunker
    SetDefaults({
        461536, -- Rolling Rubbish
        1217954, -- Meltdown
        465346, -- Sorted
        466748, -- Infected Bite
    })
    -- Sprocketmonger Lockenstock
    SetDefaults({
        1218342, -- Unstable Shrapnel
        465917,  -- Gravi-Gunk
        471308,  -- Blisterizer Mk. II
    })
    -- The One-Armed Bandit
    SetDefaults({
        471927, -- Withering Flames
        460420, -- Crushed!
    })
    -- Mug'Zee, Heads of Security
    SetDefaults({
        4664769, -- Frostshatter Boots
        466509,  -- Stormfury Finger Gun
        1215488, -- Disintegration Beam (Actually getting beamed)
        469391,  -- Perforating Wound
    })
    -- Chrome King Gallywix
    SetDefaults({
        466154, -- Blast Burns
        466834, -- Shock Barrage
        469362, -- Charged Giga Bomb (Carrying)
    })

    ----------------------------------------------------------
    -- Nerub'ar Palace
    ----------------------------------------------------------
    -- Ulgrax the Devourer
    SetDefaults({
        434705, -- Tenderized
        435138, -- Digestive Acid
        439037, -- Disembowel
        439419, -- Stalker Netting
        434778, -- Brutal Lashings
        435136, -- Venomous Lash
        438012, -- Hungering Bellows
    })
    -- The Bloodbound Horror
    SetDefaults({
        442604, -- Goresplatter
        445570, -- Unseeming Blight
        443612, -- Baneful Shift
        443042, -- Grasp From Beyond
    })
    -- Sikran
    SetDefaults({
        435410, -- Phase Lunge
        458277, -- Shattering Sweep
        438845, -- Expose
        433517, -- Phase Blades 1
        434860, -- Phase Blades 2
        459785, -- Cosmic Residue
        459273, -- Cosmic Shards
    })
    -- Rasha'nan
    SetDefaults({
        439785, -- Corrosion
        439786, -- Rolling Acid 1
        439790, -- Rolling Acid 2
        439787, -- Acidic Stupor
        458067, -- Savage Wound
        456170, -- Spinneret's Strands 1
        439783, -- Spinneret's Strands 2
        439780, -- Sticky Webs
        439776, -- Acid Pool
        455287, -- Infested Bite
    })
    -- Eggtender Ovi'nax
    SetDefaults({
        442257, -- Infest
        442799, -- Sanguine Overflow
        441362, -- Volatile Concotion
        442660, -- Rupture
        440421, -- Experimental Dosage
        442250, -- Fixate
        442437, -- Violent Discharge
        443274, -- Reverberation
    })
    -- Nexus-Princess Ky'veza
    SetDefaults({
        440377, -- Void Shredders
        436870, -- Assassination
        440576, -- Chasmal Gash
        437343, -- Queensbane
        436664, -- Regicide 1
        436666, -- Regicide 2
        436671, -- Regicide 3
        435535, -- Regicide 4
        436665, -- Regicide 5
        436663, -- Regicide 6
    })
    -- The Silken Court
    SetDefaults({
        450129, -- Entropic Desolation
        449857, -- Impaled
        438749, -- Scarab Fixation
        438708, -- Stinging Swarm
        438218, -- Piercing Strike
        454311, -- Barbed Webs
        438773, -- Shattered Shell
        438355, -- Cataclysmic Entropy
        438656, -- Venomous Rain
        441772, -- Void Bolt
        441788, -- Web Vortex
        440001, -- Binding Webs
    })
    -- Queen Ansurek
    SetDefaults({
        441865, -- Royal Shackles
        436800, -- Liquefy
        455404, -- Feast
        439829, -- Silken Tomb
        439825, -- Silken Tomb 2
        437586, -- Reactive Toxin
    })

elseif GW.Mists then
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