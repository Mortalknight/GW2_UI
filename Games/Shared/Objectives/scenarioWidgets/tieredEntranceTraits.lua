---@class GW2
local GW = select(2, ...)

local LIST_ROW_SPACING = 40
local LIST_SAFE_WIDTH = 300

GwTieredEntranceTraitsContainerMixin = {}
GwTieredEntranceTraitsListMixin = {}
GwTieredEntranceTraitSpellMixin = {}

function GwTieredEntranceTraitsContainerMixin:OnHide()
    self.List:Hide()
    self.Arrow:Hide()
end

function GwTieredEntranceTraitsContainerMixin:OnClick()
    local showList = not self.List:IsShown()
    if showList then
        if self.needSet then
            self.needSet = nil
            self.List:SetSpells(self.spells or {})
        end
        self:UpdateAlignment()
    end

    self.List:SetShown(showList)
    self.Arrow:SetShown(showList)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function GwTieredEntranceTraitsContainerMixin:SetSpells(spells)
    self.spells = spells
    self.numTraits = spells and #spells or 0
    self.needSet = true
    self.List:Hide()
    self.Arrow:Hide()

    local buttonText = SCENARIO_CHALLENGES_BUTTON
    self.Text:SetFormattedText(buttonText, self.numTraits)
    self.Text:SetTextColor(0.08, 0.07, 0.05, 1)
    self.Text:SetShadowColor(1, 1, 1, 0.35)
    self.Text:SetShadowOffset(1, -1)

    local hasTraits = self.numTraits > 0
    self:SetEnabled(hasTraits)
    self:SetAlpha(hasTraits and 1 or 0.55)
end

function GwTieredEntranceTraitsContainerMixin:UpdateAlignment()
    local left = self:GetLeft()
    local isOnLeftSide = left and left < LIST_SAFE_WIDTH
    if isOnLeftSide == self.isOnLeftSide then
        return
    end

    self.isOnLeftSide = isOnLeftSide
    self.List:ClearAllPoints()
    self.Arrow:ClearAllPoints()

    if isOnLeftSide then
        self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 1)
        self.Arrow:SetText(">")
        self.Arrow:SetPoint("LEFT", self, "RIGHT", -1, 0)
    else
        self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
        self.Arrow:SetText("<")
        self.Arrow:SetPoint("RIGHT", self, "LEFT", 1, 0)
    end

    self.Arrow:SetShadowColor(1, 1, 1, 0.5)
    self.Arrow:SetShadowOffset(1, -1)
end

function GwTieredEntranceTraitsListMixin:OnLoad()
    self.framePool = CreateFramePool("Frame", self, "GwTieredEntranceTraitSpellTemplate")
    self.stride = 6
    self.paddingX = 8
    self.paddingY = 8
    self.topPadding = 20
    self.bottomPadding = 20
end

function GwTieredEntranceTraitsListMixin:CalculateHeight(numTraits)
    local rows = math.max(math.ceil(math.max(numTraits, 1) / self.stride), 1)

    return (rows * LIST_ROW_SPACING) + ((rows - 1) * self.paddingY) + self.topPadding + self.bottomPadding
end

function GwTieredEntranceTraitsListMixin:SetSpells(spells)
    self.framePool:ReleaseAll()
    self:SetHeight(self:CalculateHeight(#spells))

    for i, spellID in ipairs(spells) do
        local iconTexture = C_Spell.GetSpellTexture(spellID)
        if iconTexture then
            local frame = self.framePool:Acquire()
            local col = (i - 1) % self.stride
            local row = math.floor((i - 1) / self.stride)

            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", self, "TOPLEFT", 27 + (col * LIST_ROW_SPACING), -self.topPadding - (row * (LIST_ROW_SPACING + self.paddingY)))
            frame.Icon:SetTexture(iconTexture)
            frame.spellID = spellID

            if not frame.mask then
                frame.mask = frame:CreateMaskTexture()
                frame.mask:SetAllPoints(frame.Icon)
                frame.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                frame.Icon:AddMaskTexture(frame.mask)
            end

            frame:Show()
        end
    end
end

function GwTieredEntranceTraitSpellMixin:OnEnter()
    if not self.spellID then return end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(self.spellID)
    GameTooltip:Show()
end

function GwTieredEntranceTraitSpellMixin:OnLeave()
    GameTooltip_Hide()
end
