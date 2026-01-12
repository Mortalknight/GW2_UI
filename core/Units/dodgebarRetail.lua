local _, GW = ...
local Debug = GW.Debug
local MixinHideDuringPetAndOverride = GW.MixinHideDuringPetAndOverride
local FrameFlash = GW.FrameFlash
local lerp = GW.lerp

if not GW.Retail then return end

-- these strings will be parsed by SecureCmdOptionParse
-- https://wow.gamepedia.com/Secure_command_options
local DODGEBAR_SPELLS = {} -- spell ID used to generate the bar information/tooltip
local DODGEBAR_SPELLS_ATTR = {} -- spell ID used to cast ability on button click, if different than above
if GW.Retail then
    DODGEBAR_SPELLS["WARRIOR"] = "100" -- Charge
    DODGEBAR_SPELLS["PALADIN"] = "190784" -- Divine Steed
    DODGEBAR_SPELLS["HUNTER"] = "781" -- Disengage
    DODGEBAR_SPELLS["ROGUE"] = "2983" -- Sprint
    DODGEBAR_SPELLS["PRIEST"] = "[spec:1/2,known:121536] 121536; 73325" -- Angelic Feather if talented, else Leap of Faith
    DODGEBAR_SPELLS["DEATHKNIGHT"] = "444347,48265" -- Death's Advance
    DODGEBAR_SPELLS["SHAMAN"] = "2645" -- Spirit Walk if Enhance
    DODGEBAR_SPELLS["MAGE"] = "[known:212653] 212653; 1953" -- Shimmer if talented, else Blink
    DODGEBAR_SPELLS_ATTR["MAGE"] = "1953" -- use Blink instead of Shimmer for the button attr
    DODGEBAR_SPELLS["WARLOCK"] = "48020" -- Demonic Circle: Teleport; TODO disable when Demonic Circle buff not active
    DODGEBAR_SPELLS["MONK"] = "[known:115008]115008; 109132" -- Chi Torpedo if talented, else Roll
    DODGEBAR_SPELLS_ATTR["MONK"] = "109132" -- use Roll instead of Chi Torpedo for the button attr
    DODGEBAR_SPELLS["DRUID"] = "[known:252216] 252216; [known:16979,form:1] 16979; [known:49376,form:2] 49376; [known:102416,form:3,swimming] 102416; [known:102417,form:3] 102417; [known:102383,form:4] 102383; [known:102401] 102401; 1850" -- Tiger Dash if talented, else Wild Charge if talented (with all its sub-details for different forms), else Dash
    DODGEBAR_SPELLS_ATTR["DRUID"] = "[known:102401] 102401; 1850" -- use Dash (instead of Tiger Dash) and Wild Charge baseline(instead of form-specific talents) for the button attr
    DODGEBAR_SPELLS["DEMONHUNTER"] = "[spec:1] 195072; [spec:2] 189110; 344865" -- Fel Rush (Havoc) or Infernal Strike (Vengeance)
    DODGEBAR_SPELLS_ATTR["DEMONHUNTER"] = "[spec:1] 343017,320416,344865; [spec:2] 189110; 344865" -- Fel Rush (Havoc) or Infernal Strike (Vengeance)
    DODGEBAR_SPELLS["EVOKER"] = "358267"
elseif GW.Mists then
    DODGEBAR_SPELLS["ROGUE"] = "2983" -- Sprint
    DODGEBAR_SPELLS["WARRIOR"] = "100" -- Charge
    DODGEBAR_SPELLS["HUNTER"] = "781" -- Disengage
    DODGEBAR_SPELLS["MAGE"] = "1953" -- Shimmer if talented, else Blink
    DODGEBAR_SPELLS["MONK"] = "[known:115173] 121827; 109132"-- Chi Torpedo if talented, else Roll
    DODGEBAR_SPELLS_ATTR["MONK"] = "109132"
    DODGEBAR_SPELLS["WARLOCK"] = "48020" -- Demonic Circle: Teleport; TODO disable when Demonic Circle buff not active
    DODGEBAR_SPELLS["DRUID"] = "9821"
    DODGEBAR_SPELLS["DEATHKNIGHT"] = "444347,48265" -- Death's Advance
    DODGEBAR_SPELLS["SHAMAN"] = "[spec:2] 58875,2645" -- Spirit Walk if Enhance
elseif GW.Classic then
    DODGEBAR_SPELLS["WARRIOR"] = "100" -- Charge
    DODGEBAR_SPELLS["HUNTER"] = "781" -- Disengage
    DODGEBAR_SPELLS["ROGUE"] = "2983" -- Sprint
    DODGEBAR_SPELLS["MAGE"] = "1953" -- Shimmer if talented, else Blink
    DODGEBAR_SPELLS["DRUID"] = "9821"
end

GwDodgeBarMixin = {}

function GwDodgeBarMixin:UpdateCooldown(durationObject)
    local statusbar = self.statusbar
    if not statusbar then return end

    if durationObject then
        statusbar:SetTimerDuration(durationObject, Enum.StatusBarInterpolation.Immediate)
    end
end

function GwDodgeBarMixin:UpdateChargeText(currentCharges, maxCharges)
    local text = self.chargeText
    if not text then return end

    text:SetText(currentCharges)
    text:SetAlphaFromBoolean(self.hasCharges, 1, 0)
