--[[--<<---------------------------------------------------->>--
Module purpose: Handles the HUD UI

Initialized by: ClientInit
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager) 
local Event = require(ReplicatedStorage.Utils.Event)
local PlatformType = require(LocalPlayer.PlayerScripts.Managers.PlatformDetectionManager.PlatformType) 

local UI_NAME = "HUDGui"

local HUDUIManager = {} 
HUDUIManager.__index = HUDUIManager --called a "metamethod" - protects you if you try to access a field of the table HUDUIManager that isn't there

--[[**
	Creates a new instance

	@param [t:PlatformDetectionManager] platformDetectionManager The platform detection manager

	@returns The new instance
**--]]
function new(platformDetectionManager)
	local self = setmetatable({}, HUDUIManager) --metatables are complicated, but self refers to the instance of the object (like "this" in C#/Java/etc.)

	-- Dependency group 0
	local connectionManager = ConnectionManager.new() --creates a new instance of the ConnectionManager object
	local screenGui = LocalPlayer.PlayerGui:WaitForChild(UI_NAME)

	-- Dependency group 1
	-- This finds each platform UI manager (desktop, mobile, console) and instances them
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

	self.HideHUDMenus = Event.new()

	_connectHandlers(self)

	return self
end

--[[**
	Hides the HUD UI
**--]]
function HUDUIManager:Hide()
	self._screenGui.Enabled = false

	_iterateOverAllPlatformSpecificUIManagers(self, function (_, platformSpecificUIManager)
		platformSpecificUIManager:Hide()
	end)
end

--[[**
	Shows the HUD UI
**--]]
function HUDUIManager:Show()
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

--Initially show the correct platform's UI
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
