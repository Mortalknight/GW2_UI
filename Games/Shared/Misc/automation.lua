---@class GW2
local GW = select(2, ...)

local GUILD_FACTION_ID = 1168
local DELETE_DIALOGS = {DELETE_GOOD_ITEM = true, DELETE_GOOD_QUEST_ITEM = true}

local GetNumFactions = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions
local SetWatchedFactionByIndex = C_Reputation and C_Reputation.SetWatchedFactionByIndex or SetWatchedFactionIndex
local errorsHidden = false
local hideInvitePopup = false

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

-- a kill can change several reputations at once: losses never switch the bar, the watched faction stays when it
-- gained as well, otherwise the biggest gain wins; the standings before are needed to tell gains from losses
local standings = {}
local gains

local function RememberStandings()
    for i = 1, GetNumFactions() do
        local data = GW.GetFactionDataByIndex(i)
        if data and data.factionID and data.factionID > 0 then
            standings[data.factionID] = data.currentStanding
        end
    end
end

local function TrackBiggestGain()
    local pending = gains
    gains = nil
    local watched = GW.GetWatchedFactionInfo()
    if watched and pending[watched.factionID] then return end
    local bestID, bestGain
    for factionID, gain in pairs(pending) do
        if not bestGain or gain > bestGain then
            bestID, bestGain = factionID, gain
        end
    end
    TrackFaction(bestID)
end

local function IsListed(factionID)
    for i = 1, GetNumFactions() do
        local data = GW.GetFactionDataByIndex(i)
        if data and data.factionID == factionID then
            return true
        end
    end
end

local function OnStandingChanged(factionID, standing)
    local previous = standings[factionID]
    -- blizzard also reports hidden factions, like the paragon of renown factions, only the reputation list counts
    if not previous and not IsListed(factionID) then return end
    standings[factionID] = standing
    -- a faction not known before counts as a gain, it was not in the list at login
    if not GW.settings.general.autoTrackReputation or factionID == GUILD_FACTION_ID or (previous and standing <= previous) then return end
    if not gains then
        gains = {}
        C_Timer.After(0, TrackBiggestGain)
    end
    gains[factionID] = (gains[factionID] or 0) + standing - (previous or standing)
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

local function FastLoot()
    if GetCVarBool("autoLootDefault") == IsModifiedClick("AUTOLOOTTOGGLE") or IsFishingLoot() then return end
    for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, ...)
    local settings = GW.settings.general
    if event == "PLAYER_REGEN_ENABLED" then
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
        OnStandingChanged(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        RememberStandings()
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
    end
end)

frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("FACTION_STANDING_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("DELETE_ITEM_CONFIRM")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("PLAYER_DEAD")
if C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED") then
    frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
end
