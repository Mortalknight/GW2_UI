local _, GW = ...
local GetSetting = GW.GetSetting
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local RoundDec = GW.RoundDec
local CUSTOM_MICRO_BUTTONS = {}
local gw_latencyToolTipUpdate = 0
local gw_frameRate = 0
local gw_latencyToolTipUpdate = 0

local function updateGuildButton()
    local bmb = GwMicroButtonSocialsMicroButton
    if bmb == nil then
        return
    end

    local _, _, numOnlineMembers = GetNumGuildMembers()

    if numOnlineMembers ~= nil and numOnlineMembers > 0 then
        bmb.darkbg:Show()

        if numOnlineMembers > 9 then
            bmb.String:SetText(numOnlineMembers)
        else
            bmb.String:SetText(numOnlineMembers .. " ")
        end
        bmb.String:Show()
    else
        bmb.darkbg:Hide()
        bmb.String:Hide()
    end
end

local function updateBagButton()
    local bmb = GwMicroButtonBagMicroButton
    if bmb == nil then
        return
    end

    local totalEmptySlots = 0
    for i = 0, 4 do
        local numberOfFreeSlots, _ = GetContainerNumFreeSlots(i)

        if numberOfFreeSlots ~= nil then
            totalEmptySlots = totalEmptySlots + numberOfFreeSlots
        end
    end

    bmb.darkbg:Show()
    if totalEmptySlots > 9 then
        bmb.String:SetText(totalEmptySlots)
    else
        bmb.String:SetText(totalEmptySlots .. " ")
    end
    bmb.String:Show()
end


local microButtonFrame = CreateFrame("Frame", "GwMicroButtonFrame", UIParent,"GwMicroButtonFrame")
local microButtonPadding = 4 +12

function create_micro_button(key)
    local mf = CreateFrame("Button", "GwMicroButton"..key, microButtonFrame,"SecureHandlerClickTemplate,GwMicroButtonTemplate")
    mf:SetPoint("CENTER",microButtonFrame,"TOPLEFT",microButtonPadding,-16);
    microButtonPadding = microButtonPadding + 24 + 4

   mf:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\"..key.."-Up");
   mf:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\"..key.."-Up");
   mf:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\"..key.."-Up");
   mf:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\"..key.."-Up");

    _G["GwMicroButton"..key.."String"]:SetFont(DAMAGE_TEXT_FONT,12)
    _G["GwMicroButton"..key.."String"]:SetShadowColor(0,0,0,0)

     _G["GwMicroButton"..key.."Texture"]:Hide()
     _G["GwMicroButton"..key.."String"]:Hide()

    return mf
end

local function microMenuFrameShow(f, name)
    StopAnimation(name)
    StopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = true
    AddToAnimation(name, 0, 1, GetTime(), 0.1, function()
        f:SetAlpha(animations[name]["progress"])
    end, nil, nil)
    AddToAnimation("GwHudArtFrameMenuBackDrop", 0, 1, GetTime(), 0.1, function()
        GwHudArtFrameMenuBackDrop:SetAlpha(animations["GwHudArtFrameMenuBackDrop"]["progress"])
    end, nil, nil)
end

local function microMenuFrameHide(f, name)
    StopAnimation(name)
    StopAnimation("GwHudArtFrameMenuBackDrop")
    f.gw_FadeShowing = false
    AddToAnimation(name, 1, 0, GetTime(), 0.1, function()
        f:SetAlpha(animations[name]["progress"])
    end, nil, nil)
    AddToAnimation("GwHudArtFrameMenuBackDrop", 1, 0, GetTime(), 0.1, function()
        GwHudArtFrameMenuBackDrop:SetAlpha(animations["GwHudArtFrameMenuBackDrop"]["progress"])
    end, nil, nil)
end

local function gw_getMicroButtonToolTip(text, action)
    if GetBindingKey(action) and text ~= nil then
     return text .. " |cffa6a6a6(" .. GetBindingText(GetBindingKey(action)) .. ")" .. FONT_COLOR_CODE_CLOSE
 else
     return text
 end
end

