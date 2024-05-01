local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local animations = GW.animations
local lerp = GW.lerp
-- Default 8 but none uses 8 talent rows in classic
local MAX_NUM__VISUAL_TALENT_TIERS = 8
local TALENT_BRANCH_ARRAY = {}
local TALENT_TOP_PADDING = 20

local activeSpec = nil
local openSpec = 1 -- Can be 1 or 2
local isPetTalents = false



local specIcons = {
    [461112] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/ABILITY_HUNTER_BESTIALDISCIPLINE",
    [132090] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_BackStab",
    [461113] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Hunter_Camouflage",
    [236179] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Hunter_FocusedAim",
    [236264] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Paladin_ShieldoftheTemplar",
    [132276] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Racial_BearForm",
    [132292] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Rogue_Eviscerate",
    [132320] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Stealth",
    [132341] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Warrior_DefensiveStance",
    [132347] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Warrior_InnerRage",
    [132355] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Ability_Warrior_SavageBlow",
    [1132292] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/INV_Knife_1H_ArtifactCthun_D_03",
    [136041] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/SPELL_NATURE_HEALINGTOUCH",
    [135770] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Deathknight_BloodPresence",
    [135773] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Deathknight_FrostPresence",
    [135775] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Deathknight_UnholyPresence",
    [135810] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Fire_FireBolt02",
    [135846] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Frost_FrostBolt02",
    [135873] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Holy_AuraOfLight",
    [237542] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Holy_GuardianSpirit",
    [135920] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Holy_HolyBolt",
    [135932] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Holy_MagicalSentry",
    [135940] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Holy_PowerWordShield",
    [136048] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Nature_Lightning",
    [136051] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Nature_LightningShield",
    [136052] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Nature_MagicImmunity",
    [136096] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Nature_StarFall",
    [136145] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Shadow_DeathCoil",
    [136172] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Shadow_Metamorphosis",
    [136186] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Shadow_RainOfFire",
    [136207] = "Interface/Addons/GW2_UI/Textures/talents/specIcons/Spell_Shadow_ShadowWordPain",
}


StaticPopupDialogs["GW_CONFIRM_LEARN_PREVIEW_TALENTS"] = {
    text = CONFIRM_LEARN_PREVIEW_TALENTS,
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        LearnPreviewTalents(isPetTalents)
    end,
    OnCancel = function(self)
    end,
    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    preferredIndex = 4
}
local function UpdatePreviewControls()
    if _G["GwLegacyTalentTree1"].summary:IsShown() then
        GwTalentFrame.bottomBar.prevLearn:Hide()
        GwTalentFrame.bottomBar.prevCancel:Hide()
        return
    end

    local preview = GetCVarBool("previewTalentsOption")
    local talentPoints = GetUnspentTalentPoints(false, isPetTalents, openSpec)
    local primaryTree = GetPreviewPrimaryTalentTree(false, false, openSpec)
    if (isPetTalents or openSpec) and preview and activeSpec == openSpec then
        GwTalentFrame.bottomBar.prevLearn:Show()
        GwTalentFrame.bottomBar.prevCancel:Show()
        -- enable accept/cancel buttons if preview talent points were spent
        if GetGroupPreviewTalentPointsSpent(isPetTalents, openSpec) > 0 or primaryTree then
            GwTalentFrame.bottomBar.prevLearn:Enable();
            GwTalentFrame.bottomBar.prevCancel:Enable();
        else
            GwTalentFrame.bottomBar.prevLearn:Disable();
            GwTalentFrame.bottomBar.prevCancel:Disable();
        end
    else
        GwTalentFrame.bottomBar.prevLearn:Hide()
        GwTalentFrame.bottomBar.prevCancel:Hide()
    end
end

local function toggleSummaryScreen(self, button, buttonstate, forceState)
    if forceState == nil then
        forceState = not _G["GwLegacyTalentTree1"].summary:IsShown()
    end

    if forceState then
        GwTalentFrame.bottomBarSummary:Show()
        GwTalentFrame.bottomBar:Hide()
        _G["GwLegacyTalentTree1"].summary:Show()
        _G["GwLegacyTalentTree2"].summary:Show()
        _G["GwLegacyTalentTree3"].summary:Show()
        UpdatePreviewControls()
        return
    end
    GwTalentFrame.bottomBar:Show()
    GwTalentFrame.bottomBarSummary:Hide()
    _G["GwLegacyTalentTree1"].summary:Hide()
    _G["GwLegacyTalentTree2"].summary:Hide()
    _G["GwLegacyTalentTree3"].summary:Hide()

    UpdatePreviewControls()

    if isPetTalents then
   --     GwTalentFrame.navigation.spec1Button:GetScript("OnClick")(GwTalentFrame.navigation.spec1Button)
    end
