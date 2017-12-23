local BANK_ITEM_SIZE = 40
local BANK_ITEM_LARGE_SIZE = 40
local BANK_ITEM_COMPACT_SIZE = 32
local BANK_ITEM_PADDING = 5
local BANK_WINDOW_SIZE = 720
local BANK_WINDOW_CONTENT_HEIGHT = 0

local default_bank_frame = {
    BankSlotsFrame.Bag1,
    BankSlotsFrame.Bag2,
    BankSlotsFrame.Bag3,
    BankSlotsFrame.Bag4,
    BankSlotsFrame.Bag5,
    BankSlotsFrame.Bag6,
    BankSlotsFrame.Bag7
}

local default_bank_frame_container ={
    'ContainerFrame6',
    'ContainerFrame7',
    'ContainerFrame8',
    'ContainerFrame9',
    'ContainerFrame10',
    'ContainerFrame11',
    'ContainerFrame12'
}

function gw_create_bankframe()
    BANK_WINDOW_SIZE = gwGetSetting('BANK_WIDTH')
    BANK_ITEM_SIZE = gwGetSetting('BANK_ITEM_SIZE')
    
    -- create mover frame, restore its saved position, and setup drag to move
    local bankPos = gwGetSetting('BANK_POSITION')
    local fm = CreateFrame('Frame', 'GwBankMoverFrame', UIParent, 'GwBankMoverFrame')
    fm:SetWidth(BANK_WINDOW_SIZE - 40)
    fm:ClearAllPoints()    
    fm:SetPoint(bankPos.point, UIParent, bankPos.relativePoint, bankPos.xOfs, bankPos.yOfs)
    fm:RegisterForDrag('LeftButton')
    fm:HookScript('OnDragStart', function(self)
        self:StartMoving()
    end)
    fm:HookScript('OnDragStop', gw_onBankMove)
    
    -- create bank frame, restore its saved size, and init its many pieces
    local f = CreateFrame('Frame', 'GwBankFrame', UIParent, 'GwBankFrame')
    f:SetWidth(BANK_WINDOW_SIZE)
    gw_update_bank_icons()

    f.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
	f.headerString:SetText(GwLocalization['BANK_TITLE'])

    f.spaceString:SetFont(UNIT_NAME_FONT, 12)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)
    gw_update_free_bank_slots()

    -- setup settings button and its dropdown items
    do
        local dd = f.buttonSettings.dropdown
        f.buttonSettings:HookScript('OnClick', function(self)
            if dd:IsShown() then
                dd:Hide()
            else
                dd:Show()
            end
        end)

        dd.sortBank:HookScript('OnClick', function(self)
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
            SortBankBags()
            if IsReagentBankUnlocked() then
                SortReagentBankBags()
            end
            dd:Hide()
        end)
        
        dd.compactBank:HookScript('OnClick', function(self)
            self:SetText(gw_bankFrameCompactToggle())
            dd:Hide()
        end)
        
        dd.sortBank:SetText(GwLocalization['SORT_BANK'])
        if BANK_ITEM_SIZE == BANK_ITEM_LARGE_SIZE then
            dd.compactBank:SetText(GwLocalization['BANK_COMPACT_ICONS'])
        else
            dd.compactBank:SetText(GwLocalization['BANK_EXPAND_ICONS'])
        end
    end
    
    -- setup close button
    f.buttonClose:HookScript('OnClick', function(self)
        CloseBankFrame()
    end)
        
    -- setup resizer stuff
    f:HookScript('OnSizeChanged', gw_OnBankFrameChangeSize)
    GwBankFrameResize:RegisterForDrag('LeftButton')
    GwBankFrameResize:HookScript('OnDragStart', function(self)
        self:StartMoving()
        GwBankFrame:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0)
        GwBankFrame:SetScript('OnUpdate', gw_onBankDragUpdate)
    end)
    GwBankFrameResize:HookScript('OnDragStop', function(self)
        gw_bankOnResizeStop(self)
    end)
   
    -- setup bank/reagent switching buttons
    GwBankButton:HookScript('OnEnter', function(self)
        _G[self:GetName() .. 'Texture']:SetBlendMode('ADD')
    end)
    GwBankButton:HookScript('OnLeave', function(self)
        _G[self:GetName() .. 'Texture']:SetBlendMode('BLEND')
    end)
    GwBankButton:HookScript('OnClick', function(self)
        BankSlotsFrame:Show()
        ReagentBankFrame:Hide()
    end)
    GwBankButton2:HookScript('OnEnter', function(self)
        _G[self:GetName() .. 'Texture']:SetBlendMode('ADD')
    end)
    GwBankButton2:HookScript('OnLeave', function(self)
        _G[self:GetName() .. 'Texture']:SetBlendMode('BLEND')
    end)
    GwBankButton2:HookScript('OnClick', function(self)
        BankSlotsFrame:Hide()
        ReagentBankFrame:Show()
    end)
    
    -- setup buy bank stuff
    GwBuyMoreBank:SetScript('OnEvent', function(self, event, ...)
        if event == 'PLAYERBANKBAGSLOTS_CHANGED' then
            if GetNumBankSlots() == 7 then
                self:Hide()
            end
            local cost = GetBankSlotCost() / 100 / 100
            GwBuyMoreBankGold:SetText(cost)
        end
    end)
    if GetNumBankSlots() == 7 then
        GwBuyMoreBank:Hide()
    end
    local cost = GetBankSlotCost() / 100 / 100
    GwBuyMoreBankGold:SetText(cost)
    GwBuyMoreBank:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED')
    GwBuyMoreBankGold:ClearAllPoints()
    GwBuyMoreBankGold:SetPoint('LEFT', GwButtonBuyBankSlots, 'RIGHT', 20, 0)
    GwBuyMoreBankGold:SetFont(UNIT_NAME_FONT, 12)
    GwBuyMoreBankGold:SetTextColor(221/255, 187/255, 68/255)
    
    GwButtonBuyBankSlots:HookScript('OnClick', function(self)
        PurchaseSlot()        
    end)
    GwButtonBuyBankSlots:SetText(GwLocalization['BANK_BUY_SLOTS'])
    
    -- setup reagent bank stuff
    GwBankDepositAllReagents:SetText(GwLocalization['REAGENT_BANK_DEPOSIT_ALL'])
    GwBankDepositAllReagents:HookScript('OnClick', function(self)
        DepositReagentBank()
    end)
    
    GwBuyRegentBank:HookScript('OnClick', function(self)
        BuyReagentBank()
    end)
    
    GwReagentBankFrame:SetScript('OnEvent', function(self, event, ...)
        if event == 'REAGENTBANK_PURCHASED' then
            if IsReagentBankUnlocked() then
                GwRegentHelpText:Hide()
                GwBuyRegentBank:Hide()
                GwBankDepositAllReagents:Show()
            end
        end
    end)
    GwReagentBankFrame:RegisterEvent('REAGENTBANK_PURCHASED')
    GwRegentHelpText:SetFont(UNIT_NAME_FONT, 12)
    GwRegentHelpText:SetShadowColor(1, 1, 1)
    BUY_REGENTBAG_TEXT = GwLocalization['PURCHASE_REAGENT_BANK'] .. ((GetReagentBankCost()) / 100 / 100) .. 'G'
    GwBuyRegentBank:SetText(BUY_REGENTBAG_TEXT)
    if IsReagentBankUnlocked() then
        GwRegentHelpText:Hide()
        GwBuyRegentBank:Hide()
        GwBankDepositAllReagents:Show()
    end

    ReagentBankFrame:HookScript('OnShow', function()
        for k,v in pairs(default_bank_frame) do
            v:Hide()
        end
        for k,v in pairs(default_bank_frame_container) do
            _G[v]:Hide()
        end
       
        BankItemSearchBox:Hide()
        GwReagentBankFrame:Show()
        GwBankFrame.headerString:SetText(GwLocalization['REAGENT_BANK_TITLE'])
        GwReagentBankFrame:SetHeight(GwBankFrame:GetHeight())
            
        GwBuyMoreBank:Hide()
            
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
        GwBankFrame.headerString:SetText(GwLocalization['BANK_TITLE'])
        BankItemSearchBox:Show()
        GwReagentBankFrame:Hide()
        for i = 5, 12 do
            OpenBag(i)     
        end
        if GetNumBankSlots() < 7 then
            GwBuyMoreBank:Show()
        end
    end)
    
    -- hook into default bank frames to re-use default bank bars and search box
    f:SetScript('OnHide', function() GwBankMoverFrame:Hide() GwBankFrameResize:Hide() end)
    f:SetScript('OnShow', function() GwBankMoverFrame:Show() GwBankFrameResize:Show() end)
    BankFrame:HookScript('OnHide', function()
        GwBankFrame:Hide()
    end)
    BankFrame:HookScript('OnShow', function()
        GwBankFrame:Show() 
        BankFrame:ClearAllPoints()    
        BankFrame:SetPoint('RIGHT', UIParent, 'LEFT', -2000, 0)
        for i = 5, 12 do
            OpenBag(i)
        end
    end)
    BankFrame:SetFrameStrata('HIGH')
    BankFrame:SetFrameLevel(5) 
    f:Hide()
    
    for i = 1, #default_bank_frame_container do
        local fv = _G[ default_bank_frame_container[i] ]
        fv:SetFrameStrata('HIGH')
        fv:SetFrameLevel(5)
        
        local fc = _G['GwBankContainer' .. tostring(i + 5)]
        if fv then
            fv:HookScript('OnShow', function()
                gw_bag_close()
                gw_update_bank_icons()
                if fc then
                    fc:Show()
                end
            end)
            fv:HookScript('OnHide', function()
                gw_bag_close()
                gw_update_bank_icons()
                if fc then
                    fc:Hide()
                end
            end)
        end
    end
    BankFrame:HookScript('OnShow', function()
        gw_bag_close()
        gw_update_bank_icons()
        gw_relocate_bank_searchbox()
        GwBankContainer5:Show()
    end)
    
    BankItemSearchBox:SetScript('OnEvent', function(self, event, ...)
        if event == 'BAG_UPDATE' or event == 'BAG_UPDATE_DELAYED' then
            gw_relocate_bank_searchbox()
            if GwReagentBankFrame:IsShown() and IsReagentBankUnlocked() then
                gw_update_reagents_icons()
            else
                gw_update_bank_icons()
            end
        end
    end)
    BankItemSearchBox:RegisterEvent('BAG_UPDATE_DELAYED')
    BankItemSearchBox:RegisterEvent('BAG_UPDATE')
