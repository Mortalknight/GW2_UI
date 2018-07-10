local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local CommaValue = GW.CommaValue

local BAG_CURRENCY_SIZE = 32

local function currency_OnClick(self)
    if not self.CurrencyID or not self.CurrencyIdx then
        return
    end
    local _, _, _, _, isWatched, _ = GetCurrencyListInfo(self.CurrencyIdx)
    local toggle = 1
    if isWatched then
        toggle = 0
    end
    SetCurrencyBackpack(self.CurrencyIdx, toggle)
end

local function currency_OnEnter(self)
    if not self.CurrencyID or not self.CurrencyIdx then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetCurrencyToken(self.CurrencyIdx)
    GameTooltip:AddLine(GwLocalization["CLICK_TO_TRACK"], 1, 1, 1)
    GameTooltip:Show()
end

local function loadCurrency(curwin)
    local USED_CURRENCY_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(curwin)
    local currencyCount = GetCurrencyListSize()
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
            local count, icon, maximum
            local name, isHeader, _, _, isWatched, _ = GetCurrencyListInfo(idx)
            if isHeader then
                slot.item:Hide()
                slot.item.CurrencyID = nil
                slot.item.CurrencyIdx = nil
                slot.header.spaceString:SetText(name)
                slot.header:Show()
            else
                slot.header:Hide()

                -- parse out the currency ID to get more accurate info
                local link = GetCurrencyListLink(idx)
                local _, _, _, _, curid, _ =
                    string.find(
                    link,
                    "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%]%[]*)%]?|?h?|?r?"
                )
                name, count, icon, _, _, maximum, _, _ = GetCurrencyInfo(curid)
                slot.item.CurrencyID = curid
                slot.item.CurrencyIdx = idx

                -- set currency item values
                slot.item.spaceString:SetText(name)
                if maximum == 0 then
                    slot.item.amount:SetText(CommaValue(count))
                else
                    slot.item.amount:SetText(CommaValue(count) .. " / " .. CommaValue(maximum))
                end
                slot.item.icon:SetTexture(icon)

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

local function currencySetup(curwin)
    HybridScrollFrame_CreateButtons(curwin, "GwCurrencyRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #curwin.buttons do
        local slot = curwin.buttons[i]
        slot:SetWidth(curwin:GetWidth() - 12)
        slot.header.spaceString:SetFont(DAMAGE_TEXT_FONT, 14)
        slot.header.spaceString:SetTextColor(1, 1, 1)
        slot.item.spaceString:SetFont(UNIT_NAME_FONT, 12)
        slot.item.spaceString:SetTextColor(1, 1, 1)
        slot.item.amount:SetFont(UNIT_NAME_FONT, 12)
        slot.item.amount:SetTextColor(1, 1, 1)
        slot.item.icon:ClearAllPoints()
        slot.item.icon:SetPoint("LEFT", 0, 0)
        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnClick", currency_OnClick)
            slot.item:HookScript("OnEnter", currency_OnEnter)
            slot.item:HookScript("OnLeave", GameTooltip_Hide)
            slot.item.ScriptsHooked = true
        end
    end

    loadCurrency(curwin)
end

local function menuItem_OnClick(self, button)
    local menuItems = self:GetParent().items
    for k, v in pairs(menuItems) do
        v:SetNormalTexture(nil)
        v.ToggleMe:Hide()
    end
    self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.ToggleMe:Show()
end

local function LoadCurrency(tabContainer)
    -- setup the currency window as a HybridScrollFrame and init each of the faux frame buttons
    local curwin_outer = CreateFrame("Frame", nil, tabContainer, "GwCurrencyWindow")
    local curwin = curwin_outer.CurrencyScroll

    curwin.update = loadCurrency
    curwin.scrollBar.doNotHide = true
    currencySetup(curwin)

    -- update currency window when a currency update event occurs
    curwin:SetScript(
        "OnEvent",
        function(self, event, ...)
            if event == "CURRENCY_DISPLAY_UPDATE" then
                if self:IsShown() then
                    loadCurrency(self)
                end
            --watchCurrency()
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

    -- setup a menu frame
    local fmMenu = CreateFrame("Frame", nil, tabContainer, "GwCharacterMenu")
    fmMenu.items = {}

    local item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = curwin
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(CURRENCY)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.items["currency"] = item

    item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    item.ToggleMe = raidinfo
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(RAID_INFO)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items["currency"], "BOTTOMLEFT")
    fmMenu.items["raidinfo"] = item

    CharacterMenuButton_OnLoad(fmMenu.items["currency"], false)
    CharacterMenuButton_OnLoad(fmMenu.items["raidinfo"], true)

    fmMenu.items["currency"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
end
GW.LoadCurrency = LoadCurrency
