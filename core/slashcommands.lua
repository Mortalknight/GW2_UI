local _, GW = ...
local L = GW.L

local function LoadSlashCommands()
    SLASH_GWSLASH1 = "/gw2"
    function SlashCmdList.GWSLASH(msg)
        if msg == "" then
            GW.Notice("Slash commands:")
            GW.Notice("  /gw2 settings       -> To open the settings window")
            GW.Notice("  /gw2 reset windows  -> To reset the inventory and hero panel windows")
            GW.Notice("  /gw2 status         -> To show GW2 Status window")
            GW.Notice("  /gw2 kb             -> To activate the keybindoptions")
            GW.Notice("  /gw2 mh             -> To activate 'Move HUD'-Mode")
            GW.Notice("  /gw2 reset profile  -> To reset the current profile to default settings")
        elseif msg == "settings" then
            if InCombatLockdown() then
                GW.Notice(L["Settings are not available in combat!"])
                return
            end
            ShowUIPanel(GwSettingsWindow)
            --UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
        elseif msg == "reset windows" then
            GW.settings.BAG_POSITION = nil
            GW.settings.BANK_POSITION = nil
            GW.settings.HERO_POSITION = nil
            GW.settings.MAILBOX_POSITION = nil
            C_UI.Reload()
        elseif msg == "status" then
            GW.ShowStatusReport()
        elseif msg == "kb" then
            if InCombatLockdown() then
                GW.Notice(L["Settings are not available in combat!"])
                return
            end
            GW.DisplayHoverBinding()
        elseif msg == "mh" then
            if InCombatLockdown() then
                GW.Notice(L["You can not move elements during combat!"])
                return
            end
            if GW.MoveHudScaleableFrame:IsShown() then
                GW.lockHudObjects(GW.MoveHudScaleableFrame)
            else
                GW.moveHudObjects(GW.MoveHudScaleableFrame)
            end
        elseif msg == "reset profile" then
            if InCombatLockdown() then
                GW.Notice(L["Settings are not available in combat!"])
                return
            end
            GW.WarningPrompt(
                GW.L["Are you sure you want to load the default settings?\n\nAll previous settings will be lost."],
                function()
                    GW.ResetToDefault()
                    C_UI.Reload()
                end
            )
        elseif msg == "error" then
            local txt = ("Version: %s Date: %s Locale: %s Build %s %s"):format(GW.VERSION_STRING or "?", date("%m/%d/%y %H:%M:%S") or "?", GW.mylocal or "?", GW.wowpatch, GW.wowbuild)
            txt = txt .. "\n" .. GW.Join("\n", GW.ErrorHandler.log)

            local errorlogFrame = GW.CreateErrorLogWindow ()
            errorlogFrame.editBox:SetText(txt)
            errorlogFrame.editBox:HighlightText()
            errorlogFrame.editBox:SetFocus()

            errorlogFrame:Show()
        else
            GW.Notice("\"" .. msg .. "\" is not a valid GW2 UI slash command.")
        end
    end
end
GW.LoadSlashCommands = LoadSlashCommands
