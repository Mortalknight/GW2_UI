local _, GW = ...
local lerp = GW.lerp

local toastList = {}
local toastQueue = {}
local toastIndex = 0
local lastShown
local delayTime = 10
local talents = 0;
local ignoreNewSpells = 0


function gwToastAnimateFlare(self,delta)

        if self.removeTime<GetTime() and self.animatingOut==false then
        
        self.animatingOut = true
        
        local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint()
        
        addToAnimation(self:GetName(),0,1,GetTime(),0.5,function(prog)
       
            self:SetPoint(point,relativeTo,relativePoint,xOffset,lerp(yOffset,yOffset - 57,prog))
            self:SetAlpha(1 - prog)
          
            end,nil,function()  
                if lastShown== self:GetName() then
                    lastShown = nil
                end
                self:Hide() 
                self.animatingOut = false
                delayTime = delayTime - 5
            end)
        
        
        end
        local rot =  self.flare.rot  + (0.5 * delta) 
        self.flare:SetRotation(rot )
        self.flare2:SetRotation(-rot )
        self.flare.rot = rot

end
function gw_animate_levelUp_wiggle(self)
    if self.animation==nil then self.animation = 0 end
    if self.doingAnimation == true then return end
    self.doingAnimation = true
    addToAnimation(self:GetName()..'wig',0,1,GetTime(),2,function(prog)
       
       
        
       
        
        if prog<0.25 then
            self.icon:SetRotation( lerp(0,-0.25,math.sin((prog/0.25) * math.pi * 0.5) ))
           
        end
        if prog>0.25 and prog<0.75 then
             self.icon:SetRotation(lerp(-0.25,0.25, math.sin(((prog - 0.25)/0.5) * math.pi * 0.5)  ))
           
        end
        if prog>0.75 then
            self.icon:SetRotation(lerp(0.25,0, math.sin(((prog - 0.75)/0.25) * math.pi * 0.5)  ))
        end
            
        if prog>0.25 then
        end
          
    end,nil,function() self.doingAnimation = false end)
    
end
function gwToastOnShowAnimation(self)
    
    self.removeTime = GetTime() + delayTime
    delayTime = delayTime + 5
    if self.flare.animation==nil then self.flare.animation = 0 end
    if self.flare.doingAnimation == true then return end
    self.flare.doingAnimation = true
    addToAnimation(self.flare:GetName(),0,1,GetTime(),0.5,function(prog)
       
        local l = lerp(400,120,math.sin((prog) * math.pi * 0.5) )
        self.flare:SetSize(l,l)
       
          
    end,nil,function() self.flare.doingAnimation = false end)
    
 
end

function toastQueueAdd(data)
    toastQueue[#toastQueue + 1] = data 
    GwToastContainer:SetScript('OnUpdate',function()
            
            if GwToastContainer.DisplayEventTimer~=nil and GwToastContainer.DisplayEventTimer>GetTime() then
                return
            end
            GwToastContainer.DisplayEventTimer = GetTime() + 0.1
            
            local f = true
            for k,v in pairs(toastQueue) do
                if v~=nil and v['method']~=nil then
                    v['method']()
                    toastQueue[k] = nil
                    f = false
                    return
                end
            end
            if f==true then
                GwToastContainer:SetScript('OnUpdate',nil)
            end
            
    end);
end

local function getBloack (t)
   
    local f
    local template = 'GwToast'
    if t~=nil then template = t end
    if toastList[template]==nil then
        toastList[template] = {}
    end
    for k,v in pairs(toastList[template]) do
        if not v:IsShown() then
            f = v
            break
        end
    end
    if f==nil then
       f= CreateFrame('BUTTON','GwToast'..toastIndex,GwToastContainer,template)
        toastList[template][toastIndex] = v
        toastIndex = toastIndex + 1
    end
    
    if lastShown==nil then
        f:ClearAllPoints()
        f:SetPoint('BOTTOMRIGHT',GwToastContainer,'BOTTOMRIGHT',0,0)
    else
        f:ClearAllPoints()
        f:SetPoint('BOTTOMRIGHT',_G[lastShown]  ,'TOPRIGHT',0,10) 
    end
 
    
    
    
    lastShown = f:GetName()
    return f
end

local function toastRecive(itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, isPersonal, showRatedBG)
   
    local itemName, itemHyperLink, itemRarity, itemTexture;
	if (isCurrency) then
		itemName, _, itemTexture, _, _, _, _, itemRarity = GetCurrencyInfo(itemLink);
		if ( lootSource == LOOT_SOURCE_GARRISON_CACHE ) then
			itemName = format(GARRISON_RESOURCES_LOOT, quantity);
		else
			itemName = format(CURRENCY_QUANTITY_TEMPLATE, quantity, itemName);
		end
		itemHyperLink = itemLink;
	else
		itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
	end
    
    
	local baseQualityColor = ITEM_QUALITY_COLORS[baseQuality];
	local upgradeQualityColor = ITEM_QUALITY_COLORS[itemRarity];
    
    local frame = getBloack()
    
    frame.icon:SetTexture(itemTexture)
    
    frame.title:SetText(itemName)
    
    if isUpgraded then
        frame.sub:SetText(format(LOOTUPGRADEFRAME_TITLE, _G["ITEM_QUALITY"..itemRarity.."_DESC"]));
    else
        frame.sub:SetText(''); 
    end
       GwSetItemButtonQuality(frame, itemRarity,itemHyperLink)
    
    if ( lessAwesome ) then
		PlaySound(SOUNDKIT.UI_RAID_LOOT_TOAST_LESSER_ITEM_WON);
	elseif ( isUpgraded ) then
		PlaySound(SOUNDKIT.UI_WARFORGED_ITEM_LOOT_TOAST);
	else
     PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST);
	end
    
