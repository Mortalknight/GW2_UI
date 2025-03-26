local _, GW = ...
local L = GW.L
local lerp = GW.lerp
local Diff = GW.Diff
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
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

    AddToAnimation("GwXpFlare", 0, 1, GetTime(), 1,
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
        AddToAnimation("AzeritBarAnimation", self.AzeritBar.AzeritBarAnimation, AzeritVal, GetTime(), animationSpeed,
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

        AddToAnimation("experiencebarAnimation", experiencebarAnimation, valPrec, GetTime(), animationSpeed, function(step)
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
                PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\exp_gain_ping.ogg", "SFX")
                animations.experiencebarAnimation.from = step
            end
        end)
        AddToAnimation("GwExperienceBarCandy", experiencebarAnimation, valPrec, GetTime(), 0.3, function(p)
            self.ExpBarCandy:SetValue(p)
        end)
    end

    if showRepu then
        animationSpeed = 15
        self.RepuBarCandy:SetValue(valPrecRepu)
        AddToAnimation("repuBarAnimation", self.RepuBar.repuBarAnimation, valPrecRepu, GetTime(), animationSpeed, function(p)
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

local actionHudPlayerAuras = {}
local actionHudPlayerPetAuras = {}

local function registerActionHudAura(auraID, left, right, unit, modelFX)
    if unit == "player" then
        actionHudPlayerAuras[auraID] = {}
        actionHudPlayerAuras[auraID].auraID = auraID
        actionHudPlayerAuras[auraID].left = left
        actionHudPlayerAuras[auraID].right = right
        actionHudPlayerAuras[auraID].unit = unit
        actionHudPlayerAuras[auraID].modelFX = modelFX
    elseif unit == "pet" then
        actionHudPlayerPetAuras[auraID] = {}
        actionHudPlayerPetAuras[auraID].auraID = auraID
        actionHudPlayerPetAuras[auraID].left = left
        actionHudPlayerPetAuras[auraID].right = right
        actionHudPlayerPetAuras[auraID].unit = unit
        actionHudPlayerPetAuras[auraID].modelFX = modelFX
    end
end
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

-- For creates a model effect somewhere on the hud with a trigger buff
local function createModelFx(modelFX)
    local anchor = modelFX.anchor
    local modelID = modelFX.modelID
    local modelPosition = modelFX.modelPosition

    if modelID == Gw2_HudBackgroud.actionBarHudFX.currentModelID and Gw2_HudBackgroud.actionBarHudFX:IsShown() then
        return
    end

    if _G[anchor.target] == nil then
        return
    end
    Gw2_HudBackgroud.actionBarHudFX.currentModelID = modelID
    Gw2_HudBackgroud.actionBarHudFX:MakeCurrentCameraCustom()
    Gw2_HudBackgroud.actionBarHudFX:SetParent(UIParent)
    Gw2_HudBackgroud.actionBarHudFX:SetFrameStrata(Gw2_HudBackgroud:GetFrameStrata())
    Gw2_HudBackgroud.actionBarHudFX:SetFrameLevel(Gw2_HudBackgroud:GetFrameLevel() - 1)
    Gw2_HudBackgroud.actionBarHudFX:SetModel(modelID)
    Gw2_HudBackgroud.actionBarHudFX:SetPosition(modelPosition.x, modelPosition.y, modelPosition.z)
    Gw2_HudBackgroud.actionBarHudFX:SetFacing(modelPosition.rotation)
    Gw2_HudBackgroud.actionBarHudFX:ClearAllPoints()
    Gw2_HudBackgroud.actionBarHudFX:SetPoint(anchor.point, anchor.target, anchor.relPoint, anchor.x, anchor.y)
    Gw2_HudBackgroud.actionBarHudFX:Show()

    if GwHudFXDebug then
        GwHudFXDebug.x:SetText(modelPosition.x)
        GwHudFXDebug.y:SetText(modelPosition.y)
        GwHudFXDebug.z:SetText(modelPosition.z)
        GwHudFXDebug.rotation:SetText(modelPosition.rotation)
    end
end
GW.AddForProfiling("hud", "createModelFx", createModelFx)

local currentTexture = nil

local function selectBg(self)
    if not GW.settings.HUD_BACKGROUND or not GW.settings.HUD_SPELL_SWAP then
        return
    end

    local right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow"
    local left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow"
    local modelFX = nil

    if UnitIsDeadOrGhost("player") then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_dead"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_dead"
    end

    if GW.myClassID == 11 then --Druid
        local form = GetShapeshiftFormID()
        if form == BEAR_FORM then
            right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_bear"
            left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_bear"
        elseif form == CAT_FORM then
            right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_cat"
            left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_cat"
        end
    end

    if GW.Libs.GW2Lib:IsPlayerDragonRiding() then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow-dragon"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow-dragon"
    end

    if UnitAffectingCombat("player") then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadowcombat"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadowcombat"

        local auraFound = false
        for spellID, auraData in pairs(actionHudPlayerAuras) do
            if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
                right = auraData.right
                left = auraData.left
                modelFX = auraData.modelFX
                auraFound = true
                break
            end
        end

        -- pet buffs
        if not auraFound then
            for i = 1, 40 do
                local auraData = C_UnitAuras.GetBuffDataByIndex("pet", i)
                local petAura = auraData and actionHudPlayerPetAuras[auraData.spellId]
                if petAura and petAura.unit == "pet" then
                    right = petAura.right
                    left = petAura.left
                    modelFX = petAura.modelFX
                    break
                end
            end
        end
    end

    if modelFX then
        createModelFx(modelFX)
    elseif self.actionBarHudFX:IsShown() and not GwHudFXDebug then
        self.actionBarHudFX:Hide()
    end

    if currentTexture ~= left then
        currentTexture = left
        self.actionBarHud.Right:SetTexture(right)
        self.actionBarHud.Left:SetTexture(left)

        AddToAnimation("DynamicHud", 0, 1, GetTime(), 0.2, function(prog)
            self.actionBarHud.Right:SetAlpha(prog)
            self.actionBarHud.Left:SetAlpha(prog)
        end)
    end
end
GW.AddForProfiling("hud", "selectBg", selectBg)

local function combatHealthState(self)
    if not GW.settings.HUD_BACKGROUND then
        return
    end

    local unitHealthPrecentage = UnitHealth("player") / UnitHealthMax("player")

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5
        local alpha = 1 - unitHealthPrecentage - 0.2
        if alpha < 0 then alpha = 0 end
        if alpha > 1 then alpha = 1 end

        self.actionBarHud.Left:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.Right:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.RightSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.LeftSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, alpha)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, alpha)
    else
        self.actionBarHud.Left:SetVertexColor(1, 1, 1)
        self.actionBarHud.Right:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftSwim:SetVertexColor(1, 1, 1)
        self.actionBarHud.RightSwim:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 0)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, 0)
    end
