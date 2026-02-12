local _, GW = ...
local L = GW.L
local EnableTooltip = GW.EnableTooltip
local inv

local BANK_ITEM_LARGE_SIZE = 40
local BANK_ITEM_COMPACT_SIZE = 32
local BANK_ITEM_PADDING = 5
local PURCHASE_TAB_ID = -1

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutAccountBankItems(f)
    inv.layoutContainerFrame(f, f:GetParent().gw_bank_cols, 0, 0, false, GW.settings.BAG_ITEM_SIZE + BANK_ITEM_PADDING)
end


-- adjusts the bank frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    inv.snapFrameSize(f, f.BankPanel, GW.settings.BAG_ITEM_SIZE, BANK_ITEM_PADDING, 370)
end


local function GrabBankItemButtons(self)
    local idx = 1
    for itemButton in self:EnumerateValidItems() do
        self.gw_items[idx] = itemButton
        inv.reskinItemButton(itemButton)

        idx = idx + 1
    end

    self.gw_num_slots = self.itemButtonPool:GetNumActive()
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
    b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    b.IconBorder:Show()
    hooksecurefunc(b.IconBorder, "SetTexture", function()
        if b.IconBorder:GetTexture() and b.IconBorder:GetTexture() > 0 and b.IconBorder:GetTexture() ~= "Interface/AddOns/GW2_UI/textures/bag/bagitemborder" then
            b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
        end
    end)

    b.SelectedTexture:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border.png")
    b.SelectedTexture:GwSetOutside()
    if not b.gwHooked then
        hooksecurefunc(b, "OnClick", function(self)
            for btn in self:GetParent().bankTabPool:EnumerateActive() do
                btn.SelectedTexture:SetShown(btn:IsEnabled() and btn:IsSelected())
            end
        end)
    end

    local high = b:GetHighlightTexture()
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
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

    if f.purchasedBankTabData then
        for _, bankTabData in ipairs(f.purchasedBankTabData) do
            local b = f.bankTabPool:Acquire()
            b.GetBankPanel = function() return f end
            b.GetActiveBankType = function() return f:GetActiveBankType() end
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
        f.PurchaseTab.GetBankPanel = function() return f end
        f.PurchaseTab.GetActiveBankType = function() return f:GetActiveBankType() end
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


local function OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

    -- hide the bank frame off screen
    BankFrame:ClearAllPoints()
    BankFrame:SetClampedToScreen(false)
    BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
    BankPanel.AutoSortButton:Hide()

    OpenAllBags(self.BankPanel)
    self.BankPanel:FetchPurchasedBankTabData()
    GrabBankItemButtons(self.BankPanel)
    RefreshBankTabs(self.BankPanel)
    snapFrameSize(self)
    inv.reskinItemButtons()
end


local function OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
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
    f.BankPanel.gw_items = {}
    f.BankPanel.gw_num_slots = 0
    f.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetAttribute("overrideBankType", Enum.BankType.Character)
    f.BankPanel:SetBankType(Enum.BankType.Character) -- always start with this one

    f.BankPanel.TabSettingsMenu = CreateFrame("Frame", nil, f, "BankPanelTabSettingsMenuTemplate")
    f.BankPanel.TabSettingsMenu.GetBankPanel = function() return f.BankPanel end
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
    hooksecurefunc(f.BankPanel, "GenerateItemSlotsForSelectedTab", GrabBankItemButtons)

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
    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    f.headerString:SetText(BANK)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
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
            local check = rootDescription:CreateCheckbox(L["Compact Icons"], function() return GW.settings.BAG_ITEM_SIZE == BANK_ITEM_COMPACT_SIZE end, compactToggle)
            check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)

            check = rootDescription:CreateCheckbox(L["Show Quality Color"], function() return GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW end, function() GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW; f.BankPanel:Reset() end)
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
        GrabBankItemButtons(f.BankPanel)
    end
    return changeItemSize
end
GW.LoadBank = LoadBank
