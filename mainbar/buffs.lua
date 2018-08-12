local _, GW = ...
local TimeCount = GW.TimeCount
local AddActionBarCallback = GW.AddActionBarCallback
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local Self_Hide = GW.Self_Hide
local LoadAuras = GW.LoadAuras
local UpdateBuffLayout = GW.UpdateBuffLayout
local Debug = GW.Debug

local buffLists = {}
local DebuffLists = {}

--[[
local function auraAnimateOut(self)
    self.animating = true

    AddToAnimation(
        self:GetName(),
        0,
        1,
        GetTime(),
        2,
        function(step)
            local alpha = 1

            if step < 0.25 then
                alpha = lerp(1, 0.3, step / 0.25)
            elseif step < 0.5 and step > 0.25 then
                alpha = lerp(0.3, 1, (step - 0.25) / 0.25)
            elseif step < 0.75 and step > 0.5 then
                alpha = lerp(1, 0.3, (step - 0.5) / 0.25)
            else
                alpha = lerp(0.3, 1, (step - 0.75) / 0.25)
            end

            self:SetAlpha(alpha)
        end,
        "noease",
        function()
            self.animating = false
        end
    )
end
--]]
--[[
local player_update_buff_Timer_cooldown = 0
local function updateBuffTimers(thisName)
    if player_update_buff_Timer_cooldown > GetTime() then
        return
    end
    player_update_buff_Timer_cooldown = GetTime() + 1

    for i = 1, 40 do
        if _G["playerDeBuffItemFrame" .. i] then
            local buffDur = ""
            d = tonumber(_G["playerDeBuffItemFrame" .. i].duration)
            e = tonumber(_G["playerDeBuffItemFrame" .. i].expires)

            if d > 0 then
                buffDur = TimeCount(e - GetTime())
            end
            _G["playerDeBuffItemFrame" .. i .. "CooldownBuffDuration"]:SetText(buffDur)
        end
        if _G["GwPlayerBuffItemFrame" .. i] then
            local buffDur = ""
            d = tonumber(_G["GwPlayerBuffItemFrame" .. i].duration)
            e = tonumber(_G["GwPlayerBuffItemFrame" .. i].expires)

            if d > 0 then
                buffDur = TimeCount(e - GetTime())
            end
            _G["GwPlayerBuffItemFrame" .. i .. "BuffDuration"]:SetText(buffDur)
        end
    end
end
--]]
local function updatePlayerDebuffList()
    unitToWatch = "Player"
    DebuffLists[unitToWatch] = {}
    for i = 1, 40 do
        if UnitDebuff(unitToWatch, i) then
            DebuffLists[unitToWatch][i] = {}
            DebuffLists[unitToWatch][i]["name"],
                DebuffLists[unitToWatch][i]["icon"],
                DebuffLists[unitToWatch][i]["count"],
                DebuffLists[unitToWatch][i]["dispelType"],
                DebuffLists[unitToWatch][i]["duration"],
                DebuffLists[unitToWatch][i]["expires"],
                DebuffLists[unitToWatch][i]["caster"],
                DebuffLists[unitToWatch][i]["isStealable"],
                DebuffLists[unitToWatch][i]["shouldConsolidate"],
                DebuffLists[unitToWatch][i]["spellID"] = UnitDebuff(unitToWatch, i)
            DebuffLists[unitToWatch][i]["key"] = i
            DebuffLists[unitToWatch][i]["timeRemaining"] = DebuffLists[unitToWatch][i]["expires"] - GetTime()
            if DebuffLists[unitToWatch][i]["duration"] <= 0 then
                DebuffLists[unitToWatch][i]["timeRemaining"] = 500000
            end
        end
    end

    table.sort(
        DebuffLists[unitToWatch],
        function(a, b)
            return a["timeRemaining"] < b["timeRemaining"]
        end
    )
end
GW.AddForProfiling("buffs", "updatePlayerDebuffList", updatePlayerDebuffList)

