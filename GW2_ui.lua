

GW2UI_SETTINGS = {}
  DEFAULT ={}
    
    DEFAULT['TARGET_ENABLED'] = true
    DEFAULT['FOCUS_ENABLED'] = true
    DEFAULT['PET_ENABLED'] = true
    DEFAULT['POWERBAR_ENABLED'] = true
    DEFAULT['CHATBUBBLES_ENABLED'] = true
    DEFAULT['NAMEPLATES_ENABLED'] = true
    DEFAULT['MINIMAP_ENABLED'] = true
    DEFAULT['QUESTTRACKER_ENABLED'] = true
    DEFAULT['TOOLTIPS_ENABLED'] = true
    DEFAULT['CHATFRAME_ENABLED'] = true
    DEFAULT['QUESTVIEW_ENABLED'] = true
    DEFAULT['HEALTHGLOBE_ENABLED'] = true
    DEFAULT['PLAYER_BUFFS_ENABLED'] = true
    DEFAULT['ACTIONBARS_ENABLED'] = true
    DEFAULT['BAGS_ENABLED'] = true
    DEFAULT['NPC_CAM_ENABLED'] = false
    DEFAULT['FONTS_ENABLED'] = true
    DEFAULT['CASTINGBAR_ENABLED'] = true

    DEFAULT['HUD_SPELL_SWAP'] = true

    DEFAULT['target_HEALTH_VALUE_ENABLED'] = false
    DEFAULT['target_HEALTH_VALUE_TYPE'] = false
        
    DEFAULT['FADE_BOTTOM_ACTIONBAR'] = true
    DEFAULT['HIDE_CHATSHADOW'] = false
    DEFAULT['HIDE_QUESTVIEW'] = false;
    DEFAULT['USE_CHAT_BUBBLES'] = false;
    DEFAULT['DISABLE_NAMEPLATES'] = false
    DEFAULT['DISABLE_TOOLTIPS'] = false
    DEFAULT['DISABLE_CHATFRAME'] = false
    DEFAULT['CHATFRAME_FADE'] = true

    DEFAULT['target_TARGET_ENABLED'] = true
    DEFAULT['target_DEBUFFS'] = true
    DEFAULT['target_DEBUFFS_FILTER'] = true
    DEFAULT['target_BUFFS'] = true
    DEFAULT['target_BUFFS_FILTER'] = true

    DEFAULT['focus_TARGET_ENABLED'] = true
    DEFAULT['focus_DEBUFFS'] = true
    DEFAULT['focus_DEBUFFS_FILTER'] = true
    DEFAULT['focus_BUFFS'] = true
    DEFAULT['focus_BUFFS_FILTER'] = true
                    
    DEFAULT['target_x_position'] = -100
    DEFAULT['target_y_position'] = -100

    DEFAULT['focus_x_position'] = -350
    DEFAULT['focus_y_position'] = -100

    DEFAULT['multibarleft_x_position'] = -300
    DEFAULT['multibarleft_y_position'] = -0

    DEFAULT['multibarright_x_position'] = -260
    DEFAULT['multibarright_y_position'] = -0

    DEFAULT['multibarleft_pos'] ={}
    DEFAULT['multibarleft_pos']['point'] = 'RIGHT'
    DEFAULT['multibarleft_pos']['relativePoint'] = 'RIGHT'
    DEFAULT['multibarleft_pos']['xOfs'] = -300
    DEFAULT['multibarleft_pos']['yOfs']= 0

    DEFAULT['multibarright_pos'] ={}
    DEFAULT['multibarright_pos']['point'] = 'RIGHT'
    DEFAULT['multibarright_pos']['relativePoint'] = 'RIGHT'
    DEFAULT['multibarright_pos']['xOfs'] = -260
    DEFAULT['multibarright_pos']['yOfs']  = 0

    DEFAULT['target_pos'] ={}
    DEFAULT['target_pos']['point'] = 'TOP'
    DEFAULT['target_pos']['relativePoint'] = 'TOP'
    DEFAULT['target_pos']['xOfs'] =  -56
    DEFAULT['target_pos']['yOfs']  = -100

    DEFAULT['pet_pos'] ={}
    DEFAULT['pet_pos']['point'] = 'BOTTOMLEFT'
    DEFAULT['pet_pos']['relativePoint'] = 'BOTTOM'
    DEFAULT['pet_pos']['xOfs'] =  -372
    DEFAULT['pet_pos']['yOfs']  = 220  

    DEFAULT['castingbar_pos'] ={}
    DEFAULT['castingbar_pos']['point'] = 'BOTTOM'
    DEFAULT['castingbar_pos']['relativePoint'] = 'BOTTOM'
    DEFAULT['castingbar_pos']['xOfs'] =  0
    DEFAULT['castingbar_pos']['yOfs']  = 300
    
    
    
    DEFAULT['targettarget_pos'] ={}
    DEFAULT['targettarget_pos']['point'] = 'TOP'
    DEFAULT['targettarget_pos']['relativePoint'] = 'TOP'
    DEFAULT['targettarget_pos']['xOfs'] =  250
    DEFAULT['targettarget_pos']['yOfs']  = -100


    DEFAULT['focus_pos'] ={}
    DEFAULT['focus_pos']['point'] = 'CENTER'
    DEFAULT['focus_pos']['relativePoint'] = 'CENTER'
    DEFAULT['focus_pos']['xOfs'] =  -350
    DEFAULT['focus_pos']['yOfs']  = 0
    
    DEFAULT['focustarget_pos'] ={}
    DEFAULT['focustarget_pos']['point'] = 'CENTER'
    DEFAULT['focustarget_pos']['relativePoint'] = 'CENTER'
    DEFAULT['focustarget_pos']['xOfs'] =  -80
    DEFAULT['focustarget_pos']['yOfs']  = 0


