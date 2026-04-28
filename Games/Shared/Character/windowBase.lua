---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Character window config model
--
-- Each game version keeps its own `windowManager.lua`, but the shared
-- character loader and secure handlers now consume a common data model.
--
-- 1. `windowsList`
--    Defines the top-level tabs that should be created for the active game
--    version.
--    Expected fields per entry:
--    - `OnLoad`: global loader function name called with the created container
--    - `FrameName`: global frame name for the created tab container
--    - `SettingName`: setting flag that controls whether the tab is enabled
--    - `RefName`: frame ref name registered on the character window
--    - `TabIcon`: icon texture key used for the side tab
--    - `HeaderIcon`: texture shown in the character window header
--    - `HeaderText`: title text shown in the character window header
--    - `TooltipText`: optional tooltip label for the side tab
--    - `Bindings`: optional keybind override table
--    - `OnClick`: secure click snippet that sets `windowpanelopen`
--
--    Add a new top-level tab by:
--    - adding a new entry to `windowsList`
--    - ensuring the frame is loaded in the tab's `OnLoad` function
--    - registering a matching frame ref name through `RefName`
--
-- 2. `charSecure_OnClick`
--    Built from `GW.BuildCharacterWindowClickHandler(buttonTargets)`.
--    This is the secure mapping from click/button names to
--    `windowpanelopen` state values.
--
--    `buttonTargets` format:
--    {
--        PaperDoll = "paperdoll",
--        Reputation = "reputation",
--        Titles = "titles",
--    }
--
--    Add a new secure button target by:
--    - adding the button name to this mapping
--    - pointing it to the state value that should be opened
--
-- 3. `charSecure_OnAttributeChanged`
--    Built from `GW.BuildCharacterWindowAttributeChangedHandler(config)`.
--    This defines how each `windowpanelopen` state shows/hides managed frames.
--
--    `managedRefs`:
--    - every frame ref the generated secure handler may access
--    - every ref used in `toggleRef`, `toggleHiddenRefs`, or `showRefs`
--      must be listed here
--
--    `states`:
--    - one entry per secure state
--    - supported fields:
--      `value`: single state name
--      `values`: multiple state names with identical behaviour
--      `toggleRef`: frame used for key-toggle close logic
--      `toggleHiddenRefs`: refs that must be hidden before the toggle-close
--         case is allowed
--      `requiresAttribute`: optional secure attribute gate, e.g. `HasPetUI`
--      `showRefs`: refs that should be visible for this state
--
--    Add a new managed subview by:
--    - making sure the frame exists and is registered via `SetFrameRef(...)`
--    - adding the ref to `managedRefs`
--    - adding a click mapping in `buttonTargets` if users must open it
--    - adding a `states` entry with the desired `value`, `toggleRef`, and
--      `showRefs`
--    - updating the base paperdoll state's `toggleHiddenRefs` if the new
--      state is another paperdoll subview
--
-- Example state:
-- {
--     value = "gearset",
--     toggleRef = "GwPaperDollOutfits",
--     showRefs = {"GwPaperDoll", "GwPaperDollOutfits", "GwDressingRoom"},
-- }

local moveDistance, heroFrameX, heroFrameY, heroFrameLeft, heroFrameTop, heroFrameNormalScale, heroFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0
local characterWindowHeroPanelMenu
local nextAddonMenuButtonShadowOdd = true
local nextAddonMenuButtonAnchor
local characterWindowConfig

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
    if not setting then
        return
    end

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

local function click_OnEvent(self, event, windowsList)
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

