local _, GW = ...
local L = GW.L
local EnableTooltip = GW.EnableTooltip
local inv

local BANK_ITEM_LARGE_SIZE = 40
local BANK_ITEM_COMPACT_SIZE = 32
local BANK_ITEM_PADDING = 5

local PURCHASE_TAB_ID = -1

local function fetchPurchasedBankTabData(f)
    f.purchasedBankTabData = C_Bank.FetchPurchasedBankTabData(f.bankType)
end

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutAccountBankItems(f)
    local max_col = f:GetParent().gw_bank_cols
    local row = 0
    local col = 0

    local item_off = GW.settings.BAG_ITEM_SIZE + BANK_ITEM_PADDING

    local cf = f.Container
    inv.layoutContainerFrame(cf, max_col, row, col, false, item_off)
end
GW.AddForProfiling("bank", "layoutAccountBankItems", layoutAccountBankItems)

-- adjusts the bank frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    inv.snapFrameSize(f, f.BankPanel.Container, GW.settings.BAG_ITEM_SIZE, BANK_ITEM_PADDING, 370)
end
GW.AddForProfiling("bank", "snapFrameSize", snapFrameSize)

-- update the number of free bank slots available and set the display for it
local function updateFreeBankSlots(self)
    local free, _ = inv.updateFreeSlots(GwBankFrame.spaceString, NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS, BANK_CONTAINER)
    local b = self.bags[0]
    if b then
        SetItemButtonCount(b, free)
        b.tooltipAddLine = string.format(NUM_FREE_SLOTS, free)
    end
end
GW.AddForProfiling("bank", "updateFreeBankSlots", updateFreeBankSlots)

local function takeOverBankItemButtons(self)
    local idx = 1
    for itemButton in self:EnumerateValidItems() do
        itemButton:SetParent(self.Container)
        itemButton.gw_owner = self.Container
        self.Container.gw_items[idx] = itemButton
        inv.reskinItemButton(itemButton)

        idx = idx + 1
    end

    self.Container.gw_num_slots = self.itemButtonPool:GetNumActive()
    layoutAccountBankItems(self)
    snapFrameSize(self:GetParent())
    local id = self:GetSelectedTabID()
    if id and id > 0 then
        inv.updateFreeSlots(self:GetParent().spaceString, id, id)
    end
end

local function reskinAccountBagBar(b)
    local bag_size = 28

    b:SetSize(bag_size, bag_size)

    b.Border:Hide()

    if b.Icon then
        b.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        b.Icon:SetAlpha(0.75)
        b.Icon:Show()
    end

    if b.icon then
        b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        b.icon:SetAlpha(0.75)
        b.icon:Show()
    end

    local norm = b:GetNormalTexture()
    if norm then
        norm:SetTexture(nil)
    end

    if not b.IconBorder then
        b.IconBorder = b:CreateTexture(nil, "ARTWORK")
    end

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    b.IconBorder:Show()
    hooksecurefunc(b.IconBorder, "SetTexture", function()
        if b.IconBorder:GetTexture() and b.IconBorder:GetTexture() > 0 and b.IconBorder:GetTexture() ~= "Interface/AddOns/GW2_UI/textures/bag/bagitemborder" then
            b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end
    end)

    b.SelectedTexture:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border")
    b.SelectedTexture:GwSetOutside()
    if not b.gwHooked then
        hooksecurefunc(b:GetParent(), "OnBankTabClicked", function(self)
            for btn in self.bankTabPool:EnumerateActive() do
                btn.SelectedTexture:SetShown(btn:IsEnabled() and btn:IsSelected())
            end
        end)
    end
    b.IsSelected = function(self) return self.tabData.ID == self:GetParent().selectedTabID end

    local high = b:GetHighlightTexture()
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)
    high:SetSize(bag_size, bag_size)
    high:ClearAllPoints()
    high:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
end

local function accountTabOnClick(self, button)
    if button == "RightButton" and not self:IsPurchaseTab() then
        self:GetParent().TabSettingsMenu:OnOpenTabSettingsRequested(self.tabData.ID)
        self:GetParent().TabSettingsMenu:OnNewBankTabSelected(self.tabData.ID)
    end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    if self:IsPurchaseTab() and C_Bank.CanPurchaseBankTab(self:GetParent().bankType) then
        self:GetParent().Container:Hide()
        self:GetParent():ShowPurchasePrompt()
    else
        self:GetParent().Container:Show()
        self:GetParent().PurchasePrompt:Hide()
        self:GetParent():OnBankTabClicked(self.tabData.ID)
        inv.updateFreeSlots(self:GetParent():GetParent().spaceString, self.tabData.ID, self.tabData.ID)
    end
