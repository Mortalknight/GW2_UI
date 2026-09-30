---@class GW2
local GW = select(2, ...)

-- The dressing room of the classic clients: a ButtonFrameTemplate window with a DressUpModel instead of the
-- model scene, the set dropdown and the detail panels of the retail client, so it gets its own skin; retail
-- keeps dressUpFrame.lua. Classic, TBC, Wrath and Mists all share the same frame.
if GW.isModern then return end

local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png"

-- classic names its rotation buttons after the model, not the camera: the left button turns to the right
local function SkinRotateButtons(model)
    local left, right = DressUpModelFrameRotateLeftButton, DressUpModelFrameRotateRightButton
    if not left or not right then return end

    -- the button named right sits on the left and shows the arrow turning left
    GW.HandleClassicRotateButton(right, "left")
    right:ClearAllPoints()
    right:SetPoint("TOPLEFT", model, "TOPLEFT", 3, 4)
    GW.HandleClassicRotateButton(left, "right")
    left:ClearAllPoints()
    left:SetPoint("TOPLEFT", right, "TOPRIGHT", 3, 0)
end

-- the window has no mover of its own, dragging works on a strip over the header
local function MakeMovable()
    local mover = CreateFrame("Frame", nil, DressUpFrame)
    mover:EnableMouse(true)
    mover:SetPoint("BOTTOMLEFT", DressUpFrame, "TOPLEFT", 0, -20)
    mover:SetPoint("BOTTOMRIGHT", DressUpFrame, "TOPRIGHT", 0, 20)
    mover:SetHeight(30)
    mover:RegisterForDrag("LeftButton")
    mover:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
    mover:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
    DressUpFrame:SetMovable(true)
    DressUpFrame:SetClampedToScreen(true)
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

    -- border, title bar and inset of the template are child frames the strip does not reach
    GW.HandlePortraitFrame(DressUpFrame)
    GW.HandlePortraitFrameArt(DressUpFrame)
    -- the inset only draws a box around the model, its NineSlice border stays otherwise
    if DressUpFrame.Inset then
        DressUpFrame.Inset:SetAlpha(0)
    end
    -- the template brings a second, empty DressUpFrameTitleText; the frame's own title carries the text
    local title = DressUpFrame.TitleText or DressUpFrameTitleText
    GW.CreateFrameHeaderWithBody(DressUpFrame, title, WINDOW_ICON, {}, nil, false, true)
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    -- blizzard centers it in a fixed width, our header starts it on the left
    title:SetJustifyH("LEFT")
    if DressUpFrame.TitleContainer then
        DressUpFrame.TitleContainer:Hide()
    end

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

    -- blizzard hangs the hint below the title, which now lives in our header, and the model starts right
    -- below it; the free spot is left of the two buttons
    local hint = DressUpFrameDescriptionText
    if hint then
        hint:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        hint:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
        hint:SetJustifyH("LEFT")
        hint:ClearAllPoints()
        hint:SetPoint("BOTTOMLEFT", DressUpFrame, "BOTTOMLEFT", 10, 4)
        hint:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", -6, 0)
        hint:SetHeight(28)
    end

    DressUpFrameCloseButton:GwSkinButton(true)
    DressUpFrameCloseButton:SetSize(20, 20)
    DressUpFrameCloseButton:ClearAllPoints()
    DressUpFrameCloseButton:SetPoint("TOPRIGHT", DressUpFrame, "TOPRIGHT", -10, -2)
    DressUpFrameResetButton:GwSkinButton(false, true)
    DressUpFrameCancelButton:GwSkinButton(false, true)

    local model = DressUpModelFrame
    if model then
        SkinRotateButtons(model)
    end

    MakeMovable()
    SkinSideDressUpFrame()
end
GW.LoadDressUpFrameSkin = LoadDressUpFrameSkin
