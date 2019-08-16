local _, GW = ...
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

local function artifactPoints()
    local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo()

    local numPoints = pointsSpent
    local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier)
    while totalXP >= xpForNextPoint and xpForNextPoint > 0 do
        totalXP = totalXP - xpForNextPoint

        pointsSpent = pointsSpent + 1
        numPoints = numPoints + 1

        xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier)
    end
    return numPoints, totalXP, xpForNextPoint
end
GW.AddForProfiling("hud", "artifactPoints", artifactPoints)

local function xpbar_OnEnter()
    GameTooltip:SetOwner(_G["GwExperienceFrame"], "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local rested = GetXPExhaustion()
    local isRestingString = ""
    if IsResting() then
        isRestingString = GwLocalization["EXP_BAR_TOOLTIP_EXP_RESTING"]
    end

    GameTooltip:AddLine(COMBAT_XP_GAIN .. isRestingString, 1, 1, 1)

    if gw_honor_vals ~= nil then
        GameTooltip:AddLine(gw_honor_vals, 1, 1, 1)
    end

    if UnitLevel("Player") < GetMaxPlayerLevel() then
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
            GwLocalization["EXP_BAR_TOOLTIP_EXP_RESTED"] ..
                CommaValue(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r",
            1,
            1,
            1
        )
    end

    UIFrameFadeOut(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 0)
    UIFrameFadeOut(_G["GwExperienceFrameArtifactBar"], 0.2, _G["GwExperienceFrameArtifactBar"]:GetAlpha(), 0)
    UIFrameFadeOut(GwExperienceFrameRepuBar, 0.2, GwExperienceFrameRepuBar:GetAlpha(), 0)

    local showArtifact = HasArtifactEquipped()
    local disabledArtifact = C_ArtifactUI.IsEquippedArtifactDisabled()
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

    if showArtifact and disabledArtifact == false then
        local _, artifactXP, xpForNextPoint = artifactPoints()
        local xpPct
        if xpForNextPoint > 0 then
            xpPct = math.floor((artifactXP / xpForNextPoint) * 100) .. "%"
        else
            xpPct = "n/a"
        end

        GameTooltip:AddLine(
            ARTIFACT_POWER ..
                " " ..
                    CommaValue(artifactXP) .. " / " .. CommaValue(xpForNextPoint) .. " |cffa6a6a6 (" .. xpPct .. ")|r",
            1,
            1,
            1
        )
    elseif azeriteItemLocation then
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
    if HasArtifactEquipped() and C_ArtifactUI.IsEquippedArtifactDisabled() == false then
        SocketInventoryItem(16)
    elseif C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped() then
        local heartItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        if heartItemLocation and heartItemLocation:IsEqualTo(ItemLocation:CreateFromEquipmentSlot(2)) then
            OpenAzeriteEssenceUIFromItemLocation(itemLocation)
        end
    else
        if UnitLevel("Player") < GetMaxPlayerLevel("Player") then
            if GwLevelingRewards:IsShown() then
                GwLevelingRewards:Hide()
            else
                GwLevelingRewards:Show()
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
    if event == "CHAT_MSG_COMBAT_HONOR_GAIN" and UnitInBattleground("player") ~= nil then
        local delayUpdateTime = GetTime() + 0.4
        GwExperienceFrame:SetScript(
            "OnUpdate",
            function()
                if GetTime() < delayUpdateTime then
                    return
                end
                xpbar_OnEvent(self, nil)
                GwExperienceFrame:SetScript("OnUpdate", nil)
            end
        )
    end
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    displayRewards()

    local showArtifact = HasArtifactEquipped()
    local disabledArtifact = C_ArtifactUI.IsEquippedArtifactDisabled()
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    local artifactVal = 0
    local numPoints = 0

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local valPrec = valCurrent / valMax
    local valPrecRepu = 0

    local level = UnitLevel("Player")
    local Nextlevel = math.min(GetMaxPlayerLevel(), UnitLevel("Player") + 1)
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

    _G["GwExperienceFrameBar"]:SetStatusBarColor(0.83, 0.57, 0)

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

                _G["GwExperienceFrameRepuBar"]:SetStatusBarColor(
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
                _G["GwExperienceFrameRepuBar"]:SetStatusBarColor(
                    FACTION_BAR_COLORS[5].r,
                    FACTION_BAR_COLORS[5].g,
                    FACTION_BAR_COLORS[5].b
                )
            else
                local currentRank =
                    GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), UnitSex("player"))
                local nextRank =
                    GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), UnitSex("player"))

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
                _G["GwExperienceFrameRepuBar"]:SetStatusBarColor(
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

    if showArtifact and disabledArtifact == false then
        showBar2 = true
        numPoints, artifactXP, xpForNextPoint = artifactPoints()

        if xpForNextPoint > 0 then
            artifactVal = artifactXP / xpForNextPoint
        else
            artifactVal = 0
        end
    elseif azeriteItemLocation then
        showBar2 = true
        azeriteXP, xpForNextPoint = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        numPoints = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

        if xpForNextPoint > 0 then
            artifactVal = azeriteXP / xpForNextPoint
        else
            artifactVal = 0
        end
        _G["GwExperienceFrameArtifactBar"]:SetStatusBarColor(
            FACTION_BAR_COLORS[10].r,
            FACTION_BAR_COLORS[10].g,
            FACTION_BAR_COLORS[10].b
        )
        _G["GwExperienceFrameArtifactBar"].animation:Show()
    end

    if showBar2 then
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(artifactVal)

        AddToAnimation(
            "artifactBarAnimation",
            _G["GwExperienceFrameArtifactBar"].artifactBarAnimation,
            artifactVal,
            GetTime(),
            animationSpeed,
            function()
                ArtifactBarSpark:SetWidth(
                    math.max(
                        8,
                        math.min(
                            9,
                            _G["GwExperienceFrameArtifactBar"]:GetWidth() *
                                animations["artifactBarAnimation"]["progress"]
                        )
                    )
                )

                _G["GwExperienceFrameArtifactBar"]:SetValue(animations["artifactBarAnimation"]["progress"])
                ArtifactBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameArtifactBar"]:GetWidth() * animations["artifactBarAnimation"]["progress"] - 8,
                    0
                )
            end
        )
        _G["GwExperienceFrameArtifactBar"].artifactBarAnimation = artifactVal

        if GetMaxPlayerLevel() == UnitLevel("player") then
            level = numPoints
            Nextlevel = numPoints + 1
            _G["GwExperienceFrameNextLevel"]:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            _G["GwExperienceFrameCurrentLevel"]:SetTextColor(240 / 255, 189 / 255, 103 / 255)
            GwExperienceFrame.labelRight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label-artifact")
            GwExperienceFrame.labelLeft:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label-artifact")
        end
    else
        _G["GwExperienceFrameNextLevel"]:SetTextColor(1, 1, 1)
        _G["GwExperienceFrameCurrentLevel"]:SetText(1, 1, 1)
        GwExperienceFrame.labelRight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")
        GwExperienceFrame.labelLeft:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")
    end

    --If we are inside a pvp arena we show the honorbar
    gw_honor_vals = nil

    if
        (UnitLevel("player") == GetMaxPlayerLevel() and UnitInBattleground("player") ~= nil) or
            (UnitLevel("player") == GetMaxPlayerLevel() and event == "PLAYER_ENTERING_BATTLEGROUND")
     then
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
        _G["GwExperienceFrameBar"]:SetStatusBarColor(1, 0.2, 0.2)
    end

    local GainBigExp = false
    local FlareBreakPoint = math.max(0.05, 0.15 * (1 - (UnitLevel("Player") / GetMaxPlayerLevel())))
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
            ExperienceBarSpark:SetWidth(
                math.max(
                    8,
                    math.min(
                        9,
                        _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"]
                    )
                )
            )

            if not GainBigExp then
                _G["GwExperienceFrameBar"]:SetValue(animations["experiencebarAnimation"]["progress"])
                ExperienceBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                GwXpFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)
            end
            _G["GwExperienceFrameBarRested"]:SetValue(rested)
            _G["GwExperienceFrameBarRested"]:SetPoint(
                "LEFT",
                _G["GwExperienceFrameBar"],
                "LEFT",
                _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"],
                0
            )

            if GainBigExp and GwXpFlare.soundCooldown < GetTime() then
                expSoundCooldown =
                    math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                _G["GwExperienceFrameBar"]:SetValue(animations["experiencebarAnimation"]["progress"])
                ExperienceBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
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
        "GwExperienceFrameBarCandy",
        experiencebarAnimation,
        valPrec,
        GetTime(),
        0.3,
        function()
            local prog = animations["GwExperienceFrameBarCandy"]["progress"]
            _G["GwExperienceFrameBarCandy"]:SetValue(prog)
        end
    )

    if showBar3 then
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            _G["GwExperienceFrameRepuBar"].repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function()
                ExperienceRepuBarSpark:SetWidth(
                    math.max(
                        8,
                        math.min(
                            9,
                            _G["GwExperienceFrameRepuBar"]:GetWidth() * animations["repuBarAnimation"]["progress"]
                        )
                    )
                )

                _G["GwExperienceFrameRepuBar"]:SetValue(animations["repuBarAnimation"]["progress"])
                ExperienceRepuBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameRepuBar"]:GetWidth() * animations["repuBarAnimation"]["progress"] - 8,
                    0
                )
            end
        )
        _G["GwExperienceFrameRepuBar"].repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

    if GW_LEVELING_REWARD_AVALIBLE then
        Nextlevel = Nextlevel .. " |TInterface\\AddOns\\GW2_UI\\textures\\levelreward-icon:20:20:0:0|t"
    end

    _G["GwExperienceFrameNextLevel"]:SetText(Nextlevel)
    _G["GwExperienceFrameCurrentLevel"]:SetText(restingIconString .. level)
    if showBar1 and showBar2 and showBar3 then
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
        _G["GwExperienceFrameBar"]:SetHeight(2.66)
        _G["GwExperienceFrameBarCandy"]:SetHeight(2.66)
        _G["ExperienceBarSpark"]:SetHeight(2.66)
        ExperienceBarSpark:Show()
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameArtifactBar"]:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:Show()
        _G["GwExperienceFrameArtifactBarAnimation"]:Show()
        _G["GwExperienceFrameArtifactBar"]:SetHeight(2.66)
        _G["GwExperienceFrameArtifactBarAnimation"]:SetHeight(2.66)
        _G["GwExperienceFrameArtifactBarCandy"]:SetHeight(2.66)
        _G["ArtifactBarSpark"]:SetHeight(2.66)
        ArtifactBarSpark:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPRIGHT", -90, -8)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPRIGHT", -90, -8)

        _G["GwExperienceFrameRepuBar"]:Show()
        _G["GwExperienceFrameRepuBarCandy"]:Show()
        _G["GwExperienceFrameRepuBar"]:SetHeight(2.66)
        _G["GwExperienceFrameRepuBarCandy"]:SetHeight(2.66)
        _G["ExperienceRepuBarSpark"]:SetHeight(2.66)
        ExperienceRepuBarSpark:Show()
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPLEFT", 90, -12)
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPRIGHT", -90, -12)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPLEFT", 90, -12)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPRIGHT", -90, -12)
    elseif showBar1 and not showBar2 and showBar3 then
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
        _G["GwExperienceFrameBar"]:SetHeight(4)
        _G["GwExperienceFrameBarCandy"]:SetHeight(4)
        _G["ExperienceBarSpark"]:SetHeight(4)
        ExperienceBarSpark:Show()
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameArtifactBar"]:Hide()
        _G["GwExperienceFrameArtifactBarCandy"]:Hide()
        _G["GwExperienceFrameArtifactBarAnimation"]:Hide()
        _G["GwExperienceFrameArtifactBar"]:SetValue(0)
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(0)
        ArtifactBarSpark:Hide()

        _G["GwExperienceFrameRepuBar"]:Show()
        _G["GwExperienceFrameRepuBarCandy"]:Show()
        _G["GwExperienceFrameRepuBar"]:SetHeight(4)
        _G["GwExperienceFrameRepuBarCandy"]:SetHeight(4)
        _G["ExperienceRepuBarSpark"]:SetHeight(4)
        ExperienceRepuBarSpark:Show()
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPRIGHT", -90, -8)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and showBar2 and showBar3 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()

        _G["GwExperienceFrameArtifactBar"]:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:Show()
        _G["GwExperienceFrameArtifactBarAnimation"]:Show()
        _G["GwExperienceFrameArtifactBar"]:SetHeight(4)
        _G["GwExperienceFrameArtifactBarAnimation"]:SetHeight(4)
        _G["GwExperienceFrameArtifactBarCandy"]:SetHeight(4)
        _G["ArtifactBarSpark"]:SetHeight(4)
        ArtifactBarSpark:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameRepuBar"]:Show()
        _G["GwExperienceFrameRepuBarCandy"]:Show()
        _G["GwExperienceFrameRepuBar"]:SetHeight(4)
        _G["GwExperienceFrameRepuBarCandy"]:SetHeight(4)
        _G["ExperienceRepuBarSpark"]:SetHeight(4)
        ExperienceRepuBarSpark:Show()
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPRIGHT", -90, -8)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and not showBar2 and showBar3 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()

        _G["GwExperienceFrameArtifactBar"]:Hide()
        _G["GwExperienceFrameArtifactBarCandy"]:Hide()
        _G["GwExperienceFrameArtifactBarAnimation"]:Hide()
        _G["GwExperienceFrameArtifactBar"]:SetValue(0)
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(0)
        ArtifactBarSpark:Hide()

        _G["GwExperienceFrameRepuBar"]:Show()
        _G["GwExperienceFrameRepuBarCandy"]:Show()
        _G["GwExperienceFrameRepuBar"]:SetHeight(8)
        _G["GwExperienceFrameRepuBarCandy"]:SetHeight(8)
        _G["ExperienceRepuBarSpark"]:SetHeight(8)
        ExperienceRepuBarSpark:Show()
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPRIGHT", -90, -4)
    elseif not showBar1 and not showBar2 and not showBar3 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()

        _G["GwExperienceFrameArtifactBar"]:Hide()
        _G["GwExperienceFrameArtifactBarCandy"]:Hide()
        _G["GwExperienceFrameArtifactBarAnimation"]:Hide()
        _G["GwExperienceFrameArtifactBar"]:SetValue(0)
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(0)
        ArtifactBarSpark:Hide()

        _G["GwExperienceFrameRepuBar"]:Hide()
        _G["GwExperienceFrameRepuBarCandy"]:Hide()
        _G["GwExperienceFrameRepuBar"]:SetValue(0)
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(0)
        ExperienceRepuBarSpark:Hide()
    elseif showBar1 and not showBar2 and not showBar3 then
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
        _G["GwExperienceFrameBar"]:SetHeight(8)
        _G["GwExperienceFrameBarCandy"]:SetHeight(8)
        _G["ExperienceBarSpark"]:SetHeight(8)
        ExperienceBarSpark:Show()
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameArtifactBar"]:Hide()
        _G["GwExperienceFrameArtifactBarCandy"]:Hide()
        _G["GwExperienceFrameArtifactBarAnimation"]:Hide()
        _G["GwExperienceFrameArtifactBar"]:SetValue(0)
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(0)
        ArtifactBarSpark:Hide()

        _G["GwExperienceFrameRepuBar"]:Hide()
        _G["GwExperienceFrameRepuBarCandy"]:Hide()
        _G["GwExperienceFrameRepuBar"]:SetValue(0)
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(0)
        ExperienceRepuBarSpark:Hide()
    elseif showBar1 and showBar2 and not showBar3 then
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
        _G["GwExperienceFrameBar"]:SetHeight(4)
        _G["GwExperienceFrameBarCandy"]:SetHeight(4)
        _G["ExperienceBarSpark"]:SetHeight(4)
        ExperienceBarSpark:Show()
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameArtifactBar"]:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:Show()
        _G["GwExperienceFrameArtifactBarAnimation"]:Show()
        _G["GwExperienceFrameArtifactBar"]:SetHeight(4)
        _G["GwExperienceFrameArtifactBarAnimation"]:SetHeight(4)
        _G["GwExperienceFrameArtifactBarCandy"]:SetHeight(4)
        _G["ArtifactBarSpark"]:SetHeight(4)
        ArtifactBarSpark:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPRIGHT", -90, -8)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPRIGHT", -90, -8)

        _G["GwExperienceFrameRepuBar"]:Hide()
        _G["GwExperienceFrameRepuBarCandy"]:Hide()
        _G["GwExperienceFrameRepuBar"]:SetValue(0)
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(0)
        ExperienceRepuBarSpark:Hide()
    elseif not showBar1 and showBar2 and not showBar3 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()

        _G["GwExperienceFrameArtifactBar"]:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:Show()
        _G["GwExperienceFrameArtifactBarAnimation"]:Show()
        _G["GwExperienceFrameArtifactBar"]:SetHeight(8)
        _G["GwExperienceFrameArtifactBarAnimation"]:SetHeight(8)
        _G["GwExperienceFrameArtifactBarCandy"]:SetHeight(8)
        _G["ArtifactBarSpark"]:SetHeight(8)
        ArtifactBarSpark:Show()
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameArtifactBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameArtifactBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameRepuBar"]:Hide()
        _G["GwExperienceFrameRepuBarCandy"]:Hide()
        _G["GwExperienceFrameRepuBar"]:SetValue(0)
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(0)
        ExperienceRepuBarSpark:Hide()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end
