---@class GW2
local GW = select(2, ...)
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetDebuffColorCurve = GW.GetDebuffColorCurve

-- 12.1: player buff/debuff bars based on the new AuraContainer system
-- (CustomAuraContainerTemplate, runs in Blizzard's secure environment).
-- On Retail this replaces the SecureAuraHeaderTemplate-based aurabar from Games/Shared/Aura.
-- The container takes care of: secure aura assignment, sorting, layout, right-click cancel,
-- tooltips as well as all display updates (icon, duration, stacks, dispel color) via the
-- setter API of CustomAuraButtonSharedMixin.

local DIRECTION_TO_POINT = {
    DOWNR = "TOPLEFT",
    DOWN = "TOPRIGHT",
    UPR = "BOTTOMLEFT",
    UP = "BOTTOMRIGHT",
    UPL_COLUMN = "BOTTOMRIGHT",
    UPR_COLUMN = "BOTTOMLEFT",
    DOWNL_COLUMN = "TOPRIGHT",
    DOWNR_COLUMN = "TOPLEFT",
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
    UPR = 1,
    DOWNR = 1,
    DOWN = -1,
    UP = -1,
    UPL_COLUMN = -1,
    UPR_COLUMN = 1,
    DOWNL_COLUMN = -1,
    DOWNR_COLUMN = 1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
    UPR = 1,
    DOWNR = -1,
    DOWN = -1,
    UP = 1,
    UPL_COLUMN = 1,
    UPR_COLUMN = 1,
    DOWNL_COLUMN = -1,
    DOWNR_COLUMN = -1,
}

local DIRECTION_IS_COLUMN_LAYOUT = {
    UPL_COLUMN = true,
    UPR_COLUMN = true,
    DOWNL_COLUMN = true,
    DOWNR_COLUMN = true,
}

local DIRECTION_TO_DEBUFF_ANCHOR = {
    DOWNR = "BOTTOMLEFT",
    DOWN = "BOTTOMRIGHT",
    UPR = "TOPLEFT",
    UP = "TOPRIGHT",
    UPL_COLUMN = "TOPRIGHT",
    UPR_COLUMN = "TOPLEFT",
    DOWNL_COLUMN = "BOTTOMRIGHT",
    DOWNR_COLUMN = "BOTTOMLEFT",
}

-- Two fixed groups per container: "own" and "others" auras.
-- This maps the old separateOwn (Seperate -1/0/1), since groups cannot be removed
-- after the fact (ClearAuraGroups is not part of the Inbound API):
--  Seperate  1: own before others |  -1: others before own |  0: own disabled (maxFrameCount 0), others shows everything
local GROUP_OWN = "GwAurasOwn"
local GROUP_OTHERS = "GwAurasOthers"
-- The debuff bar splits each of the two groups along the RAID_PLAYER_DISPELLABLE token
-- ("the player can dispel this" — plain DISPELLABLE only means "has a dispel type"):
-- the corner dispel icon must only appear on auras the player can dispel, and with
-- static button regions that boundary has to be a group boundary. The buff bar keeps
-- the plain pair
local GROUP_OWN_DISPELLABLE = "GwAurasOwnDispellable"
local GROUP_OTHERS_DISPELLABLE = "GwAurasOthersDispellable"

local function GetButtonMainAxisSize(db)
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    return DIRECTION_IS_COLUMN_LAYOUT[db.GrowDirection] and height or width, width, height
end

-- Size + icon crop per button (analogous to UpdateIcon of the old aurabar).
-- IMPORTANT: The container's flow layout uses elementWidth/Height only for calculations
-- (GetElementSize) and only sets anchor points (ApplyElementLayout) — we have to set
-- the frame size ourselves, otherwise the buttons are 0x0 and invisible
local function ApplyButtonSizeAndCrop(button, width, height, keepSizeRatio)
    button.gwVisual:SetSize(width, height)
    button:SetSize(width, height)

    if not button.status or not button.status.icon then return end

    if keepSizeRatio then
        button.status.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    else
        local left, right, top, bottom = GW.CropRatio(width, height)
        button.status.icon:SetTexCoord(left, right, top, bottom)
    end
end

local function UpdateButtonSizeAndCrop(button, db)
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    -- best-effort: while auras are secret the access restriction denies tainted
    -- access to the whole button subtree (incl. our own child frames) — failed
    -- buttons keep their previous size until the next update outside that state
    pcall(ApplyButtonSizeAndCrop, button, width, height, db.KeepSizeRatio)
end

-- Builds the GW look per aura button (replaces GwAuraSecureTmpl from aurabar.xml).
-- Called once per frame by the container (created in batches, access in combat
-- can be restricted by secret values — therefore ONLY build regions here and
-- hand them to the mixin setters, never read aura data yourself!)
local function InitializeAuraButton(button, header, isDebuff, isEnchant, withDispelIcon)
    -- The button itself is forbidden (HookScript/animations on it are blocked
    -- by secret aspects) — therefore the entire GW look is attached to a
    -- separate wrapper frame. It is anchored by CENTER and explicitly sized:
    -- the button only accepts SetSize during initializeFrame (access restrictions
    -- are applied afterwards), later size changes are carried by our own frame
    local visual = CreateFrame("Frame", nil, button)
    visual:SetPoint("CENTER", button, "CENTER")
    visual:SetFrameLevel(button:GetFrameLevel() + 1)
    button.gwVisual = visual

    -- border
    local border = CreateFrame("Frame", nil, visual)
    border:SetFrameLevel(visual:GetFrameLevel())
    border:SetPoint("TOPLEFT", visual, "TOPLEFT", 2, -2)
    border:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -2, 2)

    local borderBackground = border:CreateTexture(nil, "BACKGROUND")
    borderBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    borderBackground:SetVertexColor(0, 0, 0)
    borderBackground:SetAllPoints(border)

    border.inner = border:CreateTexture(nil, "BORDER")
    border.inner:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    border.inner:SetAlpha(0.75)
    border.inner:SetPoint("TOPLEFT", border, "TOPLEFT", 1, -1)
    border.inner:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, 1)
    button.border = border

    -- Cooldown swipe: only the 2px ring between icon (inset 4) and
    -- cooldown (inset 2) is visible — the swipe needs the opaque white texture for that
    -- (corresponds to the SwipeTexture color block from the old GwAuraSecureTmpl)
    local cooldown = CreateFrame("Cooldown", nil, visual, "CooldownFrameTemplate")
    cooldown:SetFrameLevel(visual:GetFrameLevel() + 1)
    cooldown:SetPoint("TOPLEFT", visual, "TOPLEFT", 2, -2)
    cooldown:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -2, 2)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawSwipe(true)
    cooldown:SetReverse(false)
    cooldown:SetHideCountdownNumbers(true) -- duration text comes as its own FontString below the icon
    cooldown:SetSwipeTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png", 1, 1, 1, 1)
    button.cooldown = cooldown

    -- icon + overlay + texts
    local status = CreateFrame("Frame", nil, visual)
    status:SetFrameLevel(visual:GetFrameLevel() + 2)
    status:SetPoint("TOPLEFT", visual, "TOPLEFT", 4, -4)
    status:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -4, 4)
    button.status = status

    status.icon = status:CreateTexture(nil, "ARTWORK")
    status.icon:SetAllPoints(status)

    local overlay = status:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-overlay.png")
    overlay:SetAllPoints(status)

    status.stacks = status:CreateFontString(nil, "OVERLAY")
    status.stacks:SetJustifyH("CENTER")
    status.stacks:SetJustifyV("BOTTOM")
    status.stacks:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 1, 15)
    status.stacks:SetPoint("BOTTOMRIGHT", status, "BOTTOMRIGHT", -1, 0)
    status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOWOUTLINE")

    status.duration = status:CreateFontString(nil, "OVERLAY")
    status.duration:SetJustifyH("CENTER")
    status.duration:SetSize(36, 13)
    status.duration:SetPoint("TOP", status, "BOTTOM", 0, -6)
    status.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW", -1)

    -- register the regions with the container — from here on Blizzard keeps everything up to date
    button:SetIcon(status.icon)
    button:SetDurationCooldown(cooldown)
    -- one-letter units without whitespace ("17s") — deDE/ruRU keep the whitespace
    -- by default, which makes wide values overlap the neighboring buttons
    button:SetDurationText(status.duration, { textFormatter = GW.GetAuraDurationTextFormatter() })
    button:SetApplicationCount(status.stacks)

    -- right-click cancel (the container does this securely itself — also for enchants)
    -- and tooltip anchor as in the old system
    button:SetCancelAuraButtons("RightButtonUp, RightButtonDown")
    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", -5, -5)

    if isEnchant then
        -- weapon enchants get the Curse-colored border as before
        border.inner:SetVertexColor(GW.Colors.DebuffColors.Curse:GetRGB())
    elseif isDebuff then
        -- The container takes care of the dispel type coloring: PreserveAsset keeps our
        -- texture and only sets the VertexColor based on the color curve; showWithoutDispelType
        -- ensures that debuffs without a dispel type get colored as well (curve: None = 0)
        button:AddDispelTypeTexture(border.inner, {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
            showWhenHarmful = true,
            showWithoutDispelType = true,
            customDispelColorCurve = GetDebuffColorCurve(),
        })
    else
        border.inner:SetVertexColor(GW.Colors.Fallback:GetRGB())
    end

    -- NOTE: The old zoom-in animation for new auras (NewAuraAnimation) is not feasible with
    -- the container system: the shown secrecy of the AuraButton intrinsic covers the
    -- entire child hierarchy — OnShow handlers (even on our own wrapper frames) are
    -- rejected with "blocked by secret aspects", so that the timing of new auras does not
    -- leak to addon code. If Blizzard ships an animation hook later, re-add it here.

    -- Both groups get the pandemic region: with Seperate = 0 the own auras render in
    -- the others group, and the engine only lights the window for your own auras anyway
    if not isEnchant then
        GW.AddPandemicHighlight(button, visual, function() return GW.settings.PLAYER_PANDEMIC_HIGHLIGHT end)
    end
    if isDebuff then
        GW.AddDispelTypeIcon(button, visual, { isDebuff = true }, function()
            local mode = GW.settings.PLAYER_DISPEL_ICON
            if mode == "ALL" then return true end
            return mode == "DISPELLABLE" and withDispelIcon or false
        end)
    end

    button.header = header
    button.gwInit = true

    UpdateButtonSizeAndCrop(button, GW.settings[header.setting])
