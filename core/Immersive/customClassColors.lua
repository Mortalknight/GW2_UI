local _, GW = ...

local callbacks = {}
local setupDone = false

function GW.Gw2ClassColorUpdate()
    for func in next, callbacks do
        func()
    end
end

function GW.Gw2ClassColorRegister(_, func)
    callbacks[func] = true
end

function GW.Gw2ClassColorUnregister(_, func)
    callbacks[func] = nil
end

function GW.Gw2ClassColorNotify(_, changed)
    GW.UpdateGw2ClassColors()
    if changed then
        GW.Gw2ClassColorUpdate()
    end
end

function GW.Gw2ClassColorClassToken(_, className)
    return GW:UnlocalizedClassName(className)
end

local meta = {
    __index = {
        RegisterCallback = GW.Gw2ClassColorRegister,
        UnregisterCallback = GW.Gw2ClassColorUnregister,
        NotifyChanges = GW.Gw2ClassColorNotify,
        GetClassToken = GW.Gw2ClassColorClassToken
    }
}

local function SetupGw2ClassColors()
    GW.GW_CLASS_COLORS = setmetatable(GW.GW_CLASS_COLORS, meta)
    setupDone = true
end

function GW.UpdateGw2ClassColor(classTag, r, g, b, changed)
    local colors = GW.GW_CLASS_COLORS
    local color = colors and colors[classTag]

    if color then
        color.r, color.g, color.b = r, g, b

        -- verify the object is mixed
        if color and not color.GetRGB then
            Mixin(color, ColorMixin)
        end
    end

    local db = GW.private.Gw2ClassColor[classTag]
    if db then
        db.r, db.g, db.b = r, g, b
        db.colorStr = nil
    end
    GW.Gw2ClassColorNotify(nil, changed)
end

function GW.UpdateGw2ClassColors()
    if not setupDone then
        SetupGw2ClassColors()
    end
    local custom = GW.GW_CLASS_COLORS
    local colors = GW.private.Gw2ClassColor

    for classTag, db in next, colors do
        local color = custom[classTag]
        if color then
            if color.r ~= db.r or color.g ~= db.g or color.b ~= db.b then
                color.r, color.g, color.b = db.r, db.g, db.b
                db.colorStr = nil
            end
        end
    end
end