end

function gw_move_bankbagbar()
    local y = 120
    
    for k, v in pairs(default_bank_frame) do        
        local iconTexture = v:GetRegions()
        
        v:SetSize(28, 28)
        v:ClearAllPoints()
        v:SetParent(GwBankFrame)
        v:SetPoint('TOPLEFT', GwBankFrame, 'TOPLEFT', -34, -y)
        iconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        v:SetNormalTexture(nil)
        v:SetHighlightTexture(nil)
        v.IconBorder:SetTexture(nil)
     
        y = y + 32
    end
end

function gw_relocate_bank_searchbox()
    local sb = BankItemSearchBox

    sb:ClearAllPoints()
    sb:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetTextColor(178/255, 178/255, 178/255)
    sb:SetPoint('TOPLEFT', GwBankFrame, 'TOPLEFT', 8, -40)
    sb:SetPoint('TOPRIGHT', GwBankFrame, 'TOPRIGHT', -8, -40)
    
    sb.Left:SetTexture(nil)
    sb.Right:SetTexture(nil)
    BankItemSearchBoxSearchIcon:Hide()
    sb.Middle:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagsearchbg')
  
    sb:SetHeight(24)
    
    sb.Middle:SetPoint('RIGHT', BankItemSearchBox, 'RIGHT', 0, 0)
    
    sb.Middle:SetHeight(24)
    sb.Middle:SetTexCoord(0, 1, 0, 1)
    sb.SetPoint = function() end
    sb.ClearAllPoints = function() end
    
    sb:SetFrameLevel(5)
    BankItemAutoSortButton:Hide()
