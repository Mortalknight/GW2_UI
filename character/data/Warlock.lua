local _, GW = ...
if (GW.myclass ~= "WARLOCK") then
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
[0] = {
      -- @One-Handed Swords undefined
      {id =201, isTalent =0, isSkill =1},
      -- @Staves undefined
      {id =227, isTalent =0, isSkill =1},
      -- @Daggers undefined
      {id =1180, isTalent =0, isSkill =1},
      -- @Wands undefined
      {id =5009, isTalent =0, isSkill =1},
      -- @Cataclysm Rank 1
      {id =17778, rank =1, isTalent =1},
      -- @Cataclysm Rank 2
      {id =17779, requiredIds ={17778}, rank =2, baseId =17778, isTalent =1},
      -- @Cataclysm Rank 3
      {id =17780, requiredIds ={17779}, rank =3, baseId =17778, isTalent =1},
      -- @Cataclysm Rank 4
      {id =17781, requiredIds ={17780}, rank =4, baseId =17778, isTalent =1},
      -- @Cataclysm Rank 5
      {id =17782, requiredIds ={17781}, rank =5, baseId =17778, isTalent =1},
      -- @Fel Concentration Rank 1
      {id =17783, rank =1, isTalent =1},
      -- @Fel Concentration Rank 2
      {id =17784, requiredIds ={17783}, rank =2, baseId =17783, isTalent =1},
      -- @Fel Concentration Rank 3
      {id =17785, requiredIds ={17784}, rank =3, baseId =17783, isTalent =1},
      -- @Fel Concentration Rank 4
      {id =17786, requiredIds ={17785}, rank =4, baseId =17783, isTalent =1},
      -- @Fel Concentration Rank 5
      {id =17787, requiredIds ={17786}, rank =5, baseId =17783, isTalent =1},
      -- @Bane Rank 1
      {id =17788, rank =1, isTalent =1},
      -- @Bane Rank 2
      {id =17789, requiredIds ={17788}, rank =2, baseId =17788, isTalent =1},
      -- @Bane Rank 3
      {id =17790, requiredIds ={17789}, rank =3, baseId =17788, isTalent =1},
      -- @Bane Rank 4
      {id =17791, requiredIds ={17790}, rank =4, baseId =17788, isTalent =1},
      -- @Bane Rank 5
      {id =17792, requiredIds ={17791}, rank =5, baseId =17788, isTalent =1},
      -- @Improved Shadow Bolt Rank 1
      {id =17793, rank =1, isTalent =1},
      -- @Improved Shadow Bolt Rank 2
      {id =17796, requiredIds ={17793}, rank =2, baseId =17793, isTalent =1},
      -- @Improved Shadow Bolt Rank 3
      {id =17801, requiredIds ={17796}, rank =3, baseId =17793, isTalent =1},
      -- @Improved Shadow Bolt Rank 4
      {id =17802, requiredIds ={17801}, rank =4, baseId =17793, isTalent =1},
      -- @Improved Shadow Bolt Rank 5
      {id =17803, requiredIds ={17802}, rank =5, baseId =17793, isTalent =1},
      -- @Improved Drain Life Rank 1
      {id =17804, rank =1, isTalent =1},
      -- @Improved Drain Life Rank 2
      {id =17805, requiredIds ={17804}, rank =2, baseId =17804, isTalent =1},
      -- @Improved Drain Life Rank 3
      {id =17806, requiredIds ={17805}, rank =3, baseId =17804, isTalent =1},
      -- @Improved Drain Life Rank 4
      {id =17807, requiredIds ={17806}, rank =4, baseId =17804, isTalent =1},
      -- @Improved Drain Life Rank 5
      {id =17808, requiredIds ={17807}, rank =5, baseId =17804, isTalent =1},
      -- @Improved Corruption Rank 1
      {id =17810, rank =1, isTalent =1},
      -- @Improved Corruption Rank 2
      {id =17811, requiredIds ={17810}, rank =2, baseId =17810, isTalent =1},
      -- @Improved Corruption Rank 3
      {id =17812, requiredIds ={17811}, rank =3, baseId =17810, isTalent =1},
      -- @Improved Corruption Rank 4
      {id =17813, requiredIds ={17812}, rank =4, baseId =17810, isTalent =1},
      -- @Improved Corruption Rank 5
      {id =17814, requiredIds ={17813}, rank =5, baseId =17810, isTalent =1},
      -- @Improved Immolate Rank 1
      {id =17815, rank =1, isTalent =1},
      -- @Improved Immolate Rank 2
      {id =17833, requiredIds ={17815}, rank =2, baseId =17815, isTalent =1},
      -- @Improved Immolate Rank 3
      {id =17834, requiredIds ={17833}, rank =3, baseId =17815, isTalent =1},
      -- @Improved Immolate Rank 4
      {id =17835, requiredIds ={17834}, rank =4, baseId =17815, isTalent =1},
      -- @Improved Immolate Rank 5
      {id =17836, requiredIds ={17835}, rank =5, baseId =17815, isTalent =1},
      -- @Improved Drain Mana Rank 1
      {id =17864, rank =1, isTalent =1},
      -- @Shadowburn Rank 1
      {id =17877, rank =1, isTalent =1},
      -- @Destructive Reach Rank 1
      {id =17917, rank =1, isTalent =1},
      -- @Destructive Reach Rank 2
      {id =17918, requiredIds ={17917}, rank =2, baseId =17917, isTalent =1},
      -- @Improved Searing Pain Rank 1
      {id =17927, rank =1, isTalent =1},
      -- @Improved Searing Pain Rank 2
      {id =17929, requiredIds ={17927}, rank =2, baseId =17927, isTalent =1},
      -- @Improved Searing Pain Rank 3
      {id =17930, requiredIds ={17929}, rank =3, baseId =17927, isTalent =1},
      -- @Improved Searing Pain Rank 4
      {id =17931, requiredIds ={17930}, rank =4, baseId =17927, isTalent =1},
      -- @Improved Searing Pain Rank 5
      {id =17932, requiredIds ={17931}, rank =5, baseId =17927, isTalent =1},
      -- @Emberstorm Rank 1
      {id =17954, rank =1, isTalent =1},
      -- @Emberstorm Rank 2
      {id =17955, requiredIds ={17954}, rank =2, baseId =17954, isTalent =1},
      -- @Emberstorm  Rank 3
      {id =17956, rank =3, isTalent =1},
      -- @Emberstorm  Rank 4
      {id =17957, requiredIds ={17956}, rank =4, isTalent =1},
      -- @Emberstorm  Rank 5
      {id =17958, requiredIds ={17957}, rank =5, isTalent =1},
      -- @Ruin Rank 1
      {id =17959, rank =1, isTalent =1},
      -- @Conflagrate Rank 1
      {id =17962, rank =1, isTalent =1},
      -- @Pyroclasm Rank 2
      {id =18073, requiredIds ={18096}, rank =2, baseId =18096, isTalent =1},
      -- @Nightfall Rank 1
      {id =18094, rank =1, isTalent =1},
      -- @Nightfall Rank 2
      {id =18095, requiredIds ={18094}, rank =2, baseId =18094, isTalent =1},
      -- @Pyroclasm Rank 1
      {id =18096, rank =1, isTalent =1},
      -- @Aftermath Rank 1
      {id =18119, rank =1, isTalent =1},
      -- @Aftermath Rank 2
      {id =18120, requiredIds ={18119}, rank =2, baseId =18119, isTalent =1},
      -- @Aftermath Rank 3
      {id =18121, requiredIds ={18120}, rank =3, baseId =18119, isTalent =1},
      -- @Aftermath Rank 4
      {id =18122, requiredIds ={18121}, rank =4, baseId =18119, isTalent =1},
      -- @Aftermath Rank 5
      {id =18123, requiredIds ={18122}, rank =5, baseId =18119, isTalent =1},
      -- @Improved Firebolt Rank 1
      {id =18126, rank =1, isTalent =1},
      -- @Improved Firebolt Rank 2
      {id =18127, requiredIds ={18126}, rank =2, baseId =18126, isTalent =1},
      -- @Devastation Rank 1
      {id =18130, rank =1, isTalent =1},
      -- @Devastation Rank 2
      {id =18131, requiredIds ={18130}, rank =2, baseId =18130, isTalent =1},
      -- @Devastation Rank 3
      {id =18132, requiredIds ={18131}, rank =3, baseId =18130, isTalent =1},
      -- @Devastation Rank 4
      {id =18133, requiredIds ={18132}, rank =4, baseId =18130, isTalent =1},
      -- @Devastation Rank 5
      {id =18134, requiredIds ={18133}, rank =5, baseId =18130, isTalent =1},
      -- @Intensity Rank 1
      {id =18135, rank =1, isTalent =1},
      -- @Intensity Rank 2
      {id =18136, requiredIds ={18135}, rank =2, baseId =18135, isTalent =1},
      -- @Suppression Rank 1
      {id =18174, rank =1, isTalent =1},
      -- @Suppression Rank 2
      {id =18175, requiredIds ={18174}, rank =2, baseId =18174, isTalent =1},
      -- @Suppression Rank 3
      {id =18176, requiredIds ={18175}, rank =3, baseId =18174, isTalent =1},
      -- @Suppression Rank 4
      {id =18177, requiredIds ={18176}, rank =4, baseId =18174, isTalent =1},
      -- @Suppression Rank 5
      {id =18178, requiredIds ={18177}, rank =5, baseId =18174, isTalent =1},
      -- @Improved Curse of Weakness Rank 1
      {id =18179, rank =1, isTalent =1},
      -- @Improved Curse of Weakness Rank 2
      {id =18180, requiredIds ={18179}, rank =2, baseId =18179, isTalent =1},
      -- @Improved Curse of Weakness Rank 3
      {id =18181, requiredIds ={18180}, rank =3, baseId =18179, isTalent =1},
      -- @Improved Life Tap Rank 1
      {id =18182, rank =1, isTalent =1},
      -- @Improved Life Tap Rank 2
      {id =18183, requiredIds ={18182}, rank =2, baseId =18182, isTalent =1},
      -- @Improved Drain Soul Rank 1
      {id =18213, rank =1, isTalent =1},
      -- @Grim Reach Rank 1
      {id =18218, rank =1, isTalent =1},
      -- @Grim Reach Rank 2
      {id =18219, requiredIds ={18218}, rank =2, baseId =18218, isTalent =1},
      -- @Dark Pact Rank 1
      {id =18220, rank =1, isTalent =1},
      -- @Curse of Exhaustion undefined
      {id =18223, isTalent =1},
      -- @Siphon Life Rank 1
      {id =18265, rank =1, isTalent =1},
      -- @Shadow Mastery Rank 1
      {id =18271, rank =1, isTalent =1},
      -- @Shadow Mastery Rank 2
      {id =18272, requiredIds ={18271}, rank =2, baseId =18271, isTalent =1},
      -- @Shadow Mastery Rank 3
      {id =18273, requiredIds ={18272}, rank =3, baseId =18271, isTalent =1},
      -- @Shadow Mastery Rank 4
      {id =18274, requiredIds ={18273}, rank =4, baseId =18271, isTalent =1},
      -- @Shadow Mastery Rank 5
      {id =18275, requiredIds ={18274}, rank =5, baseId =18271, isTalent =1},
      -- @Amplify Curse undefined
      {id =18288, isTalent =1},
      -- @Improved Curse of Exhaustion Rank 1
      {id =18310, rank =1, isTalent =1},
      -- @Improved Curse of Exhaustion Rank 2
      {id =18311, requiredIds ={18310}, rank =2, baseId =18310, isTalent =1},
      -- @Improved Curse of Exhaustion Rank 3
      {id =18312, requiredIds ={18311}, rank =3, baseId =18310, isTalent =1},
      -- @Improved Curse of Exhaustion Rank 4
      {id =18313, requiredIds ={18312}, rank =4, baseId =18310, isTalent =1},
      -- @Improved Drain Soul Rank 2
      {id =18372, requiredIds ={18213}, rank =2, baseId =18213, isTalent =1},
      -- @Improved Drain Mana Rank 2
      {id =18393, requiredIds ={17864}, rank =2, baseId =17864, isTalent =1},
      -- @Improved Healthstone Rank 1
      {id =18692, rank =1, isTalent =1},
      -- @Improved Healthstone Rank 2
      {id =18693, requiredIds ={18692}, rank =2, baseId =18692, isTalent =1},
      -- @Improved Imp Rank 1
      {id =18694, rank =1, isTalent =1},
      -- @Improved Imp Rank 2
      {id =18695, requiredIds ={18694}, rank =2, baseId =18694, isTalent =1},
      -- @Improved Imp Rank 3
      {id =18696, requiredIds ={18695}, rank =3, baseId =18694, isTalent =1},
      -- @Demonic Embrace Rank 1
      {id =18697, rank =1, isTalent =1},
      -- @Demonic Embrace Rank 2
      {id =18698, requiredIds ={18697}, rank =2, baseId =18697, isTalent =1},
      -- @Demonic Embrace Rank 3
      {id =18699, requiredIds ={18698}, rank =3, baseId =18697, isTalent =1},
      -- @Demonic Embrace Rank 4
      {id =18700, requiredIds ={18699}, rank =4, baseId =18697, isTalent =1},
      -- @Demonic Embrace Rank 5
      {id =18701, requiredIds ={18700}, rank =5, baseId =18697, isTalent =1},
      -- @Improved Health Funnel Rank 1
      {id =18703, rank =1, isTalent =1},
      -- @Improved Health Funnel Rank 2
      {id =18704, requiredIds ={18703}, rank =2, baseId =18703, isTalent =1},
      -- @Improved Voidwalker Rank 1
      {id =18705, rank =1, isTalent =1},
      -- @Improved Voidwalker Rank 2
      {id =18706, requiredIds ={18705}, rank =2, baseId =18705, isTalent =1},
      -- @Improved Voidwalker Rank 3
      {id =18707, requiredIds ={18706}, rank =3, baseId =18705, isTalent =1},
      -- @Fel Domination undefined
      {id =18708, isTalent =1},
      -- @Master Summoner Rank 1
      {id =18709, rank =1, isTalent =1},
      -- @Master Summoner Rank 2
      {id =18710, requiredIds ={18709}, rank =2, baseId =18709, isTalent =1},
      -- @Fel Intellect Rank 1
      {id =18731, rank =1, isTalent =1},
      -- @Fel Intellect Rank 2
      {id =18743, requiredIds ={18731}, rank =2, baseId =18731, isTalent =1},
      -- @Fel Intellect Rank 3
      {id =18744, requiredIds ={18743}, rank =3, baseId =18731, isTalent =1},
      -- @Fel Intellect Rank 4
      {id =18745, requiredIds ={18744}, rank =4, baseId =18731, isTalent =1},
      -- @Fel Intellect Rank 5
      {id =18746, requiredIds ={18745}, rank =5, baseId =18731, isTalent =1},
      -- @Fel Stamina Rank 4
      {id =18751, rank =4, isTalent =1},
      -- @Fel Stamina Rank 5
      {id =18752, requiredIds ={18751}, rank =5, isTalent =1},
      -- @Improved Succubus Rank 1
      {id =18754, rank =1, isTalent =1},
      -- @Improved Succubus Rank 2
      {id =18755, requiredIds ={18754}, rank =2, baseId =18754, isTalent =1},
      -- @Improved Succubus Rank 3
      {id =18756, requiredIds ={18755}, rank =3, baseId =18754, isTalent =1},
      -- @Improved Firestone Rank 1
      {id =18767, rank =1, isTalent =1},
      -- @Improved Firestone Rank 2
      {id =18768, requiredIds ={18767}, rank =2, baseId =18767, isTalent =1},
      -- @Unholy Power Rank 1
      {id =18769, rank =1, isTalent =1},
      -- @Unholy Power Rank 2
      {id =18770, requiredIds ={18769}, rank =2, baseId =18769, isTalent =1},
      -- @Unholy Power Rank 3
      {id =18771, requiredIds ={18770}, rank =3, baseId =18769, isTalent =1},
      -- @Unholy Power Rank 4
      {id =18772, requiredIds ={18771}, rank =4, baseId =18769, isTalent =1},
      -- @Unholy Power Rank 5
      {id =18773, requiredIds ={18772}, rank =5, baseId =18769, isTalent =1},
      -- @Improved Spellstone Rank 1
      {id =18774, rank =1, isTalent =1},
      -- @Improved Spellstone Rank 2
      {id =18775, requiredIds ={18774}, rank =2, baseId =18774, isTalent =1},
      -- @Demonic Sacrifice undefined
      {id =18788, isTalent =1},
      -- @Improved Enslave Demon Rank 1
      {id =18821, rank =1, isTalent =1},
      -- @Improved Enslave Demon Rank 3
      {id =18823, rank =3, baseId =18821, isTalent =1},
      -- @Improved Enslave Demon Rank 4
      {id =18824, requiredIds ={18823}, rank =4, baseId =18821, isTalent =1},
      -- @Improved Enslave Demon Rank 5
      {id =18825, requiredIds ={18824}, rank =5, baseId =18821, isTalent =1},
      -- @Improved Curse of Agony Rank 1
      {id =18827, rank =1, isTalent =1},
      -- @Improved Curse of Agony Rank 2
      {id =18829, requiredIds ={18827}, rank =2, baseId =18827, isTalent =1},
      -- @Improved Curse of Agony Rank 3
      {id =18830, requiredIds ={18829}, rank =3, baseId =18827, isTalent =1},
      -- @Soul Link undefined
      {id =19028, isTalent =1},
      -- @Master Demonologist undefined
      {id =23785, isTalent =1},
      -- @Master Demonologist undefined
      {id =23822, isTalent =1},
      -- @Master Demonologist undefined
      {id =23823, isTalent =1},
      -- @Master Demonologist undefined
      {id =23824, isTalent =1},
      -- @Master Demonologist undefined
      {id =23825, isTalent =1},
       },
