type DevProduct = {
	Amount: number,
	DeveloperProductId: number,
	ProductName: string,
}

local ItemsData = {}

ItemsData.DevProducts = {
	{ Amount = 1, DeveloperProductId = 1555280575, ProductName = "CabanaRental24h" },
} :: { DevProduct }

return ItemsData
