PowerBarColorCustom = {};
PowerBarColorCustom["MANA"] = { r = 0, g = 0.5058823529411765, b = 1 };
PowerBarColorCustom["RAGE"] = { r = 1.00, g = 0.00, b = 0.00 };
PowerBarColorCustom["FOCUS"] = { r = 1.00, g = 0.50, b = 0.25 };
PowerBarColorCustom["ENERGY"] = { r = 1.00, g = 1.00, b = 0.00 };
PowerBarColorCustom["CHI"] = { r = 0.71, g = 1.0, b = 0.92 };
PowerBarColorCustom["RUNES"] = { r = 0.50, g = 0.50, b = 0.50 };
PowerBarColorCustom["RUNIC_POWER"] = { r = 0.00, g = 0.82, b = 1.00 };
PowerBarColorCustom["SOUL_SHARDS"] = { r = 0.50, g = 0.32, b = 0.55 };
PowerBarColorCustom["ECLIPSE"] = { negative = { r = 0.30, g = 0.52, b = 0.90 },  positive = { r = 0.80, g = 0.82, b = 0.60 }};
PowerBarColorCustom["HOLY_POWER"] = { r = 0.95, g = 0.90, b = 0.60 };
-- vehicle colors
PowerBarColorCustom["AMMOSLOT"] = { r = 0.80, g = 0.60, b = 0.00 };
PowerBarColorCustom["FUEL"] = { r = 0.0, g = 0.55, b = 0.5 };
PowerBarColorCustom["STAGGER"] = { {r = 0.52, g = 1.0, b = 0.52}, {r = 1.0, g = 0.98, b = 0.72}, {r = 1.0, g = 0.42, b = 0.42},};
 
-- these are mostly needed for a fallback case (in case the code tries to index a power token that is missing from the table,
-- it will try to index by power type instead)
PowerBarColorCustom[0] = PowerBarColorCustom["MANA"];
PowerBarColorCustom[1] = PowerBarColorCustom["RAGE"];
PowerBarColorCustom[2] = PowerBarColorCustom["FOCUS"];
PowerBarColorCustom[3] = PowerBarColorCustom["ENERGY"];
PowerBarColorCustom[4] = PowerBarColorCustom["CHI"]; 
PowerBarColorCustom[5] = PowerBarColorCustom["RUNES"];
PowerBarColorCustom[6] = PowerBarColorCustom["RUNIC_POWER"];
PowerBarColorCustom[7] = PowerBarColorCustom["SOUL_SHARDS"];
PowerBarColorCustom[8] = PowerBarColorCustom["ECLIPSE"];
PowerBarColorCustom[9] = PowerBarColorCustom["HOLY_POWER"];


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

 oldExp =UnitXP('player') / UnitXPMax('player');
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


