local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinDeathRecapFrame_Loaded()
    local DeathRecapFrame = _G.DeathRecapFrame
    DeathRecapFrame.CloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    DeathRecapFrame.CloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    DeathRecapFrame.CloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    DeathRecapFrame.CloseButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    local r = {DeathRecapFrame.CloseButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetTextColor(0, 0, 0, 1)
            c:SetShadowOffset(0, 0)
        end
    end
    addHoverToButton(DeathRecapFrame.CloseButton)

    DeathRecapFrame.CloseXButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    DeathRecapFrame.CloseXButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    DeathRecapFrame.CloseXButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    DeathRecapFrame.CloseXButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    DeathRecapFrame.CloseXButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    DeathRecapFrame.CloseXButton:SetSize(20, 20)
    DeathRecapFrame.CloseXButton:ClearAllPoints()
    DeathRecapFrame.CloseXButton:SetPoint("TOPRIGHT", -3, -3)

    DeathRecapFrame:SetBackdrop(nil)
    DeathRecapFrame:SetBackdrop(constBackdropFrame)
    _G["DeathRecapFrameBorderTopLeft"]:Hide()
    _G["DeathRecapFrameBorderTopRight"]:Hide()
    _G["DeathRecapFrameBorderBottomLeft"]:Hide()
    _G["DeathRecapFrameBorderBottomRight"]:Hide()
    _G["DeathRecapFrameBorderTop"]:Hide()
    _G["DeathRecapFrameBorderBottom"]:Hide()
    _G["DeathRecapFrameBorderLeft"]:Hide()
    _G["DeathRecapFrameBorderRight"]:Hide()
    DeathRecapFrame.BackgroundInnerGlow:Hide()
    DeathRecapFrame.Background:Hide()
    DeathRecapFrame.Divider:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-bottom")
    DeathRecapFrame.Divider:ClearAllPoints()
    DeathRecapFrame.Divider:SetPoint("TOPLEFT", 4, -25)
    DeathRecapFrame.Divider:SetPoint("TOPRIGHT", -4, -25)

    for i = 1, 5 do
		local recap = DeathRecapFrame["Recap" .. i].SpellInfo
		recap.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        recap.IconBorder:SetAlpha(0)
        if i == 1 then
            recap.tombstone:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-dead")
            recap.tombstone:SetSize(30, 30)
            recap.tombstone:ClearAllPoints()
            recap.tombstone:SetPoint("RIGHT", recap.DamageInfo.Amount, "LEFT", 0, 0)
        end
	end

    if IsAddOnLoaded("Details") then
        for i = 1, 10 do
            if _G["DetailsDeathRecapLine" .. i] then
                _G["DetailsDeathRecapLine" .. i].spellIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                local r = {_G["DetailsDeathRecapLine" .. i]:GetRegions()}
                local y = 1
                for _,c in pairs(r) do
                    if c:GetObjectType() == "Texture" then
                        if y == 4 then c:Hide() end
                        y = y + 1
                    end
                end
                if _G["DetailsDeathRecapLine" .. i].graveIcon then
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-dead")
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetTexCoord(0,1,0,1)
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetSize(30, 30)
                    _G["DetailsDeathRecapLine" .. i].graveIcon:ClearAllPoints()
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetPoint("LEFT", _G["DetailsDeathRecapLine" .. i], "LEFT", 0, 0)
                end
            end
        end
    end
end

local function SkinDeathRecapFrame()
    hooksecurefunc("OpenDeathRecapUI", SkinDeathRecapFrame_Loaded)
end
GW.SkinDeathRecapFrame = SkinDeathRecapFrame