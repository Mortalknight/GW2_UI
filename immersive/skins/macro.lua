local _, GW = ...
local GetSetting = GW.GetSetting

local function ApplyMacroOptionsSkin()
    if not GetSetting("MACRO_SKIN_ENABLED") then return end

    local macroHeaderText

    local r = {MacroFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            macroHeaderText = c
            break
        end
    end
    GW.CreateFrameHeaderWithBody(MacroFrame, macroHeaderText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon", {MacroFrameInset, MacroFrame.MacroSelector.ScrollBox})

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

    GW.HandleTrimScrollBar(MacroFrame.MacroSelector.ScrollBar)
    GW.HandleScrollControls(MacroFrame.MacroSelector)
    MacroFrameScrollFrameScrollBar:GwSkinScrollBar()

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

    MacroFrameCloseButton:GwSkinButton(true)
    MacroFrameCloseButton:SetSize(25, 25)
    MacroFrameCloseButton:ClearAllPoints()
    MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
    MacroFrameTab1:GwSkinTab()
    MacroFrameTab2:GwSkinTab()

    MacroFrameTab1:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 12, -30)
    MacroFrameTab2:SetPoint("LEFT", MacroFrameTab1, "RIGHT", 4, 0)
    MacroFrameTab1.Text:SetAllPoints(MacroFrameTab1)
    MacroFrameTab2.Text:SetAllPoints(MacroFrameTab2)

    MacroFrameSelectedMacroButton:GwStripTextures()
    MacroFrameSelectedMacroButton:GwStyleButton()
    MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
    MacroFrameSelectedMacroButton.Icon:GwSetInside()
    MacroFrameSelectedMacroButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    MacroFrameSelectedMacroBackground:GwKill()
    MacroFrameSelectedMacroButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")

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
            GW.HandleIconSelectionFrame(self, "MacroPopup")
        end
    end)
end

local function LoadMacroOptionsSkin()
    GW.RegisterLoadHook(ApplyMacroOptionsSkin, "Blizzard_MacroUI", MacroFrame)
end
GW.LoadMacroOptionsSkin = LoadMacroOptionsSkin
