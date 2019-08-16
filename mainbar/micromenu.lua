local _, GW = ...
local RoundDec = GW.RoundDec
local GetSetting = GW.GetSetting
local RoundInt = GW.RoundInt
local VERSION_STRING = GW.VERSION_STRING
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation

local function updateGuildButton()
    local _, _, numOnlineMembers = GetNumGuildMembers()

    if numOnlineMembers ~= nil and numOnlineMembers > 0 then
        GwMicroButtonGuildMicroButton.darkbg:Show()

        if numOnlineMembers > 9 then
            GwMicroButtonGuildMicroButton.darkbg:SetSize(18, 18)
        else
            GwMicroButtonGuildMicroButton.darkbg:SetSize(14, 14)
        end

        _G["GwMicroButtonGuildMicroButtonString"]:Show()
        _G["GwMicroButtonGuildMicroButtonString"]:SetText(numOnlineMembers)
    else
        GwMicroButtonGuildMicroButton.darkbg:Hide()
        _G["GwMicroButtonGuildMicroButtonString"]:Hide()
    end
end
GW.AddForProfiling("hud", "updateGuildButton", updateGuildButton)

local function updateInventoryButton()
    local totalEmptySlots = 0

    for i = 0, 4 do
        local numberOfFreeSlots, _ = GetContainerNumFreeSlots(i)

        if numberOfFreeSlots ~= nil then
            totalEmptySlots = totalEmptySlots + numberOfFreeSlots
        end
    end

    GwMicroButtonBagMicroButton.darkbg:Show()
    if totalEmptySlots > 9 then
        GwMicroButtonBagMicroButton.darkbg:SetSize(18, 18)
    else
        GwMicroButtonBagMicroButton.darkbg:SetSize(14, 14)
    end

    _G["GwMicroButtonBagMicroButtonString"]:Show()
    _G["GwMicroButtonBagMicroButtonString"]:SetText(totalEmptySlots)
end
GW.AddForProfiling("hud", "updateInventoryButton", updateInventoryButton)

local microButtonFrame = CreateFrame("Frame", "GwMicroButtonFrame", UIParent, "GwMicroButtonFrame")

local microButtonPadding = 4 + 12

local function createMicroButton(key)
    local mf =
        CreateFrame(
        "Button",
        "GwMicroButton" .. key,
        microButtonFrame,
        "SecureHandlerClickTemplate,GwMicroButtonTemplate"
    )
    mf:SetPoint("CENTER", microButtonFrame, "TOPLEFT", microButtonPadding, -16)
    microButtonPadding = microButtonPadding + 24 + 4

    mf:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")
    mf:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")
    mf:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")
    mf:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\" .. key .. "-Up")

    _G["GwMicroButton" .. key .. "String"]:SetFont(DAMAGE_TEXT_FONT, 12)
    _G["GwMicroButton" .. key .. "String"]:SetShadowColor(0, 0, 0, 0)

    _G["GwMicroButton" .. key .. "Texture"]:Hide()
    _G["GwMicroButton" .. key .. "String"]:Hide()

    return mf
end
GW.AddForProfiling("micromenu", "createMicroButton", createMicroButton)

local CUSTOM_MICRO_BUTTONS = {}

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

local gw_sendUpdate_message_cooldown = 0
local function sendVersionCheck()
    if gw_sendUpdate_message_cooldown > GetTime() then
        return
    end
    gw_sendUpdate_message_cooldown = GetTime() + 10

    local chatToSend = "GUILD"
    local inInstanceGroup = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
    if inInstanceGroup then
        chatToSend = "INSTANCE_CHAT"
    elseif IsInGroup() then
        chatToSend = "PARTY"
        if IsInRaid() then
            chatToSend = "RAID"
        end
    end
    C_ChatInfo.SendAddonMessage("GW2_UI", VERSION_STRING, chatToSend)
end
GW.AddForProfiling("micromenu", "sendVersionCheck", sendVersionCheck)

