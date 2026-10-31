---@class GW2
local GW = select(2, ...)

-- the edit mode windows size themselves from their children, our additions must stay out of that
local function SkinWindow(frame)
    if frame.Border then
        frame.Border:Hide()
    end
    frame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    frame.backdrop.ignoreInLayout = true

    if frame.Title then
        frame.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    end
    if frame.CloseButton then
        frame.CloseButton:GwSkinButton(true)
        frame.CloseButton:SetSize(20, 20)
        frame.CloseButton:ClearAllPoints()
        frame.CloseButton:SetPoint("TOPRIGHT", -5, -5)
    end
end

local function SkinCheckbox(frame)
    frame.gwSkinned = true
    frame.Button:GwSkinCheckButton(false, 20, true)
    if frame.Label then
        frame.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    end
end

-- buttons, checkboxes, sliders and dropdowns are the same templates in every window, and the
-- settings of a frame come from pools, so the children are looked at by what they are
local function SkinWidgets(frame)
    for _, child in ipairs({frame:GetChildren()}) do
        if not child.gwSkinned then
            if child:IsObjectType("EditBox") then
                if not child:GetParent():IsObjectType("ScrollFrame") then
                    GW.SkinEditBox(child)
                end
            elseif child:IsObjectType("Button") and child.Left and child.Middle and child.Right then
                child:GwSkinButton(false, true)
            elseif child.Button and child.Button:IsObjectType("CheckButton") then
                SkinCheckbox(child)
            elseif child.Slider and child.Back and child.Forward then
                GW.SkinStepSlider(child)
            elseif child.Dropdown then
                GW.SkinDropdownControl(child)
            end
        end
        SkinWidgets(child)
    end
end

-- the scroll frames build their bar on load, only the new minimal bar has a thumb we can skin
local function SkinScrollBar(bar)
    if bar and bar.GetThumb then
        GW.HandleTrimScrollBar(bar)
    end
end

local function LoadEditModeSkin()
    if not GW.settings.skins.editMode.enabled or not EditModeManagerFrame then return end

    local manager = EditModeManagerFrame
    SkinWindow(manager)
    SkinWidgets(manager)
    GW.SkinDropdownControl({Dropdown = manager.LayoutDropdown})
    if manager.LayoutLabel then
        manager.LayoutLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        manager.LayoutLabel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
    if manager.Tutorial then
        GW.SkinHelpButton(manager.Tutorial, 20)
        manager.Tutorial:ClearAllPoints()
        manager.Tutorial:SetPoint("RIGHT", manager.CloseButton, "LEFT", -6, 0)
        manager.Tutorial:SetFrameLevel(manager.CloseButton:GetFrameLevel())
    end

    local settings = manager.AccountSettings
    if settings then
        if settings.SettingsContainer then
            if settings.SettingsContainer.BorderArt then
                settings.SettingsContainer.BorderArt:Hide()
            end
            SkinScrollBar(settings.SettingsContainer.ScrollBar)
        end
        local options = settings.SettingsContainer and settings.SettingsContainer.ScrollChild.AdvancedOptionsContainer
        if options then
            for _, key in ipairs({"FramesTitle", "CombatTitle", "MiscTitle"}) do
                local title = options[key] and options[key].Title
                if title then
                    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
                    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
                end
            end
        end
        if settings.Expander and settings.Expander.Label then
            settings.Expander.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
    end

    local dialog = EditModeSystemSettingsDialog
    if dialog then
        SkinWindow(dialog)
        SkinWidgets(dialog)
        hooksecurefunc(dialog, "UpdateDialog", SkinWidgets)
    end

    for _, popup in ipairs({EditModeLayoutDialog, EditModeImportLayoutDialog, EditModeImportLayoutLinkDialog, EditModeUnsavedChangesDialog}) do
        SkinWindow(popup)
        SkinWidgets(popup)
    end

    local importBox = EditModeImportLayoutDialog and EditModeImportLayoutDialog.ImportBox
    if importBox then
        importBox:GwStripTextures()
        GW.AddEditBoxBackground(importBox, 0)
        SkinScrollBar(importBox.ScrollBar)
    end
end
GW.LoadEditModeSkin = LoadEditModeSkin
