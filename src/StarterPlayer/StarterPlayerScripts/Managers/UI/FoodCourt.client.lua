--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Declarations
local LocalPlayer: Player = Players.LocalPlayer
task.wait(3) --cbt

local UI_NAME = "OrderFoodGui"

local main: GuiObject = LocalPlayer.PlayerGui:WaitForChild(UI_NAME):WaitForChild("BG")
local snacksFrame: ScrollingFrame = main:WaitForChild("SnacksBG"):WaitForChild("ScrollingFrame")
local drinksFrame: ScrollingFrame = main:WaitForChild("DrinksBG"):WaitForChild("ScrollingFrame")
local itemButton = main.itemButton

local fOrder1 = workspace:WaitForChild("fOrder1")
local fOrder2 = workspace:WaitForChild("fOrder2")

local foods: Folder = ReplicatedStorage:WaitForChild("Foods")
local drinks: Folder = ReplicatedStorage:WaitForChild("Drinks")
local event: RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("OrderFood")

--Functions
function playerHasTool(plr, toolName): boolean
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
	local deb: boolean = false
	button.MouseButton1Click:Connect(function()
		if deb == false then
			deb = true
			if not playerHasTool(LocalPlayer, tool.Name) then
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
	local playerChar = LocalPlayer.Character
	local hrp = playerChar:WaitForChild("HumanoidRootPart")

	local dist1 = (hrp.Position - fOrder1.Position).Magnitude
	local dist2 = (hrp.Position - fOrder2.Position).Magnitude

	if dist1 <= 5 or dist2 <= 5 then
		main.Visible = true
	else
		main.Visible = false
	end
end
