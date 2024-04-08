--[[--<<---------------------------------------------------->>--
Module purpose: Handles in-game purchases

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager).new()
local DataTypes = require(script.Parent.DataTypes)
local Event = require(ReplicatedStorage.Utils.Event)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local DataManager = nil

local PurchaseManager = {}
PurchaseManager.CabanaRented = Event.new()
PurchaseManager.Products = {}
PurchaseManager.Settings = {}

function PurchaseManager:PurchaseIdCheckAsync(profile, purchase_id, receipt_info, grant_product_callback) --> Enum.ProductPurchaseDecision
	-- Yields until the purchase_id is confirmed to be saved to the profile or the profile is released
	if profile:IsActive() ~= true then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		local meta_data = profile.MetaData

		local local_purchase_ids = meta_data.MetaTags.ProfilePurchaseIds
		if local_purchase_ids == nil then
			local_purchase_ids = {}
			meta_data.MetaTags.ProfilePurchaseIds = local_purchase_ids
		end

		local dt = DateTime.now()
		table.insert(profile.Data.purchases, {
			purchaseID = purchase_id,
			productID = receipt_info.ProductId,
			itemCost = receipt_info.CurrencySpent,
			purchaseDate = dt:FormatUniversalTime("LL", "en-us")
		})

		-- Granting product if not received:
		if table.find(local_purchase_ids, purchase_id) == nil then
			while #local_purchase_ids >= PurchaseManager.Settings.PurchaseIDLog do
				table.remove(local_purchase_ids, 1)
			end
			table.insert(local_purchase_ids, purchase_id)
			task.spawn(grant_product_callback)
		end

		-- Waiting until the purchase is confirmed to be saved:
		local result = nil

		local function check_latest_meta_tags()
			local saved_purchase_ids = meta_data.MetaTagsLatest.ProfilePurchaseIds
			if saved_purchase_ids ~= nil and table.find(saved_purchase_ids, purchase_id) ~= nil then
				result = Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		check_latest_meta_tags()

		local release_connection = profile:ListenToRelease(function()
			result = result or Enum.ProductPurchaseDecision.NotProcessedYet
		end)
		local meta_tags_connection = profile.MetaTagsUpdated:Connect(function()
			check_latest_meta_tags()
		end)
		while result == nil do
			RunService.Heartbeat:Wait()
		end
		release_connection:Disconnect()
		meta_tags_connection:Disconnect()

		return result
	end
end

-- We shouldn't yield during the product granting process!
function PurchaseManager:GrantProduct(player: Player, product_id: number | string)
    local profile = DataManager.getProfile(player)
    local product_function = PurchaseManager.Products[product_id]
    if product_function ~= nil then
        product_function(profile)
    else
        warn("ProductId " .. tostring(product_id) .. " has not been defined in Products table")
    end
end

----- Initialize -----
function PurchaseManager.new(dataManager)
	DataManager = dataManager

	PurchaseManager.Products[1555280575] = function(profile)
		local now = DateTime.now()
		profile.Data.cabanaRentalTime = now:FormatUniversalTime("YYYY HH:mm:ss", "en-us")
		PurchaseManager.CabanaRented:Fire()
		return true
	end

	PurchaseManager.Settings = {
		PurchaseIDLog = 50
	}
end

function PurchaseManager.ProcessReceipt(receipt_info)
	local player = Players:GetPlayerByUserId(receipt_info.PlayerId)

	if player == nil then
		warn("Unable to process receipt: Player is nil")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = DataManager.getProfile(player)
	if profile ~= nil then
		return PurchaseManager:PurchaseIdCheckAsync(
			profile,
			receipt_info.PurchaseId,
			receipt_info,
			function()
				PurchaseManager:GrantProduct(player, receipt_info.ProductId)
			end
		)
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	PurchaseManager.ProcessReceipt(receiptInfo)
end

return PurchaseManager