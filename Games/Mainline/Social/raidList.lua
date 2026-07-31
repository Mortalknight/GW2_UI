---@class GW2
local GW = select(2, ...)

local function SkinRaidInfoSideWindow()
    local RaidInfoFrame = SocialUIFrame.RaidInfoFrame
    if not RaidInfoFrame then return end

    RaidInfoFrame:GwStripTextures()
    if RaidInfoFrame.Border then
        RaidInfoFrame.Border:GwStripTextures()
        if RaidInfoFrame.Border.NineSlice then
            RaidInfoFrame.Border.NineSlice:SetAlpha(0)
        end
    end
    RaidInfoFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    RaidInfoFrame:ClearAllPoints()
    RaidInfoFrame:SetPoint("TOPLEFT", SocialUIFrame.gwHeader, "BOTTOMRIGHT", 45, 1)
    RaidInfoFrame.CloseButton:GwSkinButton(true)
    RaidInfoFrame.ExtendButton:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(RaidInfoFrame.ScrollBar)
    GW.HandleScrollControls(RaidInfoFrame)
    hooksecurefunc(RaidInfoFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
end

function GW.SkinRaidList()
    -- 12.1: Der Schlachtzugs-Tab ist eine SocialUI-View (RaidFrameSocialTemplate)
    local RaidView = SocialUIFrame.RaidFrame
    if not RaidView then return end

    RaidView.AllAssistCheckButton:GwSkinCheckButton()
    RaidView.AllAssistCheckButton:SetSize(18, 18)

    RaidView.RaidInfoButton:GwSkinButton(false, true)
    RaidView.ConvertToRaidButton:GwSkinButton(false, true)

    if RaidView.RaidDescription then
        RaidView.RaidDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        RaidView.RaidDescription:SetTextColor(1, 1, 1)
    end

    if RaidView.TankFrame then
        RaidView.TankFrame.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank.png")
    end
    if RaidView.HealerFrame then
        RaidView.HealerFrame.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer.png")
    end
    if RaidView.DamagerFrame then
        RaidView.DamagerFrame.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps.png")
    end

    SkinRaidInfoSideWindow()
end
