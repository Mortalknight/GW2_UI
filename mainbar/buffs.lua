local _, GW = ...
local AddActionBarCallback = GW.AddActionBarCallback
local Self_Hide = GW.Self_Hide
local LoadAuras = GW.LoadAuras
local UpdateBuffLayout = GW.UpdateBuffLayout
local Debug = GW.Debug
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local DEBUFF_COLOR = GW.DEBUFF_COLOR

local function UpdatePlayerBuffFrame()
    if InCombatLockdown() or not GwPlayerAuraFrame then
        return
    end
    GwPlayerAuraFrame:ClearAllPoints()
    if MultiBarBottomRight and MultiBarBottomRight.gw_FadeShowing then
        GwPlayerAuraFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 53, 215)
    else
        GwPlayerAuraFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 53, 120)
    end
end
GW.UpdatePlayerBuffFrame = UpdatePlayerBuffFrame

local function LoadDebuff(self, data, buffindex, filter)        
    if data['dispelType'] ~= nil then
        self.background:SetVertexColor(DEBUFF_COLOR[data['dispelType']].r, DEBUFF_COLOR[data['dispelType']].g, DEBUFF_COLOR[data['dispelType']].b)
    else          
        self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b);
    end
    self.cooldown:SetDrawEdge(0)
    self.cooldown:SetDrawSwipe(1)
    self.cooldown:SetReverse(false)
    self.cooldown:SetHideCountdownNumbers(true)       
    self.icon:SetTexture(data['icon'])
     
    local buffDur = ""
    local stacks  = ""
    if data['count'] ~= nil and data['count'] > 1 then
        stacks = data['count'] 
    end
            
    self.expires =data['expires']
    self.duration =data['duration']
    self.cooldown:SetCooldown(0, 0)
        
    _G[self:GetName() .. 'CooldownBuffDuration']:SetText(buffDur)
    _G[self:GetName() .. 'IconBuffStacks']:SetText(stacks)
           
    self:SetScript('OnEnter', function() GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT"); GameTooltip:ClearLines(); GameTooltip:SetUnitDebuff(self.unit,buffindex,filter); GameTooltip:Show() end)
    self:SetScript('OnLeave', function() GameTooltip:Hide() end)  
end
GW.LoadDebuff = LoadDebuff

local function LoadBuffs()
    BuffFrame:Hide()
    BuffFrame:SetScript("OnShow", Self_Hide)
    local player_buff_frame = CreateFrame("Frame", "GwPlayerAuraFrame", UIParent, "GwPlayerAuraFrame")
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
    if MultiBarBottomRight then
        fgw:SetFrameRef("MultiBarBottomRight", MultiBarBottomRight)
        fgw:SetAttribute(
            "_onstate-combat",
            [=[
            local mbar = self:GetFrameRef("MultiBarBottomRight")
            local aura = self:GetFrameRef("GwPlayerAuraFrame")
            local uip = self:GetFrameRef("UIParent")
            local protected = mbar:IsProtected()

            if newstate == "incombat" and protected then
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
        RegisterStateDriver(fgw, "combat", "[combat] incombat; [overridebar] low; [vehicleui] low; none")
    end

    AddActionBarCallback(UpdatePlayerBuffFrame)
    UpdatePlayerBuffFrame()

    LoadAuras(GwPlayerAuraFrame, GwPlayerAuraFrame, "player")
    UpdateBuffLayout(GwPlayerAuraFrame, event, "player")
end
GW.LoadBuffs = LoadBuffs