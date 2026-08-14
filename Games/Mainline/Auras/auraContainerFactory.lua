---@class GW2
local GW = select(2, ...)

-- Shared factory for unit aura containers (12.1 AuraContainer system).
-- On Retail this replaces the UpdateBuffLayout engine from Games/Shared/Aura/auras.lua
-- for pet, target/focus and party. The buttons get the GwAuraFrame look
-- (black backdrop, dispel-colored background as border, white cooldown swipe).
--
-- config = {
--     name = "GwPetAuraContainer",          -- global frame name (optional)
--     unit = "pet",
--     parent = frame,                        -- parent (default UIParent)
--     cancelButtons = "RightButtonUp, RightButtonDown", -- nil = no right-click cancel
--     tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
--     refreshEvents = { "UNIT_PET" },        -- events that trigger UpdateAllAuras
--     refreshUnit = "player",                -- unit for RegisterUnitEvent (nil = regular events)
--     anchorPoint = "TOPRIGHT",              -- starting corner of the flow layout
--     growLeft = false, growUp = false,      -- growth direction
--     vertical = false,                      -- true = column instead of row layout
--     maximumLineSize = 160,                 -- line length in pixels
--     elementSpacing = 3, lineSpacing = 20,
--     groups = {
--         {
--             key = "buffs",                 -- unique group key
--             filter = "HELPFUL",
--             candidateFilters = {...},      -- nil = all (see AuraContainerUtil.DoesAuraPassCandidateFilters)
--             size = 20,                     -- button size
--             iconInset = 1,                 -- icon inset from the edge (1 = small, 3 = big look)
--             maxFrameCount = 32,            -- 0 = group disabled
--             sortMethod = AuraContainerSortMethod.Default,
--             sortDirection = AuraContainerSortDirection.Normal,
--             forceNewLine = false,          -- group starts a new line
--             isDebuff = false,              -- enables dispel coloring of the border
--             bigFont = false,               -- Normal instead of Small fonts (bigBuff look)
--             showStealable = false,         -- stealable buffs get a colored border
--             showDispelIcon = false,        -- dispel type icon in the corner
--             dispelIconSize = 12,
--             showPandemic = false,          -- glow while inside the refresh window
--         },
--     },
-- }
--
-- Returns: the container. Layout/filters/sizes can be re-applied at runtime via
-- container:GwUpdateLayout() after config values have been changed.

-- GW advanced filters are OR-combined — a single filter string cannot express that,
-- but each OR branch is exactly ONE 12.1 filter string (incl. "!" negation and the new
-- tokens DISPELLABLE/CROWD_CONTROL/BIG_DEFENSIVE/...). OR = one container group per branch.
local ADVANCED_FILTER_BRANCHES = {
    { setting = "isAuraCancelablePlayer",        tokens = "CANCELABLE|PLAYER",         side = "player" },
    { setting = "notAuraCancelablePlayer",       tokens = "!CANCELABLE|PLAYER",        side = "player" },
    { setting = "isAuraRaidPlayer",              tokens = "RAID|PLAYER",               side = "player" },
    { setting = "isAuraCrowdControlPlayer",      tokens = "CROWD_CONTROL|PLAYER",      side = "player" },
    { setting = "isAuraBigDefensivePlayer",      tokens = "BIG_DEFENSIVE|PLAYER",      side = "player" },
    { setting = "isAuraExternalDefensivePlayer", tokens = "EXTERNAL_DEFENSIVE|PLAYER", side = "player" },
    { setting = "isAuraRaidInCombatPlayer",      tokens = "RAID_IN_COMBAT|PLAYER",     side = "player" },
    { setting = "isAuraImportantPlayer",         tokens = "IMPORTANT|PLAYER",          side = "player" }, -- token re-added in 12.1
    { setting = "isAuraCancelable",              tokens = "CANCELABLE|!PLAYER",        side = "other" },
    { setting = "notAuraCancelable",             tokens = "!CANCELABLE|!PLAYER",       side = "other" },
    { setting = "isAuraRaid",                    tokens = "RAID|!PLAYER",              side = "other" },
    { setting = "isAuraCrowdControl",            tokens = "CROWD_CONTROL|!PLAYER",     side = "other" },
    { setting = "isAuraBigDefensive",            tokens = "BIG_DEFENSIVE|!PLAYER",     side = "other" },
    { setting = "isAuraExternalDefensive",       tokens = "EXTERNAL_DEFENSIVE|!PLAYER", side = "other" },
    { setting = "isAuraRaidInCombat",            tokens = "RAID_IN_COMBAT|!PLAYER",    side = "other" },
    { setting = "isAuraImportant",               tokens = "IMPORTANT|!PLAYER",         side = "other" }, -- token re-added in 12.1
    -- RAID_PLAYER_DISPELLABLE = "someone in the players group can dispel this", matching
    -- the "Dispellable" label and the old engines IsDispellableByMe check — plain
    -- DISPELLABLE would only mean "has a dispel type", no matter who could remove it
    { setting = "isAuraRaidPlayerDispellable",   tokens = "RAID_PLAYER_DISPELLABLE" },
}

