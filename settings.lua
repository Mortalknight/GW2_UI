
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
    addOption('Casting Bar', 'Use the GW2 casting bar','CASTINGBAR_ENABLED','GwSettingsModuleOption')
    addOption('Class Power', 'Display class powers','CLASS_POWER','GwSettingsModuleOption')
    addOption('Group', 'Raid and party','GROUP_FRAMES','GwSettingsModuleOption')
    
    create_settings_cat('TARGET','Edit the target frame settings','GwSettingsTargetOptions',1)
    
    addOption('Target of Target','Display the target\'s target','target_TARGET_ENABLED','GwSettingsTargetOptions')
    addOption('Health Value','Display health information','target_HEALTH_VALUE_ENABLED','GwSettingsTargetOptions')
    addOption('Health Percentage','Display health info as a percentage','target_HEALTH_VALUE_TYPE','GwSettingsTargetOptions')
    addOption('Show Debuffs','Display the target\'s debuffs','target_DEBUFFS','GwSettingsTargetOptions')
    addOption('Show All debuffs','Display all target\'s buffs','target_BUFFS_FILTER_ALL','GwSettingsTargetOptions')
    addOption('Show Buffs','Display the target\'s buffs','target_BUFFS','GwSettingsTargetOptions')

    
    
    create_settings_cat('FOCUS','Edit focus frame settings','GwSettingsFocusOptions',2)
    
    addOption('Focus Target','Display the focus target','focus_TARGET_ENABLED','GwSettingsFocusOptions')
    addOption('Health Value','Display health information','focus_HEALTH_VALUE_ENABLED','GwSettingsFocusOptions')
    addOption('Health Percentage','Display health info as a percentage','focus_HEALTH_VALUE_TYPE','GwSettingsFocusOptions')
    addOption('Show Debuffs','Display the focus target\'s debuffs','focus_DEBUFFS','GwSettingsFocusOptions')
    addOption('Show All debuffs','Display all focus target\'s buffs','focus_BUFFS_FILTER_ALL','GwSettingsFocusOptions')
    addOption('Show Buffs','Display the focus target\'s buffs','focus_BUFFS','GwSettingsFocusOptions')
   
   
    create_settings_cat('HUD','Edit HUD settings','GwSettingsHudOptions',3)
    addOption('Fade Actionbars','Fade the extra action bars','FADE_BOTTOM_ACTIONBAR','GwSettingsHudOptions')
    addOption('Dynamic HUD','Change the HUD appearance','HUD_SPELL_SWAP','GwSettingsHudOptions')
    addOption('Fade Chat','Fade the chat while inactive','CHATFRAME_FADE','GwSettingsHudOptions')
    addOption('Hide Empty Slots','Hide empty action bar slots','HIDEACTIONBAR_BACKGROUND_ENABLED','GwSettingsHudOptions')
    addOption('Toggle Compass','Toggle the quest tracker compass','SHOW_QUESTTRACKER_COMPASS','GwSettingsHudOptions')
    addOption('Advanced Casting Bar','Display name and icon of spell cast','CASTINGBAR_DATA','GwSettingsHudOptions')
    addOptionDropdown('Hud Scale','Change the size of the HUD','HUD_SCALE','GwSettingsHudOptions',function() gwUpdateHudScale() end,{1,0.9,0.8},{'Normal','Small','Tiny'})
    addOptionDropdown('Minimap Scale','Change the size of the Minimap','MINIMAP_SCALE','GwSettingsHudOptions',function() Minimap:SetSize(gwGetSetting('MINIMAP_SCALE'),gwGetSetting('MINIMAP_SCALE')) end,{250,200,140},{'Large','Medium','Normal'})
    
    create_settings_cat('Group','Edit group settings','GwSettingsGroupframe',4)
    
    addOption('Raid Styled Party','Use raid-style party frames','RAID_STYLE_PARTY','GwSettingsGroupframe')
    
    addOption('Class Color','Use class color insted of class icons','RAID_CLASS_COLOR','GwSettingsGroupframe')
    addOption('Power Bars','Display power bars','RAID_POWER_BARS','GwSettingsGroupframe')
    addOption('Show Only Dispelable Debuffs','Only displays debuffs that you can dispell','RAID_ONLY_DISPELL_DEBUFFS','GwSettingsGroupframe')
  
    addOptionSlider('Raid Container Height','','RAID_UNITS_PER_COLUMN','GwSettingsGroupframe',function()
            if gwGetSetting('GROUP_FRAMES')==true then
                GwRaidFrameContainer:SetHeight((gwGetSetting('RAID_HEIGHT') + 2) * gwGetSetting('RAID_UNITS_PER_COLUMN'))
                GwRaidFrameContainerFrameMoveAble:SetHeight((gwGetSetting('RAID_HEIGHT') + 2) * gwGetSetting('RAID_UNITS_PER_COLUMN'))
                gw_raidframes_update_layout()   
                gw_raidframes_updateMoveablePosition()
                
            end    
    end,1,80)
    
    addOptionSlider('Raid Width','','RAID_WIDTH','GwSettingsGroupframe',function()
            if gwGetSetting('GROUP_FRAMES')==true then
                gw_raidframes_update_layout() 
                gw_raidframes_updateMoveablePosition()
            end
    end,55,200)
    addOptionSlider('Raid Height','','RAID_HEIGHT','GwSettingsGroupframe',function()
            if gwGetSetting('GROUP_FRAMES')==true then
                gw_raidframes_update_layout()   
                gw_raidframes_updateMoveablePosition()
            end    
    end,47,100)
    
    create_settings_cat('Profiles','Edit profiles','GwSettingsProfilesframe',5)
    _G['GwSettingsLabel5'].iconbg:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\settingsiconbg-2.tga')
 
    
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
    
    resetTodefault.name:SetText('Default Settings')
    resetTodefault.desc:SetText('Load the default addon settings to your current profile')
    resetTodefault.activateButton:SetScript('OnClick', function()
            
        gwWarningPromt('Are you sure you want to load the default settings?\n\nAll previous settings will be lost.',function()
            gwResetToDefault()
        end)
    end)
    resetTodefault.activateButton:SetText('Load')  
    
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

            local description = 'Created: '..v['profileCreatedDate']..'\nCreated by: '..v['profileCreatedCharacter']..'\nLast updated: '..v['profileLastUpdated']

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
    
    local i = countTable(settings_cat)
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
    
    local i = countTable(options)

    options[i] = {}
    options[i]['name'] = name;
    options[i]['desc'] = desc;
    options[i]['optionName'] = optionName;
    options[i]['frameName'] = frameName;
    options[i]['optionType'] = 'boolean';
    options[i]['callback'] = callback;
    
end
function addOptionSlider(name,desc,optionName,frameName,callback,min,max)
    
    local i = countTable(options)

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
    
    local i = countTable(options)

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
        DEFAULT_CHAT_FRAME:AddMessage('You can not move elements during combat!')
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
