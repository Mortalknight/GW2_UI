local _, GW = ...
if (GW.currentClass ~= "DRUID") then
	return
end

local faerieFireFeral = {16857 --[[Rank 1]], 17390 --[[Rank 2]], 17391 --[[Rank 3]], 17392 --[[Rank 4]]}
local ravage = {6785 --[[Rank 1]], 6787 --[[Rank 2]], 9866 --[[Rank 3]], 9867 --[[Rank 4]]}
local maul = {
	6807 --[[Rank 1]],
	6808 --[[Rank 2]],
	6809 --[[Rank 3]],
	8972 --[[Rank 4]],
	9745 --[[Rank 5]],
	9880 --[[Rank 6]],
	9881 --[[Rank 7]]
}
local demoralizingRoar = {99 --[[Rank 1]], 1735 --[[Rank 2]], 9490 --[[Rank 3]], 9747 --[[Rank 4]], 9898 --[[Rank 5]]}
local cower = {8998, 9000, 9892}
local swipe = {779 --[[Rank 1]], 780 --[[Rank 2]], 769 --[[Rank 3]], 9754 --[[Rank 4]], 9908 --[[Rank 5]]}
local shred = {5221 --[[Rank 1]], 6800 --[[Rank 2]], 8992 --[[Rank 3]], 9829 --[[Rank 4]], 9830 --[[Rank 5]]}
local rake = {1822 --[[Rank 1]], 1823 --[[Rank 2]], 1824 --[[Rank 3]], 9904 --[[Rank 4]]}
local pounce = {9005 --[[Rank 1]], 9823 --[[Rank 2]], 9827 --[[Rank 3]]}
local frenziedRegeneration = {22842 --[[Rank 1]], 22895 --[[Rank 2]], 22896 --[[Rank 3]]}
local freociousBite = {
	22568 --[[Rank 1]],
	22827 --[[Rank 2]],
	22828 --[[Rank 3]],
	22829 --[[Rank 4]],
	31018 --[[Rank 5]]
}
local claw = {1082 --[[Rank 1]], 3029 --[[Rank 2]], 5201 --[[Rank 3]], 9849 --[[Rank 4]], 9850}
local tigersFury = {5217 --[[Rank 1]], 6793 --[[Rank 2]], 9845 --[[Rank 3]], 9846 --[[Rank 4]]}
local prowl = {5215, 6783, 9913}
local rip = {1079 --[[Rank 1]], 9492 --[[Rank 2]], 9493 --[[Rank 3]], 9752 --[[Rank 4]], 9894 --[[Rank 5]], 9896}
local bash = {5211, 6798, 8983}
local dash = {1850, 9821}

--[[
GW:SetPreviousAbilityMap(
	{
		faerieFireFeral,
		ravage,
		maul,
		demoralizingRoar,
		cower,
		swipe,
		shred,
		rake,
		pounce,
		frenziedRegeneration,
		freociousBite,
		claw,
		tigersFury,
		prowl,
		rip,
		bash,
		dash
	}
)
]]

