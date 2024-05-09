export type colorRGB = {
	red: number,
	green: number,
	blue: number
}

export type allowedFriends = "All" | "Friends" | "None"

export type channel = "News" | "Weather" | "Kittens"

export type cabanaSettings = {
	accentColors: colorRGB,
	currentSongID: number,
	allowedFriends: allowedFriends,
	tvChannel: channel
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

module.DefaultSettings = cSettings

module.Channels = {"News", "Weather", "Kittens"}
module.AllowedFriends = {"All", "Friends", "None"}

return module