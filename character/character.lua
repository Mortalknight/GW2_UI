local STATS_ICONS ={
    STRENGTH ={l=0.75,r=1,t=0.75,b=1},
    AGILITY ={l=0.75,r=1,t=0.75,b=1},
    INTELLECT ={l=0.75,r=1,t=0.75,b=1},
    STAMINA ={l=0,r=0.25,t=0.25,b=0.5},
    ARMOR ={l=0.5,r=0.75,t=0,b=0.25},
    CRITCHANCE ={l=0.25,r=0.5,t=0.25,b=0.5},
    HASTE ={l=0,r=0.25,t=0.5,b=0.75},
    MASTERY ={l=0.75,r=1,t=0.25,b=0.5},
    --Needs icon
    MANAREGEN ={l=0.75,r=1,t=0.25,b=0.5},
    VERSATILITY ={l=0.25,r=0.5,t=0.5,b=0.75},
    LIFESTEAL  ={l=0.25,r=0.5,t=0.75,b=1},
    --Needs icon
    AVOIDANCE ={l=0,r=0.25,t=0.75,b=1},
    --DODGE needs icon
    DODGE ={l=0.5,r=0.75,t=0.5,b=0.75},
    
    BLOCK ={l=0.75,r=1,t=0.5,b=0.75},
    PARRY ={l=0,r=0.25,t=0,b=0.25},
    MOVESPEED  ={l=0.5,r=0.75,t=0.75,b=1},
}

local 
PAPERDOLL_STATCATEGORIES= {
	[1] = {
		categoryFrame = "AttributesCategory",
		stats = {
			[1] = { stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH },
			[2] = { stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY },
			[3] = { stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT },
			[4] = { stat = "STAMINA" },
			[5] = { stat = "ARMOR" },
			[6] = { stat = "MANAREGEN", roles =  { "HEALER" } },
		},
	},
	[2] = {
		categoryFrame = "EnhancementsCategory",
		stats = {
			[1] = { stat = "CRITCHANCE", hideAt = 0 },
			[2] = { stat = "HASTE", hideAt = 0 },
			[3] = { stat = "MASTERY", hideAt = 0 },
			[4] = { stat = "VERSATILITY", hideAt = 0 },
		
	
			[5] = { stat = "DODGE",  },
			[6] = { stat = "PARRY", hideAt = 0,  },
			[7] = { stat = "BLOCK", hideAt = 0,  },
            [8] = { stat = "AVOIDANCE", hideAt = 0 },
            [9] = { stat = "LIFESTEAL", hideAt = 0 },
			[10] = { stat = "MOVESPEED", hideAt = 0,  },
		},
	},
};

--[[

			[1] = { stat = "CRITCHANCE", hideAt = 0 },
			[2] = { stat = "HASTE", hideAt = 0 },
			[3] = { stat = "MASTERY", hideAt = 0 },
			[4] = { stat = "VERSATILITY", hideAt = 0 },
			[5] = { stat = "LIFESTEAL", hideAt = 0 },
			[6] = { stat = "AVOIDANCE", hideAt = 0 },
			[7] = { stat = "DODGE", roles =  { "TANK" } },
			[8] = { stat = "PARRY", hideAt = 0, roles =  { "TANK" } },
			[9] = { stat = "BLOCK", hideAt = 0, roles =  { "TANK" } },
]]--

local EquipSlotList = {}
local bagItemList = {}
local numBagSlotFrames = 0
local selectedInventorySlot = nil

local function getBagSlotFrame(i)
    
    if _G['gwPaperDollBagSlotButton'..i]~=nil then return _G['gwPaperDollBagSlotButton'..i] end
    
    local f = CreateFrame('Button','gwPaperDollBagSlotButton'..i,GwPaperDollBagItemList,'GwPaperDollBagItem')
    
    numBagSlotFrames = numBagSlotFrames + 1
    
    return f
    
end

 function GwupdateBagItemListAll()
    
    if selectedInventorySlot~=nil then return end
      
    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15
    
    for k,v in pairs(EquipSlotList) do 
     
        local id = v

        wipe(bagItemList)

        GetInventoryItemsForSlot(id, bagItemList) 


        for location, itemID in next, bagItemList do

            if not ( location - id == ITEM_INVENTORY_LOCATION_PLAYER ) then -- Remove the currently equipped item from the list

                local itemFrame = getBagSlotFrame(itemIndex)
                itemFrame.location = location

                updateBagItemButton(itemFrame)


                itemFrame:SetPoint('TOPLEFT',x,-y)    
                itemFrame:Show()
                itemFrame.itemSlot = id
                gridIndex = gridIndex + 1

                x = x + 49 + 3

                if gridIndex>4 then
                    gridIndex = 1 
                    x = 10
                    y = y + 49 +3
                end
                itemIndex = itemIndex + 1
                if itemIndex>36 then break end
            end

        end
    end
    for i=itemIndex,numBagSlotFrames do
        if _G['gwPaperDollBagSlotButton'..i]~=nil then  _G['gwPaperDollBagSlotButton'..i]:Hide() end
    end
    
