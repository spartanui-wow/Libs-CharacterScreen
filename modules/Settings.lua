---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Settings : AceModule, AceEvent-3.0
local Settings = LibCS:NewModule('Settings', 'AceEvent-3.0')
LibCS.Settings = Settings

-- Local references
local AceConfig = LibCS.Lib.AceConfig
local AceConfigDialog = LibCS.Lib.AceConfigDialog
local AceDBOptions = LibStub('AceDBOptions-3.0', true)
local LibCompress = LibStub('LibCompress', true)

-- Module definitions for the settings UI
local moduleDefinitions = {
	{ name = 'Portrait', label = 'Portrait', description = 'Character model with header/footer banners' },
	{ name = 'Equipment', label = 'Equipment', description = 'Circular gear slot buttons' },
	{ name = 'AddonIntegration', label = 'Addon Integration', description = 'Integration with Pawn, Narcissus, SimC' },
	{ name = 'Stats', label = 'Stats & DR', description = 'Combat stats with diminishing returns display' },
	{ name = 'CircularStats', label = 'Circular Stats', description = 'Visual circular stat displays' },
	{ name = 'MythicPlus', label = 'Mythic+', description = 'M+ progression and vault tracking' },
	{ name = 'RaidProgress', label = 'Raid Progress', description = 'Raid boss kill tracking' },
	{ name = 'Notifications', label = 'Notifications', description = 'Toast notification system' },
	{ name = 'LootSpec', label = 'Loot Spec', description = 'Loot specialization selector' },
	{ name = 'Reputation', label = 'Reputation', description = 'Enhanced reputation display' },
}

-- Build the AceConfig options table
local function BuildOptionsTable()
	local options = {
		type = 'group',
		name = 'LibCS - Character Screen',
		handler = Settings,
		args = {
			general = {
				type = 'group',
				name = 'General',
				order = 1,
				args = {
					header = {
						type = 'header',
						name = 'General Settings',
						order = 1,
					},
					scale = {
						type = 'range',
						name = 'UI Scale',
						desc = 'Scale of the character frame',
						min = 0.5,
						max = 2.0,
						step = 0.05,
						order = 2,
						get = function()
							return LibCS.Database:Get('scale', 1.0)
						end,
						set = function(_, value)
							LibCS.Database:Set('scale', value)
							if CharacterFrame then
								CharacterFrame:SetScale(value)
							end
						end,
					},
					paddingV = {
						type = 'range',
						name = 'Vertical Padding',
						desc = 'Vertical padding for the character frame',
						min = 0,
						max = 50,
						step = 1,
						order = 3,
						get = function()
							return LibCS.Database:Get('paddingV', 0)
						end,
						set = function(_, value)
							LibCS.Database:Set('paddingV', value)
						end,
					},
					paddingH = {
						type = 'range',
						name = 'Horizontal Padding',
						desc = 'Horizontal padding for the character frame',
						min = 0,
						max = 50,
						step = 1,
						order = 4,
						get = function()
							return LibCS.Database:Get('paddingH', 0)
						end,
						set = function(_, value)
							LibCS.Database:Set('paddingH', value)
						end,
					},
					modelSize = {
						type = 'range',
						name = 'Model Size',
						desc = 'Size of the character model',
						min = 200,
						max = 500,
						step = 10,
						order = 5,
						get = function()
							return LibCS.Database:Get('modelSize', 300)
						end,
						set = function(_, value)
							LibCS.Database:Set('modelSize', value)
						end,
					},
				},
			},
			modules = {
				type = 'group',
				name = 'Modules',
				order = 2,
				args = {
					header = {
						type = 'header',
						name = 'Module Settings',
						order = 1,
					},
					description = {
						type = 'description',
						name = 'Enable or disable individual modules. Changes take effect after reloading the UI.',
						order = 2,
					},
				},
			},
			appearance = {
				type = 'group',
				name = 'Appearance',
				order = 3,
				args = {
					header = {
						type = 'header',
						name = 'Visual Settings',
						order = 1,
					},
					useBackgroundImage = {
						type = 'toggle',
						name = 'Use Background Image',
						desc = 'Use dynamic spec-based background images',
						order = 2,
						get = function()
							return LibCS.Database:Get('useBackgroundImage', true)
						end,
						set = function(_, value)
							LibCS.Database:Set('useBackgroundImage', value)
						end,
					},
					backgroundOverlayAlpha = {
						type = 'range',
						name = 'Background Overlay Alpha',
						desc = 'Transparency of the background overlay',
						min = 0,
						max = 1,
						step = 0.05,
						order = 3,
						get = function()
							return LibCS.Database:Get('backgroundOverlayAlpha', 0.3)
						end,
						set = function(_, value)
							LibCS.Database:Set('backgroundOverlayAlpha', value)
						end,
					},
					textureKit = {
						type = 'select',
						name = 'Frame Style',
						desc = 'Visual style for frame borders',
						order = 4,
						values = {
							['thewarwithin'] = 'The War Within',
							['dragonflight'] = 'Dragonflight',
							['shadowlands'] = 'Shadowlands',
						},
						get = function()
							return LibCS.Database:Get('textureKit', 'thewarwithin')
						end,
						set = function(_, value)
							LibCS.Database:Set('textureKit', value)
						end,
					},
					borderScale = {
						type = 'range',
						name = 'Border Scale',
						desc = 'Scale of frame borders',
						min = 0.5,
						max = 1.5,
						step = 0.05,
						order = 5,
						get = function()
							return LibCS.Database:Get('borderScale', 0.8)
						end,
						set = function(_, value)
							LibCS.Database:Set('borderScale', value)
						end,
					},
				},
			},
			profiles = {
				type = 'group',
				name = 'Profiles',
				order = 100,
				args = {
					header = {
						type = 'header',
						name = 'Profile Management',
						order = 1,
					},
					exportDesc = {
						type = 'description',
						name = 'Export your current settings to share with others, or import settings from an export string.',
						order = 2,
					},
					exportInput = {
						type = 'input',
						name = 'Export String',
						desc = 'Copy this string to share your settings',
						multiline = 5,
						width = 'full',
						order = 3,
						get = function()
							return Settings:ExportProfile()
						end,
						set = function() end, -- Read-only
					},
					importInput = {
						type = 'input',
						name = 'Import String',
						desc = 'Paste an export string here to import settings',
						multiline = 5,
						width = 'full',
						order = 4,
						get = function()
							return ''
						end,
						set = function(_, value)
							if value and value ~= '' then
								Settings:ImportProfile(value)
							end
						end,
					},
				},
			},
		},
	}

	-- Add module toggles dynamically
	local order = 10
	for _, moduleDef in ipairs(moduleDefinitions) do
		options.args.modules.args[moduleDef.name:lower()] = {
			type = 'toggle',
			name = moduleDef.label,
			desc = moduleDef.description,
			order = order,
			get = function()
				return LibCS.Database:IsModuleEnabled(moduleDef.name)
			end,
			set = function(_, value)
				LibCS.Database:EnableModule(moduleDef.name, value)
			end,
		}
		order = order + 1
	end

	-- Add AceDB profile options if available
	if AceDBOptions and LibCS.database then
		options.args.dbProfiles = AceDBOptions:GetOptionsTable(LibCS.database)
		options.args.dbProfiles.order = 99
	end

	return options
