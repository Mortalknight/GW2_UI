---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

local CACHE_TIME = 120
local RETRY_DELAY = 0.1
local MAX_TRIES = 5

local watcher = CreateFrame("Frame")
-- the guid the shown tooltip already got its item level line for
local shownGUID

local function AddLine(tooltip, guid, itemLevel)
    if shownGUID ~= guid then
        shownGUID = guid
        tooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":", itemLevel, nil, nil, nil, 1, 1, 1)
        tooltip:Show()
    end
end

local function GetCached(guid)
    local cached = GW.unitIlvlsCache[guid]
    if cached and cached.itemLevel and cached.time and GetTime() - cached.time <= CACHE_TIME then
        return cached.itemLevel
    end
end

-- the inspect answer is there, the items of it may still be on their way
local function ReadItemLevel(guid, try)
    local mouseoverGUID = UnitGUID("mouseover")
    if GW.IsSecretValue(mouseoverGUID) or mouseoverGUID ~= guid then
        return
    end
    local itemLevel = GW.GetUnitItemLevel("mouseover")
    if itemLevel == "tooSoon" then
        if try < MAX_TRIES then
            C_Timer.After(RETRY_DELAY, function() ReadItemLevel(guid, try + 1) end)
        end
    elseif itemLevel then
        GW.PopulateUnitIlvlsCache(guid, itemLevel)
        if not GameTooltip:IsForbidden() and GameTooltip:IsShown() then
            AddLine(GameTooltip, guid, itemLevel)
        end
    end
end

-- shift on a player out of combat: the average item level, inspected if not known from the last minutes
local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or not IsShiftKeyDown() or InCombatLockdown() then
        return
    end
    local unit = Tooltip.GetUnit(tooltip, data)
    if not unit or not UnitIsPlayer(unit) then
        return
    end
    local guid = UnitGUID(unit)
    if GW.IsSecretValue(guid) or not guid then
        return
    end

    if guid == GW.myguid then
        AddLine(tooltip, guid, select(2, GW.GetPlayerItemLevel()))
        return
    end
    local itemLevel = GetCached(guid)
    if itemLevel then
        AddLine(tooltip, guid, itemLevel)
    elseif CanInspect(unit) and not (GW.Mists and not CheckInteractDistance(unit, 4)) then
        watcher.pendingGUID = guid
        watcher:RegisterEvent("INSPECT_READY")
        NotifyInspect(unit)
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        if not (GW.Retail or GW.Mists) then
            return
        end
        watcher:SetScript("OnEvent", function(self, _, guid)
            if GW.NotSecretValue(guid) and guid == self.pendingGUID then
                self:UnregisterEvent("INSPECT_READY")
                self.pendingGUID = nil
                ReadItemLevel(guid, 1)
            end
        end)
        GameTooltip:HookScript("OnTooltipCleared", function() shownGUID = nil end)
        Tooltip.OnTooltipData("Unit", OnUnitTooltip)
    end,
})
