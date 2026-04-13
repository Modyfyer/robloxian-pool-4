type DevProduct = {
	Amount: number,
	DeveloperProductId: number,
	ProductName: string,
}

local ItemsData = {}

ItemsData.DevProducts = {
	{ Amount = 1, DeveloperProductId = 1555280575, ProductName = "CabanaRental24h" },
} :: { DevProduct }

function ItemsData:GetDevProductByName(productName: string)
	for _, devProduct in pairs(ItemsData.DevProducts) do
		if devProduct.ProductName == productName then
			return devProduct
		end
	end
	return nil
end

return ItemsData
