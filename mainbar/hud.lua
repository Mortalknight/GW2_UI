local _, GW = ...
local comma_value = GW.comma_value
local round = GW.round
local lerp = GW.lerp

--GW_PowerBarColorCustom = PowerBarColor;
GW_PowerBarColorCustom = {}

GW_PowerBarColorCustom["MANA"] = {r = 37 / 255, g = 133 / 255, b = 240 / 255}
GW_PowerBarColorCustom["RAGE"] = {r = 240 / 255, g = 66 / 255, b = 37 / 255}
GW_PowerBarColorCustom["ENERGY"] = {r = 240 / 255, g = 200 / 255, b = 37 / 255}
GW_PowerBarColorCustom["LUNAR"] = {r = 130 / 255, g = 172 / 255, b = 230 / 255}
GW_PowerBarColorCustom["RUNIC_POWER"] = {r = 37 / 255, g = 214 / 255, b = 240 / 255}
GW_PowerBarColorCustom["FOCUS"] = {r = 240 / 255, g = 121 / 255, b = 37 / 255}
GW_PowerBarColorCustom["FURY"] = {r = 166 / 255, g = 37 / 255, b = 240 / 255}

GW_DEBUFF_COLOR = {}
GW_DEBUFF_COLOR["Curse"] = {r = 97 / 255, g = 72 / 255, b = 177 / 255}
GW_DEBUFF_COLOR["Disease"] = {r = 177 / 255, g = 114 / 255, b = 72 / 255}
GW_DEBUFF_COLOR["Magic"] = {r = 72 / 255, g = 94 / 255, b = 177 / 255}
GW_DEBUFF_COLOR["Poison"] = {r = 94 / 255, g = 177 / 255, b = 72 / 255}

GW_FACTION_BAR_COLORS = FACTION_BAR_COLORS
GW_FACTION_BAR_COLORS = {
    [1] = {r = 0.8, g = 0.3, b = 0.22},
    [2] = {r = 0.8, g = 0.3, b = 0.22},
    [3] = {r = 0.75, g = 0.27, b = 0},
    [4] = {r = 0.9, g = 0.7, b = 0},
    [5] = {r = 0, g = 0.6, b = 0.1},
    [6] = {r = 0, g = 0.6, b = 0.1},
    [7] = {r = 0, g = 0.6, b = 0.1},
    [8] = {r = 0, g = 0.6, b = 0.1},
    [9] = {r = 0.22, g = 0.37, b = 0.98}
}

GW_COLOR_FRIENDLY = {
    [1] = {r = 88 / 255, g = 170 / 255, b = 68 / 255},
    [2] = {r = 159 / 255, g = 36 / 255, b = 20 / 255},
    [3] = {r = 159 / 255, g = 159 / 255, b = 159 / 255}
}

bloodSpark = {}

bloodSpark[0] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[1] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[2] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5}
bloodSpark[3] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5}
bloodSpark[4] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5}
bloodSpark[5] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5}
bloodSpark[6] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5}
bloodSpark[7] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5}
bloodSpark[8] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}

bloodSpark[9] = {left = 0, right = 0.125, top = 0.5, bottom = 1}
bloodSpark[10] = {left = 0.125, right = 0.125 * 2, top = 0.5, bottom = 1}
bloodSpark[11] = {left = 0.125 * 2, right = 0.125 * 3, top = 0.5, bottom = 1}
bloodSpark[12] = {left = 0.125 * 3, right = 0.125 * 4, top = 0.5, bottom = 1}
bloodSpark[13] = {left = 0.125 * 4, right = 0.125 * 5, top = 0.5, bottom = 1}
bloodSpark[14] = {left = 0.125 * 5, right = 0.125 * 6, top = 0.5, bottom = 1}
bloodSpark[15] = {left = 0.125 * 6, right = 0.125 * 7, top = 0.5, bottom = 1}
bloodSpark[16] = {left = 0.125 * 7, right = 0.125 * 8, top = 0.5, bottom = 1}

bloodSpark[17] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[18] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5}
bloodSpark[19] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5}
bloodSpark[20] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5}
bloodSpark[21] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5}
bloodSpark[22] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5}
bloodSpark[23] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5}
bloodSpark[24] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}

GW_CLASS_ICONS = {}

