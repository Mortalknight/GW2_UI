local _, GW = ...
local GetSetting = GW.GetSetting

local windowsList = {}
local hasBeenLoaded = false

windowsList[1] = {
    ["OnLoad"] = "LoadPaperDoll",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwPaperDoll",
    ["TabIcon"] = "tabicon_character",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon",
    ["HeaderTextKey"] = "CHARACTER_HEADER",
    ["Bindings"] = {
        ["TOGGLECHARACTER0"] = "PaperDoll"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
    ]=]
}

windowsList[2] = {
    ["OnLoad"] = "LoadTalents",
    ["SettingName"] = "USE_TALENT_WINDOW",
    ["RefName"] = "GwTalentFrame",
    ["TabIcon"] = "tabicon_spellbook",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon",
    ["HeaderTextKey"] = "TALENTS_HEADER",
    ["Bindings"] = {
        ["TOGGLESPELLBOOK"] = "SpellBook",
        ["TOGGLETALENTS"] = "Talents",
        ["TOGGLEPETBOOK"] = "SpellBook"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
    ]=]
}

windowsList[3] = {
    ["OnLoad"] = "LoadCurrency",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwCurrencyFrame",
    ["TabIcon"] = "tabicon_currency",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon",
    ["HeaderText"] = CURRENCY,
    ["Bindings"] = {
        ["TOGGLECURRENCY"] = "Currency"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
    ]=]
}

windowsList[4] = {
    ["OnLoad"] = "LoadReputation",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwReputationFrame",
    ["TabIcon"] = "tabicon_reputation",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/reputation-window-icon",
    ["HeaderText"] = REPUTATION,
    ["Bindings"] = {
        ["TOGGLECHARACTER2"] = "Reputation"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
    ]=]
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick =
    [=[
    --print("secure click handler button: " .. button)
    if button == "Close" then
        self:SetAttribute("windowpanelopen", nil)
    elseif button == "PaperDoll" then
        self:SetAttribute("windowpanelopen", "paperdoll")
    elseif button == "Reputation" then
        self:SetAttribute("windowpanelopen", "reputation")
    elseif button == "Currency" then
        self:SetAttribute("windowpanelopen", "currency")
    elseif button == "SpellBook" then
        self:SetAttribute("windowpanelopen", "talents")
    elseif button == "Talents" then
        self:SetAttribute("windowpanelopen", "talents")
    end
    ]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged =
    [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmDoll = self:GetFrameRef("GwPaperDoll")
    local showDoll = false
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local showTal = flase
    local fmRep = self:GetFrameRef("GwReputationFrame")
    local showRep = flase
    local fmCur = self:GetFrameRef("GwCurrencyFrame")
    local showCur = flase
    
    local fmMov = self:GetFrameRef("GwCharacterWindowMoverFrame")
    local close = false

    if fmTal ~= nil and value == "talents" then
        if fmTal:IsVisible() then
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showTal = true
        end
    elseif fmDoll ~= nil and value == "paperdoll" then
        if fmDoll:IsVisible() then
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDoll = true
        end
    elseif fmRep ~= nil and value == "reputation" then
        if fmRep:IsVisible() then
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showRep = true
        end
    elseif fmCur ~= nil and value == "currency" then
        if fmCur:IsVisible() then
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showCur = true
        end
    else
        close = true
    end

    if fmDoll then
        if showDoll and not close then
            fmDoll:Show()
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
    if fmRep then
        if showRep and not close then
            fmRep:Show()
        else
            fmRep:Hide()
        end
    end
    if fmCur then
        if showCur and not close then
            fmCur:Show()
        else
            fmCur:Hide()
        end
    end

    if close then
        fmMov:Hide()
        self:Hide()
        self:CallMethod("SoundExit")
    elseif not self:IsVisible() then
        self:Show()
        fmMov:Show()
        self:CallMethod("SoundOpen")
    else
        self:CallMethod("SoundSwap")
    end
    ]=]

local charSecure_OnShow =
    [=[
    local keyEsc = GetBindingKey("TOGGLEGAMEMENU")
    if keyEsc ~= nil then
        self:SetBinding(false, keyEsc, "CLICK GwCharacterWindow:Close")
    end
    ]=]

local charSecure_OnHide = [=[
    self:ClearBindings()
    ]=]

local charCloseSecure_OnClick = [=[
    self:GetParent():SetAttribute("windowpanelopen", nil)
    ]=]

local mover_OnDragStart = function(self)
    self:StartMoving()
end

local mover_OnDragStop = function(self)
    self:StopMovingOrSizing()
end

