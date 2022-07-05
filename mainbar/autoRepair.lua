local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local FormatMoneyForChat = GW.FormatMoneyForChat

local STATUS, TYPE, COST, canRepair

local function autoRepair(overrideSettings)
    STATUS, TYPE, COST, canRepair = "", GetSetting("AUTO_REPAIR"), GetRepairAllCost()

    if canRepair and COST > 0 then
        local tryGuild = not overrideSettings and TYPE == "GUILD" and IsInGuild()
        local useGuild = tryGuild and CanGuildBankRepair() and COST <= GetGuildBankWithdrawMoney()
        if not useGuild then TYPE = "PLAYER" end

        RepairAllItems(useGuild)

        --Delay this a bit so we have time to catch the outcome of first repair attempt
        C_Timer.After(0.5, function() GW.autoRepairOutput() end)
    end
end

local function autoRepairOutput()
    if TYPE == "GUILD" then
        if STATUS == "GUILD_REPAIR_FAILED" then
            autoRepair(true) --Try using player money instead
        else
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Your items have been repaired using guild bank funds for: %s"]:format(FormatMoneyForChat(COST))):gsub("*", GW.Gw2Color))
        end
    elseif TYPE == "PLAYER" then
        if STATUS == "PLAYER_REPAIR_FAILED" then
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You don't have enough money to repair."]):gsub("*", GW.Gw2Color))
        else
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Your items have been repaired for: %s"]:format(FormatMoneyForChat(COST))):gsub("*", GW.Gw2Color))
        end
    end
end
GW.autoRepairOutput = autoRepairOutput

local function ar_frame_OnEvent(self, event, ...)
    if event == "MERCHANT_SHOW" then
        if GetSetting("AUTO_REPAIR") == "NONE" or IsShiftKeyDown() or not CanMerchantRepair() then
            return
        end

        --Prepare to catch "not enough money" messages
        self:RegisterEvent("UI_ERROR_MESSAGE")

        --Use this to unregister events afterwards
        self:RegisterEvent("MERCHANT_CLOSED")

        autoRepair()
    elseif event == "MERCHANT_CLOSED" then
        self:UnregisterEvent("UI_ERROR_MESSAGE")
        self:UnregisterEvent("MERCHANT_CLOSED")
    elseif event == "UI_ERROR_MESSAGE" then
        local messageType = ...
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