-- Builds the list of filter string branches from a GW advanced filter table
-- (e.g. PET_Buff_Filter_advanced). Simplification to avoid duplicate display:
--   * isAuraPlayer (or cancelable+notCancelable together = all) covers the whole side,
--     the individual branches of that side are then dropped as subsets.
--   * Remaining overlaps (e.g. RAID|PLAYER vs. CANCELABLE|PLAYER) are possible and
--     show an aura twice — the more exotic the combination, the rarer the case.
-- Returns: array of { filter = "HELPFUL|...", isPlayer = bool } — empty = nothing selected.
function GW.BuildAdvancedAuraFilterBranches(base, db)
    local branches = {}
    if not db then return branches end

    local playerAll = db.isAuraPlayer or (db.isAuraCancelablePlayer and db.notAuraCancelablePlayer)
    local otherAll = db.isAuraCancelable and db.notAuraCancelable

    if playerAll then
        tinsert(branches, { filter = base .. "|PLAYER", isPlayer = true })
    end
    if otherAll then
        tinsert(branches, { filter = base .. "|!PLAYER", isPlayer = false })
    end

    for _, branch in ipairs(ADVANCED_FILTER_BRANCHES) do
        local sideCovered = (branch.side == "player" and playerAll) or (branch.side == "other" and otherAll)
        if db[branch.setting] and not sideCovered then
            tinsert(branches, { filter = base .. "|" .. branch.tokens, isPlayer = branch.side == "player" })
        end
    end

    return branches
end

-- Stealable buffs use one color for every dispel type; customDispelColorMap is keyed
-- by dispel type name, "None" covers auras without one
local stealableColorMap
local function GetStealableColorMap()
    if not stealableColorMap then
        stealableColorMap = {}
        local color = GW.Colors.DebuffColors.Stealable
        for name in next, GW.Enum.DispelType do
            stealableColorMap[name] = color
        end
        stealableColorMap.None = color
    end
    return stealableColorMap
end

-- Step curve dispel type -> GW debuff color, shared by every aura consumer
-- (factory buttons, player bars)
local debuffColorCurve
local function GetDebuffColorCurve()
    if not debuffColorCurve and C_CurveUtil then
        debuffColorCurve = C_CurveUtil.CreateColorCurve()
        debuffColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, GW.Enum.DispelType do
            if GW.Colors.DebuffColors[dispelIndex] then
                debuffColorCurve:AddPoint(dispelIndex, GW.Colors.DebuffColors[dispelIndex])
            end
        end
    end
    return debuffColorCurve
end
GW.GetDebuffColorCurve = GetDebuffColorCurve

-- Container tooltips are global for all AuraContainers — switch them to the GW look
-- once, but only if the GW tooltip skin is active (TOOLTIPS_ENABLED)
local tooltipStyled = false
local function EnsureTooltipStyle()
    if tooltipStyled or not GW.settings.TOOLTIPS_ENABLED then return end
    tooltipStyled = true

    AuraContainerInbound.SetTooltipBackdrop({
        backdropInfo = GW.BackdropTemplates.Default,
    })
end
GW.EnsureAuraTooltipStyle = EnsureTooltipStyle

-- Central registry of all aura containers: settings that affect several frame types
-- (e.g. RAIDDEBUFFS toggles/scale) refresh everything with ONE call instead of poking
-- each consumer — future grid containers join automatically on creation.
-- A container may carry cfg.onSettingsRefresh to re-derive its config from settings
-- (e.g. the party containers recompute sizes/filters); default is a plain re-apply.
local containerRegistry = {}

-- change-detection generation: ApplyLayout skips re-applying candidate filters when
-- the SOURCE tables are unchanged — but the engine holds a secure copy, so in-place
-- mutations (e.g. the RAIDDEBUFFS list) are invisible to a reference compare. The
-- central refresh bumps the generation, which invalidates every cached application.
local settingsGeneration = 0

local function RegisterAuraContainer(container, refreshFunc)
    tinsert(containerRegistry, { container = container, refresh = refreshFunc })
end
GW.RegisterAuraContainer = RegisterAuraContainer

-- invalidate the cached candidate filter applications WITHOUT refreshing anything:
-- callers that mutate a filter table in place (e.g. the spell list widget writing
-- into an ignore list) bump the generation, the consumers' own settings callbacks
-- then re-apply with fresh data
function GW.BumpAuraContainerSettingsGeneration()
    settingsGeneration = settingsGeneration + 1
end

-- Pandemic highlight: a border glow the engine shows while the aura is inside its
-- refresh window. The region hangs on an own holder frame the engine knows nothing
-- about - the opt out hides the HOLDER, so it can never fight whatever the engine
-- does to the region itself (Shown today, possibly alpha animations with 12.1.5).
-- isEnabled is the hosts per frame setting getter, re-evaluated on every update.
-- The engine owns the button lists — enumerate instead of caching them ourselves.
-- Group keys come from gwConfig.groups (factory containers, including the advanced
-- branch slots appended later) or gwGroupKeys (containers with fixed groups)
local function ForEachGroupButton(container, groupKey, func)
    for i = 1, container:GetAuraGroupFrameCount(groupKey) do
        func(container:GetAuraGroupFrame(groupKey, i))
    end
end

local function ForEachContainerButton(container, func)
    if container.gwGroupKeys then
        for _, key in ipairs(container.gwGroupKeys) do
            ForEachGroupButton(container, key, func)
        end
    elseif container.gwConfig and container.gwConfig.groups then
        for _, group in ipairs(container.gwConfig.groups) do
            ForEachGroupButton(container, group.key, func)
        end
    end
end
GW.ForEachAuraContainerButton = ForEachContainerButton

local PANDEMIC_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/pandemic-glow.png"

-- Remove* takes a raw list index and table.removes it — stored indices go stale as
-- soon as the list changes. The registered texture keeps its identity (the inbound
-- wrapper returns the same object), so the index is looked up at removal time instead
local function RemoveDispelTypeTextureByIdentity(button, texture)
    for i = button:GetDispelTypeTextureCount(), 1, -1 do
        if button:GetDispelTypeTexture(i) == texture then
            button:RemoveDispelTypeTexture(i)
            return
        end
    end
