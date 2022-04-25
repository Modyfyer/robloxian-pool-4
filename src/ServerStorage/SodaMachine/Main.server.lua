local machine = script.Parent
local spawn = machine.Spawn
local ss = game:GetService("ServerStorage")
local working = false

function handleButton(button)
	button.Click.MouseClick:connect(function(player)
		if working == false then
			working = true

			button.BrickColor = BrickColor.new("Smoky grey")
			button.CFrame = button.CFrame * CFrame.new(0, 0, .08)
			button.Decal.Transparency = .5
			spawn.Vend:Play()

			local fakeSoda = ss:WaitForChild("SodaPack")[button.SodaType.Value]:Clone()
			fakeSoda.Parent = machine
			fakeSoda.CFrame = spawn.CFrame
			game:GetService("Debris"):AddItem(fakeSoda, 3)

			local tool = ss:WaitForChild("SodaTools")[button.SodaType.Value]:Clone()
			tool.Parent = player.Backpack

			task.wait(3)
			button.BrickColor = BrickColor.new("Medium stone grey")
			button.CFrame = button.CFrame * CFrame.new(0, 0, -.08)
			button.Decal.Transparency = 0

			working = false
		end
	end)
end

for _, v in pairs(machine:GetChildren()) do
	if v.Name == "Button" then
		handleButton(v)
	end
end