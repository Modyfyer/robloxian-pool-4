wait(3)

Tool = script.Parent
Player = game.Players.LocalPlayer
Character = Player.Character
Humanoid = Character:WaitForChild("Humanoid")
hrp = Character:WaitForChild("HumanoidRootPart")
Event = Tool:WaitForChild("ShootBeam")
Mouse = Player:GetMouse()

Water = Character:WaitForChild("Water")

Debounce = false

Tool.Equipped:Connect(function(mou)
	mou.Icon = "rbxasset://textures/cursors/CrossMouseIcon.png"
end)

Tool.Unequipped:Connect(function(mou)
	Mouse.Icon = ""
end)

local function onActivated()
	if Debounce == false and Water.Value >= 1 then
		Debounce = true
		while Debounce == true and Water.Value >= 1 do
			wait(.2)
			if (Mouse.Target ~= nil) and ((hrp.Position - Mouse.Hit.Position).magnitude < 30) and Water.Value >= 1 then
				Event:FireServer(Mouse.Target, Mouse.Hit)
			end
		end
		
	end
end

local function onDeactivated()
	if Debounce == true then
		Debounce = false
	end
end

Tool.Activated:Connect(onActivated)
Tool.Deactivated:Connect(onDeactivated)