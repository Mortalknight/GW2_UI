local _, GW = ...
local L = GW.L
local lerp = GW.lerp
local Diff = GW.Diff
local animations = GW.animations

local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

-- forward function defs
local experiencebarAnimation = 0

local gw_reputation_vals = nil
local gw_honor_vals = nil

local function xpbar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("player")
    local valMax = UnitXPMax("player")
    local rested = GetXPExhaustion()
    local isRestingString = ""

    if IsResting() then
        isRestingString = L[" (Resting)"]
    end

    GameTooltip:AddLine(COMBAT_XP_GAIN .. isRestingString, 1, 1, 1)

    if gw_honor_vals ~= nil then
        GameTooltip:AddLine(gw_honor_vals, 1, 1, 1)
    end

    if not IsPlayerAtEffectiveMaxLevel() then
        GameTooltip:AddLine(
            COMBAT_XP_GAIN ..
            " " ..
            GW.GetLocalizedNumber(valCurrent) ..
            " / " ..
            GW.GetLocalizedNumber(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r",
            1,
            1,
            1
        )
    end

    if rested ~= nil and rested ~= 0 then
        GameTooltip:AddLine(
            L["Rested "] ..
            GW.GetLocalizedNumber(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r",
            1,
            1,
            1
        )
    end

    if self.expBarShouldShow then
        UIFrameFadeOut(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 0)
    end
    if self.azeritBarShouldShow then
        UIFrameFadeOut(self.AzeritBar, 0.2, self.AzeritBar:GetAlpha(), 0)
    end
    if self.repuBarShouldShow then
        UIFrameFadeOut(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 0)
    end

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    local shouldShowAzeritBar = azeriteItemLocation and azeriteItemLocation:IsEquipmentSlot() and
        C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation)

    if shouldShowAzeritBar then
        local azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local xpPct
        if xpForNextPoint > 0 then
            xpPct = math.floor((azeriteXP / xpForNextPoint) * 100) .. "%"
        else
            xpPct = NOT_APPLICABLE
        end
        GameTooltip:AddLine(
            AZERITE_POWER_BAR:format(
                GW.GetLocalizedNumber(azeriteXP) .. " / " .. GW.GetLocalizedNumber(xpForNextPoint) .. " |cffa6a6a6 (" .. xpPct .. ")|r"
            ),
            1,
            1,
            1
        )
    end

    if gw_reputation_vals ~= nil then
        GameTooltip:AddLine(gw_reputation_vals, 1, 1, 1)
    end

    GameTooltip:Show()
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

local function UpdateXPValues(self)
    local valCurrent = UnitXP("player")
    local valMax = UnitXPMax("player")
    local valPrec = (valMax > 0) and (valCurrent / valMax) or 0

    local rested = GetXPExhaustion() or 0
    if rested > 0 then
        rested = math.min(rested / (valMax - valCurrent), 1)
    end

    self.ExpBar:SetStatusBarColor(0.83, 0.57, 0)
    return valPrec, rested
end

local function UpdateReputation(self, lockLevelTextUnderMaxLevel)
    local watchedFactionData = C_Reputation.GetWatchedFactionData()

    local showRepu = false
    local valPrecRepu = 0
    local repuLevel, repuNextLevel = nil, nil
    local level, nextLevel

    if watchedFactionData and watchedFactionData.factionID and watchedFactionData.factionID > 0 then
        local friendReputationInfo = C_GossipInfo.GetFriendshipReputation(watchedFactionData.factionID)
        local isParagon, isFriend, isMajor, isNormal = false, false, false, false
        local MajorCurrentLevel, MajorNextLevel = 0, 0
        showRepu = true


        if C_Reputation.IsFactionParagon(watchedFactionData.factionID) then
            local currentValue, maxValueParagon = C_Reputation.GetFactionParagonInfo(watchedFactionData.factionID)
            currentValue = currentValue % maxValueParagon
            valPrecRepu = (maxValueParagon > 0) and (currentValue / maxValueParagon) or 0
            gw_reputation_vals = string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                watchedFactionData.name, REPUTATION,
                GW.GetLocalizedNumber(currentValue), GW.GetLocalizedNumber(maxValueParagon), math.floor(valPrecRepu * 100))
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
            isParagon = true
            isFriend = (friendReputationInfo and friendReputationInfo.friendshipFactionID > 0)
        elseif friendReputationInfo and friendReputationInfo.friendshipFactionID > 0 then
            if friendReputationInfo.nextThreshold then
                valPrecRepu = (friendReputationInfo.standing - friendReputationInfo.reactionThreshold) /
                                (friendReputationInfo.nextThreshold - friendReputationInfo.reactionThreshold)
                gw_reputation_vals = string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                    friendReputationInfo.name, REPUTATION,
                    GW.GetLocalizedNumber(friendReputationInfo.standing - friendReputationInfo.reactionThreshold),
                    GW.GetLocalizedNumber(friendReputationInfo.nextThreshold - friendReputationInfo.reactionThreshold),
                    math.floor(valPrecRepu * 100))
            else
                valPrecRepu = 1
                gw_reputation_vals = string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                    friendReputationInfo.name, REPUTATION,
                    GW.GetLocalizedNumber(friendReputationInfo.maxRep), GW.GetLocalizedNumber(friendReputationInfo.maxRep), 100)
            end
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
            isFriend = true
        elseif C_Reputation.IsMajorFaction(watchedFactionData.factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(watchedFactionData.factionID)
            if majorFactionData then
                MajorCurrentLevel = majorFactionData.renownLevel
                MajorNextLevel = C_MajorFactions.HasMaximumRenown(watchedFactionData.factionID) and MajorCurrentLevel or (MajorCurrentLevel + 1)
                repuLevel = MajorCurrentLevel
                repuNextLevel = MajorNextLevel
                if C_MajorFactions.HasMaximumRenown(watchedFactionData.factionID) then
                    valPrecRepu = 1
                else
                    valPrecRepu = (majorFactionData.renownReputationEarned or 0) / majorFactionData.renownLevelThreshold
                end
                gw_reputation_vals = string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                    watchedFactionData.name, REPUTATION,
                    GW.GetLocalizedNumber(majorFactionData.renownReputationEarned or 0),
                    GW.GetLocalizedNumber(majorFactionData.renownLevelThreshold),
                    math.floor(valPrecRepu * 100))
                self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[11].r, FACTION_BAR_COLORS[11].g, FACTION_BAR_COLORS[11].b)
                isMajor = true
                repuLevel = MajorCurrentLevel
                repuNextLevel = MajorNextLevel
            end
        else
            -- Normaler Ruf
            local currentStanding = watchedFactionData.currentStanding or 0
            local currentThreshold = watchedFactionData.currentReactionThreshold or 0
            local nextThreshold = watchedFactionData.nextReactionThreshold or 0
            if (currentStanding - currentThreshold) == 0 then
                valPrecRepu = 1
                gw_reputation_vals = string.format("%s %s 21,000 / 21,000 |cffa6a6a6 (%d%%)|r", watchedFactionData.name, REPUTATION, 100)
            else
                valPrecRepu = (currentStanding - currentThreshold) / (nextThreshold - currentThreshold)
                gw_reputation_vals = string.format("%s %s %s / %s |cffa6a6a6 (%d%%)|r",
                    watchedFactionData.name, REPUTATION,
                    GW.GetLocalizedNumber(currentStanding - currentThreshold),
                    GW.GetLocalizedNumber(nextThreshold - currentThreshold),
                    math.floor(valPrecRepu * 100))
            end
            local reaction = watchedFactionData.reaction or 1
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
            isNormal = true

            -- Setze das Level-Label basierend auf Rufdaten:
            local nextId = (watchedFactionData.reaction and watchedFactionData.reaction + 1) or 1

            if not lockLevelTextUnderMaxLevel then
                -- Hier wird level überschrieben, je nach Fraktionstyp:
                level = isMajor and repuLevel or isFriend and friendReputationInfo.reaction or
                        isParagon and getglobal("FACTION_STANDING_LABEL" .. (watchedFactionData.reaction or 1)) or
                        isNormal and getglobal("FACTION_STANDING_LABEL" .. (watchedFactionData.reaction or 1))
                        nextLevel = isParagon and L["Paragon"] or isFriend and "" or isMajor and repuNextLevel or
                        isNormal and getglobal("FACTION_STANDING_LABEL" .. math.min(8, nextId))
            end
        end
    end
    return showRepu, valPrecRepu, level, nextLevel
