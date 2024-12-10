local _, GW = ...

local callbacks = {}

function GW.CustomClassColorUpdate()
    for func in next, callbacks do
        func()
    end
end

function GW.CustomClassColorRegister(_, func)
    callbacks[func] = true
end

function GW.CustomClassColorUnregister(_, func)
    callbacks[func] = nil
end

function GW.CustomClassColorNotify(_, changed)
    GW.UpdateCustomClassColors()
    if changed then
        GW.CustomClassColorUpdate()
    end
end

function GW.CustomClassColorClassToken(_, className)
    return GW:UnlocalizedClassName(className)
end

local meta = {
    __index = {
        RegisterCallback = GW.CustomClassColorRegister,
        UnregisterCallback = GW.CustomClassColorUnregister,
        NotifyChanges = GW.CustomClassColorNotify,
        GetClassToken = GW.CustomClassColorClassToken
    }
}

function GW.SetupCustomClassColors()
    local object = CopyTable(RAID_CLASS_COLORS)

    CUSTOM_CLASS_COLORS = setmetatable(object, meta)

    return object
end

function GW.UpdateCustomClassColor(classTag, r, g, b, changed)
    local colors = CUSTOM_CLASS_COLORS
    local color = colors and colors[classTag]
    local brightUpValue = not GW.settings.BLIZZARDCLASSCOLOR_ENABLED and GW.settings.brightenUpClassColorFontString and 0.3 or 0

    if color then
        color.r, color.g, color.b = r, g, b
        color.colorStr = GW.RGBToHex(min(1, color.r + brightUpValue), min(1, color.g + brightUpValue), min(1, color.b + brightUpValue), "ff")
    end

    local db = GW.private.CustomClassColor[classTag]
    if db then
        db.r, db.g, db.b = r, g, b
    end
    GW.CustomClassColorNotify(nil, changed)
end

function GW.UpdateCustomClassColors()
    local custom = CUSTOM_CLASS_COLORS or GW.SetupCustomClassColors()
    local colors = GW.private.CustomClassColor
    local brightUpValue = not GW.settings.BLIZZARDCLASSCOLOR_ENABLED and GW.settings.brightenUpClassColorFontString and 0.3 or 0

    for classTag, db in next, colors do
        local color = custom[classTag]
        if color then
            if color.r ~= db.r or color.g ~= db.g or color.b ~= db.b then
                color.r, color.g, color.b = db.r, db.g, db.b
                color.colorStr = GW.RGBToHex(min(1, color.r + brightUpValue), min(1, color.g + brightUpValue), min(1, color.b + brightUpValue), "ff")
            end
        end
    end
end