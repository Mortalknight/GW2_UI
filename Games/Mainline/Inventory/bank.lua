---@class GW2
local GW = select(2, ...)
local L = GW.L
local EnableTooltip = GW.EnableTooltip
local inv

local PURCHASE_TAB_ID = -1
local BORDER_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutAccountBankItems(cf)
    if not GW.settings.BANK_ITEM_SIZE or not GW.settings.BANK_ITEM_SPACING_X or not GW.settings.BANK_ITEM_SPACING_Y then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end
    local item_off_x = GW.settings.BANK_ITEM_SIZE + GW.settings.BANK_ITEM_SPACING_X
    local item_off_y = GW.settings.BANK_ITEM_SIZE + GW.settings.BANK_ITEM_SPACING_Y
    inv.layoutContainerFrame(cf, GwBankFrame.gw_bank_cols, 0, 0, true, item_off_x, item_off_y)
end


-- adjusts the bank frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    inv.snapFrameSize(f, f.BankPanel.gw_container, GW.settings.BANK_ITEM_SIZE, GW.settings.BANK_ITEM_SPACING_X, GW.settings.BANK_ITEM_SPACING_Y, 370)
end


-- the retail bank item button mixin reads the tab and slot from these fields
-- (never store a field named slotID on the button, that taints the mixin)
local BANK_BUTTON_OPTS = {
    frameType = "ItemButton",
    template = "BankItemButtonTemplate",
    initButton = function(button, tabID, slotID)
        button.bankTabID = tabID
        button.containerSlotID = slotID
    end,
}

-- (re)builds our own item buttons for the selected bank tab; the bank tabs are
-- ordinary containers, so the shared factory and content updates apply directly
local function UpdateBankItemButtons(self)
    local f = self:GetParent()
    local cf = self.gw_container
    local tabID = self:GetSelectedTabID()

    -- hide blizzards pooled item buttons, we render our own
    for itemButton in self:EnumerateValidItems() do
        itemButton:Hide()
    end

    local hasTab = tabID and tabID > 0
    cf:SetShown(hasTab)

    if hasTab then
        cf:SetID(tabID)
        GW.SetupOwnContainerItemButtons(cf, tabID, GW.settings.BANK_ITEM_SIZE, true, BANK_BUTTON_OPTS)
    else
        cf.gw_num_slots = 0
        for i = 1, #(cf.gw_items or {}) do
            cf.gw_items[i]:Hide()
        end
    end

    layoutAccountBankItems(cf)
    snapFrameSize(f)
    if hasTab then
        inv.updateFreeSlots(f.spaceString, tabID, tabID)
    end
end

local function reskinAccountBagBar(b)
    local bag_size = 28

    b:SetSize(bag_size, bag_size)

    b.Border:Hide()

    for _, icon in next, {b.Icon, b.icon} do
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:SetAlpha(0.75)
        icon:Show()
    end

    local norm = b:GetNormalTexture()
    if norm then
        norm:SetTexture(nil)
    end

    if not b.IconBorder then
        b.IconBorder = b:CreateTexture(nil, "ARTWORK")
    end

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture(BORDER_TEXTURE)
    b.IconBorder:Show()

    b.SelectedTexture:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border.png")
    b.SelectedTexture:GwSetOutside()
    if not b.gwHooked then
        b.gwHooked = true
        -- these hooks must only be added once, the pooled tab buttons run through
        -- this skin again on every tab refresh
        hooksecurefunc(b.IconBorder, "SetTexture", function()
            if b.IconBorder:GetTexture() ~= BORDER_TEXTURE then
                b.IconBorder:SetTexture(BORDER_TEXTURE)
            end
        end)
        hooksecurefunc(b, "OnClick", function(self)
            for btn in self:GetParent().bankTabPool:EnumerateActive() do
                btn.SelectedTexture:SetShown(btn:IsEnabled() and btn:IsSelected())
            end
        end)
    end

    local high = b:GetHighlightTexture()
    high:SetTexture(BORDER_TEXTURE)
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)
    high:SetSize(bag_size, bag_size)
    high:ClearAllPoints()
    high:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
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

