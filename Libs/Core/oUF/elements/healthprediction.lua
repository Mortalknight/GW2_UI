--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

myBar          - A `StatusBar` used to represent incoming heals from the player.
otherBar       - A `StatusBar` used to represent incoming heals from others.
absorbBar      - A `StatusBar` used to represent damage absorbs.
healAbsorbBar  - A `StatusBar` used to represent heal absorbs.
overAbsorb     - A `Texture` used to signify that the amount of damage absorb is greater than either the unit's missing
                 health or the unit's maximum health, if .showRawAbsorb is enabled.
overHealAbsorb - A `Texture` used to signify that the amount of heal absorb is greater than the unit's current health.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.maxOverflow   - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                 Defaults to 1.05 (number)
.showRawAbsorb - Makes the element show the raw amount of damage absorb (boolean)

## Examples

    -- Position and size
    local myBar = CreateFrame('StatusBar', nil, self.Health)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    myBar:SetWidth(200)

    local otherBar = CreateFrame('StatusBar', nil, self.Health)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), 'RIGHT')
    otherBar:SetWidth(200)

    local absorbBar = CreateFrame('StatusBar', nil, self.Health)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetPoint('LEFT', otherBar:GetStatusBarTexture(), 'RIGHT')
    absorbBar:SetWidth(200)

    local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
    healAbsorbBar:SetPoint('TOP')
    healAbsorbBar:SetPoint('BOTTOM')
    healAbsorbBar:SetPoint('RIGHT', self.Health:GetStatusBarTexture())
    healAbsorbBar:SetWidth(200)
    healAbsorbBar:SetReverseFill(true)

    local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
    overAbsorb:SetPoint('TOP')
    overAbsorb:SetPoint('BOTTOM')
    overAbsorb:SetPoint('LEFT', self.Health, 'RIGHT')
    overAbsorb:SetWidth(10)

	local overHealAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
    overHealAbsorb:SetPoint('TOP')
    overHealAbsorb:SetPoint('BOTTOM')
    overHealAbsorb:SetPoint('RIGHT', self.Health, 'LEFT')
    overHealAbsorb:SetWidth(10)

    -- Register with oUF
    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        absorbBar = absorbBar,
        healAbsorbBar = healAbsorbBar,
        overAbsorb = overAbsorb,
        overHealAbsorb = overHealAbsorb,
        maxOverflow = 1.05,
    }
--]]

local _, ns = ...
local oUF = ns.oUF

