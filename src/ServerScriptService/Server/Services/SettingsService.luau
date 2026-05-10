-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

-- Types
type Settings = SharedSettings.hudSettings

-- Declarations
local DataService = nil

local SettingsService = Knit.CreateService({
	Name = "SettingsService",
	Client = {
		HUDSettingsLoaded = Knit.CreateSignal(),
	},
})
SettingsService.PlayerSettings = {} :: { [Player]: Settings }

----- Public Functions -----
function SettingsService:SaveSettings(player: Player, settings: SharedSettings.hudSettings)
	DataService:SetKey(player, "settings", settings)
end

----- Client Functions -----
function SettingsService.Client:SaveSettings(player: Player, settings: Settings)
	self.Server:SaveSettings(player, settings)
end

----- Initialize -----
function SettingsService:KnitInit() end

function SettingsService:KnitStart()
	DataService = Knit.GetService("DataService")
	DataService.ProfileLoaded:Connect(function(player: Player, data)
		self.Client.HUDSettingsLoaded:Fire(player, data.settings)
		self.PlayerSettings[player] = data.settings
	end)
end

return SettingsService
