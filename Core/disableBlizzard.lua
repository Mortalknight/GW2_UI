---@class GW2
local GW = select(2, ...)

local isArenaHooked = false
local lockedFrames = {}

local MAX_PARTY = MEMBERS_PER_RAID_GROUP or MAX_PARTY_MEMBERS or 5
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
local MAX_BOSS_FRAMES = 10

-- lock Boss, Party, and Arena
local function LockParent(frame, parent)
    if parent ~= GW.HiddenFrame then
        if frame:IsProtected() and InCombatLockdown() then
            GW.CombatQueue:Queue("resetParentFrame: " .. frame:GetDebugName(), LockParent, {frame, parent})
            return
        end
        frame:SetParent(GW.HiddenFrame)
    end
end

local function HandleFrame(frame, doNotReparent)
    if type(frame) == "string" then
        frame = _G[frame]
    end

    if not frame then return end

    local lockParent = doNotReparent == 1

    if lockParent or not doNotReparent then
        frame:SetParent(GW.HiddenFrame)
        if lockParent and not lockedFrames[frame] then
            hooksecurefunc(frame, "SetParent", LockParent)
            lockedFrames[frame] = true
        end
    end

    frame:UnregisterAllEvents()
    pcall(frame.Hide, frame)

    for _, child in next, {
        frame.petFrame or frame.PetFrame,
        frame.healthBar or frame.healthbar or frame.HealthBar,
        frame.manabar or frame.ManaBar,
        frame.castBar or frame.spellbar,
        frame.powerBarAlt or frame.PowerBarAlt,
        frame.totFrame,
        frame.BuffFrame
    } do
        child:UnregisterAllEvents()
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

