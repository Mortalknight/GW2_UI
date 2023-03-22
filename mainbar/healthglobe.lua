local _, GW = ...
local CommaValue = GW.CommaValue
local AddToClique = GW.AddToClique
local Self_Hide = GW.Self_Hide
local TimeParts = GW.TimeParts
local IsIn = GW.IsIn
local MixinHideDuringPetAndOverride = GW.MixinHideDuringPetAndOverride
local GetSetting = GW.GetSetting


local function flashAnimation(self,delta)
  if t==nil then t=0 end
  local speed  =  max(0.4,4 * (1 - (self.healthPrecentage / 0.65)))
  t = t + (delta) * speed
  local c =  0.4*math.abs(math.sin(t))
  self.border.normal:SetVertexColor(c,c,c,1)

  if self.healthPrecentage>0.65 and c<0.2 then
    self:SetScript("OnUpdate",nil);
    self.border.normal:SetVertexColor(0,0,0,1)
  end
end

local function repair_OnEvent(self, event)
    if event ~= "PLAYER_ENTERING_WORLD" and not GW.inWorld then
        return
    end
    local needRepair = false
    local gearBroken = false
    for i = 1, 23 do
        local current, maximum = GetInventoryItemDurability(i)
        if current ~= nil then
            local dur = current / maximum
            if dur < 0.5 then
                needRepair = true
            end
            if dur == 0 then
                gearBroken = true
            end
        end
    end
    self.gearBroken = gearBroken

    if gearBroken then
        self.icon:SetTexCoord(0, 1, 0.5, 1)
    else
        self.icon:SetTexCoord(0, 1, 0, 0.5)
    end

    if needRepair then
        self:Show()
    else
        self:Hide()
    end
end
GW.AddForProfiling("healthglobe", "repair_OnEvent", repair_OnEvent)


local function updateHealthData(self, anims)
    local health = UnitHealth("Player")
    local healthMax = UnitHealthMax("Player")
    local absorb = UnitGetTotalAbsorbs("Player")
    local prediction = UnitGetIncomingHeals("Player") or 0
    local healAbsorb =  UnitGetTotalHealAbsorbs("Player")
    local absorbPrecentage = 0
    local absorbAmount = 0
    local absorbAmount2 = 0
    local predictionPrecentage = 0
    local healAbsorbPrecentage = 0

    local healthPrecentage = health/healthMax

    self.healthPrecentage = healthPrecentage -- used for animation
    self.health:SetFillAmount(healthPrecentage - 0.035)
    self.candy:SetFillAmount(healthPrecentage)



    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
        absorbAmount = healthPrecentage + absorbPrecentage
        absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)
    end

    if prediction > 0 and healthMax > 0 then
        predictionPrecentage = prediction / healthMax
    end
    if healAbsorb > 0 and healthMax > 0 then
        healAbsorbPrecentage = min(healthMax,healAbsorb / healthMax)
    end
    self.healPrediction:SetFillAmount(healthPrecentage + predictionPrecentage)


    self.absorbbg:SetFillAmount(absorbAmount)
    self.absorbOverlay:SetFillAmount(absorbAmount2)
    self.antiHeal:SetFillAmount(healAbsorbPrecentage)
    -- hard-set the text values for health/absorb based on the user settings (%, value or both)
    local hv = ""
    local av = ""

    if self.healthTextSetting == "PREC" then
        hv = CommaValue(health / healthMax * 100) .. "%"
    elseif self.healthTextSetting == "VALUE" then
        hv = CommaValue(health)
    elseif self.healthTextSetting == "BOTH" then
        hv = CommaValue(health) .. "\n" .. CommaValue(health / healthMax * 100) .. "%"
    end

    if self.absorbTextSetting == "PREC" then
        av = CommaValue(absorb / healthMax * 100) .. "%"
    elseif self.absorbTextSetting == "VALUE" then
        av = CommaValue(absorb)
    elseif self.absorbTextSetting == "BOTH" then
        av = CommaValue(absorb) .. "\n" .. CommaValue(absorb / healthMax * 100) .. "%"
    end

    self.text_h.value:SetText(hv)
    self.text_a.value:SetText(av)

    for _, v in ipairs(self.text_h.shadow) do
        v:SetText(hv)
    end

    for _, v in ipairs(self.text_a.shadow) do
        v:SetText(av)
    end

    if absorb < 1 then
        self.text_a:Hide()
    else
        self.text_a:Show()
    end

    if healthPrecentage<0.65 and self:GetScript("OnUpdate")==nil then
      self:SetScript("OnUpdate",flashAnimation)
    end

