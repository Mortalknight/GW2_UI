---@class GW2
local GW = select(2, ...)

-- player factors
-- sf: percent bigger(+) or smaller(-) from default size
-- x: right(+) or left(-) offset
-- z: up(+) or down(-) offset
-- f: percent change in facing toward cam(+) or away from cam(-)
local p_human_M = {['sf'] = -3.5, ['x'] = 15, ['z'] = 10}
local p_human_F = {['sf'] = -8, ['x'] = 15, ['z'] = 10}
local p_dwarf_F = {['sf'] = -13, ['x'] = 5, ['z'] = 6}
local p_gnome_M = {['sf'] = -29, ['x'] = 5, ['z'] = 10}
local p_gnome_F = {['sf'] = -29, ['x'] = 5, ['z'] = 18}
local p_night_elf_M = {['sf'] = 1, ['x'] = 5, ['z'] = 20}
local p_tauren_M = {['sf'] = 8, ['x'] = 10, ['z'] = 40}
local p_tauren_F = {['sf'] = 3, ['x'] = 0, ['z'] = 11}
local p_orc_F = {['sf'] = -1, ['x'] = 0, ['z'] = 15}
local p_troll_M = {['sf'] = -6.5, ['x'] = 0, ['z'] = 32}
local p_blood_elf_M = {['sf'] = -1, ['x'] = 10, ['z'] = 7}
local p_blood_elf_F = {['sf'] = -8.5, ['x'] = 0, ['z'] = 20}

