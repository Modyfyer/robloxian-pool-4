export type colorRGB = {
	red: number,
	green: number,
	blue: number
}

export type allowedFriends = "All" | "Friends" | "None"

export type channel = "News" | "Weather" | "Kittens"

export type settingType = "OnOff" | "Slider" | "TextEntry"

export type cabanaSettings = {
	accentColors: colorRGB,
	currentSongID: number,
	allowedFriends: allowedFriends,
	tvChannel: channel
}

export type hudSettings = {
	musicVolume: number,
	sfxVolume: number,
	uiVolume: number
}

local module = {}

local cSettings: cabanaSettings = {
	accentColors = {
		red = 0,
		green = 0,
		blue = 0
	},
	currentSongID = 0,
	allowedFriends = "All",
	tvChannel = "News"
}

local hSettings: hudSettings = {
	musicVolume = 0,
	sfxVolume = 0,
	uiVolume = 0
}

local hudSettingsDisplayInfo: {string: settingType} = {
	musicVolume = "Slider",
	sfxVolume = "Slider",
	uiVolume = "Slider"
}

module.DefaultCabanaSettings = cSettings
module.DefaultHUDSettings = hSettings

module.HUDSettingsDisplayInfo = hudSettingsDisplayInfo

module.AllowedFriends = {"All", "Friends", "None"}
module.Channels = {"News", "Weather", "Kittens"}

return module