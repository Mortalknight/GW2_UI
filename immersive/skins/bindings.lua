local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local SkinButton = GW.skins.SkinButton
local SkinCheckButton = GW.skins.SkinCheckButton
local SkinScrollBar = GW.skins.SkinScrollBar
local SkinScrollFrame = GW.skins.SkinScrollFrame

local function SkinBindingsUI()
    KeyBindingFrame_LoadUI()

    local buttons = {
        "defaultsButton",
        "unbindButton",
        "okayButton",
        "cancelButton",
    }

    local KeyBindingFrame = _G.KeyBindingFrame
    for _, v in pairs(buttons) do
        KeyBindingFrame[v]:SkinButton(false, true)
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

    KeyBindingFrameBg:Hide()
    local tex = KeyBindingFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", KeyBindingFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = KeyBindingFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    KeyBindingFrame.tex = tex

    KeyBindingFrame.bottomSeparator:Hide()

    KeyBindingFrameCategoryList:StripTextures()
    KeyBindingFrameCategoryList:CreateBackdrop(constBackdropFrameBorder)
    KeyBindingFrame.bindingsContainer:StripTextures()
    KeyBindingFrame.bindingsContainer:CreateBackdrop(constBackdropFrameBorder)

    KeyBindingFrame.characterSpecificButton:SkinCheckButton()
    KeyBindingFrame.characterSpecificButton:SetSize(15, 15)

    _G.KeyBindingFrameScrollFrame:SkinScrollFrame()
    _G.KeyBindingFrameScrollFrameScrollBar:SkinScrollBar()

    hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(binding, button)
        button:SkinButton(false, true)
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
GW.SkinBindingsUI = SkinBindingsUI