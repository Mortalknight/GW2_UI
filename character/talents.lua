local _, GW = ...
local SetClassIcon = GW.SetClassIcon

local maxTalentRows = 7
local talentsPerRow = 3

--local GwActiveSpellTab = 2

local TAXIROUTE_LINEFACTOR = 32 / 30 -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2 -- Half o that

-- T        - Texture
-- C        - Canvas Frame (for anchoring)
-- sx,sy    - Coordinate of start of line
-- ex,ey    - Coordinate of end of line
-- w        - Width of line
-- relPoint - Relative point on canvas to interpret coords (Default BOTTOMLEFT)

local function drawRouteLine(T, C, sx, sy, ex, ey, w, relPoint)
    if (not relPoint) then
        relPoint = "BOTTOMLEFT"
    end

    -- Determine dimensions and center point of line
    local dx, dy = ex - sx, ey - sy
    local cx, cy = (sx + ex) / 2, (sy + ey) / 2

    -- Normalize direction if necessary
    if (dx < 0) then
        dx, dy = -dx, -dy
    end

    -- Calculate actual length of line
    local l = sqrt((dx * dx) + (dy * dy))

    -- Quick escape if it's zero length
    if (l == 0) then
        T:SetTexCoord(0, 0, 0, 0, 0, 0, 0, 0)
        T:SetPoint("BOTTOMLEFT", C, relPoint, cx, cy)
        T:SetPoint("TOPRIGHT", C, relPoint, cx, cy)
        return
    end

    -- Sin and Cosine of rotation, and combination (for later)
    local s, c = -dy / l, dx / l
    local sc = s * c

    -- Calculate bounding box size and texture coordinates
    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy
    if (dy >= 0) then
        Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2
        Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2
        BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
        TRy = BRx
    else
        Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2
        Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2
        BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
        TRx = TLy
    end

    -- Set texture coordinates and anchors
    T:ClearAllPoints()
    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
    T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt)
    T:SetPoint("TOPRIGHT", C, relPoint, cx + Bwid, cy + Bhgt)
end

local function menu_OnLoad(self)
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("LEARNED_SPELL_IN_TAB")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("PLAYER_GUILD_UPDATE")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("USE_GLYPH")
    self:RegisterEvent("CANCEL_GLYPH_CAST")
    self:RegisterEvent("ACTIVATE_GLYPH")
end

local function tab_OnClick(self)
    GwspellbookTab1.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive")
    GwspellbookTab2.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive")
    GwspellbookTab3.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive")

    self.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg")
end

local function hero_OnLoad(self)
    local _, _, classIndex = UnitClass("player")

    SetClassIcon(self.icon, classIndex)
end

local function hookTalentButton(self, container, row, index)
    --  self:SetAttribute('macrotext1', '/click PlayerTalentFrameTalentsTalentRow'..row..'Talent'..index)
    self:RegisterForClicks("AnyUp")
    --   self:SetAttribute("type", "macro");
    self:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (38)), -10 + ((-42 * index) + 40))

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER", self, "CENTER", 0, 0)

    mask:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )
    mask:SetSize(34, 34)
    self.mask = mask
end

local function petSpec_OnUpdate(self, elapsed)
    if MouseIsOver(self) then
        if not self.info.spellPreview:IsShown() and not self.active then
            self.info.spellPreview:Show()
            self.info.specDesc:Hide()
        end
        local r, _, _, _ = self.background:GetVertexColor()
        self.background:SetVertexColor(r + (1 * elapsed), r + (1 * elapsed), r + (1 * elapsed), r + (1 * elapsed))
        return
    elseif self.active then
        self.info.spellPreview:Show()
        self.info.specDesc:Hide()
    else
        self.info.spellPreview:Hide()
        self.info.specDesc:Show()
    end

    self.background:SetVertexColor(0.7, 0.7, 0.7, 0.7)
end

local function petSpecFrame_OnShow(self)
    self:SetScript("OnUpdate", petSpec_OnUpdate)
end

