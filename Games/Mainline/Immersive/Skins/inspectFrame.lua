---@class GW2
local GW = select(2, ...)

local function SkinPvpTalents(slot)
    local icon = slot.Texture
    slot:GwStripTextures()
    slot.Border:Hide()

    GW.HandleIcon(icon, true)
    icon.backdrop:SetFrameLevel(2)
end

-- gw2 paperdoll background behind the model instead of blizzards class artwork corners
local function SkinModel()
    for _, corner in pairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
        local bg = _G["InspectModelFrameBackground" .. corner]
        if bg then
            bg:SetAlpha(0)
        end
    end
    InspectModelFrame.BackgroundOverlay:SetAlpha(0)

    InspectModelFrame.gwBackground = InspectModelFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    InspectModelFrame.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
    InspectModelFrame.gwBackground:SetAllPoints()
    InspectModelFrame:GwCreateBackdrop("Transparent")

    InspectLevelText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    InspectTitleText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    InspectGuildText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
end

-- one rating row: bracket name as header, rating and record in one line below
local function SkinPvpStatRow(row, previous, width, index)
    row:SetSize(width, 44)
    row:ClearAllPoints()
    if previous then
        row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
    else
        row:SetPoint("TOPLEFT", InspectPVPFrame, "TOPLEFT", 20, -150)
    end
    row:GwCreateBackdrop("Transparent")
    -- zebra like the other gw2 lists
    row.gwZebra = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.gwZebra:SetAllPoints()
    row.gwZebra:SetColorTexture(1, 1, 1, index % 2 == 0 and 0.03 or 0.07)

    row.BGType:ClearAllPoints()
    row.BGType:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -6)
    row.BGType:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
    row.BGType:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    row.RatingLabel:ClearAllPoints()
    row.RatingLabel:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 10, 7)
    row.Rating:ClearAllPoints()
    row.Rating:SetPoint("LEFT", row.RatingLabel, "RIGHT", 4, 0)
    row.RecordLabel:ClearAllPoints()
    row.RecordLabel:SetPoint("LEFT", row.Rating, "RIGHT", 18, 0)
    row.Record:ClearAllPoints()
    row.Record:SetPoint("LEFT", row.RecordLabel, "RIGHT", 4, 0)
    for _, text in pairs({row.RatingLabel, row.Rating, row.RecordLabel, row.Record}) do
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    end
    row.RatingLabel:SetTextColor(0.7, 0.7, 0.7)
    row.RecordLabel:SetTextColor(0.7, 0.7, 0.7)
end

local function SkinPvpFrame(frameWidth)
    local pvp = InspectPVPFrame
    pvp.BG:GwKill()
    pvp.SmallWreath:SetAlpha(0) -- would sit under the gw2 header portrait

    pvp.HKs:ClearAllPoints()
    pvp.HKs:SetPoint("TOP", pvp, "TOP", 0, -34)
    pvp.HKs:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    pvp.HKs:SetTextColor(0.8, 0.8, 0.8)

    pvp.HonorLevel:ClearAllPoints()
    pvp.HonorLevel:SetPoint("TOP", pvp, "TOP", 0, -56)
    pvp.HonorLevel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    pvp.HonorLevel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    -- pvp talents as a centered row below the honor level
    for i = 1, 3 do
        local slot = pvp["TalentSlot" .. i]
        SkinPvpTalents(slot)
        slot:ClearAllPoints()
        slot:SetPoint("TOP", pvp, "TOP", (i - 2) * 48, -90)
    end

    local previous
    local rows = { pvp.RatedBG, pvp.Arena2v2, pvp.Arena3v3, pvp.RatedSoloShuffle, pvp.RatedBGBlitz }
    for i, row in ipairs(rows) do
        SkinPvpStatRow(row, previous, frameWidth - 40, i)
        previous = row
    end

    -- blizzard never hides the talent slots, only the talent texture inside; without any talent the
    -- row would stay as an empty gap, so fade empty slots and pull the rating rows up
    hooksecurefunc("InspectPVPFrame_Update", function()
        local hasTalent = false
        for _, slot in ipairs(pvp.Slots) do
            local shown = slot.Texture and slot.Texture:IsShown()
            slot:SetAlpha(shown and 1 or 0)
            hasTalent = hasTalent or shown
        end
        pvp.RatedBG:SetPoint("TOPLEFT", pvp, "TOPLEFT", 20, hasTalent and -150 or -100)
    end)