[1] = {
      -- @Immolate Rank 1
      {id =348, rank =1, cost =10, isTalent =0},
      -- @Shadow Bolt Rank 1
      {id =686, rank =1, isTalent =0},
      -- @Demon Skin Rank 1
      {id =687, rank =1, isTalent =0},
      -- @Summon Imp Summon
      {id =688, isTalent =0},
      -- @Shoot undefined
      {id =5019, isTalent =0, isSkill =1},
       },
[4] = {
      -- @Corruption Rank 1
      {id =172, rank =1, cost =100, isTalent =0},
      -- @Curse of Weakness Rank 1
      {id =702, rank =1, cost =100, isTalent =0},
       },
[6] = {
      -- @Shadow Bolt Rank 2
      {id =695, requiredIds ={686}, rank =2, baseId =686, cost =100, isTalent =0},
      -- @Life Tap Rank 1
      {id =1454, rank =1, cost =100, isTalent =0},
       },
[8] = {
      -- @Curse of Agony Rank 1
      {id =980, rank =1, cost =200, isTalent =0},
      -- @Fear Rank 1
      {id =5782, rank =1, cost =200, isTalent =0},
       },
[10] = {
      -- @Demon Skin Rank 2
      {id =696, requiredIds ={687}, rank =2, baseId =687, cost =300, isTalent =0},
      -- @Summon Voidwalker Summon
      {id =697, isTalent =0},
      -- @Immolate Rank 2
      {id =707, requiredIds ={348}, rank =2, baseId =348, cost =300, isTalent =0},
      -- @Drain Soul Rank 1
      {id =1120, rank =1, cost =300, isTalent =0},
      -- @Create Healthstone (Minor) undefined
      {id =6201, cost =300, isTalent =0},
       },
