local Players = game:GetService("Players")

local WATER_LEVEL = 28

local terr = workspace.Terrain

function canSplash(hrp, pos)
	local min = hrp.Position - (4 * hrp.Size)
	local max = hrp.Position + (4 * hrp.Size)	
	local region = Region3.new(min, max):ExpandToGrid(4)
	local material = terr:ReadVoxels(region, 4)[1][1][1] 

	if material == Enum.Material.Water then
		local particlePart = Instance.new("Part")
		local particle = script.SplashParticle:Clone()

		particlePart.Anchored = true
		particlePart.Transparency = 1
		particlePart.CanCollide = false
		particlePart.Size = Vector3.new(3, 1, 3)
		particlePart.CFrame = pos
		particlePart.Parent = hrp.Parent

		particle.Parent = particlePart
		particle:Emit(50)

		game:GetService("Debris"):AddItem(particlePart, 5)
	end
end

function setSplash(player)
	local hrp = player.Character:WaitForChild("HumanoidRootPart")

	terr.Touched:Connect(function(part)
		local velocity = math.abs(part.Velocity.Y)
		if part == hrp and velocity > 15 then
			canSplash(hrp, CFrame.new(hrp.Position.X, WATER_LEVEL, hrp.Position.Z))
		end
	end)
end

Players.PlayerAdded:Connect(function(pl)
	pl.CharacterAdded:Connect(function(character)
		local hum = character:WaitForChild("Humanoid")
		local connection = setSplash(pl)

		hum.Died:Connect(function()
			connection:Disconnect()
		end)
	end)
end)