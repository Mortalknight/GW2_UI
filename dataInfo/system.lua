local GW2Name, GW = ...
local L = GW.L

local enteredInfo = false
local infoDisplay, ipTypes = {}, {"IPv4", "IPv6"}
local infoTable = {}
local cpuProfiling = GetCVar("scriptProfile") == "1"
local ScrollButtonIcon = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t"

local CombineAddOns = {
    ["DBM-Core"] = "^<DBM Core>",
    ["DataStore"] = "^DataStore",
    ["Altoholic"] = "^Altoholic",
    ["AtlasLoot"] = "^AtlasLoot",
    ["Details"] = "^Details!",
    ["RaiderIO"] = "^RaiderIO",
    ["BigWigs"] = "^BigWigs",
}

local function BuildAddonList()
    local addOnCount = C_AddOns.GetNumAddOns()
    if addOnCount == #infoTable then return end

    wipe(infoTable)

    for i = 1, addOnCount do
        local name, title, _, loadable, reason = C_AddOns.GetAddOnInfo(i)
        if loadable or reason == "DEMAND_LOADED" then
            tinsert(infoTable, {name = name, index = i, title = title})
        end
    end
end
GW.BuildAddonList = BuildAddonList

local function formatMem(memory)
    if memory >= 1024 then
        return format("%.2f mb", memory / 1024)
    else
       return format("%d kb", memory)
    end
end

local function displayData(data, totalMem, totalCPU)
    if not data then return end
    if totalMem == 0 then totalMem = 0.00000000000000000001 end

    local name, mem, cpu = data.title, data.mem, data.cpu
    local memRatio = mem / totalMem
    local memColor = GW.RGBToHex(memRatio, (1 - memRatio) + 0.5, 0)

    if cpu then
        local cpuRatio = cpu / totalCPU
        local cpuColor = GW.RGBToHex(cpuRatio, (1 - cpuRatio) + 0.5, 0)
        GameTooltip:AddDoubleLine(name, format("%s%s|r |cffffffff/|r %s%s|r", memColor, formatMem(mem), cpuColor, format("%d ms", cpu)), 1, 1, 1)
    else
        GameTooltip:AddDoubleLine(name, formatMem(mem), 1, 1, 1, memRatio, (1 - memRatio) + 0.5, 0)
    end
end

local function displaySort(a, b)
    return a.sort > b.sort
end

