local _, GW = ...
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local CharacterMenuBlank_OnLoad = GW.CharacterMenuBlank_OnLoad
local CharacterMenuButtonBack_OnLoad = GW.CharacterMenuButtonBack_OnLoad
local CharacterMenuButtonBack_OnClick = GW.CharacterMenuButtonBack_OnClick
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

-- forward function defs
local updateOldData

local gender = UnitSex("player")
local savedReputation = {}
local selectedReputationCat = 1
local reputationLastUpdateMethod = nil
local reputationLastUpdateMethodParams = nil

local expandedFactions = {}

local function detailFaction(factionIndex, boolean)
    if boolean then
        expandedFactions[factionIndex] = true
        return
    end
    expandedFactions[factionIndex] = nil
end

local function getNewCategory(i)
    if _G["GwPaperDollReputationCat" .. i] ~= nil then
        return _G["GwPaperDollReputationCat" .. i]
    end

    local f = CreateFrame("Button", "GwPaperDollReputationCat" .. i, GwPaperReputation, "GwPaperDollReputationCat")
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
            _G[BNAME .. "Spark"]:SetPoint("RIGHT", self, "LEFT", 201 * (v / max), 0)
            _G[BNAME .. "Spark"]:SetWidth(width)
        end
    )

    if i > 1 then
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollReputationCat" .. (i - 1)], "BOTTOMLEFT")
    else
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", GwPaperReputation, "TOPLEFT")
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint("TOPLEFT", 10, -10)
    GwPaperReputation.buttons = GwPaperReputation.buttons + 1

    return f
end

local function updateSavedReputation()
    for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
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

local function showHeader(i)
    selectedReputationCat = i
end

local function detailsAtwar_OnEnter(self)
    self.icon:SetTexCoord(0.5, 1, 0, 0.5)
end

local function detailsAtwar_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end
end

local function detailsFavorite_OnEnter(self)
    self.icon:SetTexCoord(0, 0.5, 0.5, 1)
end

local function detailsFavorite_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0.5, 1, 0.5, 1)
    end
end

local function detailsControls_OnShow(self)
    self:GetParent().details:Show()

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

local function detailsControls_OnHide(self)
    self:GetParent().details:Hide()
end

local function details_OnClick(self, button)
    if self.details:IsShown() then
        detailFaction(self.factionIndex, false)
        self:SetHeight(80)
        self.controles:Hide()
    else
        detailFaction(self.factionIndex, true)
        self:SetHeight(140)
        self.controles:Show()
    end
end

local function getNewDetail(i)
    if _G["GwReputationDetails" .. i] ~= nil then
        return _G["GwReputationDetails" .. i]
    end

    local f =
        CreateFrame(
        "Button",
        "GwReputationDetails" .. i,
        GwPaperReputationScrollFrame.scrollchild,
        "GwReputationDetails"
    )
    f.controles.atwar:SetScript("OnEnter", detailsAtwar_OnEnter)
    f.controles.atwar:SetScript("OnLeave", detailsAtwar_OnLeave)
    f.controles.favorit:SetScript("OnEnter", detailsFavorite_OnEnter)
    f.controles.favorit:SetScript("OnLeave", detailsFavorite_OnLeave)
    f.controles.inactive.string:SetFont(UNIT_NAME_FONT, 12)
    f.controles.inactive.string:SetText(GwLocalization["CHARACTER_REPUTATION_INACTIVE"])
    f.controles.showAsBar.string:SetFont(UNIT_NAME_FONT, 12)
    f.controles.showAsBar.string:SetText(GwLocalization["CHARACTER_REPUTATION_TRACK"])
    f.controles:SetScript("OnShow", detailsControls_OnShow)
    f.controles:SetScript("OnHide", detailsControls_OnHide)
    f.StatusBar.currentValue:SetFont(UNIT_NAME_FONT, 12)
    f.StatusBar.percentage:SetFont(UNIT_NAME_FONT, 12)
    f.StatusBar.nextValue:SetFont(UNIT_NAME_FONT, 12)

    f.StatusBar.currentValue:SetShadowColor(0, 0, 0, 1)
    f.StatusBar.percentage:SetShadowColor(0, 0, 0, 1)
    f.StatusBar.nextValue:SetShadowColor(0, 0, 0, 1)

    f.StatusBar.currentValue:SetShadowOffset(1, -1)
    f.StatusBar.percentage:SetShadowOffset(1, -1)
    f.StatusBar.nextValue:SetShadowOffset(1, -1)

    f.StatusBar:GetParent().currentValue = f.StatusBar.currentValue
    f.StatusBar:GetParent().percentage = f.StatusBar.percentage
    f.StatusBar:GetParent().nextValue = f.StatusBar.nextValue
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
            _G[BNAME .. "Spark"]:SetPoint("RIGHT", self, "LEFT", self:GetWidth() * (v / max), 0)
            _G[BNAME .. "Spark"]:SetWidth(width)
        end
    )

    f.details:SetPoint("TOPLEFT", f.StatusBar, "BOTTOMLEFT", 0, -15)
    f.statusbarbg:SetPoint("TOPLEFT", f.StatusBar, "TOPLEFT", -2, 2)
    f.statusbarbg:SetPoint("BOTTOMRIGHT", f.StatusBar, "BOTTOMRIGHT", 0, -2)
    f.currentRank:SetPoint("TOPLEFT", f.StatusBar, "BOTTOMLEFT", 0, -5)
    f.nextRank:SetPoint("TOPRIGHT", f.StatusBar, "BOTTOMRIGHT", 0, -5)
    f.currentRank:SetFont(DAMAGE_TEXT_FONT, 11)
    f.currentRank:SetTextColor(0.6, 0.6, 0.6)
    f.nextRank:SetFont(DAMAGE_TEXT_FONT, 11)
    f.nextRank:SetTextColor(0.6, 0.6, 0.6)
    f.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.name:SetTextColor(1, 1, 1, 1)
    f.details:SetFont(UNIT_NAME_FONT, 12)
    f.details:SetTextColor(0.8, 0.8, 0.8, 1)
    f.details:Hide()
    f.currentRank:SetText(GwLocalization["CHARACTER_CURRENT_RANK"])
    f.nextRank:SetText(GwLocalization["CHARACTER_NEXT_RANK"])
    f:SetScript("OnClick", details_OnClick)

    if i > 1 then
        _G["GwReputationDetails" .. i]:SetPoint("TOPLEFT", _G["GwReputationDetails" .. (i - 1)], "BOTTOMLEFT", 0, -1)
    else
        _G["GwReputationDetails" .. i]:SetPoint("TOPLEFT", GwPaperReputationScrollFrame.scrollchild, "TOPLEFT", 2, -10)
    end

    GwPaperReputation.detailFrames = GwPaperReputation.detailFrames + 1

    return f
