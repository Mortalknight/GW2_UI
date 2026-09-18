---@class GW2
local GW = select(2, ...)
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad

local selectedLongInstanceID = nil
local ARROW = "Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png"

local function transferHistorySetup(self)
    self:InitializeFrameVisuals()
    self:InitializeScrollBox()

    self:GwStripTextures()
    self.CloseButton:GwKill()
    self.TitleContainer.TitleText:Hide()

    self:SetScript("OnShow", function()
        self:RegisterEvent("CURRENCY_TRANSFER_LOG_UPDATE")
        self:Refresh()
    end)
    self:SetScript("OnHide", function()
        self:UnregisterEvent("CURRENCY_TRANSFER_LOG_UPDATE")
    end)
    self:Hide()

    GW.HandlePortraitFrame(self)
end

---------- raid locks ----------

local function SetupRaidExtendButton(self)
    if self.extendButton.selectedRaidID then
        if self.longInstanceID == self.extendButton.selectedRaidID then
            self.extendButton:SetEnabled(not self.extendDisabled)
            if self.extendedValue then
                self.extendButton.doExtend = false
                self.extendButton:SetText(UNEXTEND_RAID_LOCK)
            else
                self.extendButton.doExtend = true
                self.extendButton:SetText(self.locked and EXTEND_RAID_LOCK or REACTIVATE_RAID_LOCK)
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
    for index = 1, GetNumSavedInstances() or 0 do
        dataProvider:Insert({type = "SAVED_INSTANCE", index = index})
    end
    for index = 1, GetNumSavedWorldBosses() or 0 do
        dataProvider:Insert({type = "SAVED_WORLD_BOSS", index = index})
    end
    self.RaidScroll:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function raidInfo_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if self.instanceID then
        GameTooltip:SetInstanceLockEncountersComplete(self.RaidInfoIdx)
    else
        GameTooltip:SetText(GetSavedWorldBossInfo(self.RaidInfoIdx), 1, 1, 1)
    end
    GameTooltip:Show()
end

local function raidInfo_OnClick(self)
    if IsModifiedClick("CHATLINK") then
        if self.instanceID then
            ChatFrameUtil.InsertLink(GetSavedInstanceChatLink(self.RaidInfoIdx))
        end
    else
        self.extendButton.selectedRaidID = self.longInstanceID
        self.extendButton.selectedWorldBossID = self.worldBossID
        selectedLongInstanceID = self.longInstanceID
        UpdateRaidInfoScrollBox(GwCharacterCurrencyRaidInfoFrame.RaidLocks)
    end
end

local function raidInfoExtended_OnClick(self)
    local parent = self:GetParent()
    if parent.RaidInfoIdx <= GetNumSavedInstances() then
        SetSavedInstanceExtend(parent.RaidInfoIdx, self.doExtend)
        selectedLongInstanceID = parent.longInstanceID
        RequestRaidInfo()
    end
end

local function RaidInfo_InitButton(button, elementData)
    local instanceName, instanceID, instanceReset, _, locked, extended, instanceIDMostSig, _, _, difficultyName, _, _, extendDisabled
    if not button.gwSkinned then
        button.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        button.name:SetTextColor(1, 1, 1)
        button.difficult:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        button.difficult:SetTextColor(1, 1, 1)
        button.reset:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        button.reset:SetTextColor(1, 1, 1)
        button.extended:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        button.extended:SetTextColor(1, 1, 1)
        if not button.ScriptsHooked then
            button:SetScript("OnClick", raidInfo_OnClick)
            button:SetScript("OnEnter", raidInfo_OnEnter)
            button:SetScript("OnLeave", GameTooltip_Hide)
            button.extendButton:SetScript("OnClick", raidInfoExtended_OnClick)
            button.ScriptsHooked = true
        end
        GW.AddListItemChildHoverTexture(button)

        button.gwSkinned = true
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

---------- menu ----------

local function menuItem_OnClick(self)
    for _, v in pairs(self:GetParent().items) do
        v.activeTexture:Hide()
        v.ToggleMe:Hide()
    end
    self.activeTexture:Show()
    self.ToggleMe:Show()
    if self:GetName() == "GwRaidInfoFrame" then
        RequestRaidInfo()
    end