end
GW.AddForProfiling("healthglobe", "updateHealthData", updateHealthData)

local function selectPvp(self)
    local prevFlag = self.pvp.pvpFlag
    if GetSetting("PLAYER_SHOW_PVP_INDICATOR") and (C_PvP.IsWarModeDesired() or GetPVPDesired() or UnitIsPVP("player") or UnitIsPVPFreeForAll("player")) then
        self.pvp.pvpFlag = true
        if prevFlag ~= true then
            if GW.myfaction == "Horde" then
                self.pvp.ally:Hide()
                self.pvp.horde:Show()
            else
                self.pvp.ally:Show()
                self.pvp.horde:Hide()
            end
        end
    else
        self.pvp.pvpFlag = false
        self.pvp.ally:Hide()
        self.pvp.horde:Hide()
    end
end
GW.PlayerSelectPvp = selectPvp
GW.AddForProfiling("healthglobe", "selectPvp", selectPvp)

local function globe_OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        MixinHideDuringPetAndOverride(self)
        updateHealthData(self, false)
        selectPvp(self)
    elseif IsIn(event, "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION") then
        updateHealthData(self, true)
    elseif IsIn(event, "WAR_MODE_STATUS_UPDATE", "PLAYER_FLAGS_CHANGED", "UNIT_FACTION") then
        selectPvp(self)
    elseif event == "RESURRECT_REQUEST" then
        PlaySound(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER, "Master")
    end
end
GW.AddForProfiling("healthglobe", "globe_OnEvent", globe_OnEvent)

local function globe_OnEnter(self)
    local warmode = C_PvP.IsWarModeDesired()
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
                    local _, nMin, nSec = TimeParts(pvpTime)
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

    if GetSetting("PLAYER_SHOW_PVP_INDICATOR") and self.pvp.pvpFlag then
        self.pvp:fadeIn()
    end
end
GW.PlayerFrame_OnEnter = globe_OnEnter
GW.AddForProfiling("healthglobe", "globe_OnEnter", globe_OnEnter)

local function fill_OnFinish(self)
    local f = self:GetParent():GetParent()
    f:ClearAllPoints()
    f:SetPoint("CENTER", f:GetParent(), "CENTER", self.gwXoff, self.gwYoff)
end
GW.AddForProfiling("healthglobe", "fill_OnFinish", fill_OnFinish)

local function repair_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    if self.gearBroken then
        GameTooltip:AddLine(TUTORIAL_TITLE37, 1, 1, 1)
    else
        GameTooltip:AddLine(TUTORIAL_TITLE36, 1, 1, 1)
    end
    GameTooltip:Show()
end
GW.AddForProfiling("healthglobe", "repair_OnEnter", repair_OnEnter)

local function ToggleHealthglobeSettings()
    if not GW2_PlayerFrame then return end
    GW2_PlayerFrame.healthTextSetting = GetSetting("PLAYER_UNIT_HEALTH")
    GW2_PlayerFrame.absorbTextSetting = GetSetting("PLAYER_UNIT_ABSORB")

    updateHealthData(GW2_PlayerFrame, false)
end
GW.ToggleHealthglobeSettings = ToggleHealthglobeSettings


