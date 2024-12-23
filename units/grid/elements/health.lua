local _, GW = ...

local function UnitClassRnd(unit)
    if unit:find('target') or unit:find('focus') then
        return UnitClass(unit)
    end

    local classToken = CLASS_SORT_ORDER[random(1, #(CLASS_SORT_ORDER))]
    return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken
end

local function PostUpdateHealth(self)
    local parent = self:GetParent():GetParent():GetParent()
    if parent.isForced then
        self.cur = self.fakeValue or random(1, 100)
        self.max = 100
        self:ForceFillAmount(self.cur / self.max)
        self.fakeValue = self.cur
    else
        self.fakeValue = nil
    end

end

local function PostUpdateHealthColor(self, unit)
    local parent = self:GetParent():GetParent():GetParent()

    if parent.isForced then
        if parent.useClassColor then
            --if we are here we need to class color the frame
            local _, englishClass = UnitClassRnd(unit)
            local color = self.fakeColor or GW.GWGetClassColor(englishClass, true)
            self:SetStatusBarColor(color.r, color.g, color.b)
            self.fakeColor = color
        end
    else
        self.fakeColor = nil
    end

    self.bg:SetVertexColor(0, 0, 0, 1)
end

local function UpdateHealthOverride(self, event, unit)
    if (self.isForced and event ~= 'Gw2_UpdateAllElements') then return end -- GW2 changed
    if(not unit or self.unit ~= unit) then return end
    local element = self.Health

    if(element.PreUpdate) then
        element:PreUpdate(unit)
    end

    local cur, max = UnitHealth(unit), UnitHealthMax(unit)

    if not self.Forced then
        element:SetFillAmount(cur/max)
    else
        element:ForceFillAmount(cur/max)
    end
    element.cur = cur
    element.max = max

    if(element.PostUpdate) then
        element:PostUpdate(unit, cur, max)
    end
end

local function Construct_HealthBar(frame)
    local healthPredictionbar = GW.createNewStatusbar('$parent_HealthPredictionBar', frame, "GwStatusBarBarNoAnchorNoSize", false)
    healthPredictionbar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    healthPredictionbar:SetPoint('TOPLEFT', frame, "TOPLEFT")
    healthPredictionbar:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT')
    healthPredictionbar:SetMinMaxValues(0, 1)
    healthPredictionbar:SetFrameLevel(10) --Make room for Portrait and Power which should be lower by default
    healthPredictionbar.customMaskSize = 32
    healthPredictionbar.strechMask = true
    healthPredictionbar:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    local absorbBar = GW.createNewStatusbar('$parent_AbsorbBar', healthPredictionbar, "GwStatusBarBarNoAnchorNoSize", true)
    absorbBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb")
    absorbBar:SetPoint('TOPLEFT', healthPredictionbar, "TOPLEFT")
    absorbBar:SetPoint('BOTTOMRIGHT', healthPredictionbar, 'BOTTOMRIGHT')
    absorbBar:SetMinMaxValues(0, 1)
    absorbBar.customMaskSize = 32
    absorbBar.strechMask = true
    absorbBar:SetStatusBarColor(1,1,1,0.66)

    local health = GW.createNewStatusbar('$parent_HealthBar', absorbBar, "GwStatusBarBarNoAnchorNoSize", true)
    health:SetPoint('TOPLEFT', absorbBar, "TOPLEFT")
    health:SetPoint('BOTTOMRIGHT', absorbBar, 'BOTTOMRIGHT')
    health:SetMinMaxValues(0, 1)
    health.customMaskSize = 32
    health.strechMask = true

    local healAbsorbBar = GW.createNewStatusbar('$parent_AntiHealBar', health, "GwStatusBarBarNoAnchorNoSize", true)
    healAbsorbBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal")
    healAbsorbBar:SetPoint('TOPLEFT', health, "TOPLEFT")
    healAbsorbBar:SetPoint('BOTTOMRIGHT', health, 'BOTTOMRIGHT')
    healAbsorbBar:SetMinMaxValues(0, 1)
    healAbsorbBar.customMaskSize = 32
    healAbsorbBar.strechMask = true

    local overAbsorb = GW.createNewStatusbar('$parent_AbsorbOverlayHealBar', healAbsorbBar, "GwStatusBarBarNoAnchorNoSize", true)
    overAbsorb:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb")
    overAbsorb:SetPoint('TOPLEFT', healAbsorbBar, "TOPLEFT")
    overAbsorb:SetPoint('BOTTOMRIGHT', healAbsorbBar, 'BOTTOMRIGHT')
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

    health.bg = frame:CreateTexture(nil, 'BORDER')
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

    health.healthPredictionbar = healthPredictionbar

    health.Override = UpdateHealthOverride
    health.PostUpdateColor = PostUpdateHealthColor
    health.PostUpdate = PostUpdateHealth

    return health
end
GW.Construct_HealthBar = Construct_HealthBar

local function Update_Healtbar(frame)
    local health = frame.Health

    local w, h = frame:GetSize()
    health:SetSize(w, h)
    health.totalWidth = frame:GetWidth()
    health.totalHeight = frame:GetHeight()

    frame.HealthPrediction.healthPredictionbar.totalWidth = frame:GetWidth()
    frame.HealthPrediction.absorbBar.totalWidth = frame:GetWidth()
    frame.HealthPrediction.healAbsorbBar.totalWidth = frame:GetWidth()
    frame.HealthPrediction.overAbsorb.totalWidth = frame:GetWidth()

    frame.HealthPrediction.healthPredictionbar.totalHeight = frame:GetHeight()
    frame.HealthPrediction.absorbBar.totalHeight = frame:GetHeight()
    frame.HealthPrediction.healAbsorbBar.totalHeight = frame:GetHeight()
    frame.HealthPrediction.overAbsorb.totalHeight = frame:GetHeight()

    health:SetSize(w, h)
    frame.HealthPrediction.healthPredictionbar:SetSize(w, h)
    frame.HealthPrediction.absorbBar:SetSize(w, h)
    frame.HealthPrediction.healAbsorbBar:SetSize(w, h)
    frame.HealthPrediction.overAbsorb:SetSize(w, h)

    frame.HealthPrediction.healthPredictionbar:UpdateBarSize()
    frame.HealthPrediction.absorbBar:UpdateBarSize()
    frame.HealthPrediction.healAbsorbBar:UpdateBarSize()
    frame.HealthPrediction.overAbsorb:UpdateBarSize()

    --settings
    health.statusBarColor = health.statusBarColor or {}
    health.colorClass = frame.useClassColor
    health.colorDisconnected = true

    if not frame.useClassColor then
        health.colorHealth = true
    end

    if not frame.isForced then
        health.fakeColor = nil
        health.fakeValue = nil
    end
end
GW.Update_Healtbar = Update_Healtbar