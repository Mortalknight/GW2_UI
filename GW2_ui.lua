local _, GW = ...

GW_VERSION_STRING = 'GW2_UI_Classic v0.1'

local loaded = false
local forcedMABags = false

GW_MOVABLE_FRAMES = {}
GW_MOVABLE_FRAMES_REF = {}
GW_MOVABLE_FRAMES_SETTINGS_KEY = {}

local swimAnimation = 0
local lastSwimState = true

local function disableMABags()
    local bags = gwGetSetting('BAGS_ENABLED')
    if not bags or not MovAny or not MADB then return end
    MADB.noBags = true
    MAOptNoBags:SetEnabled(false)
    forcedMABags = true
end

function gwLockableOnClick(name, frame, moveframe, settingsName, lockAble)
    local dummyPoint = gwGetDefault(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(dummyPoint['point'], UIParent, dummyPoint['relativePoint'], dummyPoint['xOfs'], dummyPoint['yOfs'])
    GW_MOVABLE_FRAMES[name] = moveframe
    GW_MOVABLE_FRAMES_REF[name] = frame
    GW_MOVABLE_FRAMES_SETTINGS_KEY[name] = settingsName
                
    local point, relativeTo, relativePoint, xOfs, yOfs = moveframe:GetPoint()
            
    local new_point = gwGetSetting(settingsName)
    new_point['point'] = point
    new_point['relativePoint'] = relativePoint
    new_point['xOfs'] = math.floor(xOfs)
    new_point['yOfs'] = math.floor(yOfs)
    gwSetSetting(settingsName, new_point)

    gwSetSetting(lockAble, true)
end
function gwMoveOnDragStop(moveframe, settingsName, lockAble)
    moveframe:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = moveframe:GetPoint()
            
    local new_point = gwGetSetting(settingsName)
    new_point['point'] = point
    new_point['relativePoint'] = relativePoint
    new_point['xOfs'] = math.floor(xOfs)
    new_point['yOfs'] = math.floor(yOfs)
    gwSetSetting(settingsName, new_point)
    if lockAble ~= nil then
        gwSetSetting(lockAble, false)
    end
end
function gw_register_movable_frame(name,frame,settingsName,dummyFrame,lockAble)
    local moveframe = CreateFrame('Frame', name .. 'MoveAble', UIParent, dummyFrame)
    moveframe:SetSize(frame:GetSize())
    moveframe.frameName:SetText(name)

    local dummyPoint = gwGetSetting(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(dummyPoint['point'], UIParent, dummyPoint['relativePoint'], dummyPoint['xOfs'], dummyPoint['yOfs'])
    GW_MOVABLE_FRAMES[name] = moveframe
    GW_MOVABLE_FRAMES_REF[name] = frame
    GW_MOVABLE_FRAMES_SETTINGS_KEY[name] = settingsName
    moveframe:Hide()
    moveframe:RegisterForDrag("LeftButton")
    
    if lockAble ~= nil then
        local lockFrame = CreateFrame('Button', name .. 'LockButton', moveframe, 'GwDummyLockButton')
        lockFrame:SetScript('OnClick', function()
            gwLockableOnClick(name, frame, moveframe, settingsName, lockAble)
        end)
    end

    moveframe:SetScript("OnDragStart", frame.StartMoving)
    moveframe:SetScript("OnDragStop", function()
        gwMoveOnDragStop(moveframe, settingsName, lockAble)
    end)
    
end

function gw_update_moveableframe_positions()
    for k, v in pairs(GW_MOVABLE_FRAMES_REF) do
        local newp = gwGetSetting(GW_MOVABLE_FRAMES_SETTINGS_KEY[k])
        v:ClearAllPoints()
        GW_MOVABLE_FRAMES_REF[k]:SetPoint(newp['point'], UIParent, newp['relativePoint'], newp['xOfs'], newp['yOfs'])
    end
end

function gwUpdateHudScale(scale)
    for k, v in pairs(GW_MAIN_HUD_FRAMES) do
        if _G[v] then
            _G[v]:SetScale(gwGetSetting('HUD_SCALE'))
        end
    end
end

function gwToggleMainHud(b)
    for k, v in pairs(GW_MAIN_HUD_FRAMES) do
        if v ~= nil and _G[v] then
            if b then
                if GW_MAIN_HUD_FRAMES_OLD_STATE[k] then
                    _G[v]:Show()
                end
            else
                GW_MAIN_HUD_FRAMES_OLD_STATE[k] = _G[v]:IsShown()
                _G[v]:Hide()
            end
        end
    end
end

if AchievementMicroButton_Update == nil then
    function AchievementMicroButton_Update()
        return
    end
end

animations = {}

function gwButtonAnimation(self, name, w)
    local prog = animations[name]['progress']
    local l = GW.lerp(0, w, prog)
            
    _G[name..'OnHover']:SetPoint('RIGHT', self, 'LEFT', l, 0)
    _G[name..'OnHover']:SetVertexColor(1, 1, 1, GW.lerp(0, 1, ((prog) - 0.5)/0.5))
end

function gw_button_enter(self)
    local name = self:GetName()
    local w = self:GetWidth()
    _G[name..'OnHover']:SetAlpha(1)
    
    self.animationValue = 0
    
    addToAnimation(name, self.animationValue, 1, GetTime(), 0.2, function()
        gwButtonAnimation(self, name, w)
    end)
end

function gw_button_leave(self)
    local name = self:GetName()
    local w = self:GetWidth()
    _G[name..'OnHover']:SetAlpha(1)
    
    self.animationValue = 1
    
    addToAnimation(name, self.animationValue, 0, GetTime(), 0.2, function()
        gwButtonAnimation(self, name, w)
    end)
end

function gwBarAnimation(self, barWidth, sparkWidth)
    local snap = (animations[self.animationName]['progress'] * 100) / 5
            
    local round_closest = 0.05 * snap
  
    local spark_min =  math.floor(snap)
    local spark_current = snap

    local spark_prec = spark_current - spark_min
                            
    local spark = math.min(barWidth - sparkWidth, math.floor(barWidth * round_closest) - math.floor(sparkWidth * spark_prec))
    local bI = 17 - math.max(1, GW.intRound(16 * spark_prec))

    self.spark:SetTexCoord(
        bloodSpark[bI].left,
        bloodSpark[bI].right,
        bloodSpark[bI].top,
        bloodSpark[bI].bottom)

    self:SetValue(round_closest)
    self.spark:ClearAllPoints()
    self.spark:SetPoint('LEFT', spark, 0)
end

function gwBar(self, value)
    if self == nil then return end
    local barWidth = self:GetWidth()
    local sparkWidth = self.spark:GetWidth()
    
    addToAnimation(self.animationName, self.animationValue, value, GetTime(), 0.2, function()
        gwBarAnimation(self, barWidth, sparkWidth)
    end)
    self.animationValue = value
end

function gw_setClassIcon(self, class)
    if class == nil or class > 12 then
        class = 0
    end
  
    self:SetTexCoord(
        GW_CLASS_ICONS[class].l,
        GW_CLASS_ICONS[class].r,
        GW_CLASS_ICONS[class].t,
        GW_CLASS_ICONS[class].b
    )
end

function gw_setDeadIcon(self)
    self:SetTexCoord(
        GW_CLASS_ICONS['dead'].l,
        GW_CLASS_ICONS['dead'].r,
        GW_CLASS_ICONS['dead'].t,
        GW_CLASS_ICONS['dead'].b
    )
end

function addToAnimation(name, from, to, start, duration, method, easeing, onCompleteCallback, doCompleteOnOverider)
    newAnimation = true
    if animations[name] ~= nil then
        if (animations[name]['start'] + animations[name]['duration']) > GetTime() then
            newAnimation = false
        end
    end
    if doCompleteOnOverider == nil then
         newAnimation = true
    end
    
    if newAnimation == false then
        animations[name]['duration'] = duration
        animations[name]['to'] = to
        animations[name]['progress'] = 0
        animations[name]['method'] = method
        animations[name]['completed'] = false
        animations[name]['easeing'] = easeing
        animations[name]['onCompleteCallback'] = onCompleteCallback
    else
        animations[name] = {}
        animations[name]['start'] = start
        animations[name]['duration'] = duration
        animations[name]['from'] = from
        animations[name]['to'] = to
        animations[name]['progress'] = 0
        animations[name]['method'] = method
        animations[name]['completed'] = false
        animations[name]['easeing'] = easeing
        animations[name]['onCompleteCallback'] = onCompleteCallback
    end
end

function GwStopAnimation(k)
    if animations[k] ~= nil then
        animations[k] = nil
    end
end

local l = CreateFrame("Frame", nil, UIParent)
local OnUpdateActionBars = nil

function gwSwimAnimation()
    local r, g, b = _G['GwActionBarHudRIGHTSWIM']:GetVertexColor()
    _G['GwActionBarHudRIGHTSWIM']:SetVertexColor(r, g, b, animations['swimAnimation']['progress'])
    _G['GwActionBarHudLEFTSWIM']:SetVertexColor(r, g, b, animations['swimAnimation']['progress'])
end

function GwOnUpdate(self, elapsed)
    local foundAnimation = false
    local count = 0
    for k, v in pairs(animations) do
        count = count + 1
        if v['completed'] == false and GetTime() >= (v['start'] + v['duration']) then
            if v['easeing'] == nil then
                v['progress'] = GW.lerp(v['from'], v['to'], math.sin(1 * math.pi * 0.5))
            else
                v['progress'] = GW.lerp(v['from'], v['to'], 1)
            end
            if v['method'] ~= nil then
                v['method'](v['progress'])
            end

            if v['onCompleteCallback'] ~= nil then
                v['onCompleteCallback']()
            end

            v['completed'] = true
            foundAnimation = true
        end
        if v['completed'] == false then
            if v['easeing'] == nil then
                v['progress'] = GW.lerp(v['from'], v['to'], math.sin((GetTime() - v['start']) / v['duration'] * math.pi * 0.5))
            else
                v['progress'] = GW.lerp(v['from'], v['to'], (GetTime() - v['start']) / v['duration'])
            end
            v['method'](v['progress'])
            foundAnimation = true
        end
    end

    if foundAnimation == false and count ~= 0 then
        table.wipe(animations)
    end

    if OnUpdateActionBars then
        OnUpdateActionBars(elapsed)
    end

    --Swim hud
    if lastSwimState ~= IsSwimming() then
        if IsSwimming() then
            addToAnimation('swimAnimation', swimAnimation, 1, GetTime(), 0.1, gwSwimAnimation)
            swimAnimation = 1
        else
            addToAnimation('swimAnimation', swimAnimation, 0, GetTime(), 3.0, gwSwimAnimation)
            swimAnimation = 0
        end
        lastSwimState = IsSwimming()
    end
end

-- overrides for the alert frame subsystem update loop in Interface/FrameXML/AlertFrames.lua
local function adjustFixedAnchors(self, relativeAlert)
    if self.anchorFrame:IsShown() then
        local pt, relTo, relPt, xOf, _ = self.anchorFrame:GetPoint()
        local name = self.anchorFrame:GetName()
        if pt == 'BOTTOM' and relTo:GetName() == 'UIParent' and relPt == 'BOTTOM' then
            if name == 'TalkingHeadFrame' then
                self.anchorFrame:ClearAllPoints()
                self.anchorFrame:SetPoint(pt, relTo, relPt, xOf, GwAlertFrameOffsetter:GetHeight())
            elseif name == 'GroupLootContainer' then
                self.anchorFrame:ClearAllPoints()
                if TalkingHeadFrame and TalkingHeadFrame:IsShown() then
                    self.anchorFrame:SetPoint(pt, relTo, relPt, xOf, GwAlertFrameOffsetter:GetHeight() + 140)
                else
                    self.anchorFrame:SetPoint(pt, relTo, relPt, xOf, GwAlertFrameOffsetter:GetHeight())
                end
            end
        end
        return self.anchorFrame
	end
	return relativeAlert
end
local function updateAnchors(self)
    self:CleanAnchorPriorities()

    local relativeFrame = GwAlertFrameOffsetter
    for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
        if alertFrameSubSystem.AdjustAnchors == AlertFrameJustAnchorMixin.AdjustAnchors then
            relativeFrame = adjustFixedAnchors(alertFrameSubSystem, relativeFrame)
        else
            relativeFrame = alertFrameSubSystem:AdjustAnchors(relativeFrame)
        end
    end
end

function gwOnEvent(self, event, name)
    if loaded then return end
    if event ~= 'PLAYER_LOGIN' then return end
    loaded = true
    
    disableMABags()
    
    -- hook debug output if relevant
    local dev_dbg_tab = gwGetSetting('DEV_DBG_CHAT_TAB')
    if dev_dbg_tab and dev_dbg_tab > 0 then
        print('hooking gwDebug to chat tab #' .. dev_dbg_tab)
        gwDebug = function(...)
            local debug_tab = _G['ChatFrame' .. dev_dbg_tab]
            if not debug_tab then return end
            local msg = ''
            for i = 1, select('#', ...) do
                local arg = select(i, ...)
                msg = msg .. tostring(arg) .. ' '
            end
            debug_tab:AddMessage(date("%H:%M:%S") .. ' ' .. msg)
        end
        gwAlertTestsSetup()
    end

    --Create Settings window
    create_settings_window()
    display_options()
            
    --Create hud art
    loadHudArt()
            
    --Create experiencebar
    loadExperienceBar()
        
    if gwGetSetting('FONTS_ENABLED') then
        gw_register_fonts()
    end
    if gwGetSetting('CASTINGBAR_ENABLED') then
        gw_register_castingbar()
    end
        
    if gwGetSetting('MINIMAP_ENABLED') then
        gw_set_minimap()
    end
    if gwGetSetting('QUESTTRACKER_ENABLED') then
        --QUESTTRACKER
        --gw_load_questTracker()
    end
    if gwGetSetting('TOOLTIPS_ENABLED') then
        gw_set_tooltips()
    end
    if gwGetSetting('QUESTVIEW_ENABLED') then
        gw_create_questview()
    end
    if gwGetSetting('CHATFRAME_ENABLED') then
        --gw_set_chatframe_bg()
    end
    --Create player hud
    if gwGetSetting('HEALTHGLOBE_ENABLED') then
        gw_create_player_hud()
    end
        
    if gwGetSetting('POWERBAR_ENABLED') then
        gw_create_power_bar()
    end

    if gwGetSetting('BAGS_ENABLED') then
        gw_create_bgframe()
        --gw_create_bankframe()
    end
    if gwGetSetting('USE_BATTLEGROUND_HUD') then
        --gwLoadBattlegrounds()
    end
        
    --Gw_LoadWindows()
        
    gw_breath_meter()
        
    if gwGetSetting('TARGET_ENABLED') then
        gw_unitframes_register_Target()
        if gwGetSetting('target_TARGET_ENABLED') then
            gw_unitframes_register_Targetstarget()
        end

        -- move zone text frame
        if not gwIsFrameModified('ZoneTextFrame') then
            gwDebug('moving ZoneTextFrame')
            ZoneTextFrame:ClearAllPoints()
            ZoneTextFrame:SetPoint('TOP', UIParent, 'TOP', 0, -175)
        end

        -- move error frame
        if not gwIsFrameModified('UIErrorsFrame') then
            gwDebug('moving UIErrorsFrame')
            UIErrorsFrame:ClearAllPoints()
            UIErrorsFrame:SetPoint('TOP', UIParent, 'TOP', 0, -190)
        end
    end
           
    -- create buff frame
    if gwGetSetting('PLAYER_BUFFS_ENABLED') then
        gw_set_buffframe()
    end
    
    -- create pet frame
    if gwGetSetting('PETBAR_ENABLED') then
        gw_create_pet_frame()
    end

    -- create action bars
    if gwGetSetting('ACTIONBARS_ENABLED') then
        gwSetupActionbars()
        if gwGetSetting('FADE_BOTTOM_ACTIONBAR') then
            OnUpdateActionBars = function(elapsed)
                gwActionBar_FadeCheck(MultiBarBottomLeft, elapsed)
                gwActionBar_FadeCheck(MultiBarBottomRight, elapsed)
                gwActionBar_FadeCheck(MultiBarRight, elapsed)
                gwActionBar_FadeCheck(MultiBarLeft, elapsed)
            end
        end

        -- frames using the alert frame subsystem have their positioning managed by UIParent
        -- the secure code for that lives mostly in Interface/FrameXML/UIParent.lua
        -- we can override the alert frame subsystem update loop in Interface/FrameXML/AlertFrames.lua
        -- doing it there avoids any taint issues
        -- we also exclude a few frames from the auto-positioning stuff regardless
        GwAlertFrameOffsetter:SetHeight(205)
        UIPARENT_MANAGED_FRAME_POSITIONS['ExtraActionBarFrame'] = nil
        UIPARENT_MANAGED_FRAME_POSITIONS['ZoneAbilityFrame'] = nil
        UIPARENT_MANAGED_FRAME_POSITIONS['GroupLootContainer'] = nil
        UIPARENT_MANAGED_FRAME_POSITIONS['TalkingHeadFrame'] = nil
        --if not gwIsFrameModified('ExtraActionBarFrame') then
        --    gwDebug('moving ExtraActionBarFrame')
        --    ExtraActionBarFrame:ClearAllPoints()
        --    ExtraActionBarFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 130)
        --    ExtraActionBarFrame:SetFrameStrata('MEDIUM')
        --end
        --if not gwIsFrameModified('ZoneAbilityFrame') then
        --    gwDebug('moving ZoneAbilityFrame')
        --    ZoneAbilityFrame:ClearAllPoints()
        --    ZoneAbilityFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 130)
        --end
        AlertFrame.UpdateAnchors = updateAnchors

        -- fix position of some things dependent on action bars
        gw_updatePetFrameLocation()
        gw_updatePlayerBuffFrameLocation()
    end
    
    --[[
    if gwGetSetting('CHATBUBBLES_ENABLED') then
        gw_register_chatbubbles()
    end
    ]]--
        
    -- create new microbuttons
    gwCreateMicroMenu()
        
    if gwGetSetting('GROUP_FRAMES') then
        gw_register_partyframes()
        gw_register_raidframes()
    end
    
    gwUpdateHudScale()

    if (forcedMABags) then
        gwNotice(GwLocalization['DISABLED_MA_BAGS'])
    end

    l:SetScript('OnUpdate', GwOnUpdate)
