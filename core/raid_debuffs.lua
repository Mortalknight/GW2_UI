local _, GW = ...
GW.DEFAULTS = GW.DEFAULTS or {}
GW.DEFAULTS.RAIDDEBUFFS = {}
GW.ImportendRaidDebuff = {}

local function SetDefaultOnTheFly(id)
    GW.DEFAULTS.RAIDDEBUFFS[id] = true
    GW.ImportendRaidDebuff[id] = true
end

-------------------- Mythic+ Specific --------------------
-- General Affix
    SetDefaultOnTheFly(209858) -- Necrotic
    SetDefaultOnTheFly(226512) -- Sanguine
    SetDefaultOnTheFly(240559) -- Grievous
    SetDefaultOnTheFly(240443) -- Bursting
-- Shadowlands Season 1
    SetDefaultOnTheFly(342494) -- Belligerent Boast (Prideful)
-- Shadowlands Season 2

------------------ Shadowlands Dungeons ------------------
-- Tazavesh, the Veiled Market
    SetDefaultOnTheFly(350804) -- Collapsing Energy
    SetDefaultOnTheFly(350885) -- Hyperlight Jolt
    SetDefaultOnTheFly(351101) -- Energy Fragmentation
    SetDefaultOnTheFly(346828) -- Sanitizing Field
    SetDefaultOnTheFly(355641) -- Scintillate
    SetDefaultOnTheFly(355451) -- Undertow
    SetDefaultOnTheFly(355581) -- Crackle
    SetDefaultOnTheFly(349999) -- Anima Detonation
    SetDefaultOnTheFly(346961) -- Purging Field
    SetDefaultOnTheFly(351956) -- High-Value Target
    SetDefaultOnTheFly(346297) -- Unstable Explosion
    SetDefaultOnTheFly(347728) -- Flock!
    SetDefaultOnTheFly(356408) -- Ground Stomp
    SetDefaultOnTheFly(347744) -- Quickblade
    SetDefaultOnTheFly(347481) -- Shuri
    SetDefaultOnTheFly(355915) -- Glyph of Restraint
    SetDefaultOnTheFly(350134) -- Infinite Breath
    SetDefaultOnTheFly(350013) -- Gluttonous Feast
    SetDefaultOnTheFly(355465) -- Boulder Throw
    SetDefaultOnTheFly(346116) -- Shearing Swings
    SetDefaultOnTheFly(356011) -- Beam Splicer
-- Halls of Atonement
    SetDefaultOnTheFly(335338) -- Ritual of Woe
    SetDefaultOnTheFly(326891) -- Anguish
    SetDefaultOnTheFly(329321) -- Jagged Swipe 1
    SetDefaultOnTheFly(344993) -- Jagged Swipe 2
    SetDefaultOnTheFly(319603) -- Curse of Stone
    SetDefaultOnTheFly(319611) -- Turned to Stone
    SetDefaultOnTheFly(325876) -- Curse of Obliteration
    SetDefaultOnTheFly(326632) -- Stony Veins
    SetDefaultOnTheFly(323650) -- Haunting Fixation
    SetDefaultOnTheFly(326874) -- Ankle Bites
    SetDefaultOnTheFly(340446) -- Mark of Envy
-- Mists of Tirna Scithe
    SetDefaultOnTheFly(325027) -- Bramble Burst
    SetDefaultOnTheFly(323043) -- Bloodletting
    SetDefaultOnTheFly(322557) -- Soul Split
    SetDefaultOnTheFly(331172) -- Mind Link
    SetDefaultOnTheFly(322563) -- Marked Prey
    SetDefaultOnTheFly(322487) -- Overgrowth 1
    SetDefaultOnTheFly(322486) -- Overgrowth 2
    SetDefaultOnTheFly(328756) -- Repulsive Visage
    SetDefaultOnTheFly(325021) -- Mistveil Tear
    SetDefaultOnTheFly(321891) -- Freeze Tag Fixation
    SetDefaultOnTheFly(325224) -- Anima Injection
    SetDefaultOnTheFly(326092) -- Debilitating Poison
    SetDefaultOnTheFly(325418) -- Volatile Acid
