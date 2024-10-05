local _, GW = ...

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
    C_Timer.After(0.1, function()
        if frame and frame.MajorFactionList then
            GW.HandleTrimScrollBar(frame.MajorFactionList.ScrollBar)
            GW.HandleScrollControls(frame.MajorFactionList)
        end
    end)
end

local function ExpansionLadningPageSkin()
    GW.CreateFrameHeaderWithBody(ExpansionLandingPage, nil, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon", nil, nil, false, true)

    local factionList = LandingPageMajorFactionList
    if factionList then
        hooksecurefunc(factionList, "Create", DelayedMajorFactionList)
    end

    local overlay = ExpansionLandingPage.Overlay
    if overlay then
        for _, child in next, { overlay:GetChildren() } do
            child:GwStripTextures()

            if child.ScrollFadeOverlay then
                child.ScrollFadeOverlay:Hide()
            end

            if child.DragonridingPanel then
                HandlePanel(child)
            end
        end

        local landingOverlay = overlay.WarWithinLandingOverlay
        if landingOverlay then
            landingOverlay.CloseButton:GwSkinButton(true)
            landingOverlay.CloseButton:SetPoint("TOPRIGHT", 35, 30)
        end
    end
end

local function LoadExpansionLadningPageSkin()
    if not GW.settings.EXPANSION_LANDING_PAGE_SKIN_ENABLED then return end
    GW.RegisterLoadHook(ExpansionLadningPageSkin, "Blizzard_ExpansionLandingPage", ExpansionLandingPage)
end
GW.LoadExpansionLadningPageSkin = LoadExpansionLadningPageSkin