[12] = {
      -- @Shadow Bolt Rank 3
      {id =705, requiredIds ={695}, rank =3, baseId =686, cost =600, isTalent =0},
      -- @Health Funnel Rank 1
      {id =755, rank =1, cost =600, isTalent =0},
      -- @Curse of Weakness Rank 2
      {id =1108, requiredIds ={702}, rank =2, baseId =702, cost =600, isTalent =0},
       },
[14] = {
      -- @Drain Life Rank 1
      {id =689, rank =1, cost =900, isTalent =0},
      -- @Curse of Recklessness Rank 1
      {id =704, rank =1, cost =900, isTalent =0},
      -- @Corruption Rank 2
      {id =6222, requiredIds ={172}, rank =2, baseId =172, cost =900, isTalent =0},
       },
[16] = {
      -- @Life Tap Rank 2
      {id =1455, requiredIds ={1454}, rank =2, baseId =1454, cost =1200, isTalent =0},
      -- @Unending Breath undefined
      {id =5697, cost =1200, isTalent =0},
       },
[18] = {
      -- 7Create Soulstone (Minor) undefined
      {id =693, cost =1500, isTalent =0},
      -- @Curse of Agony Rank 2
      {id =1014, requiredIds ={980}, rank =2, baseId =980, cost =1500, isTalent =0},
      -- @Searing Pain Rank 1
      {id =5676, rank =1, cost =1500, isTalent =0},
       },
