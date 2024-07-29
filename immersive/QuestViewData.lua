local _, GW = ...

-- model scale factors for questview
local T = {
    [1980608] = 1.2, -- Ulfar
    [3762412] = 1.0, -- primus
    [4423740] = 1.5, -- herald flaps
    [950080] = 1.4, -- toddy whiskers, moira
    [3084654] = 0.69, -- big wrathion
    [4227968] = 0.69, -- big selistra
    [1249799] = 0.71, -- malfurion
    [4218359] = 1.7, -- chromie
    [1890759] = 1.5, -- selistra
    [4496906] = 0.6, -- big kalec
    [4498270] = 0.6, -- big dormu
    [4495214] = 0.6, -- big alexstrasza
    [921844] = 1.05, -- shandris
    [4216711] = 0.9, -- therazal
    [1890765] = 1.4, -- thaelin
}
GW.QUESTVIEW_MODEL_TWEAKS = T

-- NPC scale factors for questview (takes priority over model tweaks)
local N = {
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
}
GW.QUESTVIEW_MAP_BGS = M
