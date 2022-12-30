local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local AFP = GW.AddProfiling
local updateIcon

local PERFORMANCE_BAR_UPDATE_INTERVAL = 1

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"CollectionsMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
	"StoreMicroButton",
	}

do
    local SendMessageWaiting
    local function SendMessage()
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", GW.VERSION_STRING, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", GW.VERSION_STRING, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
        elseif IsInGuild() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", GW.VERSION_STRING, "GUILD")
        end

        SendMessageWaiting = nil
    end
    AFP("SendMessage", SendMessage)

    local SendRecieveGroupSize = 0
    local myRealm = gsub(GW.myrealm, "[%s%-]", "")
    local myName = GW.myname .. "-" .. myRealm
    local printChatMessage = false
    local function SendRecieve(_, event, prefix, message, _, sender)
        if event == "CHAT_MSG_ADDON" then
            if sender == myName then return end
            if prefix == "GW2UI_VERSIONCHK" then
                local version, subversion, hotfix = string.match(message, "GW2_UI v(%d+).(%d+).(%d+)")
                local currentVersion, currentSubversion, currentHotfix = string.match(GW.VERSION_STRING, "GW2_UI v(%d+).(%d+).(%d+)")
                local isUpdate = false
                if version == nil or subversion == nil or hotfix == nil or currentVersion == nil or currentSubversion == nil or currentHotfix == nil then return end

                if version > currentVersion then
                    updateIcon.tooltipText = L["New update available for download."]
                    isUpdate = true
                elseif subversion > currentSubversion then
                    updateIcon.tooltipText = L["New update available containing new features."]
                    isUpdate = true
                elseif hotfix > currentHotfix then
                    updateIcon.tooltipText = L["A |cFFFF0000major|r update is available.\nIt's strongly recommended that you update."]
                    isUpdate = true
                end

                if isUpdate and not printChatMessage then
                    GW.FrameFlash(updateIcon, 1, 0.3, 1, true)
                    DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. updateIcon.tooltipText):gsub("*", GW.Gw2Color))
                    updateIcon:Show()
                    printChatMessage = true
                end
            end
        elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
            local num = GetNumGroupMembers()
            if num ~= SendRecieveGroupSize then
                if num > 1 and num > SendRecieveGroupSize then
                    if not SendMessageWaiting then
                        SendMessageWaiting = C_Timer.After(10, SendMessage)
                    end
                end
                SendRecieveGroupSize = num
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            if not SendMessageWaiting then
                SendMessageWaiting = C_Timer.After(10, SendMessage)
            end
        end
    end
    AFP("SendRecieve", SendRecieve)

    C_ChatInfo.RegisterAddonMessagePrefix("GW2UI_VERSIONCHK")

    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_ADDON")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("RAID_ROSTER_UPDATE")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", SendRecieve)
end

local function updateGuildButton(self, event)
    if event == "GUILD_ROSTER_UPDATE" then
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

        GW.FetchGuildMembers()

        if GetMouseFocus() == self then
            GW.Guild_OnEnter(self)
        end
    elseif event == "MODIFIER_STATE_CHANGED" then
        if not IsAltKeyDown() and GetMouseFocus() == self then
			GW.Guild_OnEnter(self)
		end
    elseif event == "GUILD_MOTD" then
        if GetMouseFocus() == self then
            GW.Guild_OnEnter(self)
        end
    end
end
AFP("updateGuildButton", updateGuildButton)

local function updateQuestLogButton(_, event)
    if event ~= "QUEST_LOG_UPDATE" then
        return
    end

    local qlmb = QuestLogMicroButton
    if qlmb == nil then
        return
    end

    local _, numQuests = C_QuestLog.GetNumQuestLogEntries()

    if numQuests ~= nil and numQuests > 0 then
        qlmb.GwNotifyDark:Show()

        if numQuests > 9 then
            qlmb.GwNotifyText:SetText(numQuests)
        else
            qlmb.GwNotifyText:SetText(numQuests .. " ")
        end
        qlmb.GwNotifyText:Show()
    else
        qlmb.GwNotifyDark:Hide()
        qlmb.GwNotifyText:Hide()
    end
end
AFP("updateQuestLogButton", updateQuestLogButton)

