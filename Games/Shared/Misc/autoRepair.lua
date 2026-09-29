---@class GW2
local GW = select(2, ...)
local L = GW.L

local NOT_ENOUGH_MONEY = {}
for _, errorType in ipairs({LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY, LE_GAME_ERR_NOT_ENOUGH_MONEY}) do
    NOT_ENOUGH_MONEY[errorType] = true
end
local RESULT_DELAY = 0.5

local repairFailed = false
local Repair

-- the merchant answers a failed repair with an error message, a moment after the attempt
local function Report(cost, fromGuildBank)
    if repairFailed and fromGuildBank then
        Repair(false)
    elseif repairFailed then
        GW.Notice(GUILDBANK_REPAIR_INSUFFICIENT_FUNDS or L["Insufficient funds to repair all items"])
    elseif fromGuildBank then
        GW.Notice(format(L["Your items have been repaired using guild bank funds for: %s"], GW.FormatMoneyForChat(cost)))
    else
        GW.Notice(format(L["Your items have been repaired for: %s"], GW.FormatMoneyForChat(cost)))
    end
end

-- what the guild bank may pay: the withdraw limit, -1 means the guild leader without limit
local function GetGuildBankRepairFunds()
    local limit, funds = GetGuildBankWithdrawMoney(), GetGuildBankMoney()
    return limit == -1 and funds or math.min(limit, funds)
end

-- the guild bank pays when the setting wants it and it can afford it, otherwise the player does
function Repair(allowGuildBank)
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or cost == 0 then
        return
    end
    local fromGuildBank = allowGuildBank and IsInGuild() and CanGuildBankRepair() and cost <= GetGuildBankRepairFunds() or false
    repairFailed = false
    RepairAllItems(fromGuildBank)
    C_Timer.After(RESULT_DELAY, function() Report(cost, fromGuildBank) end)
end

local function OnEvent(self, event, messageType)
    if event == "MERCHANT_SHOW" then
        local setting = GW.settings.general.autoRepair
        if setting ~= "NONE" and not IsShiftKeyDown() and CanMerchantRepair() then
            self:RegisterEvent("UI_ERROR_MESSAGE")
            self:RegisterEvent("MERCHANT_CLOSED")
            Repair(setting == "GUILD")
        end
    elseif event == "MERCHANT_CLOSED" then
        self:UnregisterEvent("UI_ERROR_MESSAGE")
        self:UnregisterEvent("MERCHANT_CLOSED")
    elseif NOT_ENOUGH_MONEY[messageType] then
        repairFailed = true
    end
end

function GW.LoadAutoRepair()
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("MERCHANT_SHOW")
    watcher:SetScript("OnEvent", OnEvent)
end
