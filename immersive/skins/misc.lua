local _, GW = ...
local GetSetting = GW.GetSetting

local function LoadMiscBlizzardFrameSkins()
    if not GetSetting("MISC_SKIN_ENABLED") then return end

    GW.LoadTimerTrackerSkin()
    GW.LoadGhostFrameSkin()
end
GW.LoadMiscBlizzardFrameSkins = LoadMiscBlizzardFrameSkins