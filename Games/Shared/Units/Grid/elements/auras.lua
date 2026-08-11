---@class GW2
local GW = select(2, ...)
local BadDispels = GW.Libs.Dispel:GetBadList()
local INDICATORS = GW.INDICATORS
local INDICATOR_CONFIG = {
    TOPLEFT = { point = "TOPLEFT", x = 0.3, y = -0.3 },
    TOP = { point = "TOP", x = 0, y = -0.3 },
    LEFT = { point = "LEFT", x = 0.3, y = 0 },
    TOPRIGHT = { point = "TOPRIGHT", x = -0.3, y = -0.3 },
    CENTER = { point = "CENTER", x = 0, y = 0 },
    RIGHT = { point = "RIGHT", x = -0.3, y = 0 },
}

local function BuildIndicatorSpellIndex(indicators)
    local index = {}
    for mainSpellId, data in pairs(indicators) do
        local includedIds = data[4]
        if includedIds then
            for _, includedId in ipairs(includedIds) do
                index[includedId] = mainSpellId
            end
        end
    end
    return index
end

local DEFAULT_INDICATOR_COLOR = { 1, 1, 1 }

local function GetIndicatorDataForSpellId(indicators, spellId)
    if indicators then
        local indicator = indicators[spellId]
        if indicator then
            return indicator, spellId
        end

        -- Fallback: check includedIds lists via cached index for indirect matches
        if not indicators.__includedIndex then
            indicators.__includedIndex = BuildIndicatorSpellIndex(indicators)
        end

        local mainSpellId = indicators.__includedIndex[spellId]
        if mainSpellId then
            return indicators[mainSpellId], mainSpellId
        end
    end

    -- custom spell ids (entered via the settings popup) have no predefined entry:
    -- the spell acts as its own indicator with a neutral color — it only takes
    -- effect when the id is actually assigned to a position
    return DEFAULT_INDICATOR_COLOR, spellId
end

local function Construct_AuraIcon(self, button)
    button.Count:ClearAllPoints()
    button.Count:SetPoint("TOPLEFT")
    button.Count:SetPoint("BOTTOMRIGHT")
    button.Count:SetFont(UNIT_NAME_FONT, 11, "OUTLINE")
    button.Count:SetTextColor(1, 1, 1)
    button.Count:SetJustifyH("CENTER")

    button.Stealable:SetTexture()
    button.Overlay:SetTexture()

    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("TOPLEFT", 1, -1)
    button.Icon:SetPoint("BOTTOMRIGHT", -1, 1)

    button.backdrop = button:CreateTexture(nil, "BACKGROUND")
    button.backdrop:ClearAllPoints()
    button.backdrop:SetPoint("TOPLEFT")
    button.backdrop:SetPoint("BOTTOMRIGHT")
    button.backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty.png")
    button.backdrop:Hide()

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:ClearAllPoints()
    button.background:SetPoint("TOPLEFT")
    button.background:SetPoint("BOTTOMRIGHT")
    button.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    button.background:Hide()
end
GW.Construct_AuraIcon = Construct_AuraIcon

local function PostUpdateButton(self, button, unit, data, position)
    local parent = self:GetParent()

    if data.isHarmfulAura then
        local size = 16
        local isDispellable = data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) or false
        local isImportant = (parent.raidShowImportantInstanceDebuffs and GW.ImportantRaidDebuff[data.spellId]) or false
        if isImportant and isDispellable then
            size = size * GW.GetDebuffScaleBasedOnPrio()
        elseif isImportant then
            size = size * tonumber(parent.raidDebuffScale)
        elseif isDispellable then
            size = size * tonumber(parent.raidDispelDebuffScale)
        end

        if data.dispelName and GW.Colors.DebuffColors[data.dispelName] then
            button.background:SetVertexColor(GW.Colors.DebuffColors[data.dispelName]:GetRGB())
        else
            button.background:SetVertexColor(GW.Colors.DebuffColors.None:GetRGB())
        end

        local sizeChanged = button.gwAuraSize ~= size
        button.gwAuraSize = size
        button:SetSize(size, size)
        if sizeChanged and not self.gwRepositionQueued then
            self.gwRepositionQueued = true
            C_Timer.After(0, function()
                self.gwRepositionQueued = nil
                self:ForceUpdate()
            end)
        end
        button.background:Show()
        button.backdrop:Hide()
    else
        button.gwAuraSize = nil
        button.background:Hide()
        button.backdrop:Show()
    end

    -- aura tooltips
    if parent.showAuraTooltipInCombat == "NEVER" then
        button:EnableMouse(false)
    elseif parent.showAuraTooltipInCombat == "ALWAYS" then
        button:EnableMouse(true)
    elseif parent.showAuraTooltipInCombat == "OUT_COMBAT" then
        button:EnableMouse(not InCombatLockdown()) -- this is trigger by an event
    elseif parent.showAuraTooltipInCombat == "IN_COMBAT" then
        button:EnableMouse(InCombatLockdown()) -- this is trigger by an event
    end
