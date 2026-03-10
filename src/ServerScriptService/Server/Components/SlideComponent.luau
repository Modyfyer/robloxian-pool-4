local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local SlideComponent = Component.new({
	Tag = "SlideComponent",
})

function SlideComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Instance") then
		warn("SlideComponent is not a Instance")
		return
	end

	self._trigger = self.Instance:WaitForChild("SitTrigger")
end

function SlideComponent:Start()
	self._trove:Connect(self._trigger.Touched, function(p)
		local hum = p.Parent:FindFirstChild("Humanoid")
		if hum ~= nil then
			hum.Sit = true
		end
	end)

	if self.Instance.Parent.Name == "KiddiePlayground" then
		for _, v in pairs(self.Instance.Parent:WaitForChild("Velocity"):GetChildren()) do
			if v.Name == "VelocityPart" then
				v.Velocity = v.CFrame.lookVector * 50
			end
		end
	end
end

function SlideComponent:Stop()
	self._trove:Destroy()
end

return SlideComponent
