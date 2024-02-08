--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Settings UI for mobile

Public functions:
-Show()
-Hide()

Initialized by: SettingsUIManager
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
--local UIHelpers = require(LocalPlayer.PlayerScripts.UIHelpers)


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

	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft")

	self._settingsButton = self._sidebarLeft:WaitForChild("SettingsButton")

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
end

return {
	new = new
}