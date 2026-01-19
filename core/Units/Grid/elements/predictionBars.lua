local _, GW = ...

local function Construct_PredictionBar(frame)
    local healingAll = CreateFrame("StatusBar", nil, frame.Health)
    healingAll:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    healingAll:SetPoint('TOP')
    healingAll:SetPoint('BOTTOM')
    healingAll:SetPoint('LEFT', frame.Health:GetStatusBarTexture(), 'RIGHT')
    healingAll:SetStatusBarColor(0.58431,0.9372,0.2980,0.60)

    local damageAbsorb = CreateFrame('StatusBar', nil, frame.Health)
    damageAbsorb:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
    damageAbsorb:SetStatusBarColor(1,1,1,0.66)
    damageAbsorb:SetPoint('TOP')
    damageAbsorb:SetPoint('BOTTOM')
    damageAbsorb:SetPoint('LEFT', healingAll:GetStatusBarTexture(), 'RIGHT')

    local healAbsorb = CreateFrame('StatusBar', nil, frame.Health)
    healAbsorb:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
    healAbsorb:SetPoint('TOP')
    healAbsorb:SetPoint('BOTTOM')
    healAbsorb:SetPoint('RIGHT', frame.Health:GetStatusBarTexture())
    healAbsorb:SetReverseFill(true)

    local overDamageAbsorbIndicator = frame.Health:CreateTexture(nil, "OVERLAY")
    overDamageAbsorbIndicator:SetTexture("Interface/RaidFrame/Shield-Overshield")
    overDamageAbsorbIndicator:SetBlendMode("ADD")
    overDamageAbsorbIndicator:SetPoint('TOP')
    overDamageAbsorbIndicator:SetPoint('BOTTOM')
    overDamageAbsorbIndicator:SetPoint('LEFT', frame.Health, 'RIGHT', -8, 0)
    overDamageAbsorbIndicator:SetWidth(16)

    -- Register with oUF
    frame.HealthPrediction = {
        healingAll = healingAll,
        damageAbsorb = damageAbsorb,
        healAbsorb = healAbsorb,
        overDamageAbsorbIndicator = overDamageAbsorbIndicator,
        maxOverflow = 1,
        incomingHealOverflow = 1,
    }
    if GW.Retail then
        frame.HealthPrediction.damageAbsorbClampMode = Enum.UnitDamageAbsorbClampMode.MissingHealth
        frame.HealthPrediction.healAbsorbClampMode = Enum.UnitHealAbsorbClampMode.CurrentHealth
        frame.HealthPrediction.healAbsorbMode = Enum.UnitHealAbsorbMode.ReducedByIncomingHeals
        frame.HealthPrediction.incomingHealClampMode = Enum.UnitIncomingHealClampMode.MissingHealth
    end
end
GW.Construct_PredictionBar = Construct_PredictionBar

local function Update_PredictionBars(frame)
    --nothing atm
end
GW.Update_PredictionBars = Update_PredictionBars
