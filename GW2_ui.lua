local _, GW = ...
local RoundInt = GW.RoundInt
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local GetDefault = GW.GetDefault
local bloodSpark = GW.BLOOD_SPARK
local CLASS_ICONS = GW.CLASS_ICONS
local IsFrameModified = GW.IsFrameModified
local Debug = GW.Debug
local LibSharedMedia = LibStub("LibSharedMedia-3.0", true)

GW.VERSION_STRING = "GW2_UI @project-version@"

local loaded = false
local forcedMABags = false

local MOVABLE_FRAMES = {}
GW.MOVABLE_FRAMES = MOVABLE_FRAMES
local MOVABLE_FRAMES_REF = {}
local MOVABLE_FRAMES_SETTINGS_KEY = {}

local swimAnimation = 0
local lastSwimState = true

if Profiler then
    _G.GW_Addon_Scope = GW
end

local function disableMABags()
    local bags = GetSetting("BAGS_ENABLED")
    if not bags or not MovAny or not MADB then
        return
    end
    MADB.noBags = true
    MAOptNoBags:SetEnabled(false)
    forcedMABags = true
end
GW.AddForProfiling("index", "disableMABags", disableMABags)

local function lockableOnClick(name, frame, moveframe, settingsName, lockAble)
    local dummyPoint = GetDefault(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(
        dummyPoint["point"],
        UIParent,
        dummyPoint["relativePoint"],
        dummyPoint["xOfs"],
        dummyPoint["yOfs"]
    )
    MOVABLE_FRAMES[name] = moveframe
    MOVABLE_FRAMES_REF[name] = frame
    MOVABLE_FRAMES_SETTINGS_KEY[name] = settingsName

    local point, _, relativePoint, xOfs, yOfs = moveframe:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point["point"] = point
    new_point["relativePoint"] = relativePoint
    new_point["xOfs"] = math.floor(xOfs)
    new_point["yOfs"] = math.floor(yOfs)
    SetSetting(settingsName, new_point)

    SetSetting(lockAble, true)
end
GW.AddForProfiling("index", "lockableOnClick", lockableOnClick)

local function lockFrame_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Lock to default position", 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("index", "lockFrame_OnEnter", lockFrame_OnEnter)

local function mover_OnDragStart(self)
    self.IsMoving = true
    self:StartMoving()
end
GW.AddForProfiling("index", "mover_OnDragStart", mover_OnDragStart)

local function mover_OnDragStop(self)
    local settingsName = self.gw_Settings
    local lockAble = self.gw_Lockable
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point["point"] = point
    new_point["relativePoint"] = relativePoint
    new_point["xOfs"] = math.floor(xOfs)
    new_point["yOfs"] = math.floor(yOfs)
    SetSetting(settingsName, new_point)
    if lockAble ~= nil then
        SetSetting(lockAble, false)
    end

    self.IsMoving = false
end
GW.AddForProfiling("index", "mover_OnDragStop", mover_OnDragStop)

local function RegisterMovableFrame(name, frame, settingsName, dummyFrame, lockAble)
    local moveframe = CreateFrame("Frame", name .. "MoveAble", UIParent, dummyFrame)
    if frame == GameTooltip then
        moveframe:SetSize(230, 80)
    else
        moveframe:SetSize(frame:GetSize())
    end
    moveframe.frameName:SetText(name)
    moveframe.gw_Settings = settingsName
    moveframe.gw_Lockable = lockAble

    local dummyPoint = GetSetting(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(
        dummyPoint["point"],
        UIParent,
        dummyPoint["relativePoint"],
        dummyPoint["xOfs"],
        dummyPoint["yOfs"]
    )
    MOVABLE_FRAMES[name] = moveframe
    MOVABLE_FRAMES_REF[name] = frame
    MOVABLE_FRAMES_SETTINGS_KEY[name] = settingsName
    moveframe:Hide()
    moveframe:RegisterForDrag("LeftButton")

    if lockAble ~= nil then
        local lockFrame = CreateFrame("Button", name .. "LockButton", moveframe, "GwDummyLockButton")
        lockFrame:SetScript("OnEnter", lockFrame_OnEnter)
        lockFrame:SetScript("OnLeave", GameTooltip_Hide)
        lockFrame:SetScript(
            "OnClick",
            function()
                lockableOnClick(name, frame, moveframe, settingsName, lockAble)
            end
        )
    end

    moveframe:SetScript("OnDragStart", mover_OnDragStart)
    moveframe:SetScript("OnDragStop", mover_OnDragStop)
end
GW.RegisterMovableFrame = RegisterMovableFrame

local function UpdateFramePositions()
    for k, v in pairs(MOVABLE_FRAMES_REF) do
        local newp = GetSetting(MOVABLE_FRAMES_SETTINGS_KEY[k])
        v:ClearAllPoints()
        MOVABLE_FRAMES_REF[k]:SetPoint(newp["point"], UIParent, newp["relativePoint"], newp["xOfs"], newp["yOfs"])
    end
end
GW.UpdateFramePositions = UpdateFramePositions

-- https://us.battle.net/forums/en/wow/topic/6036615884
if AchievementMicroButton_Update == nil then
    function AchievementMicroButton_Update()
        return
    end
end

local animations = {}
GW.animations = animations
local function AddToAnimation(name, from, to, start, duration, method, easeing, onCompleteCallback, doCompleteOnOverider)
    local newAnimation = true
    if animations[name] ~= nil then
        if (animations[name]["start"] + animations[name]["duration"]) > GetTime() then
            newAnimation = false
        end
    end
    if doCompleteOnOverider == nil then
        newAnimation = true
    end

    if newAnimation == false then
        animations[name]["duration"] = duration
        animations[name]["to"] = to
        animations[name]["progress"] = 0
        animations[name]["method"] = method
        animations[name]["completed"] = false
        animations[name]["easeing"] = easeing
        animations[name]["onCompleteCallback"] = onCompleteCallback
    else
        animations[name] = {}
        animations[name]["start"] = start
        animations[name]["duration"] = duration
        animations[name]["from"] = from
        animations[name]["to"] = to
        animations[name]["progress"] = 0
        animations[name]["method"] = method
        animations[name]["completed"] = false
        animations[name]["easeing"] = easeing
        animations[name]["onCompleteCallback"] = onCompleteCallback
    end
end
GW.AddToAnimation = AddToAnimation

local function buttonAnim(self, name, w, hover)
    local prog = animations[name]["progress"]
    local l = GW.lerp(0, w, prog)

    hover:SetPoint("RIGHT", self, "LEFT", l, 0)
    hover:SetVertexColor(1, 1, 1, GW.lerp(0, 1, ((prog) - 0.5) / 0.5))
end
GW.AddForProfiling("index", "buttonAnim", buttonAnim)

--[[
 Basic helper function for spritemaps
 mapExample = {
  width = 100,
  height = 10,
  colums = 5,
  rows = 3
}
]]--
local function getSprite(map,x,y)



    local pw = (map.width / map.colums) / map.width
    local ph = (map.height / map.rows) / map.height

    local left = pw * (x - 1)
    local right = pw * x

    local top = ph * (y - 1)
    local bottom = ph * y

    return left, right, top, bottom;
end
GW.getSprite = getSprite


function GwStandardButton_OnEnter(self)
    local name = tostring(self)
    local w = self:GetWidth()
    local hover = self.hover
    if not hover then
        return
    end

    hover:SetAlpha(1)
    self.animationValue = 0

    AddToAnimation(
        name,
        self.animationValue,
        1,
        GetTime(),
        0.2,
        function()
            buttonAnim(self, name, w, hover)
        end
    )
end

function GwStandardButton_OnLeave(self)
    local name = tostring(self)
    local w = self:GetWidth()
    local hover = self.hover
    if not hover then
        return
    end

    hover:SetAlpha(1)
    self.animationValue = 1

    AddToAnimation(
        name,
        self.animationValue,
        0,
        GetTime(),
        0.2,
        function()
            buttonAnim(self, name, w, hover)
        end
    )
end


local function barAnimation(self, barWidth, sparkWidth)
    local snap = (animations[self.animationName]["progress"] * 100) / 5

    local round_closest = 0.05 * snap

    local spark_min = math.floor(snap)
    local spark_current = snap

    local spark_prec = spark_current - spark_min

    local spark =
        math.min(barWidth - sparkWidth, math.floor(barWidth * round_closest) - math.floor(sparkWidth * spark_prec))
    local bI = 17 - math.max(1, RoundInt(16 * spark_prec))

    self.spark:SetTexCoord(bloodSpark[bI].left, bloodSpark[bI].right, bloodSpark[bI].top, bloodSpark[bI].bottom)

    self:SetValue(round_closest)
    self.spark:ClearAllPoints()
    self.spark:SetPoint("LEFT", spark, 0)
end
GW.AddForProfiling("index", "barAnimation", barAnimation)

local function Bar(self, value)
    if self == nil then
        return
    end
    local barWidth = self:GetWidth()
    local sparkWidth = self.spark:GetWidth()

    AddToAnimation(
        self.animationName,
        self.animationValue,
        value,
        GetTime(),
        0.2,
        function()
            barAnimation(self, barWidth, sparkWidth)
        end
    )
    self.animationValue = value
end
GW.Bar = Bar

local function SetClassIcon(self, class)
    if class == nil then
        class = 0
    end

    self:SetTexCoord(CLASS_ICONS[class].l, CLASS_ICONS[class].r, CLASS_ICONS[class].t, CLASS_ICONS[class].b)
end
GW.SetClassIcon = SetClassIcon

local function SetDeadIcon(self)
    self:SetTexCoord(CLASS_ICONS["dead"].l, CLASS_ICONS["dead"].r, CLASS_ICONS["dead"].t, CLASS_ICONS["dead"].b)
end
GW.SetDeadIcon = SetDeadIcon

local function StopAnimation(k)
    if animations[k] ~= nil then
        animations[k] = nil
    end
end
GW.StopAnimation = StopAnimation

local l = CreateFrame("Frame", nil, UIParent)

local function swimAnim()
    local r, g, b = _G["GwActionBarHudRIGHTSWIM"]:GetVertexColor()
    _G["GwActionBarHudRIGHTSWIM"]:SetVertexColor(r, g, b, animations["swimAnimation"]["progress"])
    _G["GwActionBarHudLEFTSWIM"]:SetVertexColor(r, g, b, animations["swimAnimation"]["progress"])
end
GW.AddForProfiling("index", "swimAnim", swimAnim)

local updateCB = {}
local function AddUpdateCB(func, payload)
    if type(func) ~= "function" then
        return
    end

    tinsert(
        updateCB,
        {
            ["func"] = func,
            ["payload"] = payload
        }
    )
end
GW.AddUpdateCB = AddUpdateCB

local function gw_OnUpdate(self, elapsed)
    local foundAnimation = false
    local count = 0
    for k, v in pairs(animations) do
        count = count + 1
        if v["completed"] == false and GetTime() >= (v["start"] + v["duration"]) then
            if v["easeing"] == nil then
                v["progress"] = GW.lerp(v["from"], v["to"], math.sin(1 * math.pi * 0.5))
            else
                v["progress"] = GW.lerp(v["from"], v["to"], 1)
            end
            if v["method"] ~= nil then
                v["method"](v["progress"])
            end

            if v["onCompleteCallback"] ~= nil then
                v["onCompleteCallback"]()
            end

            v["completed"] = true
            foundAnimation = true
        end
        if v["completed"] == false then
            if v["easeing"] == nil then
                v["progress"] =
                    GW.lerp(v["from"], v["to"], math.sin((GetTime() - v["start"]) / v["duration"] * math.pi * 0.5))
            else
                v["progress"] = GW.lerp(v["from"], v["to"], (GetTime() - v["start"]) / v["duration"])
            end
            v["method"](v["progress"])
            foundAnimation = true
        end
    end

    if foundAnimation == false and count ~= 0 then
        table.wipe(animations)
    end

    --Swim hud
    if lastSwimState ~= IsSwimming() then
        if IsSwimming() then
            AddToAnimation("swimAnimation", swimAnimation, 1, GetTime(), 0.1, swimAnim)
            swimAnimation = 1
        else
            AddToAnimation("swimAnimation", swimAnimation, 0, GetTime(), 3.0, swimAnim)
            swimAnimation = 0
        end
        lastSwimState = IsSwimming()
    end

    for _, cb in ipairs(updateCB) do
        cb.func(cb.payload, elapsed)
    end
end
GW.AddForProfiling("index", "gw_OnUpdate", gw_OnUpdate)

local function pixelPerfection()
    local _, screenHeight = GetPhysicalScreenSize()
    local scale = 768 / screenHeight
    UIParent:SetScale(scale)
end
GW.pixelPerfection = pixelPerfection

local SCALE_HUD_FRAMES = {
    "GwHudArtFrame",
    "GwPlayerPowerBar",
    "GwPlayerAuraFrame",
    "GwPlayerClassPower",
    "GwPlayerHealthGlobe",
    "GwPlayerPetFrame",
    "GwMultiBarBottomRight",
    "GwMultiBarBottomLeft",
    "GwMultiBarRight",
    "GwMultiBarLeft",
    "GwCharacterWindow"
}
local function UpdateHudScale()
    local hudScale = GetSetting("HUD_SCALE")
    MainMenuBarArtFrame:SetScale(hudScale)
    for i, name in ipairs(SCALE_HUD_FRAMES) do
        local f = _G[name]
        local fm = _G[name .. "MoveAble"]
        if f then
            f:SetScale(hudScale)
        end
        if fm then
            fm:SetScale(hudScale)
        end
    end
end
GW.UpdateHudScale = UpdateHudScale

local function loadAddon(self)
    if GetSetting("PIXEL_PERFECTION") and not GetCVarBool("useUiScale") then
        pixelPerfection()
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFB900<GW2_UI>|r Pixel Perfection-Mode enabled. UIScale down to perfect pixel size. Can be deactivated in HUD settings. |cFF00FF00/gw2|r")
    end

    -- setup our frame pool
    GW.Pools = CreatePoolCollection()

    -- disable Move Anything bag handling
    disableMABags()

    -- hook debug output if relevant
    --@debug@
    local dev_dbg_tab = GetSetting("DEV_DBG_CHAT_TAB")
    if dev_dbg_tab and dev_dbg_tab > 0 and _G["ChatFrame" .. dev_dbg_tab] then
        DEFAULT_CHAT_FRAME:AddMessage("hooking Debug to chat tab #" .. dev_dbg_tab)
        GW.dbgTab = dev_dbg_tab
        GW.AlertTestsSetup()
        GW.inDebug = true
    else
        GW.inDebug = false
    end
    --@end-debug@
    --[===[@non-debug@
    GW.inDebug = false
    --@end-non-debug@]===]

    --Create Settings window
    GW.LoadSettings()
    GW.DisplaySettings()
    GW.SkinMainMenu()
    GW.SkinStaticPopup()
    GW.SkinBNToastFrame()
    GW.SkinGhostFrame()

    --Create hud art
    GW.LoadHudArt()

    --Create experiencebar
    GW.LoadXPBar()

    if GetSetting("FONTS_ENABLED") then
        GW.LoadFonts()
    end

    if GetSetting("CASTINGBAR_ENABLED") then
        GW.LoadCastingBar()
    end

    if GetSetting("MINIMAP_ENABLED") then
        GW.LoadMinimap()
    end

    if GetSetting("QUESTTRACKER_ENABLED") then
        GW.LoadQuestTracker()
    end

    if GetSetting("TOOLTIPS_ENABLED") then
        GW.LoadTooltips()
    end

    if GetSetting("QUESTVIEW_ENABLED") then
        GW.LoadQuestview()
    end

    if GetSetting("CHATFRAME_ENABLED") then
        GW.LoadChat()
    end

    --Create player hud
    if GetSetting("HEALTHGLOBE_ENABLED") then
        GW.LoadPlayerHud()
    end

    if GetSetting("POWERBAR_ENABLED") then
        GW.LoadPowerBar()
    end

    if GetSetting("BAGS_ENABLED") then
        GW.LoadInventory()
        GW.SkinLooTFrame()
    end

    if GetSetting("USE_BATTLEGROUND_HUD") then
        GW.LoadBattlegrounds()
    end

    GW.LoadCharacter()

    GW.LoadBreathMeter()

    --Create unitframes
    if GetSetting("FOCUS_ENABLED") then
        GW.LoadFocus()
        if GetSetting("focus_TARGET_ENABLED") then
            GW.LoadTargetOfUnit("Focus")
        end
    end
    if GetSetting("TARGET_ENABLED") then
        GW.LoadTarget()
        if GetSetting("target_TARGET_ENABLED") then
            GW.LoadTargetOfUnit("Target")
        end

        -- move zone text frame
        if not IsFrameModified("ZoneTextFrame") then
            ZoneTextFrame:ClearAllPoints()
            ZoneTextFrame:SetPoint("TOP", UIParent, "TOP", 0, -175)
        end

        -- move error frame
        if not IsFrameModified("UIErrorsFrame") then
            UIErrorsFrame:ClearAllPoints()
            UIErrorsFrame:SetPoint("TOP", UIParent, "TOP", 0, -190)
            UIErrorsFrame:SetFont(STANDARD_TEXT_FONT, 14)
        end
    end

    if GetSetting("CLASS_POWER") then
        GW.LoadClassPowers()
    end

    -- create action bars
    if GetSetting("ACTIONBARS_ENABLED") then
        GW.LoadActionBars()
    end

    -- create pet frame
    if GetSetting("PETBAR_ENABLED") then
        GW.LoadPetFrame()
    end

    -- create buff frame
    if GetSetting("PLAYER_BUFFS_ENABLED") then
        GW.LoadBuffs()
    end

    if GetSetting("DYNAMIC_CAM") then
        ConsoleExec("ActionCam basic")
    else
        ConsoleExec("ActionCam default")
    end

    -- create new microbuttons
    --[[
    if GetSetting('CHATBUBBLES_ENABLED') then
        GW.LoadChatBubbles()
    end
    --]]
    GW.LoadMicroMenu()
    GW.LoadOrderBar()

    if GetSetting("GROUP_FRAMES") then
        GW.LoadPartyFrames()
        GW.LoadRaidFrames()
    end

    GW.UpdateHudScale()

    if (forcedMABags) then
        GW.Notice(GwLocalization["DISABLED_MA_BAGS"])
    end

    --Add Shared Media
    --Font
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI", "Interface\\AddOns\\GW2_UI\\fonts\\menomonia.ttf", LibSharedMedia.LOCALE_BIT_western + LibSharedMedia.LOCALE_BIT_ruRU)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI Light", "Interface\\AddOns\\GW2_UI\\fonts\\menomonia-italic.ttf", LibSharedMedia.LOCALE_BIT_western + LibSharedMedia.LOCALE_BIT_ruRU)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI Headlines", "Interface\\AddOns\\GW2_UI\\fonts\\headlines.ttf", LibSharedMedia.LOCALE_BIT_western + LibSharedMedia.LOCALE_BIT_ruRU)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI", "Interface\\AddOns\\GW2_UI\\fonts\\chinese.ttf", LibSharedMedia.LOCALE_BIT_zhCN + LibSharedMedia.LOCALE_BIT_zhTW)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI", "Interface\\AddOns\\GW2_UI\\fonts\\korean.ttf", LibSharedMedia.LOCALE_BIT_koKR)

    --Texture
    LibSharedMedia:Register(LibSharedMedia.MediaType.BACKGROUND, "GW2_UI", "Interface\\AddOns\\GW2_UI\\Textures\\windowborder.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.BACKGROUND, "GW2_UI_2", "Interface\\Addons\\GW2_UI\\Textures\\UI-Tooltip-Background.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI_Yellow", "Interface\\Addons\\GW2_UI\\Textures\\castingbar.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI_Blue", "Interface\\Addons\\GW2_UI\\Textures\\breathmeter.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI", "Interface\\Addons\\GW2_UI\\Textures\\castinbar-white.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI_2", "Interface\\Addons\\GW2_UI\\Textures\\gwstatusbar.tga")
    

    --Check if we should show Welcomepage or Changelog
    if GetSetting("GW2_UI_VERSION") == "WELCOME" then
        --Show Welcome page
        local GwWelcomePage  = CreateFrame("Frame", nil, UIParent, "GwWelcomePage")
        GwWelcomePage.subHeader:SetText(GW.VERSION_STRING)
        GwWelcomePage.changelog.scroll.scrollchild.text:SetText(GW.GW_CHANGELOGS)
        GwWelcomePage.changelog.scroll.slider:SetMinMaxValues(0, GwWelcomePage.changelog.scroll.scrollchild.text:GetStringHeight())
        GwWelcomePage.changelog.scroll.slider.thumb:SetHeight(100)
        GwWelcomePage.changelog.scroll.slider:SetValue(1)
        GwWelcomePage.changelog:Hide()
        GwWelcomePage.welcome:Show()
        GwWelcomePage.changelogORwelcome:SetText(GwLocalization["CHANGELOG"])
        if GetSetting("PIXEL_PERFECTION") then
            GwWelcomePage.welcome.pixelbutton:SetText(GwLocalization["PIXEL_PERFECTION_OFF"])
        end
        --Button
        GwWelcomePage.movehud:SetScript("OnClick", function()
            GwWelcomePage:Hide()
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage(GwLocalization["HUD_MOVE_ERR"])
                return
            end
            GW.moveHudObjects()
        end)
        GwWelcomePage.welcome.pixelbutton:SetScript("OnClick", function(self)
            if self:GetText() == GwLocalization["PIXEL_PERFECTION_ON"] then
                pixelPerfection()
                SetSetting("PIXEL_PERFECTION", true)
                self:SetText(GwLocalization["PIXEL_PERFECTION_OFF"])
            else
                SetCVar("useUiScale", true)
                SetCVar("useUiScale", false)
                SetSetting("PIXEL_PERFECTION", false)
                self:SetText(GwLocalization["PIXEL_PERFECTION_ON"])
            end
        end)
        --Save current Version
        SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
    elseif GetSetting("GW2_UI_VERSION") ~= GW.VERSION_STRING then
        --Show Changelog
        local GwWelcomePage  = CreateFrame("Frame", nil, UIParent, "GwWelcomePage")
        GwWelcomePage.subHeader:SetText(GW.VERSION_STRING)
        GwWelcomePage.changelog.scroll.scrollchild.text:SetText(GW.GW_CHANGELOGS)
        GwWelcomePage.changelog.scroll.slider:SetMinMaxValues(0, GwWelcomePage.changelog.scroll.scrollchild.text:GetStringHeight())
        GwWelcomePage.changelog.scroll.slider.thumb:SetHeight(100)
        GwWelcomePage.changelog.scroll.slider:SetValue(1)
        GwWelcomePage.changelog:Show()
        GwWelcomePage.welcome:Hide()
        GwWelcomePage.changelogORwelcome:SetText(GwLocalization["WELCOME"])
        if GetSetting("PIXEL_PERFECTION") then
            GwWelcomePage.welcome.pixelbutton:SetText(GwLocalization["PIXEL_PERFECTION_OFF"])
        end
        --Button
        GwWelcomePage.movehud:SetScript("OnClick", function()
            GwWelcomePage:Hide()
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage(GwLocalization["HUD_MOVE_ERR"])
                return
            end
            GW.moveHudObjects()
        end)
        GwWelcomePage.welcome.pixelbutton:SetScript("OnClick", function(self)
            if self:GetText() == GwLocalization["PIXEL_PERFECTION_ON"] then
                pixelPerfection()
                SetSetting("PIXEL_PERFECTION", true)
                self:SetText(GwLocalization["PIXEL_PERFECTION_OFF"])
            else
                SetCVar("useUiScale", true)
                SetCVar("useUiScale", false)
                SetSetting("PIXEL_PERFECTION", false)
                self:SetText(GwLocalization["PIXEL_PERFECTION_ON"])
            end
        end)
        SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
    end

    self:SetScript("OnUpdate", gw_OnUpdate)
end
GW.AddForProfiling("index", "loadAddon", loadAddon)

-- handles addon loading
local function gw_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if not loaded then
            loaded = true
            loadAddon(self)
        end
        GW.LoadStorage()
    elseif event == "PLAYER_LEAVING_WORLD" then
        GW.inWorld = false
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_ENTERING_BATTLEGROUND" then
        GW.inWorld = true
        if GetSetting("PIXEL_PERFECTION") and not GetCVarBool("useUiScale") then
            pixelPerfection()
        end
    end
end
GW.AddForProfiling("index", "gw_OnEvent", gw_OnEvent)
l:SetScript("OnEvent", gw_OnEvent)
l:RegisterEvent("PLAYER_LOGIN")
l:RegisterEvent("PLAYER_LEAVING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

local function AddToClique(frame)
    if type(frame) == "string" then
        local frameName = frame
        frame = _G[frameName]
    end

    if frame and frame.RegisterForClicks and ClickCastFrames ~= nil then
        ClickCastFrames[frame] = true
    end
end
GW.AddToClique = AddToClique

local waitTable = {}
local waitFrame = nil
local function wait_OnUpdate(self, elapse)
    local count = #waitTable
    local i = 1
    while (i <= count) do
        local waitRecord = tremove(waitTable, i)
        local d = tremove(waitRecord, 1)
        local f = tremove(waitRecord, 1)
        local p = tremove(waitRecord, 1)
        if (d > elapse) then
            tinsert(waitTable, i, {d - elapse, f, p})
            i = i + 1
        else
            count = count - 1
            f(unpack(p))
        end
    end
end
GW.AddForProfiling("index", "wait_OnUpdate", wait_OnUpdate)

local function Wait(delay, func, ...)
    if type(delay) ~= "number" or type(func) ~= "function" then
        return false
    end
    if waitFrame == nil then
        waitFrame = CreateFrame("Frame", "GwWaitFrame", UIParent)
        waitFrame:SetScript("OnUpdate", wait_OnUpdate)
    end
    tinsert(waitTable, {delay, func, {...}})
    return true
end
GW.Wait = Wait

local function Self_Hide(self)
    self:Hide()
end
GW.Self_Hide = Self_Hide

local function Parent_Hide(self)
    self:GetParent():Hide()
end
GW.Parent_Hide = Parent_Hide