end

function gw_update_free_bank_slots(reagents)
    local free = 0
    local full = 0
    
    if reagents then
        free = GetContainerNumFreeSlots(-3)
        full = GetContainerNumSlots(-3)
    else
        free = GetContainerNumFreeSlots(-1)
        full = GetContainerNumSlots(-1)
        for i = 1, NUM_BANKBAGSLOTS do 
            free = free + GetContainerNumFreeSlots(i + NUM_BAG_SLOTS)
            full = full + GetContainerNumSlots(i + NUM_BAG_SLOTS)
        end
    end

    free = full - free
    local bank_space_string = free .. ' / ' .. full
    GwBankFrame.spaceString:SetText(bank_space_string)
end

function gw_onBankMove(self)
    self:StopMovingOrSizing()
    local saveBankPos = {}
    saveBankPos['point'], _, saveBankPos['relativePoint'], saveBankPos['xOfs'], saveBankPos['yOfs'] = self:GetPoint()
    gwSetSetting('BANK_POSITION', saveBankPos)
    GwBankFrameResize:SetPoint('BOTTOMRIGHT', GwBankFrame, 'BOTTOMRIGHT', 0, 0)
end

function gw_update_reagents_icons(smooth)
    local x = 8
    local y = 72
    local mx = 0
    local gwbf = GwBankFrame
    local winsize = BANK_WINDOW_SIZE
    if smooth then
        winsize = gwbf:GetWidth()
    end
    winsize = math.max(508, winsize)
    
    for i = 1, 98 do
        local FRAME_NAME = 'ReagentBankFrameItem' .. i        
        local slot = _G[FRAME_NAME]
        if slot and slot:IsShown() then
            if x > (winsize - 40) then
                mx = math.max(mx, x)
                x = 8
                y = y + BANK_ITEM_SIZE + BANK_ITEM_PADDING
            end
            
            local slotIcon = _G[FRAME_NAME .. 'IconTexture']
            local slotNormalTexture = _G[FRAME_NAME .. 'NormalTexture']

            local backdrop = _G['GwBankItemBackdrop' .. FRAME_NAME]
            if backdrop == nil then
                backdrop = gw_create_bank_item_background(FRAME_NAME)
            end
            backdrop:SetParent(slot)
            backdrop:SetFrameLevel(1)

            backdrop:SetPoint('TOPLEFT', GwReagentBankFrame, 'TOPLEFT', x, -y)
            backdrop:SetPoint('TOPRIGHT', GwReagentBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y)
            backdrop:SetPoint('BOTTOMLEFT', GwReagentBankFrame,'TOPLEFT', x, -y - BANK_ITEM_SIZE)
            backdrop:SetPoint('BOTTOMRIGHT', GwReagentBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y - BANK_ITEM_SIZE)

            GwReagentBankFrame:SetSize(x, y)

            slot:ClearAllPoints()

            slot:SetPoint('TOPLEFT', GwReagentBankFrame, 'TOPLEFT', x, -y)
            slot:SetPoint('TOPRIGHT', GwReagentBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y)
            slot:SetPoint('BOTTOMLEFT', GwReagentBankFrame, 'TOPLEFT', x, -y - BANK_ITEM_SIZE)
            slot:SetPoint('BOTTOMRIGHT', GwReagentBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y - BANK_ITEM_SIZE)

            if slot.IconBorder then
                slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                slot.IconBorder:SetSize(BANK_ITEM_SIZE, BANK_ITEM_SIZE)
                if slot.IconBorder.GwhasBeenHooked == nil then
                    hooksecurefunc(slot.IconBorder, 'SetVertexColor', function()
                        slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                    end)
                    slot.IconBorder.GwhasBeenHooked = true
                end 
            end
            if slotNormalTexture then
                slotNormalTexture:SetSize(BANK_ITEM_SIZE, BANK_ITEM_SIZE)
                slot:SetNormalTexture(nil)
            end 
            if slot.flash then
                slot.flash:SetSize(BANK_ITEM_SIZE, BANK_ITEM_SIZE)
            end

            slotIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

            x = x + BANK_ITEM_SIZE + BANK_ITEM_PADDING
        end
    end

    gw_update_free_bank_slots(true)
    if smooth then
        return
    end
    
    BANK_WINDOW_CONTENT_HEIGHT = math.max(350, y + BANK_ITEM_SIZE + (2 * BANK_ITEM_PADDING))
    if mx ~= 0 then
        BANK_WINDOW_SIZE = mx + BANK_ITEM_PADDING
    end
    gwSetSetting('BANK_WIDTH', BANK_WINDOW_SIZE)
    gwbf:SetSize(BANK_WINDOW_SIZE, BANK_WINDOW_CONTENT_HEIGHT)