-- TODO: this doesn't work if bindings are updated in combat, but who does that?!
local function mover_OnEvent(self, event)
    if event ~= "UPDATE_BINDINGS" then
        return
    end
    ClearOverrideBindings(self)

    for k, win in pairs(windowsList) do
        if win.TabFrame and win.Bindings then
            for key, click in pairs(win.Bindings) do
                local keyBind = GetBindingKey(key)
                if keyBind then
                    SetOverrideBinding(self, false, keyBind, "CLICK GwCharacterWindow:" .. click)
                end
            end
        end
    end
end

local function loadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true

    -- create the mover handle for the character window
    local fmGCWMF = CreateFrame("Frame", "GwCharacterWindowMoverFrame", UIParent, "GwCharacterWindowMoverFrame")
    fmGCWMF:SetScript("OnDragStart", mover_OnDragStart)
    fmGCWMF:SetScript("OnDragStop", mover_OnDragStop)
    fmGCWMF:RegisterForDrag("LeftButton")
    fmGCWMF:SetScript("OnEvent", mover_OnEvent)
    fmGCWMF:RegisterEvent("UPDATE_BINDINGS")

    -- create the character window and secure bind its tab open/close functions
    local fmGCW = CreateFrame("Button", "GwCharacterWindow", UIParent, "GwCharacterWindow")
    fmGCW.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    fmGCW.WindowHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fmGCW:SetFrameRef("GwCharacterWindowMoverFrame", fmGCWMF)
    fmGCW:SetAttribute("windowpanelopen", nil)
    fmGCW:SetAttribute("_onclick", charSecure_OnClick)
    fmGCW:SetAttribute("_onattributechanged", charSecure_OnAttributeChanged)
    fmGCW.SoundOpen = function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    fmGCW.SoundSwap = function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end
    fmGCW.SoundExit = function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end

    -- secure hook ESC to close char window when it is showing
    fmGCW:WrapScript(fmGCW, "OnShow", charSecure_OnShow)
    fmGCW:WrapScript(fmGCW, "OnHide", charSecure_OnHide)

    -- the close button securely closes the char window
    fmGCW.close:SetAttribute("_onclick", charCloseSecure_OnClick)

    -- hook into inventory currency button
    --if GwCurrencyIcon then
    --    GwCurrencyIcon:SetFrameRef("GwCharacterWindow", fmGCW)
    --end
end

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.505, 1, 0, 0.625)
    end
end

local function createTabIcon(iconName, tabIndex)
    local f = CreateFrame("Button", nil, GwCharacterWindow, "GwCharacterTabSelect")
    f.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\" .. iconName)
    f:SetPoint("TOP", GwCharacterWindow, "TOPLEFT", -32, -25 + -((tabIndex - 1) * 45))
    setTabIconState(f, false)
    return f
end

local function container_OnShow(self)
    setTabIconState(self.TabFrame, true)
    self.CharWindow.windowIcon:SetTexture(self.HeaderIcon)
    self.CharWindow.WindowHeader:SetText(self.HeaderText)
end

local function container_OnHide(self)
    setTabIconState(self.TabFrame, false)
end

local function charTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
    GameTooltip:ClearLines()
    GameTooltip_AddNormalLine(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end
GW.AddForProfiling("talents", "charTab_OnEnter", charTab_OnEnter)

local function LoadCharacter()
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
            local container = CreateFrame("Frame", nil, GwCharacterWindow, "GwCharacterTabContainer")
            local tab = createTabIcon(v.TabIcon, tabIndex)

            GwCharacterWindow:SetFrameRef(v.RefName, container)
            container.TabFrame = tab
            container.CharWindow = GwCharacterWindow
            container.HeaderIcon = v.HeaderIcon
            if v.HeaderTextKey then
                container.HeaderText = GwLocalization[v.HeaderTextKey]
                tab.gwTipLabel = GwLocalization[v.HeaderTextKey]
            else
                container.HeaderText = v.HeaderText
                tab.gwTipLabel = v.HeaderText
            end

            tab:SetScript("OnEnter", charTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            v.TabFrame = tab
            tab:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
            tab:SetAttribute("_onclick", v.OnClick)
            container:SetScript("OnShow", container_OnShow)
            container:SetScript("OnHide", container_OnHide)

            GW[v.OnLoad](container)

            tabIndex = tabIndex + 1
        end
    end

    -- set bindings on mover instead of char win to not interfere with secure ESC binding on char win
    mover_OnEvent(GwCharacterWindowMoverFrame, "UPDATE_BINDINGS")
end
GW.LoadCharacter = LoadCharacter

-- stuff for standard menu functionality
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

local function CharacterMenuButton_OnLoad(self, odd)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    if odd then
        self:SetNormalTexture(nil)
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end
    self:GetFontString():SetTextColor(1, 1, 1, 1)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
end
GW.CharacterMenuButton_OnLoad = CharacterMenuButton_OnLoad

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
