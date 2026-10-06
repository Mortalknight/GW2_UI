---@class GW2
local GW = select(2, ...)

-- guild bank in the look of our own bank, movable like it.
-- the slots get the bag look without our bag backdrop key: that key makes the bag quality hook read
-- player bags with the column id
local BAG_TEXTURES = "Interface/AddOns/GW2_UI/textures/bag/"
local BORDER_TEXTURE = BAG_TEXTURES .. "bagitemborder.png"
local PUSHED_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png"
local TAB_SIZE, TAB_GAP = 28, 4
local SLOTS_PER_COLUMN = 14
local FOOTER_TABS = 4

local function AddTexture(layer, file, width, height)
    local texture = GuildBankFrame:CreateTexture(nil, layer)
    texture:SetTexture(BAG_TEXTURES .. file)
    if width then
        texture:SetSize(width, height)
    end
    return texture
end

local function SkinWindow()
    GuildBankFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(GuildBankFrame)
    GuildBankFrame.Emblem:SetAlpha(0)

    local background = AddTexture("BACKGROUND", "bankbg.png")
    background:SetAllPoints()
    AddTexture("BACKGROUND", "bagheader.png", 512, 64):SetPoint("BOTTOMLEFT", GuildBankFrame, "TOPLEFT")
    AddTexture("BACKGROUND", "bagheader-right.png", 512, 64):SetPoint("BOTTOMRIGHT", GuildBankFrame, "TOPRIGHT")
    local footer = AddTexture("BACKGROUND", "bagfooter.png", 512, 70)
    footer:SetPoint("TOPLEFT", GuildBankFrame, "BOTTOMLEFT", 0, 2)
    footer:SetPoint("TOPRIGHT", GuildBankFrame, "BOTTOMRIGHT", 0, 2)
    local sidePanel = AddTexture("BACKGROUND", "bagleftpanel.png", 40, 512)
    sidePanel:SetPoint("TOPRIGHT", GuildBankFrame, "TOPLEFT")
    sidePanel:SetPoint("BOTTOMRIGHT", GuildBankFrame, "BOTTOMLEFT")
    AddTexture("BORDER", "bagicon.png", 84, 84):SetPoint("CENTER", GuildBankFrame, "TOPLEFT", -16, 16)
    AddTexture("BORDER", "bottom-right.png", 128, 128):SetPoint("BOTTOMRIGHT")

    local title = GuildBankFrame:CreateFontString(nil, "BORDER")
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    title:SetJustifyH("LEFT")
    title:SetPoint("BOTTOMLEFT", GuildBankFrame, "TOPLEFT", 30, 10)
    title:SetText(GUILD_BANK)

    -- tbc has an unnamed close button, its click handler gives it away
    local closeButton = GuildBankFrame.CloseButton
    if not closeButton then
        for _, child in ipairs({GuildBankFrame:GetChildren()}) do
            if child:IsObjectType("Button") and child:GetScript("OnClick") == UIPanelCloseButton_OnClick then
                closeButton = child
                break
            end
        end
    end
    if closeButton then
        closeButton:GwSkinButton(true)
        closeButton:SetSize(20, 20)
        closeButton:ClearAllPoints()
        closeButton:SetPoint("TOPRIGHT", GuildBankFrame, "TOPRIGHT", -10, 30)
    end
end

local function SkinSlot(button)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button.icon:SetAllPoints(button)
    button.icon:SetAlpha(0.9)
    button.IconBorder:SetAllPoints(button)
    button.IconBorder:SetTexture(BORDER_TEXTURE)
    button:GetNormalTexture():SetTexture(nil)

    local highlight = button:GetHighlightTexture()
    highlight:SetAllPoints(button)
    highlight:SetTexture(BORDER_TEXTURE)
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.33)
    button:GetPushedTexture():SetTexture(PUSHED_TEXTURE)
    button:GetPushedTexture():SetAllPoints(button)

    local backdrop = button:CreateTexture(nil, "BACKGROUND")
    backdrop:SetTexture(BAG_TEXTURES .. "bagitembackdrop.png")
    backdrop:SetAllPoints(button)

    button.Count:ClearAllPoints()
    button.Count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -3)
    button.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    button.Count:SetJustifyH("RIGHT")
