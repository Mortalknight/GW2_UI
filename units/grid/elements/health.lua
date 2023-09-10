local _, GW = ...

local function PostUpdateHealthColor(self, unit)
    local parent = self:GetParent():GetParent():GetParent()
    local color = {}

    if parent.useClassColor then
        local _, englishClass = UnitClass(unit)
        color = GW.GWGetClassColor(englishClass, true)
    else
        color = {r= 0.207, g = 0.392, b = 0.168}
    end

    if UnitIsConnected(unit) and (UnitPhaseReason(unit) or not UnitInRange(unit)) then
        self:SetStatusBarColor(color.r * 0.3, color.g * 0.3, color.b * 0.3)
    end
end

local function UpdateHealthOverride(self, event, unit)
    if(not unit or self.unit ~= unit) then return end
	local element = self.Health

    if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
    element:SetFillAmount(cur/max)
    if cur == 0 then
        self.HealthValueText:SetTextColor(255, 0, 0)
    else
        self.HealthValueText:SetTextColor(1, 1, 1)
    end

    local color = {}
    if self.useClassColor then
        local _, englishClass = UnitClass(unit)
        color = GW.GWGetClassColor(englishClass, true)
    else
        color = {r= 0.207, g = 0.392, b = 0.168}
    end

    element:SetStatusBarColor(color.r, color.g, color.b, color.a)

	element.cur = cur
	element.max = max

    if(element.PostUpdate) then
		element:PostUpdate(unit, cur, max)
	end
end

local function Construct_HealthBar(frame)
    local healthPredictionbar = GW.createNewStatusbar('$parent_HealthPredictionBar', frame, "GwStatusBarBar", false)
    healthPredictionbar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    healthPredictionbar:SetPoint('TOPLEFT', frame, "TOPLEFT")
    healthPredictionbar:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT')
    healthPredictionbar:SetMinMaxValues(0, 1)
    healthPredictionbar:SetFrameLevel(10) --Make room for Portrait and Power which should be lower by default
    healthPredictionbar.customMaskSize = 32
    healthPredictionbar.strechMask = true
    healthPredictionbar:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    local absorbBar = GW.createNewStatusbar('$parent_AbsorbBar', healthPredictionbar, "GwStatusBarBar", true)
    absorbBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb")
    absorbBar:SetPoint('TOPLEFT', frame, "TOPLEFT")
    absorbBar:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT')
    absorbBar:SetMinMaxValues(0, 1)
    absorbBar.customMaskSize = 32
    absorbBar.strechMask = true
    absorbBar:SetStatusBarColor(1,1,1,0.66)

    local health = GW.createNewStatusbar('$parent_HealthBar', absorbBar, "GwStatusBarBar", true)
    health:SetPoint('TOPLEFT', frame, "TOPLEFT")
    health:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT')
    health:SetMinMaxValues(0, 1)
    health.customMaskSize = 32
    health.strechMask = true

    local healAbsorbBar = GW.createNewStatusbar('$parent_AntiHealBar', health, "GwStatusBarBar", true)
    healAbsorbBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal")
    healAbsorbBar:SetPoint('TOPLEFT', frame, "TOPLEFT")
    healAbsorbBar:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT')
    healAbsorbBar:SetMinMaxValues(0, 1)
    healAbsorbBar.customMaskSize = 32
    healAbsorbBar.strechMask = true

    local overAbsorb = GW.createNewStatusbar('$parent_AbsorbOverlayHealBar', healAbsorbBar, "GwStatusBarBar", true)
    overAbsorb:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb")
    overAbsorb:SetPoint('TOPLEFT', frame, "TOPLEFT")
    overAbsorb:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT')
    overAbsorb:SetMinMaxValues(0, 1)
    overAbsorb.customMaskSize = 32
    overAbsorb.strechMask = true
    overAbsorb:SetStatusBarColor(1,1,1,0.66)

    -- Register with oUF
    frame.HealthPrediction = {
        healthPredictionbar = healthPredictionbar,
        absorbBar = absorbBar,
        healAbsorbBar = healAbsorbBar,
        overAbsorb = overAbsorb,
        maxOverflow = 1,
    }

    health.bg = healthPredictionbar:CreateTexture(nil, 'BORDER')
    health.bg:SetPoint("TOPLEFT", 0, 0)
    health.bg:SetPoint("BOTTOMRIGHT", 0, 0)
    health.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    health.bg:SetVertexColor(0, 0, 0, 1)
    health.bg.multiplier = 1

    health.highlightBorder = frame:CreateTexture(nil, 'BORDER', nil, -7)
    health.highlightBorder:SetPoint("TOPLEFT", -1, 1)
    health.highlightBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    health.highlightBorder:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    health.highlightBorder:SetVertexColor(0, 0, 0, 1)
    health.highlightBorder.multiplier = 1

    health.Override = UpdateHealthOverride
	--health.PostUpdateColor = PostUpdateHealthColor

	return health
end
GW.Construct_HealthBar = Construct_HealthBar

local function Update_Healtbar(frame)
    local health = frame.Health

    health:ClearAllPoints()
    health:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    health:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
end
GW.Update_Healtbar = Update_Healtbar