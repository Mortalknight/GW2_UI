---@class GW2
local GW = select(2, ...)
local L = GW.L
local GWGetClassColor = GW.GWGetClassColor
local IsIn = GW.IsIn
local lerp = GW.lerp

local GetChatCategory = ChatFrameUtil and ChatFrameUtil.GetChatCategory or Chat_GetChatCategory
local GetMobileEmbeddedTexture = (ChatFrameUtil and ChatFrameUtil.GetMobileEmbeddedTexture) or ChatFrame_GetMobileEmbeddedTexture
local FormatDiscordMessage = ChatFrameUtil and ChatFrameUtil.FormatDiscordMessage

local AFKMode

local ignoreKeys = {
    LALT = true,
    LSHIFT = true,
    RSHIFT = true,
}
local printKeys = {
    PRINTSCREEN = true,
}

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

local function UpdateTimer(self)
    local time = GetTime() - self.startTime
    self.bottom.time:SetFormattedText("%02d:%02d", floor(time / 60), time % 60)
end

local LOGOUT_WARNING_TIME = 5 * 60

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
    bar.text:SetFormattedText("%s %d:%02d", LOGOUT, floor(remaining / 60), remaining % 60)

    local base = GW.Colors.TextColors.LightHeader
    local heat = 1 - min(1, remaining / 600)
    local r, g, b = lerp(base.r, 0.9, heat), lerp(base.g, 0.15, heat), lerp(base.b, 0.15, heat)
    bar:SetStatusBarColor(r, g, b)
    bar.spark:SetVertexColor(r, g, b)

    if remaining <= LOGOUT_WARNING_TIME then
        local pulse = 0.75 + 0.25 * math.cos(GetTime() * math.pi)
        bar.text:SetTextColor(0.9, 0.15, 0.15)
        bar.text:SetAlpha(pulse)
        bar.spark:SetAlpha(pulse)
    else
        bar.text:SetTextColor(0.7, 0.7, 0.7)
        bar.text:SetAlpha(1)
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
    model.duration = options.duration
    model.idleDuration = options.wait
    model.startTime = GetTime()
    model.isIdle = nil

    model:SetFacing(options.facing)
    model:SetAnimation(options.id)

    if AFKMode.bottom.modelHolder then
        AFKMode.bottom.modelHolder:ClearAllPoints()
        AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", AFKMode.bottom, options.offsetX, options.offsetY)
    end
end

local function SetAFK(self, status)
    if status then
        MoveViewLeftStart(0.035)
        self:Show()
        CloseAllWindows()
        UIParent:Hide()

        if IsInGuild() then
            local guildName, guildRankName = GetGuildInfo("player")
            self.bottom.guild:SetFormattedText("<%s> [%s]", guildName, guildRankName)
        else
            self.bottom.guild:SetText(L["No Guild"])
        end

        SetAnimation("wave")

        self.startTime = GetTime()
        self.bottom.logout:SetValue(0)
        self.timer = CancelTimer(self.timer)
        UpdateTimer(self)
        self.timer = C_Timer.NewTicker(1, function() UpdateTimer(self) end)

        self.chat:RegisterEvent("CHAT_MSG_WHISPER")
        self.chat:RegisterEvent("CHAT_MSG_BN_WHISPER")
        self.chat:RegisterEvent("CHAT_MSG_GUILD")

        self.isAFK = true
    elseif self.isAFK then
        UIParent:Show()
        self:Hide()
        MoveViewLeftStop()
        self.timer = CancelTimer(self.timer)
        self.animTimer = CancelTimer(self.animTimer)

        self.bottom.time:SetText("00:00")

        self.chat:UnregisterAllEvents()
        self.chat:Clear()
        if GW.Retail and PVEFrame:IsShown() then
            PVEFrame_ToggleFrame()
            PVEFrame_ToggleFrame()
        end

        self.isAFK = false
    end
end

local function AFKMode_OnEvent(self, event, arg1)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event)
    elseif IsIn(event, "PLAYER_REGEN_DISABLED", "LFG_PROPOSAL_SHOW", "UPDATE_BATTLEFIELD_STATUS") then
        if event ~= "UPDATE_BATTLEFIELD_STATUS" or (GetBattlefieldStatus(arg1) == "confirm") then
            SetAFK(self, false)
        end

        if event == "PLAYER_REGEN_DISABLED" then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        return
    elseif not GW.settings.AFK_MODE or (event == "PLAYER_FLAGS_CHANGED" and arg1 ~= "player") or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
        return
    elseif UnitCastingInfo("player") then
        --Don't activate afk if player is crafting stuff, check back in 30 seconds
        C_Timer.After(30, function() AFKMode_OnEvent(self) end)
        return
    end

    SetAFK(self, GW.UnitIsAFK("player") and not ((GW.Retail or GW.Mists) and C_PetBattles.IsInBattle()))
