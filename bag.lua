local BAG_ITEM_SIZE = 45
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 480
local BAG_WINDOW_CONTENT_HEIGHT = 0

GW_BAG_RS_START_X = 0;
GW_BAG_RS_START_Y = 0;

local default_bag_frame ={
    'MainMenuBarBackpackButton',
    'CharacterBag0Slot',
    'CharacterBag1Slot',
    'CharacterBag2Slot',
    'CharacterBag3Slot',
}

local default_bag_frame_container ={
    'ContainerFrame1',
    'ContainerFrame2',
    'ContainerFrame3',
    'ContainerFrame4',
    'ContainerFrame5',
    'ContainerFrame6',
}



function gw_create_bgframe()
    
    
    BAG_WINDOW_SIZE = gwGetSetting('BAG_WIDTH')
    
    BAG_ITEM_SIZE = gwGetSetting('BAG_ITEM_SIZE')
    
    CreateFrame('Frame','gwNormalBagHolder',UIParent)
    gwNormalBagHolder:SetPoint('LEFT',UIParent,'RIGHT')
    gwNormalBagHolder:SetFrameStrata('HIGH')
   local fm= CreateFrame('Frame','GwBagMoverFrame',UIParent,'GwBagMoverFrame') 
    GwBagMoverFrame:HookScript('OnDragStop',gw_onBagMove)
    
    GwBagMoverFrame:ClearAllPoints()
    
    GwBagMoverFrame:SetPoint(gwGetSetting('BAG_POSITION')['point'],UIParent,gwGetSetting('BAG_POSITION')['relativePoint'],gwGetSetting('BAG_POSITION')['xOfs'],gwGetSetting('BAG_POSITION')['yOfs'])
    

    
   local f= CreateFrame('Frame','GwBagFrame',UIParent,'GwBagFrame') 
	GwBagFrameHeaderString:SetText(GwLocalization['INVENTORY_TITLE'])
    
    GwBagFrame:SetWidth(gwGetSetting('BAG_WIDTH'))
    GwCurrencyWindow.scrollchild:SetWidth(gwGetSetting('BAG_WIDTH') - 24 )
    gw_bagFrameOnResize(GwBagFrame,false)
    
    GwBagFrame:SetScript('OnHide',function() GwBagMoverFrame:Hide() GwBagFrameResize:Hide()  end)
    GwBagFrame:SetScript('OnShow',function() GwBagMoverFrame:Show() GwBagFrameResize:Show() end)
    
    GwBagFrame:Hide()
    

    ContainerFrame1:HookScript('OnShow',function() gw_bag_hideIcons(true)  gw_bag_close() gw_relocate_searchbox() gw_update_bag_icons() GwBagContainer0:Show() end)
    ContainerFrame2:HookScript('OnShow',function() gw_bag_hideIcons(true)  gw_bag_close() gw_update_bag_icons() GwBagContainer1:Show() gw_bag_hideIcons(true) end)
    ContainerFrame3:HookScript('OnShow',function() gw_bag_hideIcons(true) gw_bag_close() gw_update_bag_icons() GwBagContainer2:Show() gw_bag_hideIcons(true) end)
    ContainerFrame4:HookScript('OnShow',function() gw_bag_hideIcons(true) gw_bag_close() gw_update_bag_icons() GwBagContainer3:Show() gw_bag_hideIcons(true) end)
    ContainerFrame5:HookScript('OnShow',function() gw_bag_hideIcons(true) gw_bag_close() gw_update_bag_icons() GwBagContainer4:Show() gw_bag_hideIcons(true) end)
    
    --BANK BAGS
    
 

    
    ContainerFrame1:HookScript('OnHide',function() gw_bag_close() gw_update_bag_icons() GwBagContainer0:Hide() end)
    ContainerFrame2:HookScript('OnHide',function() gw_bag_close() gw_update_bag_icons() GwBagContainer1:Hide() end)
    ContainerFrame3:HookScript('OnHide',function() gw_bag_close() gw_update_bag_icons() GwBagContainer2:Hide() end)
    ContainerFrame4:HookScript('OnHide',function() gw_bag_close() gw_update_bag_icons() GwBagContainer3:Hide() end)
    ContainerFrame5:HookScript('OnHide',function() gw_bag_close() gw_update_bag_icons() GwBagContainer4:Hide() end)

    
    gw_move_bagbar()
    
    gw_update_bag_icons()
    
    BagItemSearchBox:SetScript('OnEvent',function()
        gw_relocate_searchbox()
        gw_update_bag_icons()
        gw_update_free_slots()
  
    
    end)
    BagItemSearchBox:RegisterEvent('BAG_UPDATE_DELAYD')
    BagItemSearchBox:RegisterEvent('BAG_UPDATE')

    ContainerFrame1:SetFrameStrata('HIGH')
    ContainerFrame1:SetFrameLevel(5)
    ContainerFrame2:SetFrameStrata('HIGH')
    ContainerFrame2:SetFrameLevel(5)
    ContainerFrame3:SetFrameStrata('HIGH')
    ContainerFrame3:SetFrameLevel(5)
    ContainerFrame4:SetFrameStrata('HIGH')
    ContainerFrame4:SetFrameLevel(5)
    ContainerFrame5:SetFrameStrata('HIGH')
    ContainerFrame5:SetFrameLevel(5)
    ContainerFrame6:SetFrameStrata('HIGH')
    ContainerFrame6:SetFrameLevel(5)
    
   
    gw_bg_loadCurrency()
    
    
    GwCurrencyWindow:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
    
    GwCurrencyWindow:SetScript('OnEvent',gw_bg_loadCurrency)
    GwCurrencyWindow.slider:SetValue(1)
    hooksecurefunc('SetCurrencyBackpack',gw_bg_loadCurrency)

