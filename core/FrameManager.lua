---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.FrameManager : AceModule, AceEvent-3.0
local FrameManager = LibCS:NewModule('FrameManager', 'AceEvent-3.0')
LibCS.FrameManager = FrameManager

local isInitialized = false

function FrameManager:GetSetting(key, defaultValue)
	return LibCS.Database:Get(key, defaultValue)
end

function FrameManager:OnInitialize()
	C_AddOns.LoadAddOn('Blizzard_MajorFactions')
	C_AddOns.LoadAddOn('Blizzard_TokenUI')
	WeeklyRewards_LoadUI()
end

function FrameManager:OnEnable()
	if not isInitialized then
		self:InitializeFrameModifications()
		isInitialized = true
	end

	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function FrameManager:OnDisable()
	self:UnregisterAllEvents()
end

---@param event string
---@param addonName string
function FrameManager:ADDON_LOADED(event, addonName)
	if addonName == 'Libs-CharacterScreen' then
		self:InitializeFrameModifications()
	end
end

function FrameManager:PLAYER_ENTERING_WORLD()
	self:InitializeFrameModifications()
end

function FrameManager:InitializeFrameModifications()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', 'InitializeFrameModifications')
		return
	end

	self:UnregisterEvent('PLAYER_REGEN_ENABLED')

	self:ModifyCharacterFrame()
	self:SetupFrameHooks()
end

function FrameManager:ModifyCharacterFrame()
	if InCombatLockdown() then
		return
	end

	local paddingV = self:GetSetting('paddingV', 0)
	local paddingH = self:GetSetting('paddingH', 0)
	local offset = self:GetSetting('offset', 100)

	CharacterFrame:SetHeight(479 + (7 * paddingV))
	local Bgoffset = 17 + paddingH

	CharacterFrame.Inset:Hide()
	CharacterFrame.NineSlice:Hide()
	CharacterFramePortrait:Hide()
	CharacterFrameInsetRight.Bg:Hide()

	-- Hide or reuse the original background where gear/model sat
	if CharacterFrame.Background then
		CharacterFrame.Background:Hide()
	end

	CharacterFrameBg:SetVertexColor(0, 0, 0, 0)
	CharacterFrameBg:ClearAllPoints()
	CharacterFrameBg:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', 0, 0)
	CharacterFrameBg:SetPoint('BOTTOMRIGHT', CharacterFrame, 'BOTTOMRIGHT', offset, 0)

	CharacterFrame.TopTileStreaks:Hide()
	TokenFramePopup:SetFrameStrata('HIGH')
	ReputationFrame:SetFrameStrata('HIGH')

	self:CreateBackground()
	self:ModifyEquipmentSlots()
	self:ModifyFrameElements()
	self:CenterCharacterModel()
end

function FrameManager:CreateBackground()
	local charbg = _G['CharacterFrameBgbg'] or CreateFrame('Frame', 'CharacterFrameBgbg', CharacterFrame)
	local charbgtex = _G['CharacterFrameBgbgtex'] or charbg:CreateTexture('CharacterFrameBgbgtex', 'BACKGROUND', nil, 1)

	-- Create overlay texture (like the old charbgtex overlay)
	local charbgoverlay = _G['CharacterFrameBgOverlay'] or charbg:CreateTexture('CharacterFrameBgOverlay', 'BACKGROUND', nil, 2)

	GearManagerPopupFrame:SetFrameStrata('DIALOG')
	GearManagerPopupFrame.IconSelector:SetFrameStrata('FULLSCREEN')

	charbg:ClearAllPoints()
	charbg:SetAllPoints(CharacterFrameBg)
	charbg:SetFrameStrata('BACKGROUND')

	charbgtex:ClearAllPoints()
	charbgtex:SetAllPoints()

	-- Apply background image or color
	self:ApplyBackgroundVisual(charbgtex)

	-- Setup overlay texture
	charbgoverlay:ClearAllPoints()
	charbgoverlay:SetAllPoints()
	charbgoverlay:SetTexture('Interface\\\\AddOns\\\\Libs-CharacterScreen\\\\media\\\\Gradient.jpg')
	local overlayAlpha = self:GetSetting('backgroundOverlayAlpha', 0.3)
	charbgoverlay:SetVertexColor(0, 0, 0, overlayAlpha)

	LibCS.CharacterFrameBg = charbg
	LibCS.CharacterFrameBgTex = charbgtex
	LibCS.CharacterFrameBgOverlay = charbgoverlay

	-- Add frame art/borders
	self:SetupFrameArt()
