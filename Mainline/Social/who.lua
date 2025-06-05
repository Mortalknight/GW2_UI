local _, GW = ...

local Headers = {
    "ColumnHeader1",
    "ColumnHeader2",
    "ColumnHeader3",
    "ColumnHeader4",
}

local whoSortValue = 1
local C_Glue_IsOnGlueScreen = C_Glue and C_Glue.IsOnGlueScreen or IsOnGlueScreen

local function UpdateScrollBox(self)
    local dataProvider = CreateDataProvider()
    local numWhos, totalCount = C_FriendList.GetNumWhoResults()

    for index = 1, numWhos do
		local info = C_FriendList.GetWhoInfo(index);
		dataProvider:Insert({index = index, info = info})
	end
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    local displayedText = ""
    if totalCount > MAX_WHOS_FROM_SERVER then
        displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER)
    end
    GwWhoWindow.list.Totals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount) .. "  " .. displayedText)
end


local function WhoFrameDropdown_OnLoad(self)
    WowStyle1DropdownMixin.OnLoad(self)
    if not C_Glue_IsOnGlueScreen() then
		local function IsSelected(sortData)
			return sortData.value == whoSortValue;
		end

		local function SetSelected(sortData)
			whoSortValue = sortData.value;
			C_FriendList.SortWho(sortData.sortType);

			UpdateScrollBox(GwWhoWindow.list)
		end

		self:SetWidth(101)
		self:SetupMenu(function(dropdown, rootDescription)
			rootDescription:CreateRadio(ZONE, IsSelected, SetSelected, {value = 1, sortType = "zone"});
			rootDescription:CreateRadio(GUILD, IsSelected, SetSelected, {value = 2, sortType = "guild"});
			rootDescription:CreateRadio(RACE, IsSelected, SetSelected, {value = 3, sortType = "race"});
		end);
	end
end


local function Who_InitButton(button, elementData)
    local index = elementData.index
	local info = elementData.info

    if not button.isSkinned then
        button.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.Variable:SetFont(UNIT_NAME_FONT, 11)
        button.Level:SetFont(UNIT_NAME_FONT, 11)
        button.Class:SetFont(UNIT_NAME_FONT, 11)
        button.Selected:SetColorTexture(0.5, 0.5, 0.5, .5)
        button:HookScript("OnClick", function(self, btn)
            if btn == "LeftButton" then
                GwWhoWindow.selectedWho = self.index
                GwWhoWindow.selectedName = self.Name:GetText()
                UpdateScrollBox(GwWhoWindow.list)
            else
                local name = self.Name:GetText()
                FriendsFrame_ShowDropdown(name, 1)
            end
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end)
        button:HookScript("OnEnter", function(self)
            if self.tooltip1 and self.tooltip2 then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetText(self.tooltip1)
                GameTooltip:AddLine(self.tooltip2, 1, 1, 1)
                GameTooltip:Show();
            end
        end)
        button:HookScript("OnLeave", GameTooltip_Hide)
        GW.AddListItemChildHoverTexture(button)
        button.isSkinned = true
    end

    local classTextColor
    if info.filename then
        classTextColor = RAID_CLASS_COLORS[info.filename]
    else
        classTextColor = HIGHLIGHT_FONT_COLOR
    end

    button.Name:SetText(info.fullName)
    button.Level:SetText(info.level)
    button.Class:SetText(info.classStr)
    button.Class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)

    local variableColumnTable = { info.area, info.fullGuildName, info.raceStr }
    local variableText = variableColumnTable[whoSortValue]
    button.Variable:SetText(variableText)

    if button.Variable:IsTruncated() or button.Name:IsTruncated() then
        button.tooltip1 = info.fullName
        button.tooltip2 = variableText
    end

    -- set zebra color by idx or watch status
    local zebra = index % 2
    button.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
end

