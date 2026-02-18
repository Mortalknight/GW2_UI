local _, GW = ...

-- Thanks to Windtools
GW.LFGPI = {}
-- Variables
local roleOrder = {
    [1] = "TANK",
    [2] = "HEALER",
    [3] = "DAMAGER"
}
local cache = {}
local LFG_LIST_GROUP_DATA_ATLASES_BORDERLESS = {
	TANK = "groupfinder-icon-role-micro-tank",
	HEALER = "groupfinder-icon-role-micro-heal",
	DAMAGER = "groupfinder-icon-role-micro-dps",
}

local function GetRoleOrder()
    return roleOrder
end
GW.LFGPI.GetRoleOrder = GetRoleOrder

local localizedSpecNameToID = {} -- { ["Protection"] = 73 }
local localizedSpecNameToIcon = {} -- { ["Protection"] = "Interface\\Icons\\ability_warrior_defensivestance" }

for classID = 1, 13 do
    -- Scan all specs and specilizations, 13 is Evoker
    local classFile = select(2, GetClassInfo(classID)) -- "WARRIOR"

    if classFile then
        if not localizedSpecNameToID[classFile] then
            localizedSpecNameToID[classFile] = {}
        end

        if not localizedSpecNameToIcon[classFile] then
            localizedSpecNameToIcon[classFile] = {}
        end

        for specIndex = 1, 4 do
            -- Druid has the max amount of specs, which is 4
            local specId, localizedSpecName, _, icon = GetSpecializationInfoForClassID(classID, specIndex)
            if specId and localizedSpecName and icon then
                localizedSpecNameToID[classFile][localizedSpecName] = specId
                localizedSpecNameToIcon[classFile][localizedSpecName] = icon
            end
        end
    end
end

local function ClearCache()
    for _, role in ipairs(roleOrder) do
        cache[role] = {
            totalAmount = 0,
            playerList = {}
        }
    end
end

local function AddPlayer(role, class, spec)
    if not cache[role] then
        GW.Debug("warning", format("cache not been initialized correctly, the role:%s is nil.", role))
    end

    if not cache[role].playerList[class] then
        cache[role].playerList[class] = {}
    end

    if not cache[role].playerList[class][spec] then
        cache[role].playerList[class][spec] = 0
    end

    cache[role].playerList[class][spec] = cache[role].playerList[class][spec] + 1
    cache[role].totalAmount = cache[role].totalAmount + 1
end

-- Main logic
local function Update(resultID)
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode);

    if not searchResultInfo then
        GW.Debug("debug", "cache not updated correctly, the number of results is nil.")
    end

    if not searchResultInfo.numMembers or searchResultInfo.numMembers == 0 then
        GW.Debug("debug", "cache not updated correctly, the number of result.numMembers is nil or 0.")
    end

    ClearCache()

    for i = 1, searchResultInfo.numMembers do
        local memberInfo = C_LFGList.GetSearchResultPlayerInfo(resultID, i)
        if memberInfo and memberInfo.assignedRole then
            AddPlayer(memberInfo.assignedRole, memberInfo.classFilename, memberInfo.specName)
        end
    end

    return GW.NotSecretTable(activityInfo) and activityInfo.displayType ~= Enum.LFGListDisplayType.ClassEnumerate and activityInfo.displayType ~= Enum.LFGListDisplayType.RoleEnumerate
end

local function CreateTooltipLine(role, class, spec, amount)
    local color = GW.GWGetClassColor(class, true, true)
    local roleIcon = CreateAtlasMarkup(LFG_LIST_GROUP_DATA_ATLASES_BORDERLESS[role], 13, 13, 0, 0)

    return roleIcon .. " " .. color:WrapTextInColorCode(string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, (LOCALIZED_CLASS_NAMES_MALE[class] or ""), spec)) .. (amount <= 1 and "" or " x " .. tostring(amount))
end

local function GetPartyInfo(resultId)
    local dataTable = {}

    local shouldAdd = Update(resultId)

    if not shouldAdd then return end

    for _, role in ipairs(roleOrder) do
        dataTable[role] = {}

        local members = cache[role]

        for class, numberOfPlayersSortBySpec in pairs(members.playerList) do
            for spec, numberOfPlayers in pairs(numberOfPlayersSortBySpec) do
                tinsert(dataTable[role], CreateTooltipLine(role, class, spec, numberOfPlayers))
            end
        end
    end

    return dataTable
end
GW.LFGPI.GetPartyInfo = GetPartyInfo
