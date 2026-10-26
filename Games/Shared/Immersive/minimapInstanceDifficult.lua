---@class GW2
local GW = select(2, ...)

local difficulty = MinimapCluster.InstanceDifficulty
local instance = difficulty and difficulty.Default or MiniMapInstanceDifficulty
local guild = difficulty and difficulty.Guild or GuildInstanceDifficulty
local challenge = difficulty and difficulty.ChallengeMode or MiniMapChallengeMode

local difficulties = {
    [1] = "normal",   -- 5ppl normal
    [2] = "heroic",   -- 5ppl heroic
    [3] = "normal",   -- 10ppl raid
    [4] = "normal",   -- 25ppl raid
    [5] = "heroic",   -- 10ppl heroic raid
    [6] = "heroic",   -- 25ppl heroic raid
    [7] = "lfr",      -- 25ppl LFR
    [8] = "challenge",-- 5ppl challenge
    [9] = "normal",   -- 40ppl raid
    [11] = "heroic",  -- Heroic scenario
    [12] = "normal",  -- Normal scenario
    [14] = "normal",  -- 10-30ppl normal
    [15] = "heroic",  -- 13-30ppl heroic
    [16] = "mythic",  -- 20ppl mythic
    [17] = "lfr",     -- 10-30 LFR
    [23] = "mythic",  -- 5ppl mythic
    [24] = "time",    -- Timewalking
}

local sizeOnly = {[3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [9] = true}

local function GuildEmblem()
    if not (guild and guild.Emblem and IsInGuild()) then
        return ""
    end
    local left, top, _, _, _, _, right, bottom = guild.Emblem:GetTexCoord()
    return ("|TInterface/GuildFrame/GuildEmblems_01:16:16:0:0:32:32:%d:%d:%d:%d|t"):format(left * 32, right * 32, top * 32, bottom * 32)
end

local function Update(self)
    self.text:SetText("")
    self.icon:SetText("")

    local isInstance, instanceType = IsInInstance()
    if not isInstance or instanceType == "pvp" or instanceType == "arena" then
        return
    end

    local _, _, diff, difficultyName, _, _, _, _, instanceGroupSize = GetInstanceInfo()
    local color = GW.Colors.InstanceDifficultyColors[difficulties[diff]] or GW.Colors.FallbackWhite
    if sizeOnly[diff] then
        self.text:SetText(color:WrapTextInColorCode(instanceGroupSize))
    else
        self.text:SetText(instanceGroupSize .. " " .. color:WrapTextInColorCode(difficultyName and string.utf8sub(difficultyName, 1, 1) or ""))
    end

    if self.inGuildGroup and not select(4, GetDifficultyInfo(diff)) then
        self.icon:SetText(GuildEmblem())
    end
end

local function OnEvent(self, event, ...)
    if event == "GUILD_PARTY_STATE_UPDATED" then
        self.inGuildGroup = ...
    end
    Update(self)
end

local function HideBlizzardIcon(self)
    self:Hide()
end

function GW.SkinMinimapInstanceDifficult()
    local d = CreateFrame("Frame", "GW_MinimapInstanceDifficultFrame", Minimap)

    d:SetFrameStrata("MEDIUM")
    d:SetSize(50, 20)
    d:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 0)
    d.text = d:CreateFontString(nil, "OVERLAY")
    d.text:SetPoint("LEFT", d, "LEFT", 20, 0)
    d.icon = d:CreateFontString(nil, "OVERLAY")
    d.icon:SetPoint("LEFT", d.text, "RIGHT", 4, 0)

    d.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    d.icon:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")

    -- the instance info is often not there yet at the loading screen, the last three events bring it
    for _, event in ipairs({"LOADING_SCREEN_DISABLED", "GROUP_ROSTER_UPDATE", "GUILD_PARTY_STATE_UPDATED", "PLAYER_DIFFICULTY_CHANGED", "INSTANCE_GROUP_SIZE_CHANGED", "UPDATE_INSTANCE_INFO"}) do
        if C_EventUtils.IsEventValid(event) then
            d:RegisterEvent(event)
        end
    end
    d:SetScript("OnEvent", OnEvent)

    for _, frame in pairs({instance, guild, challenge}) do
        frame:HookScript("OnShow", HideBlizzardIcon)
        frame:Hide()
    end

    if MinimapCluster.InstanceDifficulty then
        hooksecurefunc(MinimapCluster.InstanceDifficulty, "Update", function() Update(d) end)
    end
end
