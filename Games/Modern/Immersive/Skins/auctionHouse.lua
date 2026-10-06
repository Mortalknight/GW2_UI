---@class GW2
local GW = select(2, ...)

GW.ActionHouseTabsAdded = 0

local function HandleSearchBarFrame(Frame)
	Frame.FilterButton:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, Frame.FilterButton:GetWidth())
	Frame.FilterButton:SetHeight(23)
	Frame.FilterButton.ClearFiltersButton:GwSkinButton(true)
	Frame.FilterButton:ClearAllPoints()
	Frame.FilterButton:SetPoint("LEFT", Frame.SearchBox, "RIGHT", 5, 2)

	Frame.SearchBox:ClearAllPoints()
	Frame.SearchBox:SetPoint("LEFT", Frame.FavoritesSearchButton, "RIGHT", 9, -1)

	Frame.SearchButton:GwSkinButton(false, true)
	GW.SkinTextBox(Frame.SearchBox.Middle, Frame.SearchBox.Left, Frame.SearchBox.Right)
	Frame.FavoritesSearchButton:GwSkinButton(false, true)
	Frame.FavoritesSearchButton.Icon:SetDesaturated(true)
	hooksecurefunc(Frame.FavoritesSearchButton.Icon, "SetDesaturated", function(self, value) if value == false then self:SetDesaturated(true) end end) --TODO
	Frame.FavoritesSearchButton:SetSize(22, 23)
	Frame.FavoritesSearchButton:ClearAllPoints()
	Frame.FavoritesSearchButton:SetPoint("LEFT", 0, 0)
end

local ACTION_PRESSED = "Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png"

local function SetWhite(text)
	if text then
		text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
	end
end

-- Blizzard colors the refresh and favorite icons on hover, ours stay grey
local function KeepDesaturated(icon, desaturated)
	if not desaturated then
		icon:SetDesaturated(true)
	end
end

local function SkinIconButton(button, size)
	button:GwSkinButton(false, true)
	if size then
		button:SetSize(size, size)
	end
	button.Icon:SetDesaturated(true)
	hooksecurefunc(button.Icon, "SetDesaturated", KeepDesaturated)
end

-- the bid input of both bid frames is globally named "BidAmount" twice, so it goes by its keys.
-- blizzards box art goes, our text box builds its own with all four edges
local function SkinBidAmount(bidAmount)
	for _, box in ipairs({ bidAmount.gold, bidAmount.silver, bidAmount.copper }) do
		for _, region in ipairs({ box:GetRegions() }) do
			if region:IsObjectType("Texture") and region ~= box.texture then
				region:SetAlpha(0)
			end
		end
		GW.SkinTextBox(nil, nil, nil, nil, nil, nil, nil, nil, box)
	end
end

-- right to left: buyout, bid next to it, the bid boxes before that. blizzards boxes are wider than
-- their frame, so they are measured: three boxes with 10 between them, copper only when shown
local function LayoutBidRow(bidFrame, buyoutButton)
	local bidAmount = bidFrame.BidAmount
	local width = bidAmount.gold:GetWidth() + 10 + bidAmount.silver:GetWidth()
	if bidAmount.copper:IsShown() then
		width = width + 10 + bidAmount.copper:GetWidth()
	end
	bidFrame.BidButton:ClearAllPoints()
	bidFrame.BidButton:SetPoint("RIGHT", buyoutButton, "LEFT", -2, 0)
	bidAmount:ClearAllPoints()
	bidAmount:SetPoint("LEFT", bidFrame.BidButton, "LEFT", -(width + 6), 0)
end

local function SkinMoneyInput(moneyInput)
	-- retail hides the copper box for auctions, forever shows it
	for _, box in ipairs({ moneyInput.GoldBox, moneyInput.SilverBox, moneyInput.CopperBox }) do
		GW.SkinTextBox(box.Middle, box.Left, box.Right)
	end
end

