---@class GW2
local GW = select(2, ...)
local L = GW.L
local LEMO = GW.Libs.LEMO

local wpanel
local installFrame

local function ToggleChatColorNamesByClassGroup(checked, group)
	local info = _G.ChatTypeGroup[group]
	if info then
		for _, value in pairs(info) do
			SetChatColorNameByClass(strsub(value, 10), checked)
		end
	else
		SetChatColorNameByClass(group, checked)
	end
end

local function AddCompleteAlert(text)
    if not (GW.Classic or GW.TBC or GW.Wrath) then
        GW.AlertSystem:AddAlert(L["Complete"], nil, text, false, "Interface/AddOns/GW2_UI/textures/icons/icon-levelup.png", true)
    end
end

local function settings_OnClick(self)
    local t = self.target
    self:GetParent():Hide()
    t:Show()
    UIFrameFadeIn(t, 0.2, 0, 1)
end

-- ============================
-- Step appliers
-- ============================
local function ApplyChatSetup()
    FCF_ResetChatWindows()

    local voiceChat = _G[CHAT_FRAMES[3]]
    FCF_ResetChatWindow(voiceChat, VOICE)
    FCF_DockFrame(voiceChat, 3)

    FCF_OpenNewWindow(LOOT)

    for id, name in next, CHAT_FRAMES do
        local frame = _G[name]

        -- move general bottom left
        if id == 1 then
            -- this needs to be done via the edit mode lib
            LEMO:LoadLayouts()
            local doesGw2LayoutExists = LEMO:DoesLayoutExist("GW2_Layout")
            if not LEMO:CanEditActiveLayout() or not doesGw2LayoutExists then
                if not doesGw2LayoutExists then
                    LEMO:AddLayout(Enum.EditModeLayoutType.Account, "GW2_Layout")
                end
                LEMO:SetActiveLayout("GW2_Layout")
            end
            LEMO:ReanchorFrame(frame, "BOTTOMLEFT", UIParent, 40, 60)
            LEMO:ApplyChanges()
            frame:SetUserPlaced(true)
        elseif id == 2 then
            FCF_SetWindowName(frame, GUILD_EVENT_LOG)
        elseif id == 3 then
            VoiceTranscriptionFrame_UpdateVisibility(frame)
            VoiceTranscriptionFrame_UpdateVoiceTab(frame)
            VoiceTranscriptionFrame_UpdateEditBox(frame)
        elseif id == 4 then
            FCF_SetWindowName(frame, LOOT .. " / " .. TRADE)
        end

        FCF_SetChatWindowFontSize(nil, frame, 12)
        FCF_SavePositionAndDimensions(frame)
        FCF_StopDragging(frame)
    end

    -- keys taken from "ChatTypeGroup" but doesnt add: "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO", "COMMUNITIES_CHANNEL", "PET_BATTLE_COMBAT_LOG", "PET_BATTLE_INFO", "TARGETICONS"
    local chatGroup = {"SYSTEM", "CHANNEL", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_INLINE_TOAST_ALERT"}
    local ChatFrame1_RemoveAllMessageGroups = ChatFrame1.RemoveAllMessageGroups or ChatFrame_RemoveAllMessageGroups
    local ChatFrame1_AddMessageGroup = ChatFrame1.AddMessageGroup or ChatFrame_AddMessageGroup
    ChatFrame1_RemoveAllMessageGroups(ChatFrame1)
    for _, v in ipairs(chatGroup) do
        ChatFrame1_AddMessageGroup(ChatFrame1, v)
    end

    -- keys taken from "ChatTypeGroup" which weren't added above to ChatFrame1
    chatGroup = {"PING", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY"}
    local ChatFrame4_RemoveAllMessageGroups = ChatFrame4.RemoveAllMessageGroups or ChatFrame_RemoveAllMessageGroups
    local ChatFrame4_AddMessageGroup = ChatFrame4.AddMessageGroup or ChatFrame_AddMessageGroup
    ChatFrame4_RemoveAllMessageGroups(ChatFrame4)
    for _, v in ipairs(chatGroup) do
        ChatFrame4_AddMessageGroup(ChatFrame4, v)
    end

    local ChatFrame1_AddChannel = ChatFrame1.AddChannel or ChatFrame_AddChannel
    local ChatFrame1_RemoveChannel = ChatFrame1.RemoveChannel or ChatFrame_RemoveChannel
    local ChatFrame4_AddChannel = ChatFrame4.AddChannel or ChatFrame_AddChannel

    ChatFrame1_AddChannel(ChatFrame1, GENERAL)
    ChatFrame1_RemoveChannel(ChatFrame1, TRADE)
    ChatFrame4_AddChannel(ChatFrame4, TRADE)

    -- set the chat groups names in class color to enabled for all chat groups which players names appear
    chatGroup = {"SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL"}
    for i = 1, MAX_WOW_CHAT_CHANNELS do
        tinsert(chatGroup, "CHANNEL" .. i)
    end
    for _, v in ipairs(chatGroup) do
        ToggleChatColorNamesByClassGroup(true, v)
    end

    AddCompleteAlert(L["Setup Chat"])
end

local CVARS = {
    { cvar = "screenshotQuality", value = "10", desc = L["Maximum screenshot quality"] },
    { cvar = "chatMouseScroll", value = "1", desc = L["Scroll the chat with the mouse wheel"] },
    { cvar = "chatStyle", value = "classic", desc = L["Classic chat input style"] },
    { cvar = "wholeChatWindowClickable", value = "0", desc = L["Only the chat text is clickable, not the whole window"] },
    { cvar = "showTutorials", value = "0", desc = L["Disable the tutorial popups"] },
    { cvar = "showNPETutorials", value = "0", desc = L["Disable the new player tutorials"] },
    { cvar = "UberTooltips", value = "1", desc = L["Enhanced tooltips with additional information"] },
    { cvar = "threatWarning", value = "3", desc = L["Always show threat warnings"] },
    { cvar = "alwaysShowActionBars", value = "1", desc = L["Always show the action bars"] },
    { cvar = "lockActionBars", value = "1", desc = L["Lock the action bars against accidental dragging"] },
    { cvar = "spamFilter", value = "0", desc = L["Disable the built-in spam filter"] },
    { cvar = "cameraDistanceMaxZoomFactor", value = "2.6", desc = L["Increase the maximum camera zoom distance"] },
    { cvar = "showQuestTrackingTooltips", value = "1", desc = L["Show quest progress in tooltips"] },
    { cvar = "whisperMode", value = "inline", desc = L["Whispers show up in the chat window instead of extra tabs"] },
}

-- entries the current client does not know (flavor differences, removed cvars)
-- are skipped by the list and the applier alike
local function CVarExists(entry)
    return C_CVar.GetCVar(entry.cvar) ~= nil
end

local function ApplyCVars()
    local applied, total = 0, 0
    for _, entry in ipairs(CVARS) do
        if CVarExists(entry) then
            total = total + 1
            if entry.enabled ~= false then
                C_CVar.SetCVar(entry.cvar, entry.value)
                applied = applied + 1
            end
        end
    end

    AddCompleteAlert(L["Setup CVars"])
    return format("%d/%d", applied, total)
end

-- one click install: every step with its recommended default, then reload
local function ApplyExpressInstall()
    ApplyChatSetup()
    ApplyCVars()

    GW.settings.PIXEL_PERFECTION = true
    C_CVar.SetCVar("useUiScale", "0")
    GW.PixelPerfection()

    GW.settings.FONT_STYLE_TEMPLATE = "GW2"
    GW.ApplyFontStyleTemplate()

    if not GW.Retail then
        GW.settings.GW_COMBAT_TEXT_MODE = "GW2"
        GW.ApplyCombatTextMode("GW2")
    end

    GW.ShowPopup({
        text = L["The recommended settings have been applied. The interface will now be reloaded."],
        OnAccept = function() C_UI.Reload() end,
        button1 = ACCEPT,
        button2 = CANCEL,
    })
end

-- ============================
-- Install UI building blocks
-- ============================
local function CreateActionButton(parent, width)
    local button = CreateFrame("Button", nil, parent, "GwStandardButton")
    button:SetSize(width or 146, 28)
    return button
end

local function CreateInstallCheckbox(parent, label)
    local check = CreateFrame("CheckButton", nil, parent)
    check:SetSize(16, 16)
    check:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
    check:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")

    check.label = check:CreateFontString(nil, "OVERLAY")
    check.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    check.label:SetTextColor(0.9, 0.85, 0.7)
    check.label:SetJustifyH("LEFT")
    check.label:SetPoint("LEFT", check, "RIGHT", 6, 0)
    check.label:SetText(label)
    return check
end

-- ============================
-- Steps
-- ============================
-- grouped: unit frames, hud bars, ui windows, misc. Dotted settings resolve nested
local MODULES = {
    { setting = "HEALTHGLOBE_ENABLED", name = PLAYER },
    { setting = "POWERBAR_ENABLED", name = L["Power Bar"] },
    { setting = "CASTINGBAR_ENABLED", name = L["Cast Bar"] },
    { setting = "PLAYER_BUFFS_ENABLED", name = L["Auras"] },
    { setting = "CLASS_POWER", name = L["Class Power"] },
    { setting = "TARGET_ENABLED", name = TARGET },
    { setting = "FOCUS_ENABLED", name = FOCUS, hidden = GW.Classic },
    { setting = "PETBAR_ENABLED", name = PET },
    { setting = "PARTY_FRAMES", name = PARTY },
    { setting = "RAID_STYLE_PARTY", name = USE_RAID_STYLE_PARTY_FRAMES },
    { setting = "RAID_FRAMES", name = RAID_FRAMES_LABEL or RAID },
    { setting = "ACTIONBARS_ENABLED", name = BINDING_HEADER_ACTIONBAR },
    { setting = "micromenu.enabled", name = L["Micro Bar"] },
    { setting = "XPBAR_ENABLED", name = XPBAR_LABEL },
    { setting = "MINIMAP_ENABLED", name = MINIMAP_LABEL or MINIMAP_ZOOM },
    { setting = "BAGS_ENABLED", name = INVENTORY_TOOLTIP },
    { setting = "USE_CHARACTER_WINDOW", name = L["Character Pane"] },
    { setting = "USE_TALENT_WINDOW", name = TALENTS, hidden = GW.Retail },
    { setting = "USE_PROFESSION_WINDOW", name = TRADE_SKILLS },
    { setting = "USE_SOCIAL_WINDOW", name = FRIENDS },
    { setting = "USE_BATTLEGROUND_HUD", name = BATTLEGROUND },
    { setting = "CHATFRAME_ENABLED", name = CHAT },
    { setting = "CHATBUBBLES_ENABLED", name = CHAT_BUBBLES_TEXT },
    { setting = "ALERTFRAME_ENABLED", name = COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL },
    { setting = "QUESTTRACKER_ENABLED", name = OBJECTIVES_TRACKER_LABEL or QUESTS_LABEL },
    { setting = "immersiveQuesting.enabled", name = L["Immersive Questing"] },
    { setting = "TOOLTIPS_ENABLED", name = L["Tooltips"] },
}

-- flavor gated steps drop out entirely, the progress dots follow #STEPS
local function RemoveHiddenSteps(steps)
    for i = #steps, 1, -1 do
        if steps[i].hidden then
            tremove(steps, i)
        end
    end
    return steps
end

local function GetModuleValue(setting)
    local root, sub = strsplit(".", setting)
    if sub then
        return GW.settings[root][sub]
    end
    return GW.settings[setting]
end

local function SetModuleValue(setting, value)
    local root, sub = strsplit(".", setting)
    if sub then
        GW.settings[root][sub] = value
    else
        GW.settings[setting] = value
    end
end

-- forward declaration: the final steps summary closure iterates STEPS, and a local
-- only enters scope AFTER its declaration statement - inline it would capture a
-- global nil instead
local STEPS
STEPS = RemoveHiddenSteps({
    {
        title = CHAT,
        desc = L["This part sets up your chat window names, positions, and colors."],
        applyText = L["Setup Chat"],
        apply = ApplyChatSetup,
        buildContent = function(content)
            local lines = {
                L["Resets the chat windows and moves the main chat to the bottom left"],
                format(L["Adds an extra tab for %s"], LOOT .. " / " .. TRADE),
                format(L["Sets the chat font size to %d"], 12),
                L["Enables class colors for player names"],
                L["Sorts the message groups into the matching tabs"],
            }
            local previous
            for _, line in ipairs(lines) do
                local text = content:CreateFontString(nil, "OVERLAY")
                text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                text:SetTextColor(0.9, 0.85, 0.7)
                text:SetJustifyH("LEFT")
                text:SetWidth(400)
                if previous then
                    text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
                else
                    text:SetPoint("TOPLEFT", content, "TOPLEFT", 45, -8)
                end
                previous = text
                text:SetFormattedText("|cffd4b678\226\128\162|r  %s", line)
            end
        end,
    },
    {
        title = "CVars",
        desc = L["This part sets up your World of Warcraft default options."],
        applyText = L["Setup CVars"],
        apply = ApplyCVars,
        buildContent = function(content)
            local shown = {}
            for _, entry in ipairs(CVARS) do
                if CVarExists(entry) then
                    tinsert(shown, entry)
                end
            end

            local perColumn = math.ceil(#shown / 2)
            for index, entry in ipairs(shown) do
                local current = C_CVar.GetCVar(entry.cvar)
                local alreadySet = current == entry.value
                local label
                if alreadySet then
                    label = format("%s |cff888888%s|r |TInterface/RaidFrame/ReadyCheck-Ready:12|t", entry.cvar, entry.value)
                else
                    label = format("%s |cff888888%s|r |cffd4b678\226\134\146|r %s", entry.cvar, current, entry.value)
                end
                entry.enabled = not alreadySet

                local check = CreateInstallCheckbox(content, label)
                local column = math.floor((index - 1) / perColumn)
                local row = (index - 1) % perColumn
                check:SetPoint("TOPLEFT", content, "TOPLEFT", 8 + column * 232, -4 - row * 20)
                check.label:SetWidth(200)
                check.label:SetWordWrap(false)
                check:SetAlpha(alreadySet and 0.55 or 1)
                check:SetChecked(entry.enabled)
                check:SetScript("OnClick", function(self)
                    entry.enabled = self:GetChecked()
                end)
                check:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(entry.cvar, 1, 1, 1)
                    GameTooltip:AddLine(entry.desc, 0.9, 0.85, 0.7, true)
                    if alreadySet then
                        GameTooltip:AddLine(L["Already set"], 0.3, 0.92, 0.17)
                    end
                    GameTooltip:Show()
                end)
                check:SetScript("OnLeave", GameTooltip_Hide)
            end
        end,
    },
    {
        title = DISPLAY,
        desc = L["Use the recommended pixel perfect scale, or set your own - the preview applies live."],
        buildContent = function(content)
            local best = GW.getBestPixelScale()
            local state = { entryScale = UIParent:GetScale(), mode = nil }
            content.gwDisplayState = state

            local slider = CreateFrame("Slider", nil, content)
            slider:SetOrientation("HORIZONTAL")
            slider:SetSize(260, 20)
            slider:SetPoint("TOP", content, "TOP", 0, -8)
            slider:SetMinMaxValues(0.64, 1.15)
            slider:SetValueStep(0.01)
            slider:SetObeyStepOnDrag(true)
            slider:SetThumbTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderhandle.png")
            slider:GetThumbTexture():SetSize(16, 16)

            local sliderBg = slider:CreateTexture(nil, "BACKGROUND")
            sliderBg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderbg.png")
            sliderBg:SetHeight(12)
            sliderBg:SetPoint("LEFT", 2, 0)
            sliderBg:SetPoint("RIGHT", -2, 0)

            slider.valueText = slider:CreateFontString(nil, "OVERLAY")
            slider.valueText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            slider.valueText:SetTextColor(0.9, 0.85, 0.7)
            slider.valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)

            slider.title = slider:CreateFontString(nil, "OVERLAY")
            slider.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            slider.title:SetTextColor(0.62, 0.58, 0.5)
            slider.title:SetPoint("BOTTOM", slider, "TOP", 0, 4)
            slider.title:SetText(UI_SCALE)

            slider:SetScript("OnValueChanged", function(self, value)
                self.valueText:SetFormattedText("%.2f", value)
                if not self.gwSyncing then
                    state.mode = "custom"
                    UIParent:SetScale(value)
                end
            end)
            slider.gwSyncing = true
            slider:SetValue(math.min(1.15, math.max(0.64, state.entryScale)))
            slider.valueText:SetFormattedText("%.2f", slider:GetValue())
            slider.gwSyncing = false
            content.gwScaleSlider = slider

            local ppButton = CreateActionButton(content, 220)
            ppButton:SetPoint("TOP", slider, "BOTTOM", 0, -18)
            ppButton:SetText(L["Apply Pixel Perfect Scale"] .. format(" (%.2f)", best))
            ppButton:SetScript("OnClick", function()
                state.mode = "pp"
                UIParent:SetScale(best)
                slider.gwSyncing = true
                slider:SetValue(math.min(1.15, math.max(0.64, best)))
                slider.valueText:SetFormattedText("%.2f", best)
                slider.gwSyncing = false
            end)
        end,
        -- NEXT commits the previewed choice, SKIP restores the scale from step entry
        onNext = function(content, step)
            local state = content.gwDisplayState
            if state.mode == "pp" then
                GW.settings.PIXEL_PERFECTION = true
                C_CVar.SetCVar("useUiScale", "0")
                GW.PixelPerfection()
                AddCompleteAlert(L["Pixel Perfect Mode"])
                step.applied = true
                step.summaryDetail = format("%s (%.2f)", L["Pixel Perfect Mode"], GW.getBestPixelScale())
            elseif state.mode == "custom" then
                local value = content.gwScaleSlider:GetValue()
                GW.settings.PIXEL_PERFECTION = false
                C_CVar.SetCVar("useUiScale", "1")
                C_CVar.SetCVar("uiScale", value)
                UIParent:SetScale(value)
                step.applied = true
                step.summaryDetail = format("%s %.2f", UI_SCALE, value)
            end
        end,
        onSkip = function(content)
            UIParent:SetScale(content.gwDisplayState.entryScale)
        end,
    },
    {
        title = L["Modules"],
        desc = L["Choose which parts of GW2 UI are active for you. Everything can be changed later in the settings."],
        buildContent = function(content, step)
            local shown = {}
            for _, module in ipairs(MODULES) do
                if not module.hidden then
                    tinsert(shown, module)
                end
            end

            local checks = {}
            local perColumn = math.ceil(#shown / 3)
            for index, module in ipairs(shown) do
                local check = CreateInstallCheckbox(content, module.name)
                local column = math.floor((index - 1) / perColumn)
                local row = (index - 1) % perColumn
                check:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + column * 155, -30 - row * 22)
                check.label:SetWidth(125)
                check.label:SetWordWrap(false)
                check:SetChecked(GetModuleValue(module.setting))
                check:SetScript("OnClick", function(self)
                    SetModuleValue(module.setting, self:GetChecked())
                    step.applied = true
                end)
                checks[index] = check
            end

            local function SetAll(value)
                for index, module in ipairs(shown) do
                    SetModuleValue(module.setting, value)
                    checks[index]:SetChecked(value)
                end
                step.applied = true
            end

            local checkAll = CreateActionButton(content, 110)
            checkAll:SetHeight(20)
            checkAll:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -2)
            checkAll:SetText(CHECK_ALL)
            checkAll:SetScript("OnClick", function() SetAll(true) end)

            local uncheckAll = CreateActionButton(content, 110)
            uncheckAll:SetHeight(20)
            uncheckAll:SetPoint("LEFT", checkAll, "RIGHT", 8, 0)
            uncheckAll:SetText(UNCHECK_ALL)
            uncheckAll:SetScript("OnClick", function() SetAll(false) end)

            local hint = content:CreateFontString(nil, "OVERLAY")
            hint:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            hint:SetTextColor(0.62, 0.58, 0.5)
            hint:SetPoint("TOP", content, "TOP", 0, -30 - perColumn * 22 - 14)
            hint:SetText(L["Changes take effect once the installation completes."])
        end,
        onNext = function(_, step)
            local enabled, total, names = 0, 0, {}
            for _, module in ipairs(MODULES) do
                if not module.hidden then
                    total = total + 1
                    if GetModuleValue(module.setting) then
                        enabled = enabled + 1
                        tinsert(names, module.name)
                    end
                end
            end
            step.summaryDetail = format("%d/%d", enabled, total)
            step.summaryTooltip = names
        end,
    },
    {
        title = L["Fonts"],
        desc = L["Choose from predefined options to customize fonts and text styles, adjusting the appearance of your text."],
        buildContent = function(content, step)
            local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
            dropdown:SetSize(220, 25)
            dropdown:SetPoint("TOP", content, "TOP", 0, -10)
            dropdown:GwHandleDropDownBox(nil, nil, nil, 220)
            dropdown:SetupMenu(function(_, rootDescription)
                for index, template in ipairs(GW.FONT_STYLE_TEMPLATES) do
                    rootDescription:CreateRadio(GW.FONT_STYLE_TEMPLATE_NAMES[index],
                        function() return GW.settings.FONT_STYLE_TEMPLATE == template end,
                        function()
                            GW.settings.FONT_STYLE_TEMPLATE = template
                            GW.ApplyFontStyleTemplate()
                            step.applied = true
                            step.summaryDetail = GW.FONT_STYLE_TEMPLATE_NAMES[index]
                        end)
                end
            end)
        end,
        onNext = function(_, step)
            if not step.summaryDetail then
                for index, template in ipairs(GW.FONT_STYLE_TEMPLATES) do
                    if GW.settings.FONT_STYLE_TEMPLATE == template then
                        step.summaryDetail = GW.FONT_STYLE_TEMPLATE_NAMES[index]
                    end
                end
            end
        end,
    },
    {
        title = COMBAT_TEXT_LABEL,
        desc = COMBAT_SUBTEXT,
        hidden = GW.Retail,
        buildContent = function(content, step)
            local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
            dropdown:SetSize(220, 25)
            dropdown:SetPoint("TOP", content, "TOP", 0, -10)
            dropdown:GwHandleDropDownBox(nil, nil, nil, 220)
            dropdown:SetupMenu(function(_, rootDescription)
                for index, mode in ipairs(GW.COMBAT_TEXT_MODES) do
                    rootDescription:CreateRadio(GW.COMBAT_TEXT_MODE_NAMES[index],
                        function() return GW.settings.GW_COMBAT_TEXT_MODE == mode end,
                        function()
                            GW.settings.GW_COMBAT_TEXT_MODE = mode
                            GW.ApplyCombatTextMode(mode)
                            step.applied = true
                            step.summaryDetail = GW.COMBAT_TEXT_MODE_NAMES[index]
                        end)
                end
            end)
        end,
        onNext = function(_, step)
            if not step.summaryDetail then
                for index, mode in ipairs(GW.COMBAT_TEXT_MODES) do
                    if GW.settings.GW_COMBAT_TEXT_MODE == mode then
                        step.summaryDetail = GW.COMBAT_TEXT_MODE_NAMES[index]
                    end
                end
            end
        end,
    },
    {
        title = L["Profiles"],
        desc = L["This part helps you manage your settings profile. Profiles can be shared between characters."],
        buildContent = function(content, step)
            local currentLabel = content:CreateFontString(nil, "OVERLAY")
            currentLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            currentLabel:SetTextColor(0.9, 0.85, 0.7)
            currentLabel:SetPoint("TOP", content, "TOP", 0, -6)
            content.gwCurrentProfile = currentLabel

            local function UpdateCurrentLabel()
                currentLabel:SetFormattedText("%s |cffffffff%s|r", L["Current profile:"], GW.globalSettings:GetCurrentProfile())
            end
            UpdateCurrentLabel()

            local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
            dropdown:SetSize(220, 25)
            dropdown:SetPoint("TOP", currentLabel, "BOTTOM", 0, -12)
            dropdown:GwHandleDropDownBox(nil, nil, nil, 220)
            dropdown:SetupMenu(function(_, rootDescription)
                for _, profileName in ipairs(GW.globalSettings:GetProfiles() or {}) do
                    rootDescription:CreateRadio(profileName,
                        function() return GW.globalSettings:GetCurrentProfile() == profileName end,
                        function()
                            GW.globalSettings:SetProfile(profileName)
                            UpdateCurrentLabel()
                            step.applied = true
                            step.summaryDetail = profileName
                        end)
                end
            end)

            local newButton = CreateActionButton(content, 220)
            newButton:SetPoint("TOP", dropdown, "BOTTOM", 0, -12)
            newButton:SetText(L["Create a profile for this character"])
            newButton:SetScript("OnClick", function()
                GW.globalSettings:SetProfile(UnitName("player") .. " - " .. GetRealmName())
                UpdateCurrentLabel()
                dropdown:GenerateMenu()
                step.applied = true
                step.summaryDetail = GW.globalSettings:GetCurrentProfile()
            end)

            -- most common case for alts: same settings as the current profile, but
            -- independent from now on
            local copyButton = CreateActionButton(content, 220)
            copyButton:SetPoint("TOP", newButton, "BOTTOM", 0, -8)
            copyButton:SetText(L["Copy the current profile for this character"])
            copyButton:SetScript("OnClick", function()
                local oldProfile = GW.globalSettings:GetCurrentProfile()
                local newProfile = UnitName("player") .. " - " .. GetRealmName()
                if newProfile == oldProfile then
                    newProfile = format("%s (%s)", newProfile, CALENDAR_COPY_EVENT)
                end
                GW.globalSettings:SetProfile(newProfile)
                GW.globalSettings:CopyProfile(oldProfile, true)
                UpdateCurrentLabel()
                dropdown:GenerateMenu()
                step.applied = true
                step.summaryDetail = newProfile
            end)
        end,
        onNext = function(_, step)
            if not step.summaryDetail then
                step.summaryDetail = GW.globalSettings:GetCurrentProfile()
            end
        end,
    },
    {
        title = L["Installation Complete"],
        desc = L["You have now finished installing GW2 UI!"],
        applyText = L["Complete"],
        apply = function() C_UI.Reload() end,
        isFinal = true,
        buildContent = function(content)
            local previous
            for _, step in ipairs(STEPS) do
                if not step.isFinal then
                    local text = content:CreateFontString(nil, "OVERLAY")
                    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                    text:SetJustifyH("LEFT")
                    text:SetWidth(320)
                    if previous then
                        text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
                    else
                        text:SetPoint("TOPLEFT", content, "TOPLEFT", 90, -8)
                    end

                    if step.applied then
                        local detail = step.summaryDetail and format(" |cff888888%s|r", step.summaryDetail) or ""
                        text:SetTextColor(0.9, 0.85, 0.7)
                        text:SetFormattedText("|TInterface/RaidFrame/ReadyCheck-Ready:14|t %s%s", step.title, detail)
                    else
                        text:SetTextColor(0.5, 0.47, 0.42)
                        text:SetFormattedText("|TInterface/RaidFrame/ReadyCheck-NotReady:14|t %s |cff888888%s|r", step.title, L["Skipped"])
                    end

                    if step.summaryTooltip then
                        local line = CreateFrame("Frame", nil, content)
                        line:SetAllPoints(text)
                        line:EnableMouse(true)
                        line:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(step.title, 1, 1, 1)
                            GameTooltip:AddLine(table.concat(step.summaryTooltip, ", "), 0.9, 0.85, 0.7, true)
                            GameTooltip:Show()
                        end)
                        line:SetScript("OnLeave", GameTooltip_Hide)
                    end
                    previous = text
                end
            end
        end,
    },
})

