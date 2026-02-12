local _, GW = ...
local CommaValue = GW.CommaValue

local BAG_CURRENCY_SIZE = 32

local function checkNumWatched()
    local numWatched = 0

    for i = 1, GetCurrencyListSize() do
        local _, _, _, _, isWatched = GetCurrencyListInfo(i)
        if isWatched then
            numWatched = numWatched + 1
        end
    end

    return numWatched
end


local function currency_OnClick(self)
    if IsModifiedClick("TOKENWATCHTOGGLE") then
        if not self.CurrencyID or not self.CurrencyIdx then
            return
        end
        local _, _, _, _, isWatched = GetCurrencyListInfo(self.CurrencyIdx)
        if not isWatched then
            if checkNumWatched() >= MAX_WATCHED_TOKENS then
                UIErrorsFrame:AddMessage(format(TOO_MANY_WATCHED_TOKENS, MAX_WATCHED_TOKENS), 1.0, 0.1, 0.1, 1.0)
                return
            end
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            SetCurrencyBackpack(self.CurrencyIdx, 1)
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            SetCurrencyBackpack(self.CurrencyIdx, 0)
        end
    end
end


local function currency_OnEnter(self)
    if not self.CurrencyID or not self.CurrencyIdx then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetCurrencyToken(self.CurrencyIdx)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(SHOW_ON_BACKPACK, 1, 1, 1)
    GameTooltip:AddLine(TOKEN_SHOW_ON_BACKPACK, nil, nil, nil, true)
    GameTooltip:Show()
end


local function loadCurrency(curwin)
    local USED_CURRENCY_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(curwin)
    local currencyCount = GetCurrencyListSize()
    local name, isHeader, isExpanded, isWatched, curid

    for i = 1, #curwin.buttons do
        local slot = curwin.buttons[i]

        local idx = i + offset
        if idx > currencyCount then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.CurrencyID = nil
            slot.item.CurrencyIdx = nil
            slot.header:Hide()
        else
            name, isHeader, isExpanded, _, isWatched, _, _, _, _, _, _, curid = GetCurrencyListInfo(idx)
            if isHeader then
                slot.item:Hide()
                slot.item.CurrencyID = nil
                slot.item.CurrencyIdx = nil
                slot.header.spaceString:SetText(name)
                slot.header.isHeaderExpanded = isExpanded
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
                -- If is honor
                if curid == Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID then
                    slot.item.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 )
                else
                    slot.item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end

                -- set zebra color by idx or watch status
                zebra = idx % 2
                if isWatched then
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


local function header_OnClick(self)
    if self.isHeaderExpanded then
        ExpandCurrencyList(self.index, 0)
    else
        ExpandCurrencyList(self.index, 1)
    end

    loadCurrency(self.curwin)
end

local function currencySetup(curwin)
    HybridScrollFrame_CreateButtons(curwin, "GwCurrencyRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #curwin.buttons do
        local slot = curwin.buttons[i]
        slot:SetWidth(curwin:GetWidth() - 12)
        slot.header.spaceString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
        slot.header.spaceString:SetTextColor(1, 1, 1)
        slot.header.icon:ClearAllPoints()
        slot.header.icon:SetPoint("LEFT", 0, 0)
        slot.header.icon2:ClearAllPoints()
        slot.header.icon2:SetPoint("LEFT", 0, 0)
        slot.item.spaceString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        slot.item.amount:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        slot.item.icon:ClearAllPoints()
        slot.item.icon:SetPoint("LEFT", 0, 0)
        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnClick", currency_OnClick)
            slot.item:HookScript("OnEnter", currency_OnEnter)
            slot.item:HookScript("OnLeave", GameTooltip_Hide)
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


local function loadRaidInfo(raidinfo)
    local USED_RAID_INFO_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(raidinfo)
    local raidInfoCount = GetNumSavedInstances()

    for i = 1, #raidinfo.buttons do
        local slot = raidinfo.buttons[i]
        local instanceName, instanceID, instanceReset, difficult

        local idx = i + offset
        if idx > raidInfoCount then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.instanceID = nil
            slot.item.RaidInfoIdx = nil
        else
            instanceName, instanceID, instanceReset, _, _, _, _, _ , _, difficult = GetSavedInstanceInfo(idx)
            slot.item.instanceID = instanceID
            slot.item.RaidInfoIdx = idx

            -- set raidInfo values
            slot.item.reset:SetText(SecondsToTime(instanceReset, true, nil, 3))
            slot.item.name:SetText(instanceName)
            slot.item.difficult:SetText(difficult)
            slot.item.id:SetText("|cFF888888" .. ID .. ": " .. instanceID .. "|r")

            -- set zebra color by idx or watch status and show extended button
            zebra = idx % 2
            slot.item.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)

            slot.item:Show()
        end
    end

    USED_RAID_INFO_HEIGHT = 55 * raidInfoCount
    HybridScrollFrame_Update(raidinfo, USED_RAID_INFO_HEIGHT, 576)
end


local function raidInfoSetup(raidinfo)
    HybridScrollFrame_CreateButtons(raidinfo, "GwRaidInfoRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #raidinfo.buttons do
        local slot = raidinfo.buttons[i]
        slot:SetWidth(raidinfo:GetWidth() - 12)
        slot.item.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
        slot.item.name:SetTextColor(1, 1, 1)
        slot.item.name:SetShadowColor(0, 0, 0, 1)
        slot.item.name:SetShadowOffset(1, -1)

        slot.item.reset:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        slot.item.reset:SetTextColor(1, 1, 1)
        slot.item.difficult:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        slot.item.difficult:SetTextColor(1, 1, 1)
        slot.item.id:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        slot.item.id:SetTextColor(1, 1, 1)
        --save frame
        slot.item.frame = raidinfo
    end

    loadRaidInfo(raidinfo)
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


local function LoadCurrency()
    local currencyWindow = CreateFrame("Frame", "GwCurrencyDetailsFrame", GwCharacterWindow, "GwCharacterTabContainer")

    -- setup the currency window as a HybridScrollFrame and init each of the faux frame buttons
    local curwin_outer = CreateFrame("Frame", "GwCharacterCurrencyRaidInfoFrame", currencyWindow, "GwCurrencyWindow")
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
        "SetCurrencyBackpack",
        function()
            if curwin:IsShown() then
                loadCurrency(curwin)
            end
        end
    )

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
    local fmMenu = CreateFrame("Frame", "GWCurrencyMenu", currencyWindow, "GwCharacterMenuTemplate")
    fmMenu.items = {}

    local item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = curwin
    item:SetScript("OnClick", menuItem_OnClick)
    item:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    item:SetText(CURRENCY)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.items.currency = item

    item = CreateFrame("Button", "GwRaidInfoFrame", fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = raidinfo
    item:SetScript("OnClick", menuItem_OnClick)
    item:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    item:SetText(RAID_INFORMATION)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.currency, "BOTTOMLEFT")
    fmMenu.items.raidinfo = item

    GW.CharacterMenuButton_OnLoad(fmMenu.items.currency, false)
    GW.CharacterMenuButton_OnLoad(fmMenu.items.raidinfo, true)

    return currencyWindow
end
GW.LoadCurrency = LoadCurrency
