local _, GW = ...
local L = GW.L


local windowsList = {}
local hasBeenLoaded = false
local hideCharframe = true
local moveDistance, heroFrameX, heroFrameY, heroFrameLeft, heroFrameTop, heroFrameNormalScale, heroFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0

windowsList[1] = {
    ['OnLoad'] = "LoadPaperDoll",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_character',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
    ["HeaderText"] = CHARACTER,
    ["Bindings"] = {
        ["TOGGLECHARACTER0"] = "PaperDoll",
        ["TOGGLECHARACTER3"] = "PetPaperDollFrame",
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
    ]=]
}

windowsList[2] = {
    ['OnLoad'] = "LoadReputation",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_reputation',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
    ["HeaderText"] = REPUTATION,
    ["Bindings"] = {
        ["TOGGLECHARACTER2"] = "Reputation"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
    ]=]
}

windowsList[3] = {
    ['OnLoad'] = "LoadTalents",
    ['SettingName'] = "USE_TALENT_WINDOW",
    ['TabIcon'] = 'tabicon-talents',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/talents-window-icon.png",
    ["HeaderText"] = TALENTS,
    ["Bindings"] = {
        ["TOGGLETALENTS"] = "Talents"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
    ]=]
}

windowsList[4] = {
    ['OnLoad'] = "LoadSpellBook",
    ['SettingName'] = "USE_SPELLBOOK_WINDOW",
    ['TabIcon'] = 'tabicon_spellbook',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon.png",
    ["HeaderText"] = SPELLS,
    ["Bindings"] = {
        ["TOGGLESPELLBOOK"] = "SpellBook",
        ["TOGGLEPETBOOK"] = "PetBook"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
    ]=]
}

windowsList[5] = {
    ['OnLoad'] = "LoadGlyphes",
    ['SettingName'] = "USE_TALENT_WINDOW",
    ['TabIcon'] = 'tabicon-glyph',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/glyph-window-icon.png",
    ["HeaderText"] = GLYPHS,
    ["Bindings"] = {
        ["TOGGLEINSCRIPTION"] = "Glyphes"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "glyphes")
    ]=]
}

windowsList[6] = {
    ["OnLoad"] = "LoadCurrency",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["TabIcon"] = "tabicon_currency",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon.png",
    ["HeaderText"] = CURRENCY,
    ["TooltipText"] = CURRENCY,
    ["Bindings"] = {
        ["TOGGLECURRENCY"] = "Currency"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
    ]=]
}

windowsList[8] = {
    ["OnLoad"] = "LoadProfessions",
    ["FrameName"] = "GwProfessionsDetailsFrame",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwProfessionsFrame",
    ["TabIcon"] = "tabicon_professions",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon.png",
    ["HeaderText"] = TRADE_SKILLS,
    ["TooltipText"] = TRADE_SKILLS,
    ["Bindings"] = {
        ["TOGGLEPROFESSIONBOOK"] = "Professions",
        ["TOGGLECHARACTER1"] = "Professions"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
    ]=]
}



