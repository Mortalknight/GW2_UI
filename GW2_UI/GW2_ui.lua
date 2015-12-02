GW2UI_SETTINGS = {}
GW2UI_SETTINGS['FADE_BOTTOM_ACTIONBAR'] = true;
GW2UI_SETTINGS['HIDE_CHATSHADOW'] = false;
GW2UI_SETTINGS['HIDE_QUESTVIEW'] = false;

GW2UI_SETTINGS['USE_CHAT_BUBBLES'] = false;

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
    animations[name] = {}
    animations[name]['start'] = start
    animations[name]['duration'] = duration 
    animations[name]['from'] = from 
    animations[name]['to'] = to 
    animations[name]['progress'] = 0
    animations[name]['method'] = method
   
end

l = CreateFrame("Frame",nil,UIParent)

l:SetScript('OnUpdate',function() 
    
        for k,v in pairs(animations) do 
            
            if GetTime()<(v['start']+ v['duration']) then
            v['progress'] = lerp(v['from'],v['to'],(GetTime() - v['start'])/v['duration'])
            v['method']()
            end
        end

end)