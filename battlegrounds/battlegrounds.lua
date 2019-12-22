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

local function getPoints(widget)
    local widgetID = widget and widget.widgetID
    local info = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
    if info then
        pointsAlliance, pointsHorde = info.leftBarValue, info.rightBarValue
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

    local iconState = icon - bgs[activeBg]["icons"][icon]["normalState"]
    print(icon)
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

local function AB_onEvent(self, event, ...)
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
    self.timer:SetText("")

    wipe(POIList)
    wipe(POIInfo)

    POIList = GetAreaPOIForMap(activeMap)

    for i = 1, #POIList do
        POIInfo = GetAreaPOIInfo(activeMap, POIList[i])
        local f = getLandMarkFrame(i)
        LandMarkFrameSetPoint_noTimer(i)

        setIcon(f, POIInfo.textureIndex)

        GwBattleGroundScores.MID:SetWidth(36 * i)
    end
    for i = #POIList + 1, 10 do
        if _G["GwBattleLandMarkFrame" .. i] ~= nil then
            _G["GwBattleLandMarkFrame" .. i]:Hide()
        end
    end
    for i = 1, 5 do
        if _G["AlwaysUpFrame" .. i] ~= nil then
            _G["AlwaysUpFrame" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("battlegrounds", "AB_onEvent", AB_onEvent)

local function OnlyPoints_onEvent(self, event, ...)
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
    self.timer:SetText("")
end
GW.AddForProfiling("battlegrounds", "SM_onEvent", SM_onEvent)

local function pvpHud_onEvent(self, event)
    local _, _, _, _, _, _, _, mapID, _ = GetInstanceInfo()

    GW.Debug("pvp instance: ", mapID)
    
    if bgs[mapID] ~= nil then
        pointsAlliance = 0
        pointsHorde = 0
        activeBg = mapID
        activeMap = GetBestMapForUnit("player")
        UIWidgetTopCenterContainerFrame:Hide()

        GwBattleGroundScores:SetScript("OnEvent", bgs[mapID]["OnEvent"])

        GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
        GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_WORLD")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_INDOORS")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        GwBattleGroundScores:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
        GwBattleGroundScores:RegisterEvent("LFG_ROLE_CHECK_DECLINED")
        GwBattleGroundScores:RegisterEvent("LFG_ROLE_CHECK_SHOW")
        GwBattleGroundScores:RegisterEvent("LFG_READY_CHECK_DECLINED")
        GwBattleGroundScores:RegisterEvent("LFG_READY_CHECK_SHOW")
        GwBattleGroundScores:RegisterEvent("UPDATE_UI_WIDGET")
        
        GwBattleGroundScores:Show()
    else
        GwBattleGroundScores:UnregisterAllEvents()
        GwBattleGroundScores:Hide()
        UIWidgetTopCenterContainerFrame:Show()
    end
end
GW.AddForProfiling("battlegrounds", "pvpHud_onEvent", pvpHud_onEvent)

local function LoadBattlegrounds()
    bgs = {
        [529] = { --Arathi
            ["OnEvent"] = AB_onEvent,
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
            ["OnEvent"] = AB_onEvent,
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
            ["OnEvent"] = AB_onEvent,
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
        [727] = { --SilvershardMines
            ["OnEvent"] = OnlyPoints_onEvent
        },
        [1803] = { --SeethingShore
            ["OnEvent"] = OnlyPoints_onEvent
        }--,
        --[726] = {
            --["OnEvent"] = OnlyPoints_onEvent
        --}
        ,
        [998] = { --TempleOfKotmogu
            ["OnEvent"] = AB_onEvent,
            ["icons"] = {}
        },
        [761] = { --Gilneas
            ["OnEvent"] = AB_onEvent,
            ["icons"] = {
                [26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                [27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                [28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                [29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26},
                [30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  ["normalState"] = 26}
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
