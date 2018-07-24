local _, GW = ...
local CommaValue = GW.CommaValue
local RoundDec = GW.RoundDec
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local RoundInt = GW.RoundInt
local Diff = GW.Diff
local VERSION_STRING = GW.VERSION_STRING
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local Self_Hide = GW.Self_Hide
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

-- forward function defs
local displayRewards
local createOrderBar

local experiencebarAnimation = 0

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

    GameTooltip:AddLine(GwLocalization["EXP_BAR_TOOLTIP_EXP_TITLE"] .. isRestingString, 1, 1, 1)

    if gw_reputation_vals ~= nil then
        GameTooltip:AddLine(gw_reputation_vals, 1, 1, 1)
    end
    if gw_honor_vals ~= nil then
        GameTooltip:AddLine(gw_honor_vals, 1, 1, 1)
    end

    if UnitLevel("Player") < GetMaxPlayerLevel() then
        GameTooltip:AddLine(
            GwLocalization["EXP_BAR_TOOLTIP_EXP_VALUE"] ..
                CommaValue(valCurrent) ..
                    " / " .. CommaValue(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r",
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

    GameTooltip:Show()
end
GW.AddForProfiling("hud", "xpbar_OnEnter", xpbar_OnEnter)

local function xpbar_OnClick()
    if HasArtifactEquipped() and C_ArtifactUI.IsEquippedArtifactDisabled() == false then
        SocketInventoryItem(16)
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

    displayRewards()

    local showArtifact = HasArtifactEquipped()
    local disabledArtifact = C_ArtifactUI.IsEquippedArtifactDisabled()
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    local artifactVal = 0
    local numPoints = 0
    local artifactXP = 0
    local azeriteXP = 0
    local xpForNextPoint = 0

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local valPrec = valCurrent / valMax

    local level = UnitLevel("Player")
    local Nextlevel = math.min(GetMaxPlayerLevel(), UnitLevel("Player") + 1)

    local rested = GetXPExhaustion()
    local showBar1 = false
    local showBar2 = false
    local restingIconString = " |TInterface\\AddOns\\GW2_UI\\textures\\resting-icon:16:16:0:0|t "

    if not IsResting() then
        restingIconString = ""
    end
    if rested == nil or (rested / valMax) == 0 then
        rested = 0
    else
        rested = (rested / valMax) --+ valPrec
    end
    if rested > 1 then
        rested = 1
    end

    if level < Nextlevel then
        showBar1 = true
    end

    local animationSpeed = 15

    _G["GwExperienceFrameBar"]:SetStatusBarColor(0.83, 0.57, 0)

    gw_reputation_vals = nil
    if level == Nextlevel then
        for factionIndex = 1, GetNumFactions() do
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
                isChild = GetFactionInfo(factionIndex)
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
                    valPrec = (currentValue - 0) / (maxValueParagon - 0)
                    gw_reputation_vals =
                        name ..
                            GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                CommaValue((currentValue - 0)) ..
                                    " / " ..
                                        CommaValue((maxValueParagon - 0)) ..
                                            " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                        1,
                        1,
                        1

                    _G["GwExperienceFrameBar"]:SetStatusBarColor(
                        FACTION_BAR_COLORS[9].r,
                        FACTION_BAR_COLORS[9].g,
                        FACTION_BAR_COLORS[9].b
                    )
                elseif (friendID ~= nil) then
                    if (nextFriendThreshold) then
                        valPrec = (friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)
                        gw_reputation_vals =
                            friendName ..
                                GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                    CommaValue((friendRep - friendThreshold)) ..
                                        " / " ..
                                            CommaValue((nextFriendThreshold - friendThreshold)) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    else
                        valPrec = 1
                        gw_reputation_vals =
                            friendName ..
                                GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                    CommaValue(friendMaxRep) ..
                                        " / " ..
                                            CommaValue(friendMaxRep) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    end
                    _G["GwExperienceFrameBar"]:SetStatusBarColor(
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
                        valPrec = 1
                        gw_reputation_vals =
                            name ..
                                GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                    "21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    else
                        valPrec = (earnedValue - bottomValue) / (topValue - bottomValue)
                        gw_reputation_vals =
                            name ..
                                GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                    CommaValue((earnedValue - bottomValue)) ..
                                        " / " ..
                                            CommaValue((topValue - bottomValue)) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    end
                    _G["GwExperienceFrameBar"]:SetStatusBarColor(
                        FACTION_BAR_COLORS[reaction].r,
                        FACTION_BAR_COLORS[reaction].g,
                        FACTION_BAR_COLORS[reaction].b
                    )
                end

                local nextId = standingId + 1
                if nextId == nil then
                    nextId = standingId
                end
                level = getglobal("FACTION_STANDING_LABEL" .. standingId)

                Nextlevel = getglobal("FACTION_STANDING_LABEL" .. nextId)

                showBar1 = true
            end
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
        Nextlevel = math.min(level + 1, GetMaxPlayerHonorLevel())

        local currentHonor = UnitHonor("player")
        local maxHonor = UnitHonorMax("player")
        valPrec = currentHonor / maxHonor

        gw_honor_vals =
            GwLocalization["EXP_BAR_TOOLTIP_HONOR"] ..
                CommaValue(currentHonor) ..
                    " / " .. CommaValue(maxHonor) .. " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
            1,
            1,
            1
        _G["GwExperienceFrameBar"]:SetStatusBarColor(1, 0.2, 0.2)
    end

    --  experiencebarAnimation = 0.01
    --   valPrec = 0.8

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

    experiencebarAnimation = valPrec

    if GW_LEVELING_REWARD_AVALIBLE then
        Nextlevel = Nextlevel .. " |TInterface\\AddOns\\GW2_UI\\textures\\levelreward-icon:20:20:0:0|t"
    end

    _G["GwExperienceFrameNextLevel"]:SetText(Nextlevel)
    _G["GwExperienceFrameCurrentLevel"]:SetText(restingIconString .. level)
    if showBar1 and not showBar2 then
        _G["GwExperienceFrameBar"]:SetHeight(8)
        _G["GwExperienceFrameBarCandy"]:SetHeight(8)
        _G["ExperienceBarSpark"]:SetHeight(8)
    end

    if showBar1 and showBar2 then
        _G["GwExperienceFrameBar"]:SetHeight(4)
        _G["GwExperienceFrameBarCandy"]:SetHeight(4)
        _G["ExperienceBarSpark"]:SetHeight(4)

        _G["GwExperienceFrameArtifactBar"]:SetHeight(4)
        _G["GwExperienceFrameArtifactBarCandy"]:SetHeight(4)
        _G["ArtifactBarSpark"]:SetHeight(4)
        ArtifactBarSpark:Show()
    end

    if not showBar2 then
        _G["GwExperienceFrameArtifactBar"]:SetValue(0)
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(0)
        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(0)
        ArtifactBarSpark:Hide()
    end
    if showBar1 then
        ExperienceBarSpark:Show()
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
    end
    if not showBar1 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end
end
GW.AddForProfiling("hud", "xpbar_OnEvent", xpbar_OnEvent)

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

local function updateGuildButton()
    local _, _, numOnlineMembers = GetNumGuildMembers()

    if numOnlineMembers ~= nil and numOnlineMembers > 0 then
        GwMicroButtonGuildMicroButton.darkbg:Show()

        if numOnlineMembers > 9 then
            GwMicroButtonGuildMicroButton.darkbg:SetSize(18, 18)
        else
            GwMicroButtonGuildMicroButton.darkbg:SetSize(14, 14)
        end

        _G["GwMicroButtonGuildMicroButtonString"]:Show()
        _G["GwMicroButtonGuildMicroButtonString"]:SetText(numOnlineMembers)
    else
        GwMicroButtonGuildMicroButton.darkbg:Hide()
        _G["GwMicroButtonGuildMicroButtonString"]:Hide()
    end
end
GW.AddForProfiling("hud", "updateGuildButton", updateGuildButton)

local function updateInventoryButton()
    local totalEmptySlots = 0

    for i = 0, 4 do
        local numberOfFreeSlots, _ = GetContainerNumFreeSlots(i)

        if numberOfFreeSlots ~= nil then
            totalEmptySlots = totalEmptySlots + numberOfFreeSlots
        end
    end

    GwMicroButtonBagMicroButton.darkbg:Show()
    if totalEmptySlots > 9 then
        GwMicroButtonBagMicroButton.darkbg:SetSize(18, 18)
    else
        GwMicroButtonBagMicroButton.darkbg:SetSize(14, 14)
    end

    _G["GwMicroButtonBagMicroButtonString"]:Show()
    _G["GwMicroButtonBagMicroButtonString"]:SetText(totalEmptySlots)
end
GW.AddForProfiling("hud", "updateInventoryButton", updateInventoryButton)

local microButtonFrame = CreateFrame("Frame", "GwMicroButtonFrame", UIParent, "GwMicroButtonFrame")

local microButtonPadding = 4 + 12

local function createMicroButton(key)
    local mf =
        CreateFrame(
        "Button",
        "GwMicroButton" .. key,
        microButtonFrame,
        "SecureHandlerClickTemplate,GwMicroButtonTemplate"
    )
    mf:SetPoint("CENTER", microButtonFrame, "TOPLEFT", microButtonPadding, -16)
    microButtonPadding = microButtonPadding + 24 + 4

    mf:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")
    mf:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")
    mf:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")
    mf:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")

    _G["GwMicroButton" .. key .. "String"]:SetFont(DAMAGE_TEXT_FONT, 12)
    _G["GwMicroButton" .. key .. "String"]:SetShadowColor(0, 0, 0, 0)

    _G["GwMicroButton" .. key .. "Texture"]:Hide()
    _G["GwMicroButton" .. key .. "String"]:Hide()

    return mf
end
GW.AddForProfiling("hud", "createMicroButton", createMicroButton)

local CUSTOM_MICRO_BUTTONS = {}

local function microMenuFrameShow(f, name)
    StopAnimation(name)
    StopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = true
    AddToAnimation(
        name,
        0,
        1,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        nil
    )
    AddToAnimation(
        "GwHudArtFrameMenuBackDrop",
        0,
        1,
        GetTime(),
        0.1,
        function()
            GwHudArtFrameMenuBackDrop:SetAlpha(animations["GwHudArtFrameMenuBackDrop"]["progress"])
        end,
        nil,
        nil
    )
end
GW.AddForProfiling("hud", "microMenuFrameShow", microMenuFrameShow)

local function microMenuFrameHide(f, name)
    StopAnimation(name)
    StopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = false
    AddToAnimation(
        name,
        1,
        0,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        nil
    )
    AddToAnimation(
        "GwHudArtFrameMenuBackDrop",
        1,
        0,
        GetTime(),
        0.1,
        function()
            GwHudArtFrameMenuBackDrop:SetAlpha(animations["GwHudArtFrameMenuBackDrop"]["progress"])
        end,
        nil,
        nil
    )
end
GW.AddForProfiling("hud", "microMenuFrameHide", microMenuFrameHide)

local function microMenu_OnUpdate(self, elapsed)
    self.gw_LastFadeCheck = self.gw_LastFadeCheck - elapsed
    if self.gw_LastFadeCheck > 0 then
        return
    end
    self.gw_LastFadeCheck = 0.1
    if not self:IsShown() then
        return
    end

    if self:IsMouseOver(100, -100, -100, 100) then
        if not self.gw_FadeShowing then
            microMenuFrameShow(self, self:GetName())
        end
    elseif self.gw_FadeShowing then
        microMenuFrameHide(self, self:GetName())
    end
end
GW.AddForProfiling("hud", "microMenu_OnUpdate", microMenu_OnUpdate)

local gw_sendUpdate_message_cooldown = 0
local function sendVersionCheck()
    if gw_sendUpdate_message_cooldown > GetTime() then
        return
    end
    gw_sendUpdate_message_cooldown = GetTime() + 10

    local chatToSend = "GUILD"
    local inInstanceGroup = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
    if inInstanceGroup then
        chatToSend = "INSTANCE_CHAT"
    elseif IsInGroup() then
        chatToSend = "PARTY"
        if IsInRaid() then
            chatToSend = "RAID"
        end
    end
    C_ChatInfo.SendAddonMessage("GW2_UI", VERSION_STRING, chatToSend)
end
GW.AddForProfiling("hud", "sendVersionCheck", sendVersionCheck)

local function receiveVersionCheck(self, event, prefix, message, dist, sender)
    if prefix ~= "GW2_UI" then
        return
    end

    local version, subversion, hotfix = string.match(message, "GW2_UI v(%d+).(%d+).(%d+)")
    local Currentversion, Currentsubversion, Currenthotfix = string.match(VERSION_STRING, "GW2_UI v(%d+).(%d+).(%d+)")

    if version == nil or subversion == nil or hotfix == nil then
        return
    end
    if Currentversion == nil or Currentsubversion == nil or Currenthotfix == nil then
        return
    end

    if version > Currentversion then
        GwMicroButtonupdateicon.updateType = GwLocalization["UPDATE_STRING_3"]
        GwMicroButtonupdateicon.updateTypeInt = 3
        GwMicroButtonupdateicon:Show()
    else
        if subversion > Currentsubversion then
            GwMicroButtonupdateicon.updateType = GwLocalization["UPDATE_STRING_2"]
            GwMicroButtonupdateicon.updateTypeInt = 2
            GwMicroButtonupdateicon:Show()
        else
            if hotfix > Currenthotfix then
                GwMicroButtonupdateicon.updateType = GwLocalization["UPDATE_STRING_1"]
                GwMicroButtonupdateicon.updateTypeInt = 1
                GwMicroButtonupdateicon:Show()
            end
        end
    end
end
GW.AddForProfiling("hud", "receiveVersionCheck", receiveVersionCheck)

local function getToolTip(text, action)
    if (GetBindingKey(action)) then
        return text .. " |cffa6a6a6(" .. GetBindingText(GetBindingKey(action)) .. ")" .. FONT_COLOR_CODE_CLOSE
    else
        return text
    end
end
GW.AddForProfiling("hud", "getToolTip", getToolTip)

local function setToolTip(frame, text, action)
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(getToolTip(text, action), 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("hud", "setToolTip", setToolTip)

local function hookToolTip(frame, text, action)
    if frame == nil then
        return
    end
    frame:SetScript(
        "OnEnter",
        function()
            setToolTip(frame, text, action)
            setToolTip(frame, text, action)
        end
    )
    frame:SetScript("OnLeave", GameTooltip_Hide)
end
GW.AddForProfiling("hud", "hookToolTip", hookToolTip)

local gw_addonMemoryArray = {}
local function latencyToolTip(self, elapsed)
    if self.interval > 0 then
        self.interval = self.interval - elapsed
        return
    end
    self.interval = 1

    local gw_frameRate = RoundInt(GetFramerate())
    local down, up, lagHome, lagWorld = GetNetStats()
    local gw_addonMemory = 0
    local gw_numAddons = GetNumAddOns()

    -- wipe and reuse our memtable to avoid temp pre-GC bloat on the tooltip (still get a bit from the sort)
    for i = 1, #gw_addonMemoryArray do
        gw_addonMemoryArray[i]["addonIndex"] = 0
        gw_addonMemoryArray[i]["addonMemory"] = 0
    end

    UpdateAddOnMemoryUsage()

    GameTooltip:SetOwner(GwMicroButtonMainMenuMicroButton, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(MAINMENU_BUTTON, 1, 1, 1)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_1"] .. gw_frameRate .. " fps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_2"] .. lagHome .. " ms", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_3"] .. lagWorld .. " ms", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_4"] .. RoundDec(down, 2) .. " Kbps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_5"] .. RoundDec(up, 2) .. " Kbps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)

    for i = 1, gw_numAddons do
        if type(gw_addonMemoryArray[i]) ~= "table" then
            gw_addonMemoryArray[i] = {}
        end
        local mem = GetAddOnMemoryUsage(i)
        gw_addonMemoryArray[i]["addonIndex"] = i
        gw_addonMemoryArray[i]["addonMemory"] = mem
        gw_addonMemory = gw_addonMemory + mem
    end

    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_6"] .. RoundDec(gw_addonMemory / 1024, 2) .. " MB", 0.8, 0.8, 0.8)

    if self.inDebug then
        table.sort(
            gw_addonMemoryArray,
            function(a, b)
                return a["addonMemory"] > b["addonMemory"]
            end
        )

        for k, v in pairs(gw_addonMemoryArray) do
            if v["addonIndex"] ~= 0 and (IsAddOnLoaded(v["addonIndex"]) and v["addonMemory"] ~= 0) then
                gw_addonMemory = RoundDec(v["addonMemory"] / 1024, 2)
                if gw_addonMemory ~= "0.00" then
                    GameTooltip:AddLine(
                        "(" .. gw_addonMemory .. " MB) " .. GetAddOnInfo(v["addonIndex"]),
                        0.8,
                        0.8,
                        0.8
                    )
                end
            end
        end
    else
        gw_addonMemory = RoundDec(GetAddOnMemoryUsage("GW2_UI") / 1024, 2)
        GameTooltip:AddLine("(" .. gw_addonMemory .. " MB) GW2_UI", 0.8, 0.8, 0.8)
    end

    GameTooltip:Show()
end
GW.AddForProfiling("hud", "latencyToolTip", latencyToolTip)

local function talentMicro_OnEvent()
    if GetNumUnspentTalents() > 0 then
        _G["GwMicroButtonTalentMicroButtonTexture"]:Show()
        _G["GwMicroButtonTalentMicroButtonString"]:Show()
        _G["GwMicroButtonTalentMicroButtonString"]:SetText(GetNumUnspentTalents())
    else
        _G["GwMicroButtonTalentMicroButtonTexture"]:Hide()
        _G["GwMicroButtonTalentMicroButtonString"]:Hide()
    end
end
GW.AddForProfiling("hud", "talentMicro_OnEvent", talentMicro_OnEvent)

local function gwMicro_PositionAlert(alert)
    if
        (alert ~= CollectionsMicroButtonAlert and alert ~= LFDMicroButtonAlert and alert ~= EJMicroButtonAlert and
            alert ~= StoreMicroButtonAlert and
            alert ~= CharacterMicroButtonAlert)
     then
        return
    end
    alert.Arrow:ClearAllPoints()
    alert.Arrow:SetPoint("BOTTOMLEFT", alert, "TOPLEFT", 4, -4)
    alert:ClearAllPoints()
    alert:SetPoint("TOPLEFT", alert.GwMicroButton, "BOTTOMLEFT", -18, -20)
end
GW.AddForProfiling("hud", "gwMicro_PositionAlert", gwMicro_PositionAlert)

local function modifyMicroAlert(alert, microButton)
    alert.GwMicroButton = microButton
    alert.Arrow.Arrow:SetTexCoord(0.78515625, 0.99218750, 0.58789063, 0.54687500)
    alert.Arrow.Glow:SetTexCoord(0.40625000, 0.66015625, 0.82812500, 0.77343750)
    alert.Arrow.Glow:ClearAllPoints()
    alert.Arrow.Glow:SetPoint("BOTTOM")
end
GW.AddForProfiling("hud", "modifyMicroAlert", modifyMicroAlert)

local function LoadMicroMenu()
    local mi = 1
    for k, v in pairs(MICRO_BUTTONS) do
        CUSTOM_MICRO_BUTTONS[mi] = v
        if v == "CharacterMicroButton" then
            mi = mi + 1
            CUSTOM_MICRO_BUTTONS[mi] = "BagMicroButton"
        end
        mi = mi + 1
    end

    for k, v in pairs(CUSTOM_MICRO_BUTTONS) do
        if v ~= "SpellbookMicroButton" then
            createMicroButton(v)
        else
            if not GetSetting("USE_TALENT_WINDOW") then
                createMicroButton(v)
            end
        end
    end

    if GetSetting("USE_CHARACTER_WINDOW") then
        GwMicroButtonCharacterMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        GwMicroButtonCharacterMicroButton:SetAttribute(
            "_onclick",
            [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
            ]=]
        )
    else
        GwMicroButtonCharacterMicroButton:SetScript(
            "OnClick",
            function()
                ToggleCharacter("PaperDollFrame")
            end
        )
    end

    GwMicroButtonBagMicroButton:SetScript(
        "OnClick",
        function()
            ToggleAllBags()
        end
    )

    if GetSetting("USE_TALENT_WINDOW") then
        GwMicroButtonTalentMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        GwMicroButtonTalentMicroButton:SetAttribute(
            "_onclick",
            [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
            ]=]
        )
    else
        GwMicroButtonSpellbookMicroButton:SetScript(
            "OnClick",
            function()
                ToggleSpellBook(BOOKTYPE_SPELL)
            end
        )
        GwMicroButtonSpellbookMicroButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        GwMicroButtonTalentMicroButton:SetScript(
            "OnClick",
            function()
                ToggleTalentFrame()
            end
        )
    end

    GwMicroButtonAchievementMicroButton:SetScript(
        "OnClick",
        function()
            ToggleAchievementFrame()
        end
    )
    GwMicroButtonQuestLogMicroButton:SetScript(
        "OnClick",
        function()
            ToggleQuestLog()
        end
    )
    GwMicroButtonGuildMicroButton:SetScript(
        "OnClick",
        function()
            ToggleGuildFrame()
        end
    )
    GwMicroButtonLFDMicroButton:SetScript(
        "OnClick",
        function()
            PVEFrame_ToggleFrame()
        end
    )
    GwMicroButtonCollectionsMicroButton:SetScript(
        "OnClick",
        function()
            ToggleCollectionsJournal()
        end
    )
    GwMicroButtonEJMicroButton:SetScript(
        "OnClick",
        function()
            ToggleEncounterJournal()
        end
    )

    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnClick",
        function()
            if (not GameMenuFrame:IsShown()) then
                if (VideoOptionsFrame:IsShown()) then
                    VideoOptionsFrameCancel:Click()
                elseif (AudioOptionsFrame:IsShown()) then
                    AudioOptionsFrameCancel:Click()
                elseif (InterfaceOptionsFrame:IsShown()) then
                    InterfaceOptionsFrameCancel:Click()
                end

                CloseMenus()
                CloseAllWindows()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
                ShowUIPanel(GameMenuFrame)
            else
                PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
                HideUIPanel(GameMenuFrame)
                MainMenuMicroButton_SetNormal()
            end
        end
    )

    if GwMicroButtonHelpMicroButton ~= nil then
        GwMicroButtonHelpMicroButton:SetScript("OnClick", ToggleHelpFrame)
    end
    if GwMicroButtonStoreMicroButton ~= nil then
        GwMicroButtonStoreMicroButton:SetScript("OnClick", ToggleStoreUI)
    end

    GwMicroButtonTalentMicroButton:SetScript("OnEvent", talentMicro_OnEvent)
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_LEVEL_UP")
    GwMicroButtonTalentMicroButton:RegisterEvent("UPDATE_BINDINGS")
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_TALENT_UPDATE")
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    hookToolTip(GwMicroButtonCharacterMicroButton, CHARACTER_BUTTON, 'TOGGLECHARACTER0"')
    hookToolTip(GwMicroButtonBagMicroButton, GwLocalization["GW_BAG_MICROBUTTON_STRING"], "OPENALLBAGS")
    hookToolTip(GwMicroButtonSpellbookMicroButton, SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
    hookToolTip(GwMicroButtonTalentMicroButton, TALENTS_BUTTON, "TOGGLETALENTS")
    hookToolTip(GwMicroButtonAchievementMicroButton, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
    hookToolTip(GwMicroButtonQuestLogMicroButton, QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
    hookToolTip(GwMicroButtonGuildMicroButton, GUILD, "TOGGLEGUILDTAB")
    hookToolTip(GwMicroButtonLFDMicroButton, DUNGEONS_BUTTON, "TOGGLEGROUPFINDER")
    hookToolTip(GwMicroButtonCollectionsMicroButton, COLLECTIONS, "TOGGLECOLLECTIONS")
    hookToolTip(GwMicroButtonEJMicroButton, ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL")

    GwMicroButtonBagMicroButton.interval = 0
    GwMicroButtonBagMicroButton:SetScript(
        "OnUpdate",
        function(self, elapsed)
            self.interval = self.interval - elapsed
            if self.interval > 0 then
                return
            end

            self.interval = 0.5
            updateInventoryButton()
        end
    )

    GwMicroButtonGuildMicroButton.interval = 0
    GwMicroButtonGuildMicroButton:SetScript(
        "OnUpdate",
        function(self, elapsed)
            if self.interval > 0 then
                self.interval = self.interval - elapsed
                return
            end
            self.interval = 15.0
            GuildRoster()
        end
    )
    GwMicroButtonGuildMicroButton:SetScript("OnEvent", updateGuildButton)
    GwMicroButtonGuildMicroButton:RegisterEvent("GUILD_ROSTER_UPDATE")

    GwMicroButtonMainMenuMicroButton.inDebug = GW.inDebug
    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnEnter",
        function(self)
            self.interval = 0
            self:SetScript("OnUpdate", latencyToolTip)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, ANCHOR_BOTTOMLEFT)
        end
    )

    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnLeave",
        function()
            GwMicroButtonMainMenuMicroButton:SetScript("OnUpdate", nil)
            GameTooltip_Hide()
        end
    )

    talentMicro_OnEvent()
    updateGuildButton()
    createOrderBar()

    --Create update notifier
    local updateNotificationIcon = createMicroButton("updateicon")
    GwMicroButtonupdateicon.updateTypeInt = 0
    GwMicroButtonupdateicon:Hide()

    updateNotificationIcon:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(updateNotificationIcon, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
            GameTooltip:ClearLines()
            GameTooltip:AddLine("GW2_UI", 1, 1, 1)
            GameTooltip:AddLine(updateNotificationIcon.updateType, 1, 1, 1)
            GameTooltip:Show()
        end
    )
    updateNotificationIcon:SetScript("OnLeave", GameTooltip_Hide)
    C_ChatInfo.RegisterAddonMessagePrefix("GW2_UI")

    updateNotificationIcon:RegisterEvent("CHAT_MSG_ADDON")
    updateNotificationIcon:RegisterEvent("GROUP_ROSTER_UPDATE")
    updateNotificationIcon:SetScript(
        "OnEvent",
        function(self, event, prefix, message, dist, sender)
            if event == "CHAT_MSG_ADDON" then
                receiveVersionCheck(self, event, prefix, message, dist, sender)
            else
                sendVersionCheck()
            end
        end
    )

    -- if set to fade micro menu, add fader
    if GetSetting("FADE_MICROMENU") then
        microButtonFrame.gw_LastFadeCheck = -1
        microButtonFrame.gw_FadeShowing = true
        microButtonFrame:SetScript("OnUpdate", microMenu_OnUpdate)
    end

    -- fix tutorial alerts and hide the micromenu bar
    MicroButtonAndBagsBar:Hide()
    -- talent alert is always hidden by actionbars because we have a custom # on the button instead
    modifyMicroAlert(CollectionsMicroButtonAlert, GwMicroButtonCollectionsMicroButton)
    modifyMicroAlert(LFDMicroButtonAlert, GwMicroButtonLFDMicroButton)
    modifyMicroAlert(EJMicroButtonAlert, GwMicroButtonEJMicroButton)
    modifyMicroAlert(StoreMicroButtonAlert, GwMicroButtonHelpMicroButton)
    modifyMicroAlert(CharacterMicroButtonAlert, GwMicroButtonCharacterMicroButton)
    hooksecurefunc("MainMenuMicroButton_PositionAlert", gwMicro_PositionAlert)
end
GW.LoadMicroMenu = LoadMicroMenu

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
    f.rewardHeader:SetText(GwLocalization["LEVEL_REWARDS_RHEADER"])

    f.levelHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    f.levelHeader:SetTextColor(0.6, 0.6, 0.6)
    f.levelHeader:SetText(GwLocalization["LEVEL_REWARDS_LHEADER"])

    local fnGwCloseLevelingRewards_OnClick = function(self, button)
        GwLevelingRewards:Hide()
    end
    GwCloseLevelingRewards:SetScript("OnClick", fnGwCloseLevelingRewards_OnClick)
    GwCloseLevelingRewards:SetText(GwLocalization["LEVEL_REWARDS_CLOSE"])

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
                _G["GwLevelingRewardsItem" .. i]:SetScript("OnLeave", GameTooltip_Hide)
            end
            if v["type"] == "TALENT" then
                _G["GwLevelingRewardsItem" .. i].icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talent-icon")
                _G["GwLevelingRewardsItem" .. i].name:SetText(GwLocalization["LEVEL_REWARDS_TALENT"])
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

local function orderFollower_OnEnter(self)
    if (self.name) then
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self.Count, "BOTTOMRIGHT", -20, -20)
        GameTooltip:AddLine(self.name)
        if (self.description) then
            GameTooltip:AddLine(self.description, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end
end
GW.AddForProfiling("hud", "orderFollower_OnEnter", orderFollower_OnEnter)

local function createFollower(self, i)
    local newFrame = CreateFrame("FRAME", "GwOrderHallFollower" .. i, self, "GwOrderHallFollower")
    newFrame.Count:SetFont(UNIT_NAME_FONT, 14)
    newFrame.Count:SetShadowOffset(1, -1)
    newFrame:SetScript("OnEnter", orderFollower_OnEnter)
    newFrame:SetScript("OnLeave", GameTooltip_Hide)
    newFrame:SetParent(self)
    newFrame:ClearAllPoints()
    newFrame:SetPoint("LEFT", self.currency, "RIGHT", 100 * (i - 1), 0)
    return newFrame
end
GW.AddForProfiling("hud", "createFollower", createFollower)

local function updateOrderBar(self)
    local categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)

    for index, category in ipairs(categoryInfo) do
        local categoryInfoFrame = _G["GwOrderHallFollower" .. index]
        if _G["GwOrderHallFollower" .. index] == nil then
            categoryInfoFrame = createFollower(self, index)
        end

        categoryInfoFrame.Icon:SetTexture(category.icon)
        categoryInfoFrame.Icon:SetTexCoord(0, 1, 0.25, 0.75)
        categoryInfoFrame.name = category.name
        categoryInfoFrame.description = category.description

        categoryInfoFrame.Count:SetFormattedText(ORDER_HALL_COMMANDBAR_CATEGORY_COUNT, category.count, category.limit)

        categoryInfoFrame:Show()
    end
