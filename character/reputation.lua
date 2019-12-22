local _, GW = ...
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local CharacterMenuBlank_OnLoad = GW.CharacterMenuBlank_OnLoad
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS
local RT = GW.REP_TEXTURES

-- forward function defs
local updateOldData
local updateReputations
local updateDetails

local gender = UnitSex("player")
local savedReputation = {}
local selectedReputationCat = 1
local reputationLastUpdateMethod = nil
local reputationLastUpdateMethodParams = nil
local INIT_Y = 2
local OFF_Y = 10
local DETAIL_H = 65
local DETAIL_LG_H = (DETAIL_H * 2) + OFF_Y
--local REPBG_T = 0.27
--local REPBG_B = 0.73
local REPBG_T = 0
local REPBG_B = 0.464

local expandedFactions = {}

local function detailFaction(factionIndex, boolean)
    if boolean then
        expandedFactions[factionIndex] = true
        return
    end
    expandedFactions[factionIndex] = nil
end
GW.AddForProfiling("reputation", "detailFaction", detailFaction)

local function getNewCategory(i)
    if _G["GwPaperDollReputationCat" .. i] ~= nil then
        return _G["GwPaperDollReputationCat" .. i]
    end

    local f =
        CreateFrame("Button", "GwPaperDollReputationCat" .. i, GwPaperReputation.categories, "GwPaperDollReputationCat")
    CharacterMenuBlank_OnLoad(f)
    f.StatusBar:SetMinMaxValues(0, 1)
    f.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
    local BNAME = f.StatusBar:GetName()
    hooksecurefunc(
        f.StatusBar,
        "SetValue",
        function(self)
            local _, max = self:GetMinMaxValues()
            local v = self:GetValue()
            local width = math.max(1, math.min(10, 10 * ((v / max) / 0.1)))
            if v == max then
                _G[BNAME .. "Spark"]:Hide()
            else
                _G[BNAME .. "Spark"]:SetPoint("RIGHT", self, "LEFT", 201 * (v / max), 0)
                _G[BNAME .. "Spark"]:SetWidth(width)
                _G[BNAME .. "Spark"]:Show()
            end
        end
    )

    if i > 1 then
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollReputationCat" .. (i - 1)], "BOTTOMLEFT")
    else
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", GwPaperReputation.categories, "TOPLEFT")
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint("TOPLEFT", 10, -10)
    GwPaperReputation.categories.buttons = GwPaperReputation.categories.buttons + 1

    return f
end
GW.AddForProfiling("reputation", "getNewCategory", getNewCategory)

local function updateSavedReputation()
    for factionIndex = GwPaperReputation.categories.scroll, GetNumFactions() do
        savedReputation[factionIndex] = {}
        savedReputation[factionIndex].name,
            savedReputation[factionIndex].description,
            savedReputation[factionIndex].standingId,
            savedReputation[factionIndex].bottomValue,
            savedReputation[factionIndex].topValue,
            savedReputation[factionIndex].earnedValue,
            savedReputation[factionIndex].atWarWith,
            savedReputation[factionIndex].canToggleAtWar,
            savedReputation[factionIndex].isHeader,
            savedReputation[factionIndex].isCollapsed,
            savedReputation[factionIndex].hasRep,
            savedReputation[factionIndex].isWatched,
            savedReputation[factionIndex].isChild,
            savedReputation[factionIndex].factionID,
            savedReputation[factionIndex].hasBonusRepGain,
            savedReputation[factionIndex].canBeLFGBonus = GetFactionInfo(factionIndex)
    end
end
GW.AddForProfiling("reputation", "updateSavedReputation", updateSavedReputation)

