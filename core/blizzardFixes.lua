local _, GW = ...

function GW:FixBlizzardIssues()
    if self.settings.FixGuildNewsSpam then
        -- https://nga.178.com/read.php?tid=42399961
        local newsRequireUpdate, newsTimer
        CommunitiesFrameGuildDetailsFrameNews:SetScript("OnEvent", function(frame, event)
            if event == "GUILD_NEWS_UPDATE" then
                if newsTimer then
                    newsRequireUpdate = true
                else
                    CommunitiesGuildNewsFrame_OnEvent(frame, event)

                    -- After 1 second, if guild news still need to be updated, update again
                    newsTimer = C_Timer.NewTimer(1, function()
                        if newsRequireUpdate then
                            CommunitiesGuildNewsFrame_OnEvent(frame, event)
                        end
                        newsTimer = nil
                    end)
                end
            else
                CommunitiesGuildNewsFrame_OnEvent(frame, event)
            end
        end)
    end

    print(self.settings.FixGuildNewsSpam)

    RegisterCVar("addonProfilerEnabled", "1")
    SetCVar("addonProfilerEnabled", self.settings.forceDisableCPUProfiler and 0 or 1)
    local cpuProfiler = C_AddOnProfiler.IsEnabled()
    self.Debug("Blizzard AddOn profiling is: " .. (cpuProfiler == true and "ON" or "OFF"))
end
