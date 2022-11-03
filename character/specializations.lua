local _, GW = ...

local SPEC_STAT_STRINGS = {
	[LE_UNIT_STAT_STRENGTH] = SPEC_FRAME_PRIMARY_STAT_STRENGTH,
	[LE_UNIT_STAT_AGILITY] = SPEC_FRAME_PRIMARY_STAT_AGILITY,
	[LE_UNIT_STAT_INTELLECT] = SPEC_FRAME_PRIMARY_STAT_INTELLECT,
}
local BASIC_SPELL_INDEX = 1
local SIGNATURE_SPELL_INDEX = 6
local SPEC_TEXTURE_FORMAT = "spec-thumbnail-%s"

local SPEC_FORMAT_STRINGS = {
	[62] = "mage-arcane",
	[63] = "mage-fire",
	[64] = "mage-frost",
	[65] = "paladin-holy",
	[66] = "paladin-protection",
	[70] = "paladin-retribution",
	[71] = "warrior-arms",
	[72] = "warrior-fury",
	[73] = "warrior-protection",
	[102] = "druid-balance",
	[103] = "druid-feral",
	[104] = "druid-guardian",
	[105] = "druid-restoration",
	[250] = "deathknight-blood",
	[251] = "deathknight-frost",
	[252] = "deathknight-unholy",
	[253] = "hunter-beastmastery",
	[254] = "hunter-marksmanship",
	[255] = "hunter-survival",
	[256] = "priest-discipline",
	[257] = "priest-holy",
	[258] = "priest-shadow",
	[259] = "rogue-assassination",
	[260] = "rogue-outlaw",
	[261] = "rogue-subtlety",
	[262] = "shaman-elemental",
	[263] = "shaman-enhancement",
	[264] = "shaman-restoration",
	[265] = "warlock-affliction",
	[266] = "warlock-demonology",
	[267] = "warlock-destruction",
	[268] = "monk-brewmaster",
	[269] = "monk-windwalker",
	[270] = "monk-mistweaver",
	[577] = "demonhunter-havoc",
	[581] = "demonhunter-vengeance",
	[1467] = "evoker-devastation",
	[1468] = "evoker-preservation",
}

local function GetSpellPreviewButton(self, index)
    local spellButton = self.spellPreviewButton[index]

    if spellButton then
        return spellButton
    end

    spellButton = CreateFrame("Button", nil, self)
    spellButton:SetSize(30, 30)
    spellButton.icon = spellButton:CreateTexture(nil, "ARTWORK")
    spellButton.icon:SetAllPoints()
    spellButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    spellButton:SetScript("OnEnter", function(self)
        if not self.spellID or not GetSpellInfo(self.spellID) then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(self.spellID, false, false, true)
        if self.extraTooltip then
            GameTooltip:AddLine(self.extraTooltip)
        end
        self.UpdateTooltip = self.OnEnter
        GameTooltip:Show()
    end)

    spellButton:SetScript("OnLeave", function(self)
        self.UpdateTooltip = nil
        GameTooltip:Hide()
    end)

    tinsert(self.spellPreviewButton, spellButton)

    return spellButton
end

local function updateActiveSpec(self)
    local newSpec = GetSpecialization()
    GW.SetSpecTabIconAndTooltip(GwSpellbookMenu.tab3)

    for i = 1, GetNumSpecializations() do
        local container = self.specs[i]

        container.specIndex = i
        if i == newSpec then
            container.active = true
            container.background:SetDesaturated(false)
        else
            container.active = false
            container.background:SetDesaturated(true)
        end
    end
end

local function SpecSwitchAnimation(self, playFlash)
    local newSpec = GetSpecialization()

    for i = 1, GetNumSpecializations() do
        local container = self.specs[i]

        container.specIndex = i
        if i == newSpec then
            if playFlash then
                container.AnimationHolder.ActivationFlashBack:Restart()
                container.playingActivationFlash = true
            else
                if container.playingActivationFlash then
                    container.AnimationHolder.ActivationFlashBack:Stop()
                    container.playingActivationFlash = false
                end
            end
            break
        end
    end
end

