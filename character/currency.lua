local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local CommaValue = GW.CommaValue

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
GW.AddForProfiling("currency", "SetupRaidExtendButton", SetupRaidExtendButton)

local function loadRaidInfo(raidinfo)
    local USED_RAID_INFO_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(raidinfo)
    local raidInfoCount1 = GetNumSavedInstances()
    local raidInfoCount2 = GetNumSavedWorldBosses()
    local raidInfoCount = raidInfoCount1 + raidInfoCount2

    for i = 1, #raidinfo.buttons do
        local slot = raidinfo.buttons[i]
        local instanceName, instanceID, instanceReset, locked, extended, instanceIDMostSig, difficultyName, _, _, extendDisabled

        local idx = i + offset
        if idx > raidInfoCount then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.instanceID = nil
            slot.item.RaidInfoIdx = nil
            slot.item.longInstanceID = nil
            slot.item.extendedValue = nil
            slot.item.locked = nil
            slot.item.worldBossID = nil
            slot.item.extendDisabled = nil
        else
            if idx <= raidInfoCount1 then
                instanceName, instanceID, instanceReset, _, locked, extended, instanceIDMostSig, _, _, difficultyName, _, _, extendDisabled = GetSavedInstanceInfo(idx)
                slot.item.instanceID = instanceID
                slot.item.worldBossID = nil
                slot.item.RaidInfoIdx = idx
                slot.item.longInstanceID = string.format("%s_%s", instanceIDMostSig, instanceID)
                slot.item.extendedValue = extended
                slot.item.locked = locked
                slot.item.extendDisabled = extendDisabled
            else
                instanceName, instanceID, instanceReset = GetSavedWorldBossInfo(idx - raidInfoCount1)
                difficultyName = RAID_INFO_WORLD_BOSS
                slot.item.worldBossID = instanceID
                slot.item.RaidInfoIdx = idx - raidInfoCount1
                slot.item.instanceID = nil
                slot.item.longInstanceID = nil
                slot.item.extendedValue = false
                slot.item.locked = true
                slot.item.extendDisabled = nil
            end

            -- set raidInfo values
            if (slot.item.extendedValue or slot.item.locked) then
                slot.item.reset:SetText(SecondsToTime(instanceReset, true, nil, 3))
                slot.item.name:SetText(instanceName)
            else
                slot.item.reset:SetFormattedText("|cff808080%s|r", RAID_INSTANCE_EXPIRES_EXPIRED)
                slot.item.name:SetFormattedText("|cff808080%s|r", instanceName)
            end

            if slot.item.extendedValue then
                slot.item.extended:SetText(EXTENDED)
            else
                slot.item.extended:SetText("")
            end
            slot.item.difficult:SetText(difficultyName)

            -- set zebra color by idx or watch status and show extended button
            zebra = idx % 2
            if selectedLongInstanceID == slot.item.longInstanceID then
                slot.item.zebra:SetVertexColor(1, 1, 0.5, 0.15)
                slot.item.extendButton:Show()
                slot.item.extendButton.selectedRaidID = selectedLongInstanceID
                slot.item.extendButton.selectedWorldBossID = slot.item.worldBossID
                SetupRaidExtendButton(slot.item)
            else
                slot.item.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
                slot.item.extendButton:Hide()
            end

            slot.item:Show()
        end
    end

    USED_RAID_INFO_HEIGHT = 55 * raidInfoCount
    HybridScrollFrame_Update(raidinfo, USED_RAID_INFO_HEIGHT, 576)
end
GW.AddForProfiling("currency", "loadRaidInfo", loadRaidInfo)

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
GW.AddForProfiling("currency", "raidInfo_OnEnter", raidInfo_OnEnter)

local function raidInfo_OnClick(self)
    if IsModifiedClick("CHATLINK") then
        if self.instanceID then
            ChatEdit_InsertLink(GetSavedInstanceChatLink(self.RaidInfoIdx))
        else
            -- No chat links for World Boss locks yet
        end
    else
        self.extendButton.selectedRaidID = self.longInstanceID
        self.extendButton.selectedWorldBossID = self.worldBossID
        selectedLongInstanceID = self.longInstanceID
        loadRaidInfo(self.frame)
    end
end
GW.AddForProfiling("currency", "raidInfo_OnClick", raidInfo_OnClick)

