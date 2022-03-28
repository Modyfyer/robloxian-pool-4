local Players = game:GetService("Players")
--local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local managersFolder = LocalPlayer.PlayerScripts

--Dependency group 1
local hudUIManager = require(managersFolder:WaitForChild("HUDUIManager"))
hudUIManager.new()