end

local function setDetail(
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

    if expandedFactions[factionIndex] == nil then
        frame.controles:Hide()
        frame:SetHeight(80)
    else
        frame:SetHeight(140)
        frame.controles:Show()
    end

    local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), gender)
    local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), gender)
    local friendID, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold =
        GetFriendshipReputation(factionID)

    if textureC == 1 then
        frame.background:SetTexture(nil)
        textureC = 2
    else
        frame.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
        textureC = 1
    end

    frame.name:SetText(name .. savedHeaderName)
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

    if factionID and C_Reputation.IsFactionParagon(factionID) then
        local currentValue, maxValueParagon, _, _ = C_Reputation.GetFactionParagonInfo(factionID)

        if currentValue > 10000 then
            repeat
                currentValue = currentValue - 10000
            until (currentValue < 10000)
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

local function updateDetails()
    local buttonIndex = 1
    local savedHeaderName = ""
    local savedHeight = 0

    for factionIndex = selectedReputationCat + 1, GetNumFactions() do
        local name,
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
            canBeLFGBonus = returnReputationData(factionIndex)
        if name ~= nil then
            if isHeader and not isChild then
                break
            end

            if isHeader and isChild then
                savedHeaderName = " |cFFa0a0a0" .. name .. "|r"
            end

            if not isChild then
                savedHeaderName = ""
            end

            local frame = getNewDetail(buttonIndex)

            setDetail(
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
                canBeLFGBonus
            )

            savedHeight = savedHeight + frame:GetHeight()

            buttonIndex = buttonIndex + 1
        end
    end

    for i = buttonIndex, GwPaperReputation.detailFrames do
        _G["GwReputationDetails" .. i]:Hide()
    end

    GwPaperReputationScrollFrame:SetVerticalScroll(0)

    GwPaperReputationScrollFrame:SetVerticalScroll(0)

    GwPaperReputationScrollFrame.slider.thumb:SetHeight(100)
    GwPaperReputationScrollFrame.slider:SetValue(1)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.savedHeight = savedHeight - 590

    reputationLastUpdateMethod = updateDetails
end

local function updateReputations()
    ExpandAllFactionHeaders()

    local headerIndex = 1
    local CurrentOwner = nil
    local cMax = 0
    local cCur = 0
    local textureC = 1

    for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
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

    for i = headerIndex, GwPaperReputation.buttons do
        _G["GwPaperDollReputationCat" .. i]:Hide()
    end
end

updateOldData = function()
    if reputationLastUpdateMethod ~= nil then
        reputationLastUpdateMethod(reputationLastUpdateMethodParams)
    end
end

local function reputationSearch(a, b)
    return string.find(a, b)
end

