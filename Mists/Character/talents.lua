local _, GW = ...
local openSpec = 1 -- Can be 1 or 2
local isPetTalents = false

local maxTalentRows = 6
local talentsPerRow = 3

local TAXIROUTE_LINEFACTOR = 32 / 30 -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2 -- Half o that

local passiveHighlight = "Interface/AddOns/GW2_UI/textures/talents/passive_highlight"
local activeHighlight = "Interface/AddOns/GW2_UI/textures/talents/active_highlight"
local passiveOutline = "Interface/AddOns/GW2_UI/textures/talents/passive_outline"
local activeOutline = "Interface/AddOns/GW2_UI/textures/talents/background_border"

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

local function GetSpellPreviewButton(self, index)
    local spellButton = self.spellPreviewButton[index]

    if spellButton then
        return spellButton
    end

    spellButton = CreateFrame("Button", nil, self, "SecureActionButtonTemplate")
    spellButton:SetSize(30, 30)
    spellButton.icon = spellButton:CreateTexture(nil, "ARTWORK")
    spellButton.icon:SetAllPoints()
    spellButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    spellButton.border = spellButton:CreateTexture(nil, "BACKGROUND")
    spellButton.border:SetSize(31, 31)
    spellButton.border:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty")
    spellButton.border:SetPoint("CENTER", spellButton, "CENTER", 0, 0)

    spellButton:EnableMouse(true)
    spellButton:RegisterForClicks("AnyUp")
    spellButton:RegisterForDrag("LeftButton")
    spellButton:SetScript("OnDragStart", function(btn)
        if InCombatLockdown() then
            return
        end
        if btn.isPetSpell then
            PickupPetSpell(btn.spellID)
        else
            PickupSpell(btn.spellID)
        end
    end)
    spellButton:SetScript("OnEnter", function(btn)
        if not btn.spellID or not GetSpellInfo(btn.spellID) then
            return
        end

        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(btn.spellID, false, false, true)
        if btn.extraTooltip then
            GameTooltip:AddLine(btn.extraTooltip)
        end
        btn.UpdateTooltip = btn.OnEnter
        GameTooltip:Show()
    end)

    spellButton:SetScript("OnLeave", function(btn)
        btn.UpdateTooltip = nil
        GameTooltip:Hide()
    end)

    tinsert(self.spellPreviewButton, spellButton)

    return spellButton
end

local function UpdateClearInfo(self)
    local name, count, texture = GetTalentClearInfo()
    if name then
        self.topBar.clearInfo:SetText(format("|T%s:12:12|t%s %s", texture, count, name))
    end
end

local function UpdateTrees(self, currentSpec)
    for i = 1, GetNumSpecializations(false, isPetTalents) do
        local container = self.specs[i]
        local isActiveSpec = (i == currentSpec)

        local id, name, description, icon, role = C_SpecializationInfo.GetSpecializationInfo(i, false, isPetTalents, nil, GW.mysex)

        container.roleIcon:ClearAllPoints()
        if role == "TANK" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank")
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", 14, -6)
        elseif role == "HEALER" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer")
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", 12, -5)
        elseif role == "DAMAGER" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps")
            container.roleIcon:SetSize(30, 30)
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", 17, -10)
        end

        container.icon.texture:SetTexture(icon)
        container.info.specTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
        container.info.specTitle:SetTextColor(1, 1, 1, 1)
        container.info.specTitle:SetShadowColor(0, 0, 0, 1)
        container.info.specTitle:SetShadowOffset(1, -1)
        container.info.specDesc:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        container.info.specDesc:SetTextColor(0.8, 0.8, 0.8, 1)
        container.info.specDesc:SetShadowColor(0, 0, 0, 1)
        container.info.specDesc:SetShadowOffset(1, -1)
        container.info.specTitle:SetText(name)
        container.info.specDesc:SetText(description)
        container.tooltip = description

        -- spell icons
        for idx = 1, #container.spellPreviewButton do
            container.spellPreviewButton[idx]:Hide()
        end
        local bonuses
        if isPetTalents then
            bonuses = {GetSpecializationSpells(i, nil, isPetTalents)}
        else
            bonuses = SPEC_SPELLS_DISPLAY[id]
        end

        if bonuses then
            local buttonsPerColumn = 4
            local buttonSpacing = 33
            local columnSpacing = 33
            local spellInColumn = 0
            local columnIndex = 0
            local yStartOffset = -5

            for idx = 1, #bonuses, 2 do
                local bonus = bonuses[idx]
                local spellButton = GetSpellPreviewButton(container, idx)
                local _, icon2 = GetSpellTexture(bonus)
                spellButton.icon:SetTexture(icon2)
                spellButton.spellID = bonus
                spellButton.isPetSpell = isPetTalents
                spellButton:ClearAllPoints()

                spellButton.icon:SetDesaturated(not isActiveSpec)
                spellButton:EnableMouse(isActiveSpec)
                spellButton.icon:SetAlpha(isActiveSpec and 1 or 0.5)

                local xOffset = -10 - (columnIndex * columnSpacing)
                local yOffset = yStartOffset - (spellInColumn * buttonSpacing)

                spellButton:SetPoint("TOPRIGHT", container, "TOPRIGHT", xOffset, yOffset)
                spellButton:Show()

                spellInColumn = spellInColumn + 1

                if spellInColumn >= buttonsPerColumn then
                    spellInColumn = 0
                    columnIndex = columnIndex + 1
                end
            end
        end
    end