end

function gw_update_bank_icons(smooth)
    gw_move_bankbagbar()
    
    for k, v in pairs({BankSlotsFrame:GetRegions()}) do
        if k > 100 then
            break
        end
        if v.SetTexture ~= nil then
            v:SetTexture(nil)
        end
    end

    local x = 8
    local y = 72
    local ACTION_BUTTON_NAME = 'BankFrame'
    local ACTION_FRAME_NAME = 'BankFrame'
    local mx = 0
    local gwbf = GwBankFrame
    local winsize = BANK_WINDOW_SIZE
    if smooth then
        winsize = gwbf:GetWidth()
    end
    winsize = math.max(508, winsize)
  
    local bStart = 5
    local bEnd = 12
    local bStep = 1
    if gwGetSetting('BANK_REVERSE_SORT') then
        bStart = 12
        bEnd = 5
        bStep = -1
    end
    local BANK_INDEX = nil    
    for BANK_INDEX = bStart, bEnd, bStep do
        local i = 40
        local run = true
        if BANK_INDEX > 5 then
            i = 40
            ACTION_FRAME_NAME = 'ContainerFrame' .. BANK_INDEX
            ACTION_BUTTON_NAME = 'ContainerFrame' .. BANK_INDEX .. 'Item'
        else
            i = 1
            ACTION_FRAME_NAME = 'BankFrame'
            ACTION_BUTTON_NAME = 'BankFrameItem'
        end
        local cfm = _G[ACTION_FRAME_NAME]        
         
        if cfm and cfm:IsShown() then            
            while run do
                local slot = _G[ACTION_BUTTON_NAME .. i]
                if slot and slot:IsShown() then
                    if x > (winsize - 40) then
                        mx = math.max(mx, x)
                        x = 8
                        y = y + BANK_ITEM_SIZE + BANK_ITEM_PADDING
                    end
                    local slotIcon = _G[ACTION_BUTTON_NAME .. i .. 'IconTexture']
                    local slotNormalTexture = _G[ACTION_BUTTON_NAME .. i .. 'NormalTexture']
     
                    local backdrop = _G['GwBankItemBackdrop' .. ACTION_BUTTON_NAME .. i]
                    if backdrop == nil then
                        backdrop = gw_create_bank_item_background(ACTION_BUTTON_NAME .. i)
                    end
                    backdrop:SetParent(_G[ACTION_BUTTON_NAME .. BANK_INDEX])
                    backdrop:SetFrameLevel(1)                    
                    backdrop:SetPoint('TOPLEFT', GwBankFrame, 'TOPLEFT', x, -y)
                    backdrop:SetPoint('TOPRIGHT', GwBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y)
                    backdrop:SetPoint('BOTTOMLEFT', GwBankFrame, 'TOPLEFT', x, -y - BANK_ITEM_SIZE)
                    backdrop:SetPoint('BOTTOMRIGHT', GwBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y - BANK_ITEM_SIZE)
                     
                    _G['GwBankContainer' .. (BANK_INDEX - 1)]:SetSize(x, y)

                    slot:ClearAllPoints()

                    slot:SetPoint('TOPLEFT', GwBankFrame, 'TOPLEFT', x, -y)
                    slot:SetPoint('TOPRIGHT', GwBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y)
                    slot:SetPoint('BOTTOMLEFT', GwBankFrame, 'TOPLEFT', x, -y - BANK_ITEM_SIZE)
                    slot:SetPoint('BOTTOMRIGHT', GwBankFrame, 'TOPLEFT', x + BANK_ITEM_SIZE, -y - BANK_ITEM_SIZE)

                    if slot.IconBorder then
                        slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                        slot.IconBorder:SetSize(BANK_ITEM_SIZE, BANK_ITEM_SIZE)
                        if slot.IconBorder.GwhasBeenHooked == nil then
                            hooksecurefunc(slot.IconBorder, 'SetVertexColor', function()
                                slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                            end)
                            slot.IconBorder.GwhasBeenHooked = true
                        end
                    end
                    if slotNormalTexture then
                        slotNormalTexture:SetSize(BANK_ITEM_SIZE, BANK_ITEM_SIZE)
                        slot:SetNormalTexture(nil)
                    end 
                    if slot.flash then
                        slot.flash:SetSize(BANK_ITEM_SIZE, BANK_ITEM_SIZE)
                    end

                    slotIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    x = x + BANK_ITEM_SIZE + BANK_ITEM_PADDING
                end
                if BANK_INDEX > 5 then
                    i = i - 1  
                    if i == 0 then
                        run = false
                    end
                else
                    i = i + 1
                    if i == 40 then
                        run = false 
                    end
                end
            end
        end
    end

    gw_update_free_bank_slots()
    if smooth then
        return
    end
    
    BANK_WINDOW_CONTENT_HEIGHT = math.max(350, y + BANK_ITEM_SIZE + (2 * BANK_ITEM_PADDING))
    if mx ~= 0 then
        BANK_WINDOW_SIZE = mx + BANK_ITEM_PADDING
    end
    gwSetSetting('BANK_WIDTH', BANK_WINDOW_SIZE)
    gwbf:SetSize(BANK_WINDOW_SIZE, BANK_WINDOW_CONTENT_HEIGHT)
