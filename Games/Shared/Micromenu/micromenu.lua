---@class GW2
local GW = select(2, ...)
local L = GW.L
local updateIcon
local microMenuNotificationAnimatedIcons = {}

local PERFORMANCE_BAR_UPDATE_INTERVAL = 1
local MAIL_ICON_ANIMATION_CONFIG = {
    texture = "Interface/AddOns/GW2_UI/textures/icons/microicons/MailMicroButton-up.png",
    size = 30,
    point = {"CENTER", "CENTER", 0, 0},
    blendMode = "ADD",
    vertexColor = {1, 0.84, 0.5, 1},
    fadeInDuration = 0.28,
    fadeOutDuration = 0.20,
    fromAlpha = 0,
    toAlpha = 0.62,
    scaleFrom = 0.94,
    scaleTo = 1.08,
}
local WORKORDER_ICON_ANIMATION_CONFIG = {
    size = 30,
    point = {"CENTER", "CENTER", 0, 0},
    blendMode = "ADD",
    vertexColor = {1, 0.84, 0.5, 1},
    fadeInDuration = 0.28,
    fadeOutDuration = 0.20,
    fromAlpha = 0,
    toAlpha = 0.55,
    scaleFrom = 0.94,
    scaleTo = 1.08,
}

local function IsMicroMenuNotificationAnimationEnabled()
    return GW.settings.MICROMENU_NOTIFICATION_ICON_ANIMATION
end

local function PlayMicroMenuNotificationFlash(frame)
    if not frame then
        return
    end

    if IsMicroMenuNotificationAnimationEnabled() then
        GW.FrameFlash(frame, 1, 0.3, 1, true)
    else
        GW.StopFlash(frame)
    end
end

local function RegisterMicroMenuNotificationIcon(frame, refreshFn)
    if not frame then
        return
    end

    for i = 1, #microMenuNotificationAnimatedIcons do
        if microMenuNotificationAnimatedIcons[i].frame == frame then
            if refreshFn then
                microMenuNotificationAnimatedIcons[i].refresh = refreshFn
            end
            return
        end
    end

    tinsert(microMenuNotificationAnimatedIcons, {frame = frame, refresh = refreshFn})
end

local function ForEachMicroMenuNotificationIcon(callback)
    for i = #microMenuNotificationAnimatedIcons, 1, -1 do
        local entry = microMenuNotificationAnimatedIcons[i]
        if not entry or not entry.frame then
            tremove(microMenuNotificationAnimatedIcons, i)
        else
            callback(entry.frame, entry.refresh)
        end
    end
end

local MICRO_BUTTONS_LOCAL = {
    "CharacterMicroButton",
    "PlayerSpellsMicroButton",
    "SpellbookMicroButton", -- none Retail
    "AchievementMicroButton",
    "TalentMicroButton",
    "QuestLogMicroButton",
    "HousingMicroButton",
    "GuildMicroButton",
    "SocialsMicroButton", -- none Retail
    "LFDMicroButton",
    "EJMicroButton",
    "CollectionsMicroButton",
    "MainMenuMicroButton",
    "HelpMicroButton",
    "StoreMicroButton",
    "ProfessionMicroButton",
    "WorldMapMicroButton", --none Retail
    "PVPMicroButton", --none Retail
    "LFGMicroButton" --none Retail
    }

