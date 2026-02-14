local _, GW = ...
local FACTION_COLOR = GW.FACTION_COLOR

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

function BattlegroundHudMixin:GetPoints(widget)
    local widgetID = widget and widget.widgetID
    if widgetID then
        local info = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
        if info then
            self.scoreRight:SetText(info.leftBarValue or self.scoreRight:GetText())
            self.scoreLeft:SetText(info.rightBarValue or self.scoreLeft:GetText())
            return info.rightBarValue ~= nil
        end
    end
    return false
end

function BattlegroundHudMixin:PointsAndPoiOnEvent(event, ...)
    if not self.activeBgId or self.activeBgId == 0 then return end

    if event == "UPDATE_UI_WIDGET" then
       if not self:GetPoints(...) then return end
    end

    if not self.hasTimer then
        self.timer:SetText("")
    end

    self.poiList = GetAreaPOIsForPlayerByMapIDCached(self.activeBgId)
    self.landMarkFramePool:ReleaseAll()

    local counter = 0
    for i = 1, #self.poiList do
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(self.activeBgId, self.poiList[i])
        if poiInfo and poiInfo.atlasName then
            local atlas = C_Texture.GetAtlasInfo(poiInfo.atlasName)
            local f = self.landMarkFramePool:Acquire()
            f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", 36 * counter + 18, self.hasTimer and 32 or 45)
            f:SetIconAtlas(atlas)
            f:Show()
            counter = counter + 1
        elseif poiInfo and poiInfo.textureIndex then
            local f = self.landMarkFramePool:Acquire()
            f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", 36 * counter + 18, self.hasTimer and 32 or 45)
            f:SetIcon(poiInfo.textureIndex)
            f:Show()
            counter = counter + 1
            if poiInfo.textureIndex == 0 then
                for y = 1, 5 do
                    if GW.UnitExists("arena" .. y) then
                        local classificationFaction = PvPClassificationFaction[UnitPvpClassification("arena" .. y)]
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
    end
    self.MID:SetWidth(36 * counter)
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
        self.landMarkFramePool:ReleaseAll()
        local counter = 0
        for i = 1, 5 do
            if GW.UnitExists("arena" .. i)  then
                local f = self.landMarkFramePool:Acquire()
                f:SetPoint("CENTER", self.MID, "BOTTOMLEFT", (36) * (counter) + 18, self.hasTimer and 32 or 45)

                local classificationFaction = PvPClassificationFaction[UnitPvpClassification("arena" .. i)]
                if classificationFaction == "H" then
                    f.IconBackground:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
                elseif classificationFaction == "A" then
                    f.IconBackground:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)
                else
                    f.IconBackground:SetVertexColor(1, 1, 1)
                end
                f:Show()
                counter = counter + 1
            end
        end
        self.MID:SetWidth(36 * counter)
    end
end

local function OnEvent(self, event)
    local playerInstanceMapId = select(8, GetInstanceInfo())
    if self.bgs[playerInstanceMapId] then
        -- check if we are in the same BG or if we directly join from another BG. In that case we need to reset the score OR if we joind a new BG
        if (self.battlegroundHud.activeBgId > 0 and self.battlegroundHud.activeBgId ~= playerInstanceMapId) or event == "PLAYER_ENTERING_BATTLEGROUND" then
            self.battlegroundHud.scoreRight:SetText(0)
            self.battlegroundHud.scoreLeft:SetText(0)
            self.battlegroundHud.MID:SetWidth(36)
            self.battlegroundHud.landMarkFramePool:ReleaseAll()
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
    else
        self.battlegroundHud.landMarkFramePool:ReleaseAll()
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
        self.battlegroundHud.MID:SetWidth(36)
    end
end

local function LoadBattlegrounds()
    local hudManager = CreateFrame("Frame", nil, UIParent)
    hudManager.battlegroundHud = CreateFrame("Frame", nil, UIParent, "GwBattleGroundScores")
    Mixin(hudManager.battlegroundHud, BattlegroundHudMixin)

    hudManager.bgs = {
        [529] = { --Arathi
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {
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
        },
        [1681] = { --Arathi
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {
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
        },
        [2107] = { --Arathi
            OnEvent = BattlegroundHudMixin.PointsAndPoiOnEvent,
            icons = {
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

    hudManager.battlegroundHud.leftFlag:SetVertexColor(FACTION_COLOR[1].r, FACTION_COLOR[1].g, FACTION_COLOR[1].b)
    hudManager.battlegroundHud.rightFlag:SetVertexColor(FACTION_COLOR[2].r, FACTION_COLOR[2].g, FACTION_COLOR[2].b)

    hudManager.battlegroundHud.scoreLeft:SetFont(UNIT_NAME_FONT, 30)
    hudManager.battlegroundHud.scoreLeft:SetShadowColor(0, 0, 0, 1)
    hudManager.battlegroundHud.scoreLeft:SetShadowOffset(1, -1)

    hudManager.battlegroundHud.scoreRight:SetFont(UNIT_NAME_FONT, 30)
    hudManager.battlegroundHud.scoreRight:SetShadowColor(0, 0, 0, 1)
    hudManager.battlegroundHud.scoreRight:SetShadowOffset(1, -1)

    hudManager.battlegroundHud.timer:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    hudManager.battlegroundHud.timer:SetShadowColor(0, 0, 0, 1)
    hudManager.battlegroundHud.timer:SetShadowOffset(1, -1)

    hudManager.battlegroundHud.landMarkFramePool = CreateFramePool("Frame", hudManager.battlegroundHud, "GwBattleLandMarkFrame", ResetLandMark)
    hudManager.battlegroundHud.activeBgId = 0

    hudManager:RegisterEvent("PLAYER_JOINED_PVP_MATCH")
    hudManager:RegisterEvent("PLAYER_ENTERING_WORLD")
    hudManager:SetScript("OnEvent", OnEvent)
end
GW.LoadBattlegrounds = LoadBattlegrounds
