local _, GW = ...
local L = GW.L

local function LoadChatPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(CHAT)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit chat settings."])

    p:AddOption(L["GW2 chat message style"], L["Changes the chat font, timestamp color and name display"], { getterSetter = "CHAT_USE_GW2_STYLE", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Fade Chat"], L["Allow the chat to fade when not in use."], { getterSetter = "CHATFRAME_FADE", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Hide Editbox"], L["Hide the chat editbox when not in focus."], { getterSetter = "CHATFRAME_EDITBOX_HIDE", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["URL Links"], L["Attempt to create URL links inside the chat."], { getterSetter = "CHAT_FIND_URL", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Hyperlink Hover"], L["Display the hyperlink tooltip while hovering over a hyperlink."], { getterSetter = "CHAT_HYPERLINK_TOOLTIP", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Short Channels"], L["Shorten the channel names in chat."], { getterSetter = "CHAT_SHORT_CHANNEL_NAMES", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Role Icon"], L["Display LFG Icons in group chat."], { getterSetter = "CHAT_SHOW_LFG_ICONS", callback = function() GW.UpdateChatSettings() GW.CollectLfgRolesForChatIcons() end, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Class Color Mentions"], L["Use class color for the names of players when they are mentioned."], { getterSetter = "CHAT_CLASS_COLOR_MENTIONS", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Emotion Icons"], L["Display emotion icons in chat"], {getterSetter = "CHAT_KEYWORDS_EMOJI", callback = function(value) GW.UpdateChatSettings() if GW_EmoteFrame then GW_EmoteFrame:Hide() end for _, frameName in ipairs(CHAT_FRAMES) do if _G[frameName].buttonEmote then _G[frameName].buttonEmote:SetShown(value) end end end, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Quick Join Messages"], L["Show clickable Quick Join messages inside of the chat."], { getterSetter = "CHAT_SOCIAL_LINK", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Add timestamp to all messages"], nil, { getterSetter = "CHAT_ADD_TIMESTAMP_TO_ALL", callback = GW.UpdateChatSettings, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["Copy Chat Lines"], L["Adds an arrow infront of the chat lines to copy the entire line"], { getterSetter = "copyChatLines", dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOption(L["History"], L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session"], { getterSetter = "chatHistory", dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionSlider(L["History Size"], nil, { getterSetter = "historySize", min = 10, max = 500, decimalNumbers = 0, step = 1, dependence = {["CHATFRAME_ENABLED"] = true, ["chatHistory"] = true}})
    p:AddOptionButton(L["Reset History"], nil, {callback = function() GW.private.ChatHistoryLog = {} end})

    p:AddOptionDropdown(TIMESTAMPS_LABEL, OPTION_TOOLTIP_TIMESTAMPS, { getterSetter = "timeStampFormat", optionsList = {"NONE", "%I:%M ", "%I:%M:%S ", "%I:%M %p ", "%I:%M:%S %p ", "%H:%M ", "%H:%M:%S "}, optionNames = {NONE, "03:27", "03:27:32", "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}})
    p:AddOptionDropdown(L["Announce Interrupts"], L["Announce when you interrupt a spell to the specified chat channel"], { getterSetter = "interruptAnnounce", callback = GW.ToggleInterruptAnncouncement, optionsList = {"NONE", "SAY", "YELL", "PARTY", "RAID", "RAID_ONLY", "EMOTE"}, optionNames = {NONE, SAY, YELL, L["Party Only"], L["Party / Raid"], L["Raid Only"], EMOTE}})

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end
    p:AddOptionDropdown(L["Keyword Alert"], nil, { getterSetter = "CHAT_KEYWORDS_ALERT_NEW", callback = GW.UpdateChatSettings, optionsList = soundKeys, optionNames = soundKeys, dependence = {["CHATFRAME_ENABLED"] = true}, hasSound = true})

    p:AddOptionSlider(L["Spam Interval"], L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."], { getterSetter = "CHAT_SPAM_INTERVAL_TIMER", callback = function() GW.UpdateChatSettings(); GW.DisableChatThrottle() end, min = 0, max = 100, decimalNumbers = 0, step = 1, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionSlider(L["Combat Repeat"], L["Number of repeat characters while in combat before the chat editbox is automatically closed, set to zero to disable."], { getterSetter = "CHAT_INCOMBAT_TEXT_REPEAT", callback = function() GW.UpdateChatSettings() end, min = 0, max = 15, decimalNumbers = 0, step = 1, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionSlider(L["Scroll Messages"], L["Number of messages you scroll for each step."], { getterSetter = "CHAT_NUM_SCROLL_MESSAGES", callback = function() GW.UpdateChatSettings() end, min = 1, max = 12, decimalNumbers = 0, step = 1, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionSlider(L["Scroll Interval"], L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."], { getterSetter = "CHAT_SCROLL_DOWN_INTERVAL", callback = function() GW.UpdateChatSettings() end, min = 0, max = 120, decimalNumbers = 0, step = 1, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionSlider(L["Maximum lines of 'Copy Chat Frame'"], L["Set the maximum number of lines displayed in the Copy Chat Frame"], { getterSetter = "CHAT_MAX_COPY_CHAT_LINES", min = 50, max = 500, decimalNumbers = 0, step = 1, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionText(L["Keywords"], L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, Heal, Tank"], { getterSetter = "CHAT_KEYWORDS", callback = function() GW.UpdateChatSettings() GW.UpdateChatKeywords() end, dependence = {["CHATFRAME_ENABLED"] = true}})
    p:AddOptionColorPicker(L["Keyword highlight color"], nil, { getterSetter = "CHAT_KEYWORDS_ALERT_COLOR", dependence = {["CHATFRAME_ENABLED"] = true}, isPrivateSetting = true})

    sWindow:AddSettingsPanel(p, CHAT, L["Edit chat settings."])
end
GW.LoadChatPanel = LoadChatPanel