local function setLineRotation(self, from, to)
    local y1 = 0
    local y2 = 0

    if from == 1 then
        y1 = -18
    elseif from == 2 then
        y1 = -60
    elseif from == 3 then
        y1 = -103
    end
    if to == 1 then
        y2 = -18
    elseif to == 2 then
        y2 = -60
    elseif to == 3 then
        y2 = -103
    end

    drawRouteLine(self.line, self, 10, y1, 56, y2, 4, "TOPLEFT")
end

local function updateActiveSpec()
    if InCombatLockdown() then
        return
    end

    local current = GetSpecialization()

    for i = 1, GetNumSpecializations() do
        local container = _G["GwSpecFrame" .. i]

        container.specIndex = i
        if i == current then
            container.active = true
            container.info:Hide()
            container.background:SetDesaturated(false)
        else
            container.active = false
            container.info:Show()

            container.background:SetDesaturated(true)
        end
        local last = 0
        local lastIndex = 2
        for row = 1, maxTalentRows do
            local anySelected = false
            local allAvalible = false

            local sel = nil
            for index = 1, talentsPerRow do
                local button = _G["GwSpecFrameSpec" .. i .. "Teir" .. row .. "index" .. index]
                local talentID, _, texture, selected, available, spellid, _, _, _, _, known =
                    GetTalentInfo(row, index, 1, false, "player")

                if not availible then
                    allAvalible = false
                end
                if not selected then
                    anySelected = true
                end

                button.spellId = spellid
                button.icon:SetTexture(texture)

                button.talentID = talentID
                button.available = available
                button.known = known

                local ispassive = IsPassiveSpell(spellid)
                button:EnableMouse(true)
                if i ~= current then
                    button:EnableMouse(false)
                end

                if ispassive then
                    button.legendaryHighlight:SetTexture(
                        "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight"
                    )
                    button.highlight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight")
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline")
                else
                    button.highlight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight")
                    button.legendaryHighlight:SetTexture(
                        "Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight"
                    )
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border")
                end

                if i == current and (selected or available) and not known then
                    button.highlight:Show()
                    button.legendaryHighlight:Hide()

                    if lastIndex ~= -1 then
                        _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Show()
                        setLineRotation(_G["GwTalentLine" .. i .. "-" .. last .. "-" .. row], lastIndex, index)
                    else
                        _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Hide()
                    end

                    if selected then
                        sel = true
                        lastIndex = index
                    elseif index == talentsPerRow and not sel then
                        lastIndex = -1
                    end
                else
                    button.legendaryHighlight:Hide()
                    if known then
                        button.legendaryHighlight:Show()
                    end
                    button.highlight:Hide()
                end

                if i == current and (selected or available or known) then
                    button.icon:SetDesaturated(false)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                elseif i ~= current then
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.1)
                    button:SetAlpha(0.5)
                else
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.4)
                end
            end

            if i == current and allAvalible == true and anySelected == false then
                for index = 1, talentsPerRow do
                    local button = _G["GwSpecFrameSpec" .. i .. "Teir" .. row .. "index" .. index]
                    button.icon:SetDesaturated(false)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                    button.highlight:Hide()
                end
            end

            if not sel then
                _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Hide()
            end

            last = row
        end
    end
end

