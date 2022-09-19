local _, GW = ...

GW.Skills = {
    HUNTER = {
        [0] = {
            {196, 1000, }, -- One-Handed Axes 
            {197, 1000, }, -- Two-Handed Axes 
            {201, 1000, }, -- One-Handed Swords 
            {202, 1000, }, -- Two-Handed Swords 
            {227, 1000, }, -- Staves 
            {264, 1000, }, -- Bows 
            {266, 1000, }, -- Guns 
            {1180, 1000, }, -- Daggers 
            {5011, 1000, }, -- Crossbows 
            {15590, 1000, }, -- Fist Weapons 
        },
        [2] = {
            {1494, 10, }, -- Track Beasts 
        },
        [4] = {
            {1978, 100, }, -- Serpent Sting Rank 1
            {13163, 100, }, -- Aspect of the Monkey 
        },
        [6] = {
            {1130, 100, }, -- Hunter's Mark Rank 1
            {3044, 100, }, -- Arcane Shot Rank 1
        },
        [8] = {
            {5116, 200, }, -- Concussive Shot 
            {14260, 200, req=2973}, -- Raptor Strike Rank 2
        },
        [10] = {
            {674, 300, }, -- Dual Wield Passive
            {13165, 400, }, -- Aspect of the Hawk Rank 1
            {13549, 400, req=1978}, -- Serpent Sting Rank 2
            {19883, 400, }, -- Track Humanoids 
        },
        [12] = {
            {136, 600, }, -- Mend Pet Rank 1
            {2974, 600, }, -- Wing Clip 
            {14281, 600, req=3044}, -- Arcane Shot Rank 2
            {20736, 600, }, -- Distracting Shot Rank 1
            {3127, 800, }, -- Parry Passive
        },
        [14] = {
            {1002, 1200, }, -- Eyes of the Beast 
            {1513, 1200, }, -- Scare Beast Rank 1
            {6197, 1200, }, -- Eagle Eye 
        },
        [16] = {
            {1495, 1800, }, -- Mongoose Bite Rank 1
            {13795, 1800, }, -- Immolation Trap Rank 1
            {14261, 1800, req=14260}, -- Raptor Strike Rank 3
            {5118, 2200, }, -- Aspect of the Cheetah 
        },
        [18] = {
            {2643, 2000, }, -- Multi-Shot Rank 1
            {13550, 2000, req=13549}, -- Serpent Sting Rank 3
            {14318, 2000, req=13165}, -- Aspect of the Hawk Rank 2
            {19884, 2000, }, -- Track Undead 
        },
        [20] = {
            {781, 2200, }, -- Disengage 
            {1499, 2200, }, -- Freezing Trap Rank 1
            {3111, 2200, req=136}, -- Mend Pet Rank 2
            {14282, 2200, req=14281}, -- Arcane Shot Rank 3
            {200, 10000, }, -- Polearms 
            {34074, 100000, }, -- Aspect of the Viper 
        },
        [22] = {
            {3043, 6000, }, -- Scorpid Sting 
            {14323, 6000, req=1130}, -- Hunter's Mark Rank 2
        },
        [24] = {
            {1462, 7000, }, -- Beast Lore 
            {14262, 7000, req=14261}, -- Raptor Strike Rank 4
            {19885, 7000, }, -- Track Hidden 
        },
        [26] = {
            {3045, 7000, }, -- Rapid Fire 
            {13551, 7000, req=13550}, -- Serpent Sting Rank 4
            {14302, 7000, req=13795}, -- Immolation Trap Rank 2
            {19880, 7000, }, -- Track Elementals 
        },
        [28] = {
            {20900, 400, req=19434}, -- Aimed Shot Rank 2
            {3661, 8000, req=3111}, -- Mend Pet Rank 3
            {13809, 8000, }, -- Frost Trap 
            {14283, 8000, req=14282}, -- Arcane Shot Rank 4
            {14319, 8000, req=14318}, -- Aspect of the Hawk Rank 3
        },
        [30] = {
            {5384, 8000, }, -- Feign Death 
            {13161, 8000, }, -- Aspect of the Beast 
            {14269, 8000, req=1495}, -- Mongoose Bite Rank 2
            {14288, 8000, req=2643}, -- Multi-Shot Rank 2
            {14326, 8000, req=1513}, -- Scare Beast Rank 2
        },
        [32] = {
            {1543, 10000, }, -- Flare 
            {14263, 10000, req=14262}, -- Raptor Strike Rank 5
            {19878, 10000, }, -- Track Demons 
        },
        [34] = {
            {13552, 12000, req=13551}, -- Serpent Sting Rank 5
            {13813, 12000, }, -- Explosive Trap Rank 1
        },
        [36] = {
            {20901, 700, req=20900}, -- Aimed Shot Rank 3
            {3034, 14000, }, -- Viper Sting 
            {3662, 14000, req=3661}, -- Mend Pet Rank 4
            {14284, 14000, req=14283}, -- Arcane Shot Rank 5
            {14303, 14000, req=14302}, -- Immolation Trap Rank 3
        },
        [38] = {
            {14320, 16000, req=14319}, -- Aspect of the Hawk Rank 4
        },
        [40] = {
            {8737, 12000, }, -- Mail 
            {1510, 18000, }, -- Volley Rank 1
            {13159, 18000, }, -- Aspect of the Pack 
            {14264, 18000, req=14263}, -- Raptor Strike Rank 6
            {14310, 18000, req=1499}, -- Freezing Trap Rank 2
            {14324, 18000, req=14323}, -- Hunter's Mark Rank 3
            {19882, 18000, }, -- Track Giants 
        },
        [42] = {
            {20909, 1200, req=19306}, -- Counterattack Rank 2
            {13553, 24000, req=13552}, -- Serpent Sting Rank 6
            {14289, 24000, req=14288}, -- Multi-Shot Rank 3
        },
        [44] = {
            {20902, 1300, req=20901}, -- Aimed Shot Rank 4
            {13542, 26000, req=3662}, -- Mend Pet Rank 5
            {14270, 26000, req=14269}, -- Mongoose Bite Rank 3
            {14285, 26000, req=14284}, -- Arcane Shot Rank 6
            {14316, 26000, req=13813}, -- Explosive Trap Rank 2
        },
        [46] = {
            {14304, 28000, req=14303}, -- Immolation Trap Rank 4
            {14327, 28000, req=14326}, -- Scare Beast Rank 3
            {20043, 28000, }, -- Aspect of the Wild Rank 1
        },
        [48] = {
            {14265, 32000, req=14264}, -- Raptor Strike Rank 7
            {14321, 32000, req=14320}, -- Aspect of the Hawk Rank 5
        },
        [50] = {
            {24132, 1800, req=19386}, -- Wyvern Sting Rank 2
            {13554, 36000, req=13553}, -- Serpent Sting Rank 7
            {14294, 36000, req=1510}, -- Volley Rank 2
            {19879, 36000, }, -- Track Dragonkin 
            {56641, 36000, }, -- Steady Shot Rank 1
        },
        [52] = {
            {20903, 2000, req=20902}, -- Aimed Shot Rank 5
            {13543, 40000, req=13542}, -- Mend Pet Rank 6
            {14286, 40000, req=14285}, -- Arcane Shot Rank 7
        },
        [54] = {
            {20910, 2100, req=20909}, -- Counterattack Rank 3
            {14290, 42000, req=14289}, -- Multi-Shot Rank 4
            {14317, 42000, req=14316}, -- Explosive Trap Rank 3
        },
        [56] = {
            {14266, 46000, req=14265}, -- Raptor Strike Rank 8
            {14305, 46000, req=14304}, -- Immolation Trap Rank 5
            {20190, 46000, req=20043}, -- Aspect of the Wild Rank 2
        },
        [57] = {
            {63668, 1800, req=3674}, -- Black Arrow Rank 2
        },
        [58] = {
            {13555, 48000, req=13554}, -- Serpent Sting Rank 8
            {14271, 48000, req=14270}, -- Mongoose Bite Rank 4
            {14295, 48000, req=14294}, -- Volley Rank 3
            {14322, 48000, req=14321}, -- Aspect of the Hawk Rank 6
            {14325, 48000, req=14324}, -- Hunter's Mark Rank 4
        },
        [60] = {
            {19263, 2200, }, -- Deterrence 
            {20904, 2500, req=20903}, -- Aimed Shot Rank 6
            {24133, 2500, req=24132}, -- Wyvern Sting Rank 3
            {13544, 50000, req=13543}, -- Mend Pet Rank 7
            {14287, 50000, req=14286}, -- Arcane Shot Rank 8
            {14311, 50000, req=14310}, -- Freezing Trap Rank 3
            {19801, 50000, }, -- Tranquilizing Shot 
            {25294, 50000, req=14290}, -- Multi-Shot Rank 5
            {25295, 50000, req=13555}, -- Serpent Sting Rank 9
            {25296, 50000, req=14322}, -- Aspect of the Hawk Rank 7
        },
        [61] = {
            {27025, 68000, req=14317}, -- Explosive Trap Rank 4
        },
        [62] = {
            {34120, 77000, req=56641}, -- Steady Shot Rank 2
        },
        [63] = {
            {63669, 7000, req=63668}, -- Black Arrow Rank 3
            {27014, 87000, req=14266}, -- Raptor Strike Rank 9
        },
        [65] = {
            {27023, 110000, req=14305}, -- Immolation Trap Rank 6
        },
        [66] = {
            {27067, 2500, req=20910}, -- Counterattack Rank 4
            {34026, 120000, }, -- Kill Command 
        },
        [67] = {
            {27016, 140000, req=25295}, -- Serpent Sting Rank 10
            {27021, 140000, req=25294}, -- Multi-Shot Rank 6
            {27022, 140000, req=14295}, -- Volley Rank 4
        },
        [68] = {
            {27044, 150000, req=25296}, -- Aspect of the Hawk Rank 8
            {27045, 150000, req=20190}, -- Aspect of the Wild Rank 3
            {27046, 150000, req=13544}, -- Mend Pet Rank 8
            {34600, 150000, }, -- Snake Trap 
        },
        [69] = {
            {63670, 10000, req=63669}, -- Black Arrow Rank 4
            {27019, 170000, req=14287}, -- Arcane Shot Rank 9
        },
        [70] = {
            {60051, 400, req=53301}, -- Explosive Shot Rank 2
            {27065, 2700, req=20904}, -- Aimed Shot Rank 7
            {27068, 2700, req=24133}, -- Wyvern Sting Rank 4
            {34477, 190000, }, -- Misdirection 
            {36916, 190000, req=14271}, -- Mongoose Bite Rank 5
        },
        [71] = {
            {48995, 300000, req=27014}, -- Raptor Strike Rank 10
            {49051, 300000, req=34120}, -- Steady Shot Rank 3
            {49066, 300000, req=27025}, -- Explosive Trap Rank 5
            {53351, 300000, }, -- Kill Shot Rank 1
        },
        [72] = {
            {48998, 10000, req=27067}, -- Counterattack Rank 5
            {49055, 300000, req=27023}, -- Immolation Trap Rank 7
        },
        [73] = {
            {49000, 300000, req=27016}, -- Serpent Sting Rank 11
            {49044, 300000, req=27019}, -- Arcane Shot Rank 10
        },
        [74] = {
            {48989, 300000, req=27046}, -- Mend Pet Rank 9
            {49047, 300000, req=27021}, -- Multi-Shot Rank 7
            {58431, 300000, req=27022}, -- Volley Rank 5
            {61846, 300000, }, -- Aspect of the Dragonhawk Rank 1
        },
        [75] = {
            {60052, 400, req=60051}, -- Explosive Shot Rank 3
            {49049, 10000, req=27065}, -- Aimed Shot Rank 8
            {53271, 10000, }, -- Master's Call 
            {63671, 10000, req=63670}, -- Black Arrow Rank 5
            {49011, 100000, req=27068}, -- Wyvern Sting Rank 5
            {61005, 300000, req=53351}, -- Kill Shot Rank 2
        },
        [76] = {
            {53338, 10000, req=14325}, -- Hunter's Mark Rank 5
            {49071, 300000, req=27045}, -- Aspect of the Wild Rank 4
        },
        [77] = {
            {48996, 300000, req=48995}, -- Raptor Strike Rank 11
            {49052, 300000, req=49051}, -- Steady Shot Rank 4
            {49067, 300000, req=49066}, -- Explosive Trap Rank 6
        },
        [78] = {
            {48999, 15000, req=48998}, -- Counterattack Rank 6
            {49056, 300000, req=49055}, -- Immolation Trap Rank 8
        },
        [79] = {
            {49001, 300000, req=49000}, -- Serpent Sting Rank 12
            {49045, 300000, req=49044}, -- Arcane Shot Rank 11
        },
        [80] = {
            {49050, 10000, req=49049}, -- Aimed Shot Rank 9
            {63672, 10000, req=63671}, -- Black Arrow Rank 6
            {49012, 100000, req=49011}, -- Wyvern Sting Rank 6
            {60053, 100000, req=60052}, -- Explosive Shot Rank 4
            {60192, 100000, }, -- Freezing Arrow Rank 1
            {48990, 300000, req=48989}, -- Mend Pet Rank 10
            {49048, 300000, req=49047}, -- Multi-Shot Rank 8
            {53339, 300000, req=36916}, -- Mongoose Bite Rank 6
            {58434, 300000, req=58431}, -- Volley Rank 6
            {61006, 300000, req=61005}, -- Kill Shot Rank 3
            {61847, 300000, req=61846}, -- Aspect of the Dragonhawk Rank 2
            {62757, 300000, }, -- Call Stabled Pet 
        },
    },
    WARRIOR = {
        [0] = {
            {196, 1000, }, -- One-Handed Axes 
            {197, 1000, }, -- Two-Handed Axes 
            {198, 1000, }, -- One-Handed Maces 
            {199, 1000, }, -- Two-Handed Maces 
            {201, 1000, }, -- One-Handed Swords 
            {202, 1000, }, -- Two-Handed Swords 
            {227, 1000, }, -- Staves 
            {264, 1000, }, -- Bows 
            {266, 1000, }, -- Guns 
            {1180, 1000, }, -- Daggers 
            {5011, 1000, }, -- Crossbows 
            {15590, 1000, }, -- Fist Weapons 
        },
        [1] = {
            {6673, 10, }, -- Battle Shout Rank 1
        },
        [4] = {
            {100, 100, }, -- Charge Rank 1
            {772, 100, }, -- Rend Rank 1
        },
        [6] = {
            {6343, 100, }, -- Thunder Clap Rank 1
            {34428, 58000, }, -- Victory Rush 
        },
        [8] = {
            {284, 200, req=78}, -- Heroic Strike Rank 2
            {1715, 200, }, -- Hamstring 
        },
        [10] = {
            {674, 300, }, -- Dual Wield Passive
            {2687, 600, }, -- Bloodrage 
            {6546, 600, req=772}, -- Rend Rank 2
        },
        [12] = {
            {3127, 800, }, -- Parry Passive
            {72, 1000, }, -- Shield Bash 
            {5242, 1000, req=6673}, -- Battle Shout Rank 2
            {7384, 1000, }, -- Overpower 
        },
        [14] = {
            {1160, 1500, }, -- Demoralizing Shout Rank 1
            {6572, 1500, }, -- Revenge Rank 1
        },
        [16] = {
            {285, 2000, req=284}, -- Heroic Strike Rank 3
            {694, 2000, }, -- Mocking Blow 
            {2565, 2000, }, -- Shield Block 
        },
        [18] = {
            {676, 3000, }, -- Disarm 
            {8198, 3000, req=6343}, -- Thunder Clap Rank 2
        },
        [20] = {
            {845, 4000, }, -- Cleave Rank 1
            {6547, 4000, req=6546}, -- Rend Rank 3
            {12678, 4000, }, -- Stance Mastery Passive
            {20230, 4000, }, -- Retaliation 
            {200, 10000, }, -- Polearms 
        },
        [22] = {
            {5246, 6000, }, -- Intimidating Shout 
            {6192, 6000, req=5242}, -- Battle Shout Rank 3
        },
        [24] = {
            {1608, 8000, req=285}, -- Heroic Strike Rank 4
            {5308, 8000, }, -- Execute Rank 1
            {6190, 8000, req=1160}, -- Demoralizing Shout Rank 2
            {6574, 8000, req=6572}, -- Revenge Rank 2
        },
        [26] = {
            {1161, 10000, }, -- Challenging Shout 
            {6178, 10000, req=100}, -- Charge Rank 2
        },
        [28] = {
            {871, 11000, }, -- Shield Wall 
            {8204, 11000, req=8198}, -- Thunder Clap Rank 3
        },
        [30] = {
            {1464, 12000, }, -- Slam Rank 1
            {6548, 12000, req=6547}, -- Rend Rank 4
            {7369, 12000, req=845}, -- Cleave Rank 2
            {20252, 12000, }, -- Intercept 
        },
        [32] = {
            {11549, 14000, req=6192}, -- Battle Shout Rank 4
            {11564, 14000, req=1608}, -- Heroic Strike Rank 5
            {18499, 14000, }, -- Berserker Rage 
            {20658, 14000, req=5308}, -- Execute Rank 2
        },
        [34] = {
            {7379, 16000, req=6574}, -- Revenge Rank 3
            {11554, 16000, req=6190}, -- Demoralizing Shout Rank 3
        },
        [36] = {
            {1680, 18000, }, -- Whirlwind 
        },
        [38] = {
            {6552, 20000, }, -- Pummel 
            {8205, 20000, req=8204}, -- Thunder Clap Rank 4
            {8820, 20000, req=1464}, -- Slam Rank 2
        },
        [40] = {
            {8737, 12000, }, -- Mail 
            {750, 20000, }, -- Plate Mail 
            {11565, 22000, req=11564}, -- Heroic Strike Rank 6
            {11572, 22000, req=6548}, -- Rend Rank 5
            {11608, 22000, req=7369}, -- Cleave Rank 3
            {20660, 22000, req=20658}, -- Execute Rank 3
            {23922, 22000, }, -- Shield Slam Rank 1
        },
        [42] = {
            {11550, 32000, req=11549}, -- Battle Shout Rank 5
        },
        [44] = {
            {11555, 34000, req=11554}, -- Demoralizing Shout Rank 4
            {11600, 34000, req=7379}, -- Revenge Rank 4
        },
        [46] = {
            {11578, 36000, req=6178}, -- Charge Rank 3
            {11604, 36000, req=8820}, -- Slam Rank 3
        },
        [48] = {
            {21551, 2000, req=12294}, -- Mortal Strike Rank 2
            {23923, 2000, req=23922}, -- Shield Slam Rank 2
            {11566, 40000, req=11565}, -- Heroic Strike Rank 7
            {11580, 40000, req=8205}, -- Thunder Clap Rank 5
            {20661, 40000, req=20660}, -- Execute Rank 4
        },
        [50] = {
            {1719, 42000, }, -- Recklessness 
            {11573, 42000, req=11572}, -- Rend Rank 6
            {11609, 42000, req=11608}, -- Cleave Rank 4
        },
        [52] = {
            {11551, 54000, req=11550}, -- Battle Shout Rank 6
        },
        [54] = {
            {21552, 2800, req=21551}, -- Mortal Strike Rank 3
            {23924, 2800, req=23923}, -- Shield Slam Rank 3
            {11556, 56000, req=11555}, -- Demoralizing Shout Rank 5
            {11601, 56000, req=11600}, -- Revenge Rank 5
            {11605, 56000, req=11604}, -- Slam Rank 4
        },
        [56] = {
            {11567, 58000, req=11566}, -- Heroic Strike Rank 8
            {20662, 58000, req=20661}, -- Execute Rank 5
        },
        [58] = {
            {11581, 60000, req=11580}, -- Thunder Clap Rank 6
        },
        [60] = {
            {21553, 3100, req=21552}, -- Mortal Strike Rank 4
            {23925, 3100, req=23924}, -- Shield Slam Rank 4
            {30016, 3100, req=20243}, -- Devastate Rank 2
            {25288, 56000, req=11601}, -- Revenge Rank 6
            {25286, 60000, req=11567}, -- Heroic Strike Rank 9
            {11574, 62000, req=11573}, -- Rend Rank 7
            {20569, 62000, req=11609}, -- Cleave Rank 5
            {25289, 65000, req=11551}, -- Battle Shout Rank 7
        },
        [61] = {
            {25241, 65000, req=11605}, -- Slam Rank 5
        },
        [62] = {
            {25202, 65000, req=11556}, -- Demoralizing Shout Rank 6
        },
        [63] = {
            {25269, 65000, req=25288}, -- Revenge Rank 7
        },
        [64] = {
            {23920, 65000, }, -- Spell Reflection 
        },
        [65] = {
            {25234, 65000, req=20662}, -- Execute Rank 6
        },
        [66] = {
            {25248, 3250, req=21553}, -- Mortal Strike Rank 5
            {25258, 3250, req=23925}, -- Shield Slam Rank 5
            {29707, 65000, req=25286}, -- Heroic Strike Rank 10
        },
        [67] = {
            {25264, 65000, req=11581}, -- Thunder Clap Rank 7
        },
        [68] = {
            {469, 65000, }, -- Commanding Shout Rank 1
            {25208, 65000, req=11574}, -- Rend Rank 8
            {25231, 65000, req=20569}, -- Cleave Rank 6
        },
        [69] = {
            {2048, 65000, req=25289}, -- Battle Shout Rank 8
            {25242, 65000, req=25241}, -- Slam Rank 6
        },
        [70] = {
            {30022, 3250, req=30016}, -- Devastate Rank 3
            {30330, 3250, req=25248}, -- Mortal Strike Rank 6
            {30356, 3250, req=25258}, -- Shield Slam Rank 6
            {3411, 65000, }, -- Intervene 
            {25203, 65000, req=25202}, -- Demoralizing Shout Rank 7
            {25236, 65000, req=25234}, -- Execute Rank 7
            {30357, 65000, req=25269}, -- Revenge Rank 8
            {30324, 100000, req=29707}, -- Heroic Strike Rank 11
        },
        [71] = {
            {46845, 260000, req=25208}, -- Rend Rank 9
            {64382, 260000, }, -- Shattering Throw 
        },
        [72] = {
            {47449, 260000, req=30324}, -- Heroic Strike Rank 12
            {47519, 260000, req=25231}, -- Cleave Rank 7
        },
        [73] = {
            {47470, 260000, req=25236}, -- Execute Rank 8
            {47501, 260000, req=25264}, -- Thunder Clap Rank 8
        },
        [74] = {
            {47439, 100000, req=469}, -- Commanding Shout Rank 2
            {47474, 260000, req=25242}, -- Slam Rank 7
        },
        [75] = {
            {47497, 5000, req=30022}, -- Devastate Rank 4
            {47485, 13000, req=30330}, -- Mortal Strike Rank 7
            {55694, 100000, }, -- Enraged Regeneration 
            {47487, 260000, req=30356}, -- Shield Slam Rank 7
        },
        [76] = {
            {47450, 260000, req=47449}, -- Heroic Strike Rank 13
            {47465, 260000, req=46845}, -- Rend Rank 10
        },
        [77] = {
            {47520, 260000, req=47519}, -- Cleave Rank 8
        },
        [78] = {
            {47436, 260000, req=2048}, -- Battle Shout Rank 9
            {47502, 260000, req=47501}, -- Thunder Clap Rank 9
        },
        [79] = {
            {47437, 260000, req=25203}, -- Demoralizing Shout Rank 8
            {47475, 260000, req=47474}, -- Slam Rank 8
        },
        [80] = {
            {47498, 5000, req=47497}, -- Devastate Rank 5
            {47486, 13000, req=47485}, -- Mortal Strike Rank 8
            {57755, 100000, }, -- Heroic Throw 
            {47440, 260000, req=47439}, -- Commanding Shout Rank 3
            {47471, 260000, req=47470}, -- Execute Rank 9
            {47488, 260000, req=47487}, -- Shield Slam Rank 8
            {57823, 260000, req=30357}, -- Revenge Rank 9
        },
    },
    PALADIN = {
        [0] = {
            {196, 1000, }, -- One-Handed Axes 
            {197, 1000, }, -- Two-Handed Axes 
            {198, 1000, }, -- One-Handed Maces 
            {199, 1000, }, -- Two-Handed Maces 
            {201, 1000, }, -- One-Handed Swords 
            {202, 1000, }, -- Two-Handed Swords 
        },
        [1] = {
            {465, 10, }, -- Devotion Aura Rank 1
        },
        [4] = {
            {19740, 100, }, -- Blessing of Might Rank 1
            {20271, 100, }, -- Judgement of Light 
        },
        [6] = {
            {498, 100, }, -- Divine Protection 
            {639, 100, req=635}, -- Holy Light Rank 2
        },
        [8] = {
            {853, 100, }, -- Hammer of Justice Rank 1
            {1152, 100, }, -- Purify 
        },
        [10] = {
            {633, 300, }, -- Lay on Hands Rank 1
            {1022, 300, }, -- Hand of Protection Rank 1
            {10290, 300, req=465}, -- Devotion Aura Rank 2
        },
        [12] = {
            {3127, 800, }, -- Parry Passive
            {19834, 1000, req=19740}, -- Blessing of Might Rank 2
            {53408, 1000, }, -- Judgement of Wisdom 
        },
        [14] = {
            {647, 2000, req=639}, -- Holy Light Rank 3
            {19742, 2000, }, -- Blessing of Wisdom Rank 1
            {31789, 4000, }, -- Righteous Defense 
        },
        [16] = {
            {7294, 3000, }, -- Retribution Aura Rank 1
            {25780, 3000, }, -- Righteous Fury 
            {62124, 3000, }, -- Hand of Reckoning 
        },
        [18] = {
            {1044, 3500, }, -- Hand of Freedom 
        },
        [20] = {
            {643, 4000, req=10290}, -- Devotion Aura Rank 3
            {879, 4000, }, -- Exorcism Rank 1
            {5502, 4000, }, -- Sense Undead 
            {19750, 4000, }, -- Flash of Light Rank 1
            {20217, 4000, }, -- Blessing of Kings 
            {26573, 4000, }, -- Consecration Rank 1
            {200, 10000, }, -- Polearms 
            {13819, 3500, faction="Alliance"}, -- Summon Warhorse
            {34769, 3500, faction="Horde"}, -- Summon Warhorse
        },
        [22] = {
            {1026, 4000, req=647}, -- Holy Light Rank 4
            {19746, 4000, }, -- Concentration Aura 
            {19835, 4000, req=19834}, -- Blessing of Might Rank 3
            {20164, 4000, }, -- Seal of Justice 
        },
        [24] = {
            {5588, 5000, req=853}, -- Hammer of Justice Rank 2
            {5599, 5000, req=1022}, -- Hand of Protection Rank 2
            {10322, 5000, req=7328}, -- Redemption Rank 2
            {19850, 5000, req=19742}, -- Blessing of Wisdom Rank 2
            {10326, 34000, }, -- Turn Evil 
        },
        [26] = {
            {1038, 6000, }, -- Hand of Salvation 
            {10298, 6000, req=7294}, -- Retribution Aura Rank 2
            {19939, 6000, req=19750}, -- Flash of Light Rank 2
        },
        [28] = {
            {5614, 9000, req=879}, -- Exorcism Rank 2
            {19876, 9000, }, -- Shadow Resistance Aura Rank 1
            {53407, 9000, }, -- Judgement of Justice 
        },
        [30] = {
            {20116, 200, req=26573}, -- Consecration Rank 2
            {1042, 11000, req=1026}, -- Holy Light Rank 5
            {2800, 11000, req=633}, -- Lay on Hands Rank 2
            {10291, 11000, req=643}, -- Devotion Aura Rank 4
            {19752, 11000, }, -- Divine Intervention 
            {20165, 11000, }, -- Seal of Light 
        },
        [32] = {
            {19836, 12000, req=19835}, -- Blessing of Might Rank 4
            {19888, 12000, }, -- Frost Resistance Aura Rank 1
        },
        [34] = {
            {642, 13000, }, -- Divine Shield 
            {19852, 13000, req=19850}, -- Blessing of Wisdom Rank 3
            {19940, 13000, req=19939}, -- Flash of Light Rank 3
        },
        [36] = {
            {5615, 14000, req=5614}, -- Exorcism Rank 3
            {10299, 14000, req=10298}, -- Retribution Aura Rank 3
            {10324, 14000, req=10322}, -- Redemption Rank 3
            {19891, 14000, }, -- Fire Resistance Aura Rank 1
        },
        [38] = {
            {3472, 16000, req=1042}, -- Holy Light Rank 6
            {10278, 16000, req=5599}, -- Hand of Protection Rank 3
            {20166, 16000, }, -- Seal of Wisdom 
        },
        [40] = {
            {20922, 1000, req=20116}, -- Consecration Rank 3
            {8737, 12000, }, -- Mail 
            {750, 20000, }, -- Plate Mail 
            {1032, 20000, req=10291}, -- Devotion Aura Rank 5
            {5589, 20000, req=5588}, -- Hammer of Justice Rank 3
            {19895, 20000, req=19876}, -- Shadow Resistance Aura Rank 2
            {23214, 20000, req=13819, faction="Alliance"}, -- Charger
            {34767, 20000, req=34769, faction="Horde"}, -- Summon Charger Summon
        },
        [42] = {
            {4987, 21000, }, -- Cleanse 
            {19837, 21000, req=19836}, -- Blessing of Might Rank 5
            {19941, 21000, req=19940}, -- Flash of Light Rank 4
        },
        [44] = {
            {10312, 22000, req=5615}, -- Exorcism Rank 4
            {19853, 22000, req=19852}, -- Blessing of Wisdom Rank 4
            {19897, 22000, req=19888}, -- Frost Resistance Aura Rank 2
            {24275, 22000, }, -- Hammer of Wrath Rank 1
        },
        [46] = {
            {6940, 24000, }, -- Hand of Sacrifice 
            {10300, 24000, req=10299}, -- Retribution Aura Rank 4
            {10328, 24000, req=3472}, -- Holy Light Rank 7
        },
        [48] = {
            {20929, 1300, req=20473}, -- Holy Shock Rank 2
            {19899, 26000, req=19891}, -- Fire Resistance Aura Rank 2
            {20772, 26000, req=10324}, -- Redemption Rank 4
        },
        [50] = {
            {20923, 1400, req=20922}, -- Consecration Rank 4
            {20927, 1400, req=20925}, -- Holy Shield Rank 2
            {2812, 28000, }, -- Holy Wrath Rank 1
            {10292, 28000, req=1032}, -- Devotion Aura Rank 6
            {10310, 28000, req=2800}, -- Lay on Hands Rank 3
            {19942, 28000, req=19941}, -- Flash of Light Rank 5
        },
        [52] = {
            {10313, 34000, req=10312}, -- Exorcism Rank 5
            {19838, 34000, req=19837}, -- Blessing of Might Rank 6
            {19896, 34000, req=19895}, -- Shadow Resistance Aura Rank 3
            {24274, 34000, req=24275}, -- Hammer of Wrath Rank 2
            {25782, 46000, req=19838}, -- Greater Blessing of Might Rank 1
        },
        [54] = {
            {10308, 40000, req=5589}, -- Hammer of Justice Rank 4
            {10329, 40000, req=10328}, -- Holy Light Rank 8
            {19854, 40000, req=19853}, -- Blessing of Wisdom Rank 5
            {25894, 46000, req=19854}, -- Greater Blessing of Wisdom Rank 1
        },
        [56] = {
            {20930, 2100, req=20929}, -- Holy Shock Rank 3
            {10301, 42000, req=10300}, -- Retribution Aura Rank 5
            {19898, 42000, req=19897}, -- Frost Resistance Aura Rank 3
        },
        [58] = {
            {19943, 44000, req=19942}, -- Flash of Light Rank 6
        },
        [60] = {
            {20924, 2300, req=20923}, -- Consecration Rank 5
            {20928, 2300, req=20927}, -- Holy Shield Rank 3
            {25898, 2300, }, -- Greater Blessing of Kings 
            {25899, 2300, req=20911}, -- Greater Blessing of Sanctuary 
            {32699, 2300, req=31935}, -- Avenger's Shield Rank 2
            {10293, 46000, req=10292}, -- Devotion Aura Rank 7
            {10314, 46000, req=10313}, -- Exorcism Rank 6
            {10318, 46000, req=2812}, -- Holy Wrath Rank 2
            {19900, 46000, req=19899}, -- Fire Resistance Aura Rank 3
            {20773, 46000, req=20772}, -- Redemption Rank 5
            {24239, 46000, req=24274}, -- Hammer of Wrath Rank 3
            {25292, 46000, req=10329}, -- Holy Light Rank 9
            {25916, 46000, req=25782}, -- Greater Blessing of Might Rank 2
            {25918, 46000, req=25894}, -- Greater Blessing of Wisdom Rank 2
            {25290, 50000, req=19854}, -- Blessing of Wisdom Rank 6
            {25291, 50000, req=19838}, -- Blessing of Might Rank 7
        },
        [62] = {
            {27135, 55000, req=25292}, -- Holy Light Rank 10
            {32223, 55000, }, -- Crusader Aura 
        },
        [63] = {
            {27151, 61000, req=19896}, -- Shadow Resistance Aura Rank 4
        },
        [64] = {
            {27174, 3350, req=20930}, -- Holy Shock Rank 4
            {31801, 67000, faction="Alliance"}, -- Seal of Vengeance 
        },
        [65] = {
            {27142, 75000, req=25290}, -- Blessing of Wisdom Rank 7
            {27143, 75000, req=25918}, -- Greater Blessing of Wisdom Rank 3
        },
        [66] = {
            {27137, 83000, req=19943}, -- Flash of Light Rank 7
            {27150, 83000, req=10301}, -- Retribution Aura Rank 6
            {53736, 100000, faction="Horde"}, -- Seal of Corruption 
        },
        [68] = {
            {27138, 100000, req=10314}, -- Exorcism Rank 7
            {27152, 100000, req=19898}, -- Frost Resistance Aura Rank 4
            {27180, 100000, req=24239}, -- Hammer of Wrath Rank 4
        },
        [69] = {
            {27139, 110000, req=10318}, -- Holy Wrath Rank 3
            {27154, 110000, req=10310}, -- Lay on Hands Rank 4
        },
        [70] = {
            {27179, 2300, req=20928}, -- Holy Shield Rank 4
            {32700, 2300, req=32699}, -- Avenger's Shield Rank 3
            {33072, 6500, req=27174}, -- Holy Shock Rank 5
            {27141, 46000, req=25916}, -- Greater Blessing of Might Rank 3
            {27140, 50000, req=25291}, -- Blessing of Might Rank 8
            {27136, 130000, req=27135}, -- Holy Light Rank 11
            {27149, 130000, req=10293}, -- Devotion Aura Rank 8
            {27153, 130000, req=19900}, -- Fire Resistance Aura Rank 4
            {27173, 130000, req=20924}, -- Consecration Rank 6
            {31884, 130000, }, -- Avenging Wrath 
        },
        [71] = {
            {54428, 100000, }, -- Divine Plea 
            {48935, 200000, req=27142}, -- Blessing of Wisdom Rank 8
            {48937, 200000, req=27143}, -- Greater Blessing of Wisdom Rank 4
        },
        [72] = {
            {48816, 200000, req=27139}, -- Holy Wrath Rank 4
            {48949, 200000, req=20773}, -- Redemption Rank 6
        },
        [73] = {
            {48800, 200000, req=27138}, -- Exorcism Rank 8
            {48931, 200000, req=27140}, -- Blessing of Might Rank 9
            {48933, 200000, req=27141}, -- Greater Blessing of Might Rank 4
        },
        [74] = {
            {48784, 200000, req=27137}, -- Flash of Light Rank 8
            {48805, 200000, req=27180}, -- Hammer of Wrath Rank 5
            {48941, 200000, req=27149}, -- Devotion Aura Rank 9
        },
        [75] = {
            {48824, 10000, req=33072}, -- Holy Shock Rank 6
            {48826, 10000, req=32700}, -- Avenger's Shield Rank 4
            {48951, 10000, req=27179}, -- Holy Shield Rank 5
            {48781, 200000, req=27136}, -- Holy Light Rank 12
            {48818, 200000, req=27173}, -- Consecration Rank 7
            {53600, 200000, }, -- Shield of Righteousness Rank 1
        },
        [76] = {
            {48943, 200000, req=27151}, -- Shadow Resistance Aura Rank 5
            {54043, 200000, req=27150}, -- Retribution Aura Rank 7
        },
        [77] = {
            {48936, 200000, req=48935}, -- Blessing of Wisdom Rank 9
            {48938, 200000, req=48937}, -- Greater Blessing of Wisdom Rank 5
            {48945, 200000, req=27152}, -- Frost Resistance Aura Rank 5
        },
        [78] = {
            {48788, 200000, req=27154}, -- Lay on Hands Rank 5
            {48817, 200000, req=48816}, -- Holy Wrath Rank 5
            {48947, 200000, req=27153}, -- Fire Resistance Aura Rank 5
        },
        [79] = {
            {48785, 200000, req=48784}, -- Flash of Light Rank 9
            {48801, 200000, req=48800}, -- Exorcism Rank 9
            {48932, 200000, req=48931}, -- Blessing of Might Rank 10
            {48934, 200000, req=48933}, -- Greater Blessing of Might Rank 5
            {48942, 200000, req=48941}, -- Devotion Aura Rank 10
            {48950, 200000, req=48949}, -- Redemption Rank 7
        },
        [80] = {
            {48825, 10000, req=48824}, -- Holy Shock Rank 7
            {48827, 10000, req=48826}, -- Avenger's Shield Rank 5
            {48952, 10000, req=48951}, -- Holy Shield Rank 6
            {53601, 100000, }, -- Sacred Shield Rank 1
            {48782, 200000, req=48781}, -- Holy Light Rank 13
            {48806, 200000, req=48805}, -- Hammer of Wrath Rank 6
            {48819, 200000, req=48818}, -- Consecration Rank 8
            {61411, 200000, req=53600}, -- Shield of Righteousness Rank 2
        },
    },
    MAGE = {
        [0] = {
            {201, 1000, }, -- One-Handed Swords 
            {227, 1000, }, -- Staves 
            {1180, 1000, }, -- Daggers 
        },
        [1] = {
            {1459, 10, }, -- Arcane Intellect Rank 1
        },
        [4] = {
            {116, 100, }, -- Frostbolt Rank 1
            {5504, 100, }, -- Conjure Water Rank 1
        },
        [6] = {
            {143, 100, req=133}, -- Fireball Rank 2
            {587, 100, }, -- Conjure Food Rank 1
            {2136, 100, }, -- Fire Blast Rank 1
        },
        [8] = {
            {118, 200, }, -- Polymorph Rank 1
            {205, 200, req=116}, -- Frostbolt Rank 2
            {5143, 200, }, -- Arcane Missiles Rank 1
        },
        [10] = {
            {122, 400, }, -- Frost Nova Rank 1
            {5505, 400, req=5504}, -- Conjure Water Rank 2
            {7300, 400, req=168}, -- Frost Armor Rank 2
        },
        [12] = {
            {130, 600, }, -- Slow Fall 
            {145, 600, req=143}, -- Fireball Rank 3
            {597, 600, req=587}, -- Conjure Food Rank 2
            {604, 600, }, -- Dampen Magic Rank 1
        },
        [14] = {
            {837, 900, req=205}, -- Frostbolt Rank 3
            {1449, 900, }, -- Arcane Explosion Rank 1
            {1460, 900, req=1459}, -- Arcane Intellect Rank 2
            {2137, 900, req=2136}, -- Fire Blast Rank 2
        },
        [16] = {
            {2120, 1500, }, -- Flamestrike Rank 1
            {5144, 1500, req=5143}, -- Arcane Missiles Rank 2
        },
        [18] = {
            {475, 1800, }, -- Remove Curse 
            {1008, 1800, }, -- Amplify Magic Rank 1
            {3140, 1800, req=145}, -- Fireball Rank 4
        },
        [20] = {
            {10, 2000, }, -- Blizzard Rank 1
            {543, 2000, }, -- Fire Ward Rank 1
            {1463, 2000, }, -- Mana Shield Rank 1
            {1953, 2000, }, -- Blink 
            {5506, 2000, req=5505}, -- Conjure Water Rank 3
            {7301, 2000, req=7300}, -- Frost Armor Rank 3
            {7322, 2000, req=837}, -- Frostbolt Rank 4
            {12051, 2000, }, -- Evocation 
            {12824, 2000, req=118}, -- Polymorph Rank 2
            {32271, 1900, faction="Alliance"}, -- Teleport: Exodar 
            {3561, 2000, faction="Alliance"}, -- Teleport: Stormwind 
            {3562, 2000, faction="Alliance"}, -- Teleport: Ironforge 
            {49359, 2000, faction="Alliance"}, -- Teleport: Theramore 
            {3565, 8000, faction="Alliance"}, -- Teleport: Darnassus 
            {3563, 2000, faction="Horde"}, -- Teleport: Undercity 
            {3567, 2000, faction="Horde"}, -- Teleport: Orgrimmar 
            {32272, 2000, faction="Horde"}, -- Teleport: Silvermoon 
            {49358, 2000, faction="Horde"}, -- Teleport: Stonard 
            {3566, 8000, faction="Horde"}, -- Teleport: Thunder Bluff 
        },
        [22] = {
            {990, 3000, req=597}, -- Conjure Food Rank 3
            {2138, 3000, req=2137}, -- Fire Blast Rank 3
            {2948, 3000, }, -- Scorch Rank 1
            {6143, 3000, }, -- Frost Ward Rank 1
            {8437, 3000, req=1449}, -- Arcane Explosion Rank 2
        },
        [24] = {
            {12505, 200, req=11366}, -- Pyroblast Rank 2
            {2121, 4000, req=2120}, -- Flamestrike Rank 2
            {2139, 4000, }, -- Counterspell 
            {5145, 4000, req=5144}, -- Arcane Missiles Rank 3
            {8400, 4000, req=3140}, -- Fireball Rank 5
            {8450, 4000, req=604}, -- Dampen Magic Rank 2
        },
        [26] = {
            {120, 5000, }, -- Cone of Cold Rank 1
            {865, 5000, req=122}, -- Frost Nova Rank 2
            {8406, 5000, req=7322}, -- Frostbolt Rank 5
        },
        [28] = {
            {759, 7000, }, -- Conjure Mana Gem Rank 1
            {1461, 7000, req=1460}, -- Arcane Intellect Rank 3
            {6141, 7000, req=10}, -- Blizzard Rank 2
            {8444, 7000, req=2948}, -- Scorch Rank 2
            {8494, 7000, req=1463}, -- Mana Shield Rank 2
        },
        [30] = {
            {12522, 400, req=12505}, -- Pyroblast Rank 3
            {6127, 8000, req=5506}, -- Conjure Water Rank 4
            {7302, 8000, }, -- Ice Armor Rank 1
            {8401, 8000, req=8400}, -- Fireball Rank 6
            {8412, 8000, req=2138}, -- Fire Blast Rank 4
            {8438, 8000, req=8437}, -- Arcane Explosion Rank 3
            {8455, 8000, req=1008}, -- Amplify Magic Rank 2
            {8457, 8000, req=543}, -- Fire Ward Rank 2
            {45438, 8000, }, -- Ice Block 
        },
        [32] = {
            {6129, 10000, req=990}, -- Conjure Food Rank 4
            {8407, 10000, req=8406}, -- Frostbolt Rank 6
            {8416, 10000, req=5145}, -- Arcane Missiles Rank 4
            {8422, 10000, req=2121}, -- Flamestrike Rank 3
            {8461, 10000, req=6143}, -- Frost Ward Rank 2
        },
        [34] = {
            {8445, 12000, req=8444}, -- Scorch Rank 3
            {8492, 12000, req=120}, -- Cone of Cold Rank 2
            {6117, 13000, }, -- Mage Armor Rank 1
        },
        [36] = {
            {12523, 650, req=12522}, -- Pyroblast Rank 4
            {13018, 650, req=11113}, -- Blast Wave Rank 2
            {8402, 13000, req=8401}, -- Fireball Rank 7
            {8427, 13000, req=6141}, -- Blizzard Rank 3
            {8451, 13000, req=8450}, -- Dampen Magic Rank 3
            {8495, 13000, req=8494}, -- Mana Shield Rank 3
        },
        [38] = {
            {3552, 14000, req=759}, -- Conjure Mana Gem Rank 2
            {8408, 14000, req=8407}, -- Frostbolt Rank 7
            {8413, 14000, req=8412}, -- Fire Blast Rank 5
            {8439, 14000, req=8438}, -- Arcane Explosion Rank 4
        },
        [40] = {
            {6131, 15000, req=865}, -- Frost Nova Rank 3
            {7320, 15000, req=7302}, -- Ice Armor Rank 2
            {8417, 15000, req=8416}, -- Arcane Missiles Rank 5
            {8423, 15000, req=8422}, -- Flamestrike Rank 4
            {8446, 15000, req=8445}, -- Scorch Rank 4
            {8458, 15000, req=8457}, -- Fire Ward Rank 3
            {10138, 15000, req=6127}, -- Conjure Water Rank 5
            {12825, 15000, req=12824}, -- Polymorph Rank 3
            {32266, 14250, faction="Alliance"}, -- Portal: Exodar 
            {10059, 15000, faction="Alliance"}, -- Portal: Stormwind 
            {11416, 15000, faction="Alliance"}, -- Portal: Ironforge 
            {49360, 15000, faction="Alliance"}, -- Portal: Theramore 
            {11419, 32000, faction="Alliance"}, -- Portal: Darnassus 
            {11417, 15000, faction="Horde"}, -- Portal: Orgrimmar 
            {11418, 15000, faction="Horde"}, -- Portal: Undercity 
            {32267, 15000, faction="Horde"}, -- Portal: Silvermoon 
            {49361, 15000, faction="Horde"}, -- Portal: Stonard 
            {11420, 32000, faction="Horde"}, -- Portal: Thunder Bluff 
        },
        [42] = {
            {12524, 900, req=12523}, -- Pyroblast Rank 5
            {8462, 18000, req=8461}, -- Frost Ward Rank 3
            {10144, 18000, req=6129}, -- Conjure Food Rank 5
            {10148, 18000, req=8402}, -- Fireball Rank 8
            {10156, 18000, req=1461}, -- Arcane Intellect Rank 4
            {10159, 18000, req=8492}, -- Cone of Cold Rank 3
            {10169, 18000, req=8455}, -- Amplify Magic Rank 3
        },
        [44] = {
            {13019, 1150, req=13018}, -- Blast Wave Rank 3
            {10179, 23000, req=8408}, -- Frostbolt Rank 8
            {10185, 23000, req=8427}, -- Blizzard Rank 4
            {10191, 23000, req=8495}, -- Mana Shield Rank 4
        },
        [46] = {
            {13031, 1300, req=11426}, -- Ice Barrier Rank 2
            {10197, 26000, req=8413}, -- Fire Blast Rank 6
            {10201, 26000, req=8439}, -- Arcane Explosion Rank 5
            {10205, 26000, req=8446}, -- Scorch Rank 5
            {22782, 28000, req=6117}, -- Mage Armor Rank 2
        },
        [48] = {
            {12525, 1400, req=12524}, -- Pyroblast Rank 6
            {10053, 28000, req=3552}, -- Conjure Mana Gem Rank 3
            {10149, 28000, req=10148}, -- Fireball Rank 9
            {10173, 28000, req=8451}, -- Dampen Magic Rank 4
            {10211, 28000, req=8417}, -- Arcane Missiles Rank 6
            {10215, 28000, req=8423}, -- Flamestrike Rank 5
        },
        [50] = {
            {10139, 32000, req=10138}, -- Conjure Water Rank 6
            {10160, 32000, req=10159}, -- Cone of Cold Rank 4
            {10180, 32000, req=10179}, -- Frostbolt Rank 9
            {10219, 32000, req=7320}, -- Ice Armor Rank 3
            {10223, 32000, req=8458}, -- Fire Ward Rank 4
        },
        [52] = {
            {13020, 1750, req=13019}, -- Blast Wave Rank 4
            {13032, 1750, req=13031}, -- Ice Barrier Rank 3
            {10145, 35000, req=10144}, -- Conjure Food Rank 6
            {10177, 35000, req=8462}, -- Frost Ward Rank 4
            {10186, 35000, req=10185}, -- Blizzard Rank 5
            {10192, 35000, req=10191}, -- Mana Shield Rank 5
            {10206, 35000, req=10205}, -- Scorch Rank 6
        },
        [54] = {
            {12526, 1800, req=12525}, -- Pyroblast Rank 7
            {10150, 36000, req=10149}, -- Fireball Rank 10
            {10170, 36000, req=10169}, -- Amplify Magic Rank 4
            {10199, 36000, req=10197}, -- Fire Blast Rank 7
            {10202, 36000, req=10201}, -- Arcane Explosion Rank 6
            {10230, 36000, req=6131}, -- Frost Nova Rank 4
        },
        [56] = {
            {33041, 1900, req=31661}, -- Dragon's Breath Rank 2
            {10157, 38000, req=10156}, -- Arcane Intellect Rank 5
            {10181, 38000, req=10180}, -- Frostbolt Rank 10
            {10212, 38000, req=10211}, -- Arcane Missiles Rank 7
            {10216, 38000, req=10215}, -- Flamestrike Rank 6
            {23028, 38000, }, -- Arcane Brilliance Rank 1
        },
        [58] = {
            {13033, 2000, req=13032}, -- Ice Barrier Rank 4
            {10054, 40000, req=10053}, -- Conjure Mana Gem Rank 4
            {10161, 40000, req=10160}, -- Cone of Cold Rank 5
            {10207, 40000, req=10206}, -- Scorch Rank 7
            {22783, 40000, req=22782}, -- Mage Armor Rank 3
        },
        [60] = {
            {13021, 2100, req=13020}, -- Blast Wave Rank 5
            {18809, 2100, req=12526}, -- Pyroblast Rank 8
            {33690, 20000, faction="Alliance"}, -- Teleport: Shattrath 
            {35715, 20000, faction="Horde"}, -- Teleport: Shattrath 
            {10140, 42000, req=10139}, -- Conjure Water Rank 7
            {10151, 42000, req=10150}, -- Fireball Rank 11
            {10174, 42000, req=10173}, -- Dampen Magic Rank 5
            {10187, 42000, req=10186}, -- Blizzard Rank 6
            {10193, 42000, req=10192}, -- Mana Shield Rank 6
            {10220, 42000, req=10219}, -- Ice Armor Rank 4
            {10225, 42000, req=10223}, -- Fire Ward Rank 5
            {12826, 42000, req=12825}, -- Polymorph Rank 4
            {25304, 42000, req=10181}, -- Frostbolt Rank 11
            {25345, 42000, req=10212}, -- Arcane Missiles Rank 8
            {28609, 42000, req=10177}, -- Frost Ward Rank 5
            {28612, 42000, req=10145}, -- Conjure Food Rank 7
        },
        [61] = {
            {27078, 46000, req=10199}, -- Fire Blast Rank 8
        },
        [62] = {
            {25306, 42000, req=10151}, -- Fireball Rank 12
            {27080, 51000, req=10202}, -- Arcane Explosion Rank 7
            {30482, 51000, }, -- Molten Armor Rank 1
        },
        [63] = {
            {27071, 57000, req=25304}, -- Frostbolt Rank 12
            {27075, 57000, req=25345}, -- Arcane Missiles Rank 9
            {27130, 57000, req=10170}, -- Amplify Magic Rank 5
        },
        [64] = {
            {33042, 2200, req=33041}, -- Dragon's Breath Rank 3
            {27134, 2500, req=13033}, -- Ice Barrier Rank 5
            {27086, 63000, req=10216}, -- Flamestrike Rank 7
            {30451, 63000, }, -- Arcane Blast Rank 1
        },
        [65] = {
            {27133, 10500, req=13021}, -- Blast Wave Rank 6
            {27073, 70000, req=10207}, -- Scorch Rank 8
            {27087, 70000, req=10161}, -- Cone of Cold Rank 6
            {37420, 70000, req=10140}, -- Conjure Water Rank 8
            {33691, 150000, faction="Alliance"}, -- Portal: Shattrath 
            {35717, 150000, faction="Horde"}, -- Portal: Shattrath 
        },
        [66] = {
            {27132, 10500, req=18809}, -- Pyroblast Rank 9
            {27070, 78000, req=25306}, -- Fireball Rank 13
            {30455, 78000, }, -- Ice Lance Rank 1
        },
        [67] = {
            {27088, 87000, req=10230}, -- Frost Nova Rank 5
            {33944, 87000, req=10174}, -- Dampen Magic Rank 6
        },
        [68] = {
            {66, 96000, }, -- Invisibility 
            {27085, 96000, req=10187}, -- Blizzard Rank 7
            {27101, 96000, req=10054}, -- Conjure Mana Gem Rank 5
            {27131, 96000, req=10193}, -- Mana Shield Rank 7
        },
        [69] = {
            {38699, 87000, req=27075}, -- Arcane Missiles Rank 10
            {27072, 110000, req=27071}, -- Frostbolt Rank 13
            {27124, 110000, req=10220}, -- Ice Armor Rank 5
            {27125, 110000, req=22783}, -- Mage Armor Rank 4
            {27128, 110000, req=10225}, -- Fire Ward Rank 6
            {33946, 110000, req=27130}, -- Amplify Magic Rank 6
        },
        [70] = {
            {33043, 2500, req=33042}, -- Dragon's Breath Rank 4
            {55359, 5000, req=44457}, -- Living Bomb Rank 2
            {44780, 10000, req=44425}, -- Arcane Barrage Rank 2
            {33405, 10500, req=27134}, -- Ice Barrier Rank 6
            {33938, 10500, req=27132}, -- Pyroblast Rank 10
            {33933, 12500, req=27133}, -- Blast Wave Rank 7
            {27127, 100000, req=23028}, -- Arcane Brilliance Rank 2
            {38704, 100000, req=38699}, -- Arcane Missiles Rank 11
            {27074, 120000, req=27073}, -- Scorch Rank 9
            {27079, 120000, req=27078}, -- Fire Blast Rank 9
            {27082, 120000, req=27080}, -- Arcane Explosion Rank 8
            {27126, 120000, req=10157}, -- Arcane Intellect Rank 6
            {30449, 120000, }, -- Spellsteal 
            {32796, 120000, req=28609}, -- Frost Ward Rank 6
            {43987, 120000, }, -- Ritual of Refreshment Rank 1
            {27090, 150000, req=37420}, -- Conjure Water Rank 9
            {33717, 150000, req=28612}, -- Conjure Food Rank 8
            {38692, 150000, req=27070}, -- Fireball Rank 14
            {38697, 150000, req=27072}, -- Frostbolt Rank 14
        },
        [71] = {
            {53140, 100000, }, -- Teleport: Dalaran 
            {42894, 150000, req=30451}, -- Arcane Blast Rank 2
            {43023, 150000, req=27125}, -- Mage Armor Rank 5
            {43045, 150000, req=30482}, -- Molten Armor Rank 2
        },
        [72] = {
            {42913, 150000, req=30455}, -- Ice Lance Rank 2
            {42925, 150000, req=27086}, -- Flamestrike Rank 8
            {42930, 150000, req=27087}, -- Cone of Cold Rank 7
        },
        [73] = {
            {42890, 7500, req=33938}, -- Pyroblast Rank 11
            {42858, 150000, req=27074}, -- Scorch Rank 10
            {43019, 150000, req=27131}, -- Mana Shield Rank 8
        },
        [74] = {
            {53142, 100000, }, -- Portal: Dalaran 
            {42832, 150000, req=38692}, -- Fireball Rank 15
            {42872, 150000, req=27079}, -- Fire Blast Rank 10
            {42939, 150000, req=27085}, -- Blizzard Rank 8
        },
        [75] = {
            {42944, 7500, req=33933}, -- Blast Wave Rank 8
            {42949, 7500, req=33043}, -- Dragon's Breath Rank 5
            {43038, 7500, req=33405}, -- Ice Barrier Rank 7
            {42841, 150000, req=38697}, -- Frostbolt Rank 15
            {42843, 150000, req=38704}, -- Arcane Missiles Rank 12
            {42917, 150000, req=27088}, -- Frost Nova Rank 6
            {42955, 150000, }, -- Conjure Refreshment Rank 1
            {44614, 150000, }, -- Frostfire Bolt Rank 1
        },
        [76] = {
            {42896, 150000, req=42894}, -- Arcane Blast Rank 3
            {42920, 150000, req=27082}, -- Arcane Explosion Rank 9
            {43015, 150000, req=33944}, -- Dampen Magic Rank 7
        },
        [77] = {
            {42891, 7500, req=42890}, -- Pyroblast Rank 12
            {42985, 150000, req=27101}, -- Conjure Mana Gem Rank 6
            {43017, 150000, req=33946}, -- Amplify Magic Rank 7
        },
        [78] = {
            {42833, 150000, req=42832}, -- Fireball Rank 16
            {42859, 150000, req=42858}, -- Scorch Rank 11
            {42914, 150000, req=42913}, -- Ice Lance Rank 3
            {43010, 150000, req=27128}, -- Fire Ward Rank 7
        },
        [79] = {
            {42842, 150000, req=42841}, -- Frostbolt Rank 16
            {42846, 150000, req=42843}, -- Arcane Missiles Rank 13
            {42926, 150000, req=42925}, -- Flamestrike Rank 9
            {42931, 150000, req=42930}, -- Cone of Cold Rank 8
            {43008, 150000, req=27124}, -- Ice Armor Rank 6
            {43012, 150000, req=32796}, -- Frost Ward Rank 7
            {43020, 150000, req=43019}, -- Mana Shield Rank 9
            {43024, 150000, req=43023}, -- Mage Armor Rank 6
            {43046, 150000, req=43045}, -- Molten Armor Rank 3
        },
        [80] = {
            {42945, 7500, req=42944}, -- Blast Wave Rank 9
            {42950, 7500, req=42949}, -- Dragon's Breath Rank 6
            {43039, 7500, req=43038}, -- Ice Barrier Rank 8
            {55360, 7500, req=55359}, -- Living Bomb Rank 3
            {44781, 15000, req=44780}, -- Arcane Barrage Rank 3
            {42873, 150000, req=42872}, -- Fire Blast Rank 11
            {42897, 150000, req=42896}, -- Arcane Blast Rank 4
            {42921, 150000, req=42920}, -- Arcane Explosion Rank 10
            {42940, 150000, req=42939}, -- Blizzard Rank 9
            {42956, 150000, req=42955}, -- Conjure Refreshment Rank 2
            {42995, 150000, req=27126}, -- Arcane Intellect Rank 7
            {43002, 150000, req=27127}, -- Arcane Brilliance Rank 3
            {47610, 150000, req=44614}, -- Frostfire Bolt Rank 2
            {55342, 150000, }, -- Mirror Image 
            {58659, 150000, req=43987}, -- Ritual of Refreshment Rank 2
        },
    },
    PRIEST = {
        [0] = {
            {198, 1000, }, -- One-Handed Maces 
            {227, 1000, }, -- Staves 
            {1180, 1000, }, -- Daggers 
        },
        [1] = {
            {1243, 10, }, -- Power Word: Fortitude Rank 1
        },
        [4] = {
            {589, 100, }, -- Shadow Word: Pain Rank 1
            {2052, 100, req=2050}, -- Lesser Heal Rank 2
        },
        [6] = {
            {17, 100, }, -- Power Word: Shield Rank 1
            {591, 100, req=585}, -- Smite Rank 2
        },
        [8] = {
            {139, 200, }, -- Renew Rank 1
            {586, 200, }, -- Fade 
        },
        [10] = {
            {594, 300, req=589}, -- Shadow Word: Pain Rank 2
            {2006, 300, }, -- Resurrection Rank 1
            {2053, 300, req=2052}, -- Lesser Heal Rank 3
            {8092, 300, }, -- Mind Blast Rank 1
        },
        [12] = {
            {588, 800, }, -- Inner Fire Rank 1
            {592, 800, req=17}, -- Power Word: Shield Rank 2
            {1244, 800, req=1243}, -- Power Word: Fortitude Rank 2
        },
        [14] = {
            {528, 1200, }, -- Cure Disease 
            {598, 1200, req=591}, -- Smite Rank 3
            {6074, 1200, req=139}, -- Renew Rank 2
            {8122, 1200, }, -- Psychic Scream Rank 1
        },
        [16] = {
            {2054, 1600, }, -- Heal Rank 1
            {8102, 1600, req=8092}, -- Mind Blast Rank 2
        },
        [18] = {
            {527, 2000, }, -- Dispel Magic Rank 1
            {600, 2000, req=592}, -- Power Word: Shield Rank 3
            {970, 2000, req=594}, -- Shadow Word: Pain Rank 3
        },
        [20] = {
            {2944, 100, }, -- Devouring Plague Rank 1
            {6346, 800, }, -- Fear Ward 
            {453, 3000, }, -- Mind Soothe 
            {2061, 3000, }, -- Flash Heal Rank 1
            {6075, 3000, req=6074}, -- Renew Rank 3
            {7128, 3000, req=588}, -- Inner Fire Rank 2
            {9484, 3000, }, -- Shackle Undead Rank 1
            {14914, 3000, }, -- Holy Fire Rank 1
            {15237, 3000, }, -- Holy Nova Rank 1
        },
        [22] = {
            {984, 4000, req=598}, -- Smite Rank 4
            {2010, 4000, req=2006}, -- Resurrection Rank 2
            {2055, 4000, req=2054}, -- Heal Rank 2
            {2096, 4000, }, -- Mind Vision Rank 1
            {8103, 4000, req=8102}, -- Mind Blast Rank 3
        },
        [24] = {
            {1245, 5000, req=1244}, -- Power Word: Fortitude Rank 3
            {3747, 5000, req=600}, -- Power Word: Shield Rank 4
            {8129, 5000, }, -- Mana Burn 
            {15262, 5000, req=14914}, -- Holy Fire Rank 2
        },
        [26] = {
            {19238, 300, req=19236}, -- Desperate Prayer Rank 2
            {992, 6000, req=970}, -- Shadow Word: Pain Rank 4
            {6076, 6000, req=6075}, -- Renew Rank 4
            {9472, 6000, req=2061}, -- Flash Heal Rank 2
        },
        [28] = {
            {15430, 400, req=15237}, -- Holy Nova Rank 2
            {17311, 400, req=15407}, -- Mind Flay Rank 2
            {19276, 400, req=2944}, -- Devouring Plague Rank 2
            {6063, 8000, req=2055}, -- Heal Rank 3
            {8104, 8000, req=8103}, -- Mind Blast Rank 4
            {8124, 8000, req=8122}, -- Psychic Scream Rank 2
        },
        [30] = {
            {14752, 600, }, -- Divine Spirit Rank 1
            {596, 10000, }, -- Prayer of Healing Rank 1
            {602, 10000, req=7128}, -- Inner Fire Rank 3
            {605, 10000, }, -- Mind Control 
            {976, 10000, }, -- Shadow Protection Rank 1
            {1004, 10000, req=984}, -- Smite Rank 5
            {6065, 10000, req=3747}, -- Power Word: Shield Rank 5
            {15263, 10000, req=15262}, -- Holy Fire Rank 3
        },
        [32] = {
            {552, 11000, }, -- Abolish Disease 
            {6077, 11000, req=6076}, -- Renew Rank 5
            {9473, 11000, req=9472}, -- Flash Heal Rank 3
        },
        [34] = {
            {19240, 600, req=19238}, -- Desperate Prayer Rank 3
            {1706, 12000, }, -- Levitate 
            {2767, 12000, req=992}, -- Shadow Word: Pain Rank 5
            {6064, 12000, req=6063}, -- Heal Rank 4
            {8105, 12000, req=8104}, -- Mind Blast Rank 5
            {10880, 12000, req=2010}, -- Resurrection Rank 3
        },
        [36] = {
            {15431, 700, req=15430}, -- Holy Nova Rank 3
            {17312, 700, req=17311}, -- Mind Flay Rank 3
            {19277, 700, req=19276}, -- Devouring Plague Rank 3
            {988, 14000, req=527}, -- Dispel Magic Rank 2
            {2791, 14000, req=1245}, -- Power Word: Fortitude Rank 4
            {6066, 14000, req=6065}, -- Power Word: Shield Rank 6
            {15264, 14000, req=15263}, -- Holy Fire Rank 4
        },
        [38] = {
            {6060, 16000, req=1004}, -- Smite Rank 6
            {6078, 16000, req=6077}, -- Renew Rank 6
            {9474, 16000, req=9473}, -- Flash Heal Rank 4
        },
        [40] = {
            {14818, 900, req=14752}, -- Divine Spirit Rank 2
            {996, 18000, req=596}, -- Prayer of Healing Rank 2
            {1006, 18000, req=602}, -- Inner Fire Rank 4
            {2060, 18000, }, -- Greater Heal Rank 1
            {8106, 18000, req=8105}, -- Mind Blast Rank 6
            {9485, 18000, req=9484}, -- Shackle Undead Rank 2
        },
        [42] = {
            {19241, 1100, req=19240}, -- Desperate Prayer Rank 4
            {10888, 22000, req=8124}, -- Psychic Scream Rank 3
            {10892, 22000, req=2767}, -- Shadow Word: Pain Rank 6
            {10898, 22000, req=6066}, -- Power Word: Shield Rank 7
            {10957, 22000, req=976}, -- Shadow Protection Rank 2
            {15265, 22000, req=15264}, -- Holy Fire Rank 5
        },
        [44] = {
            {17313, 1200, req=17312}, -- Mind Flay Rank 4
            {19278, 1200, req=19277}, -- Devouring Plague Rank 4
            {27799, 1200, req=15431}, -- Holy Nova Rank 4
            {10909, 24000, req=2096}, -- Mind Vision Rank 2
            {10915, 24000, req=9474}, -- Flash Heal Rank 5
            {10927, 24000, req=6078}, -- Renew Rank 7
        },
        [46] = {
            {10881, 26000, req=10880}, -- Resurrection Rank 4
            {10933, 26000, req=6060}, -- Smite Rank 7
            {10945, 26000, req=8106}, -- Mind Blast Rank 7
            {10963, 26000, req=2060}, -- Greater Heal Rank 2
        },
        [48] = {
            {10899, 28000, req=10898}, -- Power Word: Shield Rank 8
            {10937, 28000, req=2791}, -- Power Word: Fortitude Rank 5
            {15266, 28000, req=15265}, -- Holy Fire Rank 6
            {21562, 28000, }, -- Prayer of Fortitude Rank 1
        },
        [50] = {
            {27870, 1200, req=724}, -- Lightwell Rank 2
            {14819, 1500, req=14818}, -- Divine Spirit Rank 3
            {19242, 1500, req=19241}, -- Desperate Prayer Rank 5
            {10893, 30000, req=10892}, -- Shadow Word: Pain Rank 7
            {10916, 30000, req=10915}, -- Flash Heal Rank 6
            {10928, 30000, req=10927}, -- Renew Rank 8
            {10951, 30000, req=1006}, -- Inner Fire Rank 5
            {10960, 30000, req=996}, -- Prayer of Healing Rank 3
        },
        [52] = {
            {17314, 1900, req=17313}, -- Mind Flay Rank 5
            {19279, 1900, req=19278}, -- Devouring Plague Rank 5
            {27800, 1900, req=27799}, -- Holy Nova Rank 5
            {10946, 38000, req=10945}, -- Mind Blast Rank 8
            {10964, 38000, req=10963}, -- Greater Heal Rank 3
        },
        [54] = {
            {10900, 40000, req=10899}, -- Power Word: Shield Rank 9
            {10934, 40000, req=10933}, -- Smite Rank 8
            {15267, 40000, req=15266}, -- Holy Fire Rank 7
        },
        [56] = {
            {34863, 2100, req=34861}, -- Circle of Healing Rank 2
            {10890, 42000, req=10888}, -- Psychic Scream Rank 4
            {10917, 42000, req=10916}, -- Flash Heal Rank 7
            {10929, 42000, req=10928}, -- Renew Rank 9
            {10958, 42000, req=10957}, -- Shadow Protection Rank 3
            {27683, 42000, }, -- Prayer of Shadow Protection Rank 1
        },
        [58] = {
            {19243, 2200, req=19242}, -- Desperate Prayer Rank 6
            {10894, 44000, req=10893}, -- Shadow Word: Pain Rank 8
            {10947, 44000, req=10946}, -- Mind Blast Rank 9
            {10965, 44000, req=10964}, -- Greater Heal Rank 4
            {20770, 44000, req=10881}, -- Resurrection Rank 5
        },
        [60] = {
            {27871, 1500, req=27870}, -- Lightwell Rank 3
            {18807, 2300, req=17314}, -- Mind Flay Rank 6
            {19280, 2300, req=19279}, -- Devouring Plague Rank 6
            {27681, 2300, req=14752}, -- Prayer of Spirit Rank 1
            {27801, 2300, req=27800}, -- Holy Nova Rank 6
            {27841, 2300, req=14819}, -- Divine Spirit Rank 4
            {34864, 2300, req=34863}, -- Circle of Healing Rank 3
            {34916, 2300, req=34914}, -- Vampiric Touch Rank 2
            {25315, 6500, req=10929}, -- Renew Rank 10
            {25316, 6500, req=10961}, -- Prayer of Healing Rank 5
            {10901, 46000, req=10900}, -- Power Word: Shield Rank 10
            {10938, 46000, req=10937}, -- Power Word: Fortitude Rank 6
            {10952, 46000, req=10951}, -- Inner Fire Rank 6
            {10955, 46000, req=9485}, -- Shackle Undead Rank 3
            {10961, 46000, req=10960}, -- Prayer of Healing Rank 4
            {15261, 46000, req=15267}, -- Holy Fire Rank 8
            {21564, 46000, req=21562}, -- Prayer of Fortitude Rank 2
            {25314, 65000, req=10965}, -- Greater Heal Rank 5
        },
        [61] = {
            {25233, 53000, req=10917}, -- Flash Heal Rank 8
            {25363, 53000, req=10934}, -- Smite Rank 9
        },
        [62] = {
            {32379, 59000, }, -- Shadow Word: Death Rank 1
        },
        [63] = {
            {25210, 65000, req=25314}, -- Greater Heal Rank 6
            {25372, 65000, req=10947}, -- Mind Blast Rank 10
        },
        [64] = {
            {32546, 72000, }, -- Binding Heal Rank 1
        },
        [65] = {
            {34865, 2300, req=34864}, -- Circle of Healing Rank 4
            {25217, 80000, req=10901}, -- Power Word: Shield Rank 11
            {25221, 80000, req=25315}, -- Renew Rank 11
            {25367, 80000, req=10894}, -- Shadow Word: Pain Rank 9
        },
        [66] = {
            {25437, 6500, req=19243}, -- Desperate Prayer Rank 7
            {25384, 65000, req=15261}, -- Holy Fire Rank 9
            {34433, 89000, }, -- Shadowfiend 
        },
        [67] = {
            {25235, 99000, req=25233}, -- Flash Heal Rank 9
        },
        [68] = {
            {25331, 3250, req=27801}, -- Holy Nova Rank 7
            {25387, 6500, req=18807}, -- Mind Flay Rank 7
            {25467, 6500, req=19280}, -- Devouring Plague Rank 7
            {25213, 110000, req=25210}, -- Greater Heal Rank 7
            {25308, 110000, req=25316}, -- Prayer of Healing Rank 6
            {25433, 110000, req=10958}, -- Shadow Protection Rank 4
            {25435, 110000, req=20770}, -- Resurrection Rank 6
            {33076, 110000, }, -- Prayer of Mending Rank 1
        },
        [69] = {
            {25364, 65000, req=25363}, -- Smite Rank 10
            {25375, 65000, req=25372}, -- Mind Blast Rank 11
            {25431, 65000, req=10952}, -- Inner Fire Rank 7
        },
        [70] = {
            {28275, 1500, req=27871}, -- Lightwell Rank 4
            {25312, 2300, req=27841}, -- Divine Spirit Rank 5
            {34866, 2300, req=34865}, -- Circle of Healing Rank 5
            {34917, 2300, req=34916}, -- Vampiric Touch Rank 3
            {32999, 3400, req=27681}, -- Prayer of Spirit Rank 2
            {53005, 5000, req=47540}, -- Penance Rank 2
            {25389, 65000, req=10938}, -- Power Word: Fortitude Rank 7
            {25392, 100000, req=21564}, -- Prayer of Fortitude Rank 3
            {39374, 100000, req=27683}, -- Prayer of Shadow Protection Rank 2
            {32375, 110000, }, -- Mass Dispel 
            {32996, 110000, req=32379}, -- Shadow Word: Death Rank 2
            {25218, 140000, req=25217}, -- Power Word: Shield Rank 12
            {25222, 140000, req=25221}, -- Renew Rank 12
            {25368, 140000, req=25367}, -- Shadow Word: Pain Rank 10
        },
        [71] = {
            {48040, 180000, req=25431}, -- Inner Fire Rank 8
        },
        [72] = {
            {48119, 180000, req=32546}, -- Binding Heal Rank 2
            {48134, 180000, req=25384}, -- Holy Fire Rank 10
        },
        [73] = {
            {48172, 3250, req=25437}, -- Desperate Prayer Rank 8
            {48062, 180000, req=25213}, -- Greater Heal Rank 8
            {48070, 180000, req=25235}, -- Flash Heal Rank 10
            {48299, 180000, req=25467}, -- Devouring Plague Rank 8
        },
        [74] = {
            {48155, 9000, req=25387}, -- Mind Flay Rank 8
            {48112, 100000, req=33076}, -- Prayer of Mending Rank 2
            {48122, 180000, req=25364}, -- Smite Rank 11
            {48126, 180000, req=25375}, -- Mind Blast Rank 12
        },
        [75] = {
            {48086, 9000, req=28275}, -- Lightwell Rank 5
            {48088, 9000, req=34866}, -- Circle of Healing Rank 6
            {48159, 9000, req=34917}, -- Vampiric Touch Rank 4
            {53006, 9000, req=53005}, -- Penance Rank 3
            {48045, 10000, }, -- Mind Sear Rank 1
            {48065, 180000, req=25218}, -- Power Word: Shield Rank 13
            {48067, 180000, req=25222}, -- Renew Rank 13
            {48077, 180000, req=25331}, -- Holy Nova Rank 8
            {48124, 180000, req=25368}, -- Shadow Word: Pain Rank 11
            {48157, 180000, req=32996}, -- Shadow Word: Death Rank 3
        },
        [76] = {
            {48072, 180000, req=25308}, -- Prayer of Healing Rank 7
            {48169, 180000, req=25433}, -- Shadow Protection Rank 5
        },
        [77] = {
            {48168, 180000, req=48040}, -- Inner Fire Rank 9
            {48170, 180000, req=39374}, -- Prayer of Shadow Protection Rank 3
        },
        [78] = {
            {48063, 180000, req=48062}, -- Greater Heal Rank 9
            {48120, 180000, req=48119}, -- Binding Heal Rank 3
            {48135, 180000, req=48134}, -- Holy Fire Rank 11
            {48171, 180000, req=25435}, -- Resurrection Rank 7
        },
        [79] = {
            {48071, 180000, req=48070}, -- Flash Heal Rank 11
            {48113, 180000, req=48112}, -- Prayer of Mending Rank 3
            {48123, 180000, req=48122}, -- Smite Rank 12
            {48127, 180000, req=48126}, -- Mind Blast Rank 13
            {48300, 180000, req=48299}, -- Devouring Plague Rank 9
        },
        [80] = {
            {48073, 9000, req=25312}, -- Divine Spirit Rank 6
            {48074, 9000, req=32999}, -- Prayer of Spirit Rank 3
            {48087, 9000, req=48086}, -- Lightwell Rank 6
            {48089, 9000, req=48088}, -- Circle of Healing Rank 7
            {48156, 9000, req=48155}, -- Mind Flay Rank 9
            {48160, 9000, req=48159}, -- Vampiric Touch Rank 5
            {48173, 9000, req=48172}, -- Desperate Prayer Rank 9
            {53007, 9000, req=53006}, -- Penance Rank 4
            {64901, 65000, }, -- Hymn of Hope 
            {53023, 100000, req=48045}, -- Mind Sear Rank 2
            {48066, 180000, req=48065}, -- Power Word: Shield Rank 14
            {48068, 180000, req=48067}, -- Renew Rank 14
            {48078, 180000, req=48077}, -- Holy Nova Rank 9
            {48125, 180000, req=48124}, -- Shadow Word: Pain Rank 12
            {48158, 180000, req=48157}, -- Shadow Word: Death Rank 4
            {48161, 180000, req=25389}, -- Power Word: Fortitude Rank 8
            {48162, 180000, req=25392}, -- Prayer of Fortitude Rank 4
            {64843, 180000, }, -- Divine Hymn Rank 1
        },
    },
    WARLOCK = {
        [0] = {
            {201, 1000, }, -- One-Handed Swords 
            {227, 1000, }, -- Staves 
            {1180, 1000, }, -- Daggers 
        },
        [1] = {
            {688, 100, }, -- Summon Imp Summon
        },
        [3] = {
            {348, 10, }, -- Immolate Rank 1
        },
        [4] = {
            {172, 100, }, -- Corruption Rank 1
            {702, 100, }, -- Curse of Weakness Rank 1
        },
        [6] = {
            {695, 100, req=686}, -- Shadow Bolt Rank 2
            {1454, 100, }, -- Life Tap Rank 1
        },
        [8] = {
            {980, 200, }, -- Curse of Agony Rank 1
            {5782, 200, }, -- Fear Rank 1
        },
        [10] = {
            {696, 300, req=687}, -- Demon Skin Rank 2
            {707, 300, req=348}, -- Immolate Rank 2
            {1120, 300, }, -- Drain Soul Rank 1
            {6201, 300, }, -- Create Healthstone Rank 1
        },
        [12] = {
            {705, 600, req=695}, -- Shadow Bolt Rank 3
            {755, 600, }, -- Health Funnel Rank 1
            {1108, 600, req=702}, -- Curse of Weakness Rank 2
        },
        [14] = {
            {689, 900, }, -- Drain Life Rank 1
            {6222, 900, req=172}, -- Corruption Rank 2
        },
        [16] = {
            {1455, 1200, req=1454}, -- Life Tap Rank 2
            {5697, 1200, }, -- Unending Breath 
        },
        [18] = {
            {693, 1500, }, -- Create Soulstone Rank 1
            {1014, 1500, req=980}, -- Curse of Agony Rank 2
            {5676, 1500, }, -- Searing Pain Rank 1
        },
        [20] = {
            {698, 2000, }, -- Ritual of Summoning 
            {706, 2000, }, -- Demon Armor Rank 1
            {1088, 2000, req=705}, -- Shadow Bolt Rank 4
            {1094, 2000, req=707}, -- Immolate Rank 3
            {3698, 2000, req=755}, -- Health Funnel Rank 2
            {5740, 2000, }, -- Rain of Fire Rank 1
            {1710, 3500, }, -- Summon Felsteed
        },
        [22] = {
            {126, 2500, }, -- Eye of Kilrogg Summon
            {699, 2500, req=689}, -- Drain Life Rank 2
            {6202, 2500, req=6201}, -- Create Healthstone Rank 2
            {6205, 2500, req=1108}, -- Curse of Weakness Rank 3
        },
        [24] = {
            {18867, 150, req=17877}, -- Shadowburn Rank 2
            {5138, 3000, }, -- Drain Mana 
            {5500, 3000, }, -- Sense Demons 
            {6223, 3000, req=6222}, -- Corruption Rank 3
            {8288, 3000, req=1120}, -- Drain Soul Rank 2
        },
        [26] = {
            {132, 4000, }, -- Detect Invisibility 
            {1456, 4000, req=1455}, -- Life Tap Rank 3
            {1714, 4000, }, -- Curse of Tongues Rank 1
            {17919, 4000, req=5676}, -- Searing Pain Rank 2
        },
        [28] = {
            {710, 5000, }, -- Banish Rank 1
            {1106, 5000, req=1088}, -- Shadow Bolt Rank 5
            {3699, 5000, req=3698}, -- Health Funnel Rank 3
            {6217, 5000, req=1014}, -- Curse of Agony Rank 3
            {6366, 5000, }, -- Create Firestone Rank 1
        },
        [30] = {
            {709, 6000, req=699}, -- Drain Life Rank 3
            {1086, 6000, req=706}, -- Demon Armor Rank 2
            {1098, 6000, }, -- Subjugate Demon Rank 1
            {1949, 6000, }, -- Hellfire Rank 1
            {2941, 6000, req=1094}, -- Immolate Rank 4
            {20752, 6000, req=693}, -- Create Soulstone Rank 2
        },
        [32] = {
            {18868, 350, req=18867}, -- Shadowburn Rank 3
            {1490, 7000, }, -- Curse of the Elements Rank 1
            {6213, 7000, req=5782}, -- Fear Rank 2
            {6229, 7000, }, -- Shadow Ward Rank 1
            {7646, 7000, req=6205}, -- Curse of Weakness Rank 4
        },
        [34] = {
            {5699, 8000, req=6202}, -- Create Healthstone Rank 3
            {6219, 8000, req=5740}, -- Rain of Fire Rank 2
            {7648, 8000, req=6223}, -- Corruption Rank 4
            {17920, 8000, req=17919}, -- Searing Pain Rank 3
        },
        [36] = {
            {2362, 9000, }, -- Create Spellstone Rank 1
            {3700, 9000, req=3699}, -- Health Funnel Rank 4
            {7641, 9000, req=1106}, -- Shadow Bolt Rank 6
            {11687, 9000, req=1456}, -- Life Tap Rank 4
            {17951, 9000, req=6366}, -- Create Firestone Rank 2
        },
        [38] = {
            {7651, 10000, req=709}, -- Drain Life Rank 4
            {8289, 10000, req=8288}, -- Drain Soul Rank 3
            {11711, 10000, req=6217}, -- Curse of Agony Rank 4
        },
        [40] = {
            {18869, 550, req=18868}, -- Shadowburn Rank 4
            {5484, 11000, }, -- Howl of Terror Rank 1
            {11665, 11000, req=2941}, -- Immolate Rank 5
            {11733, 11000, req=1086}, -- Demon Armor Rank 3
            {20755, 11000, req=20752}, -- Create Soulstone Rank 3
            {23161, 20000, req=1710}, -- Dreadsteed
        },
        [42] = {
            {6789, 11000, }, -- Death Coil Rank 1
            {11683, 11000, req=1949}, -- Hellfire Rank 2
            {11707, 11000, req=7646}, -- Curse of Weakness Rank 5
            {11739, 11000, req=6229}, -- Shadow Ward Rank 2
            {17921, 11000, req=17920}, -- Searing Pain Rank 4
        },
        [44] = {
            {11659, 12000, req=7641}, -- Shadow Bolt Rank 7
            {11671, 12000, req=7648}, -- Corruption Rank 5
            {11693, 12000, req=3700}, -- Health Funnel Rank 5
            {11725, 12000, req=1098}, -- Subjugate Demon Rank 2
        },
        [46] = {
            {11677, 13000, req=6219}, -- Rain of Fire Rank 3
            {11688, 13000, req=11687}, -- Life Tap Rank 5
            {11699, 13000, req=7651}, -- Drain Life Rank 5
            {11721, 13000, req=1490}, -- Curse of the Elements Rank 2
            {11729, 13000, req=5699}, -- Create Healthstone Rank 4
            {17952, 13000, req=17951}, -- Create Firestone Rank 3
        },
        [48] = {
            {18870, 700, req=18869}, -- Shadowburn Rank 5
            {6353, 14000, }, -- Soul Fire Rank 1
            {11712, 14000, req=11711}, -- Curse of Agony Rank 5
            {17727, 14000, req=2362}, -- Create Spellstone Rank 2
            {18647, 14000, req=710}, -- Banish Rank 2
        },
        [50] = {
            {18937, 750, req=18220}, -- Dark Pact Rank 2
            {11667, 15000, req=11665}, -- Immolate Rank 6
            {11719, 15000, req=1714}, -- Curse of Tongues Rank 2
            {11734, 15000, req=11733}, -- Demon Armor Rank 4
            {17922, 15000, req=17921}, -- Searing Pain Rank 5
            {17925, 15000, req=6789}, -- Death Coil Rank 2
            {20756, 15000, req=20755}, -- Create Soulstone Rank 4
        },
        [52] = {
            {11660, 18000, req=11659}, -- Shadow Bolt Rank 8
            {11675, 18000, req=8289}, -- Drain Soul Rank 4
            {11694, 18000, req=11693}, -- Health Funnel Rank 6
            {11708, 18000, req=11707}, -- Curse of Weakness Rank 6
            {11740, 18000, req=11739}, -- Shadow Ward Rank 3
        },
        [54] = {
            {11672, 20000, req=11671}, -- Corruption Rank 6
            {11684, 20000, req=11683}, -- Hellfire Rank 3
            {11700, 20000, req=11699}, -- Drain Life Rank 6
            {17928, 20000, req=5484}, -- Howl of Terror Rank 2
        },
        [56] = {
            {18871, 1100, req=18870}, -- Shadowburn Rank 6
            {6215, 22000, req=6213}, -- Fear Rank 3
            {11689, 22000, req=11688}, -- Life Tap Rank 6
            {17924, 22000, req=6353}, -- Soul Fire Rank 2
            {17953, 22000, req=17952}, -- Create Firestone Rank 4
        },
        [58] = {
            {11678, 24000, req=11677}, -- Rain of Fire Rank 4
            {11713, 24000, req=11712}, -- Curse of Agony Rank 6
            {11726, 24000, req=11725}, -- Subjugate Demon Rank 3
            {11730, 24000, req=11729}, -- Create Healthstone Rank 5
            {17923, 24000, req=17922}, -- Searing Pain Rank 6
            {17926, 24000, req=17925}, -- Death Coil Rank 3
        },
        [60] = {
            {18938, 1300, req=18937}, -- Dark Pact Rank 3
            {30404, 2500, req=30108}, -- Unstable Affliction Rank 2
            {30413, 2500, req=30283}, -- Shadowfury Rank 2
            {603, 26000, }, -- Curse of Doom Rank 1
            {11661, 26000, req=11660}, -- Shadow Bolt Rank 9
            {11668, 26000, req=11667}, -- Immolate Rank 7
            {11695, 26000, req=11694}, -- Health Funnel Rank 7
            {11722, 26000, req=11721}, -- Curse of the Elements Rank 3
            {11735, 26000, req=11734}, -- Demon Armor Rank 5
            {17728, 26000, req=17727}, -- Create Spellstone Rank 3
            {20757, 26000, req=20756}, -- Create Soulstone Rank 5
            {25309, 26000, req=11668}, -- Immolate Rank 8
            {25311, 26000, req=11672}, -- Corruption Rank 7
            {28610, 34000, req=11740}, -- Shadow Ward Rank 4
        },
        [61] = {
            {27224, 30000, req=11708}, -- Curse of Weakness Rank 7
        },
        [62] = {
            {25307, 26000, req=11661}, -- Shadow Bolt Rank 10
            {27219, 30000, req=11700}, -- Drain Life Rank 7
            {28176, 34000, }, -- Fel Armor Rank 1
        },
        [63] = {
            {27263, 1300, req=18871}, -- Shadowburn Rank 7
        },
        [64] = {
            {27211, 42000, req=17924}, -- Soul Fire Rank 3
            {29722, 42000, }, -- Incinerate Rank 1
        },
        [65] = {
            {27210, 46000, req=17923}, -- Searing Pain Rank 7
            {27216, 46000, req=25311}, -- Corruption Rank 8
        },
        [66] = {
            {27250, 51000, req=17953}, -- Create Firestone Rank 5
            {28172, 51000, req=17728}, -- Create Spellstone Rank 4
            {29858, 51000, }, -- Soulshatter 
        },
        [67] = {
            {27217, 57000, req=11675}, -- Drain Soul Rank 5
            {27218, 57000, req=11713}, -- Curse of Agony Rank 7
            {27259, 57000, req=11695}, -- Health Funnel Rank 8
        },
        [68] = {
            {27222, 56700, req=11689}, -- Life Tap Rank 7
            {27213, 63000, req=11684}, -- Hellfire Rank 4
            {27223, 63000, req=17926}, -- Death Coil Rank 4
            {27230, 63000, req=11730}, -- Create Healthstone Rank 6
            {29893, 63000, }, -- Ritual of Souls Rank 1
        },
        [69] = {
            {27209, 70000, req=25307}, -- Shadow Bolt Rank 11
            {27212, 70000, req=11678}, -- Rain of Fire Rank 5
            {27215, 70000, req=25309}, -- Immolate Rank 9
            {27220, 70000, req=27219}, -- Drain Life Rank 8
            {27228, 70000, req=11722}, -- Curse of the Elements Rank 4
            {28189, 70000, req=28176}, -- Fel Armor Rank 2
            {30909, 70000, req=27224}, -- Curse of Weakness Rank 8
        },
        [70] = {
            {27265, 1300, req=18938}, -- Dark Pact Rank 4
            {30405, 2500, req=30404}, -- Unstable Affliction Rank 3
            {30414, 2500, req=30413}, -- Shadowfury Rank 3
            {59161, 2500, req=48181}, -- Haunt Rank 2
            {59170, 2500, req=50796}, -- Chaos Bolt Rank 2
            {30546, 3900, req=27263}, -- Shadowburn Rank 8
            {27238, 78000, req=20757}, -- Create Soulstone Rank 6
            {27243, 78000, }, -- Seed of Corruption Rank 1
            {27260, 78000, req=11735}, -- Demon Armor Rank 6
            {30459, 78000, req=27210}, -- Searing Pain Rank 8
            {30545, 78000, req=27211}, -- Soul Fire Rank 4
            {30910, 78000, req=603}, -- Curse of Doom Rank 2
            {32231, 78000, req=29722}, -- Incinerate Rank 2
        },
        [71] = {
            {47812, 160000, req=27216}, -- Corruption Rank 9
            {50511, 160000, req=30909}, -- Curse of Weakness Rank 9
        },
        [72] = {
            {61191, 70000, req=11726}, -- Subjugate Demon Rank 4
            {47819, 160000, req=27212}, -- Rain of Fire Rank 6
            {47886, 160000, req=28172}, -- Create Spellstone Rank 5
            {47890, 160000, req=28610}, -- Shadow Ward Rank 5
        },
        [73] = {
            {47859, 160000, req=27223}, -- Death Coil Rank 5
            {47863, 160000, req=27218}, -- Curse of Agony Rank 8
            {47871, 160000, req=27230}, -- Create Healthstone Rank 7
        },
        [74] = {
            {47837, 100000, req=32231}, -- Incinerate Rank 3
            {47808, 160000, req=27209}, -- Shadow Bolt Rank 12
            {47814, 160000, req=30459}, -- Searing Pain Rank 9
            {47892, 160000, req=28189}, -- Fel Armor Rank 3
            {60219, 160000, req=27250}, -- Create Firestone Rank 6
        },
        [75] = {
            {47826, 8000, req=30546}, -- Shadowburn Rank 9
            {47841, 8000, req=30405}, -- Unstable Affliction Rank 4
            {47846, 8000, req=30414}, -- Shadowfury Rank 4
            {59163, 8000, req=59161}, -- Haunt Rank 3
            {59171, 8000, req=59170}, -- Chaos Bolt Rank 3
            {47897, 10000, }, -- Shadowflame Rank 1
            {47810, 160000, req=27215}, -- Immolate Rank 10
            {47824, 160000, req=30545}, -- Soul Fire Rank 5
            {47835, 160000, req=27243}, -- Seed of Corruption Rank 2
        },
        [76] = {
            {47793, 160000, req=27260}, -- Demon Armor Rank 7
            {47856, 160000, req=27259}, -- Health Funnel Rank 9
            {47884, 160000, req=27238}, -- Create Soulstone Rank 7
        },
        [77] = {
            {47813, 160000, req=47812}, -- Corruption Rank 10
            {47855, 160000, req=27217}, -- Drain Soul Rank 6
        },
        [78] = {
            {47823, 160000, req=27213}, -- Hellfire Rank 5
            {47857, 160000, req=27220}, -- Drain Life Rank 9
            {47860, 160000, req=47859}, -- Death Coil Rank 6
            {47865, 160000, req=27228}, -- Curse of the Elements Rank 5
            {47888, 160000, req=47886}, -- Create Spellstone Rank 6
            {47891, 160000, req=47890}, -- Shadow Ward Rank 6
        },
        [79] = {
            {47809, 160000, req=47808}, -- Shadow Bolt Rank 13
            {47815, 160000, req=47814}, -- Searing Pain Rank 10
            {47820, 160000, req=47819}, -- Rain of Fire Rank 7
            {47864, 160000, req=47863}, -- Curse of Agony Rank 9
            {47878, 160000, req=47871}, -- Create Healthstone Rank 8
            {47893, 160000, req=47892}, -- Fel Armor Rank 4
        },
        [80] = {
            {47827, 8000, req=47826}, -- Shadowburn Rank 10
            {47843, 8000, req=47841}, -- Unstable Affliction Rank 5
            {47847, 8000, req=47846}, -- Shadowfury Rank 5
            {59164, 8000, req=59163}, -- Haunt Rank 4
            {59172, 8000, req=59171}, -- Chaos Bolt Rank 4
            {61290, 10000, req=47897}, -- Shadowflame Rank 2
            {47838, 100000, req=47837}, -- Incinerate Rank 4
            {47811, 160000, req=47810}, -- Immolate Rank 11
            {47825, 160000, req=47824}, -- Soul Fire Rank 6
            {47836, 160000, req=47835}, -- Seed of Corruption Rank 3
            {47867, 160000, req=30910}, -- Curse of Doom Rank 3
            {47889, 160000, req=47793}, -- Demon Armor Rank 8
            {48018, 160000, }, -- Demonic Circle: Summon 
            {48020, 160000, }, -- Demonic Circle: Teleport 
            {57946, 160000, req=27222}, -- Life Tap Rank 8
            {58887, 160000, req=29893}, -- Ritual of Souls Rank 2
            {59092, 160000, req=27265}, -- Dark Pact Rank 5
            {60220, 160000, req=60219}, -- Create Firestone Rank 7
        },
    },
    DRUID = {
        [0] = {
            {198, 1000, }, -- One-Handed Maces 
            {199, 1000, }, -- Two-Handed Maces 
            {227, 1000, }, -- Staves 
            {1180, 1000, }, -- Daggers 
            {15590, 1000, }, -- Fist Weapons 
        },
        [1] = {
            {1126, 10, }, -- Mark of the Wild Rank 1
        },
        [4] = {
            {774, 100, }, -- Rejuvenation Rank 1
            {8921, 100, }, -- Moonfire Rank 1
        },
        [6] = {
            {467, 100, }, -- Thorns Rank 1
            {5177, 100, req=5176}, -- Wrath Rank 2
        },
        [8] = {
            {339, 200, }, -- Entangling Roots Rank 1
            {5186, 200, req=5185}, -- Healing Touch Rank 2
        },
        [10] = {
            {99, 300, }, -- Demoralizing Roar Rank 1
            {1058, 300, req=774}, -- Rejuvenation Rank 2
            {5232, 300, req=1126}, -- Mark of the Wild Rank 2
            {8924, 300, req=8921}, -- Moonfire Rank 2
            {16689, 300, req=339}, -- Nature's Grasp Rank 1
        },
        [12] = {
            {5229, 800, }, -- Enrage 
            {8936, 800, }, -- Regrowth Rank 1
            {50769, 800, }, -- Revive Rank 1
        },
        [14] = {
            {782, 900, req=467}, -- Thorns Rank 2
            {5178, 900, req=5177}, -- Wrath Rank 3
            {5187, 900, req=5186}, -- Healing Touch Rank 3
            {5211, 900, }, -- Bash Rank 1
        },
        [16] = {
            {1066, 900, }, -- Aquatic Form Shapeshift
            {779, 1800, }, -- Swipe (Bear) Rank 1
            {1430, 1800, req=1058}, -- Rejuvenation Rank 3
            {8925, 1800, req=8924}, -- Moonfire Rank 3
            {783, 6000, }, -- Travel Form Shapeshift
        },
        [18] = {
            {16810, 95, req=16689}, -- Nature's Grasp Rank 2
            {770, 1900, }, -- Faerie Fire 
            {1062, 1900, req=339}, -- Entangling Roots Rank 2
            {2637, 1900, }, -- Hibernate Rank 1
            {6808, 1900, req=6807}, -- Maul Rank 2
            {8938, 1900, req=8936}, -- Regrowth Rank 2
            {16857, 1900, }, -- Faerie Fire (Feral) 
        },
        [20] = {
            {768, 2000, }, -- Cat Form Shapeshift
            {1079, 2000, }, -- Rip Rank 1
            {1082, 2000, }, -- Claw Rank 1
            {1735, 2000, req=99}, -- Demoralizing Roar Rank 2
            {2912, 2000, }, -- Starfire Rank 1
            {5188, 2000, req=5187}, -- Healing Touch Rank 4
            {5215, 2000, }, -- Prowl 
            {6756, 2000, req=5232}, -- Mark of the Wild Rank 3
            {20484, 2000, }, -- Rebirth Rank 1
            {200, 10000, }, -- Polearms 
        },
        [22] = {
            {2090, 3000, req=1430}, -- Rejuvenation Rank 4
            {2908, 3000, }, -- Soothe Animal Rank 1
            {5179, 3000, req=5178}, -- Wrath Rank 4
            {5221, 3000, }, -- Shred Rank 1
            {8926, 3000, req=8925}, -- Moonfire Rank 4
        },
        [24] = {
            {780, 4000, req=779}, -- Swipe (Bear) Rank 2
            {1075, 4000, req=782}, -- Thorns Rank 3
            {1822, 4000, }, -- Rake Rank 1
            {2782, 4000, }, -- Remove Curse 
            {5217, 4000, }, -- Tiger's Fury Rank 1
            {8939, 4000, req=8938}, -- Regrowth Rank 3
            {50768, 4000, req=50769}, -- Revive Rank 2
        },
        [26] = {
            {1850, 4500, }, -- Dash Rank 1
            {2893, 4500, }, -- Abolish Poison 
            {5189, 4500, req=5188}, -- Healing Touch Rank 5
            {6809, 4500, req=6808}, -- Maul Rank 3
            {8949, 4500, req=2912}, -- Starfire Rank 2
        },
        [28] = {
            {16811, 250, req=16810}, -- Nature's Grasp Rank 3
            {2091, 5000, req=2090}, -- Rejuvenation Rank 5
            {3029, 5000, req=1082}, -- Claw Rank 2
            {5195, 5000, req=1062}, -- Entangling Roots Rank 3
            {5209, 5000, }, -- Challenging Roar 
            {8927, 5000, req=8926}, -- Moonfire Rank 5
            {8998, 5000, }, -- Cower Rank 1
            {9492, 5000, req=1079}, -- Rip Rank 2
        },
        [30] = {
            {24974, 300, req=5570}, -- Insect Swarm Rank 2
            {740, 6000, }, -- Tranquility Rank 1
            {5180, 6000, req=5179}, -- Wrath Rank 5
            {5234, 6000, req=6756}, -- Mark of the Wild Rank 4
            {6798, 6000, req=5211}, -- Bash Rank 2
            {6800, 6000, req=5221}, -- Shred Rank 2
            {8940, 6000, req=8939}, -- Regrowth Rank 4
            {20739, 6000, req=20484}, -- Rebirth Rank 2
        },
        [32] = {
            {5225, 8000, }, -- Track Humanoids 
            {6778, 8000, req=5189}, -- Healing Touch Rank 6
            {6785, 8000, }, -- Ravage Rank 1
            {9490, 8000, req=1735}, -- Demoralizing Roar Rank 3
            {22568, 8000, }, -- Ferocious Bite Rank 1
        },
        [34] = {
            {769, 10000, req=780}, -- Swipe (Bear) Rank 3
            {1823, 10000, req=1822}, -- Rake Rank 2
            {3627, 10000, req=2091}, -- Rejuvenation Rank 6
            {8914, 10000, req=1075}, -- Thorns Rank 4
            {8928, 10000, req=8927}, -- Moonfire Rank 6
            {8950, 10000, req=8949}, -- Starfire Rank 3
            {8972, 10000, req=6809}, -- Maul Rank 4
        },
        [36] = {
            {6793, 11000, req=5217}, -- Tiger's Fury Rank 2
            {8941, 11000, req=8940}, -- Regrowth Rank 5
            {9005, 11000, }, -- Pounce Rank 1
            {9493, 11000, req=9492}, -- Rip Rank 3
            {22842, 11000, }, -- Frenzied Regeneration 
            {50767, 11000, req=50768}, -- Revive Rank 3
        },
        [38] = {
            {16812, 600, req=16811}, -- Nature's Grasp Rank 4
            {5196, 12000, req=5195}, -- Entangling Roots Rank 4
            {5201, 12000, req=3029}, -- Claw Rank 3
            {6780, 12000, req=5180}, -- Wrath Rank 6
            {8903, 12000, req=6778}, -- Healing Touch Rank 7
            {8955, 12000, req=2908}, -- Soothe Animal Rank 2
            {8992, 12000, req=6800}, -- Shred Rank 3
            {18657, 12000, req=2637}, -- Hibernate Rank 2
        },
        [40] = {
            {24975, 700, req=24974}, -- Insect Swarm Rank 3
            {62600, 4500, }, -- Savage Defense Passive
            {8907, 14000, req=5234}, -- Mark of the Wild Rank 5
            {8910, 14000, req=3627}, -- Rejuvenation Rank 7
            {8918, 14000, req=740}, -- Tranquility Rank 2
            {8929, 14000, req=8928}, -- Moonfire Rank 7
            {9000, 14000, req=8998}, -- Cower Rank 2
            {9634, 14000, req=5487}, -- Dire Bear Form Shapeshift
            {16914, 14000, }, -- Hurricane Rank 1
            {20719, 14000, }, -- Feline Grace Passive
            {20742, 14000, req=20739}, -- Rebirth Rank 3
            {22827, 14000, req=22568}, -- Ferocious Bite Rank 2
            {29166, 14000, }, -- Innervate 
        },
        [42] = {
            {6787, 16000, req=6785}, -- Ravage Rank 2
            {8951, 16000, req=8950}, -- Starfire Rank 4
            {9745, 16000, req=8972}, -- Maul Rank 5
            {9747, 16000, req=9490}, -- Demoralizing Roar Rank 4
            {9750, 16000, req=8941}, -- Regrowth Rank 6
        },
        [44] = {
            {1824, 18000, req=1823}, -- Rake Rank 3
            {9752, 18000, req=9493}, -- Rip Rank 4
            {9754, 18000, req=769}, -- Swipe (Bear) Rank 4
            {9756, 18000, req=8914}, -- Thorns Rank 5
            {9758, 18000, req=8903}, -- Healing Touch Rank 8
            {22812, 18000, }, -- Barkskin 
        },
        [46] = {
            {8905, 20000, req=6780}, -- Wrath Rank 7
            {8983, 20000, req=6798}, -- Bash Rank 3
            {9821, 20000, req=1850}, -- Dash Rank 2
            {9823, 20000, req=9005}, -- Pounce Rank 2
            {9829, 20000, req=8992}, -- Shred Rank 4
            {9833, 20000, req=8929}, -- Moonfire Rank 8
            {9839, 20000, req=8910}, -- Rejuvenation Rank 8
        },
        [48] = {
            {16813, 1100, req=16812}, -- Nature's Grasp Rank 5
            {9845, 22000, req=6793}, -- Tiger's Fury Rank 3
            {9849, 22000, req=5201}, -- Claw Rank 4
            {9852, 22000, req=5196}, -- Entangling Roots Rank 5
            {9856, 22000, req=9750}, -- Regrowth Rank 7
            {22828, 22000, req=22827}, -- Ferocious Bite Rank 3
            {50766, 22000, req=50767}, -- Revive Rank 4
        },
        [50] = {
            {24976, 1150, req=24975}, -- Insect Swarm Rank 4
            {9862, 23000, req=8918}, -- Tranquility Rank 3
            {9866, 23000, req=6787}, -- Ravage Rank 3
            {9875, 23000, req=8951}, -- Starfire Rank 5
            {9880, 23000, req=9745}, -- Maul Rank 6
            {9884, 23000, req=8907}, -- Mark of the Wild Rank 6
            {9888, 23000, req=9758}, -- Healing Touch Rank 9
            {17401, 23000, req=16914}, -- Hurricane Rank 2
            {20747, 23000, req=20742}, -- Rebirth Rank 4
            {21849, 23000, }, -- Gift of the Wild Rank 1
        },
        [52] = {
            {9834, 26000, req=9833}, -- Moonfire Rank 9
            {9840, 26000, req=9839}, -- Rejuvenation Rank 9
            {9892, 26000, req=9000}, -- Cower Rank 3
            {9894, 26000, req=9752}, -- Rip Rank 5
            {9898, 26000, req=9747}, -- Demoralizing Roar Rank 5
        },
        [54] = {
            {9830, 28000, req=9829}, -- Shred Rank 5
            {9857, 28000, req=9856}, -- Regrowth Rank 8
            {9901, 28000, req=8955}, -- Soothe Animal Rank 3
            {9904, 28000, req=1824}, -- Rake Rank 4
            {9908, 28000, req=9754}, -- Swipe (Bear) Rank 5
            {9910, 28000, req=9756}, -- Thorns Rank 6
            {9912, 28000, req=8905}, -- Wrath Rank 8
        },
        [56] = {
            {9827, 30000, req=9823}, -- Pounce Rank 3
            {9889, 30000, req=9888}, -- Healing Touch Rank 10
            {22829, 30000, req=22828}, -- Ferocious Bite Rank 4
        },
        [58] = {
            {17329, 1600, req=16813}, -- Nature's Grasp Rank 6
            {33982, 1700, req=33917}, -- Mangle (Cat) Rank 2
            {33986, 1700, req=33917}, -- Mangle (Bear) Rank 2
            {9835, 32000, req=9834}, -- Moonfire Rank 10
            {9841, 32000, req=9840}, -- Rejuvenation Rank 10
            {9850, 32000, req=9849}, -- Claw Rank 5
            {9853, 32000, req=9852}, -- Entangling Roots Rank 6
            {9867, 32000, req=9866}, -- Ravage Rank 4
            {9876, 32000, req=9875}, -- Starfire Rank 6
            {9881, 32000, req=9880}, -- Maul Rank 7
            {18658, 32000, req=18657}, -- Hibernate Rank 3
        },
        [60] = {
            {53223, 600, req=50516}, -- Typhoon Rank 2
            {24977, 1700, req=24976}, -- Insect Swarm Rank 5
            {31018, 30000, req=22829}, -- Ferocious Bite Rank 5
            {9846, 34000, req=9845}, -- Tiger's Fury Rank 4
            {9858, 34000, req=9857}, -- Regrowth Rank 9
            {9863, 34000, req=9862}, -- Tranquility Rank 4
            {9885, 34000, req=9884}, -- Mark of the Wild Rank 7
            {9896, 34000, req=9894}, -- Rip Rank 6
            {17402, 34000, req=17401}, -- Hurricane Rank 3
            {20748, 34000, req=20747}, -- Rebirth Rank 5
            {21850, 34000, req=21849}, -- Gift of the Wild Rank 2
            {25297, 34000, req=9889}, -- Healing Touch Rank 11
            {25298, 34000, req=9876}, -- Starfire Rank 7
            {25299, 34000, req=9841}, -- Rejuvenation Rank 11
            {31709, 34000, req=9892}, -- Cower Rank 4
            {50765, 34000, req=50766}, -- Revive Rank 5
        },
        [61] = {
            {26984, 39000, req=9912}, -- Wrath Rank 9
            {27001, 39000, req=9830}, -- Shred Rank 6
        },
        [62] = {
            {22570, 43000, }, -- Maim Rank 1
            {26978, 43000, req=25297}, -- Healing Touch Rank 12
            {26998, 43000, req=9898}, -- Demoralizing Roar Rank 6
        },
        [63] = {
            {24248, 48000, req=31018}, -- Ferocious Bite Rank 6
            {26981, 48000, req=25299}, -- Rejuvenation Rank 12
            {26987, 48000, req=9835}, -- Moonfire Rank 11
        },
        [64] = {
            {26992, 53000, req=9910}, -- Thorns Rank 7
            {26997, 53000, req=9908}, -- Swipe (Bear) Rank 6
            {27003, 53000, req=9904}, -- Rake Rank 5
            {33763, 53000, }, -- Lifebloom Rank 1
        },
        [65] = {
            {26980, 59000, req=9858}, -- Regrowth Rank 10
            {33357, 59000, req=9821}, -- Dash Rank 3
        },
        [66] = {
            {27005, 66000, req=9867}, -- Ravage Rank 5
            {27006, 66000, req=9827}, -- Pounce Rank 4
            {33745, 66000, }, -- Lacerate Rank 1
        },
        [67] = {
            {26986, 73000, req=25298}, -- Starfire Rank 8
            {26996, 73000, req=9881}, -- Maul Rank 8
            {27000, 73000, req=9850}, -- Claw Rank 6
            {27008, 73000, req=9896}, -- Rip Rank 7
        },
        [68] = {
            {27009, 1700, req=17329}, -- Nature's Grasp Rank 7
            {33983, 1700, req=33982}, -- Mangle (Cat) Rank 3
            {33987, 1900, req=33986}, -- Mangle (Bear) Rank 3
            {26989, 81000, req=9853}, -- Entangling Roots Rank 7
        },
        [69] = {
            {26979, 90000, req=26978}, -- Healing Touch Rank 13
            {26982, 90000, req=26981}, -- Rejuvenation Rank 13
            {26985, 90000, req=26984}, -- Wrath Rank 10
            {26994, 90000, req=20748}, -- Rebirth Rank 6
            {27004, 90000, req=31709}, -- Cower Rank 5
            {50764, 90000, req=50765}, -- Revive Rank 6
        },
        [70] = {
            {53225, 1700, req=53223}, -- Typhoon Rank 3
            {53248, 1700, req=48438}, -- Wild Growth Rank 2
            {27013, 2500, req=24977}, -- Insect Swarm Rank 6
            {53199, 10000, req=48505}, -- Starfall Rank 2
            {26983, 100000, req=9863}, -- Tranquility Rank 5
            {26988, 100000, req=26987}, -- Moonfire Rank 12
            {26990, 100000, req=9885}, -- Mark of the Wild Rank 8
            {26991, 100000, req=21850}, -- Gift of the Wild Rank 3
            {26995, 100000, req=9901}, -- Soothe Animal Rank 4
            {27002, 100000, req=27001}, -- Shred Rank 7
            {27012, 100000, req=17402}, -- Hurricane Rank 4
            {33786, 100000, }, -- Cyclone 
        },
        [71] = {
            {40120, 200000, req=33943}, -- Swift Flight Form Shapeshift
            {48442, 200000, req=26980}, -- Regrowth Rank 11
            {48559, 200000, req=26998}, -- Demoralizing Roar Rank 7
            {49799, 200000, req=27008}, -- Rip Rank 8
            {50212, 200000, req=9846}, -- Tiger's Fury Rank 5
            {62078, 200000, }, -- Swipe (Cat) Rank 1
        },
        [72] = {
            {48450, 200000, req=33763}, -- Lifebloom Rank 2
            {48464, 200000, req=26986}, -- Starfire Rank 9
            {48561, 200000, req=26997}, -- Swipe (Bear) Rank 7
            {48573, 200000, req=27003}, -- Rake Rank 6
            {48576, 200000, req=24248}, -- Ferocious Bite Rank 7
        },
        [73] = {
            {48479, 200000, req=26996}, -- Maul Rank 9
            {48567, 200000, req=33745}, -- Lacerate Rank 2
            {48569, 200000, req=27000}, -- Claw Rank 7
            {48578, 200000, req=27005}, -- Ravage Rank 6
        },
        [74] = {
            {48377, 200000, req=26979}, -- Healing Touch Rank 14
            {48459, 200000, req=26985}, -- Wrath Rank 11
            {49802, 200000, req=22570}, -- Maim Rank 2
            {53307, 200000, req=26992}, -- Thorns Rank 8
        },
        [75] = {
            {48563, 10000, req=33987}, -- Mangle (Bear) Rank 4
            {48565, 10000, req=33983}, -- Mangle (Cat) Rank 4
            {53200, 10000, req=53199}, -- Starfall Rank 3
            {53226, 10000, req=53225}, -- Typhoon Rank 4
            {53249, 10000, req=53248}, -- Wild Growth Rank 3
            {48440, 200000, req=26982}, -- Rejuvenation Rank 14
            {48446, 200000, req=26983}, -- Tranquility Rank 6
            {48462, 200000, req=26988}, -- Moonfire Rank 13
            {48571, 200000, req=27002}, -- Shred Rank 8
            {52610, 200000, }, -- Savage Roar Rank 1
        },
        [76] = {
            {48575, 200000, req=27004}, -- Cower Rank 6
        },
        [77] = {
            {48443, 200000, req=48442}, -- Regrowth Rank 12
            {48560, 200000, req=48559}, -- Demoralizing Roar Rank 8
            {48562, 200000, req=48561}, -- Swipe (Bear) Rank 8
            {49803, 200000, req=27006}, -- Pounce Rank 5
        },
        [78] = {
            {48465, 200000, req=48464}, -- Starfire Rank 10
            {48574, 200000, req=48573}, -- Rake Rank 7
            {48577, 200000, req=48576}, -- Ferocious Bite Rank 8
            {53308, 200000, req=26989}, -- Entangling Roots Rank 8
            {53312, 200000, req=27009}, -- Nature's Grasp Rank 8
        },
        [79] = {
            {48378, 200000, req=48377}, -- Healing Touch Rank 15
            {48461, 200000, req=48459}, -- Wrath Rank 12
            {48477, 200000, req=26994}, -- Rebirth Rank 7
            {48480, 200000, req=48479}, -- Maul Rank 10
            {48570, 200000, req=48569}, -- Claw Rank 8
            {48579, 200000, req=48578}, -- Ravage Rank 7
            {50213, 200000, req=50212}, -- Tiger's Fury Rank 6
        },
        [80] = {
            {48564, 10000, req=48563}, -- Mangle (Bear) Rank 5
            {48566, 10000, req=48565}, -- Mangle (Cat) Rank 5
            {53201, 10000, req=53200}, -- Starfall Rank 4
            {53251, 10000, req=53249}, -- Wild Growth Rank 4
            {61384, 10000, req=53226}, -- Typhoon Rank 5
            {48441, 200000, req=48440}, -- Rejuvenation Rank 15
            {48447, 200000, req=48446}, -- Tranquility Rank 7
            {48451, 200000, req=48450}, -- Lifebloom Rank 3
            {48463, 200000, req=48462}, -- Moonfire Rank 14
            {48467, 200000, req=27012}, -- Hurricane Rank 5
            {48468, 200000, req=27013}, -- Insect Swarm Rank 7
            {48469, 200000, req=26990}, -- Mark of the Wild Rank 9
            {48470, 200000, req=26991}, -- Gift of the Wild Rank 4
            {48568, 200000, req=48567}, -- Lacerate Rank 3
            {48572, 200000, req=48571}, -- Shred Rank 9
            {49800, 200000, req=49799}, -- Rip Rank 9
            {50464, 200000, }, -- Nourish Rank 1
            {50763, 200000, req=50764}, -- Revive Rank 7
        },
    },
    ROGUE = {
        [0] = {
            {196, 1000, }, -- One-Handed Axes 
            {198, 1000, }, -- One-Handed Maces 
            {201, 1000, }, -- One-Handed Swords 
            {264, 1000, }, -- Bows 
            {266, 1000, }, -- Guns 
            {1180, 1000, }, -- Daggers 
            {5011, 1000, }, -- Crossbows 
            {15590, 1000, }, -- Fist Weapons 
        },
        [1] = {
            {1784, 10, }, -- Stealth 
        },
        [4] = {
            {53, 100, }, -- Backstab Rank 1
            {921, 100, }, -- Pick Pocket 
        },
        [6] = {
            {1757, 100, req=1752}, -- Sinister Strike Rank 2
            {1776, 100, }, -- Gouge 
        },
        [8] = {
            {5277, 200, }, -- Evasion Rank 1
            {6760, 200, req=2098}, -- Eviscerate Rank 2
        },
        [10] = {
            {674, 300, }, -- Dual Wield Passive
            {2983, 300, }, -- Sprint Rank 1
            {5171, 300, }, -- Slice and Dice Rank 1
            {6770, 300, }, -- Sap Rank 1
        },
        [12] = {
            {1766, 800, }, -- Kick 
            {2589, 800, req=53}, -- Backstab Rank 2
            {3127, 800, }, -- Parry Passive
        },
        [14] = {
            {703, 1200, }, -- Garrote Rank 1
            {1758, 1200, req=1757}, -- Sinister Strike Rank 3
            {8647, 1200, }, -- Expose Armor 
        },
        [16] = {
            {1804, 1800, }, -- Pick Lock 
            {1966, 1800, }, -- Feint Rank 1
            {6761, 1800, req=6760}, -- Eviscerate Rank 3
        },
        [18] = {
            {8676, 2900, }, -- Ambush Rank 1
        },
        [20] = {
            {1943, 3000, }, -- Rupture Rank 1
            {2590, 3000, req=2589}, -- Backstab Rank 3
            {51722, 3000, }, -- Dismantle 
        },
        [22] = {
            {1725, 4000, }, -- Distract 
            {1759, 4000, req=1758}, -- Sinister Strike Rank 4
            {1856, 4000, }, -- Vanish Rank 1
            {8631, 4000, req=703}, -- Garrote Rank 2
        },
        [24] = {
            {2836, 5000, }, -- Detect Traps Passive
            {6762, 5000, req=6761}, -- Eviscerate Rank 4
        },
        [26] = {
            {1833, 6000, }, -- Cheap Shot 
            {8724, 6000, req=8676}, -- Ambush Rank 2
        },
        [28] = {
            {2070, 8000, req=6770}, -- Sap Rank 2
            {2591, 8000, req=2590}, -- Backstab Rank 4
            {6768, 8000, req=1966}, -- Feint Rank 2
            {8639, 8000, req=1943}, -- Rupture Rank 2
        },
        [30] = {
            {408, 10000, }, -- Kidney Shot Rank 1
            {1760, 10000, req=1759}, -- Sinister Strike Rank 5
            {1842, 10000, }, -- Disarm Trap 
            {8632, 10000, req=8631}, -- Garrote Rank 3
        },
        [32] = {
            {8623, 12000, req=6762}, -- Eviscerate Rank 5
        },
        [34] = {
            {2094, 14000, }, -- Blind 
            {8696, 14000, req=2983}, -- Sprint Rank 2
            {8725, 14000, req=8724}, -- Ambush Rank 3
        },
        [36] = {
            {8640, 16000, req=8639}, -- Rupture Rank 3
            {8721, 16000, req=2591}, -- Backstab Rank 5
        },
        [38] = {
            {8621, 18000, req=1760}, -- Sinister Strike Rank 6
            {8633, 18000, req=8632}, -- Garrote Rank 4
        },
        [40] = {
            {1860, 20000, }, -- Safe Fall Passive
            {8624, 20000, req=8623}, -- Eviscerate Rank 6
            {8637, 20000, req=6768}, -- Feint Rank 3
        },
        [42] = {
            {1857, 27000, req=1856}, -- Vanish Rank 2
            {6774, 27000, req=5171}, -- Slice and Dice Rank 2
            {11267, 27000, req=8725}, -- Ambush Rank 4
        },
        [44] = {
            {11273, 29000, req=8640}, -- Rupture Rank 4
            {11279, 29000, req=8721}, -- Backstab Rank 6
        },
        [46] = {
            {17347, 7750, req=16511}, -- Hemorrhage Rank 2
            {11289, 31000, req=8633}, -- Garrote Rank 5
            {11293, 31000, req=8621}, -- Sinister Strike Rank 7
        },
        [48] = {
            {11297, 33000, req=2070}, -- Sap Rank 3
            {11299, 33000, req=8624}, -- Eviscerate Rank 7
        },
        [50] = {
            {34411, 5500, req=1329}, -- Mutilate Rank 2
            {8643, 35000, req=408}, -- Kidney Shot Rank 2
            {11268, 35000, req=11267}, -- Ambush Rank 5
            {26669, 35000, req=5277}, -- Evasion Rank 2
        },
        [52] = {
            {11274, 46000, req=11273}, -- Rupture Rank 5
            {11280, 46000, req=11279}, -- Backstab Rank 7
            {11303, 46000, req=8637}, -- Feint Rank 4
        },
        [54] = {
            {11290, 48000, req=11289}, -- Garrote Rank 6
            {11294, 48000, req=11293}, -- Sinister Strike Rank 8
        },
        [56] = {
            {11300, 50000, req=11299}, -- Eviscerate Rank 8
        },
        [58] = {
            {17348, 13000, req=17347}, -- Hemorrhage Rank 3
            {11269, 52000, req=11268}, -- Ambush Rank 6
            {11305, 52000, req=8696}, -- Sprint Rank 3
        },
        [60] = {
            {34412, 6500, req=34411}, -- Mutilate Rank 3
            {25302, 50000, req=11303}, -- Feint Rank 5
            {11275, 54000, req=11274}, -- Rupture Rank 6
            {11281, 54000, req=11280}, -- Backstab Rank 8
            {25300, 54000, req=11281}, -- Backstab Rank 9
            {31016, 65000, req=11300}, -- Eviscerate Rank 9
        },
        [61] = {
            {26839, 50000, req=11290}, -- Garrote Rank 7
        },
        [62] = {
            {26861, 50000, req=11294}, -- Sinister Strike Rank 9
            {26889, 59000, req=1857}, -- Vanish Rank 3
            {32645, 59000, }, -- Envenom Rank 1
        },
        [64] = {
            {26679, 72000, }, -- Deadly Throw Rank 1
            {27448, 72000, req=25302}, -- Feint Rank 6
            {26865, 140000, req=31016}, -- Eviscerate Rank 10
        },
        [66] = {
            {27441, 80000, req=11269}, -- Ambush Rank 7
            {31224, 89000, }, -- Cloak of Shadows 
        },
        [68] = {
            {26863, 110000, req=25300}, -- Backstab Rank 10
            {26867, 120000, req=11275}, -- Rupture Rank 7
        },
        [69] = {
            {32684, 120000, req=32645}, -- Envenom Rank 2
        },
        [70] = {
            {26864, 2700, req=17348}, -- Hemorrhage Rank 4
            {34413, 7500, req=34412}, -- Mutilate Rank 4
            {48673, 100000, req=26679}, -- Deadly Throw Rank 2
            {5938, 140000, }, -- Shiv 
            {26862, 140000, req=26861}, -- Sinister Strike Rank 10
            {26884, 140000, req=26839}, -- Garrote Rank 8
            {48689, 140000, req=27441}, -- Ambush Rank 8
        },
        [71] = {
            {51724, 300000, req=11297}, -- Sap Rank 4
        },
        [72] = {
            {48658, 300000, req=27448}, -- Feint Rank 7
        },
        [73] = {
            {48667, 300000, req=26865}, -- Eviscerate Rank 11
        },
        [74] = {
            {48656, 300000, req=26863}, -- Backstab Rank 11
            {48671, 300000, req=26867}, -- Rupture Rank 8
            {57992, 300000, req=32684}, -- Envenom Rank 3
        },
        [75] = {
            {48663, 15000, req=34413}, -- Mutilate Rank 5
            {48675, 300000, req=26884}, -- Garrote Rank 9
            {48690, 300000, req=48689}, -- Ambush Rank 9
            {57934, 300000, }, -- Tricks of the Trade 
        },
        [76] = {
            {48637, 300000, req=26862}, -- Sinister Strike Rank 11
            {48674, 300000, req=48673}, -- Deadly Throw Rank 3
        },
        [78] = {
            {48659, 300000, req=48658}, -- Feint Rank 8
        },
        [79] = {
            {48668, 300000, req=48667}, -- Eviscerate Rank 12
            {48672, 300000, req=48671}, -- Rupture Rank 9
        },
        [80] = {
            {48660, 15000, req=26864}, -- Hemorrhage Rank 5
            {48666, 15000, req=48663}, -- Mutilate Rank 6
            {48638, 300000, req=48637}, -- Sinister Strike Rank 12
            {48657, 300000, req=48656}, -- Backstab Rank 12
            {48676, 300000, req=48675}, -- Garrote Rank 10
            {48691, 300000, req=48690}, -- Ambush Rank 10
            {51723, 300000, }, -- Fan of Knives 
            {57993, 300000, req=57992}, -- Envenom Rank 4
        },
    },
    SHAMAN = {
        [0] = {
            {196, 1000, }, -- One-Handed Axes 
            {197, 1000, }, -- Two-Handed Axes 
            {198, 1000, }, -- One-Handed Maces 
            {199, 1000, }, -- Two-Handed Maces 
            {227, 1000, }, -- Staves 
            {1180, 1000, }, -- Daggers 
            {15590, 1000, }, -- Fist Weapons 
        },
        [1] = {
            {8017, 10, }, -- Rockbiter Weapon Rank 1
        },
        [4] = {
            {8042, 100, }, -- Earth Shock Rank 1
        },
        [6] = {
            {332, 100, req=331}, -- Healing Wave Rank 2
            {2484, 100, }, -- Earthbind Totem 
        },
        [8] = {
            {324, 100, }, -- Lightning Shield Rank 1
            {529, 100, req=403}, -- Lightning Bolt Rank 2
            {5730, 100, }, -- Stoneclaw Totem Rank 1
            {8018, 100, req=8017}, -- Rockbiter Weapon Rank 2
            {8044, 100, req=8042}, -- Earth Shock Rank 2
        },
        [10] = {
            {8024, 400, }, -- Flametongue Weapon Rank 1
            {8050, 400, }, -- Flame Shock Rank 1
            {8075, 400, }, -- Strength of Earth Totem Rank 1
        },
        [12] = {
            {370, 800, }, -- Purge Rank 1
            {547, 800, req=332}, -- Healing Wave Rank 3
            {1535, 800, }, -- Fire Nova Rank 1
            {2008, 800, }, -- Ancestral Spirit Rank 1
        },
        [14] = {
            {548, 900, req=529}, -- Lightning Bolt Rank 3
            {8045, 900, req=8044}, -- Earth Shock Rank 3
            {8154, 900, req=8071}, -- Stoneskin Totem Rank 2
        },
        [16] = {
            {325, 1800, req=324}, -- Lightning Shield Rank 2
            {526, 1800, }, -- Cure Toxins 
            {8019, 1800, req=8018}, -- Rockbiter Weapon Rank 3
            {2645, 2200, }, -- Ghost Wolf 
            {57994, 2500, }, -- Wind Shear 
        },
        [18] = {
            {913, 2000, req=547}, -- Healing Wave Rank 4
            {6390, 2000, req=5730}, -- Stoneclaw Totem Rank 2
            {8027, 2000, req=8024}, -- Flametongue Weapon Rank 2
            {8052, 2000, req=8050}, -- Flame Shock Rank 2
            {8143, 2000, }, -- Tremor Totem 
        },
        [20] = {
            {915, 2200, req=548}, -- Lightning Bolt Rank 4
            {6363, 2200, req=3599}, -- Searing Totem Rank 2
            {8004, 2200, }, -- Lesser Healing Wave Rank 1
            {8033, 2200, }, -- Frostbrand Weapon Rank 1
            {8056, 2200, }, -- Frost Shock Rank 1
            {52127, 2200, }, -- Water Shield Rank 1
        },
        [22] = {
            {131, 3000, }, -- Water Breathing 
            {8498, 3000, req=1535}, -- Fire Nova Rank 2
        },
        [24] = {
            {905, 3500, req=325}, -- Lightning Shield Rank 3
            {939, 3500, req=913}, -- Healing Wave Rank 5
            {8046, 3500, req=8045}, -- Earth Shock Rank 4
            {8155, 3500, req=8154}, -- Stoneskin Totem Rank 3
            {8160, 3500, req=8075}, -- Strength of Earth Totem Rank 2
            {8181, 3500, }, -- Frost Resistance Totem Rank 1
            {10399, 3500, req=8019}, -- Rockbiter Weapon Rank 4
            {20609, 3500, req=2008}, -- Ancestral Spirit Rank 2
        },
        [26] = {
            {943, 4000, req=915}, -- Lightning Bolt Rank 5
            {5675, 4000, }, -- Mana Spring Totem Rank 1
            {6196, 4000, }, -- Far Sight 
            {8030, 4000, req=8027}, -- Flametongue Weapon Rank 3
            {8190, 4000, }, -- Magma Totem Rank 1
        },
        [28] = {
            {546, 6000, }, -- Water Walking 
            {6391, 6000, req=6390}, -- Stoneclaw Totem Rank 3
            {8008, 6000, req=8004}, -- Lesser Healing Wave Rank 2
            {8038, 6000, req=8033}, -- Frostbrand Weapon Rank 2
            {8053, 6000, req=8052}, -- Flame Shock Rank 3
            {8184, 6000, }, -- Fire Resistance Totem Rank 1
            {8227, 6000, }, -- Flametongue Totem Rank 1
            {52129, 6000, req=52127}, -- Water Shield Rank 2
        },
        [30] = {
            {556, 7000, }, -- Astral Recall 
            {6364, 7000, req=6363}, -- Searing Totem Rank 3
            {6375, 7000, req=5394}, -- Healing Stream Totem Rank 2
            {8177, 7000, }, -- Grounding Totem 
            {8232, 7000, }, -- Windfury Weapon Rank 1
            {10595, 7000, }, -- Nature Resistance Totem Rank 1
            {20608, 7000, }, -- Reincarnation Passive
            {36936, 7000, }, -- Totemic Recall 
            {51730, 7000, }, -- Earthliving Weapon Rank 1
        },
        [32] = {
            {421, 8000, }, -- Chain Lightning Rank 1
            {945, 8000, req=905}, -- Lightning Shield Rank 4
            {959, 8000, req=939}, -- Healing Wave Rank 6
            {6041, 8000, req=943}, -- Lightning Bolt Rank 6
            {8012, 8000, req=370}, -- Purge Rank 2
            {8499, 8000, req=8498}, -- Fire Nova Rank 3
            {8512, 8000, }, -- Windfury Totem 
        },
        [34] = {
            {6495, 9000, }, -- Sentry Totem 
            {8058, 9000, req=8056}, -- Frost Shock Rank 2
            {10406, 9000, req=8155}, -- Stoneskin Totem Rank 4
            {52131, 9000, req=52129}, -- Water Shield Rank 3
        },
        [36] = {
            {8010, 10000, req=8008}, -- Lesser Healing Wave Rank 3
            {10412, 10000, req=8046}, -- Earth Shock Rank 5
            {10495, 10000, req=5675}, -- Mana Spring Totem Rank 2
            {10585, 10000, req=8190}, -- Magma Totem Rank 2
            {16339, 10000, req=8030}, -- Flametongue Weapon Rank 4
            {20610, 10000, req=20609}, -- Ancestral Spirit Rank 3
        },
        [38] = {
            {6392, 11000, req=6391}, -- Stoneclaw Totem Rank 4
            {8161, 11000, req=8160}, -- Strength of Earth Totem Rank 3
            {8170, 11000, }, -- Cleansing Totem 
            {8249, 11000, req=8227}, -- Flametongue Totem Rank 2
            {10391, 11000, req=6041}, -- Lightning Bolt Rank 7
            {10456, 11000, req=8038}, -- Frostbrand Weapon Rank 3
            {10478, 11000, req=8181}, -- Frost Resistance Totem Rank 2
        },
        [40] = {
            {930, 12000, req=421}, -- Chain Lightning Rank 2
            {1064, 12000, }, -- Chain Heal Rank 1
            {6365, 12000, req=6364}, -- Searing Totem Rank 4
            {6377, 12000, req=6375}, -- Healing Stream Totem Rank 3
            {8005, 12000, req=959}, -- Healing Wave Rank 7
            {8134, 12000, req=945}, -- Lightning Shield Rank 5
            {8235, 12000, req=8232}, -- Windfury Weapon Rank 2
            {8737, 12000, }, -- Mail 
            {10447, 12000, req=8053}, -- Flame Shock Rank 4
            {51988, 12000, req=51730}, -- Earthliving Weapon Rank 2
        },
        [41] = {
            {52134, 12000, req=52131}, -- Water Shield Rank 4
        },
        [42] = {
            {10537, 16000, req=8184}, -- Fire Resistance Totem Rank 2
            {11314, 16000, req=8499}, -- Fire Nova Rank 4
        },
        [44] = {
            {10392, 18000, req=10391}, -- Lightning Bolt Rank 8
            {10407, 18000, req=10406}, -- Stoneskin Totem Rank 5
            {10466, 18000, req=8010}, -- Lesser Healing Wave Rank 4
            {10600, 18000, req=10595}, -- Nature Resistance Totem Rank 2
        },
        [46] = {
            {10472, 20000, req=8058}, -- Frost Shock Rank 3
            {10496, 20000, req=10495}, -- Mana Spring Totem Rank 3
            {10586, 20000, req=10585}, -- Magma Totem Rank 3
            {10622, 20000, req=1064}, -- Chain Heal Rank 2
            {16341, 20000, req=16339}, -- Flametongue Weapon Rank 5
        },
        [48] = {
            {2860, 22000, req=930}, -- Chain Lightning Rank 3
            {10395, 22000, req=8005}, -- Healing Wave Rank 8
            {10413, 22000, req=10412}, -- Earth Shock Rank 6
            {10427, 22000, req=6392}, -- Stoneclaw Totem Rank 5
            {10431, 22000, req=8134}, -- Lightning Shield Rank 6
            {10526, 22000, req=8249}, -- Flametongue Totem Rank 3
            {16355, 22000, req=10456}, -- Frostbrand Weapon Rank 4
            {20776, 22000, req=20610}, -- Ancestral Spirit Rank 4
            {52136, 22000, req=52134}, -- Water Shield Rank 5
        },
        [50] = {
            {10437, 24000, req=6365}, -- Searing Totem Rank 5
            {10462, 24000, req=6377}, -- Healing Stream Totem Rank 4
            {10486, 24000, req=8235}, -- Windfury Weapon Rank 3
            {15207, 24000, req=10392}, -- Lightning Bolt Rank 9
            {51991, 24000, req=51988}, -- Earthliving Weapon Rank 3
        },
        [52] = {
            {10442, 27000, req=8161}, -- Strength of Earth Totem Rank 4
            {10448, 27000, req=10447}, -- Flame Shock Rank 5
            {10467, 27000, req=10466}, -- Lesser Healing Wave Rank 5
            {11315, 27000, req=11314}, -- Fire Nova Rank 5
        },
        [54] = {
            {10408, 29000, req=10407}, -- Stoneskin Totem Rank 6
            {10479, 29000, req=10478}, -- Frost Resistance Totem Rank 3
            {10623, 29000, req=10622}, -- Chain Heal Rank 3
        },
        [55] = {
            {52138, 29000, req=52136}, -- Water Shield Rank 6
        },
        [56] = {
            {10396, 30000, req=10395}, -- Healing Wave Rank 9
            {10432, 30000, req=10431}, -- Lightning Shield Rank 7
            {10497, 30000, req=10496}, -- Mana Spring Totem Rank 4
            {10587, 30000, req=10586}, -- Magma Totem Rank 4
            {10605, 30000, req=2860}, -- Chain Lightning Rank 4
            {15208, 30000, req=15207}, -- Lightning Bolt Rank 10
            {16342, 30000, req=16341}, -- Flametongue Weapon Rank 6
        },
        [58] = {
            {10428, 32000, req=10427}, -- Stoneclaw Totem Rank 6
            {10473, 32000, req=10472}, -- Frost Shock Rank 4
            {10538, 32000, req=10537}, -- Fire Resistance Totem Rank 3
            {16356, 32000, req=16355}, -- Frostbrand Weapon Rank 5
            {16387, 32000, req=10526}, -- Flametongue Totem Rank 4
        },
        [60] = {
            {32593, 1700, req=974}, -- Earth Shield Rank 2
            {57720, 3400, req=30706}, -- Totem of Wrath Rank 2
            {25357, 6500, req=10396}, -- Healing Wave Rank 10
            {10414, 34000, req=10413}, -- Earth Shock Rank 7
            {10438, 34000, req=10437}, -- Searing Totem Rank 6
            {10463, 34000, req=10462}, -- Healing Stream Totem Rank 5
            {10468, 34000, req=10467}, -- Lesser Healing Wave Rank 6
            {10601, 34000, req=10600}, -- Nature Resistance Totem Rank 3
            {16362, 34000, req=10486}, -- Windfury Weapon Rank 4
            {20777, 34000, req=20776}, -- Ancestral Spirit Rank 5
            {25361, 34000, req=10442}, -- Strength of Earth Totem Rank 5
            {51992, 34000, req=51991}, -- Earthliving Weapon Rank 4
            {29228, 65000, req=10448}, -- Flame Shock Rank 6
        },
        [61] = {
            {25422, 34000, req=10623}, -- Chain Heal Rank 4
            {25546, 34000, req=11315}, -- Fire Nova Rank 6
        },
        [62] = {
            {24398, 38000, req=52138}, -- Water Shield Rank 7
            {25448, 38000, req=15208}, -- Lightning Bolt Rank 11
        },
        [63] = {
            {25391, 42000, req=25357}, -- Healing Wave Rank 11
            {25439, 42000, req=10605}, -- Chain Lightning Rank 5
            {25469, 42000, req=10432}, -- Lightning Shield Rank 8
            {25508, 42000, req=10408}, -- Stoneskin Totem Rank 7
        },
        [64] = {
            {3738, 47000, }, -- Wrath of Air Totem 
            {25489, 47000, req=16342}, -- Flametongue Weapon Rank 7
        },
        [65] = {
            {25528, 52000, req=25361}, -- Strength of Earth Totem Rank 6
            {25552, 52000, req=10587}, -- Magma Totem Rank 5
            {25570, 52000, req=10497}, -- Mana Spring Totem Rank 5
        },
        [66] = {
            {2062, 58000, }, -- Earth Elemental Totem 
            {25420, 58000, req=10468}, -- Lesser Healing Wave Rank 7
            {25500, 58000, req=16356}, -- Frostbrand Weapon Rank 6
        },
        [67] = {
            {25449, 64000, req=25448}, -- Lightning Bolt Rank 12
            {25525, 64000, req=10428}, -- Stoneclaw Totem Rank 7
            {25557, 64000, req=16387}, -- Flametongue Totem Rank 5
            {25560, 64000, req=10479}, -- Frost Resistance Totem Rank 4
        },
        [68] = {
            {2894, 71000, }, -- Fire Elemental Totem 
            {25423, 71000, req=25422}, -- Chain Heal Rank 5
            {25464, 71000, req=10473}, -- Frost Shock Rank 5
            {25505, 71000, req=16362}, -- Windfury Weapon Rank 5
            {25563, 71000, req=10538}, -- Fire Resistance Totem Rank 4
        },
        [69] = {
            {25454, 79000, req=10414}, -- Earth Shock Rank 8
            {25533, 79000, req=10438}, -- Searing Totem Rank 7
            {25567, 79000, req=10463}, -- Healing Stream Totem Rank 6
            {25574, 79000, req=10601}, -- Nature Resistance Totem Rank 4
            {25590, 79000, req=20777}, -- Ancestral Spirit Rank 6
            {33736, 79000, req=24398}, -- Water Shield Rank 8
        },
        [70] = {
            {32594, 2500, req=32593}, -- Earth Shield Rank 3
            {57721, 5200, req=57720}, -- Totem of Wrath Rank 3
            {61299, 9000, req=61295}, -- Riptide Rank 2
            {51993, 71000, req=51992}, -- Earthliving Weapon Rank 5
            {2825, 88000, faction="Horde"}, -- Bloodlust 
            {25396, 88000, req=25391}, -- Healing Wave Rank 12
            {25442, 88000, req=25439}, -- Chain Lightning Rank 6
            {25457, 88000, req=29228}, -- Flame Shock Rank 7
            {25472, 88000, req=25469}, -- Lightning Shield Rank 9
            {25509, 88000, req=25508}, -- Stoneskin Totem Rank 8
            {25547, 88000, req=25546}, -- Fire Nova Rank 7
            {32182, 88000, faction="Alliance"}, -- Heroism 
            {59156, 88000, req=51490}, -- Thunderstorm Rank 2
        },
        [71] = {
            {58580, 180000, req=25525}, -- Stoneclaw Totem Rank 8
            {58649, 180000, req=25557}, -- Flametongue Totem Rank 6
            {58699, 180000, req=25533}, -- Searing Totem Rank 8
            {58755, 180000, req=25567}, -- Healing Stream Totem Rank 7
            {58771, 180000, req=25570}, -- Mana Spring Totem Rank 6
            {58785, 180000, req=25489}, -- Flametongue Weapon Rank 8
            {58794, 180000, req=25500}, -- Frostbrand Weapon Rank 7
            {58801, 180000, req=25505}, -- Windfury Weapon Rank 6
        },
        [72] = {
            {49275, 180000, req=25420}, -- Lesser Healing Wave Rank 8
        },
        [73] = {
            {49235, 180000, req=25464}, -- Frost Shock Rank 6
            {49237, 180000, req=25449}, -- Lightning Bolt Rank 13
            {58731, 180000, req=25552}, -- Magma Totem Rank 6
            {58751, 180000, req=25509}, -- Stoneskin Totem Rank 9
        },
        [74] = {
            {49230, 180000, req=25454}, -- Earth Shock Rank 9
            {49270, 180000, req=25442}, -- Chain Lightning Rank 7
            {55458, 180000, req=25423}, -- Chain Heal Rank 6
        },
        [75] = {
            {49283, 9000, req=32594}, -- Earth Shield Rank 4
            {61300, 9000, req=61299}, -- Riptide Rank 3
            {49232, 180000, req=25457}, -- Flame Shock Rank 8
            {49272, 180000, req=25396}, -- Healing Wave Rank 13
            {49280, 180000, req=25472}, -- Lightning Shield Rank 10
            {51505, 180000, }, -- Lava Burst Rank 1
            {57622, 180000, req=25528}, -- Strength of Earth Totem Rank 7
            {58581, 180000, req=58580}, -- Stoneclaw Totem Rank 9
            {58652, 180000, req=58649}, -- Flametongue Totem Rank 7
            {58703, 180000, req=58699}, -- Searing Totem Rank 9
            {58737, 180000, req=25563}, -- Fire Resistance Totem Rank 5
            {58741, 180000, req=25560}, -- Frost Resistance Totem Rank 5
            {58746, 180000, req=25574}, -- Nature Resistance Totem Rank 5
            {59158, 180000, req=59156}, -- Thunderstorm Rank 3
            {61649, 180000, req=25547}, -- Fire Nova Rank 8
        },
        [76] = {
            {57960, 180000, req=33736}, -- Water Shield Rank 9
            {58756, 180000, req=58755}, -- Healing Stream Totem Rank 8
            {58773, 180000, req=58771}, -- Mana Spring Totem Rank 7
            {58789, 180000, req=58785}, -- Flametongue Weapon Rank 9
            {58795, 180000, req=58794}, -- Frostbrand Weapon Rank 8
            {58803, 180000, req=58801}, -- Windfury Weapon Rank 7
        },
        [77] = {
            {49276, 180000, req=49275}, -- Lesser Healing Wave Rank 9
        },
        [78] = {
            {49236, 180000, req=49235}, -- Frost Shock Rank 7
            {58582, 180000, req=58581}, -- Stoneclaw Totem Rank 10
            {58734, 180000, req=58731}, -- Magma Totem Rank 7
            {58753, 180000, req=58751}, -- Stoneskin Totem Rank 10
        },
        [79] = {
            {49231, 180000, req=49230}, -- Earth Shock Rank 10
            {49238, 180000, req=49237}, -- Lightning Bolt Rank 14
        },
        [80] = {
            {49284, 9000, req=49283}, -- Earth Shield Rank 5
            {61301, 9000, req=61300}, -- Riptide Rank 4
            {57722, 10000, req=57721}, -- Totem of Wrath Rank 4
            {49233, 180000, req=49232}, -- Flame Shock Rank 9
            {49271, 180000, req=49270}, -- Chain Lightning Rank 8
            {49273, 180000, req=49272}, -- Healing Wave Rank 14
            {49277, 180000, req=25590}, -- Ancestral Spirit Rank 7
            {49281, 180000, req=49280}, -- Lightning Shield Rank 11
            {51514, 180000, }, -- Hex 
            {51994, 180000, req=51993}, -- Earthliving Weapon Rank 6
            {55459, 180000, req=55458}, -- Chain Heal Rank 7
            {58643, 180000, req=57622}, -- Strength of Earth Totem Rank 8
            {58656, 180000, req=58652}, -- Flametongue Totem Rank 8
            {58704, 180000, req=58703}, -- Searing Totem Rank 10
            {58739, 180000, req=58737}, -- Fire Resistance Totem Rank 6
            {58745, 180000, req=58741}, -- Frost Resistance Totem Rank 6
            {58749, 180000, req=58746}, -- Nature Resistance Totem Rank 6
            {58757, 180000, req=58756}, -- Healing Stream Totem Rank 9
            {58774, 180000, req=58773}, -- Mana Spring Totem Rank 8
            {58790, 180000, req=58789}, -- Flametongue Weapon Rank 10
            {58796, 180000, req=58795}, -- Frostbrand Weapon Rank 9
            {58804, 180000, req=58803}, -- Windfury Weapon Rank 8
            {59159, 180000, req=59158}, -- Thunderstorm Rank 4
            {60043, 180000, req=51505}, -- Lava Burst Rank 2
            {61657, 180000, req=61649}, -- Fire Nova Rank 9
        },
    },
    DEATHKNIGHT = {
        [55] = {
            {53341, 55000, }, -- Rune of Cinderglacier (Checked 9/1/2022)
            {53343, 55000, }, -- Rune of Razorice  (Checked 9/1/2022)
        },
        [56] = {
            {46584, 5600, }, -- Raise Dead   (Checked 9/1/2022)
            {49998, 5600, }, -- Death Strike Rank 1  (Checked 9/1/2022)
            {50842, 5600, }, -- Pestilence   (Checked 9/1/2022)
        },
        [57] = {
            {47528, 5700, }, -- Mind Freeze 
            {48263, 5700, }, -- Frost Presence 
            {53342, 5700, }, -- Rune of Spellshattering 
            {54447, 5700, }, -- Rune of Spellbreaking 
        },
        [58] = {
            {45524, 5800, }, -- Chains of Ice 
            {48721, 5800, }, -- Blood Boil Rank 1
        },
        [59] = {
            {47476, 5900, }, -- Strangulate 
            {49926, 5900, req=45902}, -- Blood Strike Rank 2
            {55258, 5900, req=55050}, -- Heart Strike Rank 2
        },
        [60] = {
            {51325, 300, req=49158}, -- Corpse Explosion Rank 2
            {49917, 5800, req=45462}, -- Plague Strike Rank 2
            {43265, 6000, }, -- Death and Decay Rank 1
            {53331, 6000, }, -- Rune of Lichbane 
            {51416, 6200, req=49143}, -- Frost Strike Rank 2
        },
        [61] = {
            {49020, 61000, }, -- Obliterate Rank 1
            {49896, 61000, req=45477}, -- Icy Touch Rank 2
        },
        [62] = {
            {49892, 59000, req=47541}, -- Death Coil Rank 2
            {48792, 62000, }, -- Icebound Fortitude 
        },
        [63] = {
            {53323, 63000, }, -- Rune of Swordshattering 
            {49999, 65000, req=49998}, -- Death Strike Rank 2
            {54446, 68000, }, -- Rune of Swordbreaking 
        },
        [64] = {
            {55259, 3200, req=55258}, -- Heart Strike Rank 3
            {45529, 64000, }, -- Blood Tap 
            {49927, 64000, req=49926}, -- Blood Strike Rank 3
        },
        [65] = {
            {51417, 3250, req=51416}, -- Frost Strike Rank 3
            {49918, 65000, req=49917}, -- Plague Strike Rank 3
            {56222, 65000, }, -- Dark Command 
            {57330, 65000, }, -- Horn of Winter Rank 1
        },
        [66] = {
            {48743, 66000, }, -- Death Pact 
            {49939, 66000, req=48721}, -- Blood Boil Rank 2
        },
        [67] = {
            {55265, 18000, req=55090}, -- Scourge Strike Rank 2
            {49903, 67000, req=49896}, -- Icy Touch Rank 3
            {51423, 67000, req=49020}, -- Obliterate Rank 2
            {56815, 67000, }, -- Rune Strike 
            {49936, 68000, req=43265}, -- Death and Decay Rank 2
        },
        [68] = {
            {48707, 68000, }, -- Anti-Magic Shell 
            {49893, 68000, req=49892}, -- Death Coil Rank 3
        },
        [69] = {
            {55260, 3450, req=55259}, -- Heart Strike Rank 4
            {49928, 69000, req=49927}, -- Blood Strike Rank 4
        },
        [70] = {
            {51409, 3182, req=49184}, -- Howling Blast Rank 2
            {51326, 18000, req=51325}, -- Corpse Explosion Rank 3
            {51418, 18000, req=51417}, -- Frost Strike Rank 4
            {45463, 63000, req=49999}, -- Death Strike Rank 3
            {48265, 360000, }, -- Unholy Presence 
            {49919, 360000, req=49918}, -- Plague Strike Rank 4
            {53344, 360000, }, -- Rune of the Fallen Crusader 
        },
        [72] = {
            {49940, 360000, req=49939}, -- Blood Boil Rank 3
            {61999, 360000, }, -- Raise Ally 
            {62158, 360000, }, -- Rune of the Stoneskin Gargoyle 
            {70164, 360000, }, -- Rune of the Nerubian Carapace 
        },
        [73] = {
            {55270, 18000, req=55265}, -- Scourge Strike Rank 3
            {49904, 360000, req=49903}, -- Icy Touch Rank 4
            {49937, 360000, req=49936}, -- Death and Decay Rank 3
            {51424, 360000, req=51423}, -- Obliterate Rank 3
        },
        [74] = {
            {55261, 18000, req=55260}, -- Heart Strike Rank 5
            {49929, 360000, req=49928}, -- Blood Strike Rank 5
        },
        [75] = {
            {51327, 18000, req=51326}, -- Corpse Explosion Rank 4
            {51410, 18000, req=51409}, -- Howling Blast Rank 3
            {51419, 18000, req=51418}, -- Frost Strike Rank 5
            {47568, 360000, }, -- Empower Rune Weapon 
            {49920, 360000, req=49919}, -- Plague Strike Rank 5
            {49923, 360000, req=45463}, -- Death Strike Rank 4
            {57623, 360000, req=57330}, -- Horn of Winter Rank 2
        },
        [76] = {
            {49894, 360000, req=49893}, -- Death Coil Rank 4
        },
        [78] = {
            {49909, 360000, req=49904}, -- Icy Touch Rank 5
            {49941, 360000, req=49940}, -- Blood Boil Rank 4
        },
        [79] = {
            {55271, 18000, req=55270}, -- Scourge Strike Rank 4
            {51425, 360000, req=51424}, -- Obliterate Rank 4
        },
        [80] = {
            {51328, 18000, req=51327}, -- Corpse Explosion Rank 5
            {51411, 18000, req=51410}, -- Howling Blast Rank 4
            {55262, 18000, req=55261}, -- Heart Strike Rank 6
            {55268, 18000, req=51419}, -- Frost Strike Rank 6
            {42650, 360000, }, -- Army of the Dead 
            {49895, 360000, req=49894}, -- Death Coil Rank 5
            {49921, 360000, req=49920}, -- Plague Strike Rank 6
            {49924, 360000, req=49923}, -- Death Strike Rank 5
            {49930, 360000, req=49929}, -- Blood Strike Rank 6
            {49938, 360000, req=49937}, -- Death and Decay Rank 4
        },
    },
}