local function updateDetailsSearch(s)
    local buttonIndex = 1

    local savedHeaderName = ""
    local savedHeight = 0

    for factionIndex = 1, GetNumFactions() do
        local name,
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
            canBeLFGBonus = returnReputationData(factionIndex)

        local lower1 = string.lower(name)
        local lower2 = string.lower(s)

        local show = true

        if isHeader then
            if not isChild then
                show = false
            end
        end

        if (name ~= nil and reputationSearch(lower1, lower2) ~= nil) and show then
            local frame = getNewDetail(buttonIndex)

            setDetail(
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
                canBeLFGBonus
            )

            savedHeight = savedHeight + frame:GetHeight()

            buttonIndex = buttonIndex + 1
        end
    end

    for i = buttonIndex, GwPaperReputation.detailFrames do
        _G["GwReputationDetails" .. i]:Hide()
    end

    GwPaperReputationScrollFrame:SetVerticalScroll(0)

    GwPaperReputationScrollFrame.slider.thumb:SetHeight(100)
    GwPaperReputationScrollFrame.slider:SetValue(1)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.savedHeight = savedHeight - 590

    reputationLastUpdateMethod = updateDetailsSearch
    reputationLastUpdateMethodParams = s
end

local function LoadCharacterReputation()
    local fmGPR = CreateFrame("Frame", "GwPaperReputation", GwCharacterWindowContainer, "GwPaperReputation")
    fmGPR.detailFrames = 0
    fmGPR.buttons = 0
    fmGPR.scroll = 1
    fmGPR:EnableMouseWheel(true)
    fmGPR:RegisterEvent("UPDATE_FACTION")
    local fnGPR_OnEvent = function(self, event)
        updateSavedReputation()
        if GwPaperReputation:IsShown() then
            updateOldData()
        end
    end
    fmGPR:SetScript("OnEvent", fnGPR_OnEvent)
    local fnGPR_OnMouseWheel = function(self, delta)
        self.scroll = math.max(1, self.scroll + -delta)
        updateReputations()
    end
    fmGPR:SetScript("OnMouseWheel", fnGPR_OnMouseWheel)
    fmGPR.backButton:SetText(GwLocalization["CHARACTER_MENU_REPS_RETURN"])
    CharacterMenuButtonBack_OnLoad(fmGPR.backButton)
    fmGPR.backButton:SetScript("OnClick", CharacterMenuButtonBack_OnClick)
    fmGPR.input:SetText(GwLocalization["CHARACTER_REP_SEARCH"])
    fmGPR.input:SetScript("OnEnterPressed", nil)
    local fnGPR_input_OnTextChanged = function(self)
        local text = self:GetText()
        if text == GwLocalization["CHARACTER_REP_SEARCH"] or text == "" then
            updateDetails()
            return
        end
        updateDetailsSearch(text)
    end
    fmGPR.input:SetScript("OnTextChanged", fnGPR_input_OnTextChanged)
    local fnGPR_input_OnEscapePressed = function(self)
        self:ClearFocus()
        self:SetText(GwLocalization["CHARACTER_REP_SEARCH"])
    end
    fmGPR.input:SetScript("OnEscapePressed", fnGPR_input_OnEscapePressed)
    local fnGPR_input_OnEditFocusGained = function(self)
        if self:GetText() == GwLocalization["CHARACTER_REP_SEARCH"] then
            self:SetText("")
        end
    end
    fmGPR.input:SetScript("OnEditFocusGained", fnGPR_input_OnEditFocusGained)
    local fnGPR_input_OnEditFocusLost = function(self)
        if self:GetText() == "" then
            self:SetText(GwLocalization["CHARACTER_REP_SEARCH"])
        end
    end
    fmGPR.input:SetScript("OnEditFocusLost", fnGPR_input_OnEditFocusLost)
    local fnGPRSF_OnMouseWheel = function(self, delta)
        delta = -delta * 15
        local s = math.max(0, self:GetVerticalScroll() + delta)
        self.slider:SetValue(s)
        self:SetVerticalScroll(s)
    end
    GwPaperReputationScrollFrame:SetScript("OnMouseWheel", fnGPRSF_OnMouseWheel)
    GwPaperReputationScrollFrame.slider:SetMinMaxValues(0, 608)
    local fnGPRSF_slider_OnValueChanged = function(self, value)
        self:GetParent():SetVerticalScroll(value)
    end
    GwPaperReputationScrollFrame.slider:SetScript("OnValueChanged", fnGPRSF_slider_OnValueChanged)
    GwPaperReputationScrollFrame.slider:SetValue(1)

    updateSavedReputation()
    GwPaperReputationScrollFrame:SetScrollChild(GwPaperReputationScrollFrame.scrollchild)
    updateReputations()

    updateDetails()
end
GW.LoadCharacterReputation = LoadCharacterReputation
