-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
--local DataTypes = require(ServerScriptService.Data.DataTypes)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Declarations
local MarketService = Knit.CreateService({
	Name = "MarketService",
	Client = {
		PurchaseGranted = Knit.CreateSignal(),
	},
	PurchaseGranted = Signal.new(),
	Products = {},
	Settings = {},
})

local DataService = nil

----- Private Functions -----
function MarketService:_purchaseIdCheckAsync(profile, purchase_id, receipt_info, grant_product_callback)
	-- Yields until the purchase_id is confirmed to be saved to the profile or the profile is released
	if not profile:IsActive() then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local meta_data = profile.MetaData
	local local_purchase_ids = meta_data.MetaTags.ProfilePurchaseIds
	if not local_purchase_ids then
		local_purchase_ids = {}
		meta_data.MetaTags.ProfilePurchaseIds = local_purchase_ids
	end

	local dt = DateTime.now()
	table.insert(profile.Data.purchases, {
		purchaseID = purchase_id,
		productID = receipt_info.ProductId,
		itemCost = receipt_info.CurrencySpent,
		purchaseDate = dt:ToIsoDate(),
	})

	-- Granting product if not received:
	if table.find(local_purchase_ids, purchase_id) == nil then
		while #local_purchase_ids >= self.Settings.PurchaseIDLog do
			table.remove(local_purchase_ids, 1)
		end
		table.insert(local_purchase_ids, purchase_id)
		task.spawn(grant_product_callback)
	end

	-- Waiting until the purchase is confirmed to be saved:
	local result = nil

	local function check_latest_meta_tags()
		local saved_purchase_ids = meta_data.MetaTagsLatest.ProfilePurchaseIds
		if saved_purchase_ids and table.find(saved_purchase_ids, purchase_id) then
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

function MarketService:_grantProduct(player: Player, product_id: number | string)
	local profile = DataService:GetProfile(player)
	local product_function = self.Products[product_id]
	if product_function then
		product_function(profile, player)
	else
		warn("ProductId " .. tostring(product_id) .. " has not been defined in Products table")
	end
end

----- Public Functions -----
function MarketService:ProcessReceipt(receipt_info)
	local player = Players:GetPlayerByUserId(receipt_info.PlayerId)

	if not player then
		warn("Unable to process receipt: Player is nil")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = DataService:GetProfile(player)
	if profile then
		return self:_purchaseIdCheckAsync(profile, receipt_info.PurchaseId, receipt_info, function()
			self:_grantProduct(player, receipt_info.ProductId)
		end)
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

----- Initialize -----
function MarketService:KnitInit()
	DataService = Knit.GetService("DataService")

	self.Products[1555280575] = function(profile, player: Player)
		local now: DateTime = DateTime.now()
		profile.Data.cabanaRentalTime = now:ToIsoDate()
		self.PurchaseGranted:Fire(player, "Cabana")
		self.Client.PurchaseGranted:Fire(player, "Cabana")
		return true
	end

	self.Settings = {
		PurchaseIDLog = 50,
	}

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return self:ProcessReceipt(receiptInfo)
	end
end

function MarketService:KnitStart()
	-- No additional startup needed
end

return MarketService
