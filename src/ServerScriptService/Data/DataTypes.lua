local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

local DataTypes = {}

type currencyType = "Robux" | "PoolPoints"

export type InventoryItem = {
	category: string,
	currencyTypeName: currencyType,
    displayName: string,
    itemID: string,
    image: string,
	price: number,
}

export type Outfit = {
    floaties: {InventoryItem},
    hats: {InventoryItem},
    pants: {InventoryItem},
    swimsuits: {InventoryItem}
}

export type Inventory = {
    actions: {InventoryItem},
    emotes: {InventoryItem},
    floaties: {InventoryItem},
    hats: {InventoryItem},
    outfits: {Outfit},
    pants: {InventoryItem},
    swimsuits: {InventoryItem},
    tools: {InventoryItem}
}

export type DataTemplate = {
    poolPoints: number,
    inventory: Inventory,
    currentOutfit: Outfit,
    daysLoggedIn: number,
    settings: SharedSettings.hudSettings,
    cabanaSettings: SharedSettings.cabanaSettings,
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
    inventory = {
        actions = {},
        emotes= {},
        floaties= {},
        hats= {},
        outfits= {},
        pants= {},
        swimsuits= {},
        tools= {}
    },
    currentOutfit = {
        floaties = {},
		hats = {},
		pants = {},
		swimsuits = {}
    },
    daysLoggedIn = 0,
    settings = SharedSettings.DefaultHUDSettings,
    cabanaSettings = SharedSettings.DefaultCabanaSettings,
    cabanaRentalTime = "",
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