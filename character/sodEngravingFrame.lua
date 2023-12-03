local _, GW = ...

local function EngravingFrame_HideAllHeaders()
	local currentHeader = 1;
	local header = _G["GwEngravingFrameHeader"..currentHeader];
	while header do
		header:Hide();
		currentHeader = currentHeader + 1;
		header = _G["GwEngravingFrameHeader"..currentHeader];
	end
end

local function EngravingFrame_UpdateCollectedLabel(self)
	local label = self.collected.collectedText;

	if label then
		local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter();
		local known, max = C_Engraving.GetNumRunesKnown(exclusiveFilter);

		if exclusiveFilter then
			label:SetFormattedText(RUNES_COLLECTED_SLOT, known, max, GetItemInventorySlotInfo(exclusiveFilter));
		else
			label:SetFormattedText(RUNES_COLLECTED, known, max);
		end
	end
end

local function EngravingFrame_CalculateScroll(offset)
	local heightLeft = offset;

	local i = 1;
	local categories = C_Engraving.GetRuneCategories(true, true)
	for _, category in ipairs(categories) do

		if ( heightLeft - RUNE_HEADER_BUTTON_HEIGHT <= 0 ) then
			return i - 1, heightLeft;
		else
			heightLeft = heightLeft - RUNE_HEADER_BUTTON_HEIGHT
		end
		i = i + 1;

		local runes = C_Engraving.GetRunesForCategory(category, true);
		for _, rune in ipairs(runes) do
			if ( heightLeft - RUNE_BUTTON_HEIGHT <= 0 ) then
				return i - 1, heightLeft;
			else
				heightLeft = heightLeft - RUNE_BUTTON_HEIGHT
			end
			i = i + 1;
		end
	end
end

local function EngravingFrame_UpdateRuneList(self)
	local numHeaders = 0;
	local numRunes = 0;
	local scrollFrame = self.scrollFrame
	local buttons = scrollFrame.buttons
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local currOffset = 0;

	local currentHeader = 1
	EngravingFrame_HideAllHeaders()

	local currButton = 1
	local categories = C_Engraving.GetRuneCategories(true, true)
	numHeaders = #categories;
	for _, category in ipairs(categories) do
		if currOffset < offset then
			currOffset = currOffset + 1;
		else
			local button = buttons[currButton];
			if button then
				button:Hide()
				local header = _G["GwEngravingFrameHeader"..currentHeader];
				if header then
                    if not header.skinned then
                        header:StripTextures()
                        header:CreateBackdrop('Transparent')
                        header.skinned = true
                    end
					header:SetPoint("BOTTOM", button, 0 , 0);
					header:Show();
					header:SetParent(button:GetParent());
					currentHeader = currentHeader + 1;

					header.filter = category;
					header.name:SetText(GetItemInventorySlotInfo(category));

					if C_Engraving.HasCategoryFilter(category) then
						header.expandedIcon:Hide();
						header.collapsedIcon:Show();
					else
						header.expandedIcon:Show();
						header.collapsedIcon:Hide();
					end
					button:SetHeight(RUNE_HEADER_BUTTON_HEIGHT)
					currButton = currButton + 1
				end
			end
		end

		local runes = C_Engraving.GetRunesForCategory(category, true);
		numRunes = numRunes + #runes;
		for _, rune in ipairs(runes) do
			if currOffset < offset then
				currOffset = currOffset + 1;
			else
				local button = buttons[currButton];

				if button then
                    if not button.skinned then
                        button:SkinButton(false, true)
                        button.skinned = true
                    end
					button:SetHeight(RUNE_BUTTON_HEIGHT);
					button.icon:SetTexture(rune.iconTexture);
					button.tooltipName = rune.name;
					button.name:SetText(rune.name);
					button.skillLineAbilityID = rune.skillLineAbilityID;
					button.selectedTex:Hide();
					button:Show();
					currButton = currButton + 1;
				end
			end
		end
	end

	while currButton < #buttons do
		buttons[currButton]:Hide();

		currButton = currButton + 1;
	end

	local totalHeight = numRunes * RUNE_BUTTON_HEIGHT;
	totalHeight = totalHeight + (numHeaders * RUNE_HEADER_BUTTON_HEIGHT);
	HybridScrollFrame_Update(scrollFrame, totalHeight + 10, 348);

	if numHeaders == 0 and numRunes == 0 then
		scrollFrame.emptyText:Show();
	else
		scrollFrame.emptyText:Hide();
	end

	local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter();
	if exclusiveFilter then
		--UIDropDownMenu_SetText(EngravingFrameFilterDropDown, GetItemInventorySlotInfo(exclusiveFilter));
	else
		if C_Engraving.IsEquippedFilterEnabled() then
			--UIDropDownMenu_SetText(EngravingFrameFilterDropDown, EQUIPPED_RUNES);
		else
			--UIDropDownMenu_SetText(EngravingFrameFilterDropDown, ALL_RUNES);
		end
	end

	EngravingFrame_UpdateCollectedLabel(self);