-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = [=[
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
    elseif button == "Glyphes" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "glyphes")
    elseif button == "Currency" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "currency")
    elseif button == "Talents" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "talents")
    elseif button == "PetPaperDollFrame" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollpet")
    elseif button == "Titles" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "titles")
    elseif button == "GearSet" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "gearset")
    elseif button == "Equipemnt" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "equipment")
    elseif button == "Professions" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "professions")
    end
]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmDoll = self:GetFrameRef("GwCharacterWindowContainer")
    local fmDollMenu = self:GetFrameRef("GwHeroPanelMenu")
    local fmDollRepu = self:GetFrameRef("GwPaperReputationContainer")
    local fmDollPetCont = self:GetFrameRef("GwPetContainer")
    local fmDollDress = self:GetFrameRef("GwDressingRoom")
    local fmDollTitles = self:GetFrameRef("GwPaperTitles")
    local fmDollGearSets = self:GetFrameRef("GwPaperGearSets")
    local fmDollBagItemList = self:GetFrameRef("GwPaperDollBagItemList")

    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollTitles = false
    local showDollGearSets = false
    local showDollEquipment = false
    local showDollPetCont = false
    local fmSBM = self:GetFrameRef("GwSpellbook")
    local showSpell = false
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local showTal = false
    local fmGlyphes = self:GetFrameRef("GwGlyphesFrame")
    local showGlyphes = false
    local fmCurrency = self:GetFrameRef("GwCurrencyDetailsFrame")
    local showCurrency = false
    local fmProf = self:GetFrameRef("GwProfessionsFrame")
    local showProf = false

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
    elseif fmGlyphes ~= nil and value == "glyphes" then
        if keytoggle and fmGlyphes:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showGlyphes = true
        end
    elseif fmCurrency ~= nil and value == "currency" then
        if keytoggle and fmCurrency:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showCurrency = true
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
    elseif fmProf ~= nil and value == "professions" then
        if keytoggle and fmProf:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showProf = true
        end
    elseif fmDoll ~= nil and value == "paperdoll" then
        if keytoggle and fmDoll:IsVisible() and (not fmDollPetCont:IsVisible() and not fmDollTitles:IsVisible() and not fmDollGearSets:IsVisible() and not fmDollBagItemList:IsVisible()) then
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
    elseif fmDollTitles ~= nil and value == "titles" then
        if keytoggle and fmDollTitles:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollTitles = true
        end
    elseif fmDollGearSets ~= nil and value == "gearset" then
        if keytoggle and fmDollGearSets:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollGearSets = true
        end
    elseif fmDollBagItemList ~= nil and value == "equipment" then
        if keytoggle and fmDollBagItemList:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollEquipment = true
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
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
            fmDollBagItemList:Hide()
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
    if fmGlyphes then
        if showGlyphes and not close then
            fmGlyphes:Show()
        else
            fmGlyphes:Hide()
        end
    end
    if fmCurrency then
        if showCurrency and not close then
            fmCurrency:Show()
        else
            fmCurrency:Hide()
        end
    end
    if fmProf then
        if showProf and not close then
            fmProf:Show()
        else
            fmProf:Hide()
        end
    end
    if fmSBM then
        if showSpell and not close then
            fmSBM:Show()
        else
            fmSBM:Hide()
        end
    end
    if fmDollRepu then
        if showDollRepu and not close then
            fmDollRepu:Show()
        else
            fmDollRepu:Hide()
        end
    end
    if fmDollPetCont and showDollPetCont then
        if showDollPetCont and not close then
            fmDoll:Show()
            fmDollPetCont:Show()

            fmDollDress:Hide()
            fmDollMenu:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
            fmDollBagItemList:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollTitles and showDollTitles then
        if showDollTitles and not close then
            fmDoll:Show()
            fmDollTitles:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollGearSets and showDollGearSets then
        if showDollGearSets and not close then
            fmDoll:Show()
            fmDollGearSets:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollBagItemList:Hide()
        else
            fmDoll:Hide()
        end
    end

    if fmDollBagItemList and showDollEquipment then
        if showDollEquipment and not close then
            fmDoll:Show()
            fmDollBagItemList:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
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

local mover_OnDragStart = [=[
    if button ~= "LeftButton" then
        return
    end
    local f = self:GetParent()
    if self:GetAttribute("isMoving") then
        f:CallMethod("StopMovingOrSizing")
    end
    self:SetAttribute("isMoving", true)
    f:CallMethod("StartMoving")
]=]

local mover_OnDragStop = [=[
    if button ~= "LeftButton" then
        return
    end
    if not self:GetAttribute("isMoving") then
        return
    end
    self:SetAttribute("isMoving", false)
    local f = self:GetParent()
    f:CallMethod("StopMovingOrSizing")
    local x, y, _ = f:GetRect()

    -- re-anchor to UIParent after the move
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)

    -- store the updated position
    self:CallMethod("savePosition", x, y)
]=]

local charSecure_OnShow = [=[
    local keyEsc = GetBindingKey("TOGGLEGAMEMENU")
    if keyEsc ~= nil then
        self:SetBinding(false, keyEsc, "CLICK GwCharacterWindowClick:Close")
    end
]=]

local charSecure_OnHide = [=[
    self:ClearBindings()
]=]

local charCloseSecure_OnClick = [=[
    self:GetParent():SetAttribute("windowpanelopen", nil)
]=]

local function mover_SavePosition(self, x, y)
    local setting = self.onMoveSetting
    if setting then
        local pos = GW.settings[setting]
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "BOTTOMLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        GW.settings[setting] = pos
    end
end

