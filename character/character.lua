local _, GW = ...
local L = GW.L
local AddToAnimation = GW.AddToAnimation
local lerp = GW.lerp
local windowsList = {}
local hasBeenLoaded = false
local moveDistance, heroFrameX, heroFrameY, heroFrameLeft, heroFrameTop, heroFrameNormalScale, heroFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0

windowsList[1] = {
    ["OnLoad"] = "LoadPaperDoll",
    ["FrameName"] = "GwPaperDollDetailsFrame",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwPaperDoll",
    ["TabIcon"] = "tabicon_character",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon",
    ["HeaderText"] = CHARACTER,
    ["TooltipText"] = CHARACTER_BUTTON,
    ["Bindings"] = {
        ["TOGGLECHARACTER0"] = "PaperDoll"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
    ]=]
}

windowsList[2] = {
    ["OnLoad"] = "LoadSpellbook",
    ["FrameName"] = "GwSpellbookDetailsFrame",
    ["SettingName"] = "USE_SPELLBOOK_WINDOW",
    ["RefName"] = "GwSpellbookFrame",
    ["TabIcon"] = "tabicon_spellbook",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon",
    ["HeaderText"] = SPELLS,
    ["TooltipText"] = SPELLS,
    ["Bindings"] = {
        ["TOGGLESPELLBOOK"] = "SpellBook",

        ["TOGGLEPETBOOK"] = "PetBook"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
    ]=]
}

windowsList[3] = {
    ["OnLoad"] = "LoadProfessions",
    ["FrameName"] = "GwProfessionsDetailsFrame",
    ["SettingName"] = "USE_TALENT_WINDOW",
    ["RefName"] = "GwProfessionsFrame",
    ["TabIcon"] = "tabicon_professions",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon",
    ["HeaderText"] = TRADE_SKILLS,
    ["TooltipText"] = TRADE_SKILLS,
    ["Bindings"] = {
        ["TOGGLEPROFESSIONBOOK"] = "Professions"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
    ]=]
}

windowsList[4] = {
    ["OnLoad"] = "LoadCurrency",
    ["FrameName"] = "GwCurrencyDetailsFrame",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwCurrencyFrame",
    ["TabIcon"] = "tabicon_currency",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon",
    ["HeaderText"] = CURRENCY,
    ["TooltipText"] = CURRENCY,
    ["Bindings"] = {
        ["TOGGLECURRENCY"] = "Currency"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
    ]=]
}

windowsList[5] = {
    ["OnLoad"] = "LoadReputation",
    ["FrameName"] = "GwReputationyDetailsFrame",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwReputationFrame",
    ["TabIcon"] = "tabicon_reputation",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/reputation-window-icon",
    ["HeaderText"] = REPUTATION,
    ["TooltipText"] = REPUTATION,
    ["Bindings"] = {
        ["TOGGLECHARACTER2"] = "Reputation"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
    ]=]
}