end

local function OnKeyDown(self, key)
    if ignoreKeys[key] then return end

    if printKeys[key] then
        Screenshot()
    elseif self.isAFK then
        SetAFK(self, false)
        if not self.nextCheck or GetTime() >= self.nextCheck then
            self.nextCheck = GetTime() + 60
            C_Timer.After(60, function()
                self.nextCheck = nil
                AFKMode_OnEvent(self)
            end)
        end
    end
end

local function Chat_OnMouseWheel(self, delta)
    if delta == 1 and IsShiftKeyDown() then
        self:ScrollToTop()
    elseif delta == -1 and IsShiftKeyDown() then
        self:ScrollToBottom()
    elseif delta == -1 then
        self:ScrollDown()
    else
        self:ScrollUp()
    end
end

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, _, _, _, arg18)
    local infoType = strsub(event, 10)
    local info = ChatTypeInfo[infoType]

    local chatGroup = GetChatCategory(infoType)
    local chatTarget
    if chatGroup == "BN_CONVERSATION" then
        chatTarget = tostring(arg8)
    elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
        chatTarget = (GW.NotSecretValue(arg2) and strsub(arg2, 1, 2) ~= "|K") and strupper(arg2) or arg2
    end

    local playerLink
    local linkTarget = chatTarget and (":"..chatTarget) or ""
    if infoType ~= "BN_WHISPER" and infoType ~= "BN_CONVERSATION" then
        playerLink = format("|Hplayer:%s:%s:%s%s|h", arg2, arg11, chatGroup, linkTarget)
    else
        playerLink = format("|HBNplayer:%s:%s:%s:%s%s|h", arg2, arg13, arg11, chatGroup, linkTarget)
    end

    local isProtected = GW.ChatFunctions:IsMessageProtected(arg1)
    if not isProtected then
        arg1 = gsub(arg1, "%%", "%%%%")
        arg1 = RemoveExtraSpaces(arg1)
    end

    local isMobile = arg14 and GetMobileEmbeddedTexture(info.r, info.g, info.b)
    local message = format("%s%s", isMobile or "", arg1)

    local discordInfo, isFromDiscord = GW.ChatFunctions:GetDiscordInfo(arg18)
    if isFromDiscord then
        message = FormatDiscordMessage(discordInfo, message)
    end

    local coloredName = (infoType == "BN_WHISPER" and GW.GetBNFriendColor(arg2, arg13)) or GW.ChatFunctions:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg18)
    local senderLink = format("%s[%s]|h", playerLink, coloredName)
    local success, msg = pcall(format, _G["CHAT_" .. infoType .. "_GET"] .. "%s", senderLink, message)
    if not success then return end

    if not isProtected and GW.settings.CHAT_SHORT_CHANNEL_NAMES then
        msg = msg:gsub("|Hchannel:(.-)|h%[(.-)%]|h", GW.ShortChannel)
        msg = msg:gsub("^(.-|h) " .. CHAT_WHISPER_GET:format("~"):gsub("~ ", ""):gsub(": ", ""), "%1")
        msg = msg:gsub("<" .. AFK .. ">", "[|cffFF0000" .. AFK .. "|r] ")
        msg = msg:gsub("<" .. DND .. ">", "[|cffE7E716" .. DND .. "|r] ")
        msg = msg:gsub("^%[" .. RAID_WARNING .. "%]", "[" .. L["RW"] .. "]")
        msg = msg:gsub("%[BN_CONVERSATION:", "%[".."")
    end

    local accessID = GW.ChatFunctions:GetAccessID(chatGroup, chatTarget)
    local typeID = GW.ChatFunctions:GetAccessID(infoType, chatTarget, arg12 or arg13)
    self:AddMessage(msg, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

local function ToggelAfkMode()
    if not AFKMode then return end
    if GW.settings.AFK_MODE then
        AFKMode:RegisterEvent("PLAYER_FLAGS_CHANGED")
        AFKMode:RegisterEvent("PLAYER_REGEN_DISABLED")
        AFKMode:RegisterEvent("LFG_PROPOSAL_SHOW")
        AFKMode:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        AFKMode:SetScript("OnEvent", AFKMode_OnEvent)
        AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

        C_CVar.SetCVar("autoClearAFK", "1")
    else
        AFKMode:UnregisterAllEvents()
        AFKMode:SetScript("OnEvent", nil)

        AFKMode.chat:SetScript("OnEvent", nil)
        AFKMode.chat:Clear()
        AFKMode.timer = CancelTimer(AFKMode.timer)
        AFKMode.animTimer = CancelTimer(AFKMode.animTimer)
    end
end
GW.ToggelAfkMode = ToggelAfkMode

local function UpdateClasscolor()
    local classColor = GWGetClassColor(GW.myclass, true, true)
    AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)
end

