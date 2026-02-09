---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Equipment : AceModule, AceEvent-3.0
local Equipment = LibCS:NewModule('Equipment', 'AceEvent-3.0')
LibCS.Equipment = Equipment

local isInitialized = false
local config = {}
local enhancedSlots = {}

-- WoW Standard Equipment Slot IDs
-- These are the inventory slot IDs used by GetInventorySlotInfo() and equipment APIs
-- The slot name strings must match what GetInventorySlotInfo() expects
---@type table<number, string>
local slotNames = {
	[1] = 'HEADSLOT',
	[2] = 'NECKSLOT',
	[3] = 'SHOULDERSLOT',
	[4] = 'SHIRTSLOT',
	[5] = 'CHESTSLOT',
	[6] = 'WAISTSLOT',
	[7] = 'LEGSSLOT',
	[8] = 'FEETSLOT',
	[9] = 'WRISTSLOT',
	[10] = 'HANDSSLOT',
	[11] = 'FINGER0SLOT',
	[12] = 'FINGER1SLOT',
	[13] = 'TRINKET0SLOT',
	[14] = 'TRINKET1SLOT',
	[15] = 'BACKSLOT',
	[16] = 'MAINHANDSLOT',
	[17] = 'SECONDARYHANDSLOT',
	[18] = 'RANGEDSLOT',
	[19] = 'TABARDSLOT',
}

function Equipment:OnInitialize()
	config = LibCS.Database:GetModuleConfig('equipment')
end

function Equipment:GetSetting(key, defaultValue)
	return LibCS.Database:GetModuleSetting('equipment', key, defaultValue)
end

---@param slotName string
---@return number?
function Equipment:GetSlotIDFromName(slotName)
	for slotID, name in pairs(slotNames) do
		if name == slotName then
			return slotID
		end
	end
	return nil
end

function Equipment:OnEnable()
	LibCS.Logger.info('Equipment: OnEnable called')

	if not isInitialized then
		self:EnhanceExistingSlots()
		isInitialized = true

		LibCS.Logger.info('Equipment: Created ' .. self:GetSlotCount() .. ' custom slots')

		-- Trigger FrameManager to reposition slots now that we've created them
		C_Timer.After(0.1, function()
			if LibCS.FrameManager and LibCS.FrameManager.RepositionSlots then
				LibCS.Logger.info('Equipment: Triggering RepositionSlots')
				LibCS.FrameManager:RepositionSlots()
			end
			-- Update all slot visuals
			self:UpdateEquipmentVisuals()
		end)
	end

	self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
	self:RegisterEvent('BAG_UPDATE')
end

---@return number
function Equipment:GetSlotCount()
	local count = 0
	for slotID = 1, 19 do
		if enhancedSlots[slotID] then
			count = count + 1
		end
	end
	return count
end

function Equipment:OnDisable()
	self:UnregisterAllEvents()
	self:RestoreOriginalSlots()
end

function Equipment:EnhanceExistingSlots()
	-- Create custom slots for all equipment positions
	-- We don't need the original slots - just create our own
	for slotID = 1, 19 do
		local slotName = slotNames[slotID]
		if slotName then
			-- Skip ranged slot (18) as it doesn't exist in modern WoW
			if slotID ~= 18 then
				self:CreateCustomSlot(slotID, nil)
			end
		end
	end
end

---@param slotID number
---@return Frame?
function Equipment:GetSlotFrame(slotID)
	local slotName = slotNames[slotID]
	if not slotName then
		return nil
	end

	local frameName = 'Character' .. slotName:gsub('SLOT', '') .. 'Slot'
	return _G[frameName]
end

---@param slotFrame Frame
---@param slotID number
function Equipment:EnhanceSlot(slotFrame, slotID)
	if not slotFrame or enhancedSlots[slotID] then
		return
	end

	self:ApplyCircularMask(slotFrame)
	self:EnhanceTooltips(slotFrame, slotID)
	self:AddItemHighlight(slotFrame)

	enhancedSlots[slotID] = true
end

