local _, GW = ...

if (GW.myclass ~= "PALADIN") then
    return
end

-- Paladin Auras are special in that you never have multiple ranks in the spellbook, only the latest one is usable
-- Even so, IsSpellKnown will only return true for your current rank

-- These tables are ordered by rank

local devotionAura = {465, 10290, 643, 10291, 1032, 10292, 10293}
local retAura = {7294, 10298, 10299, 10300, 10301}
local fireResAura = {19891, 19899, 19900}
local frostResAura = {19888, 19897, 19898}
local shadowResAura = {19876, 19895, 19896}
local layOnHands = {633 --[[Rank 1]], 2800 --[[Rank 2]], 10310 --[[Rank 3]]}

GW:SetPreviousAbilityMap({devotionAura, retAura, fireResAura, frostResAura, shadowResAura, layOnHands})

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
      -- @Polearms undefined
      {id =200, isTalent =0, isSkill =1},
      -- @One-Handed Swords undefined
      {id =201, isTalent =0, isSkill =1},
      -- @Two-Handed Swords undefined
      {id =202, isTalent =0, isSkill =1},
      -- @Holy Power Rank 1
      {id =5923, rank =1, isTalent =1},
      -- @Holy Power Rank 2
      {id =5924, requiredIds ={5923}, rank =2, baseId =5923, isTalent =1},
      -- @Holy Power Rank 3
      {id =5925, requiredIds ={5924}, rank =3, baseId =5923, isTalent =1},
      -- @Holy Power Rank 4
      {id =5926, requiredIds ={5925}, rank =4, baseId =5923, isTalent =1},
      -- @Leather undefined
      {id =9077, isTalent =0, isSkill =1},
      -- @Shield undefined
      {id =9116, isTalent =0, isSkill =1},
      -- @Vindication Rank 1
      {id =9452, rank =1, isTalent =1},
      -- @Unyielding Faith Rank 1
      {id =9453, rank =1, isTalent =1},
      -- @Eye for an Eye Rank 1
      {id =9799, rank =1, isTalent =1},
      -- @Improved Blessing of Might Rank 1
      {id =20042, rank =1, isTalent =1},
      -- @Improved Blessing of Might Rank 2
      {id =20045, requiredIds ={20042}, rank =2, baseId =20042, isTalent =1},
      -- @Improved Blessing of Might Rank 3
      {id =20046, requiredIds ={20045}, rank =3, baseId =20042, isTalent =1},
      -- @Improved Blessing of Might Rank 4
      {id =20047, requiredIds ={20046}, rank =4, baseId =20042, isTalent =1},
      -- @Improved Blessing of Might Rank 5
      {id =20048, requiredIds ={20047}, rank =5, baseId =20042, isTalent =1},
      -- @Vengeance Rank 1
      {id =20049, rank =1, isTalent =1},
      -- @Vengeance Rank 2
      {id =20056, requiredIds ={20049}, rank =2, baseId =20049, isTalent =1},
      -- @Vengeance Rank 3
      {id =20057, requiredIds ={20056}, rank =3, baseId =20049, isTalent =1},
      -- @Vengeance Rank 4
      {id =20058, requiredIds ={20057}, rank =4, baseId =20049, isTalent =1},
      -- @Vengeance Rank 5
      {id =20059, requiredIds ={20058}, rank =5, baseId =20049, isTalent =1},
      -- @Deflection Rank 1
      {id =20060, rank =1, isTalent =1},
      -- @Deflection Rank 2
      {id =20061, requiredIds ={20060}, rank =2, baseId =20060, isTalent =1},
      -- @Deflection Rank 3
      {id =20062, requiredIds ={20061}, rank =3, baseId =20060, isTalent =1},
      -- @Deflection Rank 4
      {id =20063, requiredIds ={20062}, rank =4, baseId =20060, isTalent =1},
      -- @Deflection Rank 5
      {id =20064, requiredIds ={20063}, rank =5, baseId =20060, isTalent =1},
      -- @Repentance undefined
      {id =20066, isTalent =1},
      -- @Improved Retribution Aura Rank 1
      {id =20091, rank =1, isTalent =1},
      -- @Improved Retribution Aura Rank 2
      {id =20092, requiredIds ={20091}, rank =2, baseId =20091, isTalent =1},
      -- @Anticipation Rank 1
      {id =20096, rank =1, isTalent =1},
      -- @Anticipation Rank 2
      {id =20097, requiredIds ={20096}, rank =2, baseId =20096, isTalent =1},
      -- @Anticipation Rank 3
      {id =20098, requiredIds ={20097}, rank =3, baseId =20096, isTalent =1},
      -- @Anticipation Rank 4
      {id =20099, requiredIds ={20098}, rank =4, baseId =20096, isTalent =1},
      -- @Anticipation Rank 5
      {id =20100, requiredIds ={20099}, rank =5, baseId =20096, isTalent =1},
      -- @Benediction Rank 1
      {id =20101, rank =1, isTalent =1},
      -- @Benediction Rank 2
      {id =20102, requiredIds ={20101}, rank =2, baseId =20101, isTalent =1},
      -- @Benediction Rank 3
      {id =20103, requiredIds ={20102}, rank =3, baseId =20101, isTalent =1},
      -- @Benediction Rank 4
      {id =20104, requiredIds ={20103}, rank =4, baseId =20101, isTalent =1},
      -- @Benediction Rank 5
      {id =20105, requiredIds ={20104}, rank =5, baseId =20101, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 1
      {id =20111, rank =1, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 2
      {id =20112, requiredIds ={20111}, rank =2, baseId =20111, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 3
      {id =20113, requiredIds ={20112}, rank =3, baseId =20111, isTalent =1},
      -- @Conviction Rank 1
      {id =20117, rank =1, isTalent =1},
      -- @Conviction Rank 2
      {id =20118, requiredIds ={20117}, rank =2, baseId =20117, isTalent =1},
      -- @Conviction Rank 3
      {id =20119, requiredIds ={20118}, rank =3, baseId =20117, isTalent =1},
      -- @Conviction Rank 4
      {id =20120, requiredIds ={20119}, rank =4, baseId =20117, isTalent =1},
      -- @Conviction Rank 5
      {id =20121, requiredIds ={20120}, rank =5, baseId =20117, isTalent =1},
      -- @Redoubt Rank 1
      {id =20127, rank =1, isTalent =1},
      -- @Redoubt Rank 2
      {id =20130, requiredIds ={20127}, rank =2, baseId =20127, isTalent =1},
      -- @Redoubt Rank 3
      {id =20135, requiredIds ={20130}, rank =3, baseId =20127, isTalent =1},
      -- @Redoubt Rank 4
      {id =20136, requiredIds ={20135}, rank =4, baseId =20127, isTalent =1},
      -- @Redoubt Rank 5
      {id =20137, requiredIds ={20136}, rank =5, baseId =20127, isTalent =1},
      -- @Improved Devotion Aura Rank 1
      {id =20138, rank =1, isTalent =1},
      -- @Improved Devotion Aura Rank 2
      {id =20139, requiredIds ={20138}, rank =2, baseId =20138, isTalent =1},
      -- @Improved Devotion Aura Rank 3
      {id =20140, requiredIds ={20139}, rank =3, baseId =20138, isTalent =1},
      -- @Improved Devotion Aura Rank 4
      {id =20141, requiredIds ={20140}, rank =4, baseId =20138, isTalent =1},
      -- @Improved Devotion Aura Rank 5
      {id =20142, requiredIds ={20141}, rank =5, baseId =20138, isTalent =1},
      -- @Toughness Rank 1
      {id =20143, rank =1, isTalent =1},
      -- @Toughness Rank 2
      {id =20144, requiredIds ={20143}, rank =2, baseId =20143, isTalent =1},
      -- @Toughness Rank 3
      {id =20145, requiredIds ={20144}, rank =3, baseId =20143, isTalent =1},
      -- @Toughness Rank 4
      {id =20146, requiredIds ={20145}, rank =4, baseId =20143, isTalent =1},
      -- @Toughness Rank 5
      {id =20147, requiredIds ={20146}, rank =5, baseId =20143, isTalent =1},
      -- @Shield Specialization Rank 1
      {id =20148, rank =1, isTalent =1},
      -- @Shield Specialization Rank 2
      {id =20149, requiredIds ={20148}, rank =2, baseId =20148, isTalent =1},
      -- @Shield Specialization Rank 3
      {id =20150, requiredIds ={20149}, rank =3, baseId =20148, isTalent =1},
      -- @Guardian's Favor Rank 1
      {id =20174, rank =1, isTalent =1},
      -- @Guardian's Favor Rank 2
      {id =20175, requiredIds ={20174}, rank =2, baseId =20174, isTalent =1},
      -- @Reckoning Rank 1
      {id =20177, rank =1, isTalent =1},
      -- @Reckoning Rank 2
      {id =20179, requiredIds ={20177}, rank =2, baseId =20177, isTalent =1},
      -- @Reckoning Rank 4
      {id =20180, requiredIds ={20181}, rank =4, baseId =20177, isTalent =1},
      -- @Reckoning Rank 3
      {id =20181, requiredIds ={20179}, rank =3, baseId =20177, isTalent =1},
      -- @Reckoning Rank 5
      {id =20182, requiredIds ={20180}, rank =5, baseId =20177, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 1
      {id =20196, rank =1, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 2
      {id =20197, requiredIds ={20196}, rank =2, baseId =20196, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 3
      {id =20198, requiredIds ={20197}, rank =3, baseId =20196, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 4
      {id =20199, requiredIds ={20198}, rank =4, baseId =20196, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 5
      {id =20200, requiredIds ={20199}, rank =5, baseId =20196, isTalent =1},
      -- @Spiritual Focus Rank 1
      {id =20205, rank =1, isTalent =1},
      -- @Spiritual Focus Rank 2
      {id =20206, requiredIds ={20205}, rank =2, baseId =20205, isTalent =1},
      -- @Spiritual Focus Rank 3
      {id =20207, requiredIds ={20206}, rank =3, baseId =20205, isTalent =1},
      -- @Spiritual Focus Rank 5
      {id =20208, requiredIds ={20209}, rank =5, baseId =20205, isTalent =1},
      -- @Spiritual Focus Rank 4
      {id =20209, requiredIds ={20207}, rank =4, baseId =20205, isTalent =1},
      -- @Illumination Rank 1
      {id =20210, rank =1, isTalent =1},
      -- @Illumination Rank 2
      {id =20212, requiredIds ={20210}, rank =2, baseId =20210, isTalent =1},
      -- @Illumination Rank 3
      {id =20213, requiredIds ={20212}, rank =3, baseId =20210, isTalent =1},
      -- @Illumination Rank 4
      {id =20214, requiredIds ={20213}, rank =4, baseId =20210, isTalent =1},
      -- @Illumination Rank 5
      {id =20215, requiredIds ={20214}, rank =5, baseId =20210, isTalent =1},
      -- @Divine Favor undefined
      {id =20216, isTalent =1},
      -- @Blessing of Kings undefined
      {id =20217, isTalent =1},
      -- @Sanctity Aura undefined
      {id =20218, isTalent =1},
      -- @Improved Seal of Righteousness Rank 1
      {id =20224, rank =1, isTalent =1},
      -- @Improved Seal of Righteousness Rank 2
      {id =20225, requiredIds ={20224}, rank =2, baseId =20224, isTalent =1},
      -- @Improved Lay on Hands Rank 1
      {id =20234, rank =1, isTalent =1},
      -- @Improved Lay on Hands Rank 2
      {id =20235, requiredIds ={20234}, rank =2, baseId =20234, isTalent =1},
      -- @Healing Light Rank 1
      {id =20237, rank =1, isTalent =1},
      -- @Healing Light Rank 2
      {id =20238, requiredIds ={20237}, rank =2, baseId =20237, isTalent =1},
      -- @Healing Light Rank 3
      {id =20239, requiredIds ={20238}, rank =3, baseId =20237, isTalent =1},
      -- @Improved Blessing of Wisdom Rank 1
      {id =20244, rank =1, isTalent =1},
      -- @Improved Blessing of Wisdom Rank 2
      {id =20245, requiredIds ={20244}, rank =2, baseId =20244, isTalent =1},
      -- @Improved Concentration Aura Rank 1
      {id =20254, rank =1, isTalent =1},
      -- @Improved Concentration Aura Rank 2
      {id =20255, requiredIds ={20254}, rank =2, baseId =20254, isTalent =1},
      -- @Improved Concentration Aura Rank 3
      {id =20256, requiredIds ={20255}, rank =3, baseId =20254, isTalent =1},
      -- @Divine Intellect Rank 1
      {id =20257, rank =1, isTalent =1},
      -- @Divine Intellect Rank 2
      {id =20258, requiredIds ={20257}, rank =2, baseId =20257, isTalent =1},
      -- @Divine Intellect Rank 3
      {id =20259, requiredIds ={20258}, rank =3, baseId =20257, isTalent =1},
      -- @Divine Intellect Rank 4
      {id =20260, requiredIds ={20259}, rank =4, baseId =20257, isTalent =1},
      -- @Divine Intellect Rank 5
      {id =20261, requiredIds ={20260}, rank =5, baseId =20257, isTalent =1},
      -- @Divine Strength Rank 1
      {id =20262, rank =1, isTalent =1},
      -- @Divine Strength Rank 2
      {id =20263, requiredIds ={20262}, rank =2, baseId =20262, isTalent =1},
      -- @Divine Strength Rank 3
      {id =20264, requiredIds ={20263}, rank =3, baseId =20262, isTalent =1},
      -- @Divine Strength Rank 4
      {id =20265, requiredIds ={20264}, rank =4, baseId =20262, isTalent =1},
      -- @Divine Strength Rank 5
      {id =20266, requiredIds ={20265}, rank =5, baseId =20262, isTalent =1},
      -- @Improved Seal of Righteousness Rank 3
      {id =20330, requiredIds ={20225}, rank =3, baseId =20224, isTalent =1},
      -- @Improved Seal of Righteousness Rank 4
      {id =20331, requiredIds ={20330}, rank =4, baseId =20224, isTalent =1},
      -- @Improved Seal of Righteousness Rank 5
      {id =20332, requiredIds ={20331}, rank =5, baseId =20224, isTalent =1},
      -- @Improved Seal of the Crusader Rank 1
      {id =20335, rank =1, isTalent =1},
      -- @Improved Seal of the Crusader Rank 2
      {id =20336, requiredIds ={20335}, rank =2, baseId =20335, isTalent =1},
      -- @Improved Seal of the Crusader Rank 3
      {id =20337, requiredIds ={20336}, rank =3, baseId =20335, isTalent =1},
      -- @Lasting Judgement Rank 1
      {id =20359, rank =1, isTalent =1},
      -- @Lasting Judgement Rank 2
      {id =20360, requiredIds ={20359}, rank =2, baseId =20359, isTalent =1},
      -- @Lasting Judgement Rank 3
      {id =20361, requiredIds ={20360}, rank =3, baseId =20359, isTalent =1},
      -- @Seal of Command Rank 1
      {id =20375, rank =1, isTalent =1},
      -- @Improved Righteous Fury Rank 1
      {id =20468, rank =1, isTalent =1},
      -- @Improved Righteous Fury Rank 2
      {id =20469, requiredIds ={20468}, rank =2, baseId =20468, isTalent =1},
      -- @Improved Righteous Fury Rank 3
      {id =20470, requiredIds ={20469}, rank =3, baseId =20468, isTalent =1},
      -- @Holy Shock Rank 1
      {id =20473, rank =1, isTalent =1},
      -- @Improved Hammer of Justice Rank 1
      {id =20487, rank =1, isTalent =1},
      -- @Improved Hammer of Justice Rank 2
      {id =20488, requiredIds ={20487}, rank =2, baseId =20487, isTalent =1},
      -- @Improved Hammer of Justice Rank 3
      {id =20489, requiredIds ={20488}, rank =3, baseId =20487, isTalent =1},
      -- @Blessing of Sanctuary Rank 1
      {id =20911, rank =1, isTalent =1},
      -- @Holy Shield Rank 1
      {id =20925, rank =1, isTalent =1},
      -- @Holy Power Rank 5
      {id =25829, requiredIds ={5926}, rank =5, baseId =5923, isTalent =1},
      -- @Unyielding Faith Rank 2
      {id =25836, requiredIds ={9453}, rank =2, baseId =9453, isTalent =1},
      -- @Improved Judgement Rank 1
      {id =25956, rank =1, isTalent =1},
      -- @Improved Judgement Rank 2
      {id =25957, requiredIds ={25956}, rank =2, baseId =25956, isTalent =1},
      -- @Eye for an Eye Rank 2
      {id =25988, requiredIds ={9799}, rank =2, baseId =9799, isTalent =1},
      -- @Vindication Rank 2
      {id =26016, requiredIds ={9452}, rank =2, baseId =9452, isTalent =1},
      -- @Vindication Rank 3
      {id =26021, requiredIds ={26016}, rank =3, baseId =9452, isTalent =1},
      -- @Pursuit of Justice Rank 1
      {id =26022, rank =1, isTalent =1},
      -- @Pursuit of Justice Rank 2
      {id =26023, requiredIds ={26022}, rank =2, baseId =26022, isTalent =1},
      -- @Consecration Rank 1
      {id =26573, rank =1, isTalent =1},
      -- @Libram undefined
      {id =27762, isTalent =0},
       },
[1] = {
      -- @Block Passive
      {id =107, isTalent =0},
      -- @Devotion Aura Rank 1
      {id =465, rank =1, cost =10, isTalent =0},
      -- @Holy Light Rank 1
      {id =635, rank =1, isTalent =0},
      -- @Parry Passive
      {id =3127, isTalent =0},
      -- @Seal of Righteousness Rank 1
      {id =20154, rank =1, isTalent =0},
      -- @Seal of Righteousness Rank 1
      {id =21084, rank =1, baseId =20154, isTalent =0},
       },
[4] = {
      -- @Blessing of Might Rank 1
      {id =19740, rank =1, cost =100, isTalent =0},
      -- @Judgement undefined
      {id =20271, cost =100, isTalent =0},
       },
[6] = {
      -- @Divine Protection Rank 1
      {id =498, rank =1, cost =100, isTalent =0},
      -- @Holy Light Rank 2
      {id =639, requiredIds ={635}, rank =2, baseId =635, cost =100, isTalent =0},
      -- @Seal of the Crusader Rank 1
      {id =21082, rank =1, cost =100, isTalent =0},
       },
[8] = {
      -- @Hammer of Justice Rank 1
      {id =853, rank =1, cost =100, isTalent =0},
      -- @Purify undefined
      {id =1152, cost =100, isTalent =0},
       },
[10] = {
      -- @Lay on Hands Rank 1
      {id =633, rank =1, cost =300, isTalent =0},
      -- @Blessing of Protection Rank 1
      {id =1022, rank =1, cost =300, isTalent =0},
      -- @Devotion Aura Rank 2
      {id =10290, requiredIds ={465}, rank =2, baseId =465, cost =300, isTalent =0},
      -- @Seal of Righteousness Rank 2
      {id =20287, requiredIds ={20154, 21084}, rank =2, baseId =20154, cost =300, isTalent =0},
       },
[12] = {
      -- @Redemption Rank 1
      {id =7328, rank =1, isTalent =0},
      -- @Blessing of Might Rank 2
      {id =19834, requiredIds ={19740}, rank =2, baseId =19740, cost =1000, isTalent =0},
      -- @Seal of the Crusader Rank 2
      {id =20162, requiredIds ={21082}, rank =2, baseId =21082, cost =1000, isTalent =0},
       },
[14] = {
      -- @Holy Light Rank 3
      {id =647, requiredIds ={639}, rank =3, baseId =635, cost =2000, isTalent =0},
      -- @Blessing of Wisdom Rank 1
      {id =19742, rank =1, cost =2000, isTalent =0},
       },
[16] = {
      -- @Retribution Aura Rank 1
      {id =7294, rank =1, cost =3000, isTalent =0},
      -- @Righteous Fury undefined
      {id =25780, cost =3000, isTalent =0},
       },
[18] = {
      -- @Blessing of Freedom undefined
      {id =1044, cost =3500, isTalent =0},
      -- @Divine Protection Rank 2
      {id =5573, requiredIds ={498}, rank =2, baseId =498, cost =3500, isTalent =0},
      -- @Seal of Righteousness Rank 3
      {id =20288, requiredIds ={20287}, rank =3, baseId =20154, cost =3500, isTalent =0},
       },
[20] = {
      -- @Devotion Aura Rank 3
      {id =643, requiredIds ={10290}, rank =3, baseId =465, cost =4000, isTalent =0},
      -- @Exorcism Rank 1
      {id =879, rank =1, cost =4000, isTalent =0},
      -- @Sense Undead undefined
      {id =5502, isTalent =0},
      -- @Flash of Light Rank 1
      {id =19750, rank =1, cost =4000, isTalent =0},
       },
[22] = {
      -- @Holy Light Rank 4
      {id =1026, requiredIds ={647}, rank =4, baseId =635, cost =4000, isTalent =0},
      -- @Concentration Aura undefined
      {id =19746, cost =4000, isTalent =0},
      -- @Blessing of Might Rank 3
      {id =19835, requiredIds ={19834}, rank =3, baseId =19740, cost =4000, isTalent =0},
      -- @Seal of Justice undefined
      {id =20164, cost =4000, isTalent =0},
      -- @Seal of the Crusader Rank 3
      {id =20305, requiredIds ={20162}, rank =3, baseId =21082, cost =4000, isTalent =0},
       },
[24] = {
      -- @Turn Undead Rank 1
      {id =2878, rank =1, cost =5000, isTalent =0},
      -- @Hammer of Justice Rank 2
      {id =5588, requiredIds ={853}, rank =2, baseId =853, cost =5000, isTalent =0},
      -- @Blessing of Protection Rank 2
      {id =5599, requiredIds ={1022}, rank =2, baseId =1022, cost =5000, isTalent =0},
      -- @Redemption Rank 2
      {id =10322, requiredIds ={7328}, rank =2, baseId =7328, cost =5000, isTalent =0},
      -- @Blessing of Wisdom Rank 2
      {id =19850, requiredIds ={19742}, rank =2, baseId =19742, cost =5000, isTalent =0},
       },
[26] = {
      -- @Blessing of Salvation undefined
      {id =1038, cost =6000, isTalent =0},
      -- @Retribution Aura Rank 2
      {id =10298, requiredIds ={7294}, rank =2, baseId =7294, cost =6000, isTalent =0},
      -- @Flash of Light Rank 2
      {id =19939, requiredIds ={19750}, rank =2, baseId =19750, cost =6000, isTalent =0},
      -- @Seal of Righteousness Rank 4
      {id =20289, requiredIds ={20288}, rank =4, baseId =20154, cost =6000, isTalent =0},
       },
[28] = {
      -- @Exorcism Rank 2
      {id =5614, requiredIds ={879}, rank =2, baseId =879, cost =9000, isTalent =0},
      -- @Shadow Resistance Aura Rank 1
      {id =19876, rank =1, cost =9000, isTalent =0},
       },
[30] = {
      -- @Holy Light Rank 5
      {id =1042, requiredIds ={1026}, rank =5, baseId =635, cost =11000, isTalent =0},
      -- @Lay on Hands Rank 2
      {id =2800, requiredIds ={633}, rank =2, baseId =633, cost =11000, isTalent =0},
      -- @Devotion Aura Rank 4
      {id =10291, requiredIds ={643}, rank =4, baseId =465, cost =11000, isTalent =0},
      -- @Divine Intervention undefined
      {id =19752, cost =11000, isTalent =0},
      -- @Consecration Rank 2
      {id =20116, requiredIds ={26573}, rank =2, baseId =26573, cost =200, isTalent =1},
      -- @Seal of Light Rank 1
      {id =20165, rank =1, cost =11000, isTalent =0},
      -- @Seal of Command Rank 2
      {id =20915, requiredIds ={20375}, rank =2, baseId =20375, cost =550, isTalent =1},
       },
[32] = {
      -- @Blessing of Might Rank 4
      {id =19836, requiredIds ={19835}, rank =4, baseId =19740, cost =12000, isTalent =0},
      -- @Frost Resistance Aura Rank 1
      {id =19888, rank =1, cost =12000, isTalent =0},
      -- @Seal of the Crusader Rank 4
      {id =20306, requiredIds ={20305}, rank =4, baseId =21082, cost =12000, isTalent =0},
       },
[34] = {
      -- @Divine Shield Rank 1
      {id =642, rank =1, cost =13000, isTalent =0},
      -- @Blessing of Wisdom Rank 3
      {id =19852, requiredIds ={19850}, rank =3, baseId =19742, cost =13000, isTalent =0},
      -- @Flash of Light Rank 3
      {id =19940, requiredIds ={19939}, rank =3, baseId =19750, cost =13000, isTalent =0},
      -- @Seal of Righteousness Rank 5
      {id =20290, requiredIds ={20289}, rank =5, baseId =20154, cost =13000, isTalent =0},
       },
[36] = {
      -- @Exorcism Rank 3
      {id =5615, requiredIds ={5614}, rank =3, baseId =879, cost =14000, isTalent =0},
      -- @Retribution Aura Rank 3
      {id =10299, requiredIds ={10298}, rank =3, baseId =7294, cost =14000, isTalent =0},
      -- @Redemption Rank 3
      {id =10324, requiredIds ={10322}, rank =3, baseId =7328, cost =14000, isTalent =0},
      -- @Fire Resistance Aura Rank 1
      {id =19891, rank =1, cost =14000, isTalent =0},
       },
[38] = {
      -- @Holy Light Rank 6
      {id =3472, requiredIds ={1042}, rank =6, baseId =635, cost =16000, isTalent =0},
      -- @Turn Undead Rank 2
      {id =5627, requiredIds ={2878}, rank =2, baseId =2878, cost =16000, isTalent =0},
      -- @Blessing of Protection Rank 3
      {id =10278, requiredIds ={5599}, rank =3, baseId =1022, cost =16000, isTalent =0},
      -- @Seal of Wisdom Rank 1
      {id =20166, rank =1, cost =16000, isTalent =0},
       },
[40] = {
      -- @Devotion Aura Rank 5
      {id =1032, requiredIds ={10291}, rank =5, baseId =465, cost =20000, isTalent =0},
      -- @Hammer of Justice Rank 3
      {id =5589, requiredIds ={5588}, rank =3, baseId =853, cost =20000, isTalent =0},
      -- @Summon Warhorse Summon
      {id =13819, isTalent =0},
      -- @Shadow Resistance Aura Rank 2
      {id =19895, requiredIds ={19876}, rank =2, baseId =19876, cost =20000, isTalent =0},
      -- @Blessing of Light Rank 1
      {id =19977, rank =1, cost =20000, isTalent =0},
      -- @Seal of Light Rank 2
      {id =20347, requiredIds ={20165}, rank =2, baseId =20165, cost =20000, isTalent =0},
      -- @Blessing of Sanctuary Rank 2
      {id =20912, requiredIds ={20911}, rank =2, baseId =20911, cost =1000, isTalent =1},
      -- @Seal of Command Rank 3
      {id =20918, requiredIds ={20915}, rank =3, baseId =20375, cost =1000, isTalent =1},
      -- @Consecration Rank 3
      {id =20922, requiredIds ={20116}, rank =3, baseId =26573, cost =1000, isTalent =1},
       -- @Plate Mail undefined
       {id =750, isTalent =0, isSkill =1},
       },
[42] = {
      -- @Cleanse undefined
      {id =4987, cost =21000, isTalent =0},
      -- @Blessing of Might Rank 5
      {id =19837, requiredIds ={19836}, rank =5, baseId =19740, cost =21000, isTalent =0},
      -- @Flash of Light Rank 4
      {id =19941, requiredIds ={19940}, rank =4, baseId =19750, cost =21000, isTalent =0},
      -- @Seal of Righteousness Rank 6
      {id =20291, requiredIds ={20290}, rank =6, baseId =20154, cost =21000, isTalent =0},
      -- @Seal of the Crusader Rank 5
      {id =20307, requiredIds ={20306}, rank =5, baseId =21082, cost =21000, isTalent =0},
       },
[44] = {
      -- @Exorcism Rank 4
      {id =10312, requiredIds ={5615}, rank =4, baseId =879, cost =22000, isTalent =0},
      -- @Blessing of Wisdom Rank 4
      {id =19853, requiredIds ={19852}, rank =4, baseId =19742, cost =22000, isTalent =0},
      -- @Frost Resistance Aura Rank 2
      {id =19897, requiredIds ={19888}, rank =2, baseId =19888, cost =22000, isTalent =0},
      -- @Hammer of Wrath Rank 1
      {id =24275, rank =1, cost =22000, isTalent =0},
       },
[46] = {
      -- @Blessing of Sacrifice Rank 1
      {id =6940, rank =1, cost =24000, isTalent =0},
      -- @Retribution Aura Rank 4
      {id =10300, requiredIds ={10299}, rank =4, baseId =7294, cost =24000, isTalent =0},
      -- @Holy Light Rank 7
      {id =10328, requiredIds ={3472}, rank =7, baseId =635, cost =24000, isTalent =0},
       },
[48] = {
      -- @Fire Resistance Aura Rank 2
      {id =19899, requiredIds ={19891}, rank =2, baseId =19891, cost =26000, isTalent =0},
      -- @Seal of Wisdom Rank 2
      {id =20356, requiredIds ={20166}, rank =2, baseId =20166, cost =26000, isTalent =0},
      -- @Redemption Rank 4
      {id =20772, requiredIds ={10324}, rank =4, baseId =7328, cost =26000, isTalent =0},
      -- @Holy Shock Rank 2
      {id =20929, requiredIds ={20473}, rank =2, baseId =20473, cost =1300, isTalent =1},
       },
[50] = {
      -- @Divine Shield Rank 2
      {id =1020, requiredIds ={642}, rank =2, baseId =642, cost =28000, isTalent =0},
      -- @Holy Wrath Rank 1
      {id =2812, rank =1, cost =28000, isTalent =0},
      -- @Devotion Aura Rank 6
      {id =10292, requiredIds ={1032}, rank =6, baseId =465, cost =28000, isTalent =0},
      -- @Lay on Hands Rank 3
      {id =10310, requiredIds ={2800}, rank =3, baseId =633, cost =28000, isTalent =0},
      -- @Flash of Light Rank 5
      {id =19942, requiredIds ={19941}, rank =5, baseId =19750, cost =28000, isTalent =0},
      -- @Blessing of Light Rank 2
      {id =19978, requiredIds ={19977}, rank =2, baseId =19977, cost =28000, isTalent =0},
      -- @Seal of Righteousness Rank 7
      {id =20292, requiredIds ={20291}, rank =7, baseId =20154, cost =28000, isTalent =0},
      -- @Seal of Light Rank 3
      {id =20348, requiredIds ={20347}, rank =3, baseId =20165, cost =28000, isTalent =0},
      -- @Blessing of Sanctuary Rank 3
      {id =20913, requiredIds ={20912}, rank =3, baseId =20911, cost =1400, isTalent =1},
      -- @Seal of Command Rank 4
      {id =20919, requiredIds ={20918}, rank =4, baseId =20375, cost =1400, isTalent =1},
      -- @Consecration Rank 4
      {id =20923, requiredIds ={20922}, rank =4, baseId =26573, cost =1400, isTalent =1},
      -- @Holy Shield Rank 2
      {id =20927, requiredIds ={20925}, rank =2, baseId =20925, cost =1400, isTalent =1},
       },
[52] = {
      -- @Exorcism Rank 5
      {id =10313, requiredIds ={10312}, rank =5, baseId =879, cost =34000, isTalent =0},
      -- @Turn Undead Rank 3
      {id =10326, requiredIds ={5627}, rank =3, baseId =2878, cost =34000, isTalent =0},
      -- @Blessing of Might Rank 6
      {id =19838, requiredIds ={19837}, rank =6, baseId =19740, cost =34000, isTalent =0},
      -- @Shadow Resistance Aura Rank 3
      {id =19896, requiredIds ={19895}, rank =3, baseId =19876, cost =34000, isTalent =0},
      -- @Seal of the Crusader Rank 6
      {id =20308, requiredIds ={20307}, rank =6, baseId =21082, cost =34000, isTalent =0},
      -- @Hammer of Wrath Rank 2
      {id =24274, requiredIds ={24275}, rank =2, baseId =24275, cost =34000, isTalent =0},
      -- @Greater Blessing of Might Rank 1
      {id =25782, rank =1, cost =46000, isTalent =0},
       },
[54] = {
      -- @Hammer of Justice Rank 4
      {id =10308, requiredIds ={5589}, rank =4, baseId =853, cost =40000, isTalent =0},
      -- @Holy Light Rank 8
      {id =10329, requiredIds ={10328}, rank =8, baseId =635, cost =40000, isTalent =0},
      -- @Blessing of Wisdom Rank 5
      {id =19854, requiredIds ={19853}, rank =5, baseId =19742, cost =40000, isTalent =0},
      -- @Blessing of Sacrifice Rank 2
      {id =20729, requiredIds ={6940}, rank =2, baseId =6940, cost =40000, isTalent =0},
      -- @Greater Blessing of Wisdom Rank 1
      {id =25894, rank =1, cost =46000, isTalent =0},
       },
[56] = {
      -- @Retribution Aura Rank 5
      {id =10301, requiredIds ={10300}, rank =5, baseId =7294, cost =42000, isTalent =0},
      -- @Frost Resistance Aura Rank 3
      {id =19898, requiredIds ={19897}, rank =3, baseId =19888, cost =42000, isTalent =0},
      -- @Holy Shock Rank 3
      {id =20930, requiredIds ={20929}, rank =3, baseId =20473, cost =2100, isTalent =1},
       },
[58] = {
      -- @Flash of Light Rank 6
      {id =19943, requiredIds ={19942}, rank =6, baseId =19750, cost =44000, isTalent =0},
      -- @Seal of Righteousness Rank 8
      {id =20293, requiredIds ={20292}, rank =8, baseId =20154, cost =44000, isTalent =0},
      -- @Seal of Wisdom Rank 3
      {id =20357, requiredIds ={20356}, rank =3, baseId =20166, cost =44000, isTalent =0},
       },
[60] = {
      -- @Devotion Aura Rank 7
      {id =10293, requiredIds ={10292}, rank =7, baseId =465, cost =46000, isTalent =0},
      -- @Exorcism Rank 6
      {id =10314, requiredIds ={10313}, rank =6, baseId =879, cost =46000, isTalent =0},
      -- @Holy Wrath Rank 2
      {id =10318, requiredIds ={2812}, rank =2, baseId =2812, cost =46000, isTalent =0},
      -- @Fire Resistance Aura Rank 3
      {id =19900, requiredIds ={19899}, rank =3, baseId =19891, cost =46000, isTalent =0},
      -- @Blessing of Light Rank 3
      {id =19979, requiredIds ={19978}, rank =3, baseId =19977, cost =46000, isTalent =0},
      -- @Seal of Light Rank 4
      {id =20349, requiredIds ={20348}, rank =4, baseId =20165, cost =46000, isTalent =0},
      -- @Redemption Rank 5
      {id =20773, requiredIds ={20772}, rank =5, baseId =7328, cost =46000, isTalent =0},
      -- @Blessing of Sanctuary Rank 4
      {id =20914, requiredIds ={20913}, rank =4, baseId =20911, cost =2300, isTalent =1},
      -- @Seal of Command Rank 5
      {id =20920, requiredIds ={20919}, rank =5, baseId =20375, cost =2300, isTalent =1},
      -- @Consecration Rank 5
      {id =20924, requiredIds ={20923}, rank =5, baseId =26573, cost =2300, isTalent =1},
      -- @Holy Shield Rank 3
      {id =20928, requiredIds ={20927}, rank =3, baseId =20925, cost =2300, isTalent =1},
      -- @Summon Charger Summon
      {id =23214, isTalent =0},
      -- @Hammer of Wrath Rank 3
      {id =24239, requiredIds ={24274}, rank =3, baseId =24275, cost =46000, isTalent =0},
      -- @Blessing of Wisdom Rank 6
      {id =25290, requiredIds ={19854}, rank =6, baseId =19742, isTalent =0},
      -- @Blessing of Might Rank 7
      {id =25291, requiredIds ={19838}, rank =7, baseId =19740, isTalent =0},
      -- @Holy Light Rank 9
      {id =25292, requiredIds ={10329}, rank =9, baseId =635, isTalent =0},
      -- @Greater Blessing of Light Rank 1
      {id =25890, rank =1, cost =46000, isTalent =0},
      -- @Greater Blessing of Salvation undefined
      {id =25895, cost =46000, isTalent =0},
      -- @Greater Blessing of Kings undefined
      {id =25898, requiredIds ={20217}, rank =1, baseId =20217, cost =2300, isTalent =1},
      -- @Greater Blessing of Sanctuary Rank 1
      {id =25899, requiredIds ={20914}, rank =1, baseId =20911, cost =2300, isTalent =1},
      -- @Greater Blessing of Might Rank 2
      {id =25916, requiredIds ={25782}, rank =2, baseId =25782, cost =46000, isTalent =0},
      -- @Greater Blessing of Wisdom Rank 2
      {id =25918, requiredIds ={25894}, rank =2, baseId =25894, cost =46000, isTalent =0}
        }
}