local bag_update_interval = 1/30 -- cap bag button updates to 30 FPS
local function bag_OnUpdate(self, elapsed)
    self.interval = self.interval - elapsed
    if self.interval > 0 then
        return
    end
    self.interval = bag_update_interval

    local totalEmptySlots = 0
    for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local numberOfFreeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i)
        if bagFamily == 0 and numberOfFreeSlots ~= nil then
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
AFP("bag_OnUpdate", bag_OnUpdate)

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
AFP("gwMicro_PositionAlert", gwMicro_PositionAlert)

local function modifyMicroAlert(alert, microButton)
    if not alert then return end --TODO: Alerts are changed
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
AFP("modifyMicroAlert", modifyMicroAlert)

local function reskinMicroButton(btn, name, mbf)
    btn:SetParent(mbf)
    hooksecurefunc(btn, "SetParent", function(self, parent)
        if parent ~= mbf then
            self:SetParent(mbf)
        end
    end)

    local tex = "Interface/AddOns/GW2_UI/textures/icons/microicons/" .. name .. "-Up"

    btn:SetSize(24, 24)
    btn:SetDisabledTexture(tex)
    btn:SetNormalTexture(tex)
    btn:SetPushedTexture(tex)
    btn:SetHighlightTexture(tex)

		--hackfix for texture size
    local t = btn:GetDisabledTexture()
    t:ClearAllPoints()
    t:SetPoint("CENTER",btn,"CENTER",0,0)
    t:SetSize(32,32)

    t = btn:GetNormalTexture()
    t:ClearAllPoints()
    t:SetPoint("CENTER",btn,"CENTER",0,0)
    t:SetSize(32,32)

    t = btn:GetPushedTexture()
    t:ClearAllPoints()
    t:SetPoint("CENTER",btn,"CENTER",0,0)
    t:SetSize(32,32)

    t = btn:GetHighlightTexture()
    t:ClearAllPoints()
    t:SetPoint("CENTER",btn,"CENTER",0,0)
    t:SetSize(32,32)

    if btn.Flash then
        btn.Flash:SetInside()
		btn.Flash:SetTexture()
    end

    if btn.FlashBorder then
        btn.FlashBorder:SetAlpha(0)
        btn.FlashBorder:SetScale(0.00001)
    end
    if btn.FlashContent then
        btn.FlashContent:SetAlpha(0)
        btn.FlashContent:SetScale(0.00001)
    end

    btn.GwNotify = btn:CreateTexture(nil, "OVERLAY")
    btn.GwNotifyDark = btn:CreateTexture(nil, "OVERLAY")
    btn.GwNotifyText = btn:CreateFontString(nil, "OVERLAY")

    btn.GwNotify:SetSize(18, 18)
    btn.GwNotify:SetPoint("CENTER", btn, "BOTTOM", 6, 3)
    btn.GwNotify:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop")
    btn.GwNotify:SetVertexColor(1, 0, 0, 1)
    btn.GwNotify:Hide()

    btn.GwNotifyDark:SetSize(18, 18)
    btn.GwNotifyDark:SetPoint("CENTER", btn, "BOTTOM", 6, 3)
    btn.GwNotifyDark:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop")
    btn.GwNotifyDark:SetVertexColor(0, 0, 0, 0.7)
    btn.GwNotifyDark:Hide()

    btn.GwNotifyText:SetSize(24, 24)
    btn.GwNotifyText:SetPoint("CENTER", btn, "BOTTOM", 7, 2)
    btn.GwNotifyText:SetFont(DAMAGE_TEXT_FONT, 12)
    btn.GwNotifyText:SetTextColor(1, 1, 1, 1)
    btn.GwNotifyText:SetShadowColor(0, 0, 0, 0)
    btn.GwNotifyText:Hide()
end
AFP("reskinMicroButton", reskinMicroButton)

local function reskinMicroButtons(mbf)
    for i = 1, #MICRO_BUTTONS do
        local name = MICRO_BUTTONS[i]
        local btn = _G[name]
        if btn then
            reskinMicroButton(btn, name, mbf)
        end
    end
end
AFP("reskinMicroButtons", reskinMicroButtons)

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
AFP("disableMicroButton", disableMicroButton)

local function char_SetAnchorPoint(self)
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -40, 40)
end
AFP("char_SetAnchorPoint", char_SetAnchorPoint)

