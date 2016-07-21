
local settings_cat ={}
local options = {}





function create_settings_window()
local mf = CreateFrame('Frame','GwSettingsMoverFrame',UIParent,'GwSettingsMoverFrame')
 local sWindow = CreateFrame('Frame','GwSettingsWindow',UIParent,'GwSettingsWindow')
    
    sWindow:SetScript('OnShow',function() mf:Show() end)
    sWindow:SetScript('OnHide',function() mf:Hide() end)
    mf:Hide()
    
    
    
    GwMainMenuFrame = CreateFrame('Button','GwMainMenuFrame',GameMenuFrame,'GwStandardButton')
    GwMainMenuFrame:SetText('GW2 UI Settings')
    GwMainMenuFrame:ClearAllPoints()
    GwMainMenuFrame:SetPoint('TOP',GameMenuFrame,'BOTTOM',0,0 )
    GwMainMenuFrame:SetScript('OnClick',function() sWindow:Show()
            if InCombatLockdown() then
                return
            end         
    ToggleGameMenu() end)
    
    
    lhb = CreateFrame('Button','GwLockHudButton',UIParent,'GwStandardButton')
    lhb:SetScript('OnClick',gw_lockHudObjects)
    lhb:ClearAllPoints()
    lhb:SetText('Lock Hud')
    lhb:SetPoint('TOP',UIParent,'TOP',0,0)
    lhb:Hide()


    
    create_settings_cat('MODULES','Enable and disable components','GwSettingsModuleOption',0)
    
    
    
    
    addOption('Health Globe','Health Bar Replacement','HEALTHGLOBE_ENABLED','GwSettingsModuleOption')
    addOption('Power','Mana/Power Bar Replacement','POWERBAR_ENABLED','GwSettingsModuleOption')
    addOption('Focus','Focus Frame Replacement','FOCUS_ENABLED','GwSettingsModuleOption')
    addOption('Target','Target Frame Replacement','TARGET_ENABLED','GwSettingsModuleOption')
    addOption('Chatbubbles', 'Use the GW2 Chatbubbles','CHATBUBBLES_ENABLED','GwSettingsModuleOption')
    addOption('Minimap', 'Use the GW2 Minimap frame','MINIMAP_ENABLED','GwSettingsModuleOption')
    addOption('Quest Tracker', 'Use the revamped Quest Tracker','QUESTTRACKER_ENABLED','GwSettingsModuleOption')
    addOption('Tooltips', 'Use the GW2 Tooltips','TOOLTIPS_ENABLED','GwSettingsModuleOption')
    addOption('Chat', 'Use the restyled Chat Frame','CHATFRAME_ENABLED','GwSettingsModuleOption')
    addOption('Immersive Questing', 'Use the immersive Quest Screen','QUESTVIEW_ENABLED','GwSettingsModuleOption')
    addOption('Player Auras', 'Move and resize player auras','PLAYER_BUFFS_ENABLED','GwSettingsModuleOption')
    addOption('Action Bars', 'Use the GW2 styled action bars','ACTIONBARS_ENABLED','GwSettingsModuleOption')
    addOption('Bags', 'Use the unified GW2 bag interface','BAGS_ENABLED','GwSettingsModuleOption')
    addOption('Font', 'Use the GW2 fonts','FONTS_ENABLED','GwSettingsModuleOption')
    
    create_settings_cat('TARGET','Edit the target frame settings','GwSettingsTargetOptions',1)
    
    addOption('Target of Target','Display the target\'s target','target_TARGET_ENABLED','GwSettingsTargetOptions')
    addOption('Health Value','Display health information','target_HEALTH_VALUE_ENABLED','GwSettingsTargetOptions')
    addOption('Health Percentage','Display health info as a percentage','target_HEALTH_VALUE_TYPE','GwSettingsTargetOptions')
    addOption('Show Debuffs','Display the target\'s debuffs','target_DEBUFFS','GwSettingsTargetOptions')

    addOption('Show Buffs','Display the target\'s buffs','target_BUFFS','GwSettingsTargetOptions')
    
    
    create_settings_cat('FOCUS','Edit focus frame settings','GwSettingsFocusOptions',2)
    
    addOption('Focus Target','Display the focus target','focus_TARGET_ENABLED','GwSettingsFocusOptions')
    addOption('Health Value','Display health information','focus_HEALTH_VALUE_ENABLED','GwSettingsFocusOptions')
    addOption('Health Percentage','Display health info as a percentage','focus_HEALTH_VALUE_TYPE','GwSettingsFocusOptions')
    addOption('Show Debuffs','Display the focus target\'s debuffs','focus_DEBUFFS','GwSettingsFocusOptions')
    addOption('Show Buffs','Display the focus target\'s buffs','focus_BUFFS','GwSettingsFocusOptions')
   
    create_settings_cat('HUD','Edit HUD settings','GwSettingsHudOptions',3)
    addOption('Fade Actionbars','Fade the extra action bars','FADE_BOTTOM_ACTIONBAR','GwSettingsHudOptions')
    addOption('Dynamic HUD','Change the HUD appearance','HUD_SPELL_SWAP','GwSettingsHudOptions')
    addOption('Fade Chat','Fade the chat while inactive','CHATFRAME_FADE','GwSettingsHudOptions')
    
    
    
    GwSettingsWindow:Hide()
