local _, GW = ...

local function LoadTotemTimersSkin()
    if not GW.GetSetting("TOTEM_TIMERS_ADDON_SKIN_ENABLED") then return end
    if not TTActionBars then return end
    C_Timer.After(0, function()
        for i = 1,#TTActionBars.bars do
            for j = 1,#TTActionBars.bars[i].buttons do
                TTActionBars.bars[i].buttons[j].icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                TTActionBars.bars[i].buttons[j].icon2:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                GW.setActionButtonStyle(TTActionBars.bars[i].buttons[j]:GetName())
                for mi = 1, 4 do
                    TTActionBars.bars[i].buttons[j].MiniIcons[mi]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    hooksecurefunc(TTActionBars.bars[i].buttons[j].MiniIcons[mi], "SetTexCoord", function(self, a, b, c, d)
                        if a ~= 0.1 or b ~= 0.9 or c ~= 0.1 or d ~= 0.9 then
                            self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                        end
                    end)
                end

                hooksecurefunc(TTActionBars.bars[i].buttons[j].icon, "SetTexCoord", function(self, a, b, c, d)
                    if a ~= 0.1 or b ~= 0.9 or c ~= 0.1 or d ~= 0.9 then
                        self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    end
                end)
                hooksecurefunc(TTActionBars.bars[i].buttons[j].icon2, "SetTexCoord", function(self, a, b, c, d)
                    if a ~= 0.1 or b ~= 0.9 or c ~= 0.1 or d ~= 0.9 then
                        self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    end
                end)
            end
        end

        for _, v in pairs(XiTimers.timers) do
            v.button.miniIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            GW.setActionButtonStyle(v.button:GetName())

            hooksecurefunc(v.button.miniIcon, "SetTexCoord", function(self, a, b, c, d)
                if a ~= 0.1 or b ~= 0.9 or c ~= 0.1 or d ~= 0.9 then
                    self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
            end)
            for mi = 1, v.button.nrOfTimers or 2 do
                if v.button.icons[mi] then
                    v.button.icons[mi]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    hooksecurefunc(v.button.icons[mi], "SetTexCoord", function(self, a, b, c, d)
                        if a ~= 0.1 or b ~= 0.9 or c ~= 0.1 or d ~= 0.9 then
                            self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                        end
                    end)
                end
            end
        end
    end)
end
GW.LoadTotemTimersSkin = LoadTotemTimersSkin