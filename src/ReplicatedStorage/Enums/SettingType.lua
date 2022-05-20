local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GenerateEnumTable = require(ReplicatedStorage.Utils.GenerateEnumTable)

return GenerateEnumTable({
	OnOff = 1,
	Dropdown = 2,
	ArrowSelection = 3,
	TextEntry = 4,
	Slider = 5
})