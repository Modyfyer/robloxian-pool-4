-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

local EmotesUIController = Knit.CreateController({
	Name = "EmotesUIController",
})

function EmotesUIController:KnitStart() end

function EmotesUIController:KnitInit() end

return EmotesUIController
