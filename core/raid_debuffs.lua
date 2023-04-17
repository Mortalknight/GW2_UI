local _, GW = ...
GW.DEFAULTS = GW.DEFAULTS or {}
GW.DEFAULTS.RAIDDEBUFFS = {}
GW.ImportendRaidDebuff = {}

local function RemoveOldRaidDebuffsFormProfiles()
    local profiles = GW2UI_SETTINGS_PROFILES or {}
    for k, _ in pairs(profiles) do
        if profiles[k] then
            if profiles[k].RAIDDEBUFFS then
                for id, _ in pairs(profiles[k].RAIDDEBUFFS) do
                    if GW.DEFAULTS.RAIDDEBUFFS[id] == nil then
                        GW2UI_SETTINGS_PROFILES[k].RAIDDEBUFFS[id] = nil
                    end
                end
            end
        end
    end
    --private layouts
    if GW2UI_SETTINGS_DB_03 and GW2UI_SETTINGS_DB_03.RAIDDEBUFFS then
        for id, _ in pairs(GW2UI_SETTINGS_DB_03.RAIDDEBUFFS) do
            if GW.DEFAULTS.RAIDDEBUFFS[id] == nil then
                GW2UI_SETTINGS_DB_03.RAIDDEBUFFS[id] = nil
            end
        end
    end
end
GW.RemoveOldRaidDebuffsFormProfiles = RemoveOldRaidDebuffsFormProfiles

local function SetDefaultOnTheFly(id)
    GW.DEFAULTS.RAIDDEBUFFS[id] = true
    GW.ImportendRaidDebuff[id] = true
end
----------------------------------------------------------
-------------------- Mythic+ Specific --------------------
----------------------------------------------------------
-- General Affix
    SetDefaultOnTheFly(226512) -- Sanguine
    SetDefaultOnTheFly(240559) -- Grievous
    SetDefaultOnTheFly(240443) -- Bursting
-- Dragonflight Season 1
    SetDefaultOnTheFly(396369) -- Mark of Lightning
    SetDefaultOnTheFly(396364) -- Mark of Wind

----------------------------------------------------------
----------------- Dragonflight (Season 1)) ---------------
----------------------------------------------------------
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
---------------- Dragonflight (Season 2) -----------------
----------------------------------------------------------
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