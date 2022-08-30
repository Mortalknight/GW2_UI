local _, GW = ...

local function UpdateSets()
    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    local dialog = GwPaperGearSets
	local buttons = dialog.buttons

    local selectedName = dialog.selectedSetName
    local name, texture, button, zebra
	dialog.selectedSet = nil

    for i = 0, numSets do
		name, texture = C_EquipmentSet.GetEquipmentSetInfo(i)
		button = buttons[i + 1]
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
			dialog.selectedSet = button
		end

        zebra = i % 2
        if selectedName and button.name == selectedName then
            button.zebra:SetVertexColor(1, 1, 0.5, 0.15)
        else
            button.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
        end
        button:Show()
	end

    if dialog.selectedSet then
		GwPaperGearSets.delete:Enable()
		GwPaperGearSets.equipe:Enable()
	else
		GwPaperGearSets.delete:Disable()
		GwPaperGearSets.equipe:Disable()
	end

    for i = numSets + 1, MAX_EQUIPMENT_SETS_PER_PLAYER do
		button = buttons[i]
		button:Disable()
		button.name = nil
		button.title:SetText("")
		button.icon:SetTexture("")
        button:Hide()
	end
    if(GearManagerDialogPopup:IsShown()) then
		--RecalculateGearManagerDialogPopup();		--Scroll so that the texture appears and Save is enabled
	end

end

local function GeatSetButtonOnClick(self)
    if self.name and self.name ~= "" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)		-- inappropriately named, but a good sound.
		GwPaperGearSets.selectedSetName = self.name
		GwPaperGearSets.selectedSetIcon = self.icon:GetTexture();	-- IconID, not index
		UpdateSets()  					--change selection, enable one equip button, disable rest.
	else
		GwPaperGearSets.selectedSetName = nil
		GwPaperGearSets.selectedSetIcon = nil
	end
end

local function LoadGeatSets()
    local gearSetsFrame = CreateFrame("Frame", "GwPaperGearSets", GwCharacterWindowContainer, "GwPaperGearSets")
    local button
    local YPadding = 0

    gearSetsFrame.buttons = {}

    for i = 1, 10 do
        button = CreateFrame("Button", "GwGearSetButton" .. i, gearSetsFrame, "GwGearSetsButtonTemplate")
        button:SetPoint('TOPLEFT', gearSetsFrame, 'TOPLEFT', 0, YPadding)
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
        button:HookScript("OnClick", GeatSetButtonOnClick)

        button.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
        button.title:SetTextColor(0.7, 0.7, 0.5, 1)
        button.title:SetText("")
        button.bg:SetVertexColor(1, 1, 1, 1)
        button.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        button:SetNormalTexture(nil)
        button:SetText("")

        YPadding = -44 * i

        tinsert(gearSetsFrame.buttons, button)
    end

    gearSetsFrame:RegisterEvent("VARIABLES_LOADED")
	gearSetsFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
    gearSetsFrame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
    C_EquipmentSet.ClearIgnoredSlotsForSave()

    gearSetsFrame:HookScript("OnShow", function()
        UpdateSets()
    end)

    GearManagerDialogPopup:HookScript("OnShow", function()
        GearManagerDialogPopup:ClearAllPoints()
        GearManagerDialogPopup:SetPoint("TOPLEFT", GwCharacterWindowContainer, "TOPRIGHT", 0, 0)
        gearSetsFrame.save:Disable()

    end)

    GearManagerDialogPopup:HookScript("OnHide", function()
        gearSetsFrame.save:Enable()
        UpdateSets()
    end)

    hooksecurefunc("GearManagagerDialogPopup_AdjustAnchors", function()
        GearManagerDialogPopup:ClearAllPoints()
        GearManagerDialogPopup:SetPoint("TOPLEFT", GwCharacterWindowContainer, "TOPRIGHT", 0, 0)
    end)


    GearManagerDialogPopup:SetParent(GwCharacterWindowContainer)

    hooksecurefunc(C_EquipmentSet, "DeleteEquipmentSet", UpdateSets)
    hooksecurefunc("RecalculateGearManagerDialogPopup", function()
        if GwPaperGearSets.selectedSet then
            GearManagerDialogPopupEditBox:SetText(GwPaperGearSets.selectedSet.name)
            GearManagerDialog.selectedSet = GwPaperGearSets.selectedSet
        end
    end)

    gearSetsFrame.delete:SetScript("OnClick", function()
        local selectedSet = GwPaperGearSets.selectedSet;
        if selectedSet then
            local dialog = StaticPopup_Show("CONFIRM_DELETE_EQUIPMENT_SET", selectedSet.name)
            if dialog then
                dialog.data = selectedSet.id
            else
                UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
            end
        end
    end)
    gearSetsFrame.equipe:SetScript("OnClick", function()
        local selectedSet = GwPaperGearSets.selectedSet
        if selectedSet then
            local name = selectedSet.id
            if (name) then
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)	-- inappropriately named, but a good sound.
                EquipmentManager_EquipSet(name)
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

    gearSetsFrame.backButton:SetText(CHARACTER .. ": " .. EQUIPMENT_MANAGER)
end
GW.LoadGeatSets = LoadGeatSets