---@class GW2
local GW = select(2, ...)

-- own group loot roll bars instead of blizzards roll frames
local BAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local BAR_WIDTH, BAR_HEIGHT, BUTTON_SIZE = 300, 28, 22
local ROLLS = {
    {key = "need", type = 1, texture = "Interface/Buttons/UI-GroupLoot-Dice-Up", text = NEED},
    {key = "transmog", type = 4, texture = "Interface/Minimap/Tracking/Transmogrifier", text = TRANSMOGRIFY},
    {key = "greed", type = 2, texture = "Interface/Buttons/UI-GroupLoot-Coin-Up", text = GREED},
    {key = "disenchant", type = 3, texture = "Interface/Buttons/UI-GroupLoot-DE-Up", text = ROLL_DISENCHANT},
    {key = "pass", type = 0, texture = "Interface/Buttons/UI-GroupLoot-Pass-Up", text = PASS},
}
local bars = {}
local testRolls = {}

local function GetRollItemInfo(rollID)
    local test = testRolls[rollID]
    if test then
        return test.texture, test.name, 1, test.quality, false, true, true, test.canDisenchant, nil, nil, nil, nil, test.canTransmog
    end
    return GetLootRollItemInfo(rollID)
end

local function GetRollTimeLeft(rollID)
    local test = testRolls[rollID]
    if test then
        return (test.expires - GetTime()) * 1000
    end
    return GetLootRollTimeLeft(rollID)
end

local function LayoutBars()
    local previous
    for _, bar in ipairs(bars) do
        if bar.rollID then
            bar:ClearAllPoints()
            if previous then
                bar:SetPoint("TOP", previous, "BOTTOM", 0, -5)
            else
                bar:SetPoint("TOP", GwAlertFrameOffsetter, "TOP", BAR_HEIGHT / 2, -5)
            end
            previous = bar
        end
    end
end

local function CancelRoll(rollID)
    for _, bar in ipairs(bars) do
        if bar.rollID and (not rollID or bar.rollID == rollID) then
            testRolls[bar.rollID] = nil
            bar.rollID = nil
            bar:Hide()
        end
    end
    LayoutBars()
end

local function Status_OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) - elapsed
    if self.elapsed > 0 then return end
    self.elapsed = 0.1

    local rollID = self:GetParent().rollID
    if not rollID then return end
    local timeLeft = GetRollTimeLeft(rollID)
    if timeLeft <= 0 then
        CancelRoll(rollID)
    else
        self:SetValue(timeLeft)
    end
end

local function RollButton_OnClick(self)
    local rollID = self:GetParent().rollID
    if testRolls[rollID] then
        CancelRoll(rollID)
    else
        RollOnLoot(rollID, self.rollType)
    end
end

local function RollButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltipText, 1, 1, 1)
    GameTooltip:Show()
end

local function Icon_OnEnter(self)
    local rollID = self:GetParent().rollID
    if not rollID then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    if testRolls[rollID] then
        GameTooltip:SetHyperlink(testRolls[rollID].link)
    else
        GameTooltip:SetLootRollItem(rollID)
    end
    if IsShiftKeyDown() then
        GameTooltip_ShowCompareItem()
    end
end

local function Icon_OnClick(self)
    if IsModifiedClick() then
        HandleModifiedItemClick(self:GetParent().link)
    end
end

local function CreateRollButton(bar, roll)
    local button = CreateFrame("Button", nil, bar)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameLevel(bar.status:GetFrameLevel() + 2)
    button:SetNormalTexture(roll.texture)
    button:SetHighlightTexture(roll.texture, "ADD")
    button:SetDisabledTexture(roll.texture)
    button:GetDisabledTexture():SetDesaturated(true)
    button:GetDisabledTexture():SetAlpha(0.3)
    button:SetMotionScriptsWhileDisabled(true)
    button:SetScript("OnClick", RollButton_OnClick)
    button:SetScript("OnEnter", RollButton_OnEnter)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button.rollType = roll.type
    button.tooltipText = roll.text
    return button
end

local function CreateBar()
    local bar = CreateFrame("Frame", nil, UIParent)
    bar:SetSize(BAR_WIDTH, BAR_HEIGHT)
    bar:SetFrameStrata("DIALOG")
    bar:Hide()

    bar.status = CreateFrame("StatusBar", nil, bar)
    bar.status:SetAllPoints()
    bar.status:SetStatusBarTexture(BAR_TEXTURE)
    bar.status:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    bar.status:SetScript("OnUpdate", Status_OnUpdate)

    bar.icon = CreateFrame("Button", nil, bar)
    bar.icon:SetSize(BAR_HEIGHT, BAR_HEIGHT)
    bar.icon:SetPoint("RIGHT", bar, "LEFT", -4, 0)
    bar.icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    bar.icon.texture = bar.icon:CreateTexture(nil, "ARTWORK")
    bar.icon.texture:SetAllPoints()
    bar.icon.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    bar.icon.itemLevel = bar.icon:CreateFontString(nil, "OVERLAY")
    bar.icon.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    bar.icon.itemLevel:SetPoint("BOTTOMRIGHT", 0, 1)
    bar.icon.count = bar.icon:CreateFontString(nil, "OVERLAY")
    bar.icon.count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    bar.icon.count:SetPoint("TOPRIGHT", 0, -1)
    bar.icon:SetScript("OnEnter", Icon_OnEnter)
    bar.icon:SetScript("OnLeave", GameTooltip_Hide)
    bar.icon:SetScript("OnClick", Icon_OnClick)

    for _, roll in ipairs(ROLLS) do
        bar[roll.key] = CreateRollButton(bar, roll)
    end

    bar.name = bar.status:CreateFontString(nil, "OVERLAY")
    bar.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    bar.name:SetJustifyH("LEFT")
    bar.name:SetWordWrap(false)
    bar.name:SetPoint("LEFT", 6, 0)

    tinsert(bars, bar)
    return bar
