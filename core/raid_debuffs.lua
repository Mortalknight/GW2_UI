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
elseif GW.Cata then
    -------------------------------------------------
    -------------------- Dungeons -------------------
    -------------------------------------------------
    -- Blackrock Caverns
    -- Throne of the Tides
    -- The Stonecore
    -- The Vortex Pinnacle
    -- Grim Batol
    -- Halls of Origination
    -- Deadmines
    -- Shadowfang Keep
    -- Lost City of the Tol'vir
    -------------------------------------------------
    -------------------- Phase 1 --------------------
    -------------------------------------------------
    -- Baradin Hold
    SetDefaultOnTheFly(95173)	-- Consuming Darkness
    SetDefaultOnTheFly(96913)	-- Searing Shadows
    SetDefaultOnTheFly(104936)	-- Skewer
    SetDefaultOnTheFly(105067)	-- Seething Hate
    -- Blackwing Descent
    SetDefaultOnTheFly(91911)	-- Constricting Chains
    SetDefaultOnTheFly(94679)	-- Parasitic Infection
    SetDefaultOnTheFly(94617)	-- Mangle
    SetDefaultOnTheFly(78199)	-- Sweltering Armor
    SetDefaultOnTheFly(91433)	-- Lightning Conductor
    SetDefaultOnTheFly(91521)	-- Incineration Security Measure
    SetDefaultOnTheFly(80094)	-- Fixate
    SetDefaultOnTheFly(91535)	-- Flamethrower
    SetDefaultOnTheFly(80161)	-- Chemical Cloud
    SetDefaultOnTheFly(92035)	-- Acquiring Target
    SetDefaultOnTheFly(79835)	-- Poison Soaked Shell
    SetDefaultOnTheFly(91555)	-- Power Generator
    SetDefaultOnTheFly(92048)	-- Shadow Infusion
    SetDefaultOnTheFly(92053)	-- Shadow Conductor
    SetDefaultOnTheFly(77699)	-- Flash Freeze
    SetDefaultOnTheFly(77760)	-- Biting Chill
    SetDefaultOnTheFly(92754)	-- Engulfing Darkness
    SetDefaultOnTheFly(92971)	-- Consuming Flames
    SetDefaultOnTheFly(92989)	-- Rend
    SetDefaultOnTheFly(92423)	-- Searing Flame
    SetDefaultOnTheFly(92485)	-- Roaring Flame
    SetDefaultOnTheFly(92407)	-- Sonic Breath
    SetDefaultOnTheFly(78092)	-- Tracking
    SetDefaultOnTheFly(82881)	-- Break
    SetDefaultOnTheFly(89084)	-- Low Health
    SetDefaultOnTheFly(81114)	-- Magma
    SetDefaultOnTheFly(94128)	-- Tail Lash
    SetDefaultOnTheFly(79339)	-- Explosive Cinders
    SetDefaultOnTheFly(79318)	-- Dominion
    -- The Bastion of Twilight
    SetDefaultOnTheFly(39171)	-- Malevolent Strikes
    SetDefaultOnTheFly(83710)	-- Furious Roar
    SetDefaultOnTheFly(92878)	-- Blackout
    SetDefaultOnTheFly(86840)	-- Devouring Flames
    SetDefaultOnTheFly(95639)	-- Engulfing Magic
    SetDefaultOnTheFly(92886)	-- Twilight Zone
    SetDefaultOnTheFly(88518)	-- Twilight Meteorite
    SetDefaultOnTheFly(86505)	-- Fabulous Flames
    SetDefaultOnTheFly(93051)	-- Twilight Shift
    SetDefaultOnTheFly(92511)	-- Hydro Lance
    SetDefaultOnTheFly(82762)	-- Waterlogged
    SetDefaultOnTheFly(92505)	-- Frozen
    SetDefaultOnTheFly(92518)	-- Flame Torrent
    SetDefaultOnTheFly(83099)	-- Lightning Rod
    SetDefaultOnTheFly(92075)	-- Gravity Core
    SetDefaultOnTheFly(92488)	-- Gravity Crush
    SetDefaultOnTheFly(82660)	-- Burning Blood
    SetDefaultOnTheFly(82665)	-- Heart of Ice
    SetDefaultOnTheFly(83500)	-- Swirling Winds
    SetDefaultOnTheFly(83581)	-- Grounded
    SetDefaultOnTheFly(92067)	-- Static Overload
    SetDefaultOnTheFly(86028)	-- Cho's Blast
    SetDefaultOnTheFly(86029)	-- Gall's Blast
    SetDefaultOnTheFly(93187)	-- Corrupted Blood
    SetDefaultOnTheFly(82125)	-- Corruption: Malformation
    SetDefaultOnTheFly(82170)	-- Corruption: Absolute
    SetDefaultOnTheFly(93200)	-- Corruption: Sickness
    SetDefaultOnTheFly(82411)	-- Debilitating Beam
    SetDefaultOnTheFly(91317)	-- Worshipping
    SetDefaultOnTheFly(92956)	-- Wrack
    -- Throne of the Four Winds
    SetDefaultOnTheFly(93131)	-- Ice Patch
    SetDefaultOnTheFly(86206)	-- Soothing Breeze
    SetDefaultOnTheFly(93122)	-- Toxic Spores
    SetDefaultOnTheFly(93058)	-- Slicing Gale
    SetDefaultOnTheFly(93260)	-- Ice Storm
    SetDefaultOnTheFly(93295)	-- Lightning Rod
    SetDefaultOnTheFly(87873)	-- Static Shock
    SetDefaultOnTheFly(87856)	-- Squall Line
    SetDefaultOnTheFly(88427)	-- Electrocute
    -------------------------------------------------
    -------------------- Phase 3 --------------------
    -------------------------------------------------
    -- Zul'Aman (Dungeon)
    -- Zul'Gurub (Dungeon)
    -- Firelands
    SetDefaultOnTheFly(99506)	-- Widows Kiss
    SetDefaultOnTheFly(97202)	-- Fiery Web Spin
    SetDefaultOnTheFly(49026)	-- Fixate
    SetDefaultOnTheFly(97079)	-- Seeping Venom
    SetDefaultOnTheFly(99389)	-- Imprinted
    SetDefaultOnTheFly(101296)	-- Fiero Blast
    SetDefaultOnTheFly(100723)	-- Gushing Wound
    SetDefaultOnTheFly(101729)	-- Blazing Claw
    SetDefaultOnTheFly(100640)	-- Harsh Winds
    SetDefaultOnTheFly(100555)	-- Smouldering Roots
    SetDefaultOnTheFly(99837)	-- Crystal Prison
    SetDefaultOnTheFly(99937)	-- Jagged Tear
    SetDefaultOnTheFly(99403)	-- Tormented
    SetDefaultOnTheFly(99256)	-- Torment
    SetDefaultOnTheFly(99252)	-- Blaze of Glory
    SetDefaultOnTheFly(99516)	-- Countdown
    SetDefaultOnTheFly(98450)	-- Searing Seeds
    SetDefaultOnTheFly(98565)	-- Burning Orb
    SetDefaultOnTheFly(98313)	-- Magma Blast
    SetDefaultOnTheFly(99145)	-- Blazing Heat
    SetDefaultOnTheFly(99399)	-- Burning Wound
    SetDefaultOnTheFly(99613)	-- Molten Blast
    SetDefaultOnTheFly(100293)	-- Lava Wave
    SetDefaultOnTheFly(100675)	-- Dreadflame
    SetDefaultOnTheFly(100249)	-- Combustion
    SetDefaultOnTheFly(99532)	-- Melt Armor
    -------------------------------------------------
    -------------------- Phase 4 --------------------
    -------------------------------------------------
    -- Dragon Soul
    SetDefaultOnTheFly(103541)	-- Safe
    SetDefaultOnTheFly(103536)	-- Warning
    SetDefaultOnTheFly(103534)	-- Danger
    SetDefaultOnTheFly(103687)	-- Crush Armor
    SetDefaultOnTheFly(108570)	-- Black Blood of the Earth
    SetDefaultOnTheFly(103434)	-- Disrupting Shadows
    SetDefaultOnTheFly(105171)	-- Deep Corruption
    SetDefaultOnTheFly(105465)	-- Lighting Storm
    SetDefaultOnTheFly(104451)	-- Ice Tomb
    SetDefaultOnTheFly(109325)	-- Frostflake
    SetDefaultOnTheFly(105289)	-- Shattered Ice
    SetDefaultOnTheFly(105285)	-- Target
    SetDefaultOnTheFly(105259)	-- Watery Entrenchment
    SetDefaultOnTheFly(107061)	-- Ice Lance
    SetDefaultOnTheFly(109075)	-- Fading Light
    SetDefaultOnTheFly(108043)	-- Sunder Armor
    SetDefaultOnTheFly(107558)	-- Degeneration
    SetDefaultOnTheFly(107567)	-- Brutal Strike
    SetDefaultOnTheFly(108046)	-- Shockwave
    SetDefaultOnTheFly(110214)	-- Shockwave
    SetDefaultOnTheFly(105479)	-- Searing Plasma
    SetDefaultOnTheFly(105490)	-- Fiery Grip
    SetDefaultOnTheFly(105563)	-- Grasping Tendrils
    SetDefaultOnTheFly(106199)	-- Blood Corruption: Death
    SetDefaultOnTheFly(105841)	-- Degenerative Bite
    SetDefaultOnTheFly(106385)	-- Crush
    SetDefaultOnTheFly(106730)	-- Tetanus
    SetDefaultOnTheFly(106444)	-- Impale
    SetDefaultOnTheFly(106794)	-- Shrapnel (Target)
    SetDefaultOnTheFly(105445)	-- Blistering Heat
    SetDefaultOnTheFly(108649)	-- Corrupting Parasite
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