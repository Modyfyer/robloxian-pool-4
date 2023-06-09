local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GenerateEnumTable = require(ReplicatedStorage.Utils.GenerateEnumTable)

return GenerateEnumTable({
	InGameCurrency = 1,
	GamePass = 2,
	Rental = 3,
	Food = 4,
})