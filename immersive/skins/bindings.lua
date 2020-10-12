local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function SkinBindingsUI()
    KeyBindingFrame_LoadUI()

    local buttons = {
        "defaultsButton",
        "unbindButton",
        "okayButton",
        "cancelButton",
        "quickKeybindButton"
    }

    local KeyBindingFrame = _G.KeyBindingFrame
    for _, v in pairs(buttons) do
        KeyBindingFrame[v]:SkinButton(false, true)
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

    _G.KeyBindingFrameCategoryList:StripTextures()
    _G.KeyBindingFrameCategoryList:CreateBackdrop(constBackdropFrameBorder)
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

    -- QuickKeybind
    _G.QuickKeybindFrame:StripTextures()
    _G.QuickKeybindFrame.Header:StripTextures()
    _G.QuickKeybindFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    _G.QuickKeybindFrame.characterSpecificButton:SkinCheckButton()
    _G.QuickKeybindFrame.characterSpecificButton:SetSize(13, 13)

    local tex = _G.QuickKeybindFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", _G.QuickKeybindFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = _G.QuickKeybindFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    _G.QuickKeybindFrame.tex = tex

    local buttons = {"okayButton", "defaultsButton", "cancelButton"}
    for _, v in pairs(buttons) do
        _G.QuickKeybindFrame[v]:SkinButton(false, true)
    end

    QuickKeybindFrame:HookScript("OnShow", function()
        _G.MultiBarRight.QuickKeybindGlow:Hide()
        _G.MultiBarLeft.QuickKeybindGlow:Hide()
        _G.MultiBarBottomRight.QuickKeybindGlow:Hide()
        _G.MultiBarBottomLeft.QuickKeybindGlow:Hide()
    end)

    -- make the frame movable (maybe someone have a actionbar behinde that frame)
    QuickKeybindFrame:SetClampedToScreen(true)
    QuickKeybindFrame.Header:EnableMouse(true)
    QuickKeybindFrame.Header:RegisterForDrag("LeftButton")

    QuickKeybindFrame.Header:SetScript(
        'OnDragStart',
        function(self)
            self.moving = true
            self:GetParent():StartMoving()
        end
    )

    QuickKeybindFrame.Header:SetScript(
        'OnDragStop',
        function(self)
            self.moving = nil
            self:GetParent():StopMovingOrSizing()
        end
    )

end
GW.SkinBindingsUI = SkinBindingsUI