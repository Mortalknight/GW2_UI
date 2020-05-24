local _, GW = ...
if (GW.myclass ~= "MAGE") then return end
GW.SpellsByLevel = GW.RaceFilter(
{
[0] = {
      -- @One-Handed Swords undefined
      {id =201, isTalent =0, isSkill =1},
      -- @Staves undefined
      {id =227, isTalent =0, isSkill =1},
      -- @Daggers undefined
      {id =1180, isTalent =0, isSkill =1},
      -- @Wands undefined
      {id =5009, isTalent =0, isSkill =1},
      -- @Wand Specialization Rank 1
      {id =6057, rank =1, isTalent =1},
      -- @Wand Specialization Rank 2
      {id =6085, requiredIds ={6057}, rank =2, baseId =6057, isTalent =1},
      -- @Improved Fireball Rank 1
      {id =11069, rank =1, isTalent =1},
      -- @Improved Frostbolt Rank 1
      {id =11070, rank =1, isTalent =1},
      -- @Frostbite Rank 1
      {id =11071, rank =1, isTalent =1},
      -- @Improved Fire Blast Rank 1
      {id =11078, rank =1, isTalent =1},
      -- @Improved Fire Blast Rank 2
      {id =11080, requiredIds ={11078}, rank =2, baseId =11078, isTalent =1},
      -- @Burning Soul Rank 1
      {id =11083, rank =1, isTalent =1},
      -- @Improved Fire Ward Rank 1
      {id =11094, rank =1, isTalent =1},
      -- @Improved Scorch Rank 1
      {id =11095, rank =1, isTalent =1},
      -- @Flame Throwing Rank 1
      {id =11100, rank =1, isTalent =1},
      -- @Impact Rank 1
      {id =11103, rank =1, isTalent =1},
      -- @Improved Flamestrike Rank 1
      {id =11108, rank =1, isTalent =1},
      -- @Blast Wave Rank 1
      {id =11113, rank =1, isTalent =1},
      -- @Critical Mass Rank 1
      {id =11115, rank =1, isTalent =1},
      -- @Ignite Rank 1
      {id =11119, rank =1, isTalent =1},
      -- @Ignite Rank 2
      {id =11120, requiredIds ={11119}, rank =2, baseId =11119, isTalent =1},
      -- @Fire Power Rank 1
      {id =11124, rank =1, isTalent =1},
      -- @Combustion undefined
      {id =11129, isTalent =1},
      -- @Piercing Ice Rank 1
      {id =11151, rank =1, isTalent =1},
      -- @Frost Channeling Rank 1
      {id =11160, rank =1, isTalent =1},
      -- @Improved Frost Nova Rank 1
      {id =11165, rank =1, isTalent =1},
      -- @Shatter Rank 1
      {id =11170, rank =1, isTalent =1},
      -- @Permafrost Rank 1
      {id =11175, rank =1, isTalent =1},
      -- @Winter's Chill Rank 1
      {id =11180, rank =1, isTalent =1},
      -- @Improved Blizzard Rank 1
      {id =11185, rank =1, isTalent =1},
      -- @Frost Warding Rank 1
      {id =11189, rank =1, isTalent =1},
      -- @Improved Cone of Cold Rank 1
      {id =11190, rank =1, isTalent =1},
      -- @Ice Shards Rank 1
      {id =11207, rank =1, isTalent =1},
      -- @Arcane Subtlety Rank 1
      {id =11210, rank =1, isTalent =1},
      -- @Arcane Concentration Rank 1
      {id =11213, rank =1, isTalent =1},
      -- @Arcane Focus Rank 1
      {id =11222, rank =1, isTalent =1},
      -- @Arcane Mind Rank 1
      {id =11232, rank =1, isTalent =1},
      -- @Improved Arcane Missiles Rank 1
      {id =11237, rank =1, isTalent =1},
      -- @Improved Arcane Explosion Rank 1
      {id =11242, rank =1, isTalent =1},
      -- @Magic Attunement Rank 1
      {id =11247, rank =1, isTalent =1},
      -- @Improved Mana Shield Rank 1
      {id =11252, rank =1, isTalent =1},
      -- @Improved Counterspell Rank 1
      {id =11255, rank =1, isTalent =1},
      -- @Pyroblast Rank 1
      {id =11366, rank =1, isTalent =1},
      -- @Critical Mass Rank 2
      {id =11367, requiredIds ={11115}, rank =2, baseId =11115, isTalent =1},
      -- @Critical Mass Rank 3
      {id =11368, requiredIds ={11367}, rank =3, baseId =11115, isTalent =1},
      -- @Ice Barrier Rank 1
      {id =11426, rank =1, isTalent =1},
      -- @Ice Block undefined
      {id =11958, isTalent =1},
      -- @Arcane Power undefined
      {id =12042, isTalent =1},
      -- @Presence of Mind undefined
      {id =12043, isTalent =1},
      -- @Improved Fireball Rank 2
      {id =12338, requiredIds ={11069}, rank =2, baseId =11069, isTalent =1},
      -- @Improved Fireball Rank 3
      {id =12339, requiredIds ={12338}, rank =3, baseId =11069, isTalent =1},
      -- @Improved Fireball Rank 4
      {id =12340, requiredIds ={12339}, rank =4, baseId =11069, isTalent =1},
      -- @Improved Fireball Rank 5
      {id =12341, requiredIds ={12340}, rank =5, baseId =11069, isTalent =1},
      -- @Improved Fire Blast Rank 3
      {id =12342, requiredIds ={11080}, rank =3, baseId =11078, isTalent =1},
      -- @Improved Flamestrike Rank 2
      {id =12349, requiredIds ={11108}, rank =2, baseId =11108, isTalent =1},
      -- @Improved Flamestrike Rank 3
      {id =12350, requiredIds ={12349}, rank =3, baseId =11108, isTalent =1},
      -- @Burning Soul Rank 2
      {id =12351, requiredIds ={11083}, rank =2, baseId =11083, isTalent =1},
      -- @Flame Throwing Rank 2
      {id =12353, requiredIds ={11100}, rank =2, baseId =11100, isTalent =1},
      -- @Impact Rank 2
      {id =12357, requiredIds ={11103}, rank =2, baseId =11103, isTalent =1},
      -- @Impact Rank 3
      {id =12358, requiredIds ={12357}, rank =3, baseId =11103, isTalent =1},
      -- @Impact Rank 4
      {id =12359, requiredIds ={12358}, rank =4, baseId =11103, isTalent =1},
      -- @Impact Rank 5
      {id =12360, requiredIds ={12359}, rank =5, baseId =11103, isTalent =1},
      -- @Fire Power Rank 2
      {id =12378, requiredIds ={11124}, rank =2, baseId =11124, isTalent =1},
      -- @Fire Power Rank 3
      {id =12398, requiredIds ={12378}, rank =3, baseId =11124, isTalent =1},
      -- @Fire Power Rank 4
      {id =12399, requiredIds ={12398}, rank =4, baseId =11124, isTalent =1},
      -- @Fire Power Rank 5
      {id =12400, requiredIds ={12399}, rank =5, baseId =11124, isTalent =1},
      -- @Improved Arcane Missiles Rank 2
      {id =12463, requiredIds ={11237}, rank =2, baseId =11237, isTalent =1},
      -- @Improved Arcane Missiles Rank 3
      {id =12464, requiredIds ={12463}, rank =3, baseId =11237, isTalent =1},
      -- @Improved Arcane Explosion Rank 2
      {id =12467, requiredIds ={11242}, rank =2, baseId =11242, isTalent =1},
      -- @Improved Arcane Explosion Rank 3
      {id =12469, requiredIds ={12467}, rank =3, baseId =11242, isTalent =1},
      -- @Cold Snap undefined
      {id =12472, isTalent =1},
      -- @Improved Frostbolt Rank 2
      {id =12473, requiredIds ={11070}, rank =2, baseId =11070, isTalent =1},
      -- @Improved Frost Nova Rank 2
      {id =12475, requiredIds ={11165}, rank =2, baseId =11165, isTalent =1},
      -- @Improved Blizzard Rank 2
      {id =12487, requiredIds ={11185}, rank =2, baseId =11185, isTalent =1},
      -- @Improved Blizzard Rank 3
      {id =12488, requiredIds ={12487}, rank =3, baseId =11185, isTalent =1},
      -- @Improved Cone of Cold Rank 2
      {id =12489, requiredIds ={11190}, rank =2, baseId =11190, isTalent =1},
      -- @Improved Cone of Cold Rank 3
      {id =12490, requiredIds ={12489}, rank =3, baseId =11190, isTalent =1},
      -- @Frostbite Rank 2
      {id =12496, requiredIds ={11071}, rank =2, baseId =11071, isTalent =1},
      -- @Frostbite Rank 3
      {id =12497, requiredIds ={12496}, rank =3, baseId =11071, isTalent =1},
      -- @Arcane Mind Rank 2
      {id =12500, requiredIds ={11232}, rank =2, baseId =11232, isTalent =1},
      -- @Arcane Mind Rank 3
      {id =12501, requiredIds ={12500}, rank =3, baseId =11232, isTalent =1},
      -- @Arcane Mind Rank 4
      {id =12502, requiredIds ={12501}, rank =4, baseId =11232, isTalent =1},
      -- @Arcane Mind Rank 5
      {id =12503, requiredIds ={12502}, rank =5, baseId =11232, isTalent =1},
      -- @Frost Channeling Rank 2
      {id =12518, requiredIds ={11160}, rank =2, baseId =11160, isTalent =1},
      -- @Frost Channeling Rank 3
      {id =12519, requiredIds ={12518}, rank =3, baseId =11160, isTalent =1},
      -- @Permafrost Rank 2
      {id =12569, requiredIds ={11175}, rank =2, baseId =11175, isTalent =1},
      -- @Permafrost Rank 3
      {id =12571, requiredIds ={12569}, rank =3, baseId =11175, isTalent =1},
      -- @Arcane Concentration Rank 2
      {id =12574, requiredIds ={11213}, rank =2, baseId =11213, isTalent =1},
      -- @Arcane Concentration Rank 3
      {id =12575, requiredIds ={12574}, rank =3, baseId =11213, isTalent =1},
      -- @Arcane Concentration Rank 4
      {id =12576, requiredIds ={12575}, rank =4, baseId =11213, isTalent =1},
      -- @Arcane Concentration Rank 5
      {id =12577, requiredIds ={12576}, rank =5, baseId =11213, isTalent =1},
      -- @Arcane Subtlety Rank 2
      {id =12592, requiredIds ={11210}, rank =2, baseId =11210, isTalent =1},
      -- @Improved Counterspell Rank 2
      {id =12598, requiredIds ={11255}, rank =2, baseId =11255, isTalent =1},
      -- @Improved Mana Shield Rank 2
      {id =12605, requiredIds ={11252}, rank =2, baseId =11252, isTalent =1},
      -- @Magic Attunement Rank 2
      {id =12606, requiredIds ={11247}, rank =2, baseId =11247, isTalent =1},
      -- @Ice Shards Rank 2
      {id =12672, requiredIds ={11207}, rank =2, baseId =11207, isTalent =1},
      -- @Arcane Focus Rank 2
      {id =12839, requiredIds ={11222}, rank =2, baseId =11222, isTalent =1},
      -- @Arcane Focus Rank 3
      {id =12840, requiredIds ={12839}, rank =3, baseId =11222, isTalent =1},
      -- @Arcane Focus Rank 4
      {id =12841, requiredIds ={12840}, rank =4, baseId =11222, isTalent =1},
      -- @Arcane Focus Rank 5
      {id =12842, requiredIds ={12841}, rank =5, baseId =11222, isTalent =1},
      -- @Ignite Rank 3
      {id =12846, requiredIds ={11120}, rank =3, baseId =11119, isTalent =1},
      -- @Ignite Rank 4
      {id =12847, requiredIds ={12846}, rank =4, baseId =11119, isTalent =1},
      -- @Ignite Rank 5
      {id =12848, requiredIds ={12847}, rank =5, baseId =11119, isTalent =1},
      -- @Improved Scorch Rank 2
      {id =12872, requiredIds ={11095}, rank =2, baseId =11095, isTalent =1},
      -- @Improved Scorch Rank 3
      {id =12873, requiredIds ={12872}, rank =3, baseId =11095, isTalent =1},
      -- @Piercing Ice Rank 2
      {id =12952, requiredIds ={11151}, rank =2, baseId =11151, isTalent =1},
      -- @Piercing Ice Rank 3
      {id =12953, requiredIds ={12952}, rank =3, baseId =11151, isTalent =1},
      -- @Shatter Rank 2
      {id =12982, requiredIds ={11170}, rank =2, baseId =11170, isTalent =1},
      -- @Shatter Rank 3
      {id =12983, requiredIds ={12982}, rank =3, baseId =11170, isTalent =1},
      -- @Shatter Rank 4
      {id =12984, requiredIds ={12983}, rank =4, baseId =11170, isTalent =1},
      -- @Shatter Rank 5
      {id =12985, requiredIds ={12984}, rank =5, baseId =11170, isTalent =1},
      -- @Improved Fire Ward Rank 2
      {id =13043, requiredIds ={11094}, rank =2, baseId =11094, isTalent =1},
      -- @Ice Shards Rank 3
      {id =15047, requiredIds ={12672}, rank =3, baseId =11207, isTalent =1},
      -- @Ice Shards Rank 4
      {id =15052, requiredIds ={15047}, rank =4, baseId =11207, isTalent =1},
      -- @Ice Shards Rank 5
      {id =15053, requiredIds ={15052}, rank =5, baseId =11207, isTalent =1},
      -- @Arcane Instability Rank 1
      {id =15058, rank =1, isTalent =1},
      -- @Arcane Instability Rank 2
      {id =15059, requiredIds ={15058}, rank =2, baseId =15058, isTalent =1},
      -- @Arcane Instability Rank 3
      {id =15060, requiredIds ={15059}, rank =3, baseId =15058, isTalent =1},
      -- @Arctic Reach Rank 1
      {id =16757, rank =1, isTalent =1},
      -- @Arctic Reach Rank 2
      {id =16758, requiredIds ={16757}, rank =2, baseId =16757, isTalent =1},
      -- @Improved Frostbolt Rank 3
      {id =16763, requiredIds ={12473}, rank =3, baseId =11070, isTalent =1},
      -- @Improved Frostbolt Rank 4
      {id =16765, requiredIds ={16763}, rank =4, baseId =11070, isTalent =1},
      -- @Improved Frostbolt Rank 5
      {id =16766, requiredIds ={16765}, rank =5, baseId =11070, isTalent =1},
      -- @Improved Arcane Missiles Rank 4
      {id =16769, requiredIds ={12464}, rank =4, baseId =11237, isTalent =1},
      -- @Improved Arcane Missiles Rank 5
      {id =16770, requiredIds ={16769}, rank =5, baseId =11237, isTalent =1},
      -- @Incinerate Rank 1
      {id =18459, rank =1, isTalent =1},
      -- @Incinerate Rank 2
      {id =18460, requiredIds ={18459}, rank =2, baseId =18459, isTalent =1},
      -- @Arcane Meditation Rank 1
      {id =18462, rank =1, isTalent =1},
      -- @Arcane Meditation Rank 2
      {id =18463, requiredIds ={18462}, rank =2, baseId =18462, isTalent =1},
      -- @Arcane Meditation Rank 3
      {id =18464, requiredIds ={18463}, rank =3, baseId =18462, isTalent =1},
      -- @Frost Warding Rank 2
      {id =28332, requiredIds ={11189}, rank =2, baseId =11189, isTalent =1},
      -- @Arcane Resilience undefined
      {id =28574, isTalent =1},
      -- @Winter's Chill Rank 2
      {id =28592, requiredIds ={11180}, rank =2, baseId =11180, isTalent =1},
      -- @Winter's Chill Rank 3
      {id =28593, requiredIds ={28592}, rank =3, baseId =11180, isTalent =1},
      -- @Winter's Chill Rank 4
      {id =28594, requiredIds ={28593}, rank =4, baseId =11180, isTalent =1},
      -- @Winter's Chill Rank 5
      {id =28595, requiredIds ={28594}, rank =5, baseId =11180, isTalent =1},
      -- @Master of Elements Rank 1
      {id =29074, rank =1, isTalent =1},
      -- @Master of Elements Rank 2
      {id =29075, requiredIds ={29074}, rank =2, baseId =29074, isTalent =1},
      -- @Master of Elements Rank 3
      {id =29076, requiredIds ={29075}, rank =3, baseId =29074, isTalent =1},
      -- @Elemental Precision Rank 1
      {id =29438, rank =1, isTalent =1},
      -- @Elemental Precision Rank 2
      {id =29439, requiredIds ={29438}, rank =2, baseId =29438, isTalent =1},
      -- @Elemental Precision Rank 3
      {id =29440, requiredIds ={29439}, rank =3, baseId =29438, isTalent =1},
      -- @Magic Absorption Rank 1
      {id =29441, rank =1, isTalent =1},
      -- @Magic Absorption Rank 2
      {id =29444, requiredIds ={29441}, rank =2, baseId =29441, isTalent =1},
      -- @Magic Absorption Rank 3
      {id =29445, requiredIds ={29444}, rank =3, baseId =29441, isTalent =1},
      -- @Magic Absorption Rank 4
      {id =29446, requiredIds ={29445}, rank =4, baseId =29441, isTalent =1},
      -- @Magic Absorption Rank 5
      {id =29447, requiredIds ={29446}, rank =5, baseId =29441, isTalent =1},
       },
[1] = {
      -- @Fireball Rank 1
      {id =133, rank =1, isTalent =0},
      -- @Frost Armor Rank 1
      {id =168, rank =1, isTalent =0},
      -- @Arcane Intellect Rank 1
      {id =1459, rank =1, cost =10, isTalent =0},
      -- @Shoot undefined
      {id =5019, isTalent =0, isSkill =1},
       },
[4] = {
      -- @Frostbolt Rank 1
      {id =116, rank =1, cost =100, isTalent =0},
      -- 7Conjure Water Rank 1
      {id =5504, rank =1, cost =100, isTalent =0},
       },
[6] = {
      -- @Fireball Rank 2
      {id =143, requiredIds ={133}, rank =2, baseId =133, cost =100, isTalent =0},
      -- 7Conjure Food Rank 1
      {id =587, rank =1, cost =100, isTalent =0},
      -- @Fire Blast Rank 1
      {id =2136, rank =1, cost =100, isTalent =0},
       },
[8] = {
      -- @Polymorph Rank 1
      {id =118, rank =1, cost =200, isTalent =0},
      -- @Frostbolt Rank 2
      {id =205, requiredIds ={116}, rank =2, baseId =116, cost =200, isTalent =0},
      -- @Arcane Missiles Rank 1
      {id =5143, rank =1, cost =200, isTalent =0},
       },
[10] = {
      -- @Frost Nova Rank 1
      {id =122, rank =1, cost =400, isTalent =0},
      -- 7Conjure Water Rank 2
      {id =5505, requiredIds ={5504}, rank =2, baseId =5504, cost =400, isTalent =0},
      -- @Frost Armor Rank 2
      {id =7300, requiredIds ={168}, rank =2, baseId =168, cost =400, isTalent =0},
       },
[12] = {
      -- @Slow Fall undefined
      {id =130, cost =600, isTalent =0},
      -- @Fireball Rank 3
      {id =145, requiredIds ={143}, rank =3, baseId =133, cost =600, isTalent =0},
      -- 7Conjure Food Rank 2
      {id =597, requiredIds ={587}, rank =2, baseId =587, cost =600, isTalent =0},
      -- @Dampen Magic Rank 1
      {id =604, rank =1, cost =600, isTalent =0},
       },
[14] = {
      -- @Frostbolt Rank 3
      {id =837, requiredIds ={205}, rank =3, baseId =116, cost =900, isTalent =0},
      -- @Arcane Explosion Rank 1
      {id =1449, rank =1, cost =900, isTalent =0},
      -- @Arcane Intellect Rank 2
      {id =1460, requiredIds ={1459}, rank =2, baseId =1459, cost =900, isTalent =0},
      -- @Fire Blast Rank 2
      {id =2137, requiredIds ={2136}, rank =2, baseId =2136, cost =900, isTalent =0},
       },
[16] = {
      -- @Flamestrike Rank 1
      {id =2120, rank =1, cost =1500, isTalent =0},
      -- @Detect Magic undefined
      {id =2855, cost =1500, isTalent =0},
      -- @Arcane Missiles Rank 2
      {id =5144, requiredIds ={5143}, rank =2, baseId =5143, cost =1500, isTalent =0},
       },
[18] = {
      -- @Remove Lesser Curse undefined
      {id =475, cost =1800, isTalent =0},
      -- @Amplify Magic Rank 1
      {id =1008, rank =1, cost =1800, isTalent =0},
      -- @Fireball Rank 4
      {id =3140, requiredIds ={145}, rank =4, baseId =133, cost =1800, isTalent =0},
       },
[20] = {
      -- @Blizzard Rank 1
      {id =10, rank =1, cost =2000, isTalent =0},
      -- @Fire Ward Rank 1
      {id =543, rank =1, cost =2000, isTalent =0},
      -- @Mana Shield Rank 1
      {id =1463, rank =1, cost =2000, isTalent =0},
      -- @Blink undefined
      {id =1953, cost =2000, isTalent =0},
      -- @Teleport: Stormwind undefined
      {id =3561, races ={1, 3, 4, 7}, cost =2000, isTalent =0},
      -- @Teleport: Ironforge undefined
      {id =3562, races ={1, 3, 4, 7}, cost =2000, isTalent =0},
      -- @Teleport: Undercity undefined
      {id =3563, races ={2, 5, 6, 8}, cost =2000, isTalent =0},
      -- @Teleport: Orgrimmar undefined
      {id =3567, races ={2, 5, 6, 8}, cost =2000, isTalent =0},
      -- 7Conjure Water Rank 3
      {id =5506, requiredIds ={5505}, rank =3, baseId =5504, cost =2000, isTalent =0},
      -- @Frost Armor Rank 3
      {id =7301, requiredIds ={7300}, rank =3, baseId =168, cost =2000, isTalent =0},
      -- @Frostbolt Rank 4
      {id =7322, requiredIds ={837}, rank =4, baseId =116, cost =2000, isTalent =0},
      -- @Evocation undefined
      {id =12051, cost =2000, isTalent =0},
      -- @Polymorph Rank 2
      {id =12824, requiredIds ={118}, rank =2, baseId =118, cost =2000, isTalent =0},
       },
[22] = {
      -- 7Conjure Food Rank 3
      {id =990, requiredIds ={597}, rank =3, baseId =587, cost =3000, isTalent =0},
      -- @Fire Blast Rank 3
      {id =2138, requiredIds ={2137}, rank =3, baseId =2136, cost =3000, isTalent =0},
      -- @Scorch Rank 1
      {id =2948, rank =1, cost =3000, isTalent =0},
      -- @Frost Ward Rank 1
      {id =6143, rank =1, cost =3000, isTalent =0},
      -- @Arcane Explosion Rank 2
      {id =8437, requiredIds ={1449}, rank =2, baseId =1449, cost =3000, isTalent =0},
       },
[24] = {
      -- @Flamestrike Rank 2
      {id =2121, requiredIds ={2120}, rank =2, baseId =2120, cost =4000, isTalent =0},
      -- @Counterspell undefined
      {id =2139, cost =4000, isTalent =0},
      -- @Arcane Missiles Rank 3
      {id =5145, requiredIds ={5144}, rank =3, baseId =5143, cost =4000, isTalent =0},
      -- @Fireball Rank 5
      {id =8400, requiredIds ={3140}, rank =5, baseId =133, cost =4000, isTalent =0},
      -- @Dampen Magic Rank 2
      {id =8450, requiredIds ={604}, rank =2, baseId =604, cost =4000, isTalent =0},
      -- @Pyroblast Rank 2
      {id =12505, requiredIds ={11366}, rank =2, baseId =11366, cost =200, isTalent =1},
       },
[26] = {
      -- @Cone of Cold Rank 1
      {id =120, rank =1, cost =5000, isTalent =0},
      -- @Frost Nova Rank 2
      {id =865, requiredIds ={122}, rank =2, baseId =122, cost =5000, isTalent =0},
      -- @Frostbolt Rank 5
      {id =8406, requiredIds ={7322}, rank =5, baseId =116, cost =5000, isTalent =0},
       },
[28] = {
      -- 7Conjure Mana Agate undefined
      {id =759, cost =7000, isTalent =0},
      -- @Arcane Intellect Rank 3
      {id =1461, requiredIds ={1460}, rank =3, baseId =1459, cost =7000, isTalent =0},
      -- @Blizzard Rank 2
      {id =6141, requiredIds ={10}, rank =2, baseId =10, cost =7000, isTalent =0},
      -- @Scorch Rank 2
      {id =8444, requiredIds ={2948}, rank =2, baseId =2948, cost =7000, isTalent =0},
      -- @Mana Shield Rank 2
      {id =8494, requiredIds ={1463}, rank =2, baseId =1463, cost =7000, isTalent =0},
       },
[30] = {
      -- @Teleport: Darnassus undefined
      {id =3565, races ={1, 3, 4, 7}, cost =8000, isTalent =0},
      -- @Teleport: Thunder Bluff undefined
      {id =3566, races ={2, 5, 6, 8}, cost =8000, isTalent =0},
      -- 7Conjure Water Rank 4
      {id =6127, requiredIds ={5506}, rank =4, baseId =5504, cost =8000, isTalent =0},
      -- @Ice Armor Rank 1
      {id =7302, rank =1, cost =8000, isTalent =0},
      -- @Fireball Rank 6
      {id =8401, requiredIds ={8400}, rank =6, baseId =133, cost =8000, isTalent =0},
      -- @Fire Blast Rank 4
      {id =8412, requiredIds ={2138}, rank =4, baseId =2136, cost =8000, isTalent =0},
      -- @Arcane Explosion Rank 3
      {id =8438, requiredIds ={8437}, rank =3, baseId =1449, cost =8000, isTalent =0},
      -- @Amplify Magic Rank 2
      {id =8455, requiredIds ={1008}, rank =2, baseId =1008, cost =8000, isTalent =0},
      -- @Fire Ward Rank 2
      {id =8457, requiredIds ={543}, rank =2, baseId =543, cost =8000, isTalent =0},
      -- @Pyroblast Rank 3
      {id =12522, requiredIds ={12505}, rank =3, baseId =11366, cost =400, isTalent =1},
       },
[32] = {
      -- 7Conjure Food Rank 4
      {id =6129, requiredIds ={990}, rank =4, baseId =587, cost =10000, isTalent =0},
      -- @Frostbolt Rank 6
      {id =8407, requiredIds ={8406}, rank =6, baseId =116, cost =10000, isTalent =0},
      -- @Arcane Missiles Rank 4
      {id =8416, requiredIds ={5145}, rank =4, baseId =5143, cost =10000, isTalent =0},
      -- @Flamestrike Rank 3
      {id =8422, requiredIds ={2121}, rank =3, baseId =2120, cost =10000, isTalent =0},
      -- @Frost Ward Rank 2
      {id =8461, requiredIds ={6143}, rank =2, baseId =6143, cost =10000, isTalent =0},
       },
[34] = {
      -- @Mage Armor Rank 1
      {id =6117, rank =1, cost =13000, isTalent =0},
      -- @Scorch Rank 3
      {id =8445, requiredIds ={8444}, rank =3, baseId =2948, cost =12000, isTalent =0},
      -- @Cone of Cold Rank 2
      {id =8492, requiredIds ={120}, rank =2, baseId =120, cost =12000, isTalent =0},
       },
[36] = {
      -- @Fireball Rank 7
      {id =8402, requiredIds ={8401}, rank =7, baseId =133, cost =13000, isTalent =0},
      -- @Blizzard Rank 3
      {id =8427, requiredIds ={6141}, rank =3, baseId =10, cost =13000, isTalent =0},
      -- @Dampen Magic Rank 3
      {id =8451, requiredIds ={8450}, rank =3, baseId =604, cost =13000, isTalent =0},
      -- @Mana Shield Rank 3
      {id =8495, requiredIds ={8494}, rank =3, baseId =1463, cost =13000, isTalent =0},
      -- @Pyroblast Rank 4
      {id =12523, requiredIds ={12522}, rank =4, baseId =11366, cost =650, isTalent =1},
      -- @Blast Wave Rank 2
      {id =13018, requiredIds ={11113}, rank =2, baseId =11113, cost =650, isTalent =1},
       },
[38] = {
      -- 7Conjure Mana Jade undefined
      {id =3552, cost =14000, isTalent =0},
      -- @Frostbolt Rank 7
      {id =8408, requiredIds ={8407}, rank =7, baseId =116, cost =14000, isTalent =0},
      -- @Fire Blast Rank 5
      {id =8413, requiredIds ={8412}, rank =5, baseId =2136, cost =14000, isTalent =0},
      -- @Arcane Explosion Rank 4
      {id =8439, requiredIds ={8438}, rank =4, baseId =1449, cost =14000, isTalent =0},
       },
[40] = {
      -- @Frost Nova Rank 3
      {id =6131, requiredIds ={865}, rank =3, baseId =122, cost =15000, isTalent =0},
      -- @Ice Armor Rank 2
      {id =7320, requiredIds ={7302}, rank =2, baseId =7302, cost =15000, isTalent =0},
      -- @Arcane Missiles Rank 5
      {id =8417, requiredIds ={8416}, rank =5, baseId =5143, cost =15000, isTalent =0},
      -- @Flamestrike Rank 4
      {id =8423, requiredIds ={8422}, rank =4, baseId =2120, cost =15000, isTalent =0},
      -- @Scorch Rank 4
      {id =8446, requiredIds ={8445}, rank =4, baseId =2948, cost =15000, isTalent =0},
      -- @Fire Ward Rank 3
      {id =8458, requiredIds ={8457}, rank =3, baseId =543, cost =15000, isTalent =0},
      -- @Portal: Stormwind undefined
      {id =10059, races ={1, 3, 4, 7}, cost =15000, isTalent =0},
      -- 7Conjure Water Rank 5
      {id =10138, requiredIds ={6127}, rank =5, baseId =5504, cost =15000, isTalent =0},
      -- @Portal: Ironforge undefined
      {id =11416, races ={1, 3, 4, 7}, cost =15000, isTalent =0},
      -- @Portal: Orgrimmar undefined
      {id =11417, races ={2, 5, 6, 8}, cost =15000, isTalent =0},
      -- @Portal: Undercity undefined
      {id =11418, races ={2, 5, 6, 8}, cost =15000, isTalent =0},
      -- @Polymorph Rank 3
      {id =12825, requiredIds ={12824}, rank =3, baseId =118, cost =15000, isTalent =0},
       },
[42] = {
      -- @Frost Ward Rank 3
      {id =8462, requiredIds ={8461}, rank =3, baseId =6143, cost =18000, isTalent =0},
      -- 7Conjure Food Rank 5
      {id =10144, requiredIds ={6129}, rank =5, baseId =587, cost =18000, isTalent =0},
      -- @Fireball Rank 8
      {id =10148, requiredIds ={8402}, rank =8, baseId =133, cost =18000, isTalent =0},
      -- @Arcane Intellect Rank 4
      {id =10156, requiredIds ={1461}, rank =4, baseId =1459, cost =18000, isTalent =0},
      -- @Cone of Cold Rank 3
      {id =10159, requiredIds ={8492}, rank =3, baseId =120, cost =18000, isTalent =0},
      -- @Amplify Magic Rank 3
      {id =10169, requiredIds ={8455}, rank =3, baseId =1008, cost =18000, isTalent =0},
      -- @Pyroblast Rank 5
      {id =12524, requiredIds ={12523}, rank =5, baseId =11366, cost =900, isTalent =1},
       },
[44] = {
      -- @Frostbolt Rank 8
      {id =10179, requiredIds ={8408}, rank =8, baseId =116, cost =23000, isTalent =0},
      -- @Blizzard Rank 4
      {id =10185, requiredIds ={8427}, rank =4, baseId =10, cost =23000, isTalent =0},
      -- @Mana Shield Rank 4
      {id =10191, requiredIds ={8495}, rank =4, baseId =1463, cost =23000, isTalent =0},
      -- @Blast Wave Rank 3
      {id =13019, requiredIds ={13018}, rank =3, baseId =11113, cost =1150, isTalent =1},
       },
[46] = {
      -- @Fire Blast Rank 6
      {id =10197, requiredIds ={8413}, rank =6, baseId =2136, cost =26000, isTalent =0},
      -- @Arcane Explosion Rank 5
      {id =10201, requiredIds ={8439}, rank =5, baseId =1449, cost =26000, isTalent =0},
      -- @Scorch Rank 5
      {id =10205, requiredIds ={8446}, rank =5, baseId =2948, cost =26000, isTalent =0},
      -- @Ice Barrier Rank 2
      {id =13031, requiredIds ={11426}, rank =2, baseId =11426, cost =1300, isTalent =1},
      -- @Mage Armor Rank 2
      {id =22782, requiredIds ={6117}, rank =2, baseId =6117, cost =28000, isTalent =0},
       },
[48] = {
      -- 7Conjure Mana Citrine undefined
      {id =10053, cost =28000, isTalent =0},
      -- @Fireball Rank 9
      {id =10149, requiredIds ={10148}, rank =9, baseId =133, cost =28000, isTalent =0},
      -- @Dampen Magic Rank 4
      {id =10173, requiredIds ={8451}, rank =4, baseId =604, cost =28000, isTalent =0},
      -- @Arcane Missiles Rank 6
      {id =10211, requiredIds ={8417}, rank =6, baseId =5143, cost =28000, isTalent =0},
      -- @Flamestrike Rank 5
      {id =10215, requiredIds ={8423}, rank =5, baseId =2120, cost =28000, isTalent =0},
      -- @Pyroblast Rank 6
      {id =12525, requiredIds ={12524}, rank =6, baseId =11366, cost =1400, isTalent =1},
       },
[50] = {
      -- 7Conjure Water Rank 6
      {id =10139, requiredIds ={10138}, rank =6, baseId =5504, cost =32000, isTalent =0},
      -- @Cone of Cold Rank 4
      {id =10160, requiredIds ={10159}, rank =4, baseId =120, cost =32000, isTalent =0},
      -- @Frostbolt Rank 9
      {id =10180, requiredIds ={10179}, rank =9, baseId =116, cost =32000, isTalent =0},
      -- @Ice Armor Rank 3
      {id =10219, requiredIds ={7320}, rank =3, baseId =7302, cost =32000, isTalent =0},
      -- @Fire Ward Rank 4
      {id =10223, requiredIds ={8458}, rank =4, baseId =543, cost =32000, isTalent =0},
      -- @Portal: Darnassus undefined
      {id =11419, races ={1, 3, 4, 7}, cost =32000, isTalent =0},
      -- @Portal: Thunder Bluff undefined
      {id =11420, races ={2, 5, 6, 8}, cost =32000, isTalent =0},
       },
[52] = {
      -- 7Conjure Food Rank 6
      {id =10145, requiredIds ={10144}, rank =6, baseId =587, cost =35000, isTalent =0},
      -- @Frost Ward Rank 4
      {id =10177, requiredIds ={8462}, rank =4, baseId =6143, cost =35000, isTalent =0},
      -- @Blizzard Rank 5
      {id =10186, requiredIds ={10185}, rank =5, baseId =10, cost =35000, isTalent =0},
      -- @Mana Shield Rank 5
      {id =10192, requiredIds ={10191}, rank =5, baseId =1463, cost =35000, isTalent =0},
      -- @Scorch Rank 6
      {id =10206, requiredIds ={10205}, rank =6, baseId =2948, cost =35000, isTalent =0},
      -- @Blast Wave Rank 4
      {id =13020, requiredIds ={13019}, rank =4, baseId =11113, cost =1750, isTalent =1},
      -- @Ice Barrier Rank 3
      {id =13032, requiredIds ={13031}, rank =3, baseId =11426, cost =1750, isTalent =1},
       },
[54] = {
      -- @Fireball Rank 10
      {id =10150, requiredIds ={10149}, rank =10, baseId =133, cost =36000, isTalent =0},
      -- @Amplify Magic Rank 4
      {id =10170, requiredIds ={10169}, rank =4, baseId =1008, cost =36000, isTalent =0},
      -- @Fire Blast Rank 7
      {id =10199, requiredIds ={10197}, rank =7, baseId =2136, cost =36000, isTalent =0},
      -- @Arcane Explosion Rank 6
      {id =10202, requiredIds ={10201}, rank =6, baseId =1449, cost =36000, isTalent =0},
      -- @Frost Nova Rank 4
      {id =10230, requiredIds ={6131}, rank =4, baseId =122, cost =36000, isTalent =0},
      -- @Pyroblast Rank 7
      {id =12526, requiredIds ={12525}, rank =7, baseId =11366, cost =1800, isTalent =1},
       },
[56] = {
      -- @Arcane Intellect Rank 5
      {id =10157, requiredIds ={10156}, rank =5, baseId =1459, cost =38000, isTalent =0},
      -- @Frostbolt Rank 10
      {id =10181, requiredIds ={10180}, rank =10, baseId =116, cost =38000, isTalent =0},
      -- @Arcane Missiles Rank 7
      {id =10212, requiredIds ={10211}, rank =7, baseId =5143, cost =38000, isTalent =0},
      -- @Flamestrike Rank 6
      {id =10216, requiredIds ={10215}, rank =6, baseId =2120, cost =38000, isTalent =0},
      -- @Arcane Brilliance Rank 1
      {id =23028, rank =1, isTalent =0},
      -- @Arcane Missiles Rank 8
      {id =25345, requiredIds ={10212}, rank =8, baseId =5143, isTalent =0},
       },
[58] = {
      -- 7Conjure Mana Ruby undefined
      {id =10054, cost =40000, isTalent =0},
      -- @Cone of Cold Rank 5
      {id =10161, requiredIds ={10160}, rank =5, baseId =120, cost =40000, isTalent =0},
      -- @Scorch Rank 7
      {id =10207, requiredIds ={10206}, rank =7, baseId =2948, cost =40000, isTalent =0},
      -- @Ice Barrier Rank 4
      {id =13033, requiredIds ={13032}, rank =4, baseId =11426, cost =2000, isTalent =1},
      -- @Mage Armor Rank 3
      {id =22783, requiredIds ={22782}, rank =3, baseId =6117, cost =40000, isTalent =0},
       },
[60] = {
      -- 7Conjure Water Rank 7
      {id =10140, requiredIds ={10139}, rank =7, baseId =5504, isTalent =0},
      -- @Fireball Rank 11
      {id =10151, requiredIds ={10150}, rank =11, baseId =133, cost =42000, isTalent =0},
      -- @Dampen Magic Rank 5
      {id =10174, requiredIds ={10173}, rank =5, baseId =604, cost =42000, isTalent =0},
      -- @Blizzard Rank 6
      {id =10187, requiredIds ={10186}, rank =6, baseId =10, cost =42000, isTalent =0},
      -- @Mana Shield Rank 6
      {id =10193, requiredIds ={10192}, rank =6, baseId =1463, cost =42000, isTalent =0},
      -- @Ice Armor Rank 4
      {id =10220, requiredIds ={10219}, rank =4, baseId =7302, cost =42000, isTalent =0},
      -- @Fire Ward Rank 5
      {id =10225, requiredIds ={10223}, rank =5, baseId =543, cost =42000, isTalent =0},
      -- @Polymorph Rank 4
      {id =12826, requiredIds ={12825}, rank =4, baseId =118, cost =42000, isTalent =0},
      -- @Blast Wave Rank 5
      {id =13021, requiredIds ={13020}, rank =5, baseId =11113, cost =2100, isTalent =1},
      -- @Pyroblast Rank 8
      {id =18809, requiredIds ={12526}, rank =8, baseId =11366, cost =2100, isTalent =1},
      -- @Frostbolt Rank 11
      {id =25304, requiredIds ={10181}, rank =11, baseId =116, isTalent =0},
      -- @Fireball Rank 12
      {id =25306, requiredIds ={10151}, rank =12, baseId =133, isTalent =0},
      -- @Polymorph: Cow undefined
      {id =28270, isTalent =0},
      -- @Polymorph Turtle
      {id =28271, baseId =118, isTalent =0},
      -- @Polymorph Pig
      {id =28272, baseId =118, isTalent =0},
      -- @Frost Ward Rank 5
      {id =28609, requiredIds ={10177}, rank =5, baseId =6143, isTalent =0},
      -- 7Conjure Food Rank 7
      {id =28612, requiredIds ={10145}, rank =7, baseId =587, isTalent =0}
        }
}


)