local function click_OnEvent(self, event)
    if event ~= "UPDATE_BINDINGS" then
        return
    end
    ClearOverrideBindings(self)

    for _, win in pairs(windowsList) do
        if win.TabFrame and win.Bindings then
            for key, click in pairs(win.Bindings) do
                local keyBind, keyBind2 = GetBindingKey(key)
                if keyBind then
                    SetOverrideBinding(self, false, keyBind, "CLICK GwCharacterWindowClick:" .. click)
                end
                if keyBind2 then
                    SetOverrideBinding(self, false, keyBind2, "CLICK GwCharacterWindowClick:" .. click)
                end
            end
        end
    end
end


local function GetScaleDistance()
    local left, top = heroFrameLeft, heroFrameTop
    local scale = heroFrameEffectiveScale
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end

local function loadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true

    local fmGCW = CreateFrame('Button', 'GwCharacterWindow', UIParent, 'GwCharacterWindow')
    fmGCW.WindowHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    fmGCW.WindowHeader:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    fmGCW:SetAttribute('windowpanelopen', nil)
    fmGCW.secure:SetAttribute("_onclick", charSecure_OnClick)
    fmGCW.secure:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    fmGCW:SetAttribute("_onattributechanged", charSecure_OnAttributeChanged)
    fmGCW.SoundOpen = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    fmGCW.SoundSwap = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end
    fmGCW.SoundExit = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end

    -- secure hook ESC to close char window when it is showing
    fmGCW:WrapScript(fmGCW, "OnShow", charSecure_OnShow)
    fmGCW:WrapScript(fmGCW, "OnHide", charSecure_OnHide)

    -- the close button securely closes the char window
    fmGCW.close:SetAttribute("_onclick", charCloseSecure_OnClick)

    -- setup movable stuff
    local pos = GW.settings.HERO_POSITION
    local scale = GW.settings.HERO_POSITION_SCALE

    fmGCW:SetScale(scale)
    fmGCW:ClearAllPoints()
    fmGCW:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    fmGCW.mover.onMoveSetting = "HERO_POSITION"
    fmGCW.mover.savePosition = mover_SavePosition
    fmGCW.mover:SetAttribute("_onmousedown", mover_OnDragStart)
    fmGCW.mover:SetAttribute("_onmouseup", mover_OnDragStop)
    fmGCW.sizer.texture:SetDesaturated(true)
    fmGCW.sizer:SetScript("OnEnter", function(self)
        fmGCW.sizer.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, L["Scale with Right Click"])
        GameTooltip:Show()
    end)
    fmGCW.sizer:SetScript("OnLeave", function()
        fmGCW.sizer.texture:SetDesaturated(true)
        GameTooltip_Hide()
    end)
    fmGCW.sizer:SetFrameStrata(fmGCW:GetFrameStrata())
    fmGCW.sizer:SetFrameLevel(fmGCW:GetFrameLevel() + 15)
    fmGCW.sizer:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "RightButton" then
            return
        end
        heroFrameLeft, heroFrameTop = GwCharacterWindow:GetLeft(), GwCharacterWindow:GetTop()
        heroFrameNormalScale = GwCharacterWindow:GetScale()
        heroFrameX,heroFrameY = heroFrameLeft, heroFrameTop - (UIParent:GetHeight() / heroFrameNormalScale)
        heroFrameEffectiveScale = GwCharacterWindow:GetEffectiveScale()
        moveDistance = GetScaleDistance()
        self:SetScript("OnUpdate", function()
            local scale = GetScaleDistance() / moveDistance * heroFrameNormalScale
            if scale < 0.2 then scale = 0.2 elseif scale > 3.0 then scale = 3.0 end
            GwCharacterWindow:SetScale(scale)
            local s = heroFrameNormalScale / GwCharacterWindow:GetScale()
            local x = heroFrameX * s
            local y = heroFrameY * s
            GwCharacterWindow:ClearAllPoints()
            GwCharacterWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    fmGCW.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        GW.settings.HERO_POSITION_SCALE = GwCharacterWindow:GetScale()
        -- Save hero frame position
        local pos = GW.settingsHERO_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = GwCharacterWindow:GetPoint()
        GW.settings.HERO_POSITION = pos
        --Reset Model Camera
        GwDressingRoom.model:RefreshCamera()
    end)
    -- set binding change handlers
    fmGCW.secure:HookScript("OnEvent", function(self, event)
        GW.CombatQueue_Queue(nil, click_OnEvent, {self, event})
    end)
    fmGCW.secure:RegisterEvent("UPDATE_BINDINGS")
end

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.5, 1, 0, 0.625)
    end
end

