tool = script.Parent
pl = game.Players.LocalPlayer
event = tool:WaitForChild("ShootBeam")

deb = false
tool.Equipped:connect(function(mouse)
	mouse.Icon = "rbxasset://textures/cursors/CrossMouseIcon.png"
	local ch = pl.Character
	local hrp = ch:WaitForChild("HumanoidRootPart")
	local water = ch:WaitForChild("Water")
	tool.Activated:connect(function()
		if mouse.Target ~= nil and (hrp.Position - mouse.Hit.Position).magnitude < 30 and water.Value > 4 then
			if deb == false then
				deb = true
				event:FireServer(mouse.Target, mouse.Hit)

				wait(.2)
				deb = false
			end
		end
	end)
end)