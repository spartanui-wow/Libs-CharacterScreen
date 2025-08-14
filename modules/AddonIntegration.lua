---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.AddonIntegration : AceModule, AceEvent-3.0
local AddonIntegration = LibCS:NewModule('AddonIntegration', 'AceEvent-3.0')
LibCS.AddonIntegration = AddonIntegration

local config = {}
local integratedAddons = {}
local createdButtons = {}

---@type table<string, function>
local addonHandlers = {}

function AddonIntegration:OnInitialize()
	config = LibCS.Database:GetModuleConfig('addonintegration')
	self:SetupAddonHandlers()
end

function AddonIntegration:GetSetting(key, defaultValue)
	return LibCS.Database:GetModuleSetting('addonintegration', key, defaultValue)
end

function AddonIntegration:OnEnable()
	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('PLAYER_LOGIN')

	self:ScanForAddons()
end

function AddonIntegration:OnDisable()
	self:UnregisterAllEvents()
	self:RemoveAllIntegrations()
end

function AddonIntegration:SetupAddonHandlers()
	addonHandlers['Pawn'] = function()
		self:IntegratePawn()
	end
	addonHandlers['Narcissus'] = function()
		self:IntegrateNarcissus()
	end
	addonHandlers['Simulationcraft'] = function()
		self:IntegrateSimulationcraft()
	end
end

function AddonIntegration:ScanForAddons()
	if not self:GetSetting('enabled', true) then
		return
	end

	for _, addonName in ipairs(self:GetSetting('supportedAddons', {'Pawn', 'Narcissus', 'Simulationcraft'})) do
		if C_AddOns.IsAddOnLoaded(addonName) and not integratedAddons[addonName] then
			self:IntegrateAddon(addonName)
		end
	end
end

---@param addonName string
function AddonIntegration:IntegrateAddon(addonName)
	if integratedAddons[addonName] then
		return
	end

	local handler = addonHandlers[addonName]
	if handler then
		local success, err = pcall(handler)
		if success then
			integratedAddons[addonName] = true
			if LibCS.DB.debug then
				print('LibCS: Integrated with', addonName)
			end
		else
			print('LibCS: Failed to integrate with', addonName .. ':', err)
		end
	end
end

function AddonIntegration:IntegratePawn()
	local pawnButton = _G['PawnUI_InventoryPawnButton']
	if not pawnButton then
		return
	end

	pawnButton:Hide()

	local newButton = self:CreateAddonButton('LibCS_PawnButton', 'Pawn')
	if newButton then
		newButton:SetScript(
			'OnClick',
			function()
				if PawnUI_InventoryPawnButton and PawnUI_InventoryPawnButton:GetScript('OnClick') then
					PawnUI_InventoryPawnButton:GetScript('OnClick')(PawnUI_InventoryPawnButton)
				end
			end
		)

		local icon = C_AddOns.GetAddOnMetadata('Pawn', 'IconTexture')
		if icon then
			newButton:SetNormalTexture(icon)
		end
	end
end

function AddonIntegration:IntegrateNarcissus()
	local dominationIndicator = _G['NarciCharacterFrameDominationIndicator']
	if dominationIndicator then
		dominationIndicator:ClearAllPoints()
		dominationIndicator:SetPoint('CENTER', CharacterFrame, 'TOPRIGHT', -20, -45)
	end

	local classSetIndicator = _G['NarciCharacterFrameClassSetIndicator']
	if classSetIndicator then
		classSetIndicator:ClearAllPoints()
		classSetIndicator:SetPoint('CENTER', CharacterFrame, 'TOPRIGHT', -20, -70)
	end

	local gemManagerWidget = _G['NarciGemManagerPaperdollWidget']
	if gemManagerWidget then
		gemManagerWidget:SetScale(0.7)
		self:RepositionAddonButton(gemManagerWidget, 'Narcissus')
	end
end

function AddonIntegration:IntegrateSimulationcraft()
	local simcButton = self:CreateAddonButton('LibCS_SimcButton', 'SimC')
	if simcButton then
		simcButton:SetText('SimC')
		simcButton:SetSize(50, 22)

		simcButton:SetScript(
			'OnClick',
			function()
				local Simulationcraft = LibStub('AceAddon-3.0'):GetAddon('Simulationcraft', true)
				if Simulationcraft and Simulationcraft.PrintSimcProfile then
					Simulationcraft:PrintSimcProfile(false, false, false)
				end
			end
		)

		local icon = 'Interface\\AddOns\\SimulationCraft\\logo'
		if C_Texture.GetAtlasInfo('SimC') then
			simcButton:SetNormalAtlas('SimC')
		elseif icon then
			simcButton:SetNormalTexture(icon)
		end
	end
end

