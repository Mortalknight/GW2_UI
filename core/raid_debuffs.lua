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
----------------------------------------------------------
-------------------- Mythic+ Specific --------------------
----------------------------------------------------------
-- General Affix
    SetDefaultOnTheFly(226512) -- Sanguine
    SetDefaultOnTheFly(240559) -- Grievous
    SetDefaultOnTheFly(240443) -- Bursting
    SetDefaultOnTheFly(409492) -- Afflicted Cry
----------------------------------------------------------
----------------- Dragonflight Dungeons ------------------
----------------------------------------------------------
-- Dawn of the Infinite
    SetDefaultOnTheFly(413041) -- Sheared Lifespan 1
    SetDefaultOnTheFly(416716) -- Sheared Lifespan 2
    SetDefaultOnTheFly(413013) -- Chronoshear
    SetDefaultOnTheFly(413208) -- Sand Buffeted
    SetDefaultOnTheFly(408084) -- Necrofrost
    SetDefaultOnTheFly(413142) -- Eon Shatter
    SetDefaultOnTheFly(409266) -- Extinction Blast 1
    SetDefaultOnTheFly(414300) -- Extinction Blast 2
    SetDefaultOnTheFly(401667) -- Time Stasis
    SetDefaultOnTheFly(412027) -- Chronal Burn
    SetDefaultOnTheFly(400681) -- Spark of Tyr
    SetDefaultOnTheFly(404141) -- Chrono-faded
    SetDefaultOnTheFly(407147) -- Blight Seep
    SetDefaultOnTheFly(410497) -- Mortal Wounds
    SetDefaultOnTheFly(418009) -- Serrated Arrows
    SetDefaultOnTheFly(407406) -- Corrosion
    SetDefaultOnTheFly(401420) -- Sand Stomp
    SetDefaultOnTheFly(403912) -- Accelerating Time
    SetDefaultOnTheFly(403910) -- Decaying Time
-- Brackenhide Hollow
    SetDefaultOnTheFly(385361) -- Rotting Sickness
    SetDefaultOnTheFly(378020) -- Gash Frenzy
    SetDefaultOnTheFly(385356) -- Ensnaring Trap
    SetDefaultOnTheFly(373917) -- Decaystrike 1
    SetDefaultOnTheFly(377864) -- Infectious Spit
    SetDefaultOnTheFly(376933) -- Grasping Vines
    SetDefaultOnTheFly(384425) -- Smell Like Meat
    SetDefaultOnTheFly(373912) -- Decaystrike 2
    SetDefaultOnTheFly(373896) -- Withering Rot
    SetDefaultOnTheFly(377844) -- Bladestorm 1
    SetDefaultOnTheFly(378229) -- Marked for Butchery
    SetDefaultOnTheFly(381835) -- Bladestorm 2
    SetDefaultOnTheFly(376149) -- Choking Rotcloud
    SetDefaultOnTheFly(384725) -- Feeding Frenzy
    SetDefaultOnTheFly(385303) -- Teeth Trap
    SetDefaultOnTheFly(368299) -- Toxic Trap
    SetDefaultOnTheFly(384970) -- Scented Meat 1
    SetDefaultOnTheFly(384974) -- Scented Meat 2
    SetDefaultOnTheFly(368091) -- Infected Bite
    SetDefaultOnTheFly(385185) -- Disoriented
    SetDefaultOnTheFly(387210) -- Decaying Strength
    SetDefaultOnTheFly(382808) -- Withering Contagion 1
    SetDefaultOnTheFly(383087) -- Withering Contagion 2
    SetDefaultOnTheFly(382723) -- Crushing Smash
    SetDefaultOnTheFly(382787) -- Decay Claws
    SetDefaultOnTheFly(385058) -- Withering Poison
    SetDefaultOnTheFly(383399) -- Rotting Surge
    SetDefaultOnTheFly(367484) -- Vicious Clawmangle
    SetDefaultOnTheFly(367521) -- Bone Bolt
    SetDefaultOnTheFly(368081) -- Withering
    SetDefaultOnTheFly(374245) -- Rotting Creek
    SetDefaultOnTheFly(367481) -- Bloody Bite
