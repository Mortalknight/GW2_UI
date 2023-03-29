local _, GW = ...

local function Migration()

    -- new Powerbar and Classpowerbar default position
    if GwPlayerPowerBar then
        if GwPlayerPowerBar.isMoved == false then
            GW.ResetMoverFrameToDefaultValues(nil, GwPlayerPowerBar.gwMover)
        end
    end
    if GwPlayerClassPower then
        if GwPlayerClassPower.isMoved == false then
            GW.ResetMoverFrameToDefaultValues(nil, GwPlayerClassPower.gwMover)
        end
    end


end
GW.Migration = Migration