---@class GW2
local GW = select(2, ...)

--middle left right
local function SkinTextBox(middleTex, leftTex, rightTex, topTex, bottomTex, leftOffset, rightOffset, noTop, frame)
    if middleTex then
        middleTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
        middleTex:ClearAllPoints()
        middleTex:SetPoint("TOPLEFT", -(leftOffset or 0), 0)
        middleTex:SetPoint("BOTTOMRIGHT", (rightOffset or 0), 0)
        middleTex:SetAlpha(1)
    elseif frame then
        frame.middleTex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
        frame.middleTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
        frame.middleTex:ClearAllPoints()
        frame.middleTex:SetPoint("TOPLEFT", -(leftOffset or 0), 0)
        frame.middleTex:SetPoint("BOTTOMRIGHT", (rightOffset or 0), 0)
        frame.middleTex:SetAlpha(1)
    end
    if leftTex then
        leftTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixelvertical.png")
        leftTex:SetWidth(2)
        leftTex:ClearAllPoints()
        leftTex:SetPoint("TOPLEFT", -(leftOffset or 0), 0)
        leftTex:SetPoint("BOTTOMLEFT", -(leftOffset or 0), 0)
        leftTex:SetTexCoord(0,1,1,0)
        leftTex:SetAlpha(1)
    elseif frame then
        frame.leftTex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
        frame.leftTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixelvertical.png")
        frame.leftTex:SetWidth(2)
        frame.leftTex:ClearAllPoints()
        frame.leftTex:SetPoint("TOPLEFT", -(leftOffset or 0), 0)
        frame.leftTex:SetPoint("BOTTOMLEFT", -(leftOffset or 0), 0)
        frame.leftTex:SetTexCoord(0,1,1,0)
        frame.leftTex:SetAlpha(1)
    end
    if rightTex then
        rightTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixelvertical.png")
        rightTex:SetWidth(1)
        rightTex:ClearAllPoints()
        rightTex:SetPoint("TOPRIGHT", (rightOffset or 0), 0)
        rightTex:SetPoint("BOTTOMRIGHT", (rightOffset or 0), 0)
        rightTex:SetAlpha(1)
    elseif frame then
        frame.rightTex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
        frame.rightTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixelvertical.png")
        frame.rightTex:SetWidth(1)
        frame.rightTex:ClearAllPoints()
        frame.rightTex:SetPoint("TOPRIGHT", (rightOffset or 0), 0)
        frame.rightTex:SetPoint("BOTTOMRIGHT", (rightOffset or 0), 0)
        frame.rightTex:SetAlpha(1)
        rightTex = frame.rightTex
    end

    local pframe = rightTex and rightTex:GetParent()
    if pframe and topTex then
        topTex:ClearAllPoints()
        topTex:SetHeight(2)
        topTex:SetPoint("BOTTOMLEFT", pframe, "TOPLEFT", -(leftOffset or 0), 0)
        topTex:SetPoint("BOTTOMRIGHT", pframe, "TOPRIGHT", (rightOffset or 0), 0)
        topTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
        topTex:SetAlpha(1)
    elseif pframe and not noTop then
        local top = pframe:CreateTexture(nil, "BACKGROUND", nil, 0)
        pframe.top = top
        top:ClearAllPoints()
        top:SetHeight(2)
        top:SetPoint("BOTTOMLEFT", pframe, "TOPLEFT", -(leftOffset or 0), 0)
        top:SetPoint("BOTTOMRIGHT", pframe, "TOPRIGHT", (rightOffset or 0), 0)
        top:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
        if middleTex then return end
    end
    if bottomTex and pframe then
        bottomTex:ClearAllPoints()
        bottomTex:SetHeight(2)
        bottomTex:SetPoint("TOPLEFT",pframe,"BOTTOMLEFT", -(leftOffset or 0), 0)
        bottomTex:SetPoint("TOPRIGHT",pframe,"BOTTOMRIGHT",( rightOffset or 0), 0)
        bottomTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
        bottomTex:SetTexCoord(0, 1, 1, 0)
        bottomTex:SetAlpha(1)
    elseif pframe and not noTop then
        local bottom = pframe:CreateTexture(nil, "BACKGROUND", nil, 0)
        pframe.bottom = bottom
        bottom:ClearAllPoints()
        bottom:SetHeight(2)
        bottom:SetPoint("TOPLEFT", pframe, "BOTTOMLEFT", -(leftOffset or 0), 0)
        bottom:SetPoint("TOPRIGHT", pframe, "BOTTOMRIGHT", (rightOffset or 0), 0)
        bottom:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
        bottom:SetTexCoord(0, 1, 1, 0)
    end
end
GW.SkinTextBox = SkinTextBox

local function MutateInaccessableObject(frame, objType, func)
    local r = {frame:GetRegions()}

    if frame == nil or objType == nil or func == nil then
        return
    end

    for _, c in pairs(r) do
        if c:GetObjectType() == objType then
            func(c)
        end
    end
end
GW.MutateInaccessableObject = MutateInaccessableObject

-- the breadcrumb bars of the encounter journal and the world map, where their skin is on
local NAV_BAR_SKINS = {EncounterJournal = "encounterJournal", WorldMapFrame = "worldmap"}

-- blizzard lets the crumbs overlap, ours sit a pixel apart; SetPoint is followed by a hook,
-- moving them in blizzards place would taint
local placing = false
local function PlaceCrumb(button, point, anchor, relativePoint, _, y)
    if placing then return end
    placing = true
    button:SetPoint(point, anchor, relativePoint, -1, y)
    placing = false
end

local function PlaceNavBar(bar, _, anchor)
    if placing then return end
    placing = true
    bar:SetPoint("TOPLEFT", anchor, "TOPLEFT", 1, -47)
    placing = false
end

local function SkinCrumb(button, index)
    if button.gwSkinned then return end
    button.gwSkinned = true

    button:GwStripTextures()
    local text = button:GetFontString()
    text:SetTextColor(1, 1, 1, 1)
    text:SetShadowOffset(0, 0)

    button.tex = button:CreateTexture(nil, "BACKGROUND")
    button.tex:SetAllPoints(button)
    button.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightinner.png")
    button.borderFrame = CreateFrame("Frame", nil, button, "GwLightButtonBorder")

    local menuArrow = button.MenuArrowButton
    if menuArrow then
        menuArrow:GwStripTextures()
        if menuArrow.Art then
            menuArrow.Art:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
            menuArrow.Art:SetTexCoord(0, 1, 0, 1)
            menuArrow.Art:SetSize(16, 16)
        end
    end

    -- the first crumb is the home button, it keeps its place
    if index > 1 then
        PlaceCrumb(button, button:GetPoint())
        hooksecurefunc(button, "SetPoint", PlaceCrumb)
    end
end

-- also called by NavBar_AddButton; skins every crumb not done yet, keepPosition moves the bar itself
local function HandleNavBarButtons(bar, _, keepPosition)
    local setting = NAV_BAR_SKINS[bar:GetParent():GetName()]
    if setting and not GW.settings.skins[setting].enabled then return end

    for index, button in ipairs(bar.navList) do
        SkinCrumb(button, index)
    end
    if keepPosition then
        PlaceNavBar(bar, bar:GetPoint())
        hooksecurefunc(bar, "SetPoint", PlaceNavBar)
    end
