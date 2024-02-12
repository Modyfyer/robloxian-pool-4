--[[--<<---------------------------------------------------->>--
Module purpose: Handles in-game purchases

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local Event = require(ReplicatedStorage.Utils.Event)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)
local ItemType = require(ReplicatedStorage.Enums.ItemType)

--Declarations
local ProductFunctions = {}
local PurchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local LIFEGUARD_GAMEPASS_ID = 703084245

local PurchaseManager = {}
PurchaseManager.__index = PurchaseManager

--[[**
	Creates new instance
**--]]
function new()
	local self = setmetatable({}, PurchaseManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()

    self.CabanaRented = Event.new()
	self.LifeguardEnabled = Event.new()

    ProductFunctions[ItemsData.Items[ItemType.Rental].DeveloperProductId] = function(_receipt, player)
        self.CabanaRented:Fire(player)
        return true
    end

	ProductFunctions[LIFEGUARD_GAMEPASS_ID] = function(_receipt, player)
        self.LifeguardEnabled:Fire(player)
        return true
    end

	return self
end

--[[**
	Processes purchases and returns the purchase result

	@returns Enum.ProductPurchaseDecision
**--]]
function _processReceipt(receiptInfo)
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false

	local success, result, errorMessage
	success, errorMessage = pcall(function()
		purchased = PurchaseHistoryStore:GetAsync(playerProductKey)
	end)

	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end

	-- Determine if the product was already granted by checking the data store
	playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId

	local _, isPurchaseRecorded = pcall(function()
		return PurchaseHistoryStore:UpdateAsync(playerProductKey, function(alreadyPurchased)
			if alreadyPurchased then
				return true
			end

			local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
			if not player then
				return nil
			end

			local handler = ProductFunctions[receiptInfo.ProductId]

			success, result = pcall(handler, receiptInfo, player)

			-- If granting the product failed, do NOT record the purchase in datastores.
			if not success or not result then
				error("Failed to process a product purchase for ProductId: " .. tostring(receiptInfo.ProductId) .. " Player: " .. tostring(player) .. " Error: " .. tostring(result))
				return nil
			end

			-- Record the transaction in purchaseHistoryStore.
			return true
		end)
	end)

	if not success then
		error("Failed to process receipt due to data store error.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif isPurchaseRecorded == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

MarketplaceService.ProcessReceipt = _processReceipt

return {
	new = new
}