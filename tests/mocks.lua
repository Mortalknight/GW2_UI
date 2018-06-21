local _, GW = ...

gwMocks = {}

gwMocks.GetLFGCompletionReward = function(isScenario)
    if isScenario then
        return "Mock Scenario", 11, 1, "Scenario", 20000, 2, 50000, 3, 0, 0
    else
        local name, typeID, subtypeID, _ = GetLFGDungeonInfo(1318) -- Court of Stars heroic
        return name, typeID, subtypeID, "Interface\\LFGFrame\\LFGIcon-CourtofStars", 20000, 2, 50000, 3, 3, 2
    end
end

gwMocks.GetLFGCompletionRewardItem = function(i)
    if i < 2 then
        local _, _, texturePath, _ = GetCurrencyInfo(1166) -- timewarped badge
        return texturePath, 5, false, nil
    else
        local _, _, texturePath, _ = GetCurrencyInfo(1220) -- order resources
        return texturePath, 500, false, nil
    end
end

gwMocks.GetLFGCompletionRewardItemLink = function(i)
    if i < 2 then
        return GetCurrencyLink(1166) -- timewarped badge
    else
        return GetCurrencyLink(1220) -- order resources
    end
end

-- Interface/FrameXML/AlertFrames.lua
gwMocks.BuildLFGRewardData = function()
    local rewardData = {}

    local name,
        typeID,
        subtypeID,
        iconTextureFile,
        moneyBase,
        moneyVar,
        experienceBase,
        experienceVar,
        numStrangers,
        numRewards = gwMocks.GetLFGCompletionReward(false)

    rewardData.name = name
    rewardData.subtypeID = subtypeID
    rewardData.iconTextureFile = iconTextureFile
    rewardData.moneyBase = moneyBase
    rewardData.moneyVar = moneyVar
    rewardData.experienceBase = experienceBase
    rewardData.experienceVar = experienceVar
    rewardData.numStrangers = numStrangers
    rewardData.numRewards = numRewards

    rewardData.moneyAmount = moneyBase + moneyVar * numStrangers
    rewardData.experienceGained = experienceBase + experienceVar * numStrangers

    if numRewards > 0 then
        rewardData.rewards = {}
        local rewards = rewardData.rewards

        for i = 1, numRewards do
            local texturePath, quantity, isBonus, bonusQuantity = gwMocks.GetLFGCompletionRewardItem(i)
            local rewardItemLink = gwMocks.GetLFGCompletionRewardItemLink(i)
            rewards[#rewards + 1] = {
                texturePath = texturePath,
                quantity = quantity,
                isBonus = isBonus,
                bonusQuantity = bonusQuantity,
                rewardItemLink = rewardItemLink,
                rewardID = i
            }
        end
    end

    return rewardData
end

-- Interface/AddOns/Blizzard_TalkingHeadUI/Blizzard_TalkingHeadUI.lua
gwMocks.TalkingHeadFrame_PlayCurrent = function()
    local frame = TalkingHeadFrame
    local model = frame.MainFrame.Model

    if frame.finishTimer then
        frame.finishTimer:Cancel()
        frame.finishTimer = nil
    end
    if frame.voHandle then
        StopSound(frame.voHandle)
        frame.voHandle = nil
    end

    local currentDisplayInfo = model:GetDisplayInfo()
    local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead =
        gwMocks.GetCurrentLineInfo()
    local textFormatted = string.format(text)
    if displayInfo and displayInfo ~= 0 then
        frame:Show()
        if currentDisplayInfo ~= displayInfo then
            model.uiCameraID = cameraID
            model:SetDisplayInfo(displayInfo)
        else
            if model.uiCameraID ~= cameraID then
                model.uiCameraID = cameraID
                Model_ApplyUICamera(model, model.uiCameraID)
            end
            gwMocks.TalkingHeadFrame_SetupAnimations(model)
        end

        if isNewTalkingHead then
            TalkingHeadFrame_Reset(frame, textFormatted, name)
            TalkingHeadFrame_FadeinFrames()
        else
            if name ~= frame.NameFrame.Name:GetText() then
                -- Fade out the old name and fade in the new name
                frame.NameFrame.Fadeout:Play()
                C_Timer.After(
                    0.25,
                    function()
                        frame.NameFrame.Name:SetText(name)
                    end
                )
                C_Timer.After(
                    0.5,
                    function()
                        frame.NameFrame.Fadein:Play()
                    end
                )

                frame.MainFrame.TalkingHeadsInAnim:Play()
            end

            if textFormatted ~= frame.TextFrame.Text:GetText() then
                -- Fade out the old text and fade in the new text
                frame.TextFrame.Fadeout:Play()
                C_Timer.After(
                    0.25,
                    function()
                        frame.TextFrame.Text:SetText(textFormatted)
                    end
                )
                C_Timer.After(
                    0.5,
                    function()
                        frame.TextFrame.Fadein:Play()
                    end
                )
            end
        end

        local success, voHandle = PlaySound(vo, "Talking Head", true, true)
        if success then
            frame.voHandle = voHandle
        end
    end
end

