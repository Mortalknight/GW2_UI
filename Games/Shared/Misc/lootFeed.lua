---@class GW2
local GW = select(2, ...)

local MAX_ROWS = 6
local ROW_HEIGHT = 30
local ROW_GAP = 3
local ICON_SIZE = 26
local HOLD_TIME = 5
local FADE_TIME = 0.5
local SETTLE_TIME = 0.3
local LEAVE_HOLD_TIME = 1
local SLIDE_DISTANCE = 40
local SLIDE_SPEED = 12
local PULSE_DECAY = 4
local MONEY_ICON = "Interface/Icons/INV_Misc_Coin_01"

local feed
local entries = {}
local rowPool = {}
local lastMoney
local nextFadeAt = 0

-- "%s" and "%1$s" become captures, the rest of the loot text must match literally
local function FormatToPattern(fmt)
    fmt = fmt:gsub("([%(%)%.%-%+%[%]%?%*%^])", "%%%1")
    fmt = fmt:gsub("%%%d*%$?s", "(.+)")
    fmt = fmt:gsub("%%%d*%$?d", "(%%d+)")
    return "^" .. fmt .. "$"
end

-- the multiple variants first, the single ones would match them too; by name, a text missing
-- on a client must not end the list
local LOOT_PATTERNS = {}
for _, key in ipairs({"LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_SELF", "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_CREATED_SELF"}) do
    if _G[key] then
        tinsert(LOOT_PATTERNS, FormatToPattern(_G[key]))
    end
end

local function ParseOwnLoot(text)
    for _, pattern in ipairs(LOOT_PATTERNS) do
        local link, count = text:match(pattern)
        if link then
            return link, tonumber(count) or 1
        end
    end
end

-- the tooltip of a row; while the mouse is on the icon the row holds, when it leaves it fades soon
local function IconOnEnter(self)
    local entry = self:GetParent().entry
    entry.hovered = true
    entry.fadeStart = nil
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    if entry.isMoney then
        GameTooltip:SetText(MONEY, GW.Colors.SkinColors.QuestGold:GetRGB())
        GameTooltip:AddLine(GW.FormatMoneyForChat(entry.amount, true))
    else
        GameTooltip:SetHyperlink(entry.key)
    end
    GameTooltip:Show()
end

local function IconOnLeave(self)
    local entry = self:GetParent().entry
    entry.hovered = nil
    entry.time = GetTime() - HOLD_TIME + LEAVE_HOLD_TIME
    GameTooltip:Hide()
end

