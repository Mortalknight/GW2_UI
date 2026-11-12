---@class GW2
local GW = select(2, ...)

local updateCap = 1 / 5
local BattlegroundHudMixin = {}
GwBattlegroundLandmarkMixin = {}

local PvPClassificationFaction = {
    [Enum.PvPUnitClassification.FlagCarrierHorde] = "A",
    [Enum.PvPUnitClassification.FlagCarrierAlliance] = "H",
    [Enum.PvPUnitClassification.FlagCarrierNeutral] = "N",
    [Enum.PvPUnitClassification.CartRunnerHorde] = "A",
    [Enum.PvPUnitClassification.CartRunnerAlliance] = "H"
    --[Enum.PvPUnitClassification.OrbCarrierBlue] = "orb",
    --[Enum.PvPUnitClassification.OrbCarrierGreen] = "orb",
    --[Enum.PvPUnitClassification.OrbCarrierOrange] = "orb",
    --[Enum.PvPUnitClassification.OrbCarrierPurple] = "orb"
}

local ARENA_UNITS = {"arena1", "arena2", "arena3", "arena4", "arena5"}

local function ResetLandMark(_, self)
    self:ClearAllPoints()
    self:Hide()
    self.IconBackground:SetVertexColor(1, 1, 1)
    self.icon:SetTexCoord(0, 1, 0, 1)
    self.icon:SetTexture(nil)
    self.icon:SetSize(20, 20)
    self.savedIconIndex = nil
end

function GwBattlegroundLandmarkMixin:CapStateChanged()
    local fnScale = function(prog)
        self:SetScale(prog)
    end
    GW.AddToAnimation(self:GetDebugName(), 2, 1, GetTime(), 0.5, fnScale)
end

function GwBattlegroundLandmarkMixin:SetIconAtlas(atlas)
    if not atlas then return end
    if self.savedIconIndex ~= atlas.file then
        self:CapStateChanged()
    end
    self.savedIconIndex = atlas.file

    local x1, x2, y1, y2 = atlas.leftTexCoord, atlas.rightTexCoord, atlas.topTexCoord, atlas.bottomTexCoord
    self.icon:SetTexture(atlas.file)
    self.icon:SetTexCoord(x1, x2, y1, y2)
    self.icon:SetSize(20, 20)
end

function GwBattlegroundLandmarkMixin:SetIcon(icon)
    if self.savedIconIndex ~= icon then
        self:CapStateChanged()
    end
    self.savedIconIndex = icon

    if self:IconOverrider(icon) then
        return
    end

    local x1, x2, y1, y2 = C_Minimap.GetPOITextureCoords(icon)
    self.icon:SetTexture("Interface/Minimap/POIIcons")
    self.icon:SetTexCoord(x1, x2, y1, y2)
    self.icon:SetSize(20, 20)
end

function GwBattlegroundLandmarkMixin:IconOverrider(icon)
    local parent = self:GetParent()
    local bg = parent and parent.activeBg
    if not bg or not bg.icons or not bg.icons[icon] then return false end

    local x1, x2, y1, y2 = bg.icons[icon][1], bg.icons[icon][2], bg.icons[icon][3], bg.icons[icon][4]
    self.icon:SetTexture("Interface/AddOns/GW2_UI/Textures/battleground/objective-icons.png")
    self.icon:SetTexCoord(0.25, 0.5, 0, 1)
    self.icon:SetTexCoord(x1, x2, y1, y2)
    self.icon:SetSize(32, 32)

    local iconState = icon - bg.icons[icon].normalState
    if iconState == 0 then -- no cap
        self.IconBackground:SetVertexColor(1, 1, 1)
        self.icon:SetVertexColor(0, 0, 0)
    elseif iconState == 1 then
        self.IconBackground:SetVertexColor(1, 1, 1)
        self.icon:SetVertexColor(GW.Colors.FactionColors.Alliance:GetRGB())
    elseif iconState == 2 then
        self.IconBackground:SetVertexColor(GW.Colors.FactionColors.Alliance:GetRGB())
        self.icon:SetVertexColor(0, 0, 0)
    elseif iconState == 3 then
        self.IconBackground:SetVertexColor(1, 1, 1)
        self.icon:SetVertexColor(GW.Colors.FactionColors.Horde:GetRGB())
    elseif iconState == 4 then
        self.IconBackground:SetVertexColor(GW.Colors.FactionColors.Horde:GetRGB())
        self.icon:SetVertexColor(0, 0, 0)
    end

    return true
