local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
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
    GW.CreateFrameHeaderWithBody(MacroFrame, macroHeaderText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon", {MacroFrameInset})

    MacroFrameBg:Hide()

    MacroFrame.NineSlice:Hide()
    MacroFrame.TopTileStreaks:Hide()
    MacroFrame:GwCreateBackdrop()

    MacroFrameInset.NineSlice:Hide()
    MacroHorizontalBarLeft:Hide()
    MacroFrameTextBackground:GwStripTextures()
    MacroFrameTextBackground:GwCreateBackdrop(constBackdropFrame)

    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    GW.HandleTrimScrollBar(MacroFrame.MacroSelector.ScrollBar)
    GW.HandleAchivementsScrollControls(MacroFrame.MacroSelector)
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
            GW.HandleIconSelectionFrame(self, nil, nil, "MacroPopup")
        end
    end)
end

local function LoadMacroOptionsSkin()
    GW.RegisterLoadHook(ApplyMacroOptionsSkin, "Blizzard_MacroUI", MacroFrame)
end
GW.LoadMacroOptionsSkin = LoadMacroOptionsSkin
