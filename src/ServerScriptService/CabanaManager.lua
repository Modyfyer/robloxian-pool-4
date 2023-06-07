--[[--<<---------------------------------------------------->>--
Module purpose: Handles the cabana rental and management interface

Initialized by: ServerInit
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

local CabanaManager = {}
CabanaManager.__index = CabanaManager

--[[**
	Creates new instance
**--]]
function new()
	local self = setmetatable({}, CabanaManager)

	-- Dependency group 0
	local connectionManager = ConnectionManager.new()

	return self
end

function CabanaManager:RentCabana(player: Player, cabana: Instance)

end

return {
	new = new
}