local _, GW = ...
local SetClassIcon = GW.SetClassIcon
local UpdatePvPTab = GW.UpdatePvPTab
local CreatePvPTab = GW.CreatePvPTab
local IsIn = GW.IsIn

local maxTalentRows = 10
local talentsPerRow = 10

local function setSpecTabIconAndTooltip(tab)
    -- update spec-specific skill tab tooltip and icon
    local _, specName, _ = C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
    tab.gwTipLabel = specName
    local spec = C_SpecializationInfo.GetSpecialization()
    if spec then
        local role = GetSpecializationRole(spec)
        tab.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon.png")
        if role == "DAMAGER" then
            tab.icon:SetTexCoord(0.75, 1, 0.75, 1)
        elseif role == "TANK" then
            tab.icon:SetTexCoord(0.75, 1, 0.5, 0.75)
        elseif role == "HEALER" then
            tab.icon:SetTexCoord(0.25, 0.5, 0.75, 1)
        else
            -- set default icon
            tab.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/lock.png")
            tab.icon:SetTexCoord(0, 1, 0, 1)
        end
    end
end
GW.SetSpecTabIconAndTooltip = setSpecTabIconAndTooltip

local function spellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    if InClickBindingMode() and not self.canClickBind then
        GameTooltip:AddLine(CLICK_BINDING_NOT_AVAILABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
        GameTooltip:Show();
        return;
    end
    if self.skillType == "TALENT" then
        GameTooltip:SetSpellByID(self.spellId)
    elseif not self.isFlyout and self.spellbookIndex then
        GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
    elseif not self.spellbookIndex and self.spellId then
        GameTooltip:SetSpellByID(self.spellId)
    else
        local name, desc, _, _ = GetFlyoutInfo(self.spellId)
        GameTooltip:AddLine(name)
        GameTooltip:AddLine(desc)
    end
    if self.isFuture then
        if self.unlockLevel then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(UNLOCKS_AT_LEVEL:format(self.unlockLevel), 1, 1, 1)
        elseif C_Spell.GetSpellLevelLearned(self.spellId) > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(UNLOCKS_AT_LEVEL:format(C_Spell.GetSpellLevelLearned(self.spellId)), 1, 1, 1)
        end
    end
    GameTooltip:Show()
end


local function spellButton_OnDragStart(self)
    if InCombatLockdown() or self.isFuture then
        return
    end
    PickupSpellBookItem(self.spellbookIndex, self.booktype)
end


local function spellButton_ClickBindCast(self)
    if InClickBindingMode() then
        if ClickBindingFrame:HasNewSlot() and self.canClickBind then
            ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Spell, self.spellId);
        end
    end
end

local function spellButton_GlyphApply(self, unit, button, actionType)
    GW.Debug("in glyph application", unit, button, actionType)
    if HasPendingGlyphCast() then
        --local slotType, spellId = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
        local spellId = self.spellId
        if self.skillType == "SPELL" then
            if HasAttachedGlyph(spellId) then
                if IsPendingGlyphRemoval() then
                    StaticPopup_Show(
                        "CONFIRM_GLYPH_REMOVAL",
                        nil,
                        nil,
                        {name = GetCurrentGlyphNameForSpell(spellId), id = spellId}
                    )
                else
                    StaticPopup_Show(
                        "CONFIRM_GLYPH_PLACEMENT",
                        nil,
                        nil,
                        {name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(spellId), id = spellId}
                    )
                end
            else
                AttachGlyphToSpell(spellId)
            end
        elseif self.skillType == "FLYOUT" then
            SpellFlyout:Toggle(spellId, self, "RIGHT", 1, false, self.offSpecID, true)
            SpellFlyout:SetBorderColor(181 / 256, 162 / 256, 90 / 256)
        end
    end
end


local spellButtonSecure_OnDragStart =
    [=[
    local isPickable = self:GetAttribute("ispickable")
    local spellId = self:GetAttribute("spell")

    if not spellId or not isPickable then
        return "clear", nil
    end

    return "clear", "spell", spellId
    ]=]