end

-- bases and flag carriers share the row, so the width follows both counts
local function UpdateMidWidth(self)
    self.MID:SetWidth(36 * math.max((self.poiCount or 0) + (self.flagCount or 0), 1))
end

-- the side a text score belongs to, its carrier shows in the faction color
local TEXT_SCORE_COLORS = {scoreLeft = GW.Colors.FactionColors.Horde, scoreRight = GW.Colors.FactionColors.Alliance}

function BattlegroundHudMixin:UpdateTextFlags()
    self.flagFramePool:ReleaseAll()
    local counter = 0
    for _, side in ipairs({"scoreLeft", "scoreRight"}) do
        if self.flagCarriers[side] then
            local f = self.flagFramePool:Acquire()
            f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", 36 * (counter + (self.poiCount or 0)) + 18, self.hasTimer and 32 or 45)
            f.IconBackground:SetVertexColor(TEXT_SCORE_COLORS[side]:GetRGB())
            f:Show()
            counter = counter + 1
        end
    end
    self.flagCount = counter
    UpdateMidWidth(self)
end

-- a thin line below the score fills up to the points a side needs to win, both lines grow towards the middle;
-- the hover shows the numbers, only the mouse motion is taken so clicks reach the world
local PROGRESS_WIDTH = 92
-- the estimate takes the points of the last seconds, so it follows a lost or won base after a short while
local ESTIMATE_WINDOW = 20
local ESTIMATE_MIN_SPAN = 4
-- points that come in steady ticks; single flag captures would give a jumping estimate
local ESTIMATE_MIN_TICKS = 3

local function ScoreProgress_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(self.factionName, self.color:GetRGB())
    GameTooltip:AddLine(self.value .. " / " .. self.max, HIGHLIGHT_FONT_COLOR:GetRGB())
    if self.rate and self.rate > 0 and self.value < self.max then
        GameTooltip:AddLine(format(GW.L["Wins in about %s"], SecondsToClock((self.max - self.value) / self.rate)), GW.Colors.SkinColors.SubText:GetRGB())
    end
    GameTooltip:Show()
end

-- points per second over the last seconds; nil until enough time passed, reset when the line hides
local function UpdateRate(self, value)
    local now = GetTime()
    self.samples = self.samples or {}
    local samples = self.samples
    tinsert(samples, {time = now, value = value})
    while #samples > 1 and now - samples[1].time > ESTIMATE_WINDOW do
        tremove(samples, 1)
    end
    local ticks = 0
    for i = 2, #samples do
        if samples[i].value ~= samples[i - 1].value then
            ticks = ticks + 1
        end
    end
    local span = now - samples[1].time
    self.rate = span >= ESTIMATE_MIN_SPAN and ticks >= ESTIMATE_MIN_TICKS and (value - samples[1].value) / span or nil
end

local function ScoreProgress_SetProgress(self, value, max)
    -- secret values can only be shown, not computed with
    if GW.IsSecretValue(value) or GW.IsSecretValue(max) or not value or not max or max <= 0 then
        self:Hide()
        return
    end
    self.value, self.max = value, max
    UpdateRate(self, value)
    local width = PROGRESS_WIDTH * math.min(value / max, 1)
    if width > 0 then
        self.fill:SetWidth(width)
    end
    self.fill:SetShown(width > 0)
    self:Show()
    if GameTooltip:IsOwned(self) then
        ScoreProgress_OnEnter(self)
    end
end

local function CreateScoreProgress(score, fromRight, factionName, color)
    local progress = CreateFrame("Frame", nil, score:GetParent())
    progress:SetAllPoints(score)
    progress:SetMouseMotionEnabled(true)
    progress:Hide()
    progress.factionName, progress.color = factionName, color
    progress.SetProgress = ScoreProgress_SetProgress
    progress:SetScript("OnEnter", ScoreProgress_OnEnter)
    progress:SetScript("OnLeave", GameTooltip_Hide)
    progress:SetScript("OnHide", function(self)
        self.samples, self.rate = nil, nil
    end)

    local track = progress:CreateTexture(nil, "ARTWORK")
    track:SetColorTexture(1, 1, 1)
    track:SetVertexColor(GW.Colors.SkinColors.StatusBarTrack:GetRGBA())
    track:SetSize(PROGRESS_WIDTH, 2)
    track:SetPoint("TOP", score, "BOTTOM", 0, 10)

    progress.fill = progress:CreateTexture(nil, "ARTWORK", nil, 1)
    progress.fill:SetColorTexture(1, 1, 1)
    -- the flag below already has the faction color, the line takes the color of the score, a bit muted
    progress.fill:SetVertexColor(score:GetTextColor())
    progress.fill:SetAlpha(0.7)
    progress.fill:SetHeight(2)
    progress.fill:SetPoint(fromRight and "RIGHT" or "LEFT", track)

    return progress
