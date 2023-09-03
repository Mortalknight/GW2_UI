local _, GW = ...
local PowerBarColorCustom = GW.PowerBarColorCustom

local function PostUpdatePower(self, unit)
    local _, powerToken = UnitPowerType(unit)
    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end
end

local function Construct_PowerBar(frame)
    local power = CreateFrame('StatusBar', '$parent_PowerBar', frame)

    power:SetFrameLevel(11) --Make room for Portrait and Power which should be lower by default
    power.PostUpdate = PostUpdatePower

    power:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")

    power.bg = power:CreateTexture(nil, 'BORDER')
    power.bg:SetPoint("TOPLEFT", 0, 1)
    power.bg:SetPoint("BOTTOMRIGHT", 0, 0)
    power.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    power.bg:SetVertexColor(0, 0, 0, 1)
    power.bg.multiplier = 1

	power.useAtlas = false
	power.colorDisconnected = false
	power.colorTapping = false

	return power
end
GW.Construct_PowerBar = Construct_PowerBar

local function Update_Powerbar(frame)
    local power = frame.Power
    power:SetHeight(3)
    power:ClearAllPoints()
    power:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    power:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    power:SetShown(frame.showResscoureBar)
end
GW.Update_Powerbar = Update_Powerbar