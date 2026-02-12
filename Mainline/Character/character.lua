local _, GW = ...
local L = GW.L

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
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
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
    ["OnLoad"] = "LoadProfessions",
    ["FrameName"] = "GwProfessionsDetailsFrame",
    ["SettingName"] = "USE_PROFESSION_WINDOW",
    ["RefName"] = "GwProfessionsFrame",
    ["TabIcon"] = "tabicon_professions",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon.png",
    ["HeaderText"] = TRADE_SKILLS,
    ["TooltipText"] = TRADE_SKILLS,
    ["Bindings"] = {
        ["TOGGLEPROFESSIONBOOK"] = "Professions"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
    ]=]
}

windowsList[3] = {
    ["OnLoad"] = "LoadCurrency",
    ["FrameName"] = "GwCurrencyDetailsFrame",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwCurrencyFrame",
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

windowsList[4] = {
    ["OnLoad"] = "LoadReputation",
    ["FrameName"] = "GwReputationDetailsFrame",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["RefName"] = "GwReputationFrame",
    ["TabIcon"] = "tabicon_reputation",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/reputation-window-icon.png",
    ["HeaderText"] = REPUTATION,
    ["TooltipText"] = REPUTATION,
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
    elseif button == "Professions" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "professions")
    end
    ]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then return end

    -- frames
    local doll = self:GetFrameRef("GwPaperDoll")
    local rep = self:GetFrameRef("GwReputationFrame")
    local cur = self:GetFrameRef("GwCurrencyFrame")
    local prof = self:GetFrameRef("GwProfessionsFrame")

    local keytoggle = self:GetAttribute("keytoggle")
    local selected = value

    if selected == "paperdoll" or selected == "character" then
        if doll then
            if keytoggle and doll:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                doll:Show()
            end
        end
        if rep then
            rep:Hide()
        end
        if cur then
            cur:Hide()
        end
        if prof then
            prof:Hide()
        end
    elseif selected == "reputation" then
        if rep then
            if keytoggle and rep:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                rep:Show()
            end
        end
        if doll then
            doll:Hide()
        end
        if cur then
            cur:Hide()
        end
        if prof then
            prof:Hide()
        end
    elseif selected == "currency" then
        if cur then
            if keytoggle and cur:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                cur:Show()
            end
        end
        if doll then
            doll:Hide()
        end
        if rep then
            rep:Hide()
        end
        if prof then
            prof:Hide()
        end
    elseif selected == "professions" then
        if prof then
            if keytoggle and prof:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                prof:Show()
            end
        end
        if doll then
            doll:Hide()
        end
        if rep then
            rep:Hide()
        end
        if cur then
            cur:Hide()
        end
    else
        self:Hide()
        self:CallMethod("SoundExit")
    end

    if keytoggle then
        self:SetAttribute("keytoggle", nil)
    end

    if not self:IsVisible() and value then
        self:Show()
        self:CallMethod("SoundOpen")
    elseif value then
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