end

function BattlegroundHudMixin:GetPoints(widget)
    local widgetID = widget and widget.widgetID
    local flagScore = self.activeBg and self.activeBg.textScores and self.activeBg.textScores[widgetID]
    if flagScore then
        local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(widgetID)
        local score, goal = info and info.text and info.text:match("(%d+)/%s*(%d+)")
        if not score then return false end
        self[flagScore]:SetText(score)
        self[flagScore .. "Progress"]:SetProgress(tonumber(score), tonumber(goal))
        -- the extra icon of the widget is the enemy flag this side carries
        local carries = info.state >= Enum.IconAndTextWidgetState.ShownWithDynamicIconFlashing
        if self.flagCarriers[flagScore] ~= carries then
            self.flagCarriers[flagScore] = carries
            self:UpdateTextFlags()
        end
        return true
    end
    if widgetID then
        local info = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
        if info then
            self.scoreRight:SetText(info.leftBarValue or self.scoreRight:GetText())
            self.scoreLeft:SetText(info.rightBarValue or self.scoreLeft:GetText())
            self.scoreRightProgress:SetProgress(info.leftBarValue, info.leftBarMax)
            self.scoreLeftProgress:SetProgress(info.rightBarValue, info.rightBarMax)
            return info.rightBarValue ~= nil
        end
    end
    return false
end

-- the faction whose player carries the flag, "H" or "A"; the first carrier found counts
local function GetFlagCarrierFaction()
    for _, unit in ipairs(ARENA_UNITS) do
        if GW.UnitExists(unit) then
            local faction = PvPClassificationFaction[UnitPvpClassification(unit)]
            if faction == "H" or faction == "A" then
                return faction
            end
        end
    end
end

function BattlegroundHudMixin:PointsAndPoiOnEvent(event, ...)
    if not self.activeBgId or self.activeBgId == 0 then return end

    if event == "UPDATE_UI_WIDGET" then
       if not self:GetPoints(...) then return end
    end

    if not self.hasTimer then
        self.timer:SetText("")
    end

    -- the poi api wants the ui map id, activeBgId is the instance id the battleground is keyed by; not blizzards
    -- cached list, it keeps the bases known on entering and is only cleared by the world map
    local mapID = C_Map.GetBestMapForUnit("player")
    self.poiList = mapID and C_AreaPoiInfo.GetAreaPOIForMap(mapID) or {}

    -- the flag (icon 0) takes the color of its carrier, a pickup alone changes no base so it is part of the signature
    local carrier
    local signature = ""
    local poiInfos = {}
    for i = 1, #self.poiList do
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, self.poiList[i])
        poiInfos[i] = poiInfo
        if poiInfo then
            if poiInfo.textureIndex == 0 then
                carrier = GetFlagCarrierFaction()
            end
            signature = signature .. (poiInfo.atlasName or poiInfo.textureIndex or "") .. (carrier or "") .. ","
        end
    end
    if signature == self.poiSignature then
        return
    end
    self.poiSignature = signature

    self.landMarkFramePool:ReleaseAll()

    -- the frames are rebuilt for every change, each base keeps its last icon so only the one that changed animates
    local previousIcons = self.poiIcons or {}
    self.poiIcons = {}

    local counter = 0
    for i = 1, #self.poiList do
        local poiInfo = poiInfos[i]
        local poiID = self.poiList[i]
        if poiInfo and poiInfo.atlasName then
            local atlas = C_Texture.GetAtlasInfo(poiInfo.atlasName)
            local f = self.landMarkFramePool:Acquire()
            f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", 36 * counter + 18, self.hasTimer and 32 or 45)
            f.savedIconIndex = previousIcons[poiID]
            f:SetIconAtlas(atlas)
            self.poiIcons[poiID] = f.savedIconIndex
            f:Show()
            counter = counter + 1
        elseif poiInfo and poiInfo.textureIndex then
            local f = self.landMarkFramePool:Acquire()
            f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", 36 * counter + 18, self.hasTimer and 32 or 45)
            f.savedIconIndex = previousIcons[poiID]
            f:SetIcon(poiInfo.textureIndex)
            self.poiIcons[poiID] = f.savedIconIndex
            f:Show()
            counter = counter + 1
            if poiInfo.textureIndex == 0 and carrier then
                f.IconBackground:SetVertexColor((carrier == "H" and GW.Colors.FactionColors.Horde or GW.Colors.FactionColors.Alliance):GetRGB())
            end
        end
    end
    self.poiCount = counter
    UpdateMidWidth(self)
