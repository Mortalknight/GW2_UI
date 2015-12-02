GW2UI_SETTINGS = {}
GW2UI_SETTINGS['FADE_BOTTOM_ACTIONBAR'] = true;
GW2UI_SETTINGS['HIDE_CHATSHADOW'] = false;
GW2UI_SETTINGS['HIDE_QUESTVIEW'] = false;

GW2UI_SETTINGS['USE_CHAT_BUBBLES'] = false;

GW2UI_SETTINGS['SETTINGS_LOADED'] = false;


function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
function  lerp( v0,  v1,  t) 
  return v0 + t*(v1-v0);
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