local function returnReputationData(factionIndex)
    if savedReputation[factionIndex] == nil then
        return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    return savedReputation[factionIndex].name, savedReputation[factionIndex].description, savedReputation[factionIndex].standingId, savedReputation[
        factionIndex
    ].bottomValue, savedReputation[factionIndex].topValue, savedReputation[factionIndex].earnedValue, savedReputation[
        factionIndex
    ].atWarWith, savedReputation[factionIndex].canToggleAtWar, savedReputation[factionIndex].isHeader, savedReputation[
        factionIndex
    ].isCollapsed, savedReputation[factionIndex].hasRep, savedReputation[factionIndex].isWatched, savedReputation[
        factionIndex
    ].isChild, savedReputation[factionIndex].factionID, savedReputation[factionIndex].hasBonusRepGain, savedReputation[
        factionIndex
    ].canBeLFGBonus
end
GW.AddForProfiling("reputation", "returnReputationData", returnReputationData)

local function showHeader(i)
    selectedReputationCat = i
end
GW.AddForProfiling("reputation", "showHeader", showHeader)

local function detailsAtwar_OnEnter(self)
    self.icon:SetTexCoord(0.5, 1, 0, 0.5)
end
GW.AddForProfiling("reputation", "detailsAtwar_OnEnter", detailsAtwar_OnEnter)

local function detailsAtwar_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end
end
GW.AddForProfiling("reputation", "detailsAtwar_OnLeave", detailsAtwar_OnLeave)

local function detailsFavorite_OnEnter(self)
    self.icon:SetTexCoord(0, 0.5, 0.5, 1)
end
GW.AddForProfiling("reputation", "detailsFavorite_OnEnter", detailsFavorite_OnEnter)

local function detailsFavorite_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0.5, 1, 0.5, 1)
    end
end
GW.AddForProfiling("reputation", "detailsFavorite_OnLeave", detailsFavorite_OnLeave)

local function detailsControls_OnShow(self)
    self:GetParent().details:Show()
    self:GetParent().detailsbg:Show()

    if self.atwar.isShowAble then
        self.atwar:Show()
    else
        self.atwar:Hide()
    end
    if self.favorit.isShowAble then
        self.favorit:Show()
    else
        self.favorit:Hide()
    end
end
GW.AddForProfiling("reputation", "detailsControls_OnShow", detailsControls_OnShow)

local function detailsControls_OnHide(self)
    self:GetParent().details:Hide()
    self:GetParent().detailsbg:Hide()
end
GW.AddForProfiling("reputation", "detailsControls_OnHide", detailsControls_OnHide)

local function details_OnClick(self, button)
    if self.item.details:IsShown() then
        detailFaction(self.item.factionID, false)
        self:SetHeight(DETAIL_H)
        self.item.controles:Hide()
        self.item.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
        self.item.repbg:SetDesaturated(true)
    else
        detailFaction(self.item.factionID, true)
        self:SetHeight(DETAIL_LG_H)
        self.item.controles:Show()
        self.item.repbg:SetTexCoord(0, 1, 0, 1)
        self.item.repbg:SetDesaturated(false)
    end
    updateOldData()
end
GW.AddForProfiling("reputation", "details_OnClick", details_OnClick)

