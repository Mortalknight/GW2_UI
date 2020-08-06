local _, GW = ...

local function LoadSlashCommands()
    _G["SLASH_GWSLASH1"] = "/gw2"

    SlashCmdList["GWSLASH"] = function(msg, eb)
        if msg == "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Slash commands:")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r   /gw2 settings       -> To open the settings window")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r   /gw2 reset windows  -> To reset the inventory and hero panel windows")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r   /gw2 status         -> To show GW2 Status window")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r   /gw2 kb             -> To activate the keybindoptions")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r   /gw2 mh             -> To activate 'Move HUD'-Mode")
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r   /gw2 reset profile  -> To reset the current profile to default settings")
        elseif msg == "settings" then
            ShowUIPanel(GwSettingsWindow)
            UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
        elseif msg == "reset windows" then
            GW.SetSetting("BAG_POSITION", nil)
            GW.SetSetting("BANK_POSITION", nil)
            GW.SetSetting("HERO_POSITION", nil)
            GW.SetSetting("MAILBOX_POSITION", nil)
            C_UI.Reload()
        elseif msg == "status" then
            GW.ShowStatusReport()
        elseif msg == "kb" then
            GW.HoverKeyBinds()
        elseif msg == "mh" then
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage(L["HUD_MOVE_ERR"])
                return
            end
            GW.moveHudObjects(GwSettingsWindowMoveHud)
        elseif msg == "reset profile" then
                GW.WarningPrompt(
                    GW.L["PROFILES_DEFAULT_SETTINGS_PROMPT"],
                    function()
                        GW.ResetToDefault()
                        C_UI.Reload()
                    end
                )
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r \"" .. msg .. "\" is not a valid GW2 UI slash command.")
        end
    end
end
GW.LoadSlashCommands = LoadSlashCommands