local function RefreshBankTabs(f)
    local lastButton
    f.bankTabPool:ReleaseAll()

    f.gwGetBankPanel = f.gwGetBankPanel or function() return f end
    f.gwGetActiveBankType = f.gwGetActiveBankType or function() return f:GetActiveBankType() end

    if f.purchasedBankTabData then
        for _, bankTabData in ipairs(f.purchasedBankTabData) do
            local b = f.bankTabPool:Acquire()
            b.GetBankPanel = f.gwGetBankPanel
            b.GetActiveBankType = f.gwGetActiveBankType
            b:Init(bankTabData)

            b:RegisterForClicks("AnyUp")
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
        f.PurchaseTab.GetBankPanel = f.gwGetBankPanel
        f.PurchaseTab.GetActiveBankType = f.gwGetActiveBankType
        f.PurchaseTab:Init({ ID = PURCHASE_TAB_ID, bankType = f.bankType })
        reskinAccountBagBar(f.PurchaseTab)
        f.PurchaseTab:SetParent(f)
        f.PurchaseTab:RegisterForClicks("AnyUp")
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


local function onBankFrameChangeSize(self)
    local size = GW.settings.BANK_ITEM_SIZE
    local spacing = GW.settings.BANK_ITEM_SPACING_X
    if not size or not spacing then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end
    local cols = inv.colCount(size, spacing, self:GetWidth())

    self.gw_bank_cols = cols
end

local BANK_WATCH_EVENTS = {"ITEM_LOCK_CHANGED", "BAG_UPDATE", "BAG_UPDATE_COOLDOWN", "INVENTORY_SEARCH_UPDATE"}

local function OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

    FrameUtil.RegisterFrameForEvents(self.gw_watcher, BANK_WATCH_EVENTS)

    -- hide the bank frame off screen
    BankFrame:ClearAllPoints()
    BankFrame:SetClampedToScreen(false)
    BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
    BankPanel.AutoSortButton:Hide()

    OpenAllBags(self.BankPanel)
    self.BankPanel:FetchPurchasedBankTabData()
    UpdateBankItemButtons(self.BankPanel)
    RefreshBankTabs(self.BankPanel)
    snapFrameSize(self)
end


local function OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    FrameUtil.UnregisterFrameForEvents(self.gw_watcher, BANK_WATCH_EVENTS)
    self:UnregisterAllEvents()
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    CloseAllBags(self.BankPanel)
    C_Bank.CloseBankFrame()
end


local function OnEvent(self, event, ...)
    if event == "BANKFRAME_OPENED" then
        BankFrame.BankPanel:SetBankType(Enum.BankType.Character)
        self:GetParent():Show()
        BankFrame.BankPanel:Show()
    elseif event == "BANKFRAME_CLOSED" then
        self:GetParent():Hide()
        BankFrame.BankPanel:Hide()
    elseif event == "BAG_UPDATE" then
        local containerID = ...
        if self.selectedTabID == containerID then
            inv.updateFreeSlots(self:GetParent().spaceString, containerID, containerID)
        end
    end
end


local function tab_OnEnter(self)
    self.Icon:SetBlendMode("ADD")
end


local function tab_OnLeave(self)
    self.Icon:SetBlendMode("BLEND")
