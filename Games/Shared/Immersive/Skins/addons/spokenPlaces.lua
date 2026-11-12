---@class GW2
local GW = select(2, ...)

local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png"
local PAGE_TEXTURE = "Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background.png"
local PAGE_COORDS = {0, 0.70703125, 0, 0.580078125}

local pageSkin = {
    GetStyle = function() return "modern" end,
    GetAccentColor = function() return GW.Colors.TextColors.LightHeader:GetRGB() end,
    Button = function(button) button:GwSkinButton(false, true) end,
    WhiteButtonLabel = function(button)
        local label = button:GetFontString()
        if label then label:SetTextColor(GW.Colors.FallbackWhite:GetRGB()) end
    end,
}

local function RestoreFrayedPictures(body)
    if not body.cleanPictures then return end
    body.cleanPictures = false
    if body.pictureEdge then
        body.pictureEdge:Hide()
        body.pictureEdge = nil
    end
    if body.pictureMask and body.picture and body.picture.AddMaskTexture then
        body.picture:AddMaskTexture(body.pictureMask)
    end
    if body.pictureFile and body.SetPicture then
        body:SetPicture(body.pictureFile, body.pictureMaskFile)
    end
    if body.lastParts and body.SetParts then
        body:SetParts(body.lastParts)
    elseif body.lastText and body.SetText then
        body:SetText(body.lastText)
    end
end

local function HideTopFadeAtRest(body)
    if not (body.UpdateFade and body.UpdateScrollBar) then return end
    hooksecurefunc(body, "UpdateFade", function()
        if (body.frame:GetVerticalScroll() or 0) > 1 then return end
        for _, strip in ipairs(body.strips or {}) do
            if strip.fadeEdge == "TOP" then
                strip:Hide()
            end
        end
    end)
    hooksecurefunc(body, "UpdateScrollBar", function()
        body:UpdateFade()
    end)
    body:UpdateFade()
end

-- its own thin bar: our thumb over its art, it keeps sizing and moving the thumb
local function SkinScrollBar(body)
    if not (body.bar and body.thumb) then return end
    body.bar:DisableDrawLayer("BACKGROUND")
    body.thumb:DisableDrawLayer("ARTWORK")
    local tex = body.thumb:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png")
    tex:SetAllPoints()
end

-- the round buttons on the title line (play, report, open in the compendium) as square ones
local function SkinRoundButton(button)
    if not (button and button.ring and button.glyph) then return end
    if button.mask and button.glyph.RemoveMaskTexture then
        button.glyph:RemoveMaskTexture(button.mask)
    end
    button.ring:SetAlpha(0)
    if button.vignette then
        button.vignette:SetAlpha(0)
    end
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
end

-- spoken places is not ours, a later version may drop what the skin reaches into, then the skin stays plainer
local function SkinPage(page)
    if page.Darken then
        page:Darken(pageSkin)
    end
    if page.bg then
        page.bg:SetTexture(PAGE_TEXTURE)
        page.bg:SetTexCoord(unpack(PAGE_COORDS))
        page.bg:SetAlpha(1)
    end
    local body = page.body
    if body then
        RestoreFrayedPictures(body)
        if body.SetFadeSource then
            body:SetFadeSource(page.frame, PAGE_TEXTURE, PAGE_COORDS)
        end
        HideTopFadeAtRest(body)
        SkinScrollBar(body)
    end
    SkinRoundButton(page.play)
    SkinRoundButton(page.report)
    for _, button in ipairs(page.extra or {}) do
        SkinRoundButton(button)
    end
end

