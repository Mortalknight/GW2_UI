---@class GW2
local GW = select(2, ...)
local L = GW.L

local moveable_window_placeholders_visible = true
local settings_window_open_before_change = false

local allTags, allTagsSet = {ALL}, {[ALL] = true}
local selectedTag = ALL
local grid

local SMALL_SETTINGS_COMPACT_WIDTH = 190
local SMALL_SETTINGS_EXPANDED_WIDTH = 370
local SMALL_SETTINGS_COMPACT_HEADER_WIDTH = 82
local SMALL_SETTINGS_EXPANDED_HEADER_WIDTH = 258
local SMALL_SETTINGS_ACTIVE_ALPHA = 1
local SMALL_SETTINGS_IDLE_ALPHA = 0.65

local function SetLayoutManagerMoveHudMode(layoutManager, inMoveHudMode, refresh)
    if not layoutManager then return end

    layoutManager:SetAttribute("inMoveHudMode", inMoveHudMode)

    if refresh then
        layoutManager:GetScript("OnEvent")(layoutManager)
    end
end

local function SetSmallSettingsHeader(text)
    local frame = GW.MoveHudScaleableFrame
    frame.headerBaseText = text
    frame.headerString:SetText(text .. (frame.layoutViewShown and (" & " .. L["Layouts"]) or ""))
end

local function SetSmallSettingsLayoutToggleDirection(frame)
    local button = frame.layoutToggle

    local rotation = frame.layoutViewShown and 1.57 or -1.57
    button.arrow:SetRotation(rotation)
    button.label:SetText(L["Layouts"])
    button.label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    button.arrow:SetVertexColor(GW.Colors.TextColors.LightHeader:GetRGB())
    button.bg:SetVertexColor(1, 1, 1, 0.6)
    button.hover:SetVertexColor(1, 1, 1, 0)
end

local function SetSmallSettingsLayoutViewShown(frame, show)
    frame.layoutViewShown = show
    frame:SetWidth(show and SMALL_SETTINGS_EXPANDED_WIDTH or SMALL_SETTINGS_COMPACT_WIDTH)
    frame.moverFrame:SetWidth(show and SMALL_SETTINGS_EXPANDED_WIDTH or SMALL_SETTINGS_COMPACT_WIDTH)
    frame.layoutView:SetShown(show)
    frame.seperator:SetShown(show)
    frame.headerString:SetWidth(show and SMALL_SETTINGS_EXPANDED_HEADER_WIDTH or SMALL_SETTINGS_COMPACT_HEADER_WIDTH)
    SetSmallSettingsLayoutToggleDirection(frame)

    SetSmallSettingsHeader(frame.headerBaseText or L["Extra Frame Options"])
end

local function SetSmallSettingsAlpha(frame, alpha, instant)
    if frame.targetAlpha == alpha and not instant then return end

    frame.targetAlpha = alpha
    UIFrameFadeRemoveFrame(frame)

    if instant then
        frame:SetAlpha(alpha)
    elseif alpha > frame:GetAlpha() then
        UIFrameFadeIn(frame, 0.12, frame:GetAlpha(), alpha)
    else
        UIFrameFadeOut(frame, 0.18, frame:GetAlpha(), alpha)
    end
end

local function SetSmallSettingsActive(self)
    SetSmallSettingsAlpha(self, SMALL_SETTINGS_ACTIVE_ALPHA)
end

local function SetSmallSettingsIdleIfMouseLeft(self)
    C_Timer.After(0.05, function()
        if self:IsShown() and not self:IsMouseOver() and not self.moverFrame:IsMouseOver() then
            SetSmallSettingsAlpha(self, SMALL_SETTINGS_IDLE_ALPHA)
        end
    end)
end

local function HookSmallSettingsMouseFade(frame, container)
    if frame.mouseFadeHooked then return end

    frame.mouseFadeHooked = true
    frame:HookScript("OnEnter", function()
        SetSmallSettingsActive(container)
    end)
    frame:HookScript("OnLeave", function()
        SetSmallSettingsIdleIfMouseLeft(container)
    end)

    for _, child in ipairs({frame:GetChildren()}) do
        HookSmallSettingsMouseFade(child, container)
    end
end

local function AddTagsCSV(tags)
    tags = tags or ""
    for _, v in pairs({strsplit(",", tags)}) do
        v = strtrim(v)
        if v ~= "" and not allTagsSet[v] then
            allTagsSet[v] = true
            tinsert(allTags, v)
            -- the filter dropdown has to pick the new tag up
            if GwSmallSettingsContainer and GwSmallSettingsContainer.moverSettingsFrame then
                local dd = GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown
                if dd then dd.needsRebuild = true end
            end
        end
    end
end

local function filterHudMovers(filter)
    selectedTag = filter
    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        local show = mf.enable
        if show and filter and filter ~= ALL and mf.tagsSet then
            show = mf.tagsSet[filter] == true
        end
        mf:SetShown(show)
    end
end

local function ClampEditBoxNumber(editBox, min, max, decimals)
    local value = GW.RoundDec(editBox:GetNumber(), decimals)
    value = math.max(min, math.min(max, value))
    editBox:SetText(value)
    editBox:ClearFocus()
    return value
end

-- Mover options ------------------------------------------------------------------------------------------------
-- A mover registers the options it wants in the "Move HUD" panel, like the blizzard edit mode: a list of tables,
-- each one a widget (GW.Enum.MoverOptionType) bound to a flat settings key with a label. `apply(mover, value,
-- userInput)` is called after the setting was written; `userInput` is false for the initial value and for a reset.
-- Presets in GW.MoverOption cover the common cases and take their key from the movers own setting name.
local MoverOptionType = GW.Enum.MoverOptionType
local GRID_MIN, GRID_MAX = 20, 300

