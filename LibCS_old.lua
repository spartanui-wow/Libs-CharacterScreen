---@diagnostic disable
---@class LibCS : AceAddon, AceConsole-3.0, AceEvent-3.0
local LibCS = LibStub('AceAddon-3.0'):NewAddon('LibCS', 'AceConsole-3.0', 'AceEvent-3.0')
LibCS:SetDefaultModuleLibraries('AceEvent-3.0', 'AceTimer-3.0')
_G.LibCS = LibCS

LibCS.Version = C_AddOns.GetAddOnMetadata('Libs-CharacterScreen', 'Version') or '0.0.0'
LibCS.BuildNum = C_AddOns.GetAddOnMetadata('Libs-CharacterScreen', 'X-Build') or 0

local function Strip()
	if InCombatLockdown() then
		return
	end

	CharacterFrame:SetHeight(479 + (7 * LibCS.DB.padding.v)) -- Do not allow the frame to get any smaller than the default bliz frame
	local Bgoffset = 17 + LibCS.DB.padding.h

	CharacterFrame.Inset:Hide()
	CharacterFrame.NineSlice:Hide()
	CharacterFramePortrait:Hide()
	CharacterFrameInsetRight.Bg:Hide()

	CharacterFrameBg:SetVertexColor(0, 0, 0, 0)
	CharacterFrameBg:ClearAllPoints()
	CharacterFrameBg:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', 0, 0)
	CharacterFrameBg:SetPoint('BOTTOMRIGHT', CharacterFrame, 'BOTTOMRIGHT', LibCS.DB.offset, 0) --275  .449

	CharacterFrame.TopTileStreaks:Hide()
	TokenFramePopup:SetFrameStrata('HIGH')
	ReputationFrame:SetFrameStrata('HIGH')

	local charbg = _G['CharacterFrameBgbg'] or CreateFrame('Frame', 'CharacterFrameBgbg', CharacterFrame)
	local charbgtex = _G['CharacterFrameBgbgtex'] or charbg:CreateTexture('CharacterFrameBgbgtex', 'BACKGROUND', nil, 1)
	local bgr, bgg, bgb, bgalpha = LibCS.DB.background.color[1], LibCS.DB.background.color[2], LibCS.DB.background.color[3], LibCS.DB.background.color[4]

	GearManagerPopupFrame:SetFrameStrata('DIALOG')
	GearManagerPopupFrame.IconSelector:SetFrameStrata('FULLSCREEN')

	charbg:ClearAllPoints()
	charbg:SetAllPoints(CharacterFrameBg)
	charbg:SetFrameStrata('BACKGROUND')
	charbgtex:ClearAllPoints()
	charbgtex:SetAllPoints()
	charbgtex:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
	charbgtex:SetVertexColor(bgr, bgg, bgb, bgalpha)
	CharacterFrameCloseButton:ClearAllPoints()
	CharacterFrameCloseButton:SetPoint('TOPRIGHT', CharacterFrameBg, 'TOPRIGHT', 5.6, 5)

	-- We need to scale the Name, title, and class text too
	CharacterFrameTitleText:ClearAllPoints()
	CharacterFrameTitleText:SetPoint('TOP', CharacterFrame, 'TOP', 0, 0)
	CharacterFrameTitleText:SetPoint('LEFT', CharacterFrame, 'LEFT', 50, 0)
	CharacterFrameTitleText:SetPoint('RIGHT', CharacterFrameInset, 'RIGHT', -40, 0)
	-- CharacterFrameTitleText:SetFont(Font, 12)

	CharacterLevelText:ClearAllPoints()
	CharacterLevelText:SetPoint('TOP', CharacterFrameTitleText, 'BOTTOM', 0, 0)

	-- CharacterLevelText:SetFont(Font, 11)

	CharacterFrameInsetRight:ClearAllPoints()
	CharacterFrameInsetRight:SetPoint('TOPLEFT', CharacterFrameInset, 'TOPRIGHT', 4, 0)
	CharacterFrameInsetRight:SetPoint('BOTTOMRIGHT', CharacterFrameInset, 'BOTTOMRIGHT', 200, 0)
	CharacterStatsPane.ClassBackground:Hide()

	PaperDollFrame:UnregisterAllEvents()
	PaperDollInnerBorderBottom:Hide()
	PaperDollInnerBorderBottom2:Hide()
	PaperDollInnerBorderBottomLeft:Hide()
	PaperDollInnerBorderBottomRight:Hide()
	PaperDollInnerBorderLeft:Hide()
	PaperDollInnerBorderRight:Hide()
	PaperDollInnerBorderTop:Hide()
	PaperDollInnerBorderTopLeft:Hide()
	PaperDollInnerBorderTopRight:Hide()
	CharacterFrameInsetRight.NineSlice:Hide()

	CharacterBackSlotFrame:Hide()
	CharacterChestSlotFrame:Hide()
	CharacterFeetSlotFrame:Hide()
	CharacterFinger0SlotFrame:Hide()
	CharacterFinger1SlotFrame:Hide()
	CharacterHandsSlotFrame:Hide()
	CharacterHeadSlotFrame:Hide()
	CharacterLegsSlotFrame:Hide()
	CharacterMainHandSlotFrame:Hide()
	CharacterNeckSlotFrame:Hide()
	CharacterSecondaryHandSlotFrame:Hide()
	CharacterShirtSlotFrame:Hide()
	CharacterShoulderSlotFrame:Hide()
	CharacterTabardSlotFrame:Hide()
	CharacterTrinket0SlotFrame:Hide()
	CharacterTrinket1SlotFrame:Hide()
	CharacterWaistSlotFrame:Hide()
	CharacterWristSlotFrame:Hide()
	-- All slots on the left (under head) are tied back to this slot
	CharacterHeadSlot:ClearAllPoints()
	CharacterHeadSlot:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPLEFT', 30, -60)
	-- Now we change the spacing of the slots on the left
	CharacterNeckSlot:ClearAllPoints()
	CharacterNeckSlot:SetPoint('TOPLEFT', CharacterHeadSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterShoulderSlot:ClearAllPoints()
	CharacterShoulderSlot:SetPoint('TOPLEFT', CharacterNeckSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterBackSlot:ClearAllPoints()
	CharacterBackSlot:SetPoint('TOPLEFT', CharacterShoulderSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterChestSlot:ClearAllPoints()
	CharacterChestSlot:SetPoint('TOPLEFT', CharacterBackSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterShirtSlot:ClearAllPoints()
	CharacterShirtSlot:SetPoint('TOPLEFT', CharacterChestSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterTabardSlot:ClearAllPoints()
	CharacterTabardSlot:SetPoint('TOPLEFT', CharacterShirtSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterWristSlot:ClearAllPoints()
	CharacterWristSlot:SetPoint('TOPLEFT', CharacterTabardSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)

	-- All slots on the right (under hands) are tied back to this slot
	CharacterHandsSlot:ClearAllPoints()
	CharacterHandsSlot:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPLEFT', 283 + LibCS.DB.padding.h, -60)
	-- Now we change the spacing of the slots on the right
	CharacterWaistSlot:ClearAllPoints()
	CharacterWaistSlot:SetPoint('TOPLEFT', CharacterHandsSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterLegsSlot:ClearAllPoints()
	CharacterLegsSlot:SetPoint('TOPLEFT', CharacterWaistSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterFeetSlot:ClearAllPoints()
	CharacterFeetSlot:SetPoint('TOPLEFT', CharacterLegsSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterFinger0Slot:ClearAllPoints()
	CharacterFinger0Slot:SetPoint('TOPLEFT', CharacterFeetSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterFinger1Slot:ClearAllPoints()
	CharacterFinger1Slot:SetPoint('TOPLEFT', CharacterFinger0Slot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterTrinket0Slot:ClearAllPoints()
	CharacterTrinket0Slot:SetPoint('TOPLEFT', CharacterFinger1Slot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
	CharacterTrinket1Slot:ClearAllPoints()
	CharacterTrinket1Slot:SetPoint('TOPLEFT', CharacterTrinket0Slot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)

	CharacterMainHandSlot:ClearAllPoints()
	CharacterMainHandSlot:SetPoint('BOTTOMLEFT', CharacterFrameBg, 'BOTTOMLEFT', 146 + 89 * LibCS.DB.padding.h / 262, 60)
	CharacterSecondaryHandSlot:ClearAllPoints()
	CharacterSecondaryHandSlot:SetPoint('TOPLEFT', CharacterMainHandSlot, 'TOPRIGHT', 60 * LibCS.DB.padding.h / 262, 0)
	select(16, CharacterMainHandSlot:GetRegions()):Hide()
	select(16, CharacterSecondaryHandSlot:GetRegions()):Hide()

	CharacterFrame:SetScale(LibCS.DB.scale)
	TokenFrame:SetScale(LibCS.DB.scale)
	ReputationFrame:SetScale(LibCS.DB.scale)

	if WeeklyRewardExpirationWarningDialog then
		WeeklyRewardExpirationWarningDialog:Hide()
	end
end

local function CheckAddionalAddons()
	local AddonButtons = {}

	local function AddAddonButton(frame)
		-- Set the button's position to the left of CharacterFrameTab3 if the first, or to the right of the previous button
		frame:ClearAllPoints()
		local myAnchor = CharacterFrameTab3
		if #AddonButtons == 0 then
			frame:SetPoint('TOPLEFT', CharacterFrameTab3, 'TOPRIGHT', 0, 0)
		else
			frame:SetPoint('TOPLEFT', AddonButtons[#AddonButtons], 'TOPRIGHT', 0, 0)
			myAnchor = AddonButtons[#AddonButtons]
		end

		-- Keep the button from being moved
		hooksecurefunc(
			frame,
			'SetPoint',
			function(frame, _, anchor)
				if anchor ~= myAnchor then
					frame:ClearAllPoints()
					frame:SetPoint('TOPLEFT', myAnchor, 'TOPRIGHT', 0, 0)
				end
			end
		)

		-- Add the button to the list of buttons
		table.insert(AddonButtons, frame)
	end

	if C_AddOns.IsAddOnLoaded('Pawn') then
		PawnUI_InventoryPawnButton:Hide()
		AddAddonButton(PawnUI_InventoryPawnButton)
	end

	if C_AddOns.IsAddOnLoaded('Narcissus') then
		NarciCharacterFrameDominationIndicator:ClearAllPoints()
		NarciCharacterFrameDominationIndicator:SetPoint('CENTER', CharacterFrameBg, 'TOPRIGHT', -1, -45)
		NarciCharacterFrameClassSetIndicator:ClearAllPoints()
		NarciCharacterFrameClassSetIndicator:SetPoint('CENTER', CharacterFrameBg, 'TOPRIGHT', -1, -45)

		if NarciGemManagerPaperdollWidget then
			NarciGemManagerPaperdollWidget:SetScale(0.7)
			AddAddonButton(NarciGemManagerPaperdollWidget)
		end
	end

	if C_AddOns.IsAddOnLoaded('Simulationcraft') then
		-- Create a button to open the Simulationcraft UI, with the Interface\\AddOns\\SimulationCraft\\logo texture
		local SimcButton = CreateFrame('Button', 'LibCS_SimcButton', CharacterFrame, 'UIPanelButtonTemplate')
		SimcButton:SetText('SimC')
		SimcButton:SetSize(50, 22)
		SimcButton:SetScript(
			'OnClick',
			function()
				local Simulationcraft = LibStub('AceAddon-3.0'):GetAddon('Simulationcraft')
				Simulationcraft:PrintSimcProfile(false, false, false)
			end
		)
		AddAddonButton(SimcButton)
	end
end

---@param parent Frame
---@param slotName InventorySlotName
---@param size number
---@return LibCS.GearFrame.Button
local function CreateGearButton(parent, slotName, size)
	---@class LibCS.GearFrame.Button : Button
	local button = CreateFrame('Button', nil, parent)
	button:SetSize(size, size)
	button:RegisterForDrag('LeftButton')
	button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

	local slotID, textureName = GetInventorySlotInfo(slotName)
	button.slotID = slotID
	button.emptyTexture = textureName

	local iconSize = size * 0.85 -- 85% of button size
	local borderSize = size * 2.62 -- 262% of button size (maintains proportion)
	local highlightSize = size * 1.31 -- 131% of button size

	-- Main Icon
	button.ItemIcon = button:CreateTexture(nil, 'ARTWORK')
	button.ItemIcon:SetSize(iconSize, iconSize)
	button.ItemIcon:SetPoint('CENTER')
	button.ItemIcon:SetTexture(textureName)
	button.ItemIcon:SetTexCoord(0.075, 0.925, 0.075, 0.925)

	-- Icon Mask
	button.IconMask = button:CreateMaskTexture()
	button.IconMask:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\masks\\Circle', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	button.IconMask:SetAllPoints(button.ItemIcon)
	button.ItemIcon:AddMaskTexture(button.IconMask)

	-- Border
	button.Border = button:CreateTexture(nil, 'BORDER')
	button.Border:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\ItemBorder')
	button.Border:SetSize(borderSize, borderSize)
	button.Border:SetPoint('CENTER')
	button.Border:SetTexCoord(0, 0.5, 0, 1)

	-- auctionhouse-itemicon-border-blue

	-- Inner Highlight
	button.InnerHighlight = button:CreateTexture(nil, 'OVERLAY')
	button.InnerHighlight:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\ItemBorderInnerHighlight')
	button.InnerHighlight:SetSize(highlightSize, highlightSize)
	button.InnerHighlight:SetPoint('CENTER')
	button.InnerHighlight:SetBlendMode('ADD')
	button.InnerHighlight:SetAlpha(0)

	-- Scripts

	-- Scripts
	button:SetScript(
		'OnEnter',
		function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetInventoryItem('player', self.slotID)
			GameTooltip:Show()
			self.InnerHighlight:SetAlpha(1)
		end
	)

	button:SetScript(
		'OnLeave',
		function(self)
			GameTooltip:Hide()
			self.InnerHighlight:SetAlpha(0)
		end
	)

	button:SetScript(
		'OnEnter',
		function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_NONE')
			GameTooltip:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 2, 4)
			if (self.hyperlink) then
				GameTooltip:SetHyperlink(self.hyperlink)
				GameTooltip:Show()
			elseif self.localizedName then
				GameTooltip:SetText(self.localizedName)
				GameTooltip:Show()
			else
				GameTooltip:Hide()
			end
			self.InnerHighlight:SetAlpha(1)
		end
	)

	button:SetScript(
		'OnLeave',
		function(self)
			GameTooltip:Hide()
			self.InnerHighlight:SetAlpha(0)
		end
	)

	button:SetScript(
		'OnClick',
		function(self)
			-- Implement OnClick functionality
		end
	)

	button:SetScript(
		'OnMouseDown',
		function(self)
			-- Implement OnMouseDown functionality
		end
	)

	return button
end

---@param gearManager LibCS.GearFrame
---@param buttons table
---@param slotArrangement table
local function PositionGearButtons(gearManager, buttons, slotArrangement)
	local leftStart = 0
	local rightStart = 0
	local bottomStart = 10
	local verticalSpacing = 5
	local horizontalSpacing = 5

	-- Position left side buttons
	for i, slotName in ipairs(slotArrangement[1]) do
		local button = buttons[slotName]
		if button then
			button:SetPoint('TOPRIGHT', gearManager, 'TOPLEFT', leftStart, -((i - 1) * (button:GetHeight() + verticalSpacing)))
		end
	end

	-- Position right side buttons
	for i, slotName in ipairs(slotArrangement[2]) do
		local button = buttons[slotName]
		if button then
			button:SetPoint('TOPLEFT', gearManager, 'TOPRIGHT', rightStart, -((i - 1) * (button:GetHeight() + verticalSpacing)))
		end
	end

	-- Position bottom buttons
	if #slotArrangement[3] == 2 then
		local leftButton = buttons[slotArrangement[3][1]]
		local rightButton = buttons[slotArrangement[3][2]]

		if leftButton then
			leftButton:SetPoint('BOTTOMLEFT', gearManager, 'BOTTOMLEFT', bottomStart, 5)
		end

		if rightButton then
			rightButton:SetPoint('BOTTOMRIGHT', gearManager, 'BOTTOMRIGHT', -bottomStart, 5)
		end
	else
		-- Fallback positioning if there are not exactly 2 bottom buttons
		for i, slotName in ipairs(slotArrangement[3]) do
			local button = buttons[slotName]
			if button then
				button:SetPoint('BOTTOMLEFT', gearManager, 'BOTTOMLEFT', bottomStart + ((i - 1) * (button:GetWidth() + horizontalSpacing)), 5)
			end
		end
	end
end

---@param frame LibCS.Frame
---@return LibCS.GearFrame
function CreateGearManager(frame)
	---@class LibCS.GearFrame : Frame
	local gearManager = CreateFrame('Frame', nil, frame)
	gearManager:SetPoint('TOPLEFT', frame.Portrait)
	gearManager:SetPoint('BOTTOMRIGHT', frame.Portrait, 0, frame.Portrait.footerFrame:GetHeight() + 10)

	local buttonSize = 40 -- Adjust as needed
	local buttons = {} ---@type table<InventorySlotName, LibCS.GearFrame.Button>

	local slotArrangement = {
		[1] = {'HEADSLOT', 'NECKSLOT', 'SHOULDERSLOT', 'BACKSLOT', 'CHESTSLOT', 'SHIRTSLOT', 'TABARDSLOT', 'WRISTSLOT'},
		[2] = {'HANDSSLOT', 'WAISTSLOT', 'LEGSSLOT', 'FEETSLOT', 'FINGER0SLOT', 'FINGER1SLOT', 'TRINKET0SLOT', 'TRINKET1SLOT'},
		[3] = {'MAINHANDSLOT', 'SECONDARYHANDSLOT'}
	}

	for _, group in ipairs(slotArrangement) do
		for _, slotName in ipairs(group) do
			buttons[slotName] = CreateGearButton(gearManager, slotName, buttonSize)
		end
	end

	local size = 40
	for i, child in ipairs({PaperDollItemsFrame:GetChildren()}) do
		local iconSize = size * 0.85 -- 85% of button size
		local borderSize = size * 2.62 -- 262% of button size (maintains proportion)
		local highlightSize = size * 1.31 -- 131% of button size
		child.IconMask = child:CreateMaskTexture()
		child.IconMask:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\masks\\Circle', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		child.IconMask:SetAllPoints(child.icon)
		for i, textures in ipairs({child:GetRegions()}) do
			if textures:GetObjectType() == 'Texture' then
				textures:AddMaskTexture(child.IconMask)
			end
		end

		child.HighlightTexture:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\ItemBorderInnerHighlight')
		child.HighlightTexture:SetSize(highlightSize, highlightSize)
		child.HighlightTexture:ClearAllPoints()
		child.HighlightTexture:SetPoint('CENTER')
		child.PushedTexture:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\ItemBorderInnerHighlight')
	end

	PositionGearButtons(gearManager, buttons, slotArrangement)

	EquipmentFlyoutFrame.Mask = EquipmentFlyoutFrame:CreateMaskTexture()
	EquipmentFlyoutFrame.Mask:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\masks\\Circle', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	EquipmentFlyoutFrame.Mask:SetAllPoints(EquipmentFlyoutFrame.Highlight)
	EquipmentFlyoutFrame.Highlight:AddMaskTexture(EquipmentFlyoutFrame.Mask)

	gearManager.GearButtons = buttons

	-- Function to update button icons with equipped items
	gearManager.Update = function()
		for slotName, button in pairs(buttons) do
			local itemID = GetInventoryItemID('player', button.slotID)
			if itemID then
				local itemTexture = C_Item.GetItemIconByID(itemID)
				button.ItemIcon:SetTexture(itemTexture)
			else
				button.ItemIcon:SetTexture(button.emptyTexture)
			end
		end
	end

	-- Initial update of equipped items
	gearManager:Update()

	return gearManager
end

---@param frame Frame
---@return LibCS.Portrait
local function CreatePortrait(frame)
	---@class LibCS.Portrait : PlayerModel
	local portrait = CreateFrame('PlayerModel', nil, frame)
	portrait:SetSize(231, frame:GetHeight() - 50)
	portrait:SetPoint('CENTER', frame, 'CENTER', 0, 0)
	portrait:SetUnit('player')

	-- Gradient
	portrait.Gradient = portrait:CreateTexture(nil, 'BACKGROUND', nil, 2)
	portrait.Gradient:SetPoint('TOPLEFT', -100, 50)
	portrait.Gradient:SetPoint('BOTTOMRIGHT', 100, -25)
	portrait.Gradient:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\Gradient.jpg')
	portrait.Gradient:SetAlpha(0.1)

	-- Background
	portrait.Background = portrait:CreateTexture(nil, 'BACKGROUND')
	portrait.Background:SetPoint('CENTER')
	-- portrait.Background:SetSize(portrait:GetWidth() * 1.5, portrait:GetHeight() * 1.5) -- Make it larger than the portrait
	portrait.Background:SetAtlas('gearUpdate-BG', true)
	portrait.Background:SetScale(.75)
	portrait.Background:SetAlpha(0.7)

	-- Mask
	portrait.Mask = portrait:CreateMaskTexture()
	portrait.Mask:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\RingMask.png')
	portrait.Mask:SetAllPoints(portrait.Gradient)
	portrait.Background:AddMaskTexture(portrait.Mask)
	portrait.Gradient:AddMaskTexture(portrait.Mask)

	-- Line Mask
	portrait.LineMask = portrait:CreateMaskTexture()
	portrait.LineMask:SetTexture('Interface\\AddOns\\SpartanUI\\images\\Menu\\SquareMask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	portrait.LineMask:SetPoint('TOPLEFT', portrait.Gradient, 'TOPLEFT', 100, 0)
	portrait.LineMask:SetPoint('BOTTOMRIGHT', portrait.Gradient, 'BOTTOMRIGHT', -100, 0)
	portrait.Gradient:AddMaskTexture(portrait.LineMask)
	portrait.Background:AddMaskTexture(portrait.LineMask)

	-- Character name and level
	local characterHeaderFrame = CreateFrame('Frame', nil, portrait)
	characterHeaderFrame:SetSize(200, 30)
	characterHeaderFrame:SetPoint('TOP', portrait, 'TOP', 0, -10)
	characterHeaderFrame.background = characterHeaderFrame:CreateTexture(nil, 'ARTWORK')
	characterHeaderFrame.background:SetPoint('CENTER', characterHeaderFrame, 'CENTER', 0, 0)
	characterHeaderFrame.background:SetAtlas('ui-frame-thewarwithin-subtitle', true)

	characterHeaderFrame.Label = characterHeaderFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	characterHeaderFrame.Label:SetPoint('CENTER', characterHeaderFrame, 'CENTER', 0, 0)
	characterHeaderFrame.Label:SetText(UnitLevel('player') .. ' ' .. UnitName('player'))
	portrait.headerFrame = characterHeaderFrame

	-- Character Spec label
	local class = UnitClass('player')
	local spec = GetSpecialization()
	local specName = spec and (select(2, GetSpecializationInfo(spec)) .. ' ') or ''

	local characterFooterFrame = CreateFrame('Frame', nil, portrait)
	characterFooterFrame:SetSize(200, 30)
	characterFooterFrame:SetPoint('BOTTOM', portrait, 'BOTTOM', 0, 10)
	characterFooterFrame.background = characterFooterFrame:CreateTexture(nil, 'ARTWORK')
	characterFooterFrame.background:SetPoint('CENTER', characterFooterFrame, 'CENTER', 0, 0)
	characterFooterFrame.background:SetAtlas('gearUpdate-BG', true)

	characterFooterFrame.Label = characterFooterFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	characterFooterFrame.Label:SetPoint('CENTER', characterFooterFrame, 'CENTER', 0, 0)
	characterFooterFrame.Label:SetText(specName .. class)
	portrait.footerFrame = characterFooterFrame

	return portrait
end

local function NameUpdate()
	LibCS.Frame.Portrait.headerFrame.Label:SetText(UnitLevel('player') .. ' ' .. UnitName('player'))
end

function LibCS:CreateNewCharacterFrame()
	-- Main frame
	---@class LibCS.Frame : Frame
	local frame = CreateFrame('Frame', 'LibCSCharacterFrame', UIParent)
	frame:SetSize(660, 500)
	frame:SetFrameLevel(500)
	frame:SetPoint('CENTER')
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag('LeftButton')
	frame:SetScript('OnDragStart', frame.StartMoving)
	frame:SetScript('OnDragStop', frame.StopMovingOrSizing)

	-- Background
	frame.Background = frame:CreateTexture(nil, 'BACKGROUND')
	frame.Background:SetPoint('CENTER')
	frame.Background:Show()

	-- Create a mask texture
	local maskTexture = frame:CreateMaskTexture()
	maskTexture:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\masks\\SquareMask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	maskTexture:SetPoint('TOPLEFT', frame, 'TOPLEFT', -1, 1)
	maskTexture:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 1, -1)

	-- Apply the mask to the background
	frame.Background:AddMaskTexture(maskTexture)

	-- Top Glow
	frame.TopGlow = frame:CreateTexture(nil, 'ARTWORK')
	frame.TopGlow:SetPoint('TOP')

	-- Bottom Glow
	frame.BottomGlow = frame:CreateTexture(nil, 'ARTWORK')
	frame.BottomGlow:SetPoint('BOTTOM')

	-- Border
	frame.Border = frame:CreateTexture(nil, 'BORDER')
	frame.Border:SetAllPoints()
	frame.Border:SetScale(self.DB.background.border.scale)
	frame.Border:SetAlpha(self.DB.background.border.alpha)

	-- NineSlice frame (for additional border elements)
	frame.NineSlice = CreateFrame('Frame', nil, frame)
	frame.NineSlice:SetAllPoints()

	-- Top border decorations
	frame.TopBorderDecoration = frame:CreateTexture(nil, 'OVERLAY')
	frame.TopBorderDecoration:SetPoint('TOP', frame, 'TOP')
	frame.TopBorderDecoration:SetScale(self.DB.background.border.scale + .1)
	frame.TopBorderDecoration:SetAlpha(self.DB.background.border.alpha)

	-- Bottom border decoration
	frame.BottomBorderDecoration = frame:CreateTexture(nil, 'OVERLAY')
	frame.BottomBorderDecoration:SetPoint('BOTTOM', frame, 'BOTTOM')
	frame.BottomBorderDecoration:SetScale(self.DB.background.border.scale + .1)
	frame.BottomBorderDecoration:SetAlpha(self.DB.background.border.alpha)

	-- Close button
	frame.CloseButton = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
	frame.CloseButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -9, -9)

	-- Portrait
	frame.Portrait = CreatePortrait(frame)

	-- Create gear buttons
	frame.GearManager = CreateGearManager(frame)

	-- Stats section (similar to RenownFrame's reward section)
	-- local statsFrame = CreateFrame('Frame', nil, frame)
	-- statsFrame:SetSize(200, 400)
	-- statsFrame:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -20, -100)
	-- frame.statsFrame = statsFrame

	-- local function CreateStatDisplay(statName, yOffset)
	-- 	local statFrame = CreateFrame('Frame', nil, statsFrame)
	-- 	statFrame:SetSize(180, 30)
	-- 	statFrame:SetPoint('TOP', statsFrame, 'TOP', 0, yOffset)

	-- 	local statIcon = statFrame:CreateTexture(nil, 'ARTWORK')
	-- 	statIcon:SetSize(30, 30)
	-- 	statIcon:SetPoint('LEFT', statFrame, 'LEFT')
	-- 	-- Set texture to the appropriate stat icon

	-- 	local statText = statFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	-- 	statText:SetPoint('LEFT', statIcon, 'RIGHT', 10, 0)
	-- 	statText:SetText(statName .. ': 100') -- Replace with actual stat value

	-- 	return statFrame
	-- end

	-- local strengthStat = CreateStatDisplay('Strength', -10)
	-- local agilityStat = CreateStatDisplay('Agility', -50)
	-- local intellectStat = CreateStatDisplay('Intellect', -90)
	-- Add more stats as needed

	-- Bottom tabs (similar to RenownFrame)
	-- local function CreateTab(name, index)
	-- 	local tab = CreateFrame('Button', nil, frame, 'CharacterFrameTabButtonTemplate')
	-- 	tab:SetText(name)
	-- 	tab:SetID(index)
	-- 	if index == 1 then
	-- 		tab:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 5, -30)
	-- 	else
	-- 		tab:SetPoint('LEFT', _G[frame:GetName() .. 'Tab' .. (index - 1)], 'RIGHT', -16, 0)
	-- 	end
	-- 	return tab
	-- end

	-- local characterTab = CreateTab('Character', 1)
	-- local reputationTab = CreateTab('Reputation', 2)
	-- local currencyTab = CreateTab('Currency', 3)

	return frame
end

---@param frame LibCS.Frame
function LibCS:SetupFrameArt(frame)
	local textureKit = 'thewarwithin' -- This should be determined based on the character's faction or class
	-- local textureKit = 'DragonFlight' -- This should be determined based on the character's faction or class

	-- Define the regions we want to apply textures to
	local mainTextureKitRegions = {
		['Background'] = 'uiframethewarwithinbackground',
		['TopGlow'] = 'UI-%s-Highlight-Top',
		['BottomGlow'] = 'UI-%s-Highlight-Bottom'
	}

	-- Setup the main textures
	SetupTextureKitOnRegions(textureKit, frame, mainTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)

	-- Set border
	local borderFile = 'UI-Frame-%s-Border'
	frame.Border:SetAtlas(borderFile:format(textureKit), TextureKitConstants.UseAtlasSize)

	frame.TopBorderDecoration:SetAtlas('ui-frame-' .. textureKit .. '-embellishmenttop', TextureKitConstants.UseAtlasSize)

	-- Set bottom border decoration
	frame.BottomBorderDecoration:SetAtlas('ui-frame-' .. textureKit .. '-embellishmentbottom', TextureKitConstants.UseAtlasSize)

	frame.Portrait.headerFrame.background:SetAtlas('ui-frame-' .. textureKit .. '-subtitle', TextureKitConstants.UseAtlasSize)
	frame.Portrait.footerFrame.background:SetAtlas('ui-frame-' .. textureKit .. '-subtitle', TextureKitConstants.UseAtlasSize)
	-- frame.portrait.border:SetAtlas('ui-frame-' .. textureKit .. '-portraitwider', TextureKitConstants.UseAtlasSize)

	-- Apply the background
	-- frame.Background:SetAtlas('ui-frame-' .. textureKit .. '-backgroundtile', TextureKitConstants.UseAtlasSize)
	-- frame.Background:SetAtlas('ui-frame-' .. textureKit .. '-cardparchmentwider', TextureKitConstants.UseAtlasSize)
	local visual, isAtlas = LibCS:GetDynamicBackground()
	if isAtlas then
		frame.Background:SetAtlas(visual, TextureKitConstants.UseAtlasSize)
	else
		frame.Background:SetTexture(visual)
	end
	-- /script LibCSCharacterFrame.Background:SetAtlas('hunter-stable-bg-art_tenacity', TextureKitConstants.UseAtlasSize)
	-- /script LibCSCharacterFrame.Background:SetAtlas('legionmission-complete-background-hunter', TextureKitConstants.UseAtlasSize)
	frame.Background:Show()
	-- frame.Background:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\frame\\UIFrameTheWarWithinBackground')
	-- /script LibCSCharacterFrame:Show()
	-- /script LibCSCharacterFrame.portrait:SetSize(200, 300)
end

function LibCS:OnInitialize()
	self.database = LibStub('AceDB-3.0'):New('LibCSDB', {profile = DBDefaults})
	self.DB = self.database.profile ---@type LibCS.DB

	self:RegisterChatCommand('libcs', 'ChatCommand')

	C_AddOns.LoadAddOn('Blizzard_MajorFactions')
	C_AddOns.LoadAddOn('Blizzard_TokenUI')
	WeeklyRewards_LoadUI()

	-- Strip()
end

function LibCS:OnEnable()
	self:RegisterChatCommand('libcs', 'ChatCommand')

	-- Call this function to create and show the frame
	---@class LibCS.Frame : Frame
	LibCS.Frame = LibCS:CreateNewCharacterFrame()
	LibCS:SetupFrameArt(LibCS.Frame)
	LibCS.Frame:Hide()

	CheckAddionalAddons()

	CharacterFrame:HookScript(
		'OnShow',
		function()
			LibCS.Frame:Show()
			LibCS:RegisterEvent('UNIT_MODEL_CHANGED')
		end
	)
	CharacterFrame:HookScript(
		'OnHide',
		function()
			LibCS.Frame:Hide()
			LibCS:UnregisterEvent('UNIT_MODEL_CHANGED')
		end
	)

	-- self:RegisterEvent('PLAYER_ENTERING_WORLD')
	-- self:RegisterEvent('CHARACTER_POINTS_CHANGED')
	-- self:RegisterEvent('UNIT_STATS')
	-- self:RegisterEvent('UNIT_RANGEDDAMAGE')
	-- self:RegisterEvent('UNIT_ATTACK_POWER')
	-- self:RegisterEvent('UNIT_RANGED_ATTACK_POWER')
	-- self:RegisterEvent('UNIT_ATTACK')
	self:RegisterEvent('UNIT_LEVEL', NameUpdate)
	self:RegisterEvent('UNIT_NAME_UPDATE', NameUpdate)
	-- self:RegisterEvent('UNIT_SPELL_HASTE')
	-- self:RegisterEvent('UNIT_RESISTANCES')
	-- self:RegisterEvent('PLAYER_GUILD_UPDATE')
	-- self:RegisterEvent('SKILL_LINES_CHANGED')
	-- self:RegisterEvent('COMBAT_RATING_UPDATE')
	-- self:RegisterEvent('MASTERY_UPDATE')
	-- self:RegisterEvent('SPEED_UPDATE')
	-- self:RegisterEvent('LIFESTEAL_UPDATE')
	-- self:RegisterEvent('AVOIDANCE_UPDATE')
	-- self:RegisterEvent('KNOWN_TITLES_UPDATE')
	-- self:RegisterEvent('PLAYER_TALENT_UPDATE')
	-- self:RegisterEvent('BAG_UPDATE')
	-- self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
	-- self:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')
	-- self:RegisterEvent('PLAYER_DAMAGE_DONE_MODS')
	-- self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	-- self:RegisterUnitEvent('UNIT_DAMAGE', 'player')
	-- self:RegisterUnitEvent('UNIT_ATTACK_SPEED', 'player')
	-- self:RegisterUnitEvent('UNIT_MAXHEALTH', 'player')
	-- self:RegisterUnitEvent('UNIT_AURA', 'player')
	-- self:RegisterEvent('SPELL_POWER_CHANGED')
	-- self:RegisterEvent('CHARACTER_ITEM_FIXUP_NOTIFICATION')
	---@diagnostic disable-next-line: param-type-mismatch
	-- self:RegisterEvent('TRIAL_STATUS_UPDATE')
	-- self:RegisterEvent('PLAYER_TARGET_CHANGED')
	LibCS:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
end

function LibCS:UNIT_MODEL_CHANGED()
	LibCS.Frame.Portrait:RefreshUnit()
end

function LibCS:ACTIVE_PLAYER_SPECIALIZATION_CHANGED()
	local visual, isAtlas = LibCS:GetDynamicBackground()
	if isAtlas and visual then
		LibCS.Frame.Background:SetAtlas(visual, TextureKitConstants.UseAtlasSize)
	else
		LibCS.Frame.Background:SetTexture(visual)
	end

	if LibCS.DB.background.border.enabled then
		LibCS.Frame.Border:Show()
	else
		LibCS.Frame.Border:Hide()
	end

	-- Character Spec label
	local class = UnitClass('player')
	local spec = GetSpecialization()
	local specName = spec and (select(2, GetSpecializationInfo(spec)) .. ' ') or ''

	LibCS.Frame.Portrait.footerFrame.Label:SetText(specName .. class)
end

function LibCS:ChatCommand(input)
	LibCSCharacterFrame.portrait:RefreshUnit()
	LibCSCharacterFrame:Show()
end

local SpecializationVisuals = {
	-- DK
	[0250] = 'deathknight-blood',
	[0251] = 'deathknight-frost',
	[0252] = 'deathknight-unholy',
	-- DH
	[0577] = 'demonhunter-havoc',
	[0581] = 'demonhunter-vengeance',
	-- Druid
	[0102] = 'druid-balance',
	[0103] = 'druid-feral',
	[0104] = 'druid-guardian',
	[0105] = 'druid-restoration',
	-- Evoker
	[1467] = 'evoker-devastation',
	[1468] = 'evoker-preservation',
	[1473] = 'evoker-augmentation',
	-- Hunter
	[0253] = 'hunter-beastmastery',
	[0254] = 'hunter-marksmanship',
	[0255] = 'hunter-survival',
	-- Mage
	[0062] = 'mage-arcane',
	[0063] = 'mage-fire',
	[0064] = 'mage-frost',
	-- Monk
	[0268] = 'monk-brewmaster',
	[0269] = 'monk-windwalker',
	[0270] = 'monk-mistweaver',
	-- Paladin
	[0065] = 'paladin-holy',
	[0066] = 'paladin-protection',
	[0070] = 'paladin-retribution',
	-- Priest
	[0256] = 'priest-discipline',
	[0257] = 'priest-holy',
	[0258] = 'priest-shadow',
	-- Rogue
	[0259] = 'rogue-assassination',
	[0260] = 'rogue-outlaw',
	[0261] = 'rogue-subtlety',
	-- Shaman
	[0262] = 'shaman-elemental',
	[0263] = 'shaman-enhancement',
	[0264] = 'shaman-restoration',
	-- Warlock
	[0265] = 'warlock-affliction',
	[0266] = 'warlock-demonology',
	[0267] = 'warlock-destruction',
	-- Warrior
	[0071] = 'warrior-arms',
	[0072] = 'warrior-fury',
	[0073] = 'warrior-protection'
}

---@param specID? number
---@return string?, boolean?
function LibCS:GetDynamicBackground(specID)
	-- returns specializationID on retail
	if GetSpecialization then
		local currentSpecialization = GetSpecialization()
		if currentSpecialization then
			specID = specID or GetSpecializationInfo(currentSpecialization)
		end
	end

	local visual = SpecializationVisuals[specID]
	local atlas = visual and ('talents-background-%s'):format(visual)
	if atlas and C_Texture.GetAtlasInfo(atlas) then
		return atlas, true
	end
	local classBG = 'Artifacts-' .. UnitClass('player') .. '-BG'
	if C_Texture.GetAtlasInfo(classBG) then
		return classBG, true
	end
end
