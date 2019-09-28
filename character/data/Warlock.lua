local _, GW = ...
if (GW.currentClass ~= "WARLOCK") then
	return
end
GW.TomesByLevel = {
	[4] = {{id = 16321, cost = 100}},
	[8] = {{id = 16302, cost = 100}},
	[12] = {{id = 16331, cost = 600}},
	[14] = {{id = 16322, cost = 900}, {id = 16326, cost = 900}},
	[16] = {{id = 16351, cost = 1200}},
	[18] = {{id = 16316, cost = 1500}, {id = 16357, cost = 1500}},
	[20] = {{id = 16346, cost = 2000}},
	[22] = {{id = 16375, cost = 2500}},
	[24] = {{id = 16327, cost = 3000}, {id = 16352, cost = 3000}, {id = 16363, cost = 3000}},
	[26] = {{id = 16323, cost = 4000}, {id = 16358, cost = 4000}, {id = 16379, cost = 4000}},
	[28] = {{id = 16317, cost = 5000}, {id = 16368, cost = 5000}},
	[30] = {{id = 16347, cost = 6000}},
	[32] = {{id = 16353, cost = 7000}, {id = 16380, cost = 7000}, {id = 16384, cost = 7000}},
	[34] = {{id = 16328, cost = 8000}, {id = 16359, cost = 8000}, {id = 16376, cost = 8000}},
	[36] = {{id = 16364, cost = 9000}, {id = 16371, cost = 9000}, {id = 16388, cost = 9000}},
	[38] = {{id = 16318, cost = 10000}, {id = 16324, cost = 10000}, {id = 16381, cost = 10000}},
	[40] = {{id = 16348, cost = 11000}, {id = 16354, cost = 11000}, {id = 16385, cost = 11000}},
	[42] = {{id = 16360, cost = 11000}, {id = 16390, cost = 11000}},
	[44] = {{id = 16329, cost = 12000}, {id = 16372, cost = 12000}},
	[46] = {{id = 16377, cost = 13000}, {id = 16382, cost = 13000}},
	[48] = {{id = 16319, cost = 14000}, {id = 16355, cost = 14000}, {id = 16365, cost = 14000}, {id = 16386, cost = 14000}},
	[50] = {{id = 16325, cost = 15000}, {id = 16349, cost = 15000}, {id = 16361, cost = 15000}},
	[52] = {{id = 16373, cost = 18000}, {id = 16389, cost = 18000}},
	[54] = {{id = 16330, cost = 20000}, {id = 16383, cost = 20000}},
	[56] = {{id = 16356, cost = 22000}, {id = 16387, cost = 22000}},
	[58] = {{id = 16320, cost = 24000}, {id = 16362, cost = 24000}, {id = 16378, cost = 24000}},
	[60] = {{id = 16350, cost = 26000}, {id = 16366, cost = 26000}, {id = 16374, cost = 26000}}
}
GW.SpellsByLevel = {
	[1] = {{id = 348, cost = 10}},
	[4] = {{id = 172, cost = 100}, {id = 702, cost = 100}},
	[6] = {{id = 1454, cost = 100}, {id = 695, cost = 100, requiredIds = {686}}},
	[8] = {{id = 980, cost = 200}, {id = 5782, cost = 200}},
	[10] = {
		{id = 6201, cost = 300},
		{id = 696, cost = 300, requiredIds = {687}},
		{id = 1120, cost = 300},
		{id = 707, cost = 300, requiredIds = {348}}
	},
	[12] = {
		{id = 1108, cost = 600, requiredIds = {702}},
		{id = 755, cost = 600},
		{id = 705, cost = 600, requiredIds = {695}}
	},
	[14] = {{id = 6222, cost = 900, requiredIds = {172}}, {id = 704, cost = 900}, {id = 689, cost = 900}},
	[16] = {{id = 1455, cost = 1200, requiredIds = {1454}}, {id = 5697, cost = 1200}},
	[18] = {
		{id = 693, cost = 1500},
		{id = 1014, cost = 1500, requiredIds = {980}},
		{id = 5676, cost = 1500}
	},
	[20] = {
		{id = 706, cost = 2000},
		{id = 3698, cost = 2000, requiredIds = {755}},
		{id = 1094, cost = 2000, requiredIds = {707}},
		{id = 5740, cost = 2000},
		{id = 698, cost = 2000},
		{id = 1088, cost = 2000, requiredIds = {705}}
	},
	[22] = {
		{id = 6202, cost = 2500, requiredIds = {6201}},
		{id = 6205, cost = 2500, requiredIds = {1108}},
		{id = 699, cost = 2500, requiredIds = {689}},
		{id = 126, cost = 2500}
	},
	[24] = {
		{id = 6223, cost = 3000, requiredIds = {6222}},
		{id = 5138, cost = 3000},
		{id = 8288, cost = 3000, requiredIds = {1120}},
		{id = 5500, cost = 3000},
		{id = 18867, cost = 150, requiredTalentId = 17877}
	},
	[26] = {
		{id = 1714, cost = 4000},
		{id = 132, cost = 4000},
		{id = 1456, cost = 4000, requiredIds = {1455}},
		{id = 17919, cost = 4000, requiredIds = {5676}}
	},
	[28] = {
		{id = 710, cost = 5000},
		{id = 6366, cost = 5000},
		{id = 6217, cost = 5000, requiredIds = {1014}},
		{id = 7658, cost = 5000, requiredIds = {704}},
		{id = 3699, cost = 5000, requiredIds = {3698}},
		{id = 1106, cost = 5000, requiredIds = {1088}}
	},
	[30] = {
		{id = 20752, cost = 6000, requiredIds = {693}},
		{id = 1086, cost = 6000, requiredIds = {706}},
		{id = 709, cost = 6000, requiredIds = {699}},
		{id = 1098, cost = 6000},
		{id = 1949, cost = 6000},
		{id = 2941, cost = 6000, requiredIds = {1094}}
	},
	[32] = {
		{id = 7646, cost = 7000, requiredIds = {6205}},
		{id = 1490, cost = 7000},
		{id = 6213, cost = 7000, requiredIds = {5782}},
		{id = 6229, cost = 7000},
		{id = 18868, cost = 350, requiredIds = {18867}, requiredTalentId = 17877}
	},
	[34] = {
		{id = 7648, cost = 8000, requiredIds = {6223}},
		{id = 5699, cost = 8000, requiredIds = {6202}},
		{id = 6226, cost = 8000, requiredIds = {5138}},
		{id = 6219, cost = 8000, requiredIds = {5740}},
		{id = 17920, cost = 8000, requiredIds = {17919}}
	},
	[36] = {
		{id = 17951, cost = 9000, requiredIds = {6366}},
		{id = 2362, cost = 9000},
		{id = 3700, cost = 9000, requiredIds = {3699}},
		{id = 11687, cost = 9000, requiredIds = {1456}},
		{id = 7641, cost = 9000, requiredIds = {1106}}
	},
	[38] = {
		{id = 11711, cost = 10000, requiredIds = {6217}},
		{id = 2970, cost = 10000, requiredIds = {132}},
		{id = 7651, cost = 10000, requiredIds = {709}},
		{id = 8289, cost = 10000, requiredIds = {8288}},
		{id = 18879, cost = 500, requiredTalentId = 18265}
	},
	[40] = {
		{id = 20755, cost = 11000, requiredIds = {20752}},
		{id = 11733, cost = 11000, requiredIds = {1086}},
		{id = 5484, cost = 11000},
		{id = 11665, cost = 11000, requiredIds = {2941}},
		{id = 18869, cost = 550, requiredIds = {18868}, requiredTalentId = 17877}
	},
	[42] = {
		{id = 7659, cost = 11000, requiredIds = {7658}},
		{id = 11707, cost = 11000, requiredIds = {7646}},
		{id = 6789, cost = 11000},
		{id = 11683, cost = 9900, requiredIds = {1949}},
		{id = 17921, cost = 11000, requiredIds = {17920}},
		{id = 11739, cost = 11000, requiredIds = {6229}}
	},
	[44] = {
		{id = 11671, cost = 12000, requiredIds = {7648}},
		{id = 17862, cost = 12000},
		{id = 11703, cost = 12000, requiredIds = {6226}},
		{id = 11725, cost = 12000, requiredIds = {1098}},
		{id = 11693, cost = 12000, requiredIds = {3700}},
		{id = 11659, cost = 12000, requiredIds = {7641}}
	},
	[46] = {
		{id = 18647, cost = 13000, requiredIds = {710}},
		{id = 17952, cost = 13000, requiredIds = {17951}},
		{id = 11729, cost = 13000, requiredIds = {5699}},
		{id = 11721, cost = 13000, requiredIds = {1490}},
		{id = 11699, cost = 13000, requiredIds = {7651}},
		{id = 11688, cost = 13000, requiredIds = {11687}},
		{id = 11677, cost = 13000, requiredIds = {6219}}
	},
	[48] = {
		{id = 18930, cost = 700, requiredTalentId = 17962},
		{id = 17727, cost = 14000},
		{id = 11712, cost = 14000, requiredIds = {11711}},
		{id = 18870, cost = 700, requiredIds = {18869}, requiredTalentId = 17877},
		{id = 18880, cost = 700, requiredIds = {18879}, requiredTalentId = 18265},
		{id = 6353, cost = 14000}
	},
	[50] = {
		{id = 20756, cost = 15000, requiredIds = {20755}},
		{id = 11719, cost = 15000, requiredIds = {1714}},
		{id = 18937, cost = 750, requiredTalentId = 18220},
		{id = 17925, cost = 15000, requiredIds = {6789}},
		{id = 11734, cost = 15000, requiredIds = {11733}},
		{id = 11743, cost = 15000, requiredIds = {2970}},
		{id = 11667, cost = 15000, requiredIds = {11665}},
		{id = 17922, cost = 15000, requiredIds = {17921}}
	},
	[52] = {
		{id = 11708, cost = 18000, requiredIds = {11707}},
		{id = 11675, cost = 18000, requiredIds = {8289}},
		{id = 11694, cost = 18000, requiredIds = {11693}},
		{id = 11660, cost = 18000, requiredIds = {11659}},
		{id = 11740, cost = 18000, requiredIds = {11739}}
	},
	[54] = {
		{id = 18931, cost = 1000, requiredIds = {18930}, requiredTalentId = 17962},
		{id = 11672, cost = 20000, requiredIds = {11671}},
		{id = 11700, cost = 20000, requiredIds = {11699}},
		{id = 11704, cost = 20000, requiredIds = {11703}},
		{id = 11684, cost = 18000, requiredIds = {11683}},
		{id = 17928, cost = 20000, requiredIds = {5484}}
	},
	[56] = {
		{id = 17953, cost = 22000, requiredIds = {17952}},
		{id = 11717, cost = 22000, requiredIds = {7659}},
		{id = 17937, cost = 22000, requiredIds = {17862}},
		{id = 6215, cost = 22000, requiredIds = {6213}},
		{id = 11689, cost = 22000, requiredIds = {11688}},
		{id = 18871, cost = 22000, requiredIds = {18870}, requiredTalentId = 17877},
		{id = 17924, cost = 22000, requiredIds = {6353}}
	},
	[58] = {
		{id = 11730, cost = 24000, requiredIds = {11730}},
		{id = 11713, cost = 24000, requiredIds = {11712}},
		{id = 17926, cost = 24000, requiredIds = {17925}},
		{id = 11726, cost = 24000, requiredIds = {11725}},
		{id = 11678, cost = 24000, requiredIds = {11677}},
		{id = 17923, cost = 24000, requiredIds = {17922}},
		{id = 18881, cost = 1200, requiredIds = {18880}, requiredTalentId = 18265}
	},
	[60] = {
		{id = 18932, cost = 1300, requiredIds = {18931}, requiredTalentId = 17962},
		{id = 20757, cost = 26000, requiredIds = {20756}},
		{id = 17728, cost = 26000, requiredIds = {17727}},
		{id = 603, cost = 26000},
		{id = 11722, cost = 26000, requiredIds = {11721}},
		{id = 18938, cost = 1300, requiredIds = {18937}, requiredTalentId = 18220},
		{id = 11735, cost = 26000, requiredIds = {11734}},
		{id = 11695, cost = 26000, requiredIds = {11694}},
		{id = 11668, cost = 26000, requiredIds = {11667}},
		{id = 11661, cost = 26000, requiredIds = {11660}}
	}
}
