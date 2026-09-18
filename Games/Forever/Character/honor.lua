---@class GW2
local GW = select(2, ...)

local PVP_RANK_POINTS_FACTION_ID = 2800
local ROW_WIDTH = 580

local durationFormatter = CreateFromMixins(SecondsFormatterMixin)
durationFormatter:Init(SecondsFormatterConstants.ZeroApproximationThreshold, SecondsFormatter.Abbreviation.None, SecondsFormatterConstants.DontRoundUpLastUnit, SecondsFormatterConstants.DontConvertToLower)
durationFormatter:SetDesiredUnitCount(2)

local function IsHorde()
    return UnitFactionGroup("player") == PLAYER_FACTION_GROUP[PLAYER_FACTION_GROUP.Horde]
end

local function GetRankText(rank)
    if not rank or rank <= 0 then
        return PVP_RANK_0_NAME
    end
    local faction01 = IsHorde() and 0 or 1
    return GetText("PVP_RANK_" .. tostring(Enum.PvPRanks.Rank_1 + rank - 1) .. "_" .. tostring(faction01), UnitSex("player"))
end

local function SetRankBadge(texture, rank)
    if not rank or rank == 0 then
        texture:SetAtlas(IsHorde() and "UI-Character-Info-Honor-Icon-Horde" or "UI-Character-Info-Honor-Icon-Alliance")
    else
        texture:SetAtlas(("UI-Character-Info-Honor-Icon-%d"):format(rank))
    end
end

---------- rows ----------

local function CreateRow(panel, index, previous)
    local row = CreateFrame("Frame", "GwPaperHonorDetails" .. index, panel, "GwHonorInfoRow")
    row:SetWidth(ROW_WIDTH)
    if previous then
        row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -10)
    else
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -15)
    end

    GW.AddDetailsBackground(row)
    row.Header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    row.Header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    row.Rank:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    row.Rank:SetTextColor(1, 1, 1)
    row.icon:SetSize(32, 32)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 12, -10)
    row.Header:ClearAllPoints()
    row.Header:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
    row.progressBar:ClearAllPoints()
    row.progressBar:SetPoint("TOPLEFT", row, "TOPLEFT", 16, -56)
    row.progressBar:SetSize(ROW_WIDTH - 36, 20)
    row.progressBar.border:Hide()
    row.progressBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    row.progressBar:SetStatusBarColor(GW.Colors.FactionBarColors[4]:GetRGB())
    GW.AddStatusBarFrame(row.progressBar)

    row.barText = row.progressBar:CreateFontString(nil, "OVERLAY")
    row.barText:SetAllPoints(row.progressBar)
    row.barText:SetJustifyH("CENTER")
    row.barText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

    row.Text = row:CreateFontString(nil, "OVERLAY")
    row.Text:SetWidth(ROW_WIDTH - 32)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetJustifyV("TOP")
    row.Text:SetWordWrap(true)
    row.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    row.Text:SetTextColor(1, 1, 1)
    row.Text:SetPoint("TOPLEFT", row, "TOPLEFT", 16, -56)

    row.lines = {}
    return row
end

local function AcquireLine(row, index)
    local line = row.lines[index]
    if not line then
        line = CreateFrame("Frame", nil, row)
        line:SetSize(ROW_WIDTH - 32, 36)
        line.icon = line:CreateTexture(nil, "ARTWORK")
        line.icon:SetSize(32, 32)
        line.icon:SetPoint("LEFT")
        GW.HandleIcon(line.icon)
        line.text = line:CreateFontString(nil, "OVERLAY")
        line.text:SetPoint("LEFT", line.icon, "RIGHT", 8, 0)
        line.text:SetPoint("RIGHT")
        line.text:SetJustifyH("LEFT")
        line.text:SetWordWrap(true)
        line.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        line.text:SetTextColor(1, 1, 1)
        row.lines[index] = line
    end
    line:Show()
    return line
end

local function HideLines(row, fromIndex)
    for i = fromIndex, #row.lines do
        row.lines[i]:Hide()
    end
end

local function SetRowText(row, text)
    row.Text:SetText(text or "")
    row.Text:SetShown(text ~= nil)
end

local function LayoutRow(row, contentHeight)
    row:SetHeight(56 + contentHeight + 14)
end

---------- data ----------

local function UpdateRankRow(row, info)
    local rank = info.renownLevel or 0
    SetRankBadge(row.icon, rank)
    row.Header:SetText(GetRankText(rank))
    row.Rank:SetText(rank > 0 and PVP_RANK_NUMBER:format(rank) or "")

    row.progressBar:Show()
    row.progressBar:SetMinMaxValues(0, math.max(info.renownLevelThreshold or 0, 1))
    row.progressBar:SetValue(info.renownReputationEarned or 0)
    row.barText:SetText(PVP_RANK_CURRENT_PROGRESS:format(info.renownReputationEarned or 0, info.renownLevelThreshold or 0))
    SetRowText(row, nil)
    LayoutRow(row, 30)
end

local function UpdateSeasonTimer(row)
    local duration = C_SeasonInfo.GetTimeUntilCurrentPVPSeasonEnd()
    if duration > SECONDS_PER_DAY then
        durationFormatter:SetMinInterval(SecondsFormatter.Interval.Days)
    else
        durationFormatter:SetMinInterval(SecondsFormatter.Interval.Seconds)
    end
    row.Rank:SetText(duration > 0 and SEASON_ENDS_IN_TIME:format(durationFormatter:Format(duration)) or "")
end