end
GW.HandleNavBarButtons = HandleNavBarButtons
hooksecurefunc("NavBar_AddButton", HandleNavBarButtons)

-- the art of PortraitFrameTemplate frames and the border pieces of their inset
local PORTRAIT_ART = {"Portrait", "portrait", "PortraitOverlay", "ArtOverlayFrame"}
local INSET_ART = {
    "InsetBorderTop", "InsetBorderTopLeft", "InsetBorderTopRight", "InsetBorderBottom", "InsetBorderBottomLeft",
    "InsetBorderBottomRight", "InsetBorderLeft", "InsetBorderRight", "Bg",
}

local function HandlePortraitFrame(frame, createBackdrop)
    local name = frame:GetName()
    frame:GwStripTextures()

    for _, key in ipairs(PORTRAIT_ART) do
        local art = frame[key] or name and _G[name .. key]
        if art then
            art:SetAlpha(0)
        end
    end
    local inset = frame.Inset or name and _G[name .. "Inset"]
    if inset then
        for _, key in ipairs(INSET_ART) do
            if inset[key] then
                inset[key]:Hide()
            end
        end
    end

    if frame.CloseButton then
        frame.CloseButton:GwSkinButton(true)
        frame.CloseButton:SetSize(20, 20)
    end
    if createBackdrop and not frame.backdrop then
        frame:GwCreateBackdrop({
            edgeFile = "",
            bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png",
            edgeSize = 1
        }, true, 50, 50, nil, 25)
    end
end
GW.HandlePortraitFrame = HandlePortraitFrame

-- PortraitFrameTemplate/ButtonFrameTemplate frames draw their border either as a NineSlice
-- child frame or as a set of named regions. GwStripTextures can not get rid of them reliably:
-- the NineSlice pieces are (re)created by NineSliceUtil.ApplyLayout after we skinned the frame
-- and atlas based art survives a SetTexture() call. Hide the art itself instead.
local portraitFrameArt = {
    "NineSlice",
    "Bg",
    "TitleBg",
    "TopTileStreaks",
    "PortraitContainer",
    "portrait",
    "PortraitFrame",
    "PortraitOverlay",
    "TopLeftCorner",
    "TopRightCorner",
    "TopBorder",
    "BotLeftCorner",
    "BotRightCorner",
    "BottomBorder",
    "LeftBorder",
    "RightBorder",
    "BtnCornerLeft",
    "BtnCornerRight",
    "ButtonBottomBorder",
}

local function HandlePortraitFrameArt(frame)
    if not frame then return end

    local name = frame.GetName and frame:GetName()
    for _, key in ipairs(portraitFrameArt) do
        local art = frame[key] or (name and _G[name .. key])
        if art and art.Hide then
            art:Hide()
        end
    end
end
GW.HandlePortraitFrameArt = HandlePortraitFrameArt

local function SkinArrowDropdown(dropdown)
    if not dropdown or dropdown.gwSkinned then return end
    dropdown:GwSkinButton(false, false, false, true, true, true)
    dropdown:SetSize(20, 20)
    if dropdown.Icon then dropdown.Icon:SetAlpha(0) end
    if dropdown.Arrow then dropdown.Arrow:SetAlpha(0) end
    if dropdown.GetHighlightTexture and dropdown:GetHighlightTexture() then
        dropdown:GetHighlightTexture():SetAlpha(0)
    end
    local arrow = dropdown:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("CENTER")
    arrow:SetSize(16, 16)
    arrow:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
    dropdown.gwArrow = arrow
end
GW.SkinArrowDropdown = SkinArrowDropdown

local function HandleIcon(icon, backdrop, backdropTexture, isBorder)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    if backdrop and not icon.backdrop then
        icon:GwCreateBackdrop(backdropTexture, isBorder)
    end
end
GW.HandleIcon = HandleIcon

do
    -- atlas borders tell the quality by their name, the others by their vertex color
    local ATLAS_QUALITY = {
        ["auctionhouse-itemicon-border-gray"] = Enum.ItemQuality.Poor,
        ["auctionhouse-itemicon-border-white"] = Enum.ItemQuality.Common,
        ["auctionhouse-itemicon-border-green"] = Enum.ItemQuality.Uncommon,
        ["auctionhouse-itemicon-border-blue"] = Enum.ItemQuality.Rare,
        ["auctionhouse-itemicon-border-purple"] = Enum.ItemQuality.Epic,
        ["auctionhouse-itemicon-border-orange"] = Enum.ItemQuality.Legendary,
        ["auctionhouse-itemicon-border-artifact"] = Enum.ItemQuality.Artifact,
        ["auctionhouse-itemicon-border-account"] = Enum.ItemQuality.Heirloom,
        ["Professions-Slot-Frame"] = Enum.ItemQuality.Common,
        ["Professions-Slot-Frame-Green"] = Enum.ItemQuality.Uncommon,
        ["Professions-Slot-Frame-Blue"] = Enum.ItemQuality.Rare,
        ["Professions-Slot-Frame-Epic"] = Enum.ItemQuality.Epic,
        ["Professions-Slot-Frame-Legendary"] = Enum.ItemQuality.Legendary,
        ["loottab-set-itemborder-green"] = Enum.ItemQuality.Uncommon,
        ["loottab-set-itemborder-blue"] = Enum.ItemQuality.Rare,
        ["loottab-set-itemborder-purple"] = Enum.ItemQuality.Epic,
        ["loottab-set-itemborder-orange"] = Enum.ItemQuality.Legendary,
        ["loottab-set-itemborder-artifact"] = Enum.ItemQuality.Artifact,
    }

    -- the blizzard border stays hidden, our backdrop shows what it would; kept out of blizzards tables
    local backdrops = setmetatable({}, {__mode = "k"})
    local emptyColors = setmetatable({}, {__mode = "k"})
    local wantsShown = setmetatable({}, {__mode = "k"})
    local hidingBorder -- our own Hide call, its hook must not count as blizzards

    local function UpdateBackdropColor(border)
        local backdrop = backdrops[border]
        local quality = ATLAS_QUALITY[border:GetAtlas()]
        if not wantsShown[border] then
            local color = emptyColors[border]
            backdrop:SetBackdropBorderColor(color and color.r or 1, color and color.g or 1, color and color.b or 1)
        elseif quality then
            local color = GW.GetBagItemQualityColor(quality)
            backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
        else
            backdrop:SetBackdropBorderColor(border:GetVertexColor())
        end
    end

    local function SetWantsShown(border, shown)
        wantsShown[border] = shown or nil
        if shown then
            hidingBorder = border
            border:Hide()
            hidingBorder = nil
        end
        UpdateBackdropColor(border)
    end

    local function OnShow(border)
        SetWantsShown(border, true)
    end

    local function OnHide(border)
        if hidingBorder ~= border then
            SetWantsShown(border, false)
        end
    end

    -- backdrop: the parents backdrop by default; emptyColor for a slot without quality, white by default
    local function HandleIconBorder(border, backdrop, emptyColor)
        if not backdrop then
            local parent = border:GetParent()
            backdrop = parent.backdrop or parent
        end
        local hooked = backdrops[border] ~= nil
        backdrops[border] = backdrop
        emptyColors[border] = emptyColor
        if not hooked then
            hooksecurefunc(border, "Show", OnShow)
            hooksecurefunc(border, "Hide", OnHide)
            hooksecurefunc(border, "SetShown", SetWantsShown)
            hooksecurefunc(border, "SetAtlas", UpdateBackdropColor)
            hooksecurefunc(border, "SetVertexColor", UpdateBackdropColor)
        end
        SetWantsShown(border, border:IsShown())
    end
    GW.HandleIconBorder = HandleIconBorder
