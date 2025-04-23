local _, GW = ...
local L = GW.L
local RoundDec = GW.RoundDec
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS
local RT = GW.REP_TEXTURES

local categoriesScrollBox
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

local function CollectCategories()
    C_Reputation.ExpandAllFactionHeaders()

    local categories = {}
    local factionTbl = {}
    local pendingParagonRewardFactions = {}
    local cMax, cCur = 0, 0
    local idx, headerName = 0, ""
    local skipFirst = true
    local hasPendingParagonReward = false

    for factionIndex = 1, C_Reputation.GetNumFactions() do
        local data = C_Reputation.GetFactionDataByIndex(factionIndex)
        if data and data.name then
            local friendInfo = C_GossipInfo.GetFriendshipReputation(data.factionID or 0)
            local _, _, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(data.factionID or 0)

            if data.isHeader and not data.isChild then
                if not skipFirst then
                    tinsert(categories, {
                        idx = idx,
                        idxLast = factionIndex - 1,
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
                idx = factionIndex
                headerName = data.name
            else
                if friendInfo and friendInfo.friendshipFactionID and friendInfo.friendshipFactionID > 0 then
                    local friendRanks = C_GossipInfo.GetFriendshipReputationRanks(friendInfo.friendshipFactionID)
                    local standingText = friendInfo.reaction
                    cMax = cMax + friendRanks.maxLevel
                    cCur = cCur + friendRanks.currentLevel
                    addToFactionTable(factionTbl, friendRanks.currentLevel, standingText, true, data.name, hasRewardPending, pendingParagonRewardFactions)
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
    -- insert the last header
    if #factionTbl > 0 then
        tinsert(categories, {
            idx = idx,
            idxLast = C_Reputation.GetNumFactions(),
            name = headerName,
            standingCur = cCur,
            standingMax = cMax,
            fctTbl = sortFactionsStatus(factionTbl),
            hasPendingParagonReward = hasPendingParagonReward,
            pendingParagonRewardFactions = pendingParagonRewardFactions
        })
    end

    return categories
end

local function UpdateCategories(self)
    local dataProvider = CreateDataProvider()

    for index, data in pairs( CollectCategories() ) do
        dataProvider:Insert({index = index, data = data})
    end

    self:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function UpdateDetailsData(self)
    local factionList = {}
    for factionIndex = 1, C_Reputation.GetNumFactions() do
        local factionData = C_Reputation.GetFactionDataByIndex(factionIndex)
        if factionData then
            if factionData.name == GUILD then
                factionData = C_Reputation.GetGuildFactionData()
            end
            if factionData then
                factionData.factionIndex = factionIndex
                tinsert(factionList, factionData)
            end
        end
    end

    -- run through factions to get data and total count for the selected category
    local savedHeaderName = ""
    local filteredFactionList = {}

    local searchLower = isSearchResult and string.lower(isSearchResult) or nil

    for _, data in ipairs(factionList) do
        local name = data.name
        if name then
            local include = false
            if isSearchResult then
                if not (data.isHeader and not data.isChild) and string.find(string.lower(name), searchLower) then
                    include = true
                end
            else
                local index = data.factionIndex
                if index >= firstReputationCat and index <= lastReputationCat and data.factionID and (not data.isHeader or data.isChild) then
                    include = not data.isHeader or data.isHeaderWithRep
                end
            end

            if include then
                if data.isHeader and data.isChild then
                    savedHeaderName = name
                elseif not data.isChild then
                    savedHeaderName = ""
                end

                data.savedHeaderName = savedHeaderName
                tinsert(filteredFactionList, data)
            end
        end
    end

    self:SetDataProvider(CreateDataProvider(filteredFactionList), ScrollBoxConstants.RetainScrollPosition)
end

local function showHeader(firstIndex, lastIndex)
    firstReputationCat = firstIndex
    lastReputationCat = lastIndex
end
GW.AddForProfiling("reputation", "showHeader", showHeader)

local function detailsAtwar_OnEnter(self)
    self.icon:SetTexCoord(0.5, 1, 0, 0.5)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(REPUTATION_AT_WAR_DESCRIPTION, nil, nil, nil, nil, true)
    GameTooltip:Show()
end
GW.AddForProfiling("reputation", "detailsAtwar_OnEnter", detailsAtwar_OnEnter)

local function detailsAtwar_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end
    GameTooltip:Hide()
end
GW.AddForProfiling("reputation", "detailsAtwar_OnLeave", detailsAtwar_OnLeave)

local function detailsInactive_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(REPUTATION_MOVE_TO_INACTIVE, nil, nil, nil, nil, true)
    GameTooltip:Show()
end
GW.AddForProfiling("reputation", "detailsInactive_OnEnter", detailsInactive_OnEnter)

local function detailsShowAsBar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(REPUTATION_SHOW_AS_XP, nil, nil, nil, nil, true)
    GameTooltip:Show()
end
GW.AddForProfiling("reputation", "detailsShowAsBar_OnEnter", detailsShowAsBar_OnEnter)

local function detailsControls_OnShow(self)
    self:GetParent().details:Show()
    self:GetParent().detailsbg:Show()

    if self.atwar.isShowAble then
        self.atwar:Show()
    else
        self.atwar:Hide()
    end

    if self.inactive.isShowAble then
        self.inactive:Show()
    else
        self.inactive:Hide()
    end
end
GW.AddForProfiling("reputation", "detailsControls_OnShow", detailsControls_OnShow)

local function detailsControls_OnHide(self)
    self:GetParent().details:Hide()
    self:GetParent().detailsbg:Hide()
end
GW.AddForProfiling("reputation", "detailsControls_OnHide", detailsControls_OnHide)

local function ToggleDetailsButton(self, showDetails)
    self:SetHeight(showDetails and  DETAIL_LG_H or DETAIL_H)
    self.controles:SetShown(showDetails)
    if showDetails then
        self.repbg:SetTexCoord(unpack(GW.TexCoords))
    else
        self.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
    end
    self.repbg:SetDesaturated(not showDetails)
end
GW.AddForProfiling("reputation", "ToggleDetailsButton", ToggleDetailsButton)

local function ToggleDetails(self)
    if not self then return end
    g_selectionBehavior:ToggleSelect(self)

    if g_selectionBehavior:IsSelected(self) then
        ToggleDetailsButton(self, true)
    else
        ToggleDetailsButton(self, false)
    end
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
    frame.details:SetText(data.desc)

    if data.atWarWith then
        frame.controles.atwar.isActive = true
        frame.controles.atwar.icon:SetTexCoord(0.5, 1, 0, 0.5)
    else
        frame.controles.atwar.isActive = false
        frame.controles.atwar.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end

    frame.controles.atwar.isShowAble = data.canToggleAtWar
    frame.controles.showAsBar.checkbutton:SetChecked(data.isWatched)

    frame.controles.inactive.isShowAble = data.canSetInactive
    frame.controles.inactive.checkbutton:SetChecked(not C_Reputation.IsFactionActive(data.factionIndex))
    frame.controles.inactive:SetScript(
        "OnClick",
        function()
            local shouldBeActive = not C_Reputation.IsFactionActive(data.factionIndex)
            C_Reputation.SetFactionActive(data.factionIndex, shouldBeActive)

            UpdateCategories(categoriesScrollBox)
            isSearchResult = nil
            UpdateDetailsData(GwRepDetailFrame.Details)
            local firstCategory = GwPaperReputation.Categories:Find(1)
            if firstCategory then
                showHeader(firstCategory.data.idx, firstCategory.data.idxLast)
                isSearchResult = nil
                UpdateDetailsData(GwRepDetailFrame.Details)
            end
        end
    )

    frame.controles.inactive.checkbutton:SetScript(
        "OnClick",
        function()
            local shouldBeActive = not C_Reputation.IsFactionActive(data.factionIndex)
            C_Reputation.SetFactionActive(data.factionIndex, shouldBeActive)

            UpdateCategories(categoriesScrollBox)
            isSearchResult = nil
            UpdateDetailsData(GwRepDetailFrame.Details)
            local firstCategory = GwPaperReputation.Categories:Find(1)
            if firstCategory then
                showHeader(firstCategory.data.idx, firstCategory.data.idxLast)
                isSearchResult = nil
                UpdateDetailsData(GwRepDetailFrame.Details)
            end
        end
    )

    frame.controles.atwar:SetScript(
        "OnClick",
        function()
            C_Reputation.ToggleFactionAtWar(data.factionIndex)
            if data.canToggleAtWar then
                isSearchResult = nil
                UpdateDetailsData(GwRepDetailFrame.Details)
            end
        end
    )

    frame.controles.showAsBar:SetScript(
        "OnClick",
        function()
            if data.isWatched then
                C_Reputation.SetWatchedFactionByIndex(0)
            else
                C_Reputation.SetWatchedFactionByIndex(data.factionIndex)
            end
        end
    )
    frame.controles.showAsBar.checkbutton:SetScript(
        "OnClick",
        function()
            if data.isWatched then
                C_Reputation.SetWatchedFactionByIndex(0)
            else
                C_Reputation.SetWatchedFactionByIndex(data.factionIndex)
            end
        end
    )

    frame.accountWide:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, 1, 1, 1)
        GameTooltip:Show()
    end)
    frame.accountWide:SetScript("OnLeave", GameTooltip_Hide)

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

        frame.name:SetText(hasRewardPending and data.name .. "|TInterface/AddOns/GW2_UI/textures/icons/rewards-icon:32:32:0:0|t" or data.name)

        frame.currentRank:SetText(friendInfo.friendshipFactionID and friendInfo.reaction or currentRank)
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

        frame.background2:SetVertexColor(
            FACTION_BAR_COLORS[data.reaction].r,
            FACTION_BAR_COLORS[data.reaction].g,
            FACTION_BAR_COLORS[data.reaction].b
        )
        frame.StatusBar:SetStatusBarColor(
            FACTION_BAR_COLORS[data.reaction].r,
            FACTION_BAR_COLORS[data.reaction].g,
            FACTION_BAR_COLORS[data.reaction].b
        )
    end
