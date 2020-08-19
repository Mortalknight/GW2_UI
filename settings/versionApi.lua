local _, GW = ...
local _,_, _, version = GetBuildInfo()
GW.api = {}

local function GetAverageItemLevel()
    if version>40000 then
        return _G.GetAverageItemLevel()
    end
    return nil,nil
end
GW.api.GetAverageItemLevel = GetAverageItemLevel

local function GetItemLevelColor()
    if version>40000 then
        return _G.GetItemLevelColor()
    end
    return 0,0,0
end
GW.api.GetItemLevelColor = GetItemLevelColor


local function GetNumSpecializations()
    if version>50000 then
        return _G.GetNumSpecializations()
    end
    return _G.GetNumTalentTabs()
end
GW.api.GetNumSpecializations = GetNumSpecializations

local function GetSpecialization()
    if version>50000 then
        return _G.GetSpecialization()
    end
    if version>30000 then
        return _G.GetPrimaryTalentTree()
    end

    return 0
end
GW.api.GetSpecialization = GetSpecialization

local function GetSpecializationInfo(specIndex,isInspect,isPet,inspectTarget,sex )
    if version>50000 then
        return _G.GetSpecializationInfo(specIndex,isInspect,isPet,inspectTarget,sex)
    end
    local name, iconTexture, pointsSpent, background = GetTalentTabInfo(specIndex);
    return specIndex, name, nil, iconTexture, background, nil, nil
end
GW.api.GetSpecializationInfo = GetSpecializationInfo
local function GetSpecializationRole()
    if version>50000 then
        return _G.GetSpecializationRole()
    end
    return nil
end
GW.api.GetSpecializationRole = GetSpecializationRole

local function GetFriendshipReputation()
    if version>50000 then
        return _G.GetFriendshipReputation()
    end
    return nil
end
GW.api.GetFriendshipReputation = GetFriendshipReputation
