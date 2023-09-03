local _, GW = ...

local function PostUpdateHealth(self, _, cur, max)
    self:SetFillAmount(cur/max)
end

local function PostUpdateHealthColor(self, unit)
    local parent = self:GetParent()
    local color = {}

    if parent.useClassColor then
        local _, englishClass = UnitClass(unit)
        color = GW.GWGetClassColor(englishClass, true)
    else
        color = {r= 0.207, g = 0.392, b = 0.168}
    end

    self:SetStatusBarColor(color.r, color.g, color.b, color.a)

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
    if cur == 0 then
        self.HealthValueText:SetTextColor(255, 0, 0)
    else
        self.HealthValueText:SetTextColor(1, 1, 1)
    end
	element.cur = cur
	element.max = max

    if(element.PostUpdate) then
		element:PostUpdate(unit, cur, max)
	end
end

local function Construct_HealthBar(frame)
    local health = GW.createNewStatusbar('$parent_HealthBar', frame, "GwStatusBarBar", true)

    health:SetFrameLevel(10) --Make room for Portrait and Power which should be lower by default
    health.Override = UpdateHealthOverride
	health.PostUpdate = PostUpdateHealth
	health.PostUpdateColor = PostUpdateHealthColor
    health:SetMinMaxValues(0, 1)

    health.bg = health:CreateTexture(nil, 'BORDER')
    health.bg:SetPoint("TOPLEFT", -1, 1)
    health.bg:SetPoint("BOTTOMRIGHT", 1, -1)
    health.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    health.bg:SetVertexColor(0, 0, 0, 1)
    health.bg.multiplier = 1

    health.customMaskSize = 32
    health.strechMask = true

	--health:GwCreateBackdrop(nil, nil, nil, nil, true)

	--local clipFrame = UF:Construct_ClipFrame(frame, health)
	--clipFrame:SetScript('OnUpdate', UF.HealthClipFrame_OnUpdate)

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