end

function FrameManager:ModifyEquipmentSlots()
	self:HideSlotFrames()
	self:RepositionSlots()
	self:ModifySlotAppearance()
end

function FrameManager:HideSlotFrames()
	-- These are the actual Blizzard slot frame names (not "SlotFrame", just "Slot")
	local slotFrames = {
		'CharacterBackSlot',
		'CharacterChestSlot',
		'CharacterFeetSlot',
		'CharacterFinger0Slot',
		'CharacterFinger1Slot',
		'CharacterHandsSlot',
		'CharacterHeadSlot',
		'CharacterLegsSlot',
		'CharacterMainHandSlot',
		'CharacterNeckSlot',
		'CharacterSecondaryHandSlot',
		'CharacterShirtSlot',
		'CharacterShoulderSlot',
		'CharacterTabardSlot',
		'CharacterTrinket0Slot',
		'CharacterTrinket1Slot',
		'CharacterWaistSlot',
		'CharacterWristSlot',
	}

	local hiddenCount = 0
	for _, frameName in ipairs(slotFrames) do
		local frame = _G[frameName]
		if frame then
			frame:Hide()
			hiddenCount = hiddenCount + 1
		end
	end
	LibCS.Logger.debug('FrameManager: Hidden ' .. hiddenCount .. ' Blizzard slot frames')
end

function FrameManager:RepositionSlots()
	if not CharacterModelScene then
		LibCS.Logger.debug('FrameManager: RepositionSlots - CharacterModelScene not found')
		return
	end

	-- Position custom slots created by Equipment module using old positioning logic
	if not LibCS.Core then
		LibCS.Logger.debug('FrameManager: RepositionSlots - LibCS.Core not found')
		return
	end

	local equipmentModule = LibCS.Core:GetModule('Equipment')
	if not equipmentModule or not equipmentModule.GetEnhancedSlots then
		LibCS.Logger.debug('FrameManager: RepositionSlots - Equipment module not found')
		return
	end

	local customSlots = equipmentModule:GetEnhancedSlots()
	if not customSlots or not next(customSlots) then
		-- No custom slots created yet
		LibCS.Logger.debug('FrameManager: RepositionSlots - No custom slots found')
		return
	end

	LibCS.Logger.info('FrameManager: Repositioning slots')

	-- Use exact slot arrangement from old LibCS
	local leftSlots = { 'HEADSLOT', 'NECKSLOT', 'SHOULDERSLOT', 'BACKSLOT', 'CHESTSLOT', 'SHIRTSLOT', 'TABARDSLOT', 'WRISTSLOT' }
	local rightSlots = { 'HANDSSLOT', 'WAISTSLOT', 'LEGSSLOT', 'FEETSLOT', 'FINGER0SLOT', 'FINGER1SLOT', 'TRINKET0SLOT', 'TRINKET1SLOT' }
	local bottomSlots = { 'MAINHANDSLOT', 'SECONDARYHANDSLOT' }

	-- Old positioning values
	local leftStart = 0
	local rightStart = 0
	local bottomStart = 10
	local verticalSpacing = 5
	local horizontalSpacing = 5

	local leftCount, rightCount, bottomCount = 0, 0, 0

	-- Position left side buttons (TOPRIGHT of model, going LEFT)
	for i, slotName in ipairs(leftSlots) do
		local slotID = equipmentModule:GetSlotIDFromName(slotName)
		local slot = slotID and customSlots[slotID]
		if slot then
			slot:ClearAllPoints()
			slot:SetPoint('TOPRIGHT', CharacterModelScene, 'TOPLEFT', leftStart, -((i - 1) * (slot:GetHeight() + verticalSpacing)))
			slot:Show()
			leftCount = leftCount + 1
		end
	end

	-- Position right side buttons (TOPLEFT of model, going RIGHT)
	for i, slotName in ipairs(rightSlots) do
		local slotID = equipmentModule:GetSlotIDFromName(slotName)
		local slot = slotID and customSlots[slotID]
		if slot then
			slot:ClearAllPoints()
			slot:SetPoint('TOPLEFT', CharacterModelScene, 'TOPRIGHT', rightStart, -((i - 1) * (slot:GetHeight() + verticalSpacing)))
			slot:Show()
			rightCount = rightCount + 1
		end
	end

	-- Position bottom buttons
	local mainHandID = equipmentModule:GetSlotIDFromName(bottomSlots[1])
	local offHandID = equipmentModule:GetSlotIDFromName(bottomSlots[2])
	local mainHandSlot = mainHandID and customSlots[mainHandID]
	local offHandSlot = offHandID and customSlots[offHandID]

	if mainHandSlot then
		mainHandSlot:ClearAllPoints()
		mainHandSlot:SetPoint('BOTTOMLEFT', CharacterModelScene, 'BOTTOMLEFT', bottomStart, 5)
		mainHandSlot:Show()
		bottomCount = bottomCount + 1
	end

	if offHandSlot then
		offHandSlot:ClearAllPoints()
		offHandSlot:SetPoint('BOTTOMRIGHT', CharacterModelScene, 'BOTTOMRIGHT', -bottomStart, 5)
		offHandSlot:Show()
		bottomCount = bottomCount + 1
	end

	LibCS.Logger.info('FrameManager: Positioned slots - Left: ' .. leftCount .. ', Right: ' .. rightCount .. ', Bottom: ' .. bottomCount)
