local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local CommaValue = GW.CommaValue

local BAG_CURRENCY_SIZE = 32
local MAX_WATCHED_TOKENS = 4
local selectedLongInstanceID = nil

local function checkNumWatched()
    local numWatched = 0

    for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        if info.isShowInBackpack then
            numWatched = numWatched + 1
        end
    end

    return numWatched
end
GW.AddForProfiling("currency", "checkNumWatched", checkNumWatched)

local function currency_OnClick(self, button)
    if IsModifiedClick("TOKENWATCHTOGGLE") then
        if not self.CurrencyID or not self.CurrencyIdx then
            return
        end
        local info = C_CurrencyInfo.GetCurrencyListInfo(self.CurrencyIdx)
        if not info.isShowInBackpack then
            if checkNumWatched() >= MAX_WATCHED_TOKENS then
                UIErrorsFrame:AddMessage(format(TOO_MANY_WATCHED_TOKENS, MAX_WATCHED_TOKENS), 1.0, 0.1, 0.1, 1.0)
                return
            end
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            C_CurrencyInfo.SetCurrencyBackpack(self.CurrencyIdx, true)
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            C_CurrencyInfo.SetCurrencyBackpack(self.CurrencyIdx, false)
        end
    elseif button == "LeftButton" and IsAltKeyDown() then
        local info = C_CurrencyInfo.GetCurrencyListInfo(self.CurrencyIdx)

        if info.isTypeUnused then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            C_CurrencyInfo.SetCurrencyUnused(self.CurrencyIdx, false)
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            C_CurrencyInfo.SetCurrencyUnused(self.CurrencyIdx, true)
        end

        GWCharacterCurrenyRaidInfoFrame.CurrencyScroll.update(GWCharacterCurrenyRaidInfoFrame.CurrencyScroll)
    end
end
GW.AddForProfiling("currency", "currency_OnClick", currency_OnClick)

local function currency_OnEnter(self)
    if not self.CurrencyID or not self.CurrencyIdx then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetCurrencyToken(self.CurrencyIdx)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(SHOW_ON_BACKPACK, GW.L["Shift + Left Click"], nil, nil, nil, 1, 1, 1)
    GameTooltip:AddDoubleLine(UNUSED, GW.L["Alt + Left Click"], nil, nil, nil, 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("currency", "currency_OnEnter", currency_OnEnter)

local DISABLED_ERROR_MESSAGE = {
	[Enum.AccountCurrencyTransferResult.MaxQuantity] = CURRENCY_TRANSFER_DISABLED_MAX_QUANTITY,
	[Enum.AccountCurrencyTransferResult.NoValidSourceCharacter] = CURRENCY_TRANSFER_DISABLED_NO_VALID_SOURCES,
	[Enum.AccountCurrencyTransferResult.CannotUseCurrency] = CURRENCY_TRANSFER_DISABLED_UNMET_REQUIREMENTS,
};

local CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS = {
	"CURRENCY_DISPLAY_UPDATE",
	"CURRENCY_TRANSFER_FAILED",
	"ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED",
};

local function GetDisabledErrorMessage(dataReady, failureReason)
    if not dataReady then
		return RETRIEVING_DATA
	end

	return DISABLED_ERROR_MESSAGE[failureReason]
end

local function accountWideIconOnEvent(self, event)
    if event == "CURRENCY_DISPLAY_UPDATE" or event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED" or event == "CURRENCY_TRANSFER_FAILED" then
		if not self:GetParent():GetParent().CurrencyID then
            self:GetParent().isEnabled = false
            return
        end

        local dataReady = C_CurrencyInfo.IsAccountCharacterCurrencyDataReady()
        local canTransfer, failureReason = C_CurrencyInfo.CanTransferCurrency(self:GetParent():GetParent().CurrencyID)
        self:GetParent().isEnabled = dataReady and canTransfer
        self:GetParent().disabledTooltip = GetDisabledErrorMessage(dataReady, failureReason) or nil

        local isValidCurrency = failureReason ~= Enum.AccountCurrencyTransferResult.InvalidCurrency
        local hasDisabledTooltip = self:GetParent().disabledTooltip ~= nil
        self:GetParent():SetShown(self:GetParent().isEnabled or (isValidCurrency and hasDisabledTooltip))
	end
end

local function accountWideIconOnEnter(self)
    accountWideIconOnEvent(self.eventFrame, "CURRENCY_DISPLAY_UPDATE")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local tooltipLine = self:GetParent().isAccountTransferable and ACCOUNT_TRANSFERRABLE_CURRENCY or ACCOUNT_LEVEL_CURRENCY
	GameTooltip_AddNormalLine(GameTooltip, tooltipLine)

    if not self.isEnabled and self.disabledTooltip then
        GameTooltip_AddErrorLine(GameTooltip, self.disabledTooltip)
    end

	GameTooltip:Show()
end

local function accountWideIconOnClick(self)
    if not self:GetParent().CurrencyID or not self.isEnabled then
		return
	end

    CurrencyTransferMenu:TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferRequested, self:GetParent().CurrencyID)
    CurrencyTransferMenu:ClearAllPoints()
    CurrencyTransferMenu:SetPoint("TOPLEFT", GwCharacterWindow, "TOPRIGHT", 0, 0)
