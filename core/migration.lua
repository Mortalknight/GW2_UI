local _, GW = ...


local function DatabaseMigration()
    local oldActiveProfileId, oldActiveProfileName
    if GW2UI_SETTINGS_DB_03 then
        oldActiveProfileId = GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"]
    end
    if GW2UI_PRIVATE_SETTINGS then
        if next(GW2UI_PRIVATE_SETTINGS) then
            for setting, value in next, GW2UI_PRIVATE_SETTINGS do
                GW.private[setting] = value
            end
        end
    end
    if GW2UI_PRIVATE_LAYOUTS then
        if next(GW2UI_PRIVATE_LAYOUTS) then
            for setting, value in next, GW2UI_PRIVATE_LAYOUTS do
                if not GW.private.Layouts then GW.private.Layouts = {} end
                GW.private.Layouts[setting] = value
            end
        end
    end

    if GW2UI_SETTINGS_PROFILES then
        if next(GW2UI_SETTINGS_PROFILES) then
            for k, profileTbl in next, GW2UI_SETTINGS_PROFILES do
                if oldActiveProfileId and oldActiveProfileId == k then
                    oldActiveProfileName = profileTbl.profilename
                end
                GW.globalSettings:SetProfile(profileTbl.profilename)
                for settings, value in next, profileTbl do
                    if type(value) == "table" then
                        GW.settings[settings] = GW.copyTable(value)
                    else
                        GW.settings[settings] = value
                    end
                end
            end
        end
    end

    if GW2UI_LAYOUTS then
        if next(GW2UI_LAYOUTS) then
            for k, profileTbl in next, GW2UI_LAYOUTS do
                if not GW.globalSettings.global.layouts then GW.globalSettings.global.layouts = {} end
                GW.globalSettings.global.layouts[profileTbl.name] = profileTbl
                if GW.globalSettings.global.layouts[profileTbl.name].profileLayout and GW.globalSettings.global.layouts[profileTbl.name].profileLayout == true then
                    GW.globalSettings.global.layouts[profileTbl.name].profileName = GW2UI_SETTINGS_PROFILES[profileTbl.profileId].profilename
                end
            end
        end
    end

    if oldActiveProfileName then
        GW.globalSettings:SetProfile(oldActiveProfileName)
    end

    --GW2UI_PRIVATE_SETTINGS = nil
    --GW2UI_PRIVATE_LAYOUTS = nil
    --GW2UI_SETTINGS_PROFILES = nil
    --GW2UI_LAYOUTS = nil
    --GW2UI_SETTINGS_DB_03 = nil
end
GW.DatabaseMigration = DatabaseMigration


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

    if GW.MoveHudScaleableFrame then
        GW.MoveHudScaleableFrame.layoutManager:GetScript("OnEvent")(GW.MoveHudScaleableFrame.layoutManager)
        GW.MoveHudScaleableFrame.layoutManager:SetAttribute("InMoveHudMode", false)
    end

    GW.InMoveHudMode = false
end
GW.Migration = Migration