-- Halls of Infusion
    SetDefaultOnTheFly(387571) -- Focused Deluge
    SetDefaultOnTheFly(383935) -- Spark Volley
    SetDefaultOnTheFly(385555) -- Gulp
    SetDefaultOnTheFly(384524) -- Titanic Fist
    SetDefaultOnTheFly(385963) -- Frost Shock
    SetDefaultOnTheFly(374389) -- Gulp Swog Toxin
    SetDefaultOnTheFly(386743) -- Polar Winds
    SetDefaultOnTheFly(389179) -- Power Overload
    SetDefaultOnTheFly(389181) -- Power Field
    SetDefaultOnTheFly(257274) -- Vile Coating
    SetDefaultOnTheFly(375384) -- Rumbling Earth
    SetDefaultOnTheFly(374563) -- Dazzle
    SetDefaultOnTheFly(389446) -- Nullifying Pulse
    SetDefaultOnTheFly(374615) -- Cheap Shot
    SetDefaultOnTheFly(391610) -- Blinding Winds
    SetDefaultOnTheFly(374724) -- Molten Subduction
    SetDefaultOnTheFly(385168) -- Thunderstorm
    SetDefaultOnTheFly(387359) -- Waterlogged
    SetDefaultOnTheFly(391613) -- Creeping Mold
    SetDefaultOnTheFly(374706) -- Pyretic Burst
    SetDefaultOnTheFly(389443) -- Purifying Blast
    SetDefaultOnTheFly(374339) -- Demoralizing Shout
    SetDefaultOnTheFly(374020) -- Containment Beam
    SetDefaultOnTheFly(391634) -- Deep Chill
    SetDefaultOnTheFly(393444) -- Gushing Wound
-- Neltharus
    SetDefaultOnTheFly(374534) -- Heated Swings
    SetDefaultOnTheFly(373735) -- Dragon Strike
    SetDefaultOnTheFly(377018) -- Molten Gold
    SetDefaultOnTheFly(374842) -- Blazing Aegis 1
    SetDefaultOnTheFly(392666) -- Blazing Aegis 2
    SetDefaultOnTheFly(375890) -- Magma Eruption
    SetDefaultOnTheFly(396332) -- Fiery Focus
    SetDefaultOnTheFly(389059) -- Slag Eruption
    SetDefaultOnTheFly(376784) -- Flame Vulnerability
    SetDefaultOnTheFly(377542) -- Burning Ground
    SetDefaultOnTheFly(374451) -- Burning Chain
    SetDefaultOnTheFly(372461) -- Imbued Magma
    SetDefaultOnTheFly(378818) -- Magma Conflagration
    SetDefaultOnTheFly(377522) -- Burning Pursuit
    SetDefaultOnTheFly(375204) -- Liquid Hot Magma
    SetDefaultOnTheFly(374482) -- Grounding Chain
    SetDefaultOnTheFly(372971) -- Reverberating Slam
    SetDefaultOnTheFly(384161) -- Mote of Combustion
    SetDefaultOnTheFly(374854) -- Erupted Ground
    SetDefaultOnTheFly(373089) -- Scorching Fusillade
    SetDefaultOnTheFly(372224) -- Dragonbone Axe
    SetDefaultOnTheFly(372570) -- Bold Ambush
    SetDefaultOnTheFly(372459) -- Burning
    SetDefaultOnTheFly(372208) -- Djaradin Lava
-- Uldaman: Legacy of Tyr
    SetDefaultOnTheFly(368996) -- Purging Flames
    SetDefaultOnTheFly(369792) -- Skullcracker
    SetDefaultOnTheFly(372718) -- Earthen Shards
    SetDefaultOnTheFly(382071) -- Resonating Orb
    SetDefaultOnTheFly(377405) -- Time Sink
    SetDefaultOnTheFly(369006) -- Burning Heat
    SetDefaultOnTheFly(369110) -- Unstable Embers
    SetDefaultOnTheFly(375286) -- Searing Cannonfire
    SetDefaultOnTheFly(372652) -- Resonating Orb
    SetDefaultOnTheFly(377825) -- Burning Pitch
    SetDefaultOnTheFly(369411) -- Sonic Burst
    SetDefaultOnTheFly(382576) -- Scorn of Tyr
    SetDefaultOnTheFly(369366) -- Trapped in Stone
    SetDefaultOnTheFly(369365) -- Curse of Stone
    SetDefaultOnTheFly(369419) -- Venomous Fangs
    SetDefaultOnTheFly(377486) -- Time Blade
    SetDefaultOnTheFly(369818) -- Diseased Bite
    SetDefaultOnTheFly(377732) -- Jagged Bite
    SetDefaultOnTheFly(369828) -- Chomp
    SetDefaultOnTheFly(369811) -- Brutal Slam
    SetDefaultOnTheFly(376325) -- Eternity Zone
    SetDefaultOnTheFly(369337) -- Difficult Terrain
    SetDefaultOnTheFly(376333) -- Temporal Zone
    SetDefaultOnTheFly(377510) -- Stolen Time
