local _, GW = ...
local L = GW.L

local ClassTalentsID
local spec_data = {}
local specList = {{text = SPECIALIZATION, isTitle = true, notCheckable = true}}
local loadoutList = { { text = L["Loadouts"], isTitle = true, notCheckable = true } }
local STARTER_ID = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID

local displayString, active = strjoin("", "|cffFFFFFF%s:|r ")

local activeString = strjoin("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = strjoin("", "|cffFF0000", FACTION_INACTIVE, "|r")

local menuList = {
    { text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
    { checked = function() return GetLootSpecialization() == 0 end, func = function() SetLootSpecialization(0) end },
}
local STARTER_TEXT = GW.RGBToHex(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, nil, TALENT_FRAME_DROP_DOWN_STARTER_BUILD)
local specText = "|T%s:14:14:0:0:64:64:4:60:4:60|t  %s"

local function menu_checked(data) return data and data.arg1 == GetLootSpecialization() end
local function menu_func(_, arg1) SetLootSpecialization(arg1) end

local function spec_checked(data) return data and data.arg1 == GetSpecialization() end
local function spec_func(_, arg1) SetSpecialization(arg1) end

local loadout_func
do
    local loadoutID
    local function loadout_callback(_, configID)
        return configID == loadoutID
    end

    loadout_func = function(_, arg1)
        if not ClassTalentFrame then
            ClassTalentFrame_LoadUI()
        end

        loadoutID = arg1

        ClassTalentFrame.TalentsTab:LoadConfigByPredicate(loadout_callback)
    end
end

local function loadout_checked(data)
    return data and data.arg1 == ClassTalentsID
end

local function GetSpecData()
    for index = 1, GetNumSpecializations() do
        local id, name, _, icon, role = GetSpecializationInfo(index)

        if id then
            spec_data[index] = {id = id, name = name, icon = icon, role = getglobal(role)}
            spec_data[id] = {name = name, icon = icon, role = getglobal(role)}
       end
    end
end

local function AddTexture(texture)
    return texture and format("|T%s:16:16:0:0:50:50:4:46:4:46|t", texture) or ""
end

local function TalentButton_OnEnter(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    -- get blizzard tooltip infos:
    GameTooltip_SetTitle(GameTooltip, self.tooltipText)
    if not self:IsEnabled() then
        if self.factionGroup == "Neutral" then
            GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.minLevel then
            GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.disabledTooltip then
            local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip")
            GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        end
    end
    GameTooltip:AddLine(" ")

    for i, info in ipairs(spec_data) do
        GameTooltip:AddLine(strjoin(" ", format(displayString, info.name), AddTexture(info.icon), (i == active and activeString or inactiveString)), 1, 1, 1)
    end

    GameTooltip:AddLine(" ")

    local specialization = GetLootSpecialization()
    local sameSpec = specialization == 0 and GetSpecialization()
    local specIndex = spec_data[sameSpec or specialization]
    if specIndex and specIndex.name then
        GameTooltip:AddLine(format("|cffFFFFFF%s:|r %s", SELECT_LOOT_SPECIALIZATION, sameSpec and format(LOOT_SPECIALIZATION_DEFAULT, specIndex.name) or specIndex.name))
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["Loadouts"], 0.69, 0.31, 0.31)

    for index, loadout in next, loadoutList do
        if index > 1 then
            local text = loadout:checked() and activeString or inactiveString
            GameTooltip:AddLine(strjoin(" - ", loadout.text, text), 1, 1, 1)
        end
    end

    local pvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    if next(pvpTalents) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(PVP_TALENTS, 0.69, 0.31, 0.31)

        for i, talentID in next, pvpTalents do
            if i > 4 then break end

            local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
            if name and unlocked then
                GameTooltip:AddLine(AddTexture(icon) .. " " .. name)
            end
        end
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["|cffFFFFFFLeft Click:|r Show Talent Specialization UI"])
    GameTooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Change Talent Specialization"])
    GameTooltip:AddLine(L["|cffFFFFFFControl + Left Click:|r Change Loadout"])
    GameTooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Loot Specialization"])
    GameTooltip:Show()
end
GW.TalentButton_OnEnter = TalentButton_OnEnter

local function TalentButton_OnEvent(self, event, loadoutID)
    -- MicroMenu unused indicator
    if not ClassTalentFrame then
        ClassTalentFrame_LoadUI()
    end
    local configId = ClassTalentFrame.TalentsTab:GetConfigID()
    local talentTreeId = ClassTalentFrame.TalentsTab:GetTalentTreeID()
    local excludeStagedChangesForCurrencies = ClassTalentFrame.TalentsTab.excludeStagedChangesForCurrencies

    if configId and configId > 0 and talentTreeId and talentTreeId > 0 then
        local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configId, talentTreeId, excludeStagedChangesForCurrencies)
        local counter = treeCurrencyInfo[1].quantity + treeCurrencyInfo[2].quantity
        if counter > 0 then
            self.GwNotify:Show()
            self.GwNotifyText:SetText(counter)
            self.GwNotifyText:Show()
        else
            self.GwNotify:Hide()
            self.GwNotifyText:Hide()
        end
    else
        self.GwNotify:Hide()
        self.GwNotifyText:Hide()
    end

    if #menuList == 2 then
        for index = 1, GetNumSpecializations() do
            local id, name, _, icon = GetSpecializationInfo(index)
            if id then
                menuList[index + 2] = { arg1 = id, text = name, checked = menu_checked, func = menu_func }
                specList[index + 1] = { arg1 = index, text = format(specText, icon, name), checked = spec_checked, func = spec_func }
            end
        end
    end

    local specIndex = GetSpecialization()
    local info = spec_data[specIndex]
    local ID = info and info.id

    if (event == "CONFIG_COMMIT_FAILED" or event == "FORCE_UPDATE" or event == "TRAIT_CONFIG_DELETED" or event == "TRAIT_CONFIG_UPDATED") and PlayerUtil.CanUseClassTalents() then
        if not ClassTalentsID then
            ClassTalentsID = (C_ClassTalents.GetHasStarterBuild() and C_ClassTalents.GetStarterBuildActive() and STARTER_ID) or C_ClassTalents.GetLastSelectedSavedConfigID(ID)
        end

        local builds = C_ClassTalents.GetConfigIDsBySpecID(ID)
        if builds and C_ClassTalents.GetHasStarterBuild() then
            tinsert(builds, STARTER_ID)
        end

        if event == "TRAIT_CONFIG_DELETED"  then
            for index = #loadoutList, 2, -1 do
                local loadout = loadoutList[index]
                if loadout and loadout.arg1 == loadoutID then
                    tremove(loadoutList, index)
                end
            end
        end

        for index, configID in next, builds do
            if configID == STARTER_ID then
                loadoutList[index + 1] = { text = STARTER_TEXT, checked = C_ClassTalents.GetStarterBuildActive, func = loadout_func, arg1 = STARTER_ID }
            else
                local configInfo = C_Traits.GetConfigInfo(configID)
                loadoutList[index + 1] = { text = configInfo and configInfo.name or UNKNOWN, checked = loadout_checked, func = loadout_func, arg1 = configID }
            end
        end
    end

    active = specIndex
