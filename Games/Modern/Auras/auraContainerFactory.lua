---@class GW2
local GW = select(2, ...)

-- Factory for the unit aura containers of the 12.1 AuraContainer system (pet, target/focus, party, grid);
-- the buttons get the GwAuraFrame look.
--
-- config = {
--     name = "GwPetAuraContainer",          -- global frame name (optional)
--     unit = "pet",                          -- nil = disabled until GwSetUnit
--     parent = frame,                        -- default UIParent
--     cancelButtons = "RightButtonUp, RightButtonDown", -- nil = no right-click cancel
--     tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
--     refreshEvents = { "UNIT_PET" },        -- events that trigger UpdateAllAuras
--     refreshUnit = "player",                -- unit for RegisterUnitEvent (nil = regular events)
--     onSettingsRefresh = function() end,    -- re-derives the config on a central refresh (default GwUpdateLayout)
--     newAuraAnimation = true,               -- zoom in newly shown buffs (engine driven, see AddAuraShownAnimation)
--     anchorPoint = "TOPRIGHT",              -- starting corner of the flow layout
--     growLeft = false, growUp = false,
--     vertical = false,                      -- column instead of row layout
--     maximumLineSize = 160,                 -- line length in pixels
--     elementSpacing = 3, lineSpacing = 20,
--     groups = {
--         {
--             key = "buffs",
--             filter = "HELPFUL",
--             candidateFilters = {...},      -- nil = all (AuraContainerUtil.DoesAuraPassCandidateFilters)
--             size = 20,
--             iconInset = 1,                 -- 1 = small, 3 = big look
--             maxFrameCount = 32,            -- 0 = group disabled
--             sortMethod = AuraContainerSortMethod.Default,
--             sortDirection = AuraContainerSortDirection.Normal,
--             forceNewLine = false,
--             isDebuff = false,              -- dispel colored border
--             bigFont = false,
--             showStealable = false,
--             showDispelIcon = false,        -- dispel type icon in the corner
--             dispelIconSize = 12,
--             showPandemic = false,          -- glow inside the refresh window
--             thinBorder = false,            -- only the 1px background frame, no black frame around it
--         },
--     },
-- }
--
-- Changed config values are applied with container:GwUpdateLayout().

-- Advanced filters narrow the groups, tri-state: true = required, 1 = excluded. Tokens fail open for secret
-- auras, candidate fields stay exact. PLAYER stays a token: isFromPlayerOrPlayerPet is relative to the unit
local ADVANCED_FILTER_TOKENS = {
    { setting = "isAuraPlayer",            token = "PLAYER" },
    { setting = "isAuraRaid",              token = "RAID" },
    { setting = "isAuraRaidInCombat",      token = "RAID_IN_COMBAT" }, -- with PLAYER: own HoTs
    { setting = "isAuraCancelable",        token = "CANCELABLE" },
    { setting = "isAuraCrowdControl",      token = "CROWD_CONTROL" },
    { setting = "isAuraBigDefensive",      token = "BIG_DEFENSIVE" },
    { setting = "isAuraExternalDefensive", token = "EXTERNAL_DEFENSIVE" },
    { setting = "isAuraImportant",         token = "IMPORTANT" },
}

-- "Dispellable" is not a field, it maps to dispel type candidates (GW.Dispel)
local ADVANCED_CANDIDATE_FIELDS = {
    { setting = "isAuraStealable",         field = "isStealable" },
    { setting = "isAuraBoss",              field = "isBossAura" },
    { setting = "isAuraBossOrRole",        field = "isBossOrRoleAura" },
    { setting = "isAuraPriority",          field = "isPriorityAura" },
    { setting = "isAuraRole",              field = "isRoleAura" },
    { setting = "isAuraCanApply",          field = "canApplyAura" },
    { setting = "isAuraNameplateAll",      field = "nameplateShowAll" },
    { setting = "isAuraNameplatePersonal", field = "nameplateShowPersonal" },
}

