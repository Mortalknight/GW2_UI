local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local function updateLootFrameButtons()
    for i = 1, 4 do
        _G["LootButton" .. i]:SetNormalTexture(nil)
        _G["LootButton" .. i].IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    end
end

local function SkinLooTFrame()
    _G.LootFrameBg:Hide()
    _G.LootFrameBg:SetPoint("TOPLEFT", 0, -64)
    _G.LootFrameBg:SetWidth(170)
    _G.LootFrame.TitleBg:Hide()
    _G.LootFrame.TopTileStreaks:Hide()
    _G.LootFramePortrait:Hide()
    _G.LootFramePortraitOverlay:Hide()
    _G.LootFrameInset:Hide()
    _G.LootFrame.NineSlice:Hide()

    local r = {_G.LootFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end

    local GwLootFrameTitle = CreateFrame("Frame", nil, _G.LootFrame, "GwLootFrameTitleTemp")
    GwLootFrameTitle:SetPoint("BOTTOMLEFT", _G.LootFrameBg, "TOPLEFT")
    GwLootFrameTitle.headerString:SetFont(DAMAGE_TEXT_FONT, 14)
    GwLootFrameTitle.headerString:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    if GetCVar("lootUnderMouse") == "0" then
        local pos = GetSetting("LOOTFRAME_POS")
        _G.LootFrame:SetPoint(pos.point, nil, pos.relativePoint, pos.xOfs, pos.yOfs)
        RegisterMovableFrame(_G.LootFrame, BUTTON_LAG_LOOT, "LOOTFRAME_POS", "VerticalActionBarDummy", nil, nil, nil, {"scaleable"})
        hooksecurefunc("LootFrame_Show", function(self)
            _G.LootFrame:ClearAllPoints()
            _G.LootFrame:SetPoint("TOPLEFT", self.gwMover)
        end)
    end

    _G.LootFrameCloseButton:ClearAllPoints()
    _G.LootFrameCloseButton:SetPoint("RIGHT", GwLootFrameTitle.BGRIGHT, "RIGHT", -5, -2)
    _G.LootFrameCloseButton:SetSize(20,20)
    _G.LootFrameCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal")
    _G.LootFrameCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
    _G.LootFrameCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")

    _G.LootFrameNext:SetFont(UNIT_NAME_FONT, 12)
    _G.LootFramePrev:SetFont(UNIT_NAME_FONT, 12)
    _G.LootFrameNext:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    _G.LootFramePrev:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    _G.LootFrameDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    _G.LootFrameDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    _G.LootFrameDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")

    _G.LootFrameUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")
    _G.LootFrameUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")
    _G.LootFrameUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")

    for i = 1, 4 do
        _G["LootButton" .. i .. "NameFrame"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
        _G["LootButton" .. i .. "NameFrame"]:SetHeight(_G["LootButton" .. i]:GetHeight())
        _G["LootButton" .. i .. "NameFrame"]:SetPoint("LEFT", _G["LootButton" .. i], "RIGHT", 0, 0)

        _G["LootButton" .. i .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        _G["LootButton" .. i .. "Text"]:SetFont(UNIT_NAME_FONT, 12)
    end

    hooksecurefunc("LootFrame_Update", updateLootFrameButtons)
end
GW.SkinLooTFrame = SkinLooTFrame
