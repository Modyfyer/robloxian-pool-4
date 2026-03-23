local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local SeahorseComponent = Component.new({
	Tag = "SeahorseComponent",
})

function SeahorseComponent:Construct()
	self._trove = Trove.new()
	self.power = 50

	if not self.Instance:IsA("Model") then
		warn("SeahorseComponent is not a Model")
		return
	end
end

function SeahorseComponent:Start()
	local seat = self.Instance:WaitForChild("Seat")
	local resetCounter = self.Instance:WaitForChild("ResetCounter")

	self._trove:Connect(game:GetService("RunService").Heartbeat, function()
		resetCounter.Value += 0.03

		if resetCounter.Value > 15 then
			self:resetToy()
			resetCounter.Value = 0
		end
	end)

	self._trove:Connect(seat.Changed, function(prop)
		if prop == "Throttle" or prop == "Steer" then
			self:applyMotion(seat.Throttle, seat.Steer)
			resetCounter.Value = 0
		end
	end)
end

function SeahorseComponent:Stop()
	self._trove:Destroy()
end

function SeahorseComponent:applyMotion(throt, steer)
	local al = self.Instance:WaitForChild("Spring"):WaitForChild("Align")
	local mot = self.Instance.Spring:WaitForChild("Motion")

	local vel = Vector3.new(0, 0, 0)

	if throt == 1 then
		vel = vel - Vector3.new(self.power, 0, 0)
	elseif throt == -1 then
		vel = vel + Vector3.new(self.power, 0, 0)
	end

	if steer == 1 then
		vel = vel - Vector3.new(0, 0, self.power)
	elseif steer == -1 then
		vel = vel + Vector3.new(0, 0, self.power)
	end

	al.Enabled = false
	mot.Enabled = true
	mot.AngularVelocity = vel
end

function SeahorseComponent:resetToy()
	local al = self.Instance:WaitForChild("Spring"):WaitForChild("Align")
	local mot = self.Instance.Spring:WaitForChild("Motion")

	mot.AngularVelocity = Vector3.new(0, 0, 0)
	mot.Enabled = false
	al.Enabled = true
end

return SeahorseComponent
