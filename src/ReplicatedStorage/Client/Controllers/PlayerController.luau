local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ADJUSTMENT_VAL: number = 5
local MAX_VAL: number = 100
local WATER_LEVEL: number = 28

local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local ts = game:GetService("TweenService")
local blur = game.Lighting:WaitForChild("RunBlur")

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local blurOn = ts:Create(blur, tweenInfo, { Size = 5 })
local blurOff = ts:Create(blur, tweenInfo, { Size = 0 })
local tweenOn = ts:Create(cam, tweenInfo, { FieldOfView = 90 })
local tweenOff = ts:Create(cam, tweenInfo, { FieldOfView = 70 })

local running = false
local hum

local PlayerController = Knit.CreateController({
	Name = "PlayerController",
})

function PlayerController:KnitInit() end

function PlayerController:KnitStart()
	local PlayerService = Knit.GetService("PlayerService")
	local pl = Knit.Player
	self.currentTask = nil

	uis.InputBegan:Connect(function(input)
		if running == false and hum then
			if input.KeyCode == Enum.KeyCode.LeftShift then
				blurOff:Pause()
				blurOn:Play()
				tweenOff:Pause()
				tweenOn:Play()
				hum.WalkSpeed = 45
				running = true
			end
		end
	end)

	uis.InputEnded:Connect(function(input)
		if running == true and hum then
			if input.KeyCode == Enum.KeyCode.LeftShift then
				blurOn:Pause()
				blurOff:Play()
				tweenOn:Pause()
				tweenOff:Play()
				hum.WalkSpeed = 16
				running = false
			end
		end
	end)

	local function setupCharacter(ch)
		if self.currentTask then
			task.cancel(self.currentTask)
		end

		local head = ch:WaitForChild("Head")
		hum = ch:WaitForChild("Humanoid")

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
