--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
-- local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Data
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

local CabanaComponent = require(ServerScriptService.Server.Components.CabanaComponent)

local DataService
local MarketService

local CabanaService = Knit.CreateService({
	Name = "CabanaService",
	Client = {
		UpdatedCabanaSettings = Knit.CreateSignal(),
	},
})
CabanaService.Cabanas = {}
CabanaService.PlayersWithRentalPass = {}
CabanaService.CabanaFolder = nil :: Folder?
CabanaService._trove = Trove.new()

function CabanaService:_clearCabana(cabana: Instance, index: number)
	cabana:SetAttribute("Owner", "")
	cabana:SetAttribute("Rented", false)
	cabana:SetAttribute("Index", index)
end

function CabanaService:ClearAllCabanaRentals()
	table.clear(self._cabanas)
	for i, cabanaModel in ipairs(self.CabanaFolder:GetChildren()) do
		self:_clearCabana(cabanaModel, i)
	end
end

function CabanaService:ClearCabanaRental(player: Player)
	for i, cabanaModel in pairs(self.CabanaFolder:GetChildren()) do
		if cabanaModel:GetAttribute("Owner") == player.Name then
			self:_clearCabana(cabanaModel, i)
		end
	end
end

function CabanaService:InitializeCabanas()
	for _, cabanaModel in pairs(self.CabanaFolder:GetChildren()) do
		local componentInstance = CabanaComponent:FromInstance(cabanaModel)
		if componentInstance then
			table.insert(self._cabanas, {
				owner = "",
				cabanaBuilding = cabanaModel,
				index = cabanaModel:GetAttribute("Index"),
				cabanaInstance = componentInstance,
			})
		end
	end
end

function CabanaService:RentCabana(player: Player, cabana: Instance)
	local owner = cabana:GetAttribute("Owner")
	if owner and owner ~= "" and owner ~= player.Name then
		warn(owner, "already rented this cabana")
	end

	cabana:SetAttribute("Owner", player.Name)
	cabana:SetAttribute("Rented", true)

	local settings = DataService:GetKey(player, "cabanaSettings")
	self.Client.UpdatedCabanaSettings:Fire(player, settings)
end

function CabanaService.Client:GetLastCabanaRentalTime(player: Player)
	local ret = DataService:GetKey(player, "cabanaRentalTime")
	return ret
end

function CabanaService.Client:RequestCabanaRental(player: Player, cabana: Instance)
	self.Server:RentCabana(player, cabana)
end

function CabanaService.Client:SaveCabanaSettings(player: Player, settings: SharedSettings.cabanaSettings)
	DataService:SetKey(player, "cabanaSettings", settings)
end

function CabanaService:KnitStart()
	DataService = Knit.GetService("DataService")
	MarketService = Knit.GetService("MarketService")
	self:InitializeCabanas()

	self._trove:Connect(Players.PlayerRemoving, function(player: Player)
		self:ClearCabanaRental(player)
	end)

	self._trove:Connect(MarketService.PurchaseGranted, function(player: Player, itemName: string)
		if itemName == "Cabana" then
			table.insert(self.PlayersWithRentalPass, player.UserId)
		end
	end)
end

function CabanaService:KnitInit()
	self.CabanaFolder = workspace:FindFirstChild("Cabanas") :: Folder
end

return CabanaService