local function disableCompactFrame(frame)
    frame:UnregisterAllEvents()
    frame:Hide()

    for _, child in next, {
        frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar,
        frame.healthBar or frame.healthbar or frame.HealthBar,
        frame.manabar or frame.ManaBar,
        frame.castBar or frame.spellbar,
        frame.powerBarAlt or frame.PowerBarAlt,
        frame.totFrame,
        frame.BuffFrame or frame.AurasFrame,
        frame.DebuffFrame
    } do
        child:UnregisterAllEvents()
    end
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
    local ourPartyFrames = GW.settings.PARTY_FRAMES
    local ourRaidFrames = GW.settings.RAID_FRAMES
    local ourBossFrames = GW.settings.QUESTTRACKER_ENABLED and not GW.ShouldBlockIncompatibleAddon("Objectives")
    local ourArenaFrames = not C_AddOns.IsAddOnLoaded("sArena") and GW.settings.QUESTTRACKER_ENABLED and not GW.ShouldBlockIncompatibleAddon("Objectives")
    local ourPetFrame = GW.settings.PETBAR_ENABLED and not GW.ShouldBlockIncompatibleAddon("Actionbars")
    local ourTargetFrame = GW.settings.TARGET_ENABLED
    local ourTargetTargetFrame = GW.settings.target_TARGET_ENABLED
    local ourFocusFrame = GW.settings.FOCUS_ENABLED
    local ourFocusTargetFrame = GW.settings.focus_TARGET_ENABLED
    local ourPlayerFrame = GW.settings.HEALTHGLOBE_ENABLED
    local ourCastBar = GW.settings.CASTINGBAR_ENABLED
    local ourActionbars = GW.settings.ACTIONBARS_ENABLED and GW.settings.BAR_LAYOUT_ENABLED and not GW.ShouldBlockIncompatibleAddon("Actionbars")
    local ourInventory = GW.settings.BAGS_ENABLED

    if ourPartyFrames or ourRaidFrames then
        -- calls to UpdateRaidAndPartyFrames, which as of writing this is used to show/hide the
        -- Raid Utility and update Party frames via PartyFrame.UpdatePartyFrames not raid frames.
        GW.UnregisterGameEvent("GROUP_ROSTER_UPDATE")
    end

    if ourPartyFrames then
        -- shutdown some background updates on default unitframes
        hideCompactFrame(CompactPartyFrame, "^CompactPartyFrameMember%d+$")

        if PartyFrame then
            HandleFrame(PartyFrame, 1)
            PartyFrame:UnregisterAllEvents()
            PartyFrame:SetScript("OnShow", nil)

            for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
                HandleFrame(frame, true)
            end
        end

        -- only the classic style member frames here, the compact ones are handled by
        -- the pattern above and must never be reparented
        for i = 1, MAX_PARTY do
            HandleFrame("PartyMemberFrame" .. i)
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
        hooksecurefunc("UnitFrameThreatIndicator_Initialize", function(_, unitFrame)
            unitFrame:UnregisterAllEvents() -- Arena Taint Fix
        end)

        if GW.Retail then
           if CompactArenaFrame then
                HandleFrame(_G.CompactArenaFrame, 1)

                for _, frame in next, CompactArenaFrame.memberUnitFrames do
                    HandleFrame(frame, true)
                end
            elseif ArenaEnemyFrames then
                ArenaEnemyFrames:UnregisterAllEvents()
                ArenaPrepFrames:UnregisterAllEvents()
                ArenaEnemyFrames:Hide()
                ArenaPrepFrames:Hide()

                -- reference on oUF and clear the global frame reference, to fix ClearAllPoints taint
                GW.oUF.ArenaEnemyFrames = ArenaEnemyFrames
                GW.oUF.ArenaPrepFrames = ArenaPrepFrames
                ArenaEnemyFrames = nil
                ArenaPrepFrames = nil
            end

            -- actually handle the sub frames now
            for i = 1, MAX_ARENA_ENEMIES do
                HandleFrame(_G['ArenaEnemyMatchFrame'..i], true)
                HandleFrame(_G['ArenaEnemyPrepFrame'..i], true)
            end
        else
            Arena_LoadUI = GW.NoOp

            if not isArenaHooked and CompactArenaFrame then
                isArenaHooked = true
                HandleFrame(CompactArenaFrame, 1)

                for _, frame in next, CompactArenaFrame.memberUnitFrames do
                    HandleFrame(frame, true)
                end

            end
        end
    end

    if ourBossFrames then
        HandleFrame(BossTargetFrameContainer, 1)

        for i = 1, MAX_BOSS_FRAMES do
            HandleFrame("Boss" .. i .. "TargetFrame", true)
        end
    end

    if ourPetFrame then
        HandleFrame(PetFrame)
    end

    if ourTargetFrame then
        HandleFrame(TargetFrame)
        HandleFrame(ComboFrame)
    end

    if ourTargetFrame and ourTargetTargetFrame then
        HandleFrame(TargetFrameToT)
    end

    if ourFocusFrame then
        HandleFrame(FocusFrame)
    end

    if ourFocusFrame and ourFocusTargetFrame then
        HandleFrame(TargetofFocusFrame)
    end

    if ourPlayerFrame then
        HandleFrame(PlayerFrame)

        -- for vehicle support
        PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
        PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
        PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
        PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE")

        PlayerFrame:SetMovable(true)
        PlayerFrame:SetUserPlaced(true)
        PlayerFrame:SetDontSavePosition(true)
    end

    if ourCastBar then
        HandleFrame(PlayerCastingBarFrame, 1)
        HandleFrame("OverlayPlayerCastingBarFrame", 1) -- runs its own events on retail and its stop animations error on the secret protected CastingBarTypeInfo when tainted
        HandleFrame(CastingBarFrame, 1)
        HandleFrame(PetCastingBarFrame, 1)

        -- disbale blizzard castingbar mover
        if GW.Retail or GW.TBC or GW.Mists or GW.Classic then
            PlayerCastingBarFrame:HookScript("OnShow", function() PlayerCastingBarFrame:Hide() end)
            PlayerCastingBarFrame:GwKillEditMode()
        end
    end

    if ourInventory then
        if MicroButtonAndBagsBar then
            MicroButtonAndBagsBar:SetParent(GW.HiddenFrame)
            MicroButtonAndBagsBar:UnregisterAllEvents()
        end
    end

    if ourActionbars then
        local untaint = {
            MultiBar5 = true,
            MultiBar6 = true,
            MultiBar7 = true,
            MultiBarLeft = true,
            MultiBarRight = true,
            MultiBarBottomLeft = true,
            MultiBarBottomRight = true,
            --MainMenuBar = true, -- this make the mainbar unvisible (HiddenFrame) we remove the events at the actionbars
            StanceBar = true
        }

        for name in next, untaint do
            local frame = _G[name]
            if frame then
                frame:SetParent(GW.HiddenFrame)
                frame:UnregisterAllEvents()
            end
        end
    end
end
GW.DisableBlizzardFrames = DisableBlizzardFrames