end

local function UpdateAzerite(self)
    local showAzerite = false
    local AzeritVal, AzeritLevel = 0, 0
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    local shouldShowAzerite = azeriteItemLocation and azeriteItemLocation:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation)
    if shouldShowAzerite then
        showAzerite = true
        local azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        AzeritLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
        AzeritVal = (xpForNextPoint > 0) and (azeriteXP / xpForNextPoint) or 0
        self.AzeritBar:SetStatusBarColor(FACTION_BAR_COLORS[10].r, FACTION_BAR_COLORS[10].g, FACTION_BAR_COLORS[10].b)
        self.AzeritBar.animation:Show()
    end
    return showAzerite, AzeritVal, AzeritLevel
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

local function xpbar_OnEvent(self, event)
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    gw_reputation_vals = nil

    local animationSpeed = 15
    local maxPlayerLevel = GetMaxLevelForPlayerExpansion()
    local restingIconString = IsResting() and " |TInterface\\AddOns\\GW2_UI\\textures\\icons\\resting-icon:16:16:0:0|t " or ""
    local showExp = (GW.mylevel < maxPlayerLevel)
    local level = GW.mylevel
    local Nextlevel = GW.mylevel < maxPlayerLevel and (GW.mylevel + 1) or GW.mylevel
    local lockLevelTextUnderMaxLevel = level < Nextlevel

    local valPrec, rested = UpdateXPValues(self)
    local showRepu, valPrecRepu, repuLevel, repuNextLevel = UpdateReputation(self, lockLevelTextUnderMaxLevel)
    local showAzerite, AzeritVal, AzeritLevel = UpdateAzerite(self)

    if repuLevel and repuNextLevel then
        level = repuLevel
        Nextlevel = repuNextLevel
    end

    gw_honor_vals = nil

    if (GW.mylevel == maxPlayerLevel and (UnitInBattleground("player") or event == "PLAYER_ENTERING_BATTLEGROUND")) or IsWatchingHonorAsXP() then
        showExp = true
        level = UnitHonorLevel("player")
        Nextlevel = level + 1

        local currentHonor = UnitHonor("player")
        local maxHonor = UnitHonorMax("player")
        valPrec = (maxHonor > 0) and (currentHonor / maxHonor) or 0

        gw_honor_vals = HONOR .. " " .. GW.GetLocalizedNumber(currentHonor) .. " / " .. GW.GetLocalizedNumber(maxHonor) .. " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r"
        self.ExpBar:SetStatusBarColor(1, 0.2, 0.2)
    end

    if showAzerite then
        self.AzeritBarCandy:SetValue(AzeritVal)
        GW.AddToAnimation("AzeritBarAnimation", self.AzeritBar.AzeritBarAnimation, AzeritVal, GetTime(), animationSpeed,
            function(p)
                self.AzeritBar.Spark:SetWidth(math.max(8, math.min(9, self.AzeritBar:GetWidth() * p)))
                self.AzeritBar:SetValue(p)
                self.AzeritBar.Spark:SetPoint("LEFT", self.AzeritBar:GetWidth() * p - 8, 0)
            end)
        self.AzeritBar.AzeritBarAnimation = AzeritVal

        if maxPlayerLevel == GW.mylevel then
            level = AzeritLevel
            Nextlevel = AzeritLevel + 1 --Max azerit level is infinity
            self.NextLevel:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            self.CurrentLevel:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            self.labelRight:SetTexture("Interface/AddOns/GW2_UI/textures/hud/level-label-azerit")
            self.labelLeft:SetTexture("Interface/AddOns/GW2_UI/textures/hud/level-label-azerit")
        end
    else
        local texture = (maxPlayerLevel == GW.mylevel) and "Interface/AddOns/GW2_UI/textures/hud/level-label-azerit" or "Interface/AddOns/GW2_UI/textures/hud/level-label"
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
        Nextlevel = Nextlevel .. " |TInterface\\AddOns\\GW2_UI\\textures/icons/levelreward-icon:20:20:0:0|t"
    end
    if GW.mylevel ~= UnitEffectiveLevel("player") then
        level = level .. " |cFF00FF00(" .. UnitEffectiveLevel("player") .. ")|r"
    end

    self.NextLevel:SetText(Nextlevel)
    self.CurrentLevel:SetText(restingIconString .. level)
    self.expBarShouldShow = showExp
    self.azeritBarShouldShow = showAzerite
    self.repuBarShouldShow = showRepu
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
    GW.LoadUpcomingSpells()

    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")
    GW.MixinHideDuringPet(experiencebar)
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
    experiencebar.PetBarBarCandy:Hide()

    updateBarSize(experiencebar)
    xpbar_OnEvent(experiencebar)

    experiencebar:SetScript("OnEvent", xpbar_OnEvent)

    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_FACTION")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    experiencebar:RegisterEvent("ARTIFACT_XP_UPDATE")
    experiencebar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("HONOR_XP_UPDATE")
    experiencebar:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    experiencebar:RegisterEvent("PLAYER_ENTERING_WORLD")
    experiencebar:RegisterEvent("PLAYER_LEVEL_CHANGED")
    experiencebar:RegisterEvent("UPDATE_EXHAUSTION")
    hooksecurefunc("SetWatchingHonorAsXP", function()
        xpbar_OnEvent(experiencebar)
    end)

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
end
GW.LoadXPBar = LoadXPBar