---@param slotID number
---@param originalSlot Frame?
function Equipment:CreateCustomSlot(slotID, originalSlot)
	if enhancedSlots[slotID] then
		return
	end

	local slotName = slotNames[slotID]
	if not slotName then
		return
	end

	local size = self:GetSetting('slotSize', 40)
	local frameName = 'LibCS_CustomSlot' .. slotID

	-- Create simple slot button
	local button = CreateFrame('Button', frameName, CharacterFrame)
	button:SetSize(size, size)
	button:RegisterForDrag('LeftButton')
	button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

	local slotInfo, textureName = GetInventorySlotInfo(slotName)
	button.slotID = slotID
	button.emptyTexture = textureName

	-- Simple icon (no circular mask for now - keeping it simple)
	button.ItemIcon = button:CreateTexture(nil, 'ARTWORK')
	button.ItemIcon:SetPoint('TOPLEFT', 2, -2)
	button.ItemIcon:SetPoint('BOTTOMRIGHT', -2, 2)
	button.ItemIcon:SetTexture(textureName)
	button.ItemIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	-- Simple border using textures
	button.BorderTop = button:CreateTexture(nil, 'OVERLAY')
	button.BorderTop:SetColorTexture(0.4, 0.4, 0.4, 1)
	button.BorderTop:SetPoint('TOPLEFT', 0, 0)
	button.BorderTop:SetPoint('TOPRIGHT', 0, 0)
	button.BorderTop:SetHeight(1)

	button.BorderBottom = button:CreateTexture(nil, 'OVERLAY')
	button.BorderBottom:SetColorTexture(0.4, 0.4, 0.4, 1)
	button.BorderBottom:SetPoint('BOTTOMLEFT', 0, 0)
	button.BorderBottom:SetPoint('BOTTOMRIGHT', 0, 0)
	button.BorderBottom:SetHeight(1)

	button.BorderLeft = button:CreateTexture(nil, 'OVERLAY')
	button.BorderLeft:SetColorTexture(0.4, 0.4, 0.4, 1)
	button.BorderLeft:SetPoint('TOPLEFT', 0, 0)
	button.BorderLeft:SetPoint('BOTTOMLEFT', 0, 0)
	button.BorderLeft:SetWidth(1)

	button.BorderRight = button:CreateTexture(nil, 'OVERLAY')
	button.BorderRight:SetColorTexture(0.4, 0.4, 0.4, 1)
	button.BorderRight:SetPoint('TOPRIGHT', 0, 0)
	button.BorderRight:SetPoint('BOTTOMRIGHT', 0, 0)
	button.BorderRight:SetWidth(1)

	-- Event handlers
	button:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetInventoryItem('player', self.slotID)
		GameTooltip:Show()
	end)

	button:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)

	button:SetScript('OnClick', function(self, mouseButton)
		if mouseButton == 'LeftButton' then
			PickupInventoryItem(self.slotID)
		elseif mouseButton == 'RightButton' then
			UseInventoryItem(self.slotID)
		end
	end)

	button:SetScript('OnDragStart', function(self)
		PickupInventoryItem(self.slotID)
	end)

	button:SetScript('OnReceiveDrag', function(self)
		PickupInventoryItem(self.slotID)
	end)

	-- Store the custom button
	enhancedSlots[slotID] = button

	-- Update the item icon
	self:UpdateSlotAppearance(button, slotID)

	LibCS.Logger.debug('Equipment: Created slot ' .. slotID .. ' (' .. slotName .. ')')
end

---@param slotFrame Frame
function Equipment:ApplyCircularMask(slotFrame)
	if not self:GetSetting('useCircularMask', true) then
		return
	end

	-- Find the icon texture within the slot frame
	local iconTexture = slotFrame.icon or slotFrame.Icon or slotFrame.IconBorder
	if not iconTexture then
		-- Try to find it among the regions
		for i = 1, slotFrame:GetNumRegions() do
			local region = select(i, slotFrame:GetRegions())
			if region and region:GetObjectType() == 'Texture' and region:GetTexture() then
				iconTexture = region
				break
			end
		end
	end

	if not iconTexture then
		return
	end

	-- Apply circular mask
	if not slotFrame.LibCS_CircleMask then
		slotFrame.LibCS_CircleMask = slotFrame:CreateMaskTexture()
		slotFrame.LibCS_CircleMask:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\masks\\Circle.tga', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		slotFrame.LibCS_CircleMask:SetAllPoints(iconTexture)
		iconTexture:AddMaskTexture(slotFrame.LibCS_CircleMask)
	end
end

---@param slotFrame Frame
---@param slotID number
function Equipment:EnhanceTooltips(slotFrame, slotID)
	if not self:GetSetting('showTooltips', true) or not slotFrame.UpdateTooltip then
		return
	end

	local originalUpdateTooltip = slotFrame.UpdateTooltip
	slotFrame.UpdateTooltip = function(self)
		if originalUpdateTooltip then
			originalUpdateTooltip(self)
		end

		Equipment:AddCustomTooltipInfo(self, slotID)
	end
end

