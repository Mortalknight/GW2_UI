local _, GW = ...

local function ReplaceIconString(frame, text)
    if not text then text = frame:GetText() end
    if not text or text == "" then return end
    local newText, count = gsub(text, "|T(%d+):24:24[^|]*|t", " |T%1:16:16:0:0:64:64:5:59:5:59|t")
    if count > 0 then frame:SetFormattedText("%s", newText) end
end

local function HandleRewardButton(button)
    local container = button.ContentsContainer
    if container and not container.isSkinned then
        container.isSkinned = true
        GW.HandleIcon(container.Icon)
        ReplaceIconString(container.Price)
        hooksecurefunc(container.Price, "SetText", ReplaceIconString)
    end
end

local function HandleSetButtons(button)
    if not button then return end

    if not button.Icon.backdrop then
        GW.HandleIcon(button.Icon, true)
        GW.HandleIconBorder(button.IconBorder, button.Icon.backdrop)
    end

    button.BackgroundTexture:SetAlpha(0)
    button.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.25)
    button.SelectedTexture:GwSetInside()
    button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
    button.HighlightTexture:GwSetInside()
end

local function HandleSortLabel(button)
    if button and button.Label then
        button.Label:SetFont("UNIT_NAME_FONT", 14)
        button.Label:SetTextColor(1, 1, 1, 1)
    end
end

local function HandleNextPrev(button)
    GW.HandleNextPrevButton(button)

    button:SetScript("OnMouseUp", nil)
    button:SetScript("OnMouseDown", nil)
end

local function DetailsScrollBoxUpdate(box)
    box:ForEachFrame(HandleSetButtons)
end

local function HandleRewards(box)
    if box then
        box:ForEachFrame(HandleRewardButton)
    end
end

local function PurchaseButton_EnterLeave(button)
    local label = button:GetFontString()

    label:SetTextColor(0, 0, 0, 1)
end

local function GlowEmitterFactory_Toggle(frame, target, show)
    local perks = _G.PerksProgramFrame
    local footer = perks and perks.FooterFrame
    local button = footer and footer.PurchaseButton
    if not button or target ~= button then return end

    if show then
        frame:Hide(target)
    end

    PurchaseButton_EnterLeave(target)
end

local function GlowEmitterFactory_Show(frame, target)
    GlowEmitterFactory_Toggle(frame, target, true)
end

local function GlowEmitterFactory_Hide(frame, target)
    GlowEmitterFactory_Toggle(frame, target)
end

local function PurchaseButton_OnEnter(button)
    PurchaseButton_EnterLeave(button)
end

local function PurchaseButton_OnLeave(button)
    PurchaseButton_EnterLeave(button)
end

local function SkinPerksProgram()
    if not GW.settings.PERK_PROGRAM_SKIN_ENABLED then return end

    PerksProgramFrame.ThemeContainer:SetAlpha(0)

    if PerksProgramFrame.ProductsFrame then
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:GwSkinButton(false, true)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.Text:SetShadowOffset(0, 0)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.Text:SetTextColor(0, 0, 0)

        PerksProgramFrame.ProductsFrame.PerksProgramFilter:SetScript("OnEnter", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
        end)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:SetScript("OnLeave", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
        end)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:HookScript("OnClick", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
            self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        end)
        PerksProgramFrame.ProductsFrame.PerksProgramFilter:HookScript("OnMouseDown", function(self)
            self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            self.Text:SetShadowOffset(0, 0)
            self.Text:SetTextColor(0, 0, 0)
            self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        end)

        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:SetFont("UNIT_NAME_FONT", 30)
        GW.HandleIcon(PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon)
        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon:SetSize(30, 30)

        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:GwStripTextures()
        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

        local container = PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer
        if container then
            GW.HandleTrimScrollBar(container.ScrollBar)
            GW.HandleScrollControls(container)

            hooksecurefunc(container.ScrollBox, "Update", DetailsScrollBoxUpdate)
        end

        local carousel = PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.CarouselFrame
        if carousel and carousel.IncrementButton then
            HandleNextPrev(carousel.IncrementButton)
            HandleNextPrev(carousel.DecrementButton)
        end

        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:GwStripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        GW.HandleTrimScrollBar(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBar)
        GW.HandleScrollControls(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwStripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.backdrop:GwSetInside(3, 3)

        HandleSortLabel(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.NameSortButton)
        HandleSortLabel(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PriceSortButton)

        hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, "Update", HandleRewards)
    end

    if PerksProgramFrame.FooterFrame then
        PerksProgramFrame.FooterFrame.LeaveButton:SetText(LEAVE)
        PerksProgramFrame.FooterFrame.LeaveButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.PurchaseButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RefundButton:GwSkinButton(false, true)

        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateLeftButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateRightButton:GwSkinButton(false, true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateLeftButton.Icon:SetDesaturated(true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateRightButton.Icon:SetDesaturated(true)

        PerksProgramFrame.FooterFrame.TogglePlayerPreview:GwSkinCheckButton()
        PerksProgramFrame.FooterFrame.TogglePlayerPreview:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.ToggleHideArmor:GwSkinCheckButton()
        PerksProgramFrame.FooterFrame.ToggleHideArmor:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.ToggleMountSpecial:GwSkinCheckButton()
        PerksProgramFrame.FooterFrame.ToggleMountSpecial:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.PurchaseButton:HookScript("OnEnter", PurchaseButton_OnEnter)
        PerksProgramFrame.FooterFrame.PurchaseButton:HookScript("OnLeave", PurchaseButton_OnLeave)

        -- handle the glow
        hooksecurefunc(GlowEmitterFactory, "Show", GlowEmitterFactory_Show)
        hooksecurefunc(GlowEmitterFactory, "Hide", GlowEmitterFactory_Hide)

    end
end

local function LoadPerksProgramSkin()
    GW.RegisterLoadHook(SkinPerksProgram, "Blizzard_PerksProgram", PerksProgramFrame)
end
GW.LoadPerksProgramSkin = LoadPerksProgramSkin
