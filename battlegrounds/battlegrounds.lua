local _, GW = ...
local FACTION_COLOR = GW.FACTION_COLOR
local AddToAnimation = GW.AddToAnimation
local GetAreaPOIForMap = C_AreaPoiInfo.GetAreaPOIForMap
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local GetBestMapForUnit = C_Map.GetBestMapForUnit

local bgs = {}
local POIList = {}
local POIInfo = {}

local activeBg = 0
local activeMap

local pointsAlliance = 0
local pointsHorde = 0

local updateCap = 1 / 5

local PvPClassificationFaction = {
    [Enum.PvpUnitClassification.FlagCarrierHorde] = "A",
    [Enum.PvpUnitClassification.FlagCarrierAlliance] = "H",
    [Enum.PvpUnitClassification.FlagCarrierNeutral] = "N",
    [Enum.PvpUnitClassification.CartRunnerHorde] = "A",
    [Enum.PvpUnitClassification.CartRunnerAlliance] = "H"
    --[Enum.PvpUnitClassification.OrbCarrierBlue] = "orb",
    --[Enum.PvpUnitClassification.OrbCarrierGreen] = "orb",
    --[Enum.PvpUnitClassification.OrbCarrierOrange] = "orb",
    --[Enum.PvpUnitClassification.OrbCarrierPurple] = "orb"
}

local function getPoints(widget)
    local widgetID = widget and widget.widgetID
    if widgetID then
        local info = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
        if info then
            pointsAlliance, pointsHorde = info.leftBarValue, info.rightBarValue
        end
    end
end

local function capStateChanged(self)
    local fnScale = function(prog)
        self:SetScale(prog)
    end
    AddToAnimation(self:GetName(), 2, 1, GetTime(), 0.5, fnScale)
end
GW.AddForProfiling("battlegrounds", "capStateChanged", capStateChanged)

local function iconOverrider(self, icon)
    if bgs[activeBg]["icons"][icon] == nil then
        return false
    end

    local x1, x2, y1, y2 =
        bgs[activeBg]["icons"][icon][1],
        bgs[activeBg]["icons"][icon][2],
        bgs[activeBg]["icons"][icon][3],
        bgs[activeBg]["icons"][icon][4]

    self.icon:SetTexture("Interface\\AddOns\\GW2_UI\\Textures\\battleground\\objective-icons")

    self.icon:SetTexCoord(0.25, 0.5, 0, 1)
    self.icon:SetTexCoord(x1, x2, y1, y2)
    self.icon:SetSize(32, 32)

    local iconState = icon - bgs[activeBg]["icons"][icon]["normalState"]
    if iconState == 0 then -- no cap
        self.IconBackground:SetVertexColor(1, 1, 1)
        self.icon:SetVertexColor(0, 0, 0)
    elseif iconState == 1 then
        self.IconBackground:SetVertexColor(1, 1, 1)
        self.icon:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)
    elseif iconState == 2 then
        self.IconBackground:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)
        self.icon:SetVertexColor(0, 0, 0)
    elseif iconState == 3 then
        self.IconBackground:SetVertexColor(1, 1, 1)
        self.icon:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
    elseif iconState == 4 then
        self.IconBackground:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
        self.icon:SetVertexColor(0, 0, 0)
    end

    return true
end
GW.AddForProfiling("battlegrounds", "iconOverrider", iconOverrider)

local function setIconAtlas(self, atlas)
    if self.savedIconIndex ~= atlas.file then
        capStateChanged(self)
    end
    self.savedIconIndex = atlas.file

    local x1, x2, y1, y2 = atlas.leftTexCoord, atlas.rightTexCoord, atlas.topTexCoord, atlas.bottomTexCoord
    self.icon:SetTexture(atlas.file)
    self.icon:SetTexCoord(x1, x2, y1, y2)
    self.icon:SetSize(20, 20)
end
GW.AddForProfiling("battlegrounds", "setIcon", setIcon)