-- Ruby Life Pools
    SetDefaultOnTheFly(392406) -- Thunderclap
    SetDefaultOnTheFly(372820) -- Scorched Earth
    SetDefaultOnTheFly(384823) -- Inferno 1
    SetDefaultOnTheFly(373692) -- Inferno 2
    SetDefaultOnTheFly(381862) -- Infernocore
    SetDefaultOnTheFly(372860) -- Searing Wounds
    SetDefaultOnTheFly(373869) -- Burning Touch
    SetDefaultOnTheFly(385536) -- Flame Dance
    SetDefaultOnTheFly(381518) -- Winds of Change
    SetDefaultOnTheFly(372858) -- Searing Blows
    SetDefaultOnTheFly(372682) -- Primal Chill 1
    SetDefaultOnTheFly(373589) -- Primal Chill 2
    SetDefaultOnTheFly(373693) -- Living Bomb
    SetDefaultOnTheFly(392924) -- Shock Blast
    SetDefaultOnTheFly(381515) -- Stormslam
    SetDefaultOnTheFly(396411) -- Primal Overload
    SetDefaultOnTheFly(384773) -- Flaming Embers
    SetDefaultOnTheFly(392451) -- Flashfire
    SetDefaultOnTheFly(372697) -- Jagged Earth
    SetDefaultOnTheFly(372047) -- Flurry
    SetDefaultOnTheFly(372963) -- Chillstorm
-- The Nokhud Offensive
    SetDefaultOnTheFly(382628) -- Surge of Power
    SetDefaultOnTheFly(386025) -- Tempest
    SetDefaultOnTheFly(381692) -- Swift Stab
    SetDefaultOnTheFly(387615) -- Grasp of the Dead
    SetDefaultOnTheFly(387629) -- Rotting Wind
    SetDefaultOnTheFly(386912) -- Stormsurge Cloud
    SetDefaultOnTheFly(395669) -- Aftershock
    SetDefaultOnTheFly(384134) -- Pierce
    SetDefaultOnTheFly(388451) -- Stormcaller's Fury 1
    SetDefaultOnTheFly(388446) -- Stormcaller's Fury 2
    SetDefaultOnTheFly(395035) -- Shatter Soul
    SetDefaultOnTheFly(376899) -- Crackling Cloud
    SetDefaultOnTheFly(384492) -- Hunter's Mark
    SetDefaultOnTheFly(376730) -- Stormwinds
    SetDefaultOnTheFly(376894) -- Crackling Upheaval
    SetDefaultOnTheFly(388801) -- Mortal Strike
    SetDefaultOnTheFly(376827) -- Conductive Strike
    SetDefaultOnTheFly(376864) -- Static Spear
    SetDefaultOnTheFly(375937) -- Rending Strike
    SetDefaultOnTheFly(376634) -- Iron Spear
-- The Azure Vault
    SetDefaultOnTheFly(388777) -- Oppressive Miasma
    SetDefaultOnTheFly(386881) -- Frost Bomb
    SetDefaultOnTheFly(387150) -- Frozen Ground
    SetDefaultOnTheFly(387564) -- Mystic Vapors
    SetDefaultOnTheFly(385267) -- Crackling Vortex
    SetDefaultOnTheFly(386640) -- Tear Flesh
    SetDefaultOnTheFly(374567) -- Explosive Brand
    SetDefaultOnTheFly(374523) -- Arcane Roots
    SetDefaultOnTheFly(375596) -- Erratic Growth Channel
    SetDefaultOnTheFly(375602) -- Erratic Growth
    SetDefaultOnTheFly(370764) -- Piercing Shards
    SetDefaultOnTheFly(384978) -- Dragon Strike
    SetDefaultOnTheFly(375649) -- Infused Ground
    SetDefaultOnTheFly(387151) -- Icy Devastator
    SetDefaultOnTheFly(377488) -- Icy Bindings
    SetDefaultOnTheFly(374789) -- Infused Strike
    SetDefaultOnTheFly(371007) -- Splintering Shards
    SetDefaultOnTheFly(375591) -- Sappy Burst
    SetDefaultOnTheFly(385409) -- Ouch, ouch, ouch!
    SetDefaultOnTheFly(386549) -- Waking Bane
-- Algeth'ar Academy
    SetDefaultOnTheFly(389033) -- Lasher Toxin
    SetDefaultOnTheFly(391977) -- Oversurge
    SetDefaultOnTheFly(386201) -- Corrupted Mana
    SetDefaultOnTheFly(389011) -- Overwhelming Power
    SetDefaultOnTheFly(387932) -- Astral Whirlwind
    SetDefaultOnTheFly(396716) -- Splinterbark
    SetDefaultOnTheFly(388866) -- Mana Void
    SetDefaultOnTheFly(386181) -- Mana Bomb
    SetDefaultOnTheFly(388912) -- Severing Slash
    SetDefaultOnTheFly(377344) -- Peck
    SetDefaultOnTheFly(376997) -- Savage Peck
    SetDefaultOnTheFly(388984) -- Vicious Ambush
    SetDefaultOnTheFly(388544) -- Barkbreaker
    SetDefaultOnTheFly(377008) -- Deafening Screech
    ----------------------------------------------------------
    ---------------- Dragonflight (Season 3) -----------------
    ----------------------------------------------------------