end

local function newSpellLearned(spellID)
    
    local frame = getBloack()
    
    local  name, rank, icon = GetSpellInfo(spellID)
    
    frame.icon:SetTexture(icon)
    
    frame.title:SetText(name)
    frame.sub:SetText('Unlocked')
    
    frame.IconBorder:SetVertexColor(0,0,0)
    
end

local function newTalentPoint()
    
    local frame = getBloack()
    
    local  name, rank, icon = GetSpellInfo(spellID)
    
    frame.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talent-icon')
    
    frame.title:SetText('Talent Point')
    frame.sub:SetText('A new talent point is avalible')
    
    frame.IconBorder:SetVertexColor(0,0,0,0)
    
end

local function levelUp(level)
    
    local frame = getBloack('GwToastLevelUp')
    
    
   
    
    frame.title:SetText('Level Up!')
    frame.sub:SetText('You reached level '..level)
    
    frame.IconBorder:SetVertexColor(0,0,0,0)
    
end

local function goldWon(amount)
    
    local frame = getBloack()
    
    frame.title:SetText('Gold')
   	frame.sub:SetText(GetMoneyString(amount));
    
	PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST);
	
 
end

local function onEvent(self,event,...)
    local newEvent = {}
    newEvent['event'] = event
    newEvent['method'] = function() end
    if ( event == "LOOT_ITEM_ROLL_WON" ) then
		local itemLink, quantity, rollType, roll, isUpgraded = ...;
          newEvent['method'] = function() toastRecive(itemLink, quantity, rollType, roll, nil, nil, nil, nil, nil, isUpgraded);
            end
    elseif ( event == "SHOW_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded = ...;
		if ( typeIdentifier == "item" ) then
			  newEvent['method'] = function() toastRecive(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isPersonal);
                end
            
		elseif ( typeIdentifier == "money" ) then
		  
		elseif ( isPersonal and (typeIdentifier == "currency") ) then
			-- only toast currency for personal loot
			  newEvent['method'] = function() toastRecive(itemLink, quantity, nil, nil, specID, true, false, lootSource);
                end
		end
    	elseif ( event == "SHOW_PVP_FACTION_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
		if ( typeIdentifier == "item" ) then
			  newEvent['method'] = function() toastRecive(itemLink, quantity, nil, nil, specID, false, true, nil, lessAwesome);
                end
		elseif ( typeIdentifier == "money" ) then

             newEvent['method'] = function() goldWon(quantity) end
		elseif ( typeIdentifier == "currency" ) then
			  newEvent['method'] = function() toastRecive(itemLink, quantity, nil, nil, specID, true, true);
                end
		end
	elseif ( event == "SHOW_RATED_PVP_REWARD_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
		if ( typeIdentifier == "item" ) then
			  newEvent['method'] = function() toastRecive(itemLink, quantity, nil, nil, specID, false, false, nil, lessAwesome, nil, nil, true);
                end
		elseif ( typeIdentifier == "money" ) then
            newEvent['method'] = function() goldWon(quantity) end
		elseif ( typeIdentifier == "currency" ) then
			  newEvent['method'] = function() toastRecive(itemLink, quantity, nil, nil, specID, true, false, nil, nil, nil, nil, true);
                end
		end
    elseif ( event == "SHOW_LOOT_TOAST_UPGRADE") then
		local itemLink, quantity, specID, sex, baseQuality, isPersonal, lessAwesome = ...;
		  newEvent['method'] = function() toastRecive(itemLink, quantity, specID, baseQuality, nil, nil, lessAwesome);
            end
    
    elseif ( event == "LEARNED_SPELL_IN_TAB" and ignoreNewSpells<GetTime()) then
		local spellID , tabId = ...;
		   newEvent['method'] = function()  newSpellLearned(spellID)  end
    elseif ( event == "PLAYER_LEVEL_UP") then
  
        local level, hp, mp, talentPoints, strength, agility, stamina, intellect, spirit = ...
        levelUp(level)
        if talentPoints~=nil and talentPoints>0 then
              newEvent['method'] = function() newTalentPoint() end
        end
      elseif ( event == "PLAYER_SPECIALIZATION_CHANGED") then
        for k,v in pairs(toastQueue) do
            if v~=nil and v['event']=='LEARNED_SPELL_IN_TAB' then
                toastQueue[k] = nil
            end
        end
    end
    toastQueueAdd(newEvent)
end

local function loadtoast()
    
    CreateFrame('FRAME','GwToastContainer',UIParent,'GwToastContainer')
    
   
        GwToastContainer:RegisterEvent('LOOT_ITEM_ROLL_WON')
        GwToastContainer:RegisterEvent('SHOW_LOOT_TOAST')
        GwToastContainer:RegisterEvent('SHOW_PVP_FACTION_LOOT_TOAST')
        GwToastContainer:RegisterEvent('SHOW_RATED_PVP_REWARD_TOAST')
        GwToastContainer:RegisterEvent('SHOW_LOOT_TOAST_UPGRADE')
        GwToastContainer:RegisterEvent('LEARNED_SPELL_IN_TAB')
        GwToastContainer:RegisterEvent('PLAYER_LEVEL_UP')
        GwToastContainer:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
  
        GwToastContainer:SetScript('OnEvent', onEvent)
    
        talents = GetNumUnspentTalents() 
    
   
end


function gwTestToast()
    onEvent(GwToastContainer,'PLAYER_LEVEL_UP',1,2,2,1)
end

function gwTestToastSpell()
    newSpellLearned(48181)  
	goldWon(50)
end

--loadtoast()