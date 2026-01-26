local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()

if not GW.Retail then return end

local stealableColor = CreateColor(DebuffColors.Stealable.r, DebuffColors.Stealable.g, DebuffColors.Stealable.b)
local normalColor = CreateColor(0, 0, 0)

local function UpdateTooltip(self)
    if GameTooltip:IsForbidden() then return end

    GameTooltip:SetUnitAuraByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
end

local function auraFrame_OnEnter(self)
    if GameTooltip:IsForbidden() or not self:IsVisible() then return end
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    self:UpdateTooltip()
end

local function CreateAuraFrame(name, parent)
    local f = CreateFrame("Button", name, parent, "GwAuraFrame")

    f.typeAura = "smallbuff"
    f.Cooldown:SetDrawEdge(0)
    f.Cooldown:SetDrawSwipe(1)
    f.Cooldown:SetReverse(false)
    f.Cooldown:SetHideCountdownNumbers(false)

    f.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -1)

    local r = {f.Cooldown:GetRegions()}
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            f.duration = c
            f.duration:SetPoint("TOPLEFT", f.status, "BOTTOMLEFT", -10, -2)
            f.duration:SetPoint("TOPRIGHT", f.status, "BOTTOMRIGHT", 10, 0)
            f.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
            f.duration:SetShadowOffset(1, -1)
            break
        end
    end


    f.status.duration:Hide()
    f.stacks = f.status.stacks
    f.icon = f.status.icon

    f.UpdateTooltip = UpdateTooltip
    f:SetScript("OnEnter", auraFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end

local function sortAuras(a, b)
    if a.isPlayerAura ~= b.isPlayerAura then
		return a.isPlayerAura
	end

    return a.auraInstanceID < b.auraInstanceID
end

local function sortAurasRevert(a, b)
   if a.isPlayerAura ~= b.isPlayerAura then
		return a.isPlayerAura
	end

    return a.auraInstanceID > b.auraInstanceID
end

local function sortAuraList(auraList, revert)
    if revert then
        table.sort(auraList, sortAurasRevert)
    else
        table.sort(auraList, sortAuras)
    end

    return auraList
end

local function setAuraType(self, typeAura)
    if self.typeAura == typeAura then
        return
    end

    if typeAura == "smallbuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
        self.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -1)
        self.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -1)
    elseif typeAura == "bigBuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
        self.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        self.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    end

    self.typeAura = typeAura
end

local function auraAnimateIn(self, size)
    GW.AddToAnimation(
        self:GetDebugName(),
        size * 2,
        size,
        GetTime(),
        0.2,
        function(step)
            self:SetSize(step, step)
        end
    )
end

local function SetPosition(element, from, to, unit, isInvert, auraPositon)
    local anchorTo = unit == "pet" and "TOPRIGHT" or isInvert and "TOPRIGHT" or "TOPLEFT"
    local growthx = isInvert and -1 or (unit == "pet" and -1) or 1
    local growthy = (auraPositon == 'DOWN' and -1) or 1
    local marginY = 20
    local marginX = 3
    local smallSize = 20
    local maxWidth = element.maxWidth
    local usedWidth = 0
    local usedWidth2 = 0
    local maxHeightInRow = smallSize
    local usedHeight = 0
    local lineSize = smallSize
    local firstDebuff = false
    local handledBuff = false

    for i = from, to do
        local button = element[i]
        if(not button) then break end

        if button.isHarmful and not firstDebuff then
            firstDebuff = true
            -- new line for debuffs
            usedWidth = 0
            usedHeight = handledBuff and (usedHeight + lineSize + marginY) or 0
            lineSize = smallSize
        else
            handledBuff = true
        end

        usedWidth = usedWidth + button.neededSize + marginX
        if maxWidth < usedWidth then
            usedWidth = 0
            maxHeightInRow = button.neededSize
            usedHeight = usedHeight + lineSize + marginY
            lineSize = smallSize
        elseif button.neededSize > maxHeightInRow then
            maxHeightInRow = button.neededSize
        end
        if usedWidth > 0 then
            usedWidth2 = usedWidth - button.neededSize - marginX
        else
            usedWidth2 = usedWidth
        end
        local px = usedWidth2 + (button.neededSize / 2)
        local py = usedHeight + (maxHeightInRow / 2)

        button:ClearAllPoints()
        button:SetPoint("CENTER", element, anchorTo, px * growthx, py * growthy)

        if usedWidth == 0 then
            usedWidth = usedWidth + button.neededSize + marginX
        end
    end
end

