

local spellStart = 0
local spellEnd = 0
local casting = 0
local targetOldHealth = 0;

local targetFrame,targetTexture = createBackground('TOP',512,128,300,-200,"Interface\\AddOns\\GW2_UI\\textures\\targetshadow",0)
local targetFrameRare,targetTextureRare = createBackground('TOP',512,128,300,-200,"Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",0)
local targetFrameElite,targetTextureElite = createBackground('TOP',512,128,300,-200,"Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit",0)

targetFrame:SetScale(0.7)

local targetPortraitFrame = CreateFrame('PlayerModel',nil,self)
targetTexture:SetAlpha(1)

targetPortraitFrame:SetParent(targetFrame)


targetPortraitFrame:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", 133, -40)
targetPortraitFrame:SetSize(60,60)

targetPortraitFrame:SetPortraitZoom(1)


local img1 = targetPortraitFrame:CreateTexture(nil, "BACKGROUND")
img1:SetHeight(60)
img1:SetWidth(60)
img1:SetPoint("TOPLEFT", 0, 0)
SetPortraitTexture(img1, "player")
img1:SetBlendMode('ADD')


   local tarName = targetFrame:CreateFontString('unitframePlayerHealth', "OVERLAY", "GameFontNormal")
    tarName:SetTextColor(255/255,197/255,39/255)
    tarName:SetFont(STANDARD_TEXT_FONT,18)
    tarName:SetPoint("TOPLEFT",targetFrame,"TOPLEFT",200,-42)
    tarName:SetText("")

  local  tarLevel = targetFrame:CreateFontString('unitframePlayerHealth', "OVERLAY", "GameFontNormal")
    tarLevel:SetTextColor(1,1,1)
    tarLevel:SetFont(STANDARD_TEXT_FONT,18)
    tarLevel:SetJustifyH('RIGHT')
    tarLevel:SetPoint("TOPRIGHT",targetFrame,"TOPRIGHT",-45,-42)
    tarLevel:SetText("20")


