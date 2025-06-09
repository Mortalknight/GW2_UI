local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AddToClique = GW.AddToClique
local bossFrames = {}

GwBossFrameMixin = CreateFromMixins(GwObjectivesUnitFrameMixin)

function GwBossFrameMixin:UpdateRaidMarkers()
    local index = GetRaidTargetIndex(self.unit)
    if index then
        self.marker:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. index)
        self.marker:Show()
        self.icon:Hide()
    else
        self.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
        self.icon:Show()
        self.marker:Hide()
    end
end

function GwBossFrameMixin:UpdateHealthbarColor()
    local unitReaction = UnitReaction(self.unit, "player")
    local nameColor = (unitReaction and GW.FACTION_BAR_COLORS[unitReaction]) or RAID_CLASS_COLORS.PRIEST

    if unitReaction then
        if unitReaction <= 3 then nameColor = GW.COLOR_FRIENDLY[2] end -- Feindlich
        if unitReaction >= 5 then nameColor = GW.COLOR_FRIENDLY[1] end -- Freundlich
    end

    if UnitIsTapDenied(self.unit) then
        nameColor = { r = 159 / 255, g = 159 / 255, b = 159 / 255 }
    end
    self.health:SetStatusBarColor(nameColor.r, nameColor.g, nameColor.b, 1)
end

function GwBossFrameMixin:OnShow()
    local compassData = {
        TYPE    = "BOSS",
        ID      = "boss_unknown",
        QUESTID = "unknown",
        COMPASS = false,
        DESC    = "",
        MAPID   = nil,
        X       = nil,
        Y       = nil,
        COLOR   = TRACKER_TYPE_COLOR.BOSS,
        TITLE   = UnitName(self.unit)
    }
    GwObjectivesNotification:AddNotification(compassData)

    self:UpdateName()
    self:UpdateHealth()
    self:UpdatePower()
    self:UpdateRaidMarkers()
    self:UpdateHealthbarColor()
    self.container:UpdateBossFrameHeight()

    if self.eventless then
        self:SetScript("OnUpdate", self.OnUpdate)
    end
end

function GwBossFrameMixin:OnHide()
    self.container:UpdateBossFrameHeight()
    if self.id == 1 then
        GwObjectivesNotification:RemoveNotificationOfType("BOSS")
    end

    if self.eventless then
        self:SetScript("OnUpdate", nil)
    end
end

function GwBossFrameMixin:OnEvent(event, unit)
    if GW.IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH", "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UNIT_NAME_UPDATE", "UNIT_FACTION") then
        if unit ~= self.unit then return end
    end
    if not self:IsShown() then return end

    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        self:UpdateHealth()
    elseif event == "UNIT_MAXPOWER" or event == "UNIT_POWER_FREQUENT" then
        self:UpdatePower()
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:UpdateName()
    elseif event == "RAID_TARGET_UPDATE" then
        self:UpdateRaidMarkers()
    elseif event == "UNIT_FACTION" then
        self:UpdateHealthbarColor()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "UNIT_NAME_UPDATE" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        self:UpdateName()
        self:UpdateHealth()
        self:UpdatePower()
        self:UpdateRaidMarkers()
        self:UpdateHealthbarColor()
        self.container:UpdateBossFrameHeight()
    end
end

function GwBossFrameMixin:OnUpdate(elapsed)
    if self.totalElapsed > 0 then
        self.totalElapsed = self.totalElapsed - elapsed
        return
    end
    self.totalElapsed = 0.25
    if not UnitExists(self.unit) then
        return
    end

    self:UpdateName()
    self:UpdateHealth()
    self:UpdatePower()
    self:UpdateRaidMarkers()
    self:UpdateHealthbarColor()
    self.container:UpdateBossFrameHeight()
end

GwObjectivesBossContainerMixin = {}

function GwObjectivesBossContainerMixin:UpdateBossFrameHeight()
    local lastIndex = 0
    local totalHeight = 0

    for index, frame in pairs(bossFrames) do
        if frame:IsShown() then
            lastIndex = index
        end
    end

    for index, frame in pairs(bossFrames) do
        if index <= lastIndex then
            totalHeight = totalHeight + frame:GetHeight()
        end
    end

    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(lastIndex > 0 and totalHeight or 1)
end

function GwObjectivesBossContainerMixin:SetUpFramePosition()
    local yOffset = GW.settings.SHOW_QUESTTRACKER_COMPASS and 70 or 0

    for idx, frame in pairs(bossFrames) do
        if idx == 1 then
            frame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -yOffset)
        else
            frame:SetPoint("TOPRIGHT", bossFrames[idx - 1], "BOTTOMRIGHT", 0, 0)
        end
    end
end

function GwObjectivesBossContainerMixin:RegisterFrame(i, eventless)
    local bossFrame = CreateFrame("Button", "GwBossFrame" .. i, GwQuestTracker, "GwQuestTrackerBossFramePingableTemplate")
    local unit = "boss" .. i

    bossFrame.id = i
    bossFrame.unit = unit
    bossFrame.guid = UnitGUID(unit)
    bossFrame.container = self
    bossFrame.eventless = eventless

    bossFrame:SetAttribute("unit", unit)
    bossFrame:SetAttribute("*type1", "target")
    bossFrame:SetAttribute("*type2", "togglemenu")

    AddToClique(bossFrame)
    RegisterUnitWatch(bossFrame)
    bossFrame:EnableMouse(true)
    bossFrame:RegisterForClicks("AnyDown")

    bossFrame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    bossFrame.name:SetShadowOffset(1, -1)
    bossFrame.marker:Hide()

    bossFrame.icon:SetVertexColor(TRACKER_TYPE_COLOR.BOSS.r, TRACKER_TYPE_COLOR.BOSS.g, TRACKER_TYPE_COLOR.BOSS.b)

    if not eventless then
        bossFrame:RegisterEvent("RAID_TARGET_UPDATE")
        bossFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        bossFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        bossFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
        bossFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
        bossFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
        bossFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
        bossFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
        bossFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
        bossFrame:RegisterUnitEvent("UNIT_FACTION", unit)

        bossFrame:SetScript("OnEvent", bossFrame.OnEvent)
    else
        bossFrame.totalElapsed = 0.15
    end

    bossFrame:SetScript("OnShow", bossFrame.OnShow)
    bossFrame:SetScript("OnHide", bossFrame.OnHide)
    bossFrame:SetScript("OnEnter", bossFrame.OnEnter)
    bossFrame:SetScript("OnLeave", bossFrame.OnLeave)

    return bossFrame
end

function GwObjectivesBossContainerMixin:InitModule()
    local eventless = false
    for i = 1, 10 do
        if i >= 6 then eventless = true end
        bossFrames[i] = self:RegisterFrame(i, eventless)
    end
    self:SetUpFramePosition()
    C_Timer.After(0.01, function() self:UpdateBossFrameHeight() end)
end
