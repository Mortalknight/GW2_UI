chatBubblesFrame = CreateFrame('frame',nil,UIParent)
local intervalCd = 0
local bubbles = {}
chatBubblesFrame:SetScript('OnUpdate',function()
        if intervalCd > GetTime() then
        return
        end
        intervalCd = GetTime() +0.1
        
        if GW2UI_SETTINGS['SETTINGS_LOADED']==false then
            return
        end
   
        if GW2UI_SETTINGS['USE_CHAT_BUBBLES']==true then
            chatBubblesFrame:SetScript('OnUpdate',nil)
            return 
        end
        
       getBubbles()
        
    for k,v in pairs(bubbles) do 
            
       bgFrame = v['frame']
       fontString= v['fontstring']
        b = v['bgFile']
            
        if fontString ~=nil then 
            fontString:SetFont(DAMAGE_TEXT_FONT,10)
            fontString:SetShadowColor(1, 1, 1, 0) 
            if b ~= 'Interface\\AddOns\\GW2_UI\\textures\\ChatBubble-Background' then
                local backdrop = {
                  -- path to the background texture
                  bgFile = 'Interface\\AddOns\\GW2_UI\\textures\\ChatBubble-Background',  
                  -- path to the border texture
                  edgeFile = 'Interface\\AddOns\\GW2_UI\\textures\\ChatBubble-Backdrop',
                  -- true to repeat the background texture to fill the frame, false to scale it
                  tile = true,
                  -- size (width or height) of the square repeating background tiles (in pixels)
                  tileSize = 32,
                  -- thickness of edge segments and square size of edge corners (in pixels)
                  edgeSize = 32,
                  -- distance from the edges of the frame to those of the background texture (in pixels)
                  insets = {
                    left = 11,
                    right = 12,
                    top = 12,
                    bottom = 11
                  }
                }
               bgFrame:SetBackdrop(backdrop)
            end
           
            fontString:SetTextColor(0,0,0)
        end
    end
end)
function getBubbles()
bi = 0
for i=1,WorldFrame:GetNumChildren() do
        local v = select(i, WorldFrame:GetChildren())
        local b = v:GetBackdrop()
        if b then
            if b.bgFile == "Interface\\Tooltips\\ChatBubble-Background" or b.bgFile == "Interface\\AddOns\\GW2_UI\\textures\\ChatBubble-Background" then
                for i=1,v:GetNumRegions() do
                    local frame = v
                    local v = select(i, v:GetRegions())
                    if v:GetObjectType() == "FontString" then
                        bi = bi +1
                            local fontstring = v
                            bubbles[bi] = {}
                            bubbles[bi]['frame'] = frame
                            bubbles[bi]['fontstring']= fontstring
                            bubbles[bi]['bgFile'] = b.bgFile
                    end
                end
            end
        end
    end
end