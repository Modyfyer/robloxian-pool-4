local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local BasketballHoopComponent = Component.new({
	Tag = "BasketballHoop",
})

function BasketballHoopComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Instance") then
		warn("BasketballHoopComponent is not a Instance")
		return
	end
end

function BasketballHoopComponent:Start()
	local goalPart = self.Instance:WaitForChild("Goal")
	local snd = goalPart:WaitForChild("Applause")
	local deb: boolean = false

	self._trove:Connect(goalPart.Touched, function(prt: Instance)
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

function BasketballHoopComponent:Stop()
	self._trove:Destroy()
end

return BasketballHoopComponent
