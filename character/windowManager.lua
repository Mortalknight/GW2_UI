local windowsList = {};



windowsList[0] = {}
    windowsList[0]['ONLOAD'] = gw_register_character_window;
    windowsList[0]['SETTING_NAME'] ='USE_CHARACTER_WINDOW';
    windowsList[0]['TAB_ICON'] ='tabicon_character';

local tabIndex = 0;




local function createTabIcon(iconName) 

   local f = CreateFrame('Button','CharacterWindowTab'..tabIndex,GwCharacterWindow,'CharacterWindowTabSelect')
    
    f.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\'..iconName);
    
    f:SetPoint('TOP',GwCharacterWindow,'TOPLEFT',-32,-30 + (tabIndex*40));
    
    tabIndex = tabIndex + 1;
end

function Gw_LoadWindows()
    
    for k,v in pairs(windowsList) do
        if gwGetSetting(v['SETTING_NAME']) then
            v['ONLOAD']();
            createTabIcon(v['TAB_ICON']);
        end
        
    end
    
end