local function cref_SetAnchorPoint(self, mbf)
    -- this must also happen in the auto-layout update hook which is why we do it like this
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", mbf, "TOPLEFT", 5, -3)
end
AFP("cref_SetAnchorPoint", cref_SetAnchorPoint)

local function lfd_SetAnchorPoint(self)
    -- this must also happen in the auto-layout update hook which is why we do it like this
    self:ClearAllPoints()
    self:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", 4, 0)
end
AFP("lfd_SetAnchorPoint", lfd_SetAnchorPoint)

local function hook_MainMenuMicroButton_OnUpdate()
    -- the main menu button routinely updates its texture based on streaming download
    -- status and net performance; we undo those changes here on each update interval
    local m = MainMenuMicroButton
    if m.updateInterval ~= PERFORMANCE_BAR_UPDATE_INTERVAL then
        return
    end
    m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/MainMenuMicroButton-Up")
    m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/MainMenuMicroButton-Up")
    m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/MainMenuMicroButton-Up")
    m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/MainMenuMicroButton-Up")
    m.MainMenuBarPerformanceBar:SetAlpha(0)
    m.MainMenuBarPerformanceBar:SetScale(0.00001)
end
AFP("hook_MainMenuMicroButton_OnUpdate", hook_MainMenuMicroButton_OnUpdate)

local function update_OnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, L["GW2 UI Update"])
    GameTooltip:AddLine(self.tooltipText)
    GameTooltip:Show()
end
AFP("update_OnEnter", update_OnEnter)