-- Darkheart Thicket
    SetDefaultOnTheFly(198408) -- Nightfall
    SetDefaultOnTheFly(196376) -- Grievous Tear
    SetDefaultOnTheFly(200182) -- Festering Rip
    SetDefaultOnTheFly(200238) -- Feed on the Weak
    SetDefaultOnTheFly(200289) -- Growing Paranoia
    SetDefaultOnTheFly(204667) -- Nightmare Breath
    SetDefaultOnTheFly(204611) -- Crushing Grip
    SetDefaultOnTheFly(199460) -- Falling Rocks
    SetDefaultOnTheFly(200329) -- Overwhelming Terror
    SetDefaultOnTheFly(191326) -- Breath of Corruption
    SetDefaultOnTheFly(204243) -- Tormenting Eye
    SetDefaultOnTheFly(225484) -- Grievous Rip
    SetDefaultOnTheFly(200642) -- Despair
    SetDefaultOnTheFly(199063) -- Strangling Roots
    SetDefaultOnTheFly(198477) -- Fixate
    SetDefaultOnTheFly(204246) -- Tormenting Fear
    SetDefaultOnTheFly(198904) -- Poison Spear
    SetDefaultOnTheFly(200684) -- Nightmare Toxin
    SetDefaultOnTheFly(200243) -- Waking Nightmare
    SetDefaultOnTheFly(200580) -- Maddening Roar
    SetDefaultOnTheFly(200771) -- Propelling Charge
    SetDefaultOnTheFly(200273) -- Cowardice
    SetDefaultOnTheFly(201365) -- Darksoul Drain
    SetDefaultOnTheFly(201839) -- Curse of Isolation
    SetDefaultOnTheFly(201902) -- Scorching Shot
-- Black Rook Hold
    SetDefaultOnTheFly(202019) -- Shadow Bolt Volley
    SetDefaultOnTheFly(197521) -- Blazing Trail
    SetDefaultOnTheFly(197478) -- Dark Rush
    SetDefaultOnTheFly(197546) -- Brutal Glaive
    SetDefaultOnTheFly(198079) -- Hateful Gaze
    SetDefaultOnTheFly(224188) -- Hateful Charge
    SetDefaultOnTheFly(201733) -- Stinging Swarm
    SetDefaultOnTheFly(194966) -- Soul Echoes
    SetDefaultOnTheFly(198635) -- Unerring Shear
    SetDefaultOnTheFly(225909) -- Soul Venom
    SetDefaultOnTheFly(198501) -- Fel Vomitus
    SetDefaultOnTheFly(198446) -- Fel Vomit
    SetDefaultOnTheFly(200084) -- Soul Blade
    SetDefaultOnTheFly(197821) -- Felblazed Ground
    SetDefaultOnTheFly(203163) -- Sic Bats!
    SetDefaultOnTheFly(199368) -- Legacy of the Ravencrest
    SetDefaultOnTheFly(225732) -- Strike Down
    SetDefaultOnTheFly(199168) -- Itchy!
    SetDefaultOnTheFly(225963) -- Bloodthirsty Leap
    SetDefaultOnTheFly(214002) -- Raven's Dive
    SetDefaultOnTheFly(197974) -- Bonecrushing Strike I
    SetDefaultOnTheFly(200261) -- Bonecrushing Strike II
    SetDefaultOnTheFly(204896) -- Drain Life
    SetDefaultOnTheFly(199097) -- Cloud of Hypnosis