end

function GwDodgeBarMixin:SetBarProgress(progress)
    local statusbar = self.statusbar
    if not statusbar then return end

    statusbar:SetValue(progress, Enum.StatusBarInterpolation.Immediate)
end

function GwDodgeBarMixin:InitBar(pew)
    -- do everything required to make the dodge bar a secure clickable button
    local overrideSpellID = GW.private.PLAYER_TRACKED_DODGEBAR_SPELL_ID
    self.hasCharges = false
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
    local currentCharges = spellChargeInfo and spellChargeInfo.currentCharges
    local maxCharges = spellChargeInfo and spellChargeInfo.maxCharges
    self.hasCharges = maxCharges and maxCharges > 1
    self:UpdateChargeText(currentCharges, maxCharges)

    local durationObject
    if self.hasCharges then
        durationObject = C_Spell.GetSpellChargeDuration(self.spellId)
    elseif C_Spell.GetSpellCooldownDuration then
        durationObject = C_Spell.GetSpellCooldownDuration(self.spellId)
    end
    if durationObject then
        self:UpdateCooldown(durationObject)
    else
        self:SetBarProgress(1)
    end
end

function GwDodgeBarMixin:OnEvent(event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- we don't track anything until we first see our dodge skill cast
        local spellId = select(3, ...)
        if spellId ~= self.spellId then return end
        if self.hasCharges then
            self:RegisterEvent("SPELL_UPDATE_CHARGES")
        else
            self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        -- only registered when our dodge skill is actively on cooldown
        if not GW.inWorld or not self.spellId then return end
        local durationObject = C_Spell.GetSpellCooldownDuration(self.spellId)
        if durationObject then
            self:UpdateCooldown(durationObject)
        else
            self:SetBarProgress(1)
        end
    elseif event == "SPELL_UPDATE_CHARGES" then
        -- only registered when our dodge skill is actively on cooldown
        if not GW.inWorld or not self.spellId then return end
        local spellChargeInfo = C_Spell.GetSpellCharges(self.spellId)
        local durationObject = C_Spell.GetSpellChargeDuration(self.spellId)
        local currentCharges = spellChargeInfo and spellChargeInfo.currentCharges or nil
        local maxCharges = spellChargeInfo and spellChargeInfo.maxCharges or nil
        self:UpdateChargeText(currentCharges, maxCharges)
        if durationObject then
            self:UpdateCooldown(durationObject)
        else
            self:SetBarProgress(1)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- do the stuff that must be done before combat lockdown takes effect
        self:InitBar(true)
    elseif event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "LEARNED_SPELL_IN_TAB" then
        -- do remaining spell detail stuff that is (usually) not available yet in PEW or if we are not in world
        if event ~= "LEARNED_SPELL_IN_TAB" and (not GW.inWorld or not self.spellId) then return end
        -- add a delay because spell infos sometimes not ready
        C_Timer.After(0.33, function()
            self:InitBar(false)
            self:SetupBar()
        end)
    end
end

function GwDodgeBarMixin:OnEnter(_, override)
    local bar = override and self or self.skyringingBarShown and self.skyrindingBar or self

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

function GwDodgeBarMixin:OnLeave()
    GameTooltip_Hide()
end

local function LoadDodgeBar(parent, asTargetFrame)
    Debug("LoadDodgeBar start")

    -- this bar gets a global name for use in key bindings
    local fmdb = CreateFrame("Button", "GwDodgeBar", UIParent, "GwDodgeBarRetailTmpl")
    fmdb.asTargetFrame = asTargetFrame
    fmdb:RegisterForClicks("AnyUp", "AnyDown")
    if fmdb.asTargetFrame then
        parent.dodgebar = fmdb
        fmdb.arcfill:SetSize(80, 72)
        fmdb.arcfill.mask_normal:SetSize(80, 72)
        fmdb.arcfill.maskr_normal:SetSize(80, 72)
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
    fmdb.chargeText:SetPoint("CENTER", fmdb.statusbar, "CENTER", 0, 48)
    fmdb.chargeText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -2)
    fmdb.chargeText:SetShadowColor(0, 0, 0, 1)
    fmdb.chargeText:SetShadowOffset(1, -1)
    fmdb.chargeText:SetTextColor(1.0, 0.95, 0.8, 0.85)
    fmdb.chargeText:Show()


    -- setup dodgebar event handling
    fmdb.skyringingBarShown = false
    fmdb:OnLeave(nil, true)
    fmdb:SetScript("OnEnter", fmdb.OnEnter)
    fmdb:SetScript("OnLeave", fmdb.OnLeave)
    fmdb:SetScript("OnEvent", fmdb.OnEvent)
    fmdb:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    fmdb:RegisterEvent("SPELLS_CHANGED")
    fmdb:RegisterEvent("PLAYER_ENTERING_WORLD")
    fmdb:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    if not GW.Retail then
        fmdb:RegisterEvent("LEARNED_SPELL_IN_TAB")
    end

    -- setup hook to hide the dodge bar when in vehicle/override UI
    MixinHideDuringPetAndOverride(fmdb)

    Debug("LoadDodgeBar done")
    if GW.Retail then
        --fmdb:LoadSkiridingBar(parent)
    end
    return fmdb
end
GW.LoadDodgeBar = LoadDodgeBar
