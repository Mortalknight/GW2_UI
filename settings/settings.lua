local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local RoundDec = GW.RoundDec
local Debug = GW.Debug
local AddForProfiling = GW.AddForProfiling

local settings_cat = {}
local all_options = {}

local function Grid_GetRegion(mhgb)
    if mhgb.grid then
        if mhgb.grid.regionCount and mhgb.grid.regionCount > 0 then
            local line = select(mhgb.grid.regionCount, mhgb.grid:GetRegions())
            mhgb.grid.regionCount = mhgb.grid.regionCount - 1
            line:SetAlpha(1)
            return line
        else
            return mhgb.grid:CreateTexture()
        end
    end
end

local function create_grid(mhgb)
    if not mhgb.grid then
        mhgb.grid = CreateFrame("Frame", nil, UIParent)
        mhgb.grid:SetFrameStrata("BACKGROUND")
    else
        mhgb.grid.regionCount = 0
        local numRegions = mhgb.grid:GetNumRegions()
        for i = 1, numRegions do
            local region = select(i, mhgb.grid:GetRegions())
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                mhgb.grid.regionCount = mhgb.grid.regionCount + 1
                region:SetAlpha(0)
            end
        end
    end

    local size = (1 / 0.64) - ((1 - (768 / GW.screenHeight)) / 0.64)
    local width, height = UIParent:GetSize()
    local ratio = width / height
    local hStepheight = height * ratio
    local wStep = width / mhgb.gridSize
    local hStep = hStepheight / mhgb.gridSize

    mhgb.grid.boxSize = mhgb.gridSize
    mhgb.grid:SetPoint("CENTER", UIParent)
    mhgb.grid:SetSize(width, height)
    mhgb.grid:Hide()

    for i = 0, mhgb.gridSize do
        local tx = Grid_GetRegion(mhgb)
        if i == mhgb.gridSize / 2 then
            tx:SetColorTexture(1, 0, 0)
            tx:SetDrawLayer("BACKGROUND", 1)
        else
            tx:SetColorTexture(0, 0, 0)
            tx:SetDrawLayer("BACKGROUND", 0)
        end
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", i * wStep - (size / 2), 0)
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
    end

    do
        local tx = Grid_GetRegion(mhgb)
        tx:SetColorTexture(1, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 1)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
    end

    for i = 1, floor((height / 2) / hStep) do
        local tx = Grid_GetRegion(mhgb)
        tx:SetColorTexture(0, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

        tx = Grid_GetRegion(mhgb)
        tx:SetColorTexture(0, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
    end
end

local function switchCat(index)
    for i, l in ipairs(settings_cat) do
        l.iconbg:Hide()
        l.cat_panel:Hide()
    end

    local l = settings_cat[index]
    if l then
        l.iconbg:Show()
        l.cat_panel:Show()
        UIFrameFadeIn(l.cat_panel, 0.2, 0, 1)
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

local fnF_OnClick = function(self, button)
    switchCat(self.cat_id)
end
AddForProfiling("settings", "fnF_OnClick", fnF_OnClick)

local function CreateCat(name, desc, panel, icon, bg)
    local i = #settings_cat + 1

    -- create and position a new button/label for this category
    local f = CreateFrame("Button", nil, GwSettingsWindow, "GwSettingsLabelTmpl")
    f.cat_panel = panel
    f.cat_name = name
    f.cat_desc = desc
    f.cat_id = i
    settings_cat[i] = f
    f:SetPoint("TOPLEFT", -40, -32 + (-40 * (i - 1)))

    -- set the icon requested
    f.icon:SetTexCoord(0.25 * floor(icon / 4), 0.25 * (floor(icon / 4) + 1), 0.25 * (icon % 4), 0.25 * ((icon % 4) + 1))

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

local function AddOption(panel, name, desc, optionName, callback, params, dependence)
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

    if params then
        for k, v in pairs(params) do opt[k] = v end
    end

    local i = #(panel.gwOptions) + 1
    panel.gwOptions[i] = opt

    local i = #(all_options) + 1
    all_options[i] = opt

    return opt
end
GW.AddOption = AddOption

local function AddOptionSlider(panel, name, desc, optionName, callback, min, max, params, decimalNumbers, dependence, step)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, dependence_value)

    opt["min"] = min
    opt["max"] = max
    opt["decimalNumbers"] = decimalNumbers or 0
    opt["step"] = step
    opt["optionType"] = "slider"

    return opt
end
GW.AddOptionSlider = AddOptionSlider

local function AddOptionText(panel, name, desc, optionName, callback, multiline, params, dependence)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, dependence_value)

    opt["multiline"] = multiline
    opt["optionType"] = "text"
