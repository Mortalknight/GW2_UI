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
    ------------------------- General ------------------------
    ----------------------------------------------------------
    -- Misc
    SetDefaultOnTheFly(160029) -- Resurrecting (Pending CR)
----------------------------------------------------------
-------------------- Mythic+ Specific --------------------
----------------------------------------------------------
-- General Affix
    SetDefaultOnTheFly(226512) -- Sanguine
    SetDefaultOnTheFly(240559) -- Grievous
    SetDefaultOnTheFly(240443) -- Bursting
    SetDefaultOnTheFly(409492) -- Afflicted Cry
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
-- Priory of the Sacred Flame (Season 2)
-- Cinderbrew Meadery (Season 2)
-- Darkflame Cleft (Season 2)
----------------------------------------------------------
--------------- The War Within (Season 1) ----------------
----------------------------------------------------------
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
    SetDefaultOnTheFly(334748) -- Drain Fluids
    SetDefaultOnTheFly(333489) -- Necrotic Breath
    SetDefaultOnTheFly(320717) -- Blood Hunger
-- Siege of Boralus
    SetDefaultOnTheFly(257168) -- Cursed Slash
    SetDefaultOnTheFly(272588) -- Rotting Wounds
    SetDefaultOnTheFly(272571) -- Choking Waters
    SetDefaultOnTheFly(274991) -- Putrid Waters
    SetDefaultOnTheFly(275835) -- Stinging Venom Coating
    SetDefaultOnTheFly(273930) -- Hindering Cut
    SetDefaultOnTheFly(257292) -- Heavy Slash
    SetDefaultOnTheFly(261428) -- Hangman's Noose
    SetDefaultOnTheFly(256897) -- Clamping Jaws
    SetDefaultOnTheFly(272874) -- Trample
    SetDefaultOnTheFly(273470) -- Gut Shot
    SetDefaultOnTheFly(272834) -- Viscous Slobber
    SetDefaultOnTheFly(257169) -- Terrifying Roar
    SetDefaultOnTheFly(272713) -- Crushing Slam
-- Grim Batol
    SetDefaultOnTheFly(449885) -- Shadow Gale 1
    SetDefaultOnTheFly(461513) -- Shadow Gale 2
    SetDefaultOnTheFly(449474) -- Molten Spark
    SetDefaultOnTheFly(456773) -- Twilight Wind
    SetDefaultOnTheFly(448953) -- Rumbling Earth
    SetDefaultOnTheFly(447268) -- Skullsplitter
    SetDefaultOnTheFly(449536) -- Molten Pool
    SetDefaultOnTheFly(450095) -- Curse of Entropy
    SetDefaultOnTheFly(448057) -- Abyssal Corruption
    SetDefaultOnTheFly(451871) -- Mass Temor
    SetDefaultOnTheFly(451613) -- Twilight Flame
    SetDefaultOnTheFly(451378) -- Rive
    SetDefaultOnTheFly(76711) -- Sear Mind
    SetDefaultOnTheFly(462220) -- Blazing Shadowflame
    SetDefaultOnTheFly(451395) -- Corrupt
    SetDefaultOnTheFly(82850) -- Flaming Fixate
    SetDefaultOnTheFly(451241) -- Shadowflame Slash
    SetDefaultOnTheFly(451965) -- Molten Wake
    SetDefaultOnTheFly(451224) -- Enveloping Shadowflame
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
    -- TODO: No raid testing available for this boss