end

---------- token list ----------

local function SetArrow(texture, collapsed)
    texture:SetTexture(ARROW)
    texture:SetRotation(collapsed and math.pi / 2 or 0)
end

local function UpdateHeaderArrow(header)
    SetArrow(header.StateIcon, header:IsCollapsed())
end

local function UpdateToggleArrow(button)
    local header = button:GetHeader()
    local collapsed = header and header:IsCollapsed()
    SetArrow(button:GetNormalTexture(), collapsed)
    SetArrow(button:GetPushedTexture(), collapsed)
end

local function RefreshAccountCurrencyIcon(self)
    if not self.Content then return end
    local icon = self.Content.AccountWideIcon.Icon
    if self.elementData.isAccountWide then
        icon:SetAtlas("warbands-icon", TextureKitConstants.UseAtlasSize)
        icon:SetScale(0.9)
    elseif self.elementData.isAccountTransferable then
        icon:SetAtlas("warbands-transferable-icon", TextureKitConstants.UseAtlasSize)
        icon:SetScale(0.9)
    else
        icon:SetAtlas(nil)
    end
    self.Content.AccountWideIcon:SetShown(icon:GetAtlas() ~= nil)
end

local function SkinTokenChild(child)
    if child.StateIcon then
        child:GwStripTextures()
        child:GwCreateBackdrop()
        child.backdrop:GwSetInside(child)
        child.StateIcon:SetSize(20, 20)
        UpdateHeaderArrow(child)
        hooksecurefunc(child, "Initialize", UpdateHeaderArrow)
        child.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        child.Name:GwLockTextColor(1, 1, 1)
    end

    if child.ToggleCollapseButton then
        child.ToggleCollapseButton:SetSize(16, 16)
        UpdateToggleArrow(child.ToggleCollapseButton)
        hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", UpdateToggleArrow)
    end

    if child.Text then
        child.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        child.Text:GwLockTextColor(1, 1, 1)
    end

    if child.Content then
        child.Content.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        child.Content.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        child.Content.Name:SetJustifyH("LEFT")
        child.Content.Count:SetJustifyH("RIGHT")
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

        local icon = child.Content.CurrencyIcon
        icon:SetSize(22, 22)
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", child.Content, "LEFT")
        GW.HandleIcon(icon)
        hooksecurefunc(child, "RefreshAccountCurrencyIcon", RefreshAccountCurrencyIcon)
        GW.AddListItemChildHoverTexture(child)
    end
end

local function UpdateTokenSkins(frame)
    for _, child in next, {frame.ScrollTarget:GetChildren()} do
        if not child.gwSkinned then
            SkinTokenChild(child)
            child.gwSkinned = true
        end

        if child.Content and child.elementData then
            local data = child.elementData
            if data.maxQuantity and data.maxQuantity > 0 then
                child.Content.Count:SetText(GW.GetLocalizedNumber(data.quantity) .. " / " .. GW.GetLocalizedNumber(data.maxQuantity))
            elseif data.quantity then
                child.Content.Count:SetText(GW.GetLocalizedNumber(data.quantity))
            end
            child.Content.WatchedCurrencyCheck:ClearAllPoints()
            child.Content.WatchedCurrencyCheck:SetPoint("RIGHT", child.Content.Name, "RIGHT", 20, 0)
            RefreshAccountCurrencyIcon(child)
        end
    end
    GW.HandleItemListScrollBoxHover(frame)
end

---------- detail pane ----------

local function SkinDetailRows(details)
    for _, row in next, {details.Content:GetChildren()} do
        if not row.gwSkinned then
            if row.Background then
                row.Background:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
            end
            if row.Label then
                row.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            end
            if row.Value then
                row.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            end
            if row.Icon then
                GW.HandleIcon(row.Icon)
            end
            if row.IconSlot then
                row.IconSlot:Hide()
            end
            row.gwSkinned = true
        end
    end
end

local function SkinCheckbox(checkbox)
    checkbox:GwSkinCheckButton(false, 15)
    checkbox.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    checkbox.Label:SetTextColor(1, 1, 1)
end

