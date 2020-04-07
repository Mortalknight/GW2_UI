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
    _G.KeyBindingFrameCategoryListTopRight:Hide()
    _G.KeyBindingFrameCategoryListTopLeft:Hide()
    _G.KeyBindingFrameCategoryListBottomRight:Hide()
    _G.KeyBindingFrameCategoryListBottomLeft:Hide()
    _G.KeyBindingFrameCategoryListLeft:Hide()
    _G.KeyBindingFrameCategoryListRight:Hide()
    _G.KeyBindingFrameCategoryListBottom:Hide()
    _G.KeyBindingFrameCategoryListTop:Hide()

    KeyBindingFrameBg:Hide()
    local tex = KeyBindingFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", KeyBindingFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = KeyBindingFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    KeyBindingFrame.tex = tex

    KeyBindingFrame.bottomSeparator:Hide()

    _G.KeyBindingFrameCategoryList:SetBackdrop(constBackdropFrameBorder)
    KeyBindingFrame.bindingsContainer:SetBackdrop(constBackdropFrameBorder)

    SkinCheckButton(KeyBindingFrame.characterSpecificButton)
    KeyBindingFrame.characterSpecificButton:SetSize(15, 15)

    SkinScrollFrame(_G.KeyBindingFrameScrollFrame)
    SkinScrollBar(_G.KeyBindingFrameScrollFrameScrollBar)
end
GW.SkinBindingsUI = SkinBindingsUI