end

function FrameManager:ModifySlotAppearance()
	select(16, CharacterMainHandSlot:GetRegions()):Hide()
	select(16, CharacterSecondaryHandSlot:GetRegions()):Hide()
end

function FrameManager:ModifyFrameElements()
	CharacterFrameCloseButton:ClearAllPoints()
	CharacterFrameCloseButton:SetPoint('TOPRIGHT', CharacterFrameBg, 'TOPRIGHT', 5.6, 5)

	-- Add Settings Gear icon
	self:CreateSettingsButton()

	CharacterFrameTitleText:ClearAllPoints()
	CharacterFrameTitleText:SetPoint('TOP', CharacterFrame, 'TOP', 0, 0)
	CharacterFrameTitleText:SetPoint('LEFT', CharacterFrame, 'LEFT', 50, 0)
	CharacterFrameTitleText:SetPoint('RIGHT', CharacterFrameInset, 'RIGHT', -40, 0)

	CharacterLevelText:ClearAllPoints()
	CharacterLevelText:SetPoint('TOP', CharacterFrameTitleText, 'BOTTOM', 0, 0)

	-- Position CharacterFrameInsetRight to align with expanded window right edge
	local rightPanelOffset = self:GetSetting('rightPanelOffset', -10)
	CharacterFrameInsetRight:ClearAllPoints()
	CharacterFrameInsetRight:SetPoint('TOPRIGHT', CharacterFrameBg, 'TOPRIGHT', rightPanelOffset, -30)
	CharacterFrameInsetRight:SetPoint('BOTTOMRIGHT', CharacterFrameBg, 'BOTTOMRIGHT', rightPanelOffset, 30)
	CharacterFrameInsetRight:Show()
	if CharacterStatsPane then
		CharacterStatsPane.ClassBackground:Hide()
	end

	self:HidePaperDollElements()

	CharacterFrameInsetRight.NineSlice:Hide()

	local scale = self:GetSetting('scale', 1.0)
	CharacterFrame:SetScale(scale)

	-- Resize and reposition TokenFrame and ReputationFrame to match expanded window
	self:ResizeSubFrames()

	TokenFrame:SetScale(scale)
	ReputationFrame:SetScale(scale)

	if WeeklyRewardExpirationWarningDialog then
		WeeklyRewardExpirationWarningDialog:Hide()
	end
end

