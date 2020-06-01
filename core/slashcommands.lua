local _, GW = ...

local function LoadSlashCommands()
    _G["SLASH_GWSLASH1"] = "/gw2"

    SlashCmdList["GWSLASH"] = function(msg, eb)
        if msg == "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Slash commands:")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r  /gw2 settings       -> To open the settings window")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r  /gw2 reset windows  -> To reset the inventory and hero panel windows")
        elseif msg == "settings" then
            ShowUIPanel(GwSettingsWindow)
            UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
        elseif msg == "reset windows" then
            GW.SetSetting("BAG_POSITION", nil)
            GW.SetSetting("BANK_POSITION", nil)
            GW.SetSetting("HERO_POSITION", nil)
            C_UI.Reload()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r '" .. msg .. "' is not a valid GW2 UI slash command.")
        end
    end
end
GW.LoadSlashCommands = LoadSlashCommands