end
local function selectSpecButton(self)
    if (GetCVarBool("previewTalentsOption")) then
        SetPreviewPrimaryTalentTree(self:GetParent().spec, GetActiveTalentGroup());
    else
        SetPrimaryTalentTree(self:GetParent().spec);
    end
    GW.updateTalentTrees()
end

local function getRoleIcon(role)
    local path = "Interface\\AddOns\\GW2_UI\\textures\\party\\roleicon-"
    if (role == "TANK") then
        return path .. "tank"
    end
    if (role == "HEALER") then
        return path .. "healer"
    end
    if (role == "DAMAGER") then
        return path .. "dps"
    end
end

local function getBonusFrame(self, index)
    if self.bonus == nil then
        self.bonus = {}
    end
    if self.bonus[index] == nil then
        local x, y = 0, 0
        y = (index - 1) * -44;

        local f = CreateFrame("Button", nil, self, "GwTalentBonusSpell")
        f:SetSize(30, 30)
        f:SetPoint("TOPLEFT", self, "TOPLEFT", x, y)
        f.outline:SetSize(f:GetWidth() * 1.2, f:GetHeight() * 1.2)
        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", f, "CENTER", 0, 0)
        mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        mask:SetSize(f:GetSize())

        f.mask = mask
        mask:SetParent(f);
        self.bonus[index] = f;

        return f
    end
    return self.bonus[index]
end

local function setBonusSpell(self, spellID, spellID2, formatString, desaturated)
    local name, subname, icon = GetSpellInfo(spellID);
    if (spellID2) then
        local name2, _, _ = GetSpellInfo(spellID2);
        if name2 and name then
            name = name .. "/" .. name2;
        end
    end

    if (formatString) then
        self.name:SetFormattedText(formatString, name);
    else
        self.name:SetText(name);
    end

    self.icon:SetTexture(icon)

    self.icon:SetDesaturated(desaturated)

    self.spellId = spellID
    self.booktype = "spell"
    self.isFuture = true
    self.isFlyout = false
    self.futureSpellOverrider = true
    self.requiredLevel = 0


    self.lock:Hide()
    self.arrow:Hide()
    self.autocast:Hide()

    if IsPassiveSpell(spellID) then
        self.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight')
        self.icon:AddMaskTexture(self.mask)
        self.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline')
    else
        self.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight')
        self.icon:RemoveMaskTexture(self.mask)
        self.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border')
    end
    self:SetScript("OnEnter", GW.spellbook.spell_buttonOnEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)
    self:Show()
end

