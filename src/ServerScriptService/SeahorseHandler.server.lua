power = 50

function applyMotion(horse, throt, steer)
	local al = horse:WaitForChild("Spring"):WaitForChild("Align")
	local mot = horse.Spring:WaitForChild("Motion")

	local vel = Vector3.new(0, 0, 0)

	if throt == 1 then
		vel = vel - Vector3.new(power, 0, 0)
	elseif throt == -1 then
		vel = vel + Vector3.new(power, 0, 0)
	end

	if steer == 1 then
		vel = vel - Vector3.new(0, 0, power)
	elseif steer == -1 then
		vel = vel + Vector3.new(0, 0, power)
	end

	al.Enabled = false
	mot.Enabled = true
	mot.AngularVelocity = vel
end

function resetToy(toy)
	local al = toy:WaitForChild("Spring"):WaitForChild("Align")
	local mot = toy.Spring:WaitForChild("Motion")

	mot.AngularVelocity = Vector3.new(0, 0, 0)
	mot.Enabled = false
	al.Enabled = true
end

function handleHorse(toy)
	local seat = toy.Seat

	game:GetService("RunService").Heartbeat:connect(function()
		toy.ResetCounter.Value += .03
		
		if toy.ResetCounter.Value > 15 then
			resetToy(toy)
			toy.ResetCounter.Value = 0
		end
	end)

	seat.Changed:connect(function(prop)
		if prop == "Throttle" or prop == "Steer" then
			applyMotion(toy, seat.Throttle, seat.Steer)
			toy.ResetCounter.Value = 0
		end
	end)
end

local playground = workspace:WaitForChild("KiddiePlayground")
local seahorses = playground:WaitForChild("Seahorses")

for _, v in pairs(seahorses:GetChildren()) do
	if v.Name == "Seahorse" then
		handleHorse(v)
	end
end