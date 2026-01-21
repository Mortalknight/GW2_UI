local _, GW = ...
local Debug = GW.Debug
local MixinHideDuringPetAndOverride = GW.MixinHideDuringPetAndOverride
local FrameFlash = GW.FrameFlash
local lerp = GW.lerp

-- these strings will be parsed by SecureCmdOptionParse
-- https://wow.gamepedia.com/Secure_command_options
local DODGEBAR_SPELLS = {} -- spell ID used to generate the bar information/tooltip
local DODGEBAR_SPELLS_ATTR = {} -- spell ID used to cast ability on button click, if different than above
if GW.Retail then
    DODGEBAR_SPELLS.WARRIOR = "100" -- Charge
    DODGEBAR_SPELLS.PALADIN = "190784" -- Divine Steed
    DODGEBAR_SPELLS.HUNTER = "781" -- Disengage
    DODGEBAR_SPELLS.ROGUE = "2983" -- Sprint
    DODGEBAR_SPELLS.PRIEST = "[spec:1/2,known:121536] 121536; 73325" -- Angelic Feather if talented, else Leap of Faith
    DODGEBAR_SPELLS.DEATHKNIGHT = "444347,48265" -- Death's Advance
    DODGEBAR_SPELLS.SHAMAN = "2645" -- Spirit Walk if Enhance
    DODGEBAR_SPELLS.MAGE = "[known:212653] 212653; 1953" -- Shimmer if talented, else Blink
    DODGEBAR_SPELLS_ATTR.MAGE = "1953" -- use Blink instead of Shimmer for the button attr
    DODGEBAR_SPELLS.WARLOCK = "48020" -- Demonic Circle: Teleport; TODO disable when Demonic Circle buff not active
    DODGEBAR_SPELLS.MONK = "[known:115008]115008; 109132" -- Chi Torpedo if talented, else Roll
    DODGEBAR_SPELLS_ATTR.MONK = "109132" -- use Roll instead of Chi Torpedo for the button attr
    DODGEBAR_SPELLS.DRUID = "[known:252216] 252216; [known:16979,form:1] 16979; [known:49376,form:2] 49376; [known:102416,form:3,swimming] 102416; [known:102417,form:3] 102417; [known:102383,form:4] 102383; [known:102401] 102401; 1850" -- Tiger Dash if talented, else Wild Charge if talented (with all its sub-details for different forms), else Dash
    DODGEBAR_SPELLS_ATTR.DRUID = "[known:102401] 102401; 1850" -- use Dash (instead of Tiger Dash) and Wild Charge baseline(instead of form-specific talents) for the button attr
    DODGEBAR_SPELLS.DEMONHUNTER = "[spec:1] 195072; [spec:2] 189110; 344865" -- Fel Rush (Havoc) or Infernal Strike (Vengeance)
    DODGEBAR_SPELLS_ATTR.DEMONHUNTER = "[spec:1] 343017,320416,344865; [spec:2] 189110; 344865" -- Fel Rush (Havoc) or Infernal Strike (Vengeance)
    DODGEBAR_SPELLS.EVOKER = "358267"
elseif GW.Mists then
    DODGEBAR_SPELLS.ROGUE = "2983" -- Sprint
    DODGEBAR_SPELLS.WARRIOR = "100" -- Charge
    DODGEBAR_SPELLS.HUNTER = "781" -- Disengage
    DODGEBAR_SPELLS.MAGE = "1953" -- Shimmer if talented, else Blink
    DODGEBAR_SPELLS.MONK = "[known:115173] 121827; 109132"-- Chi Torpedo if talented, else Roll
    DODGEBAR_SPELLS_ATTR.MONK = "109132"
    DODGEBAR_SPELLS.WARLOCK = "48020" -- Demonic Circle: Teleport; TODO disable when Demonic Circle buff not active
    DODGEBAR_SPELLS.DRUID = "9821"
    DODGEBAR_SPELLS.DEATHKNIGHT = "444347,48265" -- Death's Advance
    DODGEBAR_SPELLS.SHAMAN = "[spec:2] 58875,2645" -- Spirit Walk if Enhance
