local _, GW = ...

local function SkinFilterButton(Button)
	Button:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true)
	Button.ClearFiltersButton:GwSkinButton(true)
end

local function HandleSearchBarFrame(Frame)
	SkinFilterButton(Frame.FilterButton)

	Frame.SearchButton:GwSkinButton(false, true)
	GW.SkinTextBox(Frame.SearchBox.Middle, Frame.SearchBox.Left, Frame.SearchBox.Right)
	Frame.FavoritesSearchButton:GwSkinButton(false, true)
	Frame.FavoritesSearchButton.Icon:SetDesaturated(true)
	hooksecurefunc(Frame.FavoritesSearchButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end) --TODO
	Frame.FavoritesSearchButton:SetSize(22, 22)
end

local function HandleListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells and row.cells[j]
				if cell and cell.Icon then
					if not cell.IsSkinned then
						GW.HandleIcon(cell.Icon)

						if cell.IconBorder then
							cell.IconBorder:GwKill()
						end

						cell.IsSkinned = true
					end
				end
			end
		end
	end
end

local function SkinItemDisplay(frame)
	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:GwStripTextures()
	ItemDisplay:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
	ItemDisplay.backdrop:SetPoint("TOPLEFT", 3, -3)
	ItemDisplay.backdrop:SetPoint("BOTTOMRIGHT", -3, 0)

	local ItemButton = ItemDisplay.ItemButton
	ItemButton.CircleMask:Hide()

	GW.HandleIcon(ItemButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
	GW.HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	ItemButton:GetHighlightTexture():Hide()
end

local function HandleHeaders(frame)
	local maxHeaders = frame.HeaderContainer:GetNumChildren()
	for i, header in next, { frame.HeaderContainer:GetChildren() } do
		if not header.IsSkinned then
			header:DisableDrawLayer("BACKGROUND")

			if not header.backdrop then
				header:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
				header.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
			end

			header.IsSkinned = true
		end

		if header.backdrop then
			header.backdrop:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
		end
	end

	HandleListIcon(frame)
end

local function HandleTabs(arg1)
	if not arg1 or arg1 ~= AuctionHouseFrame then return end

	local lastTab = AuctionHouseFrameBuyTab
	for index, tab in next, AuctionHouseFrame.Tabs do
		if not tab.isSkinned then
			GW.HandleTabs(tab)
		end

		-- tab positions
		tab:ClearAllPoints()

		if index == 1 then
			tab:SetPoint("BOTTOMLEFT", AuctionHouseFrame, "BOTTOMLEFT", 0, -32)
		else -- skinned ones can be closer together
			tab:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", (tab.backdrop or tab.Backdrop) and -5 or 0, 0)
		end

		lastTab = tab
	end
end

local function HandleSellFrame(frame)
	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:GwStripTextures()
	ItemDisplay:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

	local ItemButton = ItemDisplay.ItemButton
	if ItemButton.IconMask then ItemButton.IconMask:Hide() end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	GW.HandleIcon(ItemButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
	GW.SkinTextBox(frame.QuantityInput.InputBox.Middle, frame.QuantityInput.InputBox.Left, frame.QuantityInput.InputBox.Right)
	frame.QuantityInput.MaxButton:GwSkinButton(false, true)
	GW.SkinTextBox(frame.PriceInput.MoneyInputFrame.GoldBox.Middle, frame.PriceInput.MoneyInputFrame.GoldBox.Left, frame.PriceInput.MoneyInputFrame.GoldBox.Right)
	GW.SkinTextBox(frame.PriceInput.MoneyInputFrame.SilverBox.Middle, frame.PriceInput.MoneyInputFrame.SilverBox.Left, frame.PriceInput.MoneyInputFrame.SilverBox.Right)

	if ItemButton.IconBorder then
		GW.HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	end

	if frame.SecondaryPriceInput then
		GW.SkinTextBox(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox.Middle, frame.SecondaryPriceInput.MoneyInputFrame.GoldBox.Left, frame.SecondaryPriceInput.MoneyInputFrame.GoldBox.Right)
		GW.SkinTextBox(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox.Middle, frame.SecondaryPriceInput.MoneyInputFrame.SilverBox.Left, frame.SecondaryPriceInput.MoneyInputFrame.SilverBox.Right)
		frame.SecondaryPriceInput.Label:SetTextColor(1, 1, 1)
	end

	frame.Duration.Dropdown:GwHandleDropDownBox()
	frame.PostButton:GwSkinButton(false, true)

	frame.CreateAuctionLabel:Hide()

	if frame.BuyoutModeCheckButton then
		frame.BuyoutModeCheckButton:GwSkinCheckButton()
		frame.BuyoutModeCheckButton:SetSize(20, 20)
		frame.BuyoutModeCheckButton.Text:SetTextColor(1, 1, 1)
	end
	if frame.QuantityInput then
		frame.QuantityInput.Label:SetTextColor(1, 1, 1)
	end

	frame.PriceInput.Label:SetTextColor(1, 1, 1)
	hooksecurefunc(frame.PriceInput.Label, "SetTextColor", function(self, r, g, b) if r ~=1 or g ~= 1 or b ~= 1 then self:SetTextColor(1, 1, 1) end end)
	frame.Duration.Label:SetTextColor(1, 1, 1)
	frame.Deposit.Label:SetTextColor(1, 1, 1)
	frame.TotalPrice.Label:SetTextColor(1, 1, 1)
end

local function HandleAuctionButtons(button)
	button:GwSkinButton(false, true)
	button:SetSize(22, 22)
	hooksecurefunc(button.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end)
end

local function AddListItemChildHoverTexture(child)
	child.Background = child:CreateTexture(nil, "BACKGROUND", nil, 7)
	child.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg")
	child.Background:ClearAllPoints()
	child.Background:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
	child.Background:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 0, 0)
	child.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
	child.HighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")

	child.HighlightTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
	child.HighlightTexture:GwSetInside(child.Background)

	child:HookScript("OnEnter",function()
		GW.TriggerButtonHoverAnimation(child, child.HighlightTexture)
	end)
end

local function HandleItemListScrollBoxHover(self)
	for _, child in next, { self.ScrollTarget:GetChildren() } do
		if not child.IsSkinned then
			AddListItemChildHoverTexture(child)

			child.IsSkinned = true
		end

		--zebra
		local zebra = child.GetOrderIndex and (child:GetOrderIndex() % 2) == 1 or false
		if zebra then
			child.Background:SetVertexColor(1, 1, 1, 1)
		else
			child.Background:SetVertexColor(0, 0, 0, 0)
		end

		if child.NormalTexture then
			child.NormalTexture:SetAlpha(0)
		end
		child.SelectedHighlight:SetColorTexture(0.5, 0.5, 0.5, .25)
	end
end

local function HookItemListScrollBoxHover(scrollBox)
	hooksecurefunc(scrollBox, "Update", HandleItemListScrollBoxHover)
end

local function HandleSummaryIcons(frame)
	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		if child.Icon then
			if not child.IsSkinned then
				GW.HandleIcon(child.Icon, true)

				child.Text:SetTextColor(255 / 255, 241 / 255, 209 / 255)

				if child.IconBorder then
					child.IconBorder:GwKill()
				end

				AddListItemChildHoverTexture(child)

				child.IsSkinned = true
			end
		end
	end
	HandleItemListScrollBoxHover(frame)
end

local function HandleTokenSellFrame(frame)
	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:GwStripTextures()
	ItemDisplay:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

	local ItemButton = ItemDisplay.ItemButton
	if ItemButton.IconMask then ItemButton.IconMask:Hide() end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	GW.HandleIcon(ItemButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)

	if ItemButton.IconBorder then
		GW.HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	end

	frame.PostButton:GwSkinButton(false, true)
	HandleAuctionButtons(frame.DummyRefreshButton)

	frame.DummyItemList:GwStripTextures()
	frame.DummyItemList:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
end

local function HandleSellList(frame, hasHeader, fitScrollBar)
	if frame.RefreshFrame then
		HandleAuctionButtons(frame.RefreshFrame.RefreshButton)
		frame.RefreshFrame.TotalQuantity:SetTextColor(1, 1, 1)
	end

	GW.HandleTrimScrollBar(frame.ScrollBar)
	GW.HandleScrollControls(frame)

	if frame.LoadingSpinner then
		frame.LoadingSpinner.SearchingText:SetTextColor(1, 1, 1)
	end

	if fitScrollBar then
		frame.ScrollBar:ClearAllPoints()
		frame.ScrollBar:SetPoint("TOPRIGHT", frame, -6, -16)
		frame.ScrollBar:SetPoint("BOTTOMRIGHT", frame, -6, 16)
	end

	if hasHeader then
		hooksecurefunc(frame, "RefreshScrollFrame", HandleHeaders)
		HookItemListScrollBoxHover(frame.ScrollBox)
	else
		hooksecurefunc(frame.ScrollBox, "Update", HandleSummaryIcons)
	end
end

local function AddDetailsBackground(frame)
	local detailBg = frame:CreateTexture(nil, "BACKGROUND", nil, 7)
	detailBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	detailBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	detailBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
	detailBg:SetTexCoord(0, 0.70703125, 0, 0.580078125)
	frame.tex = detailBg
end

local function SkinItem(item)
	if item.Icon and not item.backdrop then
		GW.HandleIcon(item.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
		GW.HandleIconBorder(item.IconBorder, item.Icon.backdrop)
		item.Icon:GwSetInside(item.backdrop)
		item.EmptySlot:Hide()
		item:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
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
			button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
			button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
			button:GetHighlightTexture():SetColorTexture(1, 0.93, 0.73, 0.25)
			button.HighlightTexture:GwKill()
			button:GetNormalTexture():GwSetInside()
			button:GetHighlightTexture():GwSetInside()
			button.Text:SetTextColor(1, 1, 1)
		end

		button.IsSkinned = true
	end
end

local function SkinAuctioneer()
	local lastTab = AuctionHouseFrameAuctionsTab

	C_Timer.After(0.2, function()
		local libAhTab = LibStub:GetLibrary("LibAHTab-1-0", true)
		-- skin tabs
		if Auctionator then
			if libAhTab then
				for _, details in ipairs(Auctionator.Tabs.State.knownTabs) do
					local tab = libAhTab:GetButton("AuctionatorTabs_" .. details.name)
					GW.HandleTabs(tab)

					-- tab positions
					tab:ClearAllPoints()
					tab:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", (tab.backdrop or tab.Backdrop) and -5 or 0, 0)

					lastTab = tab
				end
			end

			-- AuctionatorConfigFrame
			AuctionatorConfigFrame:GwStripTextures()
			AddDetailsBackground(AuctionatorConfigFrame)
			AuctionatorConfigFrame.OptionsButton:GwSkinButton(false, true)
			AuctionatorConfigFrame.ScanButton:GwSkinButton(false, true)
			GW.SkinTextBox(AuctionatorConfigFrame.DiscordLink.InputBox.Middle, AuctionatorConfigFrame.DiscordLink.InputBox.Left, AuctionatorConfigFrame.DiscordLink.InputBox.Right)
			GW.SkinTextBox(AuctionatorConfigFrame.BugReportLink.InputBox.Middle, AuctionatorConfigFrame.BugReportLink.InputBox.Left, AuctionatorConfigFrame.BugReportLink.InputBox.Right)
			AuctionatorConfigFrame.AuthorHeading.HeadingText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
			AuctionatorConfigFrame.ContributorsHeading.HeadingText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
			AuctionatorConfigFrame.VersionHeading.HeadingText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
			AuctionatorConfigFrame.EngageHeading.HeadingText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
			AuctionatorConfigFrame.TranslatorsHeading.HeadingText:SetTextColor(255 / 255, 241 / 255, 209 / 255)

			-- AuctionatorCancellingFrame
			AuctionatorCancellingFrame:GwStripTextures()
			AuctionatorCancellingFrame.ResultsListing:GwStripTextures()
			AuctionatorCancellingFrame.HistoricalPriceInset:GwStripTextures()
			AddDetailsBackground(AuctionatorCancellingFrame.HistoricalPriceInset)
			AuctionatorCancellingFrame.UndercutScanContainer.StartScanButton:GwSkinButton(false, true)
			AuctionatorCancellingFrame.UndercutScanContainer.CancelNextButton:GwSkinButton(false, true)
			AuctionatorCancelUndercutButton:GwSkinButton(false, true)
			GW.SkinTextBox(AuctionatorCancellingFrame.SearchFilter.Middle, AuctionatorCancellingFrame.SearchFilter.Left, AuctionatorCancellingFrame.SearchFilter.Right)
			HandleHeaders(AuctionatorCancellingFrame.ResultsListing)

			GW.HandleTrimScrollBar(AuctionatorCancellingFrame.ResultsListing.ScrollArea.ScrollBar)
    		GW.HandleScrollControls(AuctionatorCancellingFrame.ResultsListing.ScrollArea)
			hooksecurefunc(AuctionatorCancellingFrame.ResultsListing.ScrollArea.ScrollBox, "Update", HandleItemListScrollBoxHover)

			AuctionatorCancellingFrame.ResultsListing.ScrollArea.NoResultsText:SetTextColor(1, 1, 1)
			AuctionatorCancellingFrame.ResultsListing.ScrollArea.ResultsText:SetTextColor(1, 1, 1)

			-- undercut butttons, refresh button
			for _, child in next, {AuctionatorCancellingFrame:GetChildren()} do
				if child.iconAtlas == 'UI-RefreshButton' then
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
			AddDetailsBackground(selling.HistoricalPriceInset)
			AddDetailsBackground(selling.BagListing)
			selling.SaleItemFrame.MaxButton:GwSkinButton(false, true)
			selling.SaleItemFrame.PostButton:GwSkinButton(false, true)
			selling.SaleItemFrame.SkipButton:GwSkinButton(false, true)
			SkinItem(selling.SaleItemFrame.Icon)

			-- handle bag item icons
			hooksecurefunc(AuctionatorGroupsViewItemMixin, 'SetItemInfo', SetItemInfo)
			hooksecurefunc(AuctionatorGroupsViewGroupMixin, 'AddButton', SetGroupTitleFrame)

			GW.HandleTabs(selling.PricesTabsContainer.CurrentPricesTab)
			GW.HandleTabs(selling.PricesTabsContainer.RealmHistoryTab)
			GW.HandleTabs(selling.PricesTabsContainer.YourHistoryTab)
			GW.HandleTabs(selling.PricesTabsContainer.PriceHistoryTab)

			HandleHeaders(selling.CurrentPricesListing)
			HandleHeaders(selling.HistoricalPriceListing)
			HandleHeaders(selling.ResultsListing)

			GW.HandleTrimScrollBar(selling.CurrentPricesListing.ScrollArea.ScrollBar)
    		GW.HandleScrollControls(selling.CurrentPricesListing.ScrollArea)
			hooksecurefunc(selling.CurrentPricesListing.ScrollArea.ScrollBox, "Update", HandleItemListScrollBoxHover)

			GW.HandleTrimScrollBar(selling.HistoricalPriceListing.ScrollArea.ScrollBar)
    		GW.HandleScrollControls(selling.HistoricalPriceListing.ScrollArea)
			hooksecurefunc(selling.HistoricalPriceListing.ScrollArea.ScrollBox, "Update", HandleItemListScrollBoxHover)

			GW.HandleTrimScrollBar(selling.ResultsListing.ScrollArea.ScrollBar)
    		GW.HandleScrollControls(selling.ResultsListing.ScrollArea)
			hooksecurefunc(selling.ResultsListing.ScrollArea.ScrollBox, "Update", HandleItemListScrollBoxHover)

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
				if child.iconAtlas == 'UI-RefreshButton' then
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
		

		end
	end)
end

local function ApplyAuctionHouseSkin()
	if not GW.settings.AuctionHouseSkinEnabled then return end

	GW.HandlePortraitFrame(AuctionHouseFrame)

	AuctionHouseFrame.CategoriesList:GwStripTextures()
	AuctionHouseFrame.BrowseResultsFrame.ItemList:GwStripTextures()
	AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay:GwStripTextures()
	AuctionHouseFrame.CommoditiesBuyFrame.ItemList:GwStripTextures()
	AuctionHouseFrame.ItemBuyFrame.ItemList:GwStripTextures()
	AuctionHouseFrame.ItemSellFrame:GwStripTextures()
	AuctionHouseFrame.ItemSellList:GwStripTextures()
	AuctionHouseFrame.CommoditiesSellFrame:GwStripTextures()
	AuctionHouseFrame.CommoditiesSellList:GwStripTextures()
	AuctionHouseFrame.WoWTokenSellFrame:GwStripTextures()
	AuctionHouseFrameAuctionsFrame.CommoditiesList:GwStripTextures()
	AuctionHouseFrameAuctionsFrame.ItemList:GwStripTextures()
	AuctionHouseFrameAuctionsFrame.SummaryList:GwStripTextures()
	AuctionHouseFrameAuctionsFrame.AllAuctionsList:GwStripTextures()
	AuctionHouseFrameAuctionsFrame.BidsList:GwStripTextures()
	AuctionHouseFrame.WoWTokenResults:GwStripTextures()

	GW.CreateFrameHeaderWithBody(AuctionHouseFrame, AuctionHouseFrameTitleText, "Interface/AddOns/GW2_UI/textures/icons/auction-window-icon", {AuctionHouseFrame.CategoriesList,
								AuctionHouseFrame.BrowseResultsFrame,
								AuctionHouseFrame.CommoditiesBuyFrame,
								AuctionHouseFrame.CommoditiesBuyFrame.ItemList,
								AuctionHouseFrame.ItemBuyFrame,
								AuctionHouseFrame.ItemBuyFrame.ItemList,
								AuctionHouseFrame.ItemSellFrame,
								AuctionHouseFrame.ItemSellList,
								AuctionHouseFrame.CommoditiesSellFrame,
								AuctionHouseFrame.CommoditiesSellList,
								AuctionHouseFrame.WoWTokenSellFrame,
								AuctionHouseFrameAuctionsFrame.CommoditiesList,
								AuctionHouseFrameAuctionsFrame.ItemList,
								AuctionHouseFrameAuctionsFrame.SummaryList,
								AuctionHouseFrameAuctionsFrame.AllAuctionsList,
								AuctionHouseFrameAuctionsFrame.BidsList,
								AuctionHouseFrame.WoWTokenResults,
								})
	AuctionHouseFrame:SetWidth(810)

	hooksecurefunc("PanelTemplates_SetNumTabs", HandleTabs)
	HandleTabs(AuctionHouseFrame) -- call it once to setup our tabs

	--SearchBar Frame
	HandleSearchBarFrame(AuctionHouseFrame.SearchBar)
	AuctionHouseFrame.MoneyFrameBorder:GwStripTextures()
	AuctionHouseFrame.MoneyFrameInset:GwStripTextures()

	--Categorie List
	local Categories = AuctionHouseFrame.CategoriesList
	Categories.NineSlice:GwSetInside(Categories)
	GW.HandleTrimScrollBar(Categories.ScrollBar)
	GW.HandleScrollControls(Categories)

	local loaded = false
	hooksecurefunc(Categories.ScrollBox, "Update", function()
		--wait for load
		if not loaded then
			loaded = true
			Categories.ScrollBox.view:SetElementExtent(28)
		end
	end)
	Categories.ScrollBox:Update()

	hooksecurefunc("AuctionHouseFilterButton_SetUp", function(button) --TODO
		local r, g, b = 0.5, 0.5, 0.5
		button:SetHeight(28)
		button.NormalTexture:SetAlpha(0)
		button.NormalTexture:SetHeight(28)
		button.SelectedTexture:SetHeight(28)
		button.HighlightTexture:SetHeight(28)
		button.SelectedTexture:SetColorTexture(r, g, b, .25)
		button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
		button.Text:SetTextColor(255 / 255, 241 / 255, 209 / 255)
		if not button.IsSkinned then
			button.Background = button:CreateTexture(nil, "BACKGROUND", nil, 7)
			button.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg")
			button.Background:ClearAllPoints()
			button.Background:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
			button.Background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
			button.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
			button.HighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")

			button.HighlightTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
			button.HighlightTexture:GwSetInside(button.Background)

			button:HookScript("OnEnter",function()
				GW.TriggerButtonHoverAnimation(button, button.HighlightTexture)
			end)

			button.IsSkinned = true
		end

		--zebra
		local zebra = (button:GetOrderIndex() % 2) == 1 or false
		if zebra then
			button.Background:SetVertexColor(1, 1, 1, 1)
		else
			button.Background:SetVertexColor(0, 0, 0, 0)
		end
	end)


	--Browse Frame
	local Browse = AuctionHouseFrame.BrowseResultsFrame

	local BrowseList = Browse.ItemList
	hooksecurefunc(BrowseList, "RefreshScrollFrame", HandleHeaders)
	GW.HandleTrimScrollBar(BrowseList.ScrollBar)
	GW.HandleScrollControls(BrowseList)
	HookItemListScrollBoxHover(BrowseList.ScrollBox)
	BrowseList.ScrollBar:ClearAllPoints()
	BrowseList.ScrollBar:SetPoint("TOPRIGHT", BrowseList, -6, -16)
	BrowseList.ScrollBar:SetPoint("BOTTOMRIGHT", BrowseList, -6, 16)

	BrowseList.LoadingSpinner.SearchingText:SetTextColor(1, 1, 1)

	--BuyOut Frame
	local CommoditiesBuyFrame = AuctionHouseFrame.CommoditiesBuyFrame
	CommoditiesBuyFrame.BackButton:GwSkinButton(false, true)

	local CommoditiesBuyList = AuctionHouseFrame.CommoditiesBuyFrame.ItemList
	CommoditiesBuyList.RefreshFrame.RefreshButton:GwSkinButton(false, true)
	CommoditiesBuyList.RefreshFrame.RefreshButton.Icon:SetDesaturated(true)
	hooksecurefunc(CommoditiesBuyList.RefreshFrame.RefreshButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end) --TODO
	GW.HandleTrimScrollBar(CommoditiesBuyList.ScrollBar)
	GW.HandleScrollControls(CommoditiesBuyList)
	HookItemListScrollBoxHover(CommoditiesBuyList.ScrollBox)
	CommoditiesBuyList.RefreshFrame.TotalQuantity:SetTextColor(1, 1, 1)
	CommoditiesBuyList.LoadingSpinner.SearchingText:SetTextColor(1, 1, 1)

	local BuyDisplay = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay
	GW.SkinTextBox(BuyDisplay.QuantityInput.InputBox.Middle, BuyDisplay.QuantityInput.InputBox.Left, BuyDisplay.QuantityInput.InputBox.Right)
	BuyDisplay.BuyButton:GwSkinButton(false, true)

	BuyDisplay.QuantityInput.Label:SetTextColor(1, 1, 1)
	BuyDisplay.UnitPrice.Label:SetTextColor(1, 1, 1)
	BuyDisplay.TotalPrice.Label:SetTextColor(1, 1, 1)

	SkinItemDisplay(BuyDisplay)

	--ItemBuyOut Frame
	local ItemBuyFrame = AuctionHouseFrame.ItemBuyFrame
	ItemBuyFrame.BackButton:GwSkinButton(false, true)
	ItemBuyFrame.BuyoutFrame.BuyoutButton:GwSkinButton(false, true)

	SkinItemDisplay(ItemBuyFrame)

	local ItemBuyList = ItemBuyFrame.ItemList
	GW.HandleTrimScrollBar(ItemBuyList.ScrollBar)
	GW.HandleScrollControls(ItemBuyList)
	HookItemListScrollBoxHover(ItemBuyList.ScrollBox)
	ItemBuyList.RefreshFrame.RefreshButton:GwSkinButton(false, true)
	hooksecurefunc(ItemBuyList.RefreshFrame.RefreshButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end) --TODO
	hooksecurefunc(ItemBuyList, "RefreshScrollFrame", HandleHeaders)
	ItemBuyList.RefreshFrame.TotalQuantity:SetTextColor(1, 1, 1)
	ItemBuyList.LoadingSpinner.SearchingText:SetTextColor(1, 1, 1)

	local EditBoxes = {
		AuctionHouseFrameGold,
		AuctionHouseFrameSilver,
	}

	for _, EditBox in pairs(EditBoxes) do
		GW.SkinTextBox(_G[EditBox:GetName() .. "Middle"], _G[EditBox:GetName() .. "Left"], _G[EditBox:GetName() .. "Right"])
	end

	ItemBuyFrame.BidFrame.BidButton:GwSkinButton(false, true)
	ItemBuyFrame.BidFrame.BidButton:ClearAllPoints()
	ItemBuyFrame.BidFrame.BidButton:SetPoint("LEFT", ItemBuyFrame.BidFrame.BidAmount, "RIGHT", 2, -2)

	--Item Sell Frame - TAB 2
	local SellFrame = AuctionHouseFrame.ItemSellFrame
	HandleSellFrame(SellFrame)

	local ItemSellList = AuctionHouseFrame.ItemSellList
	HandleSellList(ItemSellList, true, true)

	local CommoditiesSellFrame = AuctionHouseFrame.CommoditiesSellFrame
	HandleSellFrame(CommoditiesSellFrame)

	local CommoditiesSellList = AuctionHouseFrame.CommoditiesSellList
	HandleSellList(CommoditiesSellList, true)

	local TokenSellFrame = AuctionHouseFrame.WoWTokenSellFrame
	HandleTokenSellFrame(TokenSellFrame)

	--Auctions Frame - TAB 3
	SkinItemDisplay(AuctionHouseFrameAuctionsFrame)
	AuctionHouseFrameAuctionsFrame.BuyoutFrame.BuyoutButton:GwSkinButton(false, true)

	local CommoditiesList = AuctionHouseFrameAuctionsFrame.CommoditiesList
	HandleSellList(CommoditiesList, true)
	CommoditiesList.RefreshFrame.RefreshButton:GwSkinButton(false, true)
	hooksecurefunc(CommoditiesList.RefreshFrame.RefreshButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end)

	local AuctionsList = AuctionHouseFrameAuctionsFrame.ItemList
	HandleSellList(AuctionsList, true)
	AuctionsList.RefreshFrame.RefreshButton:GwSkinButton(false, true)
	hooksecurefunc(AuctionsList.RefreshFrame.RefreshButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end)

	local AuctionsFrameTabs = {
		AuctionHouseFrameAuctionsFrameAuctionsTab,
		AuctionHouseFrameAuctionsFrameBidsTab,
	}

	for _, tab in pairs(AuctionsFrameTabs) do
		if tab then
			GW.HandleTabs(tab, true)
		end
	end

	local SummaryList = AuctionHouseFrameAuctionsFrame.SummaryList
	HandleSellList(SummaryList)
	AuctionHouseFrameAuctionsFrame.CancelAuctionButton:GwSkinButton(false, true)

	SummaryList.ScrollBar:ClearAllPoints()
	SummaryList.ScrollBar:SetPoint("TOPRIGHT", SummaryList, -5, -20)
	SummaryList.ScrollBar:SetPoint("BOTTOMRIGHT", SummaryList, -5, 20)

	local AllAuctionsList = AuctionHouseFrameAuctionsFrame.AllAuctionsList
	HandleSellList(AllAuctionsList, true, true)
	AllAuctionsList.RefreshFrame.RefreshButton:GwSkinButton(false, true)
	hooksecurefunc(AllAuctionsList.RefreshFrame.RefreshButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end)
	AllAuctionsList.ResultsText:SetParent(AllAuctionsList.ScrollFrame)

	SummaryList:SetPoint("BOTTOM", AuctionHouseFrameAuctionsFrame, 0, 0) -- normally this is anchored to the cancel button.. ? lol
	AuctionHouseFrameAuctionsFrame.CancelAuctionButton:ClearAllPoints()
	AuctionHouseFrameAuctionsFrame.CancelAuctionButton:SetPoint("TOPRIGHT", AllAuctionsList, "BOTTOMRIGHT", -6, 1)

	local BidsList = AuctionHouseFrameAuctionsFrame.BidsList
	HandleSellList(BidsList, true, true)
	BidsList.ResultsText:SetParent(BidsList.ScrollFrame)
	BidsList.RefreshFrame.RefreshButton:GwSkinButton(false, true)
	hooksecurefunc(BidsList.RefreshFrame.RefreshButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end)

	EditBoxes = {
		AuctionHouseFrameAuctionsFrameGold,
		AuctionHouseFrameAuctionsFrameSilver,
	}

	for _, EditBox in pairs(EditBoxes) do
		GW.SkinTextBox(_G[EditBox:GetName() .. "Middle"], _G[EditBox:GetName() .. "Left"], _G[EditBox:GetName() .. "Right"])
	end

	AuctionHouseFrameAuctionsFrame.BidFrame.BidButton:GwSkinButton(false, true)

	--WoW Token Category
	local TokenFrame = AuctionHouseFrame.WoWTokenResults
	TokenFrame.Buyout:GwSkinButton(false, true)
	GW.HandleTrimScrollBar(TokenFrame.DummyScrollBar)
	GW.HandleScrollControls(TokenFrame, "DummyScrollBar")

	local Token = TokenFrame.TokenDisplay
	Token:GwStripTextures()
	Token:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

	local ItemButton = Token.ItemButton
	GW.HandleIcon(ItemButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
	ItemButton.Icon.backdrop:SetBackdropBorderColor(0, .8, 1)
	ItemButton:GetHighlightTexture():Hide()
	ItemButton.CircleMask:Hide()
	ItemButton.IconBorder:GwKill()

	--WoW Token Tutorial Frame
	local WowTokenGameTimeTutorial = AuctionHouseFrame.WoWTokenResults.GameTimeTutorial
	WowTokenGameTimeTutorial.NineSlice:Hide()
	WowTokenGameTimeTutorial:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
	WowTokenGameTimeTutorial.CloseButton:GwSkinButton(true)
	WowTokenGameTimeTutorial.RightDisplay.StoreButton:GwSkinButton(false, true)
	WowTokenGameTimeTutorial.Bg:SetAlpha(0)
	WowTokenGameTimeTutorial.LeftDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(1, 0, 0)
	WowTokenGameTimeTutorial.RightDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(1, 0, 0)

	--Dialogs
	AuctionHouseFrame.BuyDialog:GwStripTextures()
	AuctionHouseFrame.BuyDialog:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
	AuctionHouseFrame.BuyDialog.BuyNowButton:GwSkinButton(false, true)
	AuctionHouseFrame.BuyDialog.CancelButton:GwSkinButton(false, true)

	--Multisell
	local multisellFrame = AuctionHouseMultisellProgressFrame
	multisellFrame:GwStripTextures()
	multisellFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

	local progressBar = multisellFrame.ProgressBar
	progressBar:GwStripTextures()
	progressBar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
	progressBar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white")

	progressBar.Text:ClearAllPoints()
	progressBar.Text:SetPoint("BOTTOM", progressBar, "TOP", 0, 5)

	multisellFrame.CancelButton:GwSkinButton(true)
	GW.HandleIcon(progressBar.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)

	-- Addmon Skins
	SkinAuctioneer()
end

local function LoadAuctionHouseSkin()
	GW.RegisterLoadHook(ApplyAuctionHouseSkin, "Blizzard_AuctionHouseUI", AuctionHouseFrame)
end
GW.LoadAuctionHouseSkin = LoadAuctionHouseSkin