end

-- the logs and the tab info lie on a details background, so does the bank view without slots
-- (no right to view the tab). only retail colors the slots itself, the classic clients fetch the
-- quality but never show it
local function UpdateBankView(frame)
    frame.gwDetailsBackground:SetShown(frame.mode ~= "bank" or not frame.Columns[1]:IsShown())
    if frame.mode ~= "bank" then return end
    local tab = GetCurrentGuildBankTab()
    for columnIndex, column in ipairs(frame.Columns) do
        for row, button in ipairs(column.Buttons) do
            local quality = select(5, GetGuildBankItemInfo(tab, (columnIndex - 1) * SLOTS_PER_COLUMN + row))
            GW.SetItemSlotQuality(button, quality)
        end
    end
end

local function SkinItems()
    -- below the search and as wide as its visible bar, which starts right of the box edge
    local detailsBackground = GW.CreateDetailsBackgroundTexture(GuildBankFrame)
    if GuildItemSearchBox then
        detailsBackground:SetPoint("TOPLEFT", GuildItemSearchBox.Middle, "BOTTOMLEFT", 0, -9)
    else
        detailsBackground:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", 6, -73)
    end
    detailsBackground:SetPoint("BOTTOMRIGHT", GuildBankFrame, "BOTTOMRIGHT", -10, 30)
    detailsBackground:Hide()
    GuildBankFrame.gwDetailsBackground = detailsBackground

    for _, column in ipairs(GuildBankFrame.Columns) do
        column.Background:SetAlpha(0)
        for _, button in ipairs(column.Buttons) do
            SkinSlot(button)
        end
    end
    hooksecurefunc(GuildBankFrame, "Update", UpdateBankView)
end

-- the bank tabs look like the tabs of our bank and stack on the side panel
local function SkinBankTabs()
    local index, tab = 1, GuildBankTab1
    while tab do
        local button = tab.Button
        tab:GwStripTextures()
        tab:SetSize(TAB_SIZE, TAB_SIZE)
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", -34, -40 - (index - 1) * (TAB_SIZE + TAB_GAP))

        button:ClearAllPoints()
        button:SetAllPoints(tab)
        button.NormalTexture:SetAlpha(0)
        button.IconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        button.IconTexture:SetAllPoints(button)

        local border = button:CreateTexture(nil, "OVERLAY")
        border:SetTexture(BORDER_TEXTURE)
        border:SetAllPoints(button)

        button:SetPushedTexture(PUSHED_TEXTURE)
        button:SetHighlightTexture(BORDER_TEXTURE, "ADD")
        button:GetHighlightTexture():SetAlpha(0.33)
        button:SetCheckedTexture(BAG_TEXTURES .. "stancebar-border.png")
        button:GetCheckedTexture():GwSetOutside(button)

        index = index + 1
        tab = _G["GuildBankTab" .. index]
    end
end

local function SkinScrollFrames()
    if GuildBankFrame.Log.ScrollBar then
        GW.HandleTrimScrollBar(GuildBankFrame.Log.ScrollBar)
        GW.HandleScrollControls(GuildBankFrame.Log)
        GuildBankFrame.Log.ScrollBar:SetHideIfUnscrollable(true)
    else
        GuildBankTransactionsScrollFrame:GwStripTextures()
        GuildBankTransactionsScrollFrameScrollBar:GwSkinScrollBar()
        GuildBankTransactionsScrollFrame:GwSkinScrollFrame()
    end

    -- blizzard places the log and the info text at fixed spots under its own header, they move into
    -- the details background; the classic scroll frame of the log only carries its scroll bar
    local area = GuildBankFrame.gwDetailsBackground
    for _, content in ipairs({GuildBankFrame.Log.MessageFrame, GuildBankInfoScrollFrame, GuildBankTransactionsScrollFrame}) do
        content:ClearAllPoints()
        content:SetPoint("TOPLEFT", area, "TOPLEFT", 8, -8)
        content:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", -20, 8)
    end

    GuildBankInfoScrollFrame:GwStripTextures()
    GW.SkinSlimScrollFrame(GuildBankInfoScrollFrame)
    GuildBankTabInfoEditBox:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