local function updateAura(element, unit, data, position, isBuff)
    if not data then return end

    local button = element[position]
    if not button then
        button = CreateAuraFrame(element:GetDebugName() .. 'Button' .. position, element)

        table.insert(element, button)
        element.createdButtons = element.createdButtons + 1
    end

    button.smallSize = element.smallSize
    button.bigSize = element.bigSize
    local size = button.smallSize

    -- for tooltips
    button.auraInstanceID = data.auraInstanceID

    if data.isPlayerAura then
        setAuraType(button, "bigBuff")
        size = button.bigSize
        local duration = not element.hideDuration and C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID) or nil
		if duration then
            button.Cooldown:SetCooldownFromDurationObject(duration)
            button.Cooldown:Show()
        else
            button.Cooldown:Hide()
        end
    else
        setAuraType(button, "smallbuff")
        button.Cooldown:Hide()
        data.newBuffAnimation = false
    end

    if isBuff then
        if not UnitCanCooperate("player", unit) then
            button.background:SetVertexColorFromBoolean(data.isStealable, stealableColor, normalColor)
        else
            button.background:SetVertexColor(normalColor:GetRGB())
        end
    else
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
        if color then
            button.background:SetVertexColor(color:GetRGB())
        else
            button.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    end
    button.background:Show()

    button.icon:SetTexture(data.icon)
    button.stacks:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(unit, data.auraInstanceID, 2, 999))
    button:SetSize(size, size)
    if data.newBuffAnimation == true then
        auraAnimateIn(button, size)
        data.newBuffAnimation = false
    end

    button:EnableMouse(true)
    button:Show()

    button.neededSize = size
end

local function FilterAura(element, unit, data, isBuff)
    if (element.onlyShowPlayer and data.isPlayerAura) or not element.onlyShowPlayer then
		return true
	end
end

local function processData(unit, data, filter, newBuffAnimation)
    if not data then return end

    data.isPlayerAura = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, filter .. '|PLAYER')
    data.newBuffAnimation = newBuffAnimation

    return data
end