end
GW.AddForProfiling("hud", "updateOrderBar", updateOrderBar)

local function orderBar_OnEvent(self, event)
    if OrderHallCommandBar then
        OrderHallCommandBar:SetShown(false)
        OrderHallCommandBar:UnregisterAllEvents()
        OrderHallCommandBar:SetScript("OnShow", Self_Hide)
    end

    local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
    self:SetShown(inOrderHall)

    local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)

    local _, amount, _ = GetCurrencyInfo(primaryCurrency)
    amount = BreakUpLargeNumbers(amount)
    self.currency:SetText(amount)

    updateOrderBar(self)
end
GW.AddForProfiling("hud", "orderBar_OnEvent", orderBar_OnEvent)

createOrderBar = function()
    CreateFrame("FRAME", "GwOrderhallBar", UIParent, "GwOrderhallBar")
    GwOrderhallBar.currency:SetFont(UNIT_NAME_FONT, 14)
    GwOrderhallBar.currency:SetShadowOffset(1, -1)

    GwOrderhallBar:RegisterUnitEvent("UNIT_AURA", "player")
    GwOrderhallBar:RegisterUnitEvent("UNIT_PHASE", "player")
    GwOrderhallBar:RegisterEvent("PLAYER_ALIVE")

    local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
    if inOrderHall then
        GwOrderhallBar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
        GwOrderhallBar:RegisterEvent("DISPLAY_SIZE_CHANGED")
        GwOrderhallBar:RegisterEvent("UI_SCALE_CHANGED")
        GwOrderhallBar:RegisterEvent("GARRISON_TALENT_COMPLETE")
        GwOrderhallBar:RegisterEvent("GARRISON_TALENT_UPDATE")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_ADDED")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
        GwOrderhallBar:RegisterEvent("GARRISON_MISSION_FINISHED")
        GwOrderhallBar:RegisterEvent("UPDATE_BINDINGS")
    end

    GwOrderhallBar:SetScript("OnEvent", orderBar_OnEvent)
    GwOrderhallBar:SetScript(
        "OnShow",
        function()
            GwOrderhallBar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
            GwOrderhallBar:RegisterEvent("DISPLAY_SIZE_CHANGED")
            GwOrderhallBar:RegisterEvent("UI_SCALE_CHANGED")
            GwOrderhallBar:RegisterEvent("GARRISON_TALENT_COMPLETE")
            GwOrderhallBar:RegisterEvent("GARRISON_TALENT_UPDATE")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_ADDED")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
            GwOrderhallBar:RegisterEvent("GARRISON_MISSION_FINISHED")
            GwOrderhallBar:RegisterEvent("UPDATE_BINDINGS")
        end
    )

    GwOrderhallBar:SetScript(
        "OnHide",
        function()
            GwOrderhallBar:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
            GwOrderhallBar:UnregisterEvent("DISPLAY_SIZE_CHANGED")
            GwOrderhallBar:UnregisterEvent("UI_SCALE_CHANGED")
            GwOrderhallBar:UnregisterEvent("GARRISON_TALENT_COMPLETE")
            GwOrderhallBar:UnregisterEvent("GARRISON_TALENT_UPDATE")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_REMOVED")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
            GwOrderhallBar:UnregisterEvent("GARRISON_MISSION_FINISHED")
            GwOrderhallBar:UnregisterEvent("UPDATE_BINDINGS")
        end
    )

    orderBar_OnEvent(GwOrderhallBar)
end
GW.AddForProfiling("hud", "createOrderBar", createOrderBar)

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

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterEvent("UNIT_HEALTH")
    hudArtFrame:RegisterEvent("UNIT_MAXHEALTH")
    selectBg()
    combatHealthState()
end
GW.LoadHudArt = LoadHudArt

local function LoadXPBar()
    loadRewards()

    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")
    GwlevelLableRightButton:SetScript("OnClick", xpbar_OnClick)

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

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

    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript(
        "OnLeave",
        function()
            GameTooltip_Hide()
            UIFrameFadeIn(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 1)
            UIFrameFadeIn(_G["GwExperienceFrameArtifactBar"], 0.2, _G["GwExperienceFrameArtifactBar"]:GetAlpha(), 1)
        end
    )
end
GW.LoadXPBar = LoadXPBar
