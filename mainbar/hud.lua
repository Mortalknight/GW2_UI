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

local function xpbar_OnEnter()
    GameTooltip:SetOwner(GwExperienceFrame, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local rested = GetXPExhaustion()
    local isRestingString = ""

    if IsResting() then
        isRestingString = L["EXP_BAR_TOOLTIP_EXP_RESTING"]
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
            L["EXP_BAR_TOOLTIP_EXP_RESTED"] ..
                CommaValue(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r",
            1,
            1,
            1   
        )
    end

    UIFrameFadeOut(GwExperienceFrame.ExpBar, 0.2, GwExperienceFrame.ExpBar:GetAlpha(), 0)
    UIFrameFadeOut(GwExperienceFrame.AzeritBar, 0.2, GwExperienceFrame.AzeritBar:GetAlpha(), 0)
    UIFrameFadeOut(GwExperienceFrame.RepuBar, 0.2, GwExperienceFrame.RepuBar:GetAlpha(), 0)

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

    if azeriteItemLocation then
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
                OpenAzeriteEssenceUIFromItemLocation(itemLocation)
            end
        end
    end
end
GW.AddForProfiling("hud", "xpbar_OnClick", xpbar_OnClick)

local function flareAnim()
    GwXpFlare:Show()

    AddToAnimation(
        "GwXpFlare",
        0,
        1,
        GetTime(),
        1,
        function(prog)
            GwXpFlare.texture:SetAlpha(1)
            GwXpFlare.texture:SetRotation(lerp(0, 3, prog))
            if prog > 0.75 then
                GwXpFlare.texture:SetAlpha(lerp(1, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end
        end,
        nil,
        function()
            GwXpFlare:Hide()
        end
    )
end
GW.AddForProfiling("hud", "flareAnim", flareAnim)

local function xpbar_OnEvent(self, event)
    if event == "CHAT_MSG_COMBAT_HONOR_GAIN" and UnitInBattleground("player") ~= nil and IsPlayerAtEffectiveMaxLevel() then
        C_Timer.After(0.4, function() xpbar_OnEvent(self, nil) end)
    end
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    displayRewards()

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
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
    local restingIconString = " |TInterface\\AddOns\\GW2_UI\\textures\\resting-icon:16:16:0:0|t "

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

    GwExperienceFrame.ExpBar:SetStatusBarColor(0.83, 0.57, 0)

    gw_reputation_vals = nil
    local standingId, bottomValue, topValue, earnedValue, isWatched
    for factionIndex = 1, GetNumFactions() do
        _, _, standingId, bottomValue, topValue, earnedValue, _, _, _, _, _, isWatched, _ = GetFactionInfo(factionIndex)
        if isWatched == true then
            local name, reaction, _, _, _, factionID = GetWatchedFactionInfo()
            local friendID, friendRep, friendMaxRep, friendName, _, _, _, friendThreshold, nextFriendThreshold =
                GetFriendshipReputation(factionID)
            if C_Reputation.IsFactionParagon(factionID) then
                local currentValue, maxValueParagon = C_Reputation.GetFactionParagonInfo(factionID)

                if currentValue > 10000 then
                    repeat
                        currentValue = currentValue - 10000
                    until (currentValue < 10000)
                end
                valPrecRepu = (currentValue - 0) / (maxValueParagon - 0)
                gw_reputation_vals =
                    name ..
                        " " ..
                            REPUTATION ..
                                " " ..
                                    CommaValue((currentValue - 0)) ..
                                        " / " ..
                                            CommaValue((maxValueParagon - 0)) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                    1,
                    1,
                    1

                GwExperienceFrame.RepuBar:SetStatusBarColor(
                    FACTION_BAR_COLORS[9].r,
                    FACTION_BAR_COLORS[9].g,
                    FACTION_BAR_COLORS[9].b
                )
            elseif (friendID ~= nil) then
                if (nextFriendThreshold) then
                    valPrecRepu = (friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)
                    gw_reputation_vals =
                        friendName ..
                            " " ..
                                REPUTATION ..
                                    " " ..
                                        CommaValue((friendRep - friendThreshold)) ..
                                            " / " ..
                                                CommaValue((nextFriendThreshold - friendThreshold)) ..
                                                    " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                        1,
                        1,
                        1
                else
                    valPrecRepu = 1
                    gw_reputation_vals =
                        friendName ..
                            " " ..
                                REPUTATION ..
                                    " " ..
                                        CommaValue(friendMaxRep) ..
                                            " / " ..
                                                CommaValue(friendMaxRep) ..
                                                    " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                        1,
                        1,
                        1
                end
                GwExperienceFrame.RepuBar:SetStatusBarColor(
                    FACTION_BAR_COLORS[5].r,
                    FACTION_BAR_COLORS[5].g,
                    FACTION_BAR_COLORS[5].b
                )
            else
                local currentRank =
                    GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), GW.mysex)
                local nextRank =
                    GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), GW.mysex)

                if currentRank == nextRank and earnedValue - bottomValue == 0 then
                    valPrecRepu = 1
                    gw_reputation_vals =
                        name ..
                            " " ..
                                REPUTATION ..
                                    " " .. "21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                        1,
                        1,
                        1
                else
                    valPrecRepu = (earnedValue - bottomValue) / (topValue - bottomValue)
                    gw_reputation_vals =
                        name ..
                            " " ..
                                REPUTATION ..
                                    " " ..
                                        CommaValue((earnedValue - bottomValue)) ..
                                            " / " ..
                                                CommaValue((topValue - bottomValue)) ..
                                                    " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                        1,
                        1,
                        1
                end
                GwExperienceFrame.RepuBar:SetStatusBarColor(
                    FACTION_BAR_COLORS[reaction].r,
                    FACTION_BAR_COLORS[reaction].g,
                    FACTION_BAR_COLORS[reaction].b
                )
            end

            local nextId = standingId + 1
            if nextId == nil then
                nextId = standingId
            end
            if not lockLevelTextUnderMaxLevel then
                level = getglobal("FACTION_STANDING_LABEL" .. standingId)
                Nextlevel = getglobal("FACTION_STANDING_LABEL" .. nextId)
            end

            showBar3 = true
        end
    end

    if azeriteItemLocation then
        showBar2 = true
        local azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        AzeritLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

        if xpForNextPoint > 0 then
            AzeritVal = azeriteXP / xpForNextPoint
        else
            AzeritVal = 0
        end
        GwExperienceFrame.AzeritBar:SetStatusBarColor(
            FACTION_BAR_COLORS[10].r,
            FACTION_BAR_COLORS[10].g,
            FACTION_BAR_COLORS[10].b
        )
        GwExperienceFrame.AzeritBar.animation:Show()
    end

    if showBar2 then
        GwExperienceFrame.AzeritBarCandy:SetValue(AzeritVal)

        AddToAnimation(
            "AzeritBarAnimation",
            GwExperienceFrame.AzeritBar.AzeritBarAnimation,
            AzeritVal,
            GetTime(),
            animationSpeed,
            function()
                GwExperienceFrame.AzeritBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(
                            9,
                            GwExperienceFrame.AzeritBar:GetWidth() *
                                animations["AzeritBarAnimation"]["progress"]
                        )
                    )
                )

                GwExperienceFrame.AzeritBar:SetValue(animations["AzeritBarAnimation"]["progress"])
                GwExperienceFrame.AzeritBar.Spark:SetPoint(
                    "LEFT",
                    GwExperienceFrame.AzeritBar:GetWidth() * animations["AzeritBarAnimation"]["progress"] - 8,
                    0
                )
            end
        )
        GwExperienceFrame.AzeritBar.AzeritBarAnimation = AzeritVal

        if maxPlayerLevel == GW.mylevel then
            level = AzeritLevel
            Nextlevel = AzeritLevel + 1 --Max azerit level is infinity
            GwExperienceFrame.NextLevel:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            GwExperienceFrame.CurrentLevel:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            GwExperienceFrame.labelRight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label-azerit")
            GwExperienceFrame.labelLeft:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label-azerit")
        end
    else
        GwExperienceFrame.NextLevel:SetTextColor(1, 1, 1)
        GwExperienceFrame.CurrentLevel:SetText(1, 1, 1)
        GwExperienceFrame.labelRight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")
        GwExperienceFrame.labelLeft:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")
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
            GwExperienceFrame.ExpBar:SetStatusBarColor(1, 0.2, 0.2)
    end

    local GainBigExp = false
    local FlareBreakPoint = math.max(0.05, 0.15 * (1 - (GW.mylevel / maxPlayerLevel)))
    if (valPrec - experiencebarAnimation) > FlareBreakPoint then
        GainBigExp = true
        flareAnim()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end

    GwXpFlare.soundCooldown = 0
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
            GwExperienceFrame.ExpBar.Spark:SetWidth(
                math.max(
                    8,
                    math.min(
                        9,
                        GwExperienceFrame.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"]
                    )
                )
            )

            if not GainBigExp then
                GwExperienceFrame.ExpBar:SetValue(animations["experiencebarAnimation"]["progress"])
                GwExperienceFrame.ExpBar.Spark:SetPoint(
                    "LEFT",
                    GwExperienceFrame.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                GwXpFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)
            end
            GwExperienceFrame.ExpBar.Rested:SetValue(rested)
            GwExperienceFrame.ExpBar.Rested:SetPoint(
                "LEFT",
                GwExperienceFrame.ExpBar,
                "LEFT",
                GwExperienceFrame.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"],
                0
            )

            if GainBigExp and GwXpFlare.soundCooldown < GetTime() then
                expSoundCooldown =
                    math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                    GwExperienceFrame.ExpBar:SetValue(animations["experiencebarAnimation"]["progress"])
                    GwExperienceFrame.ExpBar.Spark:SetPoint(
                    "LEFT",
                    GwExperienceFrame.ExpBar:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                GwXpFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)

                GwXpFlare.soundCooldown = GetTime() + expSoundCooldown
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
            GwExperienceFrame.ExpBarCandy:SetValue(prog)
        end
    )

    if showBar3 then
        GwExperienceFrame.RepuBarCandy:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            GwExperienceFrame.RepuBar.repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function()
                GwExperienceFrame.RepuBar.Spark:SetWidth(
                    math.max(
                        8,
                        math.min(
                            9,
                            GwExperienceFrame.RepuBar:GetWidth() * animations["repuBarAnimation"]["progress"]
                        )
                    )
                )

                GwExperienceFrame.RepuBar:SetValue(animations["repuBarAnimation"]["progress"])
                GwExperienceFrame.RepuBar.Spark:SetPoint(
                    "LEFT",
                    GwExperienceFrame.RepuBar:GetWidth() * animations["repuBarAnimation"]["progress"] - 8,
                    0
                )
            end
        )
        GwExperienceFrame.RepuBar.repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

    if GW_LEVELING_REWARD_AVALIBLE then
        Nextlevel = Nextlevel and Nextlevel .. " |TInterface\\AddOns\\GW2_UI\\textures\\levelreward-icon:20:20:0:0|t" or ""
    end

    GwExperienceFrame.NextLevel:SetText(Nextlevel)
    GwExperienceFrame.CurrentLevel:SetText(restingIconString .. level)
    if showBar1 and showBar2 and showBar3 then
        GwExperienceFrame.ExpBar:Show()
        GwExperienceFrame.ExpBarCandy:Show()
        GwExperienceFrame.ExpBar:SetHeight(2.66)
        GwExperienceFrame.ExpBarCandy:SetHeight(2.66)
        GwExperienceFrame.ExpBar.Spark:SetHeight(2.66)
        GwExperienceFrame.ExpBar.Spark:Show()
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        GwExperienceFrame.AzeritBar:Show()
        GwExperienceFrame.AzeritBarCandy:Show()
        GwExperienceFrame.AzeritBar.animation:Show()
        GwExperienceFrame.AzeritBar:SetHeight(2.66)
        GwExperienceFrame.AzeritBar.animation:SetHeight(2.66)
        GwExperienceFrame.AzeritBarCandy:SetHeight(2.66)
        GwExperienceFrame.AzeritBar.Spark:SetHeight(2.66)
        GwExperienceFrame.AzeritBar.Spark:Show()
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -8)
        GwExperienceFrame.AzeritBar:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.AzeritBar:SetPoint("TOPRIGHT", -90, -8)

        GwExperienceFrame.RepuBar:Show()
        GwExperienceFrame.RepuBarCandy:Show()
        GwExperienceFrame.RepuBar:SetHeight(2.66)
        GwExperienceFrame.RepuBarCandy:SetHeight(2.66)
        GwExperienceFrame.RepuBar.Spark:SetHeight(2.66)
        GwExperienceFrame.RepuBar.Spark:Show()
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPLEFT", 90, -12)
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPRIGHT", -90, -12)
        GwExperienceFrame.RepuBar:SetPoint("TOPLEFT", 90, -12)
        GwExperienceFrame.RepuBar:SetPoint("TOPRIGHT", -90, -12)
    elseif showBar1 and not showBar2 and showBar3 then
        GwExperienceFrame.ExpBar:Show()
        GwExperienceFrame.ExpBarCandy:Show()
        GwExperienceFrame.ExpBar:SetHeight(4)
        GwExperienceFrame.ExpBarCandy:SetHeight(4)
        GwExperienceFrame.ExpBar.Spark:SetHeight(4)
        GwExperienceFrame.ExpBar.Spark:Show()
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        GwExperienceFrame.AzeritBar:Hide()
        GwExperienceFrame.AzeritBarCandy:Hide()
        GwExperienceFrame.AzeritBar.animation:Hide()
        GwExperienceFrame.AzeritBar:SetValue(0)
        GwExperienceFrame.AzeritBarCandy:SetValue(0)
        GwExperienceFrame.AzeritBar.Spark:Hide()

        GwExperienceFrame.RepuBar:Show()
        GwExperienceFrame.RepuBarCandy:Show()
        GwExperienceFrame.RepuBar:SetHeight(4)
        GwExperienceFrame.RepuBarCandy:SetHeight(4)
        GwExperienceFrame.RepuBar.Spark:SetHeight(4)
        GwExperienceFrame.RepuBar.Spark:Show()
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPRIGHT", -90, -8)
        GwExperienceFrame.RepuBar:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.RepuBar:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and showBar2 and showBar3 then
        GwExperienceFrame.ExpBar:Hide()
        GwExperienceFrame.ExpBarCandy:Hide()
        GwExperienceFrame.ExpBar:SetValue(0)
        GwExperienceFrame.ExpBarCandy:SetValue(0)
        GwExperienceFrame.ExpBar.Spark:Hide()

        GwExperienceFrame.AzeritBar:Show()
        GwExperienceFrame.AzeritBarCandy:Show()
        GwExperienceFrame.AzeritBar.animation:Show()
        GwExperienceFrame.AzeritBar:SetHeight(4)
        GwExperienceFrame.AzeritBar.animation:SetHeight(4)
        GwExperienceFrame.AzeritBarCandy:SetHeight(4)
        GwExperienceFrame.AzeritBar.Spark:SetHeight(4)
        GwExperienceFrame.AzeritBar.Spark:Show()
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.AzeritBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.AzeritBar:SetPoint("TOPRIGHT", -90, -4)

        GwExperienceFrame.RepuBar:Show()
        GwExperienceFrame.RepuBarCandy:Show()
        GwExperienceFrame.RepuBar:SetHeight(4)
        GwExperienceFrame.RepuBarCandy:SetHeight(4)
        GwExperienceFrame.RepuBar.Spark:SetHeight(4)
        GwExperienceFrame.RepuBar.Spark:Show()
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPRIGHT", -90, -8)
        GwExperienceFrame.RepuBar:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.RepuBar:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and not showBar2 and showBar3 then
        GwExperienceFrame.ExpBar:Hide()
        GwExperienceFrame.ExpBarCandy:Hide()
        GwExperienceFrame.ExpBar:SetValue(0)
        GwExperienceFrame.ExpBarCandy:SetValue(0)
        GwExperienceFrame.ExpBar.Spark:Hide()

        GwExperienceFrame.AzeritBar:Hide()
        GwExperienceFrame.AzeritBarCandy:Hide()
        GwExperienceFrame.AzeritBar.animation:Hide()
        GwExperienceFrame.AzeritBar:SetValue(0)
        GwExperienceFrame.AzeritBarCandy:SetValue(0)
        GwExperienceFrame.AzeritBar.Spark:Hide()

        GwExperienceFrame.RepuBar:Show()
        GwExperienceFrame.RepuBarCandy:Show()
        GwExperienceFrame.RepuBar:SetHeight(8)
        GwExperienceFrame.RepuBarCandy:SetHeight(8)
        GwExperienceFrame.RepuBar.Spark:SetHeight(8)
        GwExperienceFrame.RepuBar.Spark:Show()
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.RepuBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.RepuBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.RepuBar:SetPoint("TOPRIGHT", -90, -4)
    elseif not showBar1 and not showBar2 and not showBar3 then
        GwExperienceFrame.ExpBar:Hide()
        GwExperienceFrame.ExpBarCandy:Hide()
        GwExperienceFrame.ExpBar:SetValue(0)
        GwExperienceFrame.ExpBarCandy:SetValue(0)
        GwExperienceFrame.ExpBar.Spark:Hide()

        GwExperienceFrame.AzeritBar:Hide()
        GwExperienceFrame.AzeritBarCandy:Hide()
        GwExperienceFrame.AzeritBar.animation:Hide()
        GwExperienceFrame.AzeritBar:SetValue(0)
        GwExperienceFrame.AzeritBarCandy:SetValue(0)
        GwExperienceFrame.AzeritBar.Spark:Hide()

        GwExperienceFrame.RepuBar:Hide()
        GwExperienceFrame.RepuBarCandy:Hide()
        GwExperienceFrame.RepuBar:SetValue(0)
        GwExperienceFrame.RepuBarCandy:SetValue(0)
        GwExperienceFrame.RepuBar.Spark:Hide()
    elseif showBar1 and not showBar2 and not showBar3 then
        GwExperienceFrame.ExpBar:Show()
        GwExperienceFrame.ExpBarCandy:Show()
        GwExperienceFrame.ExpBar:SetHeight(8)
        GwExperienceFrame.ExpBarCandy:SetHeight(8)
        GwExperienceFrame.ExpBar.Spark:SetHeight(8)
        GwExperienceFrame.ExpBar.Spark:Show()
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        GwExperienceFrame.AzeritBar:Hide()
        GwExperienceFrame.AzeritBarCandy:Hide()
        GwExperienceFrame.AzeritBar.animation:Hide()
        GwExperienceFrame.AzeritBar:SetValue(0)
        GwExperienceFrame.AzeritBarCandy:SetValue(0)
        GwExperienceFrame.AzeritBar.Spark:Hide()

        GwExperienceFrame.RepuBar:Hide()
        GwExperienceFrame.RepuBarCandy:Hide()
        GwExperienceFrame.RepuBar:SetValue(0)
        GwExperienceFrame.RepuBarCandy:SetValue(0)
        GwExperienceFrame.RepuBar.Spark:Hide()
    elseif showBar1 and showBar2 and not showBar3 then
        GwExperienceFrame.ExpBar:Show()
        GwExperienceFrame.ExpBarCandy:Show()
        GwExperienceFrame.ExpBar:SetHeight(4)
        GwExperienceFrame.ExpBarCandy:SetHeight(4)
        GwExperienceFrame.ExpBar.Spark:SetHeight(4)
        GwExperienceFrame.ExpBar.Spark:Show()
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        GwExperienceFrame.AzeritBar:Show()
        GwExperienceFrame.AzeritBarCandy:Show()
        GwExperienceFrame.AzeritBar.animation:Show()
        GwExperienceFrame.AzeritBar:SetHeight(4)
        GwExperienceFrame.AzeritBar.animation:SetHeight(4)
        GwExperienceFrame.AzeritBarCandy:SetHeight(4)
        GwExperienceFrame.AzeritBar.Spark:SetHeight(4)
        GwExperienceFrame.AzeritBar.Spark:Show()
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -8)
        GwExperienceFrame.AzeritBar:SetPoint("TOPLEFT", 90, -8)
        GwExperienceFrame.AzeritBar:SetPoint("TOPRIGHT", -90, -8)

        GwExperienceFrame.RepuBar:Hide()
        GwExperienceFrame.RepuBarCandy:Hide()
        GwExperienceFrame.RepuBar:SetValue(0)
        GwExperienceFrame.RepuBarCandy:SetValue(0)
        GwExperienceFrame.RepuBar.Spark:Hide()
    elseif not showBar1 and showBar2 and not showBar3 then
        GwExperienceFrame.ExpBar:Hide()
        GwExperienceFrame.ExpBarCandy:Hide()
        GwExperienceFrame.ExpBar:SetValue(0)
        GwExperienceFrame.ExpBarCandy:SetValue(0)
        GwExperienceFrame.ExpBar.Spark:Hide()

        GwExperienceFrame.AzeritBar:Show()
        GwExperienceFrame.AzeritBarCandy:Show()
        GwExperienceFrame.AzeritBar.animation:Show()
        GwExperienceFrame.AzeritBar:SetHeight(8)
        GwExperienceFrame.AzeritBar.animation:SetHeight(8)
        GwExperienceFrame.AzeritBarCandy:SetHeight(8)
        GwExperienceFrame.AzeritBar.Spark:SetHeight(8)
        GwExperienceFrame.AzeritBar.Spark:Show()
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.AzeritBarCandy:SetPoint("TOPRIGHT", -90, -4)
        GwExperienceFrame.AzeritBar:SetPoint("TOPLEFT", 90, -4)
        GwExperienceFrame.AzeritBar:SetPoint("TOPRIGHT", -90, -4)

        GwExperienceFrame.RepuBar:Hide()
        GwExperienceFrame.RepuBarCandy:Hide()
        GwExperienceFrame.RepuBar:SetValue(0)
        GwExperienceFrame.RepuBarCandy:SetValue(0)
        GwExperienceFrame.RepuBar.Spark:Hide()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end
