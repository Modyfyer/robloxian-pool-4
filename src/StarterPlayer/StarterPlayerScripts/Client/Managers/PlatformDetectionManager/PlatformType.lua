--[[--<<---------------------------------------------------->>--
Module purpose: Generates enum of platform types (desktop, mobile, console)
--]]--<<---------------------------------------------------->>--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenerateEnumTable = require(ReplicatedStorage.Utils.GenerateEnumTable)

return GenerateEnumTable({
    Desktop = 1,
    Mobile = 2,
    Console = 3
})