local MoverOption = {
    Scale = {
        type = MoverOptionType.Slider,
        settingSuffix = "_scale",
        label = L["Scale"],
        min = 0.1, max = 2, decimals = 2,
        isScale = true,
        applyOnLoad = true,
        apply = function(mover, value, userInput)
            mover.parent:SetScale(value, true) -- the hook on SetScale takes the mover along
            if userInput then
                mover.parent.isMoved = true
                mover.parent:SetAttribute("isMoved", true)
            end
        end,
    },
    Height = {
        type = MoverOptionType.Slider,
        settingSuffix = "_height",
        label = COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT,
        min = 1, max = 1500, decimals = 0,
        applyOnLoad = true,
        apply = function(mover, value)
            mover:SetHeight(value)
            mover.parent:SetHeight(value)
        end,
    },
}
GW.MoverOption = setmetatable(MoverOption, {__index = function(_, key)
    error(("unknown mover option preset %q"):format(tostring(key)), 2)
end})

local OPTION_TEMPLATES = {
    [MoverOptionType.Slider] = "GwSmallSettingsSliderOption",
    [MoverOptionType.Checkbox] = "GwSmallSettingsCheckboxOption",
    [MoverOptionType.Dropdown] = "GwSmallSettingsDropdownOption",
}
local MIN_OPTIONS_HEIGHT = 90 -- room for two sliders, the panel does not shrink and grow with every mover
local DEFAULT_BUTTONS_HEIGHT = 110 -- filter, placeholder, grid and lock rows below the mover options

-- checks a registered option and fills in the settings key of a preset; the errors are meant for the developer
-- and point at the RegisterMovableFrame call of the module (level 4: Resolve -> Create -> Register -> module)
local function ResolveMoverOption(settingsName, option)
    local where = ("mover %s"):format(settingsName)
    if type(option) ~= "table" then
        error(where .. ": an option has to be a table", 4)
    end

    local resolved = {}
    for key, value in pairs(option) do
        resolved[key] = value
    end
    resolved.setting = option.setting or (option.settingSuffix and settingsName .. option.settingSuffix)

    if not OPTION_TEMPLATES[resolved.type] then
        error(where .. ": unknown option type " .. tostring(resolved.type), 4)
    end
    if type(resolved.setting) ~= "string" then
        error(where .. ": option without a settings key", 4)
    end
    if GW.globalDefault.profile[resolved.setting] == nil then
        error(("%s: option %q has no default"):format(where, resolved.setting), 4)
    end
    if not resolved.label then
        error(("%s: option %q has no label"):format(where, resolved.setting), 4)
    end
    if resolved.type == MoverOptionType.Slider and not (type(resolved.min) == "number" and type(resolved.max) == "number") then
        error(("%s: slider %q needs min and max"):format(where, resolved.setting), 4)
    end
    if resolved.type == MoverOptionType.Dropdown and type(resolved.optionsList) ~= "table" then
        error(("%s: dropdown %q needs an optionsList"):format(where, resolved.setting), 4)
    end

    return resolved
end

local function ApplyMoverOption(mover, option, value, userInput)
    GW.settings[option.setting] = value
    if option.apply then
        option.apply(mover, value, userInput)
    end
end

-- the widgets, one pool per type, created from the templates in smallSettingFrame.xml
local WIDGET_INIT, WIDGET_SETUP = {}, {}

WIDGET_INIT[MoverOptionType.Slider] = function(widget)
    widget.title:SetFont(UNIT_NAME_FONT, 12, "")
    widget.input:SetFont(UNIT_NAME_FONT, 8, "")
    GW.AddSliderValueFill(widget.slider)

    widget.slider:SetScript("OnValueChanged", function(_, value, userInput)
        local option = widget.option
        if not option then return end
        local rounded = GW.RoundDec(value, option.decimals or 0)
        widget.input:SetText(rounded)
        if userInput then
            ApplyMoverOption(widget.mover, option, rounded, true)
        end
    end)
    widget.input:SetScript("OnEnterPressed", function(input)
        local option = widget.option
        local value = ClampEditBoxNumber(input, option.min, option.max, option.decimals or 0)
        ApplyMoverOption(widget.mover, option, value, true)
        widget.slider:SetValue(value)
    end)
    widget.input:SetScript("OnEscapePressed", function(input) input:ClearFocus() end)
end
WIDGET_SETUP[MoverOptionType.Slider] = function(widget, option)
    widget.title:SetText(option.label)
    widget.slider:SetMinMaxValues(option.min, option.max)
    widget.slider:SetValueStep(option.step or 0) -- a pooled slider must not keep the step of its last option
    widget.slider:SetObeyStepOnDrag(option.step ~= nil)
    local value = GW.settings[option.setting]
    widget.slider:SetValue(value)
    widget.input:SetText(GW.RoundDec(value, option.decimals or 0))
end

WIDGET_INIT[MoverOptionType.Checkbox] = function(widget)
    widget.title:SetFont(UNIT_NAME_FONT, 12, "")
    widget.checkbox:GwSkinCheckButton(false, 15)
    widget.checkbox:SetScript("OnClick", function(checkbox)
        ApplyMoverOption(widget.mover, widget.option, checkbox:GetChecked() and true or false, true)
    end)
end
WIDGET_SETUP[MoverOptionType.Checkbox] = function(widget, option)
    widget.title:SetText(option.label)
    widget.checkbox:SetChecked(GW.settings[option.setting] and true or false)
end

WIDGET_INIT[MoverOptionType.Dropdown] = function(widget)
    widget.title:SetFont(UNIT_NAME_FONT, 12, "")
    widget.dropdown:GwHandleDropDownBox(nil, nil, nil, 150)
    widget.dropdown:SetupMenu(function(_, rootDescription)
        local option, mover = widget.option, widget.mover
        if not option then return end

        for index, value in ipairs(option.optionsList) do
            local function IsSelected(entry) return GW.settings[option.setting] == entry end
            local function SetSelected(entry) ApplyMoverOption(mover, option, entry, true) end

            local name = option.optionNames and option.optionNames[index] or tostring(value)
            local radio = rootDescription:CreateRadio(name, IsSelected, SetSelected, value)
            radio:AddInitializer(function(button, description, menu)
                GW.BlizzardDropdownRadioButtonInitializer(button, description, menu, IsSelected, value)
            end)
        end
    end)
end
WIDGET_SETUP[MoverOptionType.Dropdown] = function(widget, option)
    widget.title:SetText(option.label)
    widget.dropdown:GenerateMenu() -- refreshes the shown selection
end

local widgetPools = {}

