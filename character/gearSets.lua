local _, GW = ...

local function UpdateSets(self)
    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    local buttons = self.buttons

    local selectedName = self.selectedSetName
    local name, texture, button, isEquipped, zebra
    self.selectedSet = nil

    for ite, i in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do
        name, texture, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(i)
        button = buttons[ite]
        button:Enable()
        button.name = name
        button.id = i --EquipmentSetID
        button.title:SetText(name);
        if texture then
            button.icon:SetTexture(texture)
        else
            button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        if selectedName and button.name == selectedName then
            self.selectedSet = button
        end

        zebra = i % 2
        if selectedName and button.name == selectedName then
            button.zebra:SetVertexColor(1, 1, 0.5, 0.15)
        else
            button.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
        end

        button.background:SetShown(isEquipped)
        button:Show()
    end

    if self.selectedSet then
        self.delete:Enable()
        self.equipe:Enable()
    else
        self.delete:Disable()
        self.equipe:Disable()
    end

    for i = numSets + 1, MAX_EQUIPMENT_SETS_PER_PLAYER do
        button = buttons[i]
        button:Disable()
        button.name = nil
        button.title:SetText("")
        button.icon:SetTexture("")
        button:Hide()
    end
    if GearManagerDialogPopup and GearManagerDialogPopup:IsShown() then
        RecalculateGearManagerDialogPopup()		--Scroll so that the texture appears and Save is enabled
    end
end

local function GeatSetButtonOnClick(self)
    local parent = self:GetParent()
    if self.name and self.name ~= "" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)		-- inappropriately named, but a good sound.
        parent.selectedSetName = self.name
        parent.selectedSetIcon = self.icon:GetTexture();	-- IconID, not index
        UpdateSets(parent)  					--change selection, enable one equip button, disable rest.
    else
        parent.selectedSetName = nil
        parent.selectedSetIcon = nil
    end
end

local function LoadGeatSets()
    local gearSetsFrame = CreateFrame("Frame", "GwPaperGearSets", GwCharacterWindowContainer, "GwPaperGearSets")
    local button
    local yPadding = 0

    gearSetsFrame.buttons = {}

    for i = 1, MAX_EQUIPMENT_SETS_PER_PLAYER do
        button = CreateFrame("Button", "GwGearSetButton" .. i, gearSetsFrame, "GwGearSetsButtonTemplate")
        button:SetParent(gearSetsFrame)
        button:SetPoint('TOPLEFT', gearSetsFrame, 'TOPLEFT', 0, yPadding)
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
        button:HookScript("OnClick", GeatSetButtonOnClick)

        button.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
        button.title:SetTextColor(0.7, 0.7, 0.5, 1)
        button.title:SetText("")
        button.bg:SetVertexColor(1, 1, 1, 1)
        button.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        button:ClearNormalTexture()
        button:SetText("")

        yPadding = -44 * i

        tinsert(gearSetsFrame.buttons, button)
    end

    gearSetsFrame:RegisterEvent("VARIABLES_LOADED")
    gearSetsFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
    gearSetsFrame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
    C_EquipmentSet.ClearIgnoredSlotsForSave()
    UpdateSets(gearSetsFrame)

    gearSetsFrame:HookScript("OnShow", function()
        if InCombatLockdown() then
            gearSetsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end
        UpdateSets(gearSetsFrame)
    end)

    gearSetsFrame:SetScript("OnEvent", function(_, event)
        if InCombatLockdown() then
            gearSetsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        UpdateSets(gearSetsFrame)

        if event == "PLAYER_REGEN_ENABLED" then
            gearSetsFrame:UnregisterEvent(event)
        end
    end)

    --[[
    GearManagerDialogPopup:HookScript("OnShow", function()
        GearManagerDialogPopup:ClearAllPoints()
        GearManagerDialogPopup:SetPoint("TOPLEFT", GwCharacterWindowContainer, "TOPRIGHT", 0, 0)
        gearSetsFrame.save:Disable()

    end)

    GearManagerDialogPopup:HookScript("OnHide", function()
        gearSetsFrame.save:Enable()
        UpdateSets(gearSetsFrame)
    end)

    hooksecurefunc("GearManagagerDialogPopup_AdjustAnchors", function()
        GearManagerDialogPopup:ClearAllPoints()
        GearManagerDialogPopup:SetPoint("TOPLEFT", GwCharacterWindowContainer, "TOPRIGHT", 0, 0)
    end)


    GearManagerDialogPopup:SetParent(GwCharacterWindowContainer)

    
    hooksecurefunc("RecalculateGearManagerDialogPopup", function()
        if gearSetsFrame.selectedSet then
            GearManagerDialogPopupEditBox:SetText(gearSetsFrame.selectedSet.name)
            GearManagerDialog.selectedSet = gearSetsFrame.selectedSet
        end
    end)

    ]]
    hooksecurefunc(C_EquipmentSet, "DeleteEquipmentSet", function() UpdateSets(gearSetsFrame) end)
    gearSetsFrame.delete:SetScript("OnClick", function()
        local selectedSet = gearSetsFrame.selectedSet;
        if selectedSet then
            local dialog = StaticPopup_Show("CONFIRM_DELETE_EQUIPMENT_SET", selectedSet.name)
            if dialog then
                dialog.data = selectedSet.id
                C_Timer.After(0.5, function() UpdateSets(gearSetsFrame) end)
            else
                UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
            end
        end
    end)
    gearSetsFrame.equipe:SetScript("OnClick", function()
        local selectedSet = gearSetsFrame.selectedSet
        if selectedSet then
            local name = selectedSet.id
            if (name) then
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)	-- inappropriately named, but a good sound.
                EquipmentManager_EquipSet(name)
                C_Timer.After(0.5, function() UpdateSets(gearSetsFrame) end)
            end
        end
    end)
    gearSetsFrame.save:SetScript("OnClick", function()
        local popup = GearManagerDialogPopup
        local wasShown = popup:IsShown()
        popup:Show()
        if wasShown then	--If the dialog was already shown, the OnShow script will not run and the icon will not be updated (Bug 169523)
            GearManagerDialogPopup_Update()
        end
    end)
end
GW.LoadGeatSets = LoadGeatSets