---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- ROGUE (combo points)
if GW.myClassID ~= GW.Enum.ClassIndex.Rogue then return end

local function setRogue(f)
    if GW.settings.unitframes.target.hookComboPoints then return false end

    CP.setComboBar(f)
    return true
end

CP.setups[GW.Enum.ClassIndex.Rogue] = setRogue
