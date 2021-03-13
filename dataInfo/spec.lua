local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

local spec_data = {}
local spec_data_loaded = false
local specList = {
	{text = SPECIALIZATION, isTitle = true, notCheckable = true}
}

local function GetSpecData()
    for index = 1, GetNumSpecializations() do
        local id, name, _, icon = GetSpecializationInfo(index)

        if id then
            spec_data[index] = {id = id, name = name, icon = icon}
            spec_data[id] = {name = name, icon = icon}
            specList[#specList + 1] = { text = format("|T%s:14:14:0:0:64:64:4:60:4:60|t  %s", icon, name), checked = function() return GetSpecialization() == index end, func = function() SetSpecialization(index) end }
        end
    end

    spec_data_loaded = true
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
    GameTooltip_AddBlankLineToTooltip(GameTooltip)

    if not spec_data_loaded then
        GetSpecData()
    end

    for i, info in ipairs(spec_data) do
        if i == GW.myspec then
            --GameTooltip:AddLine(AddTexture(info.icon) .. format("|cffFFFFFF%s:|r ", info.name) .. (i == GW.myspec and ("|cff00FF00" .. ACTIVE_PETS .. "|r") or ("|cffFF0000" .. FACTION_INACTIVE .. "|r")), 1, 1, 1)
            GameTooltip:AddLine(format("|cffFFFFFF%s:|r %s", SPECIALIZATION, AddTexture(info.icon) .. info.name), nil, nil, true)
        end
    end

    --GameTooltip_AddBlankLineToTooltip(GameTooltip)

    local specialization = GetLootSpecialization()
    local sameSpec = specialization == 0 and GW.myspec
    local specIndex = spec_data[sameSpec or specialization]
    if specIndex and specIndex.name then
        GameTooltip:AddLine(format("|cffFFFFFF%s:|r %s %s", SELECT_LOOT_SPECIALIZATION, AddTexture(specIndex.icon), sameSpec and format(LOOT_SPECIALIZATION_DEFAULT, specIndex.name) or specIndex.name), nil, nil, nil ,true)
    end

    GameTooltip_AddBlankLineToTooltip(GameTooltip)
    GameTooltip:AddLine(TALENTS, 1, 0.93, 0.73)

    for i = 1, _G.MAX_TALENT_TIERS do
        for j = 1, 3 do
            local _, name, icon, selected = GetTalentInfo(i, j, 1)
            if selected then
                GameTooltip:AddLine(AddTexture(icon) .. " " .. name)
            end
        end
    end

    local pvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    if next(pvpTalents) then
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
        GameTooltip:AddLine(PVP_TALENTS, 1, 0.93, 0.73)

        for i, talentID in next, pvpTalents do
            if i > 4 then break end
            local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
            if name and unlocked then
                GameTooltip:AddLine(AddTexture(icon ).. " " .. name)
            end
        end
    end

    GameTooltip_AddBlankLineToTooltip(GameTooltip)
    GameTooltip:AddLine("|cffaaaaaa" .. L["Right Click to change Talent Specialization"] .. "|r", nil, nil, nil, true)

    GameTooltip:Show()
end
GW.TalentButton_OnEnter = TalentButton_OnEnter

local function TalentButton_OnClick(self, button)
    if button == "LeftButton" and not GetSetting("USE_TALENT_WINDOW") then
        self:OnClick()
    elseif button == "RightButton" then
        if not spec_data_loaded then
            GetSpecData()
        end
        GW.SetEasyMenuAnchor(GW.EasyMenu, self)
        EasyMenu(specList, GW.EasyMenu, nil, nil, nil, "MENU")
    end
end
GW.TalentButton_OnClick = TalentButton_OnClick
