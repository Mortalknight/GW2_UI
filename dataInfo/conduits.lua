local _, GW = ...
local L = GW.L

local function AddTexture(texture)
    return texture and format("|T%s:16:16:0:0:50:50:4:46:4:46|t", texture) or ""
end

local function AddAtlasTexture(texture)
    return texture and format("|A%s:16:16:0:0:50:50:4:46:4:46|a", texture) or ""
end

local function LandingButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(self.title, 1, 1, 1);
    GameTooltip:AddLine(self.description, nil, nil, nil, true)

    local covenantID = C_Covenants.GetActiveCovenantID()
	if covenantID > 0 then
        local soulbindID = C_Soulbinds.GetActiveSoulbindID()
        if soulbindID == 0 then
            soulbindID = Soulbinds.GetDefaultSoulbindID(covenantID)
        end
        local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID)

        -- load Soulbinds UI if needed (Blizzard one)
        if not IsAddOnLoaded("Blizzard_Soulbinds") then
            LoadAddOn("Blizzard_Soulbinds")
        end

        GameTooltip_AddBlankLineToTooltip(GameTooltip)
        GameTooltip:AddLine( format("|cffFFFFFF%s:|r %s", COVENANT_PREVIEW_SOULBINDS, soulbindData.name), nil, nil, nil, true)
       
	    local nodes = soulbindData.tree.nodes
        local conduits = {}
        local traits = {}

        for _, node in ipairs(nodes) do
            if node.state == Enum.SoulbindNodeState.Selected then
                if node.conduitID and node.conduitID > 0 then
                    tinsert(conduits, {node.conduitID, node.conduitRank, node.conduitType})
                else
                    tinsert(traits, {node.icon, node.spellID})
                end
            end
        end

        if next(conduits) then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip:AddLine(L["Conduits"], 1, 0.93, 0.73)
            for i = 1, #conduits do
                local name, _, icon = GetSpellInfo(C_Soulbinds.GetConduitSpellID(conduits[i][1], conduits[i][2]))
                local conduitItemLevel = C_Soulbinds.GetConduitItemLevel(conduits[i][1], conduits[i][2])
                local conduitQuality = C_Soulbinds.GetConduitQuality(conduits[i][1], conduits[i][2])
                local color = ITEM_QUALITY_COLORS[conduitQuality]

                GameTooltip:AddLine(CreateAtlasMarkup(Soulbinds.GetConduitEmblemAtlas(conduits[i][3])) .. " [" .. conduitItemLevel .. "]  " .. AddTexture(icon) .. " " .. GW.RGBToHex(color.r, color.g, color.b) .. name .. "|r ")
            end
        end

        if next(traits) then
            if #conduits > 0 then GameTooltip_AddBlankLineToTooltip(GameTooltip) end
            GameTooltip:AddLine(GARRISON_TRAITS, 1, 0.93, 0.73)
            for i = 1, #traits do

                GameTooltip:AddLine(AddTexture(traits[i][1]) .. " " .. select(1, GetSpellInfo(traits[i][2])) .. "|r ")
            end
        end
    end

    GameTooltip:Show()
end
GW.LandingButton_OnEnter = LandingButton_OnEnter