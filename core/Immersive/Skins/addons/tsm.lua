local _, GW = ...

local skinLoaded = false

local function AddTsmTab()
    if AuctionHouseFrame:GetScale() < 0.5 then
        return
    end
    if skinLoaded then return end
    local libAhTab = LibStub:GetLibrary("LibAHTab-1-0", true)
    skinLoaded = true

    local tab = libAhTab:GetButton("TSM_AH_TAB")
    if not tab then return end
    if not tab.isSkinned then
        local iconTexture = "Interface/AddOns/GW2_UI/textures/Auction/tabicon_addon_tsm"
        GW.SkinSideTabButton(tab, iconTexture, "TSM")
    end

    tab:ClearAllPoints()
    tab:SetPoint("TOPRIGHT", AuctionHouseFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * GW.ActionHouseTabsAdded))
    tab:SetParent(AuctionHouseFrame.LeftSidePanel)
    tab:SetSize(64, 40)
    GW.ActionHouseTabsAdded = GW.ActionHouseTabsAdded + 1
end

local function LoadTSMAddonSkin()
    if not GW.settings.AuctionHouseSkinEnabled or not TSM_API or not AuctionatorAHFrameMixin then return end
    hooksecurefunc(AuctionatorAHFrameMixin, "OnShow", AddTsmTab)
end
GW.LoadTSMAddonSkin = LoadTSMAddonSkin