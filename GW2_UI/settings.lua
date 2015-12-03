local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1=="GW2_UI" then

        if GW2UI_SETTINGS_DB ==nil then
            GW2UI_SETTINGS_DB = {}
            GW2UI_SETTINGS_DB['FADE_BOTTOM_ACTIONBAR'] = true
            GW2UI_SETTINGS_DB['HIDE_CHATSHADOW'] = false
            GW2UI_SETTINGS_DB['HIDE_QUESTVIEW'] = false;
            GW2UI_SETTINGS_DB['USE_CHAT_BUBBLES'] = false;
            GW2UI_SETTINGS_DB['DISABLE_NAMEPLATES'] = false
            GW2UI_SETTINGS_DB['DISABLE_TOOLTIPS'] = false
        end
        GW2UI_SETTINGS['FADE_BOTTOM_ACTIONBAR'] = GW2UI_SETTINGS_DB['FADE_BOTTOM_ACTIONBAR']
        GW2UI_SETTINGS['HIDE_CHATSHADOW'] = GW2UI_SETTINGS_DB['HIDE_CHATSHADOW']
        GW2UI_SETTINGS['HIDE_QUESTVIEW'] = GW2UI_SETTINGS_DB['HIDE_QUESTVIEW']
        GW2UI_SETTINGS['USE_CHAT_BUBBLES'] = GW2UI_SETTINGS_DB['USE_CHAT_BUBBLES']
        GW2UI_SETTINGS['DISABLE_NAMEPLATES'] = GW2UI_SETTINGS_DB['DISABLE_NAMEPLATES'] 
        GW2UI_SETTINGS['DISABLE_TOOLTIPS'] = GW2UI_SETTINGS_DB['DISABLE_TOOLTIPS']
            
            
        GW2UI_SETTINGS['SETTINGS_LOADED'] = true
 
        createOptionWIndow() 
        createBoleanSetting(0,'Fade Actionbars','Hides the bottom actionbars while not in combat','FADE_BOTTOM_ACTIONBAR')
        createBoleanSetting(1,'Hide Chat Backdrop','Hides the shadow in the bottom left corner','HIDE_CHATSHADOW')
        createBoleanSetting(2,'Disable Quest Dialog','Use the default quest interface','HIDE_QUESTVIEW')
        createBoleanSetting(3,'Default Speech Bubbles','Use the default speech bubbles','USE_CHAT_BUBBLES')
        createBoleanSetting(4,'Default Nameplates','Use the default nameplates','DISABLE_NAMEPLATES')
        createBoleanSetting(5,'Default Tooltips','Use the default tooltips','DISABLE_TOOLTIPS')
           
        createOptionGameMenuButton()
                    
            
    
    if GW2UI_SETTINGS['HIDE_CHATSHADOW'] then
        chatShadowBg:SetAlpha(0)
    end        
       
    if GW2UI_SETTINGS['HIDE_QUESTVIEW'] then
        questViewBg:UnregisterAllEvents();
    end
    elseif event == "PLAYER_LOGOUT" then
         
    end
end)