local function FpsOnEnter(self, slow)
    if GW.settings.MINIMAP_FPS_TOOLTIP_DISABLED then return end
    enteredInfo = true
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    local _, _, homePing, worldPing = GetNetStats()
    GameTooltip:AddDoubleLine(L["Home Latency:"], format("%d ms", homePing), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    GameTooltip:AddDoubleLine(L["World Latency:"], format("%d ms", worldPing), 1, 0.93, 0.73, 0.84, 0.75, 0.65)

    if GetCVarBool("useIPv6") then
        local ipTypeHome, ipTypeWorld = GetNetIpTypes()
        GameTooltip:AddDoubleLine(L["Home Protocol:"], ipTypes[ipTypeHome or 0] or UNKNOWN, 1, 0.93, 0.73, 0.84, 0.75, 0.65)
        GameTooltip:AddDoubleLine(L["World Protocol:"], ipTypes[ipTypeWorld or 0] or UNKNOWN, 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    end

    if GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0 then
        GameTooltip:AddDoubleLine(L["Bandwidth"], format("%.2f Mbps", GetAvailableBandwidth()), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
        GameTooltip:AddDoubleLine(L["Download"], format("%.2f%%", GetDownloadedPercentage() * 100), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
        GameTooltip:AddLine(" ")
    end

    if slow == 1 or not slow then UpdateAddOnMemoryUsage() end
    if cpuProfiling and not slow then UpdateAddOnCPUUsage() end

    wipe(infoDisplay)

    local totalMEM, totalCPU = 0, 0
    local showByCPU = cpuProfiling and not IsShiftKeyDown()

    for _, data in ipairs(infoTable) do
        if C_AddOns.IsAddOnLoaded(data.index) then
            local mem = GetAddOnMemoryUsage(data.index)
            local cpu = cpuProfiling and GetAddOnCPUUsage(data.index) or nil

            totalMEM = totalMEM + mem
            if cpu then totalCPU = totalCPU + cpu end

            data.mem, data.cpu = mem, cpu
            data.sort = cpu or mem
            tinsert(infoDisplay, data)
        end
    end

    GameTooltip:AddDoubleLine(L["AddOn Memory:"], formatMem(totalMEM), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    if cpuProfiling then
        GameTooltip:AddDoubleLine(L["Total CPU:"], format("%d ms", totalCPU), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    end

    GameTooltip:AddLine(" ")

    local usedKeys = {}
    for addon, pattern in pairs(CombineAddOns) do
        local totalMem, totalCPU = 0, 0
        local mainData = nil

        for i = #infoDisplay, 1, -1 do
            local data = infoDisplay[i]
            if type(data) == "table" then
                local name = data.title
                local stripName = GW.StripString(name)

                if name and (strmatch(stripName, pattern) or data.name == addon) then
                    totalMem = totalMem + data.mem
                    if showByCPU and cpuProfiling then
                        totalCPU = totalCPU + (data.cpu or 0)
                    end

                    if not mainData and (data.name == addon or stripName == addon) then
                        mainData = data
                    else
                        tremove(infoDisplay, i)
                    end
                end
            end
        end

        if mainData then
            mainData.mem = totalMem
            mainData.cpu = showByCPU and totalCPU or nil
            mainData.sort = showByCPU and totalCPU or totalMem
        end
    end

    local found = false
    for _, data in ipairs(infoDisplay) do
        if GW.StripString(data.title) == GW2Name or data.name == GW2Name then
            found = true
            break
        end
    end

    if not found then
        for _, data in ipairs(infoTable) do
            if (data.name == GW2Name or GW.StripString(data.title) == GW2Name) then
                local mem = GetAddOnMemoryUsage(data.index)
                local cpu = cpuProfiling and GetAddOnCPUUsage(data.index) or nil

                data.mem = mem
                data.cpu = cpu
                data.sort = showByCPU and cpu or mem

                tinsert(infoDisplay, data)
                break
            end
        end
    end

    local finalDisplay = {}
    for i, data in ipairs(infoDisplay) do
        if not usedKeys[i] then
            tinsert(finalDisplay, data)
        elseif usedKeys[i] == true and data.name then
            tinsert(finalDisplay, data) -- reinserting main entries
        end
    end

    sort(finalDisplay, displaySort)
    local displayLimit = IsAltKeyDown() and math.huge or 30
    for i = 1, math.min(displayLimit, #finalDisplay) do
        displayData(finalDisplay[i], totalMEM, totalCPU)
    end

    if #finalDisplay > displayLimit then
        local hiddenCount, hiddenMem = #finalDisplay - displayLimit, 0

        for i = displayLimit + 1, #finalDisplay do
            hiddenMem = hiddenMem + (finalDisplay[i].mem or 0)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(format(L["Hidden AddOns: %d"], hiddenCount), formatMem(hiddenMem), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    end

    GameTooltip:AddLine(" ")
    if showByCPU then
        GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", L["Hold Shift: Memory Usage"], "|r"))
    end
    if not IsAltKeyDown() and #finalDisplay > displayLimit then
        GameTooltip:AddLine(format("|cffaaaaaa%s|r", L["Hold Alt: Show All AddOns"]))
    end
    GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", L["Shift Click: Collect Garbage"], "|r"))
    GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", L["Ctrl & Shift Click: Toggle CPU Profiling"], "|r"))
    GameTooltip:AddLine(format("%s%s %s: %s%s", "|cffaaaaaa", ScrollButtonIcon, L["Middle Button"], RELOADUI, "|r"))
    GameTooltip:Show()
end
GW.FpsOnEnter = FpsOnEnter

local function FpsOnLeave()
    enteredInfo = false
    GameTooltip_Hide()
end
GW.FpsOnLeave = FpsOnLeave

local wait, rate, delay = 10, 0, 0
local function FpsOnUpdate(self, elapsed)
    if wait < 1 then
        wait = wait + elapsed
        rate = rate + 1
    else
        wait = 0

        self.fps:SetText(rate .. " FPS")

        rate = 0 -- ok reset it

        if not enteredInfo then
			return
		elseif InCombatLockdown() then
            if delay > 3 then
                FpsOnEnter(self)
                delay = 0
            else
                FpsOnEnter(self, delay)
                delay = delay + 1
            end
        else
            FpsOnEnter(self)
        end
    end
end
GW.FpsOnUpdate = FpsOnUpdate

local function FpsOnEvent(self)
    if enteredInfo then
        FpsOnEnter(self)
    end
end
GW.FpsOnEvent = FpsOnEvent

local function FpsOnClick(_, mouseButton)
    if IsShiftKeyDown() then
        if IsControlKeyDown() then
            C_CVar.SetCVar("scriptProfile", GetCVarBool("scriptProfile") and "0" or "1")
            C_UI.Reload()
        else
            collectgarbage("collect")
            ResetCPUUsage()
        end
    elseif mouseButton == "MiddleButton" then
        C_UI.Reload()
    end
end
GW.FpsOnClick = FpsOnClick