local _, GW = ...
local L = GW.L
local lerp = GW.lerp
local Diff = GW.Diff
local animations = GW.animations

local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

-- forward function defs
local experiencebarAnimation = 0
local houseInfoCache = {}
local queueTimer

local STATUSBAR_COLORS = {
    Xp = {r = 0.83, g = 0.57, b = 0},
    PetXp = {r = 0.58, g = 0, b = 0.55},
    Honor = {r = 1, g = 0.2, b = 0.2},
    House = {r = 0.85, g = 0.7, b = 0.43},
}

local function xpbar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local isRestingString = IsResting() and L[" (Resting)"] or ""

    -- headerLine
    GameTooltip:AddLine(COMBAT_XP_GAIN .. isRestingString, 1, 1, 1)

    for _, line in ipairs(self.tooltip) do
        GameTooltip:AddLine(line, 1, 1, 1)
    end

    GameTooltip:Show()

    if self.expBarShouldShow then
        UIFrameFadeOut(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 0)
    end
    if self.azeritBarShouldShow then
        UIFrameFadeOut(self.AzeritBar, 0.2, self.AzeritBar:GetAlpha(), 0)
    end
    if self.repuBarShouldShow then
        UIFrameFadeOut(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 0)
    end
end
GW.AddForProfiling("hud", "xpbar_OnEnter", xpbar_OnEnter)

local function xpbar_OnClick()
    if not IsPlayerAtEffectiveMaxLevel() then
        if GwLevelingRewards:IsShown() then
            GwLevelingRewards:Hide()
        else
            GwLevelingRewards:Show()
        end
    elseif C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped() then
        local heartItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        if heartItemLocation and heartItemLocation:IsEqualTo(ItemLocation:CreateFromEquipmentSlot(2)) then
            if AzeriteEssenceUI and AzeriteEssenceUI:IsShown() then
                HideUIPanel(AzeriteEssenceUI)
            else
                OpenAzeriteEssenceUIFromItemLocation(heartItemLocation)
            end
        end
    end
end
GW.AddForProfiling("hud", "xpbar_OnClick", xpbar_OnClick)

