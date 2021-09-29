local _, GW = ...
GW.DEFAULTS = GW.DEFAULTS or {}
GW.DEFAULTS.RAIDDEBUFFS = {}
GW.ImportendRaidDebuff = {}

local function SetDefaultOnTheFly(id)
    GW.DEFAULTS.RAIDDEBUFFS[id] = true
    GW.ImportendRaidDebuff[id] = true
end

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