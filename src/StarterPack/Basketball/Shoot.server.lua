Tool = script.Parent
event = Tool.dest
Hndl = Tool.Handle
anim = Tool.Throw
snd = Hndl.Whoosh

VELOCITY = 200

local deb = false

function computeLaunchAngle(dx,dy,grav)
	-- arcane
	-- http://en.wikipedia.org/wiki/Trajectory_of_a_projectile

	local g = math.abs(grav)
	local inRoot = (VELOCITY*VELOCITY*VELOCITY*VELOCITY) - (g * ((g*dx*dx) + (2*dy*VELOCITY*VELOCITY)))
	if inRoot <= 0 then
		return .25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((VELOCITY*VELOCITY) + root) / (g*dx)

	local inATan2 = ((VELOCITY*VELOCITY) - root) / (g*dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	if answer1 < answer2 then return answer1 end
	return answer2
end

function computeDirection(vec)
	local lenSquared = vec.magnitude * vec.magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end


event.OnServerEvent:connect(function(player, dest)
	if deb then return end
	local hum = player.Character:WaitForChild("Humanoid")
	local animTrack = hum:LoadAnimation(anim)
	Hndl.Transparency = 1

	local proj = Hndl:Clone()
	proj.Parent = workspace
	proj.Transparency = 0
	proj.CanCollide = true
	proj.Name = "Basketball"
	proj.Trail.Enabled = true

	local startP = Hndl.Position

	animTrack:Play()
	snd:Play()

	local lAng = computeLaunchAngle((dest - startP).x, (dest - startP).y, -9.81 * 20)
	local dir = computeDirection(dest - startP)

	local vel = dir * 50 * math.cos(lAng) + Vector3.new(0, 100 * math.sin(lAng), 0)

	proj.Position = Hndl.Position

	proj.Velocity = vel
	game:GetService("Debris"):AddItem(proj, 10)


	deb = true

	wait(5)

	deb = false
	Hndl.Transparency = 0
end)