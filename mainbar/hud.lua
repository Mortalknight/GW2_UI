local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local Diff = GW.Diff
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

-- forward function defs
local displayRewards

local experiencebarAnimation = 0
local GW_LEVELING_REWARD_AVALIBLE

local gw_reputation_vals = nil
local gw_honor_vals = nil

local function xpbar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
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

    UIFrameFadeOut(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 0)
    UIFrameFadeOut(self.AzeritBar, 0.2, self.AzeritBar:GetAlpha(), 0)
    UIFrameFadeOut(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 0)

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    local shouldShowAzeritBar = azeriteItemLocation and azeriteItemLocation:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation)

    if shouldShowAzeritBar then
        local azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local xpPct
        if xpForNextPoint > 0 then
            xpPct = math.floor((azeriteXP / xpForNextPoint) * 100) .. "%"
        else
            xpPct = "n/a"
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
    GwExperienceBar.barOverlay.flare:Show()

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

    displayRewards()

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
    local lockLevelTextUnderMaxLevel = false

    local rested = GetXPExhaustion()
    local showBar1 = false
    local showBar2 = false
    local showBar3 = false
    local restingIconString = " |TInterface/AddOns/GW2_UI/textures/icons/resting-icon:16:16:0:0|t "

    if not IsResting() then
        restingIconString = ""
    end
    if rested == nil or (rested / valMax) == 0 then
        rested = 0
    else
        rested = rested / (valMax - valCurrent)
    end
    if rested > 1 then
        rested = 1
    end

    if level < Nextlevel then
        showBar1 = true
        lockLevelTextUnderMaxLevel = true
    end

    local animationSpeed = 15

    self.ExpBar:SetStatusBarColor(0.83, 0.57, 0)

    gw_reputation_vals = nil

    local name, reaction, _, _, _, factionID = GetWatchedFactionInfo()
    if factionID and factionID > 0 then
        local _, _, standingId, bottomValue, topValue, earnedValue = GetFactionInfoByID(factionID)
        local friendID, friendRep, friendMaxRep, friendName, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
        local isParagon = false
        local isFriend = false
        local isNormal = false
        if C_Reputation.IsFactionParagon(factionID) then
            local currentValue, maxValueParagon = C_Reputation.GetFactionParagonInfo(factionID)

            if currentValue > 10000 then
                repeat
                    currentValue = currentValue - 10000
                until (currentValue < 10000)
            end
            valPrecRepu = (currentValue - 0) / (maxValueParagon - 0)
            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue((currentValue - 0)) .. " / " .. CommaValue((maxValueParagon - 0)) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"

            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[9].r, FACTION_BAR_COLORS[9].g, FACTION_BAR_COLORS[9].b)
            isParagon = true
        elseif friendID ~= nil then
            if nextFriendThreshold then
                valPrecRepu = (friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)
                gw_reputation_vals = friendName .. " " .. REPUTATION .. " " .. CommaValue((friendRep - friendThreshold)) .. " / " .. CommaValue((nextFriendThreshold - friendThreshold)) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            else
                valPrecRepu = 1
                gw_reputation_vals = friendName .. " " .. REPUTATION .. " " .. CommaValue(friendMaxRep) .. " / " .. CommaValue(friendMaxRep) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            end
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)
            isFriend = true
        else
            local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), GW.mysex)
            local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), GW.mysex)

            if currentRank == nextRank and earnedValue - bottomValue == 0 then
                valPrecRepu = 1
                gw_reputation_vals = name .. " " .. REPUTATION .. " 21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            else
                valPrecRepu = (earnedValue - bottomValue) / (topValue - bottomValue)
                gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue((earnedValue - bottomValue)) .. " / " .. CommaValue((topValue - bottomValue)) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
            end
            self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
            isNormal = true
        end

        local nextId = standingId + 1
        if nextId == nil then
            nextId = standingId
        end
        if not lockLevelTextUnderMaxLevel then
            level = isParagon and getglobal("FACTION_STANDING_LABEL" .. standingId) or isFriend and friendTextLevel or isNormal and getglobal("FACTION_STANDING_LABEL" .. standingId)
            Nextlevel = isParagon and L["Paragon"] or isFriend and "" or isNormal and getglobal("FACTION_STANDING_LABEL" .. math.min(8, nextId))
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
            function()
                self.AzeritBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(9, self.AzeritBar:GetWidth() * animations["AzeritBarAnimation"]["progress"])
                    )
                )

                self.AzeritBar:SetValue(animations["AzeritBarAnimation"]["progress"])
                self.AzeritBar.Spark:SetPoint("LEFT", self.AzeritBar:GetWidth() * animations["AzeritBarAnimation"]["progress"] - 8, 0)
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
        self.CurrentLevel:SetText(1, 1, 1)
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
                        " / " .. CommaValue(maxHonor) .. " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
            1,
            1,
            1
            self.ExpBar:SetStatusBarColor(1, 0.2, 0.2)
    end

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
                    math.min(9,self.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"])
                )
            )

            if not GainBigExp then
                self.ExpBar:SetValue(animations["experiencebarAnimation"]["progress"])
                self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8, 0)

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)
            end
            self.ExpBar.Rested:SetValue(rested)
            self.ExpBar.Rested:SetPoint("LEFT", self.ExpBar, "LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"], 0)

            if GainBigExp and self.barOverlay.flare.soundCooldown < GetTime() then
                expSoundCooldown =
                    math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                    self.ExpBar:SetValue(animations["experiencebarAnimation"]["progress"])
                    self.ExpBar.Spark:SetPoint(
                    "LEFT",
                    self.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)

                self.barOverlay.flare.soundCooldown = GetTime() + expSoundCooldown
                PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\exp_gain_ping.ogg", "SFX")

                animations["experiencebarAnimation"]["from"] = step
            end
        end
    )
    AddToAnimation(
        "GwExperienceBarCandy",
        experiencebarAnimation,
        valPrec,
        GetTime(),
        0.3,
        function()
            local prog = animations["GwExperienceBarCandy"]["progress"]
            self.ExpBarCandy:SetValue(prog)
        end
    )

    if showBar3 then
        self.RepuBarCandy:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            self.RepuBar.repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function()
                self.RepuBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(9, self.RepuBar:GetWidth() * animations["repuBarAnimation"]["progress"])
                    )
                )

                self.RepuBar:SetValue(animations["repuBarAnimation"]["progress"])
                self.RepuBar.Spark:SetPoint("LEFT", self.RepuBar:GetWidth() * animations["repuBarAnimation"]["progress"] - 8, 0)
            end
        )
        self.RepuBar.repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

    if GW_LEVELING_REWARD_AVALIBLE then
        Nextlevel = Nextlevel and Nextlevel .. " |TInterface/AddOns/GW2_UI/textures/icons/levelreward-icon:20:20:0:0|t" or ""
    end

    if GW.mylevel ~= UnitEffectiveLevel("player") then
      level = level.. " |cFF00FF00(" .. UnitEffectiveLevel("player") .. ")|r"
    end

    self.NextLevel:SetText(Nextlevel)
    self.CurrentLevel:SetText(restingIconString .. level)
    if showBar1 and showBar2 and showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(2.66)
        self.ExpBarCandy:SetHeight(2.66)
        self.ExpBar.Spark:SetHeight(2.66)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.self:SetPoint("TOPRIGHT", -90, -4)
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