end


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

    -- create bank frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBankFrame", UIParent, "GwBankFrameTemplateMainline")
    tinsert(UISpecialFrames, "GwBankFrame")
    f:ClearAllPoints()
    f:SetWidth(GW.settings.BANK_WIDTH)
    onBankFrameChangeSize(f)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(-f.Left:GetWidth(), 0, f.Header:GetHeight() - 10, -35)

    -- setup show/hide
    f:SetScript("OnShow", OnShow)
    f:SetScript("OnHide", OnHide)
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
    cf.gw_items = {}
    cf.gw_num_slots = 0
    cf:SetAllPoints(f.BankPanel)
    cf.GetBagID = cf.GetID
    f.BankPanel.gw_container = cf

    -- keep our own buttons in sync outside of blizzards panel refreshes; only while the
    -- bank is open, these events fire constantly during normal play
    local watcher = CreateFrame("Frame")
    f.gw_watcher = watcher
    watcher:SetScript("OnEvent", function(_, event, ...)
        if cf.gw_num_slots == 0 then
            return
        end
        if event == "ITEM_LOCK_CHANGED" then
            local bag, slot = ...
            if bag == cf:GetID() and slot then
                GW.UpdateOwnContainerLockedState(cf, slot)
            end
        elseif event == "BAG_UPDATE" then
            local bag = ...
            if bag == cf:GetID() then
                GW.UpdateOwnContainerItemButtons(cf)
            end
        elseif event == "BAG_UPDATE_COOLDOWN" then
            GW.UpdateOwnContainerCooldowns(cf)
        elseif event == "INVENTORY_SEARCH_UPDATE" then
            GW.UpdateOwnContainerSearchResults(cf)
        end
    end)
    f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Character)
    f.BankPanel:SetBankType(Enum.BankType.Character) -- always start with this one

    -- take blizzards own tab settings menu instead of building a second one from the
    -- template: creating it ourselves runs the templates OnLoad, so a manual OnLoad on
    -- top of it wired the icon selector and the callback registry twice, which left the
    -- icon preview out of sync and made OK save the default question mark icon
    local tabSettingsMenu = BankFrame.BankPanel and BankFrame.BankPanel.TabSettingsMenu
    f.BankPanel.TabSettingsMenu = tabSettingsMenu
    if tabSettingsMenu then
        tabSettingsMenu.GetBankPanel = function() return f.BankPanel end
        tabSettingsMenu:SetParent(f)
        tabSettingsMenu:ClearAllPoints()
        tabSettingsMenu:SetPoint("TOPLEFT", f, "TOPRIGHT", 40, 5)
        tabSettingsMenu:EnableMouse(true) -- lets the player drop an icon onto the menu
        tabSettingsMenu:HookScript("OnShow", SkinAccountBankTabMenu)
        -- its OnLoad registered this against blizzards panel, ours needs it too so that
        -- picking another tab while the menu is open retargets the menu
        tabSettingsMenu:AddDynamicEventMethod(f.BankPanel, BankPanelMixin.Event.NewBankTabSelected, tabSettingsMenu.OnNewBankTabSelected)
    end

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
    f.BankPanel.MoneyFrame.MoneyDisplay.CopperButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    f.BankPanel.MoneyFrame.MoneyDisplay.CopperButton.Text:SetTextColor(177 / 255, 97 / 255, 34 / 255)
    f.BankPanel.MoneyFrame.MoneyDisplay.SilverButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    f.BankPanel.MoneyFrame.MoneyDisplay.SilverButton.Text:SetTextColor(170 / 255, 170 / 255, 170 / 255)
    f.BankPanel.MoneyFrame.MoneyDisplay.GoldButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    f.BankPanel.MoneyFrame.MoneyDisplay.GoldButton.Text:SetTextColor(221 / 255, 187 / 255, 68 / 255)

    --sort popup
    BankCleanUpConfirmationPopup:GwStripTextures()
    BankCleanUpConfirmationPopup.tex = BankCleanUpConfirmationPopup:CreateTexture(nil, "BACKGROUND")
    BankCleanUpConfirmationPopup.tex:SetPoint("TOPLEFT", BankCleanUpConfirmationPopup, "TOPLEFT", 0, 0)
    BankCleanUpConfirmationPopup.tex:SetPoint("BOTTOMRIGHT", BankCleanUpConfirmationPopup, "BOTTOMRIGHT", 0, 0)
    BankCleanUpConfirmationPopup.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    BankCleanUpConfirmationPopup.Text:SetTextColor(1, 1, 1)
    BankCleanUpConfirmationPopup.AcceptButton:GwSkinButton(false, true)
    BankCleanUpConfirmationPopup.CancelButton:GwSkinButton(false, true)
    BankCleanUpConfirmationPopup.HidePopupCheckbox.Checkbox:GwSkinCheckButton(false, true)
    BankCleanUpConfirmationPopup.HidePopupCheckbox.Checkbox:SetSize(15, 15)
    BankCleanUpConfirmationPopup.HidePopupCheckbox.Label:SetTextColor(1, 1, 1)

    hooksecurefunc(f.BankPanel.Header, "SetShown", function(self) self:Hide() end)
    hooksecurefunc(f.BankPanel, "GenerateItemSlotsForSelectedTab", UpdateBankItemButtons)
    -- RefreshBankPanel returns early once a prompt takes over, so the item slots are never
    -- generated and our buttons would keep covering the purchase and lock prompts; follow
    -- blizzards own item area switch, it is called for both prompts and the normal path
    hooksecurefunc(f.BankPanel, "SetItemDisplayEnabled", function(self, enable)
        self.gw_container:SetShown(enable)
    end)

    f.BankPanel.RefreshBankTabs = RefreshBankTabs

    f.BankPanel.AutoDepositFrame.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.AutoDepositFrame.DepositButton.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.AutoDepositFrame.IncludeReagentsCheckbox.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.MoneyFrame.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.MoneyFrame.MoneyDisplay.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.MoneyFrame.WithdrawButton.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.MoneyFrame.DepositButton.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.LockPrompt.GetBankPanel = function() return f.BankPanel end
    f.BankPanel.PurchasePrompt.GetBankPanel = function() return f.BankPanel end
    BankCleanUpConfirmationPopup.GetBankPanel = function() return f.BankPanel end
    f.GetActiveBankType = function() return f.BankPanel:GetActiveBankType() end

    -- skin some things not done in XML
    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    f.headerString:SetText(BANK)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)

    -- setup initial events (more are added when open in bank_OnEvent)
    f.BankPanel:HookScript("OnEvent", OnEvent)
    f.BankPanel:RegisterEvent("BANKFRAME_OPENED")
    f.BankPanel:RegisterEvent("BANKFRAME_CLOSED")

    -- setup settings button and its dropdown items
    f.buttonSort:SetScript("OnClick",
        function(self)
            local bankType = self:GetParent():GetActiveBankType()
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
            rootDescription:SetMinimumWidth(1)
            inv.addItemSizeMenuEntries(rootDescription, "BANK")

            local check = rootDescription:CreateCheckbox(L["Show Quality Color"], function() return GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW end, function() GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW; f.BankPanel:Reset() end)
            check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
        end)
    end)

    -- setup bank/reagent switching tabs
    f.ItemTab:SetScript("OnEnter", tab_OnEnter)
    f.ItemTab:SetScript("OnLeave", tab_OnLeave)
    f.ItemTab:SetScript(
        "OnClick",
        function()
            f.buttonSort.tooltipText = BAG_CLEANUP_BANK
            BankFrame.BankPanel:SetBankType(Enum.BankType.Character)
            f.BankPanel:SetBankType(Enum.BankType.Character)
            f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Character)
            f.BankPanel.MoneyFrame:RefreshContents()
            RefreshBankTabs(f.BankPanel)
            SelectFirstAvailableTab(f.BankPanel)
        end
    )
    EnableTooltip(f.ItemTab, BANK)

    f.AccountTab:SetScript("OnEnter", tab_OnEnter)
    f.AccountTab:SetScript("OnLeave", tab_OnLeave)
    f.AccountTab:SetScript(
        "OnClick",
        function()
            f.buttonSort.tooltipText = BAG_CLEANUP_ACCOUNT_BANK
            BankFrame.BankPanel:SetBankType(Enum.BankType.Account)
            f.BankPanel:SetBankType(Enum.BankType.Account)
            f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Account)
            f.BankPanel.MoneyFrame:RefreshContents()
            RefreshBankTabs(f.BankPanel)
            SelectFirstAvailableTab(f.BankPanel)
        end
    )
    EnableTooltip(f.AccountTab, ACCOUNT_BANK_PANEL_TITLE)

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        UpdateBankItemButtons(f.BankPanel)
    end
    return changeItemSize
end
GW.LoadBank = LoadBank