local function flareAnim(self)
    self.barOverlay.flare:Show()

    GW.AddToAnimation("GwXpFlare", 0, 1, GetTime(), 1,
        function(prog)
            self.barOverlay.flare.texture:SetAlpha(1)
            self.barOverlay.flare.texture:SetRotation(lerp(0, 3, prog))
            if prog > 0.75 then
                self.barOverlay.flare.texture:SetAlpha(lerp(1, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end
        end,
        nil,
        function()
            self.barOverlay.flare:Hide()
        end
    )
end
GW.AddForProfiling("hud", "flareAnim", flareAnim)

local function UpdatePetXP(self, index, level)
    local name = C_PetBattles.GetName(Enum.BattlePetOwner.Ally, index)
    local rarity = C_PetBattles.GetBreedQuality(Enum.BattlePetOwner.Ally, index)
    local cur, max = C_PetBattles.GetXP(Enum.BattlePetOwner.Ally, index)
    local valPrec = (max > 0) and (cur / max) or 0

    local color = STATUSBAR_COLORS.PetXp
    self.ExpBar:SetStatusBarColor(color.r, color.g, color.b)

    tinsert(self.tooltip, string.format("%s: %s / %s |cffa6a6a6 (%d%%)|r",
        ITEM_QUALITY_COLORS[rarity].color:WrapTextInColorCode(name),
        math.min(max, cur), max,
        math.floor(valPrec * 100)
    ))

    return true, valPrec, level + 1
end

local function UpdateXPValues(self)
    local valCurrent = UnitXP("player")
    local valMax = UnitXPMax("player")
    local valPrec = (valMax > 0) and (valCurrent / valMax) or 0
    local rested = GetXPExhaustion() or 0
    local restedPrec = 0
    if rested > 0 then
        restedPrec = math.min(rested / (valMax - valCurrent), 1)
    end

    local color = STATUSBAR_COLORS.Xp
    self.ExpBar:SetStatusBarColor(color.r, color.g, color.b)

    if not IsPlayerAtEffectiveMaxLevel() then
        tinsert(self.tooltip, COMBAT_XP_GAIN .." " .. GW.GetLocalizedNumber(valCurrent) .. " / " ..
            GW.GetLocalizedNumber(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r")

        if rested > 0 then
            tinsert(self.tooltip, L["Rested "] .. GW.GetLocalizedNumber(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r")
        end
    end

    return true, valPrec, restedPrec
end
local function UpdateReputation(self, data, lockLevelTextUnderMaxLevel)
    local showRepu = false
    local valPrecRepu = 0
    local repuLevel, repuNextLevel = nil, nil
    local level, nextLevel
    local friendReputationInfo = C_GossipInfo.GetFriendshipReputation(data.factionID)
    local isParagon, isFriend, isMajor, isNormal = false, false, false, false
    showRepu = true

    if C_Reputation.IsFactionParagon(data.factionID) then
        local currentValue, maxValueParagon = C_Reputation.GetFactionParagonInfo(data.factionID)
        currentValue = currentValue % maxValueParagon
        valPrecRepu = (maxValueParagon > 0) and (currentValue / maxValueParagon) or 0
        tinsert(self.tooltip, string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
            data.name, REPUTATION,
            GW.GetLocalizedNumber(currentValue), GW.GetLocalizedNumber(maxValueParagon), math.floor(valPrecRepu * 100)))
        self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
        isParagon = true
        isFriend = (friendReputationInfo and friendReputationInfo.friendshipFactionID > 0)
    elseif friendReputationInfo and friendReputationInfo.friendshipFactionID > 0 then
        if friendReputationInfo.nextThreshold then
            valPrecRepu = (friendReputationInfo.standing - friendReputationInfo.reactionThreshold) /
                            (friendReputationInfo.nextThreshold - friendReputationInfo.reactionThreshold)
            tinsert(self.tooltip, string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                friendReputationInfo.name, REPUTATION,
                GW.GetLocalizedNumber(friendReputationInfo.standing - friendReputationInfo.reactionThreshold),
                GW.GetLocalizedNumber(friendReputationInfo.nextThreshold - friendReputationInfo.reactionThreshold),
                math.floor(valPrecRepu * 100)))
        else
            valPrecRepu = 1
            tinsert(self.tooltip, string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                friendReputationInfo.name, REPUTATION,
                GW.GetLocalizedNumber(friendReputationInfo.maxRep), GW.GetLocalizedNumber(friendReputationInfo.maxRep), 100))
        end
        self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
        isFriend = true
    elseif C_Reputation.IsMajorFaction(data.factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(data.factionID)
        if majorFactionData then
            repuLevel = majorFactionData.renownLevel
            repuNextLevel = C_MajorFactions.HasMaximumRenown(data.factionID) and majorFactionData.renownLevel or (majorFactionData.renownLevel + 1)
            if C_MajorFactions.HasMaximumRenown(data.factionID) then
                valPrecRepu = 1
            else
                valPrecRepu = (majorFactionData.renownReputationEarned or 0) / majorFactionData.renownLevelThreshold
            end
            tinsert(self.tooltip, string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                data.name, REPUTATION,
                GW.GetLocalizedNumber(majorFactionData.renownReputationEarned or 0),
                GW.GetLocalizedNumber(majorFactionData.renownLevelThreshold),
                math.floor(valPrecRepu * 100)))
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[11].r, FACTION_BAR_COLORS[11].g, FACTION_BAR_COLORS[11].b)
            isMajor = true
        end
    else
        -- Normaler Ruf
        local currentStanding = data.currentStanding or 0
        local currentThreshold = data.currentReactionThreshold or 0
        local nextThreshold = data.nextReactionThreshold or 0
        if (currentStanding - currentThreshold) == 0 then
            valPrecRepu = 1
            tinsert(self.tooltip, string.format("%s %s 21,000 / 21,000 |cffa6a6a6 (%d%%)|r", data.name, REPUTATION, 100))
        else
            valPrecRepu = (currentStanding - currentThreshold) / (nextThreshold - currentThreshold)
            tinsert(self.tooltip, string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                data.name, REPUTATION,
                GW.GetLocalizedNumber(currentStanding - currentThreshold),
                GW.GetLocalizedNumber(nextThreshold - currentThreshold),
                math.floor(valPrecRepu * 100)))
        end
        local reaction = data.reaction or 1
        self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
        isNormal = true
    end
        -- Setze das Level-Label basierend auf Rufdaten:
    if not lockLevelTextUnderMaxLevel then
        local nextId = (data.reaction and data.reaction + 1) or 1
        -- Hier wird level überschrieben, je nach Fraktionstyp:
        level = isMajor and repuLevel or
            isFriend and friendReputationInfo.reaction or
            isParagon and L["Paragon"] or
            isNormal and getglobal("FACTION_STANDING_LABEL" .. (data.reaction or 1))
        nextLevel = isParagon and L["Paragon"] or
            isFriend and "" or
            isMajor and repuNextLevel or
            isNormal and getglobal("FACTION_STANDING_LABEL" .. math.min(8, nextId))
    end

    return showRepu, valPrecRepu, level, nextLevel
end

local function UpdateAzerite(self, azeriteItem)
    local AzeritVal, AzeritLevel = 0, 0
    local azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)
    AzeritLevel = C_AzeriteItem.GetPowerLevel(azeriteItem)
    AzeritVal = (xpForNextPoint > 0) and (azeriteXP / xpForNextPoint) or 0
    self.AzeritBar:SetStatusBarColor(FACTION_BAR_COLORS[10].r, FACTION_BAR_COLORS[10].g, FACTION_BAR_COLORS[10].b)
    self.AzeritBar.animation:Show()

    tinsert(self.tooltip, AZERITE_POWER_BAR:format(
        GW.GetLocalizedNumber(azeriteXP) .. " / " .. GW.GetLocalizedNumber(xpForNextPoint) .. " |cffa6a6a6 (" .. math.floor(AzeritVal * 100) .. "%)|r"
    ))

    return true, AzeritVal, AzeritLevel
