local _, GW = ...
local AddTrackerNotification = GW.AddTrackerNotification
local RemoveTrackerNotificationOfType = GW.RemoveTrackerNotificationOfType
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AddToClique = GW.AddToClique
local PowerBarColorCustom = GW.PowerBarColorCustom
local SetClassIcon = GW.SetClassIcon
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME

local countArenaFrames = 0
local countArenaPrepFrames = 0

local nameRoleIcon = {}
    nameRoleIcon["TANK"] = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-tank:16:16:0:0|t "
    nameRoleIcon["HEALER"] = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-healer:16:16:0:0|t "
    nameRoleIcon["DAMAGER"] = "|TInterface\\AddOns\\GW2_UI\\textures\\party\\roleicon-dps:16:16:0:0|t "
    nameRoleIcon["NONE"] = ""

local FractionIcon = {}
    FractionIcon["Alliance"] = "|TInterface\\AddOns\\GW2_UI\\textures\\Alliance:16:16:0:0|t "
    FractionIcon["Horde"] = "|TInterface\\AddOns\\GW2_UI\\textures\\Horde:16:16:0:0|t "
    FractionIcon["NONE"] = ""

local function setCompass(prepFrame)
    local isArena = IsActiveBattlefieldArena()
    local compassData = {}

    if prepFrame == nil then 
        prepFrame = false
    end

    if isArena or prepFrame then
        compassData["TITLE"] = ARENA
        compassData["DESC"] = VOICEMACRO_2_Ta_1_FEMALE
    else
        compassData["TITLE"] = BATTLEGROUND
        compassData["DESC"] = VOICEMACRO_2_Ta_1_FEMALE
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

local function updateArenaFrameHeight(frame)
    local height = 1
    local ii = 0
    for i = 1, 5 do 
        if _G[frame .. i]:IsShown() then
            ii = i
        end
    end
    for i = 1, 5 do
        if _G[frame .. i]:IsShown() then
            height = height + (_G[frame .. i]:GetHeight() * ii)
            break
        end
    end
    GwQuesttrackerContainerBossFrames:SetHeight(height)
end
GW.AddForProfiling("arenaFrames", "updateArenaFrameHeight", updateArenaFrameHeight)

local function updateArena_Health(self)
    local health = UnitHealth(self.unit)
    local maxHealth = UnitHealthMax(self.unit)
    local healthPrecentage = 0

    if health > 0 and maxHealth > 0 then
        healthPrecentage = health / maxHealth
    end

    self.health:SetValue(healthPrecentage)
    self.health.value:SetText(GW.RoundInt(healthPrecentage * 100) .. "%")
end
GW.AddForProfiling("arenaFrames", "updateArena_Health", updateArena_Health)

local function updateArena_Power(self)
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
GW.AddForProfiling("arenaFrames", "updateArena_Power", updateArena_Power)

