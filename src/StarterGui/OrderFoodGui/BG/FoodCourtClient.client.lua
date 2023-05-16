task.wait(3) --cbt
player = game.Players.LocalPlayer

main = script.Parent
snacksFrame = main.SnacksBG.ScrollingFrame
drinksFrame = main.DrinksBG.ScrollingFrame
itemButton = main.itemButton

fOrder1 = workspace:WaitForChild("fOrder1")
fOrder2 = workspace:WaitForChild("fOrder2")

foods = game:GetService("ReplicatedStorage"):WaitForChild("Foods")
drinks = game:GetService("ReplicatedStorage"):WaitForChild("Drinks")
event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("OrderFood")

function playerHasTool(plr, toolName)
	local backpack = plr:FindFirstChild("Backpack")
	if backpack then
		local tool = backpack:FindFirstChild(toolName)
		if tool and tool:IsA("Tool") and tool.Name == toolName then
			return true
		end
	end
	return false
end

function doOrderFood(button, tool)
	local deb = false
	button.MouseButton1Click:Connect(function()
		if deb == false then
			deb = true
			if not playerHasTool(player, tool.Name) then
				event:FireServer(tool)
			end
			wait(3)
			deb = false
		end
	end)
end

function addButton(tool, parent)
	local but = itemButton:Clone()
	but.Parent = parent
	but.FoodImage.Image = tool.TextureId
	but.ItemName.Text = tool.Name
	but.Visible = true

	doOrderFood(but, tool)
end

--Populate the frames
for _, v in pairs(foods:GetChildren()) do
	addButton(v, snacksFrame)
end

for _, v in pairs(drinks:GetChildren()) do
	addButton(v, drinksFrame)
end

while wait() do
	local playerChar = player.Character
	hrp = playerChar:WaitForChild("HumanoidRootPart")

	local dist1 = (hrp.Position - fOrder1.Position).Magnitude
	local dist2 = (hrp.Position - fOrder2.Position).Magnitude

	if dist1 <= 5 or dist2 <= 5 then
		main.Visible = true
	else
		main.Visible = false
	end
end
