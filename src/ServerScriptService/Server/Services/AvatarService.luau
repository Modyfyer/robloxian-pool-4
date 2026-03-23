--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Data
--local ItemsData = require(ReplicatedStorage.Data.ItemsData)

local AvatarService = Knit.CreateService({
	Name = "AvatarService",
	Client = {},
})

local blackListNames: { string } = { "Aura", "Tail" }
local handleWhiteList: { string } =
	{ "Attachment", "ValueBase", "Weld", "SpecialMesh", "SurfaceAppearance", "WrapLayer" }

function AvatarService:cleanAccessory(hat)
	if not hat:IsA("Hat") or hat:IsA("Accessory") then
		return
	end

	task.delay(3, function()
		for _, n in pairs(blackListNames) do
			if string.find(hat.Name:lower(), n:lower()) then
				hat:Destroy()
				return
			end
		end
		if hat.AccessoryType == Enum.AccessoryType.Back then
			hat:Destroy()
		else
			for _, a in pairs(hat:GetChildren()) do
				if a.Name ~= "Handle" then
					a:Destroy()
				else
					for _, b in pairs(a:GetChildren()) do
						local isWhiteListed = false
						for _, cls in pairs(handleWhiteList) do
							if b:IsA(cls) then
								isWhiteListed = true
								break
							end
						end
						if not isWhiteListed then
							b:Destroy()
						end
					end
				end
			end
		end
	end)
end

function AvatarService:KnitStart()
	workspace.DescendantAdded:Connect(function(descendant)
		self:cleanAccessory(descendant)
	end)
end

function AvatarService:KnitInit() end

return AvatarService
