-- Copyright 2022 plusmouse. Licensed under terms found in LICENSE file.
-- https://github.com/plusmouse/LibEditModeOverride


-- Copyright 2022 plusmouse. Licensed under terms found in LICENSE file.

local lib = LibStub:NewLibrary("LibEditModeOverride-1.0", 7)

local pointGetter = CreateFrame("Frame", nil, UIParent)

local FRAME_ERROR = "This frame isn't used by edit mode"
local LOAD_ERROR = "You need to call LibEditModeOverride:LoadLayouts first"
local EDIT_ERROR = "Active layout is not editable"

local layoutInfo
local reconciledLayouts = false

local function GetSystemByID(systemID, systemIndex)
  -- Get the system by checking each one for the right system id
  for _, system in pairs(layoutInfo.layouts[layoutInfo.activeLayout].systems) do
    if system.system == systemID and system.systemIndex == systemIndex then
      return system
    end
  end
end

local function GetSystemByFrame(frame)
  assert(frame and type(frame) == "table" and frame.IsObjectType and frame:IsObjectType("Frame"), "Frame required")

  local systemID = frame.system
  local systemIndex = frame.systemIndex

  return GetSystemByID(systemID, systemIndex)
end

local function GetParameterRestrictions(frame, setting)
  local systemRestrictions = EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[frame.system]
  for _, setup in ipairs(systemRestrictions) do
    if setup.setting == setting then
      return setup
    end
  end
  return nil
end

local function GetLayoutIndex(layoutName)
  for index, layout in ipairs(layoutInfo.layouts) do
    if layout.layoutName == layoutName then
      return index
    end
  end
end

local function GetHighestIndex()
  local highestLayoutIndexByType = {};
  for index, layoutInfo in ipairs(layoutInfo.layouts) do
    if not highestLayoutIndexByType[layoutInfo.layoutType] or highestLayoutIndexByType[layoutInfo.layoutType] < index then
      highestLayoutIndexByType[layoutInfo.layoutType] = index;
    end
  end
  return highestLayoutIndexByType
end

function lib:SetGlobalSetting(setting, value)
  C_EditMode.SetAccountSetting(setting, value)
end

function lib:GetGlobalSetting(setting)
  local currentSettings = C_EditMode.GetAccountSettings()

  for _, s in ipairs(currentSettings) do
    if s.setting == setting then
      return s.value
    end
  end
end

function lib:HasEditModeSettings(frame)
  return GetSystemByFrame(frame) ~= nil
end

-- Set an option found in the Enum.EditMode enumerations
function lib:SetFrameSetting(frame, setting, value)
  assert(lib:CanEditActiveLayout(), EDIT_ERROR)
  local system = GetSystemByFrame(frame)

  assert(system, FRAME_ERROR)

  assert(value == math.floor(value), "Non-negative integer values only")

  local restrictions = GetParameterRestrictions(frame, setting)

  if restrictions then
    local min, max
    if restrictions.type == Enum.EditModeSettingDisplayType.Dropdown then
      min = 1
      max = #restrictions.options
    elseif restrictions.type == Enum.EditModeSettingDisplayType.Checkbox then
      min = 0
      max = 1
    elseif restrictions.type == Enum.EditModeSettingDisplayType.Slider then
      if restrictions.stepSize then
        min = 0
        max = restrictions.maxValue - restrictions.minValue
      else
        min = restrictions.minValue
        max = restrictions.maxValue
      end
    else
      error("Internal Error: Unknown setting restrictions")
    end
    assert(min <= value and value <= max, string.format("Value %s invalid for this setting: min %s, max %s", value, min, max))
  end

  for _, item in pairs(system.settings) do
    if item.setting == setting then
      item.value = value
    end
  end
end

function lib:GetFrameSetting(frame, setting)
  local system = GetSystemByFrame(frame)

  assert(system, FRAME_ERROR)

  for _, item in pairs(system.settings) do
    if item.setting == setting then
      return item.value
    end
  end
  return nil
end

function lib:ReanchorFrame(frame, ...)
  assert(lib:CanEditActiveLayout(), EDIT_ERROR)
  local system = GetSystemByFrame(frame)

  assert(system, FRAME_ERROR)

  system.isInDefaultPosition = false

  pointGetter:ClearAllPoints()
  pointGetter:SetPoint(...)
  local anchorInfo = system.anchorInfo

  anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.offsetX, anchorInfo.offsetY = pointGetter:GetPoint(1)
  anchorInfo.relativeTo = anchorInfo.relativeTo:GetName()
