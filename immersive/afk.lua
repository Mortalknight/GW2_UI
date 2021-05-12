local _, GW = ...
local L = GW.L
local GWGetClassColor = GW.GWGetClassColor
local IsIn = GW.IsIn

local ignoreKeys = {
    LALT = true,
    LSHIFT = true,
    RSHIFT = true,
}
local printKeys = {
    ["PRINTSCREEN"] = true,
}

local function UpdateTimer(self)
    local time = GetTime() - self.startTime
    self.bottom.time:SetFormattedText("%02d:%02d", floor(time / 60), time % 60)
end

local function SetAFK(self, status)
    if status then
        MoveViewLeftStart(0.035)
        self:Show()
        CloseAllWindows()
        UIParent:Hide()

        if IsInGuild() then
            local guildName, guildRankName = GetGuildInfo("player")
            self.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName)
        else
            self.bottom.guild:SetText(L["No Guild"])
        end

        self.bottom.model.curAnimation = "wave"
        self.bottom.model.startTime = GetTime()
        self.bottom.model.duration = 2.3
        self.bottom.model:SetUnit("player")
        self.bottom.model.isIdle = nil
        self.bottom.model:SetAnimation(67)
        self.bottom.model.idleDuration = 30
        self.startTime = GetTime()
        self.timer = C_Timer.NewTicker(1, function() UpdateTimer(self) end)

        self.chat:RegisterEvent("CHAT_MSG_WHISPER")
        self.chat:RegisterEvent("CHAT_MSG_BN_WHISPER")
        self.chat:RegisterEvent("CHAT_MSG_GUILD")

        self.isAFK = true
    elseif self.isAFK then
        UIParent:Show()
        self:Hide()
        MoveViewLeftStop()

        self.timer:Cancel()
        if self.animTimer then self.animTimer:Cancel() end
        
        self.bottom.time:SetText("00:00")

        self.chat:UnregisterAllEvents()
        self.chat:Clear()

        self.isAFK = false
    end
end

local function AFKMode_OnEvent(self, event, ...)
    if IsIn(event, "PLAYER_REGEN_DISABLED", "UPDATE_BATTLEFIELD_STATUS") then
        if event == "UPDATE_BATTLEFIELD_STATUS" then
            local status = GetBattlefieldStatus(...)
            if status == "confirm" then
                SetAFK(self, false)
            end
        else
            SetAFK(self, false)
        end

        if event == "PLAYER_REGEN_DISABLED" then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end

    if InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown() then return end
    if UnitCastingInfo("player") ~= nil then
        --Don't activate afk if player is crafting stuff, check back in 30 seconds
        C_Timer.After(30, function() AFKMode_OnEvent(self) end)
        return
    end

    if UnitIsAFK("player") then
        SetAFK(self, true)
    else
        SetAFK(self, false)
    end
end

local function OnKeyDown(self, key)
    if ignoreKeys[key] then return end
    if printKeys[key] then
        Screenshot()
    else
        SetAFK(self, false)
        C_Timer.After(60, function() AFKMode_OnEvent(self) end)
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

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
    local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
    local type = strsub(event, 10)
    local info = ChatTypeInfo[type]

    if event == "CHAT_MSG_BN_WHISPER" then
        coloredName = format("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, arg2)
    end

    arg1 = RemoveExtraSpaces(arg1)

    local chatGroup = Chat_GetChatCategory(type)
    local chatTarget, body
    if chatGroup == "BN_CONVERSATION" then
        chatTarget = tostring(arg8)
    elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
        if not(strsub(arg2, 1, 2) == "|K") then
            chatTarget = arg2:upper()
        else
            chatTarget = arg2
        end
    end

    local playerLink
    if type ~= "BN_WHISPER" and type ~= "BN_CONVERSATION" then
        playerLink = "|Hplayer:" .. arg2 .. ":" .. arg11 .. ":" .. chatGroup .. (chatTarget and ":" .. chatTarget or "") .. "|h"
    else
        playerLink = "|HBNplayer:" .. arg2 .. ":" .. arg13 .. ":" .. arg11 .. ":" .. chatGroup .. (chatTarget and ":" .. chatTarget or "") .. "|h"
    end

    local message = arg1
    if arg14 then --isMobile
        message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b) .. message
    end

    --Escape any % characters, as it may otherwise cause an "invalid option in format" error in the next step
    message = gsub(message, "%%", "%%%%")

    local success
    success, body = pcall(format, _G["CHAT_" .. type .. "_GET"]..message, playerLink .. "[" .. coloredName .. "]" .. "|h")

    local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
    local typeID = ChatHistory_GetAccessID(type, chatTarget, arg12 == "" and arg13 or arg12)

    self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

local function LoopAnimations(self)
    if self.curAnimation == "wave" then
        self:SetAnimation(69)
        self.curAnimation = "dance"
        self.startTime = GetTime()
        self.duration = 300
        self.isIdle = false
        self.idleDuration = 120
    end
end

