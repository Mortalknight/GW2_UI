local _, GW = ...

-- Thanks to Windtools

GW.LFGPI = {}
-- Variables
local roleOrder = {
    [1] = "TANK",
    [2] = "HEALER",
    [3] = "DAMAGER"
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

-- Cache
GW.LFGPI.cache = {}

local function ClearCache()
    for _, role in ipairs(roleOrder) do
        GW.LFGPI.cache[role] = {
            totalAmount = 0,
            playerList = {}
        }
    end
end

local function AddPlayer(role, class, spec)
    if not GW.LFGPI.cache[role] then
        GW.Debug("warning", format("cache not been initialized correctly, the role:%s is nil.", role))
    end

    if not GW.LFGPI.cache[role].playerList[class] then
        GW.LFGPI.cache[role].playerList[class] = {}
    end

    if not GW.LFGPI.cache[role].playerList[class][spec] then
        GW.LFGPI.cache[role].playerList[class][spec] = 0
    end

    GW.LFGPI.cache[role].playerList[class][spec] = GW.LFGPI.cache[role].playerList[class][spec] + 1
    GW.LFGPI.cache[role].totalAmount = GW.LFGPI.cache[role].totalAmount + 1
end

-- Main logic
local function Update(resultID)
    local result = C_LFGList.GetSearchResultInfo(resultID)

    if not result then
        GW.Debug("debug", "cache not updated correctly, the number of results is nil.")
    end

    if not result.numMembers or result.numMembers == 0 then
        GW.Debug("debug", "cache not updated correctly, the number of result.numMembers is nil or 0.")
    end

    ClearCache()

    for i = 1, result.numMembers do
        local role, class, _, spec = C_LFGList.GetSearchResultMemberInfo(resultID, i)

        if not role then
            GW.Debug("debug", "cache not updated correctly, the role is nil.")
            return
        end

        if not class then
            GW.Debug("debug", "cache not updated correctly, the class is nil.")
            return
        end

        if not spec then
            GW.Debug("debug", "cache not updated correctly, the spec is nil.")
            return
        end

        AddPlayer(role, class, spec)
    end
end

local function CreateTooltipLine(role, class, spec, amount)
    local specIcon = localizedSpecNameToIcon[class] and localizedSpecNameToIcon[class][spec]
    local color = GW.GWGetClassColor(class, true, true)

    return format("|T%s:16:16:0:0:64:64:4:60:4:60|t", GW.nameRoleIconPure[role]) .. GW.GetClassIconStringWithStyle(class, 14, 14) .. " " .. (specIcon and GW.GetIconString(specIcon, 14, 14, true) or "") ..
    format(" |c%s", color.colorStr) .. LOCALIZED_CLASS_NAMES_MALE[class] .. " (" .. spec .. ")|r" .. (amount <= 1 and "" or " x " .. tostring(amount))
end

local function GetPartyInfo(resultId)
    local dataTable = {}

    Update(resultId)

    for _, role in ipairs(roleOrder) do
        dataTable[role] = {}

        local members = GW.LFGPI.cache[role]

        for class, numberOfPlayersSortBySpec in pairs(members.playerList) do
            for spec, numberOfPlayers in pairs(numberOfPlayersSortBySpec) do
                tinsert(dataTable[role], CreateTooltipLine(role, class, spec, numberOfPlayers))
            end
        end
    end

    return dataTable
end
GW.LFGPI.GetPartyInfo = GetPartyInfo
