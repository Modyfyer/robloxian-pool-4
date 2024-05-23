--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Settings UI for mobile

Public functions:
-Show()
-Hide()

Initialized by: SettingsUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

--Declarations
local LocalPlayer: Player = Players.LocalPlayer

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")


local UIManager = {}
UIManager.__index = UIManager

--[[**
	Creates new instance

	@param [t:ScreenGui] screenGui The platform specific screenGui
**--]]
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._mainFrame = screenGui:WaitForChild("Mobile")

	self._connectionManager = ConnectionManager.new()

	self.SettingsButtonPressed = BindableEvents:WaitForChild("SettingsButtonPressed")

	_connectHandlers(self)

	return self
end

--[[**
	Hides UI
**--]]
function UIManager:Hide()
	self._connectionManager:DisconnectAll()
	self._mainFrame.Visible = false
end

--[[**
	Shows UI
**--]]
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

function _connectHandlers(self)
	local function onSettingsButtonPressed()

	end
	
	self._connectionManager:ConnectToEvent(self.SettingsButtonPressed.Event, onSettingsButtonPressed)
end

return {
	new = new
}