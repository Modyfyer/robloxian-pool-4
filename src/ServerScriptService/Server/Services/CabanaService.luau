--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Data
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

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

	local roof = cabana:FindFirstChild("Roof")
	assert(roof, "Unable to clear cabana: cannot find roof")

	local statusGui = roof:FindFirstChild("RentalStatusGui") :: GuiObject

	local label = statusGui:WaitForChild("Frame"):WaitForChild("TextLabel") :: TextLabel
	label.Text = "RENT THIS CABANA"

	local floor = cabana:FindFirstChild("Floor") :: Instance
	local proxPrompt = floor:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
	proxPrompt.ActionText = "Rent Cabana"
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
		if cabanaModel.Name == "Cabana" then
			table.insert(
				self._cabanas,
				{ owner = "", cabanaBuilding = cabanaModel, index = cabanaModel:GetAttribute("Index") }
			)
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

	-- local settings = self._dataManager.getKey(player, "cabanaSettings")
	-- self.Client.UpdatedCabanaSettings:Fire(player, settings)
end

function CabanaService.Client:GetLastCabanaRentalTime(player: Player)
	-- local rentalTime = self._dataManager.getKey(player, "cabanaRentalTime")
	-- return rentalTime
end

function CabanaService.Client:RequestCabanaRental(player: Player, cabana: Instance)
	self:RentCabana(player, cabana)
end

function CabanaService.Client:SaveCabanaSettings(player: Player, settings: SharedSettings.cabanaSettings)
	--local saved = self._dataManager.setKey(player, "cabanaSettings", settings)
	--warn("Data saved for", player.Name, ":", saved)
end

function CabanaService:KnitStart()
	self:InitializeCabanas()

	self._trove:Connect(Players.PlayerRemoving, function(player: Player)
		self:ClearCabanaRental(player)
	end)

	-- self._connectionManager:ConnectToEvent(PurchaseService.CabanaRented.Event, function(player: Player)
	-- 	table.insert(self._playersWithRentalPass, player.UserId)
	-- end)
end

function CabanaService:KnitInit()
	self.CabanaFolder = workspace:FindFirstChild("Cabanas") :: Folder
end

return CabanaService