[20] = {
      -- @Ritual of Summoning undefined
      {id =698, cost =2000, isTalent =0},
      -- @Demon Armor Rank 1
      {id =706, rank =1, cost =2000, isTalent =0},
      -- @Summon Succubus Summon
      {id =712, isTalent =0},
      -- @Shadow Bolt Rank 4
      {id =1088, requiredIds ={705}, rank =4, baseId =686, cost =2000, isTalent =0},
      -- @Immolate Rank 3
      {id =1094, requiredIds ={707}, rank =3, baseId =348, cost =2000, isTalent =0},
      -- @Health Funnel Rank 2
      {id =3698, requiredIds ={755}, rank =2, baseId =755, cost =2000, isTalent =0},
      -- @Rain of Fire Rank 1
      {id =5740, rank =1, cost =2000, isTalent =0},
       },
[22] = {
      -- @Eye of Kilrogg Summon
      {id =126, cost =2500, isTalent =0},
      -- @Drain Life Rank 2
      {id =699, requiredIds ={689}, rank =2, baseId =689, cost =2500, isTalent =0},
      -- @Create Healthstone (Lesser) undefined
      {id =6202, cost =2500, isTalent =0},
      -- @Curse of Weakness Rank 3
      {id =6205, requiredIds ={1108}, rank =3, baseId =702, cost =2500, isTalent =0},
       },