GW_CLASS_ICONS[0] = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1}

GW_CLASS_ICONS[1] = {l = 0.0625 * 11, r = 0.0625 * 12, t = 0, b = 1}
GW_CLASS_ICONS[2] = {l = 0.0625 * 10, r = 0.0625 * 11, t = 0, b = 1}
GW_CLASS_ICONS[3] = {l = 0.0625 * 9, r = 0.0625 * 10, t = 0, b = 1}
GW_CLASS_ICONS[4] = {l = 0.0625 * 8, r = 0.0625 * 9, t = 0, b = 1}
GW_CLASS_ICONS[5] = {l = 0.0625 * 7, r = 0.0625 * 8, t = 0, b = 1}
GW_CLASS_ICONS[6] = {l = 0.0625 * 6, r = 0.0625 * 7, t = 0, b = 1}
GW_CLASS_ICONS[7] = {l = 0.0625 * 5, r = 0.0625 * 6, t = 0, b = 1}
GW_CLASS_ICONS[8] = {l = 0.0625 * 4, r = 0.0625 * 5, t = 0, b = 1}
GW_CLASS_ICONS[9] = {l = 0.0625 * 3, r = 0.0625 * 4, t = 0, b = 1}
GW_CLASS_ICONS[10] = {l = 0.0625 * 2, r = 0.0625 * 3, t = 0, b = 1}
GW_CLASS_ICONS[11] = {l = 0.0625 * 1, r = 0.0625 * 2, t = 0, b = 1}
GW_CLASS_ICONS[12] = {l = 0, r = 0.0625 * 1, t = 0, b = 1}

GW_CLASS_ICONS["dead"] = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1}

GW_CLASS_COLORS_RAIDFRAME = {}

GW_CLASS_COLORS_RAIDFRAME[1] = {r = 90 / 255, g = 54 / 255, b = 38 / 255} --Warrior
GW_CLASS_COLORS_RAIDFRAME[2] = {r = 177 / 255, g = 72 / 255, b = 117 / 255} --Paladin
GW_CLASS_COLORS_RAIDFRAME[3] = {r = 99 / 255, g = 125 / 255, b = 53 / 255} --Hunter
GW_CLASS_COLORS_RAIDFRAME[4] = {r = 190 / 255, g = 183 / 255, b = 79 / 255} --Rogue
GW_CLASS_COLORS_RAIDFRAME[5] = {r = 205 / 255, g = 205 / 255, b = 205 / 255} --Priest
GW_CLASS_COLORS_RAIDFRAME[6] = {r = 148 / 255, g = 62 / 255, b = 62 / 255} --Death Knight
GW_CLASS_COLORS_RAIDFRAME[7] = {r = 30 / 255, g = 44 / 255, b = 149 / 255} -- Shaman
GW_CLASS_COLORS_RAIDFRAME[8] = {r = 62 / 255, g = 121 / 255, b = 149 / 255} -- Mage
GW_CLASS_COLORS_RAIDFRAME[9] = {r = 125 / 255, g = 88 / 255, b = 154 / 255} -- Warlock
GW_CLASS_COLORS_RAIDFRAME[10] = {r = 66 / 255, g = 151 / 255, b = 112 / 255} -- Monk
GW_CLASS_COLORS_RAIDFRAME[11] = {r = 158 / 255, g = 103 / 255, b = 37 / 255} -- Druid
GW_CLASS_COLORS_RAIDFRAME[12] = {r = 72 / 255, g = 38 / 255, b = 148 / 255} -- Demon Hunter

GW_FACTION_COLOR = {}
GW_FACTION_COLOR[1] = {r = 163 / 255, g = 46 / 255, b = 54 / 255}
GW_FACTION_COLOR[2] = {r = 57 / 255, g = 115 / 255, b = 186 / 255}