end


function gw_bg_loadCurrency()
    
    local USED_CURRENCY_HEIGHT = 25
    local zebra = 1;
    local watchSlot = 1
    
    for i=1,GetCurrencyListSize() do
         local y = 0
        local name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount, unknown = GetCurrencyListInfo(i)
        
        if isHeader then
            local HeaderSlot = _G['GwCurrencyHeader'..i]
            if HeaderSlot==nil then
                
                HeaderSlot = CreateFrame('Frame','GwCurrencyHeader'..i,GwCurrencyWindow.scrollchild,'GwcurrencyCat')
                HeaderSlot:SetPoint('TOPLEFT',GwCurrencyWindow.scrollchild,'TOPLEFT',10,-USED_CURRENCY_HEIGHT + (-5))
                HeaderSlot:SetPoint('BOTTOMRIGHT',GwCurrencyWindow.scrollchild,'TOPRIGHT',0,-USED_CURRENCY_HEIGHT + (-5) +(-32))
             
                
              
                y = 32 +5
            end
            HeaderSlot.string:SetText(name)
            HeaderSlot:SetHeight(32)
      
        else
            local itemSlot = _G['GwcurrencyItem'..i]
            if itemSlot==nil then
               itemSlot = CreateFrame('Button','GwcurrencyItem'..i,GwCurrencyWindow.scrollchild,'GwcurrencyItem')
               itemSlot:SetPoint('TOPLEFT',GwCurrencyWindow.scrollchild,'TOPLEFT',10,-USED_CURRENCY_HEIGHT)
               itemSlot:SetPoint('BOTTOMRIGHT',GwCurrencyWindow.scrollchild,'TOPRIGHT',0,-USED_CURRENCY_HEIGHT+(-32))
              
               itemSlot.icon:ClearAllPoints()
               itemSlot.icon:SetPoint('LEFT',0,0)
                y = 32
            end
            itemSlot.string:SetText(name)
            itemSlot.amount:SetText(count..' / '..maximum)
            itemSlot.icon:SetTexture(icon)
            itemSlot.zebra:SetVertexColor(zebra,zebra,zebra,0.05)
            if isWatched then
                itemSlot.zebra:SetVertexColor(1,1,0,0.05)
            end
            if zebra==1 then
                zebra = 0
            else
                zebra =1
            end
            itemSlot:SetHeight(32)
            
            itemSlot:SetScript('OnClick',function()
                    
                    local toggle = 1
                    if isWatched then
                        toggle=0
                    end
                    
                    SetCurrencyBackpack(i,toggle)
            end)
          
            itemSlot:SetScript('OnLeave', function()
                GameTooltip:Hide()
            end)
            itemSlot:SetScript('OnEnter', function()
                GameTooltip:SetOwner(itemSlot,'ANCHOR_CURSOR')
                GameTooltip:ClearLines()
                GameTooltip:SetCurrencyToken(i) 
                GameTooltip:AddLine(GwLocalization['CLICK_TO_TRACK'],1,1,1) 
                GameTooltip:Show() 
            end)
            
            if isWatched and watchSlot<4 then
                
                _G['GwBagFrameCurrency'..watchSlot]:SetText(count)
                _G['GwBagFrameCurrency'..watchSlot..'Texture']:SetTexture(icon)
                
                watchSlot = watchSlot + 1
            end
            
        end
        
        
       
        
        USED_CURRENCY_HEIGHT = USED_CURRENCY_HEIGHT + y
        
    end
    GwCurrencyWindow.slider:SetMinMaxValues(0, USED_CURRENCY_HEIGHT)
    GwCurrencyWindow.height = USED_CURRENCY_HEIGHT
    GwCurrencyWindow:SetScrollChild(GwCurrencyWindow.scrollchild)
    
    for i=watchSlot,3 do
        _G['GwBagFrameCurrency'..i]:SetText('')
        _G['GwBagFrameCurrency'..i..'Texture']:SetTexture(nil)
    end
    