local function UpdateSeasonRow(row, info)
    local factionID = PVP_RANK_POINTS_FACTION_ID
    local season = GetCurrentArenaSeason()
    row.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/tabicon-pvp.png")
    row.icon:SetTexCoord(0, 0.5, 0, 0.625)
    row.Header:SetText(season > 0 and EXPANSION_SEASON_NAME:format("", season) or PVP)
    UpdateSeasonTimer(row)

    local rank = info.renownLevel or 0
    local repForWeekCap = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, info.currentWeekProgressiveMaxLevel)
    local repForPreviousWeekCap = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, info.previousWeekProgressiveMaxLevel)
    local repForMaxRank = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, info.maxLevel)
    local myTotalRep = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, rank) + (info.renownReputationEarned or 0)

    if repForWeekCap > 0 then
        row.progressBar:Show()
        row.progressBar:SetMinMaxValues(0, repForWeekCap)
        row.progressBar:SetValue(myTotalRep)
        row.barText:SetText(PVP_RANK_SEASON_PROGRESS:format(myTotalRep, repForWeekCap))
    else
        row.progressBar:Hide()
    end

    local text = PVP_RANK_SEASON_RANKUP_DESCRIPTION:format(repForMaxRank, info.maxLevel)
    if repForWeekCap == 0 and myTotalRep > 0 then
        text = PVP_RANK_SEASON_PROGRESS_NO_MAX:format(myTotalRep) .. "\n\n" .. text
    end
    local capIncrease = repForWeekCap - repForPreviousWeekCap
    if capIncrease > 0 then
        text = text .. "\n\n" .. PVP_RANK_WEEKLY_CAP_INCREASE:format(capIncrease)
    end
    SetRowText(row, text)
    row.Text:ClearAllPoints()
    if row.progressBar:IsShown() then
        row.Text:SetPoint("TOPLEFT", row.progressBar, "BOTTOMLEFT", 0, -10)
        LayoutRow(row, 34 + row.Text:GetStringHeight())
    else
        row.Text:SetPoint("TOPLEFT", row, "TOPLEFT", 16, -56)
        LayoutRow(row, row.Text:GetStringHeight())
    end
end

local function UpdateRewardRow(row, info)
    local rank = info.renownLevel or 0
    local nextRewardRank, rewards
    for testRank = rank + 1, info.maxLevel do
        local rewardInfos = C_MajorFactions.GetRenownRewardsForLevel(PVP_RANK_POINTS_FACTION_ID, testRank)
        if rewardInfos and #rewardInfos > 0 then
            nextRewardRank, rewards = testRank, rewardInfos
            break
        end
    end

    row.progressBar:Hide()
    if not nextRewardRank then
        row:Hide()
        return
    end
    row:Show()

    SetRankBadge(row.icon, nextRewardRank)
    row.Header:SetText(PVP_RANK_NEXT_REWARD:format(nextRewardRank))
    row.Rank:SetText(GetRankText(nextRewardRank))

    local lineIndex, previous = 0, nil
    for _, reward in ipairs(rewards) do
        if reward.description then
            lineIndex = lineIndex + 1
            local line = AcquireLine(row, lineIndex)
            line.icon:SetTexture(reward.icon)
            line.text:SetText(reward.description)
            line:ClearAllPoints()
            if previous then
                line:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
            else
                line:SetPoint("TOPLEFT", row, "TOPLEFT", 16, -56)
            end
            previous = line
        end
    end
    HideLines(row, lineIndex + 1)

    SetRowText(row, IsHorde() and PVP_RANK_REWARDS_VENDOR_HORDE or PVP_RANK_REWARDS_VENDOR_ALLIANCE)
    row.Text:ClearAllPoints()
    if previous then
        row.Text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -10)
    else
        row.Text:SetPoint("TOPLEFT", row, "TOPLEFT", 16, -56)
    end
    LayoutRow(row, lineIndex * 40 + row.Text:GetStringHeight() + 10)
end

local function UpdateHonorPanel(panel)
    local info = C_MajorFactions.GetMajorFactionProgressionInfo(PVP_RANK_POINTS_FACTION_ID)
    panel.unavailable:SetShown(info == nil)
    for _, row in ipairs(panel.rows) do
        row:SetShown(info ~= nil)
    end
    if not info then return end

    UpdateRankRow(panel.rows[1], info)
    UpdateSeasonRow(panel.rows[2], info)
    UpdateRewardRow(panel.rows[3], info)
end

local function panel_OnShow(self)
    UpdateHonorPanel(self)
    self.ticker = self.ticker or C_Timer.NewTicker(1, function()
        UpdateSeasonTimer(self.rows[2])
        if self.currentSeason ~= GetCurrentArenaSeason() then
            self.currentSeason = GetCurrentArenaSeason()
            UpdateHonorPanel(self)
        end
    end)
end

local function panel_OnHide(self)
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

function GW.LoadHonorPanel(panel, fmMenu)
    panel.rows = {}
    local previous
    for i = 1, 3 do
        previous = CreateRow(panel, i, previous)
        panel.rows[i] = previous
    end

    panel.unavailable = panel:CreateFontString(nil, "OVERLAY")
    panel.unavailable:SetPoint("CENTER")
    panel.unavailable:SetWidth(400)
    panel.unavailable:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    panel.unavailable:SetTextColor(0.6, 0.6, 0.6)
    panel.unavailable:SetText(PVP_RANK_DETAIL_UNAVAILABLE)
    panel.unavailable:Hide()

    panel.currentSeason = GetCurrentArenaSeason()
    panel:RegisterEvent("UPDATE_FACTION")
    panel:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    panel:SetScript("OnEvent", function(self)
        if self:IsShown() then
            UpdateHonorPanel(self)
        end
    end)
    panel:SetScript("OnShow", panel_OnShow)
    panel:SetScript("OnHide", panel_OnHide)

    fmMenu:SetupBackButton(panel.backButton, CHARACTER .. ": " .. PVP)
end
