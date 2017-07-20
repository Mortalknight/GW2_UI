local gender = UnitSex("player");

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


local savedItemSlots = {}
local savedPlayerTitles = {}

local savedReputation = {}

local selectedReputationCat = 1
local reputationLastUpdateMethod = function() end
local reputationLastUpdateMethodParams = nil

local expandedFactions = {}

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
            button.repairIcon:Show()
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

	if name ~= nil then
		local data = GwLocalization['CHARACTER_LEVEL']..' '..UnitLevel('player')..' '..name..' '..localizedClass	
		GwDressingRoom.characterData:SetText(data)
	end
    
end

function gwPaperDollStats_OnEvent(self,event,...)
    local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or
		event == "UNIT_MODEL_CHANGED" or event=='UNIT_NAME_UPDATE' and unit == "player" ) then
		GwDressingRoom.model:SetUnit("player", false);
        gwPaperDollUpdateUnitData()
		return;
    end

	--if ( not self:IsVisible() ) then
		--return;
	--end

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
				event == "UNIT_RESISTANCES" or
				IsMounted()) then
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
			event == "PLAYER_DAMAGE_DONE_MODS" or
			IsMounted()) then
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
				local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
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
			local localizedClass, englishClass, classIndex = UnitClass("player");
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
        if InCombatLockdown() then return end  
            GwCharacterWindow:SetAttribute('windowPanelOpen',0)
      
	end
end
function gwPaperDollSlotButton_OnClick (self, button,drag)
   
    MerchantFrame_ResetRefundItem();
    if ( button == "LeftButton" ) then
        local infoType = GetCursorInfo();
        if ( type == "merchant" and MerchantFrame.extendedCost ) then
            MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
        else     
        
       
            if not SpellIsTargeting() and (drag==nil and GwPaperDollBagItemList:IsShown()) then 
                GwPaperDollSelectedIndicator:SetPoint('LEFT',self,'LEFT',-16,0)
                GwPaperDollSelectedIndicator:Show()
                selectedInventorySlot = self:GetID()
                updateBagItemList(self)  
            else
                PickupInventoryItem(self:GetID());
                if ( CursorHasItem() ) then
                    MerchantFrame_SetRefundItem(self, 1);
                end
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
    
    if savedItemSlots[self:GetID()]==nil then
        savedItemSlots[self:GetID()]=self
        self.ignoreSlotCheck:SetScript('OnClick',function() 
    
            if not self.ignoreSlotCheck:GetChecked() then
                EquipmentManagerIgnoreSlotForSave(self:GetID())
            else
                EquipmentManagerUnignoreSlotForSave(self:GetID())
            end
        end)
        
    end
    
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


function gwCharacterPanelToggle(frame)
    
    PlaySound("igMainMenuOptionCheckBoxOn");

  
    
    GwPaperDollBagItemList:Hide()
    GwCharacterMenu:Hide()
    GwPaperDollOutfits:Hide()
    GwPaperTitles:Hide()
    
    GwPaperReputation:Hide()
    
    if frame~=nil then
        frame:Show() 
    else
        GwDressingRoom:Hide()
        return
    end
    
    if frame:GetName()=='GwPaperReputation' then GwDressingRoom:Hide() else GwDressingRoom:Show() end
    
end
local function getNewEquipmentSetButton(i)
    
    if _G['GwPaperDollOutfitsButton'..i]~=nil then return _G['GwPaperDollOutfitsButton'..i] end
    
    local f = CreateFrame('Button','GwPaperDollOutfitsButton'..i,GwPaperDollOutfits,'GwPaperDollOutfitsButton')
    
    if i>1 then
        _G['GwPaperDollOutfitsButton'..i]:SetPoint('TOPLEFT', _G['GwPaperDollOutfitsButton'..(i - 1)],'BOTTOMLEFT')
    end
    GwPaperDollOutfits.buttons = GwPaperDollOutfits.buttons + 1
    
    f.standardOnClick = f:GetScript('OnEnter')
    
    f:GetFontString():ClearAllPoints()
    f:GetFontString():SetPoint('TOP',f,'TOP',0,-20)
    
    return f
