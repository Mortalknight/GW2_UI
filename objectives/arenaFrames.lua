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
local arenaFrames = {}
local arenaPrepFrames = {}

local countArenaFrames = 0
local countArenaPrepFrames = 0
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5

local FractionIcon = {}
    FractionIcon["Alliance"] = "|TInterface\\AddOns\\GW2_UI\\textures\\Alliance:16:16:0:0|t "
    FractionIcon["Horde"] = "|TInterface\\AddOns\\GW2_UI\\textures\\Horde:16:16:0:0|t "
    FractionIcon["NONE"] = ""

local bgIndex = {}
    bgIndex[30] = 5         -- Alterac
    bgIndex[2197] = 5       -- Alterac
    bgIndex[529] = 3        -- Arathi
    bgIndex[1681] = 3       -- Arathi
    bgIndex[2107] = 3       -- Arathi
    bgIndex[2177] = 3       -- Arathi
    bgIndex[1191] = 12      -- Ashran
    bgIndex[2245] = 1       -- Deepwind
    bgIndex[566] = 4        -- Eye Of The Storm
    bgIndex[968] = 4        -- Eye Of The Storm
    bgIndex[761] = 7        -- Gilneas
    bgIndex[628] = 6        -- Isle Of Conquest
    bgIndex[1803] = 13      -- Seething Shore
    bgIndex[727] = 9        -- Silvershard Mines
    bgIndex[998] = 10       -- Temple Of Kotmogu
    bgIndex[726] = 8        -- Twin Peaks
    bgIndex[2106] = 2       -- Warsong
    bgIndex[2118] = 11      -- Wintergrasp

local function setCompass()
    local isArena = IsActiveBattlefieldArena()
    local compassData = {}

    if isArena then
        compassData["TITLE"] = ARENA
        compassData["DESC"] = VOICEMACRO_2_Ta_1_FEMALE
    else
        -- parse current BG date here, to show the correct name and subname
        local _, _, _, _, _, _, _, mapID = GetInstanceInfo()

        if GetBattlegroundInfo(bgIndex[mapID]) then
            compassData["TITLE"] = select(1, GetBattlegroundInfo(bgIndex[mapID])) 
            compassData["DESC"] = select(12, GetBattlegroundInfo(bgIndex[mapID]))
        else
            compassData["TITLE"] = ARENA
            compassData["DESC"] = VOICEMACRO_2_Ta_1_FEMALE
        end
    end
    compassData["TYPE"] = "ARENA"
    compassData["ID"] = "arena_unknown"
    compassData["QUESTID"] = "unknown"
    compassData["COMPASS"] = false
    compassData["MAPID"] = 0
    compassData["X"] = 0
    compassData["Y"] = 0
    compassData["COLOR"] = TRACKER_TYPE_COLOR["ARENA"]

    AddTrackerNotification(compassData)
end

local function updateArenaFrameHeight(frames)
    local i = 0

    for k, frame in pairs(frames) do
        if frame:IsShown() then
            i = k
        end
    end

    GwQuesttrackerContainerBossFrames:SetHeight(i > 0 and 1 + (frames[i]:GetHeight() * i) or 1)
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
    local specName = ""
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

local function arenaFrame_OnEvent(self, event, unit)
    local isArena = GetZonePVPInfo()
    local inBG = UnitInBattleground("player")
    if isArena ~= "arena" and inBG == nil then
        return
    end

    if IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH_FREQUENT") then
        updateArena_Health(self)
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
        updateArena_Power(self)
    elseif event == "PLAYER_TARGET_CHANGED" then
        updateArena_Name(self)
    elseif IsIn(event, "PLAYER_ENTERING_WORLD", "UNIT_NAME_UPDATE", "ARENA_OPPONENT_UPDATE") then 
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
                local nameString = UNKNOWEN
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
end
GW.AddForProfiling("arenaFrames", "arenaPrepFrame_OnEvent", arenaPrepFrame_OnEvent)

local function registerFrame(i)
    local arenaFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerBossFrameTemp")
    local unit = "arena" .. i
    local p = 70 + ((35 * i) - 35)

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

    arenaFrame:SetScript(
        "OnShow",
        function(self)
            --Hide prep frames
            for k, frame in pairs(arenaPrepFrames) do
                if frame:IsShown() then
                    frame:Hide()
                end
            end

            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
            self:RegisterEvent("ARENA_OPPONENT_UPDATE")
            self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
            self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self.unit)
            self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
            self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
            self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)

            updateArenaFrameHeight(arenaPrepFrames)

            updateArena_Health(self)
            updateArena_Power(self)
            updateArena_Name(self)

            countArenaFrames = countArenaFrames + 1
        end
    )

    arenaFrame:SetScript(
        "OnHide",
        function(self)
            countArenaFrames = countArenaFrames - 1
            updateArenaFrameHeight(arenaFrames)
            local isArena = GetZonePVPInfo()
            local inBG = UnitInBattleground("player")

            if countArenaFrames < 1 and isArena ~= "arena" and inBG == nil then
                RemoveTrackerNotificationOfType("ARENA")
                countArenaFrames = 0
            end

            self:UnregisterAllEvents()
        end
    )

    arenaFrame:SetScript("OnEvent", arenaFrame_OnEvent)

    return arenaFrame
end
GW.AddForProfiling("arenaFrames", "registerFrame", registerFrame)

local function registerPrepFrame(i)
    local arenaPrepFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerArenaPrepFrameTemp")
    local p = 70 + ((35 * i) - 35)

    arenaPrepFrame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    arenaPrepFrame:EnableMouse(true)
    arenaPrepFrame:RegisterForClicks("AnyDown")

    arenaPrepFrame.name:SetFont(UNIT_NAME_FONT, 12)
    arenaPrepFrame.name:SetShadowOffset(1, -1)

    arenaPrepFrame:SetScript(
        "OnShow",
        function(self)
            updateArenaFrameHeight(arenaPrepFrames)
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
    arenaPrepFrame:SetScript("OnEvent", arenaPrepFrame_OnEvent)

    -- Log event for compass Header
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    f:SetScript("OnEvent", function(self, event)
        C_Timer.After(0.8, function()
            local isArena = IsActiveBattlefieldArena()
            local inBG = UnitInBattleground("player")

            if not isArena and inBG == nil then
                return
            end

            setCompass()
        end)
    end)

    updateArenaFrameHeight(arenaFrames)
end
GW.LoadArenaFrame = LoadArenaFrame