end

-- offsets in whole screen pixels (GW.mult each): cut towards zero, but never below one pixel
local function Scale(x)
    local m = GW.mult
    if m == 1 or x == 0 then
        return x
    end
    local pixels = math.max(1, math.floor(math.abs(x) / m + 1e-6))
    return (x < 0 and -pixels or pixels) * m
end
GW.Scale = Scale

local function SkinScrollArrow(button, direction)
    GW.HandleNextPrevButton(button, direction)
    for _, key in ipairs({"Texture", "Overlay"}) do
        if button[key] then
            button[key]:SetAlpha(0)
        end
    end
end

local function HandleScrollControls(self, specifiedScrollBar)
    local scrollBar = specifiedScrollBar and self[specifiedScrollBar] or self.ScrollBar
    if not scrollBar then return end
    scrollBar:SetWidth(20)

    scrollBar.Track:ClearAllPoints()
    scrollBar.Track:SetPoint("TOP", scrollBar, "TOP", 0, -12)
    scrollBar.Track:SetPoint("BOTTOM", scrollBar, "BOTTOM", 0, 12)
    scrollBar.Track:SetWidth(12)

    local bg = scrollBar.Track:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints()
    bg:SetPoint("TOP", 0, 0)
    bg:SetPoint("BOTTOM", 0, 0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")

    scrollBar.Back:ClearAllPoints()
    scrollBar.Back:SetPoint("BOTTOM", scrollBar, "TOP", 0, -13)
    scrollBar.Back:SetSize(12,12)
    bg = scrollBar.Back:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT",0,0)
    bg:SetPoint("BOTTOMRIGHT",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton.png")

    scrollBar.Forward:ClearAllPoints()
    scrollBar.Forward:SetPoint("TOP", scrollBar, "BOTTOM", 0, 13)
    scrollBar.Forward:SetSize(12,12)
    bg = scrollBar.Forward:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT",0,0)
    bg:SetPoint("BOTTOMRIGHT",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton.png")
    bg:SetTexCoord(0,1,1,0)
end
GW.HandleScrollControls = HandleScrollControls

-- blizzards trim scroll bars: our arrows, no track art, one stretched thumb texture
local function HandleTrimScrollBar(bar)
    if bar.gwSkinned then return end
    bar.gwSkinned = true

    bar:GwStripTextures()
    SkinScrollArrow(bar.Back, "up")
    SkinScrollArrow(bar.Forward, "down")
    if bar.Background then
        bar.Background:Hide()
    end
    if bar.Track then
        bar.Track:DisableDrawLayer("ARTWORK")
    end

    local thumb = bar:GetThumb()
    if thumb then
        for _, piece in ipairs({"Begin", "Middle", "End"}) do
            thumb[piece]:Hide()
        end
        thumb:DisableDrawLayer("BACKGROUND")
        thumb.gwTex = thumb:CreateTexture(nil, "ARTWORK")
        thumb.gwTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png")
        thumb.gwTex:SetAllPoints(thumb)
        thumb:SetWidth(12)
    end
end
GW.HandleTrimScrollBar = HandleTrimScrollBar

function GW.SkinSlimScrollBar(scrollBar)
    HandleTrimScrollBar(scrollBar)
    scrollBar:SetHideIfUnscrollable(true)
    scrollBar:SetWidth(6)
    local thumb = scrollBar:GetThumb()
    thumb:SetWidth(4)
    thumb.gwTex:SetVertexColor(1, 1, 1, 0.45)
end

-- the classic clients still give their text boxes the old panel slider, it makes way for mainlines minimal bar
function GW.SkinSlimScrollFrame(scrollFrame, parent)
    local scrollBar = scrollFrame.ScrollBar
    if scrollBar:IsObjectType("Slider") then
        scrollBar:Hide()
        scrollBar = CreateFrame("EventFrame", nil, parent or scrollFrame:GetParent(), "MinimalScrollBar")
        scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 6, -4)
        scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 6, 5)
        ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, scrollBar)
    end
    GW.SkinSlimScrollBar(scrollBar)
end

local ITEM_ICON_KEYS = {"icon", "Icon", "IconTexture", "iconTexture"}

local function FindItemIcon(button)
    for _, key in ipairs(ITEM_ICON_KEYS) do
        if button[key] then
            return button[key]
        end
    end
    local name = button:GetName()
    return name and (_G[name .. "IconTexture"] or _G[name .. "Icon"])
end

-- our backdrop and hover; the icon cropped inside the button, or the backdrop laid around the icon
local function HandleItemButton(button, setInside)
    if button.gwSkinned then return end
    button.gwSkinned = true

    local icon = FindItemIcon(button)
    -- stripping empties the icon as well, its texture comes back afterwards
    local texture = icon and icon:GetTexture()
    button:GwStripTextures()
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    button:GwStyleButton()
    if not icon then return end

    icon:SetTexture(texture)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    if setInside then
        icon:GwSetInside(button)
    else
        button.backdrop:GwSetOutside(icon, 1, 1)
    end
end
GW.HandleItemButton = HandleItemButton

-- blizzard builds many windows from frame pools; func runs once for every frame a pool hands out
do
    local skinnedPoolFrames = setmetatable({}, {__mode = "k"})
    function GW.SkinPoolFrames(pool, func)
        if not pool then return end
        for frame in pool:EnumerateActive() do
            if not skinnedPoolFrames[frame] then
                skinnedPoolFrames[frame] = true
                func(frame)
            end
        end
    end
end

-- the stepper arrows of AlphaHighlightButtonMixin buttons (barber, trading post); on press the mixin
-- sets a highlight atlas our arrow textures do not have, so the press scripts go
function GW.SkinStepperArrow(button, size)
    GW.HandleNextPrevButton(button)
    if size then
        button:SetSize(size, size)
    end
    for _, script in ipairs({"OnMouseDown", "OnMouseUp"}) do
        button:SetScript(script, nil)
    end
end

-- the rows of a scroll box, the ones there now and every one it creates later; func runs once per row
do
    local skinnedRows = setmetatable({}, {__mode = "k"})
    function GW.SkinScrollBoxFrames(scrollBox, func)
        local function SkinRow(row)
            if not skinnedRows[row] then
                skinnedRows[row] = true
                func(row)
            end
        end
        scrollBox:ForEachFrame(SkinRow)
        -- an own owner per call, the callback registry keeps one callback per owner
        ScrollUtil.AddAcquiredFrameCallback(scrollBox, function(_, row) SkinRow(row) end, {})
    end