end

local function updateActiveSpec(self)
    if InCombatLockdown() then
        return
    end
    local spec = C_SpecializationInfo.GetSpecialization(false, isPetTalents, openSpec)
    local isCurrentSpec = openSpec == C_SpecializationInfo.GetActiveSpecGroup(false, isPetTalents)
    local talentInfoQuery = {
        groupIndex = openSpec,
        isInspect = false,
        target = isPetTalents and "pet" or "player"
    }

    self.topBar.activateSpecGroup:SetShown(not isCurrentSpec and not isPetTalents)
    self.topBar.activeSpecIndicator:SetShown(isCurrentSpec and not isPetTalents)

    UpdateTrees(self, spec)
    UpdateClearInfo(self)

    for i = 1, GetNumSpecializations(false, isPetTalents) do
        local container = self.specs[i]
        local isActiveSpec = (i == spec)

        container.specIndex = i
        if i == spec then
            container.active = true
            container.info:Hide()
            container.background:SetDesaturated(false)
            container.icon.texture:SetDesaturated(false)
        else
            container.active = false
            container.info:Show()
            container.icon.texture:SetDesaturated(true)
            container.background:SetDesaturated(true)
        end
        if isPetTalents then
            container.active = false
            container.info:Show()
        end

        local lastIndex = -1
        local lastRowHadSelection = false

        for row = 1, maxTalentRows do
            local line = container.lines[row]
            line:Hide()

            if row == 1 then
                lastIndex = 2
                lastRowHadSelection = true
            end

            local sel = false
            local selectedIndex = -1
            local anySelected = false
            local allAvailable = true

            for index = 1, talentsPerRow do
                local button = container.talentButtons[row].buttons[index]

                -- Query
                talentInfoQuery.tier = row
                talentInfoQuery.column = index
                local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)

                anySelected = anySelected or talentInfo.selected
                allAvailable = allAvailable and talentInfo.available

                button.spellId = talentInfo.spellID
                button.icon:SetTexture(talentInfo.icon)
                button.talentID = talentInfo.talentID
                button.available = talentInfo.available
                button.hasGoldBorder = talentInfo.hasGoldBorder
                button.tier = row
                button.selected = talentInfo.selected
                button:SetID(talentInfo.talentID)
                _G["PlayerTalentFrameTalentsTalentRow" .. row .. "Talent" .. index]:SetID(talentInfo.talentID)

                button:EnableMouse(isActiveSpec and isCurrentSpec)

                local isPassive = IsPassiveSpell(talentInfo.spellID)
                if isPassive then
                    button.legendaryHighlight:SetTexture(passiveHighlight)
                    button.highlight:SetTexture(passiveHighlight)
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture(passiveOutline)
                else
                    button.legendaryHighlight:SetTexture(activeHighlight)
                    button.highlight:SetTexture(activeHighlight)
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture(activeOutline)
                end

                -- Vorab merken, ob selektiert
                if talentInfo.selected then
                    sel = true
                    selectedIndex = index
                end
            end

            for index = 1, talentsPerRow do
                local button = container.talentButtons[row].buttons[index]
                talentInfoQuery.tier = row
                talentInfoQuery.column = index
                local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)

                if isActiveSpec and not isPetTalents then
                    -- Aktiver Spec
                    if sel then
                        -- Es wurde ein Talent ausgewählt
                        if talentInfo.selected then
                            button.highlight:Show()
                            button.legendaryHighlight:Hide()
                            button.icon:SetDesaturated(false)
                            button.icon:SetVertexColor(1, 1, 1, 1)
                            button:SetAlpha(1)
                        else
                            button.highlight:Hide()
                            button.legendaryHighlight:SetShown(talentInfo.hasGoldBorder)
                            button.icon:SetDesaturated(true)
                            button.icon:SetVertexColor(1, 1, 1, 0.4)
                            button:SetAlpha(0.5)
                        end
                    else
                        -- Kein Talent ausgewählt
                        button.highlight:Show()
                        button.legendaryHighlight:Hide()
                        button.icon:SetDesaturated(false)
                        button.icon:SetVertexColor(1, 1, 1, 1)
                        button:SetAlpha(1)
                    end
                else
                    -- Nicht aktiver Spec oder PetTalents
                    button.highlight:Hide()
                    button.legendaryHighlight:SetShown(talentInfo.hasGoldBorder)
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.1)
                    button:SetAlpha(0.5)
                end
            end

            -- Linien zeichnen, wenn aktiv und ausgewählt
            if isActiveSpec and sel and lastIndex ~= -1 and lastRowHadSelection then
                line:Show()
                setLineRotation(line, lastIndex, selectedIndex)
            end

            -- Zustand für nächste Reihe merken
            if sel then
                lastIndex = selectedIndex
                lastRowHadSelection = true
            else
                lastIndex = -1
                lastRowHadSelection = false
            end
        end
    end
