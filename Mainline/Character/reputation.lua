local _, GW = ...
local L = GW.L
local RoundDec = GW.RoundDec
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS
local RT = GW.REP_TEXTURES

local isSearchResult = nil
local firstReputationCat = 1
local lastReputationCat = 1
local OFF_Y = 10
local DETAIL_H = 65
local DETAIL_LG_H = (DETAIL_H * 2) + OFF_Y
local REPBG_T = 0
local REPBG_B = 0.464

local g_selectionBehavior = nil
local updateQueued = false

local factionDataCache = {}

local ReputationFrameEvents = {
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
	"MAJOR_FACTION_UNLOCKED",
	"QUEST_LOG_UPDATE",
	"UPDATE_FACTION",
}

local function SetFontWithShadow(element, font, size, sizeAddition)
    element:GwSetFontTemplate(font, size, nil, sizeAddition)
    element:SetShadowColor(0, 0, 0, 1)
    element:SetShadowOffset(1, -1)
end

local function sortFactionsStatus(tbl)
    table.sort(tbl, function(a, b)
            if a.isFriend ~= b.isFriend then
                return b.isFriend
            elseif a.reaction ~= b.reaction then
                return a.reaction > b.reaction
            else
                return a.reaction < b.reaction
            end
        end)
    return tbl
end

local function addToFactionTable(factionTbl, reaction, standingText, isFriend, name, hasRewardPending, pendingParagonRewardFactions)
    for _, v in ipairs(factionTbl) do
        if v.isFriend == isFriend and v.standingText == standingText then
            v.counter = v.counter + 1
            if hasRewardPending then
                tinsert(pendingParagonRewardFactions, {name = name})
            end
            return true
        end
    end

    if hasRewardPending then
        tinsert(pendingParagonRewardFactions, {name = name})
    end

    tinsert(factionTbl, {reaction = reaction, standingText = standingText, isFriend = isFriend, counter = 1})
    return false
end

local function UpdateCategories(self, details)
    self:SetDataProvider(CreateDataProvider(details), ScrollBoxConstants.RetainScrollPosition)
end

local function UpdateDetailsData(self, details)
    self:SetDataProvider(CreateDataProvider(details), ScrollBoxConstants.RetainScrollPosition)
end

