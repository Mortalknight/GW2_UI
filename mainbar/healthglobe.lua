local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local AddToClique = GW.AddToClique
local Self_Hide = GW.Self_Hide
local TimeParts = GW.TimeParts
local IsIn = GW.IsIn
local MixinHideDuringPetAndOverride = GW.MixinHideDuringPetAndOverride
local GetSetting = GW.GetSetting

local function repair_OnEvent(self, event, ...)
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

local Y_FULL = 47
local Y_EMPTY = -42
local Y_RANGE = Y_FULL - Y_EMPTY
local X_MAX = 20
local X_MIN = -20
local function updateHealthData(self, anims)
    local health = UnitHealth("Player")
    local healthMax = UnitHealthMax("Player")
    local absorb = UnitGetTotalAbsorbs("Player")
    local prediction = UnitGetIncomingHeals("Player") or 0

    local health_def = healthMax - health
    local absorb_over = absorb - health_def
    if absorb_over < 0 then
        absorb_over = 0
    end
    local absorb_under = absorb - absorb_over

    -- determine how much black (anti) area to mask off
    local hp = (health + absorb_under) / healthMax
    local hpy_off = Y_FULL - Y_RANGE * (1 - hp)
    local hpx_off = ((X_MAX - X_MIN) * (math.random())) + X_MIN

    -- determine how much light (absorb) area to mask off
    local aup = health / healthMax
    local auy_off = Y_FULL - Y_RANGE * (1 - aup)

    -- determine how much shield (over absorb) to overlay
    local ap = absorb_over / healthMax
    local apy_off = Y_FULL - 7 - Y_RANGE * (1 - ap)

    -- determine how much predicted health to overlay
    if prediction + health > healthMax then
        prediction = healthMax - health
    end
    local pp = prediction / healthMax
    local ppy_off = Y_FULL - Y_RANGE * (1 - aup)

    -- set the mask positions for health/absorb; prettily if animating,
    -- otherwise just force them
    local anti = self.fill.anti
    local au = self.fill.absorb_under
    if anims then
        -- animate health transition
        local ag = anti.gwAnimGroup
        ag:Stop()
        local _, _, _, _, y = anti:GetPoint()
        anti:ClearAllPoints()
        anti:SetPoint("CENTER", self.fill, "CENTER", hpx_off, y)
        local aa = anti.gwAnim
        aa.gwXoff = hpx_off
        aa.gwYoff = hpy_off
        aa:SetOffset(0, hpy_off - y)
        ag:Play()

        -- animate absorb under transition
        local ag2 = au.gwAnimGroup
        ag2:Stop()
        local _, _, _, _, y2 = au:GetPoint()
        au:ClearAllPoints()
        au:SetPoint("CENTER", self.fill, "CENTER", hpx_off, y2)
        local aa2 = au.gwAnim
        aa2.gwXoff = hpx_off
        aa2.gwYoff = auy_off
        aa2:SetOffset(0, auy_off - y2)
        ag2:Play()
    else
        -- hard-set positions
        anti:ClearAllPoints()
        anti:SetPoint("CENTER", self.fill, "CENTER", hpx_off, hpy_off)
        au:ClearAllPoints()
        au:SetPoint("CENTER", self.fill, "CENTER", hpx_off, auy_off)
    end

    local flash = anti.gwFlashGroup
    if aup < 0.5 and not UnitIsDeadOrGhost("PLAYER") then
        flash:Play()
    else
        flash:Finish()
    end

    -- hard-set over-absorb amount; no animation setup for this yet
    local abov = self.fill.absorb_over
    abov:ClearAllPoints()
    abov:SetPoint("CENTER", self.fill, "CENTER", -15, apy_off)

    -- hard-set heal prediction amount; no animation setup for this yet
    local pred = self.fill.pred
    if prediction > 0 then
        local h = (Y_RANGE * pp) - 2
        pred:ClearAllPoints()
        pred:SetPoint("CENTER", self.fill, "CENTER", -hpx_off, math.min(ppy_off + h, 41))
        pred:Show()
    else
        pred:Hide()
    end

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

    for i, v in ipairs(self.text_h.shadow) do
        v:SetText(hv)
    end

    for i, v in ipairs(self.text_a.shadow) do
        v:SetText(av)
    end

    if absorb < 1 then
        self.text_a:Hide()
    else
        self.text_a:Show()
    end

end
GW.AddForProfiling("healthglobe", "updateHealthData", updateHealthData)