-- ============================
-- Step engine
-- ============================
local function RenderStep(index)
    local step = STEPS[index]
    local install = installFrame

    install.title:SetText(step.title)
    install.desc:SetText(step.desc)

    -- progress: filled dots are done, the gold one is the current step
    for i, dot in ipairs(install.dots) do
        if i == index then
            dot:SetVertexColor(GW.Colors.TextColors.LightHeader:GetRGB())
        elseif STEPS[i].applied then
            dot:SetVertexColor(0.3, 0.92, 0.17)
        elseif i < index then
            dot:SetVertexColor(1, 1, 1, 0.7)
        else
            dot:SetVertexColor(1, 1, 1, 0.2)
        end
        dot:SetSize(i == index and 10 or 8, i == index and 10 or 8)
    end
    install.stepText:SetFormattedText(L["Step %d of %d"], index, #STEPS)

    -- content area is rebuilt per step (steps are visited rarely, no pooling needed)
    if install.content then
        install.content:Hide()
        install.content:SetParent(nil)
    end
    install.content = CreateFrame("Frame", nil, install)
    install.content:SetPoint("TOP", install.desc, "BOTTOM", 0, -12)
    install.content:SetPoint("BOTTOM", install.action, "TOP", 0, 10)
    install.content:SetWidth(470)
    if step.buildContent then
        step.buildContent(install.content, step)
    end
    UIFrameFadeIn(install.content, 0.2, 0, 1)

    -- the steps own action stands alone, the navigation row stays small below it
    install.action:SetShown(step.applyText ~= nil)
    if step.applyText then
        install.action:SetText(step.applyText)
        install.action:SetScript("OnClick", function()
            step.summaryDetail = step.apply()
            step.applied = true
            if not step.isFinal then
                RenderStep(index + 1)
            end
        end)
    end

    install.back:SetShown(index > 1 and not step.isFinal)
    install.skip:SetShown(not step.isFinal)
    install.next:SetShown(not step.isFinal and not step.applyText)

    install.skip:ClearAllPoints()
    if install.next:IsShown() then
        install.skip:SetPoint("RIGHT", install.next, "LEFT", -8, 0)
    else
        install.skip:SetPoint("BOTTOMRIGHT", install, "BOTTOMRIGHT", -10, 4)
    end

    install.back:SetScript("OnClick", function()
        if step.onSkip then step.onSkip(install.content) end
        RenderStep(index - 1)
    end)
    install.skip:SetScript("OnClick", function()
        if step.onSkip then step.onSkip(install.content) end
        RenderStep(index + 1)
    end)
    install.next:SetScript("OnClick", function()
        if step.onNext then step.onNext(install.content, step) end
        step.applied = true
        RenderStep(index + 1)
    end)
end

local function CreateInstallFrame()
    installFrame = CreateFrame("Frame", nil, wpanel)
    installFrame:SetPoint("TOP", wpanel, "TOP", 0, -60)
    installFrame:SetPoint("BOTTOM", wpanel, "BOTTOM", 0, 14)
    installFrame:SetWidth(478)
    installFrame:Hide()

    -- progress at the very top: done | current (gold) | upcoming, all on one center line
    installFrame.dots = {}
    local dotCount = #STEPS
    local spacing = 20
    for i = 1, dotCount do
        local dot = installFrame:CreateTexture(nil, "OVERLAY")
        dot:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        dot:SetSize(8, 8)
        dot:SetPoint("CENTER", installFrame, "TOP", (i - (dotCount + 1) / 2) * spacing, -10)
        installFrame.dots[i] = dot
    end

    installFrame.stepText = installFrame:CreateFontString(nil, "OVERLAY")
    installFrame.stepText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    installFrame.stepText:SetTextColor(0.62, 0.58, 0.5)
    installFrame.stepText:SetPoint("TOP", installFrame, "TOP", 0, -22)

    installFrame.title = installFrame:CreateFontString(nil, "OVERLAY")
    installFrame.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    installFrame.title:SetTextColor(0.8, 0.75, 0.6)
    installFrame.title:SetPoint("TOP", installFrame, "TOP", 0, -46)

    local separator = installFrame:CreateTexture(nil, "OVERLAY")
    separator:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
    separator:SetAlpha(0.8)
    separator:SetSize(260, 2)
    separator:SetPoint("TOP", installFrame.title, "BOTTOM", 0, -4)

    installFrame.desc = installFrame:CreateFontString(nil, "OVERLAY")
    installFrame.desc:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    installFrame.desc:SetTextColor(0.9, 0.85, 0.7)
    installFrame.desc:SetPoint("TOP", separator, "BOTTOM", 0, -10)
    installFrame.desc:SetWidth(440)
    installFrame.desc:SetJustifyH("CENTER")

    -- the steps own action button, prominent and alone
    installFrame.action = CreateActionButton(installFrame, 240)
    installFrame.action:SetPoint("BOTTOM", installFrame, "BOTTOM", 0, 40)

    -- small navigation row below it: back on the left, skip and next grouped right
    installFrame.back = CreateActionButton(installFrame, 110)
    installFrame.back:SetHeight(24)
    installFrame.back:SetPoint("BOTTOMLEFT", installFrame, "BOTTOMLEFT", 10, 4)
    installFrame.back:SetText(BACK)

    installFrame.next = CreateActionButton(installFrame, 110)
    installFrame.next:SetHeight(24)
    installFrame.next:SetPoint("BOTTOMRIGHT", installFrame, "BOTTOMRIGHT", -10, 4)
    installFrame.next:SetText(NEXT)

    installFrame.skip = CreateActionButton(installFrame, 110)
    installFrame.skip:SetHeight(24)
    installFrame.skip:SetText(L["Skip"])
end

-- ============================
-- Landing page + panel setup
-- ============================
local landingFrame

local function StartInstall()
    for _, step in ipairs(STEPS) do
        step.applied = nil
        step.summaryDetail = nil
        step.summaryTooltip = nil
    end
    landingFrame:Hide()
    installFrame:Show()
    RenderStep(1)
end

local function CreateLandingFrame()
    landingFrame = CreateFrame("Frame", nil, wpanel)
    landingFrame:SetPoint("TOP", wpanel, "TOP", 0, -60)
    landingFrame:SetPoint("BOTTOM", wpanel, "BOTTOM", 0, 14)
    landingFrame:SetWidth(478)

    landingFrame.title = landingFrame:CreateFontString(nil, "OVERLAY")
    landingFrame.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    landingFrame.title:SetTextColor(0.8, 0.75, 0.6)
    landingFrame.title:SetPoint("TOP", landingFrame, "TOP", 0, -14)
    landingFrame.title:SetText(L["GW2 UI installation"])

    local separator = landingFrame:CreateTexture(nil, "OVERLAY")
    separator:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
    separator:SetAlpha(0.8)
    separator:SetSize(260, 2)
    separator:SetPoint("TOP", landingFrame.title, "BOTTOM", 0, -4)

    landingFrame.intro = landingFrame:CreateFontString(nil, "OVERLAY")
    landingFrame.intro:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    landingFrame.intro:SetTextColor(0.9, 0.85, 0.7)
    landingFrame.intro:SetPoint("TOP", separator, "BOTTOM", 0, -16)
    landingFrame.intro:SetWidth(430)
    landingFrame.intro:SetJustifyH("CENTER")
    landingFrame.intro:SetText(L["GW2 UI is a full user interface replacement. We have built the user interface with a modular approach, this means that if you dislike a certain part of the addon - or have another you prefer for that function - you can just disable that part, while keeping the rest of the interface intact.\nSome of the modules available to you are an immersive questing window, a full inventory replacement, as well as a full character window replacement. There are many more that you can enjoy, just take a look in the settings menu to see what's available to you!"])

    landingFrame.express = CreateActionButton(landingFrame, 240)
    landingFrame.express:SetPoint("BOTTOM", landingFrame, "BOTTOM", 0, 76)
    landingFrame.express:SetText(L["Apply recommended settings"])
    landingFrame.express:SetScript("OnClick", ApplyExpressInstall)

    landingFrame.start = CreateActionButton(landingFrame, 240)
    landingFrame.start:SetPoint("BOTTOM", landingFrame, "BOTTOM", 0, 40)
    landingFrame.start:SetText(L["Start installation"])
    landingFrame.start:SetScript("OnClick", StartInstall)

    landingFrame.settings = CreateActionButton(landingFrame, 110)
    landingFrame.settings:SetHeight(24)
    landingFrame.settings:SetPoint("BOTTOMLEFT", landingFrame, "BOTTOMLEFT", 10, 4)
    landingFrame.settings:SetText(CHAT_CONFIGURATION)
    landingFrame.settings.target = GwSettingsWindow
    landingFrame.settings:SetScript("OnClick", settings_OnClick)

    landingFrame.close = CreateActionButton(landingFrame, 110)
    landingFrame.close:SetHeight(24)
    landingFrame.close:SetPoint("BOTTOMRIGHT", landingFrame, "BOTTOMRIGHT", -10, 4)
    landingFrame.close:SetText(CLOSE)
    landingFrame.close:SetScript("OnClick", GW.Parent_Hide)
end

local function setDefaultOpenLayout()
    wpanel.header:SetText(L["Welcome to GW2 UI"])
    installFrame:Hide()
    landingFrame:Show()
end

local function createPanel()
    wpanel = CreateFrame("Frame", "GwWelcomePage", UIParent, "GwWelcomePageTmpl")

    -- escape closes the window. NOT via UISpecialFrames: the chat setup activates an
    -- edit mode layout, and the edit mode closes all special frames - the installer
    -- would vanish mid step
    wpanel:EnableKeyboard(true)
    wpanel:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    local watermark = wpanel:CreateTexture(nil, "BACKGROUND", nil, 1)
    watermark:SetTexture("Interface/AddOns/GW2_UI/textures/gwlogo.png")
    watermark:SetAlpha(0.06)
    watermark:SetSize(200, 200)
    watermark:SetPoint("BOTTOMRIGHT", wpanel, "BOTTOMRIGHT", 40, 24)

    wpanel.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 12)
    wpanel.header:SetTextColor(1, 0.95, 0.8, 1)

    wpanel.subHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "OUTLINE")
    wpanel.subHeader:SetTextColor(0.9, 0.85, 0.7, 1)
    wpanel.subHeader:SetText(GW.GetVersionString())

    CreateInstallFrame()
    CreateLandingFrame()
end

local function ShowWelcomePanel()
    if not wpanel then
        createPanel()
    end
    setDefaultOpenLayout()
    wpanel:Show()
end
GW.ShowWelcomePanel = ShowWelcomePanel
