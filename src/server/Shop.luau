-- Kopen met munten: betere netten en extra planken.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local Lab = require(script.Parent.Lab)
local Remotes = require(script.Parent.Remotes)

local Shop = {}

function Shop.Start()
	Remotes.BuyNet.OnServerInvoke = function(player: Player)
		local data = PlayerData.Get(player)
		if not data then
			return false, "Even geduld, je data wordt geladen."
		end
		local nextNet = Config.Nets[data.netTier + 1]
		if not nextNet then
			return false, "Je hebt al het beste net!"
		end
		if data.coins < nextNet.price then
			return false, "Niet genoeg munten."
		end
		PlayerData.SetCoins(player, data.coins - nextNet.price)
		data.netTier = nextNet.tier
		PlayerData.Sync(player)
		return true, "Je hebt nu een " .. nextNet.name .. "!"
	end

	Remotes.BuyShelf.OnServerInvoke = function(player: Player)
		local data = PlayerData.Get(player)
		if not data then
			return false, "Even geduld, je data wordt geladen."
		end
		if data.shelves >= Config.MaxShelves then
			return false, "Je lab zit vol met planken!"
		end
		local price = Config.ShelfPrice(data.shelves)
		if data.coins < price then
			return false, "Niet genoeg munten."
		end
		PlayerData.SetCoins(player, data.coins - price)
		data.shelves += 1
		Lab.Render(player)
		PlayerData.Sync(player)
		return true, "Extra plank gekocht: " .. Config.SlotsPerShelf .. " plekken erbij!"
	end
end

return Shop
