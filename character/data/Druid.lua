local _, GW = ...
if (GW.myclass ~= "DRUID") then
    return
end

local faerieFireFeral = {16857 --[[Rank 1]], 17390 --[[Rank 2]], 17391 --[[Rank 3]], 17392 --[[Rank 4]]}
local ravage = {6785 --[[Rank 1]], 6787 --[[Rank 2]], 9866 --[[Rank 3]], 9867 --[[Rank 4]]}
local maul = {
    6807 --[[Rank 1]],
    6808 --[[Rank 2]],
    6809 --[[Rank 3]],
    8972 --[[Rank 4]],
    9745 --[[Rank 5]],
    9880 --[[Rank 6]],
    9881 --[[Rank 7]]
}
local demoralizingRoar = {99 --[[Rank 1]], 1735 --[[Rank 2]], 9490 --[[Rank 3]], 9747 --[[Rank 4]], 9898 --[[Rank 5]]}
local cower = {8998, 9000, 9892}
local swipe = {779 --[[Rank 1]], 780 --[[Rank 2]], 769 --[[Rank 3]], 9754 --[[Rank 4]], 9908 --[[Rank 5]]}
local shred = {5221 --[[Rank 1]], 6800 --[[Rank 2]], 8992 --[[Rank 3]], 9829 --[[Rank 4]], 9830 --[[Rank 5]]}
local rake = {1822 --[[Rank 1]], 1823 --[[Rank 2]], 1824 --[[Rank 3]], 9904 --[[Rank 4]]}
local pounce = {9005 --[[Rank 1]], 9823 --[[Rank 2]], 9827 --[[Rank 3]]}
local frenziedRegeneration = {22842 --[[Rank 1]], 22895 --[[Rank 2]], 22896 --[[Rank 3]]}
local freociousBite = {
    22568 --[[Rank 1]],
    22827 --[[Rank 2]],
    22828 --[[Rank 3]],
    22829 --[[Rank 4]],
    31018 --[[Rank 5]]
}
local claw = {1082 --[[Rank 1]], 3029 --[[Rank 2]], 5201 --[[Rank 3]], 9849 --[[Rank 4]], 9850}
local tigersFury = {5217 --[[Rank 1]], 6793 --[[Rank 2]], 9845 --[[Rank 3]], 9846 --[[Rank 4]]}
local prowl = {5215, 6783, 9913}
local rip = {1079 --[[Rank 1]], 9492 --[[Rank 2]], 9493 --[[Rank 3]], 9752 --[[Rank 4]], 9894 --[[Rank 5]], 9896}
local bash = {5211, 6798, 8983}
local dash = {1850, 9821}


GW:SetPreviousAbilityMap(
    {
        faerieFireFeral,
        ravage,
        maul,
        demoralizingRoar,
        cower,
        swipe,
        shred,
        rake,
        pounce,
        frenziedRegeneration,
        freociousBite,
        claw,
        tigersFury,
        prowl,
        rip,
        bash,
        dash
    }
)

