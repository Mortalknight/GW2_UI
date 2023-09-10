local _, ns = ...
local oUF = ns.oUF
local spellIDs = {}
local spellBookSearched = 0

local function GridShowBuffIcon(parent, btnIndex, x, y, icon, index)
    local size = 14
    local element = parent.MissingBuffFrame
    local marginX, marginY = x * (size + 2), y * (size + 2) -- 16, 0
    local button = element[btnIndex]

    if not button then
        button = ns.oUF_CreateAuraButton(element, btnIndex)
        button:SetSize(size, size)
        ns.Construct_AuraIcon(parent, button)
        button.tooltipByIndex = index

        button:ClearAllPoints()
        button:SetPoint("TOPRIGHT", element, "TOPRIGHT", -(marginX + 3), -(marginY + 3))

        button.backdrop:Show()

        table.insert(element, button)
		element.createdButtons = element.createdButtons + 1
    end

    button.Icon:SetTexture(icon)

    button:Show()

    btnIndex, x, marginX = btnIndex + 1, x + 1, marginX + size + 2
    if marginX > parent:GetWidth() / 2 then
        x, y = 0, y + 1
    end

    return btnIndex, x, y
end

local function Update(self, event)
	 -- missing buffs
     if not UnitIsDeadOrGhost(self.unit) and self.missingAuras then
        local i, name, spellid = 1, nil, nil
        local btnIndex, x, y = 1, 0, 0
        -- do a reset
        for ii = 1, self.MissingBuffFrame.createdButtons do
            if self.MissingBuffFrame[ii] then
                self.MissingBuffFrame[ii]:Hide()
            end
        end
        for mName, _ in pairs(self.missingAuras) do
            self.missingAuras[mName] = true
        end
        repeat
            i, name = i + 1, UnitBuff(self.unit, i)
            if name and self.missingAuras[name] then
                self.missingAuras[name] = false
            end
        until not name

        i = 0
        for mName, v in pairs(self.missingAuras) do
            --print(mName, v)
            if v then
                spellBookSearched = 0
                while not spellIDs[mName] and spellBookSearched < MAX_SPELLS do
                    spellBookSearched = spellBookSearched + 1
                    name, _, spellid = GetSpellBookItemName(spellBookSearched, BOOKTYPE_SPELL)
                    if not name then
                        spellBookSearched = MAX_SPELLS
                    elseif self.missingAuras[name] and not spellIDs[name] then
                        spellIDs[name] = spellid
                    end
                end
                if spellIDs[mName] then
                    local icon = GetSpellTexture(spellIDs[mName])
                    i, btnIndex, x, y = i + 1, GridShowBuffIcon(self, btnIndex, x, y, icon, spellIDs[mName])
                end
            end
        end
    end
end

local function ForceUpdate(element)
	if(not element.__owner.unit) then return end
	return Update(element.__owner)
end

local function Enable(self)
    if self.MissingBuffFrame then
		self.MissingBuffFrame.ForceUpdate = ForceUpdate

        self:RegisterEvent("UNIT_AURA", Update, true)
        self.MissingBuffFrame:Show()
        self.MissingBuffFrame.createdButtons = self.MissingBuffFrame.createdButtons or 0
        self.MissingBuffFrame.__owner = self
        return true
    end
end

local function Disable(self)
    if self.MissingBuffFrame then
        self:UnregisterEvent("UNIT_AURA", Update, true)
        self.MissingBuffFrame:Hide()
    end
end

oUF:AddElement('MissingBuffIndicator', Update, Enable, Disable)
