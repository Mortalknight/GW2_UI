local _, GW = ...
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local GetSetting = GW.GetSetting
local TimeCount = GW.TimeCount
local UnitAura = GW.Libs.LCD.UnitAuraWithBuffs

local textureMapping = {
    [1] = 16,    --Main hand
    [2] = 17,    --Off-hand
    [3] = 18,    --Ranged
}

local function sortAuras(a, b)
    if a["caster"] and b["caster"] and a["caster"] == b["caster"] then
        return a["timeremaning"] < b["timeremaning"]
    end

    return (b["caster"] ~= "player" and a["caster"] == "player")
end
GW.AddForProfiling("unitframes", "sortAuras", sortAuras)

local function sortAuraList(auraList)
    table.sort(
        auraList,
        function(a, b)
            return sortAuras(a, b)
        end
    )

    return auraList
end
GW.AddForProfiling("unitframes", "sortAuraList", sortAuraList)

local buffList = {}
for i = 1, 40 do
    buffList[i] = {}
end
local function getBuffs(unit, filter)
    if filter == nil then
        filter = ""
    end
    local tempCounter = 1
    for i = 1, 40 do
        table.wipe(buffList[i])
        if UnitAura(unit, i, "HELPFUL") ~= nil then
            local bli = buffList[i]
            tempCounter = tempCounter + 1
            bli["id"] = i

            bli["name"],
                bli["icon"],
                bli["count"],
                bli["dispelType"],
                bli["duration"],
                bli["expires"],
                bli["caster"],
                bli["isStealable"],
                bli["shouldConsolidate"],
                bli["spellID"] = UnitAura(unit, i, "HELPFUL")

            bli["timeremaning"] = bli["expires"] - GetTime()

            if bli["duration"] <= 0 then
                bli["timeremaning"] = 500001
            end
        end
    end

    --Add temp weaponbuffs if unit is player
    if unit == "player" then
        local RETURNS_PER_ITEM = 4
        local numVals = select("#", GetWeaponEnchantInfo())
        local numItems = numVals / RETURNS_PER_ITEM

        if numItems > 0 then
            TemporaryEnchantFrame:Hide()
            for itemIndex = numItems, 1, -1 do    --Loop through the items from the back
                local hasEnchant, enchantExpiration, enchantCharges = select(RETURNS_PER_ITEM * (itemIndex - 1) + 1, GetWeaponEnchantInfo())
                if hasEnchant then
                    tempCounter = tempCounter + 1

                    if buffList[tempCounter] then
                        table.wipe(buffList[tempCounter])
                    else
                        buffList[tempCounter] = {}
                    end
                    local atc = buffList[tempCounter]
                    atc["id"] = tempCounter
                    atc["name"] = "WeaponTempEnchant"
                    atc["icon"] = GetInventoryItemTexture("player", textureMapping[itemIndex])
                    atc["spellID"] = textureMapping[itemIndex]
                    atc["caster"] = "player"
                    atc["duration"] = enchantExpiration
                    atc["dispelType"] = "Curse"

                    -- Show buff durations if necessary
                    if enchantExpiration then
                        atc["expires"] = enchantExpiration / 1000
                        atc["timeremaning"] = atc["expires"]
                    else
                        atc["timeremaning"] = 500001
                    end
                end
            end
        end
    end

    return sortAuraList(buffList)
end
GW.AddForProfiling("unitframes", "getBuffs", getBuffs)

local debuffList = {}
for i = 1, 40 do
    debuffList[i] = {}
end
local function getDebuffs(unit, filter)
    for i = 1, 40 do
        table.wipe(debuffList[i])
        if UnitAura(unit, i, filter) ~= nil then
            local dbi = debuffList[i]
            dbi["id"] = i

            dbi["name"],
                dbi["icon"],
                dbi["count"],
                dbi["dispelType"],
                dbi["duration"],
                dbi["expires"],
                dbi["caster"],
                dbi["isStealable"],
                dbi["shouldConsolidate"],
                dbi["spellID"] = UnitAura(unit, i, filter)

                dbi["timeremaning"] = dbi["expires"] - GetTime()

            if dbi["duration"] <= 0 then
                dbi["timeremaning"] = 500001
            end
        end
    end

    return sortAuraList(debuffList)
end
GW.AddForProfiling("unitframes", "getDebuffs", getDebuffs)

local function setAuraType(self, typeAura)
    if self.typeAura == typeAura then
        return
    end

    if typeAura == "smallbuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
        self.duration:SetFont(UNIT_NAME_FONT, 11)
        self.stacks:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
    end

    if typeAura == "bigBuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
        self.duration:SetFont(UNIT_NAME_FONT, 14)
        self.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
    end

    self.typeAura = typeAura
end
GW.AddForProfiling("unitframes", "setAuraType", setAuraType)

