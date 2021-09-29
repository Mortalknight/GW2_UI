local _, GW = ...
local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame

local function updateLootFrameButtons()
    for i = 1, 4 do
        _G["LootButton" .. i]:SetNormalTexture(nil)
        _G["LootButton" .. i].IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    end
end

local function SkinLooTFrame()
    LootFrameBg:Hide()
    LootFrameBg:SetPoint("TOPLEFT", 0, -64)
    LootFrameBg:SetWidth(170)
    LootFrame.TitleBg:Hide()
    LootFrame.TopTileStreaks:Hide()
    LootFramePortraitFrame:Hide()
    LootFramePortraitOverlay:Hide()
    LootFrameInset:Hide()
    LootFrameTopBorder:Hide()
    LootFrameTopRightCorner:Hide()
    LootFrameRightBorder:Hide()
    LootFrameLeftBorder:Hide()
    LootFrameBottomBorder:Hide()
    LootFrameBotRightCorner:Hide()
    LootFrameBotLeftCorner:Hide()

    local r = {LootFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end

    local GwLootFrameTitle = CreateFrame("Frame", nil, LootFrame, "GwLootFrameTitleTemp")
    GwLootFrameTitle:SetPoint("BOTTOMLEFT", LootFrameBg, "TOPLEFT")
    GwLootFrameTitle.headerString:SetFont(DAMAGE_TEXT_FONT, 14)
    GwLootFrameTitle.headerString:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    if GetCVar("lootUnderMouse") == "0" then
        local pos = GetSetting("LOOTFRAME_POS")
        LootFrame:ClearAllPoints()
        LootFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        RegisterMovableFrame(_G.LootFrame, BUTTON_LAG_LOOT, "LOOTFRAME_POS", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
        hooksecurefunc("LootFrame_Show", function(self)
            LootFrame:ClearAllPoints()
            LootFrame:SetPoint("TOPLEFT", self.gwMover)
        end)
    end

    LootFrameCloseButton:ClearAllPoints()
    LootFrameCloseButton:SetPoint("RIGHT", GwLootFrameTitle.BGRIGHT, "RIGHT", -5, -2)
    LootFrameCloseButton:SetSize(20, 20)
    LootFrameCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    LootFrameCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    LootFrameCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")

    LootFrameNext:SetFont(UNIT_NAME_FONT, 12)
    LootFramePrev:SetFont(UNIT_NAME_FONT, 12)
    LootFrameNext:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    LootFramePrev:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    LootFrameDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")
    LootFrameDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")
    LootFrameDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")

    LootFrameUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")
    LootFrameUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")
    LootFrameUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")

    for i = 1, 4 do
        _G["LootButton" .. i .. "NameFrame"]:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
        _G["LootButton" .. i .. "NameFrame"]:SetHeight(_G["LootButton" .. i]:GetHeight())
        _G["LootButton" .. i .. "NameFrame"]:SetPoint("LEFT",_G["LootButton" .. i],"RIGHT", 0, 0)

        _G["LootButton" .. i .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        _G["LootButton" .. i .. "Text"]:SetFont(UNIT_NAME_FONT, 12)
    end

    hooksecurefunc("LootFrame_Update", updateLootFrameButtons)
end
GW.SkinLooTFrame = SkinLooTFrame