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

local function ConvertDbStringToInteger(tbl)
    for setting, value in next, tbl do
        if type(value) == "table" then
            loopTableForIntConv(value, tbl[setting])
        else
            if tonumber(value) then
                tbl[setting] = tonumber(value)
            end
        end
    end
    return tbl
end
GW.ConvertDbStringToInteger = ConvertDbStringToInteger

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
                                    GW.settings[settings] = GW.CopyTable(value)
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

    GW2UI_PRIVATE_SETTINGS = nil
    GW2UI_PRIVATE_LAYOUTS = nil
    GW2UI_SETTINGS_PROFILES = nil
    GW2UI_LAYOUTS = nil
    GW2UI_SETTINGS_DB_03 = nil
end
GW.DatabaseMigration = DatabaseMigration

local function DatabaseValueMigration()
    -- migration for font module
    if GW.settings.FONTS_ENABLED then
        if not GW.settings.FONTS_ENABLED then
            GW.settings.FONT_STYLE_TEMPLATE = "BLIZZARD"
            GW.settings.FONTS_BIG_HEADER_SIZE = 16
            GW.settings.FONTS_HEADER_SIZE = 14
            GW.settings.FONTS_NORMAL_SIZE = 12
            GW.settings.FONTS_SMALL_SIZE = 11
            GW.settings.FONTS_OUTLINE = ""
            GW.settings.FONT_NORMAL = ""
            GW.settings.FONT_HEADERS = ""
        end

        GW.settings.FONTS_ENABLED = nil
    end

    -- migration minimap scale setting
    if GW.settings.MINIMAP_SCALE then
        GW.settings.MINIMAP_SIZE = GW.settings.MINIMAP_SCALE
        GW.settings.MINIMAP_SCALE = nil
    end

    -- migration for chat timestap
    if not GW.settings.chatTimeStampMigrationDone then
        local timestampFormat = GetChatTimestampFormat()
        GW.settings.timeStampFormat = timestampFormat

        GW.settings.chatTimeStampMigrationDone = true
    end

    -- migration of tooltip item count
    if type(GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT) == "string" then
        local db = {
            Bank = true,
            Bag = true,
            Stack = false
        }
        if GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "BANK" then
            db.Bank = true
            db.Bag = false
        elseif GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "BAG" then
            db.Bank = false
            db.Bag = true
        elseif GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "BOTH" then
            db.Bank = true
            db.Bag = true
        elseif GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "NONE" then
            db.Bank = false
            db.Bag = false
        end

        GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT = db
    end

    -- migrationtarget frame itemlevel
    if type(GW.settings.target_ILVL) == "boolean" then
        GW.settings.target_ILVL = GW.settings.target_ILVL == true and "ITEM_LEVEL" or "PVP_LEVEL"
    end

    if GW.settings.TARGET_UNIT_HEALTH_SHORT_VALUES ~= nil then
        GW.settings.target_SHORT_VALUES = GW.settings.TARGET_UNIT_HEALTH_SHORT_VALUES
        GW.settings.TARGET_UNIT_HEALTH_SHORT_VALUES = nil
    end

    if GW.settings.FOCUS_UNIT_HEALTH_SHORT_VALUES ~= nil then
        GW.settings.focus_SHORT_VALUES = GW.settings.FOCUS_UNIT_HEALTH_SHORT_VALUES
        GW.settings.FOCUS_UNIT_HEALTH_SHORT_VALUES = nil
    end

    -- fix Default Profile tag
    if not GW.settings.profileMetaDataFixed and GW.private.GW2_UI_VERSION ~= "WELCOME" then
        local profiles = GW.globalSettings:GetProfiles()
        for _, profile in pairs( profiles ) do
            if profile == "Default" and GW.globalSettings.profiles[profile].profileCreatedCharacter == UNKNOWN then
                GW.globalSettings.profiles[profile].profileCreatedCharacter = "GW2_UI"
                GW.globalSettings.profiles[profile].profileCreatedDate = date(GW.L["TimeStamp m/d/y h:m:s"])
            end
            local dateString = GW.globalSettings.profiles[profile].profileCreatedDate
            if dateString and dateString:match("^(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)$") then
                local month, day, year, hour, min, sec = dateString:match("(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")
                year = tonumber(year)
                if year < 70 then
                    year = 2000 + year
                else
                    year = 1900 + year
                end
                local t = {
                    year = year,
                    month = tonumber(month),
                    day = tonumber(day),
                    hour = tonumber(hour),
                    min = tonumber(min),
                    sec = tonumber(sec),
                }
                local timestamp = time(t)
                GW.globalSettings.profiles[profile].profileCreatedDate = date(GW.L["TimeStamp m/d/y h:m:s"], timestamp)
            elseif dateString == UNKNOWN then
                GW.globalSettings.profiles[profile].profileCreatedDate = date(GW.L["TimeStamp m/d/y h:m:s"])
            end
        end
        GW.settings.profileMetaDataFixed = true
    end

    --player buff size
    if GW.settings.PlayerBuffFrame_ICON_SIZE then
        GW.settings.PlayerBuffs.Seperate = GW.settings.PlayerBuffFrame_Seperate or GW.settings.PlayerBuffs.Seperate
        GW.settings.PlayerBuffs.SortDir = GW.settings.PlayerBuffFrame_SortDir or GW.settings.PlayerBuffs.SortDir
        GW.settings.PlayerBuffs.SortMethod = GW.settings.PlayerBuffFrame_SortMethod or GW.settings.PlayerBuffs.SortMethod
        GW.settings.PlayerBuffs.IconSize = GW.RoundDec(GW.settings.PlayerBuffFrame_ICON_SIZE or GW.settings.PlayerBuffs.IconSize)
        GW.settings.PlayerBuffs.IconHeight = GW.RoundDec(GW.settings.PlayerBuffFrame_ICON_SIZE or GW.settings.PlayerBuffs.IconSize)
        GW.settings.PlayerBuffs.GrowDirection = GW.settings.PlayerBuffFrame_GrowDirection or GW.settings.PlayerBuffs.GrowDirection
        GW.settings.PlayerBuffs.HorizontalSpacing = GW.settings.PlayerBuffFrame_HorizontalSpacing or GW.settings.PlayerBuffs.HorizontalSpacing
        GW.settings.PlayerBuffs.VerticalSpacing = GW.settings.PlayerBuffFrame_VerticalSpacing or GW.settings.PlayerBuffs.VerticalSpacing
        GW.settings.PlayerBuffs.MaxWraps = GW.settings.PlayerBuffFrame_MaxWraps or GW.settings.PlayerBuffs.MaxWraps
        GW.settings.PlayerBuffs.WrapAfter = GW.settings.PLAYER_AURA_WRAP_NUM or GW.settings.PlayerBuffs.WrapAfter
        GW.settings.PlayerBuffs.NewAuraAnimation = GW.settings.PLAYER_AURA_ANIMATION or GW.settings.PlayerBuffs.NewAuraAnimation

        GW.settings.PlayerBuffFrame_Seperate = nil
        GW.settings.PlayerBuffFrame_SortDir = nil
        GW.settings.PlayerBuffFrame_SortMethod = nil
        GW.settings.PlayerBuffFrame_ICON_SIZE = nil
        GW.settings.PlayerBuffFrame_GrowDirection = nil
        GW.settings.PlayerBuffFrame_HorizontalSpacing = nil
        GW.settings.PlayerBuffFrame_VerticalSpacing = nil
        GW.settings.PLAYER_AURA_WRAP_NUM = nil
        GW.settings.PlayerBuffFrame_MaxWraps = nil
        GW.settings.PLAYER_AURA_ANIMATION = nil
    end
    if GW.settings.PlayerDebuffFrame_ICON_SIZE then
        GW.settings.PlayerDebuffs.Seperate = GW.settings.PlayerDebuffFrame_Seperate or GW.settings.PlayerDebuffs.Seperate
        GW.settings.PlayerDebuffs.SortDir = GW.settings.PlayerDebuffFrame_SortDir or GW.settings.PlayerDebuffs.SortDir
        GW.settings.PlayerDebuffs.SortMethod = GW.settings.PlayerDebuffFrame_SortMethod or GW.settings.PlayerDebuffs.SortMethod
        GW.settings.PlayerDebuffs.IconSize = GW.RoundDec(GW.settings.PlayerDebuffFrame_ICON_SIZE or GW.settings.PlayerDebuffs.IconSize)
        GW.settings.PlayerDebuffs.IconHeight = GW.RoundDec(GW.settings.PlayerDebuffFrame_ICON_SIZE or GW.settings.PlayerDebuffs.IconSize)
        GW.settings.PlayerDebuffs.GrowDirection = GW.settings.PlayerDebuffFrame_GrowDirection or GW.settings.PlayerDebuffs.GrowDirection
        GW.settings.PlayerDebuffs.HorizontalSpacing = GW.settings.PlayerDebuffFrame_HorizontalSpacing or GW.settings.PlayerDebuffs.HorizontalSpacing
        GW.settings.PlayerDebuffs.VerticalSpacing = GW.settings.PlayerDebuffFrame_VerticalSpacing or GW.settings.PlayerDebuffs.VerticalSpacing
        GW.settings.PlayerDebuffs.MaxWraps = GW.settings.PlayerDebuffFrame_MaxWraps or GW.settings.PlayerDebuffs.MaxWraps
        GW.settings.PlayerDebuffs.WrapAfter = GW.settings.PLAYER_AURA_WRAP_NUM_DEBUFF or GW.settings.PlayerDebuffs.WrapAfter
        GW.settings.PlayerDebuffs.NewAuraAnimation = GW.settings.PLAYER_AURA_ANIMATION or GW.settings.PlayerDebuffs.NewAuraAnimation

        GW.settings.PlayerDebuffFrame_Seperate = nil
        GW.settings.PlayerDebuffFrame_SortDir = nil
        GW.settings.PlayerDebuffFrame_SortMethod = nil
        GW.settings.PlayerDebuffFrame_ICON_SIZE = nil
        GW.settings.PlayerDebuffFrame_GrowDirection = nil
        GW.settings.PlayerDebuffFrame_HorizontalSpacing = nil
        GW.settings.PlayerDebuffFrame_VerticalSpacing = nil
        GW.settings.PLAYER_AURA_WRAP_NUM_DEBUFF = nil
        GW.settings.PlayerDebuffFrame_MaxWraps = nil
    end


    --Midnight migration
    if GW.Retail then
        GW.settings.target_BUFFS_FILTER_IMPORTANT = false
        GW.settings.focus_BUFFS_FILTER_IMPORTANT = false
    end
end
GW.DatabaseValueMigration = DatabaseValueMigration

local function Migration()
    -- migration for frame positions
    if not GW.settings.updateFramePositionMigrationDone then
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
        GW.settings.updateFramePositionMigrationDone = true
    end
end
GW.Migration = Migration