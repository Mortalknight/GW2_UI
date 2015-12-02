
    function setAltPowerPriestDiscipline()
        for i = 1,5 do
             createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"light" .. i .. "BG")
       
            _G["light" .. i .. "BG"]:ClearAllPoints();
            _G["light" .. i .. "BG"]:SetParent(altPowerHolder);
            _G["light" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
            _G["light" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', 50*(i-1), 10);


          
            createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"lightFill" .. i .. "BG")
            
            _G["lightFill" .. i .. "BG"]:ClearAllPoints();
            _G["lightFill" .. i .. "BG"]:SetParent(altPowerHolder);
            _G["lightFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
            _G["lightFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', 50*(i-1), 10);

        end
        altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                if unit =='player' then
                    if UnitAura('player','Evangelism') then
                       name, rank, icon, count = UnitAura('player','Evangelism')
                        for i = 1,5 do

                            if count>= i then
                                _G["lightFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,1);
                             else
                                _G["lightFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
                            end                   

                        end
                    else
                        for i = 1,5 do
                            _G["lightFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
                        end
                    end
                end
        end)
        altPowerHolder:RegisterEvent("UNIT_AURA");
    end
    function setAltPowerPriestShadow()
            for i = 1,5 do
                if i>3 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"shadowOrb" .. i .. "BG")
                else
                 createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarbg",1,"shadowOrb" .. i .. "BG")
                end
                _G["shadowOrb" .. i .. "BG"]:ClearAllPoints();
                _G["shadowOrb" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["shadowOrb" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                local p  = 50*(i-1)
                if i > 3 then
                    p = (50*3)+ (25 * (i-4))
                end
                _G["shadowOrb" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 0);


                if i>3 then
                    createBackgroundName('BOTTOM',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",2,"shadowOrbFill" .. i .. "BG")
                else
                    createBackgroundName('BOTTOM',45,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbarfill",2,"shadowOrbFill" .. i .. "BG")
                end
                _G["shadowOrbFill" .. i .. "BG"]:ClearAllPoints();
                _G["shadowOrbFill" .. i .. "BG"]:SetParent(altPowerHolder);
                _G["shadowOrbFill" .. i .. "BGTexture"]:SetVertexColor(93/255,5/255,255/255,0);
                _G["shadowOrbFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', p, 0);

            end
            altPowerHolder:SetScript("OnEvent", function(self, event, unit)
                    if unit =='player' then
                            for i = 1,5 do
                                if UnitPower('player',13)>= i then
                                    _G["shadowOrbFill" .. i .. "BGTexture"]:SetVertexColor(129/255,79/255,255/255,1);
                                 else
                                    _G["shadowOrbFill" .. i .. "BGTexture"]:SetVertexColor(233/255,174/255,5/255,0);
                                end
                                
                                if i>UnitPowerMax('player',13) then
                                    _G["shadowOrb" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
                                else
                                    _G["shadowOrb" .. i .. "BGTexture"]:SetVertexColor(0,0,0,1);
                                end

                            end
                    end
            end)
            altPowerHolder:RegisterEvent("UNIT_POWER");
        end

    function unSetAltPowerPriestDiscipline()
        for i = 1,5 do
            _G["light" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
            _G["lightFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
        end
    end
    function unSetAltPowerPriestShadow()
            for i = 1,5 do
                if _G["shadowOrb" .. i .. "BGTexture"] then
                    _G["shadowOrb" .. i .. "BGTexture"]:SetVertexColor(0,0,0,0);
                end
               if _G["shadowOrbFill" .. i .. "BGTexture"] then
                _G["shadowOrbFill" .. i .. "BGTexture"]:SetVertexColor(233/255,208/255,82/255,0);
                end
            end
     end


