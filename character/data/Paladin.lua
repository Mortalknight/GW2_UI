local _, GW = ...
if (GW.currentClass ~= "PALADIN") then
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

--GW:SetPreviousAbilityMap({devotionAura, retAura, fireResAura, frostResAura, shadowResAura, layOnHands})

GW.SpellsByLevel =

 {
 [0] = {
      -- @One-Handed Axes undefined
      {id =196, isTalent =0},
      -- @Two-Handed Axes undefined
      {id =197, isTalent =0},
      -- @One-Handed Maces undefined
      {id =198, isTalent =0},
      -- @Two-Handed Maces undefined
      {id =199, isTalent =0},
      -- @Polearms undefined
      {id =200, isTalent =0},
      -- @One-Handed Swords undefined
      {id =201, isTalent =0},
      -- @Two-Handed Swords undefined
      {id =202, isTalent =0},
      -- @Plate Mail undefined
      {id =750, isTalent =0},
      -- @Holy Power Rank 1
      {id =5923, isTalent =1},
      -- @Holy Power Rank 2
      {id =5924, requiredIds ={5923}, isTalent =1},
      -- @Holy Power Rank 3
      {id =5925, requiredIds ={5924}, isTalent =1},
      -- @Holy Power Rank 4
      {id =5926, requiredIds ={5925}, isTalent =1},
      -- @Mail undefined
      {id =8737, isTalent =0},
      -- @Leather undefined
      {id =9077, isTalent =0},
      -- @Shield undefined
      {id =9116, isTalent =0},
      -- @Vindication Rank 1
      {id =9452, isTalent =1},
      -- @Unyielding Faith Rank 1
      {id =9453, isTalent =1},
      -- @Eye for an Eye Rank 1
      {id =9799, isTalent =1},
      -- @Improved Blessing of Might Rank 1
      {id =20042, isTalent =1},
      -- @Improved Blessing of Might Rank 2
      {id =20045, requiredIds ={20042}, isTalent =1},
      -- @Improved Blessing of Might Rank 3
      {id =20046, requiredIds ={20045}, isTalent =1},
      -- @Improved Blessing of Might Rank 4
      {id =20047, requiredIds ={20046}, isTalent =1},
      -- @Improved Blessing of Might Rank 5
      {id =20048, requiredIds ={20047}, isTalent =1},
      -- @Vengeance Rank 1
      {id =20049, isTalent =1},
      -- @Vengeance Rank 2
      {id =20056, requiredIds ={20049}, isTalent =1},
      -- @Vengeance Rank 3
      {id =20057, requiredIds ={20056}, isTalent =1},
      -- @Vengeance Rank 4
      {id =20058, requiredIds ={20057}, isTalent =1},
      -- @Vengeance Rank 5
      {id =20059, requiredIds ={20058}, isTalent =1},
      -- @Deflection Rank 1
      {id =20060, isTalent =1},
      -- @Deflection Rank 2
      {id =20061, requiredIds ={20060}, isTalent =1},
      -- @Deflection Rank 3
      {id =20062, requiredIds ={20061}, isTalent =1},
      -- @Deflection Rank 4
      {id =20063, requiredIds ={20062}, isTalent =1},
      -- @Deflection Rank 5
      {id =20064, requiredIds ={20063}, isTalent =1},
      -- @Repentance undefined
      {id =20066, isTalent =1},
      -- @Improved Retribution Aura Rank 1
      {id =20091, isTalent =1},
      -- @Improved Retribution Aura Rank 2
      {id =20092, requiredIds ={20091}, isTalent =1},
      -- @Anticipation Rank 1
      {id =20096, isTalent =1},
      -- @Anticipation Rank 2
      {id =20097, requiredIds ={20096}, isTalent =1},
      -- @Anticipation Rank 3
      {id =20098, requiredIds ={20097}, isTalent =1},
      -- @Anticipation Rank 4
      {id =20099, requiredIds ={20098}, isTalent =1},
      -- @Anticipation Rank 5
      {id =20100, requiredIds ={20099}, isTalent =1},
      -- @Benediction Rank 1
      {id =20101, isTalent =1},
      -- @Benediction Rank 2
      {id =20102, requiredIds ={20101}, isTalent =1},
      -- @Benediction Rank 3
      {id =20103, requiredIds ={20102}, isTalent =1},
      -- @Benediction Rank 4
      {id =20104, requiredIds ={20103}, isTalent =1},
      -- @Benediction Rank 5
      {id =20105, requiredIds ={20104}, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 1
      {id =20111, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 2
      {id =20112, requiredIds ={20111}, isTalent =1},
      -- @Two-Handed Weapon Specialization Rank 3
      {id =20113, requiredIds ={20112}, isTalent =1},
      -- @Conviction Rank 1
      {id =20117, isTalent =1},
      -- @Conviction Rank 2
      {id =20118, requiredIds ={20117}, isTalent =1},
      -- @Conviction Rank 3
      {id =20119, requiredIds ={20118}, isTalent =1},
      -- @Conviction Rank 4
      {id =20120, requiredIds ={20119}, isTalent =1},
      -- @Conviction Rank 5
      {id =20121, requiredIds ={20120}, isTalent =1},
      -- @Redoubt Rank 1
      {id =20127, isTalent =1},
      -- @Redoubt Rank 2
      {id =20130, requiredIds ={20127}, isTalent =1},
      -- @Redoubt Rank 3
      {id =20135, requiredIds ={20130}, isTalent =1},
      -- @Redoubt Rank 4
      {id =20136, requiredIds ={20135}, isTalent =1},
      -- @Redoubt Rank 5
      {id =20137, requiredIds ={20136}, isTalent =1},
      -- @Improved Devotion Aura Rank 1
      {id =20138, isTalent =1},
      -- @Improved Devotion Aura Rank 2
      {id =20139, requiredIds ={20138}, isTalent =1},
      -- @Improved Devotion Aura Rank 3
      {id =20140, requiredIds ={20139}, isTalent =1},
      -- @Improved Devotion Aura Rank 4
      {id =20141, requiredIds ={20140}, isTalent =1},
      -- @Improved Devotion Aura Rank 5
      {id =20142, requiredIds ={20141}, isTalent =1},
      -- @Toughness Rank 1
      {id =20143, isTalent =1},
      -- @Toughness Rank 2
      {id =20144, requiredIds ={20143}, isTalent =1},
      -- @Toughness Rank 3
      {id =20145, requiredIds ={20144}, isTalent =1},
      -- @Toughness Rank 4
      {id =20146, requiredIds ={20145}, isTalent =1},
      -- @Toughness Rank 5
      {id =20147, requiredIds ={20146}, isTalent =1},
      -- @Shield Specialization Rank 1
      {id =20148, isTalent =1},
      -- @Shield Specialization Rank 2
      {id =20149, requiredIds ={20148}, isTalent =1},
      -- @Shield Specialization Rank 3
      {id =20150, requiredIds ={20149}, isTalent =1},
      -- @Guardian's Favor Rank 1
      {id =20174, isTalent =1},
      -- @Guardian's Favor Rank 2
      {id =20175, requiredIds ={20174}, isTalent =1},
      -- @Reckoning Rank 1
      {id =20177, isTalent =1},
      -- @Reckoning Rank 2
      {id =20179, requiredIds ={20177}, isTalent =1},
      -- @Reckoning Rank 4
      {id =20180, requiredIds ={20181}, isTalent =1},
      -- @Reckoning Rank 3
      {id =20181, requiredIds ={20179}, isTalent =1},
      -- @Reckoning Rank 5
      {id =20182, requiredIds ={20180}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 1
      {id =20196, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 2
      {id =20197, requiredIds ={20196}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 3
      {id =20198, requiredIds ={20197}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 4
      {id =20199, requiredIds ={20198}, isTalent =1},
      -- @One-Handed Weapon Specialization Rank 5
      {id =20200, requiredIds ={20199}, isTalent =1},
      -- @Spiritual Focus Rank 1
      {id =20205, isTalent =1},
      -- @Spiritual Focus Rank 2
      {id =20206, requiredIds ={20205}, isTalent =1},
      -- @Spiritual Focus Rank 3
      {id =20207, requiredIds ={20206}, isTalent =1},
      -- @Spiritual Focus Rank 5
      {id =20208, requiredIds ={20209}, isTalent =1},
      -- @Spiritual Focus Rank 4
      {id =20209, requiredIds ={20207}, isTalent =1},
      -- @Illumination Rank 1
      {id =20210, isTalent =1},
      -- @Illumination Rank 2
      {id =20212, requiredIds ={20210}, isTalent =1},
      -- @Illumination Rank 3
      {id =20213, requiredIds ={20212}, isTalent =1},
      -- @Illumination Rank 4
      {id =20214, requiredIds ={20213}, isTalent =1},
      -- @Illumination Rank 5
      {id =20215, requiredIds ={20214}, isTalent =1},
      -- @Divine Favor undefined
      {id =20216, isTalent =1},
      -- @Blessing of Kings undefined
      {id =20217, isTalent =1},
      -- @Sanctity Aura undefined
      {id =20218, isTalent =1},
      -- @Improved Seal of Righteousness Rank 1
      {id =20224, isTalent =1},
      -- @Improved Seal of Righteousness Rank 2
      {id =20225, requiredIds ={20224}, isTalent =1},
      -- @Improved Lay on Hands Rank 1
      {id =20234, isTalent =1},
      -- @Improved Lay on Hands Rank 2
      {id =20235, requiredIds ={20234}, isTalent =1},
      -- @Healing Light Rank 1
      {id =20237, isTalent =1},
      -- @Healing Light Rank 2
      {id =20238, requiredIds ={20237}, isTalent =1},
      -- @Healing Light Rank 3
      {id =20239, requiredIds ={20238}, isTalent =1},
      -- @Improved Blessing of Wisdom Rank 1
      {id =20244, isTalent =1},
      -- @Improved Blessing of Wisdom Rank 2
      {id =20245, requiredIds ={20244}, isTalent =1},
      -- @Improved Concentration Aura Rank 1
      {id =20254, isTalent =1},
      -- @Improved Concentration Aura Rank 2
      {id =20255, requiredIds ={20254}, isTalent =1},
      -- @Improved Concentration Aura Rank 3
      {id =20256, requiredIds ={20255}, isTalent =1},
      -- @Divine Intellect Rank 1
      {id =20257, isTalent =1},
      -- @Divine Intellect Rank 2
      {id =20258, requiredIds ={20257}, isTalent =1},
      -- @Divine Intellect Rank 3
      {id =20259, requiredIds ={20258}, isTalent =1},
      -- @Divine Intellect Rank 4
      {id =20260, requiredIds ={20259}, isTalent =1},
      -- @Divine Intellect Rank 5
      {id =20261, requiredIds ={20260}, isTalent =1},
      -- @Divine Strength Rank 1
      {id =20262, isTalent =1},
      -- @Divine Strength Rank 2
      {id =20263, requiredIds ={20262}, isTalent =1},
      -- @Divine Strength Rank 3
      {id =20264, requiredIds ={20263}, isTalent =1},
      -- @Divine Strength Rank 4
      {id =20265, requiredIds ={20264}, isTalent =1},
      -- @Divine Strength Rank 5
      {id =20266, requiredIds ={20265}, isTalent =1},
      -- @Improved Seal of Righteousness Rank 3
      {id =20330, requiredIds ={20225}, isTalent =1},
      -- @Improved Seal of Righteousness Rank 4
      {id =20331, requiredIds ={20330}, isTalent =1},
      -- @Improved Seal of Righteousness Rank 5
      {id =20332, requiredIds ={20331}, isTalent =1},
      -- @Improved Seal of the Crusader Rank 1
      {id =20335, isTalent =1},
      -- @Improved Seal of the Crusader Rank 2
      {id =20336, requiredIds ={20335}, isTalent =1},
      -- @Improved Seal of the Crusader Rank 3
      {id =20337, requiredIds ={20336}, isTalent =1},
      -- @Lasting Judgement Rank 1
      {id =20359, isTalent =1},
      -- @Lasting Judgement Rank 2
      {id =20360, requiredIds ={20359}, isTalent =1},
      -- @Lasting Judgement Rank 3
      {id =20361, requiredIds ={20360}, isTalent =1},
      -- @Seal of Command Rank 1
      {id =20375, isTalent =1},
      -- @Improved Righteous Fury Rank 1
      {id =20468, isTalent =1},
      -- @Improved Righteous Fury Rank 2
      {id =20469, requiredIds ={20468}, isTalent =1},
      -- @Improved Righteous Fury Rank 3
      {id =20470, requiredIds ={20469}, isTalent =1},
      -- @Holy Shock Rank 1
      {id =20473, isTalent =1},
      -- @Improved Hammer of Justice Rank 1
      {id =20487, isTalent =1},
      -- @Improved Hammer of Justice Rank 2
      {id =20488, requiredIds ={20487}, isTalent =1},
      -- @Improved Hammer of Justice Rank 3
      {id =20489, requiredIds ={20488}, isTalent =1},
      -- @Blessing of Sanctuary Rank 1
      {id =20911, isTalent =1},
      -- @Holy Shield Rank 1
      {id =20925, isTalent =1},
      -- @Holy Power Rank 5
      {id =25829, requiredIds ={5926}, isTalent =1},
      -- @Unyielding Faith Rank 2
      {id =25836, requiredIds ={9453}, isTalent =1},
      -- @Improved Judgement Rank 1
      {id =25956, isTalent =1},
      -- @Improved Judgement Rank 2
      {id =25957, requiredIds ={25956}, isTalent =1},
      -- @Eye for an Eye Rank 2
      {id =25988, requiredIds ={9799}, isTalent =1},
      -- @Vindication Rank 2
      {id =26016, requiredIds ={9452}, isTalent =1},
      -- @Vindication Rank 3
      {id =26021, requiredIds ={26016}, isTalent =1},
      -- @Pursuit of Justice Rank 1
      {id =26022, isTalent =1},
      -- @Pursuit of Justice Rank 2
      {id =26023, requiredIds ={26022}, isTalent =1},
      -- @Consecration Rank 1
      {id =26573, isTalent =1},
      -- @Libram undefined
      {id =27762, isTalent =0},
       },
[1] = {
      -- @Block Passive
      {id =107, isTalent =0},
      -- @Devotion Aura Rank 1
      {id =465, cost =10, isTalent =0},
      -- @Holy Light Rank 1
      {id =635, isTalent =0},
      -- @Parry Passive
      {id =3127, isTalent =0},
      -- @Seal of Righteousness Rank 1
      {id =20154, isTalent =0},
      -- @Seal of Righteousness Rank 1
      {id =21084, isTalent =0},
       },
[4] = {
      -- @Blessing of Might Rank 1
      {id =19740, cost =100, isTalent =0},
      -- @Judgement undefined
      {id =20271, cost =100, isTalent =0},
       },
[6] = {
      -- @Divine Protection Rank 1
      {id =498, cost =100, isTalent =0},
      -- @Holy Light Rank 2
      {id =639, requiredIds ={635}, cost =100, isTalent =0},
      -- @Seal of the Crusader Rank 1
      {id =21082, cost =100, isTalent =0},
       },
[8] = {
      -- @Hammer of Justice Rank 1
      {id =853, cost =100, isTalent =0},
      -- @Purify undefined
      {id =1152, cost =100, isTalent =0},
       },
[10] = {
      -- @Lay on Hands Rank 1
      {id =633, cost =300, isTalent =0},
      -- @Blessing of Protection Rank 1
      {id =1022, cost =300, isTalent =0},
      -- @Devotion Aura Rank 2
      {id =10290, requiredIds ={465}, cost =300, isTalent =0},
      -- @Seal of Righteousness Rank 2
      {id =20287, requiredIds ={20154}, cost =300, isTalent =0},
       },
[12] = {
      -- @Redemption Rank 1
      {id =7328, isTalent =0},
      -- @Blessing of Might Rank 2
      {id =19834, requiredIds ={19740}, cost =1000, isTalent =0},
      -- @Seal of the Crusader Rank 2
      {id =20162, requiredIds ={21082}, cost =1000, isTalent =0},
       },
[14] = {
      -- @Holy Light Rank 3
      {id =647, requiredIds ={639}, cost =2000, isTalent =0},
      -- @Blessing of Wisdom Rank 1
      {id =19742, cost =2000, isTalent =0},
       },
[16] = {
      -- @Retribution Aura Rank 1
      {id =7294, cost =3000, isTalent =0},
      -- @Righteous Fury undefined
      {id =25780, cost =3000, isTalent =0},
       },
[18] = {
      -- @Blessing of Freedom undefined
      {id =1044, cost =3500, isTalent =0},
      -- @Divine Protection Rank 2
      {id =5573, requiredIds ={498}, cost =3500, isTalent =0},
      -- @Seal of Righteousness Rank 3
      {id =20288, requiredIds ={20287}, cost =3500, isTalent =0},
       },
[20] = {
      -- @Devotion Aura Rank 3
      {id =643, requiredIds ={10290}, cost =4000, isTalent =0},
      -- @Exorcism Rank 1
      {id =879, cost =4000, isTalent =0},
      -- @Sense Undead undefined
      {id =5502, isTalent =0},
      -- @Flash of Light Rank 1
      {id =19750, cost =4000, isTalent =0},
       },
[22] = {
      -- @Holy Light Rank 4
      {id =1026, requiredIds ={647}, cost =4000, isTalent =0},
      -- @Concentration Aura undefined
      {id =19746, cost =4000, isTalent =0},
      -- @Blessing of Might Rank 3
      {id =19835, requiredIds ={19834}, cost =4000, isTalent =0},
      -- @Seal of Justice undefined
      {id =20164, cost =4000, isTalent =0},
      -- @Seal of the Crusader Rank 3
      {id =20305, requiredIds ={20162}, cost =4000, isTalent =0},
       },
[24] = {
      -- @Turn Undead Rank 1
      {id =2878, cost =5000, isTalent =0},
      -- @Hammer of Justice Rank 2
      {id =5588, requiredIds ={853}, cost =5000, isTalent =0},
      -- @Blessing of Protection Rank 2
      {id =5599, requiredIds ={1022}, cost =5000, isTalent =0},
      -- @Redemption Rank 2
      {id =10322, requiredIds ={7328}, cost =5000, isTalent =0},
      -- @Blessing of Wisdom Rank 2
      {id =19850, requiredIds ={19742}, cost =5000, isTalent =0},
       },
[26] = {
      -- @Blessing of Salvation undefined
      {id =1038, cost =6000, isTalent =0},
      -- @Retribution Aura Rank 2
      {id =10298, requiredIds ={7294}, cost =6000, isTalent =0},
      -- @Flash of Light Rank 2
      {id =19939, requiredIds ={19750}, cost =6000, isTalent =0},
      -- @Seal of Righteousness Rank 4
      {id =20289, requiredIds ={20288}, cost =6000, isTalent =0},
       },
[28] = {
      -- @Exorcism Rank 2
      {id =5614, requiredIds ={879}, cost =9000, isTalent =0},
      -- @Shadow Resistance Aura Rank 1
      {id =19876, cost =9000, isTalent =0},
       },
[30] = {
      -- @Holy Light Rank 5
      {id =1042, requiredIds ={1026}, cost =11000, isTalent =0},
      -- @Lay on Hands Rank 2
      {id =2800, requiredIds ={633}, cost =11000, isTalent =0},
      -- @Devotion Aura Rank 4
      {id =10291, requiredIds ={643}, cost =11000, isTalent =0},
      -- @Divine Intervention undefined
      {id =19752, cost =11000, isTalent =0},
      -- @Consecration Rank 2
      {id =20116, requiredIds ={26573}, cost =200, isTalent =0},
      -- @Seal of Light Rank 1
      {id =20165, cost =11000, isTalent =0},
      -- @Seal of Command Rank 2
      {id =20915, requiredIds ={20375}, cost =550, isTalent =0},
       },
[32] = {
      -- @Blessing of Might Rank 4
      {id =19836, requiredIds ={19835}, cost =12000, isTalent =0},
      -- @Frost Resistance Aura Rank 1
      {id =19888, cost =12000, isTalent =0},
      -- @Seal of the Crusader Rank 4
      {id =20306, requiredIds ={20305}, cost =12000, isTalent =0},
       },
[34] = {
      -- @Divine Shield Rank 1
      {id =642, cost =13000, isTalent =0},
      -- @Blessing of Wisdom Rank 3
      {id =19852, requiredIds ={19850}, cost =13000, isTalent =0},
      -- @Flash of Light Rank 3
      {id =19940, requiredIds ={19939}, cost =13000, isTalent =0},
      -- @Seal of Righteousness Rank 5
      {id =20290, requiredIds ={20289}, cost =13000, isTalent =0},
       },
[36] = {
      -- @Exorcism Rank 3
      {id =5615, requiredIds ={5614}, cost =14000, isTalent =0},
      -- @Retribution Aura Rank 3
      {id =10299, requiredIds ={10298}, cost =14000, isTalent =0},
      -- @Redemption Rank 3
      {id =10324, requiredIds ={10322}, cost =14000, isTalent =0},
      -- @Fire Resistance Aura Rank 1
      {id =19891, cost =14000, isTalent =0},
       },
[38] = {
      -- @Holy Light Rank 6
      {id =3472, requiredIds ={1042}, cost =16000, isTalent =0},
      -- @Turn Undead Rank 2
      {id =5627, requiredIds ={2878}, cost =16000, isTalent =0},
      -- @Blessing of Protection Rank 3
      {id =10278, requiredIds ={5599}, cost =16000, isTalent =0},
      -- @Seal of Wisdom Rank 1
      {id =20166, cost =16000, isTalent =0},
       },
[40] = {
      -- @Devotion Aura Rank 5
      {id =1032, requiredIds ={10291}, cost =20000, isTalent =0},
      -- @Hammer of Justice Rank 3
      {id =5589, requiredIds ={5588}, cost =20000, isTalent =0},
      -- @Summon Warhorse Summon
      {id =13819, isTalent =0},
      -- @Shadow Resistance Aura Rank 2
      {id =19895, requiredIds ={19876}, cost =20000, isTalent =0},
      -- @Blessing of Light Rank 1
      {id =19977, cost =20000, isTalent =0},
      -- @Seal of Light Rank 2
      {id =20347, requiredIds ={20165}, cost =20000, isTalent =0},
      -- @Blessing of Sanctuary Rank 2
      {id =20912, requiredIds ={20911}, cost =1000, isTalent =0},
      -- @Seal of Command Rank 3
      {id =20918, requiredIds ={20915}, cost =1000, isTalent =0},
      -- @Consecration Rank 3
      {id =20922, requiredIds ={20116}, cost =1000, isTalent =0},
       },
[42] = {
      -- @Cleanse undefined
      {id =4987, cost =21000, isTalent =0},
      -- @Blessing of Might Rank 5
      {id =19837, requiredIds ={19836}, cost =21000, isTalent =0},
      -- @Flash of Light Rank 4
      {id =19941, requiredIds ={19940}, cost =21000, isTalent =0},
      -- @Seal of Righteousness Rank 6
      {id =20291, requiredIds ={20290}, cost =21000, isTalent =0},
      -- @Seal of the Crusader Rank 5
      {id =20307, requiredIds ={20306}, cost =21000, isTalent =0},
       },
[44] = {
      -- @Exorcism Rank 4
      {id =10312, requiredIds ={5615}, cost =22000, isTalent =0},
      -- @Blessing of Wisdom Rank 4
      {id =19853, requiredIds ={19852}, cost =22000, isTalent =0},
      -- @Frost Resistance Aura Rank 2
      {id =19897, requiredIds ={19888}, cost =22000, isTalent =0},
      -- @Hammer of Wrath Rank 1
      {id =24275, cost =22000, isTalent =0},
       },
[46] = {
      -- @Blessing of Sacrifice Rank 1
      {id =6940, cost =24000, isTalent =0},
      -- @Retribution Aura Rank 4
      {id =10300, requiredIds ={10299}, cost =24000, isTalent =0},
      -- @Holy Light Rank 7
      {id =10328, requiredIds ={3472}, cost =24000, isTalent =0},
       },
[48] = {
      -- @Fire Resistance Aura Rank 2
      {id =19899, requiredIds ={19891}, cost =26000, isTalent =0},
      -- @Seal of Wisdom Rank 2
      {id =20356, requiredIds ={20166}, cost =26000, isTalent =0},
      -- @Redemption Rank 4
      {id =20772, requiredIds ={10324}, cost =26000, isTalent =0},
      -- @Holy Shock Rank 2
      {id =20929, requiredIds ={20473}, cost =1300, isTalent =0},
       },
[50] = {
      -- @Divine Shield Rank 2
      {id =1020, requiredIds ={642}, cost =28000, isTalent =0},
      -- @Holy Wrath Rank 1
      {id =2812, cost =28000, isTalent =0},
      -- @Devotion Aura Rank 6
      {id =10292, requiredIds ={1032}, cost =28000, isTalent =0},
      -- @Lay on Hands Rank 3
      {id =10310, requiredIds ={2800}, cost =28000, isTalent =0},
      -- @Flash of Light Rank 5
      {id =19942, requiredIds ={19941}, cost =28000, isTalent =0},
      -- @Blessing of Light Rank 2
      {id =19978, requiredIds ={19977}, cost =28000, isTalent =0},
      -- @Seal of Righteousness Rank 7
      {id =20292, requiredIds ={20291}, cost =28000, isTalent =0},
      -- @Seal of Light Rank 3
      {id =20348, requiredIds ={20347}, cost =28000, isTalent =0},
      -- @Blessing of Sanctuary Rank 3
      {id =20913, requiredIds ={20912}, cost =1400, isTalent =0},
      -- @Seal of Command Rank 4
      {id =20919, requiredIds ={20918}, cost =1400, isTalent =0},
      -- @Consecration Rank 4
      {id =20923, requiredIds ={20922}, cost =1400, isTalent =0},
      -- @Holy Shield Rank 2
      {id =20927, requiredIds ={20925}, cost =1400, isTalent =0},
       },
[52] = {
      -- @Exorcism Rank 5
      {id =10313, requiredIds ={10312}, cost =34000, isTalent =0},
      -- @Turn Undead Rank 3
      {id =10326, requiredIds ={5627}, cost =34000, isTalent =0},
      -- @Blessing of Might Rank 6
      {id =19838, requiredIds ={19837}, cost =34000, isTalent =0},
      -- @Shadow Resistance Aura Rank 3
      {id =19896, requiredIds ={19895}, cost =34000, isTalent =0},
      -- @Seal of the Crusader Rank 6
      {id =20308, requiredIds ={20307}, cost =34000, isTalent =0},
      -- @Hammer of Wrath Rank 2
      {id =24274, requiredIds ={24275}, cost =34000, isTalent =0},
      -- @Greater Blessing of Might Rank 1
      {id =25782, cost =46000, isTalent =0},
       },
[54] = {
      -- @Hammer of Justice Rank 4
      {id =10308, requiredIds ={5589}, cost =40000, isTalent =0},
      -- @Holy Light Rank 8
      {id =10329, requiredIds ={10328}, cost =40000, isTalent =0},
      -- @Blessing of Wisdom Rank 5
      {id =19854, requiredIds ={19853}, cost =40000, isTalent =0},
      -- @Blessing of Sacrifice Rank 2
      {id =20729, requiredIds ={6940}, cost =40000, isTalent =0},
      -- @Greater Blessing of Wisdom Rank 1
      {id =25894, cost =46000, isTalent =0},
       },
[56] = {
      -- @Retribution Aura Rank 5
      {id =10301, requiredIds ={10300}, cost =42000, isTalent =0},
      -- @Frost Resistance Aura Rank 3
      {id =19898, requiredIds ={19897}, cost =42000, isTalent =0},
      -- @Holy Shock Rank 3
      {id =20930, requiredIds ={20929}, cost =2100, isTalent =0},
       },
[58] = {
      -- @Flash of Light Rank 6
      {id =19943, requiredIds ={19942}, cost =44000, isTalent =0},
      -- @Seal of Righteousness Rank 8
      {id =20293, requiredIds ={20292}, cost =44000, isTalent =0},
      -- @Seal of Wisdom Rank 3
      {id =20357, requiredIds ={20356}, cost =44000, isTalent =0},
       },
[60] = {
      -- @Devotion Aura Rank 7
      {id =10293, requiredIds ={10292}, cost =46000, isTalent =0},
      -- @Exorcism Rank 6
      {id =10314, requiredIds ={10313}, cost =46000, isTalent =0},
      -- @Holy Wrath Rank 2
      {id =10318, requiredIds ={2812}, cost =46000, isTalent =0},
      -- @Fire Resistance Aura Rank 3
      {id =19900, requiredIds ={19899}, cost =46000, isTalent =0},
      -- @Blessing of Light Rank 3
      {id =19979, requiredIds ={19978}, cost =46000, isTalent =0},
      -- @Seal of Light Rank 4
      {id =20349, requiredIds ={20348}, cost =46000, isTalent =0},
      -- @Redemption Rank 5
      {id =20773, requiredIds ={20772}, cost =46000, isTalent =0},
      -- @Blessing of Sanctuary Rank 4
      {id =20914, requiredIds ={20913}, cost =2300, isTalent =0},
      -- @Seal of Command Rank 5
      {id =20920, requiredIds ={20919}, cost =2300, isTalent =0},
      -- @Consecration Rank 5
      {id =20924, requiredIds ={20923}, cost =2300, isTalent =0},
      -- @Holy Shield Rank 3
      {id =20928, requiredIds ={20927}, cost =2300, isTalent =0},
      -- @Summon Charger Summon
      {id =23214, isTalent =0},
      -- @Hammer of Wrath Rank 3
      {id =24239, requiredIds ={24274}, cost =46000, isTalent =0},
      -- @Blessing of Wisdom Rank 6
      {id =25290, requiredIds ={19854}, isTalent =0},
      -- @Blessing of Might Rank 7
      {id =25291, requiredIds ={19838}, isTalent =0},
      -- @Holy Light Rank 9
      {id =25292, requiredIds ={10329}, isTalent =0},
      -- @Greater Blessing of Light Rank 1
      {id =25890, cost =46000, isTalent =0},
      -- @Greater Blessing of Salvation undefined
      {id =25895, cost =46000, isTalent =0},
      -- @Greater Blessing of Kings undefined
      {id =25898, cost =2300, isTalent =0},
      -- @Greater Blessing of Sanctuary Rank 1
      {id =25899, cost =2300, isTalent =0},
      -- @Greater Blessing of Might Rank 2
      {id =25916, requiredIds ={25782}, cost =46000, isTalent =0},
      -- @Greater Blessing of Wisdom Rank 2
      {id =25918, requiredIds ={25894}, cost =46000, isTalent =0}
        }
}