local function createTabIcon(iconName, tabIndex)
    local f = CreateFrame('Button', nil, GwCharacterWindow, 'CharacterWindowTabSelect')
    f.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\' .. iconName .. ".png")
    f:SetPoint('TOP', GwCharacterWindow, 'TOPLEFT', -32, -25 + -((tabIndex - 1) * 45))
    setTabIconState(f, false)

    return f
end

local function styleCharacterMenuBackButton(fmBtn, key)
    fmBtn:SetText(key)
    GW.CharacterMenuButtonBack_OnLoad(fmBtn)
    fmBtn:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
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

local function CharacterMenuBlank_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover.png")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    self:ClearNormalTexture()
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
end
GW.CharacterMenuBlank_OnLoad = CharacterMenuBlank_OnLoad

local function CharacterMenuButton_OnLoad(self, odd, addGwHeroPanelFrameRef)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover.png")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if not odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg.png")
    end
    if self:GetFontString() then
        self:GetFontString():SetTextColor(1, 1, 1, 1)
        self:GetFontString():SetShadowColor(0, 0, 0, 0)
        self:GetFontString():SetShadowOffset(1, -1)
        self:GetFontString():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        self:GetFontString():SetJustifyH("LEFT")
        self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    end
    self.hover:SetAlpha(0)
    if addGwHeroPanelFrameRef then
        self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    end
end
GW.CharacterMenuButton_OnLoad = CharacterMenuButton_OnLoad

local function CharacterMenuButtonBack_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover.png")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    self:ClearNormalTexture()
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
end
GW.CharacterMenuButtonBack_OnLoad = CharacterMenuButtonBack_OnLoad

local nextShadow, nextAnchor
local function addAddonButton(name, setting, shadow, anchor, showFunction, hideOurFrame)
    if C_AddOns.IsAddOnLoaded(name) and (setting == nil or setting == true) then
        GwHeroPanelMenu[name] = CreateFrame("Button", nil, GwHeroPanelMenu, "SecureHandlerClickTemplate,GwCharacterMenuButtonTemplate")
        GwHeroPanelMenu[name]:SetText(select(2, C_AddOns.GetAddOnInfo(name)))
        GwHeroPanelMenu[name]:ClearAllPoints()
        GwHeroPanelMenu[name]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
        CharacterMenuButton_OnLoad(GwHeroPanelMenu[name], shadow)
        GwHeroPanelMenu[name]:SetFrameRef("charwin", GwCharacterWindow)
        GwHeroPanelMenu[name].ui_show = showFunction
        GwHeroPanelMenu[name]:SetAttribute("hideOurFrame", hideOurFrame)
        GwHeroPanelMenu[name]:SetAttribute("_onclick", [=[
            local fchar = self:GetFrameRef("charwin")
            local hideOurFrame = self:GetAttribute("hideOurFrame")
            if fchar and hideOurFrame == true then
                fchar:SetAttribute("windowpanelopen", nil)
            end
            self:CallMethod("ui_show")
        ]=])
        nextShadow = not nextShadow
        nextAnchor = GwHeroPanelMenu[name]

        if name == "GearQuipper-TBC" then
            GwHeroPanelMenu[name]:SetText("GearQuipper")
            GqUiFrame:ClearAllPoints()
            GqUiFrame:SetParent(GwCharacterWindow)
            GqUiFrame:SetPoint("TOPRIGHT", GwCharacterWindow, "TOPRIGHT", 350, -12)
        end
    end
end