local function loadTalents()
    local _, englishClass, classID = UnitClass("player")

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
            local r, _, _, _ = self.background:GetVertexColor()
            self.background:SetVertexColor(r + (1 * elapsed), r + (1 * elapsed), r + (1 * elapsed), r + (1 * elapsed))
            return
        end
        self.background:SetVertexColor(0.7, 0.7, 0.7, 0.7)
    end
    local fnContainer_OnShow = function(self)
        self:SetScript("OnUpdate", fnContainer_OnUpdate)
    end
    local fnContainer_OnHide = function(self)
        self:SetScript("OnUpdate", nil)
    end
    local fnContainer_OnClick = function(self, button)
        if not self.active and UnitLevel("player") > 9 then
            SetSpecialization(self.specIndex)
        end
    end
    for i = 1, GetNumSpecializations() do
        local container = CreateFrame("Button", "GwSpecFrame" .. i, GwSpecContainerFrame, "GwSpecFrame")

        container:RegisterForClicks("AnyUp")
        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", container.icon, "CENTER", 0, 0)
        mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        mask:SetSize(80, 80)
        container.icon:AddMaskTexture(mask)
        container:SetScript("OnEnter", nil)
        container:SetScript("OnLeave", nil)
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnShow", fnContainer_OnShow)
        container:SetScript("OnHide", fnContainer_OnHide)
        container:SetScript("OnClick", fnContainer_OnClick)
        container:SetPoint("TOPLEFT", GwSpecContainerFrame, "TOPLEFT", 10, (-140 * i) + 98)
        container.spec = i

        local _, name, description, icon, _, _, _ = GetSpecializationInfo(i)
        container.icon:SetTexture(icon)
        container.info.specTitle:SetFont(DAMAGE_TEXT_FONT, 18)
        container.info.specTitle:SetTextColor(1, 1, 1, 1)
        container.info.specTitle:SetShadowColor(0, 0, 0, 1)
        container.info.specTitle:SetShadowOffset(1, -1)
        container.info.specDesc:SetFont(UNIT_NAME_FONT, 14)
        container.info.specDesc:SetTextColor(0.8, 0.8, 0.8, 1)
        container.info.specDesc:SetShadowColor(0, 0, 0, 1)
        container.info.specDesc:SetShadowOffset(1, -1)
        container.info.specTitle:SetText(name)
        container.info.specDesc:SetText(description)

        txT = (i - 1) * txH
        container.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\" .. classID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        local last = 0

        local fnTalentButton_OnEnter = function(self)
            if self:GetParent().active ~= true then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        end
        local fnTalentButton_OnDragStart = function(self)
            if InCombatLockdown() or self.isPassive then
                return
            end
            PickupSpell(self.spellId)
        end
        local fnTalentButton_OnClick = function(self, button)
            return LearnTalent(self.talentID)
        end
        for row = 1, maxTalentRows do
            local fistOnRow
            local line =
                CreateFrame("Frame", "GwTalentLine" .. i .. "-" .. last .. "-" .. row, container, "GwTalentLine")

            line:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (88)), -10)

            last = row

            for index = 1, talentsPerRow do
                local talentButton =
                    CreateFrame(
                    "Button",
                    "GwSpecFrameSpec" .. i .. "Teir" .. row .. "index" .. index,
                    container,
                    "GwTalentButton"
                )
                talentButton:SetScript("OnEnter", fnTalentButton_OnEnter)
                talentButton:SetScript("OnLeave", GameTooltip_Hide)
                talentButton:SetScript("OnDragStart", fnTalentButton_OnDragStart)
                talentButton:SetScript("OnClick", fnTalentButton_OnClick)

                talentButton:RegisterForDrag("LeftButton")

                hookTalentButton(talentButton, container, row, index)

                if fistOnRow == nil then
                    fistOnRow = talentButton
                end
            end
            if i == 1 then
                local talentLevels = CLASS_TALENT_LEVELS[englishClass] or CLASS_TALENT_LEVELS["DEFAULT"]
                local numberDisplay =
                    CreateFrame("Frame", "GwTalentsLevelLabel" .. row, GwSpecContainerFrame, "GwTalentsLevelLabel")
                numberDisplay.title:SetFont(DAMAGE_TEXT_FONT, 14)
                numberDisplay.title:SetTextColor(0.7, 0.7, 0.7, 1)
                numberDisplay.title:SetShadowColor(0, 0, 0, 0)
                numberDisplay.title:SetShadowOffset(1, -1)
                numberDisplay:SetPoint("BOTTOM", fistOnRow, "TOP", 0, 13)
                numberDisplay.title:SetText(talentLevels[row])
            end
        end
    end
    updateActiveSpec()
end

local function updatePetTalents()
    local current = GetSpecialization(nil, true)

    for i = 1, GetNumSpecializations(false, true) do
        local container = _G["GwPetSpecFrame" .. i]

        container.specIndex = i
        if i == current then
            container.active = true
            container.info.specDesc:Hide()
            container.info.spellPreview:Show()
            container.background:SetDesaturated(false)
        else
            container.active = false
            container.info.specDesc:Show()
            container.info.spellPreview:Hide()

            container.background:SetDesaturated(true)
        end
    end
