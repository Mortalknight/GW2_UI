---@class GW2
local GW = select(2, ...)
local L = GW.L
local LEMO = GW.Libs.LEMO

local wpanel
local installFrame

local function ToggleChatColorNamesByClassGroup(checked, group)
	local info = _G.ChatTypeGroup[group]
	if info then
		for _, value in pairs(info) do
			SetChatColorNameByClass(strsub(value, 10), checked)
		end
	else
		SetChatColorNameByClass(group, checked)
	end
end

local function AddCompleteAlert(text)
    if not (GW.Classic or GW.TBC) then
        GW.AlertSystem:AddAlert(L["Complete"], nil, text, false, "Interface/AddOns/GW2_UI/textures/icons/icon-levelup.png", true)
    end
end

local function settings_OnClick(self)
    local t = self.target
    wpanel:Hide()
    t:Show()
    UIFrameFadeIn(t, 0.2, 0, 1)
end

-- ============================
-- Step appliers
-- ============================
local function ApplyChatSetup()
    FCF_ResetChatWindows()

    local voiceChat = _G[CHAT_FRAMES[3]]
    FCF_ResetChatWindow(voiceChat, VOICE)
    FCF_DockFrame(voiceChat, 3)

    FCF_OpenNewWindow(LOOT)

    for id, name in next, CHAT_FRAMES do
        local frame = _G[name]

        -- move general bottom left
        if id == 1 then
            -- this needs to be done via the edit mode lib
            LEMO:LoadLayouts()
            local doesGw2LayoutExists = LEMO:DoesLayoutExist("GW2_Layout")
            if not LEMO:CanEditActiveLayout() or not doesGw2LayoutExists then
                if not doesGw2LayoutExists then
                    LEMO:AddLayout(Enum.EditModeLayoutType.Account, "GW2_Layout")
                end
                LEMO:SetActiveLayout("GW2_Layout")
            end
            LEMO:ReanchorFrame(frame, "BOTTOMLEFT", UIParent, 40, 60)
            GW.ApplyLayoutChanges()
            frame:SetUserPlaced(true)
        elseif id == 2 then
            FCF_SetWindowName(frame, GUILD_EVENT_LOG)
        elseif id == 3 then
            VoiceTranscriptionFrame_UpdateVisibility(frame)
            VoiceTranscriptionFrame_UpdateVoiceTab(frame)
            VoiceTranscriptionFrame_UpdateEditBox(frame)
        elseif id == 4 then
            FCF_SetWindowName(frame, LOOT .. " / " .. TRADE)
        end

        FCF_SetChatWindowFontSize(nil, frame, 12)
        FCF_SavePositionAndDimensions(frame)
        FCF_StopDragging(frame)
    end

    -- keys taken from "ChatTypeGroup" but doesnt add: "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO", "COMMUNITIES_CHANNEL", "PET_BATTLE_COMBAT_LOG", "PET_BATTLE_INFO", "TARGETICONS"
    local chatGroup = {"SYSTEM", "CHANNEL", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_INLINE_TOAST_ALERT"}
    ChatFrame1:RemoveAllMessageGroups()
    for _, v in ipairs(chatGroup) do
        ChatFrame1:AddMessageGroup(v)
    end

    -- keys taken from "ChatTypeGroup" which weren't added above to ChatFrame1
    chatGroup = {"PING", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY"}
    ChatFrame4:RemoveAllMessageGroups()
    for _, v in ipairs(chatGroup) do
        ChatFrame4:AddMessageGroup(v)
    end

    ChatFrame1:AddChannel(GENERAL)
    ChatFrame1:RemoveChannel(TRADE)
    ChatFrame4:AddChannel(TRADE)

    -- set the chat groups names in class color to enabled for all chat groups which players names appear
    chatGroup = {"SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL"}
    for i = 1, Constants.ChatFrameConstants.MaxChatChannels do
        tinsert(chatGroup, "CHANNEL" .. i)
    end
    for _, v in ipairs(chatGroup) do
        ToggleChatColorNamesByClassGroup(true, v)
    end

    AddCompleteAlert(L["Setup Chat"])
end

local CVARS = {
    { cvar = "screenshotQuality", value = "10", desc = L["Maximum screenshot quality"] },
    { cvar = "chatMouseScroll", value = "1", desc = L["Scroll the chat with the mouse wheel"] },
    { cvar = "chatStyle", value = "classic", desc = L["Classic chat input style"] },
    { cvar = "wholeChatWindowClickable", value = "0", desc = L["Only the chat text is clickable, not the whole window"] },
    { cvar = "showTutorials", value = "0", desc = L["Disable the tutorial popups"] },
    { cvar = "showNPETutorials", value = "0", desc = L["Disable the new player tutorials"] },
    { cvar = "UberTooltips", value = "1", desc = L["Enhanced tooltips with additional information"] },
    { cvar = "threatWarning", value = "3", desc = L["Always show threat warnings"] },
    { cvar = "alwaysShowActionBars", value = "1", desc = L["Always show the action bars"] },
    { cvar = "lockActionBars", value = "1", desc = L["Lock the action bars against accidental dragging"] },
    { cvar = "spamFilter", value = "0", desc = L["Disable the built-in spam filter"] },
    { cvar = "cameraDistanceMaxZoomFactor", value = "2.6", desc = L["Increase the maximum camera zoom distance"] },
    { cvar = "showQuestTrackingTooltips", value = "1", desc = L["Show quest progress in tooltips"] },
    { cvar = "whisperMode", value = "inline", desc = L["Whispers show up in the chat window instead of extra tabs"] },
}

-- entries the current client does not know (flavor differences, removed cvars)
-- are skipped by the list and the applier alike
local function CVarExists(entry)
    return C_CVar.GetCVar(entry.cvar) ~= nil
end

local function ApplyCVars()
    local applied, total = 0, 0
    for _, entry in ipairs(CVARS) do
        if CVarExists(entry) then
            total = total + 1
            if entry.enabled ~= false then
                C_CVar.SetCVar(entry.cvar, entry.value)
                applied = applied + 1
            end
        end
    end

    AddCompleteAlert(L["Setup CVars"])
    return format("%d/%d", applied, total)
end

-- the text styles of the installer, picked per frame for health and power, names and levels stay; a style sets the
-- line kinds it names, false is the default of a line
local function Health(mode, short)
    return {k = "healthValue", mode = mode, short = short}
end
local DETAILED_POWER = {{k = "power", mode = "CURPREC", short = true}}
local TEXT_STYLE_NAMES = {L["Minimal"], DEFAULT, L["Detailed"]}
local TEXT_STYLE_SECTIONS = {{key = "health", label = HEALTH}, {key = "power", label = L["Power"]}}

-- previews of frames that are hidden right now, for the text style step and the module tiles: a copy of a unit
-- frame on its place, the group frames in their preview or config mode. Hide only undoes what show did
local unitCopies, shownGroupPreviews = {}, {}

local function RefreshUnitCopy(unit)
    local copy = unitCopies[unit]
    if not copy then return end
    for _, line in ipairs(GW.GetUnitFrameTextTarget(unit).lines) do
        if copy.texts[line.key] then
            copy.texts[line.key]:SetText(GW.BuildTagPreview(GW.GetUnitFrameTextBlocks(unit, line.key)))
        end
    end
end

-- the copies are built from the secure unit frame templates, so not in combat
local function ShowUnitCopy(unit, frame)
    if not frame or not frame:GetLeft() or UnitExists(unit) or InCombatLockdown() then return end
    local copy = unitCopies[unit] or GW.GetUnitFrameTextTarget(unit).createPreview(wpanel)
    unitCopies[unit] = copy
    -- the copy holds the frame 20 to the right and 15 above its bottom
    copy:SetScale(frame:GetEffectiveScale() / wpanel:GetEffectiveScale())
    copy:ClearAllPoints()
    copy:SetPoint("BOTTOMLEFT", wpanel, "BOTTOMLEFT", frame:GetLeft() - 20, frame:GetBottom() - 15)
    copy:Show()
    RefreshUnitCopy(unit)
end

local function HideUnitCopy(unit)
    if unitCopies[unit] then
        unitCopies[unit]:Hide()
    end
end

local function UnitFrameOrCopy(unit, frame)
    return UnitExists(unit) and frame or unitCopies[unit]
end

local function PartyGridReplacesFrames()
    return GW.settings.groupFrames.enabled and GW.settings.groupFrames.party.enabled
end

-- the kind of preview the party needs: the grid when it replaces the party frames
local function PartyPreviewKind()
    return PartyGridReplacesFrames() and "party" or "partyFrames"
end

-- the first raid grid that is built
local function RaidPreviewKind()
    for _, profile in ipairs({"raid25", "raid40", "raid10"}) do
        if GW.GridGroupHeaders and GW.GridGroupHeaders[profile] then
            return profile
        end
    end
end

-- kind: "partyFrames" for the party frames, otherwise a grid profile in config mode
local function ShowGroupPreview(kind)
    if not kind or InCombatLockdown() or shownGroupPreviews[kind] then return end
    if kind == "partyFrames" then
        if not (GW.settings.unitframes.party.enabled and GW.TogglePartyPreview) or GW.IsPartyFramesPreviewActive() then return end
        GW.TogglePartyPreview()
    else
        local header = GW.GridGroupHeaders and GW.GridGroupHeaders[kind]
        if not header or header.forceShow then return end
        GW.ToggleGridConfigurationMode(header, true)
    end
    shownGroupPreviews[kind] = true
end

local function HideGroupPreview(kind)
    if not (kind and shownGroupPreviews[kind]) then return end
    shownGroupPreviews[kind] = nil
    local function Hide()
        if kind == "partyFrames" then
            if GW.IsPartyFramesPreviewActive() then GW.TogglePartyPreview() end
        else
            local header = GW.GridGroupHeaders[kind]
            if header and header.forceShow then GW.ToggleGridConfigurationMode(header, nil) end
        end
    end
    -- in combat the grid config mode ends on its own, the party preview after the fight
    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwInstallerGroupPreview" .. kind, Hide)
    else
        Hide()
    end
end

local function GroupPreviewFrames(kind)
    if kind == "partyFrames" then
        return {GwPartyFrame1, GwPartyFrame2, GwPartyFrame3, GwPartyFrame4, GwPartyFrame5}
    end
    return {kind and GW.GridGroupHeaders and GW.GridGroupHeaders[kind]}
end

-- the text style step shows the real frames and changes them right away
local TEXT_STYLE_FRAME_NAMES = {
    target = {"GwTargetUnitFrame", "GwTargetTargetUnitFrame", "GwFocusUnitFrame", "GwFocusTargetUnitFrame"},
    player = {"GW2_PlayerFrame", "GwPlayerUnitFrame", "GwPlayerPetFrame", "GwPlayerPowerBar"},
}

local function RefreshTextStyleFrames(kind)
    for _, name in ipairs(TEXT_STYLE_FRAME_NAMES[kind] or {}) do
        local frame = _G[name]
        if frame and frame.ApplyTextTags then
            frame:ApplyTextTags()
        end
    end
    if kind == "target" then
        if GW.UpdateBossFramesSettings then GW.UpdateBossFramesSettings() end
        if GW.UpdateArenaFramesSettings then GW.UpdateArenaFramesSettings() end
        RefreshUnitCopy("target")
    elseif kind == "group" then
        if GW.UpdatePartyFrames then GW.UpdatePartyFrames() end
        GW.UpdateGridSettings("ALL")
        -- the grid update drops the fake members of a running config mode
        for previewKind in pairs(shownGroupPreviews) do
            if previewKind ~= "partyFrames" then
                GW.RefreshGridConfigurationMode(previewKind, true)
            end
        end
    else
        -- the class power has no frame method, its setter refreshes the texts
        GW.GetClassPowerTextTarget().set("manaText", GW.settings.classpower.manaText)
    end
end

local textStyleGroupKind

local function ShowTextStyleFrames()
    textStyleGroupKind = PartyPreviewKind()
    ShowGroupPreview(textStyleGroupKind)
    ShowUnitCopy("target", GwTargetUnitFrame)
end

local function HideTextStyleFrames()
    HideGroupPreview(textStyleGroupKind)
    HideUnitCopy("target")
end

-- a list of frames is lit as one area
local function TextStyleHighlights()
    return {
        {GW2_PlayerFrame, GwPlayerUnitFrame, GwPlayerPowerBar},
        UnitFrameOrCopy("target", GwTargetUnitFrame),
        GroupPreviewFrames(textStyleGroupKind),
    }
end

local TEXT_STYLE_FRAMES = {
    {label = TARGET, unit = "target", refresh = function() RefreshTextStyleFrames("target") end,
        lines = function(settings)
            local unitframes, objectives = settings.unitframes, settings.objectives
            local list = {}
            for _, db in pairs({unitframes.target, unitframes.targettarget, unitframes.focus, unitframes.focustarget,
                objectives.bossFrames, objectives.arenaFrames}) do
                tinsert(list, {db, "healthText", "health"})
                tinsert(list, {db, "powerText", "power"})
            end
            return list
        end,
        health = {{health = {}}, {health = false}, {health = {Health("CURPREC", true)}}},
        power = {{power = {}}, {power = false}, {power = DETAILED_POWER}}},
    {label = GROUP, refresh = function() RefreshTextStyleFrames("group") end,
        lines = function(settings)
            local list = {{settings.unitframes.party, "healthText", "health"}}
            for _, grid in ipairs({"party", "raid10", "raid25", "raid40", "maintank", "partyPet", "raidPet"}) do
                tinsert(list, {settings.groupFrames[grid], "healthText", "health"})
            end
            return list
        end,
        health = {{health = {}}, {health = false}, {health = {Health("HEALTH", true)}}}},
    {label = PLAYER, unit = "player", globe = true, refresh = function() RefreshTextStyleFrames("player") end,
        lines = function(settings)
            local unitframes, classpower = settings.unitframes, settings.classpower
            return {
                {unitframes.player, "healthText", "health"}, {unitframes.player, "powerText", "power"},
                {unitframes.pet, "healthText", "health"}, {unitframes.pet, "powerText", "power"},
                {unitframes.healthGlobe, "healthText", "globe"}, {settings.powerBar, "powerText", "powerBar"},
                {classpower, "manaText", "mana"}, {classpower, "littleManaText", "mana"},
            }
        end,
        health = {
            {health = {Health("HEALTH", true)}, globe = {Health("HEALTH", true)}},
            {health = false, globe = false},
            {health = {Health("CURPREC")}, globe = {Health("HEALTH"), {k = "newLine"}, Health("PREC")}},
        },
        power = {
            {power = {}, powerBar = {}, mana = {}},
            {power = false, powerBar = false, mana = false},
            {power = DETAILED_POWER, powerBar = DETAILED_POWER, mana = false},
        }},
}

local function ApplyTextStyle(frame, style)
    for _, entry in ipairs(frame.lines(GW.settings)) do
        local db, line, kind = entry[1], entry[2], entry[3]
        if type(db) == "table" and style[kind] ~= nil then
            db[line] = style[kind] and CopyTable(style[kind]) or false
        end
    end
end

-- the preview shows the health and power line of the first frame of the column, for the player globe and power bar
local function PreviewBlocks(frame, style, kind, line)
    local blocks = style[kind]
    if blocks == false then
        if kind == "globe" then
            return GW.GetHealthGlobeTextTarget().getDefault(line)
        elseif kind == "powerBar" then
            return GW.GetPowerBarTextTarget().getDefault(line)
        end
        return frame.unit and GW.GetUnitFrameTextTarget(frame.unit).getDefault(line) or GW.GetGridDefaultTextBlocks(line)
    end
    return blocks or {}
end

-- names, a zone and numbers in the fonts of the chosen template; the fonts themselves change after the reload
local function CreateFontPreview(parent)
    local preview = CreateFrame("Frame", nil, parent)
    preview:SetSize(300, 96)
    preview:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    local classColor = GW.GWGetClassColor(select(2, UnitClass("player")), true, true)
    preview.name = preview:CreateFontString(nil, "OVERLAY")
    preview.name:SetPoint("TOPLEFT", 14, -12)
    preview.name:SetTextColor(classColor.r, classColor.g, classColor.b)
    preview.zone = preview:CreateFontString(nil, "OVERLAY")
    preview.zone:SetPoint("TOPLEFT", preview.name, "BOTTOMLEFT", 0, -6)
    preview.zone:SetTextColor(0.9, 0.85, 0.7)
    preview.numbers = preview:CreateFontString(nil, "OVERLAY")
    preview.numbers:SetPoint("TOPLEFT", preview.zone, "BOTTOMLEFT", 0, -6)
    preview.numbers:SetTextColor(0.62, 0.58, 0.5)

    function preview:Update()
        local normal, header = GW.GetFontFamilies()
        if not normal or normal == "" then
            local blizzard = GW.BlizzardFonts or {normal = UNIT_NAME_FONT, header = DAMAGE_TEXT_FONT}
            normal, header = blizzard.normal, blizzard.header
        elseif not header or header == "" then
            header = normal
        end
        local size, outline = GW.settings.fonts.size, GW.settings.fonts.outline or ""
        self.name:SetFont(header, size.bigHeader + 6, outline)
        self.zone:SetFont(normal, size.normal, outline)
        self.numbers:SetFont(normal, size.small, outline)
    end
    -- a font string needs its font before the first text
    preview:Update()
    preview.name:SetText(UnitName("player"))
    preview.zone:SetText(GetRealZoneText())
    preview.numbers:SetFormattedText("%s %s  |  %s %s", HEALTH, BreakUpLargeNumbers(58204), L["Power"], BreakUpLargeNumbers(42000))
    return preview
end

local function CreatePreviewBar(parent, color, width, height)
    local bar = parent:CreateTexture(nil, "ARTWORK")
    bar:SetTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
    bar:SetVertexColor(color:GetRGB())
    bar:SetSize(width, height)
    return bar
end

-- target and group as a bar frame, the player as health globe with the power bar next to it
local function CreateStylePreview(parent, frame)
    local preview = CreateFrame("Frame", nil, parent)
    preview:SetSize(145, 64)

    local title = preview:CreateFontString(nil, "OVERLAY")
    title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    title:SetTextColor(0.62, 0.58, 0.5)
    title:SetPoint("BOTTOMLEFT", preview, "TOPLEFT", 0, 4)
    title:SetText(frame.label)

    local health, power
    if frame.globe then
        local globe = CreateFrame("StatusBar", nil, preview)
        globe:SetSize(64, 64)
        globe:SetPoint("LEFT")
        globe:SetOrientation("VERTICAL")
        globe:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/globe/globetextured.png")
        globe:SetMinMaxValues(0, 1)
        globe:SetValue(0.72)
        local background = globe:CreateTexture(nil, "BACKGROUND")
        background:SetTexture("Interface/AddOns/GW2_UI/textures/globe/globewhite.png")
        background:SetVertexColor(0, 0, 0)
        background:SetAllPoints()
        local border = globe:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface/AddOns/GW2_UI/textures/globe/globeborder.png")
        border:SetAllPoints()
        health = globe

        power = CreatePreviewBar(preview, GW.oUF.colors.power.MANA, 145 - 70, 14)
        power:SetPoint("LEFT", globe, "RIGHT", 6, 0)
    else
        -- a health bar on top and a power bar below, each with its text
        local box = CreateFrame("Frame", nil, preview)
        box:SetSize(145, 36)
        box:SetPoint("LEFT")
        box:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        health = CreatePreviewBar(box, GW.oUF.colors.health, 145 * 0.72, 21)
        health:SetPoint("TOPLEFT")
        power = CreatePreviewBar(box, GW.oUF.colors.power.MANA, 145 * 0.84, 14)
        power:SetPoint("BOTTOMLEFT")
    end

    local textParent = frame.globe and health or preview
    preview.healthText = textParent:CreateFontString(nil, "OVERLAY")
    preview.healthText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    preview.healthText:SetPoint(frame.globe and "CENTER" or "LEFT", health, frame.globe and "CENTER" or "LEFT", frame.globe and 0 or 4, 0)
    preview.healthText:SetJustifyH(frame.globe and "CENTER" or "LEFT")
    preview.powerText = preview:CreateFontString(nil, "OVERLAY")
    preview.powerText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    preview.powerText:SetPoint("LEFT", power, "LEFT", 4, 0)

    function preview:SetStyles(healthStyle, powerStyle)
        self.healthText:SetText(GW.BuildTagPreview(PreviewBlocks(frame, healthStyle, frame.globe and "globe" or "health", "healthText")))
        self.powerText:SetText(GW.BuildTagPreview(PreviewBlocks(frame, powerStyle or {}, frame.globe and "powerBar" or "power", "powerText")))
    end
    return preview
end

-- ============================
-- Install UI building blocks
-- ============================
local function CreateActionButton(parent, width)
    local button = CreateFrame("Button", nil, parent, "GwStandardButton")
    button:SetSize(width or 146, 28)
    return button
end

-- fades a region in; only the alpha moves, a moving text snaps from pixel to pixel and looks shaky
local function PlayFadeIn(region, delay)
    local group = region.gwFadeIn
    if not group then
        group = region:CreateAnimationGroup()
        group.fade = group:CreateAnimation("Alpha")
        group.fade:SetFromAlpha(0)
        group.fade:SetToAlpha(1)
        group.fade:SetDuration(0.4)
        group.fade:SetSmoothing("OUT")
        group:SetToFinalAlpha(true)
        region.gwFadeIn = group
    end
    group:Stop()
    group.fade:SetStartDelay(delay or 0)
    region:SetAlpha(0)
    group:Play()
end

-- a small text that works as a button, for side actions that should not look like the main buttons
local function CreateTextLink(parent, text, onClick)
    local link = CreateFrame("Button", nil, parent)
    link.text = link:CreateFontString(nil, "OVERLAY")
    link.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    link.text:SetPoint("CENTER")
    link.text:SetTextColor(0.62, 0.58, 0.5)
    link.text:SetText(text)
    link:SetSize(link.text:GetStringWidth() + 4, 16)
    link:SetScript("OnEnter", function(self) self.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB()) end)
    link:SetScript("OnLeave", function(self) self.text:SetTextColor(0.62, 0.58, 0.5) end)
    link:SetScript("OnClick", onClick)
    return link
end

local function CreateInstallCheckbox(parent, label)
    local check = CreateFrame("CheckButton", nil, parent)
    check:SetSize(16, 16)
    check:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
    check:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")

    check.label = check:CreateFontString(nil, "OVERLAY")
    check.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    check.label:SetTextColor(0.9, 0.85, 0.7)
    check.label:SetJustifyH("LEFT")
    check.label:SetPoint("LEFT", check, "RIGHT", 6, 0)
    check.label:SetText(label)
    return check
end

-- ============================
-- Steps
-- ============================
-- grouped as the tiles show them; frames returns what the spotlight lights while a tile is hovered.
-- Dotted settings resolve nested

-- previews show a module that is not on the screen while its tile is hovered; show returns false when there is
-- nothing to show. Large ones are windows: they wait a moment and the installer fades back meanwhile
local previewDriver = CreateFrame("Frame")

-- the fake cast loops and holds the bar up every frame: moving its mover or a settings update hides it again
local CAST_BAR_PREVIEW = {
    show = function()
        local bar = GwCastingBarPlayer
        -- a real cast runs its own update
        if not bar or bar:GetScript("OnUpdate") then return false end
        bar:SetValues(L["Cast Bar"], 134414)
        if bar.time then bar.time:SetText("") end
        local elapsedTotal = 0
        local function Update(_, elapsed)
            if bar:GetScript("OnUpdate") then return end
            -- the bar fades itself out after a second without a real cast
            bar.gwStuckVisibleSince = nil
            elapsedTotal = (elapsedTotal + elapsed) % 2
            bar.progress:SetFillAmount(elapsedTotal / 2)
            bar:SetAlpha(1)
        end
        -- visible right away, the spotlight looks for it in the same moment
        Update(nil, 0)
        previewDriver:SetScript("OnUpdate", Update)
    end,
    hide = function()
        previewDriver:SetScript("OnUpdate", nil)
        local bar = GwCastingBarPlayer
        if bar and not bar:GetScript("OnUpdate") then
            bar:SetAlpha(0)
        end
    end,
}

local bagsWereOpen
local BAGS_PREVIEW = {
    show = function()
        if not GwBagFrame then return false end
        bagsWereOpen = GwBagFrame:IsShown()
        if not bagsWereOpen then GwBagFrame:Show() end
    end,
    hide = function()
        if not bagsWereOpen then GwBagFrame:Hide() end
    end,
}

local NOTIFICATION_PREVIEW = {
    show = function()
        if not (GW.AlertPreviews and GW.AlertPreviews.LEVEL_UP) then return false end
        GW.AlertPreviews.LEVEL_UP()
    end,
    hide = function() end,
}

local TOOLTIP_PREVIEW = {
    ownTooltip = true,
    show = function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit("player")
    end,
    hide = function() GameTooltip:Hide() end,
}

-- a panel of the hero window, only opened and closed by us when it was not open before
local function HeroPanelPreview(panel)
    local wasOpen
    local function Close()
        GwCharacterWindow:SetAttribute("windowpanelopen", nil)
    end
    return {
        large = true,
        show = function()
            if not GwCharacterWindow then return false end
            wasOpen = GwCharacterWindow:IsShown()
            if not wasOpen then GwCharacterWindow:SetAttribute("windowpanelopen", panel) end
        end,
        hide = function()
            if wasOpen or not GwCharacterWindow then return end
            if InCombatLockdown() then
                GW.CombatQueue:Queue("GwInstallerHeroPanel", Close)
            else
                Close()
            end
        end,
    }
end

local socialWasOpen
local SOCIAL_PREVIEW = {
    large = true,
    show = function()
        if not SocialUIFrame then return false end
        socialWasOpen = SocialUIFrame:IsShown()
        if not socialWasOpen then SocialUIFrame:Show() end
    end,
    hide = function()
        if SocialUIFrame and not socialWasOpen then SocialUIFrame:Hide() end
    end,
}

local function UnitPreview(unit, getFrame)
    return {
        show = function() ShowUnitCopy(unit, getFrame()) end,
        hide = function() HideUnitCopy(unit) end,
    }
end

local function GroupPreview(getKind)
    local kind
    return {
        show = function()
            kind = getKind()
            ShowGroupPreview(kind)
        end,
        hide = function() HideGroupPreview(kind) end,
    }
end

local MODULE_GROUPS = {
    {key = "unit", label = UNITFRAME_LABEL},
    {key = "hud", label = L["HUD"]},
    {key = "windows", label = L["Windows"]},
    {key = "misc", label = MISCELLANEOUS or OTHER},
}

local MODULES = {
    { setting = "unitframes.healthGlobe.enabled", name = PLAYER, group = "unit", frames = function() return {GW2_PlayerFrame, GwPlayerUnitFrame} end },
    { setting = "powerBar.enabled", name = L["Power Bar"], group = "unit", frames = function() return {GwPlayerPowerBar} end },
    { setting = "castingbar.enabled", name = L["Cast Bar"], group = "unit", preview = CAST_BAR_PREVIEW, frames = function() return {GwCastingBarPlayer} end },
    { setting = "playerAuras.enabled", name = L["Auras"], group = "unit", frames = function() return {GW2UIPlayerBuffs, GW2UIPlayerDebuffs} end },
    { setting = "classpower.enabled", name = L["Class Power"], group = "unit", frames = function() return {GwPlayerClassPower} end },
    { setting = "unitframes.target.enabled", name = TARGET, group = "unit", preview = UnitPreview("target", function() return GwTargetUnitFrame end),
        frames = function() return {UnitFrameOrCopy("target", GwTargetUnitFrame)} end },
    { setting = "unitframes.focus.enabled", name = FOCUS, group = "unit", hidden = GW.Classic, preview = UnitPreview("focus", function() return GwFocusUnitFrame end),
        frames = function() return {UnitFrameOrCopy("focus", GwFocusUnitFrame)} end },
    { setting = "unitframes.pet.enabled", name = PET, group = "unit", frames = function() return {GwPlayerPetFrame} end },
    { setting = "unitframes.party.enabled", name = PARTY, group = "unit", preview = GroupPreview(PartyPreviewKind),
        frames = function() return GroupPreviewFrames(PartyPreviewKind()) end },
    { setting = "groupFrames.party.enabled", name = USE_RAID_STYLE_PARTY_FRAMES, group = "unit", preview = GroupPreview(function() return "party" end),
        frames = function() return GroupPreviewFrames("party") end },
    { setting = "groupFrames.enabled", name = RAID_FRAMES_LABEL or RAID, group = "unit", preview = GroupPreview(RaidPreviewKind),
        frames = function() return GroupPreviewFrames(RaidPreviewKind()) end },
    { setting = "actionbars.enabled", name = BINDING_HEADER_ACTIONBAR, group = "hud", gamepadReplaced = true,
        frames = function() return {MainActionBar or MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarRight, MultiBarLeft} end },
    { setting = "micromenu.enabled", name = L["Micro Bar"], group = "hud", gamepadReplaced = true, frames = function() return {Gw2MicroBarFrame} end },
    { setting = "hud.xpBar", name = XPBAR_LABEL, group = "hud", frames = function() return {GwExperienceFrame} end },
    { setting = "minimap.enabled", name = MINIMAP_LABEL or MINIMAP_ZOOM, group = "hud", frames = function() return {Minimap} end },
    { setting = "objectives.enabled", name = L["Tracker"], group = "hud", frames = function() return {GwQuestTracker} end },
    { setting = "chat.enabled", name = CHAT, group = "hud", frames = function() return {FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) or ChatFrame1} end },
    { setting = "bags.enabled", name = INVENTORY_TOOLTIP, group = "windows", preview = BAGS_PREVIEW, frames = function() return {GwBagFrame} end },
    { setting = "windows.character.enabled", name = L["Character Pane"], group = "windows", preview = HeroPanelPreview("paperdoll"), frames = function() return {GwCharacterWindow} end },
    { setting = "windows.talent.enabled", name = TALENTS, group = "windows", hidden = GW.Retail, preview = HeroPanelPreview("talents"), frames = function() return {GwCharacterWindow} end },
    { setting = "windows.profession.enabled", name = TRADE_SKILLS, group = "windows", preview = HeroPanelPreview("professions"), frames = function() return {GwCharacterWindow} end },
    { setting = "windows.social.enabled", name = FRIENDS, group = "windows", preview = SOCIAL_PREVIEW, frames = function() return {SocialUIFrame} end },
    { setting = "immersiveQuesting.enabled", name = L["Immersive Questing"], group = "windows" },
    { setting = "general.battlegroundHud", name = BATTLEGROUND, group = "misc" },
    { setting = "chat.bubbles.enabled", name = CHAT_BUBBLES_TEXT, group = "misc" },
    { setting = "notifications.enabled", name = COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL, group = "misc", preview = NOTIFICATION_PREVIEW, frames = function() return {GW.AlertContainerFrame} end },
    { setting = "tooltip.enabled", name = L["Tooltips"], group = "misc", preview = TOOLTIP_PREVIEW, frames = function() return {GameTooltip} end },
}