end
GW.AddForProfiling("hud", "xpbar_OnEvent", xpbar_OnEvent)

local function animateAzeriteBar(self, elapsed)
    self:SetPoint("RIGHT", ArtifactBarSpark, "RIGHT", 0, 0)
    local speed = 0.01
    self.prog = self.prog + (speed * elapsed)
    if self.prog > 1 then
        self.prog = 0
    end

    self.texture1:SetTexCoord(0, _G["GwExperienceFrameArtifactBar"]:GetValue(), 0, 1)
    self.texture2:SetTexCoord(_G["GwExperienceFrameArtifactBar"]:GetValue(), 0, 1, 0)

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
        _G["barsep" .. i]:SetPoint("LEFT", "GwExperienceFrame", "LEFT", rm, 0)
    end

    m = (UIParent:GetWidth() - 180)
    dubbleBarSep:SetWidth(m)
    dubbleBarSep:ClearAllPoints()
    dubbleBarSep:SetPoint("LEFT", "GwExperienceFrame", "LEFT", 90, 0)
end
GW.AddForProfiling("hud", "updateBarSize", updateBarSize)

local action_hud_auras = {}

local function registerActionHudAura(aura, left, right)
    action_hud_auras[aura] = {}
    action_hud_auras[aura]["aura"] = aura
    action_hud_auras[aura]["left"] = left
    action_hud_auras[aura]["right"] = right
