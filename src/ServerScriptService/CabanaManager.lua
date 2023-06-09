--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)

local CabanaManager = {}
CabanaManager.__index = CabanaManager

--[[**
	Creates new instance
**--]]
function new()
	local self = setmetatable({}, CabanaManager)

	-- Dependency group 0
	local connectionManager = ConnectionManager.new()

	-- Dependency group 1
	self._connectionManager = connectionManager

	self._cabanas = {}
	self._productFunctions = {}
	self._purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

	self.CabanaFolder = workspace.Cabanas

	self:InitializeCabanas()

	return self
end

function CabanaManager:ClearAllCabanaRentals()
	table.clear(self._cabanas)
	for i, cabana in ipairs(self.CabanaFolder:GetChildren()) do
		cabana:SetAttribute("Owner", "")
		cabana:SetAttribute("Rented", false)
		cabana:SetAttribute("Index", i)
	end
end

function CabanaManager:InitializeCabanas()
	for _, cabanaModel in pairs(self.CabanaFolder:GetChildren()) do
		if cabanaModel.Name == "Cabana" then
			table.insert(self._cabanas, {owner = "", cabanaBuilding = cabanaModel, index = cabanaModel:GetAttribute("Index")})
		end
	end
end

function CabanaManager:RentCabana(player: Player, cabana: Instance)
	for _, v in pairs(self._cabanas) do
		if v.cabanaBuilding == cabana then
			warn(v.owner, "already rented this cabana")
			return false
		end
	end

	cabana:SetAttribute("Owner", player.Name)
	cabana:SetAttribute("Rented", true)

	return true
end

function _processReceipt(receiptInfo)
		-- Determine if the product was already granted by checking the data store
		local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
		local purchased = false

		local success, result, errorMessage
		success, errorMessage = pcall(function()
			purchased = CabanaManager._purchaseHistoryStore:GetAsync(playerProductKey)
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
			return CabanaManager._purchaseHistoryStore:UpdateAsync(playerProductKey, function(alreadyPurchased)
				if alreadyPurchased then
					return true
				end
				-- Find the player who made the purchase in the server

				local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
				if not player then
					-- The player probably left the game
					-- If they come back, the callback will be called again
					return nil
				end

				local handler = CabanaManager._productFunctions[receiptInfo.ProductId]

				success, result = pcall(handler, receiptInfo, player)

				-- If granting the product failed, do NOT record the purchase in datastores.
				if not success or not result then
					error("Failed to process a product purchase for ProductId: " .. tostring(receiptInfo.ProductId) .. " Player: " .. tostring(player) .. " Error: " .. tostring(result))
					return nil
				end
				-- Record the transcation in purchaseHistoryStore.
				return true
			end)
		end)

		if not success then
			error("Failed to process receipt due to data store error.")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		elseif isPurchaseRecorded == nil then
			-- Didn't update the value in data store.
			return Enum.ProductPurchaseDecision.NotProcessedYet
		else
			-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
end

MarketplaceService.ProcessReceipt = _processReceipt

return {
	new = new
}