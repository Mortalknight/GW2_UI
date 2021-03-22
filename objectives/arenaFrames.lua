local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AddToClique = GW.AddToClique
local PowerBarColorCustom = GW.PowerBarColorCustom
local SetClassIcon = GW.SetClassIcon
local GWGetClassColor = GW.GWGetClassColor
local IsIn = GW.IsIn
local nameRoleIcon = GW.nameRoleIcon
local GetSetting = GW.GetSetting
local arenaFrames = {}
local arenaPrepFrames = {}

local countArenaFrames = 0
local countArenaPrepFrames = 0
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5

local FractionIcon = {}
    FractionIcon.Alliance = "|TInterface/AddOns/GW2_UI/textures/battleground/Alliance:16:16:0:0|t "
    FractionIcon.Horde = "|TInterface/AddOns/GW2_UI/textures/battleground/Horde:16:16:0:0|t "
    FractionIcon.NONE = ""

local function setCompass()
    local compassData = {}
    local compassTitle, compassDesc = "", ""

    if C_PvP.IsInBrawl() then
        local brawlInfo = C_PvP.GetActiveBrawlInfo()
        if brawlInfo then
            compassTitle = brawlInfo.name
            compassDesc = brawlInfo.shortDescription
        end
    else
        for i = 1, GetMaxBattlefieldID() do
            local status, mapName, _, _, _, _, _, _, _, shortDescription = GetBattlefieldStatus(i)
            if status and status == "active" then
                compassTitle = mapName
                compassDesc = shortDescription and shortDescription or ""
                break
            end
        end
    end

    compassData.TITLE = compassTitle
    compassData.DESC = compassDesc
    compassData.TYPE = "ARENA"
    compassData.ID = "arena_unknown"
    compassData.QUESTID = "unknown"
    compassData.COMPASS = false
    compassData.MAPID = nil
    compassData.X = nil
    compassData.Y = nil
    compassData.COLOR = TRACKER_TYPE_COLOR.ARENA

    AddTrackerNotification(compassData, true)
end

local function updateArenaFrameHeight()
    local i = 0

    for k, frame in pairs(arenaFrames) do
        if frame:IsShown() then
            i = k
        end
    end

    if i == 0 then
        for k, frame in pairs(arenaPrepFrames) do
            if frame:IsShown() then
                i = k
            end
        end
    end
    GwQuesttrackerContainerArenaBGFrames:SetHeight(i > 0 and (35 * i) or 1)
end
GW.AddForProfiling("arenaFrames", "updateArenaFrameHeight", updateArenaFrameHeight)

local function updateArena_Health(self)
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
GW.AddForProfiling("arenaFrames", "updateArena_Health", updateArena_Health)

local function updateArena_Power(self)
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
GW.AddForProfiling("arenaFrames", "updateArena_Power", updateArena_Power)

local function updateArena_Name(self)
    local inArena = GetZonePVPInfo()
    local inBG = UnitInBattleground("player")
    local guidTarget = UnitGUID("target")
    local specID = GetArenaOpponentSpec(self.id)
    local nameString = UNKNOWNOBJECT
    local name

    if UnitName(self.unit) ~= nil then 
        name = UnitName(self.unit)
    else 
        name = UNKNOWNOBJECT
    end

    if inArena == "arena" then
        if specID == nil then
            return
        else
            if specID and specID > 0 then
                local _, specName, _, _, role = GetSpecializationInfoByID(specID, UnitSex(self.unit))
                if nameRoleIcon[role] ~= nil then
                    nameString = nameRoleIcon[role] .. name .. " - " .. specName
                end
            end
        end
    elseif inBG ~= nil then
        local role = UnitGroupRolesAssigned(self.unit)
        local englishFaction, localizedFaction = UnitFactionGroup(self.unit)
        if role == nil or englishFaction == nil or localizedFaction == nil then 
            return
        else
            nameString = FractionIcon[englishFaction] .. nameRoleIcon[role] .. name
        end
    else
        return
    end

    self.name:SetText(nameString)
    
    self.guid = UnitGUID(self.unit)
    self.class = select(2, UnitClass(self.unit))
    self.classIndex = select(3, UnitClass(self.unit))
    if self.class then 
        SetClassIcon(self.icon, self.classIndex)
        local color = GWGetClassColor(self.class, true)
        self.health:SetStatusBarColor(
            color.r,
            color.g,
            color.b,
            color.a
        )
    end
    if self.guid == guidTarget then
        self.name:SetFont(UNIT_NAME_FONT, 14)
    else
        self.name:SetFont(UNIT_NAME_FONT, 12)
    end
end
GW.AddForProfiling("arenaFrames", "updateArena_Name", updateArena_Name)

local function arenaFrame_OnEvent(self, event)
    local _, instanceType = IsInInstance()
    if instanceType ~= "arena" and instanceType ~= "pvp" then
        return
    end

    if IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH") then
        updateArena_Health(self)
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
        updateArena_Power(self)
    elseif event == "PLAYER_TARGET_CHANGED" then
        updateArena_Name(self)
    elseif IsIn(event, "PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_BATTLEGROUND", "UNIT_NAME_UPDATE", "ARENA_OPPONENT_UPDATE") then 
        updateArena_Health(self)
        updateArena_Power(self)
        updateArena_Name(self)
    end
end
GW.AddForProfiling("arenaFrames", "arenaFrame_OnEvent", arenaFrame_OnEvent)