local function setupMicroButtons(mbf)
    -- CharacterMicroButton
    -- determine if we are using the default char button (for default charwin)
    -- or if we need to create our own char button for the custom hero panel
    local cref
    if GetSetting("USE_CHARACTER_WINDOW") then
        cref = CreateFrame("Button", nil, mbf, "SecureHandlerClickTemplate")
        cref.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
        cref.newbieText = NEWBIE_TOOLTIP_CHARACTER
        reskinMicroButton(cref, "CharacterMicroButton", mbf)
        cref:RegisterForClicks("AnyUp")
        cref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        cref:SetAttribute(
            "_onclick",
            [=[
                if button ~= "LeftButton" then return end
                local f = self:GetFrameRef("GwCharacterWindow")
                f:SetAttribute("keytoggle", "1")
                f:SetAttribute("windowpanelopen", "paperdoll")
            ]=]
        )
        disableMicroButton(CharacterMicroButton, true)
        CharacterMicroButton.GwSetAnchorPoint = char_SetAnchorPoint
        cref:SetScript("OnEnter", MainMenuBarMicroButtonMixin.OnEnter)
        cref:SetScript("OnLeave", GameTooltip_Hide)
        cref:HookScript("OnEnter", GW.Friends_OnEnter)
        cref:HookScript("OnEvent", GW.Friends_OnEvent)
        cref:HookScript("OnClick", GW.Friends_OnClick)
        cref:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
        cref:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
        cref:RegisterEvent("BN_FRIEND_INFO_CHANGED")
        cref:RegisterEvent("FRIENDLIST_UPDATE")
        cref:RegisterEvent("CHAT_MSG_SYSTEM")
        cref:RegisterEvent("MODIFIER_STATE_CHANGED")
    else
        cref = CharacterMicroButton
    end
    cref.GwSetAnchorPoint = function(self) cref_SetAnchorPoint(self, mbf) end
    cref:GwSetAnchorPoint()

    -- custom bag microbutton
    local bref = CreateFrame("Button", nil, mbf, "MainMenuBarMicroButton")
    bref.tooltipText = MicroButtonTooltipText(INVENTORY_TOOLTIP, "OPENALLBAGS")
    bref.newbieText = nil
    reskinMicroButton(bref, "BagMicroButton", mbf)

    bref:ClearAllPoints()
    bref:SetPoint("BOTTOMLEFT", cref, "BOTTOMRIGHT", 4, 0)
    --bref:HookScript("OnClick", ToggleAllBags) -- tainting TODO
    bref.interval = 0
    bref:HookScript("OnUpdate", bag_OnUpdate)
    bref:HookScript("OnEnter", GW.Bags_OnEnter)

    -- determine if we are using the default spell & talent buttons
    -- or if we need our custom talent button for the hero panel
    local sref
    if GetSetting("USE_SPELLBOOK_WINDOW") then
        sref = CreateFrame("Button", nil, mbf, "SecureHandlerClickTemplate")
        sref.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
        sref.newbieText = NEWBIE_TOOLTIP_TALENTS
        reskinMicroButton(sref, "SpellbookMicroButton", mbf)
        sref:ClearAllPoints()
        sref:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)

        sref:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        sref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        sref:SetAttribute(
            "_onclick",
            [=[
            if button == "LeftButton" then
                local f = self:GetFrameRef("GwCharacterWindow")
                f:SetAttribute("keytoggle", "1")
                f:SetAttribute("windowpanelopen", "spellbook")
            end
            ]=]
        )
        sref:SetScript("OnEnter", MainMenuBarMicroButtonMixin.OnEnter)
        sref:SetScript("OnLeave", GameTooltip_Hide)
        sref:SetScript("OnHide", GameTooltip_Hide)

        disableMicroButton(SpellbookMicroButton)
    else
        -- SpellbookMicroButton
        sref = SpellbookMicroButton
        sref:ClearAllPoints()
        sref:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)
    end
    -- TalentMicroButton create aur own to prevent actionbar taint
    local taltenMicroButton = CreateFrame("Button", nil, mbf, "SecureHandlerClickTemplate")
	taltenMicroButton.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	taltenMicroButton.newbieText = NEWBIE_TOOLTIP_TALENTS
    reskinMicroButton(taltenMicroButton, "TalentMicroButton", mbf)

    GW.InitTalentDataText()
    taltenMicroButton:ClearAllPoints()
    taltenMicroButton:SetPoint("BOTTOMLEFT", sref, "BOTTOMRIGHT", 4, 0)
    taltenMicroButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    taltenMicroButton:SetScript("OnEnter", GW.TalentButton_OnEnter)
    taltenMicroButton:SetScript("OnClick", GW.TalentButton_OnClick)
    taltenMicroButton:SetScript("OnEvent", GW.TalentButton_OnEvent)
    taltenMicroButton:RegisterEvent("PLAYER_TALENT_UPDATE")
    taltenMicroButton:RegisterEvent("PLAYER_ENTERING_WORLD")
    taltenMicroButton:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED")
    taltenMicroButton:RegisterEvent("CONFIG_COMMIT_FAILED")
    taltenMicroButton:RegisterEvent("TRAIT_CONFIG_UPDATED")
    taltenMicroButton:RegisterEvent("CONFIG_COMMIT_FAILED")
    taltenMicroButton:RegisterEvent("TRAIT_NODE_CHANGED")
    taltenMicroButton:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    taltenMicroButton:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    taltenMicroButton:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
    taltenMicroButton:RegisterEvent("TRAIT_CONFIG_DELETED")
    disableMicroButton(TalentMicroButton)

    -- AchievementMicroButton
    AchievementMicroButton:ClearAllPoints()
    AchievementMicroButton:SetPoint("BOTTOMLEFT", taltenMicroButton, "BOTTOMRIGHT", 4, 0)

    -- QuestLogMicroButton
    QuestLogMicroButton:ClearAllPoints()
    QuestLogMicroButton:SetPoint("BOTTOMLEFT", AchievementMicroButton, "BOTTOMRIGHT", 4, 0)
    QuestLogMicroButton:RegisterEvent("QUEST_LOG_UPDATE")
    QuestLogMicroButton:HookScript("OnEvent", updateQuestLogButton)
    updateQuestLogButton()

    -- GuildMicroButton
    GuildMicroButton:ClearAllPoints()
    GuildMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)

    GuildMicroButton.Ticker = C_Timer.NewTicker(15, function() C_GuildInfo.GuildRoster() end)
    GuildMicroButton:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildMicroButton:RegisterEvent("MODIFIER_STATE_CHANGED")
    GuildMicroButton:RegisterEvent("GUILD_MOTD")
    GuildMicroButton:HookScript("OnEvent", updateGuildButton)
    GuildMicroButton:HookScript("OnEnter", GW.Guild_OnEnter)
    GuildMicroButton:SetScript("OnClick", GW.Guild_OnClick)
    updateGuildButton(GuildMicroButton, "GUILD_ROSTER_UPDATE")

    -- LFDMicroButton
    LFDMicroButton.GwSetAnchorPoint = lfd_SetAnchorPoint
    LFDMicroButton:GwSetAnchorPoint()

    -- EJMicroButton
    EJMicroButton:ClearAllPoints()
    EJMicroButton:SetPoint("BOTTOMLEFT", LFDMicroButton, "BOTTOMRIGHT", 4, 0)
    hooksecurefunc(EJMicroButton, "EvaluateAlertVisibility", function(self)
        MicroButtonPulseStop(self) -- hide blizzard flash
    end)

    -- CollectionsMicroButton
    CollectionsMicroButton:ClearAllPoints()
    CollectionsMicroButton:SetPoint("BOTTOMLEFT", EJMicroButton, "BOTTOMRIGHT", 4, 0)
    hooksecurefunc(CollectionsMicroButton, "EvaluateAlertVisibility", function(self)
        MicroButtonPulseStop(self) -- hide blizzard flash
    end)

    hooksecurefunc("MicroButtonPulse", function(self)
        if self == CollectionsMicroButton or self == EJMicroButton then
            MicroButtonPulseStop(self)
            GW.FrameFlash(self, 1, 0.3, 1, true)
        end
    end)

    hooksecurefunc("MicroButtonPulseStop", function(self)
        if self == CollectionsMicroButton or self == EJMicroButton then
            GW.StopFlash(self)
        end
    end)

    -- MainMenuMicroButton
    MainMenuMicroButton:ClearAllPoints()
    MainMenuMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
    MainMenuMicroButton.MainMenuBarPerformanceBar:SetAlpha(0)
    MainMenuMicroButton.MainMenuBarPerformanceBar:SetScale(0.00001)
    MainMenuMicroButton:HookScript("OnUpdate", hook_MainMenuMicroButton_OnUpdate)

    -- HelpMicroButton
    HelpMicroButton:ClearAllPoints()
    HelpMicroButton:SetPoint("BOTTOMLEFT", MainMenuMicroButton, "BOTTOMRIGHT", 4, 0)

    -- StoreMicroButton
    StoreMicroButton:ClearAllPoints()
    StoreMicroButton:SetPoint("BOTTOMLEFT", HelpMicroButton, "BOTTOMRIGHT", 4, 0)

    -- great vault icom
    local greatVaultIcon = CreateFrame("Button", nil, mbf, "MainMenuBarMicroButton")
    greatVaultIcon.newbieText = nil
    greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT
    reskinMicroButton(greatVaultIcon, "GreatVaultMicroButton", mbf)
    greatVaultIcon:ClearAllPoints()
    greatVaultIcon:SetPoint("BOTTOMLEFT", IsAddOnLoaded("Dominos") and HelpMicroButton or StoreMicroButton, "BOTTOMRIGHT", 4, 0)
    greatVaultIcon:SetScript("OnMouseUp", function(self, button, upInside)
        if button == "LeftButton" and upInside and self:IsEnabled() then
            GW.StopFlash(self) -- Hide flasher if playing
            if WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown() then
                HideUIPanel(WeeklyRewardsFrame)
            else
                WeeklyRewards_ShowUI()
            end
        end
    end)
    -- Disable icon till level 60 then lets flash it one time
    greatVaultIcon:SetEnabled(IsPlayerAtEffectiveMaxLevel())
    greatVaultIcon:RegisterEvent("PLAYER_LEVEL_UP")
    greatVaultIcon:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    greatVaultIcon:RegisterEvent("PLAYER_ENTERING_WORLD")
    greatVaultIcon:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            local level = ...
            if level >= GetMaxLevelForPlayerExpansion() then
                self:SetEnabled(true)
                GW.FrameFlash(self, 1, 0.3, 1, true)
            end
        elseif event == "WEEKLY_REWARDS_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(0.5, function()
                if C_WeeklyRewards.HasAvailableRewards() then
                    greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT .. "\n" .. GW.RGBToHex(GREEN_FONT_COLOR:GetRGB()) .. MYTHIC_PLUS_COLLECT_GREAT_VAULT .. "|r"
                    GW.FrameFlash(greatVaultIcon, 1, 0.3, 1, true)
                else
                    greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT
                    GW.StopFlash(greatVaultIcon)
                end
            end)
        end
    end)

    -- Update icon
    updateIcon = CreateFrame("Button", nil, mbf, "MainMenuBarMicroButton")
    updateIcon.newbieText = nil
    updateIcon.tooltipText = ""
    reskinMicroButton(updateIcon, "UpdateMicroButton", mbf)
    updateIcon:ClearAllPoints()
    updateIcon:SetPoint("BOTTOMLEFT", greatVaultIcon, "BOTTOMRIGHT", 4, 0)
    updateIcon:Hide()
    updateIcon:HookScript("OnEnter", update_OnEnter)