--[[
windowsList[6] = {
    ["OnLoad"] = "LoadTalents",
    ["FrameName"] = "GwTalentDetailsFrame",
    ["SettingName"] = "USE_TALENT_WINDOW",
    ["RefName"] = "GwTalentFrame",
    ["TabIcon"] = "tabicon_spellbook",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon",
    ["HeaderText"] = TALENTS,
    ["TooltipText"] = TALENTS_BUTTON,
    ["Bindings"] = {

    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
    ]=]
}
]]

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
    elseif button == "Currency" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "currency")
    elseif button == "SpellBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "spellbook")
    elseif button == "Talents" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "talents")
    elseif button == "PetBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "petbook")
    elseif button == "Professions" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "professions")
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
    local fmSBM = self:GetFrameRef("GwSpellbookMenu")
    local fmSpell = self:GetFrameRef("GwSpellbookFrame")
    local showSpell = flase
    local fmTaM = self:GetFrameRef("GwTalentsMenu")
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local showTal = flase
    local fmRep = self:GetFrameRef("GwReputationFrame")
    local showRep = flase
    local fmCur = self:GetFrameRef("GwCurrencyFrame")
    local showCur = flase
    local fmProf = self:GetFrameRef("GwProfessionsFrame")
    local showProf = false

    local close = false
    local keytoggle = self:GetAttribute("keytoggle")

    if fmSpell ~= nil and value == "spellbook" then
        if keytoggle and fmSpell:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmTal ~= nil and value == "talents" then
        if keytoggle and fmTal:IsVisible() and fmTaM and fmTaM:GetAttribute("tabopen") == 1 then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showTal = true
            fmTaM:SetAttribute("tabopen", 1)
        end
    elseif fmSpell ~= nil and value == "spellbook" then
        if keytoggle and fmSpell:IsVisible() and fmSBM and fmSBM:GetAttribute("tabopen") == 2 then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
            fmSBM:SetAttribute("tabopen", 2)
        end
    elseif fmSpell ~= nil and value == "petbook" then
        if keytoggle and fmSpell:IsVisible() and fmSBM and fmSBM:GetAttribute("tabopen") == 5 then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
            fmSBM:SetAttribute("tabopen", 5)
        end
    elseif fmProf ~= nil and value == "professions" then
        if keytoggle and fmProf:IsVisible() then -- and fmSBM and fmSBM:GetAttribute("tabopen") == 4 then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showProf = true
            -- fmSBM:SetAttribute("tabopen", 4)
        end
    elseif fmDoll ~= nil and value == "paperdoll" then
        if keytoggle and fmDoll:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDoll = true
        end
    elseif fmRep ~= nil and value == "reputation" then
        if keytoggle and fmRep:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showRep = true
        end
    elseif fmCur ~= nil and value == "currency" then
        if keytoggle and fmCur:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showCur = true
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
        else
            fmDoll:Hide()
        end
    end
    if fmSpell then
        if showSpell and not close then
            fmSpell:Show()
        else
            fmSpell:Hide()
        end
    end
    if fmTal then
        if showTal and not close then
            fmTal:Show()
        else
            fmTal:Hide()
        end
    end
    if fmProf then
        if showProf and not close then
            fmProf:Show()
        else
            fmProf:Hide()
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
        self:Hide()
        self:CallMethod("SoundExit")
    elseif not self:IsVisible() then
        self:Show()
        self:CallMethod("SoundOpen")
    else
        self:CallMethod("SoundSwap")
    end
    ]=]

local charSecure_OnShow =
    [=[
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
GW.AddForProfiling("character", "mover_SavePosition", mover_SavePosition)

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

    -- create the character window and secure bind its tab open/close functions
    local fmGCW = CreateFrame("Frame", "GwCharacterWindow", UIParent, "GwCharacterWindowTemplate")
    fmGCW:SetClampedToScreen(true)
    fmGCW.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    fmGCW.WindowHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fmGCW:SetAttribute("windowpanelopen", nil)
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

    fmGCW.backgroundMask = UIParent:CreateMaskTexture()
    fmGCW.backgroundMask:SetPoint("TOPLEFT", fmGCW, "TOPLEFT", -64, 64)
    fmGCW.backgroundMask:SetPoint("BOTTOMRIGHT", fmGCW, "BOTTOMLEFT",-64, 0)
    fmGCW.backgroundMask:SetTexture(
        "Interface/AddOns/GW2_UI/textures/masktest",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )

    fmGCW.background:AddMaskTexture(fmGCW.backgroundMask)
    GwCharacterWindowHeader:AddMaskTexture(fmGCW.backgroundMask)
    GwCharacterWindowHeaderRight:AddMaskTexture(fmGCW.backgroundMask)
    GwCharacterWindowLeft:AddMaskTexture(fmGCW.backgroundMask)

    fmGCW:HookScript("OnShow",function()
        AddToAnimation("HERO_PANEL_ONSHOW", 0, 1, GetTime(), GW.WINDOW_FADE_DURATION,
        function(p)
            fmGCW:SetAlpha(p)
            if GwDressingRoom and GwDressingRoom.model then
                GwDressingRoom.model:SetAlpha(math.max(0, (p - 0.5) / 0.5))
            end
            fmGCW.backgroundMask:SetPoint("BOTTOMRIGHT", fmGCW.background, "BOTTOMLEFT", lerp(-64, fmGCW.background:GetWidth(), p) , 0)
        end, 1, function()
            fmGCW.backgroundMask:SetPoint("TOPLEFT", fmGCW.background, "TOPLEFT", -64, 64)
            fmGCW.backgroundMask:SetPoint("BOTTOMRIGHT", fmGCW.background, "BOTTOMLEFT",-64, 0)
        end)
    end)

    -- the close button securely closes the char window
    fmGCW.close:SetAttribute("_onclick", charCloseSecure_OnClick)

    -- setup movable stuff and scale
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
        local pos = GW.settings.HERO_POSITION
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
        GW.CombatQueue_Queue("character_update_keybind", click_OnEvent, {self, event})
    end)
    fmGCW.secure:RegisterEvent("UPDATE_BINDINGS")

    -- hook into inventory currency button
    --if GwCurrencyIcon then
    --    GwCurrencyIcon:SetFrameRef("GwCharacterWindow", fmGCW)
    --end
end
GW.AddForProfiling("character", "loadBaseFrame", loadBaseFrame)

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.505, 1, 0, 0.625)
    end
