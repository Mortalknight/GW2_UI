local _, GW = ...

local GemTypeInfo = {
    Yellow			= { r = 0.97, g = 0.82, b = 0.29 },
    Red				= { r = 1.00, g = 0.47, b = 0.47 },
    Blue			= { r = 0.47, g = 0.67, b = 1.00 },
    Hydraulic		= { r = 1.00, g = 1.00, b = 1.00 },
    Cogwheel		= { r = 1.00, g = 1.00, b = 1.00 },
    Meta			= { r = 1.00, g = 1.00, b = 1.00 },
    Prismatic		= { r = 1.00, g = 1.00, b = 1.00 },
    PunchcardRed	= { r = 1.00, g = 0.47, b = 0.47 },
    PunchcardYellow	= { r = 0.97, g = 0.82, b = 0.29 },
    PunchcardBlue	= { r = 0.47, g = 0.67, b = 1.00 },
}

local function SkinSocketUI()
    ItemSocketingFrame_LoadUI()
    local ItemSocketingFrame = _G.ItemSocketingFrame

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

    _G.ItemSocketingDescription:CreateBackdrop(GW.skins.constBackdropFrameBorder)

    local tex = ItemSocketingFrame:CreateTexture("bg", "BACKGROUND", 0)
    tex:SetPoint("TOP", ItemSocketingFrame, "TOP", 0, 20)
    local w, h = ItemSocketingFrame:GetSize()
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    ItemSocketingFrame.tex = tex

    _G.ItemSocketingScrollFrameScrollBar:SkinScrollBar()

    for i = 1, _G.MAX_NUM_SOCKETS  do
        local button = _G[("ItemSocketingSocket%d"):format(i)]
        local button_bracket = _G[("ItemSocketingSocket%dBracketFrame"):format(i)]
        local button_bg = _G[("ItemSocketingSocket%dBackground"):format(i)]
        local button_icon = _G[("ItemSocketingSocket%dIconTexture"):format(i)]
        --button:StripTextures()
        button:CreateBackdrop()
        button_bracket:Kill()
        button_bg:Kill()
        button_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end


    hooksecurefunc("ItemSocketingFrame_Update", function()
        for i, socket in ipairs(_G.ItemSocketingFrame.Sockets) do
            local gemColor = GetSocketTypes(i)
            local color = GemTypeInfo[gemColor]
            socket.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        end
    end)

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
GW.SkinSocketUI = SkinSocketUI