end

local function refreshBankPanel(self)
    self:HideAllPrompts()
    if self:ShouldShowLockPrompt() then
        self:ShowLockPrompt()
        self.Container:Hide()
        return
    end

    if self:ShouldShowPurchasePrompt() then
        self:ShowPurchasePrompt();
        self.Container:Hide()
        return;
    end
    local noTabSelected = self.selectedTabID == nil;
    if noTabSelected then
        return;
    end

    takeOverBankItemButtons(self)

    self.Container:Show()
end

local function SelectFirstAvailableTab(self)
    local hasPurchasedTabs = self.purchasedBankTabData and #self.purchasedBankTabData > 0
    if hasPurchasedTabs then
        self:SelectTab(self.purchasedBankTabData[1].ID)
    elseif C_Bank.CanPurchaseBankTab(self.bankType) then
        self:SelectTab(PURCHASE_TAB_ID)
    end

    for btn in self.bankTabPool:EnumerateActive() do
        btn.SelectedTexture:SetShown(btn:IsEnabled() and btn:IsSelected())
    end
end

local function createAccountBagBar(f)
    local lastButton
    fetchPurchasedBankTabData(f)
    takeOverBankItemButtons(f)
    f.bankTabPool:ReleaseAll()

    if f.purchasedBankTabData then
        for _, bankTabData in ipairs(f.purchasedBankTabData) do
            local b = f.bankTabPool:Acquire()
            b:Init(bankTabData)

            b:RegisterForClicks("AnyUp")
            b.OnClick = accountTabOnClick
            b:SetScript("OnClick", b.OnClick)
            reskinAccountBagBar(b)

            b:SetParent(f)
            if not lastButton then
                b:SetPoint("TOPLEFT", f, "TOPLEFT", -40, -40)
            else
                b:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -4)
            end
            b:Show()
            lastButton = b
        end
    end

    -- ...followed by the button to purchase a new tab (if applicable)
    local showPurchaseTab = not f:IsBankTypeLocked() and not C_Bank.HasMaxBankTabs(f.bankType)
    if showPurchaseTab then
        f.PurchaseTab:Init({ ID = PURCHASE_TAB_ID, bankType = f.bankType })
        reskinAccountBagBar(f.PurchaseTab)
        f.PurchaseTab:SetParent(f)
        f.PurchaseTab:RegisterForClicks("AnyUp")
        f.PurchaseTab:SetScript("OnClick", accountTabOnClick)
        f.PurchaseTab:SetEnabledState(C_Bank.CanPurchaseBankTab(f.bankType))

        f.PurchaseTab:ClearAllPoints()
        if not lastButton then
            f.PurchaseTab:SetPoint("TOPLEFT", f, "TOPLEFT", -40, -40)
        else
            f.PurchaseTab:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -4)
        end

        f.PurchaseTab:Show()
    else
        f.PurchaseTab:Hide()
    end
end

local function onBankResizeStop(self)
    GW.settings.BANK_WIDTH = self:GetWidth()
    inv.onMoved(self, "BANK_POSITION", snapFrameSize)
end
GW.AddForProfiling("bank", "onBankResizeStop", onBankResizeStop)

local function onBankFrameChangeSize(self)
    local cols = inv.colCount(GW.settings.BAG_ITEM_SIZE, BANK_ITEM_PADDING, self:GetWidth())

    if not self.gw_bank_cols or self.gw_bank_cols ~= cols then
        self.gw_bank_cols = cols
    end
end

-- toggles the setting for compact/large icons
local function compactToggle()
    if GW.settings.BAG_ITEM_SIZE == BANK_ITEM_LARGE_SIZE then
        GW.settings.BAG_ITEM_SIZE = BANK_ITEM_COMPACT_SIZE
        inv.resizeInventory()
        return true
    end

    GW.settings.BAG_ITEM_SIZE = BANK_ITEM_LARGE_SIZE
    inv.resizeInventory()
    return false
end
GW.AddForProfiling("bank", "compactToggle", compactToggle)