local function SkinDetailFrame(details, container)
    details:SetParent(container)
    details:ClearAllPoints()
    details:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    details:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)
    details:SetFrameStrata(container:GetFrameStrata())
    details:GwStripTextures()
    GW.AddDetailsBackground(container)
    details.Title:ClearAllPoints()
    details.Title:SetPoint("TOP", details, "TOP", 0, -14)
    details.Title:SetWidth(container:GetWidth() - 20)

    details.Title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    details.Subtitle:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    details.EmptyText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    details.EmptyText:SetTextColor(0.6, 0.6, 0.6)
    if details.Divider then
        details.Divider:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")
        details.Divider:SetSize(container:GetWidth() - 30, 2)
    end
    if details.Description and details.Description.SetFontObject then
        details.Description:SetFontObject(GameFontHighlight)
    end
    if details.DescriptionScrollBar then
        GW.HandleTrimScrollBar(details.DescriptionScrollBar)
    end

    SkinCheckbox(details.InactiveCheckbox)
    SkinCheckbox(details.BackpackCheckbox)
    details.CurrencyTransferToggleButton:GwSkinButton(false, true)

    hooksecurefunc(details, "LayoutRows", SkinDetailRows)
    hooksecurefunc(details, "SetPaneTitleColor", function(self)
        self.Title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        self.Subtitle:SetTextColor(1, 1, 1)
    end)
end

local function SkinTransferMenu()
    CurrencyTransferMenuTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    CurrencyTransferMenuTitleText:SetTextColor(1, 1, 1)

    local content = CurrencyTransferMenu.Content
    content.SourceSelector.SourceLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    content.SourceSelector.SourceLabel:SetTextColor(1, 1, 1)
    content.SourceSelector.PlayerName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    content.SourceSelector.PlayerName:SetTextColor(1, 1, 1)
    content.AmountSelector.TransferAmountLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    content.AmountSelector.TransferAmountLabel:SetTextColor(1, 1, 1)
    content.SourceBalancePreview.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    content.SourceBalancePreview.Label:SetTextColor(1, 1, 1)
    content.SourceBalancePreview.BalanceInfo.CurrencyIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    content.PlayerBalancePreview.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    content.PlayerBalancePreview.Label:SetTextColor(1, 1, 1)
    content.PlayerBalancePreview.BalanceInfo.CurrencyIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    CurrencyTransferMenu:GwStripTextures()
    CurrencyTransferMenu:GwCreateBackdrop(GW.BackdropTemplates.Default)
    content.SourceSelector.Dropdown:GwHandleDropDownBox()
    GW.SkinTextBox(content.AmountSelector.InputBox.Middle, content.AmountSelector.InputBox.Left, content.AmountSelector.InputBox.Right)
    content.AmountSelector.MaxQuantityButton:GwSkinButton(false, true)
    content.ConfirmButton:GwSkinButton(false, true)
    content.CancelButton:GwSkinButton(false, true)
    CurrencyTransferMenu:SetFrameStrata("DIALOG")
end

local function KeepInContainer(frame, container, ...)
    local points = {...}
    hooksecurefunc(frame, "SetParent", function(self, parent)
        if parent ~= container then
            self:SetParent(container)
        end
    end)
    hooksecurefunc(frame, "SetPoint", function(self, _, relativeTo)
        if relativeTo ~= container then
            self:ClearAllPoints()
            self:SetPoint(unpack(points))
        end
    end)
end

---------- transfer history ----------

local currencyTransferLoaded
local function UpdateTransferHistorySkins(self)
    if not currencyTransferLoaded then
        currencyTransferLoaded = true
        self.view:SetElementExtent(40)
    end
    for _, child in next, {self.ScrollTarget:GetChildren()} do
        if not child.gwSkinned then
            child.SourceName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            child.DestinationName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            child.CurrencyQuantity:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            child.SourceName:SetTextColor(1, 1, 1)
            child.DestinationName:SetTextColor(1, 1, 1)
            child.CurrencyQuantity:SetTextColor(1, 1, 1)
            if child.BackgroundHighlight then
                child.BackgroundHighlight:GwKill()
            end
            GW.HandleIcon(child.CurrencyIcon)
            GW.AddListItemChildHoverTexture(child)
            child.gwSkinned = true
        end
    end
    GW.HandleItemListScrollBoxHover(self)
