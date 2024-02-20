--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Avatar UI for mobile

Public functions:
-Show()
-Hide()

Initialized by: AvatarUIManager
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()

	-- Dependency group 1
	self._sidebarLeft = self._mainFrame:WaitForChild("SidebarLeft")
	
	-- Dependency group 2
	self._avatarButton = self._sidebarLeft:WaitForChild("AvatarButton")
	
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