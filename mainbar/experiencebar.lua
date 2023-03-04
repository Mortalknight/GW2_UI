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

local settings = {
    fadeExpbar = {}
}

local function UpdateSettings(forceFadeIn)
    settings.fadeExpbar.enabled = GW.GetSetting("FADE_EXP_BAR")
    settings.fadeExpbar.forceFadeIn = forceFadeIn
end
GW.UpdateExperiencebarSettings = UpdateSettings

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

local function xpbar_OnEvent(self, event)
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    local maxPlayerLevel = GetMaxPlayerLevel()
    local level = GW.mylevel
    local Nextlevel = math.min(maxPlayerLevel, GW.mylevel + 1)
    local lockLevelTextUnderMaxLevel = level < Nextlevel

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local valPrec = level < Nextlevel and valCurrent / valMax or 0
    local valPrecRepu = 0

    local rested = GetXPExhaustion()
    local showBar1 = level < Nextlevel -- Player
    local showBar2 = select(2, HasPetUI()) and UnitLevel("pet") < level -- Pet
    local showBar3 = false -- Repu

    local restingIconString = IsResting() and " |TInterface/AddOns/GW2_UI/textures/icons/resting-icon:16:16:0:0|t " or ""

    if rested == nil or (rested / valMax) == 0 then
        rested = 0
    else
        rested = math.min((rested / (valMax - valCurrent)), 1)
    end

    local animationSpeed = 15

    self.ExpBar:SetStatusBarColor(0.83, 0.57, 0)
    self.PetBar:SetStatusBarColor(240/255, 240/255, 155/255)

    gw_reputation_vals = nil
    local name, reaction, _, _, _, factionID = GetWatchedFactionInfo()
    if factionID and factionID > 0 then
        local _, _, standingId, bottomValue, topValue, earnedValue = GetFactionInfoByID(factionID)
        local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), GW.mysex)
        local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), GW.mysex)

        if currentRank == nextRank and earnedValue - bottomValue == 0 then
            valPrecRepu = 1
            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. "21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
        else
            valPrecRepu = (earnedValue - bottomValue) / (topValue - bottomValue)
            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue((earnedValue - bottomValue)) .. " / " .. CommaValue((topValue - bottomValue)) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
        end
        self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)

        local nextId = standingId and standingId + 1 or standingId
        if not lockLevelTextUnderMaxLevel then
            level = getglobal("FACTION_STANDING_LABEL" .. standingId)
            Nextlevel = getglobal("FACTION_STANDING_LABEL" .. nextId)
        end

        showBar3 = true
    end

    if showBar2 then
        local currXP, nextXP = GetPetExperience()
        local valPrecPet = currXP / nextXP

        if gw_reputation_vals then
            gw_reputation_vals = gw_reputation_vals .. "\n" .. PET .. " " .. CommaValue(currXP) .. " / " .. CommaValue(nextXP) .. " |cffa6a6a6 (" .. math.floor(valPrecPet * 100) .. "%)|r"
        else
            gw_reputation_vals = PET .. " " .. CommaValue(currXP) .. " / " .. CommaValue(nextXP) .. " |cffa6a6a6 (" .. math.floor(valPrecPet * 100) .. "%)|r"
        end
        self.PetBarCandy:SetValue(valPrecPet)

        AddToAnimation(
            "petBarAnimation",
            self.PetBar.petBarAnimation,
            valPrecPet,
            GetTime(),
            animationSpeed,
            function()
                self.PetBar.Spark:SetWidth(math.max(8, math.min(9, self.PetBar:GetWidth() * animations["petBarAnimation"].progress)))

                self.PetBar:SetValue(animations["petBarAnimation"].progress)
                self.PetBar.Spark:SetPoint("LEFT", self.PetBar:GetWidth() * animations["petBarAnimation"].progress - 8, 0)
            end
        )
        self.PetBar.petBarAnimation = valPrecPet
    end

    local texture = (maxPlayerLevel == GW.mylevel) and "Interface/AddOns/GW2_UI/textures/hud/level-label-azerit" or "Interface/AddOns/GW2_UI/textures/hud/level-label"
    self.NextLevel:SetTextColor(1, 1, 1)
    self.CurrentLevel:SetTextColor(1, 1, 1)
    self.labelRight:SetTexture(texture)
    self.labelLeft:SetTexture(texture)

    local GainBigExp = false
    local FlareBreakPoint = math.max(0.05, 0.15 * (1 - (GW.mylevel / GetMaxPlayerLevel())))
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

    --if showBar1 then
        AddToAnimation(
            "experiencebarAnimation",
            experiencebarAnimation,
            valPrec,
            GetTime(),
            animationSpeed,
            function(step)
                self.ExpBar.Spark:SetWidth(math.max(8, math.min(9,self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress)))

                if not GainBigExp then
                    self.ExpBar:SetValue(animations["experiencebarAnimation"].progress)
                    self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress - 8, 0)

                    local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"].progress) + 90
                    self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)
                end
                self.ExpBar.Rested:SetValue(rested)
                self.ExpBar.Rested:SetPoint("LEFT", self.ExpBar, "LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress, 0)

                if GainBigExp and self.barOverlay.flare.soundCooldown < GetTime() then
                    expSoundCooldown = math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                    self.ExpBar:SetValue(animations["experiencebarAnimation"].progress)
                    self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress - 8, 0)

                    local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"].progress) + 90
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
            function()
                local prog = animations["GwExperienceBarCandy"].progress
                self.ExpBarCandy:SetValue(prog)
            end
        )
    --end

    if showBar3 then
        self.RepuBarCandy:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            self.RepuBar.repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function()
                self.RepuBar.Spark:SetWidth(math.max(8, math.min(9, self.RepuBar:GetWidth() * animations["repuBarAnimation"].progress)))

                self.RepuBar:SetValue(animations["repuBarAnimation"].progress)
                self.RepuBar.Spark:SetPoint("LEFT", self.RepuBar:GetWidth() * animations["repuBarAnimation"].progress - 8, 0)
            end
        )
        self.RepuBar.repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

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
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(2.66)
        self.PetBarCandy:SetHeight(2.66)
        self.PetBar.Spark:SetHeight(2.66)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.PetBar:SetPoint("TOPLEFT", 90, -8)
        self.PetBar:SetPoint("TOPRIGHT", -90, -8)

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

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

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

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(4)
        self.PetBarCandy:SetHeight(4)
        self.PetBar.Spark:SetHeight(4)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.PetBar:SetPoint("TOPLEFT", 90, -4)
        self.PetBar:SetPoint("TOPRIGHT", -90, -4)

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

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

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

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

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

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

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

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(4)
        self.PetBarCandy:SetHeight(4)
        self.PetBar.Spark:SetHeight(4)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.PetBar:SetPoint("TOPLEFT", 90, -8)
        self.PetBar:SetPoint("TOPRIGHT", -90, -8)

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

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(8)
        self.PetBarCandy:SetHeight(8)
        self.PetBar.Spark:SetHeight(8)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.PetBar:SetPoint("TOPLEFT", 90, -4)
        self.PetBar:SetPoint("TOPRIGHT", -90, -4)

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