local function LoadWhoList(tabContainer)
    local WhoWindow = CreateFrame("Frame", "GwWhoWindow", tabContainer, "GwWhoWindow")

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GW_WhoListButtonTemplate", function(button, elementData)
        Who_InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(WhoWindow.list.ScrollBox, WhoWindow.list.ScrollBar, view)
    GW.HandleTrimScrollBar(WhoWindow.list.ScrollBar)
    GW.HandleScrollControls(WhoWindow.list)
    WhoWindow.list.ScrollBar:SetHideIfUnscrollable(true)

    WhoWindow:SetScript("OnLoad", function() C_FriendList.SetWhoToUi(false) end)
    WhoWindow:SetScript("OnShow", function() C_FriendList.SetWhoToUi(true) end)
    WhoWindow:SetScript("OnHide", function() C_FriendList.SetWhoToUi(false) end)
    WhoWindow:RegisterEvent("WHO_LIST_UPDATE")
    WhoWindow:SetScript("OnEvent", function() UpdateScrollBox(WhoWindow.list) end)

    WhoWindow.list.Totals:SetTextColor(1, 1, 1)

    -- Create Dropdown
    WhoWindow.list.ColumnHeader2.Dropdown = CreateFrame("DropdownButton", nil, WhoWindow.list.ColumnHeader2, "WowStyle1DropdownTemplate")
    WhoWindow.list.ColumnHeader2.Dropdown:SetPoint("TOPLEFT", WhoWindow.list.ColumnHeader2, "TOPLEFT", 0, 0)
    WhoWindow.list.ColumnHeader2.Dropdown.HighlightTexture = WhoWindow.list.ColumnHeader2.Dropdown:CreateTexture(nil, "OVERLAY")
    WhoWindow.list.ColumnHeader2.Dropdown.HighlightTexture:SetTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
    WhoWindow.list.ColumnHeader2.Dropdown.HighlightTexture:SetBlendMode("ADD")
    WhoWindow.list.ColumnHeader2.Dropdown.HighlightTexture:Hide()
    WhoWindow.list.ColumnHeader2.Dropdown.HighlightTexture:SetPoint("TOPLEFT")
    WhoWindow.list.ColumnHeader2.Dropdown.HighlightTexture:SetPoint("BOTTOMRIGHT")
    WhoWindow.list.ColumnHeader2.Dropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)

    WhoFrameDropdown_OnLoad(WhoWindow.list.ColumnHeader2.Dropdown)
    WhoWindow.list.ColumnHeader2.Dropdown:SetScript("OnShow", function() whoSortValue = 1 end)
    WhoWindow.list.ColumnHeader2.Dropdown:SetScript("OnEnter", function(self)
        self.HighlightTexture:Show()
    end)
    WhoWindow.list.ColumnHeader2.Dropdown:SetScript("OnLeave", function(self)
        self.HighlightTexture:Hide()
    end)
    WhoWindow.list.ColumnHeader2.Dropdown:HookScript("OnClick", function(self)
        self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        self.Text:SetShadowOffset(0, 0)
        self.Text:SetTextColor(1, 1, 1)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    end)
    WhoWindow.list.ColumnHeader2.Dropdown:HookScript("OnMouseDown", function(self)
        self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        self.Text:SetShadowOffset(0, 0)
        self.Text:SetTextColor(1, 1, 1)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    end)

    for _, object in pairs(Headers) do
        local frame = WhoWindow.list[object]
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            end
        end
    end

    for _, object in pairs(Headers) do
        GW.HandleScrollFrameHeaderButton(WhoWindow.list[object])
    end

    WhoWindow.list.ColumnHeader2.Dropdown:SetSize(135, 24)
    WhoWindow.list.ColumnHeader2.Dropdown:GwStripTextures()
    WhoWindow.list.ColumnHeader2.Dropdown.Arrow:ClearAllPoints()
    WhoWindow.list.ColumnHeader2.Dropdown.Arrow:SetPoint("RIGHT", WhoWindow.list.ColumnHeader2.Dropdown, "RIGHT", -5, -3)
    WhoWindow.list.ColumnHeader2.Dropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    WhoWindow.list.ColumnHeader2.Dropdown.Text:SetShadowOffset(0, 0)
    WhoWindow.list.ColumnHeader2.Dropdown.Text:SetTextColor(1, 1, 1)
    WhoWindow.list.ColumnHeader2.Dropdown.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")

    WhoWindow.list.InviteButton:SetScript("OnClick", function() C_PartyInfo.InviteUnit(WhoWindow.selectedName) end)
    WhoWindow.list.AddFriendButton:SetScript("OnClick", function() C_FriendList.AddFriend(WhoWindow.selectedName) end)
    WhoWindow.list.RefreshButton:SetScript("OnClick", function(self)
        WhoFrameEditBox_OnEnterPressed(self:GetParent().EditBox.input)
        self:GetParent():GetParent().selectedWho = nil
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

    WhoWindow.list.EditBox.input:SetScript("OnEnterPressed", WhoFrameEditBox_OnEnterPressed)
    WhoWindow.list.EditBox.input:SetScript("OnShow", EditBox_ClearFocus)
    WhoWindow.list.EditBox.input:SetScript("OnEscapePressed", EditBox_ClearFocus)

    UpdateScrollBox(WhoWindow.list)

    SlashCmdList["WHO"] = function(msg)
        if InCombatLockdown() then return end
        if (Kiosk.IsEnabled()) then
            return
        end
        if msg == "" then
            msg = WhoFrame_GetDefaultWhoCommand()
        end
        GwSocialWindow:SetAttribute("windowpanelopen", "wholist")

        GwWhoWindow.list.EditBox.input:SetText(msg)
        C_FriendList.SendWho(msg)
    end
end
GW.LoadWhoList = LoadWhoList