local _, GW = ...

local CoordsFrame
local moveDistance, mapX, mapY, mapLeft, mapTop, mapNormalScale, mapEffectiveScale = 0, 0, 0, 0, 0, 1, 0

local function UpdateCoords()
    if not WorldMapFrame:IsShown() then
        return
    end

    if GW.locationData.x and GW.locationData.y then
        CoordsFrame.Coords:SetFormattedText("%s: %.2f, %.2f", PLAYER, (GW.locationData.xText or 0), (GW.locationData.yText or 0))
    else
        CoordsFrame.Coords:SetFormattedText("%s: %s", PLAYER, NOT_APPLICABLE)
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
    WorldMapFrame:StripTextures()
    WorldMapFrame.BlackoutFrame:Hide()

    local tex = WorldMapFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = WorldMapFrame:GetSize()
    tex:SetPoint("TOP", WorldMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 110, h + 50)
    WorldMapFrame.tex = tex

    WorldMapContinentDropDown:SkinDropDownMenu()
    WorldMapZoneDropDown:SkinDropDownMenu()
    WorldMapZoneMinimapDropDown:SkinDropDownMenu()

    WorldMapContinentDropDown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 330, -35)
    WorldMapContinentDropDown:SetWidth(205)
    WorldMapContinentDropDown:SetHeight(33)
    WorldMapZoneDropDown:SetPoint("LEFT", WorldMapContinentDropDown, "RIGHT", -20, 0)
    WorldMapZoneDropDown:SetWidth(205)
    WorldMapZoneDropDown:SetHeight(33)

    WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropDown, "RIGHT", 3, 3)
    WorldMapZoomOutButton:SetHeight(21)

    WorldMapZoomOutButton:SkinButton(false, true)

    WorldMapFrameCloseButton:SkinButton(true)
    WorldMapFrameCloseButton:SetSize(25, 25)
    WorldMapFrameCloseButton:ClearAllPoints()
    WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 20, -25)
    WorldMapFrameCloseButton:SetFrameLevel(WorldMapFrameCloseButton:GetFrameLevel() + 2)

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
    table.insert(UISpecialFrames, "WorldMapFrame")
    HideUIPanel(WorldMapFrame)

    WorldMapFrame:SetScale(0.8)
    WorldMapFrame:EnableKeyboard(false)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:SetFrameStrata("HIGH")

    WorldMapTooltip:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 110)

    -- Added Coords to Worldmap
    if GW.GetSetting("WORLDMAP_COORDS_TOGGLE") then
        local CoordsTimer = nil
        CoordsFrame = CreateFrame("Frame", nil, WorldMapFrame)
        CoordsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
        CoordsFrame:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
        CoordsFrame.Coords = CoordsFrame:CreateFontString(nil, "OVERLAY")
        CoordsFrame.Coords:SetTextColor(1, 1 ,1)
        CoordsFrame.Coords:SetFontObject(NumberFontNormal)

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
        CoordsFrame.Coords:SetPoint("TOP", WorldMapFrame.ScrollContainer, "TOP", 0, 0)
    end

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
    -- Replace function to account for frame scale
    WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
        local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
        local s = WorldMapFrame:GetScale() * UIParent:GetEffectiveScale()
        return x/s, y/s
    end

    local scaleHandle = CreateFrame("Frame", nil, WorldMapFrame)
    scaleHandle:SetWidth(50)
    scaleHandle:SetHeight(50)
    scaleHandle:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -10, 30)
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

    -- Function to set position after Leatrix_Maps has loaded
    local function LeatrixMapsFix()
        hooksecurefunc(WorldMapFrame, "Show", function()
            local pos = GW.GetSetting("WORLDMAP_POSITION")
            WorldMapFrame:ClearAllPoints()
            WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

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
        end)
    end

    -- Run function when Carbonite has loaded
    if IsAddOnLoaded("Leatrix_Maps") then
        LeatrixMapsFix()
    else
        local waitFrame = CreateFrame("FRAME")
        waitFrame:RegisterEvent("ADDON_LOADED")
        waitFrame:SetScript("OnEvent", function(_, _, arg1)
            if arg1 == "Leatrix_Maps" then
                LeatrixMapsFix()
                waitFrame:UnregisterAllEvents()
            end
        end)
    end

    if Questie_Toggle then Questie_Toggle:SkinButton(false, true) end
end
GW.SkinWorldMap = SkinWorldMap