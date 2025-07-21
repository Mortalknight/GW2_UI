local _, GW = ...
local L = GW.L

local frame = CreateFrame("Frame")
local INTERRUPT_MSG = L["Interrupted %s's |cff71d5ff|Hspell:%d:0|h[%s]|h|r!"]

local function IsRandomGroup()
    return IsPartyLFG() or (GW.Retail and C_PartyInfo.IsPartyWalkIn()) -- This is the API for Delves
end

local function OnEvent(self, _, subEvent, _, sourceGUID, srcName, sourceFlags, _, destGUID, destName, _, _, ...)
    if not IsInGroup() then return end

    local _, _, _, spellID, spellName = ...
    local announce = spellName and (destGUID ~= GW.myguid) and (sourceGUID == GW.myguid or sourceGUID == UnitGUID("pet"))
    if not announce then return end

    local inRaid, inPartyLFG = IsInRaid(), IsRandomGroup()

    local _, instanceType = GetInstanceInfo()
    if instanceType == "arena" then
        local skirmish = IsArenaSkirmish()
        local _, isRegistered = IsActiveBattlefieldArena()
        if skirmish or not isRegistered then
            inPartyLFG = true
        end

        inRaid = false
    end

    local name, msg = destName or UNKNOWN
    if GW.mylocal == "msMX" or GW.mylocal == "esES" or GW.mylocal == "ptBR" then
        msg = format(INTERRUPT_MSG, spellID, spellName, name)
    else
        msg = format(INTERRUPT_MSG, name, spellID, spellName)
    end

    local channel = GW.settings.interruptAnnounce
    if channel == "PARTY" then
        C_ChatInfo.SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
    elseif channel == "RAID" then
        C_ChatInfo.SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY"))
    elseif channel == "RAID_ONLY" and inRaid then
        C_ChatInfo.SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
    elseif channel == "SAY" and instanceType ~= "none" then
        C_ChatInfo.SendChatMessage(msg, "SAY")
    elseif channel == "YELL" and instanceType ~= "none" then
        C_ChatInfo.SendChatMessage(msg, "YELL")
    elseif channel == "EMOTE" then
        C_ChatInfo.SendChatMessage(msg, "EMOTE")
    end
end


local function ToggleInterruptAnncouncement()
    local announce = GW.settings.interruptAnnounce
    if announce and announce ~= "NONE" then
        GW.Libs.GW2Lib:RegisterCombatEvent(frame, "_INTERRUPT", OnEvent)
    else
        GW.Libs.GW2Lib:UnregisterCombatEvent(frame, "_INTERRUPT")
    end
end
GW.ToggleInterruptAnncouncement = ToggleInterruptAnncouncement
