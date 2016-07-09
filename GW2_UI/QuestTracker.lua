local anchor = "TOPRIGHT"
local xOff = 0
local yOff = 0

function gw_set_questtracker()

            local tracker = ObjectiveTrackerFrame
            tracker:ClearAllPoints()
            tracker:SetPoint(anchor,UIParent,xOff,yOff)
            hooksecurefunc("UIParent_ManageFramePositions",function()
                
                    tracker:SetPoint('TOPRIGHT',UIParent,0,0)
            end)
            
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

end






--GetQuestObjectiveInfo