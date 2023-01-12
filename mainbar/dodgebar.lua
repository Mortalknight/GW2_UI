local _, GW = ...
local Debug = GW.Debug
local MixinHideDuringPetAndOverride = GW.MixinHideDuringPetAndOverride
local FrameFlash = GW.FrameFlash
local GetSetting = GW.GetSetting
local lerp = GW.lerp
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation

local DRAGON_POWERTYPE = 10


-- these strings will be parsed by SecureCmdOptionParse
-- https://wow.gamepedia.com/Secure_command_options
local DODGEBAR_SPELLS = {} -- spell ID used to generate the bar information/tooltip
local DODGEBAR_SPELLS_ATTR = {} -- spell ID used to cast ability on button click, if different than above
DODGEBAR_SPELLS["WARRIOR"] = "100" -- Charge
DODGEBAR_SPELLS["PALADIN"] = "190784" -- Divine Steed
DODGEBAR_SPELLS["HUNTER"] = "781" -- Disengage
DODGEBAR_SPELLS["ROGUE"] = "2983" -- Sprint
DODGEBAR_SPELLS["PRIEST"] = "[spec:1/2,talent:2/3] 121536; 73325" -- Angelic Feather if talented, else Leap of Faith
DODGEBAR_SPELLS["DEATHKNIGHT"] = "48265" -- Death's Advance
DODGEBAR_SPELLS["SHAMAN"] = "[spec:2] 58875,2645" -- Spirit Walk if Enhance
DODGEBAR_SPELLS["MAGE"] = "[talent:2/2] 212653; 1953" -- Shimmer if talented, else Blink
DODGEBAR_SPELLS_ATTR["MAGE"] = "1953" -- use Blink instead of Shimmer for the button attr
DODGEBAR_SPELLS["WARLOCK"] = "48020" -- Demonic Circle: Teleport; TODO disable when Demonic Circle buff not active
DODGEBAR_SPELLS["MONK"] = "[talent:2/2] 115008; 109132" -- Chi Torpedo if talented, else Roll
DODGEBAR_SPELLS_ATTR["MONK"] = "109132" -- use Roll instead of Chi Torpedo for the button attr
DODGEBAR_SPELLS["DRUID"] = "[talent:2/1] 252216; [talent:2/3,form:1] 16979; [talent:2/3,form:2] 49376; [talent:2/3,form:3,swimming] 102416; [talent:2/3,form:3] 102417; [talent:2/3,form:4] 102383; [talent:2/3] 102401; 1850" -- Tiger Dash if talented, else Wild Charge if talented (with all its sub-details for different forms), else Dash
DODGEBAR_SPELLS_ATTR["DRUID"] = "[talent:2/3] 102401; 1850" -- use Dash (instead of Tiger Dash) and Wild Charge baseline(instead of form-specific talents) for the button attr
DODGEBAR_SPELLS["DEMONHUNTER"] = "[spec:1] 195072; [spec:2] 189110; 344865" -- Fel Rush (Havoc) or Infernal Strike (Vengeance)
DODGEBAR_SPELLS_ATTR["DEMONHUNTER"] = "[spec:1] 343017,320416,344865; [spec:2] 189110; 344865" -- Fel Rush (Havoc) or Infernal Strike (Vengeance)
DODGEBAR_SPELLS["EVOKER"] = "358267"

local EMPTY_IN_RAD = 128 * math.pi / 180 -- the angle in radians for an empty bar
local FULL_IN_RAD = 2 * math.pi / 180 -- the angle in radians for a full bar
local DELTA_RAD = EMPTY_IN_RAD - FULL_IN_RAD

local EMPTY_IN_RAD_SMALL = 1.9040214425527
local FULL_IN_RAD_SMALL = 0

local RAD_AT_START = 1
local RAD_AT_END = -1

local function fill_OnFinished(self)
    -- on finishing refill, unregister any event notifications until next spellcast
    -- also force bar to "full" state just in case weirdness happened somewhere
    local f = self:GetParent()
    local fm = f:GetParent():GetParent()
    fm:UnregisterEvent("SPELL_UPDATE_CHARGES")
    fm:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    FrameFlash(fm.arcfill.spark, 0.2)
    f:SetRotation(FULL_IN_RAD)
end
GW.AddForProfiling("dodgebar", "fill_OnFinished", fill_OnFinished)

