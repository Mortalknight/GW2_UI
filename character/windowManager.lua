local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local ClassIndex = GW.ClassIndex

local windowsList = {}
local hasBeenLoaded = false
local hideCharframe = true
local moveDistance, heroFrameX, heroFrameY, heroFrameLeft, heroFrameTop, heroFrameNormalScale, heroFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0
local nextHeroPanelMenuButtonShadowOdd = true
local prevAddonButtonAnchor = nil
local firstAddonMenuButtonAnchor

windowsList[1] = {
    ['OnLoad'] = "LoadPaperDoll",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_character',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon",
    ["HeaderText"] = CHARACTER,
    ["Bindings"] = {
        ["TOGGLECHARACTER0"] = "PaperDoll",
        ["TOGGLECHARACTER2"] = "Reputation",
        ["TOGGLECHARACTER1"] = "Skills",
        ["TOGGLECHARACTER3"] = "PetPaperDollFrame",
        ["TOGGLECHARACTER4"] = "Honor"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
    ]=]
}

windowsList[2] = {
    ['OnLoad'] = "LoadReputation",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_reputation',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon",
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
    ['SettingName'] = 'USE_TALENT_WINDOW',
    ['TabIcon'] = 'tabicon-talents',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/talents-window-icon",
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
    ['SettingName'] = 'USE_SPELLBOOK_WINDOW',
    ['TabIcon'] = 'tabicon_spellbook',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon",
    ["HeaderText"] = SPELLS,
    ["Bindings"] = {
        ["TOGGLESPELLBOOK"] = "SpellBook",
        ["TOGGLEPETBOOK"] = "PetBook"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
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
    elseif button == "Talents" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "talents")
    elseif button == "PetPaperDollFrame" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollpet")
    elseif button == "Skills" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollskills")
    elseif button == "Runes" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollengravings")
    elseif button == "Honor" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollhonor")
    end
]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmDoll = self:GetFrameRef("GwCharacterWindowContainer")
    local fmDollMenu = self:GetFrameRef("GwCharacterMenu")
    local fmDollRepu = self:GetFrameRef("GwPaperReputationContainer")
    local fmDollSkills = self:GetFrameRef("GwPaperSkills")
    local fmDollPetCont = self:GetFrameRef("GwPetContainer")
    local fmDollDress = self:GetFrameRef("GwDressingRoom")
    local fmDollHonor = self:GetFrameRef("GwPaperHonor")
    local fmDollEngravings = self:GetFrameRef("GwEngravingFrame")
    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollSkills = false
    local showDollEngavings = false
    local showDollHonor = false
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
        if keytoggle and fmDoll:IsVisible() and (not fmDollSkills:IsVisible() and not fmDollPetCont:IsVisible() and not fmDollHonor:IsVisible() and not fmDollEngravings:IsVisible()) then
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
    elseif fmDollEngravings ~= nil and value == "paperdollengravings" then
        if keytoggle and fmDollEngravings:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollEngavings = true
        end
    elseif fmDollHonor ~= nil and value == "paperdollhonor" then
        if keytoggle and fmDollHonor:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollHonor = true
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
            fmDollEngravings:Hide()
            fmDollPetCont:Hide()
            fmDollHonor:Hide()
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
    if fmDollRepu then
        if showDollRepu and not close then
            fmDollRepu:Show()
        else
            fmDollRepu:Hide()
        end
    end
    if fmDollSkills and showDollSkills then
        if showDollSkills and not close then
            fmDoll:Show()
            fmDollSkills:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollHonor:Hide()
            fmDollEngravings:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollEngravings and showDollEngavings then
        if showDollEngavings and not close then
            fmDoll:Show()
            fmDollEngravings:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollHonor:Hide()
            fmDollSkills:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollHonor and showDollHonor then
        if showDollHonor and not close then
            fmDoll:Show()
            fmDollHonor:Show()

            fmDollSkills:Hide()
            fmDollMenu:Hide()
            fmDollDress:Hide()
            fmDollPetCont:Hide()
            fmDollEngravings:Hide()
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
            fmDollMenu:Hide()
            fmDollHonor:Hide()
            fmDollEngravings:Hide()
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
        local pos = GetSetting(setting)
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "BOTTOMLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        SetSetting(setting, pos)
    end