---@param buttonName string
---@param addonName string
---@return Button?
function AddonIntegration:CreateAddonButton(buttonName, addonName)
	if _G[buttonName] then
		return _G[buttonName]
	end

	local button = CreateFrame('Button', buttonName, CharacterFrame, 'UIPanelButtonTemplate')
	button:SetSize(32, 32)

	self:RepositionAddonButton(button, addonName)

	button:SetFrameStrata('HIGH')
	button:Show()

	createdButtons[buttonName] = button

	return button
end

---@param button Button
---@param addonName string
function AddonIntegration:RepositionAddonButton(button, addonName)
	button:ClearAllPoints()

	local anchor = self:GetNextButtonPosition()
	button:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.x, anchor.y)

	self:PreventButtonMovement(button, anchor)
end

---@return table
function AddonIntegration:GetNextButtonPosition()
	local buttonCount = self:GetButtonCount()
	local tab3 = _G['CharacterFrameTab3']

	if buttonCount == 0 then
		return {
			point = 'TOPLEFT',
			relativeTo = tab3,
			relativePoint = 'TOPRIGHT',
			x = 0,
			y = 0
		}
	else
		local lastButton = self:GetLastButton()
		return {
			point = 'TOPLEFT',
			relativeTo = lastButton,
			relativePoint = 'TOPRIGHT',
			x = 0,
			y = 0
		}
	end
end

---@return number
function AddonIntegration:GetButtonCount()
	local count = 0
	for _ in pairs(createdButtons) do
		count = count + 1
	end
	return count
end

---@return Button?
function AddonIntegration:GetLastButton()
	local buttons = {}
	for _, button in pairs(createdButtons) do
		if button:IsShown() then
			table.insert(buttons, button)
		end
	end

	if #buttons > 0 then
		return buttons[#buttons]
	end

	return _G['CharacterFrameTab3']
end

---@param button Button
---@param anchor table
function AddonIntegration:PreventButtonMovement(button, anchor)
	button:HookScript(
		'OnShow',
		function()
			button:ClearAllPoints()
			button:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.x, anchor.y)
		end
	)

	hooksecurefunc(
		button,
		'SetPoint',
		function(self, point, relativeTo)
			if relativeTo ~= anchor.relativeTo then
				C_Timer.After(
					0,
					function()
						self:ClearAllPoints()
						self:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.x, anchor.y)
					end
				)
			end
		end
	)
end

function AddonIntegration:RemoveAllIntegrations()
	for buttonName, button in pairs(createdButtons) do
		if button then
			button:Hide()
			button:SetParent(nil)
		end
	end

	createdButtons = {}
	integratedAddons = {}

	self:RestorePawn()
	self:RestoreNarcissus()
end

function AddonIntegration:RestorePawn()
	local pawnButton = _G['PawnUI_InventoryPawnButton']
	if pawnButton then
		pawnButton:Show()
	end
end

function AddonIntegration:RestoreNarcissus()
	local dominationIndicator = _G['NarciCharacterFrameDominationIndicator']
	if dominationIndicator then
		dominationIndicator:ClearAllPoints()
		dominationIndicator:SetPoint('CENTER', CharacterFrame, 'TOPRIGHT', -1, -45)
	end

	local classSetIndicator = _G['NarciCharacterFrameClassSetIndicator']
	if classSetIndicator then
		classSetIndicator:ClearAllPoints()
		classSetIndicator:SetPoint('CENTER', CharacterFrame, 'TOPRIGHT', -1, -45)
	end

	local gemManagerWidget = _G['NarciGemManagerPaperdollWidget']
	if gemManagerWidget then
		gemManagerWidget:SetScale(1)
	end
end

---@param event string
---@param addonName string
function AddonIntegration:ADDON_LOADED(event, addonName)
	if self:GetSetting('enabled', true) then
		self:IntegrateAddon(addonName)
	end
end

function AddonIntegration:PLAYER_LOGIN()
	C_Timer.After(
		2,
		function()
			self:ScanForAddons()
		end
	)
end

---@param addonName string
---@return boolean
function AddonIntegration:IsAddonIntegrated(addonName)
	return integratedAddons[addonName] == true
end

---@return table<string, boolean>
function AddonIntegration:GetIntegratedAddons()
	local result = {}
	for addonName, integrated in pairs(integratedAddons) do
		result[addonName] = integrated
	end
	return result
end

---@param addonName string
function AddonIntegration:RemoveIntegration(addonName)
	if integratedAddons[addonName] then
		integratedAddons[addonName] = nil

		for buttonName, button in pairs(createdButtons) do
			if buttonName:find(addonName) then
				button:Hide()
				button:SetParent(nil)
				createdButtons[buttonName] = nil
			end
		end
	end
end