local ADDOON_LOADED = false;
local PLAYER_ENTERING_WORLD = false;
local SETTINGS_LOADED = false;
local GW_UI_LOADED = false;


GW_MOVABLE_FRAMES ={}
GW_MOVABLE_FRAMES_REF ={}
GW_MOVABLE_FRAMES_SETTINGS_KEY ={}

local swimAnimation = 0
local lastSwimState = true


function gwGetSetting(name)
    if GW2UI_SETTINGS_DB_03==nil then
        GW2UI_SETTINGS_DB_03 = DEFAULT
    end
    if GW2UI_SETTINGS_DB_03[name]==nil then
        GW2UI_SETTINGS_DB_03[name] = gwGetDefault(name)
    end
    
    return GW2UI_SETTINGS_DB_03[name]
end

function gwSetSetting(name,state)
    GW2UI_SETTINGS_DB_03[name] = state
end

function gwGetDefault(name)    
    return DEFAULT[name]
end

function gw_register_movable_frame(name,frame,settingsName,dummyFrame)
    
    local moveframe = CreateFrame('Frame', name..'MoveAble',UIParent,dummyFrame);

    moveframe:SetSize(frame:GetSize())
 
    
    local dummyPoint = gwGetSetting(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(dummyPoint['point'],UIParent,dummyPoint['relativePoint'],dummyPoint['xOfs'],dummyPoint['yOfs'])
    GW_MOVABLE_FRAMES[name]=moveframe
    GW_MOVABLE_FRAMES_REF[name]=frame
    GW_MOVABLE_FRAMES_SETTINGS_KEY[name]=settingsName
    moveframe:Hide()
    moveframe:RegisterForDrag("LeftButton")
    
    moveframe:SetScript("OnDragStart", frame.StartMoving)
    moveframe:SetScript("OnDragStop", function(self)
        moveframe:StopMovingOrSizing()
        point, relativeTo, relativePoint, xOfs, yOfs = moveframe:GetPoint()
            
        new_point = {}
        new_point['point']=point
        new_point['relativePoint'] =relativePoint
        new_point['xOfs'] =math.floor(xOfs)
        new_point['yOfs'] = math.floor(yOfs)
        gwSetSetting(settingsName,new_point)

    end)
    
end

function gw_update_moveableframe_positions()
    
    for k,v in pairs(GW_MOVABLE_FRAMES_REF) do
        local newp = gwGetSetting(GW_MOVABLE_FRAMES_SETTINGS_KEY[k])
        v:ClearAllPoints()
        GW_MOVABLE_FRAMES_REF[k]:SetPoint(newp['point'],UIParent,newp['relativePoint'],newp['xOfs'],newp['yOfs'])
       
    end
    
end

if AchievementMicroButton_Update==nil then
   function AchievementMicroButton_Update()
        return
    end
end

if UnitIsTapDenied==nil then
   function UnitIsTapDenied()
        if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) then
            return true
        end
        return false
    end
end

function countTable(T)
  local c = 0
    if T~=nil and type(T) == 'table' then
        for _ in pairs(T) do c = c + 1 end
    end
  return c
end

function timeCount(numSec)
	local nSeconds = tonumber(numSec)
        if nSeconds==nil then
            nSeconds = 0
        end
		if nSeconds == 0 then

				coolTime = "0";
		else
			local	nHours = math.floor(nSeconds/3600);
			local	nMins =  math.floor(nSeconds/60 - (nHours*60));
			local	nSecs = math.floor(nSeconds - nHours*3600 - nMins *60);
			
            if nHours>0 then
                coolTime =nHours..'h'
            else
                if nMins>0 then
                     coolTime =nMins..'m'
                else
                 coolTime =   nSecs..'s'
                end
            end

	end
    return coolTime
