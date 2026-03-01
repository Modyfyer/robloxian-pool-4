local ServerScriptService = game:GetService("ServerScriptService")

-- --Dependency group 0
-- local DataManager = require(ServerScriptService:WaitForChild("Data"):WaitForChild("DataManager"))
-- DataManager.new()

-- repeat
--     task.wait()
-- until DataManager ~= nil

-- --Dependency group 1
-- local PurchaseManager = require(ServerScriptService:WaitForChild("Data"):WaitForChild("PurchaseManager"))
-- PurchaseManager.new(DataManager)

-- local SettingsManager = require(ServerScriptService:WaitForChild("SettingsManager"))
-- SettingsManager.new(DataManager)

-- --Dependency group 2
-- local AvatarManager = require(ServerScriptService:WaitForChild("AvatarManager"))
-- AvatarManager.new(DataManager, PurchaseManager)
-- local CabanaManager = require(ServerScriptService:WaitForChild("CabanaManager"))
-- CabanaManager.new(DataManager, PurchaseManager)
-- local ShopsManager = require(ServerScriptService:WaitForChild("ShopsManager"))
-- ShopsManager.new(DataManager, PurchaseManager)