end

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
GW.AddForProfiling("character", "click_OnEvent", click_OnEvent)

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
    fmGCW.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20, "")
    fmGCW.WindowHeader:SetTextColor(255/255, 241/255, 209/255)
    fmGCW:SetAttribute('windowpanelopen', nil)
    fmGCW.secure:SetAttribute("_onclick", charSecure_OnClick)
    fmGCW.secure:SetFrameRef("GwCharacterWindow", fmGCW)
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
    local pos = GetSetting("HERO_POSITION")
    local scale = GetSetting("HERO_POSITION_SCALE")

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
        heroFrameLeft, heroFrameTop = fmGCW:GetLeft(), fmGCW:GetTop()
        heroFrameNormalScale = fmGCW:GetScale()
        heroFrameX,heroFrameY = heroFrameLeft, heroFrameTop - (UIParent:GetHeight() / heroFrameNormalScale)
        heroFrameEffectiveScale = fmGCW:GetEffectiveScale()
        moveDistance = GetScaleDistance()
        self:SetScript("OnUpdate", function()
            local scale = GetScaleDistance() / moveDistance * heroFrameNormalScale
            if scale < 0.2 then scale = 0.2 elseif scale > 3.0 then scale = 3.0 end
            fmGCW:SetScale(scale)
            local s = heroFrameNormalScale / fmGCW:GetScale()
            local x = heroFrameX * s
            local y = heroFrameY * s
            fmGCW:ClearAllPoints()
            fmGCW:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    fmGCW.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        SetSetting("HERO_POSITION_SCALE", fmGCW:GetScale())
        -- Save hero frame position
        local pos = GetSetting("HERO_POSITION")
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = fmGCW:GetPoint()
        SetSetting("HERO_POSITION", pos)
        --Reset Model Camera
        GwDressingRoom.model:RefreshCamera()
    end)
    -- set binding change handlers
    fmGCW.secure:HookScript("OnEvent", function(self, event)
        GW.CombatQueue_Queue(click_OnEvent, {self, event})
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
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT,14, "")
        self:GetFontString():SetJustifyH('LEFT')
        self:GetFontString():SetPoint('LEFT',self,'LEFT',5,0)
    else
        self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        self:ClearNormalTexture()
        self:GetFontString():SetTextColor(1,1,1,1)
        self:GetFontString():SetShadowColor(0,0,0,0)
        self:GetFontString():SetShadowOffset(1,-1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT,14, "")
        self:GetFontString():SetJustifyH('LEFT')
        self:GetFontString():SetPoint('LEFT',self,'LEFT',5,0)
    end
    self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)

    nextHeroPanelMenuButtonShadowOdd = not nextHeroPanelMenuButtonShadowOdd
end

local function styleCharacterMenuBackButton(self)
    self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
    self:ClearNormalTexture()
    local fontString = self:GetFontString()
    fontString:SetTextColor(1,1,1,1)
    fontString:SetShadowColor(0,0,0,0)
    fontString:SetShadowOffset(1,-1)
    fontString:SetFont(DAMAGE_TEXT_FONT,14, "")
    self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
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

local function CharacterMenuButton_OnLoad(self, odd, addGwHeroPanelFrameRef)
    if odd == nil then
        odd = nextHeroPanelMenuButtonShadowOdd
    end
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if not odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end
    self:GetFontString():SetTextColor(1, 1, 1, 1)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14, "")
    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)

    if addGwHeroPanelFrameRef then
        self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    end

    nextHeroPanelMenuButtonShadowOdd = not nextHeroPanelMenuButtonShadowOdd
end
GW.CharacterMenuButton_OnLoad = CharacterMenuButton_OnLoad

local isFirstAddonButton = true
local function addAddonButton(name, setting, showFunction, hideOurFrame)
    if C_AddOns.IsAddOnLoaded(name) and (setting == nil or setting == true) then
        GwCharacterMenu[name] = CreateFrame("Button", nil, GwCharacterMenu, "SecureHandlerClickTemplate,GwCharacterMenuButtonTemplate")
        GwCharacterMenu[name]:SetText(select(2, C_AddOns.GetAddOnInfo(name)))
        GwCharacterMenu[name]:ClearAllPoints()
        GwCharacterMenu[name]:SetPoint("TOPLEFT", isFirstAddonButton and firstAddonMenuButtonAnchor or prevAddonButtonAnchor, "BOTTOMLEFT")
        CharacterMenuButton_OnLoad(GwCharacterMenu[name])
        GwCharacterMenu[name]:SetFrameRef("charwin", GwCharacterWindow)
        GwCharacterMenu[name].ui_show = showFunction
        GwCharacterMenu[name]:SetAttribute("hideOurFrame", hideOurFrame)
        GwCharacterMenu[name]:SetAttribute("_onclick", [=[
            local fchar = self:GetFrameRef("charwin")
            local hideOurFrame = self:GetAttribute("hideOurFrame")
            if fchar and hideOurFrame == true then
                fchar:SetAttribute("windowpanelopen", nil)
            end
            self:CallMethod("ui_show")
        ]=])
        prevAddonButtonAnchor = GwCharacterMenu[name]
        isFirstAddonButton = false
    end