elseif GW.Classic or GW.TBC then
    DODGEBAR_SPELLS.WARRIOR = "100" -- Charge
    DODGEBAR_SPELLS.HUNTER = "781" -- Disengage
    DODGEBAR_SPELLS.ROGUE = "2983" -- Sprint
    DODGEBAR_SPELLS.MAGE = "1953" -- Shimmer if talented, else Blink
    DODGEBAR_SPELLS.DRUID = "9821"
end

local EMPTY_IN_RAD = 128 * math.pi / 180 -- the angle in radians for an empty bar
local FULL_IN_RAD = 2 * math.pi / 180 -- the angle in radians for a full bar
local DELTA_RAD = EMPTY_IN_RAD - FULL_IN_RAD

local EMPTY_IN_RAD_SMALL = 1.9040214425527
local FULL_IN_RAD_SMALL = 0

local RAD_AT_START = 1
local RAD_AT_END = -1

GwDodgeBarMixin = {}

-- Retail specifgic code
function GwDodgeBarMixin:UpdateCooldown(durationObject)
    local statusbar = self.statusbar
    if not statusbar then return end

    if durationObject then
        statusbar:SetTimerDuration(durationObject, Enum.StatusBarInterpolation.ExponentialEaseOut)
    end
end

function GwDodgeBarMixin:UpdateChargeText(currentCharges)
    local text = self.chargeText
    if not text then return end

    text:SetText(currentCharges)
end
--- end

function GwDodgeBarMixin:OnFinished()
    -- on finishing refill, unregister any event notifications until next spellcast
    -- also force bar to "full" state just in case weirdness happened somewhere
    self:UnregisterEvent("SPELL_UPDATE_CHARGES")
    self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    FrameFlash(self.arcfill.spark, 0.2)
    self.arcfill.fill:SetRotation(FULL_IN_RAD)
end

function GwDodgeBarMixin:UpdateAnim(start, duration, charges, maxCharges)
    local af = self.arcfill
    local ag = af.gwAnimGroup
    if charges == maxCharges then
        if ag:IsPlaying() then ag:Stop() end
        self:OnFinished()
        return
    end

    if not maxCharges or maxCharges == 0 then maxCharges = 1 end
    -- figure out the total time (and fraction of 1 time) remaining until the bar is full again
    local time_remain = (duration * (maxCharges - charges)) - (GetTime() - start)
    local totalDuration = duration * maxCharges
    local time_remain_frac = time_remain / totalDuration

    if time_remain > 0 then
        -- stop any currently playing anim
        if ag:IsPlaying() then ag:Stop() end

        -- set start position based on fraction of time remaining to recover entire bar;
        -- if there's enough time (and we just cast a spell), do that prettily
        local a1 = af.gwAnimDrain
        a1:SetRadians(DELTA_RAD * time_remain_frac)
        if time_remain < 0.3 or not self.gwNeedDrain then
            a1:SetDuration(0)
        else
            a1:SetDuration(0.25)
            time_remain = time_remain - 0.25
            time_remain_frac = time_remain / totalDuration
            self.gwNeedDrain = false
        end

        -- set the fill animation duration to the remaining time and the angle to the
        -- remaining radians for a full bar, then begin the animation
        local a2 = af.gwAnimFill
        a2:SetDuration(time_remain)
        a2:SetRadians(-DELTA_RAD * time_remain_frac)
        ag:Play()
    end
end

