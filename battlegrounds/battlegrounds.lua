local _, GW = ...
local FACTION_COLOR = GW.FACTION_COLOR
local AddToAnimation = GW.AddToAnimation

local bgs = {}

local activeBg = 0

local function getPointsNum(t)
    local _, score, max = string.match(t, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)")

    return score, max
end

local function capStateChanged(self)
    local fnScale = function(prog)
        self:SetScale(prog)
    end
    AddToAnimation(self:GetName(), 2, 1, GetTime(), 0.5, fnScale)
end

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

local function setIcon(self, icon)
    if self.savedIconIndex ~= icon then
        capStateChanged(self)
    end
    self.savedIconIndex = icon

    if iconOverrider(self, icon) then
        return
    end

    local x1, x2, y1, y2 = GetPOITextureCoords(icon)
    self.icon:SetTexture("Interface\\Minimap\\POIIcons")
    self.icon:SetTexCoord(x1, x2, y1, y2)
end

local function LandMarkFrameSetPoint_noTimer(i)
    _G["GwBattleLandMarkFrame" .. i]:SetPoint("CENTER", GwBattleGroundScores.MID, "BOTTOMLEFT", (36) * (i - 1) + 18, 45)
end

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

local function AB_onEvent(self, event, ...)
    local _, _, _, text, _, _, _, _, _, _, _, _ = GetWorldStateUIInfo(1)
    local _, _, _, text2, _, _, _, _, _, _, _, _ = GetWorldStateUIInfo(2)

    if text2 == nil or text == nil then
        return
    end

    local current, _ = getPointsNum(text)
    local current2, _ = getPointsNum(text2)

    self.scoreRight:SetText(current)

    self.scoreLeft:SetText(current2)

    self.timer:SetText("")

    for i = 1, GetNumMapLandmarks() do
        local _, _, _, icon = GetMapLandmarkInfo(i)
        local f = getLandMarkFrame(i)
        LandMarkFrameSetPoint_noTimer(i)

        setIcon(f, icon)

        GwBattleGroundScores.MID:SetWidth(36 * i)
    end
    for i = 1, 5 do
        if _G["AlwaysUpFrame" .. i] ~= nil then
            _G["AlwaysUpFrame" .. i]:Hide()
        end
    end
end

local function pvpHud_onEvent(self, event)
    local _, _, _, _, _, _, _, mapID, _ = GetInstanceInfo()

    if bgs[mapID] ~= nil then
        activeBg = mapID
        GwBattleGroundScores:SetScript("OnEvent", bgs[mapID]["OnEvent"])

        GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        GwBattleGroundScores:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

        GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_WORLD")

        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_INDOORS")
        GwBattleGroundScores:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        GwBattleGroundScores:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

        GwBattleGroundScores:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")

        GwBattleGroundScores:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
        GwBattleGroundScores:RegisterEvent("LFG_ROLE_CHECK_DECLINED")
        GwBattleGroundScores:RegisterEvent("LFG_ROLE_CHECK_SHOW")
        GwBattleGroundScores:RegisterEvent("LFG_READY_CHECK_DECLINED")
        GwBattleGroundScores:RegisterEvent("LFG_READY_CHECK_SHOW")

        GwBattleGroundScores:Show()
    else
        GwBattleGroundScores:UnregisterAllEvents()
        GwBattleGroundScores:Hide()
    end
end

local function LoadBattlegrounds()
    bgs = {
        [529] = {
            ["OnEvent"] = AB_onEvent,
            ["icons"] = {
                [16] = {[1] = 0.25, [2] = 0.50, [3] = 0, [4] = 0.5, ["normalState"] = 16},
                [17] = {[1] = 0.25, [2] = 0.50, [3] = 0, [4] = 0.5, ["normalState"] = 16},
                [18] = {[1] = 0.25, [2] = 0.50, [3] = 0, [4] = 0.5, ["normalState"] = 16},
                [19] = {[1] = 0.25, [2] = 0.50, [3] = 0, [4] = 0.5, ["normalState"] = 16},
                [20] = {[1] = 0.25, [2] = 0.50, [3] = 0, [4] = 0.5, ["normalState"] = 16},
                [21] = {[1] = 0, [2] = 0.25, [3] = 0, [4] = 0.5, ["normalState"] = 21},
                [22] = {[1] = 0, [2] = 0.25, [3] = 0, [4] = 0.5, ["normalState"] = 21},
                [23] = {[1] = 0, [2] = 0.25, [3] = 0, [4] = 0.5, ["normalState"] = 21},
                [24] = {[1] = 0, [2] = 0.25, [3] = 0, [4] = 0.5, ["normalState"] = 21},
                [25] = {[1] = 0, [2] = 0.25, [3] = 0, [4] = 0.5, ["normalState"] = 21},
                [26] = {[1] = 0, [2] = 0.25, [3] = 0.5, [4] = 1, ["normalState"] = 26},
                [27] = {[1] = 0, [2] = 0.25, [3] = 0.5, [4] = 1, ["normalState"] = 26},
                [28] = {[1] = 0, [2] = 0.25, [3] = 0.5, [4] = 1, ["normalState"] = 26},
                [29] = {[1] = 0, [2] = 0.25, [3] = 0.5, [4] = 1, ["normalState"] = 26},
                [30] = {[1] = 0, [2] = 0.25, [3] = 0.5, [4] = 1, ["normalState"] = 26},
                [31] = {[1] = 0.75, [2] = 1, [3] = 0, [4] = 0.5, ["normalState"] = 31},
                [32] = {[1] = 0.75, [2] = 1, [3] = 0, [4] = 0.5, ["normalState"] = 31},
                [33] = {[1] = 0.75, [2] = 1, [3] = 0, [4] = 0.5, ["normalState"] = 31},
                [34] = {[1] = 0.75, [2] = 1, [3] = 0, [4] = 0.5, ["normalState"] = 31},
                [35] = {[1] = 0.75, [2] = 1, [3] = 0, [4] = 0.5, ["normalState"] = 31},
                [36] = {[1] = 0.5, [2] = 0.75, [3] = 0, [4] = 0.5, ["normalState"] = 36},
                [37] = {[1] = 0.5, [2] = 0.75, [3] = 0, [4] = 0.5, ["normalState"] = 36},
                [38] = {[1] = 0.5, [2] = 0.75, [3] = 0, [4] = 0.5, ["normalState"] = 36},
                [39] = {[1] = 0.5, [2] = 0.75, [3] = 0, [4] = 0.5, ["normalState"] = 36},
                [40] = {[1] = 0.5, [2] = 0.75, [3] = 0, [4] = 0.5, ["normalState"] = 36}
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
