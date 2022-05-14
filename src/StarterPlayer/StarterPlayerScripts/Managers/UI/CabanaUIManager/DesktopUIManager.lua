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

local _SOUNDS_FOLDER

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

	self._mainFrame = screenGui:WaitForChild("Desktop")

	_connectHandlers(self)

	return self
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

--[[**
	Clears UI and object values
**--]]
function UIManager:Clear()
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

--[[ Private functions ]]--

function _connectHandlers(_)
	--Button mouse over
	-- local function onButtonMouseOver()
	-- 	UIHelpers.PlaySoundByName("ButtonMouseOver", _SOUNDS_FOLDER)
	-- end
end
return {
	new = new
}

