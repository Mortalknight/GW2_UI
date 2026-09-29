---@class GW2
local GW = select(2, ...)

local WHITE = "Interface/AddOns/GW2_UI/textures/uistuff/white.png"
local ARROW = "Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png"
local SEPARATOR = "Interface/AddOns/GW2_UI/textures/bag/bag-sep.png"
local ROUND_ICON_MASK = 6707800
local ICON_OVERLAY_ATLAS = "UI-HUD-CoolDownManager-IconOverlay"
local BAR_BACKGROUND_ATLAS = "UI-HUD-CoolDownManager-Bar-BG"

local function ForEachTexture(frame, func)
    for _, region in ipairs({frame:GetRegions()}) do
        if region:IsObjectType("Texture") then
            func(region)
        end
    end
end

-- atlases can be secret on these frames
local function HasAtlas(region, atlas)
    local current = region:GetAtlas()
    return GW.NotSecretValue(current) and current == atlas
end

---------- the category headers of the settings window ----------

-- collapsed categories point their arrow to the side
local function UpdateCollapseArrow(header, collapsed)
    header.gwArrow:SetRotation(collapsed and math.pi / 2 or 0)
end

local function SkinCategoryHeader(header)
    for _, key in ipairs({"Left", "Middle", "Right"}) do
        if header[key] then
            header[key]:Hide()
        end
        if header["Highlight" .. key] then
            header["Highlight" .. key]:SetAlpha(0)
        end
    end

    header:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
    header.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
    header:SetNormalTexture(SEPARATOR)
    header:SetHighlightTexture(SEPARATOR)
    header:GetHighlightTexture():SetColorTexture(1, 0.93, 0.73, 0.25)
    for _, texture in ipairs({header:GetNormalTexture(), header:GetHighlightTexture()}) do
        texture:ClearAllPoints()
        texture:SetPoint("TOPLEFT", header, "TOPLEFT", 1, -1)
        texture:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -1, 1)
    end

    GW.LockFontStringColor(header.Name, 1, 1, 1)
    header.gwArrow = header:CreateTexture(nil, "ARTWORK")
    header.gwArrow:SetSize(16, 16)
    header.gwArrow:SetPoint("RIGHT", header, "RIGHT", -4, 0)
    header.gwArrow:SetTexture(ARROW)
    UpdateCollapseArrow(header, false)
    hooksecurefunc(header, "UpdateCollapsedState", UpdateCollapseArrow)
end

-- the spells and auras of a category: square icons with a light highlight
local function SkinSettingItem(item)
    local icon = item.Icon
    if not icon then return end
    if item.Highlight then
        item.Highlight:SetColorTexture(1, 1, 1, 0.25)
        item.Highlight:SetAllPoints(icon)
    end
    GW.HandleIcon(icon, true)
end

local skinnedHeaders = setmetatable({}, {__mode = "k"})
local hookedItemPools = setmetatable({}, {__mode = "k"})

local function SkinCategories(content)
    if not content then return end
    for _, category in ipairs({content:GetChildren()}) do
        local header = category.Header
        if header and not skinnedHeaders[header] then
            skinnedHeaders[header] = true
            SkinCategoryHeader(header)
        end

        local pool = category.itemPool
        if pool and not hookedItemPools[pool] then
            hookedItemPools[pool] = true
            GW.SkinPoolFrames(pool, SkinSettingItem)
            hooksecurefunc(pool, "Acquire", function(acquiredFrom) GW.SkinPoolFrames(acquiredFrom, SkinSettingItem) end)
        end
    end
end

---------- the cooldown viewers ----------

-- stack and charge counts in the top right corner
local function SkinCountText(text, parent)
    text:ClearAllPoints()
    text:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    text:SetJustifyH("RIGHT")
    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    text:SetTextColor(1, 1, 0.6)
end

-- a square icon in the backdrop of our action buttons; blizzards round mask becomes a plain square,
-- the ring over it goes
local function SkinIcon(container, icon)
    local stacks = container.Applications and container.Applications.Applications
    local charges = container.ChargeCount and container.ChargeCount.Current
    for _, text in ipairs({stacks or false, charges or false}) do
        if text then
            SkinCountText(text, container)
        end
    end
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    if not container.gwBackdrop then
        container.gwBackdrop = CreateFrame("Frame", nil, container, "GwActionButtonBackdropTmpl")
        container.gwBackdrop:SetPoint("TOPLEFT", container, "TOPLEFT", -1, 1)
        container.gwBackdrop:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 1, -1)
    end
    local alpha = tonumber(GW.settings.actionbars.backgroundAlpha)
    for _, key in ipairs({"bg", "border1", "border2", "border3", "border4"}) do
        container.gwBackdrop[key]:SetAlpha(alpha)
    end

    ForEachTexture(container, function(region)
        local texture = region:GetTexture()
        if HasAtlas(region, ICON_OVERLAY_ATLAS) then
            region:SetAlpha(0)
        elseif GW.NotSecretValue(texture) and texture == ROUND_ICON_MASK then
            region:SetTexture(WHITE)
        end
    end)
end

