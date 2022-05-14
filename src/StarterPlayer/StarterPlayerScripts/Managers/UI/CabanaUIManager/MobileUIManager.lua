--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: CabanaUIManager
--]]--<<---------------------------------------------------->>--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local CabanaSettingsByName = require(ReplicatedStorage.Data.CabanaSettingsByName)
local CabanaSettingType = require(ReplicatedStorage.Enums.CabanaSettingType)
--local UIHelpers = require(LocalPlayer.PlayerScripts.HelperFunctions.UIHelpers)

--local _SOUNDS_FOLDER = LocalPlayer.PlayerScripts:WaitForChild("Resources"):WaitForChild("Hub"):WaitForChild("Sounds")

local UIManager = {}
UIManager.__index = UIManager

--[[**
	Creates new instance

	@param [t:ScreenGui] screenGui The platform specific screenGui

	@returns The new instance
**--]]
function new(screenGui)
	local self = setmetatable({}, UIManager)

	self._connectionManager = ConnectionManager.new()

	--Dependency group 1
	self._mainFrame = screenGui:WaitForChild("Mobile")

	--Dependency group 2
	-- self._menu = self._mainFrame:WaitForChild("Menu")
	-- self._settings = self._mainFrame:WaitForChild("Settings")
	-- self._settingsTable = {} 
	-- self._settingState = false

	self._sliderEffectOffTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	self._sliderEffectOnTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	self._arrowEffectLeftTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	self._arrowEffectRightTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

	_connectHandlers(self)

	return self
end

--[[**
	Clears UI and object values
**--]]
function UIManager:Clear()
	
end

--[[**
	Hides UI
**--]]
function UIManager:Hide()
	self._mainFrame.Visible = false
	self._connectionManager:DisconnectAll()
end

--[[**
	Shows UI
**--]]
function UIManager:Show()
	self._connectionManager:ConnectAll()
	self._mainFrame.Visible = true
end

--TODO: Implement this
--[[**
	Updates a single setting

	@param [t:number] newValue The new value of the setting
	@param [t:string] setting The name of the setting

	@returns [t:bool] If the setting saved successfully
**--]]
-- function UIManager:ChangeSetting(newValue, setting)
-- 	return false
-- end

--[[**
	Gets the server settings for the LocalPlayer

	@returns [t:table] A table of the LocalPlayer's saved settings states
**--]]
function UIManager:GetServerSettings()
	--return ReplicatedStorage.Remotes.Functions.Settings.Get:InvokeServer(LocalPlayer)
end

--[[**
	Sends the local settings table to the server to allow for fewer calls

	Have a local table of all settings values in this UIManager. Only fire the server when the settings menu closes or a "save settings" button is clicked.

	@param [t:table] settingsTable The LocalPlayer's settings states

	@returns [t:bool] If the settings saved successfully
**--]]
function UIManager:UpdateServerSettings(settingsTable)
	--return ReplicatedStorage.Remotes.Functions.Settings.UpdateSavedSettings:InvokeServer(LocalPlayer, settingsTable)
end

--[[ Private functions ]]--

function _connectHandlers(self)
	--Create UI elements for each setting in the server settings
	local function _createSettingsSwitches()
		-- for _, setting in pairs(SettingsByName) do
		-- 	if setting.settingType == SettingType.OnOff then
		-- 		local newSetting = self._mainFrame.SettingsListFrame.SliderSetting:Clone()
		-- 		newSetting.Name = setting.displayName
		-- 		newSetting.SettingName.Text = setting.displayName
		-- 		newSetting.Visible = true
		-- 		newSetting.Parent = self._mainFrame.SettingsListFrame
		-- 	end
		-- end
	end
	--For each generated UI element, make it function
	local function _connectSettingsSwitches()
		-- for _, setting in pairs(self._mainFrame.SettingsListFrame:GetChildren()) do
		-- 	if setting.Name ~= "UIListLayout" and setting.SettingType.Value == "Slider" then
		-- 		self._connectionManager:ConnectToEvent(setting.Button.MouseButton1Click, function()
		-- 			if self._settingState == true then --switch off
		-- 				self._settingState = false --TODO: Make this read from self._settingsTable
		-- 				setting.OffBG.Visible = true
		-- 				setting.OnBG.Visible = false
		-- 				--self:ChangeSetting(0, "SettingName")

		-- 				local tweenOff = TweenService:Create(setting.Slider, self._sliderEffectOffTweenInfo, {Position = UDim2.new(setting.SliderOffPosition.Position.X, setting.SliderOffPosition.Position.Y, setting.SliderOffPosition.Size.X, setting.SliderOffPosition.Size.Y)})
		-- 				tweenOff:Play()
		-- 				self._connectionManager:ConnectToEvent(tweenOff.Completed, function()
		-- 					tweenOff:Destroy()
		-- 				end)
		-- 			else --switch on
		-- 				self._settingState = true --TODO: Make this read from self._settingsTable
		-- 				setting.OffBG.Visible = false
		-- 				setting.OnBG.Visible = true
		-- 				--self:ChangeSetting(1, "SettingName")

		-- 				local tweenOn = TweenService:Create(setting.Slider, self._sliderEffectOnTweenInfo, {Position = UDim2.new(setting.SliderOnPosition.Position.X, setting.SliderOnPosition.Position.Y, setting.SliderOnPosition.Size.X, setting.SliderOnPosition.Size.Y)})
		-- 				tweenOn:Play()
		-- 				self._connectionManager:ConnectToEvent(tweenOn.Completed, function()
		-- 					tweenOn:Destroy()
		-- 				end)
		-- 			end
		-- 			--UIHelpers.PlaySoundByName("MenuClick", _SOUNDS_FOLDER)
		-- 		end)
		-- 	end
		-- end
	end

	--Handlers
	-- self._connectionManager:ConnectToEvent(self._menu.CloseButton.MouseButton1Click, function()
	-- 	self._mainFrame.Visible = false
	-- end)

	-- _createSettingsSwitches()
	-- _connectSettingsSwitches()
end

function _debounce(func)
	local isRunning = false
	return function(...)
		if not isRunning then
			isRunning = true

			func(...)

			isRunning = false
		end
	end
end

return {
	new = new
}