GW.SpellsByLevel = {
	[1] = {{id = 1126, cost = 10}},
	[4] = {{id = 8921, cost = 100}, {id = 774, cost = 100}},
	[6] = {{id = 467, cost = 100}, {id = 5177, cost = 100, requiredIds = {5176}}},
	[8] = {{id = 339, cost = 200}, {id = 5186, cost = 200, requiredIds = {5185}}},
	[10] = {
		{id = 99, cost = 300, requiredIds = {5487}},
		{id = 5232, cost = 300, requiredIds = {1126}},
		{id = 8924, cost = 300, requiredIds = {8921}},
		{id = 1058, cost = 300, requiredIds = {774}}
	},
	[12] = {{id = 5229, cost = 800, requiredIds = {5487}}, {id = 8936, cost = 800}},
	[14] = {
		{id = 5211, cost = 900, requiredIds = {5487}},
		{id = 5187, cost = 900, requiredIds = {5186}},
		{id = 782, cost = 900, requiredIds = {467}},
		{id = 5178, cost = 900, requiredIds = {5177}}
	},
	[16] = {
		{id = 8925, cost = 1800, requiredIds = {8924}},
		{id = 1430, cost = 1800, requiredIds = {1058}},
		{id = 779, cost = 1800, requiredIds = {5487}}
	},
	[18] = {
		{id = 1062, cost = 1900, requiredIds = {339}},
		{id = 770, cost = 1900},
		{id = 2637, cost = 1900},
		{id = 6808, cost = 1900, requiredIds = {6807}},
		{id = 16810, cost = 95, requiredIds = {16689}, requiredTalentId = 16689},
		{id = 8938, cost = 1900, requiredIds = {8936}}
	},
	[20] = {
		{id = 768, cost = 2000},
		{id = 1082, cost = 2000, requiredIds = {768}},
		{id = 1735, cost = 2000, requiredIds = {99}},
		{id = 5188, cost = 2000, requiredIds = {5187}},
		{id = 6756, cost = 2000, requiredIds = {5232}},
		{id = 5215, cost = 2000, requiredIds = {768}},
		{id = 20484, cost = 2000},
		{id = 1079, cost = 2000, requiredIds = {768}},
		{id = 2912, cost = 2000}
	},
	[22] = {
		{id = 8926, cost = 3000, requiredIds = {8925}},
		{id = 2090, cost = 3000, requiredIds = {1430}},
		{id = 5221, cost = 3000, requiredIds = {768}},
		{id = 2908, cost = 3000},
		{id = 5179, cost = 3000, requiredIds = {5178}}
	},
	[24] = {
		{id = 1822, cost = 4000, requiredIds = {768}},
		{id = 8939, cost = 4000, requiredIds = {8938}},
		{id = 2782, cost = 4000},
		{id = 780, cost = 4000, requiredIds = {779}},
		{id = 1075, cost = 4000, requiredIds = {782}},
		{id = 5217, cost = 4000, requiredIds = {768}}
	},
	[26] = {
		{id = 2893, cost = 4500},
		{id = 1850, cost = 4500, requiredIds = {768}},
		{id = 5189, cost = 4500, requiredIds = {5188}},
		{id = 6809, cost = 4500, requiredIds = {6808}},
		{id = 8949, cost = 4500, requiredIds = {2912}}
	},
	[28] = {
		{id = 5209, cost = 5000, requiredIds = {5487}},
		{id = 3029, cost = 5000, requiredIds = {1082}},
		{id = 8998, cost = 5000, requiredIds = {768}},
		{id = 5195, cost = 5000, requiredIds = {1062}},
		{id = 8927, cost = 5000, requiredIds = {8926}},
		{id = 16811, cost = 250, requiredIds = {16810}, requiredTalentId = 16689},
		{id = 2091, cost = 5000, requiredIds = {2090}},
		{id = 9492, cost = 5000, requiredIds = {1079}}
	},
	[30] = {
		{id = 6798, cost = 6000, requiredIds = {5211}},
		{id = 778, cost = 6000, requiredIds = {770}},
		{id = 17390, cost = 300, requiredIds = {16857}, requiredTalentId = 16857},
		{id = 24974, cost = 300, requiredIds = {5570}, requiredTalentId = 5570},
		{id = 5234, cost = 6000, requiredIds = {6756}},
		{id = 20739, cost = 6000, requiredIds = {20484}},
		{id = 8940, cost = 6000, requiredIds = {8939}},
		{id = 6800, cost = 6000, requiredIds = {5221}},
		{id = 740, cost = 6000},
		{id = 783, cost = 6000},
		{id = 5180, cost = 6000, requiredIds = {5179}}
	},
	[32] = {
		{id = 9490, cost = 8000, requiredIds = {1735}},
		{id = 22568, cost = 8000, requiredIds = {768}},
		{id = 6778, cost = 8000, requiredIds = {5189}},
		{id = 6785, cost = 8000, requiredIds = {768}},
		{id = 5225, cost = 8000}
	},
	[34] = {
		{id = 8972, cost = 10000, requiredIds = {6809}},
		{id = 8928, cost = 10000, requiredIds = {8927}},
		{id = 1823, cost = 10000, requiredIds = {1822}},
		{id = 3627, cost = 10000, requiredIds = {2091}},
		{id = 8950, cost = 10000, requiredIds = {8949}},
		{id = 769, cost = 10000, requiredIds = {780}},
		{id = 8914, cost = 10000, requiredIds = {1075}}
	},
	[36] = {
		{id = 22842, cost = 11000, requiredIds = {5487}},
		{id = 9005, cost = 11000, requiredIds = {768}},
		{id = 8941, cost = 11000, requiredIds = {8940}},
		{id = 9493, cost = 11000, requiredIds = {9492}},
		{id = 6793, cost = 11000, requiredIds = {5217}}
	},
	[38] = {
		{id = 5201, cost = 12000, requiredIds = {3029}},
		{id = 5196, cost = 12000, requiredIds = {5195}},
		{id = 8903, cost = 12000, requiredIds = {6778}},
		{id = 18657, cost = 12000, requiredIds = {2637}},
		{id = 16812, cost = 600, requiredIds = {16811}, requiredTalentId = 16689},
		{id = 8992, cost = 12000, requiredIds = {6800}},
		{id = 8955, cost = 12000, requiredIds = {2908}},
		{id = 6780, cost = 12000, requiredIds = {5180}}
	},
	[40] = {
		{id = 9000, cost = 14000, requiredIds = {8998}},
		{id = 9634, cost = 14000, requiredIds = {5487}},
		{id = 20719, cost = 14000, requiredIds = {768}},
		{id = 22827, cost = 14000, requiredIds = {22568}},
		{id = 16914, cost = 14000},
		{id = 29166, cost = 14000},
		{id = 24975, cost = 700, requiredIds = {24974}, requiredTalentId = 5570},
		{id = 8907, cost = 14000, requiredIds = {5234}},
		{id = 8929, cost = 14000, requiredIds = {8928}},
		{id = 6783, cost = 14000, requiredIds = {5215}},
		{id = 20742, cost = 14000, requiredIds = {20739}},
		{id = 8910, cost = 14000, requiredIds = {3627}},
		{id = 8918, cost = 14000, requiredIds = {740}}
	},
	[42] = {
		{id = 9747, cost = 16000, requiredIds = {9490}},
		{id = 9749, cost = 16000, requiredIds = {778}},
		{id = 17391, cost = 800, requiredIds = {17390}, requiredTalentId = 16857},
		{id = 9745, cost = 16000, requiredIds = {8972}},
		{id = 6787, cost = 16000, requiredIds = {6785}},
		{id = 9750, cost = 16000, requiredIds = {8941}},
		{id = 8951, cost = 16000, requiredIds = {8950}}
	},
	[44] = {
		{id = 22812, cost = 18000},
		{id = 9758, cost = 18000, requiredIds = {8903}},
		{id = 1824, cost = 18000, requiredIds = {1823}},
		{id = 9752, cost = 18000, requiredIds = {9493}},
		{id = 9754, cost = 18000, requiredIds = {769}},
		{id = 9756, cost = 18000, requiredIds = {8914}}
	},
	[46] = {
		{id = 8983, cost = 20000, requiredIds = {6798}},
		{id = 9821, cost = 20000, requiredIds = {1850}},
		{id = 22895, cost = 20000, requiredIds = {22842}},
		{id = 9833, cost = 20000, requiredIds = {8929}},
		{id = 9823, cost = 20000, requiredIds = {9005}},
		{id = 9839, cost = 20000, requiredIds = {8910}},
		{id = 9829, cost = 20000, requiredIds = {8992}},
		{id = 8905, cost = 20000, requiredIds = {6780}}
	},
	[48] = {
		{id = 9849, cost = 22000, requiredIds = {5201}},
		{id = 9852, cost = 22000, requiredIds = {5196}},
		{id = 22828, cost = 22000, requiredIds = {22827}},
		{id = 16813, cost = 1100, requiredIds = {16812}, requiredTalentId = 16689},
		{id = 9856, cost = 22000, requiredIds = {9750}},
		{id = 9845, cost = 22000, requiredIds = {6793}}
	},
	[50] = {
		{id = 9888, cost = 23000, requiredIds = {9758}},
		{id = 17401, cost = 23000, requiredIds = {16914}},
		{id = 24976, cost = 1150, requiredIds = {24975}, requiredTalentId = 5570},
		{id = 9884, cost = 23000, requiredIds = {8907}},
		{id = 9880, cost = 23000, requiredIds = {9745}},
		{id = 9866, cost = 23000, requiredIds = {6787}},
		{id = 20747, cost = 23000, requiredIds = {20742}},
		{id = 9875, cost = 23000, requiredIds = {8951}},
		{id = 9862, cost = 23000, requiredIds = {8918}}
	},
	[52] = {
		{id = 9892, cost = 26000, requiredIds = {9000}},
		{id = 9898, cost = 26000, requiredIds = {9747}},
		{id = 9834, cost = 26000, requiredIds = {9833}},
		{id = 9840, cost = 26000, requiredIds = {9839}},
		{id = 9894, cost = 26000, requiredIds = {9752}}
	},
	[54] = {
		{id = 9907, cost = 28000, requiredIds = {9749}},
		{id = 17392, cost = 1400, requiredIds = {17391}, requiredTalentId = 16857},
		{id = 9904, cost = 28000, requiredIds = {1824}},
		{id = 9857, cost = 28000, requiredIds = {9856}},
		{id = 9830, cost = 28000, requiredIds = {9829}},
		{id = 9901, cost = 28000, requiredIds = {8955}},
		{id = 9908, cost = 28000, requiredIds = {9754}},
		{id = 9910, cost = 28000, requiredIds = {9756}},
		{id = 9912, cost = 28000, requiredIds = {8905}}
	},
	[56] = {
		{id = 22829, cost = 30000, requiredIds = {22828}},
		{id = 22896, cost = 30000, requiredIds = {22895}},
		{id = 9889, cost = 30000, requiredIds = {9888}},
		{id = 9827, cost = 30000, requiredIds = {9823}}
	},
	[58] = {
		{id = 9850, cost = 32000, requiredIds = {9849}},
		{id = 9853, cost = 32000, requiredIds = {9852}},
		{id = 18658, cost = 32000, requiredIds = {18657}},
		{id = 9881, cost = 32000, requiredIds = {9880}},
		{id = 9835, cost = 32000, requiredIds = {9834}},
		{id = 17329, cost = 1600, requiredIds = {16813}, requiredTalentId = 16689},
		{id = 9867, cost = 32000, requiredIds = {9866}},
		{id = 9841, cost = 32000, requiredIds = {9840}},
		{id = 9876, cost = 32000, requiredIds = {9875}}
	},
	[60] = {
		{id = 17402, cost = 34000, requiredIds = {17401}},
		{id = 24977, cost = 1700, requiredIds = {24976}, requiredTalentId = 5570},
		{id = 9885, cost = 34000, requiredIds = {9884}},
		{id = 9913, cost = 34000, requiredIds = {6783}},
		{id = 20748, cost = 34000, requiredIds = {20747}},
		{id = 9858, cost = 34000, requiredIds = {9857}},
		{id = 9896, cost = 34000, requiredIds = {9894}},
		{id = 9846, cost = 34000, requiredIds = {9845}},
		{id = 9863, cost = 34000, requiredIds = {9862}}
	}
}
