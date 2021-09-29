local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS
local RT = GW.REP_TEXTURES

-- forward function defs
local updateOldData
local updateReputations
local updateDetails

local savedReputation = {}
local firstReputationCat = 1
local lastReputationCat = 2
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
    if not factionIndex then return end
    if boolean then
        expandedFactions[factionIndex] = true
        return
    end
    expandedFactions[factionIndex] = nil
end
GW.AddForProfiling("reputation", "detailFaction", detailFaction)

local function updateSavedReputation()
    for factionIndex = 1, GetNumFactions() do
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
            savedReputation[factionIndex].hasBonusRepGain = GetFactionInfo(factionIndex)
    end
end
GW.AddForProfiling("reputation", "updateSavedReputation", updateSavedReputation)

local function returnReputationData(factionIndex)
    if savedReputation[factionIndex] == nil then
        return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    return savedReputation[factionIndex].name,
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
            savedReputation[factionIndex].hasBonusRepGain
end
GW.AddForProfiling("reputation", "returnReputationData", returnReputationData)

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
end
GW.AddForProfiling("reputation", "detailsControls_OnShow", detailsControls_OnShow)

local function detailsControls_OnHide(self)
    self:GetParent().details:Hide()
    self:GetParent().detailsbg:Hide()
end
GW.AddForProfiling("reputation", "detailsControls_OnHide", detailsControls_OnHide)