-- the gamepad interface brings its own action bars and micro menu
local function IsModuleShown(module)
    return not module.hidden and not (module.gamepadReplaced and GW.IsGamepadInterface())
end

-- flavor gated steps drop out entirely, the step rail follows #STEPS
local function RemoveHiddenSteps(steps)
    for i = #steps, 1, -1 do
        if steps[i].hidden then
            tremove(steps, i)
        end
    end
    return steps
end

local GetModuleValue = GW.GetSetting
local SetModuleValue = GW.SetSetting

-- forward declaration: the final steps summary closure iterates STEPS, and a local
-- only enters scope AFTER its declaration statement - inline it would capture a
-- global nil instead
-- defined with the spotlight further down, the module tiles and the layout step use them
local SetHighlights, SetSpotlight

-- a module as a tile: click switches it, hovering lights its frame on the screen
local MODULE_TILE_WIDTH, MODULE_TILE_HEIGHT, MODULE_TILE_GAP = 114, 26, 4

local function CreateModuleTile(parent, module, step)
    local tile = CreateFrame("Button", nil, parent)
    tile:SetSize(MODULE_TILE_WIDTH, MODULE_TILE_HEIGHT)
    tile.module = module

    local background = tile:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.4)
    tile.accent = tile:CreateTexture(nil, "ARTWORK")
    tile.accent:SetPoint("TOPLEFT")
    tile.accent:SetPoint("BOTTOMLEFT")
    tile.accent:SetWidth(2)
    tile.accent:SetColorTexture(GW.Colors.Accent:GetRGB())
    local hover = tile:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.06)

    tile.check = tile:CreateTexture(nil, "ARTWORK")
    tile.check:SetSize(14, 14)
    tile.check:SetPoint("RIGHT", -6, 0)

    tile.label = tile:CreateFontString(nil, "OVERLAY")
    tile.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    tile.label:SetPoint("LEFT", 9, 0)
    tile.label:SetPoint("RIGHT", tile.check, "LEFT", -4, 0)
    tile.label:SetJustifyH("LEFT")
    tile.label:SetWordWrap(false)
    tile.label:SetText(module.name)

    function tile:Update()
        local enabled = GetModuleValue(module.setting)
        self.accent:SetShown(enabled)
        self.check:SetTexture(enabled and "Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png"
            or "Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
        if enabled then
            self.label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        else
            self.label:SetTextColor(0.5, 0.47, 0.42)
        end
    end
    tile:Update()

    tile:SetScript("OnClick", function(self)
        local enabled = not GetModuleValue(module.setting)
        SetModuleValue(module.setting, enabled)
        PlaySound(enabled and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        self:Update()
        step.applied = true
    end)
    tile:SetScript("OnEnter", function(self)
        local preview = module.preview
        if not (preview and preview.ownTooltip) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(module.name, 1, 1, 1)
            GameTooltip:AddLine(L["Changes take effect once the installation completes."], 0.9, 0.85, 0.7, true)
            GameTooltip:Show()
        end
        if not preview then
            if module.frames then
                SetHighlights({[module] = module.frames()})
            end
            return
        end

        local function ShowPreview()
            self.previewTimer = nil
            if preview.large and InCombatLockdown() then return end
            if preview.show() == false then return end
            self.previewShown = true
            if preview.large then
                UIFrameFadeOut(wpanel.window, 0.2, wpanel.window:GetAlpha(), 0.15)
            end
            -- right away; a frame that needs a moment for its size joins the running animation later
            SetHighlights({[module] = module.frames()})
            C_Timer.After(0.05, function()
                if self.previewShown then SetHighlights({[module] = module.frames()}, true) end
            end)
            C_Timer.After(0.3, function()
                if self.previewShown then SetHighlights({[module] = module.frames()}, true) end
            end)
        end
        if preview.large then
            self.previewTimer = C_Timer.NewTimer(0.3, ShowPreview)
        else
            ShowPreview()
        end
    end)
    tile:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.previewTimer then
            self.previewTimer:Cancel()
            self.previewTimer = nil
        end
        if self.previewShown then
            self.previewShown = nil
            module.preview.hide()
            if module.preview.large then
                UIFrameFadeIn(wpanel.window, 0.2, wpanel.window:GetAlpha(), 1)
            end
        end
        SetHighlights({})
    end)
    return tile
end

-- playstyle like the layouts of other interfaces: melee and ranged keep the GW positions, the healer gets the
-- group and raid grids at the bottom in the middle with heal over time effects, power bars and dispellable debuffs
local PLAYSTYLES = {
    {key = "MELEE", label = MELEE, icon = GW.nameRoleIconPure.TANK,
        desc = L["Group and raid frames on the left, the cast bar above the action bars."]},
    {key = "HEALER", label = HEALER, icon = GW.nameRoleIconPure.HEALER,
        desc = L["Group and raid frames at the bottom in the middle, with heal over time effects, power bars and dispellable debuffs."]},
    {key = "RANGED", label = RANGED, icon = GW.nameRoleIconPure.DAMAGER,
        desc = L["Group and raid frames on the left, the cast bar above the action bars."]},
}
local HEALER_GRID_POSITIONS = {"party", "raid10", "raid25"}
local HEALER_GRID_VALUES = {showBuffs = true, showPowerBar = "ALL", dispelBorder = "DISPELLABLE", dispelIcon = "DISPELLABLE"}

local function DetectPlaystyle()
    if GW.myspecRole == "HEALER" then
        return "HEALER"
    elseif GW.myspecRole == "DAMAGER" and GW.myspec then
        local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(GW.myspec))
        -- survival hunters fight in melee
        if primaryStat == (LE_UNIT_STAT_INTELLECT or 4) or (GW.myclass == "HUNTER" and GW.myspecID ~= 255) then
            return "RANGED"
        end
    end
    return "MELEE"
