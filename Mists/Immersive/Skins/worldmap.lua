local _, GW = ...

local moveDistance, mapX, mapY, mapLeft, mapTop, mapNormalScale, mapEffectiveScale = 0, 0, 0, 0, 0, 1, 0

local function GetScaleDistance()
    local left, top = mapLeft, mapTop
    local scale = mapEffectiveScale
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end

local function worldMapSkin()
    if not GW.settings.WORLDMAP_SKIN_ENABLED then return end
    WorldMapFrame:GwStripTextures()
    WorldMapFrame.BlackoutFrame:GwKill()

    local headerText
    local r = {WorldMapFrame.BorderFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        elseif c:GetObjectType() == "FontString" then
            headerText = c
        end
    end

    GW.CreateFrameHeaderWithBody(WorldMapFrame, headerText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", {QuestScrollFrame}, 0, nil, true)
    WorldMapFrame.BorderFrame:GwStripTextures()
    WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    WorldMapFrame.MiniBorderFrame:GwKill()

    WorldMapFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    WorldMapFrame.backdrop:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 0, -30)
    WorldMapFrame.backdrop:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, 0)

    -- for questie
    WorldMapFrame.BorderFrame.headerText = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    WorldMapFrame.BorderFrame.headerText:SetAlpha(0)

    MiniWorldMapTitle:Hide()
    WorldMapTitleButton:GwKill()

    WorldMapContinentDropdown:GwHandleDropDownBox()
    WorldMapZoneDropdown:GwHandleDropDownBox()
    WorldMapZoneMinimapDropdown:GwHandleDropDownBox()
    WorldMapFrame.WorldMapOptionsDropDown:GwHandleDropDownBox()
    WorldMapTrackQuest:GwSkinCheckButton()
    WorldMapTrackQuest:SetSize(15, 15)
    WorldMapTrackQuestText:SetTextColor(1, 1, 1)

    QuestMapFrame.DetailsFrame.ScrollFrame:GwSkinScrollFrame()
    QuestMapFrame.DetailsFrame.ScrollFrame.ScrollBar:GwSkinScrollBar()

    GW.HandleTrimScrollBar(QuestScrollFrame.ScrollBar)
    GW.HandleScrollControls(QuestScrollFrame)

    WorldMapFrame.WorldMapLevelDropDown:GwHandleDropDownBox()

    WorldMapZoneMinimapDropdown:ClearAllPoints()
    WorldMapContinentDropdown:ClearAllPoints()
    WorldMapZoneDropdown:ClearAllPoints()
    WorldMapZoneMinimapDropdown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 6, -45)
    WorldMapContinentDropdown:SetPoint("LEFT", WorldMapZoneMinimapDropdown, "RIGHT", -5, 0)
    WorldMapZoneDropdown:SetPoint("LEFT", WorldMapContinentDropdown, "RIGHT", -5, 0)
    WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropdown, "RIGHT", 3, 2)
    WorldMapZoomOutButton:GwSkinButton(false, true)

    for _, v in pairs({WorldMapZoneMinimapDropdown, WorldMapContinentDropdown, WorldMapZoneDropdown}) do
        local regions = {v:GetRegions()}
        for regionKey, c in pairs(regions) do
            if c:GetObjectType() == "FontString" and regionKey == 4 then
                c:SetTextColor(1, 1, 1)
                c:ClearAllPoints()
                c:SetPoint("TOPLEFT", v, "TOPLEFT", 5, 10)

            end
        end
    end

    WorldMapFrameCloseButton:GwSkinButton(true)
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

    table.insert(UISpecialFrames, "WorldMapFrame")
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
        local pos = GW.settings.WORLDMAP_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
        GW.settings.WORLDMAP_POSITION = pos
    end)

    -- Set position on startup
    WorldMapFrame:HookScript("OnShow", function()
        local pos = GW.settings.WORLDMAP_POSITION
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
    scaleHandle.t:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/resize.png")
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
        GW.settings.WORLDMAP_POSITION_scale = WorldMapFrame:GetScale()
        WorldMapFrame:SetScale(WorldMapFrame:GetScale())
        -- Save map frame position
        local pos = GW.settings.WORLDMAP_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
        GW.settings.WORLDMAP_POSITION = pos
    end)

    WorldMapFrame:SetScale(GW.settings.WORLDMAP_POSITION_scale)

    -- Function to set position after Leatrix_Maps has loaded
    local function LeatrixMapsFix()
        hooksecurefunc(WorldMapFrame, "Show", function()
            local pos = GW.settings.WORLDMAP_POSITION
            WorldMapFrame:ClearAllPoints()
            WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

            WorldMapFrame:SetScript("OnDragStart", function()
                WorldMapFrame:StartMoving()
            end)

            WorldMapFrame:SetScript("OnDragStop", function()
                WorldMapFrame:StopMovingOrSizing()
                WorldMapFrame:SetUserPlaced(false)
                -- Save map frame position
                local pos = GW.settings.WORLDMAP_POSITION
                if pos then
                    wipe(pos)
                else
                    pos = {}
                end
                pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
                GW.settings.WORLDMAP_POSITION = pos
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

    -- player pin
    for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
        pin:SetPinTexture("player", "Interface/AddOns/GW2_UI/textures/icons/player_arrow.png")
        pin.dataProvider:GetUnitPinSizesTable().player = 34
        pin:SynchronizePinSizes()
        break
    end

    if Questie_Toggle then Questie_Toggle:GwSkinButton(false, true) end
end

local function LoadWorldMapSkin()
    if not GW.settings.WORLDMAP_SKIN_ENABLED then return end

    GW.RegisterLoadHook(worldMapSkin, "Blizzard_WorldMap", WorldMapFrame)
end
GW.LoadWorldMapSkin = LoadWorldMapSkin