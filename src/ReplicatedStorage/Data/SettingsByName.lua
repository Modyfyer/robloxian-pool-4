local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingType = require(ReplicatedStorage.Enums.SettingType)

local SettingsByName = {
	MusicVolume = {
		displayName = "Music Volume",
		settingType = SettingType.TextEntry
	},
	GameVolume = {
		displayName = "Game Volume",
		settingType = SettingType.Slider,
	},
}
return {
	SettingsByName = SettingsByName,
}