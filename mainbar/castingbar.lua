local _, GW = ...
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local TimeCount = GW.TimeCount
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation

local playerCasting = 0

local function barValues(name, icon, spellid)
    GwCastingBar.name:SetText(name)
    GwCastingBar.icon:SetTexture(icon)
    GwCastingBar.latency:Show()
    GwCastingBar.spellId = spellid
end
GW.AddForProfiling("castingbar", "barValues", barValues)

local function barReset()
    if animations["castingbarAnimation"] then
        animations["castingbarAnimation"]["completed"] = true
        animations["castingbarAnimation"]["duration"] = 0
    end
end
GW.AddForProfiling("castingbar", "barReset", barReset)

local function LoadCastingBar()
    CastingBarFrame:Hide()
    CastingBarFrame:UnregisterAllEvents()

    local GwCastingBar = CreateFrame("Frame", "GwCastingBar", UIParent, "GwCastingBar")
    GwCastingBar.latency:Hide()
    GwCastingBar.name:SetFont(UNIT_NAME_FONT, 12)
    GwCastingBar.name:SetShadowOffset(1, -1)
    GwCastingBar.time:SetFont(UNIT_NAME_FONT, 12)
    GwCastingBar.time:SetShadowOffset(1, -1)
    GwCastingBar.spark:ClearAllPoints()
    GwCastingBar.spark:SetPoint("RIGHT", GwCastingBar.bar, "RIGHT")

    GwCastingBar:ClearAllPoints()
    GwCastingBar:SetPoint(
        GetSetting("castingbar_pos")["point"],
        UIParent,
        GetSetting("castingbar_pos")["relativePoint"],
        GetSetting("castingbar_pos")["xOfs"],
        GetSetting("castingbar_pos")["yOfs"]
    )

    GwCastingBar:SetAlpha(0)

    RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", "GwCastFrameDummy")

    GwCastingBar:SetScript(
        "OnEvent",
        function(self, event, unitID, spellid)
            local castingType = 1
            local spell, icon, startTime, endTime
            if unitID ~= "player" then
                return
            end
            if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_DELAYED" then
                if event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
                    spell, _, icon, startTime, endTime, _, _ = UnitChannelInfo("player")
                    castingType = 2
                else
                    spell, _, icon, startTime, endTime, _, _, _ = UnitCastingInfo("player")
                end

                if GetSetting("CASTINGBAR_DATA") then
                    barValues(spell, icon, spellid)
                end

                startTime = startTime / 1000
                endTime = endTime / 1000
                barReset()
                GwCastingBar.spark:Show()
                StopAnimation("castingbarAnimation")
                AddToAnimation(
                    "castingbarAnimation",
                    0,
                    1,
                    startTime,
                    endTime - startTime,
                    function()
                        if GetSetting("CASTINGBAR_DATA") then
                            GwCastingBar.time:SetText(TimeCount(endTime - GetTime(), true))
                        end

                        local p = animations["castingbarAnimation"]["progress"]
                        GwCastingBar.latency:ClearAllPoints()
                        GwCastingBar.latency:SetPoint("RIGHT", "GwCastingBar", "RIGHT")
                        if castingType == 2 then
                            p = 1 - animations["castingbarAnimation"]["progress"]
                            GwCastingBar.latency:ClearAllPoints()
                            GwCastingBar.latency:SetPoint("LEFT", "GwCastingBar", "LEFT")
                        end

                        GwCastingBar.bar:SetWidth(math.max(1, p * 176))
                        GwCastingBar.bar:SetVertexColor(1, 1, 1, 1)

                        GwCastingBar.spark:SetWidth(math.min(15, math.max(1, p * 176)))
                        GwCastingBar.bar:SetTexCoord(0, p, 0.25, 0.5)

                        local _, _, _, lagWorld = GetNetStats()
                        lagWorld = lagWorld / 1000
                        GwCastingBar.latency:SetWidth(math.min(1, (lagWorld / (endTime - startTime))) * 176)
                    end,
                    "noease"
                )

                if playerCasting ~= 1 then
                    UIFrameFadeIn(GwCastingBar, 0.1, 0, 1)
                end
                playerCasting = 1
            end

            if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
                if GwCastingBar.animating == nil or GwCastingBar.animating == false then
                    UIFrameFadeOut(GwCastingBar, 0.2, 1, 0)
                end
                barReset()
                playerCasting = 0
            end

            if event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
                barReset()
                playerCasting = 0
            end
            if event == "UNIT_SPELLCAST_SUCCEEDED" and GwCastingBar.spellId== spellid then
                GwCastingBar.animating = true
                GwCastingBar.bar:SetTexCoord(0, 1, 0.5, 0.75)
                GwCastingBar.bar:SetWidth(176)
                GwCastingBar.spark:Hide()
                AddToAnimation(
                    "castingbarAnimationComplete",
                    0,
                    1,
                    GetTime(),
                    0.2,
                    function()
                        GwCastingBar.bar:SetVertexColor(
                            1,
                            1,
                            1,
                            lerp(1, 0.7, animations["castingbarAnimationComplete"]["progress"])
                        )
                    end,
                    nil,
                    function()
                        GwCastingBar.animating = false
                        if playerCasting == 0 then
                            if GwCastingBar:GetAlpha() > 0 then
                                UIFrameFadeOut(GwCastingBar, 0.2, 1, 0)
                            end
                        end
                    end
                )
            end
        end
    )

    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_START")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_STOP")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_DELAYED")
end
GW.LoadCastingBar = LoadCastingBar