function FrameManager:HidePaperDollElements()
	PaperDollFrame:UnregisterAllEvents()

	local borderElements = {
		'PaperDollInnerBorderBottom',
		'PaperDollInnerBorderBottom2',
		'PaperDollInnerBorderBottomLeft',
		'PaperDollInnerBorderBottomRight',
		'PaperDollInnerBorderLeft',
		'PaperDollInnerBorderRight',
		'PaperDollInnerBorderTop',
		'PaperDollInnerBorderTopLeft',
		'PaperDollInnerBorderTopRight',
	}

	for _, elementName in ipairs(borderElements) do
		local element = _G[elementName]
		if element then
			element:Hide()
		end
	end
end

function FrameManager:SetupFrameHooks()
	if not self.hooksSet then
		CharacterFrame:HookScript('OnShow', function()
			self:OnCharacterFrameShow()
		end)

		CharacterFrame:HookScript('OnHide', function()
			self:OnCharacterFrameHide()
		end)

		self.hooksSet = true
	end
end

function FrameManager:OnCharacterFrameShow()
	if LibCS.Core then
		local portraitModule = LibCS.Core:GetModule('Portrait')
		if portraitModule and portraitModule.OnFrameShow then
			portraitModule:OnFrameShow()
		end
	end

	-- Reposition equipment slots when frame shows
	self:RepositionSlots()

	LibCS:RegisterEvent('UNIT_MODEL_CHANGED')
end

function FrameManager:OnCharacterFrameHide()
	if LibCS.Core then
		local portraitModule = LibCS.Core:GetModule('Portrait')
		if portraitModule and portraitModule.OnFrameHide then
			portraitModule:OnFrameHide()
		end
	end

	LibCS:UnregisterEvent('UNIT_MODEL_CHANGED')
end

function FrameManager:GetCharacterFrame()
	return CharacterFrame
end

function FrameManager:GetCharacterFrameBg()
	return LibCS.CharacterFrameBg
end

function FrameManager:ApplyBackgroundVisual(texture)
	local useBackgroundImage = self:GetSetting('useBackgroundImage', true)
	local backgroundImage = self:GetSetting('backgroundImage', 'Interface\\AddOns\\Libs-CharacterScreen\\media\\frame\\UIFrameNeutralBackground.png')

	if useBackgroundImage and backgroundImage then
		-- Try to get dynamic background first
		local visual, isAtlas = LibCS:GetDynamicBackground()
		if visual and isAtlas then
			texture:SetAtlas(visual, true)
		elseif visual then
			texture:SetTexture(visual)
		else
			-- Fallback to configured background image
			texture:SetTexture(backgroundImage)
		end
		-- Reset vertex color for images
		texture:SetVertexColor(1, 1, 1, 1)
	else
		-- Use solid color background
		local bgColor = self:GetSetting('backgroundColor', { 0, 0, 0, 0.8 })
		local bgr, bgg, bgb, bgalpha = bgColor[1], bgColor[2], bgColor[3], bgColor[4]
		texture:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\Gradient.jpg')
		texture:SetVertexColor(bgr, bgg, bgb, bgalpha)
	end
end

function FrameManager:CenterCharacterModel()
	if not CharacterModelScene then
		return
	end

	local modelSize = self:GetSetting('modelSize', 300)

	CharacterModelScene:ClearAllPoints()
	CharacterModelScene:SetPoint('CENTER', CharacterFrameBg, 'CENTER', 0, 10)
	CharacterModelScene:SetSize(modelSize, modelSize)

	-- Position the control frame properly
	if CharacterModelScene.ControlFrame then
		CharacterModelScene.ControlFrame:ClearAllPoints()
		CharacterModelScene.ControlFrame:SetPoint('TOP', CharacterModelScene, 'TOP', 0, 10)
	end
end

