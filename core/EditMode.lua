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
	EncounterBar = CheckActionBar,
	PetActionBar = CheckActionBar,
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

local function DisableBlizzardMovers()
	local editMode = EditModeManagerFrame

	-- remove the initial registers
	local registered = editMode.registeredSystemFrames
	for i = #registered, 1, -1 do
		local name = registered[i]:GetName()
		local ignore = IgnoreFrames[name]

		if ignore and ignore() then
			tremove(editMode.registeredSystemFrames, i)
		end
	end

	-- account settings will be tainted
	local mixin = editMode.AccountSettings
	if CheckCastFrame() then mixin.RefreshCastBar = GW.NoOp end
	if CheckAuraFrame() then mixin.RefreshAuraFrame = GW.NoOp end
	if CheckBossFrame() then mixin.RefreshBossFrames = GW.NoOp end
	if CheckRaidFrame() then mixin.RefreshRaidFrames = GW.NoOp end
	if CheckArenaFrame() then mixin.RefreshArenaFrames = GW.NoOp end
	if CheckPartyFrame() then mixin.RefreshPartyFrames = GW.NoOp end
	if CheckLootFrame() then mixin.RefreshLootFrame = GW.NoOp end
	if CheckTargetFrame() and CheckFocusFrame() then mixin.RefreshTargetAndFocus = GW.NoOp end
	if CheckActionBar() then
		mixin.RefreshVehicleLeaveButton = GW.NoOp
		mixin.RefreshActionBarShown = GW.NoOp
		mixin.RefreshEncounterBar = GW.NoOp
	end
end
GW.DisableBlizzardMovers = DisableBlizzardMovers