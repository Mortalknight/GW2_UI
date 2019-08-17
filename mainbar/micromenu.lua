local _, GW = ...
local GetSetting = GW.GetSetting
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation

local microButtonFrame

local function updateGuildButton(self, event)
    if event ~= "GUILD_ROSTER_UPDATE" then
        return
    end

    local gmb = GuildMicroButton
    if gmb == nil then
        return
    end

    local _, _, numOnlineMembers = GetNumGuildMembers()

    if numOnlineMembers ~= nil and numOnlineMembers > 0 then
        gmb.GwNotifyDark:Show()

        if numOnlineMembers > 9 then
            gmb.GwNotifyText:SetText(numOnlineMembers)
        else
            gmb.GwNotifyText:SetText(numOnlineMembers .. " ")
        end
        gmb.GwNotifyText:Show()
    else
        gmb.GwNotifyDark:Hide()
        gmb.GwNotifyText:Hide()
    end
end
GW.AddForProfiling("micromenu", "updateGuildButton", updateGuildButton)

local function updateInventoryButton()
    local bmb = GwBagMicroButton
    if bmb == nil then
        return
    end

    local totalEmptySlots = 0
    for i = 0, 4 do
        local numberOfFreeSlots, _ = GetContainerNumFreeSlots(i)

        if numberOfFreeSlots ~= nil then
            totalEmptySlots = totalEmptySlots + numberOfFreeSlots
        end
    end

    bmb.GwNotifyDark:Show()
    if totalEmptySlots > 9 then
        bmb.GwNotifyText:SetText(totalEmptySlots)
    else
        bmb.GwNotifyText:SetText(totalEmptySlots .. " ")
    end
    bmb.GwNotifyText:Show()
end
GW.AddForProfiling("micromenu", "updateInventoryButton", updateInventoryButton)

local function microMenuFrameShow(f, name)
    StopAnimation(name)
    StopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = true
    AddToAnimation(
        name,
        0,
        1,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        nil
    )
    AddToAnimation(
        "GwHudArtFrameMenuBackDrop",
        0,
        1,
        GetTime(),
        0.1,
        function()
            GwHudArtFrameMenuBackDrop:SetAlpha(animations["GwHudArtFrameMenuBackDrop"]["progress"])
        end,
        nil,
        nil
    )
end
GW.AddForProfiling("micromenu", "microMenuFrameShow", microMenuFrameShow)

local function microMenuFrameHide(f, name)
    StopAnimation(name)
    StopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = false
    AddToAnimation(
        name,
        1,
        0,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        nil
    )
    AddToAnimation(
        "GwHudArtFrameMenuBackDrop",
        1,
        0,
        GetTime(),
        0.1,
        function()
            GwHudArtFrameMenuBackDrop:SetAlpha(animations["GwHudArtFrameMenuBackDrop"]["progress"])
        end,
        nil,
        nil
    )
end
GW.AddForProfiling("micromenu", "microMenuFrameHide", microMenuFrameHide)

local function microMenu_OnUpdate(self, elapsed)
    self.gw_LastFadeCheck = self.gw_LastFadeCheck - elapsed
    if self.gw_LastFadeCheck > 0 then
        return
    end
    self.gw_LastFadeCheck = 0.1
    if not self:IsShown() then
        return
    end

    if self:IsMouseOver(100, -100, -100, 100) then
        if not self.gw_FadeShowing then
            microMenuFrameShow(self, self:GetName())
        end
    elseif self.gw_FadeShowing then
        microMenuFrameHide(self, self:GetName())
    end
end
GW.AddForProfiling("micromenu", "microMenu_OnUpdate", microMenu_OnUpdate)

local function gwMicro_PositionAlert(alert)
    if
        (alert ~= CollectionsMicroButtonAlert and alert ~= LFDMicroButtonAlert and alert ~= EJMicroButtonAlert and
            alert ~= StoreMicroButtonAlert and
            alert ~= CharacterMicroButtonAlert and
            alert ~= TalentMicroButtonAlert)
     then
        return
    end
    alert.Arrow:ClearAllPoints()
    alert.Arrow:SetPoint("BOTTOMLEFT", alert, "TOPLEFT", 4, -4)
    alert:ClearAllPoints()
    alert:SetPoint("TOPLEFT", alert.GwMicroButton, "BOTTOMLEFT", -18, -20)
end
GW.AddForProfiling("micromenu", "gwMicro_PositionAlert", gwMicro_PositionAlert)

