

GW2UI_SETTINGS = {}
GW2UI_SETTINGS['FADE_BOTTOM_ACTIONBAR'] = true;
GW2UI_SETTINGS['HIDE_CHATSHADOW'] = false;
GW2UI_SETTINGS['HIDE_QUESTVIEW'] = false;

GW2UI_SETTINGS['USE_CHAT_BUBBLES'] = false;
GW2UI_SETTINGS['DISABLE_NAMEPLATES'] = false;
GW2UI_SETTINGS['DISABLE_TOOLTIPS'] = false
GW2UI_SETTINGS['DISABLE_CHATFRAME'] = false
GW2UI_SETTINGS['CHATFRAME_FADE'] = true


GW2UI_SETTINGS['target_x_position'] = -100
GW2UI_SETTINGS['target_y_position'] = -100

GW2UI_SETTINGS['focus_x_position'] = -350
GW2UI_SETTINGS['focus_y_position'] = -0


GW2UI_SETTINGS['multibarleft_x_position'] = -300
GW2UI_SETTINGS['multibarleft_y_position'] = -0

GW2UI_SETTINGS['multibarright_x_position'] = -260
GW2UI_SETTINGS['multibarright_y_position'] = -0

GW2UI_SETTINGS['multibarleft_pos'] ={}
GW2UI_SETTINGS['multibarleft_pos']['point'] = 'RIGHT'
GW2UI_SETTINGS['multibarleft_pos']['relativePoint'] = 'RIGHT'
GW2UI_SETTINGS['multibarleft_pos']['xOfs'] = -300
GW2UI_SETTINGS['multibarleft_pos']['yOfs']  = 0

GW2UI_SETTINGS['multibarright_pos'] ={}
GW2UI_SETTINGS['multibarright_pos']['point'] = 'RIGHT'
GW2UI_SETTINGS['multibarright_pos']['relativePoint'] = 'RIGHT'
GW2UI_SETTINGS['multibarright_pos']['xOfs'] = -260
GW2UI_SETTINGS['multibarright_pos']['yOfs']  = 0


GW2UI_SETTINGS['target_pos'] ={}
GW2UI_SETTINGS['target_pos']['point'] = 'TOP'
GW2UI_SETTINGS['target_pos']['relativePoint'] = 'TOP'
GW2UI_SETTINGS['target_pos']['xOfs'] =  0
GW2UI_SETTINGS['target_pos']['yOfs']  = -100

GW2UI_SETTINGS['focus_pos'] ={}
GW2UI_SETTINGS['focus_pos']['point'] = 'CENTER'
GW2UI_SETTINGS['focus_pos']['relativePoint'] = 'CENTER'
GW2UI_SETTINGS['focus_pos']['xOfs'] =  -350
GW2UI_SETTINGS['focus_pos']['yOfs']  = 0



GW2UI_SETTINGS['SETTINGS_LOADED'] = false;



animations = {}

function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
function  lerp( v0,  v1,  t) 
  return v0 + t*(v1-v0);
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
function isnan(n) return tostring(n) == '-1.#IND' end
function addToAnimation(name,from,to,start,duration,method)

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
    else
        animations[name] = {}
        animations[name]['start'] = start
        animations[name]['duration'] = duration 
        animations[name]['from'] = from 
        animations[name]['to'] = to 
        animations[name]['progress'] = 0
        animations[name]['method'] = method
        animations[name]['completed'] = false
    end
   
end

l = CreateFrame("Frame",nil,UIParent)

l:SetScript('OnUpdate',function() 
    
        for k,v in pairs(animations) do 
            
            if v['completed']==false and GetTime()>=(v['start']+ v['duration']) then
                v['progress'] = lerp(v['from'],v['to'],1)
                if  v['method']~=nil then
                    v['method']()
                end
                v['completed'] = true
                
            end            
            if v['completed']==false then
            v['progress'] = lerp(v['from'],v['to'],(GetTime() - v['start'])/v['duration'])
            v['method']()
            end
        end

end)