GW.SpellsByLevel = {
 [0] = {
      -- @One-Handed Maces undefined
      {id =198, isTalent =0, isSkill =1},
      -- @Two-Handed Maces undefined
      {id =199, isTalent =0, isSkill =1},
      -- @Staves undefined
      {id =227, isTalent =0, isSkill =1},
      -- @Daggers undefined
      {id =1180, isTalent =0, isSkill =1},
      -- @Insect Swarm Rank 1
      {id =5570, rank =1, isTalent =1},
      -- @Leather undefined
      {id =9077, isTalent =0, isSkill =1},
      -- @Fist Weapons undefined
      {id =15590, isTalent =0, isSkill =1},
      -- @Nature's Grasp Rank 1
      {id =16689, rank =1, isTalent =1},
      -- @Improved Wrath Rank 1
      {id =16814, rank =1, isTalent =1},
      -- @Improved Wrath Rank 2
      {id =16815, requiredIds ={16814}, rank =2, baseId =16814, isTalent =1},
      -- @Improved Wrath Rank 3
      {id =16816, requiredIds ={16815}, rank =3, baseId =16814, isTalent =1},
      -- @Improved Wrath Rank 4
      {id =16817, requiredIds ={16816}, rank =4, baseId =16814, isTalent =1},
      -- @Improved Wrath Rank 5
      {id =16818, requiredIds ={16817}, rank =5, baseId =16814, isTalent =1},
      -- @Nature's Reach Rank 1
      {id =16819, rank =1, isTalent =1},
      -- @Nature's Reach Rank 2
      {id =16820, requiredIds ={16819}, rank =2, baseId =16819, isTalent =1},
      -- @Improved Moonfire Rank 1
      {id =16821, rank =1, isTalent =1},
      -- @Improved Moonfire Rank 2
      {id =16822, requiredIds ={16821}, rank =2, baseId =16821, isTalent =1},
      -- @Improved Moonfire Rank 3
      {id =16823, requiredIds ={16822}, rank =3, baseId =16821, isTalent =1},
      -- @Improved Moonfire Rank 4
      {id =16824, requiredIds ={16823}, rank =4, baseId =16821, isTalent =1},
      -- @Improved Moonfire Rank 5
      {id =16825, requiredIds ={16824}, rank =5, baseId =16821, isTalent =1},
      -- @Natural Shapeshifter Rank 1
      {id =16833, rank =1, isTalent =1},
      -- @Natural Shapeshifter Rank 2
      {id =16834, requiredIds ={16833}, rank =2, baseId =16833, isTalent =1},
      -- @Natural Shapeshifter Rank 3
      {id =16835, requiredIds ={16834}, rank =3, baseId =16833, isTalent =1},
      -- @Improved Thorns Rank 1
      {id =16836, rank =1, isTalent =1},
      -- @Improved Thorns Rank 2
      {id =16839, requiredIds ={16836}, rank =2, baseId =16836, isTalent =1},
      -- @Improved Thorns Rank 3
      {id =16840, requiredIds ={16839}, rank =3, baseId =16836, isTalent =1},
      -- @Moonglow Rank 1
      {id =16845, rank =1, isTalent =1},
      -- @Moonglow Rank 2
      {id =16846, requiredIds ={16845}, rank =2, baseId =16845, isTalent =1},
      -- @Moonglow Rank 3
      {id =16847, requiredIds ={16846}, rank =3, baseId =16845, isTalent =1},
      -- @Improved Starfire Rank 1
      {id =16850, rank =1, isTalent =1},
      -- @Faerie Fire (Feral) Rank 1
      {id =16857, rank =1, isTalent =1},
      -- @Feral Aggression Rank 1
      {id =16858, rank =1, isTalent =1},
      -- @Feral Aggression Rank 2
      {id =16859, requiredIds ={16858}, rank =2, baseId =16858, isTalent =1},
      -- @Feral Aggression Rank 3
      {id =16860, requiredIds ={16859}, rank =3, baseId =16858, isTalent =1},
      -- @Feral Aggression Rank 4
      {id =16861, requiredIds ={16860}, rank =4, baseId =16858, isTalent =1},
      -- @Feral Aggression Rank 5
      {id =16862, requiredIds ={16861}, rank =5, baseId =16858, isTalent =1},
      -- @Omen of Clarity undefined
      {id =16864, isTalent =1},
      -- @Nature's Grace undefined
      {id =16880, isTalent =1},
      -- @Moonfury Rank 1
      {id =16896, rank =1, isTalent =1},
      -- @Moonfury Rank 2
      {id =16897, requiredIds ={16896}, rank =2, baseId =16896, isTalent =1},
      -- @Moonfury Rank 3
      {id =16899, requiredIds ={16897}, rank =3, baseId =16896, isTalent =1},
      -- @Moonfury Rank 4
      {id =16900, requiredIds ={16899}, rank =4, baseId =16896, isTalent =1},
      -- @Moonfury Rank 5
      {id =16901, requiredIds ={16900}, rank =5, baseId =16896, isTalent =1},
      -- @Natural Weapons Rank 1
      {id =16902, rank =1, isTalent =1},
      -- @Natural Weapons Rank 2
      {id =16903, requiredIds ={16902}, rank =2, baseId =16902, isTalent =1},
      -- @Natural Weapons Rank 3
      {id =16904, requiredIds ={16903}, rank =3, baseId =16902, isTalent =1},
      -- @Natural Weapons Rank 4
      {id =16905, requiredIds ={16904}, rank =4, baseId =16902, isTalent =1},
      -- @Natural Weapons Rank 5
      {id =16906, requiredIds ={16905}, rank =5, baseId =16902, isTalent =1},
      -- @Vengeance Rank 1
      {id =16909, rank =1, isTalent =1},
      -- @Vengeance Rank 2
      {id =16910, requiredIds ={16909}, rank =2, baseId =16909, isTalent =1},
      -- @Vengeance Rank 3
      {id =16911, requiredIds ={16910}, rank =3, baseId =16909, isTalent =1},
      -- @Vengeance Rank 4
      {id =16912, requiredIds ={16911}, rank =4, baseId =16909, isTalent =1},
      -- @Vengeance Rank 5
      {id =16913, requiredIds ={16912}, rank =5, baseId =16909, isTalent =1},
      -- @Improved Entangling Roots Rank 1
      {id =16918, rank =1, isTalent =1},
      -- @Improved Entangling Roots Rank 2
      {id =16919, requiredIds ={16918}, rank =2, baseId =16918, isTalent =1},
      -- @Improved Entangling Roots Rank 3
      {id =16920, requiredIds ={16919}, rank =3, baseId =16918, isTalent =1},
      -- @Improved Starfire Rank 2
      {id =16923, requiredIds ={16850}, rank =2, baseId =16850, isTalent =1},
      -- @Improved Starfire Rank 3
      {id =16924, requiredIds ={16923}, rank =3, baseId =16850, isTalent =1},
      -- @Improved Starfire Rank 4
      {id =16925, requiredIds ={16924}, rank =4, baseId =16850, isTalent =1},
      -- @Improved Starfire Rank 5
      {id =16926, requiredIds ={16925}, rank =5, baseId =16850, isTalent =1},
      -- @Thick Hide Rank 1
      {id =16929, rank =1, isTalent =1},
      -- @Thick Hide Rank 2
      {id =16930, requiredIds ={16929}, rank =2, baseId =16929, isTalent =1},
      -- @Thick Hide Rank 3
      {id =16931, requiredIds ={16930}, rank =3, baseId =16929, isTalent =1},
      -- @Thick Hide Rank 4
      {id =16932, requiredIds ={16931}, rank =4, baseId =16929, isTalent =1},
      -- @Thick Hide Rank 5
      {id =16933, requiredIds ={16932}, rank =5, baseId =16929, isTalent =1},
      -- @Ferocity Rank 1
      {id =16934, rank =1, isTalent =1},
      -- @Ferocity Rank 2
      {id =16935, requiredIds ={16934}, rank =2, baseId =16934, isTalent =1},
      -- @Ferocity Rank 3
      {id =16936, requiredIds ={16935}, rank =3, baseId =16934, isTalent =1},
      -- @Ferocity Rank 4
      {id =16937, requiredIds ={16936}, rank =4, baseId =16934, isTalent =1},
      -- @Ferocity Rank 5
      {id =16938, requiredIds ={16937}, rank =5, baseId =16934, isTalent =1},
      -- @Brutal Impact Rank 1
      {id =16940, rank =1, isTalent =1},
      -- @Brutal Impact Rank 2
      {id =16941, requiredIds ={16940}, rank =2, baseId =16940, isTalent =1},
      -- @Sharpened Claws Rank 1
      {id =16942, rank =1, isTalent =1},
      -- @Sharpened Claws Rank 2
      {id =16943, requiredIds ={16942}, rank =2, baseId =16942, isTalent =1},
      -- @Sharpened Claws Rank 3
      {id =16944, requiredIds ={16943}, rank =3, baseId =16942, isTalent =1},
      -- @Feral Instinct Rank 1
      {id =16947, rank =1, isTalent =1},
      -- @Feral Instinct Rank 2
      {id =16948, requiredIds ={16947}, rank =2, baseId =16947, isTalent =1},
      -- @Feral Instinct Rank 3
      {id =16949, requiredIds ={16948}, rank =3, baseId =16947, isTalent =1},
      -- @Feral Instinct Rank 4
      {id =16950, requiredIds ={16949}, rank =4, baseId =16947, isTalent =1},
      -- @Feral Instinct Rank 5
      {id =16951, requiredIds ={16950}, rank =5, baseId =16947, isTalent =1},
      -- @Primal Fury Rank 2
      {id =16961, rank =2, isTalent =1},
      -- @Improved Shred Rank 1
      {id =16966, rank =1, isTalent =1},
      -- @Improved Shred Rank 2
      {id =16968, requiredIds ={16966}, rank =2, baseId =16966, isTalent =1},
      -- @Predatory Strikes Rank 1
      {id =16972, rank =1, isTalent =1},
      -- @Predatory Strikes Rank 2
      {id =16974, requiredIds ={16972}, rank =2, baseId =16972, isTalent =1},
      -- @Predatory Strikes Rank 3
      {id =16975, requiredIds ={16974}, rank =3, baseId =16972, isTalent =1},
      -- @Feral Charge undefined
      {id =16979, isTalent =1},
      -- @Savage Fury Rank 1
      {id =16998, rank =1, isTalent =1},
      -- @Savage Fury Rank 2
      {id =16999, requiredIds ={16998}, rank =2, baseId =16998, isTalent =1},
      -- @Feline Swiftness undefined
      {id =17002, isTalent =1},
      -- @Heart of the Wild Rank 1
      {id =17003, rank =1, isTalent =1},
      -- @Heart of the Wild Rank 2
      {id =17004, requiredIds ={17003}, rank =2, baseId =17003, isTalent =1},
      -- @Heart of the Wild Rank 3
      {id =17005, requiredIds ={17004}, rank =3, baseId =17003, isTalent =1},
      -- @Heart of the Wild Rank 4
      {id =17006, requiredIds ={17005}, rank =4, baseId =17003, isTalent =1},
      -- @Leader of the Pack undefined
      {id =17007, isTalent =1},
      -- @Improved Mark of the Wild Rank 1
      {id =17050, rank =1, isTalent =1},
      -- @Improved Mark of the Wild Rank 2
      {id =17051, requiredIds ={17050}, rank =2, baseId =17050, isTalent =1},
      -- @Improved Mark of the Wild Rank 3
      {id =17053, requiredIds ={17051}, rank =3, baseId =17050, isTalent =1},
      -- @Improved Mark of the Wild Rank 4
      {id =17054, requiredIds ={17053}, rank =4, baseId =17050, isTalent =1},
      -- @Improved Mark of the Wild Rank 5
      {id =17055, requiredIds ={17054}, rank =5, baseId =17050, isTalent =1},
      -- @Furor Rank 1
      {id =17056, rank =1, isTalent =1},
      -- @Furor Rank 2
      {id =17058, requiredIds ={17056}, rank =2, baseId =17056, isTalent =1},
      -- @Furor Rank 3
      {id =17059, requiredIds ={17058}, rank =3, baseId =17056, isTalent =1},
      -- @Furor Rank 4
      {id =17060, requiredIds ={17059}, rank =4, baseId =17056, isTalent =1},
      -- @Furor Rank 5
      {id =17061, requiredIds ={17060}, rank =5, baseId =17056, isTalent =1},
      -- @Nature's Focus Rank 1
      {id =17063, rank =1, isTalent =1},
      -- @Nature's Focus Rank 2
      {id =17065, requiredIds ={17063}, rank =2, baseId =17063, isTalent =1},
      -- @Nature's Focus Rank 3
      {id =17066, requiredIds ={17065}, rank =3, baseId =17063, isTalent =1},
      -- @Nature's Focus Rank 4
      {id =17067, requiredIds ={17066}, rank =4, baseId =17063, isTalent =1},
      -- @Nature's Focus Rank 5
      {id =17068, requiredIds ={17067}, rank =5, baseId =17063, isTalent =1},
      -- @Improved Healing Touch Rank 1
      {id =17069, rank =1, isTalent =1},
      -- @Improved Healing Touch Rank 2
      {id =17070, requiredIds ={17069}, rank =2, baseId =17069, isTalent =1},
      -- @Improved Healing Touch Rank 3
      {id =17071, requiredIds ={17070}, rank =3, baseId =17069, isTalent =1},
      -- @Improved Healing Touch Rank 4
      {id =17072, requiredIds ={17071}, rank =4, baseId =17069, isTalent =1},
      -- @Improved Healing Touch Rank 5
      {id =17073, requiredIds ={17072}, rank =5, baseId =17069, isTalent =1},
      -- @Improved Regrowth Rank 1
      {id =17074, rank =1, isTalent =1},
      -- @Improved Regrowth Rank 2
      {id =17075, requiredIds ={17074}, rank =2, baseId =17074, isTalent =1},
      -- @Improved Regrowth Rank 3
      {id =17076, requiredIds ={17075}, rank =3, baseId =17074, isTalent =1},
      -- @Improved Regrowth Rank 4
      {id =17077, requiredIds ={17076}, rank =4, baseId =17074, isTalent =1},
      -- @Improved Regrowth Rank 5
      {id =17078, requiredIds ={17077}, rank =5, baseId =17074, isTalent =1},
      -- @Improved Enrage Rank 1
      {id =17079, rank =1, isTalent =1},
      -- @Improved Enrage Rank 2
      {id =17082, requiredIds ={17079}, rank =2, baseId =17079, isTalent =1},
      -- @Gift of Nature Rank 1
      {id =17104, rank =1, isTalent =1},
      -- @Reflection Rank 1
      {id =17106, rank =1, isTalent =1},
      -- @Reflection Rank 2
      {id =17107, requiredIds ={17106}, rank =2, baseId =17106, isTalent =1},
      -- @Reflection Rank 3
      {id =17108, requiredIds ={17107}, rank =3, baseId =17106, isTalent =1},
      -- @Improved Rejuvenation Rank 1
      {id =17111, rank =1, isTalent =1},
      -- @Improved Rejuvenation Rank 2
      {id =17112, requiredIds ={17111}, rank =2, baseId =17111, isTalent =1},
      -- @Improved Rejuvenation Rank 3
      {id =17113, requiredIds ={17112}, rank =3, baseId =17111, isTalent =1},
      -- @Nature's Swiftness undefined
      {id =17116, isTalent =1},
      -- @Subtlety Rank 1
      {id =17118, rank =1, isTalent =1},
      -- @Subtlety Rank 2
      {id =17119, requiredIds ={17118}, rank =2, baseId =17118, isTalent =1},
      -- @Subtlety Rank 3
      {id =17120, requiredIds ={17119}, rank =3, baseId =17118, isTalent =1},
      -- @Subtlety Rank 4
      {id =17121, requiredIds ={17120}, rank =4, baseId =17118, isTalent =1},
      -- @Subtlety Rank 5
      {id =17122, requiredIds ={17121}, rank =5, baseId =17118, isTalent =1},
      -- @Improved Tranquility Rank 1
      {id =17123, rank =1, isTalent =1},
      -- @Improved Tranquility Rank 2
      {id =17124, requiredIds ={17123}, rank =2, baseId =17123, isTalent =1},
      -- @Improved Nature's Grasp Rank 1
      {id =17245, rank =1, isTalent =1},
      -- @Improved Nature's Grasp Rank 2
      {id =17247, requiredIds ={17245}, rank =2, baseId =17245, isTalent =1},
      -- @Improved Nature's Grasp Rank 3
      {id =17248, requiredIds ={17247}, rank =3, baseId =17245, isTalent =1},
      -- @Improved Nature's Grasp Rank 4
      {id =17249, requiredIds ={17248}, rank =4, baseId =17245, isTalent =1},
      -- @Swiftmend undefined
      {id =18562, isTalent =1},
      -- @Moonkin Form Shapeshift
      {id =24858, isTalent =1},
      -- @Feline Swiftness undefined
      {id =24866, isTalent =1},
      -- @Heart of the Wild Rank 5
      {id =24894, requiredIds ={17006}, rank =5, baseId =17003, isTalent =1},
      -- @Gift of Nature Rank 2
      {id =24943, requiredIds ={17104}, rank =2, baseId =17104, isTalent =1},
      -- @Gift of Nature Rank 3
      {id =24944, requiredIds ={24943}, rank =3, baseId =17104, isTalent =1},
      -- @Gift of Nature Rank 4
      {id =24945, requiredIds ={24944}, rank =4, baseId =17104, isTalent =1},
      -- @Gift of Nature Rank 5
      {id =24946, requiredIds ={24945}, rank =5, baseId =17104, isTalent =1},
      -- @Tranquil Spirit Rank 1
      {id =24968, rank =1, isTalent =1},
      -- @Tranquil Spirit Rank 2
      {id =24969, requiredIds ={24968}, rank =2, baseId =24968, isTalent =1},
      -- @Tranquil Spirit Rank 3
      {id =24970, requiredIds ={24969}, rank =3, baseId =24968, isTalent =1},
      -- @Tranquil Spirit Rank 4
      {id =24971, requiredIds ={24970}, rank =4, baseId =24968, isTalent =1},
      -- @Tranquil Spirit Rank 5
      {id =24972, requiredIds ={24971}, rank =5, baseId =24968, isTalent =1},
      -- @Fetish undefined
      {id =27764, isTalent =0, isSkill =1},
       },
[1] = {
      -- @Mark of the Wild Rank 1
      {id =1126, rank =1, cost =10, isTalent =0},
      -- @Wrath Rank 1
      {id =5176, rank =1, isTalent =0},
      -- @Healing Touch Rank 1
      {id =5185, rank =1, isTalent =0},
       },
[4] = {
      -- @Rejuvenation Rank 1
      {id =774, rank =1, cost =100, isTalent =0},
      -- @Moonfire Rank 1
      {id =8921, rank =1, cost =100, isTalent =0},
       },
[6] = {
      -- @Thorns Rank 1
      {id =467, rank =1, cost =100, isTalent =0},
      -- @Wrath Rank 2
      {id =5177, requiredIds ={5176}, rank =2, baseId =5176, cost =100, isTalent =0},
       },
[8] = {
      -- @Entangling Roots Rank 1
      {id =339, rank =1, cost =200, isTalent =0},
      -- @Healing Touch Rank 2
      {id =5186, requiredIds ={5185}, rank =2, baseId =5185, cost =200, isTalent =0},
       },
[10] = {
      -- @Demoralizing Roar Rank 1
      {id =99, rank =1, cost =300, isTalent =0},
      -- @Rejuvenation Rank 2
      {id =1058, requiredIds ={774}, rank =2, baseId =774, cost =300, isTalent =0},
      -- @Mark of the Wild Rank 2
      {id =5232, requiredIds ={1126}, rank =2, baseId =1126, cost =300, isTalent =0},
      -- @Bear Form Shapeshift
      {id =5487, isTalent =0},
      -- @Growl undefined
      {id =6795, isTalent =0},
      -- @Maul Rank 1
      {id =6807, rank =1, isTalent =0},
      -- @Moonfire Rank 2
      {id =8924, requiredIds ={8921}, rank =2, baseId =8921, cost =300, isTalent =0},
      -- @Teleport: Moonglade undefined
      {id =18960, isTalent =0},
       },
[12] = {
      -- @Enrage undefined
      {id =5229, cost =800, isTalent =0},
      -- @Regrowth Rank 1
      {id =8936, rank =1, cost =800, isTalent =0},
       },
[14] = {
      -- @Thorns Rank 2
      {id =782, requiredIds ={467}, rank =2, baseId =467, cost =900, isTalent =0},
      -- @Wrath Rank 3
      {id =5178, requiredIds ={5177}, rank =3, baseId =5176, cost =900, isTalent =0},
      -- @Healing Touch Rank 3
      {id =5187, requiredIds ={5186}, rank =3, baseId =5185, cost =900, isTalent =0},
      -- @Bash Rank 1
      {id =5211, rank =1, cost =900, isTalent =0},
      -- @Cure Poison undefined
      {id =8946, isTalent =0},
       },
[16] = {
      -- @Swipe Rank 1
      {id =779, rank =1, cost =1800, isTalent =0},
      -- @Aquatic Form Shapeshift
      {id =1066, isTalent =0},
      -- @Rejuvenation Rank 3
      {id =1430, requiredIds ={1058}, rank =3, baseId =774, cost =1800, isTalent =0},
      -- @Moonfire Rank 3
      {id =8925, requiredIds ={8924}, rank =3, baseId =8921, cost =1800, isTalent =0},
       },
[18] = {
      -- @Faerie Fire Rank 1
      {id =770, rank =1, cost =1900, isTalent =0},
      -- @Entangling Roots Rank 2
      {id =1062, requiredIds ={339}, rank =2, baseId =339, cost =1900, isTalent =0},
      -- @Hibernate Rank 1
      {id =2637, rank =1, cost =1900, isTalent =0},
      -- @Maul Rank 2
      {id =6808, requiredIds ={6807}, rank =2, baseId =6807, cost =1900, isTalent =0},
      -- @Regrowth Rank 2
      {id =8938, requiredIds ={8936}, rank =2, baseId =8936, cost =1900, isTalent =0},
      -- @Nature's Grasp Rank 2
      {id =16810, requiredIds ={16689}, rank =2, baseId =16689, cost =95, isTalent =1},
       },
[20] = {
      -- @Cat Form Shapeshift
      {id =768, cost =2000, isTalent =0},
      -- @Rip Rank 1
      {id =1079, rank =1, cost =2000, isTalent =0},
      -- @Claw Rank 1
      {id =1082, rank =1, cost =2000, isTalent =0},
      -- @Demoralizing Roar Rank 2
      {id =1735, requiredIds ={99}, rank =2, baseId =99, cost =2000, isTalent =0},
      -- @Starfire Rank 1
      {id =2912, rank =1, cost =2000, isTalent =0},
      -- @Healing Touch Rank 4
      {id =5188, requiredIds ={5187}, rank =4, baseId =5185, cost =2000, isTalent =0},
      -- @Prowl Rank 1
      {id =5215, rank =1, cost =2000, isTalent =0},
      -- @Mark of the Wild Rank 3
      {id =6756, requiredIds ={5232}, rank =3, baseId =1126, cost =2000, isTalent =0},
      -- @Rebirth Rank 1
      {id =20484, rank =1, cost =2000, isTalent =0},
       },
[22] = {
      -- @Rejuvenation Rank 4
      {id =2090, requiredIds ={1430}, rank =4, baseId =774, cost =3000, isTalent =0},
      -- @Soothe Animal Rank 1
      {id =2908, rank =1, cost =3000, isTalent =0},
      -- @Wrath Rank 4
      {id =5179, requiredIds ={5178}, rank =4, baseId =5176, cost =3000, isTalent =0},
      -- @Shred Rank 1
      {id =5221, rank =1, cost =3000, isTalent =0},
      -- @Moonfire Rank 4
      {id =8926, requiredIds ={8925}, rank =4, baseId =8921, cost =3000, isTalent =0},
       },
[24] = {
      -- @Swipe Rank 2
      {id =780, requiredIds ={779}, rank =2, baseId =779, cost =4000, isTalent =0},
      -- @Thorns Rank 3
      {id =1075, requiredIds ={782}, rank =3, baseId =467, cost =4000, isTalent =0},
      -- @Rake Rank 1
      {id =1822, rank =1, cost =4000, isTalent =0},
      -- @Remove Curse undefined
      {id =2782, cost =4000, isTalent =0},
      -- @Tiger's Fury Rank 1
      {id =5217, rank =1, cost =4000, isTalent =0},
      -- @Regrowth Rank 3
      {id =8939, requiredIds ={8938}, rank =3, baseId =8936, cost =4000, isTalent =0},
       },
[26] = {
      -- @Dash Rank 1
      {id =1850, rank =1, cost =4500, isTalent =0},
      -- @Abolish Poison undefined
      {id =2893, cost =4500, isTalent =0},
      -- @Healing Touch Rank 5
      {id =5189, requiredIds ={5188}, rank =5, baseId =5185, cost =4500, isTalent =0},
      -- @Maul Rank 3
      {id =6809, requiredIds ={6808}, rank =3, baseId =6807, cost =4500, isTalent =0},
      -- @Starfire Rank 2
      {id =8949, requiredIds ={2912}, rank =2, baseId =2912, cost =4500, isTalent =0},
       },
[28] = {
      -- @Rejuvenation Rank 5
      {id =2091, requiredIds ={2090}, rank =5, baseId =774, cost =5000, isTalent =0},
      -- @Claw Rank 2
      {id =3029, requiredIds ={1082}, rank =2, baseId =1082, cost =5000, isTalent =0},
      -- @Entangling Roots Rank 3
      {id =5195, requiredIds ={1062}, rank =3, baseId =339, cost =5000, isTalent =0},
      -- @Challenging Roar undefined
      {id =5209, cost =5000, isTalent =0},
      -- @Moonfire Rank 5
      {id =8927, requiredIds ={8926}, rank =5, baseId =8921, cost =5000, isTalent =0},
      -- @Cower Rank 1
      {id =8998, rank =1, cost =5000, isTalent =0},
      -- @Rip Rank 2
      {id =9492, requiredIds ={1079}, rank =2, baseId =1079, cost =5000, isTalent =0},
      -- @Nature's Grasp Rank 3
      {id =16811, requiredIds ={16810}, rank =3, baseId =16689, cost =250, isTalent =1},
       },
[30] = {
      -- @Tranquility Rank 1
      {id =740, rank =1, cost =6000, isTalent =0},
      -- @Faerie Fire Rank 2
      {id =778, requiredIds ={770}, rank =2, baseId =770, cost =6000, isTalent =0},
      -- @Travel Form Shapeshift
      {id =783, cost =6000, isTalent =0},
      -- @Wrath Rank 5
      {id =5180, requiredIds ={5179}, rank =5, baseId =5176, cost =6000, isTalent =0},
      -- @Mark of the Wild Rank 4
      {id =5234, requiredIds ={6756}, rank =4, baseId =1126, cost =6000, isTalent =0},
      -- @Bash Rank 2
      {id =6798, requiredIds ={5211}, rank =2, baseId =5211, cost =6000, isTalent =0},
      -- @Shred Rank 2
      {id =6800, requiredIds ={5221}, rank =2, baseId =5221, cost =6000, isTalent =0},
      -- @Regrowth Rank 4
      {id =8940, requiredIds ={8939}, rank =4, baseId =8936, cost =6000, isTalent =0},
      -- @Faerie Fire (Feral) Rank 2
      {id =17390, requiredIds ={16857}, rank =2, baseId =16857, cost =300, isTalent =1},
      -- @Rebirth Rank 2
      {id =20739, requiredIds ={20484}, rank =2, baseId =20484, cost =6000, isTalent =0},
      -- @Insect Swarm Rank 2
      {id =24974, requiredIds ={5570}, rank =2, baseId =5570, cost =300, isTalent =1},
       },
[32] = {
      -- @Track Humanoids undefined
      {id =5225, cost =8000, isTalent =0},
      -- @Healing Touch Rank 6
      {id =6778, requiredIds ={5189}, rank =6, baseId =5185, cost =8000, isTalent =0},
      -- @Ravage Rank 1
      {id =6785, rank =1, cost =8000, isTalent =0},
      -- @Demoralizing Roar Rank 3
      {id =9490, requiredIds ={1735}, rank =3, baseId =99, cost =8000, isTalent =0},
      -- @Ferocious Bite Rank 1
      {id =22568, rank =1, cost =8000, isTalent =0},
       },
[34] = {
      -- @Swipe Rank 3
      {id =769, requiredIds ={780}, rank =3, baseId =779, cost =10000, isTalent =0},
      -- @Rake Rank 2
      {id =1823, requiredIds ={1822}, rank =2, baseId =1822, cost =10000, isTalent =0},
      -- @Rejuvenation Rank 6
      {id =3627, requiredIds ={2091}, rank =6, baseId =774, cost =10000, isTalent =0},
      -- @Thorns Rank 4
      {id =8914, requiredIds ={1075}, rank =4, baseId =467, cost =10000, isTalent =0},
      -- @Moonfire Rank 6
      {id =8928, requiredIds ={8927}, rank =6, baseId =8921, cost =10000, isTalent =0},
      -- @Starfire Rank 3
      {id =8950, requiredIds ={8949}, rank =3, baseId =2912, cost =10000, isTalent =0},
      -- @Maul Rank 4
      {id =8972, requiredIds ={6809}, rank =4, baseId =6807, cost =10000, isTalent =0},
       },
[36] = {
      -- @Tiger's Fury Rank 2
      {id =6793, requiredIds ={5217}, rank =2, baseId =5217, cost =11000, isTalent =0},
      -- @Regrowth Rank 5
      {id =8941, requiredIds ={8940}, rank =5, baseId =8936, cost =11000, isTalent =0},
      -- @Pounce Rank 1
      {id =9005, rank =1, cost =11000, isTalent =0},
      -- @Rip Rank 3
      {id =9493, requiredIds ={9492}, rank =3, baseId =1079, cost =11000, isTalent =0},
      -- @Frenzied Regeneration Rank 1
      {id =22842, rank =1, cost =11000, isTalent =0},
       },
[38] = {
      -- @Entangling Roots Rank 4
      {id =5196, requiredIds ={5195}, rank =4, baseId =339, cost =12000, isTalent =0},
      -- @Claw Rank 3
      {id =5201, requiredIds ={3029}, rank =3, baseId =1082, cost =12000, isTalent =0},
      -- @Wrath Rank 6
      {id =6780, requiredIds ={5180}, rank =6, baseId =5176, cost =12000, isTalent =0},
      -- @Healing Touch Rank 7
      {id =8903, requiredIds ={6778}, rank =7, baseId =5185, cost =12000, isTalent =0},
      -- @Soothe Animal Rank 2
      {id =8955, requiredIds ={2908}, rank =2, baseId =2908, cost =12000, isTalent =0},
      -- @Shred Rank 3
      {id =8992, requiredIds ={6800}, rank =3, baseId =5221, cost =12000, isTalent =0},
      -- @Nature's Grasp Rank 4
      {id =16812, requiredIds ={16811}, rank =4, baseId =16689, cost =600, isTalent =1},
      -- @Hibernate Rank 2
      {id =18657, requiredIds ={2637}, rank =2, baseId =2637, cost =12000, isTalent =0},
       },
[40] = {
      -- @Prowl Rank 2
      {id =6783, requiredIds ={5215}, rank =2, baseId =5215, cost =14000, isTalent =0},
      -- @Mark of the Wild Rank 5
      {id =8907, requiredIds ={5234}, rank =5, baseId =1126, cost =14000, isTalent =0},
      -- @Rejuvenation Rank 7
      {id =8910, requiredIds ={3627}, rank =7, baseId =774, cost =14000, isTalent =0},
      -- @Tranquility Rank 2
      {id =8918, requiredIds ={740}, rank =2, baseId =740, cost =14000, isTalent =0},
      -- @Moonfire Rank 7
      {id =8929, requiredIds ={8928}, rank =7, baseId =8921, cost =14000, isTalent =0},
      -- @Cower Rank 2
      {id =9000, requiredIds ={8998}, rank =2, baseId =8998, cost =14000, isTalent =0},
      -- @Dire Bear Form Shapeshift
      {id =9634, cost =14000, isTalent =0},
      -- @Hurricane Rank 1
      {id =16914, rank =1, cost =14000, isTalent =0},
      -- @Feline Grace Passive
      {id =20719, cost =14000, isTalent =0},
      -- @Rebirth Rank 3
      {id =20742, requiredIds ={20739}, rank =3, baseId =20484, cost =14000, isTalent =0},
      -- @Ferocious Bite Rank 2
      {id =22827, requiredIds ={22568}, rank =2, baseId =22568, cost =14000, isTalent =0},
      -- @Insect Swarm Rank 3
      {id =24975, requiredIds ={24974}, rank =3, baseId =5570, cost =700, isTalent =1},
      -- @Innervate undefined
      {id =29166, cost =14000, isTalent =0},
       },
[42] = {
      -- @Ravage Rank 2
      {id =6787, requiredIds ={6785}, rank =2, baseId =6785, cost =16000, isTalent =0},
      -- @Starfire Rank 4
      {id =8951, requiredIds ={8950}, rank =4, baseId =2912, cost =16000, isTalent =0},
      -- @Maul Rank 5
      {id =9745, requiredIds ={8972}, rank =5, baseId =6807, cost =16000, isTalent =0},
      -- @Demoralizing Roar Rank 4
      {id =9747, requiredIds ={9490}, rank =4, baseId =99, cost =16000, isTalent =0},
      -- @Faerie Fire Rank 3
      {id =9749, requiredIds ={778}, rank =3, baseId =770, cost =16000, isTalent =0},
      -- @Regrowth Rank 6
      {id =9750, requiredIds ={8941}, rank =6, baseId =8936, cost =16000, isTalent =0},
      -- @Faerie Fire (Feral) Rank 3
      {id =17391, requiredIds ={17390}, rank =3, baseId =16857, cost =800, isTalent =1},
       },
[44] = {
      -- @Rake Rank 3
      {id =1824, requiredIds ={1823}, rank =3, baseId =1822, cost =18000, isTalent =0},
      -- @Rip Rank 4
      {id =9752, requiredIds ={9493}, rank =4, baseId =1079, cost =18000, isTalent =0},
      -- @Swipe Rank 4
      {id =9754, requiredIds ={769}, rank =4, baseId =779, cost =18000, isTalent =0},
      -- @Thorns Rank 5
      {id =9756, requiredIds ={8914}, rank =5, baseId =467, cost =18000, isTalent =0},
      -- @Healing Touch Rank 8
      {id =9758, requiredIds ={8903}, rank =8, baseId =5185, cost =18000, isTalent =0},
      -- @Barkskin undefined
      {id =22812, cost =18000, isTalent =0},
      -- @Barkskin Effect (DND) undefined
      {id =22839, isTalent =0},
       },
[46] = {
      -- @Wrath Rank 7
      {id =8905, requiredIds ={6780}, rank =7, baseId =5176, cost =20000, isTalent =0},
      -- @Bash Rank 3
      {id =8983, requiredIds ={6798}, rank =3, baseId =5211, cost =20000, isTalent =0},
      -- @Dash Rank 2
      {id =9821, requiredIds ={1850}, rank =2, baseId =1850, cost =20000, isTalent =0},
      -- @Pounce Rank 2
      {id =9823, requiredIds ={9005}, rank =2, baseId =9005, cost =20000, isTalent =0},
      -- @Shred Rank 4
      {id =9829, requiredIds ={8992}, rank =4, baseId =5221, cost =20000, isTalent =0},
      -- @Moonfire Rank 8
      {id =9833, requiredIds ={8929}, rank =8, baseId =8921, cost =20000, isTalent =0},
      -- @Rejuvenation Rank 8
      {id =9839, requiredIds ={8910}, rank =8, baseId =774, cost =20000, isTalent =0},
      -- @Frenzied Regeneration Rank 2
      {id =22895, requiredIds ={22842}, rank =2, baseId =22842, cost =20000, isTalent =0},
       },
[48] = {
      -- @Tiger's Fury Rank 3
      {id =9845, requiredIds ={6793}, rank =3, baseId =5217, cost =22000, isTalent =0},
      -- @Claw Rank 4
      {id =9849, requiredIds ={5201}, rank =4, baseId =1082, cost =22000, isTalent =0},
      -- @Entangling Roots Rank 5
      {id =9852, requiredIds ={5196}, rank =5, baseId =339, cost =22000, isTalent =0},
      -- @Regrowth Rank 7
      {id =9856, requiredIds ={9750}, rank =7, baseId =8936, cost =22000, isTalent =0},
      -- @Nature's Grasp Rank 5
      {id =16813, requiredIds ={16812}, rank =5, baseId =16689, cost =1100, isTalent =1},
      -- @Ferocious Bite Rank 3
      {id =22828, requiredIds ={22827}, rank =3, baseId =22568, cost =22000, isTalent =0},
       },
[50] = {
      -- @Tranquility Rank 3
      {id =9862, requiredIds ={8918}, rank =3, baseId =740, cost =23000, isTalent =0},
      -- @Ravage Rank 3
      {id =9866, requiredIds ={6787}, rank =3, baseId =6785, cost =23000, isTalent =0},
      -- @Starfire Rank 5
      {id =9875, requiredIds ={8951}, rank =5, baseId =2912, cost =23000, isTalent =0},
      -- @Maul Rank 6
      {id =9880, requiredIds ={9745}, rank =6, baseId =6807, cost =23000, isTalent =0},
      -- @Mark of the Wild Rank 6
      {id =9884, requiredIds ={8907}, rank =6, baseId =1126, cost =23000, isTalent =0},
      -- @Healing Touch Rank 9
      {id =9888, requiredIds ={9758}, rank =9, baseId =5185, cost =23000, isTalent =0},
      -- @Hurricane Rank 2
      {id =17401, requiredIds ={16914}, rank =2, baseId =16914, cost =23000, isTalent =0},
      -- @Rebirth Rank 4
      {id =20747, requiredIds ={20742}, rank =4, baseId =20484, cost =23000, isTalent =0},
      -- @Gift of the Wild Rank 1
      {id =21849, rank =1, isTalent =0},
      -- @Insect Swarm Rank 4
      {id =24976, requiredIds ={24975}, rank =4, baseId =5570, cost =1150, isTalent =1},
       },
[52] = {
      -- @Moonfire Rank 9
      {id =9834, requiredIds ={9833}, rank =9, baseId =8921, cost =26000, isTalent =0},
      -- @Rejuvenation Rank 9
      {id =9840, requiredIds ={9839}, rank =9, baseId =774, cost =26000, isTalent =0},
      -- @Cower Rank 3
      {id =9892, requiredIds ={9000}, rank =3, baseId =8998, cost =26000, isTalent =0},
      -- @Rip Rank 5
      {id =9894, requiredIds ={9752}, rank =5, baseId =1079, cost =26000, isTalent =0},
      -- @Demoralizing Roar Rank 5
      {id =9898, requiredIds ={9747}, rank =5, baseId =99, cost =26000, isTalent =0},
       },
[54] = {
      -- @Shred Rank 5
      {id =9830, requiredIds ={9829}, rank =5, baseId =5221, cost =28000, isTalent =0},
      -- @Regrowth Rank 8
      {id =9857, requiredIds ={9856}, rank =8, baseId =8936, cost =28000, isTalent =0},
      -- @Soothe Animal Rank 3
      {id =9901, requiredIds ={8955}, rank =3, baseId =2908, cost =28000, isTalent =0},
      -- @Rake Rank 4
      {id =9904, requiredIds ={1824}, rank =4, baseId =1822, cost =28000, isTalent =0},
      -- @Faerie Fire Rank 4
      {id =9907, requiredIds ={9749}, rank =4, baseId =770, cost =28000, isTalent =0},
      -- @Swipe Rank 5
      {id =9908, requiredIds ={9754}, rank =5, baseId =779, cost =28000, isTalent =0},
      -- @Thorns Rank 6
      {id =9910, requiredIds ={9756}, rank =6, baseId =467, cost =28000, isTalent =0},
      -- @Wrath Rank 8
      {id =9912, requiredIds ={8905}, rank =8, baseId =5176, cost =28000, isTalent =0},
      -- @Faerie Fire (Feral) Rank 4
      {id =17392, requiredIds ={17391}, rank =4, baseId =16857, cost =1400, isTalent =1},
       },
[56] = {
      -- @Pounce Rank 3
      {id =9827, requiredIds ={9823}, rank =3, baseId =9005, cost =30000, isTalent =0},
      -- @Healing Touch Rank 10
      {id =9889, requiredIds ={9888}, rank =10, baseId =5185, cost =30000, isTalent =0},
      -- @Ferocious Bite Rank 4
      {id =22829, requiredIds ={22828}, rank =4, baseId =22568, cost =30000, isTalent =0},
      -- @Frenzied Regeneration Rank 3
      {id =22896, requiredIds ={22895}, rank =3, baseId =22842, cost =30000, isTalent =0},
       },
[58] = {
      -- @Moonfire Rank 10
      {id =9835, requiredIds ={9834}, rank =10, baseId =8921, cost =32000, isTalent =0},
      -- @Rejuvenation Rank 10
      {id =9841, requiredIds ={9840}, rank =10, baseId =774, cost =32000, isTalent =0},
      -- @Claw Rank 5
      {id =9850, requiredIds ={9849}, rank =5, baseId =1082, cost =32000, isTalent =0},
      -- @Entangling Roots Rank 6
      {id =9853, requiredIds ={9852}, rank =6, baseId =339, cost =32000, isTalent =0},
      -- @Ravage Rank 4
      {id =9867, requiredIds ={9866}, rank =4, baseId =6785, cost =32000, isTalent =0},
      -- @Starfire Rank 6
      {id =9876, requiredIds ={9875}, rank =6, baseId =2912, cost =32000, isTalent =0},
      -- @Maul Rank 7
      {id =9881, requiredIds ={9880}, rank =7, baseId =6807, cost =32000, isTalent =0},
      -- @Nature's Grasp Rank 6
      {id =17329, requiredIds ={16813}, rank =6, baseId =16689, cost =1600, isTalent =1},
      -- @Hibernate Rank 3
      {id =18658, requiredIds ={18657}, rank =3, baseId =2637, cost =32000, isTalent =0},
       },
[60] = {
      -- @Tiger's Fury Rank 4
      {id =9846, requiredIds ={9845}, rank =4, baseId =5217, cost =34000, isTalent =0},
      -- @Regrowth Rank 9
      {id =9858, requiredIds ={9857}, rank =9, baseId =8936, cost =34000, isTalent =0},
      -- @Tranquility Rank 4
      {id =9863, requiredIds ={9862}, rank =4, baseId =740, cost =34000, isTalent =0},
      -- @Mark of the Wild Rank 7
      {id =9885, requiredIds ={9884}, rank =7, baseId =1126, cost =34000, isTalent =0},
      -- @Rip Rank 6
      {id =9896, requiredIds ={9894}, rank =6, baseId =1079, cost =34000, isTalent =0},
      -- @Prowl Rank 3
      {id =9913, requiredIds ={6783}, rank =3, baseId =5215, cost =34000, isTalent =0},
      -- @Hurricane Rank 3
      {id =17402, requiredIds ={17401}, rank =3, baseId =16914, cost =34000, isTalent =0},
      -- @Rebirth Rank 5
      {id =20748, requiredIds ={20747}, rank =5, baseId =20484, cost =34000, isTalent =0},
      -- @Gift of the Wild Rank 2
      {id =21850, requiredIds ={21849}, rank =2, baseId =21849, isTalent =0},
      -- @Insect Swarm Rank 5
      {id =24977, requiredIds ={24976}, rank =5, baseId =5570, cost =1700, isTalent =1},
      -- @Healing Touch Rank 11
      {id =25297, requiredIds ={9889}, rank =11, baseId =5185, isTalent =0},
      -- @Starfire Rank 7
      {id =25298, requiredIds ={9876}, rank =7, baseId =2912, isTalent =0},
      -- @Rejuvenation Rank 11
      {id =25299, requiredIds ={9841}, rank =11, baseId =774, isTalent =0},
      -- @Ferocious Bite Rank 5
      {id =31018, requiredIds ={22829}, rank =5, baseId =22568, isTalent =0}
        }
}
