--[[--<<---------------------------------------------------->>--
Module purpose: Handles the avatar backend

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
--local MarketplaceService = game:GetService("MarketplaceService")
--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--local ServerStorage = game:GetService("ServerStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local DataTypes = require(ServerScriptService.Data.DataTypes)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")

local AvatarManager = {}
AvatarManager.__index = AvatarManager

--[[**
	Creates new instance
**--]]
function new(dataManager, purchaseManager)
	local self = setmetatable({}, AvatarManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()
	self._dataManager = dataManager
	self._purchaseManager = purchaseManager

	self.LoadAvatarEvent = RemoteEvents:WaitForChild("LoadAvatar") :: RemoteEvent
	self.SaveAvatarEvent = RemoteEvents:WaitForChild("SaveAvatar") :: RemoteEvent

	self.LoadInventoryEvent = RemoteEvents:WaitForChild("LoadInventory") :: RemoteEvent
	self.SaveInventoryEvent = RemoteEvents:WaitForChild("SaveInventory") :: RemoteEvent

	_connectHandlers(self)

	return self
end

function AvatarManager:LoadAvatar(player: Player, data: DataTypes.DataTemplate)
	local outfit = data.currentOutfit
	RemoteEvents:WaitForChild("LoadAvatar"):FireClient(player, outfit)
end

function AvatarManager:LoadInventory(player: Player, data: DataTypes.DataTemplate)
	local inventory = data.inventory
	RemoteEvents:WaitForChild("LoadInventory"):FireClient(player, inventory)
end

function _connectHandlers(self)
	self._connectionManager:ConnectToEvent(self.SaveAvatarEvent.OnServerEvent, function(player: Player, outfit: DataTypes.Outfit)
		_saveAvatar(self, player, outfit)
	end)

	self._connectionManager:ConnectToEvent(BindableEvents.ProfileLoaded.Event, function(player: Player, data: DataTypes.DataTemplate)
		--TESTING
		--_giveItem(self, player, ItemsData.hats[1])
		AvatarManager:LoadAvatar(player, data)
		AvatarManager:LoadInventory(player, data)
	end)
end

function _giveItem(self, player: Player, item: DataTypes.InventoryItem)
	local inventory = self._dataManager.getKey(player, "inventory")
	table.insert(inventory[item.category], item)
	_saveInventory(self, player, inventory)
end

function _saveAvatar(self, player: Player, outfit: DataTypes.Outfit)
	local saved = self._dataManager.setKey(player, "currentOutfit", outfit)
	warn("Outfit data saved for", player.name, ":", saved)
end

function _saveInventory(self, player: Player, inventory: DataTypes.Inventory)
	local saved = self._dataManager.setKey(player, "inventory", inventory)
	warn("Inventory data saved for", player.name, ":", saved)
end

return {
	new = new
}