local maxAngle: number = 30
local minAngle: number = -30

function getPlayerFromPart(part)
	local player = nil

	if part.Parent.ClassName == "Accessory" or part.Parent.ClassName == "Hat" then
		if part.Parent.Parent ~= workspace then
			player = game.Players:GetPlayerFromCharacter(part.Parent.Parent)
		end
	elseif part.Parent.ClassName == "Model" and game.Players:GetPlayerFromCharacter(part.Parent) then
		player = game.Players:GetPlayerFromCharacter(part.Parent)
	end
	return player
end

function doCannon(can)
	local model = can
	local seat = model:WaitForChild("Seat")
	local angle = model:WaitForChild("Angle")
	local cannon = model:WaitForChild("Cannon")
	local pivot = model:WaitForChild("Pivot")
	local canFire = model:WaitForChild("CanFire")
	local event = model:WaitForChild("FireCannon")
	local beam = cannon:WaitForChild("Beam")
	local attA = cannon:WaitForChild("BeamA")
	local sound = cannon:WaitForChild("Sound")

	event.OnServerEvent:connect(function(pl, part, loc)
		if canFire.Value == true then
			local attB = Instance.new("Attachment")
			attB.Position = part.CFrame:ToObjectSpace(loc).Position
			attB.Parent = part
			beam.Attachment1 = attB
			sound:Play()

			game:GetService("Debris"):AddItem(attB, 1.5)

			if getPlayerFromPart(part) ~= nil then
				local dedPlayer = getPlayerFromPart(part)
				local oxy = dedPlayer.Character:FindFirstChild("Oxygen")

				if oxy ~= nil then
					oxy.Value -= 10
				end
			end
			canFire.Value = false
			task.wait(5)
			canFire.Value = true
		end
	end)

	local function updateCannon()
		cannon.CFrame = pivot.CFrame * CFrame.new(0, .5, -1.5) * CFrame.Angles(0, math.rad(angle.Value), 0)
	end

	seat.ChildAdded:connect(function(w)
		if w.Name == "SeatWeld" then
			w.C0 = w.C0 + Vector3.new(0, 1, 0)
		end
	end)

	seat.Changed:connect(function(prop)
		if prop == "Steer" then
			repeat
				task.wait(.5)
				if seat.Steer == 1 and (angle.Value > minAngle) then
					angle.Value -= 5
				elseif seat.Steer == -1 and (angle.Value < maxAngle) then
					angle.Value += 5
				end
				updateCannon()
			until seat.Steer == 0
			updateCannon()
		end
	end)
end

local cannons = workspace:WaitForChild("WaterCannons")

for _, v in pairs(cannons:GetChildren()) do
	if v.Name == "WaterCannon" then
		doCannon(v)
	end
end