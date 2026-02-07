local _, GW = ...

local function UnitClassRnd(unit)
    if unit:find('target') or unit:find('focus') then
        return UnitClass(unit)
    end

    local classToken = CLASS_SORT_ORDER[random(1, #(CLASS_SORT_ORDER))]
    return LOCALIZED_CLASS_NAMES_MALE[classToken], classToken
end

local function PostUpdateHealth(self)
    local parent = self:GetParent()
    if parent.isForced then
        self.cur = self.fakeValue or random(1, 100)
        self:SetMinMaxValues(0, 100)
        self:SetValue(self.cur)
        self.fakeValue = self.cur
    else
        self.fakeValue = nil
    end
end

local function PostUpdateHealthColor(self, unit)
    local parent = self:GetParent()

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
end


local function Construct_HealthBar(frame)
    local health = CreateFrame("StatusBar", nil, frame)
    health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
    health:SetPoint('TOP')
    health:SetPoint('LEFT')
    health:SetPoint('RIGHT')
    health:SetFrameLevel(10)

    health.PostUpdateColor = PostUpdateHealthColor
    health.PostUpdate = PostUpdateHealth
    health.smoothing = Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut or nil

    frame.bg = frame:CreateTexture(nil, 'BORDER')
    frame.bg:SetPoint("TOPLEFT", -1, 1)
    frame.bg:SetPoint("BOTTOMRIGHT", 1, -1)
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    frame.bg:SetVertexColor(0, 0, 0, 1)

    frame:GwCreateBackdrop({
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
            bgFile = "",
            edgeSize = GW.Scale(1)
        })
    frame.highlightBorder = frame.backdrop
    frame.backdrop:OffsetFrameLevel(health:GetFrameLevel() + 1, frame)
    frame.backdrop:ClearAllPoints()
    frame.backdrop:SetPoint("TOPLEFT", -1, 1)
    frame.backdrop:SetPoint("BOTTOMRIGHT", 1, -1)

    return health
end
GW.Construct_HealthBar = Construct_HealthBar

local function Update_Healtbar(frame)
    local health = frame.Health

    --settings
    health.statusBarColor = health.statusBarColor or {}
    health.colorClass = frame.useClassColor
    health.colorDisconnected = true
    health.showAbsorbBar = frame.showAbsorbBar

    if not frame.useClassColor then
        health.colorHealth = true
    end

    if not frame.isForced then
        health.fakeColor = nil
        health.fakeValue = nil
    end
end
GW.Update_Healtbar = Update_Healtbar