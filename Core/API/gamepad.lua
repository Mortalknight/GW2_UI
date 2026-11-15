---@class GW2
local GW = select(2, ...)

local Gamepad = {}
GW.Gamepad = Gamepad

function Gamepad.IsInterface()
    return InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()
end

-- blizzard refuses to select into an addon scroll box (its scroll handling runs tainted), jump overrides skip that
local GAMEPAD_DIRECTIONS = SMART_NAV_INPUT_DIRECTION and {SMART_NAV_INPUT_DIRECTION.UP, SMART_NAV_INPUT_DIRECTION.DOWN, SMART_NAV_INPUT_DIRECTION.LEFT, SMART_NAV_INPUT_DIRECTION.RIGHT} or {}
local GAMEPAD_DEFAULT_ANGLE = math.rad(45)
local GAMEPAD_UP_DOWN_ANGLE = 75
local GAMEPAD_LIST_OWNER = {}
local gamepadLinkedControls = {}
local controls, controlLists, centerX, centerY = {}, {}, {}, {}

local function IsGamepadList(frame)
    return frame.ScrollTarget ~= nil and frame.FindFrameElementDataIndex ~= nil
end

local function IsGamepadControl(frame)
    return frame:IsVisible() and frame:IsRectValid() and SmartNavigation_CanFocusFrame(frame) and not SmartNavigation_IsFrameIgnored(frame)
end

local function GetScaledCenter(frame)
    local left, bottom, width, height = frame:GetScaledRect()
    return left + width / 2, bottom + height / 2
end

local function AddGamepadControl(control, x, y, list)
    tinsert(controls, control)
    centerX[control], centerY[control], controlLists[control] = x, y, list
end

local function CollectGamepadControls(frame)
    for _, child in ipairs({frame:GetChildren()}) do
        if child:IsVisible() and not SmartNavigation_IsFrameIgnored(child) then
            if IsGamepadList(child) then
                if child:GetView() and child:IsRectValid() then
                    local left, bottom, width, height = child:GetScaledRect()
                    for _, row in ipairs(child:GetFrames()) do
                        if IsGamepadControl(row) then
                            local x, y = GetScaledCenter(row)
                            if x > left and x < left + width and y > bottom and y < bottom + height then
                                AddGamepadControl(row, x, y, child)
                            end
                        end
                    end
                end
            else
                if IsGamepadControl(child) then
                    AddGamepadControl(child, GetScaledCenter(child))
                end
                CollectGamepadControls(child)
            end
        end
    end
end

local function FindNearestGamepadControl(from, direction, filter)
    local x, y = centerX[from], centerY[from]
    local angle = SmartNavigation_GetDirectionBufferThreshold(from, direction) or GAMEPAD_DEFAULT_ANGLE
    local nearest, nearestDistance
    for _, control in ipairs(controls) do
        if control ~= from and (not filter or filter(control)) then
            local dx, dy = centerX[control] - x, centerY[control] - y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance > 0 and (not nearest or distance < nearestDistance)
                and math.abs(Vector2D_CalculateAngleBetween(dx, dy, direction.x, direction.y)) <= angle then
                nearest, nearestDistance = control, distance
            end
        end
    end
    return nearest
end

local function StepGamepadList(list, row, step)
    local index = list:FindFrameElementDataIndex(row)
    local size = list:GetDataProviderSize()
    index = index and index + step
    while index and index >= 1 and index <= size do
        list:ScrollToElementDataIndex(index, ScrollBoxConstants.AlignNearest, nil, ScrollBoxConstants.NoScrollInterpolation)
        local frame = list:FindFrame(list:FindElementData(index))
        if frame and IsGamepadControl(frame) then
            return frame
        end
        index = index + step
    end
end