end

local function status_SetValue(self)
    local _, max = self:GetMinMaxValues()
    local v = self:GetValue()
    local width = math.max(1, math.min(10, 10 * ((v / max) / 0.1)))
    if v == max then
        self.spark:Hide()
    else
        self.spark:SetPoint("RIGHT", self, "LEFT", self:GetWidth() * (v / max), 0)
        self.spark:SetWidth(width)
        self.spark:Show()
    end
end
GW.AddForProfiling("reputation", "status_SetValue", status_SetValue)

local function InitDetailsButton(button, elementData)
    if not button.isSkinned then
        button.controles.atwar:SetScript("OnEnter", detailsAtwar_OnEnter)
        button.controles.atwar:SetScript("OnLeave", detailsAtwar_OnLeave)
        button.controles.inactive:SetScript("OnEnter", detailsInactive_OnEnter)
        button.controles.inactive:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.inactive.checkbutton:SetScript("OnEnter", detailsInactive_OnEnter)
        button.controles.inactive.checkbutton:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.showAsBar:SetScript("OnEnter", detailsShowAsBar_OnEnter)
        button.controles.showAsBar:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.showAsBar.checkbutton:SetScript("OnEnter", detailsShowAsBar_OnEnter)
        button.controles.showAsBar.checkbutton:SetScript("OnLeave", GameTooltip_Hide)
        button.controles.inactive.string:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.controles.inactive.string:SetText(FACTION_INACTIVE)
        button.controles.inactive:SetWidth(button.controles.inactive.string:GetWidth())
        button.controles.showAsBar.string:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.controles.showAsBar.string:SetText(SHOW_FACTION_ON_MAINSCREEN)
        button.controles.showAsBar:SetWidth(button.controles.showAsBar.string:GetWidth())
        button.controles:SetScript("OnShow", detailsControls_OnShow)
        button.controles:SetScript("OnHide", detailsControls_OnHide)
        button.StatusBar.currentValue:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.StatusBar.percentage:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.StatusBar.nextValue:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)

        button.StatusBar.currentValue:SetShadowColor(0, 0, 0, 1)
        button.StatusBar.percentage:SetShadowColor(0, 0, 0, 1)
        button.StatusBar.nextValue:SetShadowColor(0, 0, 0, 1)

        button.StatusBar.currentValue:SetShadowOffset(1, -1)
        button.StatusBar.percentage:SetShadowOffset(1, -1)
        button.StatusBar.nextValue:SetShadowOffset(1, -1)

        button.StatusBar:GetParent().currentValue = button.StatusBar.currentValue
        button.StatusBar:GetParent().percentage = button.StatusBar.percentage
        button.StatusBar:GetParent().nextValue = button.StatusBar.nextValue
        button.StatusBar:SetMinMaxValues(0, 1)
        button.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
        hooksecurefunc(button.StatusBar, "SetValue", status_SetValue)
        button.details:SetPoint("TOPLEFT", button.StatusBar, "BOTTOMLEFT", 0, -25)
        button.statusbarbg:SetPoint("TOPLEFT", button.StatusBar, "TOPLEFT", -2, 2)
        button.statusbarbg:SetPoint("BOTTOMRIGHT", button.StatusBar, "BOTTOMRIGHT", 2, -2)
        button.currentRank:SetPoint("TOPLEFT", button.StatusBar, "BOTTOMLEFT", 0, -5)
        button.nextRank:SetPoint("TOPRIGHT", button.StatusBar, "BOTTOMRIGHT", 0, -5)

        button.currentRank:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.currentRank:SetTextColor(0.6, 0.6, 0.6)
        button.currentRank:SetShadowColor(0, 0, 0, 1)
        button.currentRank:SetShadowOffset(1, -1)

        button.nextRank:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.nextRank:SetTextColor(0.6, 0.6, 0.6)
        button.nextRank:SetShadowColor(0, 0, 0, 1)
        button.nextRank:SetShadowOffset(1, -1)

        button.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        button.name:SetTextColor(1, 1, 1, 1)
        button.name:SetShadowColor(0, 0, 0, 1)
        button.name:SetShadowOffset(1, -1)

        button.details:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.details:SetTextColor(0.8, 0.8, 0.8, 1)
        button.details:SetShadowColor(0, 0, 0, 1)
        button.details:SetShadowOffset(1, -1)
        button.details:Hide()
        button.details:SetWidth(button.StatusBar:GetWidth())
        button.detailsbg:Hide()

        button.currentRank:SetText(REFORGE_CURRENT)
        button.nextRank:SetText(NEXT)
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

        button.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
        button.repbg:SetDesaturated(true)

        button.isSkinned = true
    end
    setReputationDetails(button, elementData)