end
AFP("setupMicroButtons", setupMicroButtons)

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
    ElvUI_MicroBar.backdrop:Kill()
    ElvUI_MicroBar:Kill()

    ab.UpdateMicroButtonsParent = GW.NoOp
    ab.UpdateMicroButtons = GW.NoOp
    ab.UpdateMicroButtonTexture = GW.NoOp
    for i = 1, #MICRO_BUTTONS do
        local name = MICRO_BUTTONS[i]
        local btn = _G[name]
        if btn then
            -- remove the backdrop ElvUI adds
            if btn.ClearBackdrop then
                btn:ClearBackdrop()
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

            --btn.handleBackdrop = false
        end
    end

    return false
end
AFP("checkElvUI", checkElvUI)

local function hook_MoveMicroButtons()
    if CharacterMicroButton.GwSetAnchorPoint then
        CharacterMicroButton:GwSetAnchorPoint()
    end
    if LFDMicroButton.GwSetAnchorPoint then
        LFDMicroButton:GwSetAnchorPoint()
    end
end
AFP("hook_MoveMicroButtons", hook_MoveMicroButtons)

local function hook_UpdateMicroButtons()
    HelpMicroButton:Show()
    local m = GuildMicroButton
    m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/GuildMicroButton-Up")
    m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/GuildMicroButton-Up")
    m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/GuildMicroButton-Up")
    m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/GuildMicroButton-Up")
