local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AddToClique = GW.AddToClique
local PowerBarColorCustom = GW.PowerBarColorCustom

local function updateBossFrameHeight()
    local height = 1
    for i = 1, 4 do
        if _G["GwQuestTrackerBossFrame" .. i]:IsShown() then
            height = height + _G["GwQuestTrackerBossFrame" .. i]:GetHeight()
        end
    end
    GwQuesttrackerContainerBossFrames:SetHeight(height)
end
GW.AddForProfiling("bossFrames", "updateBossFrameHeight", updateBossFrameHeight)

local function updateBoss_Health(self)
    local health = UnitHealth(self.unit)
    local maxHealth = UnitHealthMax(self.unit)
    local healthPrecentage = 0

    if health > 0 and maxHealth > 0 then
        healthPrecentage = health / maxHealth
    end

    self.health:SetValue(healthPrecentage)
end
GW.AddForProfiling("bossFrames", "updateBoss_Health", updateBoss_Health)

local function updateBoss_Power(self)
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)
    local powerPrecentage = 0

    if power > 0 and powerMax > 0 then
        powerPrecentage = power / powerMax
    end

    if power <= 0 then
        self.power:Hide()
        self.health:SetHeight(10)
    else
        self.power:Show()
        self.health:SetHeight(8)
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.power:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    else
        self.power:SetStatusBarColor(altR, altG, altB)
    end

    self.power:SetValue(powerPrecentage)
end
GW.AddForProfiling("bossFrames", "updateBoss_Power", updateBoss_Power)

local function updateBoss_Name(self)
    local guidBoss = UnitGUID(self.unit)
    local guidTarget = UnitGUID("target")
    self.name:SetText(UnitName(self.unit))
    if guidBoss == guidTarget then
        self.name:SetTextColor(255, 0, 0)
    else
        self.name:SetTextColor(1, 1, 1)
    end
end
GW.AddForProfiling("bossFrames", "updateBoss_Name", updateBoss_Name)

local function bossFrame_OnEvent(self, event, unit)
    if (event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH") and unit == self.unit then
        updateBoss_Health(self)
        return
    end

    if (event == "UNIT_MAXPOWER" or event == "UNIT_POWER_FREQUENT") and unit == self.unit then
        updateBoss_Power(self)
        return
    end

    if event == "PLAYER_TARGET_CHANGED" then
        updateBoss_Name(self)
        return
    end  
    
    if event == "PLAYER_ENTERING_WORLD" then 
        updateBoss_Health(self)
        updateBoss_Power(self)
        updateBoss_Name(self)
        return
    end

end
GW.AddForProfiling("bossFrames", "bossFrame_OnEvent", bossFrame_OnEvent)

local function registerFrame(i)
    local debug_unit_Track = "boss" .. i

    local targetF = CreateFrame("Button", "GwQuestTrackerBossFrame" .. i, GwQuestTracker, "GwQuestTrackerBossFrame")

    local p = 70 + ((35 * i) - 35)

    targetF:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    targetF.unit = debug_unit_Track
    targetF:SetAttribute("unit", debug_unit_Track)

    targetF:SetAttribute("*type1", "target")
    targetF:SetAttribute("*type2", "showmenu")

    AddToClique(targetF)

    RegisterUnitWatch(targetF)
    targetF:EnableMouse(true)
    targetF:RegisterForClicks("AnyDown")

    targetF.name:SetFont(UNIT_NAME_FONT, 12)
    targetF.name:SetShadowOffset(1, -1)

    _G["GwQuestTrackerBossFrame" .. i .. "StatusBar"]:SetStatusBarColor(
        TRACKER_TYPE_COLOR["BOSS"].r,
        TRACKER_TYPE_COLOR["BOSS"].g,
        TRACKER_TYPE_COLOR["BOSS"].b
    )
    _G["GwQuestTrackerBossFrame" .. i .. "Icon"]:SetVertexColor(
        TRACKER_TYPE_COLOR["BOSS"].r,
        TRACKER_TYPE_COLOR["BOSS"].g,
        TRACKER_TYPE_COLOR["BOSS"].b
    )

    targetF:RegisterEvent("UNIT_MAXHEALTH")
    targetF:RegisterEvent("UNIT_HEALTH")
    targetF:RegisterEvent("UNIT_MAXPOWER")
    targetF:RegisterEvent("UNIT_POWER_FREQUENT")
    targetF:RegisterEvent("PLAYER_TARGET_CHANGED")
    targetF:RegisterEvent("PLAYER_ENTERING_WORLD")

    targetF:SetScript(
        "OnShow",
        function(self)
            updateBossFrameHeight(self)

            local compassData = {}

            compassData["TYPE"] = "BOSS"
            compassData["TITLE"] = "Unknown"
            compassData["ID"] = "boss_unknown"
            compassData["QUESTID"] = "unknown"
            compassData["COMPASS"] = false
            compassData["DESC"] = ""

            compassData["MAPID"] = 0
            compassData["X"] = 0
            compassData["Y"] = 0

            compassData["COLOR"] = TRACKER_TYPE_COLOR["BOSS"]
            compassData["TITLE"] = UnitName(self.unit)

            AddTrackerNotification(compassData)
            updateBoss_Health(self)
            updateBoss_Power(self)
            updateBoss_Name(self)
        end
    )

    targetF:SetScript(
        "OnHide",
        function(self)
            updateBossFrameHeight(self)

            --[[
            local visible = false
            for index = 1, 4 do
                if _G["GwQuestTrackerBossFrame" .. index]:IsShown() then
                    visible = true
                end
            end
            if visible == false then
            end
            --]]
            if i == 1 then
                RemoveTrackerNotificationOfType("BOSS")
            end
        end
    )

    targetF:SetScript("OnEvent", bossFrame_OnEvent)
end
GW.AddForProfiling("bossFrames", "registerFrame", registerFrame)

local function LoadBossFrame()
    for i = 1, 4 do
        registerFrame(i)
        if _G["Boss" .. i .. "TargetFrame"] ~= nil then
            _G["Boss" .. i .. "TargetFrame"]:Hide()
            _G["Boss" .. i .. "TargetFrame"]:SetScript("OnEvent", nil)
        end
    end
    updateBossFrameHeight()
end
GW.LoadBossFrame = LoadBossFrame
