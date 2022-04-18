function equipStats(pl)
	local oxygenValue = Instance.new("NumberValue", pl.Character)
	oxygenValue.Name = "Oxygen"
	oxygenValue.Value = 100

	local waterValue = Instance.new("NumberValue", pl.Character)
	waterValue.Name = "Water"
	waterValue.Value = 100
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
	spawn(function()
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

game.Players.PlayerAdded:connect(function(pl)
	pl.CharacterAdded:connect(function()
		local hrp = pl.Character:WaitForChild("HumanoidRootPart")
		equipStats(pl)
		doOxygen(pl)
	end)
end)

oxygenEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("OxygenChange")
waterEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("WaterChange")

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