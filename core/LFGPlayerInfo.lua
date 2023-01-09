local _, GW = ...
local L = GW.L

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

local classFileToID = {} -- { ["WARRIOR"] = 1 }
local localizedSpecNameToID = {} -- { ["Protection"] = 73 }
local localizedSpecNameToIcon = {} -- { ["Protection"] = "Interface\\Icons\\ability_warrior_defensivestance" }

for classID = 1, 13 do
    -- Scan all specs and specilizations, 13 is Evoker
    local classFile = select(2, GetClassInfo(classID)) -- "WARRIOR"

    if classFile then
        classFileToID[classFile] = classID

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

local function Clear()
    for _, role in ipairs(roleOrder) do
        GW.LFGPI.cache[role] = {
            totalAmount = 0,
            playerList = {}
        }
    end
end
GW.LFGPI.cache.Clear = Clear

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
GW.LFGPI.cache.AddPlayer = AddPlayer

-- Main logic
local function Update(resultID)
    local result = C_LFGList.GetSearchResultInfo(resultID)

    if not result then
        GW.Debug("debug", "cache not updated correctly, the number of results is nil.")
    end

    if not result.numMembers or result.numMembers == 0 then
        GW.Debug("debug", "cache not updated correctly, the number of result.numMembers is nil or 0.")
    end

    GW.LFGPI.cache.Clear()

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

        GW.LFGPI.cache.AddPlayer(role, class, spec)
    end
end
GW.LFGPI.Update = Update

local function Conduct(template, class, spec, amount)
    -- This function allow you do a very simple template rendering.
    -- The syntax like a mix of React and Vue.
    -- The field between `{{` and `}}` should NOT have any space.
    -- The {{tagStart}} and {{tagEnd}} is a tag pair like HTML tag, but it has been designed for matching latest close tag.
    -- [Sample]
    -- {{classIcon:14}}{{specIcon:14,18}} {{classColorStart}}{{className}}{{classColorEnd}}{{amountStart}} x {{amount}}{{amountEnd}}

    local result = template

    -- {{classIcon}}
    result =
        gsub(
        result,
        "{{classIcon:([0-9,]-)}}",
        function(sub)
            if not class then
                GW.GetIconString("warning", "className not found, class is not given.")
                return ""
            end

            local size = {strsplit(",", sub)}
            local height = size[1] and size[1] ~= "" and tonumber(size[1]) or 14
            local width = size[2] and size[2] ~= "" and tonumber(size[2]) or height

            return GW.GetClassIconStringWithStyle(class, width, height)
        end
    )

    -- {{className}}
    result =
        gsub(
        result,
        "{{className}}",
        function(sub)
            if not class then
                GW.GetIconString("warning", "className not found, class is not given.")
                return ""
            end

            return LOCALIZED_CLASS_NAMES_MALE[class]
        end
    )

    -- {{classId}}
    result =
        gsub(
        result,
        "{{classId}}",
        function(sub)
            if not class then
                GW.GetIconString("warning", "classId not found, class is not given.")
                return ""
            end

            local classID = classFileToID[class]

            return classID or ""
        end
    )

    -- {{specIcon}}
    result =
        gsub(
        result,
        "{{specIcon:([0-9,]-)}}",
        function(sub)
            if not spec then
                GW.GetIconString("warning", "specIcon not found, spec is not given.")
                return ""
            end

            if spec == "Initial" then
                return ""
            end

            local icon = localizedSpecNameToIcon[class] and localizedSpecNameToIcon[class][spec]

            local size = {strsplit(",", sub)}
            local height = size[1] and size[1] ~= "" and tonumber(size[1]) or 14
            local width = size[2] and size[2] ~= "" and tonumber(size[2]) or height

            return icon and GW.GetIconString(icon, height, width, true) or ""
        end
    )

    -- {{specName}}
    result =
        gsub(
        result,
        "{{specName}}",
        function(sub)
            if not spec then
                GW.Debug("warning", "specName not found, spec is not given.")
                return ""
            end

            return spec
        end
    )

    -- {{specId}}
    result =
        gsub(
        result,
        "{{specId}}",
        function(sub)
            if not class then
                GW.Debug("warning", "specId not found, spec is not given.")
                return ""
            end

            local specID = localizedSpecNameToID[class] and localizedSpecNameToID[class][spec]

            return specID or ""
        end
    )

    -- {{classColorStart}} ... {{classColorEnd}}
    result =
        gsub(
        result,
        "{{classColorStart}}(.-){{classColorEnd}}",
        function(sub)
            if not class then
                GW.Debug("warning", "className not found, class is not given.")
                return ""
            end
            local color = GW.GWGetClassColor(class, true, true)
            return  format("|c%s%s|r", color.colorStr, sub)
        end
    )

    -- {{amountStart}} ... {{amountEnd}}
    result =
        gsub(
        result,
        "{{amountStart}}(.-){{amountEnd}}",
        function(sub)
            if amount <= 1 then -- should not show amount if the amount is only one
                return ""
            else
                -- {{amount}}
                if not amount then
                    GW.Debug("warning", "amount not found, amount is not given.")
                    return ""
                end
                return gsub(sub, "{{amount}}", tostring(amount))
            end
        end
    )

    -- {{amount}}
    result =
        gsub(
        result,
        "{{amount}}",
        function()
            if not amount then
                GW.Debug("warning", "amount not found, amount is not given.")
                return ""
            end
            return tostring(amount)
        end
    )

    -- {{classColorStart}} ... {{classColorEnd}}
    result =
        gsub(
        result,
        "{{classColorStart}}(.-){{classColorEnd}}",
        function(sub)
            if not class then
                GW.Debug("warning", "className not found, class is not given.")
                return ""
            end
            local color = GW.GWGetClassColor(class, true, true)
            return  format("|c%s%s|r", color.colorStr, sub)
        end
    )

    return result
end
GW.LFGPI.Conduct = Conduct

local function GetPartyInfo(template)
    if not template then
        GW.Debug("warning", "template is nil.")
        return
    end

    local dataTable = {}

    for _, role in ipairs(roleOrder) do
        dataTable[role] = {}

        local members = GW.LFGPI.cache[role]

        for class, numberOfPlayersSortBySpec in pairs(members.playerList) do
            for spec, numberOfPlayers in pairs(numberOfPlayersSortBySpec) do
                local result = GW.LFGPI.Conduct(template, class, spec, numberOfPlayers)
                tinsert(dataTable[role], result)
            end
        end
    end

    return dataTable
end
GW.LFGPI.GetPartyInfo = GetPartyInfo
