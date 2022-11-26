local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function ApplyMacroOptionsSkin()
    if not GW.GetSetting("MACRO_SKIN_ENABLED") then return end

    local macroHeaderText

    local r = {MacroFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            macroHeaderText = c
            break
        end
    end
    GW.CreateFrameHeaderWithBody(MacroFrame, macroHeaderText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon", {MacroFrameInset})

    MacroFrameBg:Hide()

    MacroFrame.NineSlice:Hide()
    MacroFrame.TopTileStreaks:Hide()
    MacroFrame:CreateBackdrop()

    MacroFrameInset.NineSlice:Hide()
    MacroHorizontalBarLeft:Hide()
    MacroFrameTextBackground:StripTextures()
    MacroFrameTextBackground:CreateBackdrop(constBackdropFrame)

    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    GW.HandleTrimScrollBar(MacroFrame.MacroSelector.ScrollBar)
    MacroFrameScrollFrameScrollBar:SkinScrollBar()

    local buttons = {
        MacroSaveButton,
        MacroCancelButton,
        MacroDeleteButton,
        MacroNewButton,
        MacroExitButton,
        MacroEditButton
    }

    for i = 1, #buttons do
        buttons[i]:SkinButton(false, true)
    end

    MacroFrameCloseButton:SkinButton(true)
    MacroFrameCloseButton:SetSize(25, 25)
    MacroFrameCloseButton:ClearAllPoints()
    MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
    MacroFrameTab1:SkinTab()
    MacroFrameTab2:SkinTab()

    MacroFrameSelectedMacroButton:StripTextures()
    MacroFrameSelectedMacroButton:StyleButton()
    MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
    MacroFrameSelectedMacroButton.Icon:SetInside()
    MacroFrameSelectedMacroButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    MacroFrameSelectedMacroBackground:Kill()
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
    end)

    MacroPopupFrame:HookScript("OnShow", function(frame)
        if not frame.isSkinned then
            GW.HandleIconSelectionFrame(frame, nil, nil, "MacroPopup")
        end
    end)
end

local function LoadMacroOptionsSkin()
    GW.RegisterLoadHook(ApplyMacroOptionsSkin, "Blizzard_MacroUI", MacroFrame)
end
GW.LoadMacroOptionsSkin = LoadMacroOptionsSkin