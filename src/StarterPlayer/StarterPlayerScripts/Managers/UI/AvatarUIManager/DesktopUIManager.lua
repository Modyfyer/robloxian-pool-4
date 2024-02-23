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

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	-- Dependency group 0
	self._mainFrame = screenGui:WaitForChild("Desktop")
	self._connectionManager = ConnectionManager.new()

	self._background = self._mainFrame:WaitForChild("BG")

	self._closeButton = self._background:WaitForChild("CloseButton")

	self.AvatarButtonEvent = BindableEvents:WaitForChild("AvatarButtonPressed")

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
	local debounce: boolean = false
	local menuTween = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local openTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})
	closeTween.Completed:Connect(function()
		self._mainFrame.Visible = false
	end)
	local function onAvatarButtonPressed()
		if debounce then return end
		debounce = true
		if not self._mainFrame.Visible then
			self._mainFrame.Visible = true
			openTween:Play()
		else
			closeTween:Play()
		end
		task.wait(0.1)
		debounce = false
	end

	self._connectionManager:ConnectToEvent(self.AvatarButtonEvent.Event, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, onAvatarButtonPressed)
end

return {
	new = new
}