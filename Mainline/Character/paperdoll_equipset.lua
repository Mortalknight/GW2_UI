local _, GW = ...
local g_selectionBehavior = nil
local GwGearManagerPopupFrame

local function toggleIgnoredSlots(show)
    for _, v in pairs(GW.char_equipset_SavedItems) do
        if show then
            v.ignoreSlotCheck:Show()
        else
            v.ignoreSlotCheck:Hide()
        end
    end
end

local function updateIngoredSlots(id)
    local ignoredSlots = C_EquipmentSet.GetIgnoredSlots(id)
    for slot, ignored in pairs(ignoredSlots) do
        if (ignored) then
            C_EquipmentSet.IgnoreSlotForSave(slot)
            GW.char_equipset_SavedItems[slot].ignoreSlotCheck:SetChecked(false)
        else
            C_EquipmentSet.UnignoreSlotForSave(slot)
            GW.char_equipset_SavedItems[slot].ignoreSlotCheck:SetChecked(true)
        end
    end
end

local function ToggleButton(self, shown)
    self.saveOutfit:SetShown(shown)
    self.editOutfit:SetShown(shown)
    self.deleteOutfit:SetShown(shown)
    self.equipOutfit:SetShown(shown)
    self.deleteOutfit.icon:SetDesaturated(true)
    self.saveOutfit.icon:SetDesaturated(true)

    self:SetHeight(shown and 80 or 49)
    toggleIgnoredSlots(shown)
end

local function outfitListButton_OnClick(self)
    if not self then return end
    g_selectionBehavior:ToggleSelect(self)

    if g_selectionBehavior:IsSelected(self) then
        updateIngoredSlots(self.setID)

        ToggleButton(self, true)
        GwPaperDollOutfits.selectedSetID = self.setID
    else
        ToggleButton(self, false)
    end
end

local function outfitEquipButton_OnClick()
    local selectedSetID = GwPaperDollOutfits.selectedSetID
    if (selectedSetID ~= nil) then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)

        C_EquipmentSet.UseEquipmentSet(selectedSetID)
    end
end


local function GearSetButton_Edit(self)
    GwGearManagerPopupFrame.mode = IconSelectorPopupFrameModes.Edit
    PaperDollFrame.EquipmentManagerPane.selectedSetID = self.setID
    GwGearManagerPopupFrame.setID = self.setID
    GwGearManagerPopupFrame.origName = self.setName
    GwGearManagerPopupFrame.listButton = self
    GwGearManagerPopupFrame:Show()
    GwGearManagerPopupFrame:OnShow()
end

local function UpdateScrollBox(self)
    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    local id_table = C_EquipmentSet.GetEquipmentSetIDs()

    local dataProvider = CreateDataProvider();
    for i = 1, numSets do
        dataProvider:Insert({index = i, setId = id_table[i]})
    end
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function outfitSaveButton_OnClick(self)
    GW.ShowPopup({text = TRANSMOG_OUTFIT_CONFIRM_SAVE:format(self:GetParent().setName),
        OnAccept = function()
            C_EquipmentSet.SaveEquipmentSet(self:GetParent().setID)
            UpdateScrollBox(GwPaperDollOutfits)
            toggleIgnoredSlots(false)
            outfitListButton_OnClick(self:GetParent())
        end}
    )
end


local function outfitEditButton_OnClick(self)
    MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
        rootDescription:SetMinimumWidth(1)
        rootDescription:CreateButton(EQUIPMENT_SET_EDIT, function()
            GearSetButton_Edit(self:GetParent())
        end)
        rootDescription:CreateTitle(EQUIPMENT_SET_ASSIGN_TO_SPEC)

        do
            for i = 1, GetNumSpecializations() do
                local function IsSelected(id)
                    return C_EquipmentSet.GetEquipmentSetAssignedSpec(self:GetParent().setID) == id
                end

                local function SetSelected(id)
                    local currentSpecIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(self:GetParent().setID)
                    if currentSpecIndex ~= id then
                        C_EquipmentSet.AssignSpecToEquipmentSet(self:GetParent().setID, id)
                    else
                        C_EquipmentSet.UnassignEquipmentSetSpec(self:GetParent().setID)
                    end

                    GearSetButton_UpdateSpecInfo(self:GetParent())
                    PaperDollEquipmentManagerPane_Update(true)
                end

                local name = select(2, GetSpecializationInfoByID(C_SpecializationInfo.GetSpecializationInfo(i)))
                local check = rootDescription:CreateCheckbox(name, IsSelected, SetSelected, i)
                check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
            end
        end
    end)
end


local function outfitDeleteButton_OnClick(self)
    GW.ShowPopup({text = TRANSMOG_OUTFIT_CONFIRM_DELETE:format(self:GetParent().setName),
        OnAccept = function()
            C_EquipmentSet.DeleteEquipmentSet(self:GetParent().setID)

            UpdateScrollBox(GwPaperDollOutfits)
        end}
    )
end


