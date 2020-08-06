local _, GW = ...

local CoordsFrame
local moveDistance, mapX, mapY, mapLeft, mapTop, mapNormalScale, mapEffectiveScale = 0, 0, 0, 0, 0, 1

local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
local function GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {
			select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))),
			select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))}
		mapRect[2]:Subtract(mapRect[1])
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end

local function UpdateCoords()
    local WorldMapFrame = _G.WorldMapFrame
    if not WorldMapFrame:IsShown() then
        return
    end

	local x, y
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID then
		x, y = GetPlayerMapPos(mapID)
	else
		x, y = nil, nil
	end

	if x and y then
		x = GW.RoundDec(100 * x, 2)
		y = GW.RoundDec(100 * y, 2)
		CoordsFrame.Coords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (x or 0), (y or 0))
	else
		CoordsFrame.Coords:SetFormattedText("%s: %s", PLAYER, "n/a")
    end
    
    if WorldMapFrame.ScrollContainer:IsMouseOver() then
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        if x and y and x >= 0 and y >= 0 then
            CoordsFrame.Coords:SetFormattedText("%s - %s: %.2f, %.2f", CoordsFrame.Coords:GetText(), MOUSE_LABEL, x * 100, y * 100)
        end
    end
end

local function GetScaleDistance()
    local left, top = mapLeft, mapTop
    local scale = mapEffectiveScale
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end