end

local function updateBagItemList(itemButton)
    
    local id = itemButton.id or itemButton:GetID();
    if selectedInventorySlot~=id then return end
    
    wipe(bagItemList)
    
    GetInventoryItemsForSlot(id, bagItemList) 
    
    local gridIndex = 0
    local itemIndex = 1
    local x = 10
    local y = 15
    
    for location, itemID in next, bagItemList do
      
        if not ( location - id == ITEM_INVENTORY_LOCATION_PLAYER ) then -- Remove the currently equipped item from the list
		
            local itemFrame = getBagSlotFrame(itemIndex)
            itemFrame.location = location
            
            updateBagItemButton(itemFrame)
            
            
            itemFrame:SetPoint('TOPLEFT',x,-y)    
            itemFrame:Show()
            itemFrame.itemSlot = id
            gridIndex = gridIndex + 1
            
            x = x + 49 + 3
  
            if gridIndex>4 then
                gridIndex = 1 
                x = 10
                y = y + 49 +3
            end
            itemIndex = itemIndex + 1
		end
       if itemIndex>36 then break end
    end
    for i=itemIndex,numBagSlotFrames do
        if _G['gwPaperDollBagSlotButton'..i]~=nil then  _G['gwPaperDollBagSlotButton'..i]:Hide() end
    end
    
end


function updateBagItemButton(button)
    local location = button.location;
	if ( not location ) then
		return;
	end
   local id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality = EquipmentManager_GetItemInfoByLocation(location);
    button.ItemId = id
	local broken = ( maxDurability and durability == 0 );
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, count);
        if broken then
			SetItemButtonTextureVertexColor(button, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
		end
        

        if durability~=nil and(durability/maxDurability)<0.5 then
            sebuttonlf.repairIcon:Show()
            if (durability/maxDurability)==0 then
                button.repairIcon:SetTexCoord(0,1,0.5,1)
            else
                button.repairIcon:SetTexCoord(0,1,0,0.5)
            end
            
        else
            button.repairIcon:Hide()
        end
       
        button.UpdateTooltip = function () GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6); setTooltip(); end;
	
        

		GwSetItemButtonQuality(button, quality,id);

    end
end

function GwPaperDollBagItem_OnClick (self)
    
	local action = function() end
		
    if ( self.location ) then
        if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[self.itemSlot] ) then
            UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
            return;
        end
        local action = EquipmentManager_EquipItemByLocation(self.location, self.itemSlot);
        EquipmentManager_RunAction(action);
    end
end



function gwPaperDollStats_QueuedUpdate(self)
	self:SetScript("OnUpdate", nil);
	gwPaperDollUpdateStats();
end

function gwPaperDollUpdateUnitData()
    
    GwDressingRoom.characterName:SetText(UnitPVPName('player'))
    local spec = GetSpecialization();
    local localizedClass, englishClass, classIndex = UnitClass("player");
    local id, name, description, icon, background, role = GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"))
    
    
    local data = 'Level '..UnitLevel('player')..' '..name..' '..localizedClass
    
    GwDressingRoom.characterData:SetText(data)
    
end

function gwPaperDollStats_OnEvent(self,event,...)
    local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or
		event == "UNIT_MODEL_CHANGED" and unit == "player" ) then
		GwDressingRoom.model:SetUnit("player", false);
        gwPaperDollUpdateUnitData()
		return;
    end

	if ( not self:IsVisible() ) then
		return;
	end

	if ( unit == "player" ) then
		if ( event == "UNIT_LEVEL" ) then
			gwPaperDollUpdateUnitData();
		elseif ( event == "UNIT_DAMAGE" or
				event == "UNIT_ATTACK_SPEED" or
				event == "UNIT_RANGEDDAMAGE" or
				event == "UNIT_ATTACK" or
				event == "UNIT_STATS" or
				event == "UNIT_RANGED_ATTACK_POWER" or
				event == "UNIT_SPELL_HASTE" or
				event == "UNIT_MAXHEALTH" or
				event == "UNIT_AURA" or
				event == "UNIT_RESISTANCES") then
			self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate);
		end
	end

	if ( event == "COMBAT_RATING_UPDATE" or
			event == "MASTERY_UPDATE" or
			event == "SPEED_UPDATE" or
			event == "LIFESTEAL_UPDATE" or
			event == "AVOIDANCE_UPDATE" or
			event == "BAG_UPDATE" or
			event == "PLAYER_EQUIPMENT_CHANGED" or
			event == "PLAYER_BANKSLOTS_CHANGED" or
			event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or
			event == "PLAYER_DAMAGE_DONE_MODS") then
		self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate);
	elseif (event == "PLAYER_TALENT_UPDATE") then
		gwPaperDollUpdateUnitData();
		self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate);
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
		gwPaperDollUpdateStats();
	elseif ( event == "SPELL_POWER_CHANGED" ) then
		self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate);
	end

