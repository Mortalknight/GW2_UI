local spe = CreateFrame("frame",'spe',UIParent)
local prevSpec = nil
local prevStance = nil
local altPowerHolder = CreateFrame("frame",'altPowerHolder',UIParent)

    altPowerHolder:SetFrameStrata("BACKGROUND")
    altPowerHolder:SetWidth(325)
    altPowerHolder:SetHeight(15)
 altPowerHolder:Show()
altPowerHolder:ClearAllPoints();
altPowerHolder:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, -16);

function setAltPower(event,unit)
local playerClassName, playerClassEng, playerClass = UnitClass('player')
local currentSpec  = GetSpecialization();
local stance = GetShapeshiftFormID()
    if stance==nil then
        stance = 0
    end
    if event == 'UPDATE_SHAPESHIFT_FORM' and stance~=nil then
        if prevStance==31 then
            unSetAltPowerMoonkin()
        end
          if prevStance == 1 then
                unSetAltPowerRogue()
            end
        prevStance = stance
    end
    
    --PALADIN
   if  playerClass==2 then
        setAltPowerPaladin()
    end
    
    if playerClass==4 then
        setAltPowerRogue()
    end
    
    --PRIEST
    if  playerClass==5 and currentSpec==1 then
        if prevSpec == 3 then
            unSetAltPowerPriestShadow()
        end
        setAltPowerPriestDiscipline()
    end
    if  playerClass==5 and currentSpec==2 then
        if prevSpec == 1 then
            unSetAltPowerPriestDiscipline()
        end
        if prevSpec == 3 then
           unSetAltPowerPriestShadow()
        end
    end
    if  playerClass==5 and currentSpec==3 then
        if prevSpec == 1 then
            unSetAltPowerPriestDiscipline()
        end
        
        setAltPowerPriestShadow()
    end
    
    
    -- DEATH KNIGHT
    if  playerClass==6 then
        setAltPowerDeathKnight()
    end
    
    
    -- WARLOCK
     if  playerClass==9 and currentSpec==1 then
        if prevSpec == 2 then
            unSetAltPowerWarlockDemonology()
        end
        if prevSpec == 3 then
            unSetAltPowerWarlockDestruction()
        end
        setAltPowerWarlockAffliction()
    end
    
    if  playerClass==9 and currentSpec==2 then
        if prevSpec == 1 then
            unSetAltPowerWarlockAffliction()
        end
        if prevSpec == 3 then
            unSetAltPowerWarlockDestruction()
        end
        setAltPowerWarlockDemonology()
    end
     if  playerClass==9 and currentSpec==3 then
        if prevSpec == 2 then
            unSetAltPowerWarlockDemonology()
        end
        if prevSpec == 1 then
            unSetAltPowerWarlockAffliction()
        end
         setAltPowerWarlockDestruction()
    end
    
    --MONK
    if  playerClass==10 then
        setAltPowerMonk()
    end
    
    
    -- DRUID
    if  playerClass==11 then
        
        if stance==1 then
            setAltPowerRogue()
        end
        
        if stance==5 or stance==4 or stance==3 or stance==2 or stance==29 then
            
            
        end
        if stance == 31 then
          
            setAltPowerMoonkin()
           
        end
    end
           
   prevSpec = currentSpec
end

    function setAltPowerDeathKnight()
          for i = 1,6 do

            _G["rune" .. i .. "BG"], _G["rune" .. i .. "BGt"] = createBackgroundName('BOTTOM',15,15,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerbg",1,"rune" .. i .. "BG")
            _G["rune" .. i .. "BG"]:ClearAllPoints();
            _G["rune" .. i .. "BG"]:SetParent(altPowerHolder);
            _G["rune" .. i .. "BGt"]:SetVertexColor(0,0,0,1);
            _G["rune" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', 40*(i-1), 0);


            _G["runeFill" .. i .. "BG"], _G["runeFill" .. i .. "BGt"] = createBackgroundName('BOTTOM',15,15,0,0,"Interface\\AddOns\\GW2_UI\\textures\\altpowerfill",1,"runeFill" .. i .. "BG")
            _G["runeFill" .. i .. "BG"]:ClearAllPoints();
            _G["runeFill" .. i .. "BG"]:SetParent(altPowerHolder);
           -- _G["runeFill" .. i .. "BGt"]:SetVertexColor(0,0,0,1);
            _G["runeFill" .. i .. "BG"]:SetPoint('LEFT', altPowerHolder, 'LEFT', 40*(i-1), 0);

        end
        altPowerHolder:SetScript("OnEvent", function(self, event, unit)
            if event=='PLAYER_SPECIALIZATION_CHANGED' then
                if unit ~= 'player' then
                return
                end
            end
            for i = 1,6 do
                local rune_type = GetRuneType(i)
                local rune_start, rune_duration, rune_ready = GetRuneCooldown(i)

                if rune_type == 1 then
                      _G["runeFill" .. i .. "BGt"]:SetVertexColor(1,0.2,0.2,1);
                end
                if rune_type == 2 then
                      _G["runeFill" .. i .. "BGt"]:SetVertexColor(0.2,1,0.2,1);
                end
                if rune_type == 3 then
                      _G["runeFill" .. i .. "BGt"]:SetVertexColor(0.2,0.2,1,1);
                end
                if rune_type == 4 then
                      _G["runeFill" .. i .. "BGt"]:SetVertexColor(0.5,0.2,0.5,1);
                end
                if rune_ready == false then
                      _G["runeFill" .. i .. "BGt"]:SetVertexColor(0,0,0,1);
                end

            end

        end)
        altPowerHolder:RegisterEvent("RUNE_POWER_UPDATE");
        altPowerHolder:RegisterEvent("PLAYER_ENTERING_WORLD");
        altPowerHolder:RegisterEvent("UNIT_POWER");
    end


    spe:HookScript("OnEvent", function(self, event, unit)
        altPowerHolder:UnregisterAllEvents()
        altPowerHolder:SetScript("OnEvent", nil)
         altPowerHolder:SetScript("OnUpdate", nil)
        setAltPower(event,unit)
    end)



spe:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
spe:RegisterEvent("PLAYER_ENTERING_WORLD")
spe:RegisterEvent("CHARACTER_POINTS_CHANGED")
spe:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
