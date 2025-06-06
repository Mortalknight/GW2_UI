local _, ns = ...
local oUF = ns.oUF
local chachedSpellInfo = {}

local function GridShowBuffIcon(parent, btnIndex, x, y, icon, spellId)
    local size = 14
    local element = parent.MissingBuffFrame
    local marginX, marginY = x * (size + 2), y * (size + 2)
    local button = element.createdButtons[btnIndex]

    if not button then
        button = ns.oUF_CreateAuraButton(element, btnIndex)
        button:SetSize(size, size)
        ns.Construct_AuraIcon(parent, button)
        button.tooltipBySpellId = spellId

        button:ClearAllPoints()
        button:SetPoint("TOPRIGHT", element, "TOPRIGHT", -(marginX + 3), -(marginY + 3))

        button.backdrop:Show()

        table.insert(element.createdButtons, button)
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
        local spellInfo
        local btnIndex, i, x, y = 1, 0, 0, 0
        -- do a reset
        for _, btn in pairs(self.MissingBuffFrame.createdButtons) do
            btn:Hide()
        end
        for mName, _ in pairs(self.missingAuras) do
            self.missingAuras[mName] = true
        end
        for mName, _ in pairs(self.missingAuras) do
            if AuraUtil.FindAuraByName(mName, self.unit, "HELPFUL") then
                self.missingAuras[mName] = false
            end
        end

        for mName, v in pairs(self.missingAuras) do
            if v then
                if not chachedSpellInfo[mName] then
                    spellInfo = C_Spell.GetSpellInfo(mName)
                    if spellInfo then
                        chachedSpellInfo[spellInfo.name] = {spellId = spellInfo.spellID, iconId = spellInfo.iconID}
                    end
                end
                if chachedSpellInfo[mName] then
                    i, btnIndex, x, y = i + 1, GridShowBuffIcon(self, btnIndex, x, y, chachedSpellInfo[mName].iconId, chachedSpellInfo[mName].spellId)
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

        self:RegisterEvent("UNIT_AURA", Update)
        self.MissingBuffFrame:Show()
        self.MissingBuffFrame.createdButtons = self.MissingBuffFrame.createdButtons or {}
        self.MissingBuffFrame.__owner = self
        return true
    end
end

local function Disable(self)
    if self.MissingBuffFrame then
        self:UnregisterEvent("UNIT_AURA", Update)
        self.MissingBuffFrame:Hide()
    end
end

oUF:AddElement('MissingBuffIndicator', Update, Enable, Disable)
