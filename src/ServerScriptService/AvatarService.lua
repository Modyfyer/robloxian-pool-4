--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Data
local ItemsData = require(ReplicatedStorage.Data.ItemsData)

local AvatarService = Knit.CreateService({
	Name = "AvatarService",
	Client = {},
})

function AvatarService:KnitStart() end

function AvatarService:KnitInit() end

return AvatarService
