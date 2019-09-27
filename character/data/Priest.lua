local _, GW = ...
if (GW.currentClass ~= "PRIEST") then return end
GW.SpellsByLevel = GW.RaceFilter({
	[1] = {{id = 1243, cost = 10}},
	[4] = {{id = 2052, cost = 100, requiredIds = {2050}}, {id = 589, cost = 100}},
	[6] = {{id = 17, cost = 100}, {id = 591, cost = 100, requiredIds = {585}}},
	[8] = {{id = 586, cost = 200}, {id = 139, cost = 200}},
	[10] = {
		{id = 2053, cost = 300, requiredIds = {2052}},
		{id = 8092, cost = 300},
		{id = 2006, cost = 300},
		{id = 594, cost = 300, requiredIds = {589}}
	},
	[12] = {
		{id = 588, cost = 800},
		{id = 1244, cost = 800, requiredIds = {1243}},
		{id = 592, cost = 800, requiredIds = {17}}
	},
	[14] = {
		{id = 528, cost = 1200},
		{id = 8122, cost = 1200},
		{id = 6074, cost = 1200, requiredIds = {139}},
		{id = 598, cost = 1200, requiredIds = {591}}
	},
	[16] = {{id = 2054, cost = 1600}, {id = 8102, cost = 1600, requiredIds = {8092}}},
	[18] = {
		{id = 19236, cost = 100, races = {1, 3}},
		{id = 527, cost = 2000},
		{id = 600, cost = 2000, requiredIds = {592}},
		{id = 970, cost = 2000, requiredIds = {594}},
		{id = 19296, cost = 100, race = 4}
	},
	[20] = {
		{id = 9578, cost = 3000, requiredIds = {586}},
		{id = 2061, cost = 3000},
		{id = 19281, cost = 150, race = 8},
		{id = 14914, cost = 3000},
		{id = 7128, cost = 3000, requiredIds = {588}},
		{id = 453, cost = 3000},
		{id = 6075, cost = 3000, requiredIds = {6074}},
		{id = 9484, cost = 3000},
		{id = 19261, cost = 200, race = 5}
	},
	[22] = {
		{id = 2055, cost = 4000, requiredIds = {2054}},
		{id = 8103, cost = 4000, requiredIds = {8102}},
		{id = 2096, cost = 4000},
		{id = 2010, cost = 4000, requiredIds = {2006}},
		{id = 984, cost = 4000, requiredIds = {598}}
	},
	[24] = {
		{id = 15262, cost = 5000, requiredIds = {14914}},
		{id = 8129, cost = 5000},
		{id = 1245, cost = 5000, requiredIds = {1244}},
		{id = 3747, cost = 5000, requiredIds = {600}}
	},
	[26] = {
		{id = 19238, cost = 300, races = {1, 3}},
		{id = 9472, cost = 6000, requiredIds = {2061}},
		{id = 6076, cost = 6000, requiredIds = {6075}},
		{id = 992, cost = 6000, requiredIds = {970}},
		{id = 19299, cost = 300, race = 4, requiredIds = {19296}}
	},
	[28] = {
		{id = 19276, cost = 400, race = 5},
		{id = 6063, cost = 8000, requiredIds = {2055}},
		{id = 15430, cost = 400, requiredTalentId = 15237},
		{id = 8104, cost = 8000, requiredIds = {8103}},
		{id = 17311, cost = 400, requiredTalentId = 15407},
		{id = 8124, cost = 8000, requiredIds = {8122}},
		{id = 19308, cost = 400, race = 8}
	},
	[30] = {
		{id = 19289, cost = 500, race = 4},
		{id = 9579, cost = 10000, requiredIds = {9578}},
		{id = 19271, cost = 450, race = 1},
		{id = 19282, cost = 500, race = 8},
		{id = 15263, cost = 10000, requiredIds = {15262}},
		{id = 602, cost = 10000, requiredIds = {7128}},
		{id = 605, cost = 10000},
		{id = 6065, cost = 10000, requiredIds = {3747}},
		{id = 596, cost = 10000},
		{id = 976, cost = 10000},
		{id = 1004, cost = 10000, requiredIds = {984}},
		{id = 19262, cost = 500, race = 5}
	},
	[32] = {
		{id = 552, cost = 11000},
		{id = 9473, cost = 11000, requiredIds = {9472}},
		{id = 8131, cost = 11000, requiredIds = {8129}},
		{id = 6077, cost = 11000, requiredIds = {6076}}
	},
	[34] = {
		{id = 19240, cost = 600, races = {1, 3}},
		{id = 6064, cost = 12000, requiredIds = {6063}},
		{id = 1706, cost = 12000},
		{id = 8105, cost = 12000, requiredIds = {8104}},
		{id = 10880, cost = 12000, requiredIds = {2010}},
		{id = 2767, cost = 12000, requiredIds = {992}},
		{id = 19302, cost = 600, race = 4, requiredIds = {19299}}
	},
	[36] = {
		{id = 19277, cost = 700, race = 5},
		{id = 988, cost = 14000, requiredIds = {527}},
		{id = 15264, cost = 14000, requiredIds = {15263}},
		{id = 15431, cost = 700, requiredIds = {15430}, requiredTalentId = 15237},
		{id = 17312, cost = 700, requiredIds = {17311}, requiredTalentId = 15407},
		{id = 8192, cost = 14000, requiredIds = {453}},
		{id = 2791, cost = 14000, requiredIds = {1245}},
		{id = 6066, cost = 14000, requiredIds = {6065}},
		{id = 19309, cost = 700, race = 8}
	},
	[38] = {
		{id = 9474, cost = 16000, requiredIds = {9473}},
		{id = 6078, cost = 16000, requiredIds = {6077}},
		{id = 6060, cost = 16000, requiredIds = {1004}}
	},
	[40] = {
		{id = 14818, cost = 900, requiredTalentId = 14752},
		{id = 19291, cost = 900, race = 4, requiredIds = {19289}},
		{id = 9592, cost = 18000, requiredIds = {9579}},
		{id = 19273, cost = 810, race = 1},
		{id = 2060, cost = 18000},
		{id = 19283, cost = 900, race = 8},
		{id = 1006, cost = 18000, requiredIds = {602}},
		{id = 10874, cost = 18000, requiredIds = {8131}},
		{id = 8106, cost = 18000, requiredIds = {8105}},
		{id = 996, cost = 18000, requiredIds = {596}},
		{id = 9485, cost = 18000, requiredIds = {9484}},
		{id = 19264, cost = 900, race = 5}
	},
	[42] = {
		{id = 19241, cost = 1100, races = {1, 3}},
		{id = 15265, cost = 22000, requiredIds = {15264}},
		{id = 10898, cost = 22000, requiredIds = {6066}},
		{id = 10888, cost = 22000, requiredIds = {8124}},
		{id = 10957, cost = 22000, requiredIds = {976}},
		{id = 10892, cost = 22000, requiredIds = {2767}},
		{id = 19303, cost = 1100, race = 4, requiredIds = {19302}}
	},
	[44] = {
		{id = 19278, cost = 1200, race = 5},
		{id = 10915, cost = 24000, requiredIds = {9474}},
		{id = 27799, cost = 1200, requiredIds = {15431}, requiredTalentId = 15237},
		{id = 10911, cost = 24000, requiredIds = {605}},
		{id = 17313, cost = 1200, requiredIds = {17312}, requiredTalentId = 15407},
		{id = 10909, cost = 24000, requiredIds = {2096}},
		{id = 10927, cost = 24000, requiredIds = {6078}},
		{id = 19310, cost = 1000, race = 8}
	},
	[46] = {
		{id = 10963, cost = 26000, requiredIds = {2060}},
		{id = 10945, cost = 26000, requiredIds = {8106}},
		{id = 10881, cost = 26000, requiredIds = {10880}},
		{id = 10933, cost = 26000, requiredIds = {6060}}
	},
	[48] = {
		{id = 15266, cost = 28000, requiredIds = {15265}},
		{id = 10875, cost = 28000, requiredIds = {10874}},
		{id = 10937, cost = 28000, requiredIds = {2791}},
		{id = 10899, cost = 28000, requiredIds = {10898}}
	},
	[50] = {
		{id = 19242, cost = 1500, races = {1, 3}},
		{id = 14819, cost = 1500, requiredIds = {14818}, requiredTalentId = 14752},
		{id = 19292, cost = 1500, race = 4, requiredIds = {19291}},
		{id = 10941, cost = 30000, requiredIds = {9592}},
		{id = 10916, cost = 30000, requiredIds = {10915}},
		{id = 19284, cost = 1500, race = 8},
		{id = 10951, cost = 30000, requiredIds = {1006}},
		{id = 27870, cost = 1200, requiredTalentId = 724},
		{id = 10960, cost = 30000, requiredIds = {996}},
		{id = 10928, cost = 30000, requiredIds = {10927}},
		{id = 10893, cost = 30000, requiredIds = {10892}},
		{id = 19304, cost = 1500, race = 4, requiredIds = {19303}},
		{id = 19265, cost = 1500, race = 5}
	},
	[52] = {
		{id = 19279, cost = 1900, race = 5},
		{id = 10964, cost = 38000, requiredIds = {10963}},
		{id = 27800, cost = 1900, requiredIds = {27799}, requiredTalentId = 15237},
		{id = 10946, cost = 38000, requiredIds = {10945}},
		{id = 17314, cost = 1900, requiredIds = {17313}, requiredTalentId = 15407},
		{id = 10953, cost = 38000, requiredIds = {8192}},
		{id = 19311, cost = 1200, race = 8}
	},
	[54] = {
		{id = 15267, cost = 40000, requiredIds = {15266}},
		{id = 10900, cost = 40000, requiredIds = {10899}},
		{id = 10934, cost = 40000, requiredIds = {10933}}
	},
	[56] = {
		{id = 10917, cost = 42000, requiredIds = {10916}},
		{id = 10876, cost = 42000, requiredIds = {10875}},
		{id = 10890, cost = 42000, requiredIds = {10888}},
		{id = 10929, cost = 42000, requiredIds = {10928}},
		{id = 10958, cost = 42000, requiredIds = {10957}}
	},
	[58] = {
		{id = 19243, cost = 2200, races = {1, 3}},
		{id = 10965, cost = 44000, requiredIds = {10964}},
		{id = 10947, cost = 44000, requiredIds = {10946}},
		{id = 10912, cost = 44000, requiredIds = {10911}},
		{id = 20770, cost = 44000, requiredIds = {10881}},
		{id = 10894, cost = 44000, requiredIds = {10893}},
		{id = 19305, cost = 2200, race = 4, requiredIds = {19304}}
	},
	[60] = {
		{id = 19280, cost = 2300, race = 5},
		{id = 27841, cost = 2300, requiredIds = {14819}, requiredTalentId = 14752},
		{id = 19293, cost = 2070, race = 4, requiredIds = {19292}},
		{id = 10942, cost = 46000, requiredIds = {10941}},
		{id = 19285, cost = 2300, race = 8},
		{id = 15261, cost = 46000, requiredIds = {15267}},
		{id = 27801, cost = 2300, requiredIds = {27800}, requiredTalentId = 15237},
		{id = 10952, cost = 46000, requiredIds = {10951}},
		{id = 27871, cost = 1500, requiredIds = {27870}, requiredTalentId = 724},
		{id = 18807, cost = 2300, requiredIds = {17314}, requiredTalentId = 15407},
		{id = 10938, cost = 46000, requiredIds = {10937}},
		{id = 10901, cost = 46000, requiredIds = {10900}},
		{id = 10961, cost = 46000, requiredIds = {10960}},
		{id = 27681, cost = 2300, requiredIds = {27841}},
		{id = 10955, cost = 46000, requiredIds = {9485}},
		{id = 19312, cost = 2300, race = 8},
		{id = 19266, cost = 2070, race = 5}
	}
})