end

local function UpdateAuraHeader(header)
    if not header or not header.gwIsAuraContainer then return end

    local db = GW.settings[header.setting]
    local mainAxisSize, width, height = GetButtonMainAxisSize(db)
    local grow_dir = db.GrowDirection
    local isColumnLayout = DIRECTION_IS_COLUMN_LAYOUT[grow_dir]
    local horizontalSpacing = db.HorizontalSpacing
    local verticalSpacing = db.VerticalSpacing
    local maxWraps = db.MaxWraps
    local wrapAfter = db.WrapAfter
    if not wrapAfter or wrapAfter < 1 or wrapAfter > 20 then
        wrapAfter = 7
    end

    local mainAxisSpacing = isColumnLayout and verticalSpacing or horizontalSpacing
    local crossAxisSpacing = isColumnLayout and horizontalSpacing or verticalSpacing

    -- flow layout of the container
    header:SetFlowLayoutAxis(isColumnLayout and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
    header:SetFlowLayoutAnchorPoint(DIRECTION_TO_POINT[grow_dir])
    header:SetFlowLayoutGrowthDirection(
        DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[grow_dir] > 0 and AnchorUtil.FlowDirection.Right or AnchorUtil.FlowDirection.Left,
        DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] > 0 and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
    )
    -- wrapAfter (count) -> maximum line length in pixels
    header:SetFlowLayoutMaximumLineSize(wrapAfter * (mainAxisSize + mainAxisSpacing))

    -- sorting & groups (shared sort presets, see GW.GetAuraSortPreset)
    local sort = GW.GetAuraSortPreset(db.Sort)
    local sortMethod, sortDirection = sort.method, sort.direction
    local separate = db.Seperate or 0
    local maxFrames = wrapAfter * maxWraps

    local groupLayout = {
        elementSpacing = mainAxisSpacing,
        lineSpacing = crossAxisSpacing,
        -- spacing at group boundaries (own -> others transition) uses the group values
        groupSpacing = mainAxisSpacing,
        groupLineSpacing = crossAxisSpacing,
        elementWidth = width,
        elementHeight = height,
    }

    -- shared ignore list for both player bars (PLAYER_IGNORED_AURAS)
    local candidateFilters = {}
    if GW.settings.PLAYER_IGNORED_AURAS and next(GW.settings.PLAYER_IGNORED_AURAS) then
        candidateFilters.excludeSpellIDs = GW.settings.PLAYER_IGNORED_AURAS
    end

    -- own/others split via the PLAYER filter token (cast by the player/their pet) —
    -- the isFromPlayerOrPlayerPet aura data field is unreliable for this. The debuff
    -- bar splits each side once more along DISPELLABLE (see gwGroupInfo); within a
    -- side the dispellable group renders first (RAID_PLAYER_DISPELLABLE boundary)
    local baseIndexOwn = separate == -1 and 2 or 1
    local baseIndexOthers = separate == -1 and 1 or 2
    for _, info in ipairs(header.gwGroupInfo) do
        header:SetAuraGroupCandidateFilters(info.key, candidateFilters)
        header:SetAuraGroupSortMethod(info.key, sortMethod, sortDirection)

        local filter = header.filter
        local muted = false
        if separate == 0 then
            -- no separation: "others" shows everything, "own" is muted
            muted = info.own
        else
            filter = filter .. (info.own and "|PLAYER" or "|!PLAYER")
        end
        if info.dispel ~= nil then
            filter = filter .. (info.dispel and "|RAID_PLAYER_DISPELLABLE" or "|!RAID_PLAYER_DISPELLABLE")
        end
        header:SetAuraGroupFilterString(info.key, filter)
        header:SetAuraGroupMaxFrameCount(info.key, muted and 0 or maxFrames)

        local layout = CopyTable(groupLayout)
        layout.layoutIndex = (info.own and baseIndexOwn or baseIndexOthers) + (info.dispel == false and 0.5 or 0)
        header:SetAuraGroupLayout(info.key, layout)
    end

    -- Update size + icon crop on all engine owned buttons. Enchant frames live
    -- outside the aura groups and stay cached: their enumeration
    -- (GetActiveItemEnchantmentFrames) sits on ManagedAuraContainerPrivateMixin
    -- only, which is not part of the addon facing inbound mixin chain
    for _, key in ipairs(header.gwGroupKeys) do
        for i = 1, header:GetAuraGroupFrameCount(key) do
            UpdateButtonSizeAndCrop(header:GetAuraGroupFrame(key, i), db)
        end
    end
    for _, enchantFrame in next, header.gwEnchantButtons do
        UpdateButtonSizeAndCrop(enchantFrame, db)
    end

    -- mirror isMoved onto the layout proxy (the secure layout manager reads it there)
    if header.gwLayoutProxy then
        header.gwLayoutProxy:SetAttribute("isMoved", header.isMoved and true or false)
    end

    -- container size (for the mover frame), analogous to minWidth/minHeight of the old headers
    local minWidth = ((wrapAfter == 1 and 0 or horizontalSpacing) + width) * (isColumnLayout and maxWraps or wrapAfter)
    local minHeight = ((maxWraps == 1 and 0 or verticalSpacing) + height) * (isColumnLayout and wrapAfter or maxWraps)
    header:SetSize(math.max(minWidth, width + 1), math.max(minHeight, height + 1))

    -- MaxWraps has to be enforced by geometry: the per group frame budget cannot cap the
    -- TOTAL - own/others (and the dispel split) are separate groups, each with its own
    -- budget, and the shown counts are secret, so no distribution can be computed. The
    -- container is already sized to exactly the MaxWraps box, so everything the flow
    -- lays out beyond it is cut here, including its mouse interaction.
    header:SetClipsChildren(true)

    -- anchoring: buffs to the mover, debuffs relative to the buffs (as long as not moved separately)
    if header.filter == "HELPFUL" then
        header:ClearAllPoints()
        header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
    else
        header:ClearAllPoints()
        if not header.isMoved then
            local anchor = DIRECTION_TO_DEBUFF_ANCHOR[grow_dir]
            header:SetPoint(anchor, GW2UIPlayerBuffs, anchor, 0, DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] * (verticalSpacing + height))
        else
            header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
        end
    end
