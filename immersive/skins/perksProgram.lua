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

local function SkinPerksProgram()
    if not GW.settings.PERK_PROGRAM_SKIN_ENABLED then return end

    PerksProgramFrame.ThemeContainer:SetAlpha(0)

    if PerksProgramFrame.ProductsFrame then
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.FilterDropDownButton:GwSkinButton(false, true)
        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:SetFont("UNIT_NAME_FONT", 30)
        GW.HandleIcon(PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon)
        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon:SetSize(30, 30)

        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:GwStripTextures()
        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:GwStripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwStripTextures()
        GW.HandleTrimScrollBar(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBar, true)
        GW.HandleScrollControls(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwStripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.backdrop:GwSetInside(3, 3)

        hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, "Update", function(container)
            container:ForEachFrame(HandleRewardButton)
        end)
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
    end
end

local function LoadPerksProgramSkin()
    GW.RegisterLoadHook(SkinPerksProgram, "Blizzard_PerksProgram", PerksProgramFrame)
end
GW.LoadPerksProgramSkin = LoadPerksProgramSkin