local function CollectFactionData(fetchData)
    local categories = {}
    local details = {}
    local factionTbl = {}
    local pendingParagonRewardFactions = {}

    local cMax, cCur = 0, 0
    local idx, headerName = 0, ""
    local skipFirst = true
    local hasPendingParagonReward = false
    local savedHeaderName = ""

    local searchLower = isSearchResult and string.lower(isSearchResult) or nil

    if fetchData then
        C_Reputation.ExpandAllFactionHeaders()
        wipe(factionDataCache)
        for factionIndex = 1, C_Reputation.GetNumFactions() do
            local factionData = C_Reputation.GetFactionDataByIndex(factionIndex)
            if factionData then
                if factionData.name == GUILD then
                    factionData = C_Reputation.GetGuildFactionData()
                end
                if factionData then
                    factionData.factionIndex = factionIndex
                    tinsert(factionDataCache, factionData)
                end
            end
        end
    end

    for _, data in ipairs(factionDataCache) do
        if data then
            local includeInDetails = false
            if data.name then
                if isSearchResult then
                    if not (data.isHeader and not data.isChild) and string.find(string.lower(data.name), searchLower) then
                        includeInDetails = true
                    end
                else
                    if data.factionIndex >= firstReputationCat and data.factionIndex <= lastReputationCat and data.factionID and (not data.isHeader or data.isChild) then
                        includeInDetails = not data.isHeader or data.isHeaderWithRep
                    end
                end
            end

            if includeInDetails then
                if data.isHeader and data.isChild then
                    savedHeaderName = data.name
                elseif not data.isChild then
                    savedHeaderName = ""
                end
                data.savedHeaderName = savedHeaderName
                tinsert(details, data)
            end

            -- Category collection
            local friendInfo = C_GossipInfo.GetFriendshipReputation(data.factionID or 0)
            local _, _, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(data.factionID or 0)

            if data.name then
                if data.isHeader and not data.isChild then
                    if not skipFirst then
                        tinsert(categories, {
                            idx = idx,
                            idxLast = data.factionIndex - 1,
                            name = headerName,
                            standingCur = cCur,
                            standingMax = cMax,
                            fctTbl = sortFactionsStatus(factionTbl),
                            hasPendingParagonReward = hasPendingParagonReward,
                            pendingParagonRewardFactions = pendingParagonRewardFactions
                        })
                    end
                    skipFirst = false
                    cMax, cCur = 0, 0
                    factionTbl = {}
                    pendingParagonRewardFactions = {}
                    hasPendingParagonReward = false
                    idx = data.factionIndex
                    headerName = data.name
                else
                    if friendInfo and friendInfo.friendshipFactionID and friendInfo.friendshipFactionID > 0 then
                        local ranks = C_GossipInfo.GetFriendshipReputationRanks(friendInfo.friendshipFactionID)
                        cMax = cMax + ranks.maxLevel
                        cCur = cCur + ranks.currentLevel
                        addToFactionTable(factionTbl, ranks.currentLevel, friendInfo.reaction, true, data.name, hasRewardPending, pendingParagonRewardFactions)
                        if hasRewardPending then hasPendingParagonReward = true end
                    elseif C_Reputation.IsMajorFaction(data.factionID) then
                        local major = C_MajorFactions.GetMajorFactionData(data.factionID)
                        if major then
                            local standingText = RENOWN_LEVEL_LABEL:format(major.renownLevel)
                            cMax = cMax + #C_MajorFactions.GetRenownLevels(data.factionID)
                            cCur = cCur + major.renownLevel
                            addToFactionTable(factionTbl, major.renownLevel, standingText, false, data.name, hasRewardPending, pendingParagonRewardFactions)
                            if hasRewardPending then hasPendingParagonReward = true end
                        end
                    elseif not data.isHeader then
                        local standingText = getglobal("FACTION_STANDING_LABEL" .. data.reaction)
                        cMax = cMax + 8
                        cCur = cCur + data.reaction
                        addToFactionTable(factionTbl, data.reaction, standingText, false, data.name, hasRewardPending, pendingParagonRewardFactions)
                        if hasRewardPending then hasPendingParagonReward = true end
                    end
                end
            end
        end
    end

    -- Final category insert
    if #factionTbl > 0 then
        tinsert(categories, {
            idx = idx,
            idxLast = #factionDataCache,
            name = headerName,
            standingCur = cCur,
            standingMax = cMax,
            fctTbl = sortFactionsStatus(factionTbl),
            hasPendingParagonReward = hasPendingParagonReward,
            pendingParagonRewardFactions = pendingParagonRewardFactions
        })
    end

    return categories, details
end

local function SetSelectedHeaderIndexRange(firstIndex, lastIndex)
    firstReputationCat = firstIndex
    lastReputationCat = lastIndex
end

local function detailsAtwar_OnEnter(self)
    self.icon:SetTexCoord(0.5, 1, 0, 0.5)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(REPUTATION_AT_WAR_DESCRIPTION, nil, nil, nil, nil, true)
    GameTooltip:Show()
end

local function detailsAtwar_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end
    GameTooltip:Hide()
end

local function detailsInactive_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(REPUTATION_MOVE_TO_INACTIVE, nil, nil, nil, nil, true)
    GameTooltip:Show()
end

local function detailsShowAsBar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(REPUTATION_SHOW_AS_XP, nil, nil, nil, nil, true)
    GameTooltip:Show()
end

local function detailsControls_OnShow(self)
    self:GetParent().details:Show()
    self:GetParent().detailsbg:Show()

    if self.atwar.isShowAble then
        self.atwar:Show()
    else
        self.atwar:Hide()
    end

    if self.viewRenown.isShowAble then
        self.viewRenown:Show()
    else
        self.viewRenown:Hide()
    end

    if self.inactive.isShowAble then
        self.inactive:Show()
    else
        self.inactive:Hide()
    end
end

