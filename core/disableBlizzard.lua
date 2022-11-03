local _, GW = ...

local isArenaHooked = false

local function HandleFrame(baseName, doNotReparent)
    local frame
    if type(baseName) == "string" then
        frame = _G[baseName]
    else
        frame = baseName
    end

    if frame then
        frame:UnregisterAllEvents()
        frame:Hide()

        if not doNotReparent then
            frame:SetParent(GW.HiddenFrame)
        end

        local health = frame.healthBar or frame.healthbar or frame.HealthBar
        if health then
            health:UnregisterAllEvents()
        end

        local power = frame.manabar or frame.ManaBar
        if power then
            power:UnregisterAllEvents()
        end

        local spell = frame.castBar or frame.spellbar
        if spell then
            spell:UnregisterAllEvents()
        end

        local altpowerbar = frame.powerBarAlt or frame.PowerBarAlt
        if altpowerbar then
            altpowerbar:UnregisterAllEvents()
        end

        local buffFrame = frame.BuffFrame
        if buffFrame then
            buffFrame:UnregisterAllEvents()
        end

        local petFrame = frame.PetFrame or frame.petFrame
        if petFrame then
            petFrame:UnregisterAllEvents()
        end

        local totFrame = frame.totFrame
        if totFrame then
            totFrame:UnregisterAllEvents()
        end
    end
end


local function DisableBlizzardFrames()
    local ourPartyFrames = GW.GetSetting("PARTY_FRAMES")
    local ourRaidFrames = GW.GetSetting("RAID_FRAMES")
    local ourBossFrames = GW.GetSetting("QUESTTRACKER_ENABLED") and not GW.IsIncompatibleAddonLoadedOrOverride("Objectives", true)
    local ourArenaFrames = not IsAddOnLoaded("sArena") and GW.GetSetting("QUESTTRACKER_ENABLED") and not GW.IsIncompatibleAddonLoadedOrOverride("Objectives", true)
    local ourPetFrame = GW.GetSetting("PETBAR_ENABLED")
    local ourTargetFrame = GW.GetSetting("TARGET_ENABLED")
    local ourTargetTargetFrame = GW.GetSetting("target_TARGET_ENABLED")
    local ourFocusFrame = GW.GetSetting("FOCUS_ENABLED")
    local ourFocusTargetFrame = GW.GetSetting("focus_TARGET_ENABLED")
    local ourPlayerFrame = GW.GetSetting("HEALTHGLOBE_ENABLED")
    local ourCastBar = GW.GetSetting("CASTINGBAR_ENABLED")

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
        PartyFrame:UnregisterAllEvents()
        PartyFrame:SetScript("OnShow", nil)

        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            HandleFrame(frame)
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

            ArenaEnemyFramesContainer:UnregisterAllEvents()
            ArenaEnemyPrepFramesContainer:UnregisterAllEvents()
            ArenaEnemyMatchFramesContainer:UnregisterAllEvents()

            for i = 1, MAX_ARENA_ENEMIES do
                HandleFrame("ArenaEnemyMatchFrame" .. i)
                HandleFrame("ArenaEnemyPrepFrame" .. i)
            end
        end
    end

    if ourBossFrames then
        for i = 1, MAX_BOSS_FRAMES do
            HandleFrame(format("Boss%dTargetFrame", i))
        end
    end

    if ourPetFrame then
        HandleFrame(PetFrame)
    end

    if ourTargetFrame then
        HandleFrame(TargetFrame)
        HandleFrame(ComboFrame)
    end

    if ourTargetTargetFrame then
        HandleFrame(TargetFrameToT)
    end

    if ourFocusFrame then
        HandleFrame(FocusFrame)
    end

    if ourFocusTargetFrame then
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
    end

    if ourCastBar then
        HandleFrame(PlayerCastingBarFrame)
        HandleFrame(PetCastingBarFrame)
    end
end
GW.DisableBlizzardFrames = DisableBlizzardFrames