end

local function loadCurrency(curwin)
    local USED_CURRENCY_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(curwin)
    local currencyCount = C_CurrencyInfo.GetCurrencyListSize()

    for i = 1, #curwin.buttons do
        local slot = curwin.buttons[i]

        local idx = i + offset
        if idx > currencyCount then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.CurrencyID = nil
            slot.item.CurrencyIdx = nil
            slot.item.isAccountWide = false
            slot.item.isAccountTransferable = false
            slot.header:Hide()
        else
            local info = C_CurrencyInfo.GetCurrencyListInfo(idx)
            if info.isHeader then
                slot.item:Hide()
                slot.item.CurrencyID = nil
                slot.item.CurrencyIdx = nil
                slot.header.spaceString:SetText(info.name)
                slot.header.isHeaderExpanded = info.isHeaderExpanded
                slot.header.index = idx
                if slot.header.isHeaderExpanded then
                    slot.header.icon:Show()
                    slot.header.icon2:Hide()
                else
                    slot.header.icon:Hide()
                    slot.header.icon2:Show()
                end
                slot.header:Show()
            else
                slot.header:Hide()

                -- parse out the currency ID to get more accurate info
                local link = C_CurrencyInfo.GetCurrencyListLink(idx)
                local _, _, _, _, curid, _ =
                    string.find(
                    link,
                    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%]%[]*)%]?|?h?|?r?"
                )
                local cinfo = C_CurrencyInfo.GetCurrencyInfo(curid)
                slot.item.CurrencyID = curid
                slot.item.CurrencyIdx = idx

                -- set currency item values
                slot.item.spaceString:SetText(cinfo.name)
                if cinfo.maxQuantity == 0 then
                    slot.item.amount:SetText(CommaValue(cinfo.quantity))
                else
                    slot.item.amount:SetText(CommaValue(cinfo.quantity) .. " / " .. CommaValue(cinfo.maxQuantity))
                end
                if cinfo.quantity == 0 then
                    slot.item.amount:SetFontObject("GameFontDisable")
                    slot.item.spaceString:SetFontObject("GameFontDisable")
                else
                    slot.item.amount:SetFontObject("GameFontHighlight")
                    slot.item.spaceString:SetFontObject("GameFontHighlight")
                end
                slot.item.icon:SetTexture(cinfo.iconFileID)
                slot.item.isAccountTransferable = C_CurrencyInfo.IsAccountTransferableCurrency(curid)
                slot.item.isAccountWide = C_CurrencyInfo.IsAccountWideCurrency(curid)

                if slot.item.isAccountWide then
                    slot.item.accountWideIcon.Icon:SetAtlas("warbands-icon", TextureKitConstants.UseAtlasSize)
                    slot.item.accountWideIcon.Icon:SetScale(0.9)
                elseif slot.item.isAccountTransferable then
                    slot.item.accountWideIcon.Icon:SetAtlas("warbands-transferable-icon", TextureKitConstants.UseAtlasSize)
                    slot.item.accountWideIcon.Icon:SetScale(0.9)
                else
                    slot.item.accountWideIcon.Icon:SetAtlas(nil)
                end

                -- set zebra color by idx or watch status
                zebra = idx % 2
                if info.isShowInBackpack then
                    slot.item.zebra:SetVertexColor(1, 1, 0.5, 0.15)
                else
                    slot.item.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
                end

                slot.item:Show()
            end
        end
    end

    USED_CURRENCY_HEIGHT = BAG_CURRENCY_SIZE * currencyCount
    HybridScrollFrame_Update(curwin, USED_CURRENCY_HEIGHT, 576)
