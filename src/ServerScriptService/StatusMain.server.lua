local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

local DEFAULT_COLOR: Color3 = Color3.new(0.835294, 0.45098, 0.239216)
local MAX_OXYGEN: number = 100
local MAX_WATER: number = 100

function equipStats(pl)
	local oxygenValue = Instance.new("NumberValue")
	oxygenValue.Name = "Oxygen"
	oxygenValue.Value = MAX_OXYGEN
	oxygenValue.Parent = pl.Character

	local waterValue = Instance.new("NumberValue")
	waterValue.Name = "Water"
	waterValue.Value = MAX_WATER
	waterValue.Parent = pl.Character

	local colorValue = Instance.new("Color3Value")
	colorValue.Name = "Color"
	colorValue.Value = DEFAULT_COLOR
	colorValue.Parent = pl.Character
end

function getNearestBrick(pl)
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

	if Part then
		return Part
	end
end

function drown(pl)
	local drownSpot = getNearestBrick(pl)
	pl.Character:MoveTo(drownSpot.Position)
	pl.Character.Oxygen.Value = MAX_OXYGEN
	pl.Character.Humanoid.WalkSpeed = 16
end

function doOxygen(pl)
	task.spawn(function()
		local oxy = pl.Character:WaitForChild("Oxygen")
		oxy.Changed:Connect(function()
			if oxy.Value <= 0 then
				local hum = pl.Character:FindFirstChild("Humanoid")
				hum.WalkSpeed = 0
				task.wait(3)
				drown(pl)
			end
		end)
	end)
end


game.Players.PlayerAdded:Connect(function(pl)
	pl.CharacterAdded:Connect(function()
		--local hrp = pl.Character:WaitForChild("HumanoidRootPart")
		equipStats(pl)
		doOxygen(pl)
	end)
end)

local oxygenEvent = RemoteEventsFolder:WaitForChild("OxygenChange")
local waterEvent = RemoteEventsFolder:WaitForChild("WaterChange")
local colorEvent = RemoteEventsFolder:WaitForChild("UpdateColor")

oxygenEvent.OnServerEvent:Connect(function(pl, amt)
	local plOxy = pl.Character:FindFirstChild("Oxygen")

	if plOxy ~= nil then
		plOxy.Value = plOxy.Value + amt
		if plOxy.Value > MAX_OXYGEN then
			plOxy.Value = MAX_OXYGEN
		elseif plOxy.Value < 0 then
			plOxy.Value = 0
		end
	end
end)

waterEvent.OnServerEvent:Connect(function(pl, amt)
	local plWat = pl.Character:FindFirstChild("Water")

	if plWat ~= nil then
		plWat.Value = plWat.Value + amt
		if plWat.Value > MAX_WATER then
			plWat.Value = MAX_WATER
		elseif plWat.Value < 0 then
			plWat.Value = 0
		end
	end
end)

colorEvent.OnServerEvent:Connect(function(pl, color)
	local plColor = pl.Character:FindFirstChild("Color")

	if plColor ~= nil then
		plColor.Value = color

		for _, v in pairs(pl.Backpack:GetChildren()) do
			if v:IsA("Tool") and v:FindFirstChild("Customizable") then
				v.Handle.Color = color
			end
		end

		for _, v in pairs(pl.Character:GetChildren()) do
			if v:IsA("Tool") and v:FindFirstChild("Customizable") then
				v.Handle.Color = color
			end
		end
	end
end)