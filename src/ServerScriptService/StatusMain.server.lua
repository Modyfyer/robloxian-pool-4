local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

function equipStats(pl)
	local oxygenValue = Instance.new("NumberValue")
	oxygenValue.Name = "Oxygen"
	oxygenValue.Value = 100
	oxygenValue.Parent = pl.Character

	local waterValue = Instance.new("NumberValue")
	waterValue.Name = "Water"
	waterValue.Value = 100
	waterValue.Parent = pl.Character
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
	pl.Character.Oxygen.Value = 100
	pl.Character.Humanoid.WalkSpeed = 16
end

function doOxygen(pl)
	task.spawn(function()
		local oxy = pl.Character:WaitForChild("Oxygen")
		oxy.Changed:connect(function()
			if oxy.Value <= 0 then
				local hum = pl.Character:FindFirstChild("Humanoid")
				hum.WalkSpeed = 0
				task.wait(3)
				drown(pl)
			end
		end)
	end)
end

function handleJump(char)
	local hum = char:WaitForChild("Humanoid")
	hum.Jumping:connect(function()
		local check = Instance.new("BoolValue")
		check.Name = "JustJumped"
		check.Parent = hum
		game:GetService("Debris"):AddItem(check, 5)
	end)
end

game.Players.PlayerAdded:connect(function(pl)
	pl.CharacterAdded:connect(function(char)
		--local hrp = pl.Character:WaitForChild("HumanoidRootPart")
		equipStats(pl)
		doOxygen(pl)
		handleJump(char)
	end)
end)

local oxygenEvent = RemoteEventsFolder:WaitForChild("OxygenChange")
local waterEvent = RemoteEventsFolder:WaitForChild("WaterChange")

oxygenEvent.OnServerEvent:connect(function(pl, amt)
	local plOxy = pl.Character:FindFirstChild("Oxygen")

	if plOxy ~= nil then
		plOxy.Value = plOxy.Value + amt
		if plOxy.Value > 100 then
			plOxy.Value = 100
		elseif plOxy.Value < 0 then
			plOxy.Value = 0
		end
	end
end)

waterEvent.OnServerEvent:connect(function(pl, amt)
	local plWat = pl.Character:FindFirstChild("Water")

	if plWat ~= nil then
		plWat.Value = plWat.Value + amt
		if plWat.Value > 100 then
			plWat.Value = 100
		elseif plWat.Value < 0 then
			plWat.Value = 0
		end
	end
end)