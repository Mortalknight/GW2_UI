local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad

local selectedLongInstanceID = nil


--TODO SKINNING
local function transferHistorySetup(self)
    self:InitializeFrameVisuals()
    self:InitializeScrollBox()

    self:GwStripTextures()
    self.CloseButton:GwKill()
    self.TitleContainer.TitleText:Hide()

    local CURRENCY_TRANSFER_LOG_EVENTS = {
        "CURRENCY_TRANSFER_LOG_UPDATE",
    }

    self:SetScript("OnShow", function()
        FrameUtil.RegisterFrameForEvents(self, CURRENCY_TRANSFER_LOG_EVENTS);
        self:Refresh()
    end)
    self:SetScript("OnHide", function()
        FrameUtil.UnregisterFrameForEvents(self, CURRENCY_TRANSFER_LOG_EVENTS);
    end)

    self:Hide()

    GW.HandlePortraitFrame(self)
end

local function SetupRaidExtendButton(self)
    if self.extendButton.selectedRaidID then
        if self.longInstanceID == self.extendButton.selectedRaidID then
            if self.extendDisabled then
                self.extendButton:Disable()
            else
                self.extendButton:Enable()
            end
            if self.extendedValue then
                self.extendButton.doExtend = false
                self.extendButton:SetText(UNEXTEND_RAID_LOCK)
            else
                self.extendButton.doExtend = true
                if self.locked then
                    self.extendButton:SetText(EXTEND_RAID_LOCK)
                else
                    self.extendButton:SetText(REACTIVATE_RAID_LOCK)
                end
            end
            return
        end
    elseif self.extendButton.selectedWorldBossID then
        if self.worldBossID == self.extendButton.selectedWorldBossID then
            self.extendButton:SetText(EXTEND_RAID_LOCK)
            self.extendButton:Disable()
            return
        end
    end
    self.extendButton:Disable()
end



local function UpdateRaidInfoScrollBox(self)
    local dataProvider = CreateDataProvider()

    local raidInfoCount1 = GetNumSavedInstances()
    if raidInfoCount1 and raidInfoCount1 > 0 then
        for index = 1, raidInfoCount1 do
            dataProvider:Insert({type="SAVED_INSTANCE", index=index})
        end
    end

    local raidInfoCount2 = GetNumSavedWorldBosses()
    if raidInfoCount2 and raidInfoCount2 > 0 then
        for index = 1, raidInfoCount2 do
            dataProvider:Insert({type="SAVED_WORLD_BOSS", index=index})
        end
    end
    self.RaidScroll:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function raidInfo_OnEnter(self)
    if self.instanceID then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetInstanceLockEncountersComplete(self.RaidInfoIdx)
        GameTooltip:Show()
    else
        local instanceName = GetSavedWorldBossInfo(self.RaidInfoIdx)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(instanceName)
        GameTooltip:Show()
    end
end


local function raidInfo_OnClick(self)
    if IsModifiedClick("CHATLINK") then
        if self.instanceID then
            ChatFrameUtil.InsertLink(GetSavedInstanceChatLink(self.RaidInfoIdx))
        else
            -- No chat links for World Boss locks yet
        end
    else
        self.extendButton.selectedRaidID = self.longInstanceID
        self.extendButton.selectedWorldBossID = self.worldBossID
        selectedLongInstanceID = self.longInstanceID
        UpdateRaidInfoScrollBox(GwCharacterCurrencyRaidInfoFrame.RaidLocks)
    end
end


local function raidInfoExtended_OnClick(self)
    if self:GetParent().RaidInfoIdx <= GetNumSavedInstances() then
        SetSavedInstanceExtend(self:GetParent().RaidInfoIdx, self.doExtend)
        selectedLongInstanceID = self:GetParent().longInstanceID
        RequestRaidInfo()
    end
end


