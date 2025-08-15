# GW2_UI — External Settings Panel API (for Addon Authors)

Let your addon register its own settings panel inside GW2_UI’s Settings UI. This gives you
search integration, 2-column layout, dependencies and consistent look & feel.

---

## Quick Start

1. Acquire the main Settings tab frame

    ```lua
    local settingsTab = GW2_ADDON.GetSettingsTabFrame()
    ```

2. Create your panel using the built-in template

    ```lua
    local panel = CreateFrame("Frame", "GwYourAddonPanel", settingsTab, "GwSettingsPanelTmpl")
    panel.header:SetFont(DAMAGE_TEXT_FONT, 20)
    panel.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r, GW.TextColors.LIGHT_HEADER.g, GW.TextColors.LIGHT_HEADER.b)
    panel.header:SetText("YOUR ADDON SETTINGS")
    panel.sub:SetFont(UNIT_NAME_FONT, 12)
    panel.sub:SetTextColor(181/255, 160/255, 128/255)
    panel.sub:SetText("Description of your panel.")
    ```

3. Add controls (see API below)

    ```lua
    panel:AddGroupHeader("General")
    panel:AddOption("Enable Feature", "Toggles the main feature", { getter = function() return "opt" end, setter = function(value) print(value) end, getDefault = function() return "opt1" end })
    panel:AddOptionDropdown("Mode", "Choose a mode", {
      getterSetter = "mode",
      optionsList  = {"opt1", "opt2"},
      optionNames  = {"Option 1", "Option 2"}
    })
    panel:AddOptionSlider("Opacity", nil, {
      getter = function() return 2 end, setter = function(value) print(value) end, getDefault = function() return 1 end,
      min = 0, max = 1, step = 0.01, decimalNumbers = 2,
      dependence     = { enableFeature = true }, -- shown/enabled only if enableFeature is true
    })
    ```

4. Register the panel with namespace support, returnes the namespace DB object

    ```lua
    --    AddSettingsPanel(basePanel, name, desc, subFramesOrNil, isAddon)
    local db = settingsTab:AddSettingsPanel(panel,
      "YOUR ADDON SETTINGS",
      "Description of your addon.",
      nil,              -- no sub-panels
      true,             -- isAddon
    )
    ```

## Panel API
Each method creates a widget and returns its option object. The final layout is handled
by GW2_UI (two columns where possible, full row if forced).

1) ``panel:AddOption(name, desc, values)``

    Creates a *boolean toggle* (checkbox).
    General ``values`` *keys* (apply to all API calls; listed later in detail):
    ``getter``, ``setter``, ``getDefault``, ``callback``, ``dependence``, ``forceNewLine``, ``incompatibleAddons``,
    ``groupHeaderName``, ``optionUpdateFunc``

    _No type-specific keys for ``AddOption``_.
2) ``panel:AddOptionButton(name, desc, values)``

    Creates a *button* row (non-toggle action).
    Uses the *general* keys. The action is typically handled via ``values.callback``.
3) ``panel:AddGroupHeader(name, values)``

    Creates a *section/header* row.
    Uses the *general* keys (commonly ``groupHeaderName`` for search grouping is unnecessary here,
    as the header itself acts as a group label).
4) ``panel:AddOptionColorPicker(name, desc, values)``

    Creates a *color picker*.
    Uses the *general* keys.
    _No additional type-specific keys._
5) ``panel:AddOptionSlider(name, desc, values)``

    Creates a *slider*.
    *Type-specific keys (required/optional)*:
    - ``min`` _(number, required)_ — Minimum value
    - ``max`` _(number, required)_ — Maximum value
    - ``step`` _(number, required)_ — Step size
    - ``decimalNumbers`` _(number, optional, default 0)_ — Digits to display after decimal
    The function reads these from ``values`` and applies them to the option.
6) ``panel:AddOptionText(name, desc, values)``

    Creates a *text input*.
    Type-specific keys:
    - ``multiline`` _(boolean, optional)_ — If true, uses a multiline input.
7) ``panel:AddOptionDropdown(name, desc, values)``

    Creates a *dropdown* (single-select by *default*; multi-select when ``checkbox = true`` is supported by template).
    Type-specific keys:
    - ``optionsList`` _(table, required)_ — Array of choice values (e.g., ``{"opt1","opt2"}``)
    - ``optionNames`` _(table, required)_ — Array of display labels (e.g., ``"Option 1","Option 2"}``)
    - ``checkbox`` _(boolean, optional)_ — Show a checkbox list (multi-select) if supported by your data binding
    - ``tooltipType`` _(any, optional)_ — Custom tooltip type hook used by your template
    - ``hasSound`` _(boolean, optional)_ — Play a click sound on change
    - ``noNewLine`` _(boolean, optional)_ — When set, try to keep dropdown in a *half-width column* (overrides template default)


