---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Database : AceModule, AceEvent-3.0
local Database = LibCS:NewModule('Database', 'AceEvent-3.0')
LibCS.Database = Database

-- Flexible defaults system - only stores minimal structure for AceDB
local DBDefaults = {
	global = {}
}

function Database:OnInitialize()
	LibCS.database = LibCS.Lib.AceDB:New('LibCSDB', DBDefaults)
	LibCS.DB = LibCS.database.global
end

function Database:GetDatabase()
	return LibCS.database
end

-- Dynamic default getters - no hardcoded values to maintain
---@param key string
---@param defaultValue any
---@return any
function Database:Get(key, defaultValue)
	local value = LibCS.DB[key]
	return value ~= nil and value or defaultValue
end

---@param moduleName string
---@param key string
---@param defaultValue any
---@return any
function Database:GetModuleSetting(moduleName, key, defaultValue)
	if not LibCS.DB.modules then
		LibCS.DB.modules = {}
	end

	if not LibCS.DB.modules[moduleName] then
		LibCS.DB.modules[moduleName] = {}
	end

	local value = LibCS.DB.modules[moduleName][key]
	return value ~= nil and value or defaultValue
end

---@param moduleName string
---@param key string
---@param value any
function Database:SetModuleSetting(moduleName, key, value)
	if not LibCS.DB.modules then
		LibCS.DB.modules = {}
	end

	if not LibCS.DB.modules[moduleName] then
		LibCS.DB.modules[moduleName] = {}
	end

	LibCS.DB.modules[moduleName][key] = value
end

---@param key string
---@param value any
function Database:Set(key, value)
	LibCS.DB[key] = value
end

---@param moduleName string
function Database:ResetModule(moduleName)
	if LibCS.DB.modules and LibCS.DB.modules[moduleName] then
		LibCS.DB.modules[moduleName] = {}

		if LibCS.Core then
			LibCS.Core:ReloadModule(moduleName)
		end
	end
end

---@param moduleName string
---@param enabled boolean
function Database:EnableModule(moduleName, enabled)
	self:SetModuleSetting(moduleName, 'enabled', enabled)

	if LibCS.Core then
		if enabled then
			LibCS.Core:LoadModule(moduleName, false)
			local module = LibCS.Core:GetModule(moduleName)
			if module and module.OnEnable then
				module:OnEnable()
			end
		else
			local module = LibCS.Core:GetModule(moduleName)
			if module and module.OnDisable then
				module:OnDisable()
			end
		end
	end
end

---@param moduleName string
---@return boolean
function Database:IsModuleEnabled(moduleName)
	-- Default to true for essential modules, false for optional ones
	local defaultEnabled = moduleName == 'Portrait' or moduleName == 'Equipment' or moduleName == 'AddonIntegration'
	return self:GetModuleSetting(moduleName, 'enabled', defaultEnabled)
end

---@param moduleName string
---@return table
function Database:GetModuleConfig(moduleName)
	if not LibCS.DB.modules then
		LibCS.DB.modules = {}
	end

	if not LibCS.DB.modules[moduleName] then
		LibCS.DB.modules[moduleName] = {}
	end

	return LibCS.DB.modules[moduleName]
end

---@param moduleName string
---@param config table
function Database:SetModuleConfig(moduleName, config)
	if not LibCS.DB.modules then
		LibCS.DB.modules = {}
	end

	LibCS.DB.modules[moduleName] = config

	if LibCS.Core then
		LibCS.Core:ReloadModule(moduleName)
	end
end