end

-- moved by its header like our bank (the header art sits above the frame), kept on screen with
-- the side panel, header and footer; the panel manager can not move it back
local function MakeMovable()
    local mover = CreateFrame("Frame", nil, GuildBankFrame)
    mover:SetHeight(40)
    mover:SetPoint("BOTTOMLEFT", GuildBankFrame, "TOPLEFT", -40, 0)
    mover:SetPoint("BOTTOMRIGHT", GuildBankFrame, "TOPRIGHT", -30, 0)

    GW.MakeFrameMovable(GuildBankFrame, nil, "guildBank", true)
    GW.MakeFrameMovable(mover, GuildBankFrame, "guildBank")
    GuildBankFrame:SetClampedToScreen(true)
    GuildBankFrame:SetClampRectInsets(-40, 0, 54, -35)
end

-- the top row like our bank: the tab name where the bank shows its free slots, the search below it
local function SkinTopRow()
    local title = GuildBankFrame.TabTitle
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", 8, -12)
    title:SetJustifyH("LEFT")
    title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    -- the withdrawals left for today share the bottom row with the money limit, on its right; the row
    -- gets a details strip as wide as the content above, like a status line
    local statusLine = GW.CreateDetailsBackgroundTexture(GuildBankFrame)
    statusLine:SetPoint("TOPLEFT", GuildBankFrame.gwDetailsBackground, "BOTTOMLEFT", 0, -4)
    statusLine:SetPoint("TOPRIGHT", GuildBankFrame.gwDetailsBackground, "BOTTOMRIGHT", 0, -4)
    statusLine:SetHeight(21)
    GuildBankFrame.LimitLabel:ClearAllPoints()
    GuildBankFrame.LimitLabel:SetPoint("RIGHT", statusLine, "RIGHT", -8, 0)
    GuildBankFrame.LimitLabel:SetJustifyH("RIGHT")
    GuildBankMoneyLimitLabel:ClearAllPoints()
    GuildBankMoneyLimitLabel:SetPoint("LEFT", statusLine, "LEFT", 8, 0)
    for _, label in ipairs({GuildBankFrame.LimitLabel, GuildBankMoneyLimitLabel, GuildBankMoneyUnlimitedLabel}) do
        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    end

    if GuildItemSearchBox then
        GW.SkinBagSearchBox(GuildItemSearchBox)
        GuildItemSearchBox:ClearAllPoints()
        GuildItemSearchBox:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", 6, -40)
        GuildItemSearchBox:SetPoint("TOPRIGHT", GuildBankFrame, "TOPRIGHT", -10, -40)
        GuildItemSearchBox:SetHeight(24)
    end

    -- the slots start below the search like the bank items
    local point, relativeTo, relativePoint, x = GuildBankFrame.Column1:GetPoint()
    GuildBankFrame.Column1:SetPoint(point, relativeTo, relativePoint, x, -73)
end

local function UpdateFooterTabs()
    local selected = PanelTemplates_GetSelectedTab(GuildBankFrame)
    for index = 1, FOOTER_TABS do
        local tab = _G["GuildBankFrameTab" .. index]
        GW.SetTextTab(tab, tab.gwText, index == selected)
    end
end

