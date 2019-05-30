local _, GW = ...

local BAG_ITEM_SIZE = 40
local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 480
local BAG_WINDOW_CONTENT_HEIGHT = 0

local default_bag_frame = {
    'MainMenuBarBackpackButton',
    'CharacterBag0Slot',
    'CharacterBag1Slot',
    'CharacterBag2Slot',
    'CharacterBag3Slot'
}

local default_bag_frame_container = {
    'ContainerFrame1',
    'ContainerFrame2',
    'ContainerFrame3',
    'ContainerFrame4',
    'ContainerFrame5',
    'ContainerFrame6'
}

tinsert(UISpecialFrames, "GwBagFrame") 

function gw_create_bgframe()
    BAG_WINDOW_SIZE = gwGetSetting('BAG_WIDTH')
    BAG_ITEM_SIZE = gwGetSetting('BAG_ITEM_SIZE')
    
    CreateFrame('Frame', 'gwNormalBagHolder', UIParent)
    gwNormalBagHolder:SetPoint('LEFT', UIParent, 'RIGHT')
    gwNormalBagHolder:SetFrameStrata('HIGH')
    
    -- create mover frame, restore its saved position, and setup drag to move
    local bagPos = gwGetSetting('BAG_POSITION')
    local fm = CreateFrame('Frame', 'GwBagMoverFrame', UIParent, 'GwBagMoverFrame')
    fm:SetWidth(BAG_WINDOW_SIZE - 40)
    fm:ClearAllPoints()    
    fm:SetPoint(bagPos.point, UIParent, bagPos.relativePoint, bagPos.xOfs, bagPos.yOfs)
    fm:RegisterForDrag('LeftButton')
    fm:HookScript('OnDragStart', function(self)
        self:StartMoving()
    end)
    fm:HookScript('OnDragStop', gw_onBagMove)
    
    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame('Frame', 'GwBagFrame', UIParent, 'GwBagFrame')
    f:SetWidth(BAG_WINDOW_SIZE)
    gw_update_bag_icons()

    f.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
	f.headerString:SetText(GwLocalization['INVENTORY_TITLE'])

    f.spaceString:SetFont(UNIT_NAME_FONT, 12)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)
    gw_update_free_slots()

    f.bronze:SetFont(UNIT_NAME_FONT, 12)
    f.bronze:SetTextColor(177/255, 97/255, 34/255)
    f.silver:SetFont(UNIT_NAME_FONT, 12)
    f.silver:SetTextColor(170/255, 170/255, 170/255)
    f.gold:SetFont(UNIT_NAME_FONT, 12)
    f.gold:SetTextColor(221/255, 187/255, 68/255)
    gw_update_player_money(f)
    
    f:SetScript('OnEvent', function(self, event, ...)
        if event == 'PLAYER_MONEY' then
            gw_update_player_money(self)
        end
    end)
    f:RegisterEvent('PLAYER_MONEY')
    
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

        dd.compactBags:HookScript('OnClick', function(self)
            self:SetText(gw_bagFrameCompactToggle())
            dd:Hide()
        end)
        
        if BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
            dd.compactBags:SetText(GwLocalization['COMPACT_ICONS'])
        else
            dd.compactBags:SetText(GwLocalization['EXPAND_ICONS'])
        end
    end
    
    -- setup close button
    f.buttonClose:HookScript('OnClick', function(self)
        local f = self:GetParent()
        CloseAllBags()
    end)
        
    -- setup resizer stuff
    f:HookScript('OnSizeChanged', gw_OnBagFrameChangeSize)
    GwBagFrameResize:RegisterForDrag('LeftButton')
    GwBagFrameResize:HookScript('OnDragStart', function(self)
        self:StartMoving()
        GwBagFrame:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0)
        GwBagFrame:SetScript('OnUpdate', gw_onBagDragUpdate)
    end)
    GwBagFrameResize:HookScript('OnDragStop', function(self)
        gw_bagOnResizeStop(self)
    end)
    
    f:SetScript('OnHide', gw_bagFrameHide)
    f:SetScript('OnShow', gw_bagFrameShow)
    f:Hide()    
   
    -- hook into default bag frames to re-use default bag bars and search box
    for i = 1, #default_bag_frame_container do
        local fv = _G[ default_bag_frame_container[i] ]
        fv:SetFrameStrata('HIGH')
        fv:SetFrameLevel(5)
        
        local fc = _G['GwBagContainer' .. tostring(i - 1)]
        local relocate = nil
        if i == 1 then
            relocate = gw_relocate_searchbox
        end
        if fv and i < 6 then
            fv:HookScript('OnShow', function()
                gw_bag_hideIcons(true)
                gw_bag_close()
                if relocate then
                    relocate()
                end
                gw_update_bag_icons()
                if fc then
                    fc:Show()
                end
            end)
            fv:HookScript('OnHide', function()
                gw_bag_close()
                gw_update_bag_icons()
                if fc then
                    fc:Hide()
                end
            end)
        end
    end    