local function updateAnim(self, start, duration, charges, maxCharges)
    local af = self.arcfill
    local ag = af.gwAnimGroup
    if charges == maxCharges then
        if (ag:IsPlaying()) then
            ag:Stop()
        end
        fill_OnFinished(ag)
        return
    end
    if not self.gwCharges then  self.gwCharges = 0 end
    -- spark if charge count has changed
    if not self.gwNeedDrain and self.gwCharges > charges then
  --    FrameFlash(self.arcfill.fill, 0.2)
    end
    self.gwCharges = charges

    if maxCharges == nil or maxCharges == 0 then maxCharges = 1 end
    -- figure out the total time (and fraction of 1 time) remaining until the bar is full again
    local time_remain = (duration * (maxCharges - charges)) - (GetTime() - start)
    local time_remain_frac = (time_remain / (duration * maxCharges))

    if time_remain > 0 then
        -- stop any currently playing anim
        if (ag:IsPlaying()) then
            ag:Stop()
        end

        -- set start position based on fraction of time remaining to recover entire bar;
        -- if there's enough time (and we just cast a spell), do that prettily
        local a1 = af.gwAnimDrain
        a1:SetRadians(DELTA_RAD * time_remain_frac)
        if (time_remain < 0.3 or not self.gwNeedDrain) then
            a1:SetDuration(0)
        else
            a1:SetDuration(0.25)
            time_remain = time_remain - 0.25
            time_remain_frac = (time_remain / (duration * maxCharges))
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
GW.AddForProfiling("dodgebar", "updateAnim", updateAnim)

local function initBar(self, pew)
    -- do everything required to make the dodge bar a secure clickable button
    local overrideSpellID = tonumber(GetSetting("PLAYER_TRACKED_DODGEBAR_SPELL_ID"))

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
        v, _ = SecureCmdOptionParse(DODGEBAR_SPELLS[GW.myclass])
        if not v then
            return
        end
        if string.find(v, ",") then
            for _, v in pairs(GW.splitString(v, ",", true)) do
                if IsSpellKnown(tonumber(v)) then
                    self.spellId = tonumber(v)
                    break
                end
            end
        else
            self.spellId = IsSpellKnown(tonumber(v)) and tonumber(v) or DODGEBAR_SPELLS_ATTR[GW.myclass] and tonumber(v) or nil
        end
    end
    Debug("Dodgebar spell for Tooltip: ", self.spellId)

    if self.spellId and (pew or not InCombatLockdown()) then
        if overrideSpellID == 0 and DODGEBAR_SPELLS_ATTR[GW.myclass] then
            v = SecureCmdOptionParse(DODGEBAR_SPELLS_ATTR[GW.myclass])
            if string.find(v, ",") then
                local found = false
                for _, v in pairs(GW.splitString(v, ",", true)) do
                    if IsSpellKnown(tonumber(v)) then
                        self:SetAttribute("spell", tonumber(v))
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
        end
        if not C_PetBattles.IsInBattle() and not HasOverrideActionBar() and not HasVehicleActionBar() then
            self:Show()
        end
    end
end
GW.initDodgebarSpell = initBar
GW.AddForProfiling("dodgebar", "initBar", initBar)

local function setupBar(self)
    -- get additional details about our dodge spell that often aren't available immediately on
    -- PLAYER_ENTERING_WORLD
    if not self.spellId or not GetSpellInfo(self.spellId) then
        return
    end

    local charges, maxCharges, start, duration = GetSpellCharges(self.spellId)
    if charges == nil or maxCharges == nil or charges > maxCharges then
        start, duration, _ = GetSpellCooldown(self.spellId)
        if duration == 0 then
            charges = 1
        else
            charges = 0
        end
        maxCharges = 1
    end
    self.gwMaxCharges = maxCharges or 0

    -- sort out separators for multi charges
    local af = self.arcfill
    if maxCharges == 2 then
        af.sep50:Show()
    else
        af.sep50:Hide()
    end
    if maxCharges == 3 then
        af.sep33:Show()
        af.sep66:Show()
    else
        af.sep33:Hide()
        af.sep66:Hide()
    end
    af.sep132:Hide()
    af.sep264:Hide()
    af.fillFractions:Hide()

    updateAnim(self, start, duration, charges, maxCharges)
end
GW.setDodgebarSpell = setupBar
GW.AddForProfiling("dodgebar", "setupBar", setupBar)

