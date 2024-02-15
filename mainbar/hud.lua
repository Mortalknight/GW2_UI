local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
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
                    CommaValue(valCurrent) ..
                        " / " ..
                            CommaValue(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r",
            1,
            1,
            1
        )
    end

    if rested ~= nil and rested ~= 0 then
        GameTooltip:AddLine(
            L["Rested "] ..
                CommaValue(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r",
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
    local shouldShowAzeritBar = azeriteItemLocation and azeriteItemLocation:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation)

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
                CommaValue(azeriteXP) .. " / " .. CommaValue(xpForNextPoint) .. " |cffa6a6a6 (" .. xpPct .. ")|r"
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

    AddToAnimation(
        "GwXpFlare",
        0,
        1,
        GetTime(),
        1,
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

local function xpbar_OnEvent(self, event)
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    local shouldShowAzeritBar = azeriteItemLocation and azeriteItemLocation:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation)
    local AzeritVal = 0
    local AzeritLevel = 0

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local valPrec = valCurrent / valMax
    local valPrecRepu = 0

    local level = GW.mylevel
    local maxPlayerLevel = GetMaxLevelForPlayerExpansion()
    local Nextlevel = math.min(maxPlayerLevel, level + 1)
    local lockLevelTextUnderMaxLevel = level < Nextlevel

    local rested = GetXPExhaustion()
    local showBar1 = level < Nextlevel
    local showBar2 = false
    local showBar3 = false
    local restingIconString = IsResting() and " |TInterface\\AddOns\\GW2_UI\\textures\\icons\\resting-icon:16:16:0:0|t " or ""

    if rested == nil or (rested / valMax) == 0 then
        rested = 0
    else
        rested = math.min((rested / (valMax - valCurrent)), 1)
    end

    local animationSpeed = 15

    self.ExpBar:SetStatusBarColor(0.83, 0.57, 0)

    gw_reputation_vals = nil

    local name, reaction, _, _, _, factionID = GetWatchedFactionInfo()
    if factionID and factionID > 0 then
        local _, _, standingId, bottomValue, topValue, earnedValue = GetFactionInfoByID(factionID)
        local friendReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        local friendshipID = friendReputationInfo.friendshipFactionID

        local isParagon = false
        local isFriend = false
        local isMajor = false
        local isNormal = false

        local MajorCurrentLevel = 0
        local MajorNextLevel = 0
        if C_Reputation.IsFactionParagon(factionID) then
            local currentValue, maxValueParagon = C_Reputation.GetFactionParagonInfo(factionID)

            currentValue = currentValue % maxValueParagon;
            valPrecRepu = (currentValue - 0) / (maxValueParagon - 0)

            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue(currentValue - 0) .. " / " .. CommaValue(maxValueParagon - 0) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"

            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
            isParagon = true
            isFriend = friendshipID > 0
        elseif friendshipID > 0 then
            if friendReputationInfo.nextThreshold then
                valPrecRepu = (friendReputationInfo.standing - friendReputationInfo.reactionThreshold) / (friendReputationInfo.nextThreshold - friendReputationInfo.reactionThreshold)
                gw_reputation_vals = friendReputationInfo.name .. " " .. REPUTATION .. " " .. CommaValue(friendReputationInfo.standing - friendReputationInfo.reactionThreshold) .. " / " .. CommaValue(friendReputationInfo.nextThreshold - friendReputationInfo.reactionThreshold) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            else
                valPrecRepu = 1
                gw_reputation_vals = friendReputationInfo.name .. " " .. REPUTATION .. " " .. CommaValue(friendReputationInfo.maxRep) .. " / " .. CommaValue(friendReputationInfo.maxRep) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            end
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
            self.RepuBarCandy:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
            isFriend = true
        elseif C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

            MajorCurrentLevel = majorFactionData.renownLevel
            MajorNextLevel = C_MajorFactions.HasMaximumRenown(factionID) and MajorCurrentLevel or MajorCurrentLevel + 1

            if C_MajorFactions.HasMaximumRenown(factionID) then
                valPrecRepu = 1
            else
                valPrecRepu = ((majorFactionData.renownReputationEarned or 0)) / majorFactionData.renownLevelThreshold
            end
            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue((majorFactionData.renownReputationEarned or 0)) .. " / " .. CommaValue(majorFactionData.renownLevelThreshold) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"

            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[11].r, FACTION_BAR_COLORS[11].g, FACTION_BAR_COLORS[11].b)
            self.RepuBarCandy:SetStatusBarColor(FACTION_BAR_COLORS[11].r, FACTION_BAR_COLORS[11].g, FACTION_BAR_COLORS[11].b)
            isMajor = true
        else
            local currentRank = GetText("FACTION_STANDING_LABEL" .. min(8, max(1, (standingId or 1))), GW.mysex)
            local nextRank = GetText("FACTION_STANDING_LABEL" .. min(8, max(1, (standingId or 1) + 1)), GW.mysex)

            earnedValue = earnedValue or 0 --fallback
            topValue = topValue or 0 --fallback
            bottomValue = bottomValue or 0 --fallback
            if currentRank == nextRank and earnedValue - bottomValue == 0 then
                valPrecRepu = 1
                gw_reputation_vals = name .. " " .. REPUTATION .. " 21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            else
                valPrecRepu = (earnedValue - bottomValue) / (topValue - bottomValue)
                gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue((earnedValue - bottomValue)) .. " / " .. CommaValue((topValue - bottomValue)) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            end
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
            self.RepuBarCandy:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
            isNormal = true
        end

        local nextId = standingId and standingId + 1 or 1
        if not lockLevelTextUnderMaxLevel then
            level = isMajor and MajorCurrentLevel or isFriend and friendReputationInfo.reaction or isParagon and getglobal("FACTION_STANDING_LABEL" .. (standingId or 1)) or isNormal and getglobal("FACTION_STANDING_LABEL" .. (standingId or 1))
            Nextlevel = isParagon and L["Paragon"] or isFriend and "" or isMajor and MajorNextLevel or isNormal and getglobal("FACTION_STANDING_LABEL" .. math.min(8, nextId))
        end

        showBar3 = true
    end

    if shouldShowAzeritBar then
        showBar2 = true
        local azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        AzeritLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

        if xpForNextPoint > 0 then
            AzeritVal = azeriteXP / xpForNextPoint
        else
            AzeritVal = 0
        end
        self.AzeritBar:SetStatusBarColor(
            FACTION_BAR_COLORS[10].r,
            FACTION_BAR_COLORS[10].g,
            FACTION_BAR_COLORS[10].b
        )
        self.AzeritBar.animation:Show()
    end

    if showBar2 then
        self.AzeritBarCandy:SetValue(AzeritVal)

        AddToAnimation(
            "AzeritBarAnimation",
            self.AzeritBar.AzeritBarAnimation,
            AzeritVal,
            GetTime(),
            animationSpeed,
            function(p)
                self.AzeritBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(9, self.AzeritBar:GetWidth() * p)
                    )
                )

                self.AzeritBar:SetValue(p)
                self.AzeritBar.Spark:SetPoint("LEFT", self.AzeritBar:GetWidth() * p - 8, 0)
            end
        )
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

    --If we are inside a pvp arena we show the honorbar
    gw_honor_vals = nil

    if (GW.mylevel == maxPlayerLevel and (UnitInBattleground("player") ~= nil or event == "PLAYER_ENTERING_BATTLEGROUND")) or IsWatchingHonorAsXP() then
        showBar1 = true
        level = UnitHonorLevel("player")
        Nextlevel = level + 1

        local currentHonor = UnitHonor("player")
        local maxHonor = UnitHonorMax("player")
        valPrec = currentHonor / maxHonor

        gw_honor_vals =
            HONOR ..
                " " ..
                    CommaValue(currentHonor) ..
                        " / " .. CommaValue(maxHonor) .. " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r"
            self.ExpBar:SetStatusBarColor(1, 0.2, 0.2)
    end

    if showBar1 then
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

        AddToAnimation(
            "experiencebarAnimation",
            experiencebarAnimation,
            valPrec,
            GetTime(),
            animationSpeed,
            function(step)
                self.ExpBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(9,self.ExpBar:GetWidth() * step)
                    )
                )

                if not GainBigExp then
                    self.ExpBar:SetValue(step)
                    self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * step - 8, 0)

                    local flarePoint = ((UIParent:GetWidth() - 180) * step) + 90
                    self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)
                end
                self.ExpBar.Rested:SetValue(rested)
                self.ExpBar.Rested:SetPoint("LEFT", self.ExpBar, "LEFT", self.ExpBar:GetWidth() * step, 0)

                if GainBigExp and self.barOverlay.flare.soundCooldown < GetTime() then
                    expSoundCooldown =
                        math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                        self.ExpBar:SetValue(step)
                        self.ExpBar.Spark:SetPoint(
                        "LEFT",
                        self.ExpBar:GetWidth() * step - 8,
                        0
                    )

                    local flarePoint = ((UIParent:GetWidth() - 180) * step) + 90
                    self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)

                    self.barOverlay.flare.soundCooldown = GetTime() + expSoundCooldown
                    PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\exp_gain_ping.ogg", "SFX")

                    animations["experiencebarAnimation"].from = step
                end
            end
        )
        AddToAnimation(
            "GwExperienceBarCandy",
            experiencebarAnimation,
            valPrec,
            GetTime(),
            0.3,
            function(p)
                self.ExpBarCandy:SetValue(p)
            end
        )
    end

    if showBar3 then
        self.RepuBarCandy:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            self.RepuBar.repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function(p)
                self.RepuBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(9, self.RepuBar:GetWidth() * p)
                    )
                )

                self.RepuBar:SetValue(p)
                self.RepuBar.Spark:SetPoint("LEFT", self.RepuBar:GetWidth() * p - 8, 0)
            end
        )
        self.RepuBar.repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

    if GW.IsUpcomingSpellAvalible() then
        Nextlevel = Nextlevel and Nextlevel .. " |TInterface/AddOns/GW2_UI/textures/icons/levelreward-icon:20:20:0:0|t" or ""
    end

    if GW.mylevel ~= UnitEffectiveLevel("player") then
        level = level .. " |cFF00FF00(" .. UnitEffectiveLevel("player") .. ")|r"
    end

    self.NextLevel:SetText(Nextlevel)
    self.CurrentLevel:SetText(restingIconString .. level)
    self.expBarShouldShow = showBar1
    self.azeritBarShouldShow = showBar2
    self.repuBarShouldShow = showBar3
    if showBar1 and showBar2 and showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(2.66)
        self.ExpBarCandy:SetHeight(2.66)
        self.ExpBar.Spark:SetHeight(2.66)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.AzeritBar:Show()
        self.AzeritBarCandy:Show()
        self.AzeritBar.animation:Show()
        self.AzeritBar:SetHeight(2.66)
        self.AzeritBar.animation:SetHeight(2.66)
        self.AzeritBarCandy:SetHeight(2.66)
        self.AzeritBar.Spark:SetHeight(2.66)
        self.AzeritBar.Spark:Show()
        self.AzeritBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.AzeritBar:SetPoint("TOPLEFT", 90, -8)
        self.AzeritBar:SetPoint("TOPRIGHT", -90, -8)

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(2.66)
        self.RepuBarCandy:SetHeight(2.66)
        self.RepuBar.Spark:SetHeight(2.66)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -12)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -12)
        self.RepuBar:SetPoint("TOPLEFT", 90, -12)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -12)
    elseif showBar1 and not showBar2 and showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(4)
        self.ExpBarCandy:SetHeight(4)
        self.ExpBar.Spark:SetHeight(4)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.AzeritBar:Hide()
        self.AzeritBarCandy:Hide()
        self.AzeritBar.animation:Hide()
        self.AzeritBar:SetValue(0)
        self.AzeritBarCandy:SetValue(0)
        self.AzeritBar.Spark:Hide()

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(4)
        self.RepuBarCandy:SetHeight(4)
        self.RepuBar.Spark:SetHeight(4)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.RepuBar:SetPoint("TOPLEFT", 90, -8)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and showBar2 and showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.AzeritBar:Show()
        self.AzeritBarCandy:Show()
        self.AzeritBar.animation:Show()
        self.AzeritBar:SetHeight(4)
        self.AzeritBar.animation:SetHeight(4)
        self.AzeritBarCandy:SetHeight(4)
        self.AzeritBar.Spark:SetHeight(4)
        self.AzeritBar.Spark:Show()
        self.AzeritBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.AzeritBar:SetPoint("TOPLEFT", 90, -4)
        self.AzeritBar:SetPoint("TOPRIGHT", -90, -4)

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(4)
        self.RepuBarCandy:SetHeight(4)
        self.RepuBar.Spark:SetHeight(4)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.RepuBar:SetPoint("TOPLEFT", 90, -8)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and not showBar2 and showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.AzeritBar:Hide()
        self.AzeritBarCandy:Hide()
        self.AzeritBar.animation:Hide()
        self.AzeritBar:SetValue(0)
        self.AzeritBarCandy:SetValue(0)
        self.AzeritBar.Spark:Hide()

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(8)
        self.RepuBarCandy:SetHeight(8)
        self.RepuBar.Spark:SetHeight(8)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.RepuBar:SetPoint("TOPLEFT", 90, -4)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -4)
    elseif not showBar1 and not showBar2 and not showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.AzeritBar:Hide()
        self.AzeritBarCandy:Hide()
        self.AzeritBar.animation:Hide()
        self.AzeritBar:SetValue(0)
        self.AzeritBarCandy:SetValue(0)
        self.AzeritBar.Spark:Hide()

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    elseif showBar1 and not showBar2 and not showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(8)
        self.ExpBarCandy:SetHeight(8)
        self.ExpBar.Spark:SetHeight(8)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.AzeritBar:Hide()
        self.AzeritBarCandy:Hide()
        self.AzeritBar.animation:Hide()
        self.AzeritBar:SetValue(0)
        self.AzeritBarCandy:SetValue(0)
        self.AzeritBar.Spark:Hide()

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    elseif showBar1 and showBar2 and not showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(4)
        self.ExpBarCandy:SetHeight(4)
        self.ExpBar.Spark:SetHeight(4)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.AzeritBar:Show()
        self.AzeritBarCandy:Show()
        self.AzeritBar.animation:Show()
        self.AzeritBar:SetHeight(4)
        self.AzeritBar.animation:SetHeight(4)
        self.AzeritBarCandy:SetHeight(4)
        self.AzeritBar.Spark:SetHeight(4)
        self.AzeritBar.Spark:Show()
        self.AzeritBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.AzeritBar:SetPoint("TOPLEFT", 90, -8)
        self.AzeritBar:SetPoint("TOPRIGHT", -90, -8)

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    elseif not showBar1 and showBar2 and not showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.AzeritBar:Show()
        self.AzeritBarCandy:Show()
        self.AzeritBar.animation:Show()
        self.AzeritBar:SetHeight(8)
        self.AzeritBar.animation:SetHeight(8)
        self.AzeritBarCandy:SetHeight(8)
        self.AzeritBar.Spark:SetHeight(8)
        self.AzeritBar.Spark:Show()
        self.AzeritBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.AzeritBar:SetPoint("TOPLEFT", 90, -4)
        self.AzeritBar:SetPoint("TOPRIGHT", -90, -4)

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end
end
GW.AddForProfiling("hud", "xpbar_OnEvent", xpbar_OnEvent)

