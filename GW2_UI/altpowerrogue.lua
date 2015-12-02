  function setAltPowerRogue()
            for i = 1,7 do
                if i>7 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"combatPoints" .. i .. "BG")
                else
                 createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"combatPoints" .. i .. "BG")
                end
                _G["combatPoints" .. i .. "BG"]:ClearAllPoints();
                _G["combatPoints" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["combatPoints" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                local p  = 50*(i-1)
                if i > 7 then
                    p = (50*2) + (25 * (i-3)) + (36)
                end
                _G["combatPoints" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);


                if i>7 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",2,"combatPointsFill" .. i .. "BG")
                else
                    createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"combatPointsFill" .. i .. "BG")
                end
                _G["combatPointsFill" .. i .. "BG"]:ClearAllPoints();
                _G["combatPointsFill" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["combatPointsFill" .. i .. "BGTexture"]:SetVertexColor(93/255,5/255,255/255,0);
                _G["combatPointsFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);

            end
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                    if unit =='player' then
                         updateCombatPoints()
                    end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateCombatPoints()
        end
    function updateCombatPoints()
       for i = 1,7 do
            if UnitPower('player',4)>= i then
                _G["combatPointsFill" .. i .. "BGTexture"]:SetVertexColor(165/255,114/255,63/255,1);
            else
                _G["combatPointsFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
            end
                                
            if i>UnitPowerMax('player',4) then
                _G["combatPoints" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
            else
                _G["combatPoints" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
            end
        end
    end
    function unSetAltPowerRogue()
         for i = 1,5 do
                if _G["combatPoints" .. i .. "BGTexture"] then
                    _G["combatPoints" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
                end
               if _G["combatPointsFill" .. i .. "BGTexture"] then
                _G["combatPointsFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
                end
            end
    end