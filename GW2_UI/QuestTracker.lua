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
                if anchorPoint~='TOPRIGHT' and x~=0 and y~=0 then
                    self:SetPoint('TOPRIGHT',UIParent,0,0)
                end
            end)
            
        --   ObjectiveTrackerFrame.texture = ObjectiveTrackerFrame:CreateTexture()
       --     ObjectiveTrackerFrame.texture:SetPoint('TOPRIGHT',ObjectiveTrackerFrame,'TOPRIGHT',0,0)
       --    ObjectiveTrackerFrame.texture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\questtracker')
            
  
            
            for i = 1, ObjectiveTrackerFrame.BlocksFrame:GetNumChildren() do
            local v = select(i, ObjectiveTrackerFrame.BlocksFrame:GetChildren())
            if type(v) == "table" then
                if v.Background then
                    v.Background:SetTexture("")
                    v.LineGlow:Hide()
                    v.SoftGlow:Hide()
                    v.LineSheen:Hide()	
                end
         
                if v.BottomShadow then
                    v.BottomShadow:Hide()
                    v.TopShadow:Hide()
                end
                if v.Text then
                   v.Text:SetFont(STANDARD_TEXT_FONT,16,'THINOUTLINE')
                   v.Text:SetTextColor(1,1,1)
                   v.Text:SetShadowColor(0,0,0,0)
                end
            end
        end
     self:UnregisterEvent("ADDON_LOADED")
     else
            self:RegisterEvent("ADDON_LOADED")
     end
end)
f:RegisterEvent("PLAYER_LOGIN")





--GetQuestObjectiveInfo