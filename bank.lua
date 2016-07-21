local BAG_ITEM_SIZE = 45
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 720

local BAG_WINDOW_CONTENT_HEIGHT = 0

local default_bank_frame ={
    'BankSlotsFrame.Bag1',
    'BankSlotsFrame.Bag2',
    'BankSlotsFrame.Bag3',
    'BankSlotsFrame.Bag4',
    'BankSlotsFrame.Bag5',
    'BankSlotsFrame.Bag6',
    'BankSlotsFrame.Bag7',
}

local default_bank_frame_container ={
    'ContainerFrame6',
    'ContainerFrame7',
    'ContainerFrame8',
    'ContainerFrame9',
    'ContainerFrame10',
    'ContainerFrame11',
    'ContainerFrame12',
}



function gw_create_bankframe()
   local fm= CreateFrame('Frame','GwBankMoverFrame',UIParent,'GwBagMoverFrame')
    GwBankMoverFrame:ClearAllPoints();
    GwBankMoverFrame:SetPoint('LEFT',UIParent,'LEFT',300,200)
    GwBankMoverFrame:HookScript('OnDragStop',gw_onBankMove)

 
   local f= CreateFrame('Frame','GwBankFrame',UIParent,'GwBankFrame') 
    
    GwBankFrame:SetScript('OnHide',function() 
            GwBankMoverFrame:Hide() 
            GwBankFrameResize:Hide()
         
    end)
    GwBankFrame:SetScript('OnShow',function() 
         
            GwBankMoverFrame:Show()
            GwBankFrameResize:Show()      
    end)
    
    BankFrame:HookScript('OnHide', function() GwBankFrame:Hide() end)
    BankFrame:HookScript('OnShow', function() GwBankFrame:Show() 
        BankFrame:ClearAllPoints()    
        BankFrame:SetPoint('RIGHT',UIParent,'LEFT',-20000,0)
    end)
    
    GwBankFrame:Hide()
    
    ReagentBankFrame:HookScript('OnShow', function()
        for k,v in pairs(default_bank_frame) do
            v:Hide()
        end
        for k,v in pairs(default_bank_frame_container) do
            _G[v]:Hide()
        end
       
        BankItemSearchBox:Hide()
        GwReagentBankFrame:Show()
        GwBankFrameHeaderString:SetText('Reagents Bank')
        GwReagentBankFrame:SetHeight(GwBankFrame:GetHeight())
            
        if IsReagentBankUnlocked() then
                gw_update_reagents_icons()

                GwRegentHelpText:Hide()
                GwBuyRegentBank:Hide()
                GwBankDepositAllReagents:Show()
                
        end
            
    end)
    ReagentBankFrame:HookScript('OnHide', function()
        for k,v in pairs(default_bank_frame) do
            v:Show()
        end
        GwBankFrameHeaderString:SetText('Bank')
        BankItemSearchBox:Show()
        GwReagentBankFrame:Hide()
            
    end)
    

    
    for k,v in pairs(default_bank_frame_container) do
        _G[v]:HookScript('OnShow',function() gw_bag_close()  gw_update_bank_icons() _G['GwBankContainer'..k+5]:Show() end)
        _G[v]:HookScript('OnHide',function() gw_bag_close()  gw_update_bank_icons() _G['GwBankContainer'..k+5]:Show() end)
    end
    
    
     BankFrame:HookScript('OnShow',function() gw_bag_close() gw_update_bank_icons() gw_relocate_bank_searchbox() GwBankContainer5:Show()  end)
    
    BankItemSearchBox:SetScript('OnEvent',function()
        gw_relocate_bank_searchbox()
        gw_update_bank_icons()
        gw_update_free_slots()
    
    end)
    
    
    BankFrame:SetFrameStrata('HIGH')
    BankFrame:SetFrameLevel(5) 
    
    ContainerFrame6:SetFrameStrata('HIGH')
    ContainerFrame6:SetFrameLevel(5)
    ContainerFrame7:SetFrameStrata('HIGH')
    ContainerFrame7:SetFrameLevel(5)
    ContainerFrame8:SetFrameStrata('HIGH')
    ContainerFrame8:SetFrameLevel(5)
    ContainerFrame9:SetFrameStrata('HIGH')
    ContainerFrame9:SetFrameLevel(5)
    ContainerFrame10:SetFrameStrata('HIGH')
    ContainerFrame10:SetFrameLevel(5)
    ContainerFrame11:SetFrameStrata('HIGH')
    ContainerFrame11:SetFrameLevel(5)
    ContainerFrame12:SetFrameStrata('HIGH')
    ContainerFrame12:SetFrameLevel(5)
    
    
end