-- Plaguefall
    SetDefaultOnTheFly(336258) -- Solitary Prey
    SetDefaultOnTheFly(331818) -- Shadow Ambush
    SetDefaultOnTheFly(329110) -- Slime Injection
    SetDefaultOnTheFly(325552) -- Cytotoxic Slash
    SetDefaultOnTheFly(336301) -- Web Wrap
    SetDefaultOnTheFly(322358) -- Burning Strain
    SetDefaultOnTheFly(322410) -- Withering Filth
    SetDefaultOnTheFly(328180) -- Gripping Infection
    SetDefaultOnTheFly(320542) -- Wasting Blight
    SetDefaultOnTheFly(340355) -- Rapid Infection
    SetDefaultOnTheFly(328395) -- Venompiercer
    SetDefaultOnTheFly(320512) -- Corroded Claws
    SetDefaultOnTheFly(333406) -- Assassinate
    SetDefaultOnTheFly(332397) -- Shroudweb
    SetDefaultOnTheFly(330069) -- Concentrated Plague
-- The Necrotic Wake
    SetDefaultOnTheFly(321821) -- Disgusting Guts
    SetDefaultOnTheFly(323365) -- Clinging Darkness
    SetDefaultOnTheFly(338353) -- Goresplatter
    SetDefaultOnTheFly(333485) -- Disease Cloud
    SetDefaultOnTheFly(338357) -- Tenderize
    SetDefaultOnTheFly(328181) -- Frigid Cold
    SetDefaultOnTheFly(320170) -- Necrotic Bolt
    SetDefaultOnTheFly(323464) -- Dark Ichor
    SetDefaultOnTheFly(323198) -- Dark Exile
    SetDefaultOnTheFly(343504) -- Dark Grasp
    SetDefaultOnTheFly(343556) -- Morbid Fixation 1
    SetDefaultOnTheFly(338606) -- Morbid Fixation 2
    SetDefaultOnTheFly(324381) -- Chill Scythe
    SetDefaultOnTheFly(320573) -- Shadow Well
    SetDefaultOnTheFly(333492) -- Necrotic Ichor
    SetDefaultOnTheFly(334748) -- Drain FLuids
    SetDefaultOnTheFly(333489) -- Necrotic Breath
    SetDefaultOnTheFly(320717) -- Blood Hunger
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
-- Sanguine Depths
    SetDefaultOnTheFly(326827) -- Dread Bindings
    SetDefaultOnTheFly(326836) -- Curse of Suppression
    SetDefaultOnTheFly(322554) -- Castigate
    SetDefaultOnTheFly(321038) -- Burden Soul
    SetDefaultOnTheFly(328593) -- Agonize
    SetDefaultOnTheFly(325254) -- Iron Spikes
    SetDefaultOnTheFly(335306) -- Barbed Shackles
    SetDefaultOnTheFly(322429) -- Severing Slice
    SetDefaultOnTheFly(334653) -- Engorge
-- Spires of Ascension
    SetDefaultOnTheFly(338729) -- Charged Stomp
    SetDefaultOnTheFly(338747) -- Purifying Blast
    SetDefaultOnTheFly(327481) -- Dark Lance
    SetDefaultOnTheFly(322818) -- Lost Confidence
    SetDefaultOnTheFly(322817) -- Lingering Doubt
    SetDefaultOnTheFly(324205) -- Blinding Flash
    SetDefaultOnTheFly(331251) -- Deep Connection
    SetDefaultOnTheFly(328331) -- Forced Confession
    SetDefaultOnTheFly(341215) -- Volatile Anima
    SetDefaultOnTheFly(323792) -- Anima Field
    SetDefaultOnTheFly(317661) -- Insidious Venom
    SetDefaultOnTheFly(330683) -- Raw Anima
    SetDefaultOnTheFly(328434) -- Intimidated
