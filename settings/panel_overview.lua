local _, GW = ...
local L = GW.L
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local SetSetting = GW.SetSetting
local AddForProfiling = GW.AddForProfiling
local settingMenuToggle = GW.settingMenuToggle

--copied from character.lua needs to be removed later
local function CharacterMenuButton_OnLoad(self, odd)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end
    self:GetFontString():SetTextColor(255 / 255, 241 / 255, 209 / 255)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
end

local welcome_OnClick = function(self)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowWelcomePanel()
    --Save current Version
    SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
end
AddForProfiling("panel_modules", "welcome_OnClick", welcome_OnClick)

local statusReport_OnClick = function(self)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowStatusReport()
end
AddForProfiling("panel_modules", "statusReport_OnClick", statusReport_OnClick)

local creditst_OnClick = function(self)
    if self.settings then
        self.settings:Hide()
    end
    GW.ShowCredits()
end
AddForProfiling("panel_modules", "creditst_OnClick", creditst_OnClick)

local function getChangeLogIcon(self,tag)

  if tag==GW.CHANGELOGS_TYPES.bug then
    self:SetTexCoord(0,0.5,0,1)
    return
  end
  self:SetTexCoord(0.5,1,0,1)

end

local function LoadOverviewPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsSplashPanelTmpl")


    CharacterMenuButton_OnLoad(p.menu.welcomebtn,true)
    CharacterMenuButton_OnLoad(p.menu.keybindingsbtn,false)
    CharacterMenuButton_OnLoad(p.menu.movehudbtn,true)
    CharacterMenuButton_OnLoad(p.menu.discordbtn,false)
    CharacterMenuButton_OnLoad(p.menu.reportbtn,true)
    CharacterMenuButton_OnLoad(p.menu.creditsbtn,false)


    p.header:SetFont(DAMAGE_TEXT_FONT, 30)
    p.header:SetTextColor(1,1,1)
    p.header:SetText(L["Changelog"])
    p.header:ClearAllPoints()
    p.header:SetPoint("BOTTOMLEFT",p.pageblock,"TOPLEFT",20,10)

    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Enable or disable the modules you need and don't need."])
    p.sub:Hide()

    p.menu.welcomebtn:SetParent(p)
    p.menu.welcomebtn.settings = sWindow
    p.menu.welcomebtn:SetText(L["Setup"])
    p.menu.welcomebtn:SetScript("OnClick", welcome_OnClick)

    p.menu.reportbtn:SetParent(p)
    p.menu.reportbtn.settings = sWindow
    p.menu.reportbtn:SetText(L["System info"])
    p.menu.reportbtn:SetScript("OnClick", statusReport_OnClick)

    p.menu.creditsbtn:SetParent(p)
    p.menu.creditsbtn.settings = sWindow
    p.menu.creditsbtn:SetText(L["Credits"])
    p.menu.creditsbtn:SetScript("OnClick", creditst_OnClick)

    sWindow.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    sWindow.versionString:SetFont(UNIT_NAME_FONT, 12)
    sWindow.versionString:SetText(GW.VERSION_STRING)
    sWindow.headerString:SetText(CHAT_CONFIGURATION)

    sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
    sWindow.headerBreadcrumb:SetFont(DAMAGE_TEXT_FONT, 14)
    sWindow.headerBreadcrumb:SetText(CHAT_CONFIGURATION)

    p.menu.movehudbtn:SetText(L["Move HUD"])

    p.menu.keybindingsbtn:SetText(KEY_BINDING)
    p.menu.discordbtn:SetText(L["Join Discord"])

    local fnGSWMH_OnClick = function()
        if InCombatLockdown() then
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
            return
        end
        GW.moveHudObjects(GW.MoveHudScaleableFrame)
    end
    local fnGSWD_OnClick = function()
        StaticPopup_Show("JOIN_DISCORD")
    end
    local fmGSWKB_OnClick = function()
        sWindow:Hide()
        GW.DisplayHoverBinding()
    end
    GwSettingsWindowMoveHud = p.menu.movehudbtn
    p.menu.movehudbtn:SetScript("OnClick", fnGSWMH_OnClick)
    p.menu.discordbtn:SetScript("OnClick", fnGSWD_OnClick)
    p.menu.keybindingsbtn:SetScript("OnClick", fmGSWKB_OnClick)

    createCat(L["Modules"], L["Enable and disable components"], p, "Interface\\AddOns\\GW2_UI\\textures\\uistuff\\tabicon_overview", nil, {p},nil,nil,true)

    InitPanel(p, false)
    p:SetScript("OnShow", function()
      settingMenuToggle(false)
      sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
      sWindow.headerBreadcrumb:SetText(OVERVIEW)
    end)

    p.scroll:SetScrollChild(p.scroll.scrollchild)

    local zebra = false
    local index = 1
    local margin = 0
    local size = 0
    local previousElement = nil

    for i=1,#GW.GW_CHANGELOGS do

      local versionNumber = GW.GW_CHANGELOGS[i].version
      local changes = GW.GW_CHANGELOGS[i].changes

      local changelogtitle = CreateFrame("Frame", nil, p.scroll.scrollchild, "GWChangelogVersionRow")
      if not previousElement then
        changelogtitle:SetPoint("TOPLEFT",p.scroll.scrollchild,"TOPLEFT",0,-margin)
      else
         changelogtitle:SetPoint("TOPLEFT",previousElement,"BOTTOMLEFT",0,0)
      end
      zebra  = (index % 2)==1 or false
      if zebra then
        changelogtitle.background:Hide()
      end
      changelogtitle.text:SetFont(DAMAGE_TEXT_FONT, 14)
      changelogtitle.text:SetTextColor(255 / 255, 241 / 255, 209 / 255)
      changelogtitle.text:SetText(versionNumber)
      previousElement = changelogtitle
      index = index + 1
      size = size + changelogtitle:GetHeight()
      for _,change in pairs(changes) do

        local iconTag = change[1]
        local text = change[2]
        zebra  = (index % 2)==1 or false

        local entry = CreateFrame("Frame", nil, p.scroll.scrollchild, "GWChangelogRow")
        entry:SetPoint("TOPLEFT",previousElement,"BOTTOMLEFT",0,0)
        entry.text:SetFont(UNIT_NAME_FONT, 12)
        entry.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
        entry.text:SetText(text)
        getChangeLogIcon(entry.icon,iconTag)
        entry:SetHeight(math.max(36,entry.text:GetStringHeight() + 20))

        if zebra then
          entry.background:Hide()
        end

        previousElement = entry
        index = index + 1
        size = size + entry:GetHeight()
      end

    end

    local scrollMax = max(0, size - p.scroll:GetHeight() + 50)

    p.scroll.scrollchild:SetHeight(p.scroll:GetHeight())
    p.scroll.scrollchild:SetWidth(p.scroll:GetWidth() - 20)
    p.scroll.slider:SetMinMaxValues(0, scrollMax)
    --Calculate how big the thumb is this is IMPORTANT for UX :<
    p.scroll.slider.thumb:SetHeight(p.scroll.slider:GetHeight() * (p.scroll:GetHeight() / (scrollMax + p.scroll:GetHeight())) )

    p.scroll.slider:SetValue(1)
    p.scroll.maxScroll = scrollMax
end
GW.LoadOverviewPanel = LoadOverviewPanel
