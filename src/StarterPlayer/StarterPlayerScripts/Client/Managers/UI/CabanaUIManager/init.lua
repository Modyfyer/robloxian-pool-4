--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: ClientInit
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local Event = require(ReplicatedStorage.Utils.Event)

--Declarations
local LocalPlayer = Players.LocalPlayer

local PlatformType = require(LocalPlayer.PlayerScripts.Managers.PlatformDetectionManager.PlatformType)

local CabanaUIManager = {}
CabanaUIManager.__index = CabanaUIManager

--Creates new instance
function new(platformDetectionManager)
	local self = setmetatable({}, CabanaUIManager)

	-- Dependency group 0
	local connectionManager = ConnectionManager.new()
	local screenGui = LocalPlayer.PlayerGui:WaitForChild("CabanaGui")

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

	self.RentalResult = Event.new()

	self._screenGui.Enabled = true

	_connectHandlers(self)

	return self
end

--Hides UI
function CabanaUIManager:Hide()
	self._screenGui.Enabled = false

	_iterateOverAllPlatformSpecificUIManagers(self, function (_, platformSpecificUIManager)
		platformSpecificUIManager:Hide()
	end)

	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end

--Shows UI
function CabanaUIManager:Show()
	self._screenGui.Enabled = true

	_showAppropriatePlatformSpecificUIManager(self)
end

--Clears UI and object values
function CabanaUIManager:Clear()
	_iterateOverAllPlatformSpecificUIManagers(self, function (_, platformSpecificUIManager)
		platformSpecificUIManager:Clear()
	end)
end

--[[ Private functions ]]--

-- Handles event connections
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

-- Loops through all platform specific UI managers
function _iterateOverAllPlatformSpecificUIManagers(self, callback)
	for platformType, platformSpecificUIManager in pairs(self._platformSpecificUIManagers) do
		callback(platformType, platformSpecificUIManager)
	end
end

-- Shows the correct UI for the current platform
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