end

local function ClearIndicatorFrame(frame)
    frame:Hide()
    frame.auraInstanceId = nil
    frame.isBar = nil
    frame.expires = nil
    frame.duration = nil

    if frame.textFrame then
        frame.textFrame.text:Hide()
    end

    if frame.cooldown then
        frame.cooldown:Hide()
    end

    if frame.isIndicatorBar then
        frame:SetValue(0)
        frame:SetScript("OnUpdate", nil)
    end
end

local function UpdateIndicatorBarValue(self)
    if not self.auraInstanceId or not self.expires or not self.duration or self.duration <= 0 then
        return false
    end

    local value = (self.expires - GetTime()) / self.duration
    if value <= 0 then
        return false
    end

    self:SetValue(math.min(1, value))
    return true
end

local function IndicatorBar_OnUpdate(self)
    if not UpdateIndicatorBarValue(self) then
        ClearIndicatorFrame(self)
    end
end

local function UpdateIndicatorStack(frame, parent, applications)
    local text = frame.textFrame.text
    if not parent.showRaidIndicatorStacks then
        text:Hide()
        return
    end

    applications = applications or 0
    if applications > 1 then
        text:SetText(applications)
        text:SetFont(UNIT_NAME_FONT, applications > 9 and 8 or 10, "OUTLINE")
        text:Show()
    else
        text:Hide()
    end
end

local function UpdateIconIndicator(frame, parent, data)
    UpdateIndicatorStack(frame, parent, data.applications)

    if parent.showRaidIndicatorIcon then
        frame.icon:SetTexture(data.icon)
    else
        local color = frame.color
        frame.icon:SetColorTexture(color.r, color.g, color.b)
    end

    if data.expirationTime and data.duration and data.duration > 0 then
        frame.cooldown:SetCooldown(data.expirationTime - data.duration, data.duration)
    else
        frame.cooldown:SetCooldown(0, 0)
    end

    if parent.showRaidIndicatorTimer then
        frame.cooldown:Show()
    else
        frame.cooldown:Hide()
    end

    frame:Show()
end

local function CheckForAuraIndicators(self, parent, isPlayerBuff, data, shouldDisplay)
    local raidIndicators = parent.raidIndicators
    if not isPlayerBuff or not raidIndicators then
        return shouldDisplay
    end

    local indicators = GW.AURAS_INDICATORS[GW.myclass]
    local indicator, indicatorSpellId = GetIndicatorDataForSpellId(indicators, data.spellId)
    if not indicator then
        return shouldDisplay
    end

    for _, pos in ipairs(INDICATORS) do
        if raidIndicators[pos] == indicatorSpellId then
            local frame = self["indicator" .. pos]
            local r, g, b = unpack(indicator)

            frame.isBar = pos == "BAR"
            frame.auraInstanceId = data.auraInstanceID

            if frame.isBar then
                frame.expires = data.expirationTime
                frame.duration = data.duration
                frame:SetScript("OnUpdate", IndicatorBar_OnUpdate)

                if UpdateIndicatorBarValue(frame) then
                    frame:Show()
                else
                    ClearIndicatorFrame(frame)
                end
            else
                frame.color.r = r
                frame.color.g = g
                frame.color.b = b
                UpdateIconIndicator(frame, parent, data)
                shouldDisplay = false
            end
        end
    end

    return shouldDisplay
end