end


function comma_value(n)
    n = round(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

animations = {}

function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
function  lerp( v0,  v1,  t) 
    if v0==nil then 
        v0=0
    end
     local p = (v1-v0)
  return v0 + t*p;
end
function length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function splitString(inputstr, sep,sep2,sep3)
        if sep == nil then
                sep = "%s"
        end
        inputstr = inputstr:gsub ('\n','')
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."|"..sep2.."|"..sep3.."]+)") do
            st, en, cap1, cap2, cap3 = string.find (inputstr, str)
            if en ~= nil then
                s = string.sub (inputstr, en+1, en+1)

                if s ~= nil or s ~= '' then
                    str =  str..s
                end
            end
            t[i] = str
            i = i + 1
        end
        return t
end

function gw_button_enter(self)
    local name = self:GetName()
    local startTime = GetTime()
   local w = self:GetWidth()
    
    self:SetScript('OnUpdate',function()
        
        local a  = GetTime() - startTime
        local b  =  0.2
        
        if GetTime()>(startTime+0.2) then
            self:SetScript('OnUpdate',nil)
            return
        end
        
        local l = lerp(0,w,math.sin(a/b * math.pi * 0.5))
            
        _G[name..'OnHover']:SetPoint('RIGHT',self,'LEFT',l,0)
        _G[name..'OnHover']:SetAlpha((a/b))
           
    end)
end

function gw_button_leave(self)
    local name = self:GetName()
    local startTime = GetTime()
     local w = self:GetWidth()
    
    self:SetScript('OnUpdate',function()
        
        local a  = GetTime() - startTime
        local b  =  0.2
        
        if GetTime()>(startTime+0.2) then
            self:SetScript('OnUpdate',nil)
            return
        end
        
        local l = lerp(w,0,math.sin(a/b * math.pi * 0.5))
            
        _G[name..'OnHover']:SetPoint('RIGHT',self,'LEFT',l,0)
        _G[name..'OnHover']:SetAlpha(1-(a/b))
           
    end)
end


function isnan(n) return tostring(n) == '-1.#IND' end
function addToAnimation(name,from,to,start,duration,method,easeing,onCompleteCallback)

    newAnimation = true
    if animations[name]~=nil then
        if (animations[name]['start'] + animations[name]['duration'])>GetTime() then
            newAnimation = false
        end
    end
    
    if newAnimation==false then
  --      animations[name]['start'] = start
        animations[name]['duration'] = duration 
        animations[name]['to'] = to 
        animations[name]['progress'] = 0
        animations[name]['method'] = method
        animations[name]['completed'] = false
        animations[name]['easeing'] = easeing
        animations[name]['onCompleteCallback'] = onCompleteCallback
    else
        animations[name] = {}
        animations[name]['start'] = start
        animations[name]['duration'] = duration 
        animations[name]['from'] = from 
        animations[name]['to'] = to 
        animations[name]['progress'] = 0
        animations[name]['method'] = method
        animations[name]['completed'] = false
        animations[name]['easeing'] = easeing
        animations[name]['onCompleteCallback'] = onCompleteCallback
    end
   
end

l = CreateFrame("Frame",nil,UIParent)

