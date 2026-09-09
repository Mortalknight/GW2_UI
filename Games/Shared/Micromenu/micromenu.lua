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
    return GW.settings.micromenu.notificationIconAnimation
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

---------- addon version check ----------
local function ParseVersion(text)
    local major, minor, patch = string.match(text or "", "(%d+)%.(%d+)%.(%d+)")
    if not major then return nil end
    return tonumber(major), tonumber(minor), tonumber(patch)
end

local function CompareVersions(a, b)
    local a1, a2, a3 = ParseVersion(a)
    local b1, b2, b3 = ParseVersion(b)
    if not a1 or not b1 then return nil end
    if a1 ~= b1 then return a1 - b1, 1 end
    if a2 ~= b2 then return a2 - b2, 2 end
    if a3 ~= b3 then return a3 - b3, 3 end
    return 0, nil
end

local function GetUpdateText(part)
    if part == 1 then
        return L["New update available for download."]
    elseif part == 2 then
        return L["New update available containing new features."]
    end
    return L["A |cFFFF0000major|r update is available.\nIt's strongly recommended that you update."]
end

-- number of features, changes and fixes of the installed version, taken from the top changelog entry
local function GetInstalledChangelogCounts()
    local features, changes, bugs = 0, 0, 0
    local entry = GW.changelog and GW.changelog[1]
    for _, change in ipairs(entry and entry.changes or {}) do
        if change[1] == GW.Enum.ChangelogType.feature then
            features = features + 1
        elseif change[1] == GW.Enum.ChangelogType.change then
            changes = changes + 1
        else
            bugs = bugs + 1
        end
    end
    return features, changes, bugs
end

local function GetAddonUpdateSummary()
    local seen = GW.private and GW.private.NewestSeenAddonVersion
    if not seen or not seen.features then return nil end
    if (seen.features + seen.changes + seen.bugs) == 0 then return nil end
    return format("%d %s | %d %s | %d %s", seen.features, L["New Features"], seen.changes, L["Changes"], seen.bugs, L["Fixes"])
end
GW.GetAddonUpdateSummary = GetAddonUpdateSummary

local function GetAvailableAddonUpdate()
    local seen = GW.private.NewestSeenAddonVersion
    if not seen or not seen.version or seen.version == "" then return nil end

    local diff, part = CompareVersions(seen.version, GW.GetVersionString())
    if not diff or diff <= 0 then
        seen.version, seen.sender = "", ""
        return nil
    end
    return seen.version, seen.sender, part
end
GW.GetAvailableAddonUpdate = GetAvailableAddonUpdate

local function RefreshUpdateIcon(announce)
    local version, _, part = GetAvailableAddonUpdate()
    -- the icon itself always shows, only flash and chat notice can be switched off
    announce = announce and GW.settings.micromenu.updateNotification
    if updateIcon then
        if version then
            updateIcon.tooltipText = GetUpdateText(part)
            updateIcon:Show()
            if announce then
                PlayMicroMenuNotificationFlash(updateIcon)
            end
        else
            updateIcon:Hide()
        end
    end
    if announce and version then
        GW.Notice(GetUpdateText(part))
    end
    if GW.RefreshSettingsUpdateHint then
        GW.RefreshSettingsUpdateHint()
    end
end

