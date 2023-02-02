local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionColorPicker = GW.AddOptionColorPicker
local addOptionSlider = GW.AddOptionSlider
local addOptionText = GW.AddOptionText
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadChatPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(CHAT)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit chat settings."])

    createCat(CHAT, nil, p, {p})
    settingsMenuAddButton(CHAT, p, {})
    addOption(p.scroll.scrollchild, L["GW2 chat message style"], L["Changes the chat font, timestamp color and name display"], "CHAT_USE_GW2_STYLE", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Fade Chat"], L["Allow the chat to fade when not in use."], "CHATFRAME_FADE", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Hide Editbox"], L["Hide the chat editbox when not in focus."], "CHATFRAME_EDITBOX_HIDE", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["URL Links"], L["Attempt to create URL links inside the chat."], "CHAT_FIND_URL", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Hyperlink Hover"], L["Display the hyperlink tooltip while hovering over a hyperlink."], "CHAT_HYPERLINK_TOOLTIP", function(value) GW.UpdateChatSettings(true); GW.ToggleChatHyperlink(value) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Short Channels"], L["Shorten the channel names in chat."], "CHAT_SHORT_CHANNEL_NAMES", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Role Icon"], L["Display LFG Icons in group chat."], "CHAT_SHOW_LFG_ICONS", function() GW.UpdateChatSettings(true); GW.CollectLfgRolesForChatIcons() end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Class Color Mentions"], L["Use class color for the names of players when they are mentioned."], "CHAT_CLASS_COLOR_MENTIONS", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Emotion Icons"], L["Display emotion icons in chat"], "CHAT_KEYWORDS_EMOJI", function(value) GW.UpdateChatSettings(true); GW_EmoteFrame:Hide(); for _, frameName in ipairs(CHAT_FRAMES) do if _G[frameName].buttonEmote then _G[frameName].buttonEmote:SetShown(value); end end end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Quick Join Messages"], L["Show clickable Quick Join messages inside of the chat."], "CHAT_SOCIAL_LINK", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Add timestamp to all messages"], nil, "CHAT_ADD_TIMESTAMP_TO_ALL", function() GW.UpdateChatSettings(true) end, nil, {["CHATFRAME_ENABLED"] = true})

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
            GW.UpdateChatSettings(true)
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
            GW.UpdateChatSettings(true)
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
            GW.UpdateChatSettings(true)
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
            GW.UpdateChatSettings(true)
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
            GW.UpdateChatSettings(true)
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
            GW.UpdateChatSettings(true)
            GW.UpdateChatKeywords()
        end,
        false,
        nil,
        {["CHATFRAME_ENABLED"] = true}
    )
    addOptionColorPicker(p.scroll.scrollchild, L["Keyword highlight color"], nil, "CHAT_KEYWORDS_ALERT_COLOR", nil, nil, {["CHATFRAME_ENABLED"] = true})

    InitPanel(p, true)
end
GW.LoadChatPanel = LoadChatPanel
