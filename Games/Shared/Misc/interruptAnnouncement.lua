---@class GW2
local GW = select(2, ...)
local L = GW.L

local frame = CreateFrame("Frame")
local INTERRUPT_MSG = L["Interrupted %s's |cff71d5ff|Hspell:%d:0|h[%s]|h|r!"]
-- these translations name the spell first
local SPELL_FIRST_LOCALES = {esES = true, esMX = true, ptBR = true}

-- random groups (dungeon finder, delves, arena skirmishes) only have the instance chat
local function IsInstanceGroup(instanceType)
    if instanceType == "arena" then
        local _, isRegistered = IsActiveBattlefieldArena()
        return IsArenaSkirmish() or not isRegistered
    end
    return IsPartyLFG() or (C_PartyInfo.IsPartyWalkIn and C_PartyInfo.IsPartyWalkIn())
end

-- the chat the setting asks for, nil where it does not fit
local function GetChannel(setting)
    local _, instanceType = GetInstanceInfo()
    local instanceChat = IsInstanceGroup(instanceType) and "INSTANCE_CHAT"
    local inRaid = IsInRaid() and instanceType ~= "arena"

    if setting == "PARTY" then
        return instanceChat or "PARTY"
    elseif setting == "RAID" then
        return instanceChat or (inRaid and "RAID" or "PARTY")
    elseif setting == "RAID_ONLY" then
        return inRaid and (instanceChat or "RAID") or nil
    elseif setting == "SAY" or setting == "YELL" then
        -- blizzard allows those outside of instances only from hardware events
        return instanceType ~= "none" and setting or nil
    elseif setting == "EMOTE" then
        return "EMOTE"
    end
end

local function OnInterrupt(_, _, _, _, sourceGUID, _, _, _, destGUID, destName, _, _, _, _, _, spellID, spellName)
    local petGUID = UnitGUID("pet")
    if GW.IsSecretValue(sourceGUID) or GW.IsSecretValue(destGUID) or GW.IsSecretValue(destName) or GW.IsSecretValue(spellName) or GW.IsSecretValue(petGUID) then
        return
    end
    if not IsInGroup() or not spellName or destGUID == GW.myguid or (sourceGUID ~= GW.myguid and sourceGUID ~= petGUID) then
        return
    end

    local channel = GetChannel(GW.settings.chat.interruptAnnounce)
    if channel then
        local target = destName or UNKNOWN
        local msg = SPELL_FIRST_LOCALES[GW.mylocal] and format(INTERRUPT_MSG, spellID, spellName, target) or format(INTERRUPT_MSG, target, spellID, spellName)
        C_ChatInfo.SendChatMessage(msg, channel)
    end
end

function GW.ToggleInterruptAnncouncement()
    local setting = GW.settings.chat.interruptAnnounce
    if setting and setting ~= "NONE" then
        GW.Libs.GW2Lib:RegisterCombatEvent(frame, "_INTERRUPT", OnInterrupt)
    else
        GW.Libs.GW2Lib:UnregisterCombatEvent(frame, "_INTERRUPT")
    end
end
