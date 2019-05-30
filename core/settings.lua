local _, GW = ...

local settings_cat ={}
local options = {}


--[[

GW_PROFILE_ICONS_PRESET[1] = 'Interface\\icons\\inv_corgi2'
GW_PROFILE_ICONS_PRESET[2] = 'Interface\\icons\\inv_helmet_151'
]]--

local GW_PROFILE_ICONS_PRESET = {}

GW_PROFILE_ICONS_PRESET[0] = 'Interface\\icons\\spell_druid_displacement'
GW_PROFILE_ICONS_PRESET[1] = 'Interface\\icons\\ability_socererking_arcanemines'
GW_PROFILE_ICONS_PRESET[2] = 'Interface\\icons\\ability_warrior_bloodbath'
GW_PROFILE_ICONS_PRESET[3] = 'Interface\\icons\\ability_priest_ascendance'
GW_PROFILE_ICONS_PRESET[4] = 'Interface\\icons\\spell_mage_overpowered'
GW_PROFILE_ICONS_PRESET[5] = 'Interface\\icons\\achievement_boss_kingymiron'
GW_PROFILE_ICONS_PRESET[6] = 'Interface\\icons\\spell_fire_elementaldevastation'

function create_settings_window()
    CreateFrame('Frame','GwWarningPromt',UIParent,'GwWarningPromt')
    
    tinsert(UISpecialFrames, "GwWarningPromt") 
    
    local mf = CreateFrame('Frame','GwSettingsMoverFrame',UIParent,'GwSettingsMoverFrame')
    local sWindow = CreateFrame('Frame','GwSettingsWindow',UIParent,'GwSettingsWindow')
    
    sWindow:SetScript('OnShow',function() mf:Show() end)
    sWindow:SetScript('OnHide',function() mf:Hide() end)
    mf:Hide()
    
    
    
    GwMainMenuFrame = CreateFrame('Button','GwMainMenuFrame',GameMenuFrame,'GwStandardButton')
    GwMainMenuFrame:SetText(GwLocalization['SETTINGS_BUTTON'])
    GwMainMenuFrame:ClearAllPoints()
    GwMainMenuFrame:SetPoint('TOP',GameMenuFrame,'BOTTOM',0,0 )
	GwMainMenuFrame:SetSize(150,24)
    GwMainMenuFrame:SetScript('OnClick',function() sWindow:Show()
            if InCombatLockdown() then
                return
            end         
    ToggleGameMenu() end)
    
    
    lhb = CreateFrame('Button','GwLockHudButton',UIParent,'GwStandardButton')
    lhb:SetScript('OnClick',gw_lockHudObjects)
    lhb:ClearAllPoints()
    lhb:SetText(GwLocalization['SETTING_LOCK_HUD'])
    lhb:SetPoint('TOP',UIParent,'TOP',0,0)
    lhb:Hide()


    
    create_settings_cat(GwLocalization['MODULES_CAT'],GwLocalization['MODULES_CAT_TOOLTIP'],'GwSettingsModuleOption',0)
    
    
    
    
    addOption(GwLocalization['HEALTH_GLOBE'],GwLocalization['HEALTH_GLOBE_DESC'],'HEALTHGLOBE_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['RESOURCE'],GwLocalization['RESOURCE_DESC'],'POWERBAR_ENABLED','GwSettingsModuleOption')
    --addOption(GwLocalization['FOCUS_FRAME'],GwLocalization['FOCUS_FRAME_DESC'],'FOCUS_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['TARGET_FRAME'],GwLocalization['TARGET_FRAME_DESC'],'TARGET_ENABLED','GwSettingsModuleOption')
    --addOption(GwLocalization['CHAT_BUBBLES'], GwLocalization['CHAT_BUBBLES_DESC'],'CHATBUBBLES_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['MINIMAP'], GwLocalization['MINIMAP_DESC'],'MINIMAP_ENABLED','GwSettingsModuleOption')
    --addOption(GwLocalization['QUEST_TRACKER'], GwLocalization['QUEST_TRACKER_DESC'],'QUESTTRACKER_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['TOOLTIPS'], GwLocalization['TOOLTIPS_DESC'],'TOOLTIPS_ENABLED','GwSettingsModuleOption')
    --addOption(GwLocalization['CHAT_FRAME'], GwLocalization['CHAT_FRAME_DESC'],'CHATFRAME_ENABLED','GwSettingsModuleOption')
    --addOption(GwLocalization['QUESTING_FRAME'], GwLocalization['QUESTING_FRAME_DESC'],'QUESTVIEW_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['PLAYER_AURAS'], GwLocalization['PLAYER_AURAS_DESC'],'PLAYER_BUFFS_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['ACTION_BARS'], GwLocalization['ACTION_BARS_DESC'],'ACTIONBARS_ENABLED','GwSettingsModuleOption')
	addOption(GwLocalization['PET_BAR'], GwLocalization['PET_BAR_DESC'],'PETBAR_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['INVENTORY_FRAME'], GwLocalization['INVENTORY_FRAME_DESC'],'BAGS_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['FONTS'], GwLocalization['FONTS_DESC'],'FONTS_ENABLED','GwSettingsModuleOption')
    addOption(GwLocalization['CASTING_BAR'], GwLocalization['CASTING_BAR_DESC'],'CASTINGBAR_ENABLED','GwSettingsModuleOption')
    --addOption(GwLocalization['CLASS_POWER'], GwLocalization['CLASS_POWER_DESC'],'CLASS_POWER','GwSettingsModuleOption')
    addOption(GwLocalization['GROUP_FRAMES'], GwLocalization['GROUP_FRAMES_DESC'],'GROUP_FRAMES','GwSettingsModuleOption')
    --addOption(GwLocalization['CHARACTER_WINDOW'], GwLocalization['CHRACTER_WINDOW_DESC'],'USE_CHARACTER_WINDOW','GwSettingsModuleOption')
    
    create_settings_cat(GwLocalization['TARGET_CAT'],GwLocalization['TARGET_TOOLTIP'],'GwSettingsTargetFocus',1)
    
    addOption(GwLocalization['TARGET_OF_TARGET'],GwLocalization['TARGET_OF_TARGET_DESC'],'target_TARGET_ENABLED','GwSettingsTargetOptions')
    addOption(GwLocalization['HEALTH_VALUE'],GwLocalization['HEALTH_VALUE_DESC'],'target_HEALTH_VALUE_ENABLED','GwSettingsTargetOptions')
    addOption(GwLocalization['HEALTH_PERCENTAGE'],GwLocalization['HEALTH_PERCENTAGE_DESC'],'target_HEALTH_VALUE_TYPE','GwSettingsTargetOptions')
    addOption(GwLocalization['CLASS_COLOR'],GwLocalization['CLASS_COLOR_DESC'],'target_CLASS_COLOR','GwSettingsTargetOptions')
    addOption(GwLocalization['SHOW_DEBUFFS'],GwLocalization['SHOW_DEBUFFS_DESC'],'target_DEBUFFS','GwSettingsTargetOptions')
    addOption(GwLocalization['SHOW_ALL_DEBUFFS'],GwLocalization['SHOW_ALL_DEBUFFS_DESC'],'target_BUFFS_FILTER_ALL','GwSettingsTargetOptions')
    addOption(GwLocalization['SHOW_BUFFS'],GwLocalization['SHOW_BUFFS_DESC'],'target_BUFFS','GwSettingsTargetOptions')
    --addOption(GwLocalization['FOCUS_TARGET'],GwLocalization['FOCUS_TARGET_DESC'],'focus_TARGET_ENABLED','GwSettingsFocusOptions')
    --addOption(GwLocalization['HEALTH_VALUE'],GwLocalization['HEALTH_VALUE_DESC'],'focus_HEALTH_VALUE_ENABLED','GwSettingsFocusOptions')
    --addOption(GwLocalization['HEALTH_PERCENTAGE'],GwLocalization['HEALTH_PERCENTAGE_DESC'],'focus_HEALTH_VALUE_TYPE','GwSettingsFocusOptions')
    --addOption(GwLocalization['CLASS_COLOR'],GwLocalization['CLASS_COLOR_DESC'],'focus_CLASS_COLOR','GwSettingsFocusOptions')
    --addOption(GwLocalization['SHOW_DEBUFFS'],GwLocalization['SHOW_DEBUFFS_DESC'],'focus_DEBUFFS','GwSettingsFocusOptions')
    --addOption(GwLocalization['SHOW_ALL_DEBUFFS'],GwLocalization['SHOW_ALL_DEBUFFS_DESC'],'focus_BUFFS_FILTER_ALL','GwSettingsFocusOptions')
    --addOption(GwLocalization['SHOW_BUFFS'],GwLocalization['SHOW_BUFFS_DESC'],'focus_BUFFS','GwSettingsFocusOptions')
   
   
    create_settings_cat(GwLocalization['HUD_CAT'],GwLocalization['HUD_TOOLTIP'],'GwSettingsHudOptions',3)
	
    addOption(GwLocalization['ACTION_BAR_FADE'],GwLocalization['ACTION_BAR_FADE_DESC'],'FADE_BOTTOM_ACTIONBAR','GwSettingsHudOptions')
    addOption(GwLocalization['DYNAMIC_HUD'],GwLocalization['DYNAMIC_HUD_DESC'],'HUD_SPELL_SWAP','GwSettingsHudOptions')
    addOption(GwLocalization['CHAT_FADE'],GwLocalization['CHAT_FADE_DESC'],'CHATFRAME_FADE','GwSettingsHudOptions')
    addOption(GwLocalization['HIDE_EMPTY_SLOTS'],GwLocalization['HIDE_EMPTY_SLOTS_DESC'],'HIDEACTIONBAR_BACKGROUND_ENABLED','GwSettingsHudOptions')
    addOption(GwLocalization['COMPASS_TOGGLE'],GwLocalization['COMPASS_TOGGLE_DESC'],'SHOW_QUESTTRACKER_COMPASS','GwSettingsHudOptions')
    addOption(GwLocalization['ADV_CAST_BAR'],GwLocalization['ADV_CAST_BAR_DESC'],'CASTINGBAR_DATA','GwSettingsHudOptions')
	addOption(GwLocalization['BUTTON_ASSIGNMENTS'],GwLocalization['BUTTON_ASSIGNMENTS_DESC'],'BUTTON_ASSIGNMENTS','GwSettingsHudOptions')
	addOption(GwLocalization['MOUSE_TOOLTIP'],GwLocalization['MOUSE_TOOLTIP_DESC'],'TOOLTIP_MOUSE','GwSettingsHudOptions')
	addOption(GwLocalization['FADE_MICROMENU'],GwLocalization['FADE_MICROMENU_DESC'],'FADE_MICROMENU','GwSettingsHudOptions')
	
	addOptionDropdown(GwLocalization['MINIMAP_HOVER'],GwLocalization['MINIMAP_HOVER_TOOLTIP'],'MINIMAP_HOVER','GwSettingsHudOptions',function() gwSetMinimapHover() end,{'NONE','BOTH','CLOCK','ZONE'},{GwLocalization['MINIMAP_HOVER_1'],GwLocalization['MINIMAP_HOVER_2'],GwLocalization['MINIMAP_HOVER_3'],GwLocalization['MINIMAP_HOVER_4']})
    addOptionDropdown(GwLocalization['HUD_SCALE'],GwLocalization['HUD_SCALE_DESC'],'HUD_SCALE','GwSettingsHudOptions',function() gwUpdateHudScale() end,{1,0.9,0.8},{GwLocalization['HUD_SCALE_DEFAULT'],GwLocalization['HUD_SCALE_SMALL'],GwLocalization['HUD_SCALE_TINY']})
    addOptionDropdown(GwLocalization['MINIMAP_SCALE'],GwLocalization['MINIMAP_SCALE_DESC'],'MINIMAP_SCALE','GwSettingsHudOptions',function() Minimap:SetSize(gwGetSetting('MINIMAP_SCALE'),gwGetSetting('MINIMAP_SCALE')) end,{250,200,170},{GwLocalization['MINIMAP_SCALE_LARGE'],GwLocalization['MINIMAP_SCALE_MEDIUM'],GwLocalization['MINIMAP_SCALE_DEFAULT']})
    addOptionDropdown(GwLocalization['STG_RIGHT_BAR_COLS'], GwLocalization['STG_RIGHT_BAR_COLS_DESC'], 'MULTIBAR_RIGHT_COLS', 'GwSettingsHudOptions', function() gwSetMultibarCols() end, {1, 2, 3, 4, 6, 12}, {'1', '2', '3', '4', '6', '12'})
    
    create_settings_cat(GwLocalization['GROUP_CAT'],GwLocalization['GROUP_TOOLTIP'],'GwSettingsGroupframe',4)
    
    addOption(GwLocalization['RAID_PARTY_STYLE'],GwLocalization['RAID_PARTY_STYLE_DESC'],'RAID_STYLE_PARTY','GwSettingsGroupframe')
    addOption(GwLocalization['CLASS_COLOR_RAID'],GwLocalization['CLASS_COLOR_RAID_DESC'],'RAID_CLASS_COLOR','GwSettingsGroupframe')
    addOption(GwLocalization['POWER_BARS_RAID'],GwLocalization['POWER_BARS_RAID_DESC'],'RAID_POWER_BARS','GwSettingsGroupframe')
    addOption(GwLocalization['DEBUFF_DISPELL'],GwLocalization['DEBUFF_DISPELL_DESC'],'RAID_ONLY_DISPELL_DEBUFFS','GwSettingsGroupframe')
	addOption(GwLocalization['RAID_MARKER'],GwLocalization['RAID_MARKER_DESC'],'RAID_UNIT_MARKERS','GwSettingsGroupframe')
	
	addOptionDropdown(GwLocalization['RAID_UNIT_FLAGS'],GwLocalization['RAID_UNIT_FLAGS_TOOLTIP'],'RAID_UNIT_FLAGS','GwSettingsGroupframe',function() end,{'NONE','DIFFERENT','ALL'},{GwLocalization['RAID_UNIT_FLAGS_1'],GwLocalization['RAID_UNIT_FLAGS_2'],GwLocalization['RAID_UNIT_FLAGS_3']})
  
    addOptionSlider(GwLocalization['RAID_CONT_HEIGHT'],GwLocalization['RAID_CONT_HEIGHT_DESC'],'RAID_UNITS_PER_COLUMN','GwSettingsGroupframe',function()
            if gwGetSetting('GROUP_FRAMES')==true then
                GwRaidFrameContainer:SetHeight((gwGetSetting('RAID_HEIGHT') + 2) * gwGetSetting('RAID_UNITS_PER_COLUMN'))
                GwRaidFrameContainerFrameMoveAble:SetHeight((gwGetSetting('RAID_HEIGHT') + 2) * gwGetSetting('RAID_UNITS_PER_COLUMN'))
                gw_raidframes_update_layout()   
                gw_raidframes_updateMoveablePosition()
                
            end    
    end,1,80)
    
    addOptionSlider(GwLocalization['RAID_BAR_WIDTH'],GwLocalization['RAID_BAR_WIDTH_DESC'],'RAID_WIDTH','GwSettingsGroupframe',function()
            if gwGetSetting('GROUP_FRAMES')==true then
                gw_raidframes_update_layout() 
                gw_raidframes_updateMoveablePosition()
            end
    end,55,200)
    addOptionSlider(GwLocalization['RAID_BAR_HEIGHT'],GwLocalization['RAID_BAR_HEIGHT_DESC'],'RAID_HEIGHT','GwSettingsGroupframe',function()
            if gwGetSetting('GROUP_FRAMES')==true then
                gw_raidframes_update_layout()   
                gw_raidframes_updateMoveablePosition()
            end    
    end,47,100)
    
    create_settings_cat(GwLocalization['PROFILES_CAT'],GwLocalization['PROFILES_TOOLTIP'],'GwSettingsProfilesframe',5)
    _G['GwSettingsLabel4'].iconbg:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\settingsiconbg-2.tga')
 
    
    switch_settings_cat(0)
     GwSettingsWindow:Hide()
   

     
    GwSettingsProfilesframe.slider:SetValue(0)
   
    GwSettingsProfilesframe.slider.thumb:SetHeight(200)
    
    
    local resetTodefault = CreateFrame('Button','GwProfileItemDefault',GwSettingsProfilesframe.scrollchild,'GwProfileItem')
    resetTodefault.icon:SetTexture('Interface\\icons\\inv_corgi2')

    resetTodefault.deleteable = false 
    resetTodefault.background:SetTexCoord(0,1,0,0.5)
    resetTodefault.activateAble = true
    
    resetTodefault:SetPoint('TOPLEFT',15,0)
    
    resetTodefault.name:SetText(GwLocalization['PROFILES_DEFAULT_SETTINGS'])
    resetTodefault.desc:SetText(GwLocalization['PROFILES_DEFAULT_SETTINGS_DESC'])
    resetTodefault.activateButton:SetScript('OnClick', function()
            
        gwWarningPromt(GwLocalization['PROFILES_DEFAULT_SETTINGS_PROMPT'],function()
            gwResetToDefault()
        end)
    end)
    resetTodefault.activateButton:SetText(GwLocalization['PROFILES_LOAD_BUTTON'])  
    
    CreateFrame('Button','GwCreateNewProfile',GwSettingsProfilesframe.scrollchild,'GwCreateNewProfile')
    
    GwCreateNewProfile:SetPoint('TOPLEFT',15,-80)
          
    gw_Update_Profile_Window()
end


function gw_Update_Profile_Window()
    
    
    local currentProfile = gwGetActiveProfile()
    

      
    local h = 0
    local profiles = gwGetSettingsProfiles()
    for i=0,6 do
        
        local k = i
        local v = profiles[i]
        local f = _G['GwProfileItem'..k]
        if f==nil then
            f = CreateFrame('Button','GwProfileItem'..k,GwSettingsProfilesframe.scrollchild,'GwProfileItem')
        end
        
        if v~=nil then
            f:Show() 
            f.profileID = k
            f.icon:SetTexture(GW_PROFILE_ICONS_PRESET[k])

            f.deleteable = true 
            f.background:SetTexCoord(0,1,0,0.5)
            f.activateAble = true
            if currentProfile==k then
                f.background:SetTexCoord(0,1,0.5,1)
                f.activateAble = false
            end

            local description = GwLocalization['PROFILES_CREATED']..v['profileCreatedDate']..GwLocalization['PROFILES_CREATED_BY']..v['profileCreatedCharacter']..GwLocalization['PROFILES_LAST_UPDATE']..v['profileLastUpdated']

            f.name:SetText(v['profilename'])
            f.desc:SetText(description)
            f:SetPoint('TOPLEFT',15, (-70*h) + -120)
            h=h+1
        else
           f:Hide() 
        end
    end
   
    if h<6 then
        GwCreateNewProfile:Enable() 
    else
        GwCreateNewProfile:Disable() 
    end
    
    local scrollM =  (120 + (70*h))
    local scroll = 0
    local thumbheight = 1
    
    if scrollM>440 then
        scroll =  math.abs(440 - scrollM)
        thumbheight = 100        
    end
   

    GwSettingsProfilesframe.scrollFrame:SetScrollChild(GwSettingsProfilesframe.scrollchild)
    GwSettingsProfilesframe.scrollFrame.maxScroll = scroll

    GwSettingsProfilesframe.slider.thumb:SetHeight(thumbheight)
    GwSettingsProfilesframe.slider:SetMinMaxValues(0,scroll)
end


function gw_Add_Settings_Profile(name)
 
    local index = 0
    local profileList = gwGetSettingsProfiles()
    
    for i=0,7 do
        index = i
        if profileList[i]==nil then
            break
        end
       
    end
    
    if index>6 then return end
    
    GW2UI_SETTINGS_PROFILES[index] = {}
    GW2UI_SETTINGS_PROFILES[index]['profilename'] = name
    GW2UI_SETTINGS_PROFILES[index]['profileCreatedDate'] = date("%m/%d/%y %H:%M:%S")
    GW2UI_SETTINGS_PROFILES[index]['profileCreatedCharacter'] = GetUnitName('player', true)
    GW2UI_SETTINGS_PROFILES[index]['profileLastUpdated'] = date("%m/%d/%y %H:%M:%S")
    
    GW2UI_SETTINGS_DB_03['ACTIVE_PROFILE'] = index
    gwSetProfileSettings()
    gw_Update_Profile_Window()
    
end

function gw_Delete_Settings_Profile(index)
   
    GW2UI_SETTINGS_PROFILES[index]=nil
    if GW2UI_SETTINGS_DB_03['ACTIVE_PROFILE']~=nil and GW2UI_SETTINGS_DB_03['ACTIVE_PROFILE']==index then    gwSetSetting('ACTIVE_PROFILE',nil)
    end
    
    
end

function gw_Set_Active_Profile(index)

    GW2UI_SETTINGS_DB_03['ACTIVE_PROFILE'] = index
    ReloadUI()
    
end



function create_settings_cat(name,desc,frameName,icon)
    
    local i = GW.countTable(settings_cat)
    settings_cat[i] = frameName

    local f = CreateFrame('Button','GwSettingsLabel'..i,UIParent,'GwSettingsLabel')
    f:SetPoint('TOPLEFT',-40,-32+(-40*i))
    
    
    _G['GwSettingsLabel'..i..'Texture']:SetTexCoord(0,0.5,0.25*icon,0.25*(icon+1))
    if icon>3 then
        icon = icon - 4
        _G['GwSettingsLabel'..i..'Texture']:SetTexCoord(0.5,1,0.25*icon,0.25*(icon+1))
    end
    
    f:SetScript('OnEnter',function() 
        GameTooltip:SetOwner(f, "ANCHOR_LEFT",0,-40); GameTooltip:ClearLines();  GameTooltip:AddLine(name,1,1,1)  GameTooltip:AddLine(desc,1,1,1) GameTooltip:Show()     
    end)
    f:SetScript('OnLeave',function() 
        GameTooltip:Hide()  
    end)

    
    f:SetScript('OnClick',function(event) 
         switch_settings_cat(i)    
    end)
    
end

function switch_settings_cat(index)
    
    for i=0,20 do
        if _G['GwSettingsLabel'..i]~=nil then
            _G['GwSettingsLabel'..i].iconbg:Hide()
        end
    end
    
    _G['GwSettingsLabel'..index].iconbg:Show()
    

    
    
    
    for k,v in pairs(settings_cat) do 
        if k~=index then
            _G[v]:Hide()
            
        else
            _G[v]:Show()
            UIFrameFadeIn(_G[v], 0.2,0,1)
        end
    end
   
    
end


function addOption(name,desc,optionName,frameName,callback)
    
    local i = GW.countTable(options)

    options[i] = {}
    options[i]['name'] = name;
    options[i]['desc'] = desc;
    options[i]['optionName'] = optionName;
    options[i]['frameName'] = frameName;
    options[i]['optionType'] = 'boolean';
    options[i]['callback'] = callback;
    
end
function addOptionSlider(name,desc,optionName,frameName,callback,min,max)
    
    local i = GW.countTable(options)

    options[i] = {}
    options[i]['name'] = name;
    options[i]['desc'] = desc;
    options[i]['optionName'] = optionName;
    options[i]['frameName'] = frameName;
    options[i]['callback'] = callback;
    options[i]['min'] = min;
    options[i]['max'] = max;
    options[i]['optionType'] = 'slider';
    
end
function addOptionDropdown(name,desc,optionName,frameName,callback,options_list,option_names)
    
    local i = GW.countTable(options)

    options[i] = {}
    options[i]['name'] = name;
    options[i]['desc'] = desc;
    options[i]['optionName'] = optionName;
    options[i]['frameName'] = frameName;
    options[i]['callback'] = callback;

    options[i]['optionType'] = 'dropdown';
    options[i]['options'] ={}
    options[i]['options'] = options_list;
    options[i]['options_names'] = {};
    options[i]['options_names'] = option_names;

    
end

function display_options()
    local box_padding = 8
    local pX = 244
    local pY = -48
    
    local padding = {}
    
    for k,v in pairs(options) do 
        local newLine =false
        if padding[v['frameName']]==nil then
            padding[v['frameName']] = {}
            padding[v['frameName']]['x']=  box_padding
            padding[v['frameName']]['y']=-55
        end
        optionFrameType ='GwOptionBox'
        if v['optionType']=='slider' then
           optionFrameType = 'GwOptionBoxSlider' 
              newLine = true
        end 
        if v['optionType']=='dropdown' then
          
           optionFrameType = 'GwOptionBoxDropDown'
            newLine = true
            
        end

        local of =  CreateFrame('Button','GwOptionBox'..k,_G[v['frameName']],optionFrameType)
        
        of:ClearAllPoints()
        if of:GetWidth()>300 then

            padding[v['frameName']]['y'] = padding[v['frameName']]['y'] + pY + box_padding
            padding[v['frameName']]['x'] = box_padding
     
        end
        of:SetPoint('TOPLEFT',padding[v['frameName']]['x'],padding[v['frameName']]['y'])
        _G['GwOptionBox'..k..'Title']:SetText(v['name'])
        _G['GwOptionBox'..k..'Title']:SetFont(DAMAGE_TEXT_FONT,12)
        _G['GwOptionBox'..k..'Title']:SetTextColor(1,1,1)
        _G['GwOptionBox'..k..'Title']:SetShadowColor(0,0,0,1)
        
     
        of:SetScript('OnEnter',function() 
                
                GameTooltip:SetOwner(of, "ANCHOR_CURSOR",0,0); 
                GameTooltip:ClearLines();
                GameTooltip:AddLine(v['name'],1,1,1)
                GameTooltip:AddLine(v['desc'],1,1,1)
                GameTooltip:Show()    
                
           
        end)
        of:SetScript('OnLeave',function()GameTooltip:Hide()  end)


        
        if v['optionType']=='dropdown' then
            local i = 1
            local pre = _G['GwOptionBox'..k].container
            for key,val in pairs(v['options']) do
                local dd = CreateFrame('Button','GwOptionBox'..'dropdown'..i,_G[v['frameName']].container,'GwDropDownItem')
                dd:SetPoint('TOPRIGHT',pre,'BOTTOMRIGHT')
                dd:SetParent(_G['GwOptionBox'..k].container)
                
                dd.string:SetFont(UNIT_NAME_FONT,12)
                 _G['GwOptionBox'..k].button.string:SetFont(UNIT_NAME_FONT,12)
                dd.string:SetText(v['options_names'][key])
                pre = dd
                
                
                if gwGetSetting(v['optionName'])==val then
                    _G['GwOptionBox'..k].button.string:SetText(v['options_names'][key])
                end
                
                dd:SetScript('OnClick', function()
        
                    _G['GwOptionBox'..k].button.string:SetText(v['options_names'][key])
                        
                   if  _G['GwOptionBox'..k].container:IsShown() then
                        _G['GwOptionBox'..k].container:Hide() 
                    else
                    _G['GwOptionBox'..k].container:Show()
                    end 
                        
                    gwSetSetting(v['optionName'] ,val)
                    
                    if v['callback']~=nil then
                        v['callback']()         
                    end
                    
                end)
              
                i = i + 1
            end
            _G['GwOptionBox'..k].button:SetScript('OnClick', function()  if  _G['GwOptionBox'..k].container:IsShown() then _G['GwOptionBox'..k].container:Hide() else _G['GwOptionBox'..k].container:Show() end end)
        end
        
        if v['optionType']=='slider' then
             _G['GwOptionBox'..k..'Slider']:SetMinMaxValues(v['min'],v['max'])            
             _G['GwOptionBox'..k..'Slider']:SetValue(gwGetSetting(v['optionName']))            
             _G['GwOptionBox'..k..'Slider']:SetScript('OnValueChanged',function()
                 
                gwSetSetting(v['optionName'],_G['GwOptionBox'..k..'Slider']:GetValue())
                if v['callback']~=nil then
                    v['callback']()         
                          
                end
            end)       
        end
        if v['optionType']=='boolean' then
        _G['GwOptionBox'..k..'CheckButton']:SetChecked(gwGetSetting(v['optionName']))
        _G['GwOptionBox'..k..'CheckButton']:SetScript('OnClick',function()
            
            toSet = false
            if _G['GwOptionBox'..k..'CheckButton']:GetChecked() then
                toSet = true
            end
            gwSetSetting(v['optionName'],toSet)
                    
            if v['callback']~=nil then
               v['callback']()         
            end
        
            end)
        end
        
        

        if newLine==false then
            padding[v['frameName']]['x'] = padding[v['frameName']]['x'] + of:GetWidth() + box_padding
            if padding[v['frameName']]['x']>440 then
                padding[v['frameName']]['y'] = padding[v['frameName']]['y'] + pY + box_padding
                padding[v['frameName']]['x'] = box_padding
            end
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
    
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(GwLocalization['HUD_MOVE_ERR'])
        return
    end 
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
    ReloadUI()
end


function gwWarningPromt(text,method)
    
    GwWarningPromt.string:SetText(text)
    GwWarningPromt.method = method
    GwWarningPromt:Show()
    GwWarningPromt.input:Hide()
end

function gwInputPromtPromt(text,method)
    
    GwWarningPromt.string:SetText(text)
    GwWarningPromt.method = method
    GwWarningPromt:Show()
    GwWarningPromt.input:Show()
    GwWarningPromt.input:SetText('')
end
