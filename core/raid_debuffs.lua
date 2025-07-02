local _, GW = ...
GW.ImportendRaidDebuff = {}

local function RemoveOldRaidDebuffsFormProfiles()
    local profiles = GW.globalSettings.profiles or {}
    for k, _ in pairs(profiles) do
        if profiles[k] then
            if profiles[k].RAIDDEBUFFS then
                for id, _ in pairs(profiles[k].RAIDDEBUFFS) do
                    if GW.globalDefault.profile.RAIDDEBUFFS[id] == nil then
                        profiles[k].RAIDDEBUFFS[id] = nil
                    end
                end
            end
        end
    end
end
GW.RemoveOldRaidDebuffsFormProfiles = RemoveOldRaidDebuffsFormProfiles

local function SetDefaultOnTheFly(id)
    GW.ImportendRaidDebuff[id] = true
    GW.globalDefault.profile.RAIDDEBUFFS[id] = true
end
if GW.Retail then
    ----------------------------------------------------------
        ------------------------- General ------------------------
        ----------------------------------------------------------
        -- Misc
        SetDefaultOnTheFly(160029) -- Resurrecting (Pending CR)
        SetDefaultOnTheFly(225080) -- Reincarnation (Ankh ready)
        SetDefaultOnTheFly(255234) -- Totemic Revival
    ----------------------------------------------------------
    -------------------- Mythic+ Specific --------------------
    ----------------------------------------------------------
    -- General Affix
        SetDefaultOnTheFly(440313) -- Void Rift
    ----------------------------------------------------------
        ---------------- The War Within Dungeons -----------------
        ----------------------------------------------------------
        -- The Stonevault (Season 1)
        SetDefaultOnTheFly(427329) -- Void Corruption
        SetDefaultOnTheFly(435813) -- Void Empowerment
        SetDefaultOnTheFly(423572) -- Void Empowerment
        SetDefaultOnTheFly(424889) -- Seismic Reverberation
        SetDefaultOnTheFly(424795) -- Refracting Beam
        SetDefaultOnTheFly(457465) -- Entropy
        SetDefaultOnTheFly(425974) -- Ground Pound
        SetDefaultOnTheFly(445207) -- Piercing Wail
        SetDefaultOnTheFly(428887) -- Smashed
        SetDefaultOnTheFly(427382) -- Concussive Smash
        SetDefaultOnTheFly(449154) -- Molten Mortar
        SetDefaultOnTheFly(427361) -- Fracture
        SetDefaultOnTheFly(443494) -- Crystalline Eruption
        SetDefaultOnTheFly(424913) -- Volatile Explosion
        SetDefaultOnTheFly(443954) -- Exhaust Vents
        SetDefaultOnTheFly(426308) -- Void Infection
        SetDefaultOnTheFly(429999) -- Flaming Scrap
        SetDefaultOnTheFly(429545) -- Censoring Gear
        SetDefaultOnTheFly(428819) -- Exhaust Vents
    -- City of Threads (Season 1)
        SetDefaultOnTheFly(434722) -- Subjugate
        SetDefaultOnTheFly(439341) -- Splice
        SetDefaultOnTheFly(440437) -- Shadow Shunpo
        SetDefaultOnTheFly(448561) -- Shadows of Doubt
        SetDefaultOnTheFly(440107) -- Knife Throw
        SetDefaultOnTheFly(439324) -- Umbral Weave
        SetDefaultOnTheFly(442285) -- Corrupted Coating
        SetDefaultOnTheFly(440238) -- Ice Sickles
        SetDefaultOnTheFly(461842) -- Oozing Smash
        SetDefaultOnTheFly(434926) -- Lingering Influence
        SetDefaultOnTheFly(440310) -- Chains of Oppression
        SetDefaultOnTheFly(439646) -- Process of Elimination
        SetDefaultOnTheFly(448562) -- Doubt
        SetDefaultOnTheFly(441391) -- Dark Paranoia
        SetDefaultOnTheFly(461989) -- Oozing Smash
        SetDefaultOnTheFly(441298) -- Freezing Blood
        SetDefaultOnTheFly(441286) -- Dark Paranoia
        SetDefaultOnTheFly(452151) -- Rigorous Jab
        SetDefaultOnTheFly(451239) -- Brutal Jab
        SetDefaultOnTheFly(443509) -- Ravenous Swarm
        SetDefaultOnTheFly(443437) -- Shadows of Doubt
        SetDefaultOnTheFly(451295) -- Void Rush
        SetDefaultOnTheFly(443427) -- Web Bolt
        SetDefaultOnTheFly(461630) -- Venomous Spray
        SetDefaultOnTheFly(445435) -- Black Blood
        SetDefaultOnTheFly(443401) -- Venom Strike
        SetDefaultOnTheFly(443430) -- Silk Binding
        SetDefaultOnTheFly(443438) -- Doubt
        SetDefaultOnTheFly(443435) -- Twist Thoughts
        SetDefaultOnTheFly(443432) -- Silk Binding
        SetDefaultOnTheFly(448047) -- Web Wrap
        SetDefaultOnTheFly(451426) -- Gossamer Barrage
        SetDefaultOnTheFly(446718) -- Umbral Weave
        SetDefaultOnTheFly(450055) -- Gutburst
        SetDefaultOnTheFly(450783) -- Perfume Toss
    -- The Dawnbreaker (Season 1)
        SetDefaultOnTheFly(463428) -- Lingering Erosion
        SetDefaultOnTheFly(426736) -- Shadow Shroud
        SetDefaultOnTheFly(434096) -- Sticky Webs
        SetDefaultOnTheFly(453173) -- Collapsing Night
        SetDefaultOnTheFly(426865) -- Dark Orb
        SetDefaultOnTheFly(434090) -- Spinneret's Strands
        SetDefaultOnTheFly(434579) -- Corrosion
        SetDefaultOnTheFly(426735) -- Burning Shadows
        SetDefaultOnTheFly(434576) -- Acidic Stupor
        SetDefaultOnTheFly(452127) -- Animate Shadows
        SetDefaultOnTheFly(438957) -- Acid Pools
        SetDefaultOnTheFly(434441) -- Rolling Acid
        SetDefaultOnTheFly(451119) -- Abyssal Blast
        SetDefaultOnTheFly(453345) -- Abyssal Rot
        SetDefaultOnTheFly(449332) -- Encroaching Shadows
        SetDefaultOnTheFly(431333) -- Tormenting Beam
        SetDefaultOnTheFly(431309) -- Ensnaring Shadows
        SetDefaultOnTheFly(451107) -- Bursting Cocoon
        SetDefaultOnTheFly(434406) -- Rolling Acid
        SetDefaultOnTheFly(431491) -- Tainted Slash
        SetDefaultOnTheFly(434113) -- Spinneret's Strands
        SetDefaultOnTheFly(431350) -- Tormenting Eruption
        SetDefaultOnTheFly(431365) -- Tormenting Ray
        SetDefaultOnTheFly(434668) -- Sparking Arathi Bomb
        SetDefaultOnTheFly(460135) -- Dark Scars
        SetDefaultOnTheFly(451098) -- Tacky Nova
        SetDefaultOnTheFly(450855) -- Dark Orb
        SetDefaultOnTheFly(431494) -- Black Edge
        SetDefaultOnTheFly(451115) -- Terrifying Slam
        SetDefaultOnTheFly(432448) -- Stygian Seed
    -- Ara-Kara, City of Echoes (Season 1)
        SetDefaultOnTheFly(461487) -- Cultivated Poisons
        SetDefaultOnTheFly(432227) -- Venom Volley
        SetDefaultOnTheFly(432119) -- Faded
        SetDefaultOnTheFly(433740) -- Infestation
        SetDefaultOnTheFly(439200) -- Voracious Bite
        SetDefaultOnTheFly(433781) -- Ceaseless Swarm
        SetDefaultOnTheFly(432132) -- Erupting Webs
        SetDefaultOnTheFly(434252) -- Massive Slam
        SetDefaultOnTheFly(432031) -- Grasping Blood
        SetDefaultOnTheFly(438599) -- Bleeding Jab
        SetDefaultOnTheFly(438618) -- Venomous Spit
        SetDefaultOnTheFly(436401) -- AUGH!
        SetDefaultOnTheFly(434830) -- Vile Webbing
        SetDefaultOnTheFly(436322) -- Poison Bolt
        SetDefaultOnTheFly(434083) -- Ambush
        SetDefaultOnTheFly(433843) -- Erupting Webs
    -- The Rookery (Season 2)
        SetDefaultOnTheFly(429493) -- Unstable Corruption
        SetDefaultOnTheFly(424739) -- Chaotic Corruption
        SetDefaultOnTheFly(433067) -- Seeping Corruption
        SetDefaultOnTheFly(426160) -- Dark Gravity
        SetDefaultOnTheFly(1214324) -- Crashing Thunder
        SetDefaultOnTheFly(424966) -- Lingering Void
        SetDefaultOnTheFly(467907) -- Festering Void
        SetDefaultOnTheFly(458082) -- Stormrider's Charge
        SetDefaultOnTheFly(472764) -- Void Extraction
        SetDefaultOnTheFly(427616) -- Energized Barrage
        SetDefaultOnTheFly(430814) -- Attracting Shadows
        SetDefaultOnTheFly(430179) -- Seeping Corruption
        SetDefaultOnTheFly(1214523) -- Feasting Void
    -- Priory of the Sacred Flame (Season 2)
        SetDefaultOnTheFly(424414) -- Pierce Armor
        SetDefaultOnTheFly(423015) -- Castigator's Shield
        SetDefaultOnTheFly(447439) -- Savage Mauling
        SetDefaultOnTheFly(425556) -- Sanctified Ground
        SetDefaultOnTheFly(428170) -- Blinding Light
        SetDefaultOnTheFly(448492) -- Thunderclap
        SetDefaultOnTheFly(427621) -- Impale
        SetDefaultOnTheFly(446403) -- Sacrificial Flame
        SetDefaultOnTheFly(451764) -- Radiant Flame
        SetDefaultOnTheFly(424426) -- Lunging Strike
        SetDefaultOnTheFly(448787) -- Purification
        SetDefaultOnTheFly(435165) -- Blazing Strike
        SetDefaultOnTheFly(448515) -- Divine Judgment
        SetDefaultOnTheFly(427635) -- Grievous Rip
        SetDefaultOnTheFly(427897) -- Heat Wave
        SetDefaultOnTheFly(424430) -- Consecration
        SetDefaultOnTheFly(453461) -- Caltrops
        SetDefaultOnTheFly(427900) -- Molten Pool
    -- Cinderbrew Meadery (Season 2)
        SetDefaultOnTheFly(441397) -- Bee Venom
        SetDefaultOnTheFly(431897) -- Rowdy Yell
        SetDefaultOnTheFly(442995) -- Swarming Surprise
        SetDefaultOnTheFly(437956) -- Erupting Inferno
        SetDefaultOnTheFly(441413) -- Shredding Sting
        SetDefaultOnTheFly(434773) -- Mean Mug
        SetDefaultOnTheFly(438975) -- Shredding Sting
        SetDefaultOnTheFly(463220) -- Volatile Keg
        SetDefaultOnTheFly(449090) -- Reckless Delivery
        SetDefaultOnTheFly(437721) -- Boiling Flames
        SetDefaultOnTheFly(441179) -- Oozing Honey
        SetDefaultOnTheFly(440087) -- Oozing Honey
        SetDefaultOnTheFly(434707) -- Cinderbrew Toss
        SetDefaultOnTheFly(445180) -- Crawling Brawl
        SetDefaultOnTheFly(442589) -- Beeswax
        SetDefaultOnTheFly(435789) -- Cindering Wounds
        SetDefaultOnTheFly(440134) -- Honey Marinade
        SetDefaultOnTheFly(432182) -- Throw Cinderbrew
        SetDefaultOnTheFly(436644) -- Burning Ricochet
        SetDefaultOnTheFly(436624) -- Cash Cannon
        SetDefaultOnTheFly(436640) -- Burning Ricochet
        SetDefaultOnTheFly(439325) -- Burning Fermentation
        SetDefaultOnTheFly(432196) -- Hot Honey
        SetDefaultOnTheFly(439586) -- Fluttering Wing
        SetDefaultOnTheFly(440141) -- Honey Marinade
    -- Darkflame Cleft (Season 2)
        SetDefaultOnTheFly(426943) -- Rising Gloom
        SetDefaultOnTheFly(427015) -- Shadowblast
        SetDefaultOnTheFly(420696) -- Throw Darkflame
        SetDefaultOnTheFly(422648) -- Darkflame Pickaxe
        SetDefaultOnTheFly(1218308) -- Enkindling Inferno
        SetDefaultOnTheFly(422245) -- Rock Buster
        SetDefaultOnTheFly(423693) -- Luring Candleflame
        SetDefaultOnTheFly(421638) -- Wicklighter Barrage
        SetDefaultOnTheFly(421817) -- Wicklighter Barrage
        SetDefaultOnTheFly(424223) -- Incite Flames
        SetDefaultOnTheFly(421146) -- Throw Darkflame
        SetDefaultOnTheFly(427180) -- Fear of the Gloom
        SetDefaultOnTheFly(424322) -- Explosive Flame
        SetDefaultOnTheFly(422807) -- Candlelight
        SetDefaultOnTheFly(420307) -- Candlelight
        SetDefaultOnTheFly(422806) -- Smothering Shadows
        SetDefaultOnTheFly(469620) -- Creeping Shadow
        SetDefaultOnTheFly(443694) -- Crude Weapons
        SetDefaultOnTheFly(425555) -- Crude Weapons
        SetDefaultOnTheFly(428019) -- Flashpoint
        SetDefaultOnTheFly(423501) -- Wild Wallop
        SetDefaultOnTheFly(426277) -- One-Hand Headlock
        SetDefaultOnTheFly(423654) -- Ouch!
        SetDefaultOnTheFly(421653) -- Cursed Wax
        SetDefaultOnTheFly(421067) -- Molten Wax
        SetDefaultOnTheFly(426883) -- Bonk!
        SetDefaultOnTheFly(440653) -- Surging Flamethrower
    -- Operation: Floodgate (Season 2)
        SetDefaultOnTheFly(462737) -- Black Blood Wound
        SetDefaultOnTheFly(1213803) -- Nailed
        SetDefaultOnTheFly(468672) -- Pinch
        SetDefaultOnTheFly(468616) -- Leaping Spark
        SetDefaultOnTheFly(469799) -- Overcharge
        SetDefaultOnTheFly(469811) -- Backwash
        SetDefaultOnTheFly(468680) -- Crabsplosion
        SetDefaultOnTheFly(473051) -- Rushing Tide
        SetDefaultOnTheFly(474351) -- Shreddation Sawblade
        SetDefaultOnTheFly(465830) -- Warp Blood
        SetDefaultOnTheFly(468723) -- Shock Water
        SetDefaultOnTheFly(474388) -- Flamethrower
        SetDefaultOnTheFly(472338) -- Surveyed Ground
        SetDefaultOnTheFly(462771) -- Surveying Beam
        SetDefaultOnTheFly(472819) -- Razorchoke Vines
        SetDefaultOnTheFly(473836) -- Electrocrush
        SetDefaultOnTheFly(468815) -- Gigazap
        SetDefaultOnTheFly(470022) -- Barreling Charge
        SetDefaultOnTheFly(470038) -- Razorchoke Vines
        SetDefaultOnTheFly(473713) -- Kinetic Explosive Gel
        SetDefaultOnTheFly(468811) -- Gigazap
        SetDefaultOnTheFly(466188) -- Thunder Punch
        SetDefaultOnTheFly(460965) -- Barreling Charge
        SetDefaultOnTheFly(472878) -- Sludge Claws
        SetDefaultOnTheFly(473224) -- Sonic Boom
    ----------------------------------------------------------
    --------------- The War Within (Season 2) ----------------
    ----------------------------------------------------------
    -- The MOTHERLODE
        SetDefaultOnTheFly(263074) -- Festering Bite
        SetDefaultOnTheFly(280605) -- Brain Freeze
        SetDefaultOnTheFly(257337) -- Shocking Claw
        SetDefaultOnTheFly(270882) -- Blazing Azerite
        SetDefaultOnTheFly(268797) -- Transmute: Enemy to Goo
        SetDefaultOnTheFly(259856) -- Chemical Burn
        SetDefaultOnTheFly(269302) -- Toxic Blades
        SetDefaultOnTheFly(280604) -- Iced Spritzer
        SetDefaultOnTheFly(257371) -- Tear Gas
        SetDefaultOnTheFly(257544) -- Jagged Cut
        SetDefaultOnTheFly(268846) -- Echo Blade
        SetDefaultOnTheFly(262794) -- Energy Lash
        SetDefaultOnTheFly(262513) -- Azerite Heartseeker
        SetDefaultOnTheFly(260829) -- Homing Missle (travelling)
        SetDefaultOnTheFly(260838) -- Homing Missle (exploded)
        SetDefaultOnTheFly(263637) -- Clothesline
    -- Theater of Pain
        SetDefaultOnTheFly(333299) -- Curse of Desolation 1
        SetDefaultOnTheFly(333301) -- Curse of Desolation 2
        SetDefaultOnTheFly(319539) -- Soulless
        SetDefaultOnTheFly(326892) -- Fixate
        SetDefaultOnTheFly(321768) -- On the Hook
        SetDefaultOnTheFly(323825) -- Grasping Rift
        SetDefaultOnTheFly(342675) -- Bone Spear
        SetDefaultOnTheFly(323831) -- Death Grasp
        SetDefaultOnTheFly(330608) -- Vile Eruption
        SetDefaultOnTheFly(330868) -- Necrotic Bolt Volley
        SetDefaultOnTheFly(323750) -- Vile Gas
        SetDefaultOnTheFly(323406) -- Jagged Gash
        SetDefaultOnTheFly(330700) -- Decaying Blight
        SetDefaultOnTheFly(319626) -- Phantasmal Parasite
        SetDefaultOnTheFly(324449) -- Manifest Death
        SetDefaultOnTheFly(341949) -- Withering Blight
    -- Operation Mechagon: Workshop
        SetDefaultOnTheFly(291928) -- Giga-Zap
        SetDefaultOnTheFly(292267) -- Giga-Zap
        SetDefaultOnTheFly(302274) -- Fulminating Zap
        SetDefaultOnTheFly(298669) -- Taze
        SetDefaultOnTheFly(295445) -- Wreck
        SetDefaultOnTheFly(294929) -- Blazing Chomp
        SetDefaultOnTheFly(297257) -- Electrical Charge
        SetDefaultOnTheFly(294855) -- Blossom Blast
        SetDefaultOnTheFly(291972) -- Explosive Leap
        SetDefaultOnTheFly(285443) -- 'Hidden' Flame Cannon
        SetDefaultOnTheFly(291974) -- Obnoxious Monologue
        SetDefaultOnTheFly(296150) -- Vent Blast
        SetDefaultOnTheFly(298602) -- Smoke Cloud
        SetDefaultOnTheFly(296560) -- Clinging Static
        SetDefaultOnTheFly(297283) -- Cave In
        SetDefaultOnTheFly(291914) -- Cutting Beam
        SetDefaultOnTheFly(302384) -- Static Discharge
        SetDefaultOnTheFly(294195) -- Arcing Zap
        SetDefaultOnTheFly(299572) -- Shrink
        SetDefaultOnTheFly(300659) -- Consuming Slime
        SetDefaultOnTheFly(300650) -- Suffocating Smog
        SetDefaultOnTheFly(301712) -- Pounce
        SetDefaultOnTheFly(299475) -- B.O.R.K
        SetDefaultOnTheFly(293670) -- Chain Blade
    ---------------------------------------------------------
    --------------- Liberation of Undermine -----------------
    ---------------------------------------------------------
    -- Vexie and the Geargrinders
        SetDefaultOnTheFly(465865) -- Tank Buster
        SetDefaultOnTheFly(459669) -- Spew Oil
    -- Cauldron of Carnage
        SetDefaultOnTheFly(1213690) -- Molten Phlegm
        SetDefaultOnTheFly(1214009) -- Voltaic Image
    -- Rik Reverb
        SetDefaultOnTheFly(1217122) -- Lingering Voltage
        SetDefaultOnTheFly(468119) -- Resonant Echoes
        SetDefaultOnTheFly(467044) -- Faulty Zap
    -- Stix Bunkjunker
        SetDefaultOnTheFly(461536) -- Rolling Rubbish
        SetDefaultOnTheFly(1217954) -- Meltdown
        SetDefaultOnTheFly(465346) -- Sorted
        SetDefaultOnTheFly(466748) -- Infected Bite
    -- Sprocketmonger Lockenstock
        SetDefaultOnTheFly(1218342) -- Unstable Shrapnel
        SetDefaultOnTheFly(465917) -- Gravi-Gunk
        SetDefaultOnTheFly(471308) -- Blisterizer Mk. II
    -- The One-Armed Bandit
        SetDefaultOnTheFly(471927) -- Withering Flames
        SetDefaultOnTheFly(460420) -- Crushed!
    -- Mug'Zee, Heads of Security
        SetDefaultOnTheFly(4664769) -- Frostshatter Boots
        SetDefaultOnTheFly(466509) -- Stormfury Finger Gun
        SetDefaultOnTheFly(1215488) -- Disintegration Beam (Actually getting beamed)
        SetDefaultOnTheFly(469391) -- Perforating Wound
    -- Chrome King Gallywix
        SetDefaultOnTheFly(466154) -- Blast Burns
        SetDefaultOnTheFly(466834) -- Shock Barrage
        SetDefaultOnTheFly(469362) -- Charged Giga Bomb (Carrying)
    ---------------------------------------------------------
    ------------------- Nerub'ar Palace ---------------------
    ---------------------------------------------------------
    -- Ulgrax the Devourer
        SetDefaultOnTheFly(434705) -- Tenderized
        SetDefaultOnTheFly(435138) -- Digestive Acid
        SetDefaultOnTheFly(439037) -- Disembowel
        SetDefaultOnTheFly(439419) -- Stalker Netting
        SetDefaultOnTheFly(434778) -- Brutal Lashings
        SetDefaultOnTheFly(435136) -- Venomous Lash
        SetDefaultOnTheFly(438012) -- Hungering Bellows
    -- The Bloodbound Horror
        SetDefaultOnTheFly(442604) -- Goresplatter
        SetDefaultOnTheFly(445570) -- Unseeming Blight
        SetDefaultOnTheFly(443612) -- Baneful Shift
        SetDefaultOnTheFly(443042) -- Grasp From Beyond
    -- Sikran
        SetDefaultOnTheFly(435410) -- Phase Lunge
        SetDefaultOnTheFly(458277) -- Shattering Sweep
        SetDefaultOnTheFly(438845) -- Expose
        SetDefaultOnTheFly(433517) -- Phase Blades 1
        SetDefaultOnTheFly(434860) -- Phase Blades 2
        SetDefaultOnTheFly(459785) -- Cosmic Residue
        SetDefaultOnTheFly(459273) -- Cosmic Shards
    -- Rasha'nan
        SetDefaultOnTheFly(439785) -- Corrosion
        SetDefaultOnTheFly(439786) -- Rolling Acid 1
        SetDefaultOnTheFly(439790) -- Rolling Acid 2
        SetDefaultOnTheFly(439787) -- Acidic Stupor
        SetDefaultOnTheFly(458067) -- Savage Wound
        SetDefaultOnTheFly(456170) -- Spinneret's Strands 1
        SetDefaultOnTheFly(439783) -- Spinneret's Strands 2
        SetDefaultOnTheFly(439780) -- Sticky Webs
        SetDefaultOnTheFly(439776) -- Acid Pool
        SetDefaultOnTheFly(455287) -- Infested Bite
    -- Eggtender Ovi'nax
        SetDefaultOnTheFly(442257) -- Infest
        SetDefaultOnTheFly(442799) -- Sanguine Overflow
        SetDefaultOnTheFly(441362) -- Volatile Concotion
        SetDefaultOnTheFly(442660) -- Rupture
        SetDefaultOnTheFly(440421) -- Experimental Dosage
        SetDefaultOnTheFly(442250) -- Fixate
        SetDefaultOnTheFly(442437) -- Violent Discharge
        SetDefaultOnTheFly(443274) -- Reverberation
    -- Nexus-Princess Ky'veza
        SetDefaultOnTheFly(440377) -- Void Shredders
        SetDefaultOnTheFly(436870) -- Assassination
        SetDefaultOnTheFly(440576) -- Chasmal Gash
        SetDefaultOnTheFly(437343) -- Queensbane
        SetDefaultOnTheFly(436664) -- Regicide 1
        SetDefaultOnTheFly(436666) -- Regicide 2
        SetDefaultOnTheFly(436671) -- Regicide 3
        SetDefaultOnTheFly(435535) -- Regicide 4
        SetDefaultOnTheFly(436665) -- Regicide 5
        SetDefaultOnTheFly(436663) -- Regicide 6
    -- The Silken Court
        SetDefaultOnTheFly(450129) -- Entropic Desolation
        SetDefaultOnTheFly(449857) -- Impaled
        SetDefaultOnTheFly(438749) -- Scarab Fixation
        SetDefaultOnTheFly(438708) -- Stinging Swarm
        SetDefaultOnTheFly(438218) -- Piercing Strike
        SetDefaultOnTheFly(454311) -- Barbed Webs
        SetDefaultOnTheFly(438773) -- Shattered Shell
        SetDefaultOnTheFly(438355) -- Cataclysmic Entropy
        SetDefaultOnTheFly(438656) -- Venomous Rain
        SetDefaultOnTheFly(441772) -- Void Bolt
        SetDefaultOnTheFly(441788) -- Web Vortex
        SetDefaultOnTheFly(440001) -- Binding Webs
    -- Queen Ansurek
        SetDefaultOnTheFly(441865) -- Royal Shackles
        SetDefaultOnTheFly(436800) -- Liquefy
        SetDefaultOnTheFly(455404) -- Feast
        SetDefaultOnTheFly(439829) -- Silken Tomb
        SetDefaultOnTheFly(439825) -- Silken Tomb 2
        SetDefaultOnTheFly(437586) -- Reactive Toxin
