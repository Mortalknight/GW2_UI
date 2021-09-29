local _, GW = ...
if (GW.myclass ~= "ROGUE") then
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

GW.SpellsByLevel = {
[0] = {
      -- @One-Handed Maces undefined
      {id =198, isTalent =0, isSkill =1},
      -- @One-Handed Swords undefined
      {id =201, isTalent =0, isSkill =1},
      -- @Bows undefined
      {id =264, isTalent =0, isSkill =1},
      -- @Guns undefined
      {id =266, isTalent =0, isSkill =1},
      -- @Dual Wield Passive
      {id =674, isTalent =0, isSkill =1},
      -- @Daggers undefined
      {id =1180, isTalent =0, isSkill =1},
      -- @Thrown undefined
      {id =2567, isTalent =0, isSkill =1},
      -- @Crossbows undefined
      {id =5011, isTalent =0, isSkill =1},
      -- @Leather undefined
      {id =9077, isTalent =0, isSkill =1},
      -- @Precision Rank 1
      {id =13705, rank =1, isTalent =1},
      -- @Dagger Specialization Rank 1
      {id =13706, rank =1, isTalent =1},
      -- @Mace Specialization Rank 1
      {id =13709, rank =1, isTalent =1},
      -- @Lightning Reflexes Rank 1
      {id =13712, rank =1, isTalent =1},
      -- @Deflection Rank 1
      {id =13713, rank =1, isTalent =1},
      -- @Dual Wield Specialization Rank 1
      {id =13715, rank =1, isTalent =1},
      -- @Improved Sinister Strike Rank 1
      {id =13732, rank =1, isTalent =1},
      -- @Improved Backstab Rank 1
      {id =13733, rank =1, isTalent =1},
      -- @Improved Gouge Rank 1
      {id =13741, rank =1, isTalent =1},
      -- @Endurance Rank 1
      {id =13742, rank =1, isTalent =1},
      -- @Improved Sprint Rank 1
      {id =13743, rank =1, isTalent =1},
      -- @Adrenaline Rush undefined
      {id =13750, isTalent =1},
      -- @Improved Kick Rank 1
      {id =13754, rank =1, isTalent =1},
      -- @Lightning Reflexes Rank 2
      {id =13788, requiredIds ={13712}, rank =2, baseId =13712, isTalent =1},
      -- @Lightning Reflexes Rank 3
      {id =13789, requiredIds ={13788}, rank =3, baseId =13712, isTalent =1},
      -- @Lightning Reflexes Rank 4
      {id =13790, requiredIds ={13789}, rank =4, baseId =13712, isTalent =1},
      -- @Lightning Reflexes Rank 5
      {id =13791, requiredIds ={13790}, rank =5, baseId =13712, isTalent =1},
      -- @Improved Gouge Rank 3
      {id =13792, requiredIds ={13793}, rank =3, baseId =13741, isTalent =1},
      -- @Improved Gouge Rank 2
      {id =13793, requiredIds ={13741}, rank =2, baseId =13741, isTalent =1},
      -- @Mace Specialization Rank 2
      {id =13800, requiredIds ={13709}, rank =2, baseId =13709, isTalent =1},
      -- @Mace Specialization Rank 3
      {id =13801, requiredIds ={13800}, rank =3, baseId =13709, isTalent =1},
      -- @Mace Specialization Rank 4
      {id =13802, requiredIds ={13801}, rank =4, baseId =13709, isTalent =1},
      -- @Mace Specialization Rank 5
      {id =13803, requiredIds ={13802}, rank =5, baseId =13709, isTalent =1},
      -- @Dagger Specialization Rank 2
      {id =13804, requiredIds ={13706}, rank =2, baseId =13706, isTalent =1},
      -- @Dagger Specialization Rank 3
      {id =13805, requiredIds ={13804}, rank =3, baseId =13706, isTalent =1},
      -- @Dagger Specialization Rank 4
      {id =13806, requiredIds ={13805}, rank =4, baseId =13706, isTalent =1},
      -- @Dagger Specialization Rank 5
      {id =13807, requiredIds ={13806}, rank =5, baseId =13706, isTalent =1},
      -- @Precision Rank 2
      {id =13832, requiredIds ={13705}, rank =2, baseId =13705, isTalent =1},
      -- @Precision Rank 3
      {id =13843, requiredIds ={13832}, rank =3, baseId =13705, isTalent =1},
      -- @Precision Rank 4
      {id =13844, requiredIds ={13843}, rank =4, baseId =13705, isTalent =1},
      -- @Precision Rank 5
      {id =13845, requiredIds ={13844}, rank =5, baseId =13705, isTalent =1},
      -- @Dual Wield Specialization Rank 2
      {id =13848, requiredIds ={13715}, rank =2, baseId =13715, isTalent =1},
      -- @Dual Wield Specialization Rank 3
      {id =13849, requiredIds ={13848}, rank =3, baseId =13715, isTalent =1},
      -- @Dual Wield Specialization Rank 4
      {id =13851, requiredIds ={13849}, rank =4, baseId =13715, isTalent =1},
      -- @Dual Wield Specialization Rank 5
      {id =13852, requiredIds ={13851}, rank =5, baseId =13715, isTalent =1},
      -- @Deflection Rank 2
      {id =13853, requiredIds ={13713}, rank =2, baseId =13713, isTalent =1},
      -- @Deflection Rank 3
      {id =13854, requiredIds ={13853}, rank =3, baseId =13713, isTalent =1},
      -- @Deflection Rank 4
      {id =13855, requiredIds ={13854}, rank =4, baseId =13713, isTalent =1},
      -- @Deflection Rank 5
      {id =13856, requiredIds ={13855}, rank =5, baseId =13713, isTalent =1},
      -- @Improved Sinister Strike Rank 2
      {id =13863, requiredIds ={13732}, rank =2, baseId =13732, isTalent =1},
      -- @Improved Backstab Rank 2
      {id =13865, requiredIds ={13733}, rank =2, baseId =13733, isTalent =1},
      -- @Improved Backstab Rank 3
      {id =13866, requiredIds ={13865}, rank =3, baseId =13733, isTalent =1},
      -- @Improved Kick Rank 2
      {id =13867, requiredIds ={13754}, rank =2, baseId =13754, isTalent =1},
      -- @Endurance Rank 2
      {id =13872, requiredIds ={13742}, rank =2, baseId =13742, isTalent =1},
      -- @Improved Sprint Rank 2
      {id =13875, requiredIds ={13743}, rank =2, baseId =13743, isTalent =1},
      -- @Blade Flurry undefined
      {id =13877, isTalent =1},
      -- @Master of Deception Rank 1
      {id =13958, rank =1, isTalent =1},
      -- @Sword Specialization Rank 1
      {id =13960, rank =1, isTalent =1},
      -- @Sword Specialization Rank 2
      {id =13961, requiredIds ={13960}, rank =2, baseId =13960, isTalent =1},
      -- @Sword Specialization Rank 3
      {id =13962, requiredIds ={13961}, rank =3, baseId =13960, isTalent =1},
      -- @Sword Specialization Rank 4
      {id =13963, requiredIds ={13962}, rank =4, baseId =13960, isTalent =1},
      -- @Sword Specialization Rank 5
      {id =13964, requiredIds ={13963}, rank =5, baseId =13960, isTalent =1},
      -- @Master of Deception Rank 2
      {id =13970, requiredIds ={13958}, rank =2, baseId =13958, isTalent =1},
      -- @Master of Deception Rank 3
      {id =13971, requiredIds ={13970}, rank =3, baseId =13958, isTalent =1},
      -- @Master of Deception Rank 4
      {id =13972, requiredIds ={13971}, rank =4, baseId =13958, isTalent =1},
      -- @Master of Deception Rank 5
      {id =13973, requiredIds ={13972}, rank =5, baseId =13958, isTalent =1},
      -- @Camouflage Rank 1
      {id =13975, rank =1, isTalent =1},
      -- @Initiative Rank 1
      {id =13976, rank =1, isTalent =1},
      -- @Initiative Rank 2
      {id =13979, requiredIds ={13976}, rank =2, baseId =13976, isTalent =1},
      -- @Initiative Rank 3
      {id =13980, requiredIds ={13979}, rank =3, baseId =13976, isTalent =1},
      -- @Elusiveness Rank 1
      {id =13981, rank =1, isTalent =1},
      -- @Setup Rank 1
      {id =13983, rank =1, isTalent =1},
      -- @Opportunity Rank 1
      {id =14057, rank =1, isTalent =1},
      -- @Camouflage Rank 2
      {id =14062, requiredIds ={13975}, rank =2, baseId =13975, isTalent =1},
      -- @Camouflage Rank 3
      {id =14063, requiredIds ={14062}, rank =3, baseId =13975, isTalent =1},
      -- @Camouflage Rank 4
      {id =14064, requiredIds ={14063}, rank =4, baseId =13975, isTalent =1},
      -- @Camouflage Rank 5
      {id =14065, requiredIds ={14064}, rank =5, baseId =13975, isTalent =1},
      -- @Elusiveness Rank 2
      {id =14066, requiredIds ={13981}, rank =2, baseId =13981, isTalent =1},
      -- @Setup Rank 2
      {id =14070, requiredIds ={13983}, rank =2, baseId =13983, isTalent =1},
      -- @Setup Rank 3
      {id =14071, requiredIds ={14070}, rank =3, baseId =13983, isTalent =1},
      -- @Opportunity Rank 2
      {id =14072, requiredIds ={14057}, rank =2, baseId =14057, isTalent =1},
      -- @Opportunity Rank 3
      {id =14073, requiredIds ={14072}, rank =3, baseId =14057, isTalent =1},
      -- @Opportunity Rank 4
      {id =14074, requiredIds ={14073}, rank =4, baseId =14057, isTalent =1},
      -- @Opportunity Rank 5
      {id =14075, requiredIds ={14074}, rank =5, baseId =14057, isTalent =1},
      -- @Improved Sap Rank 1
      {id =14076, rank =1, isTalent =1},
      -- @Improved Ambush Rank 1
      {id =14079, rank =1, isTalent =1},
      -- @Improved Ambush Rank 2
      {id =14080, requiredIds ={14079}, rank =2, baseId =14079, isTalent =1},
      -- @Improved Ambush Rank 3
      {id =14081, requiredIds ={14080}, rank =3, baseId =14079, isTalent =1},
      -- @Dirty Deeds Rank 1
      {id =14082, rank =1, isTalent =1},
      -- @Dirty Deeds Rank 2
      {id =14083, requiredIds ={14082}, rank =2, baseId =14082, isTalent =1},
      -- @Improved Sap Rank 2
      {id =14094, requiredIds ={14076}, rank =2, baseId =14076, isTalent =1},
      -- @Improved Poisons Rank 1
      {id =14113, rank =1, isTalent =1},
      -- @Improved Poisons Rank 2
      {id =14114, requiredIds ={14113}, rank =2, baseId =14113, isTalent =1},
      -- @Improved Poisons Rank 3
      {id =14115, requiredIds ={14114}, rank =3, baseId =14113, isTalent =1},
      -- @Improved Poisons Rank 4
      {id =14116, requiredIds ={14115}, rank =4, baseId =14113, isTalent =1},
      -- @Improved Poisons Rank 5
      {id =14117, requiredIds ={14116}, rank =5, baseId =14113, isTalent =1},
      -- @Lethality Rank 1
      {id =14128, rank =1, isTalent =1},
      -- @Lethality Rank 2
      {id =14132, requiredIds ={14128}, rank =2, baseId =14128, isTalent =1},
      -- @Lethality Rank 3
      {id =14135, requiredIds ={14132}, rank =3, baseId =14128, isTalent =1},
      -- @Lethality Rank 4
      {id =14136, requiredIds ={14135}, rank =4, baseId =14128, isTalent =1},
      -- @Lethality Rank 5
      {id =14137, requiredIds ={14136}, rank =5, baseId =14128, isTalent =1},
      -- @Malice Rank 1
      {id =14138, rank =1, isTalent =1},
      -- @Malice Rank 2
      {id =14139, requiredIds ={14138}, rank =2, baseId =14138, isTalent =1},
      -- @Malice Rank 3
      {id =14140, requiredIds ={14139}, rank =3, baseId =14138, isTalent =1},
      -- @Malice Rank 4
      {id =14141, requiredIds ={14140}, rank =4, baseId =14138, isTalent =1},
      -- @Malice Rank 5
      {id =14142, requiredIds ={14141}, rank =5, baseId =14138, isTalent =1},
      -- @Remorseless Attacks Rank 1
      {id =14144, rank =1, isTalent =1},
      -- @Remorseless Attacks Rank 2
      {id =14148, requiredIds ={14144}, rank =2, baseId =14144, isTalent =1},
      -- @Ruthlessness Rank 1
      {id =14156, rank =1, isTalent =1},
      -- @Murder Rank 1
      {id =14158, rank =1, isTalent =1},
      -- @Murder Rank 2
      {id =14159, requiredIds ={14158}, rank =2, baseId =14158, isTalent =1},
      -- @Ruthlessness Rank 2
      {id =14160, requiredIds ={14156}, rank =2, baseId =14156, isTalent =1},
      -- @Ruthlessness Rank 3
      {id =14161, requiredIds ={14160}, rank =3, baseId =14156, isTalent =1},
      -- @Improved Eviscerate Rank 1
      {id =14162, rank =1, isTalent =1},
      -- @Improved Eviscerate Rank 2
      {id =14163, requiredIds ={14162}, rank =2, baseId =14162, isTalent =1},
      -- @Improved Eviscerate Rank 3
      {id =14164, requiredIds ={14163}, rank =3, baseId =14162, isTalent =1},
      -- @Improved Slice and Dice Rank 1
      {id =14165, rank =1, isTalent =1},
      -- @Improved Slice and Dice Rank 2
      {id =14166, requiredIds ={14165}, rank =2, baseId =14165, isTalent =1},
      -- @Improved Slice and Dice Rank 3
      {id =14167, requiredIds ={14166}, rank =3, baseId =14165, isTalent =1},
      -- @Improved Expose Armor Rank 1
      {id =14168, rank =1, isTalent =1},
      -- @Improved Expose Armor Rank 2
      {id =14169, requiredIds ={14168}, rank =2, baseId =14168, isTalent =1},
      -- @Serrated Blades Rank 1
      {id =14171, rank =1, isTalent =1},
      -- @Serrated Blades Rank 2
      {id =14172, requiredIds ={14171}, rank =2, baseId =14171, isTalent =1},
      -- @Serrated Blades Rank 3
      {id =14173, requiredIds ={14172}, rank =3, baseId =14171, isTalent =1},
      -- @Improved Kidney Shot Rank 1
      {id =14174, rank =1, isTalent =1},
      -- @Improved Kidney Shot Rank 2
      {id =14175, requiredIds ={14174}, rank =2, baseId =14174, isTalent =1},
      -- @Improved Kidney Shot Rank 3
      {id =14176, requiredIds ={14175}, rank =3, baseId =14174, isTalent =1},
      -- @Cold Blood undefined
      {id =14177, isTalent =1},
      -- @Relentless Strikes undefined
      {id =14179, isTalent =1},
      -- @Premeditation undefined
      {id =14183, isTalent =1},
      -- @Preparation undefined
      {id =14185, isTalent =1},
      -- @Seal Fate Rank 1
      {id =14186, rank =1, isTalent =1},
      -- @Seal Fate Rank 2
      {id =14190, requiredIds ={14186}, rank =2, baseId =14186, isTalent =1},
      -- @Seal Fate Rank 3
      {id =14193, requiredIds ={14190}, rank =3, baseId =14186, isTalent =1},
      -- @Seal Fate Rank 4
      {id =14194, requiredIds ={14193}, rank =4, baseId =14186, isTalent =1},
      -- @Seal Fate Rank 5
      {id =14195, requiredIds ={14194}, rank =5, baseId =14186, isTalent =1},
      -- @Riposte undefined
      {id =14251, isTalent =1},
      -- @Ghostly Strike undefined
      {id =14278, isTalent =1},
      -- @Vigor undefined
      {id =14983, isTalent =1},
      -- @Fist Weapons undefined
      {id =15590, isTalent =0, isSkill =1},
      -- @Hemorrhage Rank 1
      {id =16511, rank =1, isTalent =1},
      -- @Vile Poisons Rank 1
      {id =16513, rank =1, isTalent =1},
      -- @Vile Poisons Rank 2
      {id =16514, requiredIds ={16513}, rank =2, baseId =16513, isTalent =1},
      -- @Vile Poisons Rank 3
      {id =16515, requiredIds ={16514}, rank =3, baseId =16513, isTalent =1},
      -- @Vile Poisons Rank 4
      {id =16719, requiredIds ={16515}, rank =4, baseId =16513, isTalent =1},
      -- @Vile Poisons Rank 5
      {id =16720, requiredIds ={16719}, rank =5, baseId =16513, isTalent =1},
      -- @Aggression Rank 1
      {id =18427, rank =1, isTalent =1},
      -- @Aggression Rank 2
      {id =18428, requiredIds ={18427}, rank =2, baseId =18427, isTalent =1},
      -- @Aggression Rank 3
      {id =18429, requiredIds ={18428}, rank =3, baseId =18427, isTalent =1},
      -- @Sleight of Hand Rank 1
      {id =30892, rank =1, isTalent =1},
      -- @Sleight of Hand Rank 2
      {id =30893, requiredIds ={30892}, rank =2, baseId =30892, isTalent =1},
      -- @Heightened Senses Rank 1
      {id =30894, rank =1, isTalent =1},
      -- @Heightened Senses Rank 2
      {id =30895, requiredIds ={30894}, rank =2, baseId =30894, isTalent =1},
      -- @Deadliness Rank 1
      {id =30902, rank =1, isTalent =1},
      -- @Deadliness Rank 2
      {id =30903, requiredIds ={30902}, rank =2, baseId =30902, isTalent =1},
      -- @Deadliness Rank 3
      {id =30904, requiredIds ={30903}, rank =3, baseId =30902, isTalent =1},
      -- @Deadliness Rank 4
      {id =30905, requiredIds ={30904}, rank =4, baseId =30902, isTalent =1},
      -- @Deadliness Rank 5
      {id =30906, requiredIds ={30905}, rank =5, baseId =30902, isTalent =1},
      -- @Weapon Expertise Rank 1
      {id =30919, rank =1, isTalent =1},
      -- @Weapon Expertise Rank 2
      {id =30920, requiredIds ={30919}, rank =2, baseId =30919, isTalent =1},
       },
[1] = {
      -- @Sinister Strike Rank 1
      {id =1752, rank =1, isTalent =0},
      -- @Stealth Rank 1
      {id =1784, rank =1, cost =10, isTalent =0},
      -- @Pick Lock undefined
      {id =1804, cost =1800, isTalent =0},
      -- @Eviscerate Rank 1
      {id =2098, rank =1, isTalent =0},
      -- @Shoot Bow undefined
      {id =2480, isTalent =0, isSkill =1},
      -- @Throw undefined
      {id =2764, isTalent =0, isSkill =1},
      -- @Parry Passive
      {id =3127, isTalent =0, isSkill =1},
      -- @Shoot Gun undefined
      {id =7918, isTalent =0, isSkill =1},
      -- @Shoot Crossbow undefined
      {id =7919, isTalent =0, isSkill =1},
       },
[4] = {
      -- @Backstab Rank 1
      {id =53, rank =1, cost =100, isTalent =0},
      -- @Pick Pocket undefined
      {id =921, cost =100, isTalent =0},
       },
[6] = {
      -- @Sinister Strike Rank 2
      {id =1757, requiredIds ={1752}, rank =2, baseId =1752, cost =100, isTalent =0},
      -- @Gouge Rank 1
      {id =1776, rank =1, cost =100, isTalent =0},
       },
[8] = {
      -- @Evasion undefined
      {id =5277, cost =200, isTalent =0},
      -- @Eviscerate Rank 2
      {id =6760, requiredIds ={2098}, rank =2, baseId =2098, cost =200, isTalent =0},
       },
[10] = {
      -- @Sprint Rank 1
      {id =2983, rank =1, cost =300, isTalent =0},
      -- @Slice and Dice Rank 1
      {id =5171, rank =1, cost =300, isTalent =0},
      -- @Sap Rank 1
      {id =6770, rank =1, cost =300, isTalent =0},
       },
[12] = {
      -- @Kick Rank 1
      {id =1766, rank =1, cost =800, isTalent =0},
      -- @Backstab Rank 2
      {id =2589, requiredIds ={53}, rank =2, baseId =53, cost =800, isTalent =0},
       },
[14] = {
      -- @Garrote Rank 1
      {id =703, rank =1, cost =1200, isTalent =0},
      -- @Sinister Strike Rank 3
      {id =1758, requiredIds ={1757}, rank =3, baseId =1752, cost =1200, isTalent =0},
      -- @Expose Armor Rank 1
      {id =8647, rank =1, cost =1200, isTalent =0},
       },
[16] = {
      -- @Feint Rank 1
      {id =1966, rank =1, cost =1800, isTalent =0},
      -- @Eviscerate Rank 3
      {id =6761, requiredIds ={6760}, rank =3, baseId =2098, cost =1800, isTalent =0},
       },
[18] = {
      -- @Gouge Rank 2
      {id =1777, requiredIds ={1776}, rank =2, baseId =1776, cost =2900, isTalent =0},
      -- @Ambush Rank 1
      {id =8676, rank =1, cost =2900, isTalent =0},
       },
[20] = {
      -- @Stealth Rank 2
      {id =1785, requiredIds ={1784}, rank =2, baseId =1784, cost =3000, isTalent =0},
      -- @Rupture Rank 1
      {id =1943, rank =1, cost =3000, isTalent =0},
      -- @Backstab Rank 3
      {id =2590, requiredIds ={2589}, rank =3, baseId =53, cost =3000, isTalent =0},
      -- @Poisons undefined
      {id =2842, isTalent =0},
      -- 7Crippling Poison Rank 1
      {id =3420, rank =1, cost =3000, isTalent =0},
      -- 7Instant Poison Rank 1
      {id =8681, rank =1, isTalent =0},
       },
[22] = {
      -- @Distract undefined
      {id =1725, cost =4000, isTalent =0},
      -- @Sinister Strike Rank 4
      {id =1759, requiredIds ={1758}, rank =4, baseId =1752, cost =4000, isTalent =0},
      -- @Vanish Rank 1
      {id =1856, rank =1, cost =4000, isTalent =0},
      -- @Garrote Rank 2
      {id =8631, requiredIds ={703}, rank =2, baseId =703, cost =4000, isTalent =0},
       },
[24] = {
      -- @Detect Traps Passive
      {id =2836, cost =5000, isTalent =0},
      -- 7Mind-numbing Poison Rank 1
      {id =5763, rank =1, cost =5000, isTalent =0},
      -- @Eviscerate Rank 4
      {id =6762, requiredIds ={6761}, rank =4, baseId =2098, cost =5000, isTalent =0},
       },
[26] = {
      -- @Kick Rank 2
      {id =1767, requiredIds ={1766}, rank =2, baseId =1766, cost =6000, isTalent =0},
      -- @Cheap Shot undefined
      {id =1833, cost =6000, isTalent =0},
      -- @Expose Armor Rank 2
      {id =8649, requiredIds ={8647}, rank =2, baseId =8647, cost =6000, isTalent =0},
      -- @Ambush Rank 2
      {id =8724, requiredIds ={8676}, rank =2, baseId =8676, cost =6000, isTalent =0},
       },
[28] = {
      -- @Sap Rank 2
      {id =2070, requiredIds ={6770}, rank =2, baseId =6770, cost =8000, isTalent =0},
      -- @Backstab Rank 4
      {id =2591, requiredIds ={2590}, rank =4, baseId =53, cost =8000, isTalent =0},
      -- @Feint Rank 2
      {id =6768, requiredIds ={1966}, rank =2, baseId =1966, cost =8000, isTalent =0},
      -- @Rupture Rank 2
      {id =8639, requiredIds ={1943}, rank =2, baseId =1943, cost =8000, isTalent =0},
      -- 7Instant Poison II Rank 2
      {id =8687, rank =2, cost =8000, isTalent =0},
       },
[30] = {
      -- @Kidney Shot Rank 1
      {id =408, rank =1, cost =10000, isTalent =0},
      -- @Sinister Strike Rank 5
      {id =1760, requiredIds ={1759}, rank =5, baseId =1752, cost =10000, isTalent =0},
      -- @Disarm Trap undefined
      {id =1842, cost =10000, isTalent =0},
      -- 7Deadly Poison Rank 1
      {id =2835, rank =1, cost =10000, isTalent =0},
      -- @Garrote Rank 3
      {id =8632, requiredIds ={8631}, rank =3, baseId =703, cost =10000, isTalent =0},
       },
[32] = {
      -- @Eviscerate Rank 5
      {id =8623, requiredIds ={6762}, rank =5, baseId =2098, cost =12000, isTalent =0},
      -- @Gouge Rank 3
      {id =8629, requiredIds ={1777}, rank =3, baseId =1776, cost =12000, isTalent =0},
      -- 7Wound Poison Rank 1
      {id =13220, rank =1, cost =12000, isTalent =0},
       },
[34] = {
      -- @Blind undefined
      {id =2094, cost =14000, isTalent =0},
      -- 7Blinding Powder undefined
      {id =6510, cost =14000, isTalent =0},
      -- @Sprint Rank 2
      {id =8696, requiredIds ={2983}, rank =2, baseId =2983, cost =14000, isTalent =0},
      -- @Ambush Rank 3
      {id =8725, requiredIds ={8724}, rank =3, baseId =8676, cost =14000, isTalent =0},
       },
[36] = {
      -- @Rupture Rank 3
      {id =8640, requiredIds ={8639}, rank =3, baseId =1943, cost =16000, isTalent =0},
      -- @Expose Armor Rank 3
      {id =8650, requiredIds ={8649}, rank =3, baseId =8647, cost =16000, isTalent =0},
      -- 7Instant Poison III Rank 3
      {id =8691, rank =3, cost =16000, isTalent =0},
      -- @Backstab Rank 5
      {id =8721, requiredIds ={2591}, rank =5, baseId =53, cost =16000, isTalent =0},
       },
[38] = {
      -- 7Deadly Poison II Rank 2
      {id =2837, rank =2, cost =18000, isTalent =0},
      -- @Sinister Strike Rank 6
      {id =8621, requiredIds ={1760}, rank =6, baseId =1752, cost =18000, isTalent =0},
      -- @Garrote Rank 4
      {id =8633, requiredIds ={8632}, rank =4, baseId =703, cost =18000, isTalent =0},
      -- 7Mind-numbing Poison II Rank 2
      {id =8694, rank =2, cost =18000, isTalent =0},
       },
[40] = {
      -- @Stealth Rank 3
      {id =1786, requiredIds ={1785}, rank =3, baseId =1784, cost =20000, isTalent =0},
      -- @Safe Fall Passive
      {id =1860, cost =20000, isTalent =0},
      -- @Eviscerate Rank 6
      {id =8624, requiredIds ={8623}, rank =6, baseId =2098, cost =20000, isTalent =0},
      -- @Feint Rank 3
      {id =8637, requiredIds ={6768}, rank =3, baseId =1966, cost =20000, isTalent =0},
      -- 7Wound Poison II Rank 2
      {id =13228, rank =2, cost =20000, isTalent =0},
       },
[42] = {
      -- @Kick Rank 3
      {id =1768, requiredIds ={1767}, rank =3, baseId =1766, cost =27000, isTalent =0},
      -- @Vanish Rank 2
      {id =1857, requiredIds ={1856}, rank =2, baseId =1856, cost =27000, isTalent =0},
      -- @Slice and Dice Rank 2
      {id =6774, requiredIds ={5171}, rank =2, baseId =5171, cost =27000, isTalent =0},
      -- @Ambush Rank 4
      {id =11267, requiredIds ={8725}, rank =4, baseId =8676, cost =27000, isTalent =0},
       },
[44] = {
      -- @Rupture Rank 4
      {id =11273, requiredIds ={8640}, rank =4, baseId =1943, cost =29000, isTalent =0},
      -- @Backstab Rank 6
      {id =11279, requiredIds ={8721}, rank =6, baseId =53, cost =29000, isTalent =0},
      -- 7Instant Poison IV Rank 4
      {id =11341, rank =4, cost =29000, isTalent =0},
       },
[46] = {
      -- @Expose Armor Rank 4
      {id =11197, requiredIds ={8650}, rank =4, baseId =8647, cost =31000, isTalent =0},
      -- @Gouge Rank 4
      {id =11285, requiredIds ={8629}, rank =4, baseId =1776, cost =31000, isTalent =0},
      -- @Garrote Rank 5
      {id =11289, requiredIds ={8633}, rank =5, baseId =703, cost =31000, isTalent =0},
      -- @Sinister Strike Rank 7
      {id =11293, requiredIds ={8621}, rank =7, baseId =1752, cost =31000, isTalent =0},
      -- 7Deadly Poison III Rank 3
      {id =11357, rank =3, cost =31000, isTalent =0},
      -- @Hemorrhage Rank 2
      {id =17347, requiredIds ={16511}, rank =2, baseId =16511, cost =7750, isTalent =1},
       },
[48] = {
      -- @Sap Rank 3
      {id =11297, requiredIds ={2070}, rank =3, baseId =6770, cost =33000, isTalent =0},
      -- @Eviscerate Rank 7
      {id =11299, requiredIds ={8624}, rank =7, baseId =2098, cost =33000, isTalent =0},
      -- 7Wound Poison III Rank 3
      {id =13229, rank =3, cost =33000, isTalent =0},
       },
[50] = {
      -- 7Crippling Poison II Rank 2
      {id =3421, rank =2, cost =35000, isTalent =0},
      -- @Kidney Shot Rank 2
      {id =8643, requiredIds ={408}, rank =2, baseId =408, cost =35000, isTalent =0},
      -- @Ambush Rank 5
      {id =11268, requiredIds ={11267}, rank =5, baseId =8676, cost =35000, isTalent =0},
       },
[52] = {
      -- @Rupture Rank 5
      {id =11274, requiredIds ={11273}, rank =5, baseId =1943, cost =46000, isTalent =0},
      -- @Backstab Rank 7
      {id =11280, requiredIds ={11279}, rank =7, baseId =53, cost =46000, isTalent =0},
      -- @Feint Rank 4
      {id =11303, requiredIds ={8637}, rank =4, baseId =1966, cost =46000, isTalent =0},
      -- 7Instant Poison V Rank 5
      {id =11342, rank =5, cost =46000, isTalent =0},
      -- 7Mind-numbing Poison III Rank 3
      {id =11400, rank =3, cost =46000, isTalent =0},
       },
[54] = {
      -- @Garrote Rank 6
      {id =11290, requiredIds ={11289}, rank =6, baseId =703, cost =48000, isTalent =0},
      -- @Sinister Strike Rank 8
      {id =11294, requiredIds ={11293}, rank =8, baseId =1752, cost =48000, isTalent =0},
      -- 7Deadly Poison IV Rank 4
      {id =11358, rank =4, cost =48000, isTalent =0},
       },
[56] = {
      -- @Expose Armor Rank 5
      {id =11198, requiredIds ={11197}, rank =5, baseId =8647, cost =50000, isTalent =0},
      -- @Eviscerate Rank 8
      {id =11300, requiredIds ={11299}, rank =8, baseId =2098, cost =50000, isTalent =0},
      -- 7Wound Poison IV Rank 4
      {id =13230, rank =4, cost =50000, isTalent =0},
       },
[58] = {
      -- @Kick Rank 4
      {id =1769, requiredIds ={1768}, rank =4, baseId =1766, cost =52000, isTalent =0},
      -- @Ambush Rank 6
      {id =11269, requiredIds ={11268}, rank =6, baseId =8676, cost =52000, isTalent =0},
      -- @Sprint Rank 3
      {id =11305, requiredIds ={8696}, rank =3, baseId =2983, cost =52000, isTalent =0},
      -- @Hemorrhage Rank 3
      {id =17348, requiredIds ={17347}, rank =3, baseId =16511, cost =13000, isTalent =1},
       },
[60] = {
      -- @Stealth Rank 4
      {id =1787, requiredIds ={1786}, rank =4, baseId =1784, cost =54000, isTalent =0},
      -- @Rupture Rank 6
      {id =11275, requiredIds ={11274}, rank =6, baseId =1943, cost =54000, isTalent =0},
      -- @Backstab Rank 8
      {id =11281, requiredIds ={11280}, rank =8, baseId =53, cost =54000, isTalent =0},
      -- @Gouge Rank 5
      {id =11286, requiredIds ={11285}, rank =5, baseId =1776, cost =54000, isTalent =0},
      -- 7Instant Poison VI Rank 6
      {id =11343, rank =6, cost =54000, isTalent =0},
      -- @Backstab Rank 9
      {id =25300, requiredIds ={11281}, rank =9, baseId =53, isTalent =0},
      -- @Feint Rank 5
      {id =25302, requiredIds ={11303}, rank =5, baseId =1966, isTalent =0},
      -- 7Deadly Poison V Rank 5
      {id =25347, rank =5, isTalent =0},
      -- @Eviscerate Rank 9
      {id =31016, requiredIds ={11300}, rank =9, baseId =2098, isTalent =0}
        }
}
