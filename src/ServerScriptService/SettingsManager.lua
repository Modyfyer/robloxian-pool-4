--[[--<<---------------------------------------------------->>--
Module purpose: Handles player settings

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

local SettingsManager = {}
SettingsManager.__index = SettingsManager

--[[**
	Creates new instance
**--]]
function new(dataManager)
	local self = setmetatable({}, SettingsManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()
	self._dataManager = dataManager
	
	self.SaveSettingsEvent = RemoteEvents:WaitForChild("SaveHUDSettings")

	_connectHandlers(self)

	return self
end

function SettingsManager:LoadSettings(player: Player, data)
	--local settings = self._dataManager.getKey(player, "settings")
	local settings = data.settings
	local loadSettingsEvent = RemoteEvents:WaitForChild("LoadHUDSettings")
	loadSettingsEvent:FireClient(player, settings)
end

function _connectHandlers(self)
	self._connectionManager:ConnectToEvent(self.SaveSettingsEvent.OnServerEvent, function(player: Player, settings: SharedSettings.hudSettings)
		local saved = self._dataManager.setKey(player, "settings", settings)
		warn("Data saved for", player.name, ":", saved)
	end)

	self._connectionManager:ConnectToEvent(BindableEvents.ProfileLoaded.Event, function(player: Player, data)
		SettingsManager:LoadSettings(player, data)
	end)
end

return {
	new = new
}