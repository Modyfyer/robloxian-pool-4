-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local MAX_ANGLE: number = 30
local MIN_ANGLE: number = -30

local CannonComponent = Component.new({
	Tag = "CannonComponent",
})

function getPlayerFromPart(part): Player?
	local player = nil

	if part.Parent.ClassName == "Accessory" or part.Parent.ClassName == "Hat" then
		if part.Parent.Parent ~= workspace then
			player = Players:GetPlayerFromCharacter(part.Parent.Parent)
		end
	elseif part.Parent.ClassName == "Model" and Players:GetPlayerFromCharacter(part.Parent) then
		player = Players:GetPlayerFromCharacter(part.Parent)
	end
	return player
end

function CannonComponent:Construct()
	self._trove = Trove.new()
end

function CannonComponent:Start()
	local seat = self.Instance:WaitForChild("Seat")
	local angle = self.Instance:WaitForChild("Angle")
	local cannon = self.Instance:WaitForChild("Cannon")
	local pivot = self.Instance:WaitForChild("Pivot")
	local canFire = self.Instance:WaitForChild("CanFire")
	local event = self.Instance:WaitForChild("FireCannon")
	local beam = cannon:WaitForChild("Beam")
	local sound = cannon:WaitForChild("Sound")

	event.OnServerEvent:connect(function(_, part, loc)
		if not canFire.Value then
			return
		end

		Promise.resolve()
			:andThenCall(function()
				canFire.Value = false

				local attB = Instance.new("Attachment")
				attB.Position = part.CFrame:ToObjectSpace(loc).Position
				attB.Parent = part
				beam.Attachment1 = attB
				self._trove:Add(attB)
			end)
			:andThenCall(sound.Play, sound)
			:andThenCall(function()
				if getPlayerFromPart(part) ~= nil then
					local dedPlayer = getPlayerFromPart(part)
					local oxy = dedPlayer.Character:FindFirstChild("Oxygen")

					if oxy ~= nil then
						oxy.Value -= 10
					end
				end
			end)
			:andThenCall(Promise.delay, 5)
			:finallyCall(function()
				canFire.Value = true
				self._trove:Clean()
			end)
	end)

	local function updateCannon()
		cannon.CFrame = pivot.CFrame * CFrame.new(0, 0.5, -1.5) * CFrame.Angles(0, math.rad(angle.Value), 0)
	end

	seat.ChildAdded:connect(function(w)
		if w.Name == "SeatWeld" then
			w.C0 = w.C0 + Vector3.new(0, 1, 0)
		end
	end)

	seat.Changed:connect(function(prop)
		if prop == "Steer" then
			repeat
				task.wait(0.5)
				if seat.Steer == 1 and (angle.Value > MIN_ANGLE) then
					angle.Value -= 5
				elseif seat.Steer == -1 and (angle.Value < MAX_ANGLE) then
					angle.Value += 5
				end
				updateCannon()
			until seat.Steer == 0
			updateCannon()
		end
	end)
end

function CannonComponent:Stop()
	self._trove:Destroy()
end

return CannonComponent