local function FilterAura(self, unit, data)
    local parent = self:GetParent()
    local shouldDisplay = false
    local isImportant, isDispellable

    if data.isHelpfulAura then
        local isPlayerBuff = data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle"

        if parent.showBuffs then
            local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(data.spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
            if hasCustom then
                shouldDisplay = showForMySpec or (alwaysShowMine and (data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle"))
            else
                shouldDisplay = (data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle") and (data.canApplyAura or data.isAuraPlayer) and not SpellIsSelfBuff(data.spellId)
            end

            if shouldDisplay and parent.ignoredAuraSpellIDs then
                shouldDisplay = not parent.ignoredAuraSpellIDs[data.spellId]
            end
        end

        return CheckForAuraIndicators(self, parent, isPlayerBuff, data, shouldDisplay)
    else
        isDispellable = data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) or false
        isImportant = (parent.raidShowImportantInstanceDebuffs and GW.ImportantRaidDebuff[data.spellId]) or false

        if data.dispelName and BadDispels[data.spellId] and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
            data.dispelName = "BadDispel"
        end

        if parent.showDebuffs then
            if parent.showOnlyDispelDebuffs then
                if isDispellable then
                    shouldDisplay = data.name and not (parent.ignoredAuraSpellIDs and parent.ignoredAuraSpellIDs[data.spellId] or data.spellId == 6788 and data.sourceUnit and GW.UnitNotUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                end
            else
                shouldDisplay = data.name and not (parent.ignoredAuraSpellIDs and parent.ignoredAuraSpellIDs[data.spellId] or data.spellId == 6788 and data.sourceUnit and GW.UnitNotUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
            end
        end

        if parent.raidShowImportantInstanceDebuffs and not shouldDisplay then
            shouldDisplay = isImportant
        end

        return shouldDisplay
    end
end

-- Update indicator data
local function PostProcessAuraData(self, unit, data)
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame and frame.auraInstanceId and frame.auraInstanceId == data.auraInstanceID then
            if frame.isBar then
                frame.expires = data.expirationTime
                frame.duration = data.duration
                frame:SetScript("OnUpdate", IndicatorBar_OnUpdate)

                if not UpdateIndicatorBarValue(frame) then
                    ClearIndicatorFrame(frame)
                end
            else
                UpdateIconIndicator(frame, self:GetParent(), data)
            end
        end
    end

    return data
end

local function PostUpdateInfoRemovedAuraID(self, auraInstanceID)
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame and frame.auraInstanceId and frame.auraInstanceId == auraInstanceID then
            ClearIndicatorFrame(frame)
        end
    end
end

local function PreUpdateAuras(self, unit, isFullUpdate)
    if not isFullUpdate then return end
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame then
            ClearIndicatorFrame(frame)
        end
    end
end

local function HandleTooltip(self, event)
    local mode = self.showAuraTooltipInCombat
    if mode ~= "OUT_COMBAT" and mode ~= "IN_COMBAT" then return end

    local enable = (mode == "IN_COMBAT") == (event == "PLAYER_REGEN_DISABLED")
    local auras = self.Auras
    for i = 1, auras.createdButtons or 0 do
        auras[i]:EnableMouse(enable)
    end
end

-- ========================================================================
-- Retail (12.1): grid auras run on the AuraContainer system — the container
-- tracks and renders the auras inside blizzards secure environment, so the
-- display keeps working while aura values are secret in combat. The oUF Auras
-- element is not registered on retail (frame.Auras stays nil).
--
-- Group model (one container, everything flows together from the bottom right
-- like the old element):
--   * importantDispellable / importantOnly: GW.ImportantRaidDebuff via
--     includeSpellIDs, sized by the important/dispel scale priority
--   * dispellableDebuffs: RAID_PLAYER_DISPELLABLE token, dispel scale
--   * debuffs: everything else (important ids excluded, so nothing shows twice);
--     advanced filter branches replace this group when filters are selected
--   * buffs: base group, advanced filter branches replace it when selected
-- ========================================================================

local GRID_BUFF_SIZE = 14
local GRID_DEBUFF_SIZE = 16

-- ---- aura indicators (retail): one single-button tracker container per
-- configured position. The engine drives icon, stacks, cooldown swipe and the
-- BAR duration bar, so the indicators keep working while aura values are secret.
-- The visible widgets are children of the aura button (inbound API requirement)
-- but ANCHORED to the container: the button subtree becomes access restricted
-- after creation, the container stays ours and can be resized/re-anchored by the
-- settings at any time.

local function BuildIndicatorSpellList(spellId)
    local list = { [spellId] = true }
    local indicators = GW.AURAS_INDICATORS[GW.myclass]
    local predefined = indicators and indicators[spellId]
    if predefined and predefined[4] then
        for _, includedId in ipairs(predefined[4]) do
            list[includedId] = true
        end
    end
    return list, predefined
end

local function CreateGridIndicatorTracker(frame, pos, spellList, indicatorColor)
    local isBar = pos == "BAR"
    local widgets = {}
    -- mutable: the reuse path swaps the color when the position gets a different
    -- spell assigned — a plain captured value would stay frozen at creation time
    local colorState = { color = indicatorColor }

    -- geometry carrier: the widgets are children of the aura button (inbound API
    -- requirement) but ANCHOR to this frame. The button subtree gets access
    -- restricted, and the AuraContainer re-applies its self-measured size after
    -- every engine layout — the sizer is the only rect that stays fully ours, so
    -- the settings can position/resize the indicator at any time
    local holder = CreateFrame("Frame", nil, frame)
    holder:SetSize(13, 13)

    local container = GW.CreateAuraTrackerContainer({
        parent = frame,
        unit = frame.unit or "player",
        filter = "HELPFUL|PLAYER",
        spellIDs = spellList,
        width = 13,
        height = 13,
        createWidgets = function(button)
            if isBar then
                local bar = CreateFrame("StatusBar", nil, button)
                bar:SetPoint("TOPLEFT", holder, "TOPLEFT")
                bar:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT")
                bar:SetOrientation("VERTICAL")
                bar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
                bar:SetStatusBarColor(1, 0.5, 0)

                bar.bg = bar:CreateTexture(nil, "BORDER")
                bar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
                bar.bg:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 1)
                bar.bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
                bar.bg:SetVertexColor(0, 0, 0, 1)

                widgets.bar = bar
                return { durationBar = bar }
            end

            GW.AddPandemicHighlight(button, holder, function() return frame.pandemicHighlight end, button)

            local backdrop = button:CreateTexture(nil, "BACKGROUND")
            backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
            backdrop:SetVertexColor(0, 0, 0)
            backdrop:SetPoint("TOPLEFT", holder, "TOPLEFT")
            backdrop:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT")

            -- monochrome square (indicator color) and spell icon share the slot,
            -- the settings toggle which of the two is visible
            local color = button:CreateTexture(nil, "ARTWORK")
            color:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
            color:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, -1)
            color:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -1, 1)

            local icon = button:CreateTexture(nil, "ARTWORK", nil, 1)
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, -1)
            icon:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -1, 1)
            button:SetIcon(icon)

            local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
            cooldown:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, -1)
            cooldown:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -1, 1)
            cooldown:SetDrawBling(false)
            cooldown:SetDrawEdge(false)
            cooldown:SetReverse(true)
            cooldown:SetHideCountdownNumbers(true)
            button:SetDurationCooldown(cooldown)

            local stacks = button:CreateFontString(nil, "OVERLAY")
            stacks:SetFont(UNIT_NAME_FONT, 10, "OUTLINE")
            stacks:SetJustifyH("CENTER")
            stacks:SetPoint("CENTER", holder, "CENTER")
            button:SetApplicationCount(stacks)

            -- apply the current settings right away — the widgets only exist from the
            -- first button on, the settings updater can run before that
            local r, g, b = 1, 1, 1
            if colorState.color then
                r, g, b = unpack(colorState.color)
            end
            color:SetVertexColor(r, g, b)
            color:SetShown(not frame.showRaidIndicatorIcon)
            icon:SetShown(frame.showRaidIndicatorIcon and true or false)
            cooldown:SetDrawSwipe(frame.showRaidIndicatorTimer and true or false)
            stacks:SetShown(frame.showRaidIndicatorStacks and true or false)

            widgets.colorTexture, widgets.icon, widgets.cooldown, widgets.stacks = color, icon, cooldown, stacks
            return {}
        end,
    })

    -- above the frames health/power textures, like the old indicator template
    -- (frameLevel 20 in gridFrameAuraIndicator.xml)
    container:SetFrameLevel(20)
    -- park the container itself — it renders nothing (the widgets follow the sizer),
    -- but an unanchored ancestor would keep the widgets from rendering
    container:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    container.gwWidgets = widgets
    container.gwIsBar = isBar
    container.gwSizer = holder
    container.gwColorState = colorState
    return container