function GwDodgeBarMixin:AnimateSkyridingBar(current, fraction, max)
    if not max or max < 1 or not current then return end
    fraction = fraction or self.currentValueFraction or 0

    local to = current
    local from = self.currentValue or 0
    local toFraction = current + fraction
    local fromFraction = (self.currentValueFraction or 0) + current

    if self.currentValue and current > self.currentValue then
        FrameFlash(self.arcfill.spark, 0.2)
    end

    self.currentValue = current
    self.currentValueFraction =  fraction
    GW.AddToAnimation("SKYRIDINGBAR", 0, 1, GetTime(), 0.8, function(p)
        local l = lerp(from, to, p) / max
        local l2 = lerp(fromFraction, toFraction, p) / max

        local value = lerp(EMPTY_IN_RAD_SMALL, FULL_IN_RAD_SMALL, l)
        local valueFraction = lerp(EMPTY_IN_RAD_SMALL, FULL_IN_RAD_SMALL, l2)
        self.arcfill.fill:SetRotation(value)
        self.arcfill.spark:SetRotation(value)
        self.arcfill.fillFractions:SetRotation(valueFraction)
    end, 1, nil)
end

function GwDodgeBarMixin:InitBar(pew)
    -- do everything required to make the dodge bar a secure clickable button
    local overrideSpellID = GW.private.PLAYER_TRACKED_DODGEBAR_SPELL_ID
    self.gwMaxCharges = nil
    self.spellId = overrideSpellID and overrideSpellID > 0 and overrideSpellID or nil

    if pew or not InCombatLockdown() then
        self:Hide()
    end

    if not DODGEBAR_SPELLS[GW.myclass] and overrideSpellID == 0 then
        return
    end

    local v
    if not self.spellId then
        v = SecureCmdOptionParse(DODGEBAR_SPELLS[GW.myclass])
        if not v then return end
        if string.find(v, ",") then
            for _, spell in pairs(GW.splitString(v, ",", true)) do
                if GW.IsSpellKnown(tonumber(spell)) then
                    self.spellId = tonumber(spell)
                    break
                end
            end
        else
            self.spellId = GW.IsSpellKnown(tonumber(v)) and tonumber(v) or (DODGEBAR_SPELLS_ATTR[GW.myclass] and tonumber(v)) or nil
        end
    end
    Debug("Dodgebar spell for Tooltip: ", self.spellId)

    if self.spellId and (pew or not InCombatLockdown()) then
        if overrideSpellID == 0 and DODGEBAR_SPELLS_ATTR[GW.myclass] then
            v = SecureCmdOptionParse(DODGEBAR_SPELLS_ATTR[GW.myclass])
            if string.find(v, ",") then
                local found = false
                for _, spell in pairs(GW.splitString(v, ",", true)) do
                    if GW.IsSpellKnown(tonumber(spell)) then
                        self:SetAttribute("spell", tonumber(spell))
                        found = true
                        break
                    end
                end
                if not found then return end
            else
                self:SetAttribute("spell", tonumber(v))
            end
            Debug("Dodgebar spell for Click: ", self:GetAttribute("spell"))
        else
            self:SetAttribute("spell", self.spellId)
            Debug("Dodgebar spell for Click: ", self:GetAttribute("spell"))
        end
        if not ((GW.Retail or GW.Mists) and C_PetBattles.IsInBattle()) and not HasOverrideActionBar() and not HasVehicleActionBar() then
            self:Show()
        end
    end
end

