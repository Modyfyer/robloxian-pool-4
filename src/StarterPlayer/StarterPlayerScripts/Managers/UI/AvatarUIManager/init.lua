--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Avatar UI

Public functions:
-Show()
-Hide()

Initialized by: ClientInit

Conventions:
ALL_CAPS = constants
_underscoreLeadingVariable = private
camelCaseVariable = public
CapitalizedVariable = global to file
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local PlatformType = require(LocalPlayer.PlayerScripts.Managers.PlatformDetectionManager.PlatformType)

local UI_NAME = "AvatarGui"

local AvatarUIManager = {}
AvatarUIManager.__index = AvatarUIManager

--[[**
	Creates a new instance

	@param [t:PlatformDetectionManager] platformDetectionManager The platform detection manager

	@returns The new instance
**--]]
function new(hudUIManager, platformDetectionManager)
	local self = setmetatable({}, AvatarUIManager)

	local connectionManager = ConnectionManager.new()
	local screenGui = LocalPlayer.PlayerGui:WaitForChild(UI_NAME)

	local platformSpecificUIManagers = {}
	for i = 1, #PlatformType do
		local platformTypeName = PlatformType[i]
		local platformSpecificUIManagerName = string.format("%sUIManager", platformTypeName) --%s outputs a string

		if script:FindFirstChild(platformSpecificUIManagerName) then
			platformSpecificUIManagers[i] = require(script:FindFirstChild(platformSpecificUIManagerName)).new(screenGui)
		end
	end

	self._connectionManager = connectionManager
	self._hudUIManager = hudUIManager
	self._platformDetectionManager = platformDetectionManager
	self._platformSpecificUIManagers = platformSpecificUIManagers
	self._screenGui = screenGui

	_connectHandlers(self)

	return self
end

--[[**
	Hides the HUD UI
**--]]
function AvatarUIManager:Hide()
	self._screenGui.Enabled = false

	_iterateOverAllPlatformSpecificUIManagers(self, function (_, platformSpecificUIManager)
		platformSpecificUIManager:Hide()
	end)
end

--[[**
	Shows the HUD UI
**--]]
function AvatarUIManager:Show()
	self._screenGui.Enabled = true
	_showAppropriatePlatformSpecificUIManager(self)
end

--[[ Private functions ]]--
--This sets up all the event handlers
function _connectHandlers(self)
	--When the platformDetectionManager detects a change, hide the old platform UI and show the new one
	local function onDetectedPlatformTypeChanged(newPlatformType, oldPlatformType)
		if self._platformSpecificUIManagers[oldPlatformType] then
			self._platformSpecificUIManagers[oldPlatformType]:Hide()
		end

		if self._screenGui.Enabled and self._platformSpecificUIManagers[newPlatformType] then
			self._platformSpecificUIManagers[newPlatformType]:Show()
		end
	end

	--Listeners
	self._connectionManager:ConnectToEvent(self._platformDetectionManager.DetectedPlatformTypeChanged, onDetectedPlatformTypeChanged)
end

--Helper function for applying a function to every platform specific UI manager
function _iterateOverAllPlatformSpecificUIManagers(self, callback)
	for platformType, platformSpecificUIManager in pairs(self._platformSpecificUIManagers) do
		callback(platformType, platformSpecificUIManager)
	end
end

function _showAppropriatePlatformSpecificUIManager(self)
	local currentPlatformType = self._platformDetectionManager:GetCurrentPlatformType()

	_iterateOverAllPlatformSpecificUIManagers(self, function(platformType, platformSpecificUIManager)
		if platformType == currentPlatformType then
			platformSpecificUIManager:Show()
		else
			platformSpecificUIManager:Hide()
		end
	end)
end

return {
	new = new
}