local function RaidInfo_InitButton(button, elementData)
    local instanceName, instanceID, instanceReset, _, locked, extended, instanceIDMostSig, _, _, difficultyName, _, _, extendDisabled
    if not button.isSkinned then
        button.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
        button.name:SetTextColor(1, 1, 1)
        button.difficult:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        button.difficult:SetTextColor(1, 1, 1)
        button.reset:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        button.reset:SetTextColor(1, 1, 1)
        button.extended:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        button.extended:SetTextColor(1, 1, 1)
        if not button.ScriptsHooked then
            button:SetScript("OnClick", raidInfo_OnClick)
            button:SetScript("OnEnter", raidInfo_OnEnter)
            button:SetScript("OnLeave", GameTooltip_Hide)
            button.extendButton:SetScript("OnClick", raidInfoExtended_OnClick)
            button.ScriptsHooked = true
        end
        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    if elementData.type == "SAVED_INSTANCE" then
        instanceName, instanceID, instanceReset, _, locked, extended, instanceIDMostSig, _, _, difficultyName, _, _, extendDisabled = GetSavedInstanceInfo(elementData.index)
        button.instanceID = instanceID
        button.worldBossID = nil
        button.RaidInfoIdx = elementData.index
        button.longInstanceID = string.format("%s_%s", instanceIDMostSig, instanceID)
        button.extendedValue = extended
        button.locked = locked
        button.extendDisabled = extendDisabled
    elseif elementData.type == "SAVED_WORLD_BOSS" then
        instanceName, instanceID, instanceReset = GetSavedWorldBossInfo(elementData.index)
        difficultyName = RAID_INFO_WORLD_BOSS
        button.worldBossID = instanceID
        button.RaidInfoIdx = elementData.index
        button.instanceID = nil
        button.longInstanceID = nil
        button.extendedValue = false
        button.locked = true
        button.extendDisabled = nil
    end

    -- set raidInfo values
    button.icon:SetTexture(GW.instanceIconByName[instanceName] and GW.instanceIconByName[instanceName] or nil)
    button.icon:SetTexCoord(0, 0.75, 0, 0.75)
    if (button.extendedValue or button.locked) then
        button.reset:SetText(SecondsToTime(instanceReset, true, nil, 3))
        button.name:SetText(instanceName)
    else
        button.reset:SetFormattedText("|cff808080%s|r", RAID_INSTANCE_EXPIRES_EXPIRED)
        button.name:SetFormattedText("|cff808080%s|r", instanceName)
    end

    if button.extendedValue then
        button.extended:SetText(EXTENDED)
    else
        button.extended:SetText("")
    end
    button.difficult:SetText(difficultyName)

    -- set zebra color by idx or watch status and show extended button
    local isSelected = selectedLongInstanceID == button.longInstanceID
    button.gwSelected:SetShown(isSelected)
    if isSelected or ((elementData.index % 2) == 1) then
        button.zebra:SetVertexColor(1, 1, 1, 1)
        if isSelected then
            button.extendButton:Show()
            button.extendButton.selectedRaidID = selectedLongInstanceID
            button.extendButton.selectedWorldBossID = button.worldBossID
            SetupRaidExtendButton(button)
        else
            button.extendButton:Hide()
        end
    else
        button.zebra:SetVertexColor(0, 0, 0, 0)
        button.extendButton:Hide()
    end
end


local function menuItem_OnClick(self)
    local menuItems = self:GetParent().items
    for _, v in pairs(menuItems) do
        v.activeTexture:Hide()
        v.ToggleMe:Hide()
    end
    self.activeTexture:Show()
    self.ToggleMe:Show()
    if self:GetName() == "GwRaidInfoFrame" then
        RequestRaidInfo()
    end
end


local oldAtlas = {
    Options_ListExpand_Right = 1,
    Options_ListExpand_Right_Expanded = 1
}

local function updateCollapse(texture, atlas)
    if not atlas or oldAtlas[atlas] then
        local parent = texture:GetParent()
        if parent:IsCollapsed() then
            if texture.SetTexture then
                texture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:SetRotation(1.570796325)
            else
                texture:GetNormalTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:GetNormalTexture():SetRotation(1.570796325)
            end
            if texture.GetPushedTexture then
                texture:GetPushedTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:GetPushedTexture():SetRotation(1.570796325)
            end
            if texture.GetHighlightTexture then
                texture:GetPushedTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:GetPushedTexture():SetRotation(1.570796325)
            end
        else
            if texture.SetTexture then
                texture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:SetRotation(0)
            else
                texture:GetNormalTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:GetNormalTexture():SetRotation(0)
            end
            if texture.GetPushedTexture then
                texture:GetPushedTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:GetPushedTexture():SetRotation(0)
            end
            if texture.GetHighlightTexture then
                texture:GetPushedTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                texture:GetPushedTexture():SetRotation(0)
            end
        end
    end
