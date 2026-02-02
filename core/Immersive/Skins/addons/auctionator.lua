local _, GW = ...

local skinLoaded = false

local function SkinItem(item)
    if item.Icon and not item.backdrop then
        GW.HandleIcon(item.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
        GW.HandleIconBorder(item.IconBorder, item.Icon.backdrop)
        item.Icon:GwSetInside(item.backdrop)
        item.EmptySlot:Hide()
        item:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
        item:GetHighlightTexture():Hide()
        item:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    end
end

local function SetItemInfo(item, info)
    if info then
        SkinItem(item)
    end
end

local function SetGroupTitleFrame(header)
    local button = header.GroupTitle
    if button and not button.IsSkinned then
        button:DisableDrawLayer("BACKGROUND")

        if not button.backdrop then
            button:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
            button.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
            button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
            button:GetHighlightTexture():SetColorTexture(1, 0.93, 0.73, 0.25)
            button.HighlightTexture:GwKill()
            button:GetNormalTexture():GwSetInside()
            button:GetHighlightTexture():GwSetInside()
            button.Text:SetTextColor(1, 1, 1)
        end

        button.IsSkinned = true
    end
end

local function SkinDialog()
    for i = 1, 10 do
        local frame = _G["AuctionatorDialog" .. i]
        if frame and not frame.gw2Skinned then
            frame.gw2Skinned = true
            frame:GwStripTextures()
            frame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
        end
        if frame then
            if frame.acceptButton then
                frame.acceptButton:GwSkinButton(false, true)
            end
            if frame.cancelButton then
                frame.cancelButton:GwSkinButton(false, true)
            end
            if frame.altButton then
                frame.altButton:GwSkinButton(false, true)
            end
            if frame.editBox and not frame.editBox.isSkinned then
                frame.editBox.isSkinned = true
                GW.SkinTextBox(frame.editBox.Middle, frame.editBox.Left, frame.editBox.Right, nil, nil, 5, 5)
            end
        end
    end
end

local function SkinAuctionator()
    if AuctionHouseFrame:GetScale() < 0.5 then
        return
    end
    if skinLoaded then return end
    skinLoaded = true

    local libAhTab = LibStub:GetLibrary("LibAHTab-1-0", true)
    if libAhTab then
        for _, details in ipairs(Auctionator.Tabs.State.knownTabs) do
            local tab = libAhTab:GetButton("AuctionatorTabs_" .. details.name)
            if tab then
                if not tab.isSkinned and details.name ~= nil then
                    local id = ""
                    if details.name == "Shopping" then
                        id = "addon_buy"
                    elseif details.name == "Selling" then
                        id = "addon_sell"
                    elseif details.name == "Cancelling" then
                        id = "addon_cancel"
                    elseif details.name == "Auctionator" then
                        id = "auctionator"
                    elseif details.name == "Collecting(s)" or details.name == "Collecting" then
                        id = "addon_collecting"
                    end
                    local iconTexture = "Interface/AddOns/GW2_UI/textures/Auction/tabicon_" .. id .. ".png"
                    GW.SkinSideTabButton(tab, iconTexture, details.tabHeader)
                end

                tab:ClearAllPoints()
                tab:SetPoint("TOPRIGHT", AuctionHouseFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * GW.ActionHouseTabsAdded))
                tab:SetParent(AuctionHouseFrame.LeftSidePanel)
                tab:SetSize(64, 40)
                GW.ActionHouseTabsAdded = GW.ActionHouseTabsAdded + 1
            end
        end
    end

    -- AuctionatorConfigFrame
    AuctionatorConfigFrame:GwStripTextures()
    GW.AddDetailsBackground(AuctionatorConfigFrame)
    AuctionatorConfigFrame.OptionsButton:GwSkinButton(false, true)
    AuctionatorConfigFrame.ScanButton:GwSkinButton(false, true)
    GW.SkinTextBox(AuctionatorConfigFrame.ContributeLink.InputBox.Middle, AuctionatorConfigFrame.ContributeLink.InputBox.Left, AuctionatorConfigFrame.ContributeLink.InputBox.Right)
    GW.SkinTextBox(AuctionatorConfigFrame.DiscordLink.InputBox.Middle, AuctionatorConfigFrame.DiscordLink.InputBox.Left, AuctionatorConfigFrame.DiscordLink.InputBox.Right)
    GW.SkinTextBox(AuctionatorConfigFrame.BugReportLink.InputBox.Middle, AuctionatorConfigFrame.BugReportLink.InputBox.Left, AuctionatorConfigFrame.BugReportLink.InputBox.Right)
    AuctionatorConfigFrame.AuthorHeading.HeadingText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AuctionatorConfigFrame.ContributorsHeading.HeadingText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AuctionatorConfigFrame.ContributeHeading.HeadingText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AuctionatorConfigFrame.VersionHeading.HeadingText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AuctionatorConfigFrame.EngageHeading.HeadingText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AuctionatorConfigFrame.TranslatorsHeading.HeadingText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    -- AuctionatorCancellingFrame
    AuctionatorCancellingFrame:GwStripTextures()
    AuctionatorCancellingFrame.ResultsListing:GwStripTextures()
    AuctionatorCancellingFrame.HistoricalPriceInset:GwStripTextures()
    GW.AddDetailsBackground(AuctionatorCancellingFrame.HistoricalPriceInset)
    AuctionatorCancellingFrame.UndercutScanContainer.StartScanButton:GwSkinButton(false, true)
    AuctionatorCancellingFrame.UndercutScanContainer.CancelNextButton:GwSkinButton(false, true)
    AuctionatorCancelUndercutButton:GwSkinButton(false, true)
    GW.SkinTextBox(AuctionatorCancellingFrame.SearchFilter.Middle, AuctionatorCancellingFrame.SearchFilter.Left, AuctionatorCancellingFrame.SearchFilter.Right)
    GW.HandleSrollBoxHeaders(AuctionatorCancellingFrame.ResultsListing)

    GW.HandleTrimScrollBar(AuctionatorCancellingFrame.ResultsListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(AuctionatorCancellingFrame.ResultsListing.ScrollArea)
    hooksecurefunc(AuctionatorCancellingFrame.ResultsListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    AuctionatorCancellingFrame.ResultsListing.ScrollArea.NoResultsText:SetTextColor(1, 1, 1)
    AuctionatorCancellingFrame.ResultsListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)

    AuctionatorCancellingFrame.UndercutScanContainer.StartScanButton:SetPoint("TOPRIGHT", AuctionatorCancellingFrame.UndercutScanContainer.CancelNextButton, "TOPLEFT", 0, 0)

    -- undercut butttons, refresh button
    for _, child in next, {AuctionatorCancellingFrame:GetChildren()} do
        if child.iconAtlas == "UI-RefreshButton" then
            child:GwSkinButton(false, true)
            child.Icon:SetDesaturated(true)
        end
    end

    -- Selling
    local selling = AuctionatorSellingFrame
    selling.HistoricalPriceInset:GwStripTextures()
    selling.BagInset:GwStripTextures()
    GW.HandleTrimScrollBar(selling.BagListing.View.ScrollBar)
    GW.HandleScrollControls(selling.BagListing.View)
    GW.AddDetailsBackground(selling.HistoricalPriceInset, -1)
    GW.AddDetailsBackground(selling.BagListing)
    selling.SaleItemFrame.MaxButton:GwSkinButton(false, true)
    selling.SaleItemFrame.PostButton:GwSkinButton(false, true)
    selling.SaleItemFrame.SkipButton:GwSkinButton(false, true)
    SkinItem(selling.SaleItemFrame.Icon)

    -- handle bag item icons
    hooksecurefunc(AuctionatorGroupsViewItemMixin, "SetItemInfo", SetItemInfo)
    hooksecurefunc(AuctionatorGroupsViewGroupMixin, "AddButton", SetGroupTitleFrame)

    GW.HandleTabs(selling.PricesTabsContainer.CurrentPricesTab)
    GW.HandleTabs(selling.PricesTabsContainer.RealmHistoryTab)
    GW.HandleTabs(selling.PricesTabsContainer.YourHistoryTab)
    GW.HandleTabs(selling.PricesTabsContainer.PriceHistoryTab)

    GW.HandleSrollBoxHeaders(selling.CurrentPricesListing)
    GW.HandleSrollBoxHeaders(selling.HistoricalPriceListing)
    GW.HandleSrollBoxHeaders(selling.ResultsListing)

    GW.HandleTrimScrollBar(selling.CurrentPricesListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(selling.CurrentPricesListing.ScrollArea)
    hooksecurefunc(selling.CurrentPricesListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    GW.HandleTrimScrollBar(selling.HistoricalPriceListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(selling.HistoricalPriceListing.ScrollArea)
    hooksecurefunc(selling.HistoricalPriceListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    GW.HandleTrimScrollBar(selling.ResultsListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(selling.ResultsListing.ScrollArea)
    hooksecurefunc(selling.ResultsListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    selling.CurrentPricesListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)
    selling.HistoricalPriceListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)
    selling.ResultsListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)

    selling.CurrentPricesListing.ScrollArea.NoResultsText:SetTextColor(1, 1, 1)
    selling.HistoricalPriceListing.ScrollArea.NoResultsText:SetTextColor(1, 1, 1)
    selling.ResultsListing.ScrollArea.NoResultsText:SetTextColor(1, 1, 1)

    selling.SaleItemFrame.Deposit:SetTextColor(1, 1, 1)
    selling.SaleItemFrame.Total:SetTextColor(1, 1, 1)

    GW.SkinTextBox(selling.SaleItemFrame.Quantity.InputBox.Middle, selling.SaleItemFrame.Quantity.InputBox.Left, selling.SaleItemFrame.Quantity.InputBox.Right)
    GW.SkinTextBox(selling.SaleItemFrame.Price.MoneyInput.GoldBox.Middle, selling.SaleItemFrame.Price.MoneyInput.GoldBox.Left, selling.SaleItemFrame.Price.MoneyInput.GoldBox.Right)
    GW.SkinTextBox(selling.SaleItemFrame.Price.MoneyInput.SilverBox.Middle, selling.SaleItemFrame.Price.MoneyInput.SilverBox.Left, selling.SaleItemFrame.Price.MoneyInput.SilverBox.Right)
    GW.SkinTextBox(selling.SaleItemFrame.Price.MoneyInput.CopperBox.Middle, selling.SaleItemFrame.Price.MoneyInput.CopperBox.Left, selling.SaleItemFrame.Price.MoneyInput.CopperBox.Right)

    for _, child in next, {selling.AuctionatorSaleItem:GetChildren()} do
        if child.iconAtlas == "UI-RefreshButton" then
            child:GwSkinButton(false, true)
            child.Icon:SetDesaturated(true)
        end
    end

    for _, duration in next, selling.AuctionatorSaleItem.Duration.radioButtons do
        if duration.RadioButton then
            duration.RadioButton:GwSkinCheckButton(true)
            duration.RadioButton:SetSize(15, 15)
        end
    end

    -- buying
    local frame = AuctionatorBuyItemFrame
    frame.BackButton:GwSkinButton(false, true)
    frame.Inset:GwStripTextures()
    frame.ResultsListing:GwStripTextures()
    GW.HandleTrimScrollBar(frame.ResultsListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(frame.ResultsListing.ScrollArea)
    GW.HandleSrollBoxHeaders(frame.ResultsListing)
    GW.AddDetailsBackground(frame.Inset)

    GW.HandleIcon(frame.IconAndName.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
    GW.HandleIconBorder(frame.IconAndName.QualityBorder, frame.IconAndName.Icon.backdrop)
    frame.IconAndName.Icon.backdrop:GwSetOutside(frame.IconAndName.Icon)
    frame.IconAndName:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, nil, -5, nil, -5)

    hooksecurefunc(frame.ResultsListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    for _, child in next, {frame:GetChildren()} do
        if child.iconAtlas == "UI-RefreshButton" then
            child:GwSkinButton(false, true)
            child.Icon:SetDesaturated(true)
            break
        end
    end

    frame.BuyDialog:GwStripTextures()
    frame.BuyDialog:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    frame.BuyDialog.Buy:GwSkinButton(false, true)
    frame.BuyDialog.Cancel:GwSkinButton(false, true)


    local list = AuctionatorShoppingFrame
    local buyingFrame = AuctionatorBuyCommodityFrame
    list.ResultsListing:GwStripTextures()
    list.ListsContainer:GwStripTextures()
    list.ShoppingResultsInset:GwStripTextures()
    list.RecentsContainer:GwStripTextures()
    buyingFrame:GwStripTextures()
    buyingFrame.ResultsListing:GwStripTextures()

    list.ListsContainer:ClearAllPoints()
    list.ListsContainer:SetPoint("TOP", 3, -50)
    list.ListsContainer:SetPoint("BOTTOM", 3, 35)
    list.ListsContainer:SetPoint("LEFT", 3, 0)

    buyingFrame.FinalConfirmationDialog:GwStripTextures()
    buyingFrame.FinalConfirmationDialog:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    buyingFrame.FinalConfirmationDialog.AcceptButton:GwSkinButton(false, true)
    buyingFrame.FinalConfirmationDialog.CancelButton:GwSkinButton(false, true)

    local point, anchor, anchorPoint, _, y = list.ListsContainer.ScrollBox:GetPoint()
    list.ListsContainer.ScrollBox:SetPoint(point, anchor, anchorPoint, 5, y)
    GW.HandleTrimScrollBar(list.ListsContainer.ScrollBar)
    GW.HandleScrollControls(list.ListsContainer)
    hooksecurefunc(list.ListsContainer.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    hooksecurefunc(list.ListsContainer.ScrollBox, "Update", function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            child.Text:SetTextColor(1, 1, 1)

            if not child.IsSkinned then
                child.Text:SetShadowColor(0, 0, 0, 0)
                child.Text:SetShadowOffset(1, -1)
                child.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
                child.Text:SetJustifyH("LEFT")
                child.Text:SetJustifyV("MIDDLE")
                child.IsSkinned = true
            end

            if not child.arrow then
                -- add arrows
                child.arrow = child:CreateTexture(nil, "BACKGROUND", nil, 1)
                child.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
                child.arrow:SetSize(16, 16)
                child.arrow:ClearAllPoints()
			    child.arrow:SetPoint("LEFT", 0, 0)
            end
            child.Text:SetPoint("LEFT", 15, 0)

            if child.elementData.type == RowType.List then
                local color = CreateColor(255 / 255, 241 / 255, 209 / 255)
                if child.elementData.list:IsTemporary() then
                    color = ORANGE_FONT_COLOR
                end
                if not list.ListsContainer:IsListExpanded(child.elementData.list) then
                    child.arrow:SetRotation(0)
                else
                    child.arrow:SetRotation(-1.5707)
                end
                child.Text:SetText(color:WrapTextInColorCode(child.elementData.list:GetName()))
                child.arrow:Show()
            else
                child.arrow:Hide()
            end
        end
    end)

    GW.HandleTrimScrollBar(list.ResultsListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(list.ResultsListing.ScrollArea)
    hooksecurefunc(list.ResultsListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    list.RecentsContainer:ClearAllPoints()
    list.RecentsContainer:SetPoint("TOP", 3, -50)
    list.RecentsContainer:SetPoint("BOTTOM", 3, 35)
    list.RecentsContainer:SetPoint("LEFT", 3, 0)

    point, anchor, anchorPoint, _, y = list.RecentsContainer.ScrollBox:GetPoint()
    list.RecentsContainer.ScrollBox:SetPoint(point, anchor, anchorPoint, 5, y)
    GW.HandleTrimScrollBar(list.RecentsContainer.ScrollBar)
    GW.HandleScrollControls(list.RecentsContainer)
    hooksecurefunc(list.RecentsContainer.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    GW.HandleTrimScrollBar(buyingFrame.ResultsListing.ScrollArea.ScrollBar)
    GW.HandleScrollControls(buyingFrame.ResultsListing.ScrollArea)
    hooksecurefunc(buyingFrame.ResultsListing.ScrollArea.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    GW.AddDetailsBackground(list.ShoppingResultsInset, 2)
    GW.AddDetailsBackground(list.ListsContainer.Inset, 2)
    GW.AddDetailsBackground(list.RecentsContainer.Inset, 2)
    GW.AddDetailsBackground(buyingFrame)
    GW.AddDetailsBackground(buyingFrame.ResultsListing)

    list.SearchOptions.AddToListButton:GwSkinButton(false, true)
    list.SearchOptions.MoreButton:GwSkinButton(false, true)
    list.SearchOptions.SearchButton:GwSkinButton(false, true)
    list.SearchOptions.ResetSearchStringButton:GwSkinButton(false, true)
    list.NewListButton:GwSkinButton(false, true)
    list.ImportButton:GwSkinButton(false, true)
    list.ExportButton:GwSkinButton(false, true)
    list.ExportCSV:GwSkinButton(false, true)
    buyingFrame.DetailsContainer.BuyButton:GwSkinButton(false, true)
    buyingFrame.BackButton:GwSkinButton(false, true)


    list.SearchOptions.ResetSearchStringButton.texture:SetDrawLayer("ARTWORK", 7)

    for _, child in next, {buyingFrame:GetChildren()} do
        if child.iconAtlas == "UI-RefreshButton" then
            child:GwSkinButton(false, true)
            child.Icon:SetDesaturated(true)
            break
        end
    end

    GW.SkinTextBox(list.SearchOptions.SearchString.Middle, list.SearchOptions.SearchString.Left, list.SearchOptions.SearchString.Right)
    GW.SkinTextBox(buyingFrame.DetailsContainer.Quantity.Middle, buyingFrame.DetailsContainer.Quantity.Left, buyingFrame.DetailsContainer.Quantity.Right)

    GW.HandleSrollBoxHeaders(list.ResultsListing)
    GW.HandleSrollBoxHeaders(buyingFrame.ResultsListing)

    list.SearchOptions.SearchLabel:SetTextColor(1, 1, 1)
    list.ListsContainer.ResultsText:SetTextColor(1, 1, 1)
    list.ResultsListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)
    buyingFrame.DetailsContainer.QuantityLabel:SetTextColor(1, 1, 1)
    buyingFrame.DetailsContainer.UnitPriceLabel:SetTextColor(1, 1, 1)
    buyingFrame.DetailsContainer.TotalPriceLabel:SetTextColor(1, 1, 1)
    buyingFrame.ResultsListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)
    buyingFrame.ResultsListing.ScrollArea.NoResultsText:SetTextColor(1, 1, 1)

    GW.HandleIcon(buyingFrame.IconAndName.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
    GW.HandleIconBorder(buyingFrame.IconAndName.QualityBorder, buyingFrame.IconAndName.Icon.backdrop)
    buyingFrame.IconAndName.Icon.backdrop:GwSetOutside(buyingFrame.IconAndName.Icon)
    buyingFrame.IconAndName:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    GW.HandleTabs(list.ContainerTabs.ListsTab, "top")
    GW.HandleTabs(list.ContainerTabs.RecentsTab, "top")

    list.ContainerTabs.ListsTab:SetHeight(28)
    list.ContainerTabs.RecentsTab:SetHeight(28)

    -- import export
    local export = AuctionatorExportListFrame
    local import = AuctionatorImportListFrame
    local exportCsv = AuctionatorShoppingFrame.exportCSVDialog

    export:GwStripTextures()
    import:GwStripTextures()
    export.copyTextDialog:GwStripTextures()
    exportCsv:GwStripTextures()

    export:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    import:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    import.EditBoxContainer:GwCreateBackdrop(GW.BackdropTemplates.DopwDown)
    import.EditBoxContainer.backdrop:SetBackdropBorderColor(0, 0, 0)
    import.EditBoxContainer.backdrop:SetBackdropColor(0, 0, 0)
    export.copyTextDialog:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    export.copyTextDialog.EditBoxContainer:GwCreateBackdrop(GW.BackdropTemplates.DopwDown)
    export.copyTextDialog.EditBoxContainer.backdrop:SetBackdropBorderColor(0, 0, 0)
    export.copyTextDialog.EditBoxContainer.backdrop:SetBackdropColor(0, 0, 0)
    exportCsv:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    exportCsv.EditBoxContainer:GwCreateBackdrop(GW.BackdropTemplates.DopwDown)
    exportCsv.EditBoxContainer.backdrop:SetBackdropBorderColor(0, 0, 0)
    exportCsv.EditBoxContainer.backdrop:SetBackdropColor(0, 0, 0)

    import.Import:GwSkinButton(false, true)
    import.CloseDialog:GwSkinButton(true)
    export.SelectAll:GwSkinButton(false, true)
    export.UnselectAll:GwSkinButton(false, true)
    export.Export:GwSkinButton(false, true)
    export.CloseDialog:GwSkinButton(true)
    export.copyTextDialog.Close:GwSkinButton(false, true)
    exportCsv.Close:GwSkinButton(false, true)

    GW.HandleTrimScrollBar(import.ScrollBar)
    GW.HandleScrollControls(import)

    GW.HandleTrimScrollBar(export.copyTextDialog.ScrollBar)
    GW.HandleScrollControls(export.copyTextDialog)

    GW.HandleTrimScrollBar(export.ScrollBar)
    GW.HandleScrollControls(export)

    GW.HandleTrimScrollBar(exportCsv.ScrollBar)
    GW.HandleScrollControls(exportCsv)

    hooksecurefunc(export.ScrollBox, "Update", function()
        for frame in export.checkBoxPool:EnumerateActive() do
            local checkbox = frame.CheckBox
            if checkbox and not frame.isSkinned then
                checkbox:GwSkinCheckButton()
                checkbox:SetSize(25, 25)
            end
        end
    end)

    -- extended search
    local extendedSearch = AuctionatorShoppingTabItemFrame
    extendedSearch:GwStripTextures()
    extendedSearch:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    extendedSearch.Cancel:GwSkinButton(false, true)
    extendedSearch.ResetAllButton:GwSkinButton(false, true)
    extendedSearch.Finished:GwSkinButton(false, true)

    extendedSearch.SearchContainer.IsExact:GwSkinCheckButton()

    for _, textarea in next, {
        extendedSearch.LevelRange.MaxBox,
        extendedSearch.LevelRange.MinBox,
        extendedSearch.ItemLevelRange.MaxBox,
        extendedSearch.ItemLevelRange.MinBox,
        extendedSearch.PriceRange.MaxBox,
        extendedSearch.PriceRange.MinBox,
        extendedSearch.CraftedLevelRange.MaxBox,
        extendedSearch.CraftedLevelRange.MinBox,
        extendedSearch.SearchContainer.SearchString,
        extendedSearch.PurchaseQuantity.InputBox
    } do
        GW.SkinTextBox(textarea.Middle, textarea.Left, textarea.Right)
    end

    extendedSearch.FilterKeySelector.DropDown:GwHandleDropDownBox(nil, nil, nil, 280)
    extendedSearch.QualityContainer.DropDown.DropDown:GwHandleDropDownBox()
    extendedSearch.ExpansionContainer.DropDown.DropDown:GwHandleDropDownBox()
    extendedSearch.TierContainer.DropDown.DropDown:GwHandleDropDownBox()

    -- dialogs
    hooksecurefunc(Auctionator.Dialogs, "ShowEditBox", SkinDialog)
    hooksecurefunc(Auctionator.Dialogs, "ShowConfirm", SkinDialog)
    hooksecurefunc(Auctionator.Dialogs, "ShowConfirmAlt", SkinDialog)
    hooksecurefunc(Auctionator.Dialogs, "ShowMoney", SkinDialog)
end

local function LoadAuctionatorAddonSkin()
    if not GW.settings.AuctionHouseSkinEnabled or not GW.settings.AUCTIONATOR_SKIN_ENABLED or not Auctionator then return end
    hooksecurefunc(AuctionatorAHFrameMixin, "OnShow", SkinAuctionator)
end
GW.LoadAuctionatorAddonSkin = LoadAuctionatorAddonSkin