-- in our map window the panel is a part of it, like the event tracker on retail: header and background
-- reach over it, the map close button goes along to the right edge
local function DockToMap(panel)
    local map = WorldMapFrame
    local header = map.gwHeader
    local close = map.BorderFrame.CloseButton
    local headerArtWidth = header.BGRIGHT:GetWidth()

    local anchoring = false
    local function Anchor()
        anchoring = true
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", map, "TOPRIGHT", 0, -32)
        panel:SetPoint("BOTTOMLEFT", map, "BOTTOMRIGHT", 0, 0)
        anchoring = false
    end
    -- spoken places lays the panel out again on every map change
    hooksecurefunc(panel, "SetPoint", function()
        if not anchoring then Anchor() end
    end)
    Anchor()

    local function UpdateWindow()
        local docked = panel:IsShown()
        header:SetPoint("BOTTOMRIGHT", docked and panel or map, "TOPRIGHT", 0, docked and 0 or -32)
        map.tex:SetPoint("BOTTOMRIGHT", docked and panel or map, "BOTTOMRIGHT", 0, 0)
        header.BGRIGHT:SetWidth(headerArtWidth + (docked and panel:GetWidth() or 0))
        if docked then
            close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, 30)
        else
            close:SetPoint("TOPRIGHT", map.BorderFrame, "TOPRIGHT", -10, -2)
        end
    end
    panel:HookScript("OnShow", UpdateWindow)
    panel:HookScript("OnHide", UpdateWindow)
    panel:HookScript("OnSizeChanged", UpdateWindow)
    UpdateWindow()

    if panel.TitleContainer then
        panel.TitleContainer:Hide()
    end
    -- folds the panel away, an arrow so it does not read as a second close button of the map
    GW.HandleNextPrevButton(panel.close, "left")
    panel.close:ClearAllPoints()
    panel.close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -2)

    -- the tab that opens it again like the tabs of the retail map; blizzards icon does not survive the
    -- stripping, it gets an own one like our other large side tabs
    local toggle = _G.SpokenPlacesPanelToggle
    if toggle and toggle.SelectedTexture then
        local file = toggle.Icon:GetTexture()
        GW.HandleTabs(toggle, "right")
        -- it only ever opens, the dark look of a chosen tab fits the window better than the light one
        toggle.tex:SetAlpha(0)
        toggle.Icon:SetAlpha(0)
        local icon = toggle:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(file)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetSize(30, 30)
        icon:SetPoint("CENTER", -3, 0)
    end
end

local function SkinPanel(panel)
    if panel.gwSkinned then return end
    panel.gwSkinned = true

    GW.HandlePortraitFrameArt(panel)
    panel:GwStripTextures()

    -- the classic map skin has another close button and header layout, there it stays an own window
    local docked = GW.isModern and WorldMapFrame.gwHeader ~= nil
    if docked then
        DockToMap(panel)
    else
        local title = panel.TitleContainer and panel.TitleContainer.TitleText
        GW.SkinSmallWindow(panel, title, WINDOW_ICON, panel.close)
    end

    if panel.rim then
        panel.rim:SetAlpha(0)
    end

    local page = panel.page and panel.page.page
    if page and page.frame then
        local holder = page.frame:GetParent()
        holder:ClearAllPoints()
        holder:SetPoint("TOPLEFT", docked and panel or panel.gwHeader, docked and "TOPLEFT" or "BOTTOMLEFT", 0, 0)
        holder:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
        SkinPage(page)
    end
end

local function TrySkinPanel()
    local panel = _G.SpokenPlacesPanel
    if panel and panel.page and panel.close then
        SkinPanel(panel)
    end
    return panel and panel.gwSkinned
end

-- the panel shows beside the world map, at the latest it exists when the map opens
local function LoadSpokenPlacesAddonSkin()
    if not (GW.settings.skins.spokenPlaces.enabled and (C_AddOns.IsAddOnLoaded("SpokenPlaces") or C_AddOns.IsAddOnLoaded("Spoken_Places"))) then return end

    if not TrySkinPanel() then
        GW.RegisterLoadHook(function() WorldMapFrame:HookScript("OnShow", TrySkinPanel) end, "Blizzard_WorldMap", WorldMapFrame)
    end
end
GW.LoadSpokenPlacesAddonSkin = LoadSpokenPlacesAddonSkin
