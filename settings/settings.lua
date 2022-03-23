local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec
local AddForProfiling = GW.AddForProfiling
local SetOverrideIncompatibleAddons = GW.SetOverrideIncompatibleAddons

local settings_cat = {}
local all_options = {}

local function switchCat(index)
    for _, l in ipairs(settings_cat) do
        l.iconbg:Hide()
        l.cat_panel:Hide()

        -- hide all profiles
        if l.cat_profilePanels then
            for _, pp in ipairs(l.cat_profilePanels) do
                pp:Hide()
            end
        end
    end

    local l = settings_cat[index]
    if l then
        l.iconbg:Show()
        l.cat_panel:Show()
        if l.cat_crollFrames then
            for _, v in pairs(l.cat_crollFrames) do 
                v.scroll.slider:SetShown(v.scroll.maxScroll > 0)
                v.scroll.scrollUp:SetShown(v.scroll.maxScroll > 0)
                v.scroll.scrollDown:SetShown(v.scroll.maxScroll > 0)
            end
        end
        -- open the last shown profile
        if l.cat_profilePanels then
            l.cat_panel:Hide()
            if l.cat_panel == l.cat_panel.selectProfile.active then
                l.cat_panel:Show()
                l.cat_panel.selectProfile.string:SetText(getglobal(l.cat_panel.selectProfile.type))
                UIFrameFadeIn(l.cat_panel, 0.2, 0, 1)
            else
                for _, pp in ipairs(l.cat_profilePanels) do
                    if pp == l.cat_panel.selectProfile.active then
                        pp:Show()
                        pp.selectProfile.string:SetText(getglobal(pp.selectProfile.type))
                        UIFrameFadeIn(pp, 0.2, 0, 1)
                        break
                    end
                end
            end
        else
            UIFrameFadeIn(l.cat_panel, 0.2, 0, 1)
        end
    end
end
AddForProfiling("settings", "switchCat", switchCat)

local fnF_OnEnter = function(self)
    self.icon:SetBlendMode("ADD")
    GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -40)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(self.cat_name, 1, 1, 1)
    GameTooltip:AddLine(self.cat_desc, 1, 1, 1)
    GameTooltip:Show()
end
AddForProfiling("settings", "fnF_OnEnter", fnF_OnEnter)

local fnF_OnLeave = function(self)
    self.icon:SetBlendMode("BLEND")
    GameTooltip_Hide(self)
end
AddForProfiling("settings", "fnF_OnLeave", fnF_OnLeave)

local fnF_OnClick = function(self)
    switchCat(self.cat_id)
end
AddForProfiling("settings", "fnF_OnClick", fnF_OnClick)

local function CreateCat(name, desc, panel, icon, bg, scrollFrames, specialIcon, profilePanles)
    local i = #settings_cat + 1

    -- create and position a new button/label for this category
    local f = CreateFrame("Button", nil, GwSettingsWindow, "GwSettingsLabelTmpl")
    f.cat_panel = panel
    f.cat_profilePanels = profilePanles
    f.cat_name = name
    f.cat_desc = desc
    f.cat_id = i
    f.cat_crollFrames = scrollFrames
    settings_cat[i] = f
    f:SetPoint("TOPLEFT", -40, -32 + (-40 * (i - 1)))

    -- set the icon requested
    f.icon:SetTexCoord(0.25 * floor(icon / 4), 0.25 * (floor(icon / 4) + 1), 0.25 * (icon % 4), 0.25 * ((icon % 4) + 1))
    if specialIcon then
        f.icon:SetTexCoord(0, 1, 0, 1)
        f.icon:SetTexture(specialIcon)
    end
    -- set the bg requested
    if bg then
        f.iconbg:SetTexture(bg)
    end

    -- add handlers
    f:SetScript("OnEnter", fnF_OnEnter)
    f:SetScript("OnLeave", fnF_OnLeave)
    f:SetScript("OnClick", fnF_OnClick)
end
GW.CreateCat = CreateCat

