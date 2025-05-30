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
end