local function LoadHealthGlobe()

    local hg = CreateFrame("Button", "GW2_PlayerFrame", UIParent, "GwHealthGlobeTmpl")

    hg.absorbOverlay = hg.healPrediction.absorbbg.candy.health.antiHeal.absorbOverlay
    hg.antiHeal = hg.healPrediction.absorbbg.candy.health.antiHeal
    hg.health = hg.healPrediction.absorbbg.candy.health
    hg.candy = hg.healPrediction.absorbbg.candy
    hg.absorbbg = hg.healPrediction.absorbbg

    hg.text_h = hg.absorbOverlay.text_h
    hg.text_a = hg.absorbOverlay.text_a
    hg.repair = hg.absorbOverlay.repair

    GW.hookStatusbarBehaviour(hg.absorbOverlay,true)
    GW.hookStatusbarBehaviour(hg.antiHeal,true)
    GW.hookStatusbarBehaviour(hg.health,true)
    GW.hookStatusbarBehaviour(hg.candy,true)
    GW.hookStatusbarBehaviour(hg.absorbbg,true)
    GW.hookStatusbarBehaviour(hg.healPrediction,true)

    hg.absorbOverlay:SetStatusBarColor(1,1,1,0.66)
    hg.healPrediction:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    hg.candy:SetOrientation("VERTICAL")
    hg.absorbOverlay:SetOrientation("VERTICAL")
    hg.antiHeal:SetOrientation("VERTICAL")
    hg.candy:SetOrientation("VERTICAL")
    hg.healPrediction:SetOrientation("VERTICAL")
    hg.health:SetOrientation("VERTICAL")
    hg.absorbbg:SetOrientation("VERTICAL")



    GW.RegisterScaleFrame(hg, 1.1)

    -- position based on XP bar space and make it movable if your actionbars are off
    if GetSetting("ACTIONBARS_ENABLED") and not GW.IsIncompatibleAddonLoadedOrOverride("Actionbars", true) then
        if GetSetting("XPBAR_ENABLED") then
            hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 17)
        else
            hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
        end
    else
        GW.RegisterMovableFrame(hg, GW.L["Health Globe"], "HealthGlobe_pos", ALL .. ",Unitframe", nil, {"default"}, false)
        hg:SetPoint("TOPLEFT", hg.gwMover)
        if not GetSetting("XPBAR_ENABLED") and not hg.isMoved then
            local framePoint = GetSetting("HealthGlobe_pos")
            hg.gwMover:ClearAllPoints()
            hg.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs, 0)
        end
    end

    -- unit frame stuff
    hg:SetAttribute("*type1", "target")
    hg:SetAttribute("*type2", "togglemenu")
    hg:SetAttribute("unit", "player")
    hg:EnableMouse(true)
    hg:RegisterForClicks("AnyDown")

    AddToClique(hg)






    -- set text/font stuff
    hg.hSize = 14
    if hg.absorbTextSetting == "BOTH" then
        hg.aSize = 12
        hg.text_a:ClearAllPoints()
        hg.text_a:SetPoint("CENTER", hg, "CENTER", 0, 25)
    else
        hg.aSize = 14
    end

    hg.text_h.value:SetFont(DAMAGE_TEXT_FONT, hg.hSize)
    hg.text_h.value:SetShadowColor(1, 1, 1, 0)

    hg.text_a.value:SetFont(DAMAGE_TEXT_FONT, hg.aSize)
    hg.text_a.value:SetShadowColor(1, 1, 1, 0)

    for i, v in ipairs(hg.text_h.shadow) do
        v:SetFont(DAMAGE_TEXT_FONT, hg.hSize)
        v:SetShadowColor(1, 1, 1, 0)
        v:SetTextColor(0, 0, 0, 1 / i)
    end

    for i, v in ipairs(hg.text_a.shadow) do
        v:SetFont(DAMAGE_TEXT_FONT, hg.aSize)
        v:SetShadowColor(1, 1, 1, 0)
        v:SetTextColor(0, 0, 0, 1 / i)
    end

    hg:SetScript("OnEvent", globe_OnEvent)
    hg:SetScript("OnEnter", globe_OnEnter)
    hg:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if GetSetting("PLAYER_SHOW_PVP_INDICATOR") and self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)
    hg:RegisterEvent("PLAYER_ENTERING_WORLD")
    hg:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    hg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    hg:RegisterEvent("RESURRECT_REQUEST")
    hg:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    hg:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    hg:RegisterUnitEvent("UNIT_HEALTH", "player")
    hg:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    hg:RegisterUnitEvent("UNIT_FACTION", "player")

    -- setup hooks for the repair icon (and disable default repair frame)
    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript("OnShow", Self_Hide)
    DurabilityFrame:Hide()

    local rep = hg.repair
    rep:SetScript("OnEvent", repair_OnEvent)
    rep:SetScript("OnEnter", repair_OnEnter)
    rep:SetScript("OnLeave", GameTooltip_Hide)
    rep:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    rep:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- grab the TotemFramebuttons to our own Totem Frame
    GW.Create_Totem_Bar()

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

    if not GetSetting("PLAYER_SHOW_PVP_INDICATOR") then pvp:Hide() end

    --save settingsvalue for later use
    ToggleHealthglobeSettings()

    return hg
end
GW.LoadHealthGlobe = LoadHealthGlobe
