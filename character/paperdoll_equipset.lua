local _, GW = ...
local CharacterMenuBlank_OnLoad = GW.CharacterMenuBlank_OnLoad
local SavedItemSlots = GW.char_equipset_SavedItems
local WarningPrompt = GW.WarningPrompt

-- local forward function defs
local drawItemSetList

local function updateIngoredSlots(id)
    local ignoredSlots = C_EquipmentSet.GetIgnoredSlots(id)
    for slot, ignored in pairs(ignoredSlots) do
        if (ignored) then
            C_EquipmentSet.IgnoreSlotForSave(slot)
            SavedItemSlots[slot].ignoreSlotCheck:SetChecked(false)
        else
            C_EquipmentSet.UnignoreSlotForSave(slot)
            SavedItemSlots[slot].ignoreSlotCheck:SetChecked(true)
        end
    end
end
GW.AddForProfiling("character_equipset", "updateIngoredSlots", updateIngoredSlots)

local function toggleIgnoredSlots(show)
    for k, v in pairs(SavedItemSlots) do
        if show then
            v.ignoreSlotCheck:Show()
        else
            v.ignoreSlotCheck:Hide()
        end
    end
end
GW.AddForProfiling("character_equipset", "toggleIgnoredSlots", toggleIgnoredSlots)

local function outfitListButton_OnClick(self, button)
    if not self.saveOutfit:IsShown() then
        drawItemSetList()
        toggleIgnoredSlots(true)
        updateIngoredSlots(self.setID)
        self:SetHeight(80)
        self.saveOutfit:Show()
        self.deleteOutfit:Show()
        self.equipOutfit:Show()
        self.ddbg:Show()
        self.deleteOutfit:SetText(GwLocalization["CHARACTER_DELETE_OUTFIT"])
        self.saveOutfit:SetText(GwLocalization["CHARACTER_SAVE_OUTFIT"])
        self.equipOutfit:SetText(GwLocalization["CHARCTER_EQUIP_OUTFIT"])

        GwPaperDollOutfits.selectedSetID = self.setID
    else
        self.saveOutfit:Hide()
        self.deleteOutfit:Hide()
        self.equipOutfit:Hide()
        self.ddbg:Hide()
        self:SetHeight(49)
    end
end
GW.AddForProfiling("character_equipset", "outfitListButton_OnClick", outfitListButton_OnClick)

local function outfitEquipButton_OnClick(self, button)
    local selectedSetID = GwPaperDollOutfits.selectedSetID
    if (selectedSetID ~= nil) then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)

        C_EquipmentSet.UseEquipmentSet(selectedSetID)
    end
end
GW.AddForProfiling("character_equipset", "outfitEquipButton_OnClick", outfitEquipButton_OnClick)

local function outfitSaveButton_OnClick(self, button)
    WarningPrompt(
        GwLocalization["CHARACTER_OUTFITS_SAVE"] .. self:GetParent().setName .. '"?',
        function()
            C_EquipmentSet.SaveEquipmentSet(self:GetParent().setID)
            drawItemSetList()
        end
    )
end
GW.AddForProfiling("character_equipset", "outfitSaveButton_OnClick", outfitSaveButton_OnClick)

local function outfitDeleteButton_OnClick(self, button)
    WarningPrompt(
        GwLocalization["CHARACTER_OUTFITS_DELETE"] .. self:GetParent().setName .. '"?',
        function()
            C_EquipmentSet.DeleteEquipmentSet(self:GetParent().setID)

            drawItemSetList()
        end
    )
end
GW.AddForProfiling("character_equipset", "outfitDeleteButton_OnClick", outfitDeleteButton_OnClick)

