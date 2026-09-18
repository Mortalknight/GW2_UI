---@class GW2
local GW = select(2, ...)

--[[
    Forever (camelot) inspect window. Blizzard mixes it from the retail window (ButtonFrameTemplate,
    title text, portrait), a camelot paperdoll (talents and view button on the paperdoll itself, a
    model with control panel, slots with a border art frame) and the retail guild panel. There is no
    pvp panel. The bottom tabs ship hidden, the switching is done by side "mode tabs" with the unit
    portrait and the guild icon - we hide those and use the bottom tabs like on every other client,
    blizzards tab code (InspectFrameTab_OnClick, PanelTemplates_*) drives them just the same.
]]

-- gw2 paperdoll background behind the model instead of blizzards class artwork corners and borders
local function SkinModel()
    for _, corner in pairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
        local bg = _G["InspectModelFrameBackground" .. corner]
        if bg then
            bg:SetAlpha(0)
        end
    end
    if InspectModelFrame.BackgroundOverlay then
        InspectModelFrame.BackgroundOverlay:SetAlpha(0)
    end
    for _, border in pairs({"TopLeft", "TopRight", "Top", "Left", "Right", "BottomLeft", "BottomRight", "Bottom", "Bottom2"}) do
        local texture = _G["InspectModelFrameBorder" .. border]
        if texture then
            texture:GwKill()
        end
    end

    InspectModelFrame.gwBackground = InspectModelFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    InspectModelFrame.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
    InspectModelFrame.gwBackground:SetAllPoints()
    InspectModelFrame:GwCreateBackdrop("Transparent")
    GW.HandleModelControlFrame(InspectModelFrame.controlFrame)

    InspectLevelText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    InspectTitleText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    InspectGuildText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
end

local function SkinSlots()
    for _, slot in pairs({InspectPaperDollItemsFrame:GetChildren()}) do
        if (slot:IsObjectType("Button") or slot:IsObjectType("ItemButton")) and slot.icon then
            GW.HandleIcon(slot.icon, true, GW.BackdropTemplates.DefaultWithColorableBorder)
            slot.icon.backdrop:SetFrameLevel(slot:GetFrameLevel())
            slot.icon:GwSetInside()
            slot:GwStripTextures()
            -- the camelot slot art sits on a child frame of its own
            if slot.BorderFrame then
                slot.BorderFrame:GwStripTextures()
            end
            if GW.HandleIconBorder then
                GW.HandleIconBorder(slot.IconBorder, slot.icon.backdrop)
            end

            -- item level like on our own character window slots; the icon backdrop is a child frame of
            -- the slot and would draw over a font string on the slot itself, so the text gets its own
            -- frame above it
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
    end

    -- blizzard refreshes each slot here once the inspect data arrived
    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        if not button.itemlevel then return end
        local unit = InspectFrame.unit
        local itemLink = unit and GetInventoryItemLink(unit, button:GetID())
        if itemLink then
            GW.SetItemLevel(button, GetInventoryItemQuality(unit, button:GetID()), itemLink)
        else
            button.itemlevel:SetText("")
            button.__gwLastItemLink = nil
        end
    end)
end

local function SkinTabs()
    -- blizzards side mode tabs go, the bottom tabs come back and get the gw2 look
    if InspectFrame.ModeTabs then
        InspectFrame.ModeTabs:Hide()
        InspectFrame.ModeTabs.Show = GW.NoOp
    end
    if InspectFrame.TabIndicators then
        InspectFrame.TabIndicators:Hide()
    end

    local index, previous = 1, nil
    while _G["InspectFrameTab" .. index] do
        local tab = _G["InspectFrameTab" .. index]
        GW.HandleTabs(tab)
        tab:SetSize(80, 24)
        tab:ClearAllPoints()
        if previous then
            tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
        else
            tab:SetPoint("TOPLEFT", InspectFrame, "BOTTOMLEFT", 0, 2)
        end
        tab:Show()
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

local function SkinGuildFrame()
    if InspectGuildFrameBG then
        InspectGuildFrameBG:GwKill()
    end
    local guild = InspectGuildFrame
    if guild.guildName then
        guild.guildName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
        guild.guildName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
    for _, key in pairs({"guildRealmName", "guildLevel", "guildNumMembers"}) do
        if guild[key] then
            guild[key]:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
    end
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

local function SkinInspectFrameOnLoad()
    if not GW.settings.skins.inspection.enabled then return end

    InspectFrame:GwStripTextures()
    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectPaperDollFrame.ViewButton:GwSkinButton(false, true)
    InspectPaperDollFrame.InspectTalents:GwSkinButton(false, true)

    GW.CreateFrameHeaderWithBody(InspectFrame, InspectFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon.png", {InspectPaperDollItemsFrame}, nil, false, true)
    InspectFrame.gwHeader.windowIcon:SetSize(48, 48)
    InspectFrame.gwHeader.windowIcon:ClearAllPoints()
    InspectFrame.gwHeader.windowIcon:SetPoint("CENTER", InspectFrame.gwHeader, "BOTTOMLEFT", 6 + 24, 19)
    -- two line header next to the portrait: name on top, level and class below (blizzards level
    -- text wrapper moves up from the body, its tooltip comes along)
    InspectFrameTitleText:ClearAllPoints()
    InspectFrameTitleText:SetPoint("BOTTOMLEFT", InspectFrame.gwHeader, "BOTTOMLEFT", 64, 20)
    -- anchored at its top: the wrapper is a resize layout frame whose height is only known after the
    -- first text update, and the text hangs from its top edge
    InspectPaperDollFrame.LevelTextWrapper:ClearAllPoints()
    InspectPaperDollFrame.LevelTextWrapper:SetPoint("TOPLEFT", InspectFrame.gwHeader, "BOTTOMLEFT", 64, 17)
    InspectLevelText:SetJustifyH("LEFT")
    InspectFrame.gwHeader.BGLEFT:ClearAllPoints()
    InspectFrame.gwHeader.BGLEFT:SetPoint("BOTTOMLEFT", InspectFrame.gwHeader, "BOTTOMLEFT", 0, 0)
    InspectFrame.gwHeader.BGLEFT:SetPoint("TOPRIGHT", InspectFrame.gwHeader, "TOPRIGHT", 0, 0)
    InspectFrame.gwHeader.BGRIGHT:ClearAllPoints()
    InspectFrame.gwHeader.BGRIGHT:SetPoint("BOTTOMRIGHT", InspectFrame.gwHeader, "BOTTOMRIGHT", 0, 0)
    InspectFrame.gwHeader.BGRIGHT:SetPoint("TOPLEFT", InspectFrame.gwHeader, "TOPLEFT", 0, 0)
    InspectFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)

    hooksecurefunc(InspectFrame, "SetPortraitToUnit", function(_, unit)
        GW.SetHeaderPortrait(InspectFrame.gwHeader, unit)
    end)
    InspectFramePortrait:Hide()

    MakeMovable()
    SkinTabs()
    SkinModel()
    SkinSlots()
    SkinGuildFrame()
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
