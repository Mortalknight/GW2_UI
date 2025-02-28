local _, GW = ...
local L = GW.L
local SetOverrideIncompatibleAddons = GW.SetOverrideIncompatibleAddons
local RoundDec = GW.RoundDec
local AddForProfiling = GW.AddForProfiling
local AddToAnimation
local lerp

local settings_cat = {}
local all_options = {}
local optionReference = {}

--helper functions for settings
local function getSettingsCat()
  return settings_cat
end
GW.getSettingsCat = getSettingsCat;

local function getOptionReference()
  return optionReference
end
GW.getOptionReference = getOptionReference;

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

local fnF_OnEnter = function(self)
--    self.icon:SetBlendMode("ADD")
    GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -40)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(self.cat_name, 1, 1, 1)
    GameTooltip:AddLine(self.cat_desc, 1, 1, 1)
    GameTooltip:Show()
end
AddForProfiling("settings", "fnF_OnEnter", fnF_OnEnter)

local fnF_OnLeave = function(self)
  --  self.icon:SetBlendMode("BLEND")
    GameTooltip_Hide(self)
end
AddForProfiling("settings", "fnF_OnLeave", fnF_OnLeave)

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

local function AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName, isPrivateSetting)
    if not panel then
        return
    end
    if not panel.gwOptions then
        panel.gwOptions = {}
    end

    local opt = {}
    opt.name = name
    opt.desc = desc
    opt.optionName = optionName
    opt.optionType = "boolean"
    opt.callback = callback
    opt.dependence = dependence
    opt.forceNewLine = forceNewLine
    opt.incompatibleAddonsType = incompatibleAddons
    opt.isIncompatibleAddonLoaded = false
    opt.isIncompatibleAddonLoadedButOverride = false
    opt.groupHeaderName = groupHeaderName
    opt.isPrivateSetting = isPrivateSetting

    if params then
        for k, v in pairs(params) do opt[k] = v end
    end

    panel.gwOptions[#panel.gwOptions + 1] = opt
    all_options[#all_options + 1] = opt

    if incompatibleAddons then
        local isIncompatibleAddonLoaded, whichAddonsLoaded, isOverride = GW.IsIncompatibleAddonLoadedOrOverride(incompatibleAddons)
        if isIncompatibleAddonLoaded and not isOverride then
            opt.desc = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt.isIncompatibleAddonLoaded = true
        elseif isIncompatibleAddonLoaded and isOverride then
            opt.desc = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffffa500" ..  L["You have overridden this behavior."] .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt.isIncompatibleAddonLoaded = false
            opt.isIncompatibleAddonLoadedButOverride = true
        end
    end

    return opt
end
GW.AddOption = AddOption

local function AddOptionButton(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons, groupHeaderName, isPrivateSetting)
    if not panel then
        return
    end
    if not panel.gwOptions then
        panel.gwOptions = {}
    end

    local opt = {}
    opt.name = name
    opt.desc = desc
    opt.optionName = optionName
    opt.optionType = "button"
    opt.callback = callback
    opt.dependence = dependence
    opt.incompatibleAddonsType = incompatibleAddons
    opt.isIncompatibleAddonLoaded = false
    opt.isIncompatibleAddonLoadedButOverride = false
    opt.groupHeaderName = groupHeaderName
    opt.isPrivateSetting = isPrivateSetting

    if params then
        for k, v in pairs(params) do opt[k] = v end
    end

    panel.gwOptions[#panel.gwOptions + 1] = opt
    all_options[#all_options + 1] = opt

    if incompatibleAddons then
        local isIncompatibleAddonLoaded, whichAddonsLoaded, isOverride = GW.IsIncompatibleAddonLoadedOrOverride(incompatibleAddons)
        if isIncompatibleAddonLoaded and not isOverride then
            opt.desc = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt.isIncompatibleAddonLoaded = true
        elseif  isIncompatibleAddonLoaded and isOverride then
            opt.desc = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffffa500" ..  L["You have overridden this behavior."] .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt.isIncompatibleAddonLoaded = false
            opt.isIncompatibleAddonLoadedButOverride = true
        end
    end

    return opt
end
GW.AddOptionButton = AddOptionButton

local function AddGroupHeader(panel, name)
    local opt = AddOption(panel, name)

    opt.optionType = "header"

    return opt
end
GW.AddGroupHeader = AddGroupHeader

local function AddOptionColorPicker(panel, name, desc, optionName, getterSetter, default, callback, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName)

    opt.optionType = "colorPicker"
    opt.getterSetter = getterSetter
    opt.default = default

    return opt
end
GW.AddOptionColorPicker = AddOptionColorPicker

local function AddOptionSlider(panel, name, desc, optionName, callback, min, max, params, decimalNumbers, dependence, step, incompatibleAddons, forceNewLine, groupHeaderName, isPrivateSetting)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName, isPrivateSetting)

    opt.min = min
    opt.max = max
    opt.decimalNumbers = decimalNumbers or 0
    opt.step = step
    opt.optionType = "slider"

    return opt
end
GW.AddOptionSlider = AddOptionSlider

local function AddOptionText(panel, name, desc, optionName, callback, multiline, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName, isPrivateSetting)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName, isPrivateSetting)

    opt.multiline = multiline
    opt.optionType = "text"
end
GW.AddOptionText = AddOptionText

local function AddOptionDropdown(panel, name, desc, optionName, callback, options_list, option_names, params, dependence, checkbox, incompatibleAddons, tooltipType, isSound, noNewLine, forceNewLine, groupHeaderName, isPrivateSetting, isFont)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons, forceNewLine, groupHeaderName, isPrivateSetting)

    opt.options = {}
    opt.options = options_list
    opt.options_names = option_names
    opt.hasCheckbox = checkbox
    opt.optionType = "dropdown"
    opt.tooltipType = tooltipType
    opt.hasSound = isSound
    opt.noNewLine = noNewLine
    opt.isFont = isFont
end
GW.AddOptionDropdown = AddOptionDropdown

local function setDependenciesOption(type, name, SetEnable, deactivateColor, overrideColor)
    if deactivateColor then
        _G[name].title:SetTextColor(0.82, 0, 0)
        if type == "slider" then
            _G[name].inputFrame.input:SetTextColor(0.82, 0, 0)
        elseif type == "text" then
            _G[name].inputFrame.input:SetTextColor(0.82, 0, 0)
        elseif type == "dropdown" then
            _G[name].dropDown.Text:SetTextColor(0.82, 0, 0)
        end
    elseif overrideColor then
        _G[name].title:SetTextColor(1, 0.65, 0)
        if type == "slider" then
            _G[name].inputFrame.input:SetTextColor(1, 0.65, 0)
        elseif type == "text" then
            _G[name].inputFrame.input:SetTextColor(1, 0.65, 0)
        elseif type == "dropdown" then
            _G[name].dropDown.Text:SetTextColor(1, 0.65, 0)
        end
    elseif SetEnable then
        _G[name].title:SetTextColor(1, 1, 1)
        if type == "boolean" then
            _G[name]:Enable()
            _G[name].checkbutton:Enable()
        elseif type == "slider" then
            _G[name].slider:Enable()
            _G[name].inputFrame.input:Enable()
            _G[name].inputFrame.input:SetTextColor(0.82, 0.82, 0.82)
        elseif type == "text" then
            _G[name].inputFrame.input:Enable()
            _G[name].inputFrame.input:SetTextColor(1, 1, 1)
        elseif type == "dropdown" then
            _G[name].dropDown:Enable()
            _G[name].dropDown.Text:SetTextColor(1, 1, 1)
        elseif type == "button" then
            _G[name]:Enable()
            _G[name].title:SetTextColor(0, 0, 0)
        elseif type == "colorPicker" then
            _G[name].button:Enable()
        end
    else
        _G[name].title:SetTextColor(0.4, 0.4, 0.4)
        if type == "boolean" then
            _G[name]:Disable()
            _G[name].checkbutton:Disable()
        elseif type == "slider" then
            _G[name].slider:Disable()
            _G[name].inputFrame.input:Disable()
            _G[name].inputFrame.input:SetTextColor(0.4, 0.4, 0.4)
        elseif type == "text" then
            _G[name].inputFrame.input:Disable()
            _G[name].inputFrame.input:SetTextColor(0.4, 0.4, 0.4)
        elseif type == "dropdown" then
            _G[name].dropDown:Disable()
            _G[name].dropDown.Text:SetTextColor(0.4, 0.4, 0.4)
        elseif type == "button" then
            _G[name]:Disable()
        elseif type == "colorPicker" then
            _G[name].button:Disable()
        end
    end
end

local function checkDependenciesOnLoad()
    local allOptionsSet = false

    for _, v in pairs(all_options) do
        if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
            if v.isIncompatibleAddonLoadedButOverride then
                setDependenciesOption(v.optionType, v.optionName, false, false, true)
            else
                setDependenciesOption(v.optionType, v.optionName, false, true)
            end
        elseif v.dependence then
            allOptionsSet = false
            for sn, sv in pairs(v.dependence) do
                if type(sv) == "table" then
                    for _, dv in ipairs(sv) do
                        allOptionsSet = false
                        local isPrivateDependecy = GW.private[sn] ~= nil
                        if isPrivateDependecy and GW.private[sn] == dv or GW.settings[sn] == dv then
                            allOptionsSet = true
                            break
                        end
                    end
                else
                    local isPrivateDependecy = GW.private[sn] ~= nil
                    if isPrivateDependecy and GW.private[sn] == sv or GW.settings[sn] == sv then
                        allOptionsSet = true
                    else
                        allOptionsSet = false
                        break
                    end
                end
                if not allOptionsSet then break end
            end
            setDependenciesOption(v.optionType, v.optionName, allOptionsSet)
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

    local color = frame.getterSetter
    local changed = color.r ~= newR or color.g ~= newG or color.b ~= newB
    color.r = newR
    color.g = newG
    color.b = newB
    frame.getterSetter = color
    buttonBackground:SetColorTexture(newR, newG, newB)

    if frame.callback then
        frame.callback(newR, newG, newB, changed)
    end
end

local function ShowColorPicker(frame)
    local r, g, b = frame.getterSetter.r, frame.getterSetter.g, frame.getterSetter.b
    ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
    ColorPickerFrame.hasOpacity = (frame.getterSetter.a ~= nil)
    ColorPickerFrame.opacity = frame.getterSetter.a
    ColorPickerFrame.previousValues = {r, g, b, frame.getterSetter.a}
    ColorPickerFrame.func = function() ColorPickerFrameCallback(nil, frame, frame.button.bg) end
    ColorPickerFrame.opacityFunc = function() ColorPickerFrameCallback(nil, frame, frame.button.bg) end
    ColorPickerFrame.cancelFunc = function(restore) ColorPickerFrameCallback(restore, frame, frame.button.bg) end

    if frame.default then
        if not GwColorPPDefault.defaultColor then
            GwColorPPDefault.defaultColor = {}
        end

        GwColorPPDefault.defaultColor = frame.default
    end
    ColorPickerFrame:Show()
    ColorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG')
    ColorPickerFrame:SetClampedToScreen(true)
    ColorPickerFrame:Raise()
end

local function updateSettingsFrameSettingsValue(setting, value, setSetting)
    local found = false
    for _, panel in pairs(GW.getOptionReference()) do
        for _, of in pairs(panel.options) do
            if of.optionName == setting then
                if setSetting then
                    if of.isPrivateSetting then
                        GW.private[setting] = value
                    else
                        GW.settings[setting] = value
                    end
                end
                if of.optionType == "slider" then
                    of.slider:SetValue(value)
                    of.inputFrame.input:SetText(RoundDec(value, of.decimalNumbers))
                end

                found = true
                break
            end
        end
        if found then break end
    end
end
GW.updateSettingsFrameSettingsValue = updateSettingsFrameSettingsValue

local function RefreshSettingsAfterProfileSwitch()
    GW.disableGridUpdate = true
    GW.IsInProfileSwitch = true
    for _, panel in pairs(GW.getOptionReference()) do
        for _, of in pairs(panel.options) do
            if of.optionType == "slider" then
                of.slider:SetValue(RoundDec((of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName]), of.decimalNumbers))
                of.inputFrame.input:SetText(RoundDec(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName], of.decimalNumbers))
                if of.callback then
                    of.callback()
                end
            elseif of.optionType == "boolean" then
                of.checkbutton:SetChecked(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName])
                if of.callback then
                    local toSet = of.checkbutton:GetChecked()
                    of.callback(toSet, of.optionName)
                end
            elseif of.optionType == "text" then
                of.inputFrame.input:SetText(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName] or "")
                if of.callback then
                    of.callback(of.inputFrame.input)
                end
            elseif of.optionType == "colorPicker" then
                local color = of.getterSetter -- here we have a setter/getter like GW.settings.SETTINGNAME
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

