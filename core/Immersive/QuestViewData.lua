local _, GW = ...

-- model scale factors for questview
local T = {
    [1980608] = 1.3, -- Ulfar
    [3762412] = 1.1, -- primus
    [950080] = 1.7, -- toddy whiskers, moira
    [3084654] = 0.79, -- big wrathion
    [4227968] = 0.79, -- big selistra
    [1249799] = 0.9, -- malfurion
    [4218359] = 2.0, -- chromie
    [1890759] = 1.8, -- selistra
    [4496906] = 0.7, -- big kalec
    [4498270] = 0.7, -- big dormu
    [4495214] = 0.7, -- big alexstrasza
    [1259122] = 0.7, -- big senegos
    [4216711] = 1.0, -- therazal
    [1890765] = 1.8, -- thaelin
    [4036647] = 1.6, --- huseng
    [4081379] = 1.6, -- tomul
    [4207724] = 1.4, -- vaskarn
    [4498203] = 1.65, -- emberthal
    [900914] = 2.0, -- wulferd
    [1022938] = 1.3, -- senegos
    [119376] = 1.7, -- blixrez
    [4416923] = 0.79, -- big ebyssian, big surigosa
    [917116] = 1.3, -- warchief's herald
    [1011653] = 1.3, -- hero's herald
    [4186587] = 1.6, -- rowie
    [878772] = 1.7, -- sully
    [3947971] = 2.0, -- nostwin
    [3950118] = 1.6, -- honeypelt
    [4575036] = 2.6, -- newsy
    [1890761] = 1.7, -- veeno
    [1135341] = 0.85, -- brogg
    [4183015] = 1.0, -- ignax
    [940356] = 1.9, -- sprocketspark
    [1261840] = 1.0, -- cenarius
    [5151105] = 0.75, -- big merithra
    [3024835] = 2.0, -- moonberry
    [5011146] = 1.6, -- amrymn
    [4278602] = 0.3, -- buri
    [5154480] = 0.95, -- dreamkin
    [4883916] = 2.49, -- Q'onzu
    [1120702] = 1.0, -- aviana
    [4492766] = 0.55, -- big vyranoth
    [1572377] = 0.8, -- locus walker
    [1000764] = 1.35, -- tess greymane
    [1817113] = 1.35, -- wolf genn
    [5353632] = 1.3, -- magni
    [5492980] = 1.5, -- moira
    [2168127] = 1.1, -- memory of a duke
    [3952870] = 1.1, -- thrall
    [1100258] = 1.35, -- liadrin
    [119369] = 1.8, -- izzy
    [1022598]= 1.15, -- zenata
    [959310] = 1.35, -- dalyngrigge
    [3730980] = 2.6, -- reese
    [5165026] = 2.6, -- squally
    [4066013] = 0.9, -- garz
    [5548261] = 1.4, -- baelgrim
    [5484812] = 1.35, -- brinthe
    [5548259] = 1.35, -- rannida
    [5339030] = 1.4, -- skitter
    [5767091] = 1.5, -- dagan
    [5482015] = 1.0, -- sum'latha
    [5221517] = 0.95, -- kish'nal
    [1886724] = 1.4, -- Dolena
    [5333438] = 2.6, -- spindle
    [5348707] = 0.8, -- anub'azal
}
GW.QUESTVIEW_MODEL_TWEAKS = T

-- NPC scale factors for questview (takes priority over model tweaks)
local N = {
    [197478] = 2.8, -- herald flaps
    [201648] = 0.79, -- big somnikus
}
GW.QUESTVIEW_NPC_TWEAKS = N

-- player scale factors for questview
local P = {
    [0] = 1.1, -- default
    [3] = 1.5, -- dwarf
    [4] = 1.05, -- night elf
    [6] = 1.0, -- tauren
    [7] = 1.5, -- gnome
    [8] = 1.05, -- troll
    [9] = 1.5, -- goblin
    [11] = 1.0, -- draenei
    [22] = 1.05, -- worgen
    [27] = 1.05, -- nightborne
    [28] = 1.0, -- highmountain
    [30] = 1.0, -- lightforged
    [31] = 1.05, -- zandalari
    [34] = 1.5, -- dark iron
    [35] = 1.5, -- vulpera
    [37] = 1.5, -- mechagnome
    [84] = 1.5, -- earthen
    [85] = 1.5, -- earthen
}
GW.QUESTVIEW_PLAYER_SCALES = P

-- background textures to use in questview frame for various map IDs
local M = {
    [627] = "Legion/dalaran",
    [896] = "BFA/drustvar",
    [1409] = "starter_isle",
    [1525] = "SL/revendreth",
    [1533] = "SL/bastion",
    [1543] = "SL/maw",
    [1565] = "SL/ardenweald",
    [1670] = "SL/oribos", [1671] = "SL/oribos", [1672] = "SL/oribos",
    [1961] = "SL/korthia",
    [1970] = "SL/zerethmortis",
    [2016] = "SL/tazavesh",
    [1978] = "DF/default",
    [2022] = "DF/waking_shore",
    [2133] = "DF/zaralek",
    [2248] = "TWW/isle_of_dorn",
    [2339] = "TWW/dornogal",
    [2214] = "TWW/ringing_deeps",
    [2215] = "TWW/hallowfall",
    [2255] = "TWW/azj_kahet",
}
GW.QUESTVIEW_MAP_BGS = M
