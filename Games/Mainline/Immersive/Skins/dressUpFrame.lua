---@class GW2
local GW = select(2, ...)

local function SetItemQuality(slot)
    if not slot.slotState and not slot.isHiddenVisual and slot.transmogID then
        slot.Icon.backdrop:SetBackdropBorderColor(slot.Name:GetTextColor())
    else
        slot.Icon.backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end

-- rows of the transmog set list (created on demand by the scroll box, hooked via the button mixin)
local function SkinSetListRow(row)
    if row.gwSkinned then return end
    row.gwSkinned = true

    row.BackgroundTexture:SetAlpha(0)
    row:GwCreateBackdrop("Transparent")
    row.IconBorder:SetAlpha(0)
    GW.HandleIcon(row.Icon, true)
    row.ItemName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    row.ItemSlot:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
end

local function LoadDressUpFrameSkin()
    if not GW.settings.skins.inspection.enabled then return end

    DressUpFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(DressUpFrame, DressUpFrameTitleText, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {}, nil, false, true)
    DressUpFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    -- framed player portrait in the header like the inspect and merchant frames; blizzard refreshes
    -- its own portrait on every show, so it stays hidden and ours follows
    DressUpFrame.gwHeader.windowIcon:SetSize(48, 48)
    DressUpFrame.gwHeader.windowIcon:ClearAllPoints()
    DressUpFrame.gwHeader.windowIcon:SetPoint("CENTER", DressUpFrame.gwHeader, "BOTTOMLEFT", 6 + 24, 19)
    if DressUpFramePortrait then
        DressUpFramePortrait:Hide()
    end
    DressUpFrame:HookScript("OnShow", function()
        GW.SetHeaderPortrait(DressUpFrame.gwHeader, "player")
    end)

    DressUpFrameCloseButton:GwSkinButton(true)
    DressUpFrameCloseButton:SetSize(20, 20)
    DressUpFrameResetButton:GwSkinButton(false, true)
    DressUpFrameCancelButton:GwSkinButton(false, true)

    -- top row: set dropdown, the regular gw2 save button and the details toggle aligned to the
    -- dropdowns height and edges
    local dropdown = DressUpFrameCustomSetDropdown
    dropdown:GwHandleDropDownBox()

    local save = dropdown.SaveButton
    save:GwSkinButton(false, true)
    save:ClearAllPoints()
    save:SetSize(88, 22)
    save:SetPoint("LEFT", dropdown.backdrop, "RIGHT", 4, 0)

    if DressUpFrame.LinkButton then
        DressUpFrame.LinkButton:GwSkinButton(false, true)

        local toggle = DressUpFrame.ToggleCustomSetDetailsButton
        toggle:GwSkinButton(false, true, false, true)
        toggle:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
        toggle:ClearAllPoints()
        toggle:SetSize(22, 22)
        toggle:SetPoint("LEFT", save, "RIGHT", 4, 0)

        local icon = toggle:CreateTexture(nil, "OVERLAY")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetTexture(1392954)
        icon:SetDesaturated(true)

        DressUpFrame.CustomSetDetailsPanel:DisableDrawLayer("BACKGROUND")
        DressUpFrame.CustomSetDetailsPanel:DisableDrawLayer("OVERLAY")
        DressUpFrame.CustomSetDetailsPanel:GwCreateBackdrop(GW.BackdropTemplates.Default)
    end

    DressUpFrame.MaximizeMinimizeFrame:GwHandleMaxMinFrame()

    -- model area: keep blizzards class artwork, frame it and skin the scene controls
    DressUpFrame.ModelBackground:SetDrawLayer("BACKGROUND", 2)
    DressUpFrame.ModelScene:GwCreateBackdrop("Transparent")
    DressUpFrame.ModelScene.backdrop:SetBackdropBorderColor(0, 0, 0, 0.8) -- dark frame like the item slots, not white
    GW.HandleModelSceneControlFrame(DressUpFrame.ModelScene.ControlFrame)

    -- transmog set selection panel (opens for set links)
    local sets = DressUpFrame.SetSelectionPanel
    if sets then
        sets.Border:SetAlpha(0)
        sets.BlackBackground:SetAlpha(0)
        sets:GwCreateBackdrop(GW.BackdropTemplates.Default)
        sets.SetName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        sets.SetName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        GW.HandleTrimScrollBar(sets.ScrollBar)
        if DressUpFrameTransmogSetButtonMixin then
            hooksecurefunc(DressUpFrameTransmogSetButtonMixin, "InitItem", SkinSetListRow)
        end
    end

    if DressUpFrame.CustomSetDetailsPanel then
        hooksecurefunc(DressUpFrame.CustomSetDetailsPanel, "Refresh", function(self)
            if not self.slotPool then return end

            for slot in self.slotPool:EnumerateActive() do
                if not slot.backdrop then
                    slot.Icon:GwCreateBackdrop("Transparent", true, 1, 1)
                    slot.IconBorder:SetAlpha(0)
                    GW.HandleIcon(slot.Icon)
                end

                SetItemQuality(slot)
            end
        end)
        hooksecurefunc(DressUpFrame, "ConfigureSize", function(self)
            self.CustomSetDetailsPanel:ClearAllPoints()
            self.CustomSetDetailsPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
            if self.SetSelectionPanel then
                self.SetSelectionPanel:ClearAllPoints()
                self.SetSelectionPanel:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
            end
        end)
    end

    -- SideDressUpFrame
    SideDressUpFrameCloseButton:GwSkinButton(true)
    SideDressUpFrameCloseButton:SetSize(18, 18)
    SideDressUpFrame.ResetButton:GwSkinButton(false, true)
    SideDressUpFrame:GwStripTextures()
    SideDressUpFrame.BGTopLeft:Hide()
    SideDressUpFrame.BGBottomLeft:Hide()
    SideDressUpFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true, -2, -2)
    if SideDressUpFrame.ModelScene then
        GW.HandleModelSceneControlFrame(SideDressUpFrame.ModelScene.ControlFrame)
    end
end
GW.LoadDressUpFrameSkin = LoadDressUpFrameSkin