end

-- the rect of a shown frame in UIParent units
local function ScreenRect(frame)
    if not (frame and frame:IsShown()) then return end
    local left, bottom, width, height = frame:GetRect()
    if not left or GW.IsSecretValue(width) then return end
    local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    return left * scale, bottom * scale, width * scale, height * scale
end

local function SetPosition(db, point, x, y)
    db.pos = {point = point, relativePoint = "BOTTOM", xOfs = GW.RoundInt(x), yOfs = GW.RoundInt(y), hasMoved = true}
end

local function ApplyPlaystyle(style)
    local healer = style == "HEALER"
    local groupFrames = GW.settings.groupFrames
    for _, profile in ipairs({"party", "raid10", "raid25", "raid40"}) do
        for key, value in pairs(HEALER_GRID_VALUES) do
            groupFrames[profile][key] = healer and value or GW.GetSettingDefault("groupFrames." .. profile .. "." .. key)
        end
    end
    groupFrames.party.enabled = healer or GW.GetSettingDefault("groupFrames.party.enabled")

    -- melee and ranged use the default places; healers with the globe get the grids above the action bars left of
    -- globe and cast bar, in the WoW layout the cast bar sits above the action bars and the grids in the middle above it
    GW.settings.castingbar.pos = CopyTable(GW.GetSettingDefault("castingbar.pos"))
    for _, profile in ipairs(HEALER_GRID_POSITIONS) do
        groupFrames[profile].pos = CopyTable(GW.GetSettingDefault("groupFrames." .. profile .. ".pos"))
    end
    if healer then
        local castBar = GwCastingBarPlayer and GwCastingBarPlayer.gwMover
        local castBarScale = castBar and castBar:GetEffectiveScale() / UIParent:GetEffectiveScale() or 1
        -- the buttons count, a bar frame reaches higher than its shown rows
        local hudTop = 120
        for _, prefix in ipairs({"ActionButton", "MultiBarBottomLeftButton"}) do
            for i = 1, 12 do
                local button = _G[prefix .. i]
                local _, bottom, _, height = ScreenRect(button and button:IsVisible() and button)
                if bottom then hudTop = math.max(hudTop, bottom + height) end
            end
        end
        local point, x, y
        if GW.settings.unitframes.player.enabled then
            SetPosition(GW.settings.castingbar, "BOTTOM", 0, hudTop + 10)
            point, x, y = "BOTTOM", 0, hudTop + 20 + (castBar and castBar:GetHeight() * castBarScale or 20)
        else
            local centerX = UIParent:GetWidth() / 2
            local globeLeft = ScreenRect(GW2_PlayerFrame) or (centerX - 60)
            local castBarLeft = castBar and centerX - castBar:GetWidth() * castBarScale / 2 or globeLeft
            point, x, y = "BOTTOMRIGHT", math.min(globeLeft, castBarLeft) - centerX - 10, hudTop + 10
        end
        for _, profile in ipairs(HEALER_GRID_POSITIONS) do
            SetPosition(groupFrames[profile], point, x, y)
        end
    end

    GW.ApplyMoverPositionsFromSettings()
    GW.UpdateGridSettings("ALL")
    -- the grid update drops the fake members of a running config mode
    for kind in pairs(shownGroupPreviews) do
        if kind ~= "partyFrames" then
            GW.RefreshGridConfigurationMode(kind, true)
        end
    end
