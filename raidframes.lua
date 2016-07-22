
function setStatusBarTextureRaidFrame(bar)
   bar:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
end

function gw_register_raidframes()
    local raiframeHolder = CreateFrame("frame",nil,UIParent)

    raiframeHolder:HookScript('OnEvent', function(self)

             for i = 1,80 do

                if _G["CompactRaidFrame"..i.."HealthBar"] then
                _G["CompactRaidFrame"..i.."HealthBar"]:SetStatusBarTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
                end
                if _G["CompactRaidFrame"..i.."PowerBarBackground"] then
                    hooksecurefunc( _G["CompactRaidFrame"..i.."HealthBar"], 'SetStatusBarTexture', function(self,texture)
                        if texture~="Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar" then
                            setStatusBarTextureRaidFrame(_G["CompactRaidFrame"..i.."HealthBar"])
                        end
                    end)
                end
            end


    end)
    raiframeHolder:RegisterEvent("PLAYER_ENTERING_WORLD");
    raiframeHolder:RegisterEvent("RAID_ROSTER_UPDATE");
    raiframeHolder:RegisterEvent("GROUP_ROSTER_UPDATE");
end




