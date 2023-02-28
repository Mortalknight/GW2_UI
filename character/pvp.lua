local _, GW = ...

local function LoadPvpFrame(frame)
    for i = 1, PVPFrame:GetNumRegions() do
        local region = select(i, PVPFrame:GetRegions())
        if region:IsObjectType("FontString") then
            region:ClearAllPoints()
            region:SetPoint("TOP", PVPFrame, "TOP", 0, 40)
            region:SetFont(UNIT_NAME_FONT, 24)
            region:SetTextColor(1, 1, 1)
            break
        end
    end

    PVPFrame.Hide = PVPFrame.Show
    PVPFrame:Show()
    PVPFrame:SetParent(frame)
    PVPFrame:ClearAllPoints()
    PVPFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -60)
    PVPFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 8)

    PVPFrameBackground:ClearAllPoints()
    PVPFrameBackground:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -60)
    PVPFrameBackground:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 8)

    PVPFrame:GwStripTextures(true)

    PVPFrameHonorLabel:ClearAllPoints()
    PVPFrameHonorLabel:SetPoint("TOP", PVPFrameBackground, "TOP", 0, -10)
    PVPFrameHonorLabel:SetFont(UNIT_NAME_FONT, 20, "")
    PVPFrameHonorPoints:SetFont(UNIT_NAME_FONT, 20, "")

    PVPFrameArenaLabel:ClearAllPoints()
    PVPFrameArenaLabel:SetPoint("TOP", PVPFrameBackground, "TOP", 0, -130)
    PVPFrameArenaLabel:SetFont(UNIT_NAME_FONT, 20, "")
    PVPFrameArenaPoints:SetFont(UNIT_NAME_FONT, 20, "")

    PVPHonor:ClearAllPoints()
    PVPHonor:SetPoint("TOP", PVPFrameBackground, "TOP", 0, -35)

    PVPHonorKillsLabel:SetFont(STANDARD_TEXT_FONT, 14, "")
    PVPHonorTodayLabel:SetFont(STANDARD_TEXT_FONT, 14, "")
    PVPHonorTodayKills:SetFont(STANDARD_TEXT_FONT, 14, "")
    PVPHonorYesterdayLabel:SetFont(STANDARD_TEXT_FONT, 14, "")
    PVPHonorYesterdayKills:SetFont(STANDARD_TEXT_FONT, 14, "")
    PVPHonorLifetimeLabel:SetFont(STANDARD_TEXT_FONT, 14, "")
    PVPHonorLifetimeKills:SetFont(STANDARD_TEXT_FONT, 14, "")

    PVPTeam1Standard:ClearAllPoints()
    PVPTeam1Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 150, 40)

    PVPTeam2Standard:ClearAllPoints()
    PVPTeam2Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 150, -50)

    PVPTeam3Standard:ClearAllPoints()
    PVPTeam3Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 150, -140)
end

local function LoadBattlegroundFrame(battlegroundFrame)
    BattlefieldFrame.Hide = BattlefieldFrame.Show
    BattlefieldFrame:Show()
    BattlefieldFrame:SetParent(battlegroundFrame)
    BattlefieldFrame:ClearAllPoints()
    BattlefieldFrame:SetPoint("TOPLEFT", battlegroundFrame, "TOPLEFT", 0, -40)
    BattlefieldFrame:SetPoint("BOTTOMRIGHT", battlegroundFrame, "BOTTOMRIGHT", 0, 8)


    BattlefieldFrame:GwStripTextures()
    BattlefieldFrameBGTex:Hide()

    BattlefieldFrameCloseButton:Hide()

    BattlefieldFrameFrameLabel:ClearAllPoints()
    BattlefieldFrameFrameLabel:SetPoint("TOP", BattlefieldFrame, "TOP", 0, 20)
    BattlefieldFrameFrameLabel:SetFont(UNIT_NAME_FONT, 24, "")
    BattlefieldFrameFrameLabel:SetTextColor(1, 1, 1)

    BattlefieldFrameNameHeader:ClearAllPoints()
    BattlefieldFrameNameHeader:SetPoint("TOPLEFT", BattlefieldFrame, "TOPLEFT", 20, -30)
    BattlefieldFrameNameHeader:SetFont(UNIT_NAME_FONT, 20, "")
    BattlefieldFrameNameHeader:SetTextColor(1, 1, 1)

    if WintergraspTimer then
        WintergraspTimer:ClearAllPoints()
        WintergraspTimer:SetPoint("RIGHT", BattlefieldFrame, "TOPRIGHT", -20, -0)
        WintergraspTimer:SetSize(50, 50)
        WintergraspTimer.texture:SetSize(50, 50)
    end

    hooksecurefunc("PVPBattleground_UpdateBattlegrounds", function()
        for i = 1, GetNumBattlegroundTypes() do
            if _G["BattlegroundType" .. i] then
                _G["BattlegroundType" .. i]:SetSize(560, 20)
            end
        end
    end)

    BattlefieldFrameCancelButton:Hide()

    BattlefieldFrameJoinButton:ClearAllPoints()
    BattlefieldFrameJoinButton:SetPoint("RIGHT", BattlefieldFrame, "BOTTOMRIGHT", -20, 20)

    BattlefieldFrameJoinButton:GwSkinButton(false, true)
    BattlefieldFrameGroupJoinButton:GwSkinButton(false, true)

    BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)
    BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)
end

local function menuItem_OnClick(self)
    local menuItems = self:GetParent().items
    for _, v in pairs(menuItems) do
        v:ClearNormalTexture()
        v.ToggleMe:Hide()
    end
    self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.ToggleMe:Show()
end

local function LoadPvp()
    local pvpWindow = CreateFrame("Frame", "GwPvpDetailsFrame", GwCharacterWindow, "GwCharacterTabContainer")
    local pvpFrame_outer = CreateFrame("Frame", "GWCharacterPvpFrame", pvpWindow, "GwPvpWindow")

    -- setup pvp window
    LoadPvpFrame(pvpFrame_outer.Pvp)

    -- setup battleground window
    LoadBattlegroundFrame(pvpFrame_outer.Battleground)

    -- setup a menu frame
    local fmMenu = CreateFrame("Frame", "GWPvpMenu", pvpWindow, "GwCharacterMenuTemplate")
    fmMenu.items = {}

    local item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplateNew")
    item.ToggleMe = pvpFrame_outer.Pvp
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(PVP)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.items.pvp = item

    item = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplateNew")
    item.ToggleMe = pvpFrame_outer.Battleground
    item:SetScript("OnClick", menuItem_OnClick)
    item:SetText(BATTLEGROUND)
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", fmMenu.items.pvp, "BOTTOMLEFT")
    fmMenu.items.battleground = item

    GW.CharacterMenuButton_OnLoad(fmMenu.items.pvp, false)
    GW.CharacterMenuButton_OnLoad(fmMenu.items.battleground, true)

    fmMenu.items.pvp:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")

    PVPParentFrame:HookScript("OnShow", function()
        TogglePVPFrame()
        if not InCombatLockdown() then
            ToggleCharacter("PvpFrame")
        end
    end)

    return pvpWindow
end
GW.LoadPvp = LoadPvp