end

function gw_bagFrameHide()
    GwBagMoverFrame:Hide()
    GwBagFrameResize:Hide()
    CloseAllBags()
end

function gw_bagFrameShow()
    GwBagMoverFrame:Show()
    GwBagFrameResize:Show()
end

function gw_bagFrameCompactToggle()
    if BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
        BAG_ITEM_SIZE = BAG_ITEM_COMPACT_SIZE
        gwSetSetting('BAG_ITEM_SIZE', BAG_ITEM_SIZE)
        gw_update_bag_icons()
        return GwLocalization['EXPAND_ICONS'] --Local?
    end
    
    BAG_ITEM_SIZE = BAG_ITEM_LARGE_SIZE
    gwSetSetting('BAG_ITEM_SIZE', BAG_ITEM_SIZE)
    gw_update_bag_icons()
    return GwLocalization['COMPACT_ICONS'] --Local?
end

function gw_bag_hideIcons(b)
    local gwbf = GwBagFrame
    if b then
		OpenAllBags()
        gwbf.spaceString:Show()
        gwbf.buttonSettings:Show()
        ContainerFrame1:Show()
    else
        gwbf.spaceString:Hide()
        gwbf.buttonSettings:Hide()
        CloseAllBags()
    end
end

function gw_move_bagbar()
    local y = 25
    
    for k, v in pairs(default_bag_frame) do
        local fv = _G[v]
        
        fv:ClearAllPoints()
        fv:SetParent(GwBagFrame)
        fv:SetPoint('TOPLEFT', GwBagFrame, 'TOPLEFT', -35, -y)
        _G[v .. 'IconTexture']:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        fv:SetNormalTexture(nil)
        fv:SetHighlightTexture(nil)
        fv.IconBorder:SetTexture(nil)
        
        local s = fv:GetScript('OnClick')
        fv:SetScript('OnClick', function(self, b)
            if b == 'RightButton' then
                local parent = _G[default_bag_frame_container[k]]
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                ToggleDropDownMenu(1, nil, parent.FilterDropDown, self, 32, 32)
                if v == 'MainMenuBarBackpackButton' then
                    BackpackButton_UpdateChecked(fv)
                else
                    BagSlotButton_UpdateChecked(fv)
                end
            else
                s(fv)
            end
        end)
     
        y = y + 32
    end
end

function gw_bag_close() 
    local o = false

    for i = 1, 12 do
        local cfm = _G['ContainerFrame' .. tostring(i)]
        if cfm and cfm:IsShown() then
            cfm:SetParent(gwNormalBagHolder)
            cfm:ClearAllPoints()
            cfm:SetPoint('RIGHT', gwNormalBagHolder, 'LEFT', 0, 0)
            if i < 6 then
                o = true
            end
        end
    end
    if not o then
        GwBagFrame:Hide()
        return
    end
    GwBagFrame:Show()
end 


function gw_update_player_money(self)
    if not self then
        return
    end
    local money = GetMoney();
    
    local gold = math.floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
    local silver = math.floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
    local copper = mod(money, COPPER_PER_SILVER);

    self.bronze:SetText(copper)
    self.silver:SetText(silver)
    self.gold:SetText(GW.comma_value(gold))