local function AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons)
    if not panel then
        return
    end
    if not panel.gwOptions then
        panel.gwOptions = {}
    end

    local opt = {}
    opt["name"] = name
    opt["desc"] = desc
    opt["optionName"] = optionName
    opt["optionType"] = "boolean"
    opt["callback"] = callback
    opt["dependence"] = dependence
    opt["incompatibleAddonsType"] = incompatibleAddons
    opt["isIncompatibleAddonLoaded"] = false
    opt["isIncompatibleAddonLoadedButOverride"] = false

    if params then
        for k,v in pairs(params) do opt[k] = v end
    end

    local i = #(panel.gwOptions) + 1
    panel.gwOptions[i] = opt

    local i = #(all_options) + 1
    all_options[i] = opt

    if incompatibleAddons then
        local isIncompatibleAddonLoaded, whichAddonsLoaded, isOverride = GW.IsIncompatibleAddonLoadedOrOverride(incompatibleAddons)
        if isIncompatibleAddonLoaded and not isOverride then
            opt["desc"] = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt["isIncompatibleAddonLoaded"] = true
        elseif isIncompatibleAddonLoaded and isOverride then
            opt["desc"] = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffffa500" ..  L["You have overridden this behavior."] .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt["isIncompatibleAddonLoaded"] = false
            opt["isIncompatibleAddonLoadedButOverride"] = true
        end
    end

    return opt
end
GW.AddOption = AddOption

local function AddOptionButton(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons)
    if not panel then
        return
    end
    if not panel.gwOptions then
        panel.gwOptions = {}
    end

    local opt = {}
    opt["name"] = name
    opt["desc"] = desc
    opt["optionName"] = optionName
    opt["optionType"] = "button"
    opt["callback"] = callback
    opt["dependence"] = dependence
    opt["incompatibleAddonsType"] = incompatibleAddons
    opt["isIncompatibleAddonLoaded"] = false
    opt["isIncompatibleAddonLoadedButOverride"] = false

    if params then
        for k, v in pairs(params) do opt[k] = v end
    end

    local i = #(panel.gwOptions) + 1
    panel.gwOptions[i] = opt

    local i = #(all_options) + 1
    all_options[i] = opt

    if incompatibleAddons then
        local isIncompatibleAddonLoaded, whichAddonsLoaded, isOverride = GW.IsIncompatibleAddonLoadedOrOverride(incompatibleAddons)
        if isIncompatibleAddonLoaded and not isOverride then
            opt["desc"] = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt["isIncompatibleAddonLoaded"] = true
        elseif  isIncompatibleAddonLoaded and isOverride then
            opt["desc"] = (desc and desc or "") .. "\n\n|cffffedba" .. L["The following addon(s) are loaded, which can cause conflicts. By default, this setting is disabled."] .. "|r |cffff0000\n" .. whichAddonsLoaded .. "|r\n\n|cffffa500" ..  L["You have overridden this behavior."] .. "|r\n\n|cffaaaaaa" .. L["Ctrl + Click to toggle override"] .. "|r"
            opt["isIncompatibleAddonLoaded"] = false
            opt["isIncompatibleAddonLoadedButOverride"] = true
        end
    end

    return opt
end
GW.AddOptionButton = AddOptionButton

local function AddOptionSlider(panel, name, desc, optionName, callback, min, max, params, decimalNumbers, dependence, step, incompatibleAddons)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons)

    opt["min"] = min
    opt["max"] = max
    opt["decimalNumbers"] = decimalNumbers or 0
    opt["step"] = step
    opt["optionType"] = "slider"

    return opt
end
GW.AddOptionSlider = AddOptionSlider

local function AddOptionText(panel, name, desc, optionName, callback, multiline, params, dependence, incompatibleAddons)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons)

    opt["multiline"] = multiline
    opt["optionType"] = "text"
end
GW.AddOptionText = AddOptionText

local function AddOptionDropdown(panel, name, desc, optionName, callback, options_list, option_names, params, dependence, checkbox, incompatibleAddons, tooltipType)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, incompatibleAddons)

    opt["options"] = {}
    opt["options"] = options_list
    opt["options_names"] = option_names
    opt["hasCheckbox"] = checkbox
    opt["optionType"] = "dropdown"
    opt["tooltipType"] = tooltipType
end
GW.AddOptionDropdown = AddOptionDropdown

local function WarningPrompt(text, method)
    GwWarningPrompt.string:SetText(text)
    GwWarningPrompt.method = method
    GwWarningPrompt:Show()
    GwWarningPrompt.input:Hide()
