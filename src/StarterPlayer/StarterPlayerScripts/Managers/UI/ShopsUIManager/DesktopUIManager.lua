--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Shops UI for desktop

Initialized by: ShopsUIManager
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
function new(screenGui: ScreenGui)
	local self = setmetatable({}, UIManager)

	self._screenGui = screenGui

	self._connectionManager = ConnectionManager.new()
	self._mainFrame = screenGui:WaitForChild(UI_NAME) :: Frame
	self.ShopsButtonPressed = BindableEvents:WaitForChild("ShopsButtonPressed") :: BindableEvent
	self.ShopsMenuClosed = BindableEvents:WaitForChild("ShopsMenuClosed") :: BindableEvent

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: ImageButton

	_connectHandlers(self)

	return self
end

--Hides UI and removes connections
function UIManager:Hide()
	self._mainFrame.Visible = false
end

--Shows UI and creates connections
function UIManager:Show()
	self._mainFrame.Visible = true
end

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	local debounce: boolean = false
	local openTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})

	local function onShopsButtonPressed(state: boolean?)
		if debounce then return end
		debounce = true
		if state then
			openTween:Play()
		else
			closeTween:Play()
		end
		task.wait(0.1)
		debounce = false
	end

	self._connectionManager:ConnectToEvent(self.ShopsButtonPressed.Event, onShopsButtonPressed)

	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, function()
		onShopsButtonPressed()
	end)

	self._connectionManager:ConnectToEvent(closeTween.Completed, function()
		self.ShopsMenuClosed:Fire()
	end)
end

return {
	new = new
}