end

function gw_update_free_slots()
    local free = 0
    local full = 0
            
    for i = 0, NUM_BAG_SLOTS do 
        free =  free + GetContainerNumFreeSlots(i)
        full =  full + GetContainerNumSlots(i)
    end
            
    free = full - free
    local bag_space_string = free .. ' / ' .. full
    GwBagFrame.spaceString:SetText(bag_space_string)
end

function gw_onBagMove(self)
    self:StopMovingOrSizing()
    local saveBagPos = {}
    saveBagPos['point'], _, saveBagPos['relativePoint'], saveBagPos['xOfs'], saveBagPos['yOfs'] = self:GetPoint()
    gwSetSetting('BAG_POSITION', saveBagPos)
    GwBagFrameResize:SetPoint('BOTTOMRIGHT', GwBagFrame, 'BOTTOMRIGHT', 0, 0)
end

function gw_update_bag_icons(smooth)
    gw_move_bagbar()
    local x = 8
    local y = 72
    local mx = 0
    local gwbf = GwBagFrame
    local winsize = BAG_WINDOW_SIZE
    if smooth then
        winsize = gwbf:GetWidth()
    end
    winsize = math.max(508, winsize)
  
    local bStart = 1
    local bEnd = 5
    local bStep = 1
    if gwGetSetting('BAG_REVERSE_SORT') then
        bStart = 5
        bEnd = 1
        bStep = -1
    end
    for BAG_INDEX = bStart, bEnd, bStep do
        local cfm = 'ContainerFrame' .. tostring(BAG_INDEX)

        if _G[cfm] and _G[cfm]:IsShown()  then
            for i = 40, 1, -1 do
                local slot = _G[cfm .. 'Item' .. i]
                if slot and slot:IsShown() then
                    if x > (winsize - 40) then
                        mx = math.max(mx, x)
                        x = 8
                        y = y + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                    end
                    
                    local slotIcon = _G[cfm .. 'Item' .. i .. 'IconTexture']
                    local slotNormalTexture = _G[cfm .. 'Item' .. i .. 'NormalTexture']
                    local slotQuesttexture= _G[cfm .. 'Item' .. i .. 'IconQuestTexture']
                    local slotCount= _G[cfm .. 'Item' .. i .. 'Count']
                    local backdrop = _G['GwBagItemBackdrop' .. cfm .. 'Item' ..i]
                    if backdrop == nil then
                        backdrop = gw_create_bag_item_background(cfm .. 'Item' .. i)
                    end
                    backdrop:SetParent(_G[cfm])
                    backdrop:SetFrameLevel(1)
                    
                    backdrop:SetPoint('TOPLEFT', gwbf, 'TOPLEFT', x, -y)
                    backdrop:SetPoint('TOPRIGHT', gwbf, 'TOPLEFT', x + BAG_ITEM_SIZE, -y)
                    backdrop:SetPoint('BOTTOMLEFT', gwbf, 'TOPLEFT', x, -y - BAG_ITEM_SIZE)
                    backdrop:SetPoint('BOTTOMRIGHT', gwbf, 'TOPLEFT', x + BAG_ITEM_SIZE, -y - BAG_ITEM_SIZE)
                        
                    _G['GwBagContainer' .. (BAG_INDEX - 1)]:SetSize(x,y)

                    slot:ClearAllPoints()

                    slot:SetPoint('TOPLEFT', gwbf, 'TOPLEFT', x, -y)
                    slot:SetPoint('TOPRIGHT', gwbf, 'TOPLEFT', x + BAG_ITEM_SIZE, -y)
                    slot:SetPoint('BOTTOMLEFT', gwbf, 'TOPLEFT', x, -y - BAG_ITEM_SIZE)
                    slot:SetPoint('BOTTOMRIGHT', gwbf, 'TOPLEFT', x + BAG_ITEM_SIZE, -y - BAG_ITEM_SIZE)
                    
                    if slotCount then
                        slotCount:ClearAllPoints()
                        slotCount:SetPoint('TOPRIGHT', slotCount:GetParent(), 'TOPRIGHT', 0, -3) 
                        slotCount:SetFont(UNIT_NAME_FONT, 12, 'THINOUTLINED') 
                        slotCount:SetJustifyH('RIGHT')
                    end

                    if slot.IconBorder then
                        slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                        slot.IconBorder:SetSize(BAG_ITEM_SIZE, BAG_ITEM_SIZE)
                        if slot.IconBorder.GwhasBeenHooked == nil then
                            hooksecurefunc(slot.IconBorder, 'SetVertexColor', function()
                                 slot.IconBorder:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder')
                            end)
                            slot.IconBorder.GwhasBeenHooked = true
                        end
                    end
                    
                    if slotQuesttexture then
                        slotQuesttexture:SetSize(BAG_ITEM_SIZE, BAG_ITEM_SIZE)
                    end
                    if slotNormalTexture then
                        slot:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal')
                    end
                    if slot.flash then
                        slot.flash:SetSize(BAG_ITEM_SIZE, BAG_ITEM_SIZE)
                    end

                    slotIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    x = x + BAG_ITEM_SIZE + BAG_ITEM_PADDING
                end
            end
        end
    end
    
    gw_update_free_slots()
    if smooth then
        return
    end
    
    BAG_WINDOW_CONTENT_HEIGHT = math.max(350, y + BAG_ITEM_SIZE + (2 * BAG_ITEM_PADDING))
    if mx ~= 0 then
        BAG_WINDOW_SIZE = mx + BAG_ITEM_PADDING
    end
    gwSetSetting('BAG_WIDTH', BAG_WINDOW_SIZE)
    gwbf:SetSize(BAG_WINDOW_SIZE, BAG_WINDOW_CONTENT_HEIGHT)
