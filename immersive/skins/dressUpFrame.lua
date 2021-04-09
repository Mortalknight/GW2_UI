local _, GW = ...

local function BG_Resize(self)
    local w, h = self:GetParent():GetParent():GetSize()
    self:GetParent():GetParent().tex:SetSize(w + 50, h + 30)
end

local function LoadDressUpFrameSkin()
    if not GW.GetSetting("INSPECTION_SKIN_ENABLED") then return end

    DressUpFrame:StripTextures()
    DressUpFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    DressUpFrameCloseButton:SkinButton(true)
    DressUpFrameCloseButton:SetSize(20, 20)
    DressUpFrameResetButton:SkinButton(false, true)
    DressUpFrameCancelButton:SkinButton(false, true)
    DressUpFrameOutfitDropDown:SkinDropDownMenu()
    DressUpFrameOutfitDropDown.backdrop:ClearAllPoints()
    DressUpFrameOutfitDropDown.backdrop:SetPoint("TOPLEFT", 0, 5)
    DressUpFrameOutfitDropDown.backdrop:SetPoint("BOTTOMRIGHT", DressUpFrameOutfitDropDownButton, "BOTTOMRIGHT", 2, -2)
    DressUpFrameOutfitDropDownText:ClearAllPoints()
    DressUpFrameOutfitDropDownText:SetPoint("RIGHT", DressUpFrameOutfitDropDownButton, "LEFT", 25, 0)
    DressUpFrameOutfitDropDown.SaveButton:SkinButton(false, true)
    DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -7, 3)
    DressUpFrame.MaximizeMinimizeFrame:HandleMaxMinFrame()

    local tex = DressUpFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    tex:SetPoint("TOP", DressUpFrame, "TOP", 0, 20)
    local w, h = DressUpFrame:GetSize()
    tex:SetSize(w + 50, h + 30)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    DressUpFrame.tex = tex

    DressUpFrame.ModelBackground:SetDrawLayer("BACKGROUND", 2)

    DressUpFrame.MaximizeMinimizeFrame.MaximizeButton:HookScript("OnClick", BG_Resize)
    
    DressUpFrame.MaximizeMinimizeFrame.MinimizeButton:HookScript("OnClick", BG_Resize)

    DressUpFrame:HookScript("OnShow", function()
        BG_Resize(DressUpFrame.MaximizeMinimizeFrame.MaximizeButton)
    end)

    -- Wardrobe edit frame
    WardrobeOutfitFrame:StripTextures(true)
    WardrobeOutfitFrame:CreateBackdrop(GW.skins.constBackdropFrame)

    WardrobeOutfitEditFrame:StripTextures(true)
    WardrobeOutfitEditFrame:CreateBackdrop(GW.skins.constBackdropFrame)
    WardrobeOutfitEditFrame.EditBox:StripTextures()
    GW.SkinTextBox(WardrobeOutfitEditFrame.EditBox.MiddleTexture, WardrobeOutfitEditFrame.EditBox.LeftTexture, WardrobeOutfitEditFrame.EditBox.RightTexture)
    WardrobeOutfitEditFrame.AcceptButton:SkinButton(false, true)
    WardrobeOutfitEditFrame.CancelButton:SkinButton(false, true)
    WardrobeOutfitEditFrame.DeleteButton:SkinButton(false, true)
end
GW.LoadDressUpFrameSkin = LoadDressUpFrameSkin
