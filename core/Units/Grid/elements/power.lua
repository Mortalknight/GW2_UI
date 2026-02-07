local _, GW = ...
local PowerBarColorCustom = GW.PowerBarColorCustom

local tokens = {[0]='MANA','RAGE','FOCUS','ENERGY','RUNIC_POWER'}
local function GetRandomPowerColor()
    local color = PowerBarColorCustom[tokens[random(0,4)]]
    return color
end

local function GetRole(frame)
    if frame.isForced then
		local rnd = random(1, 3)
		return (rnd == 1 and 'TANK') or (rnd == 2 and 'HEALER') or 'DAMAGER'
	else
		return GW.allowRoles and UnitGroupRolesAssigned(frame.unit)
	end
end

local function PostUpdatePower(self)
    local parent = self.origParent or self:GetParent()
    if parent.isForced then
        self.cur = self.fakeValue or random(1, 100)
        self.max = 100
        self:SetMinMaxValues(0, self.max)
        self:SetValue(self.cur)
        self.fakeValue = self.cur
    else
        self.fakeValue = nil
    end
end

local function PostUpdatePowerColor(self, unit)
    local parent = self.origParent or self:GetParent()
    if parent.isForced then
        local color = self.fakeToken or GetRandomPowerColor()
        self:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
        self.fakeToken = color
    else
        local _, powerToken = UnitPowerType(unit)
        if PowerBarColorCustom[powerToken] then
            local pwcolor = PowerBarColorCustom[powerToken]
            self:GetStatusBarTexture():SetVertexColor(pwcolor.r, pwcolor.g, pwcolor.b)
        end
        self.fakeToken = nil
    end

    local onlyHealer = parent.showResscoureBar == "HEALER"
    local all = parent.showResscoureBar == "ALL"

    if all or (onlyHealer and GetRole(parent) == "HEALER") then
        self:Show()
    else
        self:Hide()
    end
end

local function Construct_PowerBar(frame)
    local power = CreateFrame('StatusBar', '$parent_PowerBar', frame)

    power:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
    power.PostUpdate = PostUpdatePower
    power.PostUpdateColor = PostUpdatePowerColor

    power:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

    power.bg = power:CreateTexture(nil, 'BORDER')
    power.bg:SetPoint("TOPLEFT", -1, 1)
    power.bg:SetPoint("BOTTOMRIGHT", 1, -1)
    power.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    power.bg:SetVertexColor(0, 0, 0, 1)

	power.useAtlas = false
	power.colorDisconnected = false
	power.colorTapping = false
    power.smoothing = Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut or nil

	return power
end
GW.Construct_PowerBar = Construct_PowerBar

local function Update_Powerbar(frame)
    local power = frame.Power
    power.origParent = frame
    power:SetHeight(3)
    power:ClearAllPoints()
    power:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    power:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    if not power.origParent.isForced then
        power.fakeToken = nil
    end
end
GW.Update_Powerbar = Update_Powerbar