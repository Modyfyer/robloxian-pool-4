--[[--<<---------------------------------------------------->>--
Module purpose: Determines what platform a player is using (console, desktop, or mobile)

Public Functions:
-GetCurrentPlatformType

Initialized by: ClientInit

--]]--<<---------------------------------------------------->>--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Event = require(ReplicatedStorage.Utils.Event)
local PlatformType = require(script.PlatformType)

local _USER_INPUT_TYPES_BY_PLATFORM_TYPE = {
	[PlatformType.Console] = {
		Enum.UserInputType.Gamepad1,
		Enum.UserInputType.Gamepad2,
		Enum.UserInputType.Gamepad3,
		Enum.UserInputType.Gamepad4,
		Enum.UserInputType.Gamepad5,
		Enum.UserInputType.Gamepad6,
		Enum.UserInputType.Gamepad7,
		Enum.UserInputType.Gamepad8,
	},
	[PlatformType.Desktop] = {
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.MouseButton2,
		Enum.UserInputType.MouseButton3,
		Enum.UserInputType.MouseWheel,
		Enum.UserInputType.MouseMovement,
		Enum.UserInputType.Keyboard,
	},
	[PlatformType.Mobile] = {
		Enum.UserInputType.Touch,
	},
}

local _IS_TESTING_TOUCH = false

local PlatformDetectionManager = {}
PlatformDetectionManager.__index = PlatformDetectionManager


--[[**
	Creates a new instance

	@returns The new instance
**--]]

function new()
	local self = setmetatable({}, PlatformDetectionManager)

	self._detectedPlatformType = nil

	self.DetectedPlatformTypeChanged = Event.new()

	_connectHandlers(self)

	return self
end

--[[**
	Gets the current user platform

	@returns The current user platform (console, mobile, or desktop)
**--]]

function PlatformDetectionManager:GetCurrentPlatformType()
	if RunService:IsStudio() and _IS_TESTING_TOUCH then
		return PlatformType.Mobile
	end

	if not self._detectedPlatformType then
		if UserInputService.GamepadEnabled then
			_updateDetectedPlatformType(self, PlatformType.Console)
		elseif UserInputService.TouchEnabled then
			_updateDetectedPlatformType(self, PlatformType.Mobile)
		else
			_updateDetectedPlatformType(self, PlatformType.Desktop)
		end
	end

	return self._detectedPlatformType
end

--Private methods
function _connectHandlers(self)
	local function onLastInputTypeChanged(inputType)
		for platformType, userInputTypes in pairs(_USER_INPUT_TYPES_BY_PLATFORM_TYPE) do
			if _inputTypeIsInList(inputType, userInputTypes) then
				_updateDetectedPlatformType(self, platformType)
				break
			end
		end
	end

	UserInputService.LastInputTypeChanged:Connect(onLastInputTypeChanged)
end

function _inputTypeIsInList(inputType, matchingInputTypes)
	for _, v in pairs(matchingInputTypes) do
		if inputType == v then
			return true
		end
	end

	return false
end

function _updateDetectedPlatformType(self, detectedPlatformType)
	if RunService:IsStudio() and _IS_TESTING_TOUCH then
		return
	end

	if self._detectedPlatformType == detectedPlatformType then
		return
	end

	local oldPlatformType = self._detectedPlatformType
	self._detectedPlatformType = detectedPlatformType
	self.DetectedPlatformTypeChanged:Fire(detectedPlatformType, oldPlatformType)
end

return {
	new = new
}
