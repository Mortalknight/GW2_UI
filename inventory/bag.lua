local _, GW = ...
local CommaValue = GW.CommaValue
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local UpdateMoney = GW.UpdateMoney
local GetRealmMoney = GW.GetRealmMoney
local GetCharClass = GW.GetCharClass
local GetRealmStorage = GW.GetRealmStorage
local ClearStorage = GW.ClearStorage

local BAG_ITEM_SIZE = 40
local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 480
local BAG_WINDOW_CONTENT_HEIGHT = 0

local default_bag_frame = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot"
}

local default_bag_frame_container = {
    "ContainerFrame1",
    "ContainerFrame2",
    "ContainerFrame3",
    "ContainerFrame4",
    "ContainerFrame5",
    "ContainerFrame6"
}

local function bagFrameHide()
    GwBagMoverFrame:Hide()
    CloseAllBags()
end
GW.AddForProfiling("bag", "bagFrameHide", bagFrameHide)

local function bagFrameShow()
    GwBagMoverFrame:Show()
end
GW.AddForProfiling("bag", "bagFrameShow", bagFrameShow)

local function moveBagbar()
    local y = 25

    for k, v in pairs(default_bag_frame) do
        local fv = _G[v]

        fv:ClearAllPoints()
        fv:SetParent(GwBagFrame)
        fv:SetPoint("TOPLEFT", GwBagFrame, "TOPLEFT", -35, -y)
        _G[v .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        fv:SetNormalTexture(nil)
        fv:SetHighlightTexture(nil)
        fv.IconBorder:SetTexture(nil)

        if v == "MainMenuBarBackpackButton" then
            MainMenuBarBackpackButton:SetSize(32, 32)
        -- resize it
        end

        local s = fv:GetScript("OnClick")
        fv:SetScript(
            "OnClick",
            function(self, b)
                if b == "RightButton" then
                    local parent = _G[default_bag_frame_container[k]]
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                    ToggleDropDownMenu(1, nil, parent.FilterDropDown, self, 32, 32)
                else
                    s(fv)
                end
            end
        )

        y = y + 32
    end
end
GW.AddForProfiling("bag", "moveBagbar", moveBagbar)

local function updateMoney(self)
    if not self then
        return
    end
    local money = GetMoney()

    local gold = math.floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = math.floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(money, COPPER_PER_SILVER)

    self.bronze:SetText(copper)
    self.silver:SetText(silver)
    self.gold:SetText(CommaValue(gold))

    UpdateMoney()
end
GW.AddForProfiling("bag", "updateMoney", updateMoney)

local function updateFreeSlots()
    local free = 0
    local full = 0

    for i = 0, NUM_BAG_SLOTS do
        free = free + GetContainerNumFreeSlots(i)
        full = full + GetContainerNumSlots(i)
    end

    free = full - free
    local bag_space_string = free .. " / " .. full
    GwBagFrame.spaceString:SetText(bag_space_string)
end
GW.AddForProfiling("bag", "updateFreeSlots", updateFreeSlots)

local function createItemBackground(name)
    return CreateFrame("Frame", "GwBagItemBackdrop" .. name, GwBagFrame, "GwBagItemBackdrop")
end
GW.AddForProfiling("bag", "createItemBackground", createItemBackground)

local function updateBagIcons(smooth)
    moveBagbar()
    local x = 8
    local y = 72
    local mx = 0
    local gwbf = GwBagFrame
    local winsize = BAG_WINDOW_SIZE
    if smooth then
        winsize = gwbf:GetWidth()
    end
    winsize = math.max(508, winsize)

    local bStart = 1
    local bEnd = 5
    local bStep = 1
    if GetSetting("BAG_REVERSE_SORT") then
        bStart = 5
        bEnd = 1
        bStep = -1
    end
    for BAG_INDEX = bStart, bEnd, bStep do
        local cfm = "ContainerFrame" .. tostring(BAG_INDEX)

        if _G[cfm] and _G[cfm]:IsShown() then
            for i = 40, 1, -1 do
                local slot = _G[cfm .. "Item" .. i]
                if slot and slot:IsShown() then
                    if x > (winsize - 40) then
                        mx = math.max(mx, x)
                        x = 8
                        y = y + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                    end

                    local slotIcon = _G[cfm .. "Item" .. i .. "IconTexture"]
                    local slotNormalTexture = _G[cfm .. "Item" .. i .. "NormalTexture"]
                    local slotQuesttexture = _G[cfm .. "Item" .. i .. "IconQuestTexture"]
                    local slotCount = _G[cfm .. "Item" .. i .. "Count"]
                    local backdrop = _G["GwBagItemBackdrop" .. cfm .. "Item" .. i]
                    if backdrop == nil then
                        backdrop = createItemBackground(cfm .. "Item" .. i)
                    end
                    slot:GetParent():ClearAllPoints()
                    backdrop:ClearAllPoints()
                    backdrop:SetParent(_G[cfm])
                    backdrop:SetFrameLevel(1)

                    backdrop:SetPoint("TOPLEFT", gwbf, "TOPLEFT", x, -y)
                    backdrop:SetPoint("TOPRIGHT", gwbf, "TOPLEFT", x + BAG_ITEM_SIZE, -y)
                    backdrop:SetPoint("BOTTOMLEFT", gwbf, "TOPLEFT", x, -y - BAG_ITEM_SIZE)
                    backdrop:SetPoint("BOTTOMRIGHT", gwbf, "TOPLEFT", x + BAG_ITEM_SIZE, -y - BAG_ITEM_SIZE)

                    _G["GwBagContainer" .. (BAG_INDEX - 1)]:SetSize(x, y)

                    slot:ClearAllPoints()
                    slot:SetFrameLevel(43)
                    slot:SetPoint("TOPLEFT", gwbf, "TOPLEFT", x, -y)
                    slot:SetPoint("TOPRIGHT", gwbf, "TOPLEFT", x + BAG_ITEM_SIZE, -y)
                    slot:SetPoint("BOTTOMLEFT", gwbf, "TOPLEFT", x, -y - BAG_ITEM_SIZE)
                    slot:SetPoint("BOTTOMRIGHT", gwbf, "TOPLEFT", x + BAG_ITEM_SIZE, -y - BAG_ITEM_SIZE)

                    if slotCount then
                        slotCount:ClearAllPoints()
                        slotCount:SetPoint("TOPRIGHT", slotCount:GetParent(), "TOPRIGHT", 0, -3)
                        slotCount:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
                        slotCount:SetJustifyH("RIGHT")
                    end

                    if slot.IconBorder then
                        slot.IconBorder:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")
                        slot.IconBorder:SetSize(BAG_ITEM_SIZE, BAG_ITEM_SIZE)
                        if slot.IconBorder.GwhasBeenHooked == nil then
                            hooksecurefunc(
                                slot.IconBorder,
                                "SetVertexColor",
                                function()
                                    slot.IconBorder:SetTexture(
                                        "Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder"
                                    )
                                end
                            )
                            slot.IconBorder.GwhasBeenHooked = true
                        end
                    end

                    if slotQuesttexture then
                        slotQuesttexture:SetSize(BAG_ITEM_SIZE, BAG_ITEM_SIZE)
                    end
                    if slotNormalTexture then
                        slot:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal")
                    end
                    if slot.flash then
                        slot.flash:SetSize(BAG_ITEM_SIZE, BAG_ITEM_SIZE)
                    end

                    slotIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    x = x + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                end
            end
        end
    end

    updateFreeSlots()
    if smooth then
        return
    end

    BAG_WINDOW_CONTENT_HEIGHT = math.max(350, y + BAG_ITEM_SIZE + (2 * BAG_ITEM_PADDING))
    if mx ~= 0 then
        BAG_WINDOW_SIZE = mx + BAG_ITEM_PADDING
    end
    SetSetting("BAG_WIDTH", BAG_WINDOW_SIZE)
    gwbf:SetSize(BAG_WINDOW_SIZE, BAG_WINDOW_CONTENT_HEIGHT)
end
GW.AddForProfiling("bag", "updateBagIcons", updateBagIcons)

local function compactToggle()
    if BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
        BAG_ITEM_SIZE = BAG_ITEM_COMPACT_SIZE
        SetSetting("BAG_ITEM_SIZE", BAG_ITEM_SIZE)
        updateBagIcons()
        return GwLocalization["EXPAND_ICONS"] --Local?
    end

    BAG_ITEM_SIZE = BAG_ITEM_LARGE_SIZE
    SetSetting("BAG_ITEM_SIZE", BAG_ITEM_SIZE)
    updateBagIcons()
    return GwLocalization["COMPACT_ICONS"] --Local?
end
GW.AddForProfiling("bag", "compactToggle", compactToggle)

local function watchCurrency(self)
    local watchSlot = 1
    local currencyCount = GetCurrencyListSize()
    for i = 1, currencyCount do
        local _, isHeader, _, _, isWatched, count, icon, _ = GetCurrencyListInfo(i)
        if not isHeader and isWatched and watchSlot < 4 then
            self["currency" .. tostring(watchSlot)]:SetText(count)
            self["currency" .. tostring(watchSlot) .. "Texture"]:SetTexture(icon)
            watchSlot = watchSlot + 1
        end
    end

    for i = watchSlot, 3 do
        self["currency" .. tostring(i)]:SetText("")
        self["currency" .. tostring(i) .. "Texture"]:SetTexture(nil)
    end
end
GW.AddForProfiling("bag", "watchCurrency", watchCurrency)

local function showIcons()
    local gwbf = GwBagFrame
    watchCurrency(gwbf)
    OpenAllBags()
    BagItemSearchBox:Show()
    gwbf.spaceString:Show()
    gwbf.buttonSettings:Show()
    gwbf.buttonSort:Show()
    ContainerFrame1:Show()
end
GW.AddForProfiling("bag", "showIcons", showIcons)

local function CloseBags()
    local o = false

    for i = 1, 12 do
        local cfm = _G["ContainerFrame" .. tostring(i)]
        if cfm and cfm:IsShown() then
            cfm:SetParent(gwNormalBagHolder)
            gwNormalBagHolder:ClearAllPoints()
            cfm:ClearAllPoints()
            cfm:SetPoint("RIGHT", gwNormalBagHolder, "LEFT", 0, 0)
            if i < 6 then
                o = true
            end
        end
    end
    if not o then
        GwBagFrame:Hide()
        return
    end
    GwBagFrame:Show()
end
GW.CloseBags = CloseBags

local function relocateSearchBox()
    local sb = BagItemSearchBox

    sb:ClearAllPoints()
    sb:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    sb:SetPoint("TOPLEFT", GwBagFrame, "TOPLEFT", 8, -40)
    sb:SetPoint("TOPRIGHT", GwBagFrame, "TOPRIGHT", -8, -40)

    sb.Left:SetTexture(nil)
    sb.Right:SetTexture(nil)
    BagItemSearchBoxSearchIcon:Hide()
    sb.Middle:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagsearchbg")

    sb:SetHeight(24)

    sb.Middle:SetPoint("RIGHT", sb, "RIGHT", 0, 0)

    sb.Middle:SetHeight(24)
    sb.Middle:SetTexCoord(0, 1, 0, 1)
    sb.SetPoint = function()
    end
    sb.ClearAllPoints = function()
    end
end
GW.AddForProfiling("bag", "relocateSearchBox", relocateSearchBox)

local function onBagMove(self)
    self:StopMovingOrSizing()
    local saveBagPos = {}
    saveBagPos["point"], _, saveBagPos["relativePoint"], saveBagPos["xOfs"], saveBagPos["yOfs"] = self:GetPoint()
    SetSetting("BAG_POSITION", saveBagPos)
end
GW.AddForProfiling("bag", "onBagMove", onBagMove)

local function onBagResizeStop(self)
    GW.Debug("onBagResizeStop")

    BAG_WINDOW_SIZE = GwBagFrame:GetWidth()
    updateBagIcons()

    GwBagFrame:ClearAllPoints()
    GwBagFrame:SetPoint("TOPLEFT", GwBagMoverFrame, "TOPLEFT", 20, -40)

    local mfPoint, _, mfRelPoint, mfxOfs, mfyOfs = GwBagMoverFrame:GetPoint()
    local newWidth = GwBagFrame:GetWidth() - 40
    local oldWidth = GwBagMoverFrame:GetWidth()
    if mfPoint == "TOP" then
        mfxOfs = mfxOfs + ((newWidth - oldWidth) / 2)
    elseif mfPoint == "RIGHT" then
        mfxOfs = mfxOfs + (newWidth - oldWidth)
    end
    GwBagMoverFrame:ClearAllPoints()
    GwBagMoverFrame:SetPoint(mfPoint, UIParent, mfRelPoint, mfxOfs, mfyOfs)
    GwBagMoverFrame:SetWidth(newWidth)
    onBagMove(GwBagMoverFrame)
end
GW.AddForProfiling("bag", "onBagResizeStop", onBagResizeStop)

local function onBagFrameChangeSize(self)
    local w = self:GetWidth()
    local isize = BAG_ITEM_SIZE + BAG_ITEM_PADDING
    local cols = math.floor((w - 3) / isize)

    if not self.gwPrevBagCols or self.gwPrevBagCols ~= cols then
        GW.Debug("new cols is: ", cols)
        self.gwPrevBagCols = cols
        updateBagIcons(true)
    end
end
GW.AddForProfiling("bag", "onBagFrameChangeSize", onBagFrameChangeSize)

local function onSizerMouseDown(self, btn)
    if btn ~= "LeftButton" then
        return
    end
    local bfm = self:GetParent()
    bfm:StartSizing("BOTTOMRIGHT")
end
GW.AddForProfiling("bag", "onSizerMouseDown", onSizerMouseDown)

local function onSizerMouseUp(self, btn)
    if btn ~= "LeftButton" then
        return
    end
    local bfm = self:GetParent()
    bfm:StopMovingOrSizing()
    onBagResizeStop(bfm)
end
GW.AddForProfiling("bag", "onSizerMouseUp", onSizerMouseUp)

local function LoadBag()
    BAG_WINDOW_SIZE = GetSetting("BAG_WIDTH")
    BAG_ITEM_SIZE = GetSetting("BAG_ITEM_SIZE")
    if BAG_ITEM_SIZE > 40 then
        BAG_ITEM_SIZE = 40
        SetSetting("BAG_ITEM_SIZE", 40)
    end

    CreateFrame("Frame", "gwNormalBagHolder", UIParent)
    gwNormalBagHolder:SetPoint("LEFT", UIParent, "RIGHT")
    gwNormalBagHolder:SetFrameStrata("HIGH")

    -- create mover frame, restore its saved position, and setup drag to move
    local bagPos = GetSetting("BAG_POSITION")
    local fm = CreateFrame("Frame", "GwBagMoverFrame", UIParent, "GwBagMoverFrame")
    fm:SetWidth(BAG_WINDOW_SIZE - 40)
    fm:ClearAllPoints()
    fm:SetPoint(bagPos.point, UIParent, bagPos.relativePoint, bagPos.xOfs, bagPos.yOfs)
    fm:RegisterForDrag("LeftButton")
    fm:HookScript(
        "OnDragStart",
        function(self)
            self:StartMoving()
        end
    )
    fm:HookScript("OnDragStop", onBagMove)

    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBagFrame", UIParent, "GwBagFrame")
    tinsert(UISpecialFrames, "GwBagFrame")
    f:SetWidth(BAG_WINDOW_SIZE)
    updateBagIcons()

    f.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    f.headerString:SetText(INVENTORY_TOOLTIP)

    f.spaceString:SetFont(UNIT_NAME_FONT, 12)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)
    updateFreeSlots()

    f.bronze:SetFont(UNIT_NAME_FONT, 12)
    f.bronze:SetTextColor(177 / 255, 97 / 255, 34 / 255)
    f.silver:SetFont(UNIT_NAME_FONT, 12)
    f.silver:SetTextColor(170 / 255, 170 / 255, 170 / 255)
    f.gold:SetFont(UNIT_NAME_FONT, 12)
    f.gold:SetTextColor(221 / 255, 187 / 255, 68 / 255)
    updateMoney(f)

    f.currency1:SetFont(UNIT_NAME_FONT, 12)
    f.currency1:SetTextColor(1, 1, 1)
    f.currency2:SetFont(UNIT_NAME_FONT, 12)
    f.currency2:SetTextColor(1, 1, 1)
    f.currency3:SetFont(UNIT_NAME_FONT, 12)
    f.currency3:SetTextColor(1, 1, 1)
    watchCurrency(f)

    -- money tooltip
    GwMoneyFrame:SetScript(
        "OnEnter",
        function(self)
            local list, total = GetRealmMoney()
            if list then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:ClearLines()

                -- list all players from the realm+faction
                for name, money in pairs(list) do
                    local color = select(4, GetClassColor(GetCharClass(name)))
                    SetTooltipMoney(GameTooltip, money, "TOOLTIP", ("|c%s%s|r:"):format(color, name))
                end

                -- add total gold on realm+faction
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                SetTooltipMoney(GameTooltip, total, "TOOLTIP", TOTAL .. ":")

                GameTooltip:Show()

                -- align money frames to the right
                local maxWidth = 0
                for i = 1, GameTooltip.shownMoneyFrames do
                    local name = "GameTooltipMoneyFrame" .. i
                    local textWidth = _G[name .. "PrefixText"]:GetWidth()
                    local moneyWidth = select(4, _G[name .. "CopperButton"]:GetPoint(1))
                    maxWidth = max(maxWidth, textWidth + moneyWidth)
                end
                for i = 1, GameTooltip.shownMoneyFrames do
                    local name = "GameTooltipMoneyFrame" .. i
                    local textWidth = _G[name .. "PrefixText"]:GetWidth()
                    _G[name .. "CopperButton"]:SetPoint("RIGHT", name .. "PrefixText", "RIGHT", maxWidth - textWidth, 0)
                end
            end
        end
    )

    -- clear money storage on right-click
    GwMoneyFrame:SetScript(
        "OnClick",
        function(self, button)
            if button == "RightButton" then
                ClearStorage(GetRealmStorage("MONEY"))
                UpdateMoney()
                GwMoneyFrame:GetScript("OnEnter")(GwMoneyFrame)
            end
        end
    )

    -- update money and watch currencies when applicable
    f:SetScript(
        "OnEvent",
        function(self, event, ...)
            if not GW.inWorld then
                return
            end
            if event == "PLAYER_MONEY" then
                updateMoney(self)
            elseif event == "CURRENCY_DISPLAY_UPDATE" then
                watchCurrency(self)
            end
        end
    )
    f:RegisterEvent("PLAYER_MONEY")
    f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    hooksecurefunc(
        "SetCurrencyBackpack",
        function()
            watchCurrency(f)
        end
    )

    -- setup settings button and its dropdown items
    f.buttonSort:HookScript(
        "OnClick",
        function(self)
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            SortBags()
        end
    )
    f.buttonSort:HookScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -40)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(BAG_CLEANUP_BAGS, 1, 1, 1)
            GameTooltip:Show()
        end
    )
    f.buttonSort:HookScript("OnLeave", GameTooltip_Hide)
    do
        local dd = f.buttonSettings.dropdown
        f.buttonSettings:HookScript(
            "OnClick",
            function(self)
                if dd:IsShown() then
                    dd:Hide()
                else
                    dd:Show()
                end
            end
        )

        dd.compactBags:HookScript(
            "OnClick",
            function(self)
                self:SetText(compactToggle())
                dd:Hide()
            end
        )

        dd.newOrder:HookScript(
            "OnClick",
            function(self)
                if GetInsertItemsLeftToRight() then
                    dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_LAST"])
                    SetInsertItemsLeftToRight(false)
                else
                    dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_FIRST"])
                    SetInsertItemsLeftToRight(true)
                end
                dd:Hide()
            end
        )

        dd.sortOrder:HookScript(
            "OnClick",
            function(self)
                if GetSortBagsRightToLeft() then
                    dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_FIRST"])
                    SetSortBagsRightToLeft(false)
                else
                    dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_LAST"])
                    SetSortBagsRightToLeft(true)
                end
                dd:Hide()
            end
        )

        dd.bagOrder:HookScript(
            "OnClick",
            function(self)
                if GetSetting("BAG_REVERSE_SORT") then
                    dd.bagOrder:SetText(GwLocalization["BAG_ORDER_REVERSE"])
                    SetSetting("BAG_REVERSE_SORT", false)
                else
                    dd.bagOrder:SetText(GwLocalization["BAG_ORDER_NORMAL"])
                    SetSetting("BAG_REVERSE_SORT", true)
                end
                updateBagIcons()
                dd:Hide()
            end
        )

        if BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
            dd.compactBags:SetText(GwLocalization["COMPACT_ICONS"])
        else
            dd.compactBags:SetText(GwLocalization["EXPAND_ICONS"])
        end
        if GetInsertItemsLeftToRight() then
            dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_FIRST"])
        else
            dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_LAST"])
        end
        if GetSortBagsRightToLeft() then
            dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_LAST"])
        else
            dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_FIRST"])
        end
        if GetSetting("BAG_REVERSE_SORT") then
            dd.bagOrder:SetText(GwLocalization["BAG_ORDER_NORMAL"])
        else
            dd.bagOrder:SetText(GwLocalization["BAG_ORDER_REVERSE"])
        end
    end

    -- setup close button
    f.buttonClose:HookScript("OnClick", CloseAllBags)

    -- setup resizer stuff
    f:SetMinResize(508, 340)
    f:HookScript("OnSizeChanged", onBagFrameChangeSize)
    f.sizer:HookScript("OnMouseDown", onSizerMouseDown)
    f.sizer:HookScript("OnMouseUp", onSizerMouseUp)

    f:SetScript("OnHide", bagFrameHide)
    f:SetScript("OnShow", bagFrameShow)
    f:Hide()

    -- enable the bag window currency button to open currency frame
    --[[if GetSetting("USE_CHARACTER_WINDOW") then
        -- the necessary frame ref gets set by the character.lua loader
        GwCurrencyIcon:SetAttribute(
            "_onclick",
            [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
            ]=]
        )
    else
    --]]
    GwCurrencyIcon:SetScript(
        "OnClick",
        function(self, button)
            ToggleCharacter("TokenFrame")
        end
    )
    --end

    -- hook into default bag frames to re-use default bag bars and search box
    for i = 1, #default_bag_frame_container do
        local fv = _G[default_bag_frame_container[i]]
        fv:SetFrameStrata("HIGH")
        fv:SetFrameLevel(5)

        local fc = _G["GwBagContainer" .. tostring(i - 1)]
        local relocate = nil
        if i == 1 then
            relocate = relocateSearchBox
        end
        if fv and i < 6 then
            fv:HookScript(
                "OnShow",
                function()
                    showIcons()
                    CloseBags()
                    if relocate then
                        relocate()
                    end
                    updateBagIcons()
                    if fc then
                        fc:Show()
                    end
                end
            )
            fv:HookScript(
                "OnHide",
                function()
                    CloseBags()
                    updateBagIcons()
                    if fc then
                        fc:Hide()
                    end
                end
            )
        end
    end
    BagItemSearchBox:SetScript(
        "OnEvent",
        function(self, event, ...)
            if not GW.inWorld then
                return
            end
            if event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
                relocateSearchBox()
                updateBagIcons()
            --updateFreeSlots()
            end
        end
    )
    BagItemSearchBox:RegisterEvent("BAG_UPDATE_DELAYED")
    BagItemSearchBox:RegisterEvent("BAG_UPDATE")
end
GW.LoadBag = LoadBag