end
GW.AddForProfiling("hud", "combatHealthState", combatHealthState)

registerActionHudAura(
    31842,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_holy",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_holy",
    "player"
)
registerActionHudAura(
    31884,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_holy",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_holy",
    "player"
)
registerActionHudAura(
    51271,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_frost",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_frost",
    "player"
)
registerActionHudAura(
    162264,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_metamorph",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_metamorph",
    "player"
)
registerActionHudAura(
    187827,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_metamorph",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_metamorph",
    "player"
)
registerActionHudAura(
    215785,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_shaman_fire",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    77762,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_shaman_fire",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    201846,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_shaman_storm",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_shaman_storm",
    "player"
)
registerActionHudAura(
    63560,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_unholy",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_unholy",
    "pet"
)
registerActionHudAura(
    375087,
    "Interface/AddOns/GW2_UI/textures/hud/evokerdpsLeft",
    "Interface/AddOns/GW2_UI/textures/hud/evokerdpsRight",
    "player", {
        anchor = {
            point = "BOTTOM",
            relPoint = "BOTTOM",
            target = "Gw2_HudBackgroud",
            x = 0,
            y = 50

        },
        modelID = 4697927,

        modelPosition =
        { x = 2, y = 0, z = 0, rotation = 0 }
    }
)
-- Lunar Eclipse
registerActionHudAura(
    48518,
    "Interface/AddOns/GW2_UI/textures/hud/left_lunareclipse",
    "Interface/AddOns/GW2_UI/textures/hud/right_lunareclipse",
    "player",
    {
        anchor = {
            point = "BOTTOM",
            relPoint = "BOTTOM",
            target = "Gw2_HudBackgroud",
            x = 0,
            y = 100

        },
        modelID = 1513212,

        modelPosition =
        {
            x = -2.5,
            y = 0,
            z = -3.4,
            rotation = 0
        }
    }
)
--Solar Eclipse
registerActionHudAura(
    48517,
    "Interface/AddOns/GW2_UI/textures/hud/left_solareclips",
    "Interface/AddOns/GW2_UI/textures/hud/right_solareclips",
    "player",
    {
        anchor = {
            point = "BOTTOM",
            relPoint = "BOTTOM",
            target = "Gw2_HudBackgroud",
            x = 0,
            y = 100

        },
        modelID = 530798,

        modelPosition =
        {
            x = 2,
            y = 0,
            z = -0.1,
            rotation = 0
        }
    }
)



