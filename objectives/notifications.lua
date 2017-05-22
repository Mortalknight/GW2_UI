local cTitle =''
local cDesc = ''
local currentNotificationKey = ''
local currentNotificationType = ''
local radarActive =false
local radarType =''

local notifications = {}

local radarData = {}

local icons = {}
icons['QUEST'] ={tex ='icon-objective', l=0,r=1,t=0.25,b=0.5}
icons['EVENT_NEARBY'] ={tex='icon-objective',l=0,r=1,t=0.5,b=0.75}
icons['EVENT'] ={tex='icon-objective',l=0,r=1,t=0.5,b=0.75}
icons['SCENARIO'] ={tex='icon-objective',l=0,r=1,t=0.75,b=1}
icons['BOSS'] ={tex='icon-boss',l=0,r=1,t=0,b=1}
icons['DEAD'] ={tex='party/icon-dead',l=0,r=1,t=0,b=1}

local notification_priority = {}
notification_priority['EVENT_NEARBY'] = 1
notification_priority['QUEST'] = 2
notification_priority['SCENARIO'] =3
notification_priority['EVENT'] = 4
notification_priority['BOSS'] = 5
notification_priority['DEAD'] = 6


local updateLimit = 0

local function prioritys(a,b)
    
    if a == nil or a=='' then return true end
    if a == b then return true end

    return (notification_priority[a]>notification_priority[b])
    
end


function gwAddTrackerNotification (data)
    
    if data==nil or data['ID']==nil then return end
    
    notifications[data['ID']] = data
    
  --  gwSetObjectiveNotification()
        
end

function gwRemoveTrackerNotification (notificationID)
    if data==nil or notificationID==nil then return end
    notifications[data['ID']] = nil;
 --   gwSetObjectiveNotification()
        
end
function gwRemoveTrackerNotificationOfType(doType)
    
    for k,v in pairs(notifications) do
        if  v['TYPE']==doType then
             notifications[k] = nil
        end
    end
  --  gwSetObjectiveNotification()
        
end



function gwRemoveNotification(key)

        currentNotificationKey=''
        GwObjectivesNotification.shouldDisplay = false
    
end


function gwNotificationStateChanged(show)

        if show then
            GwObjectivesNotification:Show()
        end
        
       addToAnimation('notificationToggle', 0,70,GetTime(),0.2,function(step) 
       
                if show==false then
                   step = 70 - step
                end
            
                GwObjectivesNotification:SetAlpha(step/70)
                GwObjectivesNotification:SetHeight(step)
       end,nil, function()
                if not show then
                    GwObjectivesNotification:Hide()
                end
                GwObjectivesNotification.animating = false;
                gwQuestTrackerLayoutChanged()
            
        end,true) 
end

function gwSetObjectiveNotification()
    
    local data 
    
    
    for k,v in pairs( notifications) do
        

        if not notifications['COMPASS'] and notifications[k]~=nil then
        
            if data~=nil then
                if prioritys(data['KEY'],notifications[k]['KEY']) then
                    data = notifications[k]
                end
            else 
                data = notifications[k]
            end
        end
    end
   
    if data==nil and gwGetSetting('SHOW_QUESTTRACKER_COMPASS') then
        
        local index = gwGetCompassPriority()
        if index~=nil then 
            data = notifications[index]
        end
     end
    
    if data==nil then  gwRemoveNotification(currentNotificationKey)  return end

    local key =  data['KEY']
    local title = data['TITLE']
    local desc = data['DESC']
    local color = data['COLOR']
    local useRadar = data['COMPASS']
    local x = data['X']
    local y = data['Y']
    
    
    radarActive = useRadar
    
    if color==nil then color = {r=1,g=1,b=1} end


    currentNotificationKey = key
    
    currentNotificationType  = key
    
    if icons[data['TYPE']]~=nil then
         GwObjectivesNotification.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\'..icons[data['TYPE']].tex)
         GwObjectivesNotification.icon:SetTexCoord(icons[data['TYPE']].l,icons[data['TYPE']].r,icons[data['TYPE']].t,icons[data['TYPE']].b)   
    else
        GwObjectivesNotification.icon:SetTexture(nil)
    end
    
    if useRadar then
        GwObjectivesNotification.compass:Show()
        GwObjectivesNotification.compass.data = data;
        GwObjectivesNotification.compass.dataIndex = data['ID'];
        currentNotificationKey = key
    
        if icons[data['TYPE']]~=nil then
        GwObjectivesNotification.compass.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\'..icons[data['TYPE']].tex)
        GwObjectivesNotification.compass.icon:SetTexCoord(icons[data['TYPE']].l,icons[data['TYPE']].r,icons[data['TYPE']].t,icons[data['TYPE']].b)  
        else
            GwObjectivesNotification.compass.icon:SetTexture(nil)
        end
        
         GwObjectivesNotification.compass:SetScript('OnUpdate', function(self)
                if updateLimit<GetTime() then
                 --   gwSetObjectiveNotification()
                    updateLimit  = GetTime() + 5
                end
                gwUpdateRadarDirection(self)
            end)
        GwObjectivesNotification.icon:SetTexture(nil)
    else
        GwObjectivesNotification.compass:Hide()
        GwObjectivesNotification.compass:SetScript('OnUpdate', nil)
       
    end
    
    GwObjectivesNotification.title:SetText(title)
    GwObjectivesNotification.title:SetTextColor(color.r,color.g,color.b)
    GwObjectivesNotification.desc:SetText(desc)
    
    if desc==nil or desc=='' then
          GwObjectivesNotification.title:SetPoint('BOTTOM',GwObjectivesNotification, 'BOTTOM' ,0 ,30) 
    else
          GwObjectivesNotification.title:SetPoint('BOTTOM',GwObjectivesNotification, 'BOTTOM' ,0 ,15) 
    end
    GwObjectivesNotification.shouldDisplay = true

  
    
end


function gwGetCompassPriority()
  
    
   
    local closestIndex = nil
    local posX, posY  = 0
    
    local posX, posY  = GetPlayerMapPosition("player");
     
    if posX==nil or posX==0 then 
        return
    end
    
    
  
    local closest = math.huge
    for k,v in pairs(notifications) do
        if v['MAPID']~=nil then
            
            SetMapByID(v['MAPID'])


            local dx = v['X'] - posX
            local dy = v['Y'] - posY
            local dist = sqrt(dx * dx + dy * dy)
           
            if dist<closest then
                closest=dist
                closestIndex = k

            end
        end
    end

    if closestIndex==nil then
        return 
    end
   
    return closestIndex;
    
end

function gwUpdateRadarDirection(self)
    
      
    local pFaceing = GetPlayerFacing()
    local posX, posY  =GetPlayerMapPosition("player");
    if posX==nil or posX==0  or self.data['X']==nil then
        gwRemoveTrackerNotification(GwObjectivesNotification.compass.dataIndex)
    
        return
    end
        
        local dir_x  =self.data['X'] - posX
        local dir_y  =self.data['Y'] - posY

                
        local square_half = math.sqrt(0.5)
        local rad_135 = math.rad(135)
       
        local a  = math.atan2(dir_y, dir_x)
        a=-a
        
        a = a + rad_135
        a = a -pFaceing
		
		local sin,cos = math.sin(a) * square_half, math.cos(a) * square_half

        self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)

end