local barBG,barbgt = createBackground('TOPLEFT',272,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",1)
barBG:SetParent(targetFrame)
barbgt:SetVertexColor(0,0,0,0.2);
barBG:SetPoint("TOPLEFT",targetFrame,"TOPLEFT",195,-60)

local healthBar2 = CreateFrame("StatusBar", nil, targetFrame)
healthBar2:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy")
healthBar2:GetStatusBarTexture():SetHorizTile(false)
healthBar2:SetMinMaxValues(0, 100)
healthBar2:SetValue(100)
healthBar2:SetWidth(270)
healthBar2:SetHeight(12)
healthBar2:SetPoint("LEFT",barBG,"LEFT",1,0)
healthBar2:SetStatusBarColor(0.6,0.1,0.1)

local healthBar = CreateFrame("StatusBar", nil, targetFrame)
healthBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
healthBar:GetStatusBarTexture():SetHorizTile(false)
healthBar:SetMinMaxValues(0, 100)
healthBar:SetValue(100)
healthBar:SetWidth(270)
healthBar:SetHeight(12)
healthBar:SetPoint("LEFT",barBG,"LEFT",1,0)
healthBar:SetStatusBarColor(0.6,0.1,0.1)



local absorbBar = CreateFrame("StatusBar", nil, targetFrame)
absorbBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
absorbBar:GetStatusBarTexture():SetHorizTile(false)
absorbBar:SetMinMaxValues(0, 100)
absorbBar:SetValue(100)
absorbBar:SetWidth(270)
absorbBar:SetHeight(12)
absorbBar:SetPoint("LEFT",barBG,"LEFT",1,0)
absorbBar:SetStatusBarColor(0.9,0.9,0.6,0.4)

local candy, candyt = createBackground('TOPLEFT',270,16,0,0,"Interface\\AddOns\\GW2_UI\\textures\\gwstatusbarcandy",1)

candyt:SetVertexColor(0,0,0);
candyt:SetBlendMode("BLEND")
candy:SetWidth(270)
candy:SetHeight(12)
candy:SetParent(healthBar)
candy:ClearAllPoints()
candy:SetPoint("RIGHT",healthBar,"RIGHT",0,0)





local powerbar = CreateFrame("StatusBar", nil, targetFrame)
powerbar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
powerbar:GetStatusBarTexture():SetHorizTile(false)
powerbar:SetMinMaxValues(0, 100)
powerbar:SetValue(100)
powerbar:SetWidth(270)
powerbar:SetHeight(3)
powerbar:SetPoint("TOPLEFT",targetFrame,"TOPLEFT",196,-76)
powerbar:SetStatusBarColor(1,0.7,0.3)

local castBar = CreateFrame("StatusBar", nil, healthBar)
castBar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
castBar:GetStatusBarTexture():SetHorizTile(false)
castBar:SetMinMaxValues(0, 100)
castBar:SetValue(100)
castBar:SetWidth(270)
castBar:SetHeight(12)

castBar:SetPoint("TOPLEFT",healthBar,"TOPLEFT",0,0)
castBar:SetStatusBarColor(1,0.7,0.0,0.6)

   local castBarSpell = targetFrame:CreateFontString('targetSpellCastName', "OVERLAY", "GameFontNormal")
    castBarSpell:SetTextColor(1,1,1)
    castBarSpell:SetParent(castBar)
    castBarSpell:SetFont(STANDARD_TEXT_FONT,11)
    castBarSpell:SetPoint("LEFT",castBar,"LEFT",5,0)
    castBarSpell:SetText("")




targetPortraitFrame:SetScript("OnEvent",function(self,event,addon)
        if UnitExists("targettarget") then
            
            local special = 0;
            
            if ( UnitClassification("targettarget") == "elite" ) then
                targetTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit')
                special = 1
                tarLevel:SetText('Elite '..UnitLevel("targettarget"))
            end
            if ( UnitClassification("targettarget") == "rare" ) then
                targetTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare')
                special= 1
                tarLevel:SetText('Rare '..UnitLevel("targettarget"))
            end
            if ( UnitClassification("targettarget") == "rareelite" ) then
                targetTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit')
                special = 1
                tarLevel:SetText('Rare Elite '..UnitLevel("targettarget"))
            end
            
            if special == 1 then
                
            else
                targetTexture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\targetshadow')
                tarLevel:SetText(UnitLevel("targettarget"))
            end
            
            
            
            TargetFrame:Hide();
            
            targetPortraitFrame:EnableMouse(true);
            casting = false
            castBar:SetAlpha(0)
            
            prec = ((UnitHealth("targettarget") / UnitHealthMax("targettarget")))
            
            newWidth = 270*((1 - prec))
            
           
            
            
            --newWidth = ((100-prec)/100)*270
            candy:SetWidth(newWidth)
            
            targetFrame:SetAlpha(1)
            SetPortraitTexture(img1, "targettarget")
           -- targetPortraitFrame:SetUnit("targettarget")
            tarName:SetText(UnitName("targettarget"))
            powerType, powerToken, altR, altG, altB = UnitPowerType("targettarget")
            if PowerBarColorCustom[powerToken] then
                local pwcolor = PowerBarColorCustom[powerToken]
                powerbar:SetStatusBarColor(pwcolor.r,pwcolor.g,pwcolor.b)
            end
            powerbar:SetValue((UnitPower('targettarget')/UnitPowerMax('targettarget'))*100)
            targetFrame:ClearAllPoints()
            targetFrame:SetPoint('TOP',UIParent,'TOP',300,-200)
        else
            targetFrame:ClearAllPoints()
            targetFrame:SetPoint('TOP',UIParent,'TOP',0,500)
            targetPortraitFrame:EnableMouse(false);
            targetFrame:SetAlpha(0)
             targetFrameElite:SetAlpha(0)
                 targetFrameRare:SetAlpha(0)
        end
        
        
end)
castBar:SetScript("OnEvent",function(self,event,unitID,spell)
        if UnitExists("targettarget") and unitID=="targettarget" then
            if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' then
                    if event=='UNIT_SPELLCAST_CHANNEL_START' then
                        spell, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("targettarget")
                    else
                        spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("targettarget")
                    end
                castBar:SetAlpha(1)
                castBarSpell:SetText(spell)
                
                spellStart = startTime
                spellEnd = endTime
                castBar:SetValue(((spellEnd - spellStart) / 100))
                casting = true
            end
            
            if  event=='UNIT_SPELLCAST_STOP' or event=='UNIT_SPELLCAST_CHANNEL_STOP' then
                casting = false
                castBar:SetAlpha(0)
            end
            
        else
            
        end
        
        
end)
castBar:SetScript("OnUpdate",function(self)
        if UnitExists("targettarget") and UnitCastingInfo("targettarget") or UnitChannelInfo("targettarget") then
            if casting then                
                castBar:SetValue((((GetTime() * 1000) - spellStart) / (spellEnd - spellStart) * 100 ))
            end
        end
        
        
end)


targetPortraitFrame:SetScript("OnUpdate",function(self)
        if UnitExists("targettarget") then   
            
            local absorbAmount = ((UnitGetTotalAbsorbs("targettarget") / UnitHealthMax("targettarget"))*100)
            if absorbAmount > 100 then
                absorbAmount  = 100
            end
             powerbar:SetValue((UnitPower('targettarget')/UnitPowerMax('targettarget'))*100)
            
            local prec = ((UnitHealth("targettarget") / UnitHealthMax("targettarget"))*100)
            local newWidth = ((100-prec)/100)*270
            
            absorbBar:SetValue(absorbAmount)
           --  newWidth = 270*((1 - prec))
            
            
            healthBar:SetValue(prec)
            
            local limit = 30/GetFramerate()
  
            local cur = healthBar2:GetValue()
            local new = cur + min((prec-cur)/3, max(prec-cur, limit))
            if new ~= new then
                new = value
            end
            
            healthBar2:SetValue(new)
            --candy:SetWidth(new)
            if newWidth == 0 then
                candy:SetAlpha(0)
                else
                candy:SetAlpha(1)
            end
            candy:SetAlpha(0)
        end
        
        
end)




targetPortraitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
targetPortraitFrame:RegisterEvent("UNIT_TARGET");
targetPortraitFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
targetPortraitFrame:RegisterEvent("ZONE_CHANGED");

castBar:RegisterEvent("UNIT_SPELLCAST_START");
castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
castBar:RegisterEvent("UNIT_SPELLCAST_UPDATE");

castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
castBar:RegisterEvent("UNIT_SPELLCAST_STOP");
castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
castBar:RegisterEvent("UNIT_SPELLCAST_FAILED");