end

function GwEngravingFrameSearchBox_OnShow(self)
	self:SetText(SEARCH);
	self:SetFontObject("GameFontDisable");
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	self:SetTextInsets(16, 0, 0, 0);
end

function GwEngravingFrameSearchBox_OnEditFocusLost(self)
	self:HighlightText(0, 0);
	if ( self:GetText() == "" ) then
		self:SetText(SEARCH);
		self:SetFontObject("GameFontDisable");
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	end
end

function GwEngravingFrameSearchBox_OnEditFocusGained(self)
	self:HighlightText();
	if ( self:GetText() == SEARCH ) then
		self:SetFontObject("ChatFontSmall");
		self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function GwEngravingFrameSearchBox_OnTextChanged(self)
	local text = self:GetText();

	if ( text == SEARCH ) then
		C_Engraving.SetSearchFilter("");
		return;
	end

	C_Engraving.SetSearchFilter(text);
	EngravingFrame_UpdateRuneList(_G["GwEngravingFrame"]);
end

local function EngravingFrame_OnShow(self)
	OpenAllBags(self)
	C_Engraving.RefreshRunesList()
	C_Engraving.SetSearchFilter("")

	EngravingFrame_UpdateRuneList(self)

	C_Engraving.SetEngravingModeEnabled(true)

	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("NEW_RECIPE_LEARNED")
end

local function EngravingFrame_OnHide (self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("NEW_RECIPE_LEARNED")

	C_Engraving.SetEngravingModeEnabled(false)
	CloseAllBags(self)
end

local function EngravingFrame_OnEvent(self, event)
	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		EngravingFrame_UpdateRuneList(self)
	elseif ( event == "NEW_RECIPE_LEARNED") then
		EngravingFrame_UpdateRuneList(self)
	end
end

function GwRuneHeader_OnClick (self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if C_Engraving.HasCategoryFilter(self.filter) then
		C_Engraving.ClearCategoryFilter(self.filter);
	else
		C_Engraving.AddCategoryFilter(self.filter);
	end

	EngravingFrame_UpdateRuneList(_G["GwEngravingFrame"]);
end

local function RuneFrameFilter_Modify(self, arg1)
	if(arg1 == ALL_RUNES_CATEGORY) then
		C_Engraving.ClearExclusiveCategoryFilter();
		C_Engraving.EnableEquippedFilter(false);
	elseif(arg1 == EQUIPPED_RUNES_CATEGORY) then
		C_Engraving.ClearExclusiveCategoryFilter();
		C_Engraving.EnableEquippedFilter(true);
	else
		C_Engraving.AddExclusiveCategoryFilter(arg1);
		C_Engraving.EnableEquippedFilter(false);
	end

	EngravingFrame_UpdateRuneList(_G["GwEngravingFrame"]);
end 

function GwRuneFrameFilter_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = RuneFrameFilter_Modify;
	
	info.text = ALL_RUNES;
	info.checked = C_Engraving.GetExclusiveCategoryFilter() == nil and not C_Engraving.IsEquippedFilterEnabled();
	info.arg1 = ALL_RUNES_CATEGORY;
	UIDropDownMenu_AddButton(info);

	info.text = EQUIPPED_RUNES;
	info.checked = C_Engraving.IsEquippedFilterEnabled();
	info.arg1 = EQUIPPED_RUNES_CATEGORY;
	UIDropDownMenu_AddButton(info);

	local categories = C_Engraving.GetRuneCategories(false, true);
	for _, category in ipairs(categories) do
		info.text = GetItemInventorySlotInfo(category);

		local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter();
		local checked = false;
		if(exclusiveFilter and exclusiveFilter == category) then
			checked = true;
		end
		info.checked = checked;
		info.arg1 = category;
		UIDropDownMenu_AddButton(info);
	end
end

local function LoadEngravingFrame()
    if not GW.ClassicSOD then return end
    if not C_AddOns.IsAddOnLoaded("Blizzard_EngravingUI") then
        UIParentLoadAddOn("Blizzard_EngravingUI")
    end

    local engravingFrame = GwEngravingFrame
    engravingFrame.scrollFrame.update = function() EngravingFrame_UpdateRuneList(engravingFrame) end
	engravingFrame.scrollFrame.scrollBar.doNotHide = true
	engravingFrame.scrollFrame.dynamic = EngravingFrame_CalculateScroll

	HybridScrollFrame_CreateButtons(engravingFrame.scrollFrame, "GwRuneSpellButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -1, "TOP", "BOTTOM")

    engravingFrame.dropdown:SkinDropDownMenu(80, nil, 80)

    engravingFrame:SetScript("OnShow", EngravingFrame_OnShow)
    engravingFrame:SetScript("OnHide", EngravingFrame_OnHide)
    engravingFrame:SetScript("OnEvent", EngravingFrame_OnEvent)
end
GW.LoadEngravingFrame = LoadEngravingFrame