end
local currentTexture = nil
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

--[[
local function getSpecSpecificHud(left, right)
    --hard coded for now
    local playerClassName, playerClassEng, playerClass = UnitClass("player")
    if playerClass == 6 and GetSpecialization() == 3 then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_unholy"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_unholy"
    elseif playerClass == 6 and GetSpecialization() == 2 then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_frost"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_frost"
    end

    return left, right
end
--]]
local function selectBg()
    if not GetSetting("HUD_SPELL_SWAP") then
        return
    end
    local right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow"
    local left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow"

    if UnitIsDeadOrGhost("player") then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_dead"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_dead"
    end

    if UnitAffectingCombat("player") then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadowcombat"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadowcombat"

        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
            if spellID ~= nil and action_hud_auras[spellID] ~= nil then
                left = action_hud_auras[spellID]["left"]
                right = action_hud_auras[spellID]["right"]
            end
        end
    end

    if currentTexture ~= left then
        currentTexture = left
        _G["GwActionBarHudLEFT"]:SetTexture(left)
        _G["GwActionBarHudRIGHT"]:SetTexture(right)
    end
end
GW.AddForProfiling("hud", "selectBg", selectBg)

local function combatHealthState()
    local unitHealthPrecentage = UnitHealth("player") / UnitHealthMax("player")

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5

        _G["GwActionBarHudLEFT"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        _G["GwActionBarHudRIGHT"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        _G["GwActionBarHudRIGHTSWIM"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        _G["GwActionBarHudLEFTSWIM"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        _G["GwActionBarHudLEFTBLOOD"]:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
        _G["GwActionBarHudRIGHTBLOOD"]:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
    else
        _G["GwActionBarHudLEFT"]:SetVertexColor(1, 1, 1)
        _G["GwActionBarHudRIGHT"]:SetVertexColor(1, 1, 1)

        _G["GwActionBarHudRIGHTSWIM"]:SetVertexColor(1, 1, 1)
        _G["GwActionBarHudLEFTSWIM"]:SetVertexColor(1, 1, 1)

        _G["GwActionBarHudLEFTBLOOD"]:SetVertexColor(1, 1, 1, 0)
        _G["GwActionBarHudRIGHTBLOOD"]:SetVertexColor(1, 1, 1, 0)
    end
end
GW.AddForProfiling("hud", "combatHealthState", combatHealthState)

registerActionHudAura(
    31842,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy"
)
registerActionHudAura(
    31884,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy"
)
registerActionHudAura(
    5487,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_bear",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_bear"
)
registerActionHudAura(
    768,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_cat",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_cat"
)
registerActionHudAura(
    51271,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_frost",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_frost"
)
registerActionHudAura(
    162264,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_metamorph",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_metamorph"
)
registerActionHudAura(
    187827,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_metamorph",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_metamorph"
)
registerActionHudAura(
    215785,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_fire"
)
registerActionHudAura(
    77762,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_fire"
)
registerActionHudAura(
    201846,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_storm",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_storm"
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
    f.header:SetText(GwLocalization["LEVEL_REWARDS"])

    f.rewardHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    f.rewardHeader:SetTextColor(0.6, 0.6, 0.6)
    f.rewardHeader:SetText(REWARD)

    f.levelHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    f.levelHeader:SetTextColor(0.6, 0.6, 0.6)
    f.levelHeader:SetText(LEVEL)

    local fnGwCloseLevelingRewards_OnClick = function(self, button)
        GwLevelingRewards:Hide()
    end
    GwCloseLevelingRewards:SetScript("OnClick", fnGwCloseLevelingRewards_OnClick)
    GwCloseLevelingRewards:SetText(CLOSE)

    _G["GwLevelingRewardsItem1"].name:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem1"].level:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem1"].name:SetText(GwLocalization["LEVEL_REWARDS"])

    _G["GwLevelingRewardsItem2"].name:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem2"].level:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem2"].name:SetText(GwLocalization["LEVEL_REWARDS"])

    _G["GwLevelingRewardsItem3"].name:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem3"].level:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem3"].name:SetText(GwLocalization["LEVEL_REWARDS"])

    _G["GwLevelingRewardsItem4"].name:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem4"].level:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["GwLevelingRewardsItem4"].name:SetText(GwLocalization["LEVEL_REWARDS"])

    f:SetScript("OnShow", levelingRewards_OnShow)

    tinsert(UISpecialFrames, "GwLevelingRewards")
end
GW.AddForProfiling("hud", "loadRewards", loadRewards)

local GW_LEVELING_REWARDS = {}
displayRewards = function()
    local _, englishClass = UnitClass("player")
    local talentLevels = CLASS_TALENT_LEVELS[englishClass] or CLASS_TALENT_LEVELS["DEFAULT"]

    wipe(GW_LEVELING_REWARDS)
    for i = 1, 7 do
        GW_LEVELING_REWARDS[i] = {}
        GW_LEVELING_REWARDS[i]["type"] = "TALENT"
        GW_LEVELING_REWARDS[i]["id"] = 0
        GW_LEVELING_REWARDS[i]["level"] = talentLevels[i]
    end

    GW_LEVELING_REWARD_AVALIBLE = false

    local currentSpec = GetSpecialization() -- Get the player's current spec
    local spells = {GetSpecializationSpells(currentSpec)}
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
        if v["level"] > UnitLevel("player") then
            if _G["GwLevelingRewardsItem" .. i].mask ~= nil then
                _G["GwLevelingRewardsItem" .. i].icon:RemoveMaskTexture(_G["GwLevelingRewardsItem" .. i].mask)
            end

            _G["GwLevelingRewardsItem" .. i]:Show()
            _G["GwLevelingRewardsItem" .. i].level:SetText(
                v["level"] .. " |TInterface\\AddOns\\GW2_UI\\textures\\levelreward-icon:24:24:0:0|t "
            )

            if v["type"] == "SPELL" then
                name, rank, icon = GetSpellInfo(v["id"])
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
    elseif event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_MAXHEALTH" then
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

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
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

    _G["GwExperienceFrameArtifactBar"].animation:SetScript(
        "OnShow",
        function()
            _G["GwExperienceFrameArtifactBar"].animation:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    animateAzeriteBar(_G["GwExperienceFrameArtifactBar"].animation, elapsed)
                end
            )
        end
    )
    _G["GwExperienceFrameArtifactBar"].animation:SetScript(
        "OnHide",
        function()
            _G["GwExperienceFrameArtifactBar"].animation:SetScript("OnUpdate", nil)
        end
    )

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    _G["GwExperienceFrameRepuBar"].repuBarAnimation = 0
    _G["GwExperienceFrameArtifactBar"].artifactBarAnimation = 0
    _G["GwExperienceFrameNextLevel"]:SetFont(UNIT_NAME_FONT, 12)
    _G["GwExperienceFrameCurrentLevel"]:SetFont(UNIT_NAME_FONT, 12)

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
            UIFrameFadeIn(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 1)
            UIFrameFadeIn(_G["GwExperienceFrameArtifactBar"], 0.2, _G["GwExperienceFrameArtifactBar"]:GetAlpha(), 1)
            UIFrameFadeIn(GwExperienceFrameRepuBar, 0.2, GwExperienceFrameRepuBar:GetAlpha(), 1)
        end
    )
end
GW.LoadXPBar = LoadXPBar
