local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting

local windowsList = {}
local hasBeenLoaded = false

windowsList[1] = {
    ['OnLoad'] = "LoadPaperDoll",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_character',
    ["Bindings"] = {
        ["TOGGLECHARACTER0"] = "PaperDoll",
        ["TOGGLECHARACTER2"] = "Reputation",
        ["TOGGLECHARACTER1"] = "Skills",
        ["TOGGLECHARACTER3"] = "PetPaperDollFrame"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
    ]=]
}

windowsList[2] = {
    ['OnLoad'] = "LoadTalents",
    ['SettingName'] = 'USE_TALENT_WINDOW',
    ['TabIcon'] = 'tabicon-talents',
    ["Bindings"] = {
        ["TOGGLETALENTS"] = "Talents"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
    ]=]
    }

windowsList[3] = {
    ['OnLoad'] = "LoadSpellBook",
    ['SettingName'] = 'USE_SPELLBOOK_WINDOW',
    ['TabIcon'] = 'tabicon_spellbook',
    ["Bindings"] = {
        ["TOGGLESPELLBOOK"] = "SpellBook",
        ["TOGGLEPETBOOK"] = "PetBook"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
    ]=]
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick =
    [=[
    --print("secure click handler button: " .. button)
    local f = self:GetFrameRef("GwCharacterWindow")
    if button == "Close" then
        f:SetAttribute("windowpanelopen", nil)
    elseif button == "PaperDoll" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdoll")
    elseif button == "Reputation" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "reputation")
    elseif button == "SpellBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "spellbook")
    elseif button == "PetBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "petbook")
    elseif button == "Talents" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "talents")
    elseif button == "PetPaperDollFrame" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollpet")
    elseif button == "Skills" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollskills")
    end
    ]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged =
    [=[
    if name ~= "windowpanelopen" then
        return
    end
    local fmDoll = self:GetFrameRef("GwCharacterWindowContainer")
    local fmDollMenu = self:GetFrameRef("GwCharacterMenu")
    local fmDollRepu = self:GetFrameRef("GwPaperReputation")
    local fmDollSkills = self:GetFrameRef("GwPaperSkills")
    local fmDollPetCont = self:GetFrameRef("GwPetContainer")
    local fmDollDress = self:GetFrameRef("GwDressingRoom")
    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollSkills = false
    local showDollPetCont = false
    local fmSBM = self:GetFrameRef("GwSpellbook")
    local showSpell = false
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local showTal = false

    local hasPetUI = self:GetAttribute("HasPetUI")
    
    local close = false
    local keytoggle = self:GetAttribute("keytoggle")

    if fmTal ~= nil and value == "talents" then
        if keytoggle and fmTal:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showTal = true
        end
    elseif fmSBM ~= nil and value == "spellbook" then
        if keytoggle and fmSBM:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmSBM ~= nil and value == "petbook" then
        if keytoggle and fmSBM:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmDoll ~= nil and value == "paperdoll" then
        if keytoggle and fmDoll:IsVisible() and (not fmDollRepu:IsVisible() and not fmDollSkills:IsVisible() and not fmDollPetCont:IsVisible()) then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDoll = true
        end
    elseif fmDollRepu ~= nil and value == "reputation" then
        if keytoggle and fmDollRepu:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollRepu = true
        end
    elseif fmDollSkills ~= nil and value == "paperdollskills" then
        if keytoggle and fmDollSkills:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollSkills = true
        end
    elseif fmDollPetCont ~= nil and value == "paperdollpet" and hasPetUI then
        if keytoggle and fmDollPetCont:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollPetCont = true
        end
    else
        close = true
    end

    if keytoggle then
        self:SetAttribute("keytoggle", nil)
    end

    if fmDoll then
        if showDoll and not close then
            fmDoll:Show()
            fmDollMenu:Show()
            fmDollDress:Show()

            fmDollRepu:Hide()
            fmDollSkills:Hide()
            fmDollPetCont:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmTal then
        if showTal and not close then
            fmTal:Show()
        else
            fmTal:Hide()
        end
    end
    if fmSBM then
        if showSpell and not close then
            fmSBM:Show()
        else
            fmSBM:Hide()
        end
    end
    if fmDollRepu and showDollRepu then
        if showDollRepu and not close then
            fmDoll:Show()
            fmDollRepu:Show()

            fmDollMenu:Hide()
            fmDollSkills:Hide()
            fmDollPetCont:Hide()
            fmDollDress:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollSkills and showDollSkills then
        if showDollSkills and not close then
            fmDoll:Show()
            fmDollSkills:Show()
            fmDollDress:Show()

            fmDollRepu:Hide()
            fmDollMenu:Hide()
            fmDollPetCont:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollPetCont and showDollPetCont then
        if showDollPetCont and not close then
            fmDoll:Show()
            fmDollPetCont:Show()

            fmDollSkills:Hide()
            fmDollDress:Hide()
            fmDollRepu:Hide()
            fmDollMenu:Hide()
        else
            fmDoll:Hide()
        end
    end

    if close then
        self:Hide()
        self:CallMethod("SoundExit")
    elseif not self:IsVisible() then
        self:Show()
        self:CallMethod("SoundOpen")
    else
        self:CallMethod("SoundSwap")
    end
    ]=]


 -- TODO: this doesn't work if bindings are updated in combat, but who does that?!
