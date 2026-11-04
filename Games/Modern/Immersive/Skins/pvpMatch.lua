---@class GW2
local GW = select(2, ...)

-- retail and forever name a few parts differently, the content is the same
local function SkinContent(content, scrollBar, tabs)
    content:GwStripTextures()
    GW.AddDetailsBackground(content)
    local categories = content.ScrollCategories or content.scrollCategories
    if categories then
        categories:GwStripTextures()
    end
    GW.HandleTrimScrollBar(scrollBar)
    for _, tab in ipairs(tabs) do
        GW.HandleTabs(tab)
    end
end

local function SkinWindow(frame, closeButton)
    frame:GwStripTextures()
    GW.HandlePortraitFrameArt(frame)
    -- the opaque body of our windows, the tooltip background would let the world shine through
    local body = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    body:SetAllPoints()
    body:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background.png")
    frame:GwCreateBackdrop(GW.BackdropTemplates.OnlyBorder)
    closeButton:GwSkinButton(true)
    closeButton:SetSize(20, 20)
end

-- the scoreboard during the match (/run PVPMatchScoreboard:Show()) and the results at its end (/run PVPMatchResults:Show())
local function ApplyPVPMatchSkin()
    if not GW.settings.skins.pvpMatch.enabled then return end

    local scoreboard = PVPMatchScoreboard
    local content = scoreboard.Content
    local tabs = content.TabContainer.TabGroup
    SkinWindow(scoreboard, scoreboard.CloseButton or scoreboard.ClosePanelButton)
    SkinContent(content, content.ScrollBar, {tabs.Tab1, tabs.Tab2, tabs.Tab3})
    content.TabContainer:GwStripTextures()

    local results = PVPMatchResults
    content = results.content
    tabs = content.tabContainer.tabGroup
    SkinWindow(results, results.CloseButton)
    SkinContent(content, content.scrollBar, {tabs.tab1, tabs.tab2, tabs.tab3})
    content.tabContainer:GwStripTextures()

    local buttons = results.buttonContainer
    buttons.leaveButton:GwSkinButton(false, true)
    if buttons.requeueButton then
        buttons.requeueButton:GwSkinButton(false, true)
    end
end

local function LoadPVPMatchSkin()
    GW.RegisterLoadHook(ApplyPVPMatchSkin, "Blizzard_PVPMatch", PVPMatchScoreboard)
end
GW.LoadPVPMatchSkin = LoadPVPMatchSkin
