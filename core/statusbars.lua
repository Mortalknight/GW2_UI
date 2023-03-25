local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local lerpEaseOut = GW.lerpEaseOut
local lerp = GW.lerp
local numSpritesInAnimation = 254
local uniqueID  = 0

--[[

  Bar:SetFillAmount(amount)
    Sets the fill amount of the bar to bar, Animates over time if smooth was set when bar was created

  Bar:ForceFIllAmount(amount)
    always sets the bar value without animatiuon


  Bar:GetFillAmount()
    returns the bars current fill amount. if animating returns the current animating value

  bar.barOnUpdate (self)
      used for hooking custom onupdate function to the bars animation. triggers everytime bar value changes (if animated every frame during animation)

  bar.speed
    used to set custom speed, default is 100 (pixels / second)


]]

local function getAnimationDuration(self,val1,val2,width)
  if width ==nil then width = 0 end
  local speed = self.speed or 100
  local t = (width * math.abs(val1 - val2)) / speed
  return t
end
local function getAnimationDurationDynamic(self,val1,val2,width)
  if width ==nil then width = 0 end
  local speed = self.speed or 500
  speed = speed * math.abs(val1 - val2)
  local t = (width * math.abs(val1 - val2)) / speed
  return t
end

local function addMask(self,mask,value)
    if value == 0 then
      self.maskContainer.mask0:SetTexture("Interface/AddOns/GW2_UI/textures/hud/barmask/0")
    end
    self.maskContainer.mask0:SetTexture("Interface/AddOns/GW2_UI/textures/hud/barmask/ramp/"..mask)
end

local function GetFillAmount(self)
  if not self.fillAmount then return 0 end
  return self.fillAmount
end

local function SetFillAmount(self,value)

  local isVertical = (self:GetOrientation()=="VERTICAL") or false
  local totalWidth = isVertical and self:GetHeight() or self:GetWidth()
  local height = isVertical and self:GetWidth() or self:GetHeight()
  local barWidth = totalWidth * value
  local stretchMask = self.strechMask or false

  local maskHightValue = self.customMaskSize or 128


  self.fillAmount = value


  local numberOfSegments =  totalWidth / maskHightValue
  local numberOfSegmentsRound = math.ceil(numberOfSegments)

  local segmentSize = totalWidth / numberOfSegmentsRound


  local currentSegmentIndex = math.floor(numberOfSegmentsRound * value)
  local currentSegmentPosition = currentSegmentIndex * segmentSize

  local barPosition = ((currentSegmentIndex + 1) * segmentSize) / totalWidth

  local rampStartPoint = (segmentSize * currentSegmentIndex)
  local rampEndPoint = (segmentSize * (currentSegmentIndex+1))
  local rampProgress = (barWidth - rampStartPoint) / (rampEndPoint - rampStartPoint)

  local interpolateRamp = lerp(numSpritesInAnimation,0, rampProgress)
  local interpolateRampRound = round(interpolateRamp)

  if self:GetName()=="test1" then
  --  print(interpolateRampRound,value)
  end

  if value == 0 then
      barPosition = 0
  end

  if stretchMask then
    if isVertical then
      self.maskContainer:SetSize(height,maskHightValue)
    else
      self.maskContainer:SetSize(maskHightValue,height)
    end
  else
    self.maskContainer:SetSize(segmentSize,segmentSize)
  end




  if self.spark~=nil  then
    if value == 0 then
      self.spark:Hide()
    else
      self.spark:Show()
    end
    local  sparkPosition =  (currentSegmentPosition + (segmentSize * rampProgress) - self.spark.width) + 10
    local sparkWidth = min(barWidth,self.spark.width)
    self.spark:SetWidth(sparkWidth)
    self.spark:SetHeight(height)
    self.spark:ClearAllPoints()
    self.spark:SetPoint("LEFT",self.internalBar,"LEFT",min(totalWidth - self.spark.width, max(0,sparkPosition)),0)

  end

  if not self.interpolateRampRound or interpolateRampRound~=self.interpolateRampRound then
--    local newMask = self.maskContainer["mask"..interpolateRampRound]
    self:addMask(interpolateRampRound,value)

    if isVertical then
    self.maskContainer.mask0:SetSize(self.maskContainer:GetHeight(),self.maskContainer:GetWidth())
    self.maskOverflow.mask:SetSize(self.maskOverflow:GetHeight(),self.maskOverflow:GetWidth())
    end
    self.interpolateRampRound = interpolateRampRound
  end
  if self.fill_threshold~=barPosition then
      if isVertical then
        self.maskContainer:SetPoint("BOTTOM",self.internalBar,"BOTTOM",0,currentSegmentPosition)
      else
        self.maskContainer:SetPoint("LEFT",self.internalBar,"LEFT",currentSegmentPosition,0)
      end
      self:SetValue(barPosition)
      self.fill_threshold = barPosition
  end
  if self.barOnUpdate then
    self.barOnUpdate(self)
  end
end

local function  barUpdate(self,delta)

  self.animatedTime = self.animatedTime + delta
  local animationProgress = self.animatedTime/self.animatedDuration
  local newValue = lerpEaseOut(self.animatedStartValue,self.animatedValue,animationProgress)
  SetFillAmount(self,newValue)
  if self.onUpdateAnimation then
    self.onUpdateAnimation(self,animationProgress,delta)
  end
  if self.animatedTime>=self.animatedDuration then
  --  SetFillAmount(self,self.animatedValue)
    self:SetScript("OnUpdate",nil)
  end


end

