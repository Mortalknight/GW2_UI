local _, GW = ...
if (GW.currentClass ~= "PALADIN") then
	return
end

-- Paladin Auras are special in that you never have multiple ranks in the spellbook, only the latest one is usable
-- Even so, IsSpellKnown will only return true for your current rank

-- These tables are ordered by rank

local devotionAura = {465, 10290, 643, 10291, 1032, 10292, 10293}
local retAura = {7294, 10298, 10299, 10300, 10301}
local fireResAura = {19891, 19899, 19900}
local frostResAura = {19888, 19897, 19898}
local shadowResAura = {19876, 19895, 19896}
local layOnHands = {633 --[[Rank 1]], 2800 --[[Rank 2]], 10310 --[[Rank 3]]}

--GW:SetPreviousAbilityMap({devotionAura, retAura, fireResAura, frostResAura, shadowResAura, layOnHands})

GW.SpellsByLevel = {
	[1] = {{id = 465, cost = 10}},
	[4] = {{id = 19740, cost = 100}, {id = 20271, cost = 100}},
	[6] = {{id = 498, cost = 100}, {id = 639, cost = 100, requiredIds = {635}}, {id = 21082, cost = 100}},
	[8] = {{id = 853, cost = 100}, {id = 3127, cost = 100}, {id = 1152, cost = 100}},
	[10] = {
		{id = 1022, cost = 300},
		{id = 10290, cost = 300, requiredIds = {465}},
		{id = 633, cost = 300},
		{id = 20287, cost = 300, requiredIds = {21084}}
	},
	[12] = {{id = 19834, cost = 1000, requiredIds = {19740}}, {id = 20162, cost = 1000, requiredIds = {21082}}, {id = 7328, cost = 0, requiredQuestIds = {1788, 1785}}},
	[14] = {{id = 19742, cost = 2000}, {id = 647, cost = 2000, requiredIds = {639}}},
	[16] = {{id = 7294, cost = 3000}, {id = 25780, cost = 3000}},
	[18] = {
		{id = 1044, cost = 3500},
		{id = 5573, cost = 3500, requiredIds = {498}},
		{id = 20288, cost = 3500, requiredIds = {20287}}
	},
	[20] = {{id = 643, cost = 4000, requiredIds = {10290}}, {id = 879, cost = 4000}, {id = 19750, cost = 4000}},
	[22] = {
		{id = 19835, cost = 4000, requiredIds = {19834}},
		{id = 19746, cost = 4000},
		{id = 1026, cost = 4000, requiredIds = {647}},
		{id = 20164, cost = 4000},
		{id = 20305, cost = 4000, requiredIds = {20162}}
	},
	[24] = {
		{id = 5599, cost = 5000, requiredIds = {1022}},
		{id = 19850, cost = 5000, requiredIds = {19742}},
		{id = 5588, cost = 5000, requiredIds = {853}},
		{id = 10322, cost = 5000, requiredIds = {7328}},
		{id = 2878, cost = 5000}
	},
	--[25] = {{id = 20375, cost = 0, requiredTalentId = 20375}}, --Talent
	[26] = {
		{id = 1038, cost = 6000},
		{id = 19939, cost = 6000, requiredIds = {19750}},
		{id = 10298, cost = 6000, requiredIds = {7294}},
		{id = 20289, cost = 6000, requiredIds = {20288}}
	},
	[28] = {{id = 5614, cost = 9000, requiredIds = {879}}, {id = 19876, cost = 9000}},
	[30] = {
		{id = 20116, cost = 200, requiredTalentId = 26573},
		{id = 10291, cost = 11000, requiredIds = {643}},
		{id = 19752, cost = 11000},
		{id = 1042, cost = 11000, requiredIds = {1026}},
		{id = 2800, cost = 11000, requiredIds = {633}},
		{id = 20915, cost = 200, requiredTalentId = 20375},
		{id = 20165, cost = 11000}
	},
	[32] = {
		{id = 19836, cost = 12000, requiredIds = {19835}},
		{id = 19888, cost = 12000},
		{id = 20306, cost = 12000, requiredIds = {20305}}
	},
	[34] = {
		{id = 19852, cost = 13000, requiredIds = {19850}},
		{id = 642, cost = 13000},
		{id = 19940, cost = 13000, requiredIds = {19939}},
		{id = 20290, cost = 13000, requiredIds = {20289}}
	},
	[36] = {
		{id = 5615, cost = 14000, requiredIds = {5614}},
		{id = 19891, cost = 14000},
		{id = 10324, cost = 14000, requiredIds = {10322}},
		{id = 10299, cost = 14000, requiredIds = {10298}}
	},
	[38] = {
		{id = 10278, cost = 16000, requiredIds = {5599}},
		{id = 3472, cost = 16000, requiredIds = {1042}},
		{id = 20166, cost = 16000},
		{id = 5627, cost = 16000, requiredIds = {2878}}
	},
	[40] = {
		{id = 19977, cost = 20000},
		{id = 20912, cost = 900, requiredTalentId = 20911},
		{id = 20922, cost = 1000, requiredIds = {20116}, requiredTalentId = 26573},
		{id = 1032, cost = 20000, requiredIds = {10291}},
		{id = 5589, cost = 20000, requiredIds = {5588}},
		--{id = 750, cost = 20000},
		{id = 20918, cost = 1000, requiredIds = {20915}, requiredTalentId = 20375},
		{id = 20347, cost = 20000, requiredIds = {20165}},
		{id = 19895, cost = 20000, requiredIds = {19876}}
	},
	[42] = {
		{id = 19837, cost = 21000, requiredIds = {19836}},
		{id = 4987, cost = 21000},
		{id = 19941, cost = 21000, requiredIds = {19940}},
		{id = 20291, cost = 21000, requiredIds = {20290}},
		{id = 20307, cost = 21000, requiredIds = {20306}}
	},
	[44] = {
		{id = 19853, cost = 22000, requiredIds = {19852}},
		{id = 10312, cost = 22000, requiredIds = {5615}},
		{id = 19897, cost = 22000, requiredIds = {19888}},
		{id = 24275, cost = 22000}
	},
	[46] = {
		{id = 6940, cost = 24000},
		{id = 10328, cost = 24000, requiredIds = {3472}},
		{id = 10300, cost = 24000, requiredIds = {10299}}
	},
	[48] = {
		{id = 19899, cost = 26000, requiredIds = {19891}},
		{id = 20929, cost = 1170, requiredTalentId = 20473},
		{id = 20772, cost = 26000, requiredIds = {10324}},
		{id = 20356, cost = 26000, requiredIds = {20166}}
	},
	[50] = {
		{id = 19978, cost = 28000, requiredIds = {19977}},
		{id = 20913, cost = 1260, requiredIds = {20912}, requiredTalentId = 20911},
		{id = 20923, cost = 1400, requiredIds = {20922}, requiredTalentId = 26573},
		{id = 10292, cost = 28000, requiredIds = {1032}},
		{id = 1020, cost = 28000, requiredIds = {642}},
		{id = 19942, cost = 28000, requiredIds = {19941}},
		{id = 20927, cost = 1260, requiredTalentId = 20925},
		{id = 2812, cost = 28000},
		{id = 10310, cost = 28000, requiredIds = {2800}},
		{id = 20919, cost = 1260, requiredIds = {20918}, requiredTalentId = 20375},
		{id = 20348, cost = 28000, requiredIds = {20347}},
		{id = 20292, cost = 28000, requiredIds = {20291}}
	},
	[52] = {
		{id = 19838, cost = 34000, requiredIds = {19837}},
		{id = 10313, cost = 34000, requiredIds = {10312}},
		{id = 25782, cost = 46000},
		{id = 24274, cost = 34000, requiredIds = {24275}},
		{id = 20308, cost = 34000, requiredIds = {20307}},
		{id = 19896, cost = 34000, requiredIds = {19895}},
		{id = 10326, cost = 34000, requiredIds = {5627}}
	},
	[54] = {
		{id = 20729, cost = 40000, requiredIds = {6940}},
		{id = 19854, cost = 40000, requiredIds = {19853}},
		{id = 25894, cost = 40000},
		{id = 10308, cost = 40000, requiredIds = {5589}},
		{id = 10329, cost = 40000, requiredIds = {10328}}
	},
	[56] = {
		{id = 19898, cost = 42000, requiredIds = {19897}},
		{id = 20930, cost = 2100, requiredIds = {20929}, requiredTalentId = 20473},
		{id = 10301, cost = 42000, requiredIds = {10300}}
	},
	[58] = {
		{id = 19943, cost = 44000, requiredIds = {19942}},
		{id = 20293, cost = 44000, requiredIds = {20292}},
		{id = 20357, cost = 44000, requiredIds = {20356}}
	},
	[60] = {
		{id = 19979, cost = 46000, requiredIds = {19978}},
		{id = 20914, cost = 2070, requiredIds = {20913}, requiredTalentId = 20911},
		{id = 20924, cost = 2300, requiredIds = {20923}, requiredTalentId = 26573},
		{id = 10293, cost = 46000, requiredIds = {10292}},
		{id = 10314, cost = 46000, requiredIds = {10313}},
		{id = 19900, cost = 46000, requiredIds = {19899}},
		{id = 25898, cost = 2070, requiredTalentId = 20217},
		{id = 25890, cost = 46000, requiredIds = {19979}},
		{id = 25916, cost = 41400, requiredIds = {25782}},
		{id = 25895, cost = 46000, requiredIds = {1038}},
		{id = 25899, cost = 2070, requiredIds = {20914}, requiredTalentId = 20911},
		{id = 25918, cost = 46000, requiredIds = {25894}},
		{id = 24239, cost = 46000, requiredIds = {24274}},
		{id = 20928, cost = 2070, requiredIds = {20927}, requiredTalentId = 20925},
		{id = 10318, cost = 46000, requiredIds = {2812}},
		{id = 20773, cost = 46000, requiredIds = {20772}},
		{id = 20920, cost = 2070, requiredIds = {20919}, requiredTalentId = 20375},
		{id = 20349, cost = 46000, requiredIds = {20348}}
	}
}