end
GW.TalentButton_OnEvent = TalentButton_OnEvent

local function InitTalentDataText()
    GetSpecData()
    hooksecurefunc(C_ClassTalents, "UpdateLastSelectedSavedConfigID", function(_, newConfigID)
        if not newConfigID then return end
        if ClassTalentsID and newConfigID == C_ClassTalents.GetActiveConfigID() then return end
        ClassTalentsID = newConfigID

        TalentButton_OnEvent(TalentMicroButton, "FORCE_UPDATE")
    end)
    TalentButton_OnEvent(TalentMicroButton, "FORCE_UPDATE")
end
GW.InitTalentDataText = InitTalentDataText

local function TalentButton_OnClick(self, button)
    local specIndex = GetSpecialization()
    if not specIndex then return end
    local menu
    if button == "LeftButton" then
        local frame = ClassTalentFrame
        if not frame then
            LoadAddOn("Blizzard_ClassTalentUI")
            frame = ClassTalentFrame
        end

        if IsShiftKeyDown() then
            menu = specList
        elseif IsControlKeyDown() then
            menu = loadoutList
        else
            if frame:IsShown() then
                HideUIPanel(frame)
            else
                ShowUIPanel(frame)
            end
        end
    else
        local _, specName = GetSpecializationInfo(specIndex)
        if specName then
            menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)

            menu = menuList
        end
    end

    if menu then
        GW.SetEasyMenuAnchor(GW.EasyMenu, self)
        EasyMenu(menu, GW.EasyMenu, nil, nil, nil, "MENU")
    end
end
GW.TalentButton_OnClick = TalentButton_OnClick