function gw_move_bankbagbar()
    default_bank_frame ={
        BankSlotsFrame.Bag1,
        BankSlotsFrame.Bag2,
        BankSlotsFrame.Bag3,
        BankSlotsFrame.Bag4,
        BankSlotsFrame.Bag5,
        BankSlotsFrame.Bag6,
        BankSlotsFrame.Bag7,
    }
    local y = 72
    
    for k,v in pairs(default_bank_frame) do
        
        iconTexture = v:GetRegions()
        
      
        v:SetSize(28,28)
        v:ClearAllPoints()
        v:SetParent(GwBankFrame)
        v:SetPoint('TOPLEFT',GwBankFrame,'TOPLEFT',8,-y)
        iconTexture:SetTexCoord(0.1,0.9,0.1,0.9)
        v:SetNormalTexture(nil)
        v:SetHighlightTexture(nil)
        v.IconBorder:SetTexture(nil)
        

     
        y=y+32
            
    end

end

function gw_update_reagents_icons(forceSize)
    

    local x = 8
    local y = 72
    
    for i=1,98 do
        local FRAME_NAME = 'ReagentBankFrameItem'..i
        
        if _G[FRAME_NAME]~=nil and _G[FRAME_NAME]:IsShown() then
    
            
             local slot = _G[FRAME_NAME]
                local slotIcon = _G[FRAME_NAME..'IconTexture']
                local slotIconBorder = _G[FRAME_NAME..'.IconBorder']
                local slotIconFlash = _G[FRAME_NAME..'.flash']
                local slotNormalTexture = _G[FRAME_NAME..'NormalTexture']

                if slot and slot:IsShown() then
                
                local backdrop =  _G['GwBankItemBackdrop'..FRAME_NAME]
                if backdrop==nil then
                    backdrop =  gw_create_bank_item_background(FRAME_NAME)
                end
                backdrop:SetParent(_G[FRAME_NAME])
                backdrop:SetFrameLevel(1)
                    
                backdrop:SetPoint('TOPLEFT',GwReagentBankFrame,'TOPLEFT',x,-y)
                backdrop:SetPoint('TOPRIGHT',GwReagentBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y)
                backdrop:SetPoint('BOTTOMLEFT',GwReagentBankFrame,'TOPLEFT',x,-y-BAG_ITEM_SIZE)
                backdrop:SetPoint('BOTTOMRIGHT',GwReagentBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y-BAG_ITEM_SIZE)
                
                _G['GwReagentBankFrame']:SetSize(x,y)

                    slot:ClearAllPoints()

                    slot:SetPoint('TOPLEFT',GwReagentBankFrame,'TOPLEFT',x,-y)
                    slot:SetPoint('TOPRIGHT',GwReagentBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y)
                    slot:SetPoint('BOTTOMLEFT',GwReagentBankFrame,'TOPLEFT',x,-y-BAG_ITEM_SIZE)
                    slot:SetPoint('BOTTOMRIGHT',GwReagentBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y-BAG_ITEM_SIZE)
                    

                 

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
                        x = 8
                        y = y + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                    end
                end
            
            
        end
        
        
   
    end

    GwBankFrame:SetHeight(y+BAG_ITEM_SIZE+BAG_ITEM_PADDING)
    BAG_WINDOW_CONTENT_HEIGHT= y+BAG_ITEM_SIZE+BAG_ITEM_PADDING
    gw_bankFrameOnResize(GwBankFrame,forceSize)
    
    if (BAG_WINDOW_SIZE/45)<11 and BAG_ITEM_SIZE>32 then
        BAG_ITEM_SIZE = 32       
        gw_update_reagents_icons(false)
    else
        if BAG_WINDOW_CONTENT_HEIGHT>512 and BAG_ITEM_SIZE>32 then
            BAG_ITEM_SIZE = 32       
            gw_update_reagents_icons(false)
        else
            BAG_ITEM_SIZE = 45
        end
    end
    
end