end

function BattlegroundHudMixin:OnlyPointsOnEvent(event, ...)
    if not self.activeBgId or self.activeBgId == 0 then return end

    if event == "UPDATE_UI_WIDGET" then
        if not self:GetPoints(...) then return end
    end

    if not self.hasTimer then
        self.timer:SetText("")
    end
end

function BattlegroundHudMixin:TimerFlagOnUpdate(elapsed)
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
        local signature = ""
        for i = 1, 5 do
            local unit = ARENA_UNITS[i]
            if GW.UnitExists(unit) then
                signature = signature .. i .. (PvPClassificationFaction[UnitPvpClassification(unit)] or "N")
            end
        end
        if signature == self.flagSignature then
            return
        end
        self.flagSignature = signature

        self.flagFramePool:ReleaseAll()
        local counter = 0
        for i = 1, 5 do
            local unit = ARENA_UNITS[i]
            if GW.UnitExists(unit) then
                local f = self.flagFramePool:Acquire()
                f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", 36 * (counter + (self.poiCount or 0)) + 18, self.hasTimer and 32 or 45)

                local classificationFaction = PvPClassificationFaction[UnitPvpClassification(unit)]
                if classificationFaction == "H" then
                    f.IconBackground:SetVertexColor(GW.Colors.FactionColors.Horde:GetRGB())
                elseif classificationFaction == "A" then
                    f.IconBackground:SetVertexColor(GW.Colors.FactionColors.Alliance:GetRGB())
                else
                    f.IconBackground:SetVertexColor(1, 1, 1)
                end
                f:Show()
                counter = counter + 1
            end
        end
        self.flagCount = counter
        UpdateMidWidth(self)
    end
end

local function RefreshFromWidgets(hud)
    local setID = C_UIWidgetManager.GetTopCenterWidgetSetID()
    if setID then
        for _, widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(setID)) do
            if widget.widgetType == Enum.UIWidgetVisualizationType.DoubleStatusBar or widget.widgetType == Enum.UIWidgetVisualizationType.IconAndText then
                hud:GetPoints(widget)
            end
        end
    end
    if hud.activeBg and hud.activeBg.OnEvent then
        hud.activeBg.OnEvent(hud, "GW_REFRESH")
    end
end