local function updateTalentSummary(self)
    local activeTalentGroup = GetActiveTalentGroup();
    local primaryTree = GetPreviewPrimaryTalentTree(false, false, openSpec)
        or GetPrimaryTalentTree(false, false, openSpec);

    self.summary.isPrimaryTree = (primaryTree and primaryTree == self.spec) and true or false

    local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(
        self.spec, false, isPetTalents, openSpec);
    local role1, role2 = GetTalentTreeRoles(self.spec, false, isPetTalents);
    local desaturated = false;

    local summary = self.summary

    summary.specIcon:SetTexture(specIcons[icon])
    if not summary.specIcon.mask then
        local mask = UIParent:CreateMaskTexture()

        mask:SetPoint("CENTER", summary.specIcon, 'CENTER', 0, 0)
        mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        mask:SetSize(summary.specIcon:GetSize())
        summary.specIcon:AddMaskTexture(mask);
        mask:SetParent(summary)
        summary.specIcon.mask = mask

        --background mask
        summary.backgroundOverlay:AddMaskTexture(summary.backgroundMask)
    end

    summary.specName:SetText(name)
    summary.specDesc:SetText(description)


    if (role1 == "TANK" or role1 == "HEALER" or role1 == "DAMAGER") then
        summary.roleIcon:SetTexture(getRoleIcon(role1))
    end
    if (role2 == "TANK" or role2 == "HEALER" or role2 == "DAMAGER") then
        summary.roleIcon:SetPoint("CENTER", summary.specIcon, "BOTTOMRIGHT", -18, 12)
        summary.roleIcon2:SetTexture(getRoleIcon(role2))
        summary.roleIcon2:Show()
    end


    if ((primaryTree and self.spec ~= primaryTree) or (openSpec ~= activeTalentGroup) or GetNumTalentPoints() == 0) then
        desaturated = true
    end

    summary.specIcon:SetDesaturated(desaturated)
    summary.background:SetDesaturated(desaturated)
    summary.backgroundFx:SetDesaturated(desaturated)
    if (not primaryTree and GetNumTalentPoints() > 0) and activeSpec == openSpec then -- WIP if we can select a spec this should be interactable
        summary.interactable = true;
        summary:SetScript("OnClick", selectSpecButton)
    else
        summary.interactable = false;
        summary:SetScript("OnClick", nil)
    end

    local bonuses = { GetMajorTalentTreeBonuses(self.spec, false, false) };
    local bonusFrameIndex = 1
    for i = 1, #bonuses do
        local bonusFrame = getBonusFrame(summary.spells, bonusFrameIndex)

        if (bonusFrame) then
            setBonusSpell(bonusFrame, bonuses[i], nil, nil, desaturated)
        end
        bonusFrameIndex = bonusFrameIndex + 1
    end
    bonuses = { GetMinorTalentTreeBonuses(self.spec, false, false) };

    for i = 1, #bonuses do
        local bonusFrame = getBonusFrame(summary.spells, bonusFrameIndex)

        if (bonusFrame) then
            setBonusSpell(bonusFrame, bonuses[i], nil, nil, desaturated)
        end
        bonusFrameIndex = bonusFrameIndex + 1
    end
    bonuses = { GetTalentTreeEarlySpells(self.spec, false, false) };

    for i = 1, #bonuses do
        local bonusFrame = getBonusFrame(summary.spells, bonusFrameIndex)

        if (bonusFrame) then
            setBonusSpell(bonusFrame, bonuses[i], nil, nil, desaturated)
        end
        bonusFrameIndex = bonusFrameIndex + 1
    end
    local masterySpell, masterySpell2 = GetTalentTreeMasterySpells(self.spec);
    if (UnitLevel("player") >= SHOW_MASTERY_LEVEL and masterySpell) then
        local _, class = UnitClass("player");
        local masteryKnown = IsSpellKnown(CLASS_MASTERY_SPELLS[class]);
        local bonusFrame = getBonusFrame(summary.spells, bonusFrameIndex)

        if (bonusFrame) then
            setBonusSpell(bonusFrame, masterySpell, masterySpell2, TALENT_MASTERY_LABEL, desaturated)
            --Override icon to Mastery icon
            local _, _, masteryTexture = GetSpellInfo(CLASS_MASTERY_SPELLS[class]);
            bonusFrame.icon:SetTexture(masteryTexture);
            bonusFrame.icon:SetDesaturated(desaturateBonuses or not masteryKnown);
        end
    end
    if primaryTree then
        toggleSummaryScreen(nil, nil, nil, false)
    else
        toggleSummaryScreen(nil, nil, nil, true)
    end
end


local function UpdateActiveSpec(activeTalentGroup)
    -- set the active spec
    activeSpec = 1
    for i = 1, 2 do
        if i == activeTalentGroup then
            activeSpec = i
            break
        end
    end
end

local function UpdateTalentPoints()
    local talentPoints = GetUnspentTalentPoints(false, isPetTalents, openSpec)
    local unspentPoints = talentPoints - GetGroupPreviewTalentPointsSpent(isPetTalents, openSpec);

    return unspentPoints
end

local function talentBunnton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    GameTooltip:SetTalent(self.talentFrameId, self.talentid, false, isPetTalents, openSpec,
        GetCVarBool("previewTalentsOption"))
    self.UpdateTooltip = talentBunnton_OnEnter
end

local function setBackgroundFxHeight(self, height,shouldBeHidden)
    if shouldBeHidden or height<1 then
        self.backgroundFx:Hide()
        return 
    end
    self.backgroundFx:Show()
    local maxHeight = self:GetHeight()
    if self.fxHeight == nil then
        self.fxHeight = self.backgroundFx:GetHeight()
        self.fxOldHeight = self.fxHeight;
        return
    end

    if self.fxHeight == nil or self.fxHeight > height then
        self.backgroundFx:SetHeight(height)
        self.backgroundFx:SetTexCoord(self.bgCoords.l,self.bgCoords.r,self.bgCoords.t,self.bgCoords.b*(height/maxHeight))
        self.fxHeight = height
        self.fxOldHeight = self.fxHeight;
        return
    end
    local oldHeight = self.fxOldHeight
    AddToAnimation(self:GetName(), 0, 1, GetTime(), 0.2,
        function()
            local p = animations[self:GetName()].progress
            local height = lerp(oldHeight, height, p)
            self.backgroundFx:SetHeight(height)
            self.backgroundFx:SetTexCoord(self.bgCoords.l,self.bgCoords.r,self.bgCoords.t,self.bgCoords.b*(height/maxHeight))
            self.fxOldHeight = height
            self.fxHeight = height
        end
    )