end

-- the step shows the cast bar and the raid grid while it is open; the party grid moves to the same place, both
-- at once would lie on top of each other
local playstyleGroupKind

-- the WoW layout comes with the reload: until then the globe and what goes with it are faded in its previews
local function SetGlobeShown(shown)
    if not GW2_PlayerFrame then return end
    local alpha = shown and 1 or 0
    GW2_PlayerFrame:SetAlpha(alpha)
    if GwDodgeBar then GwDodgeBar:SetAlpha(alpha) end
    if GwPlayerPowerBar and not GW.settings.unitframes.player.showResourceBar then GwPlayerPowerBar:SetAlpha(alpha) end
end

local function ShowPlaystyleFrames()
    SetGlobeShown(not GW.settings.unitframes.player.enabled)
    CAST_BAR_PREVIEW.show()
    playstyleGroupKind = RaidPreviewKind()
    ShowGroupPreview(playstyleGroupKind)
end

local function HidePlaystyleFrames()
    SetGlobeShown(true)
    CAST_BAR_PREVIEW.hide()
    HideGroupPreview(playstyleGroupKind)
end

local function PlaystyleHighlights()
    return {{GwCastingBarPlayer}, GroupPreviewFrames(playstyleGroupKind)}
end

local function CreatePlaystyleCard(parent, style)
    local card = CreateFrame("Button", nil, parent)
    card:SetSize(150, 176)
    card.style = style
    local background = card:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.4)
    card.selected = card:CreateTexture(nil, "BACKGROUND", nil, 1)
    card.selected:SetAllPoints()
    card.selected:SetColorTexture(GW.Colors.Accent.r, GW.Colors.Accent.g, GW.Colors.Accent.b, 0.18)
    local hover = card:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.06)
    card:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)

    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("TOP", 0, -16)
    if style.portrait then
        SetPortraitTexture(icon, "player")
        local mask = card:CreateMaskTexture()
        mask:SetAllPoints(icon)
        mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        icon:AddMaskTexture(mask)
    else
        icon:SetTexture(style.icon)
    end

    card.title = card:CreateFontString(nil, "OVERLAY")
    card.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    card.title:SetPoint("TOP", icon, "BOTTOM", 0, -10)
    card.title:SetText(style.label)

    local desc = card:CreateFontString(nil, "OVERLAY")
    desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    desc:SetTextColor(0.62, 0.58, 0.5)
    desc:SetPoint("TOP", card.title, "BOTTOM", 0, -8)
    desc:SetWidth(132)
    desc:SetJustifyH("CENTER")
    desc:SetText(style.desc)

    function card:SetSelected(selected)
        self.selected:SetShown(selected)
        if selected then
            self.backdrop:SetBackdropBorderColor(GW.Colors.Accent:GetRGB())
            self.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        else
            self.backdrop:SetBackdropBorderColor(0, 0, 0, 0.6)
            self.title:SetTextColor(0.62, 0.58, 0.5)
        end
    end
    return card
end

local function LabelOf(list, key)
    for _, entry in ipairs(list) do
        if entry.key == key then return entry.label end
    end
end

local LAYOUTS = {
    {key = "GW2", label = "GW2 UI", icon = "Interface/AddOns/GW2_UI/textures/globe/globetextured.png",
        desc = L["Health globe in the middle, target and target of target at the top."]},
    {key = "WOW", label = L["WoW Style"], portrait = true,
        desc = L["Player frame on the left, target on the right above the action bars, like in World of Warcraft."]},
}
-- arranged like the modern Blizzard layout; the target auras go on top, below they would run into the action bars
local WOW_LAYOUT_POSITIONS = {
    player = {point = "BOTTOMRIGHT", relativePoint = "BOTTOM", xOfs = -300, yOfs = 250},
    target = {point = "BOTTOMLEFT", relativePoint = "BOTTOM", xOfs = 300, yOfs = 250},
    targettarget = {point = "TOPRIGHT", relativePoint = "BOTTOM", xOfs = 600, yOfs = 240},
}

local function DetectLayout()
    return GW.settings.unitframes.player.enabled and "WOW" or "GW2"
end

-- the player frame replaces the globe after the reload at the end
local function ApplyLayout(layout)
    local wow = layout == "WOW"
    local unitframes = GW.settings.unitframes
    unitframes.player.enabled = wow
    for unit, pos in pairs(WOW_LAYOUT_POSITIONS) do
        unitframes[unit].pos = CopyTable(wow and pos or GW.GetSettingDefault("unitframes." .. unit .. ".pos"))
    end
    unitframes.target.aurasOnTop = wow or GW.GetSettingDefault("unitframes.target.aurasOnTop")

    -- the player auras go to the top right next to the tracker, the debuffs a bit below the buffs; both grow left and
    -- down with 20 per row
    local auras = GW.settings.playerAuras
    for _, key in ipairs({"buffs", "debuffs"}) do
        local prefix = "playerAuras." .. key .. "."
        auras[key].GrowDirection = wow and "DOWN" or GW.GetSettingDefault(prefix .. "GrowDirection")
        auras[key].WrapAfter = wow and 20 or GW.GetSettingDefault(prefix .. "WrapAfter")
        auras[key].pos = CopyTable(GW.GetSettingDefault(prefix .. "pos"))
    end
    if wow then
        local trackerLeft = ScreenRect(GwQuestTracker) or (UIParent:GetWidth() - 300)
        local x = GW.RoundInt(trackerLeft - UIParent:GetWidth() - 10)
        auras.buffs.pos = {point = "TOPRIGHT", relativePoint = "TOPRIGHT", xOfs = x, yOfs = -10, hasMoved = true}
        local buffs = auras.buffs
        local buffsHeight = buffs.MaxWraps * ((buffs.KeepSizeRatio and buffs.IconSize or buffs.IconHeight) + buffs.VerticalSpacing) * buffs.scale
        auras.debuffs.pos = {point = "TOPRIGHT", relativePoint = "TOPRIGHT", xOfs = x, yOfs = GW.RoundInt(-10 - buffsHeight - 20), hasMoved = true}
    end

    GW.ApplyMoverPositionsFromSettings()
    if GwTargetUnitFrame then
        GwTargetUnitFrame:ToggleSettings()
    end
    -- the header update tells the bar layout whether the auras were moved; at their default place they follow the
    -- action bars and the bar layout puts them there
    for _, header in ipairs({GW2UIPlayerBuffs, GW2UIPlayerDebuffs}) do
        GW.UpdateAuraHeader(header)
    end
    EventRegistry:TriggerEvent("GW2_UI.ActionBarStateChanged")
end

-- the frame of the other layout only exists after the reload: a copy of the player frame stands in until then
local layoutChoice

local function ShowPlayerFrameCopy()
    if InCombatLockdown() then return end
    local copy = unitCopies.player or GW.GetUnitFrameTextTarget("player").createPreview(wpanel)
    unitCopies.player = copy
    local pos = WOW_LAYOUT_POSITIONS.player
    copy:SetScale(UIParent:GetEffectiveScale() / wpanel:GetEffectiveScale())
    copy:ClearAllPoints()
    -- the copy ends with the frame on the right and reaches 15 below it
    copy:SetPoint(pos.point, wpanel, pos.relativePoint, pos.xOfs, pos.yOfs - 15)
    copy:Show()
    RefreshUnitCopy("player")
end

local function ShowLayoutFrames()
    local wow = layoutChoice == "WOW"
    SetGlobeShown(not wow)
    if wow and not GwPlayerUnitFrame then
        ShowPlayerFrameCopy()
    else
        HideUnitCopy("player")
    end
    ShowUnitCopy("target", GwTargetUnitFrame)
    ShowUnitCopy("targettarget", GwTargetTargetUnitFrame)
end

local function HideLayoutFrames()
    SetGlobeShown(true)
    HideUnitCopy("player")
    HideUnitCopy("target")
    HideUnitCopy("targettarget")
end

local function LayoutStepHighlights()
    return {
        layoutChoice == "WOW" and (GwPlayerUnitFrame or unitCopies.player) or GW2_PlayerFrame or GwPlayerUnitFrame,
        UnitFrameOrCopy("target", GwTargetUnitFrame),
        UnitFrameOrCopy("targettarget", GwTargetTargetUnitFrame),
        -- the buffs alone, the debuffs below them would light a lot of empty room
        GW2UIPlayerBuffs,
    }
end

-- the WoW layout uses the bottom and the top right, the window waits top left
local function LayoutWindowAt()
    return layoutChoice == "WOW" and "TOPLEFT" or nil
end

-- one click install: every step with its recommended default and the playstyle of the spec, then reload
local function ApplyExpressInstall()
    ApplyChatSetup()
    ApplyCVars()

    GW.settings.general.pixelPerfection = true
    C_CVar.SetCVar("useUiScale", "0")
    GW.PixelPerfection()

    GW.settings.fonts.styleTemplate = "GW2"
    GW.ApplyFontStyleTemplate()

    if not GW.isModern then
        GW.settings.combatText.mode = "GW2"
        GW.ApplyCombatTextMode("GW2")
    end

    if not InCombatLockdown() then
        ApplyPlaystyle(DetectPlaystyle())
    end

    GW.ShowPopup({
        text = L["The recommended settings have been applied. The interface will now be reloaded."],
        OnAccept = function() C_UI.Reload() end,
        button1 = ACCEPT,
        button2 = CANCEL,
    })
end

