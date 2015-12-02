  function setAltPowerMonk()
            for i = 1,7 do
                if i>7 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"chi" .. i .. "BG")
                else
                 createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"chi" .. i .. "BG")
                end
                _G["chi" .. i .. "BG"]:ClearAllPoints();
                _G["chi" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["chi" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                local p  = 50*(i-1)
                if i > 7 then
                    p = (50*2) + (25 * (i-3)) + (36)
                end
                _G["chi" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);


                if i>7 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",2,"chiFill" .. i .. "BG")
                else
                    createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"chiFill" .. i .. "BG")
                end
                _G["chiFill" .. i .. "BG"]:ClearAllPoints();
                _G["chiFill" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["chiFill" .. i .. "BGTexture"]:SetVertexColor(93/255,5/255,255/255,0);
                _G["chiFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 7);

            end
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                    if unit =='player' then
                         updateChiBar()
                    end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
            updateChiBar()
        end
    function updateChiBar()
       for i = 1,7 do
            if UnitPower('player',12)>= i then
                _G["chiFill" .. i .. "BGTexture"]:SetVertexColor(103/255,255/255,221/255,1);
            else
                _G["chiFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
            end
                                
            if i>UnitPowerMax('player',12) then
                _G["chi" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
            else
                _G["chi" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
            end
        end
    end