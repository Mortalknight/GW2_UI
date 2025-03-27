local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local lerpEaseOut = GW.lerpEaseOut
local lerp = GW.lerp
local numSpritesInAnimation = 254
local uniqueID = 0
local round = GW.RoundInt

local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max = math.max

--[[

Bar:SetFillAmount(amount)
    Sets the fill amount of the bar to bar, Animates over time if smooth was set when bar was created

Bar:ForceFillAmount(amount)
    always sets the bar value without animatiuon

Bar:GetFillAmount()
    returns the bars current fill amount. if animating returns the current animating value

bar.barOnUpdate (self)
    used for hooking custom onupdate function to the bars animation. triggers everytime bar value changes (if animated every frame during animation)

bar.speed
    used to set custom speed, default is 100 (pixels / second)


]]

GwAnimatedStatusBarMixin = {}

local BarAnimateTypes = {All = 1, Decay = 2, Regenerate = 3}
local BarInterpolation = {Ease = 1, Linear = 2}
GW.BarAnimateTypes = BarAnimateTypes

local function getAnimationDurationDynamic(self, val1, val2, width)
    width = width or 0
    local speed = self.speed or 500
    speed = max(0.0000001, speed * abs(val1 - val2))
    return (width * abs(val1 - val2)) / speed
end
function GwAnimatedStatusBarMixin:AddMask(mask)
    self.maskContainer.mask0:SetTexture("Interface/AddOns/GW2_UI/textures/hud/barmask/ramp/" .. mask)
end

function GwAnimatedStatusBarMixin:GetFillAmount()
    return self.fillAmount or 0
end

function GwAnimatedStatusBarMixin:SetFillAmount(value, forced)
    if self.smoothAnimation and not forced then
        self:FillBarSmooth(value)
        return
    end

    local orientation = self:GetOrientation()
    local isVertical = (orientation == "VERTICAL")
    local isReverseFill = self:GetReverseFill()
    local totalWidth = self.totalWidth or (isVertical and self:GetHeight() or self:GetWidth())
    local height = self.totalHeight or (isVertical and self:GetWidth() or self:GetHeight())

    -- fallback if width or height is 0
    if totalWidth == 0 then totalWidth = 1 end
    if height == 0 then height = 1 end

    local barWidth = totalWidth * value
    local stretchMask = self.strechMask or false
    local maskHeightValue = self.customMaskSize or 128

    self.fillAmount = value

    local numberOfSegments = totalWidth / maskHeightValue
    local numberOfSegmentsRound = ceil(numberOfSegments)
    local segmentSize = totalWidth / numberOfSegmentsRound
    local currentSegmentIndex = floor(numberOfSegmentsRound * value)
    local currentSegmentPosition = currentSegmentIndex * segmentSize
    local barPosition = ((currentSegmentIndex + 1) * segmentSize) / totalWidth
    local rampStartPoint = (segmentSize * currentSegmentIndex)
    local rampEndPoint = (segmentSize * (currentSegmentIndex + 1))
    local rampProgress = (barWidth - rampStartPoint) / (rampEndPoint - rampStartPoint)
    local interpolateRamp = lerp(numSpritesInAnimation, 0, rampProgress)
    local interpolateRampRound = round(interpolateRamp)

    if value == 0 then
        barPosition = 0
    end

    if stretchMask then
        if isVertical then
            self.maskContainer:SetSize(height, maskHeightValue)
        else
            self.maskContainer:SetSize(maskHeightValue, height)
        end
    else
        self.maskContainer:SetSize(segmentSize, segmentSize)
    end

    if self.spark then
        self.spark:Hide()
    end

    if not self.interpolateRampRound or interpolateRampRound ~= self.interpolateRampRound then
        self:AddMask(interpolateRampRound)

        if isVertical then
            self.maskContainer.mask0:SetSize(self.maskContainer:GetHeight(), self.maskContainer:GetWidth())
            self.maskOverflow.mask:SetSize(self.maskOverflow:GetHeight(), self.maskOverflow:GetWidth())
        end
        self.interpolateRampRound = interpolateRampRound
    end
    if self.fill_threshold ~= barPosition or forced then
        if isVertical then
            self.maskContainer:SetPoint("BOTTOM", self.internalBar, "BOTTOM", 0, currentSegmentPosition)
        elseif isReverseFill then
            self.maskContainer:SetPoint("RIGHT", self.internalBar, "RIGHT", -currentSegmentPosition, 0)
        else
            self.maskContainer:SetPoint("LEFT", self.internalBar, "LEFT", currentSegmentPosition, 0)
        end
        if not GW.IsNaN(barPosition) and not GW.IsInf(barPosition) then
            self:SetValue(barPosition)
        end
        self.fill_threshold = barPosition
    end
    if self.barOnUpdate then
        self.barOnUpdate(self)
    end
