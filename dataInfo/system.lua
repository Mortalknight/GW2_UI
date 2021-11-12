local _, GW = ...
local L = GW.L

local enteredInfo = false
local infoDisplay, ipTypes = {}, {"IPv4", "IPv6"}
local infoTable = {}
local cpuProfiling = GetCVar("scriptProfile") == "1"

local CombineAddOns = {
    ["DBM-Core"] = "^<DBM>",
    ["DataStore"] = "^DataStore",
    ["Altoholic"] = "^Altoholic",
    ["AtlasLoot"] = "^AtlasLoot",
    ["Details"] = "^Details!",
    ["RaiderIO"] = "^RaiderIO",
    ["BigWigs"] = "^BigWigs",
}

local function BuildAddonList()
    local addOnCount = GetNumAddOns()
    if addOnCount == #infoTable then return end

    wipe(infoTable)

    for i = 1, addOnCount do
        local name, title, _, loadable, reason = GetAddOnInfo(i)
        if loadable or reason == "DEMAND_LOADED" then
            tinsert(infoTable, {name = name, index = i, title = title})
        end
    end
end
GW.BuildAddonList = BuildAddonList

local function formatMem(memory)
    local mult = 10 ^ 1
    if memory >= 1024 then
        return format("%.2f mb", ((memory / 1024) * mult) / mult)
    else
        return format("%d kb", (memory * mult) / mult)
    end
end

local function displayData(data, totalMEM, totalCPU)
    if not data then return end

    local name, mem, cpu = data.title, data.mem, data.cpu
    if cpu then
        local memRed, cpuRed = mem / totalMEM, cpu / totalCPU
        local memGreen, cpuGreen = (1 - memRed) + 0.5, (1 - cpuRed) + .5
        GameTooltip:AddDoubleLine(name, format("%s%s|r |cffffffff/|r %s%s|r", GW.RGBToHex(memRed, memGreen, 0), formatMem(mem), GW.RGBToHex(cpuRed, cpuGreen, 0), format("%d ms", cpu)), 1, 1, 1)
    else
        local red = mem / totalMEM
        local green = (1 - red) + 0.5
        GameTooltip:AddDoubleLine(name, formatMem(mem), 1, 1, 1, red or 1, green or 1, 0)
    end
end

local function displaySort(a, b)
    return a.sort > b.sort
end

local function FpsOnEnter(self, slow)
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

    local Downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
    if Downloading then
        GameTooltip:AddDoubleLine(L["Bandwidth"], format("%.2f Mbps", GetAvailableBandwidth()), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
        GameTooltip:AddDoubleLine(L["Download"], format("%.2f%%", GetDownloadedPercentage() * 100), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
        GameTooltip:AddLine(" ")
    end

    if slow == 1 or not slow then
        UpdateAddOnMemoryUsage()
    end

    if cpuProfiling and not slow then
        UpdateAddOnCPUUsage()
    end

    wipe(infoDisplay)

    local count, totalMEM, totalCPU = 0, 0, 0
    local showByCPU = cpuProfiling and not IsShiftKeyDown()
    for _, data in ipairs(infoTable) do
        local i = data.index
        if IsAddOnLoaded(i) then
            local mem = GetAddOnMemoryUsage(i)
            totalMEM = totalMEM + mem

            local cpu
            if cpuProfiling then
                cpu = GetAddOnCPUUsage(i)
                totalCPU = totalCPU + cpu
            end

            data.sort = (showByCPU and cpu) or mem
            data.cpu = showByCPU and cpu
            data.mem = mem

            count = count + 1
            infoDisplay[count] = data

            if data.name == "GW2_UI" then
                infoTable[data.name] = data
            end
        end
    end

    GameTooltip:AddDoubleLine(L["AddOn Memory:"], formatMem(totalMEM), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    if cpuProfiling then
        GameTooltip:AddDoubleLine(L["Total CPU:"], format("%d ms", totalCPU), 1, 0.93, 0.73, 0.84, 0.75, 0.65)
    end

    GameTooltip:AddLine(" ")
    for addon, searchString in pairs(CombineAddOns) do
        local addonIndex, memoryUsage, cpuUsage = 0, 0, 0
        for i, data in pairs(infoDisplay) do
            if data and data.name == addon then
                addonIndex = i
                break
            end
        end
        for k, data in pairs(infoDisplay) do
            if type(data) == "table" then
                local name, mem, cpu = data.title, data.mem, data.cpu
                local stripName = GW.StripString(data.title)
                if name and (strmatch(stripName, searchString) or data.name == addon) then
                    if data.name ~= addon and stripName ~= addon then
                        memoryUsage = memoryUsage + mem
                        if showByCPU and cpuProfiling then
                            cpuUsage = cpuUsage + cpu
                        end
                        infoDisplay[k] = false
                    end
                end
            end
        end
        if addonIndex > 0 and infoDisplay[addonIndex] then
            if memoryUsage > 0 then infoDisplay[addonIndex].mem = memoryUsage end
            if cpuProfiling and cpuUsage > 0 then infoDisplay[addonIndex].cpu = cpuUsage end
        end
    end

    for i = count, 1, -1 do
        local data = infoDisplay[i]
        if type(data) == "boolean" then
            tremove(infoDisplay, i)
        end
    end

    sort(infoDisplay, displaySort)

    for i = 1, count do
        displayData(infoDisplay[i], totalMEM, totalCPU)
    end

    GameTooltip:AddLine(" ")
    if showByCPU then
        GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", L["Hold Shift: Memory Usage"], "|r"))
    end

    GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", L["Shift Click: Collect Garbage"], "|r"))
    GameTooltip:AddLine(format("%s%s%s", "|cffaaaaaa", L["Ctrl & Shift Click: Toggle CPU Profiling"], "|r"))
    GameTooltip:Show()
end
GW.FpsOnEnter = FpsOnEnter

local function FpsOnLeave()
    enteredInfo = false
    GameTooltip_Hide()
end
GW.FpsOnLeave = FpsOnLeave

local wait, count = 10, 0
local function FpsOnUpdate(self, elapsed)
    wait = wait - elapsed

    if wait < 0 then
        wait = 1

        local framerate = floor(GetFramerate())

        self.fps:SetText(framerate .. " FPS")

        if not enteredInfo then return end

        if InCombatLockdown() then
            if count > 3 then
                FpsOnEnter(self)
                count = 0
            else
                FpsOnEnter(self, count)
                count = count + 1
            end
        else
            FpsOnEnter(self)
        end
    end
end
GW.FpsOnUpdate = FpsOnUpdate

local function FpsOnClick()
    if IsShiftKeyDown() then
        if IsControlKeyDown() then
            SetCVar("scriptProfile", GetCVarBool("scriptProfile") and 0 or 1)
            ReloadUI()
        else
            collectgarbage("collect")
            ResetCPUUsage()
        end
    end
end
GW.FpsOnClick = FpsOnClick