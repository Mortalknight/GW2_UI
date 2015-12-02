-- these three lines define where to position the topright corner
-- negative x values go left, positive x values go right
-- negative y values go down, positive y values go up
local anchor = "TOPRIGHT"
local xOff = 0
local yOff = 0

local f = CreateFrame("Frame")
f:SetScript("OnEvent",function(self,event,addon)
 if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
 local tracker = ObjectiveTrackerFrame
 tracker:ClearAllPoints()
 tracker:SetPoint(anchor,UIParent,xOff,yOff)
 hooksecurefunc(tracker,"SetPoint",function(self,anchorPoint,relativeTo,x,y)
 if anchorPoint~=anchor and x~=xOff and y~=yOff then
 self:SetPoint(anchor,UIParent,xOff,yOff)
 end
 end)
 self:UnregisterEvent("ADDON_LOADED")
 else
 self:RegisterEvent("ADDON_LOADED")
 end
end)
f:RegisterEvent("PLAYER_LOGIN")