local function setIcon(self, icon)
    if self.savedIconIndex ~= icon then
        capStateChanged(self)
    end
    self.savedIconIndex = icon

    if iconOverrider(self, icon) then
        return
    end

    local x1, x2, y1, y2 = GetPOITextureCoords(icon)
    self.icon:SetTexture("Interface/Minimap/POIIcons")
    self.icon:SetTexCoord(x1, x2, y1, y2)
    self.icon:SetSize(20, 20)
end
GW.AddForProfiling("battlegrounds", "setIcon", setIcon)

local function LandMarkFrameSetPoint_noTimer(i)
    _G["GwBattleLandMarkFrame" .. i]:SetPoint("CENTER", GwBattleGroundScores.MID, "BOTTOMLEFT", (36) * (i - 1) + 18, 45)
end
GW.AddForProfiling("battlegrounds", "LandMarkFrameSetPoint_noTimer", LandMarkFrameSetPoint_noTimer)

local function getLandMarkFrame(i)
    if _G["GwBattleLandMarkFrame" .. i] == nil then
        CreateFrame("FRAME", "GwBattleLandMarkFrame" .. i, GwBattleGroundScores, "GwBattleLandMarkFrame")
        _G["GwBattleLandMarkFrame" .. i]:SetPoint(
            "CENTER",
            GwBattleGroundScores.MID,
            "BOTTOMLEFT",
            (36) * (i - 1) + 18,
            32
        )
    end
    return _G["GwBattleLandMarkFrame" .. i]
end
GW.AddForProfiling("battlegrounds", "getLandMarkFrame", getLandMarkFrame)

local function PointsAndPOI_onEvent(self, event, ...)
    if not activeMap then
        return
    end

    if event == "UPDATE_UI_WIDGET" then
        getPoints(...)
    end
    
    if pointsAlliance == nil or pointsHorde == nil then
        return
    end

    self.scoreRight:SetText(pointsAlliance)
    self.scoreLeft:SetText(pointsHorde)
    if not self.hasTimer then
        self.timer:SetText("")
    end

    wipe(POIList)
    wipe(POIInfo)
    for i = 1, 10 do
        if _G["GwBattleLandMarkFrame" .. i] ~= nil then
            _G["GwBattleLandMarkFrame" .. i]:Hide()
        end
    end

    POIList = GetAreaPOIForMap(activeMap)

    for i = 1, #POIList do
        POIInfo = GetAreaPOIInfo(activeMap, POIList[i])
        local f = getLandMarkFrame(i)
        if not self.hasTimer then
            LandMarkFrameSetPoint_noTimer(i)
        end

        if POIInfo.atlasName then
            local atlas = C_Texture.GetAtlasInfo(POIInfo.atlasName)
            setIconAtlas(f, atlas)
        else
            setIcon(f, POIInfo.textureIndex)
            if POIInfo.textureIndex == 0 then
                for i = 1, 5 do
                    if UnitExists("arena" .. i)  then
                        local classificationFaction = PvPClassificationFaction[UnitPvpClassification("arena" .. i)]
                        if classificationFaction == "H" then
                            f.IconBackground:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
                        elseif classificationFaction == "A" then
                            f.IconBackground:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)
                        else
                            f.IconBackground:SetVertexColor(1, 1, 1)
                        end
                    end
                end
            end
        end
        f:Show()
        GwBattleGroundScores.MID:SetWidth(36 * i)
    end
    for i = 1, 5 do
        if _G["AlwaysUpFrame" .. i] ~= nil then
            _G["AlwaysUpFrame" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("battlegrounds", "PointsAndPOI_onEvent", PointsAndPOI_onEvent)

local function OnlyPoints_onEvent(self, event, ...)
    if not activeMap then
        return
    end

    if event == "UPDATE_UI_WIDGET" or event == "AREA_POIS_UPDATED" then
        getPoints(...)
    end

    if pointsAlliance == nil or pointsHorde == nil then
        return
    end

    self.scoreRight:SetText(pointsAlliance)
    self.scoreLeft:SetText(pointsHorde)
    if not self.hasTimer then
        self.timer:SetText("")
    end
end
GW.AddForProfiling("battlegrounds", "OnlyPoints_onEvent", OnlyPoints_onEvent)

local function TimerFlag_OnUpdate(self, elapsed)
    self.elapsedTimer = self.elapsedTimer - elapsed
    if self.elapsedTimer > 0 then
        return
    end
    self.elapsedTimer = updateCap

    if self.hasTimer then
        local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(6)
        if info and info.state > Enum.IconAndTextWidgetState.Hidden then
            local minutes, seconds = info.text:match("(%d+):(%d+)")
            if minutes and seconds then
                self.timer:SetText(minutes .. ":" .. seconds)
            end
        end
    end
    --Check flag
    if self.TrackFlag then
        for i = 1, 10 do
            if _G["GwBattleLandMarkFrame" .. i] ~= nil then
                _G["GwBattleLandMarkFrame" .. i]:Hide()
            end
        end
        local counter = 0
        for i = 1, 5 do
            if UnitExists("arena" .. i)  then
                counter = counter + 1
                local f = getLandMarkFrame(counter)
                if not self.hasTimer then
                    LandMarkFrameSetPoint_noTimer(counter)
                end
                local classificationFaction = PvPClassificationFaction[UnitPvpClassification("arena" .. i)]
                if classificationFaction == "H" then
                    f.IconBackground:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
                elseif classificationFaction == "A" then
                    f.IconBackground:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)
                else
                    f.IconBackground:SetVertexColor(1, 1, 1)
                end
                f.icon:SetTexture(nil)
                f:Show()
            end
        end
        GwBattleGroundScores.MID:SetWidth(36 * counter)
    end