local function details_OnClick(self)
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
        self.item.repbg:SetTexCoord(unpack(GW.TexCoords))
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
    isWatched,
    factionID)
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

    local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), GW.mysex)
    local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), GW.mysex)

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
        frame.controles.showAsBar.checkbutton:SetChecked(true)
    else
        frame.controles.showAsBar.checkbutton:SetChecked(false)
    end

    if IsFactionInactive(factionIndex) then
        frame.controles.inactive.checkbutton:SetChecked(true)
    else
        frame.controles.inactive.checkbutton:SetChecked(false)
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
            if GwPaperReputation.categories.buttons[1] then
                showHeader(GwPaperReputation.categories.buttons[1].item.factionIndexFirst, GwPaperReputation.categories.buttons[1].item.factionIndexLast)
                updateReputations()
                updateDetails()
            end
        end
    )

    frame.controles.inactive.checkbutton:SetScript(
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
            if GwPaperReputation.categories.buttons[1] then
                showHeader(GwPaperReputation.categories.buttons[1].item.factionIndexFirst, GwPaperReputation.categories.buttons[1].item.factionIndexLast)
                updateReputations()
                updateDetails()
            end
        end
    )

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
    frame.controles.showAsBar.checkbutton:SetScript(
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

    if factionID and RT[factionID] then
        frame.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/rep/" .. RT[factionID])
        if isExpanded then
            frame.repbg:SetTexCoord(unpack(GW.TexCoords))
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

        frame.name:SetText(hasRewardPending and name .. "|TInterface/AddOns/GW2_UI/textures/icons/rewards-icon:32:32:0:0|t" or name)

        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(L["Paragon"])

        frame.currentValue:SetText(CommaValue(currentValue))
        frame.nextValue:SetText(CommaValue(maxValueParagon))

        local percent = math.floor(RoundDec(((currentValue - 0) / (maxValueParagon - 0)) * 100), 0)
        frame.percentage:SetText(percent .. "%")

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((currentValue - 0) / (maxValueParagon - 0))

        frame.background2:SetVertexColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
        frame.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
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
        dat.isWatched,
        dat.factionID
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
    for _, v in pairs(facData) do
        v.loaded = false
    end
    table.wipe(facOrder)

    -- run through factions to get data and total count for the selected category
    local savedHeaderName = ""
    for idx = firstReputationCat + 1, lastReputationCat do
        local name, desc, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain = returnReputationData(idx)

        if not factionID or (isHeader and not isChild) then
            break
        end

        if expandedFactions[factionID] then
            expCount = expCount + 1
        end

        if isHeader and isChild then
            savedHeaderName = name
        end

        if not isChild then
            savedHeaderName = ""
        end

        if not facData[factionID] and (not isHeader or hasRep) then
            facData[factionID] = {}
        end
        if not isHeader or hasRep then
            repCount = repCount + 1

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
    self.controles.inactive:SetScript("OnEnter", detailsInactive_OnEnter)
    self.controles.inactive:SetScript("OnLeave", GameTooltip_Hide)
    self.controles.inactive.checkbutton:SetScript("OnEnter", detailsInactive_OnEnter)
    self.controles.inactive.checkbutton:SetScript("OnLeave", GameTooltip_Hide)
    self.controles.showAsBar:SetScript("OnEnter", detailsShowAsBar_OnEnter)
    self.controles.showAsBar:SetScript("OnLeave", GameTooltip_Hide)
    self.controles.showAsBar.checkbutton:SetScript("OnEnter", detailsShowAsBar_OnEnter)
    self.controles.showAsBar.checkbutton:SetScript("OnLeave", GameTooltip_Hide)
    self.controles.inactive.string:SetFont(UNIT_NAME_FONT, 12)
    self.controles.inactive.string:SetText(FACTION_INACTIVE)
    self.controles.inactive:SetWidth(self.controles.inactive.string:GetWidth())
    self.controles.showAsBar.string:SetFont(UNIT_NAME_FONT, 12)
    self.controles.showAsBar.string:SetText(SHOW_FACTION_ON_MAINSCREEN)
    self.controles.showAsBar:SetWidth(self.controles.showAsBar.string:GetWidth())
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
    self.nextRank:SetText(NEXT)
    self:GetParent():SetScript("OnClick", details_OnClick)
    self:GetParent():SetScript("OnEnter", function(self)
        self.item.repbg:SetBlendMode("ADD")
        self.item.background:SetBlendMode("ADD")
        self.item.background2:SetBlendMode("ADD")
    end)
    self:GetParent():SetScript("OnLeave", function(self)
        self.item.repbg:SetBlendMode("BLEND")
        self.item.background:SetBlendMode("BLEND")
        self.item.background2:SetBlendMode("BLEND")
    end)

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

local function sortFactionsStatus(tbl)
    table.sort(tbl, function(a, b)
            if a.isFriend ~= b.isFriend then
                return b.isFriend
            elseif a.standingId ~= b.standingId then
                return a.standingId > b.standingId
            end
        end)
    return tbl
end

local function CollectCategories()
    ExpandAllFactionHeaders()

    local catagories = {}
    local factionTbl
    local cMax = 0
    local cCur = 0
    local idx, headerName = 0, ""
    local skipFirst = true

    for factionIndex = 1, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, isHeader, _, _, _, isChild = returnReputationData(factionIndex)
        if name then
            if isHeader and not isChild then
                if not skipFirst then
                    tinsert(catagories, {idx = idx, idxLast = factionIndex - 1,  name = headerName, standingCur = cCur, standingMax = cMax, fctTbl = sortFactionsStatus(factionTbl)})
                end
                skipFirst = false
                cMax = 0
                cCur = 0
                factionTbl = {}
                idx = factionIndex
                headerName = name
            else
                local found = false
                local standing = getglobal("FACTION_STANDING_LABEL" .. standingId)
                cCur = cCur + standingId
                cMax = cMax + 8

                for _, v in pairs(factionTbl) do
                    if v.isFriend == false and v.standingText == standing then
                        v.counter = v.counter + 1
                        found = true
                        break
                    end
                end
                if not found then
                    tinsert(factionTbl, {standingId = standingId, isFriend = false, standingText = standing, counter = 1})
                end
            end
        end
    end
    -- insert the last header
    if factionTbl then
        tinsert(catagories, {idx = idx, idxLast = GetNumFactions(), name = headerName, standingCur = cCur, standingMax = cMax, fctTbl = sortFactionsStatus(factionTbl)})
    end

    return catagories
end

updateReputations = function()
    local USED_REPUTATION_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(GwPaperReputation.categories)
    local catagories = CollectCategories()
    local catagoriesCount = #catagories

    for i = 1, #GwPaperReputation.categories.buttons do
        local cat = GwPaperReputation.categories.buttons[i]

        local idx = i + offset
        if idx > catagoriesCount then
            -- empty row (blank starter row, final row, and any empty entries)
            cat.item:Hide()
        else
            cat.item.factionIndexFirst = catagories[idx].idx
            cat.item.factionIndexLast = catagories[idx].idxLast
            cat.item.standings = catagories[idx].fctTbl

            cat.item.name:SetText(catagories[idx].name)
            if catagories[idx].standingCur and catagories[idx].standingCur > 0 and catagories[idx].standingMax and catagories[idx].standingMax > 0 then
                cat.item.StatusBar:SetValue(catagories[idx].standingCur / catagories[idx].standingMax)
                cat.item.StatusBar.percentage:SetText(math.floor(RoundDec(cat.item.StatusBar:GetValue() * 100), 0) .. "%")
                if catagories[idx].standingCur / catagories[idx].standingMax >= 1 and catagories[idx].standingMax ~= 0 then
                    cat.item.StatusBar:SetStatusBarColor(171 / 255, 37 / 255, 240 / 255)
                    cat.item.StatusBar.Spark:Hide()
                else
                    cat.item.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
                end
            end

            -- set zebra color by idx or watch status
            zebra = idx % 2
            if cat.item.factionIndexFirst == firstReputationCat then
                cat.item.zebra:SetVertexColor(1, 1, 0.5, 0.15)
            else
                cat.item.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
            end

            cat.item:Show()
        end
    end

    USED_REPUTATION_HEIGHT = 44 * catagoriesCount
    HybridScrollFrame_Update(GwPaperReputation.categories, USED_REPUTATION_HEIGHT, 540)
end

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
    for _, v in pairs(facData) do
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
            hasBonusRepGain = returnReputationData(idx)

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

local function dynamicOffset(_, offset)
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

local function categoriesSetup(catwin)
    HybridScrollFrame_CreateButtons(catwin, "GwPaperDollReputationCat", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #catwin.buttons do
        local cat = catwin.buttons[i]

        cat.item:SetWidth(231)
        cat.item.name:SetTextColor(1, 1, 1, 1)
        cat.item.name:SetShadowColor(0, 0, 0, 1)
        cat.item.name:SetShadowOffset(1, -1)
        cat.item.name:SetFont(DAMAGE_TEXT_FONT, 14)
        cat.item.StatusBar.percentage:SetFont(UNIT_NAME_FONT, 10)
        cat.item.StatusBar.percentage:SetShadowColor(0, 0, 0, 1)
        cat.item.StatusBar.percentage:SetShadowOffset(1, -1)

        hooksecurefunc(cat.item.StatusBar, "SetValue",
            function(self)
                local v = self:GetValue()
                local width = math.max(1, math.min(10, 10 * ((v / 1) / 0.1)))
                if v == max then
                    cat.item.StatusBar.Spark:Hide()
                else
                    cat.item.StatusBar.Spark:SetPoint("RIGHT", self, "LEFT", 201 * (v / 1), 0)
                    cat.item.StatusBar.Spark:SetWidth(width)
                    cat.item.StatusBar.Spark:Show()
                end
            end)
        cat.item:SetScript("OnClick", function(self)
            updateSavedReputation()
            showHeader(self.factionIndexFirst, self.factionIndexLast)
            updateReputations()
            updateDetails()
        end)
        cat.item:SetScript("OnEnter", function(self)
            self.backgroundHover:SetBlendMode("ADD")
            self.zebra:SetBlendMode("ADD")
            self.StatusBar.percentage:Show()

            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(ACHIEVEMENT_SUMMARY_CATEGORY, 1, 1, 1)

            for _, v in pairs(self.standings) do
                GameTooltip:AddDoubleLine(v.standingText, v.counter)
            end
            GameTooltip:Show()
        end)
        cat.item:SetScript("OnLeave", function(self)
            self.backgroundHover:SetBlendMode("BLEND")
            self.zebra:SetBlendMode("BLEND")
            self.StatusBar.percentage:Hide()
            GameTooltip:Hide()
        end)
    end

    if updateReputations then
        updateReputations()
    end
end

local function LoadReputation(tabContainer)
    local container = CreateFrame("Frame", "GwPaperReputationContainer", tabContainer, "GwCharacterWindowContainer")
    local fmGPR = CreateFrame("Frame", "GwPaperReputation", container, "GwPaperReputation")

    fmGPR.categories.update = updateReputations
    fmGPR.categories.scrollBar.doNotHide = false
    categoriesSetup(fmGPR.categories)

    fmGPR.categories.detailFrames = 0
    fmGPR.categories:RegisterEvent("UPDATE_FACTION")
    local fnGPR_OnEvent = function(self)
        if not GW.inWorld then
            return
        end
        updateSavedReputation()
        if self:GetParent():IsShown() then
            updateOldData()
        end
    end
    fmGPR.categories:SetScript("OnEvent", fnGPR_OnEvent)
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

    local fmDetail = CreateFrame("Frame", "GwRepDetailFrame", container, "GwRepDetailFrame")
    local sf = fmDetail.scroller
    sf.dynamic = function(offset)
        return dynamicOffset(sf, offset)
    end
    sf.scrollBar.doNotHide = false

    updateSavedReputation()
    updateReputations()

    reputationSetup(sf)
    sf.update = updateOldData
    reputationLastUpdateMethod = updateDetails

    if GwPaperReputation.categories.buttons[1] then
        showHeader(GwPaperReputation.categories.buttons[1].item.factionIndexFirst, GwPaperReputation.categories.buttons[1].item.factionIndexLast)
        updateDetails()
    end

    ReputationFrame:UnregisterAllEvents()

    return container
end
GW.LoadReputation = LoadReputation