local STEPS
STEPS = RemoveHiddenSteps({
    {
        title = CHAT,
        desc = L["This part sets up your chat window names, positions, and colors."],
        -- the selected tab, after a first setup the main chat can sit hidden behind another tab
        spotlight = function() return FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) or ChatFrame1 end,
        applyText = L["Setup Chat"],
        apply = ApplyChatSetup,
        buildContent = function(content)
            local lines = {
                L["Resets the chat windows and moves the main chat to the bottom left"],
                format(L["Adds an extra tab for %s"], LOOT .. " / " .. TRADE),
                format(L["Sets the chat font size to %d"], 12),
                L["Enables class colors for player names"],
                L["Sorts the message groups into the matching tabs"],
            }
            local previous
            for _, line in ipairs(lines) do
                local text = content:CreateFontString(nil, "OVERLAY")
                text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                text:SetTextColor(0.9, 0.85, 0.7)
                text:SetJustifyH("LEFT")
                text:SetWidth(400)
                if previous then
                    text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
                else
                    text:SetPoint("TOPLEFT", content, "TOPLEFT", 45, -8)
                end
                previous = text
                text:SetFormattedText("|cffd4b678\226\128\162|r  %s", line)
            end
        end,
    },
    {
        title = "CVars",
        desc = L["This part sets up your World of Warcraft default options."],
        applyText = L["Setup CVars"],
        apply = ApplyCVars,
        buildContent = function(content)
            local shown = {}
            for _, entry in ipairs(CVARS) do
                if CVarExists(entry) then
                    tinsert(shown, entry)
                end
            end

            local perColumn = math.ceil(#shown / 2)
            for index, entry in ipairs(shown) do
                local current = C_CVar.GetCVar(entry.cvar)
                local alreadySet = current == entry.value
                local label
                if alreadySet then
                    label = format("%s |cff888888%s|r |TInterface/RaidFrame/ReadyCheck-Ready:12|t", entry.cvar, entry.value)
                else
                    label = format("%s |cff888888%s|r |cffd4b678\226\134\146|r %s", entry.cvar, current, entry.value)
                end
                entry.enabled = not alreadySet

                local check = CreateInstallCheckbox(content, label)
                local column = math.floor((index - 1) / perColumn)
                local row = (index - 1) % perColumn
                check:SetPoint("TOPLEFT", content, "TOPLEFT", 8 + column * 232, -4 - row * 20)
                check.label:SetWidth(200)
                check.label:SetWordWrap(false)
                check:SetAlpha(alreadySet and 0.55 or 1)
                check:SetChecked(entry.enabled)
                check:SetScript("OnClick", function(self)
                    entry.enabled = self:GetChecked()
                end)
                check:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(entry.cvar, 1, 1, 1)
                    GameTooltip:AddLine(entry.desc, 0.9, 0.85, 0.7, true)
                    if alreadySet then
                        GameTooltip:AddLine(L["Already set"], 0.3, 0.92, 0.17)
                    end
                    GameTooltip:Show()
                end)
                check:SetScript("OnLeave", GameTooltip_Hide)
            end
        end,
    },
    {
        title = DISPLAY,
        desc = L["Use the recommended pixel perfect scale, or set your own - the preview applies live."],
        spotlight = "screen",
        buildContent = function(content)
            local best = GW.getBestPixelScale()
            local state = { entryScale = UIParent:GetScale(), mode = nil }
            content.gwDisplayState = state

            local slider = CreateFrame("Slider", nil, content)
            slider:SetOrientation("HORIZONTAL")
            slider:SetSize(260, 20)
            slider:SetPoint("TOP", content, "TOP", 0, -8)
            slider:SetMinMaxValues(0.64, 1.15)
            slider:SetValueStep(0.01)
            slider:SetObeyStepOnDrag(true)
            slider:SetThumbTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderhandle.png")
            slider:GetThumbTexture():SetSize(16, 16)

            local sliderBg = slider:CreateTexture(nil, "BACKGROUND")
            sliderBg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderbg.png")
            sliderBg:SetHeight(12)
            sliderBg:SetPoint("LEFT", 2, 0)
            sliderBg:SetPoint("RIGHT", -2, 0)

            slider.valueText = slider:CreateFontString(nil, "OVERLAY")
            slider.valueText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            slider.valueText:SetTextColor(0.9, 0.85, 0.7)
            slider.valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)

            slider.title = slider:CreateFontString(nil, "OVERLAY")
            slider.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            slider.title:SetTextColor(0.62, 0.58, 0.5)
            slider.title:SetPoint("BOTTOM", slider, "TOP", 0, 4)
            slider.title:SetText(UI_SCALE)

            slider:SetScript("OnValueChanged", function(self, value)
                self.valueText:SetFormattedText("%.2f", value)
                if not self.gwSyncing then
                    state.mode = "custom"
                    UIParent:SetScale(value)
                end
            end)
            slider.gwSyncing = true
            slider:SetValue(math.min(1.15, math.max(0.64, state.entryScale)))
            slider.valueText:SetFormattedText("%.2f", slider:GetValue())
            slider.gwSyncing = false
            content.gwScaleSlider = slider

            local ppButton = CreateActionButton(content, 220)
            ppButton:SetPoint("TOP", slider, "BOTTOM", 0, -18)
            ppButton:SetText(L["Apply Pixel Perfect Scale"] .. format(" (%.2f)", best))
            ppButton:SetScript("OnClick", function()
                state.mode = "pp"
                UIParent:SetScale(best)
                slider.gwSyncing = true
                slider:SetValue(math.min(1.15, math.max(0.64, best)))
                slider.valueText:SetFormattedText("%.2f", best)
                slider.gwSyncing = false
            end)
        end,
        -- NEXT commits the previewed choice, SKIP restores the scale from step entry
        onNext = function(content, step)
            local state = content.gwDisplayState
            if state.mode == "pp" then
                GW.settings.general.pixelPerfection = true
                C_CVar.SetCVar("useUiScale", "0")
                GW.PixelPerfection()
                AddCompleteAlert(L["Pixel Perfect Mode"])
                step.applied = true
                step.summaryDetail = format("%s (%.2f)", L["Pixel Perfect Mode"], GW.getBestPixelScale())
            elseif state.mode == "custom" then
                local value = content.gwScaleSlider:GetValue()
                GW.settings.general.pixelPerfection = false
                C_CVar.SetCVar("useUiScale", "1")
                C_CVar.SetCVar("uiScale", value)
                UIParent:SetScale(value)
                step.applied = true
                step.summaryDetail = format("%s %.2f", UI_SCALE, value)
            end
        end,
        onSkip = function(content)
            UIParent:SetScale(content.gwDisplayState.entryScale)
        end,
    },
    {
        title = L["Modules"],
        desc = L["Choose which parts of GW2 UI are active for you. Everything can be changed later in the settings."],
        spotlight = "screen",
        -- nothing lit until a tile is hovered
        highlights = function() return {} end,
        buildContent = function(content, step)
            local tiles = {}
            local y = 0
            for groupIndex, group in ipairs(MODULE_GROUPS) do
                local modules = {}
                for _, module in ipairs(MODULES) do
                    if module.group == group.key and IsModuleShown(module) then
                        tinsert(modules, module)
                    end
                end
                if #modules > 0 then
                    local header = content:CreateFontString(nil, "OVERLAY")
                    header:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
                    header:SetTextColor(GW.Colors.AccentLight:GetRGB())
                    header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    header:SetText(group.label)

                    if groupIndex == 1 then
                        local function SetAll(value)
                            for _, tile in ipairs(tiles) do
                                SetModuleValue(tile.module.setting, value)
                                tile:Update()
                            end
                            step.applied = true
                        end
                        local uncheckAll = CreateTextLink(content, UNCHECK_ALL, function() SetAll(false) end)
                        uncheckAll:SetPoint("TOPRIGHT", content, "TOPRIGHT", -2, -y)
                        local checkAll = CreateTextLink(content, CHECK_ALL, function() SetAll(true) end)
                        checkAll:SetPoint("RIGHT", uncheckAll, "LEFT", -14, 0)
                    end
                    y = y + 20

                    for index, module in ipairs(modules) do
                        local tile = CreateModuleTile(content, module, step)
                        local column, row = (index - 1) % 4, math.floor((index - 1) / 4)
                        tile:SetPoint("TOPLEFT", content, "TOPLEFT", column * (MODULE_TILE_WIDTH + MODULE_TILE_GAP), -(y + row * (MODULE_TILE_HEIGHT + MODULE_TILE_GAP)))
                        tinsert(tiles, tile)
                    end
                    y = y + math.ceil(#modules / 4) * (MODULE_TILE_HEIGHT + MODULE_TILE_GAP) + 4
                end
            end
        end,
        onNext = function(_, step)
            local enabled, total, names = 0, 0, {}
            for _, module in ipairs(MODULES) do
                if IsModuleShown(module) then
                    total = total + 1
                    if GetModuleValue(module.setting) then
                        enabled = enabled + 1
                        tinsert(names, module.name)
                    end
                end
            end
            step.summaryDetail = format("%d/%d", enabled, total)
            step.summaryTooltip = names
        end,
    },
    {
        title = L["Layout"],
        desc = L["Choose where the player and target frames sit."],
        spotlight = "screen",
        highlights = LayoutStepHighlights,
        onEnter = function()
            local step = installFrame.currentStep
            layoutChoice = step.gwChoice or DetectLayout()
            step.windowAt = LayoutWindowAt()
            ShowLayoutFrames()
        end,
        onLeave = HideLayoutFrames,
        buildContent = function(content, step)
            step.gwChoice = layoutChoice
            local cards = {}
            for index, layout in ipairs(LAYOUTS) do
                local card = CreatePlaystyleCard(content, layout)
                card:SetPoint("TOPLEFT", content, "TOPLEFT", (index - 1) * 160, -6)
                card:SetSelected(layout.key == step.gwChoice)
                card:SetScript("OnClick", function()
                    if InCombatLockdown() then return end
                    step.gwChoice, layoutChoice = layout.key, layout.key
                    ApplyLayout(layout.key)
                    for _, other in ipairs(cards) do
                        other:SetSelected(other == card)
                    end
                    step.windowAt = LayoutWindowAt()
                    SetSpotlight("screen", true, step.windowAt)
                    -- the healer grids depend on the layout, the playstyle step applies again
                    for _, other in ipairs(STEPS) do
                        if other.title == L["Playstyle"] then other.applied = nil end
                    end
                    -- the movers move right away, the copies and lit areas follow them
                    C_Timer.After(0.05, function()
                        if installFrame.currentStep ~= step then return end
                        ShowLayoutFrames()
                        SetHighlights(LayoutStepHighlights())
                    end)
                end)
                cards[index] = card
            end
        end,
        onNext = function(_, step)
            step.summaryDetail = LabelOf(LAYOUTS, step.gwChoice)
        end,
    },
    {
        title = L["Playstyle"],
        desc = L["Choose how you play. Group and raid frames move to where you need them."],
        spotlight = "screen",
        -- the grids sit left and at the bottom
        windowAt = "TOPRIGHT",
        highlights = PlaystyleHighlights,
        onEnter = ShowPlaystyleFrames,
        onLeave = HidePlaystyleFrames,
        buildContent = function(content, step)
            step.gwChoice = step.gwChoice or DetectPlaystyle()
            local cards = {}
            for index, style in ipairs(PLAYSTYLES) do
                local card = CreatePlaystyleCard(content, style)
                card:SetPoint("TOPLEFT", content, "TOPLEFT", (index - 1) * 160, -6)
                card:SetSelected(style.key == step.gwChoice)
                card:SetScript("OnClick", function()
                    if InCombatLockdown() then return end
                    step.gwChoice = style.key
                    ApplyPlaystyle(style.key)
                    step.applied = true
                    for _, other in ipairs(cards) do
                        other:SetSelected(other == card)
                    end
                    -- the movers move right away, the lit areas glide after them
                    C_Timer.After(0.05, function() SetHighlights(PlaystyleHighlights()) end)
                end)
                cards[index] = card
            end
        end,
        -- the preselected style counts when next is pressed without a click
        onNext = function(_, step)
            if not step.applied and not InCombatLockdown() then
                ApplyPlaystyle(step.gwChoice)
            end
            step.summaryDetail = LabelOf(PLAYSTYLES, step.gwChoice)
        end,
    },
    {
        title = L["Fonts"],
        desc = L["Choose from predefined options to customize fonts and text styles, adjusting the appearance of your text."],
        buildContent = function(content, step)
            local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
            dropdown:SetSize(220, 25)
            dropdown:SetPoint("TOP", content, "TOP", 0, -10)
            dropdown:GwHandleDropDownBox(nil, nil, nil, 220)
            dropdown:SetupMenu(function(_, rootDescription)
                for index, template in ipairs(GW.FONT_STYLE_TEMPLATES) do
                    rootDescription:CreateRadio(GW.FONT_STYLE_TEMPLATE_NAMES[index],
                        function() return GW.settings.fonts.styleTemplate == template end,
                        function()
                            GW.settings.fonts.styleTemplate = template
                            GW.ApplyFontStyleTemplate()
                            content.gwFontPreview:Update()
                            step.applied = true
                            step.summaryDetail = GW.FONT_STYLE_TEMPLATE_NAMES[index]
                        end)
                end
            end)

            content.gwFontPreview = CreateFontPreview(content)
            content.gwFontPreview:SetPoint("TOP", dropdown, "BOTTOM", 0, -20)
        end,
        onNext = function(_, step)
            if not step.summaryDetail then
                for index, template in ipairs(GW.FONT_STYLE_TEMPLATES) do
                    if GW.settings.fonts.styleTemplate == template then
                        step.summaryDetail = GW.FONT_STYLE_TEMPLATE_NAMES[index]
                    end
                end
            end
        end,
    },
    {
        title = L["Text Style"],
        spotlight = "screen",
        highlights = TextStyleHighlights,
        onEnter = ShowTextStyleFrames,
        onLeave = HideTextStyleFrames,
        desc = L["Choose how much the health and power texts of the unit frames show. Every text can be changed later in the text designer."],
        -- a column per frame, a preview and a dropdown for health and for power; what is not picked keeps its texts
        buildContent = function(content, step)
            step.gwChoices = step.gwChoices or {}
            for index, frame in ipairs(TEXT_STYLE_FRAMES) do
                local choices = step.gwChoices[index] or {}
                step.gwChoices[index] = choices
                local preview = CreateStylePreview(content, frame)
                preview:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + (index - 1) * 155, -30)
                local function UpdatePreview()
                    preview:SetStyles(frame.health[choices.health or 2], frame.power and frame.power[choices.power or 2])
                end
                UpdatePreview()

                local previous = preview
                for _, section in ipairs(TEXT_STYLE_SECTIONS) do
                    local styles = frame[section.key]
                    if styles then
                        local label = content:CreateFontString(nil, "OVERLAY")
                        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
                        label:SetTextColor(0.62, 0.58, 0.5)
                        label:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -10)
                        label:SetText(section.label)

                        local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
                        dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
                        dropdown:GwHandleDropDownBox(nil, nil, nil, 145)
                        dropdown:SetupMenu(function(_, rootDescription)
                            for styleIndex, name in ipairs(TEXT_STYLE_NAMES) do
                                rootDescription:CreateRadio(name, function() return (choices[section.key] or 2) == styleIndex end, function()
                                    choices[section.key] = styleIndex
                                    ApplyTextStyle(frame, styles[styleIndex])
                                    frame.refresh()
                                    UpdatePreview()
                                    step.applied = true
                                end)
                            end
                        end)
                        previous = dropdown
                    end
                end
            end
        end,
        onNext = function(_, step)
            local parts = {}
            for index, frame in ipairs(TEXT_STYLE_FRAMES) do
                local choices = step.gwChoices and step.gwChoices[index] or {}
                for _, section in ipairs(TEXT_STYLE_SECTIONS) do
                    if choices[section.key] then
                        tinsert(parts, format("%s %s: %s", frame.label, section.label, TEXT_STYLE_NAMES[choices[section.key]]))
                    end
                end
            end
            step.summaryDetail = #parts > 0 and table.concat(parts, ", ") or nil
        end,
    },
    {
        title = COMBAT_TEXT_LABEL,
        desc = COMBAT_SUBTEXT,
        hidden = GW.isModern,
        buildContent = function(content, step)
            local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
            dropdown:SetSize(220, 25)
            dropdown:SetPoint("TOP", content, "TOP", 0, -10)
            dropdown:GwHandleDropDownBox(nil, nil, nil, 220)
            dropdown:SetupMenu(function(_, rootDescription)
                for index, mode in ipairs(GW.COMBAT_TEXT_MODES) do
                    rootDescription:CreateRadio(GW.COMBAT_TEXT_MODE_NAMES[index],
                        function() return GW.settings.combatText.mode == mode end,
                        function()
                            GW.settings.combatText.mode = mode
                            GW.ApplyCombatTextMode(mode)
                            step.applied = true
                            step.summaryDetail = GW.COMBAT_TEXT_MODE_NAMES[index]
                        end)
                end
            end)
        end,
        onNext = function(_, step)
            if not step.summaryDetail then
                for index, mode in ipairs(GW.COMBAT_TEXT_MODES) do
                    if GW.settings.combatText.mode == mode then
                        step.summaryDetail = GW.COMBAT_TEXT_MODE_NAMES[index]
                    end
                end
            end
        end,
    },
    {
        title = L["Profiles"],
        desc = L["This part helps you manage your settings profile. Profiles can be shared between characters."],
        buildContent = function(content, step)
            local currentLabel = content:CreateFontString(nil, "OVERLAY")
            currentLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            currentLabel:SetTextColor(0.9, 0.85, 0.7)
            currentLabel:SetPoint("TOP", content, "TOP", 0, -6)
            content.gwCurrentProfile = currentLabel

            local function UpdateCurrentLabel()
                currentLabel:SetFormattedText("%s |cffffffff%s|r", L["Current profile:"], GW.globalSettings:GetCurrentProfile())
            end
            UpdateCurrentLabel()

            local dropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
            dropdown:SetSize(220, 25)
            dropdown:SetPoint("TOP", currentLabel, "BOTTOM", 0, -12)
            dropdown:GwHandleDropDownBox(nil, nil, nil, 220)
            dropdown:SetupMenu(function(_, rootDescription)
                for _, profileName in ipairs(GW.globalSettings:GetProfiles() or {}) do
                    rootDescription:CreateRadio(profileName,
                        function() return GW.globalSettings:GetCurrentProfile() == profileName end,
                        function()
                            GW.globalSettings:SetProfile(profileName)
                            UpdateCurrentLabel()
                            step.applied = true
                            step.summaryDetail = profileName
                        end)
                end
            end)

            local newButton = CreateActionButton(content, 220)
            newButton:SetPoint("TOP", dropdown, "BOTTOM", 0, -12)
            newButton:SetText(L["Create a profile for this character"])
            newButton:SetScript("OnClick", function()
                GW.globalSettings:SetProfile(UnitName("player") .. " - " .. GetRealmName())
                UpdateCurrentLabel()
                dropdown:GenerateMenu()
                step.applied = true
                step.summaryDetail = GW.globalSettings:GetCurrentProfile()
            end)

            -- most common case for alts: same settings as the current profile, but
            -- independent from now on
            local copyButton = CreateActionButton(content, 220)
            copyButton:SetPoint("TOP", newButton, "BOTTOM", 0, -8)
            copyButton:SetText(L["Copy the current profile for this character"])
            copyButton:SetScript("OnClick", function()
                local oldProfile = GW.globalSettings:GetCurrentProfile()
                local newProfile = UnitName("player") .. " - " .. GetRealmName()
                if newProfile == oldProfile then
                    newProfile = format("%s (%s)", newProfile, CALENDAR_COPY_EVENT)
                end
                GW.globalSettings:SetProfile(newProfile)
                GW.globalSettings:CopyProfile(oldProfile, true)
                UpdateCurrentLabel()
                dropdown:GenerateMenu()
                step.applied = true
                step.summaryDetail = newProfile
            end)
        end,
        onNext = function(_, step)
            if not step.summaryDetail then
                step.summaryDetail = GW.globalSettings:GetCurrentProfile()
            end
        end,
    },
    {
        title = L["Installation Complete"],
        desc = L["You have now finished installing GW2 UI!"],
        applyText = RELOADUI,
        apply = function() C_UI.Reload() end,
        isFinal = true,
        spotlight = "screen",
        buildContent = function(content)
            local previous
            local delay = 0.2
            for _, step in ipairs(STEPS) do
                if not step.isFinal then
                    local text = content:CreateFontString(nil, "OVERLAY")
                    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
                    text:SetJustifyH("LEFT")
                    text:SetWidth(320)
                    if previous then
                        text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
                    else
                        text:SetPoint("TOPLEFT", content, "TOPLEFT", 90, -8)
                    end

                    if step.applied then
                        local detail = step.summaryDetail and format(" |cff888888%s|r", step.summaryDetail) or ""
                        text:SetTextColor(0.9, 0.85, 0.7)
                        text:SetFormattedText("|TInterface/RaidFrame/ReadyCheck-Ready:14|t %s%s", step.title, detail)
                    else
                        text:SetTextColor(0.5, 0.47, 0.42)
                        text:SetFormattedText("|TInterface/RaidFrame/ReadyCheck-NotReady:14|t %s |cff888888%s|r", step.title, L["Skipped"])
                    end

                    if step.summaryTooltip then
                        local line = CreateFrame("Frame", nil, content)
                        line:SetAllPoints(text)
                        line:EnableMouse(true)
                        line:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(step.title, 1, 1, 1)
                            GameTooltip:AddLine(table.concat(step.summaryTooltip, ", "), 0.9, 0.85, 0.7, true)
                            GameTooltip:Show()
                        end)
                        line:SetScript("OnLeave", GameTooltip_Hide)
                    end
                    previous = text
                    PlayFadeIn(text, delay)
                    delay = delay + 0.12
                end
            end

            local tip = content:CreateFontString(nil, "OVERLAY")
            tip:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            tip:SetTextColor(0.62, 0.58, 0.5)
            tip:SetPoint("BOTTOM", content, "BOTTOM", 0, 4)
            tip:SetText(L["Type /gw2 settings to open the settings at any time."])
            PlayFadeIn(tip, delay + 0.2)
        end,
    },
})

