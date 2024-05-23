--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Settings UI for desktop

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

local debounce: boolean = false
local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._screenGui = screenGui

	self._mainFrame = screenGui:WaitForChild("Desktop")

	self._connectionManager = ConnectionManager.new()
	self._settings = {}

	self._background = self._mainFrame:WaitForChild("BG")

	self._closeButton = self._background:WaitForChild("CloseButton")
	self._settingsContainer = self._background:WaitForChild("ScrollingFrame")

	self.SettingsButtonPressed = BindableEvents:WaitForChild("SettingsButtonPressed")

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

--[[ Private functions ]]--

-- Handles event connections
function _connectHandlers(self)
	self._connectionManager:ConnectToEvent(self._closeTween.Completed, function()
		self._mainFrame.Visible = false
	end)
	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, function()
		self:Hide()
	end)
	self._connectionManager:ConnectToEvent(RemoteEvents.LoadHUDSettings.OnClientEvent, function(settings)
		self._settings = settings
		_loadSettings(self)
	end)
end

function _clearSettingsFrame(self)
	for _, v in pairs(self._settingsContainer:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Setting" then
			v:Destroy()
		end
	end
end

function _createSetting(self, settingName: string, setting: any)
	local newSetting = self._settingsContainer:WaitForChild("Setting"):Clone()
	newSetting.Name = settingName
	newSetting.SettingName.Text = settingName
	newSetting.Visible = true
	newSetting.Parent = self._settingsContainer
end

function _loadSettings(self)
	_clearSettingsFrame(self)
	print(self._settings)
	for i, v in pairs(self._settings) do
		_createSetting(self, i, v)
	end
end

function _saveSettings(self)
	local settings: SharedSettings.hudSettings = SharedSettings.DefaultHUDSettings
	if self._settings ~= nil then
		settings = self._settings
	end
	RemoteEvents.SaveHUDSettings:FireServer(settings)
end

return {
	new = new
}