end

local function UpdateHouseXP(self, data)
    local level = data.houseLevel
    local cur = data.houseFavor
    local max = C_Housing.GetHouseLevelFavorForLevel(level + 1)
    local valPrec = (max > 0) and (math.min(cur, max) / max) or 0

    tinsert(self.tooltip, string.format("%s (%s): %s / %s |cffa6a6a6 (%d%%)|r",
        format(HOUSING_DASHBOARD_OWNERS_HOUSE, data.houseName or GW.myname),
        format(LEVEL .. " %s", data.houseLevel),
        math.min(max, cur), max,
        math.floor(valPrec * 100)
    ))

    if cur >= max then
        tinsert(self.tooltip, HOUSING_DASHBOARD_VISIT_NPC)
    end

    local color = STATUSBAR_COLORS.House
    self.ExpBar:SetStatusBarColor(color.r, color.g, color.b)

    return true, valPrec, level, level + 1
end

local function UpdateHonor(self)
    local level = UnitHonorLevel("player")
    local currentHonor = UnitHonor("player")
    local maxHonor = UnitHonorMax("player")
    local valPrec = (maxHonor > 0) and (currentHonor / maxHonor) or 0

    tinsert(self.tooltip, HONOR .. " " .. GW.GetLocalizedNumber(currentHonor) .. " / " .. GW.GetLocalizedNumber(maxHonor) .. " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r")

    local color = STATUSBAR_COLORS.Honor
    self.ExpBar:SetStatusBarColor(color.r, color.g, color.b)
    return true, valPrec, level, level + 1
end

local function SetBarLayout(bar, candy, spark, height, offset)
    bar:Show()
    candy:Show()
    spark:Show()
    bar:SetHeight(height)
    candy:SetHeight(height)
    spark:SetHeight(height)
    candy:ClearAllPoints()
    candy:SetPoint("TOPLEFT", 90, offset)
    candy:SetPoint("TOPRIGHT", -90, offset)
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", 90, offset)
    bar:SetPoint("TOPRIGHT", -90, offset)
end