end

function lib:AreLayoutsLoaded()
  return layoutInfo ~= nil
end

function lib:LoadLayouts()
  layoutInfo = C_EditMode.GetLayouts()

  if not reconciledLayouts then
    local anyChanged = false
    for _, layout in ipairs(layoutInfo.layouts) do
      anyChanged = anyChanged or EditModeManagerFrame:ReconcileWithModern(layout)
    end
    if not anyChanged then
      reconciledLayouts = true
    end
  end

  local tmp = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
  tAppendAll(tmp, layoutInfo.layouts);
  layoutInfo.layouts = tmp
end

function lib:SaveOnly()
  assert(layoutInfo, LOAD_ERROR)
  C_EditMode.SaveLayouts(layoutInfo)
  reconciledLayouts = true -- Would have updated for new/old systems in LoadLayouts
end

function lib:ApplyChanges()
  assert(not InCombatLockdown(), "Cannot move frames in combat")
  lib:SaveOnly()

  ShowUIPanel(EditModeManagerFrame)
  HideUIPanel(EditModeManagerFrame)
end

function lib:DoesLayoutExist(layoutName)
  assert(layoutInfo, LOAD_ERROR)
  return GetLayoutIndex(layoutName) ~= nil
end

function lib:AddLayout(layoutType, layoutName)
  assert(layoutInfo, LOAD_ERROR)
  assert(layoutName and layoutName ~= "", "Non-empty string required")
  assert(not lib:DoesLayoutExist(layoutName), "Layout should not already exist")

  local newLayout = CopyTable(layoutInfo.layouts[1]) -- Modern layout

  newLayout.layoutType = layoutType
  newLayout.layoutName = layoutName

  local highestLayoutIndexByType = GetHighestIndex()

  local newLayoutIndex;
  if highestLayoutIndexByType[layoutType] then
    newLayoutIndex = highestLayoutIndexByType[layoutType] + 1;
  elseif (layoutType == Enum.EditModeLayoutType.Character) and highestLayoutIndexByType[Enum.EditModeLayoutType.Account] then
    newLayoutIndex = highestLayoutIndexByType[Enum.EditModeLayoutType.Account] + 1;
  else
    newLayoutIndex = Enum.EditModePresetLayoutsMeta.NumValues + 1;
  end

  table.insert(layoutInfo.layouts, newLayoutIndex, newLayout)
  C_EditMode.OnLayoutAdded(newLayoutIndex)
  C_EditMode.SetActiveLayout(newLayoutIndex)
end

function lib:DeleteLayout(layoutName)
  assert(layoutInfo, LOAD_ERROR)
  local index = GetLayoutIndex(layoutName)
  assert(index ~= nil, "Can't delete layout as it doesn't exist")

  assert(layoutInfo.layouts[index].layoutType ~= Enum.EditModeLayoutType.Preset, "Cannot delete preset layouts")

  table.remove(layoutInfo.layouts, index)
  C_EditMode.OnLayoutDeleted(index)
end

function lib:GetEditableLayoutNames()
  assert(layoutInfo, LOAD_ERROR)
  local names = {}
  for _, layout in ipairs(layoutInfo.layouts) do
    if layout.layoutType ~= Enum.EditModeLayoutType.Preset then
      table.insert(names, layout.layoutName)
    end
  end

  return names
end

function lib:GetPresetLayoutNames()
  assert(layoutInfo, LOAD_ERROR)
  local names = {}
  for _, layout in ipairs(layoutInfo.layouts) do
    if layout.layoutType == Enum.EditModeLayoutType.Preset then
      table.insert(names, layout.layoutName)
    end
  end

  return names
end

function lib:CanEditActiveLayout()
  assert(layoutInfo, LOAD_ERROR)
  return layoutInfo.layouts[layoutInfo.activeLayout].layoutType ~= Enum.EditModeLayoutType.Preset
end

function lib:SetActiveLayout(layoutName)
  assert(layoutInfo, LOAD_ERROR)
  assert(lib:DoesLayoutExist(layoutName), "Layout must exist")

  local index = GetLayoutIndex(layoutName)

  layoutInfo.activeLayout = index
  C_EditMode.SetActiveLayout(index)
end

function lib:GetActiveLayout()
  assert(layoutInfo, LOAD_ERROR)
  return layoutInfo.layouts[layoutInfo.activeLayout].layoutName
end