local function EquipmentSet_InitButton(button, elementData)
    if not button.isSkinned then
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnDragStart", function()
            if button.setID then
                C_EquipmentSet.PickupEquipmentSet(button.setID)
            end
        end)
        button:SetScript("OnClick", outfitListButton_OnClick)
        button:SetScript("OnLeave", GameTooltip_Hide)
        button:SetScript("OnEnter",
            function(self)
                if self.setID then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetEquipmentSet(self.setID)
                end
            end)
        button.equipOutfit:SetScript("OnClick", outfitEquipButton_OnClick)
        button.saveOutfit:SetScript("OnClick", outfitSaveButton_OnClick)
        button.saveOutfit:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(SAVE, 1, 1, 1)
            GameTooltip:Show()
        end)
        button.saveOutfit:SetScript("OnLeave", GameTooltip_Hide)
        button.editOutfit:SetScript("OnClick", outfitEditButton_OnClick)
        button.editOutfit:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(EDIT, 1, 1, 1)
            GameTooltip:Show()
        end)
        button.editOutfit:SetScript("OnLeave", GameTooltip_Hide)
        button.deleteOutfit:SetScript("OnClick", outfitDeleteButton_OnClick)
        button.deleteOutfit:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(DELETE, 1, 1, 1)
            GameTooltip:Show()
        end)
        button.deleteOutfit:SetScript("OnLeave", GameTooltip_Hide)
        button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        button.name:SetTextColor(1, 1, 1)

        button.SetSelected = function(self, selected)
            self.selected = selected
        end

        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    local name, texture, setID, isEquipped, _, _, _, numLost = C_EquipmentSet.GetEquipmentSetInfo(elementData.setId)

    button.name:SetText(name)
    button.setName = name
    button.setID = setID
    GearSetButton_UpdateSpecInfo(button)
    if texture then
        button.icon:SetTexture(texture)
    else
        button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    if numLost > 0 then
        button.name:SetTextColor(1, 0.3, 0.3)
    else
        button.name:SetTextColor(1, 1, 1)
    end

    -- set zebra color by idx or watch status
    if ((elementData.index % 2) == 1) or isEquipped then
        button.zebra:SetVertexColor(1, 1, 1, 1)
    else
        button.zebra:SetVertexColor(0, 0, 0, 0)
    end

    ToggleButton(button, false)
end

local function LoadPDEquipset(fmMenu, parent)
    local fmGPDO = CreateFrame("Frame", "GwPaperDollOutfits", parent, "GwPaperDollOutfits")
    GwGearManagerPopupFrame = CreateFrame("Frame", "GwGearManagerPopupFrame", GwDressingRoom, "IconSelectorPopupFrameTemplate")
    Mixin(GwGearManagerPopupFrame, GearManagerPopupFrameMixin)
    GwGearManagerPopupFrame:Hide()

    GwGearManagerPopupFrame:SetParent(GwDressingRoom)
    GwGearManagerPopupFrame:ClearAllPoints()
    GwGearManagerPopupFrame:SetPoint("TOPLEFT", GwDressingRoom, "TOPRIGHT")
    local fnGPDO_newOutfit_OnClick = function()
        if C_EquipmentSet.GetNumEquipmentSets() >= MAX_EQUIPMENT_SETS_PER_PLAYER  then
            UIErrorsFrame:AddMessage(EQUIPMENT_SETS_TOO_MANY, 1.0, 0.1, 0.1, 1.0)
        else
            GwGearManagerPopupFrame.mode = IconSelectorPopupFrameModes.New
            PaperDollFrame.EquipmentManagerPane.selectedSetID = nil
            GwGearManagerPopupFrame:Show()
            GwGearManagerPopupFrame:OnShow()
            PaperDollEquipmentManagerPane_Update(true)

            -- Ignore shirt and tabard by default
            PaperDollFrame_IgnoreSlot(4)
            PaperDollFrame_IgnoreSlot(19)
        end
    end
    fmGPDO.newOutfit:SetText(TRANSMOG_OUTFIT_NEW)
    fmGPDO.newOutfit:SetScript("OnClick", fnGPDO_newOutfit_OnClick)
    fmMenu:SetupBackButton(fmGPDO.backButton, CHARACTER .. ":\n" .. EQUIPMENT_MANAGER)

    hooksecurefunc(GwGearManagerPopupFrame, "OnShow", function(frame)
        if not frame.isSkinned then
            GW.HandleIconSelectionFrame(frame)
        end
    end)

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwPaperDollOutfitsButtonTemplate", function(button, elementData)
        EquipmentSet_InitButton(button, elementData)
    end)
    view:SetElementExtentCalculator(function(dataIndex, elementData)
        if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
            return 80
        else
            return 49
        end
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(fmGPDO.ScrollBox, fmGPDO.ScrollBar, view)

    g_selectionBehavior = ScrollUtil.AddSelectionBehavior(fmGPDO.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
    g_selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
        local button = fmGPDO.ScrollBox:FindFrame(elementData)

        ToggleButton(button, selected)
        if button then
            button:SetSelected(selected)
        end
    end, fmGPDO)

    ScrollUtil.AddResizableChildrenBehavior(fmGPDO.ScrollBox)

    GW.HandleTrimScrollBar(fmGPDO.ScrollBar)
    GW.HandleScrollControls(fmGPDO)
    fmGPDO.ScrollBar:SetHideIfUnscrollable(true)

    fmGPDO:SetScript("OnShow", UpdateScrollBox)
    fmGPDO:SetScript(
        "OnHide",
        function()
            toggleIgnoredSlots(false)
        end
    )
    UpdateScrollBox(fmGPDO)

    hooksecurefunc(GwGearManagerPopupFrame, "OkayButton_OnClick", function() UpdateScrollBox(fmGPDO) end)

    return fmGPDO
end
GW.LoadPDEquipset = LoadPDEquipset