end

local function InitCategorieButton(button, elementData)
    if not button.isSkinned then
        button.name:SetTextColor(1, 1, 1, 1)
        button.name:SetShadowColor(0, 0, 0, 1)
        button.name:SetShadowOffset(1, -1)
        button.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        button.StatusBar.percentage:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
        button.StatusBar.percentage:SetShadowColor(0, 0, 0, 1)
        button.StatusBar.percentage:SetShadowOffset(1, -1)

        hooksecurefunc(button.StatusBar, "SetValue",
            function(self)
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
            showHeader(self.factionIndexFirst, self.factionIndexLast)
            UpdateCategories(categoriesScrollBox)
            isSearchResult = nil
            UpdateDetailsData(GwRepDetailFrame.Details)
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
        button.paragonIndicator.animationGroup1:SetScript("OnFinished", function(self)
            self:Play()
        end)
        button.paragonIndicator.animationGroup2:SetScript("OnFinished", function(self)
            self:Play()
        end)

        button.isSkinned = true
    end
    button.factionIndexFirst = elementData.data.idx
    button.factionIndexLast = elementData.data.idxLast
    button.standings = elementData.data.fctTbl
    button.pendingParagonRewardFactions = elementData.data.pendingParagonRewardFactions

    button.name:SetText(elementData.data.name)
    if elementData.data.name ~= COVENANT_SANCTUM_TIER_INACTIVE and elementData.data.standingCur and elementData.data.standingCur > 0 and elementData.data.standingMax and elementData.data.standingMax > 0 then
        button.StatusBar:SetValue(elementData.data.standingCur / elementData.data.standingMax)
        button.StatusBar.percentage:SetText(math.floor(RoundDec(button.StatusBar:GetValue() * 100)) .. "%")
        if elementData.data.standingCur / elementData.data.standingMax >= 1 and elementData.data.standingMax ~= 0 then
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
    button.paragonIndicator:Hide()
    button.flareIcon.animationGroup1:Stop()
    button.flareIcon.animationGroup2:Stop()
    if GwPaperReputation:IsShown() then
        if elementData.data.hasPendingParagonReward then
            button.paragonIndicator:Show()
            button.flareIcon.animationGroup1:Play()
            button.flareIcon.animationGroup2:Play()
        end
    end

    -- set zebra color by idx or watch status
    local zebra = elementData.index % 2
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

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwPaperDollReputationCat", function(button, elementData)
        InitCategorieButton(button, elementData)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(fmGPR.Categories, fmGPR.ScrollBar, view)
    GW.HandleTrimScrollBar(fmGPR.ScrollBar)
    GW.HandleScrollControls(fmGPR)
    fmGPR.ScrollBar:SetHideIfUnscrollable(true)
    categoriesScrollBox = fmGPR.Categories

    fmGPR.Categories.detailFrames = 0
    fmGPR.Categories:RegisterEvent("UPDATE_FACTION")
    fmGPR.Categories:RegisterEvent("QUEST_LOG_UPDATE")
    fmGPR.Categories:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    fmGPR.Categories:RegisterEvent("MAJOR_FACTION_UNLOCKED")
    local fnGPR_OnEvent = function(_, event)
        if not GW.inWorld then
            return
        end
        if not updateQueued then
            updateQueued = true
            C_Timer.After(1, function()
                isSearchResult = nil
                UpdateDetailsData(GwRepDetailFrame.Details)
                GW.Debug("Reputation", event)
                updateQueued = false
            end)
        end
    end
    fmGPR.Categories:SetScript("OnEvent", fnGPR_OnEvent)
    SetSearchboxInstructions(fmGPR.input, SEARCH .. "...")
    fmGPR.input:SetText("")
    fmGPR.input:SetScript("OnEnterPressed", nil)
    local fnGPR_input_OnTextChanged = function(self)
        local text = self:GetText()
        if text == "" then
            isSearchResult = nil
            UpdateDetailsData(GwRepDetailFrame.Details)
            self.clearButton:Hide()
            return
        end
        isSearchResult = text
        UpdateDetailsData(GwRepDetailFrame.Details)
        self.clearButton:Show()
    end
    fmGPR.input:HookScript("OnTextChanged", fnGPR_input_OnTextChanged)
    local fnGPR_input_OnEscapePressed = function(self)
        self:ClearFocus()
        self:SetText("")
        isSearchResult = nil
        UpdateDetailsData(GwRepDetailFrame.Details)
    end
    fmGPR.input:SetScript("OnEscapePressed", fnGPR_input_OnEscapePressed)
    local fnGPR_input_OnEditFocusGained = function(self)
        self.clearButton:Show()
    end
    fmGPR.input:SetScript("OnEditFocusGained", fnGPR_input_OnEditFocusGained)
    local fnGPR_input_OnEditFocusLost = function(self)
        if self:GetText() == "" then
            self.clearButton:Hide()
        end
    end
    fmGPR.input:SetScript("OnEditFocusLost", fnGPR_input_OnEditFocusLost)
    fmGPR.input.clearButton:SetScript("OnClick", function(self)
        self:GetParent():ClearFocus()
        self:GetParent():SetText("")
        isSearchResult = nil
        UpdateDetailsData(GwRepDetailFrame.Details)
    end)

    local fmDetail = CreateFrame("Frame", "GwRepDetailFrame", tabContainer, "GwRepDetailFrame")

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

    UpdateCategories(categoriesScrollBox)
    UpdateDetailsData(fmDetail.Details)

    local firstCategory = fmGPR.Categories:Find(1)
    if firstCategory then
        showHeader(firstCategory.data.idx, firstCategory.data.idxLast)
        isSearchResult = nil
        UpdateDetailsData(GwRepDetailFrame.Details)
    end

    ReputationFrame:UnregisterAllEvents()

    GwPaperReputation:HookScript("OnShow", function()
        UpdateCategories(categoriesScrollBox)
        isSearchResult = nil
        UpdateDetailsData(GwRepDetailFrame.Details)
    end)
    GwPaperReputation:HookScript("OnHide", function()
        UpdateCategories(categoriesScrollBox)
    end)
end
GW.LoadReputation = LoadReputation
