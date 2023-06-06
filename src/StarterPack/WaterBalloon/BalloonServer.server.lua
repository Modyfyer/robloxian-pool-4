local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local balloonEvent = Tool:WaitForChild("FireBalloon")


local debounce = false

function balloonHit(balloon)
	balloon.Touched:connect(function(p)
		if p.Name ~= "Handle" then
			balloon.Anchored = true
			local emitPos = balloon.Position
			
			local emitterPart = Instance.new("Part")
			emitterPart.Anchored = true
			emitterPart.Size = Vector3.new(2, 2, 2)
			emitterPart.Transparency = 1
			emitterPart.CanCollide = false
			emitterPart.CFrame = CFrame.new(emitPos)
			
			local emitter = Tool:WaitForChild("Particle"):Clone()
			emitter.Parent = emitterPart
			
			local snd = Tool:WaitForChild("Splat"):Clone()
			snd.Parent = emitterPart
			
			emitterPart.Parent = workspace
			
			game:GetService("Debris"):AddItem(emitterPart, 1)
			game:GetService("Debris"):AddItem(balloon, 8)
			emitter.Enabled = true
			snd:Play()
			balloon:Destroy()
			
			if game.Players:GetPlayerFromCharacter(p.Parent) then
				local plTarg = game.Players:GetPlayerFromCharacter(p.Parent)
				
				if plTarg.Character:FindFirstChild("Oxygen") then
					local oxy = plTarg.Character:FindFirstChild("Oxygen")
					oxy.Value -= 20
				end
			end
		end
	end)
end

function fireBalloon(target)
	local projectile = Handle:Clone()
	projectile.CFrame = Handle.CFrame
	projectile.Parent = workspace
	
	Handle.Transparency = 1
	
	local bodyVelocity = Instance.new("BodyVelocity", projectile)
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = (target - projectile.Position).unit * 100
	
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity", projectile)
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(), math.random(), math.random()) * 10
	
	wait(.3)
	
	balloonHit(projectile)
	
	wait(5)
	
	Handle.Transparency = 0.15
end

balloonEvent.OnServerEvent:Connect(function(player, target)
	fireBalloon(target)
end)