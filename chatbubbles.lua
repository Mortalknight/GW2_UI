local intervalCd = 0
local bubbles = {}
local CHAT_BUBBLES_ACTIVE = {}
local safeToChange = false

function update_gwChat_bubbles(msg)

    getBubbles(msg)
        
    for k,v in pairs(bubbles) do
        local bgFrame = v['frame']
        local fontString= v['fontstring']
        b = v['bgFile']
            
        if fontString~=nil then 

            fontString:SetFont(DAMAGE_TEXT_FONT,14)
            fontString:SetTextColor(0,0,0)
            
            if  bgFrame.hasBeenStyled==nil then
                local backdrop =nil
                bgFrame:SetBackdrop(backdrop)
                
                bgFrame.hasBeenStyled = true
                local newBubble = CreateFrame('Frame','GwChatBubble',bgFrame,'GwChatBubble')
                bgFrame:SetScale(0.6)
                newBubble:ClearAllPoints()
                newBubble:SetPoint('TOPLEFT',bgFrame,'TOPLEFT',0,0)
                newBubble:SetPoint('BOTTOMRIGHT',bgFrame,'BOTTOMRIGHT',0,0)
               
                newBubble.string:SetText(fontString:GetText())
                
                bgFrame:HookScript('OnShow',function()

                   newBubble.string:SetText(fontString:GetText())
                end)
               
            end
        end
    end
end
function getBubbles(msg)
local bi = 0
     
for i=1,WorldFrame:GetNumChildren() do
        local v = select(i, WorldFrame:GetChildren())
        local b = v:GetBackdrop()
        local p = v:IsProtected()
        if b~=nill and not p then
            if b.bgFile == "Interface\\Tooltips\\ChatBubble-Background" or b.bgFile == "Interface\\AddOns\\GW2_UI\\textures\\ChatBubble-Background" then
                for i=1,v:GetNumRegions() do
                    
                    local frame = v
                    local v = select(i, v:GetRegions())
                    if v:GetObjectType() == "FontString" then
                       
                        
                        if frame.hasBeenStyled==nil then
                        bi = countTable(bubbles)
                        local fontstring = v
                 
                        bubbles[bi] = {}
                        bubbles[bi]['frame'] = frame
                        bubbles[bi]['fontstring']= fontstring
                        bubbles[bi]['bgFile'] = b.bgFile
                        return  bubbles[bi]
                        end
                    end
                end
            end
        end
    end
    return nil
end

function gw_register_chatbubbles()
   local f = CreateFrame('Frame',nil,nil) 

    f:SetScript('OnEvent',gw_chatbubbles_onevent)
    f:SetScript('OnUpdate',gw_chatbubbles_onupdate)
    
    f:RegisterEvent('CHAT_MSG_SAY')
    f:RegisterEvent('CHAT_MSG_PARTY')
    f:RegisterEvent('CHAT_MSG_MONSTER_YELL')
    f:RegisterEvent('CHAT_MSG_YELL')
    f:RegisterEvent('CHAT_MSG_MONSTER_EMOTE')
    f:RegisterEvent('CHAT_MSG_MONSTER_PARTY')
    f:RegisterEvent('CHAT_MSG_MONSTER_SAY')
    f:RegisterEvent('CHAT_MSG_MONSTER_WHISPER')
    f:RegisterEvent('CHAT_MSG_MONSTER_YELL')
    f:RegisterEvent('UPDATE_INSTANCE_INFO')
    f:RegisterEvent('ZONE_CHANGED')
    
    
end
function gw_chatbubbles_onevent(self,event,msg,arg2)
    
    if event=='UPDATE_INSTANCE_INFO' or event=='ZONE_CHANGED' then
        local  name, typeOf, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
        
        if typeOf==nil or typeOf=='scenario' or typeOf=='none' then
           safeToChange = true 
        else
            safeToChange = false
        end
            
        return  
    end
    
    if safeToChange==false then return end
    
    local i = countTable(CHAT_BUBBLES_ACTIVE)
    CHAT_BUBBLES_ACTIVE[i] ={}
    CHAT_BUBBLES_ACTIVE[i]['msg'] =msg
    CHAT_BUBBLES_ACTIVE[i]['time'] =GetTime() +5
   
    
end
function gw_chatbubbles_onupdate()

if safeToChange==false then return end
    
local wipe = true
  for k,v in pairs(CHAT_BUBBLES_ACTIVE) do
        if v['time']>GetTime() then
            wipe =false
        end
    end
    if wipe==true then
        CHAT_BUBBLES_ACTIVE = {}
    else
        update_gwChat_bubbles()
    end
    
end

