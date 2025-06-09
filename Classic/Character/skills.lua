local _, GW = ...

GW.Skills = {
    HUNTER = {
		[1] = {
			{1494,10, optional=true}, -- Track Beasts
		},
		[4] = {
			{1978,100, rank=1}, -- Serpent Sting Rank 1
			{13163,100, optional=true}, -- Aspect of the Monkey
		},
		[6] = {
			{1130,100, optional=true, rank=1}, -- Hunter's Mark Rank 1
			{3044,100, rank=1}, -- Arcane Shot Rank 1
		},
		[8] = {
			{3127,200, optional=true}, -- Parry Passive
			{5116,200, optional=true}, -- Concussive Shot
			{14260,200, optional=true, rank=2}, -- Raptor Strike Rank 2
		},
		[10] = {
			{4187,10, pet=true, rank=1}, -- Great Stamina Rank 1
			{13165,400, rank=1}, -- Aspect of the Hawk Rank 1
			{13549,400, req=1978, rank=2}, -- Serpent Sting Rank 2
			{19883,400, optional=true}, -- Track Humanoids
			{24545,10, pet=true, rank=1}, -- Natural Armor Rank 1
			{14916,100, req=2649, rank=2, pet=true}, -- Growl rank 2
		},
		[12] = {
			{136,600, req=1515, rank=1}, -- Mend Pet Rank 1
			{2974,600, rank=1}, -- Wing Clip Rank 1
			{4188,120, req=4187, pet=true, rank=2}, -- Great Stamina Rank 2
			{14281,600, req=3044, rank=2}, -- Arcane Shot Rank 2
			{20736,600, optional=true, rank=1}, -- Distracting Shot Rank 1
			{24549,120, req=24545, pet=true, rank=2}, -- Natural Armor Rank 2
		},
		[14] = {
			{1002,1200, optional=true}, -- Eyes of the Beast
			{1513,1200, optional=true, rank=1}, -- Scare Beast Rank 1
			{6197,1200, optional=true}, -- Eagle Eye
		},
		[16] = {
			{1495,1800, optional=true, rank=1}, -- Mongoose Bite Rank 1
			{13795,1800, rank=1}, -- Immolation Trap Rank 1
			{14261,1800, req=14260, optional=true, rank=3}, -- Raptor Strike Rank 3
		},
		[18] = {
			{2643,2000, rank=1}, -- Multi-Shot Rank 1
			{4189,400, req=4188, pet=true, rank=3}, -- Great Stamina Rank 3
			{13550,2000, req=13549, rank=3}, -- Serpent Sting Rank 3
			{14318,2000, req=13165, rank=2}, -- Aspect of the Hawk Rank 2
			{19884,2000, optional=true}, -- Track Undead
			{24550,400, req=24549, pet=true, rank=3}, -- Natural Armor Rank 3
		},
		[20] = {
			{674,2200}, -- Dual Wield Passive
			{781,2200, optional=true, rank=1}, -- Disengage Rank 1
			{1499,2200, rank=1}, -- Freezing Trap Rank 1
			{3111,2200, req=136, rank=2}, -- Mend Pet Rank 2
			{5118,2200}, -- Aspect of the Cheetah
			{14274,2200, req=20736, optional=true, rank=2}, -- Distracting Shot Rank 2
			{14282,2200, req=14281, rank=3}, -- Arcane Shot Rank 3
			{14917,440, req=14916, pet=true, rank=3}, -- Growl Rank 3
			{23992,440, pet=true, rank=1}, -- Fire Resistance Rank 1
			{24446,440, pet=true, rank=1}, -- Frost Resistance Rank 1
			{24493,440, optional=true, pet=true, rank=1}, -- Arcane Resistance Rank 1
			{24488,40, optional=true, pet=true, rank=1}, -- Shadow Resistance Rank 1
			{24492,440, optional=true, pet=true, rank=1}, -- Nature Resistance Rank 1
		},
		[22] = {
			{3043,6000, optional=true, rank=1}, -- Scorpid Sting Rank 1
			{14323,6000, req=1130, optional=true, rank=2}, -- Hunter's Mark Rank 2
		},
		[24] = {
			{1462,7000, optional=true}, -- Beast Lore
			{4190,1260, req=4189, pet=true, rank=4}, -- Great Stamina Rank 4
			{14262,7000, req=14261, optional=true, rank=4}, -- Raptor Strike Rank 4
			{19885,7000, optional=true}, -- Track Hidden
			{24551,1260, req=24550, pet=true, rank=4}, -- Natural Armor Rank 4
		},
		[26] = {
			{3045,7000}, -- Rapid Fire
			{13551,7000, req=13550, rank=4}, -- Serpent Sting Rank 4
			{14302,7000, req=13795, rank=2}, -- Immolation Trap Rank 2
			{19880,7000, optional=true}, -- Track Elementals
		},
		[28] = {
			{3661,8000, req=3111, rank=3}, -- Mend Pet Rank 3
			{13809,8000, optional=true}, -- Frost Trap
			{14283,8000, req=14282, rank=4}, -- Arcane Shot Rank 4
			{14319,8000, req=14318, rank=3}, -- Aspect of the Hawk Rank 3
			{20900,400, req=19434, talent=19434, rank=2}, -- Aimed Shot Rank 2
		},
		[30] = {
			{4191,1440, req=4190, pet=true, rank=5}, -- Great Stamina Rank 5
			{5384,8000}, -- Feign Death
			{13161,8000, optional=true}, -- Aspect of the Beast
			{14269,8000, req=1495, optional=true, rank=2}, -- Mongoose Bite Rank 2
			{14288,8000, req=2643, rank=2}, -- Multi-Shot Rank 2
			{14326,8000, req=1513, optional=true, rank=2}, -- Scare Beast Rank 2
			{14918,1440, req=14917, pet=true, rank=4}, -- Growl Rank 4
			{15629,8000, req=14274, optional=true, rank=3}, -- Distracting Shot Rank 3
			{24439,1440, req=23992, pet=true, rank=2}, -- Fire Resistance Rank 2
			{24447,1440, req=24446, pet=true, rank=2}, -- Frost Resistance Rank 2
			{24497,1440, req=24493, optional=true, pet=true, rank=2}, -- Arcane Resistance Rank 2
			{24505,1440, req=24488, optional=true, pet=true, rank=2}, -- Shadow Resistance Rank 2
			{24502,1440, req=24492, optional=true, pet=true, rank=2}, -- Nature Resistance Rank 2
			{24552,1440, req=24551, pet=true, rank=5}, -- Natural Armor Rank 5
		},
		[32] = {
			{1543,10000, optional=true}, -- Flare
			{14263,10000, req=14262, optional=true, rank=5}, -- Raptor Strike Rank 5
			{14275,10000, req=3043, optional=true, rank=2}, -- Scorpid Sting Rank 2
			{19878,10000, optional=true}, -- Track Demons
		},
		[34] = {
			{13552,12000, req=13551, rank=5}, -- Serpent Sting Rank 5
			{13813,12000, optional=true, rank=1}, -- Explosive Trap Rank 1
			{14272,12000, req=781, optional=true, rank=2}, -- Disengage Rank 2
		},
		[36] = {
			{3034,14000, optional=true, rank=1}, -- Viper Sting Rank 1
			{3662,14000, req=3661, rank=4}, -- Mend Pet Rank 4
			{4192,2520, req=4191, pet=true, rank=6}, -- Great Stamina Rank 6
			{14284,14000, req=14283, rank=5}, -- Arcane Shot Rank 5
			{14303,14000, req=14302, rank=3}, -- Immolation Trap Rank 3
			{20901,700, req=20900, talent=19434, rank=3}, -- Aimed Shot Rank 3
			{24553,2520, req=24552, pet=true, rank=6}, -- Natural Armor Rank 6
		},
		[38] = {
			{14267,16000, req=2974, optional=true, rank=2}, -- Wing Clip Rank 2
			{14320,16000, req=14319, rank=4}, -- Aspect of the Hawk Rank 4
		},
		[40] = {
			{1510,18000, optional=true, rank=1}, -- Volley Rank 1
			{8737,18000}, -- Mail
			{13159,18000, optional=true}, -- Aspect of the Pack
			{14264,18000, req=14263, optional=true, rank=6}, -- Raptor Strike Rank 6
			{14310,18000, req=1499, rank=2}, -- Freezing Trap Rank 2
			{14324,18000, req=14323, optional=true, rank=3}, -- Hunter's Mark Rank 3
			{14919,3240, req=14918, pet=true, rank=5}, -- Growl Rank 5
			{15630,18000, req=15629, optional=true, rank=4}, -- Distracting Shot Rank 4
			{19882,18000, optional=true}, -- Track Giants
			{24444,3240, req=24439, pet=true, rank=3}, -- Fire Resistance Rank 3
			{24448,3240, req=24447, pet=true, rank=3}, -- Frost Resistance Rank 3
			{24500,3240, req=24497, optional=true, pet=true, rank=3}, -- Arcane Resistance Rank 3
			{24506,3240, req=24505, optional=true, pet=true, rank=3}, -- Shadow Resistance Rank 3
			{24503,3240, req=24502, optional=true, pet=true, rank=3}, -- Nature Resistance Rank 3
		},
		[42] = {
			{4193,4320, req=4192, pet=true, rank=7}, -- Great Stamina Rank 7
			{13553,24000, req=13552, rank=6}, -- Serpent Sting Rank 6
			{14276,24000, req=14275, optional=true, rank=3}, -- Scorpid Sting Rank 3
			{14289,24000, req=14288, rank=3}, -- Multi-Shot Rank 3
			{20909,1200, req=19306, talent=19306, rank=2}, -- Counterattack Rank 2
			{24554,4320, req=24553, pet=true, rank=7}, -- Natural Armor Rank 7
		},
		[44] = {
			{13542,26000, req=3662, rank=5}, -- Mend Pet Rank 5
			{14270,26000, req=14269, optional=true, rank=3}, -- Mongoose Bite Rank 3
			{14285,26000, req=14284, rank=6}, -- Arcane Shot Rank 6
			{14316,26000, req=13813, optional=true, rank=2}, -- Explosive Trap Rank 2
			{20902,1300, req=20901, talent=19434, rank=4}, -- Aimed Shot Rank 4
		},
		[46] = {
			{14279,28000, req=3034, optional=true, rank=2}, -- Viper Sting Rank 2
			{14304,28000, req=14303, rank=4}, -- Immolation Trap Rank 4
			{14327,28000, req=14326, optional=true, rank=3}, -- Scare Beast Rank 3
			{20043,28000, optional=true, rank=1}, -- Aspect of the Wild Rank 1
		},
		[48] = {
			{4194,5760, req=4193, pet=true, rank=8}, -- Great Stamina Rank 8
			{14265,32000, req=14264, optional=true, rank=7}, -- Raptor Strike Rank 7
			{14273,32000, req=14272, optional=true, rank=3}, -- Disengage Rank 3
			{14321,32000, req=14320, rank=5}, -- Aspect of the Hawk Rank 5
			{24555,5760, req=24554, pet=true, rank=8}, -- Natural Armor Rank 8
		},
		[50] = {
			{13554,36000, req=13553, rank=7}, -- Serpent Sting Rank 7
			{14294,36000, req=1510, optional=true, rank=2}, -- Volley Rank 2
			{14920,6480, req=14919, pet=true, rank=6}, -- Growl Rank 6
			{15631,36000, req=15630, optional=true, rank=5}, -- Distracting Shot Rank 5
			{19879,36000, optional=true}, -- Track Dragonkin
			{20905,1800, req=19506, talent=19506, rank=2}, -- Trueshot Aura Rank 2
			{24132,1800, req=19386, talent=19386, rank=2}, -- Wyvern Sting Rank 2
			{24445,6480, req=24444, pet=true, rank=4}, -- Fire Resistance Rank 4
			{24449,6480, req=24448, pet=true, rank=4}, -- Frost Resistance Rank 4
			{24501,6480, req=24500, optional=true, pet=true, rank=4}, -- Arcane Resistance Rank 4
			{24507,6480, req=24506, optional=true, pet=true, rank=4}, -- Shadow Resistance Rank 4
			{24504,6480, req=24503, optional=true, pet=true, rank=4}, -- Nature Resistance Rank 4
		},
		[52] = {
			{13543,40000, req=13542, rank=6}, -- Mend Pet Rank 6
			{14277,40000, req=14276, optional=true, rank=4}, -- Scorpid Sting Rank 4
			{14286,40000, req=14285, rank=7}, -- Arcane Shot Rank 7
			{20903,2000, req=20902, talent=19434, rank=5}, -- Aimed Shot Rank 5
		},
		[54] = {
			{5041,7560, req=4194, pet=true, rank=9}, -- Great Stamina Rank 9
			{14290,42000, req=14289, rank=4}, -- Multi-Shot Rank 4
			{14317,42000, req=14316, optional=true, rank=3}, -- Explosive Trap Rank 3
			{20910,2100, req=20909, talent=19306, rank=3}, -- Counterattack Rank 3
			{24629,7560, req=24555, pet=true, rank=9}, -- Natural Armor Rank 9
		},
		[56] = {
			{14266,46000, req=14265, optional=true, rank=8}, -- Raptor Strike Rank 8
			{14280,46000, req=14279, optional=true, rank=3}, -- Viper Sting Rank 3
			{14305,46000, req=14304, rank=5}, -- Immolation Trap Rank 5
			{20190,46000, req=20043, optional=true, rank=2}, -- Aspect of the Wild Rank 2
		},
		[58] = {
			{13555,48000, req=13554, rank=8}, -- Serpent Sting Rank 8
			{14271,48000, req=14270, optional=true, rank=4}, -- Mongoose Bite Rank 4
			{14295,48000, req=14294, optional=true, rank=3}, -- Volley Rank 3
			{14322,48000, req=14321, rank=6}, -- Aspect of the Hawk Rank 6
			{14325,48000, req=14324, optional=true, rank=4}, -- Hunter's Mark Rank 4
		},
		[60] = {
			{5042,9000, req=5041, pet=true, rank=10}, -- Great Stamina Rank 10
			{13544,50000, req=13543, rank=7}, -- Mend Pet Rank 7
			{14268,50000, req=14267, optional=true, rank=3}, -- Wing Clip Rank 3
			{14287,50000, req=14286, rank=8}, -- Arcane Shot Rank 8
			{14311,50000, req=14310, rank=3}, -- Freezing Trap Rank 3
			{14921,9000, req=14920, pet=true, rank=7}, -- Growl Rank 7
			{15632,50000, req=15631, optional=true, rank=6}, -- Distracting Shot Rank 6
			{20904,2500, req=20903, talent=19434, rank=6}, -- Aimed Shot Rank 6
			{20906,2500, req=20905, talent=19506, rank=3}, -- Trueshot Aura Rank 3
			{24133,2500, req=24132, talent=19386, rank=3}, -- Wyvern Sting Rank 3
			{24630,9000, req=24629, pet=true, rank=10}, -- Natural Armor Rank 10
		},
	},
	WARRIOR = {
		[1] = {
			{6673,10, rank=1}, -- Battle Shout Rank 1
		},
		[4] = {
			{100,100, rank=1}, -- Charge Rank 1
			{772,100, rank=1}, -- Rend Rank 1
		},
		[6] = {
			{3127,100}, -- Parry Passive
			{6343,100, rank=1}, -- Thunder Clap Rank 1
		},
		[8] = {
			{284,200, req=78, rank=2}, -- Heroic Strike Rank 2
			{1715,200, rank=1}, -- Hamstring Rank 1
		},
		[10] = {
			{2687,600}, -- Bloodrage
			{6546,600, req=772, rank=2}, -- Rend Rank 2
		},
		[12] = {
			{72,1000, rank=1}, -- Shield Bash Rank 1
			{5242,1000, req=6673, rank=2}, -- Battle Shout Rank 2
			{7384,1000, rank=1}, -- Overpower Rank 1
		},
		[14] = {
			{1160,1500, rank=1}, -- Demoralizing Shout Rank 1
			{6572,1500, rank=1}, -- Revenge Rank 1
		},
		[16] = {
			{285,2000, req=284, rank=3}, -- Heroic Strike Rank 3
			{694,2000, rank=1}, -- Mocking Blow Rank 1
			{2565,2000, optional="not talentknown(12298)"}, -- Shield Block (Talents: Shield Specialization)
		},
		[18] = {
			{676,3000, optional="not talentknown(12298)"}, -- Disarm (Talents: Shield Specialization)
			{8198,3000, req=6343, optional=true, rank=2}, -- Thunder Clap Rank 2
		},
		[20] = {
			{674,4000}, -- Dual Wield Passive, optional=true for protection
			{845,4000, rank=1}, -- Cleave Rank 1
			{6547,4000, req=6546, rank=3}, -- Rend Rank 3
			{20230,4000}, -- Retaliation
		},
		[22] = {
			{5246,6000}, -- Intimidating Shout
			{6192,6000, req=5242, rank=3}, -- Battle Shout Rank 3
			{7405,6000, optional="not talentknown(12298)"}, -- Sunder Armor Rank 2 (Talents: Shield Specialization)
		},
		[24] = {
			{1608,8000, req=285, rank=4}, -- Heroic Strike Rank 4
			{5308,8000, rank=1}, -- Execute Rank 1
			{6190,8000, req=1160, optional="not talentknown(12298)"}, -- Demoralizing Shout Rank 2 (Talents: Shield Specialization)
			{6574,8000, req=6572, optional="not talentknown(12298)"}, -- Revenge Rank 2 (Talents: Shield Specialization)
		},
		[26] = {
			{1161,10000, optional="not talentknown(12298)"}, -- Challenging Shout (Talents: Shield Specialization)
			{6178,10000, req=100, optional=true, rank=2}, -- Charge Rank 2
			{7400,10000, req=694, optional=true, rank=2}, -- Mocking Blow Rank 2
		},
		[28] = {
			{871,11000, optional="not talentknown(12298)"}, -- Shield Wall (Talents: Shield Specialization)
			{7887,11000, req=7384, optional=true, rank=2}, -- Overpower Rank 2
			{8204,11000, req=8198, optional=true, rank=3}, -- Thunder Clap Rank 3
		},
		[30] = {
			{1464,12000, optional=true, rank=1}, -- Slam Rank 1
			{6548,12000, req=6547, rank=4}, -- Rend Rank 4
			{7369,12000, req=845, optional=true, rank=2}, -- Cleave Rank 2
		},
		[32] = {
			{1671,14000, req=72, optional=true, rank=2}, -- Shield Bash Rank 2
			{7372,14000, req=1715, optional=true, rank=2}, -- Hamstring Rank 2
			{11549,14000, req=6192, rank=4}, -- Battle Shout Rank 4
			{11564,14000, req=1608, optional=true, rank=5}, -- Heroic Strike Rank 5
			{18499,14000}, -- Berserker Rage
			{20658,14000, req=5308, rank=2}, -- Execute Rank 2
		},
		[34] = {
			{7379,16000, req=6574, optional="not talentknown(12298)"}, -- Revenge Rank 3 (Talents: Shield Specialization)
			{8380,16000, req=7405, optional="not talentknown(12298)"}, -- Sunder Armor Rank 3 (Talents: Shield Specialization)
			{11554,16000, req=6190, optional="not talentknown(12298)"}, -- Demoralizing Shout Rank 3 (Talents: Shield Specialization)
		},
		[36] = {
			{1680,18000}, -- Whirlwind, optional=true Only protection
			{7402,18000, req=7400, optional=true, rank=3}, -- Mocking Blow Rank 3
		},
		[38] = {
			{6552,20000, rank=1}, -- Pummel Rank 1
			{8205,20000, req=8204, optional=true, rank=4}, -- Thunder Clap Rank 4
			{8820,20000, req=1464, optional=true, rank=2}, -- Slam Rank 2
		},
		[40] = {
			{750,22000}, -- Plate Mail
			{11565,22000, req=11564, optional=true, rank=6}, -- Heroic Strike Rank 6
			{11572,22000, req=6548, optional=true, rank=5}, -- Rend Rank 5
			{11608,22000, req=7369, optional=true, rank=3}, -- Cleave Rank 3
			{20660,22000, req=20658, rank=3}, -- Execute Rank 3
		},
		[42] = {
			{11550,32000, req=11549, rank=5}, -- Battle Shout Rank 5
			{20616,32000, talent=20252, optional=true, rank=2}, -- Intercept Rank 2
		},
		[44] = {
			{11555,34000, req=11554, optional="not talentknown(23922)"}, -- Demoralizing Shout Rank 4 (Talents: Shield Slam)
			{11584,34000, req=7887, optional=true, rank=3}, -- Overpower Rank 3
			{11600,34000, req=7379, optional="not talentknown(23922)"}, -- Revenge Rank 4 (Talents: Shield Slam)
		},
		[46] = {
			{11578,36000, req=6178, optional=true, rank=3}, -- Charge Rank 3
			{11596,36000, req=8380, optional="not talentknown(23922)"}, -- Sunder Armor Rank 4 (Talents: Shield Slam)
			{11604,36000, req=8820, optional=true, rank=3}, -- Slam Rank 3
			{20559,36000, req=7402, optional=true, rank=4}, -- Mocking Blow Rank 4
		},
		[48] = {
			{11566,40000, req=11565, optional=true, rank=7}, -- Heroic Strike Rank 7
			{11580,40000, req=8205, optional=true, rank=5}, -- Thunder Clap Rank 5
			{20661,40000, req=20660, rank=4}, -- Execute Rank 4
			{21551,200, talent=12294, rank=2}, -- Mortal Strike Rank 2
			{23892,2000, talent=23881, rank=2}, -- Bloodthirst Rank 2
			{23923,200, talent=23922, rank=2}, -- Shield Slam Rank 2
		},
		[50] = {
			{1719,42000}, -- Recklessness
			{11573,42000, req=11572, optional=true, rank=6}, -- Rend Rank 6
			{11609,42000, req=11608, optional=true, rank=4}, -- Cleave Rank 4
		},
		[52] = {
			{1672,54000, req=1671, optional=true, rank=3}, -- Shield Bash Rank 3
			{11551,54000, req=11550, rank=6}, -- Battle Shout Rank 6
			{20617,54000, req=20616, talent=20252, optional=true, rank=3}, -- Intercept Rank 3
		},
		[54] = {
			{7373,56000, req=7372, optional=true, rank=3}, -- Hamstring Rank 3
			{11556,56000, req=11555, optional="not talentknown(23922)"}, -- Demoralizing Shout Rank 5 (Talents: Shield Slam)
			{11601,56000, req=11600, optional="not talentknown(23922)"}, -- Revenge Rank 5 (Talents: Shield Slam)
			{11605,56000, req=11604, optional=true, rank=4}, -- Slam Rank 4
			{21552,2800, req=21551, talent=12294, rank=3}, -- Mortal Strike Rank 3
			{23893,2800, req=23892, talent=23881, rank=3}, -- Bloodthirst Rank 3
			{23924,2800, req=23923, talent=23922, rank=3}, -- Shield Slam Rank 3
		},
		[56] = {
			{11567,58000, req=11566, optional=true, rank=8}, -- Heroic Strike Rank 8
			{20560,58000, req=20559, optional=true, rank=5}, -- Mocking Blow Rank 5
			{20662,58000, req=20661, rank=5}, -- Execute Rank 5
		},
		[58] = {
			{6554,60000, req=6552, optional=true, rank=2}, -- Pummel Rank 2
			{11581,60000, req=11580, optional=true, rank=6}, -- Thunder Clap Rank 6
			{11597,60000, req=11596, optional="not talentknown(23922)"}, -- Sunder Armor Rank 5 (Talents: Shield Slam)
		},
		[60] = {
			{11574,62000, req=11573, optional=true, rank=7}, -- Rend Rank 7
			{11585,62000, req=11584, optional=true, rank=4}, -- Overpower Rank 4
			{20569,62000, req=11609, optional=true, rank=5}, -- Cleave Rank 5
			{21553,3100, req=21552, talent=12294, rank=4}, -- Mortal Strike Rank 4
			{23894,3100, req=23893, talent=23881, rank=4}, -- Bloodthirst Rank 4
			{23925,3100, req=23924, talent=23922, rank=4}, -- Shield Slam Rank 4
		},
	},
	PALADIN = {
		[1] = {
			{465,10, rank=1}, -- Devotion Aura Rank 1
		},
		[4] = {
			{19740,100, rank=1}, -- Blessing of Might Rank 1
			{20271,100}, -- Judgement
		},
		[6] = {
			{498,100, rank=1}, -- Divine Protection Rank 1
			{639,100, req=635, rank=2}, -- Holy Light Rank 2
			{21082,100, optional=true, rank=1}, -- Seal of the Crusader Rank 1
		},
		[8] = {
			{853,100, rank=1}, -- Hammer of Justice Rank 1
			{1152,100}, -- Purify
			{3127,100}, -- Parry Passive
		},
		[10] = {
			{633,300, rank=1}, -- Lay on Hands Rank 1
			{1022,300, rank=1}, -- Blessing of Protection Rank 1
			{10290,300, req=465, rank=2}, -- Devotion Aura Rank 2
			{20287,300, req=21084, rank=2}, -- Seal of Righteousness Rank 2
		},
		[12] = {
			{19834,1000, req=19740, rank=2}, -- Blessing of Might Rank 2
			{20162,1000, req=21082, optional=true, rank=2}, -- Seal of the Crusader Rank 2
		},
		[14] = {
			{647,2000, req=639, rank=3}, -- Holy Light Rank 3
			{19742,2000, rank=1}, -- Blessing of Wisdom Rank 1
		},
		[16] = {
			{7294,3000, optional=true, rank=1}, -- Retribution Aura Rank 1
			{25780,3000}, -- Righteous Fury
		},
		[18] = {
			{1044,3500}, -- Blessing of Freedom
			{5573,3500, req=498, rank=2}, -- Divine Protection Rank 2
			{20288,3500, req=20287, rank=3}, -- Seal of Righteousness Rank 3
		},
		[20] = {
			{643,4000, req=10290, rank=3}, -- Devotion Aura Rank 3
			{879,4000, optional=true, rank=1}, -- Exorcism Rank 1
			{19750,4000, rank=1}, -- Flash of Light Rank 1
		},
		[22] = {
			{1026,4000, req=647, rank=4}, -- Holy Light Rank 4
			{19746,4000}, -- Concentration Aura
			{19835,4000, req=19834, rank=3}, -- Blessing of Might Rank 3
			{20164,4000, optional=true}, -- Seal of Justice
			{20305,4000, req=20162, optional=true, rank=3}, -- Seal of the Crusader Rank 3
		},
		[24] = {
			{2878,5000, optional=true, rank=1}, -- Turn Undead Rank 1
			{5588,5000, req=853, rank=2}, -- Hammer of Justice Rank 2
			{5599,5000, req=1022, rank=2}, -- Blessing of Protection Rank 2
			{10322,5000, optional=true, rank=2}, -- Redemption Rank 2
			{19850,5000, req=19742, rank=2}, -- Blessing of Wisdom Rank 2
		},
		[26] = {
			{1038,6000, optional="not talentknown(20127)"}, -- Blessing of Salvation (Talents: Redoubt)
			{10298,6000, req=7294, optional=true, rank=2}, -- Retribution Aura Rank 2
			{19939,6000, req=19750, rank=2}, -- Flash of Light Rank 2
			{20289,6000, req=20288, rank=4}, -- Seal of Righteousness Rank 4
		},
		[28] = {
			{5614,9000, req=879, optional=true, rank=2}, -- Exorcism Rank 2
			{19876,9000, optional=true, rank=1}, -- Shadow Resistance Aura Rank 1
		},
		[30] = {
			{1042,11000, req=1026, rank=5}, -- Holy Light Rank 5
			{2800,11000, req=633, optional=true, rank=2}, -- Lay on Hands Rank 2
			{10291,11000, req=643, rank=4}, -- Devotion Aura Rank 4
			{19752,11000, optional=true}, -- Divine Intervention
			{20116,200, talent=26573, rank=2}, -- Consecration Rank 2
			{20165,11000, rank=1}, -- Seal of Light Rank 1
			{20915,200, talent=20375, rank=2}, -- Seal of Command Rank 2
		},
		[32] = {
			{19836,12000, req=19835, rank=4}, -- Blessing of Might Rank 4
			{19888,12000, optional=true, rank=1}, -- Frost Resistance Aura Rank 1
			{20306,12000, req=20305, optional=true, rank=4}, -- Seal of the Crusader Rank 4
		},
		[34] = {
			{642,13000, rank=1}, -- Divine Shield Rank 1
			{19852,13000, req=19850, rank=3}, -- Blessing of Wisdom Rank 3
			{19940,13000, req=19939, rank=3}, -- Flash of Light Rank 3
			{20290,13000, req=20289, rank=5}, -- Seal of Righteousness Rank 5
		},
		[36] = {
			{5615,14000, req=5614, optional=true, rank=3}, -- Exorcism Rank 3
			{10299,14000, req=10298, optional=true, rank=3}, -- Retribution Aura Rank 3
			{10324,14000, req=10322, optional=true, rank=3}, -- Redemption Rank 3
			{19891,14000, optional=true, rank=1}, -- Fire Resistance Aura Rank 1
		},
		[38] = {
			{3472,16000, req=1042, rank=6}, -- Holy Light Rank 6
			{5627,16000, req=2878, optional=true, rank=2}, -- Turn Undead Rank 2
			{10278,16000, req=5599, rank=3}, -- Blessing of Protection Rank 3
			{20166,16000, rank=1}, -- Seal of Wisdom Rank 1
		},
		[40] = {
			{750,20000}, -- Plate Mail
			{1032,20000, req=10291, rank=5}, -- Devotion Aura Rank 5
			{5589,20000, req=5588, rank=3}, -- Hammer of Justice Rank 3
			{19895,20000, req=19876, optional=true, rank=2}, -- Shadow Resistance Aura Rank 2
			{19977,20000, optional=true, rank=1}, -- Blessing of Light Rank 1
			{20347,20000, req=20165, rank=2}, -- Seal of Light Rank 2
			{20912,900, talent=20911, optional=true, rank=2}, -- Blessing of Sanctuary Rank 2
			{20918,1000, req=20915, talent=20375, rank=3}, -- Seal of Command Rank 3
			{20922,1000, req=20116, talent=26573, rank=3}, -- Consecration Rank 3
		},
		[42] = {
			{4987,21000}, -- Cleanse
			{19837,21000, req=19836, rank=5}, -- Blessing of Might Rank 5
			{19941,21000, req=19940, rank=4}, -- Flash of Light Rank 4
			{20291,21000, req=20290, rank=6}, -- Seal of Righteousness Rank 6
			{20307,21000, req=20306, optional=true, rank=5}, -- Seal of the Crusader Rank 5
		},
		[44] = {
			{10312,22000, req=5615, optional=true, rank=4}, -- Exorcism Rank 4
			{19853,22000, req=19852, rank=4}, -- Blessing of Wisdom Rank 4
			{19897,22000, req=19888, optional=true, rank=2}, -- Frost Resistance Aura Rank 2
			{24275,22000, rank=1}, -- Hammer of Wrath Rank 1
		},
		[46] = {
			{6940,24000, optional=true, rank=1}, -- Blessing of Sacrifice Rank 1
			{10300,24000, req=10299, optional=true, rank=4}, -- Retribution Aura Rank 4
			{10328,24000, req=3472, rank=7}, -- Holy Light Rank 7
		},
		[48] = {
			{19899,26000, req=19891, optional=true, rank=2}, -- Fire Resistance Aura Rank 2
			{20356,26000, req=20166, rank=2}, -- Seal of Wisdom Rank 2
			{20772,26000, req=10324, optional=true, rank=4}, -- Redemption Rank 4
			{20929,1170, talent=20473, rank=2}, -- Holy Shock Rank 2
		},
		[50] = {
			{1020,28000, req=642, rank=2}, -- Divine Shield Rank 2
			{2812,28000, optional=true, rank=1}, -- Holy Wrath Rank 1
			{10292,28000, req=1032, rank=6}, -- Devotion Aura Rank 6
			{10310,28000, req=2800, optional=true, rank=3}, -- Lay on Hands Rank 3
			{19942,28000, req=19941, rank=5}, -- Flash of Light Rank 5
			{19978,28000, req=19977, optional=true, rank=2}, -- Blessing of Light Rank 2
			{20292,28000, req=20291, rank=7}, -- Seal of Righteousness Rank 7
			{20348,28000, req=20347, rank=3}, -- Seal of Light Rank 3
			{20913,1260, req=20912, talent=20911, optional=true, rank=3}, -- Blessing of Sanctuary Rank 3
			{20919,1260, req=20918, talent=20375, rank=4}, -- Seal of Command Rank 4
			{20923,1400, req=20922, talent=26573, rank=4}, -- Consecration Rank 4
			{20927,1260, talent=20925, rank=2}, -- Holy Shield Rank 2
		},
		[52] = {
			{10313,34000, req=10312, optional=true, rank=5}, -- Exorcism Rank 5
			{10326,34000, req=5627, optional=true, rank=3}, -- Turn Undead Rank 3
			{19838,34000, req=19837, rank=6}, -- Blessing of Might Rank 6
			{19896,34000, req=19895, optional=true, rank=3}, -- Shadow Resistance Aura Rank 3
			{20308,34000, req=20307, optional=true, rank=6}, -- Seal of the Crusader Rank 6
			{24274,34000, req=24275, rank=2}, -- Hammer of Wrath Rank 2
			{25782,46000, req=19838, rank=1}, -- Greater Blessing of Might Rank 1
		},
		[54] = {
			{10308,40000, req=5589, rank=4}, -- Hammer of Justice Rank 4
			{10329,40000, req=10328, rank=8}, -- Holy Light Rank 8
			{19854,40000, req=19853, rank=5}, -- Blessing of Wisdom Rank 5
			{20729,40000, req=6940, optional=true, rank=2}, -- Blessing of Sacrifice Rank 2
			{25894,40000, req=19854, rank=1}, -- Greater Blessing of Wisdom Rank 1
		},
		[56] = {
			{10301,42000, req=10300, optional=true, rank=5}, -- Retribution Aura Rank 5
			{19898,42000, req=19897, optional=true, rank=3}, -- Frost Resistance Aura Rank 3
			{20930,2100, req=20929, talent=20473, rank=3}, -- Holy Shock Rank 3
		},
		[58] = {
			{19943,44000, req=19942, rank=6}, -- Flash of Light Rank 6
			{20293,44000, req=20292, rank=8}, -- Seal of Righteousness Rank 8
			{20357,44000, req=20356, rank=3}, -- Seal of Wisdom Rank 3
		},
		[60] = {
			{10293,46000, req=10292, rank=7}, -- Devotion Aura Rank 7
			{10314,46000, req=10313, optional=true, rank=6}, -- Exorcism Rank 6
			{10318,46000, req=2812, optional=true, rank=2}, -- Holy Wrath Rank 2
			{19900,46000, req=19899, optional=true, rank=3}, -- Fire Resistance Aura Rank 3
			{19979,46000, req=19978, optional=true, rank=3}, -- Blessing of Light Rank 3
			{20349,46000, req=20348, rank=4}, -- Seal of Light Rank 4
			{20773,46000, req=20772, optional=true, rank=5}, -- Redemption Rank 5
			{20914,2070, req=20913, talent=20911, optional=true, rank=4}, -- Blessing of Sanctuary Rank 4
			{20920,2070, req=20919, talent=20375, rank=5}, -- Seal of Command Rank 5
			{20924,2300, req=20923, talent=26573, rank=5}, -- Consecration Rank 5
			{20928,2070, req=20927, talent=20925, rank=3}, -- Holy Shield Rank 3
			{24239,46000, req=24274, rank=3}, -- Hammer of Wrath Rank 3
			{25890,46000, req=19979, optional=true, rank=1}, -- Greater Blessing of Light Rank 1
			{25895,46000, req=1038, optional="not talentknown(20127)"}, -- Greater Blessing of Salvation (Talents: Redoubt)
			{25898,2070, talent=20217}, -- Greater Blessing of Kings
			{25899,2070, req=20914, talent=20911, optional=true, rank=1}, -- Greater Blessing of Sanctuary Rank 1
			{25916,41400, rank=2}, -- Greater Blessing of Might Rank 2
			{25918,46000, rank=2}, -- Greater Blessing of Wisdom Rank 2
		},
	},
	MAGE = {
		[1] = {
			{1459,10, rank=1}, -- Arcane Intellect Rank 1
		},
		[4] = {
			{116,100}, -- Frostbolt Rank 1 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{5504,100, rank=1}, -- Conjure Water Rank 1
		},
		[6] = {
			{143,100, req=133}, -- Fireball Rank 2 (Talents: Improved Fireball, Improved Arcane Missiles)
			{587,100, rank=1}, -- Conjure Food Rank 1
			{2136,100, rank=1}, -- Fire Blast Rank 1
		},
		[8] = {
			{118,200, rank=1}, -- Polymorph Rank 1
			{205,200, req=116, rank=2}, -- Frostbolt Rank 2
			{5143,200, rank=1}, -- Arcane Missiles Rank 1
		},
		[10] = {
			{122,400, rank=1}, -- Frost Nova Rank 1
			{5505,400, req=5504, rank=2}, -- Conjure Water Rank 2
			{7300,400, req=168, rank=2}, -- Frost Armor Rank 2
		},
		[12] = {
			{130,600}, -- Slow Fall
			{145,600, req=143}, -- Fireball Rank 3 (Talents: Improved Fireball, Improved Arcane Missiles)
			{597,600, req=587, rank=2}, -- Conjure Food Rank 2
			{604,600, optional=true, rank=1}, -- Dampen Magic Rank 1
		},
		[14] = {
			{837,900, req=205, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 3 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{1449,900, rank=1}, -- Arcane Explosion Rank 1
			{1460,900, req=1459, rank=2}, -- Arcane Intellect Rank 2
			{2137,900, req=2136, rank=2}, -- Fire Blast Rank 2
		},
		[16] = {
			{2120,1500, optional=true, rank=1}, -- Flamestrike Rank 1
			{2855,1500, optional=true}, -- Detect Magic
			{5144,1500, req=5143, optional="not talentknown(11237)"}, -- Arcane Missiles Rank 2 (Talents: Improved Arcane Missiles)
		},
		[18] = {
			{475,1800}, -- Remove Lesser Curse
			{1008,1800, optional=true, rank=1}, -- Amplify Magic Rank 1
			{3140,1800, req=145, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 4 (Talents: Improved Fireball, Improved Arcane Missiles)
		},
		[20] = {
			{10,2000, optional="not talentknown(11185)", rank=1}, -- Blizzard Rank 1
			{543,2000, optional=true, rank=1}, -- Fire Ward Rank 1
			{1463,2000, rank=1}, -- Mana Shield Rank 1
			{1953,2000}, -- Blink
			{3561,2000, faction="Alliance"}, -- Teleport: Stormwind
			{3562,2000, faction="Alliance"}, -- Teleport: Ironforge
			{3563,2000, faction="Horde"}, -- Teleport: Undercity
			{3567,2000, faction="Horde"}, -- Teleport: Orgrimmar
			{5506,2000, req=5505, rank=3}, -- Conjure Water Rank 3
			{7301,2000, req=7300, rank=3}, -- Frost Armor Rank 3
			{7322,2000, req=837, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 4 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{12051,2000}, -- Evocation
			{12824,2000, req=118, rank=2}, -- Polymorph Rank 2
		},
		[22] = {
			{990,3000, req=597, rank=3}, -- Conjure Food Rank 3
			{2138,3000, req=2137, rank=3}, -- Fire Blast Rank 3
			{2948,3000, optional="not talentknown(11069)"}, -- Scorch Rank 1 (Talents: Improved Fireball)
			{6143,3000, optional=true, rank=1}, -- Frost Ward Rank 1
			{8437,3000, req=1449, optional="not talentknown(11237)"}, -- Arcane Explosion Rank 2 (Talents: Improved Arcane Missiles)
		},
		[24] = {
			{2121,4000, req=2120, optional=true, rank=2}, -- Flamestrike Rank 2
			{2139,4000}, -- Counterspell
			{5145,4000, req=5144, optional="not talentknown(11237)"}, -- Arcane Missiles Rank 3 (Talents: Improved Arcane Missiles)
			{8400,4000, req=3140, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 5 (Talents: Improved Fireball, Improved Arcane Missiles)
			{8450,4000, req=604, optional=true, rank=2}, -- Dampen Magic Rank 2
			{12505,200, req=11366, talent=11366, rank=2}, -- Pyroblast Rank 2
		},
		[26] = {
			{120,5000, optional="not talentknown(11070)"}, -- Cone of Cold Rank 1 (Talents: Improved Frostbolt)
			{865,5000, req=122, optional=true, rank=2}, -- Frost Nova Rank 2
			{8406,5000, req=7322, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 5 (Talents: Improved Frostbolt, Improved Arcane Missiles)
		},
		[28] = {
			{759,7000}, -- Conjure Mana Agate
			{1461,7000, req=1460, rank=3}, -- Arcane Intellect Rank 3
			{6141,7000, req=10, optional="not talentknown(11185)"}, -- Blizzard Rank 2 (Talents: Improved Blizzard)
			{8444,7000, req=2948, optional="not talentknown(11069)"}, -- Scorch Rank 2 (Talents: Improved Fireball)
			{8494,7000, req=1463, rank=2}, -- Mana Shield Rank 2
		},
		[30] = {
			{3565,8000, faction="Alliance"}, -- Teleport: Darnassus
			{3566,8000, faction="Horde"}, -- Teleport: Thunder Bluff
			{6127,8000, req=5506, rank=4}, -- Conjure Water Rank 4
			{7302,8000, rank=1}, -- Ice Armor Rank 1
			{8401,8000, req=8400, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 6 (Talents: Improved Fireball, Improved Arcane Missiles)
			{8412,8000, req=2138, rank=4}, -- Fire Blast Rank 4
			{8438,8000, req=8437, optional="not talentknown(11237)"}, -- Arcane Explosion Rank 3 (Talents: Improved Arcane Missiles)
			{8455,8000, req=1008, optional=true, rank=2}, -- Amplify Magic Rank 2
			{8457,8000, req=543, optional=true, rank=2}, -- Fire Ward Rank 2
			{12522,400, req=12505, talent=11366, rank=3}, -- Pyroblast Rank 3
		},
		[32] = {
			{6129,10000, req=990, rank=4}, -- Conjure Food Rank 4
			{8407,10000, req=8406, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 6 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{8416,10000, req=5145, optional="not talentknown(11237)"}, -- Arcane Missiles Rank 4 (Talents: Improved Arcane Missiles)
			{8422,10000, req=2121, optional=true, rank=3}, -- Flamestrike Rank 3
			{8461,10000, req=6143, optional=true, rank=2}, -- Frost Ward Rank 2
		},
		[34] = {
			{6117,13000, rank=1}, -- Mage Armor Rank 1
			{8445,12000, req=8444, optional="not talentknown(11069)"}, -- Scorch Rank 3 (Talents: Improved Fireball)
			{8492,12000, req=120, optional="not talentknown(11070)"}, -- Cone of Cold Rank 2 (Talents: Improved Frostbolt)
		},
		[36] = {
			{8402,13000, req=8401, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 7 (Talents: Improved Fireball, Improved Arcane Missiles)
			{8427,13000, req=6141, optional="not talentknown(11185)"}, -- Blizzard Rank 3 (Talents: Improved Blizzard)
			{8451,15000, req=8450, optional=true, rank=3}, -- Dampen Magic Rank 3
			{8495,13000, req=8494, rank=3}, -- Mana Shield Rank 3
			{12523,650, req=12522, talent=11366, rank=4}, -- Pyroblast Rank 4
			{13018,650, req=11113, talent=11113, rank=2}, -- Blast Wave Rank 2
		},
		[38] = {
			{3552,14000, req=759}, -- Conjure Mana Jade
			{8408,14000, req=8407, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 7 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{8413,14000, req=8412, rank=5}, -- Fire Blast Rank 5
			{8439,14000, req=8438, optional="not talentknown(11237)"}, -- Arcane Explosion Rank 4 (Talents: Improved Arcane Missiles)
		},
		[40] = {
			{6131,15000, req=865, optional=true, rank=3}, -- Frost Nova Rank 3
			{7320,15000, req=7302, rank=2}, -- Ice Armor Rank 2
			{8417,15000, req=8416, optional="not talentknown(11237)"}, -- Arcane Missiles Rank 5 (Talents: Improved Arcane Missiles)
			{8423,15000, req=8422, optional=true, rank=4}, -- Flamestrike Rank 4
			{8446,15000, req=8445, optional="not talentknown(11069)"}, -- Scorch Rank 4 (Talents: Improved Fireball)
			{8458,15000, req=8457, optional=true, rank=3}, -- Fire Ward Rank 3
			{10059,13500, optional=true, faction="Alliance"}, -- Portal: Stormwind
			{10138,15000, req=6127, rank=5}, -- Conjure Water Rank 5
			{11416,13500, optional=true, faction="Alliance"}, -- Portal: Ironforge
			{11417,13500, optional=true, faction="Horde"}, -- Portal: Orgrimmar
			{11418,13500, optional=true, faction="Horde"}, -- Portal: Undercity
			{12825,15000, req=12824, rank=3}, -- Polymorph Rank 3
		},
		[42] = {
			{8462,18000, req=8461, optional=true, rank=3}, -- Frost Ward Rank 3
			{10144,22750, req=6129, rank=5}, -- Conjure Food Rank 5
			{10148,22750, req=8402, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 8 (Talents: Improved Fireball, Improved Arcane Missiles)
			{10156,22750, req=1461, rank=4}, -- Arcane Intellect Rank 4
			{10159,22750, req=8492, optional="not talentknown(11070)"}, -- Cone of Cold Rank 3 (Talents: Improved Frostbolt)
			{10169,18000, req=8455, optional=true, rank=3}, -- Amplify Magic Rank 3
			{12524,900, req=12523, talent=11366, rank=5}, -- Pyroblast Rank 5
		},
		[44] = {
			{10179,23000, req=8408, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 8 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{10185,23000, req=8427, optional="not talentknown(11185)"}, -- Blizzard Rank 4 (Talents: Improved Blizzard)
			{10191,23000, req=8495, optional="not talentknown(11426)"}, -- Mana Shield Rank 4 (Talents: Frost Barrier)
			{13019,1150, req=13018, talent=11113, rank=3}, -- Blast Wave Rank 3
		},
		[46] = {
			{10197,26000, req=8413, rank=6}, -- Fire Blast Rank 6
			{10201,26000, req=8439, optional="not talentknown(11237)"}, -- Arcane Explosion Rank 5 (Talents: Improved Arcane Missiles)
			{10205,26000, req=8446, optional="not talentknown(11069)"}, -- Scorch Rank 5 (Talents: Improved Fireball)
			{13031,6500, req=11426, talent=11426, rank=2}, -- Ice Barrier Rank 2
			{22782,28000, req=6117, rank=2}, -- Mage Armor Rank 2
		},
		[48] = {
			{10053,28000, req=3552}, -- Conjure Mana Citrine
			{10149,28000, req=10148, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 9 (Talents: Improved Fireball, Improved Arcane Missiles)
			{10173,28000, req=8451, optional=true, rank=4}, -- Dampen Magic Rank 4
			{10211,28000, req=8417, optional="not talentknown(11237)"}, -- Arcane Missiles Rank 6 (Talents: Improved Arcane Missiles)
			{10215,28000, req=8423, optional=true, rank=5}, -- Flamestrike Rank 5
			{12525,900, req=12524, talent=11366, rank=6}, -- Pyroblast Rank 6
		},
		[50] = {
			{10139,32000, req=10138, rank=6}, -- Conjure Water Rank 6
			{10160,32000, req=10159, optional="not talentknown(11070)"}, -- Cone of Cold Rank 4 (Talents: Improved Frostbolt)
			{10180,32000, req=10179, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 9 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{10219,32000, req=7320, rank=3}, -- Ice Armor Rank 3
			{10223,32000, req=8458, optional=true, rank=4}, -- Fire Ward Rank 4
			{11419,28800, optional=true, faction="Alliance"}, -- Portal: Darnassus
			{11420,28800, optional=true, faction="Horde"}, -- Portal: Thunder Bluff
		},
		[52] = {
			{10145,35000, req=10144, rank=6}, -- Conjure Food Rank 6
			{10177,35000, req=8462, optional=true, rank=4}, -- Frost Ward Rank 4
			{10186,35000, req=10185, optional="not talentknown(11185)"}, -- Blizzard Rank 5 (Talents: Improved Blizzard)
			{10192,35000, req=10191, optional="not talentknown(11426)"}, -- Mana Shield Rank 5 (Talents: Frost Barrier)
			{10206,35000, req=10205, optional="not talentknown(11069)"}, -- Scorch Rank 6 (Talents: Improved Fireball)
			{13020,1750, req=13019, talent=11113, rank=4}, -- Blast Wave Rank 4
			{13032,8750, req=13031, talent=11426, rank=3}, -- Ice Barrier Rank 3
		},
		[54] = {
			{10150,36000, req=10149, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 10 (Talents: Improved Fireball, Improved Arcane Missiles)
			{10170,36000, req=10169, optional=true, rank=4}, -- Amplify Magic Rank 4
			{10199,36000, req=10197, rank=7}, -- Fire Blast Rank 7
			{10202,36000, req=10201, optional="not talentknown(11237)"}, -- Arcane Explosion Rank 6 (Talents: Improved Arcane Missiles)
			{10230,36000, req=6131, optional=true, rank=4}, -- Frost Nova Rank 4
			{12526,1800, req=12525, talent=11366, rank=7}, -- Pyroblast Rank 7
		},
		[56] = {
			{10157,38000, req=10156, rank=5}, -- Arcane Intellect Rank 5
			{10181,38000, req=10180, optional="not talentanyknown(11070,11237)"}, -- Frostbolt Rank 10 (Talents: Improved Frostbolt, Improved Arcane Missiles)
			{10212,38000, req=10211, optional="not talentknown(11237)"}, -- Arcane Missiles Rank 7 (Talents: Improved Arcane Missiles)
			{10216,38000, req=10215, optional=true, rank=6}, -- Flamestrike Rank 6
		},
		[58] = {
			{10054,40000, req=10053}, -- Conjure Mana Ruby
			{10161,40000, req=10160, optional="not talentknown(11070)"}, -- Cone of Cold Rank 5 (Talents: Improved Frostbolt)
			{10207,40000, req=10206, optional="not talentknown(11069)"}, -- Scorch Rank 7 (Talents: Improved Fireball)
			{13033,9000, req=13032, talent=11426, rank=4}, -- Ice Barrier Rank 4
			{22783,40000, req=22782, rank=3}, -- Mage Armor Rank 3
		},
		[60] = {
			{10151,42000, req=10150, optional="not talentanyknown(11069,11237)"}, -- Fireball Rank 11 (Talents: Improved Fireball, Improved Arcane Missiles)
			{10174,42000, req=10173, optional=true, rank=5}, -- Dampen Magic Rank 5
			{10187,42000, req=10186, optional="not talentknown(11185)"}, -- Blizzard Rank 6 (Talents: Improved Blizzard)
			{10193,42000, req=10192, optional="not talentknown(11426)"}, -- Mana Shield Rank 6 (Talents: Frost Barrier)
			{10220,42000, req=10219, rank=4}, -- Ice Armor Rank 4
			{10225,42000, req=10223, optional=true, rank=5}, -- Fire Ward Rank 5
			{12826,42000, req=12825, rank=4}, -- Polymorph Rank 4
			{13021,2100, req=13020, talent=11113, rank=5}, -- Blast Wave Rank 5
			{18809,1890, req=12526, talent=11366, rank=8}, -- Pyroblast Rank 8
		},
	},
	PRIEST = {
		[1] = {
			{1243,10, rank=1}, -- Power Word: Fortitude Rank 1
		},
		[4] = {
			{589,100, rank=1}, -- Shadow Word: Pain Rank 1
			{2052,100, req=2050, rank=2}, -- Lesser Heal Rank 2
		},
		[6] = {
			{17,100, rank=1}, -- Power Word: Shield Rank 1
			{591,100, req=585, optional=true, rank=2}, -- Smite Rank 2
		},
		[8] = {
			{139,200, rank=1}, -- Renew Rank 1
			{586,200, optional=true, rank=1}, -- Fade Rank 1
		},
		[10] = {
			{594,300, req=589, rank=2}, -- Shadow Word: Pain Rank 2
			{2006,300, rank=1}, -- Resurrection Rank 1
			{2053,300, req=2052, rank=3}, -- Lesser Heal Rank 3
			{8092,300, rank=1}, -- Mind Blast Rank 1
		},
		[12] = {
			{588,800, rank=1}, -- Inner Fire Rank 1
			{592,800, req=17, rank=2}, -- Power Word: Shield Rank 2
			{1244,800, req=1243, rank=2}, -- Power Word: Fortitude Rank 2
		},
		[14] = {
			{528,1200}, -- Cure Disease
			{598,1200, req=591, optional=true, rank=3}, -- Smite Rank 3
			{6074,1200, req=139, rank=2}, -- Renew Rank 2
			{8122,1200, rank=1}, -- Psychic Scream Rank 1
		},
		[16] = {
			{2054,1600, rank=1}, -- Heal Rank 1
			{8102,1600, req=8092, rank=2}, -- Mind Blast Rank 2
		},
		[18] = {
			{527,2000, optional=true, rank=1}, -- Dispel Magic Rank 1
			{600,2000, req=592, rank=3}, -- Power Word: Shield Rank 3
			{970,2000, req=594, rank=3}, -- Shadow Word: Pain Rank 3
			{19236,100, race="Human", rank=2}, -- Desperate Prayer Rank 2
			{19236,100, race="Dwarf", rank=2}, -- Desperate Prayer Rank 2
			{19296,100, race="Night Elf", rank=2}, -- Starshards Rank 2
		},
		[20] = {
			{453,3000, optional=true, rank=1}, -- Mind Soothe Rank 1
			{2061,3000, optional=true, rank=1}, -- Flash Heal Rank 1
			{6075,3000, req=6074, rank=3}, -- Renew Rank 3
			{7128,3000, req=588, rank=2}, -- Inner Fire Rank 2
			{9484,3000, optional=true, rank=1}, -- Shackle Undead Rank 1
			{9578,3000, req=586, optional=true, rank=2}, -- Fade Rank 2
			{14914,3000, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 1 (Talents: Blackout, Shadow Focus)
			{19261,200, race="Undead", rank=2}, -- Touch of Weakness Rank 2
			{19281,150, race="Troll", rank=2}, -- Hex of Weakness Rank 2
		},
		[22] = {
			{984,4000, req=598, optional=true, rank=4}, -- Smite Rank 4
			{2010,4000, req=2006, optional=true, rank=2}, -- Resurrection Rank 2
			{2055,4000, req=2054, rank=2}, -- Heal Rank 2
			{2096,4000, optional=true, rank=1}, -- Mind Vision Rank 1
			{8103,4000, req=8102, rank=3}, -- Mind Blast Rank 3
		},
		[24] = {
			{1245,5000, req=1244, rank=3}, -- Power Word: Fortitude Rank 3
			{3747,5000, req=600, rank=4}, -- Power Word: Shield Rank 4
			{8129,5000, optional=true, rank=1}, -- Mana Burn Rank 1
			{15262,5000, req=14914, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 2 (Talents: Blackout, Shadow Focus)
		},
		[26] = {
			{992,6000, req=970, rank=4}, -- Shadow Word: Pain Rank 4
			{6076,6000, req=6075, rank=4}, -- Renew Rank 4
			{9472,6000, req=2061, optional=true, rank=2}, -- Flash Heal Rank 2
			{19238,300, race="Human", rank=3}, -- Desperate Prayer Rank 3
			{19238,300, race="Dwarf", rank=3}, -- Desperate Prayer Rank 3
			{19299,300, req=19296, race="Night Elf", rank=3}, -- Starshards Rank 3
		},
		[28] = {
			{6063,8000, req=2055, rank=3}, -- Heal Rank 3
			{8104,8000, req=8103, rank=4}, -- Mind Blast Rank 4
			{8124,8000, req=8122, optional=true, rank=2}, -- Psychic Scream Rank 2
			{15430,400, talent=15237, rank=2}, -- Holy Nova Rank 2
			{17311,400, talent=15407, rank=2}, -- Mind Flay Rank 2
			{19276,400, race="Undead", rank=2}, -- Devouring Plague Rank 2
			{19308,400, race="Troll", rank=2}, -- Shadowguard Rank 2
		},
		[30] = {
			{596,10000, optional=true, rank=1}, -- Prayer of Healing Rank 1
			{602,10000, req=7128, rank=3}, -- Inner Fire Rank 3
			{605,10000, optional=true, rank=1}, -- Mind Control Rank 1
			{976,10000, optional=true, rank=1}, -- Shadow Protection Rank 1
			{1004,10000, req=984, optional=true, rank=5}, -- Smite Rank 5
			{6065,10000, req=3747, rank=5}, -- Power Word: Shield Rank 5
			{9579,10000, req=9578, optional=true, rank=3}, -- Fade Rank 3
			{15263,10000, req=15262, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 3 (Talents: Blackout, Shadow Focus)
			{19262,500, race="Undead", rank=3}, -- Touch of Weakness Rank 3
			{19271,450, race="Human", rank=2}, -- Feedback Rank 2
			{19282,500, race="Troll", rank=3}, -- Hex of Weakness Rank 3
			{19289,500, race="Night Elf", rank=2}, -- Elune's Grace Rank 2
		},
		[32] = {
			{552,11000, optional=true}, -- Abolish Disease
			{6077,11000, req=6076, rank=5}, -- Renew Rank 5
			{8131,11000, req=8129, optional=true, rank=2}, -- Mana Burn Rank 2
			{9473,11000, req=9472, optional=true, rank=3}, -- Flash Heal Rank 3
		},
		[34] = {
			{1706,12000, optional=true}, -- Levitate
			{2767,12000, req=992, rank=5}, -- Shadow Word: Pain Rank 5
			{6064,12000, req=6063, rank=4}, -- Heal Rank 4
			{8105,12000, req=8104, rank=5}, -- Mind Blast Rank 5
			{10880,12000, req=2010, optional=true, rank=3}, -- Resurrection Rank 3
			{19240,600, race="Human", rank=4}, -- Desperate Prayer Rank 4
			{19240,600, race="Dwarf", rank=4}, -- Desperate Prayer Rank 4
			{19302,600, req=19299, race="Night Elf", rank=4}, -- Starshards Rank 4
		},
		[36] = {
			{988,14000, req=527, optional=true, rank=2}, -- Dispel Magic Rank 2
			{2791,14000, req=1245, rank=4}, -- Power Word: Fortitude Rank 4
			{6066,14000, req=6065, rank=6}, -- Power Word: Shield Rank 6
			{8192,14000, req=453, optional=true, rank=2}, -- Mind Soothe Rank 2
			{15264,14000, req=15263, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 4 (Talents: Blackout, Shadow Focus)
			{15431,700, req=15430, talent=15237, rank=3}, -- Holy Nova Rank 3
			{17312,700, req=17311, talent=15407, rank=3}, -- Mind Flay Rank 3
			{19277,700, race="Undead", rank=3}, -- Devouring Plague Rank 3
			{19309,700, race="Troll", rank=3}, -- Shadowguard Rank 3
		},
		[38] = {
			{6060,16000, req=1004, optional=true, rank=6}, -- Smite Rank 6
			{6078,16000, req=6077, rank=6}, -- Renew Rank 6
			{9474,16000, req=9473, optional=true, rank=4}, -- Flash Heal Rank 4
		},
		[40] = {
			{996,18000, req=596, optional=true, rank=2}, -- Prayer of Healing Rank 2
			{1006,18000, req=602, rank=4}, -- Inner Fire Rank 4
			{2060,18000, optional=true, rank=1}, -- Greater Heal Rank 1
			{8106,18000, req=8105, rank=6}, -- Mind Blast Rank 6
			{9485,18000, req=9484, optional=true, rank=2}, -- Shackle Undead Rank 2
			{9592,18000, req=9579, optional=true, rank=4}, -- Fade Rank 4
			{10874,18000, req=8131, optional=true, rank=3}, -- Mana Burn Rank 3
			{14818,900, talent=14752, rank=2}, -- Divine Spirit Rank 2
			{19264,900, race="Undead", rank=4}, -- Touch of Weakness Rank 4
			{19273,810, race="Human", rank=3}, -- Feedback Rank 3
			{19283,900, race="Troll", rank=4}, -- Hex of Weakness Rank 4
			{19291,900, req=19289, race="Night Elf", rank=3}, -- Elune's Grace Rank 3
		},
		[42] = {
			{10888,22000, req=8124, optional=true, rank=3}, -- Psychic Scream Rank 3
			{10892,22000, req=2767, rank=6}, -- Shadow Word: Pain Rank 6
			{10898,22000, req=6066, rank=7}, -- Power Word: Shield Rank 7
			{10957,22000, req=976, optional=true, rank=2}, -- Shadow Protection Rank 2
			{15265,22000, req=15264, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 5 (Talents: Blackout, Shadow Focus)
			{19241,1100, race="Human", rank=5}, -- Desperate Prayer Rank 5
			{19241,1100, race="Dwarf", rank=5}, -- Desperate Prayer Rank 5
			{19303,1100, req=19302, race="Night Elf", rank=5}, -- Starshards Rank 5
		},
		[44] = {
			{10909,24000, req=2096, optional=true, rank=2}, -- Mind Vision Rank 2
			{10911,24000, req=605, optional=true, rank=2}, -- Mind Control Rank 2
			{10915,24000, req=9474, optional=true, rank=5}, -- Flash Heal Rank 5
			{10927,24000, req=6078, rank=7}, -- Renew Rank 7
			{17313,1200, req=17312, talent=15407, rank=4}, -- Mind Flay Rank 4
			{19278,1200, race="Undead", rank=4}, -- Devouring Plague Rank 4
			{19310,1000, race="Troll", rank=4}, -- Shadowguard Rank 4
			{27799,1200, req=15431, talent=15237, rank=4}, -- Holy Nova Rank 4
		},
		[46] = {
			{10881,26000, req=10880, optional=true, rank=4}, -- Resurrection Rank 4
			{10933,26000, req=6060, optional=true, rank=7}, -- Smite Rank 7
			{10945,26000, req=8106, rank=7}, -- Mind Blast Rank 7
			{10963,26000, req=2060, optional=true, rank=2}, -- Greater Heal Rank 2
		},
		[48] = {
			{10875,28000, req=10874, optional=true, rank=4}, -- Mana Burn Rank 4
			{10899,28000, req=10898, rank=8}, -- Power Word: Shield Rank 8
			{10937,28000, req=2791, rank=5}, -- Power Word: Fortitude Rank 5
			{15266,28000, req=15265, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 6 (Talents: Blackout, Shadow Focus)
		},
		[50] = {
			{10893,30000, req=10892, rank=7}, -- Shadow Word: Pain Rank 7
			{10916,30000, req=10915, optional=true, rank=6}, -- Flash Heal Rank 6
			{10928,30000, req=10927, rank=8}, -- Renew Rank 8
			{10941,30000, req=9592, optional=true, rank=5}, -- Fade Rank 5
			{10951,30000, req=1006, rank=5}, -- Inner Fire Rank 5
			{10960,30000, req=996, optional=true, rank=3}, -- Prayer of Healing Rank 3
			{14819,1500, req=14818, talent=14752, rank=3}, -- Divine Spirit Rank 3
			{19242,1500, race="Human", rank=6}, -- Desperate Prayer Rank 6
			{19242,1500, race="Dwarf", rank=6}, -- Desperate Prayer Rank 6
			{19265,1500, race="Undead", rank=5}, -- Touch of Weakness Rank 5
			{19284,1500, race="Troll", rank=5}, -- Hex of Weakness Rank 5
			{19292,1500, req=19291, race="Night Elf", rank=4}, -- Elune's Grace Rank 4
			{19304,1500, req=19303, race="Night Elf", rank=6}, -- Starshards Rank 6
			{27870,1200, talent=724, rank=2}, -- Lightwell Rank 2
		},
		[52] = {
			{10946,38000, req=10945, rank=8}, -- Mind Blast Rank 8
			{10953,38000, req=8192, optional=true, rank=3}, -- Mind Soothe Rank 3
			{10964,38000, req=10963, optional=true, rank=3}, -- Greater Heal Rank 3
			{17314,1900, req=17313, talent=15407, rank=5}, -- Mind Flay Rank 5
			{19279,1900, race="Undead", rank=5}, -- Devouring Plague Rank 5
			{19311,1200, race="Troll", rank=5}, -- Shadowguard Rank 5
			{27800,1900, req=27799, talent=15237, rank=5}, -- Holy Nova Rank 5
		},
		[54] = {
			{10900,40000, req=10899, rank=9}, -- Power Word: Shield Rank 9
			{10934,40000, req=10933, optional=true, rank=8}, -- Smite Rank 8
			{15267,40000, req=15266, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 7 (Talents: Blackout, Shadow Focus)
		},
		[56] = {
			{10876,42000, req=10875, optional=true, rank=5}, -- Mana Burn Rank 5
			{10890,42000, req=10888, optional=true, rank=4}, -- Psychic Scream Rank 4
			{10917,42000, req=10916, optional=true, rank=7}, -- Flash Heal Rank 7
			{10929,42000, req=10928, rank=9}, -- Renew Rank 9
			{10958,42000, req=10957, optional=true, rank=3}, -- Shadow Protection Rank 3
		},
		[58] = {
			{10894,44000, req=10893, rank=8}, -- Shadow Word: Pain Rank 8
			{10912,44000, req=10911, optional=true, rank=3}, -- Mind Control Rank 3
			{10947,44000, req=10946, rank=9}, -- Mind Blast Rank 9
			{10965,44000, req=10964, optional=true, rank=4}, -- Greater Heal Rank 4
			{19243,2200, race="Human", rank=7}, -- Desperate Prayer Rank 7
			{19243,2200, race="Dwarf", rank=7}, -- Desperate Prayer Rank 7
			{19305,2200, race="Night Elf", req=19304, rank=7}, -- Starshards Rank 7
			{20770,44000, req=10881, optional=true, rank=5}, -- Resurrection Rank 5
		},
		[60] = {
			{10901,46000, req=10900, rank=10}, -- Power Word: Shield Rank 10
			{10938,46000, req=10937, rank=6}, -- Power Word: Fortitude Rank 6
			{10942,46000, req=10941, optional=true, rank=6}, -- Fade Rank 6
			{10952,46000, req=10951, rank=6}, -- Inner Fire Rank 6
			{10955,46000, req=9485, optional=true, rank=3}, -- Shackle Undead Rank 3
			{10961,46000, req=10960, optional=true, rank=4}, -- Prayer of Healing Rank 4
			{15261,46000, req=15267, optional="talentanyknown(15268,15260)"}, -- Holy Fire Rank 8 (Talents: Blackout, Shadow Focus)
			{18807,2300, req=17314, talent=15407, rank=6}, -- Mind Flay Rank 6
			{19266,2070, race="Undead", rank=6}, -- Touch of Weakness Rank 6
			{19280,2300, race="Undead", rank=6}, -- Devouring Plague Rank 6
			{19285,2300, race="Troll", rank=6}, -- Hex of Weakness Rank 6
			{19293,2070, req=19292, race="Night Elf", rank=5}, -- Elune's Grace Rank 5
			{19312,2300, race="Troll", rank=6}, -- Shadowguard Rank 6
			{27681,2300, req=27841, rank=1}, -- Prayer of Spirit Rank 1
			{27801,2300, req=27800, talent=15237, rank=6}, -- Holy Nova Rank 6
			{27841,2300, req=14819, talent=14752, rank=4}, -- Divine Spirit Rank 4
			{27871,1500, req=27870, talent=724, rank=3}, -- Lightwell Rank 3
		},
	},
	WARLOCK = {
		[1] = {
			{348,10, rank=1}, -- Immolate Rank 1
		},
		[4] = {
			{172,100, rank=1}, -- Corruption Rank 1
			{702,100, optional=true, rank=1}, -- Curse of Weakness Rank 1
		},
		[6] = {
			{695,100, req=686, rank=2}, -- Shadow Bolt Rank 2
			{1454,100, rank=1}, -- Life Tap Rank 1
		},
		[8] = {
			{980,200, rank=1}, -- Curse of Agony Rank 1
			{5782,200, rank=1}, -- Fear Rank 1
		},
		[10] = {
			{696,300, req=687, rank=2}, -- Demon Skin Rank 2
			{707,300, req=348, rank=2}, -- Immolate Rank 2
			{1120,300, rank=1}, -- Drain Soul Rank 1
			{6201,300, req=1120}, -- Create Healthstone (Minor)
		},
		[12] = {
			{705,600, req=695, rank=3}, -- Shadow Bolt Rank 3
			{755,600, rank=1}, -- Health Funnel Rank 1
			{1108,600, req=702, optional=true, rank=2}, -- Curse of Weakness Rank 2
		},
		[14] = {
			{689,900, rank=1}, -- Drain Life Rank 1
			{704,900, optional=true, rank=1}, -- Curse of Recklessness Rank 1
			{6222,900, req=172, rank=2}, -- Corruption Rank 2
		},
		[16] = {
			{1455,1200, req=1454, rank=2}, -- Life Tap Rank 2
			{5697,1200}, -- Unending Breath
		},
		[18] = {
			{693,1500, req=1120}, -- Create Soulstone (Minor)
			{1014,1500, req=980, rank=2}, -- Curse of Agony Rank 2
			{5676,1500, optional=true, rank=1}, -- Searing Pain Rank 1
		},
		[20] = {
			{698,2000, optional=true}, -- Ritual of Summoning
			{706,2000, rank=1}, -- Demon Armor Rank 1
			{1088,2000, req=705, rank=4}, -- Shadow Bolt Rank 4
			{1094,2000, req=707, rank=3}, -- Immolate Rank 3
			{3698,2000, req=755, rank=2}, -- Health Funnel Rank 2
			{5740,2000, optional=true, rank=1}, -- Rain of Fire Rank 1
		},
		[22] = {
			{126,2500, optional=true}, -- Eye of Kilrogg Summon
			{699,2500, req=689, rank=2}, -- Drain Life Rank 2
			{6202,2500, req=6201}, -- Create Healthstone (Lesser)
			{6205,2500, req=1108, optional=true, rank=3}, -- Curse of Weakness Rank 3
		},
		[24] = {
			{5138,3000, optional=true, rank=1}, -- Drain Mana Rank 1
			{5500,3000, optional=true}, -- Sense Demons
			{6223,3000, req=6222, rank=3}, -- Corruption Rank 3
			{8288,3000, req=1120, optional=true, rank=2}, -- Drain Soul Rank 2
			{18867,150, talent=17877, rank=2}, -- Shadowburn Rank 2
		},
		[26] = {
			{132,4000, optional=true}, -- Detect Lesser Invisibility
			{1456,4000, req=1455, rank=3}, -- Life Tap Rank 3
			{1714,4000, optional=true, rank=1}, -- Curse of Tongues Rank 1
			{17919,4000, req=5676, optional=true, rank=2}, -- Searing Pain Rank 2
		},
		[28] = {
			{710,5000, optional=true, rank=1}, -- Banish Rank 1
			{1106,5000, req=1088, rank=5}, -- Shadow Bolt Rank 5
			{3699,5000, req=3698, rank=3}, -- Health Funnel Rank 3
			{6217,5000, req=1014, rank=3}, -- Curse of Agony Rank 3
			{6366,5000, optional=true}, -- Create Firestone (Lesser)
			{7658,5000, req=704, optional=true, rank=2}, -- Curse of Recklessness Rank 2
		},
		[30] = {
			{709,6000, req=699, rank=3}, -- Drain Life Rank 3
			{1086,6000, req=706, rank=2}, -- Demon Armor Rank 2
			{1098,6000, optional=true, rank=1}, -- Enslave Demon Rank 1
			{1949,6000, optional=true, rank=1}, -- Hellfire Rank 1
			{2941,6000, req=1094, rank=4}, -- Immolate Rank 4
			{20752,6000, req=693, optional=true}, -- Create Soulstone (Lesser)
		},
		[32] = {
			{1490,7000, optional=true, rank=1}, -- Curse of the Elements Rank 1
			{6213,7000, req=5782, rank=2}, -- Fear Rank 2
			{6229,7000, optional=true, rank=1}, -- Shadow Ward Rank 1
			{7646,7000, req=6205, optional=true, rank=4}, -- Curse of Weakness Rank 4
			{18868,350, req=18867, talent=17877, rank=3}, -- Shadowburn Rank 3
		},
		[34] = {
			{5699,8000, req=6202}, -- Create Healthstone
			{6219,8000, req=5740, optional=true, rank=2}, -- Rain of Fire Rank 2
			{6226,8000, req=5138, optional=true, rank=2}, -- Drain Mana Rank 2
			{7648,8000, req=6223, rank=4}, -- Corruption Rank 4
			{17920,8000, req=17919, optional=true, rank=3}, -- Searing Pain Rank 3
		},
		[36] = {
			{2362,9000, req=1120, optional=true}, -- Create Spellstone
			{3700,9000, req=3699, rank=4}, -- Health Funnel Rank 4
			{7641,9000, req=1106, rank=6}, -- Shadow Bolt Rank 6
			{11687,9000, req=1456, rank=4}, -- Life Tap Rank 4
			{17951,9000, req=6366, optional=true}, -- Create Firestone
		},
		[38] = {
			{2970,10000, req=132, optional=true}, -- Detect Invisibility
			{7651,10000, req=709, rank=4}, -- Drain Life Rank 4
			{8289,10000, req=8288, optional=true, rank=3}, -- Drain Soul Rank 3
			{11711,10000, req=6217, rank=4}, -- Curse of Agony Rank 4
			{18879,500, talent=18265, rank=2}, -- Siphon Life Rank 2
		},
		[40] = {
			{5484,11000, optional=true, rank=1}, -- Howl of Terror Rank 1
			{11665,11000, req=2941, rank=5}, -- Immolate Rank 5
			{11733,11000, req=1086, rank=3}, -- Demon Armor Rank 3
			{18869,550, req=18868, talent=17877, rank=4}, -- Shadowburn Rank 4
			{20755,11000, req=20752, optional=true}, -- Create Soulstone
		},
		[42] = {
			{6789,11000, rank=1}, -- Death Coil Rank 1
			{7659,11000, req=7658, optional=true, rank=3}, -- Curse of Recklessness Rank 3
			{11683,9900, req=1949, optional=true, rank=2}, -- Hellfire Rank 2
			{11707,11000, req=7646, optional=true, rank=5}, -- Curse of Weakness Rank 5
			{11739,11000, req=6229, optional=true, rank=2}, -- Shadow Ward Rank 2
			{17921,11000, req=17920, optional=true, rank=4}, -- Searing Pain Rank 4
		},
		[44] = {
			{11659,12000, req=7641, rank=7}, -- Shadow Bolt Rank 7
			{11671,12000, req=7648, rank=5}, -- Corruption Rank 5
			{11693,12000, req=3700, rank=5}, -- Health Funnel Rank 5
			{11703,12000, req=6226, optional=true, rank=3}, -- Drain Mana Rank 3
			{11725,12000, req=1098, optional=true, rank=2}, -- Enslave Demon Rank 2
			{17862,12000, optional=true, rank=1}, -- Curse of Shadow Rank 1
		},
		[46] = {
			{11677,13000, req=6219, optional=true, rank=3}, -- Rain of Fire Rank 3
			{11688,13000, req=11687, rank=5}, -- Life Tap Rank 5
			{11699,13000, req=7651, rank=5}, -- Drain Life Rank 5
			{11721,13000, req=1490, optional=true, rank=2}, -- Curse of the Elements Rank 2
			{11729,13000, req=5699}, -- Create Healthstone (Greater)
			{17952,13000, req=17951, optional=true}, -- Create Firestone (Greater)
		},
		[48] = {
			{6353,14000, optional=true, rank=1}, -- Soul Fire Rank 1
			{11712,14000, req=11711, rank=5}, -- Curse of Agony Rank 5
			{17727,14000, req=2362, optional=true}, -- Create Spellstone (Greater)
			{18647,13000, req=710, optional=true, rank=2}, -- Banish Rank 2
			{18870,700, req=18869, talent=17877, rank=5}, -- Shadowburn Rank 5
			{18880,700, req=18879, talent=18265, rank=3}, -- Siphon Life Rank 3
			{18930,700, talent=17962, rank=2}, -- Conflagrate Rank 2
		},
		[50] = {
			{11667,15000, req=11665, rank=6}, -- Immolate Rank 6
			{11719,15000, req=1714, optional=true, rank=2}, -- Curse of Tongues Rank 2
			{11734,15000, req=11733, rank=4}, -- Demon Armor Rank 4
			{11743,15000, req=2970, optional=true}, -- Detect Greater Invisibility
			{17922,15000, req=17921, optional=true, rank=5}, -- Searing Pain Rank 5
			{17925,15000, req=6789, rank=2}, -- Death Coil Rank 2
			{18937,750, talent=18220, rank=2}, -- Dark Pact Rank 2
			{20756,15000, req=20755, optional=true}, -- Create Soulstone (Greater)
		},
		[52] = {
			{11660,18000, req=11659, rank=8}, -- Shadow Bolt Rank 8
			{11675,18000, req=8289, optional=true, rank=4}, -- Drain Soul Rank 4
			{11694,18000, req=11693, rank=6}, -- Health Funnel Rank 6
			{11708,18000, req=11707, optional=true, rank=6}, -- Curse of Weakness Rank 6
			{11740,18000, req=11739, optional=true, rank=3}, -- Shadow Ward Rank 3
		},
		[54] = {
			{11672,20000, req=11671, rank=6}, -- Corruption Rank 6
			{11684,18000, req=11683, optional=true, rank=3}, -- Hellfire Rank 3
			{11700,20000, req=11699, rank=6}, -- Drain Life Rank 6
			{11704,20000, req=11703, optional=true, rank=4}, -- Drain Mana Rank 4
			{17928,20000, req=5484, optional=true, rank=2}, -- Howl of Terror Rank 2
			{18931,1000, req=18930, talent=17962, rank=3}, -- Conflagrate Rank 3
		},
		[56] = {
			{6215,22000, req=6213, rank=3}, -- Fear Rank 3
			{11689,22000, req=11688, rank=6}, -- Life Tap Rank 6
			{11717,22000, req=7659, optional=true, rank=4}, -- Curse of Recklessness Rank 4
			{17924,22000, req=6353, optional=true, rank=2}, -- Soul Fire Rank 2
			{17937,22000, req=17862, optional=true, rank=2}, -- Curse of Shadow Rank 2
			{17953,22000, req=17952, optional=true}, -- Create Firestone (Major)
			{18871,22000, req=18870, talent=17877, rank=6}, -- Shadowburn Rank 6
		},
		[58] = {
			{11678,24000, req=11677, optional=true, rank=4}, -- Rain of Fire Rank 4
			{11713,24000, req=11712, rank=6}, -- Curse of Agony Rank 6
			{11726,24000, req=11725, optional=true, rank=3}, -- Enslave Demon Rank 3
			{11730,24000, req=11729}, -- Create Healthstone (Major)
			{17923,24000, req=17922, optional=true, rank=6}, -- Searing Pain Rank 6
			{17926,24000, req=17925, rank=3}, -- Death Coil Rank 3
			{18881,1200, req=18880, talent=18265, rank=4}, -- Siphon Life Rank 4
		},
		[60] = {
			{603,26000, optional=true}, -- Curse of Doom
			{11661,26000, req=11660, rank=9}, -- Shadow Bolt Rank 9
			{11668,26000, req=11667, rank=7}, -- Immolate Rank 7
			{11695,26000, req=11694, rank=7}, -- Health Funnel Rank 7
			{11722,26000, req=11721, optional=true, rank=3}, -- Curse of the Elements Rank 3
			{11735,26000, req=11734, rank=5}, -- Demon Armor Rank 5
			{17728,26000, req=17727, optional=true}, -- Create Spellstone (Major)
			{18932,1300, req=18931, talent=17962, rank=4}, -- Conflagrate Rank 4
			{18938,1300, req=18937, talent=18220, rank=3}, -- Dark Pact Rank 3
			{20757,26000, req=20756, optional=true}, -- Create Soulstone (Major)
		},
	},
	DRUID = {
		[1] = {
			{1126,10, rank=1}, -- Mark of the Wild Rank 1
		},
		[4] = {
			{774,100, rank=1}, -- Rejuvenation Rank 1
			{8921,100}, -- Moonfire Rank 1 (Talents: Ferocity, Feral Aggression)
		},
		[6] = {
			{467,100, optional=true, rank=1}, -- Thorns Rank 1
			{5177,100, req=5176}, -- Wrath Rank 2 (Talents: Ferocity, Feral Aggression)
		},
		[8] = {
			{339,200}, -- Entangling Roots Rank 1 (Talents: Ferocity, Feral Aggression)
			{5186,200, req=5185}, -- Healing Touch Rank 2 (Talents: Ferocity, Feral Aggression)
		},
		[10] = {
			{99,300, req=5487}, -- Demoralizing Roar Rank 1 (Talents: Ferocity, Feral Aggression)
			{1058,300, req=774, rank=2}, -- Rejuvenation Rank 2
			{5232,300, req=1126, rank=2}, -- Mark of the Wild Rank 2
			{8924,300, req=8921}, -- Moonfire Rank 2 (Talents: Ferocity, Feral Aggression)
		},
		[12] = {
			{5229,800, req=5487, optional="not talentanyknown(16934,16858)"}, -- Enrage (Talents: Ferocity, Feral Aggression)
			{8936,800, rank=1}, -- Regrowth Rank 1
		},
		[14] = {
			{782,900, req=467, optional=true, rank=2}, -- Thorns Rank 2
			{5178,900, req=5177, optional="talentanyknown(16934,16858)"}, -- Wrath Rank 3 (Talents: Ferocity, Feral Aggression)
			{5187,900, req=5186, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 3 (Talents: Ferocity, Feral Aggression)
			{5211,900, req=5487, optional="not talentanyknown(16934,16858)"}, -- Bash Rank 1 (Talents: Ferocity, Feral Aggression)
		},
		[16] = {
			{779,1800, req=5487, optional="not talentanyknown(16934,16858)"}, -- Swipe Rank 1 (Talents: Ferocity, Feral Aggression)
			{1430,1800, req=1058, rank=3}, -- Rejuvenation Rank 3
			{8925,1800, req=8924, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 3 (Talents: Ferocity, Feral Aggression)
		},
		[18] = {
			{770,1900, optional="talentanyknown(16934,16858)"}, -- Faerie Fire Rank 1 (Talents: Ferocity, Feral Aggression)
			{1062,1900, req=339, optional="talentanyknown(16934,16858)"}, -- Entangling Roots Rank 2 (Talents: Ferocity, Feral Aggression)
			{2637,1900, optional=true, rank=1}, -- Hibernate Rank 1
			{6808,1900, req=6807, optional="not talentanyknown(16934,16858)"}, -- Maul Rank 2 (Talents: Ferocity, Feral Aggression)
			{8938,1900, req=8936, rank=2}, -- Regrowth Rank 2
			{16810,95, req=16689, talent=16689, rank=2}, -- Nature's Grasp Rank 2
		},
		[20] = {
			{768,2000}, -- Cat Form Shapeshift
			{1079,2000, req=768, optional="not talentanyknown(16934,16858)"}, -- Rip Rank 1 (Talents: Ferocity, Feral Aggression)
			{1082,2000, req=768, optional="not talentanyknown(16934,16858)"}, -- Claw Rank 1 (Talents: Ferocity, Feral Aggression)
			{1735,2000, req=99, optional="not talentanyknown(16934,16858)"}, -- Demoralizing Roar Rank 2 (Talents: Ferocity, Feral Aggression)
			{2912,2000, optional="talentanyknown(16934,16858)"}, -- Starfire Rank 1 (Talents: Ferocity, Feral Aggression)
			{5188,2000, req=5187, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 4 (Talents: Ferocity, Feral Aggression)
			{5215,2000, req=768, rank=1}, -- Prowl Rank 1
			{6756,2000, req=5232, rank=3}, -- Mark of the Wild Rank 3
			{20484,2000, rank=1}, -- Rebirth Rank 1
		},
		[22] = {
			{2090,3000, req=1430, rank=4}, -- Rejuvenation Rank 4
			{2908,3000, optional=true, rank=1}, -- Soothe Animal Rank 1
			{5179,3000, req=5178, optional="talentanyknown(16934,16858)"}, -- Wrath Rank 4 (Talents: Ferocity, Feral Aggression)
			{5221,3000, req=768, optional="not talentanyknown(16934,16858)"}, -- Shred Rank 1 (Talents: Ferocity, Feral Aggression)
			{8926,3000, req=8925, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 4 (Talents: Ferocity, Feral Aggression)
		},
		[24] = {
			{780,4000, req=779, optional="not talentanyknown(16934,16858)"}, -- Swipe Rank 2 (Talents: Ferocity, Feral Aggression)
			{1075,4000, req=782, optional=true, rank=3}, -- Thorns Rank 3
			{1822,4000, req=768, optional="not talentanyknown(16934,16858)"}, -- Rake Rank 1 (Talents: Ferocity, Feral Aggression)
			{2782,4000}, -- Remove Curse
			{5217,4000, req=768, optional="not talentanyknown(16934,16858)"}, -- Tiger's Fury Rank 1 (Talents: Ferocity, Feral Aggression)
			{8939,4000, req=8938, rank=3}, -- Regrowth Rank 3
		},
		[26] = {
			{1850,4500, req=768, rank=1}, -- Dash Rank 1
			{2893,4500}, -- Abolish Poison
			{5189,4500, req=5188, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 5 (Talents: Ferocity, Feral Aggression)
			{6809,4500, req=6808, optional="not talentanyknown(16934,16858)"}, -- Maul Rank 3 (Talents: Ferocity, Feral Aggression)
			{8949,4500, req=2912, optional="talentanyknown(16934,16858)"}, -- Starfire Rank 2 (Talents: Ferocity, Feral Aggression)
		},
		[28] = {
			{2091,5000, req=2090, rank=5}, -- Rejuvenation Rank 5
			{3029,5000, req=1082, optional="not talentanyknown(16934,16858)"}, -- Claw Rank 2 (Talents: Ferocity, Feral Aggression)
			{5195,5000, req=1062, optional="talentanyknown(16934,16858)"}, -- Entangling Roots Rank 3 (Talents: Ferocity, Feral Aggression)
			{5209,5000, req=5487, optional="not talentanyknown(16934,16858)"}, -- Challenging Roar (Talents: Ferocity, Feral Aggression)
			{8927,5000, req=8926, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 5 (Talents: Ferocity, Feral Aggression)
			{8998,5000, req=768, optional=true, rank=1}, -- Cower Rank 1
			{9492,5000, req=1079, optional="not talentanyknown(16934,16858)"}, -- Rip Rank 2 (Talents: Ferocity, Feral Aggression)
			{16811,250, req=16810, talent=16689, rank=3}, -- Nature's Grasp Rank 3
		},
		[30] = {
			{740,6000, optional=true, rank=1}, -- Tranquility Rank 1
			{778,6000, req=770, optional="talentanyknown(16934,16858)"}, -- Faerie Fire Rank 2 (Talents: Ferocity, Feral Aggression)
			{783,6000}, -- Travel Form Shapeshift
			{5180,6000, req=5179, optional="talentanyknown(16934,16858)"}, -- Wrath Rank 5 (Talents: Ferocity, Feral Aggression)
			{5234,6000, req=6756, rank=4}, -- Mark of the Wild Rank 4
			{6798,6000, req=5211, optional="not talentanyknown(16934,16858)"}, -- Bash Rank 2 (Talents: Ferocity, Feral Aggression)
			{6800,6000, req=5221, optional="not talentanyknown(16934,16858)"}, -- Shred Rank 2 (Talents: Ferocity, Feral Aggression)
			{8940,6000, req=8939, rank=4}, -- Regrowth Rank 4
			{17390,300, req=16857, talent=16857, rank=2}, -- Faerie Fire (Feral) Rank 2
			{20739,6000, req=20484, optional=true, rank=2}, -- Rebirth Rank 2
			{24974,300, req=5570, talent=5570, rank=2}, -- Insect Swarm Rank 2
		},
		[32] = {
			{5225,8000, optional=true}, -- Track Humanoids
			{6778,8000, req=5189, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 6 (Talents: Ferocity, Feral Aggression)
			{6785,8000, req=768, optional="not talentanyknown(16934,16858)"}, -- Ravage Rank 1 (Talents: Ferocity, Feral Aggression)
			{9490,8000, req=1735, optional="not talentanyknown(16934,16858)"}, -- Demoralizing Roar Rank 3 (Talents: Ferocity, Feral Aggression)
			{22568,8000, req=768, optional="not talentanyknown(16934,16858)"}, -- Ferocious Bite Rank 1 (Talents: Ferocity, Feral Aggression)
		},
		[34] = {
			{769,10000, req=780, optional="not talentanyknown(16934,16858)"}, -- Swipe Rank 3 (Talents: Ferocity, Feral Aggression)
			{1823,10000, req=1822, optional="not talentanyknown(16934,16858)"}, -- Rake Rank 2 (Talents: Ferocity, Feral Aggression)
			{3627,10000, req=2091, rank=6}, -- Rejuvenation Rank 6
			{8914,10000, req=1075, optional=true, rank=4}, -- Thorns Rank 4
			{8928,10000, req=8927, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 6 (Talents: Ferocity, Feral Aggression)
			{8950,10000, req=8949, optional="talentanyknown(16934,16858)"}, -- Starfire Rank 3 (Talents: Ferocity, Feral Aggression)
			{8972,10000, req=6809, optional="not talentanyknown(16934,16858)"}, -- Maul Rank 4 (Talents: Ferocity, Feral Aggression)
		},
		[36] = {
			{6793,11000, req=5217, optional="not talentanyknown(16934,16858)"}, -- Tiger's Fury Rank 2 (Talents: Ferocity, Feral Aggression)
			{8941,11000, req=8940, rank=5}, -- Regrowth Rank 5
			{9005,11000, req=768, optional=true, rank=1}, -- Pounce Rank 1
			{9493,11000, req=9492, optional="not talentanyknown(16934,16858)"}, -- Rip Rank 3 (Talents: Ferocity, Feral Aggression)
			{22842,11000, req=5487, optional="not talentanyknown(16934,16858)"}, -- Frenzied Regeneration Rank 1 (Talents: Ferocity, Feral Aggression)
		},
		[38] = {
			{5196,12000, req=5195, optional="talentanyknown(16934,16858)"}, -- Entangling Roots Rank 4 (Talents: Ferocity, Feral Aggression)
			{5201,12000, req=3029, optional="not talentanyknown(16934,16858)"}, -- Claw Rank 3 (Talents: Ferocity, Feral Aggression)
			{6780,12000, req=5180, optional="talentanyknown(16934,16858)"}, -- Wrath Rank 6 (Talents: Ferocity, Feral Aggression)
			{8903,12000, req=6778, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 7 (Talents: Ferocity, Feral Aggression)
			{8955,12000, req=2908, optional=true, rank=2}, -- Soothe Animal Rank 2
			{8992,12000, req=6800, optional="not talentanyknown(16934,16858)"}, -- Shred Rank 3 (Talents: Ferocity, Feral Aggression)
			{16812,600, req=16811, talent=16689, rank=4}, -- Nature's Grasp Rank 4
			{18657,12000, req=2637, optional=true, rank=2}, -- Hibernate Rank 2
		},
		[40] = {
			{6783,14000, req=5215, rank=2}, -- Prowl Rank 2
			{8907,14000, req=5234, rank=5}, -- Mark of the Wild Rank 5
			{8910,14000, req=3627, rank=7}, -- Rejuvenation Rank 7
			{8918,14000, req=740, optional=true, rank=2}, -- Tranquility Rank 2
			{8929,14000, req=8928, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 7 (Talents: Ferocity, Feral Aggression)
			{9000,14000, req=8998, optional=true, rank=2}, -- Cower Rank 2
			{9634,14000, req=5487}, -- Dire Bear Form Shapeshift
			{16914,14000, optional=true, rank=1}, -- Hurricane Rank 1
			{20719,14000, req=768}, -- Feline Grace Passive
			{20742,14000, req=20739, optional=true, rank=3}, -- Rebirth Rank 3
			{22827,14000, req=22568, optional="not talentanyknown(16934,16858)"}, -- Ferocious Bite Rank 2 (Talents: Ferocity, Feral Aggression)
			{24975,700, req=24974, talent=5570, rank=3}, -- Insect Swarm Rank 3
			{29166,14000}, -- Innervate
		},
		[42] = {
			{6787,16000, req=6785, optional="not talentanyknown(16934,16858)"}, -- Ravage Rank 2 (Talents: Ferocity, Feral Aggression)
			{8951,16000, req=8950, optional="talentanyknown(16934,16858)"}, -- Starfire Rank 4 (Talents: Ferocity, Feral Aggression)
			{9745,16000, req=8972, optional="not talentanyknown(16934,16858)"}, -- Maul Rank 5 (Talents: Ferocity, Feral Aggression)
			{9747,16000, req=9490, optional="not talentanyknown(16934,16858)"}, -- Demoralizing Roar Rank 4 (Talents: Ferocity, Feral Aggression)
			{9749,16000, req=778, optional="talentanyknown(16934,16858)"}, -- Faerie Fire Rank 3 (Talents: Ferocity, Feral Aggression)
			{9750,16000, req=8941, rank=6}, -- Regrowth Rank 6
			{17391,800, req=17390, talent=16857, rank=3}, -- Faerie Fire (Feral) Rank 3
		},
		[44] = {
			{1824,18000, req=1823, optional="not talentanyknown(16934,16858)"}, -- Rake Rank 3 (Talents: Ferocity, Feral Aggression)
			{9752,18000, req=9493, optional="not talentanyknown(16934,16858)"}, -- Rip Rank 4 (Talents: Ferocity, Feral Aggression)
			{9754,18000, req=769, optional="not talentanyknown(16934,16858)"}, -- Swipe Rank 4 (Talents: Ferocity, Feral Aggression)
			{9756,18000, req=8914, optional=true, rank=5}, -- Thorns Rank 5
			{9758,18000, req=8903, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 8 (Talents: Ferocity, Feral Aggression)
			{22812,18000}, -- Barkskin
		},
		[46] = {
			{8905,20000, req=6780, optional="talentanyknown(16934,16858)"}, -- Wrath Rank 7 (Talents: Ferocity, Feral Aggression)
			{8983,20000, req=6798, optional="not talentanyknown(16934,16858)"}, -- Bash Rank 3 (Talents: Ferocity, Feral Aggression)
			{9821,20000, req=1850, rank=2}, -- Dash Rank 2
			{9823,20000, req=9005, optional=true, rank=2}, -- Pounce Rank 2
			{9829,20000, req=8992, optional="not talentanyknown(16934,16858)"}, -- Shred Rank 4 (Talents: Ferocity, Feral Aggression)
			{9833,20000, req=8929, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 8 (Talents: Ferocity, Feral Aggression)
			{9839,20000, req=8910, rank=8}, -- Rejuvenation Rank 8
			{22895,20000, req=22842, optional="not talentanyknown(16934,16858)"}, -- Frenzied Regeneration Rank 2 (Talents: Ferocity, Feral Aggression)
		},
		[48] = {
			{9845,22000, req=6793, optional="not talentanyknown(16934,16858)"}, -- Tiger's Fury Rank 3 (Talents: Ferocity, Feral Aggression)
			{9849,22000, req=5201, optional="not talentanyknown(16934,16858)"}, -- Claw Rank 4 (Talents: Ferocity, Feral Aggression)
			{9852,22000, req=5196, optional="talentanyknown(16934,16858)"}, -- Entangling Roots Rank 5 (Talents: Ferocity, Feral Aggression)
			{9856,22000, req=9750, rank=7}, -- Regrowth Rank 7
			{16813,1100, req=16812, talent=16689, rank=5}, -- Nature's Grasp Rank 5
			{22828,22000, req=22827, optional="not talentanyknown(16934,16858)"}, -- Ferocious Bite Rank 3 (Talents: Ferocity, Feral Aggression)
		},
		[50] = {
			{9862,23000, req=8918, optional=true, rank=3}, -- Tranquility Rank 3
			{9866,23000, req=6787, optional="not talentanyknown(16934,16858)"}, -- Ravage Rank 3 (Talents: Ferocity, Feral Aggression)
			{9875,23000, req=8951, optional="talentanyknown(16934,16858)"}, -- Starfire Rank 5 (Talents: Ferocity, Feral Aggression)
			{9880,23000, req=9745, optional="not talentanyknown(16934,16858)"}, -- Maul Rank 6 (Talents: Ferocity, Feral Aggression)
			{9884,23000, req=8907, rank=6}, -- Mark of the Wild Rank 6
			{9888,23000, req=9758, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 9 (Talents: Ferocity, Feral Aggression)
			{17401,23000, req=16914, optional=true, rank=2}, -- Hurricane Rank 2
			{20747,23000, req=20742, optional=true, rank=4}, -- Rebirth Rank 4
			{24976,1150, req=24975, talent=5570, rank=4}, -- Insect Swarm Rank 4
		},
		[52] = {
			{9834,26000, req=9833, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 9 (Talents: Ferocity, Feral Aggression)
			{9840,26000, req=9839, rank=9}, -- Rejuvenation Rank 9
			{9892,26000, req=9000, optional=true, rank=3}, -- Cower Rank 3
			{9894,26000, req=9752, optional="not talentanyknown(16934,16858)"}, -- Rip Rank 5 (Talents: Ferocity, Feral Aggression)
			{9898,26000, req=9747, optional="not talentanyknown(16934,16858)"}, -- Demoralizing Roar Rank 5 (Talents: Ferocity, Feral Aggression)
		},
		[54] = {
			{9830,28000, req=9829, optional="not talentanyknown(16934,16858)"}, -- Shred Rank 5 (Talents: Ferocity, Feral Aggression)
			{9857,28000, req=9856, rank=8}, -- Regrowth Rank 8
			{9901,28000, req=8955, optional=true, rank=3}, -- Soothe Animal Rank 3
			{9904,28000, req=1824, optional="not talentanyknown(16934,16858)"}, -- Rake Rank 4 (Talents: Ferocity, Feral Aggression)
			{9907,28000, req=9749, optional="talentanyknown(16934,16858)"}, -- Faerie Fire Rank 4 (Talents: Ferocity, Feral Aggression)
			{9908,28000, req=9754, optional="not talentanyknown(16934,16858)"}, -- Swipe Rank 5 (Talents: Ferocity, Feral Aggression)
			{9910,28000, req=9756, optional=true, rank=6}, -- Thorns Rank 6
			{9912,28000, req=8905, optional="talentanyknown(16934,16858)"}, -- Wrath Rank 8 (Talents: Ferocity, Feral Aggression)
			{17392,1400, req=17391, talent=16857, rank=4}, -- Faerie Fire (Feral) Rank 4
		},
		[56] = {
			{9827,30000, req=9823, optional=true, rank=3}, -- Pounce Rank 3
			{9889,30000, req=9888, optional="talentanyknown(16934,16858)"}, -- Healing Touch Rank 10 (Talents: Ferocity, Feral Aggression)
			{22829,30000, req=22828, optional="not talentanyknown(16934,16858)"}, -- Ferocious Bite Rank 4 (Talents: Ferocity, Feral Aggression)
			{22896,30000, req=22895, optional="not talentanyknown(16934,16858)"}, -- Frenzied Regeneration Rank 3 (Talents: Ferocity, Feral Aggression)
		},
		[58] = {
			{9835,32000, req=9834, optional="talentanyknown(16934,16858)"}, -- Moonfire Rank 10 (Talents: Ferocity, Feral Aggression)
			{9841,32000, req=9840, rank=10}, -- Rejuvenation Rank 10
			{9850,32000, req=9849, optional="not talentanyknown(16934,16858)"}, -- Claw Rank 5 (Talents: Ferocity, Feral Aggression)
			{9853,32000, req=9852, optional="talentanyknown(16934,16858)"}, -- Entangling Roots Rank 6 (Talents: Ferocity, Feral Aggression)
			{9867,32000, req=9866, optional="not talentanyknown(16934,16858)"}, -- Ravage Rank 4 (Talents: Ferocity, Feral Aggression)
			{9876,32000, req=9875, optional="talentanyknown(16934,16858)"}, -- Starfire Rank 6 (Talents: Ferocity, Feral Aggression)
			{9881,32000, req=9880, optional="not talentanyknown(16934,16858)"}, -- Maul Rank 7 (Talents: Ferocity, Feral Aggression)
			{17329,1600, req=16813, talent=16689, rank=6}, -- Nature's Grasp Rank 6
			{18658,32000, req=18657, optional=true, rank=3}, -- Hibernate Rank 3
		},
		[60] = {
			{9846,34000, req=9845, optional="not talentanyknown(16934,16858)"}, -- Tiger's Fury Rank 4 (Talents: Ferocity, Feral Aggression)
			{9858,34000, req=9857, rank=9}, -- Regrowth Rank 9
			{9863,34000, req=9862, optional=true, rank=4}, -- Tranquility Rank 4
			{9885,34000, req=9884, rank=7}, -- Mark of the Wild Rank 7
			{9896,34000, req=9894, optional="not talentanyknown(16934,16858)"}, -- Rip Rank 6 (Talents: Ferocity, Feral Aggression)
			{9913,34000, req=6783, rank=3}, -- Prowl Rank 3
			{17402,34000, req=17401, optional=true, rank=3}, -- Hurricane Rank 3
			{20748,34000, req=20747, optional=true, rank=5}, -- Rebirth Rank 5
			{24977,1700, req=24976, talent=5570, rank=5}, -- Insect Swarm Rank 5
		},
	},
	ROGUE = {
		[1] = {
			{1784,10, rank=1}, -- Stealth Rank 1
		},
		[4] = {
			{53,100, rank=1}, -- Backstab Rank 1
			{921,100, optional=true}, -- Pick Pocket
		},
		[6] = {
			{1757,100, req=1752, rank=2}, -- Sinister Strike Rank 2
			{1776,100, rank=1}, -- Gouge Rank 1
		},
		[8] = {
			{5277,200}, -- Evasion
			{6760,200, req=2098, rank=2}, -- Eviscerate Rank 2
		},
		[10] = {
			{674,300}, -- Dual Wield Passive
			{2983,300, rank=1}, -- Sprint Rank 1
			{5171,300, rank=1}, -- Slice and Dice Rank 1
			{6770,300, rank=1}, -- Sap Rank 1
		},
		[12] = {
			{1766,800, rank=1}, -- Kick Rank 1
			{2589,800, req=53, rank=2}, -- Backstab Rank 2
			{3127,800}, -- Parry Passive
		},
		[14] = {
			{703,1200, optional=true, rank=1}, -- Garrote Rank 1
			{1758,1200, req=1757, rank=3}, -- Sinister Strike Rank 3
			{8647,1200, optional=true, rank=1}, -- Expose Armor Rank 1
		},
		[16] = {
			{1804,1800, optional=true}, -- Pick Lock
			{1966,1800, optional=true, rank=1}, -- Feint Rank 1
			{6761,1800, req=6760, rank=3}, -- Eviscerate Rank 3
		},
		[18] = {
			{1777,2900, req=1776, rank=2}, -- Gouge Rank 2
			{8676,2900, rank=1}, -- Ambush Rank 1
		},
		[20] = {
			{1785,3000, req=1784, rank=2}, -- Stealth Rank 2
			{1943,3000, optional=true, rank=1}, -- Rupture Rank 1
			{2590,3000, req=2589, rank=3}, -- Backstab Rank 3
			{3420,3000, rank=1}, -- Crippling Poison Rank 1
		},
		[22] = {
			{1725,4000, optional=true}, -- Distract
			{1759,4000, req=1758, rank=4}, -- Sinister Strike Rank 4
			{1856,4000, req=1784, rank=1}, -- Vanish Rank 1
			{8631,4000, req=703, optional=true, rank=2}, -- Garrote Rank 2
		},
		[24] = {
			{2836,5000, optional=true}, -- Detect Traps Passive
			{5763,5000, optional=true, rank=1}, -- Mind-numbing Poison Rank 1
			{6762,5000, req=6761, rank=4}, -- Eviscerate Rank 4
		},
		[26] = {
			{1767,6000, req=1766, optional=true, rank=2}, -- Kick Rank 2
			{1833,6000}, -- Cheap Shot
			{8649,6000, req=8647, optional=true, rank=2}, -- Expose Armor Rank 2
			{8724,6000, req=8676, rank=2}, -- Ambush Rank 2
		},
		[28] = {
			{2070,8000, req=6770, rank=2}, -- Sap Rank 2
			{2591,8000, req=2590, rank=4}, -- Backstab Rank 4
			{6768,8000, req=1966, optional=true, rank=2}, -- Feint Rank 2
			{8639,8000, req=1943, optional=true, rank=2}, -- Rupture Rank 2
			{8687,8000, rank=2}, -- Instant Poison II Rank 2
		},
		[30] = {
			{408,10000, rank=1}, -- Kidney Shot Rank 1
			{1760,10000, req=1759, rank=5}, -- Sinister Strike Rank 5
			{1842,10000, req=2836, optional=true}, -- Disarm Trap
			{2835,10000, optional=true, rank=1}, -- Deadly Poison Rank 1
			{8632,10000, req=8631, optional=true, rank=3}, -- Garrote Rank 3
		},
		[32] = {
			{8623,12000, req=6762, rank=5}, -- Eviscerate Rank 5
			{8629,12000, req=1777, rank=3}, -- Gouge Rank 3
			{13220,12000, optional=true, rank=1}, -- Wound Poison Rank 1
		},
		[34] = {
			{2094,14000}, -- Blind
			{6510,14000}, -- Blinding Powder
			{8696,14000, req=2983, rank=2}, -- Sprint Rank 2
			{8725,14000, req=8724, rank=3}, -- Ambush Rank 3
		},
		[36] = {
			{8640,16000, req=8639, optional=true, rank=3}, -- Rupture Rank 3
			{8650,16000, req=8649, optional=true, rank=3}, -- Expose Armor Rank 3
			{8691,16000, rank=3}, -- Instant Poison III Rank 3
			{8721,16000, req=2591, rank=5}, -- Backstab Rank 5
		},
		[38] = {
			{2837,18000, optional=true, rank=2}, -- Deadly Poison II Rank 2
			{8621,18000, req=1760, rank=6}, -- Sinister Strike Rank 6
			{8633,18000, req=8632, optional=true, rank=4}, -- Garrote Rank 4
			{8694,18000, optional=true, rank=2}, -- Mind-numbing Poison II Rank 2
		},
		[40] = {
			{1786,20000, req=1785, rank=3}, -- Stealth Rank 3
			{1860,20000}, -- Safe Fall Passive
			{8624,20000, req=8623, rank=6}, -- Eviscerate Rank 6
			{8637,20000, req=6768, optional=true, rank=3}, -- Feint Rank 3
			{13228,20000, optional=true, rank=2}, -- Wound Poison II Rank 2
		},
		[42] = {
			{1768,27000, req=1767, optional=true, rank=3}, -- Kick Rank 3
			{1857,27000, req=1856, rank=2}, -- Vanish Rank 2
			{6774,27000, req=5171, rank=2}, -- Slice and Dice Rank 2
			{11267,27000, req=8725, rank=4}, -- Ambush Rank 4
		},
		[44] = {
			{11273,29000, req=8640, optional=true, rank=4}, -- Rupture Rank 4
			{11279,29000, req=8721, rank=6}, -- Backstab Rank 6
			{11341,29000, rank=4}, -- Instant Poison IV Rank 4
		},
		[46] = {
			{11197,31000, req=8650, optional=true, rank=4}, -- Expose Armor Rank 4
			{11285,31000, req=8629, rank=4}, -- Gouge Rank 4
			{11289,31000, req=8633, optional=true, rank=5}, -- Garrote Rank 5
			{11293,31000, req=8621, rank=7}, -- Sinister Strike Rank 7
			{11357,31000, optional=true, rank=3}, -- Deadly Poison III Rank 3
			{17347,7750, req=16511, rank=2}, -- Hemorrhage Rank 2
		},
		[48] = {
			{11297,33000, req=2070, rank=3}, -- Sap Rank 3
			{11299,33000, req=8624, rank=7}, -- Eviscerate Rank 7
			{13229,33000, optional=true, rank=3}, -- Wound Poison III Rank 3
		},
		[50] = {
			{3421,35000, rank=2}, -- Crippling Poison II Rank 2
			{8643,35000, req=408, rank=2}, -- Kidney Shot Rank 2
			{11268,35000, req=11267, rank=5}, -- Ambush Rank 5
		},
		[52] = {
			{11274,46000, req=11273, optional=true, rank=5}, -- Rupture Rank 5
			{11280,46000, req=11279, rank=7}, -- Backstab Rank 7
			{11303,46000, req=8637, optional=true, rank=4}, -- Feint Rank 4
			{11342,46000, rank=5}, -- Instant Poison V Rank 5
			{11400,46000, optional=true, rank=3}, -- Mind-numbing Poison III Rank 3
		},
		[54] = {
			{11290,48000, req=11289, optional=true, rank=6}, -- Garrote Rank 6
			{11294,48000, req=11293, rank=8}, -- Sinister Strike Rank 8
			{11358,48000, optional=true, rank=4}, -- Deadly Poison IV Rank 4
		},
		[56] = {
			{11198,50000, req=11197, optional=true, rank=5}, -- Expose Armor Rank 5
			{11300,50000, req=11299, rank=8}, -- Eviscerate Rank 8
			{13230,50000, optional=true, rank=4}, -- Wound Poison IV Rank 4
		},
		[58] = {
			{1769,52000, req=1768, optional=true, rank=4}, -- Kick Rank 4
			{11269,52000, req=11268, rank=6}, -- Ambush Rank 6
			{11305,52000, req=8696, rank=3}, -- Sprint Rank 3
			{17348,13000, req=17347, rank=3}, -- Hemorrhage Rank 3
		},
		[60] = {
			{1787,54000, req=1786, rank=4}, -- Stealth Rank 4
			{11275,54000, req=11274, optional=true, rank=6}, -- Rupture Rank 6
			{11281,54000, req=11280, rank=8}, -- Backstab Rank 8
			{11286,54000, req=11285, rank=5}, -- Gouge Rank 5
			{11343,54000, rank=6}, -- Instant Poison VI Rank 6
		},
	},
	SHAMAN = {
		[1] = {
			{8017,10, rank=1}, -- Rockbiter Weapon Rank 1
		},
		[4] = {
			{8042,100, rank=1}, -- Earth Shock Rank 1
		},
		[6] = {
			{332,100, req=331, rank=2}, -- Healing Wave Rank 2
			{2484,100, optional=true}, -- Earthbind Totem
		},
		[8] = {
			{324,100, rank=1}, -- Lightning Shield Rank 1
			{529,100, req=403, rank=2}, -- Lightning Bolt Rank 2
			{5730,100, optional=true, rank=1}, -- Stoneclaw Totem Rank 1
			{8018,100, req=8017, rank=2}, -- Rockbiter Weapon Rank 2
			{8044,100, req=8042, rank=2}, -- Earth Shock Rank 2
		},
		[10] = {
			{8024,400, optional=true, rank=1}, -- Flametongue Weapon Rank 1
			{8050,400, rank=1}, -- Flame Shock Rank 1
			{8075,400, rank=1}, -- Strength of Earth Totem Rank 1
		},
		[12] = {
			{370,720, rank=1}, -- Purge Rank 1
			{547,800, req=332, rank=3}, -- Healing Wave Rank 3
			{1535,800, optional=true, rank=1}, -- Fire Nova Totem Rank 1
			{2008,800, rank=1}, -- Ancestral Spirit Rank 1
		},
		[14] = {
			{548,900, req=529, optional="talentknown(16253)"}, -- Lightning Bolt Rank 3 (Talents: Shield Specialization)
			{8045,900, req=8044, optional="talentknown(16182)"}, -- Earth Shock Rank 3 (Talents: Improved Healing Wave)
			{8154,900, optional=true, rank=2}, -- Stoneskin Totem Rank 2
		},
		[16] = {
			{325,1800, req=324, rank=2}, -- Lightning Shield Rank 2
			{526,1800}, -- Cure Poison
			{8019,1800, req=8018, rank=3}, -- Rockbiter Weapon Rank 3
		},
		[18] = {
			{913,2000, req=547, rank=4}, -- Healing Wave Rank 4
			{6390,2000, req=5730, optional=true, rank=2}, -- Stoneclaw Totem Rank 2
			{8027,2000, req=8024, optional=true, rank=2}, -- Flametongue Weapon Rank 2
			{8052,2000, req=8050, optional="not talentknown(16176)"}, -- Flame Shock Rank 2 (Talents: Ancestral Healing)
			{8143,2000, optional=true}, -- Tremor Totem
		},
		[20] = {
			{915,2200, req=548, optional="talentknown(16253)"}, -- Lightning Bolt Rank 4 (Talents: Shield Specialization)
			{2645,2200}, -- Ghost Wolf
			{6363,2200, optional=true, rank=2}, -- Searing Totem Rank 2
			{8004,2200, rank=1}, -- Lesser Healing Wave Rank 1
			{8033,2200, optional=true, rank=1}, -- Frostbrand Weapon Rank 1
			{8056,2200, rank=1}, -- Frost Shock Rank 1
		},
		[22] = {
			{131,3000}, -- Water Breathing
			{2870,900}, -- Cure Disease
			{8166,3000, optional=true}, -- Poison Cleansing Totem
			{8498,3000, req=1535, optional=true, rank=2}, -- Fire Nova Totem Rank 2
		},
		[24] = {
			{905,3500, req=325, rank=3}, -- Lightning Shield Rank 3
			{939,3500, req=913, rank=5}, -- Healing Wave Rank 5
			{8046,3500, req=8045, optional="talentknown(16176)"}, -- Earth Shock Rank 4 (Talents: Ancestral Healing)
			{8155,3500, req=8154, optional=true, rank=3}, -- Stoneskin Totem Rank 3
			{8160,3500, req=8075, rank=2}, -- Strength of Earth Totem Rank 2
			{8181,3500, optional=true, rank=1}, -- Frost Resistance Totem Rank 1
			{10399,3500, req=8019, rank=4}, -- Rockbiter Weapon Rank 4
			{20609,3500, req=2008, optional=true, rank=2}, -- Ancestral Spirit Rank 2
		},
		[26] = {
			{943,4000, req=915, optional="talentknown(16253)"}, -- Lightning Bolt Rank 5 (Talents: Shield Specialization)
			{5675,4000, optional="not talentknown(16176)"}, -- Mana Spring Totem Rank 1 (Talents: Ancestral Healing)
			{6196,4000, optional=true}, -- Far Sight
			{8030,4000, req=8027, optional=true, rank=3}, -- Flametongue Weapon Rank 3
			{8190,4000, optional=true, rank=1}, -- Magma Totem Rank 1
		},
		[28] = {
			{546,6000}, -- Water Walking
			{6391,6000, req=6390, optional=true, rank=3}, -- Stoneclaw Totem Rank 3
			{8008,6000, req=8004, rank=2}, -- Lesser Healing Wave Rank 2
			{8038,6000, req=8033, optional=true, rank=2}, -- Frostbrand Weapon Rank 2
			{8053,6000, req=8052, optional="not talentknown(16176)"}, -- Flame Shock Rank 3 (Talents: Ancestral Healing)
			{8184,6000, optional=true, rank=1}, -- Fire Resistance Totem Rank 1
			{8227,6000, optional=true, rank=1}, -- Flametongue Totem Rank 1
		},
		[30] = {
			{556,7000}, -- Astral Recall
			{6364,7000, req=6363, rank=3}, -- Searing Totem Rank 3
			{6375,7000, optional="talentknown(16176)"}, -- Healing Stream Totem Rank 2 (Talents: Ancestral Healing)
			{8177,7000}, -- Grounding Totem
			{8232,7000, optional=true, rank=1}, -- Windfury Weapon Rank 1
			{10595,7000, optional=true, rank=1}, -- Nature Resistance Totem Rank 1
			{20608,7000}, -- Reincarnation Passive
		},
		[32] = {
			{421,8000, optional="talentknown(16253)"}, -- Chain Lightning Rank 1 (Talents: Shield Specialization)
			{945,8000, req=905, rank=4}, -- Lightning Shield Rank 4
			{959,8000, req=939, rank=6}, -- Healing Wave Rank 6
			{6041,8000, req=943, optional="talentknown(16253)"}, -- Lightning Bolt Rank 6 (Talents: Shield Specialization)
			{8012,7200, req=370, rank=2}, -- Purge Rank 2
			{8499,8000, req=8498, optional=true, rank=3}, -- Fire Nova Totem Rank 3
			{8512,8000, rank=1}, -- Windfury Totem Rank 1
		},
		[34] = {
			{6495,9000, optional=true}, -- Sentry Totem
			{8058,9000, req=8056, optional=true, rank=2}, -- Frost Shock Rank 2
			{10406,9000, req=8155, optional=true, rank=4}, -- Stoneskin Totem Rank 4
			{16314,9000, req=10399, rank=5}, -- Rockbiter Weapon Rank 5
		},
		[36] = {
			{8010,10000, req=8008, rank=3}, -- Lesser Healing Wave Rank 3
			{10412,10000, req=8046, optional="talentknown(16176)"}, -- Earth Shock Rank 5 (Talents: Ancestral Healing)
			{10495,10000, req=5675, optional="not talentknown(16176)"}, -- Mana Spring Totem Rank 2 (Talents: Ancestral Healing)
			{10585,10000, req=8190, optional=true, rank=2}, -- Magma Totem Rank 2
			{15107,10000, optional=true, rank=1}, -- Windwall Totem Rank 1
			{16339,10000, req=8030, optional=true, rank=4}, -- Flametongue Weapon Rank 4
			{20610,10000, req=20609, optional=true, rank=3}, -- Ancestral Spirit Rank 3
		},
		[38] = {
			{6392,11000, req=6391, optional=true, rank=4}, -- Stoneclaw Totem Rank 4
			{8161,11000, req=8160, rank=3}, -- Strength of Earth Totem Rank 3
			{8170,11000, optional=true}, -- Disease Cleansing Totem
			{8249,11000, req=8227, optional=true, rank=2}, -- Flametongue Totem Rank 2
			{10391,11000, req=6041, optional="talentknown(16253)"}, -- Lightning Bolt Rank 7 (Talents: Shield Specialization)
			{10456,11000, req=8038, optional=true, rank=3}, -- Frostbrand Weapon Rank 3
			{10478,11000, req=8181, optional=true, rank=2}, -- Frost Resistance Totem Rank 2
		},
		[40] = {
			{930,12000, req=421, optional="talentknown(16253)"}, -- Chain Lightning Rank 2 (Talents: Shield Specialization)
			{1064,12000, optional="talentknown(16253)"}, -- Chain Heal Rank 1 (Talents: Shield Specialization)
			{6365,12000, req=6364, rank=4}, -- Searing Totem Rank 4
			{6377,12000, req=6375, optional="talentknown(16190)"}, -- Healing Stream Totem Rank 3 (Talents: Mana Tide Totem)
			{8005,12000, req=959, rank=7}, -- Healing Wave Rank 7
			{8134,12000, req=945, rank=5}, -- Lightning Shield Rank 5
			{8235,12000, req=8232, optional=true, rank=2}, -- Windfury Weapon Rank 2
			{8737,12000}, -- Mail
			{10447,12000, req=8053, optional="not talentknown(16176)"}, -- Flame Shock Rank 4 (Talents: Ancestral Healing)
		},
		[42] = {
			{8835,16000, optional=true, rank=1}, -- Grace of Air Totem Rank 1
			{10537,16000, req=8184, optional=true, rank=2}, -- Fire Resistance Totem Rank 2
			{10613,16000, req=8512, rank=2}, -- Windfury Totem Rank 2
			{11314,16000, req=8499, optional=true, rank=4}, -- Fire Nova Totem Rank 4
		},
		[44] = {
			{10392,18000, req=10391, optional="talentknown(17364)"}, -- Lightning Bolt Rank 8 (Talents: Stormstrike)
			{10407,18000, req=10406, optional=true, rank=5}, -- Stoneskin Totem Rank 5
			{10466,18000, req=8010, rank=4}, -- Lesser Healing Wave Rank 4
			{10600,18000, req=10595, optional=true, rank=2}, -- Nature Resistance Totem Rank 2
			{16315,18000, req=16314, rank=6}, -- Rockbiter Weapon Rank 6
		},
		[46] = {
			{10472,20000, req=8058, optional=true, rank=3}, -- Frost Shock Rank 3
			{10496,20000, req=10495, optional="not talentknown(16190)"}, -- Mana Spring Totem Rank 3 (Talents: Mana Tide Totem)
			{10586,20000, req=10585, optional=true, rank=3}, -- Magma Totem Rank 3
			{10622,20000, req=1064, optional="talentknown(17364)"}, -- Chain Heal Rank 2 (Talents: Stormstrike)
			{15111,20000, req=15107, optional=true, rank=2}, -- Windwall Totem Rank 2
			{16341,20000, req=16339, optional=true, rank=5}, -- Flametongue Weapon Rank 5
		},
		[48] = {
			{2860,22000, req=930, optional="talentknown(17364)"}, -- Chain Lightning Rank 3 (Talents: Stormstrike)
			{10395,22000, req=8005, rank=8}, -- Healing Wave Rank 8
			{10413,22000, req=10412, optional="talentknown(16190)"}, -- Earth Shock Rank 6 (Talents: Mana Tide Totem)
			{10427,22000, req=6392, optional=true, rank=5}, -- Stoneclaw Totem Rank 5
			{10431,22000, req=8134, rank=6}, -- Lightning Shield Rank 6
			{10526,22000, req=8249, optional=true, rank=3}, -- Flametongue Totem Rank 3
			{16355,22000, req=10456, optional=true, rank=4}, -- Frostbrand Weapon Rank 4
			{17354,55000, rank=2}, -- Mana Tide Totem Rank 2
			{20776,22000, req=20610, optional=true, rank=4}, -- Ancestral Spirit Rank 4
		},
		[50] = {
			{10437,24000, req=6365, rank=5}, -- Searing Totem Rank 5
			{10462,24000, req=6377, optional="talentknown(16190)"}, -- Healing Stream Totem Rank 4 (Talents: Mana Tide Totem)
			{10486,24000, req=8235, optional=true, rank=3}, -- Windfury Weapon Rank 3
			{15207,24000, req=10392, optional="talentknown(17364)"}, -- Lightning Bolt Rank 9 (Talents: Stormstrike)
			{25908,24000, optional=true}, -- Tranquil Air Totem
		},
		[52] = {
			{10442,27000, req=8161, rank=4}, -- Strength of Earth Totem Rank 4
			{10448,27000, req=10447, optional="not talentknown(16190)"}, -- Flame Shock Rank 5 (Talents: Mana Tide Totem)
			{10467,27000, req=10466, rank=5}, -- Lesser Healing Wave Rank 5
			{10614,27000, req=10613, rank=3}, -- Windfury Totem Rank 3
			{11315,27000, req=11314, optional=true, rank=5}, -- Fire Nova Totem Rank 5
		},
		[54] = {
			{10408,29000, req=10407, optional=true, rank=6}, -- Stoneskin Totem Rank 6
			{10479,29000, req=10478, optional=true, rank=3}, -- Frost Resistance Totem Rank 3
			{10623,29000, req=10622, optional="talentknown(17364)"}, -- Chain Heal Rank 3 (Talents: Stormstrike)
			{16316,29000, req=16315, rank=7}, -- Rockbiter Weapon Rank 7
		},
		[56] = {
			{10396,30000, req=10395, rank=9}, -- Healing Wave Rank 9
			{10432,30000, req=10431, rank=7}, -- Lightning Shield Rank 7
			{10497,30000, req=10496, optional="not talentknown(16190)"}, -- Mana Spring Totem Rank 4 (Talents: Mana Tide Totem)
			{10587,30000, req=10586, optional=true, rank=4}, -- Magma Totem Rank 4
			{10605,30000, req=2860, optional="talentknown(17364)"}, -- Chain Lightning Rank 4 (Talents: Stormstrike)
			{10627,30000, req=8835, optional=true, rank=2}, -- Grace of Air Totem Rank 2
			{15112,30000, req=15111, optional=true, rank=3}, -- Windwall Totem Rank 3
			{15208,30000, req=15207, optional="talentknown(17364)"}, -- Lightning Bolt Rank 10 (Talents: Stormstrike)
			{16342,30000, req=16341, optional=true, rank=6}, -- Flametongue Weapon Rank 6
		},
		[58] = {
			{10428,32000, req=10427, optional=true, rank=6}, -- Stoneclaw Totem Rank 6
			{10473,32000, req=10472, optional=true, rank=4}, -- Frost Shock Rank 4
			{10538,32000, req=10537, optional=true, rank=3}, -- Fire Resistance Totem Rank 3
			{16356,32000, req=16355, optional=true, rank=5}, -- Frostbrand Weapon Rank 5
			{16387,32000, req=10526, optional=true, rank=4}, -- Flametongue Totem Rank 4
			{17359,80000, req=17354, rank=3}, -- Mana Tide Totem Rank 3
		},
		[60] = {
			{10414,34000, req=10413, optional="talentknown(16190)"}, -- Earth Shock Rank 7 (Talents: Mana Tide Totem)
			{10438,34000, req=10437, rank=6}, -- Searing Totem Rank 6
			{10463,34000, req=10462, optional="talentknown(16190)"}, -- Healing Stream Totem Rank 5 (Talents: Mana Tide Totem)
			{10468,34000, req=10467, rank=6}, -- Lesser Healing Wave Rank 6
			{10601,34000, req=10600, optional=true, rank=3}, -- Nature Resistance Totem Rank 3
			{16362,34000, req=10486, optional=true, rank=4}, -- Windfury Weapon Rank 4
			{20777,34000, req=20776, optional=true, rank=5}, -- Ancestral Spirit Rank 5
		},
	},
}