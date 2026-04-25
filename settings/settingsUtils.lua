---@class GW2
local GW = select(2, ...)
local L = GW.L
local RoundDec = GW.RoundDec

--helper functions for settings
local function CreateSettingProxy(fullPath, isPrivateSetting, isMultiselect)
    local keys = {}
    for key in string.gmatch(fullPath, "[^%.]+") do
        table.insert(keys, key)
    end

    return {
        get = function(optionKey)
            local ref =(isPrivateSetting and GW.private) or GW.settings
            for i = 1, #keys - 1 do
                ref = ref[keys[i]]
                if not ref then return nil end
            end
            local setting = ref[keys[#keys]]
            if isMultiselect then
                if type(setting) == "table" and optionKey then
                    return setting[optionKey]
                end
                return setting
            end
            return setting
        end,

        set = function(value, optionKey)
            local ref = (isPrivateSetting and GW.private) or GW.settings
            for i = 1, #keys - 1 do
                if not ref[keys[i]] then ref[keys[i]] = {} end
                ref = ref[keys[i]]
            end
            if isMultiselect then
                if not ref[keys[#keys]] then ref[keys[#keys]] = {} end
                ref[keys[#keys]][optionKey] = value
            else
                ref[keys[#keys]] = value
            end
            GW.settings.profileChangedDate = date(L["TimeStamp m/d/y h:m:s"])
            GW.RefreshProfileScrollBox(GW2ProfileSettingsView.ScrollBox)
        end,

        getDefault = function(optionKey)
            local ref = (isPrivateSetting and GW.privateDefaults.profile) or GW.globalDefault.profile
            for i = 1, #keys - 1 do
                ref = ref[keys[i]]
                if not ref then return nil end
            end
            local setting = ref[keys[#keys]]
            if isMultiselect then
                if type(setting) == "table" and optionKey then
                    return setting[optionKey]
                end
                return setting
            end
            return setting
        end
    }
end
GW.CreateSettingProxy = CreateSettingProxy

local function AddDependenciesToOptionWidgetTooltip()
    for _, of in pairs(GW.GetAllSettingsWidgets()) do
        if of.dependence then
            of.dependenciesInfo = {}

            for settingName, expectedValue in pairs(of.dependence) do
                local settingsWidget = GW.FindSettingsWidgetByOption(settingName)
                if settingsWidget then
                    local displayName = settingsWidget and settingsWidget.displayName or settingName
                    local currentVal = settingsWidget and settingsWidget.get()
                    if settingsWidget.isIncompatibleAddonLoaded and not settingsWidget.isIncompatibleAddonLoadedButOverride then
                        currentVal = false
                    end
                    local match = false

                    local expectedText
                    if type(expectedValue) == "table" then
                        local valuesList = {}
                        for _, v in ipairs(expectedValue) do
                            if currentVal == v then
                                match = true
                            end

                            local display = tostring(v)

                            if settingsWidget and settingsWidget.optionsList and settingsWidget.optionsNames then
                                for i, real in ipairs(settingsWidget.optionsList) do
                                    if real == v then
                                        display = settingsWidget.optionsNames[i]
                                        break
                                    end
                                end
                            end

                            table.insert(valuesList, display)
                        end
                        expectedText = table.concat(valuesList, ", ")
                    else
                        if currentVal == expectedValue then
                            match = true
                        end
                        expectedText = L[tostring(expectedValue)]
                    end

                    local color = match and "|cff66cc66" or "|cffcc6666"  -- green or red
                    expectedText = color .. expectedText .. "|r"

                    table.insert(of.dependenciesInfo, { name = string.format("|cffaaaaaa%s|r", settingsWidget.settingsPath .. displayName), expected = expectedText })
                end
            end
        end
    end
end

local function CreateOption(optionType, panel, name, desc, values)
    if not panel then return end
    values = values or {}

    if values.hidden == true then
        return nil
    end

    panel.gwOptions = panel.gwOptions or {}

    local opt = {
        name = name,
        desc = desc or "",
        optionName = values.getterSetter, -- forbidden for addons
        optionType = optionType,
        callback = values.callback,
        dependence = values.dependence,
        forceNewLine = values.forceNewLine,
        incompatibleAddonsType = values.incompatibleAddons,
        isIncompatibleAddonLoaded = false,
        isIncompatibleAddonLoadedButOverride = false,
        groupHeaderName = values.groupHeaderName,
        isPrivateSetting = values.isPrivateSetting, -- forbidden for addons
        optionUpdateFunc = values.optionUpdateFunc,

        getter = values.getter, --for addons
        setter = values.setter, --for addons
        getDefault = values.getDefault, --for addons
    }

    if values.getterSetter then
        local proxy = CreateSettingProxy(values.getterSetter, values.isPrivateSetting, values.checkbox)
        opt.get = proxy.get
        opt.set = proxy.set
        opt.getDefault = proxy.getDefault
    elseif values.getter and values.setter then
        opt.get = values.getter
        opt.set = values.setter
        opt.getDefault = values.getDefault
    end

    table.insert(panel.gwOptions, opt)

    if values.incompatibleAddons then
        local isLoaded, loadedAddons, isOverride = GW.GetIncompatibleAddonInfo(values.incompatibleAddons)

        if isLoaded then
            local baseMsg = "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r"
            local addonList = "|cffff0000\n" .. loadedAddons .. "|r"
            local overrideHint = "\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            local overrideNote = isOverride and ("\n\n|cffffa500" .. L["You have overridden this behavior."] .. "|r") or ""

            opt.desc = opt.desc .. baseMsg .. addonList .. overrideNote .. overrideHint
            opt.isIncompatibleAddonLoaded = isLoaded
            opt.isIncompatibleAddonLoadedButOverride = isOverride
        end
    end

    return opt
end

GwSettingsPanelMixin = {}
function GwSettingsPanelMixin:AddOption(name, desc, values)
    return CreateOption("boolean", self, name, desc, values)
end

function GwSettingsPanelMixin:AddOptionButton(name, desc, values)
    return CreateOption("button", self, name, desc, values)
end

function GwSettingsPanelMixin:AddGroupHeader(name, values)
    return CreateOption("header", self, name, nil, values)
end

function GwSettingsPanelMixin:AddOptionColorPicker(name, desc, values)
    return CreateOption("colorPicker", self, name, desc, values)
end

function GwSettingsPanelMixin:AddOptionSlider(name, desc, values)
    local opt = CreateOption("slider", self, name, desc, values)
    if not opt then return end

    opt.min = values.min
    opt.max = values.max
    opt.decimalNumbers = values.decimalNumbers or 0
    opt.step = values.step

    return opt
end

function GwSettingsPanelMixin:AddOptionSortableList(name, desc, values)
    local opt = CreateOption("list", self, name, desc, values)
    if not opt then return end

    opt.optionsList = values.optionsList
    opt.optionsNames = values.optionNames or values.optionsNames
    opt.entryHeight = values.entryHeight or 24
    opt.maxVisibleRows = values.maxVisibleRows

    return opt
end

function GwSettingsPanelMixin:AddOptionText(name, desc, values)
    local opt = CreateOption("text", self, name, desc, values)
    if not opt then return end

    opt.multiline = values.multiline

    return opt
end

function GwSettingsPanelMixin:AddOptionDropdown(name, desc, values)
    local opt = CreateOption("dropdown", self, name, desc, values)
    if not opt then return end

    opt.optionsList = values.optionsList
    opt.optionsNames = values.optionNames
    opt.hasCheckbox = values.checkbox
    opt.tooltipType = values.tooltipType
    opt.hasSound = values.hasSound
    opt.noNewLine = values.noNewLine

    return opt
end

local function setDependenciesOption(type, settingName, SetEnable, deactivateColor, overrideColor)
    local of = GW.FindSettingsWidgetByOption(settingName)
    if not of then return end

    local color, inputColor, enabled = {1, 1, 1}, {0.82, 0.82, 0.82}, true

    if overrideColor then
        color = {1, 0.65, 0}
        inputColor = color
        enabled = true
    elseif deactivateColor then
        color = {0.82, 0, 0}
        inputColor = color
        enabled = true
    elseif not SetEnable then
        color = {0.4, 0.4, 0.4}
        inputColor = color
        enabled = false
    end

    of.title:SetTextColor(unpack(color))

    if type == "slider" then
        if enabled then
            of.slider:Enable()
            of.inputFrame.input:Enable()
        else
            of.slider:Disable()
            of.inputFrame.input:Disable()
        end
        of.inputFrame.input:SetTextColor(unpack(inputColor))
    elseif type == "text" then
        if of.inputFrame and of.inputFrame.input then
            of.inputFrame.input:SetEnabled(enabled)
            of.inputFrame.input:SetTextColor(unpack(inputColor))
        end
    elseif type == "dropdown" then
        if enabled then
            of.dropDown:Enable()
        else
            of.dropDown:Disable()
        end
        if of.dropDown.Text then
            of.dropDown.Text:SetTextColor(unpack(inputColor))
        end
    elseif type == "button" then
        if enabled then
            of:Enable()
            of.title:SetTextColor(0, 0, 0)
        else
            of:Disable()
        end
    elseif type == "colorPicker" then
        if of.button then
            of.button:SetEnabled(enabled)
        end
    elseif type == "boolean" then
        if of.checkbutton then
            of.checkbutton:SetEnabled(enabled)
        end
    elseif type == "list" then
        of:SetListEnabled(enabled, color)
    end
end

local function CheckDependencies()
    for _, v in pairs(GW.GetAllSettingsWidgets()) do
        if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
            setDependenciesOption(v.optionType, v.optionName, false, v.isIncompatibleAddonLoaded, v.isIncompatibleAddonLoadedButOverride)
        elseif v.dependence then
            local allDepsMet = true

            for settingName, expectedValue in pairs(v.dependence) do
                local of = GW.FindSettingsWidgetByOption(settingName)
                local currentVal = (of and of.get and of.get())
                if of and of.isIncompatibleAddonLoaded and not of.isIncompatibleAddonLoadedButOverride then
                    currentVal = false
                end

                if not of then currentVal = false end

                if type(expectedValue) == "table" then
                    local matched = false
                    for _, val in ipairs(expectedValue) do
                        if currentVal == val then
                            matched = true
                            break
                        end
                    end
                    if not matched then
                        allDepsMet = false
                        break
                    end
                else
                    if currentVal ~= expectedValue then
                        allDepsMet = false
                        break
                    end
                end
            end
            setDependenciesOption(v.optionType, v.optionName, allDepsMet)
        end
    end
    AddDependenciesToOptionWidgetTooltip()
end
GW.CheckDependencies = CheckDependencies

local function ColorPickerFrameCallback(restore, frame, buttonBackground)
    if ColorPickerFrame.noColorCallback then return end
    local newR, newG, newB
    if restore then
        -- The user bailed, we extract the old color from the table created by ShowColorPicker.
        newR, newG, newB = unpack(restore)
    else
        -- Something changed
        if GW.Retail then
            newR, newG, newB = ColorPickerFrame.Content.ColorPicker:GetColorRGB()
        else
            newR, newG, newB = ColorPickerFrame:GetColorRGB()
        end
    end
    -- Update our internal storage.

    local color = frame.get()
    local changed = color.r ~= newR or color.g ~= newG or color.b ~= newB
    color.r = newR
    color.g = newG
    color.b = newB
    frame.set(color)
    buttonBackground:SetColorTexture(newR, newG, newB)

    if frame.callback then
        frame.callback(newR, newG, newB, changed)
    end
end

local function ShowColorPicker(frame)
    local color = frame.get()
    if GW.Retail then
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(color.r, color.g, color.b)
    else
        ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
    end
    ColorPickerFrame.hasOpacity = (color.a ~= nil)
    ColorPickerFrame.opacity = color.a
    ColorPickerFrame.previousValues = {color.r, color.g, color.b, color.a}
    ColorPickerFrame.func = function() ColorPickerFrameCallback(nil, frame, frame.button.bg) end
    ColorPickerFrame.opacityFunc = function() ColorPickerFrameCallback(nil, frame, frame.button.bg) end
    ColorPickerFrame.cancelFunc = function(restore) ColorPickerFrameCallback(restore, frame, frame.button.bg) end
    if GwColorPPDefault and frame.getDefault then
        if not GwColorPPDefault.defaultColor then
            GwColorPPDefault.defaultColor = {}
        end

        GwColorPPDefault.defaultColor = frame.getDefault()
    end
    ColorPickerFrame:Show()
    ColorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG')
    ColorPickerFrame:SetClampedToScreen(true)
    ColorPickerFrame:Raise()
end

local function updateSettingsFrameSettingsValue(setting, value, setSetting, toDefault)
    local of = GW.FindSettingsWidgetByOption(setting)
    if not of then return end

    if toDefault then
        value = of.getDefault()
    end

    if setSetting then
        of.set(value)
    end
    if of.optionType == "slider" then
        of.slider:SetValue(RoundDec(value, of.decimalNumbers))
        of.inputFrame.input:SetText(RoundDec(value, of.decimalNumbers))
    elseif of.optionType == "boolean" then
        of.checkbutton:SetChecked(value)
    elseif of.optionType == "text" then
        of.inputFrame.input:SetText(value or "")
    elseif of.optionType == "colorPicker" then
        of.button.bg:SetColorTexture(value.r, value.g, value.b)
    elseif of.optionType == "dropdown" then
        of.dropDown:GenerateMenu()
    elseif of.optionType == "list" then
        of:RefreshList()
    end
end
GW.updateSettingsFrameSettingsValue = updateSettingsFrameSettingsValue

local function RefreshSettingsAfterProfileSwitch()
    GW.disableGridUpdate = true
    GW.IsInProfileSwitch = true
    for _, of in pairs(GW.GetAllSettingsWidgets()) do
        if of.optionType == "slider" then
            of.slider:SetValue(RoundDec(of.get(), of.decimalNumbers))
            of.inputFrame.input:SetText(RoundDec(of.get(), of.decimalNumbers))
            if of.callback then
                of.callback()
            end
        elseif of.optionType == "boolean" then
            of.checkbutton:SetChecked(of.get())
            if of.callback then
                local toSet = of.checkbutton:GetChecked()
                of.callback(toSet, of.optionName)
            end
        elseif of.optionType == "text" then
            of.inputFrame.input:SetText(of.get() or "")
            if of.callback then
                of.callback(of.inputFrame.input)
            end
        elseif of.optionType == "colorPicker" then
            local color = of.get()
            of.button.bg:SetColorTexture(color.r, color.g, color.b)
        elseif of.optionType == "dropdown" then
            of.dropDown:GenerateMenu()
        elseif of.optionType == "list" then
            of:RefreshList()
            if of.callback then
                of.callback((of.GetListOrder and of:GetListOrder()) or of.get())
            end
        end
    end
    CheckDependencies()
    GW.ShowRlPopup = false
    GW.disableGridUpdate = false
    -- Update grids with new settings
    GW.UpdateGridSettings("ALL", nil, true)
    GW.IsInProfileSwitch = false
end
GW.RefreshSettingsAfterProfileSwitch = RefreshSettingsAfterProfileSwitch

local function HandleIncompatibility(v, button, override)
    if (IsControlKeyDown() and button and button == "LeftButton") or button == nil then
        GW.SetOverrideIncompatibleAddons(v.incompatibleAddonsType, override)
        return true
    end
    return false
end

local function ShouldHandleIncompatibility(v)
    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
        return true
    end
    return false
end

local function CopyListValues(values)
    local copy = {}
    if type(values) ~= "table" then return copy end

    for i = 1, #values do
        copy[i] = values[i]
    end

    return copy
end

local function BuildListLabelMap(optionsList, optionsNames)
    local labels = {}
    if type(optionsList) ~= "table" then return labels end

    for i, value in ipairs(optionsList) do
        labels[value] = (type(optionsNames) == "table" and optionsNames[i]) or tostring(value)
    end

    return labels
end

local function GetOrderedListValues(of, v)
    local optionsList = type(v.optionsList) == "table" and v.optionsList or {}
    local validOptions = {}
    local usedOptions = {}
    local orderedValues = {}

    for _, value in ipairs(optionsList) do
        validOptions[value] = true
    end

    local currentValues = of.get and of.get()
    if type(currentValues) == "table" then
        for _, value in ipairs(currentValues) do
            if validOptions[value] and not usedOptions[value] then
                orderedValues[#orderedValues + 1] = value
                usedOptions[value] = true
            end
        end
    end

    for _, value in ipairs(optionsList) do
        if not usedOptions[value] then
            orderedValues[#orderedValues + 1] = value
            usedOptions[value] = true
        end
    end

    return orderedValues
end

local LIST_BUTTON_SPACE = 50
local LIST_SCROLLBAR_WIDTH = 12
local LIST_SCROLLBAR_GAP = 4

local function SetListButtonState(button, enabled)
    if not button then return end

    button:SetEnabled(enabled)
    button:SetAlpha(enabled and 1 or 0.35)
end

local function ClampListScrollOffset(of, totalRows, visibleRows)
    local maxOffset = math.max((totalRows or 0) - (visibleRows or 0), 0)
    of.listScrollOffset = math.min(math.max(of.listScrollOffset or 0, 0), maxOffset)
end

local function GetListVisibleRows(totalRows, v)
    local maxVisibleRows = tonumber(v.maxVisibleRows)
    if maxVisibleRows and maxVisibleRows > 0 then
        return math.min(totalRows, maxVisibleRows)
    end

    return totalRows
end

local function MoveListValue(of, v, fromIndex, toIndex)
    local order = GetOrderedListValues(of, v)

    if fromIndex == toIndex or fromIndex < 1 or toIndex < 1 or fromIndex > #order or toIndex > #order then
        return
    end

    local movedValue = table.remove(order, fromIndex)
    table.insert(order, toIndex, movedValue)
    of.set(CopyListValues(order))

    if of.RefreshList then
        of:RefreshList()
    end

    if v.callback then
        v.callback(order, movedValue, fromIndex, toIndex)
    end
    CheckDependencies()
end

local function GetListDropIndex(of, v)
    local values = GetOrderedListValues(of, v)
    if #values == 0 then return nil end

    local cursorX, cursorY = GetCursorPosition()
    local scale = of.list:GetEffectiveScale() or 1
    if not cursorX or not cursorY then return nil end

    local cursorListX = cursorX / scale
    local cursorListY = cursorY / scale
    local left = of.list:GetLeft()
    local right = of.list:GetRight()
    local top = of.list:GetTop()
    local bottom = of.list:GetBottom()
    if not left or not right or not top or not bottom then return nil end

    if cursorListX < left or cursorListX > right or cursorListY > top or cursorListY < bottom then
        return nil
    end

    local entryHeight = v.entryHeight or 24
    local relativeY = top - cursorListY
    local visibleIndex = math.floor(relativeY / entryHeight) + 1
    local visibleRows = GetListVisibleRows(#values, v)

    visibleIndex = math.min(math.max(visibleIndex, 1), math.max(visibleRows, 1))

    return math.min((of.listScrollOffset or 0) + visibleIndex, #values)
end

local function EnsureListDragFrame(of, entryHeight)
    if of.dragFrame then return of.dragFrame end

    local dragFrame = CreateFrame("Frame", nil, UIParent)
    dragFrame:SetFrameStrata("TOOLTIP")
    dragFrame:SetHeight(entryHeight - 2)
    dragFrame:Hide()

    dragFrame.bg = dragFrame:CreateTexture(nil, "BACKGROUND")
    dragFrame.bg:SetAllPoints()
    dragFrame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    dragFrame.bg:SetAlpha(0.85)

    dragFrame.label = dragFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dragFrame.label:SetFont(UNIT_NAME_FONT, 12)
    dragFrame.label:SetTextColor(1, 1, 1)
    dragFrame.label:SetJustifyH("LEFT")
    dragFrame.label:SetPoint("LEFT", 6, 0)
    dragFrame.label:SetPoint("RIGHT", -6, 0)

    of.dragFrame = dragFrame

    return dragFrame
end

local function EnsureListDropIndicator(of)
    if of.dropIndicator then return of.dropIndicator end

    local indicator = of.list:CreateTexture(nil, "OVERLAY")
    indicator:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
    indicator:SetVertexColor(1, 0.82, 0.25, 1)
    indicator:SetHeight(2)
    indicator:Hide()

    of.dropIndicator = indicator

    return indicator
end

local function UpdateListDragVisual(of, v)
    if not of.dragIndex then return end

    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale() or 1
    local dragFrame = EnsureListDragFrame(of, v.entryHeight or 24)
    dragFrame:ClearAllPoints()
    dragFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (cursorX / scale) + 12, (cursorY / scale) - 8)

    local dropIndex = GetListDropIndex(of, v)
    local indicator = EnsureListDropIndicator(of)
    if dropIndex then
        local entryHeight = v.entryHeight or 24
        local visibleIndex = dropIndex - (of.listScrollOffset or 0)
        local values = GetOrderedListValues(of, v)
        local visibleRows = GetListVisibleRows(math.max(#values, 1), v)
        visibleIndex = math.min(math.max(visibleIndex, 1), visibleRows)

        indicator:ClearAllPoints()
        indicator:SetPoint("TOPLEFT", of.list, "TOPLEFT", 0, -((visibleIndex - 1) * entryHeight))
        indicator:SetPoint("TOPRIGHT", of.list, "TOPRIGHT", -LIST_BUTTON_SPACE, -((visibleIndex - 1) * entryHeight))
        indicator:Show()
    else
        indicator:Hide()
    end
end

local function StopListDrag(of, v)
    local fromIndex = of.dragIndex
    local dragRow = of.dragRow

    of.dragIndex = nil
    of.dragRow = nil
    of.list:SetScript("OnUpdate", nil)

    if dragRow then
        dragRow:SetAlpha(1)
    end
    if of.dragFrame then
        of.dragFrame:Hide()
    end
    if of.dropIndicator then
        of.dropIndicator:Hide()
    end
    if not fromIndex then return end

    local toIndex = GetListDropIndex(of, v)
    if not toIndex then return end

    MoveListValue(of, v, fromIndex, toIndex)
end

local function StartListDrag(of, v, row)
    if of.listEnabled == false then return end

    of.dragIndex = row.index
    of.dragRow = row
    row:SetAlpha(0.55)

    local dragFrame = EnsureListDragFrame(of, v.entryHeight or 24)
    dragFrame:SetWidth((of.list:GetWidth() or 260) - LIST_BUTTON_SPACE)
    dragFrame.label:SetText(row.label:GetText() or "")
    dragFrame:Show()

    of.list:SetScript("OnUpdate", function()
        if not IsMouseButtonDown("LeftButton") then
            StopListDrag(of, v)
            return
        end

        UpdateListDragVisual(of, v)
    end)
    UpdateListDragVisual(of, v)
end

local function StopListScrollbarDrag(of)
    if of.listScrollTrack then
        of.listScrollTrack:SetScript("OnUpdate", nil)
    end
end

local function SetListScrollOffsetFromCursor(of, v)
    local values = GetOrderedListValues(of, v)
    local visibleRows = GetListVisibleRows(math.max(#values, 1), v)
    local maxOffset = math.max(#values - visibleRows, 0)
    if maxOffset <= 0 or not of.listScrollTrack or not of.listScrollThumb then return end

    local _, cursorY = GetCursorPosition()
    if not cursorY then return end

    local scale = of.listScrollTrack:GetEffectiveScale() or 1
    local top = of.listScrollTrack:GetTop()
    local trackHeight = of.listScrollTrack:GetHeight()
    local thumbHeight = of.listScrollThumb:GetHeight()
    if not top or not trackHeight or not thumbHeight then return end

    local availableHeight = math.max(trackHeight - thumbHeight, 1)
    local offset = math.min(math.max(top - (cursorY / scale) - (thumbHeight / 2), 0), availableHeight)

    of.listScrollOffset = math.floor((offset / availableHeight) * maxOffset + 0.5)
    ClampListScrollOffset(of, #values, visibleRows)
    of:RefreshList()
end

local function ScrollListOption(of, v, delta)
    local values = GetOrderedListValues(of, v)
    local visibleRows = GetListVisibleRows(math.max(#values, 1), v)

    of.listScrollOffset = (of.listScrollOffset or 0) + (delta > 0 and -1 or 1)

    ClampListScrollOffset(of, #values, visibleRows)
    of:RefreshList()
end

local function StartListScrollbarDrag(of, v)
    if of.listEnabled == false then return end

    SetListScrollOffsetFromCursor(of, v)

    of.listScrollTrack:SetScript("OnUpdate", function()
        if not IsMouseButtonDown("LeftButton") then
            StopListScrollbarDrag(of)
            return
        end

        SetListScrollOffsetFromCursor(of, v)
    end)
end

local function UpdateListScrollbar(of, v, totalRows, visibleRows, entryHeight)
    if not of.listScrollTrack then
        of.listScrollTrack = CreateFrame("Frame", nil, of)
        of.listScrollTrack:EnableMouse(true)
        of.listScrollTrack:EnableMouseWheel(true)
        of.listScrollTrack:SetSize(LIST_SCROLLBAR_WIDTH, 1)

        of.listScrollTrack.bg = of.listScrollTrack:CreateTexture(nil, "BACKGROUND")
        of.listScrollTrack.bg:SetAllPoints()
        of.listScrollTrack.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")

        of.listScrollThumb = CreateFrame("Button", nil, of.listScrollTrack)
        of.listScrollThumb:EnableMouse(true)
        of.listScrollThumb:EnableMouseWheel(true)
        of.listScrollThumb:SetSize(LIST_SCROLLBAR_WIDTH, 1)

        of.listScrollThumb.texture = of.listScrollThumb:CreateTexture(nil, "ARTWORK")
        of.listScrollThumb.texture:SetAllPoints()
        of.listScrollThumb.texture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png")

        for _, frame in ipairs({of.listScrollTrack, of.listScrollThumb}) do
            frame:SetScript("OnMouseDown", function(_, button)
                if button == "LeftButton" then
                    StartListScrollbarDrag(of, v)
                end
            end)
            frame:SetScript("OnMouseUp", function(_, button)
                if button == "LeftButton" then
                    StopListScrollbarDrag(of)
                end
            end)
            frame:SetScript("OnMouseWheel", function(_, delta)
                ScrollListOption(of, v, delta)
            end)
        end
    end

    local showScrollbar = totalRows > visibleRows
    of.listScrollTrack:SetShown(showScrollbar)
    of.listScrollThumb:SetShown(showScrollbar)
    if not showScrollbar then
        StopListScrollbarDrag(of)
        return
    end

    local trackHeight = (visibleRows * entryHeight) - 2
    local thumbHeight = math.max(12, trackHeight * (visibleRows / totalRows))
    local maxOffset = math.max(totalRows - visibleRows, 1)
    local thumbOffset = (trackHeight - thumbHeight) * ((of.listScrollOffset or 0) / maxOffset)

    of.listScrollTrack:ClearAllPoints()
    of.listScrollTrack:SetPoint("TOPLEFT", of.list, "TOPRIGHT", LIST_SCROLLBAR_GAP, -1)
    of.listScrollTrack:SetHeight(trackHeight)

    of.listScrollThumb:ClearAllPoints()
    of.listScrollThumb:SetPoint("TOP", of.listScrollTrack, "TOP", 0, -thumbOffset)
    of.listScrollThumb:SetHeight(thumbHeight)
end

local function CreateListMoveButton(parent, direction)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(20, 20)

    if GW.HandleNextPrevButton then
        GW.HandleNextPrevButton(button, direction, true)
    else
        button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
        button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
        button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
        button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")

        if direction == "down" then
            button:GetNormalTexture():SetRotation(3.14159)
            button:GetPushedTexture():SetRotation(3.14159)
            button:GetDisabledTexture():SetRotation(3.14159)
            button:GetHighlightTexture():SetRotation(3.14159)
        end
    end

    return button
end

local function RefreshListOption(of, v)
    local values = GetOrderedListValues(of, v)
    local labels = BuildListLabelMap(v.optionsList, v.optionsNames)
    local entryHeight = v.entryHeight or 24
    local visibleRows = GetListVisibleRows(math.max(#values, 1), v)
    local listEnabled = of.listEnabled ~= false
    local listTextColor = of.listTextColor or {1, 1, 1}

    ClampListScrollOffset(of, #values, visibleRows)

    of.listRows = of.listRows or {}
    of.list:SetHeight(visibleRows * entryHeight)
    UpdateListScrollbar(of, v, #values, visibleRows, entryHeight)

    for i = 1, #values do
        local row = of.listRows[i]
        if not row then
            row = CreateFrame("Button", nil, of.list)
            row:SetHeight(entryHeight - 2)
            row:EnableMouseWheel(true)

            row.bg = row:CreateTexture(nil, "BACKGROUND")
            row.bg:SetAllPoints()
            row.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
            row.bg:SetAlpha(0.45)

            row:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
            row:GetHighlightTexture():SetAllPoints()

            row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.label:SetFont(UNIT_NAME_FONT, 12)
            row.label:SetTextColor(1, 1, 1)
            row.label:SetJustifyH("LEFT")
            row.label:SetPoint("LEFT", 6, 0)
            row.label:SetPoint("RIGHT", row, "RIGHT", -50, 0)

            row.upButton = CreateListMoveButton(row, "up")
            row.upButton:SetPoint("RIGHT", row, "RIGHT", -24, 0)
            row.upButton:SetScript("OnClick", function(self, button)
                if ShouldHandleIncompatibility(v) and not HandleIncompatibility(v, button, not v.isIncompatibleAddonLoadedButOverride) then
                    return
                end

                MoveListValue(of, v, self:GetParent().index, self:GetParent().index - 1)
            end)

            row.downButton = CreateListMoveButton(row, "down")
            row.downButton:SetPoint("RIGHT", row, "RIGHT", -4, 0)
            row.downButton:SetScript("OnClick", function(self, button)
                if ShouldHandleIncompatibility(v) and not HandleIncompatibility(v, button, not v.isIncompatibleAddonLoadedButOverride) then
                    return
                end

                MoveListValue(of, v, self:GetParent().index, self:GetParent().index + 1)
            end)

            row:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" then
                    StartListDrag(of, v, self)
                end
            end)
            row:SetScript("OnMouseUp", function(_, button)
                if button == "LeftButton" then
                    StopListDrag(of, v)
                end
            end)
            row:SetScript("OnMouseWheel", function(_, delta)
                ScrollListOption(of, v, delta)
            end)

            of.listRows[i] = row
        end

        local visibleIndex = i - (of.listScrollOffset or 0)
        local isVisible = visibleIndex >= 1 and visibleIndex <= visibleRows

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", of.list, "TOPLEFT", 0, -((visibleIndex - 1) * entryHeight))
        row:SetPoint("RIGHT", of.list, "RIGHT", 0, 0)
        row.value = values[i]
        row.index = i
        row.label:SetText(labels[values[i]] or tostring(values[i]))
        row.label:SetTextColor(unpack(listTextColor))
        row:SetShown(isVisible)

        SetListButtonState(row.upButton, listEnabled and i > 1)
        SetListButtonState(row.downButton, listEnabled and i < #values)
    end

    for i = #values + 1, #of.listRows do
        of.listRows[i]:Hide()
    end
end

local function SettingsInitOptionWidget(of, v, panel)
    local t = {}
    for _, path in ipairs{panel.header and panel.header:GetText(), panel.breadcrumb and panel.breadcrumb:GetText()} do
        if path and path ~= "" then t[#t+1] = path end
    end
    of.settingsPath = table.concat(t, "->") .. "->"

    if v.optionType == "dropdown" and v.noNewLine ~= nil and v.noNewLine then
        of.title:Hide()
        of.dropDown:ClearAllPoints()
        of.dropDown:SetPoint("LEFT", 50, 0)
    end

    of:SetScript("OnEnter", function()
        GameTooltip:SetOwner(of, "ANCHOR_CURSOR", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(of.displayName, 1, 1, 1)
        GameTooltip:AddLine(of.desc, 1, 1, 1, true)

        if of.dependenciesInfo and #of.dependenciesInfo > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cffffedba" .. L["Required Settings:"] .. "|r")
            for _, info in ipairs(of.dependenciesInfo) do
                GameTooltip:AddDoubleLine(info.name, info.expected)
            end
        end

        GameTooltip:Show()
    end)
    of:SetScript("OnLeave", GameTooltip_Hide)

    if v.optionType == "colorPicker" then
        local setting = of.get()
        of.button.bg:SetColorTexture(setting.r, setting.g, setting.b)
        of.button:SetScript("OnClick", function()
            if ColorPickerFrame:IsShown() then
                HideUIPanel(ColorPickerFrame)
            else
                ShowColorPicker(of)
            end
        end)
    elseif v.optionType == "dropdown" then
        of.dropDown.OnButtonStateChanged = GW.NoOp
        of.dropDown:GwHandleDropDownBox(nil, nil, nil, 260)
        of.dropDown:HookScript("OnMouseDown", function(_, button)
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, button, not v.isIncompatibleAddonLoadedButOverride) then
                    return
                end
            end
        end)
        of.dropDown:SetSelectionText(function(selections)
            if #selections == 0 then
                return L["No option selected"]
            elseif #selections > 5 then
                return L["More than 5 options selected (#%s)"]:format(#selections)
            end

            local texts = {}
            local text
            for _, selection in ipairs(selections) do
                if not selection:IsSelectionIgnored() then
                    table.insert(texts, MenuUtil.GetElementText(selection))
                end
            end
            if #texts > 0 then
                text = table.concat(texts, LIST_DELIMITER)
            end

            return text
        end)

        of.dropDown:SetupMenu(function(drowpdown, rootDescription)
            local buttonSize = 20
            local maxButtons = 10
            rootDescription:SetScrollMode(buttonSize * maxButtons)

            for idx, option in pairs(v.optionsList) do
                if option == "HEADER" then
                    if idx > 1 then
                        rootDescription:CreateDivider()
                    end
                    local title = rootDescription:CreateTitle(v.optionsNames[idx])
                    title:AddInitializer(function(frame, description, menu)
                        frame.fontString:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
                    end)
                else
                    local function IsSelected(data)
                        if v.hasCheckbox then
                            local isSelected = of.get(data.option)
                            if GW.IsInProfileSwitch and v.callback and isSelected then
                                v.callback(isSelected, data.option)
                            end
                            return isSelected
                        else
                            local isSelected = of.get(data.optionName) == data.option
                            if GW.IsInProfileSwitch and v.callback and isSelected then
                                v.callback(data.option)
                            end
                            return isSelected
                        end
                    end
                    local function SetSelected(data)
                        if v.hasCheckbox then
                            local isSelected = not of.get(data.option)
                            of.set(isSelected, data.option)

                            if v.callback then
                                v.callback(isSelected, data.option)
                            end
                        else
                            of.set(data.option)
                            if v.callback then
                                v.callback(data.option)
                            end
                        end
                        CheckDependencies()
                    end


                    local entryButton
                    if v.hasCheckbox then
                        entryButton = rootDescription:CreateCheckbox(v.optionsNames[idx], IsSelected, SetSelected, {optionName = v.optionName, option = option})
                    else
                        entryButton = rootDescription:CreateRadio(v.optionsNames[idx], IsSelected, SetSelected, {optionName = v.optionName, option = option})
                    end

                    entryButton:AddInitializer(function(button, description, menu)
                        if v.hasCheckbox then
                            GW.BlizzardDropdownCheckButtonInitializer(button, description, menu, IsSelected,  {optionName = v.optionName, option = option})
                        else
                            GW.BlizzardDropdownRadioButtonInitializer(button, description, menu, IsSelected,  {optionName = v.optionName, option = option})
                        end

                        if v.hasSound then
                            local soundButton = MenuTemplates.AttachAutoHideButton(button, "Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on.png")
                            soundButton:SetSize(14, 14)
                            soundButton:SetPoint("RIGHT")
                            soundButton:SetScript("OnClick", function()
                                PlaySoundFile(GW.Libs.LSM:Fetch("sound", option), "Master")
                            end)
                        end
                    end)

                    if v.tooltipType then
                        if v.tooltipType == "spell" then
                            entryButton:SetTooltip(function(tooltip, elementDescription)
                                GameTooltip:SetSpellByID(option)
                            end)
                        elseif v.tooltipType == "encounter" then
                            entryButton:SetTooltip(function(tooltip, elementDescription)
                                local name, desc = EJ_GetEncounterInfo(option)
                                GameTooltip:AddLine(name, 1, 1, 1)
                                GameTooltip:AddLine(desc, 1, 1, 1, true)
                            end)
                        end
                    end
                end
            end
        end)

        of.dropDown.Text:SetFont(UNIT_NAME_FONT, 12)
        of.dropDown:Enable()
        of.dropDown.Text:SetTextColor(1, 1, 1)
    elseif v.optionType == "list" then
        of.title:ClearAllPoints()
        of.title:SetPoint("TOPLEFT", 5, -2)
        of.list:ClearAllPoints()
        of.list:SetPoint("TOPRIGHT", of, "TOPRIGHT", -28, 0)

        of.listEnabled = true
        of.SetListEnabled = function(self, enabled, titleColor)
            self.listEnabled = enabled
            self.listTextColor = {enabled and 1 or 0.4, enabled and 1 or 0.4, enabled and 1 or 0.4, enabled and 1 or 0.4}
            if titleColor then
                self.title:SetTextColor(unpack(titleColor))
            else
                self.title:SetTextColor(enabled and 1 or 0.4, enabled and 1 or 0.4, enabled and 1 or 0.4, enabled and 1 or 0.4)
            end
            self:RefreshList()
        end
        of.RefreshList = function(self)
            RefreshListOption(self, v)
        end
        of.GetListOrder = function(self)
            return GetOrderedListValues(self, v)
        end
        of.list:EnableMouseWheel(true)
        of.list:SetScript("OnMouseUp", function(_, button)
            if button ~= "LeftButton" then return end

            StopListDrag(of, v)
        end)
        of.list:SetScript("OnMouseWheel", function(_, delta)
            ScrollListOption(of, v, delta)
        end)

        of:RefreshList()
    elseif v.optionType == "slider" then
        of.slider:SetMinMaxValues(v.min, v.max)
        of.slider:SetValue(RoundDec(of.get(), of.decimalNumbers))
        if v.step then of.slider:SetValueStep(v.step) end
        of.slider:SetObeyStepOnDrag(true)
        of.slider:SetScript("OnValueChanged", function(self)
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, nil, not v.isIncompatibleAddonLoadedButOverride) then
                    self:SetValue(of.get())
                    return
                end
            end
            local roundValue = RoundDec(self:GetValue(), of.decimalNumbers)

            of.set(tonumber(roundValue))
            self:GetParent().inputFrame.input:SetText(roundValue)
            if v.callback then
                v.callback(tonumber(roundValue))
            end
        end)
        of.inputFrame.input:SetText(RoundDec(of.get(), of.decimalNumbers))
        of.inputFrame.input:SetScript("OnEnterPressed", function(self)
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, nil, not v.isIncompatibleAddonLoadedButOverride) then
                    self:SetText(RoundDec(of.get(), of.decimalNumbers))
                    return
                end
            end

            local roundValue = RoundDec(self:GetNumber(), of.decimalNumbers) or v.min
            self:ClearFocus()
            if tonumber(roundValue) > v.max then self:SetText(v.max) end
            if tonumber(roundValue) < v.min then self:SetText(v.min) end
            roundValue = RoundDec(self:GetNumber(), of.decimalNumbers) or v.min
            if v.step and v.step > 0 then
                local min_value = v.min or 0
                roundValue = floor((roundValue - min_value) / v.step + 0.5) * v.step + min_value
            end
            self:GetParent():GetParent().slider:SetValue(roundValue)
            self:SetText(roundValue)

            of.set(tonumber(roundValue))
            if v.callback then
                v.callback(tonumber(roundValue))
            end
        end)
    elseif v.optionType == "text" then
        of.inputFrame.input:SetText(of.get() or "")
        of.inputFrame.input:SetScript("OnEnterPressed", function(self)
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, nil, not v.isIncompatibleAddonLoadedButOverride) then
                    self:SetText(of.get() or "")
                    return
                end
            end
            self:ClearFocus()
            of.set(self:GetText())
            if v.callback then
                v.callback(self)
            end
        end)
    elseif v.optionType == "boolean" then
        local state = of.get()
        if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
            state = false
        end
        of.checkbutton:SetChecked(state)
        of.checkbutton:SetScript("OnClick", function(self, button)
            local toSet = false
            if self:GetChecked() then
                toSet = true
            end
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, button, toSet) then
                    self:SetChecked(not self:GetChecked())
                    return
                end
            end
            of.set(toSet)

            if v.callback then
                v.callback(toSet, of.optionName)
            end
            --Check all dependencies on this option
            CheckDependencies()
        end)
        of:SetScript("OnClick", function(self, button)
            if not of.checkbutton:IsEnabled() then return end
            local toSet = true
            if self.checkbutton:GetChecked() then
                toSet = false
            end
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, button, toSet) then
                    return
                end
            end
            self.checkbutton:SetChecked(toSet)
            of.set(toSet)

            if v.callback ~= nil then
                v.callback(toSet, of.optionName)
            end
            --Check all dependencies on this option
            CheckDependencies()
        end)
    elseif v.optionType == "button" then
        of:SetScript("OnClick", function(_, button)
            if ShouldHandleIncompatibility(v) then
                if not HandleIncompatibility(v, button, not v.isIncompatibleAddonLoadedButOverride) then
                    return
                end
            end
            if v.callback then
                v.callback()
            end
            --Check all dependencies on this option
            CheckDependencies()
        end)
        of.title:SetTextColor(0, 0, 0)
        of.title:SetShadowColor(0, 0, 0, 0)
    elseif v.optionType == "header" then
        of.title:SetFont(DAMAGE_TEXT_FONT, 16)
    end
end
GW.SettingsInitOptionWidget = SettingsInitOptionWidget

local function SettingsMenuButtonSetUp(self, odd)
    self.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    end

    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
end
GW.SettingsMenuButtonSetUp = SettingsMenuButtonSetUp