end
GW.AddForProfiling("hud", "xpbar_OnEvent", xpbar_OnEvent)

local function animateAzeriteBar(self, elapsed)
    self:SetPoint("RIGHT", GwExperienceFrame.AzeritBar.Spark, "RIGHT", 0, 0)
    local speed = 0.01
    self.prog = self.prog + (speed * elapsed)
    if self.prog > 1 then
        self.prog = 0
    end

    self.texture1:SetTexCoord(0, GwExperienceFrame.AzeritBar:GetValue(), 0, 1)
    self.texture2:SetTexCoord(GwExperienceFrame.AzeritBar:GetValue(), 0, 1, 0)

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

local function updateBarSize()
    local m = (UIParent:GetWidth() - 180) / 10
    for i = 1, 9 do
        local rm = (m * i) + 90
        _G["barsep" .. i]:ClearAllPoints()
        _G["barsep" .. i]:SetPoint("LEFT", GwExperienceFrame, "LEFT", rm, 0)
    end

    m = (UIParent:GetWidth() - 180)
    dubbleBarSep:SetWidth(m)
    dubbleBarSep:ClearAllPoints()
    dubbleBarSep:SetPoint("LEFT", GwExperienceFrame, "LEFT", 90, 0)
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

local function selectBg()
    if not GetSetting("HUD_BACKGROUND") or not GetSetting("HUD_SPELL_SWAP") then
        return
    end
    local right = "Interface/AddOns/GW2_UI/textures/rightshadow"
    local left = "Interface/AddOns/GW2_UI/textures/leftshadow"

    if UnitIsDeadOrGhost("player") then
        right = "Interface/AddOns/GW2_UI/textures/rightshadow_dead"
        left = "Interface/AddOns/GW2_UI/textures/leftshadow_dead"
    end

    if GW.myClassID == 11 then --Druid
        local ShapeshiftFormID = GetShapeshiftFormID()
        if ShapeshiftFormID == BEAR_FORM then
            right = "Interface/AddOns/GW2_UI/textures/rightshadow_bear"
            left = "Interface/AddOns/GW2_UI/textures/leftshadow_bear"
        elseif ShapeshiftFormID == CAT_FORM then
            right = "Interface/AddOns/GW2_UI/textures/rightshadow_cat"
            left = "Interface/AddOns/GW2_UI/textures/leftshadow_cat"
        end
    end

    if UnitAffectingCombat("player") then
        right = "Interface/AddOns/GW2_UI/textures/rightshadowcombat"
        left = "Interface/AddOns/GW2_UI/textures/leftshadowcombat"

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
        GwActionBarHud.Right:SetTexture(right)
        GwActionBarHud.Left:SetTexture(left)
    end
