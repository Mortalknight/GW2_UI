---@class GW2
local GW = select(2, ...)
local L = GW.L

local function LoadChatPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "chat_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(CHAT)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit chat settings."])

    p:AddOption(ENABLE, L["Enable the improved chat window."], {getterSetter = "chat.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Chat", isMasterToggle = true})
    p:AddOption(L["GW2 Chat Message Style"], L["Changes the chat font, timestamp color and name display"], { getterSetter = "chat.gw2Style", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Fade Chat"], L["Allow the chat to fade when not in use."], { getterSetter = "chat.fade", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Hide Editbox"], L["Hide the chat editbox when not in focus."], { getterSetter = "chat.hideEditBox", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["URL Links"], L["Attempt to create URL links inside the chat."], { getterSetter = "chat.findUrl", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Hyperlink Hover"], L["Display the hyperlink tooltip while hovering over a hyperlink."], { getterSetter = "chat.hyperlinkTooltip", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Short Channels"], L["Shorten the channel names in chat."], { getterSetter = "chat.shortChannelNames", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Role Icon"], L["Display LFG Icons in group chat."], { getterSetter = "chat.lfgIcons", callback = function() GW.UpdateChatSettings() GW.CollectLfgRolesForChatIcons() end, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Class Color Mentions"], L["Use class color for the names of players when they are mentioned."], { getterSetter = "chat.classColorMentions", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Emotion Icons"], L["Display emotion icons in chat"], {getterSetter = "chat.keywords.emoji", callback = function(value) GW.UpdateChatSettings() if GW_EmoteFrame then GW_EmoteFrame:Hide() end for _, frameName in ipairs(CHAT_FRAMES) do if _G[frameName].buttonEmote then _G[frameName].buttonEmote:SetShown(value) end end end, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Quick Join Messages"], L["Show clickable Quick Join messages inside of the chat."], { getterSetter = "chat.socialLink", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Add timestamp to all messages"], nil, { getterSetter = "chat.timestampAll", callback = GW.UpdateChatSettings, dependence = {["chat.enabled"] = true}})
    p:AddOption(L["Copy Chat Lines"], L["Adds an arrow infront of the chat lines to copy the entire line"], { getterSetter = "chat.copyChatLines", dependence = {["chat.enabled"] = true}})
    p:AddOption(L["History"], L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session"], { getterSetter = "chat.history.enabled", dependence = {["chat.enabled"] = true}})
    p:AddOptionSlider(L["History Size"], nil, { getterSetter = "chat.history.size", min = 10, max = 500, decimalNumbers = 0, step = 1, dependence = {["chat.enabled"] = true, ["chat.history.enabled"] = true}})
    p:AddOptionButton(L["Reset History"], nil, {callback = function() GW.private.ChatHistoryLog = {} end, isNegativeButton = true, forceNewLine = true})

    p:AddOptionDropdown(L["Chat Buttons Position"], L["Position of the chat control buttons (menu, channel, voice, social). Top and Right move them into a small hover bar, so the chat window can sit flush at the screen edge."], { getterSetter = "chat.buttonsPosition", callback = function() GW.UpdateChatButtonsPosition() end, optionsList = {"LEFT", "TOP", "RIGHT"}, optionNames = {L["Left"], L["Top"], L["Right"]}, dependence = {["chat.enabled"] = true}})
    p:AddOptionDropdown(TIMESTAMPS_LABEL, OPTION_TOOLTIP_TIMESTAMPS, { getterSetter = "chat.timeStampFormat", optionsList = {"NONE", "%I:%M ", "%I:%M:%S ", "%I:%M %p ", "%I:%M:%S %p ", "%H:%M ", "%H:%M:%S "}, optionNames = {NONE, "03:27", "03:27:32", "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}, dependence = {["chat.enabled"] = true}})
    p:AddOptionDropdown(L["Announce Interrupts"], L["Announce when you interrupt a spell to the specified chat channel"], { getterSetter = "chat.interruptAnnounce", callback = GW.ToggleInterruptAnncouncement, optionsList = {"NONE", "SAY", "YELL", "PARTY", "RAID", "RAID_ONLY", "EMOTE"}, optionNames = {NONE, SAY, YELL, L["Party Only"], L["Party / Raid"], L["Raid Only"], EMOTE}, hidden = GW.Retail})

    local soundKeys = {}
    for _, sound in next, GW.Libs.LSM:List("sound") do
        tinsert(soundKeys, sound)
    end
    p:AddOptionDropdown(L["Keyword Alert"], nil, { getterSetter = "chat.keywords.alertNew", callback = GW.UpdateChatSettings, optionsList = soundKeys, optionNames = soundKeys, dependence = {["chat.enabled"] = true}, hasSound = true})

    p:AddOptionSlider(L["Spam Interval"], L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."], { getterSetter = "chat.spamInterval", callback = function() GW.UpdateChatSettings(); GW.DisableChatThrottle() end, min = 0, max = 100, decimalNumbers = 0, step = 1, dependence = {["chat.enabled"] = true}})
    p:AddOptionSlider(L["Combat Repeat"], L["Number of repeat characters while in combat before the chat editbox is automatically closed, set to zero to disable."], { getterSetter = "chat.inCombatTextRepeat", callback = function() GW.UpdateChatSettings() end, min = 0, max = 15, decimalNumbers = 0, step = 1, dependence = {["chat.enabled"] = true}})
    p:AddOptionSlider(L["Scroll Messages"], L["Number of messages you scroll for each step."], { getterSetter = "chat.scrollMessages", callback = function() GW.UpdateChatSettings() end, min = 1, max = 12, decimalNumbers = 0, step = 1, dependence = {["chat.enabled"] = true}})
    p:AddOptionSlider(L["Scroll Interval"], L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."], { getterSetter = "chat.scrollDownInterval", callback = function() GW.UpdateChatSettings() end, min = 0, max = 120, decimalNumbers = 0, step = 1, dependence = {["chat.enabled"] = true}})
    p:AddOptionSlider(L["Maximum lines of 'Copy Chat Frame'"], L["Set the maximum number of lines displayed in the Copy Chat Frame"], { getterSetter = "chat.maxCopyLines", min = 50, max = 500, decimalNumbers = 0, step = 1, dependence = {["chat.enabled"] = true}})
    p:AddOptionText(L["Keywords"], L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, Heal, Tank"], { getterSetter = "chat.keywords.list", callback = function() GW.UpdateChatSettings() GW.UpdateChatKeywords() end, dependence = {["chat.enabled"] = true}})
    p:AddOptionColorPicker(L["Keyword highlight color"], nil, { getterSetter = "CHAT_KEYWORDS_ALERT_COLOR", dependence = {["chat.enabled"] = true}, isPrivateSetting = true})

    sWindow:AddSettingsPanel(p, CHAT, L["Edit chat settings."])
end
GW.LoadChatPanel = LoadChatPanel