gwMocks.TalkingHeadFrame_SetupAnimations = function(self)
    local animKit, animIntro, animLoop, lineDuration = gwMocks.GetCurrentLineAnimationInfo()
    if animKit == nil then
        return
    end
    if animKit ~= self.animKit then
        self:StopAnimKit()
    end

    if animKit > 0 then
        -- If intro is 0 (stand) we are assuming that is no-op and skipping to loop.
        self.animKit = animKit
    elseif animIntro > 0 then
        self.animIntro = animIntro
        self.animLoop = animLoop
    else
        self.animLoop = animLoop
    end

    if (self.animKit) then
        self:PlayAnimKit(self.animKit, true)
        self:SetScript("OnAnimFinished", nil)
        self.shouldLoop = false
    elseif (self.animIntro) then
        self:SetAnimation(self.animIntro, 0)
        self.shouldLoop = true
        self:SetScript("OnAnimFinished", TalkingHeadFrame_IdleAnim)
    else
        self:SetAnimation(self.animLoop, 0)
        self.shouldLoop = true
        self:SetScript("OnAnimFinished", TalkingHeadFrame_IdleAnim)
    end

    self.lineAnimDone = false
    if lineDuration and self.shouldLoop then
        if lineDuration > 1.5 then
            C_Timer.After(
                lineDuration - 1.5,
                function()
                    self.shouldLoop = false
                end
            )
        end
    end
end

gwMocks.TalkingHeadFrame_OnModelLoaded = function(self)
    self:RefreshCamera()
    if self.uiCameraID then
        Model_ApplyUICamera(self, self.uiCameraID)
    end

    gwMocks.TalkingHeadFrame_SetupAnimations(self)
end

gwMocks.GetCurrentLineInfo = function()
    -- thalyssra line from "Left for Dead" WQ)
    return 65100, 576, 70918, 7.6910004615784, 0, 1, "First Arcanist Thalyssra", "Exiled Nightborne are being held captive by the Legion. Set them free before they meet a terrible fate!", true
end

gwMocks.GetCurrentLineAnimationInfo = function()
    -- thalyssra line from "Left for Dead" WQ)
    return 0, 60, 60, 7.6910004615784
end

gwMocks.GetLootRollItemInfo = function(rollID)
    local itemName,
        itemLink,
        itemRarity,
        itemLevel,
        itemMinLevel,
        itemType,
        itemSubType,
        itemStackCount,
        itemEquipLoc,
        itemTexture,
        itemSellPrice = GetItemInfo(18832)
    -- return itemTexture, itemName, 1, itemRarity, true, true, true, true, 0, 0, 1, true
    return itemTexture, itemName, 1, itemRarity, false, false, false, false, 1, 1, 1, true
end

gwMocks.GetLootRollTimeLeft = function(rollID)
    if rollID then
        return rollID - GetTime()
    else
        return 0
    end
end

-- Interface/FrameXML/LootFrame.lua
gwMocks.GroupLootFrame_OnShow = function(self)
    local texture,
        name,
        count,
        quality,
        bindOnPickUp,
        canNeed,
        canGreed,
        canDisenchant,
        reasonNeed,
        reasonGreed,
        reasonDisenchant,
        deSkillRequired = gwMocks.GetLootRollItemInfo(self.rollID)
    if (name == nil) then
        GroupLootContainer_RemoveFrame(GroupLootContainer, self)
        return
    end

    self.IconFrame.Icon:SetTexture(texture)
    self.IconFrame.Border:SetAtlas(LOOT_BORDER_BY_QUALITY[quality] or LOOT_BORDER_BY_QUALITY[LE_ITEM_QUALITY_UNCOMMON])
    self.Name:SetText(name)
    local color = ITEM_QUALITY_COLORS[quality]
    self.Name:SetVertexColor(color.r, color.g, color.b)
    self.Border:SetVertexColor(color.r, color.g, color.b)
    if (count > 1) then
        self.IconFrame.Count:SetText(count)
        self.IconFrame.Count:Show()
    else
        self.IconFrame.Count:Hide()
    end

    if (canNeed) then
        GroupLootFrame_EnableLootButton(self.NeedButton)
        self.NeedButton.reason = nil
    else
        GroupLootFrame_DisableLootButton(self.NeedButton)
        self.NeedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonNeed]
    end
    if (canGreed) then
        GroupLootFrame_EnableLootButton(self.GreedButton)
        self.GreedButton.reason = nil
    else
        GroupLootFrame_DisableLootButton(self.GreedButton)
        self.GreedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonGreed]
    end
    if (canDisenchant) then
        GroupLootFrame_EnableLootButton(self.DisenchantButton)
        self.DisenchantButton.reason = nil
    else
        GroupLootFrame_DisableLootButton(self.DisenchantButton)
        self.DisenchantButton.reason = format(_G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonDisenchant], deSkillRequired)
    end
    self.Timer:SetFrameLevel(self:GetFrameLevel() - 1)
end

gwMocks.GroupLootFrame_OnUpdate = function(self, elapsed)
    local left = gwMocks.GetLootRollTimeLeft(self:GetParent().rollID)
    local min, max = self:GetMinMaxValues()
    if ((left < min) or (left > max)) then
        left = min
    end
    self:SetValue(left)
end