local function AcquireOptionWidget(parent, optionType)
    local pool = widgetPools[optionType]
    if not pool then
        pool = {free = {}, active = {}}
        widgetPools[optionType] = pool
    end

    local widget = tremove(pool.free)
    if not widget then
        widget = CreateFrame("Frame", nil, parent, OPTION_TEMPLATES[optionType])
        WIDGET_INIT[optionType](widget)
        HookSmallSettingsMouseFade(widget, GW.MoveHudScaleableFrame) -- keeps the panel awake while its controls are hovered
    end
    pool.active[#pool.active + 1] = widget
    widget:Show()

    return widget
end

local function ReleaseOptionWidgets()
    for _, pool in pairs(widgetPools) do
        for i = #pool.active, 1, -1 do
            local widget = pool.active[i]
            widget:Hide()
            widget:ClearAllPoints()
            widget.mover, widget.option = nil, nil
            pool.free[#pool.free + 1] = widget
            pool.active[i] = nil
        end
    end
end

-- the fixed rows (nudge, center, reset) follow below the options; options frame and panel grow with them
local function LayoutMoverOptions(optionsHeight)
    local frame = GW.MoveHudScaleableFrame
    local options = frame.moverSettingsFrame.options

    options.movers:ClearAllPoints()
    options.movers:SetPoint("TOPLEFT", options, "TOPLEFT", 0, -(optionsHeight + 10))

    local total = optionsHeight + 10 + options.movers:GetHeight() + 4 + options.align:GetHeight() + 5 + options.default:GetHeight()
    options:SetHeight(total)
    frame:SetHeight(total + DEFAULT_BUTTONS_HEIGHT)
    frame.seperator:SetHeight(frame:GetHeight())
end

local function BuildMoverOptions(mover)
    local options = GW.MoveHudScaleableFrame.moverSettingsFrame.options
    ReleaseOptionWidgets()

    local y = 5
    for _, option in ipairs(mover.options) do
        local widget = AcquireOptionWidget(options, option.type)
        widget.mover, widget.option = mover, option
        widget:SetPoint("TOPLEFT", options, "TOPLEFT", 0, -y)
        WIDGET_SETUP[option.type](widget, option)
        y = y + widget:GetHeight() + 5
    end

    LayoutMoverOptions(math.max(y, MIN_OPTIONS_HEIGHT + 5))
end

local function Acquire(frame, pool)
    local tx = pool[#pool]
    if tx then
        pool[#pool] = nil
        tx:Show()
        return tx
    end
    tx = frame:CreateTexture(nil, "BACKGROUND")
    return tx
end

local function CreateGrid()
    if not grid then
        grid = CreateFrame("Frame", "GW2_UIIGrid", UIParent)
        grid:SetFrameStrata("BACKGROUND")
        grid.vPool, grid.hPool, grid.activeV, grid.activeH = {}, {}, {}, {}
    end

    local width, height = UIParent:GetSize()
    local size = math.max(GW.mult * 0.5, 0.5)  -- Min 0.5 pixel
    local gSize = GW.settings.gridSpacing
    local step = math.max(2, math.min(width, height) / gSize)
    local halfW, halfH = width * 0.5, height * 0.5

    grid.boxSize = gSize
    grid:SetPoint("CENTER", UIParent)
    grid:SetSize(width, height)
    grid:Show()

    for _, t in ipairs(grid.activeV) do t:Hide(); grid.vPool[#grid.vPool + 1] = t end
    for _, t in ipairs(grid.activeH) do t:Hide(); grid.hPool[#grid.hPool + 1] = t end
    wipe(grid.activeV)
    wipe(grid.activeH)

    -- Vertical lines
    local cols = math.floor(width / step / 2)
    for i = -cols, cols do
        local x = i * step
        local tx = Acquire(grid, grid.vPool)
        local isCenter = (i == 0)
        tx:SetColorTexture(isCenter and 1 or 0, 0, 0, 1)
        tx:SetDrawLayer("BACKGROUND", isCenter and 1 or 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOP", grid, "CENTER", x, halfH)
        tx:SetPoint("BOTTOM", grid, "CENTER", x, -halfH)
        tx:SetWidth(size)
        grid.activeV[#grid.activeV+1] = tx
    end

    -- horizontal lines
    local rows = math.floor(height / step / 2)
    for i = -rows, rows do
        local y = i * step
        local tx = Acquire(grid, grid.hPool)
        local isCenter = (i == 0)
        tx:SetColorTexture(isCenter and 1 or 0, 0, 0, 1)
        tx:SetDrawLayer("BACKGROUND", isCenter and 1 or 0)
        tx:ClearAllPoints()
        tx:SetPoint("LEFT", grid, "CENTER", -halfW, y)
        tx:SetPoint("RIGHT", grid, "CENTER", halfW, y)
        tx:SetHeight(size)
        grid.activeH[#grid.activeH+1] = tx
    end
end

local function ShowGrid()
    if not grid then
        CreateGrid()
    elseif grid.boxSize ~= GW.settings.gridSpacing then
        grid:Hide()
        CreateGrid()
    else
        grid:Show()
    end
end

local function HideGrid()
    if grid then
        grid:Hide()
    end
end

-- the grid is a plain frame of ours, it can be hidden in combat as well
local function SetGridShown(show)
    local buttons = GwSmallSettingsContainer.moverSettingsFrame.defaultButtons
    if show then
        ShowGrid()
    else
        HideGrid()
    end
    buttons.gridSlider:SetShown(show)
    buttons.showGrid:SetText(show and L["Hide grid"] or L["Show grid"])
end

local function GridToggle()
    SetGridShown(not (grid and grid:IsShown()))
end
GW.GridToggle = GridToggle

local function ClearSelectedMover(settingsFrame)
    if settingsFrame.childMover then
        GW.StopFlash(settingsFrame.childMover)
        settingsFrame.childMover:SetAlpha(1)
    end
    settingsFrame.childMover = nil
end

local function hideExtraOptions()
    ClearSelectedMover(GW.MoveHudScaleableFrame.moverSettingsFrame)
    ReleaseOptionWidgets()
    SetSmallSettingsHeader(L["Extra Frame Options"])
    GW.MoveHudScaleableFrame.moverSettingsFrame.options:Hide()
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:SetText(L["Left click on a moverframe to show extra frame options"])
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:Show()
end

local function lockHudObjects(_, _, inCombatLockdown)
    local moveHudFrame = GW.MoveHudScaleableFrame
    if not moveHudFrame then return end

    GW.InMoveHudMode = false
    moveHudFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    moveHudFrame:Hide()
    ClearSelectedMover(moveHudFrame.moverSettingsFrame)

    if settings_window_open_before_change and not inCombatLockdown then
        settings_window_open_before_change = false
        GwSettingsWindow:Show()
    end

    if not moveable_window_placeholders_visible then
        GW.toggleHudPlaceholders()
    end
    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(false)
        mf:SetMovable(false)
        mf:Hide()
    end

    SetGridShown(false)

    -- enable main bar layout manager and trigger the changes
    SetLayoutManagerMoveHudMode(moveHudFrame.layoutManager, false, true)
end
GW.lockHudObjects = lockHudObjects


local function toggleHudPlaceholders()
    local show = not moveable_window_placeholders_visible

    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        if mf.backdrop then
            if show then mf.backdrop:Show() else mf.backdrop:Hide() end
        end
    end
    local btn = GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.hidePlaceholder
    btn:SetText(show and L["Hide placeholders"] or L["Show placeholders"])

    moveable_window_placeholders_visible = show
end
GW.toggleHudPlaceholders = toggleHudPlaceholders

local function moveHudObjects(self)
    GW.InMoveHudMode = true

    if GwSettingsWindow:IsShown() or settings_window_open_before_change then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(true)
        mf:SetMovable(true)
    end
    filterHudMovers(selectedTag)
    hideExtraOptions()
    SetSmallSettingsLayoutViewShown(GW.MoveHudScaleableFrame, false)
    GW.MoveHudScaleableFrame:Show()

    -- disable main bar layout manager
    SetLayoutManagerMoveHudMode(GW.MoveHudScaleableFrame.layoutManager, true)

    -- register event to close move hud in combat
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
end
GW.moveHudObjects = moveHudObjects

local function HandleMoveHudEvents(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        GW.Notice(L["You cannot move elements during combat!"])
        self:UnregisterEvent(event)
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        lockHudObjects(self, nil, true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event)
        moveHudObjects(self)
    end
end

-- mirrors the selected movers anchor offsets into the X/Y inputs
local function UpdateMoverPositionInputs(mover)
    local options = GW.MoveHudScaleableFrame.moverSettingsFrame.options
    if not options.position or options.position.gwUpdating then return end

    local _, _, _, x, y = mover:GetPoint()
    options.position.gwUpdating = true
    options.position.inputX:SetText(GW.RoundDec(x or 0, 1))
    options.position.inputY:SetText(GW.RoundDec(y or 0, 1))
    options.position.gwUpdating = false
end

local function smallSettings_resetToDefault(self, _,  moverFrame)
    local mf = moverFrame or GW.MoveHudScaleableFrame.moverSettingsFrame.childMover

    mf:ClearAllPoints()
    mf:SetPoint(
        mf.defaultPoint.point,
        UIParent,
        mf.defaultPoint.relativePoint,
        mf.defaultPoint.xOfs,
        mf.defaultPoint.yOfs
    )

    local new_point = GW.settings[mf.setting]
    new_point.point = mf.defaultPoint.point
    new_point.relativePoint = mf.defaultPoint.relativePoint
    new_point.xOfs = mf.defaultPoint.xOfs
    new_point.yOfs = mf.defaultPoint.yOfs
    new_point.hasMoved = false
    GW.settings[mf.setting] = new_point

    mf.savedPoint = GW.CopyTable(new_point)
    mf.parent.isMoved = false
    mf.parent:SetAttribute("isMoved", new_point.hasMoved)

    --if "PlayerBuffFrame" or "PlayerDebuffFrame", set also the grow direction, h,v spacing, auras per row and max wraps to default
    if mf.setting == "PlayerBuffFrame" or mf.setting == "PlayerDebuffFrame" then
        -- reset also the settings frame values
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".Seperate", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".SortDir", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".SortMethod", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".IconSize", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".IconHeight", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".KeepSizeRatio", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".GrowDirection", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".HorizontalSpacing", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".VerticalSpacing", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".MaxWraps", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".WrapAfter", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".NewAuraAnimation", nil, nil, true)
        GW.UpdateAuraHeader(mf.parent)
    elseif mf.setting == "MicromenuPos" then
        -- bar art and button offset follow the (default) position
        if GW.UpdateMicroBarOrientation then
            GW.UpdateMicroBarOrientation()
            GW.LayoutMicroButtons()
        end
    end

    -- every option back to its default; main hud frames scale with the hud instead of their own default
    for _, option in ipairs(mf.options) do
        local default = GW.globalDefault.profile[option.setting]
        if option.isScale and mf.mainHudFrame then
            default = GW.settings.HUD_SCALE
        end
        ApplyMoverOption(mf, option, default, false)
    end

    if mf.postdrag then
        mf.postdrag(mf.parent)
    end
    if GW.MoveHudScaleableFrame.moverSettingsFrame.childMover == mf then
        UpdateMoverPositionInputs(mf)
        BuildMoverOptions(mf)
    end

    GW.UpdateHudScale()

    --also update the selected layout
    GW.UpdateMatchingLayout(mf, new_point)

    -- run layout manager
    SetLayoutManagerMoveHudMode(GwSmallSettingsContainer.layoutManager, false, true)
    SetLayoutManagerMoveHudMode(GwSmallSettingsContainer.layoutManager, true)
end
GW.ResetMoverFrameToDefaultValues = smallSettings_resetToDefault


local function mover_OnDragStart(self)
    self.IsMoving = true
    self:StartMoving()
end


local function CheckForDefaultPosition(frame, point, relativePoint, xOfs, yOfs, newPoint)
    if frame.defaultPoint.point == point and frame.defaultPoint.relativePoint == relativePoint and frame.defaultPoint.xOfs == xOfs and frame.defaultPoint.yOfs == yOfs then
        newPoint.hasMoved = false
    else
        newPoint.hasMoved = true
    end

    frame.parent.isMoved = newPoint.hasMoved
    frame.parent:SetAttribute("isMoved", newPoint.hasMoved)

    GW.settings[frame.setting] = newPoint
end

-- Snaps the mover EDGES onto the grid: per axis the edge that is already closest
-- to a line wins. The grid draws its lines in step distances from the screen
-- center; everything is measured in the movers coordinate space, so differing
-- frame scales cannot skew the result
local function SnapToGrid(self, xOfs, yOfs)
    local toMoverSpace = UIParent:GetEffectiveScale() / self:GetEffectiveScale()
    local width, height = UIParent:GetSize()
    local step = math.max(2, math.min(width, height) / GW.settings.gridSpacing) * toMoverSpace
    local screenX, screenY = UIParent:GetCenter()
    screenX, screenY = screenX * toMoverSpace, screenY * toMoverSpace

    local function EdgeDelta(coord, center)
        local snapped = center + GW.RoundInt((coord - center) / step) * step
        return snapped - coord
    end

    local deltaLeft = EdgeDelta(self:GetLeft(), screenX)
    local deltaRight = EdgeDelta(self:GetRight(), screenX)
    local deltaTop = EdgeDelta(self:GetTop(), screenY)
    local deltaBottom = EdgeDelta(self:GetBottom(), screenY)

    local deltaX = math.abs(deltaLeft) <= math.abs(deltaRight) and deltaLeft or deltaRight
    local deltaY = math.abs(deltaTop) <= math.abs(deltaBottom) and deltaTop or deltaBottom
    return xOfs + deltaX, yOfs + deltaY
end

local function mover_OnDragStop(self)
    local settingsName = self.setting
    local wasDragged = self.IsMoving
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    -- only real drags snap while the grid is shown - pixel nudges, the X/Y inputs
    -- and the centering buttons stay exact
    if wasDragged and grid and grid:IsShown() and xOfs and yOfs then
        xOfs, yOfs = SnapToGrid(self, xOfs, yOfs)
    end

    xOfs = xOfs and GW.RoundInt(xOfs) or 0
    yOfs = yOfs and GW.RoundInt(yOfs) or 0

    -- for layouts: if newPoint is old point, do not update the setting
    if self.savedPoint.point ~= point or self.savedPoint.relativePoint ~= relativePoint or self.savedPoint.xOfs ~= xOfs or self.savedPoint.yOfs ~= yOfs then
        local new_point = GW.settings[settingsName]
        new_point.point = point
        new_point.relativePoint = relativePoint
        new_point.xOfs = xOfs
        new_point.yOfs = yOfs

        -- check if frame moved or back at default position
        CheckForDefaultPosition(self, point, relativePoint, xOfs, yOfs, new_point)

        self:ClearAllPoints()
        self:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        self.savedPoint = GW.CopyTable(new_point)

        self:SetMovable(true)
        self:SetUserPlaced(true)

        --also update the selected layout
        GW.UpdateMatchingLayout(self, new_point)
    end

    if self.postdrag then
        self.postdrag(self.parent)
    end
    self.IsMoving = false

    if GW.MoveHudScaleableFrame.moverSettingsFrame.childMover == self then
        UpdateMoverPositionInputs(self)
    end
end

local function showExtraOptions(self)
    local previous = GW.MoveHudScaleableFrame.moverSettingsFrame.childMover
    if previous and previous ~= self then
        GW.StopFlash(previous)
        UIFrameFadeOut(previous, 0.5, previous:GetAlpha(), 0.5)
    end
    GW.MoveHudScaleableFrame.moverSettingsFrame.childMover = self
    SetSmallSettingsHeader(self.textString)
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:Hide()
    GW.MoveHudScaleableFrame.moverSettingsFrame.options:Show()
    UpdateMoverPositionInputs(self)
    BuildMoverOptions(self)

    GW.FrameFlash(self, 1.5, 0.5, 1, true)
end

local function mover_options(self)
    if GW.MoveHudScaleableFrame.moverSettingsFrame.childMover == self then
        hideExtraOptions()
    else
        showExtraOptions(self)
    end
end

local function moverframe_OnEnter(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in ipairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeOut(moverframe, 0.5, moverframe:GetAlpha(), 0.5)
        end
    end
end

local function moverframe_OnLeave(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in ipairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeIn(moverframe, 0.5, moverframe:GetAlpha(), 1)
        end
    end
end

local function ParentOnSizeChanged(self, width, height)
    if self.gwMover.ignoreSize == true then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue(self.gwMover:GetName() .. "Size", ParentOnSizeChanged, {self, width, height})
        return
    end
    self.gwMover:SetSize(width, height)
end

local function ParentOnHeightChanged(self, height)
    if self.gwMover.ignoreSize == true then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue(self.gwMover:GetName() .. "Height", ParentOnHeightChanged, {self, height})
        return
    end
    self.gwMover:SetHeight(height)
end

local function ParentOnWidthChanged(self, width)
    if self.gwMover.ignoreSize == true then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue(self.gwMover:GetName() .. "Width", ParentOnWidthChanged, {self, width})
        return
    end
    self.gwMover:SetWidth(width)
end

local function ParentOnScaleChanged(self, scale, override)
    if not override and self.gwMover.ignoreSize == true then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue(self.gwMover:GetName() .. "Scale", ParentOnScaleChanged, {self, scale})
        return
    end
    self.gwMover:SetScale(scale)
end

local function CreateMoverFrame(parent, displayName, settingsName, size, options, mhf, postdrag, tags, ignoreParentSize)
    local mf = CreateFrame("Button", "Gw_" .. settingsName, UIParent, "SecureHandlerStateTemplate")
    mf:SetClampedToScreen(true)
    mf:SetMovable(true)
    mf:EnableMouseWheel(true)
    mf:RegisterForDrag("LeftButton", "RightButton")
    mf:SetFrameLevel(parent:GetFrameLevel() + 1)
    mf:SetFrameStrata("DIALOG")
    mf:GwCreateBackdrop("Transparent White")
    mf:SetScale(parent:GetScale())
    mf.ignoreSize = ignoreParentSize
    parent.gwMover = mf

    if size then
        mf.ignoreSize = true
        mf:SetSize(unpack(size))
    else
        mf:SetSize(parent:GetSize())
    end
    hooksecurefunc(parent, "SetScale", ParentOnScaleChanged)
    hooksecurefunc(parent, "SetHeight", ParentOnHeightChanged)
    hooksecurefunc(parent, "SetWidth", ParentOnWidthChanged)
    hooksecurefunc(parent, "SetSize", ParentOnSizeChanged)

    mf:Hide()

    local fs = mf:CreateFontString(nil, "OVERLAY")
    fs:SetFont(UNIT_NAME_FONT, 12, "")
    fs:SetPoint("CENTER")
    fs:SetText(displayName)
    fs:SetJustifyH("CENTER")
    fs:SetTextColor(1, 1, 1)
    mf:SetFontString(fs)

    mf.text = fs
    mf.parent = parent
    mf.postdrag = postdrag
    mf.textString = displayName
    mf.setting = settingsName
    mf.mainHudFrame = mhf
    mf.savedPoint = GW.settings[settingsName]
    mf.defaultPoint = GW.globalDefault.profile[settingsName]
    mf.tags = tags or ""
    mf.tagsSet = {}
    for _, v in pairs({strsplit(",", mf.tags)}) do
        v = strtrim(v)
        if v ~= "" then
            mf.tagsSet[v] = true
        end
    end
    AddTagsCSV(mf.tags)

    mf.options = {}
    for _, option in ipairs(options or {}) do
        local resolved = ResolveMoverOption(settingsName, option)
        mf.options[#mf.options + 1] = resolved
        if resolved.isScale then
            GW.scaleableFrames[#GW.scaleableFrames + 1] = mf
        end
        if resolved.applyOnLoad then
            resolved.apply(mf, GW.settings[resolved.setting], false)
        end
    end

    mf:SetScript("OnDragStart", mover_OnDragStart)
    mf:SetScript("OnDragStop", mover_OnDragStop)
    mf:SetScript("OnEnter", moverframe_OnEnter)
    mf:SetScript("OnLeave", moverframe_OnLeave)
    mf:SetScript("OnClick", mover_options)

    if mhf then
        GW.scaleableMainHudFrames[#GW.scaleableMainHudFrames + 1] = mf
    end

    if postdrag then
        mf:RegisterEvent("PLAYER_ENTERING_WORLD")
        mf:SetScript("OnEvent", function(self)
            postdrag(self.parent)
            self:UnregisterAllEvents()
        end)
    end

    mf.enable = true

    GW.MOVABLE_FRAMES[#GW.MOVABLE_FRAMES + 1] = mf

    return mf
end

local function RegisterMovableFrame(frame, displayName, settingsName, tags, size, options, mhf, postdrag, ignoreParentSize)
    local moveframe = CreateMoverFrame(frame, displayName, settingsName, size, options, mhf, postdrag, tags, ignoreParentSize)

    moveframe:ClearAllPoints()
    if not moveframe.savedPoint.point or not moveframe.savedPoint.relativePoint or not moveframe.savedPoint.xOfs or not moveframe.savedPoint.yOfs then
        -- use default position
        moveframe:SetPoint(moveframe.defaultPoint.point, UIParent, moveframe.defaultPoint.relativePoint, moveframe.defaultPoint.xOfs, moveframe.defaultPoint.yOfs)
        moveframe.savedPoint = GW.CopyTable(moveframe.defaultPoint)
    else
        moveframe:SetPoint(moveframe.savedPoint.point, UIParent, moveframe.savedPoint.relativePoint, moveframe.savedPoint.xOfs, moveframe.savedPoint.yOfs)
    end

    if moveframe.savedPoint.hasMoved ~= nil then
        frame.isMoved = moveframe.savedPoint.hasMoved
        frame:SetAttribute("isMoved", moveframe.savedPoint.hasMoved)
    end

    -- check if frame moved or back at default position
    CheckForDefaultPosition(moveframe, moveframe.savedPoint.point, moveframe.savedPoint.relativePoint, moveframe.savedPoint.xOfs, moveframe.savedPoint.yOfs, moveframe.savedPoint)
end
GW.RegisterMovableFrame = RegisterMovableFrame

-- A profile switch without a reload (the dual spec switch) hands the movers a new settings table, but they still
-- carry the positions of the old profile and the frames stay where they were. This puts every mover back onto
-- the position its setting asks for; the values then match the setting again, so the drag handler only lets the
-- real frames follow and writes nothing back.
local function ApplyMoverPositionsFromSettings()
    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwApplyMoverPositions", ApplyMoverPositionsFromSettings)
        return
    end

    GW.IsApplyingMoverPositions = true

    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        local saved = GW.settings[mf.setting]
        -- a setting without a usable position says nothing about where the frame belongs, so it stays put
        if saved and saved.point and saved.relativePoint and saved.xOfs and saved.yOfs then
            mf.savedPoint = GW.CopyTable(saved)

            mf:ClearAllPoints()
            mf:SetPoint(mf.savedPoint.point, UIParent, mf.savedPoint.relativePoint, mf.savedPoint.xOfs, mf.savedPoint.yOfs)

            -- sets hasMoved on the frame and hands the point table back to the settings
            CheckForDefaultPosition(mf, mf.savedPoint.point, mf.savedPoint.relativePoint, mf.savedPoint.xOfs, mf.savedPoint.yOfs, mf.savedPoint)

            mover_OnDragStop(mf)
        end
    end

    GW.IsApplyingMoverPositions = nil
end
GW.ApplyMoverPositionsFromSettings = ApplyMoverPositionsFromSettings

local function MoveFrameByPixel(nudgeX, nudgeY)
    local mover = GwSmallSettingsContainer.moverSettingsFrame.childMover

    local point, _, anchorPoint, x, y = mover:GetPoint()
    x = x + nudgeX
    y = y + nudgeY
    mover:ClearAllPoints()
    mover:SetPoint(point, UIParent, anchorPoint, x, y)

    mover_OnDragStop(mover)
end

local function ToggleMover(frame, toggle)
    for _, moveableFrame in ipairs(GW.MOVABLE_FRAMES) do
        if moveableFrame == frame then
            moveableFrame.enable = toggle
            break
        end
    end
end
GW.ToggleMover = ToggleMover

local function LoadMovers(layoutManager)
    -- Create mover settings frame
    local fnMf_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnMf_OnDragStop = function(self)
        self:StopMovingOrSizing()
    end
    local mf = CreateFrame("Frame", "GwSmallSettingsMoverFrame", UIParent, "GwSmallSettingsMoverFrame")
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", fnMf_OnDragStart)
    mf:SetScript("OnDragStop", fnMf_OnDragStop)

    local smallSettingsContainer = CreateFrame("Frame", "GwSmallSettingsContainer", UIParent, "GwSmallSettingsContainer")
    smallSettingsContainer.moverSettingsFrame = CreateFrame("Frame", "GwSmallSettingsWindow", smallSettingsContainer, "GwSmallSettings")
    GW.MoveHudScaleableFrame = smallSettingsContainer
    smallSettingsContainer.layoutManager = layoutManager
    smallSettingsContainer.moverFrame = mf
    smallSettingsContainer:Hide()

    tinsert(UISpecialFrames, "GwSmallSettingsContainer")

    --set correct separator rotation
    local angle = math.rad(90)
    local cos, sin = math.cos(angle), math.sin(angle)
    smallSettingsContainer.seperator:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)

    smallSettingsContainer.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    smallSettingsContainer.headerString:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    SetSmallSettingsHeader(L["Extra Frame Options"])

    if smallSettingsContainer.layoutToggle then
        smallSettingsContainer.layoutToggle:SetScript("OnEnter", function(self)
            self.label:SetTextColor(1, 1, 1)
            self.arrow:SetVertexColor(1, 1, 1)
            self.bg:SetVertexColor(1, 1, 1, 0.4)
            self.hover:SetVertexColor(1, 1, 1, 0.48)

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetText(L["Configure layouts"], 1, 1, 1)
            GameTooltip:AddLine(L["Save, rename, delete, and assign HUD layouts to specializations."], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        smallSettingsContainer.layoutToggle:SetScript("OnLeave", function(self)
            GameTooltip_Hide(self)
            SetSmallSettingsLayoutToggleDirection(self:GetParent())
        end)
        smallSettingsContainer.layoutToggle:SetScript("OnClick", function(self)
            local container = self:GetParent()
            SetSmallSettingsLayoutViewShown(container, not container.layoutViewShown)
        end)
    end

    smallSettingsContainer.moverSettingsFrame.desc:SetText(L["Left click on a moverframe to show extra frame options"])
    smallSettingsContainer.moverSettingsFrame.desc:SetFont(UNIT_NAME_FONT, 12, "")
    smallSettingsContainer.moverSettingsFrame.desc:SetTextColor(181 / 255, 160 / 255, 128 / 255)

    smallSettingsContainer.moverSettingsFrame.options.movers.title:SetText(NPE_MOVE )
    smallSettingsContainer.moverSettingsFrame.options.movers.title:SetFont(UNIT_NAME_FONT, 12, "")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.left, "left")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.right, "right")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.up, "up")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.down, "down")
    -- shift click nudges by 10 pixels instead of 1
    local function NudgeStep()
        return IsShiftKeyDown() and 10 or 1
    end
    local moverButtons = smallSettingsContainer.moverSettingsFrame.options.movers
    moverButtons.left:SetScript("OnClick", function() MoveFrameByPixel(-NudgeStep(), 0) end)
    moverButtons.right:SetScript("OnClick", function() MoveFrameByPixel(NudgeStep(), 0) end)
    moverButtons.up:SetScript("OnClick", function() MoveFrameByPixel(0, NudgeStep()) end)
    moverButtons.down:SetScript("OnClick", function() MoveFrameByPixel(0, -NudgeStep()) end)
    for _, arrow in next, { moverButtons.left, moverButtons.right, moverButtons.up, moverButtons.down } do
        arrow:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(NPE_MOVE, 1, 1, 1)
            GameTooltip:AddLine(L["Hold Shift to move in steps of 10"], 0.9, 0.85, 0.7, true)
            GameTooltip:Show()
        end)
        arrow:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- Exact positioning: the anchor offsets of the selected mover, editable. The
    -- inputs share the line with the "move" title, so they cost no extra height
    local options = smallSettingsContainer.moverSettingsFrame.options
    local position = CreateFrame("Frame", nil, moverButtons)
    position:SetPoint("TOPRIGHT", moverButtons, "TOPRIGHT", 0, 8)
    position:SetSize(110, 16)
    options.position = position
    moverButtons.title:SetWidth(58)
    moverButtons.title:SetWordWrap(false)

    local function CreatePositionInput(label, offsetX)
        local text = position:CreateFontString(nil, "OVERLAY")
        text:SetFont(UNIT_NAME_FONT, 10, "")
        text:SetTextColor(1, 1, 1)
        text:SetPoint("LEFT", position, "LEFT", offsetX, 0)
        text:SetText(label)

        local input = CreateFrame("EditBox", nil, position)
        input:SetSize(38, 14)
        input:SetAutoFocus(false)
        input:SetFont(UNIT_NAME_FONT, 9, "")
        input:SetTextColor(1, 1, 1)
        input:SetJustifyH("CENTER")
        input:SetPoint("LEFT", text, "RIGHT", 4, 0)

        local bg = input:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")
        bg:SetTexCoord(0, 0.2, 0, 1)
        bg:SetPoint("TOPLEFT", -3, 1)
        bg:SetPoint("BOTTOMRIGHT", 3, -1)

        input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        return input
    end

    position.inputX = CreatePositionInput("X", 0)
    position.inputY = CreatePositionInput("Y", 56)

    local function ApplyPositionInputs()
        local mover = smallSettingsContainer.moverSettingsFrame.childMover
        local x = tonumber(position.inputX:GetText())
        local y = tonumber(position.inputY:GetText())
        if not mover or not x or not y then return end

        local point, _, anchorPoint = mover:GetPoint()
        mover:ClearAllPoints()
        mover:SetPoint(point, UIParent, anchorPoint, x, y)
        mover_OnDragStop(mover) -- rounds the offsets and writes them back into the inputs

        position.inputX:ClearFocus()
        position.inputY:ClearFocus()
    end
    position.inputX:SetScript("OnEnterPressed", ApplyPositionInputs)
    position.inputY:SetScript("OnEnterPressed", ApplyPositionInputs)

    -- centering shortcuts: nudge by the distance between the mover and screen center. GetCenter answers in
    -- the movers own coordinate space, so the screen center is scaled into it as well
    local function ScreenCenterInMoverSpace(mover)
        local toMoverSpace = UIParent:GetEffectiveScale() / mover:GetEffectiveScale()
        local centerX, centerY = UIParent:GetCenter()
        return centerX * toMoverSpace, centerY * toMoverSpace
    end

    local align = CreateFrame("Frame", nil, options)
    align:SetSize(170, 20)
    align:SetPoint("TOPLEFT", options.movers, "BOTTOMLEFT", 0, -4)
    options.align = align

    local centerX = CreateFrame("Button", nil, align, "GwStandardButton")
    centerX:SetSize(82, 18)
    centerX:SetPoint("LEFT", align, "LEFT", 0, 0)
    centerX:SetText(L["Center"] .. " X")
    centerX:SetScript("OnClick", function()
        local mover = smallSettingsContainer.moverSettingsFrame.childMover
        if not mover then return end
        local moverCenter = mover:GetCenter()
        local screenCenter = ScreenCenterInMoverSpace(mover)
        MoveFrameByPixel(screenCenter - moverCenter, 0)
    end)

    local centerY = CreateFrame("Button", nil, align, "GwStandardButton")
    centerY:SetSize(82, 18)
    centerY:SetPoint("LEFT", centerX, "RIGHT", 6, 0)
    centerY:SetText(L["Center"] .. " Y")
    centerY:SetScript("OnClick", function()
        local mover = smallSettingsContainer.moverSettingsFrame.childMover
        if not mover then return end
        local _, moverCenter = mover:GetCenter()
        local _, screenCenter = ScreenCenterInMoverSpace(mover)
        MoveFrameByPixel(0, screenCenter - moverCenter)
    end)

    options.default:ClearAllPoints()
    options.default:SetPoint("TOPLEFT", align, "BOTTOMLEFT", 0, -5)
    LayoutMoverOptions(MIN_OPTIONS_HEIGHT + 5)

    smallSettingsContainer:SetScript("OnShow", function()
        mf:Show()
        SetSmallSettingsAlpha(smallSettingsContainer, SMALL_SETTINGS_IDLE_ALPHA, true)
    end)
    smallSettingsContainer:SetScript("OnHide", function()
        SetSmallSettingsAlpha(smallSettingsContainer, SMALL_SETTINGS_ACTIVE_ALPHA, true)
        if GW.InMoveHudMode then
            lockHudObjects()
        end
        mf:Hide()
    end)
    smallSettingsContainer:SetScript("OnEvent", HandleMoveHudEvents)

    smallSettingsContainer.moverSettingsFrame.options.default:SetScript("OnClick", smallSettings_resetToDefault)
    smallSettingsContainer.moverSettingsFrame.options.default:GwSkinNegativeButton()

    -- lock, placeholder and grid button
    local lockHudButton = smallSettingsContainer.moverSettingsFrame.defaultButtons.lockHud
    lockHudButton:SetScript("OnClick", lockHudObjects)
    lockHudButton:SetText(L["Lock HUD"])
    lockHudButton:GwSkinNegativeButton()

    smallSettingsContainer.moverSettingsFrame.defaultButtons.hidePlaceholder:SetScript("OnClick", toggleHudPlaceholders)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.hidePlaceholder:SetText(L["Hide placeholders"])

    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetScript("OnClick", GridToggle)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetText(L["Show grid"])

    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetMinMaxValues(GRID_MIN, GRID_MAX)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetValue(GW.RoundDec(GW.settings.gridSpacing, 0))
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetObeyStepOnDrag(true)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetValueStep(2)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.inputFrame.input:SetText(GW.RoundDec(GW.settings.gridSpacing, 0))

    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetScript("OnValueChanged", function(self)
        local roundValue = GW.RoundDec(self:GetValue(), 0)
        GW.settings.gridSpacing = tonumber(roundValue)
        self:GetParent().inputFrame.input:SetText(roundValue)
        ShowGrid()
    end)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.inputFrame.input:SetScript("OnEnterPressed", function(self)
        local value = ClampEditBoxNumber(self, GRID_MIN, GRID_MAX, 0)
        value = floor((value - GRID_MIN) / 2 + 0.5) * 2 + GRID_MIN -- the slider walks in steps of two
        self:SetText(value)

        -- the slider applies the value, its handler sets the setting and redraws the grid
        self:GetParent():GetParent().slider:SetValue(value)
    end)

    --load tag dropdown
    local tagScrollFrame = smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown
    tagScrollFrame.title:SetFont(DAMAGE_TEXT_FONT, 12)
    tagScrollFrame.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    tagScrollFrame.title:SetText(L["Filter"])
    tagScrollFrame:GwHandleDropDownBox(nil, nil, nil, 125)

    tagScrollFrame:SetupMenu(function(dropdown, rootDescription)
        table.sort(allTags, function(a, b)
            if a == ALL then return true end
            if b == ALL then return false end
            return tostring(a) < tostring(b)
        end)

        local buttonSize = 20
        local maxButtons = 7
        rootDescription:SetScrollMode(buttonSize * maxButtons)

        for _, v in pairs(allTags) do
            local function IsSelected(tag) return selectedTag == tag end

            local function SetSelected(tagEnum) filterHudMovers(tagEnum) end

            local radio = rootDescription:CreateRadio(v, IsSelected, SetSelected, v)
            radio:AddInitializer(function(button, description, menu)
                GW.BlizzardDropdownRadioButtonInitializer(button, description, menu, IsSelected, v)
            end)
        end
    end)

    tagScrollFrame.needsRebuild = true
    smallSettingsContainer:HookScript("OnShow", function()
        if tagScrollFrame.needsRebuild then
            tagScrollFrame:GenerateMenu()
            tagScrollFrame.needsRebuild = false
        end
    end)

    --Layout
    GW.LoadLayoutsFrame(smallSettingsContainer, layoutManager)
    SetSmallSettingsLayoutViewShown(smallSettingsContainer, false)
    HookSmallSettingsMouseFade(smallSettingsContainer, smallSettingsContainer)
    HookSmallSettingsMouseFade(mf, smallSettingsContainer)

    smallSettingsContainer:Hide()
    mf:Hide()
end
GW.LoadMovers = LoadMovers