end

-- (re)applies position, size, spell list and display modes of all configured
-- indicators; returns the spell ids owned by ICON indicators so the regular buff
-- display can suppress them (the corner indicator replaces the buff icon, the BAR
-- keeps it — like the old shouldDisplay logic)
-- every tracker/engine call below is guarded by cached state: the settings pipeline
-- (UpdateGridSettings "ALL") runs this for EVERY grid frame — unguarded re-applies
-- trigger container re-evaluations and freeze the client on large raids
local function UpdateGridIndicators(frame)
    local trackers = frame.gwIndicatorTrackers
    if not trackers then return nil end

    local size = tonumber(frame.raidIndicatorSize) or 13
    local barWidth = tonumber(frame.raidIndicatorBarWidth) or 2
    local iconIndicatorSpells

    for _, pos in ipairs(INDICATORS) do
        local spellId = frame.raidIndicators and tonumber(frame.raidIndicators[pos]) or 0
        local tracker = trackers[pos]

        if spellId and spellId > 0 then
            if not tracker or tracker.gwAppliedSpellId ~= spellId then
                local spellList, predefined = BuildIndicatorSpellList(spellId)
                if not tracker then
                    tracker = CreateGridIndicatorTracker(frame, pos, spellList, predefined)
                    trackers[pos] = tracker
                else
                    tracker:SetAuraGroupCandidateFilters("tracker", { includeSpellIDs = spellList })
                end
                tracker.gwAppliedSpellId = spellId
                tracker.gwSpellList = spellList
                tracker.gwIndicatorColor = predefined
                -- keep the createWidgets closure in sync — buttons built AFTER a
                -- spell reassignment must use the new spells color
                tracker.gwColorState.color = predefined
            end

            if not tracker.gwAppliedActive then
                tracker.gwAppliedActive = true
                tracker:SetAuraGroupMaxFrameCount("tracker", 1)
            end
            if frame.unit and tracker.gwAppliedUnit ~= frame.unit then
                tracker.gwAppliedUnit = frame.unit
                tracker:SetUnit(frame.unit)
            end

            local geoSig = pos == "BAR" and ("BAR:" .. barWidth) or (pos .. ":" .. size)
            if tracker.gwAppliedGeoSig ~= geoSig then
                tracker.gwAppliedGeoSig = geoSig
                -- geometry lives on the sizer frame — the widgets anchor to it and
                -- the engine never touches it (unlike the container, which re-applies
                -- its self-measured size after every layout)
                local sizer = tracker.gwSizer
                sizer:ClearAllPoints()
                if pos == "BAR" then
                    -- left edge flush on the frame, growing right — a fixed right
                    -- side offset would leave a width dependent gap
                    sizer:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)
                    sizer:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, 0)
                    sizer:SetWidth(barWidth)
                else
                    local config = INDICATOR_CONFIG[pos]
                    sizer:SetSize(size, size)
                    sizer:SetPoint(config.point, frame, config.point, config.x, config.y)
                end
            end

            if pos ~= "BAR" then
                -- display modes; best effort — the widgets are button children and the
                -- subtree can be access restricted while auras are secret. New buttons
                -- apply the current settings themselves in createWidgets.
                local r, g, b = 1, 1, 1
                if tracker.gwIndicatorColor then
                    r, g, b = unpack(tracker.gwIndicatorColor)
                end
                local modeSig = strjoin(":", tostring(frame.showRaidIndicatorIcon), tostring(frame.showRaidIndicatorTimer),
                    tostring(frame.showRaidIndicatorStacks), r, g, b)
                if tracker.gwAppliedModeSig ~= modeSig then
                    local w = tracker.gwWidgets
                    local ok = pcall(function()
                        w.icon:SetShown(frame.showRaidIndicatorIcon and true or false)
                        w.colorTexture:SetShown(not frame.showRaidIndicatorIcon)
                        w.colorTexture:SetVertexColor(r, g, b)
                        w.cooldown:SetDrawSwipe(frame.showRaidIndicatorTimer and true or false)
                        w.stacks:SetShown(frame.showRaidIndicatorStacks and true or false)
                    end)
                    if ok then
                        tracker.gwAppliedModeSig = modeSig
                    end
                end

                iconIndicatorSpells = iconIndicatorSpells or {}
                for id in pairs(tracker.gwSpellList) do
                    iconIndicatorSpells[id] = true
                end
            end
        elseif tracker and tracker.gwAppliedActive then
            tracker.gwAppliedActive = false
            tracker:SetAuraGroupMaxFrameCount("tracker", 0)
        end
    end

    return iconIndicatorSpells
