

local spellStart = 0
local spellEnd = 0
local casting = 0
local targetOldHealth = 0;

local targetFrame,targetTexture = createBackground('TOP',512,128,-50,-50,"Interface\\AddOns\\GW2_UI\\textures\\targetshadow",0)
targetFrameRare,targetTextureRare = createBackground('TOP',512,128,-50,-50,"Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",0)
targetFrameElite,targetTextureElite = createBackground('TOP',512,128,-50,-50,"Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit",0)

local targetPortraitFrame = CreateFrame('PlayerModel',nil,self)
targetTexture:SetAlpha(1)

targetPortraitFrame:SetParent(targetFrame)


targetPortraitFrame:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", 133, -40)
targetPortraitFrame:SetSize(60,60)

targetPortraitFrame:SetPortraitZoom(1)


local img1 = targetPortraitFrame:CreateTexture(nil, "BACKGROUND")
img1:SetHeight(60)
img1:SetWidth(60)
img1:SetPoint("TOPLEFT", 0, 0)
SetPortraitTexture(img1, "player")
img1:SetBlendMode('ADD')


 local   tarName = targetFrame:CreateFontString('unitframePlayerHealth', "OVERLAY", "GameFontNormal")
    tarName:SetTextColor(255/255,197/255,39/255)
    tarName:SetFont(STANDARD_TEXT_FONT,14)
    tarName:SetPoint("TOPLEFT",targetFrame,"TOPLEFT",200,-46)
    tarName:SetText("")

local    tarLevel = targetFrame:CreateFontString('unitframePlayerHealth', "OVERLAY", "GameFontNormal")
    tarLevel:SetTextColor(1,1,1)
    tarLevel:SetFont(STANDARD_TEXT_FONT,14)
    tarLevel:SetJustifyH('RIGHT')
    tarLevel:SetPoint("TOPRIGHT",targetFrame,"TOPRIGHT",-45,-46)
    tarLevel:SetText("20")


local barBG,barbgt = createBackground('TOPLEFT',272,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1)
barBG:SetParent(targetFrame)
barbgt:SetVertexColor(0,0,0,0.2);
barBG:SetPoint("TOPLEFT",targetFrame,"TOPLEFT",195,-60)

local healthBar2 = CreateFrame("StatusBar", nil, targetFrame)
healthBar2:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy")
healthBar2:GetStatusBarTexture():SetHorizTile(false)
healthBar2:SetMinMaxValues(0, 100)
healthBar2:SetValue(100)
healthBar2:SetWidth(270)
healthBar2:SetHeight(12)
healthBar2:SetPoint("LEFT",barBG,"LEFT",1,0)
healthBar2:SetStatusBarColor(0.6,0.1,0.1)

local healthBar = CreateFrame("StatusBar", nil, targetFrame)
healthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
healthBar:GetStatusBarTexture():SetHorizTile(false)
healthBar:SetMinMaxValues(0, 100)
healthBar:SetValue(100)
healthBar:SetWidth(270)
healthBar:SetHeight(12)
healthBar:SetPoint("LEFT",barBG,"LEFT",1,0)
healthBar:SetStatusBarColor(0.6,0.1,0.1)



local absorbBar = CreateFrame("StatusBar", nil, targetFrame)
absorbBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
absorbBar:GetStatusBarTexture():SetHorizTile(false)
absorbBar:SetMinMaxValues(0, 100)
absorbBar:SetValue(100)
absorbBar:SetWidth(270)
absorbBar:SetHeight(12)
absorbBar:SetPoint("LEFT",barBG,"LEFT",1,0)
absorbBar:SetStatusBarColor(0.9,0.9,0.6,0.4)