end
-- Public API which can be used by other addons
GW.AddAddonMenuButtonToHeroPanelMenu = addAddonButton

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
    for k, v in pairs(windowsList) do
        if GetSetting(v.SettingName) then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    loadBaseFrame()

    local fmGCW = GwCharacterWindow
    local tabIndex = 1
    for k, v in pairs(windowsList) do
        if GetSetting(v.SettingName) then
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
                fmGCW:SetFrameRef("GwCharacterMenu", GwCharacterMenu)
                fmGCW:SetFrameRef("GwPaperHonor", GwPaperHonor)
                fmGCW:SetFrameRef("GwPaperSkills", GwPaperSkills)
                fmGCW:SetFrameRef("GwEngravingFrame", GwEngravingFrame)
                fmGCW:SetFrameRef("GwDressingRoom", GwDressingRoom)
                fmGCW:SetFrameRef("GwPetContainer", GwPetContainer)

                CharacterMenuButton_OnLoad(GwCharacterMenu.skillsMenu, nextHeroPanelMenuButtonShadowOdd, true)
                CharacterMenuButton_OnLoad(GwCharacterMenu.honorMenu, nextHeroPanelMenuButtonShadowOdd, true)
                CharacterMenuButton_OnLoad(GwCharacterMenu.runeMenu, nextHeroPanelMenuButtonShadowOdd, true)
                CharacterMenuButton_OnLoad(GwCharacterMenu.petMenu, nextHeroPanelMenuButtonShadowOdd, true)

                if not GW.ClassicSOD then
                    GwCharacterMenu.runeMenu:Hide()
                    GwCharacterMenu.petMenu:ClearAllPoints()
                    GwCharacterMenu.petMenu:SetPoint("TOPLEFT", GwCharacterMenu.honorMenu, "BOTTOMLEFT")

                    styleCharacterMenuButton(GwCharacterMenu.petMenu, nextHeroPanelMenuButtonShadowOdd)
                else
                    styleCharacterMenuButton(GwCharacterMenu.runeMenu, nextHeroPanelMenuButtonShadowOdd)
                    styleCharacterMenuButton(GwCharacterMenu.petMenu, nextHeroPanelMenuButtonShadowOdd)
                end
                styleCharacterMenuBackButton(GwPaperSkills.backButton)
                styleCharacterMenuBackButton(GwPaperHonor.backButton)
                styleCharacterMenuBackButton(GwEngravingFrame.backButton)
                styleCharacterMenuBackButton(GwDressingRoomPet.backButton)

                -- add addon buttons here
                firstAddonMenuButtonAnchor = GW.myClassID == ClassIndex.WARLOCK and GwCharacterMenu.petMenu or GW.myClassID  == ClassIndex.HUNTER and GwCharacterMenu.petMenu or GW.ClassicSOD and GwCharacterMenu.runeMenu or GwCharacterMenu.honorMenu

                if firstAddonMenuButtonAnchor ~= GwCharacterMenu.petMenu then
                    nextHeroPanelMenuButtonShadowOdd = not nextHeroPanelMenuButtonShadowOdd
                end

                addAddonButton("Outfitter", GetSetting("USE_CHARACTER_WINDOW"), function() hideCharframe = false Outfitter:OpenUI() end, true)
                addAddonButton("Clique", GetSetting("USE_SPELLBOOK_WINDOW"), function() ShowUIPanel(CliqueConfig) end, true)
                addAddonButton("Pawn", GetSetting("USE_CHARACTER_WINDOW"), PawnUIShow, false)
                addAddonButton("Ranker", GetSetting("USE_CHARACTER_WINDOW"), function() RankerMainFrame:SetParent(GwCharacterWindow); RankerMainFrame:ClearAllPoints(); RankerMainFrame:SetPoint("LEFT", GwCharacterWindow, "RIGHT", 0, 0) Ranker:ToggleWindow() end, false)

                GwCharacterMenu.skillsMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollskills")
                ]=])
                GwCharacterMenu.honorMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollhonor")
                ]=])
                GwCharacterMenu.runeMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollengravings")
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
                GwEngravingFrame.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwPaperHonor.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwDressingRoomPet.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])

                -- pet GwDressingRoom
                GwCharacterMenu.petMenu:SetAttribute("_onstate-petstate", [=[
                    if newstate == "nopet" then
                        self:Disable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", false)
                    elseif newstate == "hasPet" then
                        self:Enable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", true)
                    end
                ]=])
                RegisterStateDriver(GwCharacterMenu.petMenu, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")
            end
            v.TabFrame = tab

            tabIndex = tabIndex + 1
        end
    end

    if GetSetting("USE_CHARACTER_WINDOW") then
        CharacterFrame:SetScript("OnShow", function()
            if hideCharframe then
                HideUIPanel(CharacterFrame)
            end
            hideCharframe = true
        end)
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    click_OnEvent(fmGCW.secure, "UPDATE_BINDINGS")
end
GW.LoadCharacter = LoadCharacter