do
    local SendMessageWaiting
    local function SendMessage()
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", GW.GetVersionString(), (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", GW.GetVersionString(), (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
        elseif IsInGuild() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", GW.GetVersionString(), "GUILD")
        end

        SendMessageWaiting = nil
    end


    local SendRecieveGroupSize = 0
    local myRealm = gsub(GW.myrealm, "[%s%-]", "")
    local myName = GW.myname .. "-" .. myRealm
    local printChatMessage = false
    local function SendRecieve(_, event, prefix, message, _, sender)
        if event == "CHAT_MSG_ADDON" then
            if sender == myName then return end
            if prefix == "GW2UI_VERSIONCHK" then
                local version, subversion, hotfix = string.match(message, "GW2_UI (%d+).(%d+).(%d+)")
                local currentVersion, currentSubversion, currentHotfix = string.match(GW.GetVersionString(), "GW2_UI (%d+).(%d+).(%d+)")
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
                    PlayMicroMenuNotificationFlash(updateIcon)
                    GW.Notice(updateIcon.tooltipText)
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
        local gmb = GW.Classic and SocialsMicroButton or GuildMicroButton
        if (GW.TBC or GW.Wrath) and SocialsMicroButton:IsShown() then
            gmb = SocialsMicroButton
        end
        if gmb == nil then
            return
        end

        local _, numOnlineMembers = GetNumGuildMembers()

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

        if (StoreFrame and not StoreFrame_IsShown()) and GW.DoesAncestryIncludeAny(self, GetMouseFoci()) then
            GW.FetchGuildMembers()
            GW.Guild_OnEnter(self)
        end
    elseif event == "MODIFIER_STATE_CHANGED" then
        if not IsAltKeyDown() and (StoreFrame and not StoreFrame_IsShown()) and GW.DoesAncestryIncludeAny(self, GetMouseFoci())  then
            GW.Guild_OnEnter(self)
        end
    elseif event == "GUILD_MOTD" then
        if (StoreFrame and not StoreFrame_IsShown()) and GW.DoesAncestryIncludeAny(self, GetMouseFoci())  then
            GW.Guild_OnEnter(self)
        end
    end
end

local function requestGuildRosterUpdate(self, force)
    if not IsInGuild() then
        return
    end

    local now = GetTime()
    if not force and self.lastGuildRosterRequest and (now - self.lastGuildRosterRequest) < 30 then
        return
    end

    self.lastGuildRosterRequest = now
    C_GuildInfo.GuildRoster()
end


local function updateQuestLogButton(_, event)
    if event ~= "QUEST_LOG_UPDATE" then
        return
    end

    local qlmb = QuestLogMicroButton
    if qlmb == nil then
        return
    end

    local GetNumQuestLogEntries = (GW.Retail and C_QuestLog.GetNumQuestLogEntries or GetNumQuestLogEntries)
    local _, numQuests = GetNumQuestLogEntries()

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


local function updateBagButton(self)
    local totalEmptySlots = 0
    for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS do
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


local function reskinMicroButton(btn, name, mbf, hook)
    if InCombatLockdown() and btn:IsProtected() then
        GW.CombatQueue:Queue("Update Micromenu: " .. name, reskinMicroButton, {btn, name, mbf, hook})
        return
    end

    if not btn.gwSetParentHooked then
        if btn:GetParent() ~= mbf then
            btn:SetParent(mbf)
        end

        hooksecurefunc(btn, "SetParent", function(self, parent)
            if parent ~= mbf then
                self:SetParent(mbf)
            end
        end)
        btn.gwSetParentHooked = true
    end
    if name == "SpellbookMicroButton" then name = "PlayerSpellsMicroButton" end
    if name == "SocialsMicroButton" then name = "GuildMicroButton" end
    local tex = "Interface/AddOns/GW2_UI/textures/icons/microicons/" .. name .. "-up.png"

    btn:SetSize(24, 24)
    btn:SetHitRectInsets(0, 0, 0, 0)
    btn:SetDisabledTexture(tex)
    btn:SetNormalTexture(tex)
    btn:SetPushedTexture(tex)
    btn:SetHighlightTexture(tex)

    -- temp till we have a own texture (TODO)
    if name == "HousingMicroButton" then
        btn:GetNormalTexture():SetDesaturated(true)
        btn:GetDisabledTexture():SetDesaturated(true)
        btn:GetPushedTexture():SetDesaturated(true)
        btn:GetHighlightTexture():SetDesaturated(true)
    end

    if hook and not btn.gwButtonTextureHooked then
        btn:HookScript("OnEnter", function()
            btn:SetDisabledTexture(tex)
            btn:SetNormalTexture(tex)
            btn:SetPushedTexture(tex)
            btn:SetHighlightTexture(tex)
        end)
        btn:HookScript("OnMouseDown", function()
            btn:SetDisabledTexture(tex)
            btn:SetNormalTexture(tex)
            btn:SetPushedTexture(tex)
            btn:SetHighlightTexture(tex)
        end)
        btn:HookScript("OnMouseUp", function()
            btn:SetDisabledTexture(tex)
            btn:SetNormalTexture(tex)
            btn:SetPushedTexture(tex)
            btn:SetHighlightTexture(tex)
        end)

        btn.gwButtonTextureHooked = true
    end

    --hackfix for texture size
    local t = btn:GetDisabledTexture()
    if t then
        t:ClearAllPoints()
        t:SetPoint("CENTER",btn,"CENTER", 0, 0)
        t:SetSize(32, 32)
        t:SetTexCoord(0, 1, 0, 1)
    end

    t = btn:GetNormalTexture()
    if t then
        t:ClearAllPoints()
        t:SetPoint("CENTER",btn,"CENTER", 0, 0)
        t:SetSize(32, 32)
        t:SetTexCoord(0, 1, 0, 1)
    end

    t = btn:GetPushedTexture()
    if t then
        t:ClearAllPoints()
        t:SetPoint("CENTER",btn,"CENTER", 0, 0)
        t:SetSize(32, 32)
        t:SetTexCoord(0, 1, 0, 1)
    end

    t = btn:GetHighlightTexture()
    if t then
        t:ClearAllPoints()
        t:SetPoint("CENTER",btn,"CENTER", 0, 0)
        t:SetSize(32, 32)
        t:SetTexCoord(0, 1, 0, 1)
    end

    if btn.PushedBackground then btn.PushedBackground:SetTexture() end
    if btn.PushedShadow then btn.PushedShadow:SetTexture() end
    if btn.FlashContent then btn.FlashContent:SetTexture() end
    if btn.Background then btn.Background:SetTexture() end
    if btn.Flash then btn.Flash:SetTexture() end
    if btn.Shadow then btn.Shadow:SetTexture() end

    if btn.PortraitMask then
        btn.PortraitMask:Hide()
    end

    if btn.Portrait then
        btn.Portrait:GwSetInside()
        btn.Portrait:SetAlpha(0)
        btn.Portrait:SetScale(0.00001)
    end

    if btn.FlashBorder then
        btn.FlashBorder:GwSetInside()
        btn.FlashBorder:SetAlpha(0)
        btn.FlashBorder:SetScale(0.00001)
    end

    if not btn.GwNotify then
        btn.GwNotify = btn:CreateTexture(nil, "OVERLAY")
        btn.GwNotifyDark = btn:CreateTexture(nil, "OVERLAY")
        btn.GwNotifyText = btn:CreateFontString(nil, "OVERLAY")

        btn.GwNotify:SetSize(18, 18)
        btn.GwNotify:SetPoint("CENTER", btn, "BOTTOM", 6, 3)
        btn.GwNotify:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop.png")
        btn.GwNotify:SetVertexColor(1, 0, 0, 1)
        btn.GwNotify:Hide()

        btn.GwNotifyDark:SetSize(18, 18)
        btn.GwNotifyDark:SetPoint("CENTER", btn, "BOTTOM", 6, 3)
        btn.GwNotifyDark:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop.png")
        btn.GwNotifyDark:SetVertexColor(0, 0, 0, 0.7)
        btn.GwNotifyDark:Hide()

        btn.GwNotifyText:SetSize(24, 24)
        btn.GwNotifyText:SetPoint("CENTER", btn, "BOTTOM", 7, 2)
        btn.GwNotifyText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        btn.GwNotifyText:SetTextColor(1, 1, 1, 1)
        btn.GwNotifyText:SetShadowColor(0, 0, 0, 0)
        btn.GwNotifyText:Hide()
    end
end


local function reskinMicroButtons(mbf, hook)
    for i = 1, #MICRO_BUTTONS_LOCAL do
        local name = MICRO_BUTTONS_LOCAL[i]
        local btn = _G[name]
        if btn then
            reskinMicroButton(btn, name, mbf, hook)
        end
    end
end


local function disableMicroButton(btn, hideOnly)
    if hideOnly then
        -- hide it off-screen but still want events to run for alerts/notifications
        if GW.Mists then
            btn:SetParent(GW.HiddenFrame)
        else
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -40, 40)
        end
    else
        btn:Disable()
        btn:UnregisterAllEvents()
        btn:SetScript("OnUpdate", nil)
        btn:Hide()
    end
