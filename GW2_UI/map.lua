Minimap:ClearAllPoints()
Minimap:SetPoint('BOTTOMRIGHT',UIParent,-5,21)
mapShadowBg:ClearAllPoints()
mapShadowBg:SetPoint('BOTTOMRIGHT',Minimap,'BOTTOMRIGHT',2,-1)
Minimap:SetScale(1.1)

Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')


Minimap:SetParent(UIParent)

MinimapCluster:Hide()
MinimapBorder:Hide()
MiniMapWorldMapButton:Hide()

GarrisonLandingPageMinimapButton:ClearAllPoints()
MiniMapMailFrame:ClearAllPoints()
GameTimeFrame:ClearAllPoints()
MinimapZoneText:ClearAllPoints()

MinimapZoneText:SetParent(Minimap)


GarrisonLandingPageMinimapButton:SetPoint('TOPLEFT',Minimap,0,30)
MiniMapTracking:SetPoint('TOPLEFT',Minimap,-15,-30)
MiniMapMailFrame:SetPoint('TOPLEFT',Minimap,45,15)
QueueStatusMinimapButton:SetPoint('TOPLEFT',Minimap,75,15)
GameTimeFrame:SetPoint('TOPRIGHT',Minimap,0,25)
MinimapZoneText:SetPoint('TOP',Minimap,0,25)




Minimap:SetScript('OnUpdate', function(self)
	
	if self:IsMouseOver(0, -0, -0, 0) then
    hoverMiniMap()
    end
	
end)
Minimap:SetScript('OnLeave', function(self)
	
		local kids = { Minimap:GetChildren() };

        for _, child in ipairs(kids) do
              if child:GetName()=='MiniMapMailFrame' then
                if HasNewMail()~=true then
                      UIFrameFadeIn(child, 1, self:GetAlpha(),0)
                end
            else
            UIFrameFadeIn(child, 1, self:GetAlpha(),0)
            UIFrameFadeIn(MinimapZoneText, 1, self:GetAlpha(),0)
            end
        end
	
end)

Minimap:SetScript("OnEvent",function(self,event,addon)
    local kids = { Minimap:GetChildren() };

    for _, child in ipairs(kids) do
       child:SetAlpha(0)
       MinimapZoneText:SetAlpha(0)
    end
end)

function hoverMiniMap()
	local kids = { Minimap:GetChildren() };

        for _, child in ipairs(kids) do
           if child:GetName()=='MiniMapMailFrame' then
                if HasNewMail() then
                     UIFrameFadeIn(child, 1, Minimap:GetAlpha(),1)
                end
            else
            UIFrameFadeIn(child, 1, Minimap:GetAlpha(),1)
            UIFrameFadeIn(MinimapZoneText, 1, Minimap:GetAlpha(),1)
            end
            
        end
end

MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
Minimap:EnableMouseWheel(true)

Minimap:SetScript("OnMouseWheel", function(self, delta)
   if delta > 0 and self:GetZoom() < 5 then
      self:SetZoom(self:GetZoom() + 1)
   elseif delta < 0 and self:GetZoom() > 0 then
      self:SetZoom(self:GetZoom() - 1)
   end
end)
Minimap:RegisterEvent("PLAYER_ENTERING_WORLD");


GameTooltip:SetScript("OnTooltipSetUnit", function(self)
    self:ClearAllPoints()
    self:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", 0, 200)
end)