end

local function RefreshAccountCurrencyIcon(self)
    if self.Content then
        if self.elementData.isAccountWide then
            self.Content.AccountWideIcon.Icon:SetAtlas("warbands-icon", TextureKitConstants.UseAtlasSize);
            self.Content.AccountWideIcon.Icon:SetScale(0.9);
        elseif self.elementData.isAccountTransferable then
            self.Content.AccountWideIcon.Icon:SetAtlas("warbands-transferable-icon", TextureKitConstants.UseAtlasSize);
            self.Content.AccountWideIcon.Icon:SetScale(0.9);
        else
            self.Content.AccountWideIcon.Icon:SetAtlas(nil);
        end

        self.Content.AccountWideIcon:SetShown(self.Content.AccountWideIcon.Icon:GetAtlas() ~= nil)
    end
end

local function UpdateTokenSkins(frame)
    for _, child in next, { frame.ScrollTarget:GetChildren() } do
        if not child.IsSkinned then
            if child.Right then
                child:GwStripTextures()
                child:GwCreateBackdrop()
                child.backdrop:GwSetInside(child)

                updateCollapse(child.Right)
                updateCollapse(child.HighlightRight)

                hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
                hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
            end

            if child.ToggleCollapseButton then
                updateCollapse(child.ToggleCollapseButton)
                hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateCollapse)
            end

            if child.Name then
                child.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
                child.Name:SetTextColor(1, 1, 1)
            end

            if child.Text then
                child.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
                child.Text:SetTextColor(1, 1, 1)
            end

            if child.Content then
                child.Content.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
                child.Content.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
                child.Content.Name:SetJustifyH("LEFT")
                child.Content.Count:SetJustifyH("RIGHT")
                child.Content.Name:SetJustifyV("MIDDLE")
                child.Content.Count:SetJustifyV("MIDDLE")
                child.Content.WatchedCurrencyCheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchicon.png")

                if child.Content.BackgroundHighlight then
                    child.Content.BackgroundHighlight:GwKill()
                end

                hooksecurefunc(child, "RefreshBackgroundHighlight", function()
                    child.gwSelected:SetShown(child:IsSelected())
                end)

                child.Content.Name:ClearAllPoints()
                child.Content.Count:ClearAllPoints()
                child.Content.AccountWideIcon:ClearAllPoints()
                child.Content.Name:SetPoint("LEFT", child.Content, "LEFT", 32, 0)
                child.Content.Count:SetPoint("RIGHT", child.Content, "RIGHT", -25, 0)
                child.Content.AccountWideIcon:SetPoint("RIGHT", child.Content, "RIGHT", 2, 0)
            end

            if child.elementData and child.elementData.isHeader then
                child.gwBackground = child:CreateTexture(nil, "BACKGROUND")
                child.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
                child.gwBackground:SetAllPoints(child)
                child.gwBackground:SetPoint("TOPLEFT")
            end

            local icon = child.Content and child.Content.CurrencyIcon
            if icon then
                icon:SetSize(22, 22)
                icon:ClearAllPoints()
                icon:SetPoint("LEFT", child.Content, "LEFT")
                GW.HandleIcon(icon)

                hooksecurefunc(child, "RefreshAccountCurrencyIcon", RefreshAccountCurrencyIcon)
            end

            GW.AddListItemChildHoverTexture(child)

            child.IsSkinned = true
        end

        if child.elementData.maxQuantity and child.elementData.maxQuantity > 0 then
            child.Content.Count:SetText(GW.GetLocalizedNumber(child.elementData.quantity) .. " / " .. GW.GetLocalizedNumber(child.elementData.maxQuantity))
        elseif child.elementData.quantity and child.Content then
            child.Content.Count:SetText(GW.GetLocalizedNumber(child.elementData.quantity))
        end

        if child.Content and child.Content.WatchedCurrencyCheck then
            child.Content.WatchedCurrencyCheck:ClearAllPoints()
            child.Content.WatchedCurrencyCheck:SetPoint("RIGHT", child.Content.Name, "RIGHT", 20, 0)
        end

        RefreshAccountCurrencyIcon(child)
    end
    GW.HandleItemListScrollBoxHover(frame)