local function ResolveFilterToken(entry, value)
    return value == 1 and ("!" .. entry.token) or entry.token
end

-- gwDispellable keeps the tri-state, ComposeAuraGroupCandidates resolves it per group role
local function BuildCandidateSelection(db)
    local selection
    for _, entry in ipairs(ADVANCED_CANDIDATE_FIELDS) do
        local value = db[entry.setting]
        if value then
            selection = selection or {}
            selection[entry.field] = value ~= 1
        end
    end
    if db.isAuraRaidPlayerDispellable then
        selection = selection or {}
        selection.gwDispellable = db.isAuraRaidPlayerDispellable
    end
    return selection
end

-- advanced filter settings -> filter string suffix + candidate selection
function GW.BuildAuraFilterSuffix(db)
    if not db then return "", nil end

    local tokens = {}
    for _, entry in ipairs(ADVANCED_FILTER_TOKENS) do
        local value = db[entry.setting]
        if value then
            tinsert(tokens, ResolveFilterToken(entry, value))
        end
    end

    local suffix = #tokens > 0 and ("|" .. table.concat(tokens, "|")) or ""
    return suffix, BuildCandidateSelection(db)
end

-- nothing passes an empty include list, it mutes a dispel twin half
local EMPTY_DISPEL_TYPES = {}

-- base + extra + advanced selection + the dispel twin role: "include" holds what this character can
-- dispel and carries the icon, "exclude" the rest. Apply via ApplyStableCandidates
function GW.ComposeAuraGroupCandidates(group, selection, extra)
    local merged
    local function put(field, value)
        if value ~= nil then
            merged = merged or {}
            merged[field] = value
        end
    end

    local function absorb(source)
        if not source then return end
        for field, value in next, source do
            if field ~= "gwDispellable" then
                put(field, value)
            end
        end
    end
    absorb(group.gwBaseCandidates)
    absorb(extra)
    absorb(selection)

    local dispellable = selection and selection.gwDispellable
    local myTypes = GW.Dispel.GetMyTypes()
    if group.gwDispelRole == "include" then
        put("includeDispelTypes", dispellable == 1 and EMPTY_DISPEL_TYPES or myTypes)
    elseif group.gwDispelRole == "exclude" then
        -- "Dispellable" required: the include half owns everything
        if dispellable == true then
            put("includeDispelTypes", EMPTY_DISPEL_TYPES)
        else
            put("excludeDispelTypes", myTypes)
        end
    elseif dispellable == true then
        put("includeDispelTypes", myTypes)
    elseif dispellable == 1 then
        put("excludeDispelTypes", myTypes)
    end

    return merged
end

local function SameCandidates(a, b)
    if a == b then return true end
    if not a or not b then return false end
    for k, v in next, a do
        if b[k] ~= v then return false end
    end
    for k, v in next, b do
        if a[k] ~= v then return false end
    end
    return true
end

-- keeps the previous table for unchanged content, ApplyLayout compares by reference
function GW.ApplyStableCandidates(group, candidates)
    if not SameCandidates(candidates, group.candidateFilters) then
        group.candidateFilters = candidates
    end
end

-- customDispelColorMap is keyed by dispel type name, "None" covers auras without one
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

local debuffColorCurve
local function GetDebuffColorCurve()
    if not debuffColorCurve then
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

-- the container tooltip is shared by every AuraContainer
local tooltipStyled = false
local function EnsureTooltipStyle()
    if tooltipStyled or not GW.settings.tooltip.enabled then return end
    tooltipStyled = true

    AuraContainerInbound.SetTooltipBackdrop({
        backdropInfo = GW.BackdropTemplates.Default,
    })
end
GW.EnsureAuraTooltipStyle = EnsureTooltipStyle

-- every aura container with the refresh it runs on a central settings refresh
local containerRegistry = {}

-- the engine keeps a secure copy of the candidate filters, so in-place changes of a filter table are
-- invisible to ApplyLayout's reference compare; a new generation re-applies them everywhere
local settingsGeneration = 0

