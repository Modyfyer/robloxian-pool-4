-- Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ASSETS_FOLDER: Folder = ReplicatedStorage:WaitForChild("Assets")

local FoodOrderService

local FoodCourtUIController = Knit.CreateController({
	Name = "FoodCourtUIController",
})

FoodCourtUIController._trove = Trove.new()
FoodCourtUIController._screenGui = nil :: ScreenGui?
FoodCourtUIController._mainFrame = nil :: GuiObject?
FoodCourtUIController._buttonTemplate = nil :: GuiButton?

function FoodCourtUIController:_playerHasTool(plr, toolName): boolean
	local backpack = plr:FindFirstChild("Backpack")
	if backpack then
		local tool = backpack:FindFirstChild(toolName)
		if tool and tool:IsA("Tool") and tool.Name == toolName then
			return true
		end
	end
	return false
end

function FoodCourtUIController:_orderFood(button: GuiButton, tool: Tool)
	local deb: boolean = false
	self._trove:Connect(button.Activated, function()
		if deb then
			return
		end

		deb = true
		if not self:_playerHasTool(Knit.Player, tool.Name) then
			FoodOrderService:OrderFood(tool.Name)
		end
		task.wait(1.5)
		deb = false
	end)
end

function FoodCourtUIController:_addButton(tool: Tool, parent: GuiObject)
	local button = self._buttonTemplate:Clone()
	button.Parent = parent
	button.FoodImage.Image = tool.TextureId or ""
	button.ItemName.Text = tool.Name
	button.Visible = true

	self:_orderFood(button, tool)
end

function FoodCourtUIController:KnitStart()
	FoodOrderService = Knit.GetService("FoodOrderService")
	local drinksFolder: Folder = ASSETS_FOLDER:WaitForChild("Drinks") :: Folder
	local snacksFolder: Folder = ASSETS_FOLDER:WaitForChild("Foods") :: Folder
	for _, v in pairs(snacksFolder:GetChildren()) do
		if CollectionService:HasTag(v, "EatComponent") then
			self:_addButton(v, self._snacksFrame)
		end
	end

	for _, v in pairs(drinksFolder:GetChildren()) do
		if CollectionService:HasTag(v, "DrinkComponent") then
			self:_addButton(v, self._drinksFrame)
		end
	end
end

function FoodCourtUIController:KnitInit()
	self._screenGui = PlayerGui:WaitForChild("OrderFoodGui") :: ScreenGui
	self._mainFrame = self._screenGui:WaitForChild("MainFrame") :: ImageLabel

	self._drinksFrame = self._mainFrame:WaitForChild("DrinksBG"):WaitForChild("ScrollingFrame") :: ScrollingFrame
	self._snacksFrame = self._mainFrame:WaitForChild("SnacksBG"):WaitForChild("ScrollingFrame") :: ScrollingFrame

	self._buttonTemplate =
		ASSETS_FOLDER:WaitForChild("Templates"):WaitForChild("UI"):WaitForChild("FoodCourtButton") :: GuiButton
end

return FoodCourtUIController
