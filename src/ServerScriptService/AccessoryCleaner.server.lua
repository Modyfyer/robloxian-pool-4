local blackListNames = {"Aura", "Tail"}
local handleWhiteList = {"Attachment", "ValueBase", "Weld", "SpecialMesh", "SurfaceAppearance", "WrapLayer"}

local function cleanAccessory(hat)
	if hat:IsA("Hat") or hat:IsA("Accessory") then
		spawn(function()
			wait(3)
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
end

workspace.DescendantAdded:Connect(cleanAccessory)