elseif GW.Mists then
    -------------------------------------------------
    -------------------- Dungeons -------------------
    -------------------------------------------------
    -- Scholomance
    -- Scarlet Halls
    -- Mogu'shan Palace
    -- Stormstout Brewery
    -- Siege of Niuzao Temple
    -- Scarlet Monastery
    -- Temple of the Jade Serpent
    -- Gate of the Setting Sun
    -- Shado-Pan Monastery
    -------------------------------------------------
    --------------------- Raids ---------------------
    -------------------------------------------------
    -- Mogu'shan Vaults
        -- The Stone Guard
        SetDefaultOnTheFly(125206)	-- Rend Flesh
        SetDefaultOnTheFly(130395)	-- Jasper Chains
        SetDefaultOnTheFly(116281)	-- Cobalt Mine Blast
        -- Feng the Accursed
        SetDefaultOnTheFly(131788)	-- Lightning Lash
        SetDefaultOnTheFly(116942)	-- Flaming Spear
        SetDefaultOnTheFly(131790)	-- Arcane Shock
        SetDefaultOnTheFly(131792)	-- Shadowburn
        SetDefaultOnTheFly(116374)	-- Lightning Charge
        SetDefaultOnTheFly(116784)	-- Wildfire Spark
        SetDefaultOnTheFly(116417)	-- Arcane Resonance
        -- Gara'jal the Spiritbinder
        SetDefaultOnTheFly(122151)	-- Voodoo Doll
        SetDefaultOnTheFly(117723)	-- Frail Soul
        -- The Spirit Kings
        SetDefaultOnTheFly(117708)	-- Maddening Shout
        SetDefaultOnTheFly(118303)	-- Fixate
        SetDefaultOnTheFly(118048)	-- Pillaged
        SetDefaultOnTheFly(118135)	-- Pinned Down
        SetDefaultOnTheFly(118163)	-- Robbed Blind
        -- Elegon
        SetDefaultOnTheFly(117878)	-- Overcharged
        SetDefaultOnTheFly(117949)	-- Closed Circuit
        SetDefaultOnTheFly(132222)	-- Destabilizing Energies
        -- Will of the Emperor
        SetDefaultOnTheFly(116835)	-- Devastating Arc
        SetDefaultOnTheFly(116778)	-- Focused Defense
        SetDefaultOnTheFly(116525)	-- Focused Assault
    -- Heart of Fear
        -- Imperial Vizier Zor'lok
        SetDefaultOnTheFly(122761)	-- Exhale
        SetDefaultOnTheFly(122760)	-- Exhale
        SetDefaultOnTheFly(122740)	-- Convert
        SetDefaultOnTheFly(123812)	-- Pheromones of Zeal
        -- Blade Lord Ta'yak
        SetDefaultOnTheFly(123180)	-- Wind Step
        SetDefaultOnTheFly(123474)	-- Overwhelming Assault
        -- Garalon
        SetDefaultOnTheFly(122835)	-- Pheromones
        SetDefaultOnTheFly(123081)	-- Pungency
        -- Wind Lord Mel'jarak
        SetDefaultOnTheFly(129078)	-- Amber Prison
        SetDefaultOnTheFly(122055)	-- Residue
        SetDefaultOnTheFly(122064)	-- Corrosive Resin
        SetDefaultOnTheFly(123963)	-- Kor'thik Strike
        -- Amber-Shaper Un'sok
        SetDefaultOnTheFly(121949)	-- Parasitic Growth
        SetDefaultOnTheFly(122370)	-- Reshape Life
    -- Terrace of Endless Spring
        -- Protectors of the Endless
        SetDefaultOnTheFly(117436)	-- Lightning Prison
        SetDefaultOnTheFly(118091)	-- Defiled Ground
        SetDefaultOnTheFly(117519)	-- Touch of Sha
        -- Tsulong
        SetDefaultOnTheFly(122752)	-- Shadow Breath
        SetDefaultOnTheFly(123011)	-- Terrorize
        SetDefaultOnTheFly(116161)	-- Crossed Over
        SetDefaultOnTheFly(122777)	-- Nightmares
        SetDefaultOnTheFly(123036)	-- Fright
        -- Lei Shi
        SetDefaultOnTheFly(123121)	-- Spray
        SetDefaultOnTheFly(123705)	-- Scary Fog
        -- Sha of Fear
        SetDefaultOnTheFly(119985)	-- Dread Spray
        SetDefaultOnTheFly(119086)	-- Penetrating Bolt
        SetDefaultOnTheFly(119775)	-- Reaching Attack
        SetDefaultOnTheFly(120669)	-- Naked and Afraid
        SetDefaultOnTheFly(120629)	-- Huddle in Terror
    -- Throne of Thunder
        -- Trash
        SetDefaultOnTheFly(138349)	-- Static Wound
        SetDefaultOnTheFly(137371)	-- Thundering Throw
        -- Jin'rokh the Breaker
        SetDefaultOnTheFly(137162)	-- Static Burst
        SetDefaultOnTheFly(138732)	-- Ionization
        SetDefaultOnTheFly(137422)	-- Focused Lightning
        -- Horridon
        SetDefaultOnTheFly(136767)	-- Triple Puncture
        SetDefaultOnTheFly(136708)	-- Stone Gaze
        SetDefaultOnTheFly(136654)	-- Rending Charge
        SetDefaultOnTheFly(136719)	-- Blazing Sunlight
        SetDefaultOnTheFly(136587)	-- Venom Bolt Volley
        SetDefaultOnTheFly(136710)	-- Deadly Plague
        SetDefaultOnTheFly(136512)	-- Hex of Confusion
        -- Council of Elders
        SetDefaultOnTheFly(137641)	-- Soul Fragment
        SetDefaultOnTheFly(137359)	-- Shadowed Loa Spirit Fixate
        SetDefaultOnTheFly(137972)	-- Twisted Fate
        SetDefaultOnTheFly(136903)	-- Frigid Assault
        SetDefaultOnTheFly(136922)	-- Frostbite
        SetDefaultOnTheFly(136992)	-- Biting Cold
        SetDefaultOnTheFly(136857)	-- Entrapped
        -- Tortos
        SetDefaultOnTheFly(136753)	-- Slashing Talons
        SetDefaultOnTheFly(137633)	-- Crystal Shell
        SetDefaultOnTheFly(140701)	-- Crystal Shell: Full Capacity! (Heroic)
        -- Megaera
        SetDefaultOnTheFly(137731)	-- Ignite Flesh
        SetDefaultOnTheFly(139843)	-- Arctic Freeze
        SetDefaultOnTheFly(139840)	-- Rot Armor
        SetDefaultOnTheFly(134391)	-- Cinder
        SetDefaultOnTheFly(139857)	-- Torrent of Ice
        SetDefaultOnTheFly(140179)	-- Suppression (Heroic)
        -- Ji-Kun
        SetDefaultOnTheFly(134366)	-- Talon Rake
        SetDefaultOnTheFly(140092)	-- Infected Talons
        SetDefaultOnTheFly(134256)	-- Slimed
        -- Durumu the Forgotten
        SetDefaultOnTheFly(133767)	-- Serious Wound
        SetDefaultOnTheFly(133768)	-- Arterial Cut
        SetDefaultOnTheFly(133798)	-- Life Drain
        SetDefaultOnTheFly(133597)	-- Dark Parasite (Heroic)
        -- Primordius
        SetDefaultOnTheFly(136050)	-- Malformed Blood
        SetDefaultOnTheFly(136228)	-- Volatile Pathogen
        -- Dark Animus
        SetDefaultOnTheFly(138569)	-- Explosive Slam
        SetDefaultOnTheFly(138609)	-- Matter Swap
        SetDefaultOnTheFly(138659)	-- Touch of the Animus
        -- Iron Qon
        SetDefaultOnTheFly(134691)	-- Impale
        SetDefaultOnTheFly(136192)	-- Lightning Storm
        SetDefaultOnTheFly(136193)	-- Arcing Lightning
        -- Twin Consorts
        SetDefaultOnTheFly(137440)	-- Icy Shadows
        SetDefaultOnTheFly(137408)	-- Fan of Flames
        SetDefaultOnTheFly(137360)	-- Corrupted Healing
        SetDefaultOnTheFly(136722)	-- Slumber Spores
        SetDefaultOnTheFly(137341)	-- Beast of Nightmares
        -- Lei Shen
        SetDefaultOnTheFly(135000)	-- Decapitate
        SetDefaultOnTheFly(136478)	-- Fusion Slash
        SetDefaultOnTheFly(136914)	-- Electrical Shock
        SetDefaultOnTheFly(135695)	-- Static Shock
        SetDefaultOnTheFly(136295)	-- Overcharged
        SetDefaultOnTheFly(139011)	-- Helm of Command (Heroic)
        -- Ra-den
        SetDefaultOnTheFly(138297)	-- Unstable Vita
        SetDefaultOnTheFly(138329)	-- Unleashed Anima
        SetDefaultOnTheFly(138372)	-- Vita Sensitivity
    -- Siege of Orgrimmar
        -- Immerseus
        SetDefaultOnTheFly(143436)	-- Corrosive Blast
        SetDefaultOnTheFly(143579)	-- Sha Corruption(Heroic)
        -- Fallen Protectors
        SetDefaultOnTheFly(143434)	-- Shadow Word: Bane
        SetDefaultOnTheFly(143198)	-- Garrote
        SetDefaultOnTheFly(143840)	-- Mark of Anguish
        SetDefaultOnTheFly(147383)	-- Debilitation
        -- Norushen
        SetDefaultOnTheFly(146124)	-- Self Doubt
        SetDefaultOnTheFly(144851)	-- Test of Confidence
        SetDefaultOnTheFly(144514)	-- Lingering Corruption
        -- Sha of Pride
        SetDefaultOnTheFly(144358)	-- Wounded Pride
        SetDefaultOnTheFly(144774)	-- Reaching Attacks
        SetDefaultOnTheFly(147207)	-- Weakened Resolve(Heroic)
        SetDefaultOnTheFly(144351)	-- Mark of Arrogance
        SetDefaultOnTheFly(146594)	-- Gift of the Titans
        -- Galakras
        SetDefaultOnTheFly(147029)	-- Flames of Galakrond
        SetDefaultOnTheFly(146902)	-- Poison-Tipped Blades
        -- Iron Juggernaut
        SetDefaultOnTheFly(144467)	-- Ignite Armor
        SetDefaultOnTheFly(144459)	-- Laser Burn
        -- Kor'kron Dark Shaman
        SetDefaultOnTheFly(144215)	-- Froststorm Strike
        SetDefaultOnTheFly(143990)	-- Foul Geyser
        SetDefaultOnTheFly(144330)	-- Iron Prison(Heroic)
        SetDefaultOnTheFly(144089)	-- Toxic Mist
        -- General Nazgrim
        SetDefaultOnTheFly(143494)	-- Sundering Blow
        SetDefaultOnTheFly(143638)	-- Bonecracker
        SetDefaultOnTheFly(143431)	-- Magistrike
        SetDefaultOnTheFly(143480)	-- Assassin's Mark
        -- Malkorok
        SetDefaultOnTheFly(142990)	-- Fatal Strike
        SetDefaultOnTheFly(143919)	-- Languish(Heroic)
        SetDefaultOnTheFly(142864)	-- Ancient Barrier
        SetDefaultOnTheFly(142865)	-- Strong Ancient Barrier
        SetDefaultOnTheFly(142913)	-- Displaced Energy
        -- Spoils of Pandaria
        SetDefaultOnTheFly(145218)	-- Harden Flesh
        SetDefaultOnTheFly(146235)	-- Breath of Fire
        -- Thok the Bloodthirsty
        SetDefaultOnTheFly(143766)	-- Panic
        SetDefaultOnTheFly(143773)	-- Freezing Breath
        SetDefaultOnTheFly(146589)	-- Skeleton Key
        SetDefaultOnTheFly(143777)	-- Frozen Solid
        SetDefaultOnTheFly(143780)	-- Acid Breath
        SetDefaultOnTheFly(143800)	-- Icy Blood
        SetDefaultOnTheFly(143767)	-- Scorching Breath
        SetDefaultOnTheFly(143791)	-- Corrosive Blood
        -- Siegecrafter Blackfuse
        SetDefaultOnTheFly(143385)	-- Electrostatic Charge
        SetDefaultOnTheFly(144236)	-- Pattern Recognition
        -- Paragons of the Klaxxi
        SetDefaultOnTheFly(143974)	-- Shield Bash
        SetDefaultOnTheFly(142315)	-- Caustic Blood
        SetDefaultOnTheFly(143701)	-- Whirling
        SetDefaultOnTheFly(142948)	-- Aim
        -- Garrosh Hellscream
        SetDefaultOnTheFly(145183)	-- Gripping Despair
        SetDefaultOnTheFly(145195)	-- Empowered Gripping Despair
        SetDefaultOnTheFly(145065)	-- Touch of Y'Shaarj
        SetDefaultOnTheFly(145171)	-- Empowered Touch of Y'Shaarj
