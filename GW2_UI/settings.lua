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
            GW2UI_SETTINGS_DB['DISABLE_CHATFRAME'] = false
            GW2UI_SETTINGS_DB['CHATFRAME_FADE'] = true
                
            GW2UI_SETTINGS_DB['target_x_position'] = -100
            GW2UI_SETTINGS_DB['target_y_position'] = -100

            GW2UI_SETTINGS_DB['focus_x_position'] = -350
            GW2UI_SETTINGS_DB['focus_y_position'] = -100
                
            GW2UI_SETTINGS_DB['multibarleft_x_position'] = -300
            GW2UI_SETTINGS_DB['multibarleft_y_position'] = -0

            GW2UI_SETTINGS_DB['multibarright_x_position'] = -260
            GW2UI_SETTINGS_DB['multibarright_y_position'] = -0
                
            GW2UI_SETTINGS_DB['multibarleft_pos'] ={}
            GW2UI_SETTINGS_DB['multibarleft_pos']['point'] = 'RIGHT'
            GW2UI_SETTINGS_DB['multibarleft_pos']['relativePoint'] = 'RIGHT'
            GW2UI_SETTINGS_DB['multibarleft_pos']['xOfs'] = -300
            GW2UI_SETTINGS_DB['multibarleft_pos']['yOfs']= 0
                
            GW2UI_SETTINGS_DB['multibarright_pos'] ={}
            GW2UI_SETTINGS_DB['multibarright_pos']['point'] = 'RIGHT'
            GW2UI_SETTINGS_DB['multibarright_pos']['relativePoint'] = 'RIGHT'
            GW2UI_SETTINGS_DB['multibarright_pos']['xOfs'] = -260
            GW2UI_SETTINGS_DB['multibarright_pos']['yOfs']  = 0
                
            GW2UI_SETTINGS_DB['target_pos'] ={}
            GW2UI_SETTINGS_DB['target_pos']['point'] = 'TOP'
            GW2UI_SETTINGS_DB['target_pos']['relativePoint'] = 'TOP'
            GW2UI_SETTINGS_DB['target_pos']['xOfs'] =  0
            GW2UI_SETTINGS_DB['target_pos']['yOfs']  = -100

            GW2UI_SETTINGS_DB['focus_pos'] ={}
            GW2UI_SETTINGS_DB['focus_pos']['point'] = 'CENTER'
            GW2UI_SETTINGS_DB['focus_pos']['relativePoint'] = 'CENTER'
            GW2UI_SETTINGS_DB['focus_pos']['xOfs'] =  -350
            GW2UI_SETTINGS_DB['focus_pos']['yOfs']  = 0

                
        end
        
        for k,v in pairs(GW2UI_SETTINGS) do 
            if GW2UI_SETTINGS_DB[k]==nil then
                GW2UI_SETTINGS_DB[k] = GW2UI_SETTINGS[k]
            end
            GW2UI_SETTINGS[k] = GW2UI_SETTINGS_DB[k]
        end
            
        
                    
            
        GW2UI_SETTINGS['SETTINGS_LOADED'] = true
 
        createOptionWIndow() 
        createBoleanSetting(0,'Fade Actionbars','Hides the bottom actionbars while not in combat','FADE_BOTTOM_ACTIONBAR')
        createBoleanSetting(1,'Fade Chat Window','Hides the background of the chat window while not active','CHATFRAME_FADE')
        createBoleanSetting(2,'Disable Quest Dialog','Use the default quest interface','HIDE_QUESTVIEW')
        createBoleanSetting(3,'Default Speech Bubbles','Use the default speech bubbles','USE_CHAT_BUBBLES')
        createBoleanSetting(4,'Default Nameplates','Use the default nameplates','DISABLE_NAMEPLATES')
        createBoleanSetting(5,'Default Tooltips','Use the default tooltips','DISABLE_TOOLTIPS')
        createBoleanSetting(6,'Default Chatframe','Use the default chatframe','DISABLE_CHATFRAME')
           
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
    
    
    
    hudArangement, hudArangementTexture = createButton('BOTTOM',150,30,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbutton",4)
    hudArangement:ClearAllPoints()
    hudArangement:SetParent(settingsViewBg)
    hudArangement:SetWidth(128)
    hudArangement:SetHeight(32);
    hudArangement:SetPoint('BOTTOMRIGHT',settingsViewBg,'BOTTOMRIGHT',0,-36)
    hudArangement:SetFrameLevel(5)
    hudArangement:SetFrameStrata("DIALOG")
    
    local hudArangementString = unitBGf:CreateFontString('hudArangementString', "OVERLAY", "GameFontNormal")
    hudArangementString:SetParent(hudArangement)
    hudArangementString:SetTextColor(30/255,30/255,30/255)
    hudArangementString:SetFont(STANDARD_TEXT_FONT,14)
    hudArangementString:SetPoint("CENTER")
    hudArangementString:SetText("Rearrange Hud")
    hudArangementString:SetWidth(128)
    hudArangementString:SetShadowColor(118/255,118/255,118/255);
    hudArangementString:SetPoint('CENTER',hudArangement,'CENTER',0,0)
    
    
    hudArangementDisable, hudArangementDisableTexture = createButton('TOP',150,30,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbutton",4)
    hudArangementDisable:ClearAllPoints()
    hudArangementDisable:SetPoint('TOP',UIParent,'TOP',0,0)
    hudArangementDisable:SetWidth(128)
    hudArangementDisable:SetHeight(32);
    hudArangementDisable:SetFrameLevel(5)
    hudArangementDisable:SetFrameStrata("DIALOG")
    
    local hudArangementDisableString = hudArangementDisable:CreateFontString('hudArangementString', "OVERLAY", "GameFontNormal")
    hudArangementDisableString:SetParent(hudArangementDisable)
    hudArangementDisableString:SetTextColor(30/255,30/255,30/255)
    hudArangementDisableString:SetFont(STANDARD_TEXT_FONT,14)
    hudArangementDisableString:SetPoint("CENTER")
    hudArangementDisableString:SetText("Lock Hud")
    hudArangementDisableString:SetWidth(128)
    hudArangementDisableString:SetShadowColor(118/255,118/255,118/255);
    hudArangementDisableString:SetPoint('CENTER',hudArangementDisable,'CENTER',0,0)
    
    hudArangementDisable:Hide()
    
     hudArangementDisable:SetScript("OnEnter", function(self,event,addon)
         hudArangementDisableTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton_hover");
    end)
    hudArangementDisable:SetScript("OnLeave", function(self,event,addon)
          hudArangementDisableTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton");
    end)
    hudArangementDisable:SetScript("OnClick", function(self,event,addon)
        disableMoveHud()
    end)
    
    

    hudArangement:SetScript("OnEnter", function(self,event,addon)

         hudArangementTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton_hover");
    end)
    hudArangement:SetScript("OnLeave", function(self,event,addon)
          hudArangementTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton");
    end)
    hudArangement:SetScript("OnClick", function(self,event,addon)
        enableMoveHud()
        GW2UI_SETTINGSWINDOW:Hide()
        
    end)
    
    function enableMoveHud()
        _G['targetdrageAbleFrame']:Show()
        _G['targetdrageAbleFrame']:SetMovable(true)
        _G['targetdrageAbleFrame']:EnableMouse(true)
        
        _G['focusdrageAbleFrame']:Show()
        _G['focusdrageAbleFrame']:SetMovable(true)
        _G['focusdrageAbleFrame']:EnableMouse(true)
        
        _G['frameMultiBarLeftdrageAbleFrame']:Show()
        _G['frameMultiBarLeftdrageAbleFrame']:SetMovable(true)
        _G['frameMultiBarLeftdrageAbleFrame']:EnableMouse(true)

        _G['frameMultiBarRightdrageAbleFrame']:Show()
        _G['frameMultiBarRightdrageAbleFrame']:SetMovable(true)
        _G['frameMultiBarRightdrageAbleFrame']:EnableMouse(true)
        hudArangementDisable:Show()
    end
    function disableMoveHud()
        _G['targetdrageAbleFrame']:Hide()
        _G['targetdrageAbleFrame']:SetMovable(false)
        _G['targetdrageAbleFrame']:EnableMouse(false)
        
        _G['focusdrageAbleFrame']:Hide()
        _G['focusdrageAbleFrame']:SetMovable(false)
        _G['focusdrageAbleFrame']:EnableMouse(false)
        
        _G['frameMultiBarLeftdrageAbleFrame']:Hide()
        _G['frameMultiBarLeftdrageAbleFrame']:SetMovable(false)
        _G['frameMultiBarLeftdrageAbleFrame']:EnableMouse(false)

        _G['frameMultiBarRightdrageAbleFrame']:Hide()
        _G['frameMultiBarRightdrageAbleFrame']:SetMovable(false)
        _G['frameMultiBarRightdrageAbleFrame']:EnableMouse(false)
        
         hudArangementDisable:Hide()
    end

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

