---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Notifications : AceModule, AceEvent-3.0
local Notifications = LibCS:NewModule('Notifications', 'AceEvent-3.0')
LibCS.Notifications = Notifications

local isInitialized = false
local config = {}
local toastFrame = nil

function Notifications:OnInitialize()
	config = LibCS.Database:GetModuleConfig('notifications')
end

function Notifications:GetSetting(key, defaultValue)
	return LibCS.Database:GetModuleSetting('notifications', key, defaultValue)
end

function Notifications:OnEnable()
	if not self:GetSetting('enabled', true) then
		return
	end

	if not isInitialized then
		self:CreateToastFrame()
		isInitialized = true
	end
end

function Notifications:OnDisable()
	if toastFrame then
		toastFrame:Hide()
	end
end

function Notifications:CreateToastFrame()
	if toastFrame then
		return
	end

	-- Create toast notification frame
	toastFrame = CreateFrame('Frame', 'LibCS_ToastFrame', UIParent)
	toastFrame:SetSize(300, 100)
	toastFrame:SetPoint('TOP', UIParent, 'TOP', 0, -150)
	toastFrame:SetFrameStrata('FULLSCREEN_DIALOG')
	toastFrame:SetAlpha(0)
	toastFrame:Hide()

	-- Background
	toastFrame.bg = toastFrame:CreateTexture(nil, 'BACKGROUND')
	toastFrame.bg:SetAllPoints()
	toastFrame.bg:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\Gradient.jpg')
	toastFrame.bg:SetVertexColor(0.1, 0.1, 0.1, 0.9)

	-- Border
	toastFrame.border = toastFrame:CreateTexture(nil, 'BORDER')
	toastFrame.border:SetAllPoints()
	toastFrame.border:SetAtlas('UI-Frame-thewarwithin-Border', true)
	toastFrame.border:SetScale(0.7)

	-- Title text
	toastFrame.title = toastFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	toastFrame.title:SetPoint('TOP', toastFrame, 'TOP', 0, -15)
	toastFrame.title:SetTextColor(1, 0.82, 0) -- Gold color
	toastFrame.title:SetJustifyH('CENTER')

	-- Description text
	toastFrame.description = toastFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	toastFrame.description:SetPoint('TOP', toastFrame.title, 'BOTTOM', 0, -10)
	toastFrame.description:SetTextColor(1, 1, 1)
	toastFrame.description:SetJustifyH('CENTER')
	toastFrame.description:SetWidth(280)
	toastFrame.description:SetWordWrap(true)

	-- Store reference for global access
	_G['CCS_TOAST'] = toastFrame
	LibCS.ToastFrame = toastFrame
end

---@param name string
---@param text string
function Notifications:ShowToast(name, text)
	if not toastFrame or not self:GetSetting('enabled', true) then
		return
	end

	-- Play notification sound
	local soundID = self:GetSetting('notificationSound', 44295)
	if soundID then
		PlaySound(soundID, 'master', true)
	end

	if not toastFrame:IsVisible() then
		toastFrame:EnableMouse(false)
		toastFrame.title:SetText(name)
		toastFrame.title:SetAlpha(0)
		toastFrame.description:SetText(text)
		toastFrame.description:SetAlpha(0)
		toastFrame:Show()

		-- Animation sequence from ref.lua
		C_Timer.After(1, function()
			UIFrameFadeIn(toastFrame, 0.5, 0, 1)
		end)

		C_Timer.After(2, function()
			UIFrameFadeIn(toastFrame.title, 0.5, 0, 1)
		end)

		C_Timer.After(2, function()
			UIFrameFadeIn(toastFrame.description, 0.5, 0, 1)
		end)

		local displayTime = self:GetSetting('displayTime', 5)
		C_Timer.After(displayTime, function()
			UIFrameFadeOut(toastFrame, 1, 1, 0)
			C_Timer.After(1, function()
				toastFrame:Hide()
			end)
		end)
	end
end

-- Convenience function for other modules
---@param name string
---@param text string
function Notifications:Toast(name, text)
	self:ShowToast(name, text)
end

-- Global access function (like ref.lua)
function ShowToast(name, text)
	if LibCS.Notifications then
		LibCS.Notifications:ShowToast(name, text)
	end
end

-- Test function for settings
function Notifications:TestToast()
	self:ShowToast('LibCS Test', 'This is a test notification from LibCS!')
end
