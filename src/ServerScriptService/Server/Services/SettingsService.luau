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
		SaveSettings = Knit.CreateSignal(),
	},
})

local DataService = nil

----- Private Functions -----
function SettingsService:_loadSettings(player: Player, data)
	local settings = data.settings
	self.Client.HUDSettingsLoaded:Fire(player, settings)
end

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
function SettingsService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataService.ProfileLoaded:Connect(function(player: Player, data)
		self:_loadSettings(player, data)
	end)
end

function SettingsService:KnitStart()
	-- No additional startup needed
end

return SettingsService
