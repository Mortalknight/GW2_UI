local _, GW = ...
local L = GW.L

local function LoadSlashCommands()
    _G["SLASH_GWSLASH1"] = "/gw2"

    SlashCmdList["GWSLASH"] = function(msg)
        if msg == "" then
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r Slash commands:"):gsub("*", GW.Gw2Color))
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r   /gw2 settings       -> To open the settings window"):gsub("*", GW.Gw2Color))
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r   /gw2 reset windows  -> To reset the inventory and hero panel windows"):gsub("*", GW.Gw2Color))
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r   /gw2 status         -> To show GW2 Status window"):gsub("*", GW.Gw2Color))
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r   /gw2 kb             -> To activate the keybindoptions"):gsub("*", GW.Gw2Color))
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r   /gw2 mh             -> To activate 'Move HUD'-Mode"):gsub("*", GW.Gw2Color))
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r   /gw2 reset profile  -> To reset the current profile to default settings"):gsub("*", GW.Gw2Color))
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
            GW.DisplayHoverBinding()
        elseif msg == "mh" then
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
                return
            end
            if GW.MoveHudScaleableFrame:IsShown() then
                GW.lockHudObjects(GW.MoveHudScaleableFrame)
            else
                GW.moveHudObjects(GW.MoveHudScaleableFrame)
            end
        elseif msg == "reset profile" then
                GW.WarningPrompt(
                    GW.L["Are you sure you want to load the default settings?\n\nAll previous settings will be lost."],
                    function()
                        GW.ResetToDefault()
                        C_UI.Reload()
                    end
                )
        else
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r \"" .. msg .. "\" is not a valid GW2 UI slash command."):gsub("*", GW.Gw2Color))
        end
    end
end
GW.LoadSlashCommands = LoadSlashCommands