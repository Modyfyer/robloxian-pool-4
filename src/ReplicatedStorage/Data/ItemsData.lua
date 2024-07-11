--Services
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Declarations
type currencyType = "Robux" | "PoolPoints"

export type InventoryItem = {
	category: string,
	currencyTypeName: currencyType,
    displayName: string,
    itemID: string,
    image: string,
	price: number,
}

export type DevProductItem = {
	amount: number,
	currencyTypeName: currencyType,
	developerProductID: number,
	displayName: string,
	productName: string,
}

type itemsData = {
	actions: {InventoryItem},
	developerProducts: {string: DevProductItem},
	emotes: {InventoryItem},
	floaties: {InventoryItem},
	hats: {InventoryItem},
	pants: {InventoryItem},
	swimsuits: {InventoryItem},
	tools: {InventoryItem},
}

--Module
local ItemsData: itemsData = {
	developerProducts = {
		["CabanaRental24h"] = {
			amount = 1,
			currencyTypeName = "Robux",
			developerProductID = 1555280575,
			displayName = "Cabana Rental (24 hours)",
			productName = "CabanaRental24h"
		}
	},
	floaties = {
		{
			category = "floaties",
			currencyTypeName = "Robux",
			displayName = "Balloon Animal",
			itemID = "dske-sk21-md31",
			image = "",
			price = -1
		},
	},
	hats = {
		{
			category = "hats",
			currencyTypeName = "Robux",
			displayName = "Hardware Snorkel",
			itemID = "dske-th63-md32",
			image = "",
			price = -1
		},
		{
			category = "hats",
			currencyTypeName = "Robux",
			displayName = "Hex Goggles",
			itemID = "dske-iu84-md33",
			image = "",
			price = -1
		},
	},
}

return ItemsData