end

local function fnButton_OnEnter(self)
    if self:GetParent().active ~= true then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetSpellByID(self.spellId)
    GameTooltip:Show()
end

local function fnButton_OnDragStart(self)
    if InCombatLockdown() or self.isPassive then
        return
    end
    PickupSpell(self.spellId)
end

local function getPetSpecSpells(self, specID)
    local specSpells = {GetSpecializationSpells(specID, nil, true, true)}
    local index = 0
    local xPadding = 0
    local yPadding = 0
    for k = 1, #specSpells, 2 do
        local button =
            CreateFrame(
            "Button",
            "GwPetSpecFrameSpec" .. specID .. "index" .. index,
            self.info.spellPreview,
            "GwTalentButton"
        )
        button:SetScript("OnEnter", fnButton_OnEnter)
        button:SetScript("OnLeave", GameTooltip_Hide)
        button:SetScript("OnDragStart", fnButton_OnDragStart)
        button:SetScript("OnClick", nil)
        button.mask = UIParent:CreateMaskTexture()
        button.mask:SetPoint("CENTER", button, "CENTER", 0, 0)

        button.mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        button.mask:SetSize(34, 34)

        button:SetPoint("TOPLEFT", self.info, "TOPLEFT", xPadding, -50 + yPadding)
        if xPadding > 230 then
            xPadding = 0
            yPadding = yPadding - 40
        else
            xPadding = xPadding + 40
        end

        local _, _, texture, _, _, _, _ = GetSpellInfo(specSpells[k])
        local _, _ = GetSpellBookItemInfo(specSpells[k])
        local ispassive = IsPassiveSpell(specSpells[k])

        button.spellId = specSpells[k]
        button.icon:SetTexture(texture)

        button.active = true
        button.talentID = nil
        button.available = available
        button.known = known

        button:EnableMouse(true)

        if ispassive then
            button.legendaryHighlight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight")
            button.highlight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight")
            button.icon:AddMaskTexture(button.mask)
            button.outline:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline")
        else
            button.highlight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight")
            button.legendaryHighlight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight")
            button.icon:RemoveMaskTexture(button.mask)
            button.outline:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border")
        end
        button.legendaryHighlight:Hide()
        button.highlight:Hide()

        index = index + 1
    end
end

local function loadPetTalents()
    local _, _, classID = UnitClass("player")

    local txR, txT, txH, txMH
    txR = 588 / 1024
    txH = 140
    txMH = 512
    local specs = GetNumSpecializations()
    if specs > 3 then
        txMH = 1024
    end

    local fnContainer_OnHide = function(self)
        self:SetScript("OnUpdate", nil)
    end

    for i = 1, GetNumSpecializations(false, true) do
        local container = CreateFrame("Button", "GwPetSpecFrame" .. i, GwPetSpecContainerFrame, "GwSpecFrame")
        container:RegisterForClicks("AnyUp")
        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", container.icon, "CENTER", 0, 0)
        mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        mask:SetSize(80, 80)
        container.icon:AddMaskTexture(mask)
        container:SetScript("OnEnter", nil)
        container:SetScript("OnLeave", nil)
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnHide", fnContainer_OnHide)

        container:ClearAllPoints()

        container:SetScript(
            "OnShow",
            function()
                petSpecFrame_OnShow(container)
            end
        )
        container:SetScript(
            "OnEvent",
            function()
                if GetPetTalentTree() == nil then
                    container:Hide()
                    return
                else
                    container:Show()
                end
                updatePetTalents()
            end
        )

        container:RegisterEvent("PET_SPECIALIZATION_CHANGED")
        container:RegisterEvent("SPELLS_CHANGED")
        container:RegisterEvent("LEARNED_SPELL_IN_TAB")

        container:SetPoint("TOPLEFT", GwSpecContainerFrame, "TOPLEFT", 10, (-140 * i) + 98)

        container.spec = i

        local _, name, description, icon, _, _, _ = GetSpecializationInfo(i, false, true)
        container.icon:SetTexture(icon)
        container.info.specTitle:SetFont(DAMAGE_TEXT_FONT, 18)
        container.info.specTitle:SetTextColor(1, 1, 1, 1)
        container.info.specTitle:SetShadowColor(0, 0, 0, 1)
        container.info.specTitle:SetShadowOffset(1, -1)
        container.info.specDesc:SetFont(UNIT_NAME_FONT, 14)
        container.info.specDesc:SetTextColor(0.8, 0.8, 0.8, 1)
        container.info.specDesc:SetShadowColor(0, 0, 0, 1)
        container.info.specDesc:SetShadowOffset(1, -1)
        container.info.specTitle:SetText(name)
        container.info.specDesc:SetText(description)

        txT = (i - 1) * txH
        container.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\" .. classID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        getPetSpecSpells(container, i)
    end
    updatePetTalents()
