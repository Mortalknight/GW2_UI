local _, GW = ...

local isInit = false
local opendFromGW2

local function IsQiuckKeybindFrameOpen()
    if _G.QuickKeybindFrame then
        return _G.QuickKeybindFrame:IsShown()
    else
        return false
    end
end

local function DisplayHoverBinding()
    if not isInit then
        -- Init the function
        -- Track if we opened the QuickKeybindFram from our Button, if so we need to close the KeyBindingFrame and GameMenuFrame after close
        QuickKeybindFrame:HookScript("OnHide", function()
            if opendFromGW2 then
                opendFromGW2 = false

                if KeyBindingFrame:IsShown() then
                    HideUIPanel(KeyBindingFrame)
                end
                C_Timer.After(0.01, function()
                    if GameMenuFrame:IsShown() then
                        HideUIPanel(GameMenuFrame)
                    end
                end)
            end 
        end)

        isInit = true
    end
    if not IsQiuckKeybindFrameOpen() then
        if not IsAddOnLoaded("Blizzard_BindingUI") then
            KeyBindingFrame_LoadUI()
        end

        ShowUIPanel(_G.KeyBindingFrame)
        _G.KeyBindingFrame.quickKeybindButton:Click()
        opendFromGW2 = true
    end
end
GW.DisplayHoverBinding = DisplayHoverBinding
