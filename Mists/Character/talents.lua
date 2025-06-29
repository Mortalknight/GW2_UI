local _, GW = ...
local activeSpec = nil
local openSpec = 1 -- Can be 1 or 2
local isPetTalents = false
local talentFrame

local maxTalentRows = 6
local talentsPerRow = 3

local TAXIROUTE_LINEFACTOR = 32 / 30 -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2 -- Half o that



StaticPopupDialogs["GW_CONFIRM_LEARN_PREVIEW_TALENTS"] = {
    text = CONFIRM_LEARN_PREVIEW_TALENTS,
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        LearnPreviewTalents(isPetTalents)
    end,
    OnCancel = function()
    end,
    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    preferredIndex = 4
}


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

local function hookTalentButton(self, container, row, index)
    --  self:SetAttribute('macrotext1', '/click PlayerTalentFrameTalentsTalentRow'..row..'Talent'..index)
    self:RegisterForClicks("AnyUp")
    --   self:SetAttribute("type", "macro");
    self:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (38)), -10 + ((-42 * index) + 40))

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER", self, "CENTER", 0, 0)

    mask:SetTexture(
        "Interface/AddOns/GW2_UI/textures/talents/passive_border",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )
    mask:SetSize(34, 34)
    self.mask = mask
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



local function loadTalentsFrames()
    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("TOPLEFT", GwCharacterWindow, 'TOPLEFT', 0, 0)
    mask:SetParent(GwCharacterWindow)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)
end
local function setNavigation(self)
    talentFrame.navigation.spec1Button.selected = false
    talentFrame.navigation.spec2Button.selected = false
    talentFrame.navigation.petTalentsButton.selected = false
    talentFrame.navigation.spec1Button.background:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\button-normal")
    talentFrame.navigation.spec2Button.background:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\button-normal")
    talentFrame.navigation.petTalentsButton.background:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\button-normal")
    self.selected = true
    self.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\button-selected")
end

local function updateActiveSpec()
   if InCombatLockdown() then
        return
    end

    talentFrame.navigation.activateSpecGroup:SetShown(not isPetTalents)
    talentFrame.navigation.activateSpecGroup:SetShown(openSpec ~= C_SpecializationInfo.GetActiveSpecGroup(false))


    for i = 1, GetNumSpecializations() do
        local container = _G["GwSpecFrame" .. i]

        container.specIndex = i
        if i == GW.myspec then
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
                local talentInfoQuery = {};
                talentInfoQuery.tier = row
                talentInfoQuery.column = index;
                talentInfoQuery.groupIndex = C_SpecializationInfo.GetActiveSpecGroup(isPetTalents);
                talentInfoQuery.isInspect = false;
                talentInfoQuery.target = isPetTalents and "pet" or "player";
                local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)

                if not talentInfo.available then
                    allAvalible = false
                end
                if not talentInfo.selected then
                    anySelected = true
                end

                button.spellId = talentInfo.spellID
                button.icon:SetTexture(talentInfo.icon)

                button.talentID = talentInfo.talentID
                button.available = talentInfo.available
                button.known = talentInfo.known
                button.tier = row
                button.selected = talentInfo.selected
                button:SetID(talentInfo.talentID)

                local ispassive = IsPassiveSpell(talentInfo.spellID)
                button:EnableMouse(true)
                if i ~= GW.myspec then
                    button:EnableMouse(false)
                end

                if ispassive then
                    button.legendaryHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight")
                    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight")
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_outline")
                else
                    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight")
                    button.legendaryHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight")
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border")
                end

                if i == GW.myspec and (talentInfo.selected or talentInfo.available) and not talentInfo.known then
                    button.highlight:Show()
                    button.legendaryHighlight:Hide()

                    if lastIndex ~= -1 then
                        _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Show()
                        setLineRotation(_G["GwTalentLine" .. i .. "-" .. last .. "-" .. row], lastIndex, index)
                    else
                        _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Hide()
                    end

                    if talentInfo.selected then
                        sel = true
                        lastIndex = index
                    elseif index == talentsPerRow and not sel then
                        lastIndex = -1
                    end
                else
                    button.legendaryHighlight:Hide()
                    if talentInfo.known then
                        button.legendaryHighlight:Show()
                    end
                    button.highlight:Hide()
                end

                if i == GW.myspec and (talentInfo.selected or talentInfo.available or talentInfo.known) then
                    button.icon:SetDesaturated(false)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                elseif i ~= GW.myspec then
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.1)
                    button:SetAlpha(0.5)
                else
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.4)
                end
            end

            if i == GW.myspec and allAvalible == true and anySelected == false then
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

