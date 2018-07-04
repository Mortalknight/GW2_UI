local _, GW = ...
local Debug = GW.Debug

--local CHARACTER_PANEL_OPEN

local function characterPanelToggle(frame)
    GwPaperDollBagItemList:Hide()
    GwCharacterMenu:Hide()
    GwPaperDollOutfits:Hide()
    GwPaperTitles:Hide()

    if frame ~= nil then
        frame:Show()
    else
        GwDressingRoom:Hide()
        return
    end

    GwDressingRoom:Show()
end

local function toggleCharacter(tab, onlyShow)
    if InCombatLockdown() then
        return
    end

    if GwCharacterWindow:IsShown() then
        if not onlyShow then
            GwCharacterWindow:SetAttribute("windowpanelopen", nil)
        end
    else
        GwCharacterWindow:SetAttribute("windowpanelopen", "character")
    end
end

local function CharacterMenuBlank_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self:SetNormalTexture(nil)
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:SetFont(DAMAGE_TEXT_FONT, 14)
end
GW.CharacterMenuBlank_OnLoad = CharacterMenuBlank_OnLoad

local function CharacterMenuButtonBack_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self:SetNormalTexture(nil)
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:SetFont(DAMAGE_TEXT_FONT, 14)
end
GW.CharacterMenuButtonBack_OnLoad = CharacterMenuButtonBack_OnLoad

local function CharacterMenuButtonBack_OnClick(self, button)
    characterPanelToggle(GwCharacterMenu)
end
GW.CharacterMenuButtonBack_OnClick = CharacterMenuButtonBack_OnClick

local function LoadPaperDoll(tabContainer)
    --local fmPD = CreateFrame("Frame", "GwPaperDoll", tabContainer, "GwPaperDoll")
    GwPaperDoll = tabContainer
    local fmPD = tabContainer
    --local fmGCM = CreateFrame("Frame", "GwCharacterMenu", GwPaperDoll, "GwCharacterMenu")
    local fmGCM = CreateFrame("Frame", "GwCharacterMenu", tabContainer, "GwCharacterMenu")

    local fnGCM_ToggleEquipment = function()
        characterPanelToggle(GwPaperDollBagItemList)
    end
    local fnGCM_ToggleOutfits = function()
        characterPanelToggle(GwPaperDollOutfits)
    end
    local fnGCM_ToggleTitles = function()
        characterPanelToggle(GwPaperTitles)
    end
    fmGCM.equipmentMenu:SetScript("OnClick", fnGCM_ToggleEquipment)
    fmGCM.equipmentMenu:SetText(GwLocalization["CHARACTER_MENU_EQUIPMENT"])
    fmGCM.outfitsMenu:SetScript("OnClick", fnGCM_ToggleOutfits)
    fmGCM.outfitsMenu:SetText(GwLocalization["CHARACTER_MENU_OUTFITS"])
    fmGCM.titlesMenu:SetScript("OnClick", fnGCM_ToggleTitles)
    fmGCM.titlesMenu:SetText(GwLocalization["CHARACTER_MENU_TITLES"])
    local fnGCMMenu_OnLoad1 = function(self)
        self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
        self:GetFontString():SetTextColor(1, 1, 1, 1)
        self:GetFontString():SetShadowColor(0, 0, 0, 0)
        self:GetFontString():SetShadowOffset(1, -1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
        self:GetFontString():SetJustifyH("LEFT")
        self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    end
    local fnGCMMenu_OnLoad2 = function(self)
        self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
        self:SetNormalTexture(nil)
        self:GetFontString():SetTextColor(1, 1, 1, 1)
        self:GetFontString():SetShadowColor(0, 0, 0, 0)
        self:GetFontString():SetShadowOffset(1, -1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
        self:GetFontString():SetJustifyH("LEFT")
        self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    end
    fnGCMMenu_OnLoad1(fmGCM.equipmentMenu)
    fnGCMMenu_OnLoad1(fmGCM.titlesMenu)
    fnGCMMenu_OnLoad2(fmGCM.outfitsMenu)

    GW.LoadCharacterPaperdoll()
    GW.LoadCharacterEquipset()
    GW.LoadCharacterTitles()

    CharacterFrame:SetScript(
        "OnShow",
        function()
            HideUIPanel(CharacterFrame)
        end
    )

    CharacterFrame:UnregisterAllEvents()

    hooksecurefunc("ToggleCharacter", toggleCharacter)
end
GW.LoadPaperDoll = LoadPaperDoll