[24] = {
      -- @Drain Mana Rank 1
      {id =5138, rank =1, cost =3000, isTalent =0},
      -- @Sense Demons undefined
      {id =5500, cost =3000, isTalent =0},
      -- @Corruption Rank 3
      {id =6223, requiredIds ={6222}, rank =3, baseId =172, cost =3000, isTalent =0},
      -- @Drain Soul Rank 2
      {id =8288, requiredIds ={1120}, rank =2, baseId =1120, cost =3000, isTalent =0},
      -- @Shadowburn Rank 2
      {id =18867, requiredIds ={17877}, rank =2, baseId =17877, cost =150, isTalent =1},
       },
[26] = {
      -- @Detect Lesser Invisibility undefined
      {id =132, cost =4000, isTalent =0},
      -- @Life Tap Rank 3
      {id =1456, requiredIds ={1455}, rank =3, baseId =1454, cost =4000, isTalent =0},
      -- @Curse of Tongues Rank 1
      {id =1714, rank =1, cost =4000, isTalent =0},
      -- @Searing Pain Rank 2
      {id =17919, requiredIds ={5676}, rank =2, baseId =5676, cost =4000, isTalent =0},
       },
[28] = {
      -- @Banish Rank 1
      {id =710, rank =1, cost =5000, isTalent =0},
      -- @Shadow Bolt Rank 5
      {id =1106, requiredIds ={1088}, rank =5, baseId =686, cost =5000, isTalent =0},
      -- @Health Funnel Rank 3
      {id =3699, requiredIds ={3698}, rank =3, baseId =755, cost =5000, isTalent =0},
      -- @Curse of Agony Rank 3
      {id =6217, requiredIds ={1014}, rank =3, baseId =980, cost =5000, isTalent =0},
      -- 7Create Firestone (Lesser) undefined
      {id =6366, cost =5000, isTalent =0},
      -- @Curse of Recklessness Rank 2
      {id =7658, requiredIds ={704}, rank =2, baseId =704, cost =5000, isTalent =0},
       },