local function updatePlayerDebuffs(x, y)
    y = y + 1
    x = 0
    updatePlayerDebuffList()

    for i = 1, 40 do
        local indexBuffFrame = _G["playerDeBuffItemFrame" .. i]
        if DebuffLists[unitToWatch][i] then
            local key = DebuffLists[unitToWatch][i]["key"]

            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame("Frame", "playerDeBuffItemFrame" .. i, _G["GwPlayerAuraFrame"], "GwDeBuffIcon")
                indexBuffFrame:SetParent(_G["GwPlayerAuraFrame"])
                _G["playerDeBuffItemFrame" .. i .. "DeBuffBackground"]:SetVertexColor(
                    COLOR_FRIENDLY[2].r,
                    COLOR_FRIENDLY[2].g,
                    COLOR_FRIENDLY[2].b
                )

                if
                    DebuffLists[unitToWatch][i]["dispelType"] ~= nil and
                        DEBUFF_COLOR[DebuffLists[unitToWatch][i]["dispelType"]] ~= nil
                 then
                    _G["playerDeBuffItemFrame" .. i .. "DeBuffBackground"]:SetVertexColor(
                        DEBUFF_COLOR[DebuffLists[unitToWatch][i]["dispelType"]].r,
                        DEBUFF_COLOR[DebuffLists[unitToWatch][i]["dispelType"]].g,
                        DEBUFF_COLOR[DebuffLists[unitToWatch][i]["dispelType"]].b
                    )
                end
                _G["playerDeBuffItemFrame" .. i .. "Cooldown"]:SetDrawEdge(0)
                _G["playerDeBuffItemFrame" .. i .. "Cooldown"]:SetDrawSwipe(1)
                _G["playerDeBuffItemFrame" .. i .. "Cooldown"]:SetReverse(false)
                _G["playerDeBuffItemFrame" .. i .. "Cooldown"]:SetHideCountdownNumbers(true)
            end
            _G["playerDeBuffItemFrame" .. i .. "IconBuffIcon"]:SetTexture(DebuffLists[unitToWatch][i]["icon"])
            --    _G['playerDeBuffItemFrame'..i..'IconBuffIcon']:SetParent(_G['playerDeBuffItemFrame'..i])
            local buffDur = ""
            local stacks = ""
            if DebuffLists[unitToWatch][i]["count"] > 0 then
                stacks = DebuffLists[unitToWatch][i]["count"]
            end
            if DebuffLists[unitToWatch][i]["duration"] > 0 then
                buffDur = TimeCount(DebuffLists[unitToWatch][i]["timeRemaining"])
            end
            indexBuffFrame.expires = DebuffLists[unitToWatch][i]["expires"]
            indexBuffFrame.duration = DebuffLists[unitToWatch][i]["duration"]

            _G["playerDeBuffItemFrame" .. i .. "CooldownBuffDuration"]:SetText(buffDur)
            _G["playerDeBuffItemFrame" .. i .. "IconBuffStacks"]:SetText(stacks)

            _G["playerDeBuffItemFrame" .. i .. "Cooldown"]:SetCooldown(
                DebuffLists[unitToWatch][i]["expires"] - DebuffLists[unitToWatch][i]["duration"],
                DebuffLists[unitToWatch][i]["duration"]
            )

            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint("BOTTOMRIGHT", (-32 * x), 42 * y)

            indexBuffFrame:SetScript(
                "OnEnter",
                function()
                    GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetUnitDebuff(unitToWatch, key)
                    GameTooltip:Show()
                end
            )
            indexBuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            indexBuffFrame:Show()

            x = x + 1
            if x > 7 then
                y = y + 1
                x = 0
            end
        else
            if indexBuffFrame ~= nil then
                indexBuffFrame:Hide()
            else
                break
            end
        end
    end
end
GW.AddForProfiling("buffs", "updatePlayerDebuffs", updatePlayerDebuffs)

local function updatePlayerBuffList()
    unitToWatch = "Player"
    buffLists[unitToWatch] = {}
    for i = 1, 40 do
        if UnitBuff(unitToWatch, i) then
            buffLists[unitToWatch][i] = {}
            buffLists[unitToWatch][i]["name"],
                buffLists[unitToWatch][i]["icon"],
                buffLists[unitToWatch][i]["count"],
                buffLists[unitToWatch][i]["dispelType"],
                buffLists[unitToWatch][i]["duration"],
                buffLists[unitToWatch][i]["expires"],
                buffLists[unitToWatch][i]["caster"],
                buffLists[unitToWatch][i]["isStealable"],
                buffLists[unitToWatch][i]["shouldConsolidate"],
                buffLists[unitToWatch][i]["spellID"] = UnitBuff(unitToWatch, i)
            buffLists[unitToWatch][i]["key"] = i
            buffLists[unitToWatch][i]["timeRemaining"] = buffLists[unitToWatch][i]["expires"] - GetTime()
            if buffLists[unitToWatch][i]["duration"] <= 0 then
                buffLists[unitToWatch][i]["timeRemaining"] = 500000
            end
        end
    end

    table.sort(
        buffLists[unitToWatch],
        function(a, b)
            return a["timeRemaining"] > b["timeRemaining"]
        end
    )