function gw_update_bank_icons(forceSize)
    

    gw_move_bankbagbar()

    
   for k,v in pairs({BankSlotsFrame:GetRegions()}) do
        if k>100 then
            break
        end
        if v.SetTexture~=nil then
            v:SetTexture(nil)   
        end
    end
 
    
    local x = 40
    local y = 72
    local ACTION_BUTTON_NAME = 'BankFrame'
    local ACTION_FRAME_NAME = 'BankFrame'
    local BAG_INDEX = 5
    for BAG_INDEX =5,12 do
        if BAG_INDEX>5 then
            ACTION_FRAME_NAME ='ContainerFrame'..BAG_INDEX
            ACTION_BUTTON_NAME = 'ContainerFrame'..BAG_INDEX..'Item'
        else
            ACTION_FRAME_NAME ='BankFrame'
            ACTION_BUTTON_NAME ='BankFrameItem'
        end
         
        if _G[ACTION_FRAME_NAME]~=nil and _G[ACTION_FRAME_NAME]:IsShown() then
            
            for i=1,40 do
                
               
   
                local slot = _G[ACTION_BUTTON_NAME..i]
                local slotIcon = _G[ACTION_BUTTON_NAME..i..'IconTexture']
                local slotIconBorder = _G[ACTION_BUTTON_NAME..i..'.IconBorder']
                local slotIconFlash = _G[ACTION_BUTTON_NAME..i..'.flash']
                local slotNormalTexture = _G[ACTION_BUTTON_NAME..i..'NormalTexture']

                if slot and slot:IsShown() then
                  
                    
     
                    local backdrop =  _G['GwBankItemBackdrop'..ACTION_BUTTON_NAME..i]
                    if backdrop==nil then
                      backdrop =  gw_create_bank_item_background(ACTION_BUTTON_NAME..i)
                    end
                    backdrop:SetParent(_G[ACTION_BUTTON_NAME..BAG_INDEX])
                    backdrop:SetFrameLevel(1)
                    
                    backdrop:SetPoint('TOPLEFT',GwBankFrame,'TOPLEFT',x,-y)
                    backdrop:SetPoint('TOPRIGHT',GwBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y)
                    backdrop:SetPoint('BOTTOMLEFT',GwBankFrame,'TOPLEFT',x,-y-BAG_ITEM_SIZE)
                    backdrop:SetPoint('BOTTOMRIGHT',GwBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y-BAG_ITEM_SIZE)
                     
                   _G['GwBankContainer'..(BAG_INDEX-1)]:SetSize(x,y)

                    slot:ClearAllPoints()

                    slot:SetPoint('TOPLEFT',GwBankFrame,'TOPLEFT',x,-y)
                    slot:SetPoint('TOPRIGHT',GwBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y)
                    slot:SetPoint('BOTTOMLEFT',GwBankFrame,'TOPLEFT',x,-y-BAG_ITEM_SIZE)
                    slot:SetPoint('BOTTOMRIGHT',GwBankFrame,'TOPLEFT',x+BAG_ITEM_SIZE,-y-BAG_ITEM_SIZE)
                    

                 

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
                        x = 40
                        y = y + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                    end
                    
                
                             
           
                end

            end
            
        end
    end
    
    
    GwBankFrame:SetHeight(y+BAG_ITEM_SIZE+BAG_ITEM_PADDING)
    BAG_WINDOW_CONTENT_HEIGHT = y+BAG_ITEM_SIZE+BAG_ITEM_PADDING

    gw_bankFrameOnResize(GwBankFrame,forceSize)

    if (BAG_WINDOW_SIZE/45)<11 and BAG_ITEM_SIZE>32 then
        BAG_ITEM_SIZE = 32       
        gw_update_bank_icons(false)
    else
        BAG_ITEM_SIZE = 45
    end
    
end
function gw_relocate_bank_searchbox()

    BankItemSearchBox:ClearAllPoints()
    BankItemSearchBox:SetFont(UNIT_NAME_FONT,14)
    BankItemSearchBox.Instructions:SetFont(UNIT_NAME_FONT,14)
    BankItemSearchBox.Instructions:SetTextColor(178/255,178/255,178/255)
    BankItemSearchBox:SetPoint('TOPLEFT',GwBankFrame,'TOPLEFT',8,-40)
    BankItemSearchBox:SetPoint('TOPRIGHT',GwBankFrame,'TOPRIGHT',-8,-40)
    
    BankItemSearchBox.Left:SetTexture(nil)
    BankItemSearchBox.Right:SetTexture(nil)
    BankItemSearchBoxSearchIcon:Hide()
    BankItemSearchBox.Middle:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagsearchbg')
  
    BankItemSearchBox:SetHeight(24)
    
    BankItemSearchBox.Middle:SetPoint('RIGHT',BankItemSearchBox,'RIGHT',0,0)
    
    BankItemSearchBox.Middle:SetHeight(24)
    BankItemSearchBox.Middle:SetTexCoord(0,1,0,1)
    BankItemSearchBox.SetPoint = function() end
    BankItemSearchBox.ClearAllPoints = function() end
    
    BankItemSearchBox:SetFrameLevel(5)
    BankItemAutoSortButton:Hide()
end


function gw_create_bank_item_background(name)
    local bg = CreateFrame('Frame','GwBankItemBackdrop'..name,GwBankFrame,'GwBagItemBackdrop')

    return bg
end


function gw_onBankMove()
     GwBankFrameResize:SetPoint('BOTTOMRIGHT',GwBankFrame,'BOTTOMRIGHT',0,0)
end
function gw_bankFrameOnResize(self,forceSize)
    if forceSize==nil then
        forceSize = true
    end
    
    local w = self:GetWidth()
    local h = self:GetHeight()
    
    
    w = math.max(512,w)
    h = math.max(350,math.max(BAG_WINDOW_CONTENT_HEIGHT,h))
    
    BAG_WINDOW_SIZE = w - (BAG_ITEM_PADDING * 3) -32
    
    self:SetSize(w,h)
    
    if  forceSize==false then
        return
    end
    if GwReagentBankFrame:IsShown() and  IsReagentBankUnlocked() then
        gw_update_reagents_icons(false)
    else
        gw_update_bank_icons(false)
    end

end 