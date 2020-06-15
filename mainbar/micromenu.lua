local _, GW = ...
local GetSetting = GW.GetSetting

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

local function bag_OnUpdate(self, elapsed)
    self.interval = self.interval - elapsed
    if self.interval > 0 then
        return
    end

    local totalEmptySlots = 0
    for i = 0, 4 do
        local numberOfFreeSlots, _ = GetContainerNumFreeSlots(i)

        if numberOfFreeSlots ~= nil then
            totalEmptySlots = totalEmptySlots + numberOfFreeSlots
        end
    end

    self.GwNotifyDark:Show()
    if totalEmptySlots > 9 then
        self.GwNotifyText:SetText(totalEmptySlots)
    else
        self.GwNotifyText:SetText(totalEmptySlots .. " ")
    end
    self.GwNotifyText:Show()
end
GW.AddForProfiling("micromenu", "bag_OnUpdate", bag_OnUpdate)

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

local function reskinMicroButton(btn, name, mbf)
    btn:SetParent(mbf)
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

local function reskinMicroButtons(mbf)
    for i = 1, #MICRO_BUTTONS do
        local name = MICRO_BUTTONS[i]
        local btn = _G[name]
        if btn then
            reskinMicroButton(btn, name, mbf)
        end
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

local function setupMicroButtons(mbf)
    -- CharacterMicroButton
    -- determine if we are using the default char button (for default charwin)
    -- or if we need to create our own char button for the custom hero panel
    local cref
    if GetSetting("USE_CHARACTER_WINDOW") then
        cref = CreateFrame("Button", nil, mbf, "SecureHandlerClickTemplate,MainMenuBarMicroButton")
        cref.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
        cref.newbieText = NEWBIE_TOOLTIP_CHARACTER
        reskinMicroButton(cref, "CharacterMicroButton", mbf)
    
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
    end
    cref.GwSetAnchorPoint = function(self)
        -- this must also happen in the auto-layout update hook which is why we do it like this
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", mbf, "TOPLEFT", 5, -3)
    end
    cref:GwSetAnchorPoint()

    -- custom bag microbutton
    local bref = CreateFrame("Button", nil, mbf, "MainMenuBarMicroButton")
    bref.tooltipText = MicroButtonTooltipText(INVENTORY_TOOLTIP, "OPENALLBAGS")
    bref.newbieText = nil
    reskinMicroButton(bref, "BagMicroButton", mbf)

    bref:ClearAllPoints()
    bref:SetPoint("BOTTOMLEFT", cref, "BOTTOMRIGHT", 4, 0)
    bref:HookScript("OnClick", ToggleAllBags)
    bref.interval = 0
    bref:HookScript("OnUpdate", bag_OnUpdate)

    -- determine if we are using the default spell & talent buttons
    -- or if we need our custom talent button for the hero panel
    local tref
    if GetSetting("USE_TALENT_WINDOW") then
        tref = CreateFrame("Button", nil, mbf, "SecureHandlerClickTemplate,MainMenuBarMicroButton")
        tref.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
        tref.newbieText = NEWBIE_TOOLTIP_TALENTS
        reskinMicroButton(tref, "TalentMicroButton", mbf)
        tref:ClearAllPoints()
        tref:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)

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
        SpellbookMicroButton:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)

        -- TalentMicroButton
        tref = TalentMicroButton
        tref:ClearAllPoints()
        tref:SetPoint("BOTTOMLEFT", SpellbookMicroButton, "BOTTOMRIGHT", 4, 0)

        -- we've added an extra button so expand the container a bit
        mbf:SetWidth(mbf:GetWidth() + 28)
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
            C_GuildInfo.GuildRoster()
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