end

local function hookTalentButton(talentButton, container, row, index)
    local w = container:GetWidth()
    local h = container:GetHeight()

    local columnSize = w / NUM_TALENT_COLUMNS
    local rowSize = h / MAX_NUM__VISUAL_TALENT_TIERS

    local x = (w / NUM_TALENT_COLUMNS) * (index - 1) + columnSize / 2
    local y = (h / MAX_NUM__VISUAL_TALENT_TIERS) * (row - 1) + rowSize / 2 + TALENT_TOP_PADDING

    talentButton:RegisterForClicks("AnyUp")
    talentButton:ClearAllPoints();
    talentButton:SetPoint('CENTER', container, 'TOPLEFT', x, -y)

    talentButton:SetScript("OnEnter", talentBunnton_OnEnter)
    talentButton:SetScript("OnLeave", GameTooltip_Hide)
    talentButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" and openSpec == activeSpec then
            if IsModifiedClick("CHATLINK") then
                local link = GetTalentLink(self.talentFrameId, self.talentid, false, isPetTalents, openSpec,
                    GetCVarBool("previewTalentsOption"))
                if link then
                    ChatEdit_InsertLink(link)
                end
            else
                if GetCVarBool("previewTalentsOption") then
                    AddPreviewTalentPoints(self.talentFrameId, self.talentid, 1, isPetTalents, openSpec)
                else
                    LearnTalent(self.talentFrameId, self.talentid, isPetTalents, openSpec)
                end
            end
        elseif button == "RightButton" and openSpec == activeSpec then
            if GetCVarBool("previewTalentsOption") then
                AddPreviewTalentPoints(self.talentFrameId, self.talentid, -1, isPetTalents, openSpec)
            end
        end
    end)
    talentButton:SetScript("OnEvent", function(self)
        if GameTooltip:IsOwned(self) then
            GameTooltip:SetTalent(self.talentFrameId, self.talentid)
        end
    end)
    talentButton:RegisterEvent("CHARACTER_POINTS_CHANGED")

    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("CENTER", talentButton, 'CENTER', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE")
    mask:SetSize(talentButton:GetSize())
    talentButton.mask = mask
    mask:SetParent(talentButton);
    talentButton.points:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    talentButton.points:SetTextColor(1, 1, 1, 1)
end

local function getArrow(frame, teir, column, i)
    local n = "GwLegacyTalentLine" .. "-" .. frame .. "-" .. teir .. "-" .. column .. "-" .. i
    if _G[n] == nil then
        return CreateFrame('Frame', n, _G["GwLegacyTalentTree" .. frame].treeContainer, 'GwLegacyTalentLine')
    end
    _G[n]:Show()
    return _G[n]
end

local function colorTalentArrow(self, active)
    local color = { r = 1, b = 0.6, g = 1 }
    if active == nil then
        color = { r = 0.3, b = 0.3, g = 0.3 }
    end
    self.up:SetVertexColor(color.r, color.g, color.b)
    self.down:SetVertexColor(color.r, color.g, color.b)
    self.left:SetVertexColor(color.r, color.g, color.b)
    self.right:SetVertexColor(color.r, color.g, color.b)
end

local function drawLegacyLine(path, frame, teir, column, requirementsMet)
    local w = _G["GwLegacyTalentTree" .. frame].treeContainer:GetWidth()
    local h = _G["GwLegacyTalentTree" .. frame].treeContainer:GetHeight()
    local cTeir = teir
    local cCol = column

    for i = 1, #path do
        local columnSize = w / NUM_TALENT_COLUMNS
        local rowSize = h / MAX_NUM__VISUAL_TALENT_TIERS

        local rowOffset = 0
        local columnOffset = 0


        local arrow = getArrow(frame, cTeir, cCol, i)
        arrow:SetSize(columnSize, rowSize)
        arrow.up:SetSize(rowSize, rowSize)
        arrow.down:SetSize(rowSize, rowSize)
        arrow.left:SetSize(columnSize, columnSize)
        arrow.right:SetSize(columnSize, columnSize)
        arrow:ClearAllPoints()


        if path[i].y ~= 0 then
            if path[i].y > 0 then
                arrow.up:Show()
            end
            if path[i].y < 0 then
                arrow.down:Show()
            end
        end
        if path[i].x ~= 0 then
            if path[i].x > 0 then
                arrow.right:Show()
            end
            if path[i].x < 0 then
                arrow.left:Show()
            end
        end


        local x = (columnSize * (cCol - 1) + columnSize / 2)
        local y = (rowSize * (cTeir - 1) + rowSize / 2) + TALENT_TOP_PADDING

        arrow:SetPoint("CENTER", _G["GwLegacyTalentTree" .. frame].treeContainer, "TOPLEFT", x, -y);
        colorTalentArrow(arrow, requirementsMet)
        cTeir = cTeir + path[i].y
        cCol = cCol + path[i].x
    end
end


local function getLinePath(buttonTier, buttonColumn, tier, column, frame, requirementsMet)
    --[[
        Get path to required talent
        Blocking spells are not implemented as there are none in classic
    ]]
    local path = {}
    local blocked = false

    -- Check to see if are in the same column
    if buttonColumn == column then
        if (buttonTier - tier) > 1 then
            for i = tier, buttonTier - 1 do
                path[#path + 1] = { x = 0, y = 1 }
            end
        else
            path[#path + 1] = { x = 0, y = 1 }
        end
        if not blocked then
            return drawLegacyLine(path, frame, tier, column, requirementsMet)
        end
    end

    blocked = false
    if buttonTier == tier then
        local left = min(buttonColumn, column)
        local right = max(buttonColumn, column)

        -- See if the distance is greater than one space
        if (right - left) > 1 then
            for i = buttonColumn + 1, column - 1 do
                if TALENT_BRANCH_ARRAY[frame][i][column].id ~= nil then
                    blocked = true
                else
                    path[#path + 1] = { x = 1, y = 0 }
                end
            end
        else
            if buttonColumn < column then
                path[#path + 1] = { x = -1, y = 0 }
            else
                path[#path + 1] = { x = 1, y = 0 }
            end
        end
        if not blocked then
            return drawLegacyLine(path, frame, tier, column, requirementsMet)
        end
    end
    path[#path + 1] = { x = 1, y = 0 }
    path[#path + 1] = { x = 0, y = 1 }

    return drawLegacyLine(path, frame, tier, column, requirementsMet)
end

local function TalentFrame_SetPrereqs(frame, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, preview, ...)
    local requirementsMet = tierUnlocked and not forceDesaturated

    for i = 1, select('#', ...), 4 do
        local tier, column, isLearnable, isPreviewLearnable = select(i, ...)
        if (forceDesaturated or
                (preview and not isPreviewLearnable) or
                (not preview and not isLearnable)) then
            requirementsMet = nil
        end
        getLinePath(buttonTier, buttonColumn, tier, column, frame, requirementsMet)
    end
    return requirementsMet
end

local function CleanUpTalentTrees()
    wipe(TALENT_BRANCH_ARRAY)
    for i = 1, 3 do
        TALENT_BRANCH_ARRAY[i] = {}
        for y = 1, 15 do
            TALENT_BRANCH_ARRAY[i][y] = {}
            for j = 1, NUM_TALENT_COLUMNS do
                TALENT_BRANCH_ARRAY[i][y][j] = { id = nil, up = 0, left = 0, right = 0, down = 0, leftArrow = 0, rightArrow = 0, topArrow = 0 }
                local button = _G['GwLegacyTalentTree' .. i .. 'Teir' .. y .. 'index' .. j]
                button.talentid = nil
                button:Hide()

                for l = 1, 10 do
                    local line = _G["GwLegacyTalentLine" .. "-" .. i .. "-" .. y .. "-" .. j .. "-" .. l]
                    if line then
                        line:Hide()
                    end
                end
            end
        end
    end
end



local function updateTalentTrees()
    if InCombatLockdown() then return end

    local activeTalentGroup = GetActiveTalentGroup()
    local hasDualSpec = GetNumTalentGroups(false, false) > 1
    local hasPetTalents = GetNumTalentGroups(false, true) > 0

    -- preview
    UpdatePreviewControls()

    UpdateActiveSpec(activeTalentGroup)

    if isPetTalents then
        GwTalentFrame.navigation.activateSpecGroup:Hide()
    elseif hasDualSpec then
        GwTalentFrame.navigation.spec1Button:Show()
        GwTalentFrame.navigation.spec2Button:Show()
        GwTalentFrame.navigation.spec1Button:SetEnabled(openSpec == 2 or isPetTalents)
        GwTalentFrame.navigation.spec2Button:SetEnabled(openSpec == 1 or isPetTalents)
        GwTalentFrame.navigation.activateSpecGroup:SetShown(openSpec ~= activeTalentGroup)
    else
        GwTalentFrame.navigation.spec1Button:Show()
        GwTalentFrame.navigation.spec2Button:Hide()
        GwTalentFrame.navigation.activateSpecGroup:Hide()
    end

    GwTalentFrame.navigation.petTalentsButton:SetShown(hasPetTalents)

    GwTalentFrame.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS,
        UpdateTalentPoints() ..
        " |TInterface/AddOns/GW2_UI/textures/icons/talent-icon: 24, 24, 0, 0, 0.1875, 0.828125 , 0.1875, 0.828125 |t ")

    for f = 1, GW.api.GetNumSpecializations(isPetTalents) do
        local forceDesaturated
        local talentPoints = UpdateTalentPoints()
        local activeTalentGroup = GetActiveTalentGroup();
        local primaryTree = GetPreviewPrimaryTalentTree(false, false, openSpec)
            or GetPrimaryTalentTree(false, false, openSpec);
        local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(f,
            false,
            isPetTalents, openSpec)
        --Blizzard  local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(selectedTab, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
        local TalentFrame = _G["GwLegacyTalentTree" .. f]
        local preview = GetCVarBool("previewTalentsOption")


        




        TalentFrame.pointsSpent = pointsSpent + previewPointsSpent

        if pointsSpent < 1 and previewPointsSpent<1 then
            TalentFrame.background:SetDesaturated(true)
        else
            TalentFrame.background:SetDesaturated(false)
        end
        TalentFrame.talentPoints = talentPoints
        TalentFrame.talentFrameId = f


        local shouldBeHidden = false 
        if (not isUnlocked and primaryTree) then
            shouldBeHidden = true
        elseif (primaryTree and primaryTree ~= TalentFrame.spec) then
            shouldBeHidden = false
        else 
            shouldBeHidden = false
        end



        local numTiersUnlocked = math.floor(TalentFrame.pointsSpent /
        (isPetTalents and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER)) +1

        local tierHeight = TalentFrame.treeContainer:GetHeight() / MAX_NUM__VISUAL_TALENT_TIERS;
        local totalHeight = (tierHeight * numTiersUnlocked) + TALENT_TOP_PADDING + (tierHeight / 2) - 10
        if not isUnlocked then 
            totalHeight = 0
        end
        if numTiersUnlocked>= MAX_NUM_TALENT_TIERS then 
            totalHeight = TalentFrame.background:GetHeight()
        end

        
        setBackgroundFxHeight(TalentFrame,totalHeight,shouldBeHidden)



        TalentFrame.info.title:SetText(name)
        TalentFrame.info.points:SetText(TalentFrame.pointsSpent)

        local numTalents = GetNumTalents(f, false, isPetTalents)
        for i = 1, MAX_NUM_TALENTS do
            local name, texture, tier, column, rank, maxRank, meetsPrereq, previewRank, meetsPreviewPrereq, isExceptional, goldBorder =
                GetTalentInfo(f, i, false, isPetTalents, openSpec)
            local button = _G['GwLegacyTalentTree' .. f .. 'Teir' .. tier .. 'index' .. column]


            -- copie from blizzard
            -- Temp hack - For now, we are just ignoring the "goldBorder" flag and putting the gold border on any "exceptional" talents
            goldBorder = isExceptional

            if name and i <= numTalents then
                TALENT_BRANCH_ARRAY[f][tier][column].id = i
                button.icon:SetTexture(texture)
                button.points:SetText((preview and previewRank or rank) .. " / " .. maxRank)
                button.talentid = i
                button.talentFrameId = f
                button:Show()
                button.active = true

                -- If player has no talent points or this is the inactive talent group then show only talents with points in them
                if (TalentFrame.talentPoints <= 0 or not openSpec == activeTalentGroup) and (preview and previewRank or rank) == 0 then
                    forceDesaturated = 1
                else
                    forceDesaturated = nil
                end
                -- If the player has spent at least 5 talent points in the previous tier

                if (isUnlocked and ((tier - 1) * (isPetTalents and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER) <= TalentFrame.pointsSpent)) then
                    tierUnlocked = 1;
                else
                    tierUnlocked = nil;
                end

                local ispassive = not isExceptional
                local Prereqs = TalentFrame_SetPrereqs(f, tier, column, forceDesaturated, tierUnlocked, preview,
                    GetTalentPrereqs(f, i, false, isPetTalents, openSpec))

                button.talentID = i
                button.known = (preview and previewRank or rank) == maxRank

                if ispassive then
                    button.legendaryHighlight:SetTexture(
                        'Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight')
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight')
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline')
                else
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight')
                    button.legendaryHighlight:SetTexture(
                        'Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight')
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border')
                end

                button:EnableMouse(true)
                if Prereqs and ((preview and meetsPreviewPrereq) or (not preview and meetsPrereq)) then
                    button.icon:SetDesaturated(openSpec ~= activeTalentGroup)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                    if rank < maxRank then
                        button.highlight:Hide()
                        button.points:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                    else
                        button.highlight:Show()
                        button.points:SetText(maxRank .. " / " .. maxRank)
                        button.points:SetTextColor(0.87, 0.74, 0.29, 1)
                    end
                else
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.4)
                    button.highlight:Hide()
                    button.points:SetText("")
                end
            else
                if button and button.talentid == nil then
                    button:Hide()
                end
            end
        end
        updateTalentSummary(TalentFrame)
    end
    -- Clean up unsuded slots
    for i = 1, GW.api.GetNumSpecializations(isPetTalents) do
        for y = 1, 15 do
            for j = 1, NUM_TALENT_COLUMNS do
                local button = _G['GwLegacyTalentTree' .. i .. 'Teir' .. y .. 'index' .. j]
                if button.talentid == nil then
                    button:Hide()
                end
            end
        end
    end
end
GW.updateTalentTrees = updateTalentTrees -- HACK fix




local function loadTalentsFrames()
    local _, _, classID = UnitClass('player')
    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("TOPLEFT", GwCharacterWindow, 'TOPLEFT', 0, 0)
    mask:SetParent(GwCharacterWindow)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    for i = 1, GW.api.GetNumSpecializations(isPetTalents) do
        TALENT_BRANCH_ARRAY[i] = {}
        local container = CreateFrame('Button', 'GwLegacyTalentTree' .. i, GwTalentFrame, 'GwLegacyTalentTree')

        container:SetPoint('TOPLEFT', GwTalentFrame, 'TOPLEFT', (284 * (i - 1)), -92)
        container.spec = i

        container.bgCoords = { l = 0.27734375 * (i - 1), r = 0.27734375 * i, t = 0, b = 0.611328125 }

        container.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\' .. classID)
        container.background:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)
        container.backgroundFx:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\' .. classID)
        container.backgroundFx:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)
        container.summary.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\' .. classID)
        container.summary.background:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)
        container.summary.backgroundFx:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\' ..
            classID)
        container.summary.backgroundFx:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)

        container.background:AddMaskTexture(mask)
        container.backgroundFx:AddMaskTexture(mask)
        container.summary.backgroundFx:AddMaskTexture(mask)
        container.summary.backgroundOverlay:AddMaskTexture(mask)
        container.summary.background:AddMaskTexture(mask)
        container:HookScript('OnShow', function()
            if InCombatLockdown() then return end
            updateTalentTrees()
        end)

        for y = 1, 15 do
            TALENT_BRANCH_ARRAY[i][y] = {}
            for j = 1, NUM_TALENT_COLUMNS do
                TALENT_BRANCH_ARRAY[i][y][j] = { id = nil, up = 0, left = 0, right = 0, down = 0, leftArrow = 0, rightArrow = 0, topArrow = 0 }
                local talentButton = CreateFrame('Button', 'GwLegacyTalentTree' .. i .. 'Teir' .. y .. 'index' .. j,
                    container.treeContainer, 'GwTalentButton')
                hookTalentButton(talentButton, container.treeContainer, y, j)
            end
        end
    end

    updateTalentTrees()
end
local function setNavigation(self)
    GwTalentFrame.navigation.spec1Button.selected = false
    GwTalentFrame.navigation.spec2Button.selected = false
    GwTalentFrame.navigation.petTalentsButton.selected = false
    GwTalentFrame.navigation.spec1Button.background:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\button-normal")
    GwTalentFrame.navigation.spec2Button.background:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\button-normal")
    GwTalentFrame.navigation.petTalentsButton.background:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\talents\\button-normal")
    self.selected = true
    self.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\button-selected")
end

local function LoadTalents()
    TalentFrame_LoadUI()

    CreateFrame('Frame', 'GwTalentFrame', GwCharacterWindow, 'GwLegacyTalentFrame')

    GwTalentFrame.navigation.activateSpecGroup:SetWidth(GwTalentFrame.navigation.activateSpecGroup:GetTextWidth() + 40)

    loadTalentsFrames()

    updateTalentSummary(_G["GwLegacyTalentTree1"])
    updateTalentSummary(_G["GwLegacyTalentTree2"])
    updateTalentSummary(_G["GwLegacyTalentTree3"])

    GwTalentFrame.navigation.petTalentsButton.icon:SetTexture(
        "Interface\\AddOns\\GW2_UI\\textures\\character\\tabicon_pet")
    GwTalentFrame.navigation.petTalentsButton.icon:SetTexCoord(0.6796875, 0.96875, 0.046875, 0.625)

    GwTalentFrame.bottomBarSummary.viewTalentTrees:SetScript("OnClick", toggleSummaryScreen)
    GwTalentFrame.bottomBar.viewSummary:SetScript("OnClick", toggleSummaryScreen)


    GwTalentFrame.bottomBar.prevCancel:SetScript("OnClick", function()
        ResetGroupPreviewTalentPoints(isPetTalents, openSpec)
        updateTalentTrees()
    end)
    GwTalentFrame.bottomBar.prevLearn:SetScript("OnClick", function()
        StaticPopup_Show("GW_CONFIRM_LEARN_PREVIEW_TALENTS")
        updateTalentTrees()
    end)

    GwTalentFrame.navigation.spec1Button:SetScript("OnClick", function(self)
        setNavigation(self)
        openSpec                      = 1
        isPetTalents                  = false
        PlayerTalentFrame.pet         = false
        PlayerTalentFrame.talentGroup = 1
        CleanUpTalentTrees()
        updateTalentTrees()
        GwTalentFrame.bottomBar.viewSummary:Show()
    end)
    GwTalentFrame.navigation.spec2Button:SetScript("OnClick", function(self)
        setNavigation(self)
        openSpec                      = 2
        isPetTalents                  = false
        PlayerTalentFrame.pet         = false
        PlayerTalentFrame.talentGroup = 2
        CleanUpTalentTrees()
        updateTalentTrees()
        GwTalentFrame.bottomBar.viewSummary:Show()
    end)
    GwTalentFrame.navigation.petTalentsButton:SetScript("OnClick", function(self)
        setNavigation(self)
        openSpec                      = 1
        isPetTalents                  = true
        PlayerTalentFrame.pet         = isPetTalents
        PlayerTalentFrame.talentGroup = 1
        CleanUpTalentTrees()
        updateTalentTrees()
        toggleSummaryScreen(self,nil,nil,false)
        GwTalentFrame.bottomBar.viewSummary:Hide()

    end)
    GwTalentFrame.navigation.activateSpecGroup:SetScript("OnClick", function()
        if openSpec then
            SetActiveTalentGroup(openSpec)
            updateTalentTrees()
        end
    end)

    if activeSpec == 1 then
        GwTalentFrame.navigation.spec1Button:GetScript("OnClick")(GwTalentFrame.navigation.spec1Button)
    elseif activeSpec == 2 then
        GwTalentFrame.navigation.spec2Button:GetScript("OnClick")(GwTalentFrame.navigation.spec2Button)
    end


    GwTalentFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    GwTalentFrame:RegisterEvent("PET_TALENT_UPDATE")
    GwTalentFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    GwTalentFrame:RegisterEvent("TALENT_GROUP_ROLE_CHANGED")
    GwTalentFrame:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED")
    GwTalentFrame:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED")
    GwTalentFrame:RegisterEvent("PREVIEW_TALENT_PRIMARY_TREE_CHANGED")
    GwTalentFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    GwTalentFrame:SetScript('OnEvent', function(self, event)
        GwTalentFrame.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS,
            UnitCharacterPoints("player") ..
            " |TInterface/AddOns/GW2_UI/textures/icons/talent-icon: 24, 24, 0, 0, 0.1875, 0.828125 , 0.1875, 0.828125 |t ")

        if event == "LEARNED_SPELL_IN_TAB" then
            updateTalentSummary(_G["GwLegacyTalentTree1"])
            updateTalentSummary(_G["GwLegacyTalentTree2"])
            updateTalentSummary(_G["GwLegacyTalentTree3"])
            return
        end

        if not GwTalentFrame:IsShown() then return end
        updateTalentTrees()
    end)
    GwTalentFrame:SetScript('OnShow', function()
        if InCombatLockdown() then return end
        updateTalentTrees()
        updateTalentSummary("GwLegacyTalentTree1")
        updateTalentSummary("GwLegacyTalentTree2")
        updateTalentSummary("GwLegacyTalentTree3")
    end)
    hooksecurefunc('ToggleTalentFrame', function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute("keytoggle", true)
        GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
    end)
    GwTalentFrame:Hide()
    return GwTalentFrame
end
GW.LoadTalents = LoadTalents
