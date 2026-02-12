local _, GW = ...

local function spellButton_OnEnter(self)
    if not self.isPickable then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    GameTooltip:SetPvpTalent(self.talentId, true)

    if self.isFuture then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(UNLOCKS_AT_LEVEL:format(self.unlockLevel), 1, 1, 1)
    elseif self:GetParent():GetParent().pickingSlot then
        GameTooltip:AddLine(PVP_TALENT_SLOT_EMPTY, GREEN_FONT_COLOR:GetRGB())
    end
    GameTooltip:Show()
end


local function slotButton_OnDragStart(self)
    if InCombatLockdown() or self.isFuture or self.isPassive then
        return
    end
    PickupPvpTalent(self.talentId)
end


local function slotButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    if not self.isEnabled then
        GameTooltip:SetText(PVP_TALENT_SLOT)
        GameTooltip:AddLine(PVP_TALENT_SLOT_LOCKED:format(self.unlockLevel), RED_FONT_COLOR:GetRGB())
    elseif not self.talentId then
        GameTooltip:SetText(PVP_TALENT_SLOT)
        GameTooltip:AddLine(PVP_TALENT_SLOT_EMPTY, GREEN_FONT_COLOR:GetRGB())
    else
        GameTooltip:SetPvpTalent(self.talentId, false, C_SpecializationInfo.GetActiveSpecGroup(true), self.slotIndex)
        if not self:GetParent():GetParent().pickingSlot then
            GameTooltip:AddLine(PVP_TALENT_SLOT_EMPTY, GREEN_FONT_COLOR:GetRGB())
        end
    end
    GameTooltip:Show()
end


local function updateButton(btn, slotInfo, selectedTalents)
    local btnAvail = true
    local tid = btn.talentId
    if slotInfo and (not tContains(slotInfo.availableTalentIDs, tid) or tContains(selectedTalents, tid)) then
        btnAvail = false
    end
    if btnAvail then
        if btn.isFuture then
            btn.highlight:Show()
            btn.icon:SetAlpha(0.5)
            btn.icon:SetDesaturated(true)
            if btn:GetParent():GetParent().pickingSlot then
                btn.isPickable = false
            else
                btn.isPickable = true
            end
        else
            btn.highlight:Show()
            btn.icon:SetAlpha(1)
            btn.icon:SetDesaturated(false)
            btn.isPickable = true
        end
    else
        btn.highlight:Hide()
        btn.icon:SetAlpha(0.2)
        btn.icon:SetDesaturated(true)
        btn.isPickable = false
    end
end


local function updatePicks(self)
    local fmTab = self:GetParent()
    local pickingSlot = fmTab.pickingSlot
    local slotInfo
    for slot in self.pool:EnumerateActive() do
        if slot.isEnabled then
            if slot.slotIndex ~= pickingSlot then
                slot.AbilityHighlightAnim:Stop()
                slot.AbilityHighlight:Hide()
            else
                slot.AbilityHighlight:Show()
                slot.AbilityHighlightAnim:Play()
            end

            slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slot.slotIndex)
            if slotInfo and slotInfo.selectedTalentID then
                slot.talentId = slotInfo.selectedTalentID
                local _, _, icon, _, _, spellId, _ = GetPvpTalentInfoByID(slot.talentId)
                local isPassive = IsPassiveSpell(spellId)
                slot.icon:SetTexture(icon)
                if isPassive then
                    slot.icon:AddMaskTexture(slot.mask)
                    slot.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png")
                    slot.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_outline.png")
                else
                    slot.icon:RemoveMaskTexture(slot.mask)
                    slot.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight.png")
                    slot.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border.png")
                end
            else
                slot.talentId = nil
                slot.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/pvp_empty_icon.png")
                slot.icon:RemoveMaskTexture(slot.mask)
                slot.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight.png")
                slot.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border.png")
            end
        end
    end

    if pickingSlot then
        slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(pickingSlot)
    else
        slotInfo = nil
    end
    local selectedTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()

    for btn in fmTab.groups["active"].pool:EnumerateActive() do
        updateButton(btn, slotInfo, selectedTalents)
    end

    for btn in fmTab.groups["passive"].pool:EnumerateActive() do
        updateButton(btn, slotInfo, selectedTalents)
    end
end


