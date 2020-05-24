local _, GW = ...
if (GW.myclass ~= "PRIEST") then return end
GW.SpellsByLevel = GW.RaceFilter(
{
[0] = {
      -- @One-Handed Maces undefined
      {id =198, isTalent =0, isSkill =1},
      -- @Staves undefined
      {id =227, isTalent =0, isSkill =1},
      -- @Lightwell Rank 1
      {id =724, rank =1, isTalent =1},
      -- @Daggers undefined
      {id =1180, isTalent =0, isSkill =1},
      -- @Wands undefined
      {id =5009, isTalent =0, isSkill =1},
      -- @Power Infusion undefined
      {id =10060, isTalent =1},
      -- @Mental Agility Rank 1
      {id =14520, rank =1, isTalent =1},
      -- @Meditation Rank 1
      {id =14521, rank =1, isTalent =1},
      -- @Unbreakable Will Rank 1
      {id =14522, rank =1, isTalent =1},
      -- @Silent Resolve Rank 1
      {id =14523, rank =1, isTalent =1},
      -- @Wand Specialization Rank 1
      {id =14524, rank =1, isTalent =1},
      -- @Wand Specialization Rank 2
      {id =14525, requiredIds ={14524}, rank =2, baseId =14524, isTalent =1},
      -- @Wand Specialization Rank 3
      {id =14526, requiredIds ={14525}, rank =3, baseId =14524, isTalent =1},
      -- @Wand Specialization Rank 4
      {id =14527, requiredIds ={14526}, rank =4, baseId =14524, isTalent =1},
      -- @Wand Specialization Rank 5
      {id =14528, requiredIds ={14527}, rank =5, baseId =14524, isTalent =1},
      -- @Martyrdom Rank 1
      {id =14531, rank =1, isTalent =1},
      -- @Improved Inner Fire Rank 1
      {id =14747, rank =1, isTalent =1},
      -- @Improved Power Word: Shield Rank 1
      {id =14748, rank =1, isTalent =1},
      -- @Improved Power Word: Fortitude Rank 1
      {id =14749, rank =1, isTalent =1},
      -- @Improved Mana Burn Rank 1
      {id =14750, rank =1, isTalent =1},
      -- @Inner Focus undefined
      {id =14751, isTalent =1},
      -- @Divine Spirit Rank 1
      {id =14752, rank =1, isTalent =1},
      -- @Improved Power Word: Fortitude Rank 2
      {id =14767, requiredIds ={14749}, rank =2, baseId =14749, isTalent =1},
      -- @Improved Power Word: Shield Rank 2
      {id =14768, requiredIds ={14748}, rank =2, baseId =14748, isTalent =1},
      -- @Improved Power Word: Shield Rank 3
      {id =14769, requiredIds ={14768}, rank =3, baseId =14748, isTalent =1},
      -- @Improved Inner Fire Rank 2
      {id =14770, requiredIds ={14747}, rank =2, baseId =14747, isTalent =1},
      -- @Improved Inner Fire Rank 3
      {id =14771, requiredIds ={14770}, rank =3, baseId =14747, isTalent =1},
      -- @Improved Mana Burn Rank 2
      {id =14772, requiredIds ={14750}, rank =2, baseId =14750, isTalent =1},
      -- @Martyrdom Rank 2
      {id =14774, requiredIds ={14531}, rank =2, baseId =14531, isTalent =1},
      -- @Meditation Rank 2
      {id =14776, requiredIds ={14521}, rank =2, baseId =14521, isTalent =1},
      -- @Meditation Rank 3
      {id =14777, requiredIds ={14776}, rank =3, baseId =14521, isTalent =1},
      -- @Mental Agility Rank 2
      {id =14780, requiredIds ={14520}, rank =2, baseId =14520, isTalent =1},
      -- @Mental Agility Rank 3
      {id =14781, requiredIds ={14780}, rank =3, baseId =14520, isTalent =1},
      -- @Mental Agility Rank 4
      {id =14782, requiredIds ={14781}, rank =4, baseId =14520, isTalent =1},
      -- @Mental Agility Rank 5
      {id =14783, requiredIds ={14782}, rank =5, baseId =14520, isTalent =1},
      -- @Silent Resolve Rank 2
      {id =14784, requiredIds ={14523}, rank =2, baseId =14523, isTalent =1},
      -- @Silent Resolve Rank 3
      {id =14785, requiredIds ={14784}, rank =3, baseId =14523, isTalent =1},
      -- @Silent Resolve Rank 4
      {id =14786, requiredIds ={14785}, rank =4, baseId =14523, isTalent =1},
      -- @Silent Resolve Rank 5
      {id =14787, requiredIds ={14786}, rank =5, baseId =14523, isTalent =1},
      -- @Unbreakable Will Rank 2
      {id =14788, requiredIds ={14522}, rank =2, baseId =14522, isTalent =1},
      -- @Unbreakable Will Rank 3
      {id =14789, requiredIds ={14788}, rank =3, baseId =14522, isTalent =1},
      -- @Unbreakable Will Rank 4
      {id =14790, requiredIds ={14789}, rank =4, baseId =14522, isTalent =1},
      -- @Unbreakable Will Rank 5
      {id =14791, requiredIds ={14790}, rank =5, baseId =14522, isTalent =1},
      -- @Holy Specialization Rank 1
      {id =14889, rank =1, isTalent =1},
      -- @Inspiration Rank 1
      {id =14892, rank =1, isTalent =1},
      -- @Spiritual Healing Rank 1
      {id =14898, rank =1, isTalent =1},
      -- @Spiritual Guidance Rank 1
      {id =14901, rank =1, isTalent =1},
      -- @Improved Renew Rank 1
      {id =14908, rank =1, isTalent =1},
      -- @Searing Light Rank 1
      {id =14909, rank =1, isTalent =1},
      -- @Improved Prayer of Healing Rank 1
      {id =14911, rank =1, isTalent =1},
      -- @Improved Healing Rank 1
      {id =14912, rank =1, isTalent =1},
      -- @Healing Focus Rank 1
      {id =14913, rank =1, isTalent =1},
      -- @Holy Specialization Rank 2
      {id =15008, requiredIds ={14889}, rank =2, baseId =14889, isTalent =1},
      -- @Holy Specialization Rank 3
      {id =15009, requiredIds ={15008}, rank =3, baseId =14889, isTalent =1},
      -- @Holy Specialization Rank 4
      {id =15010, requiredIds ={15009}, rank =4, baseId =14889, isTalent =1},
      -- @Holy Specialization Rank 5
      {id =15011, requiredIds ={15010}, rank =5, baseId =14889, isTalent =1},
      -- @Healing Focus Rank 2
      {id =15012, requiredIds ={14913}, rank =2, baseId =14913, isTalent =1},
      -- @Improved Healing Rank 2
      {id =15013, requiredIds ={14912}, rank =2, baseId =14912, isTalent =1},
      -- @Improved Healing Rank 3
      {id =15014, requiredIds ={15013}, rank =3, baseId =14912, isTalent =1},
      -- @Searing Light Rank 2
      {id =15017, requiredIds ={14909}, rank =2, baseId =14909, isTalent =1},
      -- @Improved Prayer of Healing Rank 2
      {id =15018, requiredIds ={14911}, rank =2, baseId =14911, isTalent =1},
      -- @Improved Prayer of Healing Rank 3
      {id =15019, requiredIds ={15018}, rank =3, baseId =14911, isTalent =1},
      -- @Improved Renew Rank 2
      {id =15020, requiredIds ={14908}, rank =2, baseId =14908, isTalent =1},
      -- @Spiritual Guidance Rank 2
      {id =15028, requiredIds ={14901}, rank =2, baseId =14901, isTalent =1},
      -- @Spiritual Guidance Rank 3
      {id =15029, requiredIds ={15028}, rank =3, baseId =14901, isTalent =1},
      -- @Spiritual Guidance Rank 4
      {id =15030, requiredIds ={15029}, rank =4, baseId =14901, isTalent =1},
      -- @Spiritual Guidance Rank 5
      {id =15031, requiredIds ={15030}, rank =5, baseId =14901, isTalent =1},
      -- @Holy Nova Rank 1
      {id =15237, rank =1, isTalent =1},
      -- @Shadow Weaving Rank 1
      {id =15257, rank =1, isTalent =1},
      -- @Darkness Rank 1
      {id =15259, rank =1, isTalent =1},
      -- @Shadow Focus Rank 1
      {id =15260, rank =1, isTalent =1},
      -- @Blackout Rank 1
      {id =15268, rank =1, isTalent =1},
      -- @Spirit Tap Rank 1
      {id =15270, rank =1, isTalent =1},
      -- @Shadow Affinity Rank 2
      {id =15272, requiredIds ={15318}, rank =2, baseId =15318, isTalent =1},
      -- @Improved Mind Blast Rank 1
      {id =15273, rank =1, isTalent =1},
      -- @Improved Fade Rank 1
      {id =15274, rank =1, isTalent =1},
      -- @Improved Shadow Word: Pain Rank 1
      {id =15275, rank =1, isTalent =1},
      -- @Vampiric Embrace undefined
      {id =15286, isTalent =1},
      -- @Darkness Rank 2
      {id =15307, requiredIds ={15259}, rank =2, baseId =15259, isTalent =1},
      -- @Darkness Rank 3
      {id =15308, requiredIds ={15307}, rank =3, baseId =15259, isTalent =1},
      -- @Darkness Rank 4
      {id =15309, requiredIds ={15308}, rank =4, baseId =15259, isTalent =1},
      -- @Darkness Rank 5
      {id =15310, requiredIds ={15309}, rank =5, baseId =15259, isTalent =1},
      -- @Improved Fade Rank 2
      {id =15311, requiredIds ={15274}, rank =2, baseId =15274, isTalent =1},
      -- @Improved Mind Blast Rank 2
      {id =15312, requiredIds ={15273}, rank =2, baseId =15273, isTalent =1},
      -- @Improved Mind Blast Rank 3
      {id =15313, requiredIds ={15312}, rank =3, baseId =15273, isTalent =1},
      -- @Improved Mind Blast Rank 4
      {id =15314, requiredIds ={15313}, rank =4, baseId =15273, isTalent =1},
      -- @Improved Mind Blast Rank 5
      {id =15316, requiredIds ={15314}, rank =5, baseId =15273, isTalent =1},
      -- @Improved Shadow Word: Pain Rank 2
      {id =15317, requiredIds ={15275}, rank =2, baseId =15275, isTalent =1},
      -- @Shadow Affinity Rank 1
      {id =15318, rank =1, isTalent =1},
      -- @Shadow Affinity Rank 3
      {id =15320, requiredIds ={15272}, rank =3, baseId =15318, isTalent =1},
      -- @Blackout Rank 2
      {id =15323, requiredIds ={15268}, rank =2, baseId =15268, isTalent =1},
      -- @Blackout Rank 3
      {id =15324, requiredIds ={15323}, rank =3, baseId =15268, isTalent =1},
      -- @Blackout Rank 4
      {id =15325, requiredIds ={15324}, rank =4, baseId =15268, isTalent =1},
      -- @Blackout Rank 5
      {id =15326, requiredIds ={15325}, rank =5, baseId =15268, isTalent =1},
      -- @Shadow Focus Rank 2
      {id =15327, requiredIds ={15260}, rank =2, baseId =15260, isTalent =1},
      -- @Shadow Focus Rank 3
      {id =15328, requiredIds ={15327}, rank =3, baseId =15260, isTalent =1},
      -- @Shadow Weaving Rank 2
      {id =15331, requiredIds ={15257}, rank =2, baseId =15257, isTalent =1},
      -- @Shadow Weaving Rank 3
      {id =15332, requiredIds ={15331}, rank =3, baseId =15257, isTalent =1},
      -- @Shadow Weaving Rank 4
      {id =15333, requiredIds ={15332}, rank =4, baseId =15257, isTalent =1},
      -- @Shadow Weaving Rank 5
      {id =15334, requiredIds ={15333}, rank =5, baseId =15257, isTalent =1},
      -- @Spirit Tap Rank 2
      {id =15335, requiredIds ={15270}, rank =2, baseId =15270, isTalent =1},
      -- @Spirit Tap Rank 3
      {id =15336, requiredIds ={15335}, rank =3, baseId =15270, isTalent =1},
      -- @Spirit Tap Rank 4
      {id =15337, requiredIds ={15336}, rank =4, baseId =15270, isTalent =1},
      -- @Spirit Tap Rank 5
      {id =15338, requiredIds ={15337}, rank =5, baseId =15270, isTalent =1},
      -- @Spiritual Healing Rank 2
      {id =15349, requiredIds ={14898}, rank =2, baseId =14898, isTalent =1},
      -- @Spiritual Healing Rank 3
      {id =15354, requiredIds ={15349}, rank =3, baseId =14898, isTalent =1},
      -- @Spiritual Healing Rank 4
      {id =15355, requiredIds ={15354}, rank =4, baseId =14898, isTalent =1},
      -- @Spiritual Healing Rank 5
      {id =15356, requiredIds ={15355}, rank =5, baseId =14898, isTalent =1},
      -- @Inspiration Rank 2
      {id =15362, requiredIds ={14892}, rank =2, baseId =14892, isTalent =1},
      -- @Inspiration Rank 3
      {id =15363, requiredIds ={15362}, rank =3, baseId =14892, isTalent =1},
      -- @Improved Psychic Scream Rank 1
      {id =15392, rank =1, isTalent =1},
      -- @Mind Flay Rank 1
      {id =15407, rank =1, isTalent =1},
      -- @Improved Psychic Scream Rank 2
      {id =15448, requiredIds ={15392}, rank =2, baseId =15392, isTalent =1},
      -- @Shadowform undefined
      {id =15473, isTalent =1},
      -- @Silence undefined
      {id =15487, isTalent =1},
      -- @Improved Renew Rank 3
      {id =17191, requiredIds ={15020}, rank =3, baseId =14908, isTalent =1},
      -- @Shadow Reach Rank 1
      {id =17322, rank =1, isTalent =1},
      -- @Shadow Reach Rank 2
      {id =17323, requiredIds ={17322}, rank =2, baseId =17322, isTalent =1},
      -- @Shadow Reach Rank 3
      {id =17325, requiredIds ={17323}, rank =3, baseId =17322, isTalent =1},
      -- @Divine Fury Rank 1
      {id =18530, rank =1, isTalent =1},
      -- @Divine Fury Rank 2
      {id =18531, requiredIds ={18530}, rank =2, baseId =18530, isTalent =1},
      -- @Divine Fury Rank 3
      {id =18533, requiredIds ={18531}, rank =3, baseId =18530, isTalent =1},
      -- @Divine Fury Rank 4
      {id =18534, requiredIds ={18533}, rank =4, baseId =18530, isTalent =1},
      -- @Divine Fury Rank 5
      {id =18535, requiredIds ={18534}, rank =5, baseId =18530, isTalent =1},
      -- @Force of Will Rank 1
      {id =18544, rank =1, isTalent =1},
      -- @Force of Will Rank 2
      {id =18547, requiredIds ={18544}, rank =2, baseId =18544, isTalent =1},
      -- @Force of Will Rank 3
      {id =18548, requiredIds ={18547}, rank =3, baseId =18544, isTalent =1},
      -- @Force of Will Rank 4
      {id =18549, requiredIds ={18548}, rank =4, baseId =18544, isTalent =1},
      -- @Force of Will Rank 5
      {id =18550, requiredIds ={18549}, rank =5, baseId =18544, isTalent =1},
      -- @Mental Strength Rank 1
      {id =18551, rank =1, isTalent =1},
      -- @Mental Strength Rank 2
      {id =18552, requiredIds ={18551}, rank =2, baseId =18551, isTalent =1},
      -- @Mental Strength Rank 3
      {id =18553, requiredIds ={18552}, rank =3, baseId =18551, isTalent =1},
      -- @Mental Strength Rank 4
      {id =18554, requiredIds ={18553}, rank =4, baseId =18551, isTalent =1},
      -- @Mental Strength Rank 5
      {id =18555, requiredIds ={18554}, rank =5, baseId =18551, isTalent =1},
      -- @Spirit of Redemption undefined
      {id =20711, isTalent =1},
      -- @Holy Reach Rank 1
      {id =27789, rank =1, isTalent =1},
      -- @Holy Reach Rank 2
      {id =27790, requiredIds ={27789}, rank =2, baseId =27789, isTalent =1},
      -- @Blessed Recovery Rank 1
      {id =27811, rank =1, isTalent =1},
      -- @Blessed Recovery Rank 2
      {id =27815, requiredIds ={27811}, rank =2, baseId =27811, isTalent =1},
      -- @Blessed Recovery Rank 3
      {id =27816, requiredIds ={27815}, rank =3, baseId =27811, isTalent =1},
      -- @Improved Vampiric Embrace Rank 1
      {id =27839, rank =1, isTalent =1},
      -- @Improved Vampiric Embrace Rank 2
      {id =27840, requiredIds ={27839}, rank =2, baseId =27839, isTalent =1},
      -- @Spell Warding Rank 1
      {id =27900, rank =1, isTalent =1},
      -- @Spell Warding Rank 2
      {id =27901, requiredIds ={27900}, rank =2, baseId =27900, isTalent =1},
      -- @Spell Warding Rank 3
      {id =27902, requiredIds ={27901}, rank =3, baseId =27900, isTalent =1},
      -- @Spell Warding Rank 4
      {id =27903, requiredIds ={27902}, rank =4, baseId =27900, isTalent =1},
      -- @Spell Warding Rank 5
      {id =27904, requiredIds ={27903}, rank =5, baseId =27900, isTalent =1},
       },
[1] = {
      -- @Smite Rank 1
      {id =585, rank =1, isTalent =0},
      -- @Power Word: Fortitude Rank 1
      {id =1243, rank =1, cost =10, isTalent =0},
      -- @Lesser Heal Rank 1
      {id =2050, rank =1, isTalent =0},
      -- @Shoot undefined
      {id =5019, isTalent =0},
       },
[4] = {
      -- @Shadow Word: Pain Rank 1
      {id =589, rank =1, cost =100, isTalent =0},
      -- @Lesser Heal Rank 2
      {id =2052, requiredIds ={2050}, rank =2, baseId =2050, cost =100, isTalent =0},
       },
[6] = {
      -- @Power Word: Shield Rank 1
      {id =17, rank =1, cost =100, isTalent =0},
      -- @Smite Rank 2
      {id =591, requiredIds ={585}, rank =2, baseId =585, cost =100, isTalent =0},
       },
[8] = {
      -- @Renew Rank 1
      {id =139, rank =1, cost =200, isTalent =0},
      -- @Fade Rank 1
      {id =586, rank =1, cost =200, isTalent =0},
       },
[10] = {
      -- @Shadow Word: Pain Rank 2
      {id =594, requiredIds ={589}, rank =2, baseId =589, cost =300, isTalent =0},
      -- @Resurrection Rank 1
      {id =2006, rank =1, cost =300, isTalent =0},
      -- @Lesser Heal Rank 3
      {id =2053, requiredIds ={2052}, rank =3, baseId =2050, cost =300, isTalent =0},
      -- @Touch of Weakness Rank 1
      {id =2652, rank =1, race =5, isTalent =0},
      -- @Mind Blast Rank 1
      {id =8092, rank =1, cost =300, isTalent =0},
      -- @Hex of Weakness Rank 1
      {id =9035, rank =1, race =8, isTalent =0},
      -- @Starshards Rank 1
      {id =10797, rank =1, race =4, isTalent =0},
      -- @Desperate Prayer Rank 1
      {id =13908, rank =1, races ={1, 3}, isTalent =0},
       },
[12] = {
      -- @Inner Fire Rank 1
      {id =588, rank =1, cost =800, isTalent =0},
      -- @Power Word: Shield Rank 2
      {id =592, requiredIds ={17}, rank =2, baseId =17, cost =800, isTalent =0},
      -- @Power Word: Fortitude Rank 2
      {id =1244, requiredIds ={1243}, rank =2, baseId =1243, cost =800, isTalent =0},
       },
[14] = {
      -- @Cure Disease undefined
      {id =528, cost =1200, isTalent =0},
      -- @Smite Rank 3
      {id =598, requiredIds ={591}, rank =3, baseId =585, cost =1200, isTalent =0},
      -- @Renew Rank 2
      {id =6074, requiredIds ={139}, rank =2, baseId =139, cost =1200, isTalent =0},
      -- @Psychic Scream Rank 1
      {id =8122, rank =1, cost =1200, isTalent =0},
       },
[16] = {
      -- @Heal Rank 1
      {id =2054, rank =1, cost =1600, isTalent =0},
      -- @Mind Blast Rank 2
      {id =8102, requiredIds ={8092}, rank =2, baseId =8092, cost =1600, isTalent =0},
       },
[18] = {
      -- @Dispel Magic Rank 1
      {id =527, rank =1, cost =2000, isTalent =0},
      -- @Power Word: Shield Rank 3
      {id =600, requiredIds ={592}, rank =3, baseId =17, cost =2000, isTalent =0},
      -- @Shadow Word: Pain Rank 3
      {id =970, requiredIds ={594}, rank =3, baseId =589, cost =2000, isTalent =0},
      -- @Desperate Prayer Rank 2
      {id =19236, requiredIds ={13908}, rank =2, baseId =13908, races ={1, 3}, cost =100, isTalent =0},
      -- @Starshards Rank 2
      {id =19296, requiredIds ={10797}, rank =2, baseId =10797, race =4, cost =100, isTalent =0},
       },
[20] = {
      -- @Mind Soothe Rank 1
      {id =453, rank =1, cost =3000, isTalent =0},
      -- @Flash Heal Rank 1
      {id =2061, rank =1, cost =3000, isTalent =0},
      -- @Elune's Grace Rank 1
      {id =2651, rank =1, race =4, isTalent =0},
      -- @Devouring Plague Rank 1
      {id =2944, rank =1, race =5, isTalent =0},
      -- @Renew Rank 3
      {id =6075, requiredIds ={6074}, rank =3, baseId =139, cost =3000, isTalent =0},
      -- @Fear Ward undefined
      {id =6346, race =3, isTalent =0},
      -- @Inner Fire Rank 2
      {id =7128, requiredIds ={588}, rank =2, baseId =588, cost =3000, isTalent =0},
      -- @Shackle Undead Rank 1
      {id =9484, rank =1, cost =3000, isTalent =0},
      -- @Fade Rank 2
      {id =9578, requiredIds ={586}, rank =2, baseId =586, cost =3000, isTalent =0},
      -- @Feedback Rank 1
      {id =13896, rank =1, race =1, isTalent =0},
      -- @Holy Fire Rank 1
      {id =14914, rank =1, cost =3000, isTalent =0},
      -- @Shadowguard Rank 1
      {id =18137, rank =1, race =8, isTalent =0},
      -- @Touch of Weakness Rank 2
      {id =19261, requiredIds ={2652}, rank =2, baseId =2652, race =5, cost =150, isTalent =0},
      -- @Hex of Weakness Rank 2
      {id =19281, requiredIds ={9035}, rank =2, baseId =9035, race =8, cost =150, isTalent =0},
       },
[22] = {
      -- @Smite Rank 4
      {id =984, requiredIds ={598}, rank =4, baseId =585, cost =4000, isTalent =0},
      -- @Resurrection Rank 2
      {id =2010, requiredIds ={2006}, rank =2, baseId =2006, cost =4000, isTalent =0},
      -- @Heal Rank 2
      {id =2055, requiredIds ={2054}, rank =2, baseId =2054, cost =4000, isTalent =0},
      -- @Mind Vision Rank 1
      {id =2096, rank =1, cost =4000, isTalent =0},
      -- @Mind Blast Rank 3
      {id =8103, requiredIds ={8102}, rank =3, baseId =8092, cost =4000, isTalent =0},
       },
[24] = {
      -- @Power Word: Fortitude Rank 3
      {id =1245, requiredIds ={1244}, rank =3, baseId =1243, cost =5000, isTalent =0},
      -- @Power Word: Shield Rank 4
      {id =3747, requiredIds ={600}, rank =4, baseId =17, cost =5000, isTalent =0},
      -- @Mana Burn Rank 1
      {id =8129, rank =1, cost =5000, isTalent =0},
      -- @Holy Fire Rank 2
      {id =15262, requiredIds ={14914}, rank =2, baseId =14914, cost =5000, isTalent =0},
       },
[26] = {
      -- @Shadow Word: Pain Rank 4
      {id =992, requiredIds ={970}, rank =4, baseId =589, cost =6000, isTalent =0},
      -- @Renew Rank 4
      {id =6076, requiredIds ={6075}, rank =4, baseId =139, cost =6000, isTalent =0},
      -- @Flash Heal Rank 2
      {id =9472, requiredIds ={2061}, rank =2, baseId =2061, cost =6000, isTalent =0},
      -- @Desperate Prayer Rank 3
      {id =19238, requiredIds ={19236}, rank =3, baseId =13908, races ={1, 3}, cost =300, isTalent =0},
      -- @Starshards Rank 3
      {id =19299, requiredIds ={19296}, rank =3, baseId =10797, race =4, cost =300, isTalent =0},
       },
[28] = {
      -- @Heal Rank 3
      {id =6063, requiredIds ={2055}, rank =3, baseId =2054, cost =8000, isTalent =0},
      -- @Mind Blast Rank 4
      {id =8104, requiredIds ={8103}, rank =4, baseId =8092, cost =8000, isTalent =0},
      -- @Psychic Scream Rank 2
      {id =8124, requiredIds ={8122}, rank =2, baseId =8122, cost =8000, isTalent =0},
      -- @Holy Nova Rank 2
      {id =15430, requiredIds ={15237}, rank =2, baseId =15237, cost =400, isTalent =1},
      -- @Mind Flay Rank 2
      {id =17311, requiredIds ={15407}, rank =2, baseId =15407, cost =400, isTalent =1},
      -- @Devouring Plague Rank 2
      {id =19276, requiredIds ={2944}, rank =2, baseId =2944, race =5, cost =400, isTalent =0},
      -- @Shadowguard Rank 2
      {id =19308, requiredIds ={18137}, rank =2, baseId =18137, race =8, cost =400, isTalent =0},
       },
[30] = {
      -- @Prayer of Healing Rank 1
      {id =596, rank =1, cost =10000, isTalent =0},
      -- @Inner Fire Rank 3
      {id =602, requiredIds ={7128}, rank =3, baseId =588, cost =10000, isTalent =0},
      -- @Mind Control Rank 1
      {id =605, rank =1, cost =10000, isTalent =0},
      -- @Shadow Protection Rank 1
      {id =976, rank =1, cost =10000, isTalent =0},
      -- @Smite Rank 5
      {id =1004, requiredIds ={984}, rank =5, baseId =585, cost =10000, isTalent =0},
      -- @Power Word: Shield Rank 5
      {id =6065, requiredIds ={3747}, rank =5, baseId =17, cost =10000, isTalent =0},
      -- @Fade Rank 3
      {id =9579, requiredIds ={9578}, rank =3, baseId =586, cost =10000, isTalent =0},
      -- @Holy Fire Rank 3
      {id =15263, requiredIds ={15262}, rank =3, baseId =14914, cost =10000, isTalent =0},
      -- @Touch of Weakness Rank 3
      {id =19262, requiredIds ={19261}, rank =3, baseId =2652, race =5, cost =500, isTalent =0},
      -- @Feedback Rank 2
      {id =19271, requiredIds ={13896}, rank =2, baseId =13896, race =1, cost =500, isTalent =0},
      -- @Hex of Weakness Rank 3
      {id =19282, requiredIds ={19281}, rank =3, baseId =9035, race =8, cost =500, isTalent =0},
      -- @Elune's Grace Rank 2
      {id =19289, requiredIds ={2651}, rank =2, baseId =2651, race =4, cost =500, isTalent =0},
       },
[32] = {
      -- @Abolish Disease undefined
      {id =552, cost =11000, isTalent =0},
      -- @Renew Rank 5
      {id =6077, requiredIds ={6076}, rank =5, baseId =139, cost =11000, isTalent =0},
      -- @Mana Burn Rank 2
      {id =8131, requiredIds ={8129}, rank =2, baseId =8129, cost =11000, isTalent =0},
      -- @Flash Heal Rank 3
      {id =9473, requiredIds ={9472}, rank =3, baseId =2061, cost =11000, isTalent =0},
       },
[34] = {
      -- @Levitate undefined
      {id =1706, cost =12000, isTalent =0},
      -- @Shadow Word: Pain Rank 5
      {id =2767, requiredIds ={992}, rank =5, baseId =589, cost =12000, isTalent =0},
      -- @Heal Rank 4
      {id =6064, requiredIds ={6063}, rank =4, baseId =2054, cost =12000, isTalent =0},
      -- @Mind Blast Rank 5
      {id =8105, requiredIds ={8104}, rank =5, baseId =8092, cost =12000, isTalent =0},
      -- @Resurrection Rank 3
      {id =10880, requiredIds ={2010}, rank =3, baseId =2006, cost =12000, isTalent =0},
      -- @Desperate Prayer Rank 4
      {id =19240, requiredIds ={19238}, rank =4, baseId =13908, races ={1, 3}, cost =600, isTalent =0},
      -- @Starshards Rank 4
      {id =19302, requiredIds ={19299}, rank =4, baseId =10797, race =4, cost =600, isTalent =0},
       },
[36] = {
      -- @Dispel Magic Rank 2
      {id =988, requiredIds ={527}, rank =2, baseId =527, cost =14000, isTalent =0},
      -- @Power Word: Fortitude Rank 4
      {id =2791, requiredIds ={1245}, rank =4, baseId =1243, cost =14000, isTalent =0},
      -- @Power Word: Shield Rank 6
      {id =6066, requiredIds ={6065}, rank =6, baseId =17, cost =14000, isTalent =0},
      -- @Mind Soothe Rank 2
      {id =8192, requiredIds ={453}, rank =2, baseId =453, cost =14000, isTalent =0},
      -- @Holy Fire Rank 4
      {id =15264, requiredIds ={15263}, rank =4, baseId =14914, cost =14000, isTalent =0},
      -- @Holy Nova Rank 3
      {id =15431, requiredIds ={15430}, rank =3, baseId =15237, cost =700, isTalent =1},
      -- @Mind Flay Rank 3
      {id =17312, requiredIds ={17311}, rank =3, baseId =15407, cost =700, isTalent =1},
      -- @Devouring Plague Rank 3
      {id =19277, requiredIds ={19276}, rank =3, baseId =2944, race =5, cost =700, isTalent =0},
      -- @Shadowguard Rank 3
      {id =19309, requiredIds ={19308}, rank =3, baseId =18137, race =8, cost =700, isTalent =0},
       },
[38] = {
      -- @Smite Rank 6
      {id =6060, requiredIds ={1004}, rank =6, baseId =585, cost =16000, isTalent =0},
      -- @Renew Rank 6
      {id =6078, requiredIds ={6077}, rank =6, baseId =139, cost =16000, isTalent =0},
      -- @Flash Heal Rank 4
      {id =9474, requiredIds ={9473}, rank =4, baseId =2061, cost =16000, isTalent =0},
       },
[40] = {
      -- @Prayer of Healing Rank 2
      {id =996, requiredIds ={596}, rank =2, baseId =596, cost =18000, isTalent =0},
      -- @Inner Fire Rank 4
      {id =1006, requiredIds ={602}, rank =4, baseId =588, cost =18000, isTalent =0},
      -- @Greater Heal Rank 1
      {id =2060, rank =1, cost =18000, isTalent =0},
      -- @Mind Blast Rank 6
      {id =8106, requiredIds ={8105}, rank =6, baseId =8092, cost =18000, isTalent =0},
      -- @Shackle Undead Rank 2
      {id =9485, requiredIds ={9484}, rank =2, baseId =9484, cost =18000, isTalent =0},
      -- @Fade Rank 4
      {id =9592, requiredIds ={9579}, rank =4, baseId =586, cost =18000, isTalent =0},
      -- @Mana Burn Rank 3
      {id =10874, requiredIds ={8131}, rank =3, baseId =8129, cost =18000, isTalent =0},
      -- @Divine Spirit Rank 2
      {id =14818, requiredIds ={14752}, rank =2, baseId =14752, cost =900, isTalent =1},
      -- @Touch of Weakness Rank 4
      {id =19264, requiredIds ={19262}, rank =4, baseId =2652, race =5, cost =900, isTalent =0},
      -- @Feedback Rank 3
      {id =19273, requiredIds ={19271}, rank =3, baseId =13896, race =1, cost =900, isTalent =0},
      -- @Hex of Weakness Rank 4
      {id =19283, requiredIds ={19282}, rank =4, baseId =9035, race =8, cost =900, isTalent =0},
      -- @Elune's Grace Rank 3
      {id =19291, requiredIds ={19289}, rank =3, baseId =2651, race =4, cost =900, isTalent =0},
       },
[42] = {
      -- @Psychic Scream Rank 3
      {id =10888, requiredIds ={8124}, rank =3, baseId =8122, cost =22000, isTalent =0},
      -- @Shadow Word: Pain Rank 6
      {id =10892, requiredIds ={2767}, rank =6, baseId =589, cost =22000, isTalent =0},
      -- @Power Word: Shield Rank 7
      {id =10898, requiredIds ={6066}, rank =7, baseId =17, cost =22000, isTalent =0},
      -- @Shadow Protection Rank 2
      {id =10957, requiredIds ={976}, rank =2, baseId =976, cost =22000, isTalent =0},
      -- @Holy Fire Rank 5
      {id =15265, requiredIds ={15264}, rank =5, baseId =14914, cost =22000, isTalent =0},
      -- @Desperate Prayer Rank 5
      {id =19241, requiredIds ={19240}, rank =5, baseId =13908, races ={1, 3}, cost =1100, isTalent =0},
      -- @Starshards Rank 5
      {id =19303, requiredIds ={19302}, rank =5, baseId =10797, race =4, cost =1100, isTalent =0},
       },
[44] = {
      -- @Mind Vision Rank 2
      {id =10909, requiredIds ={2096}, rank =2, baseId =2096, cost =24000, isTalent =0},
      -- @Mind Control Rank 2
      {id =10911, requiredIds ={605}, rank =2, baseId =605, cost =24000, isTalent =0},
      -- @Flash Heal Rank 5
      {id =10915, requiredIds ={9474}, rank =5, baseId =2061, cost =24000, isTalent =0},
      -- @Renew Rank 7
      {id =10927, requiredIds ={6078}, rank =7, baseId =139, cost =24000, isTalent =0},
      -- @Mind Flay Rank 4
      {id =17313, requiredIds ={17312}, rank =4, baseId =15407, cost =1200, isTalent =1},
      -- @Devouring Plague Rank 4
      {id =19278, requiredIds ={19277}, rank =4, baseId =2944, race =5, cost =1200, isTalent =0},
      -- @Shadowguard Rank 4
      {id =19310, requiredIds ={19309}, rank =4, baseId =18137, race =8, cost =1200, isTalent =0},
      -- @Holy Nova Rank 4
      {id =27799, requiredIds ={15431}, rank =4, baseId =15237, cost =1200, isTalent =1},
       },
[46] = {
      -- @Resurrection Rank 4
      {id =10881, requiredIds ={10880}, rank =4, baseId =2006, cost =26000, isTalent =0},
      -- @Smite Rank 7
      {id =10933, requiredIds ={6060}, rank =7, baseId =585, cost =26000, isTalent =0},
      -- @Mind Blast Rank 7
      {id =10945, requiredIds ={8106}, rank =7, baseId =8092, cost =26000, isTalent =0},
      -- @Greater Heal Rank 2
      {id =10963, requiredIds ={2060}, rank =2, baseId =2060, cost =26000, isTalent =0},
       },
[48] = {
      -- @Mana Burn Rank 4
      {id =10875, requiredIds ={10874}, rank =4, baseId =8129, cost =28000, isTalent =0},
      -- @Power Word: Shield Rank 8
      {id =10899, requiredIds ={10898}, rank =8, baseId =17, cost =28000, isTalent =0},
      -- @Power Word: Fortitude Rank 5
      {id =10937, requiredIds ={2791}, rank =5, baseId =1243, cost =28000, isTalent =0},
      -- @Holy Fire Rank 6
      {id =15266, requiredIds ={15265}, rank =6, baseId =14914, cost =28000, isTalent =0},
      -- @Prayer of Fortitude Rank 1
      {id =21562, rank =1, isTalent =0},
       },
[50] = {
      -- @Shadow Word: Pain Rank 7
      {id =10893, requiredIds ={10892}, rank =7, baseId =589, cost =30000, isTalent =0},
      -- @Flash Heal Rank 6
      {id =10916, requiredIds ={10915}, rank =6, baseId =2061, cost =30000, isTalent =0},
      -- @Renew Rank 8
      {id =10928, requiredIds ={10927}, rank =8, baseId =139, cost =30000, isTalent =0},
      -- @Fade Rank 5
      {id =10941, requiredIds ={9592}, rank =5, baseId =586, cost =30000, isTalent =0},
      -- @Inner Fire Rank 5
      {id =10951, requiredIds ={1006}, rank =5, baseId =588, cost =30000, isTalent =0},
      -- @Prayer of Healing Rank 3
      {id =10960, requiredIds ={996}, rank =3, baseId =596, cost =30000, isTalent =0},
      -- @Divine Spirit Rank 3
      {id =14819, requiredIds ={14818}, rank =3, baseId =14752, cost =1500, isTalent =1},
      -- @Desperate Prayer Rank 6
      {id =19242, requiredIds ={19241}, rank =6, baseId =13908, races ={1, 3}, cost =1500, isTalent =0},
      -- @Touch of Weakness Rank 5
      {id =19265, requiredIds ={19264}, rank =5, baseId =2652, race =5, cost =1500, isTalent =0},
      -- @Feedback Rank 4
      {id =19274, requiredIds ={19273}, rank =4, baseId =13896, race =1, cost =1500, isTalent =0},
      -- @Hex of Weakness Rank 5
      {id =19284, requiredIds ={19283}, rank =5, baseId =9035, race =8, cost =1500, isTalent =0},
      -- @Elune's Grace Rank 4
      {id =19292, requiredIds ={19291}, rank =4, baseId =2651, race =4, cost =1500, isTalent =0},
      -- @Starshards Rank 6
      {id =19304, requiredIds ={19303}, rank =6, baseId =10797, race =4, cost =1500, isTalent =0},
      -- @Lightwell Rank 2
      {id =27870, requiredIds ={724}, rank =2, baseId =724, cost =1200, isTalent =1},
       },
[52] = {
      -- @Mind Blast Rank 8
      {id =10946, requiredIds ={10945}, rank =8, baseId =8092, cost =38000, isTalent =0},
      -- @Mind Soothe Rank 3
      {id =10953, requiredIds ={8192}, rank =3, baseId =453, cost =38000, isTalent =0},
      -- @Greater Heal Rank 3
      {id =10964, requiredIds ={10963}, rank =3, baseId =2060, cost =38000, isTalent =0},
      -- @Mind Flay Rank 5
      {id =17314, requiredIds ={17313}, rank =5, baseId =15407, cost =1900, isTalent =1},
      -- @Devouring Plague Rank 5
      {id =19279, requiredIds ={19278}, rank =5, baseId =2944, race =5, cost =1900, isTalent =0},
      -- @Shadowguard Rank 5
      {id =19311, requiredIds ={19310}, rank =5, baseId =18137, race =8, cost =1900, isTalent =0},
      -- @Holy Nova Rank 5
      {id =27800, requiredIds ={27799}, rank =5, baseId =15237, cost =1900, isTalent =1},
       },
[54] = {
      -- @Power Word: Shield Rank 9
      {id =10900, requiredIds ={10899}, rank =9, baseId =17, cost =40000, isTalent =0},
      -- @Smite Rank 8
      {id =10934, requiredIds ={10933}, rank =8, baseId =585, cost =40000, isTalent =0},
      -- @Holy Fire Rank 7
      {id =15267, requiredIds ={15266}, rank =7, baseId =14914, cost =40000, isTalent =0},
       },
[56] = {
      -- @Mana Burn Rank 5
      {id =10876, requiredIds ={10875}, rank =5, baseId =8129, cost =42000, isTalent =0},
      -- @Psychic Scream Rank 4
      {id =10890, requiredIds ={10888}, rank =4, baseId =8122, cost =42000, isTalent =0},
      -- @Flash Heal Rank 7
      {id =10917, requiredIds ={10916}, rank =7, baseId =2061, cost =42000, isTalent =0},
      -- @Renew Rank 9
      {id =10929, requiredIds ={10928}, rank =9, baseId =139, cost =42000, isTalent =0},
      -- @Shadow Protection Rank 3
      {id =10958, requiredIds ={10957}, rank =3, baseId =976, cost =42000, isTalent =0},
      -- @Prayer of Shadow Protection Rank 1
      {id =27683, rank =1, isTalent =0},
       },
[58] = {
      -- @Shadow Word: Pain Rank 8
      {id =10894, requiredIds ={10893}, rank =8, baseId =589, cost =44000, isTalent =0},
      -- @Mind Control Rank 3
      {id =10912, requiredIds ={10911}, rank =3, baseId =605, cost =44000, isTalent =0},
      -- @Mind Blast Rank 9
      {id =10947, requiredIds ={10946}, rank =9, baseId =8092, cost =44000, isTalent =0},
      -- @Greater Heal Rank 4
      {id =10965, requiredIds ={10964}, rank =4, baseId =2060, cost =44000, isTalent =0},
      -- @Desperate Prayer Rank 7
      {id =19243, requiredIds ={19242}, rank =7, baseId =13908, races ={1, 3}, cost =2200, isTalent =0},
      -- @Starshards Rank 7
      {id =19305, requiredIds ={19304}, rank =7, baseId =10797, race =4, cost =2200, isTalent =0},
      -- @Resurrection Rank 5
      {id =20770, requiredIds ={10881}, rank =5, baseId =2006, cost =44000, isTalent =0},
       },
[60] = {
      -- @Power Word: Shield Rank 10
      {id =10901, requiredIds ={10900}, rank =10, baseId =17, cost =46000, isTalent =0},
      -- @Power Word: Fortitude Rank 6
      {id =10938, requiredIds ={10937}, rank =6, baseId =1243, cost =46000, isTalent =0},
      -- @Fade Rank 6
      {id =10942, requiredIds ={10941}, rank =6, baseId =586, cost =46000, isTalent =0},
      -- @Inner Fire Rank 6
      {id =10952, requiredIds ={10951}, rank =6, baseId =588, cost =46000, isTalent =0},
      -- @Shackle Undead Rank 3
      {id =10955, requiredIds ={9485}, rank =3, baseId =9484, cost =46000, isTalent =0},
      -- @Prayer of Healing Rank 4
      {id =10961, requiredIds ={10960}, rank =4, baseId =596, cost =46000, isTalent =0},
      -- @Holy Fire Rank 8
      {id =15261, requiredIds ={15267}, rank =8, baseId =14914, cost =46000, isTalent =0},
      -- @Mind Flay Rank 6
      {id =18807, requiredIds ={17314}, rank =6, baseId =15407, cost =2300, isTalent =1},
      -- @Touch of Weakness Rank 6
      {id =19266, requiredIds ={19265}, rank =6, baseId =2652, race =5, cost =2300, isTalent =0},
      -- @Feedback Rank 5
      {id =19275, requiredIds ={19274}, rank =5, baseId =13896, race =1, cost =2300, isTalent =0},
      -- @Devouring Plague Rank 6
      {id =19280, requiredIds ={19279}, rank =6, baseId =2944, race =5, cost =2300, isTalent =0},
      -- @Hex of Weakness Rank 6
      {id =19285, requiredIds ={19284}, rank =6, baseId =9035, race =8, cost =2300, isTalent =0},
      -- @Elune's Grace Rank 5
      {id =19293, requiredIds ={19292}, rank =5, baseId =2651, race =4, cost =2300, isTalent =0},
      -- @Shadowguard Rank 6
      {id =19312, requiredIds ={19311}, rank =6, baseId =18137, race =8, cost =2300, isTalent =0},
      -- @Prayer of Fortitude Rank 2
      {id =21564, requiredIds ={21562}, rank =2, baseId =21562, isTalent =0},
      -- @Greater Heal Rank 5
      {id =25314, requiredIds ={10965}, rank =5, baseId =2060, isTalent =0},
      -- @Renew Rank 10
      {id =25315, requiredIds ={10929}, rank =10, baseId =139, isTalent =0},
      -- @Prayer of Healing Rank 5
      {id =25316, requiredIds ={10961}, rank =5, baseId =596, isTalent =0},
      -- @Prayer of Spirit Rank 1
      {id =27681, rank =1, cost =2300, isTalent =0},
      -- @Holy Nova Rank 6
      {id =27801, requiredIds ={27800}, rank =6, baseId =15237, cost =2300, isTalent =1},
      -- @Divine Spirit Rank 4
      {id =27841, requiredIds ={14819}, rank =4, baseId =14752, cost =2300, isTalent =1},
      -- @Lightwell Rank 3
      {id =27871, requiredIds ={27870}, rank =3, baseId =724, cost =1500, isTalent =1}
        }
}




)
