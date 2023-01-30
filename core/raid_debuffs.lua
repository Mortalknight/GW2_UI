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
-- Court of Stars
    SetDefaultOnTheFly(207278) -- Arcane Lockdown
    SetDefaultOnTheFly(209516) -- Mana Fang
    SetDefaultOnTheFly(209512) -- Disrupting Energy
    SetDefaultOnTheFly(211473) -- Shadow Slash
    SetDefaultOnTheFly(207979) -- Shockwave
    SetDefaultOnTheFly(207980) -- Disintegration Beam 1
    SetDefaultOnTheFly(207981) -- Disintegration Beam 2
    SetDefaultOnTheFly(211464) -- Fel Detonation
    SetDefaultOnTheFly(208165) -- Withering Soul
    SetDefaultOnTheFly(209413) -- Suppress
    SetDefaultOnTheFly(209027) -- Quelling Strike
-- Halls of Valor
    SetDefaultOnTheFly(197964) -- Runic Brand Orange
    SetDefaultOnTheFly(197965) -- Runic Brand Yellow
    SetDefaultOnTheFly(197963) -- Runic Brand Purple
    SetDefaultOnTheFly(197967) -- Runic Brand Green
    SetDefaultOnTheFly(197966) -- Runic Brand Blue
    SetDefaultOnTheFly(193783) -- Aegis of Aggramar Up
    SetDefaultOnTheFly(196838) -- Scent of Blood
    SetDefaultOnTheFly(199674) -- Wicked Dagger
    SetDefaultOnTheFly(193260) -- Static Field
    SetDefaultOnTheFly(193743) -- Aegis of Aggramar Wielder
    SetDefaultOnTheFly(199652) -- Sever
    SetDefaultOnTheFly(198944) -- Breach Armor
    SetDefaultOnTheFly(215430) -- Thunderstrike 1
    SetDefaultOnTheFly(215429) -- Thunderstrike 2
    SetDefaultOnTheFly(203963) -- Eye of the Storm
    SetDefaultOnTheFly(196497) -- Ravenous Leap
    SetDefaultOnTheFly(193660) -- Felblaze Rush
    SetDefaultOnTheFly(192133) --
    SetDefaultOnTheFly(192132) --
-- Shadowmoon Burial Grounds
    SetDefaultOnTheFly(156776) -- Rending Voidlash
    SetDefaultOnTheFly(153692) -- Necrotic Pitch
    SetDefaultOnTheFly(153524) -- Plague Spit
    SetDefaultOnTheFly(154469) -- Ritual of Bones
    SetDefaultOnTheFly(162652) -- Lunar Purity
    SetDefaultOnTheFly(164907) -- Void Cleave
    SetDefaultOnTheFly(152979) -- Soul Shred
    SetDefaultOnTheFly(158061) -- Blessed Waters of Purity
    SetDefaultOnTheFly(154442) -- Malevolence
    SetDefaultOnTheFly(153501) -- Void Blast
-- Temple of the Jade Serpent
    SetDefaultOnTheFly(396150) -- Feeling of Superiority
    SetDefaultOnTheFly(397878) -- Tainted Ripple
    SetDefaultOnTheFly(106113) -- Touch of Nothingness
    SetDefaultOnTheFly(397914) -- Defiling Mist
    SetDefaultOnTheFly(397904) -- Setting Sun Kick
    SetDefaultOnTheFly(397911) -- Touch of Ruin
    SetDefaultOnTheFly(395859) -- Haunting Scream
    SetDefaultOnTheFly(374037) -- Overwhelming Rage
    SetDefaultOnTheFly(396093) -- Savage Leap
    SetDefaultOnTheFly(106823) -- Serpent Strike
    SetDefaultOnTheFly(396152) -- Feeling of Inferiority
    SetDefaultOnTheFly(110125) -- Shattered Resolve
    SetDefaultOnTheFly(397797) -- Corrupted Vortex
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
-- Halls of Infusion
-- Neltharus
-- Uldaman: Legacy of Tyr
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