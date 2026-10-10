---@class GW2
local GW = select(2, ...)

local GUILD_FACTION_ID = 1168
local DELETE_DIALOGS = {DELETE_GOOD_ITEM = true, DELETE_GOOD_QUEST_ITEM = true}
local RESURRECT_DIALOGS = {"RESURRECT", "RESURRECT_NO_SICKNESS", "RESURRECT_NO_TIMER"}

local ConfirmSummon = C_SummonInfo and C_SummonInfo.ConfirmSummon or ConfirmSummon
local GetNumFactions = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions
local SetWatchedFactionByIndex = C_Reputation and C_Reputation.SetWatchedFactionByIndex or SetWatchedFactionIndex
local summonAfterCombat = false
local errorsHidden = false
local hideInvitePopup = false
local lastGossipOption
local combatLogStarted = false
local MYTHIC_KEYSTONE_DIFFICULTY = 8

local function DoConfirmSummon()
    ConfirmSummon()
    StaticPopup_Hide("CONFIRM_SUMMON")
end

local function IsFriendOrGuild(guid)
    return (C_BattleNet and C_BattleNet.GetGameAccountInfoByGUID and C_BattleNet.GetGameAccountInfoByGUID(guid))
        or (C_FriendList and C_FriendList.IsFriend(guid))
        or IsGuildMember(guid)
end

local function IsQueued()
    local queueButton = QueueStatusButton or LFGMinimapFrame
    return queueButton and queueButton:IsShown()
end

local function TrackFaction(factionID)
    local watched = GW.GetWatchedFactionInfo()
    if factionID == GUILD_FACTION_ID or (watched and watched.factionID == factionID) then return end
    if C_Reputation and C_Reputation.SetWatchedFactionByID then
        C_Reputation.SetWatchedFactionByID(factionID)
        return
    end
    for i = 1, GetNumFactions() do
        local data = GW.GetFactionDataByIndex(i)
        if data and data.factionID == factionID then
            SetWatchedFactionByIndex(i)
            return
        end
    end
end

local function SetRoleFromSpec()
    local spec = C_SpecializationInfo.GetSpecialization()
    local role = spec and select(5, C_SpecializationInfo.GetSpecializationInfo(spec))
    if not UnitSetRole or not role or role == "NONE" or InCombatLockdown() or not IsInGroup() or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return end
    local assigned = UnitGroupRolesAssigned("player")
    if GW.NotSecretValue(assigned) and assigned ~= role then
        UnitSetRole("player", role)
    end
end

local function FillDeleteConfirmation()
    StaticPopup_ForEachShownDialog(function(dialog)
        local editBox = dialog.EditBox or dialog.editBox
        if DELETE_DIALOGS[dialog.which] and editBox then
            editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
        end
    end)
end

-- not with a soulstone, reincarnation or the like waiting
local function ReleaseInBattleground()
    local _, instanceType = IsInInstance()
    if instanceType ~= "pvp" then return end
    local options = C_DeathInfo.GetSelfResurrectOptions()
    if options and #options > 0 then return end
    C_Timer.After(0.5, function()
        if UnitIsDead("player") and not UnitIsGhost("player") then
            RepopMe()
        end
    end)
end

-- shift shows the options; every option only once until the window closes, an npc answering with the
-- same single option again would loop otherwise
local function SelectSingleGossip()
    if IsShiftKeyDown() or C_GossipInfo.GetNumAvailableQuests() > 0 or C_GossipInfo.GetNumActiveQuests() > 0 then return end
    local options = C_GossipInfo.GetOptions()
    if not options or #options ~= 1 then return end
    local optionID = options[1].gossipOptionID
    if not optionID or optionID == lastGossipOption then return end
    lastGossipOption = optionID
    C_GossipInfo.SelectOption(optionID)
end

-- shift keeps the cinematic
local function SkipCinematic()
    if IsShiftKeyDown() then return end
    C_Timer.After(0, function()
        if CinematicFrame and CinematicFrame:IsShown() then
            CinematicFrame_CancelCinematic()
        end
    end)
end

hooksecurefunc("MovieFrame_PlayMovie", function(movieFrame)
    if GW.settings.general.skipCinematics and not IsShiftKeyDown() then
        movieFrame:StopMovie()
    end
end)

