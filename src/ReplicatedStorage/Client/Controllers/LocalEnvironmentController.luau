-- Services
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local ASSETS_FOLDER = ReplicatedStorage:WaitForChild("Assets") :: Folder

local RAIN_SOUND = "Rain"

local minOrbitRadius = 1
local maxOrbitRadius = 6

local SoundController

local LocalEnvironmentController = Knit.CreateController({
	Name = "LocalEnvironmentController",
})
LocalEnvironmentController._trove = Trove.new()

function LocalEnvironmentController:_spawnButterfly(spawnLocation: SpawnLocation)
	local butterfly = self._butterfly:Clone()
	butterfly.Parent = self._butterfliesFolder
	local plane = butterfly:WaitForChild("Plane")

	local orbitRadius = math.random(minOrbitRadius, maxOrbitRadius)
	local theta = math.rad(math.random(0, 360))

	plane.CFrame = spawnLocation.CFrame * CFrame.new(orbitRadius * math.cos(theta), 0, orbitRadius * math.sin(theta))
end

local function renderRain(self)
	local rainPart = self._rainPart
	local isRaining = self._isRaining
	local ch = self._ch
	local cam = self._cam

	rainPart.CFrame = CFrame.new(cam.CFrame.Position) + Vector3.new(0, 80, 0)

	local raycastResult = nil
	local raycastParams = nil

	if isRaining.Value == true then
		raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { ch, rainPart, workspace:WaitForChild("TimeCycleLights") }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastResult = workspace:Raycast(cam.CFrame.Position, Vector3.new(0, 100, 0), raycastParams)
	end

	if (isRaining.Value == true) and not raycastResult then
		rainPart.Rain.Enabled = true

		SoundController:PlaySound(RAIN_SOUND)
	else
		rainPart.Rain.Enabled = false
		rainPart.Rain:Clear()

		SoundController:StopSound(RAIN_SOUND)
	end
end

function LocalEnvironmentController:_updateUnderwater()
	local camera = workspace.CurrentCamera
	if camera.CFrame.Y < self._waterLevel and self._underwater == false then
		self._underwater = true
		self._uwFX.Parent = Lighting
		SoundService.AmbientReverb = Enum.ReverbType.UnderWater
		SoundService.RolloffScale = 0.1
		self._uwBlur.Enabled = true
	elseif camera.CFrame.Y > self._waterLevel and self._underwater == true then
		self._underwater = false
		self._uwFX.Parent = ReplicatedStorage
		SoundService.AmbientReverb = Enum.ReverbType.NoReverb
		SoundService.RolloffScale = 1
		self._uwBlur.Enabled = false
	end
end

function LocalEnvironmentController:KnitStart()
	SoundController = Knit.GetController("SoundController")

	for _ = 1, 4 do
		self:_spawnButterfly(self._spawn1)
		self:_spawnButterfly(self._spawn2)
	end

	local function setupRain()
		self._ch = Knit.Player.Character
		self._hum = self._ch:WaitForChild("Humanoid")
		self._cam = workspace.CurrentCamera

		self._rainPart.Parent = self._cam

		self._trove:Connect(RunService.RenderStepped, function()
			renderRain(self)
		end)

		self._trove:Connect(self._hum.Died, function()
			self._rainPart:Destroy()
			SoundController:StopSound(RAIN_SOUND)
			self._trove:Clean()
		end)
	end

	Knit.Player.CharacterAdded:Connect(setupRain)
	if Knit.Player.Character then
		setupRain()
	end

	-- Underwater effects
	RunService.RenderStepped:Connect(function()
		self:_updateUnderwater()
	end)
end

function LocalEnvironmentController:KnitInit()
	self._butterfliesFolder = workspace:WaitForChild("Butterflies") :: Folder
	self._spawn1 = self._butterfliesFolder:WaitForChild("bfSp1") :: SpawnLocation
	self._spawn2 = self._butterfliesFolder:WaitForChild("bfSp2") :: SpawnLocation
	self._butterfly = ASSETS_FOLDER:WaitForChild("Butterfly") :: Model

	ASSETS_FOLDER.Mountains:Clone().Parent = workspace

	self._rainPart = ASSETS_FOLDER:WaitForChild("RainPart"):Clone()
	self._isRaining = ReplicatedStorage:WaitForChild("IsRaining")

	-- Underwater setup
	if Lighting:FindFirstChild("Underwater") then
		Lighting.Underwater:Destroy()
	end
	self._uwFX = ReplicatedStorage:WaitForChild("Underwater"):Clone()
	self._uwBlur = Lighting:WaitForChild("UWBlur")
	self._waterLevel = 28
	self._underwater = false
end

return LocalEnvironmentController
