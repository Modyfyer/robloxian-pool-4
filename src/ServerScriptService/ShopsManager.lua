--[[--<<---------------------------------------------------->>--
Module purpose: Handles the shops

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
--local ItemsData = require(ReplicatedStorage.Data.ItemsData)

--Declarations
-- local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
--local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
-- local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")

local ShopsManager = {}
ShopsManager.__index = ShopsManager

--[[**
	Creates new instance
**--]]
function new(dataManager, purchaseManager)
	local self = setmetatable({}, ShopsManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()
	self._dataManager = dataManager
	self._purchaseManager = purchaseManager

	_connectHandlers(self)

	return self
end

function _connectHandlers(self)
	print(self)
	-- self._connectionManager:ConnectToEvent(RemoteEvents.UpdateShops.OnServerEvent, function(player: Player)
	-- 	RemoteEvents.UpdateShops:FireClient(player, ItemsData)
	-- end)
end

return {
	new = new
}