end
l:SetScript('OnEvent', gwOnEvent)
l:RegisterEvent('PLAYER_LOGIN')

function GwaddTOClique(frame)
    if type(frame) == "string" then
        local frameName = frame
        frame = _G[frameName]
    end

    if frame and frame.RegisterForClicks and ClickCastFrames ~= nil then
        ClickCastFrames[frame] = true
    end
end

local waitTable = {}
local waitFrame = nil
function gwWaitOnUpdate(self, elapse)
    local count = #waitTable
    local i = 1
    while(i <= count) do
        local waitRecord = tremove(waitTable, i)
        local d = tremove(waitRecord, 1)
        local f = tremove(waitRecord, 1)
        local p = tremove(waitRecord, 1)
        if(d > elapse) then
            tinsert(waitTable, i, {d - elapse, f, p})
            i = i + 1
        else
            count = count - 1
            f(unpack(p))
        end
    end
end
function gw_wait(delay, func, ...)
    if type(delay) ~= "number" or type(func) ~= "function" then
        return false
    end
    if waitFrame == nil then
        waitFrame = CreateFrame("Frame", "GwWaitFrame", UIParent)
        waitFrame:SetScript("OnUpdate", gwWaitOnUpdate)
    end
    tinsert(waitTable, {delay, func, {...}})
    return true
end

function gwNotice(...)
    local msg_tab = _G['ChatFrame1']
    if not msg_tab then return end
    local msg = ''
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. ' '
    end
    msg_tab:AddMessage('|cffC0C0F0GW2 UI|r: ' .. msg)
end

function gwDebug()
    return
end

function gwIsFrameModified(f_name)
    if not MovAny then return false end
    return MovAny:IsModified(f_name)
end

function gwHideSelf(self)
    self:Hide()
end