local function animateAzeriteBar(self, elapsed)
    self:SetPoint("RIGHT", self:GetParent():GetParent().AzeritBar.Spark, "RIGHT", 0, 0)
    local speed = 0.01
    self.prog = self.prog + (speed * elapsed)
    if self.prog > 1 then
        self.prog = 0
    end

    self.texture1:SetTexCoord(0, self:GetParent():GetParent().AzeritBar:GetValue(), 0, 1)
    self.texture2:SetTexCoord(self:GetParent():GetParent().AzeritBar:GetValue(), 0, 1, 0)

    if self.prog < 0.2 then
        self.texture2:SetVertexColor(1, 1, 1, lerp(0, 1, self.prog / 0.2))
    elseif self.prog > 0.8 then
        self.texture2:SetVertexColor(1, 1, 1, lerp(1, 0, (self.prog - 0.8) / 0.2))
    end
    if self.prog > 0.5 then
        self.texture1:SetVertexColor(1, 1, 1, lerp(0.3, 0, (self.prog - 0.5) / 0.5))
    elseif self.prog < 0.5 then
        self.texture1:SetVertexColor(1, 1, 1, lerp(0, 0.3, self.prog / 0.5))
    end
    self.texture2:SetTexCoord(1 - self.prog, self.prog, 1, 0)
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

