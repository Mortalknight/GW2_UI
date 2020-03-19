local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinQueueStatusFrame()
    local QueueStatusFrame = _G.QueueStatusFrame

    QueueStatusFrame:SetBackdrop(nil)
    QueueStatusFrame.BorderTopLeft:Hide()
    QueueStatusFrame.BorderTopRight:Hide()
    QueueStatusFrame.BorderBottomRight:Hide()
    QueueStatusFrame.BorderBottomLeft:Hide()
    QueueStatusFrame.BorderTop:Hide()
    QueueStatusFrame.BorderRight:Hide()
    QueueStatusFrame.BorderBottom:Hide()
    QueueStatusFrame.BorderLeft:Hide()
    QueueStatusFrame.Background:Hide()
    QueueStatusFrame:SetBackdrop(constBackdropFrame)
end
GW.SkinQueueStatusFrame = SkinQueueStatusFrame