local function UpdateBuffLayout(self, event, unit, updateInfo)
    if self.unit ~= unit then return end

    local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

    local auras = self.auras

    local buffsChanged = false
    local numBuffs = self.displayBuffs or 32
    local buffFilter = "HELPFUL"

    local debuffsChanged = false
    local numDebuffs = self.displayDebuffs or 40
    local debuffFilter = self.debuffFilter or "HARMFUL"

    local numTotal = auras.numTotal or numBuffs + numDebuffs

    if isFullUpdate then
        auras.allBuffs = table.wipe(auras.allBuffs or {})
        auras.activeBuffs = table.wipe(auras.activeBuffs or {})
        buffsChanged = true

        local slots = {C_UnitAuras.GetAuraSlots(unit, buffFilter)}
        for i = 2, #slots do -- #1 return is continuationToken, we don't care about it
            local data = processData(unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]), buffFilter)
            if data then
                auras.allBuffs[data.auraInstanceID] = data

                if ((auras.FilterAura or FilterAura)(auras, unit, data, true)) then
                    auras.activeBuffs[data.auraInstanceID] = true
                end
            end
        end

        auras.allDebuffs = table.wipe(auras.allDebuffs or {})
        auras.activeDebuffs = table.wipe(auras.activeDebuffs or {})
        debuffsChanged = true

        slots = {C_UnitAuras.GetAuraSlots(unit, debuffFilter)}
        for i = 2, #slots do
            local data = processData(unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]), debuffFilter)
            if data then
                auras.allDebuffs[data.auraInstanceID] = data

                if ((auras.FilterAura or FilterAura)(auras, unit, data, false)) then
                    auras.activeDebuffs[data.auraInstanceID] = true
                end
            end
        end
    else
        auras.allBuffs = auras.allBuffs or {}
        auras.activeBuffs = auras.activeBuffs or {}
        auras.allDebuffs = auras.allDebuffs or {}
        auras.activeDebuffs = auras.activeDebuffs or {}
        auras.sortedBuffs = auras.sortedBuffs or {}
        auras.sortedDebuffs = auras.sortedDebuffs or {}

        if updateInfo.addedAuras then
            for _, data in next, updateInfo.addedAuras do
                if (not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, buffFilter)) then
                    data = processData(unit, data, buffFilter, true)
                    if data then
                        auras.allBuffs[data.auraInstanceID] = data

                        if ((auras.FilterAura or FilterAura)(auras, unit, data, true)) then
                            auras.activeBuffs[data.auraInstanceID] = true
                            buffsChanged = true
                        end
                    end
                elseif (not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, debuffFilter)) then
                    data = processData(unit, data, debuffFilter)
                    if data then
                        auras.allDebuffs[data.auraInstanceID] = data

                        if ((auras.FilterAura or FilterAura)(auras, unit, data, false)) then
                            auras.activeDebuffs[data.auraInstanceID] = true
                            debuffsChanged = true
                        end
                    end
                end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceID in next, updateInfo.updatedAuraInstanceIDs do
                if(auras.allBuffs[auraInstanceID]) then
                    auras.allBuffs[auraInstanceID] = processData(unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID), buffFilter)

                    -- only update if it's actually active
                    if(auras.activeBuffs[auraInstanceID]) then
                        auras.activeBuffs[auraInstanceID] = true
                        buffsChanged = true
                    end
                elseif(auras.allDebuffs[auraInstanceID]) then
                    auras.allDebuffs[auraInstanceID] = processData(unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID), debuffFilter)

                    if(auras.activeDebuffs[auraInstanceID]) then
                        auras.activeDebuffs[auraInstanceID] = true
                        debuffsChanged = true
                    end
                end
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
                if(auras.allBuffs[auraInstanceID]) then
                    auras.allBuffs[auraInstanceID] = nil

                    if(auras.activeBuffs[auraInstanceID]) then
                        auras.activeBuffs[auraInstanceID] = nil
                        buffsChanged = true
                    end
                elseif(auras.allDebuffs[auraInstanceID]) then
                    auras.allDebuffs[auraInstanceID] = nil

                    if(auras.activeDebuffs[auraInstanceID]) then
                        auras.activeDebuffs[auraInstanceID] = nil
                        debuffsChanged = true
                    end
                end
            end
        end
    end

    if buffsChanged or debuffsChanged then
        local numVisible

        if buffsChanged then
            -- instead of removing auras one by one, just wipe the tables entirely
            -- and repopulate them, multiple table.remove calls are insanely slow
            auras.sortedBuffs = table.wipe(auras.sortedBuffs or {})

            for auraInstanceID in next, auras.activeBuffs do
                table.insert(auras.sortedBuffs, auras.allBuffs[auraInstanceID])
            end

            auras.sortedBuffs = sortAuraList(auras.sortedBuffs, self.frameInvert)

            numVisible = math.min(numBuffs, numTotal, #auras.sortedBuffs)

            for i = 1, numVisible do
                updateAura(auras, unit, auras.sortedBuffs[i], i, true)
            end
        else
            numVisible = math.min(numBuffs, numTotal, #auras.sortedBuffs)
        end

        -- do it before adding the gap because numDebuffs could end up being 0
        if debuffsChanged then
            auras.sortedDebuffs = table.wipe(auras.sortedDebuffs or {})

            for auraInstanceID in next, auras.activeDebuffs do
                table.insert(auras.sortedDebuffs, auras.allDebuffs[auraInstanceID])
            end

            auras.sortedDebuffs = sortAuraList(auras.sortedDebuffs, self.frameInvert)
        end

        numDebuffs = math.min(numDebuffs, numTotal - numVisible, #auras.sortedDebuffs)

        -- any changes to buffs will affect debuffs, so just redraw them even if nothing changed
        for i = 1, numDebuffs do
            updateAura(auras, unit, auras.sortedDebuffs[i], numVisible + i, false)
        end

        numVisible = numVisible + numDebuffs
        local visibleChanged = false

        if numVisible ~= auras.visibleButtons then
            auras.visibleButtons = numVisible
            visibleChanged = true
        end

        for i = numVisible + 1, #auras do
            auras[i]:Hide()
            auras[i]:SetScript("OnUpdate", nil)
        end

        if event == "ForceUpdate" or visibleChanged or auras.createdButtons > auras.anchoredButtons then
            local auraPositon = "TOP"
            if unit == "pet" then
                if self.auraPositionUnder == true then
                    auraPositon = "DOWN"
                end
            else
                if not self.auraPositionTop then
                    auraPositon = "DOWN"
                end
            end
            (auras.SetPosition or SetPosition) (auras, 1, numVisible, unit, self.frameInvert, auraPositon)
        end
    end
end
GW.UpdateBuffLayout = UpdateBuffLayout

local function ForceUpdate(element)
    local parent = element:GetParent()
    UpdateBuffLayout(parent, "ForceUpdate", parent.unit)
end

-- No use for player (not secure)
local function LoadAuras(self)
    self.auras.visibleButtons = 0
    self.auras.createdButtons = 0
    self.auras.anchoredButtons = 0
    self.auras.ForceUpdate = ForceUpdate
    self.auras.__owner = self

    self.auras.maxWidth = self.auras:GetWidth()

    self.auras.dispelColorCurve = C_CurveUtil.CreateColorCurve()
    self.auras.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
    for _, dispelIndex in next, GW.DispelType do
        if GW.DebuffColors[dispelIndex] then
            self.auras.dispelColorCurve:AddPoint(dispelIndex, GW.DebuffColors[dispelIndex])
        end
    end

end
GW.LoadAuras = LoadAuras
