--[[--<<---------------------------------------------------->>--
Purpose: Initializes high level objects

Initialized by: Self
--]]--<<---------------------------------------------------->>--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--Dependency group 0
local DataManager = require(ServerScriptService:WaitForChild("Data"):WaitForChild("DataManager"))
DataManager.new()

--Dependency group 1
repeat task.wait() until DataManager ~= nil
local PurchaseManager = require(ServerScriptService:WaitForChild("Data"):WaitForChild("PurchaseManager"))
PurchaseManager.new(DataManager)

--Dependency group 2
local AvatarManager = require(ServerScriptService:WaitForChild("AvatarManager")).new(PurchaseManager)
local CabanaManager = require(ServerScriptService:WaitForChild("CabanaManager")).new(PurchaseManager)