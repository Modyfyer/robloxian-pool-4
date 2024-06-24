--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Emotes UI for mobile

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
local UI_NAME: string = "Mobile"

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
	self.EmotesMenuClosed = BindableEvents:WaitForChild("EmotesMenuClosed") :: BindableEvent

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: ImageButton

	_connectHandlers(self)

	--self._connectionManager:ConnectAll()

	return self
end

--Hides UI and removes connections
function UIManager:Hide()
	--self._connectionManager:DisconnectAll()
	self._mainFrame.Visible = false
end

--Shows UI and creates connections
function UIManager:Show()
	--self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	local debounce: boolean = false
	local openTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})

	local function onEmotesButtonPressed(state: boolean?)
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

	self._connectionManager:ConnectToEvent(self.EmotesButtonPressed.Event, onEmotesButtonPressed)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, onEmotesButtonPressed)
	self._connectionManager:ConnectToEvent(closeTween.Completed, function()
		self.EmotesMenuClosed:Fire()
	end)
end

return {
	new = new
}