local function OnEvent(self, event)
    local playerInstanceMapId = select(8, GetInstanceInfo())
    if self.bgs[playerInstanceMapId] then
        -- check if we are in the same BG or if we directly join from another BG. In that case we need to reset the score OR if we joind a new BG
        if (self.battlegroundHud.activeBgId > 0 and self.battlegroundHud.activeBgId ~= playerInstanceMapId) or event == "PLAYER_ENTERING_BATTLEGROUND" then
            self.battlegroundHud.scoreRight:SetText(0)
            self.battlegroundHud.scoreLeft:SetText(0)
            self.battlegroundHud.scoreLeftProgress:Hide()
            self.battlegroundHud.scoreRightProgress:Hide()
            self.battlegroundHud.MID:SetWidth(36)
            self.battlegroundHud.landMarkFramePool:ReleaseAll()
            self.battlegroundHud.flagFramePool:ReleaseAll()
            self.battlegroundHud.poiCount = 0
            self.battlegroundHud.flagCount = 0
            self.battlegroundHud.flagSignature = nil
            self.battlegroundHud.flagCarriers = {}
            self.battlegroundHud.poiSignature = nil
            self.battlegroundHud:SetScript("OnEvent", nil)
            self.battlegroundHud:SetScript("OnUpdate", nil)
        end
        self.battlegroundHud.activeBg = self.bgs[playerInstanceMapId]
        self.battlegroundHud.activeBgId = playerInstanceMapId
        UIWidgetTopCenterContainerFrame:Hide()
        self.battlegroundHud:SetScript("OnEvent",  self.battlegroundHud.activeBg.OnEvent)
        if  self.battlegroundHud.activeBg.OnUpdate then
            self.battlegroundHud:SetScript("OnUpdate",  self.battlegroundHud.activeBg.OnUpdate)
            self.battlegroundHud.elapsedTimer = -1
        end
        self.battlegroundHud.TrackFlag =  self.battlegroundHud.activeBg.TrackFlag
        self.battlegroundHud.hasTimer =  self.battlegroundHud.activeBg.hasTimer
        self.battlegroundHud:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        self.battlegroundHud:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
        self.battlegroundHud:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.battlegroundHud:RegisterEvent("ZONE_CHANGED")
        self.battlegroundHud:RegisterEvent("ZONE_CHANGED_INDOORS")
        self.battlegroundHud:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        self.battlegroundHud:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        self.battlegroundHud:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
        self.battlegroundHud:RegisterEvent("UPDATE_UI_WIDGET")
        self.battlegroundHud:RegisterEvent("AREA_POIS_UPDATED")

        self.battlegroundHud:Show()
        RefreshFromWidgets(self.battlegroundHud)
    else
        self.battlegroundHud.landMarkFramePool:ReleaseAll()
        self.battlegroundHud.flagFramePool:ReleaseAll()
        self.battlegroundHud.poiCount = 0
        self.battlegroundHud.flagCount = 0
        self.battlegroundHud.flagSignature = nil
        self.battlegroundHud.flagCarriers = {}
        self.battlegroundHud.poiSignature = nil
        self.battlegroundHud:UnregisterAllEvents()
        self.battlegroundHud:Hide()
        self.battlegroundHud.hasTimer = false
        self.battlegroundHud.TrackFlag = false
        self.battlegroundHud.activeBg = nil
        self.battlegroundHud.activeBgId = 0
        self.battlegroundHud:SetScript("OnEvent", nil)
        self.battlegroundHud:SetScript("OnUpdate", nil)
        UIWidgetTopCenterContainerFrame:Show()
        self.battlegroundHud.scoreRight:SetText(0)
        self.battlegroundHud.scoreLeft:SetText(0)
        self.battlegroundHud.scoreLeftProgress:Hide()
        self.battlegroundHud.scoreRightProgress:Hide()
        self.battlegroundHud.MID:SetWidth(36)
    end
end

-- the three arathi instances share their bases
local ARATHI_ICONS = {
            [16] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
            [17] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
            [18] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
            [19] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
            [20] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
            [21] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  normalState = 21},
            [22] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  normalState = 21},
            [23] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  normalState = 21},
            [24] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  normalState = 21},
            [25] = {[1] = 0,    [2] = 0.25, [3] = 0,    [4] = 0.5,  normalState = 21},
            [26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    normalState = 26},
            [27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    normalState = 26},
            [28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    normalState = 26},
            [29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    normalState = 26},
            [30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,    normalState = 26},
            [31] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  normalState = 31},
            [32] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  normalState = 31},
            [33] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  normalState = 31},
            [34] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  normalState = 31},
            [35] = {[1] = 0.75, [2] = 1,    [3] = 0,    [4] = 0.5,  normalState = 31},
            [36] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  normalState = 36},
            [37] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  normalState = 36},
            [38] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  normalState = 36},
            [39] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  normalState = 36},
            [40] = {[1] = 0.5,  [2] = 0.75, [3] = 0,    [4] = 0.5,  normalState = 36}
}