end
GW.AddForProfiling("buffs", "updatePlayerBuffList", updatePlayerBuffList)

--[[
local function updatePlayerAuras()
    unitToWatch = "player"
    updatePlayerBuffList()
    local x = 0
    local y = 0
    for i = 1, 40 do
        local indexBuffFrame = _G["GwPlayerBuffItemFrame" .. i]
        if buffLists[unitToWatch][i] then
            local key = buffLists[unitToWatch][i]["key"]
            if indexBuffFrame == nil then
                indexBuffFrame =
                    CreateFrame("Button", "GwPlayerBuffItemFrame" .. i, _G["GwPlayerAuraFrame"], "GwBuffIconBig")
                indexBuffFrame:RegisterForClicks("RightButtonUp")
                _G[indexBuffFrame:GetName() .. "BuffDuration"]:SetFont(UNIT_NAME_FONT, 11)
                _G[indexBuffFrame:GetName() .. "BuffDuration"]:SetTextColor(1, 1, 1)
                _G[indexBuffFrame:GetName() .. "BuffStacks"]:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
                _G[indexBuffFrame:GetName() .. "BuffStacks"]:SetTextColor(1, 1, 1)
                indexBuffFrame:SetParent(_G["GwPlayerAuraFrame"])
            end
            local margin = -indexBuffFrame:GetWidth() + -2
            local marginy = indexBuffFrame:GetWidth() + 12
            _G["GwPlayerBuffItemFrame" .. i .. "BuffIcon"]:SetTexture(buffLists[unitToWatch][i]["icon"])
            _G["GwPlayerBuffItemFrame" .. i .. "BuffIcon"]:SetParent(_G["GwPlayerBuffItemFrame" .. i])
            local buffDur = ""
            local stacks = ""
            if buffLists[unitToWatch][i]["duration"] > 0 then
                buffDur = TimeCount(buffLists[unitToWatch][i]["timeRemaining"])
            end
            if buffLists[unitToWatch][i]["count"] > 0 then
                stacks = buffLists[unitToWatch][i]["count"]
            end
            indexBuffFrame.expires = buffLists[unitToWatch][i]["expires"]
            indexBuffFrame.duration = buffLists[unitToWatch][i]["duration"]
            _G["GwPlayerBuffItemFrame" .. i .. "BuffDuration"]:SetText(buffDur)
            _G["GwPlayerBuffItemFrame" .. i .. "BuffStacks"]:SetText(stacks)
            indexBuffFrame:ClearAllPoints()
            indexBuffFrame:SetPoint("BOTTOMRIGHT", (margin * x), marginy * y)

            indexBuffFrame:SetScript(
                "OnEnter",
                function()
                    GameTooltip:SetOwner(indexBuffFrame, "ANCHOR_BOTTOMLEFT", 28, 0)
                    GameTooltip:ClearLines()
                    GameTooltip:SetUnitBuff(unitToWatch, key)
                    GameTooltip:Show()
                end
            )
            indexBuffFrame:SetScript("OnLeave", GameTooltip_Hide)

            indexBuffFrame:SetScript(
                "OnClick",
                function(self, button)
                    if InCombatLockdown() then
                        return
                    end
                    if button == "RightButton" then
                        CancelUnitBuff("player", key)
                    end
                end
            )

            indexBuffFrame:Show()

            x = x + 1
            if x > 7 then
                y = y + 1
                x = 0
            end
        else
            if indexBuffFrame ~= nil then
                indexBuffFrame:Hide()
                indexBuffFrame:SetScript("OnEnter", nil)
                indexBuffFrame:SetScript("OnClick", nil)
                indexBuffFrame:SetScript("OnLeave", nil)
            else
                break
            end
        end
    end
    updatePlayerDebuffs(x, y)
end
--]]
local function Buff(self, data, buffIndex)
    --Buff icon
    self.icon:SetTexture(data["icon"])

    if data["isStealable"] then
        self.outline:SetVertexColor(1, 1, 1)
    else
        self.outline:SetVertexColor(0, 0, 0)
    end

    local stacks = ""
    local duration = ""

    if data["stacks"] ~= nil and data["stacks"] > 0 then
        stacks = data["stacks"]
    end
    if data["duration"] ~= nil and data["duration"] > 0 then
        duration = TimeCount(data["timeRemaining"])
    end

    self.expires = data["expires"]
    self.duration = data["duration"]

    self.durationString:SetText(duration)
    self.stacksString:SetText(stacks)

    self:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetUnitBuff(self.unit, buffIndex)
            GameTooltip:Show()
        end
    )
    self:SetScript("OnLeave", GameTooltip_Hide)
