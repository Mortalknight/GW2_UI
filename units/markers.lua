local _, GW = ...

local function LoadMarkers()
    _G["BINDING_HEADER_GW2UI_MARKER_BINDINGS"] = string.gsub(WORLD_MARKER, "%%d", "")
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM8"] = WORLD_MARKER8
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM6"] = WORLD_MARKER6
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM3"] = WORLD_MARKER3
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM1"] = WORLD_MARKER1
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM5"] = WORLD_MARKER5
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM7"] = WORLD_MARKER7
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM2"] = WORLD_MARKER2
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM4"] = WORLD_MARKER4
    _G["BINDING_NAME_CLICK GW2UI_Markers_Button:WM9"] = REMOVE_WORLD_MARKERS

    local btn = CreateFrame("Button", "GW2UI_Markers_Button", UIParent, "SecureActionButtonTemplate")
    btn:Hide()
    btn:RegisterForClicks("AnyUp", "AnyDown")

    btn:SetAttribute("type-WM1", "worldmarker")
    btn:SetAttribute("action-WM1", "set")
    btn:SetAttribute("marker-WM1", "1")

    btn:SetAttribute("type-WM2", "worldmarker")
    btn:SetAttribute("action-WM2", "set")
    btn:SetAttribute("marker-WM2", "2")

    btn:SetAttribute("type-WM3", "worldmarker")
    btn:SetAttribute("action-WM3", "set")
    btn:SetAttribute("marker-WM3", "3")

    btn:SetAttribute("type-WM4", "worldmarker")
    btn:SetAttribute("action-WM4", "set")
    btn:SetAttribute("marker-WM4", "4")

    btn:SetAttribute("type-WM5", "worldmarker")
    btn:SetAttribute("action-WM5", "set")
    btn:SetAttribute("marker-WM5", "5")

    btn:SetAttribute("type-WM6", "worldmarker")
    btn:SetAttribute("action-WM6", "set")
    btn:SetAttribute("marker-WM6", "6")

    btn:SetAttribute("type-WM7", "worldmarker")
    btn:SetAttribute("action-WM7", "set")
    btn:SetAttribute("marker-WM7", "7")

    btn:SetAttribute("type-WM8", "worldmarker")
    btn:SetAttribute("action-WM8", "set")
    btn:SetAttribute("marker-WM8", "8")

    btn:SetAttribute("type-WM9", "worldmarker")
    btn:SetAttribute("action-WM9", "clear")
    btn:SetAttribute("marker-WM9", "0")
end
GW.LoadMarkers = LoadMarkers
