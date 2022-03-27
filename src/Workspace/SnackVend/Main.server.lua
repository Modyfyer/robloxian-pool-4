machine = script.Parent
ss = game:GetService("ServerStorage")
working = false

function handleButton(button)
	button.Click.MouseClick:connect(function(player)
		if working == false then
			working = true
			local chipType = button.ChipType.Value

			button.BrickColor = BrickColor.new("Smoky grey")
			button.CFrame = button.CFrame * CFrame.new(0, 0, .03)
			button.Decal.Transparency = .5

			machine.Backing:WaitForChild("Vend"):Play()
			wait(1.3)

			local fakeChip = ss:WaitForChild("chipPack")[chipType]:Clone()
			fakeChip.Parent = machine
			fakeChip.CFrame = machine[chipType][chipType .. "Spawn"].CFrame * CFrame.new(0, .8, 0)
			game:GetService("Debris"):AddItem(fakeChip, 3)

			local tool = ss:WaitForChild("chipTools")[chipType]:Clone()
			tool.Parent = player.Backpack

			wait(3)
			button.BrickColor = BrickColor.new("Lily white")
			button.CFrame = button.CFrame * CFrame.new(0, 0, -.03)
			button.Decal.Transparency = 0

			working = false
		end
	end)
end

for _, v in pairs(machine.Buttons:GetChildren()) do
	if v.Name == "Button" then
		handleButton(v)
	end
end