end
GW.AddForProfiling("battlegrounds", "TimerFlag_OnUpdate", TimerFlag_OnUpdate)

local function pvpHud_onEvent(self, event)
    local _, _, _, _, _, _, _, mapID, _ = GetInstanceInfo()

    GW.Debug("pvp instance: ", mapID)
    
    if bgs[mapID] ~= nil then
        if event == "PLAYER_ENTERING_BATTLEGROUND" then
            pointsAlliance = 0
            pointsHorde = 0
        end
        activeBg = mapID
        activeMap = GetBestMapForUnit("player")
        UIWidgetTopCenterContainerFrame:Hide()

        GwBattleGroundScores.hasTimer = false
        GwBattleGroundScores.TrackFlag = false
        GwBattleGroundScores:SetScript("OnEvent", bgs[mapID]["OnEvent"])
        if bgs[mapID]["OnUpdate"] then
            GwBattleGroundScores:SetScript("OnUpdate", bgs[mapID]["OnUpdate"])
            GwBattleGroundScores.elapsedTimer = -1
        end
        if bgs[mapID]["TrackFlag"] then
            GwBattleGroundScores.TrackFlag = true
        end
        if bgs[mapID]["hasTimer"] then
            GwBattleGroundScores.hasTimer = true
        end
        GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
        GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_WORLD")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_INDOORS")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        GwBattleGroundScores:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
        GwBattleGroundScores:RegisterEvent("UPDATE_UI_WIDGET")
        GwBattleGroundScores:RegisterEvent("AREA_POIS_UPDATED")
        
        GwBattleGroundScores:Show()
    else
        GwBattleGroundScores:UnregisterAllEvents()
        GwBattleGroundScores:Hide()
        GwBattleGroundScores:SetScript("OnEvent", nil)
        GwBattleGroundScores:SetScript("OnUpdate", nil)
        UIWidgetTopCenterContainerFrame:Show()
    end
end
GW.AddForProfiling("battlegrounds", "pvpHud_onEvent", pvpHud_onEvent)

