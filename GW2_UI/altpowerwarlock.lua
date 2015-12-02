  function setAltPowerWarlockAffliction()
            for i = 1,5 do
                if i>4 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"soulShards" .. i .. "BG")
                else
                 createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"soulShards" .. i .. "BG")
                end
                _G["soulShards" .. i .. "BG"]:ClearAllPoints();
                _G["soulShards" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["soulShards" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                local p  = 50*(i-1)
                if i > 4 then
                    p = (50*2) + (25 * (i-4)) + (36)
                end
                _G["soulShards" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);


                if i>4 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",2,"soulShardsFill" .. i .. "BG")
                else
                    createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"soulShardsFill" .. i .. "BG")
                end
                _G["soulShardsFill" .. i .. "BG"]:ClearAllPoints();
                _G["soulShardsFill" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["soulShardsFill" .. i .. "BGTexture"]:SetVertexColor(93/255,5/255,255/255,0);
                _G["soulShardsFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);

            end
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                    if unit =='player' then
                         updateSoulShards()
                    end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateSoulShards()
        end

  

    function setAltPowerWarlockDemonology()
                
                createBackgroundName('BOTTOM',210,12,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1,"demonicFuryBg")
            
                _G["demonicFuryBg"]:SetScale(1.5);
                _G["demonicFuryBg"]:ClearAllPoints();
                _G["demonicFuryBg"]:SetParent(altPowerHolder);
                _G["demonicFuryBgTexture"]:SetVertexColor(0,0,0,0.6);
               
                _G["demonicFuryBg"]:SetPoint('LEFT', altPowerHolder, 'LEFT', 0, 5);


                createBackgroundName('BOTTOM',108,10,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1,"demonicFuryFill")
    
                _G['demonicFuryFill']:ClearAllPoints();
                _G['demonicFuryFill']:SetScale(1.5);
                _G["demonicFuryFill"]:SetParent(altPowerHolder);
                _G["demonicFuryFillTexture"]:SetVertexColor(218/255,45/255,255/255,1);
                _G["demonicFuryFill"]:SetPoint('LEFT', _G["demonicFuryBg"], 'LEFT', 1, 0);

          
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
            
                if unit =='player' then
                    updateDemonicFury()
                end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateDemonicFury()
        end


  function setAltPowerWarlockDestruction()
            for i = 1,4 do
                if i>4 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"burningEmber" .. i .. "BG")
                else
                 createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"burningEmber" .. i .. "BG")
                end
                _G["burningEmber" .. i .. "BG"]:ClearAllPoints();
                _G["burningEmber" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["burningEmber" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                local p  = 50*(i-1)
              
                _G["burningEmber" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);


                
                createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"burningEmberFill" .. i .. "BG")
                
                _G["burningEmberFill" .. i .. "BG"]:ClearAllPoints();
                _G["burningEmberFill" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["burningEmberFill" .. i .. "BGTexture"]:SetVertexColor(93/255,5/255,255/255,0);
                _G["burningEmberFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);

            end
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                    if unit =='player' then
                         updateBurningEmbers()
                    end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateBurningEmbers()
        end

function unSetAltPowerWarlockAffliction()
            for i = 1,5 do
                if _G["soulShards" .. i .. "BGTexture"] then
                    _G["soulShards" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
                end
               if _G["soulShardsFill" .. i .. "BGTexture"] then
                _G["soulShardsFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
                end
            end
     end
function unSetAltPowerWarlockDestruction()
            for i = 1,5 do
                if _G["burningEmber" .. i .. "BGTexture"] then
                    _G["burningEmber" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
                end
               if _G["burningEmberFill" .. i .. "BGTexture"] then
                _G["burningEmberFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
                end
            end
     end
function unSetAltPowerWarlockDemonology()
    _G["demonicFuryBgTexture"]:SetVertexColor(0,0,0,0);
    _G["demonicFuryFillTexture"]:SetVertexColor(218/255,45/255,255/255,0);
end
  function updateSoulShards()
       for i = 1,5 do
            if UnitPower('player',7)>= i then
                _G["soulShardsFill" .. i .. "BGTexture"]:SetVertexColor(228/255,102/255,255/255,1);
            else
                _G["soulShardsFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
            end
                                
            if i>UnitPowerMax('player',7) then
                _G["soulShardsFill" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
            end
        end
    end
function updateDemonicFury()
    local w = 208 * (UnitPower('player',15) / UnitPowerMax('player',15))
        _G["demonicFuryFill"]:SetWidth(w);
    end
  function updateBurningEmbers()
    local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true);
    local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true);
    local numEmbers = floor(maxPower / MAX_POWER_PER_EMBER);
       for i = 1,4 do
            local p = power - (10*(i-1))

            if p>= 10 then
                _G["burningEmberFill" .. i .. "BGTexture"]:SetVertexColor(255/255,60/255,0/255,1);
             else
                if p>=1 then
                    _G["burningEmberFill" .. i .. "BGTexture"]:SetVertexColor(255/255,156/255,0/255,1);
                    _G["burningEmberFill" .. i .. "BG"]:SetWidth(45*((p+1)/10));
                
                else
                    if p<=0 then
                        _G["burningEmberFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
                    end
                end
            end
             
                                
            
        end
    end