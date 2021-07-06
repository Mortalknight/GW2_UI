local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionButton = GW.AddOptionButton
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadChatPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.scroll.scrollchild.header:SetText(CHAT)
    p.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.scroll.scrollchild.sub:SetText(L["TODO"])

    createCat(CHAT, L["TODO"], p, 3, nil, {p})

    addOption(p.scroll.scrollchild, L["URL Links"], L["Attempt to create URL links inside the chat."] , "CHAT_FIND_URL", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Hyperlink Hover"], L["Display the hyperlink tooltip while hovering over a hyperlink."], "CHAT_HYPERLINK_TOOLTIP", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Short Channels"], L["Shorten the channel names in chat."], "CHAT_SHORT_CHANNEL_NAMES", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Role Icon"], L["Display LFG Icons in group chat."] , "CHAT_SHOW_LFG_ICONS", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOptionSlider(
        p.scroll.scrollchild,
        L["Spam Interval"] ,
        L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
        "CHAT_SPAM_INTERVAL_TIMER",
        function()
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
        nil,
        0,
        15,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )


    InitPanel(p, true)
end
GW.LoadChatPanel = LoadChatPanel