end

local function SkinTokenFrame()
    TokenFramePopup:GwStripTextures()
    TokenFramePopup:GwCreateBackdrop(GW.BackdropTemplates.Default)
    TokenFramePopup:SetPoint("TOPLEFT", _G.TokenFrame, "TOPRIGHT", 3, -28)
    TokenFrame.CurrencyTransferLogToggleButton:SetAlpha(0)

    TokenFramePopup.InactiveCheckbox:GwSkinCheckButton()
    TokenFramePopup.BackpackCheckbox:GwSkinCheckButton()
    TokenFramePopup.InactiveCheckbox:SetSize(15, 15)
    TokenFramePopup.BackpackCheckbox:SetSize(15, 15)
    TokenFramePopup.CurrencyTransferToggleButton:GwSkinButton(false, true)

    TokenFramePopup.InactiveCheckbox:ClearAllPoints()
    TokenFramePopup.InactiveCheckbox:SetPoint("TOPLEFT", TokenFramePopup, 32, -38)

    TokenFramePopup.InactiveCheckbox.Text:ClearAllPoints()
    TokenFramePopup.InactiveCheckbox.Text:SetPoint("LEFT", TokenFramePopup.InactiveCheckbox, "RIGHT", 5, 0)

    TokenFramePopup.BackpackCheckbox:ClearAllPoints()
    TokenFramePopup.BackpackCheckbox:SetPoint("TOPLEFT", TokenFramePopup.InactiveCheckbox, "BOTTOMLEFT", 0, -10)

    TokenFramePopup.BackpackCheckbox.Text:ClearAllPoints()
    TokenFramePopup.BackpackCheckbox.Text:SetPoint("LEFT", TokenFramePopup.BackpackCheckbox, "RIGHT", 5, 0)

    TokenFramePopup.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    TokenFramePopup.Title:SetTextColor(1, 1, 1)

    local TokenPopupClose = TokenFramePopup["$parent.CloseButton"]
    if TokenPopupClose then
        TokenPopupClose:GwSkinButton(true)
    end

    CurrencyTransferMenuTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    CurrencyTransferMenuTitleText:SetTextColor(1, 1, 1)

    CurrencyTransferMenu.Content.SourceSelector.SourceLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    CurrencyTransferMenu.Content.SourceSelector.SourceLabel:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.Content.SourceSelector.PlayerName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    CurrencyTransferMenu.Content.SourceSelector.PlayerName:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.Content.AmountSelector.TransferAmountLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    CurrencyTransferMenu.Content.AmountSelector.TransferAmountLabel:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.Content.SourceBalancePreview.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    CurrencyTransferMenu.Content.SourceBalancePreview.Label:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.Content.SourceBalancePreview.BalanceInfo.CurrencyIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    CurrencyTransferMenu.Content.PlayerBalancePreview.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    CurrencyTransferMenu.Content.PlayerBalancePreview.Label:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.Content.PlayerBalancePreview.BalanceInfo.CurrencyIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    CurrencyTransferMenu:GwStripTextures()
    CurrencyTransferMenu:GwCreateBackdrop(GW.BackdropTemplates.Default)
    CurrencyTransferMenu.Content.CancelButton:GwSkinButton(true)
    CurrencyTransferMenu.Content.SourceSelector.Dropdown:GwHandleDropDownBox()
    GW.SkinTextBox(CurrencyTransferMenu.Content.AmountSelector.InputBox.Middle, CurrencyTransferMenu.Content.AmountSelector.InputBox.Left, CurrencyTransferMenu.Content.AmountSelector.InputBox.Right)
    CurrencyTransferMenu.Content.AmountSelector.MaxQuantityButton:GwSkinButton(false, true)
    CurrencyTransferMenu.Content.ConfirmButton:GwSkinButton(false, true)
    CurrencyTransferMenu.Content.CancelButton:GwSkinButton(false, true)

    GW.HandleTrimScrollBar(TokenFrame.ScrollBar)
    GW.HandleScrollControls(TokenFrame)
    hooksecurefunc(TokenFrame.ScrollBox, "Update", UpdateTokenSkins)

    if TokenFrame.filterDropdown then
        TokenFrame.filterDropdown:ClearAllPoints()
        TokenFrame.filterDropdown:SetPoint("TOPRIGHT", TokenFrame, "TOPRIGHT", 3, 25)
        TokenFrame.filterDropdown:GwHandleDropDownBox()
    end

    CurrencyTransferMenu:SetFrameStrata("DIALOG")
