local _, GW = ...
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

                    local expectedText = ""
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

    if deactivateColor then
        color = {0.82, 0, 0}
        inputColor = color
        enabled = false
    elseif overrideColor then
        color = {1, 0.65, 0}
        inputColor = color
        enabled = false
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

local function HandleIncompatibility(v, button)
    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
        if IsControlKeyDown() and (button and button == "LeftButton" or button == nil) then
            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                GW.SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                GW.SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
            end
        end
        return true
    end
    return false
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
        of.dropDown:HookScript("OnMouseDown", function(_, button) HandleIncompatibility(v, button) end)
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
        end)

        of.dropDown.Text:SetFont(UNIT_NAME_FONT, 12)
        of.dropDown:Enable()
        of.dropDown.Text:SetTextColor(1, 1, 1)
    elseif v.optionType == "slider" then
        of.slider:SetMinMaxValues(v.min, v.max)
        of.slider:SetValue(RoundDec(of.get(), of.decimalNumbers))
        if v.step then of.slider:SetValueStep(v.step) end
        of.slider:SetObeyStepOnDrag(true)
        of.slider:SetScript("OnValueChanged", function(self)
            if HandleIncompatibility(v) then
                self:SetValue(of.get())
            else
                local roundValue = RoundDec(self:GetValue(), of.decimalNumbers)

                of.set(tonumber(roundValue))
                self:GetParent().inputFrame.input:SetText(roundValue)
                if v.callback then
                    v.callback(tonumber(roundValue))
                end
            end
        end)
        of.inputFrame.input:SetText(RoundDec(of.get(), of.decimalNumbers))
        of.inputFrame.input:SetScript("OnEnterPressed", function(self)
            if HandleIncompatibility(v) then
                self:SetText(RoundDec(of.get(), of.decimalNumbers))
            else
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
            end
        end)
    elseif v.optionType == "text" then
        of.inputFrame.input:SetText(of.get() or "")
        of.inputFrame.input:SetScript("OnEnterPressed", function(self)
            if HandleIncompatibility(v) then
                self:SetText(of.get() or "")
            else
                self:ClearFocus()
                of.set(self:GetText())
                if v.callback then
                    v.callback(self)
                end
            end
        end)
    elseif v.optionType == "boolean" then
        local state = of.get()
        if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
            state = false
        end
        of.checkbutton:SetChecked(state)
        of.checkbutton:SetScript("OnClick", function(self, button)
            if HandleIncompatibility(v, button) then
                self:SetChecked(not self:GetChecked())
            else
                local toSet = false
                if self:GetChecked() then
                    toSet = true
                end
                of.set(toSet)

                if v.callback then
                    v.callback(toSet, of.optionName)
                end
                --Check all dependencies on this option
                CheckDependencies()
            end
        end)
        of:SetScript("OnClick", function(self, button)
            if not of.checkbutton:IsEnabled() then return end
            if not HandleIncompatibility(v, button) then
                local toSet = true
                if self.checkbutton:GetChecked() then
                    toSet = false
                end
                self.checkbutton:SetChecked(toSet)
                of.set(toSet)

                if v.callback ~= nil then
                    v.callback(toSet, of.optionName)
                end
                --Check all dependencies on this option
                CheckDependencies()
            end
        end)
    elseif v.optionType == "button" then
        of:SetScript("OnClick", function(_, button)
            if not HandleIncompatibility(v, button) then
                if v.callback then
                    v.callback()
                end
                --Check all dependencies on this option
                CheckDependencies()
            end
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
