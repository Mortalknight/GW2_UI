local _, GW = ...
local CI = GW.Libs.CI
GW.api = {}

local function GetAverageItemLevel()
    if GW.tocversion > 40000 then
        return _G.GetAverageItemLevel()
    else
        local _, gearScore = GW.Libs.LibGearScore:GetScore("player")
        return gearScore.GearScore, gearScore.AvgItemLevel
    end
end
GW.api.GetAverageItemLevel = GetAverageItemLevel

local function GetItemLevelColor()
    if GW.tocversion > 40000 then
        return _G.GetItemLevelColor()
    else
        local _, gearScore = GW.Libs.LibGearScore:GetScore("player")
        if gearScore.Color then
            return gearScore.Color.r, gearScore.Color.g, gearScore.Color.b
        else
            return 0, 0, 0
        end
    end
end
GW.api.GetItemLevelColor = GetItemLevelColor


local function GetNumSpecializations(isPet)
    if GW.tocversion > 50000 then
        return _G.GetNumSpecializations()
    end
    return _G.GetNumTalentTabs(false, isPet)
end
GW.api.GetNumSpecializations = GetNumSpecializations

local function GetSpecialization()
    if GW.tocversion > 50000 then
        return _G.GetSpecialization()
    end
    if GW.tocversion > 30000 then
        return CI:GetSpecialization("player") or 1
    end

    return 0
end
GW.api.GetSpecialization = GetSpecialization

local function GetSpecializationInfo(specIndex,isInspect,isPet,inspectTarget,sex )
    if GW.tocversion > 50000 then
        return _G.GetSpecializationInfo(specIndex,isInspect,isPet,inspectTarget,sex)
    end
    local name, iconTexture, pointsSpent, background = GetTalentTabInfo(specIndex);
    return specIndex, name, nil, iconTexture, background, nil, nil
end
GW.api.GetSpecializationInfo = GetSpecializationInfo

local function GetSpecializationRole()
    if GW.tocversion > 50000 then
        return _G.GetSpecializationRole()
    end
    return nil
end
GW.api.GetSpecializationRole = GetSpecializationRole

local function GetFriendshipReputation()
    if GW.tocversion > 50000 then
        return _G.GetFriendshipReputation()
    end
    return nil
end
GW.api.GetFriendshipReputation = GetFriendshipReputation
