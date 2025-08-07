local _, GW = ...

local function gwSetStaticPopupSize()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]
        StaticPopup.AlertIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/warning-icon")
        if _G["StaticPopup" .. i .. "ItemFrameNameFrame"] then
            _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:SetTexture(nil)
            _G["StaticPopup" .. i .. "ItemFrame"].IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
            _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            _G["StaticPopup" .. i .. "ItemFrameNormalTexture"]:SetTexture(nil)
        else
            StaticPopup.ItemFrame.NameFrame:SetTexture(nil)
            StaticPopup.ItemFrame.Item.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
            StaticPopup.ItemFrame.Item.icon:SetTexCoord(0.9, 0.1, 0.9, 0.1)
            StaticPopup.ItemFrame.Item.icon:GwSetInside()
        end
        StaticPopup.CloseButton:GwSkinButton(true)
        StaticPopup.CloseButton:SetSize(20, 20)
        StaticPopup.CloseButton:ClearAllPoints()
        StaticPopup.CloseButton:SetPoint("TOPRIGHT", -20, -5)
    end
end

local function ClearSetTexture(texture, tex)
    if tex ~= nil then
        texture:SetTexture()
    end
end

local function LoadStaticPopupSkin()
    if not GW.settings.STATICPOPUP_SKIN_ENABLED then return end

    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:GwCreateBackdrop()
        if not GW.Retail then
            StaticPopup:GwStripTextures()
        end
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()
        if StaticPopup.Border then
            StaticPopup.Border:Hide()
        end

        if StaticPopup.BG then
            StaticPopup.BG:Hide()
        end

        local tex = StaticPopup:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("TOPLEFT", StaticPopup, "TOPLEFT", 0, 0)
        tex:SetPoint("BOTTOMRIGHT", StaticPopup, "BOTTOMRIGHT", 0, 0)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        StaticPopup.tex = tex

        --Style Buttons (upto 5)
        StaticPopup.button1:GwSkinButton(false, true)
        StaticPopup.button2:GwSkinButton(false, true)
        StaticPopup.button3:GwSkinButton(false, true)
        StaticPopup.button4:GwSkinButton(false, true)
        StaticPopup.extraButton:GwSkinButton(false, true)
        StaticPopup.Dropdown:GwHandleDropDownBox()

        GW.SkinTextBox(_G["StaticPopup" .. i .. "MoneyInputFrameGoldMiddle"], _G["StaticPopup" .. i .. "MoneyInputFrameGoldLeft"], _G["StaticPopup" .. i .. "MoneyInputFrameGoldRight"], nil, nil, 5)
        GW.SkinTextBox(_G["StaticPopup" .. i .. "MoneyInputFrameSilverMiddle"], _G["StaticPopup" .. i .. "MoneyInputFrameSilverLeft"], _G["StaticPopup" .. i .. "MoneyInputFrameSilverRight"], nil, nil, 5, -10)
        GW.SkinTextBox(_G["StaticPopup" .. i .. "MoneyInputFrameCopperMiddle"], _G["StaticPopup" .. i .. "MoneyInputFrameCopperLeft"], _G["StaticPopup" .. i .. "MoneyInputFrameCopperRight"], nil, nil, 5, -10)

        local editbox = StaticPopup.editBox or StaticPopup.EditBox
        editbox:SetFrameLevel(editbox:GetFrameLevel() + 1)
        editbox:SetPoint("TOPLEFT", -2, -4)
        editbox:SetPoint("BOTTOMRIGHT", 2, 4)
        GW.SkinTextBox(_G["StaticPopup" .. i .. "EditBoxMid"], _G["StaticPopup" .. i .. "EditBoxLeft"], _G["StaticPopup" .. i .. "EditBoxRight"], nil, nil, 5)

        if _G["StaticPopup" .. i .. "ItemFrameNameFrame"] then
            _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:GwKill()
            _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:SetTexCoord(0.9, 0.1, 0.9, 0.1)
            _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:GwSetInside()
        else
            StaticPopup.ItemFrame.NameFrame:GwKill()
            StaticPopup.ItemFrame.Item.icon:SetTexCoord(0.9, 0.1, 0.9, 0.1)
            StaticPopup.ItemFrame.Item.icon:GwSetInside()
        end

        local itemFrame = StaticPopup.ItemFrame
        itemFrame:GwStyleButton()
        if itemFrame.Item then
            GW.HandleIcon(itemFrame.Item.icon, true, GW.BackdropTemplates.ColorableBorderOnly)
            GW.HandleIconBorder(itemFrame.Item.IconBorder, itemFrame.Item.icon.backdrop)
        else
            GW.HandleIcon(itemFrame.icon, true, GW.BackdropTemplates.ColorableBorderOnly)
            GW.HandleIconBorder(itemFrame.IconBorder, itemFrame.icon.backdrop)
        end

        local normTex = itemFrame.GetNormalTexture and itemFrame:GetNormalTexture()
        if normTex then
            normTex:SetTexture()
            hooksecurefunc(normTex, "SetTexture", ClearSetTexture)
        end
    end

    hooksecurefunc("StaticPopup_OnUpdate", gwSetStaticPopupSize)

    --Movie skip Frame
    hooksecurefunc("CinematicFrame_UpdateLettboxForAspectRatio", function(self)
        if self and self.closeDialog and not self.closeDialog.tex then
            self.closeDialog.Border:Hide()

            local tex = self.closeDialog:CreateTexture(nil, "BACKGROUND")
            tex:SetPoint("TOPLEFT", self.closeDialog, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", self.closeDialog, "BOTTOMRIGHT", 0, 0)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
            self.closeDialog.tex = tex

            local dialogName = self.closeDialog.GetName and self.closeDialog:GetName()
            local closeButton = self.closeDialog.ConfirmButton or (dialogName and _G[dialogName .. "ConfirmButton"])
            local resumeButton = self.closeDialog.ResumeButton or (dialogName and _G[dialogName .. "ResumeButton"])
            if closeButton then
                closeButton:GwSkinButton(false, true)
            end
            if resumeButton then
                resumeButton:GwSkinButton(false, true)
            end
        end
    end)

    hooksecurefunc("MovieFrame_PlayMovie", function(self)
        if self and self.CloseDialog and not self.CloseDialog.tex then
            self.CloseDialog.Border:Hide()

            local tex = self.CloseDialog:CreateTexture(nil, "BACKGROUND")
            tex:SetPoint("TOPLEFT", self.closeDialog, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", self.closeDialog, "BOTTOMRIGHT", 0, 0)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
            self.CloseDialog.tex = tex

            self.CloseDialog.ConfirmButton:GwSkinButton(false, true)
            self.CloseDialog.ResumeButton:GwSkinButton(false, true)
        end
    end)
end
GW.LoadStaticPopupSkin = LoadStaticPopupSkin