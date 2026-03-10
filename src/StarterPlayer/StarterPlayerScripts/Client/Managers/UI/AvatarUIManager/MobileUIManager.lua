--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Avatar UI for mobile

Public functions:
-Show()
-Hide()

Initialized by: AvatarUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
--local LocalPlayer = Players.LocalPlayer

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
--local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--[[**
	Creates new instance

	@param [t:ScreenGui] screenGui The platform specific screenGui
**--]]
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._mainFrame = screenGui:WaitForChild("Mobile") :: Frame
	self._connectionManager = ConnectionManager.new()

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: GuiButton

	self.AvatarButtonPressed = BindableEvents:WaitForChild("AvatarButtonPressed") :: BindableEvent
	self.AvatarMenuClosed = BindableEvents:WaitForChild("AvatarMenuClosed") :: BindableEvent

	_connectHandlers(self)

	return self
end

--[[**
	Hides UI
**--]]
function UIManager:Hide()
	--self._connectionManager:DisconnectAll()
	self._mainFrame.Visible = false
end

--[[**
	Shows UI
**--]]
function UIManager:Show()
	--self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

function _connectHandlers(self)
	local debounce: boolean = false
	local openTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 1})
	local closeTween = TweenService:Create(self._background.UIScale, menuTween, {Scale = 0})

	local function onAvatarButtonPressed(state: boolean?)
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

	self._connectionManager:ConnectToEvent(self.AvatarButtonPressed.Event, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, onAvatarButtonPressed)
	self._connectionManager:ConnectToEvent(closeTween.Completed, function()
		self.AvatarMenuClosed:Fire()
	end)
end

return {
	new = new
}