end
GW.WarningPrompt = WarningPrompt

local function setDependenciesOption(type, name, SetEnable, deactivateColor, overrideColor)
    if deactivateColor then
        _G[name].title:SetTextColor(0.82, 0, 0)
        if type == "slider" then
            _G[name].input:SetTextColor(0.82, 0, 0)
        elseif type == "text" then
            _G[name].input:SetTextColor(0.82, 0, 0)
        elseif type == "dropdown" then
            _G[name].button.string:SetTextColor(0.82, 0, 0)
        end
    elseif overrideColor then
        _G[name].title:SetTextColor(1, 0.65, 0)
        if type == "slider" then
            _G[name].input:SetTextColor(1, 0.65, 0)
        elseif type == "text" then
            _G[name].input:SetTextColor(1, 0.65, 0)
        elseif type == "dropdown" then
            _G[name].button.string:SetTextColor(1, 0.65, 0)
        end
    elseif SetEnable then
        _G[name].title:SetTextColor(1, 1, 1)
        if type == "boolean" then
            _G[name]:Enable()
            _G[name].checkbutton:Enable()
        elseif type == "slider" then
            _G[name].slider:Enable()
            _G[name].input:Enable()
            _G[name].input:SetTextColor(0.82, 0.82, 0.82)
        elseif type == "text" then
            _G[name].input:Enable()
            _G[name].input:SetTextColor(1, 1, 1)
        elseif type == "dropdown" then
            _G[name].button:Enable()
            _G[name].button.string:SetTextColor(1, 1, 1)
        elseif type == "button" then
            _G[name]:Enable()
            _G[name].title:SetTextColor(0, 0, 0)
        end
    else
        _G[name].title:SetTextColor(0.82, 0.82, 0.82)
        if type == "boolean" then
            _G[name]:Disable()
            _G[name].checkbutton:Disable()
        elseif type == "slider" then
            _G[name].slider:Disable()
            _G[name].input:Disable()
            _G[name].input:SetTextColor(0.82, 0.82, 0.82)
        elseif type == "text" then
            _G[name].input:Disable()
            _G[name].input:SetTextColor(0.82, 0.82, 0.82)
        elseif type == "dropdown" then
            _G[name].button:Disable()
            _G[name].button.string:SetTextColor(0.82, 0.82, 0.82)
        elseif type == "button" then
            _G[name]:Disable()
        end
    end
end

local function checkDependenciesOnLoad()
    local options = all_options
    local allOptionsSet = false

    for _, v in pairs(options) do
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
                        if GetSetting(sn) == dv then
                            allOptionsSet = true
                            break
                        end
                    end
                else
                    if GetSetting(sn) == sv then
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

local function loadDropDown(scrollFrame)
    local USED_DROPDOWN_HEIGHT

    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local ddCount = scrollFrame.numEntries

    for i = 1, #scrollFrame.buttons do
        local slot = scrollFrame.buttons[i]

        local idx = i + offset
        if idx > ddCount then
            -- empty row (blank starter row, final row, and any empty entries)
            slot:Hide()
            slot.option = nil
            slot.optionName = nil
            slot.optionDisplayName = nil
        else
            if scrollFrame.data then
                if not scrollFrame.data.hasCheckbox then
                    slot.checkbutton:Hide()
                    slot.string:ClearAllPoints()
                    slot.string:SetPoint("LEFT", 5, 0)
                else
                    slot.checkbutton:Show()
                end

                slot.string:SetText(scrollFrame.data.options_names[idx])
                slot.option = scrollFrame.data.options[idx]
                slot.optionName = scrollFrame.data.optionName
                slot.optionDisplayName = scrollFrame.data.options_names[idx]

                if scrollFrame.data.hasCheckbox then
                    local settingstable = GetSetting(scrollFrame.data.optionName, scrollFrame.data.perSpec)
                    if settingstable[scrollFrame.data.options[idx]] then
                        slot.checkbutton:SetChecked(true)
                    else
                        slot.checkbutton:SetChecked(false)
                    end
                end

                slot:Show()
            else
                slot:Hide()
            end
        end
    end

    USED_DROPDOWN_HEIGHT = 20 * ddCount
    HybridScrollFrame_Update(scrollFrame, USED_DROPDOWN_HEIGHT, 120)