local function selectPvp(self)
    local prevFlag = self.pvp.pvpFlag
    if C_PvP.IsWarModeDesired() or GetPVPDesired("player") or UnitIsPVP("player") or UnitIsPVPFreeForAll("player") then
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
GW.AddForProfiling("healthglobe", "selectPvp", selectPvp)

local function globe_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        MixinHideDuringPetAndOverride(self)
        updateHealthData(self, false)
        selectPvp(self)
    elseif IsIn(event, "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION") then
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
    local pvpdesired = GetPVPDesired("player")
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
                    local _, nMin, nSec, _ = TimeParts(pvpTime)
                    GameTooltip_AddNormalLine(
                        GameTooltip,
                        TIME_REMAINING .. " " .. string.format(TIMER_MINUTES_DISPLAY, nMin, nSec)
                    )
                end
                GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_OFF_VERBOSE, true)
            else
                GameTooltip_AddNormalLine(GameTooltip, PVP_WARMODE_TOGGLE_OFF, true)
            end
        end
    end
    GameTooltip:Show()

    if self.pvp.pvpFlag then
        self.pvp:fadeIn()
    end
end
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

local function LoadHealthGlobe()
    local hg = CreateFrame("Button", nil, UIParent, "GwHealthGlobeTmpl")
    GW.RegisterScaleFrame(hg, 1.1)

    -- position based on XP bar space
    if GetSetting("XPBAR_ENABLED") then
        hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 17)
    else
        hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
    end

    --save settingsvalue for later use
    hg.healthTextSetting = GetSetting("PLAYER_UNIT_HEALTH")
    hg.absorbTextSetting = GetSetting("PLAYER_UNIT_ABSORB")

    -- unit frame stuff
    hg:SetAttribute("*type1", "target")
    hg:SetAttribute("*type2", "togglemenu")
    hg:SetAttribute("unit", "player")
    AddToClique(hg)

    -- setup masking textures
    for i, v in ipairs(hg.fill.masked) do
        v:AddMaskTexture(hg.fill.mask)
    end

    -- setting these values in the XML creates animation glitches
    -- so we do it here instead
    hg.fill.maskb:SetPoint("CENTER", hg.fill, "CENTER", 0, 0)
    hg.fill.maska:SetPoint("CENTER", hg.fill, "CENTER", 0, 0)
    
    hg.fill.absorb_over:AddMaskTexture(hg.fill.maska)
    hg.fill.absorb_under:AddMaskTexture(hg.fill.maskb)
    hg.fill.anti:AddMaskTexture(hg.fill.maskb)
    hg.fill.pred:AddMaskTexture(hg.fill.maskb)

    -- setup fill animations; this marks off the black/empty space
    local aag = hg.fill.anti:CreateAnimationGroup()
    local aa = aag:CreateAnimation("translation")
    aa:SetDuration(0.2)
    aa:SetScript("OnFinished", fill_OnFinish)
    hg.fill.anti.gwAnimGroup = aag
    hg.fill.anti.gwAnim = aa

    -- flashes the black/empty space (for low health warning)
    local afg = hg.fill.anti:CreateAnimationGroup()
    local af = afg:CreateAnimation("alpha")
    af:SetDuration(0.66)
    af:SetFromAlpha(1)
    af:SetToAlpha(0.66)
    afg:SetLooping("BOUNCE")
    hg.fill.anti.gwFlashGroup = afg

    -- marks off the light absorb/shield space
    local aag2 = hg.fill.absorb_under:CreateAnimationGroup()
    local aa2 = aag2:CreateAnimation("translation")
    aa2:SetDuration(0.2)
    aa2:SetScript("OnFinished", fill_OnFinish)
    hg.fill.absorb_under.gwAnimGroup = aag2
    hg.fill.absorb_under.gwAnim = aa2

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

    -- set handlers for health globe and disable default player frame
    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Kill()
    hg:SetScript("OnEvent", globe_OnEvent)
    hg:SetScript("OnEnter", globe_OnEnter)
    hg:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)
    hg:RegisterEvent("PLAYER_ENTERING_WORLD")
    hg:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    hg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    hg:RegisterEvent("RESURRECT_REQUEST")
    hg:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    hg:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    hg:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
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
    if PlayerFrame and TotemFrame then
        GW.Create_Totem_Bar()
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

    pvp.fadeOut = function(self)
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

    return hg
end
GW.LoadHealthGlobe = LoadHealthGlobe
