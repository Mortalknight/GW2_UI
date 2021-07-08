local _, GW = ...

-- Food
local tableFood = {
   --Haste		Mastery		Crit		Versa		Int		Str 		Agi		Stam		Stam		Special
	[308474]=18,	[308504]=18,	[308430]=18,	[308509]=18,	[327704]=18,	[327701]=18,	[327705]=18,	[327702]=18,
    [308488]=30,	[308506]=30,	[308434]=30,	[308514]=30,	[327708]=30,	[327706]=30,	[327709]=30,	[308525]=30,	[327707]=30,	[308637]=30,
    [341449]=30,
}

local staminaFood = {[201638]=true,[259457]=true,[288075]=true,[288074]=true,[297119]=true,[297040]=true,}

local tableFlask = {
	--Stamina,	Main stat,
	[307187]=70,	[307185]=70,	[307166]=70,
}

local tablePotion = {
	[188024]=true,	--Run haste
	[250871]=true,	--Mana
	[252753]=true,	--Mana channel
	[250872]=true,	--Mana+hp

	[279152]=true,	--Agi
	[279151]=true,	--Int
	[279154]=true,	--Stamina
	[279153]=true,	--Str
	[251231]=true,	--Armor

	[298152]=true,	--Int
	[298146]=true,	--Agi
	[298153]=true,	--Stamina
	[298154]=true,	--Str
	[298155]=true,	--Armor

	[298225]=true,	--Potion of Empowered Proximity
	[298317]=true,	--Potion of Focused Resolve
	[300714]=true,	--Potion of Unbridled Fury
	[300741]=true,	--Potion of Wild Mending


	[251316]=true,	--Potion of Bursting Blood
	[269853]=true,	--Potion of Rising Death

	[250873]=true,	--Invis
	[250878]=true,	--Run haste
	[251143]=true,	--Fall

	[307159]=true,	--Agi
	[307162]=true,	--Int
	[307163]=true,	--Stam
	[307164]=true,	--Str
	[307160]=true,	--Armor

	[307161]=true,	--Mana sleep
	[307194]=true,	--Mana+hp
	[307193]=true,	--Mana

	[307497]=true,	--Potion of Deathly Fixation
	[307494]=true,	--Potion of Empowered Exorcisms
	[307496]=true,	--Potion of Divine Awakening
	[307495]=true,	--Potion of Phantom Fire
	[322302]=true,	--Potion of Sacrificial Anima
	[344314]=true,	--Run
	[307199]=true,	--Potion of Soul Purity
	[342890]=true,	--Potion of Unhindered Passing
	[307196]=true,	--Potion of Shadow Sight
	[307195]=true,	--Invis
}

local raidBuffs = {
	{ATTACK_POWER_TOOLTIP or "AP","WARRIOR",6673},
	{SPELL_STAT3_NAME or "Stamina","PRIEST",21562},
	{SPELL_STAT4_NAME or "Int","MAGE",1459},
}

local tableInt = {[1459]=true,}
local tableStamina = {[21562]=true,}
local ableAP = {[6673]=true,}

local tableVantus = {
	--uldir
	[269276] = 1,
	[269405] = 2,
	[269408] = 3,
	[269407] = 4,
	[269409] = 5,
	[269411] = 6,
	[269412] = 7,
	[269413] = 8,

	--ep
	[298622] = 1,
	[298640] = 2,
	[298642] = 3,
	[298643] = 4,
	[298644] = 5,
	[298645] = 6,
	[298646] = 7,
	[302914] = 8,

	--Nyl
	[306475] = 1,
	[306480] = 2,
	[306476] = 3,
	[306477] = 4,
	[306478] = 5,
	[306484] = 6,
	[306485] = 7,
	[306479] = 8,
	[313550] = 9,
	[313551] = 10,
	[313554] = 11,
	[313556] = 12,

	--CN
	[311445] = 1,
	[334132] = 2,
	[311448] = 3,
	[311446] = 4,
	[311447] = 5,
	[311449] = 6,
	[311450] = 7,
	[311451] = 8,
	[311452] = 9,
	[334131] = 10,

	--SoD
	[354384] = 1,
	[354385] = 2,
	[354386] = 3,
	[354387] = 4,
	[354388] = 5,
	[354389] = 6,
	[354390] = 7,
	[354391] = 8,
	[354392] = 9,
	[354393] = 10,
}