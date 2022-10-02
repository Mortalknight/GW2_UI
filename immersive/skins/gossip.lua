local _, GW = ...
local GetSetting = GW.GetSetting

local function handleGossipText()
    for i = 1, NUMGOSSIPBUTTONS do
        local button = _G["GossipTitleButton"..i]
        local icon = _G["GossipTitleButton"..i.."GossipIcon"]
        local text = button:GetFontString()

        if text and text:GetText() then
            local textString = gsub(text:GetText(), "|c[Ff][Ff]%x%x%x%x%x%x(.+)|r", "%1")

            button:SetText(textString)
            text:SetTextColor(1, 1, 1)

            if button.type == "Available" or button.type == "Active" then
                if button.type == "Active" then
                    icon:SetDesaturation(1)
                    text:SetTextColor(.6, .6, .6)
                else
                    icon:SetDesaturation(0)
                    text:SetTextColor(1, .8, .1)
                end

                local numEntries = GetNumQuestLogEntries()
                for k = 1, numEntries, 1 do
                    local questLogTitleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(k)
                    if strmatch(questLogTitleText, textString) then
                        if (isComplete == 1 or IsQuestComplete(questId)) then
                            icon:SetDesaturation(0)
                            button:GetFontString():SetTextColor(1, .8, .1)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function LoadGossipSkin()
    if not GetSetting("GOSSIP_SKIN_ENABLED") then return end

    ItemTextFrame:StripTextures(true)
    ItemTextFrame:CreateBackdrop()

    ItemTextFrame.tex = ItemTextFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    ItemTextFrame.tex:SetPoint("TOP", ItemTextFrame, "TOP", 0, 20)
    ItemTextFrame.tex:SetSize(ItemTextFrame:GetSize())
    ItemTextFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemTextScrollFrame:StripTextures()

    GossipFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GossipFrame:StripTextures()
    GossipFrame:CreateBackdrop()
    GossipFrame.tex = GossipFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    GossipFrame.tex:SetPoint("TOP", GossipFrame, "TOP", 0, 20)
    GossipFrame.tex:SetSize(GossipFrame:GetSize())
    GossipFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    GossipFrameCloseButton:SkinButton(true)
    GossipFrameCloseButton:SetSize(20, 20)

    for i = 1, _G.NUMGOSSIPBUTTONS do
        _G["GossipTitleButton"..i.."GossipIcon"]:SetSize(16, 16)
        _G["GossipTitleButton"..i.."GossipIcon"]:SetPoint("TOPLEFT", 3, 1)
    end

    GossipGreetingScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrame:SkinScrollFrame()

    GossipFrameGreetingGoodbyeButton:StripTextures()
    GossipFrameGreetingGoodbyeButton:SkinButton(false, true)

    GW.HandleNextPrevButton(ItemTextPrevPageButton)
    GW.HandleNextPrevButton(ItemTextNextPageButton)

    ItemTextPageText:SetTextColor(1, 1, 1)
    hooksecurefunc(ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(headerType, 1, 1, 1)
        end
    end)

    local StripAllTextures = {"GossipFrameGreetingPanel", "GossipGreetingScrollFrame"}
    for _, object in pairs(StripAllTextures) do
        _G[object]:StripTextures()
    end

    GossipGreetingScrollFrame:SkinScrollFrame()

    hooksecurefunc("GossipFrameUpdate", handleGossipText)
    GossipGreetingText:SetTextColor(1, 1, 1)
    handleGossipText()

    ItemTextCloseButton:SkinButton(true)
    ItemTextCloseButton:SetSize(20, 20)

    local NPCFriendshipStatusBar = NPCFriendshipStatusBar
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