local function click_OnEvent(self, event)
    if event ~= "UPDATE_BINDINGS" then
        return
    end
    ClearOverrideBindings(self)

    for k, win in pairs(windowsList) do
        if win.TabFrame and win.Bindings then
            for key, click in pairs(win.Bindings) do
                local keyBind = GetBindingKey(key)
                if keyBind then
                    SetOverrideBinding(self, false, keyBind, "CLICK GwCharacterWindowClick:" .. click)
                end
            end
        end
    end
end
GW.AddForProfiling("character", "mover_OnEvent", mover_OnEvent)

local function loadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true

    CreateFrame('Frame', 'GwCharacterWindowMoverFrame', UIParent,' GwCharacterWindowMoverFrame')
    CreateFrame('Button', 'GwCharacterWindow', UIParent, 'GwCharacterWindow')
    GwCharacterWindow:SetFrameLevel(5)
    GwCharacterWindowMoverFrame:Hide()

    GwCharacterWindow:SetAttribute('windowpanelopen', nil)
    GwCharacterWindow:SetFrameRef('GwCharacterWindowMoverFrame', GwCharacterWindowMoverFrame)
    GwCharacterWindow:SetAttribute("_onattributechanged", charSecure_OnAttributeChanged)
    GwCharacterWindow.secure:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    GwCharacterWindow.secure:SetAttribute("_onclick", charSecure_OnClick)

    -- set binding change handlers
    GwCharacterWindow.secure:HookScript("OnEvent", click_OnEvent)
    GwCharacterWindow.secure:RegisterEvent("UPDATE_BINDINGS")

    GwCharacterWindow.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwCharacterWindow.WindowHeader:SetTextColor(255/255, 241/255, 209/255)

    GwCharacterWindow.SoundOpen = function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    GwCharacterWindow.SoundSwap = function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end
    GwCharacterWindow.SoundExit = function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end

    GwCharacterWindow.close:SetFrameRef('GwCharacterWindow', GwCharacterWindow)
    GwCharacterWindow.close:SetFrameRef('GwCharacterWindowMoverFrame', GwCharacterWindowMoverFrame)

    GwCharacterWindow.close:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwCharacterWindow'):Hide()
        self:GetFrameRef('GwCharacterWindowMoverFrame'):Hide()
        if self:GetFrameRef('GwCharacterWindow'):IsVisible() then
            self:GetFrameRef('GwCharacterWindow'):Hide()
        end
    ]=])

    GwCharacterWindow:SetAttribute('_onshow', [=[
        local keyEsc = GetBindingKey("TOGGLEGAMEMENU")

        if keyEsc ~= nil then
            self:SetBinding(false, keyEsc, "CLICK GwCharacterWindowClick:Close")
        end
        ]=])
    GwCharacterWindow:SetAttribute('_onhide', [=[
        self:ClearBindings()
    ]=])

    GwCharacterWindow:Hide()
