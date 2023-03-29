local _, GW = ...

local function Migration()
    GW.InMoveHudMode = true
    -- new Powerbar and Classpowerbar default position
    if GwPlayerPowerBar then
        if GwPlayerPowerBar.isMoved == false then
            GW.ResetMoverFrameToDefaultValues(nil, nil, GwPlayerPowerBar.gwMover)
        end
    end
    if GwPlayerClassPower then
        if GwPlayerClassPower.isMoved == false then
            GW.ResetMoverFrameToDefaultValues(nil, nil, GwPlayerClassPower.gwMover)
        end
    end
    if GwMultiBarBottomRight then
        if GwMultiBarBottomRight.isMoved == false then
            GW.ResetMoverFrameToDefaultValues(nil, nil, GwMultiBarBottomRight.gwMover)
        end
    end


    GW.MoveHudScaleableFrame.layoutManager:GetScript("OnEvent")(GW.MoveHudScaleableFrame.layoutManager)
    GW.MoveHudScaleableFrame.layoutManager:SetAttribute("InMoveHudMode", false)

    GW.InMoveHudMode = false
end
GW.Migration = Migration