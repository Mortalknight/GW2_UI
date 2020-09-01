local _, GW = ...

local function IsQiuckKeybindFrameOpen()
    if _G.QuickKeybindFrame then
        return _G.QuickKeybindFrame:IsShown()
    else
        return false
    end
end

local function DisplayHoverBinding()
    if not IsQiuckKeybindFrameOpen() then
        if not IsAddOnLoaded("Blizzard_BindingUI") then
            KeyBindingFrame_LoadUI()
        end

        ShowUIPanel(_G.KeyBindingFrame)
        _G.KeyBindingFrame.quickKeybindButton:Click()
    end
end
GW.DisplayHoverBinding = DisplayHoverBinding
