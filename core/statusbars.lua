local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local lerpEaseOut = GW.lerpEaseOut
local lerp = GW.lerp
local numSpritesInAnimation = 15
local uniqueID  = 0

local function getAnimationDuration(val1,val2,width)
  if width ==nil then width = 0 end
  local t = (width * math.abs(val1 - val2)) / 100
  return t
end

local function SetFillAmount(self,value)

  local totalWidth = self:GetWidth()
  local barWidth = totalWidth * value



  self.fillAmount = value
  local bit = totalWidth / numSpritesInAnimation
  local spark = bit * math.floor(numSpritesInAnimation * value)
  local spark_current = (bit * (numSpritesInAnimation * (value)) - spark) / bit
  local bI = math.min(numSpritesInAnimation, math.max(1, math.floor((numSpritesInAnimation ) - (numSpritesInAnimation * spark_current))))
  local fill_threshold = (1/numSpritesInAnimation) * ( math.floor(numSpritesInAnimation * value) + 1)
  local maskTest = (totalWidth * fill_threshold) - bit
  if not self.bI or bI~=self.bI then
    local newMask = self.maskContainer["mask"..bI]
    self.bar:AddMaskTexture(newMask)
    if self.bI~=nil then
      local oldMask = self.maskContainer["mask"..self.bI]
      self.bar:RemoveMaskTexture(oldMask)
    end
    self.bI = bI
  end
  if self.fill_threshold~=fill_threshold then
      self.maskContainer:SetPoint("LEFT",self.bar,"LEFT",spark,0)
      self:SetValue(fill_threshold)
      self.fill_threshold = fill_threshold
  end
end
local function animateStatusBar(self,value)

  local to = value
  local from = self:GetFillAmount()
  local duration = getAnimationDuration(to,from,self:GetWidth())

  AddToAnimation("GWBAR"..self.uniqueID, from, to, GetTime(), duration, function(p)

    SetFillAmount(self,p)
  end, nil, nil, nil)
end
local function GetFillAmount(self)
  if not self.fillAmount then return 0 end
  return self.fillAmount
end

local function  barUpdate(self,delta)

  self.animatedTime = self.animatedTime + delta
  local newValue = lerpEaseOut(self.animatedStartValue,self.animatedValue,self.animatedTime/self.animatedDuration)
  SetFillAmount(self,newValue)
  if self.animatedTime>=self.animatedDuration then
    self:SetScript("OnUpdate",nil)
  end
--[[
    local direction = 1;
    local clampVal = self.animatedValue
    local newValue = GetFillAmount(self)
    if self.animatedValue<self.animatedStartValue then
       direction = -1
       newValue = max(newValue + direction * 0.5 * delta,self.animatedValue);
     else
       newValue = min(newValue + direction * 0.5 * delta,self.animatedValue);
     end
    SetFillAmount(self,newValue)
    if newValue==self.animatedValue then
      self:SetScript("OnUpdate",nil)
    end
    ]]
end

local function onupdate_AnimateBar(self,value)
    self.animatedValue = value;
    self.animatedStartValue = GetFillAmount(self)
    self.animatedTime =0
    self.animatedDuration = getAnimationDuration(self.animatedStartValue , self.animatedValue,self:GetWidth())
    self.test:SetPoint("TOPRIGHT",self.bar,"BOTTOMLEFT",self:GetWidth()*value,0)

    self:SetScript("OnUpdate",barUpdate)
end

local function hookStatusbarBehaviour(statusBar,smooth)

  if not AddToAnimation then
    AddToAnimation = GW.AddToAnimation
     round = GW.RoundInt
  end

  uniqueID = uniqueID + 1
  statusBar.maskContainer:SetSize(statusBar.bar:GetWidth() / numSpritesInAnimation,statusBar.bar:GetHeight())
  statusBar.fill_threshold = 0
  statusBar.GetFillAmount = GetFillAmount
  statusBar.SetFillAmount = smooth and onupdate_AnimateBar or SetFillAmount
  statusBar.uniqueID = uniqueID


end

local function createNewStatusBar(parent,smooth)
  local statusBar = CreateFrame("StatusBar",nil, parent, "GwStatusBarTemplate")
  hookStatusbarBehaviour(statusBar,smooth)
  return statusBar
end

GW.createNewStatusbar = createNewStatusBar


local function LoadStatusbarTest()
  local test1  = createNewStatusBar(UIParent,false)
  local test2  = createNewStatusBar(UIParent,true)
  test2:SetPoint("CENTER",0,-90)


    local delay = 0
    local delay2 = 0
    test1:SetScript("OnUpdate",function(self,delta)
      if delay2>GetTime() then
        return
      end
        delay2 = GetTime() + 3

        test1:SetFillAmount(math.abs(math.sin(GetTime())))
        test2:SetFillAmount(math.abs(math.sin(GetTime()*2)))
    end)


end

GW.LoadStatusbarTest = LoadStatusbarTest