local function modifyMicroAlert(alert, microButton)
    alert.GwMicroButton = microButton
    alert.Arrow.Arrow:SetTexCoord(0.78515625, 0.99218750, 0.58789063, 0.54687500)
    alert.Arrow.Glow:SetTexCoord(0.40625000, 0.66015625, 0.82812500, 0.77343750)
    alert.Arrow.Glow:ClearAllPoints()
    alert.Arrow.Glow:SetPoint("BOTTOM")

    alert.Arrow:ClearAllPoints()
    alert.Arrow:SetPoint("BOTTOMLEFT", alert, "TOPLEFT", 4, -4)
    alert:ClearAllPoints()
    alert:SetPoint("TOPLEFT", microButton, "BOTTOMLEFT", -18, -20)
end
GW.AddForProfiling("micromenu", "modifyMicroAlert", modifyMicroAlert)

local function reskinMicroButton(btn, name)
    GW.Debug("reskin micro", name)
    btn:SetParent(GwMicroButtonFrame)

    local tex = "Interface/AddOns/GW2_UI/textures/" .. name .. "-Up"

    btn:SetSize(24, 24)
    btn:SetDisabledTexture(tex)
    btn:SetNormalTexture(tex)
    btn:SetPushedTexture(tex)
    btn:SetHighlightTexture(tex)

    if btn.Flash then
        -- hide the flash frames off-screen
        btn.Flash:ClearAllPoints()
        btn.Flash:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -40, 440)
    end

    btn.GwNotify = btn:CreateTexture(nil, "OVERLAY")
    btn.GwNotifyDark = btn:CreateTexture(nil, "OVERLAY")
    btn.GwNotifyText = btn:CreateFontString(nil, "OVERLAY")

    btn.GwNotify:SetSize(18, 18)
    btn.GwNotify:SetPoint("CENTER", btn, "BOTTOM", 6, 3)
    btn.GwNotify:SetTexture("Interface/AddOns/GW2_UI/textures/notification-backdrop")
    btn.GwNotify:SetVertexColor(1, 0, 0, 1)
    btn.GwNotify:Hide()

    btn.GwNotifyDark:SetSize(18, 18)
    btn.GwNotifyDark:SetPoint("CENTER", btn, "BOTTOM", 6, 3)
    btn.GwNotifyDark:SetTexture("Interface/AddOns/GW2_UI/textures/notification-backdrop")
    btn.GwNotifyDark:SetVertexColor(0, 0, 0, 0.7)
    btn.GwNotifyDark:Hide()

    btn.GwNotifyText:SetSize(24, 24)
    btn.GwNotifyText:SetPoint("CENTER", btn, "BOTTOM", 7, 2)
    btn.GwNotifyText:SetFont(DAMAGE_TEXT_FONT, 12)
    btn.GwNotifyText:SetTextColor(1, 1, 1, 1)
    btn.GwNotifyText:SetShadowColor(0, 0, 0, 0)
    btn.GwNotifyText:Hide()
end
GW.AddForProfiling("micromenu", "reskinMicroButton", reskinMicroButton)

local function reskinMicroButtons()
    for i = 1, #MICRO_BUTTONS do
        local name = MICRO_BUTTONS[i]
        local btn = _G[name]
        if btn then
            reskinMicroButton(btn, name)
        end
    end
    if GwBagMicroButton then
        reskinMicroButton(GwBagMicroButton, "BagMicroButton")
    end
    if GwCharacterMicroButton then
        reskinMicroButton(GwCharacterMicroButton, "CharacterMicroButton")
    end
    if GwTalentMicroButton then
        reskinMicroButton(GwTalentMicroButton, "TalentMicroButton")
    end
end
GW.AddForProfiling("micromenu", "reskinMicroButtons", reskinMicroButtons)

local function disableMicroButton(btn, hideOnly)
    if hideOnly then
        -- hide it off-screen but still want events to run for alerts/notifications
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -40, 40)
    else
        btn:Disable()
        btn:UnregisterAllEvents()
        btn:SetScript("OnUpdate", nil)
        btn:Hide()
    end
end