local function setDetailEx(
    frame,
    factionIndex,
    savedHeaderName,
    name,
    description,
    standingId,
    bottomValue,
    topValue,
    earnedValue,
    atWarWith,
    canToggleAtWar,
    isHeader,
    isCollapsed,
    hasRep,
    isWatched,
    isChild,
    factionID,
    hasBonusRepGain,
    canBeLFGBonus)
    frame:Show()

    frame.factionIndex = factionIndex
    frame.factionID = factionID

    local isExpanded = false
    if expandedFactions[factionID] == nil then
        frame.controles:Hide()
        frame:GetParent():SetHeight(DETAIL_H)
    else
        frame:GetParent():SetHeight(DETAIL_LG_H)
        frame.controles:Show()
        isExpanded = true
    end

    local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), gender)
    local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), gender)
    local friendID, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold =
        GetFriendshipReputation(factionID)

    --if factionIndex % 2 == 0 then
    frame.background:SetTexture(nil)
    --else
    --frame.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    --end

    if savedHeaderName ~= nil and savedHeaderName ~= "" and savedHeaderName ~= name then
        frame.name:SetText(name .. "  |cFFa0a0a0" .. savedHeaderName .. "|r")
    else
        frame.name:SetText(name)
    end
    frame.details:SetText(description)

    if atWarWith then
        frame.controles.atwar.isActive = true
        frame.controles.atwar.icon:SetTexCoord(0.5, 1, 0, 0.5)
    else
        frame.controles.atwar.isActive = false
        frame.controles.atwar.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end

    if canToggleAtWar then
        frame.controles.atwar.isShowAble = true
    else
        frame.controles.atwar.isShowAble = false
    end

    if isWatched then
        frame.controles.showAsBar:SetChecked(true)
    else
        frame.controles.showAsBar:SetChecked(false)
    end

    if IsFactionInactive(factionIndex) then
        frame.controles.inactive:SetChecked(true)
    else
        frame.controles.inactive:SetChecked(false)
    end

    frame.controles.inactive:SetScript(
        "OnClick",
        function()
            if IsFactionInactive(factionIndex) then
                SetFactionActive(factionIndex)
            else
                SetFactionInactive(factionIndex)
            end
            updateSavedReputation()
            updateReputations()
            updateOldData()
        end
    )

    if canBeLFGBonus then
        frame.controles.favorit.isShowAble = true
        frame.controles.favorit:SetScript(
            "OnClick",
            function()
                ReputationBar_SetLFBonus(factionID)
                updateSavedReputation()
                updateOldData()
            end
        )
    else
        frame.controles.favorit.isShowAble = false
    end

    frame.controles.atwar:SetScript(
        "OnClick",
        function()
            FactionToggleAtWar(factionIndex)
            if canToggleAtWar then
                updateSavedReputation()
                updateOldData()
            end
        end
    )

    frame.controles.showAsBar:SetScript(
        "OnClick",
        function()
            if isWatched then
                SetWatchedFactionIndex(0)
            else
                SetWatchedFactionIndex(factionIndex)
            end
            updateSavedReputation()
            updateOldData()
        end
    )

    SetFactionInactive(GetSelectedFaction())

    if factionID and RT[factionID] then
        frame.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/rep/" .. RT[factionID])
        if isExpanded then
            frame.repbg:SetTexCoord(0, 1, 0, 1)
            frame.repbg:SetAlpha(0.85)
            frame.repbg:SetDesaturated(false)
        else
            frame.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
            frame.repbg:SetAlpha(0.33)
            frame.repbg:SetDesaturated(true)
        end
    else
        GW.Debug("no faction", name, factionID)
        frame.repbg:SetAlpha(0)
    end

    if factionID and C_Reputation.IsFactionParagon(factionID) then
        local currentValue, maxValueParagon, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)

        if currentValue > 10000 then
            repeat
                currentValue = currentValue - 10000
            until (currentValue < 10000)
        end

        if hasRewardPending then 
            local nameReward = name .. "|TInterface\\AddOns\\GW2_UI\\textures\\rewards-icon:32:32:0:0|t"
            frame.name:SetText(nameReward)
        else
            frame.name:SetText(name)
        end

        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(GwLocalization["CHARACTER_PARAGON"])

        frame.currentValue:SetText(CommaValue(currentValue))
        frame.nextValue:SetText(CommaValue(maxValueParagon))

        local percent = math.floor(RoundDec(((currentValue - 0) / (maxValueParagon - 0)) * 100), 0)
        frame.percentage:SetText(percent .. "%")

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((currentValue - 0) / (maxValueParagon - 0))

        frame.background2:SetVertexColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
        frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
    elseif (friendID ~= nil) then
        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.currentRank:SetText(friendTextLevel)
        frame.nextRank:SetText()

        frame.background2:SetVertexColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
        frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)

        if (nextFriendThreshold) then
            frame.currentValue:SetText(CommaValue(friendRep - friendThreshold))
            frame.nextValue:SetText(CommaValue(nextFriendThreshold - friendThreshold))

            local percent =
                math.floor(RoundDec(((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)) * 100), 0)
            if percent == -1 then
                frame.percentage:SetText("0%")
            else
                frame.percentage:SetText(
                    (math.floor(
                        RoundDec(((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)) * 100),
                        0
                    )) .. "%"
                )
            end

            frame.StatusBar:SetValue((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold))
        else
            --max rank
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
            frame.percentage:SetText("100%")
        end
    else
        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(nextRank)
        frame.currentValue:SetText(CommaValue(earnedValue - bottomValue))
        local ldiff = topValue - bottomValue
        if ldiff == 0 then
            ldiff = 1
        end
        local percent = math.floor(RoundDec(((earnedValue - bottomValue) / ldiff) * 100), 0)
        if percent == -1 then
            frame.percentage:SetText("0%")
        else
            frame.percentage:SetText(percent .. "%")
        end

        frame.nextValue:SetText(CommaValue(ldiff))

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((earnedValue - bottomValue) / ldiff)

        if currentRank == nextRank and earnedValue - bottomValue == 0 then
            frame.percentage:SetText("100%")
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
        end

        frame.background2:SetVertexColor(
            FACTION_BAR_COLORS[standingId].r,
            FACTION_BAR_COLORS[standingId].g,
            FACTION_BAR_COLORS[standingId].b
        )
        frame.StatusBar:SetStatusBarColor(
            FACTION_BAR_COLORS[standingId].r,
            FACTION_BAR_COLORS[standingId].g,
            FACTION_BAR_COLORS[standingId].b
        )
    end