local function LoadCharacterWindowBase(secureOnClick, secureOnAttributeChanged, windowsList)
    if GwCharacterWindow then
        return GwCharacterWindow
    end

    local frame = CreateFrame("Frame", "GwCharacterWindow", UIParent, "GwCharacterWindowTemplate")
    frame.WindowHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    frame.WindowHeader:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    frame:SetClampedToScreen(true)
    frame:SetClampRectInsets(-GwCharacterWindowLeft:GetWidth(), 0, GwCharacterWindowHeader:GetHeight(), 0)

    frame:SetAttribute("windowpanelopen", nil)
    frame.secure:SetAttribute("_onclick", secureOnClick)
    frame.secure:SetFrameRef("GwCharacterWindow", frame)
    frame:SetAttribute("_onattributechanged", secureOnAttributeChanged)
    frame.SoundOpen = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    frame.SoundSwap = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end
    frame.SoundExit = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end

    frame.backgroundMask = UIParent:CreateMaskTexture()
    frame.backgroundMask:SetPoint("TOPLEFT", frame, "TOPLEFT", -64, 64)
    frame.backgroundMask:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -64, 0)
    frame.backgroundMask:SetTexture(
        "Interface/AddOns/GW2_UI/textures/masktest.png",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )

    frame.background:AddMaskTexture(frame.backgroundMask)
    GwCharacterWindowHeader:AddMaskTexture(frame.backgroundMask)
    GwCharacterWindowHeaderRight:AddMaskTexture(frame.backgroundMask)
    GwCharacterWindowLeft:AddMaskTexture(frame.backgroundMask)

    GW.SetupCharacterPanelSwitchAnimation(frame)
    GW.SetupCharacterWindowRevealAnimation(frame)

    frame:WrapScript(frame, "OnShow", charSecure_OnShow)
    frame:WrapScript(frame, "OnHide", charSecure_OnHide)
    frame.close:SetAttribute("_onclick", charCloseSecure_OnClick)

    local pos = GW.settings.HERO_POSITION
    local scale = GW.settings.HERO_POSITION_SCALE
    frame:SetScale(scale)
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    frame.mover.onMoveSetting = "HERO_POSITION"
    frame.mover.savePosition = mover_SavePosition
    frame.mover:SetAttribute("_onmousedown", mover_OnDragStart)
    frame.mover:SetAttribute("_onmouseup", mover_OnDragStop)

    frame.sizer.texture:SetDesaturated(true)
    frame.sizer:SetScript("OnEnter", function(self)
        frame.sizer.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, L["Scale with Right Click"])
        GameTooltip:Show()
    end)
    frame.sizer:SetScript("OnLeave", function()
        frame.sizer.texture:SetDesaturated(true)
        GameTooltip_Hide()
    end)
    frame.sizer:SetFrameStrata(frame:GetFrameStrata())
    frame.sizer:SetFrameLevel(frame:GetFrameLevel() + 15)
    frame.sizer:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "RightButton" then
            return
        end

        heroFrameLeft, heroFrameTop = frame:GetLeft(), frame:GetTop()
        heroFrameNormalScale = frame:GetScale()
        heroFrameX, heroFrameY = heroFrameLeft, heroFrameTop - (UIParent:GetHeight() / heroFrameNormalScale)
        heroFrameEffectiveScale = frame:GetEffectiveScale()
        if heroFrameEffectiveScale == 0 then
            heroFrameEffectiveScale = UIParent:GetEffectiveScale()
        end
        moveDistance = GW.GetScaledCursorDistance(heroFrameLeft, heroFrameTop, heroFrameEffectiveScale)

        self:SetScript("OnUpdate", function()
            local newScale = GW.GetScaledCursorDistance(heroFrameLeft, heroFrameTop, heroFrameEffectiveScale) / moveDistance * heroFrameNormalScale
            if newScale < 0.2 then
                newScale = 0.2
            elseif newScale > 3.0 then
                newScale = 3.0
            end

            frame:SetScale(newScale)
            local scaleRatio = heroFrameNormalScale / frame:GetScale()
            local x = heroFrameX * scaleRatio
            local y = heroFrameY * scaleRatio
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    frame.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        GW.settings.HERO_POSITION_SCALE = frame:GetScale()

        local savedPos = GW.settings.HERO_POSITION
        if savedPos then
            wipe(savedPos)
        else
            savedPos = {}
        end
        savedPos.point, _, savedPos.relativePoint, savedPos.xOfs, savedPos.yOfs = frame:GetPoint()
        GW.settings.HERO_POSITION = savedPos

        if frame.dressingRoom and frame.dressingRoom.model then
            frame.dressingRoom.model:RefreshCamera()
        elseif _G.GwDressingRoom and GwDressingRoom.model then
            GwDressingRoom.model:RefreshCamera()
        end
    end)

    frame.secure:HookScript("OnEvent", function(self, event)
        GW.CombatQueue:Queue("character_update_keybind", click_OnEvent, {self, event, windowsList})
    end)
    frame.secure:RegisterEvent("UPDATE_BINDINGS")
    frame.UpdateBindings = function()
        click_OnEvent(frame.secure, "UPDATE_BINDINGS", windowsList)
    end
    frame.SetHeroPanelMenu = function(_, menuFrame)
        characterWindowHeroPanelMenu = menuFrame
    end


    frame.SetNextAddonMenuButtonShadowState = function(_, odd)
        nextAddonMenuButtonShadowOdd = odd == true
    end

    frame.SetNextAddonMenuButtonAnchor = function(_, anchor)
        nextAddonMenuButtonAnchor = anchor
    end

    return frame