[30] = {
      -- @Summon Felhunter Summon
      {id =691, isTalent =0},
      -- @Drain Life Rank 3
      {id =709, requiredIds ={699}, rank =3, baseId =689, cost =6000, isTalent =0},
      -- @Demon Armor Rank 2
      {id =1086, requiredIds ={706}, rank =2, baseId =706, cost =6000, isTalent =0},
      -- @Enslave Demon Rank 1
      {id =1098, rank =1, cost =6000, isTalent =0},
      -- @Hellfire Rank 1
      {id =1949, rank =1, cost =6000, isTalent =0},
      -- @Immolate Rank 4
      {id =2941, requiredIds ={1094}, rank =4, baseId =348, cost =6000, isTalent =0},
      -- 7Create Soulstone (Lesser) undefined
      {id =20752, cost =6000, isTalent =0},
       },
[32] = {
      -- @Curse of the Elements Rank 1
      {id =1490, rank =1, cost =7000, isTalent =0},
      -- @Fear Rank 2
      {id =6213, requiredIds ={5782}, rank =2, baseId =5782, cost =7000, isTalent =0},
      -- @Shadow Ward Rank 1
      {id =6229, rank =1, cost =7000, isTalent =0},
      -- @Curse of Weakness Rank 4
      {id =7646, requiredIds ={6205}, rank =4, baseId =702, cost =7000, isTalent =0},
      -- @Shadowburn Rank 3
      {id =18868, requiredIds ={18867}, rank =3, baseId =17877, cost =350, isTalent =1},
       },
[34] = {
      -- @Create Healthstone undefined
      {id =5699, cost =8000, isTalent =0},
      -- @Rain of Fire Rank 2
      {id =6219, requiredIds ={5740}, rank =2, baseId =5740, cost =8000, isTalent =0},
      -- @Drain Mana Rank 2
      {id =6226, requiredIds ={5138}, rank =2, baseId =5138, cost =8000, isTalent =0},
      -- @Corruption Rank 4
      {id =7648, requiredIds ={6223}, rank =4, baseId =172, cost =8000, isTalent =0},
      -- @Searing Pain Rank 3
      {id =17920, requiredIds ={17919}, rank =3, baseId =5676, cost =8000, isTalent =0},
       },
[36] = {
      -- 7Create Spellstone undefined
      {id =2362, cost =9000, isTalent =0},
      -- @Health Funnel Rank 4
      {id =3700, requiredIds ={3699}, rank =4, baseId =755, cost =9000, isTalent =0},
      -- @Shadow Bolt Rank 6
      {id =7641, requiredIds ={1106}, rank =6, baseId =686, cost =9000, isTalent =0},
      -- @Life Tap Rank 4
      {id =11687, requiredIds ={1456}, rank =4, baseId =1454, cost =9000, isTalent =0},
      -- 7Create Firestone undefined
      {id =17951, cost =9000, isTalent =0},
       },
[38] = {
      -- @Detect Invisibility undefined
      {id =2970, cost =10000, isTalent =0},
      -- @Drain Life Rank 4
      {id =7651, requiredIds ={709}, rank =4, baseId =689, cost =10000, isTalent =0},
      -- @Drain Soul Rank 3
      {id =8289, requiredIds ={8288}, rank =3, baseId =1120, cost =10000, isTalent =0},
      -- @Curse of Agony Rank 4
      {id =11711, requiredIds ={6217}, rank =4, baseId =980, cost =10000, isTalent =0},
      -- @Siphon Life Rank 2
      {id =18879, requiredIds ={18265}, rank =2, baseId =18265, cost =500, isTalent =1},
       },
[40] = {
      -- @Howl of Terror Rank 1
      {id =5484, rank =1, cost =11000, isTalent =0},
      -- @Summon Felsteed Summon
      {id =5784, isTalent =0},
      -- @Immolate Rank 5
      {id =11665, requiredIds ={2941}, rank =5, baseId =348, cost =11000, isTalent =0},
      -- @Demon Armor Rank 3
      {id =11733, requiredIds ={1086}, rank =3, baseId =706, cost =11000, isTalent =0},
      -- @Shadowburn Rank 4
      {id =18869, requiredIds ={18868}, rank =4, baseId =17877, cost =550, isTalent =1},
      -- 7Create Soulstone undefined
      {id =20755, cost =11000, isTalent =0},
       },
[42] = {
      -- @Death Coil Rank 1
      {id =6789, rank =1, cost =11000, isTalent =0},
      -- @Curse of Recklessness Rank 3
      {id =7659, requiredIds ={7658}, rank =3, baseId =704, cost =11000, isTalent =0},
      -- @Hellfire Rank 2
      {id =11683, requiredIds ={1949}, rank =2, baseId =1949, cost =11000, isTalent =0},
      -- @Curse of Weakness Rank 5
      {id =11707, requiredIds ={7646}, rank =5, baseId =702, cost =11000, isTalent =0},
      -- @Shadow Ward Rank 2
      {id =11739, requiredIds ={6229}, rank =2, baseId =6229, cost =11000, isTalent =0},
      -- @Searing Pain Rank 4
      {id =17921, requiredIds ={17920}, rank =4, baseId =5676, cost =11000, isTalent =0},
       },