local function LoadBattlegrounds()
    local hudManager = CreateFrame("Frame", nil, UIParent)
    hudManager.battlegroundHud = CreateFrame("Frame", nil, UIParent, "GwBattleGroundScores")
    Mixin(hudManager.battlegroundHud, BattlegroundHudMixin)

    hudManager.bgs = {
        [529] = { --Arathi
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = ARATHI_ICONS
        },
        [1681] = { --Arathi
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = ARATHI_ICONS
        },
        [2107] = { --Arathi
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = ARATHI_ICONS
        },
        [2245] = { --Deepwind (TODO: Add cart carrier to top)
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {}
        },
        [727] = { --SilvershardMines
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent
        },
        [30] = { --Alterac
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent
        },
        [1803] = { --SeethingShore
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent
        },
        [628] = { --Isle Of Conquest
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent
        },
        [998] = { --TempleOfKotmogu (TODO: Add orb carrier to top)
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {}
        },
        [566] = { --EyeOfTheStorm test
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {}
        },
        [968] = { --EyeOfTheStorm test
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {}
        },
        [726] = { --TwinPeaks
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            OnUpdate = BattlegroundHudMixin.TimerFlagOnUpdate,
            hasTimer = true,
            TrackFlag = true
        },
        [489] = { --Warsong Gulch, the classic instance forever uses
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent,
            -- each side shows its flags as "1/3" text and its carrier as icon instead of a double status bar and
            -- arena units, forever gives the carriers no pvp classification
            textScores = {[1891] = "scoreRight", [1892] = "scoreLeft"},
        },
        [2106] = { --Warsong
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent,
            OnUpdate = BattlegroundHudMixin.TimerFlagOnUpdate,
            hasTimer = true,
            TrackFlag = true
        },
        [2656] = { --Warsong
            OnEvent = BattlegroundHudMixin.OnlyPointsOnEvent,
            OnUpdate = BattlegroundHudMixin.TimerFlagOnUpdate,
            TrackFlag = true
        },
        [761] = { --Gilneas
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {
                --[8] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 8}, --Tower (need Icon)
                --[9] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 8},
                --[10] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 8},
                --[11] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 8},
                --[12] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 8},
                --[16] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16}, --Mine
                --[17] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
                --[18] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
                --[19] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
                --[20] = {[1] = 0.25, [2] = 0.50, [3] = 0,    [4] = 0.5,  normalState = 16},
                --[26] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  normalState = 26}, --Water (need Icon)
                --[27] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  normalState = 26},
                --[28] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  normalState = 26},
                --[29] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  normalState = 26},
                --[30] = {[1] = 0,    [2] = 0.25, [3] = 0.5,  [4] = 1,  normalState = 26}
            }
        }
    }

    hudManager.battlegroundHud.leftFlag:SetVertexColor(GW.Colors.FactionColors.Horde:GetRGB())
    hudManager.battlegroundHud.rightFlag:SetVertexColor(GW.Colors.FactionColors.Alliance:GetRGB())

    hudManager.battlegroundHud.scoreLeft:SetFont(UNIT_NAME_FONT, 30)
    hudManager.battlegroundHud.scoreLeft:SetShadowColor(0, 0, 0, 1)
    hudManager.battlegroundHud.scoreLeft:SetShadowOffset(1, -1)

    hudManager.battlegroundHud.scoreRight:SetFont(UNIT_NAME_FONT, 30)
    hudManager.battlegroundHud.scoreRight:SetShadowColor(0, 0, 0, 1)
    hudManager.battlegroundHud.scoreRight:SetShadowOffset(1, -1)

    hudManager.battlegroundHud.timer:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    hudManager.battlegroundHud.scoreLeftProgress = CreateScoreProgress(hudManager.battlegroundHud.scoreLeft, true, FACTION_HORDE, GW.Colors.FactionColors.Horde)
    hudManager.battlegroundHud.scoreRightProgress = CreateScoreProgress(hudManager.battlegroundHud.scoreRight, false, FACTION_ALLIANCE, GW.Colors.FactionColors.Alliance)

    hudManager.battlegroundHud.landMarkFramePool = CreateFramePool("Frame", hudManager.battlegroundHud, "GwBattleLandMarkFrame", ResetLandMark)
    hudManager.battlegroundHud.flagFramePool = CreateFramePool("Frame", hudManager.battlegroundHud, "GwBattleLandMarkFrame", ResetLandMark)
    hudManager.battlegroundHud.poiCount = 0
    hudManager.battlegroundHud.flagCount = 0
    hudManager.battlegroundHud.activeBgId = 0
    hudManager.battlegroundHud.flagCarriers = {}

    hudManager:RegisterEvent("PLAYER_JOINED_PVP_MATCH")
    hudManager:RegisterEvent("PLAYER_ENTERING_WORLD")
    hudManager:SetScript("OnEvent", OnEvent)
end
GW.LoadBattlegrounds = LoadBattlegrounds
