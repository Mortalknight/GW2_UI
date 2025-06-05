local _, GW = ...
local function ApplySocketUISkin()
    if not GW.settings.SOCKET_SKIN_ENABLED then return end

    ItemSocketingFrame:SetFrameStrata("DIALOG")

    ItemSocketingFramePortrait:Hide()
    ItemSocketingFrame:GwStripTextures()
    ItemSocketingFrameCloseButton:GwSkinButton(true)
    ItemSocketingFrameCloseButton:SetSize(20, 20)

    local regions = {ItemSocketingFrame:GetRegions()}
    for _,region in pairs(regions) do
        if region:IsObjectType("FontString") then
            if region:GetText() then
                region:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
                break
            end
        end
    end

    local tex = ItemSocketingFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOP", ItemSocketingFrame, "TOP", 0, 20)
    local w, h = ItemSocketingFrame:GetSize()
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    ItemSocketingFrame.tex = tex


    ItemSocketingDescription:DisableDrawLayer("BORDER")
    ItemSocketingDescription:DisableDrawLayer("BACKGROUND")
    ItemSocketingScrollFrame:GwStripTextures()

    GW.HandleTrimScrollBar(ItemSocketingScrollFrame.ScrollBar, true)
    GW.HandleScrollControls(ItemSocketingScrollFrame)

    for i = 1, MAX_NUM_SOCKETS  do
        local button_bracket = _G[("ItemSocketingSocket%dBracketFrame"):format(i)]
        local button_icon = _G[("ItemSocketingSocket%dIconTexture"):format(i)]
        button_bracket:GwKill()
        button_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    ItemSocketingSocketButton:ClearAllPoints()
    ItemSocketingSocketButton:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, -10)
    ItemSocketingSocketButton:GwSkinButton(false, true)

    ItemSocketingFrame.mover = CreateFrame("Frame", nil, ItemSocketingFrame)
    ItemSocketingFrame.mover:EnableMouse(true)
    ItemSocketingFrame:SetMovable(true)
    ItemSocketingFrame.mover:SetSize(w, 30)
    ItemSocketingFrame.mover:SetPoint("BOTTOMLEFT", ItemSocketingFrame, "TOPLEFT", 0, -20)
    ItemSocketingFrame.mover:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "TOPRIGHT", 0, 20)
    ItemSocketingFrame.mover:RegisterForDrag("LeftButton")
    ItemSocketingFrame:SetClampedToScreen(true)
    ItemSocketingFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    ItemSocketingFrame.mover:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)
end

local function LoadSocketUISkin()
    GW.RegisterLoadHook(ApplySocketUISkin, "Blizzard_ItemSocketingUI", ItemSocketingFrame)
end
GW.LoadSocketUISkin = LoadSocketUISkin
