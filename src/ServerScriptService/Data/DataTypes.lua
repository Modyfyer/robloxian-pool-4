local RunService = game:GetService("RunService")

local DataTypes = {}

export type DataTemplate = {
    poolPoints: number,
    inventory: {
        actions: {},
        emotes: {},
        outfits: {},
        tools: {}
    },
    daysLoggedIn: number,
    settings: {
        gameVolume: number,
        musicVolume: number,
        uiVolume: number
    },
    cabanaSettings: {
        accentColors: {
        red: number,
        green: number,
        blue: number
        },
        currentSongID: number,
        allowedFriends: string,
        tvChannel: string
    },
    cabanaRentalTime: string,
    purchases: {
        purchaseID: string,
        productID: number,
        itemCost: number,
        purchaseDate: string,
    },
    quests: {
        questID: number,
        requiredAmount: number,
        completedAmount: number
    },
    playerStats: {
        timePlayed: number,
    }
}

local ProfileTemplate: DataTemplate = {
    poolPoints = 0,
    inventory = {},
    daysLoggedIn = 0,
    settings = {},
    cabanaSettings = {
        accentColors = {
            red = 0,
            green = 0,
            blue = 0
        },
        currentSongID = 0,
        allowedFriends = "All",
        tvChannel = "News"
    },
    cabanaRentalTime = -1,
    purchases = {},
    quests = {},
    playerStats = {},
}

local PLAYER_DATA_KEY: string = "Player_"
local PLAYER_DATA_STORE_NAME: string = if RunService:IsStudio() then "Player_data_studio" else "Player_data_live"

DataTypes.PlayerDataKey = PLAYER_DATA_KEY
DataTypes.PlayerDataStoreName = PLAYER_DATA_STORE_NAME
DataTypes.ProfileTemplate = ProfileTemplate

return DataTypes