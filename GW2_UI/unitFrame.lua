
function createUnitFrame(unitWatch,relativePoint)
    
    unitFrameHealthAnimation[unitWatch] = 0
    unitFrameHealthCandyAnimation[unitWatch] = 0
    unitFrameAbsorbAnimation[unitWatch] = 0
    unitFrameCastAnimation[unitWatch] = 0
    unitFrameTargetTargetAnimation[unitWatch] = 0
    
      addToAnimation(unitWatch..'CastingAnimation',unitFrameCastAnimation[unitWatch],0,GetTime(),0,nil)
    
    
    
    local dragAble = CreateFrame("frame",unitWatch..'drageAbleFrame',UIParent)
    dragAble:SetWidth(378)
    dragAble:SetHeight(83)
    dragAble.texture = dragAble:CreateTexture()
    dragAble.texture:SetAllPoints(dragAble)
    dragAble.texture:SetTexture(1,0,0,0.5)
    

    dragAble:SetPoint(GW2UI_SETTINGS[unitWatch..'_pos']['point'],GW2UI_SETTINGS[unitWatch..'_pos']['xOfs'],GW2UI_SETTINGS[unitWatch..'_pos']['yOfs'])
    dragAble:SetFrameStrata('HIGH');
    
    local dragableText = dragAble:CreateFontString(unitWatch..'dragableText', "OVERLAY", "GameFontNormal")
    dragableText:SetTextColor(255/255,197/255,39/255)
    dragableText:SetFont(DAMAGE_TEXT_FONT,24)
    dragableText:SetPoint("CENTER",dragAble,"CENTER",0,0)
    dragableText:SetText(unitWatch)
    dragableText:SetParent(dragAble)
    
    
   
    local b,t = createBackgroundName('TOP',512,128,0,0,"Interface\\AddOns\\GW2_UI\\textures\\targetshadow",0,unitWatch..'GwBackground')
    b:ClearAllPoints()
    b:SetPoint('CENTER',dragAble,'CENTER',-50,0)
    b:SetFrameStrata('LOW');
    
    
    local sB = CreateFrame("Button", unitWatch.."GwButton", b, "SecureUnitButtonTemplate");
    sB:SetPoint('CENTER',dragAble,'CENTER',50,0)
    sB:SetAttribute("unit", unitWatch);
    sB:SetFrameStrata('HIGH');
    sB:SetWidth(378)
    sB:SetHeight(83)
    sB:SetAttribute("*type1", "target")
    sB:SetAttribute("*type2", "showmenu")
    sB:SetAttribute("unit", unitWatch)
    RegisterUnitWatch(sB);

    sB:EnableMouse(true)
    
   
    
    local targetPortraitFrame = CreateFrame('Frame',nil,self)
    targetPortraitFrame:SetParent(b)
    targetPortraitFrame:SetPoint("TOPLEFT", b, "TOPLEFT", 133, -40)
    targetPortraitFrame:SetSize(59,59)

    local img1 = targetPortraitFrame:CreateTexture(nil, "BACKGROUND")
    img1:SetHeight(59)
    img1:SetWidth(59)
    img1:SetPoint("TOPLEFT", 0, 0)
    SetPortraitTexture(img1, "player")
    img1:SetBlendMode('ADD')
    
    
    local ib,it = createBackground('CENTER',65,65,0,0,"Interface\\AddOns\\GW2_UI\\textures\\targetPortraitinner",0)
    ib:ClearAllPoints()
    ib:SetParent(targetPortraitFrame)
    ib:SetPoint('CENTER',targetPortraitFrame,'CENTER',-1,1)    
    
    
   

   
    
    local barBG,barbgt = createBackground('TOPLEFT',255,17,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1)
    barBG:SetParent(b)
    barbgt:SetVertexColor(0,0,0,0.4);
    barBG:SetPoint("TOPLEFT",b,"TOPLEFT",195,-60)
    
     local tarLevel = b:CreateFontString(unitWatch..'LevelText', "OVERLAY", "GameFontNormal")
    tarLevel:SetTextColor(1,1,1)
    tarLevel:SetFont(UNIT_NAME_FONT,14)
    tarLevel:SetJustifyH('RIGHT')
    tarLevel:SetPoint("BOTTOMRIGHT",barBG,"TOPRIGHT",0,0)
    tarLevel:SetText("")
    
    local tarName = b:CreateFontString(unitWatch..'NameText', "OVERLAY", "GameFontNormal")
    tarName:SetTextColor(255/255,197/255,39/255)
    tarName:SetFont(UNIT_NAME_FONT,14)
    tarName:SetPoint("BOTTOMLEFT",barBG,"TOPLEFT",0,0)
    tarName:SetText("")
    
    
    
    local TTbarBG,TTbarbgt = createBackground('TOPLEFT',150,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1)
    TTbarBG:ClearAllPoints()
    TTbarBG:SetParent(b)
    TTbarbgt:SetVertexColor(0,0,0,0.4);
    TTbarBG:SetPoint("LEFT",barBG,"RIGHT",16,0)

    TTbarBG:Hide()
    
    local ttsB = CreateFrame("Button", unitWatch.."targetGwButton", TTbarBG, "SecureUnitButtonTemplate");
    ttsB:SetPoint('CENTER',TTbarBG,'CENTER',0,0)
    ttsB:SetFrameStrata('MEDIUM');
    ttsB:SetWidth(160)
    ttsB:SetHeight(26)
    ttsB:SetAttribute("*type1", "target")
    ttsB:SetAttribute("*type2", "showmenu")
    ttsB:SetAttribute("unit", unitWatch..'target')
    RegisterUnitWatch(ttsB);
    ttsB:RegisterForClicks('RightButtonUp', 'LeftButtonUp')
    ttsB:EnableMouse(true)


   
    
    local TTarrow,TTarrowt = createBackground('TOPLEFT',16,32,0,0,"Interface\\AddOns\\GW2_UI\\textures\\targetArrow",1)
    TTarrow:ClearAllPoints()
    TTarrow:SetParent(b)
    TTarrow:SetPoint("RIGHT",TTbarBG,"LEFT",0,0)
    TTarrow:SetAlpha(0)
    
    local TTtarName = TTbarBG:CreateFontString(unitWatch..'TTNameText', "OVERLAY", "GameFontNormal")
    TTtarName:SetTextColor(255/255,197/255,39/255)
    TTtarName:SetFont(UNIT_NAME_FONT,12)
    TTtarName:SetPoint("BOTTOMLEFT",TTbarBG,"TOPLEFT",0,0)
    TTtarName:SetText("")
    
    local TThealthBar = CreateFrame("StatusBar", nil, TTbarBG)
    TThealthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
    TThealthBar:GetStatusBarTexture():SetHorizTile(false)
    TThealthBar:SetWidth(146)
    TThealthBar:SetHeight(12)
    TThealthBar:SetMinMaxValues(0, 1)
    TThealthBar:SetValue(1)
    TThealthBar:SetPoint("LEFT",TTbarBG,"LEFT",2,0)
  --  TThealthBar:SetStatusBarColor(0.6,0.1,0.1)
    
    
    local healthBar2 = CreateFrame("StatusBar", nil, b)
    healthBar2:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy")
    healthBar2:GetStatusBarTexture():SetHorizTile(false)
    healthBar2:SetWidth(253)
    healthBar2:SetHeight(15)
    healthBar2:SetMinMaxValues(0, 1)
    healthBar2:SetValue(1)
    healthBar2:SetPoint("LEFT",barBG,"LEFT",1,0)
    healthBar2:SetStatusBarColor(0.6,0.1,0.1,1)
    healthBar2:SetFrameLevel(1)
    
    local healthBar = CreateFrame("StatusBar", nil, b)
    healthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
    healthBar:GetStatusBarTexture():SetHorizTile(false)
    healthBar:SetWidth(253)
    healthBar:SetHeight(15)
    healthBar:SetMinMaxValues(0, 1)
    healthBar:SetValue(1)
    healthBar:SetPoint("LEFT",barBG,"LEFT",1,0)
  --  healthBar:SetStatusBarColor(0.6,0.1,0.1)
     healthBar:SetFrameLevel(2)
    
    local absorbBar = CreateFrame("StatusBar", nil, b)
    absorbBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy")
    absorbBar:GetStatusBarTexture():SetHorizTile(false)
    absorbBar:SetMinMaxValues(0, 1)
    absorbBar:SetValue(0)
    absorbBar:SetWidth(270)
    absorbBar:SetHeight(12)
    absorbBar:SetPoint("LEFT",barBG,"LEFT",2,0)
    absorbBar:SetStatusBarColor(0.9,0.9,0.6,0.6)
    absorbBar:SetFrameLevel(3)
    
    
    local powerbar = CreateFrame("StatusBar", nil, b)
    powerbar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
    powerbar:GetStatusBarTexture():SetHorizTile(false)
    powerbar:SetMinMaxValues(0, 1)
    powerbar:SetValue(0)
    powerbar:SetWidth(253)
    powerbar:SetHeight(3)
    powerbar:SetPoint("BOTTOMLEFT",barBG,"BOTTOMLEFT",1,-5)
    powerbar:SetStatusBarColor(1,0.7,0.3)

    local castBar = CreateFrame("StatusBar", nil, healthBar)
    castBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
    castBar:GetStatusBarTexture():SetHorizTile(false)
    castBar:SetMinMaxValues(0, 1)
    castBar:SetValue(0)
    castBar:SetWidth(253)
    castBar:SetHeight(15)
    castBar:SetFrameLevel(4)

    castBar:SetPoint("TOPLEFT",healthBar,"TOPLEFT",0,0)
    castBar:SetStatusBarColor(1,0.7,0.0,0.6)

    local castBarSpell = b:CreateFontString('targetSpellCastName', "OVERLAY", "GameFontNormal")
    castBarSpell:SetTextColor(1,1,1)
    castBarSpell:SetParent(castBar)
    castBarSpell:SetFont(STANDARD_TEXT_FONT,11)
    castBarSpell:SetPoint("LEFT",castBar,"LEFT",5,0)
    castBarSpell:SetText("")
    
    
    local targetDebuffs = CreateFrame("frame",unitWatch..'Debuffs',b)

    _G[unitWatch..'Debuffs']:SetFrameStrata("MEDIUM")
    _G[unitWatch..'Debuffs']:SetWidth(325)
    _G[unitWatch..'Debuffs']:SetHeight(300)
    targetDebuffs:SetPoint('TOPLEFT',powerbar,'BOTTOMLEFT',0,-20)
    
     TTbarBG:SetScript('OnShow',function() 
                  
        addToAnimation(unitWatch..'unitFrameTargetTargetAnimation',unitFrameTargetTargetAnimation[unitWatch],150,GetTime(),0.2,function()
            TTarrow:SetAlpha(animations[unitWatch..'unitFrameTargetTargetAnimation']['progress']/150)
            TTbarBG:SetAlpha(animations[unitWatch..'unitFrameTargetTargetAnimation']['progress']/150)

        end)
        unitFrameTargetTargetAnimation[unitWatch] =0
            
    end)
     TTbarBG:SetScript('OnHide',function() 
        unitFrameTargetTargetAnimation[unitWatch] =0
        TTbarBG:SetAlpha(0)
        TTarrow:SetAlpha(0)    
    end)
    
    b:SetScript("OnShow",function()
        UIFrameFadeIn(b, 0.1,0,1)
    end)
    
    b:SetScript("OnEvent",function(self,event,unit)
        if UnitExists(unitWatch)~=true then
            unitFrameTargetTargetAnimation[unitWatch] =0
            TTbarBG:SetAlpha(0)
            TTarrow:SetAlpha(0)

            b:Hide()
               
            return
        end
        b:Show()
            
        if UnitExists(unitWatch..'target') then
            TTbarBG:Show()
            TTtarName:SetText(UnitName(unitWatch..'target'))
            TThealthBar:SetValue(UnitHealth(unitWatch..'target') / UnitHealthMax(unitWatch..'target'))
            isFriend = UnitIsFriend("player",unitWatch..'target');
            if isFriend then
                TThealthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\statusbarcolored_green")
            else
                TThealthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\statusbarcolored_red")
            end
        else
            TTbarBG:Hide()  
        end
            
       
            
        local hp = UnitHealth(unitWatch) / UnitHealthMax(unitWatch)
        local absorbAmount = UnitGetTotalAbsorbs(unitWatch) / UnitHealthMax(unitWatch)
            
        if event=='PLAYER_'..unitWatch..'_CHANGED' then
                  healthBar:SetValue(hp)
              unitFrameHealthAnimation[unitWatch]=hp
        end
            
            
        if hp~=unitFrameHealthAnimation[unitWatch] then    
            addToAnimation(unitWatch..'healthAnimation',unitFrameHealthAnimation[unitWatch],hp,GetTime(),0.05,function()
                healthBar:SetValue(animations[unitWatch..'healthAnimation']['progress'])
            end)
        end
         unitFrameHealthAnimation[unitWatch]=hp
         addToAnimation(unitWatch..'healthCandyAnimation',unitFrameHealthCandyAnimation[unitWatch],hp,GetTime(),0.1,function()
                    
            healthBar2:SetValue(animations[unitWatch..'healthCandyAnimation']['progress'])
        end)
        unitFrameHealthCandyAnimation[unitWatch]=hp
            
        addToAnimation(unitWatch..'AbsorbAnimation',unitFrameAbsorbAnimation[unitWatch],absorbAmount,GetTime(),0.05,function()
            absorbBar:SetValue(animations[unitWatch..'AbsorbAnimation']['progress'])
        end)  
        unitFrameAbsorbAnimation[unitWatch]=absorbAmount    
            
        name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitWatch)
        casting = false
        channel = false
            
        if name~=nil then
            casting = true
        else
            name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unitWatch)
            if name~=nil then
                channel = true                
            end
        end
        
        powerbar:SetValue((UnitPower(unitWatch)/UnitPowerMax(unitWatch)))
            
        if name~=nil then
                
            
          
           SetPortraitToTexture(img1, texture)   
            castBarSpell:SetText(name)
            startTime = startTime/1000
            endTime = endTime/1000
            addToAnimation(unitWatch..'CastingAnimation',unitFrameCastAnimation[unitWatch],1,startTime,endTime - startTime,function()
                if channel then
                     castBar:SetValue(1-animations[unitWatch..'CastingAnimation']['progress'])
                else
                    castBar:SetValue(animations[unitWatch..'CastingAnimation']['progress'])
                end
            end)    
            unitFrameCastAnimation[unitWatch] = 0
        else
            SetPortraitTexture(img1, unitWatch)
            castBarSpell:SetText('')
            animations[unitWatch..'CastingAnimation']['completed'] = true
            animations[unitWatch..'CastingAnimation']['duration'] = 0
            castBar:SetValue(0)
        end
            
            
            
           
            --SetPortraitTexture(img1, unitWatch)
            tarName:SetText(UnitName(unitWatch))
            powerType, powerToken, altR, altG, altB = UnitPowerType(unitWatch)
            if PowerBarColorCustom[powerToken] then
                local pwcolor = PowerBarColorCustom[powerToken]
                powerbar:SetStatusBarColor(pwcolor.r,pwcolor.g,pwcolor.b)
            end
            lvl = UnitLevel(unitWatch)
            if lvl == -1 then
                lvl = '?'
            end
            tarLevel:SetText(lvl)
            
            bgTexture = 'Interface\\AddOns\\GW2_UI\\textures\\targetshadow'
            
            if ( UnitClassification(unitWatch) == "elite" ) then
                bgTexture ='Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit'
                tarLevel:SetText('Elite '..tarLevel:GetText())
            end
            if ( UnitClassification(unitWatch) == "rare" ) then
                bgTexture = 'Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare'
                tarLevel:SetText('Rare '..tarLevel:GetText())
            end
            if ( UnitClassification(unitWatch) == "rareelite" ) then
                 bgTexture = 'Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare'
                tarLevel:SetText('Rare Elite '..tarLevel:GetText())
            end
            t:SetTexture(bgTexture)
            
               isFriend = UnitIsFriend("player",unitWatch);
            if isFriend then
                
                healthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\statusbarcolored_green")
                healthBar2:SetStatusBarColor(88/255,170/255,68/255)
                tarName:SetTextColor(88/255,170/255,68/255)
            else
                healthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\statusbarcolored_red")
                healthBar2:SetStatusBarColor(159/255,36/255,20/255)
                tarName:SetTextColor(159/255,36/255,20/255)
            
            end
            
            
            
            
            
          
             local x = 1;
            local y = 1;
            local row = 0;
            local col = 0;
            local max = 0;
            for i = 1,20 do
                               
                if UnitBuff(unitWatch,i) then
                    px = col*25;
                    py = row*-25;
              
                      name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID  =  UnitBuff(unitWatch,i)
                  
                        if _G[unitWatch..'buff'..i] then
                            _G[unitWatch..'buff'..i]:Show()
                            _G[unitWatch..'buff'..i..'Texture']:SetTexture(icon)
                            if spellID~=nil then

                                _G[unitWatch..'buff'..i]:SetScript('OnEnter', function() GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines(); GameTooltip:SetUnitBuff(unitWatch,i); GameTooltip:Show() end)
                                _G[unitWatch..'buff'..i]:SetScript('OnLeave', function() GameTooltip:Hide() end)
                            end
                            
                        else
                            createBackgroundName('BOTTOM',20,20,px,py,icon,1,unitWatch.."buff" .. i)
                            _G[unitWatch..'buff'..i..'Texture']:SetTexCoord(0.1,0.9,0.1,0.9)
                            _G[unitWatch..'buffDuration'..i] = _G[unitWatch.."buff" .. i]:CreateFontString(unitWatch..'buffDuration'..i, "OVERLAY", "GameFontNormal")
                             _G[unitWatch..'buffDuration'..i]:SetTextColor(255/255,197/255,39/255)
                             _G[unitWatch..'buffDuration'..i]:SetFont(STANDARD_TEXT_FONT,14)
                             _G[unitWatch..'buffDuration'..i]:SetPoint("BOTTOM",_G[unitWatch..'buff'..i],"BOTTOM",0,-14)
                             _G[unitWatch..'buffDuration'..i]:SetParent(_G[unitWatch..'buff'..i])
                    
                            _G[unitWatch..'buffStacks'..i] = _G[unitWatch.."buff" .. i]:CreateFontString(unitWatch..'buffStacks'..i, "OVERLAY", "GameFontNormal")
                            _G[unitWatch..'buffStacks'..i]:SetTextColor(1,1,1)
                            _G[unitWatch..'buffStacks'..i]:SetFont(STANDARD_TEXT_FONT,11)
                            _G[unitWatch..'buffStacks'..i]:SetPoint("CENTER",_G[unitWatch..'buff'..i],"CENTER",0,0)
                            _G[unitWatch..'buffStacks'..i]:SetParent(_G[unitWatch..'buff'..i])
                        
                             
                        end
                    
                         local remain = expires - GetTime()
                        if remain>60 then
                         remain =   0
                        end
                        remain = round(remain)
                       remain = tonumber(remain)
                        if remain<=0 then
                            stringRemaining = ''
                        else
                            stringRemaining = remain
                        end
                        local stacks = ""
                
                        if count>1 then
                            stacks = count
                        end
                
                        _G[unitWatch..'buffStacks'..i]:SetText(stacks)
                        _G[unitWatch..'buffDuration'..i]:SetText(stringRemaining)
                        _G[unitWatch..'buff'..i]:ClearAllPoints()
                        _G[unitWatch..'buff'..i]:SetParent(_G[unitWatch..'Debuffs'])
                        _G[unitWatch..'buff'..i]:SetPoint('TOPLEFT',_G[unitWatch..'Debuffs'],'TOPLEFT',px,py)
                        
                    
                    
                        col = col +1
                        max = max +1;
                        if col == 11 then
                            row  = row + 1
                            col  = 0
                        end
                else
                    if _G[unitWatch..'buff'..i] then
                    _G[unitWatch..'buff'..i]:Hide()
                    end
                end
                
            end
            row  = row + 1
                            col  = 0
            for i = 1,20 do
              
                local unitDebuffCheck = nil
               if isFriend then
                   unitDebuffCheck = UnitDebuff(unitWatch,i)
                    name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID  =  UnitDebuff(unitWatch,i)
                else
                    unitDebuffCheck =  UnitDebuff(unitWatch,i,'PLAYER')
                      name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID  =  UnitDebuff(unitWatch,i,'PLAYER')
                end
             
                
                if name~=nil then
                  
                    px = col*29;
                    py = row*-39;
                  
                    if _G[unitWatch..'Debuff'..i] then
                        _G[unitWatch..'Debuffbackground'..i]:Show()
                        _G[unitWatch..'Debuff'..i..'Texture']:SetTexture(icon)
                        _G[unitWatch..'Debuff'..i]:SetScript('OnEnter', function() GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines();  GameTooltip:SetUnitDebuff(unitWatch,i); GameTooltip:Show() end)
                        _G[unitWatch..'Debuff'..i]:SetScript('OnLeave', function() GameTooltip:Hide() end)
                        if expires~=nil and duration~=nil then
                            _G[unitWatch..'DebuffCooldown'..i]:SetCooldown(expires - duration, duration)
                        end
                    else
                        createBackgroundName('BOTTOM',20,20,px,py,icon,1,unitWatch.."Debuff" .. i)
                        createBackgroundName('BOTTOM',26,26,px,py,'Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar',0,unitWatch.."Debuffbackground" .. i)
                                 
                        _G[unitWatch.."Debuffbackground" .. i].texture:SetTexture(159/255,36/255,20/255)
                        _G[unitWatch..'Debuff'..i..'Texture']:SetTexCoord(0.1,0.9,0.1,0.9)
                        _G[unitWatch..'DebuffDuration'..i] = _G[unitWatch.."Debuff" .. i]:CreateFontString(unitWatch..'DebuffDuration'..i, "OVERLAY", "GameFontNormal")
                        _G[unitWatch..'DebuffDuration'..i]:SetTextColor(255/255,197/255,39/255)
                        _G[unitWatch..'DebuffDuration'..i]:SetFont(STANDARD_TEXT_FONT,14)
                        _G[unitWatch..'DebuffDuration'..i]:SetPoint("BOTTOM",_G[unitWatch..'Debuff'..i],"BOTTOM",0,-14)
                        _G[unitWatch..'DebuffDuration'..i]:SetParent(_G[unitWatch..'Debuff'..i])
                     
                            _G[unitWatch..'DebuffStacks'..i] = _G[unitWatch.."Debuff" .. i]:CreateFontString(unitWatch..'DebuffStacks'..i, "OVERLAY", "GameFontNormal")
                             _G[unitWatch..'DebuffStacks'..i]:SetTextColor(1,1,1)
                                _G[unitWatch..'DebuffStacks'..i]:SetFont(STANDARD_TEXT_FONT,11)
                             _G[unitWatch..'DebuffStacks'..i]:SetPoint("CENTER",_G[unitWatch..'Debuff'..i],"CENTER",0,0)
                             _G[unitWatch..'DebuffStacks'..i]:SetParent(_G[unitWatch..'Debuff'..i])
                        
                            CreateFrame("Cooldown", unitWatch..'DebuffCooldown'..i, _G[unitWatch.."Debuffbackground" .. i], "CooldownFrameTemplate")
                              _G[unitWatch..'DebuffCooldown'..i]:SetAllPoints(_G[unitWatch..'Debuffbackground'..i])
                               _G[unitWatch..'DebuffCooldown'..i]:SetCooldown(GetTime(), duration)
                              _G[unitWatch..'DebuffCooldown'..i]:SetDrawEdge(0)
                               _G[unitWatch..'DebuffCooldown'..i]:SetDrawSwipe(0)
                              _G[unitWatch..'DebuffCooldown'..i]:SetReverse(1)
                              _G[unitWatch..'DebuffCooldown'..i]:SetHideCountdownNumbers(true)
     
                         
                               
                             
                        end
                            
                           local remain = 0
                         if expires~=nil then
                               remain = expires - GetTime()
                               remain = round(remain)
                           end
                           local stacks = ""
                            
                           if count~=nil then
                             if count>1 then
                                    stacks = count
                              end
                             end
                
                           _G[unitWatch..'DebuffStacks'..i]:SetText(stacks)
                        _G[unitWatch..'DebuffDuration'..i]:SetText(remain)
                            _G[unitWatch..'Debuff'..i]:SetFrameStrata('MEDIUM')
                        _G[unitWatch..'Debuff'..i]:SetFrameLevel(7)
                        _G[unitWatch..'Debuff'..i]:ClearAllPoints()
                        _G[unitWatch..'Debuffbackground'..i]:ClearAllPoints()
                        _G[unitWatch..'Debuffbackground'..i]:SetParent(_G[unitWatch..'Debuffs'])
                        _G[unitWatch..'Debuffbackground'..i]:SetPoint('TOPLEFT',_G[unitWatch..'Debuffs'],'TOPLEFT',px,py)
                    
                        _G[unitWatch.."Debuff" .. i]:SetParent(_G[unitWatch.."Debuffbackground" .. i])
                        _G[unitWatch.."Debuff" .. i]:SetPoint('CENTER',_G[unitWatch.."Debuffbackground" .. i],'CENTER',0,0)   
                        
                    
                    
                        col = col +1
                        max = max +1;
                        if col == 10 then
                            row  = row + 1
                            col  = 0
                        end
                else
                    if _G[unitWatch..'Debuff'..i] then
                    _G[unitWatch..'Debuffbackground'..i]:Hide()
                    end
                end
                
            end
            
            
    end)
    b:RegisterEvent("PLAYER_FOCUS_CHANGED");
    b:RegisterEvent("PLAYER_TARGET_CHANGED");
    b:RegisterEvent("UNIT_AURA");
    b:RegisterEvent("PLAYER_ENTERING_WORLD");
    b:RegisterEvent("ZONE_CHANGED");

    b:RegisterEvent("UNIT_SPELLCAST_START");
    b:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    b:RegisterEvent("UNIT_SPELLCAST_UPDATE");

    b:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    b:RegisterEvent("UNIT_SPELLCAST_STOP");
    b:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    b:RegisterEvent("UNIT_SPELLCAST_FAILED");
    b:RegisterEvent("UNIT_HEALTH");
    b:RegisterEvent("UNIT_MAX_HEALTH");
    b:RegisterEvent("PLAYER_ENTERING_WORLD");

    b:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")


    b:RegisterEvent("UNIT_POWER");
    b:RegisterEvent("UNIT_MAX_POWER");
    b:RegisterEvent("PLAYER_ENTERING_WORLD");
    b:RegisterEvent("UNIT_AURA");
    
    
    
    dragAble:Hide()
    b:Hide()
    
    dragAble:SetMovable(false)
    dragAble:EnableMouse(false)
    
    dragAble:RegisterForDrag("LeftButton")
    dragAble:SetScript("OnDragStart", dragAble.StartMoving)
    dragAble:SetScript("OnDragStop", function(self)
        dragAble:StopMovingOrSizing()
        point, relativeTo, relativePoint, xOfs, yOfs = dragAble:GetPoint()
        GW2UI_SETTINGS[unitWatch..'_pos']['point']=point
        GW2UI_SETTINGS[unitWatch..'_pos']['relativePoint'] =relativePoint
        GW2UI_SETTINGS[unitWatch..'_pos']['xOfs'] =xOfs
        GW2UI_SETTINGS[unitWatch..'_pos']['yOfs'] = yOfs
            


    end)
  
    
end

unitFrameHealthAnimation = {}
unitFrameHealthCandyAnimation = {}
unitFrameAbsorbAnimation = {}
unitFrameCastAnimation = {}
unitFrameTargetTargetAnimation = {}


local unitFrameLoad = CreateFrame('frame',nil,UIParent)

unitFrameLoad:SetScript('OnUpdate',function()
    if GW2UI_SETTINGS['SETTINGS_LOADED'] == false then
                return
    end
  
    createUnitFrame('target','TOP')
    createUnitFrame('focus','CENTER')
    
    FocusFrame:UnregisterAllEvents()
    FocusFrame:SetScript('OnShow',function()
                FocusFrame:Hide()
        end)    
        
    _G['targetGwButton']:SetScript('OnMouseDown', function(self,button)
        if button=='RightButton' and UnitExists("Target") then
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, _G['targetGwButton'], 0, 0)
        end
    end)
    _G['focusGwButton']:SetScript('OnMouseDown', function(self,button)
        if button=='RightButton' and UnitExists("Target") then
		ToggleDropDownMenu(1, nil,   FocusFrameDropDown, _G['focusGwButton'], 0, 0)
        end
    end)
  
            
    unitFrameLoad:SetScript('OnUpdate',nil)
end)