end

function GwAnimatedStatusBarMixin:BarUpdate(delta)
    self.animatedTime = self.animatedTime + delta
    local duration = max(0.00000001, self.animatedDuration)
    local animationProgress = self.animatedTime / duration
    local newValue = 0
    if self.BarInterpolation and self.BarInterpolation == BarInterpolation.Linear then
        newValue = lerp(self.animatedStartValue, self.animatedValue, animationProgress) -- LERP?
    else
        newValue = lerpEaseOut(self.animatedStartValue, self.animatedValue, animationProgress)
    end
    self:SetFillAmount(newValue, true)
    if self.onUpdateAnimation then
        self.onUpdateAnimation(self, animationProgress, delta)
    end
    if self.animatedTime >= self.animatedDuration then
        self:SetScript("OnUpdate", nil)
    end
end

function GwAnimatedStatusBarMixin:SetCustomAnimation(from, to, time)
    self.animatedValue = to
    self.animatedStartValue = from
    self.animatedTime = 0
    self.animatedDuration = time
    self.BarInterpolation = BarInterpolation.Linear

    if self.onAnimationStart ~= nil then
        self.onAnimationStart(self, to)
    end

    self:SetScript("OnUpdate", self.BarUpdate)
end

function GwAnimatedStatusBarMixin:FillBarSmooth(value)
    self.animatedValue = value
    self.animatedStartValue = self:GetFillAmount()
    self.animatedTime = 0
    self.animatedDuration = getAnimationDurationDynamic(self, self.animatedStartValue, self.animatedValue, self:GetWidth())

    if self.onAnimationStart then
        self.onAnimationStart(self, value)
    end

    if (self.animationType == BarAnimateTypes.Decay and self.animatedValue > self.animatedStartValue) or
        (self.animationType == BarAnimateTypes.Regenerate and self.animatedValue < self.animatedStartValue) then
        self:ForceFillAmount(value)
        return
    end

    self:SetScript("OnUpdate", self.BarUpdate)
end

function GwAnimatedStatusBarMixin:ForceFillAmount(value)
    self:SetFillAmount(value, true)
    self:SetScript("OnUpdate", nil)
end

function GwAnimatedStatusBarMixin:AddToBarMask(texture)
    if texture then
        texture:AddMaskTexture(self.maskContainer.mask0)
        texture:AddMaskTexture(self.maskOverflow.mask)
    end
end

local function SetReverseFill(self, reverse)
    if reverse then
        self.internalBar:SetPoint("RIGHT", self, "RIGHT", 0, 0)

        local maskContainer = self.maskContainer
        local maskOverflow = self.maskOverflow

        maskContainer:ClearAllPoints()
        maskContainer:SetPoint("RIGHT", self, "RIGHT", 0, 0)
        maskContainer.mask0:SetRotation(3.14159)
        maskContainer.mask0:ClearAllPoints()
        maskContainer.mask0:SetPoint("TOPRIGHT", maskContainer, "TOPRIGHT", 0, 0)
        maskContainer.mask0:SetPoint("BOTTOMLEFT", maskContainer, "BOTTOMLEFT", 0, 0)

        maskOverflow:ClearAllPoints()
        maskOverflow:SetPoint("TOPRIGHT", self.maskContainer, "TOPLEFT", 0, 0)
        maskOverflow:SetPoint("BOTTOMRIGHT", self.maskContainer, "BOTTOMLEFT", 0, 0)
        maskOverflow:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 0)
        maskOverflow:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -3, 0)

        maskOverflow.mask:SetRotation(3.14159)
        maskOverflow.mask:ClearAllPoints()
        maskOverflow.mask:SetPoint("TOPRIGHT", maskOverflow, "TOPRIGHT", 0, 0)
        maskOverflow.mask:SetPoint("BOTTOMLEFT", maskOverflow, "BOTTOMLEFT", 0, 0)
    end
end