function GwDodgeBarMixin:SetupBar()
    -- get additional details about our dodge spell that often aren't available immediately on
    -- PLAYER_ENTERING_WORLD
    if not self.spellId or not C_Spell.GetSpellInfo(self.spellId) then
        return
    end

    if GW.Retail and InCombatLockdown() then
        GW.CombatQueue_Queue("Dodgebar Update", self.SetupBar, {self})
        return
    end

    local spellChargeInfo = C_Spell.GetSpellCharges(self.spellId)
    if GW.Retail then
        local currentCharges = spellChargeInfo and spellChargeInfo.currentCharges
        self:UpdateChargeText(currentCharges)

        local durationObject = C_Spell.GetSpellChargeDuration(self.spellId)
        if durationObject then
            self:UpdateCooldown(durationObject)
        else
            self.statusbar:SetValue(1, Enum.StatusBarInterpolation.ExponentialEaseOut)
        end

        return
    end

    local start, duration = spellChargeInfo and spellChargeInfo.cooldownStartTime, spellChargeInfo and spellChargeInfo.cooldownDuration


    if not spellChargeInfo or (spellChargeInfo and (not spellChargeInfo.currentCharges or not spellChargeInfo.maxCharges or spellChargeInfo.currentCharges > spellChargeInfo.maxCharges)) then
        spellChargeInfo = spellChargeInfo or {}
        local spellCooldownInfo = GW.GetSpellCooldown(self.spellId)
        start = spellCooldownInfo.startTime
        duration = spellCooldownInfo.duration
        if spellCooldownInfo.duration == 0 then
            spellChargeInfo.currentCharges = 1
        else
            spellChargeInfo.currentCharges = 0
        end
        spellChargeInfo.maxCharges = 1
    end
    self.gwMaxCharges = spellChargeInfo.maxCharges or 0

    -- sort out separators for multi charges
    local af = self.arcfill
    if spellChargeInfo.maxCharges == 2 then
        af.sep50:Show()
    else
        af.sep50:Hide()
    end
    if spellChargeInfo.maxCharges == 3 then
        af.sep33:Show()
        af.sep66:Show()
    else
        af.sep33:Hide()
        af.sep66:Hide()
    end
    af.sep132:Hide()
    af.sep264:Hide()
    af.fillFractions:Hide()

    self:UpdateAnim(start or 0, duration or 0, spellChargeInfo.currentCharges or 0, spellChargeInfo.maxCharges or 0)
end