end

 function GwOutfitsDrawItemSetList()
    
    if GwPaperDollOutfits.buttons ==nil then GwPaperDollOutfits.buttons = 0 end
    
    local numSets = GetNumEquipmentSets()
    local numButtons = GwPaperDollOutfits.buttons
    
    if numSets>numButtons then
        numButtons =numSets
    end
    local textureC = 1
    
    for i=1,numButtons do
        if numSets>=i then
            
            local frame = getNewEquipmentSetButton(i)
            
            local name, texture, setID, isEquipped, _, _, _, numLost = GetEquipmentSetInfo(i);
            
            frame:Show()
            frame.saveOutfit:Hide()
            frame.deleteOutfit:Hide()
            frame.equipOutfit:Hide()
            frame.ddbg:Hide()
            frame:SetHeight(49)
            
            frame:SetScript('OnEnter',function(self) 
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                GameTooltip:SetEquipmentSet(self.setName);    
                self.standardOnClick(self)
            end)
      
            frame:SetText(name)
            frame.setName = name
    
            
            if texture then
                frame.icon:SetTexture(texture)
            else
                frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") 
            end
            
           if textureC==1 then frame:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg')
                textureC = 2
            else
                frame:SetNormalTexture(nil)
               textureC = 1 
            end
            if isEquipped then
                frame:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
            end
            if numLost>0 then
              --  _G[frame:GetName()..'NormalTexture']:SetVertexColor(1,0.3,0.3)
                frame:GetFontString():SetTextColor(1,0.3,0.3)
            else
                --_G[frame:GetName()..'NormalTexture']:SetVertexColor(1,1,1)
                 frame:GetFontString():SetTextColor(1,1,1)
            end
            
            frame.setId = setID
            
            
            
        else
            if _G['GwPaperDollOutfitsButton'..i]~=nil then
                _G['GwPaperDollOutfitsButton'..i]:Hide()
            end
        end
        
    end
    
end

function GwPaperDollOutfitsUpdateIngoredSlots(name)

   local ignoredSlots = GetEquipmentSetIgnoreSlots(name);
    for slot, ignored in pairs(ignoredSlots) do
        if ( ignored ) then
            EquipmentManagerIgnoreSlotForSave(slot);
            savedItemSlots[slot].ignoreSlotCheck:SetChecked(false)
        else
            EquipmentManagerUnignoreSlotForSave(slot);
            savedItemSlots[slot].ignoreSlotCheck:SetChecked(true)
        end
    end 
end

function GwPaperDollOutfitsToggleIgnoredSlots(show)
    
    for k,v in pairs(savedItemSlots) do
        if show then
            v.ignoreSlotCheck:Show()
        else
            v.ignoreSlotCheck:Hide() 
        end
    end
    
end