### General ``values`` (all controls)
These keys are available on every API method:
- ``getter``, ``setter``, ``getDefault`` _(string, recommended)_

  The storage key for this option within your namespace (e.g., "enableFeature").
  GW2_UI binds this to a proxy (via CreateSettingProxy) so get()/set() use your addon's namespace.
- ``callback`` _(function(value))_

  Called after the value is set. Use this to apply live changes.
- ``dependence`` _(table)_

  Conditional visibility/enabling based on other option keys.
  Example: ``{ enableFeature = true }`` — only show/enable when ``enableFeature`` is ``true``.
  When you register via ``AddSettingsPanel(..., isAddon=true, addonName=...)``, your dependence keys are auto-resolved inside your namespace (no prefix needed).
- ``forceNewLine`` _(boolean)_

  Forces the widget to *take a full row* (instead of sharing a row in the 2-column layout).
- ``incompatibleAddons`` _(table of strings)_

  If any listed addon is detected, the option may be hidden/disabled. (Behavior depends on the skin; keep as a safety gate.)
- ``groupHeaderName`` _(string)_

  Logical group name. Used by the search UI to group results and draw section headers for hits.
- ``optionUpdateFunc`` _(function(widget))_

  Hook for *dynamic updates* when the panel relayouts or dependencies change (advanced use).


## Layout Notes

  - Widgets are automatically placed in two columns when possible.
    Use ``forceNewLine = true`` to make a control span the full width.
    For dropdowns, ``noNewLine = true`` (type-specific) can force half-width placement when the template would otherwise span full width.

  -  Group headers created via ``AddGroupHeader()`` visually separate sections and are considered by the search.


## Search Integration

  All titles (``name``), group headers (``groupHeaderName``), and descriptions (desc) are indexed for the global settings search.
  Results are shown *by panel* and in *on-screen order*.

## Sub-Panels (Optional)

  If your addon has multiple sections, you can pass a list of subframes to ``AddSettingsPanel`` (as ``subFramesOrNil``).
  Each subframe should be created with the same ``"GwSettingsPanelTmpl"`` and populated with the APIs above.

## Example
  ```lua
  function AddSettingsPanel()
    local frame = GW2_ADDON.GetSettingsTabFrame()
    local basePanel = CreateFrame("Frame", "GwTestPanel", frame, "GwSettingsPanelTmpl")
    basePanel.header:SetFont(DAMAGE_TEXT_FONT, 20)
    basePanel.header:SetTextColor(GW2_ADDON.TextColors.LIGHT_HEADER.r, GW2_ADDON.TextColors.LIGHT_HEADER.g, GW2_ADDON.TextColors.LIGHT_HEADER.b)
    basePanel.header:SetText("TEST ADDON SETTINGS")
    basePanel.sub:SetFont(UNIT_NAME_FONT, 12)
    basePanel.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    basePanel.sub:SetText("External added settings panel for testing purposes.")

    basePanel:AddGroupHeader("Group Header")
    basePanel:AddOption("Checkbox", "Setting description", { getter = function() return true end, setter = function(value) print(value) end, getDefault = function() return false end, callback = function(value) print("Checkbox set to value:", value) end })
    basePanel:AddOptionDropdown(GW.NewSign .. "Dropdown", "Description", { getter = function() return "opt1" end, setter = function(value) print(value) end, getDefault = function() return "opt1" end, callback = function(value) print("Dropdown set to value:", value) end, optionsList = {"opt1", "opt2"}, optionNames = {"Option 1", "Option 2"}, dependence = {settingCheckbox = true, }, checkbox = false, groupHeaderName = "Group Header"})
    basePanel:AddOptionSlider(GW.NewSign .. "Slider", nil, { getter = function() return 1 end, setter = function(value) print(value) end, getDefault = function() return 2 end, callback = function(value) print("Slider set to value:", value) end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, dependence = {XPBAR_ENABLED = true},  groupHeaderName = "Group Header"})

    frame:AddSettingsPanel(basePanel, "TEST ADDON SETTINGS", "External added settings panel for testing purposes.", nil, true)
  end
  ```
