local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ADJUSTMENT_VAL: number = 5
local MAX_VAL: number = 100
local WATER_LEVEL: number = 28

local PlayerController = Knit.CreateController({
	Name = "PlayerController",
})

function PlayerController:KnitInit() end

function PlayerController:KnitStart()
	local PlayerService = Knit.GetService("PlayerService")
	local pl = Knit.Player
	self.currentTask = nil

	local function setupCharacter(ch)
		if self.currentTask then
			task.cancel(self.currentTask)
		end

		local head = ch:WaitForChild("Head")

		self.currentTask = task.spawn(function()
			while task.wait(1) do
				local oxy = pl:GetAttribute("Oxygen") or MAX_VAL
				local water = pl:GetAttribute("Water") or MAX_VAL
				if head.Position.Y < WATER_LEVEL then
					if oxy > 0 then
						PlayerService:ChangeOxygen(-ADJUSTMENT_VAL)
					end
					if water < MAX_VAL then
						PlayerService:ChangeWater(ADJUSTMENT_VAL)
					end
				elseif head.Position.Y > WATER_LEVEL and oxy < MAX_VAL then
					PlayerService:ChangeOxygen(ADJUSTMENT_VAL)
				end
			end
		end)
	end

	pl.CharacterAdded:Connect(setupCharacter)
	if pl.Character then
		setupCharacter(pl.Character)
	end
end

return PlayerController
