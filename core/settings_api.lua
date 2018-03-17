GW2UI_SETTINGS = {}

function gwGetActiveProfile()
    if GW2UI_SETTINGS_DB_03==nil then
        GW2UI_SETTINGS_DB_03 = {}
    end
    return GW2UI_SETTINGS_DB_03['ACTIVE_PROFILE']
end

function gwSetProfileSettings()
    
    local profileIndex = gwGetActiveProfile()
    
    if profileIndex==nil then return end
    if GW2UI_SETTINGS_PROFILES[profileIndex]==nil then return end
    
    
    
    for k,v in pairs(GW2UI_SETTINGS_DB_03) do
        GW2UI_SETTINGS_PROFILES[profileIndex][k] = v
    end
    
end

function gwGetSetting(name)
    
    local profileIndex = gwGetActiveProfile()
    
    if GW2UI_SETTINGS_PROFILES==nil then
        GW2UI_SETTINGS_PROFILES = {}
    end
    
    if profileIndex~=nil and GW2UI_SETTINGS_PROFILES[profileIndex]~=nil then
        if GW2UI_SETTINGS_PROFILES[profileIndex][name]==nil then
            GW2UI_SETTINGS_PROFILES[profileIndex][name] = gwGetDefault(name)
        end
        return GW2UI_SETTINGS_PROFILES[profileIndex][name]
    end
    
    
    if GW2UI_SETTINGS_DB_03==nil then
        GW2UI_SETTINGS_DB_03 = GW_DEFAULT
    end
    if GW2UI_SETTINGS_DB_03[name]==nil then
        GW2UI_SETTINGS_DB_03[name] = gwGetDefault(name)
    end
    
    return GW2UI_SETTINGS_DB_03[name]
end

function gwSetSetting(name,state)
    
    local profileIndex = gwGetActiveProfile()
    
    if profileIndex~=nil and GW2UI_SETTINGS_PROFILES[profileIndex]~=nil then
        
        GW2UI_SETTINGS_PROFILES[profileIndex][name] = state
        GW2UI_SETTINGS_PROFILES[profileIndex]['profileLastUpdated'] = date("%m/%d/%y %H:%M:%S")
        return
        
    end
    
    GW2UI_SETTINGS_DB_03[name] = state
end

function gwGetDefault(name)
    return GW_DEFAULT[name]
end
function gwResetToDefault()
    
    local profileIndex = gwGetActiveProfile()
    
    if profileIndex~=nil and GW2UI_SETTINGS_PROFILES[profileIndex]~=nil then
        for k,v in pairs(GW_DEFAULT) do
            GW2UI_SETTINGS_PROFILES[profileIndex][k] = v
        end
        GW2UI_SETTINGS_PROFILES[profileIndex]['profileLastUpdated'] = date("%m/%d/%y %H:%M:%S")
        return
        
    end
    GW2UI_SETTINGS_DB_03 = GW_DEFAULT
end

function gwGetSettingsProfiles()
    
    if GW2UI_SETTINGS_PROFILES==nil then
        GW2UI_SETTINGS_PROFILES = {}
    end
    return GW2UI_SETTINGS_PROFILES;

end
