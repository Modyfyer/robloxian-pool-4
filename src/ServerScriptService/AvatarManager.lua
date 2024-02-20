--[[--<<---------------------------------------------------->>--
Module purpose: Handles the avatar backend

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)
local ItemType = require(ReplicatedStorage.Enums.ItemType)

--Declarations
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local AvatarManager = {}
AvatarManager.__index = AvatarManager

--[[**
	Creates new instance
**--]]
function new(purchaseManager)
	local self = setmetatable({}, AvatarManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()
	self._purchaseManager = purchaseManager

	_connectHandlers(self)

	return self
end

function _connectHandlers(self)
end

return {
	new = new
}