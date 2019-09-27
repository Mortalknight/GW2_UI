local _, GW = ...
if (GW.currentClass ~= "HUNTER") then
  return
end
local petSpells = {
  24493,
  24497,
  24500,
  24501,
  23992,
  24439,
  24444,
  24445,
  24446,
  24447,
  24448,
  24449,
  4187,
  5042,
  4188,
  4189,
  4190,
  4191,
  4192,
  4193,
  4194,
  5041,
  2649,
  14916,
  14917,
  14918,
  14919,
  14920,
  14921,
  24545,
  24630,
  24549,
  24550,
  24551,
  24552,
  24553,
  24554,
  24555,
  24629,
  24492,
  24502,
  24503,
  24504,
  24488,
  24505,
  24506,
  24507
}
local petSpellMap = {}
for _, v in ipairs(petSpells) do
  petSpellMap[v] = true
end
function GW.IsPetSpell(spellId)
  return petSpellMap[spellId] == true
end

GW.SpellsByLevel = {
  [1] = {{id = 1494, cost = 10}},
  [4] = {{id = 13163, cost = 100}, {id = 1978, cost = 100}},
  [6] = {{id = 3044, cost = 100}, {id = 1130, cost = 100}},
  [8] = {{id = 5116, cost = 200}, {id = 3127, cost = 200}, {id = 14260, cost = 200}},
  [10] = {
    {id = 13165, cost = 400},
    {id = 4187, cost = 10},
    {id = 24545, cost = 10},
    {id = 13549, cost = 400, requiredIds = {1978}},
    {id = 19883, cost = 400}
  },
  [12] = {
    {id = 14281, cost = 600, requiredIds = {3044}},
    {id = 20736, cost = 600},
    {id = 4188, cost = 120},
    {id = 136, cost = 600, requiredIds = {1515}},
    {id = 24549, cost = 120},
    {id = 2974, cost = 600}
  },
  [14] = {{id = 6197, cost = 1200}, {id = 1002, cost = 1200}, {id = 1513, cost = 1200}},
  [16] = {{id = 13795, cost = 1800}, {id = 1495, cost = 1800}, {id = 14261, cost = 1800, requiredIds = {14260}}},
  [18] = {
    {id = 14318, cost = 2000, requiredIds = {13165}},
    {id = 4189, cost = 400},
    {id = 2643, cost = 2000},
    {id = 24550, cost = 400},
    {id = 13550, cost = 2000, requiredIds = {13549}},
    {id = 19884, cost = 2000}
  },
  [20] = {
    {id = 24493, cost = 440},
    {id = 14282, cost = 2200, requiredIds = {14281}},
    {id = 5118, cost = 2200},
    {id = 781, cost = 2200},
    {id = 14274, cost = 2200, requiredIds = {20736}},
    {id = 674, cost = 2200},
    {id = 23992, cost = 440},
    {id = 1499, cost = 2200},
    {id = 24446, cost = 440},
    {id = 14917, cost = 440},
    {id = 3111, cost = 2200, requiredIds = {136}},
    {id = 24492, cost = 440},
    {id = 24488, cost = 40}
  },
  [22] = {{id = 14323, cost = 6000, requiredIds = {1130}}, {id = 3043, cost = 6000}},
  [24] = {
    {id = 1462, cost = 7000},
    {id = 4190, cost = 1260},
    {id = 24551, cost = 1260},
    {id = 14262, cost = 7000, requiredIds = {14261}},
    {id = 19885, cost = 7000}
  },
  [26] = {
    {id = 14302, cost = 7000, requiredIds = {13795}},
    {id = 3045, cost = 7000},
    {id = 13551, cost = 7000, requiredIds = {13550}},
    {id = 19880, cost = 7000}
  },
  [28] = {
    {id = 20900, cost = 400, requiredIds = {19434}, requiredTalentId = 19434},
    {id = 14283, cost = 8000, requiredIds = {14282}},
    {id = 14319, cost = 8000, requiredIds = {14318}},
    {id = 13809, cost = 8000},
    {id = 3661, cost = 8000, requiredIds = {3111}}
  },
  [30] = {
    {id = 24497, cost = 1440},
    {id = 13161, cost = 8000},
    {id = 15629, cost = 8000, requiredIds = {14274}},
    {id = 5384, cost = 8000},
    {id = 24439, cost = 1440},
    {id = 24447, cost = 1440},
    {id = 4191, cost = 1440},
    {id = 14918, cost = 1440},
    {id = 14269, cost = 8000, requiredIds = {1495}},
    {id = 14288, cost = 8000, requiredIds = {2643}},
    {id = 24552, cost = 1440},
    {id = 24502, cost = 1440},
    {id = 14326, cost = 8000, requiredIds = {1513}},
    {id = 24505, cost = 1440}
  },
  [32] = {
    {id = 1543, cost = 10000},
    {id = 14263, cost = 10000, requiredIds = {14262}},
    {id = 14275, cost = 10000, requiredIds = {3043}},
    {id = 19878, cost = 10000}
  },
  [34] = {
    {id = 14272, cost = 12000, requiredIds = {781}},
    {id = 13813, cost = 12000},
    {id = 13552, cost = 12000, requiredIds = {13551}}
  },
  [36] = {
    {id = 20901, cost = 700, requiredIds = {20900}, requiredTalentId = 19434},
    {id = 14284, cost = 14000, requiredIds = {14283}},
    {id = 4192, cost = 2520},
    {id = 14303, cost = 14000, requiredIds = {14302}},
    {id = 3662, cost = 14000, requiredIds = {3661}},
    {id = 24553, cost = 2520},
    {id = 3034, cost = 14000}
  },
  [38] = {{id = 14320, cost = 16000, requiredIds = {14319}}, {id = 14267, cost = 16000, requiredIds = {2974}}},
  [40] = {
    {id = 24500, cost = 3240},
    {id = 13159, cost = 18000},
    {id = 15630, cost = 18000, requiredIds = {15629}},
    {id = 24444, cost = 3240},
    {id = 14310, cost = 18000, requiredIds = {1499}},
    {id = 24448, cost = 3240},
    {id = 14919, cost = 3240},
    {id = 14324, cost = 18000, requiredIds = {14323}},
    --{id = 8737, cost = 18000},
    {id = 24503, cost = 3240},
    {id = 14264, cost = 18000, requiredIds = {14263}},
    {id = 24506, cost = 3240},
    {id = 19882, cost = 18000},
    {id = 1510, cost = 18000}
  },
  [42] = {
    {id = 20909, cost = 1200, requiredIds = {19306}, requiredTalentId = 19306},
    {id = 4193, cost = 4320},
    {id = 14289, cost = 24000, requiredIds = {14288}},
    {id = 24554, cost = 4320},
    {id = 14276, cost = 24000, requiredIds = {14275}},
    {id = 13553, cost = 24000, requiredIds = {13552}}
  },
  [44] = {
    {id = 20902, cost = 1300, requiredIds = {20901}, requiredTalentId = 19434},
    {id = 14285, cost = 26000, requiredIds = {14284}},
    {id = 14316, cost = 26000, requiredIds = {13813}},
    {id = 13542, cost = 26000, requiredIds = {3662}},
    {id = 14270, cost = 26000, requiredIds = {14269}}
  },
  [46] = {
    {id = 20043, cost = 28000},
    {id = 14304, cost = 28000, requiredIds = {14303}},
    {id = 14327, cost = 28000, requiredIds = {14326}},
    {id = 14279, cost = 28000, requiredIds = {3034}}
  },
  [48] = {
    {id = 14321, cost = 32000, requiredIds = {14320}},
    {id = 14273, cost = 32000, requiredIds = {14272}},
    {id = 4194, cost = 5760},
    {id = 24555, cost = 5760},
    {id = 14265, cost = 32000, requiredIds = {14264}}
  },
  [50] = {
    {id = 24501, cost = 6480},
    {id = 15631, cost = 36000, requiredIds = {15630}},
    {id = 24445, cost = 6480},
    {id = 24449, cost = 6480},
    {id = 14920, cost = 6480},
    {id = 24504, cost = 6480},
    {id = 13554, cost = 36000, requiredIds = {13553}},
    {id = 24507, cost = 6480},
    {id = 19879, cost = 36000},
    {id = 20905, cost = 1800, requiredIds = {19506}, requiredTalentId = 19506},
    {id = 14294, cost = 36000, requiredIds = {1510}},
    {id = 24132, cost = 1800, requiredIds = {19386}, requiredTalentId = 19386}
  },
  [52] = {
    {id = 20903, cost = 2000, requiredIds = {20902}, requiredTalentId = 19434},
    {id = 14286, cost = 40000, requiredIds = {14285}},
    {id = 13543, cost = 40000, requiredIds = {13542}},
    {id = 14277, cost = 40000, requiredIds = {14276}}
  },
  [54] = {
    {id = 20910, cost = 2100, requiredIds = {20909}, requiredTalentId = 19306},
    {id = 14317, cost = 42000, requiredIds = {14316}},
    {id = 5041, cost = 7560},
    {id = 14290, cost = 42000, requiredIds = {14289}},
    {id = 24629, cost = 7560}
  },
  [56] = {
    {id = 20190, cost = 46000, requiredIds = {20043}},
    {id = 14305, cost = 46000, requiredIds = {14304}},
    {id = 14266, cost = 46000, requiredIds = {14265}},
    {id = 14280, cost = 46000, requiredIds = {14279}}
  },
  [58] = {
    {id = 14322, cost = 48000, requiredIds = {14321}},
    {id = 14325, cost = 48000, requiredIds = {14324}},
    {id = 14271, cost = 48000, requiredIds = {14270}},
    {id = 13555, cost = 48000, requiredIds = {13554}},
    {id = 14295, cost = 48000, requiredIds = {14294}}
  },
  [60] = {
    {id = 20904, cost = 2500, requiredIds = {20903}, requiredTalentId = 19434},
    {id = 14287, cost = 50000, requiredIds = {14286}},
    {id = 15632, cost = 50000, requiredIds = {15631}},
    {id = 14311, cost = 50000, requiredIds = {14310}},
    {id = 5042, cost = 9000},
    {id = 14921, cost = 9000},
    {id = 13544, cost = 50000, requiredIds = {13543}},
    {id = 24630, cost = 9000},
    {id = 20906, cost = 2500, requiredIds = {20905}, requiredTalentId = 19506},
    {id = 14268, cost = 5000, requiredIds = {14267}},
    {id = 24133, cost = 2500, requiredIds = {24132}, requiredTalentId = 19386}
  }
}