end




function create_settings_cat(name,desc,frameName,icon)
    
    local i = countTable(settings_cat)
    settings_cat[i] = frameName

    local f = CreateFrame('Button','GwSettingsLabel'..i,UIParent,'GwSettingsLabel')
    f:SetPoint('TOPLEFT',-40,-32+(-40*i))
    _G['GwSettingsLabel'..i..'Texture']:SetTexCoord(0,1,0.25*icon,0.25*(icon+1))
    
    f:SetScript('OnEnter',function() 
        GameTooltip:SetOwner(f, "ANCHOR_CURSOR"); GameTooltip:ClearLines();  GameTooltip:SetText(name..'\n'..desc) GameTooltip:Show()     
    end)
    f:SetScript('OnLeave',function() 
        GameTooltip:Hide()  
    end)

    
    f:SetScript('OnClick',function(event) 
         switch_settings_cat(i)    
    end)
    
end

function switch_settings_cat(index)
    for k,v in pairs(settings_cat) do 
        if k~=index then
            _G[v]:Hide()
        else
            _G[v]:Show()
            UIFrameFadeIn(_G[v], 0.2,0,1)
        end
    end
   
    
end


function addOption(name,desc,optionName,frameName)
    
    local i = countTable(options)

    options[i] = {}
    options[i]['name'] = name;
    options[i]['desc'] = desc;
    options[i]['optionName'] = optionName;
    options[i]['frameName'] = frameName;
    
end

function display_options()
    local box_padding = 8
    local pX = 244
    local pY = -48
    
    local padding = {}
    
    for k,v in pairs(options) do 
        
        if padding[v['frameName']]==nil then
            padding[v['frameName']] = {}
            padding[v['frameName']]['x']=  box_padding
            padding[v['frameName']]['y']=-55
        end
        
        local of =  CreateFrame('Button','GwOptionBox'..k,_G[v['frameName']],'GwOptionBox')
        
        of:ClearAllPoints()
        of:SetPoint('TOPLEFT',padding[v['frameName']]['x'],padding[v['frameName']]['y'])
        _G['GwOptionBox'..k..'Title']:SetText(v['name'])
        _G['GwOptionBox'..k..'Title']:SetFont(DAMAGE_TEXT_FONT,12)
        _G['GwOptionBox'..k..'Title']:SetTextColor(255/255,241/255,209/255)
        _G['GwOptionBox'..k..'Title']:SetShadowColor(1,1,1,0)
        
        _G['GwOptionBox'..k..'Sub']:SetText(v['desc'])
        _G['GwOptionBox'..k..'Sub']:SetFont(UNIT_NAME_FONT,11)
        _G['GwOptionBox'..k..'Sub']:SetTextColor(181/255,160/255,128/255)
        _G['GwOptionBox'..k..'Sub']:SetShadowColor(1,1,1,0)

        
        _G['GwOptionBox'..k..'CheckButton']:SetChecked(gwGetSetting(v['optionName']))
        _G['GwOptionBox'..k..'CheckButton']:SetScript('OnClick',function()
            
            toSet = false
            if _G['GwOptionBox'..k..'CheckButton']:GetChecked() then
                toSet = true
            end
            gwSetSetting(v['optionName'],toSet)
        
        end)
        
        

      
        padding[v['frameName']]['x'] = padding[v['frameName']]['x'] + pX + box_padding
        if padding[v['frameName']]['x']>440 then
            padding[v['frameName']]['y'] = padding[v['frameName']]['y'] + pY + box_padding
            padding[v['frameName']]['x'] = box_padding
        end
    end
    
end
    
    
tinsert(UISpecialFrames, "GwSettingsWindow") 
    

    SLASH_GWSLASH1 = "/gw2";
    function SlashCmdList.GWSLASH(msg)
        GwSettingsWindow:Show()
        UIFrameFadeIn(GwSettingsWindow, 0.2,0,1)
    end


local settings_window_open_before_change = false
function gw_moveHudObjects()
    lhb:Show()
    if GwSettingsWindow:IsShown() then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for k,v in pairs(GW_MOVABLE_FRAMES) do
        v:EnableMouse(true)
        v:SetMovable(true)
        v:Show()
    end
end
function gw_lockHudObjects()
    lhb:Hide()
    if settings_window_open_before_change then
        settings_window_open_before_change = false
        GwSettingsWindow:Show()
    end
   
    for k,v in pairs(GW_MOVABLE_FRAMES) do
        v:EnableMouse(false)
        v:SetMovable(false)
        v:Hide()
    end
    gw_update_moveableframe_positions()
end