local function LinkGamepadLists(window)
    local linked = gamepadLinkedControls[window]
    for control, directions in pairs(linked) do
        for direction in pairs(directions) do
            SmartNavigation_ClearJumpNavigationOverridesInDirection(control, direction)
        end
    end
    wipe(linked)
    wipe(controls)
    wipe(controlLists)
    wipe(centerX)
    wipe(centerY)
    CollectGamepadControls(window)
    for _, control in ipairs(controls) do
        local list = controlLists[control]
        for _, direction in ipairs(GAMEPAD_DIRECTIONS) do
            local target
            if list and direction.x == 0 then
                target = FindNearestGamepadControl(control, direction, function(other) return controlLists[other] == list end)
                if not target then
                    local outside = FindNearestGamepadControl(control, direction, function(other) return controlLists[other] ~= list end)
                    local step = direction.y > 0 and -1 or 1
                    target = function() return StepGamepadList(list, control, step) or outside end
                end
            else
                target = FindNearestGamepadControl(control, direction)
                if not list and not (target and controlLists[target]) then
                    target = nil
                end
            end
            -- blizzard links some of its own frames (the gear slots)
            if target and control["smartNavigationOverride-" .. direction.dirKey] == nil then
                SmartNavigation_AddJumpNavigationOverride(control, direction, target)
                linked[control] = linked[control] or {}
                linked[control][direction] = true
            end
        end
    end
end

local OpenGamepadMenu
local QueueGamepadControls
local function PrepareGamepadControls(frame, window)
    window = window or frame
    for _, child in ipairs({frame:GetChildren()}) do
        local leftOut = child.ScrollTarget ~= nil or child:IsObjectType("EditBox")
        if not child.gwGamepadPrepared then
            child.gwGamepadPrepared = true
            if IsGamepadList(child) then
                gamepadLinkedControls[window] = gamepadLinkedControls[window] or {}
                local function Relink() QueueGamepadControls(window) end
                child:RegisterCallback(BaseScrollBoxEvents.OnLayout, Relink, GAMEPAD_LIST_OWNER)
                child:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, Relink, GAMEPAD_LIST_OWNER)
                child:HookScript("OnShow", Relink)
            elseif leftOut then
                -- a focused edit box keeps the d-pad
                SmartNavigation_MarkFrameIgnored(child)
            elseif child:IsObjectType("Button") then
                -- our rows mix small checkboxes with wide controls
                SmartNavigation_SetDirectionBufferThreshold(child, SMART_NAV_INPUT_DIRECTION.UP, GAMEPAD_UP_DOWN_ANGLE)
                SmartNavigation_SetDirectionBufferThreshold(child, SMART_NAV_INPUT_DIRECTION.DOWN, GAMEPAD_UP_DOWN_ANGLE)
            end
            -- blizzards menu gets no pad focus when addon code opens it
            if IsDropdownButtonIntrinsic(child) then
                child.OnSmartNavClick = OpenGamepadMenu
            end
        end
        if not leftOut then
            PrepareGamepadControls(child, window)
        end
    end
end

-- blizzard blocks navigation changes from addon code in combat, those wait for its end
local gamepadControlsPending = {}
local gamepadControlsUpdater = CreateFrame("Frame")
gamepadControlsUpdater:Hide()
gamepadControlsUpdater:SetScript("OnUpdate", function(self)
    self:Hide()
    if InCombatLockdown() then
        return
    end
    for window in pairs(gamepadControlsPending) do
        if window:IsVisible() then
            PrepareGamepadControls(window)
            if gamepadLinkedControls[window] then
                LinkGamepadLists(window)
            end
        end
    end
    wipe(gamepadControlsPending)
end)
gamepadControlsUpdater:RegisterEvent("PLAYER_REGEN_ENABLED")
gamepadControlsUpdater:SetScript("OnEvent", gamepadControlsUpdater.Show)

function QueueGamepadControls(window)
    gamepadControlsPending[window] = true
    gamepadControlsUpdater:Show()
end

-- bindings only change out of combat
local gamepadFocusBindings = {}
local gamepadFocusBindingCount = 0
local function SetGamepadFocusBindings(frame, focused)
    frame.gwGamepadFocused = focused
    if InCombatLockdown() then
        return
    end
    for button, key in pairs(gamepadFocusBindings[frame]) do
        if focused then
            SetOverrideBindingClick(button, true, key, button:GetName())
        else
            ClearOverrideBindings(button)
        end
    end