end

local function spellButton_OnEvent(self)
    if not GwTalentFrame:IsShown() then
        return
    end

    local start, duration, _ = GetSpellCooldown(self.spellbookIndex, self.booktype)

    if start ~= nil and duration ~= nil then
        self.cooldown:SetCooldown(start, duration)
    end

    local _, autostate = GetSpellAutocast(self.spellbookIndex, self.booktype)

    self.autocast:Hide()
    if autostate then
        self.autocast:Show()
    end
end

local spellButtonIndex = 1
local function setButtonStyle(ispassive, isFuture, spellID, skillType, icon, spellbookIndex, booktype, tab, name)
    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)

    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].autocast:Hide()
    if autostate then
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].autocast:Show()
    end

    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].isPassive = ispassive
    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].isFuture = (skillType == "FUTURESPELL")
    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].isFlyout = (skillType == "FLYOUT")
    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].spellbookIndex = spellbookIndex
    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].booktype = booktype
    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:EnableMouse(true)

    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].spellId = spellID
    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetTexture(icon)

    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAlpha(1)

    if booktype == "pet" then
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("type", "spell")
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("*spell", spellID)

        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("type2", "macro")
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute(
            "*macrotext2",
            "/petautocasttoggle " .. name
        )
    else
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("type", "spell")
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("spell", spellID)
    end

    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].arrow:Hide()

    _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetScript("OnEvent", spellButton_OnEvent)

    if skillType == "FUTURESPELL" then
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetDesaturated(true)
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetAlpha(0.5)
    elseif skillType == "FLYOUT" then
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].arrow:Show()
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("type", "flyout")
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("flyout", spellID)
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex]:SetAttribute("flyoutDirection", "RIGHT")

        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetDesaturated(false)
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetAlpha(1)
    else
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetDesaturated(false)
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:SetAlpha(1)
    end

    if ispassive then
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].highlight:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight"
        )
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:AddMaskTexture(
            _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].mask
        )
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].outline:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline"
        )
    else
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].highlight:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight"
        )
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].icon:RemoveMaskTexture(
            _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].mask
        )
        _G["GwSpellbookTab" .. tab .. "Actionbutton" .. spellButtonIndex].outline:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border"
        )
    end
end

