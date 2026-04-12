local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ShopsUIController = Knit.CreateController({
	Name = "ShopsUIController",
})

function ShopsUIController:KnitStart() end

function ShopsUIController:KnitInit() end

return ShopsUIController