end

function gwPaperDollUpdateStats()
    local level = UnitLevel("player");
	local categoryYOffset = -5;
	local statYOffset = 0;

    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel();
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped)
    avgItemLevel = math.floor(avgItemLevel)
    if avgItemLevelEquipped<avgItemLevel then
        avgItemLevelEquipped = math.floor(avgItemLevelEquipped)..'('.. math.floor(avgItemLevel)..')'
    end
    
    GwDressingRoom.itemLevel:SetText(avgItemLevelEquipped)
    GwDressingRoom.itemLevel:SetTextColor(GetItemLevelColor())

	local spec = GetSpecialization();
	local role = GetSpecializationRole(spec);


	local statFrame = nil

	local lastAnchor;
    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

	for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
		local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame];
		local numStatInCat = 0;
		for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
			local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex];
			local showStat = true;
			if ( stat.primary ) then
				local primaryStat = select(7, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
				if ( stat.primary ~= primaryStat ) then
					showStat = false;
				end
			end
			if ( showStat and stat.roles ) then
				local foundRole = false;
				for _, statRole in pairs(stat.roles) do
					if ( role == statRole ) then
						foundRole = true;
						break;
					end
				end
				showStat = foundRole;
			end
            
            if stat.stat=='MASTERY' and (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
                showStat=false
            end
            
			if ( showStat ) then
            
                statFrame =  gwPaperDollGetStatListFrame(GwPapaerDollStats,numShownStats)
                statFrame.stat = stat.stat
				statFrame.onEnterFunc = nil;
				PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player");
                
                gwPaperDollSetStatIcon(statFrame, stat.stat)

                statFrame:SetPoint('TOPLEFT',5 + x,-35 + -y)
                grid = grid + 1
                x = x + 92
  
                if grid>2 then
                   grid = 1 
                   x = 0
                   y = y + 35
                end
                

               numShownStats = numShownStats + 1
                    
                    
			end
		end
		
	end


end

function gwPaperDollSetStatIcon(self, stat)
    
    local newTexture = 'Interface\\AddOns\\GW2_UI\\textures\\character\\statsicon'
    if STATS_ICONS[stat]~=nil then
       
        -- If mastery we use need to use class icon
        if stat=='MASTERY' then
            gw_setClassIcon(self.icon,classIndex)
            newTexture='Interface\\AddOns\\GW2_UI\\textures\\party\\classicons'
        else
            
        self.icon:SetTexCoord(STATS_ICONS[stat].l,STATS_ICONS[stat].r,STATS_ICONS[stat].t,STATS_ICONS[stat].b)
     end
    end
    
    if newTexture~=self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
    end

    
end
function gwPaperDollGetStatListFrame(self,i)
    
    if _G['GwPaperDollStat'..i]~=nil then return _G['GwPaperDollStat'..i] end
    
    return CreateFrame('Frame','GwPaperDollStat'..i,self,'GwPaperDollStat')
    
end

function gwActionButtonGlobalStyle(self)
  
    self.IconBorder:SetSize(self:GetSize(),self:GetSize())
    _G[self:GetName().."IconTexture"]:SetTexCoord(0.1,0.9,0.1,0.9)
    _G[self:GetName().."NormalTexture"]:SetSize(self:GetSize(),self:GetSize())
    _G[self:GetName().."NormalTexture"]:Hide()
    self.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')

    _G[self:GetName().."NormalTexture"]:SetTexture(nil)
    _G[self:GetName()]:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed')
    _G[self:GetName()]:SetHighlightTexture(nil)
   
end
function gwPaperDollSlotButton_OnLoad(self)
    self:RegisterForDrag("LeftButton");
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	local slotName = self:GetName();
	local id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,12));
	self:SetID(id);
    EquipSlotList[#EquipSlotList + 1] =id
	self.checkRelic = checkRelic;



    gwActionButtonGlobalStyle(self)
   
end
function gwPaperDollSlotButton_OnShow (self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");
	self:RegisterEvent("SHOW_COMPARE_TOOLTIP");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
    gwPaperDollSlotButton_Update(self)

end
function gwPaperDollSlotButton_OnHide (self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("MERCHANT_UPDATE");
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("CURSOR_UPDATE");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("SHOW_COMPARE_TOOLTIP");
	self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
end
function gwPaperDollSlotButton_OnEvent (self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		if ( self:GetID() == arg1 ) then
			gwPaperDollSlotButton_Update(self);
            updateBagItemList(self)
            
		end
	end
    if ( event == "BAG_UPDATE_COOLDOWN" ) then
	
			gwPaperDollSlotButton_Update(self);
	
	end
end

function gwPaperDollSlotButton_OnEnter (self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	
	if ( not EquipmentFlyout_SetTooltipAnchor(self) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true);
	if ( not hasItem ) then
		local text = _G[strupper(strsub(self:GetName(), 12))];
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			text = RELICSLOT;
		end
		GameTooltip:SetText(text);
	end
	if ( InRepairMode() and repairCost and (repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	else
		CursorUpdate(self);
	end
end

function gwPaperDollSlotButton_OnModifiedClick (self, button)
	if ( HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID())) ) then
		return;
	end
	if ( IsModifiedClick("SOCKETITEM") ) then
		SocketInventoryItem(self:GetID());
	end
end
function gwPaperDollSlotButton_OnClick (self, button,drag)
    if drag==nil then 
        
        GwPaperDollSelectedIndicator:SetPoint('LEFT',self,'LEFT',-16,0)
        GwPaperDollSelectedIndicator:Show()
        selectedInventorySlot = self:GetID()
        updateBagItemList(self)

        
        return
    end
	MerchantFrame_ResetRefundItem();
	if ( button == "LeftButton" ) then
		local type = GetCursorInfo();
		if ( type == "merchant" and MerchantFrame.extendedCost ) then
			MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
		else
			PickupInventoryItem(self:GetID());
			if ( CursorHasItem() ) then
				MerchantFrame_SetRefundItem(self, 1);
			end
		end
      

	end
end

function gwPaperDollSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	GameTooltip:Hide();
	ResetCursor();
end

function gwPaperDollSlotButton_Update (self)
    
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local cooldown = _G[self:GetName().."Cooldown"];
	if ( textureName ) then
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
		if ( GetInventoryItemBroken("player", self:GetID())
		  or GetInventoryItemEquippedUnusable("player", self:GetID()) ) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
			
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
			
		end
        
        local current, maximum = GetInventoryItemDurability(self:GetID());
        if current~=nil and(current/maximum)<0.5 then
            self.repairIcon:Show()
            if (current/maximum)==0 then
                self.repairIcon:SetTexCoord(0,1,0.5,1)
            else
                self.repairIcon:SetTexCoord(0,1,0,0.5)
            end
            
        else
            self.repairIcon:Hide()
        end
        
		if ( cooldown ) then
			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
			CooldownFrame_Set(cooldown, start, duration, enable);
		end
		self.hasItem = 1;
	else
        SetItemButtonTexture(self, nil);
    end

	local quality = GetInventoryItemQuality("player", self:GetID());
	GwSetItemButtonQuality(self, quality, GetInventoryItemID("player", self:GetID()));
    
  


end


function GwPaperDollResetBagInventory()
    
    print('Reseting Inventory Display')
    
    GwPaperDollSelectedIndicator:Hide()
    selectedInventorySlot = nil
    GwupdateBagItemListAll()
    
end


function GwPaperDollIndicatorAnimation(self)
    local name = self:GetName()
    local point , relat , relPoint , startX, yof = self:GetPoint()

    addToAnimation(name,0,1,GetTime(),1,function(step) 
            
        local point , relat , relPoint , xof, yof = self:GetPoint()
        if step<0.5 then
            step = step/0.5
            self:SetPoint(point,relat,relPoint,startX + (-8*step),yof)
        else
             step = (step - 0.5) /0.5
            self:SetPoint(point,relat,relPoint,(startX - 8) + (8*step),yof)
        end
        
    end,nil,function()
        if self:IsShown() then
            GwPaperDollIndicatorAnimation(self)
        end
    end)
end

function GwSetItemButtonQuality(button, quality, itemIDOrLink)

	if quality then
		if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
			button.IconBorder:Show();
			button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
		else
			button.IconBorder:Hide();
		end
	else
		button.IconBorder:Hide();
	end
end



function gw_register_character_window()
   
    CreateFrame('Frame','GwCharacterWindowMoverFrame',UIParent,'GwCharacterWindowMoverFrame')
    CreateFrame('Frame','GwCharacterWindow',UIParent,'GwCharacterWindow')
    CreateFrame('Button','GwDressingRoom',GwCharacterWindow,'GwDressingRoom')
    CreateFrame('Frame','GwPaperDollBagItemList',GwCharacterWindow,'GwPaperDollBagItemList')
    CreateFrame('Frame','GwPaperDollSelectedIndicator',GwCharacterWindow,'GwPaperDollSelectedIndicator')
    
    PaperDollFrame:HookScript('OnShow',function() GwCharacterWindow:Show() end)
    PaperDollFrame:HookScript('OnHide',function() GwCharacterWindow:Hide() end)
 --   GwCharacterWindow:Hide()
    gwPaperDollUpdateStats()
    
end