local function updateDebugPosition()
    local x = tonumber(GwHudFXDebug.x:GetText())
    local y = tonumber(GwHudFXDebug.y:GetText())
    local z = tonumber(GwHudFXDebug.z:GetText())
    local rotation = tonumber(GwHudFXDebug.rotation:GetText())
    if x ~= nil and y ~= nil and z ~= nil and rotation ~= nil then
        Gw2_HudBackgroud.actionBarHudFX:SetPosition(x, y, z)
        Gw2_HudBackgroud.actionBarHudFX:SetFacing(rotation)
        GwHudFXDebug.editbox:SetText(
            "{ x = " .. x .. ", y = " .. y .. ", z = " .. z .. ", rotation = " .. rotation .. " }"
        );
    end
end

local function createCoordDebugInput(self, labelText, index)
    local f = CreateFrame("EditBox", nil, self)
    f:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -(22 * index))
    f:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0 - (22 * index))
    f:SetSize(20, 20)
    f:SetAutoFocus(false)
    f:SetMultiLine(false)
    f:SetMaxLetters(50)
    f:SetFontObject(ChatFontNormal)
    f:SetText("")

    f.bg = f:CreateTexture(nil, "ARTWORK", nil, 1)
    f.bg:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg") -- add custom overlay texture here
    f.bg:SetAllPoints()

    f.label = f:CreateFontString(nil, "ARTWORK")
    f.label:SetPoint("RIGHT", f, "LEFT", 0, 0)
    f.label:SetJustifyH("LEFT")
    f.label:SetJustifyV("MIDDLE")
    f.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    f.label:SetText(labelText)

    f:SetScript("OnTextChanged", function() updateDebugPosition() end)
    return f
end

local function loadFXModelDebug()
    --debug stuff
    local debugModelPositionData = CreateFrame("Frame", "GwHudFXDebug", UIParent)
    debugModelPositionData:SetSize(300, 300)
    debugModelPositionData:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    debugModelPositionData.bg = debugModelPositionData:CreateTexture(nil, "ARTWORK", nil, 1)
    debugModelPositionData.bg:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg") -- add custom overlay texture here
    debugModelPositionData.bg:SetAllPoints()
    debugModelPositionData.bg:SetSize(300, 300)

    debugModelPositionData.editbox = CreateFrame("EditBox", nil, debugModelPositionData)
    debugModelPositionData.editbox:SetPoint("TOPLEFT", debugModelPositionData, "TOPLEFT", 5, -5)
    debugModelPositionData.editbox:SetPoint("BOTTOMRIGHT", debugModelPositionData, "BOTTOMRIGHT", -5, 5)
    debugModelPositionData.editbox:SetAutoFocus(false)
    debugModelPositionData.editbox:SetMultiLine(true)
    debugModelPositionData.editbox:SetMaxLetters(2000)
    debugModelPositionData.editbox:SetFontObject(ChatFontNormal)
    debugModelPositionData.editbox:SetText("")

    debugModelPositionData.x = createCoordDebugInput(debugModelPositionData, "X:", 1)
    debugModelPositionData.y = createCoordDebugInput(debugModelPositionData, "Y:", 2)
    debugModelPositionData.z = createCoordDebugInput(debugModelPositionData, "Z:", 3)
    debugModelPositionData.rotation = createCoordDebugInput(debugModelPositionData, "Rotation:", 4)
end

--[[
C_Timer.After(1, function()
    loadFXModelDebug()
end)
]]


local function hud_OnEvent(self, event, ...)
    if event == "UNIT_AURA" then
        selectBg(self)
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        selectBg(self)
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        combatHealthState(self)
    end
end
GW.AddForProfiling("hud", "hud_OnEvent", hud_OnEvent)

local function ToggleHudBackground()
    if Gw2_HudBackgroud.actionBarHud.HUDBG then
        for _, f in ipairs(Gw2_HudBackgroud.actionBarHud.HUDBG) do
            if GW.settings.HUD_BACKGROUND then
                f:Show()
            else
                f:Hide()
            end
        end
    end

    if Gw2_HudBackgroud.edgeTint then
        local showBorder = GW.settings.BORDER_ENABLED
        for _, f in ipairs(Gw2_HudBackgroud.edgeTint) do
            if showBorder then
                f:Show()
            else
                f:Hide()
            end
        end
    end
end
GW.ToggleHudBackground = ToggleHudBackground

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "Gw2_HudBackgroud", UIParent, "GwHudArtFrame")
    GW.MixinHideDuringPetAndOverride(hudArtFrame)

    ToggleHudBackground()
    GW.RegisterScaleFrame(hudArtFrame.actionBarHud)

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)
    hud_OnEvent(hudArtFrame, "INIT")

    GW.Libs.GW2Lib.RegisterCallback(hudArtFrame, "GW2_PLAYER_DRAGONRIDING_STATE_CHANGE", function()
        selectBg(hudArtFrame)
    end)

    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_AURA", "player")
    selectBg(hudArtFrame)
    combatHealthState(hudArtFrame)

    --Loss Of Control Icon Skin
    LossOfControlFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    return hudArtFrame
end
GW.LoadHudArt = LoadHudArt

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
