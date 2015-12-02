function fadeFrameShow(f)
    if f:GetAlpha() == 0 then
        f:SetAlpha(1)
    end
end
function fadeFrameHide(f)
    if f:GetAlpha() == 1 then
        UIFrameFadeOut(f, 1,f:GetAlpha(),0)
    end
end


MultiBarBottomRight:SetScript("OnUpdate",function(self)
    if self:IsMouseOver(100, -100, -100, 100) or UnitAffectingCombat('player') then
       fadeFrameShow(self)
    else
        if UnitAffectingCombat('player') == false then
         
            if GW2UI_SETTINGS['FADE_BOTTOM_ACTIONBAR']then
                fadeFrameHide(self)   
            end
        end
    end
end)
MultiBarBottomLeft:SetScript("OnUpdate",function(self)
        local b = false
    if self:IsMouseOver(100, -100, -100, 100)  or UnitAffectingCombat('player') then
       fadeFrameShow(self)
    else
        if UnitAffectingCombat('player') == false then
          
             if GW2UI_SETTINGS['FADE_BOTTOM_ACTIONBAR']then
                fadeFrameHide(self)   
            end 
        end
    end
    
    if self:GetAlpha()>0.0 then
                b = true
            end
        
  setPetBar(b)
end)