end


local function update_OnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, L["GW2 UI Update"])
    GameTooltip:AddLine(self.tooltipText)
    GameTooltip:Show()
end


local AddonMemoryArray = {}
local function LatencyInfoToolTip()
    local frameRate = GW.RoundInt(GetFramerate())
    local down, up, lagHome, lagWorld = GetNetStats()
    local addonMemory = 0
    local numAddons = C_AddOns.GetNumAddOns()

    -- wipe and reuse our memtable to avoid temp pre-GC bloat on the tooltip (still get a bit from the sort)
    for i = 1, #AddonMemoryArray do
        AddonMemoryArray[i].addonIndex = 0
        AddonMemoryArray[i].addonMemory = 0
    end

    UpdateAddOnMemoryUsage()
    GameTooltip:SetOwner(MainMenuMicroButton, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10)
    GameTooltip:ClearLines()
    GameTooltip_AddNewbieTip(MainMenuMicroButton, MainMenuMicroButton.tooltipText, 1.0, 1.0, 1.0, MainMenuMicroButton.newbieText)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["FPS"] .. " " .. frameRate .." fps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(L["Latency (Home)"] .. " " .. lagHome .." ms", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(L["Latency (World)"] .. " " .. lagWorld .." ms", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(L["Bandwidth (Download)"] .. " " .. GW.RoundDec(down,2) .. " Kbps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(L["Bandwidth (Upload)"] .. " " .. GW.RoundDec(up,2) .. " Kbps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)

    for i = 1, numAddons do
        addonMemory = addonMemory + GetAddOnMemoryUsage(i)
    end

    GameTooltip:AddLine(L["Memory for Addons:"] .. " " .. GW.RoundDec(addonMemory / 1024, 2) .. " MB", 0.8, 0.8, 0.8)

    for i = 1, numAddons do
        if type(AddonMemoryArray[i]) ~= "table" then
            AddonMemoryArray[i] = {}
        end
        AddonMemoryArray[i].addonIndex = i
        AddonMemoryArray[i].addonMemory = GetAddOnMemoryUsage(i)
    end

    table.sort(AddonMemoryArray, function(a, b) return a.addonMemory > b.addonMemory end)

    for _, v in pairs(AddonMemoryArray) do
            if v.addonIndex ~= 0 and (C_AddOns.IsAddOnLoaded(v.addonIndex) and v.addonMemory ~= 0) then
                addonMemory = GW.RoundDec(v.addonMemory / 1024, 2)
                if addonMemory ~= "0.00" then
                    GameTooltip:AddLine("(" .. addonMemory .. " MB) " .. C_AddOns.GetAddOnInfo(v.addonIndex), 0.8, 0.8, 0.8)
                end
            end
    end
    GameTooltip:Show()
end

local function refreshMainMenuMicroButton(self, elapsed)
    if self.updateInterval ~= PERFORMANCE_BAR_UPDATE_INTERVAL then
        return
    end
    self:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/mainmenumicrobutton-up.png")
    self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/mainmenumicrobutton-up.png")
    self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/mainmenumicrobutton-up.png")
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/mainmenumicrobutton-up.png")
    if self.MainMenuBarPerformanceBar then
        self.MainMenuBarPerformanceBar:SetAlpha(0)
        self.MainMenuBarPerformanceBar:SetScale(0.00001)
    elseif MainMenuMicroButton.PerformanceIndicator then
        MainMenuMicroButton.PerformanceIndicator:SetAlpha(0)
        MainMenuMicroButton.PerformanceIndicator:SetScale(0.00001)
    else
        MainMenuBarPerformanceBarFrame:Hide()
        if MainMenuMicroButton.hover then
            LatencyInfoToolTip()
        end
    end
end


-- mail icon
local function mailIconTooltip()
    local senders = { GetLatestThreeSenders() }
	local headerText = #senders >= 1 and HAVE_MAIL_FROM or HAVE_MAIL
    GameTooltip:AddLine(headerText, 1, 1, 1)
    for _, sender in ipairs(senders) do
        GameTooltip:AddLine(sender, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function stopMailIconNotificationAnimation(self)
    GW.StopIconNotificationAnimation(self)
    if self.GwNotify then
        self.GwNotify:Hide()
    end

    GW.StopFlash(self)
end

local function updateMailIconNotificationAnimation(self, playEntrancePop)
    if not self or not self.GwNotify then
        return
    end

    if not IsMicroMenuNotificationAnimationEnabled() then
        stopMailIconNotificationAnimation(self)
        self.GwNotify:Show()
        return
    end

    if playEntrancePop then
        self.GwNotify:Hide()
        GW.PlayIconNotificationAnimation(self, MAIL_ICON_ANIMATION_CONFIG)
        PlayMicroMenuNotificationFlash(self)
    else
        GW.StopIconNotificationAnimation(self)
    end
end

local function mailIconOnEvent(self)
    if HasNewMail() then
        self:Show()
        updateMailIconNotificationAnimation(self, true)
        self.gwHasNewMail = true
        if GameTooltip:IsOwned(self) then
            mailIconTooltip()
        end
    else
        self.gwHasNewMail = false
        stopMailIconNotificationAnimation(self)
        self:Hide()
        self.GwNotify:Hide()
    end
end

local function mailIconOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if GameTooltip:IsOwned(self) then
        mailIconTooltip()
    end
end

function GW.ToggleMicroMenuNotificationIconAnimation()
    local animationsEnabled = IsMicroMenuNotificationAnimationEnabled()

    ForEachMicroMenuNotificationIcon(function(frame, refreshFn)
        if refreshFn then
            refreshFn(frame)
        end

        if not animationsEnabled then
            GW.StopFlash(frame)
            GW.StopIconNotificationAnimation(frame)
        end
    end)
end

--workoOrderIcon
local function workOrderIconOnEvent(self, event)
    if event == "CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS" or event == "PLAYER_ENTERING_WORLD" then
        self.countInfos = C_CraftingOrders.GetPersonalOrdersInfo()
        if #self.countInfos > 0 then
            local shouldPlayEntrance = not self:IsShown()
            self:Show()
            if IsMicroMenuNotificationAnimationEnabled() then
                self.GwNotify:Hide()
                if shouldPlayEntrance then
                    GW.PlayIconNotificationAnimation(self, WORKORDER_ICON_ANIMATION_CONFIG)
                    PlayMicroMenuNotificationFlash(self)
                end
            else
                GW.StopIconNotificationAnimation(self)
                self.GwNotify:Show()
            end
        else
            GW.StopIconNotificationAnimation(self)
            self:Hide()
            self.GwNotify:Hide()
        end
    end
end

local function workOrderIconOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(MAILFRAME_CRAFTING_ORDERS_TOOLTIP_TITLE, 1, 1, 1)
    for _, countInfo in ipairs(self.countInfos) do
        GameTooltip:AddLine(PERSONAL_CRAFTING_ORDERS_AVAIL_FMT:format(countInfo.numPersonalOrders, countInfo.professionName), 1, 1, 1)
    end
    GameTooltip:Show()
end

local function ToggleEventTimerIcon(mbf)
    Gw2UpdateMicroMenuButton:ClearAllPoints()

    if GW.settings.MICROMENU_EVENT_TIMER_ICON then
        if not Gw2EventTimerMicroMenuButton then
            local eventTimerIcon = CreateFrame("Button", "Gw2EventTimerMicroMenuButton", mbf, "MainMenuBarMicroButton")
            eventTimerIcon.newbieText = nil
            eventTimerIcon.tooltipText = L["Event timer"]
            eventTimerIcon.textureName = "EventMicroButton"
            reskinMicroButton(eventTimerIcon, "EventMicroButton", mbf)
            eventTimerIcon:ClearAllPoints()
            eventTimerIcon:SetPoint("BOTTOMLEFT", Gw2GreateVaultMicroMenuButton, "BOTTOMRIGHT", 4, 0)
            eventTimerIcon:SetScript("OnEnter", GW.EventTrackerFunctions.onEnterAll)
        end

        Gw2EventTimerMicroMenuButton:Show()

        updateIcon:SetPoint("BOTTOMLEFT", Gw2EventTimerMicroMenuButton, "BOTTOMRIGHT", 4, 0)
    else
        if Gw2EventTimerMicroMenuButton then
            Gw2EventTimerMicroMenuButton:Hide()
        end
        updateIcon:SetPoint("BOTTOMLEFT", Gw2GreateVaultMicroMenuButton, "BOTTOMRIGHT", 4, 0)
    end
end
GW.ToggleEventTimerMicroMenuIcon = ToggleEventTimerIcon

local function setupMicroButtons(mbf)
    -- CharacterMicroButton
    -- determine if we are using the default char button (for default charwin)
    -- or if we need to create our own char button for the custom hero panel
    local cref
    if GW.settings.USE_CHARACTER_WINDOW then
        --IsProtected()
        cref = CreateFrame("Button", "GwCharacterMicroButton", mbf, ((GW.Retail or GW.Wrath) and "" or "MainMenuBarMicroButton,") .. "SecureHandlerClickTemplate")
        if GW.Retail then
            Mixin(cref, MainMenuBarMicroButtonMixin)
        end
        cref.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
        cref.newbieText = NEWBIE_TOOLTIP_CHARACTER
        cref.textureName = "CharacterMicroButton"
        reskinMicroButton(cref, "CharacterMicroButton", mbf, true)
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
        disableMicroButton(CharacterMicroButton, GW.Retail)
        if GW.Retail then
            cref:SetScript("OnEnter", MainMenuBarMicroButtonMixin.OnEnter)
            cref:SetScript("OnLeave", function() MainMenuBarMicroButtonMixin.OnLeave(cref); GameTooltip:Hide() end)
        end
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
        if MicroButtonPortrait then
            MicroButtonPortrait:Hide()
        end
    end
    cref.GwSetAnchorPoint = function(self)
        -- this must also happen in the auto-layout update hook which is why we do it like this
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", mbf, "TOPLEFT", 5, -3)
    end
    cref:GwSetAnchorPoint()

    -- custom bag microbutton
    local bref = CreateFrame("Button", nil, mbf, ((GW.Retail or GW.Wrath) and "" or "MainMenuBarMicroButton"))
    bref.tooltipText = MicroButtonTooltipText(INVENTORY_TOOLTIP, "OPENALLBAGS")
    bref.newbieText = nil
    bref.textureName = "BagMicroButton"
    reskinMicroButton(bref, "BagMicroButton", mbf)
    bref:ClearAllPoints()
    bref:SetPoint("BOTTOMLEFT", cref, "BOTTOMRIGHT", 4, 0)
    bref:HookScript("OnClick", ToggleAllBags)
    bref:HookScript("OnEvent", updateBagButton)
    bref:RegisterEvent("PLAYER_ENTERING_WORLD")
    bref:RegisterEvent("BAG_UPDATE_DELAYED")
    bref:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    updateBagButton(bref)
    bref:HookScript("OnEnter", GW.Bags_OnEnter)

    -- SpellbookMicroButton
    local sref
    if not GW.Retail then
        if GW.settings.USE_SPELLBOOK_WINDOW then
            sref = CreateFrame("Button", "GwPlayerSpellsMicroButton", mbf, (GW.Wrath and "" or "MainMenuBarMicroButton,") .. "SecureHandlerClickTemplate")
            sref.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
            sref.newbieText = NEWBIE_TOOLTIP_SPELLBOOK
            reskinMicroButton(sref, "SpellbookMicroButton", mbf)
            sref:ClearAllPoints()
            sref:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)
            sref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
            sref:SetAttribute(
                "_onclick",
                [=[
                local f = self:GetFrameRef("GwCharacterWindow")
                f:SetAttribute("keytoggle", "1")
                f:SetAttribute("windowpanelopen", "spellbook")
                ]=]
            )

            disableMicroButton(SpellbookMicroButton)
        else
            sref = SpellbookMicroButton
            sref:ClearAllPoints()
            sref:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)
        end
    else
        PlayerSpellsMicroButton:ClearAllPoints()
        PlayerSpellsMicroButton:SetPoint("BOTTOMLEFT", bref, "BOTTOMRIGHT", 4, 0)
        sref = PlayerSpellsMicroButton
    end

    --TalentMicroButton
    local tref
    if not GW.Retail then
        if GW.settings.USE_TALENT_WINDOW then
            tref = CreateFrame("Button", "GwTalentMicroButton", mbf, (GW.Wrath and "" or "MainMenuBarMicroButton,") .. "SecureHandlerClickTemplate")
            tref.tooltipText = MicroButtonTooltipText(TALENTS, "TOGGLETALENTS")
            tref.newbieText = NEWBIE_TOOLTIP_TALENTS
            reskinMicroButton(tref, "TalentMicroButton", mbf)
            tref:ClearAllPoints()
            tref:SetPoint("BOTTOMLEFT", sref, "BOTTOMRIGHT", 4, 0)

            tref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
            tref:SetAttribute(
                "_onclick",
                [=[
                local f = self:GetFrameRef("GwCharacterWindow")
                f:SetAttribute("keytoggle", "1")
                f:SetAttribute("windowpanelopen", "talents")
                ]=]
            )

            if GW.Classic or GW.TBC then
                disableMicroButton(TalentMicroButton, true)
            elseif GW.Mists or GW.Wrath then
                TalentMicroButton:ClearAllPoints()
                TalentMicroButton:SetPoint("BOTTOMLEFT", sref, "BOTTOMRIGHT", 8, 0) -- 8 because blizzard is setting is Achievement Button position back to 0, so we add the space here
                TalentMicroButton:SetAlpha(0)
                TalentMicroButton:EnableMouse(false)
            end
        else
            -- TalentMicroButton
            if TalentMicroButton:IsShown() then
                tref = TalentMicroButton
                tref:ClearAllPoints()
                tref:SetPoint("BOTTOMLEFT", sref, "BOTTOMRIGHT", 4, 0)
            else
                tref = sref
            end
        end
    else
        tref = sref
    end

    -- AchievementMicroButton
    local aref
    if GW.Retail or GW.Mists or GW.Wrath then
        AchievementMicroButton:ClearAllPoints()
        AchievementMicroButton:SetPoint("BOTTOMLEFT", tref, "BOTTOMRIGHT", 4, 0)
        aref = AchievementMicroButton
    else
        aref = tref
    end

    -- QuestLogMicroButton
    QuestLogMicroButton:ClearAllPoints()
    QuestLogMicroButton:SetPoint("BOTTOMLEFT", aref, "BOTTOMRIGHT", 4, 0)
    QuestLogMicroButton:RegisterEvent("QUEST_LOG_UPDATE")
    QuestLogMicroButton:HookScript("OnEvent", updateQuestLogButton)
    updateQuestLogButton()

    -- Retail HousingMicroButton
    local qref = QuestLogMicroButton
    if HousingMicroButton and HousingMicroButton:IsShown() then
        HousingMicroButton:ClearAllPoints()
        HousingMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)
        qref = HousingMicroButton
    end

    -- GuildMicroButton
   local gref
    for i = 1, (GW.Classic or GW.TBC or GW.Wrath) and 2 or 1 do
        if i == 1 then
            gref = GuildMicroButton
        else
            gref = SocialsMicroButton
        end
        gref:ClearAllPoints()
        gref:SetPoint("BOTTOMLEFT", qref, "BOTTOMRIGHT", 4, 0)
        gref:RegisterEvent("GUILD_ROSTER_UPDATE")
        gref:RegisterEvent("MODIFIER_STATE_CHANGED")
        gref:RegisterEvent("GUILD_MOTD")
        gref:HookScript("OnEvent", updateGuildButton)
        gref:HookScript("OnEnter", function(self)
            requestGuildRosterUpdate(self, true)
            GW.Guild_OnEnter(self)
        end)
        gref:SetScript("OnClick", GW.Guild_OnClick)
        if not (GW.Classic or GW.TBC or GW.Wrath) then
            hooksecurefunc(gref, "UpdateTabard", function()
                gref:GetDisabledTexture():SetAlpha(1)
                gref:GetNormalTexture():SetAlpha(1)
                gref:GetPushedTexture():SetAlpha(1)
                gref:GetHighlightTexture():SetAlpha(1)

                gref:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
                gref:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
                gref:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
                gref:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
            end)
        end
        requestGuildRosterUpdate(gref, true)
        updateGuildButton(gref, "GUILD_ROSTER_UPDATE")
    end

    local pref
    if GW.Retail then
        -- LFDMicroButton
        LFDMicroButton:ClearAllPoints()
        LFDMicroButton:SetPoint("BOTTOMLEFT", gref, "BOTTOMRIGHT", 4, 0)

        -- EJMicroButton
        EJMicroButton:ClearAllPoints()
        EJMicroButton:SetPoint("BOTTOMLEFT", LFDMicroButton, "BOTTOMRIGHT", 4, 0)

        -- CollectionsMicroButton
        CollectionsMicroButton:ClearAllPoints()
        CollectionsMicroButton:SetPoint("BOTTOMLEFT", EJMicroButton, "BOTTOMRIGHT", 4, 0)
        RegisterMicroMenuNotificationIcon(EJMicroButton)
        RegisterMicroMenuNotificationIcon(CollectionsMicroButton)
        hooksecurefunc("MicroButtonPulse", function(self)
            if self == CollectionsMicroButton or self == EJMicroButton then
                PlayMicroMenuNotificationFlash(self)
            end
        end)

        hooksecurefunc("MicroButtonPulseStop", function(self)
            if self == CollectionsMicroButton or self == EJMicroButton then
                GW.StopFlash(self)
            end
        end)

        --ProfessionMicroButton
        if GW.settings.USE_PROFESSION_WINDOW then
            pref = CreateFrame("Button", "GwProfessionMicroButton", mbf, "SecureHandlerClickTemplate")
            if GW.Retail then
                Mixin(pref, MainMenuBarMicroButtonMixin)
            end
            pref.tooltipText = MicroButtonTooltipText(PROFESSIONS_BUTTON, "TOGGLEPROFESSIONBOOK")
            pref.newbieText = nil
            pref.textureName = "Professions"
            reskinMicroButton(pref, "ProfessionMicroButton", mbf, true)
            pref:ClearAllPoints()
            pref:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
            pref:RegisterForClicks("AnyUp")
            pref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
            pref:SetAttribute(
                "_onclick",
                [=[
                    if button ~= "LeftButton" then return end
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", "1")
                    f:SetAttribute("windowpanelopen", "professions")
                ]=]
            )
            pref:SetScript("OnEnter", MainMenuBarMicroButtonMixin.OnEnter)
            pref:SetScript("OnLeave", function() MainMenuBarMicroButtonMixin.OnLeave(pref); GameTooltip:Hide() end)
            disableMicroButton(ProfessionMicroButton, true)
        else
            pref = ProfessionMicroButton
            pref:ClearAllPoints()
            pref:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
        end
    elseif GW.Mists or GW.Wrath then
        -- CollectionsMicroButton
        CollectionsMicroButton:ClearAllPoints()
        CollectionsMicroButton:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", 4, 0)

        -- PVPMicroButton
        local pvpref
        if GW.Wrath then
            if GW.settings.USE_CHARACTER_WINDOW then
                pvpref = CreateFrame("Button", "GwPvpMicroButton", mbf, "SecureHandlerClickTemplate")
                pvpref.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
                pvpref.newbieText = NEWBIE_TOOLTIP_PVP
                reskinMicroButton(pvpref, "PvpMicroButton", mbf)
                pvpref:ClearAllPoints()
                pvpref:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)

                pvpref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
                pvpref:SetAttribute(
                    "_onclick",
                    [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", "1")
                    f:SetAttribute("windowpanelopen", "pvp")
                    ]=]
                )

                --disableMicroButton(PVPMicroButton, true)
                PVPMicroButton:ClearAllPoints()
                PVPMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
                PVPMicroButton:SetAlpha(0)
                PVPMicroButton:EnableMouse(false)
            else
                pvpref = PVPMicroButton
                pvpref:ClearAllPoints()
                pvpref:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
            end
        else
            pvpref = PVPMicroButton
            pvpref:ClearAllPoints()
            pvpref:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
            PVPMicroButtonTexture:SetAlpha(0)
        end

        -- LFGMicroButton
        LFGMicroButton:ClearAllPoints()
        LFGMicroButton:SetPoint("BOTTOMLEFT", pvpref, "BOTTOMRIGHT", 4, 0)

        if GW.Mists then
            -- EJMicroButton
            EJMicroButton:ClearAllPoints()
            EJMicroButton:SetPoint("BOTTOMLEFT", LFGMicroButton, "BOTTOMRIGHT", 4, 0)

            StoreMicroButton:ClearAllPoints()
            StoreMicroButton:SetPoint("BOTTOMLEFT", EJMicroButton, "BOTTOMRIGHT", 4, 0)
            pref = StoreMicroButton
        else
            pref = LFGMicroButton
        end
    else
         -- WorldMapMicroButton
        WorldMapMicroButton:ClearAllPoints()
        WorldMapMicroButton:SetPoint("BOTTOMLEFT", gref, "BOTTOMRIGHT", 4, 0)
        pref = WorldMapMicroButton
    end

    -- MainMenuMicroButton
    MainMenuMicroButton:ClearAllPoints()
    MainMenuMicroButton:SetPoint("BOTTOMLEFT", pref, "BOTTOMRIGHT", 4, 0)
    if MainMenuMicroButton.MainMenuBarPerformanceBar then
        MainMenuMicroButton.MainMenuBarPerformanceBar:SetAlpha(0)
        MainMenuMicroButton.MainMenuBarPerformanceBar:SetScale(0.00001)
    elseif MainMenuMicroButton.PerformanceIndicator then
        MainMenuMicroButton.PerformanceIndicator:SetAlpha(0)
        MainMenuMicroButton.PerformanceIndicator:SetScale(0.00001)
    else
        MainMenuBarPerformanceBar:SetAlpha(0)
        MainMenuBarPerformanceBar:SetScale(0.00001)
        if MainMenuBarDownload then MainMenuBarDownload:Hide() end
    end
    MainMenuMicroButton:HookScript("OnUpdate", refreshMainMenuMicroButton)

    -- HelpMicroButton
    HelpMicroButton:ClearAllPoints()
    HelpMicroButton:SetPoint("BOTTOMLEFT", MainMenuMicroButton, "BOTTOMRIGHT", 4, 0)

    if GW.Retail then
        StoreMicroButton:ClearAllPoints()
        StoreMicroButton:SetPoint("BOTTOMLEFT", HelpMicroButton, "BOTTOMRIGHT", 4, 0)
        -- great vault icom
        local greatVaultIcon = CreateFrame("Button", "Gw2GreateVaultMicroMenuButton", mbf, "MainMenuBarMicroButton")
        greatVaultIcon.newbieText = nil
        greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT
        greatVaultIcon.textureName = "GreatVaultMicroButton"
        reskinMicroButton(greatVaultIcon, "GreatVaultMicroButton", mbf)
        RegisterMicroMenuNotificationIcon(greatVaultIcon)
        greatVaultIcon:ClearAllPoints()
        greatVaultIcon:SetPoint("BOTTOMLEFT", C_AddOns.IsAddOnLoaded("Dominos") and HelpMicroButton or StoreMicroButton, "BOTTOMRIGHT", 4, 0)
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
        -- Disable icon till level 70 then lets flash it one time
        greatVaultIcon:SetEnabled(IsPlayerAtEffectiveMaxLevel())
        greatVaultIcon:RegisterEvent("PLAYER_LEVEL_UP")
        greatVaultIcon:RegisterEvent("WEEKLY_REWARDS_UPDATE")
        greatVaultIcon:RegisterEvent("PLAYER_ENTERING_WORLD")
        greatVaultIcon:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_LEVEL_UP" then
                local level = ...
                if level >= GetMaxLevelForPlayerExpansion() then
                    self:SetEnabled(true)
                    PlayMicroMenuNotificationFlash(self)
                end
            elseif event == "WEEKLY_REWARDS_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
                C_Timer.After(0.5, function()
                    if C_WeeklyRewards.HasAvailableRewards() then
                        greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT .. "\n" .. GW.RGBToHex(GREEN_FONT_COLOR:GetRGB()) .. MYTHIC_PLUS_COLLECT_GREAT_VAULT .. "|r"
                        PlayMicroMenuNotificationFlash(greatVaultIcon)
                    else
                        greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT
                        GW.StopFlash(greatVaultIcon)
                    end
                end)
            end
        end)
    end
