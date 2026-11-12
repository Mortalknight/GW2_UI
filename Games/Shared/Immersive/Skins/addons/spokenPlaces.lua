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
    end
end

local function SkinPanel(panel)
    if panel.gwSkinned then return end
    panel.gwSkinned = true

    GW.HandlePortraitFrameArt(panel)
    panel:GwStripTextures()

    local title = panel.TitleContainer and panel.TitleContainer.TitleText
    GW.SkinSmallWindow(panel, title, WINDOW_ICON, panel.close)

    if panel.rim then
        panel.rim:SetAlpha(0)
    end

    local page = panel.page and panel.page.page
    if page and page.frame then
        local holder = page.frame:GetParent()
        holder:ClearAllPoints()
        holder:SetPoint("TOPLEFT", panel.gwHeader, "BOTTOMLEFT", 0, 0)
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
