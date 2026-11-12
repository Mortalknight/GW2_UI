---@class GW2
local GW = select(2, ...)
local L = GW.L
local GWGetClassColor = GW.GWGetClassColor
local lerp = GW.lerp

local AFKMode

-- a modifier alone does not end the AFK screen
local MODIFIER_KEYS = { LSHIFT = true, RSHIFT = true, LALT = true, RALT = true, LCTRL = true, RCTRL = true, LMETA = true, RMETA = true }

-- the character greets (wave), plays a few random emotes with idle pauses in
-- between and finally falls asleep; a key press restarts the cycle
local EMOTES_UNTIL_SLEEP = 6
local AFK_LOGOUT_TIME = 30 * 60 -- the server logs AFK players out after 30 minutes

local animations = {
    wave = { id = 67, facing = 6, wait = 5, offsetX = -200, offsetY = 220, duration = 2.3 },
    sleep = { id = 71, facing = 1, wait = 30, offsetX = -200, offsetY = 220, duration = 3000 }
}
local emotePool = {
    { id = 60, duration = 4 },  -- talk
    { id = 66, duration = 3 },  -- bow
    { id = 68, duration = 3 },  -- cheer
    { id = 69, duration = 14 }, -- dance
    { id = 70, duration = 3 },  -- laugh
    { id = 74, duration = 3 },  -- roar
    { id = 82, duration = 4 },  -- flex
}

local function CancelTimer(timer)
    if timer then
        timer:Cancel()
    end
    return nil
end

local function FormatMinutes(seconds)
    return format("%d:%02d", floor(seconds / 60), seconds % 60)
end

local function UpdateQueues(self)
    local lines = {}
    GW.ForEachGroupQueue(function(name, waited, estimated)
        local line = name .. "  " .. FormatMinutes(waited)
        if estimated and estimated > 0 then
            line = line .. "  " .. GW.Colors.SkinColors.SubText:WrapTextInColorCode("(~" .. FormatMinutes(estimated) .. ")")
        end
        tinsert(lines, line)
    end)
    self.queues:SetText(table.concat(lines, "\n"))
end

local function UpdateMessages(self)
    local text = self.whispers > 0 and format("%s: %d", WHISPER, self.whispers) or ""
    if HasNewMail and HasNewMail() then
        text = (text ~= "" and text .. "    " or "") .. HAVE_MAIL
    end
    self.bottom.messages:SetText(text)
end

local function UpdateTimer(self)
    local time = GetTime() - self.startTime
    self.bottom.time:SetFormattedText("%02d:%02d", floor(time / 60), time % 60)
    UpdateQueues(self)
    UpdateMessages(self)
end

local function GetCharacterLine()
    local line = format("%s %d %s", LEVEL, UnitLevel("player"), GW.myLocalizedClass)
    -- below level 10 the starter spec is named like the class
    if GW.myspecName and GW.myspecName ~= GW.myLocalizedClass then
        line = line .. " - " .. GW.myspecName
    end
    if GetAverageItemLevel then
        local _, itemLevel = GetAverageItemLevel()
        if itemLevel > 0 then
            line = line .. " - " .. format(ITEM_LEVEL, itemLevel)
        end
    end
    return line
end

-- the screen and the bottom band follow the ui scale and the resolution of the moment
local function UpdateLayout(self)
    self:SetScale(UIParent:GetScale())
    self.bottom:SetWidth(GetScreenWidth() + (GW.border * 2))
    self.bottom:SetHeight(GetScreenHeight() * (1.5 / 10))
    self.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)

    local b = self.bottom
    local _, captionSize = b.caption:GetFont()
    local _, timeSize = b.time:GetFont()
    local _, messagesSize = b.messages:GetFont()
    local columnHeight = captionSize + 4 + timeSize + 8 + b.logout:GetHeight() + 8 + messagesSize
    b.caption:SetPoint("TOP", b, "BOTTOM", 0, max(b.captionY, columnHeight + 15))
end

local LOGOUT_WARNING_TIME = 5 * 60
local AWAY_TEXT = FRIENDS_LIST_AWAY or AFK

local FACTION_LOGO = { size = 140, x = -20, y = -8, nameX = -10, nameY = -36 }
local NEUTRAL_LOGO = { texture = "Panda", size = 90, x = 15, y = 10, nameX = 20, nameY = -5 }

