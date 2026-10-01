---@class GW2
local GW = select(2, ...)

-- The choice window of the modern clients (campaign choices, weekly quest picks). Blizzard lays out its art again
-- on every show for the texture kit of the choice, so the art is hidden after each setup. Kits that only show their
-- options (torghast, covenants, ...) bring their own full screen art and stay as they are.

local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png"
local FRAME_ART = {"NineSlice", "BorderOverlay"}
local TITLE_ART = {"Left", "Middle", "Right"}
-- room below the buttons of a card
local CARD_BOTTOM_PADDING = 14

-- only the normal options have a card with header, art and buttons, the other templates bring their own look
local function SkinOption(option)
    if not (option.Header and option.Header.Contents) then return end

    -- the cards get the background of the gw detail panels
    if not option.tex then
        GW.AddDetailsBackground(option)
        option.tex:SetPoint("BOTTOMRIGHT", option, "BOTTOMRIGHT", 0, -CARD_BOTTOM_PADDING)
        -- blizzard's size: the header area is fixed and longer names would be cut
        option.Header.Contents.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        option.Artwork:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    end
    option.Background:SetAlpha(0)
    option.Header.Ribbon:SetAlpha(0)
    -- the frame keeps its size for the layout, only its art goes; options without a picture hide the artwork
    option.ArtworkBorder:SetAlpha(0)
    option.Artwork.backdrop:SetShown(option.Artwork:IsShown())
    if option.SubHeader then
        option.SubHeader.BG:SetAlpha(0)
    end
    option.Header.Contents.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    option.OptionText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    for buttonFrame in option.OptionButtonsContainer.buttonFramePool:EnumerateActive() do
        buttonFrame.Button:GwSkinButton(false, true)
    end
end

local function SetupFrame(frame)
    -- false for the kits that only show their options
    local showsFrame = frame.Background:IsShown()
    frame.gwHeader:SetShown(showsFrame)
    frame.tex:SetShown(showsFrame)
    if not showsFrame then return end

    for _, key in ipairs(FRAME_ART) do
        frame[key]:Hide()
    end
    for _, key in ipairs(TITLE_ART) do
        frame.Title[key]:SetAlpha(0)
    end
    frame.Background.BackgroundTile:SetAlpha(0)
    frame.Header.Texture:SetAlpha(0)

    -- blizzard places the close button per kit
    local closeButton = frame.CloseButton
    if closeButton.Border then
        closeButton.Border:SetAlpha(0)
    end
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -2)
end

local function SetupOptions(frame)
    if not frame.Background:IsShown() then return end
    for option in frame.optionPools:EnumerateActive() do
        SkinOption(option)
    end
end

local function ApplyPlayerChoiceSkin()
    if not GW.settings.skins.playerChoice.enabled then return end

    -- the gw window: header with icon and the question as title, the body background below
    local frame = PlayerChoiceFrame
    GW.CreateFrameHeaderWithBody(frame, frame.Title.Text, WINDOW_ICON)
    frame.Title.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    frame.Title.Text:SetJustifyH("LEFT")
    frame.CloseButton:GwSkinButton(true)
    frame.CloseButton:SetSize(20, 20)

    hooksecurefunc(frame, "SetupFrame", SetupFrame)
    hooksecurefunc(frame, "SetupOptions", SetupOptions)
end

local function LoadPlayerChoiceSkin()
    GW.RegisterLoadHook(ApplyPlayerChoiceSkin, "Blizzard_PlayerChoice", PlayerChoiceFrame)
end
GW.LoadPlayerChoiceSkin = LoadPlayerChoiceSkin
