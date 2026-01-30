local _, GW = ...

local effectiveHeight

function GW.UpdateMinimapSize()
    local size = GW.settings.MINIMAP_SIZE
    local scale = GW.settings.MinimapScale

    Minimap:SetSize(size, size)
    Minimap:SetScale(scale)
    Minimap.gwMover:SetScale(scale)

    Minimap:ClearAllPoints()
    Minimap.location:ClearAllPoints()
    if Minimap.northTag then
        Minimap.northTag:ClearAllPoints()
    end
    MinimapBackdrop:ClearAllPoints()
    if GW.settings.Minimap.KeepSizeRatio then
        Minimap:SetMaskTexture(130937)
        Minimap:SetHitRectInsets(0, 0, 0, 0)
        Minimap:SetPoint("CENTER", Minimap.gwMover)
        Minimap.location:SetPoint("TOP", Minimap, "TOP", 0, -2)
        if Minimap.northTag then
            Minimap.northTag:SetPoint("TOP", Minimap, 0, 0)
        end
        Minimap.gwMover:SetSize(size, size)
        Minimap.gwMover:SetClampRectInsets(0, 0, 0, 0)
        Minimap.gwBorder:SetSize(size, size)
        MinimapBackdrop:SetAllPoints(Minimap)
        return
    end

    local maskId = floor(GW.settings.Minimap.HeightPercentage / 100 * 128)
    local texturePath = format([[Interface\AddOns\GW2_UI\Textures\MinimapMasks\%d.tga]], maskId)
    local heightPct = maskId / 128
    local newHeight = size * heightPct
    local diff = size - newHeight
    local halfDiff = ceil(diff / 2)
    local mmOffset = 1

    effectiveHeight = newHeight
    Minimap.gwMover:SetSize(GW.settings.MINIMAP_SIZE, effectiveHeight)
    Minimap.gwBorder:SetSize(GW.settings.MINIMAP_SIZE, effectiveHeight)

    Minimap:SetClampedToScreen(true)
    Minimap:SetClampRectInsets(0, 0, 0, 0)
    Minimap.gwMover:SetClampRectInsets(0, 0, halfDiff, -halfDiff)
    Minimap:SetPoint("TOPRIGHT", Minimap.gwMover, -mmOffset , -mmOffset + halfDiff)
    MinimapBackdrop:SetPoint("TOPRIGHT", Minimap, -mmOffset , -mmOffset + halfDiff)

    Minimap:SetMaskTexture(texturePath)
    Minimap:SetHitRectInsets(0, 0, halfDiff, halfDiff)

    Minimap.location:SetPoint("TOP", Minimap, 0, -4 - halfDiff)

    if Minimap.northTag then
        Minimap.northTag:SetPoint("TOP", Minimap, 0, -4 - halfDiff)
    end

    if HybridMinimap then
        local mapCanvas = HybridMinimap.MapCanvas
        local rectangleMask = HybridMinimap:CreateMaskTexture()
        rectangleMask:SetTexture(texturePath)
        rectangleMask:SetAllPoints(HybridMinimap)
        HybridMinimap.RectangleMask = rectangleMask
        mapCanvas:SetMaskTexture(rectangleMask)
        mapCanvas:SetUseMaskTexture(true)
    end
end