-- smooth fill with a spark on the edge; the color heats up from gold to red
-- over the last 10 minutes, the final 5 minutes pulse. Only runs while the
-- AFK screen is shown
local function LogoutBar_OnUpdate(bar, elapsed)
    bar.throttle = (bar.throttle or 0) + elapsed
    if bar.throttle < 0.05 or not AFKMode.startTime then return end
    bar.throttle = 0

    local afkTime = GetTime() - AFKMode.startTime
    local remaining = max(0, AFK_LOGOUT_TIME - afkTime)

    bar:SetValue(min(afkTime, AFK_LOGOUT_TIME))
    bar.spark:SetPoint("CENTER", bar, "LEFT", min(afkTime / AFK_LOGOUT_TIME, 1) * bar:GetWidth(), 0)

    local base, hot = GW.Colors.TextColors.LightHeader, GW.Colors.IndicatorColors.Red
    local heat = 1 - min(1, remaining / 600)
    local r, g, b = lerp(base.r, hot.r, heat), lerp(base.g, hot.g, heat), lerp(base.b, hot.b, heat)
    bar:SetStatusBarColor(r, g, b)
    bar.spark:SetVertexColor(r, g, b)

    -- the afk time already counts, the caption above it turns into the countdown only as the warning
    local caption = AFKMode.bottom.caption
    if remaining <= LOGOUT_WARNING_TIME then
        local pulse = 0.75 + 0.25 * math.cos(GetTime() * math.pi)
        caption:SetFormattedText("%s %s", LOGOUT, FormatMinutes(remaining))
        caption:SetTextColor(GW.Colors.IndicatorColors.Red:GetRGB())
        caption:SetAlpha(pulse)
        bar.spark:SetAlpha(pulse)
    else
        caption:SetText(AWAY_TEXT)
        caption:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
        caption:SetAlpha(1)
        bar.spark:SetAlpha(1)
    end
end