end

local function LoadCurrency(tabContainer)
    local curwin_outer = CreateFrame("Frame", "GwCharacterCurrencyRaidInfoFrame", tabContainer, "GwCurrencyWindowForeverTemplate")
    local list, details = curwin_outer.Currency.List, curwin_outer.Currency.Details

    TokenFrame:Show()
    TokenFrame:SetParent(list)
    TokenFrame:ClearAllPoints()
    TokenFrame:SetPoint("TOPLEFT", list, "TOPLEFT", 0, 0)
    TokenFrame:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", 0, 0)
    TokenFrame.ScrollBox:ClearAllPoints()
    TokenFrame.ScrollBox:SetPoint("TOPLEFT", TokenFrame, 4, 0)
    TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", TokenFrame, -20, 0)

    -- the Blizzard character frame keeps toggling its sub frames, ours only follows the container
    TokenFrame.Hide = TokenFrame.Show
    hooksecurefunc(TokenFrame, "SetShown", function(self) self:Show() end)
    KeepInContainer(TokenFrame, list, "TOPLEFT", list, "TOPLEFT", 0, 0)
    KeepInContainer(TokenFrame.ScrollBox, TokenFrame, "TOPLEFT", TokenFrame, "TOPLEFT", 4, 0)

    -- the scroll box carries two decorative scroll line frames besides its scroll target
    for _, child in ipairs({TokenFrame.ScrollBox:GetChildren()}) do
        if child ~= TokenFrame.ScrollBox.ScrollTarget then
            child:Hide()
        end
    end
    GW.HandleTrimScrollBar(TokenFrame.ScrollBar)
    TokenFrame.ScrollBar:SetHideIfUnscrollable(true)
    GW.HandleScrollControls(TokenFrame)
    hooksecurefunc(TokenFrame.ScrollBox, "Update", UpdateTokenSkins)

    SkinDetailFrame(TokenFrame.DetailFrame, details)
    SkinTransferMenu()
    if CurrencyTransferLog then
        CurrencyTransferLog:GwKill()
    end

    BackpackTokenFrame.GetMaxTokensWatched = function()
        return 4
    end

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

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwRaidInfoButtonTemplate", RaidInfo_InitButton)
    ScrollUtil.InitScrollBoxListWithScrollBar(curwin_outer.RaidLocks.RaidScroll, curwin_outer.RaidLocks.ScrollBar, view)
    GW.HandleTrimScrollBar(curwin_outer.RaidLocks.ScrollBar)
    GW.HandleScrollControls(curwin_outer.RaidLocks)
    curwin_outer.RaidLocks.ScrollBar:SetHideIfUnscrollable(true)
    UpdateRaidInfoScrollBox(curwin_outer.RaidLocks)
    curwin_outer.RaidLocks:SetScript("OnEvent", function(self)
        if GW.inWorld and self:IsShown() then
            UpdateRaidInfoScrollBox(self)
        end
    end)
    curwin_outer.RaidLocks:RegisterEvent("UPDATE_INSTANCE_INFO")

    local fmMenu = CreateFrame("Frame", "GWCurrencyMenu", tabContainer, "GwCharacterPanelMenuTemplate")
    fmMenu.items = {}
    local function AddItem(key, text, toggle, previous, odd, name)
        local item = CreateFrame("Button", name, fmMenu, "GwCharacterPanelMenuButtonTemplate")
        item.ToggleMe = toggle
        item:SetScript("OnClick", menuItem_OnClick)
        item:SetText(text)
        item:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
        item:ClearAllPoints()
        if previous then
            item:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
        else
            item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
        end
        CharacterMenuButton_OnLoad(item, odd)
        fmMenu.items[key] = item
        return item
    end
    local item = AddItem("currency", CURRENCY, curwin_outer.Currency, nil, false)
    item = AddItem("currencyTransferHistory", CURRENCY_TRANSFER_LOG_TITLE, curHistroyWin, item, true)
    AddItem("raidinfo", RAID_INFORMATION, curwin_outer.RaidLocks, item, false, "GwRaidInfoFrame")
end
GW.LoadCurrency = LoadCurrency
