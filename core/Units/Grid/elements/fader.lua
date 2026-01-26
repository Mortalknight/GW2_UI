local _, GW = ...

local function Construct_Faderframe()
    return {}
end
GW.Construct_Faderframe = Construct_Faderframe

local function Update_Faderframe(frame, profile)
    local frameFaderSettings = GW.settings[profile .. "FrameFader"]
    local RangeframeFaderSettings = GW.settings[profile .. "FrameFaderRange"]
    if RangeframeFaderSettings or frameFaderSettings.health or frameFaderSettings.hover or frameFaderSettings.combat or frameFaderSettings.casting or frameFaderSettings.dynamicflight or frameFaderSettings.vehicle or frameFaderSettings.playertarget then

        if not frame:IsElementEnabled("Fader") then
            frame:EnableElement("Fader")
        end
        frame.Fader:SetOption("Range", RangeframeFaderSettings)
        frame.Fader:SetOption("Health", frameFaderSettings.health)
        frame.Fader:SetOption("Hover", frameFaderSettings.hover)
        frame.Fader:SetOption("Combat", frameFaderSettings.combat)
        frame.Fader:SetOption("Casting", frameFaderSettings.casting)
        frame.Fader:SetOption("DynamicFlight", frameFaderSettings.dynamicflight)
        frame.Fader:SetOption("Smooth", (frameFaderSettings.smooth > 0 and frameFaderSettings.smooth) or nil)
        frame.Fader:SetOption("MinAlpha", frameFaderSettings.minAlpha)
        frame.Fader:SetOption("MaxAlpha", frameFaderSettings.maxAlpha)
        frame.Fader:SetOption("Health", frameFaderSettings.health)
        frame.Fader:SetOption("Vehicle", frameFaderSettings.vehicle)
        frame.Fader:SetOption("PlayerTarget", frameFaderSettings.playertarget)

        frame.Fader:ClearTimers()
        frame.Fader.configTimer = C_Timer.NewTimer(0.25, function() frame.Fader:ForceUpdate() end)
    elseif frame:IsElementEnabled("Fader") then
        frame:DisableElement("Fader")
    end
end
GW.Update_Faderframe = Update_Faderframe
