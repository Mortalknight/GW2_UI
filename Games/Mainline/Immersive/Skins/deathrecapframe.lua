---@class GW2
local GW = select(2, ...)
local constBackdropFrame = GW.BackdropTemplates.Default

local function DeathRecapScrollUpdateChild(child)
    local spellInfo = child.SpellInfo
    if not spellInfo or spellInfo.gwSkinned then return end

    if spellInfo.Icon then
        spellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        spellInfo.IconBorder:SetAlpha(0)
    end
    if spellInfo.tombstone then
        spellInfo.tombstone:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-dead.png")
        spellInfo.tombstone:SetSize(30, 30)
        spellInfo.tombstone:ClearAllPoints()
        spellInfo.tombstone:SetPoint("RIGHT", spellInfo.DamageInfo.Amount, "LEFT", 0, 0)
    end

    spellInfo.gwSkinned = true
end

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
    DeathRecapFrame.Divider:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
    DeathRecapFrame.Divider:SetHeight(2)
    DeathRecapFrame.Divider:ClearAllPoints()
    DeathRecapFrame.Divider:SetPoint("TOPLEFT", 0, -25)
    DeathRecapFrame.Divider:SetPoint("TOPRIGHT", 0, -25)

    if DeathRecapFrame.ScrollBar then
        GW.HandleTrimScrollBar(DeathRecapFrame.ScrollBar)
    end

    if DeathRecapFrame.ScrollBox then
        hooksecurefunc(DeathRecapFrame.ScrollBox, "Update", function(frame)
            frame:ForEachFrame(DeathRecapScrollUpdateChild)
        end)
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
                    _G["DetailsDeathRecapLine" .. i].graveIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-dead.png")
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