end

-- Both regions are engine driven and their Shown state becomes a secret aspect on
-- registration — the opt out therefore DE-REGISTERS the region (Remove*) instead of
-- hiding it. A removed region keeps its last engine state, so its texture content is
-- cleared to render nothing; re-enabling restores it and registers again.
local function ApplyAuraOptionRegions(button)
    local pandemic = button.gwPandemicRegion
    if pandemic then
        if button.gwPandemicEnabled() then
            if not button.gwPandemicIndex then
                pandemic:SetTexture(PANDEMIC_TEXTURE)
                button.gwPandemicIndex = button:AddPandemicRegion(pandemic)
            end
        elseif button.gwPandemicIndex then
            -- the buttons only pandemic region is ours, the stored index stays valid
            button:RemovePandemicRegion(button.gwPandemicIndex)
            button.gwPandemicIndex = nil
            pandemic:SetTexture()
        end
    end

    local dispelIcon = button.gwDispelIcon
    if dispelIcon then
        if button.gwDispelIconEnabled() then
            if not button.gwDispelIconRegistered then
                button:AddDispelTypeTexture(dispelIcon, button.gwDispelIconOptions)
                button.gwDispelIconRegistered = true
            end
        elseif button.gwDispelIconRegistered then
            RemoveDispelTypeTextureByIdentity(button, dispelIcon)
            button.gwDispelIconRegistered = nil
            dispelIcon:SetTexture()
        end
    end
end

function GW.UpdateAuraOptionRegions()
    if InCombatLockdown() then return end

    for _, entry in ipairs(containerRegistry) do
        ForEachContainerButton(entry.container, ApplyAuraOptionRegions)
    end
end

-- Pandemic border glow, shown by the engine while the aura is inside its refresh
-- window. textureParent overrides where the region is created (buttons whose visuals
-- live directly on the button need it there for the draw order)
function GW.AddPandemicHighlight(button, anchor, isEnabled, textureParent)
    local region = (textureParent or anchor):CreateTexture(nil, "OVERLAY", nil, 1)
    region:SetPoint("TOPLEFT", anchor, "TOPLEFT", -4, 4)
    region:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
    region:SetVertexColor(1, 0.4, 0.25)

    button.gwPandemicRegion = region
    button.gwPandemicEnabled = isEnabled
    ApplyAuraOptionRegions(button)
end

-- Dispel type icon in the top right corner of the aura, shown by the engine while
-- the aura carries a dispel type
function GW.AddDispelTypeIcon(button, anchor, group, isEnabled)
    local size = group.dispelIconSize or 12
    local dispelIcon = anchor:CreateTexture(nil, "OVERLAY", nil, 2)
    dispelIcon:SetSize(size, size)
    dispelIcon:SetPoint("CENTER", anchor, "TOPRIGHT", -1, -1)

    button.gwDispelIcon = dispelIcon
    button.gwDispelIconEnabled = isEnabled
    button.gwDispelIconOptions = {
        style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
        showWhenHarmful = group.isDebuff and true or false,
        showWhenHelpful = not group.isDebuff and true or false,
        showWithoutDispelType = false,
    }
    ApplyAuraOptionRegions(button)
end

function GW.RefreshAllAuraContainers()
    settingsGeneration = settingsGeneration + 1
    for _, entry in ipairs(containerRegistry) do
        if entry.refresh then
            entry.refresh(entry.container)
        elseif entry.container.gwConfig and entry.container.gwConfig.onSettingsRefresh then
            entry.container.gwConfig.onSettingsRefresh(entry.container)
        elseif entry.container.GwUpdateLayout then
            entry.container:GwUpdateLayout()
        end
    end
end

-- Height of the duration text strip below the icon; it is part of the BUTTON size
-- (not extra line spacing) so that the container's self-measured size covers the
-- full visual extent — other frames can then be anchored directly beneath it
local DURATION_TEXT_HEIGHT = 14

local function GetGroupTextPad(group)
    return group.hideDuration and 0 or DURATION_TEXT_HEIGHT
end

-- Applies the size to wrapper and button; only callable via pcall — while auras
-- are secret the access restriction denies tainted access to the whole subtree.
-- The applied size is recorded on success so unchanged layout passes can skip it.
local function SetAuraButtonSize(button, size, textPad)
    button.gwVisual:SetSize(size, size)
    button:SetSize(size, size + textPad)
    button.gwAppliedSize = size
    button.gwAppliedTextPad = textPad
end

-- Duration text formatter: like Blizzard's DefaultAuraDurationFormatter (single unit,
-- values <= 90s/90m/36h stay in the smaller interval), but WITHOUT the whitespace
-- between value and unit ("17s" instead of "17 s") — deDE/ruRU keep the whitespace
-- by default, which makes wide values overlap the neighboring buttons
local durationTextFormatter
local function GetDurationTextFormatter()
    if not durationTextFormatter then
        -- '+1' because curves promote to the next interval on exact matches —
        -- 90 should still render as "90s", not as "1m" (cf. Blizzard_AuraContainerShared)
        local maxIntervalCurve = C_CurveUtil.CreateCurve()
        maxIntervalCurve:AddPoint(1 + (1.5 * 60), Enum.SecondsFormatterInterval.Minutes)
        maxIntervalCurve:AddPoint(1 + (1.5 * 3600), Enum.SecondsFormatterInterval.Hours)
        maxIntervalCurve:AddPoint(1 + (1.5 * 86400), Enum.SecondsFormatterInterval.Days)

        durationTextFormatter = C_StringUtil.CreateSecondsFormatter()
        durationTextFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
        durationTextFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds)
        durationTextFormatter:SetMaxIntervalCurve(maxIntervalCurve)
        durationTextFormatter:SetDesiredUnitCount(1)
        durationTextFormatter:SetStripIntervalWhitespace(Enum.SecondsFormatterIntervalWhitespace.StripIgnoreLocale)
    end
    return durationTextFormatter