local function bank_OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    self:RegisterEvent("BANK_TABS_CHANGED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("BANK_TAB_SETTINGS_UPDATED")

    -- hide the bank frame off screen
    BankFrame:ClearAllPoints()
    BankFrame:SetClampedToScreen(false)
    BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
    BankPanel.AutoSortButton:Hide()

    createAccountBagBar(self.BankPanel)
    snapFrameSize(self)
    inv.reskinItemButtons()
end
GW.AddForProfiling("bank", "bank_OnShow", bank_OnShow)

local function bank_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    self:UnregisterAllEvents()
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    C_Bank.CloseBankFrame()
end
GW.AddForProfiling("bank", "bank_OnHide", bank_OnHide)

local function bank_OnEvent(self, event, ...)
    if event == "BANKFRAME_OPENED" then
        self:Show()
    elseif event == "BANKFRAME_CLOSED" then
        self:Hide()
    elseif event == "BAG_UPDATE" then
        local containerID = select(1, ...)
        if self.BankPanel.selectedTabID == containerID then
            inv.updateFreeSlots(self.spaceString, containerID, containerID)
        end
    elseif event == "BANK_TABS_CHANGED" then
        createAccountBagBar(self.BankPanel)
    elseif event == "BANK_TAB_SETTINGS_UPDATED" then
        local bankType = ...
        if bankType == self.BankPanel.bankType then
            self.BankPanel.TabSettingsMenu:Hide()
        end
    end
end
GW.AddForProfiling("bank", "bank_OnEvent", bank_OnEvent)

local function tab_OnEnter(self)
    self.Icon:SetBlendMode("ADD")
end
GW.AddForProfiling("bank", "tab_OnEnter", tab_OnEnter)

local function tab_OnLeave(self)
    self.Icon:SetBlendMode("BLEND")
end
GW.AddForProfiling("bank", "tab_OnLeave", tab_OnLeave)

local function SkinAccountBankTabMenu(self)
    if self.isSkinned then return end
    -- skin tab menu
    local checkBoxes = {
        self.DepositSettingsMenu.AssignEquipmentCheckbox,
        self.DepositSettingsMenu.AssignConsumablesCheckbox,
        self.DepositSettingsMenu.AssignProfessionGoodsCheckbox,
        self.DepositSettingsMenu.AssignReagentsCheckbox,
        self.DepositSettingsMenu.AssignJunkCheckbox,
        self.DepositSettingsMenu.IgnoreCleanUpCheckbox,
    }

    self:GwStripTextures()
    self:EnableMouse(true)
    GW.HandleIconSelectionFrame(self)

    self.DepositSettingsMenu.ExpansionFilterDropdown:GwHandleDropDownBox()
    self.DepositSettingsMenu.ExpansionFilterDropdown:SetWidth(120)
    for _, checkBox in pairs(checkBoxes) do
        if checkBox then
            checkBox:GwSkinCheckButton()
            checkBox:SetSize(15, 15)
        end
    end

    self.isSkinned = true
end

local function LoadBank(helpers)
    inv = helpers

    if GW.settings.BAG_ITEM_SIZE > 40 then
        GW.settings.BAG_ITEM_SIZE = 40
    end

    -- create bank frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBankFrame", UIParent, "GwBankFrameTemplate")
    tinsert(UISpecialFrames, "GwBankFrame")
    f:ClearAllPoints()
    f:SetWidth(GW.settings.BANK_WIDTH)
    onBankFrameChangeSize(f)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(-f.Left:GetWidth(), 0, f.Header:GetHeight() - 10, 0)

    -- setup show/hide
    f:SetScript("OnShow", bank_OnShow)
    f:SetScript("OnHide", bank_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- re-hide the BankFrame any time it gets repositioned by UIParent stuff
    hooksecurefunc(BankFrame, "Raise", function()
        BankFrame:ClearAllPoints()
        BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
        BankPanel.AutoSortButton:Hide()
    end)

    -- setup movable stuff
    local pos = GW.settings.BANK_POSITION
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "BANK_POSITION"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetResizeBounds(340, 340)
    f:SetScript("OnSizeChanged", onBankFrameChangeSize)
    f.sizer.onResizeStop = onBankResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- take the original search box
    inv.reskinSearchBox(BankItemSearchBox)
    inv.relocateSearchBox(BankItemSearchBox, f)

    --Bank Panel Tab setup
    local cf = CreateFrame("Frame", nil, f.BankPanel)
    cf:SetAllPoints(f.BankPanel)
    cf.gw_items = {}
    cf.gw_num_slots = 0
    f.BankPanel.Container = cf
    f.BankPanel.bankType = Enum.BankType.Character -- always start with this one
    f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Character)
    f.BankPanel:SetBankType(Enum.BankType.Character)
    BankFrame.BankPanel:SetBankType(Enum.BankType.Character)

    BankPanelTabMixin.IsSelected = GW.NoOp

    f.BankPanel.ShouldShowPurchasePrompt = function(self)
        fetchPurchasedBankTabData(self)
        return C_Bank.CanPurchaseBankTab(f.BankPanel.bankType) and (not self.purchasedBankTabData or (self.purchasedBankTabData and #self.purchasedBankTabData == 0))
    end

    f.BankPanel.TabSettingsMenu = CreateFrame("Frame", nil, f, "BankPanelTabSettingsMenuTemplate")
    f.BankPanel.TabSettingsMenu.SetSelectedTab = function(self, selectedTabID)
        local alreadySelected = self:GetSelectedTabID() == selectedTabID
        if alreadySelected then
            return
        end

        fetchPurchasedBankTabData(f.BankPanel)

        if not f.BankPanel.purchasedBankTabData then
            self.selectedTabData = nil
        else
            for _, tabData in ipairs(f.BankPanel.purchasedBankTabData) do
                if tabData.ID == selectedTabID then
                    self.selectedTabData = tabData
                    break
                end
            end
        end
        if self:IsShown() then
            self:Update()
        end
    end
    f.BankPanel.TabSettingsMenu:Hide()
    f.BankPanel.TabSettingsMenu:OnLoad()
    f.BankPanel.TabSettingsMenu:SetScript("OnShow", function()
        f.BankPanel.TabSettingsMenu:OnShow()
        SkinAccountBankTabMenu(f.BankPanel.TabSettingsMenu)
    end)
    f.BankPanel.TabSettingsMenu:SetScript("OnHide", f.BankPanel.TabSettingsMenu.OnHide)

    f.BankPanel.AutoDepositFrame.DepositButton:GwSkinButton(false, true)
    f.BankPanel.AutoDepositFrame.DepositButton:ClearAllPoints()
    f.BankPanel.AutoDepositFrame.DepositButton:SetPoint("TOPLEFT", f.BankPanel, "BOTTOMLEFT", 5, -6)
    f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:ClearAllPoints()
    f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetPoint("TOPLEFT", f.BankPanel, "BOTTOMLEFT", 5, 20)
    f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:GwSkinCheckButton()
    f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetSize(15, 15)
    f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox.Text:SetTextColor(1, 1, 1)
    hooksecurefunc(f.BankPanel.AutoDepositFrame, "SetEnabled", function(_, enabled)
        local fontColor = enabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR
        f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox.Text:SetTextColor(fontColor:GetRGB())
    end)
    f.BankPanel.MoneyFrame:GwStripTextures()
    f.BankPanel.MoneyFrame.WithdrawButton:GwSkinButton(false, true)
    f.BankPanel.MoneyFrame.DepositButton:GwSkinButton(false, true)
    f.BankPanel.MoneyFrame.MoneyDisplay:ClearAllPoints()
    f.BankPanel.MoneyFrame.MoneyDisplay:SetPoint("BOTTOMRIGHT", f.BankPanel, "BOTTOMRIGHT", 3, -27)

    f.BankPanel.PurchasePrompt:GwStripTextures()
    f.BankPanel.PurchasePrompt:GwCreateBackdrop(GW.BackdropTemplates.Default)
    f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:GwSkinButton(false, true)
    f.BankPanel.LockPrompt:GwStripTextures()
    f.BankPanel.LockPrompt:GwCreateBackdrop(GW.BackdropTemplates.Default)

    -- setup money frame
    f.BankPanel.MoneyFrame.MoneyDisplay.CopperButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    f.BankPanel.MoneyFrame.MoneyDisplay.CopperButton.Text:SetTextColor(177 / 255, 97 / 255, 34 / 255)
    f.BankPanel.MoneyFrame.MoneyDisplay.SilverButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    f.BankPanel.MoneyFrame.MoneyDisplay.SilverButton.Text:SetTextColor(170 / 255, 170 / 255, 170 / 255)
    f.BankPanel.MoneyFrame.MoneyDisplay.GoldButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    f.BankPanel.MoneyFrame.MoneyDisplay.GoldButton.Text:SetTextColor(221 / 255, 187 / 255, 68 / 255)

    --sort popup
    BankCleanUpConfirmationPopup:GwStripTextures()
    local tex = BankCleanUpConfirmationPopup:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOPLEFT", BankCleanUpConfirmationPopup, "TOPLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", BankCleanUpConfirmationPopup, "BOTTOMRIGHT", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    BankCleanUpConfirmationPopup.Text:SetTextColor(1, 1, 1)
    BankCleanUpConfirmationPopup.AcceptButton:GwSkinButton(false, true)
    BankCleanUpConfirmationPopup.CancelButton:GwSkinButton(false, true)
    BankCleanUpConfirmationPopup.HidePopupCheckbox.Checkbox:GwSkinCheckButton(false, true)
    BankCleanUpConfirmationPopup.HidePopupCheckbox.Checkbox:SetSize(15, 15)
    BankCleanUpConfirmationPopup.HidePopupCheckbox.Label:SetTextColor(1, 1, 1)

    hooksecurefunc(f.BankPanel.Header, "SetShown", function(self) self:Hide() end)
    hooksecurefunc(f.BankPanel, "RefreshBankTabs", createAccountBagBar)
    hooksecurefunc(f.BankPanel, "RefreshBankPanel", refreshBankPanel)
    hooksecurefunc(f.BankPanel, "GenerateItemSlotsForSelectedTab", takeOverBankItemButtons)
    hooksecurefunc(C_Bank, "PurchaseBankTab", function() createAccountBagBar(f.BankPanel) end)
    hooksecurefunc(f.BankPanel, "SelectTab", function(_, id) BankFrame.BankPanel.selectedTabID = id end)

    -- skin some things not done in XML
    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    f.headerString:SetText(BANK)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)

    -- setup initial events (more are added when open in bank_OnEvent)
    f:SetScript("OnEvent", bank_OnEvent)
    f:RegisterEvent("BANKFRAME_OPENED")
    f:RegisterEvent("BANKFRAME_CLOSED")

    -- setup settings button and its dropdown items
    f.buttonSort:SetScript("OnClick",
        function(self)
            local bankType = self:GetParent().BankPanel.bankType
            local hasTabsToSort = bankType and C_Bank.FetchNumPurchasedBankTabs(bankType) > 0
            if not hasTabsToSort then
                return
            end

            if GetCVarBool("bankConfirmTabCleanUp") then
                StaticPopupSpecial_Show(BankCleanUpConfirmationPopup)
            else
                C_Container.SortBank(bankType)
                PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            end
        end
    )
    EnableTooltip(f.buttonSort, BAG_CLEANUP_BANK)
    EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
    f.buttonSettings:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            local check = rootDescription:CreateCheckbox(L["Compact Icons"], function() return GW.settings.BAG_ITEM_SIZE == BANK_ITEM_COMPACT_SIZE end, compactToggle)
            check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)

            check = rootDescription:CreateCheckbox(L["Reverse Bag Order"], function() return GW.settings.BANK_REVERSE_SORT end, function() GW.settings.BANK_REVERSE_SORT = not GW.settings.BANK_REVERSE_SORT; ContainerFrame_UpdateAll() end)
            check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)

            check = rootDescription:CreateCheckbox(L["Show Quality Color"], function() return GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW end, function() GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW; ContainerFrame_UpdateAll() end)
            check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
        end)
    end)

    -- setup bank/reagent switching tabs
    f.ItemTab:SetScript("OnEnter", tab_OnEnter)
    f.ItemTab:SetScript("OnLeave", tab_OnLeave)
    f.ItemTab:SetScript(
        "OnClick",
        function(self)
            BankFrame.BankPanel:SetBankType(Enum.BankType.Character)
            f.BankPanel:SetBankType(Enum.BankType.Character)
            f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Character)
            self:GetParent().buttonSort.tooltipText = BAG_CLEANUP_BANK
            f.BankPanel.MoneyFrame:RefreshContents()
            createAccountBagBar(f.BankPanel)
            SelectFirstAvailableTab(f.BankPanel)
        end
    )
    EnableTooltip(f.ItemTab, BANK)

    f.AccountTab:SetScript("OnEnter", tab_OnEnter)
    f.AccountTab:SetScript("OnLeave", tab_OnLeave)
    f.AccountTab:SetScript(
        "OnClick",
        function(self)
            BankFrame.BankPanel:SetBankType(Enum.BankType.Account)
            f.BankPanel:SetBankType(Enum.BankType.Account)
            f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Account)
            self:GetParent().buttonSort.tooltipText = BAG_CLEANUP_ACCOUNT_BANK
            f.BankPanel.MoneyFrame:RefreshContents()
            createAccountBagBar(f.BankPanel)
            SelectFirstAvailableTab(f.BankPanel)
        end
    )
    EnableTooltip(f.AccountTab, ACCOUNT_BANK_PANEL_TITLE)

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        takeOverBankItemButtons(f.BankPanel)
    end
    return changeItemSize
end
GW.LoadBank = LoadBank