local function arenaPrepFrame_OnEvent()
    local numOpps = GetNumArenaOpponentSpecs()

    if _G.ArenaPrepFrames then
        _G.ArenaPrepFrames:Kill()
    end

    for i = 1, MAX_ARENA_ENEMIES do
        local prepFrame = arenaPrepFrames[i]
        if i <= numOpps then
            local specID, gender = GetArenaOpponentSpec(i)
            if specID > 0 then 
                local nameString = UNKNOWN
                local className, classFile
                local _, specName, _, _, role, class = GetSpecializationInfoByID(specID, gender)
                for i = 1, GetNumClasses() do
                    className, classFile = GetClassInfo(i)
                    if class == classFile then
                        break
                    end
                end
                if nameRoleIcon[role] ~= nil then
                    nameString = nameRoleIcon[role] .. className .. " - " .. specName
                else
                    nameString = className .. " - " .. specName
                end   
                prepFrame.name:SetText(nameString)
                prepFrame.health:SetStatusBarColor(0.5, 0.5, 0.5)
                prepFrame.power:SetStatusBarColor(0.5, 0.5, 0.5)
                SetClassIcon(prepFrame.icon, class)
                prepFrame:Show()
            else
                prepFrame:Hide()
            end
        else
            prepFrame:Hide()
        end
    end

    updateArenaFrameHeight()
end
GW.AddForProfiling("arenaFrames", "arenaPrepFrame_OnEvent", arenaPrepFrame_OnEvent)

local function registerFrame(i)
    local arenaFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerBossFrameTemp")
    local unit = "arena" .. i
    local yOffset = GetSetting("SHOW_QUESTTRACKER_COMPASS") and 70 or 0
    local p = yOffset + ((35 * i) - 35)

    arenaFrame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    arenaFrame.unit = unit
    arenaFrame.id = i
    arenaFrame.guid = UnitGUID(unit)

    arenaFrame:SetAttribute("unit", unit)
    arenaFrame:SetAttribute("*type1", "target")
    arenaFrame:SetAttribute("*type2", "showmenu")

    AddToClique(arenaFrame)

    RegisterUnitWatch(arenaFrame)
    arenaFrame:EnableMouse(true)
    arenaFrame:RegisterForClicks("AnyDown")

    arenaFrame.name:SetFont(UNIT_NAME_FONT, 12)
    arenaFrame.name:SetShadowOffset(1, -1)
    arenaFrame.marker:Hide()
    arenaFrame.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")

    arenaFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    arenaFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    arenaFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    arenaFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    arenaFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    arenaFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    arenaFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    arenaFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    arenaFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)

    arenaFrame:SetScript(
        "OnShow",
        function(self)
            --Hide prep frames
            for _, frame in pairs(arenaPrepFrames) do
                if frame:IsShown() then
                    frame:Hide()
                end
            end

            updateArenaFrameHeight()

            updateArena_Health(self)
            updateArena_Power(self)
            updateArena_Name(self)

            countArenaFrames = countArenaFrames + 1
        end
    )

    arenaFrame:SetScript(
        "OnHide",
        function()
            countArenaFrames = countArenaFrames - 1
            updateArenaFrameHeight()
            local _, instanceType = IsInInstance()
            if countArenaFrames < 1 and instanceType ~= "arena" and instanceType ~= "pvp" then
                RemoveTrackerNotificationOfType("ARENA")
                countArenaFrames = 0
            end
        end
    )

    arenaFrame:SetScript("OnEvent", arenaFrame_OnEvent)

    return arenaFrame
end
GW.AddForProfiling("arenaFrames", "registerFrame", registerFrame)

local function registerPrepFrame(i)
    local arenaPrepFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerArenaPrepFrameTemp")
    local yOffset = GetSetting("SHOW_QUESTTRACKER_COMPASS") and 70 or 0
    local p = yOffset + ((35 * i) - 35)

    arenaPrepFrame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    arenaPrepFrame:EnableMouse(true)
    arenaPrepFrame:RegisterForClicks("AnyDown")

    arenaPrepFrame.name:SetFont(UNIT_NAME_FONT, 12)
    arenaPrepFrame.name:SetShadowOffset(1, -1)

    arenaPrepFrame:SetScript(
        "OnShow",
        function()
            updateArenaFrameHeight()
            countArenaPrepFrames = countArenaPrepFrames + 1
        end
    )

    return arenaPrepFrame
end
GW.AddForProfiling("arenaFrames", "registerPrepFrame", registerPrepFrame)

local function LoadArenaFrame()
    Arena_LoadUI()

    for i = 1, MAX_ARENA_ENEMIES do
        arenaFrames[i] = registerFrame(i)
        arenaPrepFrames[i] = registerPrepFrame(i)
        if _G["ArenaEnemyFrame" .. i] ~= nil then
            _G["ArenaEnemyFrame" .. i]:Kill()
        end
        if _G["ArenaEnemyFrame" .. i .. "PetFrame"] ~= nil then
            _G["ArenaEnemyFrame" .. i .. "PetFrame"]:Kill()
        end
    end

    --create prepframe frame to handle events
    local arenaPrepFrame = CreateFrame("Frame")
    arenaPrepFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    arenaPrepFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    arenaPrepFrame:SetScript("OnEvent", arenaPrepFrame_OnEvent)

    -- Log event for compass Header
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    f:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
    f:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    f:SetScript("OnEvent", function()
        C_Timer.After(0.8, function()
            local _, instanceType = IsInInstance()
            if instanceType == "arena" or instanceType == "pvp" then
                setCompass()
                updateArenaFrameHeight()
            end
        end)
    end)
    C_Timer.After(0.01, function() updateArenaFrameHeight() end)
end
GW.LoadArenaFrame = LoadArenaFrame