local function RegisterAuraContainer(container, refreshFunc)
    tinsert(containerRegistry, { container = container, refresh = refreshFunc })
end
GW.RegisterAuraContainer = RegisterAuraContainer

-- for callers that change a filter table in place and re-apply through their own settings callback
function GW.BumpAuraContainerSettingsGeneration()
    settingsGeneration = settingsGeneration + 1
end

-- the engine owns the button lists, they are enumerated instead of cached
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

-- 12.1.0 compat, remove with 12.1.5: up to 12.1.0 Add* returns a list index and Remove* takes one, a stored
-- index would go stale, so it is looked up at removal time; 12.1.5 removes by region
local function RemoveDispelTypeTextureByIdentity(button, texture, indexed)
    if not indexed then
        button:RemoveDispelTypeTexture(texture)
        return
    end
    for i = button:GetDispelTypeTextureCount(), 1, -1 do
        if button:GetDispelTypeTexture(i) == texture then
            button:RemoveDispelTypeTexture(i)
            return
        end
    end
end

-- registered regions have a secret Shown state, so the opt out de-registers them and clears their
-- texture instead of hiding them; registering twice errors since 12.1.5, hence the own flags
local function ApplyAuraOptionRegions(button)
    local pandemic = button.gwPandemicRegion
    if pandemic then
        if button.gwPandemicEnabled() then
            if not button.gwPandemicRegistered then
                pandemic:SetTexture(PANDEMIC_TEXTURE)
                button:AddPandemicRegion(pandemic)
                button.gwPandemicRegistered = true
            end
        elseif button.gwPandemicRegistered then
            -- the only pandemic region is ours, Clear* works on every version
            button:ClearPandemicRegions()
            button.gwPandemicRegistered = nil
            pandemic:SetTexture()
        end
    end

    local zoom = button.gwShownAnimation
    if zoom then
        if not button.gwShownAnimationEnabled or button.gwShownAnimationEnabled() then
            if not button.gwShownAnimationRegistered then
                button:AddAuraShownAnimation(zoom)
                button.gwShownAnimationRegistered = true
            end
        elseif button.gwShownAnimationRegistered then
            button:RemoveAuraShownAnimation(zoom)
            button.gwShownAnimationRegistered = nil
        end
    end

    local dispelIcon = button.gwDispelIcon
    if dispelIcon then
        if button.gwDispelIconEnabled() then
            if not button.gwDispelIconRegistered then
                local index = button:AddDispelTypeTexture(dispelIcon, button.gwDispelIconOptions)
                button.gwDispelIconRegistered = true
                button.gwDispelIconIndexed = index ~= nil -- 12.1.0 compat, remove with 12.1.5
            end
        elseif button.gwDispelIconRegistered then
            -- 12.1.0 compat, with 12.1.5: button:RemoveDispelTypeTexture(dispelIcon)
            RemoveDispelTypeTextureByIdentity(button, dispelIcon, button.gwDispelIconIndexed)
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

-- isEnabled is re-evaluated on every update; textureParent is for buttons that draw on themselves
function GW.AddPandemicHighlight(button, anchor, isEnabled, textureParent)
    local region = (textureParent or anchor):CreateTexture(nil, "OVERLAY", nil, 1)
    region:SetPoint("TOPLEFT", anchor, "TOPLEFT", -4, 4)
    region:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
    region:SetVertexColor(1, 0.4, 0.25)

    button.gwPandemicRegion = region
    button.gwPandemicEnabled = isEnabled
    ApplyAuraOptionRegions(button)
end

