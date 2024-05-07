local _, GW = ...
local L = GW.L

local mouseOver = false
local collectedInstanceImages = false
local lockoutColorExtended = {r = 0.3, g = 1, b = 0.3}
local lockoutColorNormal = {r = 0.8, g = 0.8, b = 0.8}

local InstanceNameByID = {
    -- List of not matching instanceID from EJ_GetInstanceByIndex and from GetInstanceInfo
    [749] = C_Map.GetAreaInfo(3845) -- "The Eye" vs. "Tempest Keep"
}

if GW.mylocal == "deDE" then
    InstanceNameByID[741] = "Geschmolzener Kern"        -- "Der Geschmolzene Kern"
    InstanceNameByID[1023] = "Belagerung von Boralus"   -- "Die Belagerung von Boralus"
    InstanceNameByID[1041] = "Königsruh"                -- "Die Königsruh"
    InstanceNameByID[1021] = "Kronsteiganwesen"	        -- "Das Kronsteiganwesen"
    InstanceNameByID[1186] = "Spitzen des Aufstiegs"    -- "Die Spitzen des Aufstiegs"
    InstanceNameByID[1198] = "Angriff der Nokhud"		-- "Der Angriff der Nokhud"
    InstanceNameByID[1203] = "Azurblaues Gewölbe"		-- "Das Azurblaube Gewölbe"
end

local instanceIconByName = {}
local function GetInstanceImages(raid)
    local index = 1
    local instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
    while instanceID do
        instanceIconByName[InstanceNameByID[instanceID] or name] = buttonImage
        index = index + 1
        instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
    end
end

local function sortFunc(a, b)
    return a[1] < b[1]
end

local function Time_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, TIMEMANAGER_TOOLTIP_TITLE)

    if not mouseOver then
        mouseOver = true
        RequestRaidInfo()
    end

    if not collectedInstanceImages then
        local numTiers = (EJ_GetNumTiers() or 0)
        if numTiers > 0 then
            local currentTier = EJ_GetCurrentTier()

            -- Loop through the expansions to collect the textures
            for i = 1, numTiers do
                EJ_SelectTier(i)
                GetInstanceImages(false)
                GetInstanceImages(true)
            end

            -- Set it back to the previous tier
            if currentTier then
                EJ_SelectTier(currentTier)
            end

            collectedInstanceImages = true
        end
    end

    local lockedInstances = {raids = {}, dungeons = {}}

    for i = 1, GetNumSavedInstances() do
        local name, _, _, difficulty, locked, extended, _, isRaid = GetSavedInstanceInfo(i)
        if locked or extended and name then
            local isLFR = (difficulty == 7 or difficulty == 17)
            local isHeroicOrMythicDungeon = (difficulty == 2 or difficulty == 23)
            local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficulty)
            local sortName = name .. (displayMythic and 4 or (isHeroic or displayHeroic) and 3 or isLFR and 1 or 2)
            local difficulty = (displayMythic and PLAYER_DIFFICULTY6 or (isHeroic or displayHeroic) and PLAYER_DIFFICULTY2 or isLFR and PLAYER_DIFFICULTY3 or PLAYER_DIFFICULTY1)
            local buttonImg = instanceIconByName[name] and format("|T%s:16:16:0:0:96:96:0:64:0:64|t ", instanceIconByName[name]) or ""

            if isRaid then
                tinsert(lockedInstances.raids, {sortName, difficulty, buttonImg, {GetSavedInstanceInfo(i)}})
            elseif isHeroicOrMythicDungeon then
                tinsert(lockedInstances.dungeons, {sortName, difficulty, buttonImg, {GetSavedInstanceInfo(i)}})
            end
        end
    end

    if next(lockedInstances.raids) then
        if GameTooltip:NumLines() > 0 then
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddLine(L["Saved Raid(s)"])

        sort(lockedInstances.raids, sortFunc)

        for i = 1, #lockedInstances.raids do
            local difficulty = lockedInstances.raids[i][2]
            local buttonImg = lockedInstances.raids[i][3]
            local name, _, reset, _, _, extended, _, _, _, _, numEncounters, encounterKilled = unpack(lockedInstances.raids[i][4])

            local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
            if numEncounters and numEncounters > 0 and (encounterKilled and encounterKilled > 0) then
                GameTooltip:AddDoubleLine(format("%s%s |cffaaaaaa(%s, %s/%s)", buttonImg, name, difficulty, encounterKilled, numEncounters), SecondsToTime(reset, true, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            else
                GameTooltip:AddDoubleLine(format("%s%s |cffaaaaaa(%s)", buttonImg, name, difficulty), SecondsToTime(reset, true, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            end
        end
    end

    if next(lockedInstances.dungeons) then
        if GameTooltip:NumLines() > 0 then
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddLine(L["Saved Dungeon(s)"])

        sort(lockedInstances.dungeons, sortFunc)

        for i = 1,#lockedInstances.dungeons do
            local difficulty = lockedInstances.dungeons[i][2]
            local buttonImg = lockedInstances.dungeons[i][3]
            local name, _, reset, _, _, extended, _, _, _, _, numEncounters, encounterKilled = unpack(lockedInstances.dungeons[i][4])

            local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
            if numEncounters and numEncounters > 0 and (encounterKilled and encounterKilled > 0) then
                GameTooltip:AddDoubleLine(format("%s%s |cffaaaaaa(%s, %s/%s)", buttonImg, name, difficulty, encounterKilled, numEncounters), SecondsToTime(reset, true, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            else
                GameTooltip:AddDoubleLine(format("%s%s |cffaaaaaa(%s)", buttonImg, name, difficulty), SecondsToTime(reset, true, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            end
        end
    end

    local addedLine = false
    local worldbossLockoutList = {}
    for i = 1, GetNumSavedWorldBosses() do
        local name, _, reset = GetSavedWorldBossInfo(i)
        tinsert(worldbossLockoutList, {name, reset})
    end
    sort(worldbossLockoutList, sortFunc)
    for i = 1,#worldbossLockoutList do
        local name, reset = unpack(worldbossLockoutList[i])
        if reset then
            if not addedLine then
                if GameTooltip:NumLines() > 0 then
                    GameTooltip:AddLine(" ")
                end
                GameTooltip:AddLine(WORLD_BOSSES_TEXT)
                addedLine = true
            end
            GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)
        end
    end

    if GameTooltip:NumLines() > 0 then
        GameTooltip:AddLine(" ")
    end

    GameTooltip:AddDoubleLine(L["Daily Reset"], SecondsToTime(C_DateAndTime.GetSecondsUntilDailyReset()), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
    GameTooltip:AddDoubleLine(L["Weekly Reset"], SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset(), true, nil, 3), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)

    if GameTooltip:NumLines() > 0 then
        GameTooltip:AddLine(" ")
    end

    GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), nil, nil, nil, 1, 1, 1)
    GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), nil, nil, nil, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", GAMETIME_TOOLTIP_TOGGLE_CLOCK, "|r"))

    GameTooltip:Show()
end
GW.Time_OnEnter = Time_OnEnter

local function Time_OnLeave()
    GameTooltip_Hide()
    mouseOver = false
end
GW.Time_OnLeave = Time_OnLeave

local function Time_OnEvent(self, event)
    if event == "UPDATE_INSTANCE_INFO" and mouseOver then
        Time_OnEnter(self)
    end
end
GW.Time_OnEvent = Time_OnEvent

local function Time_OnClick(_, button)
    if button == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        ToggleTimeManager()
    else
        GameTimeFrame:Click()
    end
end
GW.Time_OnClick = Time_OnClick
