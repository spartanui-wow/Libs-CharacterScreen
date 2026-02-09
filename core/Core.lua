local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS') ---@class LibCS
local Core = LibCS:NewModule('Core', 'AceEvent-3.0', 'AceConsole-3.0') ---@class LibCS.Core : AceModule, AceEvent-3.0, AceConsole-3.0
LibCS.Core = Core

---@type table<string, AceModule>
local loadedModules = {}

---@type string[]
local moduleOrder = {
	'Database',
	'Settings',
	'FrameManager',
	'Portrait',
	'Equipment',
	'AddonIntegration',
	'Stats',
	'CircularStats',
	'MythicPlus',
	'RaidProgress',
	'Notifications',
	'LootSpec',
	'Reputation',
	'EnhancedEquipment',
	'ModelControls',
}

function Core:OnInitialize()
	self:LoadCoreModules()
	self:LoadOptionalModules()
end

function Core:OnEnable()
	self:EnableLoadedModules()
end

function Core:OnDisable()
	self:DisableLoadedModules()
end

function Core:LoadCoreModules()
	local coreModules = { 'Database', 'Settings', 'FrameManager' }

	for _, moduleName in ipairs(coreModules) do
		local success, module = self:LoadModule(moduleName, true)
		if not success then
			self:Print('Failed to load core module:', moduleName)
		end
	end
end

function Core:LoadOptionalModules()
	local optionalModules = {
		'Portrait',
		'Equipment',
		'AddonIntegration',
		'Stats',
		'CircularStats',
		'MythicPlus',
		'RaidProgress',
		'Notifications',
		'LootSpec',
		'Reputation',
		'EnhancedEquipment',
		'ModelControls',
	}

	for _, moduleName in ipairs(optionalModules) do
		if self:IsModuleEnabled(moduleName) then
			local success, module = self:LoadModule(moduleName, false)
			if not success then
				self:Print('Failed to load optional module:', moduleName)
			end
		end
	end
end

---@param moduleName string
---@param isCore boolean
---@return boolean success
---@return AceModule? module
function Core:LoadModule(moduleName, isCore)
	if loadedModules[moduleName] then
		return true, loadedModules[moduleName]
	end

	local success, err = pcall(function()
		local module
		if moduleName == 'Database' or moduleName == 'FrameManager' then
			module = LibCS:GetModule(moduleName, true)
		else
			module = LibCS:GetModule(moduleName, true)
		end

		if module and module.OnInitialize then
			module:OnInitialize()
		end

		loadedModules[moduleName] = module
		return module
	end)

	if not success then
		if isCore then
			error('Core module ' .. moduleName .. ' failed to load: ' .. tostring(err))
		else
			self:Print('Optional module', moduleName, 'failed to load:', err)
			return false, nil
		end
	end

	return true, loadedModules[moduleName]
end

function Core:EnableLoadedModules()
	for _, moduleName in ipairs(moduleOrder) do
		local module = loadedModules[moduleName]
		if module and module.OnEnable then
			local success, err = pcall(module.OnEnable, module)
			if not success then
				self:Print('Failed to enable module', moduleName .. ':', err)
			end
		end
	end
end

function Core:DisableLoadedModules()
	local reverseOrder = {}
	for i = #moduleOrder, 1, -1 do
		table.insert(reverseOrder, moduleOrder[i])
	end

	for _, moduleName in ipairs(reverseOrder) do
		local module = loadedModules[moduleName]
		if module and module.OnDisable then
			local success, err = pcall(module.OnDisable, module)
			if not success then
				self:Print('Failed to disable module', moduleName .. ':', err)
			end
		end
	end
end

---@param moduleName string
---@return boolean
function Core:IsModuleEnabled(moduleName)
	if not LibCS.DB or not LibCS.DB.modules then
		return true
	end

	local moduleConfig = LibCS.DB.modules[moduleName:lower()]
	if moduleConfig == nil then
		return true
	end

	return moduleConfig.enabled ~= false
end

---@param moduleName string
---@return AceModule?
function Core:GetModule(moduleName)
	return loadedModules[moduleName]
end

---@param moduleName string
---@return boolean success
function Core:ReloadModule(moduleName)
	local module = loadedModules[moduleName]
	if module and module.OnDisable then
		module:OnDisable()
	end

	loadedModules[moduleName] = nil

	local success, newModule = self:LoadModule(moduleName, false)
	if success and newModule and newModule.OnEnable then
		newModule:OnEnable()
	end

	return success
end
