local _, GW = ...

local FRIENDS_FRAME_WHO_HEIGHT = 20

local Headers = {
    "ColumnHeader1",
    "ColumnHeader2",
    "ColumnHeader3",
    "ColumnHeader4",
}

local WHOFRAME_DROPDOWN_LIST = {
    {name = ZONE, sortType = "zone"},
    {name = GUILD, sortType = "guild"},
    {name = RACE, sortType = "race"}
}

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
            local variableText = variableColumnTable[UIDropDownMenu_GetSelectedID(GwWhoWindow.list.ColumnHeader2.DropDown)]
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


local function WhoWindowDropDownButton_OnClick(self)
    UIDropDownMenu_SetSelectedID(GwWhoWindow.list.ColumnHeader2.DropDown, self:GetID())
    WhoList_Update()
end

local function WhoWindowDropDown_Initialize()
    local info = UIDropDownMenu_CreateInfo()
    for i=1, getn(WHOFRAME_DROPDOWN_LIST), 1 do
        info.text = WHOFRAME_DROPDOWN_LIST[i].name
        info.func = WhoWindowDropDownButton_OnClick
        info.checked = nil
        UIDropDownMenu_AddButton(info)
    end
end

local function LoadWhoList(tabContainer)
    local WhoWindow = CreateFrame("Frame", "GwWhoWindow", tabContainer, "GwWhoWindow")

    WhoWindow:SetScript("OnLoad", function() C_FriendList.SetWhoToUi(false) end)
    WhoWindow:SetScript("OnShow", function() C_FriendList.SetWhoToUi(true) end)
    WhoWindow:SetScript("OnHide", function() C_FriendList.SetWhoToUi(false) end)
    WhoWindow:RegisterEvent("WHO_LIST_UPDATE")
    WhoWindow:SetScript("OnEvent", WhoList_Update)

    WhoWindow.list.ColumnHeader2.DropDown.Text:SetFont(UNIT_NAME_FONT, 12)
    UIDropDownMenu_Initialize(WhoWindow.list.ColumnHeader2.DropDown, WhoWindowDropDown_Initialize)
    UIDropDownMenu_SetWidth(WhoWindow.list.ColumnHeader2.DropDown, 80)
    UIDropDownMenu_SetButtonWidth(WhoWindow.list.ColumnHeader2.DropDown, 24)
    UIDropDownMenu_JustifyText(WhoWindow.list.ColumnHeader2.DropDown, "LEFT")

    WhoWindow.list.ColumnHeader2.DropDown:SetScript("OnShow", function(self)
        UIDropDownMenu_Initialize(self, WhoWindowDropDown_Initialize)
        UIDropDownMenu_SetSelectedID(self, 1)
    end)
    WhoWindow.list.ColumnHeader2.DropDown:SetScript("OnEnter", function(self)
        self.HighlightTexture:Show()
    end)
    WhoWindow.list.ColumnHeader2.DropDown:SetScript("OnLeave", function(self)
        self.HighlightTexture:Hide()
    end)
    WhoWindow.list.ColumnHeader2.DropDown:SetScript("OnMouseUp", function(self)
        if WHOFRAME_DROPDOWN_LIST[UIDropDownMenu_GetSelectedID(self)].sortType then
            C_FriendList.SortWho(WHOFRAME_DROPDOWN_LIST[UIDropDownMenu_GetSelectedID(self)].sortType)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end
    end)

    for _, object in pairs(Headers) do
        local frame = WhoWindow.list[object]
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:SetFont(UNIT_NAME_FONT, 12)
            end
        end
    end

    for _, object in pairs(Headers) do
        if object ~= "ColumnHeader2" then WhoWindow.list[object]:GwSkinButton(false, true) end
    end

    WhoWindow.list.ColumnHeader2.DropDown:SetSize(135, 24)
    WhoWindow.list.ColumnHeader2.DropDown:GwStripTextures()
    WhoWindow.list.ColumnHeader2.DropDown.tex = WhoWindow.list.ColumnHeader2.DropDown:CreateTexture(nil, "ARTWORK")
    WhoWindow.list.ColumnHeader2.DropDown.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button")
    WhoWindow.list.ColumnHeader2.DropDown.tex:SetPoint("TOPLEFT", WhoWindow.list.ColumnHeader2.DropDown, "TOPLEFT", 1, 0)
    WhoWindow.list.ColumnHeader2.DropDown.tex:SetPoint("BOTTOMRIGHT", WhoWindow.list.ColumnHeader2.DropDown, "BOTTOMRIGHT", -2, 8)
    WhoWindow.list.ColumnHeader2.DropDown.Button:ClearAllPoints()
    WhoWindow.list.ColumnHeader2.DropDown.Button:SetPoint("RIGHT", WhoWindow.list.ColumnHeader2.DropDown, "RIGHT", -5, 5)
    WhoWindow.list.ColumnHeader2.DropDown.Text:ClearAllPoints()
    WhoWindow.list.ColumnHeader2.DropDown.Text:SetPoint("RIGHT", WhoWindow.list.ColumnHeader2.DropDown.Button, "RIGHT", -70, -1)
    WhoWindow.list.ColumnHeader2.DropDown.Text:SetFont(UNIT_NAME_FONT, 12)
    WhoWindow.list.ColumnHeader2.DropDown.Text:SetShadowOffset(0, 0)
    WhoWindow.list.ColumnHeader2.DropDown.Text:SetTextColor(0, 0, 0)
    WhoWindow.list.ColumnHeader2.DropDown.Button.NormalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    WhoWindow.list.ColumnHeader2.DropDown.Button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    WhoWindow.list.ColumnHeader2.DropDown.Button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    WhoWindow.list.ColumnHeader2.DropDown.Button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    WhoWindow.list.ColumnHeader2.DropDown:GwSkinButton(false, false, true)
    WhoWindow.list.ColumnHeader2.DropDown.hover:ClearAllPoints()
    WhoWindow.list.ColumnHeader2.DropDown.hover:SetPoint("TOPLEFT", WhoWindow.list.ColumnHeader2.DropDown, "TOPLEFT", 1, 0)
    WhoWindow.list.ColumnHeader2.DropDown.hover:SetPoint("BOTTOMRIGHT", WhoWindow.list.ColumnHeader2.DropDown, "BOTTOMRIGHT", -2, 8)

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
        slot.Name:SetFont(UNIT_NAME_FONT, 12)
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