local function LayoutBars(self, showExp, showAzerite, showRepu)
    local visibleBars = {}

    if showExp then
        table.insert(visibleBars, {bar = self.ExpBar, candy = self.ExpBarCandy, spark = self.ExpBar.Spark})
    else
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar.Spark:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
    end

    if showAzerite then
        table.insert(visibleBars, {bar = self.AzeritBar, candy = self.AzeritBarCandy, spark = self.AzeritBar.Spark})
    else
        self.AzeritBar:Hide()
        self.AzeritBarCandy:Hide()
        self.AzeritBar.animation:Hide()
        self.AzeritBar:SetValue(0)
        self.AzeritBarCandy:SetValue(0)
        self.AzeritBar.Spark:Hide()
    end

    if showRepu then
        table.insert(visibleBars, {bar = self.RepuBar, candy = self.RepuBarCandy, spark = self.RepuBar.Spark})
    else
        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    end

    local count = #visibleBars
    local height = 0
    if count == 3 then
        height = 2.66
    elseif count == 2 then
        height = 4
    elseif count == 1 then
        height = 8
    end

    for i, barData in ipairs(visibleBars) do
        local offset = -4 * i -- z. B. i==1 -> -4, i==2 -> -8, i==3 -> -12
        SetBarLayout(barData.bar, barData.candy, barData.spark, height, offset)
    end
end

