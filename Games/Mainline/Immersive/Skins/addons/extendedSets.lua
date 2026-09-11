---@class GW2
local GW = select(2, ...)

-- Extended Transmog Sets: replaces the set list of the wardrobe with its own hybrid scroll frame, adds a filter,
-- icon buttons above the model and a third "Weapon Sets" tab. The rows use blizzards row template.

local ICON_BUTTON_SIZE = 18
local ICON_IDLE_ALPHA = 0.7
local BORDER_IDLE = {0.3, 0.3, 0.3}
local BORDER_DIM = 0.5
local SELECTED_TEXTURE = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local SELECTED_COLOR = {0.8, 0.8, 0.8, 1}
local SCROLLBAR_WIDTH = 12
local SEARCH_WIDTH = 96
local TYPE_PAD = 4
local TYPE_TEXT_PAD = 24
local DETAIL_ICONS = {"HiddenSetButton", "FavoriteSetButton", "LinkOutfitButton", "AHButton"}
local MODEL_BUTTONS = {"ResetRotation", "SwapPlayerItem", "SwapPose", "dualWield", "RedressButton", "SwapFormButton"}
-- the addon drives the item borders through blizzards loot tab atlases
local BORDER_QUALITY = {
    ["loottab-set-itemborder-white"] = Enum.ItemQuality.Common,
    ["loottab-set-itemborder-green"] = Enum.ItemQuality.Uncommon,
    ["loottab-set-itemborder-blue"] = Enum.ItemQuality.Rare,
    ["loottab-set-itemborder-purple"] = Enum.ItemQuality.Epic,
}

---------- shared pieces ----------

local function SkinRows(rows)
    for _, row in ipairs(rows) do
        GW.CollectionsSkin.SkinListRow(row)
    end
end

