local _, GW = ...
if (GW.currentClass ~= "MAGE") then return end
GW.SpellsByLevel = GW.FactionFilter(

 {
 [0] = {
      -- @One-Handed Swords undefined
      {id =201, isTalent =0},
      -- @Staves undefined
      {id =227, isTalent =0},
      -- @Daggers undefined
      {id =1180, isTalent =0},
      -- @Wands undefined
      {id =5009, isTalent =0},
      -- @Wand Specialization Rank 1
      {id =6057, isTalent =1},
      -- @Wand Specialization Rank 2
      {id =6085, requiredIds ={6057}, isTalent =1},
      -- @Improved Fireball Rank 1
      {id =11069, isTalent =1},
      -- @Improved Frostbolt Rank 1
      {id =11070, isTalent =1},
      -- @Frostbite Rank 1
      {id =11071, isTalent =1},
      -- @Improved Fire Blast Rank 1
      {id =11078, isTalent =1},
      -- @Improved Fire Blast Rank 2
      {id =11080, requiredIds ={11078}, isTalent =1},
      -- @Burning Soul Rank 1
      {id =11083, isTalent =1},
      -- @Improved Fire Ward Rank 1
      {id =11094, isTalent =1},
      -- @Improved Scorch Rank 1
      {id =11095, isTalent =1},
      -- @Flame Throwing Rank 1
      {id =11100, isTalent =1},
      -- @Impact Rank 1
      {id =11103, isTalent =1},
      -- @Improved Flamestrike Rank 1
      {id =11108, isTalent =1},
      -- @Blast Wave Rank 1
      {id =11113, isTalent =1},
      -- @Critical Mass Rank 1
      {id =11115, isTalent =1},
      -- @Ignite Rank 1
      {id =11119, isTalent =1},
      -- @Ignite Rank 2
      {id =11120, requiredIds ={11119}, isTalent =1},
      -- @Fire Power Rank 1
      {id =11124, isTalent =1},
      -- @Combustion undefined
      {id =11129, isTalent =1},
      -- @Piercing Ice Rank 1
      {id =11151, isTalent =1},
      -- @Frost Channeling Rank 1
      {id =11160, isTalent =1},
      -- @Improved Frost Nova Rank 1
      {id =11165, isTalent =1},
      -- @Shatter Rank 1
      {id =11170, isTalent =1},
      -- @Permafrost Rank 1
      {id =11175, isTalent =1},
      -- @Winter's Chill Rank 1
      {id =11180, isTalent =1},
      -- @Improved Blizzard Rank 1
      {id =11185, isTalent =1},
      -- @Frost Warding Rank 1
      {id =11189, isTalent =1},
      -- @Improved Cone of Cold Rank 1
      {id =11190, isTalent =1},
      -- @Ice Shards Rank 1
      {id =11207, isTalent =1},
      -- @Arcane Subtlety Rank 1
      {id =11210, isTalent =1},
      -- @Arcane Concentration Rank 1
      {id =11213, isTalent =1},
      -- @Arcane Focus Rank 1
      {id =11222, isTalent =1},
      -- @Arcane Mind Rank 1
      {id =11232, isTalent =1},
      -- @Improved Arcane Missiles Rank 1
      {id =11237, isTalent =1},
      -- @Improved Arcane Explosion Rank 1
      {id =11242, isTalent =1},
      -- @Magic Attunement Rank 1
      {id =11247, isTalent =1},
      -- @Improved Mana Shield Rank 1
      {id =11252, isTalent =1},
      -- @Improved Counterspell Rank 1
      {id =11255, isTalent =1},
      -- @Pyroblast Rank 1
      {id =11366, isTalent =1},
      -- @Critical Mass Rank 2
      {id =11367, requiredIds ={11115}, isTalent =1},
      -- @Critical Mass Rank 3
      {id =11368, requiredIds ={11367}, isTalent =1},
      -- @Ice Barrier Rank 1
      {id =11426, isTalent =1},
      -- @Ice Block undefined
      {id =11958, isTalent =1},
      -- @Arcane Power undefined
      {id =12042, isTalent =1},
      -- @Presence of Mind undefined
      {id =12043, isTalent =1},
      -- @Improved Fireball Rank 2
      {id =12338, requiredIds ={11069}, isTalent =1},
      -- @Improved Fireball Rank 3
      {id =12339, requiredIds ={12338}, isTalent =1},
      -- @Improved Fireball Rank 4
      {id =12340, requiredIds ={12339}, isTalent =1},
      -- @Improved Fireball Rank 5
      {id =12341, requiredIds ={12340}, isTalent =1},
      -- @Improved Fire Blast Rank 3
      {id =12342, requiredIds ={11080}, isTalent =1},
      -- @Improved Flamestrike Rank 2
      {id =12349, requiredIds ={11108}, isTalent =1},
      -- @Improved Flamestrike Rank 3
      {id =12350, requiredIds ={12349}, isTalent =1},
      -- @Burning Soul Rank 2
      {id =12351, requiredIds ={11083}, isTalent =1},
      -- @Flame Throwing Rank 2
      {id =12353, requiredIds ={11100}, isTalent =1},
      -- @Impact Rank 2
      {id =12357, requiredIds ={11103}, isTalent =1},
      -- @Impact Rank 3
      {id =12358, requiredIds ={12357}, isTalent =1},
      -- @Impact Rank 4
      {id =12359, requiredIds ={12358}, isTalent =1},
      -- @Impact Rank 5
      {id =12360, requiredIds ={12359}, isTalent =1},
      -- @Fire Power Rank 2
      {id =12378, requiredIds ={11124}, isTalent =1},
      -- @Fire Power Rank 3
      {id =12398, requiredIds ={12378}, isTalent =1},
      -- @Fire Power Rank 4
      {id =12399, requiredIds ={12398}, isTalent =1},
      -- @Fire Power Rank 5
      {id =12400, requiredIds ={12399}, isTalent =1},
      -- @Improved Arcane Missiles Rank 2
      {id =12463, requiredIds ={11237}, isTalent =1},
      -- @Improved Arcane Missiles Rank 3
      {id =12464, requiredIds ={12463}, isTalent =1},
      -- @Improved Arcane Explosion Rank 2
      {id =12467, requiredIds ={11242}, isTalent =1},
      -- @Improved Arcane Explosion Rank 3
      {id =12469, requiredIds ={12467}, isTalent =1},
      -- @Cold Snap undefined
      {id =12472, isTalent =1},
      -- @Improved Frostbolt Rank 2
      {id =12473, requiredIds ={11070}, isTalent =1},
      -- @Improved Frost Nova Rank 2
      {id =12475, requiredIds ={11165}, isTalent =1},
      -- @Improved Blizzard Rank 2
      {id =12487, requiredIds ={11185}, isTalent =1},
      -- @Improved Blizzard Rank 3
      {id =12488, requiredIds ={12487}, isTalent =1},
      -- @Improved Cone of Cold Rank 2
      {id =12489, requiredIds ={11190}, isTalent =1},
      -- @Improved Cone of Cold Rank 3
      {id =12490, requiredIds ={12489}, isTalent =1},
      -- @Frostbite Rank 2
      {id =12496, requiredIds ={11071}, isTalent =1},
      -- @Frostbite Rank 3
      {id =12497, requiredIds ={12496}, isTalent =1},
      -- @Arcane Mind Rank 2
      {id =12500, requiredIds ={11232}, isTalent =1},
      -- @Arcane Mind Rank 3
      {id =12501, requiredIds ={12500}, isTalent =1},
      -- @Arcane Mind Rank 4
      {id =12502, requiredIds ={12501}, isTalent =1},
      -- @Arcane Mind Rank 5
      {id =12503, requiredIds ={12502}, isTalent =1},
      -- @Frost Channeling Rank 2
      {id =12518, requiredIds ={11160}, isTalent =1},
      -- @Frost Channeling Rank 3
      {id =12519, requiredIds ={12518}, isTalent =1},
      -- @Permafrost Rank 2
      {id =12569, requiredIds ={11175}, isTalent =1},
      -- @Permafrost Rank 3
      {id =12571, requiredIds ={12569}, isTalent =1},
      -- @Arcane Concentration Rank 2
      {id =12574, requiredIds ={11213}, isTalent =1},
      -- @Arcane Concentration Rank 3
      {id =12575, requiredIds ={12574}, isTalent =1},
      -- @Arcane Concentration Rank 4
      {id =12576, requiredIds ={12575}, isTalent =1},
      -- @Arcane Concentration Rank 5
      {id =12577, requiredIds ={12576}, isTalent =1},
      -- @Arcane Subtlety Rank 2
      {id =12592, requiredIds ={11210}, isTalent =1},
      -- @Improved Counterspell Rank 2
      {id =12598, requiredIds ={11255}, isTalent =1},
      -- @Improved Mana Shield Rank 2
      {id =12605, requiredIds ={11252}, isTalent =1},
      -- @Magic Attunement Rank 2
      {id =12606, requiredIds ={11247}, isTalent =1},
      -- @Ice Shards Rank 2
      {id =12672, requiredIds ={11207}, isTalent =1},
      -- @Arcane Focus Rank 2
      {id =12839, requiredIds ={11222}, isTalent =1},
      -- @Arcane Focus Rank 3
      {id =12840, requiredIds ={12839}, isTalent =1},
      -- @Arcane Focus Rank 4
      {id =12841, requiredIds ={12840}, isTalent =1},
      -- @Arcane Focus Rank 5
      {id =12842, requiredIds ={12841}, isTalent =1},
      -- @Ignite Rank 3
      {id =12846, requiredIds ={11120}, isTalent =1},
      -- @Ignite Rank 4
      {id =12847, requiredIds ={12846}, isTalent =1},
      -- @Ignite Rank 5
      {id =12848, requiredIds ={12847}, isTalent =1},
      -- @Improved Scorch Rank 2
      {id =12872, requiredIds ={11095}, isTalent =1},
      -- @Improved Scorch Rank 3
      {id =12873, requiredIds ={12872}, isTalent =1},
      -- @Piercing Ice Rank 2
      {id =12952, requiredIds ={11151}, isTalent =1},
      -- @Piercing Ice Rank 3
      {id =12953, requiredIds ={12952}, isTalent =1},
      -- @Shatter Rank 2
      {id =12982, requiredIds ={11170}, isTalent =1},
      -- @Shatter Rank 3
      {id =12983, requiredIds ={12982}, isTalent =1},
      -- @Shatter Rank 4
      {id =12984, requiredIds ={12983}, isTalent =1},
      -- @Shatter Rank 5
      {id =12985, requiredIds ={12984}, isTalent =1},
      -- @Improved Fire Ward Rank 2
      {id =13043, requiredIds ={11094}, isTalent =1},
      -- @Ice Shards Rank 3
      {id =15047, requiredIds ={12672}, isTalent =1},
      -- @Ice Shards Rank 4
      {id =15052, requiredIds ={15047}, isTalent =1},
      -- @Ice Shards Rank 5
      {id =15053, requiredIds ={15052}, isTalent =1},
      -- @Arcane Instability Rank 1
      {id =15058, isTalent =1},
      -- @Arcane Instability Rank 2
      {id =15059, requiredIds ={15058}, isTalent =1},
      -- @Arcane Instability Rank 3
      {id =15060, requiredIds ={15059}, isTalent =1},
      -- @Arctic Reach Rank 1
      {id =16757, isTalent =1},
      -- @Arctic Reach Rank 2
      {id =16758, requiredIds ={16757}, isTalent =1},
      -- @Improved Frostbolt Rank 3
      {id =16763, requiredIds ={12473}, isTalent =1},
      -- @Improved Frostbolt Rank 4
      {id =16765, requiredIds ={16763}, isTalent =1},
      -- @Improved Frostbolt Rank 5
      {id =16766, requiredIds ={16765}, isTalent =1},
      -- @Improved Arcane Missiles Rank 4
      {id =16769, requiredIds ={12464}, isTalent =1},
      -- @Improved Arcane Missiles Rank 5
      {id =16770, requiredIds ={16769}, isTalent =1},
      -- @Incinerate Rank 1
      {id =18459, isTalent =1},
      -- @Incinerate Rank 2
      {id =18460, requiredIds ={18459}, isTalent =1},
      -- @Arcane Meditation Rank 1
      {id =18462, isTalent =1},
      -- @Arcane Meditation Rank 2
      {id =18463, requiredIds ={18462}, isTalent =1},
      -- @Arcane Meditation Rank 3
      {id =18464, requiredIds ={18463}, isTalent =1},
      -- @Frost Warding Rank 2
      {id =28332, requiredIds ={11189}, isTalent =1},
      -- @Arcane Resilience undefined
      {id =28574, isTalent =1},
      -- @Winter's Chill Rank 2
      {id =28592, requiredIds ={11180}, isTalent =1},
      -- @Winter's Chill Rank 3
      {id =28593, requiredIds ={28592}, isTalent =1},
      -- @Winter's Chill Rank 4
      {id =28594, requiredIds ={28593}, isTalent =1},
      -- @Winter's Chill Rank 5
      {id =28595, requiredIds ={28594}, isTalent =1},
      -- @Master of Elements Rank 1
      {id =29074, isTalent =1},
      -- @Master of Elements Rank 2
      {id =29075, requiredIds ={29074}, isTalent =1},
      -- @Master of Elements Rank 3
      {id =29076, requiredIds ={29075}, isTalent =1},
      -- @Elemental Precision Rank 1
      {id =29438, isTalent =1},
      -- @Elemental Precision Rank 2
      {id =29439, requiredIds ={29438}, isTalent =1},
      -- @Elemental Precision Rank 3
      {id =29440, requiredIds ={29439}, isTalent =1},
      -- @Magic Absorption Rank 1
      {id =29441, isTalent =1},
      -- @Magic Absorption Rank 2
      {id =29444, requiredIds ={29441}, isTalent =1},
      -- @Magic Absorption Rank 3
      {id =29445, requiredIds ={29444}, isTalent =1},
      -- @Magic Absorption Rank 4
      {id =29446, requiredIds ={29445}, isTalent =1},
      -- @Magic Absorption Rank 5
      {id =29447, requiredIds ={29446}, isTalent =1},
       },
[1] = {
      -- @Fireball Rank 1
      {id =133, isTalent =0},
      -- @Frost Armor Rank 1
      {id =168, isTalent =0},
      -- @Arcane Intellect Rank 1
      {id =1459, cost =10, isTalent =0},
      -- @Shoot undefined
      {id =5019, isTalent =0},
       },
[4] = {
      -- @Frostbolt Rank 1
      {id =116, cost =100, isTalent =0},
      -- 7Conjure Water Rank 1
      {id =5504, cost =100, isTalent =0},
       },
[6] = {
      -- @Fireball Rank 2
      {id =143, requiredIds ={133}, cost =100, isTalent =0},
      -- 7Conjure Food Rank 1
      {id =587, cost =100, isTalent =0},
      -- @Fire Blast Rank 1
      {id =2136, cost =100, isTalent =0},
       },
[8] = {
      -- @Polymorph Rank 1
      {id =118, cost =200, isTalent =0},
      -- @Frostbolt Rank 2
      {id =205, requiredIds ={116}, cost =200, isTalent =0},
      -- @Arcane Missiles Rank 1
      {id =5143, cost =200, isTalent =0},
       },
[10] = {
      -- @Frost Nova Rank 1
      {id =122, cost =400, isTalent =0},
      -- 7Conjure Water Rank 2
      {id =5505, requiredIds ={5504}, cost =400, isTalent =0},
      -- @Frost Armor Rank 2
      {id =7300, requiredIds ={168}, cost =400, isTalent =0},
       },
[12] = {
      -- @Slow Fall undefined
      {id =130, cost =600, isTalent =0},
      -- @Fireball Rank 3
      {id =145, requiredIds ={143}, cost =600, isTalent =0},
      -- 7Conjure Food Rank 2
      {id =597, requiredIds ={587}, cost =600, isTalent =0},
      -- @Dampen Magic Rank 1
      {id =604, cost =600, isTalent =0},
       },
[14] = {
      -- @Frostbolt Rank 3
      {id =837, requiredIds ={205}, cost =900, isTalent =0},
      -- @Arcane Explosion Rank 1
      {id =1449, cost =900, isTalent =0},
      -- @Arcane Intellect Rank 2
      {id =1460, requiredIds ={1459}, cost =900, isTalent =0},
      -- @Fire Blast Rank 2
      {id =2137, requiredIds ={2136}, cost =900, isTalent =0},
       },
[16] = {
      -- @Flamestrike Rank 1
      {id =2120, cost =1500, isTalent =0},
      -- @Detect Magic undefined
      {id =2855, cost =1500, isTalent =0},
      -- @Arcane Missiles Rank 2
      {id =5144, requiredIds ={5143}, cost =1500, isTalent =0},
       },
[18] = {
      -- @Remove Lesser Curse undefined
      {id =475, cost =1800, isTalent =0},
      -- @Amplify Magic Rank 1
      {id =1008, cost =1800, isTalent =0},
      -- @Fireball Rank 4
      {id =3140, requiredIds ={145}, cost =1800, isTalent =0},
       },
[20] = {
      -- @Blizzard Rank 1
      {id =10, cost =2000, isTalent =0},
      -- @Fire Ward Rank 1
      {id =543, cost =2000, isTalent =0},
      -- @Mana Shield Rank 1
      {id =1463, cost =2000, isTalent =0},
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
      {id =5506, requiredIds ={5505}, cost =2000, isTalent =0},
      -- @Frost Armor Rank 3
      {id =7301, requiredIds ={7300}, cost =2000, isTalent =0},
      -- @Frostbolt Rank 4
      {id =7322, requiredIds ={837}, cost =2000, isTalent =0},
      -- @Evocation undefined
      {id =12051, cost =2000, isTalent =0},
      -- @Polymorph Rank 2
      {id =12824, requiredIds ={118}, cost =2000, isTalent =0},
       },
[22] = {
      -- 7Conjure Food Rank 3
      {id =990, requiredIds ={597}, cost =3000, isTalent =0},
      -- @Fire Blast Rank 3
      {id =2138, requiredIds ={2137}, cost =3000, isTalent =0},
      -- @Scorch Rank 1
      {id =2948, cost =3000, isTalent =0},
      -- @Frost Ward Rank 1
      {id =6143, cost =3000, isTalent =0},
      -- @Arcane Explosion Rank 2
      {id =8437, requiredIds ={1449}, cost =3000, isTalent =0},
       },
[24] = {
      -- @Flamestrike Rank 2
      {id =2121, requiredIds ={2120}, cost =4000, isTalent =0},
      -- @Counterspell undefined
      {id =2139, cost =4000, isTalent =0},
      -- @Arcane Missiles Rank 3
      {id =5145, requiredIds ={5144}, cost =4000, isTalent =0},
      -- @Fireball Rank 5
      {id =8400, requiredIds ={3140}, cost =4000, isTalent =0},
      -- @Dampen Magic Rank 2
      {id =8450, requiredIds ={604}, cost =4000, isTalent =0},
      -- @Pyroblast Rank 2
      {id =12505, requiredIds ={11366}, cost =200, isTalent =0},
       },
[26] = {
      -- @Cone of Cold Rank 1
      {id =120, cost =5000, isTalent =0},
      -- @Frost Nova Rank 2
      {id =865, requiredIds ={122}, cost =5000, isTalent =0},
      -- @Frostbolt Rank 5
      {id =8406, requiredIds ={7322}, cost =5000, isTalent =0},
       },
[28] = {
      -- 7Conjure Mana Agate undefined
      {id =759, cost =7000, isTalent =0},
      -- @Arcane Intellect Rank 3
      {id =1461, requiredIds ={1460}, cost =7000, isTalent =0},
      -- @Blizzard Rank 2
      {id =6141, requiredIds ={10}, cost =7000, isTalent =0},
      -- @Scorch Rank 2
      {id =8444, requiredIds ={2948}, cost =7000, isTalent =0},
      -- @Mana Shield Rank 2
      {id =8494, requiredIds ={1463}, cost =7000, isTalent =0},
       },
[30] = {
      -- @Teleport: Darnassus undefined
      {id =3565, races ={1, 3, 4, 7}, cost =8000, isTalent =0},
      -- @Teleport: Thunder Bluff undefined
      {id =3566, races ={2, 5, 6, 8}, cost =8000, isTalent =0},
      -- 7Conjure Water Rank 4
      {id =6127, requiredIds ={5506}, cost =8000, isTalent =0},
      -- @Ice Armor Rank 1
      {id =7302, cost =8000, isTalent =0},
      -- @Fireball Rank 6
      {id =8401, requiredIds ={8400}, cost =8000, isTalent =0},
      -- @Fire Blast Rank 4
      {id =8412, requiredIds ={2138}, cost =8000, isTalent =0},
      -- @Arcane Explosion Rank 3
      {id =8438, requiredIds ={8437}, cost =8000, isTalent =0},
      -- @Amplify Magic Rank 2
      {id =8455, requiredIds ={1008}, cost =8000, isTalent =0},
      -- @Fire Ward Rank 2
      {id =8457, requiredIds ={543}, cost =8000, isTalent =0},
      -- @Pyroblast Rank 3
      {id =12522, requiredIds ={12505}, cost =400, isTalent =0},
       },
[32] = {
      -- 7Conjure Food Rank 4
      {id =6129, requiredIds ={990}, cost =10000, isTalent =0},
      -- @Frostbolt Rank 6
      {id =8407, requiredIds ={8406}, cost =10000, isTalent =0},
      -- @Arcane Missiles Rank 4
      {id =8416, requiredIds ={5145}, cost =10000, isTalent =0},
      -- @Flamestrike Rank 3
      {id =8422, requiredIds ={2121}, cost =10000, isTalent =0},
      -- @Frost Ward Rank 2
      {id =8461, requiredIds ={6143}, cost =10000, isTalent =0},
       },
[34] = {
      -- @Mage Armor Rank 1
      {id =6117, cost =13000, isTalent =0},
      -- @Scorch Rank 3
      {id =8445, requiredIds ={8444}, cost =12000, isTalent =0},
      -- @Cone of Cold Rank 2
      {id =8492, requiredIds ={120}, cost =12000, isTalent =0},
       },
[36] = {
      -- @Fireball Rank 7
      {id =8402, requiredIds ={8401}, cost =13000, isTalent =0},
      -- @Blizzard Rank 3
      {id =8427, requiredIds ={6141}, cost =13000, isTalent =0},
      -- @Dampen Magic Rank 3
      {id =8451, requiredIds ={8450}, cost =13000, isTalent =0},
      -- @Mana Shield Rank 3
      {id =8495, requiredIds ={8494}, cost =13000, isTalent =0},
      -- @Pyroblast Rank 4
      {id =12523, requiredIds ={12522}, cost =650, isTalent =0},
      -- @Blast Wave Rank 2
      {id =13018, requiredIds ={11113}, cost =650, isTalent =0},
       },
[38] = {
      -- 7Conjure Mana Jade undefined
      {id =3552, cost =14000, isTalent =0},
      -- @Frostbolt Rank 7
      {id =8408, requiredIds ={8407}, cost =14000, isTalent =0},
      -- @Fire Blast Rank 5
      {id =8413, requiredIds ={8412}, cost =14000, isTalent =0},
      -- @Arcane Explosion Rank 4
      {id =8439, requiredIds ={8438}, cost =14000, isTalent =0},
       },
[40] = {
      -- @Frost Nova Rank 3
      {id =6131, requiredIds ={865}, cost =15000, isTalent =0},
      -- @Ice Armor Rank 2
      {id =7320, requiredIds ={7302}, cost =15000, isTalent =0},
      -- @Arcane Missiles Rank 5
      {id =8417, requiredIds ={8416}, cost =15000, isTalent =0},
      -- @Flamestrike Rank 4
      {id =8423, requiredIds ={8422}, cost =15000, isTalent =0},
      -- @Scorch Rank 4
      {id =8446, requiredIds ={8445}, cost =15000, isTalent =0},
      -- @Fire Ward Rank 3
      {id =8458, requiredIds ={8457}, cost =15000, isTalent =0},
      -- @Portal: Stormwind undefined
      {id =10059, races ={1, 3, 4, 7}, cost =15000, isTalent =0},
      -- 7Conjure Water Rank 5
      {id =10138, requiredIds ={6127}, cost =15000, isTalent =0},
      -- @Portal: Ironforge undefined
      {id =11416, races ={1, 3, 4, 7}, cost =15000, isTalent =0},
      -- @Portal: Orgrimmar undefined
      {id =11417, races ={2, 5, 6, 8}, cost =15000, isTalent =0},
      -- @Portal: Undercity undefined
      {id =11418, races ={2, 5, 6, 8}, cost =15000, isTalent =0},
      -- @Polymorph Rank 3
      {id =12825, requiredIds ={12824}, cost =15000, isTalent =0},
       },
[42] = {
      -- @Frost Ward Rank 3
      {id =8462, requiredIds ={8461}, cost =18000, isTalent =0},
      -- 7Conjure Food Rank 5
      {id =10144, requiredIds ={6129}, cost =18000, isTalent =0},
      -- @Fireball Rank 8
      {id =10148, requiredIds ={8402}, cost =18000, isTalent =0},
      -- @Arcane Intellect Rank 4
      {id =10156, requiredIds ={1461}, cost =18000, isTalent =0},
      -- @Cone of Cold Rank 3
      {id =10159, requiredIds ={8492}, cost =18000, isTalent =0},
      -- @Amplify Magic Rank 3
      {id =10169, requiredIds ={8455}, cost =18000, isTalent =0},
      -- @Pyroblast Rank 5
      {id =12524, requiredIds ={12523}, cost =900, isTalent =0},
       },
[44] = {
      -- @Frostbolt Rank 8
      {id =10179, requiredIds ={8408}, cost =23000, isTalent =0},
      -- @Blizzard Rank 4
      {id =10185, requiredIds ={8427}, cost =23000, isTalent =0},
      -- @Mana Shield Rank 4
      {id =10191, requiredIds ={8495}, cost =23000, isTalent =0},
      -- @Blast Wave Rank 3
      {id =13019, requiredIds ={13018}, cost =1150, isTalent =0},
       },
[46] = {
      -- @Fire Blast Rank 6
      {id =10197, requiredIds ={8413}, cost =26000, isTalent =0},
      -- @Arcane Explosion Rank 5
      {id =10201, requiredIds ={8439}, cost =26000, isTalent =0},
      -- @Scorch Rank 5
      {id =10205, requiredIds ={8446}, cost =26000, isTalent =0},
      -- @Ice Barrier Rank 2
      {id =13031, requiredIds ={11426}, cost =1300, isTalent =0},
      -- @Mage Armor Rank 2
      {id =22782, requiredIds ={6117}, cost =28000, isTalent =0},
       },
[48] = {
      -- 7Conjure Mana Citrine undefined
      {id =10053, cost =28000, isTalent =0},
      -- @Fireball Rank 9
      {id =10149, requiredIds ={10148}, cost =28000, isTalent =0},
      -- @Dampen Magic Rank 4
      {id =10173, requiredIds ={8451}, cost =28000, isTalent =0},
      -- @Arcane Missiles Rank 6
      {id =10211, requiredIds ={8417}, cost =28000, isTalent =0},
      -- @Flamestrike Rank 5
      {id =10215, requiredIds ={8423}, cost =28000, isTalent =0},
      -- @Pyroblast Rank 6
      {id =12525, requiredIds ={12524}, cost =1400, isTalent =0},
       },
[50] = {
      -- 7Conjure Water Rank 6
      {id =10139, requiredIds ={10138}, cost =32000, isTalent =0},
      -- @Cone of Cold Rank 4
      {id =10160, requiredIds ={10159}, cost =32000, isTalent =0},
      -- @Frostbolt Rank 9
      {id =10180, requiredIds ={10179}, cost =32000, isTalent =0},
      -- @Ice Armor Rank 3
      {id =10219, requiredIds ={7320}, cost =32000, isTalent =0},
      -- @Fire Ward Rank 4
      {id =10223, requiredIds ={8458}, cost =32000, isTalent =0},
      -- @Portal: Darnassus undefined
      {id =11419, races ={1, 3, 4, 7}, cost =32000, isTalent =0},
      -- @Portal: Thunder Bluff undefined
      {id =11420, races ={2, 5, 6, 8}, cost =32000, isTalent =0},
       },
[52] = {
      -- 7Conjure Food Rank 6
      {id =10145, requiredIds ={10144}, cost =35000, isTalent =0},
      -- @Frost Ward Rank 4
      {id =10177, requiredIds ={8462}, cost =35000, isTalent =0},
      -- @Blizzard Rank 5
      {id =10186, requiredIds ={10185}, cost =35000, isTalent =0},
      -- @Mana Shield Rank 5
      {id =10192, requiredIds ={10191}, cost =35000, isTalent =0},
      -- @Scorch Rank 6
      {id =10206, requiredIds ={10205}, cost =35000, isTalent =0},
      -- @Blast Wave Rank 4
      {id =13020, requiredIds ={13019}, cost =1750, isTalent =0},
      -- @Ice Barrier Rank 3
      {id =13032, requiredIds ={13031}, cost =1750, isTalent =0},
       },
[54] = {
      -- @Fireball Rank 10
      {id =10150, requiredIds ={10149}, cost =36000, isTalent =0},
      -- @Amplify Magic Rank 4
      {id =10170, requiredIds ={10169}, cost =36000, isTalent =0},
      -- @Fire Blast Rank 7
      {id =10199, requiredIds ={10197}, cost =36000, isTalent =0},
      -- @Arcane Explosion Rank 6
      {id =10202, requiredIds ={10201}, cost =36000, isTalent =0},
      -- @Frost Nova Rank 4
      {id =10230, requiredIds ={6131}, cost =36000, isTalent =0},
      -- @Pyroblast Rank 7
      {id =12526, requiredIds ={12525}, cost =1800, isTalent =0},
       },
[56] = {
      -- @Arcane Intellect Rank 5
      {id =10157, requiredIds ={10156}, cost =38000, isTalent =0},
      -- @Frostbolt Rank 10
      {id =10181, requiredIds ={10180}, cost =38000, isTalent =0},
      -- @Arcane Missiles Rank 7
      {id =10212, requiredIds ={10211}, cost =38000, isTalent =0},
      -- @Flamestrike Rank 6
      {id =10216, requiredIds ={10215}, cost =38000, isTalent =0},
      -- @Arcane Brilliance Rank 1
      {id =23028, isTalent =0},
      -- @Arcane Missiles Rank 8
      {id =25345, requiredIds ={10212}, isTalent =0},
       },
[58] = {
      -- 7Conjure Mana Ruby undefined
      {id =10054, cost =40000, isTalent =0},
      -- @Cone of Cold Rank 5
      {id =10161, requiredIds ={10160}, cost =40000, isTalent =0},
      -- @Scorch Rank 7
      {id =10207, requiredIds ={10206}, cost =40000, isTalent =0},
      -- @Ice Barrier Rank 4
      {id =13033, requiredIds ={13032}, cost =2000, isTalent =0},
      -- @Mage Armor Rank 3
      {id =22783, requiredIds ={22782}, cost =40000, isTalent =0},
       },
[60] = {
      -- 7Conjure Water Rank 7
      {id =10140, requiredIds ={10139}, isTalent =0},
      -- @Fireball Rank 11
      {id =10151, requiredIds ={10150}, cost =42000, isTalent =0},
      -- @Dampen Magic Rank 5
      {id =10174, requiredIds ={10173}, cost =42000, isTalent =0},
      -- @Blizzard Rank 6
      {id =10187, requiredIds ={10186}, cost =42000, isTalent =0},
      -- @Mana Shield Rank 6
      {id =10193, requiredIds ={10192}, cost =42000, isTalent =0},
      -- @Ice Armor Rank 4
      {id =10220, requiredIds ={10219}, cost =42000, isTalent =0},
      -- @Fire Ward Rank 5
      {id =10225, requiredIds ={10223}, cost =42000, isTalent =0},
      -- @Polymorph Rank 4
      {id =12826, requiredIds ={12825}, cost =42000, isTalent =0},
      -- @Blast Wave Rank 5
      {id =13021, requiredIds ={13020}, cost =2100, isTalent =0},
      -- @Pyroblast Rank 8
      {id =18809, requiredIds ={12526}, cost =2100, isTalent =0},
      -- @Frostbolt Rank 11
      {id =25304, requiredIds ={10181}, isTalent =0},
      -- @Fireball Rank 12
      {id =25306, requiredIds ={10151}, isTalent =0},
      -- @Polymorph: Cow undefined
      {id =28270, isTalent =0},
      -- @Polymorph Turtle
      {id =28271, isTalent =0},
      -- @Polymorph Pig
      {id =28272, isTalent =0},
      -- @Frost Ward Rank 5
      {id =28609, requiredIds ={10177}, isTalent =0},
      -- 7Conjure Food Rank 7
      {id =28612, requiredIds ={10145}, isTalent =0}
        }
}

)