local function setButton(btn, spellId, skillType, icon, spellbookIndex, booktype)
    btn.isFuture = (skillType == "FUTURESPELL")
    btn.spellbookIndex = spellbookIndex
    btn.booktype = booktype
    btn.spellId = spellId
    btn.skillType = skillType
    btn.icon:SetTexture(icon)
    btn:SetAlpha(1)
    btn:Show()

    if btn.isFuture then
        btn.icon:SetDesaturated(true)
        btn.icon:SetAlpha(0.5)
    else
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1)
    end
end


local function TalProfButton_OnModifiedClick(self)
    local slot = self.spellbookIndex
    local book = self.booktype
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            local spell, subSpell = C_SpellBook.GetSpellBookItemName(slot, book)
            if spell and not IsPassiveSpell(slot, book) then
                if subSpell and strlen(subSpell) > 0 then
                    ChatFrameUtil.InsertLink(spell .. "(" .. subSpell .. ")")
                else
                    ChatFrameUtil.InsertLink(spell)
                end
            end
        else
            local profLink, profId = GetSpellTradeSkillLink(slot, book)
            if profId then
                ChatFrameUtil.InsertLink(profLink)
            else
                ChatFrameUtil.InsertLink(GetSpellLink(slot, book))
            end
        end
    elseif IsModifiedClick("PICKUPACTION") and not InCombatLockdown() and not IsPassiveSpell(slot, book) then
        PickupSpellBookItem(slot, book)
    end
end
GW.TalProfButton_OnModifiedClick = TalProfButton_OnModifiedClick

local function setActiveButton(btn, spellId, skillType, icon, spellbookIndex, booktype, name)
    setButton(btn, spellId, skillType, icon, spellbookIndex, booktype)

    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)
    if autostate then
        btn.autocast:Show()
    else
        btn.autocast:Hide()
    end

    btn:SetAttribute("ispickable", false)
    btn.isFlyout = (skillType == "FLYOUT")
    if btn.isFlyout then
        btn.arrow:Show()
        btn:SetAttribute("*type1", "flyout")
        btn:SetAttribute("*type2", "flyout")
        btn:SetAttribute("spell", spellId)
        btn:SetAttribute("flyout", spellId)
        btn:SetAttribute("flyoutDirection", "LEFT")
    elseif not btn.isFuture and booktype == BOOKTYPE_PET then
        btn:SetAttribute("*type1", "spell")
        btn:SetAttribute("*type2", "macro")
        btn:SetAttribute("spell", spellId)
        btn:SetAttribute("*macrotext2", "/petautocasttoggle " .. name)
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    elseif not btn.isFuture then
        btn:SetAttribute("ispickable", true)
        btn:SetAttribute("*type1", "spell")
        btn:SetAttribute("*type2", "spell")
        btn:SetAttribute("spell", spellId)
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    else
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    end

    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:EnableMouse(true)
end


local function setPassiveButton(btn, spellId, skillType, icon, spellbookIndex, booktype, tab, name)
    setButton(btn, spellId, skillType, icon, spellbookIndex, booktype, tab, name)
    btn:SetAttribute("shift-type1", "modifiedClick")
    btn:SetAttribute("shift-type2", "modifiedClick")
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:EnableMouse(true)
end


local function checkForClickBinding(btn, spellId, fmSpellbook)
    btn.canClickBind = false
    if InClickBindingMode() then
        btn.SpellHighlightTexture:Hide();
        local spellBindable = spellId and C_ClickBindings.CanSpellBeClickBound(spellId) or false;
        local isDisabled = spellId and C_SpellBook.IsSpellDisabled(spellId)
        local isOffSpec = (btn.offSpecID ~= 0) and (btn.bookType == BOOKTYPE_SPELL);
        local canBind = spellBindable and (not isOffSpec) and (not isDisabled);
        if (canBind) then
            btn.canClickBind = true;
            if (ClickBindingFrame:HasEmptySlot()) then
                btn.ClickBindingHighlight:Show();
            end
            btn:SetAttribute("type1", "CustomClickCastClick") -- enable strict left-click clickBindCast
        else
            btn.ClickBindingIconCover:Show();
        end
    elseif fmSpellbook.glyphReason == nil then
        btn:SetAttribute("type1", nil)
        btn.ClickBindingHighlight:Hide()
    end