end
GW.UpdateAuraHeader = UpdateAuraHeader

local function newContainer(filter)
    local name = filter == "HELPFUL" and "GW2UIPlayerBuffs" or "GW2UIPlayerDebuffs"
    local isDebuff = filter == "HARMFUL"

    local h = CreateFrame("AuraContainer", name, UIParent, "CustomAuraContainerTemplate")
    h:SetClampedToScreen(true)
    h.gwIsAuraContainer = true
    -- dispel = nil marks a group without the dispellable split (the buff bar pair)
    if isDebuff then
        h.gwGroupInfo = {
            { key = GROUP_OWN_DISPELLABLE, own = true, dispel = true },
            { key = GROUP_OWN, own = true, dispel = false },
            { key = GROUP_OTHERS_DISPELLABLE, own = false, dispel = true },
            { key = GROUP_OTHERS, own = false, dispel = false },
        }
    else
        h.gwGroupInfo = {
            { key = GROUP_OWN, own = true },
            { key = GROUP_OTHERS, own = false },
        }
    end
    h.gwGroupKeys = {}
    for _, info in ipairs(h.gwGroupInfo) do
        tinsert(h.gwGroupKeys, info.key)
    end
    h.gwEnchantButtons = {}
    h.filter = filter
    h.setting = filter == "HELPFUL" and "PlayerBuffs" or "PlayerDebuffs"
    h.name = name

    -- fixed groups (see comment above) — options are set in UpdateAuraHeader
    for _, info in ipairs(h.gwGroupInfo) do
        h:AddAuraGroup(info.key, filter, {
            initializeFrame = function(button) InitializeAuraButton(button, h, isDebuff, false, info.dispel) end,
        })
    end

    if filter == "HELPFUL" then
        -- weapon enchants (replaces includeWeapons + GetWeaponEnchantInfo polling)
        for _, slot in next, { AuraContainerItemEnchantmentSlot.MainHand, AuraContainerItemEnchantmentSlot.OffHand } do
            h:AddItemEnchantment(slot, {
                initializeFrame = function(button)
                    InitializeAuraButton(button, h, false, true)
                    tinsert(h.gwEnchantButtons, button)
                end,
            })
        end
        h:SetItemEnchantmentLayout({ placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups })

        RegisterMovableFrame(h, SHOW_BUFFS, "PlayerBuffFrame", "Blizzard,Aura", {316, 100}, {"default", "scaleable"}, true)
    else
        RegisterMovableFrame(h, SHOW_DEBUFFS, "PlayerDebuffFrame", "Blizzard,Aura", {316, 60}, {"default", "scaleable"}, true)
    end

    -- The AuraContainer is a "forbidden frame": SecureHandler frame refs (layout manager)
    -- are not allowed on it. A protected proxy stands in for it in the secure layout —
    -- the snippet only toggles Show/Hide and reads the isMoved attribute on the registered frame,
    -- only the mover the container is attached to gets moved anyway.
    local proxy = CreateFrame("Frame", nil, UIParent, "SecureFrameTemplate")
    proxy:SetSize(1, 1)
    proxy:SetPoint("BOTTOM")
    proxy.gwMover = h.gwMover
    proxy:SetAttribute("isMoved", h.isMoved and true or false)
    proxy:HookScript("OnShow", function() h:Show() end)
    proxy:HookScript("OnHide", function() h:Hide() end)
    h.gwLayoutProxy = proxy

    -- Vehicle switching: the container is unit-based, a simple (insecure) event switch
    -- replaces the old attribute driver construct
    h:SetUnit("player")
    -- IMPORTANT: containers are disabled by default — without SetEnabled(true) the
    -- container does not register UNIT_AURA and parses nothing (ShouldRegisterForDynamicEvents
    -- requires IsVisible() AND IsEnabled())
    h:SetEnabled(true)
    local unitWatcher = CreateFrame("Frame")
    unitWatcher:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    unitWatcher:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    unitWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitWatcher:SetScript("OnEvent", function()
        h:SetUnit(UnitHasVehicleUI("player") and "vehicle" or "player")
    end)

    -- hide during pet battles (replaces the SecureHandler state driver)
    local petBattleWatcher = CreateFrame("Frame")
    petBattleWatcher:RegisterEvent("PET_BATTLE_OPENING_START")
    petBattleWatcher:RegisterEvent("PET_BATTLE_CLOSE")
    petBattleWatcher:SetScript("OnEvent", function(_, event)
        h:SetShown(event ~= "PET_BATTLE_OPENING_START")
    end)

    UpdateAuraHeader(h)
    GW.RegisterAuraContainer(h, UpdateAuraHeader)

    return h