-- the item shown above a panel: the buy panels show it, the sell panels take it as a drop slot
local function SkinItemDisplay(display, isDropSlot)
	display:GwStripTextures()
	display:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

	local button = display.ItemButton
	if isDropSlot then
		if button.IconMask then
			button.IconMask:Hide()
		end
		button.EmptyBackground:Hide()
		button:SetPushedTexture(ACTION_PRESSED)
		button.Highlight:SetColorTexture(GW.Colors.SkinColors.HighlightWhite:GetRGBA())
		button.Highlight:SetAllPoints(button.Icon)
	else
		display.backdrop:SetPoint("TOPLEFT", 3, -3)
		display.backdrop:SetPoint("BOTTOMRIGHT", -3, 0)
		button.CircleMask:Hide()
		button:GetHighlightTexture():Hide()
	end

	GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
	if button.IconBorder then
		GW.HandleIconBorder(button.IconBorder, button.Icon.backdrop)
	end
end

local function HandleTabs(arg1)
	if not arg1 or arg1 ~= AuctionHouseFrame then return end

	for index, tab in next, AuctionHouseFrame.Tabs do
		if not tab.gwSkinned then
			local id = index == 1 and "buy" or index == 2 and "sell" or "listings"
			local iconTexture = "Interface/AddOns/GW2_UI/textures/Auction/tabicon_" .. id .. ".png"
			GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
		end

		tab:ClearAllPoints()
		tab:SetPoint("TOPRIGHT", AuctionHouseFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * GW.ActionHouseTabsAdded))
		tab:SetParent(AuctionHouseFrame.LeftSidePanel)
		tab:SetSize(64, 40)
		GW.ActionHouseTabsAdded = GW.ActionHouseTabsAdded + 1
	end
end

-- blizzard colors the price labels yellow, or red when the buyout is not above the bid; the red stays
local function KeepPriceLabelWhite(priceInput, color)
	if color ~= RED_FONT_COLOR then
		SetWhite(priceInput.Label)
		SetWhite(priceInput.LabelTitle)
	end
end

local function SkinPriceInput(priceInput)
	SkinMoneyInput(priceInput.MoneyInputFrame)
	KeepPriceLabelWhite(priceInput)
	hooksecurefunc(priceInput, "SetLabelColor", KeepPriceLabelWhite)
end