-- a bar with its icon in front: our bar texture and spark over our status bar background
local function SkinBar(frame, bar)
    for _, text in ipairs({bar.Name or false, bar.Duration or false}) do
        if text then
            text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
        end
    end
    if frame.Icon then
        bar:SetPoint("LEFT", frame.Icon, "RIGHT", 2, 0)
        SkinIcon(frame.Icon, frame.Icon.Icon)
    end

    ForEachTexture(bar, function(region)
        if HasAtlas(region, BAR_BACKGROUND_ATLAS) then
            region:SetAlpha(0)
        end
    end)
    if not frame.GwStatusBarBackground then
        frame.GwStatusBarBackground = CreateFrame("Frame", nil, frame, "GwStatusBarBackground")
        frame.GwStatusBarBackground:SetAllPoints(bar)
        frame.GwStatusBarBackground:SetFrameStrata("BACKGROUND")
    end

    local fill = bar:GetStatusBarTexture()
    fill:SetTexCoord(0, 1, 0, 1)
    fill:SetVertexColor(1, 1, 1, 1)
    fill:ClearAllPoints()
    fill:GwSetInside(frame.GwStatusBarBackground)
    bar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/rage.png")

    local spark = bar.Pip
    spark:SetSize(6, bar:GetHeight())
    spark:SetTexCoord(0, 1, 0, 1)
    spark:SetBlendMode("BLEND")
    spark:SetTexture("Interface/AddOns/GW2_UI/textures/bartextures/ragespark.png")
end

-- blizzard sets these again whenever the cooldown or the aura of an item changes
local ITEM_HOOKS = {
    RefreshSpellCooldownInfo = function(item)
        if item.Cooldown then
            item.Cooldown:SetSwipeColor(0, 0, 0, 1)
        end
    end,
    SetTimerShown = function(item)
        if item.Cooldown then
            GW.ToggleBlizzardCooldownText(item.Cooldown, item.Cooldown.timer)
        end
    end,
    RefreshIconBorder = function(item)
        if item.DebuffBorder then
            item.DebuffBorder.Texture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        end
    end,
}

local hookedItems = setmetatable({}, {__mode = "k"})

local function SkinItemFrame(item)
    if item.Cooldown then
        item.Cooldown:SetSwipeTexture(WHITE)
        if not hookedItems[item] then
            hookedItems[item] = true
            for method, func in pairs(ITEM_HOOKS) do
                if item[method] then
                    hooksecurefunc(item, method, func)
                end
            end
        end
    end

    if item.Bar then
        SkinBar(item, item.Bar)
    elseif item.Icon then
        SkinIcon(item, item.Icon)
    end
end

-- blizzard hands out the items of a viewer from a pool, each new one is skinned on its way out
local function HandleViewer(viewer)
    hooksecurefunc(viewer, "OnAcquireItemFrame", function(_, item) SkinItemFrame(item) end)
    for item in viewer.itemFramePool:EnumerateActive() do
        SkinItemFrame(item)
    end
end

---------- the settings window ----------

local function SkinSettings(settings)
    GW.HandlePortraitFrame(settings)
    GW.CreateFrameHeaderWithBody(settings, settings.TitleContainer.TitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png", {settings.CooldownScroll}, nil, nil, true)

    GW.SkinTextBox(settings.SearchBox.Middle, settings.SearchBox.Left, settings.SearchBox.Right)
    for _, scroll in ipairs({settings.CooldownScroll, settings.GroupBuffFilter.Scroll}) do
        GW.HandleTrimScrollBar(scroll.ScrollBar)
        GW.HandleScrollControls(scroll)
    end
    settings.UndoButton:GwSkinButton(false, true)
    settings.LayoutDropdown:GwHandleDropDownBox()

    -- spells, auras and group buffs as tabs down the right side
    local previous
    for _, tab in ipairs({settings.SpellsTab, settings.AurasTab, settings.GroupBuffsTab}) do
        GW.HandleTabs(tab, "right", {tab.Icon}, true)
        tab:ClearAllPoints()
        if previous then
            tab:SetPoint("TOP", previous, "BOTTOM", 0, 1)
        else
            tab:SetPoint("TOPLEFT", settings, "TOPRIGHT", 0, -30)
        end
        previous = tab
    end

    local function SkinAllCategories()
        SkinCategories(settings.CooldownScroll.Content)
        SkinCategories(settings.GroupBuffFilter.Scroll.Content)
    end
    SkinAllCategories()
    hooksecurefunc(settings, "RefreshLayout", SkinAllCategories)
end

local function ApplyCooldownManagerSkin()
    if not GW.settings.skins.cooldownManager.enabled then return end

    for _, viewer in ipairs({UtilityCooldownViewer, BuffBarCooldownViewer, BuffIconCooldownViewer, EssentialCooldownViewer}) do
        HandleViewer(viewer)
    end
    if CooldownViewerSettings then
        SkinSettings(CooldownViewerSettings)
    end
end

local function LoadCooldownManagerSkin()
    GW.RegisterLoadHook(ApplyCooldownManagerSkin, "Blizzard_CooldownViewer", BuffBarCooldownViewer)
end
GW.LoadCooldownManagerSkin = LoadCooldownManagerSkin
