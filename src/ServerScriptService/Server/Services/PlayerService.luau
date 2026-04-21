-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Types
export type PlayerStat = {
	Water: number,
	Oxygen: number,
	Color: Color3,
}

-- Declarations
local ADJUSTMENT_VAL: number = 5
local DISTANCE: number = 5e7
local DEFAULT_COLOR: Color3 = Color3.new(0.835294, 0.45098, 0.239216)
local DEFAULT_WALKSPEED: number = 16
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100
local WATER_LEVEL: number = 28

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {
		ChangeOxygen = Knit.CreateSignal(),
		ChangeWater = Knit.CreateSignal(),
		UpdateColor = Knit.CreateSignal(),
	},
})
PlayerService.PlayerStats = {} :: { [Player]: PlayerStat }
PlayerService.PlayerTroves = {}

----- Private Functions -----
function PlayerService:_equipStats(pl: Player)
	pl:SetAttribute("Oxygen", MAX_OXYGEN)
	pl:SetAttribute("Water", MAX_WATER)
	pl:SetAttribute("Color", DEFAULT_COLOR)

	self.PlayerStats[pl] = {
		Water = MAX_WATER,
		Oxygen = MAX_OXYGEN,
		Color = DEFAULT_COLOR,
	}
end

function PlayerService:_getNearestBrick(pl: Player): BasePart
	local char = pl.Character
	local Distance = DISTANCE
	local Part = nil
	local hrp = char:WaitForChild("HumanoidRootPart")
	local drownSpots = workspace:WaitForChild("DrownSpots")

	for _, v in pairs(drownSpots:GetChildren()) do
		if v:IsA("BasePart") and (v.Name == "DrownSpot") then
			local Dis = (v.Position - hrp.Position).magnitude

			if Dis < Distance then
				Distance = Dis
				Part = v
			end
		end
	end

	return Part
end

function PlayerService:_drown(pl: Player)
	local drownSpot = self:_getNearestBrick(pl)

	local char = pl.Character
	char:MoveTo(drownSpot.Position)
	char.Humanoid.WalkSpeed = DEFAULT_WALKSPEED

	self.PlayerStats[pl].Oxygen = MAX_OXYGEN
	pl:SetAttribute("Oxygen", MAX_OXYGEN)
end

function PlayerService:_adjustStatsWhileUnderwater(pl: Player)
	local char = pl.Character
	if not char then
		return
	end

	local head = char:WaitForChild("Head")
	if not head then
		return
	end
	local currentOxygen = self.PlayerStats[pl].Oxygen

	if head.Position.Y < WATER_LEVEL then
		if currentOxygen > 0 then
			self:ChangeOxygen(pl, -ADJUSTMENT_VAL)
		end
		local currentWater = self.PlayerStats[pl].Water
		if currentWater < MAX_WATER then
			self:ChangeWater(pl, ADJUSTMENT_VAL)
		end
	elseif head.Position.Y > WATER_LEVEL and currentOxygen < MAX_OXYGEN then
		self:ChangeOxygen(pl, ADJUSTMENT_VAL)
	end
end

function PlayerService:_checkOxygen(pl: Player)
	local char = pl.Character
	if not char then
		return
	end

	if self.PlayerStats[pl].Oxygen <= 0 then
		local hum = char:FindFirstChild("Humanoid")
		hum.WalkSpeed = 0
		task.wait(3)
		self:_drown(pl)
	end
end

function PlayerService:GetPlayerStats(player: Player)
	return self.PlayerStats[player]
end

function PlayerService:ChangeOxygen(pl: Player, amt: number)
	local current = self.PlayerStats[pl].Oxygen
	local newVal = current + amt
	if newVal > MAX_OXYGEN then
		newVal = MAX_OXYGEN
	elseif newVal < 0 then
		newVal = 0
	end
	self.PlayerStats[pl].Oxygen = newVal
	pl:SetAttribute("Oxygen", newVal)
end

function PlayerService:ChangeWater(pl: Player, amt: number)
	local current = self.PlayerStats[pl].Water
	local newVal = current + amt
	if newVal > MAX_WATER then
		newVal = MAX_WATER
	elseif newVal < 0 then
		newVal = 0
	end
	self.PlayerStats[pl].Water = newVal
	pl:SetAttribute("Water", newVal)
end

function PlayerService:_updateColor(pl: Player, color: Color3)
	self.PlayerStats[pl].Color = color
	pl:SetAttribute("Color", color)

	for _, v in pairs(pl.Backpack:GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChild("Customizable") then
			v.Handle.Color = color
		end
	end

	if pl.Character then
		for _, v in pairs(pl.Character:GetChildren()) do
			if v:IsA("Tool") and v:FindFirstChild("Customizable") then
				v.Handle.Color = color
			end
		end
	end
end

function PlayerService:_characterAdded(player: Player)
	self:_equipStats(player)
end

function PlayerService:_playerAdded(player: Player)
	self.PlayerTroves[player] = Trove.new()
	self.PlayerTroves[player]:Connect(player.CharacterAdded, function()
		self:_characterAdded(player)
	end)
	local task = task.defer(function()
		while task.wait(1) do
			self:_checkOxygen(player)
			self:_adjustStatsWhileUnderwater(player)
		end
	end)
	self.PlayerTroves[player]:Add(task)
end

----- Client Methods -----
function PlayerService.Client:UpdateColor(pl: Player, color: Color3)
	self.Server:_updateColor(pl, color)
end

----- Initialize -----
function PlayerService:KnitStart()
	Players.PlayerAdded:Connect(function(pl: Player)
		self:_playerAdded(pl)
	end)

	Players.PlayerRemoving:Connect(function(pl: Player)
		if self.PlayerTroves[pl] then
			self.PlayerTroves[pl]:Destroy()
		end
		if self.PlayerStats[pl] then
			self.PlayerStats[pl] = nil
		end
	end)
end

function PlayerService:KnitInit()
	for _, pl in Players:GetPlayers() do
		task.defer(function()
			self._characterAdded(pl)
		end)
	end
end

return PlayerService