local function button_OnModifiedClick(self)
    local tid = self.talentId
    if not tid then
        return
    end
    local isPassive
    local _, name, _, _, _, sid, _ = GetPvpTalentInfoByID(tid)
    if sid then
        isPassive = IsPassiveSpell(sid)
    end
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            if name and not isPassive then
                ChatFrameUtil.InsertLink(name)
            end
        else
            local link = GetPvpTalentLink(tid)
            ChatFrameUtil.InsertLink(link)
        end
    elseif IsModifiedClick("PICKUPACTION") and not InCombatLockdown() and not isPassive then
        PickupPvpTalent(tid)
    end
end


local function spellButton_OnClick(self)
    if IsModifiedClick() then
        return button_OnModifiedClick(self)
    end

    local tid = self.talentId
    local fmSlots = self:GetParent()
    local fmTab = fmSlots:GetParent()
    local pickingSlot = fmTab.pickingSlot
    if not self.isPickable or not pickingSlot or not tid then
        return
    end

    -- pick this talent for the picking slot
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(ERR_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        LearnPvpTalent(tid, pickingSlot)
    end
    fmTab.pickingSlot = nil
    updatePicks(fmSlots)
end


local function slotButton_OnClick(self)
    if not self.isEnabled then
        return
    end
    if IsModifiedClick() then
        return button_OnModifiedClick(self)
    end

    local fmSlots = self:GetParent()
    local fmTab = fmSlots:GetParent()
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(ERR_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
        fmTab.pickingSlot = nil
    else
        if fmTab.pickingSlot == self.slotIndex then
            fmTab.pickingSlot = nil
        else
            fmTab.pickingSlot = self.slotIndex
        end
    end
    updatePicks(fmSlots)
end


local function setSlotButton(btn, info)
    btn:EnableMouse(true)
    btn:SetAlpha(1)
    btn:Show()

    if not btn.slotIndex then
        return
    end
    
    local slotIndex = btn.slotIndex
    local unlock = C_SpecializationInfo.GetPvpTalentSlotUnlockLevel(slotIndex)
    if info.enabled and GW.mylevel >= unlock then
        btn.isEnabled = true
    else
        btn.isEnabled = false
    end
    btn.unlockLevel = unlock
    btn.talentId = info.selectedTalentID

    if btn.isEnabled then
        btn.highlight:SetAlpha(1)
        btn.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border.png")
        btn.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/pvp_empty_icon.png")
        btn.outline:SetSize(50, 50)
    else
        btn.highlight:SetAlpha(0)
        btn.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/lock.png")
        btn.icon:SetTexture(nil)
        btn.outline:SetSize(40, 40)
    end
end


local talentIds = {}
local function UpdatePvPTab(fmTab)
    if not C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
        for _, v in pairs(fmTab.groups) do
            v:Hide()
        end
        fmTab.groups["lock"]:Show()
        return
    else
        for _, v in pairs(fmTab.groups) do
            v:Show()
        end
        fmTab.groups["lock"]:Hide()
    end

    local activeIndex = 1
    local activeGroup = fmTab.groups["active"]
    local passiveIndex = 1
    local passiveGroup = fmTab.groups["passive"]
    local slotGroup = fmTab.groups["slots"]

    activeGroup.pool:ReleaseAll()
    passiveGroup.pool:ReleaseAll()
    slotGroup.pool:ReleaseAll()

    wipe(talentIds)
    local tidx = 1
    for i, _ in ipairs({"TalentSlot1", "TalentSlot2", "TalentSlot3"}) do
        local btn = slotGroup.pool:Acquire()
        local row = 0
        local col = (i - 1) % 3

        btn.slotIndex = i
        local info = C_SpecializationInfo.GetPvpTalentSlotInfo(i)
        if info then
            setSlotButton(btn, info)
            btn:SetPoint("TOPLEFT", slotGroup, "TOPLEFT", 55 + (50 * col), -37 + (-50 * row))

            for _, talentId in ipairs(info.availableTalentIDs) do
                if not tContains(talentIds, talentId) then
                    talentIds[tidx] = talentId
                    tidx = tidx + 1
                end
            end
        end
    end

    table.sort(
        talentIds,
        function(left, right)
            local llvl = C_SpecializationInfo.GetPvpTalentUnlockLevel(left)
            local rlvl = C_SpecializationInfo.GetPvpTalentUnlockLevel(right)
            if (not llvl and not rlvl) or (llvl == rlvl) then
                return left < right
            else
                return llvl < rlvl
            end
        end
    )

    for _, talentId in ipairs(talentIds) do
        local _, _, icon, _, _, spellId, _ = GetPvpTalentInfoByID(talentId)
        local isPassive = IsPassiveSpell(spellId)
        local btn
        if isPassive then
            btn = passiveGroup.pool:Acquire()
            local row = math.floor((passiveIndex - 1) / 5)
            local col = (passiveIndex - 1) % 5
            btn:SetPoint("TOPLEFT", passiveGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row))
            passiveIndex = passiveIndex + 1
        else
            btn = activeGroup.pool:Acquire()
            local row = math.floor((activeIndex - 1) / 5)
            local col = (activeIndex - 1) % 5
            btn:SetPoint("TOPLEFT", activeGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row))
            activeIndex = activeIndex + 1
        end
        btn.icon:SetTexture(icon)
        btn:Show()
        btn:SetAlpha(1)
        btn.spellId = spellId
        btn.talentId = talentId
        btn.isPickable = true
        btn.unlockLevel = C_SpecializationInfo.GetPvpTalentUnlockLevel(talentId)
        if GW.mylevel < btn.unlockLevel then
            btn.isFuture = true
            btn.icon:SetDesaturated(true)
            btn.icon:SetAlpha(0.5)
        else
            btn.isFuture = false
            btn.icon:SetDesaturated(false)
            btn.icon:SetAlpha(1)
        end
    end

    local offY = (math.ceil((activeIndex - 1) / 5) * 50) + 255
    passiveGroup:ClearAllPoints()
    passiveGroup:SetPoint("TOPLEFT", fmTab, "TOPLEFT", -4, -offY)

    fmTab.pickingSlot = nil
    updatePicks(slotGroup)
