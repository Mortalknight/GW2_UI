local _, GW = ...

local function ApplySocketUISkin()
    if not GW.GetSetting("SOCKET_SKIN_ENABLED") then return end

    ItemSocketingFrame:GwStripTextures()
    ItemSocketingCloseButton:GwSkinButton(true)
    ItemSocketingCloseButton:SetSize(20, 20)

    local regions = {ItemSocketingFrame:GetRegions()}
    for _,region in pairs(regions) do
        if region:IsObjectType("FontString") then
            if region:GetText() then
                region:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
                break
            end
        end
    end

    local w, h = ItemSocketingFrame:GetSize()
    ItemSocketingFrame.tex = ItemSocketingFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    ItemSocketingFrame.tex:SetPoint("TOP", ItemSocketingFrame, "TOP", 0, 20)
    ItemSocketingFrame.tex:SetSize(w + 50, h + 70)
    ItemSocketingFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemSocketingScrollFrame:GwStripTextures()
    ItemSocketingScrollFrame:GwCreateBackdrop(GW.skins.constBackdropFrame, true, 2, 2)
    ItemSocketingScrollFrameScrollBar:GwSkinScrollBar()

    for i = 1, _G.MAX_NUM_SOCKETS do
        local button = _G[("ItemSocketingSocket%d"):format(i)]
        local button_bracket = _G[("ItemSocketingSocket%dBracketFrame"):format(i)]
        local button_icon = _G[("ItemSocketingSocket%dIconTexture"):format(i)]
        local button_bg = _G[("ItemSocketingSocket%dBackground"):format(i)]
        button:GwStripTextures()
        button:GwStyleButton(false)
        button:GwCreateBackdrop(GW.constBackdropFrameColorBorder, true, 2, 2)
        button_bracket:GwKill()
        button_bg:GwKill()
        button_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button_icon:GwSetInside()
    end

    hooksecurefunc("ItemSocketingFrame_Update", function()
        local numSockets = GetNumSockets()
        for i = 1, numSockets do
            local socket = _G["ItemSocketingSocket" .. i]
            local gemColor = GetSocketTypes(i)
            local color = GW.GemTypeInfo[gemColor]
            socket.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        end
    end)

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
