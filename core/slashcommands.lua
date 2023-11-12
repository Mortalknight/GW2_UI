local _, GW = ...
local L = GW.L

local function HandleSlashCommands(msg)
-- _G["SLASH_GWSLASH1"] = "/gw2"

    --SlashCmdList["GWSLASH"] = function(msg)
        --if msg == "" then
        if msg == "/gw2" then
            GW.Notice("Slash commands:")
            GW.Notice("  /gw2 settings       -> To open the settings window")
            GW.Notice("  /gw2 reset windows  -> To reset the inventory and hero panel windows")
            GW.Notice("  /gw2 status         -> To show GW2 Status window")
            GW.Notice("  /gw2 kb             -> To activate the keybindoptions")
            GW.Notice("  /gw2 mh             -> To activate 'Move HUD'-Mode")
            GW.Notice("  /gw2 reset profile  -> To reset the current profile to default settings")
        --elseif msg == "settings" then
        elseif msg == "/gw2 settings" then
            if InCombatLockdown() then
                GW.Notice(L["Settings are not available in combat!"])
                return
            end
            ShowUIPanel(GwSettingsWindow)
            --UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
        --elseif msg == "reset windows" then
        elseif msg == "/gw2 reset windows" then
            GW.SetSetting("BAG_POSITION", nil)
            GW.SetSetting("BANK_POSITION", nil)
            GW.SetSetting("HERO_POSITION", nil)
            GW.SetSetting("MAILBOX_POSITION", nil)
            C_UI.Reload()
        --elseif msg == "status" then
        elseif msg == "/gw2 status" then
            GW.ShowStatusReport()
        --elseif msg == "kb" then
        elseif msg == "/gw2 kb" then
            if InCombatLockdown() then
                GW.Notice(L["Settings are not available in combat!"])
                return
            end
            GW.DisplayHoverBinding()
        --elseif msg == "mh" then
        elseif msg == "/gw2 mh" then
            if InCombatLockdown() then
                GW.Notice(L["You can not move elements during combat!"])
                return
            end
            if GW.MoveHudScaleableFrame:IsShown() then
                GW.lockHudObjects(GW.MoveHudScaleableFrame)
            else
                GW.moveHudObjects(GW.MoveHudScaleableFrame)
            end
        --elseif msg == "reset profile" then
        elseif msg == "/gw2 reset profile" then
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
        --elseif msg == "error" then
        elseif msg == "/gw2 error" then
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
    --end
end

-- Work-around for Blizzard's issue where slash commands are allowing taint to spread
local lastMessage

local function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local function LoadSlashCommands()
    hooksecurefunc("ChatEdit_ParseText", function(editBox, send, parseIfNoSpaces)
        if send == 0 then
            lastMessage = editBox:GetText()
        end
    end)

    hooksecurefunc("ChatFrame_DisplayHelpTextSimple", function(frame)
        if (lastMessage and lastMessage ~= "") then
            local cmd = string.lower(lastMessage)
            if (starts(cmd, "/gw2")) then
                local count = 1
                local numMessages = frame:GetNumMessages()
                local function predicateFunction(entry)
                    if (count == numMessages) then
                        if (entry == HELP_TEXT_SIMPLE) then
                            return true
                        end
                    end
                    count = count + 1
                end
                frame:RemoveMessagesByPredicate(predicateFunction)
                HandleSlashCommands(cmd)
            end
        end
    end)
end
GW.LoadSlashCommands = LoadSlashCommands
