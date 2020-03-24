local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local SkinButton = GW.skins.SkinButton
local SkinCheckButton = GW.skins.SkinCheckButton

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
    
    KeyBindingFrame.scrollFrame.scrollBorderTop:Hide()
    KeyBindingFrame.scrollFrame.scrollBorderBottom:Hide()
    KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
    KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetSize(3, KeyBindingFrame.scrollFrame.scrollBorderMiddle:GetSize())
    KeyBindingFrame.scrollFrame.scrollBorderMiddle:ClearAllPoints()
    KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetPoint("TOPLEFT", KeyBindingFrame.scrollFrame, "TOPRIGHT", 12, -10)
    KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetPoint("BOTTOMLEFT", KeyBindingFrame.scrollFrame,"BOTTOMRIGHT", 12, 10)
    KeyBindingFrame.scrollFrame.scrollFrameScrollBarBackground:Hide()

    KeyBindingFrameScrollFrameScrollBarThumbTexture:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbarmiddle")
    KeyBindingFrameScrollFrameScrollBarThumbTexture:SetSize(12, KeyBindingFrameScrollFrameScrollBarThumbTexture:GetSize())
    KeyBindingFrameScrollFrameScrollBarScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    KeyBindingFrameScrollFrameScrollBarScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    KeyBindingFrameScrollFrameScrollBarScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    KeyBindingFrameScrollFrameScrollBarScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    KeyBindingFrameScrollFrameScrollBarScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    KeyBindingFrameScrollFrameScrollBarScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    KeyBindingFrameScrollFrameScrollBarScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    KeyBindingFrameScrollFrameScrollBarScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
end
GW.SkinBindingsUI = SkinBindingsUI