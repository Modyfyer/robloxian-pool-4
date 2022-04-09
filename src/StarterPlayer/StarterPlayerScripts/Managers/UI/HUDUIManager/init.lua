--[[--<<---------------------------------------------------->>--
Module purpose:

Initialized by: GuiManager
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
--local Event = require(ReplicatedStorage.Event)
local PlatformType = require(LocalPlayer.PlayerScripts.Managers.PlatformDetectionManager.PlatformType)

local HUDUIManager = {}
HUDUIManager.__index = HUDUIManager

--[[**
	Creates a new instance

	@param [t:PlatformDetectionManager] platformDetectionManager The platform detection manager

	@returns The new instance
**--]]
function new(platformDetectionManager)
	local self = setmetatable({}, HUDUIManager)

	-- Dependency group 0
	local connectionManager = ConnectionManager.new()
	local screenGui = LocalPlayer.PlayerGui:WaitForChild("MainGui")

	-- Dependency group 1
	local platformSpecificUIManagers = {}
	for i = 1, #PlatformType do
		local platformTypeName = PlatformType[i]
		local platformSpecificUIManagerName = string.format("%sUIManager", platformTypeName) --%s outputs a string

		if script:FindFirstChild(platformSpecificUIManagerName) then
			platformSpecificUIManagers[i] = require(script:FindFirstChild(platformSpecificUIManagerName)).new(screenGui)
		end
	end

	self._connectionManager = connectionManager
	self._platformDetectionManager = platformDetectionManager
	self._platformSpecificUIManagers = platformSpecificUIManagers
	self._screenGui = screenGui

	_connectHandlers(self)

	return self
end

--[[**
	Hides the inventory UI
**--]]
function HUDUIManager:Hide()
	self._screenGui.Enabled = false

	_iterateOverAllPlatformSpecificUIManagers(self, function (_, platformSpecificUIManager)
		platformSpecificUIManager:Hide()
	end)
end

--[[**
	Shows the inventory UI
**--]]
function HUDUIManager:Show()
	self._screenGui.Enabled = true
	_showAppropriatePlatformSpecificUIManager(self)
end

--[[ Private functions ]]--

function _connectHandlers(self)
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
