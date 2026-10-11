---@class GW2
local GW = select(2, ...)

-- retail returns the service type second, the classic trainer third
local function IsAvailable(index)
    local _, second, third = GetTrainerServiceInfo(index)
    return second == "available" or third == "available"
end

-- from the last service, buying one shifts the ones behind it
local function GetAffordableServices()
    local money, services = GetMoney(), {}
    for i = GetNumTrainerServices(), 1, -1 do
        if IsAvailable(i) then
            local cost = GetTrainerServiceCost(i) or 0
            if cost <= money then
                money = money - cost
                services[#services + 1] = i
            end
        end
    end
    return services
end

local trainAllButton

local function UpdateButton()
    if not trainAllButton then return end
    trainAllButton:SetShown(GW.settings.general.trainAllButton)
    trainAllButton:SetEnabled(#GetAffordableServices() > 0)
end
GW.UpdateTrainAllButton = UpdateButton

local function TrainAll()
    for _, index in ipairs(GetAffordableServices()) do
        BuyTrainerService(index)
    end
end

local function CreateTrainAllButton()
    -- leatrix plus brings its own
    if _G.LeaPlusGlobalTrainAllButton then return end
    local button = CreateFrame("Button", "GwTrainAllButton", ClassTrainerFrame, "UIPanelButtonTemplate")
    button:SetText(GW.L["Train all"])
    button:SetSize(ClassTrainerTrainButton:GetWidth(), ClassTrainerTrainButton:GetHeight())
    -- the old trainer has its money left of the train button, there it goes next to the filter
    if GW.isModern then
        button:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT", -4, 0)
    else
        button:SetPoint("RIGHT", ClassTrainerFrame.FilterDropdown, "LEFT", -5, 0)
    end
    button:GwSkinButton(false, true)
    button:SetScript("OnClick", TrainAll)
    trainAllButton = button
    hooksecurefunc("ClassTrainerFrame_Update", UpdateButton)
    UpdateButton()
end

local function LoadTrainAllButton()
    GW.RegisterLoadHook(CreateTrainAllButton, "Blizzard_TrainerUI", ClassTrainerFrame)
end
GW.LoadTrainAllButton = LoadTrainAllButton