local function registerActionHudAura(auraID, left, right, unit)
    if unit == "player" then
        actionHudPlayerAuras[auraID] = {}
        actionHudPlayerAuras[auraID].auraID = auraID
        actionHudPlayerAuras[auraID].left = left
        actionHudPlayerAuras[auraID].right = right
        actionHudPlayerAuras[auraID].unit = unit
    elseif unit == "pet" then
        actionHudPlayerPetAuras[auraID] = {}
        actionHudPlayerPetAuras[auraID].auraID = auraID
        actionHudPlayerPetAuras[auraID].left = left
        actionHudPlayerPetAuras[auraID].right = right
        actionHudPlayerPetAuras[auraID].unit = unit
    end
end
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

local currentTexture = nil

local function selectBg(self)
    if not GW.settings.HUD_BACKGROUND or not GW.settings.HUD_SPELL_SWAP then
        return
    end

    local right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow"
    local left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow"

    if UnitIsDeadOrGhost("player") then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_dead"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_dead"
    end

    if GW.myClassID == 11 then --Druid
        local ShapeshiftFormID = GetShapeshiftFormID()
        if ShapeshiftFormID == BEAR_FORM then
            right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_bear"
            left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_bear"
        elseif ShapeshiftFormID == CAT_FORM then
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

        local bolFound = false
        --player buffs
        for k, v in pairs(actionHudPlayerAuras) do
            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(k)
            if auraData then
                right = v.right
                left = v.left
                bolFound = true
                break
            end
        end
        -- pet buffs
        if not bolFound then
            for i = 1, 40 do
                local auraData = C_UnitAuras.GetBuffDataByIndex("pet", i)
                if auraData and actionHudPlayerPetAuras[auraData.spellId] and actionHudPlayerPetAuras[auraData.spellId].unit == "pet" then
                    right = actionHudPlayerPetAuras[auraData.spellId].right
                    left = actionHudPlayerPetAuras[auraData.spellId].left
                    break
                end
            end
        end
    end

    if currentTexture ~= left then
        currentTexture = left
        self.actionBarHud.Right:SetTexture(right)
        self.actionBarHud.Left:SetTexture(left)
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
    "player"
)

local function hud_OnEvent(self, event, ...)
    if event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            selectBg(self)
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        selectBg(self)
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = ...
        if unit == "player" then
            combatHealthState(self)
        end
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

        --Gw2MicroBarFrame.cf.bg:SetShown(showBorder)
    end
end
GW.ToggleHudBackground = ToggleHudBackground

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "Gw2_HudBackgroud", UIParent, "GwHudArtFrame")
    GW.MixinHideDuringPetAndOverride(hudArtFrame)

    ToggleHudBackground()
    GW.RegisterScaleFrame(hudArtFrame.actionBarHud)

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    GW.Libs.GW2Lib.RegisterCallback(hudArtFrame, "GW2_PLAYER_DRAGONRIDING_STATE_CHANGE", function()
        selectBg(hudArtFrame)
    end)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
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
    experiencebar.NextLevel:SetFont(UNIT_NAME_FONT, 12)
    experiencebar.CurrentLevel:SetFont(UNIT_NAME_FONT, 12)

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
