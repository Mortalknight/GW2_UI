local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionColorPicker = GW.AddOptionColorPicker
local addOptionButton = GW.AddOptionButton
local addOptionSlider = GW.AddOptionSlider
local addOptionText = GW.AddOptionText
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadChatPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(CHAT)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit chat settings."])

    createCat(CHAT, nil, p, {p})
    settingsMenuAddButton(CHAT, p, {})
    addOption(p.scroll.scrollchild, L["GW2 chat message style"], L["Changes the chat font, timestamp color and name display"], "CHAT_USE_GW2_STYLE", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Fade Chat"], L["Allow the chat to fade when not in use."], "CHATFRAME_FADE", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Hide Editbox"], L["Hide the chat editbox when not in focus."], "CHATFRAME_EDITBOX_HIDE", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["URL Links"], L["Attempt to create URL links inside the chat."], "CHAT_FIND_URL", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Hyperlink Hover"], L["Display the hyperlink tooltip while hovering over a hyperlink."], "CHAT_HYPERLINK_TOOLTIP", GW.UpdateChatSettings, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Short Channels"], L["Shorten the channel names in chat."], "CHAT_SHORT_CHANNEL_NAMES", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Role Icon"], L["Display LFG Icons in group chat."], "CHAT_SHOW_LFG_ICONS", function() GW.UpdateChatSettings(); GW.CollectLfgRolesForChatIcons() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Class Color Mentions"], L["Use class color for the names of players when they are mentioned."], "CHAT_CLASS_COLOR_MENTIONS", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Emotion Icons"], L["Display emotion icons in chat"], "CHAT_KEYWORDS_EMOJI", function(value) GW.UpdateChatSettings(); GW_EmoteFrame:Hide(); for _, frameName in ipairs(CHAT_FRAMES) do if _G[frameName].buttonEmote then _G[frameName].buttonEmote:SetShown(value); end end end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Quick Join Messages"], L["Show clickable Quick Join messages inside of the chat."], "CHAT_SOCIAL_LINK", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Add timestamp to all messages"], nil, "CHAT_ADD_TIMESTAMP_TO_ALL", function() GW.UpdateChatSettings() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, GW.NewSign .. L["Copy Chat Lines"], L["Adds an arrow infront of the chat lines to copy the entire line"], "copyChatLines", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, GW.NewSign .. L["History"], L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session"], "chatHistory", nil, nil, {["CHATFRAME_ENABLED"] = true})

    addOptionSlider(
        p.scroll.scrollchild,
        GW.NewSign .. L["History Size"],
        nil,
        "historySize",
        nil,
        10,
        500,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true, ["chatHistory"] = true},
        1
    )
    addOptionButton(p.scroll.scrollchild, GW.NewSign .. L["Reset History"], nil, "GW2_ResetChatHistoryButton", function() GW.private.ChatHistoryLog = {} end)

    addOptionDropdown(
        p.scroll.scrollchild,
        GW.NewSign .. TIMESTAMPS_LABEL,
        OPTION_TOOLTIP_TIMESTAMPS,
        "timeStampFormat",
        nil,
        {"NONE", "%I:%M ", "%I:%M:%S ", "%I:%M %p ", "%I:%M:%S %p ", "%H:%M ", "%H:%M:%S "},
        {NONE, "03:27", "03:27:32", "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        L["Announce Interrupts"],
        L["Announce when you interrupt a spell to the specified chat channel"],
        "interruptAnnounce",
        GW.ToggleInterruptAnncouncement,
        {"NONE", "SAY", "YELL", "PARTY", "RAID", "RAID_ONLY", "EMOTE"},
        {NONE, SAY, YELL, L["Party Only"], L["Party / Raid"], L["Raid Only"], EMOTE}
    )

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Keyword Alert"],
        nil,
        "CHAT_KEYWORDS_ALERT_NEW",
        function()
            GW.UpdateChatSettings()
        end,
        soundKeys,
        soundKeys,
        nil,
        {["CHATFRAME_ENABLED"] = true},
        nil,
        nil,
        nil,
        true
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Spam Interval"] ,
        L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
        "CHAT_SPAM_INTERVAL_TIMER",
        function()
            GW.UpdateChatSettings()
            GW.DisableChatThrottle()
        end,
        0,
        100,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Combat Repeat"],
        L["Number of repeat characters while in combat before the chat editbox is automatically closed, set to zero to disable."],
        "CHAT_INCOMBAT_TEXT_REPEAT",
        function()
            GW.UpdateChatSettings()
        end,
        0,
        15,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Scroll Messages"],
        L["Number of messages you scroll for each step."],
        "CHAT_NUM_SCROLL_MESSAGES",
        function()
            GW.UpdateChatSettings()
        end,
        1,
        12,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )

    addOptionSlider(
        p.scroll.scrollchild,
        L["Scroll Interval"],
        L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."],
        "CHAT_SCROLL_DOWN_INTERVAL",
        function()
            GW.UpdateChatSettings()
        end,
        0,
        120,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Maximum lines of 'Copy Chat Frame'"],
        L["Set the maximum number of lines displayed in the Copy Chat Frame"],
        "CHAT_MAX_COPY_CHAT_LINES",
        nil,
        50,
        500,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )
    addOptionText(
        p.scroll.scrollchild,
        L["Keywords"],
        L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, Heal, Tank"],
        "CHAT_KEYWORDS",
        function()
            GW.UpdateChatSettings()
            GW.UpdateChatKeywords()
        end,
        false,
        nil,
        {["CHATFRAME_ENABLED"] = true}
    )
    addOptionColorPicker(p.scroll.scrollchild, L["Keyword highlight color"], nil, "CHAT_KEYWORDS_ALERT_COLOR", nil, nil, {["CHATFRAME_ENABLED"] = true}, nil, nil, nil, true)

    InitPanel(p, true)
end
GW.LoadChatPanel = LoadChatPanel
