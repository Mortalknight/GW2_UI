local _, GW = ...

local difficulty = MinimapCluster.InstanceDifficulty
local instance = difficulty.Instance
local guild = difficulty.Guild
local challenge = difficulty.ChallengeMode

local difficulties = {
    [1] = "normal", --5ppl normal
    [2] = "heroic", --5ppl heroic
    [3] = "normal", --10ppl raid
    [4] = "normal", --25ppl raid
    [5] = "heroic", --10ppl heroic raid
    [6] = "heroic", --25ppl heroic raid
    [7] = "lfr", --25ppl LFR
    [8] = "challenge", --5ppl challenge
    [9] = "normal", --40ppl raid
    [11] = "heroic", --Heroic scenario
    [12] = "normal", --Normal scenario
    [14] = "normal", --10-30ppl normal
    [15] = "heroic", --13-30ppl heroic
    [16] = "mythic", --20ppl mythic
    [17] = "lfr", --10-30 LFR
    [23] = "mythic", --5ppl mythic
    [24] = "time", --Timewalking
}

local colors = {
    ["lfr"] = {r = 0.32, g = 0.91, b = 0.25}, -- green
    ["normal"] = {r = 0.09, g = 0.51, b = 0.82}, --blue
    ["heroic"] = {r = 0.67, g = 0.15, b = 0.94}, --purple
    ["challenge"] = {r = 0.9, g = 0.89, b = 0.27}, -- yellow/gold
    ["mythic"] = {r = 0.82, g = 0.42, b = 0.16}, -- orange
    ["time"] = {r = 0.41, g = 0.80, b = 0.94} -- light blue
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
    local char = {}
    if guild then
        char.guildTexCoord = {guild.Emblem:GetTexCoord()}
    else
        char.guildTexCoord = false
    end
    if char.guildTexCoord and IsInGuild() then
        return "|TInterface\\GuildFrame\\GuildEmblemsLG_01:24:24:-4:1:32:32:" .. (char.guildTexCoord[1] * 32) .. ":" .. (char.guildTexCoord[7] * 32) .. ":" .. (char.guildTexCoord[2] * 32) .. ":" .. (char.guildTexCoord[8] * 32) .. "|t"
    else
        return ""
    end
end

local function InstanceDifficultOnEvent(self)
    self.icon:SetText("")

    if not InstanceCheck() then
        self.text:SetText("")
    else
        local text
        local difficulty, difficultyName, _, _, _, _, instanceGroupSize = select(3, GetInstanceInfo())
        local isChallengeMode = select(4, GetDifficultyInfo(difficulty))
        local r, g, b = GetColor(difficulty)

        if (difficulty >= 3 and difficulty <= 7) or difficulty == 9 then
            text = format("|cff%02x%02x%02x%s|r", r, g, b, instanceGroupSize)
        else
            difficultyName = string.sub(difficultyName, 1 , 1)
            text = format(instanceGroupSize .. " |cff%02x%02x%02x%s|r", r, g, b, difficultyName)
        end

        self.text:SetText(text)
        if guild and not isChallengeMode then
            self.icon:SetText(GuildEmblem())
        end
        instance:Hide()
        challenge:Hide()
        guild:Hide()
    end
end

local function SkinMinimapInstanceDifficult()
    local d = CreateFrame("Frame", "GW_MinimapInstanceDifficultFrame", Minimap)

    d:SetSize(50, 20)
    d:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 0)
    d.text = d:CreateFontString(nil, "OVERLAY")
    d.text:SetPoint("CENTER", d, "CENTER")
    d.icon = d:CreateFontString(nil, "OVERLAY")
    d.icon:SetPoint("LEFT", d.text, "RIGHT", 4, 0)

    d.text:SetFont(UNIT_NAME_FONT, 12, "OUTLINE")
    d.icon:SetFont(UNIT_NAME_FONT, 12, "OUTLINE")

    d:RegisterEvent("LOADING_SCREEN_DISABLED")
    d:RegisterEvent("GROUP_ROSTER_UPDATE")
    d:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
    d:SetScript("OnEvent", InstanceDifficultOnEvent)

    instance:HookScript("OnShow", function(frame) frame:Hide() end)
    guild:HookScript("OnShow", function(frame) frame:Hide() end)
    challenge:HookScript("OnShow", function(frame) frame:Hide() end)

    hooksecurefunc(MinimapCluster.InstanceDifficulty, "Update", function() InstanceDifficultOnEvent(d) end)
end
GW.SkinMinimapInstanceDifficult = SkinMinimapInstanceDifficult