local action_hud_auras = {}

local function registerActionHudAura(auraID, left, right, unit)
    action_hud_auras[auraID] = {}
    action_hud_auras[auraID].auraID = auraID
    action_hud_auras[auraID].left = left
    action_hud_auras[auraID].right = right
    action_hud_auras[auraID].unit = unit
end
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

local currentTexture = nil

local function selectBg(self)
    if not GetSetting("HUD_BACKGROUND") or not GetSetting("HUD_SPELL_SWAP") then
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

    if UnitAffectingCombat("player") then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadowcombat"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadowcombat"

        local bolFound = false
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
            if spellID ~= nil and action_hud_auras[spellID] ~= nil and action_hud_auras[spellID].unit == "player" then
                right = action_hud_auras[spellID].right
                left = action_hud_auras[spellID].left
                break
            end
        end
        if not bolFound then
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("pet", i)
                if spellID ~= nil and action_hud_auras[spellID] ~= nil and action_hud_auras[spellID].unit == "pet" then
                    right = action_hud_auras[spellID].right
                    left = action_hud_auras[spellID].left
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
    if not GetSetting("HUD_BACKGROUND") then
        return
    end

    local unitHealthPrecentage = UnitHealth("player") / UnitHealthMax("player")

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5

        self.actionBarHud.Left:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.Right:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.RightSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.LeftSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
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