-- Waycrest Manor
    SetDefaultOnTheFly(260703) -- Unstable Runic Mark
    SetDefaultOnTheFly(261438) -- Wasting Strike
    SetDefaultOnTheFly(261140) -- Virulent Pathogen
    SetDefaultOnTheFly(260900) -- Soul Manipulation I
    SetDefaultOnTheFly(260926) -- Soul Manipulation II
    SetDefaultOnTheFly(260741) -- Jagged Nettles
    SetDefaultOnTheFly(268086) -- Aura of Dread
    SetDefaultOnTheFly(264712) -- Rotten Expulsion
    SetDefaultOnTheFly(271178) -- Ravaging Leap
    SetDefaultOnTheFly(264040) -- Uprooted Thorns
    SetDefaultOnTheFly(265407) -- Dinner Bell
    SetDefaultOnTheFly(265761) -- Thorned Barrage
    SetDefaultOnTheFly(268125) -- Aura of Thorns
    SetDefaultOnTheFly(268080) -- Aura of Apathy
    SetDefaultOnTheFly(264050) -- Infected Thorn
    SetDefaultOnTheFly(260569) -- Wildfire
    SetDefaultOnTheFly(263943) -- Etch
    SetDefaultOnTheFly(264378) -- Fragment Soul
    SetDefaultOnTheFly(267907) -- Soul Thorns
    SetDefaultOnTheFly(264520) -- Severing Serpent
    SetDefaultOnTheFly(264105) -- Runic Mark
    SetDefaultOnTheFly(265881) -- Decaying Touch
    SetDefaultOnTheFly(265882) -- Lingering Dread
    SetDefaultOnTheFly(278456) -- Infest I
    SetDefaultOnTheFly(278444) -- Infest II
    SetDefaultOnTheFly(265880) -- Dread Mark
-- Atal'Dazar
    SetDefaultOnTheFly(250585) -- Toxic Pool
    SetDefaultOnTheFly(258723) -- Grotesque Pool
    SetDefaultOnTheFly(260668) -- Transfusion I
    SetDefaultOnTheFly(260666) -- Transfusion II
    SetDefaultOnTheFly(255558) -- Tainted Blood
    SetDefaultOnTheFly(250036) -- Shadowy Remains
    SetDefaultOnTheFly(257483) -- Pile of Bones
    SetDefaultOnTheFly(253562) -- Wildfire
    SetDefaultOnTheFly(254959) -- Soulburn
    SetDefaultOnTheFly(255814) -- Rending Maul
    SetDefaultOnTheFly(255582) -- Molten Gold
    SetDefaultOnTheFly(252687) -- Venomfang Strike
    SetDefaultOnTheFly(255041) -- Terrifying Screech
    SetDefaultOnTheFly(255567) -- Frenzied Charge
    SetDefaultOnTheFly(255836) -- Transfusion Boss I
    SetDefaultOnTheFly(255835) -- Transfusion Boss II
    SetDefaultOnTheFly(250372) -- Lingering Nausea
    SetDefaultOnTheFly(257407) -- Pursuit
    SetDefaultOnTheFly(255434) -- Serrated Teeth
    SetDefaultOnTheFly(255371) -- Terrifying Visage
-- Everbloom
    SetDefaultOnTheFly(427513) -- Noxious Discharge
    SetDefaultOnTheFly(428834) -- Verdant Eruption
    SetDefaultOnTheFly(427510) -- Noxious Charge
    SetDefaultOnTheFly(427863) -- Frostbolt I
    SetDefaultOnTheFly(169840) -- Frostbolt II
    SetDefaultOnTheFly(428084) -- Glacial Fusion
    SetDefaultOnTheFly(426991) -- Blazing Cinders
    SetDefaultOnTheFly(169179) -- Colossal Blow
    SetDefaultOnTheFly(164886) -- Dreadpetal Pollen
    SetDefaultOnTheFly(169445) -- Noxious Eruption
    SetDefaultOnTheFly(164294) -- Unchecked Growth I
    SetDefaultOnTheFly(164302) -- Unchecked Growth II
    SetDefaultOnTheFly(165123) -- Venom Burst
    SetDefaultOnTheFly(169658) -- Poisonous Claws
    SetDefaultOnTheFly(169839) -- Pyroblast
    SetDefaultOnTheFly(164965) -- Choking Vines
-- Throne of the Tides
    SetDefaultOnTheFly(429048) -- Flame Shock
    SetDefaultOnTheFly(427668) -- Festering Shockwave
    SetDefaultOnTheFly(427670) -- Crushing Claw
    SetDefaultOnTheFly(76363) -- Wave of Corruption
    SetDefaultOnTheFly(426660) -- Razor Jaws
    SetDefaultOnTheFly(426727) -- Acid Barrage
    SetDefaultOnTheFly(428404) -- Blotting Darkness
    SetDefaultOnTheFly(428403) -- Grimy
    SetDefaultOnTheFly(426663) -- Ravenous Pursuit
    SetDefaultOnTheFly(426783) -- Mind Flay
    SetDefaultOnTheFly(75992) -- Lightning Surge
    SetDefaultOnTheFly(428868) -- Putrid Roar
    SetDefaultOnTheFly(428407) -- Blotting Barrage
    SetDefaultOnTheFly(427559) -- Bubbling Ooze
    SetDefaultOnTheFly(76516) -- Poisoned Spear
    SetDefaultOnTheFly(428542) -- Crushing Depths
    SetDefaultOnTheFly(426741) -- Shellbreaker
    SetDefaultOnTheFly(76820) -- Hex
    SetDefaultOnTheFly(426608) -- Null Blast
    SetDefaultOnTheFly(426688) -- Volatile Acid
    SetDefaultOnTheFly(428103) -- Frostbolt