local function UpdateData(self)
    local animationSpeed = 15
    local maxPlayerLevel = GetMaxLevelForPlayerExpansion()
    local restingIconString = IsResting() and " |TInterface\\AddOns\\GW2_UI\\textures\\icons\\resting-icon.png:16:16:0:0|t " or ""
    local showExp, showRepu, showAzerite = false, false, false
    local level = GW.mylevel
    local nextLevel = GW.mylevel < maxPlayerLevel and (GW.mylevel + 1) or GW.mylevel
    local lockLevelTextUnderMaxLevel = level < nextLevel
    local valPrec, rested = 0, 0
    local valPrecRepu
    local valPrecAzerite, azeritLevel

    wipe(self.tooltip)

    if C_PetBattles.IsInBattle() then
        local i = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally)
        level = C_PetBattles.GetLevel(Enum.BattlePetOwner.Ally, i)
        if level and level < 25 then
            showExp, valPrec, nextLevel = UpdatePetXP(self, i, level)
        end
    else
        if not IsXPUserDisabled() and not IsPlayerAtEffectiveMaxLevel() then
            showExp, valPrec, rested = UpdateXPValues(self)
        end

        if not showExp and (IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP()) then
            showExp, valPrec, level, nextLevel = UpdateHonor(self)
        end

        local guid = C_Housing.GetTrackedHouseGuid()
        if not showExp and guid and houseInfoCache[guid] and houseInfoCache[guid].houseLevel then
            showExp, valPrec, level, nextLevel = UpdateHouseXP(self, houseInfoCache[guid])
        end

        local data = C_Reputation.GetWatchedFactionData()
        if data and data.factionID and data.factionID > 0 then
            local tempLevel, tempNextLeve = level, nextLevel
            showRepu, valPrecRepu, level, nextLevel = UpdateReputation(self, data, lockLevelTextUnderMaxLevel)
            if not level then
                level = tempLevel
            end
            if not nextLevel then
                nextLevel = tempNextLeve
            end
        end

        if not C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
            local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
            if azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem) then
                showAzerite, valPrecAzerite, azeritLevel = UpdateAzerite(self, azeriteItem)
            end
        end
    end

    if showAzerite then
        self.AzeritBarCandy:SetValue(valPrecAzerite)
        GW.AddToAnimation("AzeritBarAnimation", self.AzeritBar.AzeritBarAnimation, valPrecAzerite, GetTime(), animationSpeed,
            function(p)
                self.AzeritBar.Spark:SetWidth(math.max(8, math.min(9, self.AzeritBar:GetWidth() * p)))
                self.AzeritBar:SetValue(p)
                self.AzeritBar.Spark:SetPoint("LEFT", self.AzeritBar:GetWidth() * p - 8, 0)
            end)
        self.AzeritBar.AzeritBarAnimation = valPrecAzerite

        if maxPlayerLevel == GW.mylevel then
            level = azeritLevel
            nextLevel = azeritLevel + 1 --Max azerit level is infinity
            self.NextLevel:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            self.CurrentLevel:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            self.labelRight:SetTexture("Interface/AddOns/GW2_UI/textures/hud/level-label-azerit.png")
            self.labelLeft:SetTexture("Interface/AddOns/GW2_UI/textures/hud/level-label-azerit.png")
        end
    else
        local texture = (maxPlayerLevel == GW.mylevel) and "Interface/AddOns/GW2_UI/textures/hud/level-label-azerit.png" or "Interface/AddOns/GW2_UI/textures/hud/level-label.png"
        self.NextLevel:SetTextColor(1, 1, 1)
        self.CurrentLevel:SetTextColor(1, 1, 1)
        self.labelRight:SetTexture(texture)
        self.labelLeft:SetTexture(texture)
    end

    if showExp then
        local GainBigExp = false
        local FlareBreakPoint = math.max(0.05, 0.15 * (1 - (GW.mylevel / maxPlayerLevel)))
        if (valPrec - experiencebarAnimation) > FlareBreakPoint then
            GainBigExp = true
            flareAnim(self)
        end

        if experiencebarAnimation > valPrec then
            experiencebarAnimation = 0
        end

        self.barOverlay.flare.soundCooldown = 0
        local expSoundCooldown = 0
        local startTime = GetTime()
        animationSpeed = Diff(experiencebarAnimation, valPrec)
        animationSpeed = math.min(15, math.max(5, 10 * animationSpeed))

        GW.AddToAnimation("experiencebarAnimation", experiencebarAnimation, valPrec, GetTime(), animationSpeed, function(step)
            self.ExpBar.Spark:SetWidth(math.max(8, math.min(9, self.ExpBar:GetWidth() * step)))
            if not GainBigExp then
                self.ExpBar:SetValue(step)
                self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * step - 8, 0)
                local flarePoint = ((UIParent:GetWidth() - 180) * step) + 90
                self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)
            end
            self.ExpBar.Rested:SetValue(rested)
            self.ExpBar.Rested:SetPoint("LEFT", self.ExpBar, "LEFT", self.ExpBar:GetWidth() * step, 0)

            if GainBigExp and self.barOverlay.flare.soundCooldown < GetTime() then
                expSoundCooldown = math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))
                self.ExpBar:SetValue(step)
                self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * step - 8, 0)
                local flarePoint = ((UIParent:GetWidth() - 180) * step) + 90
                self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)
                self.barOverlay.flare.soundCooldown = GetTime() + expSoundCooldown
                PlaySoundFile("Interface/AddOns/GW2_UI/Sounds/exp_gain_ping.ogg", "SFX")
                animations.experiencebarAnimation.from = step
            end
        end)
        GW.AddToAnimation("GwExperienceBarCandy", experiencebarAnimation, valPrec, GetTime(), 0.3, function(p)
            self.ExpBarCandy:SetValue(p)
        end)
    end

    if showRepu then
        animationSpeed = 15
        self.RepuBarCandy:SetValue(valPrecRepu)
        GW.AddToAnimation("repuBarAnimation", self.RepuBar.repuBarAnimation, valPrecRepu, GetTime(), animationSpeed, function(p)
            self.RepuBar.Spark:SetWidth(math.max(8, math.min(9, self.RepuBar:GetWidth() * p)))
            self.RepuBar:SetValue(p)
            self.RepuBar.Spark:SetPoint("LEFT", self.RepuBar:GetWidth() * p - 8, 0)
        end)
        self.RepuBar.repuBarAnimation = valPrecRepu
    end

    LayoutBars(self, showExp, showAzerite, showRepu)

    experiencebarAnimation = valPrec

    if GW.IsUpcomingSpellAvalible() then
        nextLevel = nextLevel .. " |TInterface\\AddOns\\GW2_UI\\textures/icons/levelreward-icon.png:20:20:0:0|t"
    end
    if GW.mylevel ~= UnitEffectiveLevel("player") then
        level = level .. " |cFF00FF00(" .. UnitEffectiveLevel("player") .. ")|r"
    end

    self.NextLevel:SetText(nextLevel)
    self.CurrentLevel:SetText(restingIconString .. level)
    self.expBarShouldShow = showExp
    self.azeritBarShouldShow = showAzerite
    self.repuBarShouldShow = showRepu
end

local function queueUpdate(self)
    UpdateData(self)
    queueTimer = nil
end

