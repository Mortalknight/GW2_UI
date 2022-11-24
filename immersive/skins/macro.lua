local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local constBackdropFrame = GW.skins.constBackdropFrame

local function ApplyMacroOptionsSkin()
    if not GW.GetSetting("MACRO_SKIN_ENABLED") then return end

    MacroFrameBg:Hide()
    MacroFrame.NineSlice:Hide()
    MacroFrame.TopTileStreaks:Hide()
    MacroFrame:CreateBackdrop()

    MacroFrameInset.NineSlice:Hide()
    MacroFrameInset:CreateBackdrop(constBackdropFrameBorder)
    MacroHorizontalBarLeft:Hide()
    MacroFrameTextBackground:StripTextures()
    MacroFrameTextBackground:CreateBackdrop(constBackdropFrame)

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