local LoadCharWindowAfterCombat = CreateFrame("Frame", nil, UIParent)
local function LoadCharacter()
    if InCombatLockdown() then
        LoadCharWindowAfterCombat:SetScript(
            "OnUpdate",
            function()
                local inCombat = UnitAffectingCombat("player")
                if inCombat == true then
                    return
                end
                LoadCharacter()
                LoadCharWindowAfterCombat:SetScript("OnUpdate", nil)
            end)
        return
    end

    local anyThingToLoad = false
    for _, v in pairs(windowsList) do
        if GW.settings[v.SettingName] then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    loadBaseFrame()

    local fmGCW = GwCharacterWindow
    local tabIndex = 1
    for _, v in pairs(windowsList) do
        if GW.settings[v.SettingName] then
            local container = GW[v.OnLoad](fmGCW)
            local tab = createTabIcon(v.TabIcon, tabIndex)

            fmGCW:SetFrameRef(container:GetName(), container)
            container:SetScript("OnShow", container_OnShow)
            container:SetScript("OnHide", container_OnHide)
            tab:SetFrameRef('GwCharacterWindow', fmGCW)
            tab:SetAttribute('_OnClick', v.OnClick)

            container.TabFrame = tab
            container.CharWindow = fmGCW
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.HeaderText

            tab:SetScript("OnEnter", charTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            if container:GetName() == "GwCharacterWindowContainer" then
                fmGCW:SetFrameRef("GwHeroPanelMenu", GwHeroPanelMenu)
                fmGCW:SetFrameRef("GwPaperTitles", GwPaperTitles)
                fmGCW:SetFrameRef("GwDressingRoom", GwDressingRoom)
                fmGCW:SetFrameRef("GwPetContainer", GwPetContainer)
                fmGCW:SetFrameRef("GwPaperGearSets", GwPaperDollOutfits)
                fmGCW:SetFrameRef("GwPaperDollBagItemList", GwPaperDollBagItemList)

                CharacterMenuButton_OnLoad(GwHeroPanelMenu.titleMenu, true, true)
                CharacterMenuButton_OnLoad(GwHeroPanelMenu.gearMenu, false, true)
                CharacterMenuButton_OnLoad(GwHeroPanelMenu.equipmentMenu, true, true)
                CharacterMenuButton_OnLoad(GwHeroPanelMenu.petMenu, false, true)

                styleCharacterMenuBackButton(GwPaperTitles.backButton, CHARACTER .. ": " .. PAPERDOLL_SIDEBAR_TITLES)
                styleCharacterMenuBackButton(GwPaperDollOutfits.backButton, CHARACTER .. ":\n" .. EQUIPMENT_MANAGER)
                styleCharacterMenuBackButton(GwDressingRoomPet.backButton, CHARACTER .. ": " .. PET)
                styleCharacterMenuBackButton(GwPaperDollBagItemList.backButton, CHARACTER .. ": " .. BAG_FILTER_EQUIPMENT)

                -- add addon buttons here
                fmGCW:SetAttribute("myClassId", GW.myClassID)
                if GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6 then
                    nextShadow = true
                else
                    nextShadow = false
                end
                nextAnchor = (GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6) and GwHeroPanelMenu.petMenu or GwHeroPanelMenu.equipmentMenu
                addAddonButton("Outfitter", GW.settings.USE_CHARACTER_WINDOW, nextShadow, nextAnchor, function() hideCharframe = false Outfitter:OpenUI() end, true)
                addAddonButton("GearQuipper-TBC", GW.settings.USE_CHARACTER_WINDOW, nextShadow, nextAnchor, function() gearquipper:ToggleUI() end, false)
                addAddonButton("Clique", GW.settings.USE_SPELLBOOK_WINDOW, nextShadow, nextAnchor, function() ShowUIPanel(CliqueConfig) end, true)
                addAddonButton("Pawn", GW.settings.USE_CHARACTER_WINDOW, nextShadow, nextAnchor, PawnUIShow, false)

                GW.ToggleCharacterItemInfo(true)

                GwHeroPanelMenu.titleMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "titles")
                ]=])
                GwHeroPanelMenu.gearMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "gearset")
                ]=])
                GwHeroPanelMenu.equipmentMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "equipment")
                ]=])
                GwHeroPanelMenu.petMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollpet")
                ]=])
                GwPaperTitles.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwPaperDollOutfits.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwDressingRoomPet.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwPaperDollBagItemList.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])

                -- pet GwDressingRoom
                GwHeroPanelMenu.petMenu:SetAttribute("_onstate-petstate", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    local myClassId = f:GetAttribute("myClassId")
                    if myClassId == 3 or myClassId == 6 or myClassId == 9 then
                        self:Show()
                    else
                        self:Hide()
                    end
                    if newstate == "nopet" then
                        self:Disable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", false)
                    elseif newstate == "hasPet" then
                        self:Enable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", true)
                    end
                ]=])
                RegisterStateDriver(GwHeroPanelMenu.petMenu, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")
            end
            v.TabFrame = tab

            tabIndex = tabIndex + 1
        end
    end

    if GW.settings.USE_CHARACTER_WINDOW then
        CharacterFrame:SetScript("OnShow", function()
            if hideCharframe then
                HideUIPanel(CharacterFrame)
            end
            hideCharframe = true
        end)

        CharacterFrame:UnregisterAllEvents()
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    click_OnEvent(fmGCW.secure, "UPDATE_BINDINGS")
end
GW.LoadCharacter = LoadCharacter