-- the scroll frames reach further than their rows, the bar belongs next to the rows
local function PlaceBarNextToRows(bar, rows, gap)
    local first, last = rows[1], rows[#rows]
    if not first or not last then return end
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", first, "TOPRIGHT", gap, 0)
    bar:SetPoint("BOTTOMLEFT", last, "BOTTOMRIGHT", gap, 0)
end

-- the icon frames next to the variant dropdown (auction house, transmogrifier, favorite, hidden); the addon
-- chains their positions itself on every update
local function SkinDetailIcons(parent)
    if not parent then return end
    for _, key in ipairs(DETAIL_ICONS) do
        local icon = parent[key]
        if icon and icon.backgroundTexture then
            icon:SetSize(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
            icon.backgroundTexture:ClearAllPoints()
            icon.backgroundTexture:SetPoint("CENTER")
            icon.backgroundTexture:SetSize(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE)
            icon:SetAlpha(ICON_IDLE_ALPHA)
            icon:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
            icon:HookScript("OnLeave", function(self) self:SetAlpha(ICON_IDLE_ALPHA) end)
        end
    end
end

local function SkinHeader(text)
    if not text then return end
    text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

---------- item icons ----------

local function UpdateItemBorder(itemFrame)
    local backdrop = itemFrame.Icon.backdrop
    local border = itemFrame.IconBorder
    local quality = border and border:IsShown() and BORDER_QUALITY[border:GetAtlas()]
    local color = quality and GW.GetBagItemQualityColor(quality)
    if color then
        local factor = itemFrame.gwBorderDim and BORDER_DIM or 1
        backdrop:SetBackdropBorderColor(color.r * factor, color.g * factor, color.b * factor, 1)
    else
        backdrop:SetBackdropBorderColor(BORDER_IDLE[1], BORDER_IDLE[2], BORDER_IDLE[3], 1)
    end
end

local function KeepBorderHidden(border)
    border.gwResetting = true
    border:SetAlpha(0)
    border.gwResetting = nil
end

local function SkinItemFrame(itemFrame)
    if itemFrame.gwSkinned or not itemFrame.Icon then return end
    itemFrame.gwSkinned = true

    GW.HandleIcon(itemFrame.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
    -- the addon hides a foreign icon backdrop for uncollected pieces and never shows it again on the reused frame
    hooksecurefunc(itemFrame.Icon.backdrop, "Hide", function(self) self:Show() end)

    local border = itemFrame.IconBorder
    if border then
        for _, method in ipairs({"Show", "Hide", "SetShown", "SetAtlas"}) do
            hooksecurefunc(border, method, function() UpdateItemBorder(itemFrame) end)
        end
        -- the addon sets alpha 1 or 0.5 (pieces another class collects) after the atlas: the blizzard border
        -- stays invisible, the value only feeds the dim state
        hooksecurefunc(border, "SetAlpha", function(self, alpha)
            if self.gwResetting then return end
            itemFrame.gwBorderDim = alpha ~= nil and alpha < 1
            KeepBorderHidden(self)
            UpdateItemBorder(itemFrame)
        end)
        KeepBorderHidden(border)
    end
    UpdateItemBorder(itemFrame)
end

-- the set icons come from blizzards frame pool, the addon acquires and fills them on every set change
local function HookItemFrames(details)
    local pool = details and details.itemFramesPool
    if not pool then return end
    hooksecurefunc(pool, "Acquire", function(self)
        for itemFrame in self:EnumerateActive() do
            SkinItemFrame(itemFrame)
        end
    end)
    for itemFrame in pool:EnumerateActive() do
        SkinItemFrame(itemFrame)
    end
end

---------- sets tab ----------

local function SkinSetsList(sets, list)
    -- anchored to the sets frame like blizzards list instead of the search box, which moves on every tab change
    list:ClearAllPoints()
    list:SetPoint("TOPLEFT", sets, "TOPLEFT", 0, -36)
    if sets.DetailsFrame then
        list:SetPoint("BOTTOMRIGHT", sets.DetailsFrame, "BOTTOMLEFT", -7, 2)
    end

    local rows = list.buttons or {}
    SkinRows(rows)
    if list.scrollBar then
        GW.HandleTrimScrollBar(list.scrollBar)
        GW.HandleScrollControls(list, "scrollBar")
        PlaceBarNextToRows(list.scrollBar, rows, 10)
    end
end

local function SkinSetsTab()
    local frame = WardrobeCollectionFrame
    local sets = frame and frame.SetsCollectionFrame
    local list = sets and sets.ExS_ScrollFrame
    if not list or list.gwSkinned then return end
    list.gwSkinned = true

    SkinSetsList(sets, list)
    if sets.FilterDropDownButton then
        GW.CollectionsSkin.SkinFilterDropdown(sets.FilterDropDownButton, frame.SearchBox, sets.LeftInset)
    end
    GW.WhitenFontStrings(sets.HiddenSetsCount)
    HookItemFrames(sets.DetailsFrame)
    SkinDetailIcons(sets.DetailsFrame)
end

---------- weapon sets tab ----------

local function SkinWeaponList(left)
    left:GwStripTextures()
    local list = left.ScrollFrame
    local rows = list and list.buttons or {}
    SkinRows(rows)

    GW.CollectionsSkin.SkinSearchBox(left.SearchBox)
    if left.SearchBox then
        left.SearchBox:ClearAllPoints()
        left.SearchBox:SetPoint("TOPLEFT", left, "TOPLEFT", 2, -9)
        left.SearchBox:SetWidth(SEARCH_WIDTH)
    end
    if left.FilterButton then
        GW.CollectionsSkin.SkinFilterDropdown(left.FilterButton, left.SearchBox, rows[1] or left)
    end

    -- HybridScrollBarTrimTemplate, the old style bar with its own up and down buttons
    local bar = list and list.Scrollbar
    if bar then
        bar:GwStripTextures()
        bar:GwSkinScrollBar()
        bar:SetWidth(SCROLLBAR_WIDTH)
        PlaceBarNextToRows(bar, rows, 8)
    end
end

-- the weapon type buttons and their icon textures start left of the details background: selection and hover
-- begin at its edge and end behind the text
local function FitToContent(texture, button, edge)
    texture:ClearAllPoints()
    texture:SetPoint("TOP", button.WeaponIcon, "TOP", 0, TYPE_PAD)
    texture:SetPoint("BOTTOM", button.WeaponIcon, "BOTTOM", 0, -TYPE_PAD)
    texture:SetPoint("LEFT", edge, "LEFT", TYPE_PAD, 0)
    texture:SetPoint("RIGHT", button.Text, "RIGHT", TYPE_TEXT_PAD, 0)
end

-- the addon tints the selection by collection state on every update, the text already carries that color
local function KeepSelectionColor(texture)
    if texture.gwResetting then return end
    texture.gwResetting = true
    texture:SetVertexColor(unpack(SELECTED_COLOR))
    texture.gwResetting = nil
end

local function SkinWeaponTypeButtons(right)
    local edge = right.tex or right
    for _, button in ipairs(right.weaponTypeArray or {}) do
        if button.WeaponIcon and button.Text then
            if button.background then
                button.background:SetTexture(SELECTED_TEXTURE)
                button.background:SetTexCoord(0, 1, 0, 1)
                KeepSelectionColor(button.background)
                hooksecurefunc(button.background, "SetVertexColor", KeepSelectionColor)
                FitToContent(button.background, button, edge)
            end
            button:GwStyleButton(nil, true)
            if button.hover then
                FitToContent(button.hover, button, edge)
            end
        end
    end
end

-- the round buttons right of the model keep their icons, the gold ring goes
local function SkinModelButtons(right)
    for _, key in ipairs(MODEL_BUTTONS) do
        local button = right[key]
        if button then
            if button.backTex then
                button.backTex:SetAlpha(0)
            end
            button:GwStyleButton(nil, true)
        end
    end
end

local function SkinWeaponsTab()
    local weapons = WardrobeCollectionFrame and WardrobeCollectionFrame.WeaponSetsCollectionFrame
    if not weapons or weapons.gwSkinned or not weapons.LeftFrame or not weapons.RightFrame then return end
    weapons.gwSkinned = true

    SkinWeaponList(weapons.LeftFrame)

    local right = weapons.RightFrame
    right:GwStripTextures()
    GW.AddDetailsBackground(right, 8, 0)
    GW.CollectionsSkin.SkinDropdowns(right.VariantDropDownButton)
    GW.WhitenFontStrings(right.HiddenSetsCount)
    SkinDetailIcons(right)
    SkinWeaponTypeButtons(right)
    SkinModelButtons(right)

    local details = right.DetailsFrame
    if details then
        SkinHeader(details.Name)
        if details.ItemFrame then
            SkinItemFrame(details.ItemFrame)
        end
    end
end

---------- load ----------

local function ApplyExtendedSetsSkin()
    -- the addon builds the sets frames in its own Blizzard_Collections handler, which runs after ours
    C_Timer.After(0, SkinSetsTab)
    if WardrobeCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame then
        WardrobeCollectionFrame.SetsCollectionFrame:HookScript("OnShow", SkinSetsTab)
    end
    -- the weapon sets frame is built on the first click of its tab, after PanelTemplates_SetTab
    hooksecurefunc("PanelTemplates_SetTab", function(frame, tabID)
        if frame == WardrobeCollectionFrame and tabID == 3 then
            C_Timer.After(0, SkinWeaponsTab)
        end
    end)
end

local function LoadExtendedSetsAddonSkin()
    if not GW.settings.COLLECTIONS_SKIN_ENABLED or not GW.settings.EXTENDED_SETS_SKIN_ENABLED or not C_AddOns.IsAddOnLoaded("ExtendedSets") then return end
    GW.RegisterLoadHook(ApplyExtendedSetsSkin, "Blizzard_Collections", CollectionsJournal)
end
GW.LoadExtendedSetsAddonSkin = LoadExtendedSetsAddonSkin