local function updateTab()
    if InCombatLockdown() then
        return
    end

    for spellBookTabs = 1, 3 do
        local _, _, offset, numSpells = GetSpellTabInfo(spellBookTabs)

        spellButtonIndex = 1
        local BOOKTYPE = "spell"
        if spellBookTabs == 3 then
            BOOKTYPE = "pet"
            numSpells, petToken = HasPetSpells()
            offset = 0
            if numSpells == nil then
                numSpells = 0
            end
        end

        local boxIndex = 1
        local y = 1
        local indexToPassive = nil
        for i = 1, numSpells do
            local spellIndex = i + offset
            local _, _, _, _, _, _, spellID = GetSpellInfo(spellIndex, BOOKTYPE)
            local skillType, spellId = GetSpellBookItemInfo(spellIndex, BOOKTYPE)

            local ispassive = IsPassiveSpell(spellID)

            if not ispassive then
                local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)
                local name, _ = GetSpellBookItemName(spellIndex, BOOKTYPE)
                if name == nil then
                    name = ""
                end

                setButtonStyle(ispassive, isFuture, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)

                spellButtonIndex = spellButtonIndex + 1
                boxIndex = boxIndex + 1
                y = y + 1

                if y == 6 then
                    y = 1
                end
            else
                if indexToPassive == nil then
                    indexToPassive = i
                end
            end
        end

        maxSkip = 10
        if y == 1 then
            maxSkip = 5
        end
        for skip = y, maxSkip do
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. boxIndex]:SetAlpha(0)
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. boxIndex]:EnableMouse(false)
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. boxIndex]:SetScript("OnEvent", nil)
            boxIndex = boxIndex + 1
            spellButtonIndex = spellButtonIndex + 1
        end
        _G["GwSpellbookContainerTab" .. spellBookTabs].passiveLabel:ClearAllPoints()
        _G["GwSpellbookContainerTab" .. spellBookTabs].passiveLabel:SetPoint(
            "BOTTOMLEFT",
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. boxIndex],
            "TOPLEFT",
            -4,
            15
        )

        if indexToPassive ~= nil then
            for i = indexToPassive, numSpells do
                local spellIndex = i + offset
                local _, _, _, _, _, _, spellID = GetSpellInfo(spellIndex, BOOKTYPE)

                local skillType, spellId = GetSpellBookItemInfo(spellIndex, BOOKTYPE)

                local ispassive = IsPassiveSpell(spellID)

                local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)
                local name, _ = GetSpellBookItemName(spellIndex, BOOKTYPE)
                if name == nil then
                    name = ""
                end
                if ispassive then
                    y = y + 1

                    if y == 6 then
                        y = 0
                    end

                    setButtonStyle(
                        ispassive,
                        isFuture,
                        spellId,
                        skillType,
                        icon,
                        spellIndex,
                        BOOKTYPE,
                        spellBookTabs,
                        name
                    )

                    spellButtonIndex = spellButtonIndex + 1
                    boxIndex = boxIndex + 1
                end
            end
        end

        for i = boxIndex, 100 do
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. i]:SetAlpha(0)
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. i]:EnableMouse(false)
            _G["GwSpellbookTab" .. spellBookTabs .. "Actionbutton" .. boxIndex]:SetScript("OnEvent", nil)
        end
    end
end

local function spellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    if not self.isFlyout then
        GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
    else
        local name, desc, _, _ = GetFlyoutInfo(self.spellId)
        GameTooltip:AddLine(name)
        GameTooltip:AddLine(desc)
    end
    if self.isFuture then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(GwLocalization["REQUIRED_LEVEL_SPELL"] .. GetSpellLevelLearned(self.spellId), 1, 1, 1)
    end
    GameTooltip:Show()
end

