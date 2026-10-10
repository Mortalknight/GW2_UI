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

local function UpdateButton(button)
    button:SetEnabled(#GetAffordableServices() > 0)
end

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
    button:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT", -4, 0)
    button:GwSkinButton(false, true)
    button:SetScript("OnClick", TrainAll)
    hooksecurefunc("ClassTrainerFrame_Update", function() UpdateButton(button) end)
    UpdateButton(button)
end

local function LoadTrainAllButton()
    if not GW.settings.general.trainAllButton then return end
    GW.RegisterLoadHook(CreateTrainAllButton, "Blizzard_TrainerUI", ClassTrainerFrame)
end
GW.LoadTrainAllButton = LoadTrainAllButton
