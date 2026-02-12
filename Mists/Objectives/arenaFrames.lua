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

local countArenaFrames = 0
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5

local arenaFrames = {}
local arenaPrepFrames = {}

local FractionIcon = {}
    FractionIcon.Alliance = "|TInterface/AddOns/GW2_UI/textures/battleground/alliance.png:16:16:0:0|t "
    FractionIcon.Horde = "|TInterface/AddOns/GW2_UI/textures/battleground/horde.png:16:16:0:0|t "
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
            local status, mapName, _, _, _, _, _, _, _, _, _, _, _, shortDescription = GetBattlefieldStatus(i)
            if status and status == "active" then
                compassTitle = mapName
                compassDesc = shortDescription and shortDescription or ""
                break
            end
        end
    end

    compassData.TITLE = compassTitle
    compassData.DESC = compassDesc
    compassData.TYPE = GW.TRACKER_TYPE.ARENA
    compassData.ID = "arena_unknown"
    compassData.QUESTID = "unknown"
    compassData.COMPASS = false
    compassData.MAPID = nil
    compassData.X = nil
    compassData.Y = nil
    compassData.COLOR = TRACKER_TYPE_COLOR.ARENA

    AddTrackerNotification(compassData, true)
end

local function updateArenaFrameHeight(self)
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
    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(i > 0 and (48 * i) or 1)
end


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


local function updateArena_Power(self)
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
    local power = UnitPower(self.unit, powerType)
    local powerMax = UnitPowerMax(self.unit, powerType)
    local powerPercentage = 0

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.power:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    else
        self.power:SetStatusBarColor(altR or 0, altG or 0, altB or 0)
    end

    if power > 0 and powerMax > 0 then
        powerPercentage = power / powerMax
    end

    self.power:SetMinMaxValues(0, powerMax)
    self.power:SetValue(power)
    self.power.value:SetText(GW.RoundInt(powerPercentage * 100) .. "%")
end


local function updateArena_Name(self)
    local inArena = C_PvP.GetZonePVPInfo()
    local inBG = UnitInBattleground("player")
    local nameString = UNKNOWNOBJECT
    local name = UnitName(self.unit) or UNKNOWNOBJECT

    if inArena == "arena" then
        local specID = GetArenaOpponentSpec(self.id)
        if specID == nil then
            return
        else
            if specID and specID > 0 then
                local _, specName, _, _, role = GetSpecializationInfoByID(specID, UnitSex(self.unit))
                if role and nameRoleIcon[role] and specName and name then
                    nameString = nameRoleIcon[role] .. name .. " - " .. specName
                end
            end
        end
    elseif inBG ~= nil then
        local role = UnitGroupRolesAssigned(self.unit)
        local englishFaction = UnitFactionGroup(self.unit)
        if role and nameRoleIcon[role] and englishFaction and FractionIcon[englishFaction] and name then
            nameString = FractionIcon[englishFaction] .. nameRoleIcon[role] .. name
        else
            return
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
        self.health:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    if self.guid == UnitGUID("target") then
        self.name:SetFont(UNIT_NAME_FONT, 14)
    else
        self.name:SetFont(UNIT_NAME_FONT, 12)
    end
end


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


local function registerFrame(i, container)
    local arenaFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerAreanaFrameTemp")
    local unit = "arena" .. i

    arenaFrame.unit = unit
    arenaFrame.id = i
    arenaFrame.guid = UnitGUID(unit)

    arenaFrame:SetAttribute("unit", unit)
    arenaFrame:SetAttribute("*type1", "target")
    arenaFrame:SetAttribute("*type2", "togglemenu")

    AddToClique(arenaFrame)

    RegisterUnitWatch(arenaFrame)
    arenaFrame:EnableMouse(true)
    arenaFrame:RegisterForClicks("AnyDown")

    arenaFrame.name:SetFont(UNIT_NAME_FONT, 12)
    arenaFrame.name:SetShadowOffset(1, -1)
    arenaFrame.marker:Hide()
    arenaFrame.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons.png")

    arenaFrame.power.value:Hide()

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

            updateArenaFrameHeight(container)

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
            updateArenaFrameHeight(container)
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


local function registerPrepFrame(container)
    local arenaPrepFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerArenaPrepFrameTemp")

    arenaPrepFrame:EnableMouse(true)
    arenaPrepFrame:RegisterForClicks("AnyDown")

    arenaPrepFrame.name:SetFont(UNIT_NAME_FONT, 12)
    arenaPrepFrame.name:SetShadowOffset(1, -1)

    arenaPrepFrame:SetScript(
        "OnShow",
        function()
            updateArenaFrameHeight(container)
        end
    )

    return arenaPrepFrame
end


local function ArenaFrameOnEvent(self, event)
    -- handle compass header
    if IsIn(event, "PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_BATTLEGROUND", "PVP_BRAWL_INFO_UPDATED", "UPDATE_BATTLEFIELD_STATUS") then
        C_Timer.After(0.8, function()
            local _, instanceType = IsInInstance()
            if instanceType == "arena" or instanceType == "pvp" then
                setCompass()
                updateArenaFrameHeight(self)
            end
        end)
    elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
        local numOpps = GetNumArenaOpponentSpecs()

        if ArenaPrepFrames then
            ArenaPrepFrames:GwKill()
        end

        for i = 1, MAX_ARENA_ENEMIES do
            local prepFrame = arenaPrepFrames[i]
            if i <= numOpps then
                local specID, gender = GetArenaOpponentSpec(i)
                if specID > 0 then
                    local nameString = UNKNOWN
                    local className, classFile
                    local _, specName, _, _, role, class = GetSpecializationInfoByID(specID, gender)
                    for y = 1, GetNumClasses() do
                        className, classFile = GetClassInfo(y)
                        if class == classFile then
                            break
                        end
                    end
                    if nameRoleIcon[role] then
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

        updateArenaFrameHeight(self)
    end
end


local function SetUpFramePosition()
    local yOffset = GW.settings.SHOW_QUESTTRACKER_COMPASS and 70 or 0

    for idx, frame in pairs(arenaFrames) do
        local p = yOffset + ((48 * idx) - 48)
        frame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)
    end

    for idx, frame in pairs(arenaPrepFrames) do
        local p = yOffset + ((48 * idx) - 48)
        frame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)
    end
end
GW.SetUpArenaFramePosition = SetUpFramePosition

local function LoadArenaFrame(self)
    for i = 1, MAX_ARENA_ENEMIES do
        arenaFrames[i] = registerFrame(i, self)
        --arenaPrepFrames[i] = registerPrepFrame(self)
    end
    SetUpFramePosition()

    --event for arena prep frames
    --self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    --self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

    -- Log event for compass Header
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    self:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    self:SetScript("OnEvent", ArenaFrameOnEvent)

    C_Timer.After(0.01, function() updateArenaFrameHeight(self) end)
end
GW.LoadArenaFrame = LoadArenaFrame