end
GW.AddOptionText = AddOptionText

local function AddOptionDropdown(panel, name, desc, optionName, callback, options_list, option_names, params, dependence)
    local opt = AddOption(panel, name, desc, optionName, callback, params, dependence, dependence_value)

    opt["options"] = {}
    opt["options"] = options_list
    opt["options_names"] = option_names
    opt["optionType"] = "dropdown"
end
GW.AddOptionDropdown = AddOptionDropdown

local function Grid_Show_Hide(mhgb)
    if mhgb.forceHide then
        if mhgb.grid then
            mhgb.grid:Hide()
        end
        mhgb.grid_align:Hide()
        mhgb.forceHide = false
        mhgb:SetText(L["GRID_BUTTON_SHOW"])
    else
        if not mhgb.grid then
            create_grid(mhgb)
        elseif mhgb.grid.boxSize ~= mhgb.gridSize then
            mhgb.grid:Hide()
            create_grid(mhgb)
        end
        mhgb.grid_align:Show()
        mhgb.grid:Show()
        mhgb.forceHide = true
        mhgb:SetText(L["GRID_BUTTON_HIDE"])
    end
end

local settings_window_open_before_change = false
local function moveHudObjects(self)
    self.lhb:Show()
    self.mhgb:Show()
    if GwSettingsWindow:IsShown() then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for i, mf in pairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(true)
        mf:SetMovable(true)
        mf:Show()
    end
end
GW.moveHudObjects = moveHudObjects

local function lockHudObjects(self)
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(L["HUD_MOVE_ERR"])
        return
    end
    self:Hide()
    self.mhgb:Hide()
    self.mhgb.grid_align:Hide()
    if settings_window_open_before_change then
        settings_window_open_before_change = false
        GwSettingsWindow:Show()
    end

    for i, mf in ipairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(false)
        mf:SetMovable(false)
        mf:Hide()
    end
    if self.mhgb.grid then
        self.mhgb.grid:Hide()
    end
    GW.UpdateFramePositions()
    C_UI.Reload()
end
AddForProfiling("settings", "lockHudObjects", lockHudObjects)

local function WarningPrompt(text, method)
    GwWarningPrompt.string:SetText(text)
    GwWarningPrompt.method = method
    GwWarningPrompt:Show()
    GwWarningPrompt.input:Hide()
end
GW.WarningPrompt = WarningPrompt

local function setDependenciesOption(type, name, SetEnable)
    if SetEnable then
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
        end
        _G[name].title:SetTextColor(1, 1, 1)
    else
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
        end
        _G[name].title:SetTextColor(0.82, 0.82, 0.82)
    end
end

local function checkDependenciesOnLoad()
    local options = all_options
    local allOptionsSet = false

    for k, v in pairs(options) do
        if v.dependence then
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

