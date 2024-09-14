local _, GW = ...

local FRIENDS_FRAME_WHO_HEIGHT = 20

local Headers = {
    "ColumnHeader1",
    "ColumnHeader2",
    "ColumnHeader3",
    "ColumnHeader4",
}

local whoSortValue = 1

local function WhoList_Update()
    local scrollFrame = GwWhoWindow.list.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons
    local numWhos, totalCount = C_FriendList.GetNumWhoResults()
    local usedHeight = 0

    local displayedText = ""
    if totalCount > MAX_WHOS_FROM_SERVER then
        displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER)
    end
    GwWhoWindow.list.Totals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount) .. "  " .. displayedText)

    for i = 1, numButtons do
        local button = buttons[i]
        local zebra
        button.tooltip1 = nil
        button.tooltip2 = nil

        local index = offset + i;
        if index <= numWhos then
            local info = C_FriendList.GetWhoInfo(index)

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
            zebra = index % 2
            button.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)

            button.index = index

            button:Show()
            usedHeight = usedHeight + FRIENDS_FRAME_WHO_HEIGHT
        else
            button.index = nil
            button:Hide()
        end

        if GwWhoWindow.selectedWho == index then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end
    end

    local totalHeight = numWhos * FRIENDS_FRAME_WHO_HEIGHT
    HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight)

    if not GwWhoWindow.selectedWho then
        GwWhoWindow.list.InviteButton:Disable()
        GwWhoWindow.list.AddFriendButton:Disable()
    else
        GwWhoWindow.list.InviteButton:Enable()
        GwWhoWindow.list.AddFriendButton:Enable()

        local selectedWhoInfo = C_FriendList.GetWhoInfo(GwWhoWindow.selectedWho)
        if selectedWhoInfo then
            GwWhoWindow.selectedName = selectedWhoInfo.fullName
        else
            GwWhoWindow.selectedName = ""
        end
    end
end


local function WhoFrameDropdown_OnLoad(self)
    WowStyle1DropdownMixin.OnLoad(self)
    if not IsOnGlueScreen() then
		local function IsSelected(sortData)
			return sortData.value == whoSortValue;
		end

		local function SetSelected(sortData)
			whoSortValue = sortData.value;
			C_FriendList.SortWho(sortData.sortType);

			WhoList_Update()
		end

		self:SetWidth(101)
		self:SetupMenu(function(dropdown, rootDescription)
			rootDescription:CreateRadio(ZONE, IsSelected, SetSelected, {value = 1, sortType = "zone"});
			rootDescription:CreateRadio(GUILD, IsSelected, SetSelected, {value = 2, sortType = "guild"});
			rootDescription:CreateRadio(RACE, IsSelected, SetSelected, {value = 3, sortType = "race"});
		end);
	end
end

local function LoadWhoList(tabContainer)
    local WhoWindow = CreateFrame("Frame", "GwWhoWindow", tabContainer, "GwWhoWindow")

    WhoWindow:SetScript("OnLoad", function() C_FriendList.SetWhoToUi(false) end)
    WhoWindow:SetScript("OnShow", function() C_FriendList.SetWhoToUi(true) end)
    WhoWindow:SetScript("OnHide", function() C_FriendList.SetWhoToUi(false) end)
    WhoWindow:RegisterEvent("WHO_LIST_UPDATE")
    WhoWindow:SetScript("OnEvent", WhoList_Update)

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
        self.Text:SetTextColor(0, 0, 0)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    end)
    WhoWindow.list.ColumnHeader2.Dropdown:HookScript("OnMouseDown", function(self)
        self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        self.Text:SetShadowOffset(0, 0)
        self.Text:SetTextColor(0, 0, 0)
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
        if object ~= "ColumnHeader2" then WhoWindow.list[object]:GwSkinButton(false, true) end
    end

    WhoWindow.list.ColumnHeader2.Dropdown:SetSize(135, 24)
    WhoWindow.list.ColumnHeader2.Dropdown:GwStripTextures()
    WhoWindow.list.ColumnHeader2.Dropdown.tex = WhoWindow.list.ColumnHeader2.Dropdown:CreateTexture(nil, "ARTWORK")
    WhoWindow.list.ColumnHeader2.Dropdown.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button")
    WhoWindow.list.ColumnHeader2.Dropdown.tex:SetPoint("TOPLEFT", WhoWindow.list.ColumnHeader2.Dropdown, "TOPLEFT", 1, 0)
    WhoWindow.list.ColumnHeader2.Dropdown.tex:SetPoint("BOTTOMRIGHT", WhoWindow.list.ColumnHeader2.Dropdown, "BOTTOMRIGHT", -2, 0)
    WhoWindow.list.ColumnHeader2.Dropdown.Arrow:ClearAllPoints()
    WhoWindow.list.ColumnHeader2.Dropdown.Arrow:SetPoint("RIGHT", WhoWindow.list.ColumnHeader2.Dropdown, "RIGHT", -5, -3)
    WhoWindow.list.ColumnHeader2.Dropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    WhoWindow.list.ColumnHeader2.Dropdown.Text:SetShadowOffset(0, 0)
    WhoWindow.list.ColumnHeader2.Dropdown.Text:SetTextColor(0, 0, 0)
    WhoWindow.list.ColumnHeader2.Dropdown:GwSkinButton(false, false, true)
    WhoWindow.list.ColumnHeader2.Dropdown.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")

    WhoWindow.list.ColumnHeader2.Dropdown.hover:ClearAllPoints()
    WhoWindow.list.ColumnHeader2.Dropdown.hover:SetPoint("TOPLEFT", WhoWindow.list.ColumnHeader2.Dropdown, "TOPLEFT", 1, 0)
    WhoWindow.list.ColumnHeader2.Dropdown.hover:SetPoint("BOTTOMRIGHT", WhoWindow.list.ColumnHeader2.Dropdown, "BOTTOMRIGHT", -2, 0)

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

    WhoWindow.list.ScrollFrame.update = WhoList_Update
    WhoWindow.list.ScrollFrame.scrollBar.doNotHide = true
    HybridScrollFrame_CreateButtons(WhoWindow.list.ScrollFrame, "GW_WhoListButtonTemplate", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")

    for i = 1, #WhoWindow.list.ScrollFrame.buttons do
        local slot = WhoWindow.list.ScrollFrame.buttons[i]
        slot.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        slot.Variable:SetFont(UNIT_NAME_FONT, 11)
        slot.Level:SetFont(UNIT_NAME_FONT, 11)
        slot.Class:SetFont(UNIT_NAME_FONT, 11)

        if not slot.ScriptsHooked then
            slot:HookScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    GwWhoWindow.selectedWho = self.index
                    GwWhoWindow.selectedName = self.Name:GetText()
                    WhoList_Update()
                else
                    local name = self.Name:GetText()
                    FriendsFrame_ShowDropdown(name, 1)
                end
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end)
            slot:HookScript("OnEnter", function(self)
                if self.tooltip1 and self.tooltip2 then
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:SetText(self.tooltip1)
                    GameTooltip:AddLine(self.tooltip2, 1, 1, 1)
                    GameTooltip:Show();
                end
            end)
            slot:HookScript("OnLeave", GameTooltip_Hide)
            slot.ScriptsHooked = true
        end
    end

    WhoList_Update()


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