--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Avatar UI for desktop

Initialized by: AvatarUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
local LocalPlayer = Players.LocalPlayer

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	-- Dependency group 0
	self._mainFrame = screenGui:WaitForChild("Desktop")
	self._connectionManager = ConnectionManager.new()

	-- Dependency group 1
	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft")

	-- Dependency group 2
	self.avatarButton = self._sidebarLeft:WaitForChild("AvatarButton")

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

--Shows UI
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	self.avatarButton.MouseButton1Click:Connect(function()
		self._mainFrame.Visible = not self._mainFrame.Visible
	end)
end

return {
	new = new
}