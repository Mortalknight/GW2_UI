local _, GW = ...
if (GW.currentClass ~= "ROGUE") then
	return
end

-- ordered by rank
--[=====[ Generated with
$$('#tab-abilities .listview-mode-default .clickable tr td:nth-child(3)>div')
    .map(el=>({
        name: el.getElementsByTagName('a')[0].innerText,
        rank: el.getElementsByTagName('div')[0].innerText,
        id: el.getElementsByTagName('a')[0].href.split('=')[1]
    }))
    .sort((a,b)=>a.rank.localeCompare(b.rank))
    .map(s=>`${s.id} --[[${s.rank}]]`)
	.join(',')

or

$$('#search-listview .listview-mode-default .clickable tr td:nth-child(3)>div')
    .map(el=>({
        name: el.getElementsByTagName('a')[0].innerText,
        rank: el.getElementsByTagName('div')[0].innerText,
        id: el.getElementsByTagName('a')[0].href.split('=')[1]
    }))
    .sort((a,b)=>a.rank.localeCompare(b.rank))
    .map(s=>`${s.id} --[[${s.rank}]]`)
    .join(',')
--]=====]
local stealth = {1784 --[[Rank 1]], 1785 --[[Rank 2]], 1786 --[[Rank 3]], 1787 --[[Rank 4]]}
local backstab = {
	53 --[[Rank 1]],
	2589 --[[Rank 2]],
	2590 --[[Rank 3]],
	2591 --[[Rank 4]],
	8721 --[[Rank 5]],
	11279 --[[Rank 6]],
	11280 --[[Rank 7]],
	11281 --[[Rank 8]],
	25300 --[[Rank 9]]
}
local gouge = {1776 --[[Rank 1]], 1777 --[[Rank 2]], 8629 --[[Rank 3]], 11285 --[[Rank 4]], 11286 --[[Rank 5]]}
local sap = {6770 --[[Rank 1]], 2070 --[[Rank 2]], 11297 --[[Rank 3]]}
local garrote = {
	703 --[[Rank 1]],
	8631 --[[Rank 2]],
	8632 --[[Rank 3]],
	8633 --[[Rank 4]],
	11289 --[[Rank 5]],
	11290 --[[Rank 6]]
}
local feint = {1966 --[[Rank 1]], 6768 --[[Rank 2]], 8637 --[[Rank 3]], 11303 --[[Rank 4]], 25302 --[[Rank 5]]}
local rupture = {
	1943 --[[Rank 1]],
	8639 --[[Rank 2]],
	8640 --[[Rank 3]],
	11273 --[[Rank 4]],
	11274 --[[Rank 5]],
	11275 --[[Rank 6]]
}
local ambush = {
	8676 --[[Rank 1]],
	8724 --[[Rank 2]],
	8725 --[[Rank 3]],
	11267 --[[Rank 4]],
	11268 --[[Rank 5]],
	11269 --[[Rank 6]]
}
local exposeArmor = {8647 --[[Rank 1]], 8649 --[[Rank 2]], 8650 --[[Rank 3]], 11197 --[[Rank 4]], 11198 --[[Rank 5]]}
local kick = {1766 --[[Rank 1]], 1767 --[[Rank 2]], 1768 --[[Rank 3]], 1769 --[[Rank 4]]}
local cripplingPoison = {3420 --[[Rank 1]], 3421 --[[Rank 2]]}
local mindNumbingPoison = {5763 --[[Rank 1]], 8694 --[[Rank 2]], 11400 --[[Rank 3]]}
local instantPoiston = {
	8681 --[[Rank 1]],
	8687 --[[Rank 2]],
	8691 --[[Rank 3]],
	11341 --[[Rank 4]],
	11342 --[[Rank 5]],
	11343 --[[Rank 6]]
}
local deadlyPoison = {2835 --[[Rank 1]], 2837 --[[Rank 2]], 11357 --[[Rank 3]], 11358 --[[Rank 4]], 25347 --[[Rank 5]]}
local sinisterStrike = {
	1752 --[[Rank 1]],
	1757 --[[Rank 2]],
	1758 --[[Rank 3]],
	1759 --[[Rank 4]],
	1760 --[[Rank 5]],
	8621 --[[Rank 6]],
	11293 --[[Rank 7]],
	11294 --[[Rank 8]]
}
local eviscerate = {
	2098 --[[Rank 1]],
	6760 --[[Rank 2]],
	6761 --[[Rank 3]],
	6762 --[[Rank 4]],
	8623 --[[Rank 5]],
	8624 --[[Rank 6]],
	11299 --[[Rank 7]],
	11300 --[[Rank 8]],
	31016 --[[Rank 9]]
}
local sprint = {2983 --[[Rank 1]], 8696 --[[Rank 2]], 11305 --[[Rank 3]]}
local sliceAndDice = {5171 --[[Rank 1]], 6774 --[[Rank 2]]}
local vanish = {1856 --[[Rank 1]], 1857 --[[Rank 2]]}
--[[
GW:SetPreviousAbilityMap(
	{
		stealth,
		backstab,
		gouge,
		sap,
		garrote,
		feint,
		rupture,
		ambush,
		exposeArmor,
		kick,
		cripplingPoison,
		mindNumbingPoison,
		instantPoiston,
		deadlyPoison,
		sinisterStrike,
		eviscerate,
		sprint,
		sliceAndDice,
		vanish
	}
)
]]
GW.SpellsByLevel = {
	[1] = {{id = 1784, cost = 10}},
	[4] = {{id = 53, cost = 100}, {id = 921, cost = 100}},
	[6] = {{id = 1776, cost = 100}, {id = 1757, cost = 100, requiredIds = {1752}}},
	[8] = {{id = 5277, cost = 200}, {id = 6760, cost = 200, requiredIds = {2098}}},
	[10] = {{id = 674, cost = 300}, {id = 6770, cost = 300}, {id = 5171, cost = 300}, {id = 2983, cost = 300}},
	[12] = {{id = 2589, cost = 800, requiredIds = {53}}, {id = 1766, cost = 800}, {id = 3127, cost = 800}},
	[14] = {{id = 8647, cost = 1200}, {id = 703, cost = 1200}, {id = 1758, cost = 1200, requiredIds = {1757}}},
	[16] = {{id = 6761, cost = 1800, requiredIds = {6760}}, {id = 1966, cost = 1800}, {id = 1804, cost = 1800}},
	[18] = {{id = 8676, cost = 2900}, {id = 1777, cost = 2900, requiredIds = {1776}}},
	[20] = {
		{id = 2590, cost = 3000, requiredIds = {2589}},
		{id = 3420, cost = 3000, skills = {{skill = 40, level = 1}}},
		{id = 1943, cost = 3000},
		{id = 1785, cost = 3000, requiredIds = {1784}}
	},
	[22] = {
		{id = 1725, cost = 4000},
		{id = 8631, cost = 4000, requiredIds = {703}},
		{id = 1759, cost = 4000, requiredIds = {1758}},
		{id = 1856, cost = 4000, requiredIds = {1784}}
	},
	[24] = {
		{id = 2836, cost = 5000},
		{id = 6762, cost = 5000, requiredIds = {6761}},
		{id = 5763, cost = 5000, skills = {{skill = 40, level = 100}}}
	},
	[26] = {
		{id = 8724, cost = 6000, requiredIds = {8676}},
		{id = 1833, cost = 6000},
		{id = 8649, cost = 6000, requiredIds = {8647}},
		{id = 1767, cost = 6000, requiredIds = {1766}}
	},
	[28] = {
		{id = 2591, cost = 8000, requiredIds = {2590}},
		{id = 6768, cost = 8000, requiredIds = {1966}},
		{id = 8687, cost = 8000, skills = {{skill = 40, level = 120}}},
		{id = 8639, cost = 8000, requiredIds = {1943}},
		{id = 2070, cost = 8000, requiredIds = {6770}}
	},
	[30] = {
		{id = 2835, cost = 10000, skills = {{skill = 40, level = 130}}},
		{id = 1842, cost = 10000, requiredIds = {2836}},
		{id = 8632, cost = 10000, requiredIds = {8631}},
		{id = 408, cost = 10000},
		{id = 1760, cost = 10000, requiredIds = {1759}}
	},
	[32] = {
		{id = 8623, cost = 12000, requiredIds = {6762}},
		{id = 8629, cost = 12000, requiredIds = {1777}},
		{id = 13220, cost = 12000, skills = {{skill = 40, level = 140}}}
	},
	[34] = {
		{id = 8725, cost = 14000, requiredIds = {8724}},
		{id = 2094, cost = 14000, skills = {{skill = 40, level = 1}}},
		{id = 6510, cost = 14000, skills = {{skill = 40, level = 150}}},
		{id = 8696, cost = 14000, requiredIds = {2983}}
	},
	[36] = {
		{id = 8721, cost = 16000, requiredIds = {2591}},
		{id = 8650, cost = 16000, requiredIds = {8649}},
		{id = 8691, cost = 16000, skills = {{skill = 40, level = 160}}},
		{id = 8640, cost = 16000, requiredIds = {8639}}
	},
	[38] = {
		{id = 2837, cost = 18000, skills = {{skill = 40, level = 170}}},
		{id = 8633, cost = 18000, requiredIds = {8632}},
		{id = 8694, cost = 18000, skills = {{skill = 40, level = 170}}},
		{id = 8621, cost = 18000, requiredIds = {1760}}
	},
	[40] = {
		{id = 8624, cost = 20000, requiredIds = {8623}},
		{id = 8637, cost = 20000, requiredIds = {6768}},
		{id = 1860, cost = 20000},
		{id = 1786, cost = 20000, requiredIds = {1785}},
		{id = 13228, cost = 20000, skills = {{skill = 40, level = 180}}}
	},
	[42] = {
		{id = 11267, cost = 27000, requiredIds = {8725}},
		{id = 1768, cost = 27000, requiredIds = {1767}},
		{id = 6774, cost = 27000, requiredIds = {5171}},
		{id = 1857, cost = 27000, requiredIds = {1856}}
	},
	[44] = {
		{id = 11279, cost = 29000, requiredIds = {8721}},
		{id = 11341, cost = 29000, skills = {{skill = 40, level = 200}}},
		{id = 11273, cost = 29000, requiredIds = {8640}}
	},
	[46] = {
		{id = 11357, cost = 31000, skills = {{skill = 40, level = 210}}},
		{id = 11197, cost = 31000, requiredIds = {8650}},
		{id = 11289, cost = 31000, requiredIds = {8633}},
		{id = 11285, cost = 31000, requiredIds = {8629}},
		{id = 17347, cost = 7750, requiredIds = {16511}},
		{id = 11293, cost = 31000, requiredIds = {8621}}
	},
	[48] = {
		{id = 11299, cost = 33000, requiredIds = {8624}},
		{id = 11297, cost = 33000, requiredIds = {2070}},
		{id = 13229, cost = 33000, skills = {{skill = 40, level = 220}}}
	},
	[50] = {
		{id = 11268, cost = 35000, requiredIds = {11267}},
		{id = 3421, cost = 35000, skills = {{skill = 40, level = 230}}},
		{id = 8643, cost = 35000, requiredIds = {408}}
	},
	[52] = {
		{id = 11280, cost = 46000, requiredIds = {11279}},
		{id = 11303, cost = 46000, requiredIds = {8637}},
		{id = 11342, cost = 46000, skills = {{skill = 40, level = 240}}},
		{id = 11400, cost = 46000, skills = {{skill = 40, level = 240}}},
		{id = 11274, cost = 46000, requiredIds = {11273}}
	},
	[54] = {
		{id = 11358, cost = 48000, skills = {{skill = 40, level = 250}}},
		{id = 11290, cost = 48000, requiredIds = {11289}},
		{id = 11294, cost = 48000, requiredIds = {11293}}
	},
	[56] = {
		{id = 11300, cost = 50000, requiredIds = {11299}},
		{id = 11198, cost = 50000, requiredIds = {11197}},
		{id = 13230, cost = 50000, skills = {{skill = 40, level = 260}}}
	},
	[58] = {
		{id = 11269, cost = 52000, requiredIds = {11268}},
		{id = 17348, cost = 13000, requiredIds = {17347}},
		{id = 1769, cost = 52000, requiredIds = {1768}},
		{id = 11305, cost = 52000, requiredIds = {8696}}
	},
	[60] = {
		{id = 11281, cost = 54000, requiredIds = {11280}},
		{id = 11286, cost = 54000, requiredIds = {11285}},
		{id = 11343, cost = 54000, skills = {{skill = 40, level = 280}}},
		{id = 11275, cost = 54000, requiredIds = {11274}},
		{id = 1787, cost = 54000, requiredIds = {1786}}
	}
}
