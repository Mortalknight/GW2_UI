local _, GW = ...
local L = GW.L
local SetSetting = GW.SetSetting
local AddForProfiling = GW.AddForProfiling

local wpanel
local step = 0

local function settings_OnClick(self)
    local t = self.target
    self:GetParent():Hide()
    t:Show()
    UIFrameFadeIn(t, 0.2, 0, 1)
end
AddForProfiling("welcome", "settings_OnClick", settings_OnClick)

local function toggle_OnClick(self)
    if self:GetText() == L["Changelog"] then
        self:GetParent().welcome:Hide()
        self:GetParent().changelog:Show()
        self:SetText(L["Welcome"])
    else
        self:GetParent().changelog:Hide()
        self:GetParent().welcome:Show()
        self:SetText(L["Changelog"])
    end
end
AddForProfiling("welcome", "toggle_OnClick", toggle_OnClick)

local function movehud_OnClick(self)
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
        return
    end
    self:GetParent():Hide()
    GW.moveHudObjects(GW.MoveHudScaleableFrame)
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
        wpanel.welcome.header:SetText(L["Installation"] .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["This short installation process will help you to set up all of the necessary settings used by GW2 UI."])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(NEXT)
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Hide()

        wpanel.welcome.button1:SetScript("OnClick", function()
            step = 1
            button1_OnClick()
        end)
    elseif step == 1 then
        wpanel.welcome.header:SetText(CHAT .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["This part sets up your chat window names, positions, and colors."])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["Setup Chat"])
        wpanel.welcome.button2:SetText(L["Skip"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Show()

        wpanel.welcome.button1:SetScript("OnClick", function()
            FCF_ResetChatWindows()
            FCF_OpenNewWindow(LOOT .. " / " .. TRADE)

            for _, name in ipairs(CHAT_FRAMES) do
                local frame = _G[name]
                local id = frame:GetID()

                -- move general bottom left
                if id == 1 then
                    frame:ClearAllPoints()
                    frame:SetPoint("BOTTOMLEFT", UIParent, 40, 60)
                    frame:SetUserPlaced(true)
                end

                FCF_SavePositionAndDimensions(frame)
                FCF_StopDragging(frame)
                FCF_SetChatWindowFontSize(nil, frame, 12)

                if id == 2 then
                    FCF_SetWindowName(frame, GUILD_EVENT_LOG)
                elseif id == 3 then
                    VoiceTranscriptionFrame_UpdateVisibility(frame)
                    VoiceTranscriptionFrame_UpdateVoiceTab(frame)
                    VoiceTranscriptionFrame_UpdateEditBox(frame)
                end
            end

            -- keys taken from "ChatTypeGroup" but doesnt add: "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO", "COMMUNITIES_CHANNEL", "PET_BATTLE_COMBAT_LOG", "PET_BATTLE_INFO", "TARGETICONS"
            local chatGroup = {"SYSTEM", "CHANNEL", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_INLINE_TOAST_ALERT"}
            ChatFrame_RemoveAllMessageGroups(ChatFrame1)
            for _, v in ipairs(chatGroup) do
                ChatFrame_AddMessageGroup(ChatFrame1, v)
            end

            -- keys taken from "ChatTypeGroup" which weren't added above to ChatFrame1
            chatGroup = {"COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY"}
            ChatFrame_RemoveAllMessageGroups(ChatFrame4)
            for _, v in ipairs(chatGroup) do
                ChatFrame_AddMessageGroup(ChatFrame4, v)
            end

            ChatFrame_AddChannel(ChatFrame1, GENERAL)
            ChatFrame_RemoveChannel(ChatFrame1, TRADE)
            ChatFrame_AddChannel(ChatFrame4, TRADE)

            -- set the chat groups names in class color to enabled for all chat groups which players names appear
            chatGroup = {"SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL"}
            for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
                tinsert(chatGroup, "CHANNEL" .. i)
            end
            for _, v in ipairs(chatGroup) do
                ToggleChatColorNamesByClassGroup(true, v)
            end

            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Complete"] .. ": " .. L["Setup Chat"]):gsub("*", GW.Gw2Color))

            step = 2
            button1_OnClick()
        end)
        wpanel.welcome.button2:SetScript("OnClick", function()
            step = 2
            button1_OnClick()
        end)
    elseif step == 2 then
        wpanel.welcome.header:SetText("CVars" .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["This part sets up your World of Warcraft default options."])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["Setup CVars"])
        wpanel.welcome.button2:SetText(L["Skip"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Show()

        wpanel.welcome.button1:SetScript("OnClick", function()
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
            SetCVar("whisperMode", "inline")

            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Complete"] .. ": " .. L["Setup CVars"]):gsub("*", GW.Gw2Color))

            step = 3
            button1_OnClick()
        end)
        wpanel.welcome.button2:SetScript("OnClick", function()
            step = 3
            button1_OnClick()
        end)
    elseif step == 3 then
        wpanel.welcome.header:SetText(L["Pixel Perfect Mode"] .. "\n\n\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["What is 'Pixel Perfect'?\n\nGW2 UI has a built-in setting called 'Pixel Perfect Mode'. What this means for you is that your user interface will look as was intended, with crisper textures and better scaling. Of course, you can toggle this off in the settings menu should you prefer."])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["Turn Pixel Perfect Mode On"])
        wpanel.welcome.button2:SetText(L["Skip"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Show()

        wpanel.welcome.button1:SetScript("OnClick", function()
            SetSetting("PIXEL_PERFECTION", true)
            GW.PixelPerfection()

            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Pixel Perfect Mode"] .. ": " .. L["Turn Pixel Perfect Mode On"]):gsub("*", GW.Gw2Color))

            step = 4
            button1_OnClick()
        end)
        wpanel.welcome.button2:SetScript("OnClick", function()
            step = 4
            button1_OnClick()
        end)
    elseif step == 4 then
        wpanel.welcome.header:SetText(L["Installation Complete"] .. "\n\n\n\n")
        wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["You have now finished installing GW2 UI!"])
        wpanel.welcome.button0:Hide()
        wpanel.welcome.button1:SetText(L["Complete"])
        wpanel.welcome.button1:Show()
        wpanel.welcome.button2:Hide()

        wpanel.welcome.button1:SetScript("OnClick", function()
            C_UI.Reload()
        end)
    end
end
AddForProfiling("welcome", "button1_OnClick", button1_OnClick)

local function setDefaultOpenLayout()
    wpanel.welcome.header:SetFont(DAMAGE_TEXT_FONT,14)
    wpanel.welcome.header:SetTextColor(0.9,0.85,0.7,1)

    wpanel.welcome.subHeader:SetFont(DAMAGE_TEXT_FONT,22,"OUTLINE")
    wpanel.welcome.subHeader:SetTextColor(0.8,0.75,0.6,1)

    wpanel.header:SetText(L["Welcome to GW2 UI"])
    wpanel.welcome.header:SetText(L["GW2 UI is a full user interface replacement. We have built the user interface with a modular approach, this means that if you dislike a certain part of the addon - or have another you prefer for that function - you can just disable that part, while keeping the rest of the interface intact.\nSome of the modules available to you are an immersive questing window, a full inventory replacement, as well as a full character window replacement. There are many more that you can enjoy, just take a look in the settings menu to see what's available to you!"] .. "\n\n\n\n\n\n\n\n")
    wpanel.welcome.subHeader:SetText("\n\n\n\n" .. L["GW2 UI installation"])

    wpanel.close:SetText(CLOSE)
    wpanel.settings:SetText(CHAT_CONFIGURATION)
    wpanel.welcome.button0:SetText(L["Start installation"])
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

    wpanel.changelog.header:SetText(L["Changelog"])

    wpanel.subHeader:SetText(GW.VERSION_STRING)
    wpanel.changelog.scroll.scrollchild.text:SetText(GW.GW_CHANGELOGS)
    wpanel.changelog.scroll.slider:SetMinMaxValues(0, wpanel.changelog.scroll.scrollchild.text:GetStringHeight())
    wpanel.changelog.scroll.slider.thumb:SetHeight(100)
    wpanel.changelog.scroll.slider:SetValue(1)
    wpanel.changelogORwelcome:SetText(L["Changelog"])

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
    wpanel.changelogORwelcome:SetText(L["Changelog"])
    wpanel.changelog:Hide()
    wpanel.welcome:Show()
    wpanel:Show()
end
GW.ShowWelcomePanel = ShowWelcomePanel

local function ShowChangelogPanel()
    if not wpanel then
        createPanel()
    end
    setDefaultOpenLayout()
    wpanel.changelogORwelcome:SetText(L["Welcome"])
    wpanel.welcome:Hide()
    wpanel.changelog:Show()
    wpanel:Show()
end
GW.ShowChangelogPanel = ShowChangelogPanel