end

-- icons inside a text (currencies, costs) at blizzards size become small and cropped; the hook keeps
-- them small when the text changes
do
    local SMALL_ICON = "|T%1:14:14:0:0:64:64:5:59:5:59|t"
    local rewriting = false

    local function ShrinkTextIcons(fontString)
        local text = fontString:GetText()
        if rewriting or GW.IsSecretValue(text) or not text then return end
        local shrunk = gsub(text, "|T([^:|]+)[^|]*|t", SMALL_ICON)
        if shrunk ~= text then
            rewriting = true
            fontString:SetText(shrunk)
            rewriting = false
        end
    end

    function GW.KeepTextIconsSmall(fontString)
        ShrinkTextIcons(fontString)
        hooksecurefunc(fontString, "SetText", ShrinkTextIcons)
    end
end

do
    -- one icon of the selector grid
    local function SkinIconChoice(button)
        local icon = button.Icon
        local texture = icon and icon:GetTexture()
        button:GwStripTextures()
        button:GwStyleButton(nil, true)
        -- a light grey frame, the icon sits a pixel inside it
        button:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
        button.backdrop:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.6)
        if icon then
            icon:SetTexture(texture)
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:GwSetInside(button)
        end
    end

    -- the icon picker of macros, equipment sets, bank tabs and our profiles
    local function HandleIconSelectionFrame(frame)
        if frame.gwSkinned then return end
        frame.gwSkinned = true

        local borderBox = frame.BorderBox
        frame:GwStripTextures()
        frame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        frame:SetHeight(frame:GetHeight() + 10)
        frame:EnableMouse(true)
        borderBox:GwStripTextures()

        if borderBox.IconTypeDropdown then
            borderBox.IconTypeDropdown:GwHandleDropDownBox()
        end
        local selected = borderBox.SelectedIconArea and borderBox.SelectedIconArea.SelectedIconButton
        if selected then
            selected:DisableDrawLayer("BACKGROUND")
            HandleItemButton(selected, true)
        end
        local editBox = borderBox.IconSelectorEditBox
        if editBox then
            GW.SkinTextBox(editBox.IconSelectorPopupNameMiddle, editBox.IconSelectorPopupNameLeft, editBox.IconSelectorPopupNameRight, nil, nil, 5, 5)
        end

        -- cancel in the corner, okay beside it
        local cancel = frame.CancelButton or borderBox.CancelButton
        local okay = frame.OkayButton or borderBox.OkayButton
        cancel:ClearAllPoints()
        cancel:SetPoint("BOTTOMRIGHT", frame, -4, 4)
        cancel:GwSkinButton(false, true)
        okay:ClearAllPoints()
        okay:SetPoint("RIGHT", cancel, "LEFT", -10, 0)
        okay:GwSkinButton(false, true)

        GW.HandleTrimScrollBar(frame.IconSelector.ScrollBar)
        GW.HandleScrollControls(frame.IconSelector)
        GW.SkinScrollBoxFrames(frame.IconSelector.ScrollBox, SkinIconChoice)
    end
    GW.HandleIconSelectionFrame = HandleIconSelectionFrame
end

-- old style tabs only learn their state through the global PanelTemplates functions; one hook each,
-- the skinned tabs register their handler instead of hooking again for every tab
local tabHandlers = {Select = setmetatable({}, {__mode = "k"}), Deselect = setmetatable({}, {__mode = "k"}), Resize = setmetatable({}, {__mode = "k"})}
for state, handlers in pairs(tabHandlers) do
    hooksecurefunc(state == "Resize" and "PanelTemplates_TabResize" or "PanelTemplates_" .. state .. "Tab", function(tab)
        local handler = handlers[tab]
        if handler then
            handler(tab)
        end
    end)
end

local function OnTabState(tab, onSelect, onDeselect, onResize)
    tabHandlers.Select[tab] = onSelect
    tabHandlers.Deselect[tab] = onDeselect
    tabHandlers.Resize[tab] = onResize
end

local function HandleTabs(self, direction, textures, setDesaturated)
    if self and not self.gwSkinned then
        local oldTexture = {}
        if textures then
            for _, texture in pairs(textures) do
                if texture:GetAtlas() then
                    tinsert(oldTexture, {isAtlas = true, texture = texture, textureFile = texture:GetAtlas()})
                else
                    tinsert(oldTexture, {isAtlas = false, texture = texture, textureFile = texture:GetTexture()})
                end
            end
        end

        self:GwStripTextures()

        if textures and oldTexture and #oldTexture > 0 then
            for _, textureData in pairs(oldTexture) do
                if textureData.isAtlas then
                    textureData.texture:SetAtlas(textureData.textureFile)
                else
                    textureData.texture:SetTexture(textureData.textureFile)
                end
                if setDesaturated ~= nil then
                    textureData.texture:SetDesaturated(setDesaturated)
                end
            end
        end

        if self.GetFontString and self:GetFontString() ~= nil then
            self:GetFontString():SetTextColor(1, 1, 1, 1)
            self:GetFontString():SetShadowOffset(0, 0)
        end

        self.tex = self:CreateTexture(nil, "BACKGROUND")
        self.tex:SetPoint("LEFT", self, "LEFT")
        self.tex:SetPoint("TOP", self, "TOP")
        self.tex:SetPoint("BOTTOM", self, "BOTTOM")
        self.tex:SetPoint("RIGHT", self, "RIGHT")
        self.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightinner.png")
        self.tex:SetAlpha(1)

        self.borderFrame = CreateFrame("Frame", nil, self, "GwLightButtonBorder")

        self.background = self:CreateTexture(nil, "BACKGROUND", nil, -7)
        self.background:SetPoint("LEFT", self, "LEFT")
        self.background:SetPoint("TOP", self, "TOP")
        self.background:SetPoint("BOTTOM", self, "BOTTOM")
        self.background:SetPoint("RIGHT", self, "RIGHT")
        self.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header.png")
        if direction == "top" then
            self.borderFrame.bottom:Hide()
        elseif direction == "left" then
            self.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/tab-tex-right-left.png")
            self.background:SetTexCoord(1, 0, 0, 1)
            self.borderFrame.right:Hide()
            self.borderFrame.bottom:Show()
        elseif direction == "right" then
            self.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/tab-tex-right-left.png")
            self.background:SetTexCoord(0, 1, 0, 1)
            self.borderFrame.left:Hide()
            self.borderFrame.bottom:Show()
        else
            self.background:SetTexCoord(0, 1, 1, 0)
            self.borderFrame.top:Hide()
            self.borderFrame.bottom:Show()
        end

        if self.Text then
            self.Text:SetPoint("CENTER", self, "CENTER", 0, 0)
        end
        if self.GetFontString and self:GetFontString() then
            self:GetFontString():ClearAllPoints()
            self:GetFontString():SetPoint("CENTER")
        end

        if self.SetTabSelected then
            hooksecurefunc(self, "SetTabSelected", function(tab)
                if tab.isSelected then
                    tab.background:SetBlendMode("MOD")
                else
                    tab.background:SetBlendMode("BLEND")
                end
                tab.Text:SetPoint("CENTER", self, "CENTER", 0, 0)
            end)
            if self.isSelected then
                self.background:SetBlendMode("MOD")
            else
                self.background:SetBlendMode("BLEND")
            end
        elseif self.SetChecked then
            hooksecurefunc(self, "SetChecked", function(tab, checked)
                if checked then
                    self.tex:SetAlpha(0)
                else
                    self.tex:SetAlpha(1)
                end
                if self.Text then
                    self.Text:SetPoint("CENTER", self, "CENTER", 0, 0)
                end
            end)
            if self.SelectedTexture:IsShown() then
                self.tex:SetAlpha(0)
            else
                self.tex:SetAlpha(1)
            end
        else
            local function SetTabBlend(tab, mode)
                tab.background:SetBlendMode(mode)
                if tab.Text then
                    tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
                end
            end
            OnTabState(self, function(tab) SetTabBlend(tab, "MOD") end, function(tab) SetTabBlend(tab, "BLEND") end)
            if self.LeftActive and self.LeftActive:IsShown() then -- selected
                self.background:SetBlendMode("MOD")
            else
                self.background:SetBlendMode("BLEND")
            end
        end

        self.gwSkinned = true
    end