----------------------------------------------------------
---------------- Dragonflight (Season 2) -----------------
----------------------------------------------------------
-- Freehold
    SetDefaultOnTheFly(258323) -- Infected Wound
    SetDefaultOnTheFly(257775) -- Plague Step
    SetDefaultOnTheFly(257908) -- Oiled Blade
    SetDefaultOnTheFly(257436) -- Poisoning Strike
    SetDefaultOnTheFly(274389) -- Rat Traps
    SetDefaultOnTheFly(274555) -- Scabrous Bites
    SetDefaultOnTheFly(258875) -- Blackout Barrel
    SetDefaultOnTheFly(256363) -- Ripper Punch
-- Neltharion's Lair
    SetDefaultOnTheFly(199705) -- Devouring
    SetDefaultOnTheFly(199178) -- Spiked Tongue
    SetDefaultOnTheFly(210166) -- Toxic Retch 1
    SetDefaultOnTheFly(217851) -- Toxic Retch 2
    SetDefaultOnTheFly(193941) -- Impaling Shard
    SetDefaultOnTheFly(183465) -- Viscid Bile
    SetDefaultOnTheFly(226296) -- Piercing Shards
    SetDefaultOnTheFly(226388) -- Rancid Ooze
    SetDefaultOnTheFly(200154) -- Burning Hatred
    SetDefaultOnTheFly(183407) -- Acid Splatter
    SetDefaultOnTheFly(215898) -- Crystalline Ground
    SetDefaultOnTheFly(188494) -- Rancid Maw
    SetDefaultOnTheFly(192800) -- Choking Dust
-- Underrot
    SetDefaultOnTheFly(265468) -- Withering Curse
    SetDefaultOnTheFly(278961) -- Decaying Mind
    SetDefaultOnTheFly(259714) -- Decaying Spores
    SetDefaultOnTheFly(272180) -- Death Bolt
    SetDefaultOnTheFly(272609) -- Maddening Gaze
    SetDefaultOnTheFly(269301) -- Putrid Blood
    SetDefaultOnTheFly(265533) -- Blood Maw
    SetDefaultOnTheFly(265019) -- Savage Cleave
    SetDefaultOnTheFly(265377) -- Hooked Snare
    SetDefaultOnTheFly(265625) -- Dark Omen
    SetDefaultOnTheFly(260685) -- Taint of G'huun
    SetDefaultOnTheFly(266107) -- Thirst for Blood
    SetDefaultOnTheFly(260455) -- Serrated Fangs
-- Vortex Pinnacle
    SetDefaultOnTheFly(87618) -- Static Cling
    SetDefaultOnTheFly(410870) -- Cyclone
    SetDefaultOnTheFly(86292) -- Cyclone Shield
    SetDefaultOnTheFly(88282) -- Upwind of Altairus
    SetDefaultOnTheFly(88286) -- Downwind of Altairus
    SetDefaultOnTheFly(410997) -- Rushing Wind
    SetDefaultOnTheFly(411003) -- Turbulence
    SetDefaultOnTheFly(87771) -- Crusader Strike
    SetDefaultOnTheFly(87759) -- Shockwave
    SetDefaultOnTheFly(88314) -- Twisting Winds
    SetDefaultOnTheFly(76622) -- Sunder Armor
    SetDefaultOnTheFly(88171) -- Hurricane
    SetDefaultOnTheFly(88182) -- Lethargic Poison
---------------------------------------------------------
------------ Amirdrassil: The Dream's Hope --------------
---------------------------------------------------------
-- Gnarlroot
    SetDefaultOnTheFly(421972) -- Controlled Burn
    SetDefaultOnTheFly(424734) -- Uprooted Agony
    SetDefaultOnTheFly(426106) -- Dreadfire Barrage
    SetDefaultOnTheFly(425002) -- Ember-Charred I
    SetDefaultOnTheFly(421038) -- Ember-Charred II
-- Igira the Cruel
    SetDefaultOnTheFly(414367) -- Gathering Torment
    SetDefaultOnTheFly(424065) -- Wracking Skewer I
    SetDefaultOnTheFly(416056) -- Wracking Skever II
    SetDefaultOnTheFly(414888) -- Blistering Spear
-- Volcoross
    SetDefaultOnTheFly(419054) -- Molten Venom
    SetDefaultOnTheFly(421207) -- Coiling Flames
    SetDefaultOnTheFly(423494) -- Tidal Blaze
    SetDefaultOnTheFly(423759) -- Serpent's Crucible
