-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Declarations
local ASSETS = ReplicatedStorage:WaitForChild("Assets") :: Folder
local FOODS_FOLDER = ASSETS:WaitForChild("Foods") :: Folder
local DRINKS_FOLDER = ASSETS:WaitForChild("Drinks") :: Folder

local FoodOrderService = Knit.CreateService({
	Name = "FoodOrderService",
	Client = {},
})

function FoodOrderService.Client:OrderFood(player: Player, foodItemName: string)
	local foodItem: Tool? = FOODS_FOLDER:FindFirstChild(foodItemName) or DRINKS_FOLDER:FindFirstChild(foodItemName)
	if not foodItem then
		warn(`OrderComponent: "{foodItemName}" not found in Assets.Foods or Assets.Drinks`)
		return
	end

	local clone = foodItem:Clone()
	clone.Parent = player.Backpack
end

function FoodOrderService:KnitStart() end

function FoodOrderService:KnitInit() end

return FoodOrderService