end
GW.AddForProfiling("hud", "selectBg", selectBg)

local function combatHealthState()
    if not GetSetting("HUD_BACKGROUND") then 
        return
    end
    
    local unitHealthPrecentage = UnitHealth("player") / UnitHealthMax("player")

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5

        GwActionBarHud.Left:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        GwActionBarHud.Right:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        GwActionBarHud.RightSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        GwActionBarHud.LeftSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        GwActionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
        GwActionBarHud.RightBlood:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
    else
        GwActionBarHud.Left:SetVertexColor(1, 1, 1)
        GwActionBarHud.Right:SetVertexColor(1, 1, 1)

        GwActionBarHud.LeftSwim:SetVertexColor(1, 1, 1)
        GwActionBarHud.RightSwim:SetVertexColor(1, 1, 1)

        GwActionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 0)
        GwActionBarHud.RightBlood:SetVertexColor(1, 1, 1, 0)
    end
end
GW.AddForProfiling("hud", "combatHealthState", combatHealthState)

registerActionHudAura(
    31842,
    "Interface/AddOns/GW2_UI/textures/leftshadow_holy",
    "Interface/AddOns/GW2_UI/textures/rightshadow_holy",
    "player"
)
registerActionHudAura(
    31884,
    "Interface/AddOns/GW2_UI/textures/leftshadow_holy",
    "Interface/AddOns/GW2_UI/textures/rightshadow_holy",
    "player"
)
registerActionHudAura(
    51271,
    "Interface/AddOns/GW2_UI/textures/leftshadow_frost",
    "Interface/AddOns/GW2_UI/textures/rightshadow_frost",
    "player"
)
registerActionHudAura(
    162264,
    "Interface/AddOns/GW2_UI/textures/leftshadow_metamorph",
    "Interface/AddOns/GW2_UI/textures/rightshadow_metamorph",
    "player"
)
registerActionHudAura(
    187827,
    "Interface/AddOns/GW2_UI/textures/leftshadow_metamorph",
    "Interface/AddOns/GW2_UI/textures/rightshadow_metamorph",
    "player"
)
registerActionHudAura(
    215785,
    "Interface/AddOns/GW2_UI/textures/leftshadow_shaman_fire",
    "Interface/AddOns/GW2_UI/textures/rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    77762,
    "Interface/AddOns/GW2_UI/textures/leftshadow_shaman_fire",
    "Interface/AddOns/GW2_UI/textures/rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    201846,
    "Interface/AddOns/GW2_UI/textures/leftshadow_shaman_storm",
    "Interface/AddOns/GW2_UI/textures/rightshadow_shaman_storm",
    "player"
)
registerActionHudAura(
    63560,
    "Interface/AddOns/GW2_UI/textures/leftshadow_unholy",
    "Interface/AddOns/GW2_UI/textures/rightshadow_unholy",
    "pet"
)

