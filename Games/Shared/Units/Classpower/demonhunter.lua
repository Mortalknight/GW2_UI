---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- DEMON HUNTER (havoc Metamorphosis tracker, void metamorphosis counter)
if GW.myClassID ~= GW.Enum.ClassIndex.Demonhunter or not GW.Retail then return end

local function voidMetamorphosisUpdatePower(self)
    self.defaultResourceBar:SetMinMaxValues(0, self.maxPoints)
    self.defaultResourceBar:SetValue(self.currentPoints, Enum.StatusBarInterpolation.ExponentialEaseOut)
    if GW.settings.CLASSPOWER_SHOW_VALUE then
        self.defaultResourceBar.label:SetText(self.currentPoints)
    else
        self.defaultResourceBar.label:SetText("")
    end
end

local function VoidMetamorphosisGetCurrentMinMaxPower(self)
	if self.inVoidMetamorphosis then
		self.maxPoints = GetCollapsingStarCost()
	else
		self.maxPoints = C_Spell.GetSpellMaxCumulativeAuraApplications(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID)
	end
end

local function counterVoidMetamorphosis(self)
    local inVoidMetamorphosis = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID)
    self.currentPoints = 0

    if inVoidMetamorphosis then
        local silenceTheWhispersAura = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.SILENCE_THE_WHISPERS_SPELL_ID)
        if silenceTheWhispersAura then
			self.currentPoints = silenceTheWhispersAura.applications;
		end
    else
        local darkHeartAura = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID)
		if darkHeartAura then
			self.currentPoints = darkHeartAura.applications;
		end
    end

    VoidMetamorphosisGetCurrentMinMaxPower(self)
    voidMetamorphosisUpdatePower(self)
end

local function setDeamonHunter(f)
    if GW.myspec == 1 then -- havoc: Metamorphosis remaining time
        CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
        f:SetWidth(313)
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)

        local tracker = CP.EnableAuraTracker(f, "HavocMeta", {
            unit = "player",
            filter = "HELPFUL",
            spellIDs = { [162264] = true, [187827] = true },
            width = 313,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "fury", "furyspark", false, true) end,
        })
        tracker:ClearAllPoints()
        tracker:SetPoint("LEFT", f, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -11 or 0)

        return true
    elseif GW.myspec == 3 then
        CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
        CP.setPowerTypeMeta(f.defaultResourceBar, true)
        f.defaultResourceBar:SetWidth(313)
        f:SetWidth(f.defaultResourceBar:GetWidth())
        f.defaultResourceBar:ClearAllPoints()
        f.defaultResourceBar:SetPoint("LEFT", f, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -11 or 0)
        f.defaultResourceBar:Show()
        f.background:SetTexture(nil)
        f.fill:SetTexture(nil)

        f:SetScript("OnEvent", counterVoidMetamorphosis)
        counterVoidMetamorphosis(f)
        f:RegisterUnitEvent("UNIT_AURA", "player")

        return true
    end

    return false
end

CP.setups[GW.Enum.ClassIndex.Demonhunter] = setDeamonHunter
