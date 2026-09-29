---@class GW2
local GW = select(2, ...)

-- the grow direction settings of the player aura bars, shared by the modern and the classic ones:
-- the corner the icons grow from, where the debuffs sit below the buffs, the step of the next
-- icon (x, y) and whether icons fill columns instead of rows
local GROW_DIRECTIONS = {
    DOWNR = {point = "TOPLEFT", below = "BOTTOMLEFT", x = 1, y = -1},
    DOWN = {point = "TOPRIGHT", below = "BOTTOMRIGHT", x = -1, y = -1},
    UPR = {point = "BOTTOMLEFT", below = "TOPLEFT", x = 1, y = 1},
    UP = {point = "BOTTOMRIGHT", below = "TOPRIGHT", x = -1, y = 1},
    UPL_COLUMN = {point = "BOTTOMRIGHT", below = "TOPRIGHT", x = -1, y = 1, column = true},
    UPR_COLUMN = {point = "BOTTOMLEFT", below = "TOPLEFT", x = 1, y = 1, column = true},
    DOWNL_COLUMN = {point = "TOPRIGHT", below = "BOTTOMRIGHT", x = -1, y = -1, column = true},
    DOWNR_COLUMN = {point = "TOPLEFT", below = "BOTTOMLEFT", x = 1, y = -1, column = true},
}

function GW.GetAuraGrowDirection(setting)
    return GROW_DIRECTIONS[setting] or GROW_DIRECTIONS.DOWN
end