end
GW.HandleTabs = HandleTabs

-- the rotate buttons of the classic model frames: the arrow cut out of blizzards round button art
local ROTATE_ARROW_COORDS = {0.3, 0.69, 0.29, 0.65}

local function HandleRotateButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    button:GwSkinButton(false, true)
    button:SetSize(button:GetWidth() - 14, button:GetHeight() - 14)

    local normal = button:GetNormalTexture()
    normal:GwSetInside()
    normal:SetTexCoord(unpack(ROTATE_ARROW_COORDS))
    button:GetPushedTexture():SetAllPoints(normal)
    button:GetPushedTexture():SetTexCoord(unpack(ROTATE_ARROW_COORDS))
    button:GetHighlightTexture():SetAllPoints(normal)
    button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
end
GW.HandleRotateButton = HandleRotateButton

-- plain text tabs: the active one white and underlined, the others grey, lighter on hover
function GW.AddTextTabArt(tab)
    tab.gwLabel = tab:CreateFontString(nil, "OVERLAY")
    tab.gwLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    tab.gwLabel:SetPoint("CENTER")

    tab.gwLine = tab:CreateTexture(nil, "ARTWORK")
    tab.gwLine:SetColorTexture(GW.Colors.TextColors.LightHeader:GetRGB())
    tab.gwLine:SetHeight(2)
    tab.gwLine:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 4, 0)
    tab.gwLine:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -4, 0)
end

-- the tab takes the width of its text
function GW.SetTextTab(tab, text, selected)
    tab.gwLabel:SetText(text)
    tab:SetWidth(tab.gwLabel:GetStringWidth() + 8)
    local shade = selected and 1 or (tab:IsMouseOver() and 0.8 or 0.6)
    tab.gwLabel:SetTextColor(shade, shade, shade)
    tab.gwLine:SetShown(selected)
end

function GW.CreateDetailsBackgroundTexture(parent, sublevel)
    local tex = parent:CreateTexture(nil, "BACKGROUND", nil, sublevel or 7)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background.png")
    tex:SetTexCoord(0, 0.70703125, 0, 0.580078125)
    return tex
end

function GW.AddDetailsBackground(frame, detailBackgroundsXOffset, detailBackgroundsYOffset)
    local detailBg = GW.CreateDetailsBackgroundTexture(frame)
    detailBg:SetPoint("TOPLEFT", frame, "TOPLEFT", detailBackgroundsXOffset or 0, detailBackgroundsYOffset or 0)
    detailBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.tex = detailBg
end

-- blizzards round help / info buttons become the help icon of our micro menu
function GW.SkinHelpIconButton(button, size)
    -- blanked, so blizzards ring pulse for new players stays invisible
    button:GwStripTextures()
    -- some templates inset their hit rect by 20 on every side, at our size nothing would be left
    button:SetHitRectInsets(0, 0, 0, 0)
    button:SetSize(size, size)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/helpmicrobutton-up.png")
    icon:SetAllPoints(button)
    button.gwIcon = icon
    button:GwStyleButton(nil, true)
end

function GW.AddStatusBarFrame(bar)
    local background = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
    background:SetAllPoints(bar)
    background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    background:SetVertexColor(0, 0, 0, 0.6)
    local top = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
    top:SetHeight(2)
    top:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 2)
    top:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 1, 2)
    top:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
    local bottom = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
    bottom:SetHeight(2)
    bottom:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -1, -2)
    bottom:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -2)
    bottom:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
    bottom:SetTexCoord(0, 1, 1, 0)
    local right = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
    right:SetWidth(2)
    right:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 2, 0)
    right:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, 0)
    right:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixelvertical.png")
    local left = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
    left:SetWidth(2)
    left:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 0)
    left:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -2, 0)
    left:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixelvertical.png")
    left:SetTexCoord(1, 0, 0, 1)
end

function GW.WhitenFontStrings(frame)
    if not frame then return end
    for _, region in next, {frame:GetRegions()} do
        if region:IsObjectType("FontString") then
            region:SetTextColor(1, 1, 1)
        end
    end
end

