local _, GW = ...
local GetSetting = GW.GetSetting

local CheckTargetFrame = function() return GetSetting("TARGET_ENABLED") end
local CheckCastFrame = function() return GetSetting("CASTINGBAR_ENABLED") end
local CheckArenaFrame = function() return GetSetting("QUESTTRACKER_ENABLED") end
local CheckPartyFrame = function() return GetSetting("PARTY_FRAMES") end
local CheckFocusFrame = function() return GetSetting("FOCUS_ENABLED") end
local CheckRaidFrame = function() return GetSetting("RAID_FRAMES") end
local CheckBossFrame = function() return GetSetting("QUESTTRACKER_ENABLED") end
local CheckAuraFrame = function() return GetSetting("PLAYER_BUFFS_ENABLED") end
local CheckPetActionBar = function() return GetSetting("PETBAR_ENABLED") end
local CheckActionBar = function() return GetSetting("ACTIONBARS_ENABLED") end
local CheckLootFrame = function() return GetSetting("LOOTFRAME_SKIN_ENABLED") and GetCVar("lootUnderMouse") == "0" end

local IgnoreFrames = {
    MinimapCluster = function() return GetSetting("MINIMAP_ENABLED") end,
    GameTooltipDefaultContainer = function() return GetSetting("TOOLTIPS_ENABLED") end,

    -- UnitFrames
    PartyFrame = CheckPartyFrame,
    FocusFrame = CheckFocusFrame,
    TargetFrame = CheckTargetFrame,
    PlayerCastingBarFrame = CheckCastFrame,
    ArenaEnemyFramesContainer = CheckArenaFrame,
    CompactRaidFrameContainer = CheckRaidFrame,
    BossTargetFrameContainer = CheckBossFrame,
    PlayerFrame = function() return GetSetting("HEALTHGLOBE_ENABLED") end,

    -- Auras
    BuffFrame = function() return GetSetting("PLAYER_BUFFS_ENABLED") end,
    DebuffFrame = function() return GetSetting("PLAYER_BUFFS_ENABLED") end,

    -- ActionBars
    StanceBar = CheckActionBar,
    --EncounterBar = CheckActionBar,
    PetActionBar = CheckPetActionBar,
    PossessActionBar = CheckActionBar,
    MainMenuBarVehicleLeaveButton = CheckActionBar,
    MainMenuBar = CheckActionBar,
    MultiBarBottomLeft = CheckActionBar,
    MultiBarBottomRight = CheckActionBar,
    MultiBarLeft = CheckActionBar,
    MultiBarRight = CheckActionBar,
    MultiBar5 = CheckActionBar,
    MultiBar6 = CheckActionBar,
    MultiBar7 = CheckActionBar,

    -- Iventroy
    LootFrame = CheckLootFrame,
}

local ShutdownMode = {
    "OnEditModeEnter",
    "OnEditModeExit",
    "HasActiveChanges",
    "HighlightSystem",
    "SelectSystem",
    -- these will taint the default bars on spec switch
    --- "IsInDefaultPosition",
    --- "UpdateSystem",
}

local function DisableBlizzardMovers()
    local editMode = EditModeManagerFrame
    local LEM = GW.Libs.LEM

    -- first reset the actionbar scale to 100% if our actionbars are active
    if CheckActionBar() then
        -- do that in the users profile, if this is not editable we create a gw2 profile with needed actionbar settings
        --/run GW2_ADDON.Libs.LEM:ReanchorFrame(MainMenuBar, "TOP", UIParent, "BOTTOM", 0, (80 * (tonumber(GW.GetSetting("HUD_SCALE")) or 1))); GW2_ADDON.Libs.LEM:ApplyChanges()
        LEM:LoadLayouts()

        if not LEM:CanEditActiveLayout() then
            if not LEM:DoesLayoutExist("GW2_Layout") then
                LEM:AddLayout(Enum.EditModeLayoutType.Account, "GW2_Layout")
                LEM:ApplyChanges()
            end

            LEM:SetActiveLayout("GW2_Layout")
            LEM:ApplyChanges()
        end

        LEM:SetFrameSetting(MainMenuBar, 3, 5)
        LEM:SetFrameSetting(MultiBarBottomLeft, 3, 5)
        LEM:SetFrameSetting(MultiBarBottomRight, 3, 5)
        LEM:SetFrameSetting(MultiBarRight, 3, 5)
        LEM:SetFrameSetting(MultiBarLeft, 3, 5)
        LEM:SetFrameSetting(MultiBar5, 3, 5)
        LEM:SetFrameSetting(MultiBar6, 3, 5)
        LEM:SetFrameSetting(MultiBar7, 3, 5)

        -- Main Actionbar
        LEM:ReanchorFrame(MainMenuBar, "TOP", UIParent, "BOTTOM", 0, (80 * (tonumber(GW.GetSetting("HUD_SCALE")) or 1)))
        -- PossessActionBar
        LEM:ReanchorFrame(PossessActionBar, "BOTTOM", MainMenuBar, "TOP", -110, 40)

        LEM:ApplyChanges()
    end

    -- remove the initial registers
    local registered = editMode.registeredSystemFrames
    for i = #registered, 1, -1 do
        local frame = registered[i]
        local ignore = IgnoreFrames[frame:GetName()]

        if ignore and ignore() then
            for _, key in next, ShutdownMode do
                frame[key] = GW.NoOp
            end
        end
    end

    -- account settings will be tainted
    local mixin = editMode.AccountSettings
    if CheckCastFrame() then mixin.RefreshCastBar = GW.NoOp end
    if CheckAuraFrame() then mixin.RefreshAuraFrame = GW.NoOp end
    if CheckBossFrame() then mixin.RefreshBossFrames = GW.NoOp end
    if CheckArenaFrame() then mixin.RefreshArenaFrames = GW.NoOp end
    if CheckLootFrame() then mixin.RefreshLootFrame = GW.NoOp end

    if CheckRaidFrame() then
        mixin.RefreshRaidFrames = GW.NoOp
        mixin.ResetRaidFrames = GW.NoOp
    end
    if CheckPartyFrame() then
        mixin.RefreshPartyFrames = GW.NoOp
        mixin.ResetPartyFrames = GW.NoOp
    end
    if CheckTargetFrame() and CheckFocusFrame() then
        mixin.RefreshTargetAndFocus = GW.NoOp
        mixin.ResetTargetAndFocus = GW.NoOp
    end

    if CheckActionBar() then
        mixin.RefreshVehicleLeaveButton = GW.NoOp
        mixin.RefreshActionBarShown = GW.NoOp
        --mixin.RefreshEncounterBar = GW.NoOp
    end
end
GW.DisableBlizzardMovers = DisableBlizzardMovers