elseif GW.Classic then
    -- Onyxia's Lair
        SetDefaultOnTheFly(18431) --Bellowing Roar
    -- Molten Core
        SetDefaultOnTheFly(19703) --Lucifron's Curse
        SetDefaultOnTheFly(19408) --Panic
        SetDefaultOnTheFly(19716) --Gehennas' Curse
        SetDefaultOnTheFly(20277) --Fist of Ragnaros
        SetDefaultOnTheFly(20475) --Living Bomb
        SetDefaultOnTheFly(19695) --Inferno
        SetDefaultOnTheFly(19659) --Ignite Mana
        SetDefaultOnTheFly(19714) --Deaden Magic
        SetDefaultOnTheFly(19713) --Shazzrah's Curse
    -- Blackwing's Lair
        SetDefaultOnTheFly(23023) --Conflagration
        SetDefaultOnTheFly(18173) --Burning Adrenaline
        SetDefaultOnTheFly(24573) --Mortal Strike
        SetDefaultOnTheFly(23340) --Shadow of Ebonroc
        SetDefaultOnTheFly(23170) --Brood Affliction: Bronze
        SetDefaultOnTheFly(22687) --Veil of Shadow
    -- Zul'Gurub
        SetDefaultOnTheFly(23860) --Holy Fire
        SetDefaultOnTheFly(22884) --Psychic Scream
        SetDefaultOnTheFly(23918) --Sonic Burst
        SetDefaultOnTheFly(24111) --Corrosive Poison
        SetDefaultOnTheFly(21060) --Blind
        SetDefaultOnTheFly(24328) --Corrupted Blood
        SetDefaultOnTheFly(16856) --Mortal Strike
        SetDefaultOnTheFly(24664) --Sleep
        SetDefaultOnTheFly(17172) --Hex
        SetDefaultOnTheFly(24306) --Delusions of Jin'do
        SetDefaultOnTheFly(24099) --Poison Bolt Volley
    -- Ahn'Qiraj Ruins
        SetDefaultOnTheFly(25646) --Mortal Wound
        SetDefaultOnTheFly(25471) --Attack Order
        SetDefaultOnTheFly(96) --Dismember
        SetDefaultOnTheFly(25725) --Paralyze
        SetDefaultOnTheFly(25189) --Enveloping Winds
    -- Ahn'Qiraj Temple
        SetDefaultOnTheFly(785) --True Fulfillment
        SetDefaultOnTheFly(26580) --Fear
        SetDefaultOnTheFly(26050) --Acid Spit
        SetDefaultOnTheFly(26180) --Wyvern Sting
        SetDefaultOnTheFly(26053) --Noxious Poison
        SetDefaultOnTheFly(26613) --Unbalancing Strike
        SetDefaultOnTheFly(26029) --Dark Glare
    -- Naxxramas
        SetDefaultOnTheFly(28732) --Widow's Embrace
        SetDefaultOnTheFly(28622) --Web Wrap
        SetDefaultOnTheFly(28169) --Mutating Injection
        SetDefaultOnTheFly(29213) --Curse of the Plaguebringer
        SetDefaultOnTheFly(28835) --Mark of Zeliek
        SetDefaultOnTheFly(27808) --Frost Blast
        SetDefaultOnTheFly(28410) --Chains of Kel'Thuzad
        SetDefaultOnTheFly(27819) --Detonate Mana
    --Multiple Dungeons
        SetDefaultOnTheFly(744) --Poison
        SetDefaultOnTheFly(18267) --Curse of Weakness
        SetDefaultOnTheFly(20800) --Immolate
        SetDefaultOnTheFly(246) --Slow
        SetDefaultOnTheFly(6533) --Net
        SetDefaultOnTheFly(8399) --Sleep
    -- Blackrock Depths
        SetDefaultOnTheFly(13704) --Psychic Scream
    -- Deadmines
        SetDefaultOnTheFly(6304) --Rhahk'Zor Slam
        SetDefaultOnTheFly(12097) --Pierce Armor
        SetDefaultOnTheFly(7399) --Terrify
        SetDefaultOnTheFly(6713) --Disarm
        SetDefaultOnTheFly(5213) --Molten Metal
        SetDefaultOnTheFly(5208) --Poisoned Harpoon
    -- Maraudon
        SetDefaultOnTheFly(7964) --Smoke Bomb
        SetDefaultOnTheFly(21869) --Repulsive Gaze
    -- Razorfen Downs
        SetDefaultOnTheFly(12255) --Curse of Tuten'kash
        SetDefaultOnTheFly(12252) --Web Spray
        SetDefaultOnTheFly(7645) --Dominate Mind
        SetDefaultOnTheFly(12946) --Putrid Stench
    -- Razorfen Kraul
        SetDefaultOnTheFly(14515) --Dominate Mind
    -- Scarlet Monastry
        SetDefaultOnTheFly(9034) --Immolate
        SetDefaultOnTheFly(8814) --Flame Spike
        SetDefaultOnTheFly(8988) --Silence
        SetDefaultOnTheFly(9256) --Deep Sleep
        SetDefaultOnTheFly(8282) --Curse of Blood
    -- Shadowfang Keep
        SetDefaultOnTheFly(7068) --Veil of Shadow
        SetDefaultOnTheFly(7125) --Toxic Saliva
        SetDefaultOnTheFly(7621) --Arugal's Curse
    --Stratholme
        SetDefaultOnTheFly(16798) --Enchanting Lullaby
        SetDefaultOnTheFly(12734) --Ground Smash
        SetDefaultOnTheFly(17293) --Burning Winds
        SetDefaultOnTheFly(17405) --Domination
        SetDefaultOnTheFly(16867) --Banshee Curse
        SetDefaultOnTheFly(6016) --Pierce Armor
        SetDefaultOnTheFly(16869) --Ice Tomb
        SetDefaultOnTheFly(17307) --Knockout
    -- Sunken Temple
        SetDefaultOnTheFly(12889) --Curse of Tongues
        SetDefaultOnTheFly(12888) --Cause Insanity
        SetDefaultOnTheFly(12479) --Hex of Jammal'an
        SetDefaultOnTheFly(12493) --Curse of Weakness
        SetDefaultOnTheFly(12890) --Deep Slumber
        SetDefaultOnTheFly(24375) --War Stomp
    -- Uldaman
        SetDefaultOnTheFly(3356) --Flame Lash
        SetDefaultOnTheFly(6524) --Ground Tremor
    -- Wailing Caverns
        SetDefaultOnTheFly(8040) --Druid's Slumber
        SetDefaultOnTheFly(8142) --Grasping Vines
        SetDefaultOnTheFly(7967) --Naralex's Nightmare
        SetDefaultOnTheFly(8150) --Thundercrack
    -- Zul'Farrak
        SetDefaultOnTheFly(11836) --Freeze Solid
    -- World Bosses
        SetDefaultOnTheFly(21056) --Mark of Kazzak
        SetDefaultOnTheFly(24814) --Seeping Fog
end