-- the zoom in of a new aura, played by the engine the first time an aura shows on the button;
-- isEnabled nil = always. 12.1.0 compat: the check, the API comes with 12.1.5
function GW.AddAuraShownAnimation(button, target, isEnabled, scaleFrom)
    if not button.AddAuraShownAnimation then return end

    local zoom = target:CreateAnimationGroup()
    local fade = zoom:CreateAnimation("Alpha")
    fade:SetFromAlpha(0.85)
    fade:SetToAlpha(1)
    fade:SetDuration(0.25)
    local scale = zoom:CreateAnimation("Scale")
    scale:SetScaleFrom(scaleFrom or 2.5, scaleFrom or 2.5)
    scale:SetScaleTo(1, 1)
    scale:SetDuration(0.25)

    button.gwShownAnimation = zoom
    button.gwShownAnimationEnabled = isEnabled
    ApplyAuraOptionRegions(button)
end

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

    -- writes secure attributes (aurabar layout proxy) and can be triggered in combat (SPELLS_CHANGED)
    if InCombatLockdown() then
        GW.CombatQueue:Queue("gw_refresh_all_aura_containers", GW.RefreshAllAuraContainers)
        return
    end

    for _, entry in ipairs(containerRegistry) do
        if entry.refresh then
            entry.refresh(entry.container)
        end
    end
end

-- the dispel type table changes in place, invisible to the reference compares
EventRegistry:RegisterCallback("GW2_UI.DispelTypesChanged", GW.RefreshAllAuraContainers, "GW2_UI")

-- part of the button height, so the container's own size covers the text and frames can anchor below it
local DURATION_TEXT_HEIGHT = 14

local function GetGroupTextPad(group)
    return group.hideDuration and 0 or DURATION_TEXT_HEIGHT
end

-- pcall only: while auras are secret the whole button subtree denies tainted access;
-- the size is recorded on success, so unchanged layout passes skip it
local function SetAuraButtonSize(button, size, textPad)
    button.gwVisual:SetSize(size, size)
    button:SetSize(size, size + textPad)
    button.gwAppliedSize = size
    button.gwAppliedTextPad = textPad
end

-- GWs compact units like on the classic clients ("12s", "46m", "2h", "1d"); the seconds formatter uses the
-- localized unit names, which are "min" or longer in some locales and overlap the neighbours
local durationTextFormatter
local function GetDurationTextFormatter()
    if not durationTextFormatter then
        local rounding = Enum.NumericRuleFormatRounding
        durationTextFormatter = C_StringUtil.CreateNumericRuleFormatter()
        durationTextFormatter:SetBreakpoints({
            { threshold = 0, step = 1, rounding = rounding.Down, format = "%.0fs" },
            { threshold = 60, format = "%.0fm", components = { { div = 60, step = 1, rounding = rounding.Nearest } } },
            { threshold = 3600, format = "%.0fh", components = { { div = 3600, step = 1, rounding = rounding.Nearest } } },
            { threshold = 86400, format = "%.0fd", components = { { div = 86400, step = 1, rounding = rounding.Nearest } } },
        })
    end
    return durationTextFormatter
end
GW.GetAuraDurationTextFormatter = GetDurationTextFormatter

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

