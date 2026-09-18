---@class GW2
local GW = select(2, ...)

-- The parts of the inspect window that look the same on every client: window, header with the portrait of the
-- inspected unit, tabs, the paperdoll with its item levels and the model. Mists puts its talent, spec and glyph
-- tabs on top of this, the classic clients use it as their whole skin. Every frame is checked before it is
-- touched, the tabs and the pvp panels differ from client to client.

local MODEL_BORDERS = {
    "TopLeft", "TopRight", "Top", "Left", "Right", "BottomLeft", "BottomRight", "Bottom",
}
local PVP_PANELS = {"RatedBG", "Arena2v2", "Arena3v3", "Arena5v5"}

local function Update_InspectPaperDollItemSlotButton(button)
    local unit = button.hasItem and InspectFrame.unit
    local quality = unit and GetInventoryItemQuality(unit, button:GetID())

    if button.itemlevel then
        local itemLink = unit and GetInventoryItemLink(unit, button:GetID())
        if itemLink then
            GW.SetItemLevel(button, quality, itemLink)
        else
            button.itemlevel:SetText("")
            button.__gwLastItemLink = nil
        end
    end

    if quality and quality > 1 then
        local r, g, b = C_Item.GetItemQualityColor(quality)
        button.backdrop:SetBackdropBorderColor(r, g, b)
        return
    end

    button.backdrop:SetBackdropBorderColor(1, 1, 1, 1, 0.8)
end

local function SkinHeader()
    InspectFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(InspectFrame)
    GW.CreateFrameHeaderWithBody(InspectFrame, InspectNameText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png", {}, 20)
    InspectFrame.gwHeader.windowIcon:SetSize(48, 48)
    InspectFrame.gwHeader.windowIcon:ClearAllPoints()
    InspectFrame.gwHeader.windowIcon:SetPoint("CENTER", InspectFrame.gwHeader, "BOTTOMLEFT", 6 + 24, 19)

    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectFrameCloseButton:SetPoint("TOPRIGHT", -5, -5)
    InspectFramePortrait:Hide()

    InspectNameText:SetWidth(250)
    InspectNameText:ClearAllPoints()
    InspectNameText:SetPoint("BOTTOMLEFT", InspectFrame.gwHeader, "BOTTOMLEFT", 64, 20)
    InspectNameText:SetJustifyH("LEFT")
    InspectNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)

    InspectLevelText:ClearAllPoints()
    InspectLevelText:SetPoint("TOPLEFT", InspectFrame.gwHeader, "BOTTOMLEFT", 64, 17)
    InspectLevelText:SetJustifyH("LEFT")
    InspectLevelText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

    local function SetPortrait(self)
        if not self.unit then return end -- the window is shown before the unit is known on a target change
        GW.SetHeaderPortrait(InspectFrame.gwHeader, self.unit)
    end
    if InspectFrame_UnitChanged then
        hooksecurefunc("InspectFrame_UnitChanged", SetPortrait)
    end
    InspectFrame:HookScript("OnShow", SetPortrait)
end

-- the number of tabs grows with the expansion: character, talents, pvp and guild
local function SkinTabs()
    local index, previous = 1, nil
    while _G["InspectFrameTab" .. index] do
        local tab = _G["InspectFrameTab" .. index]
        GW.HandleTabs(tab)
        tab:SetSize(80, 24)
        tab:ClearAllPoints()
        if previous then
            tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
        else
            tab:SetPoint("BOTTOMLEFT", InspectFrame, "BOTTOMLEFT", 0, -24)
        end
        previous = tab
        index = index + 1
    end

    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or (name and _G[name .. "Text"])
        if text then
            text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
        end
    end)
end

-- the window has no mover of its own, dragging works on a strip above the header
local function MakeMovable()
    local mover = CreateFrame("Frame", nil, InspectFrame)
    mover:EnableMouse(true)
    mover:SetSize(InspectFrame:GetWidth(), 30)
    mover:SetPoint("BOTTOMLEFT", InspectFrame, "TOPLEFT", 0, -20)
    mover:SetPoint("BOTTOMRIGHT", InspectFrame, "TOPRIGHT", 0, 20)
    mover:RegisterForDrag("LeftButton")
    mover:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
    mover:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

    InspectFrame:SetMovable(true)
    InspectFrame:SetClampedToScreen(true)
    InspectFrame.mover = mover
