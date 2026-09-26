---@class GW2
local GW = select(2, ...)

local moveDistance, mapX, mapY, mapLeft, mapTop, mapNormalScale, mapEffectiveScale = 0, 0, 0, 0, 0, 1, 0

local function HandleDropdownHeaderText(dropdown)
    for idx, c in pairs({dropdown:GetRegions()}) do
        if idx > 3 and c:GetObjectType() == "FontString" then
            c:SetPoint("TOPLEFT", 5, 9)
            c:SetTextColor(1, 1, 1)
            break
        end
    end
end

local function LoadWorldMapSkin()
    if not GW.settings.skins.worldmap.enabled then return end
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

    GW.CreateFrameHeaderWithBody(WorldMapFrame, headerText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", nil, 30, nil, true)
    WorldMapFrame.gwHeader.BGLEFT:SetWidth(100)
    WorldMapFrame.gwHeader.BGRIGHT:SetWidth(WorldMapFrame.BorderFrame:GetWidth())
    WorldMapFrame.BorderFrame:GwStripTextures()
    WorldMapFrame.MiniBorderFrame:GwStripTextures()

    -- for questie
    WorldMapFrame.BorderFrame.headerText = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    WorldMapFrame.BorderFrame.headerText:SetAlpha(0)

    MiniWorldMapTitle:SetAlpha(0)

    WorldMapContinentDropdown:GwHandleDropDownBox()
    WorldMapZoneDropdown:GwHandleDropDownBox()
    WorldMapZoneMinimapDropdown:GwHandleDropDownBox()
    HandleDropdownHeaderText(WorldMapContinentDropdown)
    HandleDropdownHeaderText(WorldMapZoneDropdown)
    HandleDropdownHeaderText(WorldMapZoneMinimapDropdown)

    WorldMapZoneMinimapDropdown:ClearAllPoints()
    WorldMapZoneMinimapDropdown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 6, -45)
    WorldMapZoneMinimapDropdown:SetHeight(25)
    WorldMapContinentDropdown:ClearAllPoints()
    WorldMapContinentDropdown:SetPoint("LEFT", WorldMapZoneMinimapDropdown, "RIGHT", 0, 0)
    WorldMapContinentDropdown:SetWidth(205)
    WorldMapContinentDropdown:SetHeight(25)
    WorldMapZoneDropdown:SetPoint("LEFT", WorldMapContinentDropdown, "RIGHT", 0, 0)
    WorldMapZoneDropdown:SetWidth(205)
    WorldMapZoneDropdown:SetHeight(25)

    WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropdown, "RIGHT", 3, 1)
    WorldMapZoomOutButton:SetHeight(21)
    WorldMapZoomOutButton:GwSkinButton(false, true)

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

    --HideUIPanel(WorldMapFrame)

    table.insert(UISpecialFrames, "WorldMapFrame")
    WorldMapFrame:SetScale(GW.settings.skins.worldmap.scale)
    WorldMapFrame:EnableKeyboard(false)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:SetFrameStrata("HIGH")

    WorldMapTooltip:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 110)

    -- Enable movement
    WorldMapFrame:SetMovable(true)
    WorldMapFrame:SetClampedToScreen(true)
    WorldMapFrame:SetClampRectInsets(0, 0, WorldMapFrameHeader:GetHeight() - 30, 0)
    WorldMapFrame:RegisterForDrag("LeftButton")

    local header = WorldMapFrame.gwHeader
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() WorldMapFrame:GetScript("OnDragStart")(WorldMapFrame) end)
    header:SetScript("OnDragStop", function() WorldMapFrame:GetScript("OnDragStop")(WorldMapFrame) end)
    WorldMapFrame.MaximizeMinimizeFrame:SetFrameLevel(header:GetFrameLevel() + 1)
    -- it also covers blizzards title button of the mini mode, which has the options menu
    header:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" and WorldMapTitleButton:IsShown() then
            WorldMapTitleButton:Click("RightButton")
        end
    end)

    -- blizzards mini mode leaves room for its old border art, here the map sits right below the header
    local function UpdateMapLayout(frame)
        if frame:IsMaximized() then
            frame.ScrollContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -11, 30)
        else
            frame.ScrollContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -32)
            frame.ScrollContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        end
    end
    hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", UpdateMapLayout)
    UpdateMapLayout(WorldMapFrame)

    WorldMapFrame:SetScript("OnDragStart", function()
        WorldMapFrame:StartMoving()
    end)

    WorldMapFrame:SetScript("OnDragStop", function()
        WorldMapFrame:StopMovingOrSizing()
        WorldMapFrame:SetUserPlaced(false)
        -- Save map frame position
        local pos = GW.settings.skins.worldmap.pos
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
        GW.settings.skins.worldmap.pos = pos
    end)

    -- Set position on startup
    WorldMapFrame:HookScript("OnShow", function()
        local pos = GW.settings.skins.worldmap.pos
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
    scaleHandle:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", 0, 0)
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
        moveDistance = GW.GetScaledCursorDistance(mapLeft, mapTop, mapEffectiveScale)
        frame:SetScript("OnUpdate", function()
            local scale = GW.GetScaledCursorDistance(mapLeft, mapTop, mapEffectiveScale) / moveDistance * mapNormalScale
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
        GW.settings.skins.worldmap.scale = WorldMapFrame:GetScale()
        WorldMapFrame:SetScale(WorldMapFrame:GetScale())
        -- Save map frame position
        local pos = GW.settings.skins.worldmap.pos
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
        GW.settings.skins.worldmap.pos = pos
    end)

    -- Function to set position after Leatrix_Maps has loaded
    local function LeatrixMapsFix()
        hooksecurefunc(WorldMapFrame, "Show", function()
            local pos = GW.settings.skins.worldmap.pos
            WorldMapFrame:ClearAllPoints()
            WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

            WorldMapFrame:SetScript("OnDragStart", function()
                WorldMapFrame:StartMoving()
            end)

            WorldMapFrame:SetScript("OnDragStop", function()
                WorldMapFrame:StopMovingOrSizing()
                WorldMapFrame:SetUserPlaced(false)
                -- Save map frame position
                local pos = GW.settings.skins.worldmap.pos
                if pos then
                    wipe(pos)
                else
                    pos = {}
                end
                pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = WorldMapFrame:GetPoint()
                GW.settings.skins.worldmap.pos = pos
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
GW.LoadWorldMapSkin = LoadWorldMapSkin
