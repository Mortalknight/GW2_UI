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
    if not GW.GetSetting("PERK_PROGRAM_SKIN_ENABLED") then return end

    if PerksProgramFrame.ProductsFrame then
        PerksProgramFrame.ProductsFrame.PerksProgramFilter.FilterDropDownButton:SkinButton(false, true)
        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:SetFont("UNIT_NAME_FONT", 30)
        GW.HandleIcon(PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon)
        PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon:SetSize(30, 30)

        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:StripTextures()
        PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:StripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:StripTextures()
        GW.HandleTrimScrollBar(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBar, true)
        GW.HandleAchivementsScrollControls(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:StripTextures()
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder)
        PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.backdrop:SetInside(3, 3)

        hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, "Update", function(container)
            container:ForEachFrame(HandleRewardButton)
        end)
    end

    if PerksProgramFrame.FooterFrame then
        PerksProgramFrame.FooterFrame.LeaveButton:SetText(LEAVE)
        PerksProgramFrame.FooterFrame.LeaveButton:SkinButton(false, true)
        PerksProgramFrame.FooterFrame.PurchaseButton:SkinButton(false, true)
        PerksProgramFrame.FooterFrame.RefundButton:SkinButton(false, true)

        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateLeftButton:SkinButton(false, true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateRightButton:SkinButton(false, true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateLeftButton.Icon:SetDesaturated(true)
        PerksProgramFrame.FooterFrame.RotateButtonContainer.RotateRightButton.Icon:SetDesaturated(true)

        PerksProgramFrame.FooterFrame.TogglePlayerPreview:SkinCheckButton()
        PerksProgramFrame.FooterFrame.TogglePlayerPreview:SetSize(20, 20)

        PerksProgramFrame.FooterFrame.ToggleHideArmor:SkinCheckButton()
        PerksProgramFrame.FooterFrame.ToggleHideArmor:SetSize(20, 20)
    end
end

local function LoadPerksProgramSkin()
    GW.RegisterLoadHook(SkinPerksProgram, "Blizzard_PerksProgram", PerksProgramFrame)
end
GW.LoadPerksProgramSkin = LoadPerksProgramSkin