end

local function UpdateHelpTicketButtonAnchor()
    local ticket = HelpOpenWebTicketButton
	if not ticket then return end
    local btn = GwCharacterMicroButton or CharacterMicroButton
    local _, y = btn:GetCenter()
    local height, middle = 17, GW.screenHeight

    ticket:ClearAllPoints()
    ticket:SetPoint("CENTER", btn, 0, (y and y >= middle) and height or -height)
end

local function SetupNotificationArea(mbf)
    -- Update icon
    updateIcon = CreateFrame("Button", "Gw2UpdateMicroMenuButton", mbf, "MainMenuBarMicroButton")
    updateIcon.newbieText = nil
    updateIcon.tooltipText = ""
    updateIcon.textureName = "UpdateMicroButton"
    reskinMicroButton(updateIcon, "UpdateMicroButton", mbf)
    updateIcon:ClearAllPoints()
    updateIcon:SetPoint("BOTTOMLEFT", GW.Retail and Gw2GreateVaultMicroMenuButton or HelpMicroButton, "BOTTOMRIGHT", 4, 0)
    updateIcon:Hide()
    updateIcon:HookScript("OnEnter", update_OnEnter)
    updateIcon:SetFrameLevel(mbf.cf:GetFrameLevel() + 10)
    RegisterMicroMenuNotificationIcon(updateIcon)

    -- Mail icon
    local mailIcon = CreateFrame("Button", nil, mbf, "MainMenuBarMicroButton")
    mailIcon:RegisterEvent("UPDATE_PENDING_MAIL")
    mailIcon.newbieText = nil
    mailIcon.tooltipText = ""
    mailIcon.textureName = "MailMicroButton"
    reskinMicroButton(mailIcon, "MailMicroButton", mbf)
    mailIcon:ClearAllPoints()
    mailIcon:SetPoint("BOTTOMLEFT", updateIcon, "BOTTOMRIGHT", 4, 0)
    mailIcon:Hide()
    mailIcon:HookScript("OnEnter", mailIconOnEnter)
    mailIcon:HookScript("OnLeave", GameTooltip_Hide)
    mailIcon:SetScript("OnEvent", mailIconOnEvent)
    mailIcon:SetFrameLevel(mbf.cf:GetFrameLevel() + 10)
    RegisterMicroMenuNotificationIcon(mailIcon, function(frame)
        mailIconOnEvent(frame)
    end)

    if GW.Retail then
        -- workorder icon
        local workOrderIcon = CreateFrame("Button", "Gw2NotificationIconWorkorder", mbf, "MainMenuBarMicroButton")
        workOrderIcon:RegisterEvent("CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS")
        workOrderIcon:RegisterEvent("PLAYER_ENTERING_WORLD")
        workOrderIcon.newbieText = nil
        workOrderIcon.tooltipText = ""
        workOrderIcon.textureName = "ProfessionMicroButton"
        reskinMicroButton(workOrderIcon, "ProfessionMicroButton", mbf)
        workOrderIcon:ClearAllPoints()
        workOrderIcon:SetPoint("BOTTOMLEFT", mailIcon, "BOTTOMRIGHT", 4, 0)
        workOrderIcon:Hide()
        workOrderIcon:HookScript("OnEnter", workOrderIconOnEnter)
        workOrderIcon:HookScript("OnLeave", GameTooltip_Hide)
        workOrderIcon:SetScript("OnEvent", workOrderIconOnEvent)
        workOrderIcon:SetFrameLevel(mbf.cf:GetFrameLevel() + 10)
        RegisterMicroMenuNotificationIcon(workOrderIcon, function(frame)
            workOrderIconOnEvent(frame, "PLAYER_ENTERING_WORLD")
        end)
    end

    -- blizzard ticket icon
	if MicroMenu and MicroMenu.UpdateHelpTicketButtonAnchor then
        hooksecurefunc(MicroMenu, 'UpdateHelpTicketButtonAnchor', UpdateHelpTicketButtonAnchor)
        UpdateHelpTicketButtonAnchor()
    end
