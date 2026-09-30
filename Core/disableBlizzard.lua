---@class GW2
local GW = select(2, ...)

-- Blizzard frames we replace are put away instead of destroyed, other code may still
-- reference them. How a frame is put away:
--   MOVE  into the hidden frame
--   LOCK  into the hidden frame, and back there whenever Blizzard reparents it
--   STAY  only silenced and hidden, e.g. members of a container that already moved
local MOVE, LOCK, STAY = "move", "lock", "stay"

local MAX_PARTY = MEMBERS_PER_RAID_GROUP or MAX_PARTY_MEMBERS or 5
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
local MAX_BOSS_FRAMES = 10

-- parts of a unit frame that listen to events on their own; alternative keys are tried in order
local UNIT_FRAME_PARTS = {
    { "petFrame", "PetFrame" },
    { "healthBar", "healthbar", "HealthBar" },
    { "manabar", "ManaBar" },
    { "castBar", "spellbar" },
    { "powerBarAlt", "PowerBarAlt" },
    { "totFrame" },
    { "BuffFrame" },
}

local lockedFrames = {}
local arenaHidden = false

local function SilenceParts(frame, parts)
    for _, keys in ipairs(parts) do
        for _, key in ipairs(keys) do
            if frame[key] then
                frame[key]:UnregisterAllEvents()
                break
            end
        end
    end
end

local function ReturnToHiddenFrame(frame, parent)
    if parent == GW.HiddenFrame then return end
    if frame:IsProtected() and InCombatLockdown() then
        GW.CombatQueue:Queue("resetParentFrame: " .. frame:GetDebugName(), ReturnToHiddenFrame, { frame, parent })
        return
    end
    frame:SetParent(GW.HiddenFrame)
end

local function PutAway(frame, how)
    if type(frame) == "string" then
        frame = _G[frame]
    end
    if not frame then return end

    if how ~= STAY then
        frame:SetParent(GW.HiddenFrame)
    end
    if how == LOCK and not lockedFrames[frame] then
        lockedFrames[frame] = true
        hooksecurefunc(frame, "SetParent", ReturnToHiddenFrame)
    end

    frame:UnregisterAllEvents()
    pcall(frame.Hide, frame)
    SilenceParts(frame, UNIT_FRAME_PARTS)
end

local function PutAwayIf(enabled, how, ...)
    if not enabled then return end
    for i = 1, select("#", ...) do
        PutAway(select(i, ...), how)
    end
end


-- The compact party/raid member frames are protected: reparenting or otherwise touching
-- them from here taints them, and blizzards own CompactUnitFrame_UpdateAll then gets its
-- SetSize refused with ADDON_ACTION_BLOCKED
local compactPatterns = {}
local compactSetUpUnits = {}
local compactHooked = {}
local allowedCompactSetup = _G.DefaultCompactUnitFrameSetup and {[_G.DefaultCompactUnitFrameSetup] = true} or {}

local function compactFrameShown(frame, shown)
    if shown then
        frame:Hide()
    end
end

local COMPACT_FRAME_PARTS = {
    { "healthBar", "healthbar", "HealthBar" },
    { "manabar", "ManaBar" },
    { "castBar", "spellbar" },
    { "powerBarAlt", "PowerBarAlt" },
    { "totFrame" },
    { "BuffFrame", "AurasFrame" },
    { "DebuffFrame" },
}

local function disableCompactFrame(frame)
    frame:UnregisterAllEvents()
    frame:Hide()

    if frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar then
        frame.HealthBarsContainer.healthBar:UnregisterAllEvents()
    end
    SilenceParts(frame, COMPACT_FRAME_PARTS)
end

-- silences a container and marks its members by name pattern; no SetParent anywhere
local function hideCompactFrame(frame, ...)
    if not frame then return end

    disableCompactFrame(frame)
    for i = 1, select("#", ...) do
        compactPatterns[select(i, ...)] = true
    end

    if not compactHooked[frame] then
        compactHooked[frame] = true
        hooksecurefunc(frame, "Show", frame.Hide)
        hooksecurefunc(frame, "SetShown", compactFrameShown)
    end
end

local function compactSetUpFrame(self, func)
    if not allowedCompactSetup[func] then return end

    local name = (not self.IsForbidden or not self:IsForbidden()) and self:GetDebugName()
    if GW.IsSecretValue(name) or not name then return end

    for pattern in next, compactPatterns do
        if strmatch(name, pattern) then
            compactSetUpUnits[self] = true
        end
    end
end

local function compactSetUnit(self, token)
    if compactSetUpUnits[self] and token ~= nil then
        self:SetScript("OnEvent", nil)
        self:SetScript("OnUpdate", nil)
    end
end

if CompactUnitFrame_SetUpFrame then
    hooksecurefunc("CompactUnitFrame_SetUpFrame", compactSetUpFrame)
end
if CompactUnitFrame_SetUnit then
    hooksecurefunc("CompactUnitFrame_SetUnit", compactSetUnit)
end


