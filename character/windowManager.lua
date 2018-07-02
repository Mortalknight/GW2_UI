local _, GW = ...
local GetSetting = GW.GetSetting

local windowsList = {}
local hasBeenLoaded = false

windowsList[1] = {}
windowsList[1]["ONLOAD"] = GW.LoadCharacter
windowsList[1]["SETTING_NAME"] = "USE_CHARACTER_WINDOW"
windowsList[1]["TAB_ICON"] = "tabicon_character"
windowsList[1]["ONCLICK"] =
    [=[
    self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
]=]

windowsList[2] = {}
windowsList[2]["ONLOAD"] = GW.LoadTalents
windowsList[2]["SETTING_NAME"] = "USE_TALENT_WINDOW"
windowsList[2]["TAB_ICON"] = "tabicon_spellbook"
windowsList[2]["ONCLICK"] =
    [=[
    self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
]=]

-- turn click events (geneated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick =
    [=[
    --print("secure click handler button: " .. button)
    if button == "Close" then
        self:SetAttribute("windowpanelopen", nil)
    elseif button == "PaperDoll" then
        self:SetAttribute("windowpanelopen", "paperdoll")
    elseif button == "Reputation" then
        self:SetAttribute("windowpanelopen", "paperdoll")
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
    --print("name", name, "value", value)
    local fmCon = self:GetFrameRef("GwCharacterWindowContainer")
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local fmMov = self:GetFrameRef("GwCharacterWindowMoverFrame")

    if value == "talents" then
        if fmTal ~= nil and fmTal:IsVisible() then
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            fmCon:Hide()
            fmTal:Show()
        end
    elseif value == "paperdoll" then
        if fmCon ~= nil and fmCon:IsVisible() then
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            fmCon:Show()
            fmTal:Hide()
        end
    else
        -- close window
        fmCon:Hide()
        fmTal:Hide()
        fmMov:Hide()
        self:Hide()
        return
    end

    if not self:IsVisible() then
        self:Show()
        fmMov:Show()
    end
    ]=]

-- securely hook ESC to close char window while it is showing
local charSecure_OnShow =
    [=[
    local keyEsc = GetBindingKey("TOGGLEGAMEMENU")
    if keyEsc ~= nil then
        self:SetBinding(false, keyEsc, "CLICK GwCharacterWindow:Close")
    end
    ]=]

-- remove ESC hook so it does default stuff when char window not showing
local charSecure_OnHide = [=[
    self:ClearBindings()
    ]=]

-- the close button securely closes the char window
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

    if CharacterWindowTab1 then
        local keyPaperDoll = GetBindingKey("TOGGLECHARACTER0")
        local keyReputation = GetBindingKey("TOGGLECHARACTER2")
        if keyPaperDoll ~= nil then
            SetOverrideBinding(self, false, keyPaperDoll, "CLICK GwCharacterWindow:PaperDoll")
        end
        if keyReputation ~= nil then
            SetOverrideBinding(self, false, keyReputation, "CLICK GwCharacterWindow:Reputation")
        end
    end

    if CharacterWindowTab2 then
        local keySpellbook = GetBindingKey("TOGGLESPELLBOOK")
        local keyTalents = GetBindingKey("TOGGLETALENTS")
        if keySpellbook ~= nil then
            SetOverrideBinding(self, false, keySpellbook, "CLICK GwCharacterWindow:SpellBook")
        end
        if keyTalents ~= nil then
            SetOverrideBinding(self, false, keyTalents, "CLICK GwCharacterWindow:Talents")
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
    fmGCW:WrapScript(fmGCW, "OnShow", charSecure_OnShow)
    fmGCW:WrapScript(fmGCW, "OnHide", charSecure_OnHide)
    fmGCW.close:SetAttribute("_onclick", charCloseSecure_OnClick)
end

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.5, 1, 0, 0.625)
    end
end

local function createTabIcon(iconName, tabIndex)
    local f =
        CreateFrame(
        "Button",
        "CharacterWindowTab" .. tabIndex,
        GwCharacterWindow,
        "SecureHandlerClickTemplate,CharacterWindowTabSelect"
    )

    f.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\" .. iconName)

    f:SetPoint("TOP", GwCharacterWindow, "TOPLEFT", -32, -25 + -((tabIndex - 1) * 45))

    setTabIconState(f, false)

    return f
end

local function LoadCharacterWM()
    local anyThingToLoad = false
    for k, v in pairs(windowsList) do
        if GetSetting(v["SETTING_NAME"]) then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    loadBaseFrame()

    local tabIndex = 1
    for k, v in pairs(windowsList) do
        if GetSetting(v["SETTING_NAME"]) then
            local ref = v["ONLOAD"]()

            GwCharacterWindow:SetFrameRef(ref:GetName(), ref)

            local f = createTabIcon(v["TAB_ICON"], tabIndex)
            tabIndex = tabIndex + 1
            f:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
            f:SetAttribute("_onclick", v["ONCLICK"])

            ref:HookScript(
                "OnShow",
                function()
                    setTabIconState(f, true)
                end
            )
            ref:HookScript(
                "OnHide",
                function()
                    setTabIconState(f, false)
                end
            )
        end
    end

    mover_OnEvent(GwCharacterWindowMoverFrame, "UPDATE_BINDINGS")
end
GW.LoadCharacterWM = LoadCharacterWM