l:SetScript('OnUpdate',function() 
        
        if ADDOON_LOADED~=true or ADDOON_LOADED~=true then
            return
        end
        
        for k,v in pairs(animations) do 
            
            if v['completed']==false and GetTime()>=(v['start']+ v['duration']) then
                if  v['easeing']==nil then
                    v['progress'] = lerp(v['from'],v['to'],math.sin(1 * math.pi * 0.5))
                else
                    v['progress'] = lerp(v['from'],v['to'],1)
                end
                if  v['method']~=nil then
                    v['method']()
                end
                
                if v['onCompleteCallback']~=nil then
                    v['onCompleteCallback']()
                end
                
                v['completed'] = true
                
            end            
            if v['completed']==false then
                
                if  v['easeing']==nil then
                    v['progress'] = lerp(v['from'],v['to'],math.sin((GetTime() - v['start'])/v['duration'] * math.pi * 0.5))
                else
                    v['progress'] = lerp(v['from'],v['to'],(GetTime() - v['start'])/v['duration'])
                end
            v['method']()
            end
        end
        
        

    
        
        fadet_action_bar_check(MultiBarBottomLeft)
        fadet_action_bar_check(MultiBarBottomRight)
        
        --Swim hud
        
        if  lastSwimState~=IsSwimming() then 
            if IsSwimming() then
                addToAnimation('swimAnimation',swimAnimation,1,GetTime(),0.1,function()
                        local r,g,b = _G['GwActionBarHudRIGHTSWIM']:GetVertexColor()
                        _G['GwActionBarHudRIGHTSWIM']:SetVertexColor(r,g,b,animations['swimAnimation']['progress']);
                        _G['GwActionBarHudLEFTSWIM']:SetVertexColor(r,g,b,animations['swimAnimation']['progress']);
                end)   
                swimAnimation = 1
            else
                addToAnimation('swimAnimation',swimAnimation,0,GetTime(),3.0,function()
                        local r,g,b = _G['GwActionBarHudRIGHTSWIM']:GetVertexColor()
                        _G['GwActionBarHudRIGHTSWIM']:SetVertexColor(r,g,b,animations['swimAnimation']['progress']);
                        _G['GwActionBarHudLEFTSWIM']:SetVertexColor(r,g,b,animations['swimAnimation']['progress']);
                end) 
                swimAnimation = 0
            end
            lastSwimState = IsSwimming()
        end
        
        
        
        

end)

l:SetScript('OnEvent',function(self,event,name) 
        
        if GW_UI_LOADED then
            return
        end
        
        if event=='ADDON_LOADED' and name=='GW2_UI' then
            ADDOON_LOADED = true;
            SETTINGS_LOADED = true;
            return    
        end
        if event=='ADDON_LOADED' and name~='GW2_UI' then
            return
        end
        if event=='PLAYER_ENTERING_WORLD' then
            PLAYER_ENTERING_WORLD = true;
        end

        GW_UI_LOADED = true
            
            --Create Settings window
            create_settings_window()
            display_options()
            
            --Create hud art
            loadHudArt()
            
            --Create experiencebar
            loadExperienceBar() 
        
       if gwGetSetting('FONTS_ENABLED') then
            gw_register_fonts()
        end  
        if gwGetSetting('CASTINGBAR_ENABLED') then
            gw_register_castingbar()
        end  
        
       if gwGetSetting('MINIMAP_ENABLED') then
            gw_set_minimap()
        end
        if gwGetSetting('QUESTTRACKER_ENABLED') then
               --QUESTTRACKER
            gw_load_questtracker()
            gw_load_all_bossFrames()
        end
        if gwGetSetting('TOOLTIPS_ENABLED') then
            gw_set_tooltips()
        end
        if gwGetSetting('QUESTVIEW_ENABLED') then
            gw_create_questview()
        end
        if gwGetSetting('CHATFRAME_ENABLED') then
            gw_set_custom_chatframe()
            gw_set_chatframe_bg()
            FCF_FadeOutChatFrame(ChatFrame1)
        end
            --Create player hud
        if gwGetSetting('HEALTHGLOBE_ENABLED') then    
            create_player_hud()
        end
        
        if gwGetSetting('POWERBAR_ENABLED') then
            create_power_bar()
        end
        
        
        if gwGetSetting('BAGS_ENABLED') then
            gw_create_bgframe()
            gw_create_bankframe()
        end 
        
        gw_breath_meter()
        
            --Create unitframes
        if gwGetSetting('FOCUS_ENABLED') then
            registerNewUnitFrame('focus','GwTargetFrameTemplate')
            if gwGetSetting('focus_TARGET_ENABLED') then
                registerNewUnitFrame('focustarget','GwTargetFrameSmallTemplate')  
            end
        end
        if gwGetSetting('TARGET_ENABLED') then
            registerNewUnitFrame('target','GwTargetFrameTemplate')
            if gwGetSetting('target_TARGET_ENABLED') then
                registerNewUnitFrame('targettarget','GwTargetFrameSmallTemplate')
            end
        end
        
        
        --create buff frame        
        if gwGetSetting('PLAYER_BUFFS_ENABLED') then
            gw_set_buffframe()
        end
        if gwGetSetting('ACTIONBARS_ENABLED') then
            create_pet_frame()
            gw_set_actionbars()
        end  
        
                
        if gwGetSetting('CHATBUBBLES_ENABLED') then
            gw_register_chatbubbles()
        end
        
        -- create new microbuttons
        create_micro_menu()
        
    
        
        -- move error frame
        UIErrorsFrame:ClearAllPoints()
        UIErrorsFrame:SetPoint('TOP',UIParent,'TOP',0,0)
             
         
        
            
        
end)
l:RegisterEvent('ADDON_LOADED')
l:RegisterEvent('PLAYER_ENTERING_WORLD')