do
    local SendMessageWaiting
    local function SendMessage()
        -- "version;features;changes;fixes", the counts describe the sender's changelog entry
        local payload = format("%s;%d;%d;%d", GW.GetVersionString(), GetInstalledChangelogCounts())
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", payload, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", payload, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
        elseif IsInGuild() then
            C_ChatInfo.SendAddonMessage("GW2UI_VERSIONCHK", payload, "GUILD")
        end

        SendMessageWaiting = nil
    end

    local SendRecieveGroupSize = 0
    local myRealm = gsub(GW.myrealm, "[%s%-]", "")
    local myName = GW.myname .. "-" .. myRealm
    local announced = false
    local function SendRecieve(_, event, prefix, message, _, sender)
        if event == "CHAT_MSG_ADDON" then
            if sender == myName then return end
            if prefix == "GW2UI_VERSIONCHK" then
                local diff = CompareVersions(message, GW.GetVersionString())
                if not diff or diff <= 0 then return end

                -- remember the newest version anyone reported
                local seen = GW.private.NewestSeenAddonVersion
                local seenDiff = CompareVersions(message, seen.version)
                if seenDiff == nil or seenDiff > 0 then
                    seen.version = format("%d.%d.%d", ParseVersion(message))
                    seen.sender = sender
                    -- counts are optional, older senders only send the version
                    local features, changes, bugs = string.match(message, ";(%d+);(%d+);(%d+)")
                    seen.features = tonumber(features) or 0
                    seen.changes = tonumber(changes) or 0
                    seen.bugs = tonumber(bugs) or 0
                end

                -- chat notice and flash only once per session
                RefreshUpdateIcon(not announced)
                announced = true
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
            -- a version seen in an earlier session keeps the icon until the addon is updated
            RefreshUpdateIcon(false)
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
        if (GW.TBC or GW.Wrath or GW.Mists) and SocialsMicroButton:IsShown() then
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

    local numQuests
    if GW.Retail then
        -- GetNumQuestLogEntries counts hidden quests (world quests, callings, ...) as well; count the
        -- way Blizzards quest log filters its entries so the badge matches the visible quest log
        local numEntries = C_QuestLog.GetNumQuestLogEntries()
        numQuests = 0
        for questLogIndex = 1, numEntries do
            local info = C_QuestLog.GetInfo(questLogIndex)
            if info and not info.isHeader and not info.isTask and not info.isHidden and (not info.isBounty or C_QuestLog.IsComplete(info.questID)) then
                numQuests = numQuests + 1
            end
        end
    else
        numQuests = select(2, GetNumQuestLogEntries())
    end

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

    local version, sender = GetAvailableAddonUpdate()
    if version then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L["Installed version"], GW.GetVersionString(), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["Available version"], version, 0.8, 0.8, 0.8, GREEN_FONT_COLOR:GetRGB())
        local summary = GetAddonUpdateSummary()
        if summary then
            GameTooltip:AddLine(summary, 1, 0.82, 0)
        end
        if sender and sender ~= "" then
            GameTooltip:AddDoubleLine(L["Reported by"], sender, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Click to open the changelog"], 0.7, 0.7, 0.7)
    end
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

---------- micro bar layout ----------
local function IsShownRule(frame)
    return frame:IsShown()
end

local function TalentsRule(frame)
    -- our own talent button is always shown, blizzards only while it is unlocked
    return frame ~= TalentMicroButton or frame:IsShown()
end

-- display names, resolved late because the global strings differ between the clients
local SLOT_NAMES = {
    character = function() return CHARACTER_BUTTON end,
    bags = function() return INVENTORY_TOOLTIP end,
    spellbook = function() return SPELLBOOK_ABILITIES_BUTTON end,
    talents = function() return TALENTS end,
    achievements = function() return ACHIEVEMENT_BUTTON end,
    questlog = function() return QUESTLOG_BUTTON end,
    housing = function() return HOUSING_MICRO_BUTTON or HOUSING or HousingMicroButton and HousingMicroButton.tooltipText end,
    guild = function() return GUILD end,
    lfd = function() return DUNGEONS_BUTTON end,
    encounterjournal = function() return ADVENTURE_JOURNAL end,
    collections = function() return COLLECTIONS end,
    professions = function() return PROFESSIONS_BUTTON end,
    mainmenu = function() return MAINMENU_BUTTON end,
    help = function() return HELP_BUTTON end,
    store = function() return BLIZZARD_STORE end,
    greatvault = function() return RATED_PVP_WEEKLY_VAULT end,
    eventtimer = function() return L["Event timer"] end,
    update = function() return L["GW2 UI Update"] end,
    mail = function() return MAIL_LABEL end,
    workorders = function() return MAILFRAME_CRAFTING_ORDERS_TOOLTIP_TITLE end,
    pvp = function() return PLAYER_V_PLAYER end,
    lfg = function() return LFG_TITLE end,
    worldmap = function() return WORLDMAP_BUTTON end,
}

local MICRO_BAR_LAYOUTS = {
    Retail = {
        {key = "character"},
        {key = "bags"},
        {key = "spellbook"},
        {key = "achievements"},
        {key = "questlog"},
        {key = "housing", available = IsShownRule},
        {key = "guild"},
        {key = "lfd"},
        {key = "encounterjournal"},
        {key = "collections"},
        {key = "professions"},
        {key = "mainmenu"},
        {key = "help"},
        {key = "store", available = function() return not C_AddOns.IsAddOnLoaded("Dominos") end}, -- Dominos removes the store button
        {key = "greatvault"},
        {key = "eventtimer", available = function() return GW.settings.micromenu.eventTimerIcon end},
        {key = "update", notification = true},
        {key = "mail", notification = true},
        {key = "workorders", notification = true},
    },
    Mists = {
        {key = "character"},
        {key = "bags"},
        {key = "spellbook"},
        {key = "talents", available = TalentsRule},
        {key = "achievements"},
        {key = "questlog"},
        {key = "guild"},
        {key = "collections"},
        {key = "pvp"},
        {key = "lfg"},
        {key = "encounterjournal"},
        {key = "store"},
        {key = "mainmenu"},
        {key = "help"},
        {key = "update", notification = true},
        {key = "mail", notification = true},
    },
    Wrath = {
        {key = "character"},
        {key = "bags"},
        {key = "spellbook"},
        {key = "talents", available = TalentsRule},
        {key = "achievements"},
        {key = "questlog"},
        {key = "guild"},
        {key = "collections"},
        {key = "pvp"},
        {key = "lfg"},
        {key = "mainmenu"},
        {key = "help"},
        {key = "update", notification = true},
        {key = "mail", notification = true},
    },
    Classic = { -- era and tbc
        {key = "character"},
        {key = "bags"},
        {key = "spellbook"},
        {key = "talents", available = TalentsRule},
        {key = "questlog"},
        {key = "guild"},
        {key = "worldmap"},
        {key = "mainmenu"},
        {key = "help"},
        {key = "update", notification = true},
        {key = "mail", notification = true},
    },
}
local MICRO_BAR_LAYOUT = GW.Retail and MICRO_BAR_LAYOUTS.Retail or GW.Mists and MICRO_BAR_LAYOUTS.Mists or GW.Wrath and MICRO_BAR_LAYOUTS.Wrath or MICRO_BAR_LAYOUTS.Classic
GW.MicroBarLayout = MICRO_BAR_LAYOUT

local function GetMicroBarSlotName(key)
    local name = SLOT_NAMES[key] and SLOT_NAMES[key]()
    if type(name) ~= "string" or name == "" then
        return key
    end
    -- blizzard tooltip texts carry the keybind, keep the plain label
    name = name:gsub("%s*|c.*$", ""):gsub("%s*%b()%s*$", "")
    return name
end
GW.GetMicroBarSlotName = GetMicroBarSlotName

-- slots in the user's order: stored keys first, everything the stored order does not know in default order
local function GetMicroBarSlotSequence()
    local byKey, used, sequence = {}, {}, {}
    for _, slot in ipairs(MICRO_BAR_LAYOUT) do
        byKey[slot.key] = slot
    end
    for _, key in ipairs(GW.settings.micromenu.buttonOrder or {}) do
        if byKey[key] and not used[key] then
            tinsert(sequence, byKey[key])
            used[key] = true
        end
    end
    for _, slot in ipairs(MICRO_BAR_LAYOUT) do
        if not used[slot.key] then
            tinsert(sequence, slot)
        end
    end
    return sequence
end

local function IsMicroBarSlotHidden(key)
    local visibility = GW.settings.micromenu.buttonVisibility
    return visibility and visibility[key] == false
end

local layoutContainer
local slotButtons = {}
local slotCompanions = {}

local MICRO_BAR_LENGTH = GW.Retail and 500 or (GW.Mists or GW.Wrath) and 370 or 280
local MICRO_BAR_THICKNESS = 41
local MICRO_BAR_BUTTON_INSET_ALONG = 5
local MICRO_BAR_BUTTON_INSET_ACROSS = 3
local barLayout = {vertical = false, mirrorAlong = false, mirrorAcross = false}

local function GetBarArtTexCoords(vertical, mirrorAlong, mirrorAcross)
    local ul, ll, ur, lr
    local mirrorX, mirrorY
    if vertical then
        ul, ll, ur, lr = {0, 0}, {1, 0}, {0, 1}, {1, 1}
        mirrorX, mirrorY = mirrorAcross, mirrorAlong
    else
        ul, ll, ur, lr = {0, 0}, {0, 1}, {1, 0}, {1, 1}
        mirrorX, mirrorY = mirrorAlong, mirrorAcross
    end
    if mirrorX then
        ul, ur = ur, ul
        ll, lr = lr, ll
    end
    if mirrorY then
        ul, ll = ll, ul
        ur, lr = lr, ur
    end
    return ul[1], ul[2], ll[1], ll[2], ur[1], ur[2], lr[1], lr[2]
end

local function GetBarScreenHalf(mbf)
    local mover = mbf.gwMover
    if not mover then return false, false end
    local x, y = mover:GetCenter()
    if not x or not y then return false, false end
    local scale = mover:GetScale()
    return x * scale > UIParent:GetWidth() / 2, y * scale < UIParent:GetHeight() / 2
end

local function GetBarCornerPoint(vertical, mirrorAlong, mirrorAcross)
    if vertical then
        return (mirrorAlong and "BOTTOM" or "TOP") .. (mirrorAcross and "RIGHT" or "LEFT")
    end
    return (mirrorAcross and "BOTTOM" or "TOP") .. (mirrorAlong and "RIGHT" or "LEFT")
end

local function UpdateMicroBarOrientation()
    local mbf = Gw2MicroBarFrame
    if not mbf then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue("Micromenu Orientation", UpdateMicroBarOrientation)
        return
    end

    local vertical = GW.settings.micromenu.orientation == "VERTICAL"
    barLayout.vertical = vertical
    if vertical then
        mbf:SetSize(MICRO_BAR_THICKNESS, MICRO_BAR_LENGTH)
    else
        mbf:SetSize(MICRO_BAR_LENGTH, MICRO_BAR_THICKNESS)
    end

    local rightHalf, lowerHalf = GetBarScreenHalf(mbf)
    local mirrorAlong = vertical and lowerHalf or (not vertical and rightHalf)
    local mirrorAcross = vertical and rightHalf or (not vertical and lowerHalf)
    barLayout.mirrorAlong, barLayout.mirrorAcross = mirrorAlong, mirrorAcross

    local bg = mbf.cf.bg
    local corner = GetBarCornerPoint(vertical, mirrorAlong, mirrorAcross)
    if vertical then
        bg:SetSize(128, 512)
    else
        bg:SetSize(512, 128)
    end
    bg:ClearAllPoints()
    bg:SetPoint(corner, mbf.cf, corner)
    bg:SetTexCoord(GetBarArtTexCoords(vertical, mirrorAlong, mirrorAcross))
    bg:SetShown(GW.settings.micromenu.showBackground and GW.settings.BORDER_ENABLED)
end
GW.UpdateMicroBarOrientation = UpdateMicroBarOrientation

-- frame fills the slot, every further argument is a companion anchored on the same spot
local function SetSlotButton(key, frame, ...)
    slotButtons[key] = frame
    slotCompanions[key] = select("#", ...) > 0 and {...} or nil
end

local function LayoutMicroButtons()
    if not layoutContainer then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue("Layout Micromenu", LayoutMicroButtons)
        return
    end

    local vertical, mirrorAcross = barLayout.vertical, barLayout.mirrorAcross
    local firstPoint = GetBarCornerPoint(vertical, false, mirrorAcross)
    local firstX = vertical and MICRO_BAR_BUTTON_INSET_ACROSS or MICRO_BAR_BUTTON_INSET_ALONG
    local firstY = vertical and MICRO_BAR_BUTTON_INSET_ALONG or MICRO_BAR_BUTTON_INSET_ACROSS
    if vertical and mirrorAcross then
        firstX = -firstX
    end
    if not vertical and mirrorAcross then
        firstY = -firstY
    end
    firstY = -firstY
    local previous
    for _, slot in ipairs(GetMicroBarSlotSequence()) do
        local frame = slotButtons[slot.key]
        if frame and IsMicroBarSlotHidden(slot.key) then
            -- parked off screen, not hidden: blizzard toggles and alerts on the button must keep working
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -40, 40)
            if slotCompanions[slot.key] then
                for _, companion in ipairs(slotCompanions[slot.key]) do
                    companion:ClearAllPoints()
                    companion:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
                end
            end
        elseif frame and (not slot.available or slot.available(frame)) then
            frame:ClearAllPoints()
            if not previous then
                frame:SetPoint(firstPoint, layoutContainer, firstPoint, firstX, firstY)
            elseif vertical then
                frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
            else
                frame:SetPoint("BOTTOMLEFT", previous, "BOTTOMRIGHT", 4, 0)
            end
            if slotCompanions[slot.key] then
                for _, companion in ipairs(slotCompanions[slot.key]) do
                    companion:ClearAllPoints()
                    companion:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
                end
            end
            previous = frame
        end
    end
