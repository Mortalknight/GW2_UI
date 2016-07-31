PowerBarColorCustom = PowerBarColor;

PowerBarColorCustom['MANA'] = {r=37/255,g=133/255,b=240/255}
PowerBarColorCustom['RAGE'] = {r=240/255,g=66/255,b=37/255}
PowerBarColorCustom['ENERGY'] = {r=240/255,g=200/255,b=37/255}
PowerBarColorCustom['LUNAR'] = {r=130/255,g=172/255,b=230/255}
PowerBarColorCustom['RUNIC_POWER'] = {r=37/255,g=214/255,b=240/255}
PowerBarColorCustom['FOCUS'] = {r=240/255,g=121/255,b=37/255}
PowerBarColorCustom['FURY'] = {r=166/255,g=37/255,b=240/255}


FACTION_BAR_COLORS = {
    [1] = {r = 0.8, g = 0.3, b = 0.22},
    [2] = {r = 0.8, g = 0.3, b = 0.22},
    [3] = {r = 0.75, g = 0.27, b = 0},
    [4] = {r = 0.9, g = 0.7, b = 0},
    [5] = {r = 0, g = 0.6, b = 0.1},
    [6] = {r = 0, g = 0.6, b = 0.1},
    [7] = {r = 0, g = 0.6, b = 0.1},
    [8] = {r = 0, g = 0.6, b = 0.1},
};


GW_COLOR_FRIENDLY = {
    [1] = {r = 88/255, g=170/255,b=68/255 },
    [2] = {r = 159/255, g=36/255,b=20/255 },
    [3] = { r= 159/255,g=159/255,b=159/255 }
    
}

bloodSpark ={}


bloodSpark[1] = {left=0,right=0.125,top=0,bottom=0.5}
bloodSpark[2] = {left=0.125,right=0.125*2,top=0,bottom=0.5}
bloodSpark[3] = {left=0.125*2,right=0.125*3,top=0,bottom=0.5}
bloodSpark[4] = {left=0.125*3,right=0.125*4,top=0,bottom=0.5}
bloodSpark[5] = {left=0.125*4,right=0.125*5,top=0,bottom=0.5}
bloodSpark[6] = {left=0.125*5,right=0.125*6,top=0,bottom=0.5}
bloodSpark[7] = {left=0.125*6,right=0.125*7,top=0,bottom=0.5}
bloodSpark[8] = {left=0.125*7,right=0.125*8,top=0,bottom=0.5}


bloodSpark[9] = {left=0,right=0.125,top=0.5,bottom=1}
bloodSpark[10] = {left=0.125,right=0.125*2,top=0.5,bottom=1}
bloodSpark[11] = {left=0.125*2,right=0.125*3,top=0.5,bottom=1}
bloodSpark[12] = {left=0.125*3,right=0.125*4,top=0.5,bottom=1}
bloodSpark[13] = {left=0.125*4,right=0.125*5,top=0.5,bottom=1}
bloodSpark[14] = {left=0.125*5,right=0.125*6,top=0.5,bottom=1}
bloodSpark[15] = {left=0.125*6,right=0.125*7,top=0.5,bottom=1}
bloodSpark[16] = {left=0.125*7,right=0.125*8,top=0.5,bottom=1}

bloodSpark[17] = {left=0,right=0.125,top=0,bottom=0.5}
bloodSpark[18] = {left=0.125,right=0.125*2,top=0,bottom=0.5}
bloodSpark[19] = {left=0.125*2,right=0.125*3,top=0,bottom=0.5}
bloodSpark[20] = {left=0.125*3,right=0.125*4,top=0,bottom=0.5}
bloodSpark[21] = {left=0.125*4,right=0.125*5,top=0,bottom=0.5}
bloodSpark[22] = {left=0.125*5,right=0.125*6,top=0,bottom=0.5}
bloodSpark[23] = {left=0.125*6,right=0.125*7,top=0,bottom=0.5}
bloodSpark[24] = {left=0.125*7,right=0.125*8,top=0,bottom=0.5}

          

    