local function setupMicroButtons()
    -- CharacterMicroButton
    -- we must determine if we are using the default char button (for default char window) or
    -- if we need to use our own char button for the custom hero panel
    local cref
    if GetSetting("USE_CHARACTER_WINDOW") then
        cref = GwCharacterMicroButton
        cref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        cref:SetAttribute(
            "_onclick",
            [=[
            local f = self:GetFrameRef("GwCharacterWindow")
            f:SetAttribute("keytoggle", "1")
            f:SetAttribute("windowpanelopen", "paperdoll")
            ]=]
        )

        disableMicroButton(CharacterMicroButton, true)
        CharacterMicroButton.GwSetAnchorPoint = function(self)
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -40, 40)
        end
    else
        cref = CharacterMicroButton
        MicroButtonPortrait:Hide()

        disableMicroButton(GwCharacterMicroButton)
    end
    cref.GwSetAnchorPoint = function(self)
        -- this must also happen in the auto-layout update hook which is why we do it like this
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", GwMicroButtonFrame, "TOPLEFT", 5, -3)
    end
    cref:GwSetAnchorPoint()

    -- GwBagMicroButton (custom)
    GwBagMicroButton:ClearAllPoints()
    GwBagMicroButton:SetPoint("BOTTOMLEFT", cref, "BOTTOMRIGHT", 4, 0)
    GwBagMicroButton:HookScript(
        "OnClick",
        function()
            ToggleAllBags()
        end
    )
    GwBagMicroButton.interval = 0
    GwBagMicroButton:HookScript(
        "OnUpdate",
        function(self, elapsed)
            self.interval = self.interval - elapsed
            if self.interval > 0 then
                return
            end

            self.interval = 0.5
            updateInventoryButton()
        end
    )

    -- we must determine if we are using the default spell & talent buttons or if we need to
    -- use our own talent button for the custom hero panel
    local tref
    if GetSetting("USE_TALENT_WINDOW") then
        -- TalentMicroButton
        tref = GwTalentMicroButton
        tref:ClearAllPoints()
        tref:SetPoint("BOTTOMLEFT", GwBagMicroButton, "BOTTOMRIGHT", 4, 0)

        tref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        tref:SetAttribute(
            "_onclick",
            [=[
            local f = self:GetFrameRef("GwCharacterWindow")
            f:SetAttribute("keytoggle", "1")
            f:SetAttribute("windowpanelopen", "talents")
            ]=]
        )

        disableMicroButton(SpellbookMicroButton)
        disableMicroButton(TalentMicroButton, true)
    else
        -- SpellbookMicroButton
        SpellbookMicroButton:ClearAllPoints()
        SpellbookMicroButton:SetPoint("BOTTOMLEFT", GwBagMicroButton, "BOTTOMRIGHT", 4, 0)

        -- TalentMicroButton
        tref = TalentMicroButton
        tref:ClearAllPoints()
        tref:SetPoint("BOTTOMLEFT", SpellbookMicroButton, "BOTTOMRIGHT", 4, 0)

        disableMicroButton(GwTalentMicroButton)
    end

    -- AchievementMicroButton
    AchievementMicroButton:ClearAllPoints()
    AchievementMicroButton:SetPoint("BOTTOMLEFT", tref, "BOTTOMRIGHT", 4, 0)

    -- QuestLogMicroButton
    QuestLogMicroButton:ClearAllPoints()
    QuestLogMicroButton:SetPoint("BOTTOMLEFT", AchievementMicroButton, "BOTTOMRIGHT", 4, 0)

    -- GuildMicroButton
    GuildMicroButton:ClearAllPoints()
    GuildMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)
    GuildMicroButtonTabard:Hide()
    GuildMicroButton.interval = 0
    GuildMicroButton:SetScript(
        "OnUpdate",
        function(self, elapsed)
            if self.interval > 0 then
                self.interval = self.interval - elapsed
                return
            end
            self.interval = 15.0
            GuildRoster()
        end
    )
    GuildMicroButton:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildMicroButton:HookScript("OnEvent", updateGuildButton)
    updateGuildButton()

    -- LFDMicroButton
    LFDMicroButton.GwSetAnchorPoint = function(self)
        -- this must also happen in the auto-layout update hook which is why we do it like this
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", 4, 0)
    end
    LFDMicroButton:GwSetAnchorPoint()

    -- EJMicroButton
    EJMicroButton:ClearAllPoints()
    EJMicroButton:SetPoint("BOTTOMLEFT", LFDMicroButton, "BOTTOMRIGHT", 4, 0)

    -- CollectionsMicroButton
    CollectionsMicroButton:ClearAllPoints()
    CollectionsMicroButton:SetPoint("BOTTOMLEFT", EJMicroButton, "BOTTOMRIGHT", 4, 0)

    -- MainMenuMicroButton
    MainMenuMicroButton:ClearAllPoints()
    MainMenuMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
    MainMenuBarPerformanceBar:Hide()
    MainMenuBarDownload:Hide()
    MainMenuMicroButton:HookScript(
        "OnUpdate",
        function()
            -- the main menu button routinely updates its texture based on streaming download
            -- status and net performance; we undo those changes here on each update interval
            local m = MainMenuMicroButton
            if m.updateInterval ~= PERFORMANCEBAR_UPDATE_INTERVAL then
                return
            end
            m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/MainMenuMicroButton-Up")
            m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/MainMenuMicroButton-Up")
            m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/MainMenuMicroButton-Up")
            m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/MainMenuMicroButton-Up")
            MainMenuBarPerformanceBar:Hide()
            MainMenuBarDownload:Hide()
        end
    )

    -- HelpMicroButton
    HelpMicroButton:ClearAllPoints()
    HelpMicroButton:SetPoint("BOTTOMLEFT", MainMenuMicroButton, "BOTTOMRIGHT", 4, 0)

    -- StoreMicroButton
    StoreMicroButton:ClearAllPoints()
    StoreMicroButton:SetPoint("BOTTOMLEFT", HelpMicroButton, "BOTTOMRIGHT", 4, 0)