local function InitPanel(panel)
    if not panel or not panel.gwOptions then
        return
    end
    local options = panel.gwOptions

    local box_padding = 8
    local pY = -48

    local padding = {x = box_padding, y = -55}
    local first = true

    for k, v in pairs(options) do
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
        end

        local of = CreateFrame("Button", v.optionName, panel, optionFrameType)

        if newLine and not first or padding.x > 440 then
            padding.y = padding.y + (pY + box_padding)
            padding.x = box_padding
        end
        if first then
            first = false
        end

        of:ClearAllPoints()
        of:SetPoint("TOPLEFT", panel, "TOPLEFT", padding.x, padding.y)
        of.title:SetText(v.name)
        of.title:SetFont(DAMAGE_TEXT_FONT, 12)
        of.title:SetTextColor(1, 1, 1)
        of.title:SetShadowColor(0, 0, 0, 1)

        of:SetScript(
            "OnEnter",
            function()
                GameTooltip:SetOwner(of, "ANCHOR_CURSOR", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(v.name, 1, 1, 1)
                GameTooltip:AddLine(v.desc, 1, 1, 1)
                GameTooltip:Show()
            end
        )
        of:SetScript("OnLeave", GameTooltip_Hide)

        if v.optionType == "dropdown" then
            local i = 1
            local pre = of.container
            for key, val in pairs(v.options) do
                local dd =
                    CreateFrame(
                    "Button",
                    nil,
                    of.container,
                    "GwDropDownItemTmpl"
                )
                dd:SetPoint("TOPRIGHT", pre, "BOTTOMRIGHT")

                dd.string:SetFont(UNIT_NAME_FONT, 12)
                of.button.string:SetFont(UNIT_NAME_FONT, 12)
                dd.string:SetText(v.options_names[key])
                pre = dd

                if GetSetting(v.optionName, v.perSpec) == val then
                    of.button.string:SetText(v.options_names[key])
                end

                dd:SetScript(
                    "OnClick",
                    function(self, button)
                        local ddof = self:GetParent():GetParent()
                        ddof.button.string:SetText(v.options_names[key])

                        if ddof.container:IsShown() then
                            ddof.container:Hide()
                        else
                            ddof.container:Show()
                        end

                        SetSetting(v.optionName, val, v.perSpec)

                        if v.callback ~= nil then
                            v.callback()
                        end
                        --Check all dependencies on this option
                        checkDependenciesOnLoad()
                    end
                )

                i = i + 1
            end
            of.button:SetScript(
                "OnClick",
                function(self, button)
                    local dd = self:GetParent()
                    if dd.container:IsShown() then
                        dd.container:Hide()
                    else
                        dd.container:Show()
                    end
                end
            )
        end

        if v.optionType == "slider" then
            of.slider:SetMinMaxValues(v.min, v.max)
            of.slider:SetValue(GetSetting(v.optionName, v.perSpec))
            if v.step then of.slider:SetValueStep(v.step) end
            of.slider:SetObeyStepOnDrag(true)
            of.slider:SetScript(
                "OnValueChanged",
                function(self)
                    local roundValue = RoundDec(self:GetValue(), v.decimalNumbers)

                    SetSetting(v.optionName, roundValue, v.perSpec)
                    self:GetParent().input:SetText(roundValue)
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
            of.input:SetNumber(RoundDec(GetSetting(v.optionName), v.decimalNumbers))
            of.input:SetScript(
                "OnEnterPressed",
                function(self)
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
                    SetSetting(v.optionName, roundValue, v.perSpec)
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
        end

        if v.optionType == "text" then
            of.input:SetText(GetSetting(v.optionName, v.perSpec) or "")
            of.input:SetScript(
                "OnEnterPressed",
                function(self)
                    self:ClearFocus()
                    SetSetting(v.optionName, self:GetText(), v.perSpec)
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
        end

        if v.optionType == "boolean" then
            of.checkbutton:SetChecked(GetSetting(v.optionName, v.perSpec))
            of.checkbutton:SetScript(
                "OnClick",
                function(self, button)
                    local toSet = false
                    if self:GetChecked() then
                        toSet = true
                    end
                    SetSetting(v.optionName, toSet, v.perSpec)

                    if v.callback ~= nil then
                        v.callback(toSet)
                    end
                    --Check all dependencies on this option
                    checkDependenciesOnLoad()
                end
            )
            of:SetScript(
                "OnClick",
                function(self)
                    local toSet = true
                    if self.checkbutton:GetChecked() then
                        toSet = false
                    end
                    self.checkbutton:SetChecked(toSet)
                    SetSetting(v.optionName, toSet, v.perSpec)

                    if v.callback ~= nil then
                        v.callback(toSet)
                    end
                    --Check all dependencies on this option
                    checkDependenciesOnLoad()
                end
            )
        end

        if v.perSpec then
            local onUpdate = function (self)
                self:SetScript("OnUpdate", nil)
                local val = GetSetting(v.optionName, true)

                if v.optionType == "dropdown" then
                    for i,value in pairs(v.options) do
                        if value == val then self.button.string:SetText(v.options_names[i]) break end
                    end
                elseif v.optionType == "slider" then
                    self.slider:SetValue(val)
                elseif v.optionType == "text" then
                    self.input:SetText(val)
                elseif v.optionType == "boolean" then
                    self.checkbutton:SetChecked(val)
                end

                if v.callback and v.optionType ~= "slider" then
                    v.callback()
                end
            end
            of:SetScript("OnEvent", function (self, e)
                if e == "PLAYER_SPECIALIZATION_CHANGED" then
                    self:SetScript("OnUpdate", onUpdate)
                end
            end)
            of:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        end

        if newLine == false then
            padding.x = padding.x + of:GetWidth() + box_padding
        end
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
    local fnGWP_accept_OnClick = function(self, button)
        if self:GetParent().method ~= nil then
            self:GetParent().method()
        end
        self:GetParent():Hide()
    end
    local fnGWP_cancel_OnClick = function(self, button)
        self:GetParent():Hide()
    end
    fmGWP.acceptButton:SetScript("OnClick", fnGWP_accept_OnClick)
    fmGWP.cancelButton:SetScript("OnClick", fnGWP_cancel_OnClick)

    tinsert(UISpecialFrames, "GwWarningPrompt")

    local fnMf_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnMf_OnDragStop = function(self)
        -- check if frame is out of screen, if yes move it back
        ValidateFramePosition(self)
        self:StopMovingOrSizing()
    end
    local mf = CreateFrame("Frame", "GwSettingsMoverFrame", UIParent, "GwSettingsMoverFrame")
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", fnMf_OnDragStart)
    mf:SetScript("OnDragStop", fnMf_OnDragStop)

    local sWindow = CreateFrame("Frame", "GwSettingsWindow", UIParent, "GwSettingsWindowTmpl")
    tinsert(UISpecialFrames, "GwSettingsWindow")
    local fmGSWMH = GwSettingsWindowMoveHud
    local fmGSWS = sWindow.save
    local fmGSWD = sWindow.discord
    local fmGSWKB = sWindow.keyBind

    sWindow.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    sWindow.versionString:SetFont(UNIT_NAME_FONT, 12)
    sWindow.versionString:SetText(GW.VERSION_STRING)
    sWindow.headerString:SetText(CHAT_CONFIGURATION)
    fmGSWMH:SetText(L["MOVE_HUD_BUTTON"])
    fmGSWS:SetText(L["SETTINGS_SAVE_RELOAD"])
    fmGSWKB:SetText(KEY_BINDING)
    fmGSWD:SetText(L["DISCORD"])

    StaticPopupDialogs["JOIN_DISCORD"] = {
        text = L["DISCORD"],
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
        preferredIndex = 3
    }

    local fnGSWMH_OnClick = function(self, button)
        if InCombatLockdown() then
            DEFAULT_CHAT_FRAME:AddMessage(L["HUD_MOVE_ERR"])
            return
        end
        moveHudObjects(self)
    end
    local fnGSWS_OnClick = function(self, button)
        C_UI.Reload()
    end
    local fnGSWD_OnClick = function(self, button)
        StaticPopup_Show("JOIN_DISCORD")
    end
    local fmGSWKB_OnClick = function(self, button)
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
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFB900<GW2_UI>|r " .. L["HIDE_SETTING_IN_COMBAT"])
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

    local lhb = CreateFrame("Button", nil, UIParent, "GwStandardButton")
    lhb:SetScript("OnClick", lockHudObjects)
    lhb:ClearAllPoints()
    lhb:SetText(L["SETTING_LOCK_HUD"])
    lhb:SetPoint("TOP", UIParent, "TOP", 0, 0)
    lhb:Hide()
    fmGSWMH.lhb = lhb

    local mhgb = CreateFrame("Button", nil, UIParent, "GwStandardButton")
    mhgb:SetScript("OnClick", Grid_Show_Hide)
    mhgb:ClearAllPoints()
    mhgb:SetText(L["GRID_BUTTON_SHOW"])
    mhgb:SetPoint("TOP", UIParent, "TOP", 0, -26)
    mhgb:Hide()
    mhgb.gridSize = 64
    mhgb.forceHide = false
    create_grid(mhgb)

    mhgb.grid_align = CreateFrame("EditBox", nil, UIParent, "GwStandardInputBox")
    mhgb.grid_align:SetPoint("TOP", UIParent, "TOP", 44, -55)
    mhgb.grid_align:SetScript("OnEscapePressed", function(eb)
        eb:SetText(mhgb.gridSize)
        EditBox_ClearFocus(eb)
    end)
    mhgb.grid_align:SetScript("OnEnterPressed", function(eb)
        local text = eb:GetText()
        if tonumber(text) then
            if tonumber(text) <= 256 and tonumber(text) >= 4 then
                mhgb.gridSize = tonumber(text)
            else
                eb:SetText(mhgb.gridSize)
            end
        else
            eb:SetText(mhgb.gridSize)
        end
        mhgb.forceHide = false
        Grid_Show_Hide(mhgb)
        EditBox_ClearFocus(eb)
    end)
    mhgb.grid_align:SetScript("OnEditFocusLost", function(eb)
        eb:SetText(mhgb.gridSize)
    end)
    mhgb.grid_align:SetScript("OnEditFocusGained", mhgb.grid_align.HighlightText)
    mhgb.grid_align:SetScript("OnShow", function(eb)
        EditBox_ClearFocus(eb)
        eb:SetText(mhgb.gridSize)
    end)
    mhgb.grid_align.text = mhgb.grid_align:CreateFontString(nil, "OVERLAY", "GW_Standard_Button_Font")
    mhgb.grid_align.text:SetPoint("RIGHT", mhgb.grid_align, "LEFT", -5, 0)
    mhgb.grid_align.text:SetText(L["GRID_SIZE_LABLE"])
    mhgb.grid_align:Hide()
    lhb.mhgb = mhgb
    fmGSWMH.mhgb = mhgb

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

    -- change the blizzard actionbarsettings on "InterfaceOptions_OnShow" 
    InterfaceOptionsFrame:HookScript("OnShow", function()
        local bar1, bar2, bar3, bar4 = GetSetting("GW_SHOW_MULTI_ACTIONBAR_1"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_2"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_3"), GetSetting("GW_SHOW_MULTI_ACTIONBAR_4")
        _G.InterfaceOptionsActionBarsPanelBottomLeft:SetChecked(bar1)
        _G.InterfaceOptionsActionBarsPanelBottomRight:SetChecked(bar2)
        _G.InterfaceOptionsActionBarsPanelRight:SetChecked(bar3)
        _G.InterfaceOptionsActionBarsPanelRightTwo:SetChecked(bar4)
    end)

    local fnGSBC_OnClick = function(self)
        self:GetParent():Hide()
    end
    sWindow.close:SetScript("OnClick", fnGSBC_OnClick)

    switchCat(1)
    GwSettingsWindow:Hide()
end
GW.LoadSettings = LoadSettings
