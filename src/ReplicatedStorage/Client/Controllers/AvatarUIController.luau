-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local AvatarUIController = Knit.CreateController({
	Name = "AvatarUIController",
})

function AvatarUIController:KnitStart() end

function AvatarUIController:KnitInit()
	-- self._mainFrame = PlayerGui:WaitForChild("MainFrame") :: Frame

	-- self._background = self._mainFrame:WaitForChild("BG") :: ImageLabel
end

return AvatarUIController
