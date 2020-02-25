local _, GW = ...
local CountTable = GW.CountTable
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local MOVABLE_FRAMES = GW.MOVABLE_FRAMES
local UpdateFramePositions = GW.UpdateFramePositions
local Debug = GW.Debug

local settings_cat = {}
local options = {}

local lhb

SLASH_GWSLASH1 = "/gw2"
function SlashCmdList.GWSLASH(msg)
    GwSettingsWindow:Show()
    UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
end

local function switchCat(index)
    for i = 0, 20 do
        if _G["GwSettingsLabel" .. i] ~= nil then
            _G["GwSettingsLabel" .. i].iconbg:Hide()
        end
    end

    _G["GwSettingsLabel" .. index].iconbg:Show()

    for k, v in pairs(settings_cat) do
        if k ~= index then
            _G[v]:Hide()
        else
            _G[v]:Show()
            UIFrameFadeIn(_G[v], 0.2, 0, 1)
        end
    end
end

local function CreateCat(name, desc, frameName, icon)
    local i = CountTable(settings_cat)
    settings_cat[i] = frameName

    local fnF_OnEnter = function(self)
        self.icon:SetBlendMode("ADD")
    end
    local fnF_OnLeave = function(self)
        self.icon:SetBlendMode("BLEND")
    end
    local f = CreateFrame("Button", "GwSettingsLabel" .. i, GwSettingsWindow, "GwSettingsLabelTmpl")
    f:SetScript("OnEnter", fnF_OnEnter)
    f:SetScript("OnLeave", fnF_OnLeave)
    f:SetPoint("TOPLEFT", -40, -32 + (-40 * i))

    f.icon:SetTexCoord(0, 0.5, 0.25 * icon, 0.25 * (icon + 1))
    if icon > 3 then
        icon = icon - 4
        f.icon:SetTexCoord(0.5, 1, 0.25 * icon, 0.25 * (icon + 1))
    end

    f:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(f, "ANCHOR_LEFT", 0, -40)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(name, 1, 1, 1)
            GameTooltip:AddLine(desc, 1, 1, 1)
            GameTooltip:Show()
        end
    )
    f:SetScript("OnLeave", GameTooltip_Hide)

    f:SetScript(
        "OnClick",
        function(event)
            switchCat(i)
        end
    )
end
GW.CreateCat = CreateCat

local function AddOption(name, desc, optionName, frameName, callback, params)
    local i = CountTable(options)

    options[i] = {}
    options[i]["name"] = name
    options[i]["desc"] = desc
    options[i]["optionName"] = optionName
    options[i]["frameName"] = frameName
    options[i]["optionType"] = "boolean"
    options[i]["callback"] = callback

    if params then
        for k,v in pairs(params) do options[i][k] = v end
    end
end
GW.AddOption = AddOption

local function AddOptionSlider(name, desc, optionName, frameName, callback, min, max, params)
    local i = CountTable(options)

    options[i] = {}
    options[i]["name"] = name
    options[i]["desc"] = desc
    options[i]["optionName"] = optionName
    options[i]["frameName"] = frameName
    options[i]["callback"] = callback
    options[i]["min"] = min
    options[i]["max"] = max
    options[i]["optionType"] = "slider"

    if params then
        for k,v in pairs(params) do options[i][k] = v end
    end
end
GW.AddOptionSlider = AddOptionSlider

local function AddOptionText(name, desc, optionName, frameName, callback, multiline, params)
    local i = CountTable(options)

    options[i] = {}
    options[i]["name"] = name
    options[i]["desc"] = desc
    options[i]["optionName"] = optionName
    options[i]["frameName"] = frameName
    options[i]["callback"] = callback
    options[i]["multiline"] = multiline
    options[i]["optionType"] = "text"

    if params then
        for k,v in pairs(params) do options[i][k] = v end
    end
end
GW.AddOptionText = AddOptionText

local function AddOptionDropdown(name, desc, optionName, frameName, callback, options_list, option_names, params)
    local i = CountTable(options)

    options[i] = {}
    options[i]["name"] = name
    options[i]["desc"] = desc
    options[i]["optionName"] = optionName
    options[i]["frameName"] = frameName
    options[i]["callback"] = callback
    options[i]["options"] = {}
    options[i]["options"] = options_list
    options[i]["options_names"] = option_names
    options[i]["optionType"] = "dropdown"

    if params then
        for k,v in pairs(params) do options[i][k] = v end
    end
