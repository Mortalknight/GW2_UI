local _, GW = ...

local function loopTableForIntConv(tbl, settingToChange)
    for setting, value in next, tbl do
        if type(value) == "table" then
            loopTableForIntConv(value, settingToChange[setting])
        else
            if tonumber(value) then
                settingToChange = tonumber(value)
            end
        end
    end
end

local function ConvertDBIntegerBackToIntegers()
    if next(GW.globalSettings.profiles) then
        for profileName, profileTbl in next, GW.globalSettings.profiles do
            for setting, value in next, profileTbl do
                if type(value) == "table" then
                    loopTableForIntConv(value, GW.globalSettings.profiles[profileName][setting])
                else
                    if tonumber(value) then
                        GW.globalSettings.profiles[profileName][setting] = tonumber(value)
                    end
                end
            end
        end
    end
end
GW.ConvertDBIntegerBackToIntegers = ConvertDBIntegerBackToIntegers
--/run GW2_ADDON.ConvertDBIntegerBackToIntegers()

local function DatabaseMigration(globalDb, privateDb)
    local oldActiveProfileId, oldActiveProfileName

    if privateDb then
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

        if GW2UI_SETTINGS_DB_03 then
            oldActiveProfileId = GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"]
        end
    end
    if globalDb then
        if GW2UI_SETTINGS_PROFILES then
            if next(GW2UI_SETTINGS_PROFILES) then
                for k, profileTbl in next, GW2UI_SETTINGS_PROFILES do
                    if oldActiveProfileId and oldActiveProfileId == k then
                        oldActiveProfileName = profileTbl.profilename
                    end

                    local profileName = profileTbl.profilename
                    if not profileName == nil then
                        local skipProfile = false
                        if GW.globalSettings.profiles[profileName] then
                            local counter = 0
                            repeat
                                counter = counter + 1
                                profileName = profileTbl.profilename .. counter
                            until not GW.globalSettings.profiles[profileName] or counter == 100
                            if GW.globalSettings.profiles[profileName] then
                                skipProfile = true
                            end
                        end
                        if not skipProfile then
                            profileTbl.profilename = profileName
                            GW.globalSettings:SetProfile(profileName)
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
            end
        end

        if GW2UI_LAYOUTS then
            if next(GW2UI_LAYOUTS) then
                for _, profileTbl in next, GW2UI_LAYOUTS do
                    if profileTbl and profileTbl.name then
                        if not GW.globalSettings.global.layouts then GW.globalSettings.global.layouts = {} end

                        GW.globalSettings.global.layouts[profileTbl.name] = profileTbl
                        if GW.globalSettings.global.layouts[profileTbl.name].profileLayout and GW.globalSettings.global.layouts[profileTbl.name].profileLayout == true and profileTbl.profileId 
                            and GW2UI_SETTINGS_PROFILES[profileTbl.profileId] and GW2UI_SETTINGS_PROFILES[profileTbl.profileId].profilename then
                            GW.globalSettings.global.layouts[profileTbl.name].profileName = GW2UI_SETTINGS_PROFILES[profileTbl.profileId].profilename
                        end
                        GW.globalSettings.global.layouts[profileTbl.name].id = nil
                        GW.globalSettings.global.layouts[profileTbl.name].profileId = nil
                    end
                end
            end
        end
    end

    ConvertDBIntegerBackToIntegers()

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