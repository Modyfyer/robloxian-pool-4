return function (enumDictionary)
	local enumTable = {}
	
	for enumName, enumValue in pairs(enumDictionary) do
		enumTable[enumName] = enumValue
		enumTable[enumValue] = enumName
	end
	
	return enumTable
end