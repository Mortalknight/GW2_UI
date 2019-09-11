local _, GW = ...
local AddActionBarCallback = GW.AddActionBarCallback
local Self_Hide = GW.Self_Hide
local LoadAuras = GW.LoadAuras
local UpdateBuffLayout = GW.UpdateBuffLayout
local Debug = GW.Debug

local function UpdatePlayerBuffFrame()
    if InCombatLockdown() or not GwPlayerAuraFrame then
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

local function LoadBuffs()
    BuffFrame:Hide()
    BuffFrame:SetScript("OnShow", Self_Hide)
    local player_buff_frame = CreateFrame("Frame", "GwPlayerAuraFrame", UIParent, "GwPlayerAuraFrame")
    GW.MixinHideDuringPet(player_buff_frame)
    GwPlayerAuraFrame.auras = self
    GwPlayerAuraFrame.unit = "player"
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
    if GwMultiBarBottomRight then
        fgw:SetFrameRef("MultiBarBottomRight", GwMultiBarBottomRight)
        fgw:SetAttribute(
            "_onstate-combat",
            [=[
            local mbar = self:GetFrameRef("MultiBarBottomRight")
            local aura = self:GetFrameRef("GwPlayerAuraFrame")
            local uip = self:GetFrameRef("UIParent")
            local protected = mbar:IsProtected()

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

    LoadAuras(GwPlayerAuraFrame, GwPlayerAuraFrame, "player")
    UpdateBuffLayout(GwPlayerAuraFrame, event, "player")
end
GW.LoadBuffs = LoadBuffs
