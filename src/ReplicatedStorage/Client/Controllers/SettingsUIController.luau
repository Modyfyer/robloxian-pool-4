-- Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Modules
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

-- Types
type Settings = SharedSettings.hudSettings

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local SETTING_TAG = "Setting"

local SettingsService
local ColorPickerUIController

local SettingsUIController = Knit.CreateController({
	Name = "SettingsUIController",
})
SettingsUIController._trove = Trove.new()
SettingsUIController._settings = nil :: Settings?

function SettingsUIController:_clearSettingsFrame()
	for _, v in pairs(self._settingsContainer:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Setting" then
			v:Destroy()
		end
	end
end

function SettingsUIController:_createSettingsFrames()
	local mouse: Mouse = Knit.Player:GetMouse()
	local snapAmount: number = 0.1
	local scalar: number = 0.5
	local maxVal: number = 100
	local clicked: { boolean } = {}

	local function updateSlider(slider: ImageButton, amount: TextLabel, bar: Frame, settingName: string?)
		local xOffset: number = math.floor((mouse.X - bar.AbsolutePosition.X) / snapAmount + scalar) * snapAmount
		local xOffsetClamped = math.clamp(xOffset, 0, bar.AbsoluteSize.X)

		local newPos: UDim2 = UDim2.new(0, xOffsetClamped, 0.5, 0)
		slider.Position = newPos

		local roundedAbsSize: number = math.floor(bar.AbsoluteSize.X / snapAmount + scalar) * snapAmount
		local roundedOffsetClamped: number = math.floor(xOffsetClamped / snapAmount + scalar) * snapAmount

		local sliderVal: number = roundedOffsetClamped / roundedAbsSize
		local scaledVal: number = math.clamp((sliderVal * maxVal), 0, 100)
		local scaledValInt: number = math.modf(scaledVal)
		local formattedText: string = `{tostring(scaledValInt)}%`
		amount.Text = formattedText

		if settingName and self._settings[settingName] then
			self._settings[settingName] = scaledValInt
		end
	end

	local function activateSlider(settingFrame: Frame, index: number)
		local bar: Frame = settingFrame:WaitForChild("Bar") :: Frame
		local slider: ImageButton = bar:WaitForChild("Slider") :: ImageButton
		local amount: TextLabel = bar:WaitForChild("Amount") :: TextLabel
		local settingName = settingFrame:GetAttribute("SettingName") :: string
		table.insert(clicked, index, false)

		local settingAmount = self._settings[settingName]
		if settingName and settingAmount then
			amount.Text = `{settingAmount}%`
			local xVal = math.clamp(settingAmount / 100, 0, 1)
			slider.Position = UDim2.fromScale(xVal, 0.5)
		end

		local function setAll(bool: boolean)
			for i = 1, #clicked do
				clicked[i] = bool
			end
		end

		self._settingsTrove:Connect(slider.MouseButton1Down, function()
			setAll(false)
			clicked[index] = true
		end)

		self._settingsTrove:Connect(UserInputService.InputEnded, function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.Gamepad1
			then
				clicked[index] = false
			end
		end)

		self._settingsTrove:Connect(mouse.Move, function()
			if clicked[index] then
				updateSlider(slider, amount, bar, settingName)
			end
		end)
	end

	local function activateButton(settingFrame: Frame)
		local button: GuiButton = settingFrame:WaitForChild("Button") :: GuiButton
		local settingName = settingFrame:GetAttribute("SettingName") :: string

		self._settingsTrove:Connect(button.Activated, function()
			if settingName == "accessoryColor" then
				ColorPickerUIController:Show()
			end
		end)
	end

	self._settingsFrames = CollectionService:GetTagged(SETTING_TAG) :: { Frame }
	for index, settingFrame in pairs(self._settingsFrames) do
		if not settingFrame:IsA("Frame") then
			continue
		end
		settingFrame.Visible = true
		settingFrame.SettingName.Text = settingFrame:GetAttribute("DisplayName")
		if settingFrame:GetAttribute("SettingType") == "Slider" then
			activateSlider(settingFrame, index)
		elseif settingFrame:GetAttribute("SettingType") == "Button" then
			activateButton(settingFrame)
		end
	end
end

function SettingsUIController:_loadSettings()
	if self._settingsTrove then
		self._settingsTrove:Destroy()
	end
	self._settingsTrove = Trove.new()
	self:_clearSettingsFrame()
	self:_createSettingsFrames()
end

function SettingsUIController:_saveSettings()
	local settings = SharedSettings.DefaultHUDSettings

	if self._settings ~= nil then
		settings = self._settings
	end
	SettingsService:SaveSettings(settings)
end

function SettingsUIController:KnitInit()
	self._isMobile = UserInputService.TouchEnabled

	self._screenGui = PlayerGui:WaitForChild("SettingsGui") :: ScreenGui

	self._mainFrame = self._screenGui:WaitForChild("MainFrame") :: Frame

	self._background = self._mainFrame:WaitForChild("BG") :: Frame
	self._closeButton = self._mainFrame:WaitForChild("CloseButton") :: GuiButton

	self._settingsContainer = self._background:WaitForChild("ScrollingFrame") :: ScrollingFrame
end

function SettingsUIController:KnitStart()
	SettingsService = Knit.GetService("SettingsService")
	ColorPickerUIController = Knit.GetController("ColorPickerUIController")

	SettingsService.HUDSettingsLoaded:Connect(function(settings: Settings)
		self._settings = settings
		self:_loadSettings()
	end)

	self._trove:Connect(self._closeButton.Activated, function()
		self:_saveSettings()
	end)
end

return SettingsUIController