end

function gw_bag_toggleCurrency()
    if GwCurrencyWindow:IsShown() then
        
        gw_bag_hideIcons(true)
    else
         gw_bag_hideIcons(false)
    end

    
end

function gw_bag_hideIcons(b)
  
    
    if b==true then
		OpenAllBags()
        BagItemSearchBox:Show()
        GwBagFrameBagSpaceString:Show()
        GwBagButtonSettings:Show()
        GwCurrencyWindow:Hide()
        ContainerFrame1:Show()
       
    else
        BagItemSearchBox:Hide()
        GwBagFrameBagSpaceString:Hide()
        GwBagButtonSettings:Hide()
        GwCurrencyWindow:Show()
        CloseAllBags()
        
    end
end


function gw_move_bagbar()
    
    local y = 25
    
    for k,v in pairs(default_bag_frame) do
        
        _G[v]:ClearAllPoints()
        _G[v]:SetParent(GwBagFrame)
        _G[v]:SetPoint('TOPLEFT',GwBagFrame,'TOPLEFT',-35,-y)
        _G[v..'IconTexture']:SetTexCoord(0.1,0.9,0.1,0.9)
        _G[v]:SetNormalTexture(nil)
        _G[v]:SetHighlightTexture(nil)
        _G[v].IconBorder:SetTexture(nil)
        
        local s = _G[v]:GetScript('OnClick')
         _G[v]:SetScript('OnClick',function(self, b) 
                if b=='RightButton' then
                    
                    local parent = _G[default_bag_frame_container[k]];
                    PlaySound("igMainMenuOptionCheckBoxOn");
                    ToggleDropDownMenu(1, nil, parent.FilterDropDown, self, 0, 0);    
                    
                else
                    s(_G[v])
                end
            end)
     
        y=y+32
            
    end

end

function gw_bag_open() 
    gw_update_bag_icons()
end 
function gw_bag_close() 
    local o = false

   for i=1,12 do
        if i<6 then
            if _G['ContainerFrame'..i] and _G['ContainerFrame'..i]:IsShown() then
                _G['ContainerFrame'..i]:SetParent(gwNormalBagHolder)
                _G['ContainerFrame'..i]:ClearAllPoints()
                _G['ContainerFrame'..i]:SetPoint('RIGHT',gwNormalBagHolder,'LEFT',0,0);
                
                o=true
            end
        else
            if _G['ContainerFrame'..i] and _G['ContainerFrame'..i]:IsShown() then
               _G['ContainerFrame'..i]:SetParent(gwNormalBagHolder)
                _G['ContainerFrame'..i]:ClearAllPoints()
                _G['ContainerFrame'..i]:SetPoint('RIGHT',gwNormalBagHolder,'LEFT',0,0);
      
            end
        end
    end
    if o==false and GwCurrencyWindow:IsShown()==false then
        GwBagFrame:Hide()
        return
    end
     GwBagFrame:Show()
end 

function gw_relocate_searchbox()

    BagItemSearchBox:ClearAllPoints()
    BagItemSearchBox:SetFont(UNIT_NAME_FONT,14)
    BagItemSearchBox.Instructions:SetFont(UNIT_NAME_FONT,14)
    BagItemSearchBox.Instructions:SetTextColor(178/255,178/255,178/255)
    BagItemSearchBox:SetPoint('TOPLEFT',GwBagFrame,'TOPLEFT',8,-40)
    BagItemSearchBox:SetPoint('TOPRIGHT',GwBagFrame,'TOPRIGHT',-8,-40)
    
    BagItemSearchBox.Left:SetTexture(nil)
    BagItemSearchBox.Right:SetTexture(nil)
    BagItemSearchBoxSearchIcon:Hide()
    BagItemSearchBox.Middle:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagsearchbg')

  
    BagItemSearchBox:SetHeight(24)
    
    BagItemSearchBox.Middle:SetPoint('RIGHT',BagItemSearchBox,'RIGHT',0,0)
    
    BagItemSearchBox.Middle:SetHeight(24)
    BagItemSearchBox.Middle:SetTexCoord(0,1,0,1)
    BagItemSearchBox.SetPoint = function() end
    BagItemSearchBox.ClearAllPoints = function() end
    
    

    