end

function gw_create_bank_item_background(name)
    local bg = CreateFrame('Frame','GwBankItemBackdrop'..name,GwBankFrame,'GwBankItemBackdrop')

    return bg
end

function gw_bankOnResizeStop(self)
    GwBankFrame:SetScript('OnUpdate', nil)
    self:StopMovingOrSizing()
                            
    BANK_WINDOW_SIZE = GwBankFrame:GetWidth()
    if GwReagentBankFrame:IsShown() and IsReagentBankUnlocked() then
        gw_update_reagents_icons()
    else
        gw_update_bank_icons()
    end
                          
    GwBankFrame:ClearAllPoints()
    GwBankFrame:SetPoint('TOPLEFT', GwBankMoverFrame, 'TOPLEFT', 20, -40)
    GwBankFrameResize:ClearAllPoints()
    GwBankFrameResize:SetPoint('BOTTOMRIGHT', GwBankFrame, 'BOTTOMRIGHT', 0, 0)
    
    local mfPoint, _, mfRelPoint, mfxOfs, mfyOfs = GwBankMoverFrame:GetPoint()
    local newWidth = GwBankFrame:GetWidth() - 40
    local oldWidth = GwBankMoverFrame:GetWidth()
    if mfPoint == 'TOP' then
        mfxOfs = mfxOfs + ((newWidth - oldWidth) / 2)
    elseif mfPoint == 'RIGHT' then
        mfxOfs = mfxOfs + (newWidth - oldWidth)
    end
    GwBankMoverFrame:ClearAllPoints()        
    GwBankMoverFrame:SetPoint(mfPoint, UIParent, mfRelPoint, mfxOfs, mfyOfs)
    GwBankMoverFrame:SetWidth(newWidth)
    gw_onBankMove(GwBankMoverFrame)