end
GW.AddOptionDropdown = AddOptionDropdown

local settings_window_open_before_change = false
local function moveHudObjects()
    lhb:Show()
    if GwSettingsWindow:IsShown() then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for k, v in pairs(MOVABLE_FRAMES) do
        v:EnableMouse(true)
        v:SetMovable(true)
        v:Show()
    end
end
GW.moveHudObjects = moveHudObjects

local function lockHudObjects()
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(GwLocalization["HUD_MOVE_ERR"])
        return
    end
    lhb:Hide()
    if settings_window_open_before_change then
        settings_window_open_before_change = false
        GwSettingsWindow:Show()
    end

    for k, v in pairs(MOVABLE_FRAMES) do
        v:EnableMouse(false)
        v:SetMovable(false)
        v:Hide()
    end
    UpdateFramePositions()
    C_UI.Reload()
end

local function WarningPrompt(text, method)
    GwWarningPrompt.string:SetText(text)
    GwWarningPrompt.method = method
    GwWarningPrompt:Show()
    GwWarningPrompt.input:Hide()
end
GW.WarningPrompt = WarningPrompt

local function DisplaySettings()
    local box_padding = 8
    local pX = 244
    local pY = -48

    local padding = {}

    for k, v in pairs(options) do
        local first, newLine = false, false
        if padding[v.frameName] == nil then
            padding[v.frameName] = {}
            padding[v.frameName].x = box_padding
            padding[v.frameName].y = -55
            first = true
        end
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

        local of = CreateFrame("Button", "GwOptionBox" .. k, _G[v.frameName], optionFrameType)

        if newLine and not first or padding[v.frameName].x > 440 then
            padding[v.frameName].y = padding[v.frameName].y + (pY + box_padding)
            padding[v.frameName].x = box_padding
        end

        of:ClearAllPoints()
        of:SetPoint("TOPLEFT", padding[v.frameName].x, padding[v.frameName].y)
        _G["GwOptionBox" .. k].title:SetText(v.name)
        _G["GwOptionBox" .. k].title:SetFont(DAMAGE_TEXT_FONT, 12)
        _G["GwOptionBox" .. k].title:SetTextColor(1, 1, 1)
        _G["GwOptionBox" .. k].title:SetShadowColor(0, 0, 0, 1)

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
            local pre = _G["GwOptionBox" .. k].container
            for key, val in pairs(v.options) do
                local dd =
                    CreateFrame(
                    "Button",
                    "GwOptionBoxdropdown" .. i,
                    _G[v.frameName].container,
                    "GwDropDownItemTmpl"
                )
                dd:SetPoint("TOPRIGHT", pre, "BOTTOMRIGHT")
                dd:SetParent(_G["GwOptionBox" .. k].container)

                dd.string:SetFont(UNIT_NAME_FONT, 12)
                _G["GwOptionBox" .. k].button.string:SetFont(UNIT_NAME_FONT, 12)
                dd.string:SetText(v.options_names[key])
                pre = dd

                if GetSetting(v.optionName, v.perSpec) == val then
                    _G["GwOptionBox" .. k].button.string:SetText(v.options_names[key])
                end

                dd:SetScript(
                    "OnClick",
                    function()
                        _G["GwOptionBox" .. k].button.string:SetText(v.options_names[key])

                        if _G["GwOptionBox" .. k].container:IsShown() then
                            _G["GwOptionBox" .. k].container:Hide()
                        else
                            _G["GwOptionBox" .. k].container:Show()
                        end

                        SetSetting(v.optionName, val, v.perSpec)

                        if v.callback ~= nil then
                            v.callback()
                        end
                    end
                )

                i = i + 1
            end
            _G["GwOptionBox" .. k].button:SetScript(
                "OnClick",
                function()
                    if _G["GwOptionBox" .. k].container:IsShown() then
                        _G["GwOptionBox" .. k].container:Hide()
                    else
                        _G["GwOptionBox" .. k].container:Show()
                    end
                end
            )
        end

        if v.optionType == "slider" then
            _G["GwOptionBox" .. k].slider:SetMinMaxValues(v.min, v.max)
            _G["GwOptionBox" .. k].slider:SetValue(GetSetting(v.optionName, v.perSpec))
            _G["GwOptionBox" .. k].slider.label:SetText(GW.RoundInt(GetSetting(v.optionName)))
            _G["GwOptionBox" .. k].slider:SetScript(
                "OnValueChanged",
                function()
                    SetSetting(v.optionName, _G["GwOptionBox" .. k].slider:GetValue(), v.perSpec)
                    _G["GwOptionBox" .. k].slider.label:SetText(GW.RoundInt(_G["GwOptionBox" .. k].slider:GetValue()))
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
        end

        if v.optionType == "text" then
            _G["GwOptionBox" .. k].input:SetText(GetSetting(v.optionName, v.perSpec) or "")
            _G["GwOptionBox" .. k].input:SetScript(
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
            _G["GwOptionBox" .. k].checkbutton:SetChecked(GetSetting(v.optionName, v.perSpec))
            _G["GwOptionBox" .. k].checkbutton:SetScript(
                "OnClick",
                function()
                    toSet = false
                    if _G["GwOptionBox" .. k].checkbutton:GetChecked() then
                        toSet = true
                    end
                    SetSetting(v.optionName, toSet, v.perSpec)

                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
            of:SetScript(
                "OnClick",
                function(self)
                    toSet = true
                    if self.checkbutton:GetChecked() then
                        toSet = false
                    end
                    self.checkbutton:SetChecked(toSet)
                    SetSetting(v.optionName, toSet, v.perSpec)

                    if v.callback ~= nil then
                        v.callback()
                    end
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
            _G["GwOptionBox" .. k]:SetScript("OnEvent", function (self, e)
                if e == "PLAYER_SPECIALIZATION_CHANGED" then
                    self:SetScript("OnUpdate", onUpdate)
                end
            end)
            _G["GwOptionBox" .. k]:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        end

        if newLine == false then
            padding[v.frameName].x = padding[v.frameName].x + of:GetWidth() + box_padding
        end

        if GetSetting("CURSOR_ANCHOR_TYPE") == "ANCHOR_CURSOR" then
            if v.optionName == "ANCHOR_CURSOR_OFFSET_X" or v.optionName == "ANCHOR_CURSOR_OFFSET_Y" then
                if _G["GwOptionBox" .. k].slider then
                    _G["GwOptionBox" .. k].slider:Disable()
                    SetSetting(v.optionName, 0)
                    _G["GwOptionBox" .. k].slider:SetValue(0)
                    _G["GwOptionBox" .. k].title:SetTextColor(0.82, 0.82, 0.82)
                    _G["GwOptionBox" .. k].slider.label:SetTextColor(0.82, 0.82, 0.82)
                end
            end
        else
            if v.optionName == "ANCHOR_CURSOR_OFFSET_X" or v.optionName == "ANCHOR_CURSOR_OFFSET_Y" then
                if _G["GwOptionBox" .. k].slider then
                    _G["GwOptionBox" .. k].slider:Enable()
                    _G["GwOptionBox" .. k].title:SetTextColor(1, 1, 1)
                    _G["GwOptionBox" .. k].slider.label:SetTextColor(1, 1, 1)
                end
            end
        end
    end
end
GW.DisplaySettings = DisplaySettings

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
    local fmGSWWELCOME = WelcomeScreen

    sWindow.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    sWindow.versionString:SetFont(UNIT_NAME_FONT, 12)
    sWindow.versionString:SetText(GW.VERSION_STRING)
    sWindow.headerString:SetText(CHAT_CONFIGURATION)
    GwSettingsWindowMoveHud:SetText(GwLocalization["MOVE_HUD_BUTTON"])
    fmGSWS:SetText(GwLocalization["SETTINGS_SAVE_RELOAD"])
    fmGSWKB:SetText(KEY_BINDING)
    fmGSWD:SetText(GwLocalization["DISCORD"])
    --WelcomeScreen:SetText(GwLocalization["WELCOME"])

    StaticPopupDialogs["JOIN_DISCORD"] = {
        text = GwLocalization["DISCORD"],
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
            DEFAULT_CHAT_FRAME:AddMessage(GwLocalization["HUD_MOVE_ERR"])
            return
        end
        moveHudObjects()
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
    local fmGSWWELCOME_OnClick = function(self, button)
        GwSettingsWindow:Hide()
        --Show Welcome page
        local GwWelcomePage = CreateFrame("Frame", nil, UIParent, "GwWelcomePageTmpl")
        GwWelcomePage.subHeader:SetText(GW.VERSION_STRING)
        GwWelcomePage.changelog.scroll.scrollchild.text:SetText(GW.GW_CHANGELOGS)
        GwWelcomePage.changelog.scroll.slider:SetMinMaxValues(0, GwWelcomePage.changelog.scroll.scrollchild.text:GetStringHeight())
        GwWelcomePage.changelog.scroll.slider.thumb:SetHeight(100)
        GwWelcomePage.changelog.scroll.slider:SetValue(1)
        GwWelcomePage.changelog:Hide()
        GwWelcomePage.welcome:Show()
        GwWelcomePage.changelogORwelcome:SetText(GwLocalization["CHANGELOG"])
        if GetSetting("PIXEL_PERFECTION") then
            GwWelcomePage.welcome.pixelbutton:SetText(GwLocalization["PIXEL_PERFECTION_OFF"])
        end
        --Button
        GwWelcomePage.movehud:SetScript("OnClick", function()
            GwWelcomePage:Hide()
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage(GwLocalization["HUD_MOVE_ERR"])
                return
            end
            GW.moveHudObjects()
        end)
        GwWelcomePage.welcome.pixelbutton:SetScript("OnClick", function(self)
            if self:GetText() == GwLocalization["PIXEL_PERFECTION_ON"] then
                GW.pixelPerfection()
                SetSetting("PIXEL_PERFECTION", true)
                self:SetText(GwLocalization["PIXEL_PERFECTION_OFF"])
            else
                SetCVar("useUiScale", true)
                SetCVar("useUiScale", false)
                SetSetting("PIXEL_PERFECTION", false)
                self:SetText(GwLocalization["PIXEL_PERFECTION_ON"])
            end
        end)
        --Save current Version
        SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
    end
    fmGSWMH:SetScript("OnClick", fnGSWMH_OnClick)
    fmGSWS:SetScript("OnClick", fnGSWS_OnClick)
    fmGSWD:SetScript("OnClick", fnGSWD_OnClick)
    fmGSWKB:SetScript("OnClick", fmGSWKB_OnClick)
    --fmGSWWELCOME:SetScript("OnClick", fmGSWWELCOME_OnClick)

    sWindow:SetScript(
        "OnShow",
        function()
            mf:Show()
        end
    )
    sWindow:SetScript(
        "OnHide",
        function()
            mf:Hide()
        end
    )
    mf:Hide()



    lhb = CreateFrame("Button", "GwLockHudButton", UIParent, "GwStandardButton")
    lhb:SetScript("OnClick", lockHudObjects)
    lhb:ClearAllPoints()
    lhb:SetText(GwLocalization["SETTING_LOCK_HUD"])
    lhb:SetPoint("TOP", UIParent, "TOP", 0, 0)
    lhb:Hide()

    GW.LoadModulesPanel(sWindow)
    GW.LoadPlayerPanel(sWindow)
    GW.LoadTargetPanel(sWindow)
    GW.LoadActionbarPanel(sWindow)
    GW.LoadHudPanel(sWindow)
    GW.LoadPartyPanel(sWindow)
    GW.LoadRaidPanel(sWindow)
    GW.LoadAurasPanel(sWindow)
    GW.LoadSkinsPanel(sWindow)
    GW.LoadProfilesPanel(sWindow)

    local fnGSBC_OnClick = function(self)
        self:GetParent():Hide()
    end
    sWindow.close:SetScript("OnClick", fnGSBC_OnClick)

    _G["GwSettingsLabel9"].iconbg:SetTexture("Interface/AddOns/GW2_UI/textures/settingsiconbg-2")

    switchCat(0)
    GwSettingsWindow:Hide()

end
GW.LoadSettings = LoadSettings