local function onupdate_AnimateBar(self,value)
    self.animatedValue = value;
    self.animatedStartValue = GetFillAmount(self)
    self.animatedTime =0
    self.animatedDuration = getAnimationDurationDynamic(self,self.animatedStartValue , self.animatedValue,self:GetWidth())

    self:SetScript("OnUpdate",barUpdate)
end

local function ForceFIllAmount(self,value)
  SetFillAmount(self,value)
  self:SetScript("OnUpdate",nil)
end

local function addToBarMask(self,texture)
  if texture==nil then
     return
   end
   texture:AddMaskTexture(self.maskContainer.mask0)
   texture:AddMaskTexture(self.maskOverflow.mask)
end

local function SetOrientation(self,direction)


  self.maskContainer.mask0:SetRotation(1.5707)

  self.maskContainer.mask0:ClearAllPoints()
  self.maskContainer.mask0:SetPoint("CENTER",self.maskContainer,"CENTER",0,0)
  self.maskContainer.mask0:SetSize(self.maskContainer:GetHeight(),self.maskContainer:GetWidth())

  self.maskContainer:ClearAllPoints()
  self.maskContainer:SetPoint("BOTTOM",self.internalBar,"BOTTOM",0,0)

  self.maskOverflow.mask:SetRotation(1.5707)
  self.maskOverflow:ClearAllPoints()
  self.maskOverflow:SetPoint("TOPLEFT",self,"TOPLEFT",0,3)
  self.maskOverflow:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,3)
  self.maskOverflow:SetPoint("BOTTOMLEFT",self.maskContainer,"TOPLEFT",0,0)
  self.maskOverflow:SetPoint("BOTTOMRIGHT",self.maskContainer,"TOPRIGHT",0,0)

  self.maskOverflow.mask:ClearAllPoints()
  self.maskOverflow.mask:SetPoint("CENTER",self.maskOverflow,"CENTER",0,0)
  self.maskOverflow.mask:SetSize(self.maskOverflow:GetHeight(),self.maskOverflow:GetWidth())


end

local function hookStatusbarBehaviour(statusBar,smooth)

  if not AddToAnimation then
    AddToAnimation = GW.AddToAnimation
     round = GW.RoundInt
  end

  uniqueID = uniqueID + 1
  statusBar.maskContainer:SetSize(statusBar.internalBar:GetWidth() / numSpritesInAnimation,statusBar.internalBar:GetHeight())
  statusBar.fill_threshold = 0
  statusBar.GetFillAmount = GetFillAmount
  statusBar.SetFillAmount = smooth and onupdate_AnimateBar or SetFillAmount
  statusBar.ForceFIllAmount = ForceFIllAmount
  statusBar.addToBarMask = addToBarMask
  statusBar.uniqueID = uniqueID
  statusBar.addMask = addMask
  statusBar.removeMask = removeMask

  statusBar.maskContainer:ClearAllPoints()
  statusBar.maskOverflow:ClearAllPoints()

  statusBar.maskOverflow:SetPoint("TOPLEFT",statusBar.maskContainer,"TOPRIGHT",0,0)
  statusBar.maskOverflow:SetPoint("BOTTOMLEFT",statusBar.maskContainer,"BOTTOMRIGHT",0,0)
  statusBar.maskOverflow:SetPoint("TOPRIGHT",statusBar,"TOPRIGHT",3,0)
  statusBar.maskOverflow:SetPoint("BOTTOMRIGHT",statusBar,"BOTTOMRIGHT",3,0)


  statusBar:addToBarMask(statusBar.internalBar)

  if statusBar.spark ~=nil then
    statusBar:addToBarMask(statusBar.spark)
    statusBar.spark.width = statusBar.spark:GetWidth()
  end
  hooksecurefunc(statusBar,"SetOrientation",SetOrientation)
  return statusBar
end
GW.hookStatusbarBehaviour = hookStatusbarBehaviour
local function createNewStatusBar(name,parent,template,smooth)
  template = template or "GwStatusBarTemplate"
  local statusBar = CreateFrame("StatusBar",name, parent, template)
  hookStatusbarBehaviour(statusBar,smooth)
  return statusBar
end

GW.createNewStatusbar = createNewStatusBar


local function LoadStatusbarTest()
  local testFrameContainer = CreateFrame("Frame",nil,UIParent)
  local test1  = createNewStatusBar("test1",UIParent,nil,true)
  test1:SetOrientation("VERTICAL")
  test1:SetSize(150,150)
  --local test2  = createNewStatusBar("test2",UIParent,nil,true)
--  test2:SetPoint("CENTER",0,-90)

  test1:SetStatusBarColor(0.3,0.3,0.3,1)
--  test2:SetStatusBarColor(0.3,0,0,1)
    local delay = 0
    local delay2 = 0
    testFrameContainer:SetScript("OnUpdate",function(self,delta)

        test1:SetFillAmount(math.abs(math.sin(GetTime())))
  --      test2:SetFillAmount(math.abs(math.sin(GetTime()*2)))
end)


end
GW.LoadStatusbarTest = LoadStatusbarTest

local function preload(self)

    self.index = self.index + 1
    if self.index>numSpritesInAnimation then
      self:SetScript("OnUpdate",nil)
    end
end
local function preLoadStatusBarMaskTextures()
  local f = CreateFrame("Frame",nil,UIParent)
  f:SetSize(1,1)
  for i =0,numSpritesInAnimation do
    preLoader = f:CreateTexture(nil, "BACKGROUND")
    preLoader:SetTexture("Interface/AddOns/GW2_UI/textures/hud/barmask/ramp/"..i)
    preLoader:SetSize(1,1)

  end

--  f:SetScript("OnUpdate",preload)
end
GW.preLoadStatusBarMaskTextures = preLoadStatusBarMaskTextures