-- ============================
-- Spotlight: the screen is dimmed except the frame a step is about
-- ============================
local WINDOW_WIDTH, WINDOW_HEIGHT, RAIL_WIDTH = 780, 500, 190
local SPOT_PADDING, SPOT_DURATION = 8, 0.45

-- the window sits on whole pixels, a half pixel makes its texts blurry
local function SnapToPixel(value)
    local pixel = 768 / select(2, GetPhysicalScreenSize()) / wpanel:GetEffectiveScale()
    return math.floor(value / pixel + 0.5) * pixel
end

-- four dim textures frame the hole; hole and window glide to their targets
local function UpdateSpotlight(self, elapsed)
    local spot = self.spot
    spot.time = math.min(spot.time + elapsed, SPOT_DURATION)
    local t = spot.time / SPOT_DURATION
    t = t * t * (3 - 2 * t)
    for i = 1, 6 do
        spot.current[i] = spot.from[i] + (spot.to[i] - spot.from[i]) * t
    end

    local left, bottom, width, height, windowLeft, windowBottom = unpack(spot.current)
    local screenWidth, screenHeight = self:GetSize()
    self.dimTop:SetHeight(math.max(screenHeight - bottom - height, 0.01))
    self.dimBottom:SetHeight(math.max(bottom, 0.01))
    self.dimLeft:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, bottom)
    self.dimLeft:SetSize(math.max(left, 0.01), math.max(height, 0.01))
    self.dimRight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, bottom)
    self.dimRight:SetSize(math.max(screenWidth - left - width, 0.01), math.max(height, 0.01))
    self.ring:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", left, bottom)
    self.ring:SetSize(math.max(width, 0.01), math.max(height, 0.01))
    self.window:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", SnapToPixel(windowLeft), SnapToPixel(windowBottom))

    if spot.time >= SPOT_DURATION then
        self:SetScript("OnUpdate", nil)
    end
end

-- target: a frame, "screen" for no dimming or nil for a fully dimmed screen; windowAt "TOPRIGHT" or "TOPLEFT" moves the window
-- out of the way of frames a step shows. instant only skips the dimming animation, the window always glides
function SetSpotlight(target, instant, windowAt)
    local spot = wpanel.spot
    local width, height = wpanel:GetSize()
    local windowLeft, windowBottom = (width - WINDOW_WIDTH) / 2, (height - WINDOW_HEIGHT) / 2
    if windowAt == "TOPRIGHT" then
        windowLeft, windowBottom = math.max(width - WINDOW_WIDTH - 20, 20), math.max(height - WINDOW_HEIGHT - 20, 20)
    elseif windowAt == "TOPLEFT" then
        windowLeft, windowBottom = 20, math.max(height - WINDOW_HEIGHT - 20, 20)
    end
    local isFrame = type(target) == "table" and target:IsVisible() and target:GetRect() ~= nil
    local to
    if isFrame then
        local scale = target:GetEffectiveScale() / wpanel:GetEffectiveScale()
        local left, bottom, frameWidth, frameHeight = target:GetRect()
        left, bottom = left * scale - SPOT_PADDING, bottom * scale - SPOT_PADDING
        frameWidth, frameHeight = frameWidth * scale + SPOT_PADDING * 2, frameHeight * scale + SPOT_PADDING * 2
        -- the window sits next to the lit frame, bottoms aligned, and stays on the screen
        if left + frameWidth / 2 < width / 2 then
            windowLeft = left + frameWidth + 40
        else
            windowLeft = left - 40 - WINDOW_WIDTH
        end
        windowLeft = math.min(math.max(windowLeft, 20), math.max(width - WINDOW_WIDTH - 20, 20))
        windowBottom = math.min(math.max(bottom, 20), math.max(height - WINDOW_HEIGHT - 20, 20))
        to = {left, bottom, frameWidth, frameHeight, windowLeft, windowBottom}
    elseif target == "screen" then
        to = {0, 0, width, height, windowLeft, windowBottom}
    else
        to = {width / 2, height / 2, 0, 0, windowLeft, windowBottom}
    end

    spot.target, spot.windowAt = target, windowAt
    spot.from = CopyTable(spot.current)
    spot.to = to
    spot.time = 0
    if instant then
        for i = 1, 4 do
            spot.from[i] = to[i]
        end
    end
    wpanel.ring:SetShown(isFrame)
    wpanel:SetScript("OnUpdate", UpdateSpotlight)
    if instant then
        UpdateSpotlight(wpanel, 0)
    end
end

-- an accent frame that breathes
local function CreateRing()
    local ring = CreateFrame("Frame", nil, wpanel)
    ring:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
    ring.backdrop:SetBackdropBorderColor(GW.Colors.AccentLight:GetRGB())
    ring:Hide()
    local pulse = ring:CreateAnimationGroup()
    pulse:SetLooping("BOUNCE")
    local fade = pulse:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0.35)
    fade:SetDuration(1.2)
    fade:SetSmoothing("IN_OUT")
    pulse:Play()
    return ring