end

local function SpecIconOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(self:GetParent().tooltip, 1, 1, 1)
    if not self:GetParent().active and not isPetTalents  then
        GameTooltip:AddLine(TALENT_SPEC_CHANGE_AT_CLASS_TRAINER, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
    end
    GameTooltip:SetMinimumWidth(300)
    GameTooltip:Show()
end

local function LoadTalents()
    TalentFrame_LoadUI()
    local talentWindow = CreateFrame("Frame", "GwTalentFrame", GwCharacterWindow, "GwCharacterTabContainer")
    local talentContainer = CreateFrame('Frame', 'GwTalentSpecFrame', talentWindow, 'SecureHandlerStateTemplate,GwTalentFrame')

    talentContainer.title:SetFont(DAMAGE_TEXT_FONT, 14)
    talentContainer.title:SetTextColor(1, 1, 1, 1)
    talentContainer.title:SetShadowColor(0, 0, 0, 1)
    talentContainer.title:SetShadowOffset(1, -1)
    talentContainer.title:SetText(SPECIALIZATION)
    talentContainer.topBar.activeSpecIndicator:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
    talentContainer.topBar.activeSpecIndicator:SetTextColor(63 / 255, 205 / 255, 75 / 255)
    talentContainer.topBar.unspentPoints:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    talentContainer.topBar.unspentPoints:SetTextColor(0.87, 0.74, 0.29, 1)
    talentContainer.topBar.clearInfo:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    talentContainer.topBar.clearInfo:SetTextColor(1, 1, 1)
    talentContainer.specs = {}
    talentContainer:Show()

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

            if not self.active then
                self.background:SetVertexColor(r, r, r, r)
            end
            return
        end
        if not self.active then
            self.background:SetVertexColor(0.7, 0.7, 0.7, 0.7)
        end
    end
    local fnContainer_OnShow = function(self)
        self:SetScript("OnUpdate", fnContainer_OnUpdate)
    end
    local fnContainer_OnHide = function(self)
        self:SetScript("OnUpdate", nil)
    end
    local fnContainer_OnClick = function(self)
        local currentSpec = C_SpecializationInfo.GetSpecialization(nil, isPetTalents, openSpec)
        if (isPetTalents and self.specIndex ~= currentSpec and IsPetActive()) or (not currentSpec or currentSpec > GetNumSpecializations(false, isPetTalents)) then
            GW.WarningPrompt(CONFIRM_LEARN_SPEC, function() SetSpecialization(self.specIndex, isPetTalents) end, nil, YES, NO)
        end
    end

    for i = 1, specs do
        local container = CreateFrame("Button", nil, talentContainer, "GwSpecFrame")

        container:RegisterForClicks("AnyUp")
        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", container.icon, "CENTER", 0, 0)
        mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetSize(80, 80)
        container.icon.texture:AddMaskTexture(mask)
        container:SetScript("OnEnter", nil)
        container:SetScript("OnLeave", nil)
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnShow", fnContainer_OnShow)
        container:SetScript("OnHide", fnContainer_OnHide)
        container:SetScript("OnClick", fnContainer_OnClick)
        container.icon:SetScript("OnMouseDown", function() fnContainer_OnClick(container) end)
        container.icon:SetScript("OnEnter", SpecIconOnEnter)
        container.icon:SetScript("OnLeave", GameTooltip_Hide)
        container:SetPoint("TOPLEFT", talentContainer, "TOPLEFT", 10, (-140 * i) + 60)

        container.spec = i
        container.spellPreviewButton = {}
        container.talentButtons = {}
        container.lines = {}

        txT = (i - 1) * txH
        container.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        local fnTalentButton_OnEnter = function(self)
            if self:GetParent().active ~= true then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:SetTalent(self.talentID)
            GameTooltip:Show()
        end
        local fnTalentButton_OnDragStart = function(self)
            if InCombatLockdown() or self.isPassive then
                return
            end
            PickupSpell(self.spellId)
        end
        local fnTalentButton_OnClick = function(self, button)
            if IsModifiedClick("CHATLINK") then
                local link = GetSpellLink(self.spellId)
                ChatEdit_InsertLink(link)
                return
            end
            if ( button == "LeftButton" and not self.selected ) then
                LearnTalents(self.talentID)
			end
        end
        for row = 1, maxTalentRows do
            local fistOnRow
            local line = CreateFrame("Frame", nil, container, "GwTalentLine")
            line:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (88)), -10)
            tinsert(container.lines, line)
            container.talentButtons[row] = {}
            container.talentButtons[row].buttons = {}

            for index = 1, talentsPerRow do
                local talentButton = CreateFrame("Button", nil, container, "GwTalentButton")
                talentButton:SetScript("OnEnter", fnTalentButton_OnEnter)
                talentButton:SetScript("OnLeave", GameTooltip_Hide)
                talentButton:SetScript("OnDragStart", fnTalentButton_OnDragStart)
                talentButton:HookScript("OnClick", fnTalentButton_OnClick)

                talentButton:RegisterForClicks("AnyUp")
                talentButton:RegisterForDrag("LeftButton")
                talentButton:SetAttribute("type2", "macro")
                talentButton:SetAttribute('macrotext2', '/click PlayerTalentFrameTalentsTalentRow'..row..'Talent'..index .. " RightButton")
                talentButton:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (38)), -10 + ((-42 * index) + 40))
                talentButton.mask = talentButton:CreateMaskTexture()
                talentButton.mask:SetPoint("CENTER", talentButton, "CENTER", 0, 0)
                talentButton.mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                talentButton.mask:SetSize(34, 34)

                if fistOnRow == nil then
                    fistOnRow = talentButton
                end

                tinsert(container.talentButtons[row].buttons, talentButton)
            end
            if i == 1 then
                local numberDisplay = CreateFrame("Frame", "GwTalentsLevelLabel" .. row, talentContainer, "GwTalentsLevelLabel")
                numberDisplay.title:SetFont(DAMAGE_TEXT_FONT, 14)
                numberDisplay.title:SetTextColor(0.7, 0.7, 0.7, 1)
                numberDisplay.title:SetShadowColor(0, 0, 0, 0)
                numberDisplay.title:SetShadowOffset(1, -1)
                numberDisplay:SetPoint("BOTTOM", fistOnRow, "TOP", 0, 10)
                numberDisplay.title:SetText(select(3, GetTalentTierInfo(row, C_SpecializationInfo.GetActiveSpecGroup(false, isPetTalents))))
            end
        end

        tinsert(talentContainer.specs, container)
    end

    updateActiveSpec(talentContainer)

    talentContainer.topBar.activateSpecGroup:SetScript("OnClick", function()
        if openSpec then
            C_SpecializationInfo.SetActiveSpecGroup(openSpec)
        end
    end)

    talentContainer:RegisterEvent("PLAYER_TALENT_UPDATE")
    talentContainer:RegisterEvent("PET_TALENT_UPDATE")
    talentContainer:RegisterEvent("PET_SPECIALIZATION_CHANGED")
    talentContainer:RegisterEvent("UNIT_LEVEL")
    talentContainer:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    talentContainer:RegisterEvent("TALENT_GROUP_ROLE_CHANGED")
    talentContainer:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED")
    talentContainer:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED")
    talentContainer:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED")
    talentContainer:RegisterEvent("LEARNED_SPELL_IN_TAB")
    talentContainer:RegisterEvent("PLAYER_ENTERING_WORLD")
    talentContainer:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    talentContainer:RegisterEvent("BAG_UPDATE_DELAYED")
    talentContainer:SetScript('OnEvent', function(_, event)
        C_Timer.After(0.1, function() talentContainer.topBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS, UnitCharacterPoints("player") .. " |TInterface/AddOns/GW2_UI/textures/icons/talent-icon:24:24:0:0:0.1875:0.828125:0.1875:0.828125|t") end)

        if event == "PLAYER_SPECIALIZATION_CHANGED" then
            local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, isPetTalents)
            talentContainer.fmMenu.items.spec1:SetText(activeTalentGroup == 1 and SPECIALIZATION_PRIMARY_ACTIVE or SPECIALIZATION_PRIMARY)
            talentContainer.fmMenu.items.spec2:SetText(activeTalentGroup == 2 and SPECIALIZATION_SECONDARY_ACTIVE or SPECIALIZATION_SECONDARY)
            updateActiveSpec(talentContainer)
        elseif event == "BAG_UPDATE_DELAYED" then
            UpdateClearInfo(talentContainer)
        else
            updateActiveSpec(talentContainer)
        end
    end)
    talentContainer:SetScript('OnShow', function()
        if InCombatLockdown() then return end
        updateActiveSpec(talentContainer)
    end)
    hooksecurefunc('ToggleTalentFrame', function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute("keytoggle", true)
        GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
    end)

    -- setup a menu frame
    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, isPetTalents)
    local fmMenu = CreateFrame("Frame", "GWTalemtsMenu", talentWindow, "GwCharacterMenuTemplate")
    fmMenu.items = {}
    talentContainer.fmMenu = fmMenu

    local item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate,SecureActionButtonTemplate")
    item:SetAttribute("macrotext", "/click PlayerSpecTab1")
    item:SetAttribute("type", "macro")
    PlayerSpecTab1:HookScript("OnClick", function()
        openSpec                      = 1
        isPetTalents                  = false
        updateActiveSpec(talentContainer)
        GlyphFrame:Show()
    end)
    item:SetText(activeTalentGroup == 1 and SPECIALIZATION_PRIMARY_ACTIVE or SPECIALIZATION_PRIMARY)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.items.spec1 = item

    item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate,SecureActionButtonTemplate")
    item:SetAttribute("macrotext", "/click PlayerSpecTab2")
    item:SetAttribute("type", "macro")
    PlayerSpecTab2:HookScript("OnClick", function()
        openSpec                      = 2
        isPetTalents                  = false
        updateActiveSpec(talentContainer)
     GlyphFrame:Show()
    end)
    item:SetText(activeTalentGroup == 2 and SPECIALIZATION_SECONDARY_ACTIVE or SPECIALIZATION_SECONDARY)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.spec1, "BOTTOMLEFT")
    fmMenu.items.spec2 = item

    item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate,SecureActionButtonTemplate")
    item:SetAttribute("macrotext", "/click PlayerTalentFrameTab4")
    item:SetAttribute("type", "macro")
    PlayerTalentFrameTab4:HookScript("OnClick", function()
        openSpec                      = C_SpecializationInfo.GetActiveSpecGroup(false, true)
        isPetTalents                  = true
        updateActiveSpec(talentContainer)
        GlyphFrame:Show()
    end)
    item:SetText(PET)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.spec2, "BOTTOMLEFT")
    fmMenu.items.specPet = item
    fmMenu.items.specPet:SetShown(GW.myclass == "HUNTER")

    GW.CharacterMenuButton_OnLoad(fmMenu.items.spec1, false)
    GW.CharacterMenuButton_OnLoad(fmMenu.items.spec2, true)
    GW.CharacterMenuButton_OnLoad(fmMenu.items.specPet, false)

    return talentWindow
end
GW.LoadTalents = LoadTalents
