---@class GW2
local GW = select(2, ...)

-- the tooltip corner that points into the screen, where the mover sits
local function GetMoverCorner(mover)
    local quadrant = GW.GetScreenQuadrant(mover)
    if quadrant == "TOPLEFT" or quadrant == "TOPRIGHT" or quadrant == "BOTTOMLEFT" then
        return quadrant
    end
    return quadrant == "LEFT" and "BOTTOMLEFT" or "BOTTOMRIGHT"
end

-- default anchored tooltips follow the cursor or sit at the mover
local function OnSetDefaultAnchor(tooltip, parent)
    if tooltip:IsForbidden() or tooltip:GetAnchorType() ~= "ANCHOR_NONE" then
        return
    end
    -- the classic clients lose the item comparison on default anchored tooltips
    if not GW.isModern then
        tooltip.supportsItemComparison = true
    end

    local settings = GW.settings.tooltip.anchor
    if parent and not parent:IsForbidden() then
        if settings.toCursor then
            tooltip:SetOwner(parent, settings.cursorType, settings.cursorOffsetX, settings.cursorOffsetY)
            return
        end
        tooltip:SetOwner(parent, "ANCHOR_NONE")
    end

    local mover = GameTooltip.gwMover
    local _, anchor = tooltip:GetPoint()
    if anchor == nil or anchor == mover or anchor == UIParent or anchor == GameTooltipDefaultContainer then
        local corner = GetMoverCorner(mover)
        tooltip:ClearAllPoints()
        tooltip:SetPoint(corner, mover, corner)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        GW.RegisterMovableFrame(GameTooltip, "Tooltip", "tooltip", "Blizzard", {230, 80}, nil)
        if GameTooltipDefaultContainer then
            GameTooltipDefaultContainer:GwKillEditMode()
        end
        hooksecurefunc("GameTooltip_SetDefaultAnchor", OnSetDefaultAnchor)
    end,
})