local function SkinWorldMap()
    local WorldMapFrame = _G.WorldMapFrame
    WorldMapFrame:StripTextures()
    WorldMapFrame.BlackoutFrame:Hide()

    local tex = WorldMapFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = WorldMapFrame:GetSize()
    tex:SetPoint("TOP", WorldMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 120, h + 80 )
    WorldMapFrame.tex = tex

    _G.WorldMapContinentDropDown:SkinDropDownMenu()
    _G.WorldMapZoneDropDown:SkinDropDownMenu()

    _G.WorldMapContinentDropDown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 330, -35)
    _G.WorldMapContinentDropDown:SetWidth(205)
    _G.WorldMapContinentDropDown:SetHeight(33)
    _G.WorldMapZoneDropDown:SetPoint("LEFT", _G.WorldMapContinentDropDown, "RIGHT", -20, 0)
    _G.WorldMapZoneDropDown:SetWidth(205)
    _G.WorldMapZoneDropDown:SetHeight(33)

    _G.WorldMapZoomOutButton:SetPoint("LEFT", _G.WorldMapZoneDropDown, "RIGHT", 3, 3)
    _G.WorldMapZoomOutButton:SetHeight(21)

    _G.WorldMapZoomOutButton:SkinButton(false, true)

    _G.WorldMapFrameCloseButton:SkinButton(true)
    _G.WorldMapFrameCloseButton:SetSize(25, 25)
    _G.WorldMapFrameCloseButton:ClearAllPoints()
    _G.WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 20, -25)
    _G.WorldMapFrameCloseButton:SetFrameLevel(_G.WorldMapFrameCloseButton:GetFrameLevel() + 2)

    ShowUIPanel(WorldMapFrame)
    WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
    WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
    WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
    WorldMapFrame:SetIgnoreParentScale(false)
    WorldMapFrame.ScrollContainer:SetIgnoreParentScale(false)
    WorldMapFrame.IsMaximized = function() return false end
    WorldMapFrame.HandleUserActionToggleSelf = function()
        if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
    end
    HideUIPanel(WorldMapFrame)

    WorldMapFrame:SetScale(0.8)
    WorldMapFrame:EnableKeyboard(false)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:SetFrameStrata("HIGH")

    _G.WorldMapTooltip:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 110)

	-- Added Coords to Worldmap
	local CoordsTimer = nil
    CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
    CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
    CoordsFrame.Coords = CoordsFrame:CreateFontString(nil, "OVERLAY")
    CoordsFrame.Coords:SetTextColor(1, 1 ,1)
    CoordsFrame.Coords:SetFontObject(_G.NumberFontNormal)

    WorldMapFrame:HookScript("OnShow", function()
        if not CoordsTimer then
			UpdateCoords()
			CoordsTimer = C_Timer.NewTicker(0.1, function() UpdateCoords() end)
        end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        CoordsTimer:Cancel()
        CoordsTimer = nil
    end)

    CoordsFrame.Coords:ClearAllPoints()
    CoordsFrame.Coords:SetPoint("TOP", _G.WorldMapFrame.ScrollContainer, "TOP", 0, 0)
    
    -- Enable movement
    WorldMapFrame:SetMovable(true)
    WorldMapFrame:RegisterForDrag("LeftButton")

    WorldMapFrame:SetScript("OnDragStart", function()
        WorldMapFrame:StartMoving()
    end)

    WorldMapFrame:SetScript("OnDragStop", function()
        WorldMapFrame:StopMovingOrSizing()
        WorldMapFrame:SetUserPlaced(false)
        -- Save map frame position
        local pos = GW.GetSetting("WORLDMAP_POSITION")
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
        GW.SetSetting("WORLDMAP_POSITION", pos)
    end)

    -- Set position on startup
    local pos = GW.GetSetting("WORLDMAP_POSITION")
    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

    -- Create scale handle
    local scaleHandle = CreateFrame("Frame", nil, WorldMapFrame)
    scaleHandle:SetWidth(50)
    scaleHandle:SetHeight(50)
    scaleHandle:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", 8, 5)
    scaleHandle:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    scaleHandle:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 15)

    scaleHandle.t = scaleHandle:CreateTexture(nil, "OVERLAY")
    scaleHandle.t:SetAllPoints()
    scaleHandle.t:SetTexture("Interface/AddOns/GW2_UI/textures/resize")
    scaleHandle.t:SetDesaturated(true)

    -- Create scale frame
    local scaleMouse = CreateFrame("Frame", nil, WorldMapFrame)
    scaleMouse:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    scaleMouse:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 20)
    scaleMouse:SetAllPoints(scaleHandle)
    scaleMouse:EnableMouse(true)
    scaleMouse:SetScript("OnEnter", function() scaleHandle.t:SetDesaturated(false) end)
    scaleMouse:SetScript("OnLeave", function() scaleHandle.t:SetDesaturated(true) end)

    -- Click handlers
    scaleMouse:SetScript("OnMouseDown",function(frame)
        mapLeft, mapTop = WorldMapFrame:GetLeft(), WorldMapFrame:GetTop()
        mapNormalScale = WorldMapFrame:GetScale()
        mapX, mapY = mapLeft, mapTop - (UIParent:GetHeight() / mapNormalScale)
        mapEffectiveScale = WorldMapFrame:GetEffectiveScale()
        moveDistance = GetScaleDistance()
        frame:SetScript("OnUpdate", function()
            local scale = GetScaleDistance() / moveDistance * mapNormalScale
            if scale < 0.2 then	scale = 0.2	elseif scale > 3.0 then	scale = 3.0	end
            WorldMapFrame:SetScale(scale)
            local s = mapNormalScale / WorldMapFrame:GetScale()
            local x = mapX * s
            local y = mapY * s
            WorldMapFrame:ClearAllPoints()
            WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
        frame:SetAllPoints(UIParent)
    end)

    scaleMouse:SetScript("OnMouseUp", function(frame)
        frame:SetScript("OnUpdate", nil)
        frame:SetAllPoints(scaleHandle)
        GW.SetSetting("WORLDMAP_SCALE", WorldMapFrame:GetScale())
        WorldMapFrame:SetScale(WorldMapFrame:GetScale())
        -- Save map frame position
        local pos = GW.GetSetting("WORLDMAP_POSITION")
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
        GW.SetSetting("WORLDMAP_POSITION", pos)
    end)

    WorldMapFrame:SetScale(GW.GetSetting("WORLDMAP_SCALE"))

end
GW.SkinWorldMap = SkinWorldMap