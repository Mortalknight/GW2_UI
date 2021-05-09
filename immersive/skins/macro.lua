local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinMacroOptions()
    MacroFrame_LoadUI()

    local MacroFrame = _G.MacroFrame

    _G.MacroFrameBg:Hide()
    MacroFrame.TitleBg:Hide()
    MacroFrame.TopTileStreaks:Hide()

    _G.MacroFrameInsetInsetTopBorder:Hide()
    _G.MacroFrameInsetInsetBottomBorder:Hide()
    _G.MacroFrameInsetInsetLeftBorder:Hide()
    _G.MacroFrameInsetInsetRightBorder:Hide()
    _G.MacroFrameInsetInsetTopLeftCorner:Hide()
    _G.MacroFrameInsetInsetTopRightCorner:Hide()
    _G.MacroFrameInsetInsetBotRightCorner:Hide()
    _G.MacroFrameInsetInsetBotLeftCorner:Hide()

    _G.MacroFrameInset:CreateBackdrop(constBackdropFrameBorder)
    _G.MacroHorizontalBarLeft:Hide()
    MacroFrameTextBackground:StripTextures() -- TODO
    _G.MacroFrameTextBackground:CreateBackdrop(constBackdropFrame)

    local r = {MacroFrame:GetRegions()}
    local i = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        elseif c:GetObjectType() == "FontString" then
            if i == 2 then c:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE") end
            i = i + 1
        end
    end

    local tex = MacroFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", MacroFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = MacroFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    MacroFrame.tex = tex

    _G.MacroButtonScrollFrameScrollBar:SkinScrollBar()
    _G.MacroFrameScrollFrameScrollBar:SkinScrollBar()
    _G.MacroButtonScrollFrame:SkinScrollFrame()

    local buttons = {
        _G.MacroSaveButton,
        _G.MacroCancelButton,
        _G.MacroDeleteButton,
        _G.MacroNewButton,
        _G.MacroExitButton,
        _G.MacroEditButton
    }

    for i = 1, #buttons do
        buttons[i]:SkinButton(false, true)
    end

    _G.MacroFrameCloseButton:SkinButton(true)
    _G.MacroFrameCloseButton:SetSize(25, 25)
    _G.MacroFrameCloseButton:ClearAllPoints()
    _G.MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
    _G.MacroFrameTab1:SkinTab()
    _G.MacroFrameTab2:SkinTab()

    local r = {_G.MacroFrameSelectedMacroButton:GetRegions()}
    local ii = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            if ii == 1 then
                c:Hide()
            end
            ii = ii + 1
        end
    end

    _G.MacroFrameSelectedMacroButton:DisableDrawLayer("BACKGROUND")
    _G.MacroFrameSelectedMacroButtonIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    _G.MacroFrameSelectedMacroButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
    hooksecurefunc("MacroFrame_ShowDetails", function() _G.MacroFrameSelectedMacroBackground:Hide() end)

    -- Skin all buttons
    for i = 1, _G.MAX_ACCOUNT_MACROS do
        local b = _G["MacroButton" .. i]
        local t = _G["MacroButton" .. i .. "Icon"]

        if b then
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
            b:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
            local r = {b:GetRegions()}
            local ii = 1
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:SetTexture("Interface/AddOns/GW2_UI/textures/spelliconempty")
                        c:SetSize(b:GetSize())
                    end
                    ii = ii + 1
                end
            end
        end

        if t then
            t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
    end

    --Icon selection frame
    ShowUIPanel(MacroFrame) --Toggle frame to create necessary variables needed for popup frame
    HideUIPanel(MacroFrame)
    local MacroPopupFrame = _G.MacroPopupFrame
    MacroPopupFrame:Show() --Toggle the frame in order to create the necessary button elements
    MacroPopupFrame:Hide()

    -- Popout Frame
    MacroPopupFrame.BorderBox.OkayButton:SkinButton(false, true)
    MacroPopupFrame.BorderBox.CancelButton:SkinButton(false, true)
    _G.MacroPopupScrollFrameScrollBar:SkinScrollBar()
    _G.MacroPopupScrollFrame:SkinScrollFrame()
    _G.MacroPopupNameLeft:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    _G.MacroPopupNameMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    _G.MacroPopupNameRight:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")

    local r = {MacroPopupFrame.BorderBox:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end
    MacroPopupFrame.BG:Hide()

    MacroPopupFrame:SetSize(MacroPopupFrame:GetSize(), MacroPopupFrame:GetSize() + 5)
    MacroPopupFrame:CreateBackdrop(constBackdropFrame)

    for i = 1, _G.NUM_MACRO_ICONS_SHOWN do
        local button = _G["MacroPopupButton" .. i]
        if button then
            button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
            button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
            local r = {button:GetRegions()}
            local ii = 1
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:SetTexture("Interface/AddOns/GW2_UI/textures/spelliconempty")
                        c:SetSize(button:GetSize())
                    end
                    ii = ii + 1
                end
            end

            local icon = _G["MacroPopupButton" .. i .. "Icon"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end

    MacroPopupFrame:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 10, 0)
    end)
end
GW.SkinMacroOptions = SkinMacroOptions