local function SetOrientation(self)
    self.maskContainer.mask0:SetRotation(1.5707)

    self.maskContainer.mask0:ClearAllPoints()
    self.maskContainer.mask0:SetPoint("CENTER", self.maskContainer, "CENTER", 0, 0)
    self.maskContainer.mask0:SetSize(self.maskContainer:GetHeight(), self.maskContainer:GetWidth())

    self.maskContainer:ClearAllPoints()
    self.maskContainer:SetPoint("BOTTOM", self.internalBar, "BOTTOM", 0, 0)

    self.maskOverflow.mask:SetRotation(1.5707)
    self.maskOverflow:ClearAllPoints()
    self.maskOverflow:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 3)
    self.maskOverflow:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 3)
    self.maskOverflow:SetPoint("BOTTOMLEFT", self.maskContainer, "TOPLEFT", 0, 0)
    self.maskOverflow:SetPoint("BOTTOMRIGHT", self.maskContainer, "TOPRIGHT", 0, 0)

    self.maskOverflow.mask:ClearAllPoints()
    self.maskOverflow.mask:SetPoint("CENTER", self.maskOverflow, "CENTER", 0, 0)
    self.maskOverflow.mask:SetSize(self.maskOverflow:GetHeight(), self.maskOverflow:GetWidth())
end

function GwAnimatedStatusBarMixin:UpdateBarSize()
    local isVertical = (self:GetOrientation() == "VERTICAL") or false
    local totalWidth = self.totalWidth or isVertical and self:GetHeight() or self:GetWidth()
    local height = self.totalHeight or isVertical and self:GetWidth() or self:GetHeight()
    self.maskContainer:SetSize(totalWidth / numSpritesInAnimation, height)
end

local function AddStatusbarAnimation(statusBar, smooth, animationType)
    if not AddToAnimation then
        AddToAnimation = GW.AddToAnimation
        round = GW.RoundInt
    end
    animationType = animationType or BarAnimateTypes.All

    Mixin(statusBar,  GwAnimatedStatusBarMixin)

    statusBar:SetClampedToScreen(false)
    statusBar.maskContainer:SetClampedToScreen(false)
    statusBar.maskOverflow:SetClampedToScreen(false)

    statusBar.smoothAnimation = smooth

    uniqueID = uniqueID + 1
    statusBar.maskContainer:SetSize(statusBar.internalBar:GetWidth() / numSpritesInAnimation, statusBar.internalBar:GetHeight())
    statusBar.fill_threshold = 0
    statusBar.animationType = animationType
    statusBar.BarInterpolation = BarInterpolation.Ease
    statusBar.uniqueID = uniqueID

    statusBar.maskContainer:ClearAllPoints()
    statusBar.maskOverflow:ClearAllPoints()
    statusBar.maskOverflow:SetPoint("TOPLEFT", statusBar.maskContainer, "TOPRIGHT", 0, 0)
    statusBar.maskOverflow:SetPoint("BOTTOMLEFT", statusBar.maskContainer, "BOTTOMRIGHT", 0, 0)
    statusBar.maskOverflow:SetPoint("TOPRIGHT", statusBar, "TOPRIGHT", 3, 0)
    statusBar.maskOverflow:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT", 3, 0)

    statusBar:AddToBarMask(statusBar.internalBar)

    if statusBar.spark ~= nil then
        statusBar:AddToBarMask(statusBar.spark)
        statusBar.spark.width = statusBar.spark:GetWidth()
    end
    hooksecurefunc(statusBar, "SetOrientation", SetOrientation)
    hooksecurefunc(statusBar, "SetReverseFill", SetReverseFill)
    return statusBar
end
GW.AddStatusbarAnimation = AddStatusbarAnimation

local function CreateAnimatedStatusBar(name, parent, template, smooth)
    template = template or "GwStatusBarTemplate"
    local statusBar = CreateFrame("StatusBar", name, parent, template)
    AddStatusbarAnimation(statusBar, smooth)
    return statusBar
end
GW.CreateAnimatedStatusBar = CreateAnimatedStatusBar

local function PreloadStatusBarMaskTextures()
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(1, 1)
    f:SetPoint("TOPLEFT", -5000)
    for i = 0, numSpritesInAnimation do
        f.preLoader = f:CreateTexture(nil, "BACKGROUND")
        f.preLoader:SetTexture("Interface/AddOns/GW2_UI/textures/hud/barmask/ramp/" .. i)
        f.preLoader:SetSize(1, 1)
    end
end
GW.PreloadStatusBarMaskTextures = PreloadStatusBarMaskTextures