local function LoadAFKAnimation()
    local classColor = GWGetClassColor(GW.myclass, true, true)
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
    AFKMode:SetScale(UIParent:GetScale())
    AFKMode:SetAllPoints(UIParent)
    AFKMode:Hide()
    AFKMode:EnableKeyboard(true)
    AFKMode:SetScript("OnKeyDown", OnKeyDown)

    AFKMode.chat = CreateFrame("ScrollingMessageFrame", nil, AFKMode)
    AFKMode.chat:SetSize(500, 200)
    AFKMode.chat:SetPoint("TOPLEFT", AFKMode, "TOPLEFT", 4, -4)
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
    AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

    AFKMode.bottom = CreateFrame("Frame", nil, AFKMode, "BackdropTemplate")
    AFKMode.bottom:SetFrameLevel(0)
    AFKMode.bottom:SetPoint("BOTTOM", AFKMode, "BOTTOM", 0, -5)
    AFKMode.bottom:SetBackdrop(BackdropFrame)
    AFKMode.bottom:SetWidth(GetScreenWidth() + (GW.border * 2))
    AFKMode.bottom:SetHeight(GetScreenHeight() * (1.5 / 10))

    local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = GW.myfaction, 140, -20, -8, -10, -36
    if factionGroup == "Neutral" then
        factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
    end

    AFKMode.bottom.faction = AFKMode.bottom:CreateTexture(nil, "OVERLAY")
    AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
    AFKMode.bottom.faction:SetTexture("Interface/Timer/" .. factionGroup .. "-Logo")
    AFKMode.bottom.faction:SetSize(size, size)

    AFKMode.bottom.name = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    AFKMode.bottom.name:SetFormattedText("%s-%s", playerName, GW.myrealm)
    AFKMode.bottom.name:SetPoint("TOPLEFT", AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
    AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)
    GW.Gw2ClassColorRegister(nil, UpdateClasscolor)

    AFKMode.bottom.guild = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.guild:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    AFKMode.bottom.guild:SetText(L["No Guild"])
    AFKMode.bottom.guild:SetPoint("TOPLEFT", AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
    AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

    AFKMode.bottom.time = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.time:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    AFKMode.bottom.time:SetText("00:00")
    AFKMode.bottom.time:SetPoint("TOPLEFT", AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
    AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

    -- countdown until the 30 minute server auto logout
    AFKMode.bottom.logout = CreateFrame("StatusBar", nil, AFKMode.bottom)
    AFKMode.bottom.logout:SetSize(240, 6)
    AFKMode.bottom.logout:SetPoint("TOPLEFT", AFKMode.bottom.time, "BOTTOMLEFT", 0, -8)
    AFKMode.bottom.logout:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    AFKMode.bottom.logout:SetStatusBarColor(GW.Colors.TextColors.LightHeader:GetRGB())
    AFKMode.bottom.logout:SetMinMaxValues(0, AFK_LOGOUT_TIME)
    AFKMode.bottom.logout:SetScript("OnUpdate", LogoutBar_OnUpdate)

    local logoutBg = AFKMode.bottom.logout:CreateTexture(nil, "BACKGROUND")
    logoutBg:SetAllPoints()
    logoutBg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    logoutBg:SetVertexColor(0, 0, 0, 0.6)

    AFKMode.bottom.logout.spark = AFKMode.bottom.logout:CreateTexture(nil, "OVERLAY")
    AFKMode.bottom.logout.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark")
    AFKMode.bottom.logout.spark:SetBlendMode("ADD")
    AFKMode.bottom.logout.spark:SetSize(20, 26)
    AFKMode.bottom.logout.spark:SetPoint("CENTER", AFKMode.bottom.logout, "LEFT", 0, 0)

    AFKMode.bottom.logout.text = AFKMode.bottom.logout:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.logout.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    AFKMode.bottom.logout.text:SetPoint("LEFT", AFKMode.bottom.logout, "RIGHT", 8, 0)
    AFKMode.bottom.logout.text:SetTextColor(0.7, 0.7, 0.7)

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
    AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
    AFKMode.bottom.model:SetCamDistanceScale(4.5)
    AFKMode.bottom.model:SetUnit("player")
    AFKMode.bottom.model:SetScript("OnUpdate", function(self)
        if self.isIdle then return end
        local timePassed = GetTime() - self.startTime
        if timePassed >= self.duration then
            self:SetAnimation(0)
            self.isIdle = true

            AFKMode.animTimer = CancelTimer(AFKMode.animTimer)
            AFKMode.animTimer = C_Timer.NewTimer(self.idleDuration, function() SetAnimation() end)
        end
    end)

    ToggelAfkMode()

    if IsMacClient() then
        printKeys[KEY_PRINTSCREEN_MAC] = true
    end
end
GW.LoadAFKAnimation = LoadAFKAnimation