GW_TARGET_FRAME_ART = {
    
    ['minus'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetshadow',
    ['minus'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetshadow',
    ['normal'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetshadow',
    ['elite'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit',
    ['worldboss'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit',
    ['rare'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare',
    ['rareelite'] = 'Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare',
}

oldExp =0;
gainExpStart =0;
gainExpEnd=0;
newExp = 0
lerpRunning = false

function createButton(p,w,h,xo,yo,texture,sub)
    local f = CreateFrame("Button",nil,UIParent)
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(w) -- Set these to whatever height/width is needed 
    f:SetHeight(h) -- for your Texture

    local t = f:CreateTexture(nil,"BACKGROUND",UIParent,sub)
    t:SetTexture(texture)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint(p,xo,yo)
    f:Show()
    return f, t
end

function createBackground(p,w,h,xo,yo,texture,sub)
    local f = CreateFrame("frame",nil,UIParent)
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(w) -- Set these to whatever height/width is needed 
    f:SetHeight(h) -- for your Texture

    local t = f:CreateTexture(nil,"BACKGROUND",UIParent,sub)
    t:SetTexture(texture)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint(p,xo,yo)
    f:Show()
    return f, t
end
function createWindow(p,w,h,xo,yo,texture,sub)
    local f = CreateFrame("frame",nil,UIParent)
    f:SetFrameStrata("DIALOG")
    f:SetWidth(w) -- Set these to whatever height/width is needed 
    f:SetHeight(h) -- for your Texture

    local t = f:CreateTexture(nil,"DIALOG",UIParent,sub)
    t:SetTexture(texture)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint(p,xo,yo)
    f:Show()
    return f, t
end
function createWindowName(p,w,h,xo,yo,texture,sub,n)
    local f = CreateFrame("frame",n,UIParent)
    f:SetFrameStrata("DIALOG")
    f:SetWidth(w) -- Set these to whatever height/width is needed 
    f:SetHeight(h) -- for your Texture

    local t = f:CreateTexture(nil,"DIALOG",UIParent,sub)
    t:SetTexture(texture)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint(p,xo,yo)
    f:Show()
    return f, t
end

function createBackgroundName(p,w,h,xo,yo,texture,sub,n)
    local  f 
    if _G[n]~=nil then
        f = _G[n]
    else
        f = CreateFrame("frame",n,UIParent)
    end
    
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(w) -- Set these to whatever height/width is needed 
    f:SetHeight(h) -- for your Texture

    local t
    if _G[n..'Texture']~=nil then
        t = _G[n..'Texture']
    else
        t = f:CreateTexture(n..'Texture',"BACKGROUND",UIParent,sub)
    end
    t:SetTexture(texture)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint(p,xo,yo)
    f:Show()
    return f, t
end

function setBackDrop(n,p)

    f = CreateFrame("frame",n..'Backdrop',_G[p])
    --f:SetScale(1.5)
    f:SetFrameStrata("LOW")
    f:SetWidth( _G[n]:GetWidth()+2) 
    f:SetHeight(_G[n]:GetHeight()+2)
    t = f:CreateTexture(n..'BackdropTexture',"BACKGROUND",f,0)
    t:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\spelliconempty')
    
    f:SetPoint('CENTER',_G[n],'CENTER',0,0)
    t:SetAllPoints(f)
    t:SetDrawLayer("BACKGROUND", 0)
    f.texture = t
  f:SetFrameStrata("LOW")
    f:SetParent(p)
    f:Show()
end
function setOverlay(n,p)

    f = CreateFrame("frame",n..'Overlay',_G[p])
    --f:SetScale(1.5)
    f:SetFrameStrata("MEDIUM")
    f:SetWidth( _G[n]:GetWidth()) 
    f:SetHeight(_G[n]:GetHeight())
    t = f:CreateTexture(n..'OverlayTexture',"OVERLAY",f,0)
    t:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\spellIconOverlay')
    
    
    f:SetPoint('CENTER',_G[n],'CENTER',0,0)
    t:SetAllPoints(f)
    t:SetDrawLayer("OVERLAY", 1)
    t:SetBlendMode("MOD")
    f.texture = t
    f:SetFrameStrata("MEDIUM")
    f:SetParent(p)
    f:Show()
end

experiencebarAnimation = 0




function loadHudArt()
    
    
    local hudArtFrame =  CreateFrame('Frame', 'GwHudArtFrame',UIParent,'GwHudArtFrame');
    local GwHudArtFrameRepair =  CreateFrame('Frame', 'GwHudArtFrameRepair',UIParent,'GwRepair');
    
    _G['GwHudArtFrameRepair']:SetScript('OnEvent',update_repair_data)
    
    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript('OnShow',function(self) self:Hide() end)
    DurabilityFrame:Hide()
    _G['GwHudArtFrameRepair']:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    
    update_repair_data()
    
   _G['GwHudArtFrameRepair']:SetScript('OnEnter', function() GameTooltip:SetOwner(_G['GwHudArtFrameRepair'], "ANCHOR_CURSOR"); GameTooltip:ClearLines();
            
    GameTooltip:AddLine('Damaged or broken equipment',1,1,1)
            
    GameTooltip:Show() end)
    _G['GwHudArtFrameRepair']:SetScript('OnLeave', function() GameTooltip:Hide() end)
    
    
    hudArtFrame:SetScript('OnEvent',function(self,event,unit)

        if event=='UNIT_AURA' and unit=='player' then
            select_actionhud_bg()
            return
        end
            
        if event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then
                select_actionhud_bg()
            return
        end
         if event=='UNIT_HEALTH' or event=='UNIT_MAX_HEALTH' and unit=='player' then
                combat_hud_healthstate()
            return
        end
            
        
            
            
    end)
    
    hudArtFrame:RegisterEvent("UNIT_AURA");
    hudArtFrame:RegisterEvent("PLAYER_ALIVE");
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
    hudArtFrame:RegisterEvent("UNIT_HEALTH");
    hudArtFrame:RegisterEvent("UNIT_MAX_HEALTH");
    select_actionhud_bg()
    combat_hud_healthstate()
    
end



function update_repair_data()  
   
   local needRepair = false
    local gearBroken = false;
    for i=1,23 do
       local current, maximum = GetInventoryItemDurability(i);
        if current ~=nil then
            dur = current/maximum
            if dur < 0.5 then
                needRepair = true
            end
            if dur==0 then
                gearBroken = true
            end
        end
    end
    
    if gearBroken then
        _G['GwHudArtFrameRepairTexture']:SetTexCoord(0,1,0.5,1)
    else
        _G['GwHudArtFrameRepairTexture']:SetTexCoord(0,1,0,0.5)
    end
    
    
    if needRepair then
        _G['GwHudArtFrameRepair']:Show()
    else
        _G['GwHudArtFrameRepair']:Hide()
    end
end



function loadExperienceBar()
    

local experiencebar =  CreateFrame('Frame', 'GwExperienceFrame',UIParent,'GwExperienceBar');
local eName = experiencebar:GetName()
    
      experiencebarAnimation = UnitXP('Player')/UnitXPMax('Player')
    
    _G['GwExperienceFrameArtifactBar'].artifactBarAnimation = 0
    _G['GwExperienceFrameNextLevel']:SetFont(UNIT_NAME_FONT,12)
    _G['GwExperienceFrameCurrentLevel']:SetFont(UNIT_NAME_FONT,12)
    
    update_experiencebar_size()
    update_experiencebar_data()
    
    experiencebar:SetScript('OnEvent',update_experiencebar_data)
    experiencebar:RegisterEvent('PLAYER_XP_UPDATE')
    experiencebar:RegisterEvent("UPDATE_FACTION");
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    experiencebar:RegisterEvent("ARTIFACT_XP_UPDATE");
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING");
    
    
    experiencebar:SetScript('OnEnter',  show_experiencebar_tooltip)
    experiencebar:SetScript('OnLeave', function() GameTooltip:Hide()
            UIFrameFadeIn(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(),1)
            UIFrameFadeIn(_G['GwExperienceFrameArtifactBar'], 0.2, _G['GwExperienceFrameArtifactBar']:GetAlpha(),1)
    end)
    
  
    
    
    
    
end

function show_experiencebar_tooltip()
    
    local valCurrent = UnitXP('Player')
    local valMax = UnitXPMax('Player')
    local tooltipText = 'Experience '..comma_value(valCurrent).." / "..comma_value(valMax)..'  ('..math.floor((valCurrent/valMax)*100) ..'%)'
    local rested = GetXPExhaustion()
    if rested~=nil then
         GameTooltip:AddLine('Rested '..comma_value(rested)..'  ('..math.floor((rested/valMax)*100)..'%)',1,1,1)
    end
    
    
    UIFrameFadeOut(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(),0)
    UIFrameFadeOut(_G['GwExperienceFrameArtifactBar'], 0.2, _G['GwExperienceFrameArtifactBar']:GetAlpha(),0)
    
    local showArtifact = HasArtifactEquipped()
    
    if showArtifact then
        
        numPoints, artifactXP, xpForNextPoint =gw_artifact_points()
      
        local artifactVal = artifactXP/xpForNextPoint
        
        
        GameTooltip:AddLine('\nArtifact: '..artifactXP..' / '..xpForNextPoint,1,1,1)
    end
    
    GameTooltip:SetOwner(_G['GwExperienceFrame'], "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    GameTooltip:AddLine('Experience',1,1,1)
    GameTooltip:AddLine(tooltipText,1,1,1)
  
    GameTooltip:Show() 
end


function gw_artifact_points()
    
    local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetEquippedArtifactInfo();
    
    local numPoints = 0;
	local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent);
	while totalXP >= xpForNextPoint and xpForNextPoint > 0 do
		totalXP = totalXP - xpForNextPoint;

		pointsSpent = pointsSpent + 1;
		numPoints = numPoints + 1;

		xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent);
	end
	return numPoints, totalXP, xpForNextPoint;
    
end

function update_experiencebar_data(self,event)
    
    if event=='PLAYER_UPDATE_RESTING' then
            if IsResting() then
              
            end
        return
    end
    
    local showArtifact = HasArtifactEquipped()
    
    local valCurrent = UnitXP('Player')
    local valMax = UnitXPMax('Player')
    local valPrec = valCurrent/valMax;
    
    local level = UnitLevel('Player')
    local Nextlevel = math.min(GetMaxPlayerLevel(), UnitLevel('Player') +1)
    local rested = GetXPExhaustion()
    local showBar1 = false
    local showBar2 = false

    if rested==nil then
        rested = 0
    end
    rested = rested / valMax
    
    if level<Nextlevel then
        showBar1 = true
    end
    
    local dif = 5
    
    
    ReputationWatchBar:Hide()
    if level==Nextlevel  then
        for factionIndex = 1, GetNumFactions() do
            name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
            canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
            if isWatched == true then
                local name, reaction, min, max, value, factionID = GetWatchedFactionInfo();
                local nextId = standingId+1
                if nextId==nil then
                    nextId = standingId
                end
                level = getglobal("FACTION_STANDING_LABEL"..standingId)

                Nextlevel = getglobal("FACTION_STANDING_LABEL"..nextId)
                valPrec = (earnedValue - bottomValue) / (topValue - bottomValue)
                showBar1 = true
                _G['GwExperienceFrameBar']:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r,FACTION_BAR_COLORS[reaction].g,FACTION_BAR_COLORS[reaction].b)
            end
        end
    end
    
    
    if showArtifact then
             
        showBar2 = true
        numPoints, artifactXP, xpForNextPoint =gw_artifact_points()
        local artifactVal = artifactXP/xpForNextPoint
        
        artifactVal = 0.52
        _G['GwExperienceFrameArtifactBarCandy']:SetValue(artifactVal)
      
        addToAnimation('artifactBarAnimation',_G['GwExperienceFrameArtifactBar'].artifactBarAnimation,artifactVal,GetTime(),dif,function()
            
                ArtifactBarSpark:SetWidth(math.max(8,math.min(9, _G['GwExperienceFrameArtifactBar']:GetWidth()*animations['artifactBarAnimation']['progress']) ))
            
                _G['GwExperienceFrameArtifactBar']:SetValue(animations['artifactBarAnimation']['progress'])
                ArtifactBarSpark:SetPoint('LEFT', _G['GwExperienceFrameArtifactBar']:GetWidth()*animations['artifactBarAnimation']['progress'] -8,0)
           
        end)
        
  
    end
    
    

    

    
    addToAnimation('experiencebarAnimation',experiencebarAnimation,valPrec,GetTime(),dif,function()
            
            ExperienceBarSpark:SetWidth(math.max(8,math.min(9, _G['GwExperienceFrameBar']:GetWidth()*animations['experiencebarAnimation']['progress']) ))
            
            _G['GwExperienceFrameBar']:SetValue(animations['experiencebarAnimation']['progress'])
           
            _G['GwExperienceFrameBarRested']:SetValue(rested)
            _G['GwExperienceFrameBarRested']:SetPoint('LEFT',_G['GwExperienceFrameBar'],'LEFT',_G['GwExperienceFrameBar']:GetWidth()*animations['experiencebarAnimation']['progress'],0 )
      
            ExperienceBarSpark:SetPoint('LEFT', _G['GwExperienceFrameBar']:GetWidth()*animations['experiencebarAnimation']['progress'] -8,0)
           
    end)
    experiencebarAnimation =valPrec
    
    
    _G['GwExperienceFrameNextLevel']:SetText(Nextlevel);
    _G['GwExperienceFrameCurrentLevel']:SetText(level);
        if showBar1 and not showBar2 then
        _G['GwExperienceFrameBar']:SetHeight(8)
        _G['GwExperienceFrameBarCandy']:SetHeight(8)
        _G['ExperienceBarSpark']:SetHeight(8) 
             
    end
    
    if showBar1 and showBar2 then
        _G['GwExperienceFrameBar']:SetHeight(4)
        _G['GwExperienceFrameBarCandy']:SetHeight(4)
        _G['ExperienceBarSpark']:SetHeight(4)
        
        
        _G['GwExperienceFrameArtifactBar']:SetHeight(4)
        _G['ArtifactBarSpark']:SetHeight(4)
         ArtifactBarSpark:Show()
    end
    
    if not showBar2 then
        _G['GwExperienceFrameArtifactBar']:SetValue(0)
        _G['GwExperienceFrameArtifactBarCandy']:SetValue(0)
        _G['GwExperienceFrameArtifactBarCandy']:SetValue(0)
        ArtifactBarSpark:Hide()
    end
    if  showBar1 then
        ExperienceBarSpark:Show()
        _G['GwExperienceFrameBar']:Show()
        _G['GwExperienceFrameBarCandy']:Show()
    end 
    if not showBar1 then
        _G['GwExperienceFrameBar']:Hide()
        _G['GwExperienceFrameBarCandy']:Hide()
        _G['GwExperienceFrameBar']:SetValue(0)
        _G['GwExperienceFrameBarCandy']:SetValue(0)
        ExperienceBarSpark:Hide()
    end 
       
    
    _G['GwExperienceFrameBarCandy']:SetValue(valPrec)
    
    if experiencebarAnimation>valPrec then
        experiencebarAnimation = 0
    end
    
    
end

function update_experiencebar_size()
    local m = (UIParent:GetWidth()-128)  / 10
    for i=1,9 do
        local rm = (m*i) +64 
        _G['barsep'..i]:ClearAllPoints()
        _G['barsep'..i]:SetPoint('LEFT','GwExperienceFrame','LEFT',rm ,0);
    end
    
    local m = (UIParent:GetWidth()-128) 
    dubbleBarSep:SetWidth(m)
    dubbleBarSep:ClearAllPoints()
    dubbleBarSep:SetPoint('LEFT','GwExperienceFrame','LEFT',64,0);
end

action_hud_auras = {}

function registerActionHudAura(aura,left,right)
    local i = countTable(action_hud_auras)
    action_hud_auras[i] = {}
    action_hud_auras[i]['aura'] = aura
    action_hud_auras[i]['left'] = left
    action_hud_auras[i]['right'] = right
end
local currentTexture = nil
function select_actionhud_bg()
    if not gwGetSetting('HUD_SPELL_SWAP') then return end
    local right = 'Interface\\AddOns\\GW2_UI\\textures\\rightshadow';
    local left = 'Interface\\AddOns\\GW2_UI\\textures\\leftshadow';
    
    if UnitIsDeadOrGhost("player") then
        right = 'Interface\\AddOns\\GW2_UI\\textures\\rightshadow_dead';
        left = 'Interface\\AddOns\\GW2_UI\\textures\\leftshadow_dead';
    end
    
    if UnitAffectingCombat('player') then
         right = 'Interface\\AddOns\\GW2_UI\\textures\\rightshadowcombat';
         left = 'Interface\\AddOns\\GW2_UI\\textures\\leftshadowcombat';
    end
    
    for k,v in pairs(action_hud_auras) do
       if UnitAura('player',action_hud_auras[k]['aura']) then
            left=action_hud_auras[k]['left']
            right=action_hud_auras[k]['right']
        end
    end
    if currentTexture~=left then
        currentTexture = left
        _G['GwActionBarHudLEFT']:SetTexture(left)
        _G['GwActionBarHudRIGHT']:SetTexture(right)
    end
end


function combat_hud_healthstate()
    
    local unitHealthPrecentage = UnitHealth('player')/UnitHealthMax('player')
    
     if unitHealthPrecentage<0.5 and not  UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5;
            
        _G['GwActionBarHudLEFT']:SetVertexColor(1,unitHealthPrecentage  ,unitHealthPrecentage  );
        _G['GwActionBarHudRIGHT']:SetVertexColor(1,unitHealthPrecentage  ,unitHealthPrecentage  );
        
   
        _G['GwActionBarHudRIGHTSWIM']:SetVertexColor(1,unitHealthPrecentage  ,unitHealthPrecentage  );
        _G['GwActionBarHudLEFTSWIM']:SetVertexColor(1,unitHealthPrecentage  ,unitHealthPrecentage  );
            
        _G['GwActionBarHudLEFTBLOOD']:SetVertexColor(1,1,1,1-(unitHealthPrecentage-0.2))
        _G['GwActionBarHudRIGHTBLOOD']:SetVertexColor(1,1,1,1-(unitHealthPrecentage-0.2))
    else
       
        
        _G['GwActionBarHudLEFT']:SetVertexColor(1,1,1);
        _G['GwActionBarHudRIGHT']:SetVertexColor(1,1,1);
           
           
        _G['GwActionBarHudRIGHTSWIM']:SetVertexColor(1,1,1);
        _G['GwActionBarHudLEFTSWIM']:SetVertexColor(1,1,1);
        
        _G['GwActionBarHudLEFTBLOOD']:SetVertexColor(1,1,1,0)
        _G['GwActionBarHudRIGHTBLOOD']:SetVertexColor(1,1,1,0)
        
    end
end

registerActionHudAura('Avenging Wrath','Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy','Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy')
registerActionHudAura('Rapid Fire','Interface\\AddOns\\GW2_UI\\textures\\leftshadow_leafs','Interface\\AddOns\\GW2_UI\\textures\\rightshadow_leafs')
registerActionHudAura('Bear Form','Interface\\AddOns\\GW2_UI\\textures\\leftshadow_bear','Interface\\AddOns\\GW2_UI\\textures\\rightshadow_bear')
registerActionHudAura('Cat Form','Interface\\AddOns\\GW2_UI\\textures\\leftshadow_cat','Interface\\AddOns\\GW2_UI\\textures\\rightshadow_cat')


function gw_breath_meter()
    CreateFrame('Frame','GwBreathMeter',UIParent,'GwBreathMeter')
    GwBreathMeter:Hide()
    GwBreathMeter:SetScript('OnShow', function()
         UIFrameFadeIn(GwBreathMeter, 0.2,GwBreathMeter:GetAlpha(),1)
    end)
    MirrorTimer1:SetScript('OnShow',function(self) self:Hide() end)
    MirrorTimer1:UnregisterAllEvents()
 
    
    GwBreathMeter:RegisterEvent('MIRROR_TIMER_START')
    GwBreathMeter:RegisterEvent('MIRROR_TIMER_STOP')
    
    GwBreathMeter:SetScript('OnEvent', function(self,event,arg1,arg2,arg3,arg4)
        
        if event=='MIRROR_TIMER_START' then
                
            local texture = 'Interface\\AddOns\\GW2_UI\\textures\\castingbar'
                if arg1=='BREATH' then
                    texture = 'Interface\\AddOns\\GW2_UI\\textures\\breathmeter'
                end
            GwBreathMeterBar:SetStatusBarTexture(texture)
            GwBreathMeterBar:SetMinMaxValues(0,arg3)
            GwBreathMeterBar:SetScript('OnUpdate', function() GwBreathMeterBar:SetValue( GetMirrorTimerProgress(arg1)) end)
            GwBreathMeter:Show()
        end
        if event=='MIRROR_TIMER_STOP' then
            GwBreathMeterBar:SetScript('OnUpdate', nil)
            GwBreathMeter:Hide()
        end
        
    end)

end


local microButtonFrame = CreateFrame('Frame', 'GwMicroButtonFrame', UIParent,'GwMicroButtonFrame')

local microButtonPadding = 4 +12

function create_micro_button(key)
    local mf = CreateFrame('Button', 'GwMicroButton'..key, GwMicroButtonFrame,'GwMicroButtonTemplate')
    mf:SetPoint('CENTER',GwMicroButtonFrame,'TOPLEFT',microButtonPadding,-16);
    microButtonPadding = microButtonPadding + 24 + 4
    
   mf:SetDisabledTexture('Interface\\AddOns\\GW2_UI\\textures\\'..key..'-Up'); 
   mf:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\'..key..'-Up'); 
   mf:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\'..key..'-Down'); 
   mf:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\'..key..'-Down'); 

    _G['GwMicroButton'..key..'String']:SetFont(DAMAGE_TEXT_FONT,12)
    _G['GwMicroButton'..key..'String']:SetShadowColor(0,0,0,0)
    
     _G['GwMicroButton'..key..'Texture']:Hide()
     _G['GwMicroButton'..key..'String']:Hide()
    
    
    return mf
end

local CUSTOM_MICRO_BUTTONS={}
local gw_latencyToolTipUpdate = 0
local gw_frameRate = 0

local GW_BAG_MICROBUTTON_STRING = 'Inventory'

function create_micro_menu()
    
    

    local mi = 1
    for k,v in pairs(MICRO_BUTTONS) do 

        CUSTOM_MICRO_BUTTONS[mi] = v
        if v=='CharacterMicroButton' then
            mi = mi+1
            CUSTOM_MICRO_BUTTONS[mi] = 'BagMicroButton'
        end
        mi = mi +1
    end

    
    for k,v in pairs(CUSTOM_MICRO_BUTTONS) do   
        create_micro_button(v)
    end
    
    GwMicroButtonCharacterMicroButton:SetScript('OnMouseDown',function()  ToggleCharacter("PaperDollFrame"); gw_UpdateMicroButtons() end);
    
    GwMicroButtonBagMicroButton:SetScript('OnMouseDown',function()  ToggleAllBags(); gw_UpdateMicroButtons() end);
    
    GwMicroButtonSpellbookMicroButton:SetScript('OnMouseDown',function()  ToggleSpellBook(BOOKTYPE_SPELL); gw_UpdateMicroButtons() end);
    GwMicroButtonTalentMicroButton:SetScript('OnMouseDown',function()  ToggleTalentFrame(); gw_UpdateMicroButtons() end);
    GwMicroButtonAchievementMicroButton:SetScript('OnMouseDown',function()  ToggleAchievementFrame(); gw_UpdateMicroButtons() end);
    GwMicroButtonQuestLogMicroButton:SetScript('OnMouseDown',function()  ToggleQuestLog(); gw_UpdateMicroButtons() end);
  
    GwMicroButtonGuildMicroButton:SetScript('OnMouseDown',function()  ToggleGuildFrame(); gw_UpdateMicroButtons() end);
    
    GwMicroButtonLFDMicroButton:SetScript('OnMouseDown',function()  PVEFrame_ToggleFrame(); gw_UpdateMicroButtons() end);
    
    GwMicroButtonCollectionsMicroButton:SetScript('OnMouseDown',function()  ToggleCollectionsJournal(); gw_UpdateMicroButtons() end);
    
    GwMicroButtonEJMicroButton:SetScript('OnMouseDown',function() ToggleEncounterJournal()  gw_UpdateMicroButtons() end);
    
     GwMicroButtonMainMenuMicroButton:SetScript('OnMouseDown',function() ToggleGameMenuFrame()  gw_UpdateMicroButtons() end);
    
     GwMicroButtonHelpMicroButton:SetScript('OnMouseDown',function() ToggleHelpFrame()  gw_UpdateMicroButtons() end);
     GwMicroButtonStoreMicroButton:SetScript('OnMouseDown',function() ToggleStoreUI()  gw_UpdateMicroButtons() end);
    
  
    
    
    
    GwMicroButtonTalentMicroButton:SetScript('OnEvent',gw_update_talentMicrobar)
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_LEVEL_UP");
    GwMicroButtonTalentMicroButton:RegisterEvent("UPDATE_BINDINGS");
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_TALENT_UPDATE");
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED");
    
    
--    gw_microButtonHookToolTip(GwMicroButtonCharacterMicroButton,'','')
    
    gw_microButtonHookToolTip(GwMicroButtonCharacterMicroButton,CHARACTER_BUTTON,'TOGGLECHARACTER0"')
    gw_microButtonHookToolTip(GwMicroButtonBagMicroButton,GW_BAG_MICROBUTTON_STRING,'OPENALLBAGS')
    gw_microButtonHookToolTip(GwMicroButtonSpellbookMicroButton,GW_BAG_MICROBUTTON_STRING,'TOGGLESPELLBOOK')
    gw_microButtonHookToolTip(GwMicroButtonTalentMicroButton,TALENTS_BUTTON,'TOGGLETALENTS')
    gw_microButtonHookToolTip(GwMicroButtonAchievementMicroButton,ACHIEVEMENT_BUTTON,'TOGGLEACHIEVEMENT')
    gw_microButtonHookToolTip(GwMicroButtonQuestLogMicroButton,QUESTLOG_BUTTON,'TOGGLEQUESTLOG')
    gw_microButtonHookToolTip(GwMicroButtonGuildMicroButton,GUILD,'TOGGLEGUILDTAB')
    gw_microButtonHookToolTip(GwMicroButtonLFDMicroButton,DUNGEONS_BUTTON,'TOGGLEGROUPFINDER')
    gw_microButtonHookToolTip(GwMicroButtonCollectionsMicroButton,COLLECTIONS,'TOGGLECOLLECTIONS')

    gw_microButtonHookToolTip(GwMicroButtonEJMicroButton,ADVENTURE_JOURNAL,'TOGGLEENCOUNTERJOURNAL')
    gw_microButtonHookToolTip(GwMicroButtonHelpMicroButton,HELP_BUTTON,'')

    
    
    
    GwMicroButtonMainMenuMicroButton:SetScript('OnEnter', function() 
        
        GwMicroButtonMainMenuMicroButton:SetScript('OnUpdate',gw_latencyInfoToolTip)    
        GameTooltip:SetOwner(GwMicroButtonMainMenuMicroButton, "ANCHOR_CURSOR",0,ANCHOR_BOTTOMLEFT); 
  
    end)
    
     GwMicroButtonMainMenuMicroButton:SetScript('OnLeave', function() 
        GwMicroButtonMainMenuMicroButton:SetScript('OnUpdate',nil)
        GameTooltip:Hide()
    end)
    
    
    gw_update_talentMicrobar()
end


function gw_microButtonHookToolTip(frame,text,action)
    
    frame:SetScript('OnEnter', function() 

       gw_setToolTipForShow(frame,text,action)
       gw_setToolTipForShow(frame,text,action)
      end)
    frame:SetScript('OnLeave', function() 
        GameTooltip:Hide()
    end)
    
end

function gw_setToolTipForShow(frame,text,action)
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT",16 + (GameTooltip:GetWidth()/2),-10); 
    GameTooltip:ClearLines();
    GameTooltip:AddLine(gw_getMicroButtonToolTip(text,action),1,1,1)
    GameTooltip:Show()
end

function gw_getMicroButtonToolTip(text,action)
   	if ( GetBindingKey(action) ) then
		return text.." |cffa6a6a6("..GetBindingText(GetBindingKey(action))..")"..FONT_COLOR_CODE_CLOSE;
	else
		return text;
	end 
end

function gw_latencyInfoToolTip()

    if gw_latencyToolTipUpdate>GetTime() then return end
    gw_latencyToolTipUpdate = GetTime() + 0.5
    
    gw_frameRate = intRound(GetFramerate());
    local down, up, lagHome, lagWorld = GetNetStats();
   
    GameTooltip:SetOwner(GwMicroButtonMainMenuMicroButton, "ANCHOR_BOTTOMLEFT",16 + (GameTooltip:GetWidth()/2),-10); 
    GameTooltip:ClearLines();
    GameTooltip:AddLine(MAINMENU_BUTTON,1,1,1)
    GameTooltip:AddLine('FPS '..gw_frameRate,0.8,0.8,0.8)
    GameTooltip:AddLine('Latency (Home) '..lagHome,0.8,0.8,0.8)
    GameTooltip:AddLine('Latency (World) '..lagWorld,0.8,0.8,0.8)
    
    GameTooltip:Show()
  
    
end


function gw_update_talentMicrobar()
    
    if GetNumUnspentTalents() > 0 then
        _G['GwMicroButtonTalentMicroButtonTexture']:Show()
        _G['GwMicroButtonTalentMicroButtonString']:Show()
        _G['GwMicroButtonTalentMicroButtonString']:SetText(GetNumUnspentTalents())
    else
        _G['GwMicroButtonTalentMicroButtonTexture']:Hide()
        _G['GwMicroButtonTalentMicroButtonString']:Hide()
    end
    
    hooksecurefunc('UpdateMicroButtons',gw_UpdateMicroButtons)
        
end

function gw_UpdateMicroButtons()
    
   if ( CharacterFrame and CharacterFrame:IsShown() ) then
		_G['GwMicroButtonCharacterMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonCharacterMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( GwBagFrame and GwBagFrame:IsShown() ) then
		_G['GwMicroButtonBagMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonBagMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( SpellBookFrame and SpellBookFrame:IsShown() ) then
		_G['GwMicroButtonSpellbookMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonSpellbookMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() ) then
		_G['GwMicroButtonTalentMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonTalentMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( AchievementFrame and AchievementFrame:IsShown() ) then
		_G['GwMicroButtonAchievementMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonAchievementMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( WorldMapFrame and WorldMapFrame:IsShown() ) then
		_G['GwMicroButtonQuestLogMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonQuestLogMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( GuildFrame and GuildFrame:IsShown() ) then
		_G['GwMicroButtonGuildMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonGuildMicroButton']:SetButtonState("NORMAL");
    end
    
      if ( PVEFrame and PVEFrame:IsShown() ) then
		_G['GwMicroButtonLFDMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonLFDMicroButton']:SetButtonState("NORMAL");
    end
    
    if ( EncounterJournal and EncounterJournal:IsShown() ) then
		_G['GwMicroButtonEJMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonEJMicroButton']:SetButtonState("NORMAL");
    end
    if ( CollectionsJournal and CollectionsJournal:IsShown() ) then
		_G['GwMicroButtonCollectionsMicroButton']:SetButtonState("PUSHED", true);
	else
		_G['GwMicroButtonCollectionsMicroButton']:SetButtonState("NORMAL");
    end
    
end



function ToggleGameMenuFrame()
    if  GameMenuFrame:IsShown() then
        GameMenuFrame:Hide()
        return
    end
    GameMenuFrame:Show()
end






