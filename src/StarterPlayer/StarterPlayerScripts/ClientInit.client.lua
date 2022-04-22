--[[--<<---------------------------------------------------->>--
Purpose: Initializes high level objects

Initialized by: Self
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")

--Dependency group 0
local LocalPlayer = Players.LocalPlayer

-- Dependency group 1
local managersFolder = LocalPlayer.PlayerScripts:WaitForChild("Managers")

--Dependency group 2
local uiFolder = managersFolder.UI
local platformDetectionManager = require(managersFolder:WaitForChild("PlatformDetectionManager"))
platformDetectionManager = platformDetectionManager.new()

--Dependency group 3
local hudUIManager = require(uiFolder.HUDUIManager)
hudUIManager = hudUIManager.new(platformDetectionManager)