local function CreateRow()
    local row = CreateFrame("Frame", nil, feed)
    row:SetSize(feed:GetWidth(), ROW_HEIGHT)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetColorTexture(1, 1, 1, 1)
    row.bg:SetGradient("HORIZONTAL", GW.Colors.SkinColors.RowShade, GW.Colors.Transparent)
    row.bg:SetAllPoints()

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(ICON_SIZE, ICON_SIZE)
    row.icon:SetPoint("CENTER", row, "LEFT", 2 + ICON_SIZE / 2, 0)
    GW.HandleIcon(row.icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)

    -- only the icon reacts to the mouse and only to hovering, clicks still go through to the world
    row.iconHit = CreateFrame("Frame", nil, row)
    row.iconHit:SetAllPoints(row.icon)
    row.iconHit:SetMouseMotionEnabled(true)
    row.iconHit:SetScript("OnEnter", IconOnEnter)
    row.iconHit:SetScript("OnLeave", IconOnLeave)

    row.count = row:CreateFontString(nil, "OVERLAY")
    row.count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    row.count:SetPoint("RIGHT", -8, 0)

    row.name = row:CreateFontString(nil, "OVERLAY")
    row.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    row.name:SetPoint("LEFT", row, "LEFT", ICON_SIZE + 10, 0)
    row.name:SetPoint("RIGHT", row.count, "LEFT", -6, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    return row
end

-- the oldest row at the bottom; only the targets, OnUpdate moves the rows there
local function Layout()
    for i, entry in ipairs(entries) do
        entry.targetY = (i - 1) * (ROW_HEIGHT + ROW_GAP)
    end
end

local function SetCount(entry)
    entry.row.count:SetText("+" .. (entry.isMoney and GW.FormatMoneyForChat(entry.amount, true) or entry.amount))
end

local function RemoveEntry(index)
    local entry = tremove(entries, index)
    if GameTooltip:IsOwned(entry.row.iconHit) then
        GameTooltip:Hide()
    end
    entry.row:Hide()
    tinsert(rowPool, entry.row)
end

-- new rows slide in from the right on top, a counted up row pulses its icon and count;
-- the rows leave one by one from the bottom, the others glide down before the next one fades
local function OnUpdate(_, elapsed)
    local now = GetTime()
    local step = math.min(elapsed * SLIDE_SPEED, 1)
    local white, gold = GW.Colors.FallbackWhite, GW.Colors.SkinColors.QuestGold
    local removed = false

    -- a held row is skipped, the next older one leaves instead
    local oldest
    for _, entry in ipairs(entries) do
        if not entry.hovered then
            oldest = entry
            break
        end
    end
    if oldest and not oldest.fadeStart and now >= oldest.time + HOLD_TIME and now >= nextFadeAt then
        oldest.fadeStart = now
    end

    for i = #entries, 1, -1 do
        local entry = entries[i]
        local fadeOut = entry.fadeStart and (now - entry.fadeStart) / FADE_TIME or 0
        if fadeOut >= 1 then
            RemoveEntry(i)
            removed = true
            nextFadeAt = now + SETTLE_TIME
        else
            local row = entry.row
            entry.x = entry.x - entry.x * step
            entry.y = entry.y + (entry.targetY - entry.y) * step
            entry.pulse = math.max(entry.pulse - elapsed * PULSE_DECAY, 0)

            row:SetPoint("BOTTOMRIGHT", feed, "BOTTOMRIGHT", entry.x, entry.y)
            row:SetAlpha(math.min(1 - fadeOut, 1 - entry.x / SLIDE_DISTANCE))
            row.icon:SetSize(ICON_SIZE * (1 + 0.25 * entry.pulse), ICON_SIZE * (1 + 0.25 * entry.pulse))
            if not entry.isMoney then
                row.count:SetTextColor(white.r + (gold.r - white.r) * entry.pulse, white.g + (gold.g - white.g) * entry.pulse, white.b + (gold.b - white.b) * entry.pulse)
            end
        end
    end

    if removed then
        Layout()
    end
    if #entries == 0 then
        feed:SetScript("OnUpdate", nil)
    end
end

-- the same item or money again counts up the row it already has and moves it back on top
local function AddEntry(key, icon, name, color, amount, isMoney)
    for i, entry in ipairs(entries) do
        if entry.key == key then
            entry.amount = entry.amount + amount
            entry.time = GetTime()
            entry.fadeStart = nil
            entry.pulse = 1
            SetCount(entry)
            tinsert(entries, tremove(entries, i))
            Layout()
            return
        end
    end

    if #entries == MAX_ROWS then
        RemoveEntry(1)
    end

    local row = tremove(rowPool) or CreateRow()
    row.icon:SetTexture(icon)
    row.icon:SetSize(ICON_SIZE, ICON_SIZE)
    row.icon.backdrop:SetBackdropBorderColor(color:GetRGB())
    row.name:SetText(name)
    row.name:SetTextColor(color:GetRGB())
    row.count:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    row:ClearAllPoints()
    row:SetAlpha(0)
    row:Show()

    local entry = {key = key, amount = amount, isMoney = isMoney, time = GetTime(), row = row, x = SLIDE_DISTANCE, pulse = 0}
    row.entry = entry
    tinsert(entries, entry)
    SetCount(entry)
    Layout()
    entry.y = entry.targetY
    row:SetPoint("BOTTOMRIGHT", feed, "BOTTOMRIGHT", entry.x, entry.y)
    feed:SetScript("OnUpdate", OnUpdate)
end

local function OnEvent(_, event, text)
    if event == "CHAT_MSG_LOOT" then
        if issecretvalue and issecretvalue(text) then return end
        local link, count = ParseOwnLoot(text)
        if not link then return end

        local name, _, quality, _, _, _, _, _, _, icon = C_Item.GetItemInfo(link)
        local color = ITEM_QUALITY_COLORS[quality or Enum.ItemQuality.Common] or ITEM_QUALITY_COLORS[Enum.ItemQuality.Common]
        AddEntry(link, icon or select(5, C_Item.GetItemInfoInstant(link)), name or link:match("%[(.-)%]") or link, color.color, count)
    elseif event == "PLAYER_MONEY" then
        local money = GetMoney()
        local gained = money - lastMoney
        lastMoney = money
        if gained > 0 then
            AddEntry("money", MONEY_ICON, MONEY, GW.Colors.SkinColors.QuestGold, gained, true)
        end
    end
end

local function CreateFeed()
    feed = CreateFrame("Frame", "GwLootFeed", UIParent)
    feed:SetSize(240, MAX_ROWS * (ROW_HEIGHT + ROW_GAP) - ROW_GAP)
    feed:SetScript("OnEvent", OnEvent)

    GW.RegisterMovableFrame(feed, GW.L["Loot Feed"], "lootFeed", nil, nil, {GW.MoverOption.Scale})
    feed:ClearAllPoints()
    feed:SetPoint("BOTTOMRIGHT", feed.gwMover)
end

function GW.UpdateLootFeed()
    local enabled = GW.settings.lootFeed.enabled
    if not feed then
        if not enabled then return end
        CreateFeed()
    end

    feed:SetShown(enabled)
    GW.ToggleMover(feed.gwMover, enabled)
    if enabled then
        lastMoney = GetMoney()
        feed:RegisterEvent("CHAT_MSG_LOOT")
        feed:RegisterEvent("PLAYER_MONEY")
    else
        feed:UnregisterAllEvents()
        for i = #entries, 1, -1 do
            RemoveEntry(i)
        end
    end
end
