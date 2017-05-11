local toastList = {}
local toastIndex = 0
local lastShown
local delayTime = 10


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
        self.flare.rot = rot

end
function gwToastOnShowAnimation(self)
    
    self.removeTime = GetTime() + delayTime
    delayTime = delayTime + 5
    if self.flare.animation==nil then self.flare.animation = 0 end
    if self.flare.doingAnimation == true then return end
    self.flare.doingAnimation = true
    addToAnimation(self.flare:GetName(),0,1,GetTime(),0.5,function(prog)
       
        local l = lerp(250,120,math.sin((prog) * math.pi * 0.5) )
        self.flare:SetSize(l,l)
       
          
    end,nil,function() self.flare.doingAnimation = false end)
    
 
end

local function getBloack ()
   
    local f
    for k,v in pairs(toastList) do
        if not v:IsShown() then
            f = v
            break
        end
    end
    if f==nil then
       f= CreateFrame('BUTTON','GwToast'..toastIndex,GwToastContainer,'GwToast')
        toastList[toastIndex] = v
        toastIndex = toastIndex + 1
    end
    
    if lastShown==nil then
        f:ClearAllPoints()
        f:SetPoint('BOTTOMRIGHT',GwToastContainer,'BOTTOMRIGHT',0,0)
    else
        f:ClearAllPoints()
        f:SetPoint('BOTTOMRIGHT',_G[lastShown]  ,'TOPRIGHT',0,5) 
    end
 
    
    
    
    lastShown = f:GetName()
    return f
end

local function toastRecive(itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, isPersonal, showRatedBG)
   
    local itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
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
		PlaySoundKitID(51402);	--UI_Raid_Loot_Toast_Lesser_Item_Won
	elseif ( isUpgraded ) then
		PlaySoundKitID(51561);	-- UI_Warforged_Item_Loot_Toast
	else
		PlaySoundKitID(31578);	--UI_EpicLoot_Toast
	end
    
end


function gwTestToast()
    local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo("Treia's Handcrafted Shroud") 
    toastRecive(nil, link,1,nil, nil,nil, nil,nil,nil,false,true,false,false)
end

local function onEvent(self,event,...)
    
    if ( event == "LOOT_ITEM_ROLL_WON" ) then
		local itemLink, quantity, rollType, roll, isUpgraded = ...;
		toastRecive(itemLink, quantity, rollType, roll, nil, nil, nil, nil, nil, isUpgraded);
    elseif ( event == "SHOW_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded = ...;
		if ( typeIdentifier == "item" ) then
			toastRecive(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isPersonal);
            
		elseif ( typeIdentifier == "money" ) then
		  
		elseif ( isPersonal and (typeIdentifier == "currency") ) then
			-- only toast currency for personal loot
			toastRecive(itemLink, quantity, nil, nil, specID, true, false, lootSource);
		end
    	elseif ( event == "SHOW_PVP_FACTION_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
		if ( typeIdentifier == "item" ) then
			toastRecive(itemLink, quantity, nil, nil, specID, false, true, nil, lessAwesome);
		elseif ( typeIdentifier == "money" ) then
		--	MoneyWonAlertSystem:AddAlert(quantity);
		elseif ( typeIdentifier == "currency" ) then
			toastRecive(itemLink, quantity, nil, nil, specID, true, true);
		end
	elseif ( event == "SHOW_RATED_PVP_REWARD_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
		if ( typeIdentifier == "item" ) then
			toastRecive(itemLink, quantity, nil, nil, specID, false, false, nil, lessAwesome, nil, nil, true);
		elseif ( typeIdentifier == "money" ) then
		--	MoneyWonAlertSystem:AddAlert(quantity);
		elseif ( typeIdentifier == "currency" ) then
			toastRecive(itemLink, quantity, nil, nil, specID, true, false, nil, nil, nil, nil, true);
		end
    elseif ( event == "SHOW_LOOT_TOAST_UPGRADE") then
		local itemLink, quantity, specID, sex, baseQuality, isPersonal, lessAwesome = ...;
		toastRecive(itemLink, quantity, specID, baseQuality, nil, nil, lessAwesome);
    end
end

local function loadtoast()
    
    CreateFrame('FRAME','GwToastContainer',UIParent,'GwToastContainer')
    
   
        GwToastContainer:RegisterEvent('LOOT_ITEM_ROLL_WON')
        GwToastContainer:RegisterEvent('SHOW_LOOT_TOAST')
        GwToastContainer:RegisterEvent('SHOW_PVP_FACTION_LOOT_TOAST')
        GwToastContainer:RegisterEvent('SHOW_RATED_PVP_REWARD_TOAST')
        GwToastContainer:SetScript('OnEvent', onEvent)
end


loadtoast()