local function LoadBreathMeter()
    CreateFrame("Frame", "GwBreathMeter", UIParent, "GwBreathMeter")
    GwBreathMeter:Hide()
    GwBreathMeter:SetScript(
        "OnShow",
        function()
            UIFrameFadeIn(GwBreathMeter, 0.2, GwBreathMeter:GetAlpha(), 1)
        end
    )
    MirrorTimer1:SetScript(
        "OnShow",
        function(self)
            self:Hide()
        end
    )
    MirrorTimer1:UnregisterAllEvents()

    GwBreathMeter:RegisterEvent("MIRROR_TIMER_START")
    GwBreathMeter:RegisterEvent("MIRROR_TIMER_STOP")

    GwBreathMeter:SetScript(
        "OnEvent",
        function(self, event, arg1, arg2, arg3, arg4)
            if event == "MIRROR_TIMER_START" then
                local texture = "Interface\\AddOns\\GW2_UI\\textures\\castingbar"
                if arg1 == "BREATH" then
                    texture = "Interface\\AddOns\\GW2_UI\\textures\\breathmeter"
                end
                GwBreathMeterBar:SetStatusBarTexture(texture)
                GwBreathMeterBar:SetMinMaxValues(0, arg3)
                GwBreathMeterBar:SetScript(
                    "OnUpdate",
                    function()
                        GwBreathMeterBar:SetValue(GetMirrorTimerProgress(arg1))
                    end
                )
                GwBreathMeter:Show()
            end
            if event == "MIRROR_TIMER_STOP" then
                GwBreathMeterBar:SetScript("OnUpdate", nil)
                GwBreathMeter:Hide()
            end
        end
    )
