---@class GW2
local GW = select(2, ...)

local function IsPreview()
    return GetCVarBool("previewTalentsOption")
end

local function GetTalentInfo(tree, index, isPet, group)
    return C_SpecializationInfo.GetTalentInfo({
        specializationIndex = tree,
        talentIndex = index,
        isInspect = false,
        isPet = isPet,
        groupIndex = group,
    })
end

GW.TalentData = {
    NumTiers = GW.Wrath and 11 or 9,
    HasPreviewOption = true,
    Events = {
        "PLAYER_TALENT_UPDATE",
        "PET_TALENT_UPDATE",
        "ACTIVE_TALENT_GROUP_CHANGED",
        "TALENT_GROUP_ROLE_CHANGED",
        "PREVIEW_TALENT_POINTS_CHANGED",
        "PREVIEW_PET_TALENT_POINTS_CHANGED",
        "CHARACTER_POINTS_CHANGED",
        "SPELLS_CHANGED",
    },

    UsesPreview = IsPreview,
    GetNumTrees = function(isPet) return GetNumTalentTabs(false, isPet) end,
    GetNumTalents = function(tree, isPet) return GetNumTalents(tree, false, isPet) end,
    GetNumSpecGroups = function(isPet) return GetNumTalentGroups(false, isPet) end,
    GetActiveSpecGroup = function(isPet) return C_SpecializationInfo.GetActiveSpecGroup(false, isPet) end,
    GetUnspentPoints = function(isPet, group) return GetUnspentTalentPoints(false, isPet, group) end,
    GetPreviewPoints = function(isPet, group) return GetGroupPreviewTalentPointsSpent(isPet, group) end,
    ResetPreview = function(isPet, group) ResetGroupPreviewTalentPoints(isPet, group) end,
    CommitPreview = function(isPet) LearnPreviewTalents(isPet) end,

    -- name, icon, points to show, points that unlock the tiers
    GetTreeInfo = function(tree, isPet, group)
        local _, name, _, icon, _, _, pointsSpent, _, previewPointsSpent = C_SpecializationInfo.GetSpecializationInfo(tree, false, isPet, nil, nil, group)
        return name, icon, pointsSpent, pointsSpent + previewPointsSpent
    end,

    GetTalent = function(tree, index, isPet, group, treePoints)
        local info = GetTalentInfo(tree, index, isPet, group)
        if not info then return end

        local preview = IsPreview()
        local prereqs = {}
        local reqs = {GetTalentPrereqs(tree, index, false, isPet, group)}
        for i = 1, #reqs, 4 do
            prereqs[#prereqs + 1] = {tier = reqs[i], column = reqs[i + 1], met = (preview and reqs[i + 3]) or (not preview and reqs[i + 2])}
        end

        local tierUnlocked = (info.tier - 1) * (isPet and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER) <= treePoints
        return {
            tier = info.tier,
            column = info.column,
            rank = preview and info.previewRank or info.rank,
            maxRank = info.maxRank,
            icon = info.icon,
            spellID = info.spellID,
            isExceptional = info.isExceptional,
            available = tierUnlocked and ((preview and info.meetsPreviewPrereq) or (not preview and info.meetsPrereq)),
            prereqs = prereqs,
        }
    end,

    Learn = function(tree, index, isPet, group)
        if IsPreview() then
            AddPreviewTalentPoints(tree, index, 1, isPet, group)
        else
            LearnTalent(tree, index, isPet, group)
        end
    end,

    Unlearn = function(tree, index, isPet, group)
        if IsPreview() then
            AddPreviewTalentPoints(tree, index, -1, isPet, group)
        end
    end,

    GetLink = function(tree, index, isPet, group)
        return GetTalentLink(tree, index, false, isPet, group, IsPreview())
    end,

    SetTooltip = function(tree, index, isPet, group)
        local info = GetTalentInfo(tree, index, isPet, group)
        if info then
            GameTooltip:SetTalent(info.talentID, false, isPet, group)
            return true
        end
    end,
}
