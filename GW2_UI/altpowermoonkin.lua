function setAltPowerMoonkin()
                
                createBackgroundName('BOTTOM',210,12,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1,"eclips")
            
                _G["eclips"]:SetScale(1.5);
                _G["eclips"]:ClearAllPoints();
                _G["eclips"]:SetParent(altPowerHolder);
                _G["eclipsTexture"]:SetVertexColor(0,0,0,0.6);
               
                _G["eclips"]:SetPoint('LEFT', altPowerHolder, 'LEFT', 0, 3);


                createBackgroundName('BOTTOM',208,10,0,0,"Interface\\AddOns\\GW2_UI\\textures\\eclipsbar",2,"eclipsFill")
    
                _G['eclipsFill']:ClearAllPoints();
                _G['eclipsFill']:SetScale(1.5);
                _G["eclipsFill"]:SetParent(altPowerHolder);
                _G["eclipsFillTexture"]:SetAlpha(1)
                _G["eclipsFill"]:SetPoint('LEFT', _G["eclips"], 'LEFT', 1, 0);

                createBackgroundName('BOTTOM',35,35,0,0,"Interface\\CastingBar\\UI-CastingBar-Spark",3,"eclipsSpark")
    
                _G['eclipsSpark']:ClearAllPoints();
                _G['eclipsSpark']:SetScale(1.5);
                _G["eclipsSpark"]:SetParent(altPowerHolder);
                _G["eclipsSparkTexture"]:SetAlpha(1)
    _G["eclipsSparkTexture"]:SetBlendMode('ADD')
                _G["eclipsSpark"]:SetPoint('LEFT', _G["eclips"], 'LEFT', 1, 0);
    
            altPowerHolder:SetScript("OnUpdate", function(self, event, unit)
            
              
                    updateEclipsbar()
              
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateEclipsbar()
        end

function updateEclipsbar()
    
    local p = (UnitPower('player',8)+100) / (UnitPowerMax('player',8)+100)
    _G['eclipsSpark']:ClearAllPoints();
    _G["eclipsSpark"]:SetPoint('CENTER', _G['eclips'], 'CENTER', (p*208)-104, 0);
    
end

function unSetAltPowerMoonkin()
    _G["eclipsTexture"]:SetVertexColor(0,0,0,0);
    _G["eclipsFillTexture"]:SetAlpha(0)
     _G["eclipsSparkTexture"]:SetAlpha(0)
end