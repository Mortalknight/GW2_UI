local _, GW = ...
local GetSetting = GW.GetSetting

local function BG_Resize(self)
    local w, h = self:GetParent():GetParent():GetSize()
    self:GetParent():GetParent().tex:SetSize(w + 50, h + 30)
end

local function SetItemQuality(slot)
    if not slot.slotState and not slot.isHiddenVisual and slot.transmogID then
        slot.Icon.backdrop:SetBackdropBorderColor(slot.Name:GetTextColor())
    else
        slot.Icon.backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end

local function LoadDressUpFrameSkin()
    if not GetSetting("INSPECTION_SKIN_ENABLED") then return end

    DressUpFrame:GwStripTextures()
    DressUpFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    DressUpFrameCloseButton:GwSkinButton(true)
    DressUpFrameCloseButton:SetSize(20, 20)
    DressUpFrameResetButton:GwSkinButton(false, true)
    DressUpFrameCancelButton:GwSkinButton(false, true)

    -- 9.1.5 part
    if DressUpFrame.LinkButton then
        DressUpFrame.LinkButton:GwSkinButton(false, true)
        DressUpFrame.ToggleOutfitDetailsButton:GwCreateBackdrop()
        DressUpFrame.ToggleOutfitDetailsButton:GwSkinButton(false, true, false, true)

        local icon = DressUpFrame.ToggleOutfitDetailsButton:CreateTexture(nil, "OVERLAY")
        icon:SetPoint("TOPLEFT", 0, 0)
        icon:SetPoint("BOTTOMRIGHT", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetTexture(1392954)

        DressUpFrame.OutfitDetailsPanel:DisableDrawLayer("BACKGROUND")
        DressUpFrame.OutfitDetailsPanel:DisableDrawLayer("OVERLAY")
        DressUpFrame.OutfitDetailsPanel:GwCreateBackdrop(GW.skins.constBackdropFrame)
    end

    DressUpFrameOutfitDropDown:GwSkinDropDownMenu()
    DressUpFrameOutfitDropDown.backdrop:ClearAllPoints()
    DressUpFrameOutfitDropDown.backdrop:SetPoint("TOPLEFT", 0, 5)
    DressUpFrameOutfitDropDown.backdrop:SetPoint("BOTTOMRIGHT", DressUpFrameOutfitDropDownButton, "BOTTOMRIGHT", 2, -2)
    DressUpFrameOutfitDropDownText:ClearAllPoints()
    DressUpFrameOutfitDropDownText:SetPoint("RIGHT", DressUpFrameOutfitDropDownButton, "LEFT", 25, 0)
    DressUpFrameOutfitDropDown.SaveButton:GwSkinButton(false, true)
    DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -7, 3)
    DressUpFrame.MaximizeMinimizeFrame:GwHandleMaxMinFrame()

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

    -- 9.1.5 part
    if DressUpFrame.OutfitDetailsPanel then
        hooksecurefunc(DressUpFrame.OutfitDetailsPanel, "Refresh", function(self)
            if not self.slotPool then return end

            for slot in self.slotPool:EnumerateActive() do
                if not slot.backdrop then
                    slot.Icon:GwCreateBackdrop("Transparent", true, 1, 1)
                    slot.IconBorder:SetAlpha(0)
                    GW.HandleIcon(slot.Icon)
                end

                SetItemQuality(slot)
            end
        end)
        hooksecurefunc(DressUpFrame, "ConfigureSize", function(self)
            self.OutfitDetailsPanel:ClearAllPoints()
            self.OutfitDetailsPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
        end)
    end

    -- Wardrobe edit frame
    WardrobeOutfitFrame:GwStripTextures(true)
    WardrobeOutfitFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)

    WardrobeOutfitEditFrame:GwStripTextures(true)
    WardrobeOutfitEditFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    WardrobeOutfitEditFrame.EditBox:GwStripTextures()
    GW.SkinTextBox(WardrobeOutfitEditFrame.EditBox.MiddleTexture, WardrobeOutfitEditFrame.EditBox.LeftTexture, WardrobeOutfitEditFrame.EditBox.RightTexture)
    WardrobeOutfitEditFrame.AcceptButton:GwSkinButton(false, true)
    WardrobeOutfitEditFrame.CancelButton:GwSkinButton(false, true)
    WardrobeOutfitEditFrame.DeleteButton:GwSkinButton(false, true)

    -- SideDressUpFrame
    SideDressUpFrameCloseButton:GwSkinButton(true)
    SideDressUpFrameCloseButton:SetSize(18, 18)
    SideDressUpFrame.ResetButton:GwSkinButton(false, true)
    SideDressUpFrame:GwStripTextures()
    SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
    SideDressUpFrame:GwCreateBackdrop(GW.skins.constBackdropFrame, true, -2, -2)
end
GW.LoadDressUpFrameSkin = LoadDressUpFrameSkin