end

local function checkForGlyph(btn, spellId, fmSpellbook)
    if HasAttachedGlyph(spellId) then
        btn.GlyphIcon:Show()
        if IsPendingGlyphRemoval() and fmSpellbook.glyphReason then
            btn.AbilityHighlight:Show()
            btn.AbilityHighlightAnim:Play()
            btn:SetAttribute("type1", "GlyphApply") -- enable strict left-click glyph applying
        else
            btn.AbilityHighlightAnim:Stop()
            btn.AbilityHighlight:Hide()
            btn:SetAttribute("type1", nil)
        end
    else
        btn.GlyphIcon:Hide()
    end
    if fmSpellbook.glyphSlot == spellId then
        if (fmSpellbook.glyphReason == "USE_GLYPH") then
            btn.AbilityHighlight:Show()
            btn.AbilityHighlightAnim:Play()
            btn:SetAttribute("type1", "GlyphApply") -- enable strict left-click glyph applying
            fmSpellbook.glyphBtn = btn
        else
            btn.AbilityHighlightAnim:Stop()
            btn.AbilityHighlight:Hide()
            fmSpellbook.glyphBtn = nil
            fmSpellbook.glyphSlot = nil
            fmSpellbook.glyphIndex = nil
            btn:SetAttribute("type1", nil)

            if (fmSpellbook.glyphReason == "ACTIVATE_GLYPH") then
                btn.GlyphActivate:Show()
                btn.GlyphIcon:Show()
                btn.GlyphTranslation:Show()
                btn.GlyphActivateAnim:Play()
            end
        end
    end
end

local function CreatePassiveSpellButton(passiveGroup, passiveIndex, fmSpellbook, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)
    local btn = passiveGroup.pool:Acquire()
    local row = math.floor((passiveIndex - 1) / 5)
    local col = (passiveIndex - 1) % 5
    btn:SetPoint("TOPLEFT", passiveGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row))
    setPassiveButton(btn, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)

    -- check for should glyph highlight
    if spellBookTabs == 2 or spellBookTabs == 3 then
        checkForGlyph(btn, spellId, fmSpellbook)
    end

    return passiveIndex + 1
end

local function CreateActiveSpellButton(activeGroup, activeIndex, fmSpellbook, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)
    local btn
    if BOOKTYPE == BOOKTYPE_PET or skillType == "FLYOUT" then
        btn = activeGroup.poolNSD:Acquire()
    else
        btn = activeGroup.pool:Acquire()
    end
    local row = math.floor((activeIndex - 1) / 5)
    local col = (activeIndex - 1) % 5
    btn:SetPoint("TOPLEFT", activeGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row))
    setActiveButton(btn, spellId, skillType, icon, spellIndex, BOOKTYPE, name)

    -- check for should glyph highlight
    if spellBookTabs == 2 or spellBookTabs == 3 then
        checkForGlyph(btn, spellId, fmSpellbook)
        checkForClickBinding(btn, spellId, fmSpellbook)
    end
    GW.RegisterCooldown(btn.cooldown)

    return activeIndex + 1
end