function GwPaperDollOutfits_OnEvent(self, event, ...)


	if ( event == "EQUIPMENT_SWAP_FINISHED" ) then
		local completed, setName = ...;
		if ( completed ) then
			PlaySoundKitID(1212); -- plays the equip sound for plate mail
			if (self:IsShown()) then
				self.selectedSetName = setName;
				GwOutfitsDrawItemSetList();
			end
		end
	end


	if (self:IsShown()) then
		if ( event == "EQUIPMENT_SETS_CHANGED" ) then
			GwOutfitsDrawItemSetList();
		elseif ( event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE" ) then
            GwPaperDollOutfits:SetScript('OnUpdate',function(self)
                    GwOutfitsDrawItemSetList()
                    GwPaperDollOutfits:SetScript('OnUpdate',nil)
            end)
		end
	end
end 

local function getNewTitlesButton(i)
    
    if _G['GwPaperDollTitleButton'..i]~=nil then return _G['GwPaperDollTitleButton'..i] end
    
    local f = CreateFrame('Button','GwPaperDollTitleButton'..i,GwPaperTitles,'GwCharacterMenuBlank')
    
    if i>1 then
        _G['GwPaperDollTitleButton'..i]:SetPoint('TOPLEFT', _G['GwPaperDollTitleButton'..(i - 1)],'BOTTOMLEFT')
    else
        _G['GwPaperDollTitleButton'..i]:SetPoint('TOPLEFT',GwPaperTitles,'TOPLEFT')
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint('LEFT',5 ,0)
    GwPaperTitles.buttons = GwPaperTitles.buttons + 1
    
 --   f:GetFontString():ClearAllPoints()
--    f:GetFontString():SetPoint('TOP',f,'TOP',0,-20)
    
    return f
end


function GwPaperDollUpdateTitlesList()
    
    savedPlayerTitles[1] = {}
    savedPlayerTitles[1].name ='       '
    savedPlayerTitles[1].id =-1
    
    local tableIndex = 1
    
    for i = 1, GetNumTitles() do
		if ( IsTitleKnown(i) ) then
			tempName, playerTitle = GetTitleName(i);
            if ( tempName and playerTitle ) then
                tableIndex = tableIndex  + 1
                local tempName, playerTitle = GetTitleName(i);
                savedPlayerTitles[tableIndex]={}
                savedPlayerTitles[tableIndex].name = strtrim(tempName);
                savedPlayerTitles[tableIndex].id = i
            end
        end
    end
    
    table.sort(savedPlayerTitles,function(a, b) return a.name < b.name end)
    savedPlayerTitles[1].name = PLAYER_TITLE_NONE

end
function GwPaperDollUpdateTitlesLayout()
    
    local currentTitle = GetCurrentTitle();
    local textureC = 1
    local buttonId = 1
    
    for i=GwPaperTitles.scroll, #savedPlayerTitles  do
    
        if savedPlayerTitles[i]~=nil then 
            local button = getNewTitlesButton(buttonId)
            button:Show()
            buttonId = buttonId + 1
            button:SetText(savedPlayerTitles[i].name)
            button:SetScript('OnClick', function() SetCurrentTitle(savedPlayerTitles[i].id)  end)

            if textureC==1 then
                button:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg')
                textureC = 2
            else
                button:SetNormalTexture(nil)
                textureC = 1 
            end 

            if currentTitle == savedPlayerTitles[i].id then
                button:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
            end
            if buttonId>21 then break end
        end
    end
    
    for i=buttonId,GwPaperTitles.buttons do
         _G['GwPaperDollTitleButton'..i]:Hide()
    end
    
end

function GwPaperDollTitles_OnEvent()
    GwPaperDollUpdateTitlesList()
    GwPaperDollUpdateTitlesLayout()
end


local function getNewReputationCat(i)
    if _G['GwPaperDollReputationCat'..i]~=nil then return _G['GwPaperDollReputationCat'..i] end
    
    local f = CreateFrame('Button','GwPaperDollReputationCat'..i,GwPaperReputation,'GwPaperDollReputationCat')
    
    if i>1 then
        _G['GwPaperDollReputationCat'..i]:SetPoint('TOPLEFT', _G['GwPaperDollReputationCat'..(i - 1)],'BOTTOMLEFT')
    else
        _G['GwPaperDollReputationCat'..i]:SetPoint('TOPLEFT',GwPaperReputation,'TOPLEFT')
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint('TOPLEFT',10 ,-10)
    GwPaperReputation.buttons = GwPaperReputation.buttons + 1
    
 --   f:GetFontString():ClearAllPoints()
--    f:GetFontString():SetPoint('TOP',f,'TOP',0,-20)
    
    return f
end


function GwUpdateSavedReputation()
    
     for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
        savedReputation[factionIndex] = {}
         savedReputation[factionIndex].name, savedReputation[factionIndex].description, savedReputation[factionIndex].standingId, savedReputation[factionIndex].bottomValue, savedReputation[factionIndex].topValue,savedReputation[factionIndex].earnedValue, savedReputation[factionIndex].atWarWith, savedReputation[factionIndex].canToggleAtWar, savedReputation[factionIndex].isHeader, savedReputation[factionIndex].isCollapsed, savedReputation[factionIndex].hasRep, savedReputation[factionIndex].isWatched, savedReputation[factionIndex].isChild,  savedReputation[factionIndex].factionID, savedReputation[factionIndex].hasBonusRepGain, savedReputation[factionIndex].canBeLFGBonus = GetFactionInfo(factionIndex)
    end 

end

local function returnReputationData(factionIndex)

    if savedReputation[factionIndex]==nil then return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil end
    return savedReputation[factionIndex].name, savedReputation[factionIndex].description, savedReputation[factionIndex].standingId, savedReputation[factionIndex].bottomValue, savedReputation[factionIndex].topValue,savedReputation[factionIndex].earnedValue, savedReputation[factionIndex].atWarWith, savedReputation[factionIndex].canToggleAtWar, savedReputation[factionIndex].isHeader, savedReputation[factionIndex].isCollapsed, savedReputation[factionIndex].hasRep, savedReputation[factionIndex].isWatched, savedReputation[factionIndex].isChild, savedReputation[factionIndex].factionID, savedReputation[factionIndex].hasBonusRepGain, savedReputation[factionIndex].canBeLFGBonus
end



function GwPaperDollUpdateReputations()
    
    ExpandAllFactionHeaders()
    
    local headerIndex = 1
    local CurrentOwner =nil
    local cMax = 0
    local cCur = 0
    local textureC = 1 
    
    for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
        
        local  name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = returnReputationData(factionIndex)
		if name~=nil then 
            
            cCur = cCur + standingId
            cMax = cMax + 8

            if isHeader and not isChild then
			
				local header = getNewReputationCat(headerIndex)
                header:Show()
                CurrentOwner = header
                header:SetText(name)

                if CurrentOwner~=nil then
                    CurrentOwner.StatusBar:SetValue(cCur/cMax)
                end

                cCur = 0
                cMax = 0

                headerIndex = headerIndex + 1

                header:SetScript('OnClick',function() GwReputationShowReputationHeader(factionIndex ) GwUpdateReputationDetails() end)

                if textureC==1 then
                    header:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg')
                    textureC = 2
                else
                    header:SetNormalTexture(nil)
                    textureC = 1 
                end 
            end
        end

        if CurrentOwner~=nil then
            CurrentOwner.StatusBar:SetValue(cCur/cMax)
			if cCur/cMax >= 1 and cMax ~= 0 then
				CurrentOwner.StatusBar:SetStatusBarColor(171/255,37/255,240/255)
			else	
				CurrentOwner.StatusBar:SetStatusBarColor(240/255,240/255,155/255)
			end
        end
        
    end
    
    for i=headerIndex,GwPaperReputation.buttons do
         _G['GwPaperDollReputationCat'..i]:Hide()
    end
    
end


function GwReputationShowReputationHeader(i)
    selectedReputationCat = i
end


local function getNewReputationDetail(i)
    if _G['GwReputationDetails'..i]~=nil then return _G['GwReputationDetails'..i] end
    
    local f = CreateFrame('Button','GwReputationDetails'..i,GwPaperReputationScrollFrame.scrollchild,'GwReputationDetails')
    
    if i>1 then
        _G['GwReputationDetails'..i]:SetPoint('TOPLEFT', _G['GwReputationDetails'..(i - 1)],'BOTTOMLEFT',0,-1)
    else
        _G['GwReputationDetails'..i]:SetPoint('TOPLEFT',GwPaperReputationScrollFrame.scrollchild,'TOPLEFT',2,-10)
    end

    GwPaperReputation.detailFrames =  GwPaperReputation.detailFrames + 1
    

    return f
end

local function SetReputationDetailFrameData(frame,factionIndex,savedHeaderName,name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus )
    
    frame:Show()
      
            frame.factionIndex = factionIndex
  
            
            
            if expandedFactions[factionIndex]==nil then
                frame.controles:Hide()
                frame:SetHeight(80)
            else
                frame:SetHeight(140)
                frame.controles:Show()
            end
            
            local currentRank = GetText("FACTION_STANDING_LABEL"..math.min(8,math.max(1,standingId)), gender);
            local nextRank = GetText("FACTION_STANDING_LABEL"..math.min(8,math.max(1,standingId + 1)), gender);
			
            
            
            
            if textureC==1 then
                frame.background:SetTexture(nil)
                textureC = 2
            else
                frame.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg')
                textureC = 1 
            end 

			frame.name:SetText(name..savedHeaderName)
			frame.details:SetText(description)

            
            if atWarWith then
                frame.controles.atwar.isActive = true
                frame.controles.atwar.icon:SetTexCoord(0.5,1,0,0.5)
            else
                frame.controles.atwar.isActive = false
                frame.controles.atwar.icon:SetTexCoord(0,0.5,0,0.5)
            end 
            
            if canToggleAtWar then
                frame.controles.atwar.isShowAble = true
            else
                frame.controles.atwar.isShowAble = false
            end
            
            if isWatched then
                frame.controles.showAsBar:SetChecked(true)
            else
                frame.controles.showAsBar:SetChecked(false)
            end
            
                      
            if IsFactionInactive(factionIndex) then
                frame.controles.inactive:SetChecked(true)
            else
                frame.controles.inactive:SetChecked(false)
            end
            
            frame.controles.inactive:SetScript('OnClick', function() 
                    if IsFactionInactive(factionIndex) then
                        SetFactionActive(factionIndex)
                    else
                        SetFactionInactive(factionIndex)
                    end
                    GwUpdateSavedReputation()
                    GwPaperDollUpdateReputations()
                    GwUpdateReputationDisplayOldData()
            end)
            
            if canBeLFGBonus then
                 frame.controles.favorit.isShowAble = true
                    frame.controles.favorit:SetScript('OnClick',function() 
                        ReputationBar_SetLFBonus(factionID);
                        GwUpdateSavedReputation()
                        GwUpdateReputationDisplayOldData()
                    end)
            else
                 frame.controles.favorit.isShowAble = false
            end
            
            frame.controles.atwar:SetScript('OnClick', function() 
                FactionToggleAtWar(factionIndex)
                if canToggleAtWar then
                    GwUpdateSavedReputation()
                    GwUpdateReputationDisplayOldData()
                end
            end)
            
            frame.controles.showAsBar:SetScript('OnClick', function() 
                if isWatched then
                    SetWatchedFactionIndex(0)
                else
                    SetWatchedFactionIndex(factionIndex)
                end
                    GwUpdateSavedReputation()
                    GwUpdateReputationDisplayOldData()
            end)
  
            
            	SetFactionInactive(GetSelectedFaction());
            
			if factionID and C_Reputation.IsFactionParagon(factionID) then
				local currentValue, maxValueParagon, _, hasReward  = C_Reputation.GetFactionParagonInfo(factionID)
				if hasReward then 
					--frame.paragon:Hide()
					if currentValue > 10000 then 
						repeat
							currentValue = currentValue - 10000
						until( currentValue < 10000 )
					end
				else
					--frame.paragon:Hide()
					if currentValue > 10000 then 
						repeat
							currentValue = currentValue - 10000
						until( currentValue < 10000 )
					end
				end
				
				
				frame.currentRank:SetText(currentRank)
				frame.nextRank:SetText(GwLocalization['CHARACTER_PARAGON'])
				
				frame.currentValue:SetText(comma_value(currentValue))
				frame.nextValue:SetText(comma_value(maxValueParagon))
				
				local percent = math.floor(round(((currentValue - 0) / (maxValueParagon - 0))*100),0)
				frame.percentage:SetText((math.floor( round(((currentValue - 0) / (maxValueParagon - 0))*100),0) )..'%')
				
				frame.StatusBar:SetMinMaxValues(0, 1)
				frame.StatusBar:SetValue((currentValue - 0) / (maxValueParagon - 0))	
				
				frame.background2:SetVertexColor(GW_FACTION_BAR_COLORS[9].r,GW_FACTION_BAR_COLORS[9].g,GW_FACTION_BAR_COLORS[9].b)
				frame.StatusBar:SetStatusBarColor(GW_FACTION_BAR_COLORS[9].r,GW_FACTION_BAR_COLORS[9].g,GW_FACTION_BAR_COLORS[9].b)
			else
			    frame.currentRank:SetText(currentRank)
				frame.nextRank:SetText(nextRank)
				frame.currentValue:SetText(comma_value(earnedValue - bottomValue))
				local percent = math.floor(round(((earnedValue - bottomValue) / (topValue - bottomValue))*100),0)
				if percent == -1 then 
					frame.percentage:SetText('0%')
				else
					frame.percentage:SetText((math.floor( round(((earnedValue - bottomValue) / (topValue - bottomValue))*100),0) )..'%')
				end
				
				frame.nextValue:SetText(comma_value(topValue - bottomValue))
				
				frame.StatusBar:SetMinMaxValues(0, 1)
				frame.StatusBar:SetValue((earnedValue - bottomValue) / (topValue - bottomValue))
				
				if currentRank == nextRank and earnedValue - bottomValue == 0 then
					frame.percentage:SetText('100%')
					frame.StatusBar:SetValue(1)
					frame.nextValue:SetText()
					frame.currentValue:SetText()
				end 
				
				frame.background2:SetVertexColor(GW_FACTION_BAR_COLORS[standingId].r,GW_FACTION_BAR_COLORS[standingId].g,GW_FACTION_BAR_COLORS[standingId].b)
				frame.StatusBar:SetStatusBarColor(GW_FACTION_BAR_COLORS[standingId].r,GW_FACTION_BAR_COLORS[standingId].g,GW_FACTION_BAR_COLORS[standingId].b)
			end
            
            
            
 
end

function GwUpdateReputationDetails()
    
    local buttonIndex = 1
    local gender = UnitSex("player");
    local savedHeaderName = ''
    local savedHeight = 0
    local textureC = 1
    
    for factionIndex = selectedReputationCat + 1, GetNumFactions() do
     
        local  name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = returnReputationData(factionIndex)
        if name~=nil then
    
            if isHeader and not isChild then break end

            if isHeader and isChild then 

               savedHeaderName = ' |cFFa0a0a0'..name..'|r'
            end

            if not isChild then 
                savedHeaderName = ''
            end



            local frame = getNewReputationDetail(buttonIndex)
            
            SetReputationDetailFrameData(frame,factionIndex,savedHeaderName, name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus)
               
            savedHeight = savedHeight + frame:GetHeight()

            buttonIndex = buttonIndex + 1
    
        end
        
    end
    
    for i=buttonIndex, GwPaperReputation.detailFrames do
         _G['GwReputationDetails'..i]:Hide()
    end
  
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
 
    
    GwPaperReputationScrollFrame.slider.thumb:SetHeight(100)
    GwPaperReputationScrollFrame.slider:SetValue(1)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.savedHeight = savedHeight - 590
    
    
    reputationLastUpdateMethod = GwUpdateReputationDetails
    
end

function GwReputationSearch(a,b)
    return string.find(a, b)
end

function GwDetailFaction(factionIndex,boolean)
    if boolean then
        expandedFactions[factionIndex] = true 

        return
    end
    expandedFactions[factionIndex] = nil
    
    
end

function GwUpdateReputationDetailsSearch(s)
    
    local buttonIndex = 1

    local savedHeaderName = ''
    local savedHeight = 0
    local textureC = 1
    
    for factionIndex = 1, GetNumFactions() do
     
        local  name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = returnReputationData(factionIndex)
        
        
        local lower1 = string.lower(name)
        local lower2 = string.lower(s)
        
        local show = true
        
        if isHeader then
           if not isChild then
                show = false
            end
        end
       
        
        if  (name~=nil and GwReputationSearch(lower1,lower2)~=nil) and show  then

            



            local frame = getNewReputationDetail(buttonIndex)
         
            SetReputationDetailFrameData(frame,factionIndex,savedHeaderName, name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus)
            
            savedHeight = savedHeight + frame:GetHeight()

            buttonIndex = buttonIndex + 1
            
           
    
        end
        
    end
    
    for i=buttonIndex, GwPaperReputation.detailFrames do
         _G['GwReputationDetails'..i]:Hide()
    end

    GwPaperReputationScrollFrame:SetVerticalScroll(0)
 
    
    GwPaperReputationScrollFrame.slider.thumb:SetHeight(100)
    GwPaperReputationScrollFrame.slider:SetValue(1)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.savedHeight = savedHeight - 590
    
    reputationLastUpdateMethod = GwUpdateReputationDetailsSearch
    reputationLastUpdateMethodParams = s
    
end

function GwUpdateReputationDisplayOldData()
    if reputationLastUpdateMethod~=nil then
    reputationLastUpdateMethod(reputationLastUpdateMethodParams)
    end
end


function gw_register_character_window()
   
   
    CreateFrame('Frame','GwCharacterWindowContainer',GwCharacterWindow,'GwCharacterWindowContainer')
    CreateFrame('Button','GwDressingRoom',GwCharacterWindowContainer,'GwDressingRoom')
    CreateFrame('Frame','GwCharacterMenu',GwCharacterWindowContainer,'GwCharacterMenu')
    CreateFrame('Frame','GwPaperDollBagItemList',GwCharacterWindowContainer,'GwPaperDollBagItemList')
    CreateFrame('Frame','GwPaperDollOutfits',GwCharacterWindowContainer,'GwPaperDollOutfits')
    CreateFrame('Frame','GwPaperTitles',GwCharacterWindowContainer,'GwPaperTitles')
    CreateFrame('Frame','GwPaperReputation',GwCharacterWindowContainer,'GwPaperReputation')
    CreateFrame('Frame','GwPaperDollSelectedIndicator',GwCharacterWindowContainer,'GwPaperDollSelectedIndicator')
    
    GwPaperDollOutfits:SetScript('OnShow',GwOutfitsDrawItemSetList)
    GwPaperDollOutfits:SetScript('OnHide',function() GwPaperDollOutfitsToggleIgnoredSlots(false) end)
    GwOutfitsDrawItemSetList()
    
    
    GwPaperDollUpdateTitlesList()
    GwPaperDollUpdateTitlesLayout() 
    
    GwPaperTitles:HookScript('OnShow',function()
            GwPaperDollUpdateTitlesList()
            GwPaperDollUpdateTitlesLayout()
        end)
    
    
    hooksecurefunc('GearManagerDialogPopupOkay_OnClick',GwOutfitsDrawItemSetList)
    GearManagerDialogPopup:SetScript('OnShow',function(self)
            PlaySound("igCharacterInfoOpen");
            self.name = nil;
            self.isEdit = false;
            RecalculateGearManagerDialogPopup();
            RefreshEquipmentSetIconInfo();
    end)
    
    GwUpdateSavedReputation()
    GwPaperReputationScrollFrame:SetScrollChild(GwPaperReputationScrollFrame.scrollchild)
    GwPaperDollUpdateReputations()
    
    CharacterFrame:SetScript('OnShow',function() 
          HideUIPanel(CharacterFrame);	
    end)
   

  
    CharacterFrame:UnregisterAllEvents()
    
    hooksecurefunc('ToggleCharacter',GwToggleCharacter)
    
   
   
    gwPaperDollUpdateStats()
    
   
    GwUpdateReputationDetails()
    
    GwCharacterWindowContainer:SetScript('OnShow',function() 
        if CHARACTER_PANEL_OPEN==nil then
           
                gwCharacterPanelToggle(GwCharacterMenu)
        end
    end)
    
     GwCharacterWindowContainer:HookScript('OnShow', function() 
        GwCharacterWindow.windowIcon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\character-window-icon')
        GwCharacterWindow.WindowHeader:SetText(GwLocalization['CHARACTER_HEADER'])
    end)
    
    
    return GwCharacterWindowContainer;
    
end



local CHARACTER_PANEL_OPEN = '';


function GwToggleCharacter (tab, onlyShow)
    
    local CHARACTERFRAME_DEFAULTFRAMES= {}

    CHARACTERFRAME_DEFAULTFRAMES['PaperDollFrame'] = GwCharacterMenu
    CHARACTERFRAME_DEFAULTFRAMES['ReputationFrame'] = GwPaperReputation
    CHARACTERFRAME_DEFAULTFRAMES['TokenFrame'] = GwCharacterMenu

    if CHARACTERFRAME_DEFAULTFRAMES[tab]~=nil and CHARACTER_PANEL_OPEN~=tab  then
        gwCharacterPanelToggle(CHARACTERFRAME_DEFAULTFRAMES[tab]);
        CHARACTER_PANEL_OPEN = tab;
        return
    end
    
    if GwCharacterWindow:IsShown() then 

        if not InCombatLockdown() then   
            GwCharacterWindow:SetAttribute('windowPanelOpen',0)
        end
        
        CHARACTER_PANEL_OPEN=nil
        return
    end
    
    
    
end
