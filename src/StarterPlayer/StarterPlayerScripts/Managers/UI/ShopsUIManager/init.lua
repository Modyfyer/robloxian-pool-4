--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Shops UI

Initialized by: ClientInit
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer: Player = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local PlatformType = require(LocalPlayer.PlayerScripts.Managers.PlatformDetectionManager.PlatformType)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
-- local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
-- local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")

--Constants
local UI_NAME: string = "ShopsGui"

local ShopsUIManager = {}
ShopsUIManager.__index = ShopsUIManager

--[[
	Creates a new instance

	@param [t:hudUIManager] hudUIManager The hud UI manager
	@param [t:PlatformDetectionManager] platformDetectionManager The platform detection manager

	@returns The new instance
--]]
function new(hudUIManager, platformDetectionManager)
	local self = setmetatable({}, ShopsUIManager)

	local connectionManager = ConnectionManager.new()
	local screenGui = LocalPlayer.PlayerGui:WaitForChild(UI_NAME) :: GuiObject

	local platformSpecificUIManagers = {}
	for i = 1, #PlatformType do
		local platformTypeName = PlatformType[i]
		local platformSpecificUIManagerName = string.format("%sUIManager", platformTypeName)

		if script:FindFirstChild(platformSpecificUIManagerName) then
			platformSpecificUIManagers[i] = require(script:FindFirstChild(platformSpecificUIManagerName)).new(screenGui)
		end
	end

	self._connectionManager = connectionManager
	self._hudUIManager = hudUIManager
	self._platformDetectionManager = platformDetectionManager
	self._platformSpecificUIManagers = platformSpecificUIManagers
	self._screenGui = screenGui

	self.ShopsButtonPressed = BindableEvents:WaitForChild("ShopsButtonPressed") :: BindableEvent
	self.State = false

	_connectHandlers(self)

	return self
end

--Hides the Shops UI
function ShopsUIManager:Hide()
	self._screenGui.Enabled = false

	_iterateOverAllPlatformSpecificUIManagers(self, function (_, platformSpecificUIManager)
		platformSpecificUIManager:Hide()
	end)

	self.State = false
end

--Shows the Shops UI
function ShopsUIManager:Show()
	self._screenGui.Enabled = true
	_showAppropriatePlatformSpecificUIManager(self)
	self.State = true
end

--[[ Private functions ]]--
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

	local function onShopsButtonPressed()
		if not self.State then
			self:Show()
		else
			self:Hide()
		end
	end

	--Listeners
	self._connectionManager:ConnectToEvent(self._platformDetectionManager.DetectedPlatformTypeChanged, onDetectedPlatformTypeChanged)
	self._connectionManager:ConnectToEvent(self.ShopsButtonPressed.Event, onShopsButtonPressed)
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