local function CreateFrameHeaderWithBody(frame, titleText, icon, detailBackgrounds, detailBackgroundsXOffset, addLeftSidePanel, addFrameOpenAnimation)
    -- blizzard dialogs are often only a parentKey, those get unnamed header parts
    local frameName = frame:GetName()
    local header = CreateFrame("Frame", frameName and (frameName .. "Header"), frame, "GwFrameHeader")
    header.windowIcon:SetTexture(icon)
    header:SetClampedToScreen(true)
    header:SetMovable(true)
    frame.gwHeader = header

    local function UpdateFrameHeaderBodyLayout()
        header.BGLEFT:SetWidth(math.max(0, math.min(512, frame:GetWidth() - 20)))
    end

    frame:HookScript("OnSizeChanged", UpdateFrameHeaderBodyLayout)
    if frame.OnFrameSizeChanged then
        hooksecurefunc(frame, "OnFrameSizeChanged", UpdateFrameHeaderBodyLayout)
    end
    if titleText then
        if type(titleText) ~= "string" then
            titleText:ClearAllPoints()
            titleText:SetParent(header)
            titleText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
            titleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
            titleText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            header.headerText = titleText
        else
            header.headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header.headerText:ClearAllPoints()
            header.headerText:SetParent(header)
            header.headerText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
            header.headerText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
            header.headerText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            header.headerText:SetText(titleText)
        end
    end

    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background.png")
    frame.tex = tex

    if detailBackgrounds then
        for _, v in pairs(detailBackgrounds) do
            GW.AddDetailsBackground(v, detailBackgroundsXOffset, 0)
        end
    end

    if addLeftSidePanel then
        frame.LeftSidePanel = CreateFrame("Frame", frameName and (frameName .. "LeftPanel"), frame, "GwWindowLeftPanel")
    end

    if addFrameOpenAnimation then
        local bgMask = UIParent:CreateMaskTexture()
        bgMask:SetPoint("TOPLEFT", frame, "TOPLEFT", -64, 64)
        bgMask:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -64, 0)
        bgMask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/masktest.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )

        frame.tex:AddMaskTexture(bgMask)
        header.BGLEFT:AddMaskTexture(bgMask)
        header.BGRIGHT:AddMaskTexture(bgMask)
        if frame.LeftSidePanel then
            frame.LeftSidePanel.background:AddMaskTexture(bgMask)
        end
        frame.backgroundMask = bgMask

        -- anchored to the right edge the revealed mask follows size and scale changes of the frame
        local function RevealBackground()
            bgMask:SetPoint("BOTTOMRIGHT", frame.tex, "BOTTOMRIGHT", 200, 0)
        end
        RevealBackground()

        local shownAlpha, fadingIn = 1, false
        frame:HookScript("OnShow",function()
        if not fadingIn and frame:GetAlpha() > 0 then
            shownAlpha = frame:GetAlpha()
        end
        fadingIn = true
        GW.AddToAnimation((frame.GetDebugName and frame:GetDebugName() or tostring(frame)) .. "_PANEL_ONSHOW", 0, 1, GetTime(), GW.WINDOW_FADE_DURATION,
            function(p)
                frame:SetAlpha(p * shownAlpha)
                -- the mask lives on UIParent, so its offset is in UIParent units
                local width = frame.tex:GetWidth() * frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
                bgMask:SetPoint("BOTTOMRIGHT", frame.tex, "BOTTOMLEFT", GW.lerp(-64, width, p), 0)
            end, 1, function()
                fadingIn = false
                RevealBackground()
            end)
        end)
    end

    UpdateFrameHeaderBodyLayout()
end
GW.CreateFrameHeaderWithBody = CreateFrameHeaderWithBody

-- blizzards art stays with the skins, every small window brings different art
local function SkinSmallWindow(frame, title, icon, closeButton)
    CreateFrameHeaderWithBody(frame, title, icon)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "BOTTOMLEFT", 24, 30)

    if closeButton then
        closeButton:GwSkinButton(true)
        closeButton:SetSize(25, 25)
        closeButton:ClearAllPoints()
        closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -2)
    end
end
GW.SkinSmallWindow = SkinSmallWindow

local function HandleListIcon(frame)
    if not frame.tableBuilder then return end

    for i = 1, 22 do
        local row = frame.tableBuilder.rows[i]
        if row then
            for j = 1, 4 do
                local cell = row.cells and row.cells[j]
                if cell and cell.Icon then
                    if not cell.gwSkinned then
                        GW.HandleIcon(cell.Icon)

                        if cell.IconBorder then
                            cell.IconBorder:GwKill()
                        end

                        cell.gwSkinned = true
                    end
                end
            end
        end
    end
end

local function HandleHeaders(frame)
    local maxHeaders = frame.HeaderContainer:GetNumChildren()
    for i, header in next, { frame.HeaderContainer:GetChildren() } do
        if not header.gwSkinned then
            header:DisableDrawLayer("BACKGROUND")

            if not header.backdrop then
                header:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
                header.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            end

            header.gwSkinned = true
        end

        if header.backdrop then
            header.backdrop:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
        end
    end

    HandleListIcon(frame)
end
GW.HandleSrollBoxHeaders = HandleHeaders

local function HandleScrollFrameHeaderButton(button, isLastButton)
    if not button.gwSkinned then
        if button.DisableDrawLayer then
            button:DisableDrawLayer("BACKGROUND")
        end

        if not button.backdrop then
            button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
            button.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            button.backdrop:SetFrameLevel(button:GetFrameLevel())
        end

        button.gwSkinned = true
    end

    if button.backdrop then
        button.backdrop:SetPoint("BOTTOMRIGHT", isLastButton and 0 or -5, -2)
    end
end
GW.HandleScrollFrameHeaderButton = HandleScrollFrameHeaderButton

local function AddMouseMotionPropagationToChildFrames(self)
    for _, child in next, { self:GetChildren() } do
        if not InCombatLockdown() then
            child:SetPropagateMouseMotion(true)
        end
        AddMouseMotionPropagationToChildFrames(child)
    end
end
GW.AddMouseMotionPropagationToChildFrames = AddMouseMotionPropagationToChildFrames

local function AddListItemChildHoverTexture(child)
    if child.Background then
        child.Background:GwStripTextures()
    end
    child.Background = child:CreateTexture(nil, "BACKGROUND", nil, 0)
    child.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    child.Background:ClearAllPoints()
    child.Background:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
    child.Background:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 0, 0)
    child.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if child.HighlightTexture then
        child.HighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        child.HighlightTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        child.HighlightTexture:GwSetInside(child.Background)
        child:HookScript("OnEnter", function()
            GW.TriggerButtonHoverAnimation(child, child.HighlightTexture)
        end)
    elseif child.Highlight then
        child.Highlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        child.Highlight:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        child.Highlight:GwSetInside(child.Background)
        child:HookScript("OnEnter", function()
            GW.TriggerButtonHoverAnimation(child, child.Highlight)
        end)
    else -- create hover texture
        child.gwHoverTexture = child:CreateTexture(nil, "ARTWORK", nil, 0)
        child.gwHoverTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        child.gwHoverTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        child.gwHoverTexture:SetPoint("LEFT", child, "LEFT", 0, 0)
        child.gwHoverTexture:SetPoint("TOP", child, "TOP", 0, 0)
        child.gwHoverTexture:SetPoint("BOTTOM", child, "BOTTOM", 0, 0)
        child.gwHoverTexture:SetPoint("RIGHT", child, "LEFT", 0, 0)
        child.gwHoverTexture:Hide()
        child:HookScript("OnEnter", function()
            child.gwHoverTexture:Show()
            GW.TriggerButtonHoverAnimation(child, child.gwHoverTexture)
        end)
        child:HookScript("OnLeave", function()
            child.gwHoverTexture:Hide()
        end)

        child.gwSelected = child:CreateTexture(nil, "ARTWORK", nil, 0)
        child.gwSelected:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        child.gwSelected:SetVertexColor(0.8, 0.8, 0.8, 1)
        child.gwSelected:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
        child.gwSelected:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 0, 0)
        child.gwSelected:Hide()

        if child.GetHighlightTexture and child:GetHighlightTexture() then
            child:GetHighlightTexture():GwKill()
        end
    end

    AddMouseMotionPropagationToChildFrames(child)
end
GW.AddListItemChildHoverTexture = AddListItemChildHoverTexture

