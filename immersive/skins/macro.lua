local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function ApplyMacroOptionsSkin()
    if not GW.GetSetting("MACRO_SKIN_ENABLED") then return end
    local macroHeaderText

    local r = {MacroFrame:GetRegions()}
    local i = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        elseif c:GetObjectType() == "FontString" then
            if i == 2 then macroHeaderText = c end
            i = i + 1
        end
    end

    GW.CreateFrameHeaderWithBody(MacroFrame, macroHeaderText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon", {MacroFrameInset})

    MacroFrameBg:Hide()

    MacroFrameBg:Hide()
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

    MacroFrame:GwCreateBackdrop()

    MacroHorizontalBarLeft:Hide()
    MacroFrameTextBackground:GwStripTextures()
    MacroFrameTextBackground:GwCreateBackdrop(constBackdropFrame)

    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    MacroFrame.MacroSelector.ScrollBox:GwStripTextures()
    MacroFrame.MacroSelector.ScrollBox:GwCreateBackdrop(constBackdropFrame)
    GW.HandleTrimScrollBar(MacroFrame.MacroSelector.ScrollBar)
    _G.MacroFrameScrollFrameScrollBar:GwSkinScrollBar()

    local buttons = {
        _G.MacroSaveButton,
        _G.MacroCancelButton,
        _G.MacroDeleteButton,
        _G.MacroNewButton,
        _G.MacroExitButton,
        _G.MacroEditButton
    }

    for i = 1, #buttons do
        buttons[i]:GwSkinButton(false, true)
    end

    _G.MacroFrameCloseButton:GwSkinButton(true)
    _G.MacroFrameCloseButton:SetSize(25, 25)
    _G.MacroFrameCloseButton:ClearAllPoints()
    _G.MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
    _G.MacroFrameTab1:GwSkinTab()
    _G.MacroFrameTab2:GwSkinTab()

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

    MacroFrameSelectedMacroButton:GwStripTextures()
    MacroFrameSelectedMacroButton:GwStyleButton()
    MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
    MacroFrameSelectedMacroButton.Icon:GwSetInside()
    MacroFrameSelectedMacroButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    MacroFrameSelectedMacroBackground:GwKill()
    MacroFrameSelectedMacroButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")

    hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", function()
        for _, button in next, { MacroFrame.MacroSelector.ScrollBox.ScrollTarget:GetChildren() } do
            if button.Icon and not button.isSkinned then
                GW.HandleItemButton(button, true)
            end
        end
    end)

    -- Skin all buttons
    for i = 1, _G.MAX_ACCOUNT_MACROS do
        local b = _G["MacroButton" .. i]
        local t = _G["MacroButton" .. i .. "Icon"]

        if b then
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
            b:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
            local r = {b:GetRegions()}
            local ii = 1
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty")
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
    MacroPopupFrame.BorderBox.OkayButton:GwSkinButton(false, true)
    MacroPopupFrame.BorderBox.CancelButton:GwSkinButton(false, true)

    GW.HandleTrimScrollBar(MacroPopupFrame.IconSelector.ScrollBar)
    GW.SkinTextBox(MacroPopupFrame.BorderBox.IconSelectorEditBox.IconSelectorPopupNameMiddle, MacroPopupFrame.BorderBox.IconSelectorEditBox.IconSelectorPopupNameLeft, MacroPopupFrame.BorderBox.IconSelectorEditBox.IconSelectorPopupNameRight, nil, nil, 4, 4)

    local r = {MacroPopupFrame.BorderBox:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end
    MacroPopupFrame.BG:Hide()

    MacroPopupFrame:SetSize(MacroPopupFrame:GetSize(), MacroPopupFrame:GetSize() + 5)
    MacroPopupFrame:GwCreateBackdrop(constBackdropFrame)


    MacroPopupFrame.BorderBox:GwStripTextures()
    local button = MacroPopupFrame.BorderBox.SelectedIconArea and MacroPopupFrame.BorderBox.SelectedIconArea.SelectedIconButton
    if button then
        button:DisableDrawLayer("BACKGROUND")
        GW.HandleItemButton(button, true)
    end

    MacroPopupFrame:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 10, 0)

        for _, button in next, { MacroPopupFrame.IconSelector.ScrollBox.ScrollTarget:GetChildren() } do
            local icon, texture = button.Icon, nil
            button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                icon:GwSetInside(button)
                texture = icon:GetTexture()
            end

            button:GwStripTextures()
            button:GwCreateBackdrop()
            button:GwStyleButton(nil, true)

            if texture then
                icon:SetTexture(texture)
            end
        end
    end)
end

local function LoadMacroOptionsSkin()
    GW.RegisterLoadHook(ApplyMacroOptionsSkin, "Blizzard_MacroUI", MacroFrame)
end
GW.LoadMacroOptionsSkin = LoadMacroOptionsSkin