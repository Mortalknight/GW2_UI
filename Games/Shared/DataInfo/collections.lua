---@class GW2
local GW = select(2, ...)

local mountCache = {collected = 0, total = 0, time = 0}
local MOUNT_CACHE_SECONDS = 10

local function GetMountCounts()
    if not (C_MountJournal and C_MountJournal.GetMountIDs and C_MountJournal.GetMountInfoByID) then return nil end
    if GetTime() - mountCache.time < MOUNT_CACHE_SECONDS then
        return mountCache.collected, mountCache.total
    end

    local collected, total = 0, 0
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local _, _, _, _, _, _, _, _, _, shouldHideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        if not shouldHideOnChar then
            total = total + 1
            if isCollected then
                collected = collected + 1
            end
        end
    end
    mountCache.collected, mountCache.total, mountCache.time = collected, total, GetTime()
    return collected, total
end

local function Collections_OnEnter(self)
    local lines = {}

    local mountsCollected, mountsTotal = GetMountCounts()
    if mountsTotal and mountsTotal > 0 then
        tinsert(lines, {MOUNTS, mountsCollected, mountsTotal})
    end
    if C_PetJournal and C_PetJournal.GetNumPets then
        local numPets, numOwned = C_PetJournal.GetNumPets()
        if numPets and numPets > 0 then
            tinsert(lines, {PETS, numOwned or 0, numPets})
        end
    end
    if C_ToyBox and C_ToyBox.GetNumTotalDisplayedToys then
        local total = C_ToyBox.GetNumTotalDisplayedToys()
        if total and total > 0 then
            tinsert(lines, {TOY_BOX, C_ToyBox.GetNumLearnedDisplayedToys() or 0, total})
        end
    end
    if C_Heirloom and C_Heirloom.GetNumHeirlooms then
        local total = C_Heirloom.GetNumHeirlooms()
        if total and total > 0 then
            tinsert(lines, {HEIRLOOMS, C_Heirloom.GetNumKnownHeirlooms() or 0, total})
        end
    end

    if #lines == 0 or not GW.EnsureMicroMenuTooltip(self) then return end

    GameTooltip:AddLine(" ")
    for _, line in ipairs(lines) do
        GameTooltip:AddDoubleLine(line[1], GW.FormatProgressFraction(line[2], line[3]), 0.8, 0.8, 0.8)
    end
    GameTooltip:Show()
end
GW.Collections_OnEnter = Collections_OnEnter