local function detailsControls_OnHide(self)
    self:GetParent().details:Hide()
    self:GetParent().detailsbg:Hide()
end

local function ToggleDetailsButton(self, showDetails)
    self:SetHeight(showDetails and DETAIL_LG_H or DETAIL_H)
    self.controles:SetShown(showDetails)
    if showDetails then
        self.repbg:SetTexCoord(unpack(GW.TexCoords))
    else
        self.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
    end
    self.repbg:SetDesaturated(not showDetails)
end

local function ToggleDetails(self)
    if not self then return end
    g_selectionBehavior:ToggleSelect(self)
     ToggleDetailsButton(self, g_selectionBehavior:IsSelected(self))
end

local function setReputationDetails(frame, data)
    frame.factionIndex = data.factionIndex
    frame.factionID = data.factionID

    if g_selectionBehavior:IsSelected(frame) then
        frame.controles:Show()
        frame:SetHeight(DETAIL_LG_H)
    else
        frame:SetHeight(DETAIL_H)
        frame.controles:Hide()
    end

    local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, data.reaction)), GW.mysex)
    local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, data.reaction + 1)), GW.mysex)
    local friendInfo = C_GossipInfo.GetFriendshipReputation(data.factionID or 0)

    frame.background:SetTexture(nil)

    if data.isAccountWide then
        frame.accountWide:Show()
    else
        frame.accountWide:Hide()
    end

    if data.savedHeaderName ~= nil and data.savedHeaderName ~= "" and data.savedHeaderName ~= data.name then
        frame.name:SetText(data.name .. "  |cFFa0a0a0" .. data.savedHeaderName .. "|r")
    else
        frame.name:SetText(data.name)
    end
    frame.details:SetText(data.description)

    if data.atWarWith then
        frame.controles.atwar.isActive = true
        frame.controles.atwar.icon:SetTexCoord(0.5, 1, 0, 0.5)
    else
        frame.controles.atwar.isActive = false
        frame.controles.atwar.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end

    frame.controles.viewRenown.isShowAble = data.factionID and C_Reputation.IsMajorFaction(data.factionID)
    frame.controles.atwar.isShowAble = data.canToggleAtWar
    frame.controles.showAsBar.checkbutton:SetChecked(data.isWatched)
    frame.controles.inactive.isShowAble = data.canSetInactive
    frame.controles.inactive.checkbutton:SetChecked(not C_Reputation.IsFactionActive(data.factionIndex))

    if data.factionID and RT[data.factionID] then
        frame.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/rep/" .. RT[data.factionID])
        if g_selectionBehavior:IsSelected(frame) then
            frame.repbg:SetTexCoord(unpack(GW.TexCoords))
            frame.repbg:SetAlpha(0.85)
            frame.repbg:SetDesaturated(false)
        else
            frame.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
            frame.repbg:SetAlpha(0.33)
            frame.repbg:SetDesaturated(true)
        end
    else
        GW.Debug("no faction", data.name, data.factionID)
        frame.repbg:SetAlpha(0)
    end

    if data.factionID and C_Reputation.IsFactionParagon(data.factionID) then
        local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(data.factionID)
        local value = currentValue % threshold
        local isMajorFaction = C_Reputation.IsMajorFaction(data.factionID)
        local majorFactionData = isMajorFaction and C_MajorFactions.GetMajorFactionData(data.factionID)
        local currentRankText = majorFactionData and RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel) or friendInfo.friendshipFactionID and friendInfo.reaction or currentRank

        if hasRewardPending then
            frame.name:SetText(frame.name:GetText() .. "|TInterface/AddOns/GW2_UI/textures/icons/rewards-icon.png:32:32:0:0|t")
        end

        frame.currentRank:SetText(currentRankText)
        frame.nextRank:SetText(L["Paragon"] .. (currentValue > threshold and (" (" .. RoundDec(currentValue / threshold, 0) .. "x)") or ""))

        frame.currentValue:SetText(GW.GetLocalizedNumber(value))
        frame.nextValue:SetText(GW.GetLocalizedNumber(threshold))

        local percent = math.floor(RoundDec(((value - 0) / (threshold - 0)) * 100))
        frame.percentage:SetText(percent .. "%")

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((value - 0) / (threshold - 0))

        frame.background2:SetVertexColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
        frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
    elseif friendInfo.friendshipFactionID > 0 then
        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.currentRank:SetText(friendInfo.reaction)
        frame.nextRank:SetText()

        frame.background2:SetVertexColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
        frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)

        if (friendInfo.nextThreshold) then
            frame.currentValue:SetText(GW.GetLocalizedNumber(friendInfo.standing - friendInfo.reactionThreshold))
            frame.nextValue:SetText(GW.GetLocalizedNumber(friendInfo.nextThreshold - friendInfo.reactionThreshold))

            local percent =
                math.floor(RoundDec(((friendInfo.standing - friendInfo.reactionThreshold) / (friendInfo.nextThreshold - friendInfo.reactionThreshold)) * 100))
            if percent == -1 then
                frame.percentage:SetText("0%")
            else
                frame.percentage:SetText(percent .. "%")
            end

            frame.StatusBar:SetValue((friendInfo.standing - friendInfo.reactionThreshold) / (friendInfo.nextThreshold - friendInfo.reactionThreshold))
        else
            --max rank
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
            frame.percentage:SetText("100%")
        end
    elseif data.factionID and C_Reputation.IsMajorFaction(data.factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(data.factionID)
        if majorFactionData then
            frame.StatusBar:SetMinMaxValues(0, 1)

            frame.background2:SetVertexColor(FACTION_BAR_COLORS[11].r, FACTION_BAR_COLORS[11].g, FACTION_BAR_COLORS[11].b)
            frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[11].r, FACTION_BAR_COLORS[11].g, FACTION_BAR_COLORS[11].b)

            if C_MajorFactions.HasMaximumRenown(data.factionID) then
                --max rank
                frame.StatusBar:SetValue(1)

                frame.currentRank:SetText(RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel))
                frame.nextRank:SetText(RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel))

                frame.nextValue:SetText()
                frame.currentValue:SetText()
                frame.percentage:SetText("100%")
            else
                frame.nextRank:SetText(RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel + 1))
                frame.currentRank:SetText(RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel))

                frame.currentValue:SetText(GW.GetLocalizedNumber(majorFactionData.renownReputationEarned or 0))
                frame.nextValue:SetText(GW.GetLocalizedNumber(majorFactionData.renownLevelThreshold))
                frame.percentage:SetText((math.floor((majorFactionData.renownReputationEarned or 0) / majorFactionData.renownLevelThreshold * 100) .. "%"))

                frame.StatusBar:SetValue((majorFactionData.renownReputationEarned or 0) / majorFactionData.renownLevelThreshold)
            end
        end
    else
        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(nextRank)
        frame.currentValue:SetText(GW.GetLocalizedNumber(data.currentStanding - data.currentReactionThreshold))
        local ldiff = data.nextReactionThreshold - data.currentReactionThreshold
        if ldiff == 0 then
            ldiff = 1
        end
        local percent = math.floor(RoundDec(((data.currentStanding - data.currentReactionThreshold) / ldiff) * 100))
        if percent == -1 then
            frame.percentage:SetText("0%")
        else
            frame.percentage:SetText(percent .. "%")
        end

        frame.nextValue:SetText(GW.GetLocalizedNumber(ldiff))

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((data.currentStanding - data.currentReactionThreshold) / ldiff)

        if currentRank == nextRank and data.currentStanding - data.currentReactionThreshold == 0 then
            frame.percentage:SetText("100%")
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
        end

        frame.background2:SetVertexColor(FACTION_BAR_COLORS[data.reaction].r, FACTION_BAR_COLORS[data.reaction].g, FACTION_BAR_COLORS[data.reaction].b)
        frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[data.reaction].r, FACTION_BAR_COLORS[data.reaction].g, FACTION_BAR_COLORS[data.reaction].b)
    end
