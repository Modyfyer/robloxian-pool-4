--[[--<<---------------------------------------------------->>--
Purpose: Initializes high level objects

Initialized by: Self
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

--Dependency group 0
local CabanaManager = require(ServerScriptService:WaitForChild("CabanaManager")).new()