local function LoadTalents()
    local fmGTF = CreateFrame("Frame", "GwTalentFrame", GwCharacterWindow, "SecureHandlerStateTemplate,GwTalentFrame")
    fmGTF.title:SetFont(DAMAGE_TEXT_FONT, 14)
    fmGTF.title:SetTextColor(1, 1, 1, 1)
    fmGTF.title:SetShadowColor(0, 0, 0, 1)
    fmGTF.title:SetShadowOffset(1, -1)
    fmGTF.title:SetText(GwLocalization["TALENTS_SPEC_HEADER"])
    fmGTF:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    fmGTF:RegisterEvent("PET_SPECIALIZATION_CHANGED")
    fmGTF:RegisterEvent("PLAYER_LEARN_PVP_TALENT_FAILED")
    fmGTF:RegisterEvent("PLAYER_LEARN_TALENT_FAILED")
    fmGTF:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
    fmGTF:RegisterEvent("PLAYER_TALENT_UPDATE")
    fmGTF:RegisterEvent("SPEC_INVOLUNTARILY_CHANGED")
    fmGTF:RegisterEvent("TALENTS_INVOLUNTARILY_RESET")

    --fmGTF:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED")
    fmGTF:RegisterEvent("UNIT_MODEL_CHANGED")
    fmGTF:RegisterEvent("UNIT_LEVEL")
    fmGTF:RegisterEvent("LEARNED_SPELL_IN_TAB")
    --fmGTF:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED")

    CreateFrame("Frame", "GwSpecContainerFrame", GwTalentFrame)
    GwSpecContainerFrame:SetPoint("TOPLEFT", GwTalentFrame, "TOPLEFT")
    GwSpecContainerFrame:SetPoint("BOTTOMRIGHT", GwTalentFrame, "BOTTOMRIGHT")

    CreateFrame("Frame", "GwPetSpecContainerFrame", GwTalentFrame)
    GwPetSpecContainerFrame:SetPoint("TOPLEFT", GwTalentFrame, "TOPLEFT")
    GwPetSpecContainerFrame:SetPoint("BOTTOMRIGHT", GwTalentFrame, "BOTTOMRIGHT")

    CreateFrame("Frame", "GwSpellbookMenu", GwTalentFrame, "GwSpellbookMenu")

    menu_OnLoad(GwSpellbookMenu)
    GwSpellbookMenu:SetScript(
        "OnEvent",
        function()
            if not GwTalentFrame:IsShown() then
                return
            end
            updateTab()
        end
    )
    fmGTF:SetScript(
        "OnEvent",
        function(self)
            if not self:IsShown() then
                return
            end
            updateActiveSpec()
        end
    )

    for tab = 1, 3 do
        local container =
            CreateFrame("Frame", "GwSpellbookContainerTab" .. tab, GwSpellbookMenu, "GwSpellbookContainerTab")
        container.activeLabel.title:SetFont(DAMAGE_TEXT_FONT, 14)
        container.activeLabel.title:SetTextColor(1, 1, 1, 1)
        container.activeLabel.title:SetShadowColor(0, 0, 0, 1)
        container.activeLabel.title:SetShadowOffset(1, -1)
        container.activeLabel.title:SetText(GwLocalization["SPELLS_HEADER_ACTIVE"])

        container.passiveLabel.title:SetFont(DAMAGE_TEXT_FONT, 14)
        container.passiveLabel.title:SetTextColor(1, 1, 1, 1)
        container.passiveLabel.title:SetShadowColor(0, 0, 0, 1)
        container.passiveLabel.title:SetShadowOffset(1, -1)
        container.passiveLabel.title:SetText(GwLocalization["SPELLS_HEADER_PASSIVE"])

        local line = 0
        local x = 0
        local y = 0
        local fnF_OnDragStart = function(self)
            if InCombatLockdown() or self.isPassive or self.isFuture then
                return
            end
            PickupSpellBookItem(self.spellbookIndex, self.booktype)
        end
        for i = 1, 100 do
            local f =
                CreateFrame(
                "Button",
                "GwSpellbookTab" .. tab .. "Actionbutton" .. i,
                container,
                "GwSpellbookActionbutton"
            )
            f:SetScript("OnDragStart", fnF_OnDragStart)
            local mask = UIParent:CreateMaskTexture()
            mask:SetPoint("CENTER", f, "CENTER", 0, 0)

            mask:SetTexture(
                "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
                "CLAMPTOBLACKADDITIVE",
                "CLAMPTOBLACKADDITIVE"
            )
            mask:SetSize(40, 40)

            f.mask = mask

            f:SetPoint("TOPLEFT", container, "TOPLEFT", (50 * x), (-70) + (-50 * y))
            f:RegisterForClicks("AnyUp")
            f:RegisterForDrag("LeftButton")
            f:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            f:RegisterEvent("PET_BAR_UPDATE")
            f:HookScript("OnEnter", spellButton_OnEnter)
            f:HookScript("OnLeave", GameTooltip_Hide)

            line = line + 1
            x = x + 1
            if line == 5 then
                x = 0
                y = y + 1
                line = 0
            end
        end
    end

    GwSpellbookContainerTab1:Hide()
    GwSpellbookContainerTab2:Show()
    GwSpellbookContainerTab3:Hide()

    loadTalents()
    loadPetTalents()
    updateTab()

    GwspellbookTab1:SetFrameRef("GwSpellbookMenu", GwSpellbookMenu)
    GwspellbookTab1:SetAttribute(
        "_onclick",
        [=[

        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',1)
        ]=]
    )
    GwspellbookTab2:SetFrameRef("GwSpellbookMenu", GwSpellbookMenu)
    GwspellbookTab2:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
        ]=]
    )
    GwspellbookTab3:SetFrameRef("GwSpellbookMenu", GwSpellbookMenu)
    GwspellbookTab3:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',3)
        ]=]
    )

    GwspellbookTab3:SetAttribute(
        "_onstate-petstate",
        [=[
    if newstate == "nopet" then
       self:Hide()
        if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
            self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
        end
    elseif newstate == "hasPet" then
        self:Show()
    end
]=]
    )
    RegisterStateDriver(GwspellbookTab3, "petstate", "[target=pet,noexists] nopet;" .. " [target=pet,help] hasPet;")

    GwSpellbookMenu:SetFrameRef("GwSpellbookContainerTab1", GwSpellbookContainerTab1)
    GwSpellbookMenu:SetFrameRef("GwSpellbookContainerTab2", GwSpellbookContainerTab2)
    GwSpellbookMenu:SetFrameRef("GwSpellbookContainerTab3", GwSpellbookContainerTab3)
    GwSpellbookMenu:SetFrameRef("GwSpecContainerFrame", GwSpecContainerFrame)
    GwSpellbookMenu:SetFrameRef("GwPetSpecContainerFrame", GwPetSpecContainerFrame)
    GwSpellbookMenu:SetAttribute(
        "_onattributechanged",
        [=[
       
            if name~='tabopen' then return end
            
            self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
        
            if value==1 then
                self:GetFrameRef('GwSpellbookContainerTab1'):Show()
                self:GetFrameRef('GwSpecContainerFrame'):Show()
                self:GetFrameRef('GwPetSpecContainerFrame'):Hide()
                return
            end   if value==2 then
                self:GetFrameRef('GwSpellbookContainerTab2'):Show()
                self:GetFrameRef('GwSpecContainerFrame'):Show()
                self:GetFrameRef('GwPetSpecContainerFrame'):Hide()
                return
            end   if value==3 then
                self:GetFrameRef('GwSpellbookContainerTab3'):Show()
                self:GetFrameRef('GwSpecContainerFrame'):Hide()
                self:GetFrameRef('GwPetSpecContainerFrame'):Show()
                return
            end
    
  
        ]=]
    )
    GwSpellbookMenu:SetAttribute("tabOpen", 2)

    GwspellbookTab1:HookScript("OnClick", tab_OnClick)
    GwspellbookTab2:HookScript("OnClick", tab_OnClick)
    GwspellbookTab3:HookScript("OnClick", tab_OnClick)

    GwspellbookTab3:HookScript(
        "OnHide",
        function()
            tab_OnClick(GwspellbookTab2)
        end
    )

    hero_OnLoad(GwspellbookTab2)

    GwTalentFrame:HookScript(
        "OnShow",
        function()
            GwCharacterWindow.windowIcon:SetTexture(
                "Interface\\AddOns\\GW2_UI\\textures\\character\\spellbook-window-icon"
            )
            GwCharacterWindow.WindowHeader:SetText(GwLocalization["TALENTS_HEADER"])
            if InCombatLockdown() then
                return
            end
            updateTab()
            updateActiveSpec()
        end
    )

    hooksecurefunc(
        "ToggleTalentFrame",
        function()
            if InCombatLockdown() then
                return
            end

            GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
        end
    )
    GwTalentFrame:Hide()
    return GwTalentFrame
end
GW.LoadTalents = LoadTalents

--[[
local function setActiveSpellbookTab(actTab)
    GwActiveSpellTab = actTab

    for i = 1, 3 do
        _G["GwspellbookTab" .. i].background:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive"
        )
    end
    updateTab()
end
--]]
