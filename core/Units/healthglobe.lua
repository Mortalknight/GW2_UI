local _, GW = ...
local IsIn = GW.IsIn
local MixinHideDuringPetAndOverride = GW.MixinHideDuringPetAndOverride

GwHealthglobeMixin = {}

function GwHealthglobeMixin:FlashAnimation(delta, t)
    t = (t or 0) + delta * max(1, 4 * (1 - (self.healthPercentage / 0.65)))
    local c = 0.4 * math.abs(math.sin(t))
    self.border.normal:SetVertexColor(c, c, c, 1)

    if self.healthPercentage > 0.65 and c < 0.2 then
        self:SetScript("OnUpdate", nil)
        self.border.normal:SetVertexColor(0, 0, 0, 1)
    end
end

function GwHealthglobeMixin:UpdateHealthData()
    local health, healthMax = UnitHealth("player"), UnitHealthMax("player")
    local absorb = UnitGetTotalAbsorbs and UnitGetTotalAbsorbs("player") or 0
    local prediction = UnitGetIncomingHeals("player") or 0
    local healAbsorb = UnitGetTotalHealAbsorbs and UnitGetTotalHealAbsorbs("player") or 0
    local healthPercentage = health / healthMax

    self.healthPercentage = healthPercentage
    self.health:SetFillAmount(healthPercentage - 0.035)
    self.candy:SetFillAmount(healthPercentage)

    local absorbPercentage = absorb > 0 and absorb / healthMax or 0
    local absorbOverlayPercentage = absorb > 0 and (absorbPercentage - (1 - healthPercentage)) or 0
    local predictionPercentage = prediction > 0 and (prediction / healthMax) or 0
    local healAbsorbPercentage = healAbsorb > 0 and (min(healthMax, healAbsorb / healthMax)) or 0

    self.healPrediction:SetFillAmount(healthPercentage + predictionPercentage)
    self.absorbbg:SetFillAmount(healthPercentage + absorbPercentage)
    self.absorbOverlay:SetFillAmount(absorbOverlayPercentage)
    self.antiHeal:SetFillAmount(healAbsorbPercentage)

    local function formatValue(value)
        return GW.settings.PLAYER_UNIT_HEALTH_SHORT_VALUES and GW.ShortValue(value) or GW.GetLocalizedNumber(value)
    end

    local hv = GW.settings.PLAYER_UNIT_HEALTH == "PREC" and (GW.GetLocalizedNumber(healthPercentage * 100, 0) .. "%")
        or GW.settings.PLAYER_UNIT_HEALTH == "VALUE" and formatValue(health)
        or GW.settings.PLAYER_UNIT_HEALTH == "BOTH" and formatValue(health) .. "\n" .. GW.GetLocalizedNumber(healthPercentage * 100, 0) .. "%"
        or ""

    local av = GW.settings.PLAYER_UNIT_ABSORB == "PREC" and (GW.GetLocalizedNumber(absorbPercentage * 100, 0) .. "%")
        or GW.settings.PLAYER_UNIT_ABSORB == "VALUE" and formatValue(absorb)
        or GW.settings.PLAYER_UNIT_ABSORB == "BOTH" and  formatValue(absorb) .. "\n" .. GW.GetLocalizedNumber(absorbPercentage * 100, 0) .. "%"
        or ""

    self.text_h.value:SetText(hv)
    self.text_a.value:SetText(av)

    for _, v in ipairs(self.text_h.shadow) do v:SetText(hv) end
    for _, v in ipairs(self.text_a.shadow) do v:SetText(av) end

    self.text_a:SetShown(absorb > 0)

    if healthPercentage < 0.65 and not self:GetScript("OnUpdate") then
        self:SetScript("OnUpdate", self.FlashAnimation)
    end
end

function GwHealthglobeMixin:OnEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then
        MixinHideDuringPetAndOverride(self)
        self:UpdateHealthData()
        self:SelectPvp()
    elseif IsIn(event, "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION") then
        self:UpdateHealthData()
    elseif IsIn(event, "WAR_MODE_STATUS_UPDATE", "PLAYER_FLAGS_CHANGED", "UNIT_FACTION") then
        self:SelectPvp()
    elseif event == "RESURRECT_REQUEST" then
        PlaySound(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER, "Master")
    end
end

