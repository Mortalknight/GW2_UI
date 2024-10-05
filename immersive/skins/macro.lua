local _, GW = ...

local function ApplyMacroOptionsSkin()
    if not GW.settings.MACRO_SKIN_ENABLED then return end

    local macroHeaderText

    local r = {MacroFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            macroHeaderText = c
            break
        end
    end

    MacroFrameInset:GwStripTextures()
    MacroFrame.MacroSelector.ScrollBox:GwStripTextures()
    GW.CreateFrameHeaderWithBody(MacroFrame, macroHeaderText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon", {MacroFrameInset, MacroFrame.MacroSelector.ScrollBox}, nil, false, true)
    MacroFrame.gwHeader.BGLEFT:ClearAllPoints()
    MacroFrame.gwHeader.BGLEFT:SetPoint("BOTTOMLEFT", MacroFrame.gwHeader, "BOTTOMLEFT", 0, 0)
    MacroFrame.gwHeader.BGLEFT:SetPoint("TOPRIGHT", MacroFrame.gwHeader, "TOPRIGHT", 0, 0)
    MacroFrame.gwHeader.BGRIGHT:ClearAllPoints()
    MacroFrame.gwHeader.BGRIGHT:SetPoint("BOTTOMRIGHT", MacroFrame.gwHeader, "BOTTOMRIGHT", 0, 0)
    MacroFrame.gwHeader.BGRIGHT:SetPoint("TOPLEFT", MacroFrame.gwHeader, "TOPLEFT", 0, 0)
    macroHeaderText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)
    MacroFrameBg:Hide()

    MacroFrame.NineSlice:Hide()
    MacroFrame.TopTileStreaks:Hide()
    MacroFrame:GwCreateBackdrop()

    MacroFrameInset.NineSlice:Hide()
    MacroHorizontalBarLeft:Hide()

    if not MacroFrameTextBackground.NineSlice.SetBackdrop then
        Mixin(MacroFrameTextBackground.NineSlice, BackdropTemplateMixin)
        MacroFrameTextBackground.NineSlice:HookScript("OnSizeChanged", MacroFrameTextBackground.NineSlice.OnBackdropSizeChanged)
    end

    MacroFrameTextBackground.NineSlice:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    MacroFrameTextBackground.NineSlice:SetBackdropBorderColor(0, 0, 0)

    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    GW.HandleTrimScrollBar(MacroFrame.MacroSelector.ScrollBar, true)
    GW.HandleScrollControls(MacroFrame.MacroSelector)
    GW.HandleTrimScrollBar(MacroFrameScrollFrame.ScrollBar, true)
    GW.HandleScrollControls(MacroFrameScrollFrame)


    local buttons = {
        MacroSaveButton,
        MacroCancelButton,
        MacroDeleteButton,
        MacroNewButton,
        MacroExitButton,
        MacroEditButton
    }

    for i = 1, #buttons do
        buttons[i]:GwSkinButton(false, true)
    end
    MacroNewButton:SetPoint("BOTTOMRIGHT", -86, 4)

    MacroFrameCloseButton:GwSkinButton(true)
    MacroFrameCloseButton:SetSize(25, 25)
    MacroFrameCloseButton:ClearAllPoints()
    MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
    GW.HandleTabs(MacroFrameTab1, true)
    GW.HandleTabs(MacroFrameTab2, true)
    MacroFrameTab1:SetHeight(25)
    MacroFrameTab2:SetHeight(25)

    MacroFrameTab1:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 4, -35)
    MacroFrameTab2:SetPoint("LEFT", MacroFrameTab1, "RIGHT", 0, 0)
    MacroFrameTab1.Text:SetAllPoints(MacroFrameTab1)
    MacroFrameTab2.Text:SetAllPoints(MacroFrameTab2)

    MacroFrameSelectedMacroButton:GwStripTextures()
    MacroFrameSelectedMacroButton:GwStyleButton()
    MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
    MacroFrameSelectedMacroButton.Icon:GwSetInside()
    MacroFrameSelectedMacroButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    MacroFrameSelectedMacroBackground:GwKill()
    MacroFrameSelectedMacroButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")

    MacroFrameSelectedMacroName:SetTextColor(1, 1, 1)

    hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", function()
        for _, button in next, {MacroFrame.MacroSelector.ScrollBox.ScrollTarget:GetChildren()} do
            if button.Icon and not button.isSkinned then
                GW.HandleItemButton(button, true)
            end
        end
    end)

    MacroPopupFrame:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 10, 0)

        if not self.isSkinned then
            GW.HandleIconSelectionFrame(self)
        end
    end)
end

local function LoadMacroOptionsSkin()
    GW.RegisterLoadHook(ApplyMacroOptionsSkin, "Blizzard_MacroUI", MacroFrame)
end
GW.LoadMacroOptionsSkin = LoadMacroOptionsSkin