function FrameManager:SetupFrameArt()
	if not LibCS.CharacterFrameBg then
		return
	end

	local textureKit = self:GetSetting('textureKit', 'thewarwithin')
	local borderScale = self:GetSetting('borderScale', 0.8) -- Scale down borders like old implementation
	local decorationScale = borderScale + 0.1 -- Slightly larger for decorations

	-- Create border frame if it doesn't exist
	if not LibCS.CharacterFrameBorder then
		LibCS.CharacterFrameBorder = LibCS.CharacterFrameBg:CreateTexture('LibCS_CharacterFrameBorder', 'ARTWORK')
		LibCS.CharacterFrameBorder:SetAllPoints(LibCS.CharacterFrameBg)

		-- Set border atlas and scale it down like old implementation
		local borderAtlas = 'UI-Frame-' .. textureKit .. '-Border'
		if C_Texture.GetAtlasInfo(borderAtlas) then
			LibCS.CharacterFrameBorder:SetAtlas(borderAtlas, true)
			LibCS.CharacterFrameBorder:SetScale(borderScale)
		end
	end

	-- Create top border decoration
	if not LibCS.CharacterFrameTopDecoration then
		LibCS.CharacterFrameTopDecoration = LibCS.CharacterFrameBg:CreateTexture('LibCS_CharacterFrameTopDecoration', 'ARTWORK')
		LibCS.CharacterFrameTopDecoration:SetPoint('TOP', LibCS.CharacterFrameBg, 'TOP')

		local topDecorationAtlas = 'ui-frame-' .. textureKit .. '-embellishmenttop'
		if C_Texture.GetAtlasInfo(topDecorationAtlas) then
			LibCS.CharacterFrameTopDecoration:SetAtlas(topDecorationAtlas, true)
			LibCS.CharacterFrameTopDecoration:SetScale(decorationScale)
		end
	end

	-- Create bottom border decoration
	if not LibCS.CharacterFrameBottomDecoration then
		LibCS.CharacterFrameBottomDecoration = LibCS.CharacterFrameBg:CreateTexture('LibCS_CharacterFrameBottomDecoration', 'ARTWORK')
		LibCS.CharacterFrameBottomDecoration:SetPoint('BOTTOM', LibCS.CharacterFrameBg, 'BOTTOM')

		local bottomDecorationAtlas = 'ui-frame-' .. textureKit .. '-embellishmentbottom'
		if C_Texture.GetAtlasInfo(bottomDecorationAtlas) then
			LibCS.CharacterFrameBottomDecoration:SetAtlas(bottomDecorationAtlas, true)
			LibCS.CharacterFrameBottomDecoration:SetScale(decorationScale)
		end
	end

	-- Create top glow/highlight (lighter than decorations)
	if not LibCS.CharacterFrameTopGlow then
		LibCS.CharacterFrameTopGlow = LibCS.CharacterFrameBg:CreateTexture('LibCS_CharacterFrameTopGlow', 'OVERLAY')
		LibCS.CharacterFrameTopGlow:SetPoint('TOP', LibCS.CharacterFrameBg, 'TOP')
		LibCS.CharacterFrameTopGlow:SetSize(200, 50)

		local topGlowAtlas = 'UI-' .. textureKit .. '-Highlight-Top'
		if C_Texture.GetAtlasInfo(topGlowAtlas) then
			LibCS.CharacterFrameTopGlow:SetAtlas(topGlowAtlas, true)
			LibCS.CharacterFrameTopGlow:SetAlpha(0.7) -- Make it subtle
		end
	end

	-- Create bottom glow/highlight (lighter than decorations)
	if not LibCS.CharacterFrameBottomGlow then
		LibCS.CharacterFrameBottomGlow = LibCS.CharacterFrameBg:CreateTexture('LibCS_CharacterFrameBottomGlow', 'OVERLAY')
		LibCS.CharacterFrameBottomGlow:SetPoint('BOTTOM', LibCS.CharacterFrameBg, 'BOTTOM')
		LibCS.CharacterFrameBottomGlow:SetSize(200, 50)

		local bottomGlowAtlas = 'UI-' .. textureKit .. '-Highlight-Bottom'
		if C_Texture.GetAtlasInfo(bottomGlowAtlas) then
			LibCS.CharacterFrameBottomGlow:SetAtlas(bottomGlowAtlas, true)
			LibCS.CharacterFrameBottomGlow:SetAlpha(0.7) -- Make it subtle
		end
	end
end

