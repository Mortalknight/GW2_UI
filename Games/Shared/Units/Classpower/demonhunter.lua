---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- DEMON HUNTER (havoc Metamorphosis tracker, void metamorphosis counter)
if GW.myClassID ~= GW.Enum.ClassIndex.Demonhunter or not GW.Retail then return end

local function voidMetamorphosisUpdatePower(self)
    self.defaultResourceBar:SetMinMaxValues(0, self.maxPoints)
    -- the counter text is a tag of the text designer
    self.defaultResourceBar:SetValue(self.currentPoints, Enum.StatusBarInterpolation.ExponentialEaseOut)
end

local function VoidMetamorphosisGetCurrentMinMaxPower(self)
	if self.inVoidMetamorphosis then
		self.maxPoints = GetCollapsingStarCost()
	else
		self.maxPoints = C_Spell.GetSpellMaxCumulativeAuraApplications(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID)
	end
end

-- the counter of a devourer, also read by the text tag of the class bar
local function GetVoidMetamorphosisPoints()
    local ids = Constants.UnitPowerSpellIDs
    local inVoid = C_UnitAuras.GetPlayerAuraBySpellID(ids.VOID_METAMORPHOSIS_SPELL_ID) ~= nil
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(inVoid and ids.SILENCE_THE_WHISPERS_SPELL_ID or ids.DARK_HEART_SPELL_ID)
    return inVoid, aura and aura.applications or 0
end
CP.GetVoidMetamorphosisPoints = GetVoidMetamorphosisPoints

local function counterVoidMetamorphosis(self)
    self.inVoidMetamorphosis, self.currentPoints = GetVoidMetamorphosisPoints()
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