local function xpbar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local rested = GetXPExhaustion()
    local isRestingString = IsResting() and L[" (Resting)"] or ""

    GameTooltip:AddLine(COMBAT_XP_GAIN .. isRestingString, 1, 1, 1)

    if GW.mylevel < GetMaxPlayerLevel() then
        GameTooltip:AddLine(COMBAT_XP_GAIN .. " " .. CommaValue(valCurrent) .. " / " .. CommaValue(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r", 1, 1, 1)
    end

    if rested ~= nil and rested ~= 0 then
        GameTooltip:AddLine(L["Rested "] .. CommaValue(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r", 1, 1, 1)
    end

    --UIFrameFadeOut(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 0)
    --UIFrameFadeOut(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 0)
    --UIFrameFadeOut(self.PetBar, 0.2, self.PetBar:GetAlpha(), 0)

    if gw_reputation_vals ~= nil then
        GameTooltip:AddLine(gw_reputation_vals, 1, 1, 1)
    end

    GameTooltip:Show()
end
GW.AddForProfiling("hud", "xpbar_OnEnter", xpbar_OnEnter)

local function LoadXPBar(hudArtFrame)
    UpdateSettings(false)
    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    experiencebar.RepuBar.repuBarAnimation = 0
    experiencebar.PetBar.petBarAnimation = 0
    experiencebar.NextLevel:SetFont(UNIT_NAME_FONT, 12)
    experiencebar.CurrentLevel:SetFont(UNIT_NAME_FONT, 12)

    updateBarSize(experiencebar)
    xpbar_OnEvent(experiencebar)

    experiencebar:SetScript("OnEvent", xpbar_OnEvent)

    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_FACTION")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("PLAYER_ENTERING_WORLD")
    experiencebar:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    experiencebar:RegisterEvent("UPDATE_EXHAUSTION")
    experiencebar:RegisterEvent("UNIT_PET_EXPERIENCE")
    experiencebar:RegisterEvent("PET_UI_UPDATE")
    experiencebar:RegisterEvent("PET_BAR_UPDATE")

    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        --UIFrameFadeIn(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 1)
        --UIFrameFadeIn(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 1)
        --UIFrameFadeIn(self.PetBar, 0.2, self.PetBar:GetAlpha(), 1)
    end)

    experiencebar.isFadedOut = false
    local height = experiencebar.labelLeft:GetHeight()
    local slideInOutTime = 0.3
    C_Timer.NewTicker(0.2, function()
        if not settings.fadeExpbar.enabled and not settings.fadeExpbar.forceFadeIn then return end
        if experiencebar:IsMouseOver(20, -20, -20, 20) or settings.fadeExpbar.forceFadeIn then
            settings.fadeExpbar.forceFadeIn = false
            local shouldTriggerAnimation = false
            if GW.animations["EXPBARFADEOUT"] and not GW.animations["EXPBARFADEOUT"].completed then
                shouldTriggerAnimation = true
            end
            GW.StopAnimation("EXPBARFADEOUT")
            GW.StopAnimation("EXPBARFADEOUT2")
            GW.StopAnimation("EXPBARFADEOUT3")
            if (experiencebar.isFadedOut and ((GW.animations["EXPBARFADEIN"] and GW.animations["EXPBARFADEIN"].completed) or GW.animations["EXPBARFADEIN"] == nil)) or shouldTriggerAnimation then
                local posY = select(5, experiencebar:GetPoint())
                local posYBorder = select(5, hudArtFrame.edgeTintBottomCornerLeft:GetPoint())
                local posYHudBackground = select(5, hudArtFrame.actionBarHud:GetPoint())
                local startYPoint = shouldTriggerAnimation and posY * -1 or height
                local startYPointBorder = shouldTriggerAnimation and posYBorder or 0
                local startYPointHudBackground = shouldTriggerAnimation and posYHudBackground or 0
                local hudBackgroundHight = hudArtFrame.actionBarHud:GetHeight()
                GW.AddToAnimation(
                    "EXPBARFADEIN",
                    0,
                    1,
                    GetTime(),
                    slideInOutTime / height * (shouldTriggerAnimation and startYPoint or height),
                    function(p)
                        local newY = lerp(-startYPoint, 0, p)
                        experiencebar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, newY)
                        experiencebar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, newY)
                    end,
                    1,
                    function()
                        experiencebar.isFadedOut = false
                    end
                )
                GW.AddToAnimation(
                    "EXPBARFADEIN2",
                    0,
                    1,
                    GetTime(),
                    slideInOutTime / height * (shouldTriggerAnimation and 14 - startYPointBorder or height + 14),
                    function(p)
                        -- set border texture
                        local newY = lerp(startYPointBorder, 14, p)
                        hudArtFrame.edgeTintBottomCornerLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, newY)
                        hudArtFrame.edgeTintBottomCornerRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, newY)
                    end,
                    1,
                    function()
                        experiencebar.isFadedOut = false
                    end
                )
                -- set hud background texture
                GW.AddToAnimation(
                    "EXPBARFADEIN3",
                    0,
                    1,
                    GetTime(),
                    slideInOutTime / height * (shouldTriggerAnimation and 14 - startYPointBorder or height + 14),
                    function(p)
                        local newHeight = lerp(startYPointHudBackground, (hudBackgroundHight - 256), p)
                        local newY = lerp(startYPointHudBackground, 14, p)
                        hudArtFrame.actionBarHud:SetHeight(hudBackgroundHight - newHeight)
                        for _, f in ipairs(hudArtFrame.actionBarHud.HUDBG) do
                            f:SetHeight(hudBackgroundHight - newHeight)
                        end
                        hudArtFrame.actionBarHud:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, newY)
                    end,
                    1,
                    function()
                        experiencebar.isFadedOut = false
                    end
                )
            end
        else
            local shouldTriggerAnimation = false
            if GW.animations["EXPBARFADEIN"] and not GW.animations["EXPBARFADEIN"].completed then
                shouldTriggerAnimation = true
            end
            GW.StopAnimation("EXPBARFADEIN")
            GW.StopAnimation("EXPBARFADEIN2")
            GW.StopAnimation("EXPBARFADEIN3")
            if (not experiencebar.isFadedOut and ((GW.animations["EXPBARFADEOUT"] and GW.animations["EXPBARFADEOUT"].completed) or GW.animations["EXPBARFADEOUT"] == nil)) or shouldTriggerAnimation then
                local posY = select(5, experiencebar:GetPoint())
                local posYBorder = select(5, hudArtFrame.edgeTintBottomCornerLeft:GetPoint())
                local posYHudBackground = select(5, hudArtFrame.actionBarHud:GetPoint())
                local startYPoint = shouldTriggerAnimation and posY * -1 or 0
                local startYPointBorder = shouldTriggerAnimation and posYBorder or 0
                local startYPointHudBackground = shouldTriggerAnimation and posYHudBackground or 0
                local hudBackgroundHight = hudArtFrame.actionBarHud:GetHeight()
                GW.AddToAnimation(
                    "EXPBARFADEOUT",
                    0,
                    1,
                    GetTime(),
                    slideInOutTime / height * (shouldTriggerAnimation and height - startYPoint or height),
                    function(p)
                        local newY = lerp(startYPoint, height, p)
                        experiencebar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, -newY)
                        experiencebar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, -newY)
                    end,
                    1,
                    function()
                        experiencebar.isFadedOut = true
                    end
                )
                GW.AddToAnimation(
                    "EXPBARFADEOUT2",
                    0,
                    1,
                    GetTime(),
                    slideInOutTime / height * (shouldTriggerAnimation and 14 - startYPointBorder or 14),
                    function(p)
                        -- set border texture
                        local newY = lerp(startYPointBorder, 14, p)
                        hudArtFrame.edgeTintBottomCornerLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, (14 - newY))
                        hudArtFrame.edgeTintBottomCornerRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, (14 - newY))
                    end,
                    1,
                    function()
                        experiencebar.isFadedOut = true
                    end
                )
                GW.AddToAnimation(
                    "EXPBARFADEOUT3",
                    0,
                    1,
                    GetTime(),
                    slideInOutTime / height * (shouldTriggerAnimation and 14 - startYPointBorder or 14),
                    function(p)
                        local newHeight = lerp(startYPointHudBackground, (286 - hudBackgroundHight), p)
                        local newY = lerp(startYPointHudBackground, 14, p)
                        -- set hud background texture
                        hudArtFrame.actionBarHud:SetHeight(math.min(hudBackgroundHight + newHeight, 286))
                        for _, f in ipairs(hudArtFrame.actionBarHud.HUDBG) do
                            f:SetHeight(math.min(hudBackgroundHight + newHeight, 286))
                        end
                        hudArtFrame.actionBarHud:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, (14 - newY))
                    end,
                    1,
                    function()
                        experiencebar.isFadedOut = true
                    end
                )
            end
        end
    end)
end
GW.LoadXPBar = LoadXPBar