lvllable1, levelablet1 = createBackground('BOTTOMLEFT',60,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\levellable",5)
   clevel = lvllable1:CreateFontString('unitCurrentLevel', "OVERLAY", "GameFontNormal")
    
    clevel:SetTextColor(1,1,1)
    clevel:SetFont(STANDARD_TEXT_FONT,12)

    clevel:SetPoint("RIGHT",lvllable1,'RIGHT',-10,0)
    unitCurrentLevel:SetText(UnitLevel('Player'))

lvllable2, levelablet2 = createBackground('BOTTOMRIGHT',60,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\levellable",5)
nlevel = lvllable2:CreateFontString('unitNextLevel', "OVERLAY", "GameFontNormal")
    
    nlevel:SetTextColor(1,1,1)
    nlevel:SetFont(STANDARD_TEXT_FONT,12)
    nlevel:SetPoint("LEFT",lvllable2,'LEFT',10,0)
    nlevel:SetText(UnitLevel('Player') + 1)
    if UnitLevel('Player') == 100 then
        unitNextLevel:SetText(UnitLevel('Player'))
    end

xpbar, xpbart = createBackground('BOTTOMLEFT',0,16,58,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbar",4)
xpbarCandy, xpbartCandy = createBackground('BOTTOMLEFT',0,16,58,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarCandy",3)
xpbarbg, xpbarbgt  = createBackground('BOTTOM',1800,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarbg",2)
xpbarbg:SetAlpha(0.8)



sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',-6,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',174,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',354,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',534,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',714,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',894,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',1074,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',1254,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',1434,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',1614,0)

sep , sept = createBackground('BOTTOMLEFT',16,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\xpbarsep",5)
sep:SetPoint('BOTTOMLEFT',xpbar,'BOTTOMLEFT',1794,0)




mapShadowBg,mapShadowTexture = createBackground('BOTTOMRIGHT',512,256,3,19,"Interface\\AddOns\\GW2_UI\\textures\\mapshadow",0)


hudShadowLeft,hudShadowLeftTexture = createBackground('BOTTOM',512,256,-256,16,"Interface\\AddOns\\GW2_UI\\textures\\leftshadow",0)
hudShadowRight,hudShadowRightTexture = createBackground('BOTTOM',512,256,256,16,"Interface\\AddOns\\GW2_UI\\textures\\rightshadow",0)

BloodhudShadowLeft,BloodhudShadowLeftTexture = createBackground('BOTTOM',560,280,-280,16,"Interface\\AddOns\\GW2_UI\\textures\\bloodLeft",0)
BloodhudShadowRight,BloodhudShadowRightTexture = createBackground('BOTTOM',560,280,280,16,"Interface\\AddOns\\GW2_UI\\textures\\bloodRight",0)

--createBackground('TOPRIGHT',255.9,280,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questtracker",0)


createBackground('TOP',560,280,-210,0,"Interface\\AddOns\\GW2_UI\\textures\\windowborder",0)
createBackground('TOP',560,280,306.9,0,"Interface\\AddOns\\GW2_UI\\textures\\windowborder",0)

tprf,tprt = createBackground('BOTTOM',560,280,306.9,16,"Interface\\AddOns\\GW2_UI\\textures\\windowborder",0)
tprt:SetTexCoord(0,1,1,0)

tprf,tprt = createBackground('BOTTOM',560,280,-210.9,16,"Interface\\AddOns\\GW2_UI\\textures\\windowborder",0)
tprt:SetTexCoord(0,1,1,0)

tprf,tprt = createBackground('LEFT',280,560,-41.0,0,"Interface\\AddOns\\GW2_UI\\textures\\windowborder",0)
tprt:SetRotation(1.5707963268)

tprf,tprt = createBackground('RIGHT',280,560,41.0,0,"Interface\\AddOns\\GW2_UI\\textures\\windowborder",0)
tprt:SetRotation(-1.5707963268)


createBackground('TOPLEFT',560,280,0,0,"Interface\\AddOns\\GW2_UI\\textures\\windowcornermenu",0)
local tprf,tprt = createBackground('TOPRIGHT',560,280,0,0,"Interface\\AddOns\\GW2_UI\\textures\\windowcorner",1)
    tprt:SetTexCoord(1,0,0,1)

tprf,tprt = createBackground('BOTTOMLEFT',560,280,0,16,"Interface\\AddOns\\GW2_UI\\textures\\windowcorner",0)
    tprt:SetTexCoord(0,1,1,0)

tprf,tprt = createBackground('BOTTOMRIGHT',560,280,0,16,"Interface\\AddOns\\GW2_UI\\textures\\windowcorner",0)
    tprt:SetTexCoord(1,0,1,0)

--SWIM--
tprf,tprt = createBackground('BOTTOM',560,280,-280,16,"Interface\\AddOns\\GW2_UI\\textures\\leftshadowswim",1)

durabilityBg,durabilityTexture = createBackgroundName('BOTTOM',20,20,32,16,"Interface\\AddOns\\GW2_UI\\textures\\repair",3,'durabilityBg')
durabilityBg:SetFrameStrata('HIGH')
tprf:SetAlpha(0)
 tprf:HookScript("OnUpdate", function(self)
       
         if IsSwimming() then 
            self:SetAlpha(1)
            UIFrameFadeIn(self, 1,self:GetAlpha(),1)
        else
            UIFrameFadeOut(self, 1,self:GetAlpha(),0)
        end
        
        local currentHealthPrecentage = UnitHealth('Player')/UnitHealthMax('Player')
        
        
        
       if currentHealthPrecentage<0.5 then
            currentHealthPrecentage = currentHealthPrecentage / 0.5;
            
            hudShadowLeftTexture:SetVertexColor(1,currentHealthPrecentage  ,currentHealthPrecentage  );
            hudShadowRightTexture:SetVertexColor(1,currentHealthPrecentage  ,currentHealthPrecentage  );
            BloodhudShadowLeft:SetAlpha(1-currentHealthPrecentage)
             BloodhudShadowRight:SetAlpha(1-currentHealthPrecentage)
        else
              hudShadowLeftTexture:SetVertexColor(1,1,1);
            hudShadowRightTexture:SetVertexColor(1,1,1);
            BloodhudShadowRight:SetAlpha(0)
             BloodhudShadowLeft:SetAlpha(0)
        end
  
                
                    
    end)

tprf,tprt = createBackground('BOTTOM',560,280,280,16,"Interface\\AddOns\\GW2_UI\\textures\\rightshadowswim",1)
tprf:SetAlpha(0)
 tprf:HookScript("OnUpdate", function(self)
        
        if IsSwimming() then 
            self:SetAlpha(1)
            UIFrameFadeIn(self, 1,self:GetAlpha(),1)
        else
            UIFrameFadeOut(self, 1,self:GetAlpha(),0)
        end
                    
    end)

xpbar:HookScript("OnEvent", function(self)
    ReputationWatchBar:Hide()
       local xppre = UnitXP('player') / UnitXPMax('player')
        xpbart:SetVertexColor(1,1,0)
         unitNextLevel:SetText(UnitLevel('Player') + 1)
        unitCurrentLevel:SetText(UnitLevel('Player'))
    
    if UnitLevel('Player') == 100 then
        unitNextLevel:SetText(UnitLevel('Player'))
       

        for factionIndex = 1, GetNumFactions() do
          name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
            canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
          if isWatched == true then
            local name, reaction, min, max, value, factionID = GetWatchedFactionInfo();
            local nextId = standingId+1
                    if nextId==nil then
                        nextId = standingId
                    end
                    unitCurrentLevel:SetText(getglobal("FACTION_STANDING_LABEL"..standingId))
                    unitNextLevel:SetText(getglobal("FACTION_STANDING_LABEL"..nextId))
                    xppre = (earnedValue - bottomValue) / (topValue - bottomValue)
                    
                    xpbart:SetVertexColor(FACTION_BAR_COLORS[reaction].r,FACTION_BAR_COLORS[reaction].g,FACTION_BAR_COLORS[reaction].b)
                end
            end
         xpbar:SetWidth(1800*xppre)
    end

    if oldExp > xppre then
            if lerpRunning==false then
        oldExp = 0
        end
    end
            
    xpbarCandy:SetWidth(1800*xppre)
   -- xpbar:SetWidth(1800*xppre)
end)




xpbar:HookScript("OnUpdate", function(self)
        
 
        
   if UnitLevel('Player') < 100 then
    

        local xppre = UnitXP('player') / UnitXPMax('player')
     --   if oldExp<xppre then            
     --           gainExpEnd = GetTime() + 2
      --          gainExpStart = GetTime()
      --          oldExp = xppre
     --           print(gainExpStart)
      --          print(gainExpEnd)
      --  end
        if oldExp<xppre then
            if lerpRunning==false then
                    newExp = xppre;
                    lerpRunning = true;
                    gainExpStart = GetTime()
            end
        end

        if lerpRunning then
         --    xppre =   (((GetTime() ) - gainExpStart) / (gainExpEnd - gainExpStart) * 100 )
             xppre =  lerp(oldExp, newExp, (GetTime() - gainExpStart) / 2)
                if xppre>=newExp then
                    lerpRunning = false
                    oldExp = xppre;
                end

        end



        xpbar:SetWidth(1800*xppre)
     end
end)

ReputationWatchBar:HookScript("OnShow", function(self)
        self:Hide()
end)

xpbar:RegisterEvent("PLAYER_ENTERING_WORLD");
xpbar:RegisterEvent("PLAYER_XP_UPDATE");
xpbar:RegisterEvent("UPDATE_FACTION");


hudShadowLeft:SetScript("OnEvent", function(self,event,unit)
        
        if unit=='player' then
            local swap = false
            
            if UnitAffectingCombat('player') then
                swap = true
                hudShadowLeftTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\leftshadowcombat')
                hudShadowRightTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\rightshadowcombat')
            end
            
            if UnitAura('player','Archangel') or UnitAura('player','Avenging Wrath') then
                swap = true
                hudShadowLeftTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy')
                hudShadowRightTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy')
            end
            if UnitAura('player','Rapid Fire') or UnitAura('player','Bestial Wrath')  then
                swap = true
                hudShadowLeftTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\leftshadow_leafs')
                hudShadowRightTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\rightshadow_leafs')
              
            end
            if UnitAura('player','Bear Form')  then
                swap = true
                hudShadowLeftTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\leftshadow_bear')
                hudShadowRightTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\rightshadow_bear')
              
            end
            if UnitAura('player','Cat Form')  then
                swap = true
                hudShadowLeftTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\leftshadow_cat')
                hudShadowRightTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\rightshadow_cat')
              
            end
            
            
             if swap==false then
            
                hudShadowLeftTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\leftshadow')
                hudShadowRightTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\rightshadow')

            end
        end
end)

hudShadowLeft:RegisterEvent("UNIT_AURA");
hudShadowLeft:RegisterEvent("PLAYER_ALIVE");
hudShadowLeft:RegisterEvent("PLAYER_REGEN_DISABLED");
hudShadowLeft:RegisterEvent("PLAYER_REGEN_ENABLED");



gossip = CreateFrame("frame",gossip,UIParent)
gossip:SetScript("OnEvent", function(self,event,unit)
      
        for i = 1,12 do
           if _G['GossipTitleButton'..i] then
                _G['GossipTitleButton'..i]:SetHeight(25)
                _G['GossipTitleButton'..i..'GossipIcon']:ClearAllPoints()
                _G['GossipTitleButton'..i..'GossipIcon']:SetPoint('LEFT',_G['GossipTitleButton'..i],0,0)
              
            end
        end
end)
gossip:RegisterEvent("GOSSIP_SHOW");


durabilityBg:SetScript('OnEvent',function(self,event)
    
        needRepair = false
        for i=1,23 do
            current, maximum = GetInventoryItemDurability(i);
            if current ~=nil then
                dur = current/maximum
                if dur < 0.5 then
                    needRepair = true
                end
            end
        end
        if needRepair then
        self:Show()
        else
            self:Hide()
        end
end)

durabilityBg:RegisterEvent("UPDATE_INVENTORY_DURABILITY");
durabilityBg:RegisterEvent("PLAYER_ENTERING_WORLD");






