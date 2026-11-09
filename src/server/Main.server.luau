-- Startpunt van de server. Bouwt de wereld en start alle onderdelen.

local Remotes = require(script.Parent.Remotes)
local World = require(script.Parent.World)
local PlayerData = require(script.Parent.PlayerData)
local Lab = require(script.Parent.Lab)
local Weather = require(script.Parent.Weather)
local Shop = require(script.Parent.Shop)
local Rewards = require(script.Parent.Rewards)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

World.Build()
Lab.Start()
Shop.Start()
Rewards.Start()
Weather.Start()

PlayerData.Start(function(player, _data, offlineCoins)
	Lab.OnPlayerLoaded(player)
	if offlineCoins > 0 then
		task.delay(3, function()
			Remotes.Notify:FireClient(
				player,
				"Je lab verdiende " .. Config.FormatNumber(offlineCoins) .. " munten terwijl je weg was!",
				Color3.fromRGB(255, 220, 80)
			)
		end)
	end
end)