local function receiveVersionCheck(self, event, prefix, message, dist, sender)
    if prefix ~= "GW2_UI" then
        return
    end

    local version, subversion, hotfix = string.match(message, "GW2_UI v(%d+).(%d+).(%d+)")
    local Currentversion, Currentsubversion, Currenthotfix = string.match(VERSION_STRING, "GW2_UI v(%d+).(%d+).(%d+)")

    if version == nil or subversion == nil or hotfix == nil then
        return
    end
    if Currentversion == nil or Currentsubversion == nil or Currenthotfix == nil then
        return
    end

    if version > Currentversion then
        GwMicroButtonupdateicon.updateType = GwLocalization["UPDATE_STRING_3"]
        GwMicroButtonupdateicon.updateTypeInt = 3
        GwMicroButtonupdateicon:Show()
    else
        if subversion > Currentsubversion then
            GwMicroButtonupdateicon.updateType = GwLocalization["UPDATE_STRING_2"]
            GwMicroButtonupdateicon.updateTypeInt = 2
            GwMicroButtonupdateicon:Show()
        else
            if hotfix > Currenthotfix then
                GwMicroButtonupdateicon.updateType = GwLocalization["UPDATE_STRING_1"]
                GwMicroButtonupdateicon.updateTypeInt = 1
                GwMicroButtonupdateicon:Show()
            end
        end
    end
end
GW.AddForProfiling("micromenu", "receiveVersionCheck", receiveVersionCheck)

local ipTypes = {"IPv4", "IPv6"}