local function updateRegTab(fmSpellbook, fmTab, spellBookTabs)
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(spellBookTabs)
    local btn
    local isPetTab = false
    local spellBank = Enum.SpellBookSpellBank.Player

    if spellBookTabs == 3 and (skillLineInfo.numSpellBookItems < 1 or C_SpecializationInfo.GetSpecialization() == 5) then
        fmTab.groups["active"]:Hide()
        fmTab.groups["passive"]:Hide()
        fmTab.groups["lock"]:Show()
    elseif spellBookTabs == 3 and (skillLineInfo.numSpellBookItems >= 1 or C_SpecializationInfo.GetSpecialization() < 5) then
        fmTab.groups["active"]:Show()
        fmTab.groups["passive"]:Show()
        fmTab.groups["lock"]:Hide()
    elseif spellBookTabs == 5 then
        isPetTab = true
        spellBank = Enum.SpellBookSpellBank.Pet
        skillLineInfo.numSpellBookItems = HasPetSpells()
        skillLineInfo.itemIndexOffset = 0
        if skillLineInfo.numSpellBookItems == nil then
            skillLineInfo.numSpellBookItems = 0
        end
        if skillLineInfo.numSpellBookItems == 0 then
            fmTab.groups["active"]:Hide()
            fmTab.groups["passive"]:Hide()
            fmTab.groups["lock"]:Show()
        else
            fmTab.groups["active"]:Show()
            fmTab.groups["passive"]:Show()
            fmTab.groups["lock"]:Hide()
        end
    end

    local activeIndex = 1
    local activeGroup = fmTab.groups["active"]
    local passiveIndex = 1
    local passiveGroup = fmTab.groups["passive"]

    activeGroup.pool:ReleaseAll()
    activeGroup.poolNSD:ReleaseAll()
    passiveGroup.pool:ReleaseAll()

    -- first add talent passives to not have spaces between
    local talentPassiveSkills = {}
    if not isPetTab then
        local configID = C_ClassTalents.GetActiveConfigID()
        if configID then
            local configInfo = C_Traits.GetConfigInfo(configID)
            if configInfo then

                for _, treeID in ipairs(configInfo.treeIDs) do -- in the context of talent trees, there is only 1 treeID
                    local talentTreeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, true)
                    local nodes = C_Traits.GetTreeNodes(treeID)
                    for _, nodeID in ipairs(nodes) do
                        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
                        local nodeCost = C_Traits.GetNodeCost(configID, nodeID)

                        if nodeCost and nodeCost[1] and ((spellBookTabs == 2 and nodeCost[1].ID == talentTreeCurrencyInfo[1].traitCurrencyID) or (spellBookTabs == 3 and nodeCost[1].ID == talentTreeCurrencyInfo[2].traitCurrencyID)) then
                            for _, entryID in ipairs(nodeInfo.entryIDs) do -- each node can have multiple entries (e.g. choice nodes have 2)
                                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                                if entryInfo and entryInfo.definitionID then
                                    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                                    if definitionInfo.spellID and GW.IsPlayerSpell(definitionInfo.spellID) and IsPassiveSpell(definitionInfo.spellID) then
                                        local spellInfo = C_Spell.GetSpellInfo(definitionInfo.spellID)
                                        local skillType = "TALENT"
                                        btn = passiveGroup.pool:Acquire()
                                        local row2 = math.floor((passiveIndex - 1) / 5)
                                        local col = (passiveIndex - 1) % 5
                                        btn:SetPoint("TOPLEFT", passiveGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row2))
                                        setPassiveButton(btn, definitionInfo.spellID, skillType, spellInfo.iconID, nil, spellBank, spellBookTabs, spellInfo.name)
                                        passiveIndex = passiveIndex + 1
                                        talentPassiveSkills[definitionInfo.spellID] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, skillLineInfo.numSpellBookItems do
        local spellIndex = i + skillLineInfo.itemIndexOffset
        local name, _ = C_SpellBook.GetSpellBookItemName(spellIndex, spellBank)
        if name == nil then
            name = ""
        end

        local spellInfo
        local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(spellIndex, spellBank)
        local icon = C_SpellBook.GetSpellBookItemTexture(spellIndex, Enum.SpellBookSpellBank.Player)

        if spellBookItemInfo.isPassive then
            if not talentPassiveSkills[spellInfo.spellID] then
                passiveIndex = CreatePassiveSpellButton(passiveGroup, passiveIndex, fmSpellbook, spellInfo.spellID, spellBookItemInfo.itemType, icon, spellIndex, spellBank, spellBookTabs, name)
            end
        else
            activeIndex = CreateActiveSpellButton(activeGroup, activeIndex, fmSpellbook, spellInfo.spellID, spellBookItemInfo.itemType, icon, spellIndex, spellBank, spellBookTabs, name)
        end
    end
    if spellBookTabs == 5 and C_SpecializationInfo.GetSpecialization(false, true) then
        -- add spec spells
        local bonuses = {GetSpecializationSpells(C_SpecializationInfo.GetSpecialization(false, true), nil, true)}
        for i = 1, #bonuses, 2 do
            if not GW.IsSpellKnownOrOverridesKnown(bonuses[i], true) then
                local isPassive = IsPassiveSpell(bonuses[i])
                local name, _, icon = C_Spell.GetSpellInfo(bonuses[i])

                if isPassive then
                    if not talentPassiveSkills[bonuses[i]] then
                        passiveIndex = CreatePassiveSpellButton(passiveGroup, passiveIndex, fmSpellbook, bonuses[i], "FUTURESPELL", icon, nil, spellBank, spellBookTabs, name)
                    end
                else
                    activeIndex = CreateActiveSpellButton(activeGroup, activeIndex, fmSpellbook, bonuses[i], "FUTURESPELL", icon, nil, spellBank, spellBookTabs, name)
                end
            end
        end
    end
    talentPassiveSkills = nil

    local offY = (math.ceil((activeIndex - 1) / 5) * 50) + 66
    passiveGroup:ClearAllPoints()
    passiveGroup:SetPoint("TOPLEFT", fmTab, "TOPLEFT", -4, -offY)
