---@class GW2
local GW = select(2, ...)

local function UpdateConversionSlot(slot)
    local normal = slot:GetNormalTexture()
    if normal then
        normal:GwSetInside(slot)
    end
    local pushed = slot:GetPushedTexture()
    if pushed then
        pushed:SetColorTexture(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
        pushed:GwSetInside(slot)
    end
    local location = ItemInteractionFrame:GetItemLocation()
    SetItemButtonQuality(slot, location and slot.icon:IsShown() and C_Item.GetItemQuality(location) or nil)
end

local function SkinConversionSlot(slot)
    slot.ButtonFrame:SetAlpha(0)
    if slot.Glow then
        slot.Glow:SetAlpha(0)
    end
    slot:GwCreateBackdrop("Transparent")
    slot.icon:GwSetInside(slot)
    GW.HandleIcon(slot.icon)
    GW.HandleIconBorder(slot.IconBorder)
    UpdateConversionSlot(slot)
    hooksecurefunc(slot, "RefreshIcon", UpdateConversionSlot)
end

local function ApplyItemInteractionSkin()
    if not GW.settings.skins.itemInteraction.enabled then return end
    local frame = ItemInteractionFrame

    GW.HandlePortraitFrame(frame)
    GW.HandlePortraitFrameArt(frame)
    if frame.TitleContainer then
        frame.TitleContainer:Hide()
    end
    GW.CreateFrameHeaderWithBody(frame, frame:GetTitleText(), nil, nil, nil, nil, true)
    frame.gwHeader.windowIcon:SetSize(48, 48)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "BOTTOMLEFT", 30, 19)
    frame:HookScript("OnShow", function(self)
        GW.SetHeaderPortrait(self.gwHeader, UnitExists("npc") and "npc" or "player")
    end)
    frame.Background:SetAlpha(0)
    local details = GW.CreateDetailsBackgroundTexture(frame, 1)
    details:SetAllPoints(frame.Background)

    frame.Description:GwLockTextColor(GW.Colors.FallbackWhite:GetRGB())
    frame.CurrencyCost.Costs:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    GW.HookEquipmentFlyoutSkin()

    frame.ItemSlot.GlowOverlay:SetAlpha(0)
    frame.ItemSlot:GwCreateBackdrop("Transparent")
    frame.ItemSlot.Icon:GwSetInside(frame.ItemSlot)
    GW.HandleIcon(frame.ItemSlot.Icon)
    SkinConversionSlot(frame.ItemConversionFrame.ItemConversionInputSlot)
    SkinConversionSlot(frame.ItemConversionFrame.ItemConversionOutputSlot)

    local buttonFrame = frame.ButtonFrame
    buttonFrame:GwStripTextures()
    buttonFrame.MoneyFrameEdge:SetAlpha(0)
    buttonFrame.ActionButton:GwSkinButton(false, true)
    GW.HandleIcon(buttonFrame.Currency.Icon)
end

local function LoadItemInteractionSkin()
    GW.RegisterLoadHook(ApplyItemInteractionSkin, "Blizzard_ItemInteractionUI", ItemInteractionFrame)
end
GW.LoadItemInteractionSkin = LoadItemInteractionSkin
