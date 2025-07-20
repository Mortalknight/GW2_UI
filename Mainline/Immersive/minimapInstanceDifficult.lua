local _, GW = ...

local difficulty = MinimapCluster.InstanceDifficulty
local instance = difficulty.Default
local guild = difficulty.Guild
local challenge = difficulty.ChallengeMode

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

local colors = {
    ["lfr"]      = { r = 0.32, g = 0.91, b = 0.25 },  -- grün
    ["normal"]   = { r = 0.09, g = 0.51, b = 0.82 },  -- blau
    ["heroic"]   = { r = 0.67, g = 0.15, b = 0.94 },  -- lila
    ["challenge"]= { r = 0.9,  g = 0.89, b = 0.27 },  -- gelb/gold
    ["mythic"]   = { r = 0.82, g = 0.42, b = 0.16 },  -- orange
    ["time"]     = { r = 0.41, g = 0.80, b = 0.94 }   -- hellblau
}

local function InstanceCheck()
    local isInstance, InstanseType = IsInInstance()
    return isInstance and InstanseType ~= "pvp" and InstanseType ~= "arena"
end

local function GetColor(dif)
    if dif and difficulties[dif] then
        local color = colors[difficulties[dif]]
        return color.r * 255, color.g * 255, color.b * 255
    else
        return 255, 255, 255
    end
end

local function GuildEmblem()
    if guild and IsInGuild() then
        local texCoord = { guild.Emblem:GetTexCoord() }
        return ("|TInterface\\GuildFrame\\GuildEmblems_01:16:16:0:0:32:32:%d:%d:%d:%d|t"):format(
            texCoord[1] * 32, texCoord[7] * 32, texCoord[2] * 32, texCoord[8] * 32
        )
    else
        return ""
    end
end

local function InstanceDifficultOnEvent(self, _, inGuildGroup)
    self.icon:SetText("")

    if not InstanceCheck() then
        self.text:SetText("")
        return
    end

    local _, _, diff, difficultyName, _, _, _, _, instanceGroupSize = GetInstanceInfo()
    local isChallengeMode = select(4, GetDifficultyInfo(diff))
    local r, g, b = GetColor(diff)
    local text


    if (diff >= 3 and diff <= 7) or diff == 9 then
        text = format("|cff%02x%02x%02x%s|r", r, g, b, instanceGroupSize)
    else
        difficultyName = difficultyName and string.sub(difficultyName, 1, 1) or ""
        text = format("%d |cff%02x%02x%02x%s|r", instanceGroupSize, r, g, b, difficultyName)
    end

    self.text:SetText(text)

    if inGuildGroup and not isChallengeMode then
        self.icon:SetText(GuildEmblem())
    end

    instance:Hide()
    challenge:Hide()
    guild:Hide()
end

local function HideBlizzardIcon(self)
    self:Hide()
end

local function SkinMinimapInstanceDifficult()
    local d = CreateFrame("Frame", "GW_MinimapInstanceDifficultFrame", Minimap)

    d:SetFrameLevel(GwMapGradient:GetFrameLevel() + 1)
    d:SetSize(50, 20)
    d:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 0)
    d.text = d:CreateFontString(nil, "OVERLAY")
    d.text:SetPoint("CENTER", d, "CENTER")
    d.icon = d:CreateFontString(nil, "OVERLAY")
    d.icon:SetPoint("LEFT", d.text, "RIGHT", 4, 0)

    d.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    d.icon:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")

    d:RegisterEvent("LOADING_SCREEN_DISABLED")
    d:RegisterEvent("GROUP_ROSTER_UPDATE")
    d:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
    d:SetScript("OnEvent", InstanceDifficultOnEvent)

    instance:HookScript("OnShow", HideBlizzardIcon)
    guild:HookScript("OnShow", HideBlizzardIcon)
    challenge:HookScript("OnShow", HideBlizzardIcon)

    instance:Hide()
    guild:Hide()
    challenge:Hide()

    hooksecurefunc(MinimapCluster.InstanceDifficulty, "Update", function() InstanceDifficultOnEvent(d) end)
end
GW.SkinMinimapInstanceDifficult = SkinMinimapInstanceDifficult
