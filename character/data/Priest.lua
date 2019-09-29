local _, GW = ...
if (GW.currentClass ~= "PRIEST") then return end
GW.SpellsByLevel = GW.RaceFilter(

 {
 [0] = {
      -- @One-Handed Maces undefined
      {id =198, isTalent =0},
      -- @Staves undefined
      {id =227, isTalent =0},
      -- @Lightwell Rank 1
      {id =724, isTalent =1},
      -- @Daggers undefined
      {id =1180, isTalent =0},
      -- @Wands undefined
      {id =5009, isTalent =0},
      -- @Power Infusion undefined
      {id =10060, isTalent =1},
      -- @Mental Agility Rank 1
      {id =14520, isTalent =1},
      -- @Meditation Rank 1
      {id =14521, isTalent =1},
      -- @Unbreakable Will Rank 1
      {id =14522, isTalent =1},
      -- @Silent Resolve Rank 1
      {id =14523, isTalent =1},
      -- @Wand Specialization Rank 1
      {id =14524, isTalent =1},
      -- @Wand Specialization Rank 2
      {id =14525, requiredIds ={14524}, isTalent =1},
      -- @Wand Specialization Rank 3
      {id =14526, requiredIds ={14525}, isTalent =1},
      -- @Wand Specialization Rank 4
      {id =14527, requiredIds ={14526}, isTalent =1},
      -- @Wand Specialization Rank 5
      {id =14528, requiredIds ={14527}, isTalent =1},
      -- @Martyrdom Rank 1
      {id =14531, isTalent =1},
      -- @Improved Inner Fire Rank 1
      {id =14747, isTalent =1},
      -- @Improved Power Word: Shield Rank 1
      {id =14748, isTalent =1},
      -- @Improved Power Word: Fortitude Rank 1
      {id =14749, isTalent =1},
      -- @Improved Mana Burn Rank 1
      {id =14750, isTalent =1},
      -- @Inner Focus undefined
      {id =14751, isTalent =1},
      -- @Divine Spirit Rank 1
      {id =14752, isTalent =1},
      -- @Improved Power Word: Fortitude Rank 2
      {id =14767, requiredIds ={14749}, isTalent =1},
      -- @Improved Power Word: Shield Rank 2
      {id =14768, requiredIds ={14748}, isTalent =1},
      -- @Improved Power Word: Shield Rank 3
      {id =14769, requiredIds ={14768}, isTalent =1},
      -- @Improved Inner Fire Rank 2
      {id =14770, requiredIds ={14747}, isTalent =1},
      -- @Improved Inner Fire Rank 3
      {id =14771, requiredIds ={14770}, isTalent =1},
      -- @Improved Mana Burn Rank 2
      {id =14772, requiredIds ={14750}, isTalent =1},
      -- @Martyrdom Rank 2
      {id =14774, requiredIds ={14531}, isTalent =1},
      -- @Meditation Rank 2
      {id =14776, requiredIds ={14521}, isTalent =1},
      -- @Meditation Rank 3
      {id =14777, requiredIds ={14776}, isTalent =1},
      -- @Mental Agility Rank 2
      {id =14780, requiredIds ={14520}, isTalent =1},
      -- @Mental Agility Rank 3
      {id =14781, requiredIds ={14780}, isTalent =1},
      -- @Mental Agility Rank 4
      {id =14782, requiredIds ={14781}, isTalent =1},
      -- @Mental Agility Rank 5
      {id =14783, requiredIds ={14782}, isTalent =1},
      -- @Silent Resolve Rank 2
      {id =14784, requiredIds ={14523}, isTalent =1},
      -- @Silent Resolve Rank 3
      {id =14785, requiredIds ={14784}, isTalent =1},
      -- @Silent Resolve Rank 4
      {id =14786, requiredIds ={14785}, isTalent =1},
      -- @Silent Resolve Rank 5
      {id =14787, requiredIds ={14786}, isTalent =1},
      -- @Unbreakable Will Rank 2
      {id =14788, requiredIds ={14522}, isTalent =1},
      -- @Unbreakable Will Rank 3
      {id =14789, requiredIds ={14788}, isTalent =1},
      -- @Unbreakable Will Rank 4
      {id =14790, requiredIds ={14789}, isTalent =1},
      -- @Unbreakable Will Rank 5
      {id =14791, requiredIds ={14790}, isTalent =1},
      -- @Holy Specialization Rank 1
      {id =14889, isTalent =1},
      -- @Inspiration Rank 1
      {id =14892, isTalent =1},
      -- @Spiritual Healing Rank 1
      {id =14898, isTalent =1},
      -- @Spiritual Guidance Rank 1
      {id =14901, isTalent =1},
      -- @Improved Renew Rank 1
      {id =14908, isTalent =1},
      -- @Searing Light Rank 1
      {id =14909, isTalent =1},
      -- @Improved Prayer of Healing Rank 1
      {id =14911, isTalent =1},
      -- @Improved Healing Rank 1
      {id =14912, isTalent =1},
      -- @Healing Focus Rank 1
      {id =14913, isTalent =1},
      -- @Holy Specialization Rank 2
      {id =15008, requiredIds ={14889}, isTalent =1},
      -- @Holy Specialization Rank 3
      {id =15009, requiredIds ={15008}, isTalent =1},
      -- @Holy Specialization Rank 4
      {id =15010, requiredIds ={15009}, isTalent =1},
      -- @Holy Specialization Rank 5
      {id =15011, requiredIds ={15010}, isTalent =1},
      -- @Healing Focus Rank 2
      {id =15012, requiredIds ={14913}, isTalent =1},
      -- @Improved Healing Rank 2
      {id =15013, requiredIds ={14912}, isTalent =1},
      -- @Improved Healing Rank 3
      {id =15014, requiredIds ={15013}, isTalent =1},
      -- @Searing Light Rank 2
      {id =15017, requiredIds ={14909}, isTalent =1},
      -- @Improved Prayer of Healing Rank 2
      {id =15018, requiredIds ={14911}, isTalent =1},
      -- @Improved Prayer of Healing Rank 3
      {id =15019, requiredIds ={15018}, isTalent =0},
      -- @Improved Renew Rank 2
      {id =15020, requiredIds ={14908}, isTalent =1},
      -- @Spiritual Guidance Rank 2
      {id =15028, requiredIds ={14901}, isTalent =1},
      -- @Spiritual Guidance Rank 3
      {id =15029, requiredIds ={15028}, isTalent =1},
      -- @Spiritual Guidance Rank 4
      {id =15030, requiredIds ={15029}, isTalent =1},
      -- @Spiritual Guidance Rank 5
      {id =15031, requiredIds ={15030}, isTalent =1},
      -- @Holy Nova Rank 1
      {id =15237, isTalent =1},
      -- @Shadow Weaving Rank 1
      {id =15257, isTalent =1},
      -- @Darkness Rank 1
      {id =15259, isTalent =1},
      -- @Shadow Focus Rank 1
      {id =15260, isTalent =1},
      -- @Blackout Rank 1
      {id =15268, isTalent =1},
      -- @Spirit Tap Rank 1
      {id =15270, isTalent =1},
      -- @Shadow Affinity Rank 2
      {id =15272, requiredIds ={15318}, isTalent =1},
      -- @Improved Mind Blast Rank 1
      {id =15273, isTalent =1},
      -- @Improved Fade Rank 1
      {id =15274, isTalent =1},
      -- @Improved Shadow Word: Pain Rank 1
      {id =15275, isTalent =1},
      -- @Vampiric Embrace undefined
      {id =15286, isTalent =1},
      -- @Darkness Rank 2
      {id =15307, requiredIds ={15259}, isTalent =1},
      -- @Darkness Rank 3
      {id =15308, requiredIds ={15307}, isTalent =1},
      -- @Darkness Rank 4
      {id =15309, requiredIds ={15308}, isTalent =1},
      -- @Darkness Rank 5
      {id =15310, requiredIds ={15309}, isTalent =1},
      -- @Improved Fade Rank 2
      {id =15311, requiredIds ={15274}, isTalent =1},
      -- @Improved Mind Blast Rank 2
      {id =15312, requiredIds ={15273}, isTalent =1},
      -- @Improved Mind Blast Rank 3
      {id =15313, requiredIds ={15312}, isTalent =1},
      -- @Improved Mind Blast Rank 4
      {id =15314, requiredIds ={15313}, isTalent =1},
      -- @Improved Mind Blast Rank 5
      {id =15316, requiredIds ={15314}, isTalent =1},
      -- @Improved Shadow Word: Pain Rank 2
      {id =15317, requiredIds ={15275}, isTalent =1},
      -- @Shadow Affinity Rank 1
      {id =15318, isTalent =1},
      -- @Shadow Affinity Rank 3
      {id =15320, requiredIds ={15272}, isTalent =1},
      -- @Blackout Rank 2
      {id =15323, requiredIds ={15268}, isTalent =1},
      -- @Blackout Rank 3
      {id =15324, requiredIds ={15323}, isTalent =1},
      -- @Blackout Rank 4
      {id =15325, requiredIds ={15324}, isTalent =1},
      -- @Blackout Rank 5
      {id =15326, requiredIds ={15325}, isTalent =1},
      -- @Shadow Focus Rank 2
      {id =15327, requiredIds ={15260}, isTalent =1},
      -- @Shadow Focus Rank 3
      {id =15328, requiredIds ={15327}, isTalent =1},
      -- @Shadow Weaving Rank 2
      {id =15331, requiredIds ={15257}, isTalent =1},
      -- @Shadow Weaving Rank 3
      {id =15332, requiredIds ={15331}, isTalent =1},
      -- @Shadow Weaving Rank 4
      {id =15333, requiredIds ={15332}, isTalent =1},
      -- @Shadow Weaving Rank 5
      {id =15334, requiredIds ={15333}, isTalent =1},
      -- @Spirit Tap Rank 2
      {id =15335, requiredIds ={15270}, isTalent =1},
      -- @Spirit Tap Rank 3
      {id =15336, requiredIds ={15335}, isTalent =1},
      -- @Spirit Tap Rank 4
      {id =15337, requiredIds ={15336}, isTalent =1},
      -- @Spirit Tap Rank 5
      {id =15338, requiredIds ={15337}, isTalent =1},
      -- @Spiritual Healing Rank 2
      {id =15349, requiredIds ={14898}, isTalent =1},
      -- @Spiritual Healing Rank 3
      {id =15354, requiredIds ={15349}, isTalent =1},
      -- @Spiritual Healing Rank 4
      {id =15355, requiredIds ={15354}, isTalent =1},
      -- @Spiritual Healing Rank 5
      {id =15356, requiredIds ={15355}, isTalent =1},
      -- @Inspiration Rank 2
      {id =15362, requiredIds ={14892}, isTalent =1},
      -- @Inspiration Rank 3
      {id =15363, requiredIds ={15362}, isTalent =1},
      -- @Improved Psychic Scream Rank 1
      {id =15392, isTalent =1},
      -- @Mind Flay Rank 1
      {id =15407, isTalent =1},
      -- @Improved Psychic Scream Rank 2
      {id =15448, requiredIds ={15392}, isTalent =1},
      -- @Shadowform undefined
      {id =15473, isTalent =1},
      -- @Silence undefined
      {id =15487, isTalent =1},
      -- @Improved Renew Rank 3
      {id =17191, requiredIds ={15020}, isTalent =1},
      -- @Shadow Reach Rank 1
      {id =17322, isTalent =1},
      -- @Shadow Reach Rank 2
      {id =17323, requiredIds ={17322}, isTalent =1},
      -- @Shadow Reach Rank 3
      {id =17325, requiredIds ={17323}, isTalent =1},
      -- @Divine Fury Rank 1
      {id =18530, isTalent =1},
      -- @Divine Fury Rank 2
      {id =18531, requiredIds ={18530}, isTalent =1},
      -- @Divine Fury Rank 3
      {id =18533, requiredIds ={18531}, isTalent =1},
      -- @Divine Fury Rank 4
      {id =18534, requiredIds ={18533}, isTalent =1},
      -- @Divine Fury Rank 5
      {id =18535, requiredIds ={18534}, isTalent =1},
      -- @Force of Will Rank 1
      {id =18544, isTalent =1},
      -- @Force of Will Rank 2
      {id =18547, requiredIds ={18544}, isTalent =1},
      -- @Force of Will Rank 3
      {id =18548, requiredIds ={18547}, isTalent =1},
      -- @Force of Will Rank 4
      {id =18549, requiredIds ={18548}, isTalent =1},
      -- @Force of Will Rank 5
      {id =18550, requiredIds ={18549}, isTalent =1},
      -- @Mental Strength Rank 1
      {id =18551, isTalent =1},
      -- @Mental Strength Rank 2
      {id =18552, requiredIds ={18551}, isTalent =1},
      -- @Mental Strength Rank 3
      {id =18553, requiredIds ={18552}, isTalent =1},
      -- @Mental Strength Rank 4
      {id =18554, requiredIds ={18553}, isTalent =1},
      -- @Mental Strength Rank 5
      {id =18555, requiredIds ={18554}, isTalent =1},
      -- @Spirit of Redemption undefined
      {id =20711, isTalent =1},
      -- @Holy Reach Rank 1
      {id =27789, isTalent =1},
      -- @Holy Reach Rank 2
      {id =27790, requiredIds ={27789}, isTalent =1},
      -- @Blessed Recovery Rank 1
      {id =27811, isTalent =1},
      -- @Blessed Recovery Rank 2
      {id =27815, requiredIds ={27811}, isTalent =1},
      -- @Blessed Recovery Rank 3
      {id =27816, requiredIds ={27815}, isTalent =1},
      -- @Improved Vampiric Embrace Rank 1
      {id =27839, isTalent =1},
      -- @Improved Vampiric Embrace Rank 2
      {id =27840, requiredIds ={27839}, isTalent =1},
      -- @Spell Warding Rank 1
      {id =27900, isTalent =1},
      -- @Spell Warding Rank 2
      {id =27901, requiredIds ={27900}, isTalent =1},
      -- @Spell Warding Rank 3
      {id =27902, requiredIds ={27901}, isTalent =1},
      -- @Spell Warding Rank 4
      {id =27903, requiredIds ={27902}, isTalent =1},
      -- @Spell Warding Rank 5
      {id =27904, requiredIds ={27903}, isTalent =1},
       },
[1] = {
      -- @Smite Rank 1
      {id =585, isTalent =0},
      -- @Power Word: Fortitude Rank 1
      {id =1243, cost =10, isTalent =0},
      -- @Lesser Heal Rank 1
      {id =2050, isTalent =0},
      -- @Shoot undefined
      {id =5019, isTalent =0},
       },
[4] = {
      -- @Shadow Word: Pain Rank 1
      {id =589, cost =100, isTalent =0},
      -- @Lesser Heal Rank 2
      {id =2052, requiredIds ={2050}, cost =100, isTalent =0},
       },
[6] = {
      -- @Power Word: Shield Rank 1
      {id =17, cost =100, isTalent =0},
      -- @Smite Rank 2
      {id =591, requiredIds ={585}, cost =100, isTalent =0},
       },
[8] = {
      -- @Renew Rank 1
      {id =139, cost =200, isTalent =0},
      -- @Fade Rank 1
      {id =586, cost =200, isTalent =0},
       },
[10] = {
      -- @Shadow Word: Pain Rank 2
      {id =594, requiredIds ={589}, cost =300, isTalent =0},
      -- @Resurrection Rank 1
      {id =2006, cost =300, isTalent =0},
      -- @Lesser Heal Rank 3
      {id =2053, requiredIds ={2052}, cost =300, isTalent =0},
      -- @Touch of Weakness Rank 1
      {id =2652, race =5, isTalent =0},
      -- @Mind Blast Rank 1
      {id =8092, cost =300, isTalent =0},
      -- @Hex of Weakness Rank 1
      {id =9035, race =8, isTalent =0},
      -- @Starshards Rank 1
      {id =10797, race =4, isTalent =0},
      -- @Desperate Prayer Rank 1
      {id =13908, races ={1, 3}, isTalent =0},
       },
[12] = {
      -- @Inner Fire Rank 1
      {id =588, cost =800, isTalent =0},
      -- @Power Word: Shield Rank 2
      {id =592, requiredIds ={17}, cost =800, isTalent =0},
      -- @Power Word: Fortitude Rank 2
      {id =1244, requiredIds ={1243}, cost =800, isTalent =0},
       },
[14] = {
      -- @Cure Disease undefined
      {id =528, cost =1200, isTalent =0},
      -- @Smite Rank 3
      {id =598, requiredIds ={591}, cost =1200, isTalent =0},
      -- @Renew Rank 2
      {id =6074, requiredIds ={139}, cost =1200, isTalent =0},
      -- @Psychic Scream Rank 1
      {id =8122, cost =1200, isTalent =0},
       },
[16] = {
      -- @Heal Rank 1
      {id =2054, cost =1600, isTalent =0},
      -- @Mind Blast Rank 2
      {id =8102, requiredIds ={8092}, cost =1600, isTalent =0},
       },
[18] = {
      -- @Dispel Magic Rank 1
      {id =527, cost =2000, isTalent =0},
      -- @Power Word: Shield Rank 3
      {id =600, requiredIds ={592}, cost =2000, isTalent =0},
      -- @Shadow Word: Pain Rank 3
      {id =970, requiredIds ={594}, cost =2000, isTalent =0},
      -- @Desperate Prayer Rank 2
      {id =19236, requiredIds ={13908}, races ={1, 3}, cost =100, isTalent =0},
      -- @Starshards Rank 2
      {id =19296, requiredIds ={10797}, race =4, cost =100, isTalent =0},
       },
[20] = {
      -- @Mind Soothe Rank 1
      {id =453, cost =3000, isTalent =0},
      -- @Flash Heal Rank 1
      {id =2061, cost =3000, isTalent =0},
      -- @Elune's Grace Rank 1
      {id =2651, race =4, isTalent =0},
      -- @Devouring Plague Rank 1
      {id =2944, race =5, isTalent =0},
      -- @Renew Rank 3
      {id =6075, requiredIds ={6074}, cost =3000, isTalent =0},
      -- @Fear Ward undefined
      {id =6346, race =3, isTalent =0},
      -- @Inner Fire Rank 2
      {id =7128, requiredIds ={588}, cost =3000, isTalent =0},
      -- @Shackle Undead Rank 1
      {id =9484, cost =3000, isTalent =0},
      -- @Fade Rank 2
      {id =9578, requiredIds ={586}, cost =3000, isTalent =0},
      -- @Feedback Rank 1
      {id =13896, race =1, isTalent =0},
      -- @Holy Fire Rank 1
      {id =14914, cost =3000, isTalent =0},
      -- @Shadowguard Rank 1
      {id =18137, race =8, isTalent =0},
      -- @Touch of Weakness Rank 2
      {id =19261, requiredIds ={2652}, race =5, cost =150, isTalent =0},
      -- @Hex of Weakness Rank 2
      {id =19281, requiredIds ={9035}, race =8, cost =150, isTalent =0},
       },
[22] = {
      -- @Smite Rank 4
      {id =984, requiredIds ={598}, cost =4000, isTalent =0},
      -- @Resurrection Rank 2
      {id =2010, requiredIds ={2006}, cost =4000, isTalent =0},
      -- @Heal Rank 2
      {id =2055, requiredIds ={2054}, cost =4000, isTalent =0},
      -- @Mind Vision Rank 1
      {id =2096, cost =4000, isTalent =0},
      -- @Mind Blast Rank 3
      {id =8103, requiredIds ={8102}, cost =4000, isTalent =0},
       },
[24] = {
      -- @Power Word: Fortitude Rank 3
      {id =1245, requiredIds ={1244}, cost =5000, isTalent =0},
      -- @Power Word: Shield Rank 4
      {id =3747, requiredIds ={600}, cost =5000, isTalent =0},
      -- @Mana Burn Rank 1
      {id =8129, cost =5000, isTalent =0},
      -- @Holy Fire Rank 2
      {id =15262, requiredIds ={14914}, cost =5000, isTalent =0},
       },
[26] = {
      -- @Shadow Word: Pain Rank 4
      {id =992, requiredIds ={970}, cost =6000, isTalent =0},
      -- @Renew Rank 4
      {id =6076, requiredIds ={6075}, cost =6000, isTalent =0},
      -- @Flash Heal Rank 2
      {id =9472, requiredIds ={2061}, cost =6000, isTalent =0},
      -- @Desperate Prayer Rank 3
      {id =19238, requiredIds ={19236}, races ={1, 3}, cost =300, isTalent =0},
      -- @Starshards Rank 3
      {id =19299, requiredIds ={19296}, race =4, cost =300, isTalent =0},
       },
[28] = {
      -- @Heal Rank 3
      {id =6063, requiredIds ={2055}, cost =8000, isTalent =0},
      -- @Mind Blast Rank 4
      {id =8104, requiredIds ={8103}, cost =8000, isTalent =0},
      -- @Psychic Scream Rank 2
      {id =8124, requiredIds ={8122}, cost =8000, isTalent =0},
      -- @Holy Nova Rank 2
      {id =15430, requiredIds ={15237}, cost =400, isTalent =0},
      -- @Mind Flay Rank 2
      {id =17311, requiredIds ={15407}, cost =400, isTalent =0},
      -- @Devouring Plague Rank 2
      {id =19276, requiredIds ={2944}, race =5, cost =400, isTalent =0},
      -- @Shadowguard Rank 2
      {id =19308, requiredIds ={18137}, race =8, cost =400, isTalent =0},
       },
[30] = {
      -- @Prayer of Healing Rank 1
      {id =596, cost =10000, isTalent =0},
      -- @Inner Fire Rank 3
      {id =602, requiredIds ={7128}, cost =10000, isTalent =0},
      -- @Mind Control Rank 1
      {id =605, cost =10000, isTalent =0},
      -- @Shadow Protection Rank 1
      {id =976, cost =10000, isTalent =0},
      -- @Smite Rank 5
      {id =1004, requiredIds ={984}, cost =10000, isTalent =0},
      -- @Power Word: Shield Rank 5
      {id =6065, requiredIds ={3747}, cost =10000, isTalent =0},
      -- @Fade Rank 3
      {id =9579, requiredIds ={9578}, cost =10000, isTalent =0},
      -- @Holy Fire Rank 3
      {id =15263, requiredIds ={15262}, cost =10000, isTalent =0},
      -- @Touch of Weakness Rank 3
      {id =19262, requiredIds ={19261}, race =5, cost =500, isTalent =0},
      -- @Feedback Rank 2
      {id =19271, requiredIds ={13896}, race =1, cost =500, isTalent =0},
      -- @Hex of Weakness Rank 3
      {id =19282, requiredIds ={19281}, race =8, cost =500, isTalent =0},
      -- @Elune's Grace Rank 2
      {id =19289, requiredIds ={2651}, race =4, cost =500, isTalent =0},
       },
[32] = {
      -- @Abolish Disease undefined
      {id =552, cost =11000, isTalent =0},
      -- @Renew Rank 5
      {id =6077, requiredIds ={6076}, cost =11000, isTalent =0},
      -- @Mana Burn Rank 2
      {id =8131, requiredIds ={8129}, cost =11000, isTalent =0},
      -- @Flash Heal Rank 3
      {id =9473, requiredIds ={9472}, cost =11000, isTalent =0},
       },
[34] = {
      -- @Levitate undefined
      {id =1706, cost =12000, isTalent =0},
      -- @Shadow Word: Pain Rank 5
      {id =2767, requiredIds ={992}, cost =12000, isTalent =0},
      -- @Heal Rank 4
      {id =6064, requiredIds ={6063}, cost =12000, isTalent =0},
      -- @Mind Blast Rank 5
      {id =8105, requiredIds ={8104}, cost =12000, isTalent =0},
      -- @Resurrection Rank 3
      {id =10880, requiredIds ={2010}, cost =12000, isTalent =0},
      -- @Desperate Prayer Rank 4
      {id =19240, requiredIds ={19238}, races ={1, 3}, cost =600, isTalent =0},
      -- @Starshards Rank 4
      {id =19302, requiredIds ={19299}, race =4, cost =600, isTalent =0},
       },
[36] = {
      -- @Dispel Magic Rank 2
      {id =988, requiredIds ={527}, cost =14000, isTalent =0},
      -- @Power Word: Fortitude Rank 4
      {id =2791, requiredIds ={1245}, cost =14000, isTalent =0},
      -- @Power Word: Shield Rank 6
      {id =6066, requiredIds ={6065}, cost =14000, isTalent =0},
      -- @Mind Soothe Rank 2
      {id =8192, requiredIds ={453}, cost =14000, isTalent =0},
      -- @Holy Fire Rank 4
      {id =15264, requiredIds ={15263}, cost =14000, isTalent =0},
      -- @Holy Nova Rank 3
      {id =15431, requiredIds ={15430}, cost =700, isTalent =0},
      -- @Mind Flay Rank 3
      {id =17312, requiredIds ={17311}, cost =700, isTalent =0},
      -- @Devouring Plague Rank 3
      {id =19277, requiredIds ={19276}, race =5, cost =700, isTalent =0},
      -- @Shadowguard Rank 3
      {id =19309, requiredIds ={19308}, race =8, cost =700, isTalent =0},
       },
[38] = {
      -- @Smite Rank 6
      {id =6060, requiredIds ={1004}, cost =16000, isTalent =0},
      -- @Renew Rank 6
      {id =6078, requiredIds ={6077}, cost =16000, isTalent =0},
      -- @Flash Heal Rank 4
      {id =9474, requiredIds ={9473}, cost =16000, isTalent =0},
       },
[40] = {
      -- @Prayer of Healing Rank 2
      {id =996, requiredIds ={596}, cost =18000, isTalent =0},
      -- @Inner Fire Rank 4
      {id =1006, requiredIds ={602}, cost =18000, isTalent =0},
      -- @Greater Heal Rank 1
      {id =2060, cost =18000, isTalent =0},
      -- @Mind Blast Rank 6
      {id =8106, requiredIds ={8105}, cost =18000, isTalent =0},
      -- @Shackle Undead Rank 2
      {id =9485, requiredIds ={9484}, cost =18000, isTalent =0},
      -- @Fade Rank 4
      {id =9592, requiredIds ={9579}, cost =18000, isTalent =0},
      -- @Mana Burn Rank 3
      {id =10874, requiredIds ={8131}, cost =18000, isTalent =0},
      -- @Divine Spirit Rank 2
      {id =14818, requiredIds ={14752}, cost =900, isTalent =0},
      -- @Touch of Weakness Rank 4
      {id =19264, requiredIds ={19262}, race =5, cost =900, isTalent =0},
      -- @Feedback Rank 3
      {id =19273, requiredIds ={19271}, race =1, cost =900, isTalent =0},
      -- @Hex of Weakness Rank 4
      {id =19283, requiredIds ={19282}, race =8, cost =900, isTalent =0},
      -- @Elune's Grace Rank 3
      {id =19291, requiredIds ={19289}, race =4, cost =900, isTalent =0},
       },
[42] = {
      -- @Psychic Scream Rank 3
      {id =10888, requiredIds ={8124}, cost =22000, isTalent =0},
      -- @Shadow Word: Pain Rank 6
      {id =10892, requiredIds ={2767}, cost =22000, isTalent =0},
      -- @Power Word: Shield Rank 7
      {id =10898, requiredIds ={6066}, cost =22000, isTalent =0},
      -- @Shadow Protection Rank 2
      {id =10957, requiredIds ={976}, cost =22000, isTalent =0},
      -- @Holy Fire Rank 5
      {id =15265, requiredIds ={15264}, cost =22000, isTalent =0},
      -- @Desperate Prayer Rank 5
      {id =19241, requiredIds ={19240}, races ={1, 3}, cost =1100, isTalent =0},
      -- @Starshards Rank 5
      {id =19303, requiredIds ={19302}, race =4, cost =1100, isTalent =0},
       },
[44] = {
      -- @Mind Vision Rank 2
      {id =10909, requiredIds ={2096}, cost =24000, isTalent =0},
      -- @Mind Control Rank 2
      {id =10911, requiredIds ={605}, cost =24000, isTalent =0},
      -- @Flash Heal Rank 5
      {id =10915, requiredIds ={9474}, cost =24000, isTalent =0},
      -- @Renew Rank 7
      {id =10927, requiredIds ={6078}, cost =24000, isTalent =0},
      -- @Mind Flay Rank 4
      {id =17313, requiredIds ={17312}, cost =1200, isTalent =0},
      -- @Devouring Plague Rank 4
      {id =19278, requiredIds ={19277}, race =5, cost =1200, isTalent =0},
      -- @Shadowguard Rank 4
      {id =19310, requiredIds ={19309}, race =8, cost =1200, isTalent =0},
      -- @Holy Nova Rank 4
      {id =27799, requiredIds ={15431}, cost =1200, isTalent =0},
       },
[46] = {
      -- @Resurrection Rank 4
      {id =10881, requiredIds ={10880}, cost =26000, isTalent =0},
      -- @Smite Rank 7
      {id =10933, requiredIds ={6060}, cost =26000, isTalent =0},
      -- @Mind Blast Rank 7
      {id =10945, requiredIds ={8106}, cost =26000, isTalent =0},
      -- @Greater Heal Rank 2
      {id =10963, requiredIds ={2060}, cost =26000, isTalent =0},
       },
[48] = {
      -- @Mana Burn Rank 4
      {id =10875, requiredIds ={10874}, cost =28000, isTalent =0},
      -- @Power Word: Shield Rank 8
      {id =10899, requiredIds ={10898}, cost =28000, isTalent =0},
      -- @Power Word: Fortitude Rank 5
      {id =10937, requiredIds ={2791}, cost =28000, isTalent =0},
      -- @Holy Fire Rank 6
      {id =15266, requiredIds ={15265}, cost =28000, isTalent =0},
      -- @Prayer of Fortitude Rank 1
      {id =21562, isTalent =0},
       },
[50] = {
      -- @Shadow Word: Pain Rank 7
      {id =10893, requiredIds ={10892}, cost =30000, isTalent =0},
      -- @Flash Heal Rank 6
      {id =10916, requiredIds ={10915}, cost =30000, isTalent =0},
      -- @Renew Rank 8
      {id =10928, requiredIds ={10927}, cost =30000, isTalent =0},
      -- @Fade Rank 5
      {id =10941, requiredIds ={9592}, cost =30000, isTalent =0},
      -- @Inner Fire Rank 5
      {id =10951, requiredIds ={1006}, cost =30000, isTalent =0},
      -- @Prayer of Healing Rank 3
      {id =10960, requiredIds ={996}, cost =30000, isTalent =0},
      -- @Divine Spirit Rank 3
      {id =14819, requiredIds ={14818}, cost =1500, isTalent =0},
      -- @Desperate Prayer Rank 6
      {id =19242, requiredIds ={19241}, races ={1, 3}, cost =1500, isTalent =0},
      -- @Touch of Weakness Rank 5
      {id =19265, requiredIds ={19264}, race =5, cost =1500, isTalent =0},
      -- @Feedback Rank 4
      {id =19274, requiredIds ={19273}, race =1, cost =1500, isTalent =0},
      -- @Hex of Weakness Rank 5
      {id =19284, requiredIds ={19283}, race =8, cost =1500, isTalent =0},
      -- @Elune's Grace Rank 4
      {id =19292, requiredIds ={19291}, race =4, cost =1500, isTalent =0},
      -- @Starshards Rank 6
      {id =19304, requiredIds ={19303}, race =4, cost =1500, isTalent =0},
      -- @Lightwell Rank 2
      {id =27870, requiredIds ={724}, cost =1200, isTalent =0},
       },
[52] = {
      -- @Mind Blast Rank 8
      {id =10946, requiredIds ={10945}, cost =38000, isTalent =0},
      -- @Mind Soothe Rank 3
      {id =10953, requiredIds ={8192}, cost =38000, isTalent =0},
      -- @Greater Heal Rank 3
      {id =10964, requiredIds ={10963}, cost =38000, isTalent =0},
      -- @Mind Flay Rank 5
      {id =17314, requiredIds ={17313}, cost =1900, isTalent =0},
      -- @Devouring Plague Rank 5
      {id =19279, requiredIds ={19278}, race =5, cost =1900, isTalent =0},
      -- @Shadowguard Rank 5
      {id =19311, requiredIds ={19310}, race =8, cost =1900, isTalent =0},
      -- @Holy Nova Rank 5
      {id =27800, requiredIds ={27799}, cost =1900, isTalent =0},
       },
[54] = {
      -- @Power Word: Shield Rank 9
      {id =10900, requiredIds ={10899}, cost =40000, isTalent =0},
      -- @Smite Rank 8
      {id =10934, requiredIds ={10933}, cost =40000, isTalent =0},
      -- @Holy Fire Rank 7
      {id =15267, requiredIds ={15266}, cost =40000, isTalent =0},
       },
[56] = {
      -- @Mana Burn Rank 5
      {id =10876, requiredIds ={10875}, cost =42000, isTalent =0},
      -- @Psychic Scream Rank 4
      {id =10890, requiredIds ={10888}, cost =42000, isTalent =0},
      -- @Flash Heal Rank 7
      {id =10917, requiredIds ={10916}, cost =42000, isTalent =0},
      -- @Renew Rank 9
      {id =10929, requiredIds ={10928}, cost =42000, isTalent =0},
      -- @Shadow Protection Rank 3
      {id =10958, requiredIds ={10957}, cost =42000, isTalent =0},
      -- @Prayer of Shadow Protection Rank 1
      {id =27683, isTalent =0},
       },
[58] = {
      -- @Shadow Word: Pain Rank 8
      {id =10894, requiredIds ={10893}, cost =44000, isTalent =0},
      -- @Mind Control Rank 3
      {id =10912, requiredIds ={10911}, cost =44000, isTalent =0},
      -- @Mind Blast Rank 9
      {id =10947, requiredIds ={10946}, cost =44000, isTalent =0},
      -- @Greater Heal Rank 4
      {id =10965, requiredIds ={10964}, cost =44000, isTalent =0},
      -- @Desperate Prayer Rank 7
      {id =19243, requiredIds ={19242}, races ={1, 3}, cost =2200, isTalent =0},
      -- @Starshards Rank 7
      {id =19305, requiredIds ={19304}, race =4, cost =2200, isTalent =0},
      -- @Resurrection Rank 5
      {id =20770, requiredIds ={10881}, cost =44000, isTalent =0},
       },
[60] = {
      -- @Power Word: Shield Rank 10
      {id =10901, requiredIds ={10900}, cost =46000, isTalent =0},
      -- @Power Word: Fortitude Rank 6
      {id =10938, requiredIds ={10937}, cost =46000, isTalent =0},
      -- @Fade Rank 6
      {id =10942, requiredIds ={10941}, cost =46000, isTalent =0},
      -- @Inner Fire Rank 6
      {id =10952, requiredIds ={10951}, cost =46000, isTalent =0},
      -- @Shackle Undead Rank 3
      {id =10955, requiredIds ={9485}, cost =46000, isTalent =0},
      -- @Prayer of Healing Rank 4
      {id =10961, requiredIds ={10960}, cost =46000, isTalent =0},
      -- @Holy Fire Rank 8
      {id =15261, requiredIds ={15267}, cost =46000, isTalent =0},
      -- @Mind Flay Rank 6
      {id =18807, requiredIds ={17314}, cost =2300, isTalent =0},
      -- @Touch of Weakness Rank 6
      {id =19266, requiredIds ={19265}, race =5, cost =2300, isTalent =0},
      -- @Feedback Rank 5
      {id =19275, requiredIds ={19274}, race =1, cost =2300, isTalent =0},
      -- @Devouring Plague Rank 6
      {id =19280, requiredIds ={19279}, race =5, cost =2300, isTalent =0},
      -- @Hex of Weakness Rank 6
      {id =19285, requiredIds ={19284}, race =8, cost =2300, isTalent =0},
      -- @Elune's Grace Rank 5
      {id =19293, requiredIds ={19292}, race =4, cost =2300, isTalent =0},
      -- @Shadowguard Rank 6
      {id =19312, requiredIds ={19311}, race =8, cost =2300, isTalent =0},
      -- @Prayer of Fortitude Rank 2
      {id =21564, requiredIds ={21562}, isTalent =0},
      -- @Greater Heal Rank 5
      {id =25314, requiredIds ={10965}, isTalent =0},
      -- @Renew Rank 10
      {id =25315, requiredIds ={10929}, isTalent =0},
      -- @Prayer of Healing Rank 5
      {id =25316, requiredIds ={10961}, isTalent =0},
      -- @Prayer of Spirit Rank 1
      {id =27681, cost =2300, isTalent =0},
      -- @Holy Nova Rank 6
      {id =27801, requiredIds ={27800}, cost =2300, isTalent =0},
      -- @Divine Spirit Rank 4
      {id =27841, requiredIds ={14819}, cost =2300, isTalent =0},
      -- @Lightwell Rank 3
      {id =27871, requiredIds ={27870}, cost =1500, isTalent =0}
        }
}

)
