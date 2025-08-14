---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.LootSpec : AceModule, AceEvent-3.0
local LootSpec = LibCS:NewModule('LootSpec', 'AceEvent-3.0')
LibCS.LootSpec = LootSpec

local isInitialized = false
local config = {}
local lootSpecButtons = {}

function LootSpec:OnInitialize()
    config = LibCS.Database:GetModuleConfig('lootspec')
end

function LootSpec:GetSetting(key, defaultValue)
    return LibCS.Database:GetModuleSetting('lootspec', key, defaultValue)
end

function LootSpec:OnEnable()
    if not self:GetSetting('enabled', true) then
        return
    end
    
    if not isInitialized then
        self:CreateLootSpecButtons()
        isInitialized = true
    end
    
    self:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
end

function LootSpec:OnDisable()
    self:UnregisterAllEvents()
    self:RemoveLootSpecButtons()
end

function LootSpec:CreateLootSpecButtons()
    if not CharacterFrame or not CharacterFrame:IsVisible() then
        return
    end
    
    local specIndex = GetLootSpecialization() or 0
    local aid, aname, _, aicon = GetSpecializationInfo(GetSpecialization())
    
    if not aid then
        return -- No active specialization
    end
    
    local buttonSize = self:GetSetting('buttonSize', 32)
    local buttonSpacing = self:GetSetting('buttonSpacing', 2)
    local startX = self:GetSetting('startX', 10)
    local startY = self:GetSetting('startY', 10)
    
    -- Create header text
    if not self.headerText then
        self.headerText = CharacterFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        self.headerText:SetPoint('BOTTOMLEFT', CharacterFrame, 'BOTTOMLEFT', startX, startY + 40)
        self.headerText:SetText(SELECT_LOOT_SPECIALIZATION)
        self.headerText:SetTextColor(1, 0.82, 0) -- Gold color
    end
    
    -- Create buttons for each available specialization (0-4, 0 = current spec)
    for count = 0, 4 do
        local id, name, _, icon = GetSpecializationInfo(count)
        local xOffset = startX + (buttonSize + buttonSpacing) * count
        local yOffset = startY
        
        if count == 0 then
            -- Special case for "Current Specialization" option
            name = string.format(LOOT_SPECIALIZATION_DEFAULT, aname or '*')
            id = aid
            icon = aicon
        end
        
        if id then
            local button = self:CreateLootSpecButton(count, id, name, icon, xOffset, yOffset, buttonSize)
            lootSpecButtons[count] = button
        end
    end
    
    self:UpdateButtonStates()
end

---@param count number
---@param specID number
---@param specName string
---@param specIcon string
---@param xOffset number
---@param yOffset number
---@param buttonSize number
---@return Button
function LootSpec:CreateLootSpecButton(count, specID, specName, specIcon, xOffset, yOffset, buttonSize)
    local buttonName = 'LibCS_LootSpecButton' .. count
    local button = _G[buttonName] or CreateFrame('Button', buttonName, CharacterFrame, 'UIPanelButtonTemplate')
    
    button:SetSize(buttonSize, buttonSize)
    button:SetPoint('BOTTOMLEFT', CharacterFrame, 'BOTTOMLEFT', xOffset, yOffset)
    button:SetNormalTexture(specIcon)
    button:SetFrameStrata('HIGH')
    
    -- Store data on button
    button.specID = specID
    button.specIndex = count
    button.specName = specName
    
    -- Create selection indicator for current spec
    if not button.selectionRing then
        button.selectionRing = button:CreateTexture(nil, 'OVERLAY')
        button.selectionRing:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\ItemBorder')
        button.selectionRing:SetSize(buttonSize * 1.2, buttonSize * 1.2)
        button.selectionRing:SetPoint('CENTER')
        button.selectionRing:SetVertexColor(1, 1, 0) -- Yellow for selected
        button.selectionRing:Hide()
    end
    
    -- Add special marker for default/current spec (count == 0)
    if count == 0 and not button.defaultMarker then
        button.defaultMarker = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        button.defaultMarker:SetPoint('CENTER', button, 'CENTER', 0, 0)
        button.defaultMarker:SetText('**')
        button.defaultMarker:SetTextColor(1, 1, 1)
    end
    
    -- Click handler
    button:SetScript('OnClick', function(self)
        LootSpec:SetLootSpecialization(self.specIndex)
    end)
    
    -- Tooltip
    button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(self.specName, 1, 1, 1)
        if self.specIndex == 0 then
            GameTooltip:AddLine('Use current specialization for loot', 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine('Set loot specialization to this spec', 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    
    button:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    
    button:Show()
    return button
end

---@param specIndex number
function LootSpec:SetLootSpecialization(specIndex)
    if specIndex == 0 then
        SetLootSpecialization(0) -- Use current spec
    else
        local specID = GetSpecializationInfo(specIndex)
        if specID then
            SetLootSpecialization(specID)
        end
    end
    
    -- Update button states after change
    C_Timer.After(0.1, function()
        self:UpdateButtonStates()
    end)
    
    -- Show notification
    if LibCS.Notifications then
        local specName = specIndex == 0 and 'Current Specialization' or select(2, GetSpecializationInfo(specIndex))
        LibCS.Notifications:ShowToast('Loot Specialization', 'Changed to: ' .. (specName or 'Unknown'))
    end
end

function LootSpec:UpdateButtonStates()
    local currentLootSpec = GetLootSpecialization()
    
    for count, button in pairs(lootSpecButtons) do
        if button and button.selectionRing then
            local isSelected = false
            
            if count == 0 and currentLootSpec == 0 then
                -- Default/current spec is selected
                isSelected = true
            elseif count > 0 then
                local specID = GetSpecializationInfo(count)
                if specID and specID == currentLootSpec then
                    isSelected = true
                end
            end
            
            if isSelected then
                button.selectionRing:Show()
            else
                button.selectionRing:Hide()
            end
        end
    end
end

function LootSpec:RemoveLootSpecButtons()
    for count, button in pairs(lootSpecButtons) do
        if button then
            button:Hide()
            button:SetParent(nil)
        end
    end
    lootSpecButtons = {}
    
    if self.headerText then
        self.headerText:Hide()
        self.headerText = nil
    end
end

function LootSpec:PLAYER_LOOT_SPEC_UPDATED()
    self:UpdateButtonStates()
end

function LootSpec:PLAYER_SPECIALIZATION_CHANGED()
    -- Recreate buttons when specialization changes
    self:RemoveLootSpecButtons()
    C_Timer.After(0.5, function()
        self:CreateLootSpecButtons()
    end)
end

-- Utility function to check if loot spec feature should be shown
---@return boolean
function LootSpec:ShouldShowLootSpec()
    return UnitLevel('player') >= 15 and GetSpecialization() ~= nil
end