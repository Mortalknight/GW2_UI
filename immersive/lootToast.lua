local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

local constBackdropAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/hud/toast-bg",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local trackedItemIDs = {
    124113, --stonehide
    124115, --stormscale
    110609, -- raw beast hide
}
local trackedItemIDLooted = {}
local lootRequiresUpdate = false

local timeSessionStart = GetTime()
local lastExp = UnitXP("player")
local totalExpAquired = 0
local timeToLevel = 0

local function FormatMoney(copper)
    if not copper then return "" end

    local gold   = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local c      = copper % 100

    if gold >= 1 then
        -- Only show gold
        return string.format("%d|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", gold)
    else
        -- Show silver and copper
        return string.format(
        "%d|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t %d|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t", silver,
            c)
    end
end
local function formatTime(seconds)
    if seconds < 60 then
        return string.format("%d sec", seconds)
    elseif seconds < 3600 then
        return string.format("%.1f min", seconds / 60)
    else
        return string.format("%.2f hr", seconds / 3600)
    end
end
local function getSessionDuration()
    return GetTime() - timeSessionStart;
end
local function getPerHour(t)
    if not t or t <= 0 then
        return 0
    end
    return (t / getSessionDuration()) * 3600
end


local function resetButtonOnClick()
    trackedItemIDLooted = {}
    lootRequiresUpdate = true

    timeSessionStart = GetTime()
    lastExp = UnitXP("player")
    totalExpAquired = 0
    timeToLevel = 0

end

local fnGMGB_OnEnter = function(self)
    self.arrow:SetSize(21, 42)
end
local fnGMGB_OnLeave = function(self)
    self.arrow:SetSize(16, 32)
end

local function toolkitOnEvent(self, event, msg)
    if event == "PLAYER_XP_UPDATE" then
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local gain = currentXP - lastExp

        if gain < 0 then
            local prevMaxXP = UnitXPMax("player") -- XP needed for last level
            gain = (prevMaxXP - lastXP) + currentXP
        end
        totalExpAquired = totalExpAquired + gain

        local remainingXP = maxXP - currentXP
        local xpPerSecond = totalExpAquired / getSessionDuration()
        if xpPerSecond > 0 then
            timeToLevel = remainingXP / xpPerSecond
        end
        lastExp = UnitXP("player")
    elseif event == "CHAT_MSG_LOOT" then
        local itemLink = msg:match("|Hitem:[-%d:]+|h%[[^]]+%]|h")
        if itemLink then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if tContains(trackedItemIDs, itemID) then
                if trackedItemIDLooted[itemID] == nil then
                    trackedItemIDLooted[itemID] = 0;
                end
                trackedItemIDLooted[itemID] = trackedItemIDLooted[itemID] + 1
                lootRequiresUpdate = true
            end
        end
    end
end

local function renderData(self)
    if self.throtle > GetTime() then
        return
    end

    self.exp:SetFormattedText("Exp/hr: %s  Duration: %s,  Next Ding: %s",
        math.floor(getPerHour(t)),
        formatTime(getSessionDuration()),
        formatTime(timeToLevel)
    )

    self.throtle = GetTime() + 1
    if not lootRequiresUpdate then
        return
    end
    local totalItemValue = 0
    for k, v in pairs(trackedItemIDLooted) do
        local price = Atr_GetAuctionBuyout(k)
        if price and price > 0 then
            totalItemValue = price * v
        end
    end
    self.gold:SetFormattedText("Gold/hr: %s  Total: %s",
        FormatMoney(getPerHour(totalItemValue)),
        FormatMoney(totalItemValue)
    )
end

function createToolkitWindow()
    local fmGMGB = CreateFrame("Button", "GwToolkitWindow", UIParent, "GwManageGroupButtonTmpl")

    local f = CreateFrame("Frame", "GwLootToolkit", UIParent, nil)
    f:SetSize(500, 300)
    f:SetPoint("TOPLEFT", fmGMGB, "TOPRIGHT", 30, 0)
    GW.CreateFrameHeaderWithBody(f, nil, "Interface/AddOns/GW2_UI/textures/character/loot-window-icon", {})
    f.tex:SetTexture("Interface/AddOns/GW2_UI/textures/bag/lootframebg")

    fmGMGB:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 1, -120)
    fmGMGB:SetScript("OnEnter", fnGMGB_OnEnter)
    fmGMGB:SetScript("OnLeave", fnGMGB_OnLeave)
    fmGMGB:SetScript("OnClick", function()
        if f:IsShown() then
            f:Hide()
            return
        end
        f:Show()
    end)

    f.exp = f:CreateFontString(nil, "OVERLAY")
    f.exp:SetFont(UNIT_NAME_FONT, 16, "")
    --f.exp:SetFormattedText("%s-%s", playerName, GW.myrealm)
    f.exp:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -50)
    f.exp:SetShadowColor(0, 0, 0, 1)
    f.exp:SetShadowOffset(1, -1)
    f.exp:SetTextColor(1, 1, 1)
    f.exp:SetText("")

    f.gold = f:CreateFontString(nil, "OVERLAY")
    f.gold:SetFont(UNIT_NAME_FONT, 16, "")
    f.gold:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -100)
    f.gold:SetShadowColor(0, 0, 0, 1)
    f.gold:SetShadowOffset(1, -1)
    f.gold:SetTextColor(1, 1, 1)
    f.gold:SetText("")

    f.resetButton = CreateFrame("Button", nil, f, "GwStandardButton")
    f.resetButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 20)
    f.resetButton:SetSize(100, 26)

    f.resetButton:SetText("Reset")
    f.resetButton:SetScript("OnClick", resetButtonOnClick)


    f:RegisterEvent("PLAYER_XP_UPDATE")
    f:RegisterEvent("CHAT_MSG_LOOT")

    f:SetScript("OnEvent", toolkitOnEvent)
    f.throtle = 0;
    f:SetScript("OnUpdate", renderData)
    f:Hide()
end

function loadLootToast()
    createToolkitWindow()
    local f = CreateFrame("Frame", "TestLootToast", GW.AlertContainerFrame, nil)
    f:RegisterEvent("ITEM_PUSH")

    f:SetScript("OnEvent", function(self, event, bagID, textureID)
        GW2_UIAlertSystem.AlertSystem:AddAlert("ItemName", nil, name, false, textureID, false)
    end)



    --[[
 local f = CreateFrame("Frame","TestLootToast",GW.AlertContainerFrame,nil)
 f:SetPoint("CENTER")
 f:SetSize(512, 128)
 f:SetBackdrop(constBackdropAlertFrame)

 --frame.Icon.Texture:SetSize(45, 45)
 --frame.Icon.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
]]
end

GW.loadLootToast = loadLootToast