local function BuildAuraButton(button, container, group)
    -- the button itself is forbidden and only takes SetSize during initializeFrame, the visuals and
    -- later size changes live on an own wrapper; the strip below it belongs to the duration text
    local visual = CreateFrame("Frame", nil, button)
    visual:SetPoint("TOP", button, "TOP")
    visual:SetSize(group.size, group.size)
    visual:SetFrameLevel(button:GetFrameLevel() + 1)
    button.gwVisual = visual

    if not group.thinBorder then
        local backdrop = visual:CreateTexture(nil, "ARTWORK", nil, -1)
        backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        backdrop:SetVertexColor(0, 0, 0)
        backdrop:SetPoint("TOPLEFT", visual, "TOPLEFT", -1, 1)
        backdrop:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", 1, -1)
    end

    local background = visual:CreateTexture(nil, "ARTWORK")
    background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    background:SetVertexColor(0, 0, 0)
    background:SetAllPoints(visual)
    button.background = background

    -- 1px swipe ring, as slim as on the player buff bar
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

    button:SetIcon(status.icon)
    button:SetDurationCooldown(cooldown)
    if status.duration then
        button:SetDurationText(status.duration, { textFormatter = GetDurationTextFormatter() })
    end
    button:SetApplicationCount(status.stacks)

    local cfg = container.gwConfig
    -- prefix match, advanced branches ("HELPFUL|CANCELABLE|...") are cancelable too
    if cfg.cancelButtons and group.filter and group.filter:sub(1, 7) == "HELPFUL" then
        button:SetCancelAuraButtons(cfg.cancelButtons)
    end
    if cfg.enableMouse == false then
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

    -- every debuff group carries the icon region, the setting registers it live: "ALL" on every debuff,
    -- "DISPELLABLE" only on the player-dispellable half of the split (the role of advanced slots can change)
    local dispelIconGetter = cfg.dispelIconEnabled
    if dispelIconGetter and group.isDebuff then
        GW.AddDispelTypeIcon(button, visual, group, function()
            local mode = dispelIconGetter()
            if mode == "ALL" then return true end
            return mode == "DISPELLABLE" and group.showDispelIcon or false
        end)
    end

    -- built whenever the host wires the setting, so enabling it later needs no reload
    local pandemicSettingGetter = cfg.pandemicEnabled
    if group.showPandemic and pandemicSettingGetter then
        GW.AddPandemicHighlight(button, visual, pandemicSettingGetter)
    end

    -- like the old unit frame auras: new buffs only, at twice their size
    if cfg.newAuraAnimation and not group.isDebuff then
        GW.AddAuraShownAnimation(button, visual, nil, 2)
    end

    if cfg.hideTooltipInCombat then
        button:SetHideTooltipInCombat(true)
    end

    button.gwGroup = group
    SetAuraButtonSize(button, group.size, GetGroupTextPad(group))
end

-- every engine setter can trigger a container re-evaluation, with many containers (grids) a full re-apply per
-- settings pass freezes the client; true when the inputs differ from the last applied ones, tables by reference
local function InputsChanged(owner, key, ...)
    local applied = owner.gwApplied
    if not applied then
        applied = {}
        owner.gwApplied = applied
    end

    local last = applied[key]
    local count = select("#", ...)
    if last and last.n == count then
        local changed = false
        for i = 1, count do
            if last[i] ~= select(i, ...) then
                changed = true
                break
            end
        end
        if not changed then return false end
    end

    applied[key] = { n = count, ... }
    return true
end