--TODO: Does not work on retail: local spellCooldownInfo is secret in restricted situtations
function GwDodgeBarMixin:OnEvent(event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- we don't track anything until we first see our dodge skill cast
        local spellId = select(3, ...)
        if spellId ~= self.spellId then return end
        self.gwNeedDrain = true
        if (GW.Retail) or (not GW.Retail and self.gwMaxCharges and self.gwMaxCharges > 1) then
            self:RegisterEvent("SPELL_UPDATE_CHARGES")
        else
            self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        -- only registered when our dodge skill is actively on cooldown
        if not GW.inWorld or not self.spellId then return end
        local spellCooldownInfo = GW.GetSpellCooldown(self.spellId)
        if spellCooldownInfo.startTime and spellCooldownInfo.startTime ~= 0 and spellCooldownInfo.duration and spellCooldownInfo.duration ~= 0 then
            self:UpdateAnim(spellCooldownInfo.startTime, spellCooldownInfo.duration, 0, 1)
        end
    elseif event == "SPELL_UPDATE_CHARGES" then
        -- only registered when our dodge skill is actively on cooldown
        if not GW.inWorld or not self.spellId then return end
        local spellChargeInfo = C_Spell.GetSpellCharges(self.spellId)
        if GW.Retail and not self.isSkyrindingBar then -- skyriding is not secret
            local durationObject = C_Spell.GetSpellChargeDuration(self.spellId)
            local currentCharges = spellChargeInfo and spellChargeInfo.currentCharges
            self:UpdateChargeText(currentCharges)
            if durationObject then
                self:UpdateCooldown(durationObject)
            else
                self.statusbar:SetValue(1, Enum.StatusBarInterpolation.ExponentialEaseOut)
            end
        else
            if spellChargeInfo.cooldownStartTime and spellChargeInfo.cooldownStartTime ~= 0 and spellChargeInfo.cooldownDuration and spellChargeInfo.cooldownDuration ~= 0 then
                self:UpdateAnim(spellChargeInfo.cooldownStartTime, spellChargeInfo.cooldownDuration, spellChargeInfo.currentCharges, spellChargeInfo.maxCharges)
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- do the stuff that must be done before combat lockdown takes effect
        self:InitBar(true)
    elseif event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "LEARNED_SPELL_IN_TAB" or event == "LEARNED_SPELL_IN_SKILL_LINE" then
        -- do remaining spell detail stuff that is (usually) not available yet in PEW or if we are not in world
        if (event ~= "LEARNED_SPELL_IN_TAB" and event ~= "LEARNED_SPELL_IN_SKILL_LINE") and (not GW.inWorld or not self.spellId) then return end
        -- add a delay because spell infos sometimes not ready
        C_Timer.After(0.33, function()
            self:InitBar(false)
            self:SetupBar()
        end)
    end
end

function GwDodgeBarMixin:OnEnter(_, override)
    local bar = override and self or self.skyringingBarShown and self.skyrindingBar or self

    if not GW.Retail or self.skyringingBarShown then
        local af = bar.arcfill
        for _, v in ipairs(af.masked) do
            v:AddMaskTexture(af.mask_hover)
            v:RemoveMaskTexture(af.mask_normal)
        end
        af.fill:AddMaskTexture(af.maskr_hover)
        af.fill:RemoveMaskTexture(af.maskr_normal)
        bar.border.normal:Hide()
        bar.border.hover:Show()
    end

    if bar.spellId then
        GameTooltip_SetDefaultAnchor(GameTooltip, bar)
        GameTooltip:SetSpellByID(bar.spellId)
        GameTooltip:Show()
    else
        GameTooltip_SetDefaultAnchor(GameTooltip, bar)
        GameTooltip:AddLine(bar.tooltip, 1, 1, 1, true)
        GameTooltip:Show()
    end
end

function GwDodgeBarMixin:OnLeave(_, override)
    local bar = override and self or self.skyringingBarShown and self.skyrindingBar or self
    if not GW.Retail or self.skyringingBarShown or override then
        local af = bar.arcfill
        for _, v in ipairs(af.masked) do
            v:AddMaskTexture(af.mask_normal)
            v:RemoveMaskTexture(af.mask_hover)
        end
        af.fill:AddMaskTexture(af.maskr_normal)
        af.fill:RemoveMaskTexture(af.maskr_hover)
        af.fillFractions:AddMaskTexture(af.maskr_fraction)
        af.spark:AddMaskTexture(af.maskr_normal)
        af.spark:RemoveMaskTexture(af.maskr_hover)
        bar.border.hover:Hide()
        bar.border.normal:Show()
    end

    -- hide the spell tooltip
    GameTooltip_Hide()
end

function GwDodgeBarMixin:SetupSkyridingBar()
    local frameName = self:GetName()

    for i = 1, 5 do
        local seperator = _G[frameName .. "Sep" .. i]
        if i <= self.gwMaxCharges - 1 then
            local p = lerp(RAD_AT_START, RAD_AT_END, i / self.gwMaxCharges )
            seperator:SetRotation(p)
            seperator:Show()
        else
            seperator:Hide()
        end
    end
end

function GwDodgeBarMixin:UpdateSkyridingBarState(state, isLogin)
    if (self.gwMaxCharges and isLogin) or (self.gwMaxCharges and self.gwMaxCharges < 3) then
        self:SetupSkyridingBar()
    end

    if not state and self:IsShown() then
        self:Hide()
        self.dodgeBar.skyringingBarShown = false
    elseif (state and not self:IsShown()) or (state and isLogin and self:IsShown()) then
        self:Show()
        self.dodgeBar:OnLeave()
        self.dodgeBar.skyringingBarShown = true
    end
end

function GwDodgeBarMixin:SkyridingBarOnEvent(event, ...)
    if event == "GW2_PLAYER_SKYRIDING_STATE_CHANGE" then
        local state, isLogin = ...
        self:UpdateSkyridingBarState(state, isLogin)
    end
end

function GwDodgeBarMixin:LoadSkiridingBar(parent)
    Debug("LoadSkiridingBar start")

    -- this bar gets a global name for use in key bindings
    local fmdb = CreateFrame("Button", "GwSkyridingBar", UIParent, "UnsecureDodgeBar")
    fmdb:SetFrameLevel(self:GetFrameLevel() - 1)
    fmdb.arcfill.fill:SetVertexColor(1,1,1,1)
    fmdb.arcfill.spark:SetVertexColor(1,1,1)
    fmdb.arcfill.fillFractions:SetVertexColor(100/255,100/255,100/255)
    fmdb.asTargetFrame = self.asTargetFrame
    fmdb.dodgeBar = self
    self.skyrindingBar = fmdb
    fmdb.isSkyrindingBar = true
    GW.AddMouseMotionPropagationToChildFrames(self.arcfill)
    GW.AddMouseMotionPropagationToChildFrames(self.border)

    if fmdb.asTargetFrame then
        parent.skyrindingBar = fmdb
        fmdb.arcfill:SetSize(80, 72)
        fmdb.arcfill.mask_normal:SetSize(80, 72)
        fmdb.arcfill.mask_hover:SetSize(80, 72)
        fmdb.arcfill.maskr_normal:SetSize(80, 72)
        fmdb.arcfill.maskr_hover:SetSize(80, 72)
        fmdb.arcfill.maskr_fraction:SetSize(80, 72)
        fmdb.border:SetSize(80, 72)
        fmdb:SetPoint("TOPLEFT", parent, "TOPLEFT", -9.5, 5)
        fmdb:SetFrameStrata("BACKGROUND")
        fmdb:SetScale(GW.settings.player_pos_scale)
        parent:HookScript("OnSizeChanged", function() fmdb:SetScale(GW.settings.player_pos_scale) end)
        hooksecurefunc(parent, "SetAlpha", function(_, value) fmdb:SetAlpha(value) end)
    else
        fmdb:SetPoint("CENTER", parent, "CENTER", 0, 41)
        GW.RegisterScaleFrame(fmdb, 1.1)
    end

    fmdb.spellId = 372608 -- Skyward Leap

    -- setting these values in the XML creates animation glitches so we do it here instead
    local af = fmdb.arcfill

    af.maskr_hover:SetPoint("CENTER", af.fill, "CENTER", 0, 0)
    af.maskr_normal:SetPoint("CENTER", af.fill, "CENTER", 0, 0)
    af.maskr_fraction:SetPoint("CENTER", af.fill, "CENTER", 0, 0)

    fmdb.arcfill.fill:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/fill-small.png")
    fmdb.arcfill.fillFractions:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/fill-small.png")
    af.maskr_normal:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/masksmall.png")
    af.maskr_fraction:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/masksmall.png")
    af.mask_normal:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/masksmall.png")

    fmdb.border.normal:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/border-normal-small.png")

    -- create the arc drain/fill animations
    local ag = af.fill:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("rotation")
    local a2 = ag:CreateAnimation("rotation")

    a1:SetOrder(1)
    a2:SetOrder(2)

    af.gwAnimGroup = ag
    af.gwAnimDrain = a1
    af.gwAnimFill = a2

    af.fillFractions:SetRotation(EMPTY_IN_RAD)

    -- setup dodgebar event handling
    fmdb:OnLeave(nil, true)
    fmdb:RegisterEvent("SPELL_UPDATE_CHARGES")
    fmdb:SetScript("OnEvent", fmdb.OnEvent)

    GW.Libs.GW2Lib.RegisterCallback(fmdb, "GW2_PLAYER_SKYRIDING_STATE_CHANGE", function(event, ...)
        fmdb:SkyridingBarOnEvent(event, ...)
    end)

    MixinHideDuringPetAndOverride(fmdb)

    Debug("LoadSkiridingBar done")
    return fmdb
end

local function LoadDodgeBar(parent, asTargetFrame)
    Debug("LoadDodgeBar start")

    -- this bar gets a global name for use in key bindings
    local fmdb = CreateFrame("Button", "GwDodgeBar", UIParent, GW.Retail and "GwDodgeBarRetailTmpl" or "GwDodgeBarTmpl")
    fmdb.asTargetFrame = asTargetFrame
    fmdb:RegisterForClicks("AnyUp", "AnyDown")
    if fmdb.asTargetFrame then
        parent.dodgebar = fmdb
        fmdb.arcfill:SetSize(80, 72)
        fmdb.arcfill.mask_normal:SetSize(80, 72)
        fmdb.arcfill.maskr_normal:SetSize(80, 72)
        if not GW.Retail then
            fmdb.arcfill.mask_hover:SetSize(80, 72)
            fmdb.arcfill.maskr_hover:SetSize(80, 72)
        end
        fmdb.border:SetSize(80, 72)
        fmdb:SetPoint("TOPLEFT", parent, "TOPLEFT", -9.5, 5)
        fmdb:SetFrameStrata("BACKGROUND")
        fmdb:SetScale(GW.settings.player_pos_scale)
        parent:HookScript("OnSizeChanged", function() fmdb:SetScale(GW.settings.player_pos_scale) end)
        hooksecurefunc(parent, "SetAlpha", function(_, value) fmdb:SetAlpha(value) end)
    else
        fmdb:SetPoint("CENTER", parent, "CENTER", 0, 41)
        GW.RegisterScaleFrame(fmdb, 1.1)
    end
    fmdb:SetAttribute("type", "spell")

    -- setting these values in the XML creates animation glitches so we do it here instead
    local af = fmdb.arcfill
    af.maskr_normal:SetPoint("CENTER", af.fill, "CENTER", 0, 0)
    if GW.Retail then
        af.bg:AddMaskTexture(af.mask_normal)

        fmdb.statusbar = CreateFrame("StatusBar", nil, fmdb)
        fmdb.statusbar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/dodgebar/fill.png")
        fmdb.statusbar:SetPoint("TOPLEFT", af, "TOPLEFT", 8, 0)
        fmdb.statusbar:SetPoint("BOTTOMRIGHT", af, "BOTTOMRIGHT", -8, 0)
        fmdb.statusbar:SetStatusBarColor(1.0, 0.682, 0.031, 1.0)
        local statusTexture = fmdb.statusbar:GetStatusBarTexture()
        statusTexture:SetTexCoord(0.08, 0.92, 0.0, 1.0)
        af.maskr_normal:SetPoint("CENTER", af, "CENTER", 0, 0)
        statusTexture:AddMaskTexture(af.maskr_normal)

        fmdb.chargeText = fmdb.statusbar:CreateFontString(nil, "OVERLAY")
        fmdb.chargeText:SetPoint("CENTER", fmdb.statusbar, "CENTER", 0, (fmdb.asTargetFrame and 27 or 47))
        fmdb.chargeText:SetFont(UNIT_NAME_FONT, 7, "OUTLINE")
        fmdb.chargeText:SetShadowColor(0, 0, 0, 1)
        fmdb.chargeText:SetShadowOffset(1, -1)
        fmdb.chargeText:SetTextColor(1.0, 0.95, 0.8, 0.85)
        fmdb.chargeText:Show()
    else
        af.fill:SetRotation(FULL_IN_RAD)
        af.maskr_hover:SetPoint("CENTER", af.fill, "CENTER", 0, 0)

        -- create the arc drain/fill animations
        local ag = af.fill:CreateAnimationGroup()
        local a1 = ag:CreateAnimation("rotation")
        local a2 = ag:CreateAnimation("rotation")
        a1:SetOrder(1)
        a2:SetOrder(2)
        af.gwAnimGroup = ag
        af.gwAnimDrain = a1
        af.gwAnimFill = a2
    end

    -- setup dodgebar event handling
    fmdb.skyringingBarShown = false
    fmdb:OnLeave(nil, not GW.Retail)
    fmdb:SetScript("OnEnter", fmdb.OnEnter)
    fmdb:SetScript("OnLeave", fmdb.OnLeave)
    fmdb:SetScript("OnEvent", fmdb.OnEvent)
    fmdb:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    fmdb:RegisterEvent("SPELLS_CHANGED")
    fmdb:RegisterEvent("PLAYER_ENTERING_WORLD")
    fmdb:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    if GW.Retail or GW.TBC then
        fmdb:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
    else
        fmdb:RegisterEvent("LEARNED_SPELL_IN_TAB")
    end

    -- setup hook to hide the dodge bar when in vehicle/override UI
    MixinHideDuringPetAndOverride(fmdb)

    Debug("LoadDodgeBar done")
    if GW.Retail then
        fmdb:LoadSkiridingBar(parent)
    end
    return fmdb
end
GW.LoadDodgeBar = LoadDodgeBar
