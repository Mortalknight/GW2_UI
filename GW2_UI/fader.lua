
local action_bar_animations = {}
local callback = {}
    action_bar_animations['MultiBarBottomRight'] = 0
    action_bar_animations['MultiBarBottomLeft'] = 0

function gw_actionbar_state_add_callback(m)
    local k = countTable(callback)+1
    callback[k] =m
end
function gw_actionbar_state_changed()
    for k,v in pairs(callback) do
        v()
    end
end


function actionBarFrameShow(f,name)
    if f:GetAlpha() == 0 then
        addToAnimation(name, action_bar_animations[name],1,GetTime(),0.1,function()
            f:SetAlpha(animations[name]['progress'])
                gw_actionbar_state_changed()
        end,nil,function() gw_actionbar_state_changed() end)         
        action_bar_animations[name] = 1
    end
end
function actionBarFrameHide(f,name)
    if f:GetAlpha() == 1 then
        addToAnimation(name, action_bar_animations[name],0,GetTime(),0.1,function()
            f:SetAlpha(animations[name]['progress'])
                gw_actionbar_state_changed()
        end,nil, function() gw_actionbar_state_changed() end)         
        action_bar_animations[name] = 0
    end
end


MultiBarBottomRight:SetScript("OnUpdate",function(self)

end)
MultiBarBottomLeft:SetScript("OnUpdate",function(self)

end)

local thro = 0
MultiBarBottomLeft.lastFadeCheck = 0
MultiBarBottomRight.lastFadeCheck = 0
function fadet_action_bar_check(self)
    
    if self.lastFadeCheck>GetTime() then
        return
    end
    self.lastFadeCheck = GetTime() + 0.3
    
    if self:IsMouseOver(100, -100, -100, 100)  or UnitAffectingCombat('player') then
       actionBarFrameShow(self,self:GetName())
    else
        if UnitAffectingCombat('player') == false then
          
             if gwGetSetting('FADE_BOTTOM_ACTIONBAR')then
                actionBarFrameHide(self,self:GetName())   
            end 
        end
    end
    
    if self:GetAlpha()>0.0 then
                b = true
            end
end