local function loadAFKAnimation()
    local classColor = GWGetClassColor(GW.myclass, true, true)
    
    local BackdropFrame = {
        bgFile = "Interface/AddOns/GW2_UI/textures/welcome-bg",
        edgeFile = "",
        tile = false,
        tileSize = 64,
        edgeSize = 32,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    }

    local AFKMode = CreateFrame("Frame")
    AFKMode:SetFrameLevel(1)
    AFKMode:SetScale(UIParent:GetScale())
    AFKMode:SetAllPoints(UIParent)
    AFKMode:Hide()
    AFKMode:EnableKeyboard(true)
    AFKMode:SetScript("OnKeyDown", OnKeyDown)

    AFKMode.chat = CreateFrame("ScrollingMessageFrame", nil, AFKMode)
    AFKMode.chat:SetSize(500, 200)
    AFKMode.chat:SetPoint("TOPLEFT", AFKMode, "TOPLEFT", 4, -4)
    AFKMode.chat:SetFont(UNIT_NAME_FONT, 12)
    AFKMode.chat:SetJustifyH("LEFT")
    AFKMode.chat:SetMaxLines(100)
    AFKMode.chat:EnableMouseWheel(true)
    AFKMode.chat:SetFading(false)
    AFKMode.chat:SetMovable(true)
    AFKMode.chat:EnableMouse(true)
    AFKMode.chat:RegisterForDrag("LeftButton")
    AFKMode.chat:SetScript("OnDragStart", AFKMode.chat.StartMoving)
    AFKMode.chat:SetScript("OnDragStop", AFKMode.chat.StopMovingOrSizing)
    AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel)
    AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

    AFKMode.bottom = CreateFrame("Frame", nil, AFKMode)
    AFKMode.bottom:SetFrameLevel(0)
    AFKMode.bottom:SetPoint("BOTTOM", AFKMode, "BOTTOM", 0, -5)
    AFKMode.bottom:CreateBackdrop(BackdropFrame)
    AFKMode.bottom:SetWidth(GetScreenWidth() + (GW.border * 2))
    AFKMode.bottom:SetHeight(GetScreenHeight() * (1.5 / 10))

    local modelOffsetY = 205
    if GW.myrace == "Human" then
        modelOffsetY = 195
    elseif GW.myrace == "Tauren" then
        modelOffsetY = 250
    elseif GW.myrace == "Troll" then
        if GW.mysex == 2 then 
            modelOffsetY = 250
        elseif GW.mysex == 3 then
            modelOffsetY = 280
        end
    elseif GW.myrace == "Dwarf"then
        if GW.mysex == 2 then modelOffsetY = 250 end
    end

    AFKMode.bottom.faction = AFKMode.bottom:CreateTexture(nil, "OVERLAY")
    AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", AFKMode.bottom, "BOTTOMLEFT", -20, -8)
    AFKMode.bottom.faction:SetTexture("Interface/Timer/" .. GW.myfaction .. "-Logo")
    AFKMode.bottom.faction:SetSize(140, 140)

    AFKMode.bottom.name = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.name:SetFont(UNIT_NAME_FONT, 20)
    AFKMode.bottom.name:SetFormattedText("%s-%s", GW.myname, GW.myname)
    AFKMode.bottom.name:SetPoint("TOPLEFT", AFKMode.bottom.faction, "TOPRIGHT", -10, -36)
    AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

    AFKMode.bottom.guild = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.guild:SetFont(UNIT_NAME_FONT, 20)
    AFKMode.bottom.guild:SetText(L["No Guild"])
    AFKMode.bottom.guild:SetPoint("TOPLEFT", AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
    AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

    AFKMode.bottom.time = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
    AFKMode.bottom.time:SetFont(UNIT_NAME_FONT, 20)
    AFKMode.bottom.time:SetText("00:00")
    AFKMode.bottom.time:SetPoint("TOPLEFT", AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
    AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

    --Use this frame to control position of the model
    AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, AFKMode.bottom)
    AFKMode.bottom.modelHolder:SetSize(150, 150)
    AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", AFKMode.bottom, "BOTTOMRIGHT", -200, modelOffsetY)

    AFKMode.bottom.model = CreateFrame("PlayerModel", nil, AFKMode.bottom.modelHolder)
    AFKMode.bottom.model:SetPoint("CENTER", AFKMode.bottom.modelHolder, "CENTER")
    AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
    AFKMode.bottom.model:SetCamDistanceScale(4.5)
    AFKMode.bottom.model:SetFacing(6)
    AFKMode.bottom.model:SetScript("OnUpdate", function(self)
        local timePassed = GetTime() - self.startTime
        if timePassed > self.duration and self.isIdle ~= true then
            self:SetAnimation(0)
            self.isIdle = true
            AFKMode.animTimer = C_Timer.NewTimer(self.idleDuration, function() LoopAnimations(self) end)
        end
    end)

    AFKMode:RegisterEvent("PLAYER_FLAGS_CHANGED")
    AFKMode:RegisterEvent("PLAYER_REGEN_DISABLED")
    AFKMode:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    AFKMode:SetScript("OnEvent", AFKMode_OnEvent)
    SetCVar("autoClearAFK", "1")

    if IsMacClient() then
        printKeys[KEY_PRINTSCREEN_MAC] = true
    end
end
GW.loadAFKAnimation = loadAFKAnimation