local function HandleItemListScrollBoxHover(self)
    for _, child in next, { self.ScrollTarget:GetChildren() } do
        if not child.gwSkinned then
            AddListItemChildHoverTexture(child)

            child.gwSkinned = true
        end
        if not InCombatLockdown() then
            child:SetPropagateMouseMotion(true)
        end

        --zebra
        if child.Background then
            local zebra = child.GetOrderIndex and (child:GetOrderIndex() % 2) == 1 or false
            if zebra then
                child.Background:SetVertexColor(1, 1, 1, 1)
            else
                child.Background:SetVertexColor(0, 0, 0, 0)
            end
        end

        if child.NormalTexture then
            child.NormalTexture:SetAlpha(0)
        end
        if child.BackgroundHighlight then
            child.BackgroundHighlight:SetAlpha(0)
        end
        if child.SelectedHighlight then
            child.SelectedHighlight:SetColorTexture(0.5, 0.5, 0.5, .25)
        end
        if child.Selected then
            child.Selected:SetColorTexture(0.5, 0.5, 0.5, .25)
        end
    end
end
GW.HandleItemListScrollBoxHover = HandleItemListScrollBoxHover

-- blizzard sets the hover border atlas on every state change
local function SetTalentHoverTexture(texture)
    texture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
    texture:ClearAllPoints()
    texture:SetAllPoints(texture:GetParent().Icon.backdrop)
end

function GW.SkinTalentButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    if button.Shadow then button.Shadow:SetAlpha(0) end
    if button.StateBorder then button.StateBorder:SetAlpha(0) end
    if button.DisabledOverlay then button.DisabledOverlay:SetVertexColor(0, 0, 0, 0.6) end
    GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
    button.Icon.backdrop:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)

    if button.StateBorderHover then
        SetTalentHoverTexture(button.StateBorderHover)
        hooksecurefunc(button.StateBorderHover, "SetAtlas", SetTalentHoverTexture)
    end
end

local function SkinSideTabButton(self, iconTexture, tooltipText)
    self.gwSkinned = true
    self:GwStripTextures()
    self:SetSize(64, 40)
    if self.Text then
        self.Text:Hide()
    elseif self.GetName and self:GetName() ~= nil then
        _G[self:GetName() .. "Text"]:Hide()
    end

    self.icon = self:CreateTexture(nil, "BACKGROUND", nil, 0)
    self.icon:SetAllPoints()

    self.icon:SetTexture(iconTexture)

    self.icon:SetTexCoord(0.51, 1, 0, 0.625)

    if tooltipText then
        self:HookScript("OnEnter", function()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(tooltipText, 1, 1, 1)
            GameTooltip:Show()
        end)
        self:HookScript("OnLeave", GameTooltip_Hide)
    end

    if self.SetTabSelected then
        hooksecurefunc(self, "SetTabSelected", function(tab)
            if tab.isSelected then
                tab.icon:SetTexCoord(0, 0.5, 0, 0.625)
            else
                tab.icon:SetTexCoord(0.51, 1, 0, 0.625)
            end
        end)
        if self.isSelected then
            self.icon:SetTexCoord(0, 0.5, 0, 0.625)
        end
    else
        OnTabState(self,
            function(tab) tab.icon:SetTexCoord(0, 0.5, 0, 0.625) end,
            function(tab) tab.icon:SetTexCoord(0.51, 1, 0, 0.625) end,
            function(tab) tab:SetSize(64, 40) end)

        -- frame based side tabs (legacy system) have no enabled state
        if self.IsEnabled and not self:IsEnabled() then -- selected tab
            self.icon:SetTexCoord(0, 0.5, 0, 0.625)
        end
    end
end
GW.SkinSideTabButton = SkinSideTabButton

local function LockBlackButtonColor(button, r, g, b)
    if r ~= 0 or g ~= 0 or b ~= 0 then
        button:SetTextColor(0, 0, 0)
    end
end
GW.LockBlackButtonColor = LockBlackButtonColor

local function LockWhiteButtonColor(button, r, g, b)
    if r ~= 1 or g ~= 1 or b ~= 1 then
        button:SetTextColor(1, 1, 1)
    end
end
GW.LockWhiteButtonColor = LockWhiteButtonColor

local function HandleItemReward(frame, isMap)
    if not frame then
        return
    end

    if frame.Icon then
        frame.Icon:SetDrawLayer("ARTWORK")
        frame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        frame.Icon:SetAlpha(0.9)
    end

    if frame.IconBorder then
        frame.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    end

    if frame.Count then
        frame.Count:SetDrawLayer("OVERLAY")
        frame.Count:ClearAllPoints()
        frame.Count:SetPoint("TOPRIGHT", frame.Icon, "TOPRIGHT", 0, -3)
        frame.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
        frame.Count:SetJustifyH("RIGHT")
    end

    if frame.NameFrame then
        if isMap then
            frame.NameFrame:SetAlpha(0)
        else
            frame.NameFrame:SetAlpha(0.75)
            frame.NameFrame:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/nameframe.png")
        end
    end

    if frame.Name then
        frame.Name:SetTextColor(1, 1, 1)
    end

    if frame.IconOverlay then
        frame.IconOverlay:SetAlpha(0)
    end

    if frame.CircleBackground then
        frame.CircleBackground:SetAlpha(0)
        frame.CircleBackgroundGlow:SetAlpha(0)
    end

    for i = 1, frame:GetNumRegions() do
        local Region = select(i, frame:GetRegions())
        if Region and Region:IsObjectType("Texture") and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
            Region:SetTexture("")
        end
    end
end
GW.HandleItemReward = HandleItemReward