function FrameManager:ResizeSubFrames()
	-- Resize TokenFrame (Currency) and ReputationFrame to match expanded window width
	if not CharacterFrameBg then
		return
	end

	local expandedWidth = CharacterFrameBg:GetWidth()
	local borderOffset = self:GetSetting('frameBorderOffset', 20)
	local targetWidth = expandedWidth - (borderOffset * 2)

	-- Resize TokenFrame (Currency Frame)
	if TokenFrame then
		TokenFrame:ClearAllPoints()
		TokenFrame:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', borderOffset, -30)
		TokenFrame:SetPoint('TOPRIGHT', CharacterFrame, 'TOPRIGHT', -borderOffset, -30)
		TokenFrame:SetWidth(targetWidth)

		-- Adjust TokenFrame internal elements if they exist
		if TokenFrameContainer then
			TokenFrameContainer:SetWidth(targetWidth - 40)
		end
	end

	-- Resize ReputationFrame
	if ReputationFrame then
		ReputationFrame:ClearAllPoints()
		ReputationFrame:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', borderOffset, -30)
		ReputationFrame:SetPoint('TOPRIGHT', CharacterFrame, 'TOPRIGHT', -borderOffset, -30)
		ReputationFrame:SetWidth(targetWidth)

		-- Adjust ReputationFrame internal elements if they exist
		if ReputationFrame.ScrollFrame then
			ReputationFrame.ScrollFrame:SetWidth(targetWidth - 40)
		end
		if ReputationListScrollFrame then
			ReputationListScrollFrame:SetWidth(targetWidth - 40)
		end
	end
end

function FrameManager:CreateSettingsButton()
	-- Create settings button if it doesn't exist
	if not LibCS.SettingsButton then
		LibCS.SettingsButton = CreateFrame('Button', 'LibCS_SettingsButton', CharacterFrame)
		LibCS.SettingsButton:SetSize(20, 20)
		LibCS.SettingsButton:SetPoint('TOPRIGHT', CharacterFrameCloseButton, 'TOPLEFT', -5, 0)

		-- Create icon texture using mechagon-projects atlas
		LibCS.SettingsButton.icon = LibCS.SettingsButton:CreateTexture(nil, 'ARTWORK')
		LibCS.SettingsButton.icon:SetAllPoints()
		LibCS.SettingsButton.icon:SetAtlas('mechagon-projects', true)

		-- Create hover highlight
		LibCS.SettingsButton.highlight = LibCS.SettingsButton:CreateTexture(nil, 'HIGHLIGHT')
		LibCS.SettingsButton.highlight:SetAllPoints()
		LibCS.SettingsButton.highlight:SetAtlas('mechagon-projects', true)
		LibCS.SettingsButton.highlight:SetAlpha(0.5)
		LibCS.SettingsButton.highlight:SetVertexColor(1, 1, 0) -- Yellow tint on hover

		-- Event handlers
		LibCS.SettingsButton:SetScript('OnClick', function()
			self:OpenSettingsDialog()
		end)

		LibCS.SettingsButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
			GameTooltip:SetText('LibCS Settings', 1, 1, 1)
			GameTooltip:AddLine('Click to configure LibCS modules and options', 0.7, 0.7, 0.7)
			GameTooltip:Show()
		end)

		LibCS.SettingsButton:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)
	end
end

function FrameManager:OpenSettingsDialog()
	-- Try to use the Settings module if available
	local settingsModule = LibCS.Core and LibCS.Core:GetModule('Settings')
	if settingsModule and settingsModule.OpenSettings then
		settingsModule:OpenSettings()
	else
		-- Fallback: try to open Blizzard settings directly
		if _G.Settings and _G.Settings.OpenToCategory then
			pcall(function()
				_G.Settings.OpenToCategory('LibCS')
			end)
		elseif InterfaceOptionsFrame_OpenToCategory then
			InterfaceOptionsFrame_OpenToCategory('LibCS')
			InterfaceOptionsFrame_OpenToCategory('LibCS')
		else
			print('LibCS: Settings not available. Please reload UI.')
		end
	end
end

---@return string[]
function FrameManager:GetModuleList()
	local modules = {}
	if LibCS.Core then
		local moduleOrder = { 'Portrait', 'Equipment', 'AddonIntegration', 'CircularStats', 'Reputation', 'EnhancedEquipment', 'LootSpec', 'ModelControls', 'Notifications' }
		for _, moduleName in ipairs(moduleOrder) do
			local module = LibCS.Core:GetModule(moduleName)
			if module then
				table.insert(modules, moduleName)
			end
		end
	end
	return modules
end
