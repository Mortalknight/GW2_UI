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

local ARROW = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
-- the corner on the other end of an edge of the mover, along x or y
local OTHER_END = {
    x = {TOPLEFT = "TOPRIGHT", TOPRIGHT = "TOPLEFT", BOTTOMLEFT = "BOTTOMRIGHT", BOTTOMRIGHT = "BOTTOMLEFT"},
    y = {TOPLEFT = "BOTTOMLEFT", BOTTOMLEFT = "TOPLEFT", TOPRIGHT = "BOTTOMRIGHT", BOTTOMRIGHT = "TOPRIGHT"},
}

-- one long arrow along an edge of the mover, from the corner the auras grow from to the other end
local function PlaceArrow(arrow, mover, grow, axis)
    local x, y = grow.x, grow.y
    local endPoint = OTHER_END[axis][grow.point]
    local line, head = arrow.line, arrow.head
    line:ClearAllPoints()
    line:SetPoint(grow.point, mover, grow.point, 8 * x, 8 * y)
    head:ClearAllPoints()
    if axis == "x" then
        line:SetPoint(endPoint, mover, endPoint, -15 * x, 8 * y)
        line:SetHeight(2)
        head:SetPoint(endPoint, mover, endPoint, -3 * x, 3 * y)
        head:SetRotation(x > 0 and math.pi / 2 or -math.pi / 2)
    else
        line:SetPoint(endPoint, mover, endPoint, 8 * x, -15 * y)
        line:SetWidth(2)
        head:SetPoint(endPoint, mover, endPoint, 3 * x, -3 * y)
        head:SetRotation(y > 0 and math.pi or 0)
    end
end

-- in the move hud two long arrows from the corner of the mover the auras grow from: the bright one along a row or
-- column, the faint one the way the next row or column goes
function GW.UpdateAuraGrowArrows(header, grow)
    local mover = header.gwMover
    if not mover then return end
    local arrows = mover.gwGrowArrows
    if not arrows then
        arrows = {}
        for index, alpha in ipairs({0.9, 0.45}) do
            local line = mover:CreateTexture(nil, "OVERLAY")
            line:SetColorTexture(GW.Colors.FallbackWhite:GetRGB())
            line:SetAlpha(alpha)
            local head = mover:CreateTexture(nil, "OVERLAY")
            head:SetTexture(ARROW)
            head:SetSize(12, 12)
            head:SetAlpha(alpha)
            arrows[index] = {line = line, head = head}
        end
        mover.gwGrowArrows = arrows
    end
    PlaceArrow(arrows[1], mover, grow, grow.column and "y" or "x")
    PlaceArrow(arrows[2], mover, grow, grow.column and "x" or "y")
end
