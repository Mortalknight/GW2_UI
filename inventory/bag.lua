local _, GW = ...
local CommaValue = GW.CommaValue
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local UpdateMoney = GW.UpdateMoney
local GetRealmMoney = GW.GetRealmMoney
local GetCharClass = GW.GetCharClass
local GetRealmStorage = GW.GetRealmStorage
local ClearStorage = GW.ClearStorage
local BAG_TYP_COLORS = GW.BAG_TYP_COLORS

local BAG_ITEM_SIZE = 40
local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 480
local BAG_WINDOW_CONTENT_HEIGHT = 0

local CONTAINER_TYP_2 = 0
local CONTAINER_TYP_3 = 0
local CONTAINER_TYP_4 = 0
local CONTAINER_TYP_5 = 0

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
    "ContainerFrame5"
}

local function bagFrameHide(self)
    self:UnregisterEvent("BAG_UPDATE_DELAYED")
    GwBagMoverFrame:Hide()
    GwBagFrameResize:Hide()
    CloseAllBags()
end
GW.AddForProfiling("bag", "bagFrameHide", bagFrameHide)

local function bagFrameShow(self)
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    GwBagMoverFrame:Show()
    GwBagFrameResize:Show()
end
GW.AddForProfiling("bag", "bagFrameShow", bagFrameShow)

local function getBagType()
    for k, v in pairs(default_bag_frame) do
        local fv = _G[v]
        local bagItemLink = GetInventoryItemLink("player", fv:GetID())
        if bagItemLink ~= nil and select(9,GetItemInfo(bagItemLink))=="INVTYPE_BAG" then
            if v == "CharacterBag0Slot" then
                CONTAINER_TYP_2 = GetItemFamily(bagItemLink)
            elseif v == "CharacterBag1Slot" then
                CONTAINER_TYP_3 = GetItemFamily(bagItemLink)
            elseif v == "CharacterBag2Slot" then
                CONTAINER_TYP_4 = GetItemFamily(bagItemLink)
            elseif v == "CharacterBag3Slot" then
                CONTAINER_TYP_5 = GetItemFamily(bagItemLink)
            end
        end
    end
end

local function moveBagbar()
    local y = 25

    for k, v in pairs(default_bag_frame) do
        local fv = _G[v]

        fv:ClearAllPoints()
        fv:SetParent(GwBagFrame)
        fv:SetPoint("TOPLEFT", GwBagFrame, "TOPLEFT", -35, -y)
        fv:SetSize(32, 32)
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
                s(fv)
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

local function SetItemButtonQuality()
    getBagType()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local btnID = _G["ContainerFrame" .. bag + 1 .. "Item" .. slot]:GetID()
            local _, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(bag, btnID)
            local btn = _G["ContainerFrame" .. bag + 1 .. "Item" .. slot]

            if btn then
                if quality then           
                    if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
                        btn.IconBorder:Show()
                        btn.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
                    else
                        btn.IconBorder:Hide()
                    end
                else
                    btn.IconBorder:Hide()
                end
                if itemID ~= nil then
                    local isQuestItem = select(6, GetItemInfo(itemID))
                    if isQuestItem == BATTLE_PET_SOURCE_2 then 
                        btn.IconBorder:Show()
                        btn.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\stancebar-border')
                    end
                end
                --SetBorder for profession bags
                if bag == 1 and CONTAINER_TYP_2 > 0 then
                    btn.IconBorder:Show()
                    btn.IconBorder:SetVertexColor(BAG_TYP_COLORS[CONTAINER_TYP_2].r, BAG_TYP_COLORS[CONTAINER_TYP_2].g, BAG_TYP_COLORS[CONTAINER_TYP_2].b)
                elseif bag == 2 and CONTAINER_TYP_3 > 0 then
                    btn.IconBorder:Show()
                    btn.IconBorder:SetVertexColor(BAG_TYP_COLORS[CONTAINER_TYP_3].r, BAG_TYP_COLORS[CONTAINER_TYP_3].g, BAG_TYP_COLORS[CONTAINER_TYP_3].b)
                elseif bag == 3 and CONTAINER_TYP_4 > 0 then
                    btn.IconBorder:Show()
                    btn.IconBorder:SetVertexColor(BAG_TYP_COLORS[CONTAINER_TYP_4].r, BAG_TYP_COLORS[CONTAINER_TYP_4].g, BAG_TYP_COLORS[CONTAINER_TYP_4].b)
                elseif bag == 4 and CONTAINER_TYP_5 > 0 then
                    btn.IconBorder:Show()
                    btn.IconBorder:SetVertexColor(BAG_TYP_COLORS[CONTAINER_TYP_5].r, BAG_TYP_COLORS[CONTAINER_TYP_5].g, BAG_TYP_COLORS[CONTAINER_TYP_5].b)
                end
            end
        end
    end
