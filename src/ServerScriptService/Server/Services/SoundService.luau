local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundService = Knit.CreateService({
	Name = "SoundService",
	Client = {},
})

function SoundService:KnitInit()
	self._ambientFolder = Workspace:WaitForChild("AmbientSounds")
end

function SoundService:KnitStart()
	for _, part in ipairs(self._ambientFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local ambience = part:FindFirstChild("Ambience")
			if ambience and ambience:IsA("Sound") then
				ambience:Play()
			end
		end
	end
end

return SoundService
