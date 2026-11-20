---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Pawn upgrade arrows through Pawns own throttled check; it answers nil while it is busy or the item has no
-- data yet, those buttons ask again on the next frames
local answers = {}
local waiting = {}

local function AskPawn(itemLink)
    if answers[itemLink] == nil and PawnIsInitialized then
        answers[itemLink] = PawnShouldItemLinkHaveUpgradeArrow(itemLink, true)
    end
    return answers[itemLink]
end

local retry = CreateFrame("Frame")
retry:Hide()
retry:SetScript("OnUpdate", function(self)
    for button, itemLink in pairs(waiting) do
        local isUpgrade = AskPawn(itemLink)
        if isUpgrade ~= nil then
            waiting[button] = nil
            -- the slot may hold another item by now
            local bagID = button.gwBagID or (button.GetBagID and button:GetBagID())
            if bagID and C_Container.GetContainerItemLink(bagID, button:GetID()) == itemLink then
                button.UpgradeIcon:SetShown(isUpgrade)
            end
        end
    end
    if not next(waiting) then
        self:Hide()
    end
end)

-- several changes in one frame refresh the bags once
local refresh = CreateFrame("Frame")
refresh:Hide()
refresh:SetScript("OnUpdate", function(self)
    self:Hide()
    GW.UpdateAllOwnBagItemButtons()
end)

local function ForgetAnswers()
    wipe(answers)
    refresh:Show()
end

local watcher = CreateFrame("Frame")
-- pawn reads UnitLevel itself, which is only current from UNIT_LEVEL on
watcher:RegisterUnitEvent("UNIT_LEVEL", "player")
watcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
watcher:RegisterEvent("ADDON_LOADED")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:SetScript("OnEvent", function(self, event, arg)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        -- the bag slots are inventory slots too
        if arg < C_Container.ContainerIDToInventoryID(1) then
            ForgetAnswers()
        end
    elseif event == "UNIT_LEVEL" then
        ForgetAnswers()
    elseif PawnShouldItemLinkHaveUpgradeArrow then
        -- spec and scale changes of pawn
        hooksecurefunc("PawnInvalidateBestItems", ForgetAnswers)
        hooksecurefunc("PawnResetTooltips", ForgetAnswers)
        self:UnregisterEvent("ADDON_LOADED")
        self:UnregisterEvent("PLAYER_LOGIN")
        ForgetAnswers()
    end
end)

local function ShowUpgradeIcon(button, itemLink)
    waiting[button] = nil
    local isUpgrade = false
    if PawnShouldItemLinkHaveUpgradeArrow then
        isUpgrade = AskPawn(itemLink)
    end
    if isUpgrade == nil then
        -- the same item keeps its arrow while pawn recalculates
        if button.gwPawnLink ~= itemLink then
            button.UpgradeIcon:Hide()
        end
        waiting[button] = itemLink
        retry:Show()
    else
        button.UpgradeIcon:SetShown(isUpgrade)
    end
    button.gwPawnLink = itemLink
end

GW.RegisterItemButtonDecorator(function(button)
    if not button.UpgradeIcon then return end

    local info = GW.settings.bags.items.upgradeIcon and (button.gwItemInfo or C_Container.GetContainerItemInfo(button.gwBagID, button:GetID()))
    if info and info.hyperlink then
        ShowUpgradeIcon(button, info.hyperlink)
    else
        button.UpgradeIcon:Hide()
    end
end)

GW.RegisterBagModule({
    onMenu = function(_, _, addCheck)
        if C_AddOns.IsAddOnLoaded("Pawn") then
            addCheck(L["Show Upgrade Icon"], function() return GW.settings.bags.items.upgradeIcon end,
                     function() GW.settings.bags.items.upgradeIcon = not GW.settings.bags.items.upgradeIcon; GW.UpdateAllOwnBagItemButtons() end, "bags.items.upgradeIcon")
        end
    end,
})