local function raidInfoExtended_OnClick(self)
    if self:GetParent().RaidInfoIdx <= GetNumSavedInstances() then
        SetSavedInstanceExtend(self:GetParent().RaidInfoIdx, self.doExtend)
        selectedLongInstanceID = self:GetParent().longInstanceID
        RequestRaidInfo()
    end
end
GW.AddForProfiling("currency", "raidInfoExtended_OnClick", raidInfoExtended_OnClick)

local function raidInfoSetup(raidinfo)
    HybridScrollFrame_CreateButtons(raidinfo, "GwRaidInfoRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #raidinfo.buttons do
        local slot = raidinfo.buttons[i]
        slot:SetWidth(raidinfo:GetWidth() - 12)
        slot.item.name:SetFont(DAMAGE_TEXT_FONT, 14)
        slot.item.name:SetTextColor(1, 1, 1)
        slot.item.difficult:SetFont(UNIT_NAME_FONT, 12)
        slot.item.difficult:SetTextColor(1, 1, 1)
        slot.item.reset:SetFont(DAMAGE_TEXT_FONT, 12)
        slot.item.reset:SetTextColor(1, 1, 1)
        slot.item.extended:SetFont(UNIT_NAME_FONT, 12)
        slot.item.extended:SetTextColor(1, 1, 1)
        slot.item.extendButton:SetNormalFontObject(gw_button_font_black_small)
        slot.item.extendButton:SetHighlightFontObject(gw_button_font_black_small)
        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnClick", raidInfo_OnClick)
            slot.item:HookScript("OnEnter", raidInfo_OnEnter)
            slot.item:HookScript("OnLeave", GameTooltip_Hide)
            slot.item.extendButton:HookScript("OnClick", raidInfoExtended_OnClick)
            slot.item.ScriptsHooked = true
        end
        --save frame
        slot.item.frame = raidinfo
    end

    loadRaidInfo(raidinfo)
end
GW.AddForProfiling("currency", "raidInfoSetup", raidInfoSetup)

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
GW.AddForProfiling("currency", "menuItem_OnClick", menuItem_OnClick)

local oldAtlas = {
    Options_ListExpand_Right = 1,
    Options_ListExpand_Right_Expanded = 1
}

local function updateCollapse(texture, atlas)
    if not atlas or oldAtlas[atlas] then
        local parent = texture:GetParent()
        if parent:IsCollapsed() then
            if texture.SetTexture then
                texture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                texture:SetRotation(1.570796325)
            else
                texture:GetNormalTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                texture:GetNormalTexture():SetRotation(1.570796325)
            end
            if texture.GetPushedTexture then
                texture:GetPushedTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                texture:GetPushedTexture():SetRotation(1.570796325)
            end
        else
            if texture.SetTexture then
                texture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                texture:SetRotation(0)
            else
                texture:GetNormalTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                texture:GetNormalTexture():SetRotation(0)
            end
            if texture.GetPushedTexture then
                texture:GetPushedTexture():SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
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
    local zebra

    for idx, child in next, { frame.ScrollTarget:GetChildren() } do
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
                child.Name:SetFont(DAMAGE_TEXT_FONT, 14)
                child.Name:SetTextColor(1, 1, 1)
            end

            if child.Text then
                child.Text:SetFont(DAMAGE_TEXT_FONT, 13)
                child.Text:SetTextColor(1, 1, 1)
            end

            if child.Name then
                child.Name:SetFont(DAMAGE_TEXT_FONT, 14)
                child.Name:SetTextColor(1, 1, 1)
            end

            if child.Content then
                child.Content.Name:SetFont(UNIT_NAME_FONT, 12)
                child.Content.Count:SetFont(UNIT_NAME_FONT, 12)
                child.Content.WatchedCurrencyCheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchicon")
            end

            if child.elementData then
                if child.elementData.isHeader then
                    child.gwBackground = child:CreateTexture(nil, "BACKGROUND")
                    child.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep")
                    child.gwBackground:SetSize(512, child:GetHeight())
                    child.gwBackground:SetPoint("TOPLEFT")
                else
                    child.gwZebra = child:CreateTexture(nil, "BACKGROUND")
                    child.gwZebra:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
                    child.gwZebra:SetSize(32, 32)
                    child.gwZebra:SetPoint("TOPLEFT", child, "TOPLEFT")
                    child.gwZebra:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT")

                    child.Content.Name:SetFont(UNIT_NAME_FONT, 12)
                    child.Content.Count:SetFont(UNIT_NAME_FONT, 12)
                end
            end

            local icon = child.Content and child.Content.CurrencyIcon
            if icon then
                GW.HandleIcon(icon)

                hooksecurefunc(child, "RefreshAccountCurrencyIcon", RefreshAccountCurrencyIcon)
            end

            child.IsSkinned = true
        end

        -- update zebra
        if child.elementData and not child.elementData.isHeader then
            zebra = idx % 2
            child.gwZebra:SetVertexColor(zebra, zebra, zebra, 0.05)
        end
        RefreshAccountCurrencyIcon(child)
    end
end

local function SkinTokenFrame()
    --[[]]
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

    TokenFramePopup.Title:SetFont(DAMAGE_TEXT_FONT, 14)
    TokenFramePopup.Title:SetTextColor(1, 1, 1)

    local TokenPopupClose = TokenFramePopup["$parent.CloseButton"]
    if TokenPopupClose then
        TokenPopupClose:GwSkinButton(true)
    end

    CurrencyTransferMenuTitleText:SetFont(DAMAGE_TEXT_FONT, 14)
    CurrencyTransferMenuTitleText:SetTextColor(1, 1, 1)

    CurrencyTransferMenu.SourceSelector.SourceLabel:SetFont(UNIT_NAME_FONT, 13)
    CurrencyTransferMenu.SourceSelector.SourceLabel:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.SourceSelector.PlayerName:SetFont(UNIT_NAME_FONT, 13)
    CurrencyTransferMenu.SourceSelector.PlayerName:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.AmountSelector.TransferAmountLabel:SetFont(UNIT_NAME_FONT, 12)
    CurrencyTransferMenu.AmountSelector.TransferAmountLabel:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.SourceBalancePreview.Label:SetFont(UNIT_NAME_FONT, 12)
    CurrencyTransferMenu.SourceBalancePreview.Label:SetTextColor(1, 1, 1)
    CurrencyTransferMenu.PlayerBalancePreview.Label:SetFont(UNIT_NAME_FONT, 12)
    CurrencyTransferMenu.PlayerBalancePreview.Label:SetTextColor(1, 1, 1)

    CurrencyTransferMenu:GwStripTextures()
    CurrencyTransferMenu:GwCreateBackdrop(GW.BackdropTemplates.Default)
    CurrencyTransferMenu.CloseButton:GwSkinButton(true)
    CurrencyTransferMenu.SourceSelector.Dropdown:GwHandleDropDownBox()
    GW.SkinTextBox(CurrencyTransferMenu.AmountSelector.InputBox.Middle, CurrencyTransferMenu.AmountSelector.InputBox.Left, CurrencyTransferMenu.AmountSelector.InputBox.Right)
    CurrencyTransferMenu.ConfirmButton:GwSkinButton(false, true)
    CurrencyTransferMenu.CancelButton:GwSkinButton(false, true)

    --GW.HandleTrimScrollBar(TokenFrame.ScrollBar) -- taints
    --GW.HandleScrollControls(TokenFrame)
    hooksecurefunc(TokenFrame.ScrollBox, "Update", UpdateTokenSkins)

    CurrencyTransferMenu:SetFrameStrata("DIALOG")
end

local function UpdateTransferHistorySkins(self)
    local zebra

    for idx, child in next, { self.ScrollTarget:GetChildren() } do
        if not child.IsSkinned then

            if child.SourceName then
                child.SourceName:SetFont(DAMAGE_TEXT_FONT, 12)
                child.SourceName:SetTextColor(1, 1, 1)
            end

            if child.DestinationName then
                child.DestinationName:SetFont(DAMAGE_TEXT_FONT, 12)
                child.DestinationName:SetTextColor(1, 1, 1)
            end

            if child.CurrencyQuantity then
                child.CurrencyQuantity:SetFont(DAMAGE_TEXT_FONT, 12)
                child.CurrencyQuantity:SetTextColor(1, 1, 1)
            end

            if child.CurrencyIcon then
                GW.HandleIcon(child.CurrencyIcon)
            end

            if child.Arrow then
                child.Arrow:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                child.Arrow:SetRotation(1.570796325)
            end

            child.gwZebra = child:CreateTexture(nil, "BACKGROUND")
            child.gwZebra:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
            child.gwZebra:SetSize(32, 32)
            child.gwZebra:SetPoint("TOPLEFT", child, "TOPLEFT")
            child.gwZebra:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT")

            child.IsSkinned = true
        end

        -- update zebra
        zebra = idx % 2
        child.gwZebra:SetVertexColor(zebra, zebra, zebra, 0.05)
    end
end

local function LoadCurrency(tabContainer)
    -- setup the currency window as a HybridScrollFrame and init each of the faux frame buttons
    local curwin_outer = CreateFrame("Frame", "GWCharacterCurrenyRaidInfoFrame", tabContainer, "GwCurrencyWindow")

    --take over TokenFrame
    TokenFrame:Show()
    TokenFrame:SetParent(curwin_outer.Currency)
    TokenFrame:ClearAllPoints()
    TokenFrame:SetPoint("TOPLEFT", curwin_outer.Currency, "TOPLEFT", 0, 0)
    TokenFrame:SetSize(580, 576)
    TokenFrame.ScrollBox:SetParent(TokenFrame)
    TokenFrame.ScrollBox:ClearAllPoints()
    TokenFrame.ScrollBox:SetPoint("TOPLEFT", TokenFrame, 4, 0)
    TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", TokenFrame, -22, 0)

    --skin that frame here
    SkinTokenFrame()

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

    -- setup transfer history
    local curHistroyWin = curwin_outer.CurrencyTransferHistoryScroll
    curHistroyWin.Refresh = function(self)
        local dataReady = C_CurrencyInfo.IsCurrencyTransferTransactionDataReady();
        self.LoadingSpinner:SetShown(not dataReady);
        if not dataReady then
            return;
        end

        local dataProvider = CreateDataProvider();
        for _, transaction in ipairs(C_CurrencyInfo.FetchCurrencyTransferTransactions()) do -- change the order to that the newest transactions are at the top
            dataProvider:Insert(transaction);
        end

        local hasTransactionHistory = dataProvider:GetSize() > 0;
        self.EmptyLogMessage:SetShown(not hasTransactionHistory);
        self.ScrollBar:SetShown(hasTransactionHistory);
        self.ScrollBox:SetDataProvider(dataProvider);
    end
    curHistroyWin.update = function(self) self:Refresh() end
    transferHistorySetup(curHistroyWin)
    GW.HandleTrimScrollBar(curHistroyWin.ScrollBar)
    GW.HandleScrollControls(curHistroyWin)
    hooksecurefunc(curHistroyWin.ScrollBox, "Update", UpdateTransferHistorySkins)

    -- setup the raid info window
    local raidinfo = curwin_outer.RaidScroll
    raidinfo.update = loadRaidInfo
    raidinfo.scrollBar.doNotHide = true
    raidInfoSetup(raidinfo)

    -- update currency window when a currency update event occurs
    raidinfo:SetScript(
        "OnEvent",
        function(self)
            if GW.inWorld and self:IsShown() then
                loadRaidInfo(self)
            end
        end
    )
    raidinfo:RegisterEvent("UPDATE_INSTANCE_INFO")

    -- setup a menu frame
    local fmMenu = CreateFrame("Frame", "GWCurrencyMenu", tabContainer, "GwCharacterMenu")
    fmMenu.items = {}

    local item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = curwin_outer.Currency
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(CURRENCY)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.items.currency = item

    item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = curHistroyWin
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(CURRENCY_TRANSFER_LOG_TITLE)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.currency, "BOTTOMLEFT")
    fmMenu.items.currencyTransferHistory = item

    item = CreateFrame("Button", "GwRaidInfoFrame", fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = raidinfo
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(RAID_INFORMATION)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.currencyTransferHistory, "BOTTOMLEFT")
    fmMenu.items.raidinfo = item

    CharacterMenuButton_OnLoad(fmMenu.items.currency, false)
    CharacterMenuButton_OnLoad(fmMenu.items.currencyTransferHistory, true)
    CharacterMenuButton_OnLoad(fmMenu.items.raidinfo, false)
end
GW.LoadCurrency = LoadCurrency