end

function GW.BuildCharacterWindowClickHandler(buttonTargets)
    local sortedButtons = {}
    for buttonName in pairs(buttonTargets) do
        sortedButtons[#sortedButtons + 1] = buttonName
    end
    table.sort(sortedButtons)

    local lines = {
        "    local f = self:GetFrameRef(\"GwCharacterWindow\")",
        "    if button == \"Close\" then",
        "        f:SetAttribute(\"windowpanelopen\", nil)",
    }

    for _, buttonName in ipairs(sortedButtons) do
        lines[#lines + 1] = "    elseif button == " .. string.format("%q", buttonName) .. " then"
        lines[#lines + 1] = "        f:SetAttribute(\"keytoggle\", true)"
        lines[#lines + 1] = "        f:SetAttribute(\"windowpanelopen\", " .. string.format("%q", buttonTargets[buttonName]) .. ")"
    end

    lines[#lines + 1] = "    end"

    return table.concat(lines, "\n")
end

local function SanitizeCharacterWindowRefName(refName)
    return (refName:gsub("[^%w]", "_"))
end

local function QuoteSecureValue(value)
    if type(value) == "boolean" then
        return value and "true" or "false"
    elseif type(value) == "number" then
        return tostring(value)
    end

    return string.format("%q", value)
end

function GW.BuildCharacterWindowAttributeChangedHandler(config)
    local managedRefs = config.managedRefs or {}
    local attributeNames = {}

    for _, state in ipairs(config.states) do
        if state.requiresAttribute and not attributeNames[state.requiresAttribute] then
            attributeNames[state.requiresAttribute] = true
        end
    end

    local lines = {
        "    if name ~= \"windowpanelopen\" then",
        "        return",
        "    end",
        "",
        "    local selected = value",
        "    local keytoggle = self:GetAttribute(\"keytoggle\")",
        "    local close = true",
    }

    for attributeName in pairs(attributeNames) do
        lines[#lines + 1] = "    local attr_" .. SanitizeCharacterWindowRefName(attributeName) .. " = self:GetAttribute(" .. QuoteSecureValue(attributeName) .. ")"
    end

    for _, refName in ipairs(managedRefs) do
        lines[#lines + 1] = "    local ref_" .. SanitizeCharacterWindowRefName(refName) .. " = self:GetFrameRef(" .. QuoteSecureValue(refName) .. ")"
    end

    if next(attributeNames) ~= nil or #managedRefs > 0 then
        lines[#lines + 1] = ""
    end

    local function refVar(refName)
        return "ref_" .. SanitizeCharacterWindowRefName(refName)
    end

    for index, state in ipairs(config.states) do
        local conditions = {}
        local showSet = {}

        if state.values then
            local valueConditions = {}
            for _, stateValue in ipairs(state.values) do
                valueConditions[#valueConditions + 1] = "selected == " .. QuoteSecureValue(stateValue)
            end
            conditions[#conditions + 1] = "(" .. table.concat(valueConditions, " or ") .. ")"
        elseif state.value then
            conditions[#conditions + 1] = "selected == " .. QuoteSecureValue(state.value)
        end

        if state.toggleRef then
            conditions[#conditions + 1] = refVar(state.toggleRef) .. " ~= nil"
        end

        if state.requiresAttribute then
            local expectedValue = state.requiresAttributeValue
            if expectedValue == nil then
                expectedValue = true
            end
            conditions[#conditions + 1] = "attr_" .. SanitizeCharacterWindowRefName(state.requiresAttribute) .. " == " .. QuoteSecureValue(expectedValue)
        end

        lines[#lines + 1] = (index == 1 and "    if " or "    elseif ") .. table.concat(conditions, " and ") .. " then"

        if state.toggleRef then
            local toggleChecks = {refVar(state.toggleRef) .. ":IsVisible()"}
            for _, hiddenRef in ipairs(state.toggleHiddenRefs or {}) do
                toggleChecks[#toggleChecks + 1] = "(not " .. refVar(hiddenRef) .. " or not " .. refVar(hiddenRef) .. ":IsVisible())"
            end

            lines[#lines + 1] = "        if keytoggle and " .. table.concat(toggleChecks, " and ") .. " then"
            lines[#lines + 1] = "            self:SetAttribute(\"keytoggle\", nil)"
            lines[#lines + 1] = "            self:SetAttribute(\"windowpanelopen\", nil)"
            lines[#lines + 1] = "            return"
            lines[#lines + 1] = "        end"
        end

        lines[#lines + 1] = "        close = false"

        for _, refName in ipairs(state.showRefs or {}) do
            showSet[refName] = true
            lines[#lines + 1] = "        if " .. refVar(refName) .. " then " .. refVar(refName) .. ":Show() end"
        end

        for _, refName in ipairs(managedRefs) do
            if not showSet[refName] then
                lines[#lines + 1] = "        if " .. refVar(refName) .. " then " .. refVar(refName) .. ":Hide() end"
            end
        end
    end

    lines[#lines + 1] = "    end"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "    if keytoggle then"
    lines[#lines + 1] = "        self:SetAttribute(\"keytoggle\", nil)"
    lines[#lines + 1] = "    end"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "    if close then"
    lines[#lines + 1] = "        self:Hide()"
    lines[#lines + 1] = "        self:CallMethod(\"SoundExit\")"
    lines[#lines + 1] = "    elseif not self:IsVisible() then"
    lines[#lines + 1] = "        self:Show()"
    lines[#lines + 1] = "        self:CallMethod(\"SoundOpen\")"
    lines[#lines + 1] = "    else"
    lines[#lines + 1] = "        self:CallMethod(\"SoundSwap\")"
    lines[#lines + 1] = "        self:CallMethod(\"AnimatePanelSwitch\", selected)"
    lines[#lines + 1] = "    end"

    return table.concat(lines, "\n")
end

function GW.RegisterCharacterWindowConfig(config)
    characterWindowConfig = config
end

function GW.LoadCharacter()
    local config = characterWindowConfig
    if not config then
        return
    end

    if InCombatLockdown() then
        GW.CombatQueue:Queue("load_character_window", GW.LoadCharacterWindowsFromList, {config.windowsList, config.charSecure_OnClick, config.charSecure_OnAttributeChanged})
        return
    end

    local anyThingToLoad = false
    for _, v in pairs(config.windowsList) do
        if GW.settings[v.SettingName] then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    local baseFrame = LoadCharacterWindowBase(config.charSecure_OnClick, config.charSecure_OnAttributeChanged, config.windowsList)
    local tabIndex = 1
    for _, v in pairs(config.windowsList) do
        if GW.settings[v.SettingName] then
            local container = CreateFrame("Frame", v.FrameName, baseFrame, "GwCharacterTabContainerTemplate")
            local tab = GW.CreateCharacterWindowTabIcon(v.TabIcon, tabIndex)

            baseFrame:SetFrameRef(v.RefName, container)
            container.TabFrame = tab
            container.CharWindow = baseFrame
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.TooltipText or v.HeaderText

            tab:SetScript("OnEnter", GW.CharacterWindowTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            v.TabFrame = tab
            tab:SetFrameRef("GwCharacterWindow", baseFrame)
            tab:SetAttribute("_onclick", v.OnClick)
            container:SetScript("OnShow", GW.CharacterWindowContainer_OnShow)
            container:SetScript("OnHide", GW.CharacterWindowContainer_OnHide)

            GW[v.OnLoad](container)
            baseFrame.dressingRoom = container.dressingRoom or baseFrame.dressingRoom

            tabIndex = tabIndex + 1
        end
    end

    baseFrame.UpdateBindings()
end

function GW.SetCharacterWindowTabIconState(self, enabled)
    if enabled then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.505, 1, 0, 0.625)
    end
end

function GW.CreateCharacterWindowTabIcon(iconName, tabIndex)
    local tab = CreateFrame("Button", nil, GwCharacterWindow, "GwCharacterTabSelectTemplate")
    tab.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/" .. iconName .. ".png")
    tab:SetPoint("TOP", GwCharacterWindow, "TOPLEFT", -32, -25 + -((tabIndex - 1) * 45))
    GW.SetCharacterWindowTabIconState(tab, false)
    return tab
end

function GW.CharacterWindowContainer_OnShow(self)
    GW.SetCharacterWindowTabIconState(self.TabFrame, true)
    self.CharWindow.windowIcon:SetTexture(self.HeaderIcon)
    self.CharWindow.WindowHeader:SetText(self.HeaderText)
    if self.TabFrame then
        GW.PlayCharacterTabSwitchPulse(self.TabFrame)
    end
end

function GW.CharacterWindowContainer_OnHide(self)
    GW.SetCharacterWindowTabIconState(self.TabFrame, false)
    if self.TabFrame then
        GW.ResetCharacterTabSwitchPulse(self.TabFrame)
    end
end

function GW.CharacterWindowTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end

function GW.CharacterMenuBlank_OnLoad(self)
    self.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    self.limitHoverStripAmount = 1
    self:ClearNormalTexture()

    local fontString = self:GetFontString()
    if not fontString then
        return
    end

    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
end

function GW.CharacterMenuButton_OnLoad(self, odd, addGwHeroPanelFrameRef)
    self.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    self.limitHoverStripAmount = 1
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    end

    local fontString = self:GetFontString()
    if fontString then
        fontString:SetJustifyH("LEFT")
        fontString:SetPoint("LEFT", self, "LEFT", 5, 0)
    end

    if addGwHeroPanelFrameRef then
        self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    end
end

function GW.CharacterMenuButtonBack_OnLoad(self, key, setFrameRef)
    self:SetText(key)
    self.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    self.limitHoverStripAmount = 1
    self:ClearNormalTexture()

    local fontString = self:GetFontString()
    if not fontString then
        return
    end

    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)

    if setFrameRef then
        self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    end
end

function GW.SetCharacterWindowOpenAttribute(button, target, keytoggle)
    if not button or not target then
        return
    end

    button:SetAttribute("_onclick", ([=[
        local f = self:GetFrameRef("GwCharacterWindow")
        if %s then
            f:SetAttribute("keytoggle", true)
        end
        f:SetAttribute("windowpanelopen", "%s")
    ]=]):format(keytoggle == false and "false" or "true", target))
end

function GW.SetCharacterWindowBackAttribute(button, target, keytoggle)
    GW.SetCharacterWindowOpenAttribute(button, target or "paperdoll", keytoggle)
end

local function CreateAddonMenuButton(options)
    if options.createdButton then
        return options.createdButton
    end
    local button = CreateFrame("Button", nil, characterWindowHeroPanelMenu, "SecureHandlerClickTemplate,GwCharacterPanelMenuButtonTemplate")
    button:SetText(options.label or select(2, C_AddOns.GetAddOnInfo(options.name)))
    button:ClearAllPoints()

    if nextAddonMenuButtonAnchor then
        button:SetPoint("TOPLEFT", nextAddonMenuButtonAnchor, "BOTTOMLEFT")
    else
        button:SetPoint("TOPLEFT", characterWindowHeroPanelMenu, "TOPLEFT")
    end

    GW.CharacterMenuButton_OnLoad(button, nextAddonMenuButtonShadowOdd)
    nextAddonMenuButtonShadowOdd = not nextAddonMenuButtonShadowOdd
    nextAddonMenuButtonAnchor = button
    button:SetFrameRef("charwin", GwCharacterWindow)
    button.ui_show = options.showFunction
    button:SetAttribute("hideOurFrame", options.hideOurFrame)
    button:SetAttribute("_onclick", [=[
        local fchar = self:GetFrameRef("charwin")
        local hideOurFrame = self:GetAttribute("hideOurFrame")
        if fchar and hideOurFrame == true then
            fchar:SetAttribute("windowpanelopen", nil)
        end
        self:CallMethod("ui_show")
    ]=])

    if options.onCreated then
        options.onCreated(button)
    end

    options.createdButton = button

    return button
end

local function IsAddonMenuButtonSettingDisabled(options)
    return options.setting ~= nil and options.setting ~= true
end

local function AddAddonMenuButtonAfterLoad(options)
    GW.RegisterLoadHook(function()
        if InCombatLockdown() then
            GW.CombatQueue:Queue(nil, CreateAddonMenuButton, {options})
        else
            CreateAddonMenuButton(options)
        end
    end, options.name)
end

function GW.AddAddonMenuButtonToHeroPanelMenu(options)
    if not characterWindowHeroPanelMenu or not options or not options.name or IsAddonMenuButtonSettingDisabled(options) then
        return
    end
    if not C_AddOns.IsAddOnLoaded(options.name) then
        AddAddonMenuButtonAfterLoad(options)
        return
    end

    return CreateAddonMenuButton(options)
end