local function xpbar_OnEvent(self, event, ...)
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = ...
        if slot == Enum.InventoryType.IndexNeckType then
            if not queueTimer then
                queueTimer = C_Timer.NewTimer(0.1, function() queueUpdate(self) end)
            end
        end
    elseif event == "HOUSE_LEVEL_FAVOR_UPDATED" then
        local info = ...
        houseInfoCache[info.houseGUID] = houseInfoCache[info.houseGUID] or {}
        houseInfoCache[info.houseGUID].houseLevel = info.houseLevel
        houseInfoCache[info.houseGUID].houseFavor = info.houseFavor

        if not queueTimer then
            queueTimer = C_Timer.NewTimer(0.1, function() queueUpdate(self) end)
        end
    elseif event == "PLAYER_HOUSE_LIST_UPDATED" then
        local info = ...
        for _, data in next, info do
            houseInfoCache[data.houseGUID] = houseInfoCache[data.houseGUID] or {}
            houseInfoCache[data.houseGUID].houseName = data.houseName
        end

        local guid = C_Housing.GetTrackedHouseGuid()
        if guid and houseInfoCache[guid].houseLevel and not queueTimer then
            queueTimer = C_Timer.NewTimer(0.1, function() queueUpdate(self) end)
        end
    elseif event == "TRACKED_HOUSE_CHANGED" then
        local guid = ...
        if guid then
            C_Housing.GetCurrentHouseLevelFavor(guid)
        else
            if not queueTimer then
                queueTimer = C_Timer.NewTimer(0.1, function() queueUpdate(self) end)
            end
        end
    else
        if not queueTimer then
            queueTimer = C_Timer.NewTimer(0.1, function() queueUpdate(self) end)
        end
    end
end

local function animateAzeriteBar(self, elapsed)
    local parent = self:GetParent():GetParent()
    local AzeritBar = parent.AzeritBar
    local spark = AzeritBar.Spark
    local value = AzeritBar:GetValue()

    self:SetPoint("RIGHT", spark, "RIGHT", 0, 0)

    local speed = 0.01
    self.prog = self.prog + speed * elapsed
    if self.prog > 1 then
        self.prog = 0
    end
    local prog = self.prog

    self.texture1:SetTexCoord(0, value, 0, 1)
    self.texture2:SetTexCoord(value, 0, 1, 0)

    if prog < 0.2 then
        self.texture2:SetVertexColor(1, 1, 1, lerp(0, 1, prog / 0.2))
    elseif prog > 0.8 then
        self.texture2:SetVertexColor(1, 1, 1, lerp(1, 0, (prog - 0.8) / 0.2))
    end

    if prog < 0.5 then
        self.texture1:SetVertexColor(1, 1, 1, lerp(0, 0.3, prog / 0.5))
    else
        self.texture1:SetVertexColor(1, 1, 1, lerp(0.3, 0, (prog - 0.5) / 0.5))
    end

    self.texture2:SetTexCoord(1 - prog, prog, 1, 0)
end
GW.AddForProfiling("hud", "animateAzeriteBar", animateAzeriteBar)

local function updateBarSize(self)
    local m = (UIParent:GetWidth() - 180) / 10
    local i = 1
    for _, v in ipairs(self.barOverlay.barSep) do
        local rm = (m * i) + 90
        v:ClearAllPoints()
        v:SetPoint("LEFT", self, "LEFT", rm, 0)
        i = i + 1
    end

    m = (UIParent:GetWidth() - 180)
    self.barOverlay.dubbleBarSep:SetWidth(m)
    self.barOverlay.dubbleBarSep:ClearAllPoints()
    self.barOverlay.dubbleBarSep:SetPoint("LEFT", self, "LEFT", 90, 0)
end
GW.AddForProfiling("hud", "updateBarSize", updateBarSize)


