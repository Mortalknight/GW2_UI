local nPlates = CreateFrame("frame",nil,UIParent)

local Plates = {};
local i = 1;

local function PlateAdd ( Plate )
    
    i = i +1;
    
    local f1, f2 = Plate:GetChildren()
	
    local Health, Cast = f1:GetChildren()
    local old_name = f2:GetRegions()
    
	local old_threat, hpborder, highlight, old_level, old_bossicon, raidicon, old_elite = f1:GetRegions()
	local cbtexture, cbborder, old_cbshield, old_cbicon, old_cbname, cbnameshadow = Cast:GetRegions()
    

    old_threat:Hide()
    hpborder:Hide()
    cbborder:Hide()

    old_level:ClearAllPoints();
    Health:ClearAllPoints();
    Cast:ClearAllPoints();
    old_name:ClearAllPoints()
   if old_cbicon then
        old_cbicon:ClearAllPoints();
    end
    
      

    Health:SetPoint('CENTER',Plate,'CENTER',0,-10);
    Cast:SetPoint('TOP',Health,'BOTTOM',0,0);
    old_level:SetPoint('LEFT',Health,'RIGHT',5,0);
    old_name:SetPoint('BOTTOM',Health,'TOP',0,5)
   -- old_cbicon:SetPoint('LEFT',Health,'LEFT',-old_cbicon:GetWidth(),0);
    --old_cbicon:SetTexCoord(0.1,0.9,0.1,0.9)
    
    old_level:SetFont(STANDARD_TEXT_FONT, 11)
    
    old_name:SetShadowOffset(-1, -1)
    old_name:SetShadowColor(0, 0, 0, 1)
    old_name:SetFont(STANDARD_TEXT_FONT, 11,'OUTLINE')
    local backdrop = {
  bgFile = "Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar",  

  edgeFile = nil,

  tile = false,

  tileSize = 32,

  edgeSize = 0,

  insets = {
    left = -1,
    right = -1,
    top = -1,
    bottom = -1
  }
}
 

    Health:SetBackdrop(backdrop)
    Health:SetBackdropColor(0, 0, 0,0.8)
    Health:SetBackdropBorderColor(0, 0, 0,0.8)
    Health:SetStatusBarTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
    Cast:SetStatusBarTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
    Cast:SetBackdrop(backdrop)
    Cast:SetBackdropColor(0, 0, 0,0.8)
    Cast:SetBackdropBorderColor(0, 0, 0,0.8)

    minValue, maxValue = Health:GetMinMaxValues()
    Cast:SetScript('OnShow',function(self)    
            self:SetStatusBarTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
            self:SetBackdrop(backdrop)
            self:SetBackdropColor(0, 0, 0,0.8)
            self:SetBackdropBorderColor(0, 0, 0,0.8)
    end)
    
    setPlateOnShow(Health,Cast,old_name,old_level)
    Plate:SetScript('OnShow',function(self)            
      setPlateOnShow(Health,Cast,old_name,old_level)
    end)
    
    Plate:SetScript('OnHide',function(self)
      
    end)
end

function setPlateOnShow(Health,Cast,old_name,old_level)
    Health:SetWidth(70)
    Health:SetHeight(5)
    Cast:SetWidth(70)
    Cast:SetHeight(5)
    
    r,g,b = Health:GetStatusBarColor()
    

    
    if r==0.99999779462814 and g == 0 and b==0 then
       Health:SetStatusBarColor(159/255,36/255,20/255)
    end
    
    Cast:SetStatusBarTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
    Cast:SetBackdrop(backdrop)
    Cast:SetBackdropColor(0, 0, 0,0.8)
    Cast:SetBackdropBorderColor(0, 0, 0,0.8)
    

end



local PlatesScan;
do
        local select = select;
        function PlatesScan ( ... )
              for index = 1, select('#', WorldFrame:GetChildren()) do
					local frame = select(index, WorldFrame:GetChildren())
					if not Plates[frame] and (frame:GetName() and frame:GetName():find('NamePlate%d')) then
						if frame:IsShown() then
							  PlateAdd( frame,Index );
						end
					end
				end
               
        end
end




nPlates:SetScript('OnUpdate',function(self)
    if GW2UI_SETTINGS['SETTINGS_LOADED'] == false then
        return
    end
    if GW2UI_SETTINGS['DISABLE_NAMEPLATES'] == true then
        return
    end
local ChildCount, NewChildCount = 0;
        local NextUpdate = 0;
        local pairs = pairs;
                -- Check for new nameplates
                NewChildCount = WorldFrame:GetNumChildren();
                if ( ChildCount ~= NewChildCount ) then
                        ChildCount = NewChildCount;
                       
                        PlatesScan( WorldFrame:GetChildren( WorldFrame ) );
                end

             
        
end)