end

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
    if ElvUI_MicroBar.backdrop then
        ElvUI_MicroBar.backdrop:GwKill()
    end
    ElvUI_MicroBar:GwKill()

    ab.UpdateMicroButtonsParent = GW.NoOp
    ab.UpdateMicroButtons = GW.NoOp
    ab.UpdateMicroButtonTexture = GW.NoOp
    for i = 1, #MICRO_BUTTONS_LOCAL do
        local name = MICRO_BUTTONS_LOCAL[i]
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
        end
    end

    return false
end


local hook_UpdateMicroButtons

local function queueMicroMenuUpdate()
    if InCombatLockdown() then
        GW.CombatQueue:Queue("Update Micromenu", hook_UpdateMicroButtons)
        return
    end

    C_Timer.After(0, function()
        if InCombatLockdown() then
            GW.CombatQueue:Queue("Update Micromenu", hook_UpdateMicroButtons)
            return
        end

        hook_UpdateMicroButtons(true)
    end)
end

hook_UpdateMicroButtons = function(fromDeferredUpdate)
    if GW.Retail and not fromDeferredUpdate then
        queueMicroMenuUpdate()
        return
    end

    if InCombatLockdown() then
        GW.CombatQueue:Queue("Update Micromenu", hook_UpdateMicroButtons)
        return
    end

    HelpMicroButton:Show()
    local m = GW.Classic and SocialsMicroButton or GuildMicroButton
    if (GW.TBC or GW.Wrath) and SocialsMicroButton:IsShown() then
        m = SocialsMicroButton
    end
    m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
    m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
    m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
    m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")

    if MicroButtonPortrait then MicroButtonPortrait:Hide() end

    reskinMicroButtons(Gw2MicroBarFrame.cf)

    if GW.Classic or GW.TBC then
        local tref
        if GW.settings.USE_TALENT_WINDOW then
            tref = GwTalentMicroButton
        elseif TalentMicroButton:IsShown() then
            tref = TalentMicroButton
        else
            tref = GW.settings.USE_SPELLBOOK_WINDOW and GwPlayerSpellsMicroButton or SpellbookMicroButton
        end
        QuestLogMicroButton:ClearAllPoints()
        QuestLogMicroButton:SetPoint("BOTTOMLEFT", tref, "BOTTOMRIGHT", 4, 0)

        SocialsMicroButton:ClearAllPoints()
        SocialsMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)

        GuildMicroButton:ClearAllPoints()
        GuildMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)
    elseif GW.Wrath then
        local tref
        if GW.settings.USE_TALENT_WINDOW then
            tref = GwTalentMicroButton
        elseif TalentMicroButton:IsShown() then
            tref = TalentMicroButton
        else
            tref = GW.settings.USE_SPELLBOOK_WINDOW and GwPlayerSpellsMicroButton or SpellbookMicroButton
        end
        QuestLogMicroButton:ClearAllPoints()
        QuestLogMicroButton:SetPoint("BOTTOMLEFT", AchievementMicroButton, "BOTTOMRIGHT", 4, 0)

        SocialsMicroButton:ClearAllPoints()
        SocialsMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)

        GuildMicroButton:ClearAllPoints()
        GuildMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", 4, 0)

        AchievementMicroButton:ClearAllPoints()
        AchievementMicroButton:SetPoint("BOTTOMLEFT", tref, "BOTTOMRIGHT", 4, 0)

        CollectionsMicroButton:ClearAllPoints()
        CollectionsMicroButton:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", 4, 0)

        PVPMicroButton:ClearAllPoints()
        PVPMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)
    elseif GW.Mists then
        AchievementMicroButton:ClearAllPoints()
        AchievementMicroButton:SetPoint("BOTTOMLEFT", (GwTalentMicroButton or TalentMicroButton), "BOTTOMRIGHT", 4, 0)

        CollectionsMicroButton:ClearAllPoints()
        CollectionsMicroButton:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", 4, 0)

        PVPMicroButton:ClearAllPoints()
        PVPMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", 4, 0)

        MainMenuMicroButton:ClearAllPoints()
        MainMenuMicroButton:SetPoint("BOTTOMLEFT", StoreMicroButton, "BOTTOMRIGHT", 4, 0)
    end