end

-- resource bar aware aura anchoring: with the "HEALER" mode only healer frames
-- carry the power bar, the others anchor lower
local function HasGridResourceBar(frame)
    if frame.showResscoureBar == "ALL" then
        return true
    end
    if frame.showResscoureBar ~= "HEALER" then
        return false
    end
    return (GW.allowRoles and UnitGroupRolesAssigned(frame.unit or "player")) == "HEALER"
end

local function AnchorGridAuraContainer(frame)
    local container = frame.gwAuraContainer
    if not container then return end

    local offsetY = HasGridResourceBar(frame) and 5 or 2
    if frame.gwAuraAnchorY ~= offsetY then
        frame.gwAuraAnchorY = offsetY
        container:ClearAllPoints()
        container:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, offsetY)
    end
end

-- Aura tooltip setting. "OUT_COMBAT" is suppressed by the engine via
-- SetHideTooltipInCombat, only the inverse "IN_COMBAT" mode has to toggle the mouse
-- on the regen events. The applied state is cached on full success only — buttons
-- can be access restricted in combat and are retried on the next regen event.
local function ApplyGridAuraMouseState(frame)
    local container = frame.gwAuraContainer
    if not container then return end

    local mode = frame.showAuraTooltipInCombat
    local hideInCombat = mode == "OUT_COMBAT"
    local enable = (not mode or mode == "ALWAYS" or hideInCombat
        or (mode == "IN_COMBAT" and InCombatLockdown())) and true or false

    container.gwConfig.enableMouse = enable
    container.gwConfig.hideTooltipInCombat = hideInCombat
    if frame.gwAuraMouseEnabled ~= enable or frame.gwAuraHideTooltip ~= hideInCombat then
        local allApplied = true
        GW.ForEachAuraContainerButton(container, function(button)
            if not pcall(button.EnableMouse, button, enable) then
                allApplied = false
            end
            if not pcall(button.SetHideTooltipInCombat, button, hideInCombat) then
                allApplied = false
            end
        end)
        if allApplied then
            frame.gwAuraMouseEnabled = enable
            frame.gwAuraHideTooltip = hideInCombat
        end
    end
