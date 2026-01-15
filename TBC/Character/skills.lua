local _, GW = ...

GW.Skills = {
    HUNTER = {
        [1] = {
            {1494, 10}, -- Track Beasts
        },
        [4] = {
            {1978, 100, rank=1}, -- Serpent Sting rank 1
            {13163, 100}, -- Aspect of the Monkey
        },
        [6] = {
            {1130, 100, rank=1}, -- Hunter's Mark rank 1
            {3044, 100, rank=1}, -- Arcane Shot rank 1
        },
        [8] = {
            {5116, 200}, -- Concussive Shot
            {14260, 200, req=2973, rank=2}, -- Raptor Strike rank 2
        },
        [10] = {
            {4195, 100, rank=1}, -- Great Stamina rank 1
            {13165, 400, rank=1}, -- Aspect of the Hawk rank 1
            {13549, 400, req=1978, rank=2}, -- Serpent Sting rank 2
            {19883, 400}, -- Track Humanoids
            {24547, 100, rank=1}, -- Natural Armor rank 1
            {14916, 100, req=2649, rank=2}, -- Growl rank 2
        },
        [12] = {
            {136, 600, rank=1}, -- Mend Pet rank 1
            {2974, 600, rank=1}, -- Wing Clip rank 1
            {4196, 1200, req=4195, rank=2}, -- Great Stamina rank 2
            {14281, 600, req=3044, rank=2}, -- Arcane Shot rank 2
            {20736, 600, rank=1}, -- Distracting Shot rank 1
            {24556, 1200, req=24547, rank=2}, -- Natural Armor rank 2
        },
        [14] = {
            {1002, 1200}, -- Eyes of the Beast
            {1513, 1200, rank=1}, -- Scare Beast rank 1
            {6197, 1200}, -- Eagle Eye
        },
        [16] = {
            {1495, 1800, rank=1}, -- Mongoose Bite rank 1
            {13795, 1800, rank=1}, -- Immolation Trap rank 1
            {14261, 1800, req=14260, rank=3}, -- Raptor Strike rank 3
        },
        [18] = {
            {2643, 2000, rank=1}, -- Multi-Shot rank 1
            {4197, 4000, req=4196, rank=3}, -- Great Stamina rank 3
            {13550, 2000, req=13549, rank=3}, -- Serpent Sting rank 3
            {14318, 2000, req=13165, rank=2}, -- Aspect of the Hawk rank 2
            {19884, 2000}, -- Track Undead
            {24557, 4000, req=24556, rank=3}, -- Natural Armor rank 3
        },
        [20] = {
            {781, 2200, rank=1}, -- Disengage rank 1
            {1499, 2200, rank=1}, -- Freezing Trap rank 1
            {3111, 2200, req=136, rank=2}, -- Mend Pet rank 2
            {5118, 2200}, -- Aspect of the Cheetah
            {14274, 2200, req=20736, rank=2}, -- Distracting Shot rank 2
            {14282, 2200, req=14281, rank=3}, -- Arcane Shot rank 3
            {14923, 4000, req=14916, rank=3}, -- Growl rank 3
            {24440, 4400, rank=1}, -- Fire Resistance rank 1
            {24475, 4400, rank=1}, -- Frost Resistance rank 1
            {24490, 4400, rank=1}, -- Shadow Resistance rank 1
            {24494, 4400, rank=1}, -- Nature Resistance rank 1
            {24495, 4400, rank=1}, -- Arcane Resistance rank 1
        },
        [22] = {
            {3043, 6000}, -- Scorpid Sting
            {14323, 6000, req=1130, rank=2}, -- Hunter's Mark rank 2
        },
        [24] = {
            {1462, 7000}, -- Beast Lore
            {4198, 14000, req=4197, rank=4}, -- Great Stamina rank 4
            {14262, 7000, req=14261, rank=4}, -- Raptor Strike rank 4
            {19885, 7000}, -- Track Hidden
            {24558, 14000, req=24557, rank=4}, -- Natural Armor rank 4
        },
        [26] = {
            {3045, 7000}, -- Rapid Fire
            {13551, 7000, req=13550, rank=4}, -- Serpent Sting rank 4
            {14302, 7000, req=13795, rank=2}, -- Immolation Trap rank 2
            {19880, 7000}, -- Track Elementals
        },
        [28] = {
            {3661, 8000, req=3111, rank=3}, -- Mend Pet rank 3
            {13809, 8000}, -- Frost Trap
            {14283, 8000, req=14282, rank=4}, -- Arcane Shot rank 4
            {14319, 8000, req=14318, rank=3}, -- Aspect of the Hawk rank 3
            {20900, 400, req=19434, rank=2}, -- Aimed Shot rank 2
        },
        [30] = {
            {4199, 16000, req=4198, rank=5}, -- Great Stamina rank 5
            {5384, 8000}, -- Feign Death
            {13161, 8000}, -- Aspect of the Beast
            {14269, 8000, req=1495, rank=2}, -- Mongoose Bite rank 2
            {14288, 8000, req=2643, rank=2}, -- Multi-Shot rank 2
            {14326, 8000, req=1513, rank=2}, -- Scare Beast rank 2
            {14924, 16000, req=14923, rank=4}, -- Growl rank 4
            {15629, 8000, req=14274, rank=3}, -- Distracting Shot rank 3
            {24441, 16000, req=24440, rank=2}, -- Fire Resistance rank 2
            {24476, 16000, req=24475, rank=2}, -- Frost Resistance rank 2
            {24508, 16000, req=24495, rank=2}, -- Arcane Resistance rank 2
            {24511, 16000, req=24494, rank=2}, -- Nature Resistance rank 2
            {24514, 16000, req=24490, rank=2}, -- Shadow Resistance rank 2
            {24559, 16000, req=24558, rank=5}, -- Natural Armor rank 5
            {25077, 2500}, -- Cobra Reflexes
            {35699, 3000, rank=1}, -- Avoidance rank 1
        },
        [32] = {
            {1543, 10000}, -- Flare
            {14263, 10000, req=14262, rank=5}, -- Raptor Strike rank 5
            {19878, 10000}, -- Track Demons
        },
        [34] = {
            {13552, 12000, req=13551, rank=5}, -- Serpent Sting rank 5
            {13813, 12000, rank=1}, -- Explosive Trap rank 1
            {14272, 12000, req=781, rank=2}, -- Disengage rank 2
        },
        [36] = {
            {3034, 14000, rank=1}, -- Viper Sting rank 1
            {3662, 14000, req=3661, rank=4}, -- Mend Pet rank 4
            {4200, 28000, req=4199, rank=6}, -- Great Stamina rank 6
            {14284, 14000, req=14283, rank=5}, -- Arcane Shot rank 5
            {14303, 14000, req=14302, rank=3}, -- Immolation Trap rank 3
            {20901, 700, req=20900, rank=3}, -- Aimed Shot rank 3
            {24560, 28000, req=24559, rank=6}, -- Natural Armor rank 6
        },
        [38] = {
            {14267, 16000, req=2974, rank=2}, -- Wing Clip rank 2
            {14320, 16000, req=14319, rank=4}, -- Aspect of the Hawk rank 4
        },
        [40] = {
            {1510, 18000, rank=1}, -- Volley rank 1
            {13159, 18000}, -- Aspect of the Pack
            {14264, 18000, req=14263, rank=6}, -- Raptor Strike rank 6
            {14310, 18000, req=1499, rank=2}, -- Freezing Trap rank 2
            {14324, 18000, req=14323, rank=3}, -- Hunter's Mark rank 3
            {14925, 36000, req=14924, rank=5}, -- Growl rank 5
            {15630, 18000, req=15629, rank=4}, -- Distracting Shot rank 4
            {19882, 18000}, -- Track Giants
            {24463, 36000, req=24441, rank=3}, -- Fire Resistance rank 3
            {24477, 36000, req=24476, rank=3}, -- Frost Resistance rank 3
            {24509, 36000, req=24508, rank=3}, -- Arcane Resistance rank 3
            {24512, 36000, req=24511, rank=3}, -- Nature Resistance rank 3
            {24515, 36000, req=24514, rank=3}, -- Shadow Resistance rank 3
        },
        [42] = {
            {4201, 48000, req=4200, rank=7}, -- Great Stamina rank 7
            {13553, 24000, req=13552, rank=6}, -- Serpent Sting rank 6
            {14289, 24000, req=14288, rank=3}, -- Multi-Shot rank 3
            {20909, 1200, req=19306, rank=2}, -- Counterattack rank 2
            {24561, 48000, req=24560, rank=7}, -- Natural Armor rank 7
        },
        [44] = {
            {13542, 26000, req=3662, rank=5}, -- Mend Pet rank 5
            {14270, 26000, req=14269, rank=3}, -- Mongoose Bite rank 3
            {14285, 26000, req=14284, rank=6}, -- Arcane Shot rank 6
            {14316, 26000, req=13813, rank=2}, -- Explosive Trap rank 2
            {20902, 1300, req=20901, rank=4}, -- Aimed Shot rank 4
        },
        [46] = {
            {14279, 28000, req=3034, rank=2}, -- Viper Sting rank 2
            {14304, 28000, req=14303, rank=4}, -- Immolation Trap rank 4
            {14327, 28000, req=14326, rank=3}, -- Scare Beast rank 3
            {20043, 28000, rank=1}, -- Aspect of the Wild rank 1
        },
        [48] = {
            {4202, 64000, req=4201, rank=8}, -- Great Stamina rank 8
            {14265, 32000, req=14264, rank=7}, -- Raptor Strike rank 7
            {14273, 32000, req=14272, rank=3}, -- Disengage rank 3
            {14321, 32000, req=14320, rank=5}, -- Aspect of the Hawk rank 5
            {24562, 64000, req=24561, rank=8}, -- Natural Armor rank 8
        },
        [50] = {
            {13554, 36000, req=13553, rank=7}, -- Serpent Sting rank 7
            {14294, 36000, req=1510, rank=2}, -- Volley rank 2
            {14926, 72000, req=14925, rank=6}, -- Growl rank 6
            {15631, 36000, req=15630, rank=5}, -- Distracting Shot rank 5
            {19879, 36000}, -- Track Dragonkin
            {20905, 1800, req=19506, rank=2}, -- Trueshot Aura rank 2
            {24132, 1800, req=19386, rank=2}, -- Wyvern Sting rank 2
            {24464, 72000, req=24463, rank=4}, -- Fire Resistance rank 4
            {24478, 72000, req=24477, rank=4}, -- Frost Resistance rank 4
            {24510, 72000, req=24509, rank=4}, -- Arcane Resistance rank 4
            {24513, 72000, req=24512, rank=4}, -- Nature Resistance rank 4
            {24516, 72000, req=24515, rank=4}, -- Shadow Resistance rank 4
        },
        [52] = {
            {13543, 40000, req=13542, rank=6}, -- Mend Pet rank 6
            {14286, 40000, req=14285, rank=7}, -- Arcane Shot rank 7
            {20903, 2000, req=20902, rank=5}, -- Aimed Shot rank 5
        },
        [54] = {
            {5048, 84000, req=4202, rank=9}, -- Great Stamina rank 9
            {14290, 42000, req=14289, rank=4}, -- Multi-Shot rank 4
            {14317, 42000, req=14316, rank=3}, -- Explosive Trap rank 3
            {20910, 2100, req=20909, rank=3}, -- Counterattack rank 3
            {24631, 84000, req=24562, rank=9}, -- Natural Armor rank 9
        },
        [56] = {
            {14266, 46000, req=14265, rank=8}, -- Raptor Strike rank 8
            {14280, 46000, req=14279, rank=3}, -- Viper Sting rank 3
            {14305, 46000, req=14304, rank=5}, -- Immolation Trap rank 5
            {20190, 46000, req=20043, rank=2}, -- Aspect of the Wild rank 2
        },
        [58] = {
            {13555, 48000, req=13554, rank=8}, -- Serpent Sting rank 8
            {14271, 48000, req=14270, rank=4}, -- Mongoose Bite rank 4
            {14295, 48000, req=14294, rank=3}, -- Volley rank 3
            {14322, 48000, req=14321, rank=6}, -- Aspect of the Hawk rank 6
            {14325, 48000, req=14324, rank=4}, -- Hunter's Mark rank 4
        },
        [60] = {
            {5049, 100000, rank=10}, -- Great Stamina rank 10
            {13544, 50000, req=13543, rank=7}, -- Mend Pet rank 7
            {14268, 50000, req=14267, rank=3}, -- Wing Clip rank 3
            {14287, 50000, req=14286, rank=8}, -- Arcane Shot rank 8
            {14311, 50000, req=14310, rank=3}, -- Freezing Trap rank 3
            {14927, 100000, req=14926, rank=7}, -- Growl rank 7
            {15632, 50000, req=15631, rank=6}, -- Distracting Shot rank 6
            {19801, 50000}, -- Tranquilizing Shot
            {20904, 2500, req=20903, rank=6}, -- Aimed Shot rank 6
            {20906, 2500, req=20905, rank=3}, -- Trueshot Aura rank 3
            {24133, 2500, req=24132, rank=3}, -- Wyvern Sting rank 3
            {24632, 100000, rank=10}, -- Natural Armor rank 10
            {25294, 50000, req=14290, rank=5}, -- Multi-Shot rank 5
            {25295, 50000, req=13555, rank=9}, -- Serpent Sting rank 9
            {25296, 50000, req=14322, rank=7}, -- Aspect of the Hawk rank 7
            {27350, 100000, req=24510, rank=5}, -- Arcane Resistance rank 5
            {27351, 100000, req=24464, rank=5}, -- Fire Resistance rank 5
            {27352, 100000, req=24478, rank=5}, -- Frost Resistance rank 5
            {27353, 100000, req=24516, rank=5}, -- Shadow Resistance rank 5
            {27354, 100000, req=24513, rank=5}, -- Nature Resistance rank 5
            {35700, 10000, req=35699, rank=2}, -- Avoidance rank 2
        },
        [61] = {
            {27025, 68000, req=14317, rank=4}, -- Explosive Trap rank 4
        },
        [62] = {
            {27015, 77000, req=14273, rank=4}, -- Disengage rank 4
            {34120, 77000, rank=1}, -- Steady Shot rank 1
        },
        [63] = {
            {27014, 87000, req=14266, rank=9}, -- Raptor Strike rank 9
        },
        [64] = {
            {34074, 100000}, -- Aspect of the Viper
        },
        [65] = {
            {27023, 110000, req=14305, rank=6}, -- Immolation Trap rank 6
        },
        [66] = {
            {27018, 120000, req=14280, rank=4}, -- Viper Sting rank 4
            {27067, 2500, req=20910, rank=4}, -- Counterattack rank 4
            {34026, 120000, rank=1}, -- Kill Command rank 1
        },
        [67] = {
            {27016, 140000, req=25295, rank=10}, -- Serpent Sting rank 10
            {27021, 140000, req=25294, rank=6}, -- Multi-Shot rank 6
            {27022, 140000, req=14295, rank=4}, -- Volley rank 4
        },
        [68] = {
            {27044, 150000, req=25296, rank=8}, -- Aspect of the Hawk rank 8
            {27045, 150000, req=20190, rank=3}, -- Aspect of the Wild rank 3
            {27046, 150000, req=13544, rank=8}, -- Mend Pet rank 8
            {34600, 150000}, -- Snake Trap
        },
        [69] = {
            {27019, 170000, req=14287, rank=9}, -- Arcane Shot rank 9
            {27020, 170000, req=15632, rank=7}, -- Distracting Shot rank 7
        },
        [70] = {
            {27065, 2700, req=20904, rank=7}, -- Aimed Shot rank 7
            {27066, 2700, req=20906, rank=4}, -- Trueshot Aura rank 4
            {27068, 2700, req=24133, rank=4}, -- Wyvern Sting rank 4
            {27344, 100000, req=14927, rank=8}, -- Growl rank 8
            {27362, 2700, rank=11}, -- Natural Armor rank 11
            {27364, 100000, req=5049, rank=11}, -- Great Stamina rank 11
            {34477, 190000}, -- Misdirection
            {36916, 190000, req=14271, rank=5}, -- Mongoose Bite rank 5
        },
    },
    WARRIOR = {
        [1] = {
            {6673, 10, rank=1}, -- Battle Shout rank 1
        },
        [4] = {
            {100, 100, rank=1}, -- Charge rank 1
            {772, 100, rank=1}, -- Rend rank 1
        },
        [6] = {
            {6343, 100, rank=1}, -- Thunder Clap rank 1
        },
        [8] = {
            {284, 200, req=78, rank=2}, -- Heroic Strike rank 2
            {1715, 200, rank=1}, -- Hamstring rank 1
            {3127, 100}, -- Parry  ----CHECK THIS
        },
        [10] = {
            {2687, 600}, -- Bloodrage
            {6546, 600, req=772, rank=2}, -- Rend rank 2
        },
        [12] = {
            {72, 1000, rank=1}, -- Shield Bash rank 1
            {5242, 1000, req=6673, rank=2}, -- Battle Shout rank 2
            {7384, 1000, rank=1}, -- Overpower rank 1
        },
        [14] = {
            {1160, 1500, rank=1}, -- Demoralizing Shout rank 1
            {6572, 1500, rank=1}, -- Revenge rank 1
        },
        [16] = {
            {285, 2000, req=284, rank=3}, -- Heroic Strike rank 3
            {694, 2000, rank=1}, -- Mocking Blow rank 1
            {2565, 2000}, -- Shield Block
        },
        [18] = {
            {676, 3000}, -- Disarm
            {8198, 3000, req=6343, rank=2}, -- Thunder Clap rank 2
        },
        [20] = {
            {674, 300}, -- Dual Wield
            {200, 10000}, -- Polearms
            {845, 4000, rank=1}, -- Cleave rank 1
            {6547, 4000, req=6546, rank=3}, -- Rend rank 3
            {12678, 4000}, -- Stance Mastery
            {20230, 4000}, -- Retaliation
        },
        [22] = {
            {5246, 6000}, -- Intimidating Shout
            {6192, 6000, req=5242, rank=3}, -- Battle Shout rank 3
            {7405, 6000, req=7386, rank=2}, -- Sunder Armor rank 2
        },
        [24] = {
            {1608, 8000, req=285, rank=4}, -- Heroic Strike rank 4
            {5308, 8000, rank=1}, -- Execute rank 1
            {6190, 8000, req=1160, rank=2}, -- Demoralizing Shout rank 2
            {6574, 8000, req=6572, rank=2}, -- Revenge rank 2
        },
        [26] = {
            {1161, 10000}, -- Challenging Shout
            {6178, 10000, req=100, rank=2}, -- Charge rank 2
            {7400, 10000, req=694, rank=2}, -- Mocking Blow rank 2
        },
        [28] = {
            {871, 11000}, -- Shield Wall
            {7887, 11000, req=7384, rank=2}, -- Overpower rank 2
            {8204, 11000, req=8198, rank=3}, -- Thunder Clap rank 3
        },
        [30] = {
            {1464, 12000, rank=1}, -- Slam rank 1
            {6548, 12000, req=6547, rank=4}, -- Rend rank 4
            {7369, 12000, req=845, rank=2}, -- Cleave rank 2
        },
        [32] = {
            {1671, 14000, req=72, rank=2}, -- Shield Bash rank 2
            {7372, 14000, req=1715, rank=2}, -- Hamstring rank 2
            {11549, 14000, req=6192, rank=4}, -- Battle Shout rank 4
            {11564, 14000, req=1608, rank=5}, -- Heroic Strike rank 5
            {18499, 14000}, -- Berserker Rage
            {20658, 14000, req=5308, rank=2}, -- Execute rank 2
        },
        [34] = {
            {7379, 16000, req=6574, rank=3}, -- Revenge rank 3
            {8380, 16000, req=7405, rank=3}, -- Sunder Armor rank 3
            {11554, 16000, req=6190, rank=3}, -- Demoralizing Shout rank 3
        },
        [36] = {
            {1680, 18000}, -- Whirlwind
            {7402, 18000, req=7400, rank=3}, -- Mocking Blow rank 3
        },
        [38] = {
            {6552, 20000, rank=1}, -- Pummel rank 1
            {8205, 20000, req=8204, rank=4}, -- Thunder Clap rank 4
            {8820, 20000, req=1464, rank=2}, -- Slam rank 2
        },
        [40] = {
            {750, 22000}, -- Plate Mail
            {11565, 22000, req=11564, rank=6}, -- Heroic Strike rank 6
            {11572, 22000, req=6548, rank=5}, -- Rend rank 5
            {11608, 22000, req=7369, rank=3}, -- Cleave rank 3
            {20660, 22000, req=20658, rank=3}, -- Execute rank 3
        },
        [42] = {
            {11550, 32000, req=11549, rank=5}, -- Battle Shout rank 5
            {20616, 32000, req=20252, rank=2}, -- Intercept rank 2
        },
        [44] = {
            {11555, 34000, req=11554, rank=4}, -- Demoralizing Shout rank 4
            {11584, 34000, req=7887, rank=3}, -- Overpower rank 3
            {11600, 34000, req=7379, rank=4}, -- Revenge rank 4
        },
        [46] = {
            {11578, 36000, req=6178, rank=3}, -- Charge rank 3
            {11596, 36000, req=8380, rank=4}, -- Sunder Armor rank 4
            {11604, 36000, req=8820, rank=3}, -- Slam rank 3
            {20559, 36000, req=7402, rank=4}, -- Mocking Blow rank 4
        },
        [48] = {
            {11566, 40000, req=11565, rank=7}, -- Heroic Strike rank 7
            {11580, 40000, req=8205, rank=5}, -- Thunder Clap rank 5
            {20661, 40000, req=20660, rank=4}, -- Execute rank 4
            {21551, 20000, rank=2}, -- Mortal Strike rank 2
            {23892, 2000, rank=2}, -- Bloodthirst rank 2
            {23923, 2000, rank=2}, -- Shield Slam rank 2
        },
        [50] = {
            {1719, 42000}, -- Recklessness
            {11573, 42000, req=11572, rank=6}, -- Rend rank 6
            {11609, 42000, req=11608, rank=4}, -- Cleave rank 4
        },
        [52] = {
            {1672, 54000, req=1671, rank=3}, -- Shield Bash rank 3
            {11551, 54000, req=11550, rank=6}, -- Battle Shout rank 6
            {20617, 54000, req=20616, rank=3}, -- Intercept rank 3
        },
        [54] = {
            {7373, 56000, req=7372, rank=3}, -- Hamstring rank 3
            {11556, 56000, req=11555, rank=5}, -- Demoralizing Shout rank 5
            {11601, 56000, req=11600, rank=5}, -- Revenge rank 5
            {11605, 56000, req=11604, rank=4}, -- Slam rank 4
            {21552, 28000, req=21551, rank=3}, -- Mortal Strike rank 3
            {23893, 2800, req=23892, rank=3}, -- Bloodthirst rank 3
            {23924, 2800, req=23923, rank=3}, -- Shield Slam rank 3
        },
        [56] = {
            {11567, 58000, req=11566, rank=8}, -- Heroic Strike rank 8
            {20560, 58000, req=20559, rank=5}, -- Mocking Blow rank 5
            {20662, 58000, req=20661, rank=5}, -- Execute rank 5
        },
        [58] = {
            {6554, 60000, req=6552, rank=2}, -- Pummel rank 2
            {11581, 60000, req=11580, rank=6}, -- Thunder Clap rank 6
            {11597, 60000, req=11596, rank=5}, -- Sunder Armor rank 5
        },
        [60] = {
            {11574, 62000, req=11573, rank=7}, -- Rend rank 7
            {11585, 65000, req=11584, rank=4}, -- Overpower rank 4
            {20569, 62000, req=11609, rank=5}, -- Cleave rank 5
            {21553, 31000, req=21552, rank=4}, -- Mortal Strike rank 4
            {23894, 3100, req=23893, rank=4}, -- Bloodthirst rank 4
            {23925, 3100, req=23924, rank=4}, -- Shield Slam rank 4
            {25286, 60000, req=11567, rank=9}, -- Heroic Strike rank 9
            {25288, 65000, req=11601, rank=6}, -- Revenge rank 6
            {25289, 65000, req=11551, rank=7}, -- Battle Shout rank 7
            {30016, 3100, rank=2}, -- Devastate rank 2
            {30030, 3100, rank=2}, -- Rampage rank 2
        },
        [61] = {
            {25241, 65000, req=11605, rank=5}, -- Slam rank 5
            {25272, 65000, req=20617, rank=4}, -- Intercept rank 4
        },
        [62] = {
            {25202, 65000, req=11556, rank=6}, -- Demoralizing Shout rank 6
            {34428, 58000, rank=1}, -- Victory Rush rank 1
        },
        [63] = {
            {25269, 65000, req=25288, rank=7}, -- Revenge rank 7
        },
        [64] = {
            {23920, 65000}, -- Spell Reflection
            {29704, 60000, req=1672, rank=4}, -- Shield Bash rank 4
        },
        [65] = {
            {25234, 65000, req=20662, rank=6}, -- Execute rank 6
            {25266, 65000, req=20560, rank=6}, -- Mocking Blow rank 6
        },
        [66] = {
            {25248, 32500, req=21553, rank=5}, -- Mortal Strike rank 5
            {25251, 3250, req=23894, rank=5}, -- Bloodthirst rank 5
            {25258, 3200, req=23925, rank=5}, -- Shield Slam rank 5
            {29707, 65000, req=25286, rank=10}, -- Heroic Strike rank 10
        },
        [67] = {
            {25212, 65000, req=7373, rank=4}, -- Hamstring rank 4
            {25225, 65000, req=11597, rank=6}, -- Sunder Armor rank 6
            {25264, 65000, req=11581, rank=7}, -- Thunder Clap rank 7
        },
        [68] = {
            {469, 65000, rank=1}, -- Commanding Shout rank 1
            {25208, 65000, req=11574, rank=8}, -- Rend rank 8
            {25231, 65000, req=20569, rank=6}, -- Cleave rank 6
        },
        [69] = {
            {2048, 65000, req=25289, rank=8}, -- Battle Shout rank 8
            {25242, 65000, req=25241, rank=6}, -- Slam rank 6
            {25275, 65000, req=25272, rank=5}, -- Intercept rank 5
        },
        [70] = {
            {3411, 65000}, -- Intervene
            {25203, 65000, req=25202, rank=7}, -- Demoralizing Shout rank 7
            {25236, 65000, req=25234, rank=7}, -- Execute rank 7
            {30022, 2762, req=30016, rank=3}, -- Devastate rank 3
            {30033, 2762, req=30030, rank=3}, -- Rampage rank 3
            {30330, 2762, req=25248, rank=6}, -- Mortal Strike rank 6
            {30335, 2762, req=25251, rank=6}, -- Bloodthirst rank 6
            {30356, 2762, req=25258, rank=6}, -- Shield Slam rank 6
            {30357, 65000, req=25269, rank=8}, -- Revenge rank 8
        },
    },
    PALADIN = {
        [1] = {
            {465, 10, rank=1}, -- Devotion Aura rank 1
        },
        [4] = {
            {19740, 100, rank=1}, -- Blessing of Might rank 1
            {20271, 100, rank=1}, -- Judgement rank 1
        },
        [6] = {
            {498, 100, rank=1}, -- Divine Protection rank 1
            {639, 100, req=635, rank=2}, -- Holy Light rank 2
            {21082, 100, rank=1}, -- Seal of the Crusader rank 1
        },
        [8] = {
            {853, 100, rank=1}, -- Hammer of Justice rank 1
            {1152, 100}, -- Purify
        },
        [10] = {
            {633, 300, rank=1}, -- Lay on Hands rank 1
            {1022, 300, rank=1}, -- Blessing of Protection rank 1
            {10290, 300, req=465, rank=2}, -- Devotion Aura rank 2
            {20287, 300, req=21084, rank=2}, -- Seal of Righteousness rank 2
        },
        [12] = {
            {19834, 1000, req=19740, rank=2}, -- Blessing of Might rank 2
            {20162, 1000, req=21082, rank=2}, -- Seal of the Crusader rank 2
        },
        [14] = {
            {647, 2000, req=639, rank=3}, -- Holy Light rank 3
            {19742, 2000, rank=1}, -- Blessing of Wisdom rank 1
            {31789, 4000}, -- Righteous Defense
        },
        [16] = {
            {7294, 3000, rank=1}, -- Retribution Aura rank 1
            {25780, 3000}, -- Righteous Fury
        },
        [18] = {
            {1044, 3500}, -- Blessing of Freedom
            {5573, 3500, req=498, rank=2}, -- Divine Protection rank 2
            {20288, 3500, req=20287, rank=3}, -- Seal of Righteousness rank 3
            {31785, 3500, rank=1}, -- Spiritual Attunement rank 1
        },
        [20] = {
            {643, 4000, req=10290, rank=3}, -- Devotion Aura rank 3
            {879, 4000, rank=1}, -- Exorcism rank 1
            {19750, 4000, rank=1}, -- Flash of Light rank 1
            {26573, 4000, rank=1}, -- Consecration rank 1
        },
        [22] = {
            {1026, 4000, req=647, rank=4}, -- Holy Light rank 4
            {19746, 4000}, -- Concentration Aura
            {19835, 4000, req=19834, rank=3}, -- Blessing of Might rank 3
            {20164, 4000, rank=1}, -- Seal of Justice rank 1
            {20305, 4000, req=20162, rank=3}, -- Seal of the Crusader rank 3
        },
        [24] = {
            {2878, 5000, rank=1}, -- Turn Undead rank 1
            {5588, 5000, req=853, rank=2}, -- Hammer of Justice rank 2
            {5599, 5000, req=1022, rank=2}, -- Blessing of Protection rank 2
            {10322, 5000, req=7328, rank=2}, -- Redemption rank 2
            {19850, 5000, req=19742, rank=2}, -- Blessing of Wisdom rank 2
        },
        [26] = {
            {1038, 6000, rank=1}, -- Blessing of Salvation rank 1
            {10298, 6000, req=7294, rank=2}, -- Retribution Aura rank 2
            {19939, 6000, req=19750, rank=2}, -- Flash of Light rank 2
            {20289, 6000, req=20288, rank=4}, -- Seal of Righteousness rank 4
        },
        [28] = {
            {5614, 9000, req=879, rank=2}, -- Exorcism rank 2
            {19876, 9000, rank=1}, -- Shadow Resistance Aura rank 1
        },
        [30] = {
            {1042, 11000, req=1026, rank=5}, -- Holy Light rank 5
            {2800, 11000, req=633, rank=2}, -- Lay on Hands rank 2
            {10291, 11000, req=643, rank=4}, -- Devotion Aura rank 4
            {13819, 10000, faction="Alliance"}, -- Summon Warhorse
            {19752, 11000}, -- Divine Intervention
            {20116, 200, req=26573, rank=2}, -- Consecration rank 2
            {20165, 11000, rank=1}, -- Seal of Light rank 1
            {20915, 550, req=20375, rank=2}, -- Seal of Command rank 2
            {34769, 9000, faction="Horde"}, -- Summon Warhorse
        },
        [32] = {
            {19836, 12000, req=19835, rank=4}, -- Blessing of Might rank 4
            {19888, 12000, rank=1}, -- Frost Resistance Aura rank 1
            {20306, 12000, req=20305, rank=4}, -- Seal of the Crusader rank 4
        },
        [34] = {
            {642, 13000, rank=1}, -- Divine Shield rank 1
            {19852, 13000, req=19850, rank=3}, -- Blessing of Wisdom rank 3
            {19940, 13000, req=19939, rank=3}, -- Flash of Light rank 3
            {20290, 13000, req=20289, rank=5}, -- Seal of Righteousness rank 5
        },
        [36] = {
            {5615, 14000, req=5614, rank=3}, -- Exorcism rank 3
            {10299, 14000, req=10298, rank=3}, -- Retribution Aura rank 3
            {10324, 14000, req=10322, rank=3}, -- Redemption rank 3
            {19891, 14000, rank=1}, -- Fire Resistance Aura rank 1
        },
        [38] = {
            {3472, 16000, req=1042, rank=6}, -- Holy Light rank 6
            {5627, 16000, req=2878, rank=2}, -- Turn Undead rank 2
            {10278, 16000, req=5599, rank=3}, -- Blessing of Protection rank 3
            {20166, 16000, rank=1}, -- Seal of Wisdom rank 1
        },
        [40] = {
            {750, 22000}, -- Plate Mail
            {1032, 20000, req=10291, rank=5}, -- Devotion Aura rank 5
            {5589, 20000, req=5588, rank=3}, -- Hammer of Justice rank 3
            {19895, 20000, req=19876, rank=2}, -- Shadow Resistance Aura rank 2
            {19977, 20000, rank=1}, -- Blessing of Light rank 1
            {20347, 20000, req=20165, rank=2}, -- Seal of Light rank 2
            {20912, 1000, req=20911, rank=2}, -- Blessing of Sanctuary rank 2
            {20918, 1000, req=20915, rank=3}, -- Seal of Command rank 3
            {20922, 1000, req=20116, rank=3}, -- Consecration rank 3
        },
        [42] = {
            {4987, 21000}, -- Cleanse
            {19837, 21000, req=19836, rank=5}, -- Blessing of Might rank 5
            {19941, 21000, req=19940, rank=4}, -- Flash of Light rank 4
            {20291, 21000, req=20290, rank=6}, -- Seal of Righteousness rank 6
            {20307, 21000, req=20306, rank=5}, -- Seal of the Crusader rank 5
        },
        [44] = {
            {10312, 22000, req=5615, rank=4}, -- Exorcism rank 4
            {19853, 22000, req=19852, rank=4}, -- Blessing of Wisdom rank 4
            {19897, 22000, req=19888, rank=2}, -- Frost Resistance Aura rank 2
            {24275, 22000, rank=1}, -- Hammer of Wrath rank 1
        },
        [46] = {
            {6940, 24000, rank=1}, -- Blessing of Sacrifice rank 1
            {10300, 24000, req=10299, rank=4}, -- Retribution Aura rank 4
            {10328, 24000, req=3472, rank=7}, -- Holy Light rank 7
        },
        [48] = {
            {19899, 26000, req=19891, rank=2}, -- Fire Resistance Aura rank 2
            {20356, 26000, req=20166, rank=2}, -- Seal of Wisdom rank 2
            {20772, 26000, req=10324, rank=4}, -- Redemption rank 4
            {20929, 1300, req=20473, rank=2}, -- Holy Shock rank 2
            {31895, 26000, req=20164, rank=2}, -- Seal of Justice rank 2
        },
        [50] = {
            {1020, 28000, req=642, rank=2}, -- Divine Shield rank 2
            {2812, 28000, rank=1}, -- Holy Wrath rank 1
            {10292, 28000, req=1032, rank=6}, -- Devotion Aura rank 6
            {10310, 28000, req=2800, rank=3}, -- Lay on Hands rank 3
            {19942, 25000, req=19941, rank=5}, -- Flash of Light rank 5
            {19978, 28000, req=19977, rank=2}, -- Blessing of Light rank 2
            {20292, 28000, req=20291, rank=7}, -- Seal of Righteousness rank 7
            {20348, 28000, req=20347, rank=3}, -- Seal of Light rank 3
            {20913, 1400, req=20912, rank=3}, -- Blessing of Sanctuary rank 3
            {20919, 1400, req=20918, rank=4}, -- Seal of Command rank 4
            {20923, 1400, req=20922, rank=4}, -- Consecration rank 4
            {20927, 1400, req=20925, rank=2}, -- Holy Shield rank 2
        },
        [52] = {
            {10313, 34000, req=10312, rank=5}, -- Exorcism rank 5
            {10326, 34000, rank=1}, -- Turn Evil rank 1
            {19838, 34000, req=19837, rank=6}, -- Blessing of Might rank 6
            {19896, 34000, req=19895, rank=3}, -- Shadow Resistance Aura rank 3
            {20308, 34000, req=20307, rank=6}, -- Seal of the Crusader rank 6
            {24274, 34000, req=24275, rank=2}, -- Hammer of Wrath rank 2
            {25782, 46000, rank=1}, -- Greater Blessing of Might rank 1
        },
        [54] = {
            {10308, 40000, req=5589, rank=4}, -- Hammer of Justice rank 4
            {10329, 40000, req=10328, rank=8}, -- Holy Light rank 8
            {19854, 40000, req=19853, rank=5}, -- Blessing of Wisdom rank 5
            {20729, 40000, req=6940, rank=2}, -- Blessing of Sacrifice rank 2
            {25894, 46000, rank=1}, -- Greater Blessing of Wisdom rank 1
        },
        [56] = {
            {10301, 42000, req=10300, rank=5}, -- Retribution Aura rank 5
            {19898, 42000, req=19897, rank=3}, -- Frost Resistance Aura rank 3
            {20930, 2100, req=20929, rank=3}, -- Holy Shock rank 3
        },
        [58] = {
            {19943, 44000, req=19942, rank=6}, -- Flash of Light rank 6
            {20293, 44000, req=20292, rank=8}, -- Seal of Righteousness rank 8
            {20357, 44000, req=20356, rank=3}, -- Seal of Wisdom rank 3
        },
        [60] = {
            {10293, 46000, req=10292, rank=7}, -- Devotion Aura rank 7
            {10314, 46000, req=10313, rank=6}, -- Exorcism rank 6
            {10318, 46000, req=2812, rank=2}, -- Holy Wrath rank 2
            {19900, 46000, req=19899, rank=3}, -- Fire Resistance Aura rank 3
            {19979, 46000, req=19978, rank=3}, -- Blessing of Light rank 3
            {20349, 46000, req=20348, rank=4}, -- Seal of Light rank 4
            {20773, 46000, req=20772, rank=5}, -- Redemption rank 5
            {20914, 2300, req=20913, rank=4}, -- Blessing of Sanctuary rank 4
            {20920, 2300, req=20919, rank=5}, -- Seal of Command rank 5
            {20924, 2300, req=20923, rank=5}, -- Consecration rank 5
            {20928, 2300, req=20927, rank=3}, -- Holy Shield rank 3
            {24239, 46000, req=24274, rank=3}, -- Hammer of Wrath rank 3
            {25290, 50000, req=19854, rank=6}, -- Blessing of Wisdom rank 6
            {25291, 50000, req=19838, rank=7}, -- Blessing of Might rank 7
            {25292, 46000, req=10329, rank=9}, -- Holy Light rank 9
            {25890, 46000, rank=1}, -- Greater Blessing of Light rank 1
            {25895, 46000, rank=1}, -- Greater Blessing of Salvation rank 1
            {25898, 2300, rank=1}, -- Greater Blessing of Kings rank 1
            {25899, 2300, rank=1}, -- Greater Blessing of Sanctuary rank 1
            {25916, 46000, req=25782, rank=2}, -- Greater Blessing of Might rank 2
            {25918, 46000, req=25894, rank=2}, -- Greater Blessing of Wisdom rank 2
            {32699, 2300, req=31935, rank=2}, -- Avenger's Shield rank 2
        },
        [61] = {
            {27158, 50000, req=20308, rank=7}, -- Seal of the Crusader rank 7
        },
        [62] = {
            {27135, 55000, req=25292, rank=10}, -- Holy Light rank 10
            {27147, 55000, req=20729, rank=3}, -- Blessing of Sacrifice rank 3
            {32223, 55000}, -- Crusader Aura
        },
        [63] = {
            {27151, 61000, req=19896, rank=4}, -- Shadow Resistance Aura rank 4
        },
        [64] = {
            {27174, 3350, req=20930, rank=4}, -- Holy Shock rank 4
            {31801, 67000, rank=1, faction="Alliance"}, -- Seal of Vengeance rank 1
            {31892, 67000, rank=1, faction="Horde"}, -- Seal of Blood rank 1
        },
        [65] = {
            {27142, 75000, req=25290, rank=7}, -- Blessing of Wisdom rank 7
            {27143, 75000, req=25918, rank=3}, -- Greater Blessing of Wisdom rank 3
        },
        [66] = {
            {27137, 83000, req=19943, rank=7}, -- Flash of Light rank 7
            {27150, 83000, req=10301, rank=6}, -- Retribution Aura rank 6
            {27155, 83000, req=20293, rank=9}, -- Seal of Righteousness rank 9
            {33776, 83000, req=31785, rank=2}, -- Spiritual Attunement rank 2
        },
        [67] = {
            {27166, 92000, req=20357, rank=4}, -- Seal of Wisdom rank 4
        },
        [68] = {
            {27138, 100000, req=10314, rank=7}, -- Exorcism rank 7
            {27152, 100000, req=19898, rank=4}, -- Frost Resistance Aura rank 4
            {27180, 100000, req=24239, rank=4}, -- Hammer of Wrath rank 4
        },
        [69] = {
            {27139, 110000, req=10318, rank=3}, -- Holy Wrath rank 3
            {27144, 110000, req=19979, rank=4}, -- Blessing of Light rank 4
            {27145, 110000, req=25890, rank=2}, -- Greater Blessing of Light rank 2
            {27154, 110000, req=10310, rank=4}, -- Lay on Hands rank 4
            {27160, 110000, req=20349, rank=5}, -- Seal of Light rank 5
        },
        [70] = {
            {27136, 130000, req=27135, rank=11}, -- Holy Light rank 11
            {27140, 50000, req=25291, rank=8}, -- Blessing of Might rank 8
            {27141, 46000, req=25916, rank=3}, -- Greater Blessing of Might rank 3
            {27148, 130000, req=27147, rank=4}, -- Blessing of Sacrifice rank 4
            {27149, 130000, req=10293, rank=8}, -- Devotion Aura rank 8
            {27153, 130000, req=19900, rank=4}, -- Fire Resistance Aura rank 4
            {27168, 2300, req=20914, rank=5}, -- Blessing of Sanctuary rank 5
            {27169, 2300, req=25899, rank=2}, -- Greater Blessing of Sanctuary rank 2
            {27170, 2300, req=20920, rank=6}, -- Seal of Command rank 6
            {27173, 2300, req=20924, rank=6}, -- Consecration rank 6
            {27179, 2300, req=20928, rank=4}, -- Holy Shield rank 4
            {31884, 130000}, -- Avenging Wrath
            {32700, 2300, req=32699, rank=3}, -- Avenger's Shield rank 3
            {33072, 6500, req=27174, rank=5}, -- Holy Shock rank 5
            {348704, 67000, rank=1, faction="Horde"}, -- Seal of Corruption rank 1
            {348700, 67000, rank=1, faction="Alliance"}, -- Seal of the Martyr rank 1
        },
    },
    MAGE = {
        [1] = {
            {1459, 10, rank=1}, -- Arcane Intellect rank 1
        },
        [4] = {
            {116, 100, rank=1}, -- Frostbolt rank 1
            {5504, 100, rank=1}, -- Conjure Water rank 1
        },
        [6] = {
            {143, 100, req=133, rank=2}, -- Fireball rank 2
            {587, 100, rank=1}, -- Conjure Food rank 1
            {2136, 100, rank=1}, -- Fire Blast rank 1
        },
        [8] = {
            {118, 200, rank=1}, -- Polymorph rank 1
            {205, 200, req=116, rank=2}, -- Frostbolt rank 2
            {5143, 200, rank=1}, -- Arcane Missiles rank 1
        },
        [10] = {
            {122, 400, rank=1}, -- Frost Nova rank 1
            {5505, 400, req=5504, rank=2}, -- Conjure Water rank 2
            {7300, 400, req=168, rank=2}, -- Frost Armor rank 2
        },
        [12] = {
            {130, 600}, -- Slow Fall
            {145, 600, req=143, rank=3}, -- Fireball rank 3
            {597, 600, req=587, rank=2}, -- Conjure Food rank 2
            {604, 600, rank=1}, -- Dampen Magic rank 1
        },
        [14] = {
            {837, 900, req=205, rank=3}, -- Frostbolt rank 3
            {1449, 900, rank=1}, -- Arcane Explosion rank 1
            {1460, 900, req=1459, rank=2}, -- Arcane Intellect rank 2
            {2137, 900, req=2136, rank=2}, -- Fire Blast rank 2
        },
        [16] = {
            {2120, 1500, rank=1}, -- Flamestrike rank 1
            {5144, 1500, req=5143, rank=2}, -- Arcane Missiles rank 2
        },
        [18] = {
            {475, 1800}, -- Remove Lesser Curse
            {1008, 1800, rank=1}, -- Amplify Magic rank 1
            {3140, 1800, req=145, rank=4}, -- Fireball rank 4
        },
        [20] = {
            {10, 2000, rank=1}, -- Blizzard rank 1
            {543, 2000, rank=1}, -- Fire Ward rank 1
            {1463, 2000, rank=1}, -- Mana Shield rank 1
            {1953, 2000}, -- Blink
            {3561, 2000, faction="Alliance"}, -- Teleport: Stormwind
            {3562, 2000, faction="Alliance"}, -- Teleport: Ironforge
            {32271, 1900, faction="Alliance"}, -- Teleport: Exodar
            {3567, 2000, faction="Horde"}, -- Teleport: Orgrimmar
            {32272, 2000, faction="Horde"}, -- Teleport: Silvermoon
            {3563, 2000, faction="Horde"}, -- Teleport: Undercity
            {5506, 2000, req=5505, rank=3}, -- Conjure Water rank 3
            {7301, 2000, req=7300, rank=3}, -- Frost Armor rank 3
            {7322, 2000, req=837, rank=4}, -- Frostbolt rank 4
            {12051, 2000}, -- Evocation
            {12824, 2000, req=118, rank=2}, -- Polymorph rank 2
        },
        [22] = {
            {990, 3000, req=597, rank=3}, -- Conjure Food rank 3
            {2138, 3000, req=2137, rank=3}, -- Fire Blast rank 3
            {2948, 3000, rank=1}, -- Scorch rank 1
            {6143, 3000, rank=1}, -- Frost Ward rank 1
            {8437, 3000, req=1449, rank=2}, -- Arcane Explosion rank 2
        },
        [24] = {
            {2121, 4000, req=2120, rank=2}, -- Flamestrike rank 2
            {2139, 4000}, -- Counterspell
            {5145, 4000, req=5144, rank=3}, -- Arcane Missiles rank 3
            {8400, 4000, req=3140, rank=5}, -- Fireball rank 5
            {8450, 4000, req=604, rank=2}, -- Dampen Magic rank 2
            {12505, 200, req=11366, rank=2}, -- Pyroblast rank 2
        },
        [26] = {
            {120, 5000, rank=1}, -- Cone of Cold rank 1
            {865, 5000, req=122, rank=2}, -- Frost Nova rank 2
            {8406, 5000, req=7322, rank=5}, -- Frostbolt rank 5
        },
        [28] = {
            {759, 7000}, -- Conjure Mana Agate
            {1461, 7000, req=1460, rank=3}, -- Arcane Intellect rank 3
            {6141, 7000, req=10, rank=2}, -- Blizzard rank 2
            {8444, 7000, req=2948, rank=2}, -- Scorch rank 2
            {8494, 7000, req=1463, rank=2}, -- Mana Shield rank 2
        },
        [30] = {
            {3565, 8000, faction="Alliance"}, -- Teleport: Darnassus
            {3566, 8000, faction="Horde"}, -- Teleport: Thunder Bluff
            {6127, 8000, req=5506, rank=4}, -- Conjure Water rank 4
            {7302, 8000, rank=1}, -- Ice Armor rank 1
            {8401, 8000, req=8400, rank=6}, -- Fireball rank 6
            {8412, 8000, req=2138, rank=4}, -- Fire Blast rank 4
            {8438, 8000, req=8437, rank=3}, -- Arcane Explosion rank 3
            {8455, 8000, req=1008, rank=2}, -- Amplify Magic rank 2
            {8457, 8000, req=543, rank=2}, -- Fire Ward rank 2
            {12522, 400, req=12505, rank=3}, -- Pyroblast rank 3
            {45438, 8000}, -- Ice Block
        },
        [32] = {
            {6129, 10000, req=990, rank=4}, -- Conjure Food rank 4
            {8407, 10000, req=8406, rank=6}, -- Frostbolt rank 6
            {8416, 10000, req=5145, rank=4}, -- Arcane Missiles rank 4
            {8422, 10000, req=2121, rank=3}, -- Flamestrike rank 3
            {8461, 10000, req=6143, rank=2}, -- Frost Ward rank 2
        },
        [34] = {
            {6117, 13000, rank=1}, -- Mage Armor rank 1
            {8445, 12000, req=8444, rank=3}, -- Scorch rank 3
            {8492, 12000, req=120, rank=2}, -- Cone of Cold rank 2
        },
        [35] = {
            {49360, 15000, faction="Alliance"}, -- Portal: Theramore
            {49359, 2000, faction="Alliance"}, -- Teleport: Theramore
            {49361, 15000, faction="Horde"}, -- Portal: Stonard
            {49358, 2000, faction="Horde"}, -- Teleport: Stonard
        },
        [36] = {
            {8402, 13000, req=8401, rank=7}, -- Fireball rank 7
            {8427, 13000, req=6141, rank=3}, -- Blizzard rank 3
            {8451, 13000, req=8450, rank=3}, -- Dampen Magic rank 3
            {8495, 13000, req=8494, rank=3}, -- Mana Shield rank 3
            {12523, 650, req=12522, rank=4}, -- Pyroblast rank 4
            {13018, 650, req=11113, rank=2}, -- Blast Wave rank 2
        },
        [38] = {
            {3552, 14000}, -- Conjure Mana Jade
            {8408, 14000, req=8407, rank=7}, -- Frostbolt rank 7
            {8413, 14000, req=8412, rank=5}, -- Fire Blast rank 5
            {8439, 14000, req=8438, rank=4}, -- Arcane Explosion rank 4
        },
        [40] = {
            {6131, 15000, req=865, rank=3}, -- Frost Nova rank 3
            {7320, 15000, req=7302, rank=2}, -- Ice Armor rank 2
            {8417, 15000, req=8416, rank=5}, -- Arcane Missiles rank 5
            {8423, 15000, req=8422, rank=4}, -- Flamestrike rank 4
            {8446, 15000, req=8445, rank=4}, -- Scorch rank 4
            {8458, 15000, req=8457, rank=3}, -- Fire Ward rank 3
            {10138, 15000, req=6127, rank=5}, -- Conjure Water rank 5
            {12825, 15000, req=12824, rank=3}, -- Polymorph rank 3
            {10059, 15000, faction="Alliance"}, -- Portal: Stormwind
            {11416, 15000, faction="Alliance"}, -- Portal: Ironforge
            {32266, 14250, faction="Alliance"}, -- Portal: Exodar
            {11417, 15000, faction="Horde"}, -- Portal: Orgrimmar
            {32267, 15000, faction="Horde"}, -- Portal: Silvermoon
            {11418, 15000, faction="Horde"}, -- Portal: Undercity
        },
        [42] = {
            {8462, 18000, req=8461, rank=3}, -- Frost Ward rank 3
            {10144, 18000, req=6129, rank=5}, -- Conjure Food rank 5
            {10148, 18000, req=8402, rank=8}, -- Fireball rank 8
            {10156, 18000, req=1461, rank=4}, -- Arcane Intellect rank 4
            {10159, 18000, req=8492, rank=3}, -- Cone of Cold rank 3
            {10169, 18000, req=8455, rank=3}, -- Amplify Magic rank 3
            {12524, 900, req=12523, rank=5}, -- Pyroblast rank 5
        },
        [44] = {
            {10179, 23000, req=8408, rank=8}, -- Frostbolt rank 8
            {10185, 23000, req=8427, rank=4}, -- Blizzard rank 4
            {10191, 23000, req=8495, rank=4}, -- Mana Shield rank 4
            {13019, 1150, req=13018, rank=3}, -- Blast Wave rank 3
        },
        [46] = {
            {10197, 26000, req=8413, rank=6}, -- Fire Blast rank 6
            {10201, 26000, req=8439, rank=5}, -- Arcane Explosion rank 5
            {10205, 26000, req=8446, rank=5}, -- Scorch rank 5
            {13031, 1300, req=11426, rank=2}, -- Ice Barrier rank 2
            {22782, 28000, req=6117, rank=2}, -- Mage Armor rank 2
        },
        [48] = {
            {10053, 28000}, -- Conjure Mana Citrine
            {10149, 28000, req=10148, rank=9}, -- Fireball rank 9
            {10173, 28000, req=8451, rank=4}, -- Dampen Magic rank 4
            {10211, 28000, req=8417, rank=6}, -- Arcane Missiles rank 6
            {10215, 28000, req=8423, rank=5}, -- Flamestrike rank 5
            {12525, 1400, req=12524, rank=6}, -- Pyroblast rank 6
        },
        [50] = {
            {10139, 32000, req=10138, rank=6}, -- Conjure Water rank 6
            {10160, 32000, req=10159, rank=4}, -- Cone of Cold rank 4
            {10180, 32000, req=10179, rank=9}, -- Frostbolt rank 9
            {10219, 32000, req=7320, rank=3}, -- Ice Armor rank 3
            {10223, 32000, req=8458, rank=4}, -- Fire Ward rank 4
            {11419, 32000, faction="Alliance"}, -- Portal: Darnassus
            {11420, 32000, faction="Horde"}, -- Portal: Thunder Bluff
        },
        [52] = {
            {10145, 35000, req=10144, rank=6}, -- Conjure Food rank 6
            {10177, 35000, req=8462, rank=4}, -- Frost Ward rank 4
            {10186, 35000, req=10185, rank=5}, -- Blizzard rank 5
            {10192, 35000, req=10191, rank=5}, -- Mana Shield rank 5
            {10206, 35000, req=10205, rank=6}, -- Scorch rank 6
            {13020, 1750, req=13019, rank=4}, -- Blast Wave rank 4
            {13032, 1750, req=13031, rank=3}, -- Ice Barrier rank 3
        },
        [54] = {
            {10150, 36000, req=10149, rank=10}, -- Fireball rank 10
            {10170, 36000, req=10169, rank=4}, -- Amplify Magic rank 4
            {10199, 36000, req=10197, rank=7}, -- Fire Blast rank 7
            {10202, 36000, req=10201, rank=6}, -- Arcane Explosion rank 6
            {10230, 36000, req=6131, rank=4}, -- Frost Nova rank 4
            {12526, 1800, req=12525, rank=7}, -- Pyroblast rank 7
        },
        [56] = {
            {10157, 38000, req=10156, rank=5}, -- Arcane Intellect rank 5
            {10181, 38000, req=10180, rank=10}, -- Frostbolt rank 10
            {10212, 38000, req=10211, rank=7}, -- Arcane Missiles rank 7
            {10216, 38000, req=10215, rank=6}, -- Flamestrike rank 6
            {23028, 38000, rank=1}, -- Arcane Brilliance rank 1
            {33041, 1900, req=31661, rank=2}, -- Dragon's Breath rank 2
        },
        [58] = {
            {10054, 40000}, -- Conjure Mana Ruby
            {10161, 40000, req=10160, rank=5}, -- Cone of Cold rank 5
            {10207, 40000, req=10206, rank=7}, -- Scorch rank 7
            {13033, 2000, req=13032, rank=4}, -- Ice Barrier rank 4
            {22783, 40000, req=22782, rank=3}, -- Mage Armor rank 3
        },
        [60] = {
            {10140, 42000, req=10139, rank=7}, -- Conjure Water rank 7
            {10151, 42000, req=10150, rank=11}, -- Fireball rank 11
            {10174, 42000, req=10173, rank=5}, -- Dampen Magic rank 5
            {10187, 42000, req=10186, rank=6}, -- Blizzard rank 6
            {10193, 42000, req=10192, rank=6}, -- Mana Shield rank 6
            {10220, 42000, req=10219, rank=4}, -- Ice Armor rank 4
            {10225, 42000, req=10223, rank=5}, -- Fire Ward rank 5
            {12826, 42000, req=12825, rank=4}, -- Polymorph rank 4
            {13021, 2100, req=13020, rank=5}, -- Blast Wave rank 5
            {18809, 2100, req=12526, rank=8}, -- Pyroblast rank 8
            {25304, 42000, req=10181, rank=11}, -- Frostbolt rank 11
            {25345, 42000, req=10212, rank=8}, -- Arcane Missiles rank 8
            {28609, 42000, req=10177, rank=5}, -- Frost Ward rank 5
            {28612, 42000, req=10145, rank=7}, -- Conjure Food rank 7
            {33690, 20000, faction="Alliance"}, -- Teleport: Shattrath
            {35715, 20000, faction="Horde"}, -- Teleport: Shattrath
        },
        [61] = {
            {27078, 46000, req=10199, rank=8}, -- Fire Blast rank 8
        },
        [62] = {
            {25306, 42000, req=10151, rank=12}, -- Fireball rank 12
            {27080, 51000, req=10202, rank=7}, -- Arcane Explosion rank 7
            {30482, 51000, rank=1}, -- Molten Armor rank 1
        },
        [63] = {
            {27071, 57000, req=25304, rank=12}, -- Frostbolt rank 12
            {27075, 57000, req=25345, rank=9}, -- Arcane Missiles rank 9
            {27130, 57000, req=10170, rank=5}, -- Amplify Magic rank 5
        },
        [64] = {
            {27086, 63000, req=10216, rank=7}, -- Flamestrike rank 7
            {27134, 2500, req=13033, rank=5}, -- Ice Barrier rank 5
            {30451, 63000, rank=1}, -- Arcane Blast rank 1
            {33042, 2200, req=33041, rank=3}, -- Dragon's Breath rank 3
        },
        [65] = {
            {27073, 70000, req=10207, rank=8}, -- Scorch rank 8
            {27087, 70000, req=10161, rank=6}, -- Cone of Cold rank 6
            {27133, 10500, req=13021, rank=6}, -- Blast Wave rank 6
            {37420, 70000, req=10140, rank=8}, -- Conjure Water rank 8
            {33691, 150000, faction="Alliance"}, -- Portal: Shattrath
            {35717, 150000, faction="Horde"}, -- Portal: Shattrath
        },
        [66] = {
            {27070, 78000, req=25306, rank=13}, -- Fireball rank 13
            {27132, 10500, req=18809, rank=9}, -- Pyroblast rank 9
            {30455, 78000, rank=1}, -- Ice Lance rank 1
        },
        [67] = {
            {27088, 87000, req=10230, rank=5}, -- Frost Nova rank 5
            {33944, 87000, req=10174, rank=6}, -- Dampen Magic rank 6
        },
        [68] = {
            {66, 96000}, -- Invisibility
            {27085, 96000, req=10187, rank=7}, -- Blizzard rank 7
            {27101, 96000}, -- Conjure Mana Emerald
            {27131, 96000, req=10193, rank=7}, -- Mana Shield rank 7
        },
        [69] = {
            {27072, 110000, req=27071, rank=13}, -- Frostbolt rank 13
            {27124, 110000, req=10220, rank=5}, -- Ice Armor rank 5
            {27125, 110000, req=22783, rank=4}, -- Mage Armor rank 4
            {27128, 110000, req=10225, rank=6}, -- Fire Ward rank 6
            {33946, 110000, req=27130, rank=6}, -- Amplify Magic rank 6
            {38699, 87000, req=27075, rank=10}, -- Arcane Missiles rank 10
        },
        [70] = {
            {27074, 120000, req=27073, rank=9}, -- Scorch rank 9
            {27079, 120000, req=27078, rank=9}, -- Fire Blast rank 9
            {27082, 120000, req=27080, rank=8}, -- Arcane Explosion rank 8
            {27126, 120000, req=10157, rank=6}, -- Arcane Intellect rank 6
            {30449, 120000}, -- Spellsteal
            {32796, 120000, req=28609, rank=6}, -- Frost Ward rank 6
            {33043, 2500, req=33042, rank=4}, -- Dragon's Breath rank 4
            {33405, 10500, req=27134, rank=6}, -- Ice Barrier rank 6
            {33933, 12500, req=27133, rank=7}, -- Blast Wave rank 7
            {33938, 10500, req=27132, rank=10}, -- Pyroblast rank 10
            {43987, 120000, rank=1}, -- Ritual of Refreshment rank 1
        },
    },
    PRIEST = {
        [1] = {
            {1243, 10, rank=1}, -- Power Word: Fortitude rank 1
        },
        [4] = {
            {589, 100, rank=1}, -- Shadow Word: Pain rank 1
            {2052, 100, req=2050, rank=2}, -- Lesser Heal rank 2
        },
        [6] = {
            {17, 100, rank=1}, -- Power Word: Shield rank 1
            {591, 100, req=585, rank=2}, -- Smite rank 2
        },
        [8] = {
            {139, 200, rank=1}, -- Renew rank 1
            {586, 200, rank=1}, -- Fade rank 1
        },
        [10] = {
            {594, 300, req=589, rank=2}, -- Shadow Word: Pain rank 2
            {2006, 300, rank=1}, -- Resurrection rank 1
            {2053, 300, req=2052, rank=3}, -- Lesser Heal rank 3
            {8092, 300, rank=1}, -- Mind Blast rank 1
            {2652, 90, rank=1, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 1
            {9035, 90, rank=1, race="Troll"}, -- Hex of Weakness rank 1
            {10797, 90, rank=1, race="Night Elf"}, -- Starshards rank 1
            {13908, 76, rank=1, race={"Dwarf","Human"}}, -- Desperate Prayer rank 1
            {32548, 90, race="Draenei"}, -- Symbol of Hope
        },
        [12] = {
            {588, 800, rank=1}, -- Inner Fire rank 1
            {592, 800, req=17, rank=2}, -- Power Word: Shield rank 2
            {1244, 800, req=1243, rank=2}, -- Power Word: Fortitude rank 2
        },
        [14] = {
            {528, 1200}, -- Cure Disease
            {598, 1200, req=591, rank=3}, -- Smite rank 3
            {6074, 1200, req=139, rank=2}, -- Renew rank 2
            {8122, 1200, rank=1}, -- Psychic Scream rank 1
        },
        [16] = {
            {2054, 1600, rank=1}, -- Heal rank 1
            {8102, 1600, req=8092, rank=2}, -- Mind Blast rank 2
        },
        [18] = {
            {527, 2000, rank=1}, -- Dispel Magic rank 1
            {600, 2000, req=592, rank=3}, -- Power Word: Shield rank 3
            {970, 2000, req=594, rank=3}, -- Shadow Word: Pain rank 3
            {19296, 100, req=10797, rank=2, race="Night Elf"}, -- Starshards rank 2
            {19236, 100, req=13908, rank=2, race={"Dwarf","Human"}}, -- Desperate Prayer rank 2
        },
        [20] = {
            {453, 3000, rank=1}, -- Mind Soothe rank 1
            {2061, 3000, rank=1}, -- Flash Heal rank 1
            {2651, 100, race="Night Elf"}, -- Elune's Grace
            {2944, 100, rank=1, race="Undead"}, -- Devouring Plague rank 1
            {6075, 3000, req=6074, rank=3}, -- Renew rank 3
            {6346, 800}, -- Fear Ward
            {7128, 3000, req=588, rank=2}, -- Inner Fire rank 2
            {9484, 3000, rank=1}, -- Shackle Undead rank 1
            {9578, 3000, req=586, rank=2}, -- Fade rank 2
            {13896, 150, rank=1, race="Human"}, -- Feedback rank 1
            {14914, 3000, rank=1}, -- Holy Fire rank 1
            {18137, 100, rank=1, race="Troll"}, -- Shadowguard rank 1
            {32676, 100, race="Blood Elf"}, -- Consume Magic
            {44041, 100, rank=1, race={"Dwarf","Draenei"}}, -- Chastise rank 1
            {19261, 150, req=2652, rank=2, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 2
            {19281, 150, req=9035, rank=2, race="Troll"}, -- Hex of Weakness rank 2
        },
        [22] = {
            {984, 4000, req=598, rank=4}, -- Smite rank 4
            {2010, 4000, req=2006, rank=2}, -- Resurrection rank 2
            {2055, 4000, req=2054, rank=2}, -- Heal rank 2
            {2096, 4000, rank=1}, -- Mind Vision rank 1
            {8103, 4000, req=8102, rank=3}, -- Mind Blast rank 3
        },
        [24] = {
            {1245, 5000, req=1244, rank=3}, -- Power Word: Fortitude rank 3
            {3747, 5000, req=600, rank=4}, -- Power Word: Shield rank 4
            {8129, 5000, rank=1}, -- Mana Burn rank 1
            {15262, 5000, req=14914, rank=2}, -- Holy Fire rank 2
        },
        [26] = {
            {992, 6000, req=970, rank=4}, -- Shadow Word: Pain rank 4
            {6076, 6000, req=6075, rank=4}, -- Renew rank 4
            {9472, 6000, req=2061, rank=2}, -- Flash Heal rank 2
            {19299, 300, req=19296, rank=3, race="Night Elf"}, -- Starshards rank 3
            {19238, 300, req=19236, rank=3, race={"Dwarf","Human"}}, -- Desperate Prayer rank 3
        },
        [28] = {
            {6063, 8000, req=2055, rank=3}, -- Heal rank 3
            {8104, 8000, req=8103, rank=4}, -- Mind Blast rank 4
            {8124, 8000, req=8122, rank=2}, -- Psychic Scream rank 2
            {15430, 400, req=15237, rank=2}, -- Holy Nova rank 2
            {17311, 400, req=15407, rank=2}, -- Mind Flay rank 2
            {19276, 400, req=2944, rank=2, race="Undead"}, -- Devouring Plague rank 2
            {19308, 400, req=18137, rank=2, race="Troll"}, -- Shadowguard rank 2
        },
        [30] = {
            {596, 10000, rank=1}, -- Prayer of Healing rank 1
            {602, 10000, req=7128, rank=3}, -- Inner Fire rank 3
            {605, 10000, rank=1}, -- Mind Control rank 1
            {976, 10000, rank=1}, -- Shadow Protection rank 1
            {1004, 10000, req=984, rank=5}, -- Smite rank 5
            {6065, 10000, req=3747, rank=5}, -- Power Word: Shield rank 5
            {9579, 10000, req=9578, rank=3}, -- Fade rank 3
            {15263, 10000, req=15262, rank=3}, -- Holy Fire rank 3
            {19271, 500, req=13896, rank=2, race="Human"}, -- Feedback rank 2
            {44043, 500, req=44041, rank=2, race={"Dwarf","Draenei"}}, -- Chastise rank 2
            {19262, 500, req=19261, rank=3, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 3
            {19282, 500, req=19281, rank=3, race="Troll"}, -- Hex of Weakness rank 3
        },
        [32] = {
            {552, 11000}, -- Abolish Disease
            {6077, 11000, req=6076, rank=5}, -- Renew rank 5
            {8131, 11000, req=8129, rank=2}, -- Mana Burn rank 2
            {9473, 11000, req=9472, rank=3}, -- Flash Heal rank 3
        },
        [34] = {
            {1706, 12000}, -- Levitate
            {2767, 12000, req=992, rank=5}, -- Shadow Word: Pain rank 5
            {6064, 12000, req=6063, rank=4}, -- Heal rank 4
            {8105, 12000, req=8104, rank=5}, -- Mind Blast rank 5
            {10880, 12000, req=2010, rank=3}, -- Resurrection rank 3
            {19302, 600, req=19299, rank=4, race="Night Elf"}, -- Starshards rank 4
            {19240, 600, req=19238, rank=4, race={"Dwarf","Human"}}, -- Desperate Prayer rank 4
        },
        [36] = {
            {988, 14000, req=527, rank=2}, -- Dispel Magic rank 2
            {2791, 14000, req=1245, rank=4}, -- Power Word: Fortitude rank 4
            {6066, 14000, req=6065, rank=6}, -- Power Word: Shield rank 6
            {8192, 14000, req=453, rank=2}, -- Mind Soothe rank 2
            {15264, 14000, req=15263, rank=4}, -- Holy Fire rank 4
            {15431, 700, req=15430, rank=3}, -- Holy Nova rank 3
            {17312, 700, req=17311, rank=3}, -- Mind Flay rank 3
            {19277, 700, req=19276, rank=3, race="Undead"}, -- Devouring Plague rank 3
            {19309, 700, req=19308, rank=3, race="Troll"}, -- Shadowguard rank 3
        },
        [38] = {
            {6060, 16000, req=1004, rank=6}, -- Smite rank 6
            {6078, 16000, req=6077, rank=6}, -- Renew rank 6
            {9474, 16000, req=9473, rank=4}, -- Flash Heal rank 4
        },
        [40] = {
            {996, 18000, req=596, rank=2}, -- Prayer of Healing rank 2
            {1006, 18000, req=602, rank=4}, -- Inner Fire rank 4
            {2060, 18000, rank=1}, -- Greater Heal rank 1
            {8106, 18000, req=8105, rank=6}, -- Mind Blast rank 6
            {9485, 18000, req=9484, rank=2}, -- Shackle Undead rank 2
            {9592, 18000, req=9579, rank=4}, -- Fade rank 4
            {10874, 18000, req=8131, rank=3}, -- Mana Burn rank 3
            {14818, 900, req=14752, rank=2}, -- Divine Spirit rank 2
            {19273, 900, req=19271, rank=3, race="Human"}, -- Feedback rank 3
            {44044, 900, req=44043, rank=3, race={"Dwarf","Draenei"}}, -- Chastise rank 3
            {19264, 900, req=19262, rank=4, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 4
            {19283, 900, req=19282, rank=4, race="Troll"}, -- Hex of Weakness rank 4
        },
        [42] = {
            {10888, 22000, req=8124, rank=3}, -- Psychic Scream rank 3
            {10892, 22000, req=2767, rank=6}, -- Shadow Word: Pain rank 6
            {10898, 22000, req=6066, rank=7}, -- Power Word: Shield rank 7
            {10957, 22000, req=976, rank=2}, -- Shadow Protection rank 2
            {15265, 22000, req=15264, rank=5}, -- Holy Fire rank 5
            {19303, 1100, req=19302, rank=5, race="Night Elf"}, -- Starshards rank 5
            {19241, 1100, req=19240, rank=5, race={"Dwarf","Human"}}, -- Desperate Prayer rank 5
        },
        [44] = {
            {10909, 24000, req=2096, rank=2}, -- Mind Vision rank 2
            {10911, 24000, req=605, rank=2}, -- Mind Control rank 2
            {10915, 24000, req=9474, rank=5}, -- Flash Heal rank 5
            {10927, 24000, req=6078, rank=7}, -- Renew rank 7
            {17313, 1200, req=17312, rank=4}, -- Mind Flay rank 4
            {19278, 1200, req=19277, rank=4, race="Undead"}, -- Devouring Plague rank 4
            {19310, 1200, req=19309, rank=4, race="Troll"}, -- Shadowguard rank 4
            {27799, 1200, req=15431, rank=4}, -- Holy Nova rank 4
        },
        [46] = {
            {10881, 26000, req=10880, rank=4}, -- Resurrection rank 4
            {10933, 26000, req=6060, rank=7}, -- Smite rank 7
            {10945, 26000, req=8106, rank=7}, -- Mind Blast rank 7
            {10963, 26000, req=2060, rank=2}, -- Greater Heal rank 2
        },
        [48] = {
            {10875, 28000, req=10874, rank=4}, -- Mana Burn rank 4
            {10899, 28000, req=10898, rank=8}, -- Power Word: Shield rank 8
            {10937, 28000, req=2791, rank=5}, -- Power Word: Fortitude rank 5
            {15266, 28000, req=15265, rank=6}, -- Holy Fire rank 6
            {21562, 28000, rank=1}, -- Prayer of Fortitude rank 1
        },
        [50] = {
            {10893, 30000, req=10892, rank=7}, -- Shadow Word: Pain rank 7
            {10916, 30000, req=10915, rank=6}, -- Flash Heal rank 6
            {10928, 30000, req=10927, rank=8}, -- Renew rank 8
            {10941, 30000, req=9592, rank=5}, -- Fade rank 5
            {10951, 30000, req=1006, rank=5}, -- Inner Fire rank 5
            {10960, 30000, req=996, rank=3}, -- Prayer of Healing rank 3
            {14819, 1500, req=14818, rank=3}, -- Divine Spirit rank 3
            {19274, 1500, req=19273, rank=4, race="Human"}, -- Feedback rank 4
            {27870, 1200, req=724, rank=2}, -- Lightwell rank 2
            {44045, 1500, req=44044, rank=4, race={"Dwarf","Draenei"}}, -- Chastise rank 4
            {19265, 1500, req=19264, rank=5, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 5
            {19284, 1500, req=19283, rank=5, race="Troll"}, -- Hex of Weakness rank 5
            {19304, 1500, req=19303, rank=6, race="Night Elf"}, -- Starshards rank 6
            {19242, 1500, req=19241, rank=6, race={"Dwarf","Human"}}, -- Desperate Prayer rank 6
        },
        [52] = {
            {10946, 38000, req=10945, rank=8}, -- Mind Blast rank 8
            {10953, 38000, req=8192, rank=3}, -- Mind Soothe rank 3
            {10964, 38000, req=10963, rank=3}, -- Greater Heal rank 3
            {17314, 1900, req=17313, rank=5}, -- Mind Flay rank 5
            {19279, 1900, req=19278, rank=5, race="Undead"}, -- Devouring Plague rank 5
            {19311, 1900, req=19310, rank=5, race="Troll"}, -- Shadowguard rank 5
            {27800, 1900, req=27799, rank=5}, -- Holy Nova rank 5
        },
        [54] = {
            {10900, 40000, req=10899, rank=9}, -- Power Word: Shield rank 9
            {10934, 40000, req=10933, rank=8}, -- Smite rank 8
            {15267, 40000, req=15266, rank=7}, -- Holy Fire rank 7
        },
        [56] = {
            {10876, 42000, req=10875, rank=5}, -- Mana Burn rank 5
            {10890, 42000, req=10888, rank=4}, -- Psychic Scream rank 4
            {10917, 42000, req=10916, rank=7}, -- Flash Heal rank 7
            {10929, 42000, req=10928, rank=9}, -- Renew rank 9
            {10958, 42000, req=10957, rank=3}, -- Shadow Protection rank 3
            {27683, 42000, rank=1}, -- Prayer of Shadow Protection rank 1
            {34863, 2100, req=34861, rank=2}, -- Circle of Healing rank 2
        },
        [58] = {
            {10894, 44000, req=10893, rank=8}, -- Shadow Word: Pain rank 8
            {10912, 44000, req=10911, rank=3}, -- Mind Control rank 3
            {10947, 44000, req=10946, rank=9}, -- Mind Blast rank 9
            {10965, 44000, req=10964, rank=4}, -- Greater Heal rank 4
            {20770, 44000, req=10881, rank=5}, -- Resurrection rank 5
            {19305, 2200, req=19304, rank=7, race="Night Elf"}, -- Starshards rank 7
            {19243, 2200, req=19242, rank=7, race={"Dwarf","Human"}}, -- Desperate Prayer rank 7
        },
        [60] = {
            {10901, 46000, req=10900, rank=10}, -- Power Word: Shield rank 10
            {10938, 46000, req=10937, rank=6}, -- Power Word: Fortitude rank 6
            {10942, 46000, req=10941, rank=6}, -- Fade rank 6
            {10952, 46000, req=10951, rank=6}, -- Inner Fire rank 6
            {10955, 46000, req=9485, rank=3}, -- Shackle Undead rank 3
            {10961, 46000, req=10960, rank=4}, -- Prayer of Healing rank 4
            {15261, 46000, req=15267, rank=8}, -- Holy Fire rank 8
            {18807, 2300, req=17314, rank=6}, -- Mind Flay rank 6
            {19275, 2300, req=19274, rank=5, race="Human"}, -- Feedback rank 5
            {19280, 2300, req=19279, rank=6, race="Undead"}, -- Devouring Plague rank 6
            {19312, 2300, req=19311, rank=6, race="Troll"}, -- Shadowguard rank 6
            {21564, 46000, req=21562, rank=2}, -- Prayer of Fortitude rank 2
            {25314, 65000, req=10965, rank=5}, -- Greater Heal rank 5
            {25315, 6500, req=10929, rank=10}, -- Renew rank 10
            {25316, 6500, req=10961, rank=5}, -- Prayer of Healing rank 5 --LEVEL?
            {27681, 2300, req=14752, rank=2}, -- Prayer of Spirit rank 2
            {27801, 2300, req=27800, rank=6}, -- Holy Nova rank 6
            {27841, 2300, req=14819, rank=4}, -- Divine Spirit rank 4
            {27871, 1500, req=27870, rank=3}, -- Lightwell rank 3
            {34864, 2300, req=34863, rank=3}, -- Circle of Healing rank 3
            {34916, 2300, req=34914, rank=2}, -- Vampiric Touch rank 2
            {44046, 2300, req=44045, rank=5, race={"Dwarf","Draenei"}}, -- Chastise rank 5
            {19266, 2300, req=19265, rank=6, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 6
            {19285, 2300, req=19284, rank=6, race="Troll"}, -- Hex of Weakness rank 6
        },
        [61] = {
            {25233, 53000, req=10917, rank=8}, -- Flash Heal rank 8
            {25363, 53000, req=10934, rank=9}, -- Smite rank 9
        },
        [62] = {
            {32379, 59000, rank=1}, -- Shadow Word: Death rank 1
        },
        [63] = {
            {25210, 65000, req=25314, rank=6}, -- Greater Heal rank 6
            {25372, 65000, req=10947, rank=10}, -- Mind Blast rank 10
            {25379, 65000, req=10876, rank=6}, -- Mana Burn rank 6
        },
        [64] = {
            {32546, 72000, rank=1}, -- Binding Heal rank 1
        },
        [65] = {
            {25217, 80000, req=10901, rank=11}, -- Power Word: Shield rank 11
            {25221, 80000, req=25315, rank=11}, -- Renew rank 11
            {25367, 80000, req=10894, rank=9}, -- Shadow Word: Pain rank 9
            {34865, 2300, req=34864, rank=4}, -- Circle of Healing rank 4
        },
        [66] = {
            {25384, 65000, req=15261, rank=9}, -- Holy Fire rank 9
            {25429, 89000, req=10942, rank=7}, -- Fade rank 7
            {34433, 89000, rank=1}, -- Shadowfiend rank 1
            {25446, 6500, req=19305, rank=8, race="Night Elf"}, -- Starshards rank 8
            {25437, 6500, req=19243, rank=8, race={"Dwarf","Human"}}, -- Desperate Prayer rank 8
        },
        [67] = {
            {25235, 99000, req=25233, rank=9}, -- Flash Heal rank 9
            {25596, 99000, req=10953, rank=4}, -- Mind Soothe rank 4
        },
        [68] = {
            {25213, 110000, req=25210, rank=7}, -- Greater Heal rank 7
            {25308, 110000, req=25316, rank=6}, -- Prayer of Healing rank 6
            {25331, 3250, req=27801, rank=7}, -- Holy Nova rank 7
            {25387, 6500, req=18807, rank=7}, -- Mind Flay rank 7
            {25433, 110000, req=10958, rank=4}, -- Shadow Protection rank 4
            {25435, 110000, req=20770, rank=6}, -- Resurrection rank 6
            {25467, 6500, req=19280, rank=7, race="Undead"}, -- Devouring Plague rank 7
            {25477, 6500, req=19312, rank=7, race="Troll"}, -- Shadowguard rank 7
            {33076, 110000, rank=1}, -- Prayer of Mending rank 1
        },
        [69] = {
            {25364, 65000, req=25363, rank=10}, -- Smite rank 10
            {25375, 65000, req=25372, rank=11}, -- Mind Blast rank 11
            {25431, 65000, req=10952, rank=7}, -- Inner Fire rank 7
        },
        [70] = {
            {25218, 140000, req=25217, rank=12}, -- Power Word: Shield rank 12
            {25222, 140000, req=25221, rank=12}, -- Renew rank 12
            {25312, 2300, req=27841, rank=5}, -- Divine Spirit rank 5
            {25368, 140000, req=25367, rank=10}, -- Shadow Word: Pain rank 10
            {25380, 110000, req=25379, rank=7}, -- Mana Burn rank 7
            {25389, 65000, req=10938, rank=7}, -- Power Word: Fortitude rank 7
            {25441, 6500, req=19275, rank=6, race="Human"}, -- Feedback rank 6
            {28275, 1500, req=27871, rank=4}, -- Lightwell rank 4
            {32375, 110000}, -- Mass Dispel
            {32996, 110000, req=32379, rank=2}, -- Shadow Word: Death rank 2
            {32999, 3400, req=27681, rank=3}, -- Prayer of Spirit rank 3
            {34866, 2300, req=34865, rank=5}, -- Circle of Healing rank 5
            {34917, 2300, req=34916, rank=3}, -- Vampiric Touch rank 3
            {44047, 2762, req=44046, rank=6, race={"Dwarf","Draenei"}}, -- Chastise rank 6
            {25461, 6500, req=19266, rank=7, race={"Undead","Blood Elf"}}, -- Touch of Weakness rank 7
            {25470, 6500, req=19285, rank=7, race="Troll"}, -- Hex of Weakness rank 7
        },
    },
    WARLOCK = {
        [1] = {
            {348, 10, rank=1}, -- Immolate rank 1
        },
        [4] = {
            {172, 100, rank=1}, -- Corruption rank 1
            {702, 100, rank=1}, -- Curse of Weakness rank 1
        },
        [6] = {
            {695, 100, req=686, rank=2}, -- Shadow Bolt rank 2
            {1454, 100, rank=1}, -- Life Tap rank 1
        },
        [8] = {
            {980, 200, rank=1}, -- Curse of Agony rank 1
            {5782, 200, rank=1}, -- Fear rank 1
        },
        [10] = {
            {696, 300, req=687, rank=2}, -- Demon Skin rank 2
            {707, 300, req=348, rank=2}, -- Immolate rank 2
            {1120, 300, rank=1}, -- Drain Soul rank 1
            {6201, 300, rank=1}, -- Create Healthstone rank 1
        },
        [12] = {
            {705, 600, req=695, rank=3}, -- Shadow Bolt rank 3
            {755, 600, rank=1}, -- Health Funnel rank 1
            {1108, 600, req=702, rank=2}, -- Curse of Weakness rank 2
        },
        [14] = {
            {689, 900, rank=1}, -- Drain Life rank 1
            {704, 900, rank=1}, -- Curse of Recklessness rank 1
            {6222, 900, req=172, rank=2}, -- Corruption rank 2
        },
        [16] = {
            {1455, 1200, req=1454, rank=2}, -- Life Tap rank 2
            {5697, 1200}, -- Unending Breath
        },
        [18] = {
            {693, 1500, rank=1}, -- Create Soulstone rank 1
            {1014, 1500, req=980, rank=2}, -- Curse of Agony rank 2
            {5676, 1500, rank=1}, -- Searing Pain rank 1
        },
        [20] = {
            {698, 2000}, -- Ritual of Summoning
            {706, 2000, rank=1}, -- Demon Armor rank 1
            {1088, 2000, req=705, rank=4}, -- Shadow Bolt rank 4
            {1094, 2000, req=707, rank=3}, -- Immolate rank 3
            {3698, 2000, req=755, rank=2}, -- Health Funnel rank 2
            {5740, 2000, rank=1}, -- Rain of Fire rank 1
        },
        [22] = {
            {126, 2500}, -- Eye of Kilrogg
            {699, 2500, req=689, rank=2}, -- Drain Life rank 2
            {6202, 2500, req=6201, rank=2}, -- Create Healthstone rank 2
            {6205, 2500, req=1108, rank=3}, -- Curse of Weakness rank 3
        },
        [24] = {
            {5138, 3000, rank=1}, -- Drain Mana rank 1
            {5500, 3000}, -- Sense Demons
            {6223, 3000, req=6222, rank=3}, -- Corruption rank 3
            {8288, 3000, req=1120, rank=2}, -- Drain Soul rank 2
            {18867, 150, req=17877, rank=2}, -- Shadowburn rank 2
        },
        [26] = {
            {132, 4000}, -- Detect Invisibility
            {1456, 4000, req=1455, rank=3}, -- Life Tap rank 3
            {1714, 4000, rank=1}, -- Curse of Tongues rank 1
            {17919, 4000, req=5676, rank=2}, -- Searing Pain rank 2
        },
        [28] = {
            {710, 5000, rank=1}, -- Banish rank 1
            {1106, 5000, req=1088, rank=5}, -- Shadow Bolt rank 5
            {3699, 5000, req=3698, rank=3}, -- Health Funnel rank 3
            {6217, 5000, req=1014, rank=3}, -- Curse of Agony rank 3
            {6366, 5000, rank=1}, -- Create Firestone rank 1
            {7658, 5000, req=704, rank=2}, -- Curse of Recklessness rank 2
        },
        [30] = {
            {709, 6000, req=699, rank=3}, -- Drain Life rank 3
            {1086, 6000, req=706, rank=2}, -- Demon Armor rank 2
            {1098, 6000, rank=1}, -- Enslave Demon rank 1
            {1949, 6000, rank=1}, -- Hellfire rank 1
            {2941, 6000, req=1094, rank=4}, -- Immolate rank 4
            {5784, 10000}, -- Summon Felsteed
            {20752, 6000, req=693, rank=2}, -- Create Soulstone rank 2
        },
        [32] = {
            {1490, 7000, rank=1}, -- Curse of the Elements rank 1
            {6213, 7000, req=5782, rank=2}, -- Fear rank 2
            {6229, 7000, rank=1}, -- Shadow Ward rank 1
            {7646, 7000, req=6205, rank=4}, -- Curse of Weakness rank 4
            {18868, 350, req=18867, rank=3}, -- Shadowburn rank 3
        },
        [34] = {
            {5699, 8000, req=6202, rank=3}, -- Create Healthstone rank 3
            {6219, 8000, req=5740, rank=2}, -- Rain of Fire rank 2
            {6226, 8000, req=5138, rank=2}, -- Drain Mana rank 2
            {7648, 8000, req=6223, rank=4}, -- Corruption rank 4
            {17920, 8000, req=17919, rank=3}, -- Searing Pain rank 3
        },
        [36] = {
            {2362, 9000, rank=1}, -- Create Spellstone rank 1
            {3700, 9000, req=3699, rank=4}, -- Health Funnel rank 4
            {7641, 9000, req=1106, rank=6}, -- Shadow Bolt rank 6
            {11687, 9000, req=1456, rank=4}, -- Life Tap rank 4
            {17951, 9000, req=6366, rank=2}, -- Create Firestone rank 2
        },
        [38] = {
            {7651, 10000, req=709, rank=4}, -- Drain Life rank 4
            {8289, 10000, req=8288, rank=3}, -- Drain Soul rank 3
            {11711, 10000, req=6217, rank=4}, -- Curse of Agony rank 4
            {18879, 500, req=18265, rank=2}, -- Siphon Life rank 2
        },
        [40] = {
            {5484, 11000, rank=1}, -- Howl of Terror rank 1
            {11665, 11000, req=2941, rank=5}, -- Immolate rank 5
            {11733, 11000, req=1086, rank=3}, -- Demon Armor rank 3
            {18869, 550, req=18868, rank=4}, -- Shadowburn rank 4
            {20755, 11000, req=20752, rank=3}, -- Create Soulstone rank 3
        },
        [42] = {
            {6789, 11000, rank=1}, -- Death Coil rank 1
            {7659, 11000, req=7658, rank=3}, -- Curse of Recklessness rank 3
            {11683, 11000, req=1949, rank=2}, -- Hellfire rank 2
            {11707, 11000, req=7646, rank=5}, -- Curse of Weakness rank 5
            {11739, 11000, req=6229, rank=2}, -- Shadow Ward rank 2
            {17921, 11000, req=17920, rank=4}, -- Searing Pain rank 4
        },
        [44] = {
            {11659, 12000, req=7641, rank=7}, -- Shadow Bolt rank 7
            {11671, 12000, req=7648, rank=5}, -- Corruption rank 5
            {11693, 12000, req=3700, rank=5}, -- Health Funnel rank 5
            {11703, 12000, req=6226, rank=3}, -- Drain Mana rank 3
            {11725, 12000, req=1098, rank=2}, -- Enslave Demon rank 2
        },
        [46] = {
            {11677, 13000, req=6219, rank=3}, -- Rain of Fire rank 3
            {11688, 13000, req=11687, rank=5}, -- Life Tap rank 5
            {11699, 13000, req=7651, rank=5}, -- Drain Life rank 5
            {11721, 13000, req=1490, rank=2}, -- Curse of the Elements rank 2
            {11729, 13000, req=5699, rank=4}, -- Create Healthstone rank 4
            {17952, 13000, req=17951, rank=3}, -- Create Firestone rank 3
        },
        [48] = {
            {6353, 14000, rank=1}, -- Soul Fire rank 1
            {11712, 14000, req=11711, rank=5}, -- Curse of Agony rank 5
            {17727, 14000, req=2362, rank=2}, -- Create Spellstone rank 2
            {18647, 14000, req=710, rank=2}, -- Banish rank 2
            {18870, 700, req=18869, rank=5}, -- Shadowburn rank 5
            {18880, 700, req=18879, rank=3}, -- Siphon Life rank 3
            {18930, 700, req=17962, rank=2}, -- Conflagrate rank 2
        },
        [50] = {
            {11667, 15000, req=11665, rank=6}, -- Immolate rank 6
            {11719, 15000, req=1714, rank=2}, -- Curse of Tongues rank 2
            {11734, 15000, req=11733, rank=4}, -- Demon Armor rank 4
            {17922, 15000, req=17921, rank=5}, -- Searing Pain rank 5
            {17925, 15000, req=6789, rank=2}, -- Death Coil rank 2
            {18937, 750, req=18220, rank=2}, -- Dark Pact rank 2
            {20756, 15000, req=20755, rank=4}, -- Create Soulstone rank 4
        },
        [52] = {
            {11660, 18000, req=11659, rank=8}, -- Shadow Bolt rank 8
            {11675, 18000, req=8289, rank=4}, -- Drain Soul rank 4
            {11694, 18000, req=11693, rank=6}, -- Health Funnel rank 6
            {11708, 18000, req=11707, rank=6}, -- Curse of Weakness rank 6
            {11740, 18000, req=11739, rank=3}, -- Shadow Ward rank 3
        },
        [54] = {
            {11672, 20000, req=11671, rank=6}, -- Corruption rank 6
            {11684, 20000, req=11683, rank=3}, -- Hellfire rank 3
            {11700, 20000, req=11699, rank=6}, -- Drain Life rank 6
            {11704, 20000, req=11703, rank=4}, -- Drain Mana rank 4
            {17928, 20000, req=5484, rank=2}, -- Howl of Terror rank 2
            {18931, 1000, req=18930, rank=3}, -- Conflagrate rank 3
        },
        [56] = {
            {6215, 22000, req=6213, rank=3}, -- Fear rank 3
            {11689, 22000, req=11688, rank=6}, -- Life Tap rank 6
            {11717, 22000, req=7659, rank=4}, -- Curse of Recklessness rank 4
            {17924, 22000, req=6353, rank=2}, -- Soul Fire rank 2
            {17953, 22000, req=17952, rank=4}, -- Create Firestone rank 4
            {18871, 1100, req=18870, rank=6}, -- Shadowburn rank 6
        },
        [58] = {
            {11678, 24000, req=11677, rank=4}, -- Rain of Fire rank 4
            {11713, 24000, req=11712, rank=6}, -- Curse of Agony rank 6
            {11726, 24000, req=11725, rank=3}, -- Enslave Demon rank 3
            {11730, 24000, req=11729, rank=5}, -- Create Healthstone rank 5
            {17923, 24000, req=17922, rank=6}, -- Searing Pain rank 6
            {17926, 24000, req=17925, rank=3}, -- Death Coil rank 3
            {18881, 1200, req=18880, rank=4}, -- Siphon Life rank 4
        },
        [60] = {
            {603, 26000, rank=1}, -- Curse of Doom rank 1
            {11661, 26000, req=11660, rank=9}, -- Shadow Bolt rank 9
            {11668, 26000, req=11667, rank=7}, -- Immolate rank 7
            {11695, 26000, req=11694, rank=7}, -- Health Funnel rank 7
            {11722, 26000, req=11721, rank=3}, -- Curse of the Elements rank 3
            {11735, 26000, req=11734, rank=5}, -- Demon Armor rank 5
            {17728, 26000, req=17727, rank=3}, -- Create Spellstone rank 3
            {18932, 1300, req=18931, rank=4}, -- Conflagrate rank 4
            {18938, 1300, req=18937, rank=3}, -- Dark Pact rank 3
            {20757, 26000, req=20756, rank=5}, -- Create Soulstone rank 5
            {25309, 26000, req=11668, rank=8}, -- Immolate rank 8---------------------------------------
            {25311, 26000, req=11672, rank=7}, -- Corruption rank 7
            {28610, 34000, req=11740, rank=4}, -- Shadow Ward rank 4
            {30404, 2500, req=30108, rank=2}, -- Unstable Affliction rank 2
            {30413, 2500, req=30283, rank=2}, -- Shadowfury rank 2
        },
        [61] = {
            {27224, 30000, req=11708, rank=7}, -- Curse of Weakness rank 7
        },
        [62] = {
            {25307, 26000, req=11661, rank=10}, -- Shadow Bolt rank 10
            {27219, 30000, req=11700, rank=7}, -- Drain Life rank 7
            {28176, 34000, rank=1}, -- Fel Armor rank 1
        },
        [63] = {
            {27221, 38000, req=11704, rank=5}, -- Drain Mana rank 5
            {27263, 1300, req=18871, rank=7}, -- Shadowburn rank 7
            {27264, 2500, req=18881, rank=5}, -- Siphon Life rank 5
        },
        [64] = {
            {27211, 42000, req=17924, rank=3}, -- Soul Fire rank 3
            {29722, 42000, rank=1}, -- Incinerate rank 1
        },
        [65] = {
            {27210, 46000, req=17923, rank=7}, -- Searing Pain rank 7
            {27216, 46000, req=25311, rank=8}, -- Corruption rank 8
            {27266, 2300, req=18932, rank=5}, -- Conflagrate rank 5
        },
        [66] = {
            {27250, 51000, req=17953, rank=5}, -- Create Firestone rank 5
            {28172, 51000, req=17728, rank=4}, -- Create Spellstone rank 4
            {29858, 51000}, -- Soulshatter
        },
        [67] = {
            {27217, 57000, req=11675, rank=5}, -- Drain Soul rank 5
            {27218, 57000, req=11713, rank=7}, -- Curse of Agony rank 7
            {27259, 57000, req=11695, rank=8}, -- Health Funnel rank 8
        },
        [68] = {
            {27213, 63000, req=11684, rank=4}, -- Hellfire rank 4
            {27222, 56700, req=11689, rank=7}, -- Life Tap rank 7
            {27223, 63000, req=17926, rank=4}, -- Death Coil rank 4
            {27230, 63000, req=11730, rank=6}, -- Create Healthstone rank 6
            {29893, 63000, rank=1}, -- Ritual of Souls rank 1
        },
        [69] = {
            {27209, 70000, req=25307, rank=11}, -- Shadow Bolt rank 11
            {27212, 70000, req=11678, rank=5}, -- Rain of Fire rank 5
            {27215, 70000, req=25309, rank=9}, -- Immolate rank 9
            {27220, 70000, req=27219, rank=8}, -- Drain Life rank 8
            {27226, 70000, req=11717, rank=5}, -- Curse of Recklessness rank 5
            {27228, 70000, req=11722, rank=4}, -- Curse of the Elements rank 4
            {28189, 70000, req=28176, rank=2}, -- Fel Armor rank 2
            {30909, 70000, req=27224, rank=8}, -- Curse of Weakness rank 8
        },
        [70] = {
            {27238, 78000, req=20757, rank=6}, -- Create Soulstone rank 6
            {27243, 78000, rank=1}, -- Seed of Corruption rank 1
            {27260, 78000, req=11735, rank=6}, -- Demon Armor rank 6
            {27265, 1300, req=18938, rank=4}, -- Dark Pact rank 4
            {30405, 2500, req=30404, rank=3}, -- Unstable Affliction rank 3
            {30414, 2500, req=30413, rank=3}, -- Shadowfury rank 3
            {30459, 78000, req=27210, rank=8}, -- Searing Pain rank 8
            {30545, 78000, req=27211, rank=4}, -- Soul Fire rank 4
            {30546, 3900, req=27263, rank=8}, -- Shadowburn rank 8
            {30908, 78000, req=27221, rank=6}, -- Drain Mana rank 6
            {30910, 78000, req=603, rank=2}, -- Curse of Doom rank 2
            {30911, 2500, req=27264, rank=6}, -- Siphon Life rank 6
            {30912, 3900, req=27266, rank=6}, -- Conflagrate rank 6
            {32231, 78000, req=29722, rank=2}, -- Incinerate rank 2
        },
    },
    DRUID = {
        [1] = {
            {1126, 10, rank=1}, -- Mark of the Wild rank 1
        },
        [4] = {
            {774, 100, rank=1}, -- Rejuvenation rank 1
            {8921, 100, rank=1}, -- Moonfire rank 1
        },
        [6] = {
            {467, 100, rank=1}, -- Thorns rank 1
            {5177, 100, req=5176, rank=2}, -- Wrath rank 2
        },
        [8] = {
            {339, 200, rank=1}, -- Entangling Roots rank 1
            {5186, 200, req=5185, rank=2}, -- Healing Touch rank 2
        },
        [10] = {
            {99, 300, rank=1}, -- Demoralizing Roar rank 1
            {1058, 300, req=774, rank=2}, -- Rejuvenation rank 2
            {5232, 300, req=1126, rank=2}, -- Mark of the Wild rank 2
            {8924, 300, req=8921, rank=2}, -- Moonfire rank 2
        },
        [12] = {
            {5229, 800}, -- Enrage
            {8936, 800, rank=1}, -- Regrowth rank 1
        },
        [14] = {
            {782, 900, req=467, rank=2}, -- Thorns rank 2
            {5178, 900, req=5177, rank=3}, -- Wrath rank 3
            {5187, 900, req=5186, rank=3}, -- Healing Touch rank 3
            {5211, 900, rank=1}, -- Bash rank 1
        },
        [16] = {
            {779, 1800, rank=1}, -- Swipe rank 1
            {1430, 1800, req=1058, rank=3}, -- Rejuvenation rank 3
            {8925, 1800, req=8924, rank=3}, -- Moonfire rank 3
        },
        [18] = {
            {770, 1900, rank=1}, -- Faerie Fire rank 1
            {1062, 1900, req=339, rank=2}, -- Entangling Roots rank 2
            {2637, 1900, rank=1}, -- Hibernate rank 1
            {6808, 1900, req=6807, rank=2}, -- Maul rank 2
            {8938, 1900, req=8936, rank=2}, -- Regrowth rank 2
            {16810, 95, req=16689, rank=2}, -- Nature's Grasp rank 2
        },
        [20] = {
            {768, 2000}, -- Cat Form
            {1079, 2000, rank=1}, -- Rip rank 1
            {1082, 2000, rank=1}, -- Claw rank 1
            {1735, 2000, req=99, rank=2}, -- Demoralizing Roar rank 2
            {2912, 2000, rank=1}, -- Starfire rank 1
            {5188, 2000, req=5187, rank=4}, -- Healing Touch rank 4
            {5215, 2000, rank=1}, -- Prowl rank 1
            {6756, 2000, req=5232, rank=3}, -- Mark of the Wild rank 3
            {20484, 2000, rank=1}, -- Rebirth rank 1
        },
        [22] = {
            {2090, 3000, req=1430, rank=4}, -- Rejuvenation rank 4
            {2908, 3000, rank=1}, -- Soothe Animal rank 1
            {5179, 3000, req=5178, rank=4}, -- Wrath rank 4
            {5221, 3000, rank=1}, -- Shred rank 1
            {8926, 3000, req=8925, rank=4}, -- Moonfire rank 4
        },
        [24] = {
            {780, 4000, req=779, rank=2}, -- Swipe rank 2
            {1075, 4000, req=782, rank=3}, -- Thorns rank 3
            {1822, 4000, rank=1}, -- Rake rank 1
            {2782, 4000}, -- Remove Curse
            {5217, 4000, rank=1}, -- Tiger's Fury rank 1
            {8939, 4000, req=8938, rank=3}, -- Regrowth rank 3
        },
        [26] = {
            {1850, 4500, rank=1}, -- Dash rank 1
            {2893, 4500}, -- Abolish Poison
            {5189, 4500, req=5188, rank=5}, -- Healing Touch rank 5
            {6809, 4500, req=6808, rank=3}, -- Maul rank 3
            {8949, 4500, req=2912, rank=2}, -- Starfire rank 2
        },
        [28] = {
            {2091, 5000, req=2090, rank=5}, -- Rejuvenation rank 5
            {3029, 5000, req=1082, rank=2}, -- Claw rank 2
            {5195, 5000, req=1062, rank=3}, -- Entangling Roots rank 3
            {5209, 5000}, -- Challenging Roar
            {8927, 5000, req=8926, rank=5}, -- Moonfire rank 5
            {8998, 5000, rank=1}, -- Cower rank 1
            {9492, 5000, req=1079, rank=2}, -- Rip rank 2
            {16811, 250, req=16810, rank=3}, -- Nature's Grasp rank 3
        },
        [30] = {
            {740, 6000, rank=1}, -- Tranquility rank 1
            {778, 6000, req=770, rank=2}, -- Faerie Fire rank 2
            {783, 6000}, -- Travel Form
            {5180, 6000, req=5179, rank=5}, -- Wrath rank 5
            {5234, 6000, req=6756, rank=4}, -- Mark of the Wild rank 4
            {6798, 6000, req=5211, rank=2}, -- Bash rank 2
            {6800, 6000, req=5221, rank=2}, -- Shred rank 2
            {8940, 6000, req=8939, rank=4}, -- Regrowth rank 4
            {17390, 300, req=16857, rank=2}, -- Faerie Fire (Feral) rank 2
            {20739, 6000, req=20484, rank=2}, -- Rebirth rank 2
            {24974, 300, req=5570, rank=2}, -- Insect Swarm rank 2
        },
        [32] = {
            {5225, 8000}, -- Track Humanoids
            {6778, 8000, req=5189, rank=6}, -- Healing Touch rank 6
            {6785, 8000, rank=1}, -- Ravage rank 1
            {9490, 8000, req=1735, rank=3}, -- Demoralizing Roar rank 3
            {22568, 8000, rank=1}, -- Ferocious Bite rank 1
        },
        [34] = {
            {769, 10000, req=780, rank=3}, -- Swipe rank 3
            {1823, 10000, req=1822, rank=2}, -- Rake rank 2
            {3627, 10000, req=2091, rank=6}, -- Rejuvenation rank 6
            {8914, 10000, req=1075, rank=4}, -- Thorns rank 4
            {8928, 10000, req=8927, rank=6}, -- Moonfire rank 6
            {8950, 10000, req=8949, rank=3}, -- Starfire rank 3
            {8972, 10000, req=6809, rank=4}, -- Maul rank 4
        },
        [36] = {
            {6793, 11000, req=5217, rank=2}, -- Tiger's Fury rank 2
            {8941, 11000, req=8940, rank=5}, -- Regrowth rank 5
            {9005, 11000, rank=1}, -- Pounce rank 1
            {9493, 11000, req=9492, rank=3}, -- Rip rank 3
            {22842, 11000, rank=1}, -- Frenzied Regeneration rank 1
        },
        [38] = {
            {5196, 12000, req=5195, rank=4}, -- Entangling Roots rank 4
            {5201, 12000, req=3029, rank=3}, -- Claw rank 3
            {6780, 12000, req=5180, rank=6}, -- Wrath rank 6
            {8903, 12000, req=6778, rank=7}, -- Healing Touch rank 7
            {8955, 12000, req=2908, rank=2}, -- Soothe Animal rank 2
            {8992, 12000, req=6800, rank=3}, -- Shred rank 3
            {16812, 600, req=16811, rank=4}, -- Nature's Grasp rank 4
            {18657, 12000, req=2637, rank=2}, -- Hibernate rank 2
        },
        [40] = {
            {6783, 14000, req=5215, rank=2}, -- Prowl rank 2
            {8907, 14000, req=5234, rank=5}, -- Mark of the Wild rank 5
            {8910, 14000, req=3627, rank=7}, -- Rejuvenation rank 7
            {8918, 14000, req=740, rank=2}, -- Tranquility rank 2
            {8929, 14000, req=8928, rank=7}, -- Moonfire rank 7
            {9000, 14000, req=8998, rank=2}, -- Cower rank 2
            {9634, 14000}, -- Dire Bear Form
            {16914, 14000, rank=1}, -- Hurricane rank 1
            {20719, 14000}, -- Feline Grace
            {20742, 14000, req=20739, rank=3}, -- Rebirth rank 3
            {22827, 14000, req=22568, rank=2}, -- Ferocious Bite rank 2
            {24975, 700, req=24974, rank=3}, -- Insect Swarm rank 3
            {29166, 14000}, -- Innervate
        },
        [42] = {
            {6787, 16000, req=6785, rank=2}, -- Ravage rank 2
            {8951, 16000, req=8950, rank=4}, -- Starfire rank 4
            {9745, 16000, req=8972, rank=5}, -- Maul rank 5
            {9747, 16000, req=9490, rank=4}, -- Demoralizing Roar rank 4
            {9749, 16000, req=778, rank=3}, -- Faerie Fire rank 3
            {9750, 16000, req=8941, rank=6}, -- Regrowth rank 6
            {17391, 800, req=17390, rank=3}, -- Faerie Fire (Feral) rank 3
        },
        [44] = {
            {1824, 18000, req=1823, rank=3}, -- Rake rank 3
            {9752, 18000, req=9493, rank=4}, -- Rip rank 4
            {9754, 18000, req=769, rank=4}, -- Swipe rank 4
            {9756, 18000, req=8914, rank=5}, -- Thorns rank 5
            {9758, 18000, req=8903, rank=8}, -- Healing Touch rank 8
            {22812, 18000}, -- Barkskin
        },
        [46] = {
            {8905, 20000, req=6780, rank=7}, -- Wrath rank 7
            {8983, 20000, req=6798, rank=3}, -- Bash rank 3
            {9821, 20000, req=1850, rank=2}, -- Dash rank 2
            {9823, 20000, req=9005, rank=2}, -- Pounce rank 2
            {9829, 20000, req=8992, rank=4}, -- Shred rank 4
            {9833, 20000, req=8929, rank=8}, -- Moonfire rank 8
            {9839, 20000, req=8910, rank=8}, -- Rejuvenation rank 8
            {22895, 20000, req=22842, rank=2}, -- Frenzied Regeneration rank 2
        },
        [48] = {
            {9845, 22000, req=6793, rank=3}, -- Tiger's Fury rank 3
            {9849, 22000, req=5201, rank=4}, -- Claw rank 4
            {9852, 22000, req=5196, rank=5}, -- Entangling Roots rank 5
            {9856, 22000, req=9750, rank=7}, -- Regrowth rank 7
            {16813, 1100, req=16812, rank=5}, -- Nature's Grasp rank 5
            {22828, 22000, req=22827, rank=3}, -- Ferocious Bite rank 3
        },
        [50] = {
            {9862, 23000, req=8918, rank=3}, -- Tranquility rank 3
            {9866, 23000, req=6787, rank=3}, -- Ravage rank 3
            {9875, 23000, req=8951, rank=5}, -- Starfire rank 5
            {9880, 23000, req=9745, rank=6}, -- Maul rank 6
            {9884, 23000, req=8907, rank=6}, -- Mark of the Wild rank 6
            {9888, 23000, req=9758, rank=9}, -- Healing Touch rank 9
            {17401, 23000, req=16914, rank=2}, -- Hurricane rank 2
            {20747, 23000, req=20742, rank=4}, -- Rebirth rank 4
            {21849, 23000, rank=1}, -- Gift of the Wild rank 1
            {24976, 1150, req=24975, rank=4}, -- Insect Swarm rank 4
        },
        [52] = {
            {9834, 26000, req=9833, rank=9}, -- Moonfire rank 9
            {9840, 26000, req=9839, rank=9}, -- Rejuvenation rank 9
            {9892, 26000, req=9000, rank=3}, -- Cower rank 3
            {9894, 26000, req=9752, rank=5}, -- Rip rank 5
            {9898, 26000, req=9747, rank=5}, -- Demoralizing Roar rank 5
        },
        [54] = {
            {9830, 28000, req=9829, rank=5}, -- Shred rank 5
            {9857, 28000, req=9856, rank=8}, -- Regrowth rank 8
            {9901, 28000, req=8955, rank=3}, -- Soothe Animal rank 3
            {9904, 28000, req=1824, rank=4}, -- Rake rank 4
            {9907, 28000, req=9749, rank=4}, -- Faerie Fire rank 4
            {9908, 28000, req=9754, rank=5}, -- Swipe rank 5
            {9910, 28000, req=9756, rank=6}, -- Thorns rank 6
            {9912, 28000, req=8905, rank=8}, -- Wrath rank 8
            {17392, 1400, req=17391, rank=4}, -- Faerie Fire (Feral) rank 4
        },
        [56] = {
            {9827, 30000, req=9823, rank=3}, -- Pounce rank 3
            {9889, 30000, req=9888, rank=10}, -- Healing Touch rank 10
            {22829, 30000, req=22828, rank=4}, -- Ferocious Bite rank 4
            {22896, 30000, req=22895, rank=3}, -- Frenzied Regeneration rank 3
        },
        [58] = {
            {9835, 32000, req=9834, rank=10}, -- Moonfire rank 10
            {9841, 32000, req=9840, rank=10}, -- Rejuvenation rank 10
            {9850, 32000, req=9849, rank=5}, -- Claw rank 5
            {9853, 32000, req=9852, rank=6}, -- Entangling Roots rank 6
            {9867, 32000, req=9866, rank=4}, -- Ravage rank 4
            {9876, 32000, req=9875, rank=6}, -- Starfire rank 6
            {9881, 32000, req=9880, rank=7}, -- Maul rank 7
            {17329, 1600, req=16813, rank=6}, -- Nature's Grasp rank 6
            {18658, 32000, req=18657, rank=3}, -- Hibernate rank 3
            {33982, 1700, req=33876, rank=2}, -- Mangle (Cat) rank 2
            {33986, 1700, req=33878, rank=2}, -- Mangle (Bear) rank 2
        },
        [60] = {
            {9846, 34000, req=9845, rank=4}, -- Tiger's Fury rank 4
            {9858, 34000, req=9857, rank=9}, -- Regrowth rank 9
            {9863, 34000, req=9862, rank=4}, -- Tranquility rank 4
            {9885, 34000, req=9884, rank=7}, -- Mark of the Wild rank 7
            {9896, 34000, req=9894, rank=6}, -- Rip rank 6
            {9913, 34000, req=6783, rank=3}, -- Prowl rank 3
            {17402, 34000, req=17401, rank=3}, -- Hurricane rank 3
            {20748, 34000, req=20747, rank=5}, -- Rebirth rank 5
            {21850, 34000, req=21849, rank=2}, -- Gift of the Wild rank 2
            {24977, 1700, req=24976, rank=5}, -- Insect Swarm rank 5
            {25297, 34000, req=9889, rank=11}, -- Healing Touch rank 11
            {25298, 34000, req=9876, rank=7}, -- Starfire rank 7
            {25299, 34000, req=9841, rank=11}, -- Rejuvenation rank 11
            {31018, 30000, req=22829, rank=5}, -- Ferocious Bite rank 5
            {31709, 34000, req=9892, rank=4}, -- Cower rank 4
        },
        [61] = {
            {26984, 39000, req=9912, rank=9}, -- Wrath rank 9
            {27001, 39000, req=9830, rank=6}, -- Shred rank 6
        },
        [62] = {
            {22570, 43000, rank=1}, -- Maim rank 1
            {26978, 43000, req=25297, rank=12}, -- Healing Touch rank 12
            {26998, 43000, req=9898, rank=6}, -- Demoralizing Roar rank 6
        },
        [63] = {
            {24248, 48000, req=31018, rank=6}, -- Ferocious Bite rank 6
            {26981, 48000, req=25299, rank=12}, -- Rejuvenation rank 12
            {26987, 48000, req=9835, rank=11}, -- Moonfire rank 11
        },
        [64] = {
            {26992, 53000, req=9910, rank=7}, -- Thorns rank 7
            {26997, 53000, req=9908, rank=6}, -- Swipe rank 6
            {27003, 53000, req=9904, rank=5}, -- Rake rank 5
            {33763, 53000, rank=1}, -- Lifebloom rank 1
        },
        [65] = {
            {26980, 59000, req=9858, rank=10}, -- Regrowth rank 10
            {26999, 59000, req=22896, rank=4}, -- Frenzied Regeneration rank 4
            {33357, 59000, req=9821, rank=3}, -- Dash rank 3
        },
        [66] = {
            {26993, 34000, req=9907, rank=5}, -- Faerie Fire rank 5
            {27005, 66000, req=9867, rank=5}, -- Ravage rank 5
            {27006, 66000, req=9827, rank=4}, -- Pounce rank 4
            {27011, 1700, req=17392, rank=5}, -- Faerie Fire (Feral) rank 5
            {33745, 66000, rank=1}, -- Lacerate rank 1
        },
        [67] = {
            {26986, 73000, req=25298, rank=8}, -- Starfire rank 8
            {26996, 73000, req=9881, rank=8}, -- Maul rank 8
            {27000, 73000, req=9850, rank=6}, -- Claw rank 6
            {27008, 73000, req=9896, rank=7}, -- Rip rank 7
        },
        [68] = {
            {26989, 81000, req=9853, rank=7}, -- Entangling Roots rank 7
            {27009, 1700, req=17329, rank=7}, -- Nature's Grasp rank 7
            {33943, 81000}, -- Flight Form
            {33983, 1700, req=33982, rank=3}, -- Mangle (Cat) rank 3
            {33987, 1900, req=33986, rank=3}, -- Mangle (Bear) rank 3
        },
        [69] = {
            {26979, 90000, req=26978, rank=13}, -- Healing Touch rank 13
            {26982, 90000, req=26981, rank=13}, -- Rejuvenation rank 13
            {26985, 90000, req=26984, rank=10}, -- Wrath rank 10
            {26994, 90000, req=20748, rank=6}, -- Rebirth rank 6
            {27004, 90000, req=31709, rank=5}, -- Cower rank 5
        },
        [70] = {
            {26983, 100000, req=9863, rank=5}, -- Tranquility rank 5
            {26988, 100000, req=26987, rank=12}, -- Moonfire rank 12
            {26990, 100000, req=9885, rank=8}, -- Mark of the Wild rank 8
            {26995, 100000, req=9901, rank=4}, -- Soothe Animal rank 4
            {27002, 100000, req=27001, rank=7}, -- Shred rank 7
            {27012, 100000, req=17402, rank=4}, -- Hurricane rank 4
            {27013, 2500, req=24977, rank=6}, -- Insect Swarm rank 6
            {33786, 100000}, -- Cyclone
        },
    },
    ROGUE = {
        [1] = {
            {1784, 10, rank=1}, -- Stealth rank 1
            {1804, 1800}, -- Pick Lock
        },
        [4] = {
            {53, 100, rank=1}, -- Backstab rank 1
            {921, 100}, -- Pick Pocket
        },
        [6] = {
            {1757, 100, req=26862, rank=2}, -- Sinister Strike rank 2
            {1776, 100, rank=1}, -- Gouge rank 1
        },
        [8] = {
            {5277, 200, rank=1}, -- Evasion rank 1
            {6760, 200, req=26865, rank=2}, -- Eviscerate rank 2
        },
        [10] = {
            {2983, 300, rank=1}, -- Sprint rank 1
            {5171, 300, rank=1}, -- Slice and Dice rank 1
            {6770, 300, rank=1}, -- Sap rank 1
        },
        [12] = {
            {1766, 800, rank=1}, -- Kick rank 1
            {2589, 800, req=26863, rank=2}, -- Backstab rank 2
        },
        [14] = {
            {703, 1200, rank=1}, -- Garrote rank 1
            {1758, 1200, req=1757, rank=3}, -- Sinister Strike rank 3
            {8647, 1200, rank=1}, -- Expose Armor rank 1
        },
        [16] = {
            {1966, 1800, rank=1}, -- Feint rank 1
            {6761, 1800, req=6760, rank=3}, -- Eviscerate rank 3
        },
        [18] = {
            {1777, 2900, req=1776, rank=2}, -- Gouge rank 2
            {8676, 2900, rank=1}, -- Ambush rank 1
        },
        [20] = {
            {1785, 3000, req=1784, rank=2}, -- Stealth rank 2
            {1943, 3000, rank=1}, -- Rupture rank 1
            {2590, 3000, req=2589, rank=3}, -- Backstab rank 3
            {3420, 3000, rank=1}, -- Crippling Poison rank 1
        },
        [22] = {
            {1725, 4000}, -- Distract
            {1759, 4000, req=1758, rank=4}, -- Sinister Strike rank 4
            {1856, 4000, rank=1}, -- Vanish rank 1
            {8631, 4000, req=703, rank=2}, -- Garrote rank 2
        },
        [24] = {
            {2836, 5000}, -- Detect Traps
            {5763, 5000, rank=1}, -- Mind-numbing Poison rank 1
            {6762, 5000, req=6761, rank=4}, -- Eviscerate rank 4
        },
        [26] = {
            {1767, 6000, req=1766, rank=2}, -- Kick rank 2
            {1833, 6000}, -- Cheap Shot
            {8649, 6000, req=8647, rank=2}, -- Expose Armor rank 2
            {8724, 6000, req=8676, rank=2}, -- Ambush rank 2
        },
        [28] = {
            {2070, 8000, req=6770, rank=2}, -- Sap rank 2
            {2591, 8000, req=2590, rank=4}, -- Backstab rank 4
            {6768, 8000, req=1966, rank=2}, -- Feint rank 2
            {8639, 8000, req=1943, rank=2}, -- Rupture rank 2
            {8687, 8000, req=8681, rank=2}, -- Instant Poison II rank 2
        },
        [30] = {
            {408, 10000, rank=1}, -- Kidney Shot rank 1
            {1760, 10000, req=1759, rank=5}, -- Sinister Strike rank 5
            {1842, 10000}, -- Disarm Trap
            {2835, 10000, rank=1}, -- Deadly Poison rank 1
            {8632, 10000, req=8631, rank=3}, -- Garrote rank 3
        },
        [32] = {
            {8623, 12000, req=6762, rank=5}, -- Eviscerate rank 5
            {8629, 12000, req=1777, rank=3}, -- Gouge rank 3
            {13220, 12000, rank=1}, -- Wound Poison rank 1
        },
        [34] = {
            {2094, 14000}, -- Blind
            {8696, 14000, req=2983, rank=2}, -- Sprint rank 2
            {8725, 14000, req=8724, rank=3}, -- Ambush rank 3
        },
        [36] = {
            {8640, 16000, req=8639, rank=3}, -- Rupture rank 3
            {8650, 16000, req=8649, rank=3}, -- Expose Armor rank 3
            {8691, 16000, req=8687, rank=3}, -- Instant Poison III rank 3
            {8721, 16000, req=2591, rank=5}, -- Backstab rank 5
        },
        [38] = {
            {2837, 18000, req=2835, rank=2}, -- Deadly Poison II rank 2
            {8621, 18000, req=1760, rank=6}, -- Sinister Strike rank 6
            {8633, 18000, req=8632, rank=4}, -- Garrote rank 4
            {8694, 18000, req=5763, rank=2}, -- Mind-numbing Poison II rank 2
        },
        [40] = {
            {1786, 20000, req=1785, rank=3}, -- Stealth rank 3
            {1860, 20000}, -- Safe Fall
            {8624, 20000, req=8623, rank=6}, -- Eviscerate rank 6
            {8637, 20000, req=6768, rank=3}, -- Feint rank 3
            {13228, 20000, req=13220, rank=2}, -- Wound Poison II rank 2
        },
        [42] = {
            {1768, 27000, req=1767, rank=3}, -- Kick rank 3
            {1857, 27000, req=1856, rank=2}, -- Vanish rank 2
            {6774, 27000, req=5171, rank=2}, -- Slice and Dice rank 2
            {11267, 27000, req=8725, rank=4}, -- Ambush rank 4
        },
        [44] = {
            {11273, 29000, req=8640, rank=4}, -- Rupture rank 4
            {11279, 29000, req=8721, rank=6}, -- Backstab rank 6
            {11341, 29000, req=8691, rank=4}, -- Instant Poison IV rank 4
        },
        [46] = {
            {11197, 31000, req=8650, rank=4}, -- Expose Armor rank 4
            {11285, 31000, req=8629, rank=4}, -- Gouge rank 4
            {11289, 31000, req=8633, rank=5}, -- Garrote rank 5
            {11293, 31000, req=8621, rank=7}, -- Sinister Strike rank 7
            {11357, 31000, req=2837, rank=3}, -- Deadly Poison III rank 3
            {17347, 7750, rank=2}, -- Hemorrhage rank 2
        },
        [48] = {
            {11297, 33000, req=2070, rank=3}, -- Sap rank 3
            {11299, 33000, req=8624, rank=7}, -- Eviscerate rank 7
            {13229, 33000, req=13228, rank=3}, -- Wound Poison III rank 3
        },
        [50] = {
            {3421, 35000, req=3420, rank=2}, -- Crippling Poison II rank 2
            {8643, 35000, req=408, rank=2}, -- Kidney Shot rank 2
            {11268, 35000, req=11267, rank=5}, -- Ambush rank 5
            {26669, 35000, req=5277, rank=2}, -- Evasion rank 2
            {34411, 5500, rank=2}, -- Mutilate rank 2
        },
        [52] = {
            {11274, 46000, req=11273, rank=5}, -- Rupture rank 5
            {11280, 46000, req=11279, rank=7}, -- Backstab rank 7
            {11303, 46000, req=8637, rank=4}, -- Feint rank 4
            {11342, 46000, req=11341, rank=5}, -- Instant Poison V rank 5
            {11400, 46000, req=8694, rank=3}, -- Mind-numbing Poison III rank 3
        },
        [54] = {
            {11290, 48000, req=11289, rank=6}, -- Garrote rank 6
            {11294, 48000, req=11293, rank=8}, -- Sinister Strike rank 8
            {11358, 48000, req=11357, rank=4}, -- Deadly Poison IV rank 4
        },
        [56] = {
            {11198, 50000, req=11197, rank=5}, -- Expose Armor rank 5
            {11300, 50000, req=11299, rank=8}, -- Eviscerate rank 8
            {13230, 50000, req=13229, rank=4}, -- Wound Poison IV rank 4
        },
        [58] = {
            {1769, 52000, req=1768, rank=4}, -- Kick rank 4
            {11269, 52000, req=11268, rank=6}, -- Ambush rank 6
            {11305, 52000, req=8696, rank=3}, -- Sprint rank 3
            {17348, 13000, req=17347, rank=3}, -- Hemorrhage rank 3
        },
        [60] = {
            {1787, 54000, req=1786, rank=4}, -- Stealth rank 4
            {11275, 54000, req=11274, rank=6}, -- Rupture rank 6
            {11281, 54000, req=11280, rank=8}, -- Backstab rank 8
            {11286, 54000, req=11285, rank=5}, -- Gouge rank 5
            {11343, 54000, req=11342, rank=6}, -- Instant Poison VI rank 6
            {25302, 50000, req=11303, rank=5}, -- Feint rank 5
            {25347, 54000, req=11358, rank=5}, -- Deadly Poison V rank 5
            {31016, 65000, req=11300, rank=9}, -- Eviscerate rank 9
            {34412, 6500, req=34411, rank=3}, -- Mutilate rank 3
        },
        [61] = {
            {26839, 50000, req=11290, rank=7}, -- Garrote rank 7
        },
        [62] = {
            {26861, 50000, req=11294, rank=9}, -- Sinister Strike rank 9
            {26889, 59000, req=1857, rank=3}, -- Vanish rank 3
            {26969, 65000, req=25347, rank=6}, -- Deadly Poison VI rank 6
            {32645, 59000, rank=1}, -- Envenom rank 1
            --{25300, 54000, req=11281, rank=9}, -- Backstab rank 9
        },
        [64] = {
            {26679, 72000, rank=1}, -- Deadly Throw rank 1
            {26865, 140000, rank=10}, -- Eviscerate rank 10
            {27283, 80000, req=13230, rank=5}, -- Wound Poison V rank 5
            {27448, 72000, req=25302, rank=6}, -- Feint rank 6
        },
        [66] = {
            {26866, 99000, req=11198, rank=6}, -- Expose Armor rank 6
            {27441, 80000, req=11269, rank=7}, -- Ambush rank 7
            {31224, 89000}, -- Cloak of Shadows
        },
        [67] = {
            {38764, 99000, req=11286, rank=6}, -- Gouge rank 6
        },
        [68] = {
            {26786, 110000, rank=1}, -- Anesthetic Poison rank 1
            {26863, 110000, rank=10}, -- Backstab rank 10
            {26867, 120000, req=11275, rank=7}, -- Rupture rank 7
            {26892, 110000, req=11343, rank=7}, -- Instant Poison VII rank 7
        },
        [69] = {
            {32684, 120000, req=32645, rank=2}, -- Envenom rank 2
            {38768, 120000, req=1769, rank=5}, -- Kick rank 5
        },
        [70] = {
            {5938, 140000, rank=1}, -- Shiv rank 1
            {26862, 140000, rank=10}, -- Sinister Strike rank 10
            {26864, 2700, req=17348, rank=4}, -- Hemorrhage rank 4
            {26884, 140000, req=26839, rank=8}, -- Garrote rank 8
            {27282, 140000, req=26969, rank=7}, -- Deadly Poison VII rank 7
            {34413, 7500, req=34412, rank=4}, -- Mutilate rank 4
        },
    },
    SHAMAN = {
        [1] = {
            {8017, 10, rank=1}, -- Rockbiter Weapon rank 1
        },
        [4] = {
            {8042, 100, rank=1}, -- Earth Shock rank 1
        },
        [6] = {
            {332, 100, req=331, rank=2}, -- Healing Wave rank 2
            {2484, 100}, -- Earthbind Totem
        },
        [8] = {
            {324, 100, rank=1}, -- Lightning Shield rank 1
            {529, 100, req=403, rank=2}, -- Lightning Bolt rank 2
            {5730, 100, rank=1}, -- Stoneclaw Totem rank 1
            {8018, 100, req=8017, rank=2}, -- Rockbiter Weapon rank 2
            {8044, 100, req=8042, rank=2}, -- Earth Shock rank 2
        },
        [10] = {
            {8024, 400, rank=1}, -- Flametongue Weapon rank 1
            {8050, 400, rank=1}, -- Flame Shock rank 1
            {8075, 400, rank=1}, -- Strength of Earth Totem rank 1
        },
        [12] = {
            {370, 800, rank=1}, -- Purge rank 1
            {547, 800, req=332, rank=3}, -- Healing Wave rank 3
            {1535, 800, rank=1}, -- Fire Nova Totem rank 1
            {2008, 800, rank=1}, -- Ancestral Spirit rank 1
        },
        [14] = {
            {548, 900, req=529, rank=3}, -- Lightning Bolt rank 3
            {8045, 900, req=8044, rank=3}, -- Earth Shock rank 3
            {8154, 900, req=8071, rank=2}, -- Stoneskin Totem rank 2
        },
        [16] = {
            {325, 1800, req=324, rank=2}, -- Lightning Shield rank 2
            {526, 1800}, -- Cure Poison
            {8019, 1800, req=8018, rank=3}, -- Rockbiter Weapon rank 3
        },
        [18] = {
            {913, 2000, req=547, rank=4}, -- Healing Wave rank 4
            {6390, 2000, req=5730, rank=2}, -- Stoneclaw Totem rank 2
            {8027, 2000, req=8024, rank=2}, -- Flametongue Weapon rank 2
            {8052, 2000, req=8050, rank=2}, -- Flame Shock rank 2
            {8143, 2000}, -- Tremor Totem
        },
        [20] = {
            {915, 2200, req=548, rank=4}, -- Lightning Bolt rank 4
            {2645, 2200}, -- Ghost Wolf
            {6363, 2200, req=3599, rank=2}, -- Searing Totem rank 2
            {8004, 2200, rank=1}, -- Lesser Healing Wave rank 1
            {8033, 2200, rank=1}, -- Frostbrand Weapon rank 1
            {8056, 2200, rank=1}, -- Frost Shock rank 1
        },
        [22] = {
            {131, 3000}, -- Water Breathing
            {2870, 3000}, -- Cure Disease
            {8166, 3000}, -- Poison Cleansing Totem
            {8498, 3000, req=1535, rank=2}, -- Fire Nova Totem rank 2
        },
        [24] = {
            {905, 3500, req=325, rank=3}, -- Lightning Shield rank 3
            {939, 3500, req=913, rank=5}, -- Healing Wave rank 5
            {8046, 3500, req=8045, rank=4}, -- Earth Shock rank 4
            {8155, 3500, req=8154, rank=3}, -- Stoneskin Totem rank 3
            {8160, 3500, req=8075, rank=2}, -- Strength of Earth Totem rank 2
            {8181, 3500, rank=1}, -- Frost Resistance Totem rank 1
            {10399, 3500, req=8019, rank=4}, -- Rockbiter Weapon rank 4
            {20609, 3500, req=2008, rank=2}, -- Ancestral Spirit rank 2
        },
        [26] = {
            {943, 4000, req=915, rank=5}, -- Lightning Bolt rank 5
            {5675, 4000, rank=1}, -- Mana Spring Totem rank 1
            {6196, 4000}, -- Far Sight
            {8030, 4000, req=8027, rank=3}, -- Flametongue Weapon rank 3
            {8190, 4000, rank=1}, -- Magma Totem rank 1
        },
        [28] = {
            {546, 6000}, -- Water Walking
            {6391, 6000, req=6390, rank=3}, -- Stoneclaw Totem rank 3
            {8008, 6000, req=8004, rank=2}, -- Lesser Healing Wave rank 2
            {8038, 6000, req=8033, rank=2}, -- Frostbrand Weapon rank 2
            {8053, 6000, req=8052, rank=3}, -- Flame Shock rank 3
            {8184, 6000, rank=1}, -- Fire Resistance Totem rank 1
            {8227, 6000, rank=1}, -- Flametongue Totem rank 1
        },
        [30] = {
            {556, 7000}, -- Astral Recall
            {6364, 7000, req=6363, rank=3}, -- Searing Totem rank 3
            {6375, 7000, req=5394, rank=2}, -- Healing Stream Totem rank 2
            {8177, 7000}, -- Grounding Totem
            {8232, 7000, rank=1}, -- Windfury Weapon rank 1
            {10595, 7000, rank=1}, -- Nature Resistance Totem rank 1
            {20608, 7000}, -- Reincarnation
            {36936, 7000}, -- Totemic Call
        },
        [32] = {
            {421, 8000, rank=1}, -- Chain Lightning rank 1
            {945, 8000, req=905, rank=4}, -- Lightning Shield rank 4
            {959, 8000, req=939, rank=6}, -- Healing Wave rank 6
            {6041, 8000, req=943, rank=6}, -- Lightning Bolt rank 6
            {8012, 8000, req=370, rank=2}, -- Purge rank 2
            {8499, 8000, req=8498, rank=3}, -- Fire Nova Totem rank 3
            {8512, 8000, rank=1}, -- Windfury Totem rank 1
        },
        [34] = {
            {6495, 9000}, -- Sentry Totem
            {8058, 9000, req=8056, rank=2}, -- Frost Shock rank 2
            {10406, 9000, req=8155, rank=4}, -- Stoneskin Totem rank 4
            {16314, 9000, req=10399, rank=5}, -- Rockbiter Weapon rank 5
        },
        [36] = {
            {8010, 10000, req=8008, rank=3}, -- Lesser Healing Wave rank 3
            {10412, 10000, req=8046, rank=5}, -- Earth Shock rank 5
            {10495, 10000, req=5675, rank=2}, -- Mana Spring Totem rank 2
            {10585, 10000, req=8190, rank=2}, -- Magma Totem rank 2
            {15107, 10000, rank=1}, -- Windwall Totem rank 1
            {16339, 10000, req=8030, rank=4}, -- Flametongue Weapon rank 4
            {20610, 10000, req=20609, rank=3}, -- Ancestral Spirit rank 3
        },
        [38] = {
            {6392, 11000, req=6391, rank=4}, -- Stoneclaw Totem rank 4
            {8161, 11000, req=8160, rank=3}, -- Strength of Earth Totem rank 3
            {8170, 11000}, -- Disease Cleansing Totem
            {8249, 11000, req=8227, rank=2}, -- Flametongue Totem rank 2
            {10391, 11000, req=6041, rank=7}, -- Lightning Bolt rank 7
            {10456, 11000, req=8038, rank=3}, -- Frostbrand Weapon rank 3
            {10478, 11000, req=8181, rank=2}, -- Frost Resistance Totem rank 2
        },
        [40] = {
            {930, 12000, req=421, rank=2}, -- Chain Lightning rank 2
            {1064, 12000, rank=1}, -- Chain Heal rank 1
            {6365, 12000, req=6364, rank=4}, -- Searing Totem rank 4
            {6377, 12000, req=6375, rank=3}, -- Healing Stream Totem rank 3
            {8005, 12000, req=959, rank=7}, -- Healing Wave rank 7
            {8134, 12000, req=945, rank=5}, -- Lightning Shield rank 5
            {8235, 12000, req=8232, rank=2}, -- Windfury Weapon rank 2
            {10447, 12000, req=8053, rank=4}, -- Flame Shock rank 4
        },
        [42] = {
            {8835, 16000, rank=1}, -- Grace of Air Totem rank 1
            {10537, 16000, req=8184, rank=2}, -- Fire Resistance Totem rank 2
            {10613, 16000, req=8512, rank=2}, -- Windfury Totem rank 2
            {11314, 16000, req=8499, rank=4}, -- Fire Nova Totem rank 4
        },
        [44] = {
            {10392, 18000, req=10391, rank=8}, -- Lightning Bolt rank 8
            {10407, 18000, req=10406, rank=5}, -- Stoneskin Totem rank 5
            {10466, 18000, req=8010, rank=4}, -- Lesser Healing Wave rank 4
            {10600, 18000, req=10595, rank=2}, -- Nature Resistance Totem rank 2
            {16315, 18000, req=16314, rank=6}, -- Rockbiter Weapon rank 6
        },
        [46] = {
            {10472, 20000, req=8058, rank=3}, -- Frost Shock rank 3
            {10496, 20000, req=10495, rank=3}, -- Mana Spring Totem rank 3
            {10586, 20000, req=10585, rank=3}, -- Magma Totem rank 3
            {10622, 20000, req=1064, rank=2}, -- Chain Heal rank 2
            {15111, 20000, req=15107, rank=2}, -- Windwall Totem rank 2
            {16341, 20000, req=16339, rank=5}, -- Flametongue Weapon rank 5
        },
        [48] = {
            {2860, 22000, req=930, rank=3}, -- Chain Lightning rank 3
            {10395, 22000, req=8005, rank=8}, -- Healing Wave rank 8
            {10413, 22000, req=10412, rank=6}, -- Earth Shock rank 6
            {10427, 22000, req=6392, rank=5}, -- Stoneclaw Totem rank 5
            {10431, 22000, req=8134, rank=6}, -- Lightning Shield rank 6
            {10526, 22000, req=8249, rank=3}, -- Flametongue Totem rank 3
            {16355, 22000, req=10456, rank=4}, -- Frostbrand Weapon rank 4
            {20776, 22000, req=20610, rank=4}, -- Ancestral Spirit rank 4
        },
        [50] = {
            {10437, 24000, req=6365, rank=5}, -- Searing Totem rank 5
            {10462, 24000, req=6377, rank=4}, -- Healing Stream Totem rank 4
            {10486, 24000, req=8235, rank=3}, -- Windfury Weapon rank 3
            {15207, 24000, req=10392, rank=9}, -- Lightning Bolt rank 9
            {25908, 24000}, -- Tranquil Air Totem
        },
        [52] = {
            {10442, 27000, req=8161, rank=4}, -- Strength of Earth Totem rank 4
            {10448, 27000, req=10447, rank=5}, -- Flame Shock rank 5
            {10467, 27000, req=10466, rank=5}, -- Lesser Healing Wave rank 5
            {10614, 27000, req=10613, rank=3}, -- Windfury Totem rank 3
            {11315, 27000, req=11314, rank=5}, -- Fire Nova Totem rank 5
        },
        [54] = {
            {10408, 29000, req=10407, rank=6}, -- Stoneskin Totem rank 6
            {10479, 20000, req=10478, rank=3}, -- Frost Resistance Totem rank 3
            {10623, 29000, req=10622, rank=3}, -- Chain Heal rank 3
            {16316, 29000, req=16315, rank=7}, -- Rockbiter Weapon rank 7
        },
        [56] = {
            {10396, 30000, req=10395, rank=9}, -- Healing Wave rank 9
            {10432, 30000, req=10431, rank=7}, -- Lightning Shield rank 7
            {10497, 30000, req=10496, rank=4}, -- Mana Spring Totem rank 4
            {10587, 30000, req=10586, rank=4}, -- Magma Totem rank 4
            {10605, 30000, req=2860, rank=4}, -- Chain Lightning rank 4
            {10627, 30000, req=8835, rank=2}, -- Grace of Air Totem rank 2
            {15112, 30000, req=15111, rank=3}, -- Windwall Totem rank 3
            {15208, 30000, req=15207, rank=10}, -- Lightning Bolt rank 10
            {16342, 30000, req=16341, rank=6}, -- Flametongue Weapon rank 6
        },
        [58] = {
            {10428, 32000, req=10427, rank=6}, -- Stoneclaw Totem rank 6
            {10473, 32000, req=10472, rank=4}, -- Frost Shock rank 4
            {10538, 29000, req=10537, rank=3}, -- Fire Resistance Totem rank 3
            {16356, 32000, req=16355, rank=5}, -- Frostbrand Weapon rank 5
            {16387, 32000, req=10526, rank=4}, -- Flametongue Totem rank 4
        },
        [60] = {
            {10414, 34000, req=10413, rank=7}, -- Earth Shock rank 7
            {10438, 34000, req=10437, rank=6}, -- Searing Totem rank 6
            {10463, 34000, req=10462, rank=5}, -- Healing Stream Totem rank 5
            {10468, 34000, req=10467, rank=6}, -- Lesser Healing Wave rank 6
            {10601, 34000, req=10600, rank=3}, -- Nature Resistance Totem rank 3
            {16362, 34000, req=10486, rank=4}, -- Windfury Weapon rank 4
            {20777, 34000, req=20776, rank=5}, -- Ancestral Spirit rank 5
            {25357, 6500, req=10396, rank=10}, -- Healing Wave rank 10
            {25359, 65000, req=10627, rank=3}, -- Grace of Air Totem rank 3
            {25361, 34000, req=10442, rank=5}, -- Strength of Earth Totem rank 5
            {29228, 65000, req=10448, rank=6}, -- Flame Shock rank 6
            {32593, 1700, req=974, rank=2}, -- Earth Shield rank 2
        },
        [61] = {
            {25422, 34000, req=10623, rank=4}, -- Chain Heal rank 4
            {25546, 34000, req=11315, rank=6}, -- Fire Nova Totem rank 6
            {25585, 34000, req=10614, rank=4}, -- Windfury Totem rank 4
        },
        [62] = {
            {24398, 38000, rank=1}, -- Water Shield rank 1
            {25448, 38000, req=15208, rank=11}, -- Lightning Bolt rank 11
            {25479, 38000, req=16316, rank=8}, -- Rockbiter Weapon rank 8
        },
        [63] = {
            {25391, 42000, req=25357, rank=11}, -- Healing Wave rank 11
            {25439, 42000, req=10605, rank=5}, -- Chain Lightning rank 5
            {25469, 42000, req=10432, rank=8}, -- Lightning Shield rank 8
            {25508, 42000, req=10408, rank=7}, -- Stoneskin Totem rank 7
        },
        [64] = {
            {3738, 47000, rank=1}, -- Wrath of Air Totem rank 1
            {25489, 47000, req=16342, rank=7}, -- Flametongue Weapon rank 7
        },
        [65] = {
            {25528, 52000, req=25361, rank=6}, -- Strength of Earth Totem rank 6
            {25552, 52000, req=10587, rank=5}, -- Magma Totem rank 5
            {25570, 52000, req=10497, rank=5}, -- Mana Spring Totem rank 5
            {25577, 52000, req=15112, rank=4}, -- Windwall Totem rank 4
        },
        [66] = {
            {2062, 58000, rank=1}, -- Earth Elemental Totem rank 1
            {25420, 58000, req=10468, rank=7}, -- Lesser Healing Wave rank 7
            {25500, 58000, req=16356, rank=6}, -- Frostbrand Weapon rank 6
        },
        [67] = {
            {25449, 64000, req=25448, rank=12}, -- Lightning Bolt rank 12
            {25525, 64000, req=10428, rank=7}, -- Stoneclaw Totem rank 7
            {25557, 64000, req=16387, rank=5}, -- Flametongue Totem rank 5
            {25560, 64000, req=10479, rank=4}, -- Frost Resistance Totem rank 4
        },
        [68] = {
            {2894, 71000, rank=1}, -- Fire Elemental Totem rank 1
            {25423, 71000, req=25422, rank=5}, -- Chain Heal rank 5
            {25464, 71000, req=10473, rank=5}, -- Frost Shock rank 5
            {25505, 71000, req=16362, rank=5}, -- Windfury Weapon rank 5
            {25563, 71000, req=10538, rank=4}, -- Fire Resistance Totem rank 4
        },
        [69] = {
            {25454, 79000, req=10414, rank=8}, -- Earth Shock rank 8
            {25567, 79000, req=10463, rank=6}, -- Healing Stream Totem rank 6
            {25574, 79000, req=10601, rank=4}, -- Nature Resistance Totem rank 4
            {33736, 79000, req=24398, rank=2}, -- Water Shield rank 2
            {25533, 70000, req=10438, rank=7}, -- Searing Totem rank 7
        },
        [70] = {
            {2825, 88000, rank=1, faction="Horde"}, -- Bloodlust rank 1
            {25396, 88000, req=25391, rank=12}, -- Healing Wave rank 12
            {25442, 88000, req=25439, rank=6}, -- Chain Lightning rank 6
            {25457, 88000, req=29228, rank=7}, -- Flame Shock rank 7
            {25472, 88000, req=25469, rank=9}, -- Lightning Shield rank 9
            {25485, 88000, req=25479, rank=9}, -- Rockbiter Weapon rank 9
            {25509, 88000, req=25508, rank=8}, -- Stoneskin Totem rank 8
            {25547, 88000, req=25546, rank=7}, -- Fire Nova Totem rank 7
            {25587, 88000, req=25585, rank=5}, -- Windfury Totem rank 5
            {32182, 88000, rank=1, faction="Alliance"}, -- Heroism
            {32594, 2500, req=32593, rank=3}, -- Earth Shield rank 3
        },
    },
}