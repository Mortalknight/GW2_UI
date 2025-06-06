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

local function LoadWorldMapSkin()
    if not GW.GetSetting("WORLDMAP_SKIN_ENABLED") then return end
    WorldMapFrame:StripTextures()
    WorldMapFrame.BlackoutFrame:Kill()

    local headerText
    local r = {WorldMapFrame.BorderFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        elseif c:GetObjectType() == "FontString" then
            headerText = c
        end
    end

    GW.CreateFrameHeaderWithBody(WorldMapFrame, headerText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon", nil, 30)
    WorldMapFrameHeader.BGLEFT:SetWidth(100)
    WorldMapFrameHeader.BGRIGHT:SetWidth(WorldMapFrame.BorderFrame:GetWidth())
    WorldMapFrame.BorderFrame:StripTextures()
    WorldMapFrame.MiniBorderFrame:StripTextures()

    WorldMapFrame.BorderFrame:CreateBackdrop(GW.skins.constBackdropFrame, true)
    WorldMapFrame.MiniBorderFrame:CreateBackdrop(GW.skins.constBackdropFrame, true)

    WorldMapContinentDropdown:GwHandleDropDownBox()
    WorldMapZoneDropdown:GwHandleDropDownBox()
    WorldMapZoneMinimapDropdown:GwHandleDropDownBox()

    WorldMapContinentDropdown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 330, -35)
    WorldMapContinentDropdown:SetWidth(205)
    WorldMapContinentDropdown:SetHeight(33)
    WorldMapZoneDropdown:SetPoint("LEFT", WorldMapContinentDropdown, "RIGHT", -20, 0)
    WorldMapZoneDropdown:SetWidth(205)
    WorldMapZoneDropdown:SetHeight(33)

    WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropdown, "RIGHT", 3, 2)
    WorldMapZoomOutButton:SetHeight(21)

    WorldMapZoomOutButton:SkinButton(false, true)

    WorldMapFrameCloseButton:SkinButton(true)
    WorldMapFrameCloseButton:SetSize(20, 20)
    WorldMapFrameCloseButton:ClearAllPoints()
    WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)
    hooksecurefunc(WorldMapFrameCloseButton, "SetPoint", function(self)
        if not WorldMapFrameCloseButton.gwSkipSetPoint then
            WorldMapFrameCloseButton.gwSkipSetPoint = true
            WorldMapFrameCloseButton:ClearAllPoints()
            WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)
            WorldMapFrameCloseButton.gwSkipSetPoint = false
        end
    end)

    WorldMapFrameCloseButton:SetFrameLevel(WorldMapFrameCloseButton:GetFrameLevel() + 2)

    WorldMapFrame.MaximizeMinimizeFrame:GwHandleMaxMinFrame()

    --ShowUIPanel(WorldMapFrame)
    WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
    WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
    WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
    WorldMapFrame:SetIgnoreParentScale(false)
    WorldMapFrame.ScrollContainer:SetIgnoreParentScale(false)
    WorldMapFrame.HandleUserActionToggleSelf = function()
        if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
    end

    --HideUIPanel(WorldMapFrame)

    table.insert(UISpecialFrames, "WorldMapFrame")
    WorldMapFrame:SetScale(0.8)
    WorldMapFrame:EnableKeyboard(false)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:SetFrameStrata("HIGH")

    WorldMapTooltip:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 110)

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
    WorldMapFrame:HookScript("OnShow", function()
        local pos = GW.GetSetting("WORLDMAP_POSITION")
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end)

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
    if C_AddOns.IsAddOnLoaded("Leatrix_Maps") then
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
GW.LoadWorldMapSkin = LoadWorldMapSkin

local function ToggleWorldMapCoords()
    if GW.GetSetting("WORLDMAP_COORDS_TOGGLE") then
        CoordsFrame:Show()
    else
        CoordsFrame:Hide()
    end
end
GW.ToggleWorldMapCoords = ToggleWorldMapCoords

local function AddCoordsToWorldMap()
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

            if CoordsTimer then
                CoordsTimer:Cancel()
                CoordsTimer =nil
            end
            CoordsTimer = C_Timer.NewTicker(0.1, function() UpdateCoords() end)
        end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        CoordsTimer:Cancel()
        CoordsTimer = nil
    end)

    CoordsFrame.Coords:ClearAllPoints()
    CoordsFrame.Coords:SetPoint("TOP", WorldMapFrame.ScrollContainer, "TOP", 0, 0)

    ToggleWorldMapCoords()
end
GW.AddCoordsToWorldMap = AddCoordsToWorldMap