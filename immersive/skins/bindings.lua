local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function ApplyBindingsUISkin()
    local buttons = {
        "defaultsButton",
        "unbindButton",
        "okayButton",
        "cancelButton",
    }

    local KeyBindingFrame = _G.KeyBindingFrame
    for _, v in pairs(buttons) do
        KeyBindingFrame[v]:GwSkinButton(false, true)
    end
    _G.KeyBindingFrameBottomBorder:Hide()
    _G.KeyBindingFrameTopBorder:Hide()
    _G.KeyBindingFrameLeftBorder:Hide()
    _G.KeyBindingFrameRightBorder:Hide()
    _G.KeyBindingFrameTopLeftCorner:Hide()
    _G.KeyBindingFrameBottomLeftCorner:Hide()
    _G.KeyBindingFrameTopRightCorner:Hide()
    _G.KeyBindingFrameBottomRightCorner:Hide()
    KeyBindingFrameRockBg:Hide()
    KeyBindingFrame.header.text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    _G.KeyBindingFrame:SetBackdrop(nil)

    KeyBindingFrameCategoryList:GwStripTextures()
    KeyBindingFrameCategoryList:GwCreateBackdrop(constBackdropFrameBorder, true)

    KeyBindingFrame.bindingsContainer:GwStripTextures()
    KeyBindingFrame.bindingsContainer:GwCreateBackdrop(constBackdropFrameBorder, true)

    GW.CreateFrameHeaderWithBody(KeyBindingFrame, KeyBindingFrame.header.text, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon", {KeyBindingFrameCategoryList, KeyBindingFrame.bindingsContainer})

    KeyBindingFrame.bottomSeparator:Hide()

    KeyBindingFrame.characterSpecificButton:GwSkinCheckButton()
    KeyBindingFrame.characterSpecificButton:SetSize(15, 15)
    KeyBindingFrame.characterSpecificButton:ClearAllPoints()
    KeyBindingFrame.characterSpecificButton:SetPoint("TOPLEFT", KeyBindingFrame, "TOPRIGHT", -245, -10)

    KeyBindingFrameScrollFrame:GwSkinScrollFrame()
    KeyBindingFrameScrollFrameScrollBar:GwSkinScrollBar()

    hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(binding, button)
        button:GwSkinButton(false, true)
    end)

    hooksecurefunc("BindingButtonTemplate_SetSelected", function(keyBindingButton, isSelected)
        keyBindingButton.selectedHighlight:SetAlpha(0)
        if isSelected then
            keyBindingButton:SetScript("OnEnter", nil)
            keyBindingButton:SetScript("OnLeave", nil)
        else
            keyBindingButton:SetScript("OnEnter", GwStandardButton_OnEnter)
            keyBindingButton:SetScript("OnLeave", GwStandardButton_OnLeave)
            GwStandardButton_OnLeave(keyBindingButton)
        end
    end)
end

local function LoadBindingsUISkin()
    if not GW.GetSetting("BINDINGS_SKIN_ENABLED") then return end

    GW.RegisterLoadHook(ApplyBindingsUISkin, "Blizzard_BindingUI", KeyBindingFrame)
end
GW.LoadBindingsUISkin = LoadBindingsUISkin