end
GW.Buff = Buff

local function HighlightedDebuff(self, data, buffindex)
    if data["dispelType"] ~= nil then
        self.background:SetVertexColor(
            DEBUFF_COLOR[data["dispelType"]].r,
            DEBUFF_COLOR[data["dispelType"]].g,
            DEBUFF_COLOR[data["dispelType"]].b
        )
    else
        self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    end
    self.cooldown:SetDrawEdge(0)
    self.cooldown:SetDrawSwipe(1)
    self.cooldown:SetReverse(false)
    self.cooldown:SetHideCountdownNumbers(true)

    self.icon:SetTexture(data["icon"])

    local buffDur = ""
    local stacks = ""
    if data["count"] > 1 then
        stacks = data["count"]
    end
    if data["duration"] > 0 then
        buffDur = TimeCount(data["timeRemaining"])
    end

    self.expires = data["expires"]
    self.duration = data["duration"]
    self.cooldown:SetCooldown(data["expires"] - data["duration"], data["duration"])

    _G[self:GetName() .. "CooldownBuffDuration"]:SetText(buffDur)
    _G[self:GetName() .. "IconBuffStacks"]:SetText(stacks)

    self:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetUnitDebuff(self.unit, buffindex)
            GameTooltip:Show()
        end
    )
    self:SetScript("OnLeave", GameTooltip_Hide)
end
GW.HighlightedDebuff = HighlightedDebuff

local function Debuff(self, data, buffindex, filter)
    if data["dispelType"] ~= nil then
        self.background:SetVertexColor(
            DEBUFF_COLOR[data["dispelType"]].r,
            DEBUFF_COLOR[data["dispelType"]].g,
            DEBUFF_COLOR[data["dispelType"]].b
        )
    else
        self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    end
    self.cooldown:SetDrawEdge(0)
    self.cooldown:SetDrawSwipe(1)
    self.cooldown:SetReverse(false)
    self.cooldown:SetHideCountdownNumbers(true)

    self.icon:SetTexture(data["icon"])

    local buffDur = ""
    local stacks = ""
    if data["count"] ~= nil and data["count"] > 1 then
        stacks = data["count"]
    end
    if data["duration"] ~= nil and data["duration"] > 0 then
        buffDur = TimeCount(data["timeRemaining"])
    end

    self.expires = data["expires"]
    self.duration = data["duration"]
    self.cooldown:SetCooldown(0, 0)

    _G[self:GetName() .. "CooldownBuffDuration"]:SetText(buffDur)
    _G[self:GetName() .. "IconBuffStacks"]:SetText(stacks)

    self:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetUnitDebuff(self.unit, buffindex, filter)
            GameTooltip:Show()
        end
    )
    self:SetScript("OnLeave", GameTooltip_Hide)
end
GW.Debuff = Debuff

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

    local fgw = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
    fgw:SetFrameRef("GwPlayerAuraFrame", player_buff_frame)
    fgw:SetFrameRef("UIParent", UIParent)
    if GwMultiBarBottomRight then
        fgw:SetFrameRef("MultiBarBottomRight", GwMultiBarBottomRight)
        fgw:SetAttribute(
            "_onstate-combat",
            [=[
        
            if self:GetFrameRef('MultiBarBottomRight'):IsShown()==false then
                return
            end
        
            self:GetFrameRef('GwPlayerAuraFrame'):ClearAllPoints()
            if newstate == 'show' then
                self:GetFrameRef('GwPlayerAuraFrame'):SetPoint('BOTTOMLEFT',self:GetFrameRef('UIParent'),'BOTTOM',53,215)
            end
            ]=]
        )
        RegisterStateDriver(fgw, "combat", "[combat] show; hide")
    end

    AddActionBarCallback(UpdatePlayerBuffFrame)
    UpdatePlayerBuffFrame()

    LoadAuras(GwPlayerAuraFrame, GwPlayerAuraFrame, "player")
    UpdateBuffLayout(GwPlayerAuraFrame, event, "player")

    -- show/hide stuff with override bar
    OverrideActionBar:HookScript(
        "OnShow",
        function()
            player_buff_frame:SetAlpha(0)
        end
    )
    OverrideActionBar:HookScript(
        "OnHide",
        function()
            player_buff_frame:SetAlpha(1)
        end
    )
end
GW.LoadBuffs = LoadBuffs
