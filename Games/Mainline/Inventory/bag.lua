---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Blizzard derives how many currencies may be watched from the width of its own
-- BackpackTokenFrame. Our layout never sizes that frame, so it keeps the width of 1 from
-- its template, GetMaxTokensWatched falls back to the approximated container width and
-- the player is stuck at four no matter how wide our bag is. Size it to our own footer
-- capacity instead - the same number then caps the watch toggle in the token ui and the
-- loop below.
local function setWatchLimit(capacity)
    local tokenFrame = BackpackTokenFrame
    if not tokenFrame then
        return
    end
    if not tokenFrame.tokenWidth then
        tokenFrame:GetMaxTokensWatched() -- fills in the cached token width
    end
    local width = capacity * (tokenFrame.tokenWidth or 50)
    if math.floor(tokenFrame:GetWidth() or 0) ~= math.floor(width) then
        if not tokenFrame.gwUnanchored then
            -- it is anchored inside blizzards parked container frame, so a width of
            -- our own would not survive its next layout pass
            tokenFrame.gwUnanchored = true
            tokenFrame:ClearAllPoints()
        end
        tokenFrame:SetWidth(width)
    end
end

local function enumerateWatchedCurrencies()
    local watched = {}
    if not BackpackTokenFrame then
        return watched
    end
    for i = 1, BackpackTokenFrame:GetMaxTokensWatched() do
        local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
        if info and info.quantity then
            watched[#watched + 1] = {
                quantity = info.quantity,
                icon = info.iconFileID,
                tokenIndex = i,
                currencyID = info.currencyTypesID,
            }
        end
    end
    return watched
end

local function currency_OnEnter(self)
    if not self.gwCurrency then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetBackpackToken(self.gwCurrency.tokenIndex)
    GameTooltip_AddBlankLineToTooltip(GameTooltip)
    GameTooltip_AddInstructionLine(GameTooltip, TOKEN_REMOVE_FROM_BACKPACK_INSTRUCTION)
    GameTooltip:Show()
end

local function currency_OnClick(self)
    if not self.gwCurrency then
        return
    end

    if IsModifiedClick("CHATLINK") then
        local linkedToChat = HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyLink(self.gwCurrency.currencyID))
        if linkedToChat then
            return
        end
    end

    if IsModifiedClick("TOKENWATCHTOGGLE") then
        C_CurrencyInfo.SetCurrencyBackpackByID(self.gwCurrency.currencyID, false)
    elseif not InCombatLockdown() then
        ToggleCharacter("TokenFrame")
    end
end


-- blizzards combined bag view fights with our own bag frame; the frame itself is
-- already made inert by the shared code, here we just keep the cvar off
local function disableCombinedBags(f)
    SetCVar("combinedBags", 0)

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("CVAR_UPDATE")
    watcher:SetScript("OnEvent", function(_, _, cvarName, cvarValue)
        if cvarName == "combinedBags" and cvarValue == "1" then
            SetCVar("combinedBags", "0")
        end
    end)

    -- the help box for the extra bag slots anchors to the blizzard frames, move it to ours
    hooksecurefunc("ContainerFrame_GenerateFrame", function(frame)
        if frame.ExtraBagSlotsHelpBox then
            local h = frame.ExtraBagSlotsHelpBox
            h:ClearAllPoints()
            h:SetPoint("RIGHT", f, "TOPLEFT", -60, -90)
        end
    end)
end


GW.RegisterBagModule({
    onLoadBag = function(f)
        if BagBarExpandToggle then
            BagBarExpandToggle:SetParent(GW.HiddenFrame)
            SetCVar("expandBagBar", "1")
        end

        disableCombinedBags(f)
        GW.SetupBagCurrencyDisplay(f, {
            enumerate = enumerateWatchedCurrencies,
            onEnter = currency_OnEnter,
            onClick = currency_OnClick,
            setWatchLimit = setWatchLimit,
            onRefresh = function(refresh)
                hooksecurefunc(C_CurrencyInfo, "SetCurrencyBackpack", refresh)
                hooksecurefunc(C_CurrencyInfo, "SetCurrencyBackpackByID", refresh)
            end,
        })
    end,
    onMenu = function(f, rootDescription, addCheck)
        addCheck(L["Show Scrap Icon"], function() return GW.settings.BAG_ITEM_SCRAP_ICON_SHOW end,
                 function() GW.settings.BAG_ITEM_SCRAP_ICON_SHOW = not GW.settings.BAG_ITEM_SCRAP_ICON_SHOW; GW.UpdateAllOwnBagItemButtons() end)
    end,
})