local function QuestInfo_Display(template, parentFrame)
    if not GW.settings.skins.gossip.enabled and not GW.settings.immersiveQuesting.enabled and (template == QUEST_TEMPLATE_DETAIL or template == QUEST_TEMPLATE_REWARD or template == QUEST_TEMPLATE_LOG) then
        return
    end
    local isMapStyle = false
    if template == QUEST_TEMPLATE_MAP_DETAILS or template == QUEST_TEMPLATE_MAP_REWARDS then
        if not GW.settings.skins.worldmap.enabled then
            return
        end
        isMapStyle = true
    end

    local fInfo = _G.QuestInfoFrame
    local fRwd = fInfo.rewardsFrame
    local questID
    local questFrame = parentFrame:GetParent():GetParent()
    if template.questLog then
        questID = questFrame.questID
    else
        questID = GetQuestID();
    end

    for i, questItem in ipairs(fRwd.RewardButtons) do
        local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
        if point and relativeTo and relativePoint then
            if i == 1 then
                questItem:SetPoint(point, relativeTo, relativePoint, 0, y)
            elseif relativePoint == "BOTTOMLEFT" then
                questItem:SetPoint(point, relativeTo, relativePoint, 0, -4)
            else
                questItem:SetPoint(point, relativeTo, relativePoint, 4, 0)
            end
        end

        GW.HandleItemReward(questItem, isMapStyle)
    end

    local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}
    if #spellRewards > 0 then
        for spellHeader in fRwd.spellHeaderPool:EnumerateActive() do
            spellHeader:SetVertexColor(1, 1, 1)
        end
        for spellIcon in fRwd.spellRewardPool:EnumerateActive() do
            GW.HandleItemReward(spellIcon, isMapStyle)
        end

        for followerReward in fRwd.followerRewardPool:EnumerateActive() do
            if not followerReward.gwSkinned then
                followerReward:GwCreateBackdrop()
                followerReward.backdrop:SetAllPoints(followerReward.BG)
                followerReward.backdrop:SetPoint("TOPLEFT", 40, -5)
                followerReward.backdrop:SetPoint("BOTTOMRIGHT", 2, 5)
                followerReward.BG:Hide()

                followerReward.PortraitFrame:ClearAllPoints()
                followerReward.PortraitFrame:SetPoint("RIGHT", followerReward.backdrop, "LEFT", -2, 0)

                followerReward.PortraitFrame.PortraitRing:Hide()
                followerReward.PortraitFrame.PortraitRingQuality:SetTexture()
                followerReward.PortraitFrame.LevelBorder:SetAlpha(0)
                followerReward.PortraitFrame.Portrait:SetTexCoord(0.2, 0.85, 0.2, 0.85)

                local level = followerReward.PortraitFrame.Level
                level:ClearAllPoints()
                level:SetPoint("BOTTOM", followerReward.PortraitFrame, 0, 3)

                local squareBG = CreateFrame("Frame", nil, followerReward.PortraitFrame, "BackdropTemplate")
                squareBG:SetFrameLevel(followerReward.PortraitFrame:GetFrameLevel()-1)
                squareBG:SetPoint("TOPLEFT", 2, -2)
                squareBG:SetPoint("BOTTOMRIGHT", -2, 2)
                followerReward.PortraitFrame.squareBG = squareBG

                followerReward.gwSkinned = true
            end

            local r, g, b = followerReward.PortraitFrame.PortraitRingQuality:GetVertexColor()
            followerReward.PortraitFrame.squareBG:SetBackdropBorderColor(r, g, b)
        end
    end

    _G.QuestInfoTitleHeader:SetTextColor(1, 0.8, 0.1)
    _G.QuestInfoDescriptionHeader:SetTextColor(1, 0.8, 0.1)
    _G.QuestInfoDescriptionText:SetTextColor(1, 1, 1)
    _G.QuestInfoObjectivesHeader:SetTextColor(1, 0.8, 0.1)
    _G.QuestInfoObjectivesText:SetTextColor(1, 1, 1)
    _G.QuestInfoGroupSize:SetTextColor(1, 1, 1)
    _G.QuestInfoRewardText:SetTextColor(1, 1, 1)
    _G.QuestInfoQuestType:SetTextColor(1, 1, 1)
    select(1, _G.QuestInfoItemHighlight:GetRegions()):SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/questitemhighlight.png")
    fRwd.ItemChooseText:SetTextColor(1, 1, 1)
    fRwd.ItemReceiveText:SetTextColor(1, 1, 1)
    if GW.Retail then
        QuestMapFrame.DetailsFrame.BackFrame.AccountCompletedNotice.Text:SetTextColor(0, 0.9, 0.6)
    end

    if not isMapStyle and GW.settings.immersiveQuesting.enabled then
        fRwd.Header:SetTextColor(1, 1, 1)
        fRwd.Header:SetShadowColor(0, 0, 0, 1)
    elseif fRwd.Header.SetTextColor then
        fRwd.Header:SetTextColor(1, 0.8, 0.1)
    end

    if fRwd.SpellLearnText then
        fRwd.SpellLearnText:SetTextColor(1, 1, 1)
    end

    if fRwd.PlayerTitleText then
        fRwd.PlayerTitleText:SetTextColor(1, 1, 1)
    end

    if fRwd.XPFrame.ReceiveText then
        fRwd.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
    end

    local objectives = _G.QuestInfoObjectivesFrame.Objectives
    local index = 0

    questID = GW.Retail and C_QuestLog.GetSelectedQuest() or GetQuestID()
    local waypointText = GW.Retail and C_QuestLog.GetNextWaypointText(questID)
    if waypointText then
        index = index + 1
        objectives[index]:SetTextColor(1, 0.93, 0.73)
    end

    for i = 1, GetNumQuestLeaderBoards() do
        local _, objectiveType, isCompleted = GetQuestLogLeaderBoard(i)
        if objectiveType ~= "spell" and objectiveType ~= "log" and index < _G.MAX_OBJECTIVES then
            index = index + 1

            local objective = objectives[index]
            if objective then
                if isCompleted then
                    objective:SetTextColor(0.2, 1, 0.2)
                else
                    objective:SetTextColor(1, 1, 1)
                end
            end
        end
    end
end
GW.QuestInfo_Display = QuestInfo_Display

local function SetHeaderPortrait(header, unit, borderInset)
    local icon = header and header.windowIcon
    if not icon then return end

    if not icon.gwPortraitFramed then
        icon.gwPortraitFramed = true
        borderInset = borderInset or 3
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true, borderInset, borderInset)
        icon.backdrop:SetBackdropColor(0, 0, 0, 0.72)
        icon.backdrop:SetBackdropBorderColor(0, 0, 0, 0.9)

        icon.gwAccentLine = header:CreateTexture(nil, "OVERLAY", nil, 3)
        icon.gwAccentLine:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarborderpixel.png")
        icon.gwAccentLine:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", 0, -2)
        icon.gwAccentLine:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, -2)
        icon.gwAccentLine:SetHeight(2)
        icon.gwAccentLine:SetVertexColor(1, 0.86, 0.46, 0.85)
    end

    SetPortraitTexture(icon, unit)
end
GW.SetHeaderPortrait = SetHeaderPortrait

-- zoom / rotate / reset buttons of a ModelSceneControlFrameTemplate (dressing room, transmog,
-- mount journal, ...): blizzards grey square buttons become small gw2 backdrops with muted icons
local function HandleModelSceneControlFrame(controlFrame)
    if not controlFrame or controlFrame.gwSkinned then return end
    controlFrame.gwSkinned = true

    for _, key in pairs({ "zoomInButton", "zoomOutButton", "rotateLeftButton", "rotateRightButton", "resetButton" }) do
        local button = controlFrame[key]
        if button then
            if button.NormalTexture then
                button.NormalTexture:SetAlpha(0)
            end
            button:SetSize(24, 24)
            button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder) -- flush on the button, no outer frame
            if button.Icon then
                button.Icon:SetSize(14, 14)
                button.Icon:SetDesaturated(true)
            end
        end
    end
end
GW.HandleModelSceneControlFrame = HandleModelSceneControlFrame

-- the older ModelWithControlsTemplate (our character window models): a panel of six 18px buttons
-- with the UI-ModelControlPanel art; drop the panel art and give the buttons the same gw2 look as
-- HandleModelSceneControlFrame. Blizzards hover fade of the panel stays.
local function HandleModelControlFrame(controlFrame)
    if not controlFrame or controlFrame.gwSkinned then return end
    controlFrame.gwSkinned = true

    for _, region in pairs({ controlFrame:GetRegions() }) do
        if region:IsObjectType("Texture") then
            region:SetAlpha(0)
        end
    end

    for _, button in pairs({ controlFrame:GetChildren() }) do
        if button:IsObjectType("Button") then
            if button.bg then
                button.bg:SetAlpha(0)
            end
            button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
            if button.icon then
                button.icon:SetSize(14, 14)
                button.icon:SetDesaturated(true)
            end
        end
    end
end
GW.HandleModelControlFrame = HandleModelControlFrame