local function LoadSpecializations(parentContainer)
    parentContainer.title:SetFont(DAMAGE_TEXT_FONT, 14)
    parentContainer.title:SetTextColor(1, 1, 1, 1)
    parentContainer.title:SetShadowColor(0, 0, 0, 1)
    parentContainer.title:SetShadowOffset(1, -1)
    parentContainer.title:SetText(SPECIALIZATION)
    parentContainer:SetScript(
        "OnEvent",
        function(self)
            updateActiveSpec(self)
            SpecSwitchAnimation(self, true)
        end
    )
    parentContainer:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    parentContainer:RegisterEvent("UNIT_LEVEL")

    CreateFrame("Frame", "GwSpecContainerFrame", GwSpellbookFrame)
    GwSpecContainerFrame:SetPoint("TOPLEFT", GwSpellbookFrame, "TOPLEFT")
    GwSpecContainerFrame:SetPoint("BOTTOMRIGHT", GwSpellbookFrame, "BOTTOMRIGHT")

    parentContainer.specs = {}

    -- setup specs
    local txR, txT, txH, txMH
    txR = 588 / 1024
    txH = 140
    txMH = 512
    local specs = GetNumSpecializations()
    if specs > 3 then
        txMH = 1024
    end

    local fnContainer_OnUpdate = function(self, elapsed)
        if MouseIsOver(self) then
            local r = self.background:GetVertexColor()
            r = math.min(1, math.max(0, r + (1 * elapsed)))
            self.background:SetVertexColor(r, r, r, r)

            if not self.active then
                self.activateButton.hint:Show()
                self.activateButton.icon:SetBlendMode("ADD")
                self.activateButton.icon:SetAlpha(0.5)
            end
            return
        end
        self.activateButton.hint:Hide()
        self.activateButton.icon:SetBlendMode("BLEND")
        self.activateButton.icon:SetAlpha(1)
        self.background:SetVertexColor(0.7, 0.7, 0.7, 0.7)
    end
    local fnContainer_OnShow = function(self)
        self:SetScript("OnUpdate", fnContainer_OnUpdate)
    end
    local fnContainer_OnHide = function(self)
        self:SetScript("OnUpdate", nil)
        SpecSwitchAnimation(self:GetParent(), false)
    end
    local fnContainer_OnClick = function(self)
        if not self.active and C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
            SetSpecialization(self.specIndex)
        end
    end

    for i = 1, specs do
        local container = CreateFrame("Button", "GwSpecFrame" .. i, GwSpecContainerFrame, "GwSpecFrame")

        container:RegisterForClicks("AnyUp")
        container.activateButton.mask = container.activateButton:CreateMaskTexture()
        container.activateButton.mask:SetPoint("CENTER", container.activateButton.icon, "CENTER", 0, 0)
        container.activateButton.mask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        container.activateButton.mask:SetSize(80, 80)
        container.activateButton.icon:AddMaskTexture(container.activateButton.mask)
        container:SetScript("OnEnter", nil)
        container:SetScript("OnLeave", nil)
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnShow", fnContainer_OnShow)
        container:SetScript("OnHide", fnContainer_OnHide)
        container:SetScript("OnClick", fnContainer_OnClick)
        container:SetPoint("TOPLEFT", GwSpecContainerFrame, "TOPLEFT", 10, (-140 * i) + 98)
        container.spec = i

        local specID, name, description, _, role, primaryStat = GetSpecializationInfo(i, false, false, nil, GW.mysex)
        local atlasName = SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[specID])

        container.activateButton.roleIcon:ClearAllPoints()
        if role == "TANK" then
            container.activateButton.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank")
            container.activateButton.roleIcon:SetPoint("BOTTOMRIGHT", container.activateButton.icon, "BOTTOMRIGHT", -6, -6)
        elseif role == "HEALER" then
            container.activateButton.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer")
            container.activateButton.roleIcon:SetPoint("BOTTOMRIGHT", container.activateButton.icon, "BOTTOMRIGHT", -8, -5)
        elseif role == "DAMAGER" then
            container.activateButton.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps")
            container.activateButton.roleIcon:SetSize(30, 30)
            container.activateButton.roleIcon:SetPoint("BOTTOMRIGHT", container.activateButton.icon, "BOTTOMRIGHT", -3, -10)
        end

        if C_Texture.GetAtlasInfo(atlasName) then
            container.activateButton.icon:SetAtlas(atlasName)
        end

        container.info.specTitle:SetFont(DAMAGE_TEXT_FONT, 16)
        container.info.specTitle:SetTextColor(1, 1, 1, 1)
        container.info.specTitle:SetShadowColor(0, 0, 0, 1)
        container.info.specTitle:SetShadowOffset(1, -1)
        container.info.specDesc:SetFont(UNIT_NAME_FONT, 14)
        container.info.specDesc:SetTextColor(0.8, 0.8, 0.8, 1)
        container.info.specDesc:SetShadowColor(0, 0, 0, 1)
        container.info.specDesc:SetShadowOffset(1, -1)
        container.activateButton.hint:SetFont(DAMAGE_TEXT_FONT, 10)
        container.activateButton.hint:SetShadowColor(0, 0, 0, 1)
        container.activateButton.hint:SetShadowOffset(1, -1)

        container.info.specTitle:SetText(name)

        if primaryStat and primaryStat ~= 0 then
            container.info.specDesc:SetText(description .. "|n" .. SPEC_FRAME_PRIMARY_STAT:format(SPEC_STAT_STRINGS[primaryStat]))
        end

        txT = (i - 1) * txH
        container.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        container.spellPreviewButton = {}
        -- spell icons
        local bonuses = C_SpecializationInfo.GetSpellsDisplay(specID)
        local spellIndex = 1
        local yOffset = 10
        if bonuses then
            for i, bonus in ipairs(bonuses) do
                if i == BASIC_SPELL_INDEX then
                    local spellButton = GetSpellPreviewButton(container, spellIndex)
                    local _, icon = GetSpellTexture(bonus)
                    spellButton.icon:SetTexture(icon)
                    spellButton.spellID = bonus
                    spellButton:ClearAllPoints()
                    spellButton:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -yOffset, 10)
                    spellIndex = spellIndex + 1
                    yOffset = yOffset + 33
                elseif i == SIGNATURE_SPELL_INDEX then
                    local spellButton = GetSpellPreviewButton(container, spellIndex)
                    local _, icon = GetSpellTexture(bonus)
                    spellButton.icon:SetTexture(icon)
                    spellButton.spellID = bonus
                    spellButton:ClearAllPoints()
                    spellButton:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -yOffset, 10)
                    spellIndex = spellIndex + 1
                    yOffset = yOffset + 33
                end
            end
        end

        tinsert(parentContainer.specs, container)
    end

    updateActiveSpec(parentContainer)

end
GW.LoadSpecializations = LoadSpecializations