end

local function GamepadFocusBinding_OnEvent(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        ClearOverrideBindings(self)
    elseif self.gwWindow.gwGamepadFocused then
        SetOverrideBindingClick(self, true, gamepadFocusBindings[self.gwWindow][self], self:GetName())
    end
end

local function AddGamepadFocusBinding(frame, key, onClick)
    if not gamepadFocusBindings[frame] then
        gamepadFocusBindings[frame] = {}
        frame.FocusGamepad = function(self) SetGamepadFocusBindings(self, true) end
        frame.UnfocusGamepad = function(self) SetGamepadFocusBindings(self, false) end
        -- blizzard skips UnfocusGamepad when a window closes while the game has the gamepad
        frame:HookScript("OnHide", frame.UnfocusGamepad)
    end
    gamepadFocusBindingCount = gamepadFocusBindingCount + 1
    local button = CreateFrame("Button", "GwGamepadFocusBinding" .. gamepadFocusBindingCount, UIParent)
    button.gwWindow = frame
    button:SetScript("OnClick", onClick)
    button:RegisterEvent("PLAYER_REGEN_DISABLED")
    button:RegisterEvent("PLAYER_REGEN_ENABLED")
    button:SetScript("OnEvent", GamepadFocusBinding_OnEvent)
    gamepadFocusBindings[frame][button] = key
end

local function GamepadLegend_Update(self, event, ...)
    for text, getLabel in pairs(self.labelFunctions) do
        text:SetText(getLabel(event, ...))
    end
end

local function CreateGamepadLegend(parent, entries)
    local legend = CreateFrame("Frame", nil, parent)
    legend:SetSize(1, 24)
    legend.labelFunctions = {}
    local prev
    for _, entry in ipairs(entries) do
        local icon = CreateFrame("Frame", nil, legend, "InputIconTextureFrameTemplate")
        icon:SetInputKey(entry[1])
        if prev then
            icon:SetPoint("LEFT", prev, "RIGHT", 12, 0)
        else
            icon:SetPoint("LEFT")
        end
        local text = legend:CreateFontString(nil, "OVERLAY")
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        if type(entry[2]) == "function" then
            legend.labelFunctions[text] = entry[2]
        else
            text:SetText(entry[2])
        end
        text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        prev = text
    end
    if next(legend.labelFunctions) then
        legend:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
        legend:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
        legend:SetScript("OnEvent", GamepadLegend_Update)
        legend:SetScript("OnShow", GamepadLegend_Update)
    end
    return legend
end

local function AddGamepadButtonIcon(button, key)
    local icon = CreateFrame("Frame", nil, button, "InputIconTextureFrameTemplate")
    icon:SetSize(button:GetHeight() - 4, button:GetHeight() - 4)
    if button:GetFontString() then
        icon:SetPoint("RIGHT", button:GetFontString(), "LEFT", -4, 0)
    else
        icon:SetPoint("LEFT", button, "LEFT", 4, 0)
    end
    icon:SetInputKey(key)
    button.gwGamepadIcon = icon
end

local gamepadStartButtons = {}
local gamepadReplacedFrames = {}
local gamepadPopups = {}
local gamepadPending = {}
local gamepadModal
local gamepadDeferred = {}
-- a window joins one frame after it shows; own OnUpdate, a C_Timer from hooks on blizzard functions taints
local gamepadDriver = CreateFrame("Frame")
gamepadDriver:Hide()
gamepadDriver:SetScript("OnUpdate", function(self)
    self:Hide()
    local pending = gamepadPending
    gamepadPending = {}
    for _, frame in ipairs(pending) do
        if gamepadModal and gamepadModal:IsVisible() and frame ~= gamepadModal and not gamepadPopups[frame] then
            tinsert(gamepadDeferred, frame)
        elseif frame:IsVisible() then
            if gamepadReplacedFrames[frame] then
                GamepadMode.FrameControlsManager:FrameHidden(gamepadReplacedFrames[frame])
            end
            QueueGamepadControls(frame)
            GamepadMode.FrameControlsManager:FrameShown(frame, gamepadPopups[frame])
            if gamepadStartButtons[frame] then
                SmartNavigation:SetTargetButtonForFrame(frame, gamepadStartButtons[frame](frame))
            end
        end
    end
end)

local function QueueGamepadWindow(frame)
    tDeleteItem(gamepadPending, frame)
    tinsert(gamepadPending, frame)
    gamepadDriver:Show()
end
Gamepad.FocusWindow = QueueGamepadWindow

-- options: startButton(frame), replaces (blizzard window), bindings {[key] = onClick or button},
-- icons {[key] = button}, skip {frame, ...}, modal, popup, onDemand (focus only through FocusWindow),
-- legend {{key, label or function}, ...}, legendOffset
function Gamepad.RegisterWindow(frame, options)
    if not GW.loadedWithGamepadInterface then
        return
    end
    options = options or {}
    gamepadStartButtons[frame] = options.startButton
    gamepadReplacedFrames[frame] = options.replaces
    gamepadPopups[frame] = options.popup
    if options.modal then
        gamepadModal = frame
    end
    for _, handle in pairs({frame.sizer, frame.mover}) do
        SmartNavigation_MarkFrameIgnored(handle)
    end
    for _, skipped in ipairs(options.skip or {}) do
        SmartNavigation_MarkFrameIgnored(skipped)
    end
    for key, button in pairs(options.icons or {}) do
        AddGamepadButtonIcon(button, key)
    end
    if not options.onDemand then
        frame:HookScript("OnShow", QueueGamepadWindow)
    end
    frame:HookScript("OnHide", function(self)
        tDeleteItem(gamepadPending, self)
        tDeleteItem(gamepadDeferred, self)
        GamepadMode.FrameControlsManager:FrameHidden(self)
        if self == gamepadModal then
            for _, deferred in ipairs(gamepadDeferred) do
                tinsert(gamepadPending, deferred)
            end
            wipe(gamepadDeferred)
            gamepadDriver:Show()
        end
    end)
    for key, action in pairs(options.bindings or {}) do
        if type(action) == "function" then
            AddGamepadFocusBinding(frame, key, action)
        else
            AddGamepadFocusBinding(frame, key, function()
                if action:IsVisible() and action:IsEnabled() then
                    action:Click()
                end
            end)
            AddGamepadButtonIcon(action, key)
        end
    end
    if options.legend then
        local offset = options.legendOffset or -8
        CreateGamepadLegend(frame, options.legend):SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, offset)
        local left, right, top, bottom = frame:GetClampRectInsets()
        frame:SetClampRectInsets(left, right, top, math.min(bottom, offset - 24))
    end
