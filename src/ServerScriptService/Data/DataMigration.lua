local DataMigration = {}

-- Updates previously saved data
function DataMigration.run(data: any)
	if data["poolPoints"] then
		data["poolPoints"] = nil
	end
    if data["inventory"] then
		data["inventory"] = nil
	end
    if data["daysLoggedIn"] then
		data["daysLoggedIn"] = nil
	end
    if data["settings"] then
		data["settings"] = nil
	end
    if data["cabanaSettings"] then
		data["cabanaSettings"] = nil
	end
    if data["cabanaRentalTime"] then
		data["cabanaRentalTime"] = nil
	end
    if data["purchases"] then
		data["purchases"] = nil
	end
    if data["quests"] then
		data["quests"] = nil
	end
    if data["playerStats"] then
		data["playerStats"] = nil
	end
end

return DataMigration