local function UpdateSize(self, event, unit)
	local element = self.HealthPrediction

	if(element.healingAll) then
		element.healingAll[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingAll, element.size)
	end

	if(element.healingPlayer) then
		element.healingPlayer[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingPlayer, element.size)
	end

	if(element.healingOther) then
		element.healingOther[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingOther, element.size)
	end

	if(element.damageAbsorb) then
		element.damageAbsorb[element.isHoriz and 'SetWidth' or 'SetHeight'](element.damageAbsorb, element.size)
	end

	if(element.healAbsorb) then
		element.healAbsorb[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healAbsorb, element.size)
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.HealthPrediction

	--[[ Callback: HealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local allHeal, playerHeal, otherHeal, healClamped
	local damageAbsorbAmount, damageAbsorbClamped = 0, false
	local healAbsorbAmount
	if ns.Retail then
		UnitGetDetailedHealPrediction(unit, 'player', element.values)

		allHeal, playerHeal, otherHeal, healClamped = element.values:GetIncomingHeals()
		if self.showAbsorbBar  then
			damageAbsorbAmount, damageAbsorbClamped = element.values:GetDamageAbsorbs()
		end

		healAbsorbAmount = element.values:GetHealAbsorbs()

		if(element.overDamageAbsorbIndicator) then
			element.overDamageAbsorbIndicator:SetAlphaFromBoolean(damageAbsorbClamped, 1, 0)
		end

		if(element.overHealIndicator) then
			element.overHealIndicator:SetAlphaFromBoolean(healClamped, 1, 0)
		end

	else
		allHeal = UnitGetIncomingHeals(unit) or 0
		damageAbsorbAmount = (self.showAbsorbBar and UnitGetTotalAbsorbs and UnitGetTotalAbsorbs(unit)) or 0 --GW2 change
		healAbsorbAmount = UnitGetTotalHealAbsorbs and UnitGetTotalHealAbsorbs(unit) or 0

		if allHeal > 0 then
			if (allHeal + health) > maxHealth then
				allHeal = maxHealth - health
			end
		end

		if damageAbsorbAmount > 0 then
			if (allHeal + health + damageAbsorbAmount) > maxHealth then
				damageAbsorbAmount = maxHealth - health - allHeal
				damageAbsorbClamped = true
			end
		end

		if(element.overDamageAbsorbIndicator) then
			if(damageAbsorbClamped) then
				element.overDamageAbsorbIndicator:Show()
			else
				element.overDamageAbsorbIndicator:Hide()
			end
		end
	end

	if(element.healingAll) then
		element.healingAll:SetMinMaxValues(0, maxHealth)
		element.healingAll:SetValue(allHeal)
	end

	if(element.healingOther) then
		element.healingOther:SetMinMaxValues(0, maxHealth)
		element.healingOther:SetValue(otherHeal)
	end

	if(element.damageAbsorb and self.showAbsorbBar) then
		element.damageAbsorb:SetMinMaxValues(0, maxHealth)
		element.damageAbsorb:SetValue(damageAbsorbAmount)
	end

	if(element.healAbsorb) then
		element.healAbsorb:SetMinMaxValues(0, maxHealth)
		element.healAbsorb:SetValue(healAbsorbAmount)
	end


	--[[ Callback: HealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	Called after the element has been updated.

	* self              - the HealthPrediction element
	* unit              - the unit for which the update has been triggered (string)
	* myIncomingHeal    - the amount of incoming healing done by the player (number)
	* otherIncomingHeal - the amount of incoming healing done by others (number)
	* absorb            - the amount of damage the unit can absorb without losing health (number)
	* healAbsorb        - the amount of healing the unit can absorb without gaining health (number)
	* hasOverAbsorb     - indicates if the amount of damage absorb is higher than either the unit's missing health or the unit's maximum health, if .showRawAbsorb is enabled (boolean)
	* hasOverHealAbsorb - indicates if the amount of heal absorb is higher than the unit's current health (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	end
end

local function shouldUpdateSize(self)
	if(not self.Health) then return end

	local isHoriz = self.Health:GetOrientation() == 'HORIZONTAL'
	local newSize = self.Health[isHoriz and 'GetWidth' or 'GetHeight'](self.Health)
	if(isHoriz ~= self.HealthPrediction.isHoriz or newSize ~= self.HealthPrediction.size) then
		self.HealthPrediction.isHoriz = isHoriz
		self.HealthPrediction.size = newSize

		return true
	end
end

local function Path(self, ...)
	--[[ Override: HealthPrediction.UpdateSize(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' size.
	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	if(shouldUpdateSize(self)) then
		(self.HealthPrediction.UpdateSize or UpdateSize) (self, ...)
	end
	--[[ Override: HealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.HealthPrediction.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	element.isHoriz = nil
	element.size = nil

	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.HealthPrediction
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if ns.Retail then
			if(element.values) then
				element.values:Reset()
			else
				element.values = CreateUnitHealPredictionCalculator()
			end

			if(element.damageAbsorbClampMode) then
				element.values:SetDamageAbsorbClampMode(element.damageAbsorbClampMode)
			end

			if(element.healAbsorbClampMode) then
				element.values:SetHealAbsorbClampMode(element.healAbsorbClampMode)
			end

			if(element.healAbsorbMode) then
				element.values:SetHealAbsorbMode(element.healAbsorbMode)
			end

			if(element.incomingHealClampMode) then
				element.values:SetIncomingHealClampMode(element.incomingHealClampMode)
			end

			if(element.incomingHealOverflow) then
				element.values:SetIncomingHealOverflowPercent(element.incomingHealOverflow)
			end
		end

		self:RegisterEvent('UNIT_HEALTH', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)

		if oUF.isClassic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		if oUF.isRetail or oUF.isMists then
			self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
			self:RegisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
			self:RegisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
		end


		if(element.healingAll) then
			if(element.healingAll:IsObjectType('StatusBar') and not element.healingAll:GetStatusBarTexture()) then
				element.healingAll:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healingPlayer) then
			if(element.healingPlayer:IsObjectType('StatusBar') and not element.healingPlayer:GetStatusBarTexture()) then
				element.healingPlayer:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healingOther) then
			if(element.healingOther:IsObjectType('StatusBar') and not element.healingOther:GetStatusBarTexture()) then
				element.healingOther:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.overHealIndicator) then
			if(element.overHealIndicator:IsObjectType('Texture') and not element.overHealIndicator:GetTexture()) then
				element.overHealIndicator:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overHealIndicator:SetBlendMode('ADD')
			end
		end

		if(element.damageAbsorb) then
			if(element.damageAbsorb:IsObjectType('StatusBar') and not element.damageAbsorb:GetStatusBarTexture()) then
				element.damageAbsorb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healAbsorb) then
			if(element.healAbsorb:IsObjectType('StatusBar') and not element.healAbsorb:GetStatusBarTexture()) then
				element.healAbsorb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.overDamageAbsorbIndicator) then
			if(element.overDamageAbsorbIndicator:IsObjectType('Texture') and not element.overDamageAbsorbIndicator:GetTexture()) then
				element.overDamageAbsorbIndicator:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overDamageAbsorbIndicator:SetBlendMode('ADD')
			end
		end

		if(element.overHealAbsorbIndicator) then
			if(element.overHealAbsorbIndicator:IsObjectType('Texture') and not element.overHealAbsorbIndicator:GetTexture()) then
				element.overHealAbsorbIndicator:SetTexture([[Interface\RaidFrame\Absorb-Overabsorb]])
				element.overHealAbsorbIndicator:SetBlendMode('ADD')
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.HealthPrediction
	if(element) then
		if(element.healingAll) then
			element.healingAll:Hide()
		end

		if(element.healingPlayer) then
			element.healingPlayer:Hide()
		end

		if(element.healingOther) then
			element.healingOther:Hide()
		end

		if(element.overHealIndicator) then
			element.overHealIndicator:Hide()
		end

		if(element.damageAbsorb) then
			element.damageAbsorb:Hide()
		end

		if(element.healAbsorb) then
			element.healAbsorb:Hide()
		end

		if(element.overDamageAbsorbIndicator) then
			element.overDamageAbsorbIndicator:Hide()
		end

		if(element.overHealAbsorbIndicator) then
			element.overHealAbsorbIndicator:Hide()
		end

		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)

		if oUF.isClassic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		if oUF.isRetail or oUF.isMists then
			self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
			self:UnregisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
			self:UnregisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
		end
	end
end

oUF:AddElement('HealthPrediction', Path, Enable, Disable)