end

local currencyTransferLoaded
local function UpdateTransferHistorySkins(self)
    if not currencyTransferLoaded then
        currencyTransferLoaded = true
        self.view:SetElementExtent(32)
    end
    for _, child in next, { self.ScrollTarget:GetChildren() } do
        if not child.IsSkinned then
            child:SetHeight(32)

            if child.SourceName then
                child.SourceName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
                child.SourceName:SetTextColor(1, 1, 1)
                child.SourceName:ClearAllPoints()
                child.SourceName:SetPoint("LEFT", child, "LEFT", 42, 0)
            end

            if child.DestinationName then
                child.DestinationName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
                child.DestinationName:SetTextColor(1, 1, 1)
                child.DestinationName:ClearAllPoints()
                child.DestinationName:SetPoint("LEFT", child.Arrow, "RIGHT", 3, 0)
            end

            if child.CurrencyQuantity then
                child.CurrencyQuantity:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
                child.CurrencyQuantity:SetTextColor(1, 1, 1)
                child.CurrencyQuantity:ClearAllPoints()
                child.CurrencyQuantity:SetPoint("RIGHT", child, "RIGHT", -25, 0)
            end

            if child.CurrencyIcon then
                child.CurrencyIcon:SetSize(32, 32)
                child.CurrencyIcon:ClearAllPoints()
                child.CurrencyIcon:SetPoint("LEFT", child, "LEFT")
                GW.HandleIcon(child.CurrencyIcon)
            end

            if child.Arrow then
                child.Arrow:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
                child.Arrow:SetRotation(1.570796325)
                child.Arrow:ClearAllPoints()
                child.Arrow:SetPoint("LEFT", child.SourceName, "RIGHT", 3, 0)
            end

            if child.BackgroundHighlight then
                child.BackgroundHighlight:GwKill()
            end

            GW.AddListItemChildHoverTexture(child)

            child.IsSkinned = true
        end
    end
    GW.HandleItemListScrollBoxHover(self)
end