end

-- the rect of a frame or of a list of frames in screen units, with the padding of the spotlight
local function GetHighlightRect(target)
    local left, bottom, right, top
    -- pairs: a frame that does not exist leaves a hole in the list
    for _, frame in pairs(target.GetRect and {target} or target) do
        local frameLeft, frameBottom, width, height = frame:GetRect()
        -- secure aura containers have secret sizes, their mover has the same rect
        if GW.IsSecretValue(width) and frame.gwMover then
            frameLeft, frameBottom, width, height = frame.gwMover:GetRect()
        end
        if frame:IsVisible() and frame:GetEffectiveAlpha() > 0 and frameLeft and not GW.IsSecretValue(width) and width > 1 and height > 1 then
            local scale = frame:GetEffectiveScale() / wpanel:GetEffectiveScale()
            frameLeft, frameBottom = frameLeft * scale, frameBottom * scale
            local frameRight, frameTop = frameLeft + width * scale, frameBottom + height * scale
            left, bottom = math.min(left or frameLeft, frameLeft), math.min(bottom or frameBottom, frameBottom)
            right, top = math.max(right or frameRight, frameRight), math.max(top or frameTop, frameTop)
        end
    end
    if left then
        return {left = left - SPOT_PADDING, bottom = bottom - SPOT_PADDING, right = right + SPOT_PADDING, top = top + SPOT_PADDING}
    end
end

-- dims all but the rects: the screen is cut into bands at the rect edges, in each band the gaps get a texture.
-- All edges sit on whole pixels, two textures meeting on a half pixel leave a bright line
local function DimAround(rects)
    wpanel.holeDims = wpanel.holeDims or {}
    local used = 0
    local function Dim(left, bottom, right, top)
        if right - left < 0.5 or top - bottom < 0.5 then return end
        used = used + 1
        local dim = wpanel.holeDims[used]
        if not dim then
            dim = wpanel:CreateTexture(nil, "BACKGROUND")
            dim:SetColorTexture(0, 0, 0, 0.78)
            wpanel.holeDims[used] = dim
        end
        dim:ClearAllPoints()
        dim:SetPoint("BOTTOMLEFT", wpanel, "BOTTOMLEFT", left, bottom)
        dim:SetSize(right - left, top - bottom)
        dim:Show()
    end

    if rects then
        local width, height = wpanel:GetSize()
        local snapped, edges = {}, {0, SnapToPixel(height)}
        for _, rect in pairs(rects) do
            local bottom = SnapToPixel(math.min(math.max(rect.bottom, 0), height))
            local top = SnapToPixel(math.min(math.max(rect.top, 0), height))
            tinsert(snapped, {left = SnapToPixel(rect.left), right = SnapToPixel(rect.right), bottom = bottom, top = top})
            tinsert(edges, bottom)
            tinsert(edges, top)
        end
        sort(edges)
        for i = 1, #edges - 1 do
            local bandBottom, bandTop = edges[i], edges[i + 1]
            if bandTop > bandBottom then
                local middle = (bandBottom + bandTop) / 2
                local spans = {}
                for _, rect in ipairs(snapped) do
                    if rect.bottom < middle and rect.top > middle then
                        tinsert(spans, rect)
                    end
                end
                sort(spans, function(a, b) return a.left < b.left end)
                local x = 0
                for _, rect in ipairs(spans) do
                    Dim(x, bandBottom, rect.left, bandTop)
                    x = math.max(x, rect.right)
                end
                Dim(x, bandBottom, SnapToPixel(width), bandTop)
            end
        end
    end
    for i = used + 1, #wpanel.holeDims do
        wpanel.holeDims[i]:Hide()
    end
end

-- rects by the key of their target, a ring each
local function LayoutHighlights(rects)
    wpanel.rings = wpanel.rings or {}
    for key, ring in pairs(wpanel.rings) do
        ring:SetShown(rects ~= nil and rects[key] ~= nil)
    end
    for key, rect in pairs(rects or {}) do
        local ring = wpanel.rings[key] or CreateRing()
        wpanel.rings[key] = ring
        ring:ClearAllPoints()
        ring:SetPoint("BOTTOMLEFT", wpanel, "BOTTOMLEFT", rect.left, rect.bottom)
        ring:SetSize(math.max(rect.right - rect.left, 0.01), math.max(rect.top - rect.bottom, 0.01))
        ring:SetShown(rect.right - rect.left > 2 and rect.top - rect.bottom > 2)
    end
    DimAround(rects)
end

-- the lit areas grow out of their middle like the spotlight
local function UpdateHighlights(self, elapsed)
    local anim = self.anim
    anim.time = math.min(anim.time + elapsed, SPOT_DURATION)
    local t = anim.time / SPOT_DURATION
    t = t * t * (3 - 2 * t)
    local rects = {}
    for key, to in pairs(anim.to) do
        local from = anim.from[key]
        rects[key] = {
            left = from.left + (to.left - from.left) * t,
            bottom = from.bottom + (to.bottom - from.bottom) * t,
            right = from.right + (to.right - from.right) * t,
            top = from.top + (to.top - from.top) * t,
        }
    end
    if anim.time >= SPOT_DURATION then
        self:SetScript("OnUpdate", nil)
        -- closed areas are done
        for key in pairs(anim.closing) do
            rects[key] = nil
        end
    end
    wpanel.highlightCurrent = rects
    LayoutHighlights(rects)
end

local function CenterOf(rect)
    local x, y = (rect.left + rect.right) / 2, (rect.bottom + rect.top) / 2
    return {left = x, right = x, bottom = y, top = y}
end

-- several frames lit at once with a ring each, the rest of the screen dimmed; a list of frames counts as one area.
-- retarget only moves the goals of a running animation, frames that show up late join it without a restart
function SetHighlights(targets, retarget)
    wpanel.highlightTargets = targets
    local driver = wpanel.highlightDriver
    if not driver then
        driver = CreateFrame("Frame", nil, wpanel)
        wpanel.highlightDriver = driver
    end
    if not targets then
        driver:SetScript("OnUpdate", nil)
        driver.anim = nil
        wpanel.highlightCurrent = nil
        LayoutHighlights(nil)
        return
    end

    local to = {}
    for key, target in pairs(targets) do
        to[key] = GetHighlightRect(target)
    end
    local anim = driver.anim
    if retarget and anim and anim.time < SPOT_DURATION then
        for key, rect in pairs(to) do
            anim.from[key] = anim.from[key] or CenterOf(rect)
        end
        anim.to = to
        return
    end

    local from, closing = {}, {}
    for key, rect in pairs(to) do
        from[key] = wpanel.highlightCurrent and wpanel.highlightCurrent[key] or CenterOf(rect)
    end
    -- an area that is no longer wanted closes into its middle
    for key, rect in pairs(wpanel.highlightCurrent or {}) do
        if not to[key] then
            from[key], to[key], closing[key] = rect, CenterOf(rect), true
        end
    end
    driver.anim = {from = from, to = to, time = 0, closing = closing}
    driver:SetScript("OnUpdate", UpdateHighlights)
    -- right away, the dark screen of the spotlight is already gone
    UpdateHighlights(driver, 0)
end

local function CreateSpotlight()
    wpanel.spot = {time = 0}

    for _, key in ipairs({"dimTop", "dimBottom", "dimLeft", "dimRight"}) do
        local dim = wpanel:CreateTexture(nil, "BACKGROUND")
        dim:SetColorTexture(0, 0, 0, 0.78)
        wpanel[key] = dim
    end
    wpanel.dimTop:SetPoint("TOPLEFT")
    wpanel.dimTop:SetPoint("TOPRIGHT")
    wpanel.dimBottom:SetPoint("BOTTOMLEFT")
    wpanel.dimBottom:SetPoint("BOTTOMRIGHT")

    wpanel.ring = CreateRing()

    local width, height = wpanel:GetSize()
    wpanel.spot.current = {width / 2, height / 2, 0, 0, (width - WINDOW_WIDTH) / 2, (height - WINDOW_HEIGHT) / 2}
    wpanel.window:SetPoint("BOTTOMLEFT", wpanel, "BOTTOMLEFT", SnapToPixel(wpanel.spot.current[5]), SnapToPixel(wpanel.spot.current[6]))
    -- the scale preview of the display step resizes the screen
    wpanel:SetScript("OnSizeChanged", function()
        SetSpotlight(wpanel.spot.target, true, wpanel.spot.windowAt)
        SetHighlights(wpanel.highlightTargets)
    end)
end

-- ============================
-- Step engine
-- ============================
local function UpdateRail(index)
    for i, row in ipairs(installFrame.rows) do
        local step = STEPS[i]
        row.accent:SetShown(i == index)
        row.highlight:SetShown(i == index)
        if i == index then
            row.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            row.number:SetText(i)
        elseif step.applied then
            row.text:SetTextColor(0.72, 0.82, 0.6)
            row.number:SetText("|TInterface/RaidFrame/ReadyCheck-Ready:14|t")
        elseif i < index then
            row.text:SetTextColor(0.5, 0.47, 0.42)
            row.number:SetText(i)
        else
            row.text:SetTextColor(0.62, 0.58, 0.5)
            row.number:SetText(i)
        end
        row.number:SetTextColor(row.text:GetTextColor())
    end
end

-- a step can show frames while it is open (onEnter) and has to put them away again (onLeave)
local function LeaveStep()
    local step = installFrame.currentStep
    installFrame.currentStep = nil
    if step and step.onLeave then
        step.onLeave()
    end
    if step and step.highlights then
        SetHighlights(nil)
        -- the next step opens its spotlight from a dark screen
        SetSpotlight(nil, true)
    end
end

local function RenderStep(index)
    local step = STEPS[index]
    local install = installFrame

    LeaveStep()
    install.currentStep = step
    if step.onEnter then
        step.onEnter()
    end

    install.title:SetText(step.title)
    install.desc:SetText(step.desc)
    UpdateRail(index)
    SetSpotlight(type(step.spotlight) == "function" and step.spotlight() or step.spotlight, step.highlights ~= nil, step.windowAt)
    if step.highlights then
        -- the config mode of the group frames shows its frames a moment later
        SetHighlights(step.highlights())
        C_Timer.After(0.2, function()
            if install.currentStep == step then
                SetHighlights(step.highlights(), true)
            end
        end)
    end

    -- content area is rebuilt per step (steps are visited rarely, no pooling needed)
    if install.content then
        install.content:Hide()
        install.content:SetParent(nil)
    end
    -- below the description on a whole pixel, the texts of the content would blur otherwise
    local top = 28 + install.title:GetStringHeight() + 10 + install.desc:GetStringHeight() + 16
    install.content = CreateFrame("Frame", nil, install)
    install.content:SetPoint("TOP", install.main, "TOPLEFT", (WINDOW_WIDTH - RAIL_WIDTH) / 2, -SnapToPixel(top))
    install.content:SetPoint("BOTTOM", install.next, "TOP", 0, 12)
    install.content:SetWidth(470)
    if step.buildContent then
        step.buildContent(install.content, step)
    end
    -- the finale brings its lines in one by one itself
    if not step.isFinal then
        PlayFadeIn(install.content)
    end
    PlayFadeIn(install.title)
    PlayFadeIn(install.desc, 0.05)

    -- the action replaces next, the finale lets it glow
    install.action:SetShown(step.applyText ~= nil)
    install.glow:SetShown(step.isFinal == true)
    if step.applyText then
        install.action:SetText(step.applyText)
        install.action:SetScript("OnClick", function()
            step.summaryDetail = step.apply()
            step.applied = true
            if not step.isFinal then
                RenderStep(index + 1)
            end
        end)
    end

    install.back:SetShown(index > 1 and not step.isFinal)
    install.skip:SetShown(not step.isFinal)
    install.next:SetShown(not step.isFinal and not step.applyText)
    install.skip:SetPoint("BOTTOMRIGHT", step.applyText and install.action or install.next, "BOTTOMLEFT", -8, 0)

    install.back:SetScript("OnClick", function()
        if step.onSkip then step.onSkip(install.content) end
        RenderStep(index - 1)
    end)
    install.skip:SetScript("OnClick", function()
        if step.onSkip then step.onSkip(install.content) end
        RenderStep(index + 1)
    end)
    install.next:SetScript("OnClick", function()
        if step.onNext then step.onNext(install.content, step) end
        step.applied = true
        RenderStep(index + 1)
    end)
end