local function LoadBattlegrounds()
    bgs = {
        [529] = { --Arathi
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {
                [16] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [17] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [18] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [19] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [20] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [21] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [22] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [23] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [24] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [25] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [31] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [32] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [33] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [34] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [35] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [36] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [37] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [38] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [39] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [40] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36}
            }
        },
        [1681] = { --Arathi
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {
                [16] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [17] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [18] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [19] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [20] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [21] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [22] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [23] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [24] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [25] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [31] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [32] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [33] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [34] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [35] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [36] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [37] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [38] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [39] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [40] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36}
            }
        },
        [2107] = { --Arathi
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {
                [16] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [17] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [18] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [19] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [20] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                [21] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [22] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [23] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [24] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [25] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  ["normalState"] = 21},
                [26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    ["normalState"] = 26},
                [31] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [32] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [33] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [34] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [35] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  ["normalState"] = 31},
                [36] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [37] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [38] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [39] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36},
                [40] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  ["normalState"] = 36}
            }
        },
        [2245] = { --Deepwind (TODO: Add cart carrier to top)
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {}
        },
        [727] = { --SilvershardMines
            ["OnEvent"] = OnlyPoints_onEvent
        },
        [30] = { --Alterac
            ["OnEvent"] = OnlyPoints_onEvent
        },
        [1803] = { --SeethingShore
            ["OnEvent"] = OnlyPoints_onEvent
        },
        [998] = { --TempleOfKotmogu (TODO: Add orb carrier to top)
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {}
        },
        [566] = { --EyeOfTheStorm test
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {}
        },
        [968] = { --EyeOfTheStorm test
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {}
        },
        [726] = { --TwinPeaks
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["OnUpdate"] = TimerFlag_OnUpdate,
            ["hasTimer"] = true,
            ["TrackFlag"] = true
        },
        [2106] = { --Warsong
            ["OnEvent"] = OnlyPoints_onEvent,
            ["OnUpdate"] = TimerFlag_OnUpdate,
            ["hasTimer"] = true,
            ["TrackFlag"] = true
        },
        [761] = { --Gilneas
            ["OnEvent"] = PointsAndPOI_onEvent,
            ["icons"] = {
                --[8] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 8}, --Tower (need Icon)
                --[9] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 8},
                --[10] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 8},
                --[11] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 8},
                --[12] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 8},
                --[16] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16}, --Mine
                --[17] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                --[18] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                --[19] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                --[20] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  ["normalState"] = 16},
                --[26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26}, --Water (need Icon)
                --[27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                --[28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                --[29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                --[30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26}
            }
        }
    }

    CreateFrame("FRAME", "GwPvpHudManager", UIParent)

    local gwbgs = CreateFrame("FRAME", "GwBattleGroundScores", UIParent, "GwBattleGroundScores")
    gwbgs.leftFlag:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
    gwbgs.rightFlag:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)

    gwbgs.scoreLeft:SetFont(UNIT_NAME_FONT, 30)
    gwbgs.scoreLeft:SetShadowColor(0, 0, 0, 1)
    gwbgs.scoreLeft:SetShadowOffset(1, -1)

    gwbgs.scoreRight:SetFont(UNIT_NAME_FONT, 30)
    gwbgs.scoreRight:SetShadowColor(0, 0, 0, 1)
    gwbgs.scoreRight:SetShadowOffset(1, -1)

    gwbgs.timer:SetFont(UNIT_NAME_FONT, 12)
    gwbgs.timer:SetShadowColor(0, 0, 0, 1)
    gwbgs.timer:SetShadowOffset(1, -1)

    GwPvpHudManager:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwPvpHudManager:RegisterEvent("ZONE_CHANGED")
    GwPvpHudManager:RegisterEvent("ZONE_CHANGED_INDOORS")
    GwPvpHudManager:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    GwPvpHudManager:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    GwPvpHudManager:SetScript("OnEvent", pvpHud_onEvent)
end
GW.LoadBattlegrounds = LoadBattlegrounds