end

local function status_SetValue(self)
    local v = self:GetValue()
    local _, max = self:GetMinMaxValues()
    local width = math.max(1, math.min(10, 10 * ((v / max) / 0.1)))

    if v == max then
        self.spark:Hide()
    else
        self.spark:SetPoint("RIGHT", self, "LEFT", self:GetWidth() * (v / max), 0)
        self.spark:SetWidth(width)
        self.spark:Show()
    end
end

local function detailsInactive_OnClick(self)
    local parent = self:GetParent():GetParent()
    isSearchResult = nil
    local shouldBeActive = not C_Reputation.IsFactionActive(parent.data.factionIndex)
    local categories, details = CollectFactionData()
    C_Reputation.SetFactionActive(parent.data.factionIndex, shouldBeActive)
    UpdateCategories(GwPaperReputation.Categories, categories)
    local firstCategory = GwPaperReputation.Categories:FindElementData(1)
    if firstCategory then
        SetSelectedHeaderIndexRange(firstCategory.idx, firstCategory.idxLast)
        categories, details = CollectFactionData()
    end
    UpdateDetailsData(GwRepDetailFrame.Details, details)
end

local function detailsAtwar_OnClick(self)
    local parent = self:GetParent():GetParent()
    C_Reputation.ToggleFactionAtWar(parent.data.factionIndex)
    if parent.data.canToggleAtWar then
        isSearchResult = nil
        local _, details = CollectFactionData()
        UpdateDetailsData(GwRepDetailFrame.Details, details)
    end