end

local gridEventFrames
local function RegisterGridAuraEvents(frame)
    if not gridEventFrames then
        gridEventFrames = {}
        local watcher = CreateFrame("Frame")
        watcher:RegisterEvent("PLAYER_REGEN_DISABLED")
        watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
        watcher:RegisterEvent("PLAYER_ROLES_ASSIGNED")
        watcher:RegisterEvent("GROUP_ROSTER_UPDATE")
        watcher:SetScript("OnEvent", function(_, event)
            for f in pairs(gridEventFrames) do
                if event == "PLAYER_ROLES_ASSIGNED" or event == "GROUP_ROSTER_UPDATE" then
                    AnchorGridAuraContainer(f)
                else
                    ApplyGridAuraMouseState(f)
                    -- retries indicator display modes whose in-combat application
                    -- failed (everything unchanged is skipped by the caches)
                    UpdateGridIndicators(f)
                end
            end
        end)
    end
    gridEventFrames[frame] = true
end

-- shallow spell-set comparison, used to keep a STABLE exclude table reference —
-- a fresh table every pass would defeat the factory's change detection
local function SameSpellSet(a, b)
    if a == b then return true end
    if not a or not b then return false end
    for k in pairs(a) do
        if not b[k] then return false end
    end
    for k in pairs(b) do
        if not a[k] then return false end
    end
    return true
end

-- stable candidate filter table for "everything except the important ids"
local importantExcludeFilters
local function GetImportantExcludeFilters()
    if not importantExcludeFilters then
        importantExcludeFilters = { excludeSpellIDs = GW.ImportantRaidDebuff }
    end
    return importantExcludeFilters
end

local function GetGridDebuffBranches(frame)
    local branches = GW.BuildAdvancedAuraFilterBranches("HARMFUL", frame.debuffFilters)
    if #branches == 0 then return nil end

    -- the dispellable group owns the RAID_PLAYER_DISPELLABLE auras (own scale) —
    -- keep the branches disjoint from it
    for _, branch in ipairs(branches) do
        branch.filter = branch.filter .. "|!RAID_PLAYER_DISPELLABLE"
    end
    return branches
end

local function UpdateGridAuraContainers(frame)
    local container = frame.gwAuraContainer
    if not container then return end
    local cfg = container.gwConfig

    cfg.maximumLineSize = (frame.unitWidth or frame:GetWidth() or 40) - 2

    -- indicators first: icon indicators own their spells exclusively, the regular
    -- buff display suppresses them (together with the per grid ignore list)
    local iconIndicatorSpells = UpdateGridIndicators(frame)
    local exclude = iconIndicatorSpells
    for spellId, enabled in pairs(frame.ignoredAuraSpellIDs or {}) do
        if enabled then
            exclude = exclude or {}
            exclude[spellId] = true
        end
    end
    -- keep the previous table reference when the content is unchanged, so the
    -- factory's candidate filter change detection can skip the re-apply
    if SameSpellSet(exclude, frame.gwAuraExcludeCache) then
        exclude = frame.gwAuraExcludeCache
    else
        frame.gwAuraExcludeCache = exclude
    end
    cfg.excludeSpellIDs = exclude

    local showImportant = frame.raidShowImportantInstanceDebuffs and next(GW.ImportantRaidDebuff) ~= nil
    local importantScale = tonumber(frame.raidDebuffScale) or 1
    local dispelScale = tonumber(frame.raidDispelDebuffScale) or 1
    local prioScale = GW.GetDebuffScaleBasedOnPrio and GW.GetDebuffScaleBasedOnPrio() or math.max(importantScale, dispelScale)

    local buffBranches = frame.showBuffs and GW.BuildAdvancedAuraFilterBranches("HELPFUL", frame.buffFilters) or nil
    if buffBranches and #buffBranches == 0 then buffBranches = nil end
    local debuffBranches = frame.showDebuffs and GetGridDebuffBranches(frame) or nil

    -- the important ids leave the generic groups so they only render in their own,
    -- scaled groups (stable table reference — see the factory change detection)
    local importantExclude = showImportant and GetImportantExcludeFilters() or nil

    for _, group in next, cfg.groups do
        if group.key == "importantDispellable" then
            group.size = GW.RoundInt(GRID_DEBUFF_SIZE * prioScale)
            group.maxFrameCount = (frame.showDebuffs and showImportant) and 12 or 0
        elseif group.key == "importantOnly" then
            group.size = GW.RoundInt(GRID_DEBUFF_SIZE * importantScale)
            group.maxFrameCount = (frame.showDebuffs and showImportant) and 12 or 0
        elseif group.key == "dispellableDebuffs" then
            group.size = GW.RoundInt(GRID_DEBUFF_SIZE * dispelScale)
            group.maxFrameCount = frame.showDebuffs and 12 or 0
            group.candidateFilters = importantExclude
        elseif group.key == "debuffs" then
            group.size = GRID_DEBUFF_SIZE
            group.maxFrameCount = (frame.showDebuffs and not debuffBranches) and 12 or 0
            group.candidateFilters = importantExclude
        elseif group.key == "buffs" then
            group.size = GRID_BUFF_SIZE
            group.maxFrameCount = (frame.showBuffs and not buffBranches) and 12 or 0
        end
    end

    AnchorGridAuraContainer(frame)
    ApplyGridAuraMouseState(frame)

    -- both branch sets target the SAME container: only the last call runs the layout
    container:GwSetAdvancedBranches("debuffs", debuffBranches, function(branch, index)
        return {
            size = GRID_DEBUFF_SIZE,
            maxFrameCount = 12,
            isDebuff = true,
            hideDuration = true,
            candidateFilters = importantExclude,
            layoutIndex = 4 + index * 0.01,
        }
    end, true)
    container:GwSetAdvancedBranches("buffs", buffBranches, function(branch, index)
        return {
            size = GRID_BUFF_SIZE,
            maxFrameCount = 12,
            hideDuration = true,
            layoutIndex = 5 + index * 0.01,
        }
    end)

    if frame.unit and container.gwAppliedUnit ~= frame.unit then
        container.gwAppliedUnit = frame.unit
        container:SetUnit(frame.unit)
    end