end

local function InitPanel(panel, hasScroll)
    if not panel or not (hasScroll and panel.scroll.scrollchild.gwOptions or panel.gwOptions) then
        return
    end
    local options = hasScroll and panel.scroll.scrollchild.gwOptions or panel.gwOptions

    local box_padding = 8
    local pY = -48

    local numRows = 1

    local padding = {x = box_padding, y = hasScroll and 0 or panel.sub:GetText() and -55 or -35}
    local first = true

    for _, v in pairs(options) do
        local newLine = false
        local optionFrameType = "GwOptionBoxTmpl"
        if v.optionType == "slider" then
            optionFrameType = "GwOptionBoxSliderTmpl"
            newLine = true
        end
        if v.optionType == "dropdown" then
            optionFrameType = "GwOptionBoxDropDownTmpl"
            newLine = true
        end
        if v.optionType == "text" then
            optionFrameType = "GwOptionBoxTextTmpl"
            newLine = true
        elseif v.optionType == "button" then
            optionFrameType = "GwButtonTextTmpl"
            newLine = true
        end

        local of = CreateFrame("Button", v.optionName, (hasScroll and panel.scroll.scrollchild or panel), optionFrameType)

        if (newLine and not first) or padding.x > 440 then
            padding.y = padding.y + (pY + box_padding)
            padding.x = box_padding
            numRows = numRows + 1
        end
        if first then
            first = false
        end

        of:ClearAllPoints()
        of:SetPoint("TOPLEFT", (hasScroll and panel.scroll.scrollchild or panel), "TOPLEFT", padding.x, padding.y)
        of.title:SetText(v.name)
        of.title:SetFont(DAMAGE_TEXT_FONT, 12)
        of.title:SetTextColor(1, 1, 1)
        of.title:SetShadowColor(0, 0, 0, 1)

        if hasScroll and v.optionType == "dropdown" then
            of.container:SetParent(panel)
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

        if v.optionType == "dropdown" then
            local scrollFrame = of.container.contentScroll
            scrollFrame.numEntries = #v.options
            scrollFrame.scrollBar.thumbTexture:SetSize(12, 30)
            scrollFrame.scrollBar:ClearAllPoints()
            scrollFrame.scrollBar:SetPoint("TOPRIGHT", -3, -12)
            scrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -3, 12)
            scrollFrame.scrollBar.scrollUp:SetPoint("TOPRIGHT", 0, 12)
            scrollFrame.scrollBar.scrollDown:SetPoint("BOTTOMRIGHT", 0, -12)
            scrollFrame.scrollBar:SetFrameLevel(scrollFrame:GetFrameLevel() + 5)

            scrollFrame.data = GW.copyTable(nil, v)
            scrollFrame.of = of
            scrollFrame.update = loadDropDown
            scrollFrame.scrollBar.doNotHide = false
            HybridScrollFrame_CreateButtons(scrollFrame, "GwDropDownItemTmpl", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
            for i = 1, #scrollFrame.buttons do
                local slot = scrollFrame.buttons[i]
                slot:SetWidth(scrollFrame:GetWidth())
                slot.string:SetFont(UNIT_NAME_FONT, 12)
                slot.of = of
                if not slot.ScriptsHooked then
                    slot:HookScript("OnClick", function(self)
                        if v.hasCheckbox then return end
                        of.button.string:SetText(self.optionDisplayName)

                        if of.container:IsShown() then
                            of.container:Hide()
                        else
                            of.container:Show()
                        end

                        SetSetting(self.optionName, self.option)

                        if v.callback ~= nil then
                            v.callback()
                        end
                        --Check all dependencies on this option
                        checkDependenciesOnLoad()
                    end)
                    slot.checkbutton:HookScript("OnClick", function(self)
                        local toSet = false
                        if self:GetChecked() then
                            toSet = true
                        end

                        SetSetting(self:GetParent().optionName, toSet, self:GetParent().option)

                        if v.callback ~= nil then
                            v.callback(toSet, self:GetParent().option)
                        end
                        --Check all dependencies on this option
                        checkDependenciesOnLoad()
                    end)
                    if v.tooltipType then
                        if v.tooltipType == "spell" then
                            slot:HookScript("OnEnter", function(self)
                                -- show the spell tooltip
                                GameTooltip_SetDefaultAnchor(GameTooltip, self)
                                GameTooltip:SetSpellByID(self.option)
                                GameTooltip:Show()
                            end)
                        end
                        slot:HookScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)
                    end
                    slot.ScriptsHooked = true
                end
            end
            loadDropDown(scrollFrame)
            -- set current settings value
            for key, val in pairs(v.options) do
                if GetSetting(v.optionName, v.perSpec) == val then
                    of.button.string:SetText(v.options_names[key])
                    break
                end
            end

            of.button.string:SetFont(UNIT_NAME_FONT, 12)
            of.button:SetScript(
                "OnClick",
                function(self, button) -- if incompatible addons is loaded, check for override click
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
                    local dd = self:GetParent()
                    if dd.container:IsShown() then
                        dd.container:Hide()
                    else
                        dd.container:Show()
                    end
                end
            )
            scrollFrame:SetScript(
                "OnMouseDown",
                function(self)
                    if self:GetParent():IsShown() then
                        self:GetParent():Hide()
                    else
                        self:GetParent():Show()
                    end
                end
            )
        elseif v.optionType == "slider" then
            of.slider:SetMinMaxValues(v.min, v.max)
            of.slider:SetValue(GetSetting(v.optionName))
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
                        self:SetValue(GetSetting(v.optionName))
                        return
                    end
                    local roundValue = RoundDec(self:GetValue(), v.decimalNumbers)

                    SetSetting(v.optionName, roundValue)
                    self:GetParent().input:SetText(roundValue)
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
            of.input:SetNumber(GW.RoundDec(GetSetting(v.optionName), v.decimalNumbers))
            of.input:SetScript(
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
                        self:SetNumber(RoundDec(GetSetting(v.optionName), v.decimalNumbers))
                        return
                    end
                    local roundValue = RoundDec(self:GetNumber(), v.decimalNumbers) or v.min

                    self:ClearFocus()
                    if tonumber(roundValue) > v.max then self:SetText(v.max) end
                    if tonumber(roundValue) < v.min then self:SetText(v.min) end
                    roundValue = RoundDec(self:GetNumber(), v.decimalNumbers) or v.min
                    if v.step and v.step > 0 then
                        local min_value = v.min or 0
                        roundValue = floor((roundValue - min_value) / v.step + 0.5) * v.step + min_value
                    end
                    self:GetParent().slider:SetValue(roundValue)
                    self:SetText(roundValue)
                    SetSetting(v.optionName, roundValue)
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
        elseif v.optionType == "text" then
            of.input:SetText(GetSetting(v.optionName) or "")
            of.input:SetScript(
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
                        self:SetText(GetSetting(v.optionName, v.perSpec) or "")
                        return
                    end
                    self:ClearFocus()
                    SetSetting(v.optionName, self:GetText())
                    if v.callback ~= nil then
                        v.callback(self)
                    end
                end
            )
        elseif v.optionType == "boolean" then
            of.checkbutton:SetChecked(GetSetting(v.optionName))
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
                    SetSetting(v.optionName, toSet)

                    if v.callback ~= nil then
                        v.callback(toSet)
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
                    SetSetting(v.optionName, toSet)

                    if v.callback ~= nil then
                        v.callback(toSet)
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
                    if v.callback ~= nil then
                        v.callback()
                    end
                    --Check all dependencies on this option
                    checkDependenciesOnLoad()
                end
            )
            of.title:SetTextColor(0, 0, 0)
            of.title:SetShadowColor(0, 0, 0, 0)
        end

        if not newLine then
            padding.x = padding.x + of:GetWidth() + box_padding
        else
            padding.x = 450
        end
    end
    -- Scrollframe settings
    if hasScroll then
        panel.scroll:SetScrollChild(panel.scroll.scrollchild)
        panel.scroll.scrollchild:SetHeight(panel:GetHeight())
        panel.scroll.scrollchild:SetWidth(panel.scroll:GetWidth() - 20)
        panel.scroll.slider:SetMinMaxValues(0, max(0, numRows * 40 - panel:GetHeight() + 50))
        panel.scroll.slider.thumb:SetHeight(100)
        panel.scroll.slider:SetValue(1)
        panel.scroll.maxScroll = max(0, numRows * 40 - panel:GetHeight() + 50)
    end