end

function gw_create_bag_item_background(name)
    return CreateFrame('Frame', 'GwBagItemBackdrop' .. name, GwBagFrame, 'GwBagItemBackdrop')
end

function gw_bagOnResizeStop(self)
    GwBagFrame:SetScript('OnUpdate', nil)
    self:StopMovingOrSizing()
                            
    BAG_WINDOW_SIZE = GwBagFrame:GetWidth()
    gw_update_bag_icons()
                          
    GwBagFrame:ClearAllPoints()
    GwBagFrame:SetPoint('TOPLEFT', GwBagMoverFrame, 'TOPLEFT', 20, -40)
    GwBagFrameResize:ClearAllPoints()
    GwBagFrameResize:SetPoint('BOTTOMRIGHT', GwBagFrame, 'BOTTOMRIGHT', 0, 0)
    
    local mfPoint, _, mfRelPoint, mfxOfs, mfyOfs = GwBagMoverFrame:GetPoint()
    local newWidth = GwBagFrame:GetWidth() - 40
    local oldWidth = GwBagMoverFrame:GetWidth()
    if mfPoint == 'TOP' then
        mfxOfs = mfxOfs + ((newWidth - oldWidth) / 2)
    elseif mfPoint == 'RIGHT' then
        mfxOfs = mfxOfs + (newWidth - oldWidth)
    end
    GwBagMoverFrame:ClearAllPoints()        
    GwBagMoverFrame:SetPoint(mfPoint, UIParent, mfRelPoint, mfxOfs, mfyOfs)
    GwBagMoverFrame:SetWidth(newWidth)
    gw_onBagMove(GwBagMoverFrame)
end

function gw_onBagDragUpdate(self)
    local point, relative, framerela, xPos, yPos = GwBagFrameResize:GetPoint()
    
    local w = self:GetWidth()
    local h = self:GetHeight()
    
    if w < 508 or h < 340 then
        GwBagFrameResize:StopMovingOrSizing()
    else
        gw_update_bag_icons(true)
    end
end

function gw_OnBagFrameChangeSize(self)    
    local w, h = self:GetSize()
    
    w = math.min(1, w / 512)
    h = math.min(1, h / 512) 
    
    self.Texture:SetTexCoord(0, w, 0, h)
end