-- De Other Side
    SetDefaultOnTheFly(320786) -- Power Overwhelming
    SetDefaultOnTheFly(334913) -- Master of Death
    SetDefaultOnTheFly(325725) -- Cosmic Artifice
    SetDefaultOnTheFly(328987) -- Zealous
    SetDefaultOnTheFly(334496) -- Soporific Shimmerdust
    SetDefaultOnTheFly(339978) -- Pacifying Mists
    SetDefaultOnTheFly(323692) -- Arcane Vulnerability
    SetDefaultOnTheFly(333250) -- Reaver
    SetDefaultOnTheFly(330434) -- Buzz-Saw 1
    SetDefaultOnTheFly(320144) -- Buzz-Saw 2
    SetDefaultOnTheFly(331847) -- W-00F
    SetDefaultOnTheFly(327649) -- Crushed Soul
    SetDefaultOnTheFly(331379) -- Lubricate
    SetDefaultOnTheFly(332678) -- Gushing Wound
    SetDefaultOnTheFly(322746) -- Corrupted Blood
    SetDefaultOnTheFly(323687) -- Arcane Lightning
    SetDefaultOnTheFly(323877) -- Echo Finger Laser X-treme
    SetDefaultOnTheFly(334535) -- Beak Slice

---------------- Sanctum of Domination -----------------
-- The Tarragrue
    SetDefaultOnTheFly(347283) -- Predator's Howl
    SetDefaultOnTheFly(347286) -- Unshakeable Dread
    SetDefaultOnTheFly(346986) -- Crushed Armor
    SetDefaultOnTheFly(347991) -- Ten of Towers
    SetDefaultOnTheFly(347269) -- Chains of Eternity
    SetDefaultOnTheFly(346985) -- Overpower
    SetDefaultOnTheFly(347274) -- Annihilating Smash
-- Eye of the Jailer
    SetDefaultOnTheFly(350606) -- Hopeless Lethargy
    SetDefaultOnTheFly(355240) -- Scorn
    SetDefaultOnTheFly(355245) -- Ire
    SetDefaultOnTheFly(349979) -- Dragging Chains
    SetDefaultOnTheFly(348074) -- Assailing Lance
    SetDefaultOnTheFly(351827) -- Spreading Misery
    SetDefaultOnTheFly(355143) -- Deathlink
    SetDefaultOnTheFly(350763) -- Annihilating Glare
-- The Nine
-- Remnant of Ner'zhul
-- Soulrender Dormazain
-- Painsmith Raznal
-- Guardian of the First Ones
-- Fatescribe Roh-Kalo
-- Kel'Thuzad
-- Sylvanas Windrunner

-------------------- Castle Nathria --------------------
-- Shriekwing
    SetDefaultOnTheFly(328897) -- Exsanguinated
    SetDefaultOnTheFly(330713) -- Reverberating Pain
    SetDefaultOnTheFly(329370) -- Deadly Descent
    SetDefaultOnTheFly(336494) -- Echo Screech
    SetDefaultOnTheFly(346301) -- Bloodlight
    SetDefaultOnTheFly(342077) -- Echolocation
-- Huntsman Altimor
    SetDefaultOnTheFly(335304) -- Sinseeker
    SetDefaultOnTheFly(334971) -- Jagged Claws
    SetDefaultOnTheFly(335111) -- Huntsman's Mark 3
    SetDefaultOnTheFly(335112) -- Huntsman's Mark 2
    SetDefaultOnTheFly(335113) -- Huntsman's Mark 1
    SetDefaultOnTheFly(334945) -- Vicious Lunge
    SetDefaultOnTheFly(334852) -- Petrifying Howl
    SetDefaultOnTheFly(334695) -- Destabilize
-- Hungering Destroyer
    SetDefaultOnTheFly(334228) -- Volatile Ejection
    SetDefaultOnTheFly(329298) -- Gluttonous Miasma