function GwHealthglobeMixin:OnEnter()
    local warmode = GW.Retail and C_PvP.IsWarModeDesired()
    local pvpdesired = GetPVPDesired()
    local pvpactive = UnitIsPVP("player") or UnitIsPVPFreeForAll("player")

    GameTooltip_SetDefaultAnchor(GameTooltip, self)
    GameTooltip:SetUnit("player")
    GameTooltip:AddLine(" ")
    if warmode or pvpdesired or pvpactive then
        GameTooltip_AddColoredLine(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_ENABLED, HIGHLIGHT_FONT_COLOR)
    else
        GameTooltip_AddColoredLine(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_DISABLED, HIGHLIGHT_FONT_COLOR)
    end
    if warmode then
        GameTooltip_AddNormalLine(GameTooltip, PVP_WARMODE_TOGGLE_ON, true)
    else
        if pvpdesired then
            GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_ON_VERBOSE, true)
        else
            if pvpactive then
                local pvpTime = GetPVPTimer()
                if pvpTime > 0 and pvpTime < 301000 then
                    local _, nMin, nSec = GW.TimeParts(pvpTime)
                    GameTooltip_AddNormalLine(GameTooltip, TIME_REMAINING .. " " .. string.format(TIMER_MINUTES_DISPLAY, nMin, nSec))
                end
                GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_OFF_VERBOSE, true)
            else
                GameTooltip_AddNormalLine(GameTooltip, PVP_WARMODE_TOGGLE_OFF, true)
            end
        end
    end

    if IsInRaid() then
        local groupNumber
        for i = 1, GetNumGroupMembers() do
            if UnitIsUnit("raid" .. i, "player") then
                groupNumber = select(3, GetRaidRosterInfo(i))
            end
        end
        if groupNumber then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(format(QUEST_SUGGESTED_GROUP_NUM_TAG, groupNumber), 1, 1, 1)
        end
    end
    GameTooltip:Show()

    if GW.settings.PLAYER_SHOW_PVP_INDICATOR and self.pvp.pvpFlag then
        self.pvp:fadeIn()
    end
end

GwHealthglobeRepairMixin = {}

function GwHealthglobeRepairMixin:OnEvent(event)
    if event ~= "PLAYER_ENTERING_WORLD" and not GW.inWorld then
        return
    end
    local needRepair = false
    local gearBroken = false
    for i = 1, 23 do
        local current, maximum = GetInventoryItemDurability(i)
        if current and maximum then
            local dur = current / maximum
            if dur == 0 then
                gearBroken = true
                needRepair = true
                break -- Keine weitere Überprüfung nötig, wenn ein Item komplett kaputt ist
            elseif dur < 0.5 then
                needRepair = true
            end
        end
    end
    self.gearBroken = gearBroken

    self.gearBroken = gearBroken
    self.icon:SetTexCoord(0, 1, gearBroken and 0.5 or 0, gearBroken and 1 or 0.5)
    self:SetShown(needRepair)
end

function GwHealthglobeRepairMixin:RepairOnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    if self.gearBroken then
        GameTooltip:AddLine(TUTORIAL_TITLE37, 1, 1, 1)
    else
        GameTooltip:AddLine(TUTORIAL_TITLE36, 1, 1, 1)
    end
    GameTooltip:Show()
end

function GwHealthglobeMixin:ToggleSettings()
    self:UpdateHealthData()
end