local function setBuffData(self, buffs, i, oldBuffs)
    if not self or not buffs then
        return false
    end
    local b = buffs[i]
    if b == nil or b["name"] == nil then
        return false
    end

    local stacks = ""
    local duration = ""

    if b["caster"] == "player" and (b["duration"] > 0 and b["duration"] < 120) then
        setAuraType(self, "bigBuff")

        self.cooldown:SetCooldown(b["expires"] - b["duration"], b["duration"])
    else
        setAuraType(self, "smallbuff")
    end

    if b["count"] ~= nil and b["count"] > 1 then
        stacks = b["count"]
    end
    if b["timeremaning"] ~= nil and b["timeremaning"] > 0 and b["timeremaning"] < 500000 then
        duration = TimeCount(b["timeremaning"])
    end

    if b["expires"] < 1 or b["timeremaning"] > 500000 then
        self.expires = nil
    else
        self.expires = b["expires"]
    end

    if self.auraType == "debuff" or b["name"] == "WeaponTempEnchant" then
        if b["dispelType"] ~= nil then
            self.background:SetVertexColor(
                DEBUFF_COLOR[b["dispelType"]].r,
                DEBUFF_COLOR[b["dispelType"]].g,
                DEBUFF_COLOR[b["dispelType"]].b
            )
        else
            self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    else
        if b["isStealable"] then
            self.background:SetVertexColor(1, 1, 1)
        else
            self.background:SetVertexColor(0, 0, 0)
        end
    end

    if b["name"] == "WeaponTempEnchant" then
        self.auraid = b["spellID"]
    else
        self.auraid = b["id"]
    end
    self.isTempEnchant = b["name"]
    self.duration:SetText(duration)
    self.stacks:SetText(stacks)
    self.icon:SetTexture(b["icon"])

    return true
end
GW.AddForProfiling("unitframes", "setBuffData", setBuffData)

local function auraAnimateIn(self)
    local endWidth = self:GetWidth()

    GW.AddToAnimation(
        self:GetName(),
        endWidth * 2,
        endWidth,
        GetTime(),
        0.2,
        function(step)
            self:SetSize(step, step)
        end
    )
end
GW.AddForProfiling("unitframes", "auraAnimateIn", auraAnimateIn)

