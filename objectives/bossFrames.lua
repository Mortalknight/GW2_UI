local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AddToClique = GW.AddToClique
local PowerBarColorCustom = GW.PowerBarColorCustom
local GetSetting = GW.GetSetting
local bossFrames = {}

local function updateBossFrameHeight()
    local i = 0

    for k, frame in pairs(bossFrames) do
        if frame:IsShown() then
            i = k
        end
    end

    GwQuesttrackerContainerBossFrames:SetHeight(i > 0 and (35 * i) or 1)
end
GW.AddForProfiling("bossFrames", "updateBossFrameHeight", updateBossFrameHeight)

local function updateBoss_Health(self)
    local health = UnitHealth(self.unit)
    local maxHealth = UnitHealthMax(self.unit)
    local healthPrecentage = 0

    if health > 0 and maxHealth > 0 then
        healthPrecentage = health / maxHealth
    end

    self.health:SetMinMaxValues(0, maxHealth)
    self.health:SetValue(health)
    self.health.value:SetText(GW.RoundInt(healthPrecentage * 100) .. "%")
end
GW.AddForProfiling("bossFrames", "updateBoss_Health", updateBoss_Health)

local function updateBoss_Power(self)
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.power:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    else
        self.power:SetStatusBarColor(altR, altG, altB)
    end

    self.power:SetMinMaxValues(0, powerMax)
    self.power:SetValue(power)
end
GW.AddForProfiling("bossFrames", "updateBoss_Power", updateBoss_Power)

local function updateBoss_Name(self)
    local guidTarget = UnitGUID("target")
    local name = UnitName(self.unit)

    self.name:SetText(name)
    self.guid = UnitGUID(self.unit)
    if self.guid == guidTarget then
        self.name:SetFont(UNIT_NAME_FONT, 14)
    else
        self.name:SetFont(UNIT_NAME_FONT, 12)
    end
end
GW.AddForProfiling("bossFrames", "updateBoss_Name", updateBoss_Name)

local function updateBoss_RaidMarkers(self)
    local i = GetRaidTargetIndex(self.unit)

    if i then
        self.marker:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
        self.marker:Show()
        self.icon:Hide()
    else
        self.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
        self.icon:Show()
        self.marker:Hide()
    end
end
GW.AddForProfiling("unitframes", "updateRaidMarkers", updateRaidMarkers)

local function bossFrame_OnEvent(self, event, unit)
    if not self:IsShown() then
        return
    end

    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        updateBoss_Health(self)
    elseif event == "UNIT_MAXPOWER" or event == "UNIT_POWER_FREQUENT" then
        updateBoss_Power(self)
    elseif event == "PLAYER_TARGET_CHANGED" then
        updateBoss_Name(self)
    elseif event == "RAID_TARGET_UPDATE" then
        updateBoss_RaidMarkers(self)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "UNIT_NAME_UPDATE" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        updateBoss_Health(self)
        updateBoss_Power(self)
        updateBoss_Name(self)
        updateBoss_RaidMarkers(self)
    end
end
GW.AddForProfiling("bossFrames", "bossFrame_OnEvent", bossFrame_OnEvent) 

local function registerFrame(i)
    local bossFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerBossFrameTemp")
    local unit = "boss" .. i
    local yOffset = GetSetting("SHOW_QUESTTRACKER_COMPASS") and 70 or 0
    local p = yOffset + ((35 * i) - 35)

    bossFrame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    bossFrame.id = i
    bossFrame.unit = unit
    bossFrame.guid = UnitGUID(unit)

    bossFrame:SetAttribute("unit", unit)
    bossFrame:SetAttribute("*type1", "target")
    bossFrame:SetAttribute("*type2", "showmenu")

    AddToClique(bossFrame)

    RegisterUnitWatch(bossFrame)
    bossFrame:EnableMouse(true)
    bossFrame:RegisterForClicks("AnyDown")

    bossFrame.name:SetFont(UNIT_NAME_FONT, 12)
    bossFrame.name:SetShadowOffset(1, -1)
    bossFrame.marker:Hide()

    bossFrame.health:SetStatusBarColor(
        TRACKER_TYPE_COLOR.BOSS.r,
        TRACKER_TYPE_COLOR.BOSS.g,
        TRACKER_TYPE_COLOR.BOSS.b
    )
    bossFrame.icon:SetVertexColor(
        TRACKER_TYPE_COLOR.BOSS.r,
        TRACKER_TYPE_COLOR.BOSS.g,
        TRACKER_TYPE_COLOR.BOSS.b
    )

    bossFrame:RegisterEvent("RAID_TARGET_UPDATE")
    bossFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    bossFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    bossFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    bossFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    bossFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    bossFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    bossFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    bossFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)

    bossFrame:SetScript(
        "OnShow",
        function(self)
            local compassData = {}

            compassData.TYPE = "BOSS"
            compassData.ID = "boss_unknown"
            compassData.QUESTID = "unknown"
            compassData.COMPASS = false
            compassData.DESC = ""

            compassData.MAPID = nil
            compassData.X = nil
            compassData.Y = nil

            compassData.COLOR = TRACKER_TYPE_COLOR.BOSS
            compassData.TITLE = UnitName(self.unit)

            AddTrackerNotification(compassData)
            updateBossFrameHeight()
            updateBoss_Health(self)
            updateBoss_Power(self)
            updateBoss_Name(self)
            updateBoss_RaidMarkers(self)
        end
    )

    bossFrame:SetScript(
        "OnHide",
        function(self)
            updateBossFrameHeight()

            if self.id == 1 then
                RemoveTrackerNotificationOfType("BOSS")
            end
        end
    )

    bossFrame:SetScript("OnEvent", bossFrame_OnEvent)

    return bossFrame
end
GW.AddForProfiling("bossFrames", "registerFrame", registerFrame)

local function LoadBossFrame()
    for i = 1, 5 do
        bossFrames[i] = registerFrame(i)
        _G["Boss" .. i .. "TargetFrame"]:Kill()
    end
    C_Timer.After(0.01, function() updateBossFrameHeight() end)
end
GW.LoadBossFrame = LoadBossFrame
