---@class GW2
local GW = select(2, ...)
local L = GW.L

local RATED_BRACKETS = {
    {index = 1, label = function() return ARENA_2V2 end},
    {index = 2, label = function() return ARENA_3V3 end},
    {index = 3, label = function() return ARENA_5V5 end},
    {index = 4, label = function() return BATTLEGROUND_10V10 end},
    {index = 7, label = function() return PVP_RATED_SOLO_SHUFFLE end},
    {index = 9, label = function() return PVP_RATED_BG_BLITZ end},
}

-- appends the rated brackets with a rating or games this season; beforeFirst runs before the first line
-- (spacer or section header of the caller), returns true when something was added
local function AddRatedPvpLines(beforeFirst)
    if not GetPersonalRatedInfo then return false end

    local added = false
    for _, bracket in ipairs(RATED_BRACKETS) do
        local label = bracket.label()
        if label then
            local rating, seasonBest, _, seasonPlayed = GetPersonalRatedInfo(bracket.index)
            rating, seasonBest, seasonPlayed = rating or 0, seasonBest or 0, seasonPlayed or 0
            if rating > 0 or seasonPlayed > 0 then
                if not added then
                    if beforeFirst then
                        beforeFirst()
                    end
                    added = true
                end
                local right = tostring(rating)
                if seasonBest > rating then
                    right = format("%s |cffaaaaaa(%s %d)|r", right, L["Best"], seasonBest)
                end
                GameTooltip:AddDoubleLine(label, right, 0.8, 0.8, 0.8, 1, 1, 1)
            end
        end
    end
    return added
end
GW.AddRatedPvpTooltipLines = AddRatedPvpLines

-- pvp micro button on the classic clients
local function Pvp_OnEnter(self)
    if not GetPersonalRatedInfo or not GW.EnsureMicroMenuTooltip(self) then return end
    AddRatedPvpLines(function() GameTooltip:AddLine(" ") end)
    GameTooltip:Show()
end
GW.Pvp_OnEnter = Pvp_OnEnter
