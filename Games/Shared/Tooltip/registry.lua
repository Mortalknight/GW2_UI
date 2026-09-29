---@class GW2
local GW = select(2, ...)

--[[
    Tooltip modules.

    Every module hooks what it needs in its onLoad; the registry runs them once the tooltips
    are ours and offers what several modules share:

        GW.RegisterTooltipModule({
            onLoad = function() end,
        })
]]

local Tooltip = {}
GW.Tooltip = Tooltip

local ID_LINE = "|cffffedba%s|r %s"
local modules = {}
local loaded = false

-- the modern clients and era hand out typed tooltip data, tbc, wrath and mists run the old scripts
local USE_DATA_PROCESSOR = TooltipDataProcessor and not (GW.TBC or GW.Wrath or GW.Mists)
local DATA_SCRIPTS = {Item = "OnTooltipSetItem", Unit = "OnTooltipSetUnit", Spell = "OnTooltipSetSpell"}

-- the ID modifier setting, or any other key setting: always, or while shift, ctrl or alt is held
function Tooltip.IsModifierDown(setting)
    local key = setting or GW.settings.tooltip.idModifier
    return key == "ALWAYS" or key == "SHIFT" and IsShiftKeyDown() or key == "CTRL" and IsControlKeyDown() or key == "ALT" and IsAltKeyDown()
end

function Tooltip.FormatID(id)
    return format(ID_LINE, ID, id)
end

function Tooltip.AddID(tooltip, id, spaced)
    if spaced then
        tooltip:AddLine(" ")
    end
    tooltip:AddLine(Tooltip.FormatID(id))
    tooltip:Show()
end

-- func(tooltip, data) after a tooltip of that type (Item, Unit, Spell, Macro) was filled; data is nil
-- on the clients without typed data, Macro only exists with it
function Tooltip.OnTooltipData(typeName, func)
    if USE_DATA_PROCESSOR then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType[typeName], func)
    elseif DATA_SCRIPTS[typeName] then
        GameTooltip:HookScript(DATA_SCRIPTS[typeName], func)
    end
end

-- the unit a tooltip shows: from its data, from the tooltip, or from the unit frame under the mouse;
-- a secret or vanished token falls back to the mouseover
function Tooltip.GetUnit(tooltip, data)
    if not tooltip or tooltip:IsForbidden() then
        return
    end
    local unit
    if tooltip.IsTooltipType then
        data = data or (tooltip:IsTooltipType(Enum.TooltipDataType.Unit) and tooltip:GetPrimaryTooltipData())
        unit = data and GW.NotSecretValue(data.guid) and data.guid and UnitTokenFromGUID(data.guid)
    else
        unit = select(2, tooltip:GetUnit())
    end
    if not unit then
        local focus = GetMouseFoci()[1]
        unit = focus and focus.GetAttribute and focus:GetAttribute("unit")
    end
    if not unit then
        return
    end
    if GW.NotSecretValue(unit) and UnitExists(unit) then
        return unit
    end
    return UnitExists("mouseover") and "mouseover" or nil
end

-- players in their class color, npcs in their reaction color, tapped ones grey
function Tooltip.GetUnitColor(unit)
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        return GW.GWGetClassColor(class, GW.settings.tooltip.unit.classColor, true)
    end
    local tapDenied = UnitIsTapDenied(unit)
    if GW.NotSecretValue(tapDenied) and tapDenied then
        return GW.Colors.UnitFrameReactionColors.TappedDenied
    end
    local reaction = UnitReaction(unit, "player")
    if GW.IsSecretValue(reaction) or not reaction then
        return RAID_CLASS_COLORS.PRIEST
    elseif reaction >= 5 then
        return GW.Colors.UnitFrameReactionColors.Friendly
    end
    return GW.settings.tooltip.unit.classColor and GW.Colors.FactionBarColors[reaction] or RAID_CLASS_COLORS.PRIEST
end

-- where a mount comes from, by the spell of its aura; the mount journal only exists on some clients
local mountSources
function Tooltip.GetMountSource(spellID)
    if not mountSources then
        mountSources = {}
        if C_MountJournal then
            for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
                local _, mountSpellID = C_MountJournal.GetMountInfoByID(mountID)
                local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)
                if mountSpellID and sourceText then
                    mountSources[mountSpellID] = gsub(sourceText, "|n%s+|n", "|n")
                end
            end
        end
    end
    return GW.NotSecretValue(spellID) and mountSources[spellID]
end

function GW.RegisterTooltipModule(module)
    tinsert(modules, module)
    if loaded then
        module.onLoad()
    end
end

-- once the tooltips are ours
function GW.LoadTooltips()
    if loaded then
        return
    end
    loaded = true
    for _, module in ipairs(modules) do
        module.onLoad()
    end
end