end
GW.AddForProfiling("currency", "loadCurrency", loadCurrency)

local function header_OnClick(self)
    if self.isHeaderExpanded then
        C_CurrencyInfo.ExpandCurrencyList(self.index, false)
    else
        C_CurrencyInfo.ExpandCurrencyList(self.index, true)
    end

    loadCurrency(self.curwin)
end

local function currencySetup(curwin)
    HybridScrollFrame_CreateButtons(curwin, "GwCurrencyRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #curwin.buttons do
        local slot = curwin.buttons[i]
        slot:SetWidth(curwin:GetWidth() - 12)
        slot.header.spaceString:SetFont(DAMAGE_TEXT_FONT, 14)
        slot.header.spaceString:SetTextColor(1, 1, 1)
        slot.header.icon:ClearAllPoints()
        slot.header.icon:SetPoint("LEFT", 0, 0)
        slot.header.icon2:ClearAllPoints()
        slot.header.icon2:SetPoint("LEFT", 0, 0)
        slot.item.spaceString:SetFont(UNIT_NAME_FONT, 12)
        slot.item.amount:SetFont(UNIT_NAME_FONT, 12)
        slot.item.icon:ClearAllPoints()
        slot.item.icon:SetPoint("LEFT", 0, 0)
        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnClick", currency_OnClick)
            slot.item:HookScript("OnEnter", currency_OnEnter)
            slot.item:HookScript("OnLeave", GameTooltip_Hide)
            slot.item.accountWideIcon:SetScript("OnClick", accountWideIconOnClick)
            slot.item.accountWideIcon:SetScript("OnEnter", accountWideIconOnEnter)
            slot.item.accountWideIcon.eventFrame:SetScript("OnEvent", accountWideIconOnEvent)
            slot.item.accountWideIcon:SetScript("OnLeave", GameTooltip_Hide)
            slot.item.accountWideIcon:SetScript("OnShow", function(self)
                FrameUtil.RegisterFrameForEvents(self.eventFrame, CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS);
                C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
            end)
            slot.item.accountWideIcon:SetScript("OnHide", function(self)
                FrameUtil.UnregisterFrameForEvents(self.eventFrame, CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS);
            end)
            slot.item.ScriptsHooked = true
        end
        if not slot.header.ScriptsHooked then
            slot.header:HookScript("OnClick", header_OnClick)
            slot.header.curwin = curwin
            slot.header.ScriptsHooked = true
        end
    end

    loadCurrency(curwin)
end
GW.AddForProfiling("currency", "currencySetup", currencySetup)

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

local function LoadCurrency(tabContainer)
    -- setup the currency window as a HybridScrollFrame and init each of the faux frame buttons
    local curwin_outer = CreateFrame("Frame", "GWCharacterCurrenyRaidInfoFrame", tabContainer, "GwCurrencyWindow")
    local curwin = curwin_outer.CurrencyScroll

    curwin.update = loadCurrency
    curwin.scrollBar.doNotHide = true
    currencySetup(curwin)

    -- update currency window when a currency update event occurs
    curwin:SetScript(
        "OnEvent",
        function(self)
            if GW.inWorld and self:IsShown() then
                loadCurrency(self)
            end
        end
    )
    curwin:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    -- update currency window when anyone adds a watch currency
    hooksecurefunc(
        C_CurrencyInfo, "SetCurrencyBackpack",
        function()
            if curwin:IsShown() then
                loadCurrency(curwin)
            end
        end
    )

    -- setup transfer history
    local curHistroyWin = curwin_outer.CurrencyTransferHistoryScroll
    curHistroyWin.update = function(self) self:Refresh() end
    transferHistorySetup(curHistroyWin)

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
    item.ToggleMe = curwin
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