end

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


local function showIcons()
    local gwbf = GwBagFrame
    OpenAllBags()
    gwbf.spaceString:Show()
    gwbf.buttonSettings:Show()
    ContainerFrame1:Show()
end
GW.AddForProfiling("bag", "showIcons", showIcons)

local function CloseBags()
    local o = false

    for i = 1, 12 do
        local cfm = _G["ContainerFrame" .. tostring(i)]
        if cfm and cfm:IsShown() then
            cfm:SetParent(gwNormalBagHolder)
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

local function onBagMove(self)
    self:StopMovingOrSizing()
    local saveBagPos = {}
    saveBagPos["point"], _, saveBagPos["relativePoint"], saveBagPos["xOfs"], saveBagPos["yOfs"] = self:GetPoint()
    SetSetting("BAG_POSITION", saveBagPos)
    GwBagFrameResize:SetPoint("BOTTOMRIGHT", GwBagFrame, "BOTTOMRIGHT", 0, 0)
end
GW.AddForProfiling("bag", "onBagMove", onBagMove)

local function bagOnResizeStop(self)
    GwBagFrame:SetScript("OnUpdate", nil)
    self:StopMovingOrSizing()

    BAG_WINDOW_SIZE = GwBagFrame:GetWidth()
    updateBagIcons()

    GwBagFrame:ClearAllPoints()
    GwBagFrame:SetPoint("TOPLEFT", GwBagMoverFrame, "TOPLEFT", 20, -40)
    GwBagFrameResize:ClearAllPoints()
    GwBagFrameResize:SetPoint("BOTTOMRIGHT", GwBagFrame, "BOTTOMRIGHT", 0, 0)

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
GW.AddForProfiling("bag", "bagOnResizeStop", bagOnResizeStop)

local function onBagDragUpdate(self)
    local point, relative, framerela, xPos, yPos = GwBagFrameResize:GetPoint()

    local w = self:GetWidth()
    local h = self:GetHeight()

    if w < 508 or h < 340 then
        GwBagFrameResize:StopMovingOrSizing()
    else
        updateBagIcons(true)
    end
end
GW.AddForProfiling("bag", "onBagDragUpdate", onBagDragUpdate)

local function onBagFrameChangeSize(self)
    local w, h = self:GetSize()

    w = math.min(1, w / 512)
    h = math.min(1, h / 512)

    self.Texture:SetTexCoord(0, w, 0, h)
end
GW.AddForProfiling("bag", "onBagFrameChangeSize", onBagFrameChangeSize)

-- (re)steals the default search boxes
local function relocateSearchBox(sb, f)
    if not sb or not f then
        return
    end

    sb:SetParent(f)
    sb:ClearAllPoints()
    sb:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -40)
    sb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -40)
    sb:SetHeight(24)
end
GW.relocateSearchBox = relocateSearchBox

-- reskins the default search boxes
local function reskinSearchBox(sb)
    if not sb then
        return
    end

    sb:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)

    sb.Left:SetTexture(nil)
    sb.Right:SetTexture(nil)
    sb.Middle:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagsearchbg")

    sb.Middle:SetPoint("RIGHT", sb, "RIGHT", 0, 0)

    sb.Middle:SetHeight(24)
    sb.Middle:SetTexCoord(0, 1, 0, 1)