end

function Settings:OnInitialize()
	-- Only register once (avoid duplicate registration errors)
	if self.isRegistered then
		return
	end

	-- Register the options table
	local success, err = pcall(function()
		AceConfig:RegisterOptionsTable('LibCS', BuildOptionsTable)
		self.optionsFrame = AceConfigDialog:AddToBlizOptions('LibCS', 'LibCS')
	end)

	if not success then
		-- Options may already be registered, that's fine
		if LibCS.Logger then
			LibCS.Logger.debug('Settings registration: ' .. tostring(err))
		end
	end

	self.isRegistered = true
end

function Settings:OnEnable()
	-- Nothing to do on enable
end

function Settings:OnDisable()
	-- Nothing to do on disable
end

---Open the settings dialog
function Settings:OpenSettings()
	-- Try to open the new settings panel first (11.0+)
	if Settings and Settings.OpenToCategory then
		pcall(function()
			_G.Settings.OpenToCategory('LibCS')
		end)
	else
		-- Fallback to InterfaceOptionsFrame
		if InterfaceOptionsFrame_OpenToCategory then
			InterfaceOptionsFrame_OpenToCategory('LibCS')
			InterfaceOptionsFrame_OpenToCategory('LibCS') -- Call twice for Blizzard bug
		end
	end
end

---Export the current profile to a compressed string
---@return string
function Settings:ExportProfile()
	if not LibCompress then
		return 'Export libraries not available'
	end

	local data = LibCS.DB
	if not data then
		return ''
	end

	-- Serialize the data
	local serialized = LibCS.Lib.AceSerializer:Serialize(data)
	if not serialized then
		return ''
	end

	-- Compress the data
	local compressed = LibCompress:Compress(serialized)
	if not compressed then
		return ''
	end

	-- Encode to base64
	local encoded = LibBase64:Encode(compressed)
	return encoded or ''
end

---Import a profile from a compressed string
---@param encoded string
---@return boolean success
function Settings:ImportProfile(encoded)
	if not LibCompress or not LibBase64 then
		self:Print('Import libraries not available')
		return false
	end

	if not encoded or encoded == '' then
		self:Print('No import string provided')
		return false
	end

	-- Decode from base64
	local compressed = LibBase64:Decode(encoded)
	if not compressed then
		self:Print('Failed to decode import string')
		return false
	end

	-- Decompress the data
	local serialized, err = LibCompress:Decompress(compressed)
	if not serialized then
		self:Print('Failed to decompress: ' .. tostring(err))
		return false
	end

	-- Deserialize the data
	local success, data = LibCS.Lib.AceSerializer:Deserialize(serialized)
	if not success then
		self:Print('Failed to deserialize import data')
		return false
	end

	-- Merge the imported data into the current profile
	if type(data) == 'table' then
		for key, value in pairs(data) do
			LibCS.DB[key] = value
		end
		self:Print('Profile imported successfully! Reload UI to apply all changes.')
		return true
	end

	self:Print('Invalid import data format')
	return false
end

---Register module-specific options
---@param moduleName string
---@param optionsTable table
function Settings:RegisterModuleOptions(moduleName, optionsTable)
	if not optionsTable then
		return
	end

	-- Add the module options as a sub-group
	AceConfig:RegisterOptionsTable('LibCS-' .. moduleName, optionsTable)
	AceConfigDialog:AddToBlizOptions('LibCS-' .. moduleName, optionsTable.name or moduleName, 'LibCS')
end