GW_TARGET_FRAME_ART = {
    ["minus"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["minus"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["normal"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["elite"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit",
    ["worldboss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit",
    ["rare"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",
    ["rareelite"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",
    ["prestige1"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_p1",
    ["prestige2"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_p2",
    ["prestige3"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_p3",
    ["prestige4"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_p4"
}

GW_DODGEBAR_SPELLS = {}
GW_DODGEBAR_SPELLS[1] = {100, 198304}
GW_DODGEBAR_SPELLS[2] = {190784}
GW_DODGEBAR_SPELLS[3] = {781, 190925}
GW_DODGEBAR_SPELLS[4] = {195457}
GW_DODGEBAR_SPELLS[5] = {121536}
GW_DODGEBAR_SPELLS[6] = {212552}
GW_DODGEBAR_SPELLS[7] = {196884}
GW_DODGEBAR_SPELLS[8] = {212653, 1953}
GW_DODGEBAR_SPELLS[9] = {48018}
GW_DODGEBAR_SPELLS[10] = {109132, 115008}
GW_DODGEBAR_SPELLS[11] = {102280, 102401}
GW_DODGEBAR_SPELLS[12] = {189110, 195072}

GW_MAIN_HUD_FRAMES = {
    "MainMenuBarArtFrame",
    "GwHudArtFrame",
    "MultiBarBottomRight",
    "MultiBarBottomLeft",
    "GwPlayerPowerBar",
    "GwPlayerAuraFrame",
    "GwPlayerClassPower",
    "GwPlayerHealthGlobe",
    "GwPlayerPetFrame",
    "PetActionButton1",
    "PetActionButton2",
    "PetActionButton3",
    "PetActionButton4",
    "PetActionButton5",
    "PetActionButton6",
    "PetActionButton7",
    "PetActionButton8",
    "PetActionButton9",
    "PetActionButton10",
    "PetActionButton11",
    "PetActionButton12"
}
GW_MAIN_HUD_FRAMES_OLD_STATE = {}

local experiencebarAnimation = 0

function loadHudArt()
    local hudArtFrame = CreateFrame("Frame", "GwHudArtFrame", UIParent, "GwHudArtFrame")

    hudArtFrame:SetScript(
        "OnEvent",
        function(self, event, unit)
            if event == "UNIT_AURA" and unit == "player" then
                select_actionhud_bg()
                return
            end

            if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
                select_actionhud_bg()
                return
            end
            if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" and unit == "player" then
                combat_hud_healthstate()
                return
            end
        end
    )

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterEvent("UNIT_HEALTH")
    hudArtFrame:RegisterEvent("UNIT_MAXHEALTH")
    select_actionhud_bg()
    combat_hud_healthstate()
end

local gw_reputation_vals = nil
local gw_honor_vals = nil
function loadExperienceBar()
    gw_load_levelingrewads()

    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")
    GwlevelLableRightButton:SetScript("OnClick", gw_experienceBar_OnClick)
    local eName = experiencebar:GetName()

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    _G["GwExperienceFrameArtifactBar"].artifactBarAnimation = 0
    _G["GwExperienceFrameNextLevel"]:SetFont(UNIT_NAME_FONT, 12)
    _G["GwExperienceFrameCurrentLevel"]:SetFont(UNIT_NAME_FONT, 12)

    update_experiencebar_size()
    update_experiencebar_data()

    experiencebar:SetScript("OnEvent", update_experiencebar_data)

    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_FACTION")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    experiencebar:RegisterEvent("ARTIFACT_XP_UPDATE")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
    experiencebar:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

    experiencebar:SetScript("OnEnter", show_experiencebar_tooltip)
    experiencebar:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
            UIFrameFadeIn(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 1)
            UIFrameFadeIn(_G["GwExperienceFrameArtifactBar"], 0.2, _G["GwExperienceFrameArtifactBar"]:GetAlpha(), 1)
        end
    )
end

function show_experiencebar_tooltip()
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
                comma_value(valCurrent) ..
                    " / " .. comma_value(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r",
            1,
            1,
            1
        )
    end

    if rested ~= nil then
        GameTooltip:AddLine(
            GwLocalization["EXP_BAR_TOOLTIP_EXP_RESTED"] ..
                comma_value(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r",
            1,
            1,
            1
        )
    end

    UIFrameFadeOut(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 0)
    UIFrameFadeOut(_G["GwExperienceFrameArtifactBar"], 0.2, _G["GwExperienceFrameArtifactBar"]:GetAlpha(), 0)

    local showArtifact = HasArtifactEquipped()

    if showArtifact then
        local numPoints, artifactXP, xpForNextPoint = gw_artifact_points()

        local artifactVal = artifactXP / xpForNextPoint

        GameTooltip:AddLine(
            GwLocalization["EXP_BAR_TOOLTIP_ARTIFACT"] ..
                comma_value(artifactXP) ..
                    " / " ..
                        comma_value(xpForNextPoint) ..
                            " |cffa6a6a6 (" .. math.floor((artifactXP / xpForNextPoint) * 100) .. "%)|r",
            1,
            1,
            1
        )
    end

    GameTooltip:Show()
end

function gw_experienceBar_OnClick()
    if HasArtifactEquipped() then
        SocketInventoryItem(16)
    else
        GwLevelingRewards:Show()
    end
end

function gw_artifact_points()
    local itemID,
        altItemID,
        name,
        icon,
        totalXP,
        pointsSpent,
        quality,
        artifactAppearanceID,
        appearanceModID,
        itemAppearanceID,
        altItemAppearanceID,
        altOnTop,
        artifactTier = C_ArtifactUI.GetEquippedArtifactInfo()

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

function update_experiencebar_data(self, event)
    if event == "CHAT_MSG_COMBAT_HONOR_GAIN" and UnitInBattleground("player") ~= nil then
        local delayUpdateTime = GetTime() + 0.4
        GwExperienceFrame:SetScript(
            "OnUpdate",
            function()
                if GetTime() < delayUpdateTime then
                    return
                end
                update_experiencebar_data(self, nil)
                GwExperienceFrame:SetScript("OnUpdate", nil)
            end
        )
    end

    gw_leveling_display_rewards()

    local showArtifact = HasArtifactEquipped()

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
    --8X ReputationWatchBar:Hide()
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
                local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
                local friendID,
                    friendRep,
                    friendMaxRep,
                    friendName,
                    friendText,
                    friendTexture,
                    friendTextLevel,
                    friendThreshold,
                    nextFriendThreshold = GetFriendshipReputation(factionID)
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
                                comma_value((currentValue - 0)) ..
                                    " / " ..
                                        comma_value((maxValueParagon - 0)) ..
                                            " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                        1,
                        1,
                        1

                    _G["GwExperienceFrameBar"]:SetStatusBarColor(
                        GW_FACTION_BAR_COLORS[9].r,
                        GW_FACTION_BAR_COLORS[9].g,
                        GW_FACTION_BAR_COLORS[9].b
                    )
                elseif (friendID ~= nil) then
                    if (nextFriendThreshold) then
                        valPrec = (friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)
                        gw_reputation_vals =
                            friendName ..
                                GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                    comma_value((friendRep - friendThreshold)) ..
                                        " / " ..
                                            comma_value((nextFriendThreshold - friendThreshold)) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    else
                        valPrec = 1
                        gw_reputation_vals =
                            friendName ..
                                GwLocalization["EXP_BAR_TOOLTIP_REP"] ..
                                    comma_value(friendMaxRep) ..
                                        " / " ..
                                            comma_value(friendMaxRep) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    end
                    _G["GwExperienceFrameBar"]:SetStatusBarColor(
                        GW_FACTION_BAR_COLORS[5].r,
                        GW_FACTION_BAR_COLORS[5].g,
                        GW_FACTION_BAR_COLORS[5].b
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
                                    comma_value((earnedValue - bottomValue)) ..
                                        " / " ..
                                            comma_value((topValue - bottomValue)) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
                            1,
                            1,
                            1
                    end
                    _G["GwExperienceFrameBar"]:SetStatusBarColor(
                        GW_FACTION_BAR_COLORS[reaction].r,
                        GW_FACTION_BAR_COLORS[reaction].g,
                        GW_FACTION_BAR_COLORS[reaction].b
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

    if showArtifact then
        showBar2 = true
        local numPoints, artifactXP, xpForNextPoint = gw_artifact_points()
        local artifactVal = artifactXP / xpForNextPoint

        _G["GwExperienceFrameArtifactBarCandy"]:SetValue(artifactVal)

        addToAnimation(
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
                comma_value(currentHonor) ..
                    " / " .. comma_value(maxHonor) .. " |cffa6a6a6 (" .. math.floor(valPrec * 100) .. "%)|r",
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

        gw_expFlare_animation()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end

    expFlare.soundCooldown = 0
    local expSoundCooldown = 0
    local startTime = GetTime()

    animationSpeed = GW.dif(experiencebarAnimation, valPrec)
    animationSpeed = math.min(15, math.max(5, 10 * animationSpeed))

    addToAnimation(
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
                expFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)
            end
            _G["GwExperienceFrameBarRested"]:SetValue(rested)
            _G["GwExperienceFrameBarRested"]:SetPoint(
                "LEFT",
                _G["GwExperienceFrameBar"],
                "LEFT",
                _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"],
                0
            )

            if GainBigExp and expFlare.soundCooldown < GetTime() then
                expSoundCooldown =
                    math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                _G["GwExperienceFrameBar"]:SetValue(animations["experiencebarAnimation"]["progress"])
                ExperienceBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                expFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)

                expFlare.soundCooldown = GetTime() + expSoundCooldown
                PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\exp_gain_ping.ogg", "SFX")

                animations["experiencebarAnimation"]["from"] = step
            end
        end
    )
    addToAnimation(
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

function gw_expFlare_animation()
    expFlare:Show()

    addToAnimation(
        "expFlare",
        0,
        1,
        GetTime(),
        1,
        function(prog)
            expFlare.texture:SetAlpha(1)

            expFlare.texture:SetRotation(lerp(0, 3, prog))
            if prog > 0.75 then
                expFlare.texture:SetAlpha(lerp(1, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end
        end,
        nil,
        function()
            expFlare:Hide()
        end
    )
end

function update_experiencebar_size()
    local m = (UIParent:GetWidth() - 180) / 10
    for i = 1, 9 do
        local rm = (m * i) + 90
        _G["barsep" .. i]:ClearAllPoints()
        _G["barsep" .. i]:SetPoint("LEFT", "GwExperienceFrame", "LEFT", rm, 0)
    end

    local m = (UIParent:GetWidth() - 180)
    dubbleBarSep:SetWidth(m)
    dubbleBarSep:ClearAllPoints()
    dubbleBarSep:SetPoint("LEFT", "GwExperienceFrame", "LEFT", 90, 0)
end

action_hud_auras = {}

function registerActionHudAura(aura, left, right)
    action_hud_auras[aura] = {}
    action_hud_auras[aura]["aura"] = aura
    action_hud_auras[aura]["left"] = left
    action_hud_auras[aura]["right"] = right
end
local currentTexture = nil

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

function select_actionhud_bg()
    if not gwGetSetting("HUD_SPELL_SWAP") then
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
            local name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID =
                UnitBuff("player", i)
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

function combat_hud_healthstate()
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

function gw_breath_meter()
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

local function updateGuildButton()
    local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers()

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

local function updateInventoryButton()
    local totalEmptySlots = 0

    for i = 0, 4 do
        local numberOfFreeSlots, bagType = GetContainerNumFreeSlots(i)

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

local microButtonFrame = CreateFrame("Frame", "GwMicroButtonFrame", UIParent, "GwMicroButtonFrame")

local microButtonPadding = 4 + 12

local function fnMf_OnEnter(self)
    self:SetSize(28, 28)
end
local function fnMf_OnLeave(self)
    self:SetSize(24, 24)
end
function create_micro_button(key)
    local mf =
        CreateFrame(
        "Button",
        "GwMicroButton" .. key,
        microButtonFrame,
        "SecureHandlerClickTemplate,GwMicroButtonTemplate"
    )
    mf:SetScript("OnEnter", fnMf_OnEnter)
    mf:SetScript("OnLeave", fnMf_OnLeave)
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

local CUSTOM_MICRO_BUTTONS = {}
local gw_latencyToolTipUpdate = 0
local gw_frameRate = 0

local function microMenuFrameShow(f, name)
    GwStopAnimation(name)
    GwStopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = true
    addToAnimation(
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
    addToAnimation(
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

local function microMenuFrameHide(f, name)
    GwStopAnimation(name)
    GwStopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = false
    addToAnimation(
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
    addToAnimation(
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

function gwCreateMicroMenu()
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
            create_micro_button(v)
        else
            if not gwGetSetting("USE_TALENT_WINDOW_DEV") then
                create_micro_button(v)
            end
        end
    end

    if gwGetSetting("USE_CHARACTER_WINDOW") then
        GwMicroButtonCharacterMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        GwMicroButtonCharacterMicroButton:SetAttribute(
            "_OnClick",
            [=[
            self:GetFrameRef('GwCharacterWindow'):SetAttribute('windowPanelOpen', 1)
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

    if gwGetSetting("USE_TALENT_WINDOW_DEV") then
        GwMicroButtonTalentMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        GwMicroButtonTalentMicroButton:SetAttribute(
            "_OnClick",
            [=[
            self:GetFrameRef('GwCharacterWindow'):SetAttribute('windowPanelOpen', 2)
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

    GwMicroButtonStoreMicroButton:SetScript("OnClick", ToggleStoreUI)
    GwMicroButtonStoreMicroButton:SetScript("OnEnter", nil)
    GwMicroButtonStoreMicroButton:SetScript("OnLeave", nil)

    GwMicroButtonTalentMicroButton:SetScript("OnEvent", gw_update_talentMicrobar)
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_LEVEL_UP")
    GwMicroButtonTalentMicroButton:RegisterEvent("UPDATE_BINDINGS")
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_TALENT_UPDATE")
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    --8X GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED");

    gw_microButtonHookToolTip(GwMicroButtonCharacterMicroButton, CHARACTER_BUTTON, 'TOGGLECHARACTER0"')
    gw_microButtonHookToolTip(GwMicroButtonBagMicroButton, GwLocalization["GW_BAG_MICROBUTTON_STRING"], "OPENALLBAGS")
    gw_microButtonHookToolTip(GwMicroButtonSpellbookMicroButton, SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
    gw_microButtonHookToolTip(GwMicroButtonTalentMicroButton, TALENTS_BUTTON, "TOGGLETALENTS")
    gw_microButtonHookToolTip(GwMicroButtonAchievementMicroButton, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
    gw_microButtonHookToolTip(GwMicroButtonQuestLogMicroButton, QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
    gw_microButtonHookToolTip(GwMicroButtonGuildMicroButton, GUILD, "TOGGLEGUILDTAB")
    gw_microButtonHookToolTip(GwMicroButtonLFDMicroButton, DUNGEONS_BUTTON, "TOGGLEGROUPFINDER")
    gw_microButtonHookToolTip(GwMicroButtonCollectionsMicroButton, COLLECTIONS, "TOGGLECOLLECTIONS")
    gw_microButtonHookToolTip(GwMicroButtonEJMicroButton, ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL")

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

    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnEnter",
        function()
            GwMicroButtonMainMenuMicroButton:SetScript("OnUpdate", gw_latencyInfoToolTip)
            GameTooltip:SetOwner(GwMicroButtonMainMenuMicroButton, "ANCHOR_CURSOR", 0, ANCHOR_BOTTOMLEFT)
        end
    )

    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnLeave",
        function()
            GwMicroButtonMainMenuMicroButton:SetScript("OnUpdate", nil)
            GameTooltip:Hide()
        end
    )

    gw_update_talentMicrobar()
    updateGuildButton()

    gw_create_orderHallBar()

    --Create update notifier
    local updateNotificationIcon = create_micro_button("updateicon")
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
    updateNotificationIcon:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )
    C_ChatInfo.RegisterAddonMessagePrefix("GW2_UI")

    updateNotificationIcon:RegisterEvent("CHAT_MSG_ADDON")
    updateNotificationIcon:RegisterEvent("GROUP_ROSTER_UPDATE")
    updateNotificationIcon:SetScript(
        "OnEvent",
        function(self, event, prefix, message, dist, sender)
            if event == "CHAT_MSG_ADDON" then
                gw_onReciveVersionCheck(self, event, prefix, message, dist, sender)
            else
                gw_sendVersionCheck()
            end
        end
    )

    -- if set to fade micro menu, add fader
    if gwGetSetting("FADE_MICROMENU") then
        microButtonFrame.gw_LastFadeCheck = -1
        microButtonFrame.gw_FadeShowing = true
        microButtonFrame:SetScript("OnUpdate", microMenu_OnUpdate)
    end

    -- hide the default microbar
    MicroButtonAndBagsBar:Hide()
end

gw_sendUpdate_message_cooldown = 0

function gw_sendVersionCheck()
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
    SendAddonMessage("GW2_UI", GW_VERSION_STRING, chatToSend)
end

function gw_onReciveVersionCheck(self, event, prefix, message, dist, sender)
    if prefix ~= "GW2_UI" then
        return
    end

    local version, subversion, hotfix = string.match(message, "GW2_UI v(%d+).(%d+).(%d+)")
    local Currentversion, Currentsubversion, Currenthotfix =
        string.match(GW_VERSION_STRING, "GW2_UI v(%d+).(%d+).(%d+)")

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

function gw_microButtonHookToolTip(frame, text, action)
    if frame == nil then
        return
    end
    frame:SetScript(
        "OnEnter",
        function()
            gw_setToolTipForShow(frame, text, action)
            gw_setToolTipForShow(frame, text, action)
        end
    )
    frame:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )
end

function gw_setToolTipForShow(frame, text, action)
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(gw_getMicroButtonToolTip(text, action), 1, 1, 1)
    GameTooltip:Show()
end

function gw_getMicroButtonToolTip(text, action)
    if (GetBindingKey(action)) then
        return text .. " |cffa6a6a6(" .. GetBindingText(GetBindingKey(action)) .. ")" .. FONT_COLOR_CODE_CLOSE
    else
        return text
    end
end

local gw_addonMemoryArray = {}
function gw_latencyInfoToolTip()
    if gw_latencyToolTipUpdate > GetTime() then
        return
    end
    gw_latencyToolTipUpdate = GetTime() + 0.5

    gw_frameRate = GW.intRound(GetFramerate())
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
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_4"] .. round(down, 2) .. " Kbps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_5"] .. round(up, 2) .. " Kbps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)

    for i = 1, gw_numAddons do
        gw_addonMemory = gw_addonMemory + GetAddOnMemoryUsage(i)
    end

    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_6"] .. round(gw_addonMemory / 1024, 2) .. " MB", 0.8, 0.8, 0.8)

    for i = 1, gw_numAddons do
        if type(gw_addonMemoryArray[i]) ~= "table" then
            gw_addonMemoryArray[i] = {}
        end
        gw_addonMemoryArray[i]["addonIndex"] = i
        gw_addonMemoryArray[i]["addonMemory"] = GetAddOnMemoryUsage(i)
    end

    table.sort(
        gw_addonMemoryArray,
        function(a, b)
            return a["addonMemory"] > b["addonMemory"]
        end
    )

    for k, v in pairs(gw_addonMemoryArray) do
        if v["addonIndex"] ~= 0 and (IsAddOnLoaded(v["addonIndex"]) and v["addonMemory"] ~= 0) then
            gw_addonMemory = round(v["addonMemory"] / 1024, 2)
            if gw_addonMemory ~= "0.00" then
                GameTooltip:AddLine("(" .. gw_addonMemory .. " MB) " .. GetAddOnInfo(v["addonIndex"]), 0.8, 0.8, 0.8)
            end
        end
    end

    GameTooltip:Show()
end

function gw_update_talentMicrobar()
    if GetNumUnspentTalents() > 0 then
        _G["GwMicroButtonTalentMicroButtonTexture"]:Show()
        _G["GwMicroButtonTalentMicroButtonString"]:Show()
        _G["GwMicroButtonTalentMicroButtonString"]:SetText(GetNumUnspentTalents())
    else
        _G["GwMicroButtonTalentMicroButtonTexture"]:Hide()
        _G["GwMicroButtonTalentMicroButtonString"]:Hide()
    end
end

function ToggleGameMenuFrame()
    if GameMenuFrame:IsShown() then
        GameMenuFrame:Hide()
        return
    end
    GameMenuFrame:Show()
end

local function levelingRewards_OnShow(self)
    PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
    self.animationValue = -400
    local name = self:GetName()
    local start = GetTime()
    addToAnimation(
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

function gw_load_levelingrewads()
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

function gw_leveling_display_rewards()
    GW_LEVELING_REWARDS = {}

    GW_LEVELING_REWARDS[1] = {}
    GW_LEVELING_REWARDS[1]["type"] = "TALENT"
    GW_LEVELING_REWARDS[1]["id"] = 0
    GW_LEVELING_REWARDS[1]["level"] = 15

    GW_LEVELING_REWARDS[2] = {}
    GW_LEVELING_REWARDS[2]["type"] = "TALENT"
    GW_LEVELING_REWARDS[2]["id"] = 0
    GW_LEVELING_REWARDS[2]["level"] = 30

    GW_LEVELING_REWARDS[3] = {}
    GW_LEVELING_REWARDS[3]["type"] = "TALENT"
    GW_LEVELING_REWARDS[3]["id"] = 0
    GW_LEVELING_REWARDS[3]["level"] = 45

    GW_LEVELING_REWARDS[4] = {}
    GW_LEVELING_REWARDS[4]["type"] = "TALENT"
    GW_LEVELING_REWARDS[4]["id"] = 0
    GW_LEVELING_REWARDS[4]["level"] = 60

    GW_LEVELING_REWARDS[5] = {}
    GW_LEVELING_REWARDS[5]["type"] = "TALENT"
    GW_LEVELING_REWARDS[5]["id"] = 0
    GW_LEVELING_REWARDS[5]["level"] = 75

    GW_LEVELING_REWARDS[6] = {}
    GW_LEVELING_REWARDS[6]["type"] = "TALENT"
    GW_LEVELING_REWARDS[6]["id"] = 0
    GW_LEVELING_REWARDS[6]["level"] = 90

    GW_LEVELING_REWARDS[7] = {}
    GW_LEVELING_REWARDS[7]["type"] = "TALENT"
    GW_LEVELING_REWARDS[7]["id"] = 0
    GW_LEVELING_REWARDS[7]["level"] = 100

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
                _G["GwLevelingRewardsItem" .. i]:SetScript(
                    "OnLeave",
                    function()
                        GameTooltip:Hide()
                    end
                )
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

function gw_create_orderHallBar()
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

    GwOrderhallBar:SetScript("OnEvent", gw_orderHallBar_OnEvent)
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

    gw_orderHallBar_OnEvent(GwOrderhallBar)
end

function gw_orderHallBar_OnEvent(self, event)
    if OrderHallCommandBar then
        OrderHallCommandBar:SetShown(false)
        OrderHallCommandBar:UnregisterAllEvents()
        OrderHallCommandBar:SetScript(
            "OnShow",
            function(self)
                self:Hide()
            end
        )
    end

    local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
    self:SetShown(inOrderHall)

    local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)

    local currencyName, amount, currencyTexture = GetCurrencyInfo(primaryCurrency)
    amount = BreakUpLargeNumbers(amount)
    self.currency:SetText(amount)

    gw_orderHallBar_Update_Follower(self)
end

function gw_orderHallBar_Update_Follower(self)
    local categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)

    local numCategories = #categoryInfo

    for index, category in ipairs(categoryInfo) do
        local categoryInfoFrame = _G["GwOrderHallFollower" .. index]
        if _G["GwOrderHallFollower" .. index] == nil then
            categoryInfoFrame = gw_orderHallBar_createFollower(self, index)
        end

        categoryInfoFrame.Icon:SetTexture(category.icon)
        categoryInfoFrame.Icon:SetTexCoord(0, 1, 0.25, 0.75)
        categoryInfoFrame.name = category.name
        categoryInfoFrame.description = category.description

        categoryInfoFrame.Count:SetFormattedText(ORDER_HALL_COMMANDBAR_CATEGORY_COUNT, category.count, category.limit)

        categoryInfoFrame:Show()
    end
end

local function gwOrderHallFollower_OnEnter(self)
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
local function gwOrderHallFollower_OnLeave(self)
    GameTooltip:Hide()
end
function gw_orderHallBar_createFollower(self, i)
    local newFrame = CreateFrame("FRAME", "GwOrderHallFollower" .. i, self, "GwOrderHallFollower")
    newFrame.Count:SetFont(UNIT_NAME_FONT, 14)
    newFrame.Count:SetShadowOffset(1, -1)
    newFrame:SetScript("OnEnter", gwOrderHallFollower_OnEnter)
    newFrame:SetScript("OnLeave", gwOrderHallFollower_OnLeave)
    newFrame:SetParent(self)
    newFrame:ClearAllPoints()
    newFrame:SetPoint("LEFT", self.currency, "RIGHT", 100 * (i - 1), 0)
    return newFrame
end