[44] = {
      -- @Shadow Bolt Rank 7
      {id =11659, requiredIds ={7641}, rank =7, baseId =686, cost =12000, isTalent =0},
      -- @Corruption Rank 5
      {id =11671, requiredIds ={7648}, rank =5, baseId =172, cost =12000, isTalent =0},
      -- @Health Funnel Rank 5
      {id =11693, requiredIds ={3700}, rank =5, baseId =755, cost =12000, isTalent =0},
      -- @Drain Mana Rank 3
      {id =11703, requiredIds ={6226}, rank =3, baseId =5138, cost =12000, isTalent =0},
      -- @Enslave Demon Rank 2
      {id =11725, requiredIds ={1098}, rank =2, baseId =1098, cost =12000, isTalent =0},
      -- @Curse of Shadow Rank 1
      {id =17862, rank =1, cost =12000, isTalent =0},
       },
[46] = {
      -- @Rain of Fire Rank 3
      {id =11677, requiredIds ={6219}, rank =3, baseId =5740, cost =13000, isTalent =0},
      -- @Life Tap Rank 5
      {id =11688, requiredIds ={11687}, rank =5, baseId =1454, cost =13000, isTalent =0},
      -- @Drain Life Rank 5
      {id =11699, requiredIds ={7651}, rank =5, baseId =689, cost =13000, isTalent =0},
      -- @Curse of the Elements Rank 2
      {id =11721, requiredIds ={1490}, rank =2, baseId =1490, cost =13000, isTalent =0},
      -- @Create Healthstone (Greater) undefined
      {id =11729, cost =13000, isTalent =0},
      -- 7Create Firestone (Greater) undefined
      {id =17952, cost =13000, isTalent =0},
       },
[48] = {
      -- @Soul Fire Rank 1
      {id =6353, rank =1, cost =14000, isTalent =0},
      -- @Curse of Agony Rank 5
      {id =11712, requiredIds ={11711}, rank =5, baseId =980, cost =14000, isTalent =0},
      -- 7Create Spellstone (Greater) undefined
      {id =17727, cost =14000, isTalent =0},
      -- @Banish Rank 2
      {id =18647, requiredIds ={710}, rank =2, baseId =710, cost =14000, isTalent =0},
      -- @Shadowburn Rank 5
      {id =18870, requiredIds ={18869}, rank =5, baseId =17877, cost =700, isTalent =1},
      -- @Siphon Life Rank 3
      {id =18880, requiredIds ={18879}, rank =3, baseId =18265, cost =700, isTalent =1},
      -- @Conflagrate Rank 2
      {id =18930, requiredIds ={17962}, rank =2, baseId =17962, cost =700, isTalent =1},
       },
[50] = {
      -- @Inferno Summon
      {id =1122, isTalent =0},
      -- @Immolate Rank 6
      {id =11667, requiredIds ={11665}, rank =6, baseId =348, cost =15000, isTalent =0},
      -- @Curse of Tongues Rank 2
      {id =11719, requiredIds ={1714}, rank =2, baseId =1714, cost =15000, isTalent =0},
      -- @Demon Armor Rank 4
      {id =11734, requiredIds ={11733}, rank =4, baseId =706, cost =15000, isTalent =0},
      -- @Detect Greater Invisibility undefined
      {id =11743, cost =15000, isTalent =0},
      -- @Searing Pain Rank 5
      {id =17922, requiredIds ={17921}, rank =5, baseId =5676, cost =15000, isTalent =0},
      -- @Death Coil Rank 2
      {id =17925, requiredIds ={6789}, rank =2, baseId =6789, cost =15000, isTalent =0},
      -- @Dark Pact Rank 2
      {id =18937, requiredIds ={18220}, rank =2, baseId =18220, cost =750, isTalent =1},
      -- 7Create Soulstone (Greater) undefined
      {id =20756, cost =15000, isTalent =0},
       },
[52] = {
      -- @Shadow Bolt Rank 8
      {id =11660, requiredIds ={11659}, rank =8, baseId =686, cost =18000, isTalent =0},
      -- @Drain Soul Rank 4
      {id =11675, requiredIds ={8289}, rank =4, baseId =1120, cost =18000, isTalent =0},
      -- @Health Funnel Rank 6
      {id =11694, requiredIds ={11693}, rank =6, baseId =755, cost =18000, isTalent =0},
      -- @Curse of Weakness Rank 6
      {id =11708, requiredIds ={11707}, rank =6, baseId =702, cost =18000, isTalent =0},
      -- @Shadow Ward Rank 3
      {id =11740, requiredIds ={11739}, rank =3, baseId =6229, cost =18000, isTalent =0},
       },
