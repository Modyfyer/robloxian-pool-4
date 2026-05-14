-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local ASSETS_FOLDER: Folder = ReplicatedStorage:WaitForChild("Assets")

local TabsComponent = require(ReplicatedStorage.Client.Components.TabsComponent)

local AvatarUIController = Knit.CreateController({
	Name = "AvatarUIController",
})
AvatarUIController._trove = Trove.new()

function AvatarUIController:_createItemsList()
	--TODO: get this from data
	local inventory = {
		actions = { "walk", "run" },
		emotes = { "happy", "sad" },
		outfits = {
			Floaties = { "duck" },
			Hats = { "Baseball Cap" },
			Pants = { "Jeans" },
			Swimsuits = { "Swim Trunks" },
		},
		tools = { "hammer" },
	}

	for category, items in inventory.outfits do
		for _, item in pairs(items) do
			local slot = self._slotTemplate:Clone()
			slot.ItemName.Text = item
			slot:SetAttribute("ItemCategory", category)
			slot.Visible = true
			slot.Parent = self._itemsContainer
		end
	end
end

function AvatarUIController:KnitStart()
	local function filterBySelectedTab(selectedTab: string)
		for _, item in pairs(self._itemsContainer:GetChildren()) do
			if not item:IsA("ImageLabel") then
				continue
			end
			item.Visible = (item:GetAttribute("ItemCategory") == selectedTab)
		end
	end

	TabsComponent:WaitForInstance(self._tabsContainer):andThen(function(myInstance)
		self:_createItemsList()
		filterBySelectedTab(myInstance.SelectedTab)
	end)

	for _, tab in pairs(self._tabsContainer:GetChildren()) do
		if not tab:IsA("GuiButton") then
			continue
		end
		self._trove:Connect(tab.Activated, function()
			filterBySelectedTab(tab.Name)
		end)
	end
end

function AvatarUIController:KnitInit()
	self._screenGui = PlayerGui:WaitForChild("AvatarGui") :: ScreenGui
	self._mainFrame = self._screenGui:WaitForChild("MainFrame") :: Frame

	self._itemsContainer = self._mainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
	self._slotTemplate =
		ASSETS_FOLDER:WaitForChild("Templates"):WaitForChild("UI"):WaitForChild("AvatarSlot") :: ImageLabel
	self._tabsContainer = self._mainFrame:WaitForChild("Tabs") :: Frame
end

return AvatarUIController
