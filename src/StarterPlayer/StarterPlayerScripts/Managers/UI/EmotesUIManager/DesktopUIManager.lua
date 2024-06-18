--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Emotes UI for desktop

Initialized by: EmotesUIManager
--]]--<<---------------------------------------------------->>--

--Services
--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
--local UserInputService = game:GetService("UserInputService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
--local LocalPlayer = Players.LocalPlayer
local UI_NAME: string = "Desktop"

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
--local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._screenGui = screenGui

	self._connectionManager = ConnectionManager.new()
	self._mainFrame = screenGui:WaitForChild(UI_NAME) :: Frame
	self.EmotesButtonPressed = BindableEvents:WaitForChild("EmotesButtonPressed") :: BindableEvent

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: ImageButton

	local openTween: Tween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween: Tween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})
	self._openTween = openTween
	self._closeTween = closeTween

	_connectHandlers(self)

	return self
end

--Hides UI and removes connections
function UIManager:Hide()
	self._connectionManager:ConnectToEvent(self._closeTween.Completed, function()
		self._mainFrame.Visible = false
		self._connectionManager:DisconnectAll()
	end)
	self._closeTween:Play()
end

--Shows UI and creates connections
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
	self._openTween:Play()
end

--Hides UI and resets to default values
function UIManager:Clear()
	self._mainFrame.Visible = false
	self._background.UIScale.Scale = 0
end

--Returns the visibility of the main UI frame
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