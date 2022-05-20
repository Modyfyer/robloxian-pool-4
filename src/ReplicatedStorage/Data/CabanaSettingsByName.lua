local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingType = require(ReplicatedStorage.Enums.SettingType)

local CabanaSettingsByName = {
	AccentColorRed = {
		defaultValue = 0,
		displayName = "Accent Color Red",
		settingType = SettingType.TextEntry,
	},
	AccentColorGreen = {
		defaultValue = 0,
		displayName = "Accent Color Green",
		settingType = SettingType.TextEntry,
	},
	AccentColorBlue = {
		defaultValue = 0,
		displayName = "Accent Color Blue",
		settingType = SettingType.TextEntry,
	},
	SongID = {
		defaultValue = 0,
		displayName = "Song ID",
		settingType = SettingType.TextEntry,
	},
	AllowedFriends = {
		defaultValue = 0,
		displayName = "Allowed Friends",
		settingType = SettingType.ArrowSelection,
	},
	TVChannel = {
		defaultValue = 0,
		displayName = "TV Channel",
		settingType = SettingType.ArrowSelection,
	},
}
return {
	CabanaSettingsByName = CabanaSettingsByName,
}