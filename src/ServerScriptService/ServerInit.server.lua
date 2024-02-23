--[[--<<---------------------------------------------------->>--
Purpose: Initializes high level objects

Initialized by: Self
--]]--<<---------------------------------------------------->>--

local ServerScriptService = game:GetService("ServerScriptService")

--Dependency group 0
local PurchaseManager = require(ServerScriptService:WaitForChild("PurchaseManager")).new()

--Dependency group 1
local AvatarManager = require(ServerScriptService:WaitForChild("AvatarManager")).new(PurchaseManager)
local CabanaManager = require(ServerScriptService:WaitForChild("CabanaManager")).new(PurchaseManager)