local function LoadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true 

    -- create the character window and secure bind its tab open/close functions
    local fmGCW = CreateFrame("Frame", "GwCharacterWindow", UIParent, "GwCharacterWindowTemplate")
    fmGCW:SetClampedToScreen(true)
    fmGCW:SetClampRectInsets(-GwCharacterWindowLeft:GetWidth(), 0, GwCharacterWindowHeader:GetHeight(), 0)
    fmGCW.WindowHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    fmGCW.WindowHeader:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
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
        "Interface/AddOns/GW2_UI/textures/masktest.png",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )

    fmGCW.background:AddMaskTexture(fmGCW.backgroundMask)
    GwCharacterWindowHeader:AddMaskTexture(fmGCW.backgroundMask)
    GwCharacterWindowHeaderRight:AddMaskTexture(fmGCW.backgroundMask)
    GwCharacterWindowLeft:AddMaskTexture(fmGCW.backgroundMask)

    fmGCW:HookScript("OnShow",function(self)
        GW.AddToAnimation("HERO_PANEL_ONSHOW", 0, 1, GetTime(), GW.WINDOW_FADE_DURATION,
        function(p)
            self:SetAlpha(p)
            if self.dressingRoom and self.dressingRoom.model then
                self.dressingRoom.model:SetAlpha(math.max(0, (p - 0.5) / 0.5))
            end
            self.backgroundMask:SetPoint("BOTTOMRIGHT", self.background, "BOTTOMLEFT", lerp(-64, self.background:GetWidth(), p) , 0)
        end, 1, function()
            self.backgroundMask:SetPoint("TOPLEFT", self.background, "TOPLEFT", -64, 64)
            self.backgroundMask:SetPoint("BOTTOMRIGHT", self.background, "BOTTOMLEFT",-64, 0)
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
        heroFrameLeft, heroFrameTop = fmGCW:GetLeft(), fmGCW:GetTop()
        heroFrameNormalScale = fmGCW:GetScale()
        heroFrameX,heroFrameY = heroFrameLeft, heroFrameTop - (UIParent:GetHeight() / heroFrameNormalScale)
        heroFrameEffectiveScale = fmGCW:GetEffectiveScale()
        if heroFrameEffectiveScale == 0 then
            heroFrameEffectiveScale = UIParent:GetEffectiveScale()
        end
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
        GW.settings.HERO_POSITION_SCALE = fmGCW:GetScale()
        -- Save hero frame position
        local pos = GW.settings.HERO_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = fmGCW:GetPoint()
        GW.settings.HERO_POSITION = pos
        --Reset Model Camera
        fmGCW.dressingRoom.model:RefreshCamera()
    end)

    -- set binding change handlers
    fmGCW.secure:HookScript("OnEvent", function(self, event)
        GW.CombatQueue_Queue("character_update_keybind", click_OnEvent, {self, event})
    end)
    fmGCW.secure:RegisterEvent("UPDATE_BINDINGS")

    -- hook into inventory currency button
    --if GwCurrencyIcon then
    --    GwCurrencyIcon:SetFrameRef("fmGCW", fmGCW)
    --end

    return fmGCW
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
    f.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\" .. iconName .. ".png")
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
    GameTooltip_SetTitle(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end


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

    local baseFrame = LoadBaseFrame()

    local tabIndex = 1
    for _, v in pairs(windowsList) do
        if GW.settings[v.SettingName] then
            local container = CreateFrame("Frame", v.FrameName, baseFrame, "GwCharacterTabContainer")
            local tab = createTabIcon(v.TabIcon, tabIndex)

            baseFrame:SetFrameRef(v.RefName, container)
            container.TabFrame = tab
            container.CharWindow = baseFrame
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.TooltipText

            tab:SetScript("OnEnter", charTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            v.TabFrame = tab
            tab:SetFrameRef("GwCharacterWindow", baseFrame)
            tab:SetAttribute("_onclick", v.OnClick)
            container:SetScript("OnShow", container_OnShow)
            container:SetScript("OnHide", container_OnHide)

            GW[v.OnLoad](container)

            tabIndex = tabIndex + 1
        end
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    click_OnEvent(baseFrame.secure, "UPDATE_BINDINGS")
end
GW.LoadCharacter = LoadCharacter

-- stuff for standard menu functionality
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

local function CharacterMenuButton_OnLoad(self, odd)
    if odd == nil then
        odd = GW.nextHeroPanelMenuButtonShadowOdd
    end

    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover.png")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg.png")
    end

    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    GW.nextHeroPanelMenuButtonShadowOdd = not GW.nextHeroPanelMenuButtonShadowOdd
end
GW.CharacterMenuButton_OnLoad = CharacterMenuButton_OnLoad

local function CharacterMenuButtonBack_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover.png")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    self:ClearNormalTexture()

end
GW.CharacterMenuButtonBack_OnLoad = CharacterMenuButtonBack_OnLoad