local function ApplyLayout(container)
    local cfg = container.gwConfig

    if InputsChanged(container, "flow", cfg.vertical, cfg.anchorPoint, cfg.growLeft, cfg.growUp, cfg.maximumLineSize) then
        container:SetFlowLayoutAxis(cfg.vertical and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
        container:SetFlowLayoutAnchorPoint(cfg.anchorPoint or "TOPLEFT")
        container:SetFlowLayoutGrowthDirection(
            cfg.growLeft and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
            cfg.growUp and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
        )
        container:SetFlowLayoutMaximumLineSize(cfg.maximumLineSize or math.huge)
    end

    local elementSpacing = cfg.elementSpacing or 3
    local lineSpacing = cfg.lineSpacing or 20

    for index, group in ipairs(cfg.groups) do
        local textPad = GetGroupTextPad(group)

        if InputsChanged(group, "filter", group.filter) then
            container:SetAuraGroupFilterString(group.key, group.filter)
        end

        -- the container wide ignore list is merged into every group
        if InputsChanged(group, "candidates", group.candidateFilters, cfg.excludeSpellIDs, settingsGeneration) then
            local candidateFilters = group.candidateFilters
            if cfg.excludeSpellIDs and next(cfg.excludeSpellIDs) then
                candidateFilters = candidateFilters and CopyTable(candidateFilters, true) or {}
                candidateFilters.excludeSpellIDs = cfg.excludeSpellIDs
            end
            container:SetAuraGroupCandidateFilters(group.key, candidateFilters or {})
        end

        local maxFrameCount = group.maxFrameCount or math.huge
        if InputsChanged(group, "maxFrameCount", maxFrameCount) then
            container:SetAuraGroupMaxFrameCount(group.key, maxFrameCount)
            -- 12.1.5 stops processing a disabled group entirely; 12.1.0 compat, the check goes with 12.1.5
            if container.SetAuraGroupEnabled then
                container:SetAuraGroupEnabled(group.key, maxFrameCount > 0)
            end
        end

        local sortMethod = group.sortMethod or AuraContainerSortMethod.Default
        local sortDirection = group.sortDirection or AuraContainerSortDirection.Normal
        if InputsChanged(group, "sort", sortMethod, sortDirection) then
            container:SetAuraGroupSortMethod(group.key, sortMethod, sortDirection)
        end

        local forceNewLine = group.forceNewLine or false
        local layoutIndex = group.layoutIndex or index
        if InputsChanged(group, "layout", elementSpacing, lineSpacing, group.size, textPad, forceNewLine, layoutIndex) then
            container:SetAuraGroupLayout(group.key, {
                elementSpacing = elementSpacing,
                lineSpacing = lineSpacing,
                -- group boundaries (forceNewLine) use the group values
                groupSpacing = elementSpacing,
                groupLineSpacing = lineSpacing,
                elementWidth = group.size,
                elementHeight = group.size + textPad,
                forceNewLine = forceNewLine,
                layoutIndex = layoutIndex,
            })
        end

        -- the flow layout only anchors; sizes are best effort, buttons that fail while auras are secret
        -- keep their size until the next pass
        ForEachGroupButton(container, group.key, function(button)
            if button.gwAppliedSize ~= group.size or button.gwAppliedTextPad ~= textPad then
                pcall(SetAuraButtonSize, button, group.size, textPad)
            end
        end)
    end
end

-- Maps the shared per-unit aura settings onto the two stacked containers of a frame: one buffs group and
-- one debuffs group (plus its dispel icon twin), so an aura never renders twice. Growth stays with the caller.
--
-- opts = {
--     smallSize = 20, bigSize = 24,        -- buff / debuff button size
--     buffFilter = "all|none|advanced",
--     debuffFilter = "all|none|player|advanced",
--     buffAdvanced = {...}, debuffAdvanced = {...},
--     sort = "DEFAULT",                    -- see GW.GetAuraSortPreset
--     excludeSpellIDs = {...},             -- {[spellID] = true}
-- }
function GW.ApplyAuraContainerSettings(buffContainer, debuffContainer, opts)
    local cfg = buffContainer.gwConfig
    local debuffCfg = debuffContainer.gwConfig

    local buffSuffix, buffCandidates = "", nil
    if opts.buffFilter == "advanced" then
        buffSuffix, buffCandidates = GW.BuildAuraFilterSuffix(opts.buffAdvanced)
    end
    local debuffSuffix, debuffCandidates = "", nil
    if opts.debuffFilter == "advanced" then
        debuffSuffix, debuffCandidates = GW.BuildAuraFilterSuffix(opts.debuffAdvanced)
    elseif opts.debuffFilter == "player" then
        debuffSuffix = "|PLAYER"
    end

    local buffMax = opts.buffFilter == "none" and 0 or 32
    local debuffMax = opts.debuffFilter == "none" and 0 or 40
    local sort = GW.GetAuraSortPreset(opts.sort)

    cfg.excludeSpellIDs = opts.excludeSpellIDs
    debuffCfg.excludeSpellIDs = opts.excludeSpellIDs

    -- every selection change rebuilds from gwBaseFilter/gwBaseCandidates
    for _, group in next, cfg.groups do
        group.sortMethod = sort.method
        group.sortDirection = sort.direction
        group.gwBaseFilter = group.gwBaseFilter or group.filter
        GW.ApplyStableCandidates(group, GW.ComposeAuraGroupCandidates(group, buffCandidates, nil))
        if group.key == "buffs" then
            group.filter = group.gwBaseFilter .. buffSuffix
            group.size = opts.smallSize
            group.maxFrameCount = buffMax
        end
    end
    for _, group in next, debuffCfg.groups do
        group.sortMethod = sort.method
        group.sortDirection = sort.direction
        group.gwBaseFilter = group.gwBaseFilter or group.filter
        GW.ApplyStableCandidates(group, GW.ComposeAuraGroupCandidates(group, debuffCandidates, nil))
        -- gwBaseKey covers the dispel icon twin
        if (group.gwBaseKey or group.key) == "debuffs" then
            group.filter = group.gwBaseFilter .. debuffSuffix
            group.size = opts.bigSize
            group.maxFrameCount = debuffMax
        end
    end

    ApplyLayout(buffContainer)
    ApplyLayout(debuffContainer)
end

-- the container only refreshes on UNIT_AURA, not when the unit behind the token changes
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

-- containers created without a unit get enabled on their first unit
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

-- Single-button tracker for the classpower spec trackers (Shield of the Righteous, Metamorphosis, ...): the
-- engine finds the aura even while it is secret and drives the widgets itself, no Lua math on durations.
-- The widgets must be descendants of the button (validated, no reparenting afterwards), so they are built in
-- createWidgets; the container hides the button while the aura is missing.
--
-- config = {
--     name = "GwClassPowerTrackerX",     -- global frame name (optional)
--     parent = frame,                     -- default UIParent, position the container yourself
--     unit = "player",
--     filter = "HELPFUL",
--     spellIDs = { [132403] = true },
--     width = 164, height = 14,           -- button size
--     createWidgets = function(button)
--         return { durationBar = bar,     -- optional: decay bar
--                  durationText = fs,     -- optional: countdown text
--                  counterText = fs }     -- optional: stacks
--     end,
--     refreshEvents = { "UNIT_PET" },
--     refreshUnit = "player",
-- }
function GW.CreateAuraTrackerContainer(config)
    local container = CreateFrame("AuraContainer", config.name, config.parent or UIParent, "CustomAuraContainerTemplate")
    container.gwConfig = config
    container.gwSkipAlphaRecursion = true -- engine child buttons reject tainted SetAlpha
    container.gwGroupKeys = { "tracker" }
    container:SetSize(config.width or 1, config.height or 1)

    container:AddAuraGroup("tracker", config.filter, {
        initializeFrame = function(button)
            -- the button subtree is access restricted after initialization
            button:SetSize(config.width or 1, config.height or 1)
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

-- the corner dispel icon may only show on auras this character can dispel, exact even for secret auras only as
-- a group boundary: icon groups split into the dispellable half ("include", keeps key and icon) and a twin
local DISPEL_TWIN_FIELDS = {"size", "maxFrameCount", "isDebuff", "hideDuration", "iconInset", "bigFont", "showPandemic", "candidateFilters", "sortMethod", "sortDirection", "forceNewLine"}
local function SplitDispelIconGroups(groups)
    local index = 1
    while groups[index] do
        local group = groups[index]
        if group.showDispelIcon and not group.gwDispelRole then
            local twin = { key = group.key .. "NoDispel", gwBaseKey = group.key, filter = group.filter, gwDispelRole = "exclude" }
            for _, field in ipairs(DISPEL_TWIN_FIELDS) do
                twin[field] = group[field]
            end
            group.gwDispelRole = "include"
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

    SplitDispelIconGroups(config.groups)

    for index, group in ipairs(config.groups) do
        group.layoutIndex = group.layoutIndex or index
        group.gwBaseCandidates = group.candidateFilters
        group.candidateFilters = GW.ComposeAuraGroupCandidates(group, nil, nil)
        container:AddAuraGroup(group.key, group.filter, {
            initializeFrame = function(button) BuildAuraButton(button, container, group) end,
        })
    end

    container.GwSetUnit = GwContainerSetUnit
    -- the secure header creates ~125 grid frames before their units exist, a fallback unit would build
    -- skinned buttons for the players own auras on every one of them
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
    RegisterAuraContainer(container, config.onSettingsRefresh or ApplyLayout)

    return container
end
