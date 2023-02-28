local _, GW = ...
local GetSetting = GW.GetSetting


local function ReplaceGossipFormat(button, textFormat, text)
    local newFormat, count = gsub(textFormat, "000000", "ffffff")
    if count > 0 then
        button:SetFormattedText(newFormat, text)
    end
end

local ReplacedGossipColor = {
    ["000000"] = "ffffff",
    ["414141"] = "7b8489",
}
local function ReplaceGossipText(button, text)
    if text and text ~= "" then
        local newText, count = gsub(text, ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59")
        if count > 0 then
            text = newText
            button:SetFormattedText("%s", text)
        end

        local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
        colorStr = ReplacedGossipColor[colorStr]
        if colorStr and rawText then
            button:SetFormattedText("|cff%s%s|r", colorStr, rawText)
        end
    end
end

local function LoadGossipSkin()
    if not GetSetting("GOSSIP_SKIN_ENABLED") then return end

    ItemTextFrame:GwStripTextures(true)
    ItemTextFrame:GwCreateBackdrop()

    ItemTextFrame.tex = ItemTextFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    ItemTextFrame.tex:SetPoint("TOP", ItemTextFrame, "TOP", 0, 20)
    ItemTextFrame.tex:SetSize(ItemTextFrame:GetSize())
    ItemTextFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemTextScrollFrame:GwStripTextures()

    GW.HandleTrimScrollBar(GossipFrame.GreetingPanel.ScrollBar)
    ItemTextScrollFrameScrollBar:GwSkinScrollBar()
    ItemTextScrollFrame:GwSkinScrollFrame()

    GossipFrame.TitleContainer.TitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GossipFrame:GwStripTextures()
    GossipFrame:GwCreateBackdrop()
    GossipFrame.GreetingPanel:GwStripTextures()
    GossipFrame.tex = GossipFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    GossipFrame.tex:SetPoint("TOP", GossipFrame, "TOP", 0, 20)
    GossipFrame.tex:SetSize(GossipFrame:GetSize())
    GossipFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    GossipFrame.CloseButton:GwSkinButton(true)
    GossipFrame.CloseButton:SetSize(20, 20)

    GossipFrame.GreetingPanel.GoodbyeButton:GwStripTextures()
    GossipFrame.GreetingPanel.GoodbyeButton:GwSkinButton(false, true)

    GW.HandleNextPrevButton(ItemTextPrevPageButton)
    GW.HandleNextPrevButton(ItemTextNextPageButton)

    ItemTextPageText:SetTextColor("P", 1, 1, 1)
    hooksecurefunc(ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(headerType, 1, 1, 1)
        end
    end)

    ItemTextFrame:GwStripTextures(true)
    QuestFont:SetTextColor(1, 1, 1)

    if GossipFrame.Background then
        GossipFrame.Background:Hide()
    end

    hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "Update", function(frame)
        for _, button in next, { frame.ScrollTarget:GetChildren() } do
            if not button.IsSkinned then
                local buttonText = select(3, button:GetRegions())
                if buttonText and buttonText:IsObjectType("FontString") then
                    ReplaceGossipText(button, button:GetText())
                    hooksecurefunc(button, "SetText", ReplaceGossipText)
                    hooksecurefunc(button, "SetFormattedText", ReplaceGossipFormat)
                end

                button.IsSkinned = true
            end
        end
    end)

    ItemTextCloseButton:GwSkinButton(true)
    ItemTextCloseButton:SetSize(20, 20)

    local NPCFriendshipStatusBar = NPCFriendshipStatusBar
    NPCFriendshipStatusBar:GwStripTextures()
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
    GossipFrame.mover:SetSize(GossipFrame:GetWidth(), 30)
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