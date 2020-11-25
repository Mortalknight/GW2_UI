local _, GW = ...
local AddActionBarCallback = GW.AddActionBarCallback
local Self_Hide = GW.Self_Hide
local LoadAuras = GW.LoadAuras
local UpdateBuffLayout = GW.UpdateBuffLayout
local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame
local Debug = GW.Debug
--- NOT USED ATM
local function UpdatePlayerBuffFrame()
    if InCombatLockdown() or not GwPlayerAuraFrame or GwPlayerAuraFrame.isMoved then
        return
    end
    GwPlayerAuraFrame:ClearAllPoints()
    if GwMultiBarBottomRight and GwMultiBarBottomRight.gw_FadeShowing then
        GwPlayerAuraFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 53, 215)
    else
        GwPlayerAuraFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 53, 120)
    end
end
GW.UpdatePlayerBuffFrame = UpdatePlayerBuffFrame

local function LoadAurasLegacy()
    BuffFrame:Hide()
    BuffFrame:SetScript("OnShow", Self_Hide)
    local player_buff_frame = CreateFrame("Frame", "GwPlayerAuraFrame", UIParent, "GwPlayerAuraFrame")
    GW.RegisterScaleFrame(player_buff_frame)
    GW.MixinHideDuringPet(player_buff_frame)
    player_buff_frame.auras = self
    player_buff_frame.unit = "player"
    player_buff_frame:SetScript(
        "OnEvent",
        function(self, event, unit)
            if unit ~= "player" then
                return
            end
            UpdateBuffLayout(GwPlayerAuraFrame, event, unit)
        end
    )
    player_buff_frame:RegisterEvent("UNIT_AURA")
    player_buff_frame:SetScript(
        "OnUpdate",
        function(self, elapsed)
            UpdateBuffLayout(GwPlayerAuraFrame, event, "player")
        end
    )

    local fgw = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
    fgw:SetFrameRef("GwPlayerAuraFrame", player_buff_frame)
    fgw:SetFrameRef("UIParent", UIParent)

    --Movable stuff
    player_buff_frame.secureHandler = fgw
    player_buff_frame.anchor = GetSetting("PlayerBuffFrame_GrowDirection") == "UP" and "BOTTOMRIGHT" or GetSetting("PlayerBuffFrame_GrowDirection") == "DOWN" and "TOPRIGHT" or "BOTTOMRIGHT"
    player_buff_frame.yOff = GetSetting("PlayerBuffFrame_GrowDirection") == "UP" and 0 or GetSetting("PlayerBuffFrame_GrowDirection") == "DOWN" and 15 or 0
    player_buff_frame:ClearAllPoints()
    player_buff_frame:SetPoint(
        player_buff_frame.anchor,
        player_buff_frame.gwMover,
        player_buff_frame.anchor,
        0,
        player_buff_frame.yOff
    )

    if GwMultiBarBottomRight then
        fgw:SetFrameRef("MultiBarBottomRight", GwMultiBarBottomRight)
        fgw:SetAttribute(
            "_onstate-combat",
            [=[
            local mbar = self:GetFrameRef("MultiBarBottomRight")
            local aura = self:GetFrameRef("GwPlayerAuraFrame")
            local auraIsMoved = self:GetAttribute("isMoved")
            local uip = self:GetFrameRef("UIParent")
            local protected = mbar:IsProtected()

            if auraIsMoved then
                newstate = "doNotTouch"
            end
            if newstate == "test" and protected then
                if not mbar or not mbar:IsShown() then
                    newstate = "low"
                else
                    newstate = "high"
                end
            end
            if newstate == "high" then
                aura:ClearAllPoints()
                aura:SetPoint("BOTTOMLEFT", uip, "BOTTOM", 53, 215)
            elseif newstate == "low" then
                aura:ClearAllPoints()
                aura:SetPoint("BOTTOMLEFT", uip, "BOTTOM", 53, 120)
            end
            ]=]
        )
        RegisterStateDriver(fgw, "combat", "[combat] test; [overridebar] low; [vehicleui] low; none")
    end

    AddActionBarCallback(UpdatePlayerBuffFrame)
    UpdatePlayerBuffFrame()

    LoadAuras(player_buff_frame, player_buff_frame, "player")
    UpdateBuffLayout(player_buff_frame, event, "player")

    RegisterMovableFrame(player_buff_frame, BUFFOPTIONS_LABEL, "PlayerBuffFrame", "VerticalActionBarDummy", true, true)
    hooksecurefunc(player_buff_frame.gwMover, "StopMovingOrSizing", function (frame)
        local anchor = GwPlayerAuraFrame.anchor
        local yOff = GwPlayerAuraFrame.yOff

        if not InCombatLockdown() then
            GwPlayerAuraFrame:ClearAllPoints()
            GwPlayerAuraFrame:SetPoint(anchor, frame, anchor, 0, yOff)
        end
    end)
end
GW.LoadAurasLegacy = LoadAurasLegacy