local function SkinSellFrame(frame)
	SkinItemDisplay(frame.ItemDisplay, true)

	local quantity = frame.QuantityInput
	GW.SkinTextBox(quantity.InputBox.Middle, quantity.InputBox.Left, quantity.InputBox.Right)
	quantity.MaxButton:GwSkinButton(false, true)
	SetWhite(quantity.Label)
	SkinPriceInput(frame.PriceInput)
	if frame.SecondaryPriceInput then
		SkinPriceInput(frame.SecondaryPriceInput)
	end

	frame.Duration.Dropdown:GwHandleDropDownBox()
	frame.PostButton:GwSkinButton(false, true)
	frame.CreateAuctionLabel:Hide()
	if frame.BuyoutModeCheckButton then
		frame.BuyoutModeCheckButton:GwSkinCheckButton(false, 20)
		SetWhite(frame.BuyoutModeCheckButton.Text)
		-- blizzards template pulls the label 2px into the box, our check runs out of it
		frame.BuyoutModeCheckButton.Text:ClearAllPoints()
		frame.BuyoutModeCheckButton.Text:SetPoint("LEFT", frame.BuyoutModeCheckButton, "RIGHT", 6, 0)
	end

	for _, text in ipairs({ frame.PriceInput.Label, frame.Duration.Label, frame.Deposit.Label, frame.TotalPrice.Label }) do
		SetWhite(text)
	end
	-- Blizzard tints the price label red for invalid prices
	hooksecurefunc(frame.PriceInput.Label, "SetTextColor", function(label, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			SetWhite(label)
		end
	end)
end

local function SkinTokenSellFrame(frame)
	SkinItemDisplay(frame.ItemDisplay, true)
	frame.PostButton:GwSkinButton(false, true)
	SkinIconButton(frame.DummyRefreshButton, 22)
	frame.DummyItemList:GwStripTextures()
	frame.DummyItemList:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
end

local function HandleSummaryIcons(frame)
	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		if child.Icon then
			if not child.gwSkinned then
				GW.HandleIcon(child.Icon, true)

				child.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

				if child.IconBorder then
					child.IconBorder:GwKill()
				end

				GW.AddListItemChildHoverTexture(child)

				child.gwSkinned = true
			end
		end
	end
	GW.HandleItemListScrollBoxHover(frame)
end

-- options: headers (sortable columns), summary (icon list without columns),
-- scrollBarInset {x, y} and smallRefresh for the 22px refresh buttons of the own auctions
local function SkinList(list, options)
	GW.HandleTrimScrollBar(list.ScrollBar)
	list.ScrollBar:SetHideIfUnscrollable(true)
	GW.HandleScrollControls(list)
	if options.scrollBarInset then
		local x, y = unpack(options.scrollBarInset)
		list.ScrollBar:ClearAllPoints()
		list.ScrollBar:SetPoint("TOPRIGHT", list, -x, -y)
		list.ScrollBar:SetPoint("BOTTOMRIGHT", list, -x, y)
	end

	if list.RefreshFrame then
		SkinIconButton(list.RefreshFrame.RefreshButton, options.smallRefresh and 22)
		SetWhite(list.RefreshFrame.TotalQuantity)
	end
	-- the hint and the no results text, blizzard only changes its text
	if list.ResultsText then
		list.ResultsText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
	end
	if list.LoadingSpinner then
		SetWhite(list.LoadingSpinner.SearchingText)
	end

	if options.headers then
		hooksecurefunc(list, "RefreshScrollFrame", GW.HandleSrollBoxHeaders)
	end
	if options.summary then
		hooksecurefunc(list.ScrollBox, "Update", HandleSummaryIcons)
	else
		hooksecurefunc(list.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
	end
end

-- the details background of wide lists starts 2px in, next to the categories
local function FitListBackground(list)
	list.tex:ClearAllPoints()
	list.tex:SetPoint("TOPLEFT", list, "TOPLEFT", 2, 0)
	list.tex:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", 0, 0)
end

local function SkinDialog(frame)
	frame:GwStripTextures()
	frame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
end

local function ApplyAuctionHouseSkin()
	if not GW.settings.skins.auctionHouse.enabled then return end

	GW.HandlePortraitFrame(AuctionHouseFrame)
	AuctionHouseFrame.CloseButton:SetPoint("TOPRIGHT", -5, -2)

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

	GW.CreateFrameHeaderWithBody(AuctionHouseFrame, AuctionHouseFrameTitleText, "Interface/AddOns/GW2_UI/textures/icons/auction-window-icon.png", {AuctionHouseFrame.CategoriesList,
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
								}
								, nil, true, true)
	AuctionHouseFrame:SetWidth(810)
	AuctionHouseFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/Auction/windowbg.png")
	AuctionHouseFrame.tex:SetTexCoord(0, 1, 0, 0.74)
	AuctionHouseFrame.gwHeader.windowIcon:ClearAllPoints()
	AuctionHouseFrame.gwHeader.windowIcon:SetPoint("CENTER", AuctionHouseFrame.gwHeader, "BOTTOMLEFT", -26, 35)
	AuctionHouseFrameTitleText:ClearAllPoints()
	AuctionHouseFrameTitleText:SetPoint("BOTTOMLEFT", AuctionHouseFrame.gwHeader, "BOTTOMLEFT", 25, 10)
	AuctionHouseFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
	AuctionHouseFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

	AuctionHouseFrame:SetClampedToScreen(true)
	AuctionHouseFrame:SetClampRectInsets(-40, 0, AuctionHouseFrame.gwHeader:GetHeight() - 30, 0)

	hooksecurefunc("PanelTemplates_SetNumTabs", HandleTabs)
	HandleTabs(AuctionHouseFrame) -- call it once to setup our tabs

	--SearchBar Frame
	HandleSearchBarFrame(AuctionHouseFrame.SearchBar)
	AuctionHouseFrame.MoneyFrameBorder:GwStripTextures()
	AuctionHouseFrame.MoneyFrameInset:GwStripTextures()
	-- our gold sits in the bottom of the left panel of each page, in the font and coin colors of our bags;
	-- blizzard may set its price font again, so the look is kept by a hook
	local money = AuctionHouseFrame.MoneyFrameBorder.MoneyFrame
	local function PlaceMoney()
		local anchor = AuctionHouseFrame.CategoriesList
		for _, panel in ipairs({ AuctionHouseFrameAuctionsFrame.SummaryList, AuctionHouseFrame.ItemSellFrame, AuctionHouseFrame.CommoditiesSellFrame }) do
			if panel:IsVisible() then
				anchor = panel
				break
			end
		end
		money:ClearAllPoints()
		money:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -8, 10)
	end
	hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", PlaceMoney)
	PlaceMoney()
	for key, coin in pairs({ GoldDisplay = "Gold", SilverDisplay = "Silver", CopperDisplay = "Copper" }) do
		local display = money[key]
		local function StyleCoin()
			GW.StyleMoneyText(display.Text, coin)
			display:UpdateWidth()
		end
		StyleCoin()
		hooksecurefunc(display, "SetFontObject", StyleCoin)
	end

	--Categorie List
	local Categories = AuctionHouseFrame.CategoriesList
	Categories.NineSlice:GwSetInside(Categories)
	-- the lists keep their size (the results hang on their bottom), their scroll areas make room for the gold
	Categories.ScrollBox:SetPoint("BOTTOMRIGHT", Categories, "BOTTOMRIGHT", -25, 32)
	local summaryList = AuctionHouseFrameAuctionsFrame.SummaryList
	summaryList.ScrollBox:SetPoint("BOTTOMRIGHT", summaryList, "BOTTOMRIGHT", -27, 32)
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

	local HasCategorySubCategories = function (catIdx, catType)
		local selectedCategoryIndex = Categories:GetSelectedCategory()
		if catType == "category" then
			return AuctionCategories[catIdx] and AuctionCategories[catIdx].subCategories and #AuctionCategories[catIdx].subCategories > 0
		elseif catType == "subCategory" then
			return AuctionCategories[selectedCategoryIndex].subCategories[catIdx] and AuctionCategories[selectedCategoryIndex].subCategories[catIdx].subCategories and #AuctionCategories[selectedCategoryIndex].subCategories[catIdx] .subCategories > 0
		end
		return false
	end

	hooksecurefunc("AuctionHouseFilterButton_SetUp", function(button, info)
		local r, g, b = 0.5, 0.5, 0.5

		if not button.gwSkinned then
			button.Background = button:CreateTexture(nil, "BACKGROUND", nil, 0)
			button.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
			button.Background:ClearAllPoints()
			button.Background:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
			button.Background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
			button.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
			button.HighlightTexture:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
			button.HighlightTexture:GwSetInside(button.Background)

			button:HookScript("OnEnter",function()
				GW.TriggerButtonHoverAnimation(button, button.HighlightTexture)
			end)

			-- add arrows
			button.arrow = button:CreateTexture(nil, "BACKGROUND", nil, 1)
			button.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
			button.arrow:SetSize(16,16)
			button.arrow:Hide()

			button.gwSkinned = true
		end

		button:SetHeight(28)
		button.NormalTexture:SetAlpha(0)
		button.NormalTexture:SetHeight(28)
		button.SelectedTexture:SetHeight(28)
		button.HighlightTexture:SetHeight(28)
		button.SelectedTexture:SetColorTexture(r, g, b, .25)
		button.SelectedTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
		button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
		button.HighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")

		button.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
		button.Text:SetShadowColor(0, 0, 0, 0)
		button.Text:SetShadowOffset(1, -1)
		button.Text:SetFont(DAMAGE_TEXT_FONT, 13)
		button.Text:SetJustifyH("LEFT")
		button.Text:SetJustifyV("MIDDLE")
		button.Text:ClearAllPoints()

		if info.type == "category" then
			button.arrow:ClearAllPoints()
			button.arrow:SetPoint("LEFT", 0, 0)
			button.Text:SetPoint("LEFT", 15, 0)
		elseif info.type == "subCategory" then
			button.arrow:ClearAllPoints()
			button.arrow:SetPoint("LEFT", 10, 0)
			button.Text:SetPoint("LEFT", 25, 0)
		else
			button.Text:SetPoint("LEFT", 30, 0)
		end

		if info.selected then
			button.arrow:SetRotation(-1.5707)
		else
			button.arrow:SetRotation(0)
		end
		-- show the arrow only if there are sub categories
		button.arrow:SetShown(HasCategorySubCategories((info.categoryIndex or info.subCategoryIndex), info.type))
		button.Lines:Hide()

		--zebra
		local zebra = (button:GetOrderIndex() % 2) == 1 or false
		if zebra then
			button.Background:SetVertexColor(GW.Colors.FallbackWhite:GetRGBA())
		else
			button.Background:SetVertexColor(GW.Colors.Transparent:GetRGBA())
		end
	end)

	-- browse and buy (tab 1)
	local browse = AuctionHouseFrame.BrowseResultsFrame
	SkinList(browse.ItemList, { headers = true, scrollBarInset = { 6, 16 } })
	FitListBackground(browse)

	local commoditiesBuy = AuctionHouseFrame.CommoditiesBuyFrame
	commoditiesBuy.BackButton:GwSkinButton(false, true)
	SkinList(commoditiesBuy.ItemList, {})
	local buyDisplay = commoditiesBuy.BuyDisplay
	SkinItemDisplay(buyDisplay.ItemDisplay)
	GW.SkinTextBox(buyDisplay.QuantityInput.InputBox.Middle, buyDisplay.QuantityInput.InputBox.Left, buyDisplay.QuantityInput.InputBox.Right)
	buyDisplay.BuyButton:GwSkinButton(false, true)
	for _, text in ipairs({ buyDisplay.QuantityInput.Label, buyDisplay.UnitPrice.Label, buyDisplay.TotalPrice.Label }) do
		SetWhite(text)
	end

	local itemBuy = AuctionHouseFrame.ItemBuyFrame
	itemBuy.BackButton:GwSkinButton(false, true)
	itemBuy.BuyoutFrame.BuyoutButton:GwSkinButton(false, true)
	SkinItemDisplay(itemBuy.ItemDisplay)
	SkinList(itemBuy.ItemList, { headers = true })
	SkinBidAmount(itemBuy.BidFrame.BidAmount)
	itemBuy.BidFrame.BidButton:GwSkinButton(false, true)
	LayoutBidRow(itemBuy.BidFrame, itemBuy.BuyoutFrame.BuyoutButton)

	-- sell (tab 2)
	SkinSellFrame(AuctionHouseFrame.ItemSellFrame)
	SkinSellFrame(AuctionHouseFrame.CommoditiesSellFrame)
	SkinTokenSellFrame(AuctionHouseFrame.WoWTokenSellFrame)
	SkinList(AuctionHouseFrame.ItemSellList, { headers = true, scrollBarInset = { 6, 16 }, smallRefresh = true })
	FitListBackground(AuctionHouseFrame.ItemSellList)
	SkinList(AuctionHouseFrame.CommoditiesSellList, { headers = true, smallRefresh = true })

	-- own auctions and bids (tab 3)
	local auctions = AuctionHouseFrameAuctionsFrame
	SkinItemDisplay(auctions.ItemDisplay)
	auctions.BuyoutFrame.BuyoutButton:GwSkinButton(false, true)
	auctions.BidFrame.BidButton:GwSkinButton(false, true)
	auctions.CancelAuctionButton:GwSkinButton(false, true)
	auctions.CancelAuctionButton:GwSkinNegativeButton()
	SkinBidAmount(auctions.BidFrame.BidAmount)
	LayoutBidRow(auctions.BidFrame, auctions.BuyoutFrame.BuyoutButton)
	for _, tab in ipairs({ AuctionHouseFrameAuctionsFrameAuctionsTab, AuctionHouseFrameAuctionsFrameBidsTab }) do
		GW.HandleTabs(tab, "top")
	end

	SkinList(auctions.CommoditiesList, { headers = true, smallRefresh = true })
	SkinList(auctions.ItemList, { headers = true, smallRefresh = true })
	SkinList(auctions.SummaryList, { summary = true, scrollBarInset = { 5, 20 }, smallRefresh = true })
	auctions.SummaryList.ScrollBar:SetPoint("BOTTOMRIGHT", auctions.SummaryList, -5, 36)
	for _, list in ipairs({ auctions.AllAuctionsList, auctions.BidsList }) do
		SkinList(list, { headers = true, scrollBarInset = { 6, 16 }, smallRefresh = true })
		FitListBackground(list)
	end
	-- Blizzard anchors the summary above the cancel button, which now sits below the list
	auctions.SummaryList:SetPoint("BOTTOM", auctions, 0, 0)
	auctions.CancelAuctionButton:ClearAllPoints()
	auctions.CancelAuctionButton:SetPoint("TOPRIGHT", auctions.AllAuctionsList, "BOTTOMRIGHT", -6, 1)

	-- WoW token
	local tokenResults = AuctionHouseFrame.WoWTokenResults
	tokenResults.Buyout:GwSkinButton(false, true)
	GW.HandleTrimScrollBar(tokenResults.DummyScrollBar)
	GW.HandleScrollControls(tokenResults, "DummyScrollBar")
	tokenResults.DummyScrollBar:SetHideIfUnscrollable(true)
	SkinDialog(tokenResults.TokenDisplay)
	local tokenButton = tokenResults.TokenDisplay.ItemButton
	GW.HandleIcon(tokenButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)
	tokenButton.Icon.backdrop:SetBackdropBorderColor(GW.Colors.SkinColors.TokenBorder:GetRGB())
	tokenButton:GetHighlightTexture():Hide()
	tokenButton.CircleMask:Hide()
	tokenButton.IconBorder:SetAlpha(0)

	local tutorial = tokenResults.GameTimeTutorial
	tutorial.NineSlice:Hide()
	tutorial.Bg:SetAlpha(0)
	tutorial:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
	tutorial.CloseButton:GwSkinButton(true)
	tutorial.RightDisplay.StoreButton:GwSkinButton(false, true)
	for _, display in ipairs({ tutorial.LeftDisplay, tutorial.RightDisplay }) do
		SetWhite(display.Label)
		display.Tutorial1:SetTextColor(GW.Colors.SkinColors.Negative:GetRGB())
	end

	-- dialogs
	SkinDialog(AuctionHouseFrame.BuyDialog)
	AuctionHouseFrame.BuyDialog.BuyNowButton:GwSkinButton(false, true)
	AuctionHouseFrame.BuyDialog.CancelButton:GwSkinButton(false, true)

	local multisell = AuctionHouseMultisellProgressFrame
	SkinDialog(multisell)
	multisell.CancelButton:GwSkinButton(true)
	local progressBar = multisell.ProgressBar
	progressBar:GwStripTextures()
	progressBar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
	progressBar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white.png")
	progressBar.Text:ClearAllPoints()
	progressBar.Text:SetPoint("BOTTOM", progressBar, "TOP", 0, 5)
	GW.HandleIcon(progressBar.Icon, true, GW.BackdropTemplates.ColorableBorderOnly)

	GW.MakeFrameMovable(AuctionHouseFrame, nil, "auctionHouse", true)
end

local function LoadAuctionHouseSkin()
	GW.RegisterLoadHook(ApplyAuctionHouseSkin, "Blizzard_AuctionHouseUI", AuctionHouseFrame)
end
GW.LoadAuctionHouseSkin = LoadAuctionHouseSkin
