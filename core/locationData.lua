local _, GW = ...
local mapInfoWatcher = CreateFrame("Frame")
local coordsWatcher = CreateFrame("Frame")
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
local  HBD = nil

-- we need to load this function here because it is need in defaults.lua
local function MapTable(T, fn, withKey)
    local t = {}
    for k,v in pairs(T) do
        if withKey then
            t[k] = fn(v, k)
        else
            t[k] = fn(v)
        end
    end
    return t
end
GW.MapTable = MapTable