end


function gw_update_bag_icons(forceSize)
    gw_move_bagbar()
    local x = 8
    local y = 72
  
    for BAG_INDEX =1,5 do
      
        if _G['ContainerFrame'..BAG_INDEX] and _G['ContainerFrame'..BAG_INDEX]:IsShown()  then
            local i = 40
            while i>0 do

                local slot = _G['ContainerFrame'..BAG_INDEX..'Item'..i]
                local slotIcon = _G['ContainerFrame'..BAG_INDEX..'Item'..i..'IconTexture']
                local slotIconBorder = _G['ContainerFrame'..BAG_INDEX..'Item'..i..'.IconBorder']
                local slotIconFlash = _G['ContainerFrame'..BAG_INDEX..'Item'..i..'.flash']
                local slotNormalTexture = _G['ContainerFrame'..BAG_INDEX..'Item'..i..'NormalTexture']
                local slotQuesttexture= _G['ContainerFrame'..BAG_INDEX..'Item'..i..'IconQuestTexture']
                local slotCount= _G['ContainerFrame'..BAG_INDEX..'Item'..i..'Count']

                if slot and slot:IsShown() then
                    
                    local backdrop =  _G['GwBagItemBackdrop'..'ContainerFrame'..BAG_INDEX..'Item'..i]
                    if backdrop==nil then
                      backdrop =  gw_create_bag_item_background('ContainerFrame'..BAG_INDEX..'Item'..i)
                    end
                    backdrop:SetParent(_G['ContainerFrame'..BAG_INDEX])
                    backdrop:SetFrameLevel(1)
                    
                    backdrop:SetPoint('TOPLEFT',GwBagFrame,'TOPLEFT',x,-y)
                    backdrop:SetPoint('TOPRIGHT',GwBagFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y)
                    backdrop:SetPoint('BOTTOMLEFT',GwBagFrame,'TOPLEFT',x,-y-BAG_ITEM_SIZE)
                    backdrop:SetPoint('BOTTOMRIGHT',GwBagFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y-BAG_ITEM_SIZE)
                        
                   _G['GwBagContainer'..(BAG_INDEX-1)]:SetSize(x,y)

                    slot:ClearAllPoints()

                    slot:SetPoint('TOPLEFT',GwBagFrame,'TOPLEFT',x,-y)
                    slot:SetPoint('TOPRIGHT',GwBagFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y)
                    slot:SetPoint('BOTTOMLEFT',GwBagFrame,'TOPLEFT',x,-y-BAG_ITEM_SIZE)
                    slot:SetPoint('BOTTOMRIGHT',GwBagFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y-BAG_ITEM_SIZE)
                    
                    if slotCount then
                        slotCount:ClearAllPoints()
                        slotCount:SetPoint('TOPRIGHT',slotCount:GetParent(),'TOPRIGHT',0,-3) 
                        slotCount:SetFont(UNIT_NAME_FONT,12,'THINOUTLINED') 
                        slotCount:SetJustifyH('RIGHT')
                    end

                 

                    if slot.IconBorder then
                        slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                        slot.IconBorder:SetSize(BAG_ITEM_SIZE,BAG_ITEM_SIZE)
                        if slot.IconBorder.GwhasBeenHooked==nil then
                            hooksecurefunc(slot.IconBorder,'SetVertexColor',function()
                                 slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                            end)
                            slot.IconBorder.GwhasBeenHooked =true
                        end 
                        
                    end
                    
                    if slotQuesttexture then
                        slotQuesttexture:SetSize(BAG_ITEM_SIZE,BAG_ITEM_SIZE)
                    end
                    
                    if slotNormalTexture then
                        slotNormalTexture:SetSize(BAG_ITEM_SIZE,BAG_ITEM_SIZE)
                        slot:SetNormalTexture(nil)
                    end 
                    if slot.flash then
                        slot.flash:SetSize(BAG_ITEM_SIZE,BAG_ITEM_SIZE)
                    end

                    slotIcon:SetTexCoord(0.1,0.9,0.1,0.9)

                    x=x+BAG_ITEM_SIZE + BAG_ITEM_PADDING

                    if x>BAG_WINDOW_SIZE then
                        x =8
                        y = y + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                    end
                    
                   
                             
           
                end
                 i = i -1
            end
            
        end
    end
    
    GwBagFrame:SetHeight(y+BAG_ITEM_SIZE+BAG_ITEM_PADDING)
    BAG_WINDOW_CONTENT_HEIGHT= y+BAG_ITEM_SIZE+BAG_ITEM_PADDING
    gw_bagFrameOnResize(GwBagFrame,forceSize)
    
    
    