GW.immersiveQuesting.playerScales = {
    -- old player models (pre revamp)
    [119940] = p_human_M, -- human male (old)
    [119563] = p_human_F, -- human female (old)
    [119159] = p_gnome_M, -- gnome male (old)
    [119063] = p_gnome_F, -- gnome female (old)
    [118355] = {['sf'] = -15, ['x'] = 5, ['z'] = 6}, -- dwarf male (old)
    [118135] = p_dwarf_F, -- dwarf female (old)
    [120791] = p_night_elf_M, -- night elf male (old)
    [120590] = {['sf'] = -2, ['x'] = 0, ['z'] = 15}, -- night elf female (old)
    [121768] = {['sf'] = -10, ['x'] = 0, ['z'] = 10}, -- undead male (old)
    [121608] = {['sf'] = -6, ['x'] = 0, ['z'] = 9}, -- undead female (old)
    [121287] = {['sf'] = -3, ['x'] = 0, ['z'] = 10}, -- orc male (old)
    [121087] = p_orc_F, -- orc female (old)
    [122560] = p_troll_M, -- troll male (old)
    [122414] ={['sf'] = 4, ['x'] = -5, ['z'] = 15}, -- troll female (old)
    [122055] = {['sf'] = 5, ['x'] = 10, ['z'] = 6}, -- taruen male (old)
    [121961] = p_tauren_F, -- tauren female (old)
    [117721] = {['sf'] = 9, ['x'] = -30, ['z'] = 7, ['f'] = 20}, -- draenei male (old)
    [117437] = {['sf'] = 4, ['x'] = -10, ['z'] = 10, ['f'] = 10}, -- draenei female (old)
    [117170] = p_blood_elf_M, -- blood elf male (old)
    [116921] = p_blood_elf_F, -- blood elf female (old)

    -- player models
    [1011653] = p_human_M, -- human male
    [1000764] = p_human_F, -- human female
    [900914] = p_gnome_M, -- gnome male
    [940356] = {['sf'] = -30, ['x'] = -5, ['z'] = 13}, -- gnome female
    [878772] = {['sf'] = -20, ['x'] = -5, ['z'] = 34}, -- dwarf male
    [950080] = {['sf'] = -14, ['x'] = 5, ['z'] = 5}, -- dwarf female
    [974343] = {['sf'] = 2, ['x'] = 5, ['z'] = 16}, -- night elf male
    [921844] = {['sf'] = -3, ['x'] = 0, ['z'] = 17}, -- night elf female
    [959310] = {['sf'] = -5, ['x'] = 0, ['z'] = 5}, -- undead male
    [997378] = {['sf'] = -4, ['x'] = 0, ['z'] = 13}, -- undead female
    [917116] = {['sf'] = -6, ['x'] = 10, ['z'] = 10}, -- hunched orc & mag'har orc male
    [1968587] = {['sf'] = 14, ['x'] = 30, ['z'] = -15, ['f'] = 10}, -- upright orc & mag'har orc male
    [949470] = {['sf'] = -3, ['x'] = 0, ['z'] = 14}, -- orc & mag'har orc female
    [1022938] = p_troll_M, -- troll male
    [1018060] = {['sf'] = -5, ['x'] = -5, ['z'] = 45}, -- troll female
    [968705] = {['sf'] = 10, ['x'] = 10, ['z'] = 32}, -- tauren male
    [986648] = p_tauren_F, -- tauren female
    [1005887] = {['sf'] = 12, ['x'] = -30, ['z'] = 10, ['f'] = 20}, -- draenei male
    [1022598] = {['sf'] = 8, ['x'] = -10, ['z'] = 8, ['f'] = 10}, -- draenei female
    [1100087] = {['sf'] = -1, ['x'] = 10, ['z'] = 3}, -- blood elf male
    [1100258] = p_blood_elf_F, -- blood elf female
    [307454] = GW.Retail and
        {['sf'] = -6, ['x'] = 0, ['z'] = 55} or -- worgen male
        {['sf'] = 5, ['x'] = -10, ['z'] = -20},  -- worgen male (old)
    [307453] = GW.Retail and
        {['sf'] = -8.5, ['x'] = 5, ['z'] = 55, ['f'] = -45} or -- worgen female
        {['sf'] = 24, ['x'] = 5, ['z'] = -9, ['f'] = -60},     -- worgen female (old)
    [119376] = {['sf'] = -24.5, ['x'] = 5, ['z'] = 32}, -- goblin male
    [119369] = {['sf'] = -26, ['x'] = 5, ['z'] = 25}, -- goblin female
    [535052] = {['sf'] = 16, ['x'] = 5, ['z'] = 6}, -- pandaren male
    [589715] = {['sf'] = -9, ['x'] = -10, ['z'] = 41}, -- pandaren female
    [1734034] = p_blood_elf_M, -- void elf male
    [1733758] = p_blood_elf_F, -- void elf female
    [1620605] = {['sf'] = -1, ['x'] = -30, ['z'] = 33, ['f'] = 20}, -- lightforged male
    [1593999] = {['sf'] = 3, ['x'] = -10, ['z'] = 21, ['f'] = 10}, -- lightforged female
    [1630218] = p_tauren_M, -- highmountain male
    [1630402] = p_tauren_F, -- highmountain female
    [1814471] = p_night_elf_M, -- nightborne male
    [1810676] = {['sf'] = -1, ['x'] = 0, ['z'] = 20}, -- nightborne female
    [2622502] = p_gnome_M, -- mechagnome male
    [2564806] = p_gnome_F, -- mechagnome female
    [1721003] = {['sf'] = 7, ['x'] = 0, ['z'] = 8}, -- kul tiran male
    [1886724] = {['sf'] = -5.5, ['x'] = -10, ['z'] = 37}, -- kul tiran female
    [1890765] = {['sf'] = -18, ['x'] = 5, ['z'] = 30}, -- dark iron male
    [1890763] = p_dwarf_F, -- dark iron female
    [1630447] = {['sf'] = 5, ['x'] = 10, ['z'] = 17, ['f'] = -30}, -- zandalari male
    [1662187] = {['sf'] = 0, ['x'] = -5, ['z'] = -2, ['f'] = -45}, -- zandalari female
    [1890761] = {['sf'] = -20, ['z'] = 20}, -- vulpera male
    [1890759] = {['sf'] = -26.5, ['z'] = 35}, -- vulpera female
    [4207724] = {['sf'] = -12, ['x'] = -50, ['z'] = 65}, -- dracthyr male & female
    [4395382] = p_blood_elf_M, -- dracthyr male visage
    [4220448] = p_human_F, -- dracthyr female visage
    [5548261] = {['sf'] = -12, ['x'] = -5, ['z'] = 35}, -- earthen male
    [5548259] = {['sf'] = -10, ['x'] = 5, ['z'] = 8}, -- earthen female
    [5422149] = {['sf'] = 6, ['x'] = 5, ['z'] = 15}, -- haranir male
    [5422147] = {['sf'] = 5, ['x'] = 5, ['z'] = 7}, -- haranir female
}