end


local function updateTab(fmSpellbook)
    if InCombatLockdown() then
        return
    end

    for tab = 1, 5 do
        local fmTab = fmSpellbook.tabContainers[tab]
        if tab == 4 then
            UpdatePvPTab(fmTab)
        else
            updateRegTab(fmSpellbook, fmTab, tab)
        end
    end
end


local function spellMenu_OnUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateTab(self)
    self.queuedUpdateTab = false
end


local function queueUpdateTab(fm)
    if fm.queuedUpdateTab then
        return
    end

    fm.queuedUpdateTab = true
    fm:SetScript("OnUpdate", spellMenu_OnUpdate)
end


local function talentFrame_OnUpdate(self)
    self:SetScript("OnUpdate", nil)
    self.queuedUpdateActiveSpec = false
end


local function queueUpdateActiveSpec(fm)
    if fm.queuedUpdateActiveSpec then
        return
    end

    fm.queuedUpdateActiveSpec = true
    fm:SetScript("OnUpdate", talentFrame_OnUpdate)
end


local function spellTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip_AddNormalLine(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end


local function activePoolCommon_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:Hide()
    btn.arrow:Hide()
    btn.autocast:Hide()
    btn:SetScript("OnEnter", spellButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnEvent", SpellButton_OnEvent) --spellButton_OnEvent??
    btn:SetAttribute("flyout", nil)
    btn:SetAttribute("flyoutDirection", nil)
    btn:SetAttribute("type1", nil)
    btn:SetAttribute("type2", nil)
    btn:SetAttribute("spell", nil)
    btn:SetAttribute("shift-type1", nil)
    btn:SetAttribute("shift-type2", nil)
    btn:SetAttribute("*macrotext2", nil)
    btn:SetAttribute("ispickable", nil)
    btn.GlyphApply = spellButton_GlyphApply
    btn.CustomClickCastClick = spellButton_ClickBindCast
    btn.isFuture = nil
    btn.spellbookIndex = nil
    btn.booktype = nil
    btn.spellId = nil
    btn.skillType = nil
    btn.isFlyout = nil
    btn.modifiedClick = TalProfButton_OnModifiedClick
    btn.canClickBind = false
end


local function activePool_Resetter(self, btn)
    activePoolCommon_Resetter(self, btn)
    btn:SetAttribute("_ondragstart", spellButtonSecure_OnDragStart)
end


local function activePoolNSD_Resetter(self, btn)
    activePoolCommon_Resetter(self, btn)
    btn:SetScript("OnDragStart", spellButton_OnDragStart)
end


local function passivePool_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:Hide()
    btn:SetScript("OnEnter", spellButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetAttribute("shift-type1", nil)
    btn:SetAttribute("shift-type2", nil)
    btn.GlyphApply = spellButton_GlyphApply
    btn.isFuture = nil
    btn.spellbookIndex = nil
    btn.booktype = nil
    btn.spellId = nil
    btn.skillType = nil
    btn.modifiedClick = TalProfButton_OnModifiedClick

    if not btn.mask then
        btn.mask = UIParent:CreateMaskTexture()
        btn.mask:SetPoint("CENTER", btn.icon, "CENTER", 0, 0)
        btn.mask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/talents/passive_border.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.mask:SetSize(40, 40)
        btn.icon:AddMaskTexture(btn.mask)
    end
end


local function updateButton(self)
    if self.spellbookIndex and self.booktype then
        local spellCooldownInfo = GW.GetSpellCooldown(self.spellbookIndex, self.booktype)

        if spellCooldownInfo.startTime ~= nil and spellCooldownInfo.duration ~= nil then
            self.cooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration)
        end

        local _, autostate = GetSpellAutocast(self.spellbookIndex, self.booktype)

        self.autocast:SetShown(autostate)
    end
end


local function spellGroup_OnEvent(self)
    if not GwSpellbookFrame:IsShown() or not self.pool or not self.poolNSD or not GW.inWorld then
        return
    end

    for btn in self.pool:EnumerateActive() do
        updateButton(btn)
    end
    for btn in self.poolNSD:EnumerateActive() do
        updateButton(btn)
    end
end


local function toggleSpellBook(bookType)
    if InCombatLockdown() then
        return
    end
    if bookType == BOOKTYPE_PROFESSION then
        GwCharacterWindow:SetAttribute("windowpanelopen", "professions")
    elseif bookType == BOOKTYPE_PET then
        GwCharacterWindow:SetAttribute("windowpanelopen", "petbook")
    else
        -- BOOKTYPE_SPELL or any other type
        GwCharacterWindow:SetAttribute("windowpanelopen", "spellbook")
    end
end


local function spellBook_OnEvent(self, event, ...)
    if IsIn(event, "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB", "PLAYER_GUILD_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_LEVEL_UP", "") then
        if not GwSpellbookFrame:IsShown() or not GW.inWorld then
            return
        end
        queueUpdateTab(self)
    elseif IsIn(event, "USE_GLYPH", "ACTIVATE_GLYPH") then
        -- open and highlight glyphable spell
        local slot = ...
        GW.Debug("in event", event, slot, IsPendingGlyphRemoval())
        GwCharacterWindow:SetAttribute("windowpanelopen", "spellbook")
        if IsPendingGlyphRemoval() then
            self.glyphSlot = -1 -- highlight/cancel all
        else
            self.glyphSlot = slot
        end
        if event == "ACTIVATE_GLYPH" then
            self.glyphCasting = true
        else
            self.glyphCasting = nil
        end
        self.glyphReason = event
        queueUpdateTab(self) -- if already open OnShow won't fire again so queue here to be sure
    elseif event == "CANCEL_GLYPH_CAST" then
        -- dehiglight glyphable spell
        GW.Debug("in event", event)
        if self.glyphBtn then
            self.glyphBtn.AbilityHighlightAnim:Stop()
            self.glyphBtn.AbilityHighlight:Hide()
            self.glyphBtn:SetAttribute("type1", nil)
            self.glyphBtn = nil
        end
        if self.glyphSlot == -1 then
            queueUpdateTab(self)
        end
        self.glyphSlot = nil
        self.glyphReason = nil
    elseif event == "CURRENT_SPELL_CAST_CHANGED" then
        if self.glyphCasting and not IsCastingGlyph() then
            self.glyphBtn = nil
            self.glyphSlot = nil
            self.glyphReason = nil
            self.glyphCasting = nil
            queueUpdateTab(self)
        end
    end
end


local function createRegTab(fmSpellbook, tab)
    local container = CreateFrame("Frame", nil, fmSpellbook, "GwSpellbookContainerTab")
    local actGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    local psvGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    container.groups = {
        ["active"] = actGroup,
        ["passive"] = psvGroup
    }

    actGroup:ClearAllPoints()
    actGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -31)
    actGroup.label.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    actGroup.label.title:SetTextColor(1, 1, 1, 1)
    actGroup.label.title:SetShadowColor(0, 0, 0, 1)
    actGroup.label.title:SetShadowOffset(1, -1)
    actGroup.label.title:SetText(ACTIVE_PETS)
    actGroup.pool = CreateFramePool("Button", actGroup, "GwSpellbookActiveButton", activePool_Resetter)
    actGroup.poolNSD = CreateFramePool("Button", actGroup, "GwSpellbookActiveButtonNSD", activePoolNSD_Resetter)
    actGroup:SetScript("OnEvent", spellGroup_OnEvent)
    actGroup:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    actGroup:RegisterEvent("PET_BAR_UPDATE")

    psvGroup:ClearAllPoints()
    psvGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -72)
    psvGroup.label.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    psvGroup.label.title:SetTextColor(1, 1, 1, 1)
    psvGroup.label.title:SetShadowColor(0, 0, 0, 1)
    psvGroup.label.title:SetShadowOffset(1, -1)
    psvGroup.label.title:SetText(SPELL_PASSIVE)
    psvGroup.pool = CreateFramePool("Button", psvGroup, "GwSpellbookPassiveButton", passivePool_Resetter)

    if tab == 3 or tab == 5 then
        local lockGroup = CreateFrame("Frame", nil, container, "GwSpellbookLockGroup")
        container.groups["lock"] = lockGroup
        lockGroup:ClearAllPoints()
        lockGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -31)
        lockGroup.info:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        lockGroup.info:SetTextColor(1, 1, 1, 1)
        lockGroup.info:SetShadowColor(0, 0, 0, 1)
        lockGroup.info:SetShadowOffset(1, -1)
        lockGroup.info:SetText(tab == 3 and format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10) or SPELL_FAILED_NO_PET)
    end

    return container
