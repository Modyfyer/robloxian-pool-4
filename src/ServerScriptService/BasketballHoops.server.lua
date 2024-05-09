-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager).new()

-- Declarations
local hoops: {Instance} = CollectionService:GetTagged("BasketballHoop")

-- Functions
function handleBasketballHoop(hoop)
	local goalPart = hoop:WaitForChild("Goal")
	local snd = goalPart:WaitForChild("Applause")
	local deb: boolean = false

	ConnectionManager:ConnectToEvent(goalPart.Touched, function(prt: Instance)
		if prt:IsA("MeshPart") and prt.Name == "Basketball" and not deb then
			snd:Play()
			for _, v in pairs(goalPart:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
			deb = true

			task.wait(5)

			snd:Stop()
			for _, v in pairs(goalPart:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			deb = false
		end
	end)
end

for _, v: Instance in pairs(hoops) do
	handleBasketballHoop(v)
end