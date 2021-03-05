local _, GW = ...

local function handleGossipText()
    local buttons = _G.GossipFrame.buttons
    if buttons and next(buttons) then
        for _, button in ipairs(buttons) do
            local str = button:GetFontString()
            if str then
                str:SetTextColor(1, 1, 1)

                local text = str:GetText()
                if text then
                    local stripped = GW.StripString(text)
                    str:SetText(stripped)
                end
            end
        end
    end
end

local function LoadGossipSkin()
    if not GW.GetSetting("GOSSIP_SKIN_ENABLED") then return end

    local GossipFrame = _G.GossipFrame
    _G.ItemTextFrame:StripTextures(true)
    _G.ItemTextFrame:CreateBackdrop()

    local tex = _G.ItemTextFrame:CreateTexture("bg", "BACKGROUND", 0)
    local w, h = ItemTextFrame:GetSize()
    tex:SetPoint("TOP", _G.ItemTextFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    _G.ItemTextFrame.tex = tex

    _G.ItemTextScrollFrame:StripTextures()

    _G.GossipFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GossipFrame:StripTextures()
    GossipFrame:CreateBackdrop()
    tex = GossipFrame:CreateTexture("bg", "BACKGROUND", 0)
    w, h = GossipFrame:GetSize()
    tex:SetPoint("TOP", GossipFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    GossipFrame.tex = tex

    GossipFrame.CloseButton:SkinButton(true)
    GossipFrame.CloseButton:SetSize(20, 20)
    GossipFrame.Background:Hide()

    _G.ItemTextFrameCloseButton:SkinButton(true)
    _G.ItemTextFrameCloseButton:SetSize(20, 20)

    _G.GossipGreetingScrollFrameScrollBar:SkinScrollBar()
    _G.ItemTextScrollFrameScrollBar:SkinScrollBar()

    GW.HandleNextPrevButton(_G.ItemTextPrevPageButton)
    GW.HandleNextPrevButton(_G.ItemTextNextPageButton)

    _G.ItemTextPageText:SetTextColor(1, 1, 1)
    hooksecurefunc(_G.ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(headerType, 1, 1, 1)
        end
    end)

    local StripAllTextures = {"GossipFrameGreetingPanel", "GossipGreetingScrollFrame"}
    for _, object in pairs(StripAllTextures) do
        _G[object]:StripTextures()
    end

    local GossipGreetingScrollFrame = _G.GossipGreetingScrollFrame
    GossipGreetingScrollFrame:SkinScrollFrame()

    hooksecurefunc("GossipFrameUpdate", handleGossipText)
    _G.GossipGreetingText:SetTextColor(1, 1, 1)
    handleGossipText()

    _G.GossipFrameGreetingGoodbyeButton:StripTextures()
    _G.GossipFrameGreetingGoodbyeButton:SkinButton(false, true)

    for i = 1, 4 do
        local notch = _G["NPCFriendshipStatusBarNotch" .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(1, 16)
        end
    end

    local NPCFriendshipStatusBar = _G.NPCFriendshipStatusBar
    NPCFriendshipStatusBar:StripTextures()
    NPCFriendshipStatusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    NPCFriendshipStatusBar.bg = NPCFriendshipStatusBar:CreateTexture(nil, "BACKGROUND")
    NPCFriendshipStatusBar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
    NPCFriendshipStatusBar.bg:SetPoint("TOPLEFT", NPCFriendshipStatusBar, "TOPLEFT", -3, 3)
    NPCFriendshipStatusBar.bg:SetPoint("BOTTOMRIGHT", NPCFriendshipStatusBar, "BOTTOMRIGHT", 3, -3)

    NPCFriendshipStatusBar.icon:ClearAllPoints()
    NPCFriendshipStatusBar.icon:SetPoint("RIGHT", NPCFriendshipStatusBar, "LEFT", 0, -3)
    NPCFriendshipStatusBar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- mover
    GossipFrame.mover = CreateFrame("Frame", nil, GossipFrame)
    GossipFrame.mover:EnableMouse(true)
    GossipFrame:SetMovable(true)
    GossipFrame.mover:SetSize(w, 30)
    GossipFrame.mover:SetPoint("BOTTOMLEFT", GossipFrame, "TOPLEFT", 0, -20)
    GossipFrame.mover:SetPoint("BOTTOMRIGHT", GossipFrame, "TOPRIGHT", 0, 20)
    GossipFrame.mover:RegisterForDrag("LeftButton")
    GossipFrame:SetClampedToScreen(true)
    GossipFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    GossipFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)

end
GW.LoadGossipSkin = LoadGossipSkin