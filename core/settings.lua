local _, GW = ...
local SetMinimapHover = GW.SetMinimapHover
local CountTable = GW.CountTable
local GetActiveProfile = GW.GetActiveProfile
local SetProfileSettings = GW.SetProfileSettings
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local ResetToDefault = GW.ResetToDefault
local GetSettingsProfiles = GW.GetSettingsProfiles
local UpdateRaidFramesPosition = GW.UpdateRaidFramesPosition
local UpdateRaidFramesLayout = GW.UpdateRaidFramesLayout
local MOVABLE_FRAMES = GW.MOVABLE_FRAMES
local UpdateFramePositions = GW.UpdateFramePositions
local UpdateHudScale = GW.UpdateHudScale
local StrUpper = GW.StrUpper
local MapTable = GW.MapTable
local Debug = GW.Debug

local settings_cat = {}
local options = {}
local GW_PROFILE_ICONS_PRESET = {}

local lhb

GW_PROFILE_ICONS_PRESET[0] = "Interface\\icons\\spell_druid_displacement"
GW_PROFILE_ICONS_PRESET[1] = "Interface\\icons\\ability_socererking_arcanemines"
GW_PROFILE_ICONS_PRESET[2] = "Interface\\icons\\ability_warrior_bloodbath"
GW_PROFILE_ICONS_PRESET[3] = "Interface\\icons\\ability_priest_ascendance"
GW_PROFILE_ICONS_PRESET[4] = "Interface\\icons\\spell_mage_overpowered"
GW_PROFILE_ICONS_PRESET[5] = "Interface\\icons\\achievement_boss_kingymiron"
GW_PROFILE_ICONS_PRESET[6] = "Interface\\icons\\spell_fire_elementaldevastation"

SLASH_GWSLASH1 = "/gw2"
function SlashCmdList.GWSLASH(msg)
    GwSettingsWindow:Show()
    UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
end

-- local forward function defs
local updateProfiles = nil

local function deleteProfile(index)
    GW2UI_SETTINGS_PROFILES[index] = nil
    if GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] ~= nil and GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] == index then
        SetSetting("ACTIVE_PROFILE", nil)
    end
end

local function setProfile(index)
    GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index
    C_UI.Reload()
end

local function gwProfileItem_delete_OnEnter(self)
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
end

local function gwProfileItem_delete_OnClick(self, button)
    GW.WarningPrompt(
        GwLocalization["PROFILES_DELETE"],
        function()
            deleteProfile(self:GetParent().profileID)
            updateProfiles()
        end
    )
end

local function gwProfileItem_activate_OnEnter(self)
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
end

local function gwProfileItem_activate_OnClick(self, button)
    setProfile(self:GetParent().profileID)
    updateProfiles()
    self:Hide()
end

local function gwProfileItem_OnLoad(self)
    self.name:SetFont(UNIT_NAME_FONT, 14)
    self.name:SetTextColor(1, 1, 1)
    self.desc:SetFont(UNIT_NAME_FONT, 12)
    self.desc:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    self.desc:SetText(GwLocalization["PROFILES_MISSING_LOAD"])

    self.deleteButton.string:SetFont(UNIT_NAME_FONT, 12)
    self.deleteButton.string:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    self.deleteButton.string:SetText(DELETE)

    self.activateButton:SetText(ACTIVATE)

    self.deleteButton:SetScript("OnEnter", gwProfileItem_delete_OnEnter)
    self.deleteButton:SetScript("OnClick", gwProfileItem_delete_OnClick)
    self.activateButton:SetScript("OnEnter", gwProfileItem_activate_OnEnter)
    self.activateButton:SetScript("OnClick", gwProfileItem_activate_OnClick)
end

