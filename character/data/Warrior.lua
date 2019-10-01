local _, GW = ...
if (GW.currentClass ~= "WARRIOR") then
	return
end

-- ordered by rank
local rend = {772, 6546, 6547, 6548, 11572, 11573, 11574}
local heroicStrike = {78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286}
local bloodthirst = {23881 --[[Rank 1]], 23892 --[[Rank 2]], 23893 --[[Rank 3]], 23894 --[[Rank 4]]}
local intercept = {20252 --[[Rank 1]], 20616 --[[Rank 2]], 20617 --[[Rank 3]]}
local mortalStrike = {12294 --[[Rank 1]], 21551 --[[Rank 2]], 21552 --[[Rank 3]], 21553 --[[Rank 4]]}
local shieldSlam = {23922 --[[Rank 1]], 23923 --[[Rank 2]], 23924 --[[Rank 3]], 23925 --[[Rank 4]]}
local overpower = {7384 --[[Rank 1]], 7887 --[[Rank 2]], 11584 --[[Rank 3]], 11585 --[[Rank 4]]}
local cleave = {845 --[[Rank 1]], 7369 --[[Rank 2]], 11608 --[[Rank 3]], 11609 --[[Rank 4]], 20569 --[[Rank 5]]}
local thunderClap = {
	6343 --[[Rank 1]],
	8198 --[[Rank 2]],
	8204 --[[Rank 3]],
	8205 --[[Rank 4]],
	11580 --[[Rank 5]],
	11581 --[[Rank 6]]
}
local sunderArmor = {7386 --[[Rank 1]], 7405 --[[Rank 2]], 8380 --[[Rank 3]], 11596 --[[Rank 4]], 11597 --[[Rank 5]]}
local pummel = {6552, 6554}
local mockingBlow = {694 --[[Rank 1]], 7400 --[[Rank 2]], 7402 --[[Rank 3]], 20559 --[[Rank 4]], 20560 --[[Rank 5]]}
local execute = {5308 --[[Rank 1]], 20658 --[[Rank 2]], 20660 --[[Rank 3]], 20661 --[[Rank 4]], 20662 --[[Rank 5]]}
local slam = {1464 --[[Rank 1]], 8820 --[[Rank 2]], 11604 --[[Rank 3]], 11605 --[[Rank 4]]}
local revenge = {
	6572 --[[Rank 1]],
	6574 --[[Rank 2]],
	7379 --[[Rank 3]],
	11600 --[[Rank 4]],
	11601 --[[Rank 5]],
	25288 --[[Rank 6]]
}
local hamstring = {1715 --[[Rank 1]], 7372 --[[Rank 2]], 7373 --[[Rank 3]]}
local demoralizingShout = {
	1160 --[[Rank 1]],
	6190 --[[Rank 2]],
	11554 --[[Rank 3]],
	11555 --[[Rank 4]],
	11556 --[[Rank 5]]
}
local shieldBash = {72 --[[Rank 1]], 1671 --[[Rank 2]], 1672 --[[Rank 3]]}
local charge = {100, 6178, 11578}
local battleShout = {
	6673 --[[Rank 1]],
	5242 --[[Rank 2]],
	6192 --[[Rank 3]],
	11549 --[[Rank 4]],
	11550 --[[Rank 5]],
	11551 --[[Rank 6]],
	25289 --[[Rank 7]]
}
--[[
GW:SetPreviousAbilityMap(
	{
		rend,
		heroicStrike,
		bloodthirst,
		intercept,
		mortalStrike,
		shieldSlam,
		overpower,
		cleave,
		thunderClap,
		sunderArmor,
		pummel,
		mockingBlow,
		execute,
		slam,
		revenge,
		hamstring,
		demoralizingShout,
		shieldBash,
		charge,
		battleShout
	}
)
]]
GW.SpellsByLevel =

 {
 [0] = {
      -- @One-Handed Axes undefined
      {id =196, isTalent =0},
      -- @Two-Handed Axes undefined
      {id =197, isTalent =0},
      -- @One-Handed Maces undefined
      {id =198, isTalent =0},
      -- @Two-Handed Maces undefined
      {id =199, isTalent =0},
      -- @Polearms undefined
      {id =200, isTalent =0},
      -- @One-Handed Swords undefined
      {id =201, isTalent =0},
      -- @Two-Handed Swords undefined
      {id =202, isTalent =0},
      -- @Staves undefined
      {id =227, isTalent =0},
      -- @Bows undefined
      {id =264, isTalent =0},
      -- @Guns undefined
      {id =266, isTalent =0},
      -- @Dual Wield Passive
      {id =674, isTalent =0},
      -- @Plate Mail undefined
      {id =750, isTalent =0},
      -- @Daggers undefined
      {id =1180, isTalent =0},
      -- @Thrown undefined
      {id =2567, isTalent =0},
      -- @Crossbows undefined
      {id =5011, isTalent =0},
      -- @Mail undefined
      {id =8737, isTalent =0},
      -- @Leather undefined
      {id =9077, isTalent =0},
      -- @Shield undefined
      {id =9116, isTalent =0},
      -- @Two-Handed Weapon Specialization Rank 1
      {id =12163, isTalent =1},
      -- @Polearm Specialization Rank 1
      {id =12165, isTalent =1},
      -- @Sword Specialization Rank 1
      {id =12281, isTalent =1},
      -- @Improved Heroic Strike Rank 1
      {id =12282, isTalent =1},
      -- @Mace Specialization Rank 1
      {id =12284, isTalent =1},
      -- @Improved Charge Rank 1
      {id =12285, isTalent =1},
      -- @Improved Rend Rank 1
      {id =12286, isTalent =1},
      -- @Improved Thunder Clap Rank 1
      {id =12287, isTalent =1},
      -- @Improved Hamstring Rank 1
      {id =12289, isTalent =1},
      -- @Improved Overpower Rank 1
      {id =12290, isTalent =1},
      -- @Sweeping Strikes undefined
      {id =12292, isTalent =1},
      -- @Mortal Strike Rank 1
      {id =12294, isTalent =1},
      -- @Tactical Mastery Rank 1
      {id =12295, isTalent =1},
      -- @Anger Management undefined
      {id =12296, isTalent =1},
      -- @Anticipation Rank 1
      {id =12297, isTalent =1},
      -- @Shield Specialization Rank 1
      {id =12298, isTalent =1},
      -- @Toughness Rank 1
      {id =12299, isTalent =1},
      -- @Iron Will Rank 1
      {id =12300, isTalent =1},
      -- @Improved Bloodrage Rank 1
      {id =12301, isTalent =1},
      -- @Improved Taunt Rank 1
      {id =12302, isTalent =1},
      -- @Defiance Rank 1
      {id =12303, isTalent =1},
      -- @Improved Shield Block Rank 2
      {id =12307, requiredIds ={12945}, isTalent =1},
      -- @Improved Sunder Armor Rank 1
      {id =12308, isTalent =1},
      -- @Improved Shield Bash Rank 1
      {id =12311, isTalent =1},
      -- @Improved Shield Wall Rank 1
      {id =12312, isTalent =1},
      -- @Improved Disarm Rank 1
      {id =12313, isTalent =1},
      -- @Enrage Rank 1
      {id =12317, isTalent =1},
      -- @Improved Battle Shout Rank 1
      {id =12318, isTalent =1},
      -- @Flurry Rank 1
      {id =12319, isTalent =1},
      -- @Cruelty Rank 1
      {id =12320, isTalent =1},
      -- @Booming Voice Rank 1
      {id =12321, isTalent =1},
      -- @Unbridled Wrath Rank 1
      {id =12322, isTalent =1},
      -- @Piercing Howl undefined
      {id =12323, isTalent =1},
      -- @Improved Demoralizing Shout Rank 1
      {id =12324, isTalent =1},
      -- @Death Wish undefined
      {id =12328, isTalent =1},
      -- @Improved Cleave Rank 1
      {id =12329, isTalent =1},
      -- @Improved Slam Rank 2
      {id =12330, requiredIds ={12862}, isTalent =1},
      -- @Improved Rend Rank 2
      {id =12658, requiredIds ={12286}, isTalent =1},
      -- @Improved Rend Rank 3
      {id =12659, requiredIds ={12658}, isTalent =1},
      -- @Improved Heroic Strike Rank 2
      {id =12663, requiredIds ={12282}, isTalent =1},
      -- @Improved Heroic Strike Rank 3
      {id =12664, requiredIds ={12663}, isTalent =1},
      -- @Improved Thunder Clap Rank 2
      {id =12665, requiredIds ={12287}, isTalent =1},
      -- @Improved Thunder Clap Rank 3
      {id =12666, requiredIds ={12665}, isTalent =1},
      -- @Improved Hamstring Rank 2
      {id =12668, requiredIds ={12289}, isTalent =1},
      -- @Tactical Mastery Rank 2
      {id =12676, requiredIds ={12295}, isTalent =1},
      -- @Tactical Mastery Rank 3
      {id =12677, requiredIds ={12676}, isTalent =1},
      -- @Tactical Mastery Rank 4
      {id =12678, requiredIds ={12677}, isTalent =1},
      -- @Tactical Mastery Rank 5
      {id =12679, requiredIds ={12678}, isTalent =1},
      -- @Improved Charge Rank 2
      {id =12697, requiredIds ={12285}, isTalent =1},
      -- @Axe Specialization Rank 1
      {id =12700, isTalent =1},
      -- @Mace Specialization Rank 2
      {id =12701, requiredIds ={12284}, isTalent =1},
      -- @Mace Specialization Rank 3
      {id =12702, requiredIds ={12701}, isTalent =1},
      -- @Mace Specialization Rank 4
      {id =12703, requiredIds ={12702}, isTalent =1},
      -- @Mace Specialization Rank 5
      {id =12704, requiredIds ={12703}, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 2
      {id =12711, requiredIds ={12163}, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 3
      {id =12712, requiredIds ={12711}, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 4
      {id =12713, requiredIds ={12712}, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 5
      {id =12714, requiredIds ={12713}, isTalent =1},
      -- @Shield Specialization Rank 2
      {id =12724, requiredIds ={12298}, isTalent =1},
      -- @Shield Specialization Rank 3
      {id =12725, requiredIds ={12724}, isTalent =1},
      -- @Shield Specialization Rank 4
      {id =12726, requiredIds ={12725}, isTalent =1},
      -- @Shield Specialization Rank 5
      {id =12727, requiredIds ={12726}, isTalent =1},
      -- @Anticipation Rank 2
      {id =12750, requiredIds ={12297}, isTalent =1},
      -- @Anticipation Rank 3
      {id =12751, requiredIds ={12750}, isTalent =1},
      -- @Anticipation Rank 4
      {id =12752, requiredIds ={12751}, isTalent =1},
      -- @Anticipation Rank 5
      {id =12753, requiredIds ={12752}, isTalent =1},
      -- @Toughness Rank 2
      {id =12761, requiredIds ={12299}, isTalent =1},
      -- @Toughness Rank 3
      {id =12762, requiredIds ={12761}, isTalent =1},
      -- @Toughness Rank 4
      {id =12763, requiredIds ={12762}, isTalent =1},
      -- @Toughness Rank 5
      {id =12764, requiredIds ={12763}, isTalent =1},
      -- @Improved Taunt Rank 2
      {id =12765, requiredIds ={12302}, isTalent =1},
      -- @Axe Specialization Rank 2
      {id =12781, requiredIds ={12700}, isTalent =1},
      -- @Axe Specialization Rank 3
      {id =12783, requiredIds ={12781}, isTalent =1},
      -- @Axe Specialization Rank 4
      {id =12784, requiredIds ={12783}, isTalent =1},
      -- @Axe Specialization Rank 5
      {id =12785, requiredIds ={12784}, isTalent =1},
      -- @Defiance Rank 2
      {id =12788, requiredIds ={12303}, isTalent =1},
      -- @Defiance Rank 3
      {id =12789, requiredIds ={12788}, isTalent =1},
      -- @Defiance Rank 4
      {id =12791, requiredIds ={12789}, isTalent =1},
      -- @Defiance Rank 5
      {id =12792, requiredIds ={12791}, isTalent =1},
      -- @Improved Revenge Rank 1
      {id =12797, isTalent =1},
      -- @Improved Revenge Rank 2
      {id =12799, requiredIds ={12797}, isTalent =1},
      -- @Improved Revenge Rank 3
      {id =12800, requiredIds ={12799}, isTalent =1},
      -- @Improved Shield Wall Rank 2
      {id =12803, requiredIds ={12312}, isTalent =1},
      -- @Improved Disarm Rank 2
      {id =12804, requiredIds ={12313}, isTalent =1},
      -- @Improved Disarm Rank 3
      {id =12807, requiredIds ={12804}, isTalent =1},
      -- @Concussion Blow undefined
      {id =12809, isTalent =1},
      -- @Improved Sunder Armor Rank 2
      {id =12810, requiredIds ={12308}, isTalent =1},
      -- @Improved Sunder Armor Rank 3
      {id =12811, requiredIds ={12810}, isTalent =1},
      -- @Sword Specialization Rank 2
      {id =12812, requiredIds ={12281}, isTalent =1},
      -- @Sword Specialization Rank 3
      {id =12813, requiredIds ={12812}, isTalent =1},
      -- @Sword Specialization Rank 4
      {id =12814, requiredIds ={12813}, isTalent =1},
      -- @Sword Specialization Rank 5
      {id =12815, requiredIds ={12814}, isTalent =1},
      -- @Improved Bloodrage Rank 2
      {id =12818, requiredIds ={12301}, isTalent =1},
      -- @Polearm Specialization Rank 2
      {id =12830, requiredIds ={12165}, isTalent =1},
      -- @Polearm Specialization Rank 3
      {id =12831, requiredIds ={12830}, isTalent =1},
      -- @Polearm Specialization Rank 4
      {id =12832, requiredIds ={12831}, isTalent =1},
      -- @Polearm Specialization Rank 5
      {id =12833, requiredIds ={12832}, isTalent =1},
      -- @Deep Wounds Rank 1
      {id =12834, isTalent =1},
      -- @Booming Voice Rank 2
      {id =12835, requiredIds ={12321}, isTalent =1},
      -- @Booming Voice Rank 3
      {id =12836, requiredIds ={12835}, isTalent =1},
      -- @Booming Voice Rank 4
      {id =12837, requiredIds ={12836}, isTalent =1},
      -- @Booming Voice Rank 5
      {id =12838, requiredIds ={12837}, isTalent =1},
      -- @Deep Wounds Rank 2
      {id =12849, requiredIds ={12834}, isTalent =1},
      -- @Cruelty Rank 2
      {id =12852, requiredIds ={12320}, isTalent =1},
      -- @Cruelty Rank 3
      {id =12853, requiredIds ={12852}, isTalent =1},
      -- @Cruelty Rank 4
      {id =12855, requiredIds ={12853}, isTalent =1},
      -- @Cruelty Rank 5
      {id =12856, requiredIds ={12855}, isTalent =1},
      -- @Improved Battle Shout Rank 2
      {id =12857, requiredIds ={12318}, isTalent =1},
      -- @Improved Battle Shout Rank 3
      {id =12858, requiredIds ={12857}, isTalent =1},
      -- @Improved Battle Shout Rank 4
      {id =12860, requiredIds ={12858}, isTalent =1},
      -- @Improved Battle Shout Rank 5
      {id =12861, requiredIds ={12860}, isTalent =1},
      -- @Improved Slam Rank 1
      {id =12862, isTalent =1},
      -- @Deep Wounds Rank 3
      {id =12867, requiredIds ={12849}, isTalent =1},
      -- @Improved Demoralizing Shout Rank 2
      {id =12876, requiredIds ={12324}, isTalent =1},
      -- @Improved Demoralizing Shout Rank 3
      {id =12877, requiredIds ={12876}, isTalent =1},
      -- @Improved Demoralizing Shout Rank 4
      {id =12878, requiredIds ={12877}, isTalent =1},
      -- @Improved Demoralizing Shout Rank 5
      {id =12879, requiredIds ={12878}, isTalent =1},
      -- @Improved Shield Block Rank 3
      {id =12944, requiredIds ={12307}, isTalent =1},
      -- @Improved Shield Block Rank 1
      {id =12945, isTalent =1},
      -- @Improved Cleave Rank 2
      {id =12950, requiredIds ={12329}, isTalent =1},
      -- @Improved Shield Bash Rank 2
      {id =12958, requiredIds ={12311}, isTalent =1},
      -- @Iron Will Rank 2
      {id =12959, requiredIds ={12300}, isTalent =1},
      -- @Iron Will Rank 3
      {id =12960, requiredIds ={12959}, isTalent =1},
      -- @Iron Will Rank 4
      {id =12961, requiredIds ={12960}, isTalent =1},
      -- @Iron Will Rank 5
      {id =12962, requiredIds ={12961}, isTalent =1},
      -- @Improved Overpower Rank 2
      {id =12963, requiredIds ={12290}, isTalent =1},
      -- @Flurry Rank 2
      {id =12971, requiredIds ={12319}, isTalent =1},
      -- @Flurry Rank 3
      {id =12972, requiredIds ={12971}, isTalent =1},
      -- @Flurry Rank 4
      {id =12973, requiredIds ={12972}, isTalent =1},
      -- @Flurry Rank 5
      {id =12974, requiredIds ={12973}, isTalent =1},
      -- @Last Stand undefined
      {id =12975, isTalent =1},
      -- @Unbridled Wrath Rank 2
      {id =12999, requiredIds ={12322}, isTalent =1},
      -- @Unbridled Wrath Rank 3
      {id =13000, requiredIds ={12999}, isTalent =1},
      -- @Unbridled Wrath Rank 4
      {id =13001, requiredIds ={13000}, isTalent =1},
      -- @Unbridled Wrath Rank 5
      {id =13002, requiredIds ={13001}, isTalent =1},
      -- @Enrage Rank 2
      {id =13045, requiredIds ={12317}, isTalent =1},
      -- @Enrage Rank 3
      {id =13046, requiredIds ={13045}, isTalent =1},
      -- @Enrage Rank 4
      {id =13047, requiredIds ={13046}, isTalent =1},
      -- @Enrage Rank 5
      {id =13048, requiredIds ={13047}, isTalent =1},
      -- @Fist Weapons undefined
      {id =15590, isTalent =0},
      -- @Deflection Rank 1
      {id =16462, isTalent =1},
      -- @Deflection Rank 2
      {id =16463, requiredIds ={16462}, isTalent =1},
      -- @Deflection Rank 3
      {id =16464, requiredIds ={16463}, isTalent =1},
      -- @Deflection Rank 4
      {id =16465, requiredIds ={16464}, isTalent =1},
      -- @Deflection Rank 5
      {id =16466, requiredIds ={16465}, isTalent =1},
      -- @Blood Craze Rank 1
      {id =16487, isTalent =1},
      -- @Blood Craze Rank 2
      {id =16489, requiredIds ={16487}, isTalent =1},
      -- @Blood Craze Rank 3
      {id =16492, requiredIds ={16489}, isTalent =1},
      -- @Impale Rank 1
      {id =16493, isTalent =1},
      -- @Impale Rank 2
      {id =16494, requiredIds ={16493}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 1
      {id =16538, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 2
      {id =16539, requiredIds ={16538}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 3
      {id =16540, requiredIds ={16539}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 4
      {id =16541, requiredIds ={16540}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 5
      {id =16542, requiredIds ={16541}, isTalent =1},
      -- @Improved Cleave Rank 3
      {id =20496, requiredIds ={12950}, isTalent =1},
      -- @Improved Slam Rank 3
      {id =20497, requiredIds ={12330}, isTalent =1},
      -- @Improved Slam Rank 4
      {id =20498, requiredIds ={20497}, isTalent =1},
      -- @Improved Slam Rank 5
      {id =20499, requiredIds ={20498}, isTalent =1},
      -- @Improved Berserker Rage Rank 1
      {id =20500, isTalent =1},
      -- @Improved Berserker Rage Rank 2
      {id =20501, requiredIds ={20500}, isTalent =1},
      -- @Improved Execute Rank 1
      {id =20502, isTalent =1},
      -- @Improved Execute Rank 2
      {id =20503, requiredIds ={20502}, isTalent =1},
      -- @Improved Intercept Rank 1
      {id =20504, isTalent =1},
      -- @Improved Intercept Rank 2
      {id =20505, requiredIds ={20504}, isTalent =1},
      -- @Dual Wield Specialization Rank 1
      {id =23584, isTalent =1},
      -- @Dual Wield Specialization Rank 2
      {id =23585, requiredIds ={23584}, isTalent =1},
      -- @Dual Wield Specialization Rank 3
      {id =23586, requiredIds ={23585}, isTalent =1},
      -- @Dual Wield Specialization Rank 4
      {id =23587, requiredIds ={23586}, isTalent =1},
      -- @Dual Wield Specialization Rank 5
      {id =23588, requiredIds ={23587}, isTalent =1},
      -- @Improved Hamstring Rank 3
      {id =23695, requiredIds ={12668}, isTalent =1},
      -- @Bloodthirst Rank 1
      {id =23881, isTalent =1},
      -- @Shield Slam Rank 1
      {id =23922, isTalent =1},
       },
[1] = {
      -- @Heroic Strike Rank 1
      {id =78, isTalent =0},
      -- @Block Passive
      {id =107, isTalent =0},
      -- @Battle Stance undefined
      {id =2457, isTalent =0},
      -- @Shoot Bow undefined
      {id =2480, isTalent =0},
      -- @Throw undefined
      {id =2764, isTalent =0},
      -- @Parry Passive
      {id =3127, isTalent =0},
      -- @Battle Shout Rank 1
      {id =6673, cost =10, isTalent =0},
      -- @Shoot Gun undefined
      {id =7918, isTalent =0},
      -- @Shoot Crossbow undefined
      {id =7919, isTalent =0},
      -- @Improved Pummel Rank 1
      {id =12288, isTalent =0},
      -- @Improved Pummel Rank 2
      {id =12707, requiredIds ={12288}, isTalent =0},
      -- @Improved Pummel Rank 3
      {id =12708, requiredIds ={12707}, isTalent =0},
       },
[4] = {
      -- @Charge Rank 1
      {id =100, cost =100, isTalent =0},
      -- @Rend Rank 1
      {id =772, cost =100, isTalent =0},
       },
[6] = {
      -- @Thunder Clap Rank 1
      {id =6343, cost =100, isTalent =0},
       },
[8] = {
      -- @Heroic Strike Rank 2
      {id =284, requiredIds ={78}, cost =200, isTalent =0},
      -- @Hamstring Rank 1
      {id =1715, cost =200, isTalent =0},
       },
[10] = {
      -- @Defensive Stance undefined
      {id =71, isTalent =0},
      -- @Taunt undefined
      {id =355, isTalent =0},
      -- @Bloodrage undefined
      {id =2687, cost =600, isTalent =0},
      -- @Rend Rank 2
      {id =6546, requiredIds ={772}, cost =600, isTalent =0},
      -- @Sunder Armor Rank 1
      {id =7386, isTalent =0},
       },
[12] = {
      -- @Shield Bash Rank 1
      {id =72, cost =1000, isTalent =0},
      -- @Battle Shout Rank 2
      {id =5242, requiredIds ={6673}, cost =1000, isTalent =0},
      -- @Overpower Rank 1
      {id =7384, cost =1000, isTalent =0},
       },
[14] = {
      -- @Demoralizing Shout Rank 1
      {id =1160, cost =1500, isTalent =0},
      -- @Revenge Rank 1
      {id =6572, cost =1500, isTalent =0},
       },
[16] = {
      -- @Heroic Strike Rank 3
      {id =285, requiredIds ={284}, cost =2000, isTalent =0},
      -- @Mocking Blow Rank 1
      {id =694, cost =2000, isTalent =0},
      -- @Shield Block undefined
      {id =2565, cost =2000, isTalent =0},
       },
[18] = {
      -- @Disarm undefined
      {id =676, cost =3000, isTalent =0},
      -- @Thunder Clap Rank 2
      {id =8198, requiredIds ={6343}, cost =3000, isTalent =0},
       },
[20] = {
      -- @Cleave Rank 1
      {id =845, cost =4000, isTalent =0},
      -- @Rend Rank 3
      {id =6547, requiredIds ={6546}, cost =4000, isTalent =0},
      -- @Retaliation undefined
      {id =20230, cost =4000, isTalent =0},
       },
[22] = {
      -- @Intimidating Shout undefined
      {id =5246, cost =6000, isTalent =0},
      -- @Battle Shout Rank 3
      {id =6192, requiredIds ={5242}, cost =6000, isTalent =0},
      -- @Sunder Armor Rank 2
      {id =7405, requiredIds ={7386}, cost =6000, isTalent =0},
       },
[24] = {
      -- @Heroic Strike Rank 4
      {id =1608, requiredIds ={285}, cost =8000, isTalent =0},
      -- @Execute Rank 1
      {id =5308, cost =8000, isTalent =0},
      -- @Demoralizing Shout Rank 2
      {id =6190, requiredIds ={1160}, cost =8000, isTalent =0},
      -- @Revenge Rank 2
      {id =6574, requiredIds ={6572}, cost =8000, isTalent =0},
       },
[26] = {
      -- @Challenging Shout undefined
      {id =1161, cost =10000, isTalent =0},
      -- @Charge Rank 2
      {id =6178, requiredIds ={100}, cost =10000, isTalent =0},
      -- @Mocking Blow Rank 2
      {id =7400, requiredIds ={694}, cost =10000, isTalent =0},
       },
[28] = {
      -- @Shield Wall undefined
      {id =871, cost =11000, isTalent =0},
      -- @Overpower Rank 2
      {id =7887, requiredIds ={7384}, cost =11000, isTalent =0},
      -- @Thunder Clap Rank 3
      {id =8204, requiredIds ={8198}, cost =11000, isTalent =0},
       },
[30] = {
      -- @Slam Rank 1
      {id =1464, cost =12000, isTalent =0},
      -- @Berserker Stance undefined
      {id =2458, isTalent =0},
      -- @Rend Rank 4
      {id =6548, requiredIds ={6547}, cost =12000, isTalent =0},
      -- @Cleave Rank 2
      {id =7369, requiredIds ={845}, cost =12000, isTalent =0},
      -- @Intercept Rank 1
      {id =20252, isTalent =0},
       },
[32] = {
      -- @Shield Bash Rank 2
      {id =1671, requiredIds ={72}, cost =14000, isTalent =0},
      -- @Hamstring Rank 2
      {id =7372, requiredIds ={1715}, cost =14000, isTalent =0},
      -- @Battle Shout Rank 4
      {id =11549, requiredIds ={6192}, cost =14000, isTalent =0},
      -- @Heroic Strike Rank 5
      {id =11564, requiredIds ={1608}, cost =14000, isTalent =0},
      -- @Berserker Rage undefined
      {id =18499, cost =14000, isTalent =0},
      -- @Execute Rank 2
      {id =20658, requiredIds ={5308}, cost =14000, isTalent =0},
       },
[34] = {
      -- @Revenge Rank 3
      {id =7379, requiredIds ={6574}, cost =16000, isTalent =0},
      -- @Sunder Armor Rank 3
      {id =8380, requiredIds ={7405}, cost =16000, isTalent =0},
      -- @Demoralizing Shout Rank 3
      {id =11554, requiredIds ={6190}, cost =16000, isTalent =0},
       },
[36] = {
      -- @Whirlwind undefined
      {id =1680, cost =18000, isTalent =0},
      -- @Mocking Blow Rank 3
      {id =7402, requiredIds ={7400}, cost =18000, isTalent =0},
       },
[38] = {
      -- @Pummel Rank 1
      {id =6552, cost =20000, isTalent =0},
      -- @Thunder Clap Rank 4
      {id =8205, requiredIds ={8204}, cost =20000, isTalent =0},
      -- @Slam Rank 2
      {id =8820, requiredIds ={1464}, cost =20000, isTalent =0},
       },
[40] = {
      -- @Heroic Strike Rank 6
      {id =11565, requiredIds ={11564}, cost =22000, isTalent =0},
      -- @Rend Rank 5
      {id =11572, requiredIds ={6548}, cost =22000, isTalent =0},
      -- @Cleave Rank 3
      {id =11608, requiredIds ={7369}, cost =22000, isTalent =0},
      -- @Execute Rank 3
      {id =20660, requiredIds ={20658}, cost =22000, isTalent =0},
       },
[42] = {
      -- @Battle Shout Rank 5
      {id =11550, requiredIds ={11549}, cost =32000, isTalent =0},
      -- @Intercept Rank 2
      {id =20616, requiredIds ={20252}, cost =32000, isTalent =0},
       },
[44] = {
      -- @Demoralizing Shout Rank 4
      {id =11555, requiredIds ={11554}, cost =34000, isTalent =0},
      -- @Overpower Rank 3
      {id =11584, requiredIds ={7887}, cost =34000, isTalent =0},
      -- @Revenge Rank 4
      {id =11600, requiredIds ={7379}, cost =34000, isTalent =0},
       },
[46] = {
      -- @Charge Rank 3
      {id =11578, requiredIds ={6178}, cost =36000, isTalent =0},
      -- @Sunder Armor Rank 4
      {id =11596, requiredIds ={8380}, cost =36000, isTalent =0},
      -- @Slam Rank 3
      {id =11604, requiredIds ={8820}, cost =36000, isTalent =0},
      -- @Mocking Blow Rank 4
      {id =20559, requiredIds ={7402}, cost =36000, isTalent =0},
       },
[48] = {
      -- @Heroic Strike Rank 7
      {id =11566, requiredIds ={11565}, cost =40000, isTalent =0},
      -- @Thunder Clap Rank 5
      {id =11580, requiredIds ={8205}, cost =40000, isTalent =0},
      -- @Execute Rank 4
      {id =20661, requiredIds ={20660}, cost =40000, isTalent =0},
      -- @Mortal Strike Rank 2
      {id =21551, requiredIds ={12294}, cost =2000, isTalent =0},
      -- @Bloodthirst Rank 2
      {id =23892, requiredIds ={23881}, cost =2000, isTalent =0},
      -- @Shield Slam Rank 2
      {id =23923, requiredIds ={23922}, cost =2000, isTalent =0},
       },
[50] = {
      -- @Recklessness undefined
      {id =1719, cost =42000, isTalent =0},
      -- @Rend Rank 6
      {id =11573, requiredIds ={11572}, cost =42000, isTalent =0},
      -- @Cleave Rank 4
      {id =11609, requiredIds ={11608}, cost =42000, isTalent =0},
       },
[52] = {
      -- @Shield Bash Rank 3
      {id =1672, requiredIds ={1671}, cost =54000, isTalent =0},
      -- @Battle Shout Rank 6
      {id =11551, requiredIds ={11550}, cost =54000, isTalent =0},
      -- @Intercept Rank 3
      {id =20617, requiredIds ={20616}, cost =54000, isTalent =0},
       },
[54] = {
      -- @Hamstring Rank 3
      {id =7373, requiredIds ={7372}, cost =56000, isTalent =0},
      -- @Demoralizing Shout Rank 5
      {id =11556, requiredIds ={11555}, cost =56000, isTalent =0},
      -- @Revenge Rank 5
      {id =11601, requiredIds ={11600}, cost =56000, isTalent =0},
      -- @Slam Rank 4
      {id =11605, requiredIds ={11604}, cost =56000, isTalent =0},
      -- @Mortal Strike Rank 3
      {id =21552, requiredIds ={21551}, cost =2800, isTalent =0},
      -- @Bloodthirst Rank 3
      {id =23893, requiredIds ={23892}, cost =2800, isTalent =0},
      -- @Shield Slam Rank 3
      {id =23924, requiredIds ={23923}, cost =2800, isTalent =0},
       },
[56] = {
      -- @Heroic Strike Rank 8
      {id =11567, requiredIds ={11566}, cost =58000, isTalent =0},
      -- @Mocking Blow Rank 5
      {id =20560, requiredIds ={20559}, cost =58000, isTalent =0},
      -- @Execute Rank 5
      {id =20662, requiredIds ={20661}, cost =58000, isTalent =0},
       },
[58] = {
      -- @Pummel Rank 2
      {id =6554, requiredIds ={6552}, cost =60000, isTalent =0},
      -- @Thunder Clap Rank 6
      {id =11581, requiredIds ={11580}, cost =60000, isTalent =0},
      -- @Sunder Armor Rank 5
      {id =11597, requiredIds ={11596}, cost =60000, isTalent =0},
       },
[60] = {
      -- @Rend Rank 7
      {id =11574, requiredIds ={11573}, cost =62000, isTalent =0},
      -- @Overpower Rank 4
      {id =11585, requiredIds ={11584}, cost =62000, isTalent =0},
      -- @Cleave Rank 5
      {id =20569, requiredIds ={11609}, cost =62000, isTalent =0},
      -- @Mortal Strike Rank 4
      {id =21553, requiredIds ={21552}, cost =3100, isTalent =0},
      -- @Bloodthirst Rank 4
      {id =23894, requiredIds ={23893}, cost =3100, isTalent =0},
      -- @Shield Slam Rank 4
      {id =23925, requiredIds ={23924}, cost =3100, isTalent =0},
      -- @Heroic Strike Rank 9
      {id =25286, requiredIds ={11567}, isTalent =0},
      -- @Revenge Rank 6
      {id =25288, requiredIds ={11601}, isTalent =0},
      -- @Battle Shout Rank 7
      {id =25289, requiredIds ={11551}, isTalent =0}
        }
}
