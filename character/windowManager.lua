local windowsList = {};
hasBeenLoaded = false



windowsList[0] = {}
    windowsList[0]['ONLOAD'] = gw_register_character_window;
    windowsList[0]['SETTING_NAME'] ='USE_CHARACTER_WINDOW';
    windowsList[0]['TAB_ICON'] ='tabicon_character';
    windowsList[0]['ONCLICK'] =function()  ToggleCharacter("PaperDollFrame");  end;

 --windowsList[1] = {}
--    windowsList[1]['ONLOAD'] = gw_register_spellbook_window;
  --  windowsList[1]['SETTING_NAME'] ='USE_SPELLBOOK_WINDOW';
--    windowsList[1]['TAB_ICON'] ='tabicon_character';
--    windowsList[1]['ONCLICK'] =function() ToggleSpellBook(BOOKTYPE_SPELL);  end;

local tabIndex = 0;


local function loadBaseFrame()
   
    if hasBeenLoaded then return end
    hasBeenLoaded = true
    
    CreateFrame('Frame','GwCharacterWindowMoverFrame',UIParent,'GwCharacterWindowMoverFrame')
    CreateFrame('Frame','GwCharacterWindow',UIParent,'GwCharacterWindow')
    
    tinsert(UISpecialFrames, "GwCharacterWindow") 
    GwCharacterWindow:HookScript('OnHide',function() GwCharacterWindowMoverFrame:Hide() end)
    GwCharacterWindow:HookScript('OnShow',function() GwCharacterWindowMoverFrame:Show() end)
    GwCharacterWindow:Hide()
    
    
end

local function createTabIcon(iconName) 

   local f = CreateFrame('Button','CharacterWindowTab'..tabIndex,GwCharacterWindow,'CharacterWindowTabSelect')
    
    f.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\'..iconName);
    
    f:SetPoint('TOP',GwCharacterWindow,'TOPLEFT',-32,-30 + -(tabIndex*40));
    
    tabIndex = tabIndex + 1;
    return f
end

function Gw_LoadWindows()
    loadBaseFrame()
    for k,v in pairs(windowsList) do
        if gwGetSetting(v['SETTING_NAME']) then
            v['ONLOAD']();
            local f  = createTabIcon(v['TAB_ICON'])
            f:SetScript('OnClick', v['ONCLICK'] );
            
        end
        
    end
    
end