local function levelingRewards_OnShow(self)
    PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
    self.animationValue = -400
    local name = self:GetName()
    local start = GetTime()
    AddToAnimation(
        name,
        self.animationValue,
        0,
        start,
        0.2,
        function()
            local prog = animations[name]["progress"]
            local a = lerp(0, 1, (GetTime() - start) / 0.2)
            self:SetAlpha(a)
            self:SetPoint("CENTER", 0, prog)
        end
    )
end
GW.AddForProfiling("hud", "levelingRewards_OnShow", levelingRewards_OnShow)

local function loadRewards()
    local f = CreateFrame("Frame", "GwLevelingRewards", UIParent, "GwLevelingRewards")

    f.header:SetFont(DAMAGE_TEXT_FONT, 24)
    f.header:SetText(L["Upcoming Level Rewards"])

    f.rewardHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    f.rewardHeader:SetTextColor(0.6, 0.6, 0.6)
    f.rewardHeader:SetText(REWARD)

    f.levelHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    f.levelHeader:SetTextColor(0.6, 0.6, 0.6)
    f.levelHeader:SetText(LEVEL)

    local fnGwCloseLevelingRewards_OnClick = function(self)
        self:GetParent():Hide()
    end
    f.CloseButton:SetScript("OnClick", fnGwCloseLevelingRewards_OnClick)
    f.CloseButton:SetText(CLOSE)

    f.Item1.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item1.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item1.name:SetText(L["Upcoming Level Rewards"])

    f.Item2.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item2.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item2.name:SetText(L["Upcoming Level Rewards"])

    f.Item3.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item3.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item3.name:SetText(L["Upcoming Level Rewards"])

    f.Item4.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item4.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item4.name:SetText(L["Upcoming Level Rewards"])

    f:SetScript("OnShow", levelingRewards_OnShow)

    tinsert(UISpecialFrames, "GwLevelingRewards")
end
GW.AddForProfiling("hud", "loadRewards", loadRewards)