local function gwProfileItem_OnEnter(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Show()
    end
    if self.activateAble ~= nil and self.activateAble == true then
        self.activateButton:Show()
    end
    self.background:SetBlendMode("ADD")
end

local function gwProfileItem_OnLeave(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Hide()
    end
    self.activateButton:Hide()
    self.background:SetBlendMode("BLEND")
end

updateProfiles = function()
    local currentProfile = GetActiveProfile()

    local h = 0
    local profiles = GetSettingsProfiles()
    for i = 0, 6 do
        local k = i
        local v = profiles[i]
        local f = _G["GwProfileItem" .. k]
        if f == nil then
            f = CreateFrame("Button", "GwProfileItem" .. k, GwSettingsProfilesframe.scrollchild, "GwProfileItem")
            f:SetScript("OnEnter", gwProfileItem_OnEnter)
            f:SetScript("OnLeave", gwProfileItem_OnLeave)
            gwProfileItem_OnLoad(f)
        end

        if v ~= nil then
            f:Show()
            f.profileID = k
            f.icon:SetTexture(GW_PROFILE_ICONS_PRESET[k])

            f.deleteable = true
            f.background:SetTexCoord(0, 1, 0, 0.5)
            f.activateAble = true
            if currentProfile == k then
                f.background:SetTexCoord(0, 1, 0.5, 1)
                f.activateAble = false
            end

            local description =
                GwLocalization["PROFILES_CREATED"] ..
                v["profileCreatedDate"] ..
                    GwLocalization["PROFILES_CREATED_BY"] ..
                        v["profileCreatedCharacter"] ..
                            GwLocalization["PROFILES_LAST_UPDATE"] .. v["profileLastUpdated"]

            f.name:SetText(v["profilename"])
            f.desc:SetText(description)
            f:SetPoint("TOPLEFT", 15, (-70 * h) + -120)
            h = h + 1
        else
            f:Hide()
        end
    end

    if h < 6 then
        GwCreateNewProfile:Enable()
    else
        GwCreateNewProfile:Disable()
    end

    local scrollM = (120 + (70 * h))
    local scroll = 0
    local thumbheight = 1

    if scrollM > 440 then
        scroll = math.abs(440 - scrollM)
        thumbheight = 100
    end

    GwSettingsProfilesframe.scrollFrame:SetScrollChild(GwSettingsProfilesframe.scrollchild)
    GwSettingsProfilesframe.scrollFrame.maxScroll = scroll

    GwSettingsProfilesframe.slider.thumb:SetHeight(thumbheight)
    GwSettingsProfilesframe.slider:SetMinMaxValues(0, scroll)
end

local function addProfile(name)
    local index = 0
    local profileList = GetSettingsProfiles()

    for i = 0, 7 do
        index = i
        if profileList[i] == nil then
            break
        end
    end

    if index > 6 then
        return
    end

    GW2UI_SETTINGS_PROFILES[index] = {}
    GW2UI_SETTINGS_PROFILES[index]["profilename"] = name
    GW2UI_SETTINGS_PROFILES[index]["profileCreatedDate"] = date("%m/%d/%y %H:%M:%S")
    GW2UI_SETTINGS_PROFILES[index]["profileCreatedCharacter"] = GetUnitName("player", true)
    GW2UI_SETTINGS_PROFILES[index]["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")

    GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index
    SetProfileSettings()
    updateProfiles()
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

local function createCat(name, desc, frameName, icon)
    local i = CountTable(settings_cat)
    settings_cat[i] = frameName

    local fnF_OnEnter = function(self)
        _G[self:GetName() .. "Texture"]:SetBlendMode("ADD")
    end
    local fnF_OnLeave = function(self)
        _G[self:GetName() .. "Texture"]:SetBlendMode("BLEND")
    end
    local f = CreateFrame("Button", "GwSettingsLabel" .. i, UIParent, "GwSettingsLabel")
    f:SetScript("OnEnter", fnF_OnEnter)
    f:SetScript("OnLeave", fnF_OnLeave)
    f:SetPoint("TOPLEFT", -40, -32 + (-40 * i))

    _G["GwSettingsLabel" .. i .. "Texture"]:SetTexCoord(0, 0.5, 0.25 * icon, 0.25 * (icon + 1))
    if icon > 3 then
        icon = icon - 4
        _G["GwSettingsLabel" .. i .. "Texture"]:SetTexCoord(0.5, 1, 0.25 * icon, 0.25 * (icon + 1))
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

local function addOption(name, desc, optionName, frameName, callback, params)
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

local function addOptionSlider(name, desc, optionName, frameName, callback, min, max, params)
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

local function addOptionText(name, desc, optionName, frameName, callback, multiline, params)
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

local function addOptionDropdown(name, desc, optionName, frameName, callback, options_list, option_names, params)
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

local function inputPrompt(text, method)
    GwWarningPrompt.string:SetText(text)
    GwWarningPrompt.method = method
    GwWarningPrompt:Show()
    GwWarningPrompt.input:Show()
    GwWarningPrompt.input:SetText("")
end

local function inputDiscord(text, method, input)
    GwDiscordPrompt.string:SetText(text)
    GwDiscordPrompt.method = method
    GwDiscordPrompt:Show()
    GwDiscordPrompt.input:Show()
    GwDiscordPrompt.input:SetText(input)
end

local function setMultibarCols()
    local cols = GetSetting("MULTIBAR_RIGHT_COLS")
    Debug("setting multibar cols", cols)
    local mb1 = GetSetting("MultiBarRight")
    local mb2 = GetSetting("MultiBarLeft")
    mb1["ButtonsPerRow"] = cols
    mb2["ButtonsPerRow"] = cols
    SetSetting("MultiBarRight", mb1)
    SetSetting("MultiBarLeft", mb2)
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
        local optionFrameType = "GwOptionBox"
        if v.optionType == "slider" then
            optionFrameType = "GwOptionBoxSlider"
            newLine = true
        end
        if v.optionType == "dropdown" then
            optionFrameType = "GwOptionBoxDropDown"
            newLine = true
        end
        if v.optionType == "text" then
            optionFrameType = "GwOptionBoxText"
            newLine = true
        end

        local of = CreateFrame("Button", "GwOptionBox" .. k, _G[v.frameName], optionFrameType)
        
        if v.margin or newLine and not first or padding[v.frameName].x > 440 then
            padding[v.frameName].y = padding[v.frameName].y + (pY + box_padding) * (v.margin and 2 or 1)
            padding[v.frameName].x = box_padding
        end

        of:ClearAllPoints()
        of:SetPoint("TOPLEFT", padding[v.frameName].x, padding[v.frameName].y)
        _G["GwOptionBox" .. k .. "Title"]:SetText(v.name)
        _G["GwOptionBox" .. k .. "Title"]:SetFont(DAMAGE_TEXT_FONT, 12)
        _G["GwOptionBox" .. k .. "Title"]:SetTextColor(1, 1, 1)
        _G["GwOptionBox" .. k .. "Title"]:SetShadowColor(0, 0, 0, 1)

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
                    "GwOptionBox" .. "dropdown" .. i,
                    _G[v.frameName].container,
                    "GwDropDownItem"
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
            _G["GwOptionBox" .. k .. "Slider"]:SetMinMaxValues(v.min, v.max)
            _G["GwOptionBox" .. k .. "Slider"]:SetValue(GetSetting(v.optionName, v.perSpec))
            _G["GwOptionBox" .. k .. "Slider"]:SetScript(
                "OnValueChanged",
                function()
                    SetSetting(v.optionName, _G["GwOptionBox" .. k .. "Slider"]:GetValue(), v.perSpec)
                    if v.callback ~= nil then
                        v.callback()
                    end
                end
            )
        end

        if v.optionType == "text" then
            _G["GwOptionBox" .. k .. "Input"]:SetText(GetSetting(v.optionName, v.perSpec) or "")
            _G["GwOptionBox" .. k .. "Input"]:SetScript(
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
            _G["GwOptionBox" .. k .. "CheckButton"]:SetChecked(GetSetting(v.optionName, v.perSpec))
            _G["GwOptionBox" .. k .. "CheckButton"]:SetScript(
                "OnClick",
                function()
                    toSet = false
                    if _G["GwOptionBox" .. k .. "CheckButton"]:GetChecked() then
                        toSet = true
                    end
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

    local fmGWD = CreateFrame("Frame", "GwDiscordPrompt", UIParent, "GwDiscordPrompt")
    fmGWD.string:SetFont(UNIT_NAME_FONT, 14)
    fmGWD.string:SetTextColor(1, 1, 1)
    fmGWD.acceptButton:SetText(ACCEPT)
    local fmGWD_input_OnEscapePressed = function(self)
        self:ClearFocus()
    end
    fmGWD.input:SetScript("OnEscapePressed", fmGWD_input_OnEscapePressed)
    fmGWD.input:SetScript("OnEditFocusGained", nil)
    fmGWD.input:SetScript("OnEditFocusLost", nil)
    fmGWD.input:SetScript("OnEnterPressed", nil)
    local fmGWD_accept_OnClick = function(self, button)
        self:GetParent():Hide()
    end
    fmGWD.acceptButton:SetScript("OnClick", fmGWD_accept_OnClick)

    tinsert(UISpecialFrames, "GwDiscordPrompt")

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

    local sWindow = CreateFrame("Frame", "GwSettingsWindow", UIParent, "GwSettingsWindow")
    tinsert(UISpecialFrames, "GwSettingsWindow")
    local fmGSWMH = GwSettingsWindowMoveHud
    local fmGSWS = GwSettingsWindowSave
    local fmGSWD = GwSettingsWindowDiscord
    local fmGSWKB = GwSettingsWindowKeyBind

    GwSettingsWindowHeaderString:SetFont(DAMAGE_TEXT_FONT, 24)
    GwSettingsWindowVersionString:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsWindowVersionString:SetText(GW.VERSION_STRING)
    GwSettingsWindowHeaderString:SetText(CHAT_CONFIGURATION)
    GwSettingsWindowMoveHud:SetText(GwLocalization["MOVE_HUD_BUTTON"])
    GwSettingsWindowSave:SetText(GwLocalization["SETTINGS_SAVE_RELOAD"])
    GwSettingsWindowKeyBind:SetText(KEY_BINDING)

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
        inputDiscord("Discord", nil, "https://discord.gg/MZZtRWt")
    end
    local fmGSWKB_OnClick = function(self, button)
        GwSettingsWindow:Hide()
        GW.hoverkeybinds()
    end
    fmGSWMH:SetScript("OnClick", fnGSWMH_OnClick)
    fmGSWS:SetScript("OnClick", fnGSWS_OnClick)
    fmGSWD:SetScript("OnClick", fnGSWD_OnClick)
    fmGSWKB:SetScript("OnClick", fmGSWKB_OnClick)

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

    GwMainMenuFrame = CreateFrame("Button", "GwMainMenuFrame", GameMenuFrame, "GwStandardButton")
    GwMainMenuFrame:SetText(GwLocalization["SETTINGS_BUTTON"])
    GwMainMenuFrame:ClearAllPoints()
    GwMainMenuFrame:SetPoint("TOP", GameMenuFrame, "BOTTOM", 0, 0)
    GwMainMenuFrame:SetSize(150, 24)
    GwMainMenuFrame:SetScript(
        "OnClick",
        function()
            sWindow:Show()
            if InCombatLockdown() then
                return
            end
            ToggleGameMenu()
        end
    )

    lhb = CreateFrame("Button", "GwLockHudButton", UIParent, "GwStandardButton")
    lhb:SetScript("OnClick", lockHudObjects)
    lhb:ClearAllPoints()
    lhb:SetText(GwLocalization["SETTING_LOCK_HUD"])
    lhb:SetPoint("TOP", UIParent, "TOP", 0, 0)
    lhb:Hide()

    GwSettingsModuleOptionHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsModuleOptionHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsModuleOptionHeader:SetText(GwLocalization["MODULES_CAT_1"])
    GwSettingsModuleOptionSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsModuleOptionSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsModuleOptionSub:SetText(GwLocalization["MODULES_DESC"])

    GwSettingsTargetOptionsHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsTargetOptionsHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsTargetOptionsHeader:SetText(TARGET)
    GwSettingsTargetOptionsSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsTargetOptionsSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsTargetOptionsSub:SetText(GwLocalization["TARGET_DESC"])

    GwSettingsFocusOptionsHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsFocusOptionsHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsFocusOptionsHeader:SetText(FOCUS)
    GwSettingsFocusOptionsSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsFocusOptionsSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsFocusOptionsSub:SetText(GwLocalization["FOCUS_DESC"])

    GwSettingsHudOptionsHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsHudOptionsHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsHudOptionsHeader:SetText(GwLocalization["HUD_CAT_1"])
    GwSettingsHudOptionsSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsHudOptionsSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsHudOptionsSub:SetText(GwLocalization["HUD_DESC"])

    GwSettingsGroupframeHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsGroupframeHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsGroupframeHeader:SetText(CHAT_MSG_PARTY)
    GwSettingsGroupframeSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsGroupframeSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsGroupframeSub:SetText(GwLocalization["GROUP_DESC"])

    GwSettingsGroupframe2Header:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsGroupframe2Header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsGroupframe2Header:SetText(CHAT_MSG_PARTY)
    GwSettingsGroupframe2Sub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsGroupframe2Sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsGroupframe2Sub:SetText(GwLocalization["GROUP_DESC"])

    GwSettingsAurasOptionsHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsAurasOptionsHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsAurasOptionsHeader:SetText(AURAS)
    GwSettingsAurasOptionsSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsAurasOptionsSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsAurasOptionsSub:SetText(GwLocalization["AURAS_DESC"])

    GwSettingsIndicatorsOptionsHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsIndicatorsOptionsHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    GwSettingsIndicatorsOptionsHeader:SetText(GwLocalization["INDICATORS"])
    GwSettingsIndicatorsOptionsSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsIndicatorsOptionsSub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsIndicatorsOptionsSub:SetText(GwLocalization["INDICATORS_DESC"])

    GwSettingsProfilesframeHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsProfilesframeHeader:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    GwSettingsProfilesframeHeader:SetText(GwLocalization["PROFILES_CAT_1"])
    GwSettingsProfilesframeSub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsProfilesframeSub:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    GwSettingsProfilesframeSub:SetText(GwLocalization["PROFILES_DESC"])

    local fnGSPF_OnShow = function(self)
        GwSettingsWindow.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\profiles\\profiles-bg")
    end
    local fnGSPF_OnHide = function(self)
        GwSettingsWindow.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagbg")
    end
    GwSettingsProfilesframe:SetScript("OnShow", fnGSPF_OnShow)
    GwSettingsProfilesframe:SetScript("OnHide", fnGSPF_OnHide)

    local fnGSPF_slider_OnValueChanged = function(self, value)
        self:GetParent().scrollFrame:SetVerticalScroll(value)
    end
    GwSettingsProfilesframe.slider:SetScript("OnValueChanged", fnGSPF_slider_OnValueChanged)
    GwSettingsProfilesframe.slider:SetMinMaxValues(0, 512)

    local fnGSPF_scroll_OnMouseWheel = function(self, delta)
        delta = -delta * 10
        local s = math.max(0, self:GetVerticalScroll() + delta)
        if self.maxScroll ~= nil then
            s = math.min(self.maxScroll, s)
        end
        self:SetVerticalScroll(s)
        self:GetParent().slider:SetValue(s)
    end
    GwSettingsProfilesframe.scrollFrame:SetScript("OnMouseWheel", fnGSPF_scroll_OnMouseWheel)

    local fnGSBC_OnClick = function(self)
        self:GetParent():Hide()
    end
    GwSettingsButtonClose:SetScript("OnClick", fnGSBC_OnClick)

    createCat(GwLocalization["MODULES_CAT"], GwLocalization["MODULES_CAT_TOOLTIP"], "GwSettingsModuleOption", 0)

    addOption(
        GwLocalization["HEALTH_GLOBE"],
        GwLocalization["HEALTH_GLOBE_DESC"],
        "HEALTHGLOBE_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        DISPLAY_POWER_BARS,
        GwLocalization["RESOURCE_DESC"],
        "POWERBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        FOCUS,
        GwLocalization["FOCUS_FRAME_DESC"],
        "FOCUS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        TARGET,
        GwLocalization["TARGET_FRAME_DESC"],
        "TARGET_ENABLED",
        "GwSettingsModuleOption"
    )
    --addOption(GwLocalization['CHAT_BUBBLES'], GwLocalization['CHAT_BUBBLES_DESC'],'CHATBUBBLES_ENABLED','GwSettingsModuleOption')
    addOption(
        MINIMAP_LABEL,
        GwLocalization["MINIMAP_DESC"],
        "MINIMAP_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        OBJECTIVES_TRACKER_LABEL,
        GwLocalization["QUEST_TRACKER_DESC"],
        "QUESTTRACKER_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["TOOLTIPS"],
        GwLocalization["TOOLTIPS_DESC"],
        "TOOLTIPS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE,
        GwLocalization["CHAT_FRAME_DESC"],
        "CHATFRAME_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["QUESTING_FRAME"],
        GwLocalization["QUESTING_FRAME_DESC"],
        "QUESTVIEW_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        BUFFOPTIONS_LABEL,
        GwLocalization["PLAYER_AURAS_DESC"],
        "PLAYER_BUFFS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        BINDING_HEADER_ACTIONBAR,
        GwLocalization["ACTION_BARS_DESC"],
        "ACTIONBARS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        BINDING_NAME_TOGGLECHARACTER3,
        GwLocalization["PET_BAR_DESC"],
        "PETBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        INVENTORY_TOOLTIP,
        GwLocalization["INVENTORY_FRAME_DESC"],
        "BAGS_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(GwLocalization["FONTS"], GwLocalization["FONTS_DESC"], "FONTS_ENABLED", "GwSettingsModuleOption")
    addOption(
        SHOW_ENEMY_CAST,
        GwLocalization["CASTING_BAR_DESC"],
        "CASTINGBAR_ENABLED",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["CLASS_POWER"],
        GwLocalization["CLASS_POWER_DESC"],
        "CLASS_POWER",
        "GwSettingsModuleOption"
    )
    addOption(
        GwLocalization["GROUP_FRAMES"],
        GwLocalization["GROUP_FRAMES_DESC"],
        "GROUP_FRAMES",
        "GwSettingsModuleOption"
    )
    addOption(
        BINDING_NAME_TOGGLECHARACTER0,
        GwLocalization["CHRACTER_WINDOW_DESC"],
        "USE_CHARACTER_WINDOW",
        "GwSettingsModuleOption"
    )
    addOption(
        TALENTS_BUTTON,
        GwLocalization["TALENTS_BUTTON_DESC"],
        "USE_TALENT_WINDOW",
        "GwSettingsModuleOption"
    )

    createCat(TARGET, GwLocalization["TARGET_TOOLTIP"], "GwSettingsTargetFocus", 1)

    addOption(
        SHOW_TARGET_OF_TARGET_TEXT,
        GwLocalization["TARGET_OF_TARGET_DESC"],
        "target_TARGET_ENABLED",
        "GwSettingsTargetOptions"
    )
    addOption(
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        GwLocalization["HEALTH_VALUE_DESC"],
        "target_HEALTH_VALUE_ENABLED",
        "GwSettingsTargetOptions"
    )
    addOption(
        RAID_HEALTH_TEXT_PERC,
        GwLocalization["HEALTH_PERCENTAGE_DESC"],
        "target_HEALTH_VALUE_TYPE",
        "GwSettingsTargetOptions"
    )
    addOption(
        CLASS_COLORS,
        GwLocalization["CLASS_COLOR_DESC"],
        "target_CLASS_COLOR",
        "GwSettingsTargetOptions"
    )
    addOption(
        SHOW_DEBUFFS,
        GwLocalization["SHOW_DEBUFFS_DESC"],
        "target_DEBUFFS",
        "GwSettingsTargetOptions"
    )
    addOption(
        SHOW_ALL_ENEMY_DEBUFFS_TEXT,
        GwLocalization["SHOW_ALL_DEBUFFS_DESC"],
        "target_BUFFS_FILTER_ALL",
        "GwSettingsTargetOptions"
    )
    addOption(
        SHOW_BUFFS,
        GwLocalization["SHOW_BUFFS_DESC"],
        "target_BUFFS",
        "GwSettingsTargetOptions"
    )
    addOption(
        GwLocalization["SHOW_ILVL"],
        GwLocalization["SHOW_ILVL_DESC"],
        "target_SHOW_ILVL",
        "GwSettingsTargetOptions"
    )
    addOption(
        GwLocalization["SHOW_THREAT_VALUE"],
        GwLocalization["SHOW_THREAT_VALUE"],
        "target_THREAT_VALUE_ENABLED",
        "GwSettingsTargetOptions"
    )
    addOption(
        MINIMAP_TRACKING_FOCUS,
        GwLocalization["FOCUS_TARGET_DESC"],
        "focus_TARGET_ENABLED",
        "GwSettingsFocusOptions"
    )
    addOption(
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        GwLocalization["HEALTH_VALUE_DESC"],
        "focus_HEALTH_VALUE_ENABLED",
        "GwSettingsFocusOptions"
    )
    addOption(
        RAID_HEALTH_TEXT_PERC,
        GwLocalization["HEALTH_PERCENTAGE_DESC"],
        "focus_HEALTH_VALUE_TYPE",
        "GwSettingsFocusOptions"
    )
    addOption(
        CLASS_COLORS,
        GwLocalization["CLASS_COLOR_DESC"],
        "focus_CLASS_COLOR",
        "GwSettingsFocusOptions"
    )
    addOption(
        SHOW_DEBUFFS,
        GwLocalization["SHOW_DEBUFFS_DESC"],
        "focus_DEBUFFS",
        "GwSettingsFocusOptions"
    )
    addOption(
        SHOW_ALL_ENEMY_DEBUFFS_TEXT,
        GwLocalization["SHOW_ALL_DEBUFFS_DESC"],
        "focus_BUFFS_FILTER_ALL",
        "GwSettingsFocusOptions"
    )
    addOption(
        SHOW_BUFFS,
        GwLocalization["SHOW_BUFFS_DESC"],
        "focus_BUFFS",
        "GwSettingsFocusOptions"
    )

    createCat(GwLocalization["HUD_CAT"], GwLocalization["HUD_TOOLTIP"], "GwSettingsHudOptions", 3)

    addOption(
        GwLocalization["ACTION_BAR_FADE"],
        GwLocalization["ACTION_BAR_FADE_DESC"],
        "FADE_BOTTOM_ACTIONBAR",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["DYNAMIC_HUD"],
        GwLocalization["DYNAMIC_HUD_DESC"],
        "HUD_SPELL_SWAP",
        "GwSettingsHudOptions"
    )
    addOption(GwLocalization["CHAT_FADE"], GwLocalization["CHAT_FADE_DESC"], "CHATFRAME_FADE", "GwSettingsHudOptions")
    addOption(
        GwLocalization["HIDE_EMPTY_SLOTS"],
        GwLocalization["HIDE_EMPTY_SLOTS_DESC"],
        "HIDEACTIONBAR_BACKGROUND_ENABLED",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["COMPASS_TOGGLE"],
        GwLocalization["COMPASS_TOGGLE_DESC"],
        "SHOW_QUESTTRACKER_COMPASS",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["ADV_CAST_BAR"],
        GwLocalization["ADV_CAST_BAR_DESC"],
        "CASTINGBAR_DATA",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["BUTTON_ASSIGNMENTS"],
        GwLocalization["BUTTON_ASSIGNMENTS_DESC"],
        "BUTTON_ASSIGNMENTS",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["MOUSE_TOOLTIP"],
        GwLocalization["MOUSE_TOOLTIP_DESC"],
        "TOOLTIP_MOUSE",
        "GwSettingsHudOptions"
    )
    addOption(
        GwLocalization["FADE_MICROMENU"],
        GwLocalization["FADE_MICROMENU_DESC"],
        "FADE_MICROMENU",
        "GwSettingsHudOptions"
    )
    addOption(
        DISPLAY_BORDERS,
        nil,
        "BORDER_ENABLED",
        "GwSettingsHudOptions"
    )
    addOption(
        CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC,
        nil,
        "DYNAMIC_CAM",
        "GwSettingsHudOptions"
    )
    addOption(
        WORLD_MARKER:format(0):gsub("%d", ""),
        GwLocalization["WORLD_MARKER_DESC"],
        "WORLD_MARKER_FRAME",
        "GwSettingsHudOptions"
    )

    addOptionDropdown(
        GwLocalization["MINIMAP_HOVER"],
        GwLocalization["MINIMAP_HOVER_TOOLTIP"],
        "MINIMAP_HOVER",
        "GwSettingsHudOptions",
        function()
            GW.SetMinimapHover()
        end,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            GwLocalization['MINIMAP_COORDS'],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. GwLocalization['MINIMAP_COORDS'],
            ZONE .. " + " .. GwLocalization['MINIMAP_COORDS']
        }
    )
    addOptionDropdown(
        GwLocalization["MINIMAP_POS"],
        nil,
        "MINIMAP_POS",
        "GwSettingsHudOptions",
        function()
            GW.SetMinimapPosition()
        end,
        {"BOTTOM", "TOP"},
        {
            TRACKER_SORT_MANUAL_BOTTOM,
            TRACKER_SORT_MANUAL_TOP
        }
    )
    addOptionDropdown(
        GwLocalization["MINIMAP_SCALE"],
        GwLocalization["MINIMAP_SCALE_DESC"],
        "MINIMAP_SCALE",
        "GwSettingsHudOptions",
        function()
            Minimap:SetSize(GetSetting("MINIMAP_SCALE"), GetSetting("MINIMAP_SCALE"))
        end,
        {250, 200, 170},
        {
            LARGE,
            TIME_LEFT_MEDIUM,
            DEFAULT
        }
    )
    addOptionDropdown(
        GwLocalization["HUD_SCALE"],
        GwLocalization["HUD_SCALE_DESC"],
        "HUD_SCALE",
        "GwSettingsHudOptions",
        function()
            GW.UpdateHudScale()
        end,
        {1, 0.9, 0.8},
        {
            DEFAULT,
            SMALL,
            GwLocalization["HUD_SCALE_TINY"]
        }
    )
    addOptionDropdown(
        GwLocalization["STG_RIGHT_BAR_COLS"],
        GwLocalization["STG_RIGHT_BAR_COLS_DESC"],
        "MULTIBAR_RIGHT_COLS",
        "GwSettingsHudOptions",
        setMultibarCols,
        {1, 2, 3, 4, 6, 12},
        {"1", "2", "3", "4", "6", "12"}
    )

    createCat(CHAT_MSG_PARTY, GwLocalization["GROUP_TOOLTIP"], "GwSettingsGroupframe", 4)

    addOption(
        USE_RAID_STYLE_PARTY_FRAMES,
        GwLocalization["RAID_PARTY_STYLE_DESC"],
        "RAID_STYLE_PARTY",
        "GwSettingsGroupframe"
    )
    addOption(
        RAID_USE_CLASS_COLORS,
        GwLocalization["CLASS_COLOR_RAID_DESC"],
        "RAID_CLASS_COLOR",
        "GwSettingsGroupframe"
    )
    addOption(
        DISPLAY_POWER_BARS,
        GwLocalization["POWER_BARS_RAID_DESC"],
        "RAID_POWER_BARS",
        "GwSettingsGroupframe"
    )
    addOption(
        DISPLAY_ONLY_DISPELLABLE_DEBUFFS,
        GwLocalization["DEBUFF_DISPELL_DESC"],
        "RAID_ONLY_DISPELL_DEBUFFS",
        "GwSettingsGroupframe"
    )
    addOption(
        RAID_TARGET_ICON,
        GwLocalization["RAID_MARKER_DESC"],
        "RAID_UNIT_MARKERS",
        "GwSettingsGroupframe"
    )
    addOption(
        GwLocalization["RAID_SORT_BY_ROLE"],
        GwLocalization["RAID_SORT_BY_ROLE_DESC"],
        "RAID_SORT_BY_ROLE",
        "GwSettingsGroupframe",
        function ()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end
    )
    addOption(
        GwLocalization["RAID_AURA_TOOLTIP_IN_COMBAT"],
        GwLocalization["RAID_AURA_TOOLTIP_IN_COMBAT_DESC"],
        "RAID_AURA_TOOLTIP_IN_COMBAT",
        "GwSettingsGroupframe"
    )

    addOptionDropdown(
        GwLocalization["RAID_UNIT_FLAGS"],
        GwLocalization["RAID_UNIT_FLAGS_TOOLTIP"],
        "RAID_UNIT_FLAGS",
        "GwSettingsGroupframe",
        function()
        end,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, GwLocalization["RAID_UNIT_FLAGS_2"], ALL}
    )

    addOptionDropdown(    
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH",
        "GwSettingsGroupframe",
        function()
        end,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}
    )

    createCat(CHAT_MSG_PARTY, GwLocalization["GROUP_TOOLTIP"], "GwSettingsGroupframe2", 4)

    local dirs, grow = {"DOWN", "UP", "RIGHT", "LEFT"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, dirs[i] .. "+" .. dirs[j])
        end
    end

        addOptionDropdown(
        GwLocalization["RAID_GROW"],
        GwLocalization["RAID_GROW"],
        "RAID_GROW",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesAnchor()
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        grow,
        MapTable(grow, function (dir)
            local g1, g2 = strsplit("+", dir)
            return StrUpper(GwLocalization["RAID_GROW_DIR"]:format(GwLocalization[g1], GwLocalization[g2]), 1, 1)
        end)
    )

    local pos = {"POSITION", "GROWTH"}
    for i,v in pairs({"TOP", "", "BOTTOM"}) do
        for j,h in pairs({"LEFT", "", "RIGHT"}) do
            tinsert(pos, (v .. h) == "" and "CENTER" or v .. h)
        end
    end

    addOptionDropdown(
        GwLocalization["RAID_ANCHOR"],
        GwLocalization["RAID_ANCHOR_DESC"],
        "RAID_ANCHOR",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesAnchor()
            end
        end,
        pos,
        MapTable(pos, function (pos, i)
            return StrUpper(GwLocalization[i <= 2 and "RAID_ANCHOR_BY_" .. pos or pos], 1, 1)
        end, true)
    )

    addOptionSlider(
        GwLocalization["RAID_UNITS_PER_COLUMN"],
        GwLocalization["RAID_UNITS_PER_COLUMN_DESC"],
        "RAID_UNITS_PER_COLUMN",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        40
    )

    addOptionSlider(
        GwLocalization["RAID_BAR_WIDTH"],
        GwLocalization["RAID_BAR_WIDTH_DESC"],
        "RAID_WIDTH",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        45,
        300
    )

    addOptionSlider(
        GwLocalization["RAID_BAR_HEIGHT"],
        GwLocalization["RAID_BAR_HEIGHT_DESC"],
        "RAID_HEIGHT",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        15,
        100
    )

    addOptionSlider(
        GwLocalization["RAID_CONT_WIDTH"],
        GwLocalization["RAID_CONT_WIDTH_DESC"],
        "RAID_CONT_WIDTH",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenWidth()
    )

    addOptionSlider(
        GwLocalization["RAID_CONT_HEIGHT"],
        GwLocalization["RAID_CONT_HEIGHT_DESC"],
        "RAID_CONT_HEIGHT",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenHeight()
    )

    createCat(AURAS, GwLocalization["AURAS_TOOLTIP"], "GwSettingsAurasframe", 2)
    
    addOptionText(
        GwLocalization["AURAS_IGNORED"],
        GwLocalization["AURAS_IGNORED_DESC"],
        "AURAS_IGNORED",
        "GwSettingsAurasOptions",
        function() end
    )
    
    addOptionText(
        GwLocalization["AURAS_MISSING"],
        GwLocalization["AURAS_MISSING_DESC"],
        "AURAS_MISSING",
        "GwSettingsAurasOptions",
        function() end
    )

    addOption(
        GwLocalization["INDICATORS_ICON"],
        GwLocalization["INDICATORS_ICON_DESC"],
        "INDICATORS_ICON",
        "GwSettingsIndicatorsOptions",
        function () end
    )

    addOption(
        GwLocalization["INDICATORS_TIME"],
        GwLocalization["INDICATORS_TIME_DESC"],
        "INDICATORS_TIME",
        "GwSettingsIndicatorsOptions",
        function () end
    )

    local auraKeys, auraVals = {0}, {NONE_KEY}
    for spellID,indicator in pairs(GW.AURAS_INDICATORS[select(2, UnitClass("player"))]) do
        if not indicator[4] then
            tinsert(auraKeys, spellID)
            tinsert(auraVals, (GetSpellInfo(spellID)))
        end
    end

    for _,pos in ipairs(GW.INDICATORS) do
        local key = "INDICATOR_" .. pos
        local t = StrUpper(GwLocalization[key] or GwLocalization[pos], 1, 1)
        addOptionDropdown(
            GwLocalization["INDICATOR_TITLE"]:format(t),
            GwLocalization["INDICATOR_DESC"]:format(t),
            key,
            "GwSettingsIndicatorsOptions",
            function () SetSetting(key, tonumber(GetSetting(key, true)), true) end,
            auraKeys,
            auraVals,
            {perSpec = true}
        )
    end

    createCat(GwLocalization["PROFILES_CAT"], GwLocalization["PROFILES_TOOLTIP"], "GwSettingsProfilesframe", 5)
    _G["GwSettingsLabel4"].iconbg:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\settingsiconbg-2.tga")

    switchCat(0)
    GwSettingsWindow:Hide()

    GwSettingsProfilesframe.slider:SetValue(0)

    GwSettingsProfilesframe.slider.thumb:SetHeight(200)

    local resetTodefault =
        CreateFrame("Button", "GwProfileItemDefault", GwSettingsProfilesframe.scrollchild, "GwProfileItem")
    resetTodefault:SetScript("OnEnter", gwProfileItem_OnEnter)
    resetTodefault:SetScript("OnLeave", gwProfileItem_OnLeave)
    gwProfileItem_OnLoad(resetTodefault)

    resetTodefault.icon:SetTexture("Interface\\icons\\inv_corgi2")

    resetTodefault.deleteable = false
    resetTodefault.background:SetTexCoord(0, 1, 0, 0.5)
    resetTodefault.activateAble = true

    resetTodefault:SetPoint("TOPLEFT", 15, 0)

    resetTodefault.name:SetText(GwLocalization["PROFILES_DEFAULT_SETTINGS"])
    resetTodefault.desc:SetText(GwLocalization["PROFILES_DEFAULT_SETTINGS_DESC"])
    resetTodefault.activateButton:SetScript(
        "OnClick",
        function()
            GW.WarningPrompt(
                GwLocalization["PROFILES_DEFAULT_SETTINGS_PROMPT"],
                function()
                    ResetToDefault()
                end
            )
        end
    )
    resetTodefault.activateButton:SetText(GwLocalization["PROFILES_LOAD_BUTTON"])

    local fmGCNP =
        CreateFrame("Button", "GwCreateNewProfile", GwSettingsProfilesframe.scrollchild, "GwCreateNewProfile")
    fmGCNP:SetWidth(fmGCNP:GetTextWidth() + 10)
    fmGCNP:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE)
    local fnGCNP_OnClick = function(self, button)
        inputPrompt(
            NEW_COMPACT_UNIT_FRAME_PROFILE,
            function()
                addProfile(GwWarningPrompt.input:GetText())
                GwWarningPrompt:Hide()
            end
        )
    end
    fmGCNP:SetScript("OnClick", fnGCNP_OnClick)

    GwCreateNewProfile:SetPoint("TOPLEFT", 15, -80)

    updateProfiles()
end
GW.LoadSettings = LoadSettings