local function LoadXPBar()
    StatusTrackingBarManager:GwKill()
    PetBattleFrameXPBar:GwKill()
    GW.LoadUpcomingSpells()

    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")
    experiencebar.tooltip = {}
    GW.MixinHideDuringOverride(experiencebar)
    experiencebar.rightButton:SetScript("OnClick", xpbar_OnClick)
    experiencebar.rightButton:SetScript(
        "OnEnter",
        function(self)
            local p = self:GetParent()
            p.NextLevel.oldColor = {}
            p.NextLevel.oldColor.r, p.NextLevel.oldColor.g, p.NextLevel.oldColor.b = p.NextLevel:GetTextColor()
            p.NextLevel:SetTextColor(p.NextLevel.oldColor.r * 2, p.NextLevel.oldColor.g * 2, p.NextLevel.oldColor.b * 2)
        end
    )
    experiencebar.rightButton:SetScript(
        "OnLeave",
        function(self)
            local p = self:GetParent()
            if p.NextLevel.oldColor == nil then
                return
            end
            p.NextLevel:SetTextColor(p.NextLevel.oldColor.r, p.NextLevel.oldColor.g, p.NextLevel.oldColor.b)
        end
    )

    experiencebar.AzeritBar.animation:SetScript(
        "OnShow",
        function(self)
            self:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    animateAzeriteBar(self, elapsed)
                end
            )
        end
    )
    experiencebar.AzeritBar.animation:SetScript(
        "OnHide",
        function(self)
            self:SetScript("OnUpdate", nil)
        end
    )

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    experiencebar.RepuBar.repuBarAnimation = 0
    experiencebar.AzeritBar.AzeritBarAnimation = 0
    experiencebar.NextLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    experiencebar.CurrentLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    experiencebar.PetBar:Hide()
    experiencebar.PetBarCandy:Hide()

    updateBarSize(experiencebar)

    experiencebar:SetScript("OnEvent", xpbar_OnEvent)
    -- all
    experiencebar:RegisterEvent("PET_BATTLE_CLOSE")
    experiencebar:RegisterEvent("PET_BATTLE_OPENING_START")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("UPDATE_EXHAUSTION")
    -- honor
    experiencebar:RegisterEvent("HONOR_XP_UPDATE")
    experiencebar:RegisterEvent("ZONE_CHANGED")
    experiencebar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    --azerite
    experiencebar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    -- xp
    experiencebar:RegisterEvent("DISABLE_XP_GAIN")
    experiencebar:RegisterEvent("ENABLE_XP_GAIN")
    experiencebar:RegisterEvent("PLAYER_LEVEL_UP")
    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
    -- pet xp
    experiencebar:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
    experiencebar:RegisterEvent("PET_BATTLE_PET_CHANGED")
    experiencebar:RegisterEvent("PET_BATTLE_XP_CHANGED")
    -- rep
    experiencebar:RegisterEvent("UPDATE_FACTION")
    -- house xp
    experiencebar:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED")
    experiencebar:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
    experiencebar:RegisterEvent("TRACKED_HOUSE_CHANGED")

    local isHonorBarHooked = false
    local function hookHonor()
        if not isHonorBarHooked then
            PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:SetScript("OnMouseUp", function()
                if IsShiftKeyDown() then
                    if IsWatchingHonorAsXP() then
                        PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
                        SetWatchingHonorAsXP(false)
                    else
                        PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
                        SetWatchingHonorAsXP(true)
                    end

                    UpdateData(experiencebar)
                end
            end)

            PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:HookScript("OnEnter", function()
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cffaaaaaa" .. L["Shift-Click to show as experience bar."] .. "|r")
                GameTooltip:Show()
            end)

            PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:HookScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            isHonorBarHooked = true
        end
    end

    if C_AddOns.IsAddOnLoaded("Blizzard_PVPUI") then
        hookHonor()
    else
        hooksecurefunc("UIParentLoadAddOn", function(addOnName)
            if addOnName == "Blizzard_PVPUI" then
                hookHonor()
            end
        end)
    end

    experiencebar.UpdateTooltip = xpbar_OnEnter
    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript(
        "OnLeave",
        function(self)
            GameTooltip_Hide()

            if self.expBarShouldShow then
                UIFrameFadeIn(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 1)
            end
            if self.azeritBarShouldShow then
                UIFrameFadeIn(self.AzeritBar, 0.2, self.AzeritBar:GetAlpha(), 1)
            end
            if self.repuBarShouldShow then
                UIFrameFadeIn(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 1)
            end
        end
    )

    -- to fetch and cache the tracked house data
    local guid = C_Housing.GetTrackedHouseGuid()
    if guid then
        C_Housing.GetCurrentHouseLevelFavor(guid)
    end

    UpdateData(experiencebar)
end
GW.LoadXPBar = LoadXPBar
