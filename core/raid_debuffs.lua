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

    -- Legion
    	-- Antorus, the Burning Throne
    		-- Garothi Worldbreaker
    		SetDefaultOnTheFly(244590) -- Molten Hot Fel
    		SetDefaultOnTheFly(244761) -- Annihilation
    		SetDefaultOnTheFly(246920) -- Haywire Decimation
    		SetDefaultOnTheFly(246369) -- Searing Barrage
    		SetDefaultOnTheFly(246848) -- Luring Destruction
    		SetDefaultOnTheFly(246220) -- Fel Bombardment
    		SetDefaultOnTheFly(247159) -- Luring Destruction
    		SetDefaultOnTheFly(244122) -- Carnage
    		SetDefaultOnTheFly(244410) -- Decimation
    		SetDefaultOnTheFly(245294) -- Empowered Decimation
    		SetDefaultOnTheFly(246368) -- Searing Barrage

    		-- Felhounds of Sargeras
    		SetDefaultOnTheFly(245022) -- Burning Remnant
    		SetDefaultOnTheFly(251445) -- Smouldering
    		SetDefaultOnTheFly(251448) -- Burning Maw
    		SetDefaultOnTheFly(244086) -- Molten Touch
    		SetDefaultOnTheFly(244091) -- Singed
    		SetDefaultOnTheFly(244768) -- Desolate Gaze
    		SetDefaultOnTheFly(244767) -- Desolate Path
    		SetDefaultOnTheFly(244471) -- Enflame Corruption
    		SetDefaultOnTheFly(248815) -- Enflamed
    		SetDefaultOnTheFly(244517) -- Lingering Flames
    		SetDefaultOnTheFly(245098) -- Decay
    		SetDefaultOnTheFly(251447) -- Corrupting Maw
    		SetDefaultOnTheFly(244131) -- Consuming Sphere
    		SetDefaultOnTheFly(245024) -- Consumed
    		SetDefaultOnTheFly(244071) -- Weight of Darkness
    		SetDefaultOnTheFly(244578) -- Siphon Corruption
    		SetDefaultOnTheFly(248819) -- Siphoned
    		SetDefaultOnTheFly(254429) -- Weight of Darkness
    		SetDefaultOnTheFly(244072) -- Molten Touch

    		-- Antoran High Command
    		SetDefaultOnTheFly(245121) -- Entropic Blast
    		SetDefaultOnTheFly(244748) -- Shocked
    		SetDefaultOnTheFly(244824) -- Warp Field
    		SetDefaultOnTheFly(244892) -- Exploit Weakness
    		SetDefaultOnTheFly(244172) -- Psychic Assault
    		SetDefaultOnTheFly(244388) -- Psychic Scarring
    		SetDefaultOnTheFly(244420) -- Chaos Pulse
    		SetDefaultOnTheFly(254771) -- Disruption Field
    		SetDefaultOnTheFly(257974) -- Chaos Pulse
    		SetDefaultOnTheFly(244910) -- Felshield
    		SetDefaultOnTheFly(244737) -- Shock Grenade

    		-- Portal Keeper Hasabel
    		SetDefaultOnTheFly(244016) -- Reality Tear
    		SetDefaultOnTheFly(245157) -- Everburning Light
    		SetDefaultOnTheFly(245075) -- Hungering Gloom
    		SetDefaultOnTheFly(245240) -- Oppressive Gloom
    		SetDefaultOnTheFly(244709) -- Fiery Detonation
    		SetDefaultOnTheFly(246208) -- Acidic Web
    		SetDefaultOnTheFly(246075) -- Catastrophic Implosion
    		SetDefaultOnTheFly(244826) -- Fel Miasma
    		SetDefaultOnTheFly(246316) -- Poison Essence
    		SetDefaultOnTheFly(244849) -- Caustic Slime
    		SetDefaultOnTheFly(245118) -- Cloying Shadows
    		SetDefaultOnTheFly(245050) -- Delusions
    		SetDefaultOnTheFly(245040) -- Corrupt
    		SetDefaultOnTheFly(244607) -- Flames of Xoroth
    		SetDefaultOnTheFly(244915) -- Leech Essence
    		SetDefaultOnTheFly(244926) -- Felsilk Wrap
    		SetDefaultOnTheFly(244949) -- Felsilk Wrap
    		SetDefaultOnTheFly(244613) -- Everburning Flames

    		-- Eonar the Life-Binder
    		SetDefaultOnTheFly(248326) -- Rain of Fel
    		SetDefaultOnTheFly(248861) -- Spear of Doom
    		SetDefaultOnTheFly(249016) -- Feedback - Targeted
    		SetDefaultOnTheFly(249015) -- Feedback - Burning Embers
    		SetDefaultOnTheFly(249014) -- Feedback - Foul Steps
    		SetDefaultOnTheFly(249017) -- Feedback - Arcane Singularity
    		SetDefaultOnTheFly(250693) -- Arcane Buildup
    		SetDefaultOnTheFly(250691) -- Burning Embers
    		SetDefaultOnTheFly(248795) -- Fel Wake
    		SetDefaultOnTheFly(248332) -- Rain of Fel
    		SetDefaultOnTheFly(250140) -- Foul Steps

    		-- Imonar the Soulhunter
    		SetDefaultOnTheFly(248424) -- Gathering Power
    		SetDefaultOnTheFly(247552) -- Sleep Canister
    		SetDefaultOnTheFly(247565) -- Slumber Gas
    		SetDefaultOnTheFly(250224) -- Shocked
    		SetDefaultOnTheFly(248252) -- Infernal Rockets
    		SetDefaultOnTheFly(247687) -- Sever
    		SetDefaultOnTheFly(247716) -- Charged Blasts
    		SetDefaultOnTheFly(247367) -- Shock Lance
    		SetDefaultOnTheFly(250255) -- Empowered Shock Lance
    		SetDefaultOnTheFly(247641) -- Stasis Trap
    		SetDefaultOnTheFly(255029) -- Sleep Canister
    		SetDefaultOnTheFly(248321) -- Conflagration
    		SetDefaultOnTheFly(247932) -- Shrapnel Blast
    		SetDefaultOnTheFly(248070) -- Empowered Shrapnel Blast
    		SetDefaultOnTheFly(254183) -- Seared Skin

    		-- Kin'garoth
    		SetDefaultOnTheFly(244312) -- Forging Strike
    		SetDefaultOnTheFly(254919) -- Forging Strike
    		SetDefaultOnTheFly(246840) -- Ruiner
    		SetDefaultOnTheFly(248061) -- Purging Protocol
    		SetDefaultOnTheFly(249686) -- Reverberating Decimation
    		SetDefaultOnTheFly(246706) -- Demolish
    		SetDefaultOnTheFly(246698) -- Demolish
    		SetDefaultOnTheFly(245919) -- Meteor Swarm
    		SetDefaultOnTheFly(245770) -- Decimation

    		-- Varimathras
    		SetDefaultOnTheFly(244042) -- Marked Prey
    		SetDefaultOnTheFly(243961) -- Misery
    		SetDefaultOnTheFly(248732) -- Echoes of Doom
    		SetDefaultOnTheFly(243973) -- Torment of Shadows
    		SetDefaultOnTheFly(244005) -- Dark Fissure
    		SetDefaultOnTheFly(244093) -- Necrotic Embrace
    		SetDefaultOnTheFly(244094) -- Necrotic Embrace

    		-- The Coven of Shivarra
    		SetDefaultOnTheFly(244899) -- Fiery Strike
    		SetDefaultOnTheFly(245518) -- Flashfreeze
    		SetDefaultOnTheFly(245586) -- Chilled Blood
    		SetDefaultOnTheFly(246763) -- Fury of Golganneth
    		SetDefaultOnTheFly(245674) -- Flames of Khaz'goroth
    		SetDefaultOnTheFly(245671) -- Flames of Khaz'goroth
    		SetDefaultOnTheFly(245910) -- Spectral Army of Norgannon
    		SetDefaultOnTheFly(253520) -- Fulminating Pulse
    		SetDefaultOnTheFly(245634) -- Whirling Saber
    		SetDefaultOnTheFly(253020) -- Storm of Darkness
    		SetDefaultOnTheFly(245921) -- Spectral Army of Norgannon
    		SetDefaultOnTheFly(250757) -- Cosmic Glare

    		-- Aggramar
    		SetDefaultOnTheFly(244291) -- Foe Breaker
    		SetDefaultOnTheFly(255060) -- Empowered Foe Breaker
    		SetDefaultOnTheFly(245995) -- Scorching Blaze
    		SetDefaultOnTheFly(246014) -- Searing Tempest
    		SetDefaultOnTheFly(244912) -- Blazing Eruption
    		SetDefaultOnTheFly(247135) -- Scorched Earth
    		SetDefaultOnTheFly(247091) -- Catalyzed
    		SetDefaultOnTheFly(245631) -- Unchecked Flame
    		SetDefaultOnTheFly(245916) -- Molten Remnants
    		SetDefaultOnTheFly(245990) -- Taeshalach's Reach
    		SetDefaultOnTheFly(254452) -- Ravenous Blaze
    		SetDefaultOnTheFly(244736) -- Wake of Flame
    		SetDefaultOnTheFly(247079) -- Empowered Flame Rend

    		-- Argus the Unmaker
    		SetDefaultOnTheFly(251815) -- Edge of Obliteration
    		SetDefaultOnTheFly(248499) -- Sweeping Scythe
    		SetDefaultOnTheFly(250669) -- Soulburst
    		SetDefaultOnTheFly(251570) -- Soulbomb
    		SetDefaultOnTheFly(248396) -- Soulblight
    		SetDefaultOnTheFly(258039) -- Deadly Scythe
    		SetDefaultOnTheFly(252729) -- Cosmic Ray
    		SetDefaultOnTheFly(256899) -- Soul Detonation
    		SetDefaultOnTheFly(252634) -- Cosmic Smash
    		SetDefaultOnTheFly(252616) -- Cosmic Beacon
    		SetDefaultOnTheFly(255200) -- Aggramar's Boon
    		SetDefaultOnTheFly(255199) -- Avatar of Aggramar
    		SetDefaultOnTheFly(258647) -- Gift of the Sea
    		SetDefaultOnTheFly(253901) -- Strength of the Sea
    		SetDefaultOnTheFly(257299) -- Ember of Rage
    		SetDefaultOnTheFly(248167) -- Death Fog
    		SetDefaultOnTheFly(258646) -- Gift of the Sky
    		SetDefaultOnTheFly(253903) -- Strength of the Sky

    	-- Tomb of Sargeras
    		-- Goroth
    		SetDefaultOnTheFly(233279) -- Shattering Star
    		SetDefaultOnTheFly(230345) -- Crashing Comet (Dot)
    		SetDefaultOnTheFly(232249) -- Crashing Comet
    		SetDefaultOnTheFly(231363) -- Burning Armor
    		SetDefaultOnTheFly(234264) -- Melted Armor
    		SetDefaultOnTheFly(233062) -- Infernal Burning
    		SetDefaultOnTheFly(230348) -- Fel Pool

    		-- Demonic Inquisition
    		SetDefaultOnTheFly(233430) -- Ubearable Torment
    		SetDefaultOnTheFly(233983) -- Echoing Anguish
    		SetDefaultOnTheFly(248713) -- Soul Corruption

    		-- Harjatan
    		SetDefaultOnTheFly(231770) -- Drenched
    		SetDefaultOnTheFly(231998) -- Jagged Abrasion
    		SetDefaultOnTheFly(231729) -- Aqueous Burst
    		SetDefaultOnTheFly(234128) -- Driven Assault
    		SetDefaultOnTheFly(234016) -- Driven Assault

    		-- Sisters of the Moon
    		SetDefaultOnTheFly(236603) -- Rapid Shot
    		SetDefaultOnTheFly(236596) -- Rapid Shot
    		SetDefaultOnTheFly(234995) -- Lunar Suffusion
    		SetDefaultOnTheFly(234996) -- Umbra Suffusion
    		SetDefaultOnTheFly(236519) -- Moon Burn
    		SetDefaultOnTheFly(236697) -- Deathly Screech
    		SetDefaultOnTheFly(239264) -- Lunar Flare (Tank)
    		SetDefaultOnTheFly(236712) -- Lunar Beacon
    		SetDefaultOnTheFly(236304) -- Incorporeal Shot
    		SetDefaultOnTheFly(236305) -- Incorporeal Shot (Heroic)
    		SetDefaultOnTheFly(236306) -- Incorporeal Shot
    		SetDefaultOnTheFly(237570) -- Incorporeal Shot
    		SetDefaultOnTheFly(248911) -- Incorporeal Shot
    		SetDefaultOnTheFly(236550) -- Discorporate (Tank)
    		SetDefaultOnTheFly(236330) -- Astral Vulnerability
    		SetDefaultOnTheFly(236529) -- Twilight Glaive
    		SetDefaultOnTheFly(236541) -- Twilight Glaive
    		SetDefaultOnTheFly(237561) -- Twilight Glaive (Heroic)
    		SetDefaultOnTheFly(237633) -- Spectral Glaive
    		SetDefaultOnTheFly(233263) -- Embrace of the Eclipse

    		-- Mistress Sassz'ine
    		SetDefaultOnTheFly(230959) -- Concealing Murk
    		SetDefaultOnTheFly(232732) -- Slicing Tornado
    		SetDefaultOnTheFly(232913) -- Befouling Ink
    		SetDefaultOnTheFly(234621) -- Devouring Maw
    		SetDefaultOnTheFly(230201) -- Burden of Pain (Tank)
    		SetDefaultOnTheFly(230139) -- Hydra Shot
    		SetDefaultOnTheFly(232754) -- Hydra Acid
    		SetDefaultOnTheFly(230920) -- Consuming Hunger
    		SetDefaultOnTheFly(230358) -- Thundering Shock
    		SetDefaultOnTheFly(230362) -- Thundering Shock

    		-- The Desolate Host
    		SetDefaultOnTheFly(236072) -- Wailing Souls
    		SetDefaultOnTheFly(236449) -- Soulbind
    		SetDefaultOnTheFly(236515) -- Shattering Scream
    		SetDefaultOnTheFly(235989) -- Tormented Cries
    		SetDefaultOnTheFly(236241) -- Soul Rot
    		SetDefaultOnTheFly(236361) -- Spirit Chains
    		SetDefaultOnTheFly(235968) -- Grasping Darkness

    		-- Maiden of Vigilance
    		SetDefaultOnTheFly(235117) -- Unstable Soul
    		SetDefaultOnTheFly(240209) -- Unstable Soul
    		SetDefaultOnTheFly(243276) -- Unstable Soul
    		SetDefaultOnTheFly(249912) -- Unstable Soul
    		SetDefaultOnTheFly(235534) -- Creator's Grace
    		SetDefaultOnTheFly(235538) -- Demon's Vigor
    		SetDefaultOnTheFly(234891) -- Wrath of the Creators
    		SetDefaultOnTheFly(235569) -- Hammer of Creation
    		SetDefaultOnTheFly(235573) -- Hammer of Obliteration
    		SetDefaultOnTheFly(235213) -- Light Infusion
    		SetDefaultOnTheFly(235240) -- Fel Infusion

    		-- Fallen Avatar
    		SetDefaultOnTheFly(239058) -- Touch of Sargeras
    		SetDefaultOnTheFly(239739) -- Dark Mark
    		SetDefaultOnTheFly(234059) -- Unbound Chaos
    		SetDefaultOnTheFly(240213) -- Chaos Flames
    		SetDefaultOnTheFly(236604) -- Shadowy Blades
    		SetDefaultOnTheFly(236494) -- Desolate (Tank)
    		SetDefaultOnTheFly(240728) -- Tainted Essence

    		-- Kil'jaeden
    		SetDefaultOnTheFly(238999) -- Darkness of a Thousand Souls
    		SetDefaultOnTheFly(239216) -- Darkness of a Thousand Souls (Dot)
    		SetDefaultOnTheFly(239155) -- Gravity Squeeze
    		SetDefaultOnTheFly(234295) -- Armageddon Rain
    		SetDefaultOnTheFly(240908) -- Armageddon Blast
    		SetDefaultOnTheFly(239932) -- Felclaws (Tank)
    		SetDefaultOnTheFly(240911) -- Armageddon Hail
    		SetDefaultOnTheFly(238505) -- Focused Dreadflame
    		SetDefaultOnTheFly(238429) -- Bursting Dreadflame
    		SetDefaultOnTheFly(236710) -- Shadow Reflection: Erupting
    		SetDefaultOnTheFly(241822) -- Choking Shadow
    		SetDefaultOnTheFly(236555) -- Deceiver's Veil
    		SetDefaultOnTheFly(234310) -- Armageddon Rain

    	-- The Nighthold
    		-- Skorpyron
    		SetDefaultOnTheFly(204766) -- Energy Surge
    		SetDefaultOnTheFly(214718) -- Acidic Fragments
    		SetDefaultOnTheFly(211801) -- Volatile Fragments
    		SetDefaultOnTheFly(204284) -- Broken Shard (Protection)
    		SetDefaultOnTheFly(204275) -- Arcanoslash (Tank)
    		SetDefaultOnTheFly(211659) -- Arcane Tether (Tank debuff)
    		SetDefaultOnTheFly(204483) -- Focused Blast (Stun)

    		-- Chronomatic Anomaly
    		SetDefaultOnTheFly(206607) -- Chronometric Particles (Tank stack debuff)
    		SetDefaultOnTheFly(206609) -- Time Release (Heal buff/debuff)
    		SetDefaultOnTheFly(219966) -- Time Release (Heal Absorb Red)
    		SetDefaultOnTheFly(219965) -- Time Release (Heal Absorb Yellow)
    		SetDefaultOnTheFly(219964) -- Time Release (Heal Absorb Green)
    		SetDefaultOnTheFly(205653) -- Passage of Time
    		SetDefaultOnTheFly(207871) -- Vortex (Mythic)
    		SetDefaultOnTheFly(212099) -- Temporal Charge

    		-- Trilliax
    		SetDefaultOnTheFly(206488) -- Arcane Seepage
    		SetDefaultOnTheFly(206641) -- Arcane Spear (Tank)
    		SetDefaultOnTheFly(206798) -- Toxic Slice
    		SetDefaultOnTheFly(214672) -- Annihilation
    		SetDefaultOnTheFly(214573) -- Stuffed
    		SetDefaultOnTheFly(214583) -- Sterilize
    		SetDefaultOnTheFly(208910) -- Arcing Bonds
    		SetDefaultOnTheFly(206838) -- Succulent Feast

    		-- Spellblade Aluriel
    		SetDefaultOnTheFly(212492) -- Annihilate (Tank)
    		SetDefaultOnTheFly(212494) -- Annihilated (Main Tank debuff)
    		SetDefaultOnTheFly(212587) -- Mark of Frost
    		SetDefaultOnTheFly(212531) -- Mark of Frost (marked)
    		SetDefaultOnTheFly(212530) -- Replicate: Mark of Frost
    		SetDefaultOnTheFly(212647) -- Frostbitten
    		SetDefaultOnTheFly(212736) -- Pool of Frost
    		SetDefaultOnTheFly(213085) -- Frozen Tempest
    		SetDefaultOnTheFly(213621) -- Entombed in Ice
    		SetDefaultOnTheFly(213148) -- Searing Brand Chosen
    		SetDefaultOnTheFly(213181) -- Searing Brand Stunned
    		SetDefaultOnTheFly(213166) -- Searing Brand
    		SetDefaultOnTheFly(213278) -- Burning Ground
    		SetDefaultOnTheFly(213504) -- Arcane Fog

    		-- Tichondrius
    		SetDefaultOnTheFly(206480) -- Carrion Plague
    		SetDefaultOnTheFly(215988) -- Carrion Nightmare
    		SetDefaultOnTheFly(208230) -- Feast of Blood
    		SetDefaultOnTheFly(212794) -- Brand of Argus
    		SetDefaultOnTheFly(216685) -- Flames of Argus
    		SetDefaultOnTheFly(206311) -- Illusionary Night
    		SetDefaultOnTheFly(206466) -- Essence of Night
    		SetDefaultOnTheFly(216024) -- Volatile Wound
    		SetDefaultOnTheFly(216027) -- Nether Zone
    		SetDefaultOnTheFly(216039) -- Fel Storm
    		SetDefaultOnTheFly(216726) -- Ring of Shadows
    		SetDefaultOnTheFly(216040) -- Burning Soul

    		-- Krosus
    		SetDefaultOnTheFly(206677) -- Searing Brand
    		SetDefaultOnTheFly(205344) -- Orb of Destruction

    		-- High Botanist Tel'arn
    		SetDefaultOnTheFly(218503) -- Recursive Strikes (Tank)
    		SetDefaultOnTheFly(219235) -- Toxic Spores
    		SetDefaultOnTheFly(218809) -- Call of Night
    		SetDefaultOnTheFly(218342) -- Parasitic Fixate
    		SetDefaultOnTheFly(218304) -- Parasitic Fetter
    		SetDefaultOnTheFly(218780) -- Plasma Explosion

    		-- Star Augur Etraeus
    		SetDefaultOnTheFly(205984) -- Gravitaional Pull
    		SetDefaultOnTheFly(214167) -- Gravitaional Pull
    		SetDefaultOnTheFly(214335) -- Gravitaional Pull
    		SetDefaultOnTheFly(206936) -- Icy Ejection
    		SetDefaultOnTheFly(206388) -- Felburst
    		SetDefaultOnTheFly(206585) -- Absolute Zero
    		SetDefaultOnTheFly(206398) -- Felflame
    		SetDefaultOnTheFly(206589) -- Chilled
    		SetDefaultOnTheFly(205649) -- Fel Ejection
    		SetDefaultOnTheFly(206965) -- Voidburst
    		SetDefaultOnTheFly(206464) -- Coronal Ejection
    		SetDefaultOnTheFly(207143) -- Void Ejection
    		SetDefaultOnTheFly(206603) -- Frozen Solid
    		SetDefaultOnTheFly(207720) -- Witness the Void
    		SetDefaultOnTheFly(216697) -- Frigid Pulse

    		-- Grand Magistrix Elisande
    		SetDefaultOnTheFly(209166) -- Fast Time
    		SetDefaultOnTheFly(211887) -- Ablated
    		SetDefaultOnTheFly(209615) -- Ablation
    		SetDefaultOnTheFly(209244) -- Delphuric Beam
    		SetDefaultOnTheFly(209165) -- Slow Time
    		SetDefaultOnTheFly(209598) -- Conflexive Burst
    		SetDefaultOnTheFly(209433) -- Spanning Singularity
    		SetDefaultOnTheFly(209973) -- Ablating Explosion
    		SetDefaultOnTheFly(209549) -- Lingering Burn
    		SetDefaultOnTheFly(211261) -- Permaliative Torment
    		SetDefaultOnTheFly(208659) -- Arcanetic Ring

    		-- Gul'dan
    		SetDefaultOnTheFly(210339) -- Time Dilation
    		SetDefaultOnTheFly(180079) -- Felfire Munitions
    		SetDefaultOnTheFly(206875) -- Fel Obelisk (Tank)
    		SetDefaultOnTheFly(206840) -- Gaze of Vethriz
    		SetDefaultOnTheFly(206896) -- Torn Soul
    		SetDefaultOnTheFly(206221) -- Empowered Bonds of Fel
    		SetDefaultOnTheFly(208802) -- Soul Corrosion
    		SetDefaultOnTheFly(212686) -- Flames of Sargeras

    	-- The Emerald Nightmare
    		-- Nythendra
    		SetDefaultOnTheFly(204504) -- Infested
    		SetDefaultOnTheFly(205043) -- Infested mind
    		SetDefaultOnTheFly(203096) -- Rot
    		SetDefaultOnTheFly(204463) -- Volatile Rot
    		SetDefaultOnTheFly(203045) -- Infested Ground
    		SetDefaultOnTheFly(203646) -- Burst of Corruption

    		-- Elerethe Renferal
    		SetDefaultOnTheFly(210228) -- Dripping Fangs
    		SetDefaultOnTheFly(215307) -- Web of Pain
    		SetDefaultOnTheFly(215300) -- Web of Pain
    		SetDefaultOnTheFly(215460) -- Necrotic Venom
    		SetDefaultOnTheFly(213124) -- Venomous Pool
    		SetDefaultOnTheFly(210850) -- Twisting Shadows
    		SetDefaultOnTheFly(215489) -- Venomous Pool
    		SetDefaultOnTheFly(218519) -- Wind Burn (Mythic)

    		-- Il'gynoth, Heart of the Corruption
    		SetDefaultOnTheFly(208929)  -- Spew Corruption
    		SetDefaultOnTheFly(210984)  -- Eye of Fate
    		SetDefaultOnTheFly(209469)  -- Touch of Corruption
    		SetDefaultOnTheFly(208697)  -- Mind Flay
    		SetDefaultOnTheFly(215143)  -- Cursed Blood

    		-- Ursoc
    		SetDefaultOnTheFly(198108) -- Unbalanced
    		SetDefaultOnTheFly(197943) -- Overwhelm
    		SetDefaultOnTheFly(204859) -- Rend Flesh
    		SetDefaultOnTheFly(205611) -- Miasma
    		SetDefaultOnTheFly(198006) -- Focused Gaze
    		SetDefaultOnTheFly(197980) -- Nightmarish Cacophony

    		-- Dragons of Nightmare
    		SetDefaultOnTheFly(203102)  -- Mark of Ysondre
    		SetDefaultOnTheFly(203121)  -- Mark of Taerar
    		SetDefaultOnTheFly(203125)  -- Mark of Emeriss
    		SetDefaultOnTheFly(203124)  -- Mark of Lethon
    		SetDefaultOnTheFly(204731)  -- Wasting Dread
    		SetDefaultOnTheFly(203110)  -- Slumbering Nightmare
    		SetDefaultOnTheFly(207681)  -- Nightmare Bloom
    		SetDefaultOnTheFly(205341)  -- Sleeping Fog
    		SetDefaultOnTheFly(203770)  -- Defiled Vines
    		SetDefaultOnTheFly(203787)  -- Volatile Infection

    		-- Cenarius
    		SetDefaultOnTheFly(210279) -- Creeping Nightmares
    		SetDefaultOnTheFly(213162) -- Nightmare Blast
    		SetDefaultOnTheFly(210315) -- Nightmare Brambles
    		SetDefaultOnTheFly(212681) -- Cleansed Ground
    		SetDefaultOnTheFly(211507) -- Nightmare Javelin
    		SetDefaultOnTheFly(211471) -- Scorned Touch
    		SetDefaultOnTheFly(211612) -- Replenishing Roots
    		SetDefaultOnTheFly(216516) -- Ancient Dream

    		-- Xavius
    		SetDefaultOnTheFly(206005) -- Dream Simulacrum
    		SetDefaultOnTheFly(206651) -- Darkening Soul
    		SetDefaultOnTheFly(209158) -- Blackening Soul
    		SetDefaultOnTheFly(211802) -- Nightmare Blades
    		SetDefaultOnTheFly(206109) -- Awakening to the Nightmare
    		SetDefaultOnTheFly(209034) -- Bonds of Terror
    		SetDefaultOnTheFly(210451) -- Bonds of Terror
    		SetDefaultOnTheFly(208431) -- Corruption: Descent into Madness
    		SetDefaultOnTheFly(207409) -- Madness
    		SetDefaultOnTheFly(211634) -- The Infinite Dark
    		SetDefaultOnTheFly(208385) -- Tainted Discharge

    	-- Trial of Valor
    		-- Odyn
    		SetDefaultOnTheFly(227959) -- Storm of Justice
    		SetDefaultOnTheFly(227807) -- Storm of Justice
    		SetDefaultOnTheFly(227475) -- Cleansing Flame
    		SetDefaultOnTheFly(192044) -- Expel Light
    		SetDefaultOnTheFly(228030) -- Expel Light
    		SetDefaultOnTheFly(227781) -- Glowing Fragment
    		SetDefaultOnTheFly(228918) -- Stormforged Spear
    		SetDefaultOnTheFly(227490) -- Branded
    		SetDefaultOnTheFly(227491) -- Branded
    		SetDefaultOnTheFly(227498) -- Branded
    		SetDefaultOnTheFly(227499) -- Branded
    		SetDefaultOnTheFly(227500) -- Branded
    		SetDefaultOnTheFly(231297) -- Runic Brand (Mythic Only)

    		-- Guarm
    		SetDefaultOnTheFly(228228) -- Flame Lick
    		SetDefaultOnTheFly(228248) -- Frost Lick
    		SetDefaultOnTheFly(228253) -- Shadow Lick
    		SetDefaultOnTheFly(227539) -- Fiery Phlegm
    		SetDefaultOnTheFly(227566) -- Salty Spittle
    		SetDefaultOnTheFly(227570) -- Dark Discharge

    		-- Helya
    		SetDefaultOnTheFly(228883)  -- Unholy Reckoning (Trash)
    		SetDefaultOnTheFly(227903)  -- Orb of Corruption
    		SetDefaultOnTheFly(228058)  -- Orb of Corrosion
    		SetDefaultOnTheFly(229119)  -- Orb of Corrosion
    		SetDefaultOnTheFly(228054)  -- Taint of the Sea
    		SetDefaultOnTheFly(193367)  -- Fetid Rot
    		SetDefaultOnTheFly(227982)  -- Bilewater Redox
    		SetDefaultOnTheFly(228519)  -- Anchor Slam
    		SetDefaultOnTheFly(202476)  -- Rabid
    		SetDefaultOnTheFly(232450)  -- Corrupted Axion

    	-- Mythic Dungeons
    		SetDefaultOnTheFly(226303) -- Piercing Shards (Neltharion's Lair)
    		SetDefaultOnTheFly(227742) -- Garrote (Karazhan)
    		SetDefaultOnTheFly(209858) -- Necrotic
    		SetDefaultOnTheFly(226512) -- Sanguine
    		SetDefaultOnTheFly(240559) -- Grievous
    		SetDefaultOnTheFly(240443) -- Bursting
    		SetDefaultOnTheFly(196376) -- Grievous Tear
    		SetDefaultOnTheFly(200227) -- Tangled Web