local function LoadTalents()
    TalentFrame_LoadUI()
    talentFrame = CreateFrame('Frame', 'GwTalentFrame', GwCharacterWindow, 'GwLegacyTalentFrame')
    talentFrame.navigation.activateSpecGroup:SetWidth(talentFrame.navigation.activateSpecGroup:GetTextWidth() + 40)

    loadTalentsFrames()

    talentFrame.navigation.petTalentsButton.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\tabicon_pet")
    talentFrame.navigation.petTalentsButton.icon:SetTexCoord(0.6796875, 0.96875, 0.046875, 0.625)

    talentFrame.navigation.petTalentsButton:SetShown(GW.myclass == "HUNTER")

    talentFrame.specs = {}

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
        if not C_SpecializationInfo.GetSpecialization() then
            SetSpecialization(self.specIndex, isPetTalents)
        end
    end

    for i = 1, specs do
        local container = CreateFrame("Button", "GwSpecFrame" .. i, talentFrame, "GwSpecFrame")

        container:RegisterForClicks("AnyUp")
        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", container.icon, "CENTER", 0, 0)
        mask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
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
        if i == 1 then
            container:SetPoint("TOPLEFT", talentFrame, "TOPLEFT", 10, -120 * i)
        else
            container:SetPoint("TOPLEFT", _G["GwSpecFrame" .. i - 1], "BOTTOMLEFT", 0, -10)
        end
        container.spec = i

        local _, name, description, icon, role, primaryStat = C_SpecializationInfo.GetSpecializationInfo(i, false, false, nil, GW.mysex)

        container.icon:SetTexture(icon)
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

        txT = (i - 1) * txH
        container.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        local last = 0

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
			elseif ( button == "RightButton" and self.selected ) then
				if ( UnitIsDeadOrGhost("player") ) then
					UIErrorsFrame:AddMessage(ERR_PLAYER_DEAD, 1.0, 0.1, 0.1, 1.0);
				else
					StaticPopup_Show("CONFIRM_REMOVE_TALENT", nil, nil, {id = self:GetID()});
				end
			end
        end
        for row = 1, maxTalentRows do
            local fistOnRow
            local line = CreateFrame("Frame", "GwTalentLine" .. i .. "-" .. last .. "-" .. row, container, "GwTalentLine")

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
                local numberDisplay = CreateFrame("Frame", "GwTalentsLevelLabel" .. row, talentFrame, "GwTalentsLevelLabel")
                numberDisplay.title:SetFont(DAMAGE_TEXT_FONT, 14)
                numberDisplay.title:SetTextColor(0.7, 0.7, 0.7, 1)
                numberDisplay.title:SetShadowColor(0, 0, 0, 0)
                numberDisplay.title:SetShadowOffset(1, -1)
                numberDisplay:SetPoint("BOTTOM", fistOnRow, "TOP", 0, 13)
                numberDisplay.title:SetText(select(3, GetTalentTierInfo(row, C_SpecializationInfo.GetActiveSpecGroup())))
            end
        end

        tinsert(talentFrame.specs, container)
    end

    updateActiveSpec()

    talentFrame.navigation.spec1Button:SetScript("OnClick", function(self)
        setNavigation(self)
        openSpec                      = 1
        isPetTalents                  = false
        PlayerTalentFrame.talentGroup = 1
        updateActiveSpec()
    end)
    talentFrame.navigation.spec1Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
        GameTooltip:SetText(TALENT_SPEC_PRIMARY, 1, 1, 1)
        GameTooltip:Show()
    end)
    talentFrame.navigation.spec1Button:SetScript("OnLeave", GameTooltip_Hide)
    talentFrame.navigation.spec2Button:SetScript("OnClick", function(self)
        setNavigation(self)
        openSpec                      = 2
        isPetTalents                  = false
        PlayerTalentFrame.talentGroup = 2
        updateActiveSpec()
    end)
    talentFrame.navigation.spec2Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
        GameTooltip:SetText(TALENT_SPEC_SECONDARY, 1, 1, 1)
        GameTooltip:Show()
    end)
    talentFrame.navigation.spec2Button:SetScript("OnLeave", GameTooltip_Hide)
    talentFrame.navigation.petTalentsButton:SetScript("OnClick", function(self)
        setNavigation(self)
        openSpec                      = 1
        isPetTalents                  = true
        PlayerTalentFrame.talentGroup = 1
        updateActiveSpec()
    end)
    talentFrame.navigation.activateSpecGroup:SetScript("OnClick", function()
        if openSpec then
            C_SpecializationInfo.SetActiveSpecGroup(openSpec)
            updateActiveSpec()
        end
    end)

    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false)
    if activeTalentGroup == 1 then
        talentFrame.navigation.spec1Button:GetScript("OnClick")(talentFrame.navigation.spec1Button)
    elseif activeTalentGroup == 2 then
        talentFrame.navigation.spec2Button:GetScript("OnClick")(talentFrame.navigation.spec2Button)
    end

    talentFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    talentFrame:RegisterEvent("PET_TALENT_UPDATE")
    talentFrame:RegisterEvent("PET_SPECIALIZATION_CHANGED")
    talentFrame:RegisterEvent("UNIT_LEVEL")
    talentFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    talentFrame:RegisterEvent("TALENT_GROUP_ROLE_CHANGED")
    talentFrame:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED")
    talentFrame:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED")
    talentFrame:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED")
    talentFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    talentFrame:SetScript('OnEvent', function(self, event)
        talentFrame.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS,
            UnitCharacterPoints("player") ..
            " |TInterface/AddOns/GW2_UI/textures/icons/talent-icon: 24, 24, 0, 0, 0.1875, 0.828125 , 0.1875, 0.828125 |t ")
        if not talentFrame:IsShown() then return end
        updateActiveSpec()
    end)
    talentFrame:SetScript('OnShow', function()
        if InCombatLockdown() then return end
        updateActiveSpec()
    end)
    hooksecurefunc('ToggleTalentFrame', function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute("keytoggle", true)
        GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
    end)
    talentFrame:Hide()
    return talentFrame
end
GW.LoadTalents = LoadTalents