[54] = {
      -- @Corruption Rank 6
      {id =11672, requiredIds ={11671}, rank =6, baseId =172, cost =20000, isTalent =0},
      -- @Hellfire Rank 3
      {id =11684, requiredIds ={11683}, rank =3, baseId =1949, cost =20000, isTalent =0},
      -- @Drain Life Rank 6
      {id =11700, requiredIds ={11699}, rank =6, baseId =689, cost =20000, isTalent =0},
      -- @Drain Mana Rank 4
      {id =11704, requiredIds ={11703}, rank =4, baseId =5138, cost =20000, isTalent =0},
      -- @Howl of Terror Rank 2
      {id =17928, requiredIds ={5484}, rank =2, baseId =5484, cost =20000, isTalent =0},
      -- @Conflagrate Rank 3
      {id =18931, requiredIds ={18930}, rank =3, baseId =17962, cost =1000, isTalent =1},
       },
[56] = {
      -- @Fear Rank 3
      {id =6215, requiredIds ={6213}, rank =3, baseId =5782, cost =22000, isTalent =0},
      -- @Life Tap Rank 6
      {id =11689, requiredIds ={11688}, rank =6, baseId =1454, cost =22000, isTalent =0},
      -- @Curse of Recklessness Rank 4
      {id =11717, requiredIds ={7659}, rank =4, baseId =704, cost =22000, isTalent =0},
      -- @Soul Fire Rank 2
      {id =17924, requiredIds ={6353}, rank =2, baseId =6353, cost =22000, isTalent =0},
      -- @Curse of Shadow Rank 2
      {id =17937, requiredIds ={17862}, rank =2, baseId =17862, cost =22000, isTalent =0},
      -- 7Create Firestone (Major) undefined
      {id =17953, cost =22000, isTalent =0},
      -- @Shadowburn Rank 6
      {id =18871, requiredIds ={18870}, rank =6, baseId =17877, cost =1100, isTalent =1},
       },
[58] = {
      -- @Rain of Fire Rank 4
      {id =11678, requiredIds ={11677}, rank =4, baseId =5740, cost =24000, isTalent =0},
      -- @Curse of Agony Rank 6
      {id =11713, requiredIds ={11712}, rank =6, baseId =980, cost =24000, isTalent =0},
      -- @Enslave Demon Rank 3
      {id =11726, requiredIds ={11725}, rank =3, baseId =1098, cost =24000, isTalent =0},
      -- @Create Healthstone (Major) undefined
      {id =11730, cost =24000, isTalent =0},
      -- @Searing Pain Rank 6
      {id =17923, requiredIds ={17922}, rank =6, baseId =5676, cost =24000, isTalent =0},
      -- @Death Coil Rank 3
      {id =17926, requiredIds ={17925}, rank =3, baseId =6789, cost =24000, isTalent =0},
      -- @Siphon Life Rank 4
      {id =18881, requiredIds ={18880}, rank =4, baseId =18265, cost =1200, isTalent =1},
       },
[60] = {
      -- @Curse of Doom undefined
      {id =603, cost =26000, isTalent =0},
      -- @Shadow Bolt Rank 9
      {id =11661, requiredIds ={11660}, rank =9, baseId =686, cost =26000, isTalent =0},
      -- @Immolate Rank 7
      {id =11668, requiredIds ={11667}, rank =7, baseId =348, cost =26000, isTalent =0},
      -- @Health Funnel Rank 7
      {id =11695, requiredIds ={11694}, rank =7, baseId =755, cost =26000, isTalent =0},
      -- @Curse of the Elements Rank 3
      {id =11722, requiredIds ={11721}, rank =3, baseId =1490, cost =26000, isTalent =0},
      -- @Demon Armor Rank 5
      {id =11735, requiredIds ={11734}, rank =5, baseId =706, cost =26000, isTalent =0},
      -- 7Create Spellstone (Major) undefined
      {id =17728, cost =26000, isTalent =0},
      -- @Ritual of Doom undefined
      {id =18540, isTalent =0},
      -- @Conflagrate Rank 4
      {id =18932, requiredIds ={18931}, rank =4, baseId =17962, cost =1300, isTalent =1},
      -- @Dark Pact Rank 3
      {id =18938, requiredIds ={18937}, rank =3, baseId =18220, cost =1300, isTalent =1},
      -- 7Create Soulstone (Major) undefined
      {id =20757, cost =26000, isTalent =0},
      -- @Summon Dreadsteed Summon
      {id =23161, isTalent =0},
      -- @Shadow Bolt Rank 10
      {id =25307, requiredIds ={11661}, rank =10, baseId =686, isTalent =0},
      -- @Immolate Rank 8
      {id =25309, requiredIds ={11668}, rank =8, baseId =348, isTalent =0},
      -- @Corruption Rank 7
      {id =25311, requiredIds ={11672}, rank =7, baseId =172, isTalent =0},
      -- @Shadow Ward Rank 4
      {id =28610, requiredIds ={11740}, rank =4, baseId =6229, isTalent =0}
        }
}
