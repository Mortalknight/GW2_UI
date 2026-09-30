---@class GW2
local GW = select(2, ...)
local addonName = ...
local L = GW.L

local MAX_LISTED = 30
local IP_TYPES = { "IPv4", "IPv6" }
local MIDDLE_MOUSE_ICON = CreateTextureMarkup("Interface/TUTORIALFRAME/UI-TUTORIAL-FRAME", 512, 512, 11, 13, 12 / 512, 66 / 512, 127 / 512, 204 / 512, 0, -1)

local cpuProfiling = GetCVar("scriptProfile") == "1"
local addons = {} -- every addon that can be loaded: index, title and family
local knownAddOnCount = 0
local tooltipOwner

-- addons that ship in parts share a name prefix, "DBM-Core" and "DBM-Raids" are listed as "DBM"
local function GetFamily(name)
    return name:match("^([^_%-]+)[_%-]") or name
end

-- our own usage is shown apart from the ranking
local OWN_FAMILY = GetFamily(addonName)

local function BuildAddonList()
    local count = C_AddOns.GetNumAddOns()
    if count == knownAddOnCount then return end
    knownAddOnCount = count

    wipe(addons)
    for index = 1, count do
        local name, title, _, loadable, reason = C_AddOns.GetAddOnInfo(index)
        if loadable or reason == "DEMAND_LOADED" then
            addons[#addons + 1] = { index = index, name = name, title = title, family = GetFamily(name) }
        end
    end
end
GW.BuildAddonList = BuildAddonList

local function FormatMemory(kb)
    return kb >= 1024 and format("%.2f mb", kb / 1024) or format("%d kb", kb)
end

local function FormatCPU(ms)
    return format("%d ms", ms)
end

-- by the share of the whole addon usage: green for small users, yellow at half of this, red at it
local RED_AT_SHARE = 0.5

local function UsageColor(share)
    local colors = GW.Colors.SkinColors
    local good, middle, bad = colors.Positive, colors.QuestGold, colors.Negative
    return CreateColor(GW.ColorGradient(share, good.r, good.g, good.b, middle.r, middle.g, middle.b, bad.r, bad.g, bad.b))
end

local function SortByUsage(a, b)
    return a.usage > b.usage
end

-- loaded addons summed up per family, biggest first; our own family is returned on its own
local function CollectUsage(byCPU)
    local families, list = {}, {}
    local totalMemory, totalCPU = 0, 0

    for _, addon in ipairs(addons) do
        if C_AddOns.IsAddOnLoaded(addon.index) then
            local memory = GetAddOnMemoryUsage(addon.index)
            local cpu = cpuProfiling and GetAddOnCPUUsage(addon.index) or 0
            totalMemory, totalCPU = totalMemory + memory, totalCPU + cpu

            local family = families[addon.family]
            if not family then
                family = { title = addon.title, memory = 0, cpu = 0, parts = 0 }
                families[addon.family] = family
                list[#list + 1] = family
            end
            -- the part named like the family names the group
            if addon.name == addon.family then
                family.title = addon.title
            end
            family.memory, family.cpu, family.parts = family.memory + memory, family.cpu + cpu, family.parts + 1
        end
    end

    for _, family in ipairs(list) do
        family.usage = byCPU and family.cpu or family.memory
    end
    local own = families[OWN_FAMILY]
    if own then
        tremove(list, tIndexOf(list, own))
    end
    sort(list, SortByUsage)
    return list, totalMemory, totalCPU, own
end

local function AddInfoLine(label, value)
    local labelColor, valueColor = GW.Colors.TextColors.LightHeader, GW.Colors.FallbackWhite
    GameTooltip:AddDoubleLine(label, value, labelColor.r, labelColor.g, labelColor.b, valueColor.r, valueColor.g, valueColor.b)
end

local function AddHint(text)
    GameTooltip:AddLine(GW.Colors.SkinColors.Disabled:WrapTextInColorCode(text))
end

local function AddNetworkLines()
    local _, _, homePing, worldPing = GetNetStats()
    AddInfoLine(L["Home Latency:"], format("%d ms", homePing))
    AddInfoLine(L["World Latency:"], format("%d ms", worldPing))

    if GetCVarBool("useIPv6") then
        local homeType, worldType = GetNetIpTypes()
        AddInfoLine(L["Home Protocol:"], IP_TYPES[homeType or 0] or UNKNOWN)
        AddInfoLine(L["World Protocol:"], IP_TYPES[worldType or 0] or UNKNOWN)
    end

    -- only while the client still streams game data
    if GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0 then
        AddInfoLine(L["Bandwidth"], format("%.2f Mbps", GetAvailableBandwidth()))
        AddInfoLine(L["Download"], format("%.2f%%", GetDownloadedPercentage() * 100))
        GameTooltip:AddLine(" ")
    end
end

local function AddAddonLines()
    local byCPU = cpuProfiling and not IsShiftKeyDown()
    local list, totalMemory, totalCPU, own = CollectUsage(byCPU)

    AddInfoLine(L["AddOn Memory:"], FormatMemory(totalMemory))
    if cpuProfiling then
        AddInfoLine(L["Total CPU:"], FormatCPU(totalCPU))
    end
    GameTooltip:AddLine(" ")

    local limit = IsAltKeyDown() and #list or min(#list, MAX_LISTED)
    local total = byCPU and totalCPU or totalMemory
    local function AddFamilyLine(family)
        local color = UsageColor(total > 0 and family.usage / total / RED_AT_SHARE or 0)
        local value = byCPU and FormatCPU(family.cpu) or FormatMemory(family.memory)
        local title = family.parts > 1 and format("%s (%d)", family.title, family.parts) or family.title
        GameTooltip:AddDoubleLine(title, color:WrapTextInColorCode(value), GW.Colors.FallbackWhite:GetRGB())
    end

    -- our own line stands apart, so it does not read like the top of the ranking
    if own then
        AddFamilyLine(own)
        GameTooltip:AddLine(" ")
    end
    for i = 1, limit do
        AddFamilyLine(list[i])
    end

    if #list > limit then
        local hiddenMemory = 0
        for i = limit + 1, #list do
            hiddenMemory = hiddenMemory + list[i].memory
        end
        GameTooltip:AddLine(" ")
        AddInfoLine(format(L["Hidden AddOns: %d"], #list - limit), FormatMemory(hiddenMemory))
    end

    GameTooltip:AddLine(" ")
    if byCPU then
        AddHint(L["Hold Shift: Memory Usage"])
    end
    if #list > limit then
        AddHint(L["Hold Alt: Show All AddOns"])
    end
    AddHint(L["Shift Click: Collect Garbage"])
    AddHint(L["Ctrl & Shift Click: Toggle CPU Profiling"])
    AddHint(format("%s %s: %s", MIDDLE_MOUSE_ICON, L["Middle Button"], RELOADUI))
end

local function ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    -- measuring cpu is expensive, in combat only memory is refreshed
    UpdateAddOnMemoryUsage()
    if cpuProfiling and not InCombatLockdown() then
        UpdateAddOnCPUUsage()
    end

    AddNetworkLines()
    AddAddonLines()
    GameTooltip:Show()
    self.nextTooltipRefresh = GetTime() + (InCombatLockdown() and 4 or 1)
end

local function FpsOnEnter(self)
    if GW.settings.minimap.fpsTooltipDisabled then return end
    tooltipOwner = self
    ShowTooltip(self)
end
GW.FpsOnEnter = FpsOnEnter

local function FpsOnLeave()
    tooltipOwner = nil
    GameTooltip_Hide()
end
GW.FpsOnLeave = FpsOnLeave

-- runs once per second from the minimap ticker
local function FpsOnUpdate(self)
    self.fps:SetText(format("%d FPS", Round(GetFramerate())))
    if tooltipOwner == self and GetTime() >= (self.nextTooltipRefresh or 0) then
        ShowTooltip(self)
    end
end
GW.FpsOnUpdate = FpsOnUpdate

-- shift and alt change the list, show it right away
local function FpsOnEvent(self)
    if tooltipOwner == self then
        ShowTooltip(self)
    end
end
GW.FpsOnEvent = FpsOnEvent

local function FpsOnClick(_, mouseButton)
    if mouseButton == "MiddleButton" then
        C_UI.Reload()
    elseif IsShiftKeyDown() and IsControlKeyDown() then
        C_CVar.SetCVar("scriptProfile", cpuProfiling and "0" or "1")
        C_UI.Reload()
    elseif IsShiftKeyDown() then
        collectgarbage("collect")
        ResetCPUUsage()
    end
end
GW.FpsOnClick = FpsOnClick
