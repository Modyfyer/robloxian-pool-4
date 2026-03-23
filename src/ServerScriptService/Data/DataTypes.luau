local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

local DataTypes = {}

export type Quest = {
	questID: number,
	requiredAmount: number,
	completedAmount: number,
}

export type Purchase = {
	purchaseID: string,
	productID: number,
	itemCost: number,
	purchaseDate: string,
}

export type DataTemplate = {
	poolPoints: number,
	inventory: {
		actions: {},
		emotes: {},
		outfits: {},
		tools: {},
	},
	daysLoggedIn: number,
	settings: SharedSettings.hudSettings,
	cabanaSettings: SharedSettings.cabanaSettings,
	cabanaRentalTime: string,
	purchases: { Purchase },
	quests: { Quest },
	playerStats: {
		timePlayed: number,
	},
}

local ProfileTemplate: DataTemplate = {
	poolPoints = 0,
	inventory = {
		actions = {},
		emotes = {},
		outfits = {},
		tools = {},
	},
	daysLoggedIn = 0,
	settings = SharedSettings.DefaultHUDSettings,
	cabanaSettings = SharedSettings.DefaultCabanaSettings,
	cabanaRentalTime = "",
	purchases = {},
	quests = {},
	playerStats = {
		timePlayed = 0,
	},
}

local PLAYER_DATA_KEY: string = "Player_"
local PLAYER_DATA_STORE_NAME: string = if RunService:IsStudio() then "Player_data_studio" else "Player_data_live"

DataTypes.PlayerDataKey = PLAYER_DATA_KEY
DataTypes.PlayerDataStoreName = PLAYER_DATA_STORE_NAME
DataTypes.ProfileTemplate = ProfileTemplate

return DataTypes