end

function gw_onBankDragUpdate(self)
    local point, relative, framerela, xPos, yPos = GwBankFrameResize:GetPoint()
    
    local w = self:GetWidth()
    local h = self:GetHeight()
    
    if w < 508 or h < 340 then
        GwBagFrameResize:StopMovingOrSizing()
    else
        if GwReagentBankFrame:IsShown() and IsReagentBankUnlocked() then
            gw_update_reagents_icons(true)
        else
            gw_update_bank_icons(true)
        end
    end
end

function gw_bankFrameCompactToggle()
    if BANK_ITEM_SIZE == BANK_ITEM_LARGE_SIZE then
        BANK_ITEM_SIZE = BANK_ITEM_COMPACT_SIZE
        gwSetSetting('BANK_ITEM_SIZE', BANK_ITEM_SIZE)
        if GwReagentBankFrame:IsShown() and IsReagentBankUnlocked() then
            gw_update_reagents_icons()
        else
            gw_update_bank_icons()
        end
        return GwLocalization['BANK_EXPAND_ICONS']
    end
    
    BANK_ITEM_SIZE = BANK_ITEM_LARGE_SIZE
    gwSetSetting('BANK_ITEM_SIZE', BANK_ITEM_SIZE)
    if GwReagentBankFrame:IsShown() and IsReagentBankUnlocked() then
        gw_update_reagents_icons(false)
    else
        gw_update_bank_icons()
    end
    return GwLocalization['BANK_COMPACT_ICONS']
end

function gw_OnBankFrameChangeSize(self)
    --[[
    local w, h = self:GetSize()
    
    w = math.min(1, w / 768)
    h = math.min(1, h / 512) 
    
    self.Texture:SetTexCoord(0, w, 0, h)
    ]]--
end