end
GW.LoadBreathMeter = LoadBreathMeter

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
    f.header:SetText(L["LEVEL_REWARDS"])

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
    f.Item1.name:SetText(L["LEVEL_REWARDS"])

    f.Item2.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item2.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item2.name:SetText(L["LEVEL_REWARDS"])

    f.Item3.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item3.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item3.name:SetText(L["LEVEL_REWARDS"])

    f.Item4.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item4.level:SetFont(DAMAGE_TEXT_FONT, 14)
    f.Item4.name:SetText(L["LEVEL_REWARDS"])

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
    for k, v in pairs(spells) do
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
            for k, v in pairs(GW_LEVELING_REWARDS) do
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
    for k, v in pairs(GW_LEVELING_REWARDS) do
        if v["level"] > GW.mylevel then
            if _G["GwLevelingRewardsItem" .. i].mask ~= nil then
                _G["GwLevelingRewardsItem" .. i].icon:RemoveMaskTexture(_G["GwLevelingRewardsItem" .. i].mask)
            end

            _G["GwLevelingRewardsItem" .. i]:Show()
            _G["GwLevelingRewardsItem" .. i].level:SetText(
                v["level"] .. " |TInterface\\AddOns\\GW2_UI\\textures\\levelreward-icon:24:24:0:0|t "
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
                            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
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
                _G["GwLevelingRewardsItem" .. i].icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talent-icon")
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
            selectBg()
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        selectBg()
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = ...
        if unit == "player" then
            combatHealthState()
        end
    end
end
GW.AddForProfiling("hud", "hud_OnEvent", hud_OnEvent)

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "GwHudArtFrame", UIParent, "GwHudArtFrame")
    GW.MixinHideDuringPetAndOverride(hudArtFrame)

    if not GetSetting("BORDER_ENABLED") and hudArtFrame.edgeTint then
        for _, f in ipairs(hudArtFrame.edgeTint) do
            f:Hide()
        end
    end

    if not GetSetting("HUD_BACKGROUND") and GwActionBarHud.HUDBG then
        for _, f in ipairs(GwActionBarHud.HUDBG) do
            f:Hide()
        end
    else
        GW.RegisterScaleFrame(GwActionBarHud)
    end

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    selectBg()
    combatHealthState()