end
GW.GetAuraDurationTextFormatter = GetDurationTextFormatter

-- Sort presets for the per-unitframe "Aura Sorting" setting
local AURA_SORT_PRESETS = {
    DEFAULT = { method = AuraContainerSortMethod.Default, direction = AuraContainerSortDirection.Normal },
    EXPIRATION_ASC = { method = AuraContainerSortMethod.ExpirationOnly, direction = AuraContainerSortDirection.Normal },
    EXPIRATION_DESC = { method = AuraContainerSortMethod.ExpirationOnly, direction = AuraContainerSortDirection.Reverse },
    NAME_ASC = { method = AuraContainerSortMethod.NameOnly, direction = AuraContainerSortDirection.Normal },
    NAME_DESC = { method = AuraContainerSortMethod.NameOnly, direction = AuraContainerSortDirection.Reverse },
}

function GW.GetAuraSortPreset(value)
    return AURA_SORT_PRESETS[value] or AURA_SORT_PRESETS.DEFAULT
end

-- GwAuraFrame look for a container button (cf. aurabar_legacy.xml + setAuraType):
-- black 1px backdrop, background as border (dispel color for debuffs),
-- white cooldown swipe, icon with inset, stacks inside the icon, duration text below
local function BuildAuraButton(button, container, group)
    -- The button itself is forbidden (secret aspects) — the visuals hang off a wrapper.
    -- The wrapper is anchored to the TOP (the strip below it belongs to the duration
    -- text) and explicitly sized: the button only accepts SetSize during
    -- initializeFrame (access restrictions are applied afterwards), so later size
    -- changes have to be carried by our own frame
    local visual = CreateFrame("Frame", nil, button)
    visual:SetPoint("TOP", button, "TOP")
    visual:SetSize(group.size, group.size)
    visual:SetFrameLevel(button:GetFrameLevel() + 1)
    button.gwVisual = visual

    local backdrop = visual:CreateTexture(nil, "ARTWORK", nil, -1)
    backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    backdrop:SetVertexColor(0, 0, 0)
    backdrop:SetPoint("TOPLEFT", visual, "TOPLEFT", -1, 1)
    backdrop:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", 1, -1)

    local background = visual:CreateTexture(nil, "ARTWORK")
    background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    background:SetVertexColor(0, 0, 0)
    background:SetAllPoints(visual)
    button.background = background

    -- visible swipe ring = icon inset minus cooldown inset; keep it at 1px so the
    -- ring looks as slim as on the player buff bar (2px on 32px buttons there)
    local swipeInset = math.max(0, (group.iconInset or 1) - 1)
    local cooldown = CreateFrame("Cooldown", nil, visual, "CooldownFrameTemplate")
    cooldown:SetFrameLevel(visual:GetFrameLevel() + 1)
    cooldown:SetPoint("TOPLEFT", visual, "TOPLEFT", swipeInset, -swipeInset)
    cooldown:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -swipeInset, swipeInset)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawSwipe(true)
    cooldown:SetReverse(false)
    cooldown:SetHideCountdownNumbers(true)
    cooldown:SetSwipeTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png", 1, 1, 1, 1)
    button.cooldown = cooldown

    local status = CreateFrame("Frame", nil, visual)
    status:SetFrameLevel(visual:GetFrameLevel() + 2)
    status:SetAllPoints(visual)
    button.status = status

    local inset = group.iconInset or 1
    status.icon = status:CreateTexture(nil, "OVERLAY")
    status.icon:SetPoint("TOPLEFT", status, "TOPLEFT", inset, -inset)
    status.icon:SetPoint("BOTTOMRIGHT", status, "BOTTOMRIGHT", -inset, inset)
    status.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    local overlay = status:CreateTexture(nil, "OVERLAY", nil, 1)
    overlay:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-overlay.png")
    overlay:SetPoint("TOPLEFT", status.icon)
    overlay:SetPoint("BOTTOMRIGHT", status.icon)

    local textSize = group.bigFont and GW.Enum.TextSizeType.Normal or GW.Enum.TextSizeType.Small
    status.stacks = status:CreateFontString(nil, "OVERLAY")
    status.stacks:SetJustifyH("CENTER")
    status.stacks:SetJustifyV("BOTTOM")
    status.stacks:SetPoint("TOPLEFT", status.icon, "TOPLEFT", -10, 0)
    status.stacks:SetPoint("BOTTOMRIGHT", status.icon, "BOTTOMRIGHT", 10, 0)
    status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, textSize, "OUTLINE", group.bigFont and 0 or -1)

    if not group.hideDuration then
        status.duration = status:CreateFontString(nil, "OVERLAY")
        status.duration:SetJustifyH("CENTER")
        status.duration:SetHeight(14)
        status.duration:SetPoint("TOPLEFT", status, "BOTTOMLEFT", -10, 0)
        status.duration:SetPoint("TOPRIGHT", status, "BOTTOMRIGHT", 10, 0)
        status.duration:GwSetFontTemplate(UNIT_NAME_FONT, textSize, nil, group.bigFont and 0 or -1)
    end

    -- the container takes care of the display updates
    button:SetIcon(status.icon)
    button:SetDurationCooldown(cooldown)
    if status.duration then
        button:SetDurationText(status.duration, { textFormatter = GetDurationTextFormatter() })
    end
    button:SetApplicationCount(status.stacks)

    local cfg = container.gwConfig
    -- prefix match: advanced filter branches ("HELPFUL|CANCELABLE|...") are
    -- cancelable buffs as well
    if cfg.cancelButtons and group.filter and group.filter:sub(1, 7) == "HELPFUL" then
        button:SetCancelAuraButtons(cfg.cancelButtons)
    end
    if cfg.enableMouse == false then
        -- pure display buttons (e.g. grid frames with tooltips disabled): no aura
        -- tooltip and no mouse interception over the underlying unit button
        button:EnableMouse(false)
    end
    if cfg.tooltipAnchor then
        button:SetTooltipAnchorPoint(unpack(cfg.tooltipAnchor))
    end

    if group.isDebuff then
        button:AddDispelTypeTexture(background, {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
            showWhenHarmful = true,
            showWithoutDispelType = true,
            customDispelColorCurve = GetDebuffColorCurve(),
        })
    end

    if group.showStealable then
        local stealable = visual:CreateTexture(nil, "ARTWORK", nil, 1)
        stealable:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        stealable:SetAllPoints(visual)
        button.gwStealableBorder = stealable

        button:AddDispelTypeTexture(stealable, {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
            stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable,
            showWhenHelpful = true,
            showWhenHarmful = false,
            showWithoutDispelType = true,
            customDispelColorMap = GetStealableColorMap(),
        })
    end

    -- every debuff group carries the region, the three state setting decides the
    -- registration live: "ALL" puts the icon on every debuff with a dispel type,
    -- "DISPELLABLE" only on the groups holding the player-dispellable half of the
    -- split (showDispelIcon — for advanced slots that role can change with the
    -- selected filters, the getter reads the CURRENT one), "OFF" on none
    local dispelIconGetter = container.gwConfig and container.gwConfig.dispelIconEnabled
    if dispelIconGetter and group.isDebuff then
        GW.AddDispelTypeIcon(button, visual, group, function()
            local mode = dispelIconGetter()
            if mode == "ALL" then return true end
            return mode == "DISPELLABLE" and group.showDispelIcon or false
        end)
    end

    -- the getter decides the VISIBILITY (live, via UpdatePandemicHighlights) — the
    -- region itself is always built when the host wires a setting, so enabling it
    -- later never needs a reload
    local pandemicSettingGetter = container.gwConfig and container.gwConfig.pandemicEnabled
    if group.showPandemic and pandemicSettingGetter then
        GW.AddPandemicHighlight(button, visual, pandemicSettingGetter)
    end

    if cfg.hideTooltipInCombat then
        button:SetHideTooltipInCombat(true)
    end

    button.gwGroup = group
    SetAuraButtonSize(button, group.size, GetGroupTextPad(group))
