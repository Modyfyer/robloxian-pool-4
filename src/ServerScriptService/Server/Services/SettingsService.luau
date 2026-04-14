-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

-- Declarations
local SettingsService = Knit.CreateService({
	Name = "SettingsService",
	Client = {
		HUDSettingsLoaded = Knit.CreateSignal(),
	},
})

local DataService = nil

----- Public Functions -----
function SettingsService:SaveSettings(player: Player, settings: SharedSettings.hudSettings)
	local saved = DataService:SetKey(player, "settings", settings)
	warn("Data saved for", player.Name, ":", saved)
end

----- Client Functions -----
function SettingsService.Client:SaveSettings(player: Player, settings: SharedSettings.hudSettings)
	self.Server:SaveSettings(player, settings)
end

----- Initialize -----
function SettingsService:KnitInit() end

function SettingsService:KnitStart()
	DataService = Knit.GetService("DataService")
	DataService.ProfileLoaded:Connect(function(player: Player, data)
		self.Client.HUDSettingsLoaded:Fire(player, data.settings)
	end)
end

return SettingsService