local function LoadCurrency(tabContainer)
    local curwin_outer = CreateFrame("Frame", "GwCharacterCurrencyRaidInfoFrame", tabContainer, "GwCurrencyWindow")

    --take over TokenFrame
    TokenFrame:Show()
    TokenFrame:SetParent(curwin_outer.Currency)
    TokenFrame:ClearAllPoints()
    TokenFrame:SetPoint("TOPLEFT", curwin_outer.Currency, "TOPLEFT", 0, -15)
    TokenFrame:SetSize(580, 576)
    TokenFrame.ScrollBox:SetParent(TokenFrame)
    TokenFrame.ScrollBox:ClearAllPoints()
    TokenFrame.ScrollBox:SetPoint("TOPLEFT", TokenFrame, 4, 0)
    TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", TokenFrame, -20, 0)

    --skin that frame here
    SkinTokenFrame()

    TokenFrame.Hide = TokenFrame.Show

    hooksecurefunc(TokenFrame, "SetShown", function(self)
        self:Show()
    end)
    hooksecurefunc(TokenFrame, "SetParent", function(self, parent)
        if parent ~= curwin_outer.Currency then
            self:SetParent(curwin_outer.Currency)
        end
    end)
    hooksecurefunc(TokenFrame, "SetPoint", function(self, _, parent)
        if parent ~= curwin_outer.Currency then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", curwin_outer.Currency, "TOPLEFT", 0, 0)
        end
    end)

    hooksecurefunc(TokenFrame.ScrollBox, "SetParent", function(self, parent)
        if parent ~= TokenFrame then
            self:SetParent(TokenFrame)
        end
    end)
    hooksecurefunc(TokenFrame.ScrollBox, "SetPoint", function(self, _, parent)
        if parent ~= TokenFrame then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", TokenFrame, 4, 0)
            self:SetPoint("BOTTOMRIGHT", TokenFrame, -22, 0)
        end
    end)

    BackpackTokenFrame.GetMaxTokensWatched = function()
        return 4
    end

    -- setup transfer history
    local curHistroyWin = curwin_outer.CurrencyTransferHistoryScroll
    curHistroyWin.update = function(self) self:Refresh() end
    transferHistorySetup(curHistroyWin)
    GW.HandleTrimScrollBar(curHistroyWin.ScrollBar)
    GW.HandleScrollControls(curHistroyWin)
    curHistroyWin.ScrollBar:SetHideIfUnscrollable(true)
    curHistroyWin.EmptyLogMessage:SetTextColor(1, 1, 1)
    hooksecurefunc(curHistroyWin.ScrollBox, "Update", UpdateTransferHistorySkins)
    curHistroyWin.ScrollBox:ClearAllPoints()
    curHistroyWin.ScrollBox:SetPoint("TOPLEFT", curHistroyWin, 4, 0)
    curHistroyWin.ScrollBox:SetPoint("BOTTOMRIGHT", curHistroyWin, -22, 0)

    -- setup the raid info window
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwRaidInfoButtonTemplate", function(button, elementData)
        RaidInfo_InitButton(button, elementData)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(curwin_outer.RaidLocks.RaidScroll, curwin_outer.RaidLocks.ScrollBar, view)
    GW.HandleTrimScrollBar(curwin_outer.RaidLocks.ScrollBar)
    GW.HandleScrollControls(curwin_outer.RaidLocks)
    curwin_outer.RaidLocks.ScrollBar:SetHideIfUnscrollable(true)

    UpdateRaidInfoScrollBox(curwin_outer.RaidLocks)

    -- update currency window when a currency update event occurs
    curwin_outer.RaidLocks:SetScript(
        "OnEvent",
        function(self)
            if GW.inWorld and self:IsShown() then
                UpdateRaidInfoScrollBox(self)
            end
        end
    )
    curwin_outer.RaidLocks:RegisterEvent("UPDATE_INSTANCE_INFO")

    -- setup a menu frame
    local fmMenu = CreateFrame("Frame", "GWCurrencyMenu", tabContainer, "GwHeroPanelMenuTemplate")
    fmMenu.items = {}

    local item = CreateFrame("Button", nil, fmMenu, "GwHeroPanelMenuButtonTemplate")
    item.ToggleMe = curwin_outer.Currency
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(CURRENCY)
    item:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.items.currency = item

    item = CreateFrame("Button", nil, fmMenu, "GwHeroPanelMenuButtonTemplate")
    item.ToggleMe = curHistroyWin
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(CURRENCY_TRANSFER_LOG_TITLE)
    item:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.currency, "BOTTOMLEFT")
    fmMenu.items.currencyTransferHistory = item

    item = CreateFrame("Button", "GwRaidInfoFrame", fmMenu, "GwHeroPanelMenuButtonTemplate")
    item.ToggleMe = curwin_outer.RaidLocks
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(RAID_INFORMATION)
    item:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.currencyTransferHistory, "BOTTOMLEFT")
    fmMenu.items.raidinfo = item

    CharacterMenuButton_OnLoad(fmMenu.items.currency, false)
    CharacterMenuButton_OnLoad(fmMenu.items.currencyTransferHistory, true)
    CharacterMenuButton_OnLoad(fmMenu.items.raidinfo, false)
end
GW.LoadCurrency = LoadCurrency
