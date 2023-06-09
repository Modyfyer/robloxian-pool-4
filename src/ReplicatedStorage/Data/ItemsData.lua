local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemType = require(ReplicatedStorage.Enums.ItemType)

local nullCheckMetatable = {}
nullCheckMetatable.__index = function(_, key)
	error("Attempt to index constant '" .. key .. "', which is not declared.")
end

local module = {}
setmetatable(module, nullCheckMetatable)

--Actual items data
module.Items = {}

module.Items[ItemType.InGameCurrency] = {
    {
        CurrencyTypeName = "Robux",
		DeveloperProductId = 1555280575,
		Value = 1,
        ProductName = "CabanaRentalUnlimited"
	},
}

module.Items[ItemType.GamePass] = {
    {
        CurrencyTypeName = "Robux",
		DeveloperProductId = 1555280575,
		Value = 1,
        ProductName = "CabanaRentalUnlimited"
	},
}

module.Items[ItemType.Rental] = {

        CurrencyTypeName = "Robux",
		DeveloperProductId = 1555280575,
		Value = 1,
        ProductName = "CabanaRental24h"
}

-- module.Items[ItemType.Ability] = {
-- 	["{1523D49B-F496-4273-9E3C-6FA8FACDDA11}"] = {
-- 		AbilityKey = "TempoBurst",
-- 		Description = "Speed past everyone for a short time, destroying everything in your path.",
-- 		DisplayName = "Tempo Burst",
-- 		Icon = {
-- 			BlackWhite = "rbxassetid://3559363683",
-- 			Color = "rbxassetid://3559093745"
-- 		},
-- 		IsForSale = true,
-- 		NotesRequired = 12,
-- 		Prices = {
-- 			{
-- 				CurrencyAmount = 100,
-- 				CurrencyTypeName = SharedConstants.coinsCurrencyTypeName,
-- 			}
-- 		}
-- 	},
-- }


module.DoesItemExist = function(itemType, itemID)
	return module.Items[itemType] ~= nil and module.Items[itemType][itemID] ~= nil
end

return module
