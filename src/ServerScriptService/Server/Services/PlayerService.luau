local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {
		ChangeOxygen = Knit.CreateSignal(),
		ChangeWater = Knit.CreateSignal(),
		UpdateColor = Knit.CreateSignal(),
	},
})

local DEFAULT_COLOR: Color3 = Color3.new(0.835294, 0.45098, 0.239216)
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100

----- Private Functions -----
function PlayerService:_equipStats(pl)
	pl:SetAttribute("Oxygen", MAX_OXYGEN)
	pl:SetAttribute("Water", MAX_WATER)
	pl:SetAttribute("Color", DEFAULT_COLOR)
end

function PlayerService:_getNearestBrick(pl)
	local Distance = 5e7
	local Part = nil
	local hrp = pl.Character:WaitForChild("HumanoidRootPart")
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

function PlayerService:_drown(pl)
	local drownSpot = self:_getNearestBrick(pl)
	pl.Character:MoveTo(drownSpot.Position)
	pl:SetAttribute("Oxygen", MAX_OXYGEN)
	pl.Character.Humanoid.WalkSpeed = 16
end

function PlayerService:_doOxygen(pl)
	task.spawn(function()
		local function checkOxygen()
			local oxy = pl:GetAttribute("Oxygen")
			if oxy <= 0 then
				local hum = pl.Character:FindFirstChild("Humanoid")
				hum.WalkSpeed = 0
				task.wait(3)
				self:_drown(pl)
			end
		end

		pl.AttributeChanged:Connect(function(attr)
			if attr == "Oxygen" then
				checkOxygen()
			end
		end)

		checkOxygen()
	end)
end

function PlayerService:_changeOxygen(pl: Player, amt: number)
	local current = pl:GetAttribute("Oxygen") or 0
	local newVal = current + amt
	if newVal > MAX_OXYGEN then
		newVal = MAX_OXYGEN
	elseif newVal < 0 then
		newVal = 0
	end
	pl:SetAttribute("Oxygen", newVal)
end

function PlayerService:_changeWater(pl: Player, amt: number)
	local current = pl:GetAttribute("Water") or 0
	local newVal = current + amt
	if newVal > MAX_WATER then
		newVal = MAX_WATER
	elseif newVal < 0 then
		newVal = 0
	end
	pl:SetAttribute("Water", newVal)
end

function PlayerService:_updateColor(pl: Player, color)
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
	self:_doOxygen(player)
end

----- Client Methods -----
function PlayerService.Client:ChangeOxygen(pl, amt)
	self.Server:_changeOxygen(pl, amt)
end

function PlayerService.Client:ChangeWater(pl, amt)
	self.Server:_changeWater(pl, amt)
end

function PlayerService.Client:UpdateColor(pl, color)
	self.Server:_updateColor(pl, color)
end

----- Initialize -----
function PlayerService:KnitStart()
	Players.PlayerAdded:Connect(function(pl)
		pl.CharacterAdded:Connect(function()
			self:_characterAdded(pl)
		end)
	end)
end

function PlayerService:KnitInit()
	for _, pl in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			if pl.Character then
				self:_characterAdded(pl)
			end
			pl.CharacterAdded:Connect(function()
				self:_characterAdded(pl)
			end)
		end)
	end
end

return PlayerService