local gw_addonMemoryArray = {}
local function latencyToolTip(self, elapsed)
    if self.interval > 0 then
        self.interval = self.interval - elapsed
        return
    end
    self.interval = 1

    local gw_frameRate = RoundInt(GetFramerate())
    local _, _, lagHome, lagWorld = GetNetStats()
    local percent = floor(GetDownloadedPercentage() * 100 + 0.5)
    local gw_addonMemory = 0
    local gw_numAddons = GetNumAddOns()

    -- wipe and reuse our memtable to avoid temp pre-GC bloat on the tooltip (still get a bit from the sort)
    for i = 1, #gw_addonMemoryArray do
        gw_addonMemoryArray[i]["addonIndex"] = 0
        gw_addonMemoryArray[i]["addonMemory"] = 0
    end

    UpdateAddOnMemoryUsage()

    GameTooltip:SetOwner(GwMicroButtonMainMenuMicroButton, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(MAINMENU_BUTTON, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(MAINMENUBAR_LATENCY_LABEL:format(lagHome, lagWorld), 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")
    if (GetCVarBool("useIPv6")) then
        local ipTypeHome, ipTypeWorld = GetNetIpTypes()
        GameTooltip:AddLine(
            MAINMENUBAR_PROTOCOLS_LABEL:format(
                ipTypes[ipTypeHome or 0] or UNKNOWN,
                ipTypes[ipTypeWorld or 0] or UNKNOWN
            ),
            0.8,
            0.8,
            0.8
        )
        GameTooltip:AddLine(" ")
    end
    GameTooltip:AddLine(MAINMENUBAR_FPS_LABEL:format(gw_frameRate), 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(MAINMENUBAR_BANDWIDTH_LABEL:format(GetAvailableBandwidth()), 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(MAINMENUBAR_DOWNLOAD_PERCENT_LABEL:format(percent), 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")

    for i = 1, gw_numAddons do
        if type(gw_addonMemoryArray[i]) ~= "table" then
            gw_addonMemoryArray[i] = {}
        end
        local mem = GetAddOnMemoryUsage(i)
        gw_addonMemoryArray[i]["addonIndex"] = i
        gw_addonMemoryArray[i]["addonMemory"] = mem
        gw_addonMemory = gw_addonMemory + mem
    end

    if (gw_addonMemory > 1024) then
        gw_addonMemory = gw_addonMemory / 1024
        GameTooltip:AddLine(TOTAL_MEM_MB_ABBR:format(gw_addonMemory), 0.8, 0.8, 0.8)
    else
        GameTooltip:AddLine(TOTAL_MEM_MB_ABBR:format(gw_addonMemory), 0.8, 0.8, 0.8)
    end

    if self.inDebug then
        table.sort(
            gw_addonMemoryArray,
            function(a, b)
                return a["addonMemory"] > b["addonMemory"]
            end
        )

        for k, v in pairs(gw_addonMemoryArray) do
            if v["addonIndex"] ~= 0 and (IsAddOnLoaded(v["addonIndex"]) and v["addonMemory"] ~= 0) then
                gw_addonMemory = RoundDec(v["addonMemory"] / 1024, 2)
                if gw_addonMemory ~= "0.00" then
                    GameTooltip:AddLine(
                        "(" .. gw_addonMemory .. " MB) " .. GetAddOnInfo(v["addonIndex"]),
                        0.8,
                        0.8,
                        0.8
                    )
                end
            end
        end
    else
        gw_addonMemory = RoundDec(GetAddOnMemoryUsage("GW2_UI") / 1024, 2)
        GameTooltip:AddLine("(" .. gw_addonMemory .. " MB) GW2_UI", 0.8, 0.8, 0.8)
    end

    GameTooltip:Show()
end
GW.AddForProfiling("micromenu", "latencyToolTip", latencyToolTip)

local function talentMicro_OnEvent()
    if not GW.inWorld then
        return
    end
    if GetNumUnspentTalents() > 0 then
        _G["GwMicroButtonTalentMicroButtonTexture"]:Show()
        _G["GwMicroButtonTalentMicroButtonString"]:Show()
        _G["GwMicroButtonTalentMicroButtonString"]:SetText(GetNumUnspentTalents())
    else
        _G["GwMicroButtonTalentMicroButtonTexture"]:Hide()
        _G["GwMicroButtonTalentMicroButtonString"]:Hide()
    end
end
GW.AddForProfiling("micromenu", "talentMicro_OnEvent", talentMicro_OnEvent)

local function gwMicro_PositionAlert(alert)
    if
        (alert ~= CollectionsMicroButtonAlert and alert ~= LFDMicroButtonAlert and alert ~= EJMicroButtonAlert and
            alert ~= StoreMicroButtonAlert and
            alert ~= CharacterMicroButtonAlert)
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
end
GW.AddForProfiling("micromenu", "modifyMicroAlert", modifyMicroAlert)

local function getToolTip(text, action)
    if (GetBindingKey(action)) then
        return text .. " |cffa6a6a6(" .. GetBindingText(GetBindingKey(action)) .. ")" .. FONT_COLOR_CODE_CLOSE
    else
        return text
    end
end
GW.AddForProfiling("micromenu", "getToolTip", getToolTip)

local function setToolTip(frame, text, action)
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(getToolTip(text, action), 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("micromenu", "setToolTip", setToolTip)

local function hookToolTip(frame, text, action)
    if frame == nil then
        return
    end
    frame:SetScript(
        "OnEnter",
        function()
            setToolTip(frame, text, action)
            setToolTip(frame, text, action)
        end
    )
    frame:SetScript("OnLeave", GameTooltip_Hide)
end
GW.AddForProfiling("micromenu", "hookToolTip", hookToolTip)

local function setMicroButtons()
    MicroButtonPortrait:Hide()
    GuildMicroButtonTabard:Hide()
    MainMenuBarPerformanceBar:Hide()
    TalentMicroButtonAlert:Hide()
    TalentMicroButtonAlert:SetScript("OnShow", Self_Hide)
    TalentMicroButtonAlert:SetScript("OnHide", nil)
    TalentMicroButtonAlert:SetScript("OnEnter", nil)
    TalentMicroButtonAlert:SetScript("OnLeave", nil)

    for i = 1, #MICRO_BUTTONS do
        local b = _G[MICRO_BUTTONS[i]]
        if b then
            b:UnregisterAllEvents()
            b:SetScript("OnShow", Self_Hide)
            b:SetScript("OnHide", nil)
            b:SetScript("OnEnter", nil)
            b:SetScript("OnLeave", nil)
            b:SetScript("OnEvent", nil)
            b:SetScript("OnUpdate", nil)
            b:Hide()
        end
    end
end
GW.AddForProfiling("micromenu", "setMicroButtons", setMicroButtons)

local function LoadMicroMenu()
    local mi = 1
    for k, v in pairs(MICRO_BUTTONS) do
        CUSTOM_MICRO_BUTTONS[mi] = v
        if v == "CharacterMicroButton" then
            mi = mi + 1
            CUSTOM_MICRO_BUTTONS[mi] = "BagMicroButton"
        end
        mi = mi + 1
    end

    for k, v in pairs(CUSTOM_MICRO_BUTTONS) do
        if v ~= "SpellbookMicroButton" then
            createMicroButton(v)
        else
            if not GetSetting("USE_TALENT_WINDOW") then
                createMicroButton(v)
            end
        end
    end

    if GetSetting("USE_CHARACTER_WINDOW") then
        GwMicroButtonCharacterMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        GwMicroButtonCharacterMicroButton:SetAttribute(
            "_onclick",
            [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
            ]=]
        )
    else
        GwMicroButtonCharacterMicroButton:SetScript(
            "OnClick",
            function()
                ToggleCharacter("PaperDollFrame")
            end
        )
    end

    GwMicroButtonBagMicroButton:SetScript(
        "OnClick",
        function()
            ToggleAllBags()
        end
    )

    if GetSetting("USE_TALENT_WINDOW") then
        GwMicroButtonTalentMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        GwMicroButtonTalentMicroButton:SetAttribute(
            "_onclick",
            [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
            ]=]
        )
    else
        GwMicroButtonSpellbookMicroButton:SetScript(
            "OnClick",
            function()
                ToggleSpellBook(BOOKTYPE_SPELL)
            end
        )
        GwMicroButtonSpellbookMicroButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        GwMicroButtonTalentMicroButton:SetScript(
            "OnClick",
            function()
                ToggleTalentFrame()
            end
        )
    end

    GwMicroButtonAchievementMicroButton:SetScript(
        "OnClick",
        function()
            ToggleAchievementFrame()
        end
    )
    GwMicroButtonQuestLogMicroButton:SetScript(
        "OnClick",
        function()
            ToggleQuestLog()
        end
    )
    GwMicroButtonGuildMicroButton:SetScript(
        "OnClick",
        function()
            ToggleGuildFrame()
        end
    )
    GwMicroButtonLFDMicroButton:SetScript(
        "OnClick",
        function()
            PVEFrame_ToggleFrame()
        end
    )
    GwMicroButtonCollectionsMicroButton:SetScript(
        "OnClick",
        function()
            ToggleCollectionsJournal()
        end
    )
    GwMicroButtonEJMicroButton:SetScript(
        "OnClick",
        function()
            ToggleEncounterJournal()
        end
    )

    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnClick",
        function()
            if (not GameMenuFrame:IsShown()) then
                if (VideoOptionsFrame:IsShown()) then
                    VideoOptionsFrameCancel:Click()
                elseif (AudioOptionsFrame:IsShown()) then
                    AudioOptionsFrameCancel:Click()
                elseif (InterfaceOptionsFrame:IsShown()) then
                    InterfaceOptionsFrameCancel:Click()
                end

                CloseMenus()
                CloseAllWindows()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
                ShowUIPanel(GameMenuFrame)
            else
                PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
                HideUIPanel(GameMenuFrame)
                MainMenuMicroButton_SetNormal()
            end
        end
    )

    if GwMicroButtonHelpMicroButton ~= nil then
        GwMicroButtonHelpMicroButton:SetScript("OnClick", ToggleHelpFrame)
    end
    if GwMicroButtonStoreMicroButton ~= nil then
        GwMicroButtonStoreMicroButton:SetScript("OnClick", ToggleStoreUI)
    end

    GwMicroButtonTalentMicroButton:SetScript("OnEvent", talentMicro_OnEvent)
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_LEVEL_UP")
    GwMicroButtonTalentMicroButton:RegisterEvent("UPDATE_BINDINGS")
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_TALENT_UPDATE")
    GwMicroButtonTalentMicroButton:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    hookToolTip(GwMicroButtonCharacterMicroButton, CHARACTER_BUTTON, 'TOGGLECHARACTER0"')
    hookToolTip(GwMicroButtonBagMicroButton, INVENTORY_TOOLTIP, "OPENALLBAGS")
    hookToolTip(GwMicroButtonSpellbookMicroButton, SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
    hookToolTip(GwMicroButtonTalentMicroButton, TALENTS_BUTTON, "TOGGLETALENTS")
    hookToolTip(GwMicroButtonAchievementMicroButton, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
    hookToolTip(GwMicroButtonQuestLogMicroButton, QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
    hookToolTip(GwMicroButtonGuildMicroButton, GUILD, "TOGGLEGUILDTAB")
    hookToolTip(GwMicroButtonLFDMicroButton, DUNGEONS_BUTTON, "TOGGLEGROUPFINDER")
    hookToolTip(GwMicroButtonCollectionsMicroButton, COLLECTIONS, "TOGGLECOLLECTIONS")
    hookToolTip(GwMicroButtonEJMicroButton, ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL")

    GwMicroButtonBagMicroButton.interval = 0
    GwMicroButtonBagMicroButton:SetScript(
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

    GwMicroButtonGuildMicroButton.interval = 0
    GwMicroButtonGuildMicroButton:SetScript(
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
    GwMicroButtonGuildMicroButton:SetScript("OnEvent", updateGuildButton)
    GwMicroButtonGuildMicroButton:RegisterEvent("GUILD_ROSTER_UPDATE")

    GwMicroButtonMainMenuMicroButton.inDebug = GW.inDebug
    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnEnter",
        function(self)
            self.interval = 0
            self:SetScript("OnUpdate", latencyToolTip)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, ANCHOR_BOTTOMLEFT)
        end
    )

    GwMicroButtonMainMenuMicroButton:SetScript(
        "OnLeave",
        function()
            GwMicroButtonMainMenuMicroButton:SetScript("OnUpdate", nil)
            GameTooltip_Hide()
        end
    )

    talentMicro_OnEvent()
    updateGuildButton()

    --Create update notifier
    local updateNotificationIcon = createMicroButton("updateicon")
    GwMicroButtonupdateicon.updateTypeInt = 0
    GwMicroButtonupdateicon:Hide()

    updateNotificationIcon:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(updateNotificationIcon, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
            GameTooltip:ClearLines()
            GameTooltip:AddLine("GW2_UI", 1, 1, 1)
            GameTooltip:AddLine(updateNotificationIcon.updateType, 1, 1, 1)
            GameTooltip:Show()
        end
    )
    updateNotificationIcon:SetScript("OnLeave", GameTooltip_Hide)
    C_ChatInfo.RegisterAddonMessagePrefix("GW2_UI")

    updateNotificationIcon:RegisterEvent("CHAT_MSG_ADDON")
    updateNotificationIcon:RegisterEvent("GROUP_ROSTER_UPDATE")
    updateNotificationIcon:SetScript(
        "OnEvent",
        function(self, event, prefix, message, dist, sender)
            if event == "CHAT_MSG_ADDON" then
                receiveVersionCheck(self, event, prefix, message, dist, sender)
            else
                sendVersionCheck()
            end
        end
    )

    -- if set to fade micro menu, add fader
    if GetSetting("FADE_MICROMENU") then
        microButtonFrame.gw_LastFadeCheck = -1
        microButtonFrame.gw_FadeShowing = true
        microButtonFrame:SetScript("OnUpdate", microMenu_OnUpdate)
    end

    -- fix tutorial alerts and hide the micromenu bar
    MicroButtonAndBagsBar:Hide()
    MicroButtonAndBagsBar:SetMovable(1)
    MicroButtonAndBagsBar:SetUserPlaced(true)
    MicroButtonAndBagsBar:SetMovable(0)
    hooksecurefunc("UpdateMicroButtons", setMicroButtons)
    setMicroButtons()

    -- talent alert is always hidden by actionbars because we have a custom # on the button instead
    modifyMicroAlert(CollectionsMicroButtonAlert, GwMicroButtonCollectionsMicroButton)
    modifyMicroAlert(LFDMicroButtonAlert, GwMicroButtonLFDMicroButton)
    modifyMicroAlert(EJMicroButtonAlert, GwMicroButtonEJMicroButton)
    modifyMicroAlert(StoreMicroButtonAlert, GwMicroButtonHelpMicroButton)
    modifyMicroAlert(CharacterMicroButtonAlert, GwMicroButtonCharacterMicroButton)
    hooksecurefunc("MainMenuMicroButton_PositionAlert", gwMicro_PositionAlert)
end
GW.LoadMicroMenu = LoadMicroMenu