local function gw_setToolTipForShow(frame, text, action)
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT", 16 + (GameTooltip:GetWidth() / 2), -10);
    GameTooltip:ClearLines()
    GameTooltip:AddLine(gw_getMicroButtonToolTip(text, action), 1, 1, 1)
    GameTooltip:Show()
end

local gw_addonMemoryArray = {}
local function LatencyInfoToolTip()
    if gw_latencyToolTipUpdate > GetTime() then
        return
    end
    gw_latencyToolTipUpdate = GetTime() + 0.5

    gw_frameRate = GW.RoundInt(GetFramerate())
    local down, up, lagHome, lagWorld = GetNetStats()
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
    GameTooltip:AddLine(gw_getMicroButtonToolTip(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_1"] .. gw_frameRate .." fps", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_2"] .. lagHome .." ms", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_3"] .. lagWorld .." ms", 0.8, 0.8, 0.8)
	GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)
	GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_4"] .. RoundDec(down,2) .. " Kbps", 0.8, 0.8, 0.8)
	GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_5"] .. RoundDec(up,2) .. " Kbps", 0.8, 0.8, 0.8)
	GameTooltip:AddLine(" ", 0.8, 0.8, 0.8)

	for i = 1, gw_numAddons do
		gw_addonMemory = gw_addonMemory + GetAddOnMemoryUsage(i)
	end

	GameTooltip:AddLine(GwLocalization["FPS_TOOLTIP_6"] .. RoundDec(gw_addonMemory / 1024, 2) .. " MB", 0.8, 0.8, 0.8)

	for i = 1, gw_numAddons do
		if type(gw_addonMemoryArray[i]) ~= "table" then
            gw_addonMemoryArray[i] = {}
        end
		gw_addonMemoryArray[i]["addonIndex"] = i
		gw_addonMemoryArray[i]["addonMemory"] = GetAddOnMemoryUsage(i)
	end

	table.sort( gw_addonMemoryArray, function(a, b) return a["addonMemory"] > b["addonMemory"] end)

	for k, v in pairs(gw_addonMemoryArray) do
			if v["addonIndex"] ~= 0 and (IsAddOnLoaded(v["addonIndex"]) and v["addonMemory"] ~= 0) then
				gw_addonMemory = RoundDec(v["addonMemory"] / 1024, 2)
                if gw_addonMemory ~= "0.00" then
                    GameTooltip:AddLine("(" .. gw_addonMemory .. " MB) " .. GetAddOnInfo(v["addonIndex"]), 0.8, 0.8, 0.8)
                end
			end
	end
    GameTooltip:Show()
end

