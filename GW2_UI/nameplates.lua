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
    old_cbicon:ClearAllPoints();
  
    

    Health:SetPoint('CENTER',Plate,'CENTER',0,-10);
    Cast:SetPoint('CENTER',Plate,'CENTER',0,-15);
    old_level:SetPoint('LEFT',Health,'RIGHT',10,0);
    old_cbicon:SetPoint('LEFT',Health,'LEFT',-old_cbicon:GetWidth(),0);
    old_cbicon:SetTexCoord(0.1,0.9,0.1,0.9)
    
    old_name:SetShadowOffset(-1, -1)
    old_name:SetShadowColor(0, 0, 0, 1)
    old_name:SetFont(STANDARD_TEXT_FONT, 12)
    
    Health:SetStatusBarTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
    Cast:SetStatusBarTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
    minValue, maxValue = Health:GetMinMaxValues()
    
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
    
    red, green, blue, alpha = Health:GetStatusBarColor()
    
    if red > green and red > blue then
        red =0.6
        green = 0.1
        blue = 0.1
    else
        if green > blue and green > red then
           red =0.1
            green = 0.6
            blue = 0.1
        else
            if blue > red and blue > green then
                red =0.1
                green = 0.1
                blue = 0.6
            end
        end
    end
    
    Health:SetStatusBarColor(red,green,blue)
    
    
    old_name:SetTextColor(red+0.2,green+0.2,blue+0.2)
    old_level:SetTextColor(1,1,1)
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