local function dodge_OnEvent(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- we don't track anything until we first see our dodge skill cast
        local spellId = select(3, ...)
        if spellId ~= self.spellId then
            return
        end
        self.gwNeedDrain = true
        if (self.gwMaxCharges > 1) then
            self:RegisterEvent("SPELL_UPDATE_CHARGES")
        else
            self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end

    elseif event == "SPELL_UPDATE_COOLDOWN" then
        -- only registered when our dodge skill is actively on cooldown
        if not GW.inWorld or not self.spellId then
            return
        end
        local start, duration, _ = GetSpellCooldown(self.spellId)
        if start ~= nil and start ~= 0 and duration ~= nil and duration ~= 0 then
            updateAnim(self, start, duration, 0, 1)
        end

    elseif event == "SPELL_UPDATE_CHARGES" then
        -- only registered when our dodge skill is actively on cooldown
        if not GW.inWorld or not self.spellId then
            return
        end
        local charges, maxCharges, start, duration = GetSpellCharges(self.spellId)
        if start ~= nil and start ~= 0 and duration ~= nil and duration ~= 0 then
            updateAnim(self, start, duration, charges, maxCharges)
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- do the stuff that must be done before combat lockdown takes effect
        initBar(self, true)

    elseif event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "LEARNED_SPELL_IN_TAB" then
        -- do remaining spell detail stuff that is (usually) not available yet in PEW or if we are not in world
        if event ~= "LEARNED_SPELL_IN_TAB" and (not GW.inWorld or not self.spellId) then
            return
        end
        -- add a delay because spell infos sometimes not ready
        C_Timer.After(0.33, function()
            initBar(self, false)
            setupBar(self)
        end)
    end
end
GW.AddForProfiling("dodgebar", "dodge_OnEvent", dodge_OnEvent)

local function dodge_OnEnter(self)
    -- change the masks/art to the hover version
    local af = self.arcfill
    for _, v in ipairs(af.masked) do
        v:AddMaskTexture(af.mask_hover)
        v:RemoveMaskTexture(af.mask_normal)
    end
    af.fill:AddMaskTexture(af.maskr_hover)
    af.fill:RemoveMaskTexture(af.maskr_normal)
    self.border.normal:Hide()
    self.border.hover:Show()

    -- show the spell tooltip
    if self.spellId then
      GameTooltip_SetDefaultAnchor(GameTooltip, self)
      GameTooltip:SetSpellByID(self.spellId)
      GameTooltip:Show()
    else
      GameTooltip_SetDefaultAnchor(GameTooltip, self)
      GameTooltip:SetSpellByID(self.spellId)
      GameTooltip:Show()
    end
end
GW.AddForProfiling("dodgebar", "dodge_OnEnter", dodge_OnEnter)

local function dodge_OnLeave(self)
    -- change the masks/art to the non-hover (normal) version
    local af = self.arcfill
    for _, v in ipairs(af.masked) do
        v:AddMaskTexture(af.mask_normal)
        v:RemoveMaskTexture(af.mask_hover)
    end
    af.fill:AddMaskTexture(af.maskr_normal)
    af.fill:RemoveMaskTexture(af.maskr_hover)
    af.fillFractions:AddMaskTexture(af.maskr_fraction)
    af.spark:AddMaskTexture(af.maskr_normal)
    af.spark:RemoveMaskTexture(af.maskr_hover)
    self.border.hover:Hide()
    self.border.normal:Show()

    -- hide the spell tooltip
    GameTooltip_Hide()
end
GW.AddForProfiling("dodgebar", "dodge_OnLeave", dodge_OnLeave)

local function setupDragonBar(self)

    local maxVigor = UnitPowerMax("player" , DRAGON_POWERTYPE);

    local frameName = self:GetName()
    for i=1,5 do
      local seperator = _G[frameName.."Sep"..i]
      if i<=maxVigor then
          local p = lerp(RAD_AT_START,RAD_AT_END,i/maxVigor)
          seperator:SetRotation(p)
          seperator:Show()
      else
        seperator:Hide()
      end
    end
end
local function animateDragonBar(self,current,fraction,max)

  if not max or max < 1 or not current then
    return
  end

  if not fraction then
    fraction = self.currentValueFraction or 0
  end
  local to = current
  local from = self.currentValue or 0

  local toFraction = current + fraction
  local fromfraction =  self.currentValueFraction or 0
  fromfraction = fromfraction + current
  local flash = nil
  if self.currentValue~=nil and current>self.currentValue then
    FrameFlash(self.arcfill.spark, 0.2)
  end

  self.currentValue = current
  self.currentValueFraction =  fraction
  AddToAnimation("DRAGONBAR", 0, 1, GetTime(), 0.8,
  function()
    local p = animations["DRAGONBAR"].progress
    local l = lerp(from,to,p) / max
    local l2 = lerp(fromfraction,toFraction,p) / max

    local value = lerp(EMPTY_IN_RAD_SMALL,FULL_IN_RAD_SMALL,l)
    local valueFraction = lerp(EMPTY_IN_RAD_SMALL,FULL_IN_RAD_SMALL,l2)
    self.arcfill.fill:SetRotation(value)
    self.arcfill.spark:SetRotation(value)
    self.arcfill.fillFractions:SetRotation(valueFraction)
  end,1,flash)


end
local function updateDragonRidingState(self)
  if GwIsCurrentlyDragonRiding==false and self:IsShown() then
    self:Hide()
  elseif GwIsCurrentlyDragonRiding and not self:IsShown() then
    self:Show()
  end
end
local thrillInstanceID
local function dragonBar_OnEvent(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- we don't track anything until we first see our dodge skill cast
        local spellId = select(3, ...)
        if spellId ~= DR_FORWARD and spellId ~= DR_FLAP and spellId ~= DR_SURGE  then
            return
        end
    --    self.gwNeedDrain = true
    elseif event == "UNIT_POWER_UPDATE" then

      local current = UnitPower("player",DRAGON_POWERTYPE)
      local max = UnitPowerMax("player",DRAGON_POWERTYPE)
      local fraction = (self.lastPower and self.lastPower>current and 0) or nil
      if not self.gwMaxCharges or max>self.gwMaxCharges then
        self.gwMaxCharges = max
        setupDragonBar(self)
      end
      animateDragonBar(self,current,nil,max)
      self.lastPower = current


    elseif event == "UPDATE_UI_WIDGET" then
      local widget = ...
      if widget.widgetSetID ~=283 then
        return
      end
      local current = UnitPower("player",DRAGON_POWERTYPE)
      local max = UnitPowerMax("player",DRAGON_POWERTYPE)

      local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widget.widgetID)
        if widgetInfo then
        --  updateAnim(self, GetTime(), 20, math.min(max,current + (widgetInfo.fillValue / widgetInfo.fillMax)), max)
          animateDragonBar(self, current,(widgetInfo.fillValue / widgetInfo.fillMax), max)
        end

      elseif event=="DRAGONRIDING_STATE_CHANGE" then

        updateDragonRidingState(self)

      elseif event=="PLAYER_ENTERING_WORLD" then
        C_Timer.After(0.33, function()
          updateDragonRidingState(self)
          setupDragonBar(self)
        end)

      end
end

local function LoadDodgeBar(hg, asTargetFrame)
    Debug("LoadDodgeBar start")

    -- this bar gets a global name for use in key bindings
    local fmdb = CreateFrame("Button", "GwDodgeBar", UIParent, "GwDodgeBarTmpl")
    fmdb.asTargetFrame = asTargetFrame
    fmdb:RegisterForClicks("AnyUp", "AnyDown")

    fmdb:ClearAllPoints()
    if fmdb.asTargetFrame then
        hg.dodgebar = fmdb
        fmdb.arcfill:SetSize(80, 72)
        fmdb.arcfill.mask_normal:SetSize(80, 72)
        fmdb.arcfill.mask_hover:SetSize(80, 72)
        fmdb.arcfill.maskr_normal:SetSize(80, 72)
        fmdb.arcfill.maskr_hover:SetSize(80, 72)
        fmdb.border:SetSize(80, 72)
        fmdb:SetPoint("TOPLEFT", hg, "TOPLEFT", -9.5, 5)
        fmdb:SetFrameStrata("BACKGROUND")
        hg:HookScript("OnSizeChanged", function() fmdb:SetScale(GetSetting("player_pos_scale")) end)
    else
        fmdb:SetPoint("CENTER", hg, "CENTER", 0, 41)
        GW.RegisterScaleFrame(fmdb, 1.1)
    end
    fmdb:SetAttribute("*type1", "spell")

    -- setting these values in the XML creates animation glitches so we do it here instead
    local af = fmdb.arcfill
    af.fill:SetRotation(FULL_IN_RAD)
    af.maskr_hover:SetPoint("CENTER", af.fill, "CENTER", 0, 0)
    af.maskr_normal:SetPoint("CENTER", af.fill, "CENTER", 0, 0)

    -- create the arc drain/fill animations
    local ag = af.fill:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("rotation")
    local a2 = ag:CreateAnimation("rotation")
    a1:SetOrder(1)
    a2:SetOrder(2)
    af.gwAnimGroup = ag
    af.gwAnimDrain = a1
    af.gwAnimFill = a2
  --  ag:SetScript("OnFinished", fill_OnFinished)

    -- setup dodgebar event handling
    dodge_OnLeave(fmdb)
    fmdb:SetScript("OnEnter", dodge_OnEnter)
    fmdb:SetScript("OnLeave", dodge_OnLeave)
    fmdb:SetScript("OnEvent", dodge_OnEvent)
    fmdb:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    fmdb:RegisterEvent("SPELLS_CHANGED")
    fmdb:RegisterEvent("PLAYER_ENTERING_WORLD")
    fmdb:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    fmdb:RegisterEvent("LEARNED_SPELL_IN_TAB")


    -- setup hook to hide the dodge bar when in vehicle/override UI
    MixinHideDuringPetAndOverride(fmdb)

    Debug("LoadDodgeBar done")
    return fmdb
end
local function LoadDragonBar(hg, asTargetFrame)
    Debug("LoadDragonBar start")

    -- this bar gets a global name for use in key bindings
    local fmdb = CreateFrame("Button", "GwDragonBar", UIParent, "GwDodgeBarTmpl")
    fmdb:SetFrameLevel(GwDodgeBar:GetFrameLevel() - 1)
    fmdb.arcfill.fill:SetVertexColor(1,1,1,1)
    fmdb.arcfill.spark:SetVertexColor(1,1,1)
    fmdb.arcfill.fillFractions:SetVertexColor(100/255,100/255,100/255)
    fmdb.asTargetFrame = asTargetFrame

    fmdb:ClearAllPoints()
    if fmdb.asTargetFrame then
        hg.dragonBar = fmdb
        fmdb.arcfill:SetSize(80, 72)
        fmdb.arcfill.mask_normal:SetSize(80, 72)
        fmdb.arcfill.mask_hover:SetSize(80, 72)
        fmdb.arcfill.maskr_normal:SetSize(80, 72)
        fmdb.arcfill.maskr_hover:SetSize(80, 72)
        fmdb.arcfill.maskr_fraction:SetSize(80, 72)
        fmdb.border:SetSize(80, 72)
        fmdb:SetPoint("TOPLEFT", hg, "TOPLEFT", -9.5, 5)
        fmdb:SetFrameStrata("BACKGROUND")
        hg:HookScript("OnSizeChanged", function() fmdb:SetScale(GetSetting("player_pos_scale")) end)
    else
        fmdb:SetPoint("CENTER", hg, "CENTER", 0, 41)
        GW.RegisterScaleFrame(fmdb, 1.1)
    end

    -- setting these values in the XML creates animation glitches so we do it here instead
    local af = fmdb.arcfill

    af.maskr_hover:SetPoint("CENTER", af.fill, "CENTER", 0, 0)
    af.maskr_normal:SetPoint("CENTER", af.fill, "CENTER", 0, 0)
    af.maskr_fraction:SetPoint("CENTER", af.fill, "CENTER", 0, 0)

    fmdb.arcfill.fill:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/fill-small")
    fmdb.arcfill.fillFractions:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/fill-small")
    af.maskr_normal:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/masksmall")
    af.maskr_fraction:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/masksmall")
    af.mask_normal:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/masksmall")

    fmdb.border.normal:SetTexture("Interface/AddOns/GW2_UI/textures/dodgebar/border-normal-small")

    -- create the arc drain/fill animations
    local agFraction = af.fillFractions:CreateAnimationGroup()
    local agSpark = af.spark:CreateAnimationGroup()
    local ag = af.fill:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("rotation")
    local a2 = ag:CreateAnimation("rotation")

    a1:SetOrder(1)
    a2:SetOrder(2)

    af.gwAnimGroup = ag
    af.gwAnimDrain = a1
    af.gwAnimFill = a2

    af.fillFractions:SetRotation(EMPTY_IN_RAD)
    ag:SetScript("OnFinished", fill_OnFinished)

    -- setup dodgebar event handling
    dodge_OnLeave(fmdb)
    fmdb:SetScript("OnEnter", dodge_OnEnter)
    fmdb:SetScript("OnLeave", dodge_OnLeave)
    fmdb:SetScript("OnEvent", dragonBar_OnEvent)
    fmdb:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    fmdb:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    fmdb:RegisterEvent("UPDATE_UI_WIDGET")
    fmdb:RegisterEvent("PLAYER_ENTERING_WORLD")

    hooksecurefunc("GwDragonRidingStateChange",function() dragonBar_OnEvent(fmdb,"DRAGONRIDING_STATE_CHANGE") end)



    Debug("LoadDragonBar done")
    return fmdb
end
GW.LoadDragonBar = LoadDragonBar
GW.LoadDodgeBar = LoadDodgeBar