end
GW.UpdatePvPTab = UpdatePvPTab

local function slotPool_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:Hide()
    btn:SetScript("OnEnter", slotButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnClick", slotButton_OnClick)
    btn:SetScript("OnDragStart", slotButton_OnDragStart)
    btn.isEnabled = nil
    btn.unlockLevel = nil
    btn.isFuture = nil
    btn.talentId = nil
    btn.spellId = nil
    btn.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/pvp_empty_icon.png")

    if not btn.mask then
        btn.mask = UIParent:CreateMaskTexture()
        btn.mask:SetPoint("CENTER", btn.icon, "CENTER", 0, 0)
        btn.mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.mask:SetSize(40, 40)
    end
end


local function activePool_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:Hide()
    btn:SetScript("OnEnter", spellButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnClick", spellButton_OnClick)
    btn.isPickable = nil
    btn.isFuture = nil
    btn.spellId = nil
    btn.talentId = nil
    btn.icon:SetTexture(nil)
end


local function passivePool_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:Hide()
    btn:SetScript("OnEnter", spellButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnClick", spellButton_OnClick)
    btn.isPickable = nil
    btn.isFuture = nil
    btn.spellId = nil
    btn.talentId = nil
    btn.icon:SetTexture(nil)

    if not btn.mask then
        btn.mask = UIParent:CreateMaskTexture()
        btn.mask:SetPoint("CENTER", btn.icon, "CENTER", 0, 0)
        btn.mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.mask:SetSize(40, 40)
        btn.icon:AddMaskTexture(btn.mask)
    end
end


local function toggle_OnShow(self)
    self:RegisterEvent("PLAYER_FLAGS_CHANGED")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end


local function toggle_OnHide(self)
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:UnregisterEvent("ZONE_CHANGED")
end


local function toggle_OnClick(self)
    if (C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired())) then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        local warmodeEnabled = C_PvP.IsWarModeDesired()

        if (warmodeEnabled) then
            PlaySound(SOUNDKIT.UI_WARMODE_DECTIVATE)
            self.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/warmode_off.png")
        else
            PlaySound(SOUNDKIT.UI_WARMODE_ACTIVATE)
            self.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/warmode_on.png")
        end
        C_PvP.ToggleWarMode()
    end
end


local function toggle_OnEnter(self)
    local canToggleWarmodeOFF = C_PvP.CanToggleWarMode(false)
    local canToggleWarmodeON = C_PvP.CanToggleWarMode(true)
    
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(PVP_LABEL_WAR_MODE, 1, 1, 1)
    if (C_PvP.IsWarModeDesired()) then
        local r, g, b = GREEN_FONT_COLOR:GetRGB()
        GameTooltip:AddLine(PVP_WAR_MODE_ENABLED, r, g, b, true)
    end
    GameTooltip:AddLine(PVP_WAR_MODE_DESCRIPTION, nil, nil, nil, true)
    if ((not canToggleWarmodeOFF and not C_PvP.IsWarModeDesired()) or (canToggleWarmodeON or C_PvP.IsWarModeDesired())) == false then
        local text =
            GW.myfaction == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or
            PVP_WAR_MODE_NOT_NOW_ALLIANCE
        local r, g, b = RED_FONT_COLOR:GetRGB()
        GameTooltip:AddLine(text, r, g, b, true)
    end
    GameTooltip:Show()
end


local function CreatePvPTab(fmSpellbook)
    local container = CreateFrame("Frame", nil, fmSpellbook, "GwSpellbookContainerTab")
    local lockGroup = CreateFrame("Frame", nil, container, "GwSpellbookLockGroup")
    local warGroup = CreateFrame("Frame", nil, container, "GwSpellbookWMGroup")
    local slotGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    local actGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    local psvGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    container.groups = {
        ["lock"] = lockGroup,
        ["warmode"] = warGroup,
        ["slots"] = slotGroup,
        ["active"] = actGroup,
        ["passive"] = psvGroup
    }

    lockGroup:ClearAllPoints()
    lockGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -31)
    lockGroup.info:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    lockGroup.info:SetTextColor(1, 1, 1, 1)
    lockGroup.info:SetShadowColor(0, 0, 0, 1)
    lockGroup.info:SetShadowOffset(1, -1)
    lockGroup.info:SetText(select(2, C_SpecializationInfo.CanPlayerUsePVPTalentUI()))

    warGroup:ClearAllPoints()
    warGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -31)
    warGroup.label.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    warGroup.label.title:SetTextColor(1, 1, 1, 1)
    warGroup.label.title:SetShadowColor(0, 0, 0, 1)
    warGroup.label.title:SetShadowOffset(1, -1)
    warGroup.label.title:SetText(PVP_LABEL_WAR_MODE)

    warGroup.toggle:SetScript("OnEnter", toggle_OnEnter)
    warGroup.toggle:SetScript("OnLeave", GameTooltip_Hide)
    warGroup.toggle:SetScript("OnShow", toggle_OnShow)
    warGroup.toggle:SetScript("OnHide", toggle_OnHide)
    warGroup.toggle:SetScript("OnClick", toggle_OnClick)
    warGroup.toggle:SetEnabled(true)
    if C_PvP.IsWarModeDesired() then
        warGroup.toggle.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/warmode_on.png")
    end

    slotGroup:ClearAllPoints()
    slotGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -135)
    slotGroup.label.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    slotGroup.label.title:SetTextColor(1, 1, 1, 1)
    slotGroup.label.title:SetShadowColor(0, 0, 0, 1)
    slotGroup.label.title:SetShadowOffset(1, -1)
    slotGroup.label.title:SetText(PVP_TALENTS)
    slotGroup.pool = CreateFramePool("Button", slotGroup, "GwSpellbookSlotButtonPvP", slotPool_Resetter)
    slotGroup:SetScript(
        "OnShow",
        function(self)
            self:GetParent().pickingSlot = nil
            updatePicks(self)
        end
    )

    actGroup:ClearAllPoints()
    actGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -220)
    actGroup.label.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    actGroup.label.title:SetTextColor(1, 1, 1, 1)
    actGroup.label.title:SetShadowColor(0, 0, 0, 1)
    actGroup.label.title:SetShadowOffset(1, -1)
    actGroup.label.title:SetText(ACTIVE_PETS)
    actGroup.pool = CreateFramePool("Button", actGroup, "GwSpellbookActiveButtonPvP", activePool_Resetter)

    psvGroup:ClearAllPoints()
    psvGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -255)
    psvGroup.label.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    psvGroup.label.title:SetTextColor(1, 1, 1, 1)
    psvGroup.label.title:SetShadowColor(0, 0, 0, 1)
    psvGroup.label.title:SetShadowOffset(1, -1)
    psvGroup.label.title:SetText(SPELL_PASSIVE)
    psvGroup.pool = CreateFramePool("Button", psvGroup, "GwSpellbookPassiveButtonPvP", passivePool_Resetter)

    return container
end
GW.CreatePvPTab = CreatePvPTab
