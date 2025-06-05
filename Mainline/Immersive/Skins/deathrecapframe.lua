local _, GW = ...
local constBackdropFrame = GW.BackdropTemplates.Default

local function SkinDeathRecapFrame_Loaded()
    if not GW.settings.DEATHRECAPFRAME_SKIN_ENABLED then return end

    DeathRecapFrame.CloseButton:GwSkinButton(false, true)
    DeathRecapFrame.CloseXButton:GwSkinButton(true)

    DeathRecapFrame.CloseXButton:SetSize(20, 20)
    DeathRecapFrame.CloseXButton:ClearAllPoints()
    DeathRecapFrame.CloseXButton:SetPoint("TOPRIGHT", -3, -3)

    DeathRecapFrame:GwCreateBackdrop(constBackdropFrame)
    DeathRecapFrameBorderTopLeft:Hide()
    DeathRecapFrameBorderTopRight:Hide()
    DeathRecapFrameBorderBottomLeft:Hide()
    DeathRecapFrameBorderBottomRight:Hide()
    DeathRecapFrameBorderTop:Hide()
    DeathRecapFrameBorderBottom:Hide()
    DeathRecapFrameBorderLeft:Hide()
    DeathRecapFrameBorderRight:Hide()
    DeathRecapFrame.BackgroundInnerGlow:Hide()
    DeathRecapFrame.Background:Hide()
    DeathRecapFrame.Divider:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep")
    DeathRecapFrame.Divider:SetHeight(2)
    DeathRecapFrame.Divider:ClearAllPoints()
    DeathRecapFrame.Divider:SetPoint("TOPLEFT", 0, -25)
    DeathRecapFrame.Divider:SetPoint("TOPRIGHT", 0, -25)

    for i = 1, 5 do
        local recap = DeathRecapFrame["Recap" .. i]
        recap.SpellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        recap.SpellInfo.IconBorder:SetAlpha(0)
        if i == 1 then
            DeathRecapFrame.Recap1.tombstone:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-dead")
            DeathRecapFrame.Recap1.tombstone:SetSize(30, 30)
            DeathRecapFrame.Recap1.tombstone:ClearAllPoints()
            DeathRecapFrame.Recap1.tombstone:SetPoint("RIGHT", DeathRecapFrame.Recap1.DamageInfo.Amount, "LEFT", 0, 0)
        end
    end

    if C_AddOns.IsAddOnLoaded("Details") then
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
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-dead")
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetTexCoord(0,1,0,1)
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetSize(30, 30)
                    _G["DetailsDeathRecapLine" .. i].graveIcon:ClearAllPoints()
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetPoint("LEFT", _G["DetailsDeathRecapLine" .. i], "LEFT", 0, 0)
                end
            end
        end
    end
end

local function LoadDeathRecapSkin()
    GW.RegisterLoadHook(SkinDeathRecapFrame_Loaded, "Blizzard_DeathRecap", DeathRecapFrame)
end
GW.LoadDeathRecapSkin = LoadDeathRecapSkin