local function UpdateBuffLayout(self, event, anchorPos)
    local minIndex = 1
    local maxIndex = 80

    local isPlayer = false
    local playerGrowDirection 
    if anchorPos and anchorPos == "player" then
        isPlayer = true
        playerGrowDirection = GetSetting("PlayerBuffFrame_GrowDirection")
        self.debuffFilter = "HARMFUL"
    elseif anchorPos ~= "player" then
        if self.displayBuffs ~= true then
            minIndex = 40
        end
        if self.displayDebuffs ~= true then
            maxIndex = 40
        end
    end

    local marginX = 3
    local marginY = 20

    local usedWidth = 0
    local usedHeight = 0

    local smallSize
    local bigSize
    local maxSize
    
    if isPlayer then
        if MainMenuBarArtFrame.gw_Bar2 and MainMenuBarArtFrame.gw_Bar2.gw_IsEnabled and MainMenuBarArtFrame.gw_Bar2.gw_FadeShowing and GwPlayerAuraFrame and not GwPlayerAuraFrame.isMoved then
            maxSize = MultiBarBottomRight:GetWidth()
        else
            maxSize = self:GetWidth()
        end
        smallSize = 28
        bigSize = 32
    else
        maxSize = self.auras:GetWidth()
        smallSize = 20
        bigSize = 28
    end

    local lineSize = smallSize

    local auraList = getBuffs(self.unit)
    local dbList = getDebuffs(self.unit, self.debuffFilter)

    local saveAuras = {}

    saveAuras["buff"] = {}
    saveAuras["debuff"] = {}

    local fUnit
    if isPlayer then
        fUnit = "player"
    else
        fUnit = self.unit
    end

    local isBuff = false
    for frameIndex = minIndex, maxIndex do
        local index
        if isPlayer then
            index = 41 - frameIndex
        else
            index = frameIndex
        end
        local list = auraList
        local newAura = true

        if frameIndex > 40 then
            if isPlayer then
                index = 41 - (frameIndex - 40)
            else
                index = frameIndex - 40
            end
        end

        local frame = _G["Gw" .. fUnit .. "buffFrame" .. index]

        if frameIndex > 40 then
            frame = _G["Gw" .. fUnit .. "debuffFrame" .. index]
            list = dbList
        end
        if frameIndex == 41 and isBuff then
            usedWidth = 0
            usedHeight = usedHeight + lineSize + marginY
            lineSize = smallSize
        end

        if setBuffData(frame, list, index) then
            if frameIndex <= 40 then
                isBuff = true
            end
            if not frame:IsShown() then
                frame:Show()
            end

            local isBig = frame.typeAura == "bigBuff"

            local size = smallSize
            if isBig then
                size = bigSize
                lineSize = bigSize

                for k, v in pairs(self.saveAuras[frame.auraType]) do
                    if v == list[index]["name"] then
                        newAura = false
                    end
                end
                self.animating = false
                saveAuras[frame.auraType][#saveAuras[frame.auraType] + 1] = list[index]["name"]
            end
            
            usedWidth = usedWidth + size + marginX
            if maxSize < usedWidth then
                usedWidth = 0
                usedHeight = usedHeight + lineSize + marginY
                lineSize = smallSize
            end
            if usedWidth > 0 then 
                usedWidth2 = usedWidth - size - marginX
            else
                usedWidth2 = usedWidth
            end
            local px = usedWidth2  + (size / 2)
            local py = usedHeight + (size / 2)
            if not anchorPos then
                if self.auraPositionTop then
                    frame:SetPoint("CENTER", self.auras, "TOPLEFT", px, py)
                else
                    frame:SetPoint("CENTER", self.auras, "TOPLEFT", px, -py)
                end
            elseif anchorPos == "pet" then
                frame:SetPoint("CENTER", self.auras, "BOTTOMRIGHT", -px, py)
            elseif anchorPos == "player" then
                if playerGrowDirection == "UP" then
                    frame:SetPoint("CENTER", self, "BOTTOMRIGHT", -px, py)
                else
                    frame:SetPoint("CENTER", self, "BOTTOMRIGHT", -px, -py)
                end
            end

            frame:SetSize(size, size)
            if newAura and isBig and event == "UNIT_AURA" then
                auraAnimateIn(frame)
            end

            if usedWidth == 0 then 
                usedWidth = usedWidth + size + marginX
            end
        elseif frame and frame:IsShown() then
            frame:Hide()
        end
    end

    self.saveAuras = saveAuras
end
GW.UpdateBuffLayout = UpdateBuffLayout

local function auraFrame_OnUpdate(self, elapsed)
    if self.throt < 0 and self.expires ~= nil and self:IsShown() then
        self.throt = 0.2
        self.duration:SetText(TimeCount(self.expires - GetTime()))
    else
        self.throt = self.throt - elapsed
    end
end
GW.AddForProfiling("unitframes", "auraFrame_OnUpdate", auraFrame_OnUpdate)

local function auraFrame_OnEnter(self)
    if self:IsShown() and self.auraid ~= nil and self.unit ~= nil then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        if self.auraType == "buff" then
            GameTooltip:SetUnitBuff(self.unit, self.auraid)
        else
            GameTooltip:SetUnitDebuff(self.unit, self.auraid, self.debuffFilter)
        end
        GameTooltip:Show()
    end
end
GW.AddForProfiling("unitframes", "auraFrame_OnEnter", auraFrame_OnEnter)

local function auraFrame_OnClick(self, button, down)
    if not InCombatLockdown() and self.auraType == "buff" and button == "RightButton" and self.unit == "player" then
        CancelUnitBuff("player", self.auraid)
    end
end
GW.AddForProfiling("unitframes", "auraFrame_OnClick", auraFrame_OnClick)

local function CreateAuraFrame(name, parent)
    local f = CreateFrame("Button", name, parent, "GwAuraFrame")
    local fs = f.status

    f.typeAura = "smallbuff"
    f.cooldown:SetDrawEdge(0)
    f.cooldown:SetDrawSwipe(1)
    f.cooldown:SetReverse(false)
    f.cooldown:SetHideCountdownNumbers(true)
    f.throt = -1

    fs.stacks:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
    fs.duration:SetFont(UNIT_NAME_FONT, 10)
    fs.duration:SetShadowOffset(1, -1)

    fs:GetParent().duration = fs.duration
    fs:GetParent().stacks = fs.stacks
    fs:GetParent().icon = fs.icon

    f:SetScript("OnUpdate", auraFrame_OnUpdate)
    f:SetScript("OnEnter", auraFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)
    f:SetScript("OnClick", auraFrame_OnClick)
    --f:SetAttribute('type2', 'cancelaura')

    return f
end
GW.CreateAuraFrame = CreateAuraFrame

local function LoadAuras(f, a, u)
    local unit = u or f.unit
    for i = 1, 40 do
        local frame = CreateAuraFrame("Gw" .. unit .. "buffFrame" .. i, a)
        frame.unit = unit
        frame.auraType = "buff"
        frame = CreateAuraFrame("Gw" .. unit .. "debuffFrame" .. i, a)
        frame.unit = unit
        frame.auraType = "debuff"
    end
    f.saveAuras = {}
    f.saveAuras["buff"] = {}
    f.saveAuras["debuff"] = {}
end
GW.LoadAuras = LoadAuras
