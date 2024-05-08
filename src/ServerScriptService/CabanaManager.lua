--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Constants
local SECONDS_IN_DAY: number = 86400

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions: Folder = ReplicatedStorage:WaitForChild("RemoteFunctions")
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

local CabanaManager = {}
CabanaManager.__index = CabanaManager

--[[**
	Creates new instance
**--]]
function new(dataManager, purchaseManager)
	local self = setmetatable({}, CabanaManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()
	self._dataManager = dataManager
	self._purchaseManager = purchaseManager

	self._cabanas = {}
	self._playersWithRentalPass = {}

	local folder: Folder = workspace.Cabanas
	self.CabanaFolder = folder

	self:InitializeCabanas()

	_connectHandlers(self)

	return self
end

function CabanaManager:ClearAllCabanaRentals()
	table.clear(self._cabanas)
	for i, cabanaModel in ipairs(self.CabanaFolder:GetChildren()) do
		_clearCabana(cabanaModel, i)
	end
end

function CabanaManager:ClearCabanaRental(player: Player)
	for i, cabanaModel in pairs(self.CabanaFolder:GetChildren()) do
		if cabanaModel:GetAttribute("Owner") == player.Name then
			_clearCabana(cabanaModel, i)
		end
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
	-- local canRent: boolean = false
	-- -- for _, pl: number in pairs(self._playersWithRentalPass) do
	-- -- 	if pl == player.UserId then
	-- -- 		canRent = true
	-- -- 	end
	-- -- end

	-- local function _isCabanaAlreadyRented(rentalTime: string): boolean
	-- 	local rentalDT: DateTime? = DateTime.fromIsoDate(rentalTime)
	
	-- 	if rentalDT then
	-- 		local rentalTimestamp = rentalDT.UnixTimestamp
	-- 		local now = DateTime.now().UnixTimestamp
	-- 		if (now - rentalTimestamp) > SECONDS_IN_DAY then --it's been >24h since the rental pass was purchased
	-- 			return false
	-- 		else --the rental is still valid
	-- 			return true
	-- 		end
	-- 	else --no rental time could be parsed
	-- 		return false
	-- 	end
	-- end

	-- local rentalTime: string? = self._dataManager.getKey(player, "cabanaRentalTime")
	-- if rentalTime then
	-- 	if _isCabanaAlreadyRented(rentalTime) then
	-- 		canRent = true
	-- 	end
	-- end

	-- print(canRent)

	local owner = cabana:GetAttribute("Owner")
	if owner and owner ~= "" and owner ~= player.Name then
		warn(owner, "already rented this cabana")
	end

	cabana:SetAttribute("Owner", player.Name)
	cabana:SetAttribute("Rented", true)

	local settings = self._dataManager.getKey(player, "cabanaSettings")
	RemoteEvents.LoadCabanaSettings:FireClient(player, settings)
end

function _clearCabana(cabana: Instance, index: number)
	cabana:SetAttribute("Owner", "")
	cabana:SetAttribute("Rented", false)
	cabana:SetAttribute("Index", index)

	local roof = cabana:FindFirstChild("Roof")
	if roof then
		local statusGui = roof:FindFirstChild("RentalStatusGui")
		if statusGui then
			local label = statusGui:WaitForChild("Frame"):WaitForChild("TextLabel")
			if label then
				label.Text = "RENT THIS CABANA"
			end
		end
	end

	local floor = cabana:FindFirstChild("Floor")
	if floor then
		local proxPrompt = floor:FindFirstChildOfClass("ProximityPrompt")
		if proxPrompt then
			proxPrompt.ActionText = "Rent Cabana"
		end
	end
end

function _connectHandlers(self)
	self._connectionManager:ConnectToEvent(RemoteEvents.RentCabana.OnServerEvent, function(player: Player, cabana: Instance)
		self:RentCabana(player, cabana)
	end)

	self._connectionManager:ConnectToEvent(BindableEvents.CabanaRented.Event, function(player: Player)
		table.insert(self._playersWithRentalPass, player.UserId)
	end)
	self._connectionManager:ConnectToEvent(RemoteEvents.SaveCabanaSettings.OnServerEvent, function(player: Player, settings: SharedSettings.cabanaSettings)
		local saved = self._dataManager.setKey(player, "cabanaSettings", settings)
		warn("Data saved for", player.name, ":", saved)
	end)

	self._connectionManager:ConnectToEvent(Players.PlayerRemoving, function(player: Player)
		self:ClearCabanaRental(player)
	end)

	local function getCabanaRentalTime(player: Player)
		local rentalTime = self._dataManager.getKey(player, "cabanaRentalTime")
		return rentalTime
	end

	RemoteFunctions.GetLastCabanaRentalTime.OnServerInvoke = getCabanaRentalTime
end

return {
	new = new
}