end


local function mbf_OnLeave(self)
    if not self:IsMouseOver() and GW.settings.FADE_MICROMENU then
        self:fadeOut()
    end
end


local function LoadMicroMenu()
    if checkElvUI() or not GW.settings.micromenu.enabled then
        return
    end

    if GW.Retail or GW.TBC or GW.Wrath then
        MicroMenuContainer:GwKillEditMode()
    elseif GW.Classic then
        PERFORMANCEBAR_UPDATE_INTERVAL = 1
    end

    -- create our micro button container frame
    local mbf = CreateFrame("Frame", "Gw2MicroBarFrame", UIParent, "GwMicroButtonFrameTmpl")
    mbf:SetSize(GW.Retail and 500 or (GW.Mists or GW.Wrath) and 370 or 280, 41)
    local postDragFunction = function(mbf)
        mbf.cf.bg:SetShown(not mbf.isMoved)
    end
    GW.RegisterMovableFrame(mbf, GW.L["Micro Bar"], "MicromenuPos", "Blizzard,Widgets", nil, {"default"}, nil, postDragFunction)
    mbf:SetPoint("TOPLEFT", mbf.gwMover)

    -- reskin all default (and custom) micro buttons to our styling
    reskinMicroButtons(mbf.cf, true)

    -- re-do anchoring of the micro buttons to our preferred ordering and setup
    -- custom button overrides & behaviors for each button where necessary
    setupMicroButtons(mbf.cf)

    -- setup our notification area
    SetupNotificationArea(mbf)

    if GW.Retail then
        -- event timer icon
        ToggleEventTimerIcon(mbf.cf)
    end

    if not (GW.Retail or GW.TBC or GW.Wrath) then
        for i = 1, #MICRO_BUTTONS do
            MICRO_BUTTONS[i] = nil
        end

        UpdateMicroButtonsParent(mbf.cf)

        hooksecurefunc(
            "MoveMicroButtons",
            function()
                if CharacterMicroButton.GwSetAnchorPoint then
                    CharacterMicroButton:GwSetAnchorPoint()
                end
            end
        )
    end

    hooksecurefunc("UpdateMicroButtons", hook_UpdateMicroButtons)

    -- if borders are hidden, hide the bg
    if not GW.settings.BORDER_ENABLED then
        mbf.cf.bg:Hide()
    end

    -- if set to fade micro menu, add fader
    mbf.cf:SetAttribute("shouldFade", GW.settings.FADE_MICROMENU)
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
        local shouldFade = cf:GetAttribute("shouldFade")
        if cf:IsShown() or not shouldFade then
            return
        end
        cf:UnregisterAutoHide()
        cf:Show()
        cf:CallMethod("fadeIn", cf)
        cf:RegisterAutoHide(cf:GetAttribute("fadeTime") + 0.25)
    ]=])
    mbf.cf:HookScript("OnLeave", mbf_OnLeave)
    mbf.cf:SetShown(not GW.settings.FADE_MICROMENU)

    if GW.Retail then
        -- fix alert positions and hide the micromenu bar
        MicroButtonAndBagsBar:SetAlpha(0)
        MicroButtonAndBagsBar:EnableMouse(false)
    end
end
GW.LoadMicroMenu = LoadMicroMenu