end
GW.LayoutMicroButtons = LayoutMicroButtons

local function ToggleEventTimerIcon(mbf)
    if GW.settings.micromenu.eventTimerIcon and not Gw2EventTimerMicroMenuButton then
        local eventTimerIcon = CreateFrame("Button", "Gw2EventTimerMicroMenuButton", mbf, "MainMenuBarMicroButton")
        eventTimerIcon.newbieText = nil
        eventTimerIcon.tooltipText = L["Event timer"]
        eventTimerIcon.textureName = "EventMicroButton"
        reskinMicroButton(eventTimerIcon, "EventMicroButton", mbf)
        eventTimerIcon:SetScript("OnEnter", GW.EventTracker.OnEnterAll)
        SetSlotButton("eventtimer", eventTimerIcon)
    end

    if Gw2EventTimerMicroMenuButton then
        Gw2EventTimerMicroMenuButton:SetShown(GW.settings.micromenu.eventTimerIcon)
    end

    LayoutMicroButtons()
end
GW.ToggleEventTimerMicroMenuIcon = ToggleEventTimerIcon

local function setupMicroButtons(mbf)
    layoutContainer = mbf

    -- CharacterMicroButton
    -- determine if we are using the default char button (for default charwin)
    -- or if we need to create our own char button for the custom hero panel
    local cref
    if GW.settings.USE_CHARACTER_WINDOW then
        --IsProtected()
        cref = CreateFrame("Button", "GwCharacterMicroButton", mbf,  "SecureHandlerClickTemplate")
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
        cref:HookScript("OnLeave", GameTooltip_Hide)
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
    SetSlotButton("character", cref)

    -- custom bag microbutton
    local bref = CreateFrame("Button", nil, mbf, "")
    bref.tooltipText = MicroButtonTooltipText(INVENTORY_TOOLTIP, "OPENALLBAGS")
    bref.newbieText = nil
    bref.textureName = "BagMicroButton"
    reskinMicroButton(bref, "BagMicroButton", mbf)
    bref:HookScript("OnClick", ToggleAllBags)
    bref:HookScript("OnEvent", updateBagButton)
    bref:RegisterEvent("PLAYER_ENTERING_WORLD")
    bref:RegisterEvent("BAG_UPDATE_DELAYED")
    bref:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    updateBagButton(bref)
    bref:HookScript("OnEnter", GW.Bags_OnEnter)
    bref:HookScript("OnLeave", GameTooltip_Hide)
    SetSlotButton("bags", bref)

    -- SpellbookMicroButton
    if GW.Retail then
        SetSlotButton("spellbook", PlayerSpellsMicroButton)
    elseif GW.settings.USE_SPELLBOOK_WINDOW then
        local sref = CreateFrame("Button", "GwPlayerSpellsMicroButton", mbf, "SecureHandlerClickTemplate")
        sref.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
        sref.newbieText = NEWBIE_TOOLTIP_SPELLBOOK
        reskinMicroButton(sref, "SpellbookMicroButton", mbf)
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
        SetSlotButton("spellbook", sref)
    else
        SetSlotButton("spellbook", SpellbookMicroButton)
    end

    -- TalentMicroButton (none retail)
    if not GW.Retail then
        if GW.settings.USE_TALENT_WINDOW then
            local tref = CreateFrame("Button", "GwTalentMicroButton", mbf, "SecureHandlerClickTemplate")
            tref.tooltipText = MicroButtonTooltipText(TALENTS, "TOGGLETALENTS")
            tref.newbieText = NEWBIE_TOOLTIP_TALENTS
            reskinMicroButton(tref, "TalentMicroButton", mbf)

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
                SetSlotButton("talents", tref)
            else
                -- blizzard anchors its achievement button to the talent button, keep it invisible on our slot
                TalentMicroButton:SetAlpha(0)
                TalentMicroButton:EnableMouse(false)
                SetSlotButton("talents", tref, TalentMicroButton)
            end
        else
            SetSlotButton("talents", TalentMicroButton)
        end
    end

    -- AchievementMicroButton
    if GW.Retail or GW.Mists or GW.Wrath then
        SetSlotButton("achievements", AchievementMicroButton)
    end

    -- QuestLogMicroButton
    QuestLogMicroButton:RegisterEvent("QUEST_LOG_UPDATE")
    QuestLogMicroButton:HookScript("OnEvent", updateQuestLogButton)
    updateQuestLogButton()
    SetSlotButton("questlog", QuestLogMicroButton)

    -- Retail HousingMicroButton
    if HousingMicroButton then
        SetSlotButton("housing", HousingMicroButton)
    end

    -- GuildMicroButton (and the SocialsMicroButton blizzard toggles with it on the classics)
    for i = 1, (GW.Classic or GW.TBC or GW.Wrath or GW.Mists) and 2 or 1 do
        local gref
        if i == 1 then
            gref = GuildMicroButton
        else
            gref = SocialsMicroButton
        end
        gref:RegisterEvent("GUILD_ROSTER_UPDATE")
        gref:RegisterEvent("MODIFIER_STATE_CHANGED")
        gref:RegisterEvent("GUILD_MOTD")
        gref:HookScript("OnEvent", updateGuildButton)
        gref:HookScript("OnEnter", function(self)
            requestGuildRosterUpdate(self, true)
            GW.Guild_OnEnter(self)
        end)
        gref:SetScript("OnClick", GW.Guild_OnClick)
        if not (GW.Classic or GW.TBC or GW.Wrath or GW.Mists) then
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
    if GW.Retail then
        SetSlotButton("guild", GuildMicroButton)
    else
        SetSlotButton("guild", GuildMicroButton, SocialsMicroButton)
    end

    if GW.Retail then
        SetSlotButton("lfd", LFDMicroButton)
        SetSlotButton("encounterjournal", EJMicroButton)
        SetSlotButton("collections", CollectionsMicroButton)
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
            local pref = CreateFrame("Button", "GwProfessionMicroButton", mbf, "SecureHandlerClickTemplate")
            Mixin(pref, MainMenuBarMicroButtonMixin)
            pref.tooltipText = MicroButtonTooltipText(PROFESSIONS_BUTTON, "TOGGLEPROFESSIONBOOK")
            pref.newbieText = nil
            pref.textureName = "Professions"
            reskinMicroButton(pref, "ProfessionMicroButton", mbf, true)
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
            SetSlotButton("professions", pref)
        else
            SetSlotButton("professions", ProfessionMicroButton)
        end
    elseif GW.Mists or GW.Wrath then
        SetSlotButton("collections", CollectionsMicroButton)

        -- PVPMicroButton
        if GW.Wrath and GW.settings.USE_CHARACTER_WINDOW then
            local pvpref = CreateFrame("Button", "GwPvpMicroButton", mbf, "SecureHandlerClickTemplate")
            pvpref.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
            pvpref.newbieText = NEWBIE_TOOLTIP_PVP
            reskinMicroButton(pvpref, "PvpMicroButton", mbf)

            pvpref:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
            pvpref:SetAttribute(
                "_onclick",
                [=[
                local f = self:GetFrameRef("GwCharacterWindow")
                f:SetAttribute("keytoggle", "1")
                f:SetAttribute("windowpanelopen", "pvp")
                ]=]
            )

            -- blizzards button stays invisible on our slot so its events and alerts keep working
            PVPMicroButton:SetAlpha(0)
            PVPMicroButton:EnableMouse(false)
            SetSlotButton("pvp", pvpref, PVPMicroButton)
        else
            if GW.Mists then
                PVPMicroButtonTexture:SetAlpha(0)
            end
            SetSlotButton("pvp", PVPMicroButton)
        end

        SetSlotButton("lfg", LFGMicroButton)

        if GW.Mists then
            SetSlotButton("encounterjournal", EJMicroButton)
            SetSlotButton("store", StoreMicroButton)
        end
    else
        SetSlotButton("worldmap", WorldMapMicroButton)
    end

    -- MainMenuMicroButton
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
    SetSlotButton("mainmenu", MainMenuMicroButton)

    -- HelpMicroButton
    SetSlotButton("help", HelpMicroButton)

    if GW.Retail then
        SetSlotButton("store", StoreMicroButton)

        -- great vault icon
        local greatVaultIcon = CreateFrame("Button", "Gw2GreateVaultMicroMenuButton", mbf, "MainMenuBarMicroButton")
        greatVaultIcon.newbieText = nil
        greatVaultIcon.tooltipText = RATED_PVP_WEEKLY_VAULT
        greatVaultIcon.textureName = "GreatVaultMicroButton"
        reskinMicroButton(greatVaultIcon, "GreatVaultMicroButton", mbf)
        RegisterMicroMenuNotificationIcon(greatVaultIcon)
        greatVaultIcon:SetScript("OnEnter", GW.GreatVault_OnEnter)
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
        greatVaultIcon:SetEnabled(GameRulesUtil.IsPlayerAtEffectiveMaxLevel())
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
        SetSlotButton("greatvault", greatVaultIcon)
    end

    LayoutMicroButtons()
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
    updateIcon:Hide()
    updateIcon:HookScript("OnEnter", update_OnEnter)
    updateIcon:HookScript("OnLeave", GameTooltip_Hide)
    updateIcon:SetScript("OnClick", function()
        if GW.ShowSettingsChangelog then
            GW.ShowSettingsChangelog()
        end
    end)
    updateIcon:SetFrameLevel(mbf.cf:GetFrameLevel() + 10)
    RegisterMicroMenuNotificationIcon(updateIcon)
    SetSlotButton("update", updateIcon)
    RefreshUpdateIcon(false)
    -- parented to the bar frame, not the fading container: always visible, but the fade must not treat
    -- the mouse over them as leaving the bar (see the auto hide set in LoadMicroMenu)
    mbf.notificationIcons = {updateIcon}

    -- Mail icon
    local mailIcon = CreateFrame("Button", nil, mbf, "MainMenuBarMicroButton")
    mailIcon:RegisterEvent("UPDATE_PENDING_MAIL")
    mailIcon.newbieText = nil
    mailIcon.tooltipText = ""
    mailIcon.textureName = "MailMicroButton"
    reskinMicroButton(mailIcon, "MailMicroButton", mbf)
    mailIcon:Hide()
    mailIcon:HookScript("OnEnter", mailIconOnEnter)
    mailIcon:HookScript("OnLeave", GameTooltip_Hide)
    mailIcon:SetScript("OnEvent", mailIconOnEvent)
    mailIcon:SetFrameLevel(mbf.cf:GetFrameLevel() + 10)
    RegisterMicroMenuNotificationIcon(mailIcon, function(frame)
        mailIconOnEvent(frame)
    end)
    SetSlotButton("mail", mailIcon)
    tinsert(mbf.notificationIcons, mailIcon)

    if GW.Retail then
        -- workorder icon
        local workOrderIcon = CreateFrame("Button", "Gw2NotificationIconWorkorder", mbf, "MainMenuBarMicroButton")
        workOrderIcon:RegisterEvent("CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS")
        workOrderIcon:RegisterEvent("PLAYER_ENTERING_WORLD")
        workOrderIcon.newbieText = nil
        workOrderIcon.tooltipText = ""
        workOrderIcon.textureName = "ProfessionMicroButton"
        reskinMicroButton(workOrderIcon, "ProfessionMicroButton", mbf)
        workOrderIcon:Hide()
        workOrderIcon:HookScript("OnEnter", workOrderIconOnEnter)
        workOrderIcon:HookScript("OnLeave", GameTooltip_Hide)
        workOrderIcon:SetScript("OnEvent", workOrderIconOnEvent)
        workOrderIcon:SetFrameLevel(mbf.cf:GetFrameLevel() + 10)
        RegisterMicroMenuNotificationIcon(workOrderIcon, function(frame)
            workOrderIconOnEvent(frame, "PLAYER_ENTERING_WORLD")
        end)
        SetSlotButton("workorders", workOrderIcon)
        tinsert(mbf.notificationIcons, workOrderIcon)
    end

    LayoutMicroButtons()

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
    if (GW.TBC or GW.Wrath or GW.Mists) and SocialsMicroButton:IsShown() then
        m = SocialsMicroButton
    end
    m:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
    m:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
    m:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
    m:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")

    if MicroButtonPortrait then MicroButtonPortrait:Hide() end

    reskinMicroButtons(Gw2MicroBarFrame.cf)

    -- blizzard re-anchors some of its buttons on every update, put the row back into our order
    LayoutMicroButtons()