end
GW.LoadHudArt = LoadHudArt

local function LoadXPBar()
    loadRewards()

    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")
    GW.MixinHideDuringPet(experiencebar)
    GwlevelLableRightButton:SetScript("OnClick", xpbar_OnClick)
    GwlevelLableRightButton:SetScript(
        "OnEnter",
        function()
            GwExperienceFrame.NextLevel.oldColor = {}
            GwExperienceFrame.NextLevel.oldColor.r, GwExperienceFrame.NextLevel.oldColor.g, GwExperienceFrame.NextLevel.oldColor.b = GwExperienceFrame.NextLevel:GetTextColor()
            GwExperienceFrame.NextLevel:SetTextColor(GwExperienceFrame.NextLevel.oldColor.r * 2, GwExperienceFrame.NextLevel.oldColor.g * 2, GwExperienceFrame.NextLevel.oldColor.b * 2)
        end
    )
    GwlevelLableRightButton:SetScript(
        "OnLeave",
        function()
            if GwExperienceFrame.NextLevel.oldColor == nil then
                return
            end
            GwExperienceFrame.NextLevel:SetTextColor(GwExperienceFrame.NextLevel.oldColor.r, GwExperienceFrame.NextLevel.oldColor.g, GwExperienceFrame.NextLevel.oldColor.b)
        end
    )

    GwExperienceFrame.AzeritBar.animation:SetScript(
        "OnShow",
        function()
            GwExperienceFrame.AzeritBar.animation:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    animateAzeriteBar(GwExperienceFrame.AzeritBar.animation, elapsed)
                end
            )
        end
    )
    GwExperienceFrame.AzeritBar.animation:SetScript(
        "OnHide",
        function()
            GwExperienceFrame.AzeritBar.animation:SetScript("OnUpdate", nil)
        end
    )

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    GwExperienceFrame.RepuBar.repuBarAnimation = 0
    GwExperienceFrame.AzeritBar.AzeritBarAnimation = 0
    GwExperienceFrame.NextLevel:SetFont(UNIT_NAME_FONT, 12)
    GwExperienceFrame.CurrentLevel:SetFont(UNIT_NAME_FONT, 12)

    updateBarSize()
    xpbar_OnEvent()

    experiencebar:SetScript("OnEvent", xpbar_OnEvent)

    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_FACTION")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    experiencebar:RegisterEvent("ARTIFACT_XP_UPDATE")
    experiencebar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
    experiencebar:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    experiencebar:RegisterEvent("PLAYER_ENTERING_WORLD")

    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript(
        "OnLeave",
        function()
            GameTooltip_Hide()
            UIFrameFadeIn(GwExperienceFrame.ExpBar, 0.2, GwExperienceFrame.ExpBar:GetAlpha(), 1)
            UIFrameFadeIn(GwExperienceFrame.AzeritBar, 0.2, GwExperienceFrame.AzeritBar:GetAlpha(), 1)
            UIFrameFadeIn(GwExperienceFrame.RepuBar, 0.2, GwExperienceFrame.RepuBar:GetAlpha(), 1)
        end
    )

    --Loss Of Control Icon Skin
    LossOfControlFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end
GW.LoadXPBar = LoadXPBar