local function CreateInstallFrame()
    local window = wpanel.window
    installFrame = CreateFrame("Frame", nil, window)
    installFrame:SetAllPoints(window)
    installFrame:Hide()

    -- left rail: brand on top, one row per step
    local rail = CreateFrame("Frame", nil, installFrame)
    rail:SetPoint("TOPLEFT")
    rail:SetPoint("BOTTOMLEFT")
    rail:SetWidth(RAIL_WIDTH)
    local railBg = rail:CreateTexture(nil, "BACKGROUND", nil, 1)
    railBg:SetAllPoints()
    railBg:SetColorTexture(0, 0, 0, 0.35)
    local railLine = rail:CreateTexture(nil, "BORDER")
    railLine:SetPoint("TOPRIGHT")
    railLine:SetPoint("BOTTOMRIGHT")
    railLine:SetWidth(1)
    railLine:SetColorTexture(GW.Colors.AccentLight:GetRGB())
    railLine:SetAlpha(0.25)

    local brand = GW.CreateBrandLogo(rail, 36)
    brand:SetPoint("CENTER", rail, "TOPLEFT", 36, -36)
    local brandText = rail:CreateFontString(nil, "OVERLAY")
    brandText:SetFont("Interface/AddOns/GW2_UI/Fonts/menomonia.ttf", 22)
    brandText:SetText("|cffffffffGW2|r " .. GW.Colors.TextColors.LightHeader:WrapTextInColorCode("UI"))
    brandText:SetPoint("LEFT", brand, "RIGHT", 8, 4)
    local version = rail:CreateFontString(nil, "OVERLAY")
    version:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
    version:SetTextColor(0.62, 0.58, 0.5)
    version:SetPoint("TOPLEFT", brandText, "BOTTOMLEFT", 0, -2)
    version:SetText(GW.GetVersionString())

    installFrame.rows = {}
    for i, step in ipairs(STEPS) do
        local row = CreateFrame("Frame", nil, rail)
        row:SetSize(RAIL_WIDTH - 1, 30)
        row:SetPoint("TOPLEFT", rail, "TOPLEFT", 0, -78 - (i - 1) * 32)
        row.highlight = row:CreateTexture(nil, "BACKGROUND", nil, 2)
        row.highlight:SetAllPoints()
        row.highlight:SetColorTexture(GW.Colors.Accent.r, GW.Colors.Accent.g, GW.Colors.Accent.b, 0.18)
        row.accent = row:CreateTexture(nil, "ARTWORK")
        row.accent:SetPoint("TOPLEFT")
        row.accent:SetPoint("BOTTOMLEFT")
        row.accent:SetWidth(3)
        row.accent:SetColorTexture(GW.Colors.Accent:GetRGB())
        row.number = row:CreateFontString(nil, "OVERLAY")
        row.number:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        row.number:SetPoint("CENTER", row, "LEFT", 22, 0)
        row.text = row:CreateFontString(nil, "OVERLAY")
        row.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        row.text:SetPoint("LEFT", row, "LEFT", 40, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)
        row.text:SetText(step.title)
        installFrame.rows[i] = row
    end

    -- main area: accent title, description, content, buttons
    local main = CreateFrame("Frame", nil, installFrame)
    main:SetPoint("TOPLEFT", RAIL_WIDTH, 0)
    main:SetPoint("BOTTOMRIGHT")
    installFrame.main = main

    installFrame.title = main:CreateFontString(nil, "OVERLAY")
    installFrame.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 8)
    installFrame.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    installFrame.title:SetPoint("TOPLEFT", main, "TOPLEFT", 32, -28)
    local titleAccent = main:CreateTexture(nil, "ARTWORK")
    titleAccent:SetColorTexture(GW.Colors.Accent:GetRGB())
    titleAccent:SetSize(3, 22)
    titleAccent:SetPoint("RIGHT", installFrame.title, "LEFT", -10, 0)

    installFrame.desc = main:CreateFontString(nil, "OVERLAY")
    installFrame.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    installFrame.desc:SetTextColor(0.9, 0.85, 0.7)
    installFrame.desc:SetPoint("TOPLEFT", installFrame.title, "BOTTOMLEFT", 0, -10)
    installFrame.desc:SetWidth(WINDOW_WIDTH - RAIL_WIDTH - 64)
    installFrame.desc:SetJustifyH("LEFT")

    installFrame.next = CreateActionButton(main, 150)
    installFrame.next:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -24, 18)
    installFrame.next:SetText(NEXT)

    installFrame.action = CreateActionButton(main, 200)
    installFrame.action:SetPoint("BOTTOMRIGHT", installFrame.next)

    -- the finale lets its button glow
    local glow = main:CreateTexture(nil, "BACKGROUND", nil, 3)
    glow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/glow.png")
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(GW.Colors.AccentLight:GetRGB())
    glow:SetPoint("TOPLEFT", installFrame.action, "TOPLEFT", -40, 30)
    glow:SetPoint("BOTTOMRIGHT", installFrame.action, "BOTTOMRIGHT", 40, -30)
    local glowPulse = glow:CreateAnimationGroup()
    glowPulse:SetLooping("BOUNCE")
    local glowFade = glowPulse:CreateAnimation("Alpha")
    glowFade:SetFromAlpha(0.9)
    glowFade:SetToAlpha(0.3)
    glowFade:SetDuration(1)
    glowFade:SetSmoothing("IN_OUT")
    glow:SetScript("OnShow", function() glowPulse:Play() end)
    glow:SetScript("OnHide", function() glowPulse:Stop() end)
    installFrame.glow = glow

    installFrame.skip = CreateActionButton(main, 110)
    installFrame.skip:SetText(L["Skip"])

    installFrame.back = CreateActionButton(main, 110)
    installFrame.back:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 24, 18)
    installFrame.back:SetText(BACK)
end

-- ============================
-- Landing page + panel setup
-- ============================
local landingFrame

local function StartInstall()
    for _, step in ipairs(STEPS) do
        step.applied = nil
        step.summaryDetail = nil
        step.summaryTooltip = nil
    end
    landingFrame:Hide()
    installFrame:Show()
    RenderStep(1)
end

local function CreateLandingFrame()
    local window = wpanel.window
    landingFrame = CreateFrame("Frame", nil, window)
    landingFrame:SetAllPoints(window)

    -- the artwork of the client, darkened to the right for the text
    local art = landingFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    art:SetTexture((GW.GetSettingsSplashArt()))
    art:SetTexCoord(0, 0.75, 0.02, 0.98)
    art:SetAllPoints()
    local shade = landingFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
    shade:SetColorTexture(1, 1, 1, 1)
    shade:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0.15), CreateColor(0, 0, 0, 0.92))
    shade:SetAllPoints()
    local bottomShade = landingFrame:CreateTexture(nil, "BACKGROUND", nil, 3)
    bottomShade:SetColorTexture(1, 1, 1, 1)
    bottomShade:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.85), CreateColor(0, 0, 0, 0))
    bottomShade:SetPoint("BOTTOMLEFT")
    bottomShade:SetPoint("BOTTOMRIGHT")
    bottomShade:SetHeight(140)

    -- the own character, slowly turning a bit to each side
    local model = CreateFrame("PlayerModel", nil, landingFrame)
    model:SetPoint("BOTTOMLEFT", landingFrame, "BOTTOMLEFT", 30, 10)
    model:SetSize(300, 440)
    local swayTime = 0
    model:SetScript("OnShow", function(self)
        self:SetUnit("player")
        self:SetPortraitZoom(0)
    end)
    model:SetScript("OnUpdate", function(self, elapsed)
        swayTime = swayTime + elapsed
        self:SetFacing(0.45 * math.sin(swayTime * 0.4))
    end)
    landingFrame.model = model

    local column = CreateFrame("Frame", nil, landingFrame)
    column:SetPoint("TOPLEFT", landingFrame, "TOPLEFT", 380, -60)
    column:SetPoint("BOTTOMRIGHT", landingFrame, "BOTTOMRIGHT", -40, 0)

    local brand = GW.CreateBrandLogo(column, 56)
    brand:SetPoint("TOPLEFT", column, "TOPLEFT", 0, 0)

    local welcome = column:CreateFontString(nil, "OVERLAY")
    welcome:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    welcome:SetTextColor(GW.Colors.AccentLight:GetRGB())
    welcome:SetPoint("TOPLEFT", brand, "BOTTOMLEFT", 0, -22)
    welcome:SetText(L["Welcome to GW2 UI"])

    local name = column:CreateFontString(nil, "OVERLAY")
    name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 18)
    name:SetPoint("TOPLEFT", welcome, "BOTTOMLEFT", 0, -6)
    if GW.Forever then
        local firstName, lastName = UnitName("player")
        name:SetText(firstName .. " " .. lastName)
    else
        name:SetText(GW.myname)
    end
    local classColor = GW.GWGetClassColor(select(2, UnitClass("player")), true, true)
    name:SetTextColor(classColor.r, classColor.g, classColor.b)

    local version = column:CreateFontString(nil, "OVERLAY")
    version:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    version:SetTextColor(0.62, 0.58, 0.5)
    version:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    version:SetText(GW.GetVersionString())

    local intro = column:CreateFontString(nil, "OVERLAY")
    intro:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    intro:SetTextColor(0.9, 0.85, 0.7)
    intro:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -18)
    intro:SetWidth(340)
    intro:SetJustifyH("LEFT")
    intro:SetText(L["Your interface is ready in a few steps. Everything can be changed later in the settings."])

    -- the buttons hang from the bottom, below a text of any height they would sit on half pixels
    local start = CreateActionButton(column, 240)
    start:SetHeight(32)
    start:SetPoint("BOTTOMLEFT", column, "BOTTOMLEFT", 0, 120)
    start:SetText(L["Start installation"])
    start:SetScript("OnClick", StartInstall)

    local express = CreateTextLink(column, L["Apply recommended settings"], ApplyExpressInstall)
    express.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    express:SetSize(express.text:GetStringWidth() + 4, 20)
    express:SetPoint("TOPLEFT", start, "BOTTOMLEFT", 0, -10)

    local settings = CreateActionButton(landingFrame, 110)
    settings:SetHeight(24)
    settings:SetPoint("BOTTOMRIGHT", landingFrame, "BOTTOMRIGHT", -136, 16)
    settings:SetText(CHAT_CONFIGURATION)
    settings.target = GwSettingsWindow
    settings:SetScript("OnClick", settings_OnClick)

    local close = CreateActionButton(landingFrame, 110)
    close:SetHeight(24)
    close:SetPoint("BOTTOMRIGHT", landingFrame, "BOTTOMRIGHT", -18, 16)
    close:SetText(CLOSE)
    close:SetScript("OnClick", function() wpanel:Hide() end)

    landingFrame.reveal = {welcome, name, version, intro, start, express}
end

local function createPanel()
    -- the whole screen: dimming, spotlight and the window on top
    wpanel = CreateFrame("Frame", "GwWelcomePage", UIParent)
    wpanel:SetAllPoints(UIParent)
    -- above the bags and hero window it opens as previews, those stay below the dimming
    wpanel:SetFrameStrata("DIALOG")
    wpanel:SetToplevel(true)
    wpanel:EnableMouse(true)
    wpanel:Hide()

    -- escape closes the window. NOT via UISpecialFrames: the chat setup activates an
    -- edit mode layout, and the edit mode closes all special frames - the installer
    -- would vanish mid step
    wpanel:EnableKeyboard(true)
    wpanel:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    wpanel:SetScript("OnHide", function()
        LeaveStep()
        PlaySoundFile("Interface/AddOns/GW2_UI/Sounds/dialog_close.ogg", "SFX")
    end)

    local window = CreateFrame("Frame", nil, wpanel)
    window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:EnableMouse(true)
    local background = window:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/settingspanelbg.png")
    background:SetTexCoord(0, WINDOW_WIDTH / 853, 0, WINDOW_HEIGHT / 853)
    background:SetAllPoints()

    -- the window comes in a little smaller and grows to its size
    local enter = window:CreateAnimationGroup()
    local grow = enter:CreateAnimation("Scale")
    grow:SetScaleFrom(0.94, 0.94)
    grow:SetScaleTo(1, 1)
    grow:SetDuration(0.4)
    grow:SetSmoothing("OUT")
    local fade = enter:CreateAnimation("Alpha")
    fade:SetFromAlpha(0)
    fade:SetToAlpha(1)
    fade:SetDuration(0.4)
    window.enter = enter
    wpanel.window = window

    CreateSpotlight()
    CreateInstallFrame()
    CreateLandingFrame()
end

local function ShowWelcomePanel()
    if not wpanel then
        createPanel()
    end
    LeaveStep()
    installFrame:Hide()
    landingFrame:Show()

    wpanel:Show()
    SetSpotlight(nil)
    UIFrameFadeIn(wpanel, 0.5, 0, 1)
    wpanel.window.enter:Play()
    for index, region in ipairs(landingFrame.reveal) do
        PlayFadeIn(region, 0.25 + index * 0.1)
    end
    PlaySoundFile("Interface/AddOns/GW2_UI/Sounds/dialog_open.ogg", "SFX")
end
GW.ShowWelcomePanel = ShowWelcomePanel