-- logs raids and / or Mythic+ keys; a log we did not start is left alone
local function UpdateCombatLog()
    local mode = GW.settings.general.autoCombatLog
    local _, instanceType, difficultyID = GetInstanceInfo()
    local isRaid = instanceType == "raid"
    local isKeystone = difficultyID == MYTHIC_KEYSTONE_DIFFICULTY
    local shouldLog = (isRaid and (mode == "RAID" or mode == "BOTH")) or (isKeystone and (mode == "MYTHICPLUS" or mode == "BOTH"))
    if shouldLog and not LoggingCombat() then
        LoggingCombat(true)
        combatLogStarted = true
        GW.Notice(COMBATLOGENABLED)
    elseif not shouldLog and combatLogStarted then
        combatLogStarted = false
        if LoggingCombat() then
            LoggingCombat(false)
            GW.Notice(COMBATLOGDISABLED)
        end
    end
end
GW.UpdateAutoCombatLog = UpdateCombatLog

local function FastLoot()
    if GetCVarBool("autoLootDefault") == IsModifiedClick("AUTOLOOTTOGGLE") or IsFishingLoot() then return end
    for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, ...)
    local settings = GW.settings.general
    if event == "RESURRECT_REQUEST" then
        if settings.autoAcceptResurrect and not IsEncounterInProgress() then
            AcceptResurrect()
            for _, which in ipairs(RESURRECT_DIALOGS) do
                StaticPopup_Hide(which)
            end
        end
    elseif event == "CONFIRM_SUMMON" then
        if settings.autoConfirmSummon then
            if InCombatLockdown() then
                summonAfterCombat = true
            else
                C_Timer.After(0.6, DoConfirmSummon)
            end
        end
    elseif event == "CANCEL_SUMMON" then
        summonAfterCombat = false
    elseif event == "PLAYER_REGEN_ENABLED" then
        if summonAfterCombat then
            summonAfterCombat = false
            DoConfirmSummon()
        end
        if errorsHidden then
            errorsHidden = false
            UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if settings.hideErrorsInCombat then
            errorsHidden = true
            UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
        end
    elseif event == "PARTY_INVITE_REQUEST" then
        local inviterGUID = select(7, ...)
        if settings.autoAcceptInvite and inviterGUID and inviterGUID ~= "" and not IsInGroup() and not IsQueued() and IsFriendOrGuild(inviterGUID) then
            hideInvitePopup = true
            AcceptGroup()
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        if hideInvitePopup then
            hideInvitePopup = false
            StaticPopup_Hide("PARTY_INVITE")
        end
        if settings.autoSetRole then
            SetRoleFromSpec()
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        if settings.autoSetRole then
            SetRoleFromSpec()
        end
    elseif event == "FACTION_STANDING_CHANGED" then
        if settings.autoTrackReputation then
            TrackFaction(...)
        end
    elseif event == "DELETE_ITEM_CONFIRM" then
        if settings.autoFillDelete then
            FillDeleteConfirmation()
        end
    elseif event == "LOOT_READY" then
        if settings.fastLoot then
            FastLoot()
        end
    elseif event == "PLAYER_DEAD" then
        if settings.autoReleasePvP then
            ReleaseInBattleground()
        end
    elseif event == "GOSSIP_SHOW" then
        if settings.autoGossip then
            SelectSingleGossip()
        end
    elseif event == "GOSSIP_CLOSED" then
        lastGossipOption = nil
    elseif event == "CINEMATIC_START" then
        if settings.skipCinematics then
            SkipCinematic()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "CHALLENGE_MODE_START" then
        if settings.autoCombatLog ~= "NONE" or combatLogStarted then
            UpdateCombatLog()
        end
    end
end)

frame:RegisterEvent("RESURRECT_REQUEST")
frame:RegisterEvent("CONFIRM_SUMMON")
frame:RegisterEvent("CANCEL_SUMMON")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("FACTION_STANDING_CHANGED")
frame:RegisterEvent("DELETE_ITEM_CONFIRM")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("GOSSIP_CLOSED")
frame:RegisterEvent("CINEMATIC_START")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
if C_EventUtils.IsEventValid("CHALLENGE_MODE_START") then
    frame:RegisterEvent("CHALLENGE_MODE_START")
end
if C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED") then
    frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
end