end

local function Construct_GridAuraContainers(frame)
    local container = GW.CreateUnitAuraContainer({
        parent = frame,
        unit = frame.unit or "player",
        pandemicEnabled = function() return frame.pandemicHighlight end,
        dispelIconEnabled = function() return frame.showDispelIcon end,
        tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
        anchorPoint = "BOTTOMRIGHT",
        growLeft = true,
        growUp = true,
        elementSpacing = 1,
        lineSpacing = 1,
        onSettingsRefresh = function() UpdateGridAuraContainers(frame) end,
        groups = {
            -- showDispelIcon sits on the RAID_PLAYER_DISPELLABLE groups, so the corner
            -- icon marks exactly what this character can dispel
            { key = "importantDispellable", filter = "HARMFUL|RAID_PLAYER_DISPELLABLE", candidateFilters = { includeSpellIDs = GW.ImportantRaidDebuff }, size = GRID_DEBUFF_SIZE, maxFrameCount = 0, isDebuff = true, hideDuration = true, showDispelIcon = true, dispelIconSize = 10 },
            { key = "importantOnly", filter = "HARMFUL|!RAID_PLAYER_DISPELLABLE", candidateFilters = { includeSpellIDs = GW.ImportantRaidDebuff }, size = GRID_DEBUFF_SIZE, maxFrameCount = 0, isDebuff = true, hideDuration = true },
            { key = "dispellableDebuffs", filter = "HARMFUL|RAID_PLAYER_DISPELLABLE", size = GRID_DEBUFF_SIZE, maxFrameCount = 12, isDebuff = true, hideDuration = true, showDispelIcon = true, dispelIconSize = 10 },
            { key = "debuffs", filter = "HARMFUL|!RAID_PLAYER_DISPELLABLE", size = GRID_DEBUFF_SIZE, maxFrameCount = 12, isDebuff = true, hideDuration = true },
            { key = "buffs", filter = "HELPFUL", size = GRID_BUFF_SIZE, maxFrameCount = 12, hideDuration = true, showPandemic = true },
        },
    })
    container:SetFrameLevel(frame.RaisedElementParent and frame.RaisedElementParent.AuraLevel or (frame:GetFrameLevel() + 4))
    container:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    frame.gwAuraContainer = container
    frame.gwIndicatorTrackers = {}
    RegisterGridAuraEvents(frame)

    -- the secure header re-targets the frame (raid1 -> raid2, ...): keep the
    -- containers on the same unit as the frame
    frame:HookScript("OnAttributeChanged", function(self, name, value)
        if name == "unit" and value and self.gwAuraContainer then
            if self.gwAuraContainer.gwAppliedUnit ~= value then
                self.gwAuraContainer.gwAppliedUnit = value
                self.gwAuraContainer:SetUnit(value)
            end
            for _, tracker in pairs(self.gwIndicatorTrackers) do
                if tracker.gwAppliedUnit ~= value then
                    tracker.gwAppliedUnit = value
                    tracker:SetUnit(value)
                end
            end
            -- the resource bar anchoring depends on the units role
            AnchorGridAuraContainer(self)
        end
    end)
end

