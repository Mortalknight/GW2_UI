local _, GW = ...

local function CreateEntry(name, command, description)
    _G["BINDING_NAME_CLICK " .. name .. ":LeftButton"] = description
	local btn = CreateFrame("Button", name, nil, "SecureActionButtonTemplate")
	btn:SetAttribute("type", "macro")
	btn:SetAttribute("macrotext", command)
	btn:RegisterForClicks("AnyDown")
end

local function LoadMarkers()
    BINDING_HEADER_GW2UI_WORLD_MARKER = string.gsub(WORLD_MARKER, "%%d", "")
    for i = 1, 8 do
        CreateEntry("GW2UI_Markers_Button" .. i, "/clearworldmarker "..i.."\n/worldmarker "..i, _G["WORLD_MARKER"..i])
    end
    CreateEntry("GW2UI_Markers_ButtonCWM", "/clearworldmarker 0", REMOVE_WORLD_MARKERS)

    _G["BINDING_HEADER_GW2UI_MOVE_BINDINGS"] = BINDING_HEADER_MOVEMENT
    _G["BINDING_NAME_CLICK GwDodgeBar:LeftButton"] = DODGE

    BINDING_NAME_BAG_SORT = BAG_CLEANUP_BAGS
    BINDING_NAME_BANK_SORT = BAG_CLEANUP_BANK
end
GW.LoadMarkers = LoadMarkers
