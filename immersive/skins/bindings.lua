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
        SkinButton(KeyBindingFrame[v], false, true)
    end

    KeyBindingFrame.Header.CenterBG:Hide()
    KeyBindingFrame.Header.RightBG:Hide()
    KeyBindingFrame.Header.LeftBG:Hide()
    KeyBindingFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    KeyBindingFrame.BG:Hide()
    local tex = KeyBindingFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", KeyBindingFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = KeyBindingFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    KeyBindingFrame.tex = tex

    _G.KeyBindingFrameCategoryList:SetBackdrop(constBackdropFrameBorder)
    KeyBindingFrame.bindingsContainer:SetBackdrop(constBackdropFrameBorder)

    SkinCheckButton(KeyBindingFrame.characterSpecificButton)
    KeyBindingFrame.characterSpecificButton:SetSize(15, 15)

    SkinScrollFrame(_G.KeyBindingFrameScrollFrame)
    SkinScrollBar(_G.KeyBindingFrameScrollFrameScrollBar)

    hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(binding, button)
        SkinButton(button, false, true)
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