end

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.5, 1, 0, 0.625)
    end
end

local function createTabIcon(iconName, tabIndex)
    local f = CreateFrame('Button', 'CharacterWindowTab' .. tabIndex, GwCharacterWindow, 'SecureHandlerClickTemplate,SecureHandlerStateTemplate,CharacterWindowTabSelect')

    f.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\' .. iconName)
    f:SetPoint('TOP', GwCharacterWindow, 'TOPLEFT', -32, -25 + -((tabIndex - 1) * 45))
    setTabIconState(f, false)

    return f
end

local function styleCharacterMenuButton(self, shadow)
    if shadow then
        self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        self:GetFontString():SetTextColor(1,1,1,1)
        self:GetFontString():SetShadowColor(0,0,0,0)
        self:GetFontString():SetShadowOffset(1,-1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT,14)
        self:GetFontString():SetJustifyH('LEFT')
        self:GetFontString():SetPoint('LEFT',self,'LEFT',5,0)
    else
        self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        self:SetNormalTexture(nil)
        self:GetFontString():SetTextColor(1,1,1,1)
        self:GetFontString():SetShadowColor(0,0,0,0)
        self:GetFontString():SetShadowOffset(1,-1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT,14)
        self:GetFontString():SetJustifyH('LEFT')
        self:GetFontString():SetPoint('LEFT',self,'LEFT',5,0)
    end
    self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
end

local function styleCharacterMenuBackButton(self)
    self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
    self:SetNormalTexture(nil)
    local fontString = self:GetFontString()
    fontString:SetTextColor(1,1,1,1)
    fontString:SetShadowColor(0,0,0,0)
    fontString:SetShadowOffset(1,-1)
    fontString:SetFont(DAMAGE_TEXT_FONT,14)
    self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
end

function Gw_LoadWindows()
    local anyThingToLoad = false
    for k, v in pairs(windowsList) do
        if GetSetting(v.SettingName) then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    loadBaseFrame()

    local tabIndex = 1
    for k, v in pairs(windowsList) do
        if GetSetting(v.SettingName) then
            local ref = GW[v.OnLoad]()
            local f = createTabIcon(v.TabIcon, tabIndex)

            GwCharacterWindow:SetFrameRef(ref:GetName(), ref)
            ref:HookScript('OnShow', function()
                setTabIconState(f, true)
            end)
            ref:HookScript('OnHide', function()
                setTabIconState(f, false)
            end)
            f:SetFrameRef('GwCharacterWindow', GwCharacterWindow)
            f:SetAttribute('_OnClick', v.OnClick)

            if ref:GetName() == "GwCharacterWindowContainer" then
                GwCharacterWindow:SetFrameRef("GwCharacterMenu", GwCharacterMenu)
                GwCharacterWindow:SetFrameRef("GwPaperReputation", GwPaperReputation)
                GwCharacterWindow:SetFrameRef("GwPaperSkills", GwPaperSkills)
                GwCharacterWindow:SetFrameRef("GwDressingRoom", GwDressingRoom)
                GwCharacterWindow:SetFrameRef("GwPetContainer", GwPetContainer)

                styleCharacterMenuButton(GwCharacterMenu.skillsMenu, true)
                styleCharacterMenuButton(GwCharacterMenu.reputationMenu, false)
                styleCharacterMenuButton(GwCharacterMenu.petMenu, true)
                styleCharacterMenuBackButton(GwPaperSkills.backButton)
                styleCharacterMenuBackButton(GwPaperReputation.backButton)
                styleCharacterMenuBackButton(GwDressingRoomPet.backButton)

                GwCharacterMenu.skillsMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollskills")
                ]=])
                GwCharacterMenu.reputationMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "reputation")
                ]=])
                GwCharacterMenu.petMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollpet")
                ]=])
                GwPaperSkills.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwPaperReputation.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwDressingRoomPet.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
            end
            v.TabFrame = f

            tabIndex = tabIndex + 1
        end
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    click_OnEvent(GwCharacterWindow.secure, "UPDATE_BINDINGS")
end