end

local function loadAuras(lm)
    local hb = newContainer("HELPFUL")
    hb:Show()
    lm:RegisterBuffFrame(hb.gwLayoutProxy)
    hooksecurefunc(hb.gwMover, "StopMovingOrSizing", function()
        local grow_dir = GW.settings[hb.setting].GrowDirection
        local anchor_hb = DIRECTION_TO_POINT[grow_dir]

        hb:ClearAllPoints()
        hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
    end)

    local hd = newContainer("HARMFUL")
    hd:Show()
    lm:RegisterDebuffFrame(hd.gwLayoutProxy)
    hooksecurefunc(hd.gwMover, "StopMovingOrSizing", function()
        local grow_dir = GW.settings[hd.setting].GrowDirection
        local anchor_hd = DIRECTION_TO_POINT[grow_dir]

        hd:ClearAllPoints()
        hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
    end)

    -- Raise PetBattleFrame
    if PetBattleFrame then
        PetBattleFrame:SetFrameLevel(hb:GetFrameLevel() + 5)
    end

    -- Private auras no longer exist as a separate system in 12.1 —
    -- they now run through the container as normal debuffs
end

local function LoadPlayerAuras(lm)
    -- hide the Blizzard bars
    BuffFrame:GwKill()
    if DebuffFrame then
        DebuffFrame:GwKill()
    end

    -- The container uses its own (secure) tooltip — switch the look to GW style
    -- (once, gated on TOOLTIPS_ENABLED — same place as the factory containers)
    GW.EnsureAuraTooltipStyle()

    loadAuras(lm)
end
GW.LoadPlayerAuras = LoadPlayerAuras