end
GW.AddForProfiling("micromenu", "setupMicroButtons", setupMicroButtons)

local function LoadMicroMenu()
    -- create our micro button container frame
    microButtonFrame = CreateFrame("Frame", "GwMicroButtonFrame", UIParent, "GwMicroButtonFrame")

    -- create a custom micro button for inventory, character, and talents
    CreateFrame("Button", "GwBagMicroButton", UIParent, "MainMenuBarMicroButton")
    GwBagMicroButton.tooltipText = MicroButtonTooltipText(INVENTORY_TOOLTIP, "OPENALLBAGS")
    GwBagMicroButton.newbieText = nil

    CreateFrame("Button", "GwCharacterMicroButton", UIParent, "SecureHandlerClickTemplate,MainMenuBarMicroButton")
    GwCharacterMicroButton.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
    GwCharacterMicroButton.newbieText = NEWBIE_TOOLTIP_CHARACTER

    CreateFrame("Button", "GwTalentMicroButton", UIParent, "SecureHandlerClickTemplate,MainMenuBarMicroButton")
    GwTalentMicroButton.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
    GwTalentMicroButton.newbieText = NEWBIE_TOOLTIP_TALENTS

    -- reskin all default (and custom) micro buttons to our styling
    reskinMicroButtons()

    -- re-do anchoring of the micro buttons to our preferred ordering and setup
    -- custom button overrides & behaviors for each button where necessary
    setupMicroButtons()

    -- get rid of the super-persistent PvP talent selector alert
    if not TalentMicroButton:HasTalentAlertToShow() then
        TalentMicroButtonAlert:Hide()
    end
    hooksecurefunc(
        "MainMenuMicroButton_ShowAlert",
        function(f, t)
            if f == TalentMicroButtonAlert and not TalentMicroButton:HasTalentAlertToShow() then
                f:Hide()
            end
        end
    )

    -- undo micro button position and visibility changes done by the auto-layout stuff
    hooksecurefunc(
        "UpdateMicroButtonsParent",
        function()
            for i = 1, #MICRO_BUTTONS do
                _G[MICRO_BUTTONS[i]]:SetParent(GwMicroButtonFrame)
            end
        end
    )
    hooksecurefunc(
        "MoveMicroButtons",
        function()
            if CharacterMicroButton.GwSetAnchorPoint then
                CharacterMicroButton:GwSetAnchorPoint()
            end
            if LFDMicroButton.GwSetAnchorPoint then
                LFDMicroButton:GwSetAnchorPoint()
            end
        end
    )
    hooksecurefunc(
        "UpdateMicroButtons",
        function()
            HelpMicroButton:Show()
            MicroButtonPortrait:Hide()
        end
    )
    hooksecurefunc(
        "GuildMicroButton_UpdateTabard",
        function()
            GuildMicroButtonTabard:Hide()
            local m = GuildMicroButton
            m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
            m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
            m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
            m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
        end
    )

    -- if set to fade micro menu, add fader
    if GetSetting("FADE_MICROMENU") then
        microButtonFrame.gw_LastFadeCheck = -1
        microButtonFrame.gw_FadeShowing = true
        microButtonFrame:SetScript("OnUpdate", microMenu_OnUpdate)
    end

    -- fix alert positions and hide the micromenu bar
    MicroButtonAndBagsBar:Hide()
    MicroButtonAndBagsBar:SetMovable(1)
    MicroButtonAndBagsBar:SetUserPlaced(true)
    MicroButtonAndBagsBar:SetMovable(0)
    modifyMicroAlert(CollectionsMicroButtonAlert, CollectionsMicroButton)
    modifyMicroAlert(LFDMicroButtonAlert, LFDMicroButton)
    modifyMicroAlert(EJMicroButtonAlert, EJMicroButton)
    modifyMicroAlert(StoreMicroButtonAlert, StoreMicroButton)
    if GetSetting("USE_CHARACTER_WINDOW") then
        modifyMicroAlert(CharacterMicroButtonAlert, GwCharacterMicroButton)
    else
        modifyMicroAlert(CharacterMicroButtonAlert, CharacterMicroButton)
    end
    if GetSetting("USE_TALENT_WINDOW") then
        modifyMicroAlert(TalentMicroButtonAlert, GwTalentMicroButton)
    else
        modifyMicroAlert(TalentMicroButtonAlert, TalentMicroButton)
    end
    hooksecurefunc("MainMenuMicroButton_PositionAlert", gwMicro_PositionAlert)
end
GW.LoadMicroMenu = LoadMicroMenu
