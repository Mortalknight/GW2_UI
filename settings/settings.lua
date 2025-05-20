local _, GW = ...
local L = GW.L
local SetOverrideIncompatibleAddons = GW.SetOverrideIncompatibleAddons
local RoundDec = GW.RoundDec
local AddForProfiling = GW.AddForProfiling
local AddToAnimation
local lerp

local settings_cat = {}
local optionReference = {}
local panelUniqueID = 0
local optionTypes = {
    boolean     = {template = "GwOptionBoxTmpl", frame = "Button", newLine = false},
    slider      = {template = "GwOptionBoxSliderTmpl", frame = "Button", newLine = true},
    dropdown    = {template = "GwOptionBoxDropDownTmpl", frame = "Button", newLine = true},
    text        = {template = "GwOptionBoxTextTmpl", frame = "Button", newLine = true},
    button      = {template = "GwButtonTextTmpl", frame = "Button", newLine = true},
    colorPicker = {template = "GwOptionBoxColorPickerTmpl", frame = "Button", newLine = true},
    header      = {template = "GwOptionBoxHeader", frame = "Frame", newLine = true},
}

--helper functions for settings
function CreateSettingProxy(fullPath, isPrivateSetting, isMultiselect)
    local keys = {}
    for key in string.gmatch(fullPath, "[^%.]+") do
        table.insert(keys, key)
    end

    return {
        get = function(optionKey)
            local ref = (isPrivateSetting and GW.private) or GW.settings
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

local function getSettingsCat()
return settings_cat
end
GW.getSettingsCat = getSettingsCat

local function getOptionReference()
return optionReference
end
GW.getOptionReference = getOptionReference

local function switchCat(index)
    for _, l in ipairs(settings_cat) do
        l.iconbg:SetTexCoord(0.505, 1, 0, 0.625)
        l.cat_panel:Hide()
    end
    local l = settings_cat[index]
    if l then
        l.iconbg:SetTexCoord(0, 0.5, 0, 0.625)
        if index == 2 and GW.lastSelectedSettingsMenuCategorie and GW.lastSelectedSettingsMenuCategorie.button and GW.lastSelectedSettingsMenuCategorie.basePanel then -- Index = 2 is Settings Panel
            l.cat_panel:Show()
            GW.ResetSettingsMenuCategories(false)
            GW.SwitchSettingsMenuCategorie(GW.lastSelectedSettingsMenuCategorie.button, GW.lastSelectedSettingsMenuCategorie.basePanel, GW.lastSelectedSettingsMenuCategorie.panelFrame)

            UIFrameFadeIn(GW.lastSelectedSettingsMenuCategorie.basePanel, 0.2, 0, 1)
        else
            l.cat_panel:Show()

            if l.cat_crollFrames then
                for _, v in pairs(l.cat_crollFrames) do
                    v.scroll.slider:SetShown((v.scroll.maxScroll~=nil and v.scroll.maxScroll > 0))
                    v.scroll.scrollUp:SetShown((v.scroll.maxScroll~=nil and v.scroll.maxScroll > 0))
                    v.scroll.scrollDown:SetShown((v.scroll.maxScroll~=nil and v.scroll.maxScroll > 0))
                end
            end

            UIFrameFadeIn(l.cat_panel, 0.2, 0, 1)
        end
    end
end
GW.SettingsFrameSwitchCategorieModule = switchCat
AddForProfiling("settings", "switchCat", switchCat)

local fnF_OnClick = function(self)
    switchCat(self.cat_id)
end
AddForProfiling("settings", "fnF_OnClick", fnF_OnClick)

local visible_cat_button_id  = 0
local function CreateCat(name, desc, panel, scrollFrames, visibleTabButton, icon)
    local i = #settings_cat + 1
    -- create and position a new button/label for this category
    local f = CreateFrame("Button", nil, GwSettingsWindow, "GwSettingsLabelTmpl")
    f.cat_panel = panel
    f.cat_name = name
    f.cat_desc = desc
    f.cat_id = i
    f.cat_crollFrames = scrollFrames
    settings_cat[i] = f
    f:SetPoint("TOPRIGHT", GwSettingsWindow, "TOPLEFT", 1, -32 + (-40 * visible_cat_button_id))

    if not visibleTabButton then
        f:Hide()
    else
        visible_cat_button_id = visible_cat_button_id + 1
    end

    if icon then
        f.iconbg:SetTexture(icon)
    end

    f:SetScript("OnClick", fnF_OnClick)
end
GW.CreateCat = CreateCat

local function CreateOption(optionType, panel, name, desc, values)
    if not panel then return end
    values = values or {}

    panel.gwOptions = panel.gwOptions or {}

    local opt = {
        name = name,
        desc = desc or "",
        optionName = values.getterSetter,
        optionType = optionType,
        callback = values.callback,
        dependence = values.dependence,
        forceNewLine = values.forceNewLine,
        incompatibleAddonsType = values.incompatibleAddons,
        isIncompatibleAddonLoaded = false,
        isIncompatibleAddonLoadedButOverride = false,
        groupHeaderName = values.groupHeaderName,
        isPrivateSetting = values.isPrivateSetting
    }

    if values.getterSetter then
        local proxy = CreateSettingProxy(values.getterSetter, values.isPrivateSetting, values.checkbox)
        opt.get = proxy.get
        opt.set = proxy.set
        opt.getDefault = proxy.getDefault
    end

    if values.params then
        for k, v in pairs(values.params) do opt[k] = v end
    end

    table.insert(panel.gwOptions, opt)

    if values and values.incompatibleAddons then
        local isIncompatibleAddonLoaded, whichAddonsLoaded, isOverride = GW.IsIncompatibleAddonLoadedOrOverride(values.incompatibleAddons)
        if isIncompatibleAddonLoaded and not isOverride then
            opt.desc = desc .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt.isIncompatibleAddonLoaded = true
        elseif isIncompatibleAddonLoaded and isOverride then
            opt.desc = desc .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffffa500" ..  L["You have overridden this behavior."] .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt.isIncompatibleAddonLoaded = false
            opt.isIncompatibleAddonLoadedButOverride = true
        end
    end

    return opt
end

local function AddOption(panel, name, desc, values)
    return CreateOption("boolean", panel, name, desc, values)
end
GW.AddOption = AddOption

local function AddOptionButton(panel, name, desc, values)
    return CreateOption("button", panel, name, desc, values)
end
GW.AddOptionButton = AddOptionButton

local function AddGroupHeader(panel, name)
    return CreateOption("header", panel, name)
end
GW.AddGroupHeader = AddGroupHeader

local function AddOptionColorPicker(panel, name, desc, values)
    return CreateOption("colorPicker", panel, name, desc, values)
end
GW.AddOptionColorPicker = AddOptionColorPicker

local function AddOptionSlider(panel, name, desc, values)
    local opt = CreateOption("slider", panel, name, desc, values)
    opt.min = values.min
    opt.max = values.max
    opt.decimalNumbers = values.decimalNumbers or 0
    opt.step = values.step

    return opt
end
GW.AddOptionSlider = AddOptionSlider

local function AddOptionText(panel, name, desc, values)
    local opt = CreateOption("text", panel, name, desc, values)
    opt.multiline = values.multiline

    return opt
end
GW.AddOptionText = AddOptionText

local function AddOptionDropdown(panel, name, desc, values)
    local opt = CreateOption("dropdown", panel, name, desc, values)

    opt.optionsList = values.optionsList
    opt.optionsNames = values.optionNames
    opt.hasCheckbox = values.checkbox
    opt.tooltipType = values.tooltipType
    opt.hasSound = values.isSound
    opt.noNewLine = values.noNewLine

    return opt
end
GW.AddOptionDropdown = AddOptionDropdown

local function getOptionFrame(settingName)
    for _, panel in pairs(GW.getOptionReference()) do
        for _, of in pairs(panel.options) do
            if of.optionName == settingName then
                return of
            end
        end
    end
end

local function setDependenciesOption(type, settingName, SetEnable, deactivateColor, overrideColor)
    local of = getOptionFrame(settingName)
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
    end
end

local function checkDependenciesOnLoad()
    for _, panel in pairs(GW.getOptionReference()) do
        for _, v in pairs(panel.options) do
            if v.isIncompatibleAddonLoaded then
                local override = v.isIncompatibleAddonLoadedButOverride == true
                setDependenciesOption(v.optionType, v.optionName, false, not override, override)
            elseif v.dependence then
                local allDepsMet = true

                for settingName, expectedValue in pairs(v.dependence) do
                    local of = getOptionFrame(settingName)
                    local currentVal = (of and of.get and of.get())

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
    end
end

local function ColorPickerFrameCallback(restore, frame, buttonBackground)
    if ColorPickerFrame.noColorCallback then return end
    local newR, newG, newB
    if restore then
    -- The user bailed, we extract the old color from the table created by ShowColorPicker.
    newR, newG, newB = unpack(restore)
    else
    -- Something changed
    newR, newG, newB = ColorPickerFrame.Content.ColorPicker:GetColorRGB()
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
    ColorPickerFrame.Content.ColorPicker:SetColorRGB(color.r, color.g, color.b)
    ColorPickerFrame.hasOpacity = (color.a ~= nil)
    ColorPickerFrame.opacity = color.a
    ColorPickerFrame.previousValues = {color.r, color.g, color.b, color.a}
    ColorPickerFrame.func = function() ColorPickerFrameCallback(nil, frame, frame.button.bg) end
    ColorPickerFrame.opacityFunc = function() ColorPickerFrameCallback(nil, frame, frame.button.bg) end
    ColorPickerFrame.cancelFunc = function(restore) ColorPickerFrameCallback(restore, frame, frame.button.bg) end

    if frame.getDefault then
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

local function updateSettingsFrameSettingsValue(setting, value, setSetting)
    local of = getOptionFrame(setting)
    if not of then return end

    if setSetting then
        of.set(value)
    end
    if of.optionType == "slider" then
        of.slider:SetValue(value)
        of.inputFrame.input:SetText(RoundDec(value, of.decimalNumbers))
    end
end
GW.updateSettingsFrameSettingsValue = updateSettingsFrameSettingsValue

local function RefreshSettingsAfterProfileSwitch()
    GW.disableGridUpdate = true
    GW.IsInProfileSwitch = true
    for _, panel in pairs(GW.getOptionReference()) do
        for _, of in pairs(panel.options) do
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
                of.inputFrame.input(of.get() or "")
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
    end
    checkDependenciesOnLoad()
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
                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
            end
        end
        return true
    end
    return false
end

local function InitPanel(panel, hasScroll)
    if not panel then return end

    local parent = hasScroll and panel.scroll.scrollchild or panel
    local options = parent.gwOptions
    if not options then return end
    panelUniqueID = panelUniqueID + 1

    local padding = {x = 8, y = hasScroll and 0 or panel.sub:GetText() and -55 or -35}
    local pY = -48
    local maxWidth = 440
    local first = true
    local lastOptionName
    local numRows = 1

    for _, v in ipairs(options) do
        local conf = optionTypes[v.optionType]
        if conf then
            local newLine = v.forceNewLine ~= nil and v.forceNewLine or conf.newLine
            if v.optionType == "dropdown" and v.noNewLine ~= nil then
                newLine = not v.noNewLine
            end

            local of = CreateFrame(conf.frame, nil, parent, conf.template)

            -- Panel Info
            local headerText = panel.header:GetText()
            local breadcrumbText = panel.breadcrumb and panel.breadcrumb:GetText() or ""
            optionReference[panelUniqueID] = optionReference[panelUniqueID] or {
                header = headerText,
                breadCrumb = breadcrumbText,
                options = {},
            }
            table.insert(optionReference[panelUniqueID].options, of)

            -- Shared setup
            of.displayName = v.name or lastOptionName
            lastOptionName = of.displayName
            for k, val in pairs(v) do
                of[k] = val
                print(k)
            end
            of.newLine = newLine

            if (newLine and not first) or padding.x > maxWidth then
                padding.y = padding.y + (pY + 8)
                padding.x = 8
                numRows = numRows + 1
            end
            first = false

            -- Position
            of:ClearAllPoints()
            of:SetPoint("TOPLEFT", parent, "TOPLEFT", padding.x, padding.y)

            of.title:SetFont(DAMAGE_TEXT_FONT, 12)
            of.title:SetTextColor(1, 1, 1)
            of.title:SetShadowColor(0, 0, 0, 1)
            of.title:SetText(of.displayName)

            if v.optionType == "dropdown" and v.noNewLine ~= nil and v.noNewLine then
                of.title:Hide()
                of.dropDown:ClearAllPoints()
                of.dropDown:SetPoint("LEFT", 50, 0)
            end

            of:SetScript("OnEnter", function()
                GameTooltip:SetOwner(of, "ANCHOR_CURSOR", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(v.name, 1, 1, 1)
                GameTooltip:AddLine(v.desc, 1, 1, 1, true)
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
                                if GW.IsInProfileSwitch and v.callback then
                                    v.callback(isSelected, data.option)
                                end
                                return isSelected
                            else
                                if GW.IsInProfileSwitch and v.callback then
                                    v.callback(data.option)
                                end
                                return of.get(data.optionName) == data.option
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
                            checkDependenciesOnLoad()
                        end

                        local entryButton
                        if v.hasCheckbox then
                            entryButton = rootDescription:CreateCheckbox(v.optionsNames[idx], IsSelected, SetSelected, {optionName = v.optionName, option = option})
                        else
                            entryButton = rootDescription:CreateRadio(v.optionsNames[idx], IsSelected, SetSelected, {optionName = v.optionName, option = option})
                        end

                        entryButton:AddInitializer(function(button, description, menu)
                            if v.hasCheckbox then
                                GW.BlizzardDropdownCheckButtonInitializer(button, description, menu)
                            else
                                GW.BlizzardDropdownRadioButtonInitializer(button, description, menu)
                            end

                            if v.hasSound then
                                local soundButton = MenuTemplates.AttachAutoHideButton(button, "Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on")
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
                            v.callback()
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
                            v.callback()
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
                of.checkbutton:SetChecked(of.get())
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
                        checkDependenciesOnLoad()
                    end
                end)
                of:SetScript("OnClick", function(self, button)
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
                        checkDependenciesOnLoad()
                    end
                end)
            elseif v.optionType == "button" then
                of:SetScript("OnClick", function(_, button)
                    if not HandleIncompatibility(v, button) then
                        if v.callback then
                            v.callback()
                        end
                        --Check all dependencies on this option
                        checkDependenciesOnLoad()
                    end
                end)
                of.title:SetTextColor(0, 0, 0)
                of.title:SetShadowColor(0, 0, 0, 0)
            elseif v.optionType == "header" then
                of.title:SetFont(DAMAGE_TEXT_FONT, 16)
            end

            padding.x = newLine and maxWidth + 10 or padding.x + of:GetWidth() + 8
        end
    end

    -- Scrollbar setup
    if hasScroll then
        local scrollHeight = panel:GetHeight()
        local maxScroll = math.max(0, numRows * 40 - scrollHeight + 50)
        local scroll = panel.scroll
        scroll:SetScrollChild(scroll.scrollchild)
        scroll.scrollchild:SetHeight(scrollHeight)
        scroll.scrollchild:SetWidth(scroll:GetWidth() - 20)
        scroll.slider:SetMinMaxValues(0, maxScroll)
        scroll.slider.thumb:SetHeight(scroll.slider:GetHeight() * (scroll:GetHeight() / (maxScroll + scroll:GetHeight())))
        scroll.slider:SetValue(1)
        scroll.maxScroll = maxScroll
        scroll.doNotHide = false
    end
end
GW.InitPanel = InitPanel

local function LoadSettings()
    --GwSettingsWindow
    local mf = CreateFrame("Frame", "GwSettingsMoverFrame", UIParent, "GwSettingsMoverFrame")
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", function(self) self:StartMoving() end)
    mf:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local sWindow = CreateFrame("Frame", "GwSettingsWindow", UIParent, "GwSettingsWindowTmpl")
    GW.loadSettingsSearchAbleMenu()
    sWindow:SetClampedToScreen(true)
    tinsert(UISpecialFrames, "GwSettingsWindow")

    mf:SetFrameLevel(sWindow:GetFrameLevel() + 100)
    mf:SetClampedToScreen(true)
    mf:SetClampRectInsets(0, 0, 0, -sWindow:GetHeight())

    sWindow:SetScript("OnShow", function()
        mf:Show()
        -- Check UI Scale
        if GetCVarBool("useUiScale") then
            _G["PIXEL_PERFECTION"].checkbutton:SetChecked(false)
        end

        checkDependenciesOnLoad()
    end)
    sWindow:SetScript("OnHide", function()
        mf:Hide()
        if not GW.InMoveHudMode and GW.ShowRlPopup then
            StaticPopup_Show("CONFIG_RELOAD")
            GW.ShowRlPopup = false
        end
    end)
    sWindow:SetScript( "OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" and self:IsShown() then
            self:Hide()
            mf:Hide()
            GW.Notice(L["Settings are not available in combat!"])
            sWindow.wasOpen = true
        elseif event == "PLAYER_REGEN_ENABLED" and self.wasOpen then
            self:Show()
            mf:Show()
            sWindow.wasOpen = false
        end
    end)
    sWindow:RegisterEvent("PLAYER_REGEN_DISABLED")
    sWindow:RegisterEvent("PLAYER_REGEN_ENABLED")
    mf:Hide()

    sWindow.backgroundMask = UIParent:CreateMaskTexture()
    sWindow.backgroundMask:SetPoint("TOPLEFT", sWindow, "TOPLEFT", -64, 64)
    sWindow.backgroundMask:SetPoint("BOTTOMRIGHT", sWindow, "BOTTOMLEFT",-64, 0)
    sWindow.backgroundMask:SetTexture("Interface/AddOns/GW2_UI/textures/masktest", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    sWindow.background:AddMaskTexture(sWindow.backgroundMask)

    sWindow:HookScript("OnShow", function()
        if AddToAnimation == nil then
            AddToAnimation = GW.AddToAnimation
            lerp = GW.lerp
        end

        AddToAnimation("SETTINGSFRAME_PANEL_ONSHOW",
            0,
            1,
            GetTime(),
            GW.WINDOW_FADE_DURATION,
            function(p)
                sWindow:SetAlpha(p)
                sWindow.backgroundMask:SetPoint("BOTTOMRIGHT", sWindow.background, "BOTTOMLEFT", lerp(-64, sWindow.background:GetWidth(), p) , 0)
            end,
            1,
            function()
                sWindow.backgroundMask:SetPoint("BOTTOMRIGHT", sWindow.background, "BOTTOMLEFT", sWindow.background:GetWidth() + 200, 0)
            end
        )
    end)

    GW.LoadOverviewPanel(sWindow)
    GW.LoadModulesPanel(sWindow)
    GW.LoadGeneralPanel(sWindow)
    GW.LoadPlayerPanel(sWindow)
    GW.LoadTargetPanel(sWindow)
    GW.LoadActionbarPanel(sWindow)
    GW.LoadHudPanel(sWindow)
    GW.LoadObjectivesPanel(sWindow)
    GW.LoadFontsPanel(sWindow)
    GW.LoadChatPanel(sWindow)
    GW.LoadTooltipPanel(sWindow)
    GW.LoadPartyPanel(sWindow)
    GW.LoadRaidPanel(sWindow)
    GW.LoadAurasPanel(sWindow)
    GW.LoadNotificationsPanel(sWindow)
    GW.LoadSkinsPanel(sWindow)
    GW.LoadProfilesPanel(sWindow)

    checkDependenciesOnLoad()

    sWindow.close:SetScript("OnClick", function(self) self:GetParent():Hide() end)

    switchCat(1)
    sWindow:Hide()
end
GW.LoadSettings = LoadSettings