end
AFP("hook_UpdateMicroButtons", hook_UpdateMicroButtons)

local function hook_MainMenuMicroButton_ShowAlert(f)
    if f == TalentMicroButtonAlert and not TalentMicroButton:HasTalentAlertToShow() then
        f:Hide()
    end
end
AFP("hook_MainMenuMicroButton_ShowAlert", hook_MainMenuMicroButton_ShowAlert)

local function mbf_OnLeave(self)
    if not self:IsMouseOver() then
        self:fadeOut()
    end
end
AFP("mbf_OnLeave", mbf_OnLeave)

local function LoadMicroMenu()
    -- compatability with ElvUI (this one is their fault)
    if checkElvUI() then
        return
    end

    -- create our micro button container frame
    local mbf = CreateFrame("Frame", "Gw2MicroBarFrame", UIParent, "GwMicroButtonFrameTmpl")
    local postDragFunction = function(mbf)
        mbf.cf.bg:SetShown(not mbf.isMoved)
    end
    GW.RegisterMovableFrame(mbf, GW.L["Micro Bar"], "MicromenuPos", "VerticalActionBarDummy", nil, {"default"}, nil, postDragFunction)
    mbf:SetPoint("TOPLEFT", mbf.gwMover)

    -- reskin all default (and custom) micro buttons to our styling
    reskinMicroButtons(mbf.cf)

    -- re-do anchoring of the micro buttons to our preferred ordering and setup
    -- custom button overrides & behaviors for each button where necessary
    setupMicroButtons(mbf.cf)

    hooksecurefunc("MoveMicroButtons", hook_MoveMicroButtons)
    hooksecurefunc("UpdateMicroButtons", hook_UpdateMicroButtons)

    -- get rid of the super-persistent PvP talent selector alert TODO
    --if not TalentMicroButton:HasTalentAlertToShow() then
    --   TalentMicroButtonAlert:Hide()
    --end
    hooksecurefunc("MainMenuMicroButton_ShowAlert", hook_MainMenuMicroButton_ShowAlert)

    -- if borders are hidden, hide the bg
    if not GetSetting("BORDER_ENABLED") then
        mbf.cf.bg:Hide()
    end

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
        mbf.cf.fadeOut = function()
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
        mbf.cf:HookScript("OnLeave", mbf_OnLeave)
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
    --hooksecurefunc("MainMenuMicroButton_PositionAlert", gwMicro_PositionAlert) TODO

end
GW.LoadMicroMenu = LoadMicroMenu
