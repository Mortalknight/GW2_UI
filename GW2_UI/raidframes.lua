local raiframeHolder = CreateFrame("frame",nil,UIParent)

raiframeHolder:HookScript('OnEvent', function(self)
	
         for i = 1,40 do
            
            if _G["CompactRaidFrame"..i.."HealthBar"] then
            --    _G["CompactRaidFrame"..i.."HealthBar"]:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
               _G["CompactRaidFrame"..i.."HealthBar"]:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
            end
            if _G["CompactRaidFrame"..i.."PowerBarBackground"] then
           --     _G["CompactRaidFrame"..i.."PowerBarBackground"]:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar')
                _G["CompactRaidFrame"..i.."HealthBar"]:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
                
            end
        end
        
end)

raiframeHolder:RegisterEvent("RAID_ROSTER_UPDATE");
raiframeHolder:RegisterEvent("GROUP_ROSTER_UPDATE");