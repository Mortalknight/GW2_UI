local paladingPowersCreated = false
local lerpRunningPalading = false
local oldValuePaladin = UnitPower('player',9) * 1000
local newValuePaladin = 0
local startTimePaladin = 0
local currentLerpPaladin = 0

function setAltPowerPaladin()
    if paladingPowersCreated==true then
        return
    end
    paladingPowersCreated = true
    
    --SPELLS/PRIEST_LIGHTWELL_V2.m2
    
    _G["holyPowerBG"],_G["holyPowerTexture"] = createBackground('TOPLEFT',256,32,0,0,"Interface\\AddOns\\GW2_UI\\textures\\holypower_bg",1)
    _G["holyPowerBG"]:ClearAllPoints()
    _G["holyPowerBG"]:SetParent(altPowerHolder);
    _G["holyPowerBG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', -5, 5);
    
    _G["holyPowerBar"] = CreateFrame("StatusBar", nil, _G["holyPowerBG"])
    _G["holyPowerBar"]:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\holypower_fill")
    _G["holyPowerBar"]:GetStatusBarTexture():SetHorizTile(false)
    _G["holyPowerBar"]:SetMinMaxValues(0, 3000)
    _G["holyPowerBar"]:SetValue(0)
    _G["holyPowerBar"]:SetWidth(256)
    _G["holyPowerBar"]:SetHeight(32)
    _G["holyPowerBar"]:SetPoint('CENTER', _G["holyPowerBG"], 'CENTER', 0, 0);

    _G["holyPowerExtraBG"],_G["holyPowerExtraTexture"] = createBackgroundName('TOPLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,'holyPowerExtraBG')
    _G["holyPowerExtraBG"]:ClearAllPoints()
    _G["holyPowerExtraBG"]:SetParent(altPowerHolder);
    _G["holyPowerExtraBG"]:SetPoint('LEFT', holyPowerBG, 'RIGHT', 5, 0);
    
    _G["holyPowerExtraBG2"],_G["holyPowerExtraTexture2"] = createBackgroundName('TOPLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,'holyPowerExtraBG2')
    _G["holyPowerExtraBG2"]:ClearAllPoints()
    _G["holyPowerExtraBG2"]:SetParent(altPowerHolder);
    _G["holyPowerExtraBG2"]:SetPoint('LEFT', holyPowerExtraBG, 'RIGHT', 5, 0);
    
    _G["holyPowerExtraFillBg"],_G["holyPowerExtraTexture2"] = createBackgroundName('TOPLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",1,'holyPowerExtraFillBg')
    _G["holyPowerExtraFillBg"]:ClearAllPoints()
    _G["holyPowerExtraFillBg"]:SetParent(altPowerHolder);
    _G["holyPowerExtraFillBg"]:SetPoint('CENTER', holyPowerExtraBG, 'CENTER', 0, 0);
    _G["holyPowerExtraFillBg"]:SetFrameLevel(4)
    
    _G["holyPowerExtraFillBg2"],_G["holyPowerExtraTexture2"] = createBackgroundName('TOPLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",1,'holyPowerExtraFillBg2')
    _G["holyPowerExtraFillBg2"]:ClearAllPoints()
    _G["holyPowerExtraFillBg2"]:SetParent(altPowerHolder);
    _G["holyPowerExtraFillBg2"]:SetPoint('CENTER', holyPowerExtraBG2, 'CENTER', 0, 0);
    _G["holyPowerExtraFillBg2"]:SetFrameLevel(4)
    
    
    HolyShine = CreateFrame("PlayerModel",HolyShine,altPowerHolder)
    HolyShine:SetFrameStrata("BACKGROUND")
    HolyShine:SetFrameLevel(0)
    HolyShine:SetWidth(500) 
    HolyShine:SetHeight(474) 
    HolyShine:SetPoint('BOTTOM',altPowerHolder,'BOTTOM',0,-100)
    HolyShine:SetModel('SPELLS/HolyZone.m2')
    HolyShine:SetPosition(-12,0,0)
    HolyShine:SetAlpha(0)
    
          
            _G["holyPowerBG"]:SetScript('OnUpdate',function()
            
                m = UnitPower('player',9)*1000
            
              if oldValuePaladin ~= m and lerpRunningPaladin~=true then

                    newValuePaladin = UnitPower('player',9) * 1000
                    lerpRunningPaladin = true
                    startTimePaladin = GetTime()
                 
                end
                if lerpRunningPaladin then

                    currentLerpPaladin = lerp(oldValuePaladin, newValuePaladin, (GetTime() - startTimePaladin) / 0.3)
                    HolyShine:SetAlpha((currentLerpPaladin/1000)/3)
                    if (GetTime() - startTimePaladin)>=0.3 then
                        lerpRunningPaladin = false
                        oldValuePaladin = UnitPower('player',9) * 1000
                        currentLerpPaladin = oldValuePaladin
                    end
                end
                _G["holyPowerBar"]:SetValue(currentLerpPaladin)
                if UnitPower('player',9)>=4 then
                    _G["holyPowerExtraFillBg"]:Show()
                else
                     _G["holyPowerExtraFillBg"]:Hide()
                end
              if UnitPower('player',9)>=5 then
                    _G["holyPowerExtraFillBg2"]:Show()
                else
                     _G["holyPowerExtraFillBg2"]:Hide()
                end
            end)
         
        end
        
    function updateHolyPowerBar()
     --UnitPower('player',9)
       -- _G["holyPowerBar"]:SetValue(UnitPower('player',9))
          
    end