end


function gw_create_bag_item_background(name)
    local bg = CreateFrame('Frame','GwBagItemBackdrop'..name,GwBagFrame,'GwBagItemBackdrop')

    return bg
end


function gw_update_player_money()
   money = GetMoney(); 
    
    local gold = math.floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
    local silver = math.floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
    local copper = mod(money, COPPER_PER_SILVER);

                
                

    GwBagFrameBronze:SetText(copper)

    GwBagFrameSilver:SetText(silver)
                 
    GwBagFrameGold:SetText(gold)
    
end

function gw_update_free_slots()
          local free = 0
        local full = 0
            
        for i=0,4 do 
            free =  free + GetContainerNumFreeSlots(i)
            full =  full + GetContainerNumSlots(i)
        end
            
        free =  full - free
        local bag_space_string =free..' / '..full
        GwBagFrameBagSpaceString:SetText(bag_space_string); 
end

function gw_onBagMove()
     GwBagFrameResize:SetPoint('BOTTOMRIGHT',GwBagFrame,'BOTTOMRIGHT',0,0)
end
function gw_bagFrameOnResize(self,forceSize)
    if forceSize==nil then
        forceSize = true
    end
    
    local w = self:GetWidth()
    local h = self:GetHeight()
    
    
    w = math.max(512,w)
    h = math.max(350,math.max(BAG_WINDOW_CONTENT_HEIGHT,h))
    
    BAG_WINDOW_SIZE = w - (BAG_ITEM_PADDING * 3) -32
    
    gwSetSetting('BAG_WIDTH',BAG_WINDOW_SIZE)
    
    self:SetSize(w,h)
    
    if  forceSize==false then
        return
    end
   
    gw_update_bag_icons(false)
    

end 
function  gw_bagOnResizeStop(self)
    GwBagFrame:SetScript('OnUpdate',nil)
    self:StopMovingOrSizing();
                            
    gw_bagFrameOnResize(GwBagFrame)
                          
    GwBagFrame:ClearAllPoints()
    GwBagFrame:SetPoint('TOPLEFT',GwBagMoverFrame,'TOPLEFT',20,-40);
    GwBagFrameResize:ClearAllPoints()
    GwBagFrameResize:SetPoint('BOTTOMRIGHT',GwBagFrame,'BOTTOMRIGHT',0,0) 
    GwBagMoverFrame:SetWidth(GwBagFrame:GetWidth()-40)
end
function gw_onBagDragUpdate()
    
    local  point,relative,framerela,xPos,yPos  = GwBagFrameResize:GetPoint()
    
    local w = GwBagFrame:GetWidth()
    local h = GwBagFrame:GetHeight()
    
    if  w<500 or h<340 then
        GwBagFrameResize:StopMovingOrSizing();
        GwBagFrameResize:SetPoint(point,relative,framerela,xPos,yPos);
        gw_bagOnResizeStop(GwBagFrameResize)
    end
    gw_update_bag_icons()

end


function gw_backFrameCompactToggle()
    
    if BAG_ITEM_SIZE==45 then
        gwSetSetting('BAG_ITEM_SIZE',32)
        BAG_ITEM_SIZE = 32
        gw_update_bag_icons(true)
        return GwLocalization['EXPAND_ICONS']; --Local?
    end
    
    gwSetSetting('BAG_ITEM_SIZE',45)
    BAG_ITEM_SIZE = 45
    gw_update_bag_icons(true)
     
    return GwLocalization['COMPACT_ICONS']; --Local?
end

function gw_OnBagFrameChangeSize(self)
    
    local w,h = self:GetSize();
    
    w = math.min(1,w/512)
    h = math.min(1,h/512) 
    
    self.Texture:SetTexCoord(0,w,0,h);
    
end