--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Shops UI for desktop

Initialized by: ShopsUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
--local UserInputService = game:GetService("UserInputService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
local LocalPlayer = Players.LocalPlayer

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._screenGui = screenGui

	-- Dependency group 0
	self._mainFrame = screenGui:WaitForChild("Desktop")
	self._connectionManager = ConnectionManager.new()

	self._background = self._mainFrame:WaitForChild("BG")

	self._closeButton = self._background:WaitForChild("CloseButton")

	self.ShopsButtonPressed = BindableEvents:WaitForChild("ShopsButtonPressed")

	local openTween: Tween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween: Tween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})
	self._openTween = openTween
	self._closeTween = closeTween

	_connectHandlers(self)

	return self
end

--[[**
	Hides UI
**--]]
function UIManager:Hide()
	self._connectionManager:ConnectToEvent(self._closeTween.Completed, function()
		self._mainFrame.Visible = false
		self._connectionManager:DisconnectAll()
	end)
	self._closeTween:Play()
end

--Shows UI
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
	self._openTween:Play()
end

function UIManager:Clear()
	self._mainFrame.Visible = false
	self._background.UIScale.Scale = 0
end

function UIManager:GetState()
	return self._mainFrame.Visible
end

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	self._connectionManager:ConnectToEvent(self._closeTween.Completed, function()
		self._mainFrame.Visible = false
	end)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, function()
		self:Hide()
	end)
end

return {
	new = new
}