-- the view tabs (bank, logs, info) become text tabs in the footer, the gold sits beside them
local function SkinFooter()
    for index = 1, FOOTER_TABS do
        local tab = _G["GuildBankFrameTab" .. index]
        tab:GwStripTextures()
        -- blizzard swaps the font on every selection, so its text is taken over and emptied
        tab.gwText = tab:GetText()
        tab:SetText("")
        tab:SetHeight(28)
        GW.AddTextTabArt(tab)
        tab:HookScript("OnEnter", UpdateFooterTabs)
        tab:HookScript("OnLeave", UpdateFooterTabs)
        tab:ClearAllPoints()
        if index == 1 then
            tab:SetPoint("TOPLEFT", GuildBankFrame, "BOTTOMLEFT", 10, -6)
        else
            tab:SetPoint("LEFT", _G["GuildBankFrameTab" .. (index - 1)], "RIGHT", 10, 0)
        end
    end
    hooksecurefunc("PanelTemplates_SetTab", function(frame)
        if frame == GuildBankFrame then
            UpdateFooterTabs()
        end
    end)
    UpdateFooterTabs()

    if GuildBankFrame.MoneyFrameBG then
        GuildBankFrame.MoneyFrameBG:GwStripTextures()
    end
    GuildBankMoneyFrame:ClearAllPoints()
    GuildBankMoneyFrame:SetPoint("TOPRIGHT", GuildBankFrame, "BOTTOMRIGHT", -10, -14)

    -- deposit and withdraw beside the gold, like the bank money buttons
    GuildBankFrame.DepositButton:ClearAllPoints()
    GuildBankFrame.DepositButton:SetPoint("RIGHT", GuildBankMoneyFrame, "LEFT", -20, 0)
    GuildBankFrame.WithdrawButton:ClearAllPoints()
    GuildBankFrame.WithdrawButton:SetPoint("RIGHT", GuildBankFrame.DepositButton, "LEFT", -5, 0)
end

local function SkinTexts()
    local texts = {GuildBankMoneyLimitLabel, GuildBankMoneyUnlimitedLabel, GuildBankFrame.LimitLabel, GuildBankFrame.TabTitle,
        GuildBankFrame.ErrorMessage, GuildBankFrame.BuyInfo.TabText, GuildBankFrame.BuyInfo.PurchasedText}
    for _, text in pairs(texts) do
        text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
end

-- the classic clients keep the old tab icon dialog: blizzards macro popup art, an icon grid built on first show
local function SkinLegacyIconPopup(popup)
    if popup.gwSkinned then return end
    popup.gwSkinned = true

    popup:GwStripTextures()
    if popup.BG then
        popup.BG:Hide()
    end
    -- the border art sits on an unkeyed child named BorderBox, its two labels stay
    for _, child in ipairs({popup:GetChildren()}) do
        if child:GetName() == "BorderBox" then
            child:GwStripTextures()
        end
    end
    popup:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    GW.SkinTextBox(GuildBankPopupNameMiddle, GuildBankPopupNameLeft, GuildBankPopupNameRight, nil, nil, 5, 5)
    popup.OkayButton:GwSkinButton(false, true)
    popup.CancelButton:GwSkinButton(false, true)

    popup.ScrollFrame:GwStripTextures()
    popup.ScrollFrame.ScrollBar:GwSkinScrollBar()
    popup.ScrollFrame:GwSkinScrollFrame()

    local index, button = 1, GuildBankPopupButton1
    while button do
        GW.SkinIconChoice(button)
        index = index + 1
        button = _G["GuildBankPopupButton" .. index]
    end
end

local function SkinButtons()
    local buttons = {GuildBankFrame.DepositButton, GuildBankFrame.WithdrawButton, GuildBankFrame.BuyInfo.PurchaseButton, GuildBankInfoSaveButton}
    for _, button in ipairs(buttons) do
        button:GwSkinButton(false, true)
    end
    -- the tab icon dialog fills its icons on the first show, so both versions are skinned then
    if GuildBankPopupFrame then
        GuildBankPopupFrame:HookScript("OnShow", GuildBankPopupFrame.IconSelector and GW.HandleIconSelectionFrame or SkinLegacyIconPopup)
    end
end

local function ApplyGuildBankSkin()
    SkinWindow()
    SkinItems()
    SkinBankTabs()
    SkinScrollFrames()
    SkinButtons()
    SkinFooter()
    SkinTopRow()
    SkinTexts()
    MakeMovable()
end

-- part of the inventory module, classic era has no guild bank and never loads the addon
local function LoadGuildBank()
    GW.RegisterLoadHook(ApplyGuildBankSkin, "Blizzard_GuildBankUI", GuildBankFrame)
end
GW.LoadGuildBank = LoadGuildBank