end
GW.AddForProfiling("character", "setTabIconState", setTabIconState)

local function createTabIcon(iconName, tabIndex)
    local f = CreateFrame("Button", nil, GwCharacterWindow, "GwCharacterTabSelect")
    f.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\" .. iconName)
    f:SetPoint("TOP", GwCharacterWindow, "TOPLEFT", -32, -25 + -((tabIndex - 1) * 45))
    setTabIconState(f, false)
    return f
end
GW.AddForProfiling("character", "createTabIcon", createTabIcon)

local function container_OnShow(self)
    setTabIconState(self.TabFrame, true)
    self.CharWindow.windowIcon:SetTexture(self.HeaderIcon)
    self.CharWindow.WindowHeader:SetText(self.HeaderText)
end
GW.AddForProfiling("character", "container_OnShow", container_OnShow)

local function container_OnHide(self)
    setTabIconState(self.TabFrame, false)
end
GW.AddForProfiling("character", "container_OnHide", container_OnHide)

local function charTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end
GW.AddForProfiling("character", "charTab_OnEnter", charTab_OnEnter)

local function LoadCharacter()
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

    local tabIndex = 1
    for _, v in pairs(windowsList) do
        if GW.settings[v.SettingName] then
            local container = CreateFrame("Frame", v.FrameName, GwCharacterWindow, "GwCharacterTabContainer")
            local tab = createTabIcon(v.TabIcon, tabIndex)

            GwCharacterWindow:SetFrameRef(v.RefName, container)
            container.TabFrame = tab
            container.CharWindow = GwCharacterWindow
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.TooltipText

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

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    click_OnEvent(GwCharacterWindow.secure, "UPDATE_BINDINGS")
end
GW.LoadCharacter = LoadCharacter

-- stuff for standard menu functionality
local function CharacterMenuBlank_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    self:ClearNormalTexture()
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:SetFont(DAMAGE_TEXT_FONT, 14)
end
GW.CharacterMenuBlank_OnLoad = CharacterMenuBlank_OnLoad

local function CharacterMenuButton_OnLoad(self, odd)
    if odd == nil then
        odd = GW.nextHeroPanelMenuButtonShadowOdd
    end

    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end
    self:GetFontString():SetTextColor(1, 1, 1, 1)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    GW.nextHeroPanelMenuButtonShadowOdd = not GW.nextHeroPanelMenuButtonShadowOdd
end
GW.CharacterMenuButton_OnLoad = CharacterMenuButton_OnLoad

local function CharacterMenuButtonBack_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    self:ClearNormalTexture()
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:SetFont(DAMAGE_TEXT_FONT, 14)
end
GW.CharacterMenuButtonBack_OnLoad = CharacterMenuButtonBack_OnLoad