local function getNewEquipmentSetButton(i)
    if _G["GwPaperDollOutfitsButton" .. i] ~= nil then
        return _G["GwPaperDollOutfitsButton" .. i]
    end

    local f = CreateFrame("Button", "GwPaperDollOutfitsButton" .. i, GwPaperDollOutfits, "GwPaperDollOutfitsButton")
    f:SetScript("OnClick", outfitListButton_OnClick)
    f:SetScript("OnLeave", GameTooltip_Hide)
    CharacterMenuBlank_OnLoad(f)
    f.equipOutfit:SetScript("OnClick", outfitEquipButton_OnClick)
    f.saveOutfit:SetScript("OnClick", outfitSaveButton_OnClick)
    f.deleteOutfit:SetScript("OnClick", outfitDeleteButton_OnClick)

    if i > 1 then
        _G["GwPaperDollOutfitsButton" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollOutfitsButton" .. (i - 1)], "BOTTOMLEFT")
    end
    GwPaperDollOutfits.buttons = GwPaperDollOutfits.buttons + 1

    f.standardOnClick = f:GetScript("OnEnter")

    f:GetFontString():ClearAllPoints()
    f:GetFontString():SetPoint("TOP", f, "TOP", 0, -20)

    return f
end
GW.AddForProfiling("character_equipset", "getNewEquipmentSetButton", getNewEquipmentSetButton)

drawItemSetList = function()
    if GwPaperDollOutfits.buttons == nil then
        GwPaperDollOutfits.buttons = 0
    end

    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    local numButtons = GwPaperDollOutfits.buttons

    if numSets > numButtons then
        numButtons = numSets
    end
    local textureC = 1

    local id_table = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, numButtons do
        if numSets >= i then
            local frame = getNewEquipmentSetButton(i)

            local name, texture, setID, isEquipped, _, _, _, numLost, _ =
                C_EquipmentSet.GetEquipmentSetInfo(id_table[i])

            frame:Show()
            frame.saveOutfit:Hide()
            frame.deleteOutfit:Hide()
            frame.equipOutfit:Hide()
            frame.ddbg:Hide()
            frame:SetHeight(49)

            frame:SetScript(
                "OnEnter",
                function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetEquipmentSet(self.setID)
                    self.standardOnClick(self)
                end
            )

            frame:SetText(name)
            frame.setName = name
            frame.setID = setID

            if texture then
                frame.icon:SetTexture(texture)
            else
                frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end

            if textureC == 1 then
                frame:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                textureC = 2
            else
                frame:SetNormalTexture(nil)
                textureC = 1
            end
            if isEquipped then
                frame:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            end
            if numLost > 0 then
                frame:GetFontString():SetTextColor(1, 0.3, 0.3)
            else
                frame:GetFontString():SetTextColor(1, 1, 1)
            end
        else
            if _G["GwPaperDollOutfitsButton" .. i] ~= nil then
                _G["GwPaperDollOutfitsButton" .. i]:Hide()
            end
        end
    end
end
GW.AddForProfiling("character_equipset", "drawItemSetList", drawItemSetList)

--[[
function local GwPaperDollOutfits_OnEvent(self, event, ...)
    if (event == "EQUIPMENT_SWAP_FINISHED") then
        local completed, setName = ...
        if (completed) then
            PlaySound(1212) -- plays the equip sound for plate mail
            if (self:IsShown()) then
                self.selectedSetID = C_EquipmentSet.GetEquipmentSetID(setName)
                drawItemSetList()
            end
        end
    end

    if (self:IsShown()) then
        if (event == "EQUIPMENT_SETS_CHANGED") then
            drawItemSetList()
        elseif (event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE") then
            GwPaperDollOutfits:SetScript(
                "OnUpdate",
                function(self)
                    drawItemSetList()
                    GwPaperDollOutfits:SetScript("OnUpdate", nil)
                end
            )
        end
    end
end
--]]
local function LoadPDEquipset(fmMenu)
    local fmGPDO = CreateFrame("Frame", "GwPaperDollOutfits", GwPaperDoll, "GwPaperDollOutfits")
    local fnGPDO_newOutfit_OnClick = function(self, button)
        self.oldParent = GearManagerDialogPopup:GetParent()
        GearManagerDialogPopup:Show()
        GearManagerDialogPopup:SetParent(GwDressingRoom)
        GearManagerDialogPopup:SetPoint("TOPLEFT", GwDressingRoom, "TOPRIGHT")
        PaperDollEquipmentManagerPane.selectedSetID = nil
        PaperDollFrame_ClearIgnoredSlots()
        PaperDollFrame_IgnoreSlot(4)
        PaperDollFrame_IgnoreSlot(19)
    end
    fmGPDO.newOutfit:SetText(GwLocalization["CHARACTER_OUTFIT_NEW"])
    fmGPDO.newOutfit:SetScript("OnClick", fnGPDO_newOutfit_OnClick)
    fmMenu:SetupBackButton(fmGPDO.backButton, "CHARACTER_MENU_OUTFITS_RETURN")

    GwPaperDollOutfits:SetScript("OnShow", drawItemSetList)
    GwPaperDollOutfits:SetScript(
        "OnHide",
        function()
            toggleIgnoredSlots(false)
        end
    )
    drawItemSetList()

    hooksecurefunc("GearManagerDialogPopupOkay_OnClick", drawItemSetList)
    GearManagerDialogPopup:SetScript(
        "OnShow",
        function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
            self.name = nil
            self.isEdit = false
            RecalculateGearManagerDialogPopup()
            RefreshEquipmentSetIconInfo()
        end
    )
end
GW.LoadPDEquipset = LoadPDEquipset
