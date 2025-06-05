local _, GW = ...

local function SkinPvpTalents(slot)
    local icon = slot.Texture
    slot:GwStripTextures()
    slot.Border:Hide()

    GW.HandleIcon(icon, true)
    icon.backdrop:SetFrameLevel(2)
end

local function SkinInspectFrameOnLoad()
    if not GW.settings.INSPECTION_SKIN_ENABLED then return end

    local w, _ = InspectFrame:GetSize()
    InspectFrame:GwStripTextures()
    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectPaperDollFrame.ViewButton:GwSkinButton(false, true)

    GW.CreateFrameHeaderWithBody(InspectFrame, InspectFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/macro-window-icon", {InspectPaperDollItemsFrame}, nil, false, true)
    InspectFrame.gwHeader.windowIcon:SetSize(65, 65)
    InspectFrame.gwHeader.windowIcon:ClearAllPoints()
    InspectFrame.gwHeader.windowIcon:SetPoint("CENTER", InspectFrame.gwHeader.BGLEFT, "LEFT", 25, -5)
    InspectFrame.gwHeader.BGLEFT:ClearAllPoints()
    InspectFrame.gwHeader.BGLEFT:SetPoint("BOTTOMLEFT", InspectFrame.gwHeader, "BOTTOMLEFT", 0, 0)
    InspectFrame.gwHeader.BGLEFT:SetPoint("TOPRIGHT", InspectFrame.gwHeader, "TOPRIGHT", 0, 0)
    InspectFrame.gwHeader.BGRIGHT:ClearAllPoints()
    InspectFrame.gwHeader.BGRIGHT:SetPoint("BOTTOMRIGHT", InspectFrame.gwHeader, "BOTTOMRIGHT", 0, 0)
    InspectFrame.gwHeader.BGRIGHT:SetPoint("TOPLEFT", InspectFrame.gwHeader, "TOPLEFT", 0, 0)
    InspectFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    hooksecurefunc(InspectFrame, "SetPortraitToUnit", function(self, unit)
        SetPortraitTexture(InspectFrame.gwHeader.windowIcon, unit);
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

    -- PvP Talents
    for i = 1, 3 do
        SkinPvpTalents(InspectPVPFrame["TalentSlot" .. i])
    end

    for i = 1, 3 do
        GW.HandleTabs(_G["InspectFrameTab" .. i])
        _G["InspectFrameTab" .. i]:SetSize(80, 24)
        _G["InspectFrameTab" .. i]:ClearAllPoints()
        if i == 1 then
            _G["InspectFrameTab" .. i]:SetPoint("TOPLEFT", InspectFrame, "BOTTOMLEFT", 0, 2)
        else
            _G["InspectFrameTab" .. i]:SetPoint("LEFT", _G["InspectFrameTab" .. i - 1], "RIGHT", 0, 0)
        end
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

    InspectModelFrame.BackgroundOverlay:SetColorTexture(0, 0, 0)

    -- Give inspect frame model backdrop it's color back
    for _, corner in pairs({"TopLeft","TopRight","BotLeft","BotRight"}) do
        local bg = _G["InspectModelFrameBackground" .. corner]
        if bg then
            bg:SetDesaturated(false)
            hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
                if value and bckgnd.ignoreDesaturated then
                    bckgnd:SetDesaturated(false)
                end
            end)
        end
    end

    for _, Slot in pairs({InspectPaperDollItemsFrame:GetChildren()}) do
        if Slot:IsObjectType("Button") or Slot:IsObjectType("ItemButton") then
            if not Slot.icon then return end
            GW.HandleIcon(Slot.icon, true, GW.BackdropTemplates.DefaultWithColorableBorder)

            Slot.icon.backdrop:SetFrameLevel(Slot:GetFrameLevel())
            Slot.icon:GwSetInside()
            Slot:GwStripTextures()
            GW.HandleIconBorder(Slot.IconBorder, Slot.icon.backdrop)
        end
    end

    InspectPVPFrame.BG:GwKill()
    InspectGuildFrameBG:GwKill()
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