---@param slotFrame Frame
---@param slotID number
function Equipment:AddCustomTooltipInfo(slotFrame, slotID)
	if not GameTooltip:IsShown() then
		return
	end

	local itemID = GetInventoryItemID('player', slotID)
	if not itemID then
		return
	end

	local itemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slotID))
	if itemLevel and itemLevel > 0 then
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine('Item Level:', itemLevel, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end

	local durabilityInfo = self:GetDurabilityInfo(slotID)
	if durabilityInfo then
		GameTooltip:AddDoubleLine('Durability:', durabilityInfo, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b)
	end

	GameTooltip:Show()
end

---@param slotID number
---@return string?
function Equipment:GetDurabilityInfo(slotID)
	local current, max = GetInventoryItemDurability(slotID)
	if current and max and max > 0 then
		local percentage = math.floor((current / max) * 100)
		return string.format('%d/%d (%d%%)', current, max, percentage)
	end
	return nil
end

---@param slotFrame Frame
function Equipment:AddItemHighlight(slotFrame)
	if not self:GetSetting('showHighlight', true) then
		return
	end

	if not slotFrame.LibCS_Highlight then
		slotFrame.LibCS_Highlight = slotFrame:CreateTexture(nil, 'OVERLAY')
		slotFrame.LibCS_Highlight:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\ItemBorderInnerHighlight')
		slotFrame.LibCS_Highlight:SetSize(slotFrame:GetSize())
		slotFrame.LibCS_Highlight:SetPoint('CENTER')
		slotFrame.LibCS_Highlight:SetBlendMode('ADD')
		slotFrame.LibCS_Highlight:SetAlpha(0)
	end

	if not slotFrame.LibCS_HooksSet then
		slotFrame:HookScript('OnEnter', function(self)
			if self.LibCS_Highlight then
				self.LibCS_Highlight:SetAlpha(1)
			end
		end)

		slotFrame:HookScript('OnLeave', function(self)
			if self.LibCS_Highlight then
				self.LibCS_Highlight:SetAlpha(0)
			end
		end)

		slotFrame.LibCS_HooksSet = true
	end
end

function Equipment:RestoreOriginalSlots()
	-- Hide custom slots and show original ones
	for slotID = 1, 19 do
		if enhancedSlots[slotID] then
			-- Hide and remove custom slot
			if type(enhancedSlots[slotID]) == 'table' and enhancedSlots[slotID].Hide then
				enhancedSlots[slotID]:Hide()
				enhancedSlots[slotID]:SetParent(nil)
			end

			-- Show original slot
			local originalSlot = self:GetSlotFrame(slotID)
			if originalSlot then
				originalSlot:Show()
			end
		end
	end

	enhancedSlots = {}
end

---@param slotFrame Frame
---@param slotID number
function Equipment:RestoreSlot(slotFrame, slotID)
	-- Remove circular mask
	if slotFrame.LibCS_CircleMask then
		local iconTexture = slotFrame.icon or slotFrame.Icon or slotFrame.IconBorder
		if not iconTexture then
			-- Try to find it among the regions
			for i = 1, slotFrame:GetNumRegions() do
				local region = select(i, slotFrame:GetRegions())
				if region and region:GetObjectType() == 'Texture' and region:GetTexture() then
					iconTexture = region
					break
				end
			end
		end

		if iconTexture then
			iconTexture:RemoveMaskTexture(slotFrame.LibCS_CircleMask)
		end
		slotFrame.LibCS_CircleMask = nil
	end

	-- Remove old mask if it exists
	if slotFrame.LibCS_IconMask then
		local iconTexture = slotFrame.icon or slotFrame.IconBorder
		if iconTexture then
			iconTexture:RemoveMaskTexture(slotFrame.LibCS_IconMask)
		end
		slotFrame.LibCS_IconMask = nil
	end

	if slotFrame.LibCS_Highlight then
		slotFrame.LibCS_Highlight:Hide()
		slotFrame.LibCS_Highlight = nil
	end
end

function Equipment:UpdateEquipmentVisuals()
	for slotID = 1, 19 do
		local customSlot = enhancedSlots[slotID]
		if customSlot and type(customSlot) == 'table' then
			self:UpdateSlotAppearance(customSlot, slotID)
		end
	end
end

---@param slotButton Frame
---@param slotID number
function Equipment:UpdateSlotAppearance(slotButton, slotID)
	local itemID = GetInventoryItemID('player', slotID)

	if itemID and slotButton.ItemIcon then
		local itemTexture = C_Item.GetItemIconByID(itemID)
		if itemTexture then
			slotButton.ItemIcon:SetTexture(itemTexture)
			slotButton.ItemIcon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
		end
	elseif slotButton.ItemIcon and slotButton.emptyTexture then
		-- Show empty slot texture
		slotButton.ItemIcon:SetTexture(slotButton.emptyTexture)
		slotButton.ItemIcon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
	end
end

---@param event string
---@param slotID number
function Equipment:PLAYER_EQUIPMENT_CHANGED(event, slotID)
	-- Update our custom slot, not the original Blizzard slot
	local customSlot = enhancedSlots[slotID]
	if customSlot and type(customSlot) == 'table' then
		self:UpdateSlotAppearance(customSlot, slotID)
	end
end

---@param event string
---@param bagID number
function Equipment:BAG_UPDATE(event, bagID)
	C_Timer.After(0.1, function()
		self:UpdateEquipmentVisuals()
	end)
end

---@param buttonSize number
function Equipment:SetButtonSize(buttonSize)
	LibCS.Database:SetModuleSetting('equipment', 'buttonSize', buttonSize)

	for slotID = 1, 19 do
		local slotFrame = self:GetSlotFrame(slotID)
		if slotFrame and enhancedSlots[slotID] then
			slotFrame:SetSize(buttonSize, buttonSize)

			if slotFrame.LibCS_Highlight then
				slotFrame.LibCS_Highlight:SetSize(buttonSize * 1.31, buttonSize * 1.31)
			end
		end
	end
end

---@return table<number, Frame>
function Equipment:GetEnhancedSlots()
	local slots = {}
	for slotID = 1, 19 do
		if enhancedSlots[slotID] then
			slots[slotID] = enhancedSlots[slotID]
		end
	end
	return slots
end
