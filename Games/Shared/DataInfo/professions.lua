---@class GW2
local GW = select(2, ...)

local ICON_STRING = "|T%s:14:14:0:0:64:64:4:60:4:60|t "

local function CollectProfessions()
    local list = {}

    if GetProfessions and GetProfessionInfo then
        for _, index in ipairs({GetProfessions()}) do
            local name, icon, skillLevel, maxSkillLevel = GetProfessionInfo(index)
            if name then
                tinsert(list, {name = name, icon = icon, skill = skillLevel, max = maxSkillLevel})
            end
        end
        return list
    end

    if GetNumSkillLines and GetSkillLineInfo then
        -- skills sit below collapsible headers, only the professions and secondary skills headers matter
        local wanted = false
        for i = 1, GetNumSkillLines() do
            local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
            if isHeader then
                wanted = name == TRADE_SKILLS or name == SECONDARY_SKILLS
            elseif wanted and name then
                tinsert(list, {name = name, skill = rank, max = maxRank})
            end
        end
    end

    return list
end

local function Professions_OnEnter(self)
    local list = CollectProfessions()
    if #list == 0 or not GW.EnsureMicroMenuTooltip(self) then return end

    GameTooltip:AddLine(" ")
    for _, prof in ipairs(list) do
        local label = (prof.icon and format(ICON_STRING, prof.icon) or "") .. prof.name
        GameTooltip:AddDoubleLine(label, GW.FormatProgressFraction(prof.skill or 0, prof.max or 0), 1, 1, 1)
    end
    GameTooltip:Show()
end
GW.Professions_OnEnter = Professions_OnEnter
