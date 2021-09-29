local _, GW = ...
if (GW.myclass ~= "SHAMAN") then
    return
end
GW.SpellsByLevel = {
[0] = {
      -- @One-Handed Axes undefined
      {id =196, isTalent =0, isSkill =1},
      -- @Two-Handed Axes undefined
      {id =197, isTalent =0, isSkill =1},
      -- @One-Handed Maces undefined
      {id =198, isTalent =0, isSkill =1},
      -- @Two-Handed Maces undefined
      {id =199, isTalent =0, isSkill =1},
      -- @Staves undefined
      {id =227, isTalent =0, isSkill =1},
      -- @Daggers undefined
      {id =1180, isTalent =0, isSkill =1},
      -- @Leather undefined
      {id =9077, isTalent =0, isSkill =1},
      -- @Shield undefined
      {id =9116, isTalent =0, isSkill =1},
      -- @Fist Weapons undefined
      {id =15590, isTalent =0, isSkill =1},
      -- @Concussion Rank 1
      {id =16035, rank =1, isTalent =1},
      -- @Call of Flame Rank 1
      {id =16038, rank =1, isTalent =1},
      -- @Convection Rank 1
      {id =16039, rank =1, isTalent =1},
      -- @Reverberation Rank 1
      {id =16040, rank =1, isTalent =1},
      -- @Call of Thunder Rank 1
      {id =16041, rank =1, isTalent =1},
      -- @Earth's Grasp Rank 1
      {id =16043, rank =1, isTalent =1},
      -- @Improved Fire Totems Rank 1
      {id =16086, rank =1, isTalent =1},
      -- @Elemental Fury undefined
      {id =16089, isTalent =1},
      -- @Concussion Rank 2
      {id =16105, requiredIds ={16035}, rank =2, baseId =16035, isTalent =1},
      -- @Concussion Rank 3
      {id =16106, requiredIds ={16105}, rank =3, baseId =16035, isTalent =1},
      -- @Concussion Rank 4
      {id =16107, requiredIds ={16106}, rank =4, baseId =16035, isTalent =1},
      -- @Concussion Rank 5
      {id =16108, requiredIds ={16107}, rank =5, baseId =16035, isTalent =1},
      -- @Convection Rank 2
      {id =16109, requiredIds ={16039}, rank =2, baseId =16039, isTalent =1},
      -- @Convection Rank 3
      {id =16110, requiredIds ={16109}, rank =3, baseId =16039, isTalent =1},
      -- @Convection Rank 4
      {id =16111, requiredIds ={16110}, rank =4, baseId =16039, isTalent =1},
      -- @Convection Rank 5
      {id =16112, requiredIds ={16111}, rank =5, baseId =16039, isTalent =1},
      -- @Reverberation Rank 2
      {id =16113, requiredIds ={16040}, rank =2, baseId =16040, isTalent =1},
      -- @Reverberation Rank 3
      {id =16114, requiredIds ={16113}, rank =3, baseId =16040, isTalent =1},
      -- @Reverberation Rank 4
      {id =16115, requiredIds ={16114}, rank =4, baseId =16040, isTalent =1},
      -- @Reverberation Rank 5
      {id =16116, requiredIds ={16115}, rank =5, baseId =16040, isTalent =1},
      -- @Call of Thunder Rank 2
      {id =16117, requiredIds ={16041}, rank =2, baseId =16041, isTalent =1},
      -- @Call of Thunder Rank 3
      {id =16118, requiredIds ={16117}, rank =3, baseId =16041, isTalent =1},
      -- @Call of Thunder Rank 4
      {id =16119, requiredIds ={16118}, rank =4, baseId =16041, isTalent =1},
      -- @Call of Thunder Rank 5
      {id =16120, requiredIds ={16119}, rank =5, baseId =16041, isTalent =1},
      -- @Earth's Grasp Rank 2
      {id =16130, requiredIds ={16043}, rank =2, baseId =16043, isTalent =1},
      -- @Call of Flame Rank 2
      {id =16160, requiredIds ={16038}, rank =2, baseId =16038, isTalent =1},
      -- @Call of Flame Rank 3
      {id =16161, requiredIds ={16160}, rank =3, baseId =16038, isTalent =1},
      -- @Elemental Focus undefined
      {id =16164, isTalent =1},
      -- @Elemental Mastery undefined
      {id =16166, isTalent =1},
      -- @Totemic Focus Rank 1
      {id =16173, rank =1, isTalent =1},
      -- @Ancestral Healing Rank 1
      {id =16176, rank =1, isTalent =1},
      -- @Purification Rank 1
      {id =16178, rank =1, isTalent =1},
      -- @Tidal Focus Rank 1
      {id =16179, rank =1, isTalent =1},
      -- @Nature's Guidance Rank 1
      {id =16180, rank =1, isTalent =1},
      -- @Healing Focus Rank 1
      {id =16181, rank =1, isTalent =1},
      -- @Improved Healing Wave Rank 1
      {id =16182, rank =1, isTalent =1},
      -- @Improved Reincarnation Rank 1
      {id =16184, rank =1, isTalent =1},
      -- @Restorative Totems Rank 1
      {id =16187, rank =1, isTalent =1},
      -- @Nature's Swiftness undefined
      {id =16188, isTalent =1},
      -- @Mana Tide Totem Rank 1
      {id =16190, rank =1, isTalent =1},
      -- @Tidal Mastery Rank 1
      {id =16194, rank =1, isTalent =1},
      -- @Nature's Guidance Rank 2
      {id =16196, requiredIds ={16180}, rank =2, baseId =16180, isTalent =1},
      -- @Nature's Guidance Rank 3
      {id =16198, requiredIds ={16196}, rank =3, baseId =16180, isTalent =1},
      -- @Restorative Totems Rank 2
      {id =16205, requiredIds ={16187}, rank =2, baseId =16187, isTalent =1},
      -- @Restorative Totems Rank 3
      {id =16206, requiredIds ={16205}, rank =3, baseId =16187, isTalent =1},
      -- @Restorative Totems Rank 4
      {id =16207, requiredIds ={16206}, rank =4, baseId =16187, isTalent =1},
      -- @Restorative Totems Rank 5
      {id =16208, requiredIds ={16207}, rank =5, baseId =16187, isTalent =1},
      -- @Improved Reincarnation Rank 2
      {id =16209, requiredIds ={16184}, rank =2, baseId =16184, isTalent =1},
      -- @Purification Rank 2
      {id =16210, requiredIds ={16178}, rank =2, baseId =16178, isTalent =1},
      -- @Purification Rank 3
      {id =16211, requiredIds ={16210}, rank =3, baseId =16178, isTalent =1},
      -- @Purification Rank 4
      {id =16212, requiredIds ={16211}, rank =4, baseId =16178, isTalent =1},
      -- @Purification Rank 5
      {id =16213, requiredIds ={16212}, rank =5, baseId =16178, isTalent =1},
      -- @Tidal Focus Rank 2
      {id =16214, requiredIds ={16179}, rank =2, baseId =16179, isTalent =1},
      -- @Tidal Focus Rank 3
      {id =16215, requiredIds ={16214}, rank =3, baseId =16179, isTalent =1},
      -- @Tidal Focus Rank 4
      {id =16216, requiredIds ={16215}, rank =4, baseId =16179, isTalent =1},
      -- @Tidal Focus Rank 5
      {id =16217, requiredIds ={16216}, rank =5, baseId =16179, isTalent =1},
      -- @Tidal Mastery Rank 2
      {id =16218, requiredIds ={16194}, rank =2, baseId =16194, isTalent =1},
      -- @Tidal Mastery Rank 3
      {id =16219, requiredIds ={16218}, rank =3, baseId =16194, isTalent =1},
      -- @Tidal Mastery Rank 4
      {id =16220, requiredIds ={16219}, rank =4, baseId =16194, isTalent =1},
      -- @Tidal Mastery Rank 5
      {id =16221, requiredIds ={16220}, rank =5, baseId =16194, isTalent =1},
      -- @Totemic Focus Rank 2
      {id =16222, requiredIds ={16173}, rank =2, baseId =16173, isTalent =1},
      -- @Totemic Focus Rank 3
      {id =16223, requiredIds ={16222}, rank =3, baseId =16173, isTalent =1},
      -- @Totemic Focus Rank 4
      {id =16224, requiredIds ={16223}, rank =4, baseId =16173, isTalent =1},
      -- @Totemic Focus Rank 5
      {id =16225, requiredIds ={16224}, rank =5, baseId =16173, isTalent =1},
      -- @Improved Healing Wave Rank 2
      {id =16226, requiredIds ={16182}, rank =2, baseId =16182, isTalent =1},
      -- @Improved Healing Wave Rank 3
      {id =16227, requiredIds ={16226}, rank =3, baseId =16182, isTalent =1},
      -- @Improved Healing Wave Rank 4
      {id =16228, requiredIds ={16227}, rank =4, baseId =16182, isTalent =1},
      -- @Improved Healing Wave Rank 5
      {id =16229, requiredIds ={16228}, rank =5, baseId =16182, isTalent =1},
      -- @Healing Focus Rank 2
      {id =16230, requiredIds ={16181}, rank =2, baseId =16181, isTalent =1},
      -- @Healing Focus Rank 3
      {id =16232, requiredIds ={16230}, rank =3, baseId =16181, isTalent =1},
      -- @Healing Focus Rank 4
      {id =16233, requiredIds ={16232}, rank =4, baseId =16181, isTalent =1},
      -- @Healing Focus Rank 5
      {id =16234, requiredIds ={16233}, rank =5, baseId =16181, isTalent =1},
      -- @Ancestral Healing Rank 2
      {id =16235, requiredIds ={16176}, rank =2, baseId =16176, isTalent =1},
      -- @Ancestral Healing Rank 3
      {id =16240, requiredIds ={16235}, rank =3, baseId =16176, isTalent =1},
      -- @Toughness Rank 1
      {id =16252, rank =1, isTalent =1},
      -- @Anticipation Rank 1
      {id =16254, rank =1, isTalent =1},
      -- @Thundering Strikes Rank 1
      {id =16255, rank =1, isTalent =1},
      -- @Flurry Rank 1
      {id =16256, rank =1, isTalent =1},
      -- @Guardian Totems Rank 1
      {id =16258, rank =1, isTalent =1},
      -- @Enhancing Totems Rank 1
      {id =16259, rank =1, isTalent =1},
      -- @Improved Lightning Shield Rank 1
      {id =16261, rank =1, isTalent =1},
      -- @Improved Ghost Wolf Rank 1
      {id =16262, rank =1, isTalent =1},
      -- @Elemental Weapons Rank 1
      {id =16266, rank =1, isTalent =1},
      -- @Parry undefined
      {id =16268, isTalent =1},
      -- @Two-Handed Axes and Maces undefined
      {id =16269, isTalent =1},
      -- @Anticipation Rank 2
      {id =16271, requiredIds ={16254}, rank =2, baseId =16254, isTalent =1},
      -- @Anticipation Rank 3
      {id =16272, requiredIds ={16271}, rank =3, baseId =16254, isTalent =1},
      -- @Anticipation Rank 4
      {id =16273, requiredIds ={16272}, rank =4, baseId =16254, isTalent =1},
      -- @Anticipation Rank 5
      {id =16274, requiredIds ={16273}, rank =5, baseId =16254, isTalent =1},
      -- @Flurry Rank 2
      {id =16281, requiredIds ={16256}, rank =2, baseId =16256, isTalent =1},
      -- @Flurry Rank 3
      {id =16282, requiredIds ={16281}, rank =3, baseId =16256, isTalent =1},
      -- @Flurry Rank 4
      {id =16283, requiredIds ={16282}, rank =4, baseId =16256, isTalent =1},
      -- @Flurry Rank 5
      {id =16284, requiredIds ={16283}, rank =5, baseId =16256, isTalent =1},
      -- @Improved Ghost Wolf Rank 2
      {id =16287, requiredIds ={16262}, rank =2, baseId =16262, isTalent =1},
      -- @Improved Lightning Shield Rank 2
      {id =16290, requiredIds ={16261}, rank =2, baseId =16261, isTalent =1},
      -- @Guardian Totems Rank 2
      {id =16293, requiredIds ={16258}, rank =2, baseId =16258, isTalent =1},
      -- @Enhancing Totems Rank 2
      {id =16295, requiredIds ={16259}, rank =2, baseId =16259, isTalent =1},
      -- @Shield Specialization Rank 3
      {id =16299, rank =3, isTalent =1},
      -- @Shield Specialization Rank 4
      {id =16300, requiredIds ={16299}, rank =4, isTalent =1},
      -- @Shield Specialization Rank 5
      {id =16301, requiredIds ={16300}, rank =5, isTalent =1},
      -- @Thundering Strikes Rank 2
      {id =16302, requiredIds ={16255}, rank =2, baseId =16255, isTalent =1},
      -- @Thundering Strikes Rank 3
      {id =16303, requiredIds ={16302}, rank =3, baseId =16255, isTalent =1},
      -- @Thundering Strikes Rank 4
      {id =16304, requiredIds ={16303}, rank =4, baseId =16255, isTalent =1},
      -- @Thundering Strikes Rank 5
      {id =16305, requiredIds ={16304}, rank =5, baseId =16255, isTalent =1},
      -- @Toughness Rank 2
      {id =16306, requiredIds ={16252}, rank =2, baseId =16252, isTalent =1},
      -- @Toughness Rank 3
      {id =16307, requiredIds ={16306}, rank =3, baseId =16252, isTalent =1},
      -- @Toughness Rank 4
      {id =16308, requiredIds ={16307}, rank =4, baseId =16252, isTalent =1},
      -- @Toughness Rank 5
      {id =16309, requiredIds ={16308}, rank =5, baseId =16252, isTalent =1},
      -- @Improved Fire Totems Rank 2
      {id =16544, requiredIds ={16086}, rank =2, baseId =16086, isTalent =1},
      -- @Lightning Mastery Rank 1
      {id =16578, rank =1, isTalent =1},
      -- @Lightning Mastery Rank 2
      {id =16579, requiredIds ={16578}, rank =2, baseId =16578, isTalent =1},
      -- @Lightning Mastery Rank 3
      {id =16580, requiredIds ={16579}, rank =3, baseId =16578, isTalent =1},
      -- @Lightning Mastery Rank 4
      {id =16581, requiredIds ={16580}, rank =4, baseId =16578, isTalent =1},
      -- @Lightning Mastery Rank 5
      {id =16582, requiredIds ={16581}, rank =5, baseId =16578, isTalent =1},
      -- @Stormstrike Rank 1
      {id =17364, rank =1, isTalent =1},
      -- @Ancestral Knowledge Rank 1
      {id =17485, rank =1, isTalent =1},
      -- @Ancestral Knowledge Rank 2
      {id =17486, requiredIds ={17485}, rank =2, baseId =17485, isTalent =1},
      -- @Ancestral Knowledge Rank 3
      {id =17487, requiredIds ={17486}, rank =3, baseId =17485, isTalent =1},
      -- @Ancestral Knowledge Rank 4
      {id =17488, requiredIds ={17487}, rank =4, baseId =17485, isTalent =1},
      -- @Ancestral Knowledge Rank 5
      {id =17489, requiredIds ={17488}, rank =5, baseId =17485, isTalent =1},
      -- @Totem undefined
      {id =27763, isTalent =0, isSkill =1},
      -- @Elemental Warding Rank 1
      {id =28996, rank =1, isTalent =1},
      -- @Elemental Warding Rank 2
      {id =28997, requiredIds ={28996}, rank =2, baseId =28996, isTalent =1},
      -- @Elemental Warding Rank 3
      {id =28998, requiredIds ={28997}, rank =3, baseId =28996, isTalent =1},
      -- @Storm Reach Rank 1
      {id =28999, rank =1, isTalent =1},
      -- @Storm Reach Rank 2
      {id =29000, requiredIds ={28999}, rank =2, baseId =28999, isTalent =1},
      -- @Eye of the Storm Rank 1
      {id =29062, rank =1, isTalent =1},
      -- @Eye of the Storm Rank 2
      {id =29064, requiredIds ={29062}, rank =2, baseId =29062, isTalent =1},
      -- @Eye of the Storm Rank 3
      {id =29065, requiredIds ={29064}, rank =3, baseId =29062, isTalent =1},
      -- @Elemental Weapons Rank 2
      {id =29079, requiredIds ={16266}, rank =2, baseId =16266, isTalent =1},
      -- @Elemental Weapons Rank 3
      {id =29080, requiredIds ={29079}, rank =3, baseId =16266, isTalent =1},
      -- @Weapon Mastery Rank 1
      {id =29082, rank =1, isTalent =1},
      -- @Weapon Mastery Rank 2
      {id =29084, requiredIds ={29082}, rank =2, baseId =29082, isTalent =1},
      -- @Weapon Mastery Rank 3
      {id =29086, requiredIds ={29084}, rank =3, baseId =29082, isTalent =1},
      -- @Weapon Mastery Rank 4
      {id =29087, requiredIds ={29086}, rank =4, baseId =29082, isTalent =1},
      -- @Weapon Mastery Rank 5
      {id =29088, requiredIds ={29087}, rank =5, baseId =29082, isTalent =1},
      -- @Elemental Devastation Rank 2
      {id =29179, requiredIds ={30160}, rank =2, baseId =30160, isTalent =1},
      -- @Elemental Devastation Rank 3
      {id =29180, requiredIds ={29179}, rank =3, baseId =30160, isTalent =1},
      -- @Healing Grace Rank 1
      {id =29187, rank =1, isTalent =1},
      -- @Healing Grace Rank 2
      {id =29189, requiredIds ={29187}, rank =2, baseId =29187, isTalent =1},
      -- @Healing Grace Rank 3
      {id =29191, requiredIds ={29189}, rank =3, baseId =29187, isTalent =1},
      -- @Improved Weapon Totems Rank 1
      {id =29192, rank =1, isTalent =1},
      -- @Improved Weapon Totems Rank 2
      {id =29193, requiredIds ={29192}, rank =2, baseId =29192, isTalent =1},
      -- @Healing Way Rank 3
      {id =29202, requiredIds ={29205}, rank =3, baseId =29206, isTalent =1},
      -- @Healing Way Rank 2
      {id =29205, requiredIds ={29206}, rank =2, baseId =29206, isTalent =1},
      -- @Healing Way Rank 1
      {id =29206, rank =1, isTalent =1},
      -- @Elemental Devastation Rank 1
      {id =30160, rank =1, isTalent =1},
       },
[1] = {
      -- @Block Passive
      {id =107, isTalent =0, isSkill =1},
      -- @Healing Wave Rank 1
      {id =331, rank =1, isTalent =0},
      -- @Lightning Bolt Rank 1
      {id =403, rank =1, isTalent =0},
      -- @Rockbiter Weapon Rank 1
      {id =8017, rank =1, cost =10, isTalent =0},
       },
[4] = {
      -- @Earth Shock Rank 1
      {id =8042, rank =1, cost =100, isTalent =0},
      -- @Stoneskin Totem Rank 1
      {id =8071, rank =1, isTalent =0},
       },
[6] = {
      -- @Healing Wave Rank 2
      {id =332, requiredIds ={331}, rank =2, baseId =331, cost =100, isTalent =0},
      -- @Earthbind Totem undefined
      {id =2484, cost =100, isTalent =0},
       },
[8] = {
      -- @Lightning Shield Rank 1
      {id =324, rank =1, cost =100, isTalent =0},
      -- @Lightning Bolt Rank 2
      {id =529, requiredIds ={403}, rank =2, baseId =403, cost =100, isTalent =0},
      -- @Stoneclaw Totem Rank 1
      {id =5730, rank =1, cost =100, isTalent =0},
      -- @Rockbiter Weapon Rank 2
      {id =8018, requiredIds ={8017}, rank =2, baseId =8017, cost =100, isTalent =0},
      -- @Earth Shock Rank 2
      {id =8044, requiredIds ={8042}, rank =2, baseId =8042, cost =100, isTalent =0},
       },
[10] = {
      -- @Searing Totem Rank 1
      {id =3599, rank =1, isTalent =0},
      -- @Flametongue Weapon Rank 1
      {id =8024, rank =1, cost =400, isTalent =0},
      -- @Flame Shock Rank 1
      {id =8050, rank =1, cost =400, isTalent =0},
      -- @Strength of Earth Totem Rank 1
      {id =8075, rank =1, cost =400, isTalent =0},
       },
[12] = {
      -- @Purge Rank 1
      {id =370, rank =1, cost =800, isTalent =0},
      -- @Healing Wave Rank 3
      {id =547, requiredIds ={332}, rank =3, baseId =331, cost =800, isTalent =0},
      -- @Fire Nova Totem Rank 1
      {id =1535, rank =1, cost =800, isTalent =0},
      -- @Ancestral Spirit Rank 1
      {id =2008, rank =1, cost =800, isTalent =0},
       },
[14] = {
      -- @Lightning Bolt Rank 3
      {id =548, requiredIds ={529}, rank =3, baseId =403, cost =900, isTalent =0},
      -- @Earth Shock Rank 3
      {id =8045, requiredIds ={8044}, rank =3, baseId =8042, cost =900, isTalent =0},
      -- @Stoneskin Totem Rank 2
      {id =8154, requiredIds ={8071}, rank =2, baseId =8071, cost =900, isTalent =0},
       },
[16] = {
      -- @Lightning Shield Rank 2
      {id =325, requiredIds ={324}, rank =2, baseId =324, cost =1800, isTalent =0},
      -- @Cure Poison undefined
      {id =526, cost =1800, isTalent =0},
      -- @Rockbiter Weapon Rank 3
      {id =8019, requiredIds ={8018}, rank =3, baseId =8017, cost =1800, isTalent =0},
       },
[18] = {
      -- @Healing Wave Rank 4
      {id =913, requiredIds ={547}, rank =4, baseId =331, cost =2000, isTalent =0},
      -- @Stoneclaw Totem Rank 2
      {id =6390, requiredIds ={5730}, rank =2, baseId =5730, cost =2000, isTalent =0},
      -- @Flametongue Weapon Rank 2
      {id =8027, requiredIds ={8024}, rank =2, baseId =8024, cost =2000, isTalent =0},
      -- @Flame Shock Rank 2
      {id =8052, requiredIds ={8050}, rank =2, baseId =8050, cost =2000, isTalent =0},
      -- @Tremor Totem undefined
      {id =8143, cost =2000, isTalent =0},
       },
[20] = {
      -- @Lightning Bolt Rank 4
      {id =915, requiredIds ={548}, rank =4, baseId =403, cost =2200, isTalent =0},
      -- @Ghost Wolf undefined
      {id =2645, cost =2200, isTalent =0},
      -- @Healing Stream Totem Rank 1
      {id =5394, rank =1, isTalent =0},
      -- @Searing Totem Rank 2
      {id =6363, requiredIds ={3599}, rank =2, baseId =3599, cost =2200, isTalent =0},
      -- @Lesser Healing Wave Rank 1
      {id =8004, rank =1, cost =2200, isTalent =0},
      -- @Frostbrand Weapon Rank 1
      {id =8033, rank =1, cost =2200, isTalent =0},
      -- @Frost Shock Rank 1
      {id =8056, rank =1, cost =2200, isTalent =0},
       },
[22] = {
      -- @Water Breathing undefined
      {id =131, cost =3000, isTalent =0},
      -- @Cure Disease undefined
      {id =2870, cost =3000, isTalent =0},
      -- @Poison Cleansing Totem undefined
      {id =8166, cost =3000, isTalent =0},
      -- @Fire Nova Totem Rank 2
      {id =8498, requiredIds ={1535}, rank =2, baseId =1535, cost =3000, isTalent =0},
       },
[24] = {
      -- @Lightning Shield Rank 3
      {id =905, requiredIds ={325}, rank =3, baseId =324, cost =3500, isTalent =0},
      -- @Healing Wave Rank 5
      {id =939, requiredIds ={913}, rank =5, baseId =331, cost =3500, isTalent =0},
      -- @Earth Shock Rank 4
      {id =8046, requiredIds ={8045}, rank =4, baseId =8042, cost =3500, isTalent =0},
      -- @Stoneskin Totem Rank 3
      {id =8155, requiredIds ={8154}, rank =3, baseId =8071, cost =3500, isTalent =0},
      -- @Strength of Earth Totem Rank 2
      {id =8160, requiredIds ={8075}, rank =2, baseId =8075, cost =3500, isTalent =0},
      -- @Frost Resistance Totem Rank 1
      {id =8181, rank =1, cost =3500, isTalent =0},
      -- @Rockbiter Weapon Rank 4
      {id =10399, requiredIds ={8019}, rank =4, baseId =8017, cost =3500, isTalent =0},
      -- @Ancestral Spirit Rank 2
      {id =20609, requiredIds ={2008}, rank =2, baseId =2008, cost =3500, isTalent =0},
       },
[26] = {
      -- @Lightning Bolt Rank 5
      {id =943, requiredIds ={915}, rank =5, baseId =403, cost =4000, isTalent =0},
      -- @Mana Spring Totem Rank 1
      {id =5675, rank =1, cost =4000, isTalent =0},
      -- @Far Sight undefined
      {id =6196, cost =4000, isTalent =0},
      -- @Flametongue Weapon Rank 3
      {id =8030, requiredIds ={8027}, rank =3, baseId =8024, cost =4000, isTalent =0},
      -- @Magma Totem Rank 1
      {id =8190, rank =1, cost =4000, isTalent =0},
       },
[28] = {
      -- @Water Walking undefined
      {id =546, cost =6000, isTalent =0},
      -- @Stoneclaw Totem Rank 3
      {id =6391, requiredIds ={6390}, rank =3, baseId =5730, cost =6000, isTalent =0},
      -- @Lesser Healing Wave Rank 2
      {id =8008, requiredIds ={8004}, rank =2, baseId =8004, cost =6000, isTalent =0},
      -- @Frostbrand Weapon Rank 2
      {id =8038, requiredIds ={8033}, rank =2, baseId =8033, cost =6000, isTalent =0},
      -- @Flame Shock Rank 3
      {id =8053, requiredIds ={8052}, rank =3, baseId =8050, cost =6000, isTalent =0},
      -- @Fire Resistance Totem Rank 1
      {id =8184, rank =1, cost =6000, isTalent =0},
      -- @Flametongue Totem Rank 1
      {id =8227, rank =1, cost =6000, isTalent =0},
       },
[30] = {
      -- @Astral Recall undefined
      {id =556, cost =7000, isTalent =0},
      -- @Searing Totem Rank 3
      {id =6364, requiredIds ={6363}, rank =3, baseId =3599, cost =7000, isTalent =0},
      -- @Healing Stream Totem Rank 2
      {id =6375, requiredIds ={5394}, rank =2, baseId =5394, cost =7000, isTalent =0},
      -- @Grounding Totem undefined
      {id =8177, cost =7000, isTalent =0},
      -- @Windfury Weapon Rank 1
      {id =8232, rank =1, cost =7000, isTalent =0},
      -- @Nature Resistance Totem Rank 1
      {id =10595, rank =1, cost =7000, isTalent =0},
      -- @Reincarnation Passive
      {id =20608, cost =7000, isTalent =0},
       },
[32] = {
      -- @Chain Lightning Rank 1
      {id =421, rank =1, cost =8000, isTalent =0},
      -- @Lightning Shield Rank 4
      {id =945, requiredIds ={905}, rank =4, baseId =324, cost =8000, isTalent =0},
      -- @Healing Wave Rank 6
      {id =959, requiredIds ={939}, rank =6, baseId =331, cost =8000, isTalent =0},
      -- @Lightning Bolt Rank 6
      {id =6041, requiredIds ={943}, rank =6, baseId =403, cost =8000, isTalent =0},
      -- @Purge Rank 2
      {id =8012, requiredIds ={370}, rank =2, baseId =370, cost =8000, isTalent =0},
      -- @Fire Nova Totem Rank 3
      {id =8499, requiredIds ={8498}, rank =3, baseId =1535, cost =8000, isTalent =0},
      -- @Windfury Totem Rank 1
      {id =8512, rank =1, cost =8000, isTalent =0},
       },
[34] = {
      -- @Sentry Totem undefined
      {id =6495, cost =9000, isTalent =0},
      -- @Frost Shock Rank 2
      {id =8058, requiredIds ={8056}, rank =2, baseId =8056, cost =9000, isTalent =0},
      -- @Stoneskin Totem Rank 4
      {id =10406, requiredIds ={8155}, rank =4, baseId =8071, cost =9000, isTalent =0},
      -- @Rockbiter Weapon Rank 5
      {id =16314, requiredIds ={10399}, rank =5, baseId =8017, cost =9000, isTalent =0},
       },
[36] = {
      -- @Lesser Healing Wave Rank 3
      {id =8010, requiredIds ={8008}, rank =3, baseId =8004, cost =10000, isTalent =0},
      -- @Earth Shock Rank 5
      {id =10412, requiredIds ={8046}, rank =5, baseId =8042, cost =10000, isTalent =0},
      -- @Mana Spring Totem Rank 2
      {id =10495, requiredIds ={5675}, rank =2, baseId =5675, cost =10000, isTalent =0},
      -- @Magma Totem Rank 2
      {id =10585, requiredIds ={8190}, rank =2, baseId =8190, cost =10000, isTalent =0},
      -- @Windwall Totem Rank 1
      {id =15107, rank =1, cost =10000, isTalent =0},
      -- @Flametongue Weapon Rank 4
      {id =16339, requiredIds ={8030}, rank =4, baseId =8024, cost =10000, isTalent =0},
      -- @Ancestral Spirit Rank 3
      {id =20610, requiredIds ={20609}, rank =3, baseId =2008, cost =10000, isTalent =0},
       },
[38] = {
      -- @Stoneclaw Totem Rank 4
      {id =6392, requiredIds ={6391}, rank =4, baseId =5730, cost =11000, isTalent =0},
      -- @Strength of Earth Totem Rank 3
      {id =8161, requiredIds ={8160}, rank =3, baseId =8075, cost =11000, isTalent =0},
      -- @Disease Cleansing Totem undefined
      {id =8170, cost =11000, isTalent =0},
      -- @Flametongue Totem Rank 2
      {id =8249, requiredIds ={8227}, rank =2, baseId =8227, cost =11000, isTalent =0},
      -- @Lightning Bolt Rank 7
      {id =10391, requiredIds ={6041}, rank =7, baseId =403, cost =11000, isTalent =0},
      -- @Frostbrand Weapon Rank 3
      {id =10456, requiredIds ={8038}, rank =3, baseId =8033, cost =11000, isTalent =0},
      -- @Frost Resistance Totem Rank 2
      {id =10478, requiredIds ={8181}, rank =2, baseId =8181, cost =11000, isTalent =0},
       },
[40] = {
      -- @Chain Lightning Rank 2
      {id =930, requiredIds ={421}, rank =2, baseId =421, cost =12000, isTalent =0},
      -- @Chain Heal Rank 1
      {id =1064, rank =1, cost =12000, isTalent =0},
      -- @Searing Totem Rank 4
      {id =6365, requiredIds ={6364}, rank =4, baseId =3599, cost =12000, isTalent =0},
      -- @Healing Stream Totem Rank 3
      {id =6377, requiredIds ={6375}, rank =3, baseId =5394, cost =12000, isTalent =0},
      -- @Healing Wave Rank 7
      {id =8005, requiredIds ={959}, rank =7, baseId =331, cost =12000, isTalent =0},
      -- @Lightning Shield Rank 5
      {id =8134, requiredIds ={945}, rank =5, baseId =324, cost =12000, isTalent =0},
      -- @Windfury Weapon Rank 2
      {id =8235, requiredIds ={8232}, rank =2, baseId =8232, cost =12000, isTalent =0},
      -- @Mail undefined
      {id =8737, isTalent =0, isSkill =1},
      -- @Flame Shock Rank 4
      {id =10447, requiredIds ={8053}, rank =4, baseId =8050, cost =12000, isTalent =0},
       },
[42] = {
      -- @Grace of Air Totem Rank 1
      {id =8835, rank =1, cost =16000, isTalent =0},
      -- @Fire Resistance Totem Rank 2
      {id =10537, requiredIds ={8184}, rank =2, baseId =8184, cost =16000, isTalent =0},
      -- @Windfury Totem Rank 2
      {id =10613, requiredIds ={8512}, rank =2, baseId =8512, cost =16000, isTalent =0},
      -- @Fire Nova Totem Rank 4
      {id =11314, requiredIds ={8499}, rank =4, baseId =1535, cost =16000, isTalent =0},
       },
[44] = {
      -- @Lightning Bolt Rank 8
      {id =10392, requiredIds ={10391}, rank =8, baseId =403, cost =18000, isTalent =0},
      -- @Stoneskin Totem Rank 5
      {id =10407, requiredIds ={10406}, rank =5, baseId =8071, cost =18000, isTalent =0},
      -- @Lesser Healing Wave Rank 4
      {id =10466, requiredIds ={8010}, rank =4, baseId =8004, cost =18000, isTalent =0},
      -- @Nature Resistance Totem Rank 2
      {id =10600, requiredIds ={10595}, rank =2, baseId =10595, cost =18000, isTalent =0},
      -- @Rockbiter Weapon Rank 6
      {id =16315, requiredIds ={16314}, rank =6, baseId =8017, cost =18000, isTalent =0},
       },
[46] = {
      -- @Frost Shock Rank 3
      {id =10472, requiredIds ={8058}, rank =3, baseId =8056, cost =20000, isTalent =0},
      -- @Mana Spring Totem Rank 3
      {id =10496, requiredIds ={10495}, rank =3, baseId =5675, cost =20000, isTalent =0},
      -- @Magma Totem Rank 3
      {id =10586, requiredIds ={10585}, rank =3, baseId =8190, cost =20000, isTalent =0},
      -- @Chain Heal Rank 2
      {id =10622, requiredIds ={1064}, rank =2, baseId =1064, cost =20000, isTalent =0},
      -- @Windwall Totem Rank 2
      {id =15111, requiredIds ={15107}, rank =2, baseId =15107, cost =20000, isTalent =0},
      -- @Flametongue Weapon Rank 5
      {id =16341, requiredIds ={16339}, rank =5, baseId =8024, cost =20000, isTalent =0},
       },
[48] = {
      -- @Chain Lightning Rank 3
      {id =2860, requiredIds ={930}, rank =3, baseId =421, cost =22000, isTalent =0},
      -- @Healing Wave Rank 8
      {id =10395, requiredIds ={8005}, rank =8, baseId =331, cost =22000, isTalent =0},
      -- @Earth Shock Rank 6
      {id =10413, requiredIds ={10412}, rank =6, baseId =8042, cost =22000, isTalent =0},
      -- @Stoneclaw Totem Rank 5
      {id =10427, requiredIds ={6392}, rank =5, baseId =5730, cost =22000, isTalent =0},
      -- @Lightning Shield Rank 6
      {id =10431, requiredIds ={8134}, rank =6, baseId =324, cost =22000, isTalent =0},
      -- @Flametongue Totem Rank 3
      {id =10526, requiredIds ={8249}, rank =3, baseId =8227, cost =22000, isTalent =0},
      -- @Frostbrand Weapon Rank 4
      {id =16355, requiredIds ={10456}, rank =4, baseId =8033, cost =22000, isTalent =0},
      -- @Mana Tide Totem Rank 2
      {id =17354, requiredIds ={16190}, rank =2, baseId =16190, cost =1100, isTalent =1},
      -- @Ancestral Spirit Rank 4
      {id =20776, requiredIds ={20610}, rank =4, baseId =2008, cost =22000, isTalent =0},
       },
[50] = {
      -- @Searing Totem Rank 5
      {id =10437, requiredIds ={6365}, rank =5, baseId =3599, cost =24000, isTalent =0},
      -- @Healing Stream Totem Rank 4
      {id =10462, requiredIds ={6377}, rank =4, baseId =5394, cost =24000, isTalent =0},
      -- @Windfury Weapon Rank 3
      {id =10486, requiredIds ={8235}, rank =3, baseId =8232, cost =24000, isTalent =0},
      -- @Lightning Bolt Rank 9
      {id =15207, requiredIds ={10392}, rank =9, baseId =403, cost =24000, isTalent =0},
      -- @Tranquil Air Totem undefined
      {id =25908, cost =24000, isTalent =0},
       },
[52] = {
      -- @Strength of Earth Totem Rank 4
      {id =10442, requiredIds ={8161}, rank =4, baseId =8075, cost =27000, isTalent =0},
      -- @Flame Shock Rank 5
      {id =10448, requiredIds ={10447}, rank =5, baseId =8050, cost =27000, isTalent =0},
      -- @Lesser Healing Wave Rank 5
      {id =10467, requiredIds ={10466}, rank =5, baseId =8004, cost =27000, isTalent =0},
      -- @Windfury Totem Rank 3
      {id =10614, requiredIds ={10613}, rank =3, baseId =8512, cost =27000, isTalent =0},
      -- @Fire Nova Totem Rank 5
      {id =11315, requiredIds ={11314}, rank =5, baseId =1535, cost =27000, isTalent =0},
       },
[54] = {
      -- @Stoneskin Totem Rank 6
      {id =10408, requiredIds ={10407}, rank =6, baseId =8071, cost =29000, isTalent =0},
      -- @Frost Resistance Totem Rank 3
      {id =10479, requiredIds ={10478}, rank =3, baseId =8181, cost =29000, isTalent =0},
      -- @Chain Heal Rank 3
      {id =10623, requiredIds ={10622}, rank =3, baseId =1064, cost =29000, isTalent =0},
      -- @Rockbiter Weapon Rank 7
      {id =16316, requiredIds ={16315}, rank =7, baseId =8017, cost =29000, isTalent =0},
       },
[56] = {
      -- @Healing Wave Rank 9
      {id =10396, requiredIds ={10395}, rank =9, baseId =331, cost =30000, isTalent =0},
      -- @Lightning Shield Rank 7
      {id =10432, requiredIds ={10431}, rank =7, baseId =324, cost =30000, isTalent =0},
      -- @Mana Spring Totem Rank 4
      {id =10497, requiredIds ={10496}, rank =4, baseId =5675, cost =30000, isTalent =0},
      -- @Magma Totem Rank 4
      {id =10587, requiredIds ={10586}, rank =4, baseId =8190, cost =30000, isTalent =0},
      -- @Chain Lightning Rank 4
      {id =10605, requiredIds ={2860}, rank =4, baseId =421, cost =30000, isTalent =0},
      -- @Grace of Air Totem Rank 2
      {id =10627, requiredIds ={8835}, rank =2, baseId =8835, cost =30000, isTalent =0},
      -- @Windwall Totem Rank 3
      {id =15112, requiredIds ={15111}, rank =3, baseId =15107, cost =30000, isTalent =0},
      -- @Lightning Bolt Rank 10
      {id =15208, requiredIds ={15207}, rank =10, baseId =403, cost =30000, isTalent =0},
      -- @Flametongue Weapon Rank 6
      {id =16342, requiredIds ={16341}, rank =6, baseId =8024, cost =30000, isTalent =0},
       },
[58] = {
      -- @Stoneclaw Totem Rank 6
      {id =10428, requiredIds ={10427}, rank =6, baseId =5730, cost =32000, isTalent =0},
      -- @Frost Shock Rank 4
      {id =10473, requiredIds ={10472}, rank =4, baseId =8056, cost =32000, isTalent =0},
      -- @Fire Resistance Totem Rank 3
      {id =10538, requiredIds ={10537}, rank =3, baseId =8184, cost =32000, isTalent =0},
      -- @Frostbrand Weapon Rank 5
      {id =16356, requiredIds ={16355}, rank =5, baseId =8033, cost =32000, isTalent =0},
      -- @Flametongue Totem Rank 4
      {id =16387, requiredIds ={10526}, rank =4, baseId =8227, cost =32000, isTalent =0},
      -- @Mana Tide Totem Rank 3
      {id =17359, requiredIds ={17354}, rank =3, baseId =16190, cost =1600, isTalent =1},
       },
[60] = {
      -- @Earth Shock Rank 7
      {id =10414, requiredIds ={10413}, rank =7, baseId =8042, cost =34000, isTalent =0},
      -- @Searing Totem Rank 6
      {id =10438, requiredIds ={10437}, rank =6, baseId =3599, cost =34000, isTalent =0},
      -- @Healing Stream Totem Rank 5
      {id =10463, requiredIds ={10462}, rank =5, baseId =5394, cost =34000, isTalent =0},
      -- @Lesser Healing Wave Rank 6
      {id =10468, requiredIds ={10467}, rank =6, baseId =8004, cost =34000, isTalent =0},
      -- @Nature Resistance Totem Rank 3
      {id =10601, requiredIds ={10600}, rank =3, baseId =10595, cost =34000, isTalent =0},
      -- @Windfury Weapon Rank 4
      {id =16362, requiredIds ={10486}, rank =4, baseId =8232, cost =34000, isTalent =0},
      -- @Ancestral Spirit Rank 5
      {id =20777, requiredIds ={20776}, rank =5, baseId =2008, cost =34000, isTalent =0},
      -- @Healing Wave Rank 10
      {id =25357, requiredIds ={10396}, rank =10, baseId =331, isTalent =0},
      -- @Grace of Air Totem Rank 3
      {id =25359, requiredIds ={10627}, rank =3, baseId =8835, isTalent =0},
      -- @Strength of Earth Totem Rank 5
      {id =25361, requiredIds ={10442}, rank =5, baseId =8075, isTalent =0},
      -- @Flame Shock Rank 6
      {id =29228, requiredIds ={10448}, rank =6, baseId =8050, isTalent =0}
        }
}