-- Lady Inerva Darkvein
    SetDefaultOnTheFly(325936) -- Shared Cognition
    SetDefaultOnTheFly(335396) -- Hidden Desire
    SetDefaultOnTheFly(324983) -- Shared Suffering
    SetDefaultOnTheFly(324982) -- Shared Suffering (Partner)
    SetDefaultOnTheFly(332664) -- Concentrate Anima
    SetDefaultOnTheFly(325382) -- Warped Desires
-- Sun King's Salvation
    SetDefaultOnTheFly(333002) -- Vulgar Brand
    SetDefaultOnTheFly(326078) -- Infuser's Boon
    SetDefaultOnTheFly(325251) -- Sin of Pride
    SetDefaultOnTheFly(341475) -- Crimson Flurry
    SetDefaultOnTheFly(341473) -- Crimson Flurry Teleport
    SetDefaultOnTheFly(328479) -- Eyes on Target
    SetDefaultOnTheFly(328889) -- Greater Castigation
-- Artificer Xy'mox
    SetDefaultOnTheFly(327902) -- Fixate
    SetDefaultOnTheFly(326302) -- Stasis Trap
    SetDefaultOnTheFly(325236) -- Glyph of Destruction
    SetDefaultOnTheFly(327414) -- Possession
    SetDefaultOnTheFly(328468) -- Dimensional Tear 1
    SetDefaultOnTheFly(328448) -- Dimensional Tear 2
    SetDefaultOnTheFly(340860) -- Withering Touch
-- The Council of Blood
    SetDefaultOnTheFly(327052) -- Drain Essence 1
    SetDefaultOnTheFly(327773) -- Drain Essence 2
    SetDefaultOnTheFly(346651) -- Drain Essence Mythic
    SetDefaultOnTheFly(328334) -- Tactical Advance
    SetDefaultOnTheFly(330848) -- Wrong Moves
    SetDefaultOnTheFly(331706) -- Scarlet Letter
    SetDefaultOnTheFly(331636) -- Dark Recital 1
    SetDefaultOnTheFly(331637) -- Dark Recital 2
-- Sludgefist
    SetDefaultOnTheFly(335470) -- Chain Slam
    SetDefaultOnTheFly(339181) -- Chain Slam (Root)
    SetDefaultOnTheFly(331209) -- Hateful Gaze
    SetDefaultOnTheFly(335293) -- Chain Link
    SetDefaultOnTheFly(335270) -- Chain This One!
    SetDefaultOnTheFly(342419) -- Chain Them! 1
    SetDefaultOnTheFly(342420) -- Chain Them! 2
    SetDefaultOnTheFly(335295) -- Shattering Chain
    SetDefaultOnTheFly(332572) -- Falling Rubble
-- Stone Legion Generals
    SetDefaultOnTheFly(334498) -- Seismic Upheaval
    SetDefaultOnTheFly(337643) -- Unstable Footing
    SetDefaultOnTheFly(334765) -- Heart Rend
    SetDefaultOnTheFly(333377) -- Wicked Mark
    SetDefaultOnTheFly(334616) -- Petrified
    SetDefaultOnTheFly(334541) -- Curse of Petrification
    SetDefaultOnTheFly(339690) -- Crystalize
    SetDefaultOnTheFly(342655) -- Volatile Anima Infusion
    SetDefaultOnTheFly(342698) -- Volatile Anima Infection
    SetDefaultOnTheFly(343881) -- Serrated Tear
-- Sire Denathrius
    SetDefaultOnTheFly(326851) -- Blood Price
    SetDefaultOnTheFly(327796) -- Night Hunter
    SetDefaultOnTheFly(327992) -- Desolation
    SetDefaultOnTheFly(328276) -- March of the Penitent
    SetDefaultOnTheFly(326699) -- Burden of Sin
    SetDefaultOnTheFly(329181) -- Wracking Pain
    SetDefaultOnTheFly(335873) -- Rancor
    SetDefaultOnTheFly(329951) -- Impale
    SetDefaultOnTheFly(327039) -- Feeding Time
    SetDefaultOnTheFly(332794) -- Fatal Finesse
    SetDefaultOnTheFly(334016) -- Unworthy