local function checkElvUI()
    -- ElvUI re-styles the MicroButton bar even if it is disabled in their options.
    -- We check for that condition here, and force styling fixes if necessary. Or
    -- skip touching it entirely if their MicroButton bar is enabled.
    --
    -- This works as-is because we know ElvUI will load before us. Otherwise we'll
    -- have to get more in-depth with the ACE loading logic.
    
    -- get the ElvUI addon/ActionBars module from ACE
    if not LibStub then
        return false
    end
    local ace = LibStub("AceAddon-3.0", true)
    if not ace then
        return false
    end
    local elv = ace:GetAddon("ElvUI", true)
    if not elv then
        return false
    end
    local ab = elv:GetModule("ActionBars")
    if not ab then
        return false
    end

    -- check if the ElvUI microbar setting is enabled
    if ab.db.microbar.enabled then
        return true
    end

    -- at this point we know we should own the microbar; fix what ElvUI did to it
    ElvUI_MicroBar = nil

    for i = 1, #MICRO_BUTTONS do
        local name = MICRO_BUTTONS[i]
        local btn = _G[name]
        if btn then
            -- remove the backdrop ElvUI adds
            if btn.backdrop then
                btn.backdrop:Hide()
                btn.backdrop = nil
            end

            -- undo the texture coords ElvUI applies
            local pushed = btn:GetPushedTexture()
            local normal = btn:GetNormalTexture()
            local disabled = btn:GetDisabledTexture()

            if pushed then
                pushed:SetTexCoord(unpack(GW.TexCoords))
            end
            if normal then
                normal:SetTexCoord(unpack(GW.TexCoords))
            end
            if disabled then
                disabled:SetTexCoord(unpack(GW.TexCoords))
            end

            local high = btn:GetHighlightTexture()
            if high then
                high.Show = normal.Show
                high:Show()
            end
        end
    end

    return false
end

local function LoadMicroMenu()
    -- compatability with ElvUI (this one is their fault)
    if checkElvUI() then
        return
    end

    -- create our micro button container frame
    local mbf = CreateFrame("Frame", nil, UIParent, "GwMicroButtonFrameTmpl")

    -- reskin all default (and custom) micro buttons to our styling
    reskinMicroButtons(mbf.cf)

    -- re-do anchoring of the micro buttons to our preferred ordering and setup
    -- custom button overrides & behaviors for each button where necessary
    setupMicroButtons(mbf.cf)

    -- undo micro button position and visibility changes done by others
    for i = 1, #MICRO_BUTTONS do
        MICRO_BUTTONS[i] = nil
    end
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
            GuildMicroButtonTabard:Hide()
            local m = GuildMicroButton
            m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
            m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
            m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
            m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/GuildMicroButton-Up")
        end
    )

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

    -- if set to fade micro menu, add fader
    if GetSetting("FADE_MICROMENU") then
        mbf.cf:SetAttribute("fadeTime", 0.15)

        local fo = mbf.cf:CreateAnimationGroup("fadeOut")
        local fi = mbf.cf:CreateAnimationGroup("fadeIn")
        local fadeOut = fo:CreateAnimation("Alpha")
        local fadeIn = fi:CreateAnimation("Alpha")
        fo:SetScript("OnFinished", function(self)
            self:GetParent():SetAlpha(0)
        end)
        fadeOut:SetStartDelay(0.25)
        fadeOut:SetFromAlpha(1.0)
        fadeOut:SetToAlpha(0.0)
        fadeOut:SetDuration(mbf.cf:GetAttribute("fadeTime"))
        fadeIn:SetFromAlpha(0.0)
        fadeIn:SetToAlpha(1.0)
        fadeIn:SetDuration(mbf.cf:GetAttribute("fadeTime"))
        mbf.cf.fadeOut = function(self)
            fi:Stop()
            fo:Stop()
            fo:Play()
        end
        mbf.cf.fadeIn = function(self)
            self:SetAlpha(1)
            fi:Stop()
            fo:Stop()
            fi:Play()
        end
    
        mbf:SetFrameRef("cf", mbf.cf)

        mbf:SetAttribute("_onenter", [=[
            local cf = self:GetFrameRef("cf")
            if cf:IsShown() then
                return
            end
            cf:UnregisterAutoHide()
            cf:Show()
            cf:CallMethod("fadeIn", cf)
            cf:RegisterAutoHide(cf:GetAttribute("fadeTime") + 0.25)
        ]=])
        mbf.cf:HookScript("OnLeave", function(self)
            if not self:IsMouseOver() then
                self:fadeOut()
            end
        end)
        mbf.cf:Hide()
    end

    -- fix alert positions and hide the micromenu bar
    MicroButtonAndBagsBar:SetAlpha(0)
    MicroButtonAndBagsBar:EnableMouse(false)
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
