---@class GW2
local GW = select(2, ...)

-- One look and one behavior for every text field: the background of our settings fields, a placeholder that is
-- back as soon as the field is empty, the whole text selected on focus and escape only leaves the field. Search
-- fields get the search icon in front, a clear button only shows while there is text. Blizzard search boxes bring
-- icon, clear button and placeholder along, they are reused.

local TEXTURES = "Interface/AddOns/GW2_UI/textures/uistuff/"
local INSET = 6
local COMPACT_INSET = 2
local ICON_INSET = 20

-- left/right/vertical lay the background around the frame instead of on it, negative values move it inside
local function CreateBackground(box, left, right, vertical)
    left, right, vertical = left or 0, right or 0, vertical or 0
    local bg = box:CreateTexture(nil, "BACKGROUND", nil, -1)
    bg:SetTexture(TEXTURES .. "statusbar.png")
    bg:SetVertexColor(1, 1, 1, 0.5)
    bg:SetPoint("TOPLEFT", -left, vertical)
    bg:SetPoint("BOTTOMRIGHT", right, -vertical)

    local top = box:CreateTexture(nil, "BACKGROUND")
    top:SetTexture(TEXTURES .. "statusbarborderpixel.png")
    top:SetHeight(1)
    top:SetPoint("TOPLEFT", bg)
    top:SetPoint("TOPRIGHT", bg)

    local bottom = box:CreateTexture(nil, "BACKGROUND")
    bottom:SetTexture(TEXTURES .. "statusbarborderpixel.png")
    bottom:SetTexCoord(0, 1, 1, 0)
    bottom:SetHeight(1)
    bottom:SetPoint("BOTTOMLEFT", bg)
    bottom:SetPoint("BOTTOMRIGHT", bg)

    local leftBorder = box:CreateTexture(nil, "BACKGROUND")
    leftBorder:SetTexture(TEXTURES .. "statusbarborderpixelvertical.png")
    leftBorder:SetTexCoord(1, 0, 0, 1)
    leftBorder:SetWidth(2)
    leftBorder:SetPoint("TOPLEFT", bg, -1, 0)
    leftBorder:SetPoint("BOTTOMLEFT", bg, -1, 0)

    local rightBorder = box:CreateTexture(nil, "BACKGROUND")
    rightBorder:SetTexture(TEXTURES .. "statusbarborderpixelvertical.png")
    rightBorder:SetWidth(1)
    rightBorder:SetPoint("TOPRIGHT", bg, 1, 0)
    rightBorder:SetPoint("BOTTOMRIGHT", bg, 1, 0)
end

-- the background alone, for fields that keep their own layout: multi line fields sit in a scroll frame that
-- reaches up to the text, so by default the background goes 5 around it like blizzards art; right and vertical
-- follow left unless given; blizzards art of the frame is hidden
local MULTI_LINE_OUTSET = 5
function GW.AddEditBoxBackground(frame, left, right, vertical)
    left = left or MULTI_LINE_OUTSET
    GW.HandleBlizzardRegions(frame)
    CreateBackground(frame, left, right or left, vertical or left)
    -- blizzards input scroll frames carry the text field as EditBox
    local box = frame.EditBox
    if box then
        box:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        box:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        if box.Instructions then
            box.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            box.Instructions:SetTextColor(GW.Colors.SkinColors.Placeholder:GetRGB())
        end
    end
end

-- other addons skin their fields through this (Baganator, ItemUpgradeTip, Krowi), the art they pass sits on the field
function GW.SkinTextBox(middle, left, right)
    local art = middle or left or right
    local box = art and art:GetParent()
    if box and not box.gwEditBoxSkinned then
        box.gwEditBoxSkinned = true
        GW.AddEditBoxBackground(box, 0)
    end
end

local function CreateSearchIcon(box)
    local icon = box:CreateTexture(nil, "OVERLAY")
    icon:SetAtlas("common-search-magnifyingglass")
    icon:SetSize(10, 10)
    box.searchIcon = icon
end

local function ClearButton_OnClick(self)
    local box = self:GetParent()
    box:SetText("")
    box:ClearFocus()
