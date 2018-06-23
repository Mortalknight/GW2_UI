local _, GW = ...

local CHARACTER_PANEL_OPEN = ""

local function characterPanelToggle(frame)
    GwPaperDollBagItemList:Hide()
    GwCharacterMenu:Hide()
    GwPaperDollOutfits:Hide()
    GwPaperTitles:Hide()

    GwPaperReputation:Hide()

    if frame ~= nil then
        frame:Show()
    else
        GwDressingRoom:Hide()
        return
    end

    if frame:GetName() == "GwPaperReputation" then
        GwDressingRoom:Hide()
    else
        GwDressingRoom:Show()
    end
end

local function toggleCharacter(tab, onlyShow)
    local CHARACTERFRAME_DEFAULTFRAMES = {}

    CHARACTERFRAME_DEFAULTFRAMES["PaperDollFrame"] = GwCharacterMenu
    CHARACTERFRAME_DEFAULTFRAMES["ReputationFrame"] = GwPaperReputation
    CHARACTERFRAME_DEFAULTFRAMES["TokenFrame"] = GwCharacterMenu

    if CHARACTERFRAME_DEFAULTFRAMES[tab] ~= nil and CHARACTER_PANEL_OPEN ~= tab then
        characterPanelToggle(CHARACTERFRAME_DEFAULTFRAMES[tab])
        CHARACTER_PANEL_OPEN = tab
        return
    end

    if GwCharacterWindow:IsShown() then
        if not InCombatLockdown() then
            GwCharacterWindow:SetAttribute("windowPanelOpen", 0)
        end

        CHARACTER_PANEL_OPEN = nil
        return
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

local function LoadCharacter()
    CreateFrame("Frame", "GwCharacterWindowContainer", GwCharacterWindow, "GwCharacterWindowContainer")

    local fmGCM = CreateFrame("Frame", "GwCharacterMenu", GwCharacterWindowContainer, "GwCharacterMenu")
    local fnGCM_ToggleEquipment = function()
        characterPanelToggle(GwPaperDollBagItemList)
    end
    local fnGCM_ToggleOutfits = function()
        characterPanelToggle(GwPaperDollOutfits)
    end
    local fnGCM_ToggleTitles = function()
        characterPanelToggle(GwPaperTitles)
    end
    local fnGCM_ToggleReputation = function()
        characterPanelToggle(GwPaperReputation)
    end
    fmGCM.equipmentMenu:SetScript("OnClick", fnGCM_ToggleEquipment)
    fmGCM.equipmentMenu:SetText(GwLocalization["CHARACTER_MENU_EQUIPMENT"])
    fmGCM.outfitsMenu:SetScript("OnClick", fnGCM_ToggleOutfits)
    fmGCM.outfitsMenu:SetText(GwLocalization["CHARACTER_MENU_OUTFITS"])
    fmGCM.titlesMenu:SetScript("OnClick", fnGCM_ToggleTitles)
    fmGCM.titlesMenu:SetText(GwLocalization["CHARACTER_MENU_TITLES"])
    fmGCM.reputationMenu:SetScript("OnClick", fnGCM_ToggleReputation)
    fmGCM.reputationMenu:SetText(GwLocalization["CHARACTER_MENU_REPS"])
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
    fnGCMMenu_OnLoad2(fmGCM.reputationMenu)

    GW.LoadCharacterPaperdoll()
    GW.LoadCharacterEquipset()
    GW.LoadCharacterTitles()
    GW.LoadCharacterReputation()

    CharacterFrame:SetScript(
        "OnShow",
        function()
            HideUIPanel(CharacterFrame)
        end
    )

    CharacterFrame:UnregisterAllEvents()

    hooksecurefunc("ToggleCharacter", toggleCharacter)

    GwCharacterWindowContainer:HookScript(
        "OnHide",
        function()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
        end
    )
    GwCharacterWindowContainer:HookScript(
        "OnShow",
        function()
            GwCharacterWindow.windowIcon:SetTexture(
                "Interface\\AddOns\\GW2_UI\\textures\\character\\character-window-icon"
            )
            GwCharacterWindow.WindowHeader:SetText(GwLocalization["CHARACTER_HEADER"])
            if CHARACTER_PANEL_OPEN == nil then
                characterPanelToggle(GwCharacterMenu)
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
            end
        end
    )

    fmGCM:Show()

    return GwCharacterWindowContainer
end
GW.LoadCharacter = LoadCharacter