function createOptionWIndow()

    settingsViewBg, settingsViewTexture = createWindowName('CENTER',512,512,0,0,"Interface\\AddOns\\GW2_UI\\textures\\settingsbg",1,'GW2UI_SETTINGSWINDOW')
    settingsViewBg:Hide()
    
    settingsViewBg:SetScript('OnShow',function(self) PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg",'SFX') end)
     settingsViewBg:SetScript('OnHide',function(self) PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_close.ogg",'SFX') end)

    
    settingsCloseButtonBg, settingsCloseButtonTextiure = createButton('TOPRIGHT',20,20,0,0,"Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal",4)
    settingsCloseButtonBg:SetParent(settingsViewBg)

    settingsCloseButtonBg:SetPoint('TOPRIGHT',settingsViewBg,'TOPRIGHT',-6,-6)
    settingsCloseButtonBg:SetFrameLevel(5)
    settingsCloseButtonBg:SetFrameStrata("DIALOG")
    settingsCloseButtonBg:SetScript("OnEnter", function(self,event,addon)

         settingsCloseButtonTextiure:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover");
    end)
    settingsCloseButtonBg:SetScript("OnLeave", function(self,event,addon)
          settingsCloseButtonTextiure:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal");
    end)
    settingsCloseButtonBg:SetScript("OnClick", function(self,event,addon)
          GW2UI_SETTINGSWINDOW:Hide()
    end)
    
    local settingsPageTextTitle = unitBGf:CreateFontString('settingsPageTextTitle', "OVERLAY", "GameFontNormal")
    settingsPageTextTitle:SetParent(settingsViewBg)
    settingsPageTextTitle:SetTextColor(255/255,241/255,209/255)
    settingsPageTextTitle:SetFont(DAMAGE_TEXT_FONT,50)
    settingsPageTextTitle:SetText("Settings")
    settingsPageTextTitle:SetWidth(128)
    settingsPageTextTitle:SetShadowColor(14/255,0/255,0/255);
    settingsPageTextTitle:SetPoint('TOPLEFT',settingsViewBg,'TOPLEFT',-20,10)
    
    saveAndReloadBg, saveAndReloadTexture = createButton('BOTTOM',150,30,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbutton",4)
    saveAndReloadBg:SetParent(settingsViewBg)
    saveAndReloadBg:SetWidth(128)
    saveAndReloadBg:SetHeight(32);
    saveAndReloadBg:SetPoint('BOTTOMLEFT',settingsViewBg,'BOTTOMLEFT',0,-36)
    saveAndReloadBg:SetFrameLevel(5)
    saveAndReloadBg:SetFrameStrata("DIALOG")

    saveAndReloadBg:SetScript("OnEnter", function(self,event,addon)

         saveAndReloadTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton_hover");
    end)
    saveAndReloadBg:SetScript("OnLeave", function(self,event,addon)
          saveAndReloadTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton");
    end)
    saveAndReloadBg:SetScript("OnClick", function(self,event,addon)
         ReloadUI()
    end)

    local saveAndReloadString = unitBGf:CreateFontString('saveAndReloadString', "OVERLAY", "GameFontNormal")
    saveAndReloadString:SetParent(saveAndReloadBg)
    saveAndReloadString:SetTextColor(30/255,30/255,30/255)
    saveAndReloadString:SetFont(STANDARD_TEXT_FONT,14)
    saveAndReloadString:SetPoint("CENTER")
    saveAndReloadString:SetText("Save & Reload")
    saveAndReloadString:SetWidth(128)
    questAcceptButton:SetHeight(32);
    saveAndReloadString:SetShadowColor(118/255,118/255,118/255);
    saveAndReloadString:SetPoint('CENTER',saveAndReloadBg,'CENTER',0,0)

    
    tinsert(UISpecialFrames, "GW2UI_SETTINGSWINDOW") 
    

    SLASH_GWSLASH1 = "/gw2";
    function SlashCmdList.GWSLASH(msg)
        GW2UI_SETTINGSWINDOW:Show()
        UIFrameFadeIn(GW2UI_SETTINGSWINDOW, 0.2,0,1)
    end
    
end

function createOptionGameMenuButton()
    
    gameOptionMenuButton, gameOptionMenuButtonTexture = createButton('BOTTOM',150,30,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbutton",4)
    gameOptionMenuButton:SetParent(GameMenuFrame)
    gameOptionMenuButton:SetWidth(128)
    gameOptionMenuButton:SetHeight(32);
    gameOptionMenuButton:SetPoint('BOTTOM',GameMenuFrame,'BOTTOM',0,-36)
    gameOptionMenuButton:SetFrameLevel(5)
    gameOptionMenuButton:SetFrameStrata("DIALOG")
    
    local gameOptionMenuButtonString = unitBGf:CreateFontString('gameOptionMenuButtonString', "OVERLAY", "GameFontNormal")
    gameOptionMenuButtonString:SetParent(gameOptionMenuButton)
    gameOptionMenuButtonString:SetTextColor(30/255,30/255,30/255)
    gameOptionMenuButtonString:SetFont(STANDARD_TEXT_FONT,14)
    gameOptionMenuButtonString:SetPoint("CENTER")
    gameOptionMenuButtonString:SetText("GW2 UI Options")
    gameOptionMenuButtonString:SetWidth(128)

    gameOptionMenuButtonString:SetShadowColor(118/255,118/255,118/255);
    gameOptionMenuButtonString:SetPoint('CENTER',gameOptionMenuButton,'CENTER',0,0)
    
    gameOptionMenuButton:SetScript("OnEnter", function(self,event,addon)

         gameOptionMenuButtonTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton_hover");
    end)
    
    gameOptionMenuButton:SetScript("OnLeave", function(self,event,addon)
          gameOptionMenuButtonTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton");
    end)
    
     gameOptionMenuButton:SetScript("OnClick", function(self,event,addon)
            ToggleGameMenu()
            GW2UI_SETTINGSWINDOW:Show()
            UIFrameFadeIn(GW2UI_SETTINGSWINDOW, 0.2,0,1)
    end)
    
end


function createBoleanSetting(i,Title,description,settingString)
    
    y = 32 + (50 * i)
    
    _G['settingsOptionBg'..i], _G['settingsOptionBgTexture'..i] = createButton('CENTER',512,50,0,0,"Interface\\AddOns\\GW2_UI\\textures\\settingsbg",1)
    _G['settingsOptionBg'..i]:SetParent(settingsViewBg);
    _G['settingsOptionBg'..i]:SetPoint('TOPLEFT',settingsViewBg,'TOPLEFT',0,-y)
     _G['settingsOptionBgTexture'..i]:SetBlendMode('ADD')
    _G['settingsOptionBgTexture'..i]:SetVertexColor(1, 1, 1, 0.2) 
    
    _G['settingsOptionTitle'..i] = unitBGf:CreateFontString('settingsOptionTitle'..i, "OVERLAY", "GameFontNormal")
    _G['settingsOptionTitle'..i]:SetParent(_G['settingsOptionBg'..i])
    _G['settingsOptionTitle'..i]:SetTextColor(255/255,241/255,209/255)
    _G['settingsOptionTitle'..i]:SetFont(DAMAGE_TEXT_FONT,14)
    _G['settingsOptionTitle'..i]:SetText(Title)
    _G['settingsOptionTitle'..i]:SetWidth(400)
    _G['settingsOptionTitle'..i]:SetShadowColor(14/255,0/255,0/255);
    _G['settingsOptionTitle'..i]:SetPoint('TOPLEFT',_G['settingsOptionBg'..i],'TOPLEFT',10,-10)
    _G['settingsOptionTitle'..i]:SetJustifyH('LEFT')
    
    _G['settingsOptionDesc'..i] = unitBGf:CreateFontString('settingsOptionDesc'..i, "OVERLAY", "GameFontNormal")
    _G['settingsOptionDesc'..i]:SetParent(_G['settingsOptionBg'..i])
    _G['settingsOptionDesc'..i]:SetTextColor(181/255,160/255,128/255)
    _G['settingsOptionDesc'..i]:SetFont(STANDARD_TEXT_FONT,12)
    _G['settingsOptionDesc'..i]:SetText(description)
    _G['settingsOptionDesc'..i]:SetWidth(400)
    _G['settingsOptionDesc'..i]:SetShadowColor(14/255,0/255,0/255,0);
    _G['settingsOptionDesc'..i]:SetPoint('TOPLEFT',_G['settingsOptionBg'..i],'TOPLEFT',10,-29)
    _G['settingsOptionDesc'..i]:SetJustifyH('LEFT')
    
    
    
    _G['settingsOptionCheckBox'..i] = CreateFrame("CheckButton", "'settingsOptionCheckBox'..i", _G['settingsOptionBg'..i], "ChatConfigCheckButtonTemplate");
    _G['settingsOptionCheckBox'..i]:SetPoint('RIGHT',_G['settingsOptionBg'..i],'RIGHT',-10,0);
     _G['settingsOptionCheckBox'..i]:EnableMouse(false) 
     _G['settingsOptionCheckBox'..i]:SetChecked(GW2UI_SETTINGS_DB[settingString])
    
    _G['settingsOptionBg'..i]:SetScript('OnClick',function(event)
        toSet = true
            if _G['settingsOptionCheckBox'..i]:GetChecked() then
                toSet = false
            end
            
         _G['settingsOptionCheckBox'..i]:SetChecked(toSet)
        GW2UI_SETTINGS_DB[settingString] = toSet;
    end)
 
   
    
    _G['settingsOptionBg'..i]:SetScript('OnEnter',function(event)
        _G['settingsOptionBgTexture'..i]:SetVertexColor(1, 1, 1, 0.6) 
    end)
    _G['settingsOptionBg'..i]:SetScript('OnLeave',function(event)
        _G['settingsOptionBgTexture'..i]:SetVertexColor(1, 1, 1, 0.2) 
    end)
    
  --  SetShadowColor(shadowR, shadowG, shadowB, shadowAlpha) 
    
end

