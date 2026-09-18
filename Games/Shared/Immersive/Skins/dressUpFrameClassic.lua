---@class GW2
local GW = select(2, ...)

-- The dressing room of the classic clients. It is a plain window with a DressUpModel instead of the model scene,
-- the set dropdown and the detail panels of the retail client, so it gets its own skin; retail keeps
-- dressUpFrame.lua. Classic, TBC, Wrath and Mists all share the same frame.
if GW.isModern then return end

local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png"

-- classic names its rotation buttons after the model, not the camera: the left button turns to the right
local function SkinRotateButtons(model)
    local left, right = DressUpModelFrameRotateLeftButton, DressUpModelFrameRotateRightButton
    if not left or not right then return end

    for _, button in ipairs({right, left}) do
        GW.HandleRotateButton(button)
        button:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
        button:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
    end

    right:ClearAllPoints()
    right:SetPoint("TOPLEFT", model, "TOPLEFT", 3, -3)
    right:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
    right:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)

    left:ClearAllPoints()
    left:SetPoint("TOPLEFT", right, "TOPRIGHT", 3, 0)
    left:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
    left:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)
end

-- the small preview window of quest rewards and auctions
local function SkinSideDressUpFrame()
    if not SideDressUpFrame then return end

    SideDressUpFrame:GwStripTextures()
    SideDressUpFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true, -2, -2)
    if SideDressUpFrame.BGTopLeft then
        SideDressUpFrame.BGTopLeft:Hide()
    end
    if SideDressUpFrame.BGBottomLeft then
        SideDressUpFrame.BGBottomLeft:Hide()
    end
    if SideDressUpFrame.ResetButton then
        SideDressUpFrame.ResetButton:GwSkinButton(false, true)
    end
    if SideDressUpFrameCloseButton then
        SideDressUpFrameCloseButton:GwSkinButton(true)
        SideDressUpFrameCloseButton:SetSize(18, 18)
    end
end

local function LoadDressUpFrameSkin()
    if not GW.settings.skins.inspection.enabled then return end

    DressUpFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(DressUpFrame, DressUpFrameTitleText, WINDOW_ICON, {}, nil, false, true)
    DressUpFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    -- framed player portrait in the header like the inspect and merchant frames
    DressUpFrame.gwHeader.windowIcon:SetSize(48, 48)
    DressUpFrame.gwHeader.windowIcon:ClearAllPoints()
    DressUpFrame.gwHeader.windowIcon:SetPoint("CENTER", DressUpFrame.gwHeader, "BOTTOMLEFT", 6 + 24, 19)
    if DressUpFramePortrait then
        DressUpFramePortrait:Hide()
    end
    DressUpFrame:HookScript("OnShow", function()
        GW.SetHeaderPortrait(DressUpFrame.gwHeader, "player")
    end)

    if DressUpFrameDescriptionText then
        DressUpFrameDescriptionText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        DressUpFrameDescriptionText:SetTextColor(0.8, 0.8, 0.8)
    end

    DressUpFrameCloseButton:GwSkinButton(true)
    DressUpFrameCloseButton:SetSize(20, 20)
    DressUpFrameResetButton:GwSkinButton(false, true)
    DressUpFrameCancelButton:GwSkinButton(false, true)

    local model = DressUpModelFrame
    if model then
        model:GwCreateBackdrop("Transparent")
        model.backdrop:SetBackdropBorderColor(0, 0, 0, 0.8) -- dark frame like the item slots, not white
        SkinRotateButtons(model)
    end

    SkinSideDressUpFrame()
end
GW.LoadDressUpFrameSkin = LoadDressUpFrameSkin
