local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local FormatMoneyForChat = GW.FormatMoneyForChat

local STATUS, COST, canRepair

local function autoRepairOutput()
    if STATUS == "PLAYER_REPAIR_FAILED" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. ERR_NOT_ENOUGH_MONEY)
    else
        DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Your items have been repaired for: %s"]:format(FormatMoneyForChat(COST))):gsub("*", GW.Gw2Color))
    end
end

local function autoRepair()
    STATUS, COST, canRepair = "", GetRepairAllCost()

    if canRepair and COST > 0 then
        RepairAllItems(false)

        --Delay this a bit so we have time to catch the outcome of first repair attempt
        C_Timer.After(0.5, function() autoRepairOutput() end)
    end
end

local function ar_frame_OnEvent(self, event, ...)
    if event == "MERCHANT_SHOW" then
        if not GetSetting("AUTO_REPAIR") or IsShiftKeyDown() or not CanMerchantRepair() then
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
        if ... == LE_GAME_ERR_NOT_ENOUGH_MONEY then
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