end

local function SkinPaperDoll()
    InspectPaperDollFrame:GwStripTextures()

    for _, slot in ipairs({InspectPaperDollItemsFrame:GetChildren()}) do
        local name = slot:GetName()
        local icon = name and _G[name .. "IconTexture"]
        local cooldown = name and _G[name .. "Cooldown"]

        slot:GwStripTextures()
        slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
        slot.backdrop:SetAllPoints()
        slot:SetFrameLevel(slot:GetFrameLevel() + 2)
        slot:GwStyleButton()

        if icon then
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:GwSetInside()
        end
        if cooldown then
            GW.RegisterCooldown(cooldown)
        end

        slot.gwTextOverlay = CreateFrame("Frame", nil, slot)
        slot.gwTextOverlay:SetAllPoints()
        slot.gwTextOverlay:SetFrameLevel(slot:GetFrameLevel() + 3)
        slot.itemlevel = slot.gwTextOverlay:CreateFontString(nil, "OVERLAY")
        slot.itemlevel:SetSize(100, 10)
        slot.itemlevel:SetPoint("BOTTOMLEFT", slot, "BOTTOMLEFT", 1, 2)
        slot.itemlevel:SetTextColor(1, 1, 1)
        slot.itemlevel:SetJustifyH("LEFT")
        slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    end

    if InspectPaperDollItemSlotButton_Update then
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", Update_InspectPaperDollItemSlotButton)
    end
end

local function SkinModel()
    for _, border in ipairs(MODEL_BORDERS) do
        local texture = _G["InspectModelFrameBorder" .. border]
        if texture then
            texture:GwKill()
        end
    end

    -- the gw2 paperdoll background replaces blizzards class artwork in the corners
    for _, corner in ipairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
        local background = _G["InspectModelFrameBackground" .. corner]
        if background then
            background:SetAlpha(0)
        end
    end
    if InspectModelFrameBackgroundOverlay then
        InspectModelFrameBackgroundOverlay:SetAlpha(0)
    end

    InspectModelFrame.gwBackground = InspectModelFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    InspectModelFrame.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
    InspectModelFrame.gwBackground:SetAllPoints()
    InspectModelFrame:GwCreateBackdrop("Transparent")

    local left, right = InspectModelFrameRotateLeftButton, InspectModelFrameRotateRightButton
    if left then
        GW.HandleRotateButton(left)
        left:SetPoint("TOPLEFT", 3, -3)
        left:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
        left:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
        left:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
        left:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
    end
    if right then
        GW.HandleRotateButton(right)
        right:SetPoint("TOPLEFT", left or InspectModelFrame, left and "TOPRIGHT" or "TOPLEFT", 3, left and 0 or -3)
        right:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
        right:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
        right:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
        right:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)
    end
end

-- arena teams on the old clients, rated battlegrounds from cataclysm on
local function SkinPvP()
    if not InspectPVPFrame then return end
    InspectPVPFrame:GwStripTextures()

    for _, name in ipairs(PVP_PANELS) do
        local panel = InspectPVPFrame[name]
        if panel then
            panel:GwStripTextures()
            panel:GwCreateBackdrop(GW.BackdropTemplates.Default)
            panel.backdrop:SetPoint("TOPLEFT", 9, -4)
            panel.backdrop:SetPoint("BOTTOMRIGHT", -24, 3)
            panel.backdrop:SetFrameLevel(panel:GetFrameLevel())
        end
    end
end

-- returns false when the skin is switched off, so the flavors can skip their own parts as well
local function SkinInspectFrameBase()
    if not GW.settings.skins.inspection.enabled then return false end

    SkinHeader()
    SkinTabs()
    MakeMovable()
    SkinPaperDoll()
    SkinModel()
    SkinPvP()

    return true
end
GW.SkinInspectFrameBase = SkinInspectFrameBase

-- the classic clients have no talent or glyph panel of their own to skin, the base is their whole skin
if not (GW.Classic or GW.TBC or GW.Wrath or GW.Forever) then return end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameBase, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
