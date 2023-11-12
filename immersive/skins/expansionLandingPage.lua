local _, GW = ...
local GetSetting = GW.GetSetting

local function HandlePanel(panel)
    if panel.DragonridingPanel then
        panel.DragonridingPanel.SkillsButton:GwSkinButton(false, true)
    end

    if panel.CloseButton then
        panel.CloseButton:GwSkinButton(true)
        panel.CloseButton:SetPoint("TOPRIGHT", -3, -2)
    end
end

local function DelayedMajorFactionList(frame)
    GW.HandleTrimScrollBar(frame.MajorFactionList.ScrollBar, true)
    GW.HandleScrollControls(frame.MajorFactionList)
end

local function ExpansionLadningPageSkin()
    GW.CreateFrameHeaderWithBody(ExpansionLandingPage, nil, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon")

    if ExpansionLandingPage.Overlay then
        for _, child in next, {ExpansionLandingPage.Overlay:GetChildren()} do
            child:GwStripTextures()

            if child.ScrollFadeOverlay then
                child.ScrollFadeOverlay:Hide()
            end

            if child.DragonridingPanel then
                HandlePanel(child)
            end

            if child.MajorFactionList then
                DelayedMajorFactionList(child)
            end
        end
    end
end

local function LoadExpansionLadningPageSkin()
    if not GetSetting("EXPANSION_LANDING_PAGE_SKIN_ENABLED") then return end
    GW.RegisterLoadHook(ExpansionLadningPageSkin, "Blizzard_ExpansionLandingPage", ExpansionLandingPage)
end
GW.LoadExpansionLadningPageSkin = LoadExpansionLadningPageSkin