end
GW.reskinSearchBox = reskinSearchBox

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

    f.headerString:SetFont(DAMAGE_TEXT_FONT, 20)
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

    -- Create bag item search box
    local BagItemSearchBox = CreateFrame("EditBox", "BagItemSearchBox", f, "BagSearchBoxTemplate")
    reskinSearchBox(BagItemSearchBox)
    hooksecurefunc(
        "ContainerFrame_Update",
        function()
            relocateSearchBox(BagItemSearchBox, f)
        end
    )
    relocateSearchBox(BagItemSearchBox, f)

    -- money tooltip
    GwMoneyFrame:SetScript("OnEnter", function (self)
        local list, total = GetRealmMoney()
        if list then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:ClearLines()

            -- list all players from the realm+faction
            local _, realm = UnitFullName("player")
            GameTooltip:AddDoubleLine(realm .. " " .. TOTAL, nil, nil, nil, 1, 1, 1)
            for name, money in pairs(list) do
                if money > 0 then
                    local color = select(4, GetClassColor(GetCharClass(name)))
                    SetTooltipMoney(GameTooltip, money, "TOOLTIP", ("|c%s%s|r:"):format(color, name))
                end
            end

            -- add total gold on realm+faction
            GameTooltip:AddLine(" ")
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
    end)

    -- clear money storage on right-click
    GwMoneyFrame:SetScript("OnClick", function (self, button)
        if button == "RightButton" then
            ClearStorage(GetRealmStorage("MONEY"))
            UpdateMoney()
            GwMoneyFrame:GetScript("OnEnter")(GwMoneyFrame)
        end
    end)

    -- update money and watch currencies when applicable
    f:SetScript(
        "OnEvent",
        function(self, event, ...)
            if not GW.inWorld then
                return
            end
            if event == "PLAYER_MONEY" then
                updateMoney(self)
            elseif event == "BAG_UPDATE_DELAYED" or event == "MERCHANT_SHOW" then
                updateBagIcons()
                SetItemButtonQuality()
            end 
        end
    )
    f:RegisterEvent("PLAYER_MONEY")
    f:RegisterEvent("MERCHANT_SHOW")

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
        if GetSetting("BAG_REVERSE_SORT") then
            dd.bagOrder:SetText(GwLocalization["BAG_ORDER_NORMAL"])
        else
            dd.bagOrder:SetText(GwLocalization["BAG_ORDER_REVERSE"])
        end
    end

    -- setup close button
    f.buttonClose:HookScript(
        "OnClick",
        function(self)
            CloseAllBags()
        end
    )

    -- setup resizer stuff
    f:HookScript("OnSizeChanged", onBagFrameChangeSize)
    GwBagFrameResize:RegisterForDrag("LeftButton")
    GwBagFrameResize:HookScript(
        "OnDragStart",
        function(self)
            self:StartMoving()
            GwBagFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
            GwBagFrame:SetScript("OnUpdate", onBagDragUpdate)
        end
    )
    GwBagFrameResize:HookScript("OnDragStop", bagOnResizeStop)

    f:SetScript("OnHide", bagFrameHide)
    f:SetScript("OnShow", bagFrameShow)
    f:Hide()

    -- hook into default bag frames to re-use default bag bars and search box
    for i = 1, #default_bag_frame_container do
        local fv = _G[default_bag_frame_container[i]]
        fv:SetFrameStrata("HIGH")
        fv:SetFrameLevel(5)

        local fc = _G["GwBagContainer" .. tostring(i - 1)]
        if fv and i < 6 then
            fv:HookScript(
                "OnShow",
                function()
                    showIcons()
                    CloseBags()
                    updateBagIcons()
                    SetItemButtonQuality()
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
end
GW.LoadBag = LoadBag