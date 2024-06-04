--[[--<<---------------------------------------------------->>--
Purpose: Initializes high level objects

Initialized by: Self
--]]--<<---------------------------------------------------->>--

local Players = game:GetService("Players")

--Dependency group 0
local LocalPlayer: Player = Players.LocalPlayer

-- Dependency group 1
local managersFolder: Folder = LocalPlayer.PlayerScripts:WaitForChild("Managers")

--Dependency group 2
local uiFolder: Folder = managersFolder.UI
local platformDetectionManager = require(managersFolder:WaitForChild("PlatformDetectionManager")).new()

--Dependency group 3
local cabanaUIManager = require(uiFolder.CabanaUIManager)
cabanaUIManager = cabanaUIManager.new(platformDetectionManager)

local hudUIManager = require(uiFolder.HUDUIManager)
hudUIManager = hudUIManager.new(platformDetectionManager)

--Dependency group 4
local avatarUIManager = require(uiFolder.AvatarUIManager)
avatarUIManager = avatarUIManager.new(hudUIManager, platformDetectionManager)

local settingsUIManager = require(uiFolder.SettingsUIManager)
settingsUIManager = settingsUIManager.new(hudUIManager, platformDetectionManager)

avatarUIManager:Hide()
settingsUIManager:Hide()

