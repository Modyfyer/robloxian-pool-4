-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local terr = workspace.Terrain

local ASSETS_FOLDER = ReplicatedStorage:WaitForChild("Assets") :: Folder

-- Constants
local WATER_LEVEL = 28

local SplashService = Knit.CreateService({
	Name = "SplashService",
	Client = {},
})
SplashService._trove = Trove.new()
SplashService._charTrove = Trove.new()
SplashService._splashParticle = nil :: ParticleEmitter?

function SplashService:_canSplash(hrp, pos)
	local min = hrp.Position - (4 * hrp.Size)
	local max = hrp.Position + (4 * hrp.Size)
	local region = Region3.new(min, max):ExpandToGrid(4)
	local material = terr:ReadVoxels(region, 4)[1][1][1]

	if material == Enum.Material.Water then
		local particlePart = Instance.new("Part")
		local particle = self._splashParticle:Clone()

		particlePart.Anchored = true
		particlePart.Transparency = 1
		particlePart.CanCollide = false
		particlePart.Size = Vector3.new(3, 1, 3)
		particlePart.CFrame = pos
		particlePart.Parent = hrp.Parent

		particle.Parent = particlePart

		task.delay(1, function()
			particlePart:Destroy()
		end)
	end
end

function SplashService:KnitStart()
	self._trove:Connect(Players.PlayerAdded, function(player: Player)
		self._trove:Connect(player.CharacterAdded, function(character)
			local hrp = character:WaitForChild("HumanoidRootPart")
			self._charTrove:Connect(terr.Touched, function(part)
				local velocity = math.abs(part.Velocity.Y)
				if part == hrp and velocity > 15 then
					self:_canSplash(hrp, CFrame.new(hrp.Position.X, WATER_LEVEL, hrp.Position.Z))
				end
			end)

			local hum = character:WaitForChild("Humanoid")
			self._charTrove:Connect(hum.Died, function()
				self._charTrove:Clean()
			end)
		end)
	end)
end

function SplashService:KnitInit()
	self._splashParticle = ASSETS_FOLDER:WaitForChild("SplashParticle") :: ParticleEmitter
end

return SplashService
