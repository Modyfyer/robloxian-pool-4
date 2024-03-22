--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)
local ItemsData = require(ReplicatedStorage.Data.ItemsData)
local ItemType = require(ReplicatedStorage.Enums.ItemType)

--Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

local CabanaManager = {}
CabanaManager.__index = CabanaManager

--[[**
	Creates new instance
**--]]
function new(purchaseManager)
	local self = setmetatable({}, CabanaManager)

	-- Dependency group 0
	self._connectionManager = ConnectionManager.new()
	self._purchaseManager = purchaseManager

	self._cabanas = {}
	self._playersWithRentalPass = {}
	self._productFunctions = {}

	self.CabanaFolder = workspace.Cabanas

	self:InitializeCabanas()

	_connectHandlers(self)

	return self
end

function CabanaManager:ClearAllCabanaRentals()
	table.clear(self._cabanas)
	for i, cabana in ipairs(self.CabanaFolder:GetChildren()) do
		cabana:SetAttribute("Owner", "")
		cabana:SetAttribute("Rented", false)
		cabana:SetAttribute("Index", i)

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
end

function CabanaManager:InitializeCabanas()
	for _, cabanaModel in pairs(self.CabanaFolder:GetChildren()) do
		if cabanaModel.Name == "Cabana" then
			table.insert(self._cabanas, {owner = "", cabanaBuilding = cabanaModel, index = cabanaModel:GetAttribute("Index")})
		end
	end
end

function CabanaManager:RentCabana(player: Player, cabana: Instance): boolean
	if not table.find(self._playersWithRentalPass, player) then
		warn(player.Name, "does not have the cabana rental pass")
		return false
	end
	-- for _, v in pairs(self._cabanas) do
	-- 	if v.cabanaBuilding == cabana then
	-- 		warn(v.owner, "already rented this cabana")
	-- 		return false
	-- 	end
	-- end

	local owner = cabana:GetAttribute("Owner")
	if owner and owner ~= "" and owner ~= player.Name then
		warn(owner, "already rented this cabana")
		return false
	end

	cabana:SetAttribute("Owner", player.Name)
	cabana:SetAttribute("Rented", true)

	return true
end

function _connectHandlers(self)
	self._connectionManager:ConnectToEvent(RemoteEvents.RentCabana.OnServerEvent, function(player, cabana)
		local rentResult = self:RentCabana(player, cabana)
		if rentResult then
			print("rented")
		else
			print("not rented")
		end
	end)

	self._connectionManager:ConnectToEvent(self._purchaseManager.CabanaRented, function(player)
		table.insert(self._playersWithRentalPass, player)
	end)
end

return {
	new = new
}