local candy, candyt = createBackground('TOPLEFT',270,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy",1)

candyt:SetVertexColor(0,0,0);
candyt:SetBlendMode("BLEND")
candy:SetWidth(270)
candy:SetHeight(12)
candy:SetParent(healthBar)
candy:ClearAllPoints()
candy:SetPoint("RIGHT",healthBar,"RIGHT",0,0)





local powerbar = CreateFrame("StatusBar", nil, targetFrame)
powerbar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
powerbar:GetStatusBarTexture():SetHorizTile(false)
powerbar:SetMinMaxValues(0, 100)
powerbar:SetValue(100)
powerbar:SetWidth(270)
powerbar:SetHeight(3)
powerbar:SetPoint("TOPLEFT",targetFrame,"TOPLEFT",196,-76)
powerbar:SetStatusBarColor(1,0.7,0.3)

local castBar = CreateFrame("StatusBar", nil, healthBar)
castBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
castBar:GetStatusBarTexture():SetHorizTile(false)
castBar:SetMinMaxValues(0, 100)
castBar:SetValue(100)
castBar:SetWidth(270)
castBar:SetHeight(12)

castBar:SetPoint("TOPLEFT",healthBar,"TOPLEFT",0,0)
castBar:SetStatusBarColor(1,0.7,0.0,0.6)

    local castBarSpell = targetFrame:CreateFontString('targetSpellCastName', "OVERLAY", "GameFontNormal")
    castBarSpell:SetTextColor(1,1,1)
    castBarSpell:SetParent(castBar)
    castBarSpell:SetFont(STANDARD_TEXT_FONT,11)
    castBarSpell:SetPoint("LEFT",castBar,"LEFT",5,0)
    castBarSpell:SetText("")




targetPortraitFrame:SetScript("OnEvent",function(self,event,addon)
        if UnitExists("Target") then
            
            local special = 0;
            
            if ( UnitClassification("target") == "elite" ) then
                targetFrameElite:SetAlpha(1)
                special = 1
                tarLevel:SetText('Elite '..UnitLevel("target"))
            end
            if ( UnitClassification("target") == "rare" ) then
                targetFrameRare:SetAlpha(1)
                special= 1
                tarLevel:SetText('Rare '..UnitLevel("target"))
            end
            if ( UnitClassification("target") == "rareelite" ) then
                targetFrameElite:SetAlpha(1)
                 targetFrameRare:SetAlpha(1)
                special = 1
                tarLevel:SetText('Rare Elite '..UnitLevel("target"))
            end
            
            if special == 1 then
                targetTexture:SetAlpha(0)
            else
                targetTexture:SetAlpha(1)
                targetFrameElite:SetAlpha(0)
                targetFrameRare:SetAlpha(0)
                tarLevel:SetText(UnitLevel("target"))
            end
            
            
            
            TargetFrame:Hide();
            
            targetPortraitFrame:EnableMouse(true);
            casting = false
            castBar:SetAlpha(0)
            
            prec = ((UnitHealth('Target') / UnitHealthMax('Target')))
            
            newWidth = 270*((1 - prec))
            
           
            
            
            --newWidth = ((100-prec)/100)*270
            candy:SetWidth(newWidth)
            
            targetFrame:SetAlpha(1)
            SetPortraitTexture(img1, "Target")
           -- targetPortraitFrame:SetUnit("Target")
            tarName:SetText(UnitName('Target'))
            powerType, powerToken, altR, altG, altB = UnitPowerType("Target")
            if PowerBarColorCustom[powerToken] then
                local pwcolor = PowerBarColorCustom[powerToken]
                powerbar:SetStatusBarColor(pwcolor.r,pwcolor.g,pwcolor.b)
            end
            
           
            targetFrame:ClearAllPoints()
            targetFrame:SetPoint('TOP',UIParent,'TOP',-50,-50)
        else
            targetFrame:ClearAllPoints()
            targetFrame:SetPoint('TOP',UIParent,'TOP',0,500)
            targetPortraitFrame:EnableMouse(false);
            targetFrame:SetAlpha(0)
             targetFrameElite:SetAlpha(0)
                 targetFrameRare:SetAlpha(0)
        end
        
        
end)
castBar:SetScript("OnEvent",function(self,event,unitID,spell)
        if UnitExists("Target") and unitID=='target' then
            if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' then
                    if event=='UNIT_SPELLCAST_CHANNEL_START' then
                        spell, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("Target")
                    else
                        spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("Target")
                    end
                castBar:SetAlpha(1)
                castBarSpell:SetText(spell)
                
                spellStart = startTime
                spellEnd = endTime
                castBar:SetValue(((spellEnd - spellStart) / 100))
                casting = true
            end
            
            if  event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_CHANNEL_STOP' then
                casting = false
                castBar:SetAlpha(0)
            end
            
        else
            
        end
        
        
end)
castBar:SetScript("OnUpdate",function(self)
        if UnitExists("Target") and UnitCastingInfo('target') or UnitChannelInfo('target') then
            if casting then                
                castBar:SetValue((((GetTime() * 1000) - spellStart) / (spellEnd - spellStart) * 100 ))
            end
        end
        
        
end)


targetPortraitFrame:SetScript("OnUpdate",function(self)
        if UnitExists("Target") then   
            
            local absorbAmount = ((UnitGetTotalAbsorbs('Target') / UnitHealthMax('Target'))*100)
            if absorbAmount > 100 then
                absorbAmount  = 100
            end
             powerbar:SetValue((UnitPower('target')/UnitPowerMax('target'))*100)
            
            local prec = ((UnitHealth('Target') / UnitHealthMax('Target'))*100)
            local newWidth = ((100-prec)/100)*270
            
            absorbBar:SetValue(absorbAmount)
           --  newWidth = 270*((1 - prec))
            
            
            healthBar:SetValue(prec)
            
            local limit = 30/GetFramerate()
  
            local cur = healthBar2:GetValue()
            local new = cur + min((prec-cur)/3, max(prec-cur, limit))
            if new ~= new then
                new = value
            end
            
            healthBar2:SetValue(new)
            --candy:SetWidth(new)
            if newWidth == 0 then
                candy:SetAlpha(0)
                else
                candy:SetAlpha(1)
            end
            candy:SetAlpha(0)
        end
        
        
end)


targetFrame:SetScript('OnMouseDown', function(self,button)
        if button=='RightButton' and UnitExists("Target") then
		ToggleDropDownMenu(1, nil, TargetFrameDropDown, targetFrame, 0, 0)
        end
end)

targetPortraitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
targetPortraitFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
targetPortraitFrame:RegisterEvent("ZONE_CHANGED");

castBar:RegisterEvent("UNIT_SPELLCAST_START");
castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
castBar:RegisterEvent("UNIT_SPELLCAST_UPDATE");

castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
castBar:RegisterEvent("UNIT_SPELLCAST_STOP");
castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
castBar:RegisterEvent("UNIT_SPELLCAST_FAILED");


local targetDebuffs = CreateFrame("frame",'targetDebuffs',UIParent)

    targetDebuffs:SetFrameStrata("MEDIUM")
    targetDebuffs:SetWidth(325)
    targetDebuffs:SetHeight(300)
    targetDebuffs:SetPoint('TOPLEFT',targetFrame,'BOTTOMLEFT',195,40)

    targetDebuffs:SetScript('OnUpdate', function(self,event,unit)
       
    
            local x = 1;
            local y = 1;
            local row = 0;
            local col = 0;
            local max = 0;
        for i = 1,20 do
                               
                if UnitBuff("target",i) then
                    px = col*29;
                    py = row*-29;
              
                      name, rank, icon, count, dispelType, duration, expires  =  UnitBuff("target",i)
                  
                        if _G['targetbuff'..i] then
                        _G['targetbuff'..i]:Show()
                         _G['targetbuff'..i..'Texture']:SetTexture(icon)
                            else
                            createBackgroundName('BOTTOM',24,24,px,py,icon,1,"targetbuff" .. i)
                            _G['targetbuff'..i..'Texture']:SetTexCoord(0.1,0.9,0.1,0.9)
                            _G['targetbuffDuration'..i] = targetFrame:CreateFontString('targetbuffDuration'..i, "OVERLAY", "GameFontNormal")
                             _G['targetbuffDuration'..i]:SetTextColor(255/255,197/255,39/255)
                             _G['targetbuffDuration'..i]:SetFont(STANDARD_TEXT_FONT,14)
                             _G['targetbuffDuration'..i]:SetPoint("BOTTOM",_G['targetbuff'..i],"BOTTOM",0,-14)
                             _G['targetbuffDuration'..i]:SetParent(_G['targetbuff'..i])
                    
                            _G['targetbuffStacks'..i] = targetFrame:CreateFontString('targetbuffStacks'..i, "OVERLAY", "GameFontNormal")
                            _G['targetbuffStacks'..i]:SetTextColor(1,1,1)
                            _G['targetbuffStacks'..i]:SetFont(STANDARD_TEXT_FONT,11)
                            _G['targetbuffStacks'..i]:SetPoint("CENTER",_G['targetbuff'..i],"CENTER",0,0)
                            _G['targetbuffStacks'..i]:SetParent(_G['targetbuff'..i])
                             
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
                
                        _G['targetbuffStacks'..i]:SetText(stacks)
                        _G['targetbuffDuration'..i]:SetText(stringRemaining)
                        _G['targetbuff'..i]:ClearAllPoints()
                        _G['targetbuff'..i]:SetParent(targetDebuffs)
                        _G['targetbuff'..i]:SetPoint('TOPLEFT',targetDebuffs,'TOPLEFT',px,py)
                        
                    
                    
                        col = col +1
                        max = max +1;
                        if col == 10 then
                            row  = row + 1
                            col  = 0
                        end
                else
                    if _G['targetbuff'..i] then
                    _G['targetbuff'..i]:Hide()
                    end
                end
                
            end
            row  = row + 1
                            col  = 0
            for i = 1,20 do
                               
                if UnitDebuff("target",i,'PLAYER') then
                    px = col*29;
                    py = row*-39;
                      name, rank, icon, count, dispelType, duration, expires  =  UnitDebuff("target",i,'PLAYER')
                        if _G['targetDebuff'..i] then
                        _G['targetDebuff'..i]:Show()
                         _G['targetDebuff'..i..'Texture']:SetTexture(icon)
                            else
                            createBackgroundName('BOTTOM',24,24,px,py,icon,1,"targetDebuff" .. i)
                            _G['targetDebuff'..i..'Texture']:SetTexCoord(0.1,0.9,0.1,0.9)
                            _G['targetDebuffDuration'..i] = targetFrame:CreateFontString('targetDebuffDuration'..i, "OVERLAY", "GameFontNormal")
                             _G['targetDebuffDuration'..i]:SetTextColor(255/255,197/255,39/255)
                             _G['targetDebuffDuration'..i]:SetFont(STANDARD_TEXT_FONT,14)
                             _G['targetDebuffDuration'..i]:SetPoint("BOTTOM",_G['targetDebuff'..i],"BOTTOM",0,-14)
                             _G['targetDebuffDuration'..i]:SetParent(_G['targetDebuff'..i])
                    
                            _G['targetDebuffStacks'..i] = targetFrame:CreateFontString('targetDebuffStacks'..i, "OVERLAY", "GameFontNormal")
                            _G['targetDebuffStacks'..i]:SetTextColor(1,1,1)
                            _G['targetDebuffStacks'..i]:SetFont(STANDARD_TEXT_FONT,11)
                            _G['targetDebuffStacks'..i]:SetPoint("CENTER",_G['targetDebuff'..i],"CENTER",0,0)
                            _G['targetDebuffStacks'..i]:SetParent(_G['targetDebuff'..i])
                             
                        end
                    
                         local remain = expires - GetTime()
                        remain = round(remain)
                        local stacks = ""
                
                        if count>1 then
                            stacks = count
                        end
                
                        _G['targetDebuffStacks'..i]:SetText(stacks)
                        _G['targetDebuffDuration'..i]:SetText(remain)
                        _G['targetDebuff'..i]:ClearAllPoints()
                        _G['targetDebuff'..i]:SetParent(targetDebuffs)
                        _G['targetDebuff'..i]:SetPoint('TOPLEFT',targetDebuffs,'TOPLEFT',px,py)
                        
                    
                    
                        col = col +1
                        max = max +1;
                        if col == 10 then
                            row  = row + 1
                            col  = 0
                        end
                else
                    if _G['targetDebuff'..i] then
                    _G['targetDebuff'..i]:Hide()
                    end
                end
                
            end
        
            
    end)
    

    targetDebuffs:RegisterEvent("UNIT_AURA");
    targetDebuffs:RegisterEvent("PLAYER_TARGET_CHANGED");