local function GetAnimation(key)
    if key then
        return animations[key], key
    end

    local model = AFKMode.bottom.model
    if model.curAnimation == "sleep" then
        return animations.wave, "wave"
    end
    if (model.emoteCount or 0) >= EMOTES_UNTIL_SLEEP then
        return animations.sleep, "sleep"
    end

    local pick
    repeat
        pick = emotePool[math.random(#emotePool)]
    until pick.id ~= model.lastEmoteId or #emotePool == 1
    model.lastEmoteId = pick.id

    return { id = pick.id, facing = 6, wait = math.random(15, 35), offsetX = -200, offsetY = 220, duration = pick.duration }, "emote"
end

local function SetAnimation(key)
    local options, usedKey = GetAnimation(key)

    local model = AFKMode.bottom.model
    if usedKey == "emote" then
        model.emoteCount = (model.emoteCount or 0) + 1
    else
        model.emoteCount = 0
    end
    model.curAnimation = usedKey
    model:SetFacing(options.facing)
    model:SetAnimation(options.id)

    -- after the animation the character stands idle until the next one
    AFKMode.animTimer = CancelTimer(AFKMode.animTimer)
    AFKMode.animTimer = C_Timer.NewTimer(options.duration, function()
        model:SetAnimation(0)
        AFKMode.animTimer = C_Timer.NewTimer(options.wait, function() SetAnimation() end)
    end)

    if AFKMode.bottom.modelHolder then
        AFKMode.bottom.modelHolder:ClearAllPoints()
        AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", AFKMode.bottom, options.offsetX, options.offsetY)
    end
end

local function ShowAFKScreen(self)
    -- the camera slowly circles the character while everything else is hidden
    MoveViewLeftStart(0.035)
    UpdateLayout(self)
    self:Show()
    CloseAllWindows()
    UIParent:Hide()

    local guildName, rankName = GetGuildInfo("player")
    if guildName then
        local guild = GW.Colors.TextColors.Guild
        self.bottom.guild:SetFormattedText("%s [%s]", guild:WrapTextInColorCode("<" .. guildName .. ">"), guild:WrapTextInColorCode(rankName))
    else
        self.bottom.guild:SetText(L["No Guild"])
    end

    self.bottom.info:SetText(GetCharacterLine())

    SetAnimation("wave")
    -- a key press only hides the screen, the server keeps counting while the player stays afk
    self.startTime = self.startTime or GetTime()
    self.bottom.logout:SetValue(0)
    self.timer = CancelTimer(self.timer)
    UpdateTimer(self)
    self.timer = C_Timer.NewTicker(1, function() UpdateTimer(self) end)
    self.isAFK = true
end

local function HideAFKScreen(self)
    UIParent:Show()
    self:Hide()
    MoveViewLeftStop()
    self.timer = CancelTimer(self.timer)
    self.animTimer = CancelTimer(self.animTimer)
    self.bottom.time:SetText("00:00")
    self.chat:Clear()
    self.chat:Hide()

    -- the group finder lays itself out wrong while UIParent was hidden, reopening fixes it
    if PVEFrame and PVEFrame:IsShown() then
        PVEFrame_ToggleFrame()
        PVEFrame_ToggleFrame()
    end
    self.isAFK = false
end

local function CheckAFK(self)
    local isAFK = GW.UnitIsAFK("player")
    if not isAFK then
        self.startTime = nil
        self.whispers = 0
    end
    if not GW.settings.general.afkMode or InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown() then
        return
    end
    -- crafting keeps the player busy, look again later
    if UnitCastingInfo("player") then
        C_Timer.After(30, function() CheckAFK(self) end)
        return
    end

    local inPetBattle = C_PetBattles and C_PetBattles.IsInBattle()
    if isAFK and not inPetBattle then
        if not self.isAFK then
            ShowAFKScreen(self)
        end
    elseif self.isAFK then
        HideAFKScreen(self)
    end
end

local function AFKMode_OnEvent(self, event, arg1)
    if event == "PLAYER_FLAGS_CHANGED" then
        if arg1 == "player" then
            CheckAFK(self)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- the flag may have changed while we were fighting
        self:UnregisterEvent(event)
        CheckAFK(self)
    elseif event ~= "UPDATE_BATTLEFIELD_STATUS" or GetBattlefieldStatus(arg1) == "confirm" then
        -- combat, a group or a battleground invite need the normal UI
        if self.isAFK then
            HideAFKScreen(self)
        end
        if event == "PLAYER_REGEN_DISABLED" then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
    end
end

local function OnKeyDown(self, key)
    if MODIFIER_KEYS[key] then return end

    -- follows the player's own screenshot binding
    if GetBindingFromClick(key) == "SCREENSHOT" then
        Screenshot()
    elseif self.isAFK then
        HideAFKScreen(self)
        -- still AFK a minute later brings the screen back
        if not self.recheckPending then
            self.recheckPending = true
            C_Timer.After(60, function()
                self.recheckPending = false
                CheckAFK(self)
            end)
        end
    end
end

local function Chat_OnMouseWheel(chat, delta)
    local up = delta > 0
    if IsShiftKeyDown() then
        if up then chat:ScrollToTop() else chat:ScrollToBottom() end
    elseif up then
        chat:ScrollUp()
    else
        chat:ScrollDown()
    end
end

-- whispers and guild chat, the way the chat windows show them; a line in several windows comes once
local AFK_CHAT_TYPES = {WHISPER = true, BN_WHISPER = true, GUILD = true}
local lastMirroredLine

local function MirrorChatLine(_, text, r, g, b, infoID)
    if GW.IsSecretValue(infoID) or not (AFKMode and AFKMode.isAFK) or text == lastMirroredLine then
        return
    end
    local chatType = infoID and C_ChatInfo.GetChatTypeName(infoID)
    if chatType and AFK_CHAT_TYPES[chatType] then
        lastMirroredLine = text
        AFKMode.chat:AddMessage(GW.Colors.SkinColors.SubText:WrapTextInColorCode(date("%H:%M")) .. " " .. text, r, g, b)
        AFKMode.chat:Show()
        if chatType ~= "GUILD" then
            AFKMode.whispers = AFKMode.whispers + 1
            UpdateMessages(AFKMode)
        end
    end
end

GW.RegisterChatModule({
    setting = function() return GW.settings.general.afkMode end,
    onLine = MirrorChatLine,
})

local function ToggelAfkMode()
    if not AFKMode then return end
    if GW.settings.general.afkMode then
        AFKMode:RegisterEvent("PLAYER_FLAGS_CHANGED")
        AFKMode:RegisterEvent("PLAYER_REGEN_DISABLED")
        AFKMode:RegisterEvent("LFG_PROPOSAL_SHOW")
        AFKMode:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        AFKMode:SetScript("OnEvent", AFKMode_OnEvent)
        C_CVar.SetCVar("autoClearAFK", "1")
    else
        AFKMode:UnregisterAllEvents()
        AFKMode:SetScript("OnEvent", nil)

        AFKMode.chat:Clear()
        AFKMode.timer = CancelTimer(AFKMode.timer)
        AFKMode.animTimer = CancelTimer(AFKMode.animTimer)
    end
end
GW.ToggelAfkMode = ToggelAfkMode

local function UpdateClasscolor()
    local classColor = GWGetClassColor(GW.myclass, true)
    AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)
end

local function LoadAFKAnimation()
    local classColor = GWGetClassColor(GW.myclass, true)
    local playerName = GW.myname

    local BackdropFrame = {
        bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/welcome-bg.png",
        edgeFile = "",
        tile = false,
        tileSize = 64,
        edgeSize = 32,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    }

    AFKMode = CreateFrame("Frame")
    AFKMode:SetFrameLevel(1)
    AFKMode:SetAllPoints(UIParent)
    AFKMode:Hide()
    AFKMode:EnableKeyboard(true)
    AFKMode:SetScript("OnKeyDown", OnKeyDown)

    AFKMode.whispers = 0

    -- only shows once a line came in, a short dark box instead of a big empty one
    AFKMode.chat = CreateFrame("ScrollingMessageFrame", nil, AFKMode)
    AFKMode.chat:Hide()
    AFKMode.chat:SetSize(460, 150)
    AFKMode.chat:SetPoint("TOPLEFT", AFKMode, "TOPLEFT", 14, -14)
    local chatBg = AFKMode.chat:CreateTexture(nil, "BACKGROUND")
    chatBg:SetPoint("TOPLEFT", -8, 8)
    chatBg:SetPoint("BOTTOMRIGHT", 8, -8)
    chatBg:SetColorTexture(GW.Colors.SkinColors.AfkShade:GetRGBA())
    AFKMode.chat:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    AFKMode.chat:SetJustifyH("LEFT")
    AFKMode.chat:SetMaxLines(100)
    AFKMode.chat:EnableMouseWheel(true)
    AFKMode.chat:SetFading(false)
    AFKMode.chat:SetMovable(true)
    AFKMode.chat:UnregisterAllEvents()
    AFKMode.chat:EnableMouse(true)
    AFKMode.chat:RegisterForDrag("LeftButton")
    AFKMode.chat:SetScript("OnDragStart", AFKMode.chat.StartMoving)
    AFKMode.chat:SetScript("OnDragStop", AFKMode.chat.StopMovingOrSizing)
    AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel)

    AFKMode.bottom = CreateFrame("Frame", nil, AFKMode, "BackdropTemplate")
    AFKMode.bottom:SetFrameLevel(0)
    AFKMode.bottom:SetPoint("BOTTOM", AFKMode, "BOTTOM", 0, -5)
    AFKMode.bottom:SetBackdrop(BackdropFrame)

    -- pandaren without a faction get the smaller panda logo, the name moves with it
    local logo = GW.myfaction == "Neutral" and NEUTRAL_LOGO or FACTION_LOGO
    AFKMode.bottom.faction = AFKMode.bottom:CreateTexture(nil, "OVERLAY")
    AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", AFKMode.bottom, "BOTTOMLEFT", logo.x, logo.y)
    AFKMode.bottom.faction:SetTexture("Interface/Timer/" .. (logo.texture or GW.myfaction) .. "-Logo")
    AFKMode.bottom.faction:SetSize(logo.size, logo.size)

    AFKMode.bottom.name = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    AFKMode.bottom.name:SetText(GW.Forever and GW.GetUnitDisplayName("player") or format("%s-%s", playerName, GW.myrealm))
    AFKMode.bottom.name:SetPoint("TOPLEFT", AFKMode.bottom.faction, "TOPRIGHT", logo.nameX, logo.nameY)
    AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)
    GW.Gw2ClassColorRegister(nil, UpdateClasscolor)

    AFKMode.bottom.info = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.info:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    AFKMode.bottom.info:SetPoint("TOPLEFT", AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
    AFKMode.bottom.info:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    AFKMode.bottom.guild = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.guild:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    AFKMode.bottom.guild:SetText(L["No Guild"])
    AFKMode.bottom.guild:SetPoint("TOPLEFT", AFKMode.bottom.info, "BOTTOMLEFT", 0, -6)
    AFKMode.bottom.guild:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())

    -- the status sits in the middle of the band, its top on the height of the name
    AFKMode.bottom.caption = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.caption:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    AFKMode.bottom.captionY = logo.y + logo.size + logo.nameY
    AFKMode.bottom.caption:SetText(AWAY_TEXT)
    AFKMode.bottom.caption:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())

    AFKMode.bottom.time = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.time:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 18)
    AFKMode.bottom.time:SetText("00:00")
    AFKMode.bottom.time:SetPoint("TOP", AFKMode.bottom.caption, "BOTTOM", 0, -4)
    AFKMode.bottom.time:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    -- countdown until the 30 minute server auto logout
    AFKMode.bottom.logout = CreateFrame("StatusBar", nil, AFKMode.bottom)
    AFKMode.bottom.logout:SetSize(280, 6)
    AFKMode.bottom.logout:SetPoint("TOP", AFKMode.bottom.time, "BOTTOM", 0, -8)
    AFKMode.bottom.logout:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    AFKMode.bottom.logout:SetStatusBarColor(GW.Colors.TextColors.LightHeader:GetRGB())
    AFKMode.bottom.logout:SetMinMaxValues(0, AFK_LOGOUT_TIME)
    AFKMode.bottom.logout:SetScript("OnUpdate", LogoutBar_OnUpdate)

    local logoutBg = AFKMode.bottom.logout:CreateTexture(nil, "BACKGROUND")
    logoutBg:SetAllPoints()
    logoutBg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    logoutBg:SetVertexColor(GW.Colors.SkinColors.AfkShade:GetRGBA())

    AFKMode.bottom.logout.spark = AFKMode.bottom.logout:CreateTexture(nil, "OVERLAY")
    AFKMode.bottom.logout.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark")
    AFKMode.bottom.logout.spark:SetBlendMode("ADD")
    AFKMode.bottom.logout.spark:SetSize(20, 26)
    AFKMode.bottom.logout.spark:SetPoint("CENTER", AFKMode.bottom.logout, "LEFT", 0, 0)

    AFKMode.bottom.messages = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.messages:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    AFKMode.bottom.messages:SetPoint("TOP", AFKMode.bottom.logout, "BOTTOM", 0, -8)
    AFKMode.bottom.messages:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    -- running dungeon finder and battleground queues, while waiting for them is a common time to be afk
    AFKMode.queues = AFKMode:CreateFontString(nil, "OVERLAY")
    AFKMode.queues:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    AFKMode.queues:SetPoint("TOPRIGHT", AFKMode, "TOPRIGHT", -20, -20)
    AFKMode.queues:SetJustifyH("RIGHT")
    AFKMode.queues:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    -- brand watermark, same subtle treatment as the settings window
    local watermark = AFKMode.bottom:CreateTexture(nil, "BACKGROUND", nil, 2)
    watermark:SetTexture("Interface/AddOns/GW2_UI/textures/gwlogo.png")
    watermark:SetSize(140, 140)
    watermark:SetPoint("BOTTOMRIGHT", AFKMode.bottom, "BOTTOMRIGHT", -24, 10)
    watermark:SetAlpha(0.08)

    --Use this frame to control position of the model
    AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, AFKMode.bottom)
    AFKMode.bottom.modelHolder:SetSize(150, 150)

    AFKMode.bottom.model = CreateFrame("PlayerModel", nil, AFKMode.bottom.modelHolder)
    AFKMode.bottom.model:SetPoint("CENTER", AFKMode.bottom.modelHolder, "CENTER")
    AFKMode.bottom.model:SetCamDistanceScale(4.5)
    AFKMode.bottom.model:SetUnit("player")

    ToggelAfkMode()
end
GW.LoadAFKAnimation = LoadAFKAnimation