local function LoadHealthGlobe()
    local hg = CreateFrame("Button", "GW2_PlayerFrame", UIParent, GW.Retail and "GwHealthGlobePingableTmpl" or "GwHealthGlobeTmpl")

    hg.absorbOverlay = hg.healPrediction.absorbbg.candy.health.antiHeal.absorbOverlay
    hg.antiHeal = hg.healPrediction.absorbbg.candy.health.antiHeal
    hg.health = hg.healPrediction.absorbbg.candy.health
    hg.candy = hg.healPrediction.absorbbg.candy
    hg.absorbbg = hg.healPrediction.absorbbg

    hg.text_h = hg.absorbOverlay.text_h
    hg.text_a = hg.absorbOverlay.text_a
    hg.repair = hg.absorbOverlay.repair

    for _, bar in pairs({hg.absorbOverlay, hg.antiHeal, hg.health, hg.candy, hg.absorbbg, hg.healPrediction}) do
        GW.AddStatusbarAnimation(bar, true)
        bar:SetOrientation("VERTICAL")
    end

    hg.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    hg.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    -- position based on XP bar space and make it movable if your actionbars are off
    if GW.settings.ACTIONBARS_ENABLED and GW.settings.BAR_LAYOUT_ENABLED and not GW.IsIncompatibleAddonLoadedOrOverride("Actionbars", true) then
        if GW.settings.XPBAR_ENABLED then
            hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 17)
        else
            hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
        end
    else
        GW.RegisterMovableFrame(hg, GW.L["Health Globe"], "HealthGlobe_pos", ALL .. ",Unitframe", nil, {"default"}, false)
        hg:SetPoint("TOPLEFT", hg.gwMover)
        if not GW.settings.XPBAR_ENABLED and not hg.isMoved then
            local framePoint = GW.settings.HealthGlobe_pos
            hg.gwMover:ClearAllPoints()
            hg.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs, 0)
        end
    end
    GW.RegisterScaleFrame(hg, 1.1)

    -- unit frame stuff
    hg:SetAttribute("*type1", "target")
    hg:SetAttribute("*type2", "togglemenu")
    hg:SetAttribute("unit", "player")
    hg:EnableMouse(true)
    hg:RegisterForClicks("AnyDown")
    hg.unit = "player"

    GW.AddToClique(hg)

    -- set text/font stuff
    if GW.settings.PLAYER_UNIT_ABSORB == "BOTH" then
        hg.text_a:ClearAllPoints()
        hg.text_a:SetPoint("CENTER", hg, "CENTER", 0, 25)

        hg.text_a.value:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
        hg.text_a.value:SetShadowColor(1, 1, 1, 0)

        for i, v in ipairs(hg.text_a.shadow) do
            v:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
            v:SetShadowColor(1, 1, 1, 0)
            v:SetTextColor(0, 0, 0, 1 / i)
        end
    else
        hg.text_a.value:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        hg.text_a.value:SetShadowColor(1, 1, 1, 0)

        for i, v in ipairs(hg.text_a.shadow) do
            v:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
            v:SetShadowColor(1, 1, 1, 0)
            v:SetTextColor(0, 0, 0, 1 / i)
        end
    end
    hg.text_h.value:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER, nil, -1)
    hg.text_h.value:SetShadowColor(1, 1, 1, 0)

    for i, v in ipairs(hg.text_h.shadow) do
        v:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER, nil, -1)
        v:SetShadowColor(1, 1, 1, 0)
        v:SetTextColor(0, 0, 0, 1 / i)
    end

    hg:SetScript("OnEvent", hg.OnEvent)
    hg:SetScript("OnEnter", hg.OnEnter)
    hg:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if GW.settings.PLAYER_SHOW_PVP_INDICATOR and self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)
    hg:RegisterEvent("PLAYER_ENTERING_WORLD")
    hg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    hg:RegisterEvent("RESURRECT_REQUEST")
    hg:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    hg:RegisterUnitEvent("UNIT_HEALTH", "player")
    hg:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    hg:RegisterUnitEvent("UNIT_FACTION", "player")

    if GW.Retail then
        hg:RegisterEvent("WAR_MODE_STATUS_UPDATE")
        hg:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    elseif GW.Classic then
       hg:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    end

    -- setup hooks for the repair icon (and disable default repair frame)
    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript("OnShow", GW.Self_Hide)
    DurabilityFrame:Hide()

    local rep = hg.repair
    rep:SetScript("OnEvent", rep.OnEvent)
    rep:SetScript("OnEnter", rep.OnEnter)
    rep:SetScript("OnLeave", GameTooltip_Hide)
    rep:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    rep:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- grab the TotemFramebuttons to our own Totem Frame
    if GW.Retail then
        GW.CreateTotemBar()
    end

    -- setup anim to flash the PvP marker
    local pvp = hg.pvp
    local pagIn = pvp:CreateAnimationGroup("fadeIn")
    local pagOut = pvp:CreateAnimationGroup("fadeOut")
    local fadeOut = pagOut:CreateAnimation("Alpha")
    local fadeIn = pagIn:CreateAnimation("Alpha")

    pagOut:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(0.33)
    end)

    fadeOut:SetFromAlpha(1.0)
    fadeOut:SetToAlpha(0.33)
    fadeOut:SetDuration(0.1)
    fadeIn:SetFromAlpha(0.33)
    fadeIn:SetToAlpha(1.0)
    fadeIn:SetDuration(0.1)

    pvp.fadeOut = function()
        pagIn:Stop()
        pagOut:Stop()
        pagOut:Play()
    end
    pvp.fadeIn = function(self)
        self:SetAlpha(1)
        pagIn:Stop()
        pagOut:Stop()
        pagIn:Play()
    end

    if not GW.settings.PLAYER_SHOW_PVP_INDICATOR then pvp:Hide() end

    return hg
end
GW.LoadHealthGlobe = LoadHealthGlobe