end

-- the roll buttons sit right to left, the hidden ones leave no gap
local function LayoutButtons(bar)
    local previous
    for i = #ROLLS, 1, -1 do
        local button = bar[ROLLS[i].key]
        if button:IsShown() then
            button:ClearAllPoints()
            button:SetPoint("RIGHT", previous or bar, previous and "LEFT" or "RIGHT", -4, 0)
            previous = button
        end
    end
    bar.name:SetPoint("RIGHT", previous, "LEFT", -4, 0)
end

local function StartRoll(rollID, rollTime)
    local texture, name, count, quality, _, canNeed, canGreed, canDisenchant, _, _, _, _, canTransmog = GetRollItemInfo(rollID)
    if not name then
        CancelRoll(rollID)
        return
    end

    local bar
    for _, candidate in ipairs(bars) do
        if not candidate.rollID then
            bar = candidate
            break
        end
    end
    bar = bar or CreateBar()

    local link = testRolls[rollID] and testRolls[rollID].link or GetLootRollItemLink(rollID)
    local color = GW.GetQualityColor(quality)
    bar.rollID, bar.link = rollID, link

    bar.icon.texture:SetTexture(texture)
    bar.icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    bar.icon.count:SetText(count > 1 and count or "")
    bar.icon.itemLevel:SetText(link and GW.IsItemEligibleForItemLevelDisplay(link) and C_Item.GetDetailedItemLevelInfo(link) or "")

    bar.name:SetText(name)
    bar.name:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    bar.status:SetStatusBarColor(color.r, color.g, color.b, 0.5)
    bar.status.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    bar.status:SetMinMaxValues(0, rollTime)
    bar.status:SetValue(rollTime)
    bar.status.elapsed = 0

    bar.need:SetEnabled(canNeed)
    bar.greed:SetEnabled(canGreed and not canTransmog)
    bar.disenchant:SetShown(canDisenchant)
    bar.transmog:SetShown(canTransmog == true)
    LayoutButtons(bar)

    bar:Show()
    LayoutBars()
end

function GW.LoadLootRollBars()
    if not GW.settings.skins.lootRoll.enabled then return end

    if GameEvent and GameEvent.UnregisterInternalEvent then
        GameEvent.UnregisterInternalEvent("START_LOOT_ROLL")
    else
        UIParent:UnregisterEvent("START_LOOT_ROLL")
    end

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, event, rollID, rollTime)
        if event == "START_LOOT_ROLL" then
            StartRoll(rollID, rollTime)
        elseif event == "CANCEL_LOOT_ROLL" then
            CancelRoll(rollID)
        else
            CancelRoll()
        end
    end)
    frame:RegisterEvent("START_LOOT_ROLL")
    frame:RegisterEvent("CANCEL_LOOT_ROLL")
    if C_EventUtils.IsEventValid("CANCEL_ALL_LOOT_ROLLS") then
        frame:RegisterEvent("CANCEL_ALL_LOOT_ROLLS")
    end
end

-- /gw2 test lootroll
-- one bar per quality from poor to legendary; the quality is set here, items that exist on every client
local TEST_ITEMS = {
    {itemID = 7073, quality = 0},
    {itemID = 2589, quality = 1},
    {itemID = 4500, quality = 2},
    {itemID = 2164, quality = 3},
    {itemID = 18832, quality = 4},
    {itemID = 19019, quality = 5},
}
function GW.TestLootRolls()
    if not GW.settings.skins.lootRoll.enabled then
        GW.Notice(GW.L["Loot roll bars"] .. ": " .. ADDON_DISABLED)
        return
    end
    for index, test in ipairs(TEST_ITEMS) do
        CancelRoll(-index)
        local item = Item:CreateFromItemID(test.itemID)
        item:ContinueOnItemLoad(function()
            local rollID = -index
            testRolls[rollID] = {
                texture = item:GetItemIcon(),
                name = item:GetItemName(),
                quality = test.quality,
                link = item:GetItemLink(),
                expires = GetTime() + 60,
                canDisenchant = test.quality >= 2,
                canTransmog = test.quality == 4,
            }
            StartRoll(rollID, 60000)
        end)
    end
end