local function gw_microButtonHookToolTip(frame, text, action)
    if frame == nil then return end
    frame:SetScript("OnEnter", function()
       gw_setToolTipForShow(frame, text, action)
      end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function microMenu_OnUpdate(self, elapsed)
    self.gw_LastFadeCheck = self.gw_LastFadeCheck - elapsed
    if self.gw_LastFadeCheck > 0 then
        return
    end
    self.gw_LastFadeCheck = 0.1
    if not self:IsShown() then return end

    if self:IsMouseOver(100, -100, -100, 100) then
        if not self.gw_FadeShowing then
            microMenuFrameShow(self, self:GetName())
        end
    elseif self.gw_FadeShowing then
        microMenuFrameHide(self, self:GetName())
    end
end

local function LoadMicroMenu()
    local mi = 1
    for k,v in pairs(MICRO_BUTTONS) do
        CUSTOM_MICRO_BUTTONS[mi] = v
        if v == "CharacterMicroButton" then
            mi = mi + 1
            CUSTOM_MICRO_BUTTONS[mi] = "BagMicroButton"
        end
        mi = mi + 1
    end

    for k,v in pairs(CUSTOM_MICRO_BUTTONS) do
        create_micro_button(v)
    end
    if GetSetting("USE_CHARACTER_WINDOW") then
       GwMicroButtonCharacterMicroButton:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
       GwMicroButtonCharacterMicroButton:SetAttribute(
           "_onclick",
           [=[
          self:GetFrameRef('GwCharacterWindow'):SetAttribute('windowPanelOpen',1)
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
           self:GetFrameRef('GwCharacterWindow'):SetAttribute('windowPanelOpen',2)
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
--    GwMicroButtonCharacterMicroButton:SetScript("OnClick", function() ToggleCharacter("PaperDollFrame") end)
    GwMicroButtonBagMicroButton:SetScript("OnClick", function() ToggleAllBags() end)
--    GwMicroButtonSpellbookMicroButton:SetScript("OnClick", function() ToggleSpellBook(BOOKTYPE_SPELL) end)
--    GwMicroButtonTalentMicroButton:SetScript("OnClick", function() ToggleTalentFrame() end)
    GwMicroButtonQuestLogMicroButton:SetScript("OnClick", function() ToggleQuestLog() end)
    GwMicroButtonSocialsMicroButton:SetScript("OnClick", function() ToggleFriendsFrame() end)
    GwMicroButtonWorldMapMicroButton:SetScript("OnClick", function() ToggleWorldMap() end)
    GwMicroButtonHelpMicroButton:SetScript("OnClick", function() ToggleHelpFrame() end)

    GwMicroButtonMainMenuMicroButton:SetScript("OnClick", function()
        if ( not GameMenuFrame:IsShown() ) then
            if ( VideoOptionsFrame:IsShown() ) then
                VideoOptionsFrameCancel:Click()
            elseif ( AudioOptionsFrame:IsShown() ) then
                AudioOptionsFrameCancel:Click()
            elseif ( InterfaceOptionsFrame:IsShown() ) then
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
    end)

    gw_microButtonHookToolTip(GwMicroButtonCharacterMicroButton, CHARACTER_BUTTON, "TOGGLECHARACTER0")
    gw_microButtonHookToolTip(GwMicroButtonBagMicroButton, INVENTORY_TOOLTIP, "OPENALLBAGS")
    gw_microButtonHookToolTip(GwMicroButtonSpellbookMicroButton, SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
    gw_microButtonHookToolTip(GwMicroButtonTalentMicroButton, TALENTS_BUTTON, "TOGGLETALENTS")
    gw_microButtonHookToolTip(GwMicroButtonQuestLogMicroButton, QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
    gw_microButtonHookToolTip(GwMicroButtonSocialsMicroButton, SOCIAL_BUTTON, "TOGGLESOCIAL")
    gw_microButtonHookToolTip(GwMicroButtonWorldMapMicroButton, WORLDMAP_BUTTON, "TOGGLEWORLDMAP")
    gw_microButtonHookToolTip(GwMicroButtonHelpMicroButton, PETITION_GAME_MASTER, "TOGGLE_HELP")

    GwMicroButtonBagMicroButton.interval = 0
    GwMicroButtonBagMicroButton:HookScript(
        "OnUpdate",
        function(self, elapsed)
            self.interval = self.interval - elapsed
            if self.interval > 0 then
                return
            end

            self.interval = 0.5
            updateBagButton()
        end
    )

    GwMicroButtonSocialsMicroButton.interval = 0
    GwMicroButtonSocialsMicroButton:SetScript("OnUpdate", function(self, elapsed)
        if self.interval > 0 then
            self.interval = self.interval - elapsed
            return
        end
        self.interval = 15.0
        GuildRoster()
    end)
    GwMicroButtonSocialsMicroButton:SetScript("OnEvent", updateGuildButton)
    GwMicroButtonSocialsMicroButton:RegisterEvent("GUILD_ROSTER_UPDATE")

    GwMicroButtonMainMenuMicroButton:SetScript('OnEnter', function()
        GwMicroButtonMainMenuMicroButton:SetScript('OnUpdate', LatencyInfoToolTip)
        GameTooltip:SetOwner(GwMicroButtonMainMenuMicroButton, "ANCHOR_CURSOR", 0, ANCHOR_BOTTOMLEFT)
    end)

    GwMicroButtonMainMenuMicroButton:SetScript('OnLeave', function()
        GwMicroButtonMainMenuMicroButton:SetScript('OnUpdate', nil)
        GameTooltip:Hide()
    end)

    -- if set to fade micro menu, add fader
    if GetSetting("FADE_MICROMENU") then
        microButtonFrame.gw_LastFadeCheck = -1
        microButtonFrame.gw_FadeShowing = true
        microButtonFrame:SetScript("OnUpdate", microMenu_OnUpdate)
    end
end
GW.LoadMicroMenu = LoadMicroMenu
