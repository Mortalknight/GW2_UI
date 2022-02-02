local _, GW = ...

local function ApplySocketUISkin()
    if not GW.GetSetting("SOCKET_SKIN_ENABLED") then return end

    ItemSocketingFrame:StripTextures()
    _G.ItemSocketingFrameCloseButton:SkinButton(true)
    _G.ItemSocketingFrameCloseButton:SetSize(20, 20)

    local regions = {ItemSocketingFrame:GetRegions()}
    for _,region in pairs(regions) do
        if region:IsObjectType("FontString") then
            if region:GetText() then
                region:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
                break
            end
        end
    end

    local tex = ItemSocketingFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    tex:SetPoint("TOP", ItemSocketingFrame, "TOP", 0, 20)
    local w, h = ItemSocketingFrame:GetSize()
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    ItemSocketingFrame.tex = tex

    _G.ItemSocketingScrollFrameScrollBar:SkinScrollBar()

    for i = 1, _G.MAX_NUM_SOCKETS  do
        local button_bracket = _G[("ItemSocketingSocket%dBracketFrame"):format(i)]
        local button_icon = _G[("ItemSocketingSocket%dIconTexture"):format(i)]
        button_bracket:Kill()
        button_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    _G.ItemSocketingSocketButton:ClearAllPoints()
    _G.ItemSocketingSocketButton:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, -10)
    _G.ItemSocketingSocketButton:SkinButton(false, true)

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
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)
end

local function LoadSocketUISkin()
    GW.RegisterSkin("Blizzard_ItemSocketingUI", function() ApplySocketUISkin() end)
end
GW.LoadSocketUISkin = LoadSocketUISkin