local function DisableBlizzardFrames()
    local ourPartyFrames = GW.settings.unitframes.party.enabled
    local ourRaidFrames = GW.settings.groupFrames.enabled
    local ourBossFrames = GW.settings.objectives.enabled and not GW.ShouldBlockIncompatibleAddon("Objectives")
    local ourArenaFrames = not C_AddOns.IsAddOnLoaded("sArena") and GW.settings.objectives.enabled and not GW.ShouldBlockIncompatibleAddon("Objectives")
    local ourPetFrame = GW.settings.unitframes.pet.enabled and not GW.ShouldBlockIncompatibleAddon("Actionbars")
    local ourTargetFrame = GW.settings.unitframes.target.enabled
    local ourTargetTargetFrame = GW.settings.unitframes.targettarget.enabled
    local ourFocusFrame = GW.settings.unitframes.focus.enabled
    local ourFocusTargetFrame = GW.settings.unitframes.focustarget.enabled
    local ourPlayerFrame = GW.settings.unitframes.healthGlobe.enabled
    local ourCastBar = GW.settings.castingbar.enabled
    local ourActionbars = GW.settings.actionbars.enabled and GW.settings.actionbars.barLayout and not GW.ShouldBlockIncompatibleAddon("Actionbars")
    local ourInventory = GW.settings.bags.enabled

    if ourPartyFrames or ourRaidFrames then
        -- calls to UpdateRaidAndPartyFrames, which as of writing this is used to show/hide the
        -- Raid Utility and update Party frames via PartyFrame.UpdatePartyFrames not raid frames.
        GW.UnregisterGameEvent("GROUP_ROSTER_UPDATE")
    end

    if ourPartyFrames then
        -- shutdown some background updates on default unitframes
        hideCompactFrame(CompactPartyFrame, "^CompactPartyFrameMember%d+$")

        if PartyFrame then
            PutAway(PartyFrame, LOCK)
            PartyFrame:SetScript("OnShow", nil)
            for member in PartyFrame.PartyMemberFramePool:EnumerateActive() do
                PutAway(member, STAY)
            end
        end

        -- only the classic style member frames here, the compact ones are handled by
        -- the pattern above and must never be reparented
        for i = 1, MAX_PARTY do
            PutAway("PartyMemberFrame" .. i, MOVE)
        end
    end

    if ourRaidFrames then
        -- grouped layout names members CompactRaidGroup<g>Member<n>, combined layout CompactRaidFrame<n>
        hideCompactFrame(CompactRaidFrameContainer, "^CompactRaidGroup%d+Member%d+$", "^CompactRaidFrame%d+$")

        -- Raid Utility
        if CompactRaidFrameManager_SetSetting then
            CompactRaidFrameManager_SetSetting("IsShown", "0")
        end

        if CompactRaidFrameManager then
            CompactRaidFrameManager:UnregisterAllEvents()
            CompactRaidFrameManager:SetParent(GW.HiddenFrame)
        end

        if CompactRaidFrameContainer then
            CompactRaidFrameContainer:GwKillEditMode()
        end
    end

    if ourArenaFrames then
        -- the threat indicator registers events on the arena frames again
        hooksecurefunc("UnitFrameThreatIndicator_Initialize", function(_, unitFrame)
            unitFrame:UnregisterAllEvents()
        end)

        -- classic clients would load the old arena frames on demand
        if not GW.Retail then
            Arena_LoadUI = GW.NoOp
        end

        if CompactArenaFrame and not arenaHidden then
            arenaHidden = true
            PutAway(CompactArenaFrame, LOCK)
            for _, member in pairs(CompactArenaFrame.memberUnitFrames) do
                PutAway(member, STAY)
            end
        end

        -- retail still keeps the old frames for battleground flag carriers
        for i = 1, MAX_ARENA_ENEMIES do
            PutAway("ArenaEnemyMatchFrame" .. i, STAY)
            PutAway("ArenaEnemyPrepFrame" .. i, STAY)
        end
    end

    if ourBossFrames then
        PutAway(BossTargetFrameContainer, LOCK)
        for i = 1, MAX_BOSS_FRAMES do
            PutAway("Boss" .. i .. "TargetFrame", STAY)
        end
    end

    PutAwayIf(ourPetFrame, MOVE, "PetFrame")
    PutAwayIf(ourTargetFrame, MOVE, "TargetFrame", "ComboFrame")
    PutAwayIf(ourTargetFrame and ourTargetTargetFrame, MOVE, "TargetFrameToT")
    PutAwayIf(ourFocusFrame, MOVE, "FocusFrame")
    PutAwayIf(ourFocusFrame and ourFocusTargetFrame, MOVE, "TargetofFocusFrame")

    if ourPlayerFrame then
        PutAway(PlayerFrame, MOVE)

        -- for vehicle support
        for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "UNIT_ENTERING_VEHICLE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITING_VEHICLE", "UNIT_EXITED_VEHICLE" }) do
            PlayerFrame:RegisterEvent(event)
        end
        PlayerFrame:SetMovable(true)
        PlayerFrame:SetUserPlaced(true)
        PlayerFrame:SetDontSavePosition(true)
    end

    if ourCastBar then
        -- the overlay bar runs its own events on retail and its stop animations error on the
        -- secret protected CastingBarTypeInfo when tainted
        for _, name in ipairs({ "PlayerCastingBarFrame", "OverlayPlayerCastingBarFrame", "CastingBarFrame", "PetCastingBarFrame" }) do
            PutAway(name, LOCK)
        end

        -- keeps Blizzard's cast bar mover away
        PlayerCastingBarFrame:HookScript("OnShow", function() PlayerCastingBarFrame:Hide() end)
        PlayerCastingBarFrame:GwKillEditMode()
    end

    if ourInventory and MicroButtonAndBagsBar then
        MicroButtonAndBagsBar:SetParent(GW.HiddenFrame)
        MicroButtonAndBagsBar:UnregisterAllEvents()
    end

    if ourActionbars then
        -- only moved and silenced: Blizzard's settings read their shown state.
        -- MainMenuBar stays: in the hidden frame our main bar would vanish too, the
        -- action bar module removes its events instead.
        for _, name in ipairs({ "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarLeft", "MultiBarRight", "MultiBar5", "MultiBar6", "MultiBar7", "StanceBar" }) do
            local bar = _G[name]
            if bar then
                bar:SetParent(GW.HiddenFrame)
                bar:UnregisterAllEvents()
            end
        end
    end
end
GW.DisableBlizzardFrames = DisableBlizzardFrames