end

local function CreateClearButton(box)
    local button = CreateFrame("Button", nil, box)
    button:SetSize(17, 17)
    button.texture = button:CreateTexture(nil, "ARTWORK")
    button.texture:SetAtlas("common-search-clearbutton")
    button.texture:SetSize(10, 10)
    button.texture:SetPoint("CENTER")
    button.texture:SetAlpha(0.5)
    button:SetScript("OnEnter", function(self) self.texture:SetAlpha(1) end)
    button:SetScript("OnLeave", function(self) self.texture:SetAlpha(0.5) end)
    button:SetScript("OnClick", ClearButton_OnClick)
    box.clearButton = button
end

local function Update(box)
    local isEmpty = box:GetText() == ""
    box.Instructions:SetShown(isEmpty)
    if box.clearButton then
        box.clearButton:SetShown(box.gwHasClear and not isEmpty)
    end
    if box.gwHasSearch then
        box.searchIcon:SetAlpha((box:HasFocus() or not isEmpty) and 1 or 0.6)
    end
end

local function OnFocusGained(box)
    box:HighlightText()
    Update(box)
end

local function OnFocusLost(box)
    box:HighlightText(0, 0)
    Update(box)
end

-- options: search (icon, clear button and SEARCH as placeholder), clear, placeholder, noBackground,
-- compact (small centered values) and keepFont (the caller set the font already)
local function SkinEditBox(box, options)
    if box.gwEditBoxSkinned then return end
    box.gwEditBoxSkinned = true
    options = options or {}
    local inset = options.compact and COMPACT_INSET or INSET

    -- without a background the caller brings its own, like the bags
    if not options.noBackground then
        GW.HandleBlizzardRegions(box)
        CreateBackground(box)
    end

    local left, right = inset, inset
    if options.search then
        if not box.searchIcon then
            CreateSearchIcon(box)
        end
        box.searchIcon:ClearAllPoints()
        box.searchIcon:SetPoint("LEFT", inset, 0)
        left = ICON_INSET
    elseif box.searchIcon then
        box.searchIcon:Hide()
    end
    box.gwHasSearch = options.search

    box.gwHasClear = options.search or options.clear
    if box.gwHasClear then
        if not box.clearButton then
            CreateClearButton(box)
        end
        box.clearButton:ClearAllPoints()
        box.clearButton:SetPoint("RIGHT", -2, 0)
        right = ICON_INSET
    elseif box.clearButton then
        box.clearButton:Hide()
    end
    box:SetTextInsets(left, right, 0, 0)
    local textSize = options.compact and GW.Enum.TextSizeType.Small or GW.Enum.TextSizeType.Normal
    if not options.keepFont then
        box:GwSetFontTemplate(UNIT_NAME_FONT, textSize)
    end
    box:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    -- blizzard centers some of its number boxes, ours only center the compact ones
    box:SetJustifyH(options.compact and "CENTER" or "LEFT")

    if not box.Instructions then
        box.Instructions = box:CreateFontString(nil, "ARTWORK")
        box.Instructions:SetJustifyH("LEFT")
        box.Instructions:SetJustifyV("MIDDLE")
    end
    if options.keepFont then
        box.Instructions:SetFont(box:GetFont())
    else
        box.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, textSize)
    end
    box.Instructions:SetTextColor(GW.Colors.SkinColors.Placeholder:GetRGB())
    box.Instructions:ClearAllPoints()
    box.Instructions:SetPoint("TOPLEFT", left, 0)
    box.Instructions:SetPoint("BOTTOMRIGHT", -right, 0)
    -- blizzard boxes keep their own hint unless we bring one
    if options.placeholder or options.search then
        box.Instructions:SetText(options.placeholder or SEARCH)
    end

    if not box:GetScript("OnEscapePressed") then
        box:SetScript("OnEscapePressed", box.ClearFocus)
    end
    box:HookScript("OnTextChanged", Update)
    box:HookScript("OnEditFocusGained", OnFocusGained)
    box:HookScript("OnEditFocusLost", OnFocusLost)
    Update(box)
end
GW.SkinEditBox = SkinEditBox
