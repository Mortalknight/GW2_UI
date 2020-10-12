local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local AddForProfiling = GW.AddForProfiling

local wpanel
local step = 0

local function settings_OnClick(self, button)
    local t = self.target
    self:GetParent():Hide()
    t:Show()
    UIFrameFadeIn(t, 0.2, 0, 1)
end
AddForProfiling("welcome", "settings_OnClick", settings_OnClick)

local function toggle_OnClick(self, button)
    if self:GetText() == L["CHANGELOG"] then
        self:GetParent().welcome:Hide()
        self:GetParent().changelog:Show()
        self:SetText(L["WELCOME"])
    else
        self:GetParent().changelog:Hide()
        self:GetParent().welcome:Show()
        self:SetText(L["CHANGELOG"])
    end
end
AddForProfiling("welcome", "toggle_OnClick", toggle_OnClick)

local function movehud_OnClick(self, button)
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(L["HUD_MOVE_ERR"])
        return
    end
    self:GetParent():Hide()
    GW.moveHudObjects(GwSettingsWindowMoveHud)
end
AddForProfiling("welcome", "movehud_OnClick", movehud_OnClick)

local function button1_OnClick()
    -- reset font settings
    wpanel.welcome.header:SetFont(DAMAGE_TEXT_FONT,24)
    wpanel.welcome.header:SetTextColor(0.8,0.75,0.6,1)

    wpanel.welcome.subHeader:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.welcome.subHeader:SetTextColor(0.9,0.85,0.7,1)

    -- hide buttons
    wpanel.settings:Hide()
    wpanel.changelogORwelcome:Hide()

    -- Start install Process
    if step == 0 then
        wpanel.welcome.header:SetText(L["INSTALL_START_HEADER"] .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["INSTALL_DESCRIPTION_DSC"])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(NEXT)
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Hide()

        wpanel.welcome.button1:SetScript("OnClick", function(self)
            step = 1
            button1_OnClick()
        end)
    elseif step == 1 then
        wpanel.welcome.header:SetText(CHAT .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["INSTALL_CHAT_DESC"])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["INSTALL_CHAT_BTN"])
        wpanel.welcome.button2:SetText(L["QUEST_VIEW_SKIP"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Show()

        wpanel.welcome.button1:SetScript("OnClick", function(self)
            FCF_ResetChatWindows()
            FCF_OpenNewWindow(LOOT .. " / " .. TRADE)

            for _, name in ipairs(_G.CHAT_FRAMES) do
                local frame = _G[name]
                local id = frame:GetID()
        
                -- move general bottom left
                if id == 1 then
                    frame:ClearAllPoints()
                    frame:SetPoint("BOTTOMLEFT", UIParent, 40, 60)
                end
        
                FCF_SavePositionAndDimensions(frame)
                FCF_StopDragging(frame)
                FCF_SetChatWindowFontSize(nil, frame, 12)
            end

            -- keys taken from "ChatTypeGroup" but doesnt add: "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO", "COMMUNITIES_CHANNEL", "PET_BATTLE_COMBAT_LOG", "PET_BATTLE_INFO", "TARGETICONS"
            local chatGroup = {"SYSTEM", "CHANNEL", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_INLINE_TOAST_ALERT"}
            ChatFrame_RemoveAllMessageGroups(_G.ChatFrame1)
            for _, v in ipairs(chatGroup) do
                ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
            end

            -- keys taken from "ChatTypeGroup" which weren't added above to ChatFrame1
            chatGroup = {"COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY"}
            ChatFrame_RemoveAllMessageGroups(_G.ChatFrame3)
            for _, v in ipairs(chatGroup) do
                ChatFrame_AddMessageGroup(_G.ChatFrame3, v)
            end

            ChatFrame_AddChannel(_G.ChatFrame1, GENERAL)
            ChatFrame_RemoveChannel(_G.ChatFrame1, TRADE)
            ChatFrame_AddChannel(_G.ChatFrame3, TRADE)

            -- set the chat groups names in class color to enabled for all chat groups which players names appear
            chatGroup = {"SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL"}
            for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
                tinsert(chatGroup, "CHANNEL" .. i)
            end
            for _, v in ipairs(chatGroup) do
                ToggleChatColorNamesByClassGroup(true, v)
            end

            -- if we are in debug mode add a "Debug"-Tab
            if GW.VERSION_STRING == "GW2_UI @project-version@" then
                FCF_OpenNewWindow(BINDING_HEADER_DEBUG, true)
                SetSetting("DEV_DBG_CHAT_TAB", 4)
                DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r hooking Debug to chat tab #4")
                GW.AlertTestsSetup()
                SetCVar("fstack_preferParentKeys", 0) --Add back the frame names via fstack!
                GW.inDebug = true
            else
                GW.inDebug = false
            end

            GW2_UIAlertSystem.AlertSystem:AddAlert(L["INSTALL_FINISHED_BTN"], nil, L["INSTALL_CHAT_BTN"], false, "Interface/AddOns/GW2_UI/textures/icon-levelup", true)

            step = 2
            button1_OnClick()
        end)
        wpanel.welcome.button2:SetScript("OnClick", function(self)
            step = 2
            button1_OnClick()
        end)
    elseif step == 2 then
        wpanel.welcome.header:SetText("CVars" .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["INSTALL_CVARS_DESC"])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["INSTALL_CVARS_BTN"])
        wpanel.welcome.button2:SetText(L["QUEST_VIEW_SKIP"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Show()

        wpanel.welcome.button1:SetScript("OnClick", function(self)
            SetCVar("statusTextDisplay", "BOTH")
            SetCVar("screenshotQuality", 10)
            SetCVar("chatMouseScroll", 1)
            SetCVar("chatStyle", "classic")
            SetCVar("wholeChatWindowClickable", 0)
            SetCVar("showTutorials", 0)
            SetCVar("UberTooltips", 1)
            SetCVar("threatWarning", 3)
            SetCVar("alwaysShowActionBars", 1)
            SetCVar("lockActionBars", 1)
            SetCVar("spamFilter", 0)
            SetCVar("cameraDistanceMaxZoomFactor", 2.6)
            SetCVar("showQuestTrackingTooltips", 1)
            SetCVar("fstack_preferParentKeys", 0)

            GW2_UIAlertSystem.AlertSystem:AddAlert(L["INSTALL_FINISHED_BTN"], nil, L["INSTALL_CVARS_BTN"], false, "Interface/AddOns/GW2_UI/textures/icon-levelup", true)

            step = 3
            button1_OnClick()
        end)
        wpanel.welcome.button2:SetScript("OnClick", function(self)
            step = 3
            button1_OnClick()
        end)
    elseif step == 3 then
        wpanel.welcome.header:SetText(L["PIXEL_PERFECTION"] .. "\n\n\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["WELCOME_SPLASH_WELCOME_TEXT_PP"])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["PIXEL_PERFECTION_ON"])
        wpanel.welcome.button2:SetText(L["QUEST_VIEW_SKIP"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Show()

        wpanel.welcome.button1:SetScript("OnClick", function(self)
            SetSetting("PIXEL_PERFECTION", true)
            GW.PixelPerfection()

            GW2_UIAlertSystem.AlertSystem:AddAlert(L["PIXEL_PERFECTION"], nil, L["PIXEL_PERFECTION_ON"], false, "Interface/AddOns/GW2_UI/textures/icon-levelup", true)

            step = 4
            button1_OnClick()
        end)
        wpanel.welcome.button2:SetScript("OnClick", function(self)
            step = 4
            button1_OnClick()
        end)
    elseif step == 4 then
        wpanel.welcome.header:SetText(L["INSTALL_FINISHED_HEADER"] .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["INSTALL_FINISHED_DESC"])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["INSTALL_FINISHED_BTN"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Hide()

        wpanel.welcome.button1:SetScript("OnClick", function(self)
            C_UI.Reload()
        end)
    end
end
AddForProfiling("welcome", "pixel_OnClick", pixel_OnClick)

local function setDefaultOpenLayout()
    wpanel.welcome.header:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.welcome.header:SetTextColor(0.9,0.85,0.7,1)

    wpanel.welcome.subHeader:SetFont(DAMAGE_TEXT_FONT,22,"OUTLINE")
    wpanel.welcome.subHeader:SetTextColor(0.8,0.75,0.6,1)

    wpanel.header:SetText(L["WELCOME_SPLASH_HEADER"])
    wpanel.welcome.header:SetText(L["WELCOME_SPLASH_WELCOME_TEXT"] .. "\n\n\n\n\n\n\n\n")
    wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["INSTALL_DESCRIPTION_HEADER"])

    wpanel.close:SetText(CLOSE)
    wpanel.settings:SetText(CHAT_CONFIGURATION)
    wpanel.welcome.button0:SetText(L["INSTALL_START_BTN"])
    wpanel.welcome.button0:Show()
    wpanel.welcome.button1:Hide()
    wpanel.welcome.button2:Hide()
    wpanel.settings:Show()
    wpanel.changelogORwelcome:Show()
end

local function createPanel()
    wpanel = CreateFrame("Frame", nil, UIParent, "GwWelcomePageTmpl")
    wpanel.changelog.scroll:SetScrollChild(wpanel.changelog.scroll.scrollchild)
    wpanel.changelog.scroll.scrollchild:SetSize(wpanel.changelog.scroll:GetSize())
    wpanel.changelog.scroll.scrollchild:SetWidth(wpanel.changelog.scroll:GetWidth() - 20)

    wpanel.header:SetFont(DAMAGE_TEXT_FONT,30,"OUTLINE")
    wpanel.header:SetTextColor(1,0.95,0.8,1)

    wpanel.subHeader:SetFont(DAMAGE_TEXT_FONT,16,"OUTLINE")
    wpanel.subHeader:SetTextColor(0.9,0.85,0.7,1)

    wpanel.changelog.header:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.changelog.header:SetTextColor(0.8,0.75,0.6,1)

    wpanel.changelog.scroll.scrollchild.text:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.changelog.scroll.scrollchild.text:SetTextColor(0.8,0.75,0.6,1)

    wpanel.changelog.header:SetText(L["CHANGELOG"])

    wpanel.subHeader:SetText(GW.VERSION_STRING)
    wpanel.changelog.scroll.scrollchild.text:SetText(GW.GW_CHANGELOGS)
    wpanel.changelog.scroll.slider:SetMinMaxValues(0, wpanel.changelog.scroll.scrollchild.text:GetStringHeight())
    wpanel.changelog.scroll.slider.thumb:SetHeight(100)
    wpanel.changelog.scroll.slider:SetValue(1)
    wpanel.changelogORwelcome:SetText(L["CHANGELOG"])

    -- settings button
    wpanel.settings.target = GwSettingsWindow
    wpanel.settings:SetScript("OnClick", settings_OnClick)

    -- changelog/welcome toggle button
    wpanel.changelogORwelcome:SetScript("OnClick", toggle_OnClick)

    -- pixel perfect toggle
    wpanel.welcome.button0:SetScript("OnClick", button1_OnClick)

    -- pixel perfect toggle
    wpanel.close:SetScript("OnClick", GW.Parent_Hide)
end
AddForProfiling("welcome", "createPanel", createPanel)

local function ShowWelcomePanel()
    if not wpanel then
        createPanel()
    end
    step = 0
    setDefaultOpenLayout()
    wpanel.changelogORwelcome:SetText(L["CHANGELOG"])
    wpanel.changelog:Hide()
    wpanel.welcome:Show()
    wpanel:Show()
end
GW.ShowWelcomePanel = ShowWelcomePanel

local function ShowChangelogPanel()
    if not wpanel then
        createPanel()
    end

    wpanel.changelogORwelcome:SetText(L["WELCOME"])
    wpanel.welcome:Hide()
    wpanel.changelog:Show()
    wpanel:Show()
end
GW.ShowChangelogPanel = ShowChangelogPanel
