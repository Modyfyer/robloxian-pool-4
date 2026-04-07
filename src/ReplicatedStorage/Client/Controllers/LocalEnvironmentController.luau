local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ASSETS_FOLDER = ReplicatedStorage:WaitForChild("Assets") :: Folder

local LocalEnvironmentController = Knit.CreateController({
	Name = "LocalEnvironmentController",
})
LocalEnvironmentController._trove = Trove.new()

function LocalEnvironmentController:_spawnButterfly(spawnLocation: SpawnLocation)
	local butterfly = self._butterfly:Clone()
	butterfly.Parent = self._butterfliesFolder
	local plane = butterfly:WaitForChild("Plane")

	local minOrbitRadius = 1
	local maxOrbitRadius = 6
	local orbitRadius = math.random(minOrbitRadius, maxOrbitRadius)
	local theta = math.rad(math.random(0, 360))

	plane.CFrame = spawnLocation.CFrame * CFrame.new(orbitRadius * math.cos(theta), 0, orbitRadius * math.sin(theta))
end

function LocalEnvironmentController:KnitStart()
	for _ = 1, 4 do
		self:_spawnButterfly(self._spawn1)
		self:_spawnButterfly(self._spawn2)
	end
end

function LocalEnvironmentController:KnitInit()
	self._butterfliesFolder = workspace:WaitForChild("Butterflies") :: Folder
	self._spawn1 = self._butterfliesFolder:WaitForChild("bfSp1") :: SpawnLocation
	self._spawn2 = self._butterfliesFolder:WaitForChild("bfSp2") :: SpawnLocation
	self._butterfly = ASSETS_FOLDER:WaitForChild("Butterfly") :: Model

	ReplicatedStorage.Mountains:Clone().Parent = workspace
end

return LocalEnvironmentController