local function CreateAuraIndicator(frame, pos)
    local config = INDICATOR_CONFIG[pos]
    if not config then return nil end

    local indicator = CreateFrame("Frame", nil, frame, "GwGridFrameAuraIndicator")

    indicator:SetPoint(config.point, frame, config.point, config.x, config.y)
    indicator.color = { r = 1, g = 1, b = 1 }
    indicator.cooldown:HookScript("OnCooldownDone", function()
        ClearIndicatorFrame(indicator)
    end)

    return indicator
end

local function Construct_Auras(frame)
    if GW.Retail then
        -- no oUF Auras element on retail (reading aura data from insecure code is
        -- blocked while values are secret) — frame.Auras stays nil, the display
        -- runs through the AuraContainer
        Construct_GridAuraContainers(frame)
        return nil
    end

    local auras = CreateFrame('Frame', '$parentAuras', frame)
    auras:SetSize(frame:GetSize())
    auras:SetFrameLevel(frame.RaisedElementParent.AuraLevel)

    -- init settings
    auras.initialAnchor = "BOTTOMRIGHT"
    auras.growthX = "LEFT"
    auras.spacingX = 1
    auras.spacingY = 1
    auras.disableCooldown = true
    auras.reanchorIfVisibleChanged = true

    auras.PostCreateButton = Construct_AuraIcon
    auras.PostUpdateButton = PostUpdateButton
    auras.FilterAura = FilterAura

    auras.PostUpdateInfoRemovedAuraID = PostUpdateInfoRemovedAuraID
    auras.PostProcessAuraData = PostProcessAuraData
    auras.PreUpdate = PreUpdateAuras

    auras.size = 14 -- dynamic

    frame:RegisterEvent("PLAYER_REGEN_DISABLED", HandleTooltip, true)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED", HandleTooltip, true)

    -- construct the aura indicators
    for _, pos in ipairs(INDICATORS) do
        if INDICATOR_CONFIG[pos] then
            auras["indicator" .. pos] = CreateAuraIndicator(frame, pos)
        end
    end

    local indicatorBar = CreateFrame("StatusBar", '$parentIndicatorBar', frame)
    indicatorBar:SetFrameLevel(20)
    indicatorBar:SetOrientation("VERTICAL")
    indicatorBar:SetMinMaxValues(0, 1)
    indicatorBar:SetSize(2, 2)
    indicatorBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 3, 0)
    indicatorBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, 0)
    indicatorBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    indicatorBar:SetStatusBarColor(1, 0.5, 0)
    indicatorBar.isIndicatorBar = true
    indicatorBar:Hide()

    indicatorBar.bg = indicatorBar:CreateTexture(nil, "BORDER")
    indicatorBar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    indicatorBar.bg:SetPoint("TOPLEFT", indicatorBar, "TOPLEFT", 0, 1)
    indicatorBar.bg:SetPoint("BOTTOMRIGHT", indicatorBar, "BOTTOMRIGHT", 1, -1)
    indicatorBar.bg:SetVertexColor(0, 0, 0, 1)
    auras.indicatorBAR = indicatorBar

    if C_CurveUtil then
        auras.dispelColorCurve = C_CurveUtil.CreateColorCurve()
        auras.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, GW.Enum.DispelType do
            if GW.Colors.DebuffColors[dispelIndex] then
                auras.dispelColorCurve:AddPoint(dispelIndex, GW.Colors.DebuffColors[dispelIndex])
            end
        end
    end

	return auras
end
GW.Construct_Auras = Construct_Auras

local function UpdateIndicatorSettings(frame)
    local indicatorSize = tonumber(frame.raidIndicatorSize) or 13
    local indicatorBarWidth = tonumber(frame.raidIndicatorBarWidth) or 2

    for _, pos in ipairs(INDICATORS) do
        if INDICATOR_CONFIG[pos] then
            local indicator = frame.Auras["indicator" .. pos]
            indicator:SetSize(indicatorSize, indicatorSize)
        end
    end

    frame.Auras.indicatorBAR:SetWidth(indicatorBarWidth)
end

local function UpdateAurasSettings(frame)
    if GW.Retail then
        UpdateGridAuraContainers(frame)
        return
    end

    frame.Auras:ClearAllPoints()
    frame.Auras:SetPoint('TOPLEFT', frame, 'TOPLEFT')
    if frame.showResscoureBar == "ALL" or frame.showResscoureBar == "HEALER" then
        frame.Auras:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 5)
    else
        frame.Auras:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
    end

    frame.Auras:SetSize(frame.unitWidth - 2, frame.unitHeight - 2)
    frame.Auras.forceShow = frame.forceShowAuras
    UpdateIndicatorSettings(frame)

    frame.Auras:ForceUpdate()
end
GW.UpdateAurasSettings = UpdateAurasSettings
