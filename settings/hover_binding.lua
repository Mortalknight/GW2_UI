local _, GW = ...

local isInit = false
local opendFromGW2

local function DisplayHoverBinding()
    if not isInit then
        -- Init the function
        -- Track if we opened the QuickKeybindFram from our Button, if so we need to close the KeyBindingFrame and GameMenuFrame after close
        QuickKeybindFrame:HookScript("OnHide", function()
            print(opendFromGW2)
            if opendFromGW2 then
                opendFromGW2 = false

                if SettingsPanel:IsShown() then
                    HideUIPanel(SettingsPanel)
                end
                C_Timer.After(0.001, function()
                    if GameMenuFrame:IsShown() then
                        HideUIPanel(GameMenuFrame)
                    end
                end)
            end
        end)

        isInit = true
    end
    if not KeybindFrames_InQuickKeybindMode() then
        QuickKeybindFrame:Show()
        opendFromGW2 = true
    end
end
GW.DisplayHoverBinding = DisplayHoverBinding