end
GW.InitPanel = InitPanel

local function LoadSettings()
    local fmGWP = CreateFrame("Frame", "GwWarningPrompt", UIParent, "GwWarningPrompt")
    fmGWP.string:SetFont(UNIT_NAME_FONT, 14)
    fmGWP.string:SetTextColor(1, 1, 1)
    fmGWP.acceptButton:SetText(ACCEPT)
    fmGWP.cancelButton:SetText(CANCEL)
    local fnGWP_input_OnEscapePressed = function(self)
        self:ClearFocus()
    end
    local fnGWP_input_OnEnterPressed = function(self)
        if self:GetParent().method ~= nil then
            self:GetParent().method()
        end
        self:GetParent():Hide()
    end
    fmGWP.input:SetScript("OnEscapePressed", fnGWP_input_OnEscapePressed)
    fmGWP.input:SetScript("OnEditFocusGained", nil)
    fmGWP.input:SetScript("OnEditFocusLost", nil)
    fmGWP.input:SetScript("OnEnterPressed", fnGWP_input_OnEnterPressed)
    local fnGWP_accept_OnClick = function(self)
        if self:GetParent().method ~= nil then
            self:GetParent().method()
        end
        self:GetParent():Hide()
    end
    local fnGWP_cancel_OnClick = function(self)
        self:GetParent():Hide()
    end
    fmGWP.acceptButton:SetScript("OnClick", fnGWP_accept_OnClick)
    fmGWP.cancelButton:SetScript("OnClick", fnGWP_cancel_OnClick)

    tinsert(UISpecialFrames, "GwWarningPrompt")

    local fnMf_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnMf_OnDragStop = function(self)
        self:StopMovingOrSizing()
    end
    local mf = CreateFrame("Frame", "GwSettingsMoverFrame", UIParent, "GwSettingsMoverFrame")
    mf:SetClampedToScreen(true)
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", fnMf_OnDragStart)
    mf:SetScript("OnDragStop", fnMf_OnDragStop)

    local sWindow = CreateFrame("Frame", "GwSettingsWindow", UIParent, "GwSettingsWindowTmpl")
    sWindow:SetClampedToScreen(true)
    tinsert(UISpecialFrames, "GwSettingsWindow")
    local fmGSWMH = GwSettingsWindowMoveHud
    local fmGSWS = sWindow.save
    local fmGSWD = sWindow.discord
    local fmGSWKB = sWindow.keyBind

    sWindow.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    sWindow.versionString:SetFont(UNIT_NAME_FONT, 12)
    sWindow.versionString:SetText(GW.VERSION_STRING)
    sWindow.headerString:SetText(CHAT_CONFIGURATION)
    fmGSWMH:SetText(L["Move HUD"])
    fmGSWS:SetText(L["Save and Reload"])
    fmGSWKB:SetText(KEY_BINDING)
    fmGSWD:SetText(L["Join Discord"])

    StaticPopupDialogs["JOIN_DISCORD"] = {
        text = L["Join Discord"],
        button2 = CLOSE,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = 1,
        hasWideEditBox = true,
        editBoxWidth = 250,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide();
        end,
        OnShow = function(self)
            self:SetWidth(420)
            local editBox = _G[self:GetName() .. "EditBox"]
            editBox:SetText("https://discord.gg/MZZtRWt")
            editBox:SetFocus()
            editBox:HighlightText(false)
            local button = _G[self:GetName() .. "Button2"]
            button:ClearAllPoints()
            button:SetWidth(200)
            button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
        end,
        preferredIndex = 4
    }

    local fnGSWMH_OnClick = function()
        if InCombatLockdown() then
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
            return
        end
        GW.moveHudObjects(GW.MoveHudScaleableFrame)
    end
    local fnGSWS_OnClick = function()
        C_UI.Reload()
    end
    local fnGSWD_OnClick = function()
        StaticPopup_Show("JOIN_DISCORD")
    end
    local fmGSWKB_OnClick = function()
        GwSettingsWindow:Hide()
        GW.HoverKeyBinds()
    end
    fmGSWMH:SetScript("OnClick", fnGSWMH_OnClick)
    fmGSWS:SetScript("OnClick", fnGSWS_OnClick)
    fmGSWD:SetScript("OnClick", fnGSWD_OnClick)
    fmGSWKB:SetScript("OnClick", fmGSWKB_OnClick)

    sWindow:SetScript(
        "OnShow",
        function()
            mf:Show()
            -- Check Blizzard Actionbar settings and set correct values
            local bar1, bar2, bar3, bar4 =  GetActionBarToggles()
            SetSetting("GW_SHOW_MULTI_ACTIONBAR_1", bar1)
            SetSetting("GW_SHOW_MULTI_ACTIONBAR_2", bar2)
            SetSetting("GW_SHOW_MULTI_ACTIONBAR_3", bar3)
            SetSetting("GW_SHOW_MULTI_ACTIONBAR_4", bar4)
            _G["GW_SHOW_MULTI_ACTIONBAR_1"].checkbutton:SetChecked(bar1)
            _G["GW_SHOW_MULTI_ACTIONBAR_2"].checkbutton:SetChecked(bar2)
            _G["GW_SHOW_MULTI_ACTIONBAR_3"].checkbutton:SetChecked(bar3)
            _G["GW_SHOW_MULTI_ACTIONBAR_4"].checkbutton:SetChecked(bar4)

            -- Check UI Scale
            if GetCVarBool("useUiScale") then
                _G["PIXEL_PERFECTION"].checkbutton:SetChecked(false)
            end

            checkDependenciesOnLoad()
        end
    )
    sWindow:SetScript(
        "OnHide",
        function()
            mf:Hide()
        end
    )
    sWindow:SetScript(
        "OnEvent",
        function(self, event)
            if event == "PLAYER_REGEN_DISABLED" and self:IsShown() then
                self:Hide()
                mf:Hide()
                DEFAULT_CHAT_FRAME:AddMessage(("*GW2GW2_UI:|r " .. L["Settings are not available in combat!"]):gsub("*", GW.Gw2Color))
                sWindow.wasOpen = true
            elseif event == "PLAYER_REGEN_ENABLED" and self.wasOpen then
                self:Show()
                mf:Show()
                sWindow.wasOpen = false
            end
        end
    )
    sWindow:RegisterEvent("PLAYER_REGEN_DISABLED")
    sWindow:RegisterEvent("PLAYER_REGEN_ENABLED")
    mf:Hide()

    GW.LoadModulesPanel(sWindow)
    GW.LoadPlayerPanel(sWindow)
    GW.LoadTargetPanel(sWindow)
    GW.LoadActionbarPanel(sWindow)
    GW.LoadHudPanel(sWindow)
    GW.LoadTooltipPanel(sWindow)
    GW.LoadPartyPanel(sWindow)
    GW.LoadRaidPanel(sWindow)
    GW.LoadAurasPanel(sWindow)
    GW.LoadSkinsPanel(sWindow)
    GW.LoadProfilesPanel(sWindow)

    checkDependenciesOnLoad()
    switchCat(1)
    GwSettingsWindow:Hide()

    -- change the blizzard actionbarsettings on "InterfaceOptions_OnShow"
    _G.InterfaceOptionsActionBarsPanelBottomLeft:Hide()
    _G.InterfaceOptionsActionBarsPanelBottomRight:Hide()
    _G.InterfaceOptionsActionBarsPanelRight:Hide()
    _G.InterfaceOptionsActionBarsPanelRightTwo:Hide()
    --InterfaceOptionsFrame:HookScript("OnShow", function()
    --    local bar1, bar2, bar3, bar4 = GetSetting("GW_SHOW_MULTI_ACTIONBAR_1"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_2"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_3"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_4")
    --    _G.InterfaceOptionsActionBarsPanelBottomLeft:SetChecked(bar1)
    --    _G.InterfaceOptionsActionBarsPanelBottomRight:SetChecked(bar2)
    --    _G.InterfaceOptionsActionBarsPanelRight:SetChecked(bar3)
    --    _G.InterfaceOptionsActionBarsPanelRightTwo:SetChecked(bar4)
    --end)

    local fnGSBC_OnClick = function(self)
        self:GetParent():Hide()
    end
    sWindow.close:SetScript("OnClick", fnGSBC_OnClick)
end
GW.LoadSettings = LoadSettings
