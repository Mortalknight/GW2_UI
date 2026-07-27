---@class GW2
local GW = select(2, ...)

--[[
    Shared building blocks for bag and bank addins.

    Some extras only exist on a subset of the flavors, so they live in a flavor module
    registered with GW.RegisterBagModule. Where the mechanics of such an extra are the
    same everywhere and only the game api underneath differs, the mechanics belong here
    and the module passes in the flavor specific parts.
]]

local CURRENCY_DISPLAY_STRIDE = 60 -- one display plus the gap to the next one
local CURRENCY_FOOTER_RESERVED = 273 -- the money display on the right and the currency button on the left

-- how many watched currency displays fit into our bag footer; how many currencies the
-- game lets the player watch at all is a separate, smaller limit that the flavor applies
local function maxCurrencySlots(f)
    return math.max(1, math.floor((f:GetWidth() - CURRENCY_FOOTER_RESERVED) / CURRENCY_DISPLAY_STRIDE) + 1)
end

local function getCurrencyFrame(f, index, opts)
    local currencyFrame = f.gwCurrencyFrames[index]
    if currencyFrame then
        return currencyFrame
    end

    currencyFrame = CreateFrame("Button", nil, f, "GwBagWatchedCurrencyTemplate")
    currencyFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -183 - ((index - 1) * CURRENCY_DISPLAY_STRIDE), -40)
    currencyFrame.value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    currencyFrame.value:SetTextColor(1, 1, 1)
    -- the handlers read the entry the flavor produced from currencyFrame.gwCurrency
    currencyFrame:SetScript("OnEnter", opts.onEnter)
    if opts.onClick then
        currencyFrame:SetScript("OnClick", opts.onClick)
    end

    f.gwCurrencyFrames[index] = currencyFrame
    return currencyFrame
end

--[[
    Creates the currency button in the bag footer plus the watched currency displays next
    to it, and keeps them filled. opts carries the flavor specific parts:

        enumerate = function() end,  -- the watched currencies as an ordered list of
                                     -- {quantity = , icon = , ...}, in display order;
                                     -- the whole entry lands on the display as
                                     -- .gwCurrency, so it can carry whatever the
                                     -- handlers below need to identify the currency
        onEnter   = function(self) end,          -- tooltip for one display
        onClick   = function(self) end,          -- optional click behavior
        onRefresh = function(refresh) end,       -- optional, register additional hooks
                                                 -- that have to refresh the displays
]]
local function SetupBagCurrencyDisplay(f, opts)
    f.gwCurrencyFrames = {}

    local function refresh()
        local entries = opts.enumerate() or {}
        local shown = math.min(#entries, maxCurrencySlots(f))

        for i = 1, shown do
            local entry = entries[i]
            local currencyFrame = getCurrencyFrame(f, i, opts)
            currencyFrame.gwCurrency = entry
            currencyFrame.value:SetText(GW.GetLocalizedNumber(entry.quantity))
            currencyFrame.icon:SetTexture(entry.icon)
            currencyFrame:Show()
        end

        for i = shown + 1, #f.gwCurrencyFrames do
            local currencyFrame = f.gwCurrencyFrames[i]
            currencyFrame.gwCurrency = nil
            currencyFrame.value:SetText("")
            currencyFrame.icon:SetTexture(nil)
            currencyFrame:Hide()
        end
    end

    f.currency = CreateFrame("Button", nil, f)
    f.currency:SetSize(32, 32)
    f.currency:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 2, -2)
    f.currency:SetFrameLevel(50)
    f.currency:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/currency-icon.png")
    f.currency:SetScript("OnClick", function()
        -- TODO: cannot do this properly until we make the whole bag frame secure
        if not InCombatLockdown() then
            ToggleCharacter("TokenFrame")
        end
    end)
    f.currency:SetScript("OnEvent", function()
        if GW.inWorld then
            refresh()
        end
    end)
    f.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    f:HookScript("OnSizeChanged", refresh)
    if opts.onRefresh then
        opts.onRefresh(refresh)
    end

    refresh()
end
GW.SetupBagCurrencyDisplay = SetupBagCurrencyDisplay
