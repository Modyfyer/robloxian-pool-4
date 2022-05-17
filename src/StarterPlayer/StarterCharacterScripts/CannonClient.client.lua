player = game.Players.LocalPlayer
char = player.Character
hum = char:WaitForChild("Humanoid")
holdAnim = hum:LoadAnimation(script:WaitForChild("Animation"))
hrp = char:WaitForChild("HumanoidRootPart")

function doCannon()
	local mouse = player:GetMouse()
	local cannon = hum.SeatPart.Parent
	local canFire = cannon:WaitForChild("CanFire")
	local event = cannon:WaitForChild("FireCannon")

	mouse.Icon = "rbxasset://textures/cursors/CrossMouseIcon.png"

	pcall(function()
		hum.Jumping:connect(function()
			holdAnim:Stop()
			if mouse ~= nil then
				mouse.Icon = ""
				mouse = nil
			end
			return
		end)

		mouse.Button1Down:connect(function()
			if mouse == nil then
				return
			end

			if mouse.Target ~= nil and (hrp.Position - mouse.Hit.Position).magnitude < 70 and canFire.Value == true then
				event:FireServer(mouse.Target, mouse.Hit)
			end
		end)
	end)
end

hum.Changed:connect(function(prop)
	if prop == "SeatPart" then
		if hum.SeatPart ~= nil then
			local seat = hum.SeatPart
			if seat.Parent.Name == "WaterCannon" then
				doCannon()
				holdAnim:Play()
			end
		end
	end
end)