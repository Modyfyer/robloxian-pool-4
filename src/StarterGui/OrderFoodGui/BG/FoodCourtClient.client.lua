local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
task.wait(3) --cbt

local main = script.Parent
local snacksFrame = main.SnacksBG.ScrollingFrame
local drinksFrame = main.DrinksBG.ScrollingFrame
local itemButton = main.itemButton

local fOrder1 = workspace:WaitForChild("fOrder1")
local fOrder2 = workspace:WaitForChild("fOrder2")

local foods = ReplicatedStorage:WaitForChild("Foods")
local drinks = ReplicatedStorage:WaitForChild("Drinks")
local event = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("OrderFood")

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
			task.wait(3)
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

while task.wait() do
	local playerChar = player.Character
	local hrp = playerChar:WaitForChild("HumanoidRootPart")

	local dist1 = (hrp.Position - fOrder1.Position).Magnitude
	local dist2 = (hrp.Position - fOrder2.Position).Magnitude

	if dist1 <= 5 or dist2 <= 5 then
		main.Visible = true
	else
		main.Visible = false
	end
end
