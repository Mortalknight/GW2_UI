local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local lerpEaseOut = GW.lerpEaseOut
local lerp = GW.lerp
local numSpritesInAnimation = 15
local uniqueID  = 0

--[[
  TODO
    Implement Vertical bars (for healglobe etc)




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

local function removeMask(self,mask)
  self.internalBar:RemoveMaskTexture(mask)

  if self.maskedTextures==nil then
     return
   end

   for _,texture in pairs(self.maskedTextures) do
     texture:RemoveMaskTexture(mask)
  end
end
local function addMask(self,mask)
  self.internalBar:AddMaskTexture(mask)

  if self.maskedTextures==nil then
     return
   end

  for _,texture in pairs(self.maskedTextures) do
    texture:AddMaskTexture(mask)
  end
end

local function GetFillAmount(self)
  if not self.fillAmount then return 0 end
  return self.fillAmount
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

  if value == 0 then
    bI = 0
  end

  if self.spark~=nil then
    local  sparkPosition = max(0,(spark - self.maskContainer:GetWidth()) + (spark_current * self.maskContainer:GetWidth()) - (self.spark:GetWidth()/2) + 5)
    self.spark:ClearAllPoints()
    self.spark:SetPoint("LEFT",self.internalBar,"LEFT",sparkPosition ,0)

  end

  if not self.bI or bI~=self.bI then
    local newMask = self.maskContainer["mask"..bI]
    self:addMask(newMask)
    if self.bI~=nil then
      local oldMask = self.maskContainer["mask"..self.bI]
      self:removeMask(oldMask)
    end
    self.bI = bI
  end
  if self.fill_threshold~=fill_threshold then
      self.maskContainer:SetPoint("LEFT",self.internalBar,"LEFT",spark,0)
      self:SetValue(fill_threshold)
      self.fill_threshold = fill_threshold
  end
  if self.barOnUpdate then
    self.barOnUpdate(self)
  end
end

local function  barUpdate(self,delta)

  self.animatedTime = self.animatedTime + delta
  local newValue = lerpEaseOut(self.animatedStartValue,self.animatedValue,self.animatedTime/self.animatedDuration)
  SetFillAmount(self,newValue)
  if self.animatedTime>=self.animatedDuration then
  --  SetFillAmount(self,self.animatedValue)
    self:SetScript("OnUpdate",nil)
  end


end

local function onupdate_AnimateBar(self,value)
    self.animatedValue = value;
    self.animatedStartValue = GetFillAmount(self)
    self.animatedTime =0
    self.animatedDuration = getAnimationDuration(self,self.animatedStartValue , self.animatedValue,self:GetWidth())

    self:SetScript("OnUpdate",barUpdate)
end

local function addToBarMask(self,texture)
  if texture==nil then
     return
   end
   texture:AddMaskTexture(self.mask)
  if self.maskedTextures == nil then
    self.maskedTextures  ={}
  end
  self.maskedTextures[#self.maskedTextures +  1] = texture

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
  statusBar.ForceFIllAmount = SetFillAmount
  statusBar.addToBarMask = addToBarMask
  statusBar.uniqueID = uniqueID
  statusBar.addMask = addMask
  statusBar.removeMask = removeMask

  statusBar.maskContainer:ClearAllPoints()
  statusBar.maskContainer:SetPoint("LEFT",statusBar.internalBar,"LEFT",0,0)

  statusBar.mask:SetPoint("LEFT",statusBar.maskContainer,"RIGHT",-2,0)
  --statusBar.mask:SetPoint("RIGHT",statusBar,"RIGHT",0,0)
  statusBar.internalBar:AddMaskTexture(statusBar.mask)

  if statusBar.spark ~=nil then
    statusBar:addToBarMask(statusBar.spark)
  end

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
  local test1  = createNewStatusBar("test1",UIParent,nil,false)
  local test2  = createNewStatusBar("test2",UIParent,nil,true)
  test2:SetPoint("CENTER",0,-90)

  test1:SetStatusBarColor(0.3,0,0,1)
  test2:SetStatusBarColor(0.3,0,0,1)
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