end


local function mbf_OnLeave(self)
    if not self:IsMouseOver() and GW.settings.micromenu.fade then
        self:fadeOut()
    end
end


local function LoadMicroMenu()
    if checkElvUI() or not GW.settings.micromenu.enabled then
        return
    end

    MicroMenuContainer:GwKillEditMode()

    -- create our micro button container frame
    local mbf = CreateFrame("Frame", "Gw2MicroBarFrame", UIParent, "GwMicroButtonFrameTmpl")
    UpdateMicroBarOrientation() -- size only, the mover does not exist yet
    local postDragFunction = function()
        -- art and button offset follow the screen position
        UpdateMicroBarOrientation()
        LayoutMicroButtons()
    end
    GW.RegisterMovableFrame(mbf, GW.L["Micro Bar"], "MicromenuPos", "Blizzard,Widgets", nil, {"default", "scaleable"}, nil, postDragFunction)
    mbf:SetPoint("TOPLEFT", mbf.gwMover)
    UpdateMicroBarOrientation() -- now with the position: the art corner follows the screen half

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

    hooksecurefunc("UpdateMicroButtons", hook_UpdateMicroButtons)


    -- if set to fade micro menu, add fader
    mbf.cf:SetAttribute("shouldFade", GW.settings.micromenu.fade)
    mbf.cf:SetAttribute("fadeTime", 0.15)

    local fo = mbf.cf:CreateAnimationGroup("fadeOut")
    local fi = mbf.cf:CreateAnimationGroup("fadeIn")
    local fadeOut = fo:CreateAnimation("Alpha")
    local fadeIn = fi:CreateAnimation("Alpha")
    fo:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(0)
    end)
    fo:SetScript("OnUpdate", function(self)
        if mbf:IsMouseOver() then
            self:Stop()
        end
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
        local wasFadingOut = fo:IsPlaying()
        fo:Stop()
        if wasFadingOut or (self:GetAlpha() >= 1 and not fi:IsPlaying()) then
            self:SetAlpha(1)
            return
        end
        self:SetAlpha(1)
        fi:Stop()
        fi:Play()
    end

    mbf:SetFrameRef("cf", mbf.cf)
    for i, icon in ipairs(mbf.notificationIcons or {}) do
        mbf:SetFrameRef("notificationIcon" .. i, icon)
    end

    mbf:SetAttribute("_onenter", [=[
        local cf = self:GetFrameRef("cf")
        local shouldFade = cf:GetAttribute("shouldFade")
        if not shouldFade then
            return
        end
        cf:UnregisterAutoHide()
        cf:Show()
        cf:CallMethod("fadeIn", cf)
        cf:RegisterAutoHide(cf:GetAttribute("fadeTime") + 0.25)
        -- the notification icons hang next to the container, hovering them keeps the bar shown
        for i = 1, 3 do
            local icon = self:GetFrameRef("notificationIcon" .. i)
            if icon then
                cf:AddToAutoHide(icon)
            end
        end
    ]=])
    mbf.cf:HookScript("OnLeave", mbf_OnLeave)
    mbf.cf:SetShown(not GW.settings.micromenu.fade)

    if GW.Retail then
        -- fix alert positions and hide the micromenu bar
        MicroButtonAndBagsBar:SetAlpha(0)
        MicroButtonAndBagsBar:EnableMouse(false)

        -- GW owns the micro buttons: blizzards micro menu reset on action bar
        -- show runs UpdateMicroButtons and hits the protected micro button
        -- Enable calls with our taint (ADDON_ACTION_BLOCKED, e.g. when a
        -- cinematic ends in combat) - keep the end cap update, drop the reset
        if MainActionBar and MainActionBar.UpdateEndCaps then
            MainActionBar:SetScript("OnShow", function(self)
                self:UpdateEndCaps(self.hideBarArt)
            end)
        end
    end
end
GW.LoadMicroMenu = LoadMicroMenu