local GW_LEVELING_REWARDS = {}
displayRewards = function()

    wipe(GW_LEVELING_REWARDS)
    for i = 1, 7 do
        GW_LEVELING_REWARDS[i] = {}
        GW_LEVELING_REWARDS[i]["type"] = "TALENT"
        GW_LEVELING_REWARDS[i]["id"] = 0
        GW_LEVELING_REWARDS[i]["level"] = select(3, GetTalentTierInfo(i, GetActiveSpecGroup()))
    end

    GW_LEVELING_REWARD_AVALIBLE = false

    local spells = {GetSpecializationSpells(GW.myspec)}
    for _, v in pairs(spells) do
        if v ~= nil then
            local tIndex = #GW_LEVELING_REWARDS + 1
            GW_LEVELING_REWARDS[tIndex] = {}
            GW_LEVELING_REWARDS[tIndex]["type"] = "SPELL"
            GW_LEVELING_REWARDS[tIndex]["id"] = v
            GW_LEVELING_REWARDS[tIndex]["level"] = GetSpellLevelLearned(v)
        end
    end

    for i = 1, 80 do
        local skillType, spellId = GetSpellBookItemInfo(i, "spell")

        if skillType == "FUTURESPELL" and spellId ~= nil then
            local shouldAdd = true
            for _, v in pairs(GW_LEVELING_REWARDS) do
                if v["type"] == "SPELL" and v["id"] == spellId then
                    shouldAdd = false
                end
            end
            if shouldAdd then
                local tIndex = #GW_LEVELING_REWARDS + 1

                GW_LEVELING_REWARDS[tIndex] = {}
                GW_LEVELING_REWARDS[tIndex]["type"] = "SPELL"
                GW_LEVELING_REWARDS[tIndex]["id"] = spellId
                GW_LEVELING_REWARDS[tIndex]["level"] = GetSpellLevelLearned(spellId)
            end
        end
    end

    table.sort(
        GW_LEVELING_REWARDS,
        function(a, b)
            return a["level"] < b["level"]
        end
    )

    local i = 1
    for _, v in pairs(GW_LEVELING_REWARDS) do
        if v["level"] > GW.mylevel then
            if _G["GwLevelingRewardsItem" .. i].mask ~= nil then
                _G["GwLevelingRewardsItem" .. i].icon:RemoveMaskTexture(_G["GwLevelingRewardsItem" .. i].mask)
            end

            _G["GwLevelingRewardsItem" .. i]:Show()
            _G["GwLevelingRewardsItem" .. i].level:SetText(
                v["level"] .. " |TInterface/AddOns/GW2_UI/textures/icons/levelreward-icon:24:24:0:0|t "
            )

            if v["type"] == "SPELL" then
                local name, _, icon = GetSpellInfo(v["id"])
                _G["GwLevelingRewardsItem" .. i].icon:SetTexture(icon)
                _G["GwLevelingRewardsItem" .. i].name:SetText(name)
                _G["GwLevelingRewardsItem" .. i]:SetScript(
                    "OnEnter",
                    function()
                        GameTooltip:SetOwner(GwLevelingRewards, "ANCHOR_CURSOR", 0, 0)
                        GameTooltip:ClearLines()
                        GameTooltip:SetSpellByID(v["id"])
                        GameTooltip:Show()
                    end
                )
                if IsPassiveSpell(v["id"]) then
                    if not _G["GwLevelingRewardsItem" .. i].mask then
                        local mask = UIParent:CreateMaskTexture()
                        mask:SetPoint("CENTER", _G["GwLevelingRewardsItem" .. i].icon, "CENTER", 0, 0)
                        mask:SetTexture(
                            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
                            "CLAMPTOBLACKADDITIVE",
                            "CLAMPTOBLACKADDITIVE"
                        )
                        mask:SetSize(40, 40)
                        _G["GwLevelingRewardsItem" .. i].mask = mask
                    end
                    _G["GwLevelingRewardsItem" .. i].icon:AddMaskTexture(_G["GwLevelingRewardsItem" .. i].mask)
                end
                _G["GwLevelingRewardsItem" .. i]:SetScript("OnLeave", GameTooltip_Hide)
            elseif v["type"] == "TALENT" then
                _G["GwLevelingRewardsItem" .. i].icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/talent-icon")
                _G["GwLevelingRewardsItem" .. i].name:SetText(BONUS_TALENTS)
                _G["GwLevelingRewardsItem" .. i]:SetScript(
                    "OnEnter",
                    function()
                    end
                )
                _G["GwLevelingRewardsItem" .. i]:SetScript(
                    "OnLeave",
                    function()
                    end
                )
            end
            GW_LEVELING_REWARD_AVALIBLE = true

            i = i + 1
            if i > 4 then
                break
            end
        end
    end

    if i < 5 then
        while i < 5 do
            _G["GwLevelingRewardsItem" .. i]:Hide()
            i = i + 1
        end
    end
end
GW.AddForProfiling("hud", "displayRewards", displayRewards)

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
    elseif event == "MIRROR_TIMER_START" then
        local arg1, arg2, arg3, arg4, arg5, arg6 = ...
        GW.MirrorTimer_Show(arg1, arg2, arg3, arg4, arg5, arg6)
    end
end
GW.AddForProfiling("hud", "hud_OnEvent", hud_OnEvent)

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", nil, UIParent, "GwHudArtFrame")
    GW.MixinHideDuringPetAndOverride(hudArtFrame)

    if not GetSetting("BORDER_ENABLED") and hudArtFrame.edgeTint then
        for _, f in ipairs(hudArtFrame.edgeTint) do
            f:Hide()
        end
    end

    if not GetSetting("HUD_BACKGROUND") and hudArtFrame.actionBarHud.HUDBG then
        for _, f in ipairs(hudArtFrame.actionBarHud.HUDBG) do
            f:Hide()
        end
    else
        GW.RegisterScaleFrame(hudArtFrame.actionBarHud)
    end

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterEvent("MIRROR_TIMER_START")
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
    loadRewards()

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
    hooksecurefunc("SetWatchingHonorAsXP", xpbar_OnEvent)

    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript(
        "OnLeave",
        function(self)
            GameTooltip_Hide()
            UIFrameFadeIn(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 1)
            UIFrameFadeIn(self.AzeritBar, 0.2, self.AzeritBar:GetAlpha(), 1)
            UIFrameFadeIn(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 1)
        end
    )    
end
GW.LoadXPBar = LoadXPBar