end

local function detailsViewRenown_OnClick(self)
    if not EncounterJournal then
		EncounterJournal_LoadUI()
	end

	if not EncounterJournal:IsShown() then
		ShowUIPanel(EncounterJournal)
	end

    local parent = self:GetParent():GetParent()
	EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID())
	EncounterJournalJourneysFrame:ResetView(nil, parent.data.factionID)
end

local function detailsShowAsBar_OnClick(self)
    local parent = self:GetParent():GetParent()
    if parent.data.isWatched then
        C_Reputation.SetWatchedFactionByIndex(0)
    else
        C_Reputation.SetWatchedFactionByIndex(parent.data.factionIndex)
    end
end

local function InitDetailsButton(button, elementData)
    if not button.isSkinned then

        SetFontWithShadow(button.controles.inactive.string, UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        SetFontWithShadow(button.controles.showAsBar.string, UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        SetFontWithShadow(button.StatusBar.currentValue, UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        SetFontWithShadow(button.StatusBar.percentage, UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        SetFontWithShadow(button.StatusBar.nextValue, UNIT_NAME_FONT, GW.TextSizeType.SMALL)

        SetFontWithShadow(button.currentRank, UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        SetFontWithShadow(button.nextRank, UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        SetFontWithShadow(button.name, DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        SetFontWithShadow(button.details, UNIT_NAME_FONT, GW.TextSizeType.SMALL)

        button.currentRank:SetTextColor(0.6, 0.6, 0.6)
        button.nextRank:SetTextColor(0.6, 0.6, 0.6)
        button.name:SetTextColor(1, 1, 1, 1)
        button.details:SetTextColor(0.8, 0.8, 0.8, 1)

        button.StatusBar:SetMinMaxValues(0, 1)
        button.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
        hooksecurefunc(button.StatusBar, "SetValue", status_SetValue)
        button.StatusBar:GetParent().currentValue = button.StatusBar.currentValue
        button.StatusBar:GetParent().percentage = button.StatusBar.percentage
        button.StatusBar:GetParent().nextValue = button.StatusBar.nextValue

        button.controles:SetScript("OnShow", detailsControls_OnShow)
        button.controles:SetScript("OnHide", detailsControls_OnHide)
        button.controles.atwar:SetScript("OnEnter", detailsAtwar_OnEnter)
        button.controles.atwar:SetScript("OnLeave", detailsAtwar_OnLeave)
        button.controles.atwar:SetScript("OnClick", detailsAtwar_OnClick)
        button.controles.viewRenown:SetScript("OnClick", detailsViewRenown_OnClick)
        button.controles.inactive:SetScript("OnEnter", detailsInactive_OnEnter)
        button.controles.inactive:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.inactive.checkbutton:SetScript("OnEnter", detailsInactive_OnEnter)
        button.controles.inactive.checkbutton:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.inactive:SetScript("OnClick", detailsInactive_OnClick)
        button.controles.inactive.checkbutton:SetScript("OnClick", function() detailsInactive_OnClick(button.controles.inactive) end)
        button.controles.showAsBar:SetScript("OnEnter", detailsShowAsBar_OnEnter)
        button.controles.showAsBar:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.showAsBar:SetScript("OnClick", detailsShowAsBar_OnClick)
        button.controles.showAsBar.checkbutton:SetScript("OnClick", function() detailsShowAsBar_OnClick(button.controles.showAsBar) end)
        button.controles.showAsBar.checkbutton:SetScript("OnEnter", detailsShowAsBar_OnEnter)
        button.controles.showAsBar.checkbutton:SetScript("OnLeave", GameTooltip_Hide)
        button.accountWide:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, 1, 1, 1)
            GameTooltip:Show()
        end)
        button.accountWide:SetScript("OnLeave", GameTooltip_Hide)
        button:SetScript("OnClick", ToggleDetails)
        button:SetScript("OnEnter", function(self)
            self.repbg:SetBlendMode("ADD")
            self.background:SetBlendMode("ADD")
            self.background2:SetBlendMode("ADD")
        end)
        button:SetScript("OnLeave", function(self)
            self.repbg:SetBlendMode("BLEND")
            self.background:SetBlendMode("BLEND")
            self.background2:SetBlendMode("BLEND")
        end)

        button.controles.inactive.string:SetText(FACTION_INACTIVE)
        button.controles.inactive:SetWidth(button.controles.inactive.string:GetWidth())
        button.controles.showAsBar.string:SetText(SHOW_FACTION_ON_MAINSCREEN)
        button.currentRank:SetText(REFORGE_CURRENT)
        button.nextRank:SetText(NEXT)

        button.details:SetPoint("TOPLEFT", button.StatusBar, "BOTTOMLEFT", 0, -25)
        button.statusbarbg:SetPoint("TOPLEFT", button.StatusBar, "TOPLEFT", -2, 2)
        button.statusbarbg:SetPoint("BOTTOMRIGHT", button.StatusBar, "BOTTOMRIGHT", 2, -2)
        button.currentRank:SetPoint("TOPLEFT", button.StatusBar, "BOTTOMLEFT", 0, -5)
        button.nextRank:SetPoint("TOPRIGHT", button.StatusBar, "BOTTOMRIGHT", 0, -5)

        button.details:Hide()
        button.detailsbg:Hide()
        button.details:SetWidth(button.StatusBar:GetWidth())
        button.controles.showAsBar:SetWidth(button.controles.showAsBar.string:GetWidth())
        button.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
        button.repbg:SetDesaturated(true)

        button.isSkinned = true
    end
    button.data = elementData
    setReputationDetails(button, elementData)
end

local function InitCategorieButton(button, elementData)
    if not button.isSkinned then
        SetFontWithShadow(button.name, DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        SetFontWithShadow(button.StatusBar.percentage, UNIT_NAME_FONT, GW.TextSizeType.SMALL, -2)

        button.name:SetTextColor(1, 1, 1, 1)

        hooksecurefunc(button.StatusBar, "SetValue", function(self)
                local v = self:GetValue()
                local width = math.max(1, math.min(10, 10 * ((v / 1) / 0.1)))
                if v == max then
                    button.StatusBar.Spark:Hide()
                else
                    button.StatusBar.Spark:SetPoint("RIGHT", self, "LEFT", 201 * (v / 1), 0)
                    button.StatusBar.Spark:SetWidth(width)
                    button.StatusBar.Spark:Show()
                end
            end)
        button:SetScript("OnClick", function(self)
            isSearchResult = nil
            SetSelectedHeaderIndexRange(self.factionIndexFirst, self.factionIndexLast)
            local categories, details = CollectFactionData()
            UpdateCategories(GwPaperReputation.Categories, categories)
            UpdateDetailsData(GwRepDetailFrame.Details, details)
        end)
        button:SetScript("OnEnter", function(self)
            local addedFriendTitle = false
            self.backgroundHover:SetBlendMode("ADD")
            self.zebra:SetBlendMode("ADD")
            self.StatusBar.percentage:Show()

            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(ACHIEVEMENT_SUMMARY_CATEGORY, 1, 1, 1)

            for _, v in pairs(self.standings) do
                if v.isFriend and not addedFriendTitle then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(FRIENDS, 1, 1, 1)
                    addedFriendTitle = true
                end
                GameTooltip:AddDoubleLine(v.standingText, v.counter)
            end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function(self)
            self.backgroundHover:SetBlendMode("BLEND")
            self.zebra:SetBlendMode("BLEND")
            self.StatusBar.percentage:Hide()
            GameTooltip:Hide()
        end)
        button.paragonIndicator:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Paragon"], 1, 1, 1)
            for _, v in pairs(button.pendingParagonRewardFactions) do
                GameTooltip:AddLine(v.name)
            end
            GameTooltip:Show()
        end)
        button.paragonIndicator:SetScript("OnLeave", GameTooltip_Hide)

        GW.AddFlareAnimationToObject(button, button.paragonIndicator)
        button.paragonIndicator.flare:SetSize(32, 32)
        button.paragonIndicator.flare2:SetSize(32, 32)

        function button:StopParagonIdicatorAnimation()
            self.paragonIndicator:Hide()
            self.flareIcon.animationGroup:Stop()
        end

        function button:StartParagonIdicatorAnimation()
            self.paragonIndicator:Show()
            self.flareIcon.animationGroup:Play()
        end

        GwPaperReputation:HookScript("OnHide", function()
           button:StopParagonIdicatorAnimation()
        end)

        button.isSkinned = true
    end

    button.factionIndexFirst = elementData.idx
    button.factionIndexLast = elementData.idxLast
    button.standings = elementData.fctTbl
    button.pendingParagonRewardFactions = elementData.pendingParagonRewardFactions

    button.name:SetText(elementData.name)
    if elementData.name ~= COVENANT_SANCTUM_TIER_INACTIVE and elementData.standingCur and elementData.standingCur > 0 and elementData.standingMax and elementData.standingMax > 0 then
        button.StatusBar:SetValue(elementData.standingCur / elementData.standingMax)
        button.StatusBar.percentage:SetText(math.floor(RoundDec(button.StatusBar:GetValue() * 100)) .. "%")
        if elementData.standingCur / elementData.standingMax >= 1 and elementData.standingMax ~= 0 then
            button.StatusBar:SetStatusBarColor(171 / 255, 37 / 255, 240 / 255)
            button.StatusBar.Spark:Hide()
        else
            button.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
        end
        button.StatusBar:Show()
        button.statusbarbg:Show()
    else
        button.StatusBar:Hide()
        button.statusbarbg:Hide()
    end
    -- paragonIndicator
    button:StopParagonIdicatorAnimation()
    if GwPaperReputation:IsShown() then
        if elementData.hasPendingParagonReward then
            button:StartParagonIdicatorAnimation()
        end
    end

    -- set zebra color by idx or watch status
    local zebra = elementData.idx % 2
    if button.factionIndexFirst == firstReputationCat then
        button.zebra:SetVertexColor(1, 1, 0.5, 0.15)
    else
        button.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
    end
end

local function SetSearchboxInstructions(editbox, text)
    editbox.Instructions:SetTextColor(0.5, 0.5, 0.5)
    editbox.Instructions:SetText(text)
end

local function LoadReputation(tabContainer)
    local fmGPR = CreateFrame("Frame", "GwPaperReputation", tabContainer, "GwPaperReputation")
    local fmDetail = CreateFrame("Frame", "GwRepDetailFrame", tabContainer, "GwRepDetailFrame")
    local view = CreateScrollBoxListLinearView()

    view:SetElementInitializer("GwPaperDollReputationCat", function(button, elementData)
        InitCategorieButton(button, elementData)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(fmGPR.Categories, fmGPR.ScrollBar, view)
    GW.HandleTrimScrollBar(fmGPR.ScrollBar)
    GW.HandleScrollControls(fmGPR)
    fmGPR.ScrollBar:SetHideIfUnscrollable(true)

    local fnGPR_OnEvent = function(_, event)
        if not GW.inWorld or not fmGPR:IsShown() then
            return
        end
        if not updateQueued then
            updateQueued = true
            C_Timer.After(0.2, function()
                isSearchResult = nil
                local _, details = CollectFactionData(true)
                UpdateDetailsData(fmDetail.Details, details)
                GW.Debug("Reputation", event)
                updateQueued = false
            end)
        end
    end
    fmGPR.Categories:SetScript("OnEvent", fnGPR_OnEvent)
    SetSearchboxInstructions(fmGPR.input, SEARCH .. "...")
    fmGPR.input:SetText("")
    fmGPR.input:SetScript("OnEnterPressed", nil)

    fmGPR.input:HookScript("OnTextChanged", function(self)
        local text = self:GetText()
        local details
        if text == "" then
            isSearchResult = nil
            _, details = CollectFactionData()
            self.clearButton:Hide()
        else
            isSearchResult = text
            _, details = CollectFactionData()
            self.clearButton:Show()
        end
        UpdateDetailsData(fmDetail.Details, details)
    end)

    fmGPR.input:SetScript("OnEscapePressed", function(self)
        isSearchResult = nil
        local _, details = CollectFactionData()
        self:ClearFocus()
        self:SetText("")
        UpdateDetailsData(fmDetail.Details, details)
    end)

    fmGPR.input:SetScript("OnEditFocusGained", function(self)
        self.clearButton:Show()
    end)

    fmGPR.input:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self.clearButton:Hide()
        end
    end)
    fmGPR.input.clearButton:SetScript("OnClick", function(self)
        isSearchResult = nil
        local _, details = CollectFactionData()
        self:GetParent():ClearFocus()
        self:GetParent():SetText("")
        UpdateDetailsData(fmDetail.Details, details)
    end)

    local detailsView = CreateScrollBoxListLinearView()
    detailsView:SetElementInitializer("GwReputationDetails", function(button, elementData)
        InitDetailsButton(button, elementData)
    end)
    detailsView:SetPadding(5, 5, 12, 12, 10)
    detailsView:SetElementExtentCalculator(function(dataIndex, elementData)
        if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
            return DETAIL_LG_H
        else
            return DETAIL_H
        end
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(fmDetail.Details, fmDetail.ScrollBar, detailsView)

    g_selectionBehavior = ScrollUtil.AddSelectionBehavior(fmDetail.Details, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
    g_selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
        local button = fmDetail.Details:FindFrame(elementData)
        if not button then return end
        ToggleDetailsButton(button, selected)
    end, fmDetail)

    ScrollUtil.AddResizableChildrenBehavior(fmDetail.Details)

    GW.HandleTrimScrollBar(fmDetail.ScrollBar)
    GW.HandleScrollControls(fmDetail)
    fmDetail.ScrollBar:SetHideIfUnscrollable(true)

    isSearchResult = nil
    local categories, details = CollectFactionData(true)
    UpdateCategories(fmGPR.Categories, categories)
    local firstCategory = fmGPR.Categories:FindElementData(1)
    if firstCategory then
        SetSelectedHeaderIndexRange(firstCategory.idx, firstCategory.idxLast)
        _, details = CollectFactionData()
    end
    UpdateDetailsData(fmDetail.Details, details)

    ReputationFrame:UnregisterAllEvents()

    fmGPR:HookScript("OnShow", function(self)
        FrameUtil.RegisterFrameForEvents(self.Categories, ReputationFrameEvents)
        isSearchResult = nil
        local cat, detailsOnShow = CollectFactionData(true)
        UpdateCategories(fmGPR.Categories, cat)
        UpdateDetailsData(fmDetail.Details, detailsOnShow)
    end)

    fmGPR:HookScript("OnHide", function(self)
        FrameUtil.UnregisterFrameForEvents(self.Categories, ReputationFrameEvents)
    end)
end
GW.LoadReputation = LoadReputation
