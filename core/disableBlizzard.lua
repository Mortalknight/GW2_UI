local _, GW = ...

local isArenaHooked = false
local lockedFrames = {}
local GetSetting = GW.GetSetting

local MAX_PARTY = MEMBERS_PER_RAID_GROUP or MAX_PARTY_MEMBERS or 5
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
local MAX_BOSS_FRAMES = 8

-- lock Boss, Party, and Arena
local function LockParent(frame, parent)
    if parent ~= GW.HiddenFrame then
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
    frame:Hide()

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


local function DisableBlizzardFrames()
    local ourPartyFrames = GetSetting("PARTY_FRAMES")
    local ourRaidFrames = GetSetting("RAID_FRAMES")
    local ourBossFrames = GetSetting("QUESTTRACKER_ENABLED") and not GW.IsIncompatibleAddonLoadedOrOverride("Objectives", true)
    local ourArenaFrames = not IsAddOnLoaded("sArena") and GetSetting("QUESTTRACKER_ENABLED") and not GW.IsIncompatibleAddonLoadedOrOverride("Objectives", true)
    local ourPetFrame = GetSetting("PETBAR_ENABLED")
    local ourTargetFrame = GetSetting("TARGET_ENABLED")
    local ourTargetTargetFrame = GetSetting("target_TARGET_ENABLED")
    local ourFocusFrame = GetSetting("FOCUS_ENABLED")
    local ourFocusTargetFrame = GetSetting("focus_TARGET_ENABLED")
    local ourPlayerFrame = GetSetting("HEALTHGLOBE_ENABLED")
    local ourCastBar = GetSetting("CASTINGBAR_ENABLED")
    local ourActionbars = GetSetting("ACTIONBARS_ENABLED")
    local ourInventory = GetSetting("BAGS_ENABLED")

    if ourPartyFrames or ourRaidFrames then
        -- calls to UpdateRaidAndPartyFrames, which as of writing this is used to show/hide the
        -- Raid Utility and update Party frames via PartyFrame.UpdatePartyFrames not raid frames.
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end

    -- shutdown some background updates on default unitframes
    if ourPartyFrames and CompactPartyFrame then
        CompactPartyFrame:UnregisterAllEvents()
    end

    if ourPartyFrames then
        HandleFrame(PartyFrame, 1)
        PartyFrame:UnregisterAllEvents()
        PartyFrame:SetScript("OnShow", nil)

        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            HandleFrame(frame, true)
        end

        for i = 1, MAX_PARTY do
            HandleFrame("PartyMemberFrame" .. i)
            HandleFrame("CompactPartyFrameMember" .. i)
        end
    end

    if ourRaidFrames then
        if CompactRaidFrameContainer then
            CompactRaidFrameContainer:UnregisterAllEvents()
        end

        -- Raid Utility
        if not CompactRaidFrameManager_SetSetting then
            StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
        else
            CompactRaidFrameManager_SetSetting("IsShown", "0")
        end

        if CompactRaidFrameManager then
            CompactRaidFrameManager:UnregisterAllEvents()
            CompactRaidFrameManager:SetParent(GW.HiddenFrame)
        end
    end

    if ourArenaFrames then
        hooksecurefunc("UnitFrameThreatIndicator_Initialize", function(_, unitFrame)
            unitFrame:UnregisterAllEvents() -- Arena Taint Fix
        end)

        Arena_LoadUI = GW.NoOp

        if not isArenaHooked then
            isArenaHooked = true
            -- this disables ArenaEnemyFramesContainer
            SetCVar("showArenaEnemyFrames", "0")
            SetCVar("showArenaEnemyPets", "0")

            HandleFrame(ArenaEnemyFramesContainer, 1)
            HandleFrame(ArenaEnemyPrepFramesContainer, 1)
            HandleFrame(ArenaEnemyMatchFramesContainer, 1)

            for i = 1, MAX_ARENA_ENEMIES do
                HandleFrame("ArenaEnemyMatchFrame" .. i, true)
                HandleFrame("ArenaEnemyPrepFrame" .. i, true)
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
        HandleFrame(PlayerCastingBarFrame)
        HandleFrame(PetCastingBarFrame)

        -- disbale blizzard castingbar mover
        PlayerCastingBarFrame:HookScript("OnShow", function() PlayerCastingBarFrame:Hide() end)
        PlayerCastingBarFrame:GwKillEditMode()
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

        --MainMenuBar.SetPositionForStatusBars = GW.NoOp
        --MultiActionBar_HideAllGrids = GW.NoOp
        --MultiActionBar_ShowAllGrids = GW.NoOp
    end
end
GW.DisableBlizzardFrames = DisableBlizzardFrames