end


local function LoadSpellbook(tabContainer)
    local fmGTF = CreateFrame("Frame", "GwSpellbookFrame", tabContainer, "SecureHandlerStateTemplate,GwSpellbookFrame")

    local fmSpellbook = CreateFrame("Frame", "GwSpellbookMenu", GwSpellbookFrame, "GwSpellbookMenu")
    -- TODO: change this to do all attribute stuff on container instead of menu
    GwCharacterWindow:SetFrameRef("GwSpellbookMenu", fmSpellbook)

    fmSpellbook.tabContainers = {}
    fmSpellbook.queuedUpdateTab = false
    fmSpellbook:SetScript("OnEvent", spellBook_OnEvent)
    fmSpellbook:RegisterEvent("SPELLS_CHANGED")
    fmSpellbook:RegisterEvent("LEARNED_SPELL_IN_TAB")
    fmSpellbook:RegisterEvent("PLAYER_GUILD_UPDATE")
    fmSpellbook:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    fmSpellbook:RegisterEvent("USE_GLYPH")
    fmSpellbook:RegisterEvent("CANCEL_GLYPH_CAST")
    fmSpellbook:RegisterEvent("ACTIVATE_GLYPH")
    fmSpellbook:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
    fmSpellbook:RegisterEvent("PLAYER_LEVEL_UP")
    SpellBookFrame:UnregisterAllEvents()
    SpellBookFrame:HookScript("OnShow", function() HideUIPanel(SpellBookFrame) end)

    for tab = 1, 5 do
        if tab == 4 then
            fmSpellbook.tabContainers[tab] = CreatePvPTab(fmSpellbook)
        else
            fmSpellbook.tabContainers[tab] = createRegTab(fmSpellbook, tab)
        end
        fmSpellbook:SetFrameRef("GwSpellbookContainerTab" .. tab, fmSpellbook.tabContainers[tab])
    end

    fmSpellbook.tabContainers[2]:Show()


    GW.LoadSpecializations(fmGTF)
    updateTab(fmSpellbook)

    fmSpellbook.tab1:RegisterForClicks("AnyUp")
    fmSpellbook.tab1:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab1:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',1)
        ]=]
    )
    fmSpellbook.tab2:RegisterForClicks("AnyUp")
    fmSpellbook.tab2:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab2:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
        ]=]
    )
    fmSpellbook.tab3:RegisterForClicks("AnyUp")
    fmSpellbook.tab3:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab3:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',3)
        ]=]
    )
    fmSpellbook.tab4:RegisterForClicks("AnyUp")
    fmSpellbook.tab4:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab4:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',4)
        ]=]
    )
    fmSpellbook.tab5:RegisterForClicks("AnyUp")
    fmSpellbook.tab5:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab5:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',5)
        ]=]
    )

    fmSpellbook:SetFrameRef("GwspellbookTab1", fmSpellbook.tab1)
    fmSpellbook:SetFrameRef("GwspellbookTab2", fmSpellbook.tab2)
    fmSpellbook:SetFrameRef("GwspellbookTab3", fmSpellbook.tab3)
    fmSpellbook:SetFrameRef("GwspellbookTab4", fmSpellbook.tab4)
    fmSpellbook:SetFrameRef("GwspellbookTab5", fmSpellbook.tab5)
    fmSpellbook.UnselectAllTabs = function()
        fmSpellbook.tab1.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive.png")
        fmSpellbook.tab2.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive.png")
        fmSpellbook.tab3.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive.png")
        fmSpellbook.tab4.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive.png")
        fmSpellbook.tab5.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive.png")
    end
    fmSpellbook.SelectTab = function(_, tab)
        local frame
        if tab == 1 then
            frame = fmSpellbook.tab1
        elseif tab == 2 then
            frame = fmSpellbook.tab2
        elseif tab == 3 then
            frame = fmSpellbook.tab3
        elseif tab == 4 then
            frame = fmSpellbook.tab4
        elseif tab == 5 then
            frame = fmSpellbook.tab5
        end
        frame.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg.png")
    end
    fmSpellbook:SetAttribute(
        "_onattributechanged",
        [=[
            if name ~= 'tabopen' then return end

            self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab4'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab5'):Hide()
            self:CallMethod("UnselectAllTabs")
        
            if value == 1 then
                self:GetFrameRef('GwSpellbookContainerTab1'):Show()
                self:CallMethod("SelectTab", 1)
                return
            elseif value == 2 then
                self:GetFrameRef('GwSpellbookContainerTab2'):Show()
                self:CallMethod("SelectTab", 2)
                return
            elseif value == 3 then
                self:GetFrameRef('GwSpellbookContainerTab3'):Show()
                self:CallMethod("SelectTab", 3)
                return
            elseif value == 4 then
                self:GetFrameRef('GwSpellbookContainerTab4'):Show()
                self:CallMethod("SelectTab", 4)
                return
            elseif value == 5 then
                self:GetFrameRef('GwSpellbookContainerTab5'):Show()
                self:CallMethod("SelectTab", 5)
                return
            end
        ]=]
    )
    fmSpellbook:SetAttribute("tabOpen", 2)

    local _, specName = C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
    fmSpellbook.tab1.gwTipLabel = GENERAL_SPELLS
    fmSpellbook.tab2.gwTipLabel = GW.myLocalizedClass
    fmSpellbook.tab3.gwTipLabel = specName
    fmSpellbook.tab4.gwTipLabel = PVP_LABEL_PVP_TALENTS
    fmSpellbook.tab5.gwTipLabel = PET

    fmSpellbook.tab1:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab1:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab2:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab2:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab3:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab3:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab4:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab4:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab5:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab5:SetScript("OnLeave", GameTooltip_Hide)

    -- set tab 2/3 to class/spec icon
    SetClassIcon(fmSpellbook.tab2.icon, GW.myClassID)
    setSpecTabIconAndTooltip(fmSpellbook.tab3)

    GwSpellbookFrame:HookScript(
        "OnShow",
        function()
            if InCombatLockdown() then
                return
            end
            updateTab(fmSpellbook)
        end
    )

    -- TODO: not sure if we want these or not
    hooksecurefunc("ToggleSpellBook", toggleSpellBook)

    return GwSpellbookFrame
end
GW.LoadSpellbook = LoadSpellbook