local function updateArena_Name(self, inBG, inArena)
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

    if inArena then
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
    self.classIndex = select(3, UnitClass(self.unit))
    if self.classIndex then 
        SetClassIcon(self.icon, self.classIndex)
        self.health:SetStatusBarColor(
            CLASS_COLORS_RAIDFRAME[self.classIndex].r,
            CLASS_COLORS_RAIDFRAME[self.classIndex].g,
            CLASS_COLORS_RAIDFRAME[self.classIndex].b,
            1
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
    local isArena = IsActiveBattlefieldArena()
    local inBG = UnitInBattleground("player")
    if not isArena and inBG == nil then
        return
    end

    if (event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT") then
        updateArena_Health(self)
        return
    end

    if (event == "UNIT_MAXPOWER" or event == "UNIT_POWER_FREQUENT") then
        updateArena_Power(self)
        return
    end

    if event == "PLAYER_TARGET_CHANGED" then
        updateArena_Name(self, inBG, isArena)
        return
    end     
    
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_NAME_UPDATE" or event == "PLAYER_ENTERING_BATTLEGROUND" or event == "ARENA_OPPONENT_UPDATE" then 
        updateArena_Health(self)
        updateArena_Power(self)
        updateArena_Name(self, inBG, isArena)
        setCompass()
        return
    end
end
GW.AddForProfiling("arenaFrames", "arenaFrame_OnEvent", arenaFrame_OnEvent)

local function arenaPrepFrame_OnEvent(self, event)
    if event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
        --Hide Blizzard frames
        for i = 1, 5 do
            if _G["ArenaPrepFrame" .. i] ~= nil then
                _G["ArenaPrepFrame" .. i]:SetAlpha(0)
                _G["ArenaPrepFrame" .. i]:SetScript("OnEvent", nil)
            end
        end
        local specID, gender = GetArenaOpponentSpec(self.id)
        local nameString = UNKNOWEN
        local className, classFile

        if specID == nil then 
            return
        end
        if specID and specID > 0 then
            local _, specName, _, _, role, class = GetSpecializationInfoByID(specID, gender)
            for i = 1, GetNumClasses() do
                className, classFile = GetClassInfo(i)
                if class == classFile then
                    break
                end
            end
            if nameRoleIcon[role] ~= nil then
                nameString = nameRoleIcon[role] .. className .. " - " .. specName
            end
            self.name:SetText(nameString)
            self.health:SetStatusBarColor(0.5, 0.5, 0.5)
            self.power:SetStatusBarColor(0.5, 0.5, 0.5)
            SetClassIcon(self.icon, class)
            self:Show()
        end
    end   
end
GW.AddForProfiling("arenaFrames", "arenaPrepFrame_OnEvent", arenaPrepFrame_OnEvent)

local function registerFrame(i)
    local debug_unit_Track = "arena" .. i

    local targetF = CreateFrame("Button", "GwQuestTrackerArenaFrame" .. i, GwQuestTracker, "GwQuestTrackerBossFrame")

    local p = 70 + ((35 * i) - 35)

    targetF:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    targetF.unit = debug_unit_Track
    targetF.id = i
    targetF.guid = UnitGUID(targetF.unit)
    targetF:SetAttribute("unit", debug_unit_Track)

    targetF:SetAttribute("*type1", "target")
    targetF:SetAttribute("*type2", "showmenu")

    AddToClique(targetF)

    RegisterUnitWatch(targetF)
    targetF:EnableMouse(true)
    targetF:RegisterForClicks("AnyDown")

    targetF.name:SetFont(UNIT_NAME_FONT, 12)
    targetF.name:SetShadowOffset(1, -1)
    targetF.marker:Hide()
    targetF.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons")

    targetF:RegisterUnitEvent("UNIT_MAXHEALTH", targetF.unit)
    targetF:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", targetF.unit)
    targetF:RegisterUnitEvent("UNIT_MAXPOWER", targetF.unit)
    targetF:RegisterUnitEvent("UNIT_POWER_FREQUENT", targetF.unit)
    targetF:RegisterUnitEvent("UNIT_NAME_UPDATE", targetF.unit)
    targetF:RegisterEvent("PLAYER_TARGET_CHANGED")
    targetF:RegisterEvent("PLAYER_ENTERING_WORLD")
    targetF:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    targetF:RegisterEvent("ARENA_OPPONENT_UPDATE")

    targetF:SetScript(
        "OnShow",
        function(self)
            --Hide prep frames
            for i = 1, 5 do
                if _G["GwQuestTrackerArenaPrepFrame" .. i]:IsShown() then
                    _G["GwQuestTrackerArenaPrepFrame" .. i]:Hide()
                    _G["GwQuestTrackerArenaPrepFrame" .. i]:SetScript("OnEvent", nil)
                end
            end

            updateArenaFrameHeight("GwQuestTrackerArenaFrame")
            setCompass()

            updateArena_Health(self)
            updateArena_Power(self)
            updateArena_Name(self, inBG, isArena)

            countArenaFrames = countArenaFrames + 1

            --Hide Blizzard frames
            if _G["ArenaEnemyFrame" .. i]:IsShown() then 
                _G["ArenaEnemyFrame" .. i]:SetAlpha(0)
                _G["ArenaEnemyFrame" .. i]:SetScript("OnEvent", nil)
                _G["ArenaEnemyFrame" .. i]:SetScript("OnEnter", nil)
                if _G["ArenaEnemyFrame" .. i .. "PetFrame"]:IsShown() then
                    _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetAlpha(0)
                    _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetScript("OnEvent", nil)
                    _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetScript("OnEnter", nil)
                end  
            end
        end
    )

    targetF:SetScript(
        "OnHide",
        function()
            countArenaFrames = countArenaFrames - 1
            updateArenaFrameHeight("GwQuestTrackerArenaFrame")
            if countArenaFrames < 1 then
                RemoveTrackerNotificationOfType("ARENA")
                countArenaFrames = 0
            end
        end
    )

    targetF:SetScript(
        "OnUpdate",
        function()
            if _G["ArenaEnemyFrame" .. i .. "PetFrame"]:IsShown() then
                _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetAlpha(0)
                _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetScript("OnEvent", nil)
                _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetScript("OnEnter", nil)
            end 
        end
    )

    targetF:SetScript("OnEvent", arenaFrame_OnEvent)
end
GW.AddForProfiling("arenaFrames", "registerFrame", registerFrame)

local function registerPrepFrame(i)
    local targetF = CreateFrame("Button", "GwQuestTrackerArenaPrepFrame" .. i, GwQuestTracker, "GwQuestTrackerArenaPrepFrame")
    local p = 70 + ((35 * i) - 35)

    targetF:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)

    targetF.id = i

    targetF:EnableMouse(true)
    targetF:RegisterForClicks("AnyDown")

    targetF.name:SetFont(UNIT_NAME_FONT, 12)
    targetF.name:SetShadowOffset(1, -1)

    targetF:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

    targetF:SetScript(
        "OnShow",
        function(self)
            updateArenaFrameHeight("GwQuestTrackerArenaPrepFrame")
            setCompass(true)
            countArenaPrepFrames = countArenaPrepFrames + 1

            --Hide Blizzard frames
            for i = 1, 5 do
                if _G["ArenaPrepFrame" .. i] ~= nil then
                    _G["ArenaPrepFrame" .. i]:SetAlpha(0)
                    _G["ArenaPrepFrame" .. i]:SetScript("OnEvent", nil)
                end
            end
        end
    )
    targetF:SetScript("OnEvent", arenaPrepFrame_OnEvent)
end
GW.AddForProfiling("arenaFrames", "registerPrepFrame", registerPrepFrame)

local function LoadArenaFrame()
    for i = 1, 5 do
        registerFrame(i)
        registerPrepFrame(i)
        if _G["ArenaEnemyFrame" .. i] ~= nil then
            _G["ArenaEnemyFrame" .. i]:Hide()
            _G["ArenaEnemyFrame" .. i]:SetScript("OnEvent", nil)
            _G["ArenaEnemyFrame" .. i]:SetScript("OnShow", function(self) self:Hide() end)
        end
        if _G["ArenaEnemyFrame" .. i .. "PetFrame"] ~= nil then
            _G["ArenaEnemyFrame" .. i .. "PetFrame"]:Hide()
            _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetScript("OnEvent", nil)
            _G["ArenaEnemyFrame" .. i .. "PetFrame"]:SetScript("OnShow", nil)
        end
        if _G["ArenaPrepFrame" .. i] ~= nil then
            _G["ArenaPrepFrame" .. i]:Hide()
            _G["ArenaPrepFrame" .. i]:SetScript("OnEvent", nil)
        end
    end
    updateArenaFrameHeight("GwQuestTrackerArenaFrame")
end
GW.LoadArenaFrame = LoadArenaFrame
