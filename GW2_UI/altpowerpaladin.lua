  function setAltPowerPaladin()
            for i = 1,5 do
                if i>3 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"holyPower" .. i .. "BG")
                else
                 createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"holyPower" .. i .. "BG")
                end
                _G["holyPower" .. i .. "BG"]:ClearAllPoints();
                _G["holyPower" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["holyPower" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                local p  = 50*(i-1)
                if i > 3 then
                    p = (50*2) + (25 * (i-3)) + (36)
                end
                _G["holyPower" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 0);


                if i>3 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",2,"holyPowerFill" .. i .. "BG")
                else
                    createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"holyPowerFill" .. i .. "BG")
                end
                _G["holyPowerFill" .. i .. "BG"]:ClearAllPoints();
                _G["holyPowerFill" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["holyPowerFill" .. i .. "BGTexture"]:SetVertexColor(93/255,5/255,255/255,0);
                _G["holyPowerFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 0);

            end
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                    if unit =='player' then
                         updateHolyPowerBar()
                    end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateHolyPowerBar()
        end
    function updateHolyPowerBar()
       for i = 1,5 do
            if UnitPower('player',9)>= i then
                _G["holyPowerFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,1);
            else
                _G["holyPowerFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
            end
                                
            if i>UnitPowerMax('player',9) then
                _G["holyPower" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
            else
                _G["holyPower" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
            end
        end
    end