local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local FormatMoneyForChat = GW.FormatMoneyForChat

local STATUS, TYPE, COST, POSS

local function autoRepairOutput()
    if TYPE == "GUILD" then
        if STATUS == "GUILD_REPAIR_FAILED" then
            autoRepair(true) --Try using player money instead
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. L["REPAIRD_FOR_GUILD"]:format(FormatMoneyForChat(COST)))
        end
    elseif TYPE == "PLAYER" then
        if STATUS == "PLAYER_REPAIR_FAILED" then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. GUILDBANK_REPAIR_INSUFFICIENT_FUNDS)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. L["REPAIRD_FOR"]:format(FormatMoneyForChat(COST)))
        end
    end
end

local function autoRepair(overrideSettings)
    STATUS, TYPE, COST, POSS = "", GetSetting("AUTO_REPAIR"), GetRepairAllCost()

    if POSS and COST > 0 then
        --This check evaluates to true even if the guild bank has 0 gold, so we add an override
        if (IsInGuild() and TYPE == "GUILD" and (overrideSettings or (not CanGuildBankRepair() or COST > GetGuildBankWithdrawMoney()))) or (not IsInGuild() and TYPE == "GUILD") then
            TYPE = "PLAYER"
        end
        RepairAllItems(TYPE == "GUILD")

        --Delay this a bit so we have time to catch the outcome of first repair attempt
        C_Timer.After(0.5, function() autoRepairOutput() end)
    end
end

local function ar_frame_OnEvent(self, event, ...)
    if event == "MERCHANT_SHOW" then
        if GetSetting("AUTO_REPAIR") == "NONE" or IsShiftKeyDown() or not CanMerchantRepair() then
            return
        end

        --Prepare to catch "not enough money" messages
        self:RegisterEvent("UI_ERROR_MESSAGE")

        --Use this to unregister events afterwards
        self:RegisterEvent("MERCHANT_CLOSED")

        autoRepair(false)
    elseif event == "MERCHANT_CLOSED" then
        self:UnregisterEvent("UI_ERROR_MESSAGE")
        self:UnregisterEvent("MERCHANT_CLOSED")
    elseif event == "UI_ERROR_MESSAGE" then
        local messageType = select(2, ...)
        if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
            STATUS = "GUILD_REPAIR_FAILED"
        elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
            STATUS = "PLAYER_REPAIR_FAILED"
        end
    end
end

local function LoadAutoRepair()
    local ar_frame = CreateFrame("Frame")

    ar_frame:RegisterEvent("MERCHANT_SHOW")
    ar_frame:SetScript("OnEvent", ar_frame_OnEvent)
end
GW.LoadAutoRepair = LoadAutoRepair