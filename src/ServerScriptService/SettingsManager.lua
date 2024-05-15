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

	return self
end

return {
	new = new
}