end

local function ApplyLayout(container)
    local cfg = container.gwConfig

    -- every engine setter below can trigger a container re-evaluation — with many
    -- containers (grids!) a full re-apply per settings pass freezes the client, so
    -- each block is skipped when its inputs are unchanged
    local flowSig = strjoin(":", cfg.vertical and "V" or "H", cfg.anchorPoint or "TOPLEFT",
        cfg.growLeft and "L" or "R", cfg.growUp and "U" or "D", tostring(cfg.maximumLineSize or 0))
    if container.gwAppliedFlowSig ~= flowSig then
        container.gwAppliedFlowSig = flowSig
        container:SetFlowLayoutAxis(cfg.vertical and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
        container:SetFlowLayoutAnchorPoint(cfg.anchorPoint or "TOPLEFT")
        container:SetFlowLayoutGrowthDirection(
            cfg.growLeft and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
            cfg.growUp and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
        )
        container:SetFlowLayoutMaximumLineSize(cfg.maximumLineSize or math.huge)
    end

    for index, group in ipairs(cfg.groups) do
        local textPad = GetGroupTextPad(group)

        if group.gwAppliedFilter ~= group.filter then
            group.gwAppliedFilter = group.filter
            container:SetAuraGroupFilterString(group.key, group.filter)
        end

        -- container-wide ignore list (cfg.excludeSpellIDs, e.g. the "Ignored Auras"
        -- setting) is merged into every group's candidate filters. Reference compare
        -- plus the settings generation (see RefreshAllAuraContainers) — the engine
        -- keeps a secure copy, in-place table mutations need the generation bump
        if group.gwAppliedCandidates ~= group.candidateFilters
            or group.gwAppliedExclude ~= cfg.excludeSpellIDs
            or group.gwAppliedGeneration ~= settingsGeneration then
            group.gwAppliedCandidates = group.candidateFilters
            group.gwAppliedExclude = cfg.excludeSpellIDs
            group.gwAppliedGeneration = settingsGeneration

            local candidateFilters = group.candidateFilters
            if cfg.excludeSpellIDs and next(cfg.excludeSpellIDs) then
                candidateFilters = candidateFilters and CopyTable(candidateFilters, true) or {}
                candidateFilters.excludeSpellIDs = cfg.excludeSpellIDs
            end
            container:SetAuraGroupCandidateFilters(group.key, candidateFilters or {})
        end

        local maxFrameCount = group.maxFrameCount or math.huge
        if group.gwAppliedMaxCount ~= maxFrameCount then
            group.gwAppliedMaxCount = maxFrameCount
            container:SetAuraGroupMaxFrameCount(group.key, maxFrameCount)
        end

        local sortMethod = group.sortMethod or AuraContainerSortMethod.Default
        local sortDirection = group.sortDirection or AuraContainerSortDirection.Normal
        if group.gwAppliedSortMethod ~= sortMethod or group.gwAppliedSortDirection ~= sortDirection then
            group.gwAppliedSortMethod = sortMethod
            group.gwAppliedSortDirection = sortDirection
            container:SetAuraGroupSortMethod(group.key, sortMethod, sortDirection)
        end

        local layoutSig = strjoin(":", tostring(cfg.elementSpacing or 3), tostring(cfg.lineSpacing or 20),
            tostring(group.size), tostring(textPad), tostring(group.forceNewLine or false), tostring(group.layoutIndex or index))
        if group.gwAppliedLayoutSig ~= layoutSig then
            group.gwAppliedLayoutSig = layoutSig
            container:SetAuraGroupLayout(group.key, {
                elementSpacing = cfg.elementSpacing or 3,
                lineSpacing = cfg.lineSpacing or 20,
                -- spacing at GROUP boundaries (e.g. a forceNewLine transition) is governed
                -- by the group values, not by element/lineSpacing — keep them in sync
                groupSpacing = cfg.elementSpacing or 3,
                groupLineSpacing = cfg.lineSpacing or 20,
                elementWidth = group.size,
                -- element height includes the duration text strip below the icon
                elementHeight = group.size + textPad,
                forceNewLine = group.forceNewLine or false,
                layoutIndex = group.layoutIndex or index,
            })
        end

        -- the flow layout does not set the frame size itself (only anchors) — apply
        -- sizes best-effort: the access restriction (DenyTaintedAccessWhenAurasAreSecret)
        -- covers the WHOLE button subtree including our own child frames while auras
        -- are secret; failed buttons keep their creation size until the next layout
        -- pass outside that state
        ForEachGroupButton(container, group.key, function(button)
            if button.gwAppliedSize ~= group.size or button.gwAppliedTextPad ~= textPad then
                pcall(SetAuraButtonSize, button, group.size, textPad)
            end
        end)
    end
end

-- Advanced filter branches as reusable group slots: container groups cannot be
-- removed after the fact, but their filter string is swappable
-- (SetAuraGroupFilterString) — unused slots are muted via maxFrameCount = 0.
-- templateProvider(branch, index) supplies the group template (size, isDebuff, layoutIndex, ...).
-- skipApplyLayout: when several branch sets go onto the SAME container, only the
-- last call should run the layout
local function SetAdvancedBranches(container, baseKey, branches, templateProvider, skipApplyLayout)
    local cfg = container.gwConfig
    container.gwAdvancedSlots = container.gwAdvancedSlots or {}
    local slots = container.gwAdvancedSlots[baseKey]
    if not slots then
        slots = {}
        container.gwAdvancedSlots[baseKey] = slots
    end

    for i, branch in ipairs(branches or {}) do
        local template = templateProvider(branch, i)
        local group = slots[i]
        if not group then
            group = template
            group.key = baseKey .. "Advanced" .. i
            group.filter = branch.filter
            slots[i] = group
            tinsert(cfg.groups, group)
            container:AddAuraGroup(group.key, branch.filter, {
                initializeFrame = function(button) BuildAuraButton(button, container, group) end,
            })
        else
            -- Reuse the slot: update filter + base data (fonts/insets of the already
            -- built buttons are kept — so deliver the branches in a stable sort order)
            group.filter = branch.filter
            group.size = template.size
            group.maxFrameCount = template.maxFrameCount
            group.layoutIndex = template.layoutIndex or group.layoutIndex
            group.forceNewLine = template.forceNewLine
            group.candidateFilters = template.candidateFilters
            group.sortMethod = template.sortMethod
            group.sortDirection = template.sortDirection
            if group.showDispelIcon ~= template.showDispelIcon then
                -- the slot switched between the dispel icon role and the rest role —
                -- the existing buttons re-evaluate their (de)registration via the getter
                group.showDispelIcon = template.showDispelIcon
                ForEachGroupButton(container, group.key, ApplyAuraOptionRegions)
            end
        end
    end

    for i = #(branches or {}) + 1, #slots do
        slots[i].maxFrameCount = 0
    end

    if not skipApplyLayout then
        ApplyLayout(container)
    end
end

-- Maps the shared per-unit aura settings (preset/advanced filters, sorting, ignore
-- list, icon sizes) onto the two stacked containers of a frame (buffs + debuffs with
-- the static groups buffsOwn/buffs and debuffsOwn/debuffs). Growth direction and
-- anchoring stay with the caller — they are frame specific. Triggers the layout via
-- GwSetAdvancedBranches, so set growth fields on the configs BEFORE calling this.
--
-- opts = {
--     smallSize = 20, bigSize = 24,        -- other players' / own aura button size
--     buffFilter = "all|none|advanced",    -- preset setting values
--     debuffFilter = "all|none|player|advanced",
--     buffAdvanced = {...}, debuffAdvanced = {...}, -- advanced filter tables
--     sort = "DEFAULT",                    -- see GW.GetAuraSortPreset
--     excludeSpellIDs = {...},             -- ignore list ({[spellID] = true})
-- }
function GW.ApplyAuraContainerSettings(buffContainer, debuffContainer, opts)
    local cfg = buffContainer.gwConfig
    local debuffCfg = debuffContainer.gwConfig

    local buffBranches = opts.buffFilter == "advanced" and GW.BuildAdvancedAuraFilterBranches("HELPFUL", opts.buffAdvanced) or nil
    local debuffBranches = opts.debuffFilter == "advanced" and GW.BuildAdvancedAuraFilterBranches("HARMFUL", opts.debuffAdvanced) or nil
    -- empty advanced selection behaves like the old noFilter (= show everything)
    if buffBranches and #buffBranches == 0 then buffBranches = nil end
    if debuffBranches and #debuffBranches == 0 then debuffBranches = nil end

    -- dispel icon boundary for the advanced branches, mirroring SplitDispelIconGroups:
    -- every debuff branch splits into its DISPELLABLE part (carries the icon) and the
    -- rest. Splitting ALL branches keeps the icon role of each reusable slot positionally
    -- stable when the selected filters change (slots keep their buttons)
    if debuffBranches and opts.showDispelIcon then
        local split = {}
        for _, branch in ipairs(debuffBranches) do
            if branch.filter:find("RAID_PLAYER_DISPELLABLE", 1, true) then
                -- already bounded by the player-dispellable token, no twin needed
                branch.gwDispelIcon = true
                tinsert(split, branch)
            else
                tinsert(split, { filter = branch.filter .. "|RAID_PLAYER_DISPELLABLE", isPlayer = branch.isPlayer, gwDispelIcon = true })
                tinsert(split, { filter = branch.filter .. "|!RAID_PLAYER_DISPELLABLE", isPlayer = branch.isPlayer })
            end
        end
        debuffBranches = split
    end

    local buffMax = opts.buffFilter == "none" and 0 or 32
    local debuffMax = opts.debuffFilter == "none" and 0 or 40
    local sort = GW.GetAuraSortPreset(opts.sort)

    cfg.excludeSpellIDs = opts.excludeSpellIDs
    debuffCfg.excludeSpellIDs = opts.excludeSpellIDs

    -- static groups: sizes + mute states (advanced active mutes them, the branches
    -- take over); the sort applies to every group including the advanced slots
    for _, group in next, cfg.groups do
        group.sortMethod = sort.method
        group.sortDirection = sort.direction
        if group.key == "buffsOwn" then
            group.size = opts.bigSize
            group.maxFrameCount = buffBranches and 0 or buffMax
        elseif group.key == "buffs" then
            group.size = opts.smallSize
            group.maxFrameCount = buffBranches and 0 or buffMax
        end
    end
    for _, group in next, debuffCfg.groups do
        group.sortMethod = sort.method
        group.sortDirection = sort.direction
        -- the dispel icon split (SplitDispelIconGroups) leaves a twin group behind each
        -- of the static keys — it follows its original in everything but the icon
        local baseKey = group.gwBaseKey or group.key
        if baseKey == "debuffsOwn" then
            group.size = opts.bigSize
            group.maxFrameCount = debuffBranches and 0 or debuffMax
        elseif baseKey == "debuffs" then
            group.size = opts.smallSize
            -- the "player" preset shows own debuffs only — mute the others group
            group.maxFrameCount = (debuffBranches or opts.debuffFilter == "player") and 0 or debuffMax
        end
    end

    local function branchTemplate(baseLayoutIndex, isDebuff)
        return function(branch, index)
            local template = {
                size = branch.isPlayer and opts.bigSize or opts.smallSize,
                maxFrameCount = isDebuff and 40 or 32,
                isDebuff = isDebuff or nil,
                gwAdvancedSlot = true,
                layoutIndex = baseLayoutIndex + index * 0.01,
                sortMethod = sort.method,
                sortDirection = sort.direction,
                -- keep the static groups' extras (see the frame configs)
                showStealable = (not isDebuff) and opts.showStealable or nil,
                showPandemic = branch.isPlayer and opts.showPandemic or nil,
                -- only the DISPELLABLE half of a split branch carries the icon
                showDispelIcon = (isDebuff and opts.showDispelIcon and branch.gwDispelIcon) or nil,
            }
            if branch.isPlayer then
                template.iconInset = 2
                template.bigFont = true
            end
            return template
        end
    end

    buffContainer:GwSetAdvancedBranches("buffs", buffBranches, branchTemplate(1, false))
    debuffContainer:GwSetAdvancedBranches("debuffs", debuffBranches, branchTemplate(3, true))
end

-- The container only refreshes on UNIT_AURA — if the unit BEHIND the token changes
-- (pet swap, target change, roster update), UpdateAllAuras must be triggered
local function AttachRefreshWatcher(container, config)
    if not config.refreshEvents then
        return
    end

    local watcher = CreateFrame("Frame")
    for _, event in next, config.refreshEvents do
        if config.refreshUnit then
            watcher:RegisterUnitEvent(event, config.refreshUnit)
        else
            watcher:RegisterEvent(event)
        end
    end
    watcher:SetScript("OnEvent", function()
        container:UpdateAllAuras()
    end)
    container.gwRefreshWatcher = watcher
end

-- SetUnit plus the deferred first enable for containers that were created before
-- their unit existed (see the comment in CreateUnitAuraContainer)
local function GwContainerSetUnit(container, unit)
    if not unit then
        return
    end
    container:SetUnit(unit)
    if not container.gwEnabled then
        container.gwEnabled = true
        container:SetEnabled(true)
    end
end

-- Single-button tracker container: the AuraContainer finds the aura in its secure
-- environment (works even while aura values are secret) and drives display widgets
-- engine-side — a StatusBar as remaining-duration bar (SetDurationBar) and/or a
-- FontString as application counter (SetApplicationCount). No Lua arithmetic on
-- duration/expirationTime is involved, so this is fully secret-proof.
-- Used by the classpower spec trackers (Shield of the Righteous, Metamorphosis,
-- pet Frenzy, Mongoose Fury, ...).
--
-- The inbound widgets MUST be descendants of the aura button (the container
-- validates this and forbids reparenting afterwards) — they are therefore built
-- inside createWidgets, as children of the button. The button is shown/hidden by
-- the container depending on whether the tracked aura is present, so the whole
-- display disappears automatically when the aura is missing.
--
-- config = {
--     name = "GwClassPowerTrackerX",     -- global frame name (optional)
--     parent = frame,                     -- default UIParent; position the returned
--                                         -- container yourself (normal frame)
--     unit = "player",
--     filter = "HELPFUL",                 -- base filter string
--     spellIDs = { [132403] = true },     -- tracked spells ({[spellID] = true})
--     width = 164, height = 14,           -- button size (widgets usually fill it)
--     createWidgets = function(button)    -- build widgets as children of the button;
--         return { durationBar = bar,     --   optional: engine-driven decay bar
--                  durationText = fs,     --   optional: engine-driven countdown text
--                  counterText = fs }     --   optional: stacks (empty at 0/1 stacks)
--     end,
--     refreshEvents = { "UNIT_PET" },     -- events that trigger UpdateAllAuras
--     refreshUnit = "player",             -- unit for RegisterUnitEvent (nil = regular)
-- }
function GW.CreateAuraTrackerContainer(config)
    local container = CreateFrame("AuraContainer", config.name, config.parent or UIParent, "CustomAuraContainerTemplate")
    container.gwConfig = config
    container.gwSkipAlphaRecursion = true -- engine child buttons reject tainted SetAlpha
    container.gwGroupKeys = { "tracker" }
    container:SetSize(config.width or 1, config.height or 1)

    container:AddAuraGroup("tracker", config.filter, {
        initializeFrame = function(button)
            -- the flow layout only anchors, it never sizes — and after initialization
            -- the button subtree becomes access restricted, so size it now
            button:SetSize(config.width or 1, config.height or 1)
            -- trackers are pure displays: no aura tooltip, no mouse interception
            button:EnableMouse(false)

            local widgets = config.createWidgets and config.createWidgets(button) or {}
            if widgets.durationBar then
                button:SetDurationBar(widgets.durationBar, {
                    direction = Enum.StatusBarTimerDirection.RemainingTime,
                })
            end
            if widgets.durationText then
                button:SetDurationText(widgets.durationText, { textFormatter = GetDurationTextFormatter() })
            end
            if widgets.counterText then
                button:SetApplicationCount(widgets.counterText)
            end
        end,
    })
    container:SetAuraGroupCandidateFilters("tracker", { includeSpellIDs = config.spellIDs })
    container:SetAuraGroupMaxFrameCount("tracker", 1)
    container.GwSetUnit = GwContainerSetUnit
    -- same unit guard as CreateUnitAuraContainer: no unit yet = stay disabled
    if config.unit then
        container.gwEnabled = true
        container:SetUnit(config.unit)
        container:SetEnabled(true)
    else
        container:SetEnabled(false)
    end
    AttachRefreshWatcher(container, config)
    RegisterAuraContainer(container)

    return container
end

-- The corner dispel icon must only appear on auras the PLAYER can dispel. The region
-- options know nothing about dispellability and per-aura regions do not exist, so the
-- boundary has to be a group boundary: every icon-bearing group is split into its
-- RAID_PLAYER_DISPELLABLE part (keeps the key and the icon) and a negated twin without
-- the icon right behind it. That token means "the player can dispel this" — plain
-- DISPELLABLE only means "has a dispel type" and is NOT sufficient here. The engine
-- evaluates the token per aura and unit, so the split follows spec changes on its own.
-- Groups whose filter already carries the token (the grid and party ones) are left alone
local DISPEL_TWIN_FIELDS = {"size", "maxFrameCount", "isDebuff", "hideDuration", "iconInset", "bigFont", "showPandemic", "candidateFilters", "sortMethod", "sortDirection", "forceNewLine"}
local function SplitDispelIconGroups(groups)
    local index = 1
    while groups[index] do
        local group = groups[index]
        if group.showDispelIcon and not group.filter:find("RAID_PLAYER_DISPELLABLE", 1, true) then
            local twin = { key = group.key .. "NoDispel", gwBaseKey = group.key, filter = group.filter .. "|!RAID_PLAYER_DISPELLABLE" }
            for _, field in ipairs(DISPEL_TWIN_FIELDS) do
                twin[field] = group[field]
            end
            group.filter = group.filter .. "|RAID_PLAYER_DISPELLABLE"
            tinsert(groups, index + 1, twin)
            index = index + 1
        end
        index = index + 1
    end
end

function GW.CreateUnitAuraContainer(config)
    local container = CreateFrame("AuraContainer", config.name, config.parent or UIParent, "CustomAuraContainerTemplate")
    container.gwConfig = config
    container.gwSkipAlphaRecursion = true -- engine child buttons reject tainted SetAlpha
    container.GwUpdateLayout = ApplyLayout
    container.GwSetAdvancedBranches = SetAdvancedBranches

    SplitDispelIconGroups(config.groups)

    for index, group in ipairs(config.groups) do
        group.layoutIndex = group.layoutIndex or index
        container:AddAuraGroup(group.key, group.filter, {
            initializeFrame = function(button) BuildAuraButton(button, container, group) end,
        })
    end

    container.GwSetUnit = GwContainerSetUnit
    -- the grid frames are pre-created by the secure header BEFORE their units exist.
    -- Binding unit-less containers to a fallback like "player" made every one of the
    -- ~125 pre-created grid frames track the players own auras and build a full set
    -- of skinned aura buttons for them (tens of MB, growing with every own aura) —
    -- without a unit the container stays disabled until GwSetUnit delivers one
    if config.unit then
        container.gwEnabled = true
        container:SetUnit(config.unit)
        container:SetEnabled(true)
    else
        container:SetEnabled(false)
    end
    AttachRefreshWatcher(container, config)

    ApplyLayout(container)
    EnsureTooltipStyle()
    RegisterAuraContainer(container)

    return container
end
