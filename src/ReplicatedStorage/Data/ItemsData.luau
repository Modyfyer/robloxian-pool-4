export type OutfitItemType = "Hats" | "Swimsuits" | "Floaties" | "Pants"

type DevProduct = {
	Amount: number,
	DeveloperProductId: number,
	ProductName: string,
}

type OutfitItem = {
	ItemName: string,
	ItemID: string,
	Category: OutfitItemType,
}

local ItemsData = {}

ItemsData.LifeguardGamepassID = 703084245

ItemsData.DevProducts = {
	{ Amount = 1, DeveloperProductId = 1555280575, ProductName = "CabanaRental24h" },
} :: { DevProduct }

ItemsData.OutfitItems = {
	Floaties = {
		{ ItemName = "Duck", ItemID = "FJDS-ENSK-VT94", Category = "Floaties" },
	},
	Hats = {
		{ ItemName = "Baseball Cap", ItemID = "FJDS-ENSK-EO24", Category = "Hats" },
	},
	Pants = {
		{ ItemName = "Jeans", ItemID = "FJDS-ENSK-MC65", Category = "Pants" },
	},
	Swimsuits = {
		{ ItemName = "Swim Trunks", ItemID = "FJDS-ENSK-JN50", Category = "Swimsuits" },
	},
} :: { [OutfitItemType]: { OutfitItem } }

function ItemsData:GetDevProductByName(productName: string): DevProduct?
	for _, devProduct in pairs(ItemsData.DevProducts) do
		if devProduct.ProductName == productName then
			return devProduct
		end
	end
	return nil
end

function ItemsData:GetOutfitByName(outfitName: string, itemCategory: OutfitItemType): OutfitItem?
	for category, items in pairs(ItemsData.OutfitItems) do
		if category ~= itemCategory then
			continue
		end
		for _, item in pairs(items) do
			if item.ItemName == outfitName then
				return item
			end
		end
	end
	return nil
end

return ItemsData