local panelUniqueID = 0
local function InitPanel(panel, hasScroll)
    panelUniqueID = panelUniqueID + 1
    if not panel or not (hasScroll and panel.scroll.scrollchild.gwOptions or panel.gwOptions) then
        return
    end
    local options = hasScroll and panel.scroll.scrollchild.gwOptions or panel.gwOptions

    local box_padding = 8
    local pY = -48

    local numRows = 1

    local padding = {x = box_padding, y = hasScroll and 0 or panel.sub:GetText() and -55 or -35}
    local first = true
    local lastOptionName = nil
    local maximumXSize = 440

    for _, v in pairs(options) do
        local newLine = false
        local optionFrameType
        local frameType
        if v.optionType == "boolean" then
            optionFrameType = "GwOptionBoxTmpl"
            frameType = "Button"
            newLine = false
            if v.forceNewLine and v.forceNewLine == true then
                newLine = true
            end
        elseif v.optionType == "slider" then
            optionFrameType = "GwOptionBoxSliderTmpl"
            frameType = "Button"
            newLine = true
        elseif v.optionType == "dropdown" then
            optionFrameType = "GwOptionBoxDropDownTmpl"
            frameType = "Button"
            if v.noNewLine then
                newLine = not v.noNewLine
            else
                newLine = true
            end
        elseif v.optionType == "text" then
            optionFrameType = "GwOptionBoxTextTmpl"
            frameType = "Button"
            newLine = true
        elseif v.optionType == "button" then
            optionFrameType = "GwButtonTextTmpl"
            frameType = "Button"
            newLine = true
        elseif v.optionType == "colorPicker" then
            optionFrameType = "GwOptionBoxColorPickerTmpl"
            frameType = "Button"
            newLine = true
        elseif v.optionType == "header" then
            optionFrameType = "GwOptionBoxHeader"
            frameType = "Frame"
            newLine = true
        end

        local of = CreateFrame(frameType, v.optionName, (hasScroll and panel.scroll.scrollchild or panel), optionFrameType)

        -- joink the panel information we need
        local htext = panel.header:GetText()
        local btext = (panel.breadcrumb and panel.breadcrumb:GetText() or "")
        if not optionReference[panelUniqueID] then
            optionReference[panelUniqueID] = {
              header = htext,
              breadCrumb = btext,
              options = {},
            }
        end

        -- hackfix for dropdowns :<
        if v.name == nil then
          of.displayName = lastOptionName
        else
          of.displayName = v.name
          lastOptionName = v.name
        end

        optionReference[panelUniqueID].options[#optionReference[panelUniqueID].options + 1] = of

        of.optionName = v.optionName
        of.decimalNumbers = v.decimalNumbers
        of.options = v.options
        of.options_names = v.options_names
        of.newLine = newLine
        of.optionType = v.optionType
        of.groupHeaderName = v.groupHeaderName
        of.isPrivateSetting = v.isPrivateSetting
        of.callback = v.callback
        of.hasCheckbox = v.hasCheckbox
        of.getterSetter = v.getterSetter
        of.default = v.default
        --need this for searchables
        of.forceNewLine = v.forceNewLine

        if (newLine and not first) or padding.x > maximumXSize then
            padding.y = padding.y + (pY + box_padding)
            padding.x = box_padding
            numRows = numRows + 1
        end
        if first then
            first = false
        end

        of:ClearAllPoints()
        of:SetPoint("TOPLEFT", (hasScroll and panel.scroll.scrollchild or panel), "TOPLEFT", padding.x, padding.y)
        of.title:SetFont(DAMAGE_TEXT_FONT, 12)
        of.title:SetTextColor(1, 1, 1)
        of.title:SetShadowColor(0, 0, 0, 1)
        of.title:SetText(v.name)

        if v.optionType == "dropdown" and v.noNewLine ~= nil and v.noNewLine then
            of.title:Hide()
            of.dropDown:ClearAllPoints()
            of.dropDown:SetPoint("LEFT", 50, 0)
        end

        of:SetScript(
            "OnEnter",
            function()
                GameTooltip:SetOwner(of, "ANCHOR_CURSOR", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(v.name, 1, 1, 1)
                GameTooltip:AddLine(v.desc, 1, 1, 1, true)
                GameTooltip:Show()
            end
        )
        of:SetScript("OnLeave", GameTooltip_Hide)

        if v.optionType == "colorPicker" then
            local setting = of.getterSetter
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
                if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                    if IsControlKeyDown() and button == "LeftButton" then
                        if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                            -- Set override value
                            SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                        elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                            -- Remove override value
                            SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                        end
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
            end);

            of.dropDown:SetupMenu(function(drowpdown, rootDescription)
                local buttonSize = 20
                local maxButtons = 10
                rootDescription:SetScrollMode(buttonSize * maxButtons)

                for idx, option in pairs(v.options) do
                    local function IsSelected(data)
                        if v.hasCheckbox then
                            local settingstable = of.isPrivateSetting and GW.private[data.optionName] or GW.settings[data.optionName]
                            local isSelected = false
                            if type(settingstable[option]) == "table" then
                                isSelected = settingstable[option].enable
                            else
                                isSelected = settingstable[option] == nil and true or settingstable[option]
                            end
                            if GW.IsInProfileSwitch and v.callback then
                                v.callback(isSelected, data.option)
                            end
                            return isSelected
                        else
                            if GW.IsInProfileSwitch and v.callback then
                                v.callback(data.option)
                                if v.isFont then
                                    of.dropDown.Text:SetFont(GW.Libs.LSM:Fetch("font", data.option), 12, "")
                                else
                                    of.dropDown.Text:SetFont(UNIT_NAME_FONT, 12)
                                end
                            end
                            if of.isPrivateSetting then
                                return GW.private[data.optionName] == data.option
                            else
                                return GW.settings[data.optionName] == data.option
                            end
                        end
                    end
                    local function SetSelected(data)
                        if v.hasCheckbox then
                            local isSelected = true

                            if of.isPrivateSetting then
                                if type(GW.private[data.optionName][data.option]) == "table" then
                                    isSelected = not GW.private[data.optionName][data.option].enable
                                    GW.private[data.optionName][data.option].enable = isSelected
                                else
                                    isSelected = not GW.private[data.optionName][data.option]
                                    GW.private[data.optionName][data.option] = isSelected
                                end
                            else
                                if type(GW.settings[data.optionName][data.option]) == "table" then
                                    isSelected = not GW.settings[data.optionName][data.option].enable
                                    GW.settings[data.optionName][data.option].enable = isSelected
                                else
                                    isSelected = not GW.settings[data.optionName][data.option]
                                    GW.settings[data.optionName][data.option] = isSelected
                                end
                            end

                            if v.callback then
                                v.callback(isSelected, data.option)
                            end
                        else
                            if of.isPrivateSetting then
                                GW.private[data.optionName] = data.option
                            else
                                GW.settings[data.optionName] = data.option
                            end

                            if v.isFont then
                                of.dropDown.Text:SetFont(GW.Libs.LSM:Fetch("font", data.option), 12, "")
                            else
                                of.dropDown.Text:SetFont(UNIT_NAME_FONT, 12)
                            end

                            if v.callback then
                                v.callback(data.option)
                            end
                        end
                        checkDependenciesOnLoad()
                    end

                    local entryButton
                    if v.hasCheckbox then
                        entryButton = rootDescription:CreateCheckbox(v.options_names[idx], IsSelected, SetSelected, {optionName = v.optionName, option = option})
                    else
                        entryButton = rootDescription:CreateRadio(v.options_names[idx], IsSelected, SetSelected, {optionName = v.optionName, option = option})
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

            if v.isFont then
                of.dropDown.Text:SetFont(GW.Libs.LSM:Fetch("font", of.dropDown.Text:GetText()), 12, "")
            else
                of.dropDown.Text:SetFont(UNIT_NAME_FONT, 12)
            end

            of.dropDown:Enable()
            of.dropDown.Text:SetTextColor(1, 1, 1) -- init text color for options without deps
        elseif v.optionType == "slider" then
            of.slider:SetMinMaxValues(v.min, v.max)
            of.slider:SetValue(RoundDec((of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName]), of.decimalNumbers))
            if v.step then of.slider:SetValueStep(v.step) end
            of.slider:SetObeyStepOnDrag(true)
            of.slider:SetScript(
                "OnValueChanged",
                function(self)
                    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                        if IsControlKeyDown() then
                            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                                -- Set override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                                -- Remove override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                            end
                        end
                        self:SetValue(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName])
                        return
                    end
                    local roundValue = RoundDec(self:GetValue(), of.decimalNumbers)

                    if of.isPrivateSetting then
                        GW.private[of.optionName] = tonumber(roundValue)
                    else
                        GW.settings[of.optionName] = tonumber(roundValue)
                    end

                    self:GetParent().inputFrame.input:SetText(roundValue)
                    if v.callback then
                        v.callback()
                    end
                end
            )
            of.inputFrame.input:SetText(RoundDec(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName], of.decimalNumbers))
            of.inputFrame.input:SetScript(
                "OnEnterPressed",
                function(self)
                    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                        if IsControlKeyDown() then
                            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                                -- Set override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                                -- Remove override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                            end
                        end
                        self:SetText(RoundDec(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName], of.decimalNumbers))
                        return
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
                    if of.isPrivateSetting then
                        GW.private[of.optionName] = tonumber(roundValue)
                    else
                        GW.settings[of.optionName] = tonumber(roundValue)
                    end
                    if v.callback then
                        v.callback()
                    end
                end
            )
        elseif v.optionType == "text" then
            of.inputFrame.input:SetText(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName] or "")
            of.inputFrame.input:SetScript(
                "OnEnterPressed",
                function(self)
                    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                        if IsControlKeyDown() then
                            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                                -- Set override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                                -- Remove override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                            end
                        end
                        self:SetText(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName] or "")
                        return
                    end
                    self:ClearFocus()
                    if of.isPrivateSetting then
                        GW.private[of.optionName] = self:GetText()
                    else
                        GW.settings[of.optionName] = self:GetText()
                    end
                    if v.callback then
                        v.callback(self)
                    end
                end
            )
        elseif v.optionType == "boolean" then
            of.checkbutton:SetChecked(of.isPrivateSetting and GW.private[of.optionName] or GW.settings[of.optionName])
            of.checkbutton:SetScript(
                "OnClick",
                function(self, button)
                    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                        if IsControlKeyDown() and button == "LeftButton" then
                            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                                -- Set override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                                -- Remove override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                            end
                        end
                        self:SetChecked(not self:GetChecked())
                        return
                    end

                    local toSet = false
                    if self:GetChecked() then
                        toSet = true
                    end
                    if of.isPrivateSetting then
                        GW.private[of.optionName] = toSet
                    else
                        GW.settings[of.optionName] = toSet
                    end

                    if v.callback then
                        v.callback(toSet, of.optionName)
                    end
                    --Check all dependencies on this option
                    checkDependenciesOnLoad()
                end
            )
            of:SetScript(
                "OnClick",
                function(self, button)
                    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                        if IsControlKeyDown() and button == "LeftButton" then
                            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                                -- Set override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                                -- Remove override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                            end
                        end
                        return
                    end
                    local toSet = true
                    if self.checkbutton:GetChecked() then
                        toSet = false
                    end
                    self.checkbutton:SetChecked(toSet)
                    if of.isPrivateSetting then
                        GW.private[of.optionName] = toSet
                    else
                        GW.settings[of.optionName] = toSet
                    end

                    if v.callback ~= nil then
                        v.callback(toSet, of.optionName)
                    end
                    --Check all dependencies on this option
                    checkDependenciesOnLoad()
                end
            )
        elseif v.optionType == "button" then
            of:SetScript(
                "OnClick",
                function(_, button)
                    if v.isIncompatibleAddonLoaded or v.isIncompatibleAddonLoadedButOverride then
                        if IsControlKeyDown() and button == "LeftButton" then
                            if v.isIncompatibleAddonLoaded and not v.isIncompatibleAddonLoadedButOverride then
                                -- Set override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, true)
                            elseif not v.isIncompatibleAddonLoaded and v.isIncompatibleAddonLoadedButOverride then
                                -- Remove override value
                                SetOverrideIncompatibleAddons(v.incompatibleAddonsType, false)
                            end
                        end
                        return
                    end
                    if v.callback then
                        v.callback()
                    end
                    --Check all dependencies on this option
                    checkDependenciesOnLoad()
                end
            )
            of.title:SetTextColor(0, 0, 0)
            of.title:SetShadowColor(0, 0, 0, 0)
        elseif v.optionType == "header" then
            of.title:SetFont(DAMAGE_TEXT_FONT, 16)
        end

        if not newLine then
            padding.x = padding.x + of:GetWidth() + box_padding
        else
            padding.x = maximumXSize + 10
        end
    end

    -- Scrollframe settings
    if hasScroll then
        local maxScroll = max(0, numRows * 40 - panel:GetHeight() + 50)
        panel.scroll:SetScrollChild(panel.scroll.scrollchild)
        panel.scroll.scrollchild:SetHeight(panel:GetHeight())
        panel.scroll.scrollchild:SetWidth(panel.scroll:GetWidth() - 20)
        panel.scroll.slider:SetMinMaxValues(0, maxScroll)
        panel.scroll.slider.thumb:SetHeight(panel.scroll.slider:GetHeight() * (panel.scroll:GetHeight() / (maxScroll + panel.scroll:GetHeight())) )
        panel.scroll.slider:SetValue(1)
        panel.scroll.maxScroll = maxScroll
        panel.scroll.doNotHide = false
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
