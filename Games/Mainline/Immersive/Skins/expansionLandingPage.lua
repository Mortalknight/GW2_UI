---@class GW2
local GW = select(2, ...)

local skinnedLists = setmetatable({}, {__mode = "k"})

local function SkinFactionList(owner)
    local list = owner and owner.MajorFactionList
    if list and not skinnedLists[list] then
        skinnedLists[list] = true
        GW.HandleTrimScrollBar(list.ScrollBar)
        GW.HandleScrollControls(list)
    end
end

-- Create hands the new list to its caller, which puts it on the parent right after
local function SkinFactionListSoon(parent)
    RunNextFrame(function() SkinFactionList(parent) end)
end

local function SkinCloseButton(button)
    button:GwSkinButton(true)
    button:SetSize(20, 20)
end

-- the overlay of the newest expansion; blizzard creates it when the page first needs it
local skinnedOverlays = setmetatable({}, {__mode = "k"})
local function SkinOverlays()
    for _, overlay in ipairs({ExpansionLandingPage.Overlay:GetChildren()}) do
        if not skinnedOverlays[overlay] then
            skinnedOverlays[overlay] = true
            overlay:GwStripTextures()
            if overlay.ScrollFadeOverlay then
                overlay.ScrollFadeOverlay:Hide()
            end
            if overlay.DragonridingPanel then
                overlay.DragonridingPanel.SkillsButton:GwSkinButton(false, true)
            end
            if overlay.CloseButton then
                SkinCloseButton(overlay.CloseButton)
            end
            SkinFactionListSoon(overlay)
        end
    end
end

local function ExpansionLadningPageSkin()
    GW.CreateFrameHeaderWithBody(ExpansionLandingPage, nil, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", nil, nil, false, true)

    if LandingPageMajorFactionList then
        hooksecurefunc(LandingPageMajorFactionList, "Create", SkinFactionListSoon)
    end
    SkinOverlays()
    EventRegistry:RegisterCallback("ExpansionLandingPage.OverlayChanged", SkinOverlays, ExpansionLandingPage)
end

local function LoadExpansionLadningPageSkin()
    if not GW.settings.skins.expansionLandingPage.enabled then return end
    GW.RegisterLoadHook(ExpansionLadningPageSkin, "Blizzard_ExpansionLandingPage", ExpansionLandingPage)
end
GW.LoadExpansionLadningPageSkin = LoadExpansionLadningPageSkin
