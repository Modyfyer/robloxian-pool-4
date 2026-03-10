--[[--<<---------------------------------------------------->>--
Module purpose: Handles the Settings UI for mobile

Public functions:
-Show()
-Hide()

Initialized by: SettingsUIManager
--]]--<<---------------------------------------------------->>--

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

--Declarations
local LocalPlayer: Player = Players.LocalPlayer

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
--local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")

local menuTween: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local UIManager = {}
UIManager.__index = UIManager

--Creates new instance
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._mainFrame = screenGui:WaitForChild("Mobile") :: Frame

	self._connectionManager = ConnectionManager.new()
	local playerSettings: SharedSettings.hudSettings = {}
	self._settings = playerSettings

	self._background = self._mainFrame:WaitForChild("BG") :: Frame

	self._closeButton = self._background:WaitForChild("CloseButton") :: GuiButton
	self._settingsContainer = self._background:WaitForChild("ScrollingFrame") :: ScrollingFrame

	self.SettingsButtonPressed = BindableEvents:WaitForChild("SettingsButtonPressed") :: BindableEvent
	self.SettingsMenuClosed = BindableEvents:WaitForChild("SettingsMenuClosed") :: BindableEvent

	_connectHandlers(self)

	return self
end

--Hides UI
function UIManager:Hide()
	--self._connectionManager:DisconnectAll()
	self._mainFrame.Visible = false
end

--Shows UI
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

	local function onSettingsButtonPressed(state: boolean?)
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

	self._connectionManager:ConnectToEvent(self.SettingsButtonPressed.Event, onSettingsButtonPressed)

	self._connectionManager:ConnectToEvent(self._closeButton.MouseButton1Click, function()
		onSettingsButtonPressed()
		_saveSettings(self)
	end)

	self._connectionManager:ConnectToEvent(closeTween.Completed, function()
		self.SettingsMenuClosed:Fire()
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

function _createSettingsFrames(self)
	local mouse: Mouse = LocalPlayer:GetMouse()
	local snapAmount: number = 0.1
	local offset: number = 0 --padding between slider and bar
	local scalar: number = 0.5
	local maxVal: number = 100
	local clicked: {boolean} = {}

	local function updateSlider(slider: ImageButton, amount: TextLabel, bar: Frame, settingName: string?)
		local xOffset: number = math.floor((mouse.X - bar.AbsolutePosition.X) / snapAmount + scalar) * snapAmount
		local xOffsetClamped = math.clamp(xOffset, offset, bar.AbsoluteSize.X - offset)

		local newPos: UDim2 = UDim2.new(0, xOffsetClamped, 0.5, 0)
		slider.Position = newPos

		local roundedAbsSize: number = math.floor(bar.AbsoluteSize.X / snapAmount + scalar) * snapAmount
		local roundedOffsetClamped: number = math.floor(xOffsetClamped / snapAmount + scalar) * snapAmount

		local sliderVal: number = roundedOffsetClamped / roundedAbsSize
		local scaledVal: number = math.clamp((sliderVal * maxVal), 0, 100)
		local scaledValInt: number = math.modf(scaledVal)
		local formattedText: string = tostring(scaledValInt)
		amount.Text = formattedText

		if settingName and self._settings[settingName] then
			self._settings[settingName] = scaledValInt
		end
	end

	local function activateSlider(settingFrame: Frame, index: number)
		local bar: Frame = settingFrame:WaitForChild("Bar") :: Frame
		local slider: ImageButton = bar:WaitForChild("Slider") :: ImageButton
		local amount: TextLabel = bar:WaitForChild("Amount") :: TextLabel
		local settingName: string? = settingFrame:GetAttribute("SettingName")
		table.insert(clicked, index, false)

		if settingName and self._settings[settingName] then
			amount.Text = self._settings[settingName]
		end

		local function setAll(bool: boolean)
			for i = 1, #clicked do
				clicked[i] = bool
			end
		end

		self._connectionManager:ConnectToEvent(slider.MouseButton1Down, function()
			setAll(false)
			clicked[index] = true
		end)

		self._connectionManager:ConnectToEvent(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				clicked[index] = false
			end
		end)

		self._connectionManager:ConnectToEvent(mouse.Move, function()
			if clicked[index] then
				updateSlider(slider, amount, bar, settingName)
			end
		end)
	end

	for settingName, _ in pairs(SharedSettings.DefaultHUDSettings) do
		for index, settingFrame in pairs(self._settingsContainer:GetChildren()) do
			if settingFrame:IsA("Frame") and settingFrame:GetAttribute("SettingName") == settingName then
				settingFrame.Visible = true
				settingFrame.SettingName.Text = settingFrame:GetAttribute("DisplayName") or settingName
				if settingFrame:GetAttribute("SettingType") == "Slider" then
					activateSlider(settingFrame, index)
				end
			end
		end
	end
end

function _loadSettings(self)
	_clearSettingsFrame(self)
	_createSettingsFrames(self)
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