end
GW.AddForProfiling("reputation", "setDetailEx", setDetailEx)

local function setDetail(frame, dat)
    return setDetailEx(
        frame,
        dat.factionIndex,
        dat.savedHeaderName,
        dat.name,
        dat.desc,
        dat.standingId,
        dat.bottomValue,
        dat.topValue,
        dat.earnedValue,
        dat.atWarWith,
        dat.canToggleAtWar,
        dat.isHeader,
        dat.isCollapsed,
        dat.hasRep,
        dat.isWatched,
        dat.isChild,
        dat.factionID,
        dat.hasBonusRepGain,
        dat.canBeLFGBonus
    )
end
GW.AddForProfiling("reputation", "setDetail", setDetail)

local facData = {}
local facOrder = {}
updateDetails = function()
    local fm = GwRepDetailFrame.scroller

    local offset = HybridScrollFrame_GetOffset(fm)
    local repCount = 0
    local expCount = 0

    -- clean up facData table (re-use instead of reallocate to prevent mem bloat)
    for k, v in pairs(facData) do
        v.loaded = false
    end
    table.wipe(facOrder)

    -- run through factions to get data and total count for the selected category
    local savedHeaderName = ""
    for idx = selectedReputationCat + 1, GetNumFactions() do
        local name,
            desc,
            standingId,
            bottomValue,
            topValue,
            earnedValue,
            atWarWith,
            canToggleAtWar,
            isHeader,
            isCollapsed,
            hasRep,
            isWatched,
            isChild,
            factionID,
            hasBonusRepGain,
            canBeLFGBonus = returnReputationData(idx)

        if isHeader and not isChild then
            break
        end

        repCount = repCount + 1
        if expandedFactions[factionID] then
            expCount = expCount + 1
        end

        if isHeader and isChild then
            savedHeaderName = name
        end

        if not isChild then
            savedHeaderName = ""
        end

        if not facData[factionID] then
            facData[factionID] = {}
        end
        facOrder[#facOrder + 1] = factionID
        facData[factionID].loaded = true
        facData[factionID].factionIndex = idx
        facData[factionID].name = name
        facData[factionID].desc = desc
        facData[factionID].standingId = standingId
        facData[factionID].bottomValue = bottomValue
        facData[factionID].topValue = topValue
        facData[factionID].earnedValue = earnedValue
        facData[factionID].atWarWith = atWarWith
        facData[factionID].canToggleAtWar = canToggleAtWar
        facData[factionID].isHeader = isHeader
        facData[factionID].isCollapsed = isCollapsed
        facData[factionID].hasRep = hasRep
        facData[factionID].isWatched = isWatched
        facData[factionID].isChild = isChild
        facData[factionID].factionID = factionID
        facData[factionID].hasBonusRepGain = hasBonusRepGain
        facData[factionID].canBeLFGBonus = canBeLFGBonus
        facData[factionID].savedHeaderName = savedHeaderName
    end

    -- run through hybridscroll buttons, setting appropriate faction data by offset & index
    for i = 1, #fm.buttons do
        local idx = i + offset
        local factionID = facOrder[idx]
        local slot = fm.buttons[i].item

        if idx > repCount or not factionID or not facData[factionID] or not facData[factionID].loaded then
            -- this is an empty/not used button
            slot:Hide()
        else
            setDetail(slot, facData[factionID])
        end
    end

    local used_detail_height = (repCount * (DETAIL_H + OFF_Y)) + (expCount * (DETAIL_H + OFF_Y))
    HybridScrollFrame_Update(fm, used_detail_height, 576)

    reputationLastUpdateMethod = updateDetails
end
GW.AddForProfiling("reputation", "updateDetails", updateDetails)

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

local function setupDetail(self)
    self.controles.atwar:SetScript("OnEnter", detailsAtwar_OnEnter)
    self.controles.atwar:SetScript("OnLeave", detailsAtwar_OnLeave)
    self.controles.favorit:SetScript("OnEnter", detailsFavorite_OnEnter)
    self.controles.favorit:SetScript("OnLeave", detailsFavorite_OnLeave)
    self.controles.inactive.string:SetFont(UNIT_NAME_FONT, 12)
    self.controles.inactive.string:SetText(FACTION_INACTIVE)
    self.controles.showAsBar.string:SetFont(UNIT_NAME_FONT, 12)
    self.controles.showAsBar.string:SetText(GwLocalization["CHARACTER_REPUTATION_TRACK"])
    self.controles:SetScript("OnShow", detailsControls_OnShow)
    self.controles:SetScript("OnHide", detailsControls_OnHide)
    self.StatusBar.currentValue:SetFont(UNIT_NAME_FONT, 12)
    self.StatusBar.percentage:SetFont(UNIT_NAME_FONT, 12)
    self.StatusBar.nextValue:SetFont(UNIT_NAME_FONT, 12)

    self.StatusBar.currentValue:SetShadowColor(0, 0, 0, 1)
    self.StatusBar.percentage:SetShadowColor(0, 0, 0, 1)
    self.StatusBar.nextValue:SetShadowColor(0, 0, 0, 1)

    self.StatusBar.currentValue:SetShadowOffset(1, -1)
    self.StatusBar.percentage:SetShadowOffset(1, -1)
    self.StatusBar.nextValue:SetShadowOffset(1, -1)

    self.StatusBar:GetParent().currentValue = self.StatusBar.currentValue
    self.StatusBar:GetParent().percentage = self.StatusBar.percentage
    self.StatusBar:GetParent().nextValue = self.StatusBar.nextValue
    self.StatusBar:SetMinMaxValues(0, 1)
    self.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
    hooksecurefunc(self.StatusBar, "SetValue", status_SetValue)
    self.details:SetPoint("TOPLEFT", self.StatusBar, "BOTTOMLEFT", 0, -25)
    self.statusbarbg:SetPoint("TOPLEFT", self.StatusBar, "TOPLEFT", -2, 2)
    self.statusbarbg:SetPoint("BOTTOMRIGHT", self.StatusBar, "BOTTOMRIGHT", 2, -2)
    self.currentRank:SetPoint("TOPLEFT", self.StatusBar, "BOTTOMLEFT", 0, -5)
    self.nextRank:SetPoint("TOPRIGHT", self.StatusBar, "BOTTOMRIGHT", 0, -5)

    self.currentRank:SetFont(DAMAGE_TEXT_FONT, 11)
    self.currentRank:SetTextColor(0.6, 0.6, 0.6)
    self.currentRank:SetShadowColor(0, 0, 0, 1)
    self.currentRank:SetShadowOffset(1, -1)

    self.nextRank:SetFont(DAMAGE_TEXT_FONT, 11)
    self.nextRank:SetTextColor(0.6, 0.6, 0.6)
    self.nextRank:SetShadowColor(0, 0, 0, 1)
    self.nextRank:SetShadowOffset(1, -1)
    
    self.name:SetFont(DAMAGE_TEXT_FONT, 14)
    self.name:SetTextColor(1, 1, 1, 1)
    self.name:SetShadowColor(0, 0, 0, 1)
    self.name:SetShadowOffset(1, -1)

    self.details:SetFont(UNIT_NAME_FONT, 12)
    self.details:SetTextColor(0.8, 0.8, 0.8, 1)
    self.details:SetShadowColor(0, 0, 0, 1)
    self.details:SetShadowOffset(1, -1)
    self.details:Hide()
    self.details:SetWidth(self.StatusBar:GetWidth())
    self.detailsbg:Hide()

    self.currentRank:SetText(REFORGE_CURRENT)
    self.nextRank:SetText(GwLocalization["CHARACTER_NEXT_RANK"])
    self:GetParent():SetScript("OnClick", details_OnClick)

    self.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
    self.repbg:SetDesaturated(true)
end
GW.AddForProfiling("reputation", "setupDetail", setupDetail)

local function reputationSetup(self)
    HybridScrollFrame_CreateButtons(
        self,
        "GwReputationDetails",
        12,
        -INIT_Y,
        "TOPLEFT",
        "TOPLEFT",
        0,
        -OFF_Y,
        "TOP",
        "BOTTOM"
    )
    for i = 1, #self.buttons do
        local slot = self.buttons[i]
        slot:SetWidth(self:GetWidth() - 18)
        slot.item:Hide()
        setupDetail(slot.item)
    end

    updateDetails()
end
GW.AddForProfiling("reputation", "reputationSetup", reputationSetup)

updateReputations = function()
    ExpandAllFactionHeaders()

    local headerIndex = 1
    local CurrentOwner = nil
    local cMax = 0
    local cCur = 0
    local textureC = 1

    for factionIndex = GwPaperReputation.categories.scroll, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, isHeader, _, _, _, isChild, factionID =
            returnReputationData(factionIndex)
        local friendID = GetFriendshipReputation(factionID)
        if name ~= nil then
            cCur = cCur + standingId
            if friendID ~= nil then
                cMax = cMax + 7
            else
                cMax = cMax + 8
            end

            if isHeader and not isChild then
                local header = getNewCategory(headerIndex)
                header:Show()
                CurrentOwner = header
                header:SetText(name)

                if CurrentOwner ~= nil then
                    CurrentOwner.StatusBar:SetValue(cCur / cMax)
                end

                cCur = 0
                cMax = 0

                headerIndex = headerIndex + 1

                header:SetScript(
                    "OnClick",
                    function()
                        updateSavedReputation()
                        showHeader(factionIndex)
                        updateDetails()
                    end
                )

                if textureC == 1 then
                    header:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                    textureC = 2
                else
                    header:SetNormalTexture(nil)
                    textureC = 1
                end
            end
        end

        if CurrentOwner ~= nil then
            if cMax ~= 0 and cMax ~= nil then
                CurrentOwner.StatusBar:SetValue(cCur / cMax)
                if cCur / cMax >= 1 and cMax ~= 0 then
                    CurrentOwner.StatusBar:SetStatusBarColor(171 / 255, 37 / 255, 240 / 255)
                else
                    CurrentOwner.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
                end
            end
        end
    end

    for i = headerIndex, GwPaperReputation.categories.buttons do
        _G["GwPaperDollReputationCat" .. i]:Hide()
    end
end
GW.AddForProfiling("reputation", "updateReputations", updateReputations)

updateOldData = function()
    if reputationLastUpdateMethod ~= nil then
        reputationLastUpdateMethod(reputationLastUpdateMethodParams)
    end
end
GW.AddForProfiling("reputation", "updateOldData", updateOldData)

local function reputationSearch(a, b)
    return string.find(a, b)
end
GW.AddForProfiling("reputation", "reputationSearch", reputationSearch)

local function updateDetailsSearch(s)
    local fm = GwRepDetailFrame.scroller

    local offset = HybridScrollFrame_GetOffset(fm)
    local repCount = 0
    local expCount = 0

    -- clean up facData table (re-use instead of reallocate to prevent mem bloat)
    for k, v in pairs(facData) do
        v.loaded = false
    end
    table.wipe(facOrder)

    -- run through factions to get data and total count for the selected category
    local savedHeaderName = ""
    for idx = 1, GetNumFactions() do
        local name,
            desc,
            standingId,
            bottomValue,
            topValue,
            earnedValue,
            atWarWith,
            canToggleAtWar,
            isHeader,
            isCollapsed,
            hasRep,
            isWatched,
            isChild,
            factionID,
            hasBonusRepGain,
            canBeLFGBonus = returnReputationData(idx)

        local lower1 = string.lower(name)
        local lower2 = string.lower(s)

        if isHeader and not isChild then
            -- skip
        elseif name == nil or reputationSearch(lower1, lower2) == nil then
            -- skip
        else
            repCount = repCount + 1
            if expandedFactions[factionID] then
                expCount = expCount + 1
            end

            if isHeader and isChild then
                savedHeaderName = name
            end

            if not isChild then
                savedHeaderName = ""
            end

            if not facData[factionID] then
                facData[factionID] = {}
            end
            facOrder[#facOrder + 1] = factionID
            facData[factionID].loaded = true
            facData[factionID].factionIndex = idx
            facData[factionID].name = name
            facData[factionID].desc = desc
            facData[factionID].standingId = standingId
            facData[factionID].bottomValue = bottomValue
            facData[factionID].topValue = topValue
            facData[factionID].earnedValue = earnedValue
            facData[factionID].atWarWith = atWarWith
            facData[factionID].canToggleAtWar = canToggleAtWar
            facData[factionID].isHeader = isHeader
            facData[factionID].isCollapsed = isCollapsed
            facData[factionID].hasRep = hasRep
            facData[factionID].isWatched = isWatched
            facData[factionID].isChild = isChild
            facData[factionID].factionID = factionID
            facData[factionID].hasBonusRepGain = hasBonusRepGain
            facData[factionID].canBeLFGBonus = canBeLFGBonus
            facData[factionID].savedHeaderName = savedHeaderName
        end
    end

    -- run through hybridscroll buttons, setting appropriate faction data by offset & index
    for i = 1, #fm.buttons do
        local idx = i + offset
        local factionID = facOrder[idx]
        local slot = fm.buttons[i].item

        if idx > repCount or not factionID or not facData[factionID] or not facData[factionID].loaded then
            -- this is an empty/not used button
            slot:Hide()
        else
            setDetail(slot, facData[factionID])
        end
    end

    local used_detail_height = (repCount * (DETAIL_H + OFF_Y)) + (expCount * (DETAIL_H + OFF_Y))
    HybridScrollFrame_Update(fm, used_detail_height, 576)

    reputationLastUpdateMethod = updateDetailsSearch
    reputationLastUpdateMethodParams = s
end
GW.AddForProfiling("reputation", "updateDetailsSearch", updateDetailsSearch)

local function dynamicOffset(self, offset)
    local heightSoFar = 0
    local element = 0
    local scrollHeight = 0
    for _, factionID in ipairs(facOrder) do
        local v = facData[factionID]
        if v.loaded then
            local nextHeight
            if expandedFactions[v.factionID] then
                nextHeight = DETAIL_LG_H + OFF_Y
            else
                nextHeight = DETAIL_H + OFF_Y
            end
            if (heightSoFar + nextHeight) <= offset then
                element = element + 1
                heightSoFar = heightSoFar + nextHeight
            else
                local diff = math.floor(nextHeight - ((heightSoFar + nextHeight) - offset))
                element = element + (diff / nextHeight)
                scrollHeight = diff
                break
            end
        end
    end

    return element, scrollHeight
end
GW.AddForProfiling("reputation", "dynamicOffset", dynamicOffset)

local function LoadReputation(tabContainer)
    local fmGPR = CreateFrame("Frame", "GwPaperReputation", tabContainer, "GwPaperReputation")
    fmGPR.categories.detailFrames = 0
    fmGPR.categories.buttons = 0
    fmGPR.categories.scroll = 1
    fmGPR.categories:EnableMouseWheel(true)
    fmGPR.categories:RegisterEvent("UPDATE_FACTION")
    local fnGPR_OnEvent = function(self, event)
        if not GW.inWorld then
            return
        end
        updateSavedReputation()
        if GwPaperReputation:IsShown() then
            updateOldData()
        end
    end
    fmGPR.categories:SetScript("OnEvent", fnGPR_OnEvent)
    local fnGPR_OnMouseWheel = function(self, delta)
        self.scroll = math.max(1, self.scroll + -delta)
        updateReputations()
    end
    fmGPR.categories:SetScript("OnMouseWheel", fnGPR_OnMouseWheel)
    fmGPR.input:SetText(SEARCH .. "...")
    fmGPR.input:SetScript("OnEnterPressed", nil)
    local fnGPR_input_OnTextChanged = function(self)
        local text = self:GetText()
        if text == SEARCH .. "..." or text == "" then
            updateDetails()
            return
        end
        updateDetailsSearch(text)
    end
    fmGPR.input:SetScript("OnTextChanged", fnGPR_input_OnTextChanged)
    local fnGPR_input_OnEscapePressed = function(self)
        self:ClearFocus()
        self:SetText(SEARCH .. "...")
    end
    fmGPR.input:SetScript("OnEscapePressed", fnGPR_input_OnEscapePressed)
    local fnGPR_input_OnEditFocusGained = function(self)
        if self:GetText() == SEARCH .. "..." then
            self:SetText("")
        end
        --update saved reputations
        updateSavedReputation()
    end
    fmGPR.input:SetScript("OnEditFocusGained", fnGPR_input_OnEditFocusGained)
    local fnGPR_input_OnEditFocusLost = function(self)
        if self:GetText() == "" then
            self:SetText(SEARCH .. "...")
        end
    end
    fmGPR.input:SetScript("OnEditFocusLost", fnGPR_input_OnEditFocusLost)

    local fmDetail = CreateFrame("Frame", "GwRepDetailFrame", tabContainer, "GwRepDetailFrame")
    local sf = fmDetail.scroller
    sf.dynamic = function(offset)
        return dynamicOffset(sf, offset)
    end
    sf.scrollBar.doNotHide = true

    updateSavedReputation()
    updateReputations()

    reputationSetup(sf)
    sf.update = updateOldData
    reputationLastUpdateMethod = updateDetails

    ReputationFrame:UnregisterAllEvents()
end
GW.LoadReputation = LoadReputation
