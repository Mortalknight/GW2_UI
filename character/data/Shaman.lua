local _, GW = ...
if (GW.currentClass ~= "SHAMAN") then
	return
end
GW.SpellsByLevel = {
	[1] = {{id = 8017, cost = 10}},
	[4] = {{id = 8042, cost = 100}},
	[6] = {{id = 2484, cost = 100}, {id = 332, cost = 100, requiredIds = {331}}},
	[8] = {
		{id = 8044, cost = 100, requiredIds = {8042}},
		{id = 529, cost = 100, requiredIds = {403}},
		{id = 324, cost = 100},
		{id = 8018, cost = 100, requiredIds = {8017}},
		{id = 5730, cost = 100}
	},
	[10] = {{id = 8050, cost = 400}, {id = 8024, cost = 400}, {id = 8075, cost = 400}},
	[12] = {
		{id = 2008, cost = 800},
		{id = 1535, cost = 800},
		{id = 547, cost = 800, requiredIds = {332}},
		{id = 370, cost = 720}
	},
	[14] = {
		{id = 8045, cost = 900, requiredIds = {8044}},
		{id = 548, cost = 900, requiredIds = {529}},
		{id = 8154, cost = 900}
	},
	[16] = {
		{id = 526, cost = 1800},
		{id = 325, cost = 1800, requiredIds = {324}},
		{id = 8019, cost = 1800, requiredIds = {8018}}
	},
	[18] = {
		{id = 8052, cost = 2000, requiredIds = {8050}},
		{id = 8027, cost = 2000, requiredIds = {8024}},
		{id = 913, cost = 2000, requiredIds = {547}},
		{id = 6390, cost = 2000, requiredIds = {5730}},
		{id = 8143, cost = 2000}
	},
	[20] = {
		{id = 8056, cost = 2200},
		{id = 8033, cost = 2200},
		{id = 2645, cost = 2200},
		{id = 8004, cost = 2200},
		{id = 915, cost = 2200, requiredIds = {548}},
		{id = 6363, cost = 2200}
	},
	[22] = {
		{id = 8498, cost = 3000, requiredIds = {1535}},
		{id = 8166, cost = 3000},
		{id = 131, cost = 3000},
		{id = 2870, cost = 900}
	},
	[24] = {
		{id = 20609, cost = 3500, requiredIds = {2008}},
		{id = 8046, cost = 3500, requiredIds = {8045}},
		{id = 8181, cost = 3500},
		{id = 939, cost = 3500, requiredIds = {913}},
		{id = 905, cost = 3500, requiredIds = {325}},
		{id = 10399, cost = 3500, requiredIds = {8019}},
		{id = 8155, cost = 3500, requiredIds = {8154}},
		{id = 8160, cost = 3500, requiredIds = {8075}}
	},
	[26] = {
		{id = 6196, cost = 4000},
		{id = 8030, cost = 4000, requiredIds = {8027}},
		{id = 943, cost = 4000, requiredIds = {915}},
		{id = 8190, cost = 4000},
		{id = 5675, cost = 4000}
	},
	[28] = {
		{id = 8184, cost = 6000},
		{id = 8053, cost = 6000, requiredIds = {8052}},
		{id = 8227, cost = 6000},
		{id = 8038, cost = 6000, requiredIds = {8033}},
		{id = 8008, cost = 6000, requiredIds = {8004}},
		{id = 6391, cost = 6000, requiredIds = {6390}},
		{id = 546, cost = 6000}
	},
	[30] = {
		{id = 556, cost = 7000},
		{id = 8177, cost = 7000},
		{id = 6375, cost = 7000},
		{id = 10595, cost = 7000},
		{id = 20608, cost = 7000},
		{id = 6364, cost = 7000, requiredIds = {6363}},
		{id = 8232, cost = 7000}
	},
	[32] = {
		{id = 421, cost = 8000},
		{id = 8499, cost = 8000, requiredIds = {8498}},
		{id = 959, cost = 8000, requiredIds = {939}},
		{id = 6041, cost = 8000, requiredIds = {943}},
		{id = 945, cost = 8000, requiredIds = {905}},
		{id = 8012, cost = 7200, requiredIds = {370}},
		{id = 8512, cost = 8000}
	},
	[34] = {
		{id = 8058, cost = 9000, requiredIds = {8056}},
		{id = 16314, cost = 9000, requiredIds = {10399}},
		{id = 6495, cost = 9000},
		{id = 10406, cost = 9000, requiredIds = {8155}}
	},
	[36] = {
		{id = 20610, cost = 10000, requiredIds = {20609}},
		{id = 10412, cost = 10000, requiredIds = {8046}},
		{id = 16339, cost = 10000, requiredIds = {8030}},
		{id = 8010, cost = 10000, requiredIds = {8008}},
		{id = 10585, cost = 10000, requiredIds = {8190}},
		{id = 10495, cost = 10000, requiredIds = {5675}},
		{id = 15107, cost = 10000}
	},
	[38] = {
		{id = 8170, cost = 11000},
		{id = 8249, cost = 11000, requiredIds = {8227}},
		{id = 10478, cost = 11000, requiredIds = {8181}},
		{id = 10456, cost = 11000, requiredIds = {8038}},
		{id = 10391, cost = 11000, requiredIds = {6041}},
		{id = 6392, cost = 11000, requiredIds = {6391}},
		{id = 8161, cost = 11000, requiredIds = {8160}}
	},
	[40] = {
		{id = 1064, cost = 12000},
		{id = 930, cost = 12000, requiredIds = {421}},
		{id = 10447, cost = 12000, requiredIds = {8053}},
		{id = 6377, cost = 12000, requiredIds = {6375}},
		{id = 8005, cost = 12000, requiredIds = {959}},
		{id = 8134, cost = 12000, requiredIds = {945}},
		--{id = 8737, cost = 12000},
		{id = 6365, cost = 12000, requiredIds = {6364}},
		{id = 8235, cost = 12000, requiredIds = {8232}}
	},
	[42] = {
		{id = 11314, cost = 16000, requiredIds = {8499}},
		{id = 10537, cost = 16000, requiredIds = {8184}},
		{id = 8835, cost = 16000},
		{id = 10613, cost = 16000, requiredIds = {8512}}
	},
	[44] = {
		{id = 10466, cost = 18000, requiredIds = {8010}},
		{id = 10392, cost = 18000, requiredIds = {10391}},
		{id = 10600, cost = 18000, requiredIds = {10595}},
		{id = 16315, cost = 18000, requiredIds = {16314}},
		{id = 10407, cost = 18000, requiredIds = {10406}}
	},
	[46] = {
		{id = 10622, cost = 20000, requiredIds = {1064}},
		{id = 16341, cost = 20000, requiredIds = {16339}},
		{id = 10472, cost = 20000, requiredIds = {8058}},
		{id = 10586, cost = 20000, requiredIds = {10585}},
		{id = 10496, cost = 20000, requiredIds = {10495}},
		{id = 15111, cost = 20000, requiredIds = {15107}}
	},
	[48] = {
		{id = 20776, cost = 22000, requiredIds = {20610}},
		{id = 2860, cost = 22000, requiredIds = {930}},
		{id = 10413, cost = 22000, requiredIds = {10412}},
		{id = 10526, cost = 22000, requiredIds = {8249}},
		{id = 16355, cost = 22000, requiredIds = {10456}},
		{id = 10395, cost = 22000, requiredIds = {8005}},
		{id = 10431, cost = 22000, requiredIds = {8134}},
		{id = 17354, cost = 55000},
		{id = 10427, cost = 22000, requiredIds = {6392}}
	},
	[50] = {
		{id = 10462, cost = 24000, requiredIds = {6377}},
		{id = 15207, cost = 24000, requiredIds = {10392}},
		{id = 10437, cost = 24000, requiredIds = {6365}},
		{id = 25908, cost = 24000},
		{id = 10486, cost = 24000, requiredIds = {8235}}
	},
	[52] = {
		{id = 11315, cost = 27000, requiredIds = {11314}},
		{id = 10448, cost = 27000, requiredIds = {10447}},
		{id = 10467, cost = 27000, requiredIds = {10466}},
		{id = 10442, cost = 27000, requiredIds = {8161}},
		{id = 10614, cost = 27000, requiredIds = {10613}}
	},
	[54] = {
		{id = 10623, cost = 29000, requiredIds = {10622}},
		{id = 10479, cost = 29000, requiredIds = {10478}},
		{id = 16316, cost = 29000, requiredIds = {16315}},
		{id = 10408, cost = 29000, requiredIds = {10407}}
	},
	[56] = {
		{id = 10605, cost = 30000, requiredIds = {2860}},
		{id = 16342, cost = 30000, requiredIds = {16341}},
		{id = 10627, cost = 30000, requiredIds = {8835}},
		{id = 10396, cost = 30000, requiredIds = {10395}},
		{id = 15208, cost = 30000, requiredIds = {15207}},
		{id = 10432, cost = 30000, requiredIds = {10431}},
		{id = 10587, cost = 30000, requiredIds = {10586}},
		{id = 10497, cost = 30000, requiredIds = {10496}},
		{id = 15112, cost = 30000, requiredIds = {15111}}
	},
	[58] = {
		{id = 10538, cost = 32000, requiredIds = {10537}},
		{id = 16387, cost = 32000, requiredIds = {10526}},
		{id = 10473, cost = 32000, requiredIds = {10472}},
		{id = 16356, cost = 32000, requiredIds = {16355}},
		{id = 17359, cost = 80000, requiredIds = {17354}},
		{id = 10428, cost = 32000, requiredIds = {10427}}
	},
	[60] = {
		{id = 20777, cost = 34000, requiredIds = {20776}},
		{id = 10414, cost = 34000, requiredIds = {10413}},
		{id = 10463, cost = 34000, requiredIds = {10462}},
		{id = 10468, cost = 34000, requiredIds = {10467}},
		{id = 10601, cost = 34000, requiredIds = {10600}},
		{id = 10438, cost = 34000, requiredIds = {10437}},
		{id = 16362, cost = 34000, requiredIds = {10486}}
	}
}