end

function Gamepad.RefreshWindow(frame, startButton)
    if not GW.loadedWithGamepadInterface then
        return
    end
    QueueGamepadControls(frame)
    if SmartNavigation:GetActiveFrame() == frame then
        SmartNavigation:RefreshButtonGroups()
        if startButton then
            SmartNavigation:SetTargetButtonForFrame(frame, startButton)
        end
    end
end

-- the dropdown entries as own popup, built from the same menu description as blizzards menu
local GAMEPAD_MENU_ROW = 22
local gamepadMenu
local RenderGamepadMenu

local function UpdateGamepadMenuSlider(row, direction)
    local config = row.entry.gwSlider
    if direction then
        config.setValue(Clamp(config.getValue() + direction * (config.step or 1), config.minValue or 0, config.maxValue or 1))
    end
    row.text:SetText(MenuUtil.GetElementText(row.entry) .. ":  " .. config.getValue())
    return true
end

local function UpdateGamepadMenuRow(row)
    local entry = row.entry
    row:SetEnabled(entry:IsEnabled())
    row.text:SetAlpha(row:IsEnabled() and 1 or 0.5)
    if entry:IsRadio() then
        row.check:SetTexture(entry:IsSelected() and "Interface/AddOns/GW2_UI/textures/uistuff/radio-selected.png" or "Interface/AddOns/GW2_UI/textures/uistuff/radio-unselected.png")
    elseif entry:IsCheckbox() then
        row.check:SetTexture(entry:IsSelected() and "Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png" or "Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
    end
end

local function GamepadMenuRow_OnClick(row)
    local menu, entry = gamepadMenu, row.entry
    if entry.gwSlider then
        return
    end
    if entry:HasElements() then
        tinsert(menu.stack, menu.description)
        RenderGamepadMenu(entry)
        return
    end
    local _, response = entry:Pick(MenuInputContext.MouseButton, "LeftButton")
    menu.dropdown:OnMenuResponse(nil, entry)
    if response == MenuResponse.Refresh or response == MenuResponse.Open then
        -- no new layout, the selected button stays
        for activeRow in menu.rows:EnumerateActive() do
            UpdateGamepadMenuRow(activeRow)
        end
    elseif response == MenuResponse.Close and #menu.stack > 0 then
        RenderGamepadMenu(tremove(menu.stack))
    else
        menu:Hide()
    end
end

local function GamepadMenuRow_Init(row)
    row:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
    row:GetHighlightTexture():SetAlpha(0.5)
    row.check = row:CreateTexture(nil, "ARTWORK")
    row.check:SetSize(14, 14)
    row.check:SetPoint("LEFT", 6, 0)
    row.arrow = row:CreateTexture(nil, "ARTWORK")
    row.arrow:SetTexture("Interface/ChatFrame/ChatFrameExpandArrow")
    row.arrow:SetSize(12, 12)
    row.arrow:SetPoint("RIGHT", -6, 0)
    row.text = row:CreateFontString(nil, "OVERLAY")
    row.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    row.text:SetJustifyH("LEFT")
    row.text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    row:SetHeight(GAMEPAD_MENU_ROW)
    row:SetScript("OnClick", GamepadMenuRow_OnClick)
end

function RenderGamepadMenu(description)
    local menu = gamepadMenu
    menu.description = description
    menu.rows:ReleaseAll()
    menu.titles:ReleaseAll()
    menu.selected = nil
    local width, index = 0, 0
    for _, entry in description:EnumerateElementDescriptions() do
        local text = MenuUtil.GetElementText(entry)
        if type(text) == "string" and text ~= "" then
            index = index + 1
            local y = -6 - (index - 0.5) * GAMEPAD_MENU_ROW
            -- a title is no button, the navigation can not land on it
            if not entry:HasResponder() and not entry:HasElements() and not entry.gwSlider then
                local title = menu.titles:Acquire()
                title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
                title:SetText(text)
                title:SetPoint("LEFT", menu, "TOPLEFT", 8, y)
                title:Show()
                width = math.max(width, title:GetUnboundedStringWidth() + 32)
            else
                local row = menu.rows:Acquire()
                local hasCheck = entry:IsCheckbox() or entry:IsRadio()
                row.entry = entry
                if not InCombatLockdown() then
                    SmartNavigation_ClearJumpNavigationOverrides(row)
                    if entry.gwSlider then
                        SmartNavigation_AddJumpNavigationOverride(row, SMART_NAV_INPUT_DIRECTION.LEFT, function() return UpdateGamepadMenuSlider(row, -1) end)
                        SmartNavigation_AddJumpNavigationOverride(row, SMART_NAV_INPUT_DIRECTION.RIGHT, function() return UpdateGamepadMenuSlider(row, 1) end)
                    end
                end
                UpdateGamepadMenuRow(row)
                menu.selected = menu.selected or row
                row.check:SetShown(hasCheck)
                row.arrow:SetShown(entry:HasElements())
                if entry.gwSlider then
                    UpdateGamepadMenuSlider(row)
                else
                    row.text:SetText(text)
                end
                row.text:SetPoint("LEFT", hasCheck and 26 or 8, 0)
                width = math.max(width, row.text:GetUnboundedStringWidth() + (hasCheck and 26 or 8) + 24)
                row:SetPoint("LEFT", menu, "TOPLEFT", 0, y)
                row:SetPoint("RIGHT", menu, "TOPRIGHT", 0, y)
                row:Show()
            end
        end
    end
    menu:SetSize(width, index * GAMEPAD_MENU_ROW + 12)
    Gamepad.RefreshWindow(menu, menu.selected)
end

function OpenGamepadMenu(dropdown)
    -- blizzard blocks the popup focus in combat
    if InCombatLockdown() or not dropdown:IsEnabled() then
        return
    end
    dropdown:GenerateMenu()
    local description = dropdown:GetMenuDescription()
    if not description or not description:HasElements() then
        return
    end
    if not gamepadMenu then
        gamepadMenu = CreateFrame("Frame", nil, UIParent)
        gamepadMenu:SetFrameStrata("FULLSCREEN_DIALOG")
        gamepadMenu:SetClampedToScreen(true)
        gamepadMenu:EnableMouse(true)
        gamepadMenu:GwCreateBackdrop(GW.BackdropTemplates.Default)
        gamepadMenu:Hide()
        gamepadMenu.rows = CreateFramePool("Button", gamepadMenu, nil, nil, nil, GamepadMenuRow_Init)
        gamepadMenu.titles = CreateFontStringPool(gamepadMenu, "OVERLAY")
        gamepadMenu.stack = {}
        gamepadMenu.SmartNavigationCloseHandler = function(self)
            if #self.stack > 0 then
                RenderGamepadMenu(tremove(self.stack))
            else
                self:Hide()
            end
            return true
        end
        Gamepad.RegisterWindow(gamepadMenu, {popup = true, startButton = function(self) return self.selected end,
            legend = {{"PAD1", ACTION_LABEL_SELECT}, {"DIRPAD", FRAME_ACTION_NAVIGATE}, {"PAD2", FRAME_ACTION_CLOSE}}})
    end
    if not dropdown.gwGamepadMenuHook then
        dropdown.gwGamepadMenuHook = true
        dropdown:HookScript("OnHide", function(self)
            if gamepadMenu.dropdown == self then
                gamepadMenu:Hide()
            end
        end)
    end
    gamepadMenu:Hide()
    gamepadMenu.dropdown = dropdown
    wipe(gamepadMenu.stack)
    gamepadMenu:ClearAllPoints()
    gamepadMenu:SetPoint(dropdown.menuPoint or "TOPLEFT", dropdown, dropdown.menuRelativePoint or "BOTTOMLEFT")
    RenderGamepadMenu(description)
    gamepadMenu:Show()
end

-- blizzard applies the focus frame opacity only when it changes, never to new frames
local function ApplyGamepadFocusOpacity(glow)
    glow:SetAlpha(tonumber(C_CVar.GetCVar("GamepadFocusStateOpacity")) or 1)
end

-- for blizzard dropdowns whose menu was built by addon code
function Gamepad.UseGamepadMenu(dropdown)
    dropdown.OnSmartNavClick = OpenGamepadMenu
end

function Gamepad.HideFocusFrames()
    if not FrameGlowMixin then return end
    if tonumber(C_CVar.GetCVar("GamepadFocusStateOpacity")) ~= 0 then
        C_CVar.SetCVar("GamepadFocusStateOpacity", "0")
    end
    hooksecurefunc(FrameGlowMixin, "OnLoad", ApplyGamepadFocusOpacity)
    local frame = EnumerateFrames()
    while frame do
        if not frame:IsForbidden() and frame.glowTextures and frame.GlowTexture then
            ApplyGamepadFocusOpacity(frame)
        end
        frame = EnumerateFrames(frame)
    end
end

function Gamepad.LinkGameMenuButton(menuFrame, button)
    local buttons = menuFrame.buttons
    if not Gamepad.IsInterface() or not buttons or #buttons == 0 then
        return
    end
    SmartNavigation_AddBidirectionalJumpNavigationOverride(buttons[#buttons], SMART_NAV_INPUT_DIRECTION.DOWN, button)
    SmartNavigation_AddBidirectionalJumpNavigationOverride(button, SMART_NAV_INPUT_DIRECTION.DOWN, buttons[1])
end