end

local function SkinGuildFrame()
    InspectGuildFrameBG:GwKill()
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

local function SkinInspectFrameOnLoad()
    if not GW.settings.INSPECTION_SKIN_ENABLED then return end

    local w, _ = InspectFrame:GetSize()
    InspectFrame:GwStripTextures()
    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectPaperDollFrame.ViewButton:GwSkinButton(false, true)

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

    InspectFrame.mover = CreateFrame("Frame", nil, InspectFrame)
    InspectFrame.mover:EnableMouse(true)
    InspectFrame:SetMovable(true)
    InspectFrame.mover:SetSize(w, 30)
    InspectFrame.mover:SetPoint("BOTTOMLEFT", InspectFrame, "TOPLEFT", 0, -20)
    InspectFrame.mover:SetPoint("BOTTOMRIGHT", InspectFrame, "TOPRIGHT", 0, 20)
    InspectFrame.mover:RegisterForDrag("LeftButton")
    InspectFrame:SetClampedToScreen(true)
    InspectFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    InspectFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)

    local previous = nil
    for i = 1, 3 do
        local tab = _G["InspectFrameTab" .. i]
        GW.HandleTabs(tab)
        tab:SetSize(80, 24)
        tab:ClearAllPoints()
        if not previous then
            tab:SetPoint("TOPLEFT", InspectFrame, "BOTTOMLEFT", 0, 2)
        else
            tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
        end
        previous = tab
    end

    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    InspectModelFrame:GwStripTextures()
    InspectModelFrameBorderTopLeft:GwKill()
    InspectModelFrameBorderTopRight:GwKill()
    InspectModelFrameBorderTop:GwKill()
    InspectModelFrameBorderLeft:GwKill()
    InspectModelFrameBorderRight:GwKill()
    InspectModelFrameBorderBottomLeft:GwKill()
    InspectModelFrameBorderBottomRight:GwKill()
    InspectModelFrameBorderBottom:GwKill()
    InspectModelFrameBorderBottom2:GwKill()

    InspectPaperDollItemsFrame.InspectTalents:GwSkinButton(false, true)

    SkinModel()

    for _, Slot in pairs({InspectPaperDollItemsFrame:GetChildren()}) do
        -- the talents button is a child as well; a plain return here used to abort the whole skin
        if (Slot:IsObjectType("Button") or Slot:IsObjectType("ItemButton")) and Slot.icon then
            GW.HandleIcon(Slot.icon, true, GW.BackdropTemplates.DefaultWithColorableBorder)

            Slot.icon.backdrop:SetFrameLevel(Slot:GetFrameLevel())
            Slot.icon:GwSetInside()
            Slot:GwStripTextures()
            GW.HandleIconBorder(Slot.IconBorder, Slot.icon.backdrop)

            -- item level like on our own character window slots; the icon backdrop is a child frame of
            -- the slot and would draw over a font string on the slot itself, so the text gets its own
            -- frame above it
            Slot.gwTextOverlay = CreateFrame("Frame", nil, Slot)
            Slot.gwTextOverlay:SetAllPoints()
            Slot.gwTextOverlay:SetFrameLevel(Slot:GetFrameLevel() + 3)
            Slot.itemlevel = Slot.gwTextOverlay:CreateFontString(nil, "OVERLAY")
            Slot.itemlevel:SetSize(100, 10)
            Slot.itemlevel:SetPoint("BOTTOMLEFT", Slot, "BOTTOMLEFT", 1, 2)
            Slot.itemlevel:SetTextColor(1, 1, 1)
            Slot.itemlevel:SetJustifyH("LEFT")
            Slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
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

    SkinPvpFrame(w)
    SkinGuildFrame()
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
