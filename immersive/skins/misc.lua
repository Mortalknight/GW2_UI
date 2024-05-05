local _, GW = ...

local function LoadMiscBlizzardFrameSkins()
    if not GW.GetSetting("MISC_SKIN_ENABLED") then return end

    GW.LoadTimerTrackerSkin()
    GW.LoadGhostFrameSkin()
end
GW.LoadMiscBlizzardFrameSkins = LoadMiscBlizzardFrameSkins