-- Council of Dreams
    SetDefaultOnTheFly(420948) -- Barreling Charge
    SetDefaultOnTheFly(421032) -- Captivating Finale
    SetDefaultOnTheFly(420858) -- Poisonous Javelin
    SetDefaultOnTheFly(418589) -- Polymorph Bomb
    SetDefaultOnTheFly(421031) -- Song of the Dragon
    SetDefaultOnTheFly(426390) -- Corrosive Pollen
-- Larodar, Keeper of the Flame
    SetDefaultOnTheFly(425888) -- Igniting Growth
    SetDefaultOnTheFly(426249) -- Blazing Coalescence
    SetDefaultOnTheFly(421594) -- Smoldering Suffocation
    SetDefaultOnTheFly(427299) -- Flash Fire
    SetDefaultOnTheFly(428901) -- Ashen Devastation
-- Nymue, Weaver of the Cycle
    SetDefaultOnTheFly(423195) -- Inflorescence
    SetDefaultOnTheFly(427137) -- Threads of Life I
    SetDefaultOnTheFly(427138) -- Threads of Life II
    SetDefaultOnTheFly(426520) -- Weaver's Burden
    SetDefaultOnTheFly(428273) -- Woven Resonance
-- Smolderon
    SetDefaultOnTheFly(426018) -- Seeking Inferno
    SetDefaultOnTheFly(421455) -- Overheated
    SetDefaultOnTheFly(421643) -- Emberscar's Mark
    SetDefaultOnTheFly(421656) -- Cauterizing Wound
    SetDefaultOnTheFly(425574) -- Lingering Burn
-- Tindral Sageswift, Seer of the Flame
    SetDefaultOnTheFly(427297) -- Flame Surge
    SetDefaultOnTheFly(424581) -- Fiery Growth
    SetDefaultOnTheFly(424580) -- Falling Stars
    SetDefaultOnTheFly(424578) -- Blazing Mushroom
    SetDefaultOnTheFly(424579) -- Suppressive Ember
    SetDefaultOnTheFly(424495) -- Mass Entanblement
    SetDefaultOnTheFly(424665) -- Seed of Flame
-- Fyrakk the Blazing
---------------------------------------------------------
------------ Aberrus, the Shadowed Crucible -------------
---------------------------------------------------------
-- Kazzara
    SetDefaultOnTheFly(406530) -- Riftburn
    SetDefaultOnTheFly(402420) -- Molten Scar
    SetDefaultOnTheFly(402253) -- Ray of Anguish
    SetDefaultOnTheFly(406525) -- Dread Rift
    SetDefaultOnTheFly(404743) -- Terror Claws
-- Molgoth
    SetDefaultOnTheFly(405084) -- Lingering Umbra
    SetDefaultOnTheFly(405645) -- Engulfing Heat
    SetDefaultOnTheFly(405642) -- Blistering Twilight
    SetDefaultOnTheFly(402617) -- Blazing Heat
    SetDefaultOnTheFly(401809) -- Corrupting Shadow
    SetDefaultOnTheFly(405394) -- Shadowflame
-- Experimentation of Dracthyr
    SetDefaultOnTheFly(406317) -- Mutilation 1
    SetDefaultOnTheFly(406365) -- Mutilation 2
    SetDefaultOnTheFly(405392) -- Disintegrate 1
    SetDefaultOnTheFly(405423) -- Disintegrate 2
    SetDefaultOnTheFly(406233) -- Deep Breath
    SetDefaultOnTheFly(407327) -- Unstable Essence
    SetDefaultOnTheFly(406313) -- Infused Strikes
    SetDefaultOnTheFly(407302) -- Infused Explosion
-- Zaqali Invasion
    SetDefaultOnTheFly(408873) -- Heavy Cudgel
    SetDefaultOnTheFly(410353) -- Flaming Cudgel
    SetDefaultOnTheFly(407017) -- Vigorous Gale
    SetDefaultOnTheFly(401407) -- Blazing Spear 1
    SetDefaultOnTheFly(401452) -- Blazing Spear 2
    SetDefaultOnTheFly(409275) -- Magma Flow
-- Rashok
    SetDefaultOnTheFly(407547) -- Flaming Upsurge
    SetDefaultOnTheFly(407597) -- Earthen Crush
    SetDefaultOnTheFly(405819) -- Searing Slam
    SetDefaultOnTheFly(408857) -- Doom Flame
-- Zskarn
    SetDefaultOnTheFly(404955) -- Shrapnel Bomb
    SetDefaultOnTheFly(404010) -- Unstable Embers
    SetDefaultOnTheFly(404942) -- Searing Claws
    SetDefaultOnTheFly(403978) -- Blast Wave
    SetDefaultOnTheFly(405592) -- Salvage Parts
    SetDefaultOnTheFly(405462) -- Dragonfire Traps
    SetDefaultOnTheFly(409942) -- Elimination Protocol
-- Magmorax
    SetDefaultOnTheFly(404846) -- Incinerating Maws 1
    SetDefaultOnTheFly(408955) -- Incinerating Maws 2
    SetDefaultOnTheFly(402994) -- Molten Spittle
    SetDefaultOnTheFly(403747) -- Igniting Roar
-- Echo of Neltharion
    SetDefaultOnTheFly(409373) -- Disrupt Earth
    SetDefaultOnTheFly(407220) -- Rushing Shadows 1
    SetDefaultOnTheFly(407182) -- Rushing Shadows 2
    SetDefaultOnTheFly(405484) -- Surrendering to Corruption
    SetDefaultOnTheFly(409058) -- Seeping Lava
    SetDefaultOnTheFly(402120) -- Collapsed Earth
    SetDefaultOnTheFly(407728) -- Sundered Shadow
    SetDefaultOnTheFly(401998) -- Calamitous Strike
    SetDefaultOnTheFly(408160) -- Shadow Strike
    SetDefaultOnTheFly(403846) -- Sweeping Shadows
    SetDefaultOnTheFly(401133) -- Wildshift (Druid)
    SetDefaultOnTheFly(401131) -- Wild Summoning (Warlock)
    SetDefaultOnTheFly(401130) -- Wild Magic (Mage)
    SetDefaultOnTheFly(401135) -- Wild Breath (Evoker)
    SetDefaultOnTheFly(408071) -- Shapeshifter's Fervor
-- Scalecommander Sarkareth
    SetDefaultOnTheFly(403520) -- Embrace of Nothingness
    SetDefaultOnTheFly(401383) -- Oppressing Howl
    SetDefaultOnTheFly(401951) -- Oblivion
    SetDefaultOnTheFly(407496) -- Infinite Duress
---------------------------------------------------------
---------------- Vault of the Incarnates ----------------
---------------------------------------------------------
-- Eranog
    SetDefaultOnTheFly(370648) -- Primal Flow
    SetDefaultOnTheFly(390715) -- Primal Rifts
    SetDefaultOnTheFly(370597) -- Kill Order
-- Terros
    SetDefaultOnTheFly(382776) -- Awakened Earth 1
    SetDefaultOnTheFly(381253) -- Awakened Earth 2
    SetDefaultOnTheFly(386352) -- Rock Blast
    SetDefaultOnTheFly(382458) -- Resonant Aftermath
-- The Primal Council
    SetDefaultOnTheFly(371624) -- Conductive Mark
    SetDefaultOnTheFly(372027) -- Slashing Blaze
    SetDefaultOnTheFly(374039) -- Meteor Axe
-- Sennarth, the Cold Breath
    SetDefaultOnTheFly(371976) -- Chilling Blast
    SetDefaultOnTheFly(372082) -- Enveloping Webs
    SetDefaultOnTheFly(374659) -- Rush
    SetDefaultOnTheFly(374104) -- Wrapped in Webs Slow
    SetDefaultOnTheFly(374503) -- Wrapped in Webs Stun
    SetDefaultOnTheFly(373048) -- Suffocating Webs
-- Dathea, Ascended
    SetDefaultOnTheFly(391686) -- Conductive Mark
    SetDefaultOnTheFly(378277) -- Elemental Equilbrium
    SetDefaultOnTheFly(388290) -- Cyclone
-- Kurog Grimtotem
    SetDefaultOnTheFly(377780) -- Skeletal Fractures
    SetDefaultOnTheFly(372514) -- Frost Bite
    SetDefaultOnTheFly(374554) -- Lava Pool
    SetDefaultOnTheFly(374709) -- Seismic Rupture
    SetDefaultOnTheFly(374023) -- Searing Carnage
    SetDefaultOnTheFly(374427) -- Ground Shatter
    SetDefaultOnTheFly(390920) -- Shocking Burst
    SetDefaultOnTheFly(372458) -- Below Zero
-- Broodkeeper Diurna
    SetDefaultOnTheFly(388920) -- Frozen Shroud
    SetDefaultOnTheFly(378782) -- Mortal Wounds
    SetDefaultOnTheFly(378787) -- Crushing Stoneclaws
    SetDefaultOnTheFly(375620) -- Ionizing Charge
    SetDefaultOnTheFly(375578) -- Flame Sentry
-- Raszageth the Storm-Eater
    SetDefaultOnTheFly(381615) -- Static Charge
    SetDefaultOnTheFly(399713) -- Magnetic